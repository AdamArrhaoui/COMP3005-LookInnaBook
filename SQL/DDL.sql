DROP TABLE IF EXISTS Publishers CASCADE;
DROP TABLE IF EXISTS PublisherPhones CASCADE;
DROP TABLE IF EXISTS Books CASCADE;
DROP TABLE IF EXISTS BookGenres CASCADE;
DROP TABLE IF EXISTS Authors CASCADE;
DROP TABLE IF EXISTS BookAuthors CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS BooksInOrders CASCADE;

DROP TYPE IF EXISTS genre;
DROP TYPE IF EXISTS status;


CREATE TYPE genre AS ENUM (
    'Fantasy',
    'Adventure',
    'Romance',
    'Contemporary',
    'Dystopian',
    'Mystery',
    'Horror',
    'Thriller',
    'Paranormal',
    'Historical Fiction',
    'Science Fiction',
    'Children’s',
    'Memoir',
    'Cookbook',
    'Art',
    'Self-help',
    'Health',
    'History',
    'Travel',
    'Guide',
    'Relationships',
    'Humor'
);

CREATE TYPE status AS ENUM ('Pending Payment', 'Pending Shipment', 'Shipped', 'Delivered');


CREATE TABLE Publishers (
    pid SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    bank_account NUMERIC(12, 0) NOT NULL,
    address VARCHAR(150),
    email VARCHAR(100)
);

CREATE TABLE PublisherPhones (
    pid INT NOT NULL,
    phone_num NUMERIC(10, 0) NOT NULL,
    PRIMARY KEY (pid, phone_num),
    FOREIGN KEY (pid) REFERENCES Publishers(pid)
);

CREATE TABLE Books (
    isbn NUMERIC(10, 0) PRIMARY KEY,
    pid INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    publish_date DATE NOT NULL DEFAULT CURRENT_DATE,
    num_pages INT,
    price NUMERIC(6, 2),
    publisher_cut NUMERIC(4, 3) CHECK(publisher_cut BETWEEN 0 AND 1),
    stock_num INT CHECK(stock_num >= 0),
    FOREIGN KEY (pid) REFERENCES Publishers(pid)
);

CREATE TABLE BookGenres (
    isbn NUMERIC(10, 0) NOT NULL,
    book_genre genre NOT NULL,
    PRIMARY KEY (isbn, book_genre),
    FOREIGN KEY (isbn) REFERENCES Books(isbn)
);

CREATE TABLE Authors (
    aid SERIAL PRIMARY KEY,
    fname VARCHAR(30) NOT NULL,
    lname VARCHAR(30) NOT NULL
);

CREATE TABLE BookAuthors (
  isbn NUMERIC(10, 0) NOT NULL,
  aid INT NOT NULL,
  PRIMARY KEY (isbn, aid),
  FOREIGN KEY (isbn) REFERENCES Books(isbn),
  FOREIGN KEY (aid) REFERENCES Authors(aid)
);

CREATE TABLE Users (
    uid SERIAL PRIMARY KEY,
    fname VARCHAR(30) NOT NULL,
    lname VARCHAR(30),
    billing_info VARCHAR(200),
    shipping_info VARCHAR(150)
);

CREATE TABLE Orders (
    oid SERIAL PRIMARY KEY,
    uid INT,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    billing_info VARCHAR(200) NOT NULL,
    shipping_info VARCHAR(150) NOT NULL,
    order_status status NOT NULL,
    tracking_number CHAR(20),
    FOREIGN KEY (uid) REFERENCES Users(uid)
);

CREATE TABLE BooksInOrders (
    isbn NUMERIC(10, 0) NOT NULL,
    oid INT NOT NULL,
    quantity INT NOT NULL CHECK ( quantity > 0 ),
    PRIMARY KEY (isbn, oid),
    FOREIGN KEY (isbn) REFERENCES Books(isbn),
    FOREIGN KEY (oid) REFERENCES Orders(oid)
);



DROP PROCEDURE IF EXISTS add_publisher;
CREATE PROCEDURE add_publisher (
    name VARCHAR(50),
    bank_account NUMERIC(12, 0),
    address VARCHAR(150),
    email VARCHAR(100),
    phone_numbers NUMERIC(10, 0)[]
)
AS $$
BEGIN
    WITH inserted_pid AS (
        INSERT INTO Publishers (name, bank_account, address, email)
            VALUES (name, bank_account, address, email)
            RETURNING pid
    )
    INSERT INTO PublisherPhones (pid, phone_num)
    SELECT pid, phone_num
    FROM unnest(phone_numbers) as phone_num, inserted_pid as pid;
END;
$$ LANGUAGE plpgsql;


DROP PROCEDURE IF EXISTS add_book;
CREATE PROCEDURE add_book (
    IN isbn NUMERIC(10, 0),
    IN pid INT,
    IN title VARCHAR(100),
    IN publish_date DATE,
    IN num_pages INT,
    IN price NUMERIC(6, 2),
    IN publisher_cut NUMERIC(4, 3),
    IN stock_num INT,
    IN author_ids INT[]
)
AS $$
BEGIN
    -- Add the book to the Books table
    INSERT INTO Books (isbn, pid, title, publish_date, num_pages, price, publisher_cut, stock_num)
    VALUES (isbn, pid, title, publish_date, num_pages, price, publisher_cut, stock_num);

    -- Add the author IDs as authors of the book in the BookAuthors table
    INSERT INTO BookAuthors (isbn, aid)
    SELECT isbn, aid
    FROM unnest(author_ids) as aid;
END;
$$ LANGUAGE plpgsql;


DROP PROCEDURE IF EXISTS add_author_to_book;
CREATE PROCEDURE add_author_to_book (
    IN isbn NUMERIC(10, 0),
    IN aid INT
)
AS $$
BEGIN
    -- Add the author to the book
    INSERT INTO BookAuthors (isbn, aid)
    VALUES (isbn, aid);
END;
$$ LANGUAGE plpgsql;



DROP VIEW IF EXISTS BookAuthorNames;
CREATE VIEW BookAuthorNames AS (
	SELECT b.isbn, STRING_AGG(a.fname || ' ' || a.lname, ', '
							   ORDER BY a.lname, a.fname) as authors
	FROM Books b
	NATURAL JOIN BookAuthors ba
	NATURAL JOIN Authors a
	GROUP BY b.isbn
);