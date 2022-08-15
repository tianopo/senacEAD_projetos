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
    foreign key(Produto_id) references Produto(id),
    foreign key(Vendedor_id) references Vendedor(id)
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

/*1.Ajuste questões de segurança, incluindo usuários, papéis e permissões.*/

create role 'desenvolvedor', 'equipe_geral','editor_banco';

grant all privileges on empresa to 'desenvolvedor';
grant select on empresa.* to 'equipe_geral';
grant insert,update,delete on empresa.* to 'editor_banco';
flush privileges;

show grants for 'desenvolvedor';
show grants for 'equipe_geral';
show grants for 'editor_banco';

create user 'supervisor'@'localhost';
create user 'equipe'@'localhost';
create user 'editores'@'localhost';

grant 'desenvolvedor' to 'supervisor'@'localhost';
grant 'equipe_geral' to 'equipe'@'localhost';
grant 'editor_banco' to 'editores'@'localhost';

SELECT * FROM mysql.user;
show grants for 'supervisor'@'localhost';
show grants for 'equipe'@'localhost';
show grants for 'editores'@'localhost';

/*2.Crie visões no banco de dados para consultas mais frequentes.*/

create view compra_produto 
as select c.Nome,p.Descrição,p.Preço from cliente c 
join produto p on c.id = p.id where p.Preço > 500;

create view produto_totalLiquido 
as select p.Descrição,p.Preço,v.total_venda
from produto p join vendedor v on p.id = v.id
where p.Descrição like 'c%';

select * from compra_produto;
select * from produto_totalLiquido;

/*3.Crie ao menos uma stored function, um stored procedure ou um trigger 
para o banco de dados, selecionando uma funcionalidade que seja adequada para tanto.*/

delimiter //
create procedure procedure_venda(p_descricao varchar(100))
begin
	declare p_description varchar(100);
    declare p_preco int;
	
    select Descrição,Preço into p_description, p_preco
    from produto_totalLiquido
    where Descrição = p_descricao;
    
    if p_descricao = 'conjunto de cozinha' then
		select p_descricao,p_preco from produto_totalLiquido
        where p_descricao like 'con%';
	else
		select * from produto_totalLiquido;
	end if;
end //
delimiter ;
drop procedure nome;
call procedure_venda ('conjunto de coz');
call procedure_venda ('conjunto de cozinha');

/*4.Crie ao menos um índice composto para uma das tabelas.*/


create index idx_view_produto on produto(Descrição);

explain select * from produto_totalLiquido;

explain select p.Descrição,p.Preço,v.total_venda
from produto p join vendedor v on p.id = v.id
where p.Descrição like 'c%';

create index idx_view_compra on produto(Preço);

explain select c.Nome,p.Descrição,p.Preço from cliente c 
join produto p on c.id = p.id where p.Preço > 500;

explain select * from compra_produto;

/*5.Descreva textualmente uma rotina de administração de banco de dados, 
prevendo backups, restore e checagem de integridade periódica.*/

/*
Primeiramente, criaria uma pasta onde seria receido o nome do arquivo de 
backup através de um script bash: FILE=banco_empresa.`2022-08-04 +"%Y%m%d"`
com o endereo de IP(DBSERVER=127.0.0.1), host(localhost) e nome do 
banco de dados(DATABASE=database-name). 
Teria de inserir um usuário de base de dados que não fosse 'root' por questão 
de segurança e incluiria no Bash (USER=user-name) com uma senha (PASS= dj4lk3).
Reforçaria se já existe algum arquivo de mesmo nome:
unalias rm 2> /envio/backup/mysql

rm ${banco_empresa.sql} 2> /envio/backup/mysql
rm ${banco_empresa.sql}.gz 2> /envio/backup/mysql

Executaria o mysqldumb para executar o backup:
mysqldump --opt --user=${gerente} --password=${'dj4lk3'} ${empresa} > ${banco_empresa.sql}

transform em arquivo gzip:
gzip $banco_empresa.sql

Listo o arquivo criado:
ls -l ${banco_empresa.sql}.gz

salvo o arquivo com o nome de 'empresa-backup.sh.

Crio a pasta:
mkdir -p /backup/mysql

Dou permissão de execuçao dentro da pasta:
chmod +x /backup/mysql/empresa-backup.sh

Faço um processo automatizado para que todos os dias às 
8 da manhã seja executado o script para backup:

crontab -e

8 1 * * * /envio/backup/mysql/banco_empresa.sql 1>> /var/log/empresa-backup.log 2>>/var/log/empresa-backup-error.log
*/





