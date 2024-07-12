-- Q1. Who is the senior most employee based on job title?
select * from employee
order by levels DESC

-- Q2. Which countries have the most Invoices?
select
COUNT (invoice_id) as invoice,
billing_country as country
from invoice
group by 2
order by 1 DESC

-- Q3. What are top 3 values of total invoice?
select * from invoice
order by total DESC

-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--     Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
SELECT 
billing_country,
sum (total) as Total
from invoice
GROUP by 1
ORDER by 2 DESC

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--     Write a query that returns the person who has spent the most money.
select 
c.customer_id,
concat (c.first_name,' ', c.last_name) name,
sum (i.total)
from customer AS c
Left JOIN invoice i on c.customer_id = i.customer_id
GROUP by 1
order by 2 DESC

-- Q6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 
SELECT
DISTINCT email,
concat (first_name, ' ', last_name) name
from customer c
LEFT join invoice i on c.customer_id = i.customer_id
LEFT JOIN invoice_line il on i.invoice_id = il.invoice_id
where track_id
	in (SELECT
        track_id from track t
        LEFT join genre g on t.genre_id = g.genre_id
        where g.name LIKE 'rock')
order by 1

-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
--     Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT
a.artist_id,
a.name,
count (t.track_id) Num_Song
from artist a
LEFT JOIN album al on al.artist_id = a.artist_id
LEFT JOIN track t on t.album_id = al.album_id
where genre_id
	in (SELECT 
        genre_id from genre
        WHERE name like 'rock')
GROUP by 1
ORDER by 3 DESC

-- Q8. Return all the track names that have a song length longer than the average song length. 
--     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select
name,
milliseconds
from track
where milliseconds > (select avg (milliseconds) avg_music
                      from track)
group by 1
ORDER by 2 desc

-- note : Kalo didalam WHERE tidak boleh ada fungsi Agregate karena nantinya error.

-- Q9. Find how much amount spent by each customer on artists. Write a query to return the customer name, artist name, and total spent.
WITH best_selling_artist AS 
	(SELECT a.artist_id AS artist_id, 
		a.name AS artist_name, 
		SUM(il.unit_price * il.quantity) AS total_spent
	 FROM invoice_line il
	 JOIN track t ON t.track_id = il.track_id
	 JOIN album al ON al.album_id = t.album_id
	 JOIN artist a ON a.artist_id = al.artist_id
	 GROUP BY 1
	 ORDER BY 3 DESC)
SELECT c.customer_id AS customer_id, 
	concat (c.first_name, ' ', c.last_name) AS name, 
	bsa.artist_name AS artist_name, 
	(SUM(il.unit_price * il.quantity)) AS total_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

-- Q10. We want to find out the most popular music Genre for each country. 
--      We determine the most popular genre as the genre with the highest amount of purchases. 
--      Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
-- Q10. Kami ingin mengetahui Genre musik terpopuler di setiap negara. 
-- Genre terpopuler kami tentukan sebagai genre dengan jumlah pembelian tertinggi. 
-- Tulis kueri yang menampilkan setiap negara beserta Genre teratas. Untuk negara yang jumlah maksimum pembeliannya dibagikan, kembalikan semua Genre.
with genre_popular AS
	(select count (il.quantity) as purchases,
     c.country as country,
     g.name as genre_name,
     row_number()
     over (partition by c.country
           order by COUNT(il.quantity) desc) as row_num
     from
     invoice_line il
     left JOIN invoice i on i.invoice_id = il.invoice_id
     LEFT join customer c on c.customer_id = i.customer_id
     LEFT join track t on t.track_id = il.track_id
     LEFT join genre g on g.genre_id = t.genre_id
     GROUP by 2,3
     order by 1 desc)
select
country,
genre_name,
purchases
from genre_popular
where row_num <= 1
     
-- Q11. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

-- Q11. Tulis kueri yang menentukan pelanggan yang paling banyak mengeluarkan uang untuk musik di setiap negara.
-- Tulis kueri yang menampilkan negara beserta pelanggan teratas dan berapa banyak yang mereka belanjakan. 
-- Untuk negara-negara yang membagi jumlah pembelanjaan tertinggi, cantumkan semua pelanggan yang membelanjakan jumlah ini.
with customer_country AS
	(SELECT
     c.customer_id,
     concat (c.first_name, ' ', c.last_name) name,
     billing_country,
     sum(total) as total_spent,
     row_number ()
     over (partition by billing_country 
           ORDER by sum(total) DESC) row_num
     from invoice i
     LEFT join customer c on c.customer_id = i.customer_id
     group by 1, 2, 3
     order by 4, 5 DESC)
SELECT
	customer_id,
    name,
    billing_country,
    total_spent
from customer_country
WHERE
row_num = 1

-- Q12. Who are the most popular artists?
SELECT
count (il.quantity) purchases,
a.name artist_name
from invoice_line il
LEFT JOIN track t on t.track_id = il.track_id
LEFT join album al on al.album_id = t.album_id
LEFT join artist a on a.artist_id = a.artist_id
group by 2
order by 1 DESC

 -- Q13. Which is the most popular song?
 SELECT
 COUNT (il.quantity) purchases,
 t.name song_name
 from invoice_line il
 LEFT join track t on t.track_id = il.track_id
 group by 2
 ORDER by 1 desc

-- Q14. What are the average prices of different types of music?
WITH purchases AS
	(SELECT g.name AS genre, 
     		SUM(total) AS total_spent
	FROM invoice i
	JOIN invoice_line il ON il.invoice_id = i.invoice_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY 1
	ORDER BY 2)
SELECT genre, 
	   round(avg(total_spent)) AS total_spent
FROM purchases
GROUP BY 1

-- Q15. What are the most popular countries for music purchases?
SELECT
COUNT (il.quantity) purchases,
c.country country
from invoice_line il
LEFT join invoice i on i.invoice_id = il.invoice_id
LEFT join customer c on c.customer_id = i.customer_id
GROUP by 2
order by 1 desc







