-- Clear table
TRUNCATE TABLE BooksInOrders, Orders, BookAuthors, BookGenres, Books, PublisherPhones, Publishers, Authors, Users;
-- Reset sequences
SELECT setval('Publishers_pid_seq', 1, false);
SELECT setval('Authors_aid_seq', 1, false);
SELECT setval('Users_uid_seq', 1, false);
SELECT setval('Orders_oid_seq', 1, false);

-- Add publishers
INSERT INTO Publishers (name, bank_account, address, email) VALUES
('Fantasy Books Inc.', 1234567890, '123 Main Street, New York, NY 10001', 'info@fantasybooks.com'),
('Adventure Books Ltd.', 1234567890, '456 Park Avenue, London, UK SW1P 1AA', 'info@adventurebooks.co.uk'),
('Romance Books Co.', 1234567890, '789 Eiffel Tower, Paris, FR 75001', 'info@romancebooks.fr');

-- Add publisher phones
INSERT INTO PublisherPhones (pid, phone_num) VALUES
(1, 1234567890),
(2, 1234567890),
(3, 1234567890);

-- Add authors
INSERT INTO Authors (fname, lname) VALUES
('J.K.', 'Rowling'),
('George R.R.', 'Martin'),
('Jane', 'Austen'),
('William', 'Shakespeare'),
('Leo', 'Tolstoy');

-- Add books
CALL add_book(1234567890, 1, 'Harry Potter and the Philosopher''s Stone',
    '1997-06-26', 223, 10.99, 0.1, 100, ARRAY[1, 2]);

CALL add_book(1234567891, 1, 'Harry Potter and the Chamber of Secrets', '1998-07-02',
    251, 10.99, 0.1, 100, ARRAY[1]);

CALL add_book(1234567892, 1, 'Harry Potter and the Prisoner of Azkaban', '1999-07-08', 317, 10.99, 0.1, 100, ARRAY [1]);

CALL add_book(1234567893, 2, 'A Game of Thrones', '1996-08-01', 694, 9.99, 0.1, 100, ARRAY [2, 4]);