-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 30-Out-2020 às 05:45
-- Versão do servidor: 10.4.11-MariaDB
-- versão do PHP: 7.4.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_helper` (IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `bio` VARCHAR(140), IN `email` VARCHAR(30), IN `password` CHAR(40))  NO SQL
BEGIN
IF NOT EXISTS( SELECT * FROM vwHelper WHERE vwHelper.email = email ) THEN
INSERT INTO tbHelper(nome_helper , sobrenome_helper , biografia_helper, email_helper, senha_helper) 
VALUES (name, surname, bio, email, password);

ELSE 
CALL my_signal('E-mail já existente.');
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_helper` (IN `id` INT, IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `bio` VARCHAR(140), IN `email` VARCHAR(30))  NO SQL
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

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbAjuda`
--

CREATE TABLE `tbAjuda` (
  `cod_ajuda` int(11) NOT NULL,
  `titulo_ajuda` varchar(40) NOT NULL,
  `descricao_ajuda` varchar(140) DEFAULT NULL,
  `classificacao_ajuda` int(11) DEFAULT NULL,
  `data_ajuda` date NOT NULL,
  `horario_ajuda` time NOT NULL,
  `local_ajuda` varchar(40) NOT NULL,
  `cod_materia` int(11) DEFAULT NULL,
  `cod_estudante` int(11) DEFAULT NULL,
  `cod_helper` int(11) DEFAULT NULL,
  `cod_status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbEstudante`
--

CREATE TABLE `tbEstudante` (
  `cod_estudante` int(11) NOT NULL,
  `foto_estudante` varchar(30) DEFAULT NULL,
  `nome_estudante` varchar(12) NOT NULL,
  `sobrenome_estudante` varchar(12) NOT NULL,
  `email_estudante` varchar(30) NOT NULL,
  `senha_estudante` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbEstudante`
--

INSERT INTO `tbEstudante` (`cod_estudante`, `foto_estudante`, `nome_estudante`, `sobrenome_estudante`, `email_estudante`, `senha_estudante`) VALUES
(1, '1.png', 'Vitor', 'Carmo', 'vitorv0071@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(2, '2.png', 'Beatriz', 'Vitória', 'Beatrizvika@gmail.com', '7110eda4d09e062aa5e4a390b0a572ac0d2c0220'),
(4, '4.png', 'Ana', 'Herley', 'Aninha_Harley123@gmail.com', 'f7c3bc1d808e04732adf679965ccc34ca7ae3441'),
(6, NULL, 'test', 'test', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbHelper`
--

CREATE TABLE `tbHelper` (
  `cod_helper` int(11) NOT NULL,
  `foto_helper` varchar(30) DEFAULT NULL,
  `nome_helper` varchar(12) NOT NULL,
  `sobrenome_helper` varchar(12) NOT NULL,
  `biografia_helper` varchar(140) DEFAULT NULL,
  `email_helper` varchar(30) NOT NULL,
  `senha_helper` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbHelper`
--

INSERT INTO `tbHelper` (`cod_helper`, `foto_helper`, `nome_helper`, `sobrenome_helper`, `biografia_helper`, `email_helper`, `senha_helper`) VALUES
(1, '1.png', 'George', 'Hotz', 'Olá! me chamo george, gosto de matemática, programação, hacking e hardware, manjo muito dos paranauê, porém, sou um pouco chato', 'gghotz@comma.ai.com', '40bd001563085fc35165329ea1ff5c5ecbdbbeef'),
(3, '3.png', 'Aline', 'Mendonça', 'Eu sou professora da Etec de guaianazes em Desenvolvimento de Sistemas. Caso tenha dúvida em programação só chamar', 'aline@gmail.com', '7751a23fa55170a57e90374df13a3ab78efe0e99'),
(4, NULL, 'test', 'test', 'hello!', 'test@gmail.com', 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3');

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
  `cod_helper` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  `icone_topico` varchar(40) NOT NULL,
  `cod_materia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbTopico`
--

INSERT INTO `tbTopico` (`cod_topico`, `nome_topico`, `icone_topico`, `cod_materia`) VALUES
(1, 'Aritmética', '1.svg', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbVideo`
--

CREATE TABLE `tbVideo` (
  `cod_video` int(11) NOT NULL,
  `url_video` varchar(40) DEFAULT NULL,
  `titulo_video` varchar(40) NOT NULL,
  `descricao_video` varchar(500) DEFAULT NULL,
  `cod_topico` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbVideo`
--

INSERT INTO `tbVideo` (`cod_video`, `url_video`, `titulo_video`, `descricao_video`, `cod_topico`) VALUES
(14, '14.mp4', '#1 - Adição Básica', 'A adição e a subtração são a base de toda a matemática. Este tutorial apresenta a adição e a subtração de números de um algarismo. Você também deverá se familiarizar bastante com a reta numérica!', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbView`
--

CREATE TABLE `tbView` (
  `cod_view` int(11) NOT NULL,
  `data_view` date NOT NULL,
  `cod_video` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `tbView`
--

INSERT INTO `tbView` (`cod_view`, `data_view`, `cod_video`) VALUES
(1, '2020-10-30', 14),
(2, '2020-10-30', 14),
(3, '2020-10-30', 14),
(4, '2020-10-30', 14);

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
,`email` varchar(30)
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
,`bio` varchar(140)
,`email` varchar(30)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vwVideos`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vwVideos` (
`code` int(11)
,`url` varchar(40)
,`title` varchar(40)
,`description` varchar(500)
,`topico` varchar(30)
,`views` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `vwEstudantes`
--
DROP TABLE IF EXISTS `vwEstudantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwEstudantes`  AS  select `tbEstudante`.`cod_estudante` AS `code`,`tbEstudante`.`foto_estudante` AS `photo`,`tbEstudante`.`nome_estudante` AS `name`,`tbEstudante`.`sobrenome_estudante` AS `surname`,`tbEstudante`.`email_estudante` AS `email` from `tbEstudante` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwHelper`
--
DROP TABLE IF EXISTS `vwHelper`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwHelper`  AS  select `tbHelper`.`cod_helper` AS `code`,`tbHelper`.`foto_helper` AS `photo`,`tbHelper`.`nome_helper` AS `name`,`tbHelper`.`sobrenome_helper` AS `surname`,`tbHelper`.`biografia_helper` AS `bio`,`tbHelper`.`email_helper` AS `email` from `tbHelper` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vwVideos`
--
DROP TABLE IF EXISTS `vwVideos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwVideos`  AS  select `tbVideo`.`cod_video` AS `code`,`tbVideo`.`url_video` AS `url`,`tbVideo`.`titulo_video` AS `title`,`tbVideo`.`descricao_video` AS `description`,`tbTopico`.`nome_topico` AS `topico`,count(`tbView`.`cod_video`) AS `views` from ((`tbVideo` left join `tbView` on(`tbView`.`cod_video` = `tbVideo`.`cod_video`)) join `tbTopico` on(`tbTopico`.`cod_topico` = `tbVideo`.`cod_topico`)) group by `tbVideo`.`cod_video` ;

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
  ADD KEY `cod_status` (`cod_status`);

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
  MODIFY `cod_ajuda` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tbEstudante`
--
ALTER TABLE `tbEstudante`
  MODIFY `cod_estudante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `tbHelper`
--
ALTER TABLE `tbHelper`
  MODIFY `cod_helper` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `tbMateria`
--
ALTER TABLE `tbMateria`
  MODIFY `cod_materia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  MODIFY `cod_materia_helper` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tbMensagem`
--
ALTER TABLE `tbMensagem`
  MODIFY `cod_mensagem` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tbStatus`
--
ALTER TABLE `tbStatus`
  MODIFY `cod_status` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `tbTopico`
--
ALTER TABLE `tbTopico`
  MODIFY `cod_topico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `tbVideo`
--
ALTER TABLE `tbVideo`
  MODIFY `cod_video` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de tabela `tbView`
--
ALTER TABLE `tbView`
  MODIFY `cod_view` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  ADD CONSTRAINT `tbAjuda_ibfk_4` FOREIGN KEY (`cod_status`) REFERENCES `tbStatus` (`cod_status`);

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
