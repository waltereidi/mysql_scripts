BEGIN

########################################
##### LAST UPDATE 10/06/2017 - 11:08
##Walter Eidi Matsuda:::
##########################################

DECLARE `int1` ,`i` , `_count` , `_freq`,`_arrumeitor` INT DEFAULT 0 ;
DECLARE `vchar1` ,`table`,`execpath`,`logoutput` VARCHAR(1024);
#########################################################################
### Querys Padrão (Unnalocated) [Modelo Comentado]
#########################################################################
SET @execpath='walter_procedures';
SET @logoutput='wcm_temp_resource';
#Nome do banco onde o log da procedure será gravado com o nome da tabela gravada.
/* 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA =",indb," AND table_name=",`table`," AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;

SET @sqlstr= (SELECT CONCAT("
SELECT MAX(",@p1,") INTO @return FROM '",indb,table"' WHERE imp_tbl='",`table`,"' ; 
"));PREPARE GetMax FROM @sqlstr; 

*/

###########################################################
####### Pos Procedure ##
#As querys abaixo criam logs
###########################################################

INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 22 ,`table`);
SET @return = NULL ; 
SELECT table_name INTO @return FROM information_schema.tables WHERE table_schema=@execpath AND table_name=@logoutput; 
IF @return <>'' AND @return IS NOT NULL THEN 
SET @table_create=CONCAT(@logoutput,'_0');
SET @counter = 0 ;


WHILE ((SELECT table_name FROM information_schema.tables WHERE table_schema=@execpath AND table_name=@table_create)<>'') OR(
(SELECT table_name FROM information_schema.tables WHERE table_schema=@execpath AND table_name=@table_create) IS NOT NULL) DO 
SET @table_create=REPLACE(@table_create,@counter,@counter:=@counter+1);
END WHILE ;
#Verifica nome adicional para a tabela já existente , e renomeia com o próximo número.


SET @sqlstr=(SELECT CONCAT("RENAME TABLE ",@logoutput," TO ",@table_create,";"));
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
END IF;
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 39 ,`table`);

DROP TABLE IF EXISTS `wcm_temp_resource`;
CREATE TABLE `wcm_temp_resource` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`wcm_table` CHAR(128) NULL DEFAULT NULL,
`wcm_table_index` VARCHAR(128) NULL DEFAULT NULL,
`wcm_archive_table` VARCHAR(128) NULL DEFAULT NULL,
`wcm_archive_table_index` VARCHAR(128) NULL DEFAULT NULL,
`wbc_table_equiv` VARCHAR(128) NULL DEFAULT NULL,
`wbc_table_equiv_index` VARCHAR(128) NULL DEFAULT NULL,
`wbc_archive_table` VARCHAR(128) NULL DEFAULT NULL,
`wbc_archive_table_index` VARCHAR(128) NULL DEFAULT NULL,
`Obs` TEXT NULL,
`Last_Index` TEXT NULL,
`data_exec` DATETIME NULL,
`state` TEXT NULL,
PRIMARY KEY (`id`)
)
COLLATE='latin1_swedish_ci'
ENGINE=MyISAM
;




##################################################################################
### Politicos
##################################################################################

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_profissoes ( `pro_descricao` , `pro_atualizado_online` ) 
SELECT Profissao,1 FROM ",outdb,"politico AS a 
WHERE a.profissao IS NOT NULL AND a.profissao<>'' GROUP BY a.profissao ;" ));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_enderecos ( end_descricao ,end_atualizado_online )
(SELECT endereco ,1 FROM ",outdb,"politico AS a 
WHERE a.endereco IS NOT NULL AND a.endereco<>'' GROUP BY a.endereco )
UNION
(SELECT Endereco_Comercial, 1 FROM ",outdb,"politico AS a 
WHERE a.Endereco_Comercial IS NOT NULL AND a.Endereco_Comercial<>'' AND a.Endereco_Comercial<>a.endereco GROUP BY a.Endereco_Comercial )
")) ;
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_ceps (cep_numero ,cep_atualizado_online )
(SELECT cep ,1 FROM ",outdb,"politico AS a 

WHERE a.cep IS NOT NULL AND a.cep<>'' GROUP BY a.cep )
UNION
(SELECT cep, 1 FROM ",outdb,"politico AS a 

WHERE a.cep_Comercial IS NOT NULL AND a.cep_Comercial<>'' AND a.cep_Comercial<>a.cep GROUP BY a.CEP_Comercial )
")) ;
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_bairros ( bai_descricao , bai_atualizado_online ) 
SELECT a.nome ,1
FROM ",outdb,"bairro AS a
WHERE a.nome IS NOT NULL AND a.nome<>'' AND a.nome<>' ' ")) ;
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_escolaridades` (`esc_atualizado_online`, `esc_descricao`)
SELECT 1 , Escolaridade FROM ",outdb,"politico 
WHERE escolaridade IS NOT NULL AND escolaridade<>'' AND escolaridade<>' ' GROUP BY escolaridade
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;
/*
SET @sqlstr=(SELECT CONCAT( "ALTER TABLE ",indb,"`wcm_parlamentares` ADD COLUMN `imp_index` INT NOT NULL ; "));
PREPARE stmt FROM @sqlstr;EXECUTE stmt ; DEALLOCATE PREPARE stmt ;
INSERT INTO registro_tabelas ( _table , _column , _data_base ,_host_name , _command_line , _oper ) VALUES ( "wcm_parlamentares" , "imp_index" , REPLACE(indb , '.','') , @@hostname , @sqlstr , 'Inclui index da tabela politico importada');
*/

SET @sqlstr =(SELECT CONCAT("
INSERT INTO ",indb,"wcm_parlamentares( 
`par_nome`, `par_apelido`, `par_carteira_habilitacao`, 
`par_carteira_profissional`, `par_cpf`, `par_data_emissao_rg`, `par_data_emissao_te`, 
`par_data_falecimento`, `par_data_nascimento`, `par_naturalidade`, `par_pis`, 
`par_reservista`, `par_rg`, `par_secao_eleitoral`, `par_sexo`, 
`par_titulo_eleitoral`, `par_zona_eleitoral`, `par_primeiro_partido`, `par_tratamentos_id_fk`, 
`par_historia`, `par_atualizado_online`, `par_mostra_online`, 
imp_index)
SELECT 
a.nome , a.Apelido , a.Carteira_Habilitacao , 
Carteira_Profissional , a.cpf , a.Data_Emissao_RG , a.Data_Emissao_TE ,
a.Data_Falecimento , a.Data_Nascimento , a.Naturalidade , a.Numero_PIS , 
a.Reservista , a.rg , a.secao , if( sexo ='f' , 1 , 0 ) , 
a.Titulo_eleitoral , a.zona , NULL ,if(sexo='f' , 2 , 1) , 
a.Historia , 1 , 1, 
a.codigo 
FROM ",outdb,"politico AS a 
GROUP BY a.codigo ;"));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indba,"`wcm_fotos_parlamentares` (
`fot_par_imagem`, `fot_par_parlamentares_id_fk`, `fot_par_creditos`, `fot_par_atualizado_online`, 
`fot_par_mostra_online`) 
SELECT a.arquivo_foto , b.par_id , '' , 1 , 1 
FROM ",outdb,"politico AS a
INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index =a.codigo 
WHERE a.arquivo_foto IS NOT NULL ;"
));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_telefones ( `tel_atualizado_online`, `tel_descricao`, `tel_id_fk_tabela_pertencente`, `tel_numero`, `tel_ramal` , `tel_tipo_tabela_pertencente` ) 

(SELECT 1, CONCAT('Telefone Comercial do parlamentar ',a.nome ) ,1, a.telefone_comercial, '', b.par_id FROM ",outdb,"politico AS a INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index=a.codigo WHERE telefone_comercial IS NOT NULL AND telefone_comercial <>'' AND telefone_comercial<>' ' GROUP BY telefone_comercial )
UNION
(SELECT 1, CONCAT('Telefone Celular do parlamentar ',a.nome ) ,1, a.telefone_celular, '', b.par_id FROM ",outdb,"politico AS a INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index=a.codigo WHERE telefone_celular IS NOT NULL AND telefone_celular <>'' AND telefone_celular<>' ' GROUP BY telefone_celular)
UNION
(SELECT 1 ,CONCAT('Telefone Fax do parlamentar ',a.nome ) ,1, a.Telefone_Fax, '', b.par_id FROM ",outdb,"politico AS a INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index=a.codigo WHERE telefone_fax IS NOT NULL AND Telefone_Fax <>'' AND telefone_fax<>' ' GROUP BY telefone_fax)
UNION
(SELECT 1, CONCAT('Telefone Residencial do parlamentar ',a.nome ) ,1, a.telefone_residencial,'', b.par_id FROM ",outdb,"politico AS a INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index=a.codigo WHERE telefone_residencial IS NOT NULL AND telefone_residencial <>'' AND telefone_residencial<>' ' GROUP BY telefone_residencial )
UNION
(SELECT 1, CONCAT('Telefone Gabinete do parlamentar ',a.nome ) ,1, a.telefone_gabinete , '', b.par_id FROM ",outdb,"politico AS a INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index=a.codigo WHERE telefone_gabinete IS NOT NULL AND Telefone_Gabinete <>'' AND telefone_gabinete<>' ' GROUP BY telefone_gabinete )
UNION
(SELECT 1, tipo_telefone ,9, numero ,'', NULL FROM ",outdb,"telefone ) ")) ;

PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_emails (
`ema_atualizado_online`, `ema_descricao`, `ema_email`, `ema_id_fk_tabela_pertencente`, 
`ema_tipo_tabela_pertencente`) 
SELECT
1 ,CONCAT('email do parlamentar ',a.nome) , a.email , 1 , b.par_id FROM ",outdb,"politico AS a 
INNER JOIN ",indb,"wcm_parlamentares AS b ON a.codigo = b.imp_index WHERE a.email IS NOT NULL AND a.email <>'' AND a.email <>' ' GROUP BY a.email 
")) ;
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt ;

SET @ret1 = NULL;
SET @sqlstr=(SELECT CONCAT( "SELECT car_id INTO @ret1 FROM ",indb,"wcm_cargos WHERE car_descricao ='PREFEITO' LIMIT 1 ; "));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
IF @ret1 IS NULL THEN
SET @sqlstr=(SELECT CONCAT( "INSERT INTO ",indb,"wcm_cargos (car_descricao , car_atualizado_online , car_ordem_exibicao) VALUES
( 'PREFEITO' , 1 , 1 ); "));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
END IF ;
SET @sqlstr= (SELECT CONCAT( "SELECT car_id INTO @ret1 FROM ",indb,"wcm_cargos WHERE car_descricao ='VICE-PREFEITO' LIMIT 1 ; "));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
IF @ret1 IS NULL THEN
SET @sqlstr=(SELECT CONCAT( "INSERT INTO ",indb,"wcm_cargos (car_descricao , car_atualizado_online , car_ordem_exibicao) VALUES
( 'VICE-PREFEITO' , 1 , 1 ); "));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
END IF ;
SET @sqlstr = (SELECT CONCAT("INSERT INTO ",indb,"`wcm_legislaturas` ( `leg_descricao`, `leg_sigla`, `leg_data_inicio`, 
`leg_data_fim`, `leg_mostra_online`, `leg_atualizado_online`)
SELECT nome ,sigla , Data_Inicial , data_final , 1 ,1 
FROM ",outdb,"legislatura;
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_legislaturas_executivos (
`leg_exe_data_hora_inicio`, `leg_exe_data_hora_fim`,
`leg_exe_voto`, `leg_exe_legislaturas_id_fk`, `leg_exe_atualizado_online`,
`leg_exe_cargos_id_fk`, `leg_exe_parlamentares_id_fk`, `leg_exe_partidos_id_fk`
)SELECT a.Data_Inicial , a.Data_Final,
REPLACE(REPLACE(a.votos,'.',''),',',''), c.leg_id , 1 ,d.car_id , b.par_id , if(f.par_id IS NULL ,(SELECT par_id FROM ",indb,"wcm_partidos WHERE par_sigla ='N/A') , f.par_id ) 

FROM ",outdb,"legislatura AS a
INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index = a.cod_prefeito_politico
INNER JOIN ",indb,"wcm_legislaturas AS c ON YEAR(a.Data_Inicial)=YEAR(c.leg_Data_Inicio) 
INNER JOIN ",indb,"wcm_cargos AS d ON d.car_descricao ='PREFEITO'
LEFT JOIN ",outdb,"partido AS e ON e.codigo = a.codigo_partido 
LEFT JOIN ",indb,"wcm_partidos AS f ON f.par_sigla = e.nome 
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_legislaturas_executivos (
`leg_exe_data_hora_inicio`, `leg_exe_data_hora_fim`,
`leg_exe_voto`, `leg_exe_legislaturas_id_fk`, `leg_exe_atualizado_online`,
`leg_exe_cargos_id_fk`, `leg_exe_parlamentares_id_fk`, `leg_exe_partidos_id_fk`
)SELECT a.Data_Inicial , a.Data_Final,
REPLACE(REPLACE(a.votos,'.',''),',','') , c.leg_id , 1 ,
d.car_id , b.par_id , if(f.par_id IS NULL , (SELECT par_id FROM ",indb,"wcm_partidos WHERE par_sigla ='N/A') , f.par_id )
FROM ",outdb,"legislatura AS a
INNER JOIN ",indb,"wcm_parlamentares AS b ON b.imp_index = a.Cod_Vice_POLITICO
INNER JOIN ",indb,"wcm_legislaturas AS c ON YEAR(a.Data_Inicial)=YEAR(c.leg_Data_Inicio) 
INNER JOIN ",indb,"wcm_cargos AS d ON d.car_descricao ='VICE-PREFEITO'
LEFT JOIN ",outdb,"partido AS e ON e.codigo = a.codigo_partido 
LEFT JOIN ",indb,"wcm_partidos AS f ON f.par_sigla = e.nome 
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
/*
SET @sqlstr=(SELECT CONCAT( "ALTER TABLE ",indb,"`wcm_mesas_diretoras` ADD COLUMN `imp_index` INT NOT NULL ; "));
PREPARE stmt FROM @sqlstr;EXECUTE stmt ; DEALLOCATE PREPARE stmt ;
INSERT INTO registro_tabelas ( _table , _column , _data_base ,_host_name , _command_line , _oper ) VALUES 
( "wcm_meesas_diretoras" , "imp_index" , REPLACE(indb , '.','') , @@hostname , @sqlstr , 'Deixa guardado o Index da tabela recebida ');

*/
SET @sqlstr =(SELECT CONCAT("
INSERT INTO ",indb,"wcm_mesas_diretoras(
`mes_dir_descricao`,`mes_dir_legislaturas_id_fk`,`mes_dir_data_inicio`,
`mes_dir_sigla`,`mes_dir_periodo`, `mes_dir_data_fim`, 
`mes_dir_situacao`, `mes_dir_observacao`, `mes_dir_atualizado_online`, `mes_dir_bienio` , imp_index)
SELECT a.`nome`, c.leg_id, a.`data_inicio`,
a.`sigla` ,a.`bienio`,a.`data_fim` ,
a.`situacao`,a.`Observacoes`,1 ,if( TIMESTAMPDIFF(day ,a.`data_fim` , a.`data_inicio` ) >366 , 'BIENIO' , 'ANUÊNIO' ) , a.codigo 
FROM ",outdb,"mesa AS a 
INNER JOIN ",indb,"wcm_legislaturas AS c ON YEAR(a.data_inicio) BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) "));
PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;


SET @sqlstr =(SELECT CONCAT("
INSERT INTO ",indb,"wcm_legislativos (
`leg_data_hora_inicio`,`leg_data_hora_fim`,`leg_voto`,`leg_legislaturas_id_fk`,
`leg_cargos_id_fk`,`leg_parlamentares_id_fk`,`leg_partidos_id_fk`, `leg_atualizado_online` )	
SELECT
b.leg_data_inicio , b.leg_data_fim , if(a.Votos_Eleicao IS NULL , 0 , CAST(REPLACE(REPLACE(a.votos_eleicao , '.',''),',','') AS UNSIGNED )) , b.leg_id , 
cg.car_id , e.par_id , if(ptd.par_id IS NULL ,(SELECT par_id FROM ",indb,"wcm_partidos WHERE par_sigla ='N/A') , ptd.par_id ) , 1 
FROM ",outdb,"vereador_legislatura as a 
INNER JOIN ",outdb,"legislatura AS c ON a.codigo_legislatura = c.codigo 
INNER JOIN ",indb,"wcm_legislaturas AS b ON b.leg_data_inicio= c.data_inicial 
INNER JOIN ",indb,"wcm_parlamentares AS e ON e.imp_index = a.codigo_politico
LEFT JOIN ",outdb,"mesa_legislatura AS d ON d.codigo_legislatura = c.codigo AND d.codigo_politico =e.imp_index
LEFT JOIN ",indb,"wcm_cargos AS cg ON cg.car_descricao = d.cargo 
LEFT JOIN ",outdb,"partido AS pd ON pd.codigo = a.codigo_partido 
LEFT JOIN ",indb,"wcm_partidos AS ptd ON ptd.par_sigla = pd.nome 
WHERE a.Codigo_POLITICO >0 
GROUP BY a.Codigo ;
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_cargos` (`car_descricao`, `car_atualizado_online`, `car_ordem_exibicao`)
SELECT a.cargo, 1, 1
FROM ",outdb,"mesa_legislatura AS a 
LEFT JOIN ",indb,"wcm_cargos AS b ON b.car_descricao = a.cargo
WHERE b.car_id IS NULL AND a.cargo IS NOT NULL GROUP BY a.cargo;
"));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;
SET @sqlstr =
(SELECT CONCAT( "INSERT INTO ",indb,"wcm_mesas_membros (
`mes_mem_atualizado_online` , `mes_mem_cargo_id_fk`,
`mes_mem_parlamentares_id_fk`,`mes_mem_mesas_diretoras_id_fk`
)SELECT 
1 ,b.car_id , c.par_id , n.mes_dir_id
FROM ",outdb,"mesa_legislatura AS a 
INNER JOIN ",indb,"wcm_cargos AS b ON b.car_descricao= a.cargo 
INNER JOIN ",indb,"wcm_parlamentares AS c ON a.codigo_politico = c.imp_index
INNER JOIN ",outdb,"mesa AS m ON m.codigo = a.codigo_mesa 
INNER JOIN ",indb,"wcm_mesas_diretoras AS n ON YEAR(n.mes_dir_data_inicio )= YEAR(m.Data_Inicio )
; "));PREPARE stmt FROM @sqlstr; EXECUTE stmt ; DEALLOCATE PREPARE stmt;

SET @sqlstr = (SELECT CONCAT(
"INSERT INTO ",indb,"wcm_comissoes_permanentes (
`com_per_descricao`, `com_per_sigla`, `com_per_periodo`, 
`com_per_ano`, `com_per_data_inicio`, `com_per_data_fim`, `com_per_situacao`, 
`com_per_observacao`, `com_per_atualizado_internet`, `com_per_atribuicoes`, `com_per_legislaturas_id_fk`
)SELECT a.nome , a.sigla , a.periodo , a.ano , a.Data_Inicial , a.Data_Final ,a.Situacao, a.Observacoes,
1 , a.Atribuicao , b.leg_id 
FROM ",outdb,"comissao AS a 
INNER JOIN ",outdb,"legislatura AS l ON l.codigo = a.Codigo_LEGISLATURA 
INNER JOIN ",indb,"wcm_legislaturas AS b ON b.leg_data_inicio = l.Data_Inicial "));
PREPARE stmt FROM @sqlstr;
EXECUTE stmt ;DEALLOCATE PREPARE stmt ;
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_cargos (car_descricao , car_atualizado_online , car_ordem_exibicao )
SELECT 
a.cargo , 1 , 1 FROM ",outdb,"comissao_legislatura AS a 
LEFT JOIN ",indb,"wcm_cargos AS b ON b.car_descricao=a.cargo 
WHERE cargo IS NOT NULL AND cargo<>'' AND cargo<>' ' AND b.car_id IS NULL GROUP BY Cargo "));
PREPARE stmt FROM @sqlstr;
EXECUTE stmt ;DEALLOCATE PREPARE stmt ;
SET @sqlstr = (SELECT CONCAT(
"INSERT INTO ",indb,"wcm_comissoes_permanentes_membros (
`com_per_mem_cargos_id_fk`, `com_per_mem_parlamentares_id_fk`,`com_per_mem_comissoes_permanentes_id_fk`, `com_per_mem_atualizado_internet`)
SELECT b.car_id , p2.par_id , cmp.com_per_id , 1 
FROM ",outdb,"comissao_legislatura AS a 
INNER JOIN ",indb,"wcm_cargos AS b ON b.car_descricao = a.cargo 
INNER JOIN ",outdb,"politico AS p ON p.codigo = a.codigo_politico
INNER JOIN ",indb,"wcm_parlamentares AS p2 ON p.nome = p2.par_nome 
INNER JOIN ",outdb,"comissao AS cm ON cm.codigo = a.Codigo_COMISSAO
INNER JOIN ",indb,"wcm_comissoes_permanentes AS cmp ON cm.nome =cmp.com_per_descricao AND cmp.com_per_ano = cm.ano 
INNER JOIN ",outdb,"legislatura AS leg ON leg.codigo = a.Codigo_LEGISLATURA 
INNER JOIN ",indb,"wcm_legislaturas AS wleg ON YEAR(wleg.leg_data_inicio) = YEAR(leg.data_inicial) AND cmp.com_per_legislaturas_id_fk = wleg.leg_id
GROUP BY a.codigo 
;"
) );
PREPARE stmt FROM @sqlstr;
EXECUTE stmt ;
DEALLOCATE PREPARE stmt ;
SET @_id = NULL;
SET @sqlstr =(SELECT CONCAT("SELECT par_id INTO @_id FROM ",indb,"wcm_partidos WHERE par_nome ='Sem Partido';"));PREPARE _get_partido FROM @sqlstr;
EXECUTE _get_partido ;
IF @_id IS NULL THEN
SET @sqlstr =(SELECT CONCAT("INSERT INTO ",indb,"wcm_partidos (par_sigla, par_nome ) VALUES ( 'N/A' , 'Sem Partido'); "));PREPARE stmt FROM @sqlstr;EXECUTE stmt ;DEALLOCATE PREPARE stmt ;
EXECUTE _get_partido ;
END IF;
DEALLOCATE PREPARE _get_partido ;

SET @sqlstr =(SELECT CONCAT ( "
INSERT INTO ",indb,"`wcm_suplentes_vereadores` (
`sup_ver_legislaturas_id_fk`, `sup_ver_data_hora_inicio`, `sup_ver_data_hora_fim`, 
`sup_ver_voto`, `sup_ver_motivo`, `sup_ver_atualizado_online`, `sup_ver_mostra_online`, 
`sup_ver_partidos_id_fk`, `sup_ver_cargo_id_fk`, `sup_ver_parlamentar_substituto_id_fk`, `sup_ver_parlamentar_substituido_id_fk`, 
`sup_ver_situacoes_id_fk`)
SELECT c.leg_id , a.inicio , a.termino ,
a.votos , a.Motivo_Suplencia , 1 , 1 , 
if(h.leg_partidos_id_fk IS NULL , @_id ,h.leg_partidos_id_fk ) , h.leg_cargos_id_fk , g.par_id , e.par_id , 
NULL 
FROM ",outdb,"suplente AS a 
INNER JOIN ",outdb,"legislatura AS b ON a.Cod_Legislatura = b.codigo 
INNER JOIN ",indb,"wcm_legislaturas AS c ON YEAR(b.data_inicial) = YEAR(c.leg_data_inicio) 
INNER JOIN ",outdb,"politico AS d ON d.codigo = a.Codigo_POLITICO 
INNER JOIN ",indb,"wcm_parlamentares AS e ON d.nome = e.par_nome 
INNER JOIN ",outdb,"politico AS f ON f.codigo = a.Codigo_POLITICO_SUB
INNER JOIN ",indb,"wcm_parlamentares AS g ON f.nome = g.par_nome 
LEFT JOIN ",indb,"wcm_legislativos AS h ON h.leg_legislaturas_id_fk = c.leg_id AND h.leg_parlamentares_id_fk = e.par_id ;	" ) );
PREPARE stmt FROM @sqlstr;EXECUTE stmt ;DEALLOCATE PREPARE stmt ;

######################################################################### 
### Informação 1<->*
#########################################################################
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 69 ,`table`);
SET @sqlstr = (SELECT CONCAT( "INSERT INTO ",indb,"`wcm_regimes_tramitacoes` (
`reg_tra_descricao`, `reg_tra_quantidade_dias`, `reg_tra_ativo`, `reg_tra_atualizado_online`) 
SELECT a.regime_tramitacao , NULL , 1 , 1 FROM ",outdb,"projeto AS a 
LEFT JOIN ",indb,"wcm_regimes_tramitacoes AS b ON b.reg_tra_descricao=a.regime_tramitacao
WHERE b.reg_tra_id IS NULL AND TRIM(a.regime_tramitacao) <>'' GROUP BY regime_tramitacao ;
" ) );
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 76 ,`table`);
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
SET @sqlstr = (SELECT CONCAT(
"INSERT INTO ",indb,"`wcm_tramitacoes` (
`tra_descricao`, `tra_atualizado_online`, `tra_exibir_wcm_documentos`,
`tra_exibir_wfx_processos`)
SELECT a.descricao , 1 , 1 , 1 
FROM ",outdb,"situacao_tramitacao AS a
LEFT JOIN ",indb,"`wcm_tramitacoes` AS b ON a.descricao = b.tra_descricao 
WHERE b.tra_id IS NULL AND TRIM(a.descricao) <>'' ;
"));
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 87 ,`table`);
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
SET @sqlstr=(SELECT CONCAT("INSERT INTO ",indb,"`wcm_iniciativas` ( `ini_descricao`, `ini_atualizado_online`) 
SELECT a.iniciativa , 1 FROM ",outdb,"projeto AS a 
LEFT JOIN ",indb,"`wcm_iniciativas` AS b ON a.iniciativa = b.ini_descricao
WHERE b.ini_id IS NULL AND TRIM(a.iniciativa) <>'' GROUP BY a.iniciativa; 
"));
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 94 ,`table`);
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;


SET @sqlstr=(SELECT CONCAT("INSERT INTO ",indb,"`wcm_processos_votacoes` (`pro_vot_descricao`, `pro_vot_atualizado_online`) 
SELECT a.processo_votacao , 1 FROM ",outdb,"projeto AS a 
LEFT JOIN ",indb,"`wcm_processos_votacoes` AS b ON a.processo_votacao = b.pro_vot_descricao
WHERE b.pro_vot_id IS NULL AND TRIM(a.processo_votacao) <>'' GROUP BY a.processo_votacao; 
"));
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter , 103 ,`table`);
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;



SET @sqlstr=(SELECT CONCAT("INSERT INTO ",indb,"`wcm_tipos_quoruns` ( `tip_quo_descricao`, `tip_quo_atualizado_id_fk`)
SELECT a.quorum, 1 FROM ",outdb,"projeto AS a 
LEFT JOIN ",indb,"wcm_tipos_quoruns AS b ON a.quorum = b.tip_quo_descricao
WHERE b.tip_quo_id IS NULL AND TRIM(a.quorum) <>'' GROUP BY a.quorum; 
"));
INSERT INTO debugger(col1,col2,col3,col4) VALUES (@sqlstr , @counter ,113 ,`table`);
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

########################################################
#### Sessões #
SET `table`='sessao';
SELECT `table`;
########################################################

SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_sessoes; ; 
"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;


SET @sqlstr = (SELECT CONCAT ("INSERT INTO ",indb,"wcm_tipos_sessoes 
(`tip_ses_descricao`, `tip_ses_ativo`, `tip_ses_atualizado_online`)
SELECT a.nome_tipo_sessao , 1 , 1 
FROM ",outdb,"Tipo_Sessao AS a
LEFT JOIN ",indb,"wcm_tipos_sessoes AS b ON a.nome_tipo_sessao=b.tip_ses_descricao
WHERE b.tip_ses_id IS NULL;"));
PREPARE stmt FROM @sqlstr;EXECUTE stmt ;DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT ("
INSERT INTO ",indb,"`wcm_sessoes` (
`ses_nome`, `ses_codigo_individual`, `ses_formato_numero_codigo_individual_id_fk`, 
`ses_data_hora_sessao`, `ses_data_hora_limite_protocolo`, `ses_observacao`, `ses_atualizado_online`, 
`ses_mostra_online`, `ses_tipos_sessoes_id_fk`, `ses_finalizado_turno_ordem_dia`, `ses_finalizado_turno_expediente` , imp_index,imp_tbl)
SELECT a.nome , a.Codigo_Individual , 3 , 
CONCAT(a.Data ,' ', a.Hora) ,CONCAT (a.Data_Limite_Sessao_Protocolo_Internet ,' ' , a.Hora_Limite_Sessao_Protocolo_Internet) ,a.observacao, 1 ,
1 , c.tip_ses_id , 1 ,1, a.codigo , 'Sessao'
FROM ",outdb,"sessao AS a 
LEFT JOIN ",outdb,"Tipo_Sessao AS b ON b.codigo = a.tipo 
LEFT JOIN ",indb,"wcm_tipos_sessoes AS c ON c.tip_ses_descricao = b.nome_tipo_sessao
",IF(@return IS NOT NULL AND @return>0, CONCAT('WHERE a.',vchar1,'>',@return),''),";")) ;
# 0=Sessoes 1= Ordem Dia 2=Pauta da Sessao 3=Atas das Sessoes
PREPARE stmt FROM @sqlstr;EXECUTE stmt;DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT ("
INSERT INTO ",indb,"`wcm_sessoes` (
`ses_nome`, `ses_codigo_individual`, `ses_formato_numero_codigo_individual_id_fk`, 
`ses_data_hora_sessao`, `ses_data_hora_limite_protocolo`, `ses_observacao`, `ses_atualizado_online`, 
`ses_mostra_online`, `ses_tipos_sessoes_id_fk`, `ses_finalizado_turno_ordem_dia`, `ses_finalizado_turno_expediente` , imp_index, imp_tbl)
SELECT a.numero_ata , a.Codigo_Individual , 2 , 
a.data_sessao ,NULL ,a.descricao, 1 ,
1 , IF(b.tip_ses_id IS NOT NULL , b.tip_ses_id , 1) , 1 ,1, a.codigo , 'Ata Sessao'
FROM ",outdb,"ata_sessao AS a 
LEFT JOIN ",indb,"wcm_tipos_sessoes AS b ON b.tip_ses_descricao = a.Tipo_Sessao
LEFT JOIN ",indb,"wcm_sessoes AS c ON c.imp_index = a.codigo 
WHERE c.ses_id IS NULL ;
"));PREPARE stmt FROM @sqlstr;EXECUTE stmt;DEALLOCATE PREPARE stmt ;
########################################################
#### Atas Sessões #
SET `table`='ata_sessao';
SELECT `table`;
########################################################

SET @sqlstr= (SELECT CONCAT ( "INSERT INTO ",indb,"`wcm_atas_sessoes` (
`ata_ses_data_ata`, `ata_ses_codigo_individual`, `ata_ses_formato_numero_codigo_individual_id_fk`, 
`ata_ses_descricao`, `ata_ses_retificacao`, `ata_ses_data_aprovacao`, `ata_ses_data_atualizacao`, 
`ata_ses_data_afixacao`, `ata_ses_processos`, `ata_ses_mostra_online`, `ata_ses_atualizado_online`, 
`ata_ses_mesas_diretoras_id_fk`, `ata_ses_sessoes_id_fk`, imp_index )
SELECT a.Data_Afixacao,a.Codigo_Individual, 2 ,
CONCAT('Ata da ',a.Descricao) , a.Retificacao , a.Data_Afixacao ,a.Data_Aprovacao , 
a.Data_Afixacao , 0 , 1 , 1 ,
e.mes_dir_id , c.ses_id ,a.codigo 
FROM ",outdb,"ata_sessao AS a 
LEFT JOIN ",outdb,"sessao AS b ON b.codigo = a.Codigo_sessao 
LEFT JOIN ",indb,"wcm_sessoes AS c ON c.imp_index=IF(c.imp_tbl='Sessao' ,b.codigo, a.codigo)
LEFT JOIN ",outdb,"mesa AS d ON d.codigo = a.Codigo_MESA 
LEFT JOIN ",indb,"wcm_mesas_diretoras AS e ON e.mes_dir_data_inicio = d.data_inicio 
")); 
PREPARE stmt FROM @sqlstr;EXECUTE stmt;DEALLOCATE PREPARE stmt ;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"wcm_frequencias_parlamentares (
`fre_par_observacao`, `fre_par_descricao_justificativa`, `fre_par_situacoes_id_fk`, 
`fre_par_parlamentares_id_fk`, `fre_par_sessoes_id_fk`)
SELECT a.observacao , a.Descricao_Justificativa , b.sit_id ,
d.par_id , f.ses_id 
FROM ",outdb,"frequencia_vereadores_sessao AS a 
INNER JOIN ",indb,"wcm_situacoes AS b ON b.sit_descricao = a.Situacao 
INNER JOIN ",outdb,"politico AS c ON c.codigo = a.codigo_politico OR a.Nome_Politico = c.Nome
INNER JOIN ",indb,"wcm_parlamentares AS d ON d.par_nome = c.nome 
INNER JOIN ",outdb,"sessao AS e ON a.Codigo_Sessao = e.codigo
INNER JOIN ",indb,"wcm_sessoes AS f ON f.imp_index=a.Codigo_sessao 
GROUP BY a.codigo " ) );
PREPARE stmt FROM @sqlstr;EXECUTE stmt;DEALLOCATE PREPARE stmt ;






########################################################
#### projeto#
SET `table`='projeto';
SELECT `table`;
########################################################

SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ; 
"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;

INSERT INTO `wcm_temp_resource` (`wcm_table`, `wcm_table_index`, `wcm_archive_table`, `wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, `wbc_archive_table`, `wbc_archive_table_index`) VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL , e.tra_id , 1 , 
f.reg_tra_id , CASE a.codigo_tipo_projeto 
WHEN 1 THEN 10 
WHEN 2 THEN 11
WHEN 3 THEN 12
WHEN 4 THEN 13
WHEN 5 THEN 14 
WHEN 6 THEN 15
WHEN 7 THEN 16
WHEN 8 THEN 17 
WHEN 9 THEN 18
WHEN 10 THEN 19
ELSE 10 END , IF( a.codigo_tipo_projeto IN(6 , 7) , h.doc_id , 0 ) ,
h.doc_tipos_protocolos_id_fk , a.Ementa , a.observacao , 
a.justificativa ,NULL , IF(a.Data_Inicio_Tramitacao IS NULL OR a.Data_Inicio_Tramitacao ='0000-00-00' , CONCAT(ano,'-01-01') , a.Data_Inicio_Tramitacao ) ,
a.Data_Inicio_Tramitacao,1,1,
a.Data_Fim_Tramitacao , a.prazo_tramitacao , now() ,
a.Beneficiario , 
0 , 0 , 1 , 
g.ini_id , 2 , pv.pro_vot_id ,
i.tip_quo_id , NULL , 3 , 
0 , a.Num_Sequencial , 'projeto'
FROM ",outdb,"projeto AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) 
OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) 
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.codigo_situacao_tramitacao
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
LEFT JOIN ",indb,"wcm_regimes_tramitacoes AS f ON f.reg_tra_descricao = a.regime_tramitacao
LEFT JOIN ",indb,"wcm_iniciativas AS g ON g.ini_descricao = a.iniciativa 
LEFT JOIN ",indb,"wcm_processos_votacoes AS pv ON pv.pro_vot_descricao = a.processo_votacao 
LEFT JOIN ",indb,"wcm_tipos_quoruns AS i ON i.tip_quo_descricao = a.quorum
LEFT JOIN ",indb,"wcm_documentos AS h ON h.imp_index= CASE a.codigo_tipo_projeto 
WHEN 6 THEN a.codigo_projeto_substituido
WHEN 7 THEN a.codigo_projeto_veto 
ELSE NULL END AND h.imp_tbl = 'projeto' 
WHERE a.codigo_tipo_projeto NOT IN(6,7)
",IF(@return IS NOT NULL AND @return>0, CONCAT(' AND a.',vchar1,'>',@return),'')," ;
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
/*OR IF(YEAR(c.leg_data_inicio) IS NOT NULL , 
YEAR(c.leg_data_inicio) , IF( a.ano IS NOT NULL , a.ano , 
SUBSTRING( codigo_individual_ano FROM LOCATE('-', codigo_individual_ano)+1 FOR 4 ) ) ) = YEAR(b.data_inicial) */
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL , e.tra_id , 1 , 
f.reg_tra_id , CASE a.codigo_tipo_projeto 
WHEN 1 THEN 10 
WHEN 2 THEN 11
WHEN 3 THEN 12
WHEN 4 THEN 13
WHEN 5 THEN 14 
WHEN 6 THEN 15
WHEN 7 THEN 16
WHEN 8 THEN 17 
WHEN 9 THEN 18
WHEN 10 THEN 19
ELSE 10 END , IF( a.codigo_tipo_projeto IN(6 , 7) , h.doc_id , 0 ) ,
h.doc_tipos_protocolos_id_fk , a.Ementa , a.observacao , 
a.justificativa ,NULL , IF(a.Data_Inicio_Tramitacao IS NULL OR a.Data_Inicio_Tramitacao ='0000-00-00' , CONCAT(ano,'-01-01') , a.Data_Inicio_Tramitacao ) ,
a.Data_Inicio_Tramitacao,1,1,
a.Data_Fim_Tramitacao , a.prazo_tramitacao , now() ,
a.Beneficiario , 
0 , 0 , 1 , 
g.ini_id , 2 , pv.pro_vot_id ,
i.tip_quo_id , NULL , 3 , 
0 , a.Num_Sequencial , 'projeto'
FROM ",outdb,"projeto AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) 
OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) 
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.codigo_situacao_tramitacao
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
LEFT JOIN ",indb,"wcm_regimes_tramitacoes AS f ON f.reg_tra_descricao = a.regime_tramitacao
LEFT JOIN ",indb,"wcm_iniciativas AS g ON g.ini_descricao = a.iniciativa 
LEFT JOIN ",indb,"wcm_processos_votacoes AS pv ON pv.pro_vot_descricao = a.processo_votacao 
LEFT JOIN ",indb,"wcm_tipos_quoruns AS i ON i.tip_quo_descricao = a.quorum
LEFT JOIN ",indb,"wcm_documentos AS h ON h.imp_index= CASE a.codigo_tipo_projeto 
WHEN 6 THEN a.codigo_projeto_substituido
WHEN 7 THEN a.codigo_projeto_veto 
ELSE NULL END AND h.imp_tbl = 'projeto' 
WHERE a.codigo_tipo_projeto IN(6,7)
",IF(@return IS NOT NULL AND @return>0, CONCAT(' AND a.',vchar1,'>',@return),'')," ;
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', @sqlstr, 
@return, NOW(), @sqlstr);


########################################################
#### requerimento#
SET `table` ='requerimento';
########################################################

SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ;"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL , e.tra_id , CASE a.Codigo_Tipo_Requerimento
WHEN 1 THEN 11 
WHEN 2 THEN 10
WHEN 3 THEN 12
WHEN 4 THEN 14 
WHEN 5 THEN 11
WHEN 6 THEN 9
WHEN 7 THEN 15
WHEN 8 THEN 13
WHEN 9 THEN 19 
ELSE 11 END, 
f.reg_tra_id , 3, 0 ,
NULL , a.Ementa , a.observacao , 
a.justificativa ,NULL , IF( a.Data_Inicio_Tramitacao IS NULL OR a.Data_Inicio_Tramitacao ='0000-00-00' , CONCAT(ano,'-01-01') , a.Data_Inicio_Tramitacao ) ,
a.Data_Inicio_Tramitacao,1,1,
NULL , NULL , now() ,
NULL , 
0 , 0 , 1 , 
NULL , 2 , h.pro_vot_id ,
NULL , NULL , 3 , 
0 , a.codigo , 'requerimento'
FROM ",outdb,"requerimento AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) 
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.codigo_situacao_tramitacao 
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
LEFT JOIN ",indb,"wcm_regimes_tramitacoes AS f ON f.reg_tra_descricao = a.regime_tramitacao 
LEFT JOIN ",outdb,"tipo_processo_votacao AS pvt ON pvt.Codigo = a.Codigo_TIPO_PROCESSO_VOTACAO
LEFT JOIN ",indb,"wcm_processos_votacoes AS h ON h.pro_vot_descricao = pvt.descricao 
",IF(@return IS NOT NULL AND @return>0, CONCAT('WHERE a.',vchar1,'>',@return),''),";
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt;DEALLOCATE PREPARE stmt ;
/*OR IF(YEAR(a.Data_Publicacao) IS NOT NULL , 
YEAR(a.Data_Publicacao) , IF( a.ano IS NOT NULL , a.ano , 
SUBSTRING( codigo_individual_ano FROM LOCATE('-', codigo_individual_ano)+1 FOR 4 ) ) ) = YEAR(b.data_inicial) 
OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) */


INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', '', 
@return, NOW(),@sqlstr);

########################################################
#### indicacao #
SET `table`='indicacoes';
SELECT `table`;
########################################################

SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ;"));
PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL , e.tra_id , CASE 1 
WHEN a.tipo_indicacao IN( 1 , 5 , 9 ,13 ,17 ,21 ) THEN 24 
WHEN a.tipo_indicacao IN( 2 , 6 , 10 ,14 ,18 ,22 ) THEN 25
WHEN a.tipo_indicacao IN( 3 , 7 , 11 ,15 ,19 ,23 ) THEN 26
WHEN a.tipo_indicacao IN( 4 , 8 , 12 ,16 ,20 ,24 ) THEN 27
ELSE 24 END , 
NULL , 5, 0 ,
NULL , a.Ementa , a.observacao , 
a.justificativa ,NULL , IF(a.Data_Inicio_Tramitacao IS NULL OR a.Data_Inicio_Tramitacao ='0000-00-00' , CONCAT(ano,'-01-01') , a.Data_Inicio_Tramitacao ) ,
a.Data_Inicio_Tramitacao,1,1,
NULL , NULL , now() ,
NULL , 
0 , 0 , 1 , 
NULL , 2 ,NULL ,
NULL , NULL , 3 , 
0 , a.codigo , 'indicacoes'
FROM ",outdb,"indicacoes AS a 
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.codigo_situacao_tramitacao 
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON 
IF(YEAR(c.leg_data_inicio) IS NOT NULL , 
YEAR(c.leg_data_inicio) , IF( a.ano IS NOT NULL , a.ano , 
SUBSTRING( codigo_individial_ano FROM LOCATE('-', codigo_individial_ano)+1 FOR 4 ) ) ) = YEAR(b.data_inicial) 
OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim)
",IF(@return IS NOT NULL AND @return>0, CONCAT('WHERE a.',vchar1,'>',@return),'')," 
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', '', 
@return, NOW(),@sqlstr);

########################################################
#### Moções #
SET `table` = 'mocoes';
########################################################
SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ;"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;


SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL ,e.tra_id , CASE a.Tipo_Mocao_TIPO_MOCAO 
WHEN 1 THEN 13
WHEN 2 THEN 19
WHEN 3 THEN 23 
WHEN 4 THEN 18
WHEN 5 THEN 20
WHEN 7 THEN 17 
WHEN 23 THEN 22
ELSE 29 END , 
NULL , 4, 0 ,
NULL , a.Ementa , a.observacao , 
a.justificativa ,NULL , IF(a.data_inicio_tramitacao IS NULL OR a.data_inicio_tramitacao ='0000-00-00' , CONCAT(ano,'-01-01') , a.data_inicio_tramitacao ) ,
a.data_inicio_tramitacao,1,1,
NULL , NULL , now() ,
NULL , 
0 , 0 , 1 , 
NULL , 2 ,NULL ,
NULL , NULL , 3 , 
0 , a.codigo , 'mocoes'
FROM ",outdb,"mocoes AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim)
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.codigo_situacao_tramitacao 
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
",IF(@return IS NOT NULL AND @return>0, CONCAT('WHERE a.',vchar1,'>',@return),'')," 
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', '', 
@return, NOW(), @sqlstr);

########################################################
#### Protocolos Copy #
SET `table`='protocolo';
SELECT `table`;
########################################################
SET @return = NULL ; 
SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(pro_processos_id_fk) INTO @return FROM ",indb,"wcm_protocolos ;"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;

SET @sqlstr =(SELECT CONCAT("
INSERT INTO ",indb,"`wcm_protocolos` ( 
`pro_numero`, `pro_formato_numero_codigo_individual_id_fk`, `pro_tipos_protocolos_id_fk`, `pro_documentos_id_fk`, 
`pro_data_hora`, `pro_atualizado_online`, `pro_mostra_online`, `pro_usuario_id_fk`, 
`pro_tipos_dinamicos_id_fk`, `pro_protocolante_id_fk`, `pro_tipos_processos_id_fk`, `pro_observacao`, 
`pro_processos_id_fk`, `pro_gerado`, `pro_anulado`, `pro_motivo_anulacao`, 
`pro_motivo_reativacao`, `pro_origem`, `pro_processos_web_fluxo_id_fk`)
SELECT a.num_protocolo , 3 , f.doc_tipos_protocolos_id_fk , f.doc_id ,
a.data_protocolo , 1 , 1 , 1 , 
3 , 1 , 2 , a.observacao , 
a.Num_Protocolo , 1 , IF(a.anulado ='û' ,1,0) , a.motivo_anulacao , 
a.motivo_reativacao , '' , NULL 
FROM ",outdb,"protocolo AS a 
LEFT JOIN ",outdb,"requerimento AS b ON b.Num_Protocolo_PROTOCOLO = a.num_protocolo
LEFT JOIN ",outdb,"projeto AS c	ON c.Num_Protocolo_PROTOCOLO = a.num_protocolo
LEFT JOIN ",outdb,"indicacoes AS d ON d.Num_Protocolo_PROTOCOLO = a.num_protocolo
LEFT JOIN ",outdb,"mocoes AS g ON g.Num_Protocolo_PROTOCOLO = a.num_protocolo
LEFT JOIN ",outdb,"emenda AS e ON e.Num_Protocolo_PROTOCOLO = a.num_protocolo
INNER JOIN ",indb,"wcm_documentos AS f ON imp_tbl=CASE 1 
WHEN a.codigo_tipo_protocolo IN(1 ,2 ,3 ,4, 5, 6, 7,37,38,59) THEN 'projeto' 
WHEN a.codigo_tipo_protocolo=18 THEN 'emenda'
WHEN a.codigo_tipo_protocolo=19 THEN 'indicacoes'
WHEN a.codigo_tipo_protocolo=20 THEN 'mocoes' 
WHEN a.codigo_tipo_protocolo=21 THEN 'requerimento'
WHEN a.codigo_tipo_protocolo=35 THEN 'subemenda' END AND imp_index=CASE 1 
WHEN a.codigo_tipo_protocolo IN(1 ,2 ,3 ,4, 5, 6, 7,37,38,59) THEN c.Num_Sequencial
WHEN a.codigo_tipo_protocolo=18 THEN e.codigo
WHEN a.codigo_tipo_protocolo=19 THEN d.codigo 
WHEN a.codigo_tipo_protocolo=20 THEN g.codigo 
WHEN a.codigo_tipo_protocolo=21 THEN b.codigo 
END
WHERE a.codigo_tipo_protocolo IN(1,2,3,4,5,6,8,18,19,20,21,35,37,38,44) ",IF(@return IS NOT NULL AND @return>0, CONCAT('AND a.',vchar1,'>',@return),'')," ;"));
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_protocolos', 'pro_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', '', 
@return, NOW(), @sqlstr);
########################################################
#### Protocolo Generate; #
SET `table`='protocolo';
SELECT `table`;
SET @return = NULL; 
########################################################

SET @sqlstr=(SELECT CONCAT("SELECT MAX(pro_numero) INTO @i FROM ",indb,"wcm_protocolos ;"));
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
SET @return = NULL ;

SET @sqlstr=(SELECT CONCAT("
SELECT COUNT(*) INTO @return
FROM ",indb,"wcm_documentos AS a 
LEFT JOIN ",indb,"wcm_protocolos AS b ON b.pro_documentos_id_fk = a.doc_id 
WHERE b.pro_id IS NULL ;"));
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

SET @sqlstr=(SELECT CONCAT("
INSERT INTO ",indb,"`wcm_protocolos` (
`pro_numero`, `pro_formato_numero_codigo_individual_id_fk`, `pro_tipos_protocolos_id_fk`, `pro_documentos_id_fk`, 
`pro_data_hora`, `pro_atualizado_online`, `pro_mostra_online`, `pro_usuario_id_fk`, 
`pro_tipos_dinamicos_id_fk`, `pro_protocolante_id_fk`, `pro_tipos_processos_id_fk`, `pro_observacao`, 
`pro_processos_id_fk`, `pro_gerado`, `pro_anulado`, `pro_motivo_anulacao`, 
`pro_motivo_reativacao`, `pro_origem`, `pro_processos_web_fluxo_id_fk`)
SELECT @i:=@i+1 , 3 , a.doc_tipos_protocolos_id_fk , a.doc_id , 
a.doc_data_documento , 1 , 1 , 1, 
3 , 1 , 2 , '' , 
1 , 1 , NULL , '' , 
'' , '' , NULL 
FROM ",indb,"wcm_documentos AS a 
LEFT JOIN ",indb,"wcm_protocolos AS b ON b.pro_documentos_id_fk = a.doc_id 
WHERE b.pro_id IS NULL ;"));
PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;

INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_protocolos', 'pro_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', 'Criação de protocolos inexistentes para tabelas específicas.', 
@return, NOW(), @sqlstr);
########################################################
#### Processo Generator #
SET @return = NULL ; 
SET `table` = 'wfx_processos';
########################################################

SET @sqlstr=(SELECT CONCAT("
SELECT COUNT(*) INTO @return
FROM ",indb,"wcm_documentos AS a 
LEFT JOIN ",indb,"wcm_protocolos AS b ON a.doc_id = b.pro_documentos_id_fk
LEFT JOIN ",indb,"wfx_processos AS c ON c.pro_ementa_documento_nao_protocolado = a.doc_id 
WHERE c.pro_id IS NULL; 
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;


SET @sqlstr=(SELECT CONCAT("
INSERT INTO ",indb,"`wfx_processos` 
(`pro_setores_id_fk`, `pro_usuarios_id_fk`, `pro_usuarios_arquivado_id_fk`, 
`pro_usuarios_desarquivado_id_fk`, `pro_data_hora`, `pro_data_arquivado`, 
`pro_data_desarquivado`, `pro_codigo_individual_documentos`, `pro_ano`, 
`pro_tipos_protocolos_id_fk`, `pro_interno_ou_protocolo`, `pro_numero_protocolo`, 
`pro_protocolo_internet_id_fk`, `pro_formato_numero_codigo_individual_id_fk`, `pro_tipos_processos_id_fk`, 
`pro_processos_id_fk`, `pro_requerente_id`, `pro_documento_nao_protocolado`, 
`pro_ementa_documento_nao_protocolado`, `pro_retirado`, `pro_aguardando_retirada`, 
`pro_usuarios_retirado_id_fk`, `pro_data_hora_retirado`, `pro_assunto`)
SELECT 1 , 1 , NULL , 
NULL , a.doc_data_documento , NULL , 
NULL , a.doc_codigo_individual , YEAR(a.doc_data_documento) ,
a.doc_tipos_protocolos_id_fk , NULL , b.pro_id,
NULL , 3 , 2 ,
NULL , NULL , a.doc_id , 
NULL , NULL , NULL ,
NULL , NULL , ''
FROM ",indb,"wcm_documentos AS a 
LEFT JOIN ",indb,"wcm_protocolos AS b ON a.doc_id = b.pro_documentos_id_fk
LEFT JOIN ",indb,"wfx_processos AS c ON c.pro_ementa_documento_nao_protocolado = a.doc_id 
WHERE c.pro_id IS NULL AND a.doc_tipos_protocolos_id_fk NOT IN(15 , 16 , 8 , 1 ,2 ); 
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_protocolos', 'pro_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', 'Criação de protocolos inexistentes para tabelas específicas.', 
@return, NOW(), @sqlstr);


########################################################
#### Pareceres #
SET `table` = 'parecer';
SET @return = NULL ; 
########################################################

SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ;"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;

SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.num_sequencial_ano , NULL , 
NULL , NULL , CASE a.codigo_tipo_parecer
WHEN 1 THEN 30
WHEN 2 THEN 30
WHEN 3 THEN 30
WHEN 4 THEN 30
WHEN 5 THEN 30
WHEN 6 THEN 30
WHEN 7 THEN 30
WHEN 8 THEN 30
WHEN 9 THEN 30
WHEN 10 THEN 30
WHEN 11 THEN 30
ELSE 30 END , 
NULL , 8 , d.doc_id ,
d.doc_tipos_protocolos_id_fk , a.Ementa , '' , 
NULL ,NULL , IF(a.data IS NULL OR a.data='0000-00-00' , CONCAT(ano,'-01-01') , a.data ) ,
a.data,1,1,
NULL , NULL , now() ,
NULL , 
0 , 0 , 1 , 
NULL , 2 ,NULL ,
NULL , NULL , 3 , 
0 , a.codigo , 'parecer'
FROM ",outdb,"parecer AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) 
LEFT JOIN ",indb,"wcm_documentos AS d ON d.imp_index= a.num_sequencial_projeto AND d.imp_tbl='projeto'
",IF(@return IS NOT NULL AND @return>0, CONCAT('WHERE a.',vchar1,'>',@return),'')," 
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;



INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', @sqlstr, 
@return, NOW(), @sqlstr);


########################################################
#### emenda #
SET `table`='emenda';
SELECT `table`;
SET @return= NULL ;
########################################################

SET @sqlstr = (SELECT CONCAT("
SELECT a.COLUMN_NAME INTO @return FROM information_schema.`COLUMNS` AS a WHERE a.TABLE_SCHEMA ='",REPLACE(outdb,'.',''),"' AND table_name='",`table`,"' AND a.COLUMN_KEY='PRI' 
"));PREPARE GetIndex FROM @sqlstr ;EXECUTE GetIndex ;DEALLOCATE PREPARE GetIndex;
SET vchar1 = @return; 

SET @return = NULL ; 
SET @sqlstr= (SELECT CONCAT("
SELECT MAX(imp_index) INTO @return FROM ",indb,"wcm_documentos WHERE imp_tbl='",`table`,"' ;"));PREPARE GetMax FROM @sqlstr;EXECUTE GetMax;DEALLOCATE PREPARE GetMax;

##
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wcm_documentos` (
`doc_legislaturas_id_fk`, `doc_codigo_individual`, `doc_oficios_id_fk`,
`doc_publicacoes_id_fk`, `doc_tramitacoes_id_fk`, `doc_tipos_documentos_id_fk`, 
`doc_regimes_tramitacoes_id_fk`, `doc_tipos_protocolos_id_fk`, `doc_documentos_id_fk`,
`doc_tipos_protocolos_projetos_id_fk`, `doc_ementa`, `doc_observacao`, 
`doc_justificativa`, `doc_texto`, `doc_data_documento`, 
`doc_data_inicio_tramitacao`, `doc_atualizado_online`, `doc_mostra_online`, 
`doc_data_fim_tramitacao`, `doc_data_limite_tramitacao`, `doc_data_atualizacao`, 
`doc_beneficiario`, 
`doc_processos_id_fk`,`doc_numero_processo`, `doc_discussoes_id_fk`, 
`doc_iniciativas_id_fk`, `doc_competencias_id_fk`, `doc_processos_votacoes_id_fk`, 
`doc_tipos_quoruns_id_fk`, `doc_gerado`, `doc_formato_numero_codigo_individual_id_fk`, 
`doc_numero_volumes` , imp_index , imp_tbl ) 
SELECT 
c.leg_id , a.Codigo_Individual , NULL , 
NULL , e.tra_id , CASE a.codigo_tipo_emenda
WHEN 1 THEN 3 
WHEN 3 THEN 2
WHEN 4 THEN 12
WHEN 5 THEN 1
ELSE 1 END , 
NULL , 1 , h.doc_id , 
h.doc_tipos_protocolos_id_fk , a.Ementa , '' , 
'' ,NULL , IF( a.Data IS NULL OR a.Data ='0000-00-00' , CONCAT(ano,'-01-01') , a.Data ) ,
a.Data ,1,1,
a.Data , NULL , now() ,
NULL , 
0 , 0 , 1 , 
NULL , 2 , NULL ,
i.tip_quo_id , NULL , 3 , 
0 , a.codigo , 'emenda'
FROM ",outdb,"emenda AS a 
LEFT JOIN ",outdb,"legislatura AS b ON a.codigo_legislatura = b.codigo 
LEFT JOIN ",indb,"wcm_legislaturas AS c ON YEAR(c.leg_data_inicio) = YEAR(b.data_inicial) OR IF(YEAR(c.leg_data_inicio) IS NOT NULL , 
YEAR(c.leg_data_inicio) , IF( a.ano IS NOT NULL , a.ano , 
SUBSTRING( codigo_individual_ano FROM LOCATE('-', codigo_individual_ano)+1 FOR 4 ) ) ) = YEAR(b.data_inicial) 
OR a.ano BETWEEN YEAR(c.leg_data_inicio) AND YEAR(c.leg_data_fim) 
LEFT JOIN ",outdb,"situacao_tramitacao AS d ON d.codigo = a.Codigo_SITUACAO_TRAMITACAO
LEFT JOIN ",indb,"wcm_tramitacoes AS e ON d.descricao = e.tra_descricao
LEFT JOIN ",indb,"wcm_tipos_quoruns AS i ON i.tip_quo_descricao = a.quorum
LEFT JOIN ",indb,"wcm_documentos AS h ON h.imp_index=a.num_sequencial_projeto AND h.imp_tbl = 'projeto'
WHERE a.num_sequencial_projeto>0 ",IF(@return IS NOT NULL AND @return>0, CONCAT('AND a.',vchar1,'>',@return),'')," ;
"));PREPARE stmt FROM @sqlstr ;EXECUTE stmt ;DEALLOCATE PREPARE stmt;
##
INSERT INTO `wcm_temp_resource` (
`wcm_table`, `wcm_table_index`, `wcm_archive_table`, 
`wcm_archive_table_index`, `wbc_table_equiv`, `wbc_table_equiv_index`, 
`wbc_archive_table`, `wbc_archive_table_index`, `Obs`, 
`Last_Index`, `data_exec`, `state`) 
VALUES (
'wcm_documentos', 'doc_id', 'wfx_arquivos_mensagens', 
'arq_men_id', `table`, @vchar1, 
'', '', @sqlstr, 
@return, NOW(), @sqlstr);


########################################################
#### mensagem #
SET `table`='wfx_mensagens';
SELECT `table`;
########################################################
SET @sqlstr = (SELECT CONCAT("
INSERT INTO ",indb,"`wfx_mensagens` (
`men_tipos_mensagens_id_fk`, `men_aguarda_notificacao`, `men_aguarda_notificacao_mensagem_id_fk`, `men_processos_id_fk`, 
`men_grupos_id_fk`, `men_usuarios_id_fk`, `men_destinatarios_id_fk`, `men_rotas_id_fk`, 
`men_ordem_rota`, `men_data_hora`, `men_data_hora_resposta`, `men_data_hora_prazo`, 
`men_mensagem`, `men_anexo`, `men_lido`, `men_data_hora_lido`, 
`men_despachar`, `men_assunto`, `men_despacho`, `men_rascunho_despacho_mensagens_id_fk`, 
`men_destinatario_departamento_id_fk`, `men_codigo_individual`, `men_em_sigilo`, `men_documentos_id_fk`, 
`men_pareceres_id_fk`, `men_autografos_id_fk`) 
SELECT 7 , NULL , NULL , NULL ,
994 , 717 , 1 , 0 ,
0 , a.doc_data_documento ,NULL, NULL , 
'Proposicao' ,NULL , 1 ,NULL ,
'n' , a.doc_id, NULL , a.doc_id ,
994 , 1,0,a.doc_id,
IF(a.imp_tbl='parecer' , a.doc_id , NULL ) , NULL 
FROM ",indb,"wcm_documentos AS a 
LEFT