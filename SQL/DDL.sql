DROP TABLE Publishers CASCADE;
DROP TABLE PhoneNumbers;
DROP TABLE Books;

CREATE TABLE Publishers (
    pid SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    bank_account NUMERIC(12, 0) NOT NULL,
    address VARCHAR(150),
    email VARCHAR(100)
);

CREATE TABLE PhoneNumbers (
    pid INT NOT NULL,
    phone_num NUMERIC(10, 0) NOT NULL,
    PRIMARY KEY (pid, phone_num),
    FOREIGN KEY (pid) REFERENCES Publishers(pid)
);

CREATE TABLE Books (
    isbn NUMERIC(10, 0) PRIMARY KEY,
    pid INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(20),
    num_pages INT,
    price NUMERIC(6, 2),
    publisher_cut NUMERIC(4, 3) CHECK(publisher_cut BETWEEN 0 AND 1),
    quantity INT CHECK(quantity >= 0),
    FOREIGN KEY (pid) REFERENCES Publishers(pid)
);
