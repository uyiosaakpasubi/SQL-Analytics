-- CREATING CONVERSION FUNNELS 
/*
TASK: We need to understand based on previous analysis where we lose GSEARCH
 (google search) visitors between LANDER-1 page and making an order. You need
 to build a full conversion funnel, analyzing how many customers, make it to
 each step. Start with the LANDER-1 page and build the funnel to the THANK YOU 
 page between August 5th and September 5th. We will consider one of the products
 in the product page titled Mr Fuzzy.
 
BACKGROUND:
 Prior to this analysis, we have tested the traffic volumes for all the pages 
 linked to this website and from that information, created a new homepage, LANDER-1,
 to check for the reduction in bouncerate against what was observed on the initial
 homepage. 


For this analysis, we hope to do the following;
1. Figure out what percentage of users go through the different stages of the
	funnel (from LANDER-1 to THANK_YOU) from the data.
2. Identify how many of the users continue on to each next step in the conversion 
	flow.

*/

/*
For the first two steps of the process, we will;
1. Write a query to isolate instances where the various pages that we want to analyze
 were clicked by assigning values of 1 when there is data for a click session or 0 
 when there is no click information.
 2. Create A VIEW or TEMPORARY TABLE with this information by embeding the query as a 
 subquery from which we will extract ONLY situations where there is a value for the page
 click (MAX of values between 0 and 1)
*/
CREATE VIEW lander1_conversion_funnel as 
(SELECT 
    session_id,
    MAX(lander1_page) lander1_clicked,
    MAX(product_page) product_clicked,
    MAX(mrfuzzy_page) mrfuzzy_clicked,
    MAX(cart_page) cart_clicked,
    MAX(shipping_page) shipping_clicked,
    MAX(billing_page) billing_clicked,
    MAX(thankyou_page) thankyou_clicked
FROM
    (SELECT 
        ws.website_session_id session_id,
            wp.pageview_url page_seen,
            DATE(wp.created_at) date_created,
             CASE
                WHEN wp.pageview_url = '/lander-1' THEN 1
                ELSE 0
            END lander1_page,
            CASE
                WHEN wp.pageview_url = '/products' THEN 1
                ELSE 0
            END product_page,
            CASE
                WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END mrfuzzy_page,
            CASE
                WHEN wp.pageview_url = '/cart' THEN 1
                ELSE 0
            END cart_page,
            CASE
                WHEN wp.pageview_url = '/shipping' THEN 1
                ELSE 0
            END shipping_page,
            CASE
                WHEN wp.pageview_url = '/billing' THEN 1
                ELSE 0
            END billing_page,
            CASE
                WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END thankyou_page
    FROM
        website_sessions ws
    LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
    WHERE
        ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
            AND wp.pageview_url IN ('/lander-1' , '/products', '/the-original-mr-fuzzy', '/cart',
            '/shipping', '/billing', '/thank-you-for-your-order')) as case_breakdown
	GROUP BY 1);
 /*
 Next we use a CASE-WHEN function to count the number of active sessions (numbered as 
 1) from the conditions we set in the VIEW, and this will produce the number of sessions
 that went into each page
 */   
SELECT 
    COUNT(DISTINCT session_id) num_of_sessions,
     COUNT(DISTINCT CASE
            WHEN lander1_clicked = 1 THEN session_id
            ELSE NULL
        END) lander1_clicks,
    COUNT(DISTINCT CASE
            WHEN product_clicked = 1 THEN session_id
            ELSE NULL
        END) product_clicks,
	COUNT(DISTINCT CASE
            WHEN mrfuzzy_clicked = 1 THEN session_id
            ELSE NULL
        END) mrfuzzy_clicks,
	COUNT(DISTINCT CASE
            WHEN cart_clicked = 1 THEN session_id
            ELSE NULL
        END) cart_clicks,
	COUNT(DISTINCT CASE
            WHEN shipping_clicked = 1 THEN session_id
            ELSE NULL
        END) shipping_clicks,
	COUNT(DISTINCT CASE
            WHEN billing_clicked = 1 THEN session_id
            ELSE NULL
        END) billing_clicks,
	COUNT(DISTINCT CASE
            WHEN thankyou_clicked = 1 THEN session_id
            ELSE NULL
        END) thankyou_clicks
FROM
    lander1_conversion_funnel;
 
 /*
 Finally we calculate the percentages of the numbers we discovered above to help us
 understand fpr example; what percentage of the clicke that went to the product page
 landed on our sample product page "MR FUZZY"
 */
SELECT 
    COUNT(DISTINCT session_id) num_of_sessions,
    COUNT(DISTINCT CASE
            WHEN lander1_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT session_id) percent_lander1_clicks,
    COUNT(DISTINCT CASE
            WHEN product_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN lander1_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_product_clicks,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_mrfuzzy_clicks,
    COUNT(DISTINCT CASE
            WHEN cart_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN mrfuzzy_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_cart_clicks,
    COUNT(DISTINCT CASE
            WHEN shipping_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN cart_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_shipping_clicks,
    COUNT(DISTINCT CASE
            WHEN billing_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN shipping_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_billing_clicks,
    COUNT(DISTINCT CASE
            WHEN thankyou_clicked = 1 THEN session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN billing_clicked = 1 THEN session_id
            ELSE NULL
        END) percent_thankyou_clicks
FROM
    lander1_conversion_funnel;
    
/*
    RESULTS:
    num_of_sessions - 5714
    percent_lander1_clicks - 0.9162
    percent_product_clicks - 0.5584
    percent_mrfuzzy_clicks - 0.7304
    percent_cart_clicks - 0.4370
    percent_shipping_clicks - 0.6720
    percent_billing_clicks - 0.7815
    percent_thankyou_clicks - 0.4306
*/