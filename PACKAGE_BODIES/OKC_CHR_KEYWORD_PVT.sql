--------------------------------------------------------
--  DDL for Package Body OKC_CHR_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CHR_KEYWORD_PVT" AS
/* $Header: OKCRCKWB.pls 120.1.12010000.2 2008/10/24 08:01:55 ssreekum ship $ */

  retcode_success   CONSTANT VARCHAR2(1) := '0';
  retcode_warning   CONSTANT VARCHAR2(1) := '1';
  retcode_error     CONSTANT VARCHAR2(1) := '2';

  starting constant number := 0;
  finish   constant number := 1;

  rindex   BINARY_INTEGER;
  slno     BINARY_INTEGER;

  PROCEDURE sync IS
  BEGIN
    ad_ctx_ddl.set_effective_schema('okc');
    ad_ctx_ddl.sync_index('okc_k_headers_tl_ctx');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE optimize IS
  BEGIN
     ad_ctx_ddl.set_effective_schema('okc');
     ad_ctx_ddl.optimize_index
        ( idx_name => 'okc_k_headers_tl_ctx',
        optlevel => ad_ctx_ddl.optlevel_full,
        maxtime  => ad_ctx_ddl.maxtime_unlimited);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE sync_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'concurrent_sync_ctx';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  BEGIN
    sync;
    retcode := retcode_success;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := retcode_error;
      errbuf := SUBSTR(sqlerrm,1,200);
  END;

  PROCEDURE optimize_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'concurrent_optimize_ctx';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  BEGIN
    sync_ctx(errbuf, retcode);
    IF retcode <> retcode_success THEN
      RETURN;
    END IF;
    optimize;
    retcode := retcode_success;
  EXCEPTION
    WHEN OTHERS THEN
     retcode := retcode_error;
     errbuf := SUBSTR(sqlerrm,1,200);
  END;

  FUNCTION get_request_id(prog_name varchar2)
  RETURN fnd_concurrent_requests.request_id%TYPE
  IS
    result fnd_concurrent_requests.request_id%TYPE;
  BEGIN
    SELECT request_id INTO result
    FROM fnd_concurrent_requests
    WHERE concurrent_program_id IN (SELECT concurrent_program_id
                                    FROM fnd_concurrent_programs
                                    WHERE concurrent_program_name = prog_name)
    AND phase_code = 'R';
    RETURN result;
  EXCEPTION WHEN OTHERS THEN
    return 0;
  END;

  PROCEDURE create_ctx(x_return_status OUT NOCOPY VARCHAR2) IS
    apps  sys.dba_objects.owner%TYPE;
    okc   sys.dba_objects.owner%TYPE;
    cmd   VARCHAR2(4000);

    anyexp  EXCEPTION;

    request_id fnd_concurrent_requests.request_id%TYPE;
  BEGIN

    x_return_status := 'S';

    request_id := get_request_id('OKCCHRCRCTX');
    fnd_file.put_line(fnd_file.log,'OKC_K_HEADERS_TL_CTX text index creation started');

    BEGIN
      fnd_file.put_line(fnd_file.log,'Checking OKC_CHR_KEYWORD_PVT package exists or not...');
      SELECT owner INTO apps
      FROM sys.dba_objects
      WHERE object_name = 'OKC_CHR_KEYWORD_PVT'
      AND object_type = 'PACKAGE';
      fnd_file.put_line(fnd_file.log,'OKC_CHR_KEYWORD_PVT package exists');
      fnd_file.put_line(fnd_file.log,'OKC_CHR_KEYWORD_PVT package owner is '||apps);

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 1, 13);
    EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: OKC_CHR__KEYWORD_PVT package doesn''t exist');
      RAISE anyexp;
    END;

    BEGIN
      fnd_file.put_line(fnd_file.log,'Checking OKC_K_HEADERS_TL table ...');
      SELECT owner INTO okc
      FROM sys.dba_tables
      WHERE table_name = 'OKC_K_HEADERS_TL';
      fnd_file.put_line(fnd_file.log,'OKC_K_HEADERS_TL table exists');
      fnd_file.put_line(fnd_file.log,'OKC_K_HEADERS_TL table owner is '||okc);

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 2, 13);

    EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: OKC_K_HEADERS_TL table doesn''t exist');
      RAISE anyexp;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON '||apps||'.OKC_CHR_KEYWORD_PVT TO '||okc;
      fnd_file.put_line(fnd_file.log,'Granted execute on '||apps||'.OKC_CHR_KEYWORD_PVT to '||okc);

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 3, 13);

    EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: Couldn''t grant execute on '||apps||'.OKC_CHR_KEYWORD_PVT to '||okc);
      RAISE anyexp;
    END;


    -- Create context index preferences
    -- Context index searches through columns
    --    cognomen
    --    short_description
    --    description
    -- Create datastore okc_k_headers_tl_datastore

    BEGIN
      BEGIN
        fnd_file.put_line(fnd_file.log,'Before drop preference');
        ad_ctx_ddl.drop_preference('okc_k_headers_tl_datastore');
        fnd_file.put_line(fnd_file.log,'Preference dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      fnd_file.put_line(fnd_file.log,'Before create preference');
      ad_ctx_ddl.create_preference('okc_k_headers_tl_datastore','multi_column_datastore');
      ad_ctx_ddl.set_attribute('okc_k_headers_tl_datastore','columns',
                               'cognomen, short_description, description');
      fnd_file.put_line(fnd_file.log,'Preference created successfully');
      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 4, 13);
    END;

    -- Creating all Lexers and sublexers
    BEGIN
      BEGIN
        fnd_file.put_line(fnd_file.log,'Dropping multi lexer');
        ad_ctx_ddl.drop_preference('okc_k_headers_tl_lexer');
        fnd_file.put_line(fnd_file.log,'Multi lexer successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      fnd_file.put_line(fnd_file.log,'Creating multi lexer');
      ad_ctx_ddl.create_preference('okc_k_headers_tl_lexer','multi_lexer');
      BEGIN
        fnd_file.put_line(fnd_file.log,'Dropping basic lexer');
        ad_ctx_ddl.drop_preference('okc_chrtl_blexer');
        fnd_file.put_line(fnd_file.log,'Basic lexer dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      fnd_file.put_line(fnd_file.log,'Creating basic lexer with its attributes');
      ad_ctx_ddl.create_preference('okc_chrtl_blexer','basic_lexer');
      ad_ctx_ddl.set_attribute('okc_chrtl_blexer','index_themes','false');
      ad_ctx_ddl.set_attribute('okc_chrtl_blexer','index_text','true');
      ad_ctx_ddl.set_attribute('okc_chrtl_blexer','base_letter','true');
      ad_ctx_ddl.set_attribute('okc_chrtl_blexer','mixed_case','false');
      fnd_file.put_line(fnd_file.log,'Basic lexer with its attributes created successfully');

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 5, 13);

      BEGIN
        fnd_file.put_line(fnd_file.log,'Dropping Chinese lexer');
        ad_ctx_ddl.drop_preference('okc_chrtl_clexer');
        fnd_file.put_line(fnd_file.log,'Chinese lexer dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      DECLARE
        yes_no VARCHAR2(1);
      BEGIN
        BEGIN
          SELECT 'Y' INTO yes_no
          FROM ctxsys.ctx_objects
          WHERE obj_class = 'LEXER'
          AND obj_name = 'CHINESE_LEXER';
        EXCEPTION
          WHEN OTHERS THEN yes_no := 'N';
        END;
        fnd_file.put_line(fnd_file.log,'Chinese lexer: yes_no: ' || yes_no);
        IF yes_no = 'Y' THEN
          ad_ctx_ddl.create_preference('okc_chrtl_clexer','chinese_lexer');
        ELSE
          ad_ctx_ddl.create_preference('okc_chrtl_clexer','chinese_vgram_lexer');
        END IF;
        fnd_file.put_line(fnd_file.log,'Chinese lexer created successfully');
        dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 6, 13);

      END;

      BEGIN
        fnd_file.put_line(fnd_file.log,'Dropping Japanese lexer');
        ad_ctx_ddl.drop_preference('okc_chrtl_jlexer');
        fnd_file.put_line(fnd_file.log,'Japanese lexer dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      DECLARE
        yes_no VARCHAR2(1);
      BEGIN
        BEGIN
          SELECT 'Y' INTO yes_no
          FROM ctxsys.ctx_objects
          WHERE obj_class = 'LEXER'
          AND obj_name = 'JAPANESE_LEXER';
        EXCEPTION
          WHEN OTHERS THEN
            yes_no := 'N';
        END;
        fnd_file.put_line(fnd_file.log,'Japanese lexer: yes_no: ' || yes_no);
        IF yes_no = 'Y' THEN
          ad_ctx_ddl.create_preference('okc_chrtl_jlexer','japanese_lexer');
        ELSE
          ad_ctx_ddl.create_preference('okc_chrtl_jlexer','japanese_vgram_lexer');
        END IF;
        fnd_file.put_line(fnd_file.log,'Japanese lexer created successfully');
        dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 7, 13);
      END;

      BEGIN
        fnd_file.put_line(fnd_file.log,'Dropping korean lexer');
        ad_ctx_ddl.drop_preference('okc_chrtl_klexer');
        fnd_file.put_line(fnd_file.log,'Korean lexer dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      DECLARE
        yes_no varchar2(1);
      BEGIN
        BEGIN
          SELECT 'Y' INTO yes_no
          FROM ctxsys.ctx_objects
          WHERE obj_class = 'LEXER'
          AND obj_name = 'KOREAN_MORPH_LEXER';
        EXCEPTION
          WHEN OTHERS THEN
            yes_no := 'N';
        END;
        fnd_file.put_line(fnd_file.log,'Korean lexer: yes_no: ' || yes_no);
        IF yes_no = 'Y' THEN
          ad_ctx_ddl.create_preference('okc_chrtl_klexer', 'korean_morph_lexer');
          ad_ctx_ddl.set_attribute('okc_chrtl_klexer', 'one_char_word', 'true');
          ad_ctx_ddl.set_attribute('okc_chrtl_klexer', 'number', 'true');
        ELSE
          ad_ctx_ddl.create_preference('okc_chrtl_klexer', 'korean_lexer');
        END IF;

        fnd_file.put_line(fnd_file.log,'Korean lexer created successfully');
        dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 8, 13);

      END;

      fnd_file.put_line(fnd_file.log,'Before Add Sub Lexer');
      ad_ctx_ddl.add_sub_lexer('okc_k_headers_tl_lexer','default','okc_chrtl_blexer');
      ad_ctx_ddl.add_sub_lexer('okc_k_headers_tl_lexer','ja','okc_chrtl_jlexer');
      ad_ctx_ddl.add_sub_lexer('okc_k_headers_tl_lexer','ko','okc_chrtl_klexer');
      ad_ctx_ddl.add_sub_lexer('okc_k_headers_tl_lexer','zhs','okc_chrtl_clexer');
      ad_ctx_ddl.add_sub_lexer('okc_k_headers_tl_lexer','zht','okc_chrtl_clexer');

      fnd_file.put_line(fnd_file.log,'Sub Lexer Added Successfully');
      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 9, 13);

    END;

    --Create wordlist okc_k_headers_tl_wordlist
    BEGIN
      BEGIN
         fnd_file.put_line(fnd_file.log,'Dropping WordList');
         ad_ctx_ddl.drop_preference('okc_k_headers_tl_wordlist');
         fnd_file.put_line(fnd_file.log,'WordList dropped successfully');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      fnd_file.put_line(fnd_file.log,'Creating WordList...');
      ad_ctx_ddl.create_preference('okc_k_headers_tl_wordlist','basic_wordlist');
      ad_ctx_ddl.set_attribute('okc_k_headers_tl_wordlist','stemmer','auto');
      ad_ctx_ddl.set_attribute('okc_k_headers_tl_wordlist','fuzzy_match','auto');
      fnd_file.put_line(fnd_file.log,'WordList created succesfully');
    END;

    dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 10, 13);

    -- Drop context index okc_k_headers_tl_ctx (if exists)
    BEGIN
      fnd_file.put_line(fnd_file.log,'Dropping INDEX okc_k_headers_tl_ctx...');
      EXECUTE IMMEDIATE 'DROP INDEX ' || okc ||'.okc_k_headers_tl_ctx FORCE';
      fnd_file.put_line(fnd_file.log,'INDEX okc_k_headers_tl_ctx succesfully dropped');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 11, 13);

    -- Create context index okc_k_headers_tl_ctx
    DECLARE
      l_max_memory    NUMBER;
      l_cpu_count     NUMBER;
    BEGIN
      fnd_file.put_line(fnd_file.log,'Index Creation Logic Begins');

    BEGIN
      SELECT par_value INTO l_max_memory
      FROM ctx_parameters
      WHERE par_name = 'MAX_INDEX_MEMORY';
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;

      fnd_file.put_line(fnd_file.log,'Max Memory: '||l_max_memory);

    BEGIN
      SELECT value INTO l_cpu_count
      FROM v$parameter
      WHERE name = 'cpu_count';
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;

      fnd_file.put_line(fnd_file.log,'CPU Count: '||l_cpu_count);
      fnd_file.put_line(fnd_file.log,'Before Index Creation');

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 12, 13);

-- Changes for Bug# 6921424
-- l_max_memory and l_cpu_count should be an integer in order to
-- pass them as parameters to the create index statement
      l_max_memory := round(l_max_memory/2);
      l_cpu_count  := round(l_cpu_count/2);
-- Changes For Bug# 6921424 Ends

      EXECUTE IMMEDIATE
      'CREATE INDEX ' || okc || '.okc_k_headers_tl_ctx ON okc_k_headers_tl(short_description)
       INDEXTYPE IS CTXSYS.CONTEXT
       PARAMETERS (''
       DATASTORE  ' || apps || '.okc_k_headers_tl_datastore
       FILTER		ctxsys.null_filter
       LEXER ' || apps || '.okc_k_headers_tl_lexer language column source_lang
       SECTION GROUP ctxsys.null_section_group
       MEMORY ' || l_max_memory || -- For Bug# 6921424
       ' STOPLIST ctxsys.default_stoplist
       WORDLIST	' || apps || '.okc_k_headers_tl_wordlist'') PARALLEL ' || l_cpu_count; -- For Bug# 6921424

       fnd_file.put_line(fnd_file.log,'Index OKC_K_HEADERS_TL_CTX created successfully');
       dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 13, 13);

    EXCEPTION
      WHEN ANYEXP THEN
	   x_return_status := 'E';
      WHEN OTHERS THEN
        BEGIN
          EXECUTE IMMEDIATE 'DROP INDEX ' || okc || '.okc_k_headers_tl_ctx FORCE';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
    END;
  END create_ctx;

  PROCEDURE create_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) AS
    l_api_name        CONSTANT VARCHAR2(30) := 'concurrent_create_ctx';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    request_id        fnd_concurrent_requests.request_id%type;
    l_return_status   VARCHAR2(3) := 'S';
    stop_proc         EXCEPTION;
  BEGIN
    rindex := dbms_application_info.set_session_longops_nohint;
    request_id := get_request_id('OKCCHRCRCTX');
    dbms_application_info.set_session_longops
         (rindex, slno, 'Create Contract Header Text Index', request_id, request_id, 0, 13,
         'OKCCHRCRCTX concurrent program', 'steps');

    create_ctx(x_return_status => l_return_status);
    IF l_return_status <> 'S'
    THEN
      RAISE stop_proc;
    END IF;

    errbuf := 'OKC_K_HEADERS_TL_CTX text index has been created successfully';
    retcode := retcode_success;
  EXCEPTION
    WHEN stop_proc THEN
      retcode := retcode_error;
      errbuf := 'ERROR: Couldn''t create OKC_K_HEADERS_TL_CTX text index';
    WHEN OTHERS THEN
      retcode := retcode_error;
      errbuf := 'ERROR: Couldn''t create OKC_K_HEADERS_TL_CTX text index';
  END create_ctx;

END;

/

  GRANT EXECUTE ON "APPS"."OKC_CHR_KEYWORD_PVT" TO "OKC";
