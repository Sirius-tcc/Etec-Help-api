-- phpMyAdmin SQL Dump
-- version 5.0.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 25-Nov-2020 às 04:01
-- Versão do servidor: 10.4.14-MariaDB
-- versão do PHP: 7.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `bdEtecHelp`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_signal` (`in_errortext` VARCHAR(255))  BEGIN
    SET @sql=CONCAT('UPDATE `', in_errortext, '` SET x=1');
    PREPARE my_signal_stmt FROM @sql;
    EXECUTE my_signal_stmt;
    DEALLOCATE PREPARE my_signal_stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_check_estudante` (IN `email` VARCHAR(100))  NO SQL
BEGIN
IF EXISTS( SELECT vwEstudantes.email FROM vwEstudantes WHERE vwEstudantes.email = email ) THEN
CALL my_signal('E-mail já existente.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_check_helper` (IN `email` VARCHAR(100))  NO SQL
BEGIN
IF EXISTS( SELECT vwHelper.email FROM vwHelper WHERE vwHelper.email = email ) THEN
CALL my_signal('E-mail já existente.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_estudante` (IN `nome` VARCHAR(12), IN `sobrenome` VARCHAR(12), IN `email` VARCHAR(30), IN `senha` VARCHAR(40))  BEGIN

IF NOT EXISTS (SELECT cod_estudante FROM tbEstudante WHERE email_estudante LIKE email) THEN
    INSERT INTO tbEstudante(nome_estudante, 
                            sobrenome_estudante, 
                            email_estudante,
                            senha_estudante
                           )
    VALUES(nome, sobrenome, email, senha);
ELSE
CALL my_signal('CPF já existente!');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_help` (IN `title` VARCHAR(40), IN `description` VARCHAR(280), IN `date` DATE, IN `time` TIME, IN `local` INT, IN `subject` INT, IN `student` INT, IN `helper` INT, IN `status` INT)  NO SQL
BEGIN

INSERT INTO `tbAjuda` (`titulo_ajuda`, `descricao_ajuda`, `data_ajuda`, `horario_ajuda`, `cod_local`, `cod_materia`, `cod_estudante`, `cod_helper`, `cod_status`) VALUES 
(title, description, date, time, local, subject, student, helper, status );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_helper` (IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `email` VARCHAR(30), IN `password` CHAR(40))  NO SQL
BEGIN
IF NOT EXISTS( SELECT * FROM vwHelper WHERE vwHelper.email = email ) THEN
INSERT INTO tbHelper(nome_helper , sobrenome_helper, email_helper, senha_helper) 
VALUES (name, surname, email, password);

ELSE 
CALL my_signal('E-mail já existente.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_message` (IN `menssage` VARCHAR(5000), IN `helper` INT, IN `student` INT, IN `user` VARCHAR(10))  NO SQL
BEGIN
INSERT INTO tbMensagem(texto_mensagem, data_mensagem, horario_mensagem, cod_estudante, cod_helper, usuario_mensagem)
VALUES ( menssage, CURDATE(), TIME(NOW()), student, helper, user);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_subject_helper` (IN `id_helper` INT, IN `id_subject` INT)  NO SQL
BEGIN
IF NOT EXISTS( SELECT * FROM tbMateriaHelper WHERE tbMateriaHelper.cod_helper = id_helper
AND 
tbMateriaHelper.cod_materia = id_subject  
) THEN
INSERT INTO tbMateriaHelper( cod_helper , cod_materia ) 
VALUES ( id_helper, id_subject );
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_topic` (IN `name` VARCHAR(30), IN `subject_code` INT)  NO SQL
BEGIN
IF EXISTS( SELECT * FROM tbMateria WHERE cod_materia =  subject_code ) THEN
INSERT INTO tbTopico(nome_topico, cod_materia) 
VALUES (name, subject_code);
ELSE 
CALL my_signal('Matéria não existe.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_helper` (IN `id` INT)  NO SQL
BEGIN 
IF EXISTS(SELECT * FROM tbHelper WHERE cod_helper = id) THEN
DELETE FROM tbHelper WHERE cod_helper = id;
ELSE
CALL my_signal('ID do Helper não existe.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_student` (IN `id` INT)  NO SQL
BEGIN
IF EXISTS(SELECT * FROM tbEstudante WHERE cod_estudante = id) THEN
DELETE FROM tbEstudante WHERE cod_estudante = id;
ELSE
	CALL my_signal('Erro ao deletar! estudante não existe.'); 
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_subject` (IN `helper_code` INT, IN `subject_code` INT)  NO SQL
BEGIN
IF EXISTS(SELECT * FROM tbMateriaHelper WHERE tbMateriaHelper.cod_helper = helper_code 
or tbMateriaHelper.cod_materia = subject_code ) THEN

    DELETE FROM tbMateriaHelper 
    WHERE tbMateriaHelper.cod_helper = helper_code
    AND tbMateriaHelper.cod_materia = subject_code;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_video` (IN `id` INT)  NO SQL
BEGIN
IF EXISTS(SELECT * FROM tbVideo WHERE cod_video = id) THEN
DELETE FROM tbVideo WHERE cod_video = id;
ELSE
	CALL my_signal('Erro ao deletar! video não existe.'); 
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_photo_estudante_name` (IN `id` INT, IN `name_photo` VARCHAR(30))  NO SQL
BEGIN
IF NOT EXISTS (SELECT * FROM tbEstudante WHERE cod_estudante = id) THEN
	CALL my_signal('ID não existe!');
END IF;

IF (SELECT foto_estudante FROM tbEstudante WHERE cod_estudante = id) IS NULL THEN
UPDATE tbEstudante
SET foto_estudante = name_photo
WHERE cod_estudante = id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_photo_helper_name` (IN `id` INT, IN `name_photo` VARCHAR(30))  NO SQL
BEGIN
IF NOT EXISTS (SELECT * FROM tbHelper WHERE cod_helper = id) THEN
	CALL my_signal('ID não existe!');
END IF;

IF (SELECT foto_helper FROM tbHelper WHERE cod_helper = id) IS NULL THEN
UPDATE tbHelper
SET foto_helper = name_photo
WHERE cod_helper = id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_save_photo_topic_name` (IN `id` INT, IN `name_icone` VARCHAR(40))  NO SQL
BEGIN
IF NOT EXISTS (SELECT * FROM tbTopico WHERE cod_topico = id) THEN
	CALL my_signal('ID não existe!');
    
ELSE

UPDATE tbTopico
SET icone_topico = name_icone
WHERE cod_topico = id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_set_classification` (IN `id` INT, IN `stars` INT)  NO SQL
BEGIN
IF (SELECT tbAjuda.classificacao_ajuda FROM tbAjuda WHERE tbAjuda.cod_ajuda = id) IS NULL THEN

UPDATE tbAjuda
SET classificacao_ajuda = stars
WHERE tbAjuda.cod_ajuda = id;

ELSE

CALL my_signal('Ajuda já foi classificada!');

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_show_classification_helper` (IN `cod_helper` INT)  NO SQL
BEGIN
SELECT AVG(tbAjuda.classificacao_ajuda) as classification FROM tbHelper
INNER JOIN tbAjuda
ON tbAjuda.cod_helper = tbHelper.cod_helper
WHERE tbHelper.cod_helper = cod_helper;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_subject_helper` (IN `id` INT)  NO SQL
BEGIN
SELECT nome_materia as subject from ((`bdEtecHelp`.`tbHelper` inner join `bdEtecHelp`.`tbMateriaHelper` on(`bdEtecHelp`.`tbMateriaHelper`.`cod_helper` = `bdEtecHelp`.`tbHelper`.`cod_helper`)) inner join `bdEtecHelp`.`tbMateria` on(`bdEtecHelp`.`tbMateriaHelper`.`cod_materia` = `bdEtecHelp`.`tbMateria`.`cod_materia`)) WHERE tbMateriaHelper.cod_helper = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_estudante` (IN `id` INT, IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `email` VARCHAR(30))  NO SQL
BEGIN
IF EXISTS( SELECT code FROM vwEstudantes WHERE code = id  ) THEN 
UPDATE tbEstudante 
	SET nome_estudante = name,
    sobrenome_estudante = surname,
    email_estudante = email
    WHERE cod_estudante = id;

ELSE
CALL my_signal('Estudante não existe!');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_helper` (IN `id` INT, IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `bio` VARCHAR(300), IN `email` VARCHAR(30))  NO SQL
BEGIN

IF EXISTS (SELECT cod_helper FROM tbHelper WHERE cod_helper = id) THEN
	UPDATE tbHelper 
	SET nome_helper= name,
	sobrenome_helper = surname,
    biografia_helper = bio,
	email_helper = email
	WHERE cod_helper = id;
ELSE
CALL my_signal('Helper não existe.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_video` (IN `id` INT, IN `title` VARCHAR(60), IN `description` VARCHAR(500))  NO SQL
BEGIN
IF EXISTS( SELECT code FROM vwVideos WHERE code = id  ) THEN 
UPDATE tbVideo 
SET titulo_video = title,
descricao_video = description
WHERE cod_video = id;
ELSE
CALL my_signal('Este video não existe!');
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbAjuda`
--

CREATE TABLE `tbAjuda` (
  `cod_ajuda` int(11) NOT NULL,
  `titulo_ajuda` varchar(40) NOT NULL,
  `descricao_ajuda` varchar(280) DEFAULT NULL,
  `classificacao_ajuda` int(11) DEFAULT NULL,
  `data_ajuda` date NOT NULL,
  `horario_ajuda` time NOT NULL,
  `cod_materia` int(11) DEFAULT NULL,
  `cod_estudante` int(11) DEFAULT NULL,
  `cod_helper` int(11) DEFAULT NULL,
  `cod_status` int(11) DEFAULT NULL,
  `cod_local` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbAjuda`
--

INSERT INTO `tbAjuda` (`cod_ajuda`, `titulo_ajuda`, `descricao_ajuda`, `classificacao_ajuda`, `data_ajuda`, `horario_ajuda`, `cod_materia`, `cod_estudante`, `cod_helper`, `cod_status`, `cod_local`) VALUES
(1, 'Por Favor, me ajude em algebra!', 'Eu não estou conseguindo entender o conceito de variável, hotz. Não entendi direito como funciona tal coisa. Esse negócio de passar para o lado e somar ou subtrair, não entendi direito. Me ajuda por favor.', 5, '2020-12-17', '15:00:00', 1, 2, 1, 2, 7),
(4, 'Preciso de ajuda em insert', ' OI, George!! eu vi um vídeo de programação explicando sobre inserts, mas eu não entendi nada. tem como você me ajudar nessa.', NULL, '2020-12-16', '15:50:00', 2, 2, 1, 2, 4);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbEstudante`
--

CREATE TABLE `tbEstudante` (
  `cod_estudante` int(11) NOT NULL,
  `foto_estudante` varchar(30) DEFAULT NULL,
  `nome_estudante` varchar(12) NOT NULL,
  `sobrenome_estudante` varchar(12) NOT NULL,
  `email_estudante` varchar(100) NOT NULL,
  `senha_estudante` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbEstudante`
--

INSERT INTO `tbEstudante` (`cod_estudante`, `foto_estudante`, `nome_estudante`, `sobrenome_estudante`, `email_estudante`, `senha_estudante`) VALUES
(1, '1.png', 'Vitor', 'Carmo', 'vitorv0071@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(2, '2.png', 'Beatriz', 'Vitória', 'beatrizvika@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(4, '4.png', 'Ana', 'Herley', 'Aninha_Harley123@gmail.com', 'f7c3bc1d808e04732adf679965ccc34ca7ae3441'),
(6, NULL, 'test', 'test', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3'),
(7, NULL, 'José', 'Nilton', 'nilton@gmail.com', '7751a23fa55170a57e90374df13a3ab78efe0e99'),
(8, NULL, 'Beatriz', 'França', 'beabea@gmail.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef'),
(9, '9.png', 'Brendo', 'Carmo', 'tionamae2@gmail.com', 'bd0e51e8b59bbf8a2c24c46e54e094cc73843447'),
(10, '10.png', 'Rutieny', 'Pires', 'ruty.pires@gmail.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef'),
(11, '11.png', 'Joaquim', 'Vinicius', 'jokas@gmail.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbHelper`
--

CREATE TABLE `tbHelper` (
  `cod_helper` int(11) NOT NULL,
  `foto_helper` varchar(30) DEFAULT NULL,
  `nome_helper` varchar(12) NOT NULL,
  `sobrenome_helper` varchar(12) NOT NULL,
  `biografia_helper` varchar(300) DEFAULT NULL,
  `email_helper` varchar(100) NOT NULL,
  `senha_helper` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbHelper`
--

INSERT INTO `tbHelper` (`cod_helper`, `foto_helper`, `nome_helper`, `sobrenome_helper`, `biografia_helper`, `email_helper`, `senha_helper`) VALUES
(1, '1.png', 'George', 'Hotz', 'Olá! me chamo george.\nGosto de matemática, programação, hacking e hardware, manjo muito dos paranauê, porém, sou um pouco chato.\n\nSe precisar de ajuda só me chamar', 'gghotz@comma.ai.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef'),
(3, '3.png', 'Aline', 'Mendonça', 'Eu sou professora da Etec de guaianazes em Desenvolvimento de Sistemas. Caso tenha dúvida em programação só chamar', 'aline@gmail.com', '7751a23fa55170a57e90374df13a3ab78efe0e99'),
(8, '8.png', 'Antonio', 'Junior', 'Olá eu sou o professor junior!\n\nEu gosto bastante de robótica, astrofísica, programação e qualquer coisa que envolve tecnologia e ciência.\n\nSe precisar de ajuda é só me chamar (uma ajuda que envolva programação)', 'antoniojr@gmail.com', '925f631c4ece772dceaee694ceb09e43bf07e5c9'),
(9, '9.png', 'Vanessa', 'Souza', 'Sou a professora, vanessa!\nE sou capacitada para ensinar matemática básica e do ensino fundamental com propriedade.\n\ncaso precisar de ajuda, só entrar em contato.', 'vanessa@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(11, NULL, 'Mateus', 'Araujo', 'Manjo muito de programação e lógica. \nJá alteirei um css de um framework inteiro na mão só por diversão, se quiser aprender lógica só entrar em contato', 'mateusAraujo@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(12, '12.png', 'Clodoaldo', 'Silva', 'Olá eu sou o clodoaldo. Gosto bastante de redes,  banco de dados e robótica.\n\nSe precisar de ajuda em álgebra, geometria e funções e matemática em geral só me chamar!', 'clodo@gmail.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbLocal`
--

CREATE TABLE `tbLocal` (
  `cod_local` int(11) NOT NULL,
  `nome_local` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbLocal`
--

INSERT INTO `tbLocal` (`cod_local`, `nome_local`) VALUES
(1, 'LAB 1'),
(2, 'LAB 2'),
(3, 'LAB 3'),
(4, 'LAB 4'),
(5, 'LAB 5'),
(6, 'LAB 6'),
(7, 'Biblioteca');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbMateria`
--

CREATE TABLE `tbMateria` (
  `cod_materia` int(11) NOT NULL,
  `nome_materia` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbMateria`
--

INSERT INTO `tbMateria` (`cod_materia`, `nome_materia`) VALUES
(1, 'Matemática'),
(2, 'Programação');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbMateriaHelper`
--

CREATE TABLE `tbMateriaHelper` (
  `cod_materia_helper` int(11) NOT NULL,
  `cod_materia` int(11) DEFAULT NULL,
  `cod_helper` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbMateriaHelper`
--

INSERT INTO `tbMateriaHelper` (`cod_materia_helper`, `cod_materia`, `cod_helper`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 1, 3),
(5, 2, 3),
(10, 2, 8),
(16, 2, 11),
(18, 2, 12),
(19, 1, 12),
(20, 1, 9);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbMensagem`
--

CREATE TABLE `tbMensagem` (
  `cod_mensagem` int(11) NOT NULL,
  `texto_mensagem` varchar(5000) NOT NULL,
  `data_mensagem` date NOT NULL,
  `horario_mensagem` time NOT NULL,
  `cod_estudante` int(11) DEFAULT NULL,
  `cod_helper` int(11) DEFAULT NULL,
  `usuario_mensagem` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbMensagem`
--

INSERT INTO `tbMensagem` (`cod_mensagem`, `texto_mensagem`, `data_mensagem`, `horario_mensagem`, `cod_estudante`, `cod_helper`, `usuario_mensagem`) VALUES
(2, 'Oi, tudo bem com você!', '2020-11-10', '15:17:41', 2, 1, 'student'),
(3, 'Oi..', '2020-11-10', '16:58:16', 2, 1, 'helper'),
(4, 'No que eu posso ajudar?', '2020-11-10', '16:59:31', 2, 1, 'helper'),
(5, 'Tem como você me ajudar em matemática!', '2020-11-10', '21:04:21', 2, 1, 'student'),
(6, 'Tem como você me ajudar em matemática!', '2020-11-11', '00:11:05', 2, 3, 'student'),
(7, 'Sim, espera só um pouquinho! mas já pode ir mandando sua pergunta', '2020-11-11', '00:24:35', 2, 3, 'helper'),
(8, 'OK!', '2020-11-11', '00:27:45', 2, 3, 'student'),
(9, 'Oi, Você tá precisando de ajuda?', '2020-11-11', '15:29:03', 1, 3, 'student'),
(10, 'Desculpa mandei errado kkkkk', '2020-11-11', '15:50:30', 1, 3, 'student'),
(11, 'Qual a pergunta???', '2020-11-11', '15:56:19', 2, 3, 'helper'),
(12, '???', '2020-11-11', '16:07:22', 2, 3, 'helper'),
(13, 'Foi mal desculpa!', '2020-11-11', '16:10:57', 1, 3, 'student'),
(14, 'Oi, desculpa!', '2020-11-11', '16:15:20', 2, 3, 'student'),
(15, 'Ta lenta minha internet!', '2020-11-11', '16:21:51', 2, 3, 'student'),
(16, '...', '2020-11-11', '16:23:47', 1, 3, 'student'),
(17, '...', '2020-11-11', '16:25:49', 2, 3, 'student'),
(18, '...', '2020-11-11', '16:27:30', 1, 3, 'student'),
(19, '...', '2020-11-11', '16:28:19', 2, 3, 'student'),
(20, 'Oi! tem como Você me ajudar?', '2020-11-11', '16:37:18', 4, 3, 'student'),
(21, '... espera ai', '2020-11-11', '16:39:11', 1, 3, 'student'),
(22, '...', '2020-11-11', '16:48:09', 2, 3, 'student'),
(23, '...', '2020-11-11', '18:09:32', 1, 3, 'student'),
(24, 'O que foi bia?', '2020-11-11', '18:15:19', 2, 3, 'helper'),
(25, '...', '2020-11-11', '18:15:48', 2, 1, 'helper'),
(26, 'oi', '2020-11-19', '23:25:04', 2, 8, 'student'),
(27, '....', '2020-11-19', '23:28:20', 2, 1, 'student'),
(28, 'testando', '2020-11-20', '16:28:11', 2, 1, 'helper'),
(29, 'testando', '2020-11-20', '16:28:43', 2, 8, 'helper'),
(30, 'olá bia', '2020-11-20', '16:32:59', 2, 8, 'helper'),
(31, 'Foi nada não desculpa', '2020-11-20', '18:13:16', 2, 3, 'student'),
(33, 'Hello george!', '2020-11-20', '20:41:41', 2, 1, 'student'),
(34, 'olá', '2020-11-20', '20:58:50', 2, 1, 'student'),
(35, 'olá', '2020-11-20', '21:02:54', 2, 1, 'student'),
(36, 'oiii de novo', '2020-11-20', '21:03:02', 2, 1, 'student'),
(37, '...', '2020-11-20', '21:03:09', 2, 1, 'student'),
(38, 'hey', '2020-11-20', '21:03:52', 2, 1, 'student'),
(39, 'estou só testando', '2020-11-20', '21:06:50', 2, 1, 'student'),
(40, '.', '2020-11-20', '21:07:17', 2, 1, 'student'),
(41, 'hello', '2020-11-20', '21:13:11', 2, 1, 'student'),
(42, 'hello', '2020-11-20', '21:13:13', 2, 1, 'student'),
(43, 'aaa', '2020-11-20', '21:15:43', 2, 1, 'student'),
(44, 'aaa', '2020-11-20', '21:15:45', 2, 1, 'student'),
(45, 'aaa', '2020-11-20', '21:16:33', 2, 1, 'student'),
(46, 'aaa', '2020-11-20', '21:16:44', 2, 1, 'student'),
(61, 'oi', '2020-11-20', '21:30:44', 2, 1, 'student'),
(62, 'oi', '2020-11-20', '21:30:46', 2, 1, 'student'),
(63, 'oi', '2020-11-20', '21:30:47', 2, 1, 'student'),
(64, 'olá', '2020-11-20', '21:32:40', 2, 1, 'student'),
(65, 'olá', '2020-11-20', '21:32:41', 2, 1, 'student'),
(66, 'olá', '2020-11-20', '21:32:42', 2, 1, 'student'),
(67, 'olá', '2020-11-20', '21:32:43', 2, 1, 'student'),
(68, 'meu deus que atraso', '2020-11-20', '21:32:50', 2, 1, 'student'),
(69, 'olá', '2020-11-20', '21:34:34', 2, 1, 'student'),
(70, 'tudo bem?', '2020-11-20', '21:34:39', 2, 1, 'student'),
(71, 'olá tudo bem?', '2020-11-20', '21:34:57', 2, 1, 'student'),
(72, 'olá tudo bem?', '2020-11-20', '21:35:00', 2, 1, 'student'),
(73, 'oiiiiiiiiiiiiii', '2020-11-20', '21:35:05', 2, 1, 'student'),
(74, 'oiiiiiiiiiiiiii', '2020-11-20', '21:35:08', 2, 1, 'student'),
(94, 'olá!', '2020-11-20', '22:09:29', 2, 1, 'student'),
(95, 'tudo bem?', '2020-11-20', '22:09:35', 2, 1, 'student'),
(96, 'oi moço?', '2020-11-20', '22:09:43', 2, 1, 'student'),
(99, 'oi professora!', '2020-11-20', '22:13:03', 2, 3, 'student'),
(100, 'Oi junior!', '2020-11-20', '22:13:16', 2, 8, 'student'),
(106, 'hello', '2020-11-20', '22:29:13', 2, 1, 'student'),
(107, 'oi', '2020-11-20', '22:45:52', 2, 3, 'student'),
(108, '??????', '2020-11-20', '22:46:12', 2, 1, 'student'),
(109, 'aaaa', '2020-11-20', '22:54:48', 2, 1, 'student'),
(110, 'olá', '2020-11-20', '22:55:02', 2, 1, 'student'),
(111, 'como vai indo a vida?', '2020-11-20', '22:55:34', 2, 8, 'student'),
(112, 'olá!', '2020-11-20', '23:00:17', 2, 8, 'student'),
(113, 'hey', '2020-11-20', '23:00:24', 2, 3, 'student'),
(114, 'kkkkk', '2020-11-20', '23:00:32', 2, 8, 'student'),
(115, 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? [33] At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.', '2020-11-20', '23:01:38', 2, 1, 'student'),
(116, 'desculpa kkk', '2020-11-20', '23:10:57', 2, 1, 'student'),
(117, 'foi mal', '2020-11-20', '23:11:52', 2, 1, 'student'),
(118, '....', '2020-11-20', '23:17:38', 2, 1, 'student'),
(119, 'aaa', '2020-11-20', '23:41:14', 2, 1, 'student'),
(120, 'oi professora como você vai?', '2020-11-20', '23:42:15', 1, 3, 'student'),
(121, 'oi george!', '2020-11-22', '20:39:43', 2, 1, 'student'),
(122, 'como vai!', '2020-11-22', '20:39:58', 2, 1, 'student'),
(123, 'hello!', '2020-11-22', '20:40:58', 2, 3, 'student'),
(124, 'me responde por favor!', '2020-11-22', '20:41:29', 2, 1, 'student'),
(125, 'me responda agora george!!!!', '2020-11-22', '20:52:42', 2, 1, 'student'),
(126, 'que foi?', '2020-11-22', '21:00:23', 2, 1, 'helper'),
(127, 'oi', '2020-11-22', '21:02:43', 2, 1, 'student'),
(129, 'meu deus para', '2020-11-22', '21:03:47', 2, 1, 'helper'),
(130, 'O que que você quer que eu te ajude?', '2020-11-22', '21:06:16', 2, 1, 'helper'),
(131, 'Em programação, george!', '2020-11-22', '21:12:27', 2, 1, 'student'),
(132, 'Mas exatamente o que?', '2020-11-22', '21:12:40', 2, 1, 'helper'),
(133, 'Laço de repitição ', '2020-11-22', '21:12:56', 2, 1, 'student'),
(134, 'e também vetor!', '2020-11-22', '21:13:03', 2, 1, 'student'),
(135, 'entendi', '2020-11-22', '21:13:12', 2, 1, 'helper'),
(136, 'p', '2020-11-22', '21:13:33', 2, 1, 'student'),
(137, 'ops', '2020-11-22', '21:15:14', 2, 1, 'student'),
(138, 'hh', '2020-11-22', '21:15:54', 2, 1, 'helper'),
(139, 'aaaaa', '2020-11-22', '21:16:00', 2, 1, 'helper'),
(140, '444', '2020-11-22', '21:16:08', 2, 1, 'student'),
(141, 'aaa', '2020-11-22', '21:17:26', 2, 1, 'helper'),
(143, '444', '2020-11-22', '21:18:06', 2, 1, 'student'),
(144, '444', '2020-11-22', '21:18:12', 2, 1, 'helper'),
(145, 'aaa', '2020-11-22', '21:20:14', 2, 1, 'helper'),
(146, 'aaaa', '2020-11-22', '21:20:26', 2, 1, 'helper'),
(147, 'aaaa', '2020-11-22', '21:21:34', 2, 1, 'helper'),
(148, 'aaa', '2020-11-22', '21:21:55', 2, 1, 'helper'),
(149, 'aaa', '2020-11-22', '21:21:56', 2, 1, 'student'),
(150, 'aaa', '2020-11-22', '21:21:56', 2, 8, 'student'),
(151, '555', '2020-11-22', '21:21:57', 2, 3, 'student'),
(152, 'aaa', '2020-11-22', '21:23:03', 2, 1, 'helper'),
(153, 'aa', '2020-11-22', '21:23:07', 2, 1, 'student'),
(154, 'aaaa', '2020-11-22', '21:27:40', 2, 1, 'helper'),
(155, '1111', '2020-11-22', '21:27:46', 2, 1, 'student'),
(156, '444', '2020-11-22', '21:27:57', 2, 8, 'student'),
(157, '444', '2020-11-22', '21:30:48', 2, 8, 'student'),
(158, '222', '2020-11-22', '21:30:48', 2, 1, 'student'),
(159, 'aaa', '2020-11-22', '21:30:48', 2, 8, 'student'),
(160, 'aa', '2020-11-22', '21:32:15', 2, 3, 'student'),
(161, 'oi tudo bom ', '2020-11-22', '21:34:06', 2, 1, 'helper'),
(162, 'aaa', '2020-11-22', '21:34:07', 2, 3, 'student'),
(163, 'aaaa', '2020-11-22', '21:34:17', 2, 1, 'helper'),
(164, 'aaa', '2020-11-22', '21:34:21', 2, 1, 'helper'),
(165, 'como vai!!!!', '2020-11-22', '21:34:29', 2, 1, 'helper'),
(166, 'aaaaa', '2020-11-22', '21:34:47', 2, 3, 'student'),
(167, 'aaa', '2020-11-22', '21:37:40', 2, 8, 'student'),
(168, 'aaa', '2020-11-22', '21:37:41', 2, 1, 'helper'),
(169, 'aaa', '2020-11-22', '21:37:41', 2, 8, 'student'),
(170, 'aaaa', '2020-11-22', '21:37:42', 2, 1, 'student'),
(171, 'aaaaa', '2020-11-22', '21:38:12', 2, 1, 'helper'),
(172, 'oi', '2020-11-22', '21:38:32', 2, 1, 'student'),
(173, 'que foi!', '2020-11-22', '21:39:48', 2, 3, 'helper'),
(174, 'aline!', '2020-11-22', '21:39:48', 2, 3, 'student'),
(175, 'diga ', '2020-11-22', '21:40:53', 1, 3, 'helper'),
(176, 'aa', '2020-11-22', '21:42:02', 4, 3, 'helper'),
(177, 'ççç', '2020-11-22', '21:44:06', 2, 8, 'student'),
(178, 'aaa', '2020-11-22', '21:44:24', 1, 3, 'helper'),
(179, 'aaa', '2020-11-22', '21:49:35', 1, 3, 'helper'),
(180, 'oi', '2020-11-22', '21:50:37', 1, 3, 'helper'),
(181, 'jnnakl', '2020-11-22', '21:50:37', 1, 3, 'helper'),
(182, 'aa', '2020-11-22', '21:52:42', 1, 3, 'helper'),
(183, 'oi', '2020-11-22', '21:53:30', 2, 3, 'helper'),
(184, 'aaa', '2020-11-22', '21:54:23', 2, 3, 'helper'),
(185, 'aaa', '2020-11-22', '21:55:08', 2, 3, 'helper'),
(186, 'meu deus', '2020-11-22', '21:55:15', 2, 3, 'helper'),
(187, 'testando', '2020-11-22', '21:56:13', 2, 3, 'helper'),
(188, 'oi', '2020-11-22', '21:56:47', 2, 3, 'helper'),
(189, 'agora foi!', '2020-11-22', '21:56:53', 2, 3, 'helper'),
(190, 'testando chat', '2020-11-22', '21:57:18', 2, 3, 'student'),
(191, 'testando chat', '2020-11-22', '21:57:27', 2, 1, 'student'),
(192, 'testando chat junior', '2020-11-22', '21:57:40', 2, 8, 'student'),
(193, 'testando chat ', '2020-11-22', '21:57:48', 4, 3, 'helper'),
(194, 'aaa', '2020-11-22', '21:58:18', 4, 3, 'helper'),
(195, 'aaa', '2020-11-22', '21:58:22', 1, 3, 'helper'),
(196, 'oi', '2020-11-22', '21:59:53', 1, 3, 'helper'),
(197, 'oi', '2020-11-22', '21:59:58', 2, 3, 'helper'),
(198, 'oi', '2020-11-22', '22:00:07', 2, 3, 'student'),
(199, 'testando!', '2020-11-22', '22:00:16', 4, 3, 'helper'),
(200, 'ala o chat da twitch', '2020-11-22', '22:00:30', 2, 1, 'student'),
(201, '123', '2020-11-24', '20:44:04', 2, 1, 'student'),
(202, 'desculpa', '2020-11-24', '21:15:10', 2, 8, 'student'),
(203, 'Hello!', '2020-11-24', '21:40:52', 2, 1, 'student'),
(204, 'Hello, baby!', '2020-11-24', '21:42:52', 2, 1, 'helper'),
(205, 'testando!', '2020-11-24', '23:09:59', 2, 1, 'helper'),
(206, 'Oi vitor!', '2020-11-24', '23:41:11', 1, 1, 'helper'),
(207, 'como vai meu consagrado!', '2020-11-24', '23:41:37', 1, 1, 'helper'),
(208, 'pera ai que eu já aceito', '2020-11-24', '23:41:52', 2, 1, 'helper'),
(209, 'blz?', '2020-11-24', '23:42:15', 2, 1, 'helper'),
(210, 'Fala, mateus! tranquilo?', '2020-11-24', '23:56:25', 1, 11, 'student'),
(211, 'podes me ajudar se possivel?', '2020-11-24', '23:56:34', 1, 11, 'student'),
(212, 'test', '2020-11-24', '23:57:31', 1, 11, 'student'),
(213, 'olá', '2020-11-24', '23:57:42', 1, 8, 'student'),
(214, 'manja de jupyter?', '2020-11-24', '23:57:51', 1, 8, 'student'),
(215, 'python hehe', '2020-11-24', '23:57:59', 1, 8, 'student'),
(216, 'olá professora!', '2020-11-24', '23:58:13', 1, 3, 'student');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbStatus`
--

CREATE TABLE `tbStatus` (
  `cod_status` int(11) NOT NULL,
  `nome_status` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbStatus`
--

INSERT INTO `tbStatus` (`cod_status`, `nome_status`) VALUES
(1, 'Pendente'),
(2, 'Confirmado'),
(3, 'Recusado');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbTopico`
--

CREATE TABLE `tbTopico` (
  `cod_topico` int(11) NOT NULL,
  `nome_topico` varchar(30) NOT NULL,
  `icone_topico` varchar(40) DEFAULT NULL,
  `cod_materia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbTopico`
--

INSERT INTO `tbTopico` (`cod_topico`, `nome_topico`, `icone_topico`, `cod_materia`) VALUES
(1, 'Aritmética', '1.svg', 1),
(14, 'Álgebra', '14.svg', 1),
(15, 'Lógica de programação', '15.svg', 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbVideo`
--

CREATE TABLE `tbVideo` (
  `cod_video` int(11) NOT NULL,
  `url_video` varchar(40) DEFAULT NULL,
  `titulo_video` varchar(60) NOT NULL,
  `descricao_video` varchar(3000) DEFAULT NULL,
  `cod_topico` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbVideo`
--

INSERT INTO `tbVideo` (`cod_video`, `url_video`, `titulo_video`, `descricao_video`, `cod_topico`) VALUES
(14, '14.mp4', '#1 - introdução a adição e subtração básica', 'A adição e a subtração são a base de toda a matemática. Este tutorial apresenta a adição e a subtração de números de um algarismo.', 1),
(24, '24.mp4', '#2 - Subtração Básica', 'fjndjbnvjanjon jnfjnaj njnjonafon bfh absbhasfh nujfnja ', 1),
(25, '25.mp4', '#1 - Indrodução', 'Diferente do que muito gente pensa, você não precisa ser um gênio para aprender a programar. Lembra de quando você não sabia ler? As letras eram como desenhos ou rabiscos e pra você não formavam palavras, muito menos frases. Mas, aos pouquinhos você aprendeu, primeiro as vogais, depois as consoantes e então vieram as sílabas, palavras e por fim você estava lendo e escrevendo. A programação também é uma linguagem, que pode ser lida por computadores, e você não precisa ser nenhum gênio para aprendê-la, assim como não precisa ser um gênio para aprender a ler e escrever.\n\nMas, você precisa começar de algum lugar e o primeiro passo para aprender a programar é pela lógica de programação, pois ela é fundamental para organizar seu raciocínio para resolução de problemas, uma vez que é você quem define o que o computador irá executar.\n\nEsse repositório é feito para ajudar estudantes que estão iniciando em programação. Os conteúdos aqui apresentados são baseados em uma apostila feita pelas Professoras Aline Mendonça e Vanessa Ferraz.', 15);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbView`
--

CREATE TABLE `tbView` (
  `cod_view` int(11) NOT NULL,
  `data_hora_view` datetime NOT NULL,
  `cod_video` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbView`
--

INSERT INTO `tbView` (`cod_view`, `data_hora_view`, `cod_video`) VALUES
(5, '2020-10-31 00:38:17', 14),
(6, '2020-10-31 00:38:31', 14),
(7, '2020-10-31 00:38:32', 14),
(8, '2020-10-31 00:38:32', 14),
(9, '2020-10-31 00:38:33', 14),
(10, '2020-10-31 00:38:33', 14),
(11, '2020-11-18 22:11:13', 14),
(12, '2020-11-18 23:37:00', 24),
(13, '2020-11-18 23:38:20', 24),
(14, '2020-11-18 23:38:31', 14),
(15, '2020-11-18 23:38:40', 24),
(16, '2020-11-18 23:38:51', 24),
(17, '2020-11-18 23:38:58', 14),
(18, '2020-11-18 23:39:31', 25),
(19, '2020-11-18 23:40:51', 25),
(20, '2020-11-18 23:41:05', 25),
(21, '2020-11-18 23:41:13', 25),
(22, '2020-11-18 23:41:32', 25),
(23, '2020-11-18 23:44:05', 24),
(24, '2020-11-18 23:44:51', 14),
(25, '2020-11-18 23:45:44', 24),
(26, '2020-11-19 18:17:18', 25),
(27, '2020-11-19 23:43:22', 25),
(28, '2020-11-20 11:04:26', 14);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwAjuda`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwAjuda` (
`help_code` int(11)
,`title` varchar(40)
,`description` varchar(280)
,`classification` int(11)
,`date` date
,`time` time
,`local` varchar(40)
,`subject_code` int(11)
,`subject_name` varchar(30)
,`student_code` int(11)
,`student_name` varchar(12)
,`student_surname` varchar(12)
,`helper_code` int(11)
,`helper_name` varchar(12)
,`helper_surname` varchar(12)
,`status` varchar(10)
,`status_code` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwEstudantes`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwEstudantes` (
`code` int(11)
,`photo` varchar(30)
,`name` varchar(12)
,`surname` varchar(12)
,`email` varchar(100)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwHelper`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwHelper` (
`code` int(11)
,`photo` varchar(30)
,`name` varchar(12)
,`surname` varchar(12)
,`bio` varchar(300)
,`email` varchar(100)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwMensagens`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwMensagens` (
`code` int(11)
,`message` varchar(5000)
,`date` date
,`time` time
,`student_code` int(11)
,`helper_code` int(11)
,`user` varchar(10)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwSubjectHelpers`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwSubjectHelpers` (
`helper_code` int(11)
,`subject_code` int(11)
,`name` varchar(12)
,`surname` varchar(12)
,`subject` varchar(30)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwTopico`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwTopico` (
`code` int(11)
,`name` varchar(30)
,`icon` varchar(40)
,`subject` varchar(30)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwVideos`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwVideos` (
`icon` varchar(40)
,`code` int(11)
,`url` varchar(40)
,`title` varchar(60)
,`description` varchar(3000)
,`topic` varchar(30)
,`views` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `vwAjuda`
--
DROP TABLE IF EXISTS `vwAjuda`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwAjuda`  AS SELECT `tbAjuda`.`cod_ajuda` AS `help_code`, `tbAjuda`.`titulo_ajuda` AS `title`, `tbAjuda`.`descricao_ajuda` AS `description`, `tbAjuda`.`classificacao_ajuda` AS `classification`, `tbAjuda`.`data_ajuda` AS `date`, `tbAjuda`.`horario_ajuda` AS `time`, `tbLocal`.`nome_local` AS `local`, `tbMateria`.`cod_materia` AS `subject_code`, `tbMateria`.`nome_materia` AS `subject_name`, `tbEstudante`.`cod_estudante` AS `student_code`, `tbEstudante`.`nome_estudante` AS `student_name`, `tbEstudante`.`sobrenome_estudante` AS `student_surname`, `tbHelper`.`cod_helper` AS `helper_code`, `tbHelper`.`nome_helper` AS `helper_name`, `tbHelper`.`sobrenome_helper` AS `helper_surname`, `tbStatus`.`nome_status` AS `status`, `tbStatus`.`cod_status` AS `status_code` FROM (((((`tbAjuda` join `tbLocal` on(`tbLocal`.`cod_local` = `tbAjuda`.`cod_local`)) join `tbHelper` on(`tbHelper`.`cod_helper` = `tbAjuda`.`cod_helper`)) join `tbEstudante` on(`tbEstudante`.`cod_estudante` = `tbAjuda`.`cod_estudante`)) join `tbMateria` on(`tbMateria`.`cod_materia` = `tbAjuda`.`cod_materia`)) join `tbStatus` on(`tbStatus`.`cod_status` = `tbAjuda`.`cod_status`)) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwEstudantes`
--
DROP TABLE IF EXISTS `vwEstudantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwEstudantes`  AS SELECT `tbEstudante`.`cod_estudante` AS `code`, `tbEstudante`.`foto_estudante` AS `photo`, `tbEstudante`.`nome_estudante` AS `name`, `tbEstudante`.`sobrenome_estudante` AS `surname`, `tbEstudante`.`email_estudante` AS `email` FROM `tbEstudante` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwHelper`
--
DROP TABLE IF EXISTS `vwHelper`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwHelper`  AS SELECT `tbHelper`.`cod_helper` AS `code`, `tbHelper`.`foto_helper` AS `photo`, `tbHelper`.`nome_helper` AS `name`, `tbHelper`.`sobrenome_helper` AS `surname`, `tbHelper`.`biografia_helper` AS `bio`, `tbHelper`.`email_helper` AS `email` FROM `tbHelper` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwMensagens`
--
DROP TABLE IF EXISTS `vwMensagens`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwMensagens`  AS SELECT `tbMensagem`.`cod_mensagem` AS `code`, `tbMensagem`.`texto_mensagem` AS `message`, `tbMensagem`.`data_mensagem` AS `date`, `tbMensagem`.`horario_mensagem` AS `time`, `tbMensagem`.`cod_estudante` AS `student_code`, `tbMensagem`.`cod_helper` AS `helper_code`, `tbMensagem`.`usuario_mensagem` AS `user` FROM `tbMensagem` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwSubjectHelpers`
--
DROP TABLE IF EXISTS `vwSubjectHelpers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwSubjectHelpers`  AS SELECT `tbHelper`.`cod_helper` AS `helper_code`, `tbMateria`.`cod_materia` AS `subject_code`, `tbHelper`.`nome_helper` AS `name`, `tbHelper`.`sobrenome_helper` AS `surname`, `tbMateria`.`nome_materia` AS `subject` FROM ((`tbHelper` left join `tbMateriaHelper` on(`tbMateriaHelper`.`cod_helper` = `tbHelper`.`cod_helper`)) left join `tbMateria` on(`tbMateriaHelper`.`cod_materia` = `tbMateria`.`cod_materia`)) ORDER BY `tbMateria`.`cod_materia` ASC ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwTopico`
--
DROP TABLE IF EXISTS `vwTopico`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwTopico`  AS SELECT `tbTopico`.`cod_topico` AS `code`, `tbTopico`.`nome_topico` AS `name`, `tbTopico`.`icone_topico` AS `icon`, `tbMateria`.`nome_materia` AS `subject` FROM (`tbTopico` join `tbMateria` on(`tbTopico`.`cod_materia` = `tbMateria`.`cod_materia`)) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwVideos`
--
DROP TABLE IF EXISTS `vwVideos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwVideos`  AS SELECT `tbTopico`.`icone_topico` AS `icon`, `tbVideo`.`cod_video` AS `code`, `tbVideo`.`url_video` AS `url`, `tbVideo`.`titulo_video` AS `title`, `tbVideo`.`descricao_video` AS `description`, `tbTopico`.`nome_topico` AS `topic`, count(`tbView`.`cod_video`) AS `views` FROM ((`tbVideo` left join `tbView` on(`tbView`.`cod_video` = `tbVideo`.`cod_video`)) join `tbTopico` on(`tbTopico`.`cod_topico` = `tbVideo`.`cod_topico`)) GROUP BY `tbVideo`.`cod_video` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `tbAjuda`
--
ALTER TABLE `tbAjuda`
  ADD PRIMARY KEY (`cod_ajuda`),
  ADD KEY `cod_materia` (`cod_materia`),
  ADD KEY `cod_estudante` (`cod_estudante`),
  ADD KEY `cod_helper` (`cod_helper`),
  ADD KEY `cod_status` (`cod_status`),
  ADD KEY `cod_local` (`cod_local`);

--
-- Índices para tabela `tbEstudante`
--
ALTER TABLE `tbEstudante`
  ADD PRIMARY KEY (`cod_estudante`);

--
-- Índices para tabela `tbHelper`
--
ALTER TABLE `tbHelper`
  ADD PRIMARY KEY (`cod_helper`);

--
-- Índices para tabela `tbLocal`
--
ALTER TABLE `tbLocal`
  ADD PRIMARY KEY (`cod_local`);

--
-- Índices para tabela `tbMateria`
--
ALTER TABLE `tbMateria`
  ADD PRIMARY KEY (`cod_materia`);

--
-- Índices para tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  ADD PRIMARY KEY (`cod_materia_helper`),
  ADD KEY `cod_materia` (`cod_materia`),
  ADD KEY `cod_helper` (`cod_helper`);

--
-- Índices para tabela `tbMensagem`
--
ALTER TABLE `tbMensagem`
  ADD PRIMARY KEY (`cod_mensagem`),
  ADD KEY `cod_estudante` (`cod_estudante`),
  ADD KEY `cod_helper` (`cod_helper`);

--
-- Índices para tabela `tbStatus`
--
ALTER TABLE `tbStatus`
  ADD PRIMARY KEY (`cod_status`);

--
-- Índices para tabela `tbTopico`
--
ALTER TABLE `tbTopico`
  ADD PRIMARY KEY (`cod_topico`),
  ADD KEY `cod_materia` (`cod_materia`);

--
-- Índices para tabela `tbVideo`
--
ALTER TABLE `tbVideo`
  ADD PRIMARY KEY (`cod_video`),
  ADD KEY `cod_topico` (`cod_topico`);

--
-- Índices para tabela `tbView`
--
ALTER TABLE `tbView`
  ADD PRIMARY KEY (`cod_view`),
  ADD KEY `cod_video` (`cod_video`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `tbAjuda`
--
ALTER TABLE `tbAjuda`
  MODIFY `cod_ajuda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `tbEstudante`
--
ALTER TABLE `tbEstudante`
  MODIFY `cod_estudante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de tabela `tbHelper`
--
ALTER TABLE `tbHelper`
  MODIFY `cod_helper` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de tabela `tbLocal`
--
ALTER TABLE `tbLocal`
  MODIFY `cod_local` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `tbMateria`
--
ALTER TABLE `tbMateria`
  MODIFY `cod_materia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  MODIFY `cod_materia_helper` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de tabela `tbMensagem`
--
ALTER TABLE `tbMensagem`
  MODIFY `cod_mensagem` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=217;

--
-- AUTO_INCREMENT de tabela `tbStatus`
--
ALTER TABLE `tbStatus`
  MODIFY `cod_status` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `tbTopico`
--
ALTER TABLE `tbTopico`
  MODIFY `cod_topico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de tabela `tbVideo`
--
ALTER TABLE `tbVideo`
  MODIFY `cod_video` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de tabela `tbView`
--
ALTER TABLE `tbView`
  MODIFY `cod_view` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `tbAjuda`
--
ALTER TABLE `tbAjuda`
  ADD CONSTRAINT `tbAjuda_ibfk_1` FOREIGN KEY (`cod_materia`) REFERENCES `tbMateria` (`cod_materia`),
  ADD CONSTRAINT `tbAjuda_ibfk_2` FOREIGN KEY (`cod_estudante`) REFERENCES `tbEstudante` (`cod_estudante`),
  ADD CONSTRAINT `tbAjuda_ibfk_3` FOREIGN KEY (`cod_helper`) REFERENCES `tbHelper` (`cod_helper`),
  ADD CONSTRAINT `tbAjuda_ibfk_4` FOREIGN KEY (`cod_status`) REFERENCES `tbStatus` (`cod_status`),
  ADD CONSTRAINT `tbAjuda_ibfk_5` FOREIGN KEY (`cod_local`) REFERENCES `tbLocal` (`cod_local`);

--
-- Limitadores para a tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  ADD CONSTRAINT `tbMateriaHelper_ibfk_1` FOREIGN KEY (`cod_materia`) REFERENCES `tbMateria` (`cod_materia`),
  ADD CONSTRAINT `tbMateriaHelper_ibfk_2` FOREIGN KEY (`cod_helper`) REFERENCES `tbHelper` (`cod_helper`);

--
-- Limitadores para a tabela `tbMensagem`
--
ALTER TABLE `tbMensagem`
  ADD CONSTRAINT `tbMensagem_ibfk_1` FOREIGN KEY (`cod_estudante`) REFERENCES `tbEstudante` (`cod_estudante`),
  ADD CONSTRAINT `tbMensagem_ibfk_2` FOREIGN KEY (`cod_helper`) REFERENCES `tbHelper` (`cod_helper`);

--
-- Limitadores para a tabela `tbTopico`
--
ALTER TABLE `tbTopico`
  ADD CONSTRAINT `tbTopico_ibfk_1` FOREIGN KEY (`cod_materia`) REFERENCES `tbMateria` (`cod_materia`);

--
-- Limitadores para a tabela `tbVideo`
--
ALTER TABLE `tbVideo`
  ADD CONSTRAINT `tbVideo_ibfk_1` FOREIGN KEY (`cod_topico`) REFERENCES `tbTopico` (`cod_topico`);

--
-- Limitadores para a tabela `tbView`
--
ALTER TABLE `tbView`
  ADD CONSTRAINT `tbView_ibfk_1` FOREIGN KEY (`cod_video`) REFERENCES `tbVideo` (`cod_video`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
