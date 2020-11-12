-- phpMyAdmin SQL Dump
-- version 5.0.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 12-Nov-2020 às 16:02
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
(3, 1, 3);

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  ADD PRIMARY KEY (`cod_materia_helper`),
  ADD KEY `cod_materia` (`cod_materia`),
  ADD KEY `cod_helper` (`cod_helper`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  MODIFY `cod_materia_helper` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `tbMateriaHelper`
--
ALTER TABLE `tbMateriaHelper`
  ADD CONSTRAINT `tbMateriaHelper_ibfk_1` FOREIGN KEY (`cod_materia`) REFERENCES `tbMateria` (`cod_materia`),
  ADD CONSTRAINT `tbMateriaHelper_ibfk_2` FOREIGN KEY (`cod_helper`) REFERENCES `tbHelper` (`cod_helper`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
