# SQL-User-Journey-Analysis
An advanced MySQL project extracting and concatenating website user journeys for paying customers to analyze conversion funnels. Built using CTEs, Window Functions, and GROUP_CONCAT.
# Extracting User Journey Data Using SQL

## 📌 Project Overview
[cite_start]The objective of this project is to extract and format data for a subsequent user journey analysis[cite: 5]. [cite_start]The goal was to track the sequence of pages visited by a user leading up to a purchase[cite: 6]. [cite_start]By grouping all pages visited during a session into a single string[cite: 7], analysts and marketing teams can better understand the conversion funnel and user behavior.

[cite_start]This project was completed as part of the 365 Data Science curriculum[cite: 2].

## 🎯 Business Problem
[cite_start]To understand the customer journey, we need to extract the specific sequence of webpage interactions for users who successfully purchased a subscription[cite: 8, 9]. 

The requirements for this data extraction were highly specific:
* [cite_start]Filter for users who made their first purchase in Q1 2023 (January 1 - March 31, 2023, inclusive)[cite: 10, 103].
* [cite_start]Remove test users (records where the purchase price was $0)[cite: 96, 105].
* [cite_start]Exclude any page visits that occurred *after* the purchase timestamp[cite: 94].
* [cite_start]Assign readable aliases to URLs (e.g., replacing `https://365datascience.com/` with `Homepage`) for better readability[cite: 98, 99].
* [cite_start]Combine all visited pages within a session into a single string, separated by a hyphen[cite: 80, 81].

## 🛠️ Tools & SQL Techniques Used
* **Database Management System:** MySQL
* [cite_start]**Advanced SQL Concepts:** * Common Table Expressions (CTEs) for code modularity and readability[cite: 115].
  * Window Functions (`ROW_NUMBER()`) to isolate the chronological first purchase.
  * [cite_start]String Functions (`CONCAT()`, `GROUP_CONCAT()`) to stitch together source/destination URLs and full user journeys[cite: 146, 151].
  * [cite_start]System Variable modification (`SET GLOBAL group_concat_max_len = 100000;`) to prevent string truncation on long sessions[cite: 154, 157].
  * [cite_start]Conditional Logic (`CASE` statements) to map raw URLs to clean aliases[cite: 135].
  * Complex Table Joins across user, visitor, and interaction tables.

## 📊 Data Output
[cite_start]The expected output is a clean CSV file containing four primary columns[cite: 79, 112]:
1. `user_id`: The unique identifier for the customer.
2. `session_id`: The unique identifier for the browsing session.
3. [cite_start]`subscription_type`: Categorized as Monthly, Quarterly, or Annual[cite: 119].
4. [cite_start]`user_journey`: A hyphen-separated string of the chronological page alias sequence[cite: 79, 81].

*Example output format:*
[cite_start]`Homepage-Log in-Log in-Courses-Career tracks-Checkout-Checkout` [cite: 23, 24, 56, 57]

## 💡 Key Learnings & Challenges Overcome
* **Cartesian Explosions / Server Timeouts:** Initially encountered MySQL Error 2013 due to inefficient joins. Optimized the query execution plan by passing `user_id` and `subscription_type` through earlier CTEs, completely eliminating the need for a massive, unoptimized `JOIN` at the final aggregation step.
* [cite_start]**Pre-Purchase Filtering:** Ensured that *only* interactions leading up to the exact timestamp of the first purchase were included, preventing post-purchase browsing from skewing the funnel analysis[cite: 104].
