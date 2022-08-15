create database empresa;
use empresa;

create table ControledeVendas
	(
    id int not null primary key auto_increment,
	relatorios_empresariais varchar(200),
    balanco_mensal decimal(10,2),
    data_de_fechamento date
    );
    
create table Financeiro
	(
    id int not null primary key auto_increment,
    receita decimal(10,2) not null,
    deduçõesDeImpostos decimal(10,2) not null,
    gastosDiarios decimal(10,2) not null,
    relatorios varchar(200)
    );
    
create table Vendedor
	(
    id int not null primary key auto_increment,
    total_venda decimal(10,2) not null
    );
    
create table Produto
	(
    id int not null primary key auto_increment,
    Descrição varchar(200),
    Preço decimal(10,2) not null,
    Validade date
    );
    
create table produto_has_vendedor
	(
    Produto_id int not null,
    Vendedor_id int not null,
    primary key(Produto_id, Vendedor_id),
    foreign key(Produto_id) references Produto(id),
    foreign key(Vendedor_id) references Cliente(id)
    );

create table Cliente
	(
    id int not null primary key auto_increment,
    Nome varchar(45),
    cpf varchar(11) not null,
    data_de_nascimento date
    );
    
create table cliente_has_produto
	(
    Produto_id int not null,
    Cliente_id int not null,
    primary key(Produto_id, Cliente_id),
    foreign key(Produto_id) references Produto(id),
    foreign key(Cliente_id) references Cliente(id)
    );
    
insert into ControleDeVendas(relatorios_empresariais,
balanco_mensal, data_de_fechamento) values
	('O faturamento da empresa cresceu 20% este mês comparado ao último',
	33948493,'2022-06-30');

insert into Financeiro(receita, deduçõesDeImpostos,
gastosDiarios,relatorios) values
	(1000,10,30,'produtos de mercado'),
	(5000,20,50,'produtos de carro'),
	(10000,50,20,'produtos de cozinha');

insert into vendedor(total_venda) values
	(5000),(2000),(400);

insert into Produto(descrição,Preço,Validade) values
	('motor de carro',2000,'2024-04-10'),
	('cesta básica', 200,'2023-02-12'),
	('conjunto de cozinha',760,'2025-03-30');

insert into Cliente(Nome,cpf,data_de_nascimento) values
	('Daiane','38499309043','2002-04-22'),
	('Larissa','48992800938','1980-07-18'),
	('Everton','84493830092','1991-09-02');