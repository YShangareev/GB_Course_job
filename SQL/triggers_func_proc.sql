USE game_shop;

-- Функции, которые нам возвращают баланс кошелька пользователя и стоимость игры.
DELIMITER //
DROP FUNCTION IF EXISTS get_money//
CREATE FUNCTION get_money()
RETURNS FLOAT DETERMINISTIC
BEGIN
	RETURN FORMAT((SELECT (RAND() *1000)),2);
END//

DROP FUNCTION IF EXISTS get_price//
CREATE FUNCTION get_price()
RETURNS FLOAT DETERMINISTIC
BEGIN
	RETURN FORMAT((SELECT (10+RAND() *100)),2);
END//
DELIMITER ;

-- Создадим новую таблицу для хранения "кошелька" пользователя.
DROP TABLE IF EXISTS wallets;
CREATE TABLE wallets(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	ballance FLOAT,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE);

-- Создадим триггер, который не позволит нам добавить пользователей, у которых прописан отрицательный баланс.
DELIMITER //

DROP TRIGGER IF EXISTS check_ballance_user//
CREATE TRIGGER check_ballance_user BEFORE INSERT ON wallets
FOR EACH ROW 
BEGIN
	IF NEW.ballance < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'отрицательный баланс';
	END IF;
END//

DELIMITER ;

-- Вставляем пользователей в таблицу wallets и прописываем баланс.
INSERT INTO wallets(user_id, ballance) VALUES (1, get_money()),(2,get_money()),(3,get_money()),(4,get_money()),(5,get_money()),(6,get_money()),(7,get_money()),(8,get_money()),(9,get_money()),(10,get_money());
INSERT INTO wallets(user_id, ballance) VALUES (11, -5);
SELECT user_id, FORMAT(ballance,2) AS ballance FROM wallets;

-- Изменим таблицу со списком игр, добавив колонку цены.
ALTER TABLE game_market ADD COLUMN price FLOAT UNSIGNED DEFAULT 0;

-- При помощи процедуры будем добавлять новые игры(название, класс и цену).
DROP PROCEDURE IF EXISTS add_price_game;
DELIMITER //
CREATE PROCEDURE add_price_game(game_name VARCHAR(50),game_class VARCHAR(20),price FLOAT, OUT error VARCHAR(100))
BEGIN
	
	DECLARE rb BIT DEFAULT 0;
	DECLARE code varchar(100);
	DECLARE text_error varchar(100);

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		SET rb = 1;
		GET stacked DIAGNOSTICS CONDITION 1
		code = RETURNED_SQLSTATE, text_error = MESSAGE_TEXT;
		
	END;

	START TRANSACTION;

	INSERT INTO game_market(game_name,game_class,price)
	VALUES(game_name,game_class, price);

	IF rb THEN
		SET error = CONCAT('Ошибка:', code,';', 'Текст ошибки',':', text_error);
		ROLLBACK;
	ELSE
		SET error = 'Нет ошибок';
		COMMIT;
	END IF;
END//
DELIMITER ;

-- Предварительно очистим колонку цены игр на всякий случай, а также выставим автоинкремент так, чтобы id игр шли по порядку(для красоты).
DELETE FROM game_market WHERE price != 0;
ALTER TABLE game_market AUTO_INCREMENT = 1;
-- Заполняем таблицу новыми играми уже с ценниками.
CALL add_price_game('warcraft', 'strategy', get_price(),@error);
CALL add_price_game('NFS', 'racing', get_price(),@error);
CALL add_price_game('Spider-man', 'action', get_price(),@error);
CALL add_price_game("Assasins's creed", 'action', get_price(),@error);
CALL add_price_game('Dishonored', 'action', get_price(),@error);
CALL add_price_game('StarCraft', 'strategy', get_price(),@error);
-- При следующем добавлении происходит ошибка, так как цена не может быть отрицательной.
CALL add_price_game('ABC', 'strategy', -5,@error);
SELECT @error;
SELECT id_of_game,game_name,game_class,FORMAT(price,2) AS price FROM game_market WHERE price != 0;
-- Возвращаем автоинкремент на место.
ALTER TABLE game_market AUTO_INCREMENT = 0;


