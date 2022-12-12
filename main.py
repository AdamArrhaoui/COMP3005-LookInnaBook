import PySimpleGUI as sg
import psycopg2
from psycopg2 import extensions

DDL_PATH = "SQL/DDL.sql"
DML_PATH = "SQL/DML.sql"


def db_login_prompt(default_dbname='bookstore', default_user='postgres', default_password='postgres') -> psycopg2.extensions.connection:

    layout = [[sg.Push(), sg.T("Please enter PostgreSQL database login information"), sg.Push()],
              [sg.Push(), sg.T("user:"), sg.Input(default_text=default_user, key='user')],
              [sg.Push(), sg.T("password:"), sg.Input(default_text=default_password, key='password')],
              [sg.Push(), sg.T("dbname:"), sg.Input(default_text=default_dbname, key="dbname")],
              [sg.Push(), sg.Submit(), sg.Push()]]

    window = sg.Window("Database Login", layout)

    values = None

    while True:
        event, values = window.read()
        if event in (sg.WIN_CLOSED, 'Exit'):
            break
        if event == "Submit":
            try:
                connection_text = f"dbname={values['dbname']} user={values['user']} password={values['password']}"
                # Connect to an existing database
                conn = psycopg2.connect(connection_text)
                if conn.closed == 0:
                    window.close()
                    return conn
            except Exception as e:
                sg.popup_error(e, title="Error connecting to database!")
    window.close()
    exit()


def ensure_tables_exist(conn):
    # Open a cursor to perform database operations
    with conn.cursor() as cur:
        # Check if tables exist in db
        cur.execute("select exists(select * from information_schema.tables where table_name=%s)", ('books',))
        if cur.fetchone()[0] == False:
            # If tables
            answer = sg.popup_yes_no("books table does not exist! Do you want to run DDL file to create all tables in database?")
            if answer and answer == "Yes":
                cur.execute(open(DDL_PATH, "r").read())
                answer = sg.popup_yes_no("Do you want to run DML file to fill tables with sample data?")
                if answer and answer == "Yes":
                    cur.execute(open(DML_PATH, "r").read())
                conn.commit()
            else:
                return False
        return True


def show_login_signup(conn: psycopg2.extensions.connection) -> tuple[int, str, str]:
    name_minlen = 3
    name_maxlen = 30
    text_maxlen = 150

    with conn.cursor() as cur:
        # get list of all users
        cur.execute("SELECT uid, fname, lname FROM users")
        available_users = cur.fetchall()
        print(available_users)
        # create the tabs
        tab1 = sg.Tab('Signup', [
            [sg.Push(), sg.Text("Use the form below to sign up!"), sg.Push()],
            [sg.Push(), sg.Text('First Name'), sg.InputText(do_not_clear=True, enable_events=True, k='s_fname')],
            [sg.Push(), sg.Text('Last Name'), sg.InputText(do_not_clear=True, enable_events=True, k='s_lname')],
            [sg.HSep()],
            [sg.Push(), sg.Text('Billing Info (optional)'), sg.Multiline(size=(40, 3), enable_events=True, k='s_billing')],
            [sg.Push(), sg.Text('Shipping Info (optional)'), sg.Multiline(size=(40, 3), enable_events=True, k='s_shipping')],
            [sg.Push(), sg.Submit("Sign Up", k='signup'), sg.Push()]
        ])

        tab2 = sg.Tab('Login', [
            [sg.P(),sg.T("Select a user to login as:"),sg.P()],
            [sg.P(),sg.Table(values=available_users, headings=["uid", "First Name", "Last Name"], k='user_table'),sg.P()],
            [sg.P(),sg.Submit("Login", k='login'),sg.P()]
        ])

        # create the layout with the tabs
        layout = [
            [sg.TabGroup([[tab1, tab2]])]
        ]
        # create the window and show it
        window = sg.Window('User Login/Signup', layout)

        while True:  # Event Loop
            event, values = window.Read()
            print(event, values)
            if event is None or event == 'Exit':
                window.close()
                return
            # input validation
            for name_input_key in ('s_fname', 's_lname'):
                if len(values[name_input_key]) > name_maxlen:
                    window.Element(name_input_key).Update(values[name_input_key][:-1])
            for text_input_key in ('s_billing', 's_shipping'):
                if len(values[text_input_key]) > text_maxlen:
                    window.Element(text_input_key).Update(values[text_input_key][:-1])

            if event == "login":
                if len(values['user_table']) == 0:
                    sg.popup_ok("No user selected!")
                    continue
                logged_in_user = available_users[values['user_table'][0]]
                print(f"Logged in as {logged_in_user}")
                window.close()
                return logged_in_user

            if event == "signup":
                valid = True
                # min length validation
                for name_input_key in ('s_fname', 's_lname'):
                    if len(values[name_input_key]) < name_minlen:
                        valid = False
                        break
                if not valid:
                    sg.popup_ok(f"First/Last name should be at least {name_minlen} characters")
                    continue
                else:
                    try:
                        new_user = (values['s_fname'], values['s_lname'], values['s_billing'], values['s_shipping'])
                        cur.execute(f"INSERT INTO users (fname, lname, billing_info, shipping_info) VALUES {new_user} RETURNING uid")
                    except Exception as e:
                        sg.popup_error(e, title="Error creating new user in database!")
                        continue

                    logged_in_user = (cur.fetchone()[0], values['s_fname'], values['s_lname'])
                    conn.commit()
                    sg.popup(f"Signed up as {logged_in_user}", custom_text="Nice")
                    window.close()
                    return logged_in_user


def main():
    # Connect to an existing database
    conn = db_login_prompt()

    if not ensure_tables_exist(conn):
        sg.popup_auto_close("Goodbye", auto_close_duration=1)
        exit()

    logged_in_uid, logged_in_fname, logged_in_lname = show_login_signup(conn)

    if not logged_in_uid:
        print("bruh")
        exit()
    cur = conn.cursor()

    row_names = "isbn, authors, title, publish_date, num_pages, price"
    # Query the database and obtain data as Python objects
    cur.execute(f"SELECT {row_names} FROM (select * FROM books NATURAL JOIN BookAuthorNames) b")
    books = cur.fetchall()

    bookstore_tab = sg.Tab("Bookstore", [
        [sg.Text('Select a book to purchase, and enter a quantity')],
        [sg.Table(values=books, headings=row_names.split(", "), select_mode=sg.TABLE_SELECT_MODE_EXTENDED, k="book_table")],
        [sg.Text("quantity:"), sg.Spin(values=[*range(1, 100)], key="in_quantity", size=3), sg.Button('Add to Cart')]
    ])

    current_cart = {}
    # current_cart = {'1234567890': ["harry Botter", 1, 15.99]}
    cart_tab = sg.Tab("Cart", [
        [sg.Text('This is your shopping cart')],
        [sg.Table(values=[[key] + current_cart[key] for key in current_cart.keys()],
                  headings=["isbn", "title", "quantity", "price"], select_mode=sg.TABLE_SELECT_MODE_NONE,
                  k="cart_table")],
        [sg.Button("Purchase")]
    ])
    # Make the window
    layout = [
        [sg.Text(f"Hello, {logged_in_fname} {logged_in_lname}!")],
        [sg.HSep()],
        [sg.TabGroup([[bookstore_tab, cart_tab]])],
        [sg.Button('Exit')]
    ]

    window = sg.Window('Bookstore', layout)

    # Event Loop to process "events" and get the "values" of the inputs
    while True:
        event, values = window.read()
        print(event, values)
        if event == sg.WIN_CLOSED or event == 'Exit':  # if user closes window or clicks cancel
            break

        if event == 'Add to Cart':
            if len(values['book_table']) == 0:
                sg.popup_ok("No book selected!")
                continue

            selected_quantity = values['in_quantity']
            selected_book = books[values["book_table"][0]]
            selected_isbn = selected_book[0]
            selected_title = selected_book[2]
            selected_price = selected_book[len(selected_book) - 1]

            if selected_isbn in current_cart.keys():
                current_cart[selected_isbn][1] += selected_quantity
                current_cart[selected_isbn][2] += selected_price * selected_quantity
            else:
                current_cart[selected_isbn] = [selected_title, selected_quantity, selected_price * selected_quantity]
            window.Element("cart_table").Update(values=[[key] + current_cart[key] for key in current_cart.keys()])
            sg.popup_ok(f"Added {selected_quantity} copies of '{selected_title}' to cart!")

        if event == 'Purchase':
            if len(current_cart) == 0:
                sg.popup_ok("There's nothing in your cart!")
                continue

            answer = sg.popup_yes_no("Are you sure you want to order all the items in your cart?")
            if answer and answer == "Yes":
                try:
                    cur.execute(f"INSERT INTO orders (uid, billing_info, shipping_info) VALUES ({logged_in_uid}, 'Placeholder', 'Placeholder') RETURNING oid")
                    new_oid = cur.fetchone()[0]
                    data = [(key, new_oid, current_cart[key][1]) for key in current_cart.keys()]
                    records_list_template = ','.join(['%s'] * len(data))
                    insert_query = 'INSERT INTO booksinorders (isbn, oid, quantity) VALUES {}'.format(records_list_template)
                    cur.execute(insert_query, data)
                except Exception as e:
                    sg.popup_error(e)
                    continue
                else:
                    conn.commit()
                    sg.popup_ok("Order placed!")
                    current_cart = {}
                    window.Element("cart_table").Update(values=[[]])
            else:
                continue

    window.close()
    cur.close()




# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    main()


# See PyCharm help at https://www.jetbrains.com/help/pycharm/
