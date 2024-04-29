--------------------------------------------------------
--  DDL for Package Body PSA_GVTMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_GVTMB" AS
/* $Header: psagvtmb.pls 120.0.12010000.2 2009/05/14 16:28:17 cjain noship $ */
  g_module_name VARCHAR2(100) ;
  g_FAILURE             NUMBER;
  g_SUCCESS             NUMBER;
  g_WARNING             NUMBER;

  PROCEDURE initialize_global_variables
   IS
  BEGIN
    g_module_name         := 'psa.plsql.psagvtmb.';
    g_FAILURE             := -1;
    g_SUCCESS             := 0;
    g_WARNING             := -2;
  END;

  PROCEDURE log
  (
    p_message IN VARCHAR2
  )
  IS
  BEGIN
    fnd_file.put_line (fnd_file.log, p_message);
  END;

  PROCEDURE error
  (
    p_module   IN VARCHAR2,
    p_location IN VARCHAR2,
    p_message  IN VARCHAR2
  )
  IS
  BEGIN
    fnd_file.put_line (fnd_file.log, 'ERROR :'||p_module||'.'||p_location||':'||p_message);
  END;


  PROCEDURE check_and_insert
  (
    p_program_name IN VARCHAR2,
    p_errbuf       OUT NOCOPY VARCHAR2,
    p_retcode      OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
    l_gl_request_group           VARCHAR2(100):= 'GL Concurrent Program Group';
    l_gl_application             VARCHAR2(10) := 'SQLGL';
  BEGIN
    l_module_name := g_module_name || 'check_and_insert';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    IF (fnd_program.program_exists
        (
          program 	  => p_program_name,
			    application	=> l_gl_application
        )) THEN
      BEGIN
        log ('Program '||p_program_name||' exists in fnd_concurrent_programs');

        fnd_program.enable_program
        (
          short_name  => p_program_name,
          application => l_gl_application,
          enabled     => 'Y'
        );

        IF (fnd_program.program_in_group
            (
              program_short_name	=> p_program_name,
              program_application	=> l_gl_application,
              request_group       => l_gl_request_group,
              group_application   => l_gl_application
            ) = FALSE) THEN
          log ('Program '||p_program_name||' does not exist in request_group');
          log ('Inserting Program '||p_program_name||' into request_group');
          fnd_program.add_to_group
          (
            program_short_name  => p_program_name,
            program_application	=> l_gl_application,
            request_group       => l_gl_request_group,
            group_application   => l_gl_application
          );
        ELSE
          log ('Program '||p_program_name||' already exists in request_group');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := 'add_program_to_group';
          error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
      END;
    ELSE
      log ('Program '||p_program_name||' does not exist');
    END IF;

    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE insert_into_request_group
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
    l_program_name               VARCHAR2(100);
  BEGIN
    l_module_name := g_module_name || 'insert_into_request_group';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    fnd_set.set_session_mode('seed_data');

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGDOCDE';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGENCRE';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGEOT';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGFUN';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLXRLTCL';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLBCMP';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

/*
Not yet ready to support this program
    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLXFMA';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;
*/

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGHIST';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_program_name := 'GLGPREP';
      log ('Calling check_and_insert with '||l_program_name);
      check_and_insert
      (
        p_program_name => l_program_name,
        p_errbuf       => p_errbuf,
        p_retcode      => p_retcode
      );
    END IF;
    log ('LEAVE *** '||l_module_name||' ***');


  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE glgv05
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'glgv05';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        log ('Updating columns in fnd_columns for Reporting Attributes');
        UPDATE fnd_columns
           SET flexfield_usage_code = 'K'
         WHERE table_id = (SELECT table_id
                             FROM fnd_tables
                            WHERE application_id = 101
                              AND table_name = 'GL_CODE_COMBINATIONS')
                              AND column_name  LIKE 'SEGMENT_ATTRIBUTE%';
        log ('Updated '||SQL%ROWCOUNT||' rows');
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := 'update_fnd_columns';
          error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
      log ('Updating fnd_flex_value_sets');
        UPDATE fnd_flex_value_sets
           SET format_type = 'C'
         WHERE flex_value_set_name LIKE 'Reporting Attribute:%'
           AND format_type = 'V';
        log ('Updated '||SQL%ROWCOUNT||' rows');
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := 'update_fnd_flex_value_sets';
          error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
      END;
    END IF;
    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE enable_lookups
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'enable_gl_lookups';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    log ('Updating Lookups');
    UPDATE gl_lookups
       SET enabled_flag = 'Y'
     WHERE lookup_type = 'ACCOUNT TYPE'
       AND lookup_code IN ('C', 'D');

    log ('Updated '||SQL%ROWCOUNT||' rows');
    log ('LEAVE *** '||l_module_name||' ***');
    UPDATE fnd_lookups
       SET enabled_flag = 'Y'
     WHERE lookup_type = 'ACCOUNT_TYPE'
       AND lookup_code IN ('C', 'D');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE ins_fnd_lookup_values
  (
    p_lookup_type IN VARCHAR2,
    p_lookup_code IN VARCHAR2,
    p_lookup_meaning IN VARCHAR2,
    p_lookup_desc IN VARCHAR2,
    p_errbuf      OUT NOCOPY VARCHAR2,
    p_retcode     OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'ins_fnd_lookup_values';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    log ('Inserting '||p_lookup_type||':'||p_lookup_code);

    INSERT INTO fnd_lookup_values
    (
      lookup_type,
      language,
      lookup_code,
      meaning,
      description,
      enabled_flag,
      start_date_active,
      end_date_active,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      source_lang,
      security_group_id,
      view_application_id
    )
    SELECT p_lookup_type,
           'US',
           p_lookup_code,
           p_lookup_meaning,
           p_lookup_desc,
           'Y',
           NULL,
           NULL,
           0,
           sysdate,
           0,
           sysdate,
           0,
           'US',
           0,
           0
      FROM sys.dual
     WHERE NOT EXISTS (SELECT 1
                         FROM fnd_lookup_values
                        WHERE lookup_type = p_lookup_type
                          AND language = 'US'
                          AND lookup_code = p_lookup_code
                          AND security_group_id = 0
                          AND view_application_id = 0);

  log ('Inserted '||SQL%ROWCOUNT||' rows');
    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE insert_fnd_lookups
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'insert_fnd_lookups';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');



      log ('Inserting lookup value Fund');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_COMPANY',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Fund',
        p_lookup_desc    => 'Fund',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Revenue');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_SALES',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Revenue',
        p_lookup_desc    => 'Revenue',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Fund Balance');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_EQUITY',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Fund Balance',
        p_lookup_desc    => 'Fund Balance',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Net Revenue');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_EARNING',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Net Revenue',
        p_lookup_desc    => 'Net Revenue',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Order');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_SALES_ORDER',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Order',
        p_lookup_desc    => 'Order',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Agent');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_SALES_REP',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Agent',
        p_lookup_desc    => 'Agent',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Agent');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_SALES_TERRITORY',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Territory',
        p_lookup_desc    => 'Territory',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

   IF (p_retcode = g_SUCCESS) THEN
      log ('Inserting lookup value Agent');
      ins_fnd_lookup_values
      (
        p_lookup_type    => 'IND_SALES_CREDIT',
        p_lookup_code    => 'G',
        p_lookup_meaning => 'Credit',
        p_lookup_desc    => 'Credit',
        p_errbuf         => p_errbuf,
        p_retcode        => p_retcode
      );
   END IF;

  fnd_lookup_values_pkg.add_language;
    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE set_industry_profile
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
    l_industry_value             VARCHAR2(1);
    l_result                     BOOLEAN;
  BEGIN
    l_module_name := g_module_name || 'set_industry_profile';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    log ('Getting Industry Value');

    SELECT industry
      INTO l_industry_value
      FROM fnd_product_installations
     WHERE application_id=101;

    log ('Industry Value = '||l_industry_value);

    IF ( l_industry_value = 'G' ) THEN
      l_result := fnd_profile.save('INDUSTRY', 'G', 'SITE');
    ELSE
      l_result := fnd_profile.save('INDUSTRY', 'C', 'SITE');
    END IF;
    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE set_industry_prod_installation
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'set_industry_prod_installation';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');

    UPDATE fnd_product_installations a
       SET a.industry = 'G'
     WHERE a.application_id in (SELECT application_id
                                  FROM fnd_application
                                 WHERE application_short_name IN ('FND',
                                                                  'SYSADMIN',
                                                                  'SQLGL',
                                                                  'SQLAP',
                                                                  'PO',
                                                                  'AR'));
    log ('LEAVE *** '||l_module_name||' ***');

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

  PROCEDURE main
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  )
  IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'main';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    log ('ENTER *** '||l_module_name||' ***');


    IF (p_retcode = g_SUCCESS) THEN
      log('Calling insert_into_request_group');
      insert_into_request_group (p_errbuf, p_retcode);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      log('Calling glgv05');
      glgv05 (p_errbuf, p_retcode);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      log('Calling enable_fnd_lookups');
      insert_fnd_lookups (p_errbuf, p_retcode);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      log('Calling enable_lookups');
      enable_lookups (p_errbuf, p_retcode);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      log('Calling set_industry_prod_installation');
      set_industry_prod_installation (p_errbuf, p_retcode);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      log('Calling set_industry_profile');
      set_industry_profile (p_errbuf, p_retcode);
    END IF;

    log ('LEAVE *** '||l_module_name||' ***');
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location := 'final_exception';
      error (l_module_name, l_location, SQLCODE||':'||p_errbuf);
  END;

BEGIN
  initialize_global_variables;
END psa_gvtmb;

/
