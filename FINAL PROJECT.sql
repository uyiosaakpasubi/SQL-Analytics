/* 
	THIS PROJECT WILL ANSWER EIGHT BUSINESS QUESTIONS POSED BY A POTENTIAL BUYER
    OF THE BUSINESS (Mavenmovies Record Store)
	
    BACKGROUND:
    The business has been approached by potential buyers who think it's a good idea,
    but have contracted an analyst to justify why the purchase of this business is
    a good decision.

	NOTE: Each Question will be listed below and the codes can be run seperately
*/

/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 

SELECT 
    CONCAT(s.first_name, ' ', s.last_name) Manager_name,
    a.address street_address,
    a.district,
    city,
    country
FROM
    staff s
        JOIN
    address a ON s.address_id = a.address_id
        JOIN
    city c ON c.city_id = a.city_id
        JOIN
    country cn ON c.country_id = cn.country_id
WHERE
    staff_id IN (SELECT 
            manager_staff_id
        FROM
            store)
        OR a.address_id IN (SELECT 
            address_id
        FROM
            store);


/*
2.	I would like to get a better understanding of all of the inventory that would come along
 with the business. Please pull together a list of each inventory item you have stocked,
 including the store_id number, the inventory_id, the name of the film, the film’s rating
 its rental rate and replacement cost. 
*/

SELECT 
    iv.inventory_id,
    f.title name_of_film,
    f.rating,
    st.store_id,
    f.rental_rate,
    f.replacement_cost
FROM
    film f
        JOIN
    inventory iv ON f.film_id = iv.film_id
        JOIN
    store st ON iv.store_id = st.store_id
ORDER BY 4;


/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level 
overview of your inventory. We would like to know how many inventory items you have with each rating 
at each store. 
*/

SELECT 
    f.rating rating,
    st.store_id store,
    count(iv.inventory_id) number_of_items
FROM
    film f
        JOIN
    inventory iv ON f.film_id = iv.film_id
        JOIN
    store st ON iv.store_id = st.store_id
group by 1,2;


/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 

SELECT 
    c.name Category,
    iv.store_id Store_ID,
    COUNT(f.film_id) Number_of_films,
    ROUND(AVG(f.replacement_cost), 2) 'Average_replacement_cost ($)',
    ROUND(SUM(f.replacement_cost), 2) 'Total_replacement_cost ($)'
FROM
    category c
        JOIN
    film_category fc ON c.category_id = fc.category_id
        JOIN
    film f ON f.film_id = fc.film_id
        JOIN
    inventory iv ON iv.film_id = f.film_id
GROUP BY 1 , 2;


/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) 'Customer Name',
    st.store_id 'Store Patronised',
    CASE
        WHEN c.active = 1 THEN 'active'
        ELSE 'inactive'
    END 'Activity Status',
    CONCAT(a.address,',',' ',ct.city,',',' ',cn.country) Address
FROM
    country cn
        JOIN
    city ct ON cn.country_id = ct.country_id
        JOIN
    address a ON ct.city_id = a.city_id
        JOIN
    customer c ON a.address_id = c.address_id
        JOIN
    store st ON c.store_id = st.store_id
group by 1, 2;


/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) 'Customer Name',
    COUNT(rt.rental_id) 'Lifetime Rentals',
    AVG(p.amount) 'Average Price($)',
    SUM(p.amount) AS 'Total Lifetime Value($)'
FROM
    customer c
        LEFT JOIN
    rental rt ON c.customer_id = rt.customer_id
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY 4 DESC;


/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/

SELECT 
    first_name,
    last_name,
   'advisor' Status,
   'not available' as company_name
FROM
    advisor 
UNION ALL 
SELECT 
    first_name,
    last_name,
    'investor' as Status,
    company_name
FROM
    investor;

/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/

SELECT 
    CASE
        WHEN aw.awards = 'Emmy, Oscar, Tony ' THEN '3 Awards'
        WHEN aw.awards IN ('Emmy, Oscar' , 'Emmy, Tony', 'Tony, Oscar') THEN '2 Awards' /* when aw.awards = emmy, oscar OR aw.awards = Emmy,Tony*/
        ELSE ' 1 Award'
    END AS number_of_awards,
    AVG(CASE
        WHEN aw.actor_id IS NULL THEN 0
        ELSE 1
    END) AS percent_of_film
FROM
    actor_award aw
group by 1;