import PySimpleGUI as sg
import psycopg2

# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    # Connect to an existing database
    conn = psycopg2.connect("dbname=bookstore user=postgres password=postgres")

    # Open a cursor to perform database operations
    cur = conn.cursor()

    row_names = "isbn, title, publish_date, num_pages, price"
    # Query the database and obtain data as Python objects
    cur.execute(f"SELECT {row_names} FROM books")
    books = cur.fetchall()

    # Make the window
    layout = [
        [sg.Text('Bookstore')],
        [sg.Table(values=books, headings=row_names.split(", "), size=(60, 9))],
        [sg.Button('Exit')]
    ]

    window = sg.Window('Bookstore', layout)

    # Event Loop to process "events" and get the "values" of the inputs
    while True:
        event, values = window.read()
        if event == sg.WIN_CLOSED or event == 'Exit':  # if user closes window or clicks cancel
            break

    window.close()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
