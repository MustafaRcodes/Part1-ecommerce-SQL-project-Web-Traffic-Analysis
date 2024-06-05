# ecommerce-SQL-project-Web-Traffic-Analysis-Part-1
Introduction
In this SQL project, I took on the role of an eCommerce Database Analyst for Toy Factory, an online retailer that had just launched its first product. Alongside the CEO, Marketing Manager, and Website Manager of this startup team, I acted as an analyst to help steer business decisions by analyzing marketing channels, measuring website performance, and exploring the product portfolio.

Overview of the database.

<img width="492" alt="image" src="https://github.com/MustafaRcodes/ecommerce-SQL-project-Web-Traffic-Analysis-Part-1/assets/150495517/1ef69b49-4320-470a-8156-9c5949d3da71">


The six most critical and fundamental tables I worked with, though stripped down and simplified, still contained the key data (i.e., website activity, products, orders, and refunds) that an e-commerce database analyst typically handles daily.

Before diving into the project, let's briefly cover some essential web/digital marketing terms:

UTM (Urchin Tracking Module) Tracking Parameters
Businesses running paid marketing campaigns often focus on performance metrics, measuring aspects like spending and conversion rates. Paid traffic is tagged with UTM parameters appended to URLs, which help tie website activity back to specific traffic sources and campaigns.

<img width="506" alt="image" src="https://github.com/MustafaRcodes/ecommerce-SQL-project-Web-Traffic-Analysis-Part-1/assets/150495517/7ecdd360-8b2d-4a74-b494-6d288c250dc1">


In a URL with UTM parameters, the ? indicates that everything following it is for tracking purposes and does not affect the page's destination. The parameter-value pairs (highlighted in yellow) are separated by ampersands (&).

In this database:

UTM Sources: Include gsearch (Google) and bsearch (Bing).
UTM Campaigns: Include nonbrand and brand. The nonbrand group targets product categories like "Teddy Bears" or "Buy Toys Online," while the brand group targets searches specifically for the company, such as  "M Toy Factory."
UTM Contents: Include g_ad_1, g_ad_2, b_ad_1, and b_ad_2, often used to store the name of a specific ad unit being run.
Project Background

The Situation: Toy Factory has been live for approximately 8 months, and the CEO is preparing to present company performance metrics to the board next week. As the analyst, I am tasked with preparing the relevant metrics to showcase the company's promising growth.

The Objective: Use SQL to extract and analyze website traffic and performance data from the Toy Factory database, quantify the company’s growth, and effectively communicate the story of how we have achieved that growth.
