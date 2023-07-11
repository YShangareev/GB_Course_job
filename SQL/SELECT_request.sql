USE game_shop;

-- Вычислить средний рейтинг игр в магазине по обзорам
-- Вложенные запросы
SELECT game_id, FORMAT(AVG(rating),2) AS avg_rating
FROM game_reviews
WHERE game_id IN (SELECT id_of_game FROM game_market)
GROUP BY game_id
ORDER BY game_id;
-- Join
SELECT game_id, game_name, FORMAT(AVG(rating),2) AS avg_rating
FROM game_reviews gr
JOIN game_market gm
ON gr.game_id = gm.id_of_game
GROUP BY game_id
ORDER BY game_id;

-- Выбрать всех людей у кого есть игры из класса РПГ и посчитать количество этих людей
-- Вложенные запросы
SELECT COUNT(*) AS number_of_people
FROM users
WHERE id IN (SELECT user_id FROM accounts_game WHERE game_id IN (SELECT id_of_game FROM game_market WHERE game_class = 'rpg'));
-- Join
SELECT COUNT(DISTINCT id)
FROM users u
JOIN accounts_game ag
ON u.id = ag.user_id
JOIN game_market gm 
ON ag.game_id = gm.id_of_game
WHERE game_class = 'rpg';

-- Выбрать никнеймы людей, которые имеют предмет с id = 2
-- Вложенные запросы
SELECT nickname FROM accounts
WHERE user_id IN
(SELECT user_id FROM items_users 
WHERE item_id IN
(SELECT id FROM items 
WHERE id IN
(SELECT item_id FROM items_game WHERE game_id = 2)));
-- Join
SELECT nickname FROM
accounts a
JOIN
items_users iu
ON a.user_id = iu.user_id
JOIN items i
ON i.id = iu.item_id
JOIN items_game ig
ON iu.item_id = ig.item_id
WHERE game_id = 2;




