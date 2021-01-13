-- https://drive.google.com/file/d/1QnH5Zs4d5_cxdClbjVAo-GfEgQTBNhEI/view

SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';
    
   
select 
	product_category_name,
	avg(product_description_lenght::float) as tamanho_medio,
	avg(product_description_lenght::float) as min_val,
	avg(product_description_lenght::float) as max_val
from "_tb_products" 
group by product_category_name 

select 
	product_category_name,
	avg(product_name_lenght::float) as tamanho_medio,
	avg(product_name_lenght::float) as min_val,
	avg(product_name_lenght::float) as max_val
from "_tb_products" 
group by product_category_name 


select 
	product_category_name,
	avg(product_description_lenght::float) as tamanho_medio,
	avg(product_description_lenght::float) as min_val,
	avg(product_description_lenght::float) as max_val
from "_tb_products"
where product_description_lenght::float >= 100
group by product_category_name


select 
	product_category_name,
	avg(product_description_lenght::float) as tamanho_medio,
	avg(product_description_lenght::float) as min_val,
	avg(product_description_lenght::float) as max_val
from "_tb_products"
where product_description_lenght::float > 100
group by product_category_name
having avg(product_description_lenght::float) > 500
order by min(product_name_lenght) desc,
         max(product_name_lenght) asc



SELECT t2.customer_state,
       sum(t3.price) AS receita_total_estado,
       sum(t3.price) / count(DISTINCT t1.customer_id) avg_receita_cliente
FROM tb_orders AS t1
LEFT JOIN tb_customers AS t2 ON t1.customer_id = t2.customer_id
LEFT JOIN tb_order_items AS t3 ON t1.order_id = t3.order_id
WHERE t1.order_status = 'delivered'
GROUP BY t2.customer_state


SELECT sum(toi.price),
       ts.seller_state
FROM tb_sellers ts
INNER JOIN tb_order_items toi ON toi.seller_id = ts.seller_id
INNER JOIN tb_orders to2 ON to2.order_id = toi.order_id
WHERE to2.order_status = 'delivered'
GROUP BY ts.seller_state


SELECT avg(tp.product_weight_g),
       ts.seller_state
FROM tb_order_items toi
INNER JOIN tb_products tp ON tp.product_id = toi.product_id
INNER JOIN tb_sellers ts ON ts.seller_id = toi.seller_id
INNER JOIN tb_orders to2 ON to2.order_id = toi.order_id
WHERE to2.order_status = 'delivered'
  AND to2.order_delivered_customer_date BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY ts.seller_state

SELECT t4.seller_state,
       avg(t3.product_weight_g) AS avg_peso_produto
FROM tb_orders AS t1
LEFT JOIN tb_order_items AS t2 ON t1.order_id = t2.order_id
LEFT JOIN tb_products AS t3 ON t2.product_id = t3.product_id
LEFT JOIN tb_sellers AS t4 ON t2.seller_id = t4.seller_id
WHERE t1.order_status = 'delivered'
  AND strftime("%Y", order_approved_at) = '2017'
GROUP BY t4.seller_state







