/*
Тема курсовой работы выбран онлайн-магазин игр(наподобие Steam, Origins, Uplay и т.д.)
*/


DROP DATABASE IF EXISTS game_shop;
CREATE DATABASE game_shop;
USE game_shop;

/* 
Создаем таблицу пользователей, где у нас будет храниться основная информация, а так же подтвержденный ли пользователь
(поле autentication, в данном поле опечатка, должно быть authentification. Не исправлено, по причине "поломки" дальнейших скриптов).
*/
DROP TABLE IF EXISTS users;
CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	email VARCHAR(100) UNIQUE NOT NULL,
	password_hash VARCHAR(100) UNIQUE,
	authentication BIT DEFAULT b'0',
	country VARCHAR(50),
	INDEX users_firstname_lastname_idx(firstname, lastname));
-- Создаем таблицу аккаунтов, где у нас будет храниться дополнительная информация, такая как: ник пользователя, последняя активность.
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts(
	user_id SERIAL PRIMARY KEY,
	nickname VARCHAR(50) UNIQUE,
	last_activity DATETIME DEFAULT NOW(),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	INDEX accounts_nickname_idx(nickname));
-- Создаем таблицу новостей, где у нас будут храниться новости, которые создали пользователи.
DROP TABLE IF EXISTS news;
CREATE TABLE news(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	create_date DATETIME DEFAULT NOW(),
	body VARCHAR(1000),
	heading VARCHAR(100) UNIQUE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	INDEX news_heading_idx(heading));
-- Создаем таблицу площадки, где можно посмотреть доступные игры. Поле цены будет добавлено в разделе, где будут показаны хранимые процедуры.
DROP TABLE IF EXISTS game_market;
CREATE TABLE game_market(
	id_of_game SERIAL PRIMARY KEY,
	game_name VARCHAR(50) UNIQUE,
	game_class VARCHAR(50),
	INDEX game_market_game_name_idx(game_name)); 
-- Создаем таблицу обзоров на игры.
DROP TABLE IF EXISTS game_reviews;
CREATE TABLE game_reviews(
	id SERIAL PRIMARY KEY,
	game_id BIGINT UNSIGNED NOT NULL,
	reviews VARCHAR(600),
	rating TINYINT UNSIGNED,
	FOREIGN KEY (game_id) REFERENCES game_market(id_of_game) ON UPDATE CASCADE ON DELETE CASCADE);
-- Создаем таблицу-словарь для отображения у каких пользователей какие есть игры.
DROP TABLE IF EXISTS accounts_game;
CREATE TABLE accounts_game(
	user_id BIGINT UNSIGNED NOT NULL,
	game_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (user_id, game_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (game_id) REFERENCES game_market(id_of_game) ON UPDATE CASCADE ON DELETE CASCADE);
-- Создаем таблицу где будет представлено сколько минут провел человек в определенной игре.
DROP TABLE IF EXISTS game_hours;
CREATE TABLE game_hours(
	user_id BIGINT UNSIGNED NOT NULL,
	game_id BIGINT UNSIGNED NOT NULL,
	number_of_hours BIGINT DEFAULT 0,
	PRIMARY KEY (user_id, game_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (game_id) REFERENCES game_market(id_of_game) ON UPDATE CASCADE ON DELETE CASCADE);
-- Создаем таблицу заказов покупателей на определенные лоты(внутриигровые предметы).
DROP TABLE IF EXISTS purchase_requests;
CREATE TABLE purchase_requests(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED,
	create_date DATETIME DEFAULT NOW(),
	items VARCHAR(100),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL);
-- Создаем таблицу лотов(внутриигровые предметы) на продажу.
DROP TABLE IF EXISTS lots_for_sale;
CREATE TABLE lots_for_sale(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED,
	create_date DATETIME DEFAULT NOW(),
	items VARCHAR(100),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL);
-- Создаем таблицу лотов(внутриигровые предметы).
DROP TABLE IF EXISTS items;
CREATE TABLE items(
	id SERIAL PRIMARY KEY,
	rare VARCHAR(20),
	body VARCHAR(600),
	for_sale BIT DEFAULT b'0');
-- Создаем таблицу, где у нас будет показана принадлежность лотов(внутриигровые предметы) к определенной игре.
DROP TABLE IF EXISTS items_game;
CREATE TABLE items_game(
	game_id BIGINT UNSIGNED NOT NULL,
	item_id	BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (game_id,item_id),
	FOREIGN KEY (game_id) REFERENCES game_market(id_of_game) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES items(id) ON UPDATE CASCADE ON DELETE CASCADE);
-- Создаем таблицу лотов(внутриигровые предметы), которые есть у пользователя.
DROP TABLE IF EXISTS items_users;
CREATE TABLE items_users(
	user_id BIGINT UNSIGNED NOT NULL,
	item_id	BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (user_id,item_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES items(id) ON UPDATE CASCADE ON DELETE CASCADE);
	


/*
Для более легкой проверки итоговой курсовой, пренебрег дополнительными идеями, такие как:
Создание "корзины", куда пользователь "кладет" игры для покупки,
Ценниками на игры, лоты,
Балансом у пользователей
*/