CREATE TABLE tbMateria(
	cod_materia INT PRIMARY KEY AUTO_INCREMENT,
	nome_materia VARCHAR(30) NOT NULL
);


CREATE TABLE tbEstudante(
	cod_estudante INT PRIMARY KEY AUTO_INCREMENT,
	foto_estudante VARCHAR(30),
	nome_estudante VARCHAR(12) NOT NULL,
	sobrenome_estudante VARCHAR(12) NOT NULL,
	email_estudante VARCHAR(30) NOT NULL,
	senha_estudante VARCHAR(40) NOT NULL
);


CREATE TABLE tbHelper(
	cod_helper INT PRIMARY KEY AUTO_INCREMENT,
	foto_helper VARCHAR(30),
	nome_helper VARCHAR(12) NOT NULL,
	sobrenome_helper VARCHAR(12) NOT NULL,
	biografia_helper VARCHAR(140),
	email_helper VARCHAR(30) NOT NULL,
	senha_helper VARCHAR(40) NOT NULL
);


CREATE TABLE tbMateriaHelper(
	cod_materia_helper INT PRIMARY KEY AUTO_INCREMENT,
	cod_materia INT, 
	FOREIGN KEY (cod_materia) REFERENCES tbMateria(cod_materia),
	cod_helper INT, 
	FOREIGN KEY (cod_helper) REFERENCES tbHelper(cod_helper)
);


CREATE TABLE tbStatus(
	cod_status INT PRIMARY KEY AUTO_INCREMENT,
	nome_status VARCHAR(10) NOT NULL
); 

CREATE TABLE tbAjuda(
	cod_ajuda INT PRIMARY KEY AUTO_INCREMENT,
	titulo_ajuda VARCHAR(40) NOT NULL,
	descricao_ajuda VARCHAR(140),
	classificacao_ajuda INT,
	data_ajuda DATE NOT NULL,
	horario_ajuda TIME NOT NULL,
	local_ajuda VARCHAR(40) NOT NULL,
	cod_materia INT,
	cod_estudante INT,
	cod_helper INT, 
	cod_status INT,
	FOREIGN KEY (cod_materia) REFERENCES tbMateria(cod_materia),
	FOREIGN KEY (cod_estudante) REFERENCES tbEstudante(cod_estudante),
	FOREIGN KEY (cod_helper) REFERENCES tbHelper(cod_helper),
	FOREIGN KEY (cod_status) REFERENCES tbStatus(cod_status)
);


CREATE TABLE tbMensagem(
	cod_mensagem INT PRIMARY KEY AUTO_INCREMENT,
	texto_mensagem VARCHAR(5000) NOT NULL,
	data_mensagem DATE NOT NULL,
	horario_mensagem TIME NOT NULL,
	cod_estudante INT,
	cod_helper INT, 
	FOREIGN KEY (cod_estudante) REFERENCES tbEstudante(cod_estudante),
	FOREIGN KEY (cod_helper) REFERENCES tbHelper(cod_helper)
);


CREATE TABLE tbTopico(
	cod_topico INT PRIMARY KEY AUTO_INCREMENT,
	nome_topico VARCHAR(30) NOT NULL,
	icone_topico VARCHAR(40) NOT NULL,
	cod_materia INT,
	FOREIGN KEY (cod_materia) REFERENCES tbMateria(cod_materia)
);

CREATE TABLE tbVideo(
	cod_video INT PRIMARY KEY AUTO_INCREMENT,
	url_video VARCHAR(40) NOT NULL,
	titulo_video VARCHAR(40) NOT NULL,
	descricao_video VARCHAR(500),
	cod_topico INT,
	FOREIGN KEY (cod_topico) REFERENCES tbTopico(cod_topico)
);

CREATE TABLE tbView(
	cod_view INT PRIMARY KEY AUTO_INCREMENT,
	data_view DATE NOT NULL,
	cod_video INT,
	FOREIGN KEY (cod_video) REFERENCES tbVideo(cod_video)
);