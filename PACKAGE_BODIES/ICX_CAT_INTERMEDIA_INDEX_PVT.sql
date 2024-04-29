--------------------------------------------------------
--  DDL for Package Body ICX_CAT_INTERMEDIA_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_INTERMEDIA_INDEX_PVT" AS
/* $Header: ICXVCIIB.pls 120.6.12010000.4 2013/01/17 20:32:09 chihchan ship $*/

-- Constants
G_PKG_NAME              CONSTANT VARCHAR2(30) :='ICX_CAT_INTERMEDIA_INDEX_PVT';

-- Cursor to fetch intalled languages
CURSOR installed_languages_csr IS
  SELECT language_code,
         nls_language,
         installed_flag
  FROM   fnd_languages
  WHERE  installed_flag IN ('B', 'I');

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

  l_ctx_section_group  	VARCHAR2(30) := 'ICX_CAT_SECTGRP_HDRS';
  l_ctx_desc_tag	VARCHAR2(30) := NULL;
  l_ctx_pref_lexer	VARCHAR2(30) := NULL;
  l_ctx_pref_datastore	VARCHAR2(30) := 'ICX_CAT_DATASTORE_HDRS';
  l_apps_schema_name    VARCHAR2(30) := NULL;
  l_icx_schema_name     VARCHAR2(30) := NULL;
  l_parallel            PLS_INTEGER;
  l_mem                 PLS_INTEGER;
  l_parameter           VARCHAR2(50);

BEGIN
    l_err_loc := 100;

    l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;
    l_apps_schema_name := ICX_CAT_UTIL_PVT.getAppsSchemaName;

    l_err_loc := 200;
    -- Obtain the index tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'ICX',
    x_object_name          =>  'DR$ICX_CAT_ITEMSCTXDESC_HDRS$X',
    x_object_type          =>  'TABLE',
    x_index_lookup_flag    =>  'Y',     -- obtain the index tspace
    x_validate_ts_exists   =>  'Y',
    x_is_object_registered =>  l_is_object_registered,
    x_ts_exists            =>  l_ts_exists,
    x_tablespace           =>  l_ctx_index_tbsp);

    l_err_loc := 300;
    -- Obtain the data tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'ICX',
    x_object_name          =>  'DR$ICX_CAT_ITEMSCTXDESC_HDRS$I',
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
      ctx_ddl.drop_preference('ICX_CAT_FILTER_HDRS');
      l_err_loc := 420;
      ctx_ddl.drop_preference('ICX_CAT_LEXER_GLOBAL_HDRS');
      l_err_loc := 430;
      ctx_ddl.drop_preference('ICX_CAT_WORDLIST_HDRS');
      l_err_loc := 440;
      ctx_ddl.drop_preference('ICX_CAT_STORAGE_HDRS');
      l_err_loc := 450;
      ctx_ddl.drop_section_group(l_ctx_section_group);
      l_err_loc := 460;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;

    -- now we will go ahead and create the preferences
    l_err_loc := 500;

    -- create the detail datastore preferences
    ctx_ddl.create_preference(l_ctx_pref_datastore, 'DETAIL_DATASTORE');

    -- Set the attributes specific to DETAIL_DATASTORE.
    l_err_loc := 510;
    ctx_ddl.set_attribute(l_ctx_pref_datastore, 'binary', 'false');
    l_err_loc := 520;
    ctx_ddl.set_attribute(l_ctx_pref_datastore, 'detail_table',
      l_icx_schema_name || '.ICX_CAT_ITEMS_CTX_DTLS_TLP');
    l_err_loc := 530;
    ctx_ddl.set_attribute(l_ctx_pref_datastore,'detail_key',
      'po_line_id, inventory_item_id, req_template_name, req_template_line_num, org_id, language');
    l_err_loc := 540;
    ctx_ddl.set_attribute(l_ctx_pref_datastore, 'detail_lineno', 'sequence');
    l_err_loc := 550;
    ctx_ddl.set_attribute(l_ctx_pref_datastore,'detail_text', 'CTX_DESC');

    -- create the other preferences
    l_err_loc := 600;
    ctx_ddl.create_preference('ICX_CAT_FILTER_HDRS', 'NULL_FILTER');

    l_err_loc := 610;
    ctx_ddl.create_preference('ICX_CAT_WORDLIST_HDRS', 'BASIC_WORDLIST');
    l_err_loc := 620;
    ctx_ddl.set_attribute('ICX_CAT_WORDLIST_HDRS', 'STEMMER', 'AUTO');
    l_err_loc := 630;
    ctx_ddl.set_attribute('ICX_CAT_WORDLIST_HDRS', 'FUZZY_MATCH', 'AUTO');

    l_err_loc := 700;
    ctx_ddl.create_preference('ICX_CAT_STORAGE_HDRS', 'BASIC_STORAGE');

    -- Check if the tablespace exists before using it
    l_err_loc := 710;
    IF (l_ts_exists = 'Y') THEN
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','I_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','K_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','R_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','N_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','P_TABLE_CLAUSE',
        'tablespace '||l_ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE_HDRS','I_INDEX_CLAUSE',
        'tablespace '||l_ctx_index_tbsp);
    END IF;

    l_err_loc := 720;
    ctx_ddl.create_section_group(l_ctx_section_group, 'basic_section_group');

    -- add all the field sections
    l_err_loc := 730;
    ctx_ddl.add_field_section(l_ctx_section_group, 'source_type', 'source_type', FALSE);
    l_err_loc := 740;
    ctx_ddl.add_field_section(l_ctx_section_group, 'supid', 'supid', FALSE);
    l_err_loc := 750;
    ctx_ddl.add_field_section(l_ctx_section_group, 'ipcatid', 'ipcatid', FALSE);
    l_err_loc := 760;
    ctx_ddl.add_field_section(l_ctx_section_group, 'pocatid', 'pocatid', FALSE);
    l_err_loc := 770;
    ctx_ddl.add_field_section(l_ctx_section_group, 'siteid', 'siteid', FALSE);
    l_err_loc := 780;
    ctx_ddl.add_field_section(l_ctx_section_group, 'orgid', 'orgid', FALSE);
    l_err_loc := 790;
    ctx_ddl.add_field_section(l_ctx_section_group, 'purchorgid', 'purchorgid', FALSE);
    l_err_loc := 800;
    ctx_ddl.add_field_section(l_ctx_section_group, 'language', 'language', FALSE);
    l_err_loc := 810;
    ctx_ddl.add_field_section(l_ctx_section_group, 'item_type', 'item_type', FALSE);

    l_err_loc := 900;
    FOR counter in 1..100
    LOOP
      l_err_loc := 910;
      l_ctx_desc_tag := counter;
      ctx_ddl.add_zone_section(l_ctx_section_group, to_char(counter), l_ctx_desc_tag);
    END LOOP;

    FOR counter in 1000..1300
    LOOP
      l_err_loc := 920;
      l_ctx_desc_tag := counter;
      ctx_ddl.add_zone_section(l_ctx_section_group, to_char(counter), l_ctx_desc_tag);
    END LOOP;

    FOR counter in 5000..5150
    LOOP
      l_err_loc := 930;
      l_ctx_desc_tag := counter;
      ctx_ddl.add_zone_section(l_ctx_section_group, to_char(counter), l_ctx_desc_tag);
    END LOOP;

    l_err_loc := 940;
    ctx_ddl.create_preference('ICX_CAT_LEXER_GLOBAL_HDRS', 'MULTI_LEXER');

    -- we now loop through the installed languages and create
    -- lexers for each of them
    l_err_loc := 1000;
    FOR language_row IN installed_languages_csr LOOP
      l_lang := language_row.language_code;
      l_nls_lang := language_row.nls_language;

      l_err_loc := 1010;
      l_ctx_pref_lexer := 'ICX_CAT_LEXER_HDRS_' || l_lang;

      -- drop the existing lexer preference for this langauge
      -- don't do anything on exception since preference may not exist
      BEGIN
        l_err_loc := 1020;
        ctx_ddl.drop_preference(l_ctx_pref_lexer);
        l_err_loc := 1030;
      EXCEPTION
        WHEN OTHERS THEN
            null;
      END;

      l_err_loc := 1100;
      -- Now create the lexer preferences and set appropriate attributes
      IF (l_lang IN ('US', 'GB')) THEN
        -- American English (US), English (GB)
        l_err_loc := 1110;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      ELSIF (l_lang = 'JA') THEN
        -- Japanese (JA)
        l_err_loc := 1120;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'JAPANESE_VGRAM_LEXER');
      ELSIF (l_lang = 'KO') THEN
        -- Korean (KO)
        l_err_loc := 1130;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'KOREAN_MORPH_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'VERB_ADJECTIVE', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'ONE_CHAR_WORD', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'NUMBER', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'USER_DIC', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'STOP_DIC', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'COMPOSITE', 'COMPONENT_WORD');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'MORPHEME', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'TO_UPPER', 'TRUE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'HANJA', 'FALSE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'LONG_WORD', 'FALSE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'JAPANESE', 'FALSE');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'ENGLISH', 'TRUE');
      ELSIF (l_lang IN ('ZHS', 'ZHT')) THEN
        -- Simplified Chinese (ZHS), Traditional Chinese (ZHT)
        l_err_loc := 1140;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'CHINESE_VGRAM_LEXER');
      ELSIF (l_lang IN ('F', 'FRC')) THEN
        -- French (F), Canadian French (FRC)
        l_err_loc := 1150;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      ELSIF (l_lang = 'D') THEN
        -- German (D)
        l_err_loc := 1160;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'ALTERNATE_SPELLING', 'GERMAN');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      ELSIF (l_lang = 'I') THEN
        -- Italian (I)
        l_err_loc := 1170;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      ELSIF (l_lang  in ('E','ESA')) THEN
        -- Spanish (E), Latin American Spanish (ESA)
        l_err_loc := 1180;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      ELSIF (l_lang = 'NL') THEN
        -- Dutch (NL)
        l_err_loc := 1190;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');

        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
	  -- 16177309 Starts
      ELSIF (l_lang = 'SQ' OR l_lang = 'AZ') then
         -- AZERBAIJANI(AZ), Albanian (SQ)
         l_err_loc := 11901;
         ctx_ddl.create_preference(l_ctx_pref_lexer, 'WORLD_LEXER');
         -- 16177309 Ends
      ELSE
        -- All other languages
        l_err_loc := 1200;
        ctx_ddl.create_preference(l_ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'PRINTJOINS', '-_');
        ctx_ddl.set_attribute(l_ctx_pref_lexer, 'BASE_LETTER', 'YES');
      END IF;
       -- 16177309 Starts
      if (l_lang <> 'SQ' AND l_lang <> 'AZ') then
		   -- AZERBAIJANI(AZ), Albanian (SQ)
		  l_err_loc := 1210;
		  -- add a sub lexer for this language
		  ctx_ddl.add_sub_lexer('ICX_CAT_LEXER_GLOBAL_HDRS', l_nls_lang,
								l_ctx_pref_lexer);

		  l_err_loc := 1220;
		  -- make the base language sub lexer the default
		  IF (language_row.installed_flag = 'B') THEN
			ctx_ddl.add_sub_lexer('ICX_CAT_LEXER_GLOBAL_HDRS', 'default',
								  l_ctx_pref_lexer);
		  END IF;
	  END IF;
    END LOOP;

    -- Now we drop the index if it exists
    l_err_loc := 1300;
    BEGIN
      execute immediate 'DROP INDEX '|| l_icx_schema_name || '.ICX_CAT_ITEMSCTXDESC_HDRS';
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
        ICX_CAT_UTIL_PVT.logUnexpectedException(
          G_PKG_NAME, l_api_name,
          ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
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
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Intermedia Index parameters: l_parallel:' || l_parallel ||
          ', l_mem:' || l_mem ||
          ', l_parameter:' || l_parameter);
    END IF;

    l_err_loc := 1800;
    BEGIN
      EXECUTE IMMEDIATE
        'CREATE INDEX ' || l_icx_schema_name || '.ICX_CAT_ITEMSCTXDESC_HDRS' ||
        ' ON ' || l_icx_schema_name || '.ICX_CAT_ITEMS_CTX_HDRS_TLP(CTX_DESC' ||
        ') INDEXTYPE IS CTXSYS.CONTEXT ' ||
        'PARAMETERS(''DATASTORE ' || l_apps_schema_name || '.ICX_CAT_DATASTORE_HDRS' ||
        ' FILTER ' || l_apps_schema_name || '.ICX_CAT_FILTER_HDRS' ||
        ' LEXER ' || l_apps_schema_name || '.ICX_CAT_LEXER_GLOBAL_HDRS' ||
        ' LANGUAGE COLUMN LANGUAGE' ||
        ' WORDLIST ' || l_apps_schema_name || '.ICX_CAT_WORDLIST_HDRS' ||
        ' STORAGE ' || l_apps_schema_name || '.ICX_CAT_STORAGE_HDRS' ||
        ' STOPLIST CTXSYS.EMPTY_STOPLIST' ||
        ' SECTION GROUP ' || l_apps_schema_name || '.ICX_CAT_SECTGRP_HDRS' ||
        l_parameter;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,
          'Exception at ICX_CAT_INTERMEDIA_INDEX_PVT.create_index('
          || l_err_loc || '): ' || SQLERRM );
    END;

    l_err_loc := 1900;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_CAT_INTERMEDIA_INDEX_PVT.create_index('
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

  l_ctx_section_group VARCHAR2(30) := 'ICX_CAT_SECTGRP_HDRS';
  l_ctx_pref_lexer  VARCHAR2(30) := NULL;
  l_ctx_pref_datastore  VARCHAR2(30) := 'ICX_CAT_DATASTORE_HDRS';

  l_icx_schema_name VARCHAR2(30) := NULL;
BEGIN
  l_err_loc := 100;

  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

  -- drop the existing preferences
  BEGIN
    l_err_loc := 110;
    ctx_ddl.drop_preference(l_ctx_pref_datastore);
    l_err_loc := 120;
    ctx_ddl.drop_preference('ICX_CAT_FILTER_HDRS');
    l_err_loc := 130;
    ctx_ddl.drop_preference('ICX_CAT_LEXER_GLOBAL_HDRS');
    l_err_loc := 140;
    ctx_ddl.drop_preference('ICX_CAT_WORDLIST_HDRS');
    l_err_loc := 150;
    ctx_ddl.drop_preference('ICX_CAT_STORAGE_HDRS');
    l_err_loc := 160;
    ctx_ddl.drop_section_group(l_ctx_section_group);
    l_err_loc := 170;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  FOR language_row IN installed_languages_csr LOOP
    l_err_loc := 200;
    -- language-specific preference settings
    l_ctx_pref_lexer := 'ICX_CAT_LEXER_HDRS_' || language_row.language_code;

    BEGIN
      l_err_loc := 210;
      ctx_ddl.drop_preference(l_ctx_pref_lexer);
    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;

  -- finally drop the index
  l_err_loc := 300;
  BEGIN
    execute immediate 'DROP INDEX ' || l_icx_schema_name || '.ICX_CAT_ITEMSCTXDESC_HDRS';
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_CAT_INTERMEDIA_INDEX_PVT.drop_index('
        || l_err_loc || '): ' || SQLERRM);

END drop_index;

/**
 ** Proc : rebuild_index
 ** Desc : Rebuild the index for each installed language in FND_LANGUAGES,
 **        including the base language.
 **/

PROCEDURE rebuild_index IS
  l_err_loc PLS_INTEGER;
  l_icx_schema_name VARCHAR2(30) := NULL;
BEGIN
  l_err_loc := 100;

  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

  l_err_loc := 200;
  ad_ctx_ddl.sync_index(l_icx_schema_name || '.ICX_CAT_ITEMSCTXDESC_HDRS');

  l_err_loc := 300;

 IF fnd_profile.Value('FND_ENDECA_PORTAL_URL') IS NOT NULL THEN

  ICX_ENDECA_UTIL_PKG.incrementalInsert ;

 END IF ;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index('
        || l_err_loc || '): ' || SQLERRM);

END rebuild_index;


END ICX_CAT_INTERMEDIA_INDEX_PVT;

/
