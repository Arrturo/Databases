-- MySQL Script generated by MySQL Workbench
-- Wed Dec 23 16:26:16 2020
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema jeznacha
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema jeznacha
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `jeznacha` DEFAULT CHARACTER SET utf8 ;
USE `jeznacha` ;

-- -----------------------------------------------------
-- Table `jeznacha`.`autor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`autor` (
  `id_autora` INT NOT NULL AUTO_INCREMENT,
  `imie` VARCHAR(45) NOT NULL,
  `nazwisko` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_autora`),
  UNIQUE INDEX `id_autora_UNIQUE` (`id_autora` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`dzial`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`dzial` (
  `id_dzialu` INT NOT NULL AUTO_INCREMENT,
  `nazwa` VARCHAR(3) NOT NULL,
  PRIMARY KEY (`id_dzialu`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`gatunek`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`gatunek` (
  `id_gatunku` INT NOT NULL AUTO_INCREMENT,
  `gatunek` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_gatunku`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`ksiazka`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`ksiazka` (
  `id_ksiazki` INT NOT NULL AUTO_INCREMENT,
  `tytul` VARCHAR(45) NOT NULL,
  `autor_id_autora` INT NOT NULL,
  `opis` TEXT NULL,
  `wydawnictwo` VARCHAR(45) NOT NULL,
  `ilosc` TINYINT UNSIGNED NULL,
  `rok_wydania` YEAR NOT NULL,
  `dzial_id_dzialu` INT NOT NULL,
  `gatunek_id_gatunku` INT NOT NULL,
  PRIMARY KEY (`id_ksiazki`, `autor_id_autora`),
  INDEX `fk_ksiazka_autor1_idx` (`autor_id_autora` ASC) VISIBLE,
  INDEX `fk_ksiazka_sektor1_idx` (`dzial_id_dzialu` ASC) VISIBLE,
  INDEX `fk_ksiazka_gatunek1_idx` (`gatunek_id_gatunku` ASC) VISIBLE,
  CONSTRAINT `fk_ksiazka_autor1`
    FOREIGN KEY (`autor_id_autora`)
    REFERENCES `jeznacha`.`autor` (`id_autora`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ksiazka_sektor1`
    FOREIGN KEY (`dzial_id_dzialu`)
    REFERENCES `jeznacha`.`dzial` (`id_dzialu`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ksiazka_gatunek1`
    FOREIGN KEY (`gatunek_id_gatunku`)
    REFERENCES `jeznacha`.`gatunek` (`id_gatunku`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`karta_biblioteczna`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`karta_biblioteczna` (
  `id_karty` INT NOT NULL AUTO_INCREMENT,
  `data_zalozenia` DATE NULL,
  `kod` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`id_karty`),
  UNIQUE INDEX `kod_UNIQUE` (`kod` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`czytelnik`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`czytelnik` (
  `id_czytelnika` INT NOT NULL AUTO_INCREMENT,
  `imie` VARCHAR(100) NOT NULL,
  `nazwisko` VARCHAR(100) NOT NULL,
  `data_urodzenia` DATE NOT NULL,
  `miasto` VARCHAR(100) NOT NULL,
  `karta_biblioteczna_id_karty` INT NOT NULL,
  PRIMARY KEY (`id_czytelnika`, `karta_biblioteczna_id_karty`),
  INDEX `fk_pro_czytelnik_pro_karta_biblioteczna1_idx` (`karta_biblioteczna_id_karty` ASC) VISIBLE,
  CONSTRAINT `fk_pro_czytelnik_pro_karta_biblioteczna1`
    FOREIGN KEY (`karta_biblioteczna_id_karty`)
    REFERENCES `jeznacha`.`karta_biblioteczna` (`id_karty`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jeznacha`.`wypozyczenia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jeznacha`.`wypozyczenia` (
  `id_wypozyczenia` INT NOT NULL AUTO_INCREMENT,
  `czytelnik_id_czytelnika` INT NOT NULL,
  `ksiazka_id_ksiazki` INT NOT NULL,
  `data_wypozyczenia` DATE NULL,
  `data_oddania` DATE NULL,
  INDEX `fk_wyporzyczenie_czytelnik1_idx` (`czytelnik_id_czytelnika` ASC) VISIBLE,
  INDEX `fk_wyporzyczenie_ksiazka1_idx` (`ksiazka_id_ksiazki` ASC) VISIBLE,
  PRIMARY KEY (`id_wypozyczenia`),
  CONSTRAINT `fk_wyporzyczenie_czytelnik1`
    FOREIGN KEY (`czytelnik_id_czytelnika`)
    REFERENCES `jeznacha`.`czytelnik` (`id_czytelnika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_wyporzyczenie_ksiazka1`
    FOREIGN KEY (`ksiazka_id_ksiazki`)
    REFERENCES `jeznacha`.`ksiazka` (`id_ksiazki`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;







#Funkcja:
DELIMITER //
CREATE FUNCTION count_wyp_ksiazki()
RETURNS INTEGER
BEGIN
	DECLARE liczba INT;
	SELECT COUNT(*) INTO @liczba FROM wypozyczenia;
	RETURN @liczba;
END//

SELECT count_wyp_ksiazki();

#Procedury
DELIMITER $$
CREATE PROCEDURE wypozyczenie_ksiazek(IN id INT)
BEGIN
	UPDATE ksiazka set ilosc = ilosc-1 where id_ksiazki = id;
END
$$
DELIMITER ;


DELIMITER //
CREATE PROCEDURE zwrot_ksiazki(IN id INT)
BEGIN
	UPDATE wypozyczenia set data_oddania = current_date() where id_wypozyczenia = id;
END
//
DELIMITER ;



#Wyzwalacze
DELIMITER //
CREATE TRIGGER check_ilosc
BEFORE INSERT ON ksiazka
FOR EACH ROW
BEGIN
IF NEW.ilosc < 0
THEN
	SET NEW.ilosc = 0;
END IF;
END
//
DELIMITER ;



DELIMITER &&
CREATE TRIGGER check_ksiazki
AFTER INSERT ON wypozyczenia
FOR EACH ROW
BEGIN
DECLARE a int;
SET a = 0;

IF a in(SELECT ilosc FROM ksiazka WHERE id_ksiazki in(SELECT ksiazka_id_ksiazki from wypozyczenia where ksiazka_id_ksiazki=new.ksiazka_id_ksiazki))
THEN DELETE FROM wypozyczenia where ksiazka_id_ksiazki=new.ksiazka_id_ksiazki;

END IF;
END 
&&
DELIMITER ;

