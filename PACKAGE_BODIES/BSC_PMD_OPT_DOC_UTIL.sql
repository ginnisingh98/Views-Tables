--------------------------------------------------------
--  DDL for Package Body BSC_PMD_OPT_DOC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMD_OPT_DOC_UTIL" AS
/* $Header: BSCPDGB.pls 120.6 2006/04/18 15:43:12 calaw noship $ */

  G_BSC_SCHEMA VARCHAR2(100) := BSC_APPS.get_user_schema('BSC');
  G_APPS_SCHEMA VARCHAR2(100) := BSC_APPS.get_user_schema('APPS');

  G_REL_DISPLAY_TABLE VARCHAR2(100):= 'BSC_DB_TABLES_RELS_DISPLAY';
  G_MASTER_DISPLAY_TABLE VARCHAR2(100):= 'BSC_DB_TABLES_DISPLAY';
  G_T_COLLAPSE_TEMP VARCHAR2(100):= G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP';

  TYPE table_mv_pair IS record(table_name varchar2(30), mv_name varchar2(30), mv_type varchar2(10));
  TYPE table_mv_pair_tab IS TABLE OF table_mv_pair INDEX BY PLS_INTEGER;
  l_tab_mv table_mv_pair_tab;

  TYPE v_n IS RECORD(tab_index NUMBER);
  TYPE v_n_v is table OF v_n INDEX BY VARCHAR2(50);
  tab_mv_index v_n_v;

  PROCEDURE DEBUG(TEXT VARCHAR2)
  IS
  BEGIN
    --DBMS_OUTPUT.PUT_LINE(TEXT);
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    --IF (FND_LOG.TEST(FND_LOG.LEVEL_ERROR, G_BSC_SCHEMA||'.BSC_PMD_OPT_DOC_UTIL')) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_BSC_SCHEMA||'.BSC_PMD_OPT_DOC_UTIL',TEXT);
    END IF;
  END;

  Procedure POPULATE_DISPLAY_TYPE
  IS
  BEGIN
    UPDATE bsc_db_tables_display
    set DISPLAY_TYPE = 'TABLE'
    where PHYSICAL_TYPE = 'TABLE';

    UPDATE bsc_db_tables_display
    set DISPLAY_TYPE = 'ANALYTICAL_WORKSPACES'
    where PHYSICAL_TYPE = 'VIEW'
    and TABLE_NAME_DISPLAY LIKE 'BSC\_S%' ESCAPE '\'
    and exists (SELECT 1
                from BSC_KPI_PROPERTIES
                where INDICATOR =
                        TO_NUMBER(
                          SUBSTR(TABLE_NAME_DISPLAY,
                                 INSTR(TABLE_NAME_DISPLAY,'_',1,2)+1,
                                 INSTR(TABLE_NAME_DISPLAY,'_',1,3)-INSTR(TABLE_NAME_DISPLAY,'_',1,2)-1))
                and PROPERTY_CODE = 'IMPLEMENTATION_TYPE'
                and PROPERTY_VALUE = 2);

    UPDATE bsc_db_tables_display
    set DISPLAY_TYPE = 'VIEW'
    where PHYSICAL_TYPE = 'VIEW'
    and (TABLE_NAME_DISPLAY NOT LIKE 'BSC\_S%' ESCAPE '\'
    or not exists (SELECT 1
                   from BSC_KPI_PROPERTIES
                   where INDICATOR =
                           TO_NUMBER(
                             SUBSTR(TABLE_NAME_DISPLAY,
                                    INSTR(TABLE_NAME_DISPLAY,'_',1,2)+1,
                                    INSTR(TABLE_NAME_DISPLAY,'_',1,3)-INSTR(TABLE_NAME_DISPLAY,'_',1,2)-1))
                   and PROPERTY_CODE = 'IMPLEMENTATION_TYPE'
                   and PROPERTY_VALUE = 2));

    UPDATE bsc_db_tables_display
    set DISPLAY_TYPE = 'MATERIALIZED_VIEW'
    where PHYSICAL_TYPE = 'MATERIALIZED VIEW';
    commit;
  END;

  Procedure analyze_table( p_table_name  in Varchar2) IS
    l_bsc_schema          VARCHAR2(30);
    l_stmt  		VARCHAR2(200);
    l_status		VARCHAR2(30);
    l_industry		VARCHAR2(30);
    errbuf                varchar2(2000):=null;
    retcode               varchar2(200):=null;
   BEGIN

      IF (FND_INSTALLATION.GET_APP_INFO('BSC', l_status, l_industry, l_bsc_schema)) THEN
         FND_STATS.GATHER_TABLE_STATS(errbuf,retcode, l_bsc_schema, p_table_name ) ;
      END IF;
   END;


  PROCEDURE GEN_MASTER_DISPLAY_SUM_MODE
  IS
    l_stmt varchar2(32767):= '
select
  TABLE_NAME TABLE_DISPLAY,
  TABLE_TYPE,
  null DISPLAY_TYPE,
  ''TABLE'' PHYSICAL_TYPE
from bsc_db_tables
--where TABLE_TYPE <> 2 -- commented by Arun as we need to display D tables also in the new UI

union /* for D tables*/  --bug 3918860
select
	TABLE_NAME TABLE_DISPLAY,
	2 TABLE_TYPE,
	null DISPLAY_TYPE,
  	''TABLE'' PHYSICAL_TYPE
from
	bsc_db_tables_rels
where
	TABLE_NAME like ''BSC_D_%''
';
  BEGIN
    l_stmt:='insert into ' || G_MASTER_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;


  PROCEDURE GEN_TBLREL_DISPLAY_SUM_MODE
  IS
    l_stmt varchar2(32767):= '
select *
from bsc_db_tables_rels
';

  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE GEN_TBLREL_DISPLAY  --bug 3918860
  IS
    l_stmt varchar2(32767):= '
		select *
		from bsc_db_tables_rels
		where table_name like ''BSC_D%''
		';

  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;


-- aguwalan : bug fix#4602415 : Modified to get the MV names from the PL/SQL table rather than expensive query
  FUNCTION GET_MV_BY_STABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2
  IS
  l_mv_name   VARCHAR2(30);

  BEGIN
    l_mv_name := null;
    IF ( INSTR(P_STABLE, 'BSC_SB_') > 0  ) THEN
      return null;
    ELSIF ( INSTR(P_STABLE, 'BSC_S_') = 0 ) THEN
      return P_STABLE;
    END IF;

    l_mv_name := l_tab_mv(tab_mv_index(P_STABLE||'-MV').tab_index).mv_name;

    IF (l_mv_name IS NULL) THEN
      l_mv_name := P_STABLE;
    END IF;

    return  l_mv_name;
  END;

-- aguwalan : bug fix#4602415 : Modified to get the ZMV name from the PL/SQL table rather than expensive query
  FUNCTION GET_ZMV_BY_STABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2
  IS
  l_zmv_name  VARCHAR2(30);

  BEGIN
    l_zmv_name := null;
    IF ( INSTR(P_STABLE, 'BSC_SB_') > 0  ) THEN
      return null;
    ELSIF ( INSTR(P_STABLE, 'BSC_S_') = 0 ) THEN
      return P_STABLE;
    END IF;
    l_zmv_name := l_tab_mv(tab_mv_index(P_STABLE||'-ZMV').tab_index).mv_name;
    IF (l_zmv_name IS NULL) THEN
      l_zmv_name := P_STABLE;
    END IF;
    return  l_zmv_name;
  END;

  FUNCTION GET_MV_BY_SBTABLE(
    P_STABLE              IN VARCHAR2
  ) RETURN VARCHAR2
  IS
  BEGIN
    IF(P_STABLE like 'BSC_SB%') THEN
      RETURN SUBSTR( P_STABLE, 1, INSTR(P_STABLE, '_', -1)) || 'MV' ;
    ELSE
      RETURN NULL;
    END IF;

  END;



  PROCEDURE TRUNC_BSC_TBL(TBL_NAME VARCHAR2)
  IS
  BEGIN
    execute immediate 'truncate table ' || G_BSC_SCHEMA || '.' || TBL_NAME;
    DEBUG('executed truncate table ' || G_BSC_SCHEMA || '.' || TBL_NAME);
  END;


  PROCEDURE CREATE_BSC_TMP_TABLE(p_table varchar2, p_stmt varchar2)
  IS
    l_stmt varchar2(32767) := 'create table ' || p_table || ' as ' || p_stmt;
  BEGIN

    begin
      execute immediate 'drop table ' || p_table;
      debug('drop table '|| p_table );
    exception when others then
      debug('encounter error ' || sqlerrm );
    end;

    debug('executing: ' || l_stmt);
    execute immediate l_stmt;
    debug('executed');
  END;

  PROCEDURE CREATE_BSC_T_COLLAPSE_TMP
  IS
    l_stmt varchar2(32767):= '
        select * from bsc_db_tables_rels
        where (SOURCE_TABLE_NAME like ''BSC_B%''
        and TABLE_NAME like ''BSC_T%'') OR
        SOURCE_TABLE_NAME like ''BSC_T%''
    ';
  BEGIN
    CREATE_BSC_TMP_TABLE(G_T_COLLAPSE_TEMP, l_stmt);

    l_stmt:='create index  '||G_T_COLLAPSE_TEMP||'_U1'||' on '||G_T_COLLAPSE_TEMP||'(SOURCE_TABLE_NAME, TABLE_NAME)';
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;


  PROCEDURE MAKE_T_COLLAPSE_AND_COPY
  IS
    l_stmt varchar2(32767):= '
select distinct BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(t1.table_name) table_name_display, k.source_table_name source_table_name_display, t1.relation_type
from '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP t1, '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP k
where t1.source_table_name in (
        select t2.table_name
        from '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP t2
        start with t2.source_table_name = k.source_table_name
        connect by prior t2.table_name = t2.source_table_name
        and t2.table_name like ''BSC_T%''
)
and t1.TABLE_NAME like ''BSC_S_%''
and k.source_table_name like ''BSC_B%''
and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(t1.table_name) is not null
union
select distinct BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(t1.table_name) table_name_display, k.source_table_name source_table_name_display, t1.relation_type
from '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP t1, '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP k
where t1.source_table_name in (
        select t2.table_name
        from '||G_BSC_SCHEMA||'.BSC_T_COLLAPSE_TEMP t2
        start with t2.source_table_name = k.source_table_name
        connect by prior t2.table_name = t2.source_table_name
        and t2.table_name like ''BSC_T%''
)
and t1.TABLE_NAME like ''BSC_SB_%''
and k.source_table_name like ''BSC_B%''
    ';
  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE COPY_THE_REST
  IS
    l_stmt varchar2(32767):= '
  select TABLE_NAME TABLE_NAME_DISPLAY, SOURCE_TABLE_NAME SOURCE_TABLE_NAME_DISPLAY, relation_type
  from bsc_db_tables_rels
  where (SOURCE_TABLE_NAME like ''BSC_I%''
  or SOURCE_TABLE_NAME like ''BSC_B%'' )
  and TABLE_NAME not like ''BSC_S%''
  and TABLE_NAME not like ''BSC_T%''
  and relation_type = 0
  union
  select distinct BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) TABLE_NAME_DISPLAY
                  , SOURCE_TABLE_NAME SOURCE_TABLE_NAME_DISPLAY, relation_type from bsc_db_tables_rels
  where
      SOURCE_TABLE_NAME like ''BSC_B%''
  and TABLE_NAME like ''BSC_S_%''
  and TABLE_NAME not like ''BSC_SB_%''
  and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) is not null
  and relation_type = 0
  union
  select distinct BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(TABLE_NAME) TABLE_NAME_DISPLAY
                  , SOURCE_TABLE_NAME SOURCE_TABLE_NAME_DISPLAY, relation_type from bsc_db_tables_rels
  where
      SOURCE_TABLE_NAME like ''BSC_B%''
  and TABLE_NAME like ''BSC_SB_%''
  and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(TABLE_NAME) is not null
  and relation_type = 0
  ';
  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE GEN_SB2S_OR_SB2S_DISPLAY
  IS
    l_stmt varchar2(32767):= '
select distinct
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(TABLE_NAME) TABLE_NAME_DISPALY,
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(SOURCE_TABLE_NAME) SOURCE_TABLE_NAME_DISPALY,
       RELATION_TYPE
from bsc_db_tables_rels
where source_table_name like ''BSC_SB_%''
and table_name like ''BSC_SB_%''
and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(TABLE_NAME) <>
    BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(SOURCE_TABLE_NAME)
union
select distinct
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) TABLE_NAME_DISPALY,
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(SOURCE_TABLE_NAME) SOURCE_TABLE_NAME_DISPALY,
       RELATION_TYPE
from bsc_db_tables_rels
where source_table_name like ''BSC_SB_%''
and table_name like ''BSC_S_%''
and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) is not null
';
  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE GEN_S2S_DISPLAY
  IS
    l_stmt varchar2(32767):= '
select distinct BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(table_name) table_name_display,
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(source_table_name) source_table_name_display,
       relation_type
from bsc_db_tables_rels
where
    SOURCE_TABLE_NAME like ''BSC_S_%''
and TABLE_NAME like ''BSC_S_%''
and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(table_name) <>
    BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(source_table_name)
and relation_type = 0
';
  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE GEN_ZMV_DISPLAY
  IS
    l_stmt varchar2(32767):= '
select distinct BSC_PMD_OPT_DOC_UTIL.GET_ZMV_BY_STABLE(table_name) table_name_display,
       BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(table_name) source_table_name_display,
       null relation_type
from bsc_db_tables
where
    TABLE_NAME like ''BSC_S_%''
and BSC_PMD_OPT_DOC_UTIL.GET_ZMV_BY_STABLE(table_name) is not null
';
  BEGIN
    l_stmt:='insert into ' || G_REL_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt;
    debug('executed ' || l_stmt);
  END;

  PROCEDURE GEN_MASTER_DISPLAY
  IS
    l_stmt varchar2(32767):= '
select /*I and B tables*/
  TABLE_NAME TABLE_DISPLAY,
  TABLE_TYPE,
  null DISPLAY_TYPE,
  ''TABLE'' PHYSICAL_TYPE
from bsc_db_tables
where ( TABLE_NAME like ''BSC_I_%'' OR TABLE_NAME like ''BSC_B_%'' OR TABLE_NAME like ''BSC_DI_%'' )
union /* for _MV*/
select
  BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) TABLE_DISPLAY,
  TABLE_TYPE,
  null DISPLAY_TYPE,
  o.object_type PHYSICAL_TYPE
from bsc_db_tables, all_objects o
where o.owner in (:1, :2)
and o.object_type in (''VIEW'', ''MATERIALIZED VIEW'')
and TABLE_TYPE = 1
and TABLE_NAME like ''BSC_S_%''
and BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME) is not null
and o.object_name = BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME)
union /* for _ZMV*/
select
  BSC_PMD_OPT_DOC_UTIL.GET_ZMV_BY_STABLE(TABLE_NAME) TABLE_DISPLAY,
  TABLE_TYPE,
  null DISPLAY_TYPE,
  o.object_type PHYSICAL_TYPE
from bsc_db_tables, all_objects o
where TABLE_TYPE =1
and TABLE_NAME like ''BSC_S_%''
and BSC_PMD_OPT_DOC_UTIL.GET_ZMV_BY_STABLE(TABLE_NAME) is not null
and o.owner in (:3, :4)
and o.object_type in (''VIEW'', ''MATERIALIZED VIEW'')
and o.object_name = BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_STABLE(TABLE_NAME)
union /* for SB tables*/
select
  BSC_PMD_OPT_DOC_UTIL.GET_MV_BY_SBTABLE(TABLE_NAME) TABLE_DISPLAY,
  TABLE_TYPE,
  null DISPLAY_TYPE,
  ''TABLE'' PHYSICAL_TYPE
from bsc_db_tables
where TABLE_TYPE = 1
and TABLE_NAME like ''BSC_SB_%''
union /* for D tables*/  --bug 3918860
select
	TABLE_NAME TABLE_DISPLAY,
	2 TABLE_TYPE,
	null DISPLAY_TYPE,
  	''TABLE'' PHYSICAL_TYPE
from
	bsc_db_tables_rels
where
	TABLE_NAME like ''BSC_D_%''
';
  BEGIN
    l_stmt:='insert into ' || G_MASTER_DISPLAY_TABLE || l_stmt ;
    execute immediate l_stmt using G_APPS_SCHEMA, G_BSC_SCHEMA, G_APPS_SCHEMA, G_BSC_SCHEMA;
    debug('executed ' || l_stmt);
  END;

-- aguwalan : bug fix#4602415 : Added code to build PL/SQL table rather than expensive query
PROCEDURE BUILD_STABLE_MV_ZMV_REP
IS
  CURSOR build_table_mv IS
    SELECT distinct TABLE_NAME,MV_NAME,decode(substr(MV_NAME,-3),'ZMV','ZMV','MV') mv_type FROM BSC_KPI_DATA_TABLES where MV_NAME is not null;
BEGIN
  OPEN build_table_mv;
  LOOP
    FETCH build_table_mv BULK COLLECT INTO l_tab_mv;
    EXIT WHEN build_table_mv%NOTFOUND;
  END LOOP;
  CLOSE build_table_mv;
  FOR i IN 1..l_tab_mv.count LOOP
    tab_mv_index(l_tab_mv(i).table_name||'-'||l_tab_mv(i).mv_type).tab_index:=i;
  END LOOP;

END;

  PROCEDURE GEN_TBL_RELS_DISPLAY
  IS
  BEGIN
    TRUNC_BSC_TBL(G_REL_DISPLAY_TABLE);
    TRUNC_BSC_TBL(G_MASTER_DISPLAY_TABLE);
    BUILD_STABLE_MV_ZMV_REP;
    IF (fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL') is not null ) THEN
      CREATE_BSC_T_COLLAPSE_TMP;
      MAKE_T_COLLAPSE_AND_COPY;
      COPY_THE_REST;
      GEN_S2S_DISPLAY;
      GEN_SB2S_OR_SB2S_DISPLAY;
      GEN_ZMV_DISPLAY;

      GEN_MASTER_DISPLAY;
      GEN_TBLREL_DISPLAY; --bug 3918860
    ELSE
      GEN_MASTER_DISPLAY_SUM_MODE;
      GEN_TBLREL_DISPLAY_SUM_MODE;
    END IF;
    commit;
    POPULATE_DISPLAY_TYPE;

    analyze_table(G_REL_DISPLAY_TABLE);
    analyze_table(G_MASTER_DISPLAY_TABLE);
  END;


  /*
   * For bug: 3662676
   *          Release the restriction on BSC_S_%, per tal with arun, per tal with arun
   *          it will work for other type of table renaming from now on.
   */
  PROCEDURE RENAME_TBL_RELS_DISPLAY(
    P_OLD              IN VARCHAR2,
    P_NEW              IN VARCHAR2
  ) IS
  BEGIN
    UPDATE BSC_DB_TABLES_DISPLAY
    SET TABLE_NAME_DISPLAY = P_NEW
    WHERE TABLE_NAME_DISPLAY = P_OLD;
    --AND P_NEW like 'BSC_S_%'
    --AND P_OLD like 'BSC_S_%';

    UPDATE BSC_DB_TABLES_RELS_DISPLAY
    SET SOURCE_TABLE_NAME_DISPLAY = P_NEW
    WHERE SOURCE_TABLE_NAME_DISPLAY = P_OLD;
    --AND P_NEW like 'BSC_S_%'
    --AND P_OLD like 'BSC_S_%';

    COMMIT;
  END;

END BSC_PMD_OPT_DOC_UTIL;

/
