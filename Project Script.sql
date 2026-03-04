-- '''''''''''''''''''''''''''''''''''''''''''''''''''
-- ''Extracting User Journey Data Using SQL Project ''
-- '''''''''''''''''''''''''''''''''''''''''''''''''''
USE user_journey_data;

# Assess the student purchases table
SELECT *, date(left(date_purchased,10)) AS purchase_date
FROM student_purchases 
LIMIT 10;

# Assess the front interactions table
SELECT *
FROM front_interactions 
LIMIT 10;


-- Build a Query On User Data to Create Customer Journey Strings
SET GLOBAL group_concat_max_len = 100000;

WITH paid_users AS (
    -- Identify the first purchase date for users paying more than $0
    SELECT 
        user_id,
        date_purchased AS first_purchase_date,
        CASE purchase_type
            WHEN 0 THEN 'Monthly'
            WHEN 1 THEN 'Quarterly'
            WHEN 2 THEN 'Annual'
            ELSE 'Unknown'
        END AS subscription_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date_purchased) AS rn
    FROM student_purchases
    WHERE purchase_price > 0
),

first_purchase_dates AS (
    -- Filter down to users whose first purchase was in Q1 2023
    SELECT 
        user_id, 
        first_purchase_date, 
        subscription_type
    FROM paid_users
    WHERE rn = 1
        AND first_purchase_date >= '2023-01-01' 
        AND first_purchase_date <= '2023-03-31'
),

user_interactions AS (
    -- Pass user details forward and filter out post-purchase interactions immediately
    SELECT 
        fpd.user_id,
        fpd.subscription_type,
        fi.session_id,
        fi.event_date,
        fi.event_source_url,
        fi.event_destination_url
    FROM first_purchase_dates fpd
    JOIN front_visitors fv 
        ON fpd.user_id = fv.user_id
    JOIN front_interactions fi 
        ON fv.visitor_id = fi.visitor_id
    WHERE fi.event_date < fpd.first_purchase_date
),

url_aliases AS (
    -- Map URLs to aliases for the filtered dataset
    SELECT 
        user_id,
        session_id,
        subscription_type,
        event_date,
        CASE
            WHEN event_source_url = 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_source_url LIKE 'https://365datascience.com/checkout/%' AND event_source_url LIKE '%coupon%' THEN 'Coupon'
            WHEN event_source_url LIKE 'https://365datascience.com/checkout/%' THEN 'Checkout'
            WHEN event_source_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_source_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_source_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources center'
            WHEN event_source_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career tracks'
            WHEN event_source_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_source_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_source_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_source_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_source_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
            ELSE 'Other'
        END AS event_source_url2,

        CASE
            WHEN event_destination_url = 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_destination_url LIKE 'https://365datascience.com/checkout/%' AND event_destination_url LIKE '%coupon%' THEN 'Coupon'
            WHEN event_destination_url LIKE 'https://365datascience.com/checkout/%' THEN 'Checkout'
            WHEN event_destination_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_destination_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_destination_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources center'
            WHEN event_destination_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career tracks'
            WHEN event_destination_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_destination_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_destination_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_destination_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_destination_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
            ELSE 'Other'
        END AS event_destination_url2
    FROM user_interactions
),

paid_user_steps AS (
    -- Combine source and destination strings for each step
    SELECT 
        user_id,
        session_id,
        subscription_type,
        event_date,
        CONCAT(event_source_url2, '-', event_destination_url2) AS step
    FROM url_aliases
)

-- Group all steps together per session
SELECT 
    user_id,
    session_id,
    subscription_type,
    GROUP_CONCAT(step ORDER BY event_date SEPARATOR '-') AS user_journey 
FROM paid_user_steps 
GROUP BY user_id, session_id, subscription_type
ORDER BY user_id, session_id;



