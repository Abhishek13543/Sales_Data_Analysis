



-- 1. Creating database




create database amazon_data;
use amazon_data;





-- 2. Table creation and data insertion having no null values


create Table amazon (
Invoice_id varchar(30) not null,
Branch varchar(5) not null,
City varchar(30) not null,
Customer_type varchar(30) not null,
Gender varchar(10) not null,
product_line varchar(100) not null,
Unit_price decimal(10,2)  not null,
Quantity int not null,
VAT float  not null,
Total decimal(10,2)  not null,
Date date  not null,
Time time  not null,
Payment varchar(50)  not null,
cogs decimal(10,2)  not null,
gross_margin_percentage float  not null,
gross_income decimal(10,2)  not null,
Rating float  not null
);

select * from amazon;
select Product_line from amazon;



-- Feature Eng.
-- 1. Adding new column name timeofday to give insight of sales in the morning,afternoon and evening

Alter table amazon                                                                         # Alter is DDL command
add column time_of_day varchar(50);                                                    # adding new column 'time_of_day'
 
 update amazon                                                # Update is Data manupulation command
 set time_of_day = case                                                     # updating 'time_od_day' column
          when hour(amazon.time) >=0 and hour( amazon.time) <12 then 'Morning'
          when hour(amazon.time)>=12 and hour(amazon.time) <18 then 'Afternoon'
          else 'evening'
end;
  
  
  
  -- 2. Adding new column named dayname that contains the extracted days of the week on which the given transactions took place.
  
  
  
  Alter table amazon
  Add column day_name varchar(50);
  
  
  update amazon
  set day_name = date_format(amazon.date, '%a');              #column 'day_name' updated with date_format method 
                                                                   -- of mysql to get weekday name


-- 3. Add a new column named month_name that contains the extracted months of the year 
       -- on which the given transactions took place.


   Alter table amazon
     Add column month_name varchar(50);                            #new column created 'month_name'
     
     
     update amazon
     set month_name = date_format(amazon.date, '%b');    #month_name column updated to get first three leteers of months
     
   
   
   
									-- B U S I N E S S    Q U E S T I O N S --    
   
   
   
   select * from amazon;
   
   
   
   
   -- 1. What is the count of distinct cities in the dataset?
   
   select count(distinct city) as cities from amazon;
   
   # there are three distinct cities in the dataset.
   
   
   
   -- 2. For each branch, what is the corresponding city?
   
   select distinct branch, city from amazon;
   
   
   -- 3. What is the count of distinct product lines in the dataset?
   
   
   select count(distinct Product_line) as distinct_product_line from amazon ;
   
   # There are six distinct product lines in the dataset.
   
   
-- 4. Which payment method occurs most frequently?
   
   select Payment, count(*) as Payment_count from amazon
   group by payment
   order by Payment_count desc
   limit 1;
   
                 # Ewallet is most frequently used payment method with payment count of 345 
   
   
   
-- 5. Which product line has the highest sales?

select product_line, count(Invoice_id) as sales_count from amazon
group by product_line
order by sales_count desc
limit 1;


                    # fashion accessories is the product line with the highest sales.


 
 
-- 6. How much revenue is generated each month?


select month_name, count(Invoice_id) as monthly_sales_revenue from amazon
group by month_name;



-- 7. In which month did the cost of goods sold reach its peak?

select month_name, sum(cogs) as total_cogs from amazon
group by month_name
order by total_cogs desc
limit 1;

               #  january is the month when cost of goods sold reach its peak.

 


-- 8. Which product line generated the highest revenue?

select product_line, sum(total) as Total_revenue from amazon
group by product_line
order by Total_revenue desc
limit 1;

               # Food and beverages is the product line which generated the highest revenue.



-- 9. In which city was the highest revenue recorded?

select city,payment, count(*), sum(total) as highest_revenue from amazon
group by city, payment
order by highest_revenue desc
;

                    #  NAYPYITAW is the city with the highest revenue recorded. 



-- 10. Which product line incurred the highest Value Added Tax?

select product_line, sum(Vat) as total_vat_amount from amazon
group by product_line
order by total_vat_amount desc
limit 1

             # FOOD and BEVERAGES  is the product line which incurred the highest value added tax.



-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."


select product_line,
case
    when gross_income > (select avg(gross_income) from amazon) then 'Good'
    else 'Bad'
    end as sales_perfo
from amazon;

# As Observed out of all the product line only three product line is considered as bad based on its sales performance 
     -- rest all the product line is considered as good 


-- 12. Identify the branch that exceeded the average number of products sold.

select distinct Branch
from amazon
where Quantity > (select avg(Quantity)  from amazon);

               # All the branch A, B, and C exceeded the average number of product sold.




-- 13.  Which product line is most frequently associated with each gender?

with ranked_product_lines as (
select gender, product_line, count(*) as product_line_count, 
rank() over (partition by gender order by count(*) desc) as rank_number
 from amazon
group by gender, product_line
)
select gender, product_line, product_line_count
from ranked_product_lines
where rank_number =1;


-- (CTE) is used with windows rank function 

# Fashion accessories is assosiated with gender female having productline count of 96 
         -- whereas Health and beauty is assosiated with gender male having productline count of 88.




-- 14. Calculate the average rating for each product line.


select product_line, round(avg(Rating))
 as Avg_Rating from amazon
group by product_line;


-- 15. Count the sales occurrences for each time of day on every weekday.


select day_name, time_of_day, count(*) as Sale_occured from amazon
group by day_name, time_of_day
order by day_name, sale_occured desc;

-- 16. Identify the customer type contributing the highest revenue.

select customer_type, sum(Total) as high_revenue
from amazon
group by customer_type
order by high_revenue desc;

                     # Member contributed highest in the revenue.



-- 17. Determine the city with the highest VAT percentage.

select city, sum(Vat) as high_vat, sum(total) as total_revenue, 
(sum(vat)/sum(total))*100 as vat_percent
from amazon
group by city
order by vat_percent desc;


# to get vat percentage i divided the total vat with the total revenue which 5% and the results have negligible diff. 
          -- in vat percentage  with respect to city 





-- 18. Identify the customer type with the highest VAT payments.

select customer_type, sum(vat) as high_vat from amazon
group by customer_type
order by high_vat desc
limit 1;


                # MEMBER is the customer_type which has paid the highest vat 




-- 19. What is the count of distinct customer types in the dataset?

select count(distinct customer_type) as customer_type_count from amazon;

                # only two types of customers are in the dataset (member and normal customer)



-- 20. What is the count of distinct payment methods in the dataset?

select count(distinct payment) as payment_method_count from amazon;

           # three distinct types of payment methods are in the dataset (Ewallet, cash and Credit card)



-- 21. Which customer type occurs most frequently?

select customer_type, count(*) as most_frequent from amazon
group by customer_type
limit 1 ;


                   # members type customers tends to purchase more frequently.

 

-- 22. Identify the customer type with the highest purchase frequency.

select customer_type, sum(quantity) as high_purchase_frequency from amazon
group by customer_type
order by high_purchase_frequency desc
limit 1;


                 # member type of customers purchases goods more frequently.



-- 23. Determine the predominant gender among customers.

select gender, count(*) as customer_count from amazon
group by gender
order by customer_count desc
limit 1;


                   # females are the predominant gender amongst customers.


-- 24. Examine the distribution of genders within each branch.


select branch, gender, count(gender) as gender_distribution from amazon
group by branch, gender
order by branch, gender_distribution desc; 


# It shows males contributes more in branch A and B whereas females are contributes more in branch C.



-- 25. Identify the time of day when customers provide the most ratings.

select time_of_day, count(rating) as rating_count from amazon
group by time_of_day
order by rating_count desc;

                        # It is clear that most ratings have been provided in Afternnoon.



-- 26. Determine the time of day with the highest customer ratings for each branch.

select branch, time_of_day, count(rating) as rating_count from amazon
group by branch, time_of_day
order by branch;

        # It is clear that for all the branches A, B, C most number of ratings are done in Afternoon.




-- 27. Identify the day of the week with the highest average ratings.

select day_name, avg(rating) as average_rating from amazon
group by day_name
order by average_rating desc
limit 1;

                           # Monday is the day when highest average ratings are recieved.



-- 28. Determine the day of the week with the highest average ratings for each branch

with branch_high_rating as
(select branch, day_name, avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank_number
from amazon
group by branch, day_name)
select branch, day_name, avg_rating
from branch_high_rating
where rank_number = 1; 

# Here common table expression(CTE) is used with windows rank function to get the average rating
    --  for each branch with weekday name. 

# It shows that for branch A and C FRIDAY is the highest average rating day and for branch B monday
      -- is the day when it recieved highest average ratings.
      
      
    
      
                                       -- P R O D U C T    A N A L Y S I S--
      
      
      
# 1. The dataset consists of 6 unique product lines
     	-- out of these 6 product lines FOOD and BEVERAGES incurred the highest Value Added Tax
         
#2.   january is the month when cost of goods sold reach its peak.
       
# 3.  Fashion accessories is assosiated with gender female having productline count of 96 
			-- whereas Health and beauty is assosiated with gender male having productline count of 88.

       
       
       
       
       
										-- S A L E S    A N A L Y S I S --
       
       
        
        
# 1. NAYIPTAW city  generates the highest revenue among all the 3 cities and hence it can be seen that the 
	 -- purchasing power of this city or around this locality is higher than other cities.
            
#2 . MEMBERS type customers contributed the most revenue, this shows that members type customers are more loyal 
	  --  than the normal customers and retention of these members type customers must be done if needed. 
            
# 3. EWALLET is the most frequent used payment method type suggesting preference for the  digital transactions 
		-- for customers as it is convinient for them  to pay.