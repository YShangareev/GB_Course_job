USE game_shop;

-- Представление, которое показывает всех пользователей, у когоры нет аутентификации
CREATE OR REPLACE VIEW view_1 AS
SELECT id, email, authentication
FROM users
WHERE authentication = 0
ORDER BY id;
SELECT * FROM view_1;

-- Представление, которое показывает пользователей, у которых есть игры из раздела 'action', а также id этих игр
CREATE OR REPLACE VIEW view_2 AS
SELECT user_id,game_id
FROM accounts_game ag JOIN game_market gm ON ag.game_id = gm.id_of_game
WHERE game_class = 'action'
ORDER BY user_id;
SELECT * FROM view_2;

-- Представление, которое показывает количество предметов различной категории ценностей, которые есть в определенной игре
CREATE OR REPLACE VIEW view_3 AS
SELECT game_id, rare, COUNT(rare) AS number_of_items
FROM items i JOIN items_game ig ON i.id = ig.item_id
GROUP BY game_id,rare
ORDER BY game_id;
SELECT * FROM view_3;