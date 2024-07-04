-- Analyzing Traffic source OR TRAFFIC SOURCE ANALYSIS
-- We use the utm parameters stored in the database to identify paid website sessions
-- From our session data, we link to our order data to undertand how much revenue our paid campaigns are driving.
-- Paid marketing campaigns: UTM Tracking Parameters

-- Website sessions that traffics more volume or orders
SELECT
   utm_content,
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 -- arbitrary
GROUP BY 
   utm_content -- Can also use 1 because the position of above column is 1 after SELECT
ORDER BY COUNT(DISTINCT website_sessions.website_session_id) DESC; -- Can also 2 because the position of above column is 2 after SELECT

-- Checking and calculating conversion rates from each session
SELECT
   utm_content,
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 
GROUP BY 
   utm_content 
ORDER BY COUNT(DISTINCT website_sessions.website_session_id) DESC; 

-- Business problem : CEO would like to understand where the bulk of website sessions are coming from
-- breakdown by UTM source, campaign, and referring domain. 
SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS number_of_sessions
FROM website_sessions
WHERE created_at <= '2012-04-12'
    GROUP BY 
    utm_source,
    utm_campaign,
    http_referer
ORDER BY 
    number_of_sessions DESC;
    
 -- Calculating and analyzing conversion rate from session order, based on wwhat we are paying 
 -- for clicks, need CVR of at least 4% to make number works. if lower, we need to reduce bid 
 -- if higher, we can increase bid to drive more volume.
SELECT
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2012-04-14'
   AND utm_source = 'gsearch'
   AND utm_campaign = 'nonbrand';

-- Bid Optimization & Trend Analysis
-- Using date funstions with GROUP BY and aggregate function like COUNT() and SUM() to show trend.alter
-- We will be using YEAR(), QUARTER(), MONTH(), WEEK(), DATE(), NOW() with GROUP BY

-- Checking number of session by YEAR, WEEK AND week date on which session started in the week
SELECT
    YEAR (created_at),
    WEEK (created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM 
    website_sessions
WHERE YEAR (created_at) = '2015'
    GROUP BY 1,2;
    
-- From orders table checking number of items purchased orders with 1 product and how many orders with 2 product.
-- Pivoting by 1 and 2 ( number of item purchased)
SELECT
    primary_product_id,
    order_id,
    items_purchased,
    COUNT(  DISTINCT CASE WHEN items_purchased = 1 THEN 1 END) AS '1_one_item_purchase',
    COUNT(  DISTINCT CASE WHEN items_purchased = 2 THEN 2 END) AS '2_two_item_purchase'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
   primary_product_id,
    order_id
ORDER BY 
         1,2,3;
-- Another way of writing above code is as per below.
    SELECT
    primary_product_id,
    order_id,
    items_purchased,
  COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS '1_one_item_order',
  COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS '2_two_item_order'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
   primary_product_id,
    order_id,
    items_purchased;
    
-- Checking total count of 1 and 2 product order 
SELECT
    COUNT(CASE WHEN items_purchased = 1 THEN 1 END) AS '1_one_item_purchase',
    COUNT(CASE WHEN items_purchased = 2 THEN 2 END) AS '2_two_item_purchase'
FROM
   orders
   WHERE order_id BETWEEN 31000 AND 32000;
   
-- Checking it by primary product ID 
SELECT
    primary_product_id,
  COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS '1_one_item_order',
  COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS '2_two_item_order'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
      1;
-- Traffic source Trending. Pulling gsearch trended session volume, by week to see if the bid changes have caused volume to drop. 
SELECT 
-- YEAR(created_at) AS year,
-- WEEK(created_at) AS week,
MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <'2012-05-12'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 
      YEAR(created_at),
      WEEK(created_at);
      -- Does look like there is an impact on session volume from April. From 800 range down to in between 500 - 600
      
   -- Bid optimization for paid traffic.
  SELECT
  website_sessions.device_type,
  COUNT( DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT( DISTINCT orders.order_id) AS orders,
  COUNT( DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
  FROM website_sessions
     LEFT JOIN orders
     ON orders.website_session_id = website_sessions.website_session_id
  WHERE website_sessions.created_at <'2012-05-11'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
     1;
   -- Key take away is desktop session are performing way better than mobile due to high conversion rate
   -- Management is going to increase bids on desktop. When bid higher, will rank higher in the auction
   -- This insights should lead to a sales boost.
  
-- pulling weekly trend for both desktop and mobile 
SELECT
  YEAR(website_sessions.created_at) AS year,
  WEEK(website_sessions.created_at) AS weekly,
  MIN(DATE(website_sessions.created_at)) AS Session_start_date,
  website_sessions.device_type,
  COUNT( DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT( DISTINCT orders.order_id) AS orders,
  COUNT( DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
  FROM website_sessions
     LEFT JOIN orders
     ON orders.website_session_id = website_sessions.website_session_id
  WHERE website_sessions.created_at BETWEEN '2012-04-15' AND '2012-05-19'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
    YEAR(website_sessions.created_at),
    WEEK(website_sessions.created_at),
    website_sessions.device_type
ORDER BY
    website_sessions.device_type;
    
-- one hot encoding to check count by week to check device type used for sessions.
SELECT
  MIN(DATE(created_at)) AS week_start_date,
  SUM(   CASE WHEN device_type = 'mobile' THEN 1 ELSE 0 END) AS mob_sessions,
  SUM(   CASE WHEN device_type = 'desktop'THEN 1 ELSE 0 END) AS dtop_sessions
FROM website_sessions
  WHERE  created_at < '2012-06-09' 
AND created_at > '2012-04-15'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);

-- Another way of writing same code.
SELECT
  MIN(DATE(created_at)) AS week_start_date,
  COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id  ELSE NULL END) AS mob_sessions,
  COUNT(DISTINCT CASE WHEN device_type = 'desktop'THEN website_session_id  ELSE NULL END) AS dtop_sessions
FROM website_sessions
  WHERE  created_at < '2012-06-09' 
AND created_at > '2012-04-15'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);
    
-- Looks like mobile has been pretty flat or little down however desktop is looking strong. 
-- Thats really great, bid changes we made based on our previuos conversion analysis. We are in the right direction.
-- Key take away is continue to monitor device level volume and be aware of the impact bid level has 
-- Continue to monitor conversion performance at the device level to optimize spending.

-- ANALYZING WEBSITE PERFORMANCE OR ANALYZING TOP WEBSITE CONTENT 
-- CREATING TEMPORARY TABLES to perform multi-step analyses

SELECT
   pageview_url,
   COUNT(DISTINCT website_pageview_id) AS pageviews
FROM website_pageviews
WHERE website_pageview_id <1000
GROUP BY pageview_url
HAVING COUNT(DISTINCT website_pageview_id) >100
ORDER BY pageviews DESC;
-- Firt create tabel and store it in first_pageview with all website_pageview_id visited first with MIN function 
CREATE TEMPORARY TABLE first_pageview
 SELECT
   website_session_id,
   MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id <1000
GROUP BY website_session_id;

-- Now only with unique value of pageviews or website_pageview_id will use left join and join only same value from new created table first_pageview
SELECT 
   first_pageview.website_session_id,
   website_pageviews.pageview_url AS landing_page
FROM first_pageview
   LEFT JOIN website_pageviews
    ON first_pageview.min_pv_id = website_pageviews.website_pageview_id;

-- Now count all session id by pageview_url and website session ID only consist unique minimum or first time visited ID after above query
SELECT 
   website_pageviews.pageview_url AS landing_page,
   COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
   LEFT JOIN website_pageviews
    ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY 
  website_pageviews.pageview_url;

-- As per the management request pulling most-viewed website page, ranked by session volume.
SELECT 
pageview_url,
COUNT(DISTINCT website_pageview_id) AS Pageview_session_volume
FROM  
  website_pageviews
  WHERE  created_at < '2012-06-09'
GROUP BY 
  pageview_url
ORDER BY 
  COUNT(DISTINCT website_pageview_id) DESC;
  
  -- Top three pageview_url such as home,product page get the bulk of traffic.

-- Now need to look at top entry pages 

SELECT * FROM website_pageviews;

CREATE TEMPORARY TABLE first_pageview_per_session
SELECT 
  website_session_id,
  MIN(website_pageview_id) AS first_pageview
FROM  
  website_pageviews
  WHERE  created_at < '2012-06-12'
GROUP BY 
  website_session_id;

SELECT 
    -- first_pageview_per_session.website_session_id,
    website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pageview_per_session.website_session_id) AS session_hitting
FROM
    first_pageview_per_session
    LEFT JOIN website_pageviews
    ON first_pageview_per_session.first_pageview = website_pageviews.website_pageview_id
GROUP BY
    -- first_pageview_per_session.website_session_id,
    website_pageviews.pageview_url;
  -- next step is analyze landing page performance, for the homepage specificaly
  -- think about whether or not the homepage is the best initial experience for all customers.
  
-- LANDING PAGE PERFORMANCE & A/B TESTING
-- BUSINESS CONTEXT: we would like to see landing page performance for a certain time period
-- Step 1: find the first website_pageview_id for relevant sessions
-- Step 2: identify the landing page of each session
-- Step 3: counting pageviews for each session, to identify "bounces" 
-- Step 4: summarizing total sessions and  bounced sessions, by landing page

-- Finding the minimum website pageviews id associated with each session we care about.
SELECT
   website_pageviews.website_session_id,
   MIN(website_pageviews.website_pageview_id) AS min_pageviews_id
FROM website_pageviews
    INNER JOIN website_sessions
      ON website_sessions.website_session_id = website_pageviews.website_session_id
      AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
     website_pageviews.website_session_id;
     
-- Same query as above, this time we are storing the dataset as a temporary table 

CREATE TEMPORARY TABLE first_pageviews_demo 
SELECT
   website_pageviews.website_session_id,
   MIN(website_pageviews.website_pageview_id) AS min_pageviews_id
FROM website_pageviews
    INNER JOIN website_sessions
      ON website_sessions.website_session_id = website_pageviews.website_session_id
      AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
     website_pageviews.website_session_id;
     
SELECT* FROM first_pageviews_demo;

-- next,we'll bring in the landing page to each session

CREATE TEMPORARY TABLE session_w_landing_page_demo
SELECT
	-- first_pageviews_demo.min_pageviews_id,
    first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
    LEFT JOIN website_pageviews
      ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageviews_id;

SELECT * FROM session_w_landing_page_demo;
      
-- Next we make a table to include a count of pageview per session
-- Then we will limit to bounced sessions and create a temporary table 

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
    session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM 
    session_w_landing_page_demo
LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = session_w_landing_page_demo.website_session_id
GROUP BY 
    session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page
HAVING 
    COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT * FROM first_pageviews_demo;
SELECT * FROM session_w_landing_page_demo;
SELECT * FROM bounced_sessions_only;

SELECT 
    session_w_landing_page_demo.landing_page,
    session_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session_id
FROM session_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
    ON session_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY 
    session_w_landing_page_demo.website_session_id;
    
-- Final output 
  -- we will use the same query we previously ran, and run a count of records,
  -- we will group by landing page, and then we will add a bounce rate column
  
  SELECT 
    session_w_landing_page_demo.landing_page,
    COUNT(session_w_landing_page_demo.website_session_id) AS sessions,
    COUNT(bounced_sessions_only.website_session_id) AS bounced_website_session_id,
    COUNT(bounced_sessions_only.website_session_id)/COUNT(session_w_landing_page_demo.website_session_id) AS bounce_rate
FROM session_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
    ON session_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 
	session_w_landing_page_demo.landing_page
ORDER BY 
    session_w_landing_page_demo.landing_page;
    
-- All of our traffic is landing on the homepage right now. We should check how that landing page is performing 
-- Three number we need to see here, Sessions, Bounced sessions and % of sessions which Bounced/Bounced rate.

CREATE TEMPORARY TABLE first_pageviews
SELECT
   website_session_id,
   MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
   WHERE created_at <'2012-06-14'
GROUP BY 
     website_pageviews.website_session_id;
     
SELECT* FROM first_pageviews;
--  next, we will bring in the landing page, like last time and restrict to home only
-- this is redudant in this case, since all is to the homepage.
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
   first_pageviews.website_session_id,
   website_pageviews.pageview_url AS landing_page
FROM first_pageviews
   LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url ='/home';

-- Then a table to have count of pageviews per session	
-- Then limit is to just bounced_ sessions
CREATE TEMPORARY TABLE bounced_sessions
SELECT
   sessions_w_home_landing_page.website_session_id,
   sessions_w_home_landing_page.landing_page,
   COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
   ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
GROUP BY 
    sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
HAVING 
     COUNT(website_pageviews.website_pageview_id) = 1;

-- we will do this first just to show what's in this query, then we will count them after:

SELECT 
   sessions_w_home_landing_page.website_session_id,
   bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
   LEFT JOIN bounced_sessions
	ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY 
    sessions_w_home_landing_page.website_session_id;
    
-- Final output for assignment_calculating_bounce_rates
SELECT
   COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS total_sessions,
   COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
   COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
 FROM sessions_w_home_landing_page
   LEFT JOIN bounced_sessions
    ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;
    
    -- ANALYSING LANDING PAGE TEST
   -- Step 1: Find out when the new page/lander launched
   -- Step 2: Finding the first website_pageview_id for relevant sessions
   -- Step 3: Indentifying the landing page of each session
   -- Step 4: Counting pageviews for each session, to identify "bounces"
   -- Step 5: Summarizing total sessions and bounced sessions, by landing page
   
   SELECT
     MIN(created_at) AS first_created_at,
     MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url ='/lander-1'
     AND created_at IS NOT NULL;
     
-- first_created_at = '2012-06-19 00:35:54'
-- first_pageview_id = 23504

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
    INNER JOIN website_sessions
      ON website_sessions.website_session_id= website_pageviews.website_session_id
      AND website_sessions.created_at <'2012-07-28' 
      AND website_pageviews.website_pageview_id > 23504
      AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
GROUP BY 
     website_pageviews.website_session_id;
     
-- Next I will bring in the landing page to each session, like last time, but restricting to home or lander-1 this time
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
    LEFT JOIN website_pageviews
     ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

-- then a table to have count of pageviews per session
-- then limit it to just bounced_sessions

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
  nonbrand_test_sessions_w_landing_page.website_session_id,
  nonbrand_test_sessions_w_landing_page.landing_page,
  COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
LEFT JOIN  website_pageviews
   ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY 
   nonbrand_test_sessions_w_landing_page.website_session_id,
   nonbrand_test_sessions_w_landing_page.landing_page
HAVING 
   COUNT(website_pageviews.website_pageview_id) = 1;
   
SELECT 
  nonbrand_test_sessions_w_landing_page.landing_page,
  nonbrand_test_sessions_w_landing_page.website_session_id,
  nonbrand_test_bounced_sessions.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page
  LEFT JOIN nonbrand_test_bounced_sessions
    ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
ORDER BY 
   nonbrand_test_sessions_w_landing_page.website_session_id;
   

SELECT 
  nonbrand_test_sessions_w_landing_page.landing_page,
  COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
  COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page
  LEFT JOIN nonbrand_test_bounced_sessions
    ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY 
   nonbrand_test_sessions_w_landing_page.landing_page;


SELECT 
  nonbrand_test_sessions_w_landing_page.landing_page,
  COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
  COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
  COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounced_rate
FROM nonbrand_test_sessions_w_landing_page
  LEFT JOIN nonbrand_test_bounced_sessions
    ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY 
   nonbrand_test_sessions_w_landing_page.landing_page;
   
-- insights - the custom lander has a lower bounce rate which is great

-- LANDING PAGE TREND ANALYSIS
-- Step 1: finding the first website_pageview_id for relevant sessions
-- Step 2: indentifying the landing page of each session 
-- Step 3: counting pageviews for each session to identify "bounces"
-- Step 4: summarizing by week (bounce rate, sessions to each lander)

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
     LEFT JOIN website_pageviews
       ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-01' -- asked by management 
     AND website_sessions.created_at < '2012-08-31' 
     AND website_sessions.utm_source = 'gsearch'
     AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
     website_sessions.website_session_id;

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at     
SELECT 
    sessions_w_min_pv_id_and_view_count.website_session_id,
	sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
    LEFT JOIN website_pageviews
      ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;
      
SELECT 
    -- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    -- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM 
	sessions_w_counts_lander_and_created_at 
GROUP BY 
    YEARWEEK(session_created_at);
    
 -- Looks like both pages were getting traffic for a while, and then we fully switche over to the custom lander as intended.
 -- And it looks like out overall bounce rate has come down over time
 
 
 -- ANALYZING & TESTING CONVERSION FUNNELS
-- CONVERSION FUNNEL ANALYSIS IS ABOUT UNDERSTANDING AND OPTIMIZING EACH STEP OF USER'S EXPERIENCE ON 
-- THEIR JOURNEY TOWARDS PURCHASING PRODUCT.
-- FROM HOME PAFE TO PRODUCT PAGE TO ADD TO CART TO SALE- CHECKING PAGE FROM CUSTOMER LAND ON AND WHAT PERCENTAGE 
-- OF CUSTOMER MOVE TO THE SECOND PAGE AND THEN WAHT PERCENTAGE GO TO ADD TO CART AND WHAT PERCETAGE WILL COMPLETE PURCAHSE 
-- WILL CHECK HOW MANY CUSTOMER WILL MOVE ON TO THE NEXT STEP.

-- COMMON USE CASES:
-- IDENTIFYING THE MOST COMMON PATHS CUSTOMERS TAKE BEFORE PURCHASING PRODUCT 
-- IDENTIFYING HOW MANY USERS CONTINUE ON TO EACH NEXT STEP IN CONVERSION FLOW, AND HOW MANY USERS 
-- ABANDON AT EACH STEP.
-- OPTIMIZING CRITICAL PAIN POINT WHERE USERS ARE ABANDONING, SO THAT CAN CONVERT MORE USERS AND SELL MORE PRODUCT.

-- USING SUBQUERY

SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   website_pageviews.created_at AS pageview_created_at,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS products_page,
   CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' 
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at;

SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   website_pageviews.created_at AS pageview_created_at,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS products_page
   -- CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   -- CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' 
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at;
    
    
-- Next we will put the previous query inside a subquery ( similar to temporary table)
-- We will group by website_session_id, and take the MAX() of each of the flags
-- This MAX() become a made_it flag for that session, to show the session made it there.

SELECT 
website_session_id,
MAX(product_page) AS product_made_it,
MAX(mrfuzzy_page) AS mrfuzzy_made_it,
MAX(cart_page) AS cart_made_it
FROM (
SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS product_page,
   CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' 
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level

GROUP BY 
    website_session_id;
    
    
-- Another way of getting same result like above we got with subquery
    SELECT
   website_sessions.website_session_id,
   -- website_pageviews.pageview_url,
   -- website_pageviews.created_at AS pageview_created_at,
  MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END) AS products_page,
  MAX(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page,
  MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' 
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
GROUP BY
   website_sessions.website_session_id
   -- website_pageviews.pageview_url,
   -- website_pageviews.created_at
ORDER BY 
    website_sessions.website_session_id;
    -- website_pageviews.created_at
    
SELECT 
    COUNT(website_session_id) AS sessions,
    SUM(product_made_it) / COUNT(website_session_id) AS lander_clickthrough_rate,
    SUM(mrfuzzy_made_it) / SUM(product_made_it) AS product_clickthrough_rate,
    SUM(cart_made_it) / SUM(mrfuzzy_made_it) AS mr_fuzzy_clickthrough_rate
FROM (
    SELECT
        website_session_id,
        MAX(product_page) AS product_made_it,
        MAX(mrfuzzy_page) AS mrfuzzy_made_it,
        MAX(cart_page) AS cart_made_it
    FROM (
        SELECT
            website_sessions.website_session_id,
            CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
            CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
            CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
        FROM website_sessions
        LEFT JOIN website_pageviews
            ON website_sessions.website_session_id = website_pageviews.website_session_id
        WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
    ) AS pageview_level
    GROUP BY website_session_id
) AS session_aggregates;

-- There is another way of writing above code by creating temprarory table 

-- Would like to undertand where we lose our gsearch visitors between the new/ lander-1 page and 
-- placing an order. building full conversion funnel, analyzing how many customers make it to each step.
-- starting with /lander-1 and building the funnelall the way to our thank you page. Using data since August 5th.

-- Step 1: select all pageviews for relevant sessions
-- Step 2: identify each pageview as the specific funnel step
-- Step 3: create the session-level conversion funnel view
-- Step 4: aggregate the data to assess funel performance

SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   -- website_pageviews.created_at AS pageview_created_at,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS products_page,
   CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
   CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
   CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
   CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at >'2012-08-05'
    AND website_sessions.created_at <'2012-09-05'
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at;
    
  SELECT 
     website_session_id,
     MAX(products_page) AS products_made_it,
     MAX(mrfuzzy_page) AS mrfuzzy_page_made_it,
     MAX(cart_page) AS cart_page_made_it,
     MAX(shipping_page) AS shipping_page_made_it,
     MAX(billing_page) AS billing_page_made_it,
     MAX(thankyou_page) AS thankyou_page_made_it
 FROM( 
SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   -- website_pageviews.created_at AS pageview_created_at,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS products_page,
   CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
   CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
   CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
   CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at >'2012-08-05'
    AND website_sessions.created_at <'2012-09-05'
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY website_session_id;

CREATE TEMPORARY TABLE session_level_made_it_flags2
SELECT 
     website_session_id,
     MAX(products_page) AS products_made_it,
     MAX(mrfuzzy_page) AS mrfuzzy_page_made_it,
     MAX(cart_page) AS cart_page_made_it,
     MAX(shipping_page) AS shipping_page_made_it,
     MAX(billing_page) AS billing_page_made_it,
     MAX(thankyou_page) AS thankyou_page_made_it
 FROM( 
SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   -- website_pageviews.created_at AS pageview_created_at,
   CASE WHEN pageview_url = '/products' THEN 1 ELSE 0  END AS products_page,
   CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
   CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
   CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
   CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
   CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
   LEFT JOIN website_pageviews
     ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at >'2012-08-05'
    AND website_sessions.created_at <'2012-09-05'
ORDER BY 
    website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY website_session_id;

SELECT * FROM session_level_made_it_flags2;

-- Final count of each stage of session where customer clicked on website
SELECT 
   COUNT(DISTINCT website_session_id) AS sessions,
   COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
   COUNT(DISTINCT CASE WHEN mrfuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
   COUNT(DISTINCT CASE WHEN cart_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
   COUNT(DISTINCT CASE WHEN shipping_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
   COUNT(DISTINCT CASE WHEN billing_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
   COUNT(DISTINCT CASE WHEN thankyou_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags2;

-- On the basis of count calculating click rates in percentage for each step of shopping from checking product to billing page to thank you page

SELECT 
   COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rate,
   COUNT(DISTINCT CASE WHEN mrfuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_product_click_rate,
   COUNT(DISTINCT CASE WHEN cart_page_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy_click_rate,
   COUNT(DISTINCT CASE WHEN shipping_page_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart_click_rate,
   COUNT(DISTINCT CASE WHEN billing_page_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping_click_rate,
   COUNT(DISTINCT CASE WHEN thankyou_page_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing_click_rate
FROM session_level_made_it_flags2;

-- Looks like we should focus on the lander, Mr.Fuzzy page and the billing page, which have the lowest click.
-- For billing page we need to make customer more comfortable entering their credit card info.
-- We need to check new page soon. 

-- We need to check if we have any imporvement on billing2 page after the implimention of changes 
-- Will compare it with old billing page result

SELECT 
   MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';

SELECT 
   website_pageviews.website_session_id,
   website_pageviews.pageview_url AS billing_version_seen,
   orders.order_id
FROM 
   website_pageviews
   LEFT JOIN orders
        ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2');
    
    -- Final analysis output 
    
    SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS session,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rate
    FROM(
    SELECT 
   website_pageviews.website_session_id,
   website_pageviews.pageview_url AS billing_version_seen,
   orders.order_id
FROM 
   website_pageviews
   LEFT JOIN orders
        ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_sessions_w_orders
GROUP BY 
    billing_version_seen;
    
-- Looks like the new version of the billing page has done much better job converting customers
-- will keep goig with this strategy and roll out to all of our customer right away. Great potential fro revenue increase. 