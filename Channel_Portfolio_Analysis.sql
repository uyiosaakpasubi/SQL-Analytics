/*
TASK-1: Pull the weekly trends of GSEARCH nonbrand and compare it to the results of 
BSEARCH nonbrand. The goal here is to identify and compare the weekly trended session
volumes for both search channels, so we can get a sense for which would be more
important for the business. Show trend from August 22 till November 29.
*/

SELECT 
   YEARWEEK(created_at) yrwk,
   MIN(DATE(created_at)) week_trend,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS gsearch_count,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS bsearch_count
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-08-22' AND '2012-11-29'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;


/*
TASK-2: Compare the percentage of traffic coming in from mobile channels for both
GSEARSH and BSEARCH channels 
*/

select * from website_sessions;

SELECT 
    utm_source,
    COUNT(website_session_id) total_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(website_session_id) perct_mobile_sessions
FROM
    website_sessions 
WHERE
    created_at BETWEEN '2012-08-22' AND '2012-11-30'
        AND utm_source IN ('gsearch' , 'bsearch')
GROUP BY 1;



/*
TASK-3: We need to figure out if BSEARCH nonbrand traffic should have the same bids as GSEARCH
nonbrand traffic. Pull nonbrand conversion rates from session to order for both search channels
and classify by device type from August 22 until September 18.
*/

SELECT 
    ws.device_type,
    ws.utm_source,
    COUNT(ws.website_session_id) number_of_sessions,
    COUNT(o.order_id) number_of_orders,
    COUNT(o.order_id)/COUNT(ws.website_session_id) percentage_of_orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at BETWEEN '2012-08-22' AND '2012-09-18'
        AND ws.utm_campaign = 'nonbrand'
GROUP BY 2 , 1
ORDER BY 3;

/*
TASK-4: Analyze organic search, searches that originated from 
directly typing in and paid brand search sessions by month, and show these sessions 
as a percentage of paid search nonbrand sessions.
*/