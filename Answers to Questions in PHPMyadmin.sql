/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT *
FROM Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
4 faciliteis do not charge members
SELECT COUNT( * )
FROM Facilities
WHERE membercost =0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost >0
AND (
membercost < ( .2 * monthlymaintenance )
)

facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
(SELECT * FROM Facilities WHERE facid = 1) UNION
(SELECT * FROM Facilities WHERE facid = 5 )

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
(SELECT name, monthlymaintenance, 'expensive' as Monthly_Maintenance FROM Facilities WHERE monthlymaintenance > 100) UNION
(SELECT name, monthlymaintenance, 'cheap' as Monthly_Maintenance FROM Facilities WHERE monthlymaintenance < 100)

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT *
FROM `Members`
ORDER BY `Members`.`joindate` DESC
LIMIT 1

# How is this done without limit?


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT(b.memid), f.name, CONCAT(m.firstname, ' ', m.surname) as Name FROM Bookings b
JOIN Members m 
ON m.memid = b.memid 
JOIN Facilities f ON 
f.facid = b.facid
WHERE (f.facid = 0 OR f.facid = 1) AND (m.memid != 0)
ORDER BY Name



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name AS Facility_Name, 
	CONCAT(m.firstname, ' ', m.surname) as Name, 
	CONCAT(EXTRACT(YEAR_MONTH FROM starttime), EXTRACT(DAY FROM starttime)) AS Booking_Date, 
	CASE WHEN (m.memid = 0) THEN f.guestcost * b.slots
	ELSE f.membercost * b.slots
	END AS Facility_Cost 
	FROM Bookings b
JOIN Members m on m.memid = b.memid 
JOIN Facilities f ON f.facid = b.facid 
HAVING (Facility_Cost > 30) AND (Booking_Date = 20120914) ORDER BY Facility_Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT * FROM (SELECT f.name AS Facility_Name, 
	CONCAT(m.firstname, ' ', m.surname) as Name, 
	CONCAT(EXTRACT(YEAR_MONTH FROM starttime), EXTRACT(DAY FROM starttime)) AS Booking_Date, 
	CASE WHEN (m.memid = 0) THEN f.guestcost * b.slots
	ELSE f.membercost * b.slots
	END AS Facility_Cost 
	FROM Bookings b
JOIN Members m on m.memid = b.memid 
JOIN Facilities f ON f.facid = b.facid 
HAVING (Facility_Cost > 30) AND (Booking_Date = 20120914) ORDER BY Facility_Cost DESC) z


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name, 
SUM(CASE WHEN (m.memid = 0) THEN f.guestcost * b.slots 
ELSE f.membercost * b.slots 
END) as Revenue

FROM Facilities f
JOIN Bookings b ON b.facid = f.facid
JOIN Members m ON m.memid = b.memid 
GROUP BY b.facid
HAVING Revenue < 1000 
ORDER BY Revenue 

[('Table Tennis', 180), ('Snooker Table', 240), ('Pool Table', 270)]

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
q11_query  = "SELECT m.firstname || ' ' || m.surname AS Member, 
m2.firstname || ' ' || m2.surname as Recommended_By 
FROM Members m JOIN Members m2 ON m2.memid = m.recommendedby 
WHERE m.recommendedby > 0 
ORDER BY m.surname"


[('Florence Bader', 'Ponder Stibbons'),
 ('Anne Baker', 'Ponder Stibbons'),
 ('Timothy Baker', 'Jemima Farrell'),
 ('Tim Boothe', 'Tim Rownam'),
 ('Gerald Butters', 'Darren Smith'),
 ('Joan Coplin', 'Timothy Baker'),
 ('Erica Crumpet', 'Tracy Smith'),
 ('Nancy Dare', 'Janice Joplette'),
 ('Matthew Genting', 'Gerald Butters'),
 ('John Hunt', 'Millicent Purview'),
 ('David Jones', 'Janice Joplette'),
 ('Douglas Jones', 'David Jones'),
 ('Janice Joplette', 'Darren Smith'),
 ('Anna Mackenzie', 'Darren Smith'),
 ('Charles Owen', 'Darren Smith'),
 ('David Pinker', 'Jemima Farrell'),
 ('Millicent Purview', 'Tracy Smith'),
 ('Henrietta Rumney', 'Matthew Genting'),
 ('Ramnaresh Sarwin', 'Florence Bader'),
 ('Jack Smith', 'Darren Smith'),
 ('Ponder Stibbons', 'Burton Tracy'),
 ('Henry Worthington-Smyth', 'Tracy Smith')]

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT f.name, COUNT(b.bookid) as Member_Bookings
FROM Bookings b
JOIN Facilities f 
ON f.facid = b.facid 
JOIN Members m
ON b.memid = m.memid 
WHERE b.memid > 0 
GROUP by f.facid 
Tennis Court 1	308
Tennis Court 2	276
Badminton Court	344
Table Tennis	385
Massage Room 1	421
Massage Room 2	27
Squash Court	195
Snooker Table	421
Pool Table	783


/* Q13: Find the facilities usage by month, but not guests */

SELECT Month, Count(Month) as Monthly_Usage, Fac_Name FROM 
(SELECT strftime('%m',b.starttime) as Month, b.facid, f.name as Fac_Name FROM Bookings b 
JOIN Members m 
ON b.memid = m.memid 
JOIN Facilities f
ON f.facid = b.facid 
WHERE b.memid > 0 AND strftime('%m',b.starttime) = '08') As sub
GROUP BY Fac_Name
UNION
SELECT Month, Count(Month) as Monthly_Usage, Fac_Name FROM 
(SELECT strftime('%m',b.starttime) as Month, b.facid, f.name as Fac_Name FROM Bookings b 
JOIN Members m 
ON b.memid = m.memid 
JOIN Facilities f
ON f.facid = b.facid 
WHERE b.memid > 0 AND strftime('%m',b.starttime) = '09') As sub
GROUP BY Fac_Name
UNION 
SELECT Month, Count(Month) as Monthly_Usage, Fac_Name FROM 
(SELECT strftime('%m',b.starttime) as Month, b.facid, f.name as Fac_Name FROM Bookings b 
JOIN Members m 
ON b.memid = m.memid 
JOIN Facilities f
ON f.facid = b.facid 
WHERE b.memid > 0 AND strftime('%m',b.starttime) = '07') As sub
GROUP BY Fac_Name
07	4	Massage Room 2
07	23	Squash Court
07	41	Tennis Court 2
07	48	Table Tennis
07	51	Badminton Court
07	65	Tennis Court 1
07	68	Snooker Table
07	77	Massage Room 1
07	103	Pool Table
08	9	Massage Room 2
08	85	Squash Court
08	109	Tennis Court 2
08	111	Tennis Court 1
08	132	Badminton Court
08	143	Table Tennis
08	153	Massage Room 1
08	154	Snooker Table
08	272	Pool Table
09	14	Massage Room 2
09	87	Squash Court
09	126	Tennis Court 2
09	132	Tennis Court 1
09	161	Badminton Court
09	191	Massage Room 1
09	194	Table Tennis
09	199	Snooker Table
09	408	Pool Table