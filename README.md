## 📌 Project Overview
The objective of this project is to extract and format data for subsequent user-journey analysis. The goal was to track the sequence of pages a user visited leading up to a purchase. By grouping all pages visited during a session into a single string, analysts and marketing teams can better understand the conversion funnel and user behavior.

This project was completed as part of the 365 Data Science curriculum.

## 🎯 Business Problem
To understand the customer journey, we need to extract the specific sequence of webpage interactions for users who successfully purchased a subscription. 

The requirements for this data extraction were highly specific:
* Filter for users who made their first purchase in Q1 2023 (January 1 - March 31, 2023, inclusive).
* Remove test users (records where the purchase price was $0).
* Exclude any page visits that occurred *after* the purchase timestamp.
* Assign readable aliases to URLs (e.g., replacing `https://365datascience.com/` with `Homepage`) for better readability.
* Combine all visited pages within a session into a single string, separated by a hyphen.

## 🛠️ Tools & SQL Techniques Used
* **Database Management System:** MySQL
* **Advanced SQL Concepts:** * Common Table Expressions (CTEs) for code modularity and readability.
  * Window Functions (`ROW_NUMBER()`) to isolate the chronological first purchase.
  * String Functions (`CONCAT()`, `GROUP_CONCAT()`) to stitch together source/destination URLs and full user journeys.
  * System Variable modification (`SET GLOBAL group_concat_max_len = 100000;`) to prevent string truncation on long sessions.
  * Conditional Logic (`CASE` statements) to map raw URLs to clean aliases.
  * Complex Table Joins across user, visitor, and interaction tables.

## 📊 Data Output
The expected output is a clean CSV file containing four primary columns:
1. `user_id`: The unique identifier for the customer.
2. `session_id`: The unique identifier for the browsing session.
3. `subscription_type`: Categorized as Monthly, Quarterly, or Annual.
4. `user_journey`: A hyphen-separated string of the chronological page alias sequence.

*Example output format:*
`Homepage-Log in-Log in-Courses-Career tracks-Checkout-Checkout` 

## 💡 Key Learnings & Challenges Overcome
* **Cartesian Explosions / Server Timeouts:** Initially encountered MySQL Error 2013 due to inefficient joins. Optimized the query execution plan by passing `user_id` and `subscription_type` through earlier CTEs, completely eliminating the need for a massive, unoptimized `JOIN` at the final aggregation step.
* **Pre-Purchase Filtering:** Ensured that *only* interactions leading up to the exact timestamp of the first purchase were included, preventing post-purchase browsing from skewing the funnel analysis.
