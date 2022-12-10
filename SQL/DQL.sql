-- Get book titles and author names
SELECT b.title, unnest(ARRAY_AGG(a.fname || ' ' || a.lname)) as authors
FROM Books b
JOIN BookAuthors ba ON ba.isbn = b.isbn
JOIN Authors a ON a.aid = ba.aid
GROUP BY b.title;