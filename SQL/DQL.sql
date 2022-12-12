-- Get book titles and author names
SELECT b.title, STRING_AGG(a.fname || ' ' || a.lname, ', '
						   ORDER BY a.lname, a.fname) as authors
FROM Books b
JOIN BookAuthors ba ON ba.isbn = b.isbn
JOIN Authors a ON a.aid = ba.aid
GROUP BY b.title;