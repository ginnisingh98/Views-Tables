--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_SEARCH_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_SEARCH_INDEX_PKG" AS
-- $Header: POS_SUPPLIER_SEARCH_INDEX_PKG.plb 120.0.12010000.3 2014/12/24 04:55:08 irasoolm noship $

-- Constants
G_PKG_NAME              CONSTANT VARCHAR2(30) :='POS_SUPPLIER_SEARCH_INDEX_PKG';

/**
 ** Proc : create_index
 ** Desc : Create interMedia index  with multi-lexer for each installed
 **        language in FND_LANGUAGES, including the base language.
 **/

PROCEDURE create_index
IS
  l_api_name            CONSTANT VARCHAR2(30):= 'create_index';
  l_err_loc             PLS_INTEGER := 0;

  l_lang                fnd_languages.language_code%TYPE;
  l_nls_lang            fnd_languages.nls_language%TYPE;

  l_ctx_index_tbsp      VARCHAR2(100):='USER_IDX';
  l_ctx_data_tbsp       VARCHAR2(100):='USER_DATA';

  l_is_object_registered        VARCHAR2(10);
  l_ts_exists                   VARCHAR2(10);

  l_ctx_section_group  	VARCHAR2(30) := 'POS_SUPPLIERS_SECTGRP';
  l_ctx_desc_tag	VARCHAR2(30) := NULL;
  l_ctx_pref_lexer	VARCHAR2(30) := NULL;
  l_ctx_pref_datastore	VARCHAR2(30) := 'POS_SUPPLIERS_DATASTORE';
  l_apps_schema_name    VARCHAR2(30) := NULL;
  l_pos_schema_name     VARCHAR2(30) := NULL;
  l_parallel            PLS_INTEGER;
  l_mem                 PLS_INTEGER;
  l_parameter           VARCHAR2(50);

BEGIN
    l_err_loc := 100;

    l_pos_schema_name := getPosSchemaName;
    SELECT oracle_username
    INTO l_apps_schema_name
    FROM fnd_oracle_userid
    WHERE read_only_flag = 'U';

    l_err_loc := 200;
    -- Obtain the index tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'POS',
    x_object_name          =>  'DR$POS_SUPPLIER_ENTITY_DATA$X',
    x_object_type          =>  'TABLE',
    x_index_lookup_flag    =>  'Y',     -- obtain the index tspace
    x_validate_ts_exists   =>  'Y',
    x_is_object_registered =>  l_is_object_registered,
    x_ts_exists            =>  l_ts_exists,
    x_tablespace           =>  l_ctx_index_tbsp);

    l_err_loc := 300;
    -- Obtain the data tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'POS',
    x_object_name          =>  'DR$POS_SUPPLIER_ENTITY_DATA$I',
    x_object_type          =>  'TABLE',
    x_index_lookup_flag    =>  'N',
    x_validate_ts_exists   =>  'Y',
    x_is_object_registered =>  l_is_object_registered,
    x_ts_exists            =>  l_ts_exists,
    x_tablespace           =>  l_ctx_data_tbsp);

    -- First we drop the existing preferences
    -- We need this in a separate block since if these don't exist
    -- they will throw exception and we are ok with this
    l_err_loc := 400;
    BEGIN
      ctx_ddl.drop_preference(l_ctx_pref_datastore);
      l_err_loc := 410;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    BEGIN
      ctx_ddl.drop_preference('POS_SUPPLIERS_FILTER');
      l_err_loc := 420;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    BEGIN
      ctx_ddl.drop_preference('POS_SUPPLIERS_LEXER_GLOBAL');
      l_err_loc := 430;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    BEGIN
      ctx_ddl.drop_preference('POS_SUPPLIERS_WORDLIST');
      l_err_loc := 440;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    BEGIN
      ctx_ddl.drop_preference('POS_SUPPLIERS_STORAGE');
      l_err_loc := 450;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    BEGIN
      ctx_ddl.drop_section_group(l_ctx_section_group);
      l_err_loc := 460;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;

    -- now we will go ahead and create the preferences
    l_err_loc := 500;

    -- create the detail datastore preferences
    ctx_ddl.create_preference(l_ctx_pref_datastore, 'DIRECT_DATASTORE');

    -- create the other preferences
    l_err_loc := 600;
    ctx_ddl.create_preference('POS_SUPPLIERS_FILTER', 'NULL_FILTER');

    l_err_loc := 610;
    ctx_ddl.create_preference('POS_SUPPLIERS_WORDLIST', 'BASIC_WORDLIST');
    l_err_loc := 620;
    ctx_ddl.set_attribute('POS_SUPPLIERS_WORDLIST', 'STEMMER', 'AUTO');
    l_err_loc := 630;
    ctx_ddl.set_attribute('POS_SUPPLIERS_WORDLIST', 'FUZZY_MATCH', 'AUTO');

    l_err_loc := 700;
    ctx_ddl.create_preference('POS_SUPPLIERS_STORAGE', 'BASIC_STORAGE');

    -- Check if the tablespace exists before using it
    l_err_loc := 710;
    IF (l_ts_exists = 'Y') THEN
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','I_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','K_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','R_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','N_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','P_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('POS_SUPPLIERS_STORAGE','I_INDEX_CLAUSE',
        'tablespace '||l_ctx_index_tbsp);
    END IF;

    l_err_loc := 720;
    ctx_ddl.create_section_group(l_ctx_section_group, 'path_section_group');

    l_err_loc := 940;
    ctx_ddl.create_preference('POS_SUPPLIERS_LEXER_GLOBAL', 'WORLD_LEXER');

    -- Now we drop the index if it exists
    l_err_loc := 1300;
    BEGIN
      execute immediate 'DROP INDEX '|| l_pos_schema_name || '.POS_SUPPLIER_SEARCH_INDEX';
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;

    l_err_loc := 1400;
    BEGIN
      -- Get the parameters to be used for create index to make it faster.
      -- The SQL to get degree of parallelism is:
      SELECT MIN(TO_NUMBER(value))
      INTO l_parallel
      FROM v$parameter
      WHERE name IN ('parallel_max_servers', 'cpu_count');

      l_err_loc := 1500;
      -- The SQL to get memory / worker is:
      SELECT ROUND(LEAST((LEAST(2147483648 , TO_NUMBER(sys_params.value)/3) / l_parallel), ctx_params.par_value) / 1048576)
      INTO  l_mem
      FROM v$parameter sys_params, ctx_parameters ctx_params
      WHERE sys_params.name IN ('pga_aggregate_target')
      AND ctx_params.par_name = 'MAX_INDEX_MEMORY';
    EXCEPTION
      WHEN OTHERS THEN
        l_parallel := NULL;
        l_mem := NULL;
    END;

    l_err_loc := 1600;
    IF ( l_parallel IS NOT NULL AND
         l_mem IS NOT NULL ) THEN
      l_parameter := ' MEMORY ' || l_mem || 'M' || ''') parallel ' || l_parallel;
    ELSE
      l_parameter := ''')';
    END IF;

    l_err_loc := 1700;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          'pon.plsql.POS_SUPPLIER_SEARCH_INDEX_PKG.CREATE_INDEX',
          'Intermedia Index parameters: l_parallel:' || l_parallel ||
          ', l_mem:' || l_mem ||
          ', l_parameter:' || l_parameter);
    END IF;

    l_err_loc := 1800;
    BEGIN
      EXECUTE IMMEDIATE
        'CREATE INDEX ' || l_pos_schema_name || '.POS_SUPPLIER_SEARCH_INDEX' ||
        ' ON ' || l_pos_schema_name || '.POS_SUPPLIER_ENTITY_DATA(ENTITY_DATA' ||
        ') INDEXTYPE IS CTXSYS.CONTEXT ' ||
        'PARAMETERS(''DATASTORE ' || l_apps_schema_name || '.POS_SUPPLIERS_DATASTORE' ||
        ' FILTER ' || l_apps_schema_name || '.POS_SUPPLIERS_FILTER' ||
        ' LEXER ' || l_apps_schema_name || '.POS_SUPPLIERS_LEXER_GLOBAL' ||
        ' WORDLIST ' || l_apps_schema_name || '.POS_SUPPLIERS_WORDLIST' ||
        ' STORAGE ' || l_apps_schema_name || '.POS_SUPPLIERS_STORAGE' ||
        ' STOPLIST CTXSYS.EMPTY_STOPLIST' ||
        ' SECTION GROUP ' || l_apps_schema_name || '.POS_SUPPLIERS_SECTGRP' ||
        l_parameter;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,
          'Exception at POS_SUPPLIER_SEARCH_INDEX_PKG.create_index('
          || l_err_loc || '): ' || SQLERRM );
    END;

    l_err_loc := 1900;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at POS_SUPPLIER_SEARCH_INDEX_PKG.create_index('
        || l_err_loc || '): ' || SQLERRM);

END create_index;

/**
 ** Proc : drop_index
 ** Desc : Drop the index for each installed language in FND_LANGUAGES,
 **        including the base language.
 **/

PROCEDURE drop_index
IS
  l_err_loc PLS_INTEGER;

  l_ctx_section_group VARCHAR2(30) := 'POS_SUPPLIERS_SECTGRP';
  l_ctx_pref_lexer  VARCHAR2(30) := NULL;
  l_ctx_pref_datastore  VARCHAR2(30) := 'POS_SUPPLIERS_DATASTORE';

  l_pos_schema_name VARCHAR2(30) := NULL;
BEGIN
  l_err_loc := 100;

  l_pos_schema_name := getPosSchemaName;

  -- drop the existing preferences
  BEGIN
    l_err_loc := 110;
    ctx_ddl.drop_preference(l_ctx_pref_datastore);
    l_err_loc := 120;
    ctx_ddl.drop_preference('POS_SUPPLIERS_FILTER');
    l_err_loc := 130;
    ctx_ddl.drop_preference('POS_SUPPLIERS_LEXER_GLOBAL');
    l_err_loc := 140;
    ctx_ddl.drop_preference('POS_SUPPLIERS_WORDLIST');
    l_err_loc := 150;
    ctx_ddl.drop_preference('POS_SUPPLIERS_STORAGE');
    l_err_loc := 160;
    ctx_ddl.drop_section_group(l_ctx_section_group);
    l_err_loc := 170;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  -- finally drop the index
  l_err_loc := 300;
  BEGIN
    execute immediate 'DROP INDEX ' || l_pos_schema_name || '.POS_SUPPLIER_SEARCH_INDEX';
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at POS_SUPPLIER_SEARCH_INDEX_PKG.drop_index('
        || l_err_loc || '): ' || SQLERRM);

END drop_index;

/**
 ** Proc : rebuild_index
 ** Desc : Rebuild the index for each installed language in FND_LANGUAGES,
 **        including the base language.
 **/

PROCEDURE rebuild_index IS
  l_err_loc PLS_INTEGER;
  l_pos_schema_name VARCHAR2(30) := NULL;
BEGIN
  l_err_loc := 100;

  l_pos_schema_name := getPosSchemaName;

  l_err_loc := 200;
  ad_ctx_ddl.sync_index(l_pos_schema_name || '.POS_SUPPLIER_SEARCH_INDEX');

  l_err_loc := 300;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at POS_SUPPLIER_SEARCH_INDEX_PKG.rebuild_index('
        || l_err_loc || '): ' || SQLERRM);

END rebuild_index;

FUNCTION getPosSchemaName
  RETURN VARCHAR2
IS
  l_status  VARCHAR2(20);
  l_industry  VARCHAR2(20);
  l_pos_schema_name VARCHAR2(20);
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_INSTALLATION.GET_APP_INFO('POS', l_status,
        l_industry, l_pos_schema_name))
  THEN
    RETURN l_pos_schema_name;
  ELSE
    RETURN 'POS';
  END IF;
END getPosSchemaName;


END pos_supplier_search_index_pkg;

/
