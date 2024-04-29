--------------------------------------------------------
--  DDL for Package Body ICX_POR_INTERMEDIA_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_INTERMEDIA_INDEX" AS
/* $Header: ICXCGITB.pls 120.0.12010000.2 2012/08/06 10:21:29 bpulivar ship $*/

--
-- Cursor to fetch intalled languages
--
    CURSOR installed_languages_csr IS
        select language_code,
               -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
               nls_language,
               installed_flag
        from   fnd_languages
        where  installed_flag in ('B', 'I');

/**
 ** Proc : create_index
 ** Desc : Create interMedia index  with multi-lex for each installed
 **        language in FND_LANGUAGES, including the base language.
 **/

PROCEDURE create_index IS

    xErrLoc         INTEGER := 0;

    -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
    xLang	    fnd_languages.language_code%TYPE;
    xNLSLang	    fnd_languages.nls_language%TYPE;

    -- Bug 1802907, zxzhang, May-24-01
    ctx_index_tbsp	VARCHAR2(100):='USER_IDX';
    ctx_data_tbsp	VARCHAR2(100):='USER_DATA';

    -- sosingha bug 3175547 to use AD API for getting the tablespace
    if_registered        VARCHAR2(10);
    check_tspace_exist   VARCHAR2(10);

    ctx_section_group  	VARCHAR2(30) := 'ICX_CAT_SECTGRP';
    ctx_desc_tag	    VARCHAR2(30) := NULL;
    ctx_pref_lexer	    VARCHAR2(30) := NULL;
    ctx_pref_datastore	VARCHAR2(30) := 'ICX_CAT_DATASTORE';
    xAppsSchemaName     VARCHAR2(30) := NULL;

    --Bug 4353520
   xIcxSchemaName varchar2(30):=ICX_POR_EXT_UTL.getIcxSchema;
BEGIN
    -- get the schema name from fnd_oracle_userid insted of hardcoding it.
    SELECT oracle_username
    INTO xAppsSchemaName
    FROM fnd_oracle_userid
    WHERE read_only_flag = 'U';

    -- Bug 1802907, zxzhang, May-24-01
    xErrLoc := 50;
    /* sosingha bug 3175547 to use AD API for getting the tablespace
    select index_tablespace
    into ctx_index_tbsp
    from fnd_product_installations
    where application_id = '178';

    -- bug 2050141
    xErrLoc := 60;
    select tablespace
    into ctx_data_tbsp
    from fnd_product_installations
    where application_id = '178';
    */

    -- Obtain the index tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'ICX',
    x_object_name          =>  'DR$ICX_CAT_ITEMS_CTX_DESC$X',
    x_object_type          =>  'TABLE',
    x_index_lookup_flag    =>  'Y',     -- obtain the index tspace
    x_validate_ts_exists   =>  'Y',
    x_is_object_registered =>  if_registered,
    x_ts_exists            =>  check_tspace_exist,
    x_tablespace           =>  ctx_index_tbsp);

    xErrLoc := 60;
    -- Obtain the data tablespace to use.
    AD_TSPACE_UTIL.get_object_tablespace(
    x_product_short_name   =>  'ICX',
    x_object_name          =>  'DR$ICX_CAT_ITEMS_CTX_DESC$I',
    x_object_type          =>  'TABLE',
    x_index_lookup_flag    =>  'N',
    x_validate_ts_exists   =>  'Y',
    x_is_object_registered =>  if_registered,
    x_ts_exists            =>  check_tspace_exist,
    x_tablespace           =>  ctx_data_tbsp);

    xErrLoc := 100;
    ctx_section_group := 'ICX_CAT_SECTGRP';

    -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
    -- drop the existing preferences
    BEGIN
      ctx_ddl.drop_preference(ctx_pref_datastore);
      xErrLoc := 110;
      ctx_ddl.drop_preference('ICX_CAT_FILTER');
      xErrLoc := 120;
      ctx_ddl.drop_preference('ICX_CAT_LEXER_GLOBAL');
      xErrLoc := 125;
      ctx_ddl.drop_preference('ICX_CAT_WORDLIST');
      xErrLoc := 140;
      ctx_ddl.drop_preference('ICX_CAT_STORAGE');
      xErrLoc := 150;
      ctx_ddl.drop_section_group(ctx_section_group);
      xErrLoc := 170;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;

    xErrLoc := 200;
    -- create preferences
    ctx_ddl.create_preference(ctx_pref_datastore, 'DETAIL_DATASTORE');
    xErrLoc := 210;
    -- Set the attributes specific to DETAIL_DATASTORE.
    ctx_ddl.set_attribute(ctx_pref_datastore, 'binary', 'false');
    xErrLoc := 211;
    ctx_ddl.set_attribute(ctx_pref_datastore, 'detail_table',
      xIcxSchemaName||'.ICX_CAT_ITEMS_CTX_TLP');
    xErrLoc := 212;
    ctx_ddl.set_attribute(ctx_pref_datastore,'detail_key',
      'rt_item_id, language');
    xErrLoc := 213;
    ctx_ddl.set_attribute(ctx_pref_datastore, 'detail_lineno', 'sequence');
    xErrLoc := 214;
    ctx_ddl.set_attribute(ctx_pref_datastore,'detail_text', 'CTX_DESC');

    xErrLoc := 220;
    ctx_ddl.create_preference('ICX_CAT_FILTER', 'NULL_FILTER');
    xErrLoc := 230;
    ctx_ddl.create_preference('ICX_CAT_WORDLIST', 'BASIC_WORDLIST');
    xErrLoc := 240;
    ctx_ddl.set_attribute('ICX_CAT_WORDLIST', 'STEMMER', 'AUTO');
    xErrLoc := 260;
    ctx_ddl.set_attribute('ICX_CAT_WORDLIST', 'FUZZY_MATCH', 'AUTO');

    -- Bug 1802907, zxzhang, May-24-01
    -- Enabled the storage clause to have the index created in
    -- the INDEX tablespace
    xErrLoc := 270;
    ctx_ddl.create_preference('ICX_CAT_STORAGE', 'BASIC_STORAGE');

    -- sosingha bug 3175547 to use AD API for getting the tablespace
    -- Check if the tablespace exists before using it
    IF (check_tspace_exist = 'Y') THEN
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','I_TABLE_CLAUSE',
        'tablespace '||ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','K_TABLE_CLAUSE',
        'tablespace '||ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','R_TABLE_CLAUSE',
        'tablespace '||ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','N_TABLE_CLAUSE',
        'tablespace '||ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','P_TABLE_CLAUSE',
        'tablespace '||ctx_data_tbsp);
      ctx_ddl.set_attribute('ICX_CAT_STORAGE','I_INDEX_CLAUSE',
        'tablespace '||ctx_index_tbsp);
    END IF;


    xErrLoc := 280;
    ctx_ddl.create_section_group(ctx_section_group, 'basic_section_group');
    xErrLoc := 290;
    ctx_ddl.add_field_section(ctx_section_group, 'SEARCH_TYPE',
                              'SEARCH_TYPE', FALSE);

    xErrLoc := 300;
    ctx_ddl.add_field_section(ctx_section_group, 'supid',
                              'supid', FALSE);
    ctx_ddl.add_field_section(ctx_section_group, 'catid',
                              'catid', FALSE);
    ctx_ddl.add_field_section(ctx_section_group, 'orgid',
                              'orgid', FALSE);
    ctx_ddl.add_field_section(ctx_section_group, 'language',
                              'language', FALSE);
    xErrLoc := 310;
    ctx_ddl.add_zone_section(ctx_section_group, 'catnm',
                              'catnm' );

    FOR counter in 1..100
      LOOP
          xErrLoc := 320;
          ctx_desc_tag := counter;
          ctx_ddl.add_zone_section(ctx_section_group,to_char(counter),
                                   ctx_desc_tag);
    END LOOP;

    FOR counter in 1000..1300
      LOOP
          xErrLoc := 330;
          ctx_desc_tag := counter;
          ctx_ddl.add_zone_section(ctx_section_group, to_char(counter),
                                   ctx_desc_tag);
    END LOOP;

    FOR counter in 5000..5150
      LOOP
            xErrLoc := 340;
            -- OEX_IP_PORTING
            ctx_desc_tag := counter;
            ctx_ddl.add_zone_section(ctx_section_group,to_char(counter),
                                     ctx_desc_tag);
    END LOOP;


    xErrLoc := 400;
    -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
    ctx_ddl.create_preference('ICX_CAT_LEXER_GLOBAL', 'MULTI_LEXER');

    xErrLoc := 420;
    FOR language_row IN installed_languages_csr LOOP
      xLang := language_row.language_code;
      xNLSLang := language_row.nls_language;

      xErrLoc := 440;
      ctx_pref_lexer := 'ICX_CAT_LEXER_' || xLang;

      -- drop the existing preference
      BEGIN
        xErrLoc := 450;
        ctx_ddl.drop_preference(ctx_pref_lexer);
        xErrLoc := 460;
      EXCEPTION
        WHEN OTHERS THEN
            null;
      END;

      xErrLoc := 480;
      -- create preferences
      if (xLang IN ('US', 'GB')) then
        -- American English (US), English (GB)
        xErrLoc := 3490;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        xErrLoc := 495;
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      elsif (xLang = 'JA') then
        -- Japanese (JA)
        xErrLoc := 500;
        ctx_ddl.create_preference(ctx_pref_lexer, 'JAPANESE_VGRAM_LEXER');
      elsif (xLang = 'KO') then
        -- Korean (KO)
        xErrLoc := 410;
        ctx_ddl.create_preference(ctx_pref_lexer, 'KOREAN_MORPH_LEXER');
        xErrLoc := 520;
        ctx_ddl.set_attribute(ctx_pref_lexer, 'VERB_ADJECTIVE', 'TRUE');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'ONE_CHAR_WORD', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'NUMBER', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'USER_DIC', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'STOP_DIC', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'COMPOSITE', 'COMPONENT_WORD');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'MORPHEME', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'TO_UPPER', 'TRUE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'HANJA', 'FALSE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'LONG_WORD', 'FALSE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'JAPANESE', 'FALSE');
	ctx_ddl.set_attribute(ctx_pref_lexer, 'ENGLISH', 'TRUE');
      elsif (xLang IN ('ZHS', 'ZHT')) then
        -- Simplified Chinese (ZHS), Traditional Chinese (ZHT)
        xErrLoc := 530;
        ctx_ddl.create_preference(ctx_pref_lexer, 'CHINESE_VGRAM_LEXER');
      elsif (xLang IN ('F', 'FRC')) then
        -- French (F), Canadian French (FRC)
        xErrLoc := 540;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      elsif (xLang = 'D') then
        -- German (D)
        xErrLoc := 550;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'ALTERNATE_SPELLING', 'GERMAN');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      elsif (xLang = 'I') then
        -- Italian (I)
        xErrLoc := 560;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      elsif (xLang  in ('E','ESA')) then
        -- Spanish (E)
        xErrLoc := 570;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      elsif (xLang = 'NL') then
        -- Dutch (NL)
        xErrLoc := 580;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
        -- 13822612 Starts
      elsif (xLang = 'SQ') then
        -- Albanian (SQ)
        xErrLoc := 590;
        ctx_ddl.create_preference(ctx_pref_lexer, 'WORLD_LEXER');
        -- 13822612 Ends
      else
        -- All other languages
        xErrLoc := 4590;
        ctx_ddl.create_preference(ctx_pref_lexer, 'BASIC_LEXER');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'INDEX_THEMES', 'NO');
        ctx_ddl.set_attribute(ctx_pref_lexer, 'PRINTJOINS', '-_');
        -- bug1898152, jingyu. Treat accented characters as regular ones.
        ctx_ddl.set_attribute(ctx_pref_lexer, 'BASE_LETTER', 'YES');
      end if;

      -- 13822612 Starts
     if (xLang <> 'SQ') then
      -- Albanian (SQ)
      -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
      ctx_ddl.add_sub_lexer('ICX_CAT_LEXER_GLOBAL', xNLSLang,
                            ctx_pref_lexer);
      if (language_row.installed_flag = 'B') then
        ctx_ddl.add_sub_lexer('ICX_CAT_LEXER_GLOBAL', 'default',
                              ctx_pref_lexer);
      end if;
     end if;
     -- 13822612 Ends

    END LOOP;

    -- Bug 2249721, Multi-Lexer, ZXZHANG, Mar-04-02
    xErrLoc := 600;
    BEGIN
      execute immediate 'DROP INDEX '||xIcxSchemaName||'.ICX_CAT_ITEMS_CTX_DESC';
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;

    xErrLoc := 700;
    BEGIN
      -- Bug#3260189
      execute immediate
        'CREATE INDEX '||xIcxSchemaName||'.ICX_CAT_ITEMS_CTX_DESC' ||
        ' ON ICX_CAT_ITEMS_TLP(CTX_DESC' ||
        ') INDEXTYPE IS CTXSYS.CONTEXT ' ||
        'PARAMETERS(''DATASTORE ' || xAppsSchemaName || '.ICX_CAT_DATASTORE' ||
        ' FILTER ' || xAppsSchemaName || '.ICX_CAT_FILTER' ||
        ' LEXER ' || xAppsSchemaName || '.ICX_CAT_LEXER_GLOBAL' ||
        ' LANGUAGE COLUMN LANGUAGE' ||
        ' WORDLIST ' || xAppsSchemaName || '.ICX_CAT_WORDLIST' ||
        ' STORAGE ' || xAppsSchemaName || '.ICX_CAT_STORAGE' ||
        ' STOPLIST CTXSYS.EMPTY_STOPLIST' ||
        ' SECTION GROUP ' || xAppsSchemaName || '.ICX_CAT_SECTGRP' || ''')';

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,
          'Exception at ICX_POR_INTERMEDIA_INDEX.create_index('
          || xErrLoc || '): ' || SQLERRM );
    END;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_INTERMEDIA_INDEX.create_index('
        || xErrLoc || '): ' || SQLERRM);

END create_index;

/**
 ** Proc : drop_index
 ** Desc : Drop the index for each installed language in FND_LANGUAGES,
 **        including the base language.
 **/

PROCEDURE drop_index IS
  xErrLoc         INTEGER := 0;

  ctx_section_group 	VARCHAR2(30) := 'ICX_CAT_SECTGRP';
  ctx_pref_lexer	VARCHAR2(30) := NULL;
  ctx_pref_datastore	VARCHAR2(30) := 'ICX_CAT_DATASTORE';

    --Bug 4353520
   xIcxSchemaName varchar2(30):=ICX_POR_EXT_UTL.getIcxSchema;
BEGIN
  xErrLoc := 100;

  -- drop the existing preferences
  BEGIN
    ctx_ddl.drop_preference(ctx_pref_datastore);
    xErrLoc := 110;
    ctx_ddl.drop_preference('ICX_CAT_FILTER');
    xErrLoc := 120;
    ctx_ddl.drop_preference('ICX_CAT_LEXER_GLOBAL');
    xErrLoc := 125;
    ctx_ddl.drop_preference('ICX_CAT_WORDLIST');
    xErrLoc := 140;
    ctx_ddl.drop_preference('ICX_CAT_STORAGE');
    xErrLoc := 150;
    ctx_ddl.drop_section_group(ctx_section_group);
    xErrLoc := 170;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  FOR language_row IN installed_languages_csr LOOP
    xErrLoc := 200;
    -- language-specific preference settings
    ctx_pref_lexer := 'ICX_CAT_LEXER_' || language_row.language_code;

    BEGIN
      xErrLoc := 210;
      ctx_ddl.drop_preference(ctx_pref_lexer);
    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;

  xErrLoc := 400;
  BEGIN
    execute immediate 'DROP INDEX '||xIcxSchemaName||'.ICX_CAT_ITEMS_CTX_DESC';
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_INTERMEDIA_INDEX.drop_index('
        || xErrLoc || '): ' || SQLERRM);

END drop_index;

/**
 ** Proc : rebuild_index
 ** Desc : Rebuild the index for each installed language in FND_LANGUAGES,
 **        including the base language.
 **/

PROCEDURE rebuild_index IS

    xErrLoc         INTEGER := 0;

    --Bug 4353520
   xIcxSchemaName varchar2(30):=ICX_POR_EXT_UTL.getIcxSchema;
BEGIN
  xErrLoc := 100;
  -- bug 1663129: to avoid deadlock
  -- bug 1854624: calling ctxsys.ICX_CAT_index_rebuild....
  ad_ctx_ddl.sync_index(xIcxSchemaName||'.ICX_CAT_ITEMS_CTX_DESC');
  xErrLoc := 200;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_INTERMEDIA_INDEX.rebuild_index('
        || xErrLoc || '): ' || SQLERRM);

END rebuild_index;


END ICX_POR_INTERMEDIA_INDEX;

/
