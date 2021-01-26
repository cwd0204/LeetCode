支出表: Spending

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| spend_date  | date    |
| platform    | enum    | 
| amount      | int     |
+-------------+---------+
这张表记录了用户在一个在线购物网站的支出历史，该在线购物平台同时拥有桌面端（'desktop'）和手机端（'mobile'）的应用程序。
这张表的主键是 (user_id, spend_date, platform)。
平台列 platform 是一种 ENUM ，类型为（'desktop', 'mobile'）。
 

写一段 SQL 来查找每天 仅 使用手机端用户、仅 使用桌面端用户和 同时 使用桌面端和手机端的用户人数和总支出金额。

查询结果格式如下例所示：

Spending table:
+---------+------------+----------+--------+
| user_id | spend_date | platform | amount |
+---------+------------+----------+--------+
| 1       | 2019-07-01 | mobile   | 100    |
| 1       | 2019-07-01 | desktop  | 100    |
| 2       | 2019-07-01 | mobile   | 100    |
| 2       | 2019-07-02 | mobile   | 100    |
| 3       | 2019-07-01 | desktop  | 100    |
| 3       | 2019-07-02 | desktop  | 100    |
+---------+------------+----------+--------+

Result table:
+------------+----------+--------------+-------------+
| spend_date | platform | total_amount | total_users |
+------------+----------+--------------+-------------+
| 2019-07-01 | desktop  | 100          | 1           |
| 2019-07-01 | mobile   | 100          | 1           |
| 2019-07-01 | both     | 200          | 1           |
| 2019-07-02 | desktop  | 100          | 1           |
| 2019-07-02 | mobile   | 100          | 1           |
| 2019-07-02 | both     | 0            | 0           |
+------------+----------+--------------+-------------+ 
在 2019-07-01, 用户1 同时 使用桌面端和手机端购买, 用户2 仅 使用了手机端购买，而用户3 仅 使用了桌面端购买。
在 2019-07-02, 用户2 仅 使用了手机端购买, 用户3 仅 使用了桌面端购买，且没有用户 同时 使用桌面端和手机端购买。

Q1:

SELECT t2.spend_date,
       t2.platform,
       ifnull(sum(t1.amount), 0) AS total_amount,
       ifnull(count(DISTINCT t1.user_id), 0) AS total_users
FROM
  ( SELECT DISTINCT spend_date,
                    "desktop" AS platform
   FROM Spending
   
   UNION 
   
   SELECT DISTINCT spend_date,
                         "mobile" AS platform
   FROM Spending

   UNION 
   
   SELECT DISTINCT spend_date,
                         "both" AS platform
   FROM Spending) AS t2

LEFT JOIN
  ( SELECT spend_date,
           user_id,
           CASE
               WHEN count(*) = 1 THEN platform
               ELSE "both"
           END AS platform,
           sum(amount) AS amount
   FROM Spending
   GROUP BY 1,2,3 ) AS t1 ON t2.spend_date = t1.spend_date AND t2.platform = t1.platform

GROUP BY t2.spend_date,
         t2.platform;
Q3:

WITH t2 AS
  (SELECT DISTINCT spend_date,
                   'desktop' AS platform
   FROM Spending
   UNION SELECT DISTINCT spend_date,
                         'mobile' AS platform
   FROM Spending
   UNION SELECT DISTINCT spend_date,
                         'both' AS platform
   FROM Spending),
     t1 AS
  (SELECT spend_date,
          user_id,
          CASE
              WHEN count(*) = 1 THEN platform
              ELSE 'both'
          END AS platform,
          sum(amount) AS amount
   FROM Spending
   GROUP BY spend_date,
            user_id)
SELECT t2.spend_date,
       t2.platform,
       sum(t1.amount) AS total_amount,
       count(DISTINCT t1.user_id) AS total_users
FROM T2
JOIN t1 ON t2.spend_date = t1.spend_date
AND t2.platform = t1.platform
GROUP BY t2.spend_date,
         t2.platform






Q2:

SELECT t2.spend_date,
       t2.platform,
       ifnull(sum(amount), 0) AS total_amount,
       ifnull(count(DISTINCT user_id), 0) AS total_users
FROM (--1.构造所需的表
      SELECT DISTINCT spend_date,
                      "desktop" AS platform
      FROM Spending
      UNION
      SELECT DISTINCT spend_date,
                      "mobile" AS platform
      FROM Spending
      UNION
      SELECT DISTINCT spend_date,
                      "both" AS platform
      FROM Spending) AS t2
LEFT JOIN (--2.查询每个用户，每个日期，每个平台类型，总金额
           SELECT spend_date,
                  user_id,
                  sum(amount) AS amount,
                  if(count(*)=1,platform,'both') AS platform
           FROM Spending
           GROUP BY spend_date,
                    user_id) AS t1 #3.左连接，并按日期和平台分组 ON t2.spend_date = t1.spend_date
AND t2.platform = t1.platform
GROUP BY t2.spend_date,
         t2.platform