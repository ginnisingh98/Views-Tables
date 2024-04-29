--------------------------------------------------------
--  DDL for Package Body BSC_WEB_ADI_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_WEB_ADI_LOADER_PKG" AS
/*$Header: BSCWADIB.pls 120.8.12000000.2 2007/06/08 12:41:25 karthmoh ship $*/

g_bsc_schema VARCHAR2(32);

/*---------------------------------------------------------------------------
 API to create the WebADI Integrator, an integrator will be created with the
 code = <table_name>_INTG, also creates a Security Rule so that this
 integrator is accessible from PMA <table_name>_SEC
 Security Rule is required so that the Integrator is available for PMA Responsibility
 This is possible by adding PMA functions to the security rule
----------------------------------------------------------------------------*/

PROCEDURE CREATE_INTEGRATOR( TABLE_NAME VARCHAR2 )
IS
  integrator_code VARCHAR2(100);
  l_stmt VARCHAR2(3000);
BEGIN
  l_stmt:='begin
             BNE_INTEGRATOR_UTILS.CREATE_INTEGRATOR
              (271, ''' || TABLE_NAME ||''' ,''Balanced Scorecard Loader '||TABLE_NAME ||''', USERENV(''LANG''),USERENV(''LANG''),0, :1);
              end;';

  EXECUTE IMMEDIATE l_stmt using OUT integrator_code;

  l_stmt:='begin
             BNE_SECURITY_UTILS_PKG.ADD_OBJECT_RULES(271,''' || integrator_code || ''' ,''INTEGRATOR'',
               '''|| TABLE_NAME ||'_SEC'',''FUNCTION'',''BSC_PMD_LDR_INPUT_TBL,BSC_PMD_LDR_DIM,BNE_ADI_CREATE_DOCUMENT,BSC_PMD_LDR_INPUT_TBL_DB,BSC_PMD_LDR_DIM_DB'',1355);
           end;';
  EXECUTE IMMEDIATE l_stmt;
END;


/*---------------------------------------------------------------------------
 API to create the WebADI Interface for each table with interface code =
 <table_name>_INTF, and assigns this interface to an already created Integrator
 for this table( <table_name>_INTG)
----------------------------------------------------------------------------*/
PROCEDURE CREATE_INTERFACE(TABLE_NAME VARCHAR2 ) IS
  l_stmt VARCHAR2(3000);
BEGIN
  l_stmt := 'INSERT INTO BNE_INTERFACES_B (APPLICATION_ID, INTERFACE_CODE,
              OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID, INTEGRATOR_CODE,
              INTERFACE_NAME, UPLOAD_TYPE, UPLOAD_OBJ_NAME, UPLOAD_PARAM_LIST_APP_ID,
              UPLOAD_PARAM_LIST_CODE, UPLOAD_ORDER, CREATED_BY, CREATION_DATE,
              LAST_UPDATED_BY, 	LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
     	    VALUES ( 271,'''|| TABLE_NAME ||'_INTF'', 1, 271, '''|| TABLE_NAME ||'_INTG'', '''||TABLE_NAME ||''', 1, NULL, NULL
              , NULL, NULL, 1355,  sysdate, 1355, NULL,  sysdate)';

  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_INTERFACES_TL ( APPLICATION_ID, INTERFACE_CODE, LANGUAGE,
              SOURCE_LANG, USER_NAME, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,LAST_UPDATE_DATE )
             VALUES ( 271, '''|| TABLE_NAME ||'_INTF'', USERENV(''LANG''),USERENV(''LANG'') ,''Interface: BSC Loader'',
              1355,  sysdate, 1355, NULL,  sysdate)';

  EXECUTE IMMEDIATE L_STMT;
END;

/*---------------------------------------------------------------------------
 API to create the WebADI Interface Columns corresponding to each Column in
 table, plus an additional column as a place holder for the Interface Table
 Name to be displayed in the Excel as the context
----------------------------------------------------------------------------*/
PROCEDURE CREATE_INTERFACE_COLUMNS( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  sequence_num NUMBER;
  CURSOR TAB_COL IS
    SELECT COLUMN_NAME,
           DECODE(DATA_TYPE, 'VARCHAR2', 2, 'NUMBER', 1, 'DATE', 3) TYPE ,
           (DECODE( NULLABLE, 'N', '* ')) || (SELECT Meaning FROM bsc_lookups WHERE lookup_type = 'BSC_PMA_WEBADI_HINTS' and lookup_code = DATA_TYPE) HINT,
           DECODE( NULLABLE, 'N', 'Y', 'N') NOT_NULL_FLAG,
           DATA_LENGTH
    FROM ALL_TAB_COLUMNS
    WHERE OWNER=g_bsc_schema AND TABLE_NAME = TAB_NAME
    order by COLUMN_ID;
  val_type VARCHAR2(8);
  val_obj_name VARCHAR2(100);
  field_size VARCHAR2(8);
BEGIN
   l_stmt :='INSERT INTO BNE_INTERFACE_COLS_B ( APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER,
                 SEQUENCE_NUM, INTERFACE_COL_TYPE, INTERFACE_COL_NAME, ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG,
                 READ_ONLY_FLAG, NOT_NULL_FLAG, SUMMARY_FLAG, MAPPING_ENABLED_FLAG, DATA_TYPE, FIELD_SIZE,
                 DEFAULT_TYPE, DEFAULT_VALUE, SEGMENT_NUMBER, GROUP_NAME, OA_FLEX_CODE, OA_CONCAT_FLEX, VAL_TYPE,
                 VAL_ID_COL, VAL_MEAN_COL, VAL_DESC_COL, VAL_OBJ_NAME, VAL_ADDL_W_C, VAL_COMPONENT_APP_ID,
                 VAL_COMPONENT_CODE, OA_FLEX_NUM, OA_FLEX_APPLICATION_ID, DISPLAY_ORDER, UPLOAD_PARAM_LIST_ITEM_NUM,
                 EXPANDED_SQL_QUERY, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE,
                 LOV_TYPE, OFFLINE_LOV_ENABLED_FLAG, VARIABLE_DATA_TYPE_CLASS )
              VALUES ( 271,'''|| TAB_NAME ||'_INTF'', 1,
                       1, 2, ''TAB_NAME_HEADER'', ''Y'', ''N'', ''Y'',
                       ''Y'', ''N'', ''N'', ''Y'', 2, NULL,
                       NULL, NULL, NULL, NULL, NULL, NULL , NULL,
                       NULL, NULL, NULL, NULL , NULL, NULL,
                       NULL, NULL, NULL, 1, NULL,
                       NULL, 1355,  sysdate, 1355, 0, sysdate,
                       NULL , ''N'',NULL )';
    EXECUTE IMMEDIATE L_STMT;

    l_stmt :='INSERT INTO BNE_INTERFACE_COLS_TL ( APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, LANGUAGE,
                SOURCE_LANG, USER_HINT, PROMPT_LEFT, USER_HELP_TEXT, PROMPT_ABOVE, CREATED_BY, CREATION_DATE,
                LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
              VALUES ( 271, '''|| TAB_NAME ||'_INTF'', 1, USERENV(''LANG''), USERENV(''LANG''), null,
                (select Meaning from bsc_lookups where lookup_type =''BSC_PMA_WEBADI_HINTS''
                 and lookup_Code = ''INTERFACE_TAB''), null, null, 1355,
                sysdate, 1355, 0, sysdate)';

    EXECUTE IMMEDIATE L_STMT;

  sequence_num := 2;
  val_type := 'JAVA';
  val_obj_name := 'oracle.apps.bsc.locking.BSCWebADILockValidator';
  FOR  TAB_COL_REC IN TAB_COL LOOP
    IF (TAB_COL_REC.TYPE = 3) THEN
      field_size := 'NULL';
    ELSE
      field_size := TAB_COL_REC.DATA_LENGTH;
    END IF;
    l_stmt :='INSERT INTO BNE_INTERFACE_COLS_B ( APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER,
                 SEQUENCE_NUM, INTERFACE_COL_TYPE, INTERFACE_COL_NAME, ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG,
                 READ_ONLY_FLAG, NOT_NULL_FLAG, SUMMARY_FLAG, MAPPING_ENABLED_FLAG, DATA_TYPE, FIELD_SIZE,
                 DEFAULT_TYPE, DEFAULT_VALUE, SEGMENT_NUMBER, GROUP_NAME, OA_FLEX_CODE, OA_CONCAT_FLEX, VAL_TYPE,
                 VAL_ID_COL, VAL_MEAN_COL, VAL_DESC_COL, VAL_OBJ_NAME, VAL_ADDL_W_C, VAL_COMPONENT_APP_ID,
                 VAL_COMPONENT_CODE, OA_FLEX_NUM, OA_FLEX_APPLICATION_ID, DISPLAY_ORDER, UPLOAD_PARAM_LIST_ITEM_NUM,
                 EXPANDED_SQL_QUERY, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE,
                 LOV_TYPE, OFFLINE_LOV_ENABLED_FLAG, VARIABLE_DATA_TYPE_CLASS )
              VALUES ( 271,'''|| TAB_NAME ||'_INTF'', 1,
                     '||sequence_num ||', 1, '''|| TAB_COL_REC.COLUMN_NAME ||''', ''Y'', ''Y'', ''Y'',
                     ''N'', '''||TAB_COL_REC.NOT_NULL_FLAG||''', ''N'', ''Y'', '|| TAB_COL_REC.TYPE ||', ' ||field_size||',
                     NULL, NULL, NULL, NULL, NULL, NULL, ''' || val_type || ''',
                     NULL, NULL, NULL,  '''|| val_obj_name ||''' , NULL, NULL,
                     NULL, NULL, NULL, '||sequence_num||', NULL,
                     NULL, 1355, sysdate, 1355, 0, sysdate,
                     NULL, ''N'', NULL )';

    EXECUTE IMMEDIATE L_STMT;

    l_stmt :='INSERT INTO BNE_INTERFACE_COLS_TL ( APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, LANGUAGE,
                SOURCE_LANG, USER_HINT, PROMPT_LEFT, USER_HELP_TEXT, PROMPT_ABOVE, CREATED_BY, CREATION_DATE,
                LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
              VALUES ( 271, '''|| TAB_NAME ||'_INTF'', '||sequence_num ||', USERENV(''LANG''), USERENV(''LANG''), ''' || TAB_COL_REC.HINT ||''',
                '''|| TAB_COL_REC.COLUMN_NAME ||''', ''' || TAB_COL_REC.HINT ||''', '''|| TAB_COL_REC.COLUMN_NAME ||''', 1355,
                sysdate, 1355, 0, sysdate)';

    EXECUTE IMMEDIATE L_STMT;

    sequence_num := sequence_num +1;
    -- reseting val_type and val_obj_name for remaining columns
    val_type := null;
    val_obj_name := null;
  END LOOP;
END;

/*---------------------------------------------------------------------------
 API to create metadata about Layouts, Layout Blocks, Layout Columns
 Two Layout blocks are created one for the Context(Interface Table Name) and
 other for the actual table
 Layour code = <table_name>_L
----------------------------------------------------------------------------*/
PROCEDURE CREATE_LAYOUT( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  counter number;
  CURSOR TAB_COL IS
    SELECT COLUMN_NAME,
           DECODE(DATA_TYPE, 'VARCHAR2', 2, 'NUMBER', 1, 'DATE', 3) TYPE
    FROM ALL_TAB_COLUMNS WHERE OWNER=g_bsc_schema AND TABLE_NAME = TAB_NAME
    order by COLUMN_ID;

BEGIN
  l_stmt:='INSERT INTO BNE_LAYOUTS_B ( APPLICATION_ID, LAYOUT_CODE, OBJECT_VERSION_NUMBER, STYLESHEET_APP_ID,
             STYLESHEET_CODE, INTEGRATOR_APP_ID, INTEGRATOR_CODE, STYLE, STYLE_CLASS, REPORTING_FLAG,
             REPORTING_INTERFACE_APP_ID, REPORTING_INTERFACE_CODE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN, LAST_UPDATE_DATE, CREATE_DOC_LIST_APP_ID, CREATE_DOC_LIST_CODE )
          VALUES ( 271,  '''|| TAB_NAME ||'_L'', 1, 231, ''DEFAULT'', 271, '''|| TAB_NAME ||'_INTG'', NULL,
            ''BNE_PAGE'', ''N'', NULL, NULL, sysdate, 1355, 1355, NULL,  sysdate, 271, NULL)';

  EXECUTE IMMEDIATE L_STMT;

  l_stmt:='INSERT INTO BNE_LAYOUTS_TL ( APPLICATION_ID, LAYOUT_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE )
           VALUES ( 271,'''|| TAB_NAME ||'_L'', USERENV(''LANG''), USERENV(''LANG''), ''BSC Default Layout'', 1355,
             sysdate, 1355, 0, sysdate)';

  EXECUTE IMMEDIATE L_STMT;

  -- Creating Layout Block for the Context i.e Interface Table Name
  l_stmt:='INSERT INTO BNE_LAYOUT_BLOCKS_B ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, OBJECT_VERSION_NUMBER,
             PARENT_ID, LAYOUT_ELEMENT, STYLE_CLASS, STYLE, ROW_STYLE_CLASS, ROW_STYLE, COL_STYLE_CLASS,
             COL_STYLE, PROMPT_DISPLAYED_FLAG, PROMPT_STYLE_CLASS, PROMPT_STYLE, HINT_DISPLAYED_FLAG,
             HINT_STYLE_CLASS, HINT_STYLE, ORIENTATION, LAYOUT_CONTROL, DISPLAY_FLAG, BLOCKSIZE, MINSIZE,
             MAXSIZE, SEQUENCE_NUM, PROMPT_COLSPAN, HINT_COLSPAN, ROW_COLSPAN, SUMMARY_STYLE_CLASS,
             SUMMARY_STYLE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
           VALUES ( 271, '''|| TAB_NAME ||'_L'', 1, 1, NULL, ''CONTEXT'', ''BNE_CONTEXT'', NULL, ''BNE_CONTEXT_ROW'',
             NULL, NULL, NULL, ''Y'', ''BNE_CONTEXT_HEADER'', NULL, ''Y'', ''BNE_CONTEXT_HINT'', NULL, ''HORIZONTAL'',
             ''COLUMN_FLOW'', ''Y'', 1, 1, 1, 20, 2, 2, 2, ''BNE_LINES_TOTAL'', NULL, 1355,
             sysdate, 1355, 1355, sysdate)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt:='INSERT INTO BNE_LAYOUT_BLOCKS_TL ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, USER_NAME, LANGUAGE,
             SOURCE_LANG, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
           VALUES ( 271, '''|| TAB_NAME ||'_L'', 1, ''Context'', USERENV(''LANG''), USERENV(''LANG''), 1355,
             sysdate, 1355, 0, sysdate)';
  EXECUTE IMMEDIATE L_STMT;

  -- Creating Layout Block for the Data
  l_stmt:='INSERT INTO BNE_LAYOUT_BLOCKS_B ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, OBJECT_VERSION_NUMBER,
             PARENT_ID, LAYOUT_ELEMENT, STYLE_CLASS, STYLE, ROW_STYLE_CLASS, ROW_STYLE, COL_STYLE_CLASS,
             COL_STYLE, PROMPT_DISPLAYED_FLAG, PROMPT_STYLE_CLASS, PROMPT_STYLE, HINT_DISPLAYED_FLAG,
             HINT_STYLE_CLASS, HINT_STYLE, ORIENTATION, LAYOUT_CONTROL, DISPLAY_FLAG, BLOCKSIZE, MINSIZE,
             MAXSIZE, SEQUENCE_NUM, PROMPT_COLSPAN, HINT_COLSPAN, ROW_COLSPAN, SUMMARY_STYLE_CLASS,
             SUMMARY_STYLE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
           VALUES ( 271, '''|| TAB_NAME ||'_L'', 2, 1, NULL, ''LINE'', ''BNE_LINES'', NULL, ''BNE_LINES_ROW'',
             NULL, NULL, NULL, ''Y'', ''BNE_LINES_HEADER'', NULL, ''Y'', ''BNE_LINES_HINT'', NULL, ''VERTICAL'',
             ''TABLE_FLOW'', ''Y'', 10, 1, 1, 10, NULL, NULL, NULL, ''BNE_LINES_TOTAL'', NULL, 1355,
             sysdate, 1355, 1355, sysdate)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt:='INSERT INTO BNE_LAYOUT_BLOCKS_TL ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, USER_NAME, LANGUAGE,
             SOURCE_LANG, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
           VALUES ( 271, '''|| TAB_NAME ||'_L'', 2, ''Line'', USERENV(''LANG''),USERENV(''LANG''), 1355,
             sysdate, 1355, 0, sysdate)';
  EXECUTE IMMEDIATE L_STMT;

  -- Creating Layout Column for the Context i.e Interface Table Name
  l_stmt:='INSERT INTO BNE_LAYOUT_COLS ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, OBJECT_VERSION_NUMBER,
             INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM, SEQUENCE_NUM, STYLE, STYLE_CLASS,
             HINT_STYLE, HINT_STYLE_CLASS, PROMPT_STYLE, PROMPT_STYLE_CLASS, DEFAULT_TYPE, DEFAULT_VALUE,
             CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
           VALUES ( 271, '''|| TAB_NAME ||'_L'', 1, 1, 271, '''|| TAB_NAME ||'_INTF'',1 ,
              10, NULL, NULL, NULL, NULL, NULL, NULL, ''CONSTANT'', '''|| TAB_NAME ||''', 1355,
              sysdate, 1355, 1355, sysdate)';
   EXECUTE IMMEDIATE L_STMT;

  counter :=2;
  FOR  TAB_COL_REC IN TAB_COL LOOP
    l_stmt:='INSERT INTO BNE_LAYOUT_COLS ( APPLICATION_ID, LAYOUT_CODE, BLOCK_ID, OBJECT_VERSION_NUMBER,
               INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM, SEQUENCE_NUM, STYLE, STYLE_CLASS,
               HINT_STYLE, HINT_STYLE_CLASS, PROMPT_STYLE, PROMPT_STYLE_CLASS, DEFAULT_TYPE, DEFAULT_VALUE,
               CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE )
             VALUES ( 271, '''|| TAB_NAME ||'_L'', 2, 1, 271, '''|| TAB_NAME ||'_INTF'',' || counter ||' ,
                ' || (counter*10)||', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1355,
                sysdate, 1355, 1355, sysdate)';

    EXECUTE IMMEDIATE L_STMT;
    counter := counter + 1;
  END LOOP;

END;

/*---------------------------------------------------------------------------
 API to create Content Metadata for the Integrator.
 COntent code = <table_name>_CNT
----------------------------------------------------------------------------*/
PROCEDURE CREATE_CONTENT(
  TAB_NAME VARCHAR2
, x_errbuf OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2)
IS
  CURSOR TAB_COL IS
    SELECT COLUMN_NAME
    FROM ALL_TAB_COLUMNS WHERE OWNER=g_bsc_schema AND TABLE_NAME = TAB_NAME
    order by COLUMN_ID;
  col_list VARCHAR2(5000);
  query    VARCHAR2(5000);
  content_code VARCHAR2(100);
  l_stmt VARCHAR2(3000);
BEGIN
  x_retcode := FND_API.G_RET_STS_SUCCESS;
  col_list := '';
  FOR  TAB_COL_REC IN TAB_COL LOOP
    col_list := col_list || TAB_COL_REC.COLUMN_NAME || ',';
    IF(LENGTH(col_list) > 1957) THEN
      x_errbuf := 'BSC_PMA_TOO_MANY_COLS';
      x_retcode := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;
  col_list := SUBSTR(col_list,1,LENGTH(col_list)-1);
  query := ' SELECT ' || col_list || ' FROM ' || TAB_NAME ;

  l_stmt:='BEGIN
             BNE_CONTENT_UTILS.CREATE_CONTENT_STORED_SQL(271, '''|| TAB_NAME ||''','''|| TAB_NAME || '_INTG'',
                ''BSC LOADER CONTENT'', :1, :2, USERENV(''LANG''), USERENV(''LANG''), 2, :3);
           END;';
  EXECUTE IMMEDIATE l_stmt using IN col_list, IN query, OUT content_code;
END;

/*---------------------------------------------------------------------------
 API to create Mapping Metadata for the Integrator.
 COntent code = <table_name>_MAP
----------------------------------------------------------------------------*/
PROCEDURE CREATE_MAPPING( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  CURSOR TAB_COL IS
    SELECT COLUMN_NAME
    FROM ALL_TAB_COLUMNS WHERE OWNER=g_bsc_schema AND TABLE_NAME = TAB_NAME
    order by COLUMN_ID;
  seq NUMBER;
BEGIN
  -- Creating Mapping to download data from the Interface Table to the Excel Sheet
  l_stmt := 'INSERT INTO BNE_MAPPINGS_B (APPLICATION_ID, MAPPING_CODE, OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID,
  INTEGRATOR_CODE, REPORTING_FLAG, REPORTING_INTERFACE_APP_ID, REPORTING_INTERFACE_CODE, LAST_UPDATE_DATE,
  LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN) VALUES (
  271, '''|| TAB_NAME ||'_MAP'' , 1, 271, '''|| TAB_NAME ||'_INTG'', ''N'', NULL, NULL, sysdate
  , 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_MAPPINGS_tl ( APPLICATION_ID, MAPPING_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
  271, '''|| TAB_NAME ||'_MAP'', USERENV(''LANG''), USERENV(''LANG''), ''None'',  sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Mapping columns from Content to Interface
  seq :=1;
  FOR  TAB_COL_REC IN TAB_COL LOOP
    l_stmt := 'INSERT INTO BNE_MAPPING_LINES ( APPLICATION_ID, MAPPING_CODE, SEQUENCE_NUM, CONTENT_APP_ID, CONTENT_CODE,
               CONTENT_SEQ_NUM, INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM, OBJECT_VERSION_NUMBER,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES
              ( 271, '''|| TAB_NAME ||'_MAP'', ' || seq || ', 271, '''|| TAB_NAME ||'_CNT'', ' || seq || ', 271
               , '''||TAB_NAME ||'_INTF'', ('||seq||'+1) ,1,  sysdate, 2,  sysdate , 2, 0)';
    EXECUTE IMMEDIATE L_STMT;
    seq := seq+1;
  END LOOP;
END;



/*---------------------------------------------------------------------------
 API to create Query for Duplicate Key Management for the Integrator.
 Query Code = <table_name>_Q
----------------------------------------------------------------------------*/
PROCEDURE CREATE_QUERY( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  query  VARCHAR2(1000);
BEGIN
  -- the query will fetch all the Duplicate profiles defined for a particular Integrator
  query := ' SELECT APPLICATION_ID ||'''':''''||DUP_PROFILE_CODE, USER_NAME ' ||
           ' FROM BNE_DUPLICATE_PROFILES_VL ' ||
           ' WHERE INTEGRATOR_APP_ID = 271 AND INTEGRATOR_CODE = '''''|| TAB_NAME ||'_INTG''''';

  l_stmt := 'INSERT INTO BNE_RAW_QUERY (APPLICATION_ID, QUERY_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER, QUERY,
	     LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN) VALUES (
             271,'''|| TAB_NAME ||'_Q'', 1, 1, '''|| query ||''', sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_QUERIES_B( APPLICATION_ID, QUERY_CODE, OBJECT_VERSION_NUMBER, QUERY_CLASS,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_Q'', 1, ''oracle.apps.bne.query.BneRawSQLQuery'', sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_QUERIES_TL( APPLICATION_ID, QUERY_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_Q'', USERENV(''LANG''), USERENV(''LANG''), ''Duplicate row Management'',  sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;
END;


/*---------------------------------------------------------------------------
 API to create 2 Parameters
 - Rows
 - Duplicate management
----------------------------------------------------------------------------*/
PROCEDURE CREATE_PARAM_DEFN( TAB_NAME VARCHAR2, key_cols NUMBER )
IS
  l_stmt VARCHAR2(3000);
BEGIN
  -- Parameter Definition for the Upload Parameter List
  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
             PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
             DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
             DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
             DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271, '''|| TAB_NAME ||'_ROW'', 2, ''bne:rows'', ''WEBADI:Upload'',6,1,null,null,null, ''N'',''Y'',''Y'',''FLAGGED'',
             null, null, null, null, 3, ''BNE_ROWS'', 100, 3, 2, 100, null, null, sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  IF (key_cols > 0) then
    l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
               PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
               DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
               DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
               DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
               271, '''|| TAB_NAME ||'_DUP'' ,1 , ''Duplicate Parameter Query'', ''WEBADI: Upload'', 5, 1, null, null, null,
               ''N'', ''Y'', ''Y'', null, null, null, null, null, 4, ''271:'|| TAB_NAME ||'_Q'', 100,
               3, 2, 100, null, null, sysdate, 2, sysdate, 2, 0)';
    EXECUTE IMMEDIATE L_STMT;
  END IF;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
             PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
             DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
             DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
             DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271, ''OBJECT_ID'', 1, ''OBJECT_ID'', ''WEBADI: Upload'',6,1,null,null,null, ''N'',''N'',''N'',
	     null, null, null, null, null, ''1'', null, 100, 2, 2, 100, null, null, sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
             PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
             DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
             DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
             DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271, ''OBJECT_TYPE'', 1, ''OBJECT_TYPE'', ''WEBADI: Upload'',6,1,null,null,null, ''N'',''N'',''N'',
	     null, null, null, null, null, ''1'', null, 100, 2, 2, 100, null, null, sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
             PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
             DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
             DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
             DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271, ''TABLE_NAME'', 1, ''TABLE_NAME'', ''WEBADI: Upload'',6,1,null,null,null, ''N'',''N'',''N'',
	     null, null, null, null, null, ''1'', null, 100, 2, 2, 100, null, null, sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_B( APPLICATION_ID, PARAM_DEFN_CODE, OBJECT_VERSION_NUMBER, PARAM_NAME,
             PARAM_SOURCE, PARAM_CATEGORY, DATATYPE, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, PARAM_RESOLVER,
             DEFAULT_REQUIRED_FLAG, DEFAULT_VISIBLE_FLAG, DEFAULT_USER_MODIFYABLE_FLAG, DEFAULT_STRING,
             DEFAULT_DATE, DEFAULT_NUMBER, DEFAULT_BOOLEAN_FLAG, DEFAULT_FORMULA, VAL_TYPE, VAL_VALUE, MAX_SIZE,
             DISPLAY_TYPE, DISPLAY_STYLE, DISPLAY_SIZE, HELP_URL, FORMAT_MASK,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271, ''QUERY_TIME'', 1, ''QUERY_TIME'', ''WEBADI: Upload'',6,1,null,null,null, ''N'',''N'',''N'',
	     null, null, null, null, null, ''1'', null, 100, 2, 2, 100, null, null, sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Parameter Definition TL
  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_ROW'',USERENV(''LANG''),USERENV(''LANG''),''Flagged rows'',null,''flagged rows'',
             BSC_WEB_ADI_LOADER_PKG.get_lookup_value(''BSC_PMA_WEBADI_UPL_ROW'',''ROWS_UPL''),null,
             null,null,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  IF (key_cols > 0) then
    l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
               DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
               271,'''|| TAB_NAME ||'_DUP'',USERENV(''LANG''),USERENV(''LANG''),''Duplicate Parameter Query'' ,null,''Update Columns'',
               BSC_WEB_ADI_LOADER_PKG.get_lookup_value(''BSC_PMA_WEBADI_UPL_DUP'',''DUPLICATE_REC''),
               null,null,null,sysdate, 2, sysdate, 2, 0)'; --BSC_LOOKUPS
    EXECUTE IMMEDIATE L_STMT;
  end if;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,''OBJECT_ID'',USERENV(''LANG''),USERENV(''LANG''),''Object Id'' ,null,''Object Id'',
             ''Object Id'',null,''Object Id'',null,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,''OBJECT_TYPE'',USERENV(''LANG''),USERENV(''LANG''),''Object Type'' ,null,''Object Type'',
             ''Object Type'',null,''Object Type'',null,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,''TABLE_NAME'',USERENV(''LANG''),USERENV(''LANG''),''Table Name'' ,null,''Table Name'',
             ''Table Name'',null,''Table Name'',null,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  l_stmt := 'INSERT INTO BNE_PARAM_DEFNS_TL(APPLICATION_ID, PARAM_DEFN_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             DEFAULT_STRING, DEFAULT_DESC, PROMPT_LEFT, PROMPT_ABOVE, USER_TIP, ACCESS_KEY,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,''QUERY_TIME'',USERENV(''LANG''),USERENV(''LANG''),''Query Time'' ,null,''Query Time'',
             ''Query Time'',null,''Query Time'',null,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;
END;

/*---------------------------------------------------------------------------
 API to create a Parameter List
 Parameter List Code = <table_name>_PL
----------------------------------------------------------------------------*/
PROCEDURE CREATE_PARAM_LIST( TAB_NAME VARCHAR2, key_cols NUMBER )
IS
  l_stmt VARCHAR2(3000);
  l_upload_param_list VARCHAR2(50);
  l_integrator  VARCHAR2(50);
BEGIN
  -- Create Upload Parameter List
  l_stmt := 'INSERT INTO BNE_PARAM_LISTS_B( APPLICATION_ID, PARAM_LIST_CODE, OBJECT_VERSION_NUMBER, PERSISTENT_FLAG,
             COMMENTS, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, LIST_RESOLVER,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'',3,''Y'',''WebADI: Upload Parameter List'',null,null,null,
             sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Parameter List TL
  l_stmt := 'INSERT INTO BNE_PARAM_LISTS_TL(APPLICATION_ID, PARAM_LIST_CODE, LANGUAGE, SOURCE_LANG,
             USER_NAME, USER_TIP, PROMPT_LEFT, PROMPT_ABOVE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'',USERENV(''LANG''),USERENV(''LANG''),''Web ADI: Upload Parameter List'', null, null,
             ''Upload Parameters'',sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating ROW parameter with Parameter list
  l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
             PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
             DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'',1,2,271,'''|| TAB_NAME ||'_ROW'',''bne:rows'',null,null,null,null,null,null,null,null
             ,sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating Duplicate parameter with Parameter list
  IF (key_cols > 0) then
    l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
               PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
               DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
               271,'''|| TAB_NAME ||'_UPL'', 2, 1, 271, '''|| TAB_NAME ||'_DUP'', ''bne:duplicateProfile'', null, null,
                null, null, null, null, null, null, sysdate, 2, sysdate, 2, 0)';
    EXECUTE IMMEDIATE L_STMT;
  END IF;

  -- Associating OBJECT_TYPE with Parameter list
  l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
             PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
             DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'', 3, 1, 271, ''OBJECT_TYPE'', ''OBJECT_TYPE'', null, null,
              null, null, null, null, null, null, sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating ObjectID with Parameter list
  l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
             PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
             DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'', 4, 1, 271, ''OBJECT_ID'', ''OBJECT_ID'', null, null,
              null, null, null, null, null, null, sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating TABLE_NAME with Parameter list
  l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
             PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
             DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'', 5, 1, 271, ''TABLE_NAME'', ''TABLE_NAME'', null, null,
              null, null, null, null, null, null, sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating QUERY_TIME with Parameter list
  l_stmt := 'INSERT INTO BNE_PARAM_LIST_ITEMS(APPLICATION_ID, PARAM_LIST_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
             PARAM_DEFN_APP_ID, PARAM_DEFN_CODE, PARAM_NAME, ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, STRING_VALUE,
             DATE_VALUE, NUMBER_VALUE, BOOLEAN_VALUE_FLAG, FORMULA_VALUE, DESC_VALUE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_UPL'', 6, 1, 271, ''QUERY_TIME'', ''QUERY_TIME'', null, null,
              null, null, null, null, null, null, sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Update the Integrator to use this Upload List
  l_upload_param_list := TAB_NAME ||'_UPL';
  l_integrator := TAB_NAME ||'_INTG';
  l_stmt := 'update bne_integrators_b set UPLOAD_PARAM_LIST_APP_ID=271, UPLOAD_PARAM_LIST_CODE= :1
             where integrator_code = :2 and APPLICATION_ID = 271';
  EXECUTE IMMEDIATE L_STMT USING l_upload_param_list, l_integrator;
END;


/*---------------------------------------------------------------------------
 API to create a Duplicate Profile
 Parameter List Code = <table_name>_REP / _ERR
----------------------------------------------------------------------------*/
PROCEDURE CREATE_DUP_PROFILE( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  l_non_uniq_cols VARCHAR2(3000);
  TYPE curType IS REF CURSOR ;
  c_non_uniq_cols  curType;
  l_seq_num VARCHAR2(10);
  l_interface_code VARCHAR2(100);
BEGIN
  l_non_uniq_cols :=
    'SELECT SEQUENCE_NUM FROM BNE_INTERFACE_COLS_B
    WHERE  APPLICATION_ID=271 AND INTERFACE_CODE= :1  AND SEQUENCE_NUM >1
    AND SEQUENCE_NUM NOT IN(SELECT INTERFACE_SEQ_NUM
    FROM BNE_INTERFACE_KEY_COLS WHERE INTERFACE_APP_ID=271 AND INTERFACE_CODE= :2)
    order by SEQUENCE_NUM';
  l_interface_code := tab_name||'_INTF';

  --Error Profile
  l_stmt := 'INSERT INTO BNE_DUPLICATE_PROFILES_B( APPLICATION_ID, DUP_PROFILE_CODE, OBJECT_VERSION_NUMBER,
             INTEGRATOR_APP_ID, INTEGRATOR_CODE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_ERR'',1,271,'''|| TAB_NAME ||'_INTG'',sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Duplicate Profile TL
  l_stmt := 'INSERT INTO BNE_DUPLICATE_PROFILES_TL(APPLICATION_ID, DUP_PROFILE_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_ERR'',USERENV(''LANG''),USERENV(''LANG''),
             BSC_WEB_ADI_LOADER_PKG.get_lookup_value(''BSC_PMA_WEBADI_UPL_ERR'',''ERROR_DUP''),sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating Duplicate Profile with Interface list
  l_stmt := 'INSERT INTO BNE_DUP_INTERFACE_PROFILES(INTERFACE_APP_ID, INTERFACE_CODE, DUP_PROFILE_APP_ID,
             DUP_PROFILE_CODE, OBJECT_VERSION_NUMBER, DUP_HANDLING_CODE, DEFAULT_RESOLVER_CLASSNAME,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_INTF'',271,'''|| TAB_NAME ||'_ERR'',1,''ROW_ERROR'',
             NULL, sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  --Replace Profile
  l_stmt := 'INSERT INTO BNE_DUPLICATE_PROFILES_B( APPLICATION_ID, DUP_PROFILE_CODE, OBJECT_VERSION_NUMBER,
             INTEGRATOR_APP_ID, INTEGRATOR_CODE,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_REP'',1,271,'''|| TAB_NAME ||'_INTG'',sysdate, 2,  sysdate , 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Duplicate Profile TL
  l_stmt := 'INSERT INTO BNE_DUPLICATE_PROFILES_TL(APPLICATION_ID, DUP_PROFILE_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_REP'',USERENV(''LANG''),USERENV(''LANG''),
             BSC_WEB_ADI_LOADER_PKG.get_lookup_value(''BSC_PMA_WEBADI_UPL_REP'',''REPLACE_DUP''),sysdate, 2, sysdate, 2, 0)'; --BSC_LOOKUPS
  EXECUTE IMMEDIATE L_STMT;

  -- Associating Duplicate Profile with Interface list
  l_stmt := 'INSERT INTO BNE_DUP_INTERFACE_PROFILES(INTERFACE_APP_ID, INTERFACE_CODE, DUP_PROFILE_APP_ID,
             DUP_PROFILE_CODE, OBJECT_VERSION_NUMBER, DUP_HANDLING_CODE, DEFAULT_RESOLVER_CLASSNAME,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
             271,'''|| TAB_NAME ||'_INTF'',271,'''|| TAB_NAME ||'_REP'',1,''TRANSFORM'',
             ''oracle.apps.bne.integrator.upload.BneKeepResolver'', sysdate, 2, sysdate, 2, 0)';
  EXECUTE IMMEDIATE L_STMT;

  -- Associating Non-unique columns for updation
  OPEN c_non_uniq_cols FOR l_non_uniq_cols USING l_interface_code, l_interface_code;
  LOOP
    FETCH c_non_uniq_cols INTO l_seq_num;
    EXIT WHEN c_non_uniq_cols%NOTFOUND;
    l_stmt := 'INSERT INTO BNE_DUP_INTERFACE_COLS( INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM,
               DUP_PROFILE_APP_ID, DUP_PROFILE_CODE, OBJECT_VERSION_NUMBER, RESOLVER_CLASSNAME,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
               271,'''|| TAB_NAME ||'_INTF'','||l_seq_num||',271, '''|| TAB_NAME ||'_REP'',
               1,''oracle.apps.bne.integrator.upload.BneReplaceResolver'', sysdate, 2, sysdate, 2, 0)';
    EXECUTE IMMEDIATE L_STMT;
  END LOOP;
  CLOSE c_non_uniq_cols;
END;

/*---------------------------------------------------------------------------
 API to create a Interface Keys
 Interface Key Code = <table_name>_UK
----------------------------------------------------------------------------*/
FUNCTION CREATE_INTERFACE_KEYS( TAB_NAME VARCHAR2 ) RETURN NUMBER
IS
  l_stmt VARCHAR2(3000);
  CURSOR unique_ind_col is
    SELECT COLUMN_POSITION+1 Interface_seq
    FROM ALL_INDEXES i, ALL_IND_COLUMNS c
    WHERE i.TABLE_OWNER=g_bsc_schema AND i.TABLE_NAME=TAB_NAME AND
          i.UNIQUENESS ='UNIQUE' AND i.OWNER=c.INDEX_OWNER AND I.INDEX_NAME = C.INDEX_NAME;
  key_cols NUMBER;
BEGIN
  key_cols := 0;
  -- Associate the Columns in the Unique index to the Unique Key created for an Interface
  FOR unique_ind_col_rec IN unique_ind_col LOOP
    IF (key_cols = 0) THEN
      -- Create the Unique Key for an Interface
      l_stmt := 'INSERT INTO BNE_INTERFACE_KEYS( APPLICATION_ID, KEY_CODE, OBJECT_VERSION_NUMBER, INTERFACE_APP_ID,
                 INTERFACE_CODE, KEY_TYPE, KEY_CLASS,
                 LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
                 271,'''|| TAB_NAME ||'_UK'',1,271,'''|| TAB_NAME ||'_INTF'',''DUP_UNIQUE'',
                 ''oracle.apps.bne.integrator.upload.BneTableInterfaceKey'',sysdate, 2,  sysdate , 2, 0)';
      EXECUTE IMMEDIATE L_STMT;
    END IF;
    l_stmt := 'INSERT INTO BNE_INTERFACE_KEY_COLS( APPLICATION_ID, KEY_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER,
               INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN ) VALUES (
               271,'''|| TAB_NAME ||'_UK'','||to_char(unique_ind_col_rec.Interface_seq-1) ||', 1, 271, '''|| TAB_NAME ||'_INTF'','
               ||to_char(unique_ind_col_rec.Interface_seq)||',sysdate, 2,  sysdate , 2, 0)';
    EXECUTE IMMEDIATE L_STMT;
    key_cols := key_Cols + 1;
  END LOOP;
  RETURN key_cols;
END;

/*---------------------------------------------------------------------------
 API to clear all the WebADI metadata for application=BSC and pertaining to
 a particular Interface Table
----------------------------------------------------------------------------*/
PROCEDURE clear_metadata( TAB_NAME VARCHAR2 )
IS
  l_stmt VARCHAR2(3000);
  l_code VARCHAR2(50);
  l_code_2 VARCHAR2(50);
BEGIN
  l_code := TAB_NAME||'_INTG';
  l_stmt := 'delete bne_integrators_b where application_id = 271 and INTEGRATOR_CODE =  :1';
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_integrators_tl
             where application_id = 271 and INTEGRATOR_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_SECURED_OBJECTS
             where application_id = 271 and OBJECT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_SEC';

  l_stmt := 'delete BNE_SECURITY_RULES
             where application_id = 271 and SECURITY_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_INTF';

  l_stmt := 'delete bne_interfaces_b
             where application_id = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_interfaces_tl
             where application_id = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_interface_cols_b
             where application_id = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_interface_cols_tl
             where application_id = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_L';

  l_stmt := 'delete bne_layouts_b
             where application_id = 271 and LAYOUT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_layouts_tl
             where application_id = 271 and LAYOUT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_layout_blocks_b
             where application_id = 271 and LAYOUT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_layout_blocks_tl
             where application_id = 271 and LAYOUT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete bne_layout_cols
             where application_id = 271 and LAYOUT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_CNT';

  l_stmt := 'delete BNE_CONTENTS_b
             where application_id = 271 and CONTENT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_CONTENTS_TL
             where application_id = 271 and CONTENT_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_MAP';

  l_stmt := 'delete BNE_MAPPINGS_B
             where application_id = 271 and MAPPING_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_MAPPINGS_TL
             where application_id = 271 and MAPPING_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_MAPPING_LINES
             where application_id = 271 and MAPPING_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_Q';

  l_stmt := 'delete BNE_RAW_QUERY
             where application_id = 271 and QUERY_CODE =  :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_QUERIES_B
             where application_id = 271 and QUERY_CODE =  :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_QUERIES_TL
             where application_id = 271 and QUERY_CODE =  :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_ROW';
  l_code_2 := TAB_NAME||'_DUP';

  l_stmt := 'delete BNE_PARAM_DEFNS_B
             where application_id = 271 and (PARAM_DEFN_CODE = :1 OR
                                             PARAM_DEFN_CODE = :2 OR
                                             PARAM_DEFN_CODE = ''OBJECT_TYPE''  OR
                                             PARAM_DEFN_CODE = ''OBJECT_ID''  OR
                                             PARAM_DEFN_CODE = ''TABLE_NAME'' OR
                                             PARAM_DEFN_CODE = ''QUERY_TIME'')' ;

  EXECUTE IMMEDIATE L_STMT USING l_code, l_code_2;

  l_stmt := 'delete BNE_PARAM_DEFNS_TL
             where application_id = 271 and (PARAM_DEFN_CODE = :1  OR
                                             PARAM_DEFN_CODE = :2  OR
                                             PARAM_DEFN_CODE = ''OBJECT_TYPE''  OR
                                             PARAM_DEFN_CODE = ''OBJECT_ID''  OR
                                             PARAM_DEFN_CODE = ''TABLE_NAME'' OR
                                             PARAM_DEFN_CODE = ''QUERY_TIME'')' ;
  EXECUTE IMMEDIATE L_STMT USING l_code, l_code_2;

  l_code := TAB_NAME||'_UPL';

  l_stmt := 'delete BNE_PARAM_LISTS_B
             where application_id = 271 and PARAM_LIST_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_PARAM_LISTS_TL
             where application_id = 271 and PARAM_LIST_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_PARAM_LIST_ITEMS
             where application_id = 271 and PARAM_LIST_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_REP';
  l_code_2 := TAB_NAME||'_ERR';

  l_stmt := 'delete BNE_DUPLICATE_PROFILES_B
             where application_id = 271 and (DUP_PROFILE_CODE = :1
                                           or DUP_PROFILE_CODE = :2)' ;
  EXECUTE IMMEDIATE L_STMT USING l_code, l_code_2;

  l_stmt := 'delete BNE_DUPLICATE_PROFILES_TL
             where application_id = 271 and (DUP_PROFILE_CODE = :1
                                           or DUP_PROFILE_CODE = :2)' ;
  EXECUTE IMMEDIATE L_STMT USING l_code, l_code_2;

  l_code := TAB_NAME||'_INTF';

  l_stmt := 'delete BNE_DUP_INTERFACE_PROFILES
             where INTERFACE_APP_ID = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_DUP_INTERFACE_COLS
             where INTERFACE_APP_ID = 271 and INTERFACE_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_code := TAB_NAME||'_UK';

  l_stmt := 'delete BNE_INTERFACE_KEYS
             where application_id = 271 and KEY_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

  l_stmt := 'delete BNE_INTERFACE_KEY_COLS
             where application_id = 271 and KEY_CODE = :1' ;
  EXECUTE IMMEDIATE L_STMT USING l_code;

END;

/*---------------------------------------------------------------------------
 API to get the BSC Schema name
----------------------------------------------------------------------------*/
FUNCTION get_bsc_schema return varchar2 is
  dummy1           VARCHAR2(32)    := null;
  dummy2           VARCHAR2(32)    := null;
  l_bsc_schema     VARCHAR2(32)    := null;
begin
  IF (FND_INSTALLATION.GET_APP_INFO('BSC', dummy1, dummy2, l_bsc_schema)) THEN
    NULL;
  END IF;
  return l_bsc_schema;
end;

/*---------------------------------------------------------------------------
 API to get the BSC Lookups
----------------------------------------------------------------------------*/
FUNCTION get_lookup_value(type VARCHAR2, code VARCHAR2) return varchar2 is
  lookup_value  VARCHAR2(80);
BEGIN
  SELECT meaning
  INTO lookup_value
  FROM bsc_lookups
  WHERE  APPLICATION_ID=271 and lookup_type = type AND lookup_code = code ;

  RETURN lookup_value;
END;

/*---------------------------------------------------------------------------
 API to create all the WebADI metadata for application=BSC and pertaining to
 a particular Interface Table, this api will be called from the JAVA layer
----------------------------------------------------------------------------*/
PROCEDURE Create_Metadata(TAB_NAME VARCHAR2, ERRBUF OUT NOCOPY VARCHAR2,RETCODE OUT NOCOPY VARCHAR2)
IS
  key_cols NUMBER;
BEGIN
  g_bsc_schema := get_bsc_schema();
  CLEAR_METADATA(TAB_NAME); --Clear
  CREATE_INTEGRATOR(TAB_NAME);
  CREATE_INTERFACE(TAB_NAME);
  CREATE_INTERFACE_COLUMNS(TAB_NAME);
  CREATE_LAYOUT(TAB_NAME);
  CREATE_CONTENT(TAB_NAME, ERRBUF,RETCODE);
  IF RETCODE <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
  END IF;
  CREATE_MAPPING(TAB_NAME);
  key_cols := CREATE_INTERFACE_KEYS( TAB_NAME );
  IF (key_cols > 0) then
    CREATE_QUERY(TAB_NAME);
    CREATE_DUP_PROFILE( TAB_NAME);
  END IF;
  CREATE_PARAM_DEFN( TAB_NAME, key_cols );
  CREATE_PARAM_LIST( TAB_NAME, key_cols );
  COMMIT;
  RETCODE := FND_API.G_RET_STS_SUCCESS;
  ERRBUF := ' ';
null;
END;



/*---------------------------------------------------------------------------
 API to clear all the WebADI metadata for application=BSC.
 Used during development
----------------------------------------------------------------------------*/
/*PROCEDURE clear_all_metadata
IS
BEGIN
  delete bne_integrators_b where application_id = 271;
  delete bne_integrators_tl where application_id = 271;
  delete BNE_SECURITY_RULES WHERE application_id = 271;
  delete BNE_SECURED_OBJECTS  WHERE application_id = 271;
  delete bne_interfaces_b where application_id = 271;
  delete bne_interfaces_tl where application_id = 271;
  delete bne_interface_cols_b where application_id = 271;
  delete bne_interface_cols_tl where application_id = 271;
  delete bne_layouts_b where application_id = 271;
  delete bne_layouts_tl where application_id = 271;
  delete bne_contents_b where application_id = 271;
  delete bne_contents_tl where application_id = 271;
  delete bne_layout_blocks_b where application_id = 271;
  delete bne_layout_blocks_tl where application_id = 271;
  delete bne_layout_cols where application_id = 271;
END;*/

END BSC_WEB_ADI_LOADER_PKG;

/
