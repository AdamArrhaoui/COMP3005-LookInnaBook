# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import click
from consolemenu import ConsoleMenu, SelectionMenu
from consolemenu.items import SubmenuItem

test_items: list[str] = ["Hunger gamer", "Hunger gamer 2", "Hunger gamer 3", "Bible 2: Electric bogaloo", "damn son the movie"]
for i in range(5):
    test_items += test_items


@click.command()
@click.option('--name', prompt=True, help="Your name")
def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # main_menu = ConsoleMenu("Main Menu", "Please select an option below")
    # book_menu = SelectionMenu(test_items, "Book List", "Choose da book")
    # main_menu.append_item(SubmenuItem("Go to da submenu", book_menu))
    # main_menu.show()

    import PySimpleGUI as sg
    import psycopg2

    # Connect to an existing database
    conn = psycopg2.connect("dbname=bookstore user=postgres password=postgres")

    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Query the database and obtain data as Python objects
    cur.execute("SELECT * FROM books")
    books = cur.fetchall()

    # Make the window
    layout = [
        [sg.Text('Bookstore')],
        [sg.Listbox(values=books, size=(40, 6))],
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
