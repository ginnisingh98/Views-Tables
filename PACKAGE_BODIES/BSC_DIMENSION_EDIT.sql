--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_EDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_EDIT" as
/* $Header: BSCEDITB.pls 120.4 2007/02/08 09:41:57 ankgoel ship $*/
/*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 | FILENAME                                                                  |
 |      BSCEDITB.pls                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Package for backend logic of BSC edit dimension page.                   |
 |           20-Aug-03   Adeulgao fixed bug#3008243 eliminated hard coding   |
 |                      of schema name                                       |
 | 04-NOV-2003 PAJOHRI  Bug #3232366                                         |
 | 07-Jan-04 SMULYE    Bug 3343979  Fixed API Delete_Codes_CascadeMN to      |
 |  delete  only from base tables , not system tables.			     |
 |									     |
 | 14-Jan-04 MREZA	Bug 3363584 Fixed API checkUsercodeChange to	     |
 |			increase width of l_old_user_code.		     |
 | 16-NOV-2006 ankgoel  Color By KPI enh#5244136                             |
 |									     |
 +==========================================================================+*/

h_installed_languages BSC_UPDATE_UTIL.t_array_of_varchar2;
h_num_installed_languages NUMBER;

CURSOR LEVEL is
 SELECT DISTINCT L.DIM_LEVEL_ID, D.LEVEL_TABLE_NAME
    FROM BSC_SYS_COM_DIM_LEVELS L, BSC_SYS_DIM_LEVELS_B D
    WHERE L.DIM_LEVEL_ID = D.DIM_LEVEL_ID;

CURSOR CHILD (l_table_name varchar2) is
     SELECT T.LEVEL_TABLE_NAME AS CHILDTABLE , P.level_pk_col
     FROM BSC_SYS_DIM_LEVELS_B T, BSC_SYS_DIM_LEVEL_RELS R, BSC_SYS_DIM_LEVELS_B P
   WHERE T.DIM_LEVEL_ID = R.DIM_LEVEL_ID
     and R.PARENT_DIM_LEVEL_ID =P.dim_level_id
        AND R.RELATION_TYPE = 1
        and P.level_table_name=l_table_name;

UNIQUE_CONSTRAINT_VIOLATED exception;

procedure security_sync is
l_stmt varchar2(3000);
L_LEVEL_ID NUMBER;
L_TABLE_NAME VARCHAR2(30);
e_unexpected_error EXCEPTION;
begin
        IF (LEVEL%isopen) THEN
                close LEVEL;
        END IF;
        open LEVEL;
        LOOP
         fetch LEVEL into L_LEVEL_ID, L_TABLE_NAME;
         exit when LEVEL%notfound;
         l_stmt:='DELETE FROM BSC_USER_LIST_ACCESS '||
                ' WHERE (RESPONSIBILITY_ID, TAB_ID) IN '||
          '( SELECT LA.RESPONSIBILITY_ID, LA.TAB_ID '||
          '  FROM BSC_SYS_COM_DIM_LEVELS L, BSC_USER_LIST_ACCESS LA '||
          '  WHERE L.TAB_ID = LA.TAB_ID '||
          ' AND L.DIM_LEVEL_INDEX = LA.DIM_LEVEL_INDEX '||
          ' AND L.DIM_LEVEL_ID = :1 '||
          ' AND LA.DIM_LEVEL_VALUE <> 0 '||
          ' AND LA.DIM_LEVEL_VALUE NOT IN ( '||
          ' SELECT CODE FROM '||L_TABLE_NAME||'))';
         execute immediate l_stmt using L_LEVEL_ID;
         commit;
        END LOOP;

        close LEVEL;

    h_num_installed_languages := BSC_UPDATE_UTIL.Get_Installed_Languages(h_installed_languages);
        IF h_num_installed_languages = -1 THEN
            RAISE e_unexpected_error;
        END IF;

end security_sync;

procedure deleteNormalRow(   l_dim_table IN VARCHAR2,
        l_deleted_code IN NUMBER) is
deleted_code  BSC_UPDATE_UTIL.t_array_of_number;
temp boolean;
begin
deleted_code(1):=l_deleted_code;
 temp:=BSC_UPDATE_DIM.Delete_Codes_Cascade(
        l_dim_table,
        deleted_code, 1);
 --commit;
  /* if (temp=FALSE) then raise program_error; end if; */
end;

procedure deleteMNRow(l_dim_table IN VARCHAR2,
                      l_key_column1 IN VARCHAR2,
                      l_key_column2 IN VARCHAR2,
                      l_rowid IN VARCHAR2)   is
    TYPE CURSORTYPE IS REF CURSOR;
    l_cursor CURSORTYPE;
    l_code1  NUMBER;
    l_code2  NUMBER;
    l_stmt   VARCHAR2(2000);
    result     BOOLEAN :=false;
begin
    l_stmt := 'SELECT '||l_key_column1||', '||l_key_column2||' FROM '||l_dim_table||' WHERE rowid='''||l_rowid||'''';
    open l_cursor for l_stmt;
    fetch l_cursor into l_code1, l_code2;
    close l_cursor;
    result := Delete_Codes_CascadeMN(
                l_dim_table,
                l_key_column1,
                l_key_column2,
                l_code1 ,
                l_code2
            );
    --commit;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.deleteMNRow');
  end deleteMNRow;

procedure markKPI( l_dim_table IN VARCHAR2) is
begin
        UPDATE BSC_KPIS_B K
        SET PROTOTYPE_FLAG = 6,
            LAST_UPDATED_BY = BSC_APPS.fnd_global_user_id,
            LAST_UPDATE_DATE = SYSDATE
        WHERE INDICATOR IN (SELECT D.INDICATOR
                            FROM BSC_KPI_DIM_LEVELS_B D
                            WHERE K.INDICATOR = D.INDICATOR AND
                                  (UPPER(D.LEVEL_TABLE_NAME) = UPPER(l_dim_table) OR
                                   UPPER(D.TABLE_RELATION) = UPPER(l_dim_table))) AND
              PROTOTYPE_FLAG in (0, 6, 7);

        -- Color By KPI: Mark KPIs for color re-calculation
        UPDATE bsc_kpi_analysis_measures_b k
	  SET prototype_flag = 7
          WHERE indicator IN (SELECT D.INDICATOR
                              FROM BSC_KPI_DIM_LEVELS_B D
                              WHERE K.INDICATOR = D.INDICATOR AND
                                    (UPPER(D.LEVEL_TABLE_NAME) = UPPER(l_dim_table) OR
                                     UPPER(D.TABLE_RELATION) = UPPER(l_dim_table)));
    commit;
end markKPI;

procedure saveNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_code in number, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message out  nocopy varchar2) is
l_code_number number;
l_fkcode_number number;
l_name2 varchar2(2000);
begin
   l_fkcode_number:=to_number(l_fkcode);
   l_name2:=removeComma(l_name);
   if (l_code is not null) then
     l_code_number:=to_number(l_code);
     updateNormalRowNW(l_dim_table,l_fk,l_fk_user,l_code_number,
       l_user_code, l_name2, l_fkcode_number, l_fkusercode, l_message);
   else
     insertNormalRowNW(l_dim_table,l_fk,l_fk_user,
       l_user_code, l_name2, l_fkcode_number, l_fkusercode, l_message);
   end if;
end  saveNormalRowNW;

procedure saveNormalRowNO(l_dim_table in varchar2, l_code in varchar2,
    l_user_code in varchar2, l_name in varchar2, l_message out  nocopy varchar2) is
l_code_number number;
l_name2 varchar2(2000);
begin
   l_name2:=removeComma(l_name);
   if (l_code is not null) then
     l_code_number:=to_number(l_code);
     updateNormalRowNO(l_dim_table,l_code_number,l_user_code,l_name2,l_message);
   else
     insertNormalRowNO(l_dim_table,l_user_code,l_name2, l_message);
   end if;
end  saveNormalRowNO;

procedure saveMNRow(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number, l_rowid in varchar2,
l_message out  nocopy varchar2 ) is
l_stmt varchar2(3000);
begin
 if (l_rowid is not null) then
 if (checkMNrecord(l_dim_table, l_key_column1,l_key_column2,
  l_code1,l_code2, l_rowid)) then
    l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
  else
   l_stmt:='update '||l_dim_table ||' set '||
    l_key_column1 ||'=:1, '||
    l_key_column2 ||'=:2  ' ||
    ' where rowid=:3 ';
     execute immediate l_stmt using l_code1,l_code2, l_rowid;
  end if;
 else
   if (checkMNrecord(l_dim_table, l_key_column1,l_key_column2, l_code1,l_code2)) then
    l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
      --raise_application_error(-20000,'UNIQUE_CONSTRAINT_VIOLATED');
   else
     l_stmt:='insert into '||l_dim_table ||'( '||
      l_key_column1 ||','|| l_key_column2 ||')'||
       'values(:1, :2)';
     execute immediate l_stmt using l_code1,l_code2;
     --commit;
   end if;
 end if;

end saveMNRow;

procedure updateNormalRowNO(l_dim_table in varchar2, l_code in number,
    l_user_code in varchar2, l_name in varchar2,l_message out nocopy varchar2) is
l_stmt varchar2(3000);
l_source_lang varchar2(4);
UsercodeChange boolean ;
begin
   if (checkrecord(l_dim_table, l_user_code, l_name, l_code)) then
       l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
   else
      UsercodeChange:=checkUsercodeChange(l_dim_table, l_code, l_user_code);
      l_source_lang:=USERENV('LANG');
      l_stmt:=' update '||l_dim_table||' set '||
              ' user_code=:1 where code=:2 ';
      execute immediate l_stmt using l_user_code, l_code;
      --commit;
      --l_stmt:=' update '||l_dim_table||' set '||
      --        ' name=:1, source_lang=:2 where code=:3 and language=:4 ';
      --execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang;
      l_stmt:=' update '||l_dim_table||' set '||
              ' name=:1, source_lang=:2 where code=:3 and (language=:4 or source_lang=:5) ';
      execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang, l_source_lang;
      --commit;
      if (UsercodeChange and checkChild(l_dim_table) > 0) then
        cascadeUsercodeChange(l_dim_table, l_code, l_user_code);
      end if;
   end if;
end updateNormalRowNO;

procedure insertNormalRowNO(l_dim_table in varchar2,
    l_user_code in varchar2, l_name in varchar2, l_message out  nocopy varchar2)is
l_stmt varchar2(3000);
l_code number;
l_source_lang varchar2(4);
e_unexpected_error EXCEPTION;
begin
   if (checkrecord(l_dim_table, l_user_code, l_name)) then
       l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
       -- raise_application_error(-20000,'UNIQUE_CONSTRAINT_VIOLATED');
   else
      l_code:=BSC_UPDATE_DIM.get_new_code(l_dim_table);
      l_source_lang:=USERENV('LANG');

	IF h_num_installed_languages is NULL THEN
	    h_num_installed_languages := BSC_UPDATE_UTIL.Get_Installed_Languages(h_installed_languages);
		IF h_num_installed_languages = -1 THEN
		    RAISE e_unexpected_error;
		END IF;
	END IF;


      FOR h_i IN 1 .. h_num_installed_languages LOOP
       l_stmt := 'INSERT INTO '||l_dim_table||' ('||
                         ' code, user_code, name, language, source_lang)'||
                         ' values (:1,:2,:3,:4,:5)';
       execute immediate l_stmt using l_code,l_user_code, l_name, h_installed_languages(h_i),l_source_lang;
      END LOOP;
      --commit;
   end if;

end insertNormalRowNO;

procedure updateNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_code in number, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message out nocopy varchar2)is
TYPE curcode IS REF CURSOR;
cv curcode;
l_code_number number;
l_stmt varchar2(3000);
l_source_lang varchar2(4);
UsercodeChange boolean ;
begin
   l_message := null;
   if (checkrecord(l_dim_table, l_user_code, l_name, l_code)) then
      l_stmt:='select code from '||l_dim_table ||' where (user_code=:1 or name=:2) and ('||l_fk||' is null or '||l_fk_user||' is null) and code!=:3';
      open cv for l_stmt using l_user_code, l_name, l_code;
      fetch cv into l_code_number;
      close cv;
      if (l_code_number is not null) then
         deleteNormalRow(l_dim_table, l_code_number);
      else
         l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
      end if;
   end if;
   if (l_message is null) then
      UsercodeChange:=checkUsercodeChange(l_dim_table, l_code, l_user_code);
      l_source_lang:=USERENV('LANG');
      l_stmt:=' update '||l_dim_table||' set '||
        ' user_code=:1, '||l_fk||'=:2, '||l_fk_user||'=:3  where code=:4 ';
      execute immediate l_stmt using l_user_code, l_fkcode, l_fkusercode, l_code;
      --commit;
      --l_stmt:=' update '||l_dim_table||' set '||
      --  ' name=:1, source_lang=:2 where code=:3 and language=:4 ';
      --execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang;
      l_stmt:=' update '||l_dim_table||' set '||
        ' name=:1, source_lang=:2 where code=:3 and (language=:4 or source_lang=:5) ';
      execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang, l_source_lang;
      --commit;
      if (UsercodeChange and checkChild(l_dim_table) > 0) then
        cascadeUsercodeChange(l_dim_table, l_code, l_user_code);
      end if;
   end if;
end updateNormalRowNW;

procedure insertNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message out  nocopy varchar2) is
TYPE curcode IS REF CURSOR;
cv curcode;
l_stmt varchar2(3000);
l_code number;
l_source_lang varchar2(4);
e_unexpected_error EXCEPTION;
begin
   if (checkrecord(l_dim_table, l_user_code, l_name)) then
      l_stmt:='select code from '||l_dim_table ||' where (user_code=:1 or name=:2) and ('||l_fk||' is null or '||l_fk_user||' is null)';
      open cv for l_stmt using l_user_code, l_name;
      fetch cv into l_code;
      close cv;
      if (l_code is not null) then
         updateNormalRowNW(l_dim_table, l_fk, l_fk_user, l_code, l_user_code, l_name, l_fkcode, l_fkusercode, l_message);
      else
         l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
         --raise_application_error(-20000,'UNIQUE_CONSTRAINT_VIOLATED');
      end if;
   else
      l_code:=BSC_UPDATE_DIM.get_new_code(l_dim_table);
      l_source_lang:=USERENV('LANG');

	IF h_num_installed_languages is NULL THEN
	    h_num_installed_languages := BSC_UPDATE_UTIL.Get_Installed_Languages(h_installed_languages);
		IF h_num_installed_languages = -1 THEN
		    RAISE e_unexpected_error;
		END IF;
	END IF;

      FOR h_i IN 1 .. h_num_installed_languages LOOP
       l_stmt := 'INSERT INTO '||l_dim_table||' ('||
                         ' code, user_code, name, language, source_lang,'||
            l_fk||','||l_fk_user||')'||
                         ' values (:1,:2,:3,:4,:5,:6,:7)';
       execute immediate l_stmt using l_code,l_user_code, l_name, h_installed_languages(h_i),l_source_lang,l_fkcode, l_fkusercode;
      END LOOP;
    --commit;
   end if;

end insertNormalRowNW;

FUNCTION  checkrecord(l_dim_table in varchar2, l_user_code in varchar2,
 l_name in varchar2) return boolean is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(3000);
l_count number:=0;
begin
  l_stmt:='select count(*) from '||l_dim_table ||' where user_code=:1';
  open cv for l_stmt using l_user_code;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  l_stmt:='select count(*) from '||l_dim_table ||' where name=:1';
  open cv for l_stmt using l_name;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  return false;
end;

FUNCTION  checkrecord(l_dim_table in varchar2, l_user_code in varchar2,
 l_name in varchar2, l_code in number ) return boolean is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(3000);
l_count number:=0;
begin
  l_stmt:='select count(*) from '||l_dim_table ||' where user_code=:1 and code!=:2';
  open cv for l_stmt using l_user_code, l_code;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  l_stmt:='select count(*) from '||l_dim_table ||' where name=:1 and code!=:2';
  open cv for l_stmt using l_name, l_code;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  return false;
end;

FUNCTION  checkMNrecord(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number) return boolean is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(3000);
l_count number:=0;
begin
  l_stmt:='select count(*) from '||l_dim_table ||' where '||l_key_column1
   ||'=:1 and '||l_key_column2||' =:2';
  open cv for l_stmt using l_code1, l_code2;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  return false;
end;

FUNCTION  checkMNrecord(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number, l_rowid in varchar2) return boolean is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(3000);
l_count number:=0;
begin
  l_stmt:='select count(*) from '||l_dim_table ||' where '||l_key_column1
   ||'=:1 and '||l_key_column2||' =:2 and rowid!=:3 ';
  open cv for l_stmt using l_code1, l_code2, l_rowid;
  fetch cv into l_count;
  close cv;
  if (l_count>0) then
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
    return true;
  end if;
  return false;
end;

function removeComma(l_name varchar2) return varchar2
is
l_name2 varchar2(2000):=null;
l_position number;
TYPE curtyp IS REF CURSOR;
cv       curtyp;
--l_stmt varchar2(2000);
begin
 /*l_stmt:='select instr('||''''||l_name||''''||','','') from dual';
  open cv for l_stmt;
  fetch cv into l_position;
  close cv; */
  l_position:= instr(l_name,',');
  if (l_position>0) then
    l_name2:=substr(l_name,1,l_position-1)||substr(l_name,l_position+1,length(l_name));
  else l_name2:=l_name;
  end if;
  /*l_stmt:='select instr('||''''||l_name2||''''||','','') from dual';
  open cv for l_stmt;
  fetch cv into l_position;
  close cv; */
  l_position:= instr(l_name2,',');
  if (l_position>0) then
    l_name2:=removeComma(l_name2);
  end if;
  return l_name2;
end;

FUNCTION Delete_Codes_CascadeMN(
    x_dim_table IN VARCHAR2,
    x_key_column1 IN VARCHAR2,
    x_key_column2 IN VARCHAR2,
    x_deleted_codes1 IN number,
    x_deleted_codes2 IN number
    ) RETURN BOOLEAN IS

    h_condition VARCHAR2(32700);
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;

    c_base_tables t_cursor; -- x_key_column1, x_key_column2,  h_column_type_p

     c_base_tables_sql VARCHAR2(2000) := 'SELECT DISTINCT bt.table_name '||
                                        ' FROM (SELECT DISTINCT table_name'||
					' FROM bsc_db_tables_rels'||
					' WHERE source_table_name IN '||
					' ( SELECT table_name  FROM bsc_db_tables '||
					' WHERE table_type = 0 ) )bt,'||
					' bsc_db_tables_cols c '||
					' WHERE bt.table_name = c.table_name AND '||
					' (UPPER(c.column_name) = UPPER(:1)  OR '||
					' UPPER(c.column_name) = UPPER(:2)) AND '||
					' c.column_type = :3 '||
					' GROUP BY bt.table_name '||
					' HAVING COUNT(*) = 2 ';

    h_column_type_p VARCHAR2(1) := 'P';

    h_base_table VARCHAR2(30);
    h_sql VARCHAR2(32700);

BEGIN
    h_condition := x_key_column1||'='||x_deleted_codes1||' and '
    ||x_key_column2||'='||x_deleted_codes2;

    -- Delete from system tables
  OPEN c_base_tables FOR c_base_tables_sql USING x_key_column1, x_key_column2,  h_column_type_p;
  FETCH c_base_tables INTO h_base_table;
  While c_base_tables%FOUND LOOP
     	 h_sql := 'DELETE FROM '||h_base_table||
                 ' WHERE '||h_condition;
               BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
       FETCH c_base_tables INTO h_base_table;
    END LOOP;
    CLOSE c_base_tables;


    -- Delete from dimension table
    h_sql := 'DELETE FROM '||x_dim_table||
             ' WHERE '||h_condition;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Delete_Codes_CascadeMN');
        RETURN FALSE;

END Delete_Codes_CascadeMN;

FUNCTION  checkMVnot(l_table in varchar2) return boolean is
    l_mv varchar2(100);
BEGIN
  l_mv  :=  UPPER(l_table)||'_MV';
  IF (BSC_UTILITY.is_MV_Exists(l_mv)) THEN
    RETURN FALSE;
    --dbms_output.put_line('UNIQUE_CONSTRAINT_VIOLATED');
  ELSE
    RETURN TRUE;
  END IF;
end;

procedure insertNormalRowNWM(l_dim_table in varchar2,
l_user_code in varchar2, l_name in varchar2, l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out  nocopy varchar2) is
TYPE curcode IS REF CURSOR;
cv curcode;
l_stmt varchar2(5000);
l_code number;
l_source_lang varchar2(4);
l_t1 varchar2(1000):=null;
l_t2 varchar2(1000):=null;
l_t3 varchar2(1000):=null;
e_unexpected_error EXCEPTION;
begin
   if (checkrecord(l_dim_table, l_user_code, l_name)) then
      if (l_parentcount >= 1) then
         l_t3 := '('||l_fklist(1)||' is null or '||l_fklist(1)||'_USR is null';
         for i in 2 ..l_parentcount loop
            l_t3 := l_t3||' or '||l_fklist(i)||' is null or '||l_fklist(i)||'_USR is null';
         end loop;
         l_t3 := l_t3||')';
      end if;
      l_stmt := 'select code from '||l_dim_table ||' where (user_code=:1 or name=:2) and '||l_t3;
      open cv for l_stmt using l_user_code, l_name;
      fetch cv into l_code;
      close cv;
      if (l_code is not null) then
         updateNormalRowNWM(l_dim_table, l_code, l_user_code, l_name, l_parentcount, l_fklist, l_fkvaluelist, l_fkuservaluelist, l_message);
      else
         l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
         --raise_application_error(-20000,'UNIQUE_CONSTRAINT_VIOLATED');
      end if;
   else
      l_code:=BSC_UPDATE_DIM.get_new_code(l_dim_table);
      l_source_lang:=USERENV('LANG');
      for i in 1 ..l_parentcount loop
        l_t1:=l_t1||' , '||l_fklist(i)||' , '||l_fklist(i)||'_USR';
        l_t2:=l_t2||' , '||to_number(l_fkvaluelist(i))||' , '''||l_fkuservaluelist(i)||'''';
      end loop;


	IF h_num_installed_languages is NULL THEN
	    h_num_installed_languages := BSC_UPDATE_UTIL.Get_Installed_Languages(h_installed_languages);
		IF h_num_installed_languages = -1 THEN
		    RAISE e_unexpected_error;
		END IF;
	END IF;



      FOR h_i IN 1 .. h_num_installed_languages LOOP
      l_stmt := 'INSERT INTO '||l_dim_table||' ('||
                         ' code, user_code, name, language, source_lang '||
            l_t1||
                         ' ) values (:1,:2,:3,:4,:5 ' ||l_t2 ||' )';
        execute immediate l_stmt using l_code,l_user_code, l_name, h_installed_languages(h_i),l_source_lang;
      END LOOP;
    --commit;
    end if;

end insertNormalRowNWM;

procedure updateNormalRowNWM(l_dim_table in varchar2, l_code in number,
l_user_code in varchar2, l_name in varchar2,l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out nocopy varchar2
)is
TYPE curcode IS REF CURSOR;
cv curcode;
l_code_number number;
l_stmt varchar2(3000);
l_t1 varchar2(1000):=null;
l_t2 varchar2(1000):=null;
l_source_lang varchar2(4);
UsercodeChange boolean ;
begin
   l_message := null;
   if (checkrecord(l_dim_table, l_user_code, l_name, l_code)) then
      if (l_parentcount >= 1) then
         l_t2 := '('||l_fklist(1)||' is null or '||l_fklist(1)||'_USR is null';
         for i in 2 ..l_parentcount loop
            l_t2 := l_t2||' or '||l_fklist(i)||' is null or '||l_fklist(i)||'_USR is null';
         end loop;
         l_t2 := l_t2||')';
      end if;
      l_stmt:='select code from '||l_dim_table||' where (user_code=:1 or name=:2) and code!=:3 and '||l_t2;
      open cv for l_stmt using l_user_code, l_name, l_code;
      fetch cv into l_code_number;
      close cv;
      if (l_code_number is not null) then
         deleteNormalRow(l_dim_table, l_code_number);
      else
         l_message:=fnd_message.get_string('BSC','BSC_PMD_LDR_UNICONSTR_VIOLATE');
      end if;
   end if;
   if (l_message is null) then
      UsercodeChange:=checkUsercodeChange(l_dim_table, l_code, l_user_code);
      l_source_lang:=USERENV('LANG');
      for i in 1 ..l_parentcount loop
        l_t1:=l_t1||' , '||l_fklist(i)||'='||to_number(l_fkvaluelist(i))||
        ' , '||l_fklist(i)||'_USR='''||l_fkuservaluelist(i)||'''';
      end loop;
      l_stmt:=' update '||l_dim_table||' set '||
        ' user_code=:1 '||l_t1||'  where code=:2 ';
      execute immediate l_stmt using l_user_code, l_code;
      --commit;
      --l_stmt:=' update '||l_dim_table||' set '||
      --  ' name=:1, source_lang=:2 where code=:3 and language=:4 ';
      --execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang;
      l_stmt:=' update '||l_dim_table||' set '||
        ' name=:1, source_lang=:2 where code=:3 and (language=:4 or source_lang=:5) ';
      execute immediate l_stmt using l_name, l_source_lang, l_code, l_source_lang, l_source_lang;
      --commit;

      if (UsercodeChange and checkChild(l_dim_table) > 0) then
        cascadeUsercodeChange(l_dim_table,  l_code, l_user_code);
      end if;
    end if;
end updateNormalRowNWM;

procedure saveNormalRowNWM(l_dim_table in varchar2,  l_code in number,
l_user_code in varchar2, l_name in varchar2, l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out  nocopy varchar2) is
l_code_number number;
l_fkcode_number number;
l_name2 varchar2(2000);
begin
   l_name2:=removeComma(l_name);
   if (l_code is not null) then
     l_code_number:=to_number(l_code);
     updateNormalRowNWM(l_dim_table,l_code_number,
      l_user_code,l_name2,l_parentcount,l_fklist,
    l_fkvaluelist,l_fkuservaluelist,l_message );
   else
     insertNormalRowNWM(l_dim_table,
      l_user_code,l_name2,l_parentcount,l_fklist,
    l_fkvaluelist,l_fkuservaluelist,  l_message );
   end if;
end  saveNormalRowNWM;

FUNCTION  checkUsercodeChange(l_dim_table in varchar2, l_code in number,
l_user_code in varchar2) return boolean is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(400);
l_old_user_code varchar2(2000);
begin
 l_stmt:='select user_code from '||l_dim_table ||' where code=:1';
 open cv for l_stmt using l_code;
 fetch cv into l_old_user_code;
 close cv;
 if (l_old_user_code=l_user_code) then
   return false;
 else
   return true;
 end if;
end;

Function checkChild(l_dim_table in varchar2) return number is
TYPE curtyp IS REF CURSOR;
cv       curtyp;
l_stmt varchar2(1500);
l_count number;
begin
 l_stmt:='SELECT count(*) FROM BSC_SYS_DIM_LEVELS_B T, BSC_SYS_DIM_LEVEL_RELS R, BSC_SYS_DIM_LEVELS_B P WHERE T.DIM_LEVEL_ID = R.DIM_LEVEL_ID and R.PARENT_DIM_LEVEL_ID =P.dim_level_id AND R.RELATION_TYPE = 1  and P.level_table_name=:1';
 open cv for l_stmt using l_dim_table;
 fetch cv into l_count;
 close cv;
 return l_count;
end;

procedure cascadeUsercodeChange(l_dim_table in varchar2,  l_code in number,
l_user_code in varchar2) is
l_childtable varchar2(50);
l_pk        varchar2(100);
l_stmt      varchar2(800);
begin

        IF (CHILD%isopen) THEN
                close CHILD;
        END IF;
        open CHILD(l_dim_table);
        LOOP
         fetch CHILD into l_childtable, l_pk;
         exit when CHILD%notfound;
     l_stmt:='update '||l_childtable ||' set '||l_pk||'_USR =:1 '||
           ' where '||l_pk||' = :2';
         execute immediate l_stmt using l_user_code, l_code;
         commit;
        END LOOP;

        close CHILD;
end;

procedure checkViewExist(p_view_name varchar2,l_message out nocopy varchar2) is
l_sql varchar2(2000);
begin
 l_sql:='select ''1'' from '||p_view_name||' where rownum=1';
 execute immediate l_sql;
 l_message:=null;
 exception
  when others then
      l_message:=null;
       fnd_message.set_name('BSC','BSC_PMD_LDR_VIEW_NOT_EXIST');
       fnd_message.set_token('VIEW_NAME',p_view_name);
       l_message:=fnd_message.get;


end;

procedure checkMetadata(p_table_name varchar2,p_query varchar2, l_message out nocopy varchar2) is
l_sql varchar2(2000);
begin
 -- l_sql:='select ''1'' from '||p_view_name||' where rownum=1';
 execute immediate p_query;
 l_message:=null;
 exception
  when others then
      l_message:=null;
       fnd_message.set_name('BSC','BSC_PMD_LDR_METADATACORRUPTION');
       fnd_message.set_token('TABLE_NAME',p_table_name);
       l_message:=fnd_message.get;


end;

End bsc_dimension_edit;

/
