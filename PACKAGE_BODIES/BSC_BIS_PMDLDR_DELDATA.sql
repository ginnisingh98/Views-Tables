--------------------------------------------------------
--  DDL for Package Body BSC_BIS_PMDLDR_DELDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_PMDLDR_DELDATA" AS
/* $Header: BSCPMDDB.pls 120.0 2005/06/01 14:57:20 appldev noship $ */

 TYPE T_KPI_REC_TYPE IS RECORD(
   indicator            BSC_KPIS_B.INDICATOR%TYPE
 );
 TYPE G_KPI_TAB_TYPE is table of T_KPI_REC_TYPE index by binary_integer;
 TYPE curType IS REF CURSOR ;

 TYPE T_TABLE_REC_TYPE IS RECORD(
   NAME             VARCHAR2(100)
 );

 TYPE G_TABLE_TAB_TYPE is table of T_TABLE_REC_TYPE index by binary_integer;

 G_KPI_TABLE  G_KPI_TAB_TYPE ;
 G_KPI_TABLE_SIZE binary_integer := 0;

 G_TABNAME_TABLE  G_TABLE_TAB_TYPE ;
 G_TABNAME_TABLE_SIZE binary_integer := 0;

 G_REC_LEVEL  number := 32767000;

 PROCEDURE  SET_RECURSIVE_LEVEL( P_lvl number)
 IS
 BEGIN
   G_REC_LEVEL := P_lvl;
 END;

 PROCEDURE ADD_TABLE(name varchar2)
 IS
 BEGIN
     BSC_APPS.Add_Value_Big_In_Cond( 3, name );
     G_TABNAME_TABLE_SIZE := G_TABNAME_TABLE_SIZE + 1;
     G_TABNAME_TABLE(G_TABNAME_TABLE_SIZE).name := name;

 END;

 PROCEDURE REFRESH_BSC_TMP_BIG_IN_COND
 IS
   l_dummy varchar2(2000);
 BEGIN
   l_dummy :=  BSC_APPS.Get_New_Big_In_Cond_Varchar2( 4, 'TABLE_NAME');

   For i in 1..G_TABNAME_TABLE_SIZE
   loop
     BSC_APPS.Add_Value_Big_In_Cond( 4, G_TABNAME_TABLE(i).name );
   end loop;
   --debug('Refreshed  ' || G_TABNAME_TABLE_SIZE || ' to temp'  );
   G_TABNAME_TABLE.delete;
   G_TABNAME_TABLE_SIZE := 0;
 END;

 FUNCTION get_indicatorstr
 RETURN varchar2
 IS
   l_string varchar2(3000) := '';
 BEGIN

   For i in 1..G_KPI_TABLE_SIZE
   loop
     if (i = 1) then
       l_string := l_string || G_KPI_TABLE(i).indicator ;
     else
       l_string := l_string || ', ' ||  G_KPI_TABLE(i).indicator ;
     end if;
   end loop;

   return l_string;
 End;



 PROCEDURE  DEBUG(txt varchar2)
 IS
 BEGIN
   --Cond added for bug 3964235
   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, 'bis.plsql.BSC_BIS_PMDLDR_DELDATA.DEBUG', txt);
   END IF;
 END;


 PROCEDURE INITIALIZE
 IS
 BEGIN
   G_KPI_TABLE_SIZE := 0;
   G_KPI_TABLE.delete;

   BSC_APPS.Init_Bsc_Apps;
   BSC_APPS.Init_Big_In_Cond_Table;

   G_TABNAME_TABLE_SIZE := 0;
   G_TABNAME_TABLE.delete;


 END;

 PROCEDURE SELECT_INDICATOR(p_ind number) IS
 BEGIN
   G_KPI_TABLE_SIZE := G_KPI_TABLE_SIZE + 1;
   G_KPI_TABLE(G_KPI_TABLE_SIZE).INDICATOR := p_ind;
 END;

 FUNCTION INIT_RELATED_TABLES(
    p_stmtWhereInIndics varchar2)
 RETURN NUMBER
 IS
   l_stmt varchar2(2000);
   cur_init_tbl          curType;
   l_tbl_name          varchar2(1000);
   l_rownum   number := 0;
 BEGIN

   l_stmt :=
   ' SELECT DISTINCT TABLE_NAME ' ||
   ' FROM BSC_KPI_DATA_TABLES_V ' ||
   ' WHERE (' ||  p_stmtWhereInIndics || ' ) ';
   -- || ' AND TABLE_NAME IS NOT NULL ';
   debug('Executing ' || l_stmt);
   open cur_init_tbl for l_stmt;
   loop
     FETCH cur_init_tbl INTO l_tbl_name;
     exit when cur_init_tbl%NOTFOUND;
     if ( l_tbl_name is not null ) then
       ADD_TABLE(l_tbl_name);
       l_rownum := l_rownum + 1;
     end if;
     --debug('Fetched ' || l_tbl_name || ' to BSC_TMP_BIG_IN_COND' );
   end loop;
   debug(l_rownum || ' rows fetched in INIT_RELATED_TABLES');
   return l_rownum;
   close cur_init_tbl;
   EXCEPTION
   WHEN OTHERS THEN
     close cur_init_tbl;
     raise;
 END;

 FUNCTION MARK_TABLES_BY_INDICATORS( p_stmtWhereInTables varchar2, p_stmtTempWhereInTables varchar2)
 RETURN NUMBER
 IS
   l_stmt varchar2(2000);
   cur_tbl_mark_by_ind          curType;
   l_tbl_name          varchar2(1000);
   l_stmtWhereNotInTables varchar2(1000);
   l_rownum number :=0;
 BEGIN
   l_stmtWhereNotInTables := p_stmtWhereInTables ;
   l_stmt :=
   ' SELECT TABLE_NAME ' ||
   ' FROM BSC_KPI_DATA_TABLES_V ' ||
   ' WHERE INDICATOR IN ( ' ||
   ' SELECT INDICATOR ' ||
   ' FROM BSC_KPI_DATA_TABLES_V ' ||
   ' WHERE ' ||  p_stmtTempWhereInTables ||
   ' ) ' ||
   ' AND TABLE_NAME IS NOT NULL' ||
   ' MINUS ' ||  l_stmtWhereNotInTables;

   debug('Executing '|| l_stmt);

   open cur_tbl_mark_by_ind for l_stmt;
   loop
     FETCH cur_tbl_mark_by_ind INTO l_tbl_name;
     exit when cur_tbl_mark_by_ind%NOTFOUND;
     ADD_TABLE(l_tbl_name);
     l_rownum := l_rownum+1;
     -- debug('Fetched ' || l_tbl_name || ' to BSC_TMP_BIG_IN_COND' );
   end loop;
   close cur_tbl_mark_by_ind;
   debug(l_rownum || ' rows fetched in MARK_TABLES_BY_INDICATORS ');

   return l_rownum;
   EXCEPTION
   WHEN OTHERS THEN
     close cur_tbl_mark_by_ind;
     raise;
  END;

 FUNCTION MARK_TABLES( p_stmtWhereInTables varchar2, p_stmtTempWhereInSrcTables varchar2,
                       p_stmtTempWhereInTables varchar2 )
 RETURN NUMBER
 IS
   l_stmt varchar2(2000);
   cur_tbl_mark          curType;
   l_tbl_name          varchar2(1000);
   l_stmtWhereNotInTables varchar2(1000);
   l_rownum       number := 0;
 BEGIN
   REFRESH_BSC_TMP_BIG_IN_COND;

   --l_stmtWhereNotInTables := ' NOT ( ' ||  p_stmtWhereInTables || ' ) ' ;
   l_stmtWhereNotInTables := p_stmtWhereInTables ;

   l_stmt :=
   ' SELECT * from ( SELECT TABLE_NAME ' ||
   ' FROM BSC_DB_TABLES_RELS WHERE ' || p_stmtTempWhereInSrcTables ||
   ' UNION ' ||
   ' SELECT SOURCE_TABLE_NAME ' ||
   ' FROM BSC_DB_TABLES_RELS WHERE ' || p_stmtTempWhereInTables || ' ) ' ||
   ' MINUS ' || l_stmtWhereNotInTables;

   debug('Executing '|| l_stmt);

   open cur_tbl_mark for l_stmt;
   loop
     FETCH cur_tbl_mark INTO l_tbl_name;
     exit when cur_tbl_mark%NOTFOUND;
     ADD_TABLE(l_tbl_name);
     l_rownum := l_rownum+1;
     -- debug('Fetched ' || l_tbl_name || ' to BSC_TMP_BIG_IN_COND' );
   end loop;
   l_rownum:= l_rownum + MARK_TABLES_BY_INDICATORS( p_stmtWhereInTables, p_stmtTempWhereInTables);
   close cur_tbl_mark;
   debug(l_rownum || ' rows fetched in MARK_TABLES ');
   return l_rownum;
   EXCEPTION
   WHEN OTHERS THEN
     close cur_tbl_mark;
     raise;
 END;

 PROCEDURE MARK_INDICATORS(
   p_stmtWhereInTables varchar2,
   p_stmtWhereInIndics varchar2
 )
 IS
   l_stmt varchar2(2000);
   l_kpi  number;
   l_stmtNotWhereInIndics varchar2(2000);
   l_stmtWhereInIndics varchar2(2000);

   cur_kpi_mark          curType;
   l_rownum       number := 0;
 BEGIN
   --l_stmtWhereInTables :=  substr(l_stmtWhereInTables, instr(l_stmtWhereInTables, 'IN') + 2 );
   l_stmtWhereInIndics:= BSC_APPS.Get_New_Big_In_Cond_Number( 5, 'INDICATOR');

   l_stmtNotWhereInIndics := substr(p_stmtWhereInIndics, instr(p_stmtWhereInIndics, ' IN') + 3 );
   l_stmt :=
       'SELECT DISTINCT INDICATOR ' ||
       ' FROM BSC_KPI_DATA_TABLES_V ' ||
       ' WHERE TABLE_NAME IN ( ' || p_stmtWhereInTables || ' ) ' ||
       --' WHERE ( ' || p_stmtWhereInTables || ' ) ' ||
       ' MINUS ' || l_stmtNotWhereInIndics ;
   debug('executing ' || l_stmt);
   open cur_kpi_mark for l_stmt;
   loop
     FETCH cur_kpi_mark INTO l_kpi;
     exit when cur_kpi_mark%NOTFOUND;
     BSC_APPS.Add_Value_Big_In_Cond( 5, l_kpi );

   end loop;
   close cur_kpi_mark;
 END;

 PROCEDURE GET_RELATED_INDICATORS
 IS
   l_stmtWhereInIndics varchar2(2000);
   l_stmtWhereInTables varchar2(2000);
   l_stmtTempWhereInSrcTables varchar2(2000);
   l_stmtTempWhereInSTables varchar2(2000);
   l_rownum   number :=0;
   l_rowmarked number;
   l_rec_level number := 0 ;
 BEGIN
   l_stmtWhereInIndics:= BSC_APPS.Get_New_Big_In_Cond_Number( 1, 'INDICATOR');
   l_stmtWhereInTables :=  BSC_APPS.Get_New_Big_In_Cond_Varchar2( 3, 'TABLE_NAME');
   l_stmtTempWhereInSrcTables :=  BSC_APPS.Get_New_Big_In_Cond_Varchar2( 4, 'SOURCE_TABLE_NAME');
   l_stmtTempWhereInSTables :=  BSC_APPS.Get_New_Big_In_Cond_Varchar2( 4, 'TABLE_NAME');
   l_stmtWhereInTables :=  substr(l_stmtWhereInTables, instr(l_stmtWhereInTables, 'IN') + 2 );


   debug('l_stmtWhereInIndics '||l_stmtWhereInIndics);
   debug('l_stmtWhereInTables ' || l_stmtWhereInTables);
   debug('l_stmtTempWhereInSrcTables ' || l_stmtTempWhereInSrcTables);
   debug('l_stmtTempWhereInSTables ' || l_stmtTempWhereInSTables);

   For i in 1..G_KPI_TABLE_SIZE
   loop
     BSC_APPS.Add_Value_Big_In_Cond(1, G_KPI_TABLE(i).indicator);
     -- debug('Fetched ' || G_KPI_TABLE(i).indicator || ' to BSC_TMP_BIG_IN_COND' );
   end loop;
   l_rownum := INIT_RELATED_TABLES( l_stmtWhereInIndics);

   while (l_rec_level < G_REC_LEVEL)
   loop
     debug('Recursive ' || l_rec_level );
     l_rowmarked := MARK_TABLES( l_stmtWhereInTables, l_stmtTempWhereInSrcTables, l_stmtTempWhereInSTables);
     l_rownum := l_rownum + l_rowmarked;
     l_rec_level := l_rec_level + 1;

     exit when (l_rowmarked = 0);
   end loop;
   debug('Toatl ' || l_rownum || ' rows fetched ');
   MARK_INDICATORS( l_stmtWhereInTables ,l_stmtWhereInIndics );

 END;

END BSC_BIS_PMDLDR_DELDATA;

/
