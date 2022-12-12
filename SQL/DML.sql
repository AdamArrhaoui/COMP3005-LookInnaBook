-- Clear table
TRUNCATE TABLE BooksInOrders, Orders, BookAuthors, BookGenres, Books, PublisherPhones, Publishers, Authors, Users;
-- Reset sequences
SELECT setval('Publishers_pid_seq', 1, false);
SELECT setval('Authors_aid_seq', 1, false);
SELECT setval('Users_uid_seq', 1, false);
SELECT setval('Orders_oid_seq', 1, false);

-- Add users
INSERT INTO Users (fname, lname, billing_info, shipping_info) VALUES
('Billy', 'Bobson', 'Card num 123456789, 123 Billy Bobson Way', '123 Billy Bobson Way'),
('Timmy', 'Thomphson', 'Card num 313123123, 321 Timmy Thomphson Way', '321 Timmy Thomphson Way');


-- Add publishers
CALL add_publisher('Awesome book group', 1234567893, '597 Rocky Lane, London, UK SW1P 1GV', 'info@awesomebooks.com', ARRAY[6137371111, 1234567890]);
CALL add_publisher('Fantasy Books Inc.', 1234567890, '123 Main Street, New York, NY 10001', 'info@fantasybooks.com', ARRAY[1234567891]);
CALL add_publisher('Adventure Books Ltd.', 1234567891, '456 Park Avenue, London, UK SW1P 1AA', 'info@adventurebooks.co.uk', ARRAY[8271312744]);
CALL add_publisher('Romance Books Co.', 1234567892, '789 Eiffel Tower, Paris, FR 75001', 'info@romancebooks.fr', ARRAY[7271821232, 7278289911]);

-- Add authors
INSERT INTO Authors (fname, lname) VALUES
('J.K.', 'Rowling'),
('George R.R.', 'Martin'),
('Jane', 'Austen'),
('William', 'Shakespeare'),
('Leo', 'Tolstoy'),
('Christopher', 'Paolini');

-- Add books
CALL add_book(1234567890, 2, 'Harry Potter and the Philosopher''s Stone',
    '1997-06-26', 223, 10.99, 0.1, 100, ARRAY[1, 2]);
CALL add_book(1234567891, 2, 'Harry Potter and the Chamber of Secrets', '1998-07-02',
    251, 10.99, 0.1, 100, ARRAY[1]);
CALL add_book(1234567892, 2, 'Harry Potter and the Prisoner of Azkaban', '1999-07-08', 317, 10.99, 0.1, 100, ARRAY [1]);
CALL add_book(1234567893, 3, 'A Game of Thrones', '1996-08-01', 694, 9.99, 0.1, 100, ARRAY [2, 4]);
CALL add_book(2828212312, 1, 'Eragon', '2003-08-26', 509 , 15.99, 0.1, 50, ARRAY[6]);