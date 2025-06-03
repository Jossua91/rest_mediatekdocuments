-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mar. 03 juin 2025 à 13:24
-- Version du serveur : 8.3.0
-- Version de PHP : 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mediatek86`
--
CREATE DATABASE IF NOT EXISTS `mediatek86` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `mediatek86`;

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `insertAbonnement`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertAbonnement` (IN `p_id` VARCHAR(5), IN `p_dateCommande` DATE, IN `p_montant` DOUBLE, IN `p_dateFinAbonnement` DATE, IN `p_idRevue` VARCHAR(10))   BEGIN
DECLARE exit handler for SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
    END; 
START TRANSACTION;
INSERT INTO commande (id, dateCommande, montant) VALUES (p_id, p_dateCommande, p_montant);
INSERT INTO abonnement (id, dateFinAbonnement, idRevue) VALUES (p_id, p_dateFinAbonnement, p_idRevue);
COMMIT;
END$$

DROP PROCEDURE IF EXISTS `InsertCommandeDocument`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCommandeDocument` (IN `p_id` VARCHAR(5), IN `p_dateCommande` DATE, IN `p_montant` DOUBLE, IN `p_nbExemplaire` INT, IN `p_idLivreDvd` VARCHAR(10), IN `p_idSuivi` VARCHAR(5), OUT `p_success` BOOLEAN)   BEGIN 
	-- gestion erreur
    DECLARE exit handler for SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_success = FALSE; 
    END; 
 
    START TRANSACTION; 
 
    INSERT INTO commande (id, dateCommande, montant) 
    VALUES (p_id, p_dateCommande, p_montant); 
 
    INSERT INTO commandedocument (id, nbExemplaire, idLivreDvd, idSuivi) 
    VALUES (p_id, p_nbExemplaire, p_idLivreDvd, p_idSuivi); 
 
    COMMIT; 
    SET p_success = TRUE; 
END$$

DROP PROCEDURE IF EXISTS `updateCommandeDocument`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCommandeDocument` (IN `p_id` VARCHAR(5), IN `p_dateCommande` DATE, IN `p_nbExemplaire` INT, IN `p_montant` DOUBLE, IN `p_idSuivi` VARCHAR(5))   BEGIN
    START TRANSACTION;
    
    UPDATE commande 
    SET dateCommande = p_dateCommande, montant = p_montant 
    WHERE id = p_id COLLATE utf8mb4_0900_ai_ci;
    
    UPDATE commandedocument 
    SET nbExemplaire = p_nbExemplaire, idSuivi = p_idSuivi 
    WHERE id = p_id COLLATE utf8mb4_0900_ai_ci;
    
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `abonnement`
--

DROP TABLE IF EXISTS `abonnement`;
CREATE TABLE IF NOT EXISTS `abonnement` (
  `id` varchar(5) NOT NULL,
  `dateFinAbonnement` date DEFAULT NULL,
  `idRevue` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRevue` (`idRevue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `abonnement`
--

INSERT INTO `abonnement` (`id`, `dateFinAbonnement`, `idRevue`) VALUES
('00007', '2026-03-17', '10001'),
('00010', '2025-03-23', '10001'),
('00012', '2025-05-25', '10001'),
('00013', '2025-04-15', '10002'),
('00014', '2025-04-10', '10002'),
('00018', '2026-04-11', '10003'),
('00020', '2025-05-14', '10001');

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `id` varchar(5) NOT NULL,
  `dateCommande` date DEFAULT NULL,
  `montant` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`id`, `dateCommande`, `montant`) VALUES
('00001', '2025-03-06', 10),
('00002', '2025-03-03', 5),
('00003', '2025-03-07', 7.5),
('00004', '2025-03-10', 15),
('00005', '2025-03-03', 30),
('00006', '2025-03-11', 16),
('00007', '2025-03-17', 80),
('00010', '2025-03-17', 50),
('00011', '2025-03-24', 10),
('00012', '2025-03-24', 160),
('00013', '2025-03-24', 60),
('00014', '2025-03-24', 50),
('00015', '2025-04-10', 15),
('00016', '2025-04-11', 50),
('00017', '2025-04-11', 50),
('00018', '2025-04-11', 180),
('00019', '2025-04-11', 100),
('00020', '2025-04-15', 60),
('00021', '2025-04-15', 5),
('00022', '2025-05-26', 11);

--
-- Déclencheurs `commande`
--
DROP TRIGGER IF EXISTS `deleteCommande`;
DELIMITER $$
CREATE TRIGGER `deleteCommande` BEFORE DELETE ON `commande` FOR EACH ROW BEGIN
    DELETE FROM commandedocument WHERE id = OLD.id;
    DELETE FROM abonnement WHERE id = OLD.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `commandedocument`
--

DROP TABLE IF EXISTS `commandedocument`;
CREATE TABLE IF NOT EXISTS `commandedocument` (
  `id` varchar(5) NOT NULL,
  `nbExemplaire` int DEFAULT NULL,
  `idLivreDvd` varchar(10) NOT NULL,
  `idSuivi` varchar(5) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idLivreDvd` (`idLivreDvd`),
  KEY `fk_id_suivi` (`idSuivi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `commandedocument`
--

INSERT INTO `commandedocument` (`id`, `nbExemplaire`, `idLivreDvd`, `idSuivi`) VALUES
('00001', 2, '00001', '00002'),
('00002', 1, '00001', '00002'),
('00003', 1, '20001', '00004'),
('00004', 2, '20001', '00001'),
('00005', 4, '20001', '00002'),
('00006', 2, '20002', '00002'),
('00011', 2, '00001', '00001'),
('00015', 4, '00001', '00003'),
('00016', 2, '00002', '00001'),
('00021', 2, '00001', '00001'),
('00022', 1, '00017', '00003');

--
-- Déclencheurs `commandedocument`
--
DROP TRIGGER IF EXISTS `UpdateNouveauxExemplaires`;
DELIMITER $$
CREATE TRIGGER `UpdateNouveauxExemplaires` AFTER UPDATE ON `commandedocument` FOR EACH ROW BEGIN
    DECLARE v_NbExemplairesAjoutes INT;
    DECLARE v_DateAchat DATE;
    DECLARE v_NumeroMaxExemplaireDocument INT;
    
    IF NEW.idSuivi = '00002' AND OLD.idSuivi != '00002' THEN
        SET v_NbExemplairesAjoutes = NEW.nbExemplaire;
        SET v_DateAchat = (SELECT dateCommande FROM commande WHERE id = NEW.id);
        
        WHILE v_NbExemplairesAjoutes > 0 DO
            SET v_NumeroMaxExemplaireDocument = (SELECT IFNULL(MAX(numero), 0) FROM exemplaire WHERE id = NEW.idLivreDvd);
            INSERT INTO exemplaire (id, numero, dateAchat, photo, idEtat) 
            VALUES (NEW.idLivreDvd, v_NumeroMaxExemplaireDocument + 1, v_DateAchat, '', '00001');
            SET v_NbExemplairesAjoutes = v_NbExemplairesAjoutes - 1;
        END WHILE;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `document`
--

DROP TABLE IF EXISTS `document`;
CREATE TABLE IF NOT EXISTS `document` (
  `id` varchar(10) NOT NULL,
  `titre` varchar(60) DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  `idRayon` varchar(5) NOT NULL,
  `idPublic` varchar(5) NOT NULL,
  `idGenre` varchar(5) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRayon` (`idRayon`),
  KEY `idPublic` (`idPublic`),
  KEY `idGenre` (`idGenre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `document`
--

INSERT INTO `document` (`id`, `titre`, `image`, `idRayon`, `idPublic`, `idGenre`) VALUES
('00001', 'Quand sort la recluse', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'LV003', '00002', '10014'),
('00002', 'Un pays à l\'aube', '', 'LV001', '00002', '10004'),
('00003', 'Et je danse aussi', '', 'LV002', '00003', '10013'),
('00004', 'L\'armée furieuse', '', 'LV003', '00002', '10014'),
('00005', 'Les anonymes', '', 'LV001', '00002', '10014'),
('00006', 'La marque jaune', '', 'BD001', '00003', '10001'),
('00007', 'Dans les coulisses du musée', '', 'LV001', '00003', '10006'),
('00008', 'Histoire du juif errant', '', 'LV002', '00002', '10006'),
('00009', 'Pars vite et reviens tard', '', 'LV003', '00002', '10014'),
('00010', 'Le vestibule des causes perdues', '', 'LV001', '00002', '10006'),
('00011', 'L\'île des oubliés', '', 'LV002', '00003', '10006'),
('00012', 'La souris bleue', '', 'LV002', '00003', '10006'),
('00013', 'Sacré Pêre Noël', '', 'JN001', '00001', '10001'),
('00014', 'Mauvaise étoile', '', 'LV003', '00003', '10014'),
('00015', 'La confrérie des téméraires', '', 'JN002', '00004', '10014'),
('00016', 'Le butin du requin', '', 'JN002', '00004', '10014'),
('00017', 'Catastrophes au Brésil', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'JN002', '00004', '10014'),
('00018', 'Le Routard - Maroc', '', 'DV005', '00003', '10011'),
('00019', 'Guide Vert - Iles Canaries', '', 'DV005', '00003', '10011'),
('00020', 'Guide Vert - Irlande', '', 'DV005', '00003', '10011'),
('00021', 'Les déferlantes', '', 'LV002', '00002', '10006'),
('00022', 'Une part de Ciel', '', 'LV002', '00002', '10006'),
('00023', 'Le secret du janissaire', '', 'BD001', '00002', '10001'),
('00024', 'Pavillon noir', '', 'BD001', '00002', '10001'),
('00025', 'L\'archipel du danger', '', 'BD001', '00002', '10001'),
('00026', 'La planète des singes', '', 'LV002', '00003', '10002'),
('10001', 'Arts Magazine', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'PR002', '00002', '10016'),
('10002', 'Alternatives Economiques', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'PR002', '00002', '10015'),
('10003', 'Challenges', '', 'PR002', '00002', '10015'),
('10004', 'Rock and Folk', '', 'PR002', '00002', '10016'),
('10005', 'Les Echos', '', 'PR001', '00002', '10015'),
('10006', 'Le Monde', '', 'PR001', '00002', '10018'),
('10007', 'Telerama', '', 'PR002', '00002', '10016'),
('10008', 'L\'Obs', '', 'PR002', '00002', '10018'),
('10009', 'L\'Equipe', '', 'PR001', '00002', '10017'),
('10010', 'L\'Equipe Magazine', '', 'PR002', '00002', '10017'),
('10011', 'Geo', '', 'PR002', '00003', '10016'),
('20001', 'Star Wars 5 L\'empire contre attaque', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'DF001', '00003', '10002'),
('20002', 'Le seigneur des anneaux : la communauté de l\'anneau', '', 'DF001', '00003', '10019'),
('20003', 'Jurassic Park', 'https://img-mediatekdocuments.jossua-creuzet.fr/quandSortLaRecluse.jpg', 'DF001', '00003', '10002'),
('20004', 'Matrix', '', 'DF001', '00003', '10002');

-- --------------------------------------------------------

--
-- Structure de la table `dvd`
--

DROP TABLE IF EXISTS `dvd`;
CREATE TABLE IF NOT EXISTS `dvd` (
  `id` varchar(10) NOT NULL,
  `synopsis` text,
  `realisateur` varchar(20) DEFAULT NULL,
  `duree` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `dvd`
--

INSERT INTO `dvd` (`id`, `synopsis`, `realisateur`, `duree`) VALUES
('20001', 'Luc est entraîné par Yoda pendant que Han et Leia tentent de se cacher dans la cité des nuages.', 'George Lucas', 124),
('20002', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 228),
('20003', 'Un milliardaire et des généticiens créent des dinosaures à partir de clonage.', 'Steven Spielberg', 128),
('20004', 'Un informaticien réalise que le monde dans lequel il vit est une simulation gérée par des machines.', 'Les Wachowski', 136);

-- --------------------------------------------------------

--
-- Structure de la table `etat`
--

DROP TABLE IF EXISTS `etat`;
CREATE TABLE IF NOT EXISTS `etat` (
  `id` char(5) NOT NULL,
  `libelle` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `etat`
--

INSERT INTO `etat` (`id`, `libelle`) VALUES
('00001', 'neuf'),
('00002', 'usagé'),
('00003', 'détérioré'),
('00004', 'inutilisable');

-- --------------------------------------------------------

--
-- Structure de la table `exemplaire`
--

DROP TABLE IF EXISTS `exemplaire`;
CREATE TABLE IF NOT EXISTS `exemplaire` (
  `id` varchar(10) NOT NULL,
  `numero` int NOT NULL,
  `dateAchat` date DEFAULT NULL,
  `photo` varchar(500) NOT NULL,
  `idEtat` char(5) NOT NULL,
  PRIMARY KEY (`id`,`numero`),
  KEY `idEtat` (`idEtat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `exemplaire`
--

INSERT INTO `exemplaire` (`id`, `numero`, `dateAchat`, `photo`, `idEtat`) VALUES
('00001', 1, '2025-03-06', '', '00001'),
('00001', 2, '2025-03-06', '', '00001'),
('00001', 3, '2025-03-03', '', '00001'),
('00001', 4, '2025-04-10', '', '00001'),
('00001', 5, '2025-04-10', '', '00001'),
('00001', 6, '2025-04-10', '', '00001'),
('00017', 1, '2025-05-26', '', '00001'),
('10001', 1, '2025-03-19', '', '00001'),
('10001', 2, '2025-04-11', '', '00001'),
('10002', 413, '2025-04-15', 'C:\\img\\parution\\altereco413.jpg', '00001'),
('10002', 418, '2021-12-01', 'C:\\img\\parution\\altereco418.jpeg', '00001'),
('10007', 3237, '2021-11-23', '', '00001'),
('10007', 3238, '2021-11-30', '', '00001'),
('10007', 3239, '2021-12-07', '', '00001'),
('10007', 3240, '2021-12-21', '', '00001'),
('10011', 505, '2022-10-16', '', '00001'),
('10011', 506, '2021-04-01', '', '00001'),
('10011', 507, '2021-05-03', '', '00001'),
('10011', 508, '2021-06-05', '', '00001'),
('10011', 509, '2021-07-01', '', '00001'),
('10011', 510, '2021-08-04', '', '00001'),
('10011', 511, '2021-09-01', '', '00001'),
('10011', 512, '2021-10-06', '', '00001'),
('10011', 513, '2021-11-01', '', '00001'),
('10011', 514, '2021-12-01', '', '00001'),
('20001', 1, '2025-03-03', '', '00001'),
('20001', 2, '2025-03-03', '', '00001'),
('20001', 3, '2025-03-03', '', '00001'),
('20001', 4, '2025-03-03', '', '00001'),
('20002', 1, '2025-03-11', '', '00001'),
('20002', 2, '2025-03-11', '', '00001');

-- --------------------------------------------------------

--
-- Structure de la table `genre`
--

DROP TABLE IF EXISTS `genre`;
CREATE TABLE IF NOT EXISTS `genre` (
  `id` varchar(5) NOT NULL,
  `libelle` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `genre`
--

INSERT INTO `genre` (`id`, `libelle`) VALUES
('10000', 'Humour'),
('10001', 'Bande dessinée'),
('10002', 'Science Fiction'),
('10003', 'Biographie'),
('10004', 'Historique'),
('10006', 'Roman'),
('10007', 'Aventures'),
('10008', 'Essai'),
('10009', 'Documentaire'),
('10010', 'Technique'),
('10011', 'Voyages'),
('10012', 'Drame'),
('10013', 'Comédie'),
('10014', 'Policier'),
('10015', 'Presse Economique'),
('10016', 'Presse Culturelle'),
('10017', 'Presse sportive'),
('10018', 'Actualités'),
('10019', 'Fantazy');

-- --------------------------------------------------------

--
-- Structure de la table `livre`
--

DROP TABLE IF EXISTS `livre`;
CREATE TABLE IF NOT EXISTS `livre` (
  `id` varchar(10) NOT NULL,
  `ISBN` varchar(13) DEFAULT NULL,
  `auteur` varchar(20) DEFAULT NULL,
  `collection` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `livre`
--

INSERT INTO `livre` (`id`, `ISBN`, `auteur`, `collection`) VALUES
('00001', '1234569877896', 'Fred Vargas', 'Commissaire Adamsberg'),
('00002', '1236547896541', 'Dennis Lehanne', ''),
('00003', '6541236987410', 'Anne-Laure Bondoux', ''),
('00004', '3214569874123', 'Fred Vargas', 'Commissaire Adamsberg'),
('00005', '3214563214563', 'RJ Ellory', ''),
('00006', '3213213211232', 'Edgar P. Jacobs', 'Blake et Mortimer'),
('00007', '6541236987541', 'Kate Atkinson', ''),
('00008', '1236987456321', 'Jean d\'Ormesson', ''),
('00009', '', 'Fred Vargas', 'Commissaire Adamsberg'),
('00010', '', 'Manon Moreau', ''),
('00011', '', 'Victoria Hislop', ''),
('00012', '', 'Kate Atkinson', ''),
('00013', '', 'Raymond Briggs', ''),
('00014', '', 'RJ Ellory', ''),
('00015', '', 'Floriane Turmeau', ''),
('00016', '', 'Julian Press', ''),
('00017', '', 'Philippe Masson', ''),
('00018', '', '', 'Guide du Routard'),
('00019', '', '', 'Guide Vert'),
('00020', '', '', 'Guide Vert'),
('00021', '', 'Claudie Gallay', ''),
('00022', '', 'Claudie Gallay', ''),
('00023', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00024', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00025', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00026', '', 'Pierre Boulle', 'Julliard');

-- --------------------------------------------------------

--
-- Structure de la table `livres_dvd`
--

DROP TABLE IF EXISTS `livres_dvd`;
CREATE TABLE IF NOT EXISTS `livres_dvd` (
  `id` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `livres_dvd`
--

INSERT INTO `livres_dvd` (`id`) VALUES
('00001'),
('00002'),
('00003'),
('00004'),
('00005'),
('00006'),
('00007'),
('00008'),
('00009'),
('00010'),
('00011'),
('00012'),
('00013'),
('00014'),
('00015'),
('00016'),
('00017'),
('00018'),
('00019'),
('00020'),
('00021'),
('00022'),
('00023'),
('00024'),
('00025'),
('00026'),
('20001'),
('20002'),
('20003'),
('20004');

-- --------------------------------------------------------

--
-- Structure de la table `public`
--

DROP TABLE IF EXISTS `public`;
CREATE TABLE IF NOT EXISTS `public` (
  `id` varchar(5) NOT NULL,
  `libelle` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `public`
--

INSERT INTO `public` (`id`, `libelle`) VALUES
('00001', 'Jeunesse'),
('00002', 'Adultes'),
('00003', 'Tous publics'),
('00004', 'Ados');

-- --------------------------------------------------------

--
-- Structure de la table `rayon`
--

DROP TABLE IF EXISTS `rayon`;
CREATE TABLE IF NOT EXISTS `rayon` (
  `id` char(5) NOT NULL,
  `libelle` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `rayon`
--

INSERT INTO `rayon` (`id`, `libelle`) VALUES
('BD001', 'BD Adultes'),
('BL001', 'Beaux Livres'),
('DF001', 'DVD films'),
('DV001', 'Sciences'),
('DV002', 'Maison'),
('DV003', 'Santé'),
('DV004', 'Littérature classique'),
('DV005', 'Voyages'),
('JN001', 'Jeunesse BD'),
('JN002', 'Jeunesse romans'),
('LV001', 'Littérature étrangère'),
('LV002', 'Littérature française'),
('LV003', 'Policiers français étrangers'),
('PR001', 'Presse quotidienne'),
('PR002', 'Magazines');

-- --------------------------------------------------------

--
-- Structure de la table `revue`
--

DROP TABLE IF EXISTS `revue`;
CREATE TABLE IF NOT EXISTS `revue` (
  `id` varchar(10) NOT NULL,
  `periodicite` varchar(2) DEFAULT NULL,
  `delaiMiseADispo` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `revue`
--

INSERT INTO `revue` (`id`, `periodicite`, `delaiMiseADispo`) VALUES
('10001', 'MS', 52),
('10002', 'MS', 52),
('10003', 'HB', 15),
('10004', 'HB', 15),
('10005', 'QT', 5),
('10006', 'QT', 5),
('10007', 'HB', 26),
('10008', 'HB', 26),
('10009', 'QT', 5),
('10010', 'HB', 12),
('10011', 'MS', 52);

-- --------------------------------------------------------

--
-- Structure de la table `service`
--

DROP TABLE IF EXISTS `service`;
CREATE TABLE IF NOT EXISTS `service` (
  `idService` int NOT NULL,
  `libelle` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`idService`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `service`
--

INSERT INTO `service` (`idService`, `libelle`) VALUES
(1, 'Administratif'),
(2, 'Prêts'),
(3, 'Culture'),
(4, 'Administrateur');

-- --------------------------------------------------------

--
-- Structure de la table `suivi`
--

DROP TABLE IF EXISTS `suivi`;
CREATE TABLE IF NOT EXISTS `suivi` (
  `id` varchar(5) NOT NULL,
  `libelle` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `suivi`
--

INSERT INTO `suivi` (`id`, `libelle`) VALUES
('00001', 'En cours'),
('00002', 'Livrée'),
('00003', 'Réglée'),
('00004', 'Relancée');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `idUtilisateur` int NOT NULL AUTO_INCREMENT,
  `login` varchar(30) NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `idService` int DEFAULT NULL,
  PRIMARY KEY (`idUtilisateur`),
  KEY `fk_utilisateur_service` (`idService`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`idUtilisateur`, `login`, `password`, `idService`) VALUES
(1, 'serviceadministratif', '0720f40c8c96d143ed0b1a13bd65ca4935da5042758620efb985953a524ba499', 1),
(2, 'servicepret', '1e4d7656a527a12b0ba6869e25692daca384cdc96b22ad1b7bf4c1b53cd7fcfe', 2),
(3, 'serviceculture', '84b57463cf89eebae4accada6a0650da634fe223c1a9d6cbf1dae137adbf0d3e', 3),
(4, 'admin', 'f724b2895757d445eacf1fc75b4892ddf971079421f09b7d9cfd0bb2d68142d8', 4);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `abonnement`
--
ALTER TABLE `abonnement`
  ADD CONSTRAINT `abonnement_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `abonnement_ibfk_2` FOREIGN KEY (`idRevue`) REFERENCES `revue` (`id`);

--
-- Contraintes pour la table `commandedocument`
--
ALTER TABLE `commandedocument`
  ADD CONSTRAINT `commandedocument_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `commandedocument_ibfk_2` FOREIGN KEY (`idLivreDvd`) REFERENCES `livres_dvd` (`id`),
  ADD CONSTRAINT `fk_id_suivi` FOREIGN KEY (`idSuivi`) REFERENCES `suivi` (`id`);

--
-- Contraintes pour la table `document`
--
ALTER TABLE `document`
  ADD CONSTRAINT `document_ibfk_1` FOREIGN KEY (`idRayon`) REFERENCES `rayon` (`id`),
  ADD CONSTRAINT `document_ibfk_2` FOREIGN KEY (`idPublic`) REFERENCES `public` (`id`),
  ADD CONSTRAINT `document_ibfk_3` FOREIGN KEY (`idGenre`) REFERENCES `genre` (`id`);

--
-- Contraintes pour la table `dvd`
--
ALTER TABLE `dvd`
  ADD CONSTRAINT `dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `exemplaire`
--
ALTER TABLE `exemplaire`
  ADD CONSTRAINT `exemplaire_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`),
  ADD CONSTRAINT `exemplaire_ibfk_2` FOREIGN KEY (`idEtat`) REFERENCES `etat` (`id`);

--
-- Contraintes pour la table `livre`
--
ALTER TABLE `livre`
  ADD CONSTRAINT `livre_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `livres_dvd`
--
ALTER TABLE `livres_dvd`
  ADD CONSTRAINT `livres_dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);

--
-- Contraintes pour la table `revue`
--
ALTER TABLE `revue`
  ADD CONSTRAINT `revue_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
