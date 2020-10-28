-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 28-Out-2020 às 04:27
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_student` (IN `id` INT)  NO SQL
BEGIN
IF EXISTS(SELECT * FROM tbEstudante WHERE cod_estudante = id) THEN
DELETE FROM tbEstudante WHERE cod_estudante = id;
ELSE
	CALL my_signal('Erro ao deletar! estudante não existe.'); 
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_estudante` (IN `id` INT, IN `name` VARCHAR(12), IN `surname` VARCHAR(12), IN `email` VARCHAR(30))  NO SQL
BEGIN
UPDATE tbEstudante 
	SET nome_estudante = name,
    sobrenome_estudante = surname,
    email_estudante = email
    WHERE cod_estudante = id;
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
(4, '4.png', 'Ana', 'Herley', 'Aninha_Harley123@gmail.com', 'f7c3bc1d808e04732adf679965ccc34ca7ae3441');

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

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbVideo`
--

CREATE TABLE `tbVideo` (
  `cod_video` int(11) NOT NULL,
  `url_video` varchar(40) NOT NULL,
  `titulo_video` varchar(40) NOT NULL,
  `descricao_video` varchar(500) DEFAULT NULL,
  `cod_topico` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tbView`
--

CREATE TABLE `tbView` (
  `cod_view` int(11) NOT NULL,
  `data_view` date NOT NULL,
  `cod_video` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
-- Estrutura para vista `vwEstudantes`
--
DROP TABLE IF EXISTS `vwEstudantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vwEstudantes`  AS  select `tbEstudante`.`cod_estudante` AS `code`,`tbEstudante`.`foto_estudante` AS `photo`,`tbEstudante`.`nome_estudante` AS `name`,`tbEstudante`.`sobrenome_estudante` AS `surname`,`tbEstudante`.`email_estudante` AS `email` from `tbEstudante` ;

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
  MODIFY `cod_estudante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `tbHelper`
--
ALTER TABLE `tbHelper`
  MODIFY `cod_helper` int(11) NOT NULL AUTO_INCREMENT;

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
  MODIFY `cod_topico` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tbVideo`
--
ALTER TABLE `tbVideo`
  MODIFY `cod_video` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tbView`
--
ALTER TABLE `tbView`
  MODIFY `cod_view` int(11) NOT NULL AUTO_INCREMENT;

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
