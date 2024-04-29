--------------------------------------------------------
--  DDL for Package Body JL_BR_SPED_DATA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_SPED_DATA_EXTRACT_PKG" AS
/* $Header: jlbraseb.pls 120.1.12010000.4 2009/12/17 22:39:51 spasupun ship $ */

   l_cc_exists_flag  number :=1;       -- cost center setup flag. it will become zero if cost center setup not done in intialize proc.
  l_exclusive_mode  VARCHAR2(1);
  l_estb_acts_as_company VARCHAR2(1); -- This flag explains whethere LE is acting as company or Establishment is acting as company
                                      -- Will populate this flag with 'Y' , if accounting_type is 'CENTRALIZED' and establishment_id is not null.
  g_state_insc_tax_regime        zx_registrations.tax_regime_code%TYPE;
  g_state_insc_tax               zx_registrations.tax%TYPE;
  g_municipal_insc_tax_regime    zx_registrations.tax_regime_code%TYPE;
  g_municipal_insc_tax           zx_registrations.tax%TYPE;

  PROCEDURE register_I051(p_account_flex_value fnd_flex_values.flex_value%TYPE );
  PROCEDURE register_I052(p_account_flex_value fnd_flex_values.flex_value%TYPE );
  PROCEDURE register_I250(p_journal_header_id gl_je_headers.je_header_id%TYPE,
                          p_journal_name gl_je_headers.name%TYPE,
                          p_journal_source gl_je_headers.je_source%TYPE,
                          p_je_category gl_je_headers.je_category%TYPE);


  PROCEDURE initialize( p_ledger_id                     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE,
                        p_chart_of_accounts_id          GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
                        p_accounting_type               VARCHAR2,
                        p_legal_entity_id                  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
                        p_establishment_id                 XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
                        p_is_special_situation          VARCHAR2,
                        p_period_type                   VARCHAR2,
                        p_period_name                   GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                        p_adjustment_period_name        GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                        p_start_date                    VARCHAR2,
                        p_end_date                      VARCHAR2,
                        p_special_situation_indicator   VARCHAR2,
                        p_bookkeeping_type              VARCHAR2,
                        p_participant_type              JL_BR_SPED_PARTIC_CODES.PARTICIPANT_TYPE%TYPE,
                        p_accounting_segment_type       VARCHAR2,
                        p_coa_mapping_id                VARCHAR2,
                        p_balance_statement_request_id   fnd_concurrent_requests.request_id%TYPE,
                        p_agglutination_code_source     VARCHAR2,
                        p_income_statement_request_id    fnd_concurrent_requests.request_id%TYPE,
                        p_journal_for_rtf               NUMBER,
                        p_hash_code                     VARCHAR2, -- auxillary book
                        p_acct_stmt_ident               VARCHAR2,
                        p_acct_stmt_header              VARCHAR2,
                        p_gen_sped_text_file            VARCHAR2,
                        p_inscription_source            VARCHAR2,
                        p_le_state_reg_code             VARCHAR2,
                        p_le_municipal_reg_code          VARCHAR2,
                        p_state_insc_tax_id                  NUMBER,
                        p_ebtax_state_reg_code          VARCHAR2,
                        p_municipal_insc_tax_id           NUMBER,
                        p_ebtax_municipal_reg_code       VARCHAR2);

  PROCEDURE initialize( p_ledger_id                     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE,
                        p_chart_of_accounts_id          GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
                        p_accounting_type               VARCHAR2,
                        p_legal_entity_id                  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
                        p_establishment_id                 XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
                        p_is_special_situation          VARCHAR2,
                        p_period_type                   VARCHAR2,
                        p_period_name                   GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                        p_adjustment_period_name        GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                        p_start_date                    VARCHAR2,
                        p_end_date                      VARCHAR2,
                        p_special_situation_indicator   VARCHAR2,
                        p_bookkeeping_type              VARCHAR2,
                        p_participant_type              JL_BR_SPED_PARTIC_CODES.PARTICIPANT_TYPE%TYPE,
                        p_accounting_segment_type       VARCHAR2,
                        p_coa_mapping_id                VARCHAR2,
                        p_balance_statement_request_id   fnd_concurrent_requests.request_id%TYPE,
                        p_agglutination_code_source     VARCHAR2,
                        p_income_statement_request_id    fnd_concurrent_requests.request_id%TYPE,
                        p_journal_for_rtf               NUMBER,
                        p_hash_code                     VARCHAR2, -- auxillary book
                        p_acct_stmt_ident               VARCHAR2,
                        p_acct_stmt_header              VARCHAR2,
                        p_gen_sped_text_file            VARCHAR2,
                        p_inscription_source            VARCHAR2,
                        p_le_state_reg_code             VARCHAR2,
                        p_le_municipal_reg_code          VARCHAR2,
                        p_state_insc_tax_id                  NUMBER,
                        p_ebtax_state_reg_code          VARCHAR2,
                        p_municipal_insc_tax_id           NUMBER,
                        p_ebtax_municipal_reg_code       VARCHAR2) AS
   l_api_name                CONSTANT VARCHAR2(30) :='INITIALIZE';
   l_icx_format_mask         VARCHAR2(30);
   l_bsv_count               NUMBER;
   l_le_count                NUMBER;
   l_fsg_output_check        VARCHAR2(100);

   CURSOR bsv_cur IS SELECT jg_info_v1 from jg_zz_vat_trx_gt;  -- jg_zz_vat_trx_gt is global temparary table to store the BSVs associated to LE or Establishment.

   /* Cursor used to find the position of account and sped qualifiers */
   CURSOR pos_qualifier_cur(p_flex_value_set_id NUMBER) IS
	     SELECT rownum,
	            value_attribute_type
	      FROM ( SELECT  value_attribute_type
	               FROM  fnd_flex_validation_qualifiers
	              WHERE  id_flex_code           = 'GL#'
	                AND  id_flex_application_id = 101
	                AND  flex_value_set_id      = p_flex_value_set_id
	          ORDER BY assignment_date, value_attribute_type) ;

BEGIN
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		     G_PKG_NAME||': '||l_api_name||'()+');
      END IF;

      g_created_by            := NVL(fnd_profile.value('USER_ID'),1);
      g_creation_date         := sysdate;
      g_last_updated_by       := NVL(fnd_profile.value('USER_ID'),1);
      g_last_update_date      := sysdate;
      g_last_update_login     := 1;
      g_concurrent_request_id := NVL(fnd_profile.value('CONC_REQUEST_ID'),1);


      IF UPPER(p_accounting_type) = 'DECENTRALIZED' AND p_establishment_id IS NULL THEN
          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DECEN_ESTB_REQ');
          g_errbuf :=  FND_MESSAGE.GET;
          g_retcode :=2;
          return;
      END IF;



      --check whether establishment is acting as company ?? If so Assign 'Y' to l_estb_acts_as_company variable.
      IF p_accounting_type = 'DECENTRALIZED' OR (p_accounting_type='CENTRALIZED' AND p_establishment_id IS NULL) THEN
  	 l_estb_acts_as_company := 'N';
      ELSE
         l_estb_acts_as_company := 'Y';
	  FND_FILE.PUT_LINE(FND_FILE.LOG,G_PKG_NAME||': '||l_api_name||'(): Establishment Acts as Company');
      END IF;



      --Initializing Globals for report paramters

     g_ledger_id                       :=  p_ledger_id;
     g_chart_of_accounts_id            :=  p_chart_of_accounts_id;
     g_accounting_type                 :=  p_accounting_type;
     g_legal_entity_id                 :=  p_legal_entity_id;
     g_establishment_id                :=  p_establishment_id;
     g_special_situation_indicator     :=  p_special_situation_indicator;
     g_bookkeeping_type                :=  p_bookkeeping_type;
     g_participant_type                :=  p_participant_type;
     g_accounting_segment_type         :=  p_accounting_segment_type;
     g_coa_mapping_id                  :=  p_coa_mapping_id;
     g_balance_statement_request_id    :=  p_balance_statement_request_id;
     g_agglutination_code_source       :=  p_agglutination_code_source;
     g_income_statement_request_id     :=  p_income_statement_request_id;
     g_journal_for_rtf                 :=  p_journal_for_rtf;
     g_hash_code                       :=  p_hash_code;
     g_acct_stmt_ident                 :=  p_acct_stmt_ident;
     g_acct_stmt_header                :=  p_acct_stmt_header;
     g_gen_sped_text_file              :=  p_gen_sped_text_file;
     g_adjustment_period_name          :=  p_adjustment_period_name;
     g_inscription_source              :=  p_inscription_source;
     g_le_state_reg_code               :=  p_le_state_reg_code;
     g_le_municipal_reg_code           :=  p_le_municipal_reg_code;
     g_state_tax_id                    :=  p_state_insc_tax_id;
     g_ebtax_state_reg_code            :=  p_ebtax_state_reg_code;
     g_municipal_reg_tax_id            :=  p_municipal_insc_tax_id;
     g_ebtax_municipal_reg_code        :=  p_ebtax_municipal_reg_code;

    -- Initializing other variables

    fnd_file.put_line(fnd_file.log,'p_coa_id:'||p_coa_mapping_id||' g_coa_id:'||g_coa_mapping_id);

      --Deriving Ledger Id to which LE is associated


    /* BEGIN

         SELECT  ledger_id
           INTO  g_ledger_id
           FROM  gl_ledger_le_v
          WHERE  legal_entity_id = g_legal_entity_id
            AND  ledger_category_code='PRIMARY';

     END;  */

      IF p_period_type = '02' THEN
      	 g_closing_period_flag :=  'Y';
      ELSE
         g_closing_period_flag :=  'N';
      END IF;

      BEGIN       --Deriving Company Name. Here check is done whether establishment is acting as company or LE is acting as company.

         IF UPPER(g_accounting_type) = 'DECENTRALIZED'          -- LE acts as company
            OR (UPPER(g_accounting_type) = 'CENTRALIZED' AND g_establishment_id IS NULL) THEN

           SELECT  name
             INTO  g_company_name
             FROM  xle_entity_profiles
            WHERE  legal_entity_id = g_legal_entity_id;

         ELSE   -- Establishment acts like company

	    SELECT  name
	      INTO  g_company_name
              FROM  xle_etb_profiles
             WHERE  establishment_id = g_establishment_id
	       AND  legal_entity_id  = g_legal_entity_id ;

          END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No company found for Legal Entity Id: '||p_legal_entity_id||'  Establishment Id :'||p_establishment_id);
         END IF;
          g_errbuf := 'Company Not Found ';
          g_retcode := 2;
          return;
      WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Faied to get company Name. Legal Entity Id: '||p_legal_entity_id||'  Establishment Id :'||p_establishment_id);
           END IF;
          g_errbuf := 'Faied to get Company Name ';
          g_retcode := 2;
          return;
     END;

    BEGIN              -- Deriving the period_set_name,currency code

         SELECT  period_set_name,currency_code,accounted_period_type
           INTO  g_period_set_name,g_currency_code,g_accounted_period_type
           FROM  gl_ledgers
          WHERE  ledger_id = g_ledger_id;

         FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Period Set Name: '||g_period_set_name||', Currency Code:'||g_currency_code||', Accounted Period Type :'||g_accounted_period_type);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No record exists for ledger: '||g_ledger_id);
          END IF;
          g_errbuf := 'Error while fetching Pertiod Set Name and Currency Code ';
          g_retcode := 2;
          return;
       WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get period_set_name for Ledger: '||g_ledger_id);
           END IF;
          g_errbuf := 'Error while fetching Pertiod Set Name and Currency Code ';
          g_retcode := 2;
          return;
    END;


   /*  Checking Whether the Legal entity setup is in Exclusive Mode or in Shared Mode
        If no BSVs exists then taking it as exlusive mode. In this case filtering of transactions,balances will be
	done only based on Ledger_id(AS one to one relation exists between Ledger and LE. */
    BEGIN

        SELECT  COUNT(segment_value)
          INTO  l_bsv_count
          FROM  GL_LEDGER_NORM_SEG_VALS
         WHERE  ledger_id = g_ledger_id
           AND  legal_entity_id = g_legal_entity_id
           AND  segment_type_code = 'B';

        IF  l_bsv_count = 0 THEN

            SELECT  count(distinct legal_entity_id)
	            INTO  l_le_count
              FROM  gl_ledger_le_v
             WHERE  ledger_id = g_ledger_id
               AND  ledger_category_code='PRIMARY' ;

            IF  l_le_count = 1 THEN
                l_exclusive_mode := 'Y';
	    ELSE
                g_errbuf := 'More than one LE is associated to Ledger. And No BSVs exists. So It is not possible to filter the data from LE';
                g_retcode := 2;
                return;
            END IF;

        ELSIF l_bsv_count >0 THEN
              l_exclusive_mode := 'N';  -- shared mode
        END IF;
    EXCEPTION
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to check whether it is exclusive mode or shared mode');
             END IF;
             g_errbuf := 'Failed to check whether it is exclusive mode or shared mode';
             g_retcode := 2;
             return;
    END;

    IF l_exclusive_mode ='N' THEN       /* If not exclusive mode deriving the BSVs attached to either LE or Establishment
                                           for filtering and storing in a gt table(jg_zz_vat_trx_gt) */

	  INSERT INTO jg_zz_vat_trx_gt (jg_info_n1,
                                        jg_info_v1)
          SELECT  g_concurrent_request_id,
                  segment_value
            FROM  GL_LEDGER_NORM_SEG_VALS
           WHERE  ledger_id = g_ledger_id
             AND  legal_entity_id = g_legal_entity_id
             AND  segment_type_code = 'B'
             AND  g_establishment_id is null -- IF running in Centralized mode and only for LE
          UNION
          SELECT  g_concurrent_request_id,
                  entity_name
            FROM  xle_bsv_associations
           WHERE  legal_parent_id =  g_legal_entity_id
             AND  legal_construct_id = g_establishment_id
             AND  context = 'EST_BSV_MAPPING'
             AND  entity_type = 'BALANCING_SEGMENT_VALUE'
             AND  legal_construct ='ESTABLISHMENT'
             AND  g_establishment_id is not null; -- running in decentralized mode or in centralized mode for establishment(Establishment acts as company)



        FND_FILE.PUT(FND_FILE.LOG,'Balancing Segments associated to the Comapny are :');

	FOR bsv_rec in bsv_cur LOOP            --To display balancing segments associated to LE or ESTB (Company)

                 FND_FILE.PUT(FND_FILE.LOG,bsv_rec.jg_info_v1||'   ');

	END LOOP;

                 FND_FILE.PUT_LINE(FND_FILE.LOG,'   ');
    END IF; -- End for IF l_exclusive_mode ='N'

    IF p_special_situation_indicator IS NULL THEN

        BEGIN

          SELECT  start_date, end_date
            INTO  g_start_date,g_end_date
            FROM  gl_periods
           WHERE  period_name = p_period_name
             AND  period_set_name = g_period_set_name;

           g_period_name := p_period_name;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
             		 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Not a valid period: '||p_period_name);
             END IF;
            g_errbuf := 'Not a valid period ';
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get start and end dates for '||p_period_name);
             END IF;
             g_errbuf := 'Failed to get start and end dates for '||p_period_name;
             g_retcode := 2;
             return;
        END;

      ELSE       -- If special situation indicator not null.

         BEGIN

            l_icx_format_mask := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'RRRR/MM/DD');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ICX Date Format Mask : '||l_icx_format_mask);
            g_start_date := to_date(p_start_date,l_icx_format_mask);
            g_end_date   := to_date(p_end_date,l_icx_format_mask);

            SELECT  period_name
              INTO  g_period_name
              FROM  gl_periods
             WHERE  period_set_name = g_period_set_name
               AND  period_type = g_accounted_period_type
               AND  g_start_date BETWEEN start_date AND end_date
               AND  g_end_date BETWEEN start_date AND end_date;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
            		FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Start and end dates do not belong to same period: '||p_start_date||' '||p_end_date);
            END IF;
             g_errbuf := 'Start and end date do not belong to same period: '||p_start_date||' '||p_end_date;
             g_retcode := 2;
             return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get period name for given start and end dates '||p_start_date||' '||p_end_date);

             END IF;
              g_errbuf := 'Failed to get period name for given start and end date '||p_start_date||' '||p_end_date||'  '||SQLERRM;
              g_retcode := 2;
              return;
          END;

      END IF; -- End for check on special situation indicator.

      IF g_adjustment_period_name IS NOT NULL THEN

       BEGIN
          SELECT  start_date, end_date
            INTO  g_adjustment_period_start_date,g_adjustment_period_end_date
            FROM  gl_periods
           WHERE  period_name = p_adjustment_period_name
             AND  period_set_name = g_period_set_name
             AND  adjustment_period_flag = 'Y';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
             		 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Not a valid period: '||p_period_name);
             END IF;
            g_errbuf := 'Not a valid adjustment period ';
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get start and end dates for '||p_period_name);
             END IF;
             g_errbuf := 'Failed to get start and end dates for adjustment period '||p_period_name;
             g_retcode := 2;
             return;
        END;

      END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Start_date  :'||g_start_date||' End_date: '||g_end_date);

     BEGIN
         SELECT  application_column_name      -- finding which segment column is used for balancing segment storage
           INTO  g_bsv_segment
           FROM  fnd_segment_attribute_values
          WHERE  id_flex_code            = 'GL#'
            AND  attribute_value         = 'Y'
            AND  segment_attribute_type  = 'GL_BALANCING'
            AND  application_id          = 101
            AND  id_flex_num             = g_chart_of_accounts_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
       	        FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No balacing segment found in fnd_segment_attribute_values' );
            END IF;
            g_errbuf := 'No balancing segment found in fnd_segment_attribute_values for '||g_chart_of_accounts_id;
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get column used for Balancing segment');
             END IF;
            g_errbuf := 'Failed to get column used for Balancing segment';
            g_retcode := 2;
            return;
       END;

       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Balancing segment: '||g_bsv_segment);

     BEGIN
         SELECT  application_column_name      -- finding which segment column is used for natural account segment storage
           INTO  g_account_segment
           FROM  fnd_segment_attribute_values
          WHERE  id_flex_code            = 'GL#'
            AND  attribute_value         = 'Y'
            AND  segment_attribute_type  = 'GL_ACCOUNT'
            AND  application_id          = 101
            AND  id_flex_num             = g_chart_of_accounts_id;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Natural account segment found in fnd_segment_attribute_values' );
            END IF;
            g_errbuf := 'No Natural account segment found in fnd_segment_attribute_values for '||g_chart_of_accounts_id;
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get column used for Natural account');
             END IF;
            g_errbuf := 'Failed to get column used for Natural account';
            g_retcode := 2;
            return;
     END;

       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Natural Account segment: '||g_account_segment);

     BEGIN
         SELECT  application_column_name      -- finding which segment column is used for cost center storage
           INTO  g_cost_center_segment
           FROM  fnd_segment_attribute_values
          WHERE  id_flex_code            = 'GL#'
            AND  attribute_value         = 'Y'
            AND  segment_attribute_type  = 'FA_COST_CTR'
            AND  application_id          = 101
            AND  id_flex_num             = g_chart_of_accounts_id;

	     FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Cost center segment: '||g_cost_center_segment);

	   EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No cost center segment found in fnd_segment_attribute_values' );
            END IF;

	    l_cc_exists_flag := 0; -- cost center setup doesn't exist
            g_cost_center_segment := 'SEGMENT20'; -- To frame the dynamic query in I155,I310 assigned this column name. But we won't retrieve this column values.
	                                          -- If l_cc_exists_flag = 0 then we will retrieve null
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get column used for cost center');
             END IF;

	    l_cc_exists_flag := 0;
            g_cost_center_segment := 'SEGMENT20';

       END;

             -- Deriving value set id for Natural Accounts
     BEGIN

         SELECT  flex_value_set_id
           INTO  g_account_value_set_id
           FROM  fnd_id_flex_segments
          WHERE  id_flex_num    = g_chart_of_accounts_id
            AND  id_flex_code   ='GL#'
            AND  application_id = 101
            AND  application_column_name = g_account_segment;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No value set found for: '||g_account_segment);
             END IF;
            g_errbuf := 'No value set found for: '||g_account_segment;
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed in retrieving value set'||g_account_segment);
             END IF;
            g_errbuf := 'Failed in retrieving value set for'||g_account_segment;
            g_retcode := 2;
            return;
     END;

     FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Value set id for Natural Account :'||g_account_value_set_id);

     -- Deriving value set id for Cost Center (only if cost center setup was done)

     IF l_cc_exists_flag <>0 THEN

     BEGIN

         SELECT  flex_value_set_id
           INTO  g_cost_center_value_set_id
           FROM  fnd_id_flex_segments
          WHERE  id_flex_num    = g_chart_of_accounts_id
            AND  id_flex_code   ='GL#'
            AND  application_id = 101
            AND  application_column_name = g_cost_center_segment;

          FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Value set id for Cost Center :'||g_cost_center_value_set_id);

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No value set found for: '||g_cost_center_segment);
            END IF;
	          g_errbuf := 'No value set found for: '||g_cost_center_segment;
            g_retcode := 2;
            return;
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed in retrieving value set'||g_cost_center_segment);
             END IF;
            g_errbuf := 'Failed in retrieving value set for'||g_cost_center_segment;
            g_retcode := 2;
            return;
       END;

       END IF; -- END for IF l_cc_exists_flag <> 0

       /* Deriving the position of account and sped qualifiers */
       BEGIN
           -- deriving sped account qualifier position
           FOR pos_qual_rec IN pos_qualifier_cur(g_account_value_set_id)--(acct_vsetid)
	         LOOP
	             IF pos_qual_rec.value_attribute_type = 'SPED_ACCOUNT_TYPE' THEN
	                g_sped_qualifier_position  := pos_qual_rec.rownum;
	                EXIT ;
	             END IF;
	         END LOOP;

           --deriving account qualifier position
           FOR pos_qual_rec IN pos_qualifier_cur(g_account_value_set_id)--(acct_vsetid)
           LOOP
	            IF pos_qual_rec.value_attribute_type = 'GL_ACCOUNT_TYPE' THEN
	                g_account_qualifier_position := pos_qual_rec.rownum;
	                EXIT ;
              END IF;
	         END LOOP;

           FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Position of sped qualifier : '||g_sped_qualifier_position);
           FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Position of account qualifier : '||g_account_qualifier_position);

       EXCEPTION
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed in retrieving value set'||g_cost_center_segment);
             END IF;
            g_errbuf := 'Failed in Deriving the position of account and sped qualifiers';
            g_retcode := 2;
            return;
       END;

       BEGIN
        IF p_balance_statement_request_id is not null THEN

           SELECT  argument7 -- balancesheet report_id
             INTO  g_balance_statement_report_id
             FROM  fnd_concurrent_requests
            WHERE  request_id = p_balance_statement_request_id;
        END IF;

        EXCEPTION
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed in retrieving Balance Sheet Report ID');
             END IF;
       END;

      FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Balance Sheet Report Id : '||g_balance_statement_report_id);

      BEGIN
      IF p_income_statement_request_id IS NOT NULL THEN
           SELECT  argument7 --Income Statement report_id
             INTO  g_income_statement_report_id
             FROM  fnd_concurrent_requests
           WHERE  request_id = p_income_statement_request_id;
      END IF;

        EXCEPTION
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed in retrieving Income Statement Report ID');
             END IF;
       END;
      FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Income Statement Report Id : '||g_income_statement_report_id);

   BEGIN

     SELECT  COUNT(*)
       INTO  g_ap_ar_auxbook_exist
       FROM  jl_br_cinfos_books
      WHERE  legal_entity_id = g_legal_entity_id
        AND  ((l_estb_acts_as_company='N' AND establishment_id is null)
	       OR (l_estb_acts_as_company='Y' AND establishment_id = g_establishment_id))
        AND  bookkeeping_type = 'A'
        AND  auxiliary_book_source = 'AP/AR';

  EXCEPTION
      WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Verifiying the auxiliary books setup availabiblity.');
           END IF;
  END;

  IF substr(g_bookkeeping_type,1,1) = 'A' AND g_ap_ar_auxbook_exist = 0 THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Auxiliary Book is not defined for Book Source AP/AR');
  END IF;



       /* BEGIN: Deriving the column type of first column in balance statement report  */

    IF g_bookkeeping_type <> 'A/R' AND g_bookkeeping_type <> 'A/B' THEN
    IF g_balance_statement_request_id IS NOT NULL THEN
       BEGIN
            SELECT  amount_type
              INTO  l_fsg_output_check
              FROM (SELECT  r2.*
                      FROM  fnd_concurrent_requests req,
                            rg_reports r1,
                            rg_report_axes_v r2
                     WHERE  req.request_id = g_balance_statement_request_id
                       AND  r1.report_id   = req.argument7  --arguement7 in fnd_concurrent_requests holds the report id
                       AND  r1.column_set_id = r2.axis_set_id
                       ORDER BY r2.sequence)
             WHERE  ROWNUM = 1;

	 FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount Type in Balance Sheet Report is :'||l_fsg_output_check);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No data found for Balance sheet request Id:'||g_balance_statement_request_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
	   WHEN OTHERS THEN
	       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get information for Balance sheet request Id:'||g_balance_statement_request_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	       END IF;
       END;

   END IF;    --END for IF g_balance_statement_request_id is not null

       /*Checking the amount type of first column in income statement report */

   IF g_income_statement_request_id IS NOT NULL THEN
       BEGIN

            SELECT  amount_type
              INTO  l_fsg_output_check
              FROM  (SELECT  r2.*
                       FROM  fnd_concurrent_requests req,
                             rg_reports r1,
                             rg_report_axes_v r2
                      WHERE  req.request_id = g_income_statement_request_id
                        AND  r1.report_id   = req.argument7  --arguement7 in fnd_concurrent_requests holds the report id
                        AND  r1.column_set_id = r2.axis_set_id
                      ORDER BY r2.sequence)
              WHERE  ROWNUM = 1;

	FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount Type in Income Statement Report is :'||l_fsg_output_check);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No data found exception while trying to fetch amount type for Income Statement Report'||g_income_statement_request_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
           WHEN OTHERS THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Failed to get information for Income statement request id:'||g_income_statement_request_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
       END;

   END IF; --    End for IF g_income_statement_request_id is not null
   END IF; --IF g_bookkeping_type <> 'A/R' AND g_bookkeeping_type <> 'A/B' THEN

   IF p_inscription_source = 'ZX' THEN

      IF p_state_insc_tax_id IS NOT NULL THEN

	    BEGIN
                 SELECT tax_regime_code, tax
                   INTO g_state_insc_tax_regime,g_state_insc_tax
                   FROM zx_taxes_b
                  WHERE tax_id = p_state_insc_tax_id;

	    EXCEPTION
               WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error while retrieving the tax regime and tax used to create state inscription.');
		     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                  END IF;
            END;

      END IF; -- End for IF p_state_insc_tax_id IS NOT NULL

      IF p_municipal_insc_tax_id IS NOT NULL THEN

	    BEGIN
                 SELECT tax_regime_code, tax
                   INTO g_municipal_insc_tax_regime,g_municipal_insc_tax
                   FROM zx_taxes_b
                  WHERE tax_id = p_municipal_insc_tax_id;

	    EXCEPTION
               WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error while retrieving the tax regime and tax used to create municipal inscription.');
		     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                  END IF;
            END;

      END IF; -- End for IF p_state_insc_tax_id IS NOT NULL

   END IF; -- End for IF p_inscription_source = 'ZX'(EBTax);

   BEGIN
       INSERT INTO JL_BR_SPED_EXTR_PARAM
      (REQUEST_ID,
       LEDGER_ID,
       LEGAL_ENTITY_ID,
       ESTABLISHMENT_ID,
       PERIOD_TYPE,
       PERIOD_NAME,
       ADJUSTMENT_PERIOD,
       SPEC_SITU_INDIC,
       SPEC_SITU_START_DATE,
       SPEC_SITU_END_DATE,
       BOOKKEEPING_TYPE,
       ESTB_ACCT_TYPE,
       PARTICIPANT_TYPE,
       PARTIC_ACCT_SEGMENT,
       CONSOL_MAP_ID,
       BALSHEET_REP_REQUEST_ID,
       INCMSTMT_REP_REQUEST_ID,
       AGC_SOURCE,
       RTF_FILE_SOURCE,
       HAS_CODE,
       ACCT_STMT_INDF,
       ACCT_STMT_HEADER,
       DATA_EXIST,
       REPORT_MODE,
       REGISTRATION_SOURCE,
       XLE_STATE_INS_REG_CODE,
       XLE_CITY_INS_REG_CODE,
       ZX_STATE_INS_TAX_ID,
       ZX_STATE_INS_REG_CODE,
       ZX_CITY_INS_TAX_ID,
       ZX_CITY_INS_REG_CODE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
       VALUES ( g_concurrent_request_id,
                g_ledger_id,
                p_legal_entity_id,
                p_establishment_id,
		p_period_type,
                g_period_name,
		p_adjustment_period_name,
                p_special_situation_indicator,
		g_start_date,
		g_end_date,
                p_bookkeeping_type,
                p_accounting_type,
                p_participant_type,
                p_accounting_segment_type,
                p_coa_mapping_id,
                p_balance_statement_request_id,
                p_income_statement_request_id,
                p_agglutination_code_source,
                p_journal_for_rtf ,  --rtf_file_soource
                p_hash_code,
                p_acct_stmt_ident,  --acct_stmt_indf
                p_acct_stmt_header,   --acct_stmt_header
                'N',
                'P',    --report_mode
                p_inscription_source,
                p_le_state_reg_code,
                p_le_municipal_reg_code,
                p_state_insc_tax_id,
                p_ebtax_state_reg_code,
                p_municipal_insc_tax_id ,
                p_ebtax_municipal_reg_code,
                g_created_by,
                g_creation_date,
                g_last_updated_by,
                g_last_update_date,
                g_last_update_login
               );

        EXCEPTION
          WHEN OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR While inserting into JL_BR_SPED_EXTR_PARAM    ');
             END IF;
            g_errbuf := 'ERROR While inserting into JL_BR_SPED_EXTR_PARAM    '||SQLERRM;
            g_retcode := 2;
            return;
      END;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                  	G_PKG_NAME||': ' ||l_api_name||'()-');
      END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR in Intialize Procedure    '||SQLERRM;
      g_retcode := 2;
      return;



END initialize;

FUNCTION get_segment_value(ccid NUMBER,segment_code VARCHAR2) RETURN VARCHAR2 AS
/* This function is to return the value of segment for a code_combination_id.
If segment_code is segment1, then the value of segment1 for the given code_combination_id(ccid) will be returned*/
segment_value  gl_code_combinations.segment1%TYPE;
sqlstmt        VARCHAR2(100);
l_api_name     CONSTANT VARCHAR2(30) :='GET_SEGMENT_VALUE';
BEGIN


    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		     G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

   sqlstmt := 'SELECT to_char('||segment_code||') FROM gl_code_combinations WHERE code_combination_id = :ccid';

   BEGIN
         EXECUTE IMMEDIATE sqlstmt INTO segment_value USING  ccid;
   EXCEPTION
         WHEN NO_DATA_FOUND THEN
              IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No '||segment_code||' value found for: '||ccid);
              END IF;
              RETURN NULL;
         WHEN OTHERS THEN
          IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Faied to get '||segment_code||' value for '||ccid);
           END IF;
           RETURN NULL;

   END;
   RETURN segment_value;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                  	G_PKG_NAME||': ' ||l_api_name||'()-');
      END IF;
EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

END get_segment_value;

FUNCTION get_account_type(p_flex_Value_id  fnd_flex_values.flex_value_id%TYPE) RETURN VARCHAR2 AS
/* This function returns the Account Type for flex value .
  For the flex value if there is sped account type other than 'Not applibale' then this function
  returns the corresponding sped account code, otherwise it will return account code for the
  GL_ACCOUNT_TYPE*/
l_position_qualifier_account INTEGER;
l_position_qualifier_sped    INTEGER;
l_SPED_CODE                  VARCHAR2(1);
l_SPED_CODE_VALUE            VARCHAR2(2);
l_ACCT_CODE                  VARCHAR2(1);
l_ACCT_CODE_VALUE            VARCHAR2(2);
l_api_name                   CONSTANT VARCHAR2(30) :='GET_ACCOUNT_TYPE';

BEGIN

   IF g_sped_qualifier_position IS NOT NULL THEN
      BEGIN
         SELECT DECODE(vs.flex_value, 'T', 'O', substrb( fnd_global.newline
	                    ||vs.compiled_value_attributes
	                    ||fnd_global.newline, instrb( fnd_global.newline
	                    ||vs.compiled_value_attributes
	                    ||fnd_global.newline, fnd_global.newline,1,g_sped_qualifier_position)+1, 1 ))
	         INTO  l_sped_code
	         FROM  fnd_flex_values vs
	        WHERE  flex_value_id=p_flex_Value_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_sped_code := null;
         WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Faied to sped accounting code for: '||p_flex_value_id);
           END IF;
      END;
   END IF;

	  IF l_sped_code IS NULL OR l_sped_code = 'N' THEN

        BEGIN

               SELECT  DECODE(vs.flex_value, 'T', 'O', substrb( fnd_global.newline
	                         ||vs.compiled_value_attributes
	                         ||fnd_global.newline, instrb( fnd_global.newline
	                         ||vs.compiled_value_attributes
	                         ||fnd_global.newline, fnd_global.newline,1,g_account_qualifier_position)+1, 1 ))
	               INTO  l_acct_code
	               FROM  fnd_flex_values vs
	              WHERE  flex_value_id=p_flex_value_id;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_acct_code := null;
         WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Faied to get accounting code for: '||p_flex_value_id);
           END IF;
       END;

        SELECT  DECODE(l_acct_code, 'A', '01', 'L','02', 'O','03', 'E','04', 'R','04',null)
	        INTO  l_acct_code_value
	        FROM  DUAL;

     ELSE

        SELECT  DECODE (l_sped_code, 'C', '05', 'T','09',null)
          INTO  l_sped_code_value
          FROM  DUAL;

	   END IF;

     RETURN NVL(l_sped_code_value,l_acct_code_value);

END get_account_type;

FUNCTION get_participant_code (p_je_header_id gl_je_headers.je_header_id%TYPE,
                               p_je_line_num gl_je_lines.je_line_num%TYPE,
                               p_journal_source gl_je_headers.je_source%TYPE,
                               p_je_line_ccid gl_je_lines.code_combination_id%TYPE,
                               p_third_party_id NUMBER,
                               p_third_party_site_id NUMBER) RETURN VARCHAR2 AS
l_participant_code      jl_br_sped_partic_codes.participant_code%TYPE := NULL;
l_third_party_count     NUMBER := 0;
l_third_party_id        NUMBER;
l_third_party_site_id   NUMBER;
l_receivable_category   VARCHAR2(50);
l_partic_active_flag    NUMBER := 0;
l_api_name              CONSTANT VARCHAR2(30) :='GET_PARTICIPANT_CODE';

BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
	                                     G_PKG_NAME||': '||l_api_name||'()+');
    END IF;


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num||'  Source'||p_journal_source);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'CCID :'||p_je_line_ccid||' Third Party Id:'||p_third_party_id||' Site Id :'||p_third_party_site_id);
    END IF;


  -- In case of Manual Journal, User can enter Participant Code at Jounral Header or Lines level GDF.
  --

   IF p_journal_source = 'Manual'  THEN

      BEGIN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	                                   'Manual Journal:'||p_je_header_id||'-'||p_je_line_num);
          END IF;


       SELECT  nvl(jl.global_attribute5,jh.global_attribute5)
         INTO  l_participant_code
         FROM  gl_je_headers jh
               ,gl_je_lines jl
               ,jl_br_sped_partic_codes pc
        WHERE  jh.je_header_id = jl.je_header_id
          AND  jh.je_header_id = p_je_header_id
          AND  jl.je_line_num  = p_je_line_num
          AND  pc.ledger_id = g_ledger_id
          AND  nvl(jl.global_attribute5,jh.global_attribute5) = pc.participant_code    --- to get the particpant code
          AND  ((g_participant_type in ('SUPPLIERS','CUSTOMERS','SUPPLIER_SITES','CUSTOMER_SITES') AND participant_type = g_participant_type) OR
               (g_participant_type = 'ACCOUNTING_FLEXFIELD_SEGMENT' AND pc.segment_type = g_accounting_segment_type) OR
               (g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' AND participant_type = 'SUPPLIERS') OR
               (g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' AND participant_type = 'CUSTOMERS') OR
               (g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' AND participant_type = 'SUPPLIER_SITES') OR
               (g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' AND participant_type = 'CUSTOMER_SITES') );

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLCODE||' '||SQLERRM);
                  END IF;
         	  l_participant_code := NULL;
             WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLCODE||' '||SQLERRM);
                  END IF;
                  l_participant_code := NULL;
          END;

         BEGIN
           SELECT 1                --if no data found means, no active relation in the report period.
             INTO l_partic_active_flag
             FROM dual
            WHERE EXISTS ( SELECT 1 FROM jl_br_sped_partic_rel rel
            WHERE  rel.LEGAL_ENTITY_ID  = g_legal_entity_id
              AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                   OR  (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
              AND rel.participant_code = l_participant_code
              AND rel.effective_from <= g_end_date
              AND nvl(rel.effective_to,sysdate) >= g_start_date);

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLCODE||' '||SQLERRM);
                         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'Source'||p_journal_source||'Participant_type'||g_participant_type);
                  END IF;
		  l_participant_code := NULL;
             WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLCODE||' '||SQLERRM);
                  END IF;
                  l_participant_code := NULL;
          END;
          RETURN   l_participant_code;

   ELSIF g_participant_type = 'ACCOUNTING_FLEXFIELD_SEGMENT' THEN  -- Else part for IF p_journal_source = 'Manual' OR l_journalsource_check = 1   THEN
     BEGIN
        SELECT  pc.participant_code
          INTO  l_participant_code
          FROM  jl_br_sped_partic_codes pc
         WHERE  pc.ledger_id = g_ledger_id
          AND  pc.segment_type = g_accounting_segment_type
             AND  get_segment_value(p_je_line_ccid,
                                  decode(g_accounting_segment_type,'GL_ACCOUNT',g_account_segment
                                                                  ,'GL_BALANCING',g_bsv_segment
                                                                  ,'FA_COST_CTR',g_cost_center_segment)) = pc.flex_value
                                                                  ---,g_estb_segment_type,g_establishment_segment)) = pc.flex_value
          AND  EXISTS (SELECT 1
                        FROM jl_br_sped_partic_rel rel
                      WHERE rel.LEGAL_ENTITY_ID  = g_legal_entity_id
                        AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                                 OR  (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
                       AND rel.participant_code = pc.participant_code
                       AND rel.effective_from <= g_end_date
                       AND nvl(rel.effective_to,sysdate) >= g_start_date );

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No participant code found');
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
	       l_participant_code := NULL;
          WHEN OTHERS THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error while retrieving the participant code.');
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
               l_participant_code := NULL;
      END;

      RETURN  l_participant_code;

   END IF; --END IF for IF p_journal_source = 'Manual'  THEN


   IF substr(g_bookkeeping_type,1,1) = 'A' THEN
       --As drilldown done in I250, third_party_id and third_party_site_id are passed from I250

	 l_third_party_id      := p_third_party_id;
         l_third_party_site_id := p_third_party_site_id;


   ELSE   --BK Type <> 'A'

      BEGIN

         SELECT  DISTINCT  xll.party_id , xll.party_site_id     --- NEED TO CHECK IF SAME CUSTOMER WITH DIFFERENT CUST SITE ID
           INTO  l_third_party_id, l_third_party_site_id
           FROM  gl_import_references glimp, GL_JE_LINES JL ,  xla_ae_lines xll
          WHERE  glimp.je_header_id  = p_je_header_id
            AND  glimp.je_header_id  = jl.je_header_id
            AND  glimp.je_line_num   = p_je_line_num
            AND  glimp.je_line_num   = jl.je_line_num
            AND  xll.ledger_id       = g_ledger_id
            AND  xll.gl_sl_link_id   = glimp.gl_sl_link_id
            AND  xll.gl_sl_link_table= glimp.gl_sl_link_table;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              RETURN NULL;  --participant_code not found.
	 WHEN OTHERS THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num);
		     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'  Source'||p_journal_source||'  Participant_type'||g_participant_type);
               END IF;
              RETURN NULL;
      END;

   END IF;

   IF p_journal_source = 'Payables' THEN

            IF g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' OR g_participant_type = 'SUPPLIERS' THEN

                 BEGIN
                       SELECT  pc.participant_code
                         INTO  l_participant_code
                         FROM  jl_br_sped_partic_codes pc
                        WHERE  vendor_id  = l_third_party_id
                          AND  participant_type = 'SUPPLIERS'
                          AND  enabled_flag = 'Y'
                          AND  EXISTS (SELECT 1
                                         FROM jl_br_sped_partic_rel rel
                                        WHERE rel.participant_code = pc.participant_code
                                          AND legal_entity_id = g_legal_entity_id
                                          AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                                                OR (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
                                          AND rel.effective_from <= g_end_date
                                          AND nvl(rel.effective_to,sysdate) >= g_start_date) ;

                       RETURN l_participant_code;
                  EXCEPTION
                    WHEN  NO_DATA_FOUND THEN
                       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Participant Code found '||SQLERRM);
                        END IF;
		       RETURN NULL;  --participant_code not found.

                    WHEN OTHERS THEN
                             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num);
				FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'  Source'||p_journal_source||'  Participant_type'||g_participant_type);
                             END IF;
                             RETURN NULL;
                  END;

            ELSIF g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' OR g_participant_type = 'SUPPLIER_SITES' THEN

                  BEGIN
                      SELECT pc.participant_code
                        INTO l_participant_code
                        FROM jl_br_sped_partic_codes pc
                       WHERE vendor_id        = l_third_party_id
                         AND vendor_site_id   = l_third_party_site_id
                         AND participant_type = 'SUPPLIER_SITES'
                         AND enabled_flag = 'Y'
                         AND  EXISTS (SELECT 1
                                        FROM jl_br_sped_partic_rel rel
                                       WHERE rel.participant_code = pc.participant_code
                                         AND legal_entity_id = g_legal_entity_id
                                         AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                                              OR (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
                                         AND rel.effective_from <= g_end_date
                                         AND nvl(rel.effective_to,sysdate) >= g_start_date);

                          RETURN l_participant_code;

                   EXCEPTION
                    WHEN  NO_DATA_FOUND THEN
                       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Participant Code found '||SQLERRM);
                        END IF;
		       RETURN NULL;  --participant_code not found.
                    WHEN OTHERS THEN
                             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num);
				FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||' Source'||p_journal_source||' Participant_type'||g_participant_type);
                             END IF;
                             RETURN NULL;
                  END;

            END IF; --End for p_participant_type = 'SUPPLIERS_AND_CUSTOMERS' OR p_participant_type = 'SUPPLIERS'

        ELSIF p_journal_source = 'Receivables' THEN

              IF g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' OR g_participant_type = 'CUSTOMERS' THEN
                   BEGIN
                          SELECT  pc.participant_code
                            INTO  l_participant_code
                            FROM  jl_br_sped_partic_codes pc
                           WHERE  pc.cust_account_id  = l_third_party_id
                             AND  pc.participant_type = 'CUSTOMERS'
                             AND  EXISTS (SELECT 1
                                            FROM jl_br_sped_partic_rel rel
                                           WHERE rel.participant_code = pc.participant_code
                                             AND legal_entity_id = g_legal_entity_id
                                             AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                                                    OR (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
                                             AND rel.effective_from <= g_end_date
                                             AND nvl(rel.effective_to,sysdate) >= g_start_date);

                          RETURN l_participant_code;
                    EXCEPTION
                    WHEN  NO_DATA_FOUND THEN
                       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Participant Code found '||SQLERRM);
                        END IF;
		       RETURN NULL;  --participant_code not found.
                    WHEN OTHERS THEN
                             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num);
				FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'  Source'||p_journal_source||'  Participant_type'||g_participant_type);
                                RETURN NULL;
                             END IF;
                  END;

              ELSIF g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' OR g_participant_type = 'CUSTOMER_SITES' THEN

                        BEGIN

                             SELECT  pc.participant_code
                                INTO  l_participant_code
                                FROM  jl_br_sped_partic_codes pc
                                      ,hz_cust_site_uses_all hcsu
                               WHERE  hcsu.cust_acct_site_id = pc.cust_acct_site_id
                                -- AND  pc.cust_account_id  = l_third_party_id
                                 AND  hcsu.site_use_id    = l_third_party_site_id
                                 AND  pc.participant_type = 'CUSTOMER_SITES'
                                 AND  EXISTS (SELECT 1
                                                FROM jl_br_sped_partic_rel rel
                                               WHERE rel.participant_code = pc.participant_code
                                                 AND legal_entity_id = g_legal_entity_id
                                                 AND ((l_estb_acts_as_company ='Y' AND establishment_id=g_establishment_id)
                                                      OR (l_estb_acts_as_company='N' AND establishment_id is null))   --- Need to modify
                                                 AND rel.effective_from <= g_end_date
                                                 AND nvl(rel.effective_to,sysdate) >= g_start_date);

                              RETURN l_participant_code;
                       EXCEPTION
                          WHEN  NO_DATA_FOUND THEN
                              IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Participant Code found '||SQLERRM);
                               END IF;
			       RETURN NULL;  --participant_code not found.
                          WHEN OTHERS THEN
                             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Journal Header: '||p_je_header_id||'  Journal Line: '||p_je_line_num);
				FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'  Source'||p_journal_source||'  Participant_type'||g_participant_type);
                             END IF;
                             RETURN NULL;
                       END;

              END IF; -- End for IF p_participant_type = 'SUPPLIERS_AND_CUSTOMERS' OR p_participant_type = 'SUPPLIERS'

        END IF; --End for IF p_journal_source = 'Payables'

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                  	G_PKG_NAME||': ' ||l_api_name||'()-');
      END IF;


return l_participant_code;

EXCEPTION
   WHEN OTHERS THEN
     g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While deriving the participant code for journal header_id and line num '||p_je_header_id||'-'||p_je_line_num||SQLERRM;
      FND_FILE.PUT_LINE(FND_FILE.LOG, g_errbuf);
      return NULL;
END get_participant_code;

PROCEDURE register_0000 AS
  l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0000';
  l_cnpj                    xle_registrations.registration_number%TYPE;
  l_state                   hr_locations.region_2%TYPE;
  l_state_inscription       xle_registrations.registration_number%TYPE;
  l_municipal_inscription    xle_registrations.registration_number%TYPE;
  l_ibge_city_code          xle_entity_profiles.le_information4%TYPE;

BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
	                  	G_PKG_NAME||': ' ||l_api_name||'()+');
      END IF;

    IF l_estb_acts_as_company='N' THEN  -- If LE acts as company

       BEGIN

	   SELECT  loc.region_2, le.le_information4       --retrieve state and ibge_city_code
	     INTO  l_state,l_ibge_city_code
	     FROM  xle_entity_profiles le,
	           xle_registrations reg,
                   hr_locations loc
            WHERE  le.legal_entity_id = g_legal_entity_id
              AND  reg.source_id      = le.legal_entity_id
              AND  reg.source_table   = 'XLE_ENTITY_PROFILES'
              AND  reg.identifying_flag = 'Y'
              AND  reg.location_id      = loc.location_id
	      AND  le.transacting_entity_flag = 'Y'
	      AND  rownum=1;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving state and ibge city code');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state and ibge city code');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;

       BEGIN       -- retrieving cnpj

	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789')
	     INTO  l_cnpj
	     FROM  xle_registrations reg,
		   xle_jurisdictions_vl jur
            WHERE  reg.source_id       =  g_legal_entity_id
              AND  reg.source_table    = 'XLE_ENTITY_PROFILES'
              AND  reg.jurisdiction_id = jur.jurisdiction_id
              AND  jur.registration_code_le   = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving cnpj');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving cnpj');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;


      IF  g_inscription_source ='XLE' THEN
	   BEGIN  --Retrieving state inscription
               SELECT  registration_number
                 INTO  l_state_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_legal_entity_id
                  AND  reg.source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_le = g_le_state_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
	   BEGIN   -- --Retrieving municipal inscription
               SELECT  registration_number
                 INTO  l_municipal_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_legal_entity_id
                  AND  reg.source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_le = g_le_municipal_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum =1;
           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving municipal inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
      ELSE   -- g_inscription_source ='EBTax'(ZX)

           BEGIN   -- retreive state inscription

              SELECT  reg.registration_number
                INTO  l_state_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  main_establishment_flag  = 'Y'      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             =  ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_state_reg_code
                 AND  reg.tax             = g_state_insc_tax
                 AND  reg.tax_regime_code = g_state_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving State inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

           BEGIN   -- retreive municipal inscription

              SELECT  reg.registration_number
                INTO  l_municipal_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  main_establishment_flag  = 'Y'      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             =  ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_municipal_reg_code
                 AND  reg.tax             = g_municipal_insc_tax
                 AND  reg.tax_regime_code = g_municipal_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving municipal inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

      END IF;   -- END for p_insciption_source='LE'


    ELSE -- Establishment acts as company

       BEGIN
               --retrieving state,ibge_city_code
	   SELECT  loc.region_2, etb.etb_information4
	     INTO  l_state,l_ibge_city_code
	     FROM  xle_etb_profiles etb,
	           xle_registrations reg,
                   hr_locations loc
            WHERE  etb.legal_entity_id  = g_legal_entity_id
              AND  etb.establishment_id = g_establishment_id
              AND  reg.source_id        = etb.establishment_id
              AND  reg.source_table     = 'XLE_ETB_PROFILES'
              AND  reg.identifying_flag = 'Y'
              AND  reg.location_id      = loc.location_id
	      AND  rownum=1;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving state and ibge_city_code');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state and ibge_city_code');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;


       BEGIN
               --retrieving cnpj
	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789')
	     INTO  l_cnpj
	     FROM  xle_registrations reg,
                   xle_jurisdictions_vl jur
            WHERE  reg.source_id        = g_establishment_id
              AND  reg.source_table     = 'XLE_ETB_PROFILES'
              AND  reg.jurisdiction_id  = jur.jurisdiction_id
              AND  jur.registration_code_etb = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving cnpj');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving cnpj');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;



            --Retrieving state inscription
       IF  g_inscription_source ='XLE' THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_state_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_establishment_id
                  AND  reg.source_table = 'XLE_ETB_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_etb = g_le_state_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
	   BEGIN  --Retrieving municipal inscription
               SELECT  registration_number
                 INTO  l_municipal_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_establishment_id
                  AND  reg.source_table = 'XLE_ETB_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_etb = g_le_municipal_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum=1;
           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving municipal inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
      ELSE   -- g_inscription_source ='EBTax' ('ZX')

            BEGIN   -- retreive state inscription

              SELECT  reg.registration_number
                INTO  l_state_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  etb.establishment_id     = g_establishment_id
                 AND  etb.party_id             = ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_state_reg_code
                 AND  reg.tax             = g_state_insc_tax
                 AND  reg.tax_regime_code = g_state_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving State inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

           BEGIN   -- retreive municipal inscription

              SELECT  reg.registration_number
                INTO  l_municipal_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  etb.establishment_id     = g_establishment_id
                 AND  etb.party_id             = ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_municipal_reg_code
                 AND  reg.tax             = g_municipal_insc_tax
                 AND  reg.tax_regime_code = g_municipal_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving Municipal inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

      END IF;   -- END for p_insciption_source='XLE'


    END IF;  -- End for If l_estb_acts_as_company='N'

    --insert company info into 0000 register.
    BEGIN

    INSERT INTO jl_br_sped_extr_data_t
    (request_id,
     block,
     record_seq,
     field1,
     separator1,
     field2,
     separator2,
     field3,
     separator3,
     field4,
     separator4,
     field5,
     separator5,
     field6,
     separator6,
     field7,
     separator7,
     field8,
     separator8,
     field9,
     separator9,
     field10,
     separator10,
     field11,
     separator11,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login)
     VALUES (g_concurrent_request_id
	     ,'0'  -- Block
             ,jl_br_sped_extr_data_t_s.nextval --record_seq
             ,'0000' -- Register (field 1)
             ,'|'
	     ,'LECD' -- Fixed Text (field 2)
             ,'|'
	     ,to_char(g_start_date,'ddmmyyyy') --(field 3)
             ,'|'
             ,to_char(g_end_date,'ddmmyyyy') --(field 4)
             ,'|'
	     ,g_company_name --field 5
             ,'|'
	     ,l_cnpj --field 6
             ,'|'
             ,SUBSTRB(l_state,1,2)
             ,'|'
             ,l_state_inscription
             ,'|'
             ,SUBSTRB(l_ibge_city_code,1,7)
	     ,'|'
	     ,l_municipal_inscription
             ,'|'
	     ,g_special_situation_indicator
             ,'|'
             ,g_created_by
             ,g_creation_date
             ,g_last_updated_by
             ,g_last_update_date
             ,g_last_update_login);
     EXCEPTION
         WHEN OTHERS THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Inserting data into 0000 register');
           FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
           g_errbuf := 'ERROR While inserting 0000 register '||SQLERRM;
           g_retcode := 2;
           return;
     END;
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                  	G_PKG_NAME||': ' ||l_api_name||'()-');
      END IF;
     EXCEPTION
         WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Exception in 0000 register'||SQLERRM);
           END IF;


END register_0000;

PROCEDURE register_0001 AS
  l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0001';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES(  g_concurrent_request_id,
              '0',     --block
	            jl_br_sped_extr_data_t_s.nextval, --record_seq
	            '0001',  --Register (field1)
              '|',
	             0,-- null,--decode(count(*),0,1,0), --field2
              '|'
              ,g_created_by
              ,g_creation_date
              ,g_last_updated_by
              ,g_last_update_date
              ,g_last_update_login );

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'error in 0001'||sqlcode||sqlerrm);
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting 0001 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_0001;

PROCEDURE register_0007 AS
   l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0007';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
  END IF;

  IF l_estb_acts_as_company = 'N' THEN   --LE acts as company

      INSERT INTO jl_br_sped_extr_data_t
      (request_id,
       block,
       record_seq,
       field1,
       separator1,
       field2,
       separator2,
       field3,
       separator3,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
       )
       SELECT  g_concurrent_request_id
               ,'0'  -- Block
	       ,jl_br_sped_extr_data_t_s.nextval --record_seq
	       ,'0007' -- Register (field 1)
               ,'|'
	       ,reg.reg_information1 --field 2
               ,'|'
               ,decode(reg.reg_information1,'00',null,reg.registration_number) --field 3
               ,'|'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login
         FROM  xle_registrations reg
        WHERE  reg.source_id    =  g_legal_entity_id
	  AND  reg.source_table =  'XLE_ENTITY_PROFILES'
          AND  reg.reg_information1 IS NOT NULL
          AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY')) <= g_start_date   --effective_from column can be null in xle_registrations table.
          AND  (nvl(effective_to,sysdate) >= g_end_date OR effective_to IS NULL);                      -- Registration should be there for entire period.

    ELSE    --Establishment acts as company

      INSERT INTO jl_br_sped_extr_data_t
      (request_id,
       block,
       record_seq,
       field1,
       separator1,
       field2,
       separator2,
       field3,
       separator3,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
       )
       SELECT  g_concurrent_request_id
               ,'0'  -- Block
	       ,jl_br_sped_extr_data_t_s.nextval --record_seq
	       ,'0007' -- Register (field 1)
               ,'|'
	       ,reg.reg_information1 --field 2
               ,'|'
               ,decode(reg.reg_information1,'00',null,reg.registration_number) --field 3
               ,'|'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login
         FROM  xle_registrations reg
        WHERE  reg.source_id    =  g_establishment_id
	  AND  reg.source_table =  'XLE_ETB_PROFILES'
          AND  reg.reg_information1 IS NOT NULL
          AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY')) <= g_start_date   --effective_from column can be null in xle_registrations table.
          AND  (nvl(effective_to,sysdate) >= g_end_date OR effective_to IS NULL);                      -- Registration should be there for entire period.

   END IF;   -- End for IF l_estb_acts_as_company='N'

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting 0007 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_0007;

PROCEDURE register_0020 AS
  l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0020';
  l_main_estb_flag          VARCHAR2(1);
  l_cnpj                    xle_registrations.registration_number%TYPE;
  l_state                   hr_locations.region_2%TYPE;
  l_state_inscription       xle_registrations.registration_number%TYPE;
  l_municipal_inscription    xle_registrations.registration_number%TYPE;
  l_ibge_city_code          xle_entity_profiles.le_information4%TYPE;
  l_nire                    NUMBER(20);   --check the data type
  l_establishment_id        xle_etb_profiles.establishment_id%TYPE;
  l_count                   NUMBER := 0;
  CURSOR  secondary_estbs_cur IS SELECT  establishment_id
                                   FROM  xle_etb_profiles
                                  WHERE  legal_entity_id = g_legal_entity_id
                                    AND  main_establishment_flag='N' ;
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
	                   G_PKG_NAME||': ' ||l_api_name||'()+');
   END IF;


   IF UPPER(g_accounting_type) = 'CENTRALIZED' THEN
      RETURN;
   END IF;

   SELECT  NVL(main_establishment_flag,'N')
     INTO  l_main_estb_flag
     FROM  xle_etb_profiles
    WHERE  legal_entity_id = g_legal_entity_id
      AND  establishment_id = g_establishment_id;

   IF l_main_estb_flag = 'N'  THEN    -- running the report for secondary establishment. need to display LE info in 0020 register.

       BEGIN

	   SELECT  loc.region_2, le.le_information4
	     INTO  l_state,l_ibge_city_code
	     FROM  xle_entity_profiles le,
	           xle_registrations reg,
                   hr_locations loc
            WHERE  le.legal_entity_id = g_legal_entity_id
              AND  reg.source_id      = le.legal_entity_id
              AND  reg.source_table   = 'XLE_ENTITY_PROFILES'
              AND  reg.identifying_flag = 'Y'
              AND  reg.location_id      = loc.location_id
	      AND  le.transacting_entity_flag = 'Y'
	      AND  rownum = 1 ;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving state and ibge_city_code');
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state and ibge_city_code');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;

       BEGIN       -- retrieving cnpj

	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789')
	     INTO  l_cnpj
	     FROM  xle_registrations reg,
		   xle_jurisdictions_vl jur
            WHERE  reg.source_id       = g_legal_entity_id
              AND  reg.source_table    = 'XLE_ENTITY_PROFILES'
              AND  reg.jurisdiction_id = jur.jurisdiction_id
              AND  jur.registration_code_le   = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while Retrieving cnpj of LE');
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving cnpj');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;

       --Begin for retrieving NIRE.
      /* If any registration number exists with place of registration as 'NIRE' then, we need to retrieve it as 'NIRE'.
         otherwise, we need to retrieve the registration number with legislative category as 'COMMERCIAL_LAW'. */

       SELECT  count(*)
         INTO  l_count
         FROM  xle_registrations
        WHERE  source_id    = g_legal_entity_id
          AND  source_table = 'XLE_ENTITY_PROFILES'
          AND  UPPER(place_of_registration) = 'NIRE'
          AND  nvl(effective_from ,to_date('01-01-1950','DD-MM-YYYY')) <= g_start_date
          AND  (effective_to IS NULL OR effective_to >= g_end_date);

       IF l_count > 0 THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations
                WHERE  source_id    = g_legal_entity_id
                  AND  source_table = 'XLE_ENTITY_PROFILES'
                  AND  UPPER(place_of_registration) = 'NIRE'
                  AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (effective_to IS NULL OR effective_to >= g_end_date)
		  AND  rownum =1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using place of registration');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
       ELSE

	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations reg,
		       xle_jurisdictions_vl jur
                WHERE  source_id    = g_legal_entity_id
                  AND  source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.legislative_cat_code = 'COMMERCIAL_LAW'
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
		  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using Commercial Law');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;

       END IF;
       --End of retrieving NIRE

            --Retrieving state inscription
      IF  g_inscription_source ='XLE' THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_state_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_legal_entity_id
                  AND  reg.source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_le = g_le_state_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY')) <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
	   BEGIN   -- --Retrieving municipal inscription
               SELECT  registration_number
                 INTO  l_municipal_inscription
                 FROM  xle_registrations reg,
                       xle_jurisdictions_vl jur
                WHERE  reg.source_id = g_legal_entity_id
                  AND  reg.source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.registration_code_le = g_le_municipal_reg_code
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                  AND  rownum =1;
           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving municipal inscription');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
      ELSE   -- g_inscription_source ='EBTax'('ZX')

           BEGIN   -- retreive state inscription

              SELECT  reg.registration_number
                INTO  l_state_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  main_establishment_flag  = 'Y'      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             =  ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_state_reg_code
                 AND  reg.tax             = g_state_insc_tax
                 AND  reg.tax_regime_code = g_state_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving State inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

           BEGIN   -- retreive municipal inscription

              SELECT  reg.registration_number
                INTO  l_municipal_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  main_establishment_flag  = 'Y'      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             =  ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_municipal_reg_code
                 AND  reg.tax             = g_municipal_insc_tax
                 AND  reg.tax_regime_code = g_municipal_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving municipal inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

	END IF;   -- END for p_insciption_source='XLE'

      BEGIN

	  INSERT INTO jl_br_sped_extr_data_t
	  (request_id,
	   block,
	   record_seq,
	   field1,
           separator1,
	   field2,
           separator2,
	   field3,
           separator3,
           field4,
           separator4,
	   field5,
           separator5,
	   field6,
           separator6,
	   field7,
           separator7,
	   field8,
           separator8,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
           VALUES(g_concurrent_request_id
	          ,'0'  -- Block
	          ,jl_br_sped_extr_data_t_s.nextval --record_seq
	          ,'0020' -- Register (field 1)
                  ,'|'
	          ,1 --LE
                  ,'|'
	          ,l_cnpj --field 3
                  ,'|'
                  ,SUBSTRB(l_state,1,2) --field 4
                  ,'|'
                  ,l_state_inscription -- field 5
                  ,'|'
                  ,SUBSTRB(l_ibge_city_code,1,7)      --field6
                  ,'|'
 	          ,l_municipal_inscription  -- field 7
                  ,'|'
                  ,SUBSTRB(l_nire,11)  --field 8
                  ,'|'
                  ,g_created_by
                  ,g_creation_date
                  ,g_last_updated_by
                  ,g_last_update_date
                  ,g_last_update_login);
      EXCEPTION
	 WHEN OTHERS THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Inserting data into 0020 register');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
		g_errbuf := 'ERROR While inserting 0020 register '||SQLERRM;
                g_retcode := 2;
                return;
      END;

   ELSE  -- running the report for primary establishment.Need to display all secondary establishment's info in 0020 register.

       FOR secondary_estb_rec in secondary_estbs_cur LOOP
           l_establishment_id     := secondary_estb_rec.establishment_id ;
           l_state                := null;
           l_ibge_city_code       := null;
           l_state_inscription    := null;
           l_municipal_inscription := null;
	   l_cnpj                 := null;
	   l_nire                 := null;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Establishment_id : '||l_establishment_id);
	  END IF;

	   BEGIN
                 --retrieving cnpj,state,ibge_city_code
               SELECT  loc.region_2, etb.etb_information4
	         INTO  l_state,l_ibge_city_code
                 FROM  xle_etb_profiles etb,
	               xle_registrations reg,
                       hr_locations loc
                WHERE  etb.legal_entity_id  = g_legal_entity_id
                  AND  etb.establishment_id = l_establishment_id
                  AND  reg.source_id        = etb.establishment_id
                  AND  reg.source_table   = 'XLE_ETB_PROFILES'
                  AND  reg.identifying_flag = 'Y'
                  AND  reg.location_id      = loc.location_id
		  AND  rownum = 1;

           EXCEPTION
           WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving state and ibge_city_code');
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state,ibge_city_code of ESTB');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
            END;

       --Begin for retrieving NIRE.
      /* If any registration number exists with place of registration as 'NIRE' then, we need to retrieve it as 'NIRE'.
         otherwise, we need to retrieve the registration number with legislative category as 'COMMERCIAL_LAW'. */

       SELECT  count(*)
         INTO  l_count
         FROM  xle_registrations
        WHERE  source_id    = l_establishment_id
          AND  source_table = 'XLE_ETB_PROFILES'
          AND  UPPER(place_of_registration) = 'NIRE'
          AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
          AND  (effective_to IS NULL OR effective_to >= g_end_date);

       IF l_count > 0 THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations
                WHERE  source_id    = l_establishment_id
                  AND  source_table = 'XLE_ETB_PROFILES'
                  AND  UPPER(place_of_registration) = 'NIRE'
                  AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (effective_to IS NULL OR effective_to >= g_end_date)
		  AND  rownum = 1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using place of registration');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
       ELSE

	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations reg,
		       xle_jurisdictions_vl jur
                WHERE  source_id    = l_establishment_id
                  AND  source_table = 'XLE_ETB_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.legislative_cat_code = 'COMMERCIAL_LAW'
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
		  AND  rownum = 1;

           EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using Commercial Law');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;

       END IF;
       --End of retrieving NIRE

       BEGIN
               --retrieving cnpj
	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789')
	     INTO  l_cnpj
	     FROM  xle_registrations reg,
                   xle_jurisdictions_vl jur
            WHERE  reg.source_id        = l_establishment_id
              AND  reg.source_table     = 'XLE_ETB_PROFILES'
              AND  reg.jurisdiction_id  = jur.jurisdiction_id
              AND  jur.registration_code_etb = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while Retrieving cnpj of ESTB');
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error while Retrieving cnpj of ESTB');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;


            --Retrieving state inscription

	   IF  g_inscription_source ='XLE' THEN
	     BEGIN
                SELECT  registration_number
                  INTO  l_state_inscription
                  FROM  xle_registrations reg,
                        xle_jurisdictions_vl jur
                 WHERE  reg.source_id = l_establishment_id
                   AND  reg.source_table = 'XLE_ETB_PROFILES'
                   AND  reg.jurisdiction_id = jur.jurisdiction_id
                   AND  jur.registration_code_etb = g_le_state_reg_code
                   AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                   AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                   AND  rownum=1;

              EXCEPTION
                WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving state inscription of ESTB from XLE');
		      FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                  END IF;
              END;
	     BEGIN  --Retrieving municipal inscription
                SELECT  registration_number
                  INTO  l_municipal_inscription
                  FROM  xle_registrations reg,
                        xle_jurisdictions_vl jur
                 WHERE  reg.source_id = l_establishment_id
                   AND  reg.source_table = 'XLE_ETB_PROFILES'
                   AND  reg.jurisdiction_id = jur.jurisdiction_id
                   AND  jur.registration_code_etb = g_le_municipal_reg_code
                   AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                   AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
                   AND  rownum=1;
             EXCEPTION
               WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving municipal inscription of ESTB from XLE');
  		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                  END IF;
             END;
          ELSE   -- g_inscription_source ='EBTax'('ZX')

           BEGIN   -- retreive state inscription

              SELECT  reg.registration_number
                INTO  l_state_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  etb.establishment_id     = l_establishment_id      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             =  ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_state_reg_code
                 AND  reg.tax             = g_state_insc_tax
                 AND  reg.tax_regime_code = g_state_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving State inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

           BEGIN   -- retreive municipal inscription

              SELECT  reg.registration_number
                INTO  l_municipal_inscription
                FROM  zx_registrations reg,
                      xle_etb_profiles etb,
                      zx_party_tax_profile ptp
               WHERE  etb.legal_entity_id      = g_legal_entity_id
                 AND  etb.establishment_id     = l_establishment_id      -- will fetch the registration number of main establishment for LE in case of EBtax.
                 AND  etb.party_id             = ptp.party_id
                 AND  ptp.party_tax_profile_id = reg.party_tax_profile_id
                 AND  ptp.party_type_code      = 'LEGAL_ESTABLISHMENT'
                 AND  reg.registration_type_code = g_ebtax_municipal_reg_code
                 AND  reg.tax             = g_municipal_insc_tax
                 AND  reg.tax_regime_code = g_municipal_insc_tax_regime
                 AND  rownum =1;
            EXCEPTION
               WHEN OTHERS THEN
       	           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error in retreiving municipal inscription for EBTax');
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
	    END;

          END IF;   -- END for p_insciption_source='XLE'

          BEGIN

	      INSERT INTO jl_br_sped_extr_data_t
	      (request_id,
	       block,
               record_seq,
	       field1,
               separator1,
	       field2,
               separator2,
               field3,
               separator3,
               field4,
               separator4,
               field5,
               separator5,
               field6,
               separator6,
	       field7,
               separator7,
               field8,
               separator8,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
              )
              VALUES(g_concurrent_request_id
	             ,'0'  -- Block
	             ,jl_br_sped_extr_data_t_s.nextval --record_seq
	             ,'0020' -- Register (field 1)
                     ,'|'
	             ,0  --Establishment
                     ,'|'
                     ,l_cnpj --field 3
                     ,'|'
                     ,SUBSTRB(l_state,1,2) --field 4
                     ,'|'
                     ,l_state_inscription -- field 5
                     ,'|'
                     ,SUBSTRB(l_ibge_city_code,1,7)      --field6
                     ,'|'
 	             ,l_municipal_inscription  -- field 7
                     ,'|'
                     ,SUBSTRB(l_nire,1,11)  --field 8
                     ,'|'
                     ,g_created_by
                     ,g_creation_date
                     ,g_last_updated_by
                     ,g_last_update_date
                     ,g_last_update_login);
            EXCEPTION
	       WHEN OTHERS THEN
		   FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Inserting data into 0020 register-establishments');
		   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                   IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                   END IF;
                   g_errbuf := 'ERROR While inserting 0020 register '||SQLERRM;
                   g_retcode := 2;
                   return;
           END;
       END LOOP;

   END IF; -- End for l_main_estb_flag = 'N'


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

END register_0020;

PROCEDURE register_0150_0180 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0150_0180';
l_count NUMBER;
	CURSOR c_participants IS
	SELECT  p.participant_code
	       ,participant_name
	       ,lpad(lc.meaning,5,'0') cbank_country_code
         ,decode(p.register_type,'2',decode(length(p.register_number),9,substrb(p.register_number,2,8)||p.register_subsidiary||p.register_digit,
                                                      	              p.register_number||p.register_subsidiary||p.register_digit),null) cnpj
	       ,decode(p.register_type,'1',p.register_number||p.register_digit,null) cpf
	       ,p.nit
	       ,p.state_code
	       ,p.state_inscription
	       ,p.state_inscription_substitute
	       ,p.ibge_city_code
	       ,p.municipal_inscription
	       ,p.suframa_inscription_number
	  FROM jl_br_sped_partic_codes p
         ,fnd_lookups lc
   WHERE ledger_id  = g_ledger_id
     AND lc.lookup_type ='JLBR_CBANK_COUNTRY_CODES'
     AND lc.lookup_code = p.country_code
     AND p.enabled_flag = 'Y'
     AND ((g_participant_type in ('SUPPLIERS','CUSTOMERS','SUPPLIER_SITES','CUSTOMER_SITES') AND participant_type = g_participant_type) OR
          (g_participant_type = 'ACCOUNTING_FLEXFIELD_SEGMENT' AND p.segment_type = g_accounting_segment_type) OR
          (g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' AND participant_type = 'SUPPLIERS') OR
          (g_participant_type = 'SUPPLIERS_AND_CUSTOMERS' AND participant_type = 'CUSTOMERS') OR
          (g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' AND participant_type = 'SUPPLIER_SITES') OR
          (g_participant_type = 'SUPPLIER_AND_CUSTOMER_SITES' AND participant_type = 'CUSTOMER_SITES') )
     AND exists (select 1 from jl_br_sped_partic_rel rel
	                 where rel.participant_code = p.participant_code
			   and rel.legal_entity_id  = g_legal_entity_id
			   and ((g_accounting_type='CENTRALIZED' AND ((l_estb_acts_as_company = 'Y' AND establishment_id = g_establishment_id)
			                                              OR (l_estb_acts_as_company ='N' AND establishment_id is null)))
                                 OR
                                (g_accounting_type='DECENTRALIZED' AND (establishment_id is null OR
                                                                        establishment_id=g_establishment_id)))
	                   and rel.effective_from <= g_end_date
	                   and nvl(rel.effective_to,sysdate) >= g_start_date);

BEGIN

 IF g_bookkeeping_type <> 'B' THEN   -- 0150 and 0180 are not required for book keeping type 'B'

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                      G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

 	For partic_record in c_participants LOOP

	     INSERT INTO jl_br_sped_extr_data_t
	     (request_id,
        block,
        record_seq,
        field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        field7,
        separator7,
        field8,
        separator8,
        field9,
        separator9,
        field10,
        separator10,
        field11,
        separator11,
        field12,
        separator12,
	field13,
	separator13,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
	      values (g_concurrent_request_id
	              ,'0'  -- Block
                ,jl_br_sped_extr_data_t_s.nextval -- Record_seq
                ,'0150' -- Register (field 1)
                ,'|'
                , partic_record.participant_code       --field 2
                ,'|'
                , partic_record.participant_name           --field 3
                ,'|'
                , partic_record.cbank_country_code     --field 4
                ,'|'
                , partic_record.cnpj                   --field 5
                ,'|'
                , partic_record.cpf                     --field 6
                ,'|'
                , partic_record.nit                     --field 7
                ,'|'
                , partic_record.state_code              --field 8
                ,'|'
                , partic_record.state_inscription      --field 9
                ,'|'
		, partic_record.state_inscription_substitute  --field10
		, '|'
                , partic_record.ibge_city_code         --field 11
                ,'|'
                , partic_record.municipal_inscription  --field 12
                ,'|'
                ,partic_record.suframa_inscription_number --field 13
                ,'|'
                ,g_created_by
                ,g_creation_date
                ,g_last_updated_by
                ,g_last_update_date
                ,g_last_update_login  );


      INSERT INTO jl_br_sped_extr_data_t
	    (request_id,
       block,
       record_seq,
       field1,
       separator1,
       field2,
       separator2,
       field3,
       separator3,
       field4,
       separator4,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login)
	     SELECT g_concurrent_request_id
	            ,'0'  -- Block
              ,jl_br_sped_extr_data_t_s.nextval -- Record_seq
              ,'0180' -- Register (field 1)
              ,'|'
              ,relationship_code  --field 2
              ,'|'
              ,to_char(effective_from,'ddmmyyyy')--field 3
              ,'|'
              ,to_char(effective_to,'ddmmyyyy')  --field 4
              ,'|'
              ,g_created_by
              ,g_creation_date
              ,g_last_updated_by
              ,g_last_update_date
              ,g_last_update_login
         FROM jl_br_sped_partic_rel
	      WHERE participant_code = partic_record.participant_code
	        AND legal_entity_id = g_legal_entity_id
		AND ((l_estb_acts_as_company = 'Y' AND establishment_id = g_establishment_id)
		      OR (l_estb_acts_as_company = 'N' AND establishment_id is null))
	        AND effective_from <= g_end_date
	        AND nvl(effective_to,sysdate) >= g_start_date ;

	 END LOOP;

   SELECT COUNT(*) INTO l_count
   FROM jl_br_sped_extr_data_t
   WHERE request_id =g_concurrent_request_id
   AND block  = '0'
   AND field1 = '0150';

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): 0150 Records Inserted : '||l_count);

   SELECT COUNT(*) INTO l_count
   FROM jl_br_sped_extr_data_t
   WHERE request_id =g_concurrent_request_id
   AND block  = '0'
   AND field1 = '0180';
 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): 0180 Records Inserted : '||l_count);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

  END IF; -- End for IF g_bookkeeping_type <> 'B'

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting 0150 and 0180 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_0150_0180;

PROCEDURE register_0990 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_0990';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;
    INSERT INTO jl_br_sped_extr_data_t
    (request_id,
    block,
    record_seq,
    field1,
    separator1,
    field2,
    separator2,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )
    VALUES(  g_concurrent_request_id
            ,'0'  -- Block
	          ,jl_br_sped_extr_data_t_s.nextval -- Record_seq
	          ,'0990'  -- Register (field 1)
            ,'|'
	          ,0--,null  --count(*) -- Field 2
            ,'|'
            ,g_created_by
            ,g_creation_date
            ,g_last_updated_by
            ,g_last_update_date
            ,g_last_update_login  );

--  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
	END IF;
EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting 0990 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_0990;

PROCEDURE register_I001 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I001';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   INSERT INTO jl_br_sped_extr_data_t
   (request_id,
    block,
    record_seq,
    field1,
    separator1,
    field2,
    separator2,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login)
    VALUES( g_concurrent_request_id,
            'I',     --block
	    jl_br_sped_extr_data_t_s.nextval,  --Record_seq
	    'I001',  --Register (field1)
            '|',
	    0,--null,--decode(count(*),0,1,0), --field2
            '|'
            ,g_created_by
            ,g_creation_date
            ,g_last_updated_by
            ,g_last_update_date
            ,g_last_update_login );

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
	END IF;
EXCEPTION
   WHEN OTHERS THEN
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting I0001 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_I001;

PROCEDURE register_I010 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I010';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'G_BOOKKEEPING_TYPE: ' ||g_bookkeeping_type);

	 INSERT INTO jl_br_sped_extr_data_t
	 (request_id,
	  block,
	  record_seq,
	  field1,
          separator1,
	  field2,
          separator2,
          field3,
          separator3,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
         VALUES
 	  ( g_concurrent_request_id
	    ,'I'  -- Block
	    ,jl_br_sped_extr_data_t_s.nextval -- Record_seq
	    ,'I010' -- Register (field 1)
            ,'|'
	    ,substr(g_bookkeeping_type,1,1) -- field 2
            ,'|'
	    ,'1.00'      --field3
            ,'|'
            ,g_created_by
            ,g_creation_date
            ,g_last_updated_by
            ,g_last_update_date
            ,g_last_update_login
	   );
 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
	END IF;
EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting I010 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I010;

/* This register contains Book information. This procedure won't be called for book keeping type 'G'*/
PROCEDURE register_I012 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I012';

BEGIN

  IF g_bookkeeping_type <> 'G' THEN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

	 INSERT INTO jl_br_sped_extr_data_t
	 (request_id,
	  block,
	  record_seq,
	  field1,
          separator1,
	  field2,
          separator2,
          field3,
          separator3,
          field4,
          separator4,
          field5,
          separator5,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
  	SELECT
	    g_concurrent_request_id
	    ,'I'  -- Block
	    ,jl_br_sped_extr_data_t_s.nextval -- Record_seq
	    ,'I012' -- Register (field 1)
            ,'|'
	    ,book_number   -- field 2
            ,'|'
	    ,book_name      --field3
            ,'|'
            ,0              --field4
            ,'|'
            ,DECODE(g_bookkeeping_type,'R',g_hash_code,'B',g_hash_code,NULL)
            ,'|'
            ,g_created_by
            ,g_creation_date
            ,g_last_updated_by
            ,g_last_update_date
            ,g_last_update_login
       FROM  jl_br_cinfos_books
      WHERE  legal_entity_id = g_legal_entity_id
        AND  ((l_estb_acts_as_company ='N' AND establishment_id is null)
              OR (l_estb_acts_as_company = 'Y' AND establishment_id=g_establishment_id))  --establishment acts as company
        AND  bookkeeping_type = DECODE(g_bookkeeping_type,'R','A','B','A'
                                                      ,'A/R','R','A/B','B')
        AND  ((bookkeeping_type = 'A' AND auxiliary_book_flag = 'Y')
              OR bookkeeping_type <> 'A');

   /*  If we are running the report for book keeping type is 'R' or 'B' then we will
        display the auxiliary books for book keeping type 'A'.
        If we run with book keeping type 'A/R' then display book of 'R'
        If we run with book keeping type 'A/B' then display book of 'B'*/

   -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
	  END IF;
  END IF;  -- End for IF g_bookkeeping_type <> 'G'
EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting I012 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I012;

PROCEDURE register_I015 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I015';
l_query                   VARCHAR2(6000);

BEGIN

 IF g_bookkeeping_type = 'G' THEN
  return;
 END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

l_query   := 'INSERT INTO jl_br_sped_extr_data_t
              (request_id,
               block,
               record_seq,
               field1,
               separator1,
               field2,
               separator2,
               created_by,
	       creation_date,
	       last_updated_by,
               last_update_date,
               last_update_login
              )
              SELECT '||g_concurrent_request_id|| '
                     ,''I''  -- Block
                     ,jl_br_sped_extr_data_t_s.nextval -- record_seq
		     ,''I015'' -- Register (field 1)
                     ,''|''
                     ,natural_acct
                     ,''|''
                     ,'||g_created_by||'
		     ,'''||g_creation_date||'''
                     ,'||g_last_updated_by||'
                     ,'''||g_last_update_date||'''
		     ,'||g_last_update_login||'
                FROM (SELECT  DISTINCT  glcc.'||g_account_segment||'  natural_acct
		      FROM  gl_je_headers jh
                            ,gl_je_lines jl
                            ,gl_import_references glimp
                            ,xla_ae_lines xll
                            ,xla_ae_headers xlh
                            ,xla_distribution_links xld
                            ,gl_code_combinations glcc
                     WHERE  jh.ledger_id = '||g_ledger_id||'
                       AND  jh.je_source in (''Payables'',''Receivables'')
                       AND  jh.je_header_id     = jl.je_header_id
                       AND  glimp.je_header_id  = jh.je_header_id
                       AND  xlh.ae_header_id    = xll.ae_header_id
                       AND  xlh.EVENT_ID        = xld.EVENT_ID
                       AND  xlh.application_id  = xll.application_id
		       AND  xll.ae_header_id    = xld.ae_header_id
		       AND  xll.ae_line_num     = xld.ae_line_num
		       AND  xll.application_id  = xld.application_id
                       AND  jl.je_line_num      = glimp.je_line_num
                       AND  glimp.gl_sl_link_id = xll.gl_sl_link_id
		       AND  glimp.gl_sl_link_table = xll.gl_sl_link_table
		       AND  jl.code_combination_id = glcc.code_combination_id
                       AND  jh.status      = ''P''
                       AND  jl.status      = ''P''
                       AND  jh.default_effective_date between '''||g_start_date||''' and '''|| g_end_date||'''
                       AND  ('''||l_exclusive_mode||'''=''Y''
		              OR ('''||l_exclusive_mode||'''=''N'' AND   glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))
                      GROUP BY  glimp.je_header_id,glimp.je_line_num,jl.code_combination_id,glcc.'||g_account_segment||'
                      HAVING  count(*) >1)';


 --  FND_FILE.PUT_LINE(FND_FILE.LOG,'query:'||l_query);

   EXECUTE IMMEDIATE l_query;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting I015 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I015;

PROCEDURE register_I030 AS
  l_api_name        CONSTANT VARCHAR2(30) :='REGISTER_I030';
  l_book_number     jl_br_cinfos_books.book_number%TYPE;
  l_book_name       jl_br_cinfos_books.book_name%TYPE;
  l_nire            NUMBER(11);
  l_cnpj            xle_registrations.registration_number%TYPE;
  l_registration_id xle_registrations.registration_id%TYPE;
  l_effective_from  DATE;
  l_conversion_date DATE;
  l_city            hr_locations.town_or_city%TYPE;
  l_count           NUMBER(4) :=0;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                    G_PKG_NAME||': ' ||l_api_name||'()+');
   END IF;

    IF l_estb_acts_as_company = 'N' THEN       --LE acts as company.

        BEGIN
                      --retreiving book info
	   SELECT  le.effective_from,bk.book_number,bk.book_name
             INTO  l_effective_from,l_book_number,l_book_name
             FROM  xle_entity_profiles le,
	           jl_br_cinfos_books bk
            WHERE  le.legal_entity_id = g_legal_entity_id
              AND  bk.legal_entity_id = le.legal_entity_id
              AND  bk.establishment_id IS NULL   -- need to retrive the book info of LE.
              AND  bookkeeping_type = substrb(g_bookkeeping_type,1,1)
              AND  bk.auxiliary_book_flag ='N';

        EXCEPTION
	   WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving the Book Information');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving the Book Information');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
        END;

       --Begin for retrieving NIRE.
      /* If any registration number exists with place of registration as 'NIRE' then, we need to retrieve it as 'NIRE'.
         otherwise, we need to retrieve the registration number with legislative category as 'COMMERCIAL_LAW'. */

       SELECT  count(*)
         INTO  l_count
         FROM  xle_registrations
        WHERE  source_id    = g_legal_entity_id
          AND  source_table = 'XLE_ENTITY_PROFILES'
          AND  UPPER(place_of_registration) = 'NIRE'
          AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
          AND  (effective_to IS NULL OR effective_to >= g_end_date);

       IF l_count > 0 THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations
                WHERE  source_id    = g_legal_entity_id
                  AND  source_table = 'XLE_ENTITY_PROFILES'
                  AND  UPPER(place_of_registration) = 'NIRE'
                  AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (effective_to IS NULL OR effective_to >= g_end_date)
		  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving nire using place of registration');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
		IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using place of registration');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
       ELSE

	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations reg,
		       xle_jurisdictions_vl jur
                WHERE  source_id    = g_legal_entity_id
                  AND  source_table = 'XLE_ENTITY_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.legislative_cat_code = 'COMMERCIAL_LAW'
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
		  AND  rownum=1;

           EXCEPTION
              WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving nire using Commercial Law');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
		IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving nire using Commercial Law');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;

       END IF;
       --End of retrieving NIRE

        BEGIN
                     --retriving city
            SELECT  loc.town_or_city
              INTO  l_city
              FROM  xle_registrations reg,hr_locations_all loc
             WHERE  reg.source_id = g_legal_entity_id
               AND  reg.source_table = 'XLE_ENTITY_PROFILES'
               AND  reg.identifying_flag = 'Y'
               AND  reg.location_id =loc.location_id
	       AND  rownum = 1 ;

	EXCEPTION
	  WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving CNPJ');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
        END;

       BEGIN       -- retrieving cnpj

	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789'),reg.registration_id
	     INTO  l_cnpj,l_registration_id
	     FROM  xle_registrations reg,
		   xle_jurisdictions_vl jur
            WHERE  reg.source_id       = g_legal_entity_id
              AND  reg.source_table    = 'XLE_ENTITY_PROFILES'
              AND  reg.jurisdiction_id = jur.jurisdiction_id
              AND  jur.registration_code_le   = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving cnpj');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;

       l_count :=0;

       SELECT  count(*)
         INTO  l_count
         FROM  xle_histories his
        WHERE  source_table = 'XLE_REGISTRATIONS'
          AND  source_id    = l_registration_id
          AND  source_column_name = 'EFFECTIVE_FROM';

      IF  l_count >= 1 THEN  --  registration Effective From field was changed. so entry exists in history table.

	  BEGIN
             SELECT  substr(source_column_value,1,11)
               INTO  l_conversion_date
               FROM  xle_histories his
              WHERE  source_table = 'XLE_REGISTRATIONS'
                AND  source_id    = l_registration_id
                AND  source_column_name = 'EFFECTIVE_FROM'
                AND  effective_to IS NULL;

          EXCEPTION
             WHEN OTHERS THEN
 	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving conversion Date');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving conversion Date');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
          END;

      END IF;  --End for IF l_count >=1

    ELSE          -- Establishment acts as company.

	BEGIN
                      --retreiving book info
	   SELECT  etb.effective_from,bk.book_number,bk.book_name
             INTO  l_effective_from,l_book_number,l_book_name
             FROM  xle_etb_profiles etb,
	           jl_br_cinfos_books bk
            WHERE  etb.legal_entity_id  = g_legal_entity_id
              AND  etb.establishment_id = g_establishment_id
              AND  bk.legal_entity_id   = etb.legal_entity_id
	      AND  bk.establishment_id  = etb.establishment_id   -- need to retrive the book info of ETB.
              AND  bookkeeping_type = substrb(g_bookkeeping_type,1,1)
              AND  bk.auxiliary_book_flag ='N';

        EXCEPTION
	   WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving the Book Information');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
        END;

       --Begin for retrieving NIRE.
      /* If any registration number exists with place of registration as 'NIRE' then, we need to retrieve it as 'NIRE'.
         otherwise, we need to retrieve the registration number with legislative category as 'COMMERCIAL_LAW'. */

       SELECT  count(*)
         INTO  l_count
         FROM  xle_registrations
        WHERE  source_id    = g_establishment_id
          AND  source_table = 'XLE_ETB_PROFILES'
          AND  UPPER(place_of_registration) = 'NIRE'
          AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
          AND  (effective_to IS NULL OR effective_to >= g_end_date)	  ;

       IF l_count > 0 THEN
	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations
                WHERE  source_id    = g_establishment_id
                  AND  source_table = 'XLE_ETB_PROFILES'
                  AND  UPPER(place_of_registration) = 'NIRE'
                  AND  nvl(effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (effective_to IS NULL OR effective_to >= g_end_date)
		  AND  rownum = 1;

           EXCEPTION
              WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving nire using place of registration');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;
       ELSE

	   BEGIN
               SELECT  registration_number
                 INTO  l_nire
                 FROM  xle_registrations reg,
		       xle_jurisdictions_vl jur
                WHERE  source_id    = g_establishment_id
                  AND  source_table = 'XLE_ETB_PROFILES'
                  AND  reg.jurisdiction_id = jur.jurisdiction_id
                  AND  jur.legislative_cat_code = 'COMMERCIAL_LAW'
                  AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
                  AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
		  AND  rownum = 1;

           EXCEPTION
              WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving nire using Commercial Law');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
           END;

       END IF;
       --End of retrieving NIRE

        BEGIN
                     --retriving city
            SELECT  loc.town_or_city
              INTO  l_city
              FROM  xle_registrations reg,hr_locations_all loc
             WHERE  reg.source_id = g_establishment_id
               AND  reg.source_table = 'XLE_ETB_PROFILES'
               AND  reg.identifying_flag = 'Y'
               AND  reg.location_id =loc.location_id
	       AND  rownum = 1 ;

	EXCEPTION
	  WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving CNPJ');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
        END;
       BEGIN       -- retrieving cnpj

	   SELECT  translate(reg.registration_number,'0123456789/-.', '0123456789'),reg.registration_id
	     INTO  l_cnpj,l_registration_id
	     FROM  xle_registrations reg,
		   xle_jurisdictions_vl jur
            WHERE  reg.source_id       = g_establishment_id
              AND  reg.source_table    = 'XLE_ETB_PROFILES'
              AND  reg.jurisdiction_id = jur.jurisdiction_id
              AND  jur.registration_code_le   = 'CNPJ'
              AND  nvl(reg.effective_from,to_date('01-01-1950','DD-MM-YYYY'))  <= g_start_date
              AND  (reg.effective_to IS NULL OR reg.effective_to >= g_end_date)
	      AND  rownum=1;

           SELECT decode(length(l_cnpj),15,substr(l_cnpj,2,14),l_cnpj) into l_cnpj from dual;

       EXCEPTION
         WHEN OTHERS THEN
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving cnpj');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
       END;

       l_count :=0;

       SELECT  count(*)
         INTO  l_count
         FROM  xle_histories his
        WHERE  source_table = 'XLE_REGISTRATIONS'
          AND  source_id    = l_registration_id
          AND  source_column_name = 'EFFECTIVE_FROM';

      IF  l_count >= 1 THEN  --  registration Effective From field was changed. so entry exists in history table.

	  BEGIN
             SELECT  substr(source_column_value,1,11)
               INTO  l_conversion_date
               FROM  xle_histories his
              WHERE  source_table = 'XLE_REGISTRATIONS'
                AND  source_id    = l_registration_id
                AND  source_column_name = 'EFFECTIVE_FROM'
                AND  effective_to IS NULL;

          EXCEPTION
             WHEN OTHERS THEN
 	        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Retrieving conversion Date');
		FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While Retrieving conversion Date');
		    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
          END;

     END IF;     -- End for l_count >=1

    END IF; -- End for l_estb_acts_as_company='N'

    -- inserting data into data extract table
    BEGIN

       INSERT INTO jl_br_sped_extr_data_t
       (request_id,
        block,
        record_seq,
        field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        field7,
        separator7,
        field8,
        separator8,
        field9,
        separator9,
        field10,
        separator10,
        field11,
        separator11,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  	VALUES(g_concurrent_request_id
	       ,'I'  -- Block
	       ,jl_br_sped_extr_data_t_s.nextval  -- record_seq
	       ,'I030' -- Register (field 1)
               ,'|'
	       ,'TERMO DE ABERTURA' -- Fixed Text (field 2)
               ,'|'
	       ,l_book_number --(field 3)
               ,'|'
	       ,l_book_name --(field 4)
               ,'|'
               ,null       --field5
               ,'|'
	       ,g_company_name  --field6
               ,'|'
	       ,SUBSTRB(l_nire,1,11) --field7
               ,'|'
               ,l_cnpj -- field8
               ,'|'
               ,to_char(l_effective_from,'DDMMYYYY') -- field9
               ,'|'
               ,to_char(l_conversion_date,'DDMMYYYY') -- field10
               ,'|'
      	       ,l_city  -- field11
               ,'|'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login);
     EXCEPTION
        WHEN OTHERS THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Error While Inserting Data into I030 register');
             FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
             g_errbuf := 'ERROR While inserting 0000 register '||SQLERRM;
             g_retcode := 2;
             return;
     END;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

END register_I030;


PROCEDURE register_I050 AS
  l_api_name       CONSTANT VARCHAR2(30) :='REGISTER_I050';

  TYPE tab_fv_last_update_date IS TABLE OF
  fnd_flex_values.last_update_date%TYPE INDEX BY BINARY_INTEGER;

  TYPE tab_fv_account_type IS TABLE OF
  VARCHAR2(10) INDEX BY BINARY_INTEGER;

  TYPE tab_fv_summary_flag IS TABLE OF
  VARCHAR2(10) INDEX BY BINARY_INTEGER;

  TYPE tab_fv_value_level IS TABLE OF
  NUMBER INDEX BY BINARY_INTEGER;

  TYPE tab_fv_flex_value IS TABLE OF
  fnd_flex_values.flex_value%TYPE INDEX BY BINARY_INTEGER;

  TYPE tab_fv_flex_value_id IS TABLE OF
  fnd_flex_values.flex_value_id%TYPE INDEX BY BINARY_INTEGER;

  TYPE tab_fv_description IS TABLE OF
  VARCHAR2(250) INDEX BY BINARY_INTEGER;

  fv_last_update_date tab_fv_last_update_date;
  fv_id tab_fv_flex_value_id;
  fv_summary_flag tab_fv_summary_flag;
  fv_parent_value_level tab_fv_value_level;
  fv_parent_value tab_fv_flex_value;
  fv_child_value tab_fv_flex_value;
  fv_description tab_fv_description;

  l_query varchar2(6000);

  l_childs_exist NUMBER := 0;
  l_prev_level1_parent VARCHAR2(10) := '-1';

  l_fv_last_update_date fnd_flex_values.last_update_date%TYPE;
  l_fv_id fnd_flex_values.flex_value_id%TYPE;
  l_fv_summary_flag VARCHAR2(10);
  l_fv_description VARCHAR2(250);

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

FND_FILE.put_line(fnd_file.log,'Start Of I050');

   l_query := 'SELECT  V.last_update_date
	              ,V.flex_value_id
             	      ,V.summary_flag
             	      ,level parent_level
                      ,V.parent_flex_value parent
                      ,V.child_flex_value  child
                      ,V.description
	           FROM  ( SELECT b.last_update_date
				 ,b.flex_value_id
		                 ,b.summary_flag
			         ,a.parent_flex_value
				 ,b.flex_value child_flex_value
				 ,b.description
			    FROM  fnd_flex_value_norm_hierarchy a, -- Hierarquia compilada
			         FND_FLEX_VALUES_VL b, -- Valores do segmento
		                 fnd_id_flex_segments c -- Segmentos da estrutura
			    WHERE  c.application_id = 101
		            AND  c.id_flex_code = ''GL#''
			    AND  c.id_flex_num = '||g_chart_of_accounts_id||
			    ' AND c.application_column_name = '''||g_account_segment||'''
			    AND  b.flex_value_set_id = '||g_account_value_set_id||
			    ' AND  b.flex_value_set_id = c.flex_value_set_id
			    AND  b.flex_value >= a.child_flex_value_low
		            AND  b.flex_value <= a.child_flex_value_high
		            AND  a.flex_value_set_id = b.flex_value_set_id ) V
	      WHERE V.summary_flag=  ''Y''
		 OR  exists  (SELECT  1
				  FROM  gl_code_combinations glcc
		                  WHERE  glcc.chart_of_accounts_id = '||g_chart_of_accounts_id||
		                  ' AND  glcc.summary_flag = ''N''
		                  AND  ('''||l_exclusive_mode||'''=''Y'' OR
				        ('''||l_exclusive_mode||'''=''N'' AND glcc.'||g_bsv_segment||'  in  (select jg_info_v1 from jg_zz_vat_trx_gt)))
				  AND  glcc.'||g_account_segment||' =V.child_flex_value
		               )
	     CONNECT BY  V.parent_flex_value = PRIOR V.child_flex_value
	     START WITH V.parent_flex_value IN
	                  (  SELECT  b.flex_value
	                       FROM  FND_FLEX_VALUES_VL b
	                     WHERE  b.flex_value_set_id = '||g_account_value_set_id||
                       '      AND  NOT EXISTS (SELECT 1 FROM fnd_flex_value_norm_hierarchy a
	                                       WHERE  a.flex_value_set_id = '||g_account_value_set_id||
	                                       ' AND  b.flex_value >= a.child_flex_value_low
	                                       AND  b.flex_value <= a.child_flex_value_high))';

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'I050-Query',l_query);
   END IF;


--FND_FILE.put_line(fnd_file.log,l_query);

   EXECUTE IMMEDIATE l_query
   BULK COLLECT INTO fv_last_update_date
		    ,fv_id
 		    ,fv_summary_flag
		    ,fv_parent_value_level
		    ,fv_parent_value
		    ,fv_child_value
		    ,fv_description;

	-- Deleting parent accounts which has no childs.
  BEGIN
      IF fv_id.COUNT > 0 THEN
	  FOR i in 1..fv_id.LAST
	  LOOP

	    IF fv_summary_flag (i) = 'Y' THEN

		      l_childs_exist := '-1';
		      FOR j in 1..fv_id.LAST
		      LOOP
		       IF fv_parent_value.EXISTS(j) THEN
		        IF fv_parent_value(j) = fv_child_value(i) THEN
		          l_childs_exist := '1';
		          EXIT;
		        END If;
		       END IF;
		      END LOOP;

		     IF l_childs_exist= '-1' and fv_id.EXISTS(i) THEN

		      fv_last_update_date.DELETE(i);
		      fv_id.DELETE(i);
		      fv_summary_flag.DELETE(i);
		      fv_parent_value_level.DELETE(i);
		      fv_parent_value.DELETE(i);
		      fv_child_value.DELETE(i);
		      fv_description.DELETE(i);
		    END IF;

	     END If; --IF fv_summary_flag (i) = 'Y' THEN

	  END LOOP;
      END IF; -- End for If fv_id.COUNT >0.
  EXCEPTION
   WHEN OTHERS THEN
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While deleting the parent accounts in I050 register '||SQLERRM;
      g_retcode := 2;
      return;
  END;
  IF fv_id.COUNT > 0 THEN
    FOR i IN 1..fv_id.LAST
    LOOP

	  IF fv_id.EXISTS(i) THEN

	    IF fv_parent_value_level(i) = 1 and l_prev_level1_parent <> fv_parent_value(i) THEN

	      l_prev_level1_parent := fv_parent_value(i);

	      BEGIN

		SELECT last_update_date
		      ,flex_value_id
	              ,summary_flag
		      ,description
	 	 INTO l_fv_last_update_date
		      ,l_fv_id
		      ,l_fv_summary_flag
		      ,l_fv_description
		FROM FND_FLEX_VALUES_VL
		WHERE flex_value = fv_parent_value(i)
		AND  flex_value_set_id = g_account_value_set_id; -- GL Account segment value set id
	      EXCEPTION
              WHEN OTHERS THEN
		      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
		      IF g_debug_flag = 'Y' THEN
		         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		      END IF;
		      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
			   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR in I050, While getting level 1 parent information Flex Value := '||fv_parent_value(i)||'  '||SQLERRM);
		      END IF;
		      g_errbuf := 'ERROR in I050, While getting level 1 parent information Flex Value := '||fv_parent_value(i)||'  '||SQLERRM;
		      g_retcode := 2;
		      return;
	      END;


    	    INSERT INTO jl_br_sped_extr_data_t
		       (request_id,
           		block,
			record_seq,
			field1,
	                separator1,
		        field2,
			separator2,
	                field3,
		        separator3,
	                field4,
		        separator4,
			field5,
	                separator5,
		        field6,
			separator6,
	              --field7,
		        separator7,
			field8,
	                separator8,
		        created_by,
			creation_date,
	                last_updated_by,
		        last_update_date,
			last_update_login)
		VALUES( g_concurrent_request_id
		       ,'I'  -- Block
		       ,jl_br_sped_extr_data_t_s.nextval -- record_seq
		       ,'I050' -- Register (field 1)
		       ,'|'
		       , to_char(l_fv_last_update_date,'DDMMYYYY')   --field 2
	               ,'|'
		       , JL_BR_SPED_DATA_EXTRACT_PKG.get_account_type(l_fv_id)       --field 3
		       ,'|'
		       , decode(l_fv_summary_flag,'N','A','S')  --field 4   summary flag has 'Y','N' values.
		       ,'|'
		       ,fv_parent_value_level(i)         --field 5
		       ,'|'
		       ,fv_parent_value(i)          --field 6
		       ,'|'
		    -- ,fv_parent_value(i)        --field 7
   	              ,'|'
	              ,l_fv_description        --field 8
		      ,'|'
	              ,g_created_by
                      ,g_creation_date
                      ,g_last_updated_by
                      ,g_last_update_date
                      ,g_last_update_login
		     );

              END IF; -- IF fv_parent_value_level(i) = 1 and l_prev_level1_parent <> fv_parent_value(i) THEN


	    INSERT INTO jl_br_sped_extr_data_t
	       (request_id,
		block,
	        record_seq,
                field1,
                separator1,
                field2,
                separator2,
                field3,
                separator3,
                field4,
                separator4,
                field5,
                separator5,
                field6,
                separator6,
                field7,
                separator7,
                field8,
                separator8,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
		VALUES( g_concurrent_request_id
		       ,'I'  -- Block
		       ,jl_br_sped_extr_data_t_s.nextval -- record_seq
		       ,'I050' -- Register (field 1)
		       ,'|'
		       , to_char(fv_last_update_date(i),'DDMMYYYY')   --field 2
	               ,'|'
		       , JL_BR_SPED_DATA_EXTRACT_PKG.get_account_type(fv_id(i))       --field 3
		       ,'|'
		       , decode(fv_summary_flag(i),'N','A','S')  --field 4   summary flag has 'Y','N' values.
		       ,'|'
		       ,fv_parent_value_level(i)+1         --field 5
		       ,'|'
		       ,fv_child_value(i)          --field 6
		       ,'|'
		       ,fv_parent_value(i)        --field 7
	               ,'|'
	              ,fv_description(i)        --field 8
		      ,'|'
	              ,g_created_by
                      ,g_creation_date
                      ,g_last_updated_by
                      ,g_last_update_date
                      ,g_last_update_login
		     );

       IF fv_summary_flag(i) = 'N' THEN
--FND_FILE.put_line(fnd_file.log,'Before I051'||fv_child_value(i));
             register_I051(fv_child_value(i));

            IF g_bookkeeping_type ='G' OR g_bookkeeping_type = 'R' OR g_bookkeeping_type = 'B' THEN
                 /* I052 is to display agglutination codes. As we get the agglutination codes
                  for fsg, if the fsg request ids are null then there is no need to call I052 */
                 IF g_balance_statement_request_id IS NOT NULL AND g_income_statement_request_id IS NOT NULL THEN
	                 register_I052(fv_child_value(i));
                 END IF;
            END IF;

        END IF;

    END IF; --IF fv_id.EXISTS(i) THEN

  END LOOP;
 END IF; --  IF fv_id.COUNT > 0 THEN
 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                   G_PKG_NAME||': ' ||l_api_name||'()-');
 END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting I050 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I050;

PROCEDURE register_I051(p_account_flex_value fnd_flex_values.flex_value%TYPE ) AS
l_institution_resp_code      VARCHAR2(250);
l_referential_account        gl_cons_flex_hierarchies.parent_flex_value%TYPE;
l_cnt                        NUMBER;
l_api_name                   CONSTANT VARCHAR2(30) :='REGISTER_I051';
BEGIN

--fnd_file.put_line(fnd_file.log,'coa_id '||g_coa_mapping_id);

   IF g_coa_mapping_id IS NULL THEN
      RETURN;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

  -- fnd_file.put_line(fnd_file.log,'Felx value :'||p_account_flex_value||'  G_coa_maping_id :'||g_coa_mapping_id);

   BEGIN

        SELECT  count(distinct parent_flex_value) into l_cnt
	        FROM   gl_coa_mappings C
                       ,gl_cons_segment_map cm
	              ,gl_cons_flex_hierarchies ch
	      WHERE  c.coa_mapping_id = g_coa_mapping_id
	      AND  cm.coa_mapping_id =  c.coa_mapping_id
	      AND  cm.segment_map_type = 'R' --Detail Rollup Ranges
        AND  cm.segment_map_id = ch.segment_map_id
 	      AND  p_account_flex_value BETWEEN ch.child_flex_value_low AND ch.child_flex_value_high;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_referential_account := NULL;
       WHEN OTHERS THEN
             g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
             IF g_debug_flag = 'Y' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
             END IF;
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
             g_errbuf := 'ERROR While finding Number of referential chart of accounts associated for an account in I051 register '||SQLERRM;
             g_retcode := 2;
             return;
	 END;

   IF  l_cnt > 1 THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Consolidation is not proper. '||p_account_flex_value||' is associated with more than one referential chart of account');
   END IF;

	 BEGIN
        SELECT  parent_flex_value into l_referential_account
	        FROM  (SELECT ch.parent_flex_value
                   FROM gl_coa_mappings C
                        ,gl_cons_segment_map cm
	                      ,gl_cons_flex_hierarchies ch
	                WHERE  c.coa_mapping_id = g_coa_mapping_id
	                  AND  cm.coa_mapping_id =  c.coa_mapping_id
	                  AND  cm.segment_map_type = 'R' --Detail Rollup Ranges
                    AND  cm.segment_map_id = ch.segment_map_id
 	                  AND  p_account_flex_value BETWEEN ch.child_flex_value_low AND ch.child_flex_value_high
                 ORDER BY ch.last_update_date DESC)
         WHERE  ROWNUM = 1;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_referential_account := NULL;
       WHEN OTHERS THEN
             g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
             IF g_debug_flag = 'Y' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
             END IF;
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
             g_errbuf := 'ERROR While finding referential chart of accounts mapping in I051 register '||SQLERRM;
             g_retcode := 2;
             return;
	 END;

--fnd_file.put_line(fnd_file.log,'l_ref_account :'||l_referential_account);
   BEGIN


/*  GETTING ENTITY_RESP_REFERENTIAL_COA IS NOT CONFIRMED. NEED TO RECHECK AGAIN  */

      IF UPPER(g_accounting_type) = 'CENTRALIZED' AND g_establishment_id IS NOT NULL THEN

	    SELECT  etb_information5
	      INTO  l_institution_resp_code
	      FROM  xle_etb_profiles
             WHERE  legal_entity_id  = g_legal_entity_id
	       AND  establishment_id = g_establishment_id;

        ELSE

	    SELECT  le_information5
	      INTO  l_institution_resp_code
	      FROM  xle_entity_profiles
             WHERE  legal_entity_id = g_legal_entity_id ;

        END IF;

  	EXCEPTION
         WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'No Data Found for Entity_RESP_REFERENTIAL_COA -'||SQLERRM);
             END IF;
             l_institution_resp_code := NULL;  -- verify
         WHEN OTHERS THEN
             g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
             IF g_debug_flag = 'Y' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
             END IF;
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
             g_errbuf := 'ERROR While finding institution responsibility code in I051 register '||SQLERRM;
             g_retcode := 2;
             return;
    END;

 IF  l_referential_account IS NOT NULL THEN

	INSERT INTO jl_br_sped_extr_data_t
                   (request_id,
                    block,
                    record_seq,
                    field1,
                    separator1,
                    field2,
                    separator2,
                    field3,
                    separator3,
		    field4,
                    separator4,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login)
        VALUES (g_concurrent_request_id
                ,'I'  -- Block
                ,jl_br_sped_extr_data_t_s.nextval -- record_seq
                ,'I051' -- Register (field 1)
                ,'|'
                , SUBSTR(l_institution_resp_code,1,2) --field 2
                ,'|'
                , NULL   --field 3
                ,'|'
                , l_referential_account --field 4
                ,'|'
                ,g_created_by
                ,g_creation_date
                ,g_last_updated_by
                ,g_last_update_date
                ,g_last_update_login
               );

END IF; --END for IF  l_referential_account IS NOT NULL THEN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                    G_PKG_NAME||': ' ||l_api_name||'()-');
	END IF;
EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into I051 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I051;

PROCEDURE register_I052(p_account_flex_value fnd_flex_values.flex_value%TYPE) AS
  l_bal_agglutination_code       rg_report_axes_v.description%TYPE;
	l_income_agglutination_code    rg_report_axes_v.description%TYPE;
	l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I052';
  sql_stmt                   VARCHAR2(5000);
BEGIN

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;


  /* Inserts all agglutination_codes defined for balance_statement_report_id*/
   sql_stmt := 'INSERT INTO jl_br_sped_extr_data_t
               (request_id,
                block,
                record_seq,
                field1,
                separator1,
                field2,
                separator2,
                field3,
                separator3,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
		)
                SELECT  '||g_concurrent_request_id||'
                        ,''I''  -- Block
                        ,jl_br_sped_extr_data_t_s.nextval
                        ,''I052'' -- Register (field 1)
                        ,''|''
                        , NULL --field 2
                        ,''|''
                        , row_seq_ident
                        ,''|''
                        ,'||g_created_by||'
                        ,'''||g_creation_date||'''
                        ,'||g_last_updated_by||'
                        ,'''||g_last_update_date||'''
                        ,'||g_last_update_login||'
        	FROM
                     (SELECT DECODE('''||g_agglutination_code_source||''',''FSG_LINE'',to_char(r3.sequence),r3.description) row_seq_ident
	                FROM   rg_reports r1
                               ,rg_report_axis_sets r2
                               ,rg_report_axes_v r3
                               ,rg_report_axis_contents r4
                       WHERE  r1.report_id   = '||g_balance_statement_report_id||'
                         AND  r1.row_set_id  = r2.axis_set_id
                         AND  r2.axis_set_id = r3.axis_set_id
                         AND  r3.axis_set_id = r4.axis_set_id
                         AND  r3.sequence = r4.axis_seq
                         AND  :p_account_flex_value >='||g_account_segment||'_LOW
                         AND  :p_account_flex_value <='|| g_account_segment||'_HIGH)';

--FND_FILE.PUT_LINE(FND_FILE.LOG, sql_stmt);

     EXECUTE IMMEDIATE sql_stmt using p_account_flex_value,p_account_flex_value;


  /* Inserts all agglutination_codes defined for income_statement_report_id*/
    sql_stmt := 'INSERT INTO jl_br_sped_extr_data_t
          (request_id,
           block,
           record_seq,
           field1,
           separator1,
           field2,
           separator2,
           field3,
           separator3,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
	 )
         SELECT  '||g_concurrent_request_id||'
                ,''I''  -- Block
                ,jl_br_sped_extr_data_t_s.nextval
	        ,''I052'' -- Register (field 1)
                ,''|''
                , NULL --field 2
                ,''|''
                ,row_seq_ident
                ,''|''
                ,'||g_created_by||'
                ,'''||g_creation_date||'''
                ,'||g_last_updated_by||'
                ,'''||g_last_update_date||'''
                ,'||g_last_update_login||'
	FROM
	    (SELECT   DECODE('''||g_agglutination_code_source||''',''FSG_LINE'',to_char(r3.sequence),r3.description) row_seq_ident
	       FROM   rg_reports r1
	          ,rg_report_axis_sets r2
	          ,rg_report_axes_v r3
	          ,rg_report_axis_contents r4
	   WHERE  r1.report_id   = '||g_income_statement_report_id||'
             AND  r1.row_set_id  = r2.axis_set_id
             AND  r2.axis_set_id = r3.axis_set_id
             AND  r3.axis_set_id = r4.axis_set_id
             AND  r3.sequence = r4.axis_seq
             AND  :p_account_flex_value >='||g_account_segment||'_LOW
             AND  :p_account_flex_value <='|| g_account_segment||'_HIGH)';

--FND_FILE.PUT_LINE(FND_FILE.LOG, sql_stmt);

      EXECUTE IMMEDIATE sql_stmt using p_account_flex_value,p_account_flex_value;


  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into I052 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_I052;

PROCEDURE register_I100 AS
l_api_name      CONSTANT VARCHAR2(30) :='REGISTER_I100';
l_query         VARCHAR2(6000);
BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
        G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

-- FND_FILE.PUT_LINE(FND_FILE.LOG,' in register I100');

 IF l_cc_exists_flag = 0 THEN

     RETURN;

 END IF;

l_query  := 'INSERT INTO jl_br_sped_extr_data_t
    (request_id,
     block,
     record_seq,
     field1,
     separator1,
     field2,     separator2,
     field3,       separator3,
     field4,       separator4,
     created_by,         creation_date,      last_updated_by,
     last_update_date,
     last_update_login
     )
       SELECT '||g_concurrent_request_id||
             ',''I''  -- Block
               ,jl_br_sped_extr_data_t_s.nextval --record_seq
               ,''I100'' -- Register (field 1)
           ,''|''
             ,to_char(fv.last_update_date,''DDMMYYYY'')
           ,''|''
             ,fv.flex_value
           ,''|''
             ,fv.description
           ,''|''
           ,'||g_created_by||                    ','''||g_creation_date||''''||
	   ','||g_last_updated_by||               ','''||g_last_update_date||''''||
	   ','||g_last_update_login||                    ' FROM  fnd_flex_values_vl fv
      WHERE  fv.flex_value_set_id = '||g_cost_center_value_set_id||
        ' AND  EXISTS (SELECT  1
                       FROM  gl_code_combinations glcc
                      WHERE  glcc.chart_of_accounts_id = '||g_chart_of_accounts_id||
                         ' AND  glcc.summary_flag = ''N''
			   AND  ('''||l_exclusive_mode||'''=''Y''
                                   OR ('''||l_exclusive_mode ||'''=''N'' AND  glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))
			   AND  glcc.'||g_cost_center_segment||' =fv.flex_value)';

 --     fnd_file.put_line(fnd_file.log,l_query);

      execute immediate l_query;

--  FND_FILE.PUT_LINE(FND_FILE.LOG,' after I100');

--  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                      G_PKG_NAME||': ' ||l_api_name||'()-');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
          g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
     IF g_debug_flag = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
     g_errbuf := 'ERROR While inserting data into I100 register '||SQLERRM;
     g_retcode := 2;
     return;
END register_I100;

/* This register will store the period's information like start_date and end_date parameters*/

PROCEDURE register_I150 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I150';
BEGIN

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                      G_PKG_NAME||': ' ||l_api_name||'()+');
  END IF;

     INSERT INTO jl_br_sped_extr_data_t
    (request_id,
     block,
     record_seq,
     field1,
     separator1,
     field2,
     separator2,
     field3,
     separator3,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login
     )
     VALUES (g_concurrent_request_id
	         ,'I'  -- Block
		       ,jl_br_sped_extr_data_t_s.nextval -- record_seq
		       ,'I150' -- Register (field 1)
           ,'|'
	         ,to_char(g_start_date,'DDMMYYYY') --filed2
           ,'|'
	         ,to_char(g_end_date,'DDMMYYYY')   --field3
           ,'|'
           ,g_created_by
           ,g_creation_date
           ,g_last_updated_by
           ,g_last_update_date
           ,g_last_update_login
           );

--   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into I150 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I150;

PROCEDURE register_I155 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I155';
l_query1                   VARCHAR2(16000);

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;


l_query1 :=
'INSERT INTO jl_br_sped_extr_data_t
                (request_id,
                 block,
                 record_seq,
                 field1,
                 separator1,
                 field2,
                 separator2,
                 field3,
	         separator3,
                 field4,
	         separator4,
	         field5,
                 separator5,
                 field6,
                 separator6,
                 field7,
                 separator7,
                 field8,
                 separator8,
                 field9,
                 separator9,
                 created_by,
		 creation_date,
	         last_updated_by,
                 last_update_date,
                 last_update_login
                 )
                SELECT '||g_concurrent_request_id||
                       ',''I''  -- Block
                       ,jl_br_sped_extr_data_t_s.nextval --record_seq
                       ,''I155'' -- Register (field 1)
                       ,''|''
                       ,natural_acct
                       ,''|''
                       ,cost_center
                       ,''|''
                       ,begin_bal
                       ,''|''
		       ,begin_bal_type
		       ,''|''
		       ,period_dr
		       ,''|''
		       ,period_cr
		       ,''|''
		       ,end_bal
		       ,''|''
		       ,end_bal_type
                      ,''|''
                      ,'||g_created_by||
		      ','''||g_creation_date||''''||
                      ','||g_last_updated_by||
		      ','''||g_last_update_date||''''||
	              ','||g_last_update_login||
	         ' FROM (SELECT  glcc.'||g_account_segment||' natural_acct
                           ,''|''
                            ,decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||') cost_center
                            ,''|''
                            ,TRIM(TO_CHAR(ABS(NVL(SUM(DECODE(glb.period_name
				 ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0))
			         ,''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) begin_bal
			    ,''|''
			    ,DECODE(SIGN(NVL(SUM(DECODE(glb.period_name
		                       ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0))
		                       ,1,''D'',''C'') begin_bal_type
		            ,''|''
		           ,TRIM(TO_CHAR(NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_DR,0))
				        +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_DR,0))
	                               ,0),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) period_dr
			   ,''|''
		           ,TRIM(TO_CHAR(NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_CR,0))
				      +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_CR,0))
	                            ,0),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) period_cr
			   ,''|''
		          ,TRIM(TO_CHAR(ABS(NVL(SUM(
				    DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
	                              ,''-1'' , DECODE(glb.period_name
                                           ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
				       ,DECODE(glb.period_name,
		                       '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
					  )
	                           ),0)),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) end_bal
			   ,''|''
			      ,DECODE(SIGN(NVL(SUM(
		                    DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
			                ,''-1'' , DECODE(glb.period_name
                                            ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
	                                ,DECODE(glb.period_name,
                                            '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
                                  )
                           ),0)),1,''D'',''C'') end_bal_type
                 FROM  gl_balances glb
	             ,gl_code_combinations glcc
	  	 WHERE  period_name in('''||g_period_name||''' , '''||g_adjustment_period_name||''')
		 AND  glb.ledger_id = '||g_ledger_id||
		 ' AND  glb.currency_code   =  '''||g_currency_code||'''
	           AND  glb.code_combination_id= glcc.code_combination_id
	   	   AND  ('''||l_exclusive_mode||'''=''Y'' OR ('''||l_exclusive_mode||'''=''N'' AND glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))  AND  glcc.summary_flag = ''N''
		   AND  glb.actual_flag = ''A''
		 GROUP BY  glcc.'||g_account_segment||',decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment ||')
	          HAVING  NVL(SUM(DECODE(glb.period_name
		   ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0) <> 0 OR
	            NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_DR,0))
		           + SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_DR,0)),0) <> 0 OR
	            NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_CR,0))
		           +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_CR,0)),0) <> 0 OR
	           NVL(SUM(
		           DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
                                ,''-1'' , DECODE(glb.period_name
                                            ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
                                ,DECODE(glb.period_name,
                                          '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
                                  )
                           ),0) <> 0 )';


--  fnd_file.put_line(fnd_file.log,'I155_query:'||l_query1);

           execute immediate  'INSERT INTO jl_br_sped_extr_data_t
                (request_id,
                 block,
                 record_seq,
                 field1,
                 separator1,
                 field2,
                 separator2,
                 field3,
	         separator3,
                 field4,
	         separator4,
	         field5,
                 separator5,
                 field6,
                 separator6,
                 field7,
                 separator7,
                 field8,
                 separator8,
                 field9,
                 separator9,
                 created_by,
		 creation_date,
	         last_updated_by,
                 last_update_date,
                 last_update_login
                 )
                SELECT '||g_concurrent_request_id||
                       ',''I''  -- Block
                       ,jl_br_sped_extr_data_t_s.nextval --record_seq
                       ,''I155'' -- Register (field 1)
                       ,''|''
                       ,natural_acct
                       ,''|''
                       ,cost_center
                       ,''|''
                       ,begin_bal
                       ,''|''
		       ,begin_bal_type
		       ,''|''
		       ,period_dr
		       ,''|''
		       ,period_cr
		       ,''|''
		       ,end_bal
		       ,''|''
		       ,end_bal_type
                      ,''|''
                      ,'||g_created_by||
		      ','''||g_creation_date||''''||
                      ','||g_last_updated_by||
		      ','''||g_last_update_date||''''||
	              ','||g_last_update_login||
	         ' FROM (SELECT  glcc.'||g_account_segment||' natural_acct
                           ,''|''
                            ,decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||') cost_center
                            ,''|''
                            ,TRIM(TO_CHAR(ABS(NVL(SUM(DECODE(glb.period_name
				 ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0))
			         ,''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) begin_bal
			    ,''|''
			    ,DECODE(SIGN(NVL(SUM(DECODE(glb.period_name
		                       ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0))
		                       ,1,''D'',''C'') begin_bal_type
		            ,''|''
		           ,TRIM(TO_CHAR(NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_DR,0))
				        +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_DR,0))
	                               ,0),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) period_dr
			   ,''|''
		           ,TRIM(TO_CHAR(NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_CR,0))
				      +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_CR,0))
	                            ,0),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) period_cr
			   ,''|''
		          ,TRIM(TO_CHAR(ABS(NVL(SUM(
				    DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
	                              ,''-1'' , DECODE(glb.period_name
                                           ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
				       ,DECODE(glb.period_name,
		                       '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
					  )
	                           ),0)),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) end_bal
			   ,''|''
			      ,DECODE(SIGN(NVL(SUM(
		                    DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
			                ,''-1'' , DECODE(glb.period_name
                                            ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
	                                ,DECODE(glb.period_name,
                                            '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
                                  )
                           ),0)),1,''D'',''C'') end_bal_type
                 FROM  gl_balances glb
	             ,gl_code_combinations glcc
	  	 WHERE  period_name in('''||g_period_name||''' , '''||g_adjustment_period_name||''')
		 AND  glb.ledger_id = '||g_ledger_id||
		 ' AND  glb.currency_code   =  '''||g_currency_code||'''
	           AND  glb.code_combination_id= glcc.code_combination_id
	   	   AND  ('''||l_exclusive_mode||'''=''Y'' OR ('''||l_exclusive_mode||'''=''N'' AND glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))
		   AND  glcc.summary_flag = ''N''
		   AND  glb.actual_flag = ''A''
		 GROUP BY  glcc.'||g_account_segment||',decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment ||')
	          HAVING  NVL(SUM(DECODE(glb.period_name
		   ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR,0)),0) <> 0 OR
	            NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_DR,0))
		           + SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_DR,0)),0) <> 0 OR
	            NVL(SUM(DECODE(glb.period_name,'''||g_period_name||''',PERIOD_NET_CR,0))
		           +SUM(DECODE(glb.period_name,'''||g_adjustment_period_name||''',PERIOD_NET_CR,0)),0) <> 0 OR
	           NVL(SUM(
		           DECODE(NVL('''||g_adjustment_period_name||''',''-1'')
                                ,''-1'' , DECODE(glb.period_name
                                            ,'''||g_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                            ,0)
                                ,DECODE(glb.period_name,
                                          '''||g_adjustment_period_name||''',BEGIN_BALANCE_DR - BEGIN_BALANCE_CR +PERIOD_NET_DR -PERIOD_NET_CR
                                        ,0 )
                                  )
                           ),0) <> 0 )';


  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
	    g_errbuf := 'ERROR While inserting data into I155 register '||SQLERRM;
      g_retcode := 2;
      return;
END register_I155;

PROCEDURE register_I200 AS
   l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I200';
   l_period_flag VARCHAR2(1) := NULL;
   l_end_date DATE;
   l_jounrnal_flag VARCHAR2(1) := NULL;
   CURSOR c_journals IS
	   SELECT  j.name||'-'||j.je_batch_id name
                  ,j.default_effective_date
	          ,j.running_total_accounted_dr
	          ,j.je_header_id
                  ,j.je_source
                  ,j.je_category
		  ,j.period_name
	    FROM  gl_je_headers j
	    WHERE  j.ledger_id  = g_ledger_id
	    AND  j.actual_flag = 'A'
	    AND  j.status = 'P'
            AND  j.period_name in (g_period_name,g_adjustment_period_name)
	    AND  ((j.default_effective_date between g_start_date and g_end_date)
	          OR (j.default_effective_date between g_adjustment_period_start_date and g_adjustment_period_end_date))
	    AND   j.je_source NOT IN (SELECT  fl.lookup_code
                                       FROM  fnd_lookups fl
                                      WHERE  fl.lookup_type = 'JLBR_SPED_LEGACY_SOURCES'
				      AND    fl.ENABLED_FLAG = 'Y')
	    AND  EXISTS (SELECT 1
	                       FROM gl_je_lines jl
	                       WHERE jl.je_header_id= j.je_header_id
			       AND  jl.ledger_id=g_ledger_id
			       AND  (l_exclusive_mode = 'Y' OR
			             (l_exclusive_mode = 'N' AND get_segment_value(jl.code_combination_id,g_bsv_segment) in (select jg_info_v1 from jg_zz_vat_trx_gt)))
	                       );

BEGIN

 IF g_bookkeeping_type = 'B' THEN
	return;
 END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

  FOR c_journal_header in c_journals LOOP

    IF g_closing_period_flag = 'Y' THEN

	IF g_adjustment_period_name IS NOT NULL THEN
	  IF c_journal_header.period_name = g_adjustment_period_name THEN
   	   l_jounrnal_flag := 'E';
	  ELSE
	   l_jounrnal_flag := 'N';
	  END IF;
        END IF;
    ELSE
	l_jounrnal_flag := 'N';
    END IF;

	INSERT INTO jl_br_sped_extr_data_t
	      (request_id,
	       block,
       	       record_seq,
	       field1,
	       separator1,
	       field2,
	       separator2,
	       field3,
	       separator3,
               field4,
               separator4,
	       field5,
               separator5,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
			 )
	  VALUES (g_concurrent_request_id
	       ,'I'  -- Block
	       ,jl_br_sped_extr_data_t_s.nextval -- record_seq
	       ,'I200' -- field 1
               ,'|'
	       ,c_journal_header.name   --field 2
               ,'|'
	       ,to_char(c_journal_header.default_effective_date,'DDMMYYYY') --field 3
               ,'|'
	       ,TRIM(TO_CHAR(c_journal_header.running_total_accounted_dr,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))       --field 4
               ,'|'
               ,l_jounrnal_flag        --field 5
               ,'|'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login
	        );

             register_I250(c_journal_header.je_header_id,c_journal_header.name,c_journal_header.je_source,c_journal_header.je_category);

	  END LOOP;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;


EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
	    g_errbuf := 'ERROR While inserting data into I200 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_I200;



PROCEDURE register_I250(p_journal_header_id gl_je_headers.je_header_id%TYPE,
                        p_journal_name gl_je_headers.name%TYPE,
                        p_journal_source gl_je_headers.je_source%TYPE,
                        p_je_category gl_je_headers.je_category%TYPE) AS


l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I250';
l_bordero_id              jl_br_ar_occurrence_docs.bordero_id%TYPE;
l_cnt_bordero_id          NUMBER;
l_occurrence_type         jl_br_ar_occurrence_docs.bank_occurrence_type%TYPE;
l_ap_auxbook_exst         NUMBER;
l_ar_auxbook_exst         NUMBER;
l_description             VARCHAR2(500);
BEGIN


   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Journal Header : '||p_journal_header_id||' Journal Source : '||p_journal_source);
   END IF;

    IF SUBSTR(g_bookkeeping_type,1,1) <> 'A' OR (p_journal_source='Payables' AND  g_ap_ar_auxbook_exist=0)
                                             OR (p_journal_source='Receivables' AND  g_ap_ar_auxbook_exist=0)
                                             OR (p_journal_source <> 'Payables' AND  p_journal_source <> 'Receivables') THEN
    BEGIN

      -- Debit Lines

       INSERT INTO jl_br_sped_extr_data_t
       (request_id,
        block,
        record_seq,
         field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        field7,
        separator7,
        field8,
        separator8,
        field9,
        separator9,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
        SELECT  g_concurrent_request_id
                ,'I'  -- Block
             ,jl_br_sped_extr_data_t_s.nextval -- record_seq
             ,'I250' -- field 1
                ,'|'
                ,get_segment_value(jl.code_combination_id,g_account_segment) natural_Acct
                ,'|'
               ,decode(l_cc_exists_flag,0,null,get_segment_value(jl.code_combination_id,g_cost_center_segment)) cost_center
                ,'|'
               ,TRIM(TO_CHAR(abs(jl.accounted_dr),'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
                ,'|'
               ,'D'  --,DECODE(SIGN(nvl(jl.accounted_dr,0)-nvl(jl.accounted_cr,0)),-1,'C','D')
                ,'|'
               ,p_journal_name
                ,'|'
               ,NULL
                ,'|'
               ,jl.description
                ,'|'
               ,get_participant_code(jl.je_header_id,jl.je_line_num,p_journal_source,jl.code_combination_id,NULL,NULL)
                ,'|'
                ,g_created_by
                ,g_creation_date
                ,g_last_updated_by
                ,g_last_update_date
                ,g_last_update_login
         FROM  gl_je_lines jl
        WHERE  jl.je_header_id = p_journal_header_id
          AND  jl.accounted_dr is not null
          AND  jl.ledger_id = g_ledger_id
          AND  (l_exclusive_mode='Y' OR (l_exclusive_mode='N' AND get_segment_value(jl.code_combination_id,g_bsv_segment) in (SELECT jg_info_v1 FROM jg_zz_vat_trx_gt)));  -- need to modify


  -- Credit Lines

       INSERT INTO jl_br_sped_extr_data_t
       (request_id,
        block,
        record_seq,
         field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        field7,
        separator7,
        field8,
        separator8,
        field9,
        separator9,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
        SELECT  g_concurrent_request_id
                ,'I'  -- Block
             ,jl_br_sped_extr_data_t_s.nextval -- record_seq
             ,'I250' -- field 1
                ,'|'
                ,get_segment_value(jl.code_combination_id,g_account_segment) natural_Acct
                ,'|'
               ,decode(l_cc_exists_flag,0,null,get_segment_value(jl.code_combination_id,g_cost_center_segment)) cost_center
                ,'|'
                 ,TRIM(TO_CHAR(abs(jl.accounted_cr),'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
                ,'|'
               ,'C'  --,DECODE(SIGN(nvl(jl.accounted_dr,0)-nvl(jl.accounted_cr,0)),-1,'C','D')
                ,'|'
               ,p_journal_name
                ,'|'
               ,NULL
                ,'|'
               ,jl.description
                ,'|'
               ,get_participant_code(jl.je_header_id,jl.je_line_num,p_journal_source,jl.code_combination_id,NULL,NULL)
                ,'|'
                ,g_created_by
                ,g_creation_date
                ,g_last_updated_by
                ,g_last_update_date
                ,g_last_update_login
         FROM  gl_je_lines jl
        WHERE  jl.je_header_id = p_journal_header_id
          AND  jl.accounted_cr is not null
          AND  jl.ledger_id = g_ledger_id
          AND  (l_exclusive_mode='Y' OR (l_exclusive_mode='N' AND get_segment_value(jl.code_combination_id,g_bsv_segment) in (SELECT jg_info_v1 FROM jg_zz_vat_trx_gt)));  -- need to modify


    EXCEPTION
       WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While inserting data into I250 register for the Header Id :'||p_journal_header_id);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
    END;
    ELSE   -- If g_bookkeeping_type = 'A/R' or 'A/B' and auxiliary book exists.


   --Extract the detail lines by drill down to xla_ae_lines_all and xla_distributions_links table.

     BEGIN
	    INSERT INTO jl_br_sped_extr_data_t
            (request_id,
            block,
            record_seq,
            field1,
            separator1,
            field2,
            separator2,
            field3,
            separator3,
            field4,
            separator4,
            field5,
            separator5,
            field6,
            separator6,
            field7,
            separator7,
            field8,
            separator8,
            field9,
            separator9,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
         )
          SELECT g_concurrent_request_id
                 , 'I' -- Block
                 , jl_br_sped_extr_data_t_s.nextval -- record_seq
                 , 'I250' -- field 1
    , '|'
    , get_segment_value(xll.code_combination_id, g_account_segment)
    , '|'
    , decode(l_cc_exists_flag, 0, NULL, get_segment_value(xll.code_combination_id, g_cost_center_segment))
    , '|'
    , TRIM(TO_CHAR(ABS(NVL(xld.UNROUNDED_ACCOUNTED_DR, 0) - nvl(xld.UNROUNDED_ACCOUNTED_CR, 0)), '9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
    , '|'
    , DECODE(SIGN(NVL(xld.UNROUNDED_ACCOUNTED_DR, 0) - nvl(xld.UNROUNDED_ACCOUNTED_CR, 0)), - 1, 'C', 'D')
    , '|'
    , p_journal_name
    , '|'
    , NULL
    , '|'
    , nvl(xll.description, p_journal_name || '-' || xll.ae_line_num)
    , '|'
    , get_participant_code(glimp.je_header_id, glimp.je_line_num, p_journal_source, xll.code_combination_id, xll.party_id, xll.party_site_id)
    , '|'
    , g_created_by
    , g_creation_date
    , g_last_updated_by
    , g_last_update_date
    , g_last_update_login
    FROM  gl_import_references glimp,
          xla_ae_lines xll,
	  xla_ae_headers xlh,
	  XLA_DISTRIBUTION_LINKS xld
   WHERE  glimp.je_header_id  = p_journal_header_id
     AND  xlh.ledger_id       = g_ledger_id
     AND  xlh.application_id  = xll.application_id
     AND  xll.gl_sl_link_id   = glimp.gl_sl_link_id
     AND  xll.gl_sl_link_table= glimp.gl_sl_link_table
     AND  xlh.ae_header_id    = xll.ae_header_id
     AND  xll.ae_header_id    = xld.ae_header_id
     AND  xll.application_id  = xld.application_id
     AND  xlh.EVENT_ID        = xld.EVENT_ID
     AND  xll.ae_line_num     = xld.ae_line_num           --p_je_line_num
     AND (l_exclusive_mode='Y' OR (l_exclusive_mode='N' AND get_segment_value(xll.code_combination_id,g_bsv_segment) in (SELECT jg_info_v1 from jg_zz_vat_trx_gt)));    --- Need to modify

   EXCEPTION
      WHEN OTHERS THEN
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Error While inserting data into I250 register for the Header Id :'||p_journal_header_id);
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
   END;

    END IF;   --End for substr(Bookkeeping_type,1,1) <> 'A' ..

END register_I250;


PROCEDURE register_I300_I310 AS

  l_api_name               CONSTANT VARCHAR2(30) :='REGISTER_I300_I310';
  l_previous_date          DATE := g_start_date-1;

  TYPE tab_effective_date IS TABLE OF
  gl_je_lines.effective_date%TYPE INDEX BY BINARY_INTEGER;

  TYPE tab_flex_value IS TABLE OF
  fnd_flex_values.flex_value%TYPE INDEX BY BINARY_INTEGER;

  TYPE tab_num IS TABLE OF
  NUMBER INDEX BY BINARY_INTEGER;

  effective_date  tab_effective_date;
  natural_acct tab_flex_value;
  cost_center_acct tab_flex_value;
  accounted_dr tab_num;
  accounted_cr tab_num;

  l_query varchar2(6000);
  l_estb_check VARCHAR2(2000);

BEGIN

   IF g_bookkeeping_type <> 'B' THEN
     return;
   END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;


  l_query :=   ' SELECT  jl.effective_date
           ,glcc.'||g_account_segment||' natural_acct
	   ,decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||') cost_center_acct
	   ,NVL(SUM(jl.accounted_dr),0) accounted_dr
           ,NVL(SUM(jl.accounted_cr),0) accounted_cr
     FROM  gl_je_headers jh
          ,gl_je_lines jl
      	  ,gl_code_combinations glcc
     WHERE  jh.ledger_id = '||g_ledger_id||'
      AND  jh.default_effective_date BETWEEN '''||g_start_date||''' AND '''||g_end_date||'''
      AND  jh.je_header_id = jl.je_header_id
      AND  jh.actual_flag  = ''A''
      AND  jh.status       = ''P''
      AND  glcc.code_combination_id = jl.code_combination_id
      AND  glcc.chart_of_accounts_id = '||g_chart_of_accounts_id||'
      AND  ('''||l_exclusive_mode||'''=''Y'' OR ('''||l_exclusive_mode||'''=''N'' AND glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))
    GROUP BY jl.effective_date
              ,glcc.'||g_account_segment||'
	      ,decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||')
      ORDER BY  jl.effective_date
	       ,natural_acct
	       ,cost_center_acct';

EXECUTE IMMEDIATE l_query
BULK COLLECT INTO effective_date
                  ,natural_acct
		  ,cost_center_acct
		  ,accounted_dr
		  ,accounted_cr;

  FOR i IN 1..effective_date.COUNT
    LOOP

          IF effective_date(i) <> l_previous_date THEN

	 	           INSERT INTO jl_br_sped_extr_data_t
	 		         (request_id,
	 		          block,
                record_seq,
			          field1,
                separator1,
			          field2,
                separator2,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
			         )
	 		         VALUES (g_concurrent_request_id
			                 ,'I'  -- Block
			                 ,jl_br_sped_extr_data_t_s.nextval -- record_seq
			                 ,'I300' -- field 1
                       ,'|'
                       ,to_char(effective_date(i),'DDMMYYYY')
                       ,'|'
                       ,g_created_by
                       ,g_creation_date
                       ,g_last_updated_by
                       ,g_last_update_date
                       ,g_last_update_login
                       );

	             l_previous_date := effective_date(i);
           END IF;

 	 INSERT INTO jl_br_sped_extr_data_t
	 		 (request_id,
	 		  block,
			  record_seq,
			  field1,
		          separator1,
			  field2,
			  separator2,
			  field3,
		          separator3,
			  field4,
		          separator4,
			  field5,
		          separator5,
			  created_by,
			  creation_date,
		          last_updated_by,
		          last_update_date,
		          last_update_login
			 )
	 		 VALUES (g_concurrent_request_id
			         ,'I'  -- Block
			         ,jl_br_sped_extr_data_t_s.nextval --record_seq
			         ,'I310' -- field 1
			         ,'|'
			         ,natural_acct(i)
		                 ,'|'
	                         ,cost_center_Acct(i)
			         ,'|'
	             ,TRIM(TO_CHAR(accounted_dr(i),'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
		       ,'|'
	             ,TRIM(TO_CHAR(accounted_cr(i),'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
	               ,'|'
		       ,g_created_by
	               ,g_creation_date
		       ,g_last_updated_by
	               ,g_last_update_date
	               ,g_last_update_login    );

  END LOOP;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting into I300 and I310 registers '||SQLERRM;
      g_retcode := 2;
      return;
END register_I300_I310;


PROCEDURE register_I350 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I350';
BEGIN

   IF SUBSTRB(g_bookkeeping_type,1,1) = 'A' THEN
       RETURN;
   END IF;

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;



   INSERT INTO jl_br_sped_extr_data_t
	 (request_id,
	  block,
	  record_seq,
	  field1,
    separator1,
	  field2,
    separator2,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
	 )
   VALUES (g_concurrent_request_id
				   ,'I'  -- Block
				   ,jl_br_sped_extr_data_t_s.nextval -- record_seq
				   ,'I350' -- field 1
           ,'|'
	         ,to_char(g_end_date,'DDMMYYYY')
           ,'|'
           ,g_created_by
           ,g_creation_date
           ,g_last_updated_by
           ,g_last_update_date
           ,g_last_update_login    );

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting into I350 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_I350;

PROCEDURE register_I355 AS
l_api_name             CONSTANT VARCHAR2(30) :='REGISTER_I355';
l_query                VARCHAR2(6000);
l_estb_check           VARCHAR2(2000);

BEGIN


   IF SUBSTRB(g_bookkeeping_type,1,1) = 'A' THEN
       RETURN;
   END IF;

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   IF g_adjustment_period_name IS NOT NULL THEN                   -- It will be true always. so is this check require???

      l_query  := 'INSERT INTO jl_br_sped_extr_data_t
		         (request_id,
			  block,
	                  record_seq,
		          field1,
			  separator1,
	                  field2,
		          separator2,
	                  field3,
		          separator3,
			  field4,
	                  separator4,
		          field5,
			  separator5,
	                  created_by,
		          creation_date,
			  last_updated_by,
	                  last_update_date,
		          last_update_login
			  )
	                 SELECT  '|| g_concurrent_request_id||
		                 ',''I''  Block
			         ,jl_br_sped_extr_data_t_s.nextval
				 ,''I355''
	                         ,''|''
		                 , natural_acct
			         ,''|''
				 ,costcenter_value
	                         ,''|''
		                 ,amount
			         ,''|''
				 ,amount_flag
	                         ,''|''
	                       ,'||g_created_by||
		                 ','''||g_creation_date||''''||
			         ','||g_last_updated_by||
				 ','''||g_last_update_date||''''||
	                         ','||g_last_update_login||
		         ' FROM (SELECT  glcc.'||g_account_segment||' natural_acct '||                                     ',decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||') costcenter_value'||
                                   ',TRIM(TO_CHAR(abs(sum(((glb.BEGIN_BALANCE_DR - glb.BEGIN_BALANCE_CR)
                                   + (glb.PERIOD_NET_DR - glb.PERIOD_NET_CR)))),''9999999990D00'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')) amount
                                   ,DECODE(SIGN(sum((glb.BEGIN_BALANCE_DR - glb.BEGIN_BALANCE_CR)
                                           + (glb.PERIOD_NET_DR - glb.PERIOD_NET_CR))),1,''D'',''C'') amount_flag
			          FROM  gl_balances glb
	                                ,gl_code_combinations glcc
		                 WHERE  glb.period_name = '''||g_period_name||''''||
			         ' AND  glb.code_combination_id = glcc.code_combination_id
				   AND  glb.ledger_id = '||g_ledger_id||
	                         ' AND  glcc.chart_of_accounts_id = '||g_chart_of_accounts_id||
		                 ' AND  glcc.account_type in (''E'',''R'')
				   AND  glcc.summary_flag = ''N''
				   AND  glb.actual_flag = ''A''
				   AND  glb.currency_code   =  '''||g_currency_code||'''
				   AND  ('''||l_exclusive_mode||'''=''Y'' OR ('''||l_exclusive_mode||'''=''N'' AND  glcc.'||g_bsv_segment||' in (select jg_info_v1 from jg_zz_vat_trx_gt)))
			         GROUP BY  glcc.'||g_account_segment||',decode('||l_cc_exists_flag||',0,null,glcc.'||g_cost_center_segment||')
				  HAVING sum(((glb.BEGIN_BALANCE_DR - glb.BEGIN_BALANCE_CR)
                                   + (glb.PERIOD_NET_DR - glb.PERIOD_NET_CR)))<>0) ';

 END IF;


   --   FND_FILE.PUT_LINE(FND_FILE.LOG,'I355 Query :'|| l_query);

   --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Before execution of dynamic query');

      execute immediate l_query;

--      FND_FILE.PUT_LINE(FND_FILE.LOG,'After execution of dynamic query');

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into I355 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_I355;

PROCEDURE register_I990 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_I990';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              'I',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            'I990',  --Register (field1)
              '|',
	            null,--count(*), --field2
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login);

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into I990 registers '||SQLERRM;
      g_retcode := 2;
      return;
END register_I990;

PROCEDURE register_J001 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_J001';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              'J',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            'J001',  --Register (field1)
              '|',
	            0,-- null, --decode(count(*),0,1,0), --field2
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into J001 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J001;

PROCEDURE register_J005 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_J005';

BEGIN

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

    IF g_acct_stmt_ident IS NULL THEN
       RETURN;
    END IF;

 IF  g_bookkeeping_type = 'G' OR g_bookkeeping_type = 'R' OR g_bookkeeping_type = 'B' THEN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      field4,
      separator4,
      field5,
      separator5,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              'J',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            'J005',  --Register (field1)
              '|',
	            to_char(g_start_date,'ddmmyyyy'), --field2
              '|',
              to_char(g_end_date,'ddmmyyyy'), --field3
              '|',
              g_acct_stmt_ident,
              '|',
              decode(g_acct_stmt_ident,2,g_acct_stmt_header,null),
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login);

--   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

 END IF;  -- END for checking on book keeping type

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into J001 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J005;

/*  register_J100 will have balance statement report information.
 Actually before calling this J100 register, a concurrent program will be submitted to
 read balance statement and income statement reports xml data. This JCP program will insert
 records into sped extract temparory table with some imp info like row_sequence_number(into field8),
 sped extract concurrent request,field1(as J100), and filed6 with amount. So by using
 row_sequence stored in J100 record, we need to update other fields of this register.
 After all Updations, update field8 as null.

*/
PROCEDURE register_J100 AS
l_api_name             CONSTANT VARCHAR2(30) :='register_J100';
l_cnt                  NUMBER := 0;
l_amount               NUMBER := 0;
l_amount_sign          NUMBER := 0;
l_format               VARCHAR2(40);
l_amount_in_char       VARCHAR2(30);
l_acct_type            NUMBER;
l_prev_acct_type       NUMBER:= 0;
l_row_set_name         rg_report_axis_sets.name%TYPE;
l_row_name             rg_report_axes.description%TYPE;
acct_low               NUMBER;
acct_high              NUMBER;
l_row_set_id           NUMBER;
l_acct_axis_seq        VARCHAR2(10);
l_axis_seq             VARCHAR2(10);
l_calc_acct_type       VARCHAR2(10);
l_icx_num_format       VARCHAR2(50);
TYPE ref_cursor is REF CURSOR;
acct_cur               ref_cursor;
CURSOR J100_recs_by_jcp IS
   SELECT  field6,      -- amount
           field8       -- row_sequence
     FROM  jl_br_sped_extr_data_t
    WHERE  request_id = g_concurrent_request_id
      AND  field1     = 'J100'
 ORDER BY  record_seq;

CURSOR  calculations_cursor IS
SELECT  field8
  FROM  jl_br_sped_extr_data_t
 WHERE  request_id = g_concurrent_request_id
   AND  field1     = 'J100'
   AND  field4 IS NULL;

BEGIN


   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    SELECT row_set_id
      INTO l_row_set_id
      FROM rg_reports
     WHERE report_id =g_balance_statement_report_id;

    l_icx_num_format := NVL(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),',.');

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): ICX Numeric Format: '||l_icx_num_format);
    END IF;


/*    SELECT  fmt
      INTO  l_format
      FROM  (SELECT  nvl2(ra.display_format,decode(instr(ra.display_format,'.'),0,'999,999,999,999',
                             '999,999,999,999.9999'),'999,999,999,999.9999') fmt
               FROM  rg_reports r,
                     rg_report_axes_v ra
              WHERE  r.report_id =g_balance_statement_report_id
                AND  r.column_set_id =ra.axis_set_id
           ORDER BY  ra.sequence)
      WHERE ROWNUM=1; */

  --  FND_FILE.PUT_LINE(FND_FILE.LOG,'Format of number for Balance sheet report :'||l_format);

    FOR J100_rec in J100_recs_by_jcp  LOOP

      l_amount := 0;
      l_amount_sign := 1;

   --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount before conversion :'||J100_rec.field6);

      l_amount_in_char := trim(J100_rec.field6);

      IF l_icx_num_format = ',.' THEN  -- If the data is in 9.999,99 format changing it to 9,999.99 format

         l_amount_in_char := translate(l_amount_in_char,'.,',',.');

      END IF;


      IF substr(l_amount_in_char,1,1) = '<' OR substr(l_amount_in_char,1,1) = '-' THEN
          l_amount_sign := -1;
          IF substr(l_amount_in_char,1,1) = '<' THEN
             l_amount := to_number(substr(l_amount_in_char,2,length(l_amount_in_char)-2),'999,999,999.999999');
          ELSE
             l_amount := to_number(substr(l_amount_in_char,2,length(l_amount_in_char)-1),'999,999,999.999999');
          END IF;
       ELSE
             l_amount :=  to_number(l_amount_in_char,'999,999,999.999999');
       END IF;

  --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount after conversion :'||l_amount);

       l_cnt := 0;
       SELECT  COUNT(*) -- Checking for account assignements
         INTO  l_cnt
         FROM  rg_report_axis_contents
	      WHERE  axis_set_id  = l_row_set_id
	      	AND  axis_seq    = J100_rec.field8;

      IF l_cnt > 0 THEN --account assignments exists
   --   FND_FILE.PUT_LINE(FND_FILE.LOG,'In acct assignments');
  --    FND_FILE.PUT_LINE(FND_FILE.LOG,J100_rec.field8||'  '||J100_rec.field6);
      l_prev_acct_type := 0;

      OPEN acct_cur FOR 'SELECT '||g_account_segment||'_LOW,'||g_account_segment||'_HIGH
                           FROM   rg_report_axis_contents
                           WHERE  axis_set_id ='|| l_row_set_id||
		                        'AND  axis_seq ='||J100_rec.field8;
       LOOP
           FETCH acct_cur INTO acct_low,acct_high;
           EXIT WHEN  acct_cur%NOTFOUND;

           BEGIN

                 SELECT  DISTINCT DECODE(DECODE(vs.flex_value, 'T', 'O', substrb( fnd_global.newline
	                         ||vs.compiled_value_attributes
	                         ||fnd_global.newline, instrb( fnd_global.newline
	                         ||vs.compiled_value_attributes
	                         ||fnd_global.newline, fnd_global.newline,1,g_account_qualifier_position)+1, 1 )),'A',1,'L',2,'O',2,null)
                   INTO  l_acct_type
                   FROM  fnd_flex_values vs
    	            WHERE  flex_value_set_id = g_account_value_set_id
                    AND  flex_value  BETWEEN acct_low AND acct_high;

       --   FND_FILE.PUT_LINE(FND_FILE.LOG,'acct_type for axis_seq '||J100_rec.field8||' is '||l_acct_type);

            EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_acct_type := null;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'No Account Type found for Report Id:'||g_balance_statement_report_id||' And Axis Num :'||J100_rec.field8);
                   WHEN TOO_MANY_ROWS THEN --Multiple account types assigned for a account range.
                        l_acct_type := null;
                         FND_FILE.PUT_LINE(FND_FILE.LOG,'More Account Types found for Report Id:'||g_balance_statement_report_id||' And Axis Num :'||J100_rec.field8);
                   WHEN OTHERS THEN
                        l_acct_type := null;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception occured while fetching the Acct Type for Report Id:'||g_balance_statement_report_id||' And Axis Num :'||J100_rec.field8);
	                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
            END;
       --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Acct low: '||acct_low||' acct high: '||acct_high);

           IF l_acct_type is not null THEN
             IF l_prev_acct_type <> l_acct_type THEN
      --        FND_FILE.PUT_LINE(FND_FILE.LOG,'In chk'||l_prev_acct_type||'  '||l_acct_type);
                  IF l_prev_acct_type = 0 THEN
                        l_prev_acct_type := l_acct_type;
                  ELSE      -- the Account type of multiple account assignments are not same.
                    --  l_acct_type := null;
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'More Account Types found for Report Id:'||g_balance_statement_report_id||' And Axis Num :'||J100_rec.field8);
                  END IF;
               END IF;
	         END IF;
        END LOOP;
    --    FND_FILE.PUT_LINE(FND_FILE.LOG,'acct_type : '||l_acct_type||'l_prev_acct_type : '||l_prev_acct_type);
        CLOSE acct_cur;
       ELSE /* If no account assignments exists (means if the fsg row is because of caluculation)*/
           l_acct_type := null;
           l_prev_acct_type := null;
       END IF;


     --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Before Update');
          /*Updating J100 records for account assignments */
           UPDATE  jl_br_sped_extr_data_t tmp
              SET  (field2,  field3,separator3,
                   field4 ,
                    separator4,field5, separator5,field6,separator6,
                    field7, separator7) = (SELECT  --jl_br_sped_extr_data_t_s.nextval,
                                                    decode(g_agglutination_code_source,'FSG_LINE',to_char(r2.axis_seq),r2.description),
                                                    r2.number_characters_indented,
                                                    '|',
                                                    --get_account_type(get_segment_range_value(g_account_segment,r3.axis_set_id,r3.axis_seq,'LOW')),  --field4 --account qualifier for segment_low
                                                    nvl(l_acct_type,l_prev_acct_type),   --field4
                                                    '|',
                                                    r2.description,
                                                    '|',
                                                    TRIM(TO_CHAR(l_amount,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')),
						                                        '|',
                                                    decode(l_amount_sign,-1,'C','D'),   --field7
                                                    '|'
                                              FROM  rg_reports r1
                                                    ,rg_report_axes r2
	                                           WHERE  r1.report_id   = g_balance_statement_report_id
  	                                           AND  r1.row_set_id  = r2.axis_set_id
	                                             AND  r2.axis_seq = J100_rec.field8)
            WHERE  request_id = g_concurrent_request_id
              AND  field1  = 'J100'
              AND  field8  = J100_rec.field8;
      --    FND_FILE.PUT_LINE(FND_FILE.LOG,'after Update');

       UPDATE  jl_br_sped_extr_data_t
          SET  record_seq        = jl_br_sped_extr_data_t_s.nextval,
           --    field8            = null,
	             creation_date     = g_creation_date,
	             created_by        = g_created_by,
	             last_update_date  = g_last_update_date,
	       last_updated_by   = g_last_updated_by,
	       last_update_login = g_last_update_login
        WHERE  request_id = g_concurrent_request_id
          AND  field1     = 'J100'
          AND  field8     = J100_rec.field8;
    END LOOP;
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating Acct Type for Calculation rows');
    FOR calc_rec in calculations_cursor LOOP
  --     FND_FILE.PUT_LINE(FND_FILE.LOG,'seq: '||calc_rec.field8);
       l_axis_seq := trim(calc_rec.field8);

       WHILE  l_axis_seq IS NOT NULL
       LOOP
       BEGIN
           SELECT  axis_seq_low
             INTO  l_acct_axis_seq
             FROM  rg_report_calculations
            WHERE  axis_set_id = l_row_set_id
              AND  axis_seq = l_axis_seq
              AND  ROWNUM < 2;
       EXCEPTION
          WHEN OTHERS THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while getting the acct seq for a calculation');
       END;
        --   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_acct_axis_seq: '||l_acct_axis_seq);
            l_cnt := 0;
           SELECT  COUNT(*) -- Checking for account assignements
             INTO  l_cnt
             FROM  rg_report_axis_contents
	          WHERE  axis_set_id =  l_row_set_id
	        	  AND  axis_seq =  l_acct_axis_seq;
          --  FND_FILE.PUT_LINE(FND_FILE.LOG,'l_cnt: '||l_cnt);

           IF l_cnt >0 THEN
           BEGIN
             SELECT  trim(field4)
               INTO  l_calc_acct_type
               FROM  jl_br_sped_extr_data_t
              WHERE  request_id = g_concurrent_request_id
                AND  field1     = 'J100'
                AND  trim(field8) = trim(l_acct_axis_seq);
           EXCEPTION
             WHEN OTHERS THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while getting the acct type of account''s axis_seq for calculation');
           END;

         --   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_calc_acct_type: '||l_calc_acct_type);
              UPDATE  jl_br_sped_extr_data_t
                 SET  field4  = l_calc_acct_type
               WHERE  request_id = g_concurrent_request_id
                 AND  field1     = 'J100'
                 AND  trim(field8) = trim(calc_rec.field8) ;

       --     FND_FILE.PUT_LINE(FND_FILE.LOG,'after Update');
               EXIT;
           ELSE
              l_axis_seq := trim(l_acct_axis_seq);
           END IF;
       END LOOP;
    END LOOP;

    UPDATE  jl_br_sped_extr_data_t
       SET  field8     =  null
     WHERE  request_id =  g_concurrent_request_id
       AND  field1 ='J100';

    UPDATE  jl_br_sped_extr_data_t
       SET  field4 = null
     WHERE  request_id = g_concurrent_request_id
       AND  field1 ='J100'
       AND  field4 = '0'; --field4=0 means all the accounts in the specified account assignments are of not same acct type.

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While processing data Of J100 register '||SQLERRM;
      g_retcode := 2;
      return;

END register_J100;

PROCEDURE register_J150 AS
l_api_name             CONSTANT VARCHAR2(30) :='register_J150';
l_cnt                  NUMBER := 0;
l_amount               NUMBER := 0;
l_amount_in_char       VARCHAR2(30);
l_amount_sign          NUMBER := 0;
l_format               VARCHAR2(40);
l_row_set_id           NUMBER;
l_icx_num_format       VARCHAR2(50);
TYPE ref_cursor is REF CURSOR;
acct_cur               ref_cursor;
CURSOR J150_recs_by_jcp IS
   SELECT  field5,      -- amount
           field8       -- row_sequence
     FROM  jl_br_sped_extr_data_t
    WHERE  request_id = g_concurrent_request_id
      AND  field1     = 'J150'
 ORDER BY  record_seq;
BEGIN

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    SELECT row_set_id
      INTO l_row_set_id
      FROM rg_reports
     WHERE report_id =g_income_statement_report_id;

    l_icx_num_format :=fnd_profile.value('ICX_NUMERIC_CHARACTERS');

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): ICX Numeric Format: '||l_icx_num_format);
    END IF;

 /*   SELECT  fmt
      INTO  l_format
      FROM  (SELECT  nvl2(ra.display_format,decode(instr(ra.display_format,'.'),0,'999,999,999,999',
                             '999,999,999,999.9999'),'999,999,999,999.9999') fmt
               FROM  rg_reports r,
                     rg_report_axes_v ra
              WHERE  r.report_id =g_income_statement_report_id
                AND  r.column_set_id =ra.axis_set_id
           ORDER BY  ra.sequence)
      WHERE ROWNUM=1;  */

--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Format of number for Income statement report :'||l_format);

    FOR J150_rec IN J150_recs_by_jcp LOOP
 --   FND_FILE.PUT_LINE(FND_FILE.LOG,'IN LOOP'||J150_rec.field8||J150_rec.field5);


      l_amount := 0;
      l_amount_sign := 1;

--     FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount before conversion :'||J150_rec.field5);
      l_amount_in_char := trim(J150_rec.field5);

      IF l_icx_num_format = ',.' THEN  -- If the data is in 9.999,99 format changing it to 9,999.99 format

         l_amount_in_char := translate(l_amount_in_char,'.,',',.');

      END IF;

      IF substr(l_amount_in_char,1,1) = '<' OR substr(l_amount_in_char,1,1) = '-' THEN
          l_amount_sign := -1;
          IF substr(l_amount_in_char,1,1) = '<' THEN
             l_amount := to_number(substr(l_amount_in_char,2,length(l_amount_in_char)-2),'999,999,999.999999');
          ELSE
             l_amount := to_number(substr(l_amount_in_char,2,length(l_amount_in_char)-1),'999,999,999.999999');
          END IF;
      ELSE
             l_amount :=  to_number(l_amount_in_char,'999,999,999.999999');
      END IF;

   --  FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount after conversion :'||l_amount);

       l_cnt := 0;
       SELECT  COUNT(*) -- Checking for account assignements
         INTO  l_cnt
         FROM  rg_report_axis_contents
        WHERE  axis_set_id = l_row_set_id
       	  AND  axis_seq    = J150_rec.field8;

   --  FND_FILE.PUT_LINE(FND_FILE.LOG,'After cnt'||l_cnt);

     IF l_cnt > 0 THEN      --account assignments exists

    --          FND_FILE.PUT_LINE(FND_FILE.LOG,'In acct assignments');
    --  FND_FILE.PUT_LINE(FND_FILE.LOG,J150_rec.field8||'  '||J150_rec.field5);


  	   UPDATE  jl_br_sped_extr_data_t tmp
              SET  (field2,  field3,separator3, field4 ,separator4,field5,separator5,
                    field6, separator6) = (SELECT  --jl_br_sped_extr_data_t_s.nextval,
                                                    decode(g_agglutination_code_source,'FSG_LINE',to_char(r2.axis_seq),r2.description), --field2
                                                    r2.number_characters_indented,  --field3
                                                    '|',
                                                    r2.description, --field4
                                                    '|',
						     TRIM(TO_CHAR(l_amount,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')),
                                                    '|',
                                                    decode(l_amount_sign,-1,'R','D'),     --field6
                                                    '|'
                                              FROM  rg_report_axes r2
	                                     WHERE  r2.axis_set_id = l_row_set_id
                                               AND  r2.axis_seq =  J150_rec.field8
                                               AND  ROWNUM      = 1) --There may exist multiple records in rg_report_contents for a axis_set_id and axis_seq
            WHERE  request_id = g_concurrent_request_id
              AND  field1  = 'J150'
              AND  field8  = J150_rec.field8;
     --         FND_FILE.PUT_LINE(FND_FILE.LOG,'After update of account assignements');

      ELSE    -- If the row is of type calculations.
           UPDATE  jl_br_sped_extr_data_t tmp
              SET  (field2,  field3,separator3, field4 ,separator4,field5,separator5,
                    field6, separator6) = (SELECT  --jl_br_sped_extr_data_t_s.nextval,
                                                    decode(g_agglutination_code_source,'FSG_LINE',to_char(r2.axis_seq),r2.description), --field2
                                                    r2.number_characters_indented,  --field3
                                                    '|',
                                                    r2.description, --field4
                                                    '|',
						   TRIM(TO_CHAR(l_amount,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')),
                                                    '|',
                                                    decode(l_amount_sign,-1,'P','N'), --field6
                                                    '|'
                                             FROM  rg_report_axes r2
	                                    WHERE  r2.axis_set_id = l_row_set_id
                                              AND  r2.axis_seq = J150_rec.field8
                                              AND  ROWNUM      = 1) --There may exist multiple records in rg_report_calculations for a axis_set_id and axis_seq
            WHERE  request_id = g_concurrent_request_id
              AND  field1  = 'J150'
              AND  field8  = J150_rec.field8;
  --  FND_FILE.PUT_LINE(FND_FILE.LOG,'After update of calculations');
     END IF;

    UPDATE  jl_br_sped_extr_data_t
        SET  record_seq        = jl_br_sped_extr_data_t_s.nextval,
             field8            = null,
	           creation_date     = g_creation_date,
	           created_by        = g_created_by,
	           last_update_date  = g_last_update_date,
             last_updated_by   = g_last_updated_by,
	           last_update_login = g_last_update_login
      WHERE  request_id = g_concurrent_request_id
        AND  field1     = 'J150'
        AND  field8     = J150_rec.field8;

    END LOOP;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While processing data Of J150 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J150;

PROCEDURE register_J800 AS
l_api_name         CONSTANT VARCHAR2(30) :='REGISTER_J800';
l_file_id          fnd_attached_docs_form_vl.media_id%TYPE;
l_lob_data         BLOB;
l_data_length      NUMBER;
l_amount_to_read   NUMBER := 255;
l_data_var_raw     RAW(255);
l_data_var_char    VARCHAR2(255);
l_read_length      NUMBER := 1;
CURSOR  file_ids_cur(p_journal_for_rtf NUMBER) IS
        SELECT  DISTINCT media_id file_id
          FROM  fnd_attached_docs_form_vl
         WHERE  entity_name = 'GL_JE_HEADERS'
           AND  pk2_value   =  p_journal_for_rtf
           AND  file_name like '%.txt';
BEGIN

   IF nvl(g_closing_period_flag,'N') <> 'Y' THEN
	   RETURN;
   END IF;

   IF g_journal_for_rtf IS NULL THEN
      RETURN;
   END IF;

--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Journal for RTF is :'||g_journal_for_rtf);

 IF  g_bookkeeping_type = 'G' OR g_bookkeeping_type = 'R' OR g_bookkeeping_type = 'B' THEN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    FOR l_file_ids_rec  IN file_ids_cur(g_journal_for_rtf) LOOP

    l_read_length  := 1;   --reinitializing for next file

     BEGIN

          SELECT  file_data
            INTO  l_lob_data
            FROM  FND_LOBS
           WHERE  file_id = l_file_ids_rec.file_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          EXIT;
       WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         IF g_debug_flag = 'Y' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
         END IF;
         IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
      END;

      l_data_length := DBMS_LOB.GETLENGTH(l_lob_data);  --getting the total length of rtf file

    --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): Length of '||l_file_ids_rec.file_id ||' is:' ||l_data_length);

      WHILE (l_read_length < l_data_length )
      LOOP

         DBMS_LOB.READ(l_lob_data,l_amount_to_read,l_read_length,l_data_var_raw); --reading lob data. l_amount_to_read is IN OUT parameter.

         l_data_var_char := UTL_RAW.CAST_TO_VARCHAR2(TO_CHAR(l_data_var_raw));

         INSERT INTO jl_br_sped_extr_data_t
         (request_id,
          block,
          record_seq,
          field1,
          separator1,
          field2,
          separator2,
          field3,
          separator3,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
          VALUES (g_concurrent_request_id,
                  'J',
                  jl_br_sped_extr_data_t_s.nextval,
                  decode(l_read_length,1,'J800',null),   --filed1
                  decode(l_read_length,1,'|',null),      --seperator1
                  l_data_var_char,                       --field2
                  decode(sign(l_data_length - (l_read_length + l_amount_to_read)),1,null,'|'), --separator2
                  decode(sign(l_data_length - (l_read_length + l_amount_to_read)),1,null,'J800FIM'), --field3
                  decode(sign(l_data_length - (l_read_length + l_amount_to_read)),1,null,'|'),  --separator3
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
                  );

           l_read_length := l_read_length + l_amount_to_read ;

      END LOOP;   -- for while
   END LOOP;  -- for cursor loop

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

 END IF; -- End for book keeping type checking

   EXCEPTION
      WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           IF g_debug_flag = 'Y' THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
           END IF;
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
      g_errbuf := 'ERROR While inserting data into J800 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J800;


PROCEDURE register_J900 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_J900';
l_booktype_desc           VARCHAR2(80);
l_book_number             NUMBER; -- change
l_company_name            VARCHAR2(200);
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   SELECT  SUBSTR(meaning,1,80)
     INTO  l_booktype_desc
     FROM  fnd_lookups
    WHERE  lookup_type = 'JLBR_SPED_BOOK_TYPES'
      AND  lookup_code = g_bookkeeping_type;

    BEGIN

        SELECT  book_number
          INTO  l_book_number
          FROM  jl_br_cinfos_books
         WHERE  ((upper(g_accounting_type) = 'DECENTRALIZED' AND legal_entity_id = g_legal_entity_id AND establishment_id IS NULL)
                 OR (upper(g_accounting_type) = 'CENTRALIZED' AND g_establishment_id IS NULL AND legal_entity_id = g_legal_entity_id)
                 OR (upper(g_accounting_type) = 'CENTRALIZED' AND g_establishment_id IS NOT NULL AND legal_entity_id = g_legal_entity_id AND establishment_id=g_establishment_id))
           AND  bookkeeping_type = substrb(g_bookkeeping_type,1,1)
           AND  auxiliary_book_flag = 'N';

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_book_number := null;
          WHEN OTHERS THEN
               g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
               IF g_debug_flag = 'Y' THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
               END IF;
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
      END;


     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      field4,
      separator4,
      field5,
      separator5,
      field6,
      separator6,
      field7,
      separator7,
      field8,
      separator8,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES (g_concurrent_request_id,
             'J',     --block
	           jl_br_sped_extr_data_t_s.nextval,  --record_seq
	           'J900',  --Register (field1)
             '|',
             'TERMO DE ENCERRAMENTO', -- field2
             '|',
             l_book_number,        --field3
             '|',
             l_booktype_desc,      -- field4
             '|',
	     g_company_name,
        --     decode(upper(g_accounting_type),'DECENTRALIZED',g_legal_entity_name,NVL(g_establishment_name,g_legal_entity_name)) ,      --field5
             '|',
             null,                 --field6
             '|',
             to_char(g_start_date,'ddmmyyyy'),          --field7
             '|',
             to_char(g_end_date,'ddmmyyyy'),            --field8
             '|',
             g_created_by,
             g_creation_date,
             g_last_updated_by,
             g_last_update_date,
             g_last_update_login );


--   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into J900 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J900;


--J930 Logic :   (contact info)

PROCEDURE register_J930 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_J930';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   IF ((upper(g_accounting_type) = 'CENTRALIZED' AND g_establishment_id is null)  --LE is the company
        OR  upper(g_accounting_type) = 'DECENTRALIZED')
   THEN

       INSERT INTO jl_br_sped_extr_data_t
       (request_id,
        block,
        record_seq,
        field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
        select  g_concurrent_request_id,
	        'J',
                jl_br_sped_extr_data_t_s.nextval,
		'J930',
		'|',
		hp.party_name,
		'|',
                hp.jgzz_fiscal_code,
		'|',
                lk.meaning,
		'|',
		crole.lookup_code,
		'|',
                hp.person_identifier,
		'|',
		g_created_by,
		g_creation_date,
		g_last_updated_by,
		g_last_update_date,
		g_last_update_login
          from  xle_entity_profiles le,
                xle_contact_legal_roles crole,
                hz_parties hp,
                xle_lookups lk
         where  le.legal_entity_id =g_legal_entity_id
           and  le.party_id = crole.le_etb_party_id
           and  crole.source_table = 'XLE_ENTITY_PROFILES'
           and  crole.lookup_type = 'XLE_CONTACT_ROLE'
           and  crole.contact_party_id = hp.party_id
           and  lk.lookup_type = crole.lookup_type
           and  lk.lookup_code = crole.lookup_code;

    ELSE  -- means running in 'CENTRALIZED' mode and establishment acts as company

       INSERT INTO jl_br_sped_extr_data_t
       (request_id,
        block,
        record_seq,
        field1,
        separator1,
        field2,
        separator2,
        field3,
        separator3,
        field4,
        separator4,
        field5,
        separator5,
        field6,
        separator6,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
        select  g_concurrent_request_id,
	        'J',
                jl_br_sped_extr_data_t_s.nextval,
		'J930',
		'|',
		hp.party_name,
		'|',
                hp.jgzz_fiscal_code,
		'|',
                lk.meaning,
		'|',
		crole.lookup_code,
		'|',
                hp.person_identifier,
		'|',
		g_created_by,
		g_creation_date,
		g_last_updated_by,
		g_last_update_date,
		g_last_update_login
          from  xle_etb_profiles etb,
                xle_contact_legal_roles crole,
                hz_parties hp,
                xle_lookups lk
         where  etb.legal_entity_id =g_legal_entity_id
	   and  etb.establishment_id =g_establishment_id
           and  etb.party_id = crole.le_etb_party_id
           and  crole.source_table = 'XLE_ETB_PROFILES'
           and  crole.lookup_type = 'XLE_CONTACT_ROLE'
           and  crole.contact_party_id = hp.party_id
           and  lk.lookup_type = crole.lookup_type
           and  lk.lookup_code = crole.lookup_code;

         IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
         END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into J930 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_J930;

PROCEDURE register_J990 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_J990';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              'J',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            'J990',  --Register (field1)
              '|',
	            null, --count(*), --field2
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login);

--   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into J990 register'||SQLERRM;
      g_retcode := 2;
      return;
END register_J990;

/* This procedure inserts one record through which we can identify whether data is
    reported for block '9' or not
    0- Block with data reported;
    1- Block without data reported  */

PROCEDURE register_9001 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_9001';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9001',  --Register (field1)
              '|',
	             0,--null, --decode(count(*),0,1,0), --field2
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

--   FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into 9001 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_9001;

/* This procedure will inserts one row for each register got created by this extract prg.
   Each row contains the details like the register_name and total number of lines
   created for that register */

PROCEDURE register_9900 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_9900';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      SELECT  g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9900',  --Register (field1)
              '|',
	            reg, --field2
              '|',
              cnt,
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
        FROM (SELECT  field1 reg,
                      COUNT(*) cnt
                FROM  jl_br_sped_extr_data_t
               WHERE  request_id = g_concurrent_request_id
                 AND  field1 IS NOT NULL
                 AND  field1 <> '9001'
               GROUP BY field1);

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   /*9900 register should contain the number of records for each register.
    At the time of call to this register_9900, records doesn't exists for 9900, 9990 and 9999 registers.
    So need to insert the records 9990 and 9999 registers*/
     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES (g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9900',  --Register (field1)
              '|',
	            '9001', --field2
              '|',
              1,
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES (g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9900',  --Register (field1)
              '|',
	            '9900', --field2
              '|',
              1,
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES (g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9900',  --Register (field1)
              '|',
	            '9990', --field2
              '|',
              1,
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      field3,
      separator3,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES (g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9900',  --Register (field1)
              '|',
	            '9999', --field2
              '|',
              1,
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into 9900 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_9900;

/* This register contains total number of lines generated in block '9' */
PROCEDURE register_9990 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_9990';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9990',  --Register (field1)
              '|',
	            null, --count(*), --field2
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login );

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into 9990 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_9990;

/* This register contains total number of lines generated for sped file */

PROCEDURE register_9999 AS
l_api_name                CONSTANT VARCHAR2(30) :='REGISTER_9999';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

     INSERT INTO jl_br_sped_extr_data_t
     (request_id,
      block,
      record_seq,
      field1,
      separator1,
      field2,
      separator2,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
      VALUES( g_concurrent_request_id,
              '9',     --block
	            jl_br_sped_extr_data_t_s.nextval,  --record_seq
	            '9999',  --Register (field1)
              '|',
	            null, --count(*), --field2  This field will be updated in update_register_cnt proc at the end of data extraction
              '|',
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login);

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'(): No of Records Inserted:' ||SQL%ROWCOUNT);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
	                   G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      g_errbuf := 'ERROR While inserting data into 9999 register'||SQLERRM;
      g_retcode := 2;
      return;

END register_9999;

PROCEDURE update_register_cnt AS
l_api_name                CONSTANT VARCHAR2(30) :='UPDATE_REGISTER_CNT';
BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
        G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

   /*This procedure is to update the details about number of records inserted into sped temp table.
    This will be called at the end of data extraction(after calling all registers) as
    the insertion of data will be completed at this time.
   */

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT DECODE(COUNT(*),0,1,0)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='0'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = '0001'
       AND  request_id = g_concurrent_request_id;

  --  FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 0001 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='0'
                         AND  request_id = g_concurrent_request_id)
     WHERE  field1 = '0990'
       AND  request_id = g_concurrent_request_id;

  --  FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 0990 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT DECODE(COUNT(*),0,1,0)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='I'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = 'I001'
       AND  request_id = g_concurrent_request_id;

--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated I001 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='I'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = 'I990'
       AND  request_id = g_concurrent_request_id;

--   FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated I990 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT DECODE(COUNT(*),0,1,0)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='J'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = 'J001'
       AND  request_id = g_concurrent_request_id;

--     FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated J001 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field6 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE request_id = g_concurrent_request_id
                         AND field1 IS NOT NULL)
     WHERE  field1 = 'J900'
       AND  request_id = g_concurrent_request_id;

 --      FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated J990 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='J'
                         AND  request_id = g_concurrent_request_id
                         AND  field1 IS NOT NULL)
     WHERE  field1 = 'J990'
       AND  request_id = g_concurrent_request_id;

  --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated J990 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT DECODE(COUNT(*),0,1,0)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='9'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = '9001'
       AND  request_id = g_concurrent_request_id;

--   FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 9001 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field3 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE field1='9900'
                         AND request_id = g_concurrent_request_id)
     WHERE  field1 = '9900'
       AND  field2 = '9900'
       AND  request_id = g_concurrent_request_id;

--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 9900 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE block='9'
                         AND  request_id = g_concurrent_request_id)
     WHERE  field1 = '9990'
       AND  request_id = g_concurrent_request_id;

  --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 9990 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field5 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE request_id = g_concurrent_request_id
                         AND  field1 IS NOT NULL)
     WHERE  field1 = 'I030'
       AND  request_id = g_concurrent_request_id;

    --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated I030 register');

    UPDATE  jl_br_sped_extr_data_t
       SET  field2 = (SELECT COUNT(*)
                        FROM jl_br_sped_extr_data_t
                       WHERE request_id = g_concurrent_request_id
                         AND field1 IS NOT NULL)
     WHERE  field1 = '9999'
       AND  request_id = g_concurrent_request_id;

   --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated 9999 register');

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

EXCEPTION
   WHEN OTHERS THEN

      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

END update_register_cnt;

PROCEDURE validation_before_extract AS
l_cnt                    NUMBER := 0;
l_prev_bk_type           VARCHAR2(3);
l_journalsource_check    NUMBER := 0 ;
BEGIN
    --BEGIN: Special situation Start and End Date vaidaion
    BEGIN
     IF g_special_situation_indicator IS NOT NULL THEN

          SELECT  COUNT(*)
            INTO  l_cnt
            FROM  gl_periods gp,
                  gl_ledgers gl
           WHERE  gp.period_set_name  = gl.period_set_name
             AND  gl.ledger_id = g_ledger_id
             AND  g_start_date   >=  gp.start_date
             AND  g_end_date     <=  gp.end_date ;

             IF l_cnt = 0 THEN
                 FND_MESSAGE.SET_NAME('JL','JLBR_SPED_SPEC_SIT_DATE_CHECK');
                 g_errbuf            :=  FND_MESSAGE.GET;
                 --g_errbuf := 'Start and End dates do not belong to same period';
                 g_retcode := 2;
                 return;
             END IF;

      END IF;
     EXCEPTION
         WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' : '||SUBSTR(SQLERRM,1,80));
         g_errbuf :=  'Issue while validation of the special situation start and end date';
         g_retcode :=2;
         RETURN;
    END;
     --END: Special situation Start and End Date vaidaion

      l_cnt := 0;

    BEGIN      -- Begin for checking whether the report is finally submitted or not for the period?

      SELECT  COUNT(*)
        INTO  l_cnt
        FROM  jl_br_sped_extr_param
       WHERE  legal_entity_id    = g_legal_entity_id
         AND  bookkeeping_type   = g_bookkeeping_type
      	 AND  estb_acct_type     = g_accounting_type
         AND  ((g_establishment_id IS NOT NULL AND establishment_id  = g_establishment_id )
	        OR (g_establishment_id IS NULL AND establishment_id IS NULL))
         AND  period_name        = g_period_name
         AND  report_mode in ('R','F');

      IF l_cnt > 0 THEN
         FND_MESSAGE.SET_NAME('JL','JLBR_SPED_FILE_FINAL_REPORTED');
         g_errbuf :=  FND_MESSAGE.GET;
         --g_errbuf := 'Report has been already submitted in Final Mode with this combination';
         g_retcode := 2;
         return;
      END IF;
    EXCEPTION
         WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' : '||SUBSTR(SQLERRM,1,80));
         g_errbuf :=  'Erro while verification of previous report runs';
         g_retcode :=2;
         RETURN;
    END;   -- End for checking whether the report is finally submitted or not for the period?


      /* Validation for the book keeping types 'R' and 'B'.
         User can run the program with book keeping type 'R', only when the program already
         ran with book keeping type 'A/R' for the same input parameters. Same is the case with 'B'*/

      IF g_bookkeeping_type = 'R'  THEN

            BEGIN

                SELECT  bookkeeping_type
                  INTO  l_prev_bk_type
                  FROM  jl_br_sped_extr_param
                 WHERE  legal_entity_id     = g_legal_entity_id
                   AND  estb_acct_type      = g_accounting_type
                   AND  ((g_establishment_id IS NOT NULL AND establishment_id    = g_establishment_id)
		         OR (g_establishment_id IS NULL AND establishment_id IS NULL))
                   AND  period_name         = g_period_name
                   AND  nvl(CONSOL_MAP_ID,1)   = nvl(g_coa_mapping_id,1)
                   AND  data_exist          = 'Y'
                   AND  request_id          <> g_concurrent_request_id
                   AND  bookkeeping_type like 'A/R';

               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('JL','JLBR_SPED_BOOK_A/R_NOT_RUN');
                     g_errbuf :=  FND_MESSAGE.GET;
                     g_retcode :=2;
                     return;
                WHEN OTHERS THEN
            		     FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' : '||SUBSTR(SQLERRM,1,80));
                     g_errbuf :=  'Fialed to get book keeping type in validation_before_extract';
                     g_retcode :=2;
                     RETURN;
            END;

      END IF; -- IF g_bookkeeping_type = 'R'  THEN

       IF g_bookkeeping_type = 'B' THEN

            BEGIN

                SELECT  bookkeeping_type
                  INTO  l_prev_bk_type
                  FROM  jl_br_sped_extr_param
                 WHERE  legal_entity_id     = g_legal_entity_id
                   AND  estb_acct_type      = g_accounting_type
                   AND  ((g_establishment_id IS NOT NULL AND establishment_id= g_establishment_id)
		          OR (g_establishment_id IS NULL AND establishment_id IS NULL))
                   AND  period_name         = g_period_name
                   AND  nvl(CONSOL_MAP_ID,1)   = nvl(g_coa_mapping_id,1)
                   AND  data_exist          = 'Y'
                   AND  request_id          <> g_concurrent_request_id
                   AND  bookkeeping_type like 'A/B';

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('JL','JLBR_SPED_BOOK_A/B_NOT_RUN');
                     g_errbuf :=  FND_MESSAGE.GET;
                     g_retcode :=2;
                     return;
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' : '||SUBSTR(SQLERRM,1,80));
                    g_errbuf :=  'Fialed to get book keeping type in validation_before_extract';
                    g_retcode :=2;
                    return;
              END;

       END IF;

   IF g_bookkeeping_type = 'A/R' AND g_bookkeeping_type = 'A/B' THEN

/*   After calling I015,I200,I250 registers, a custom procedure will called to insert the data of
     non oracle standard journal source's information. Customer will define their journal sources
     as lookup values of type 'JLBR_SPED_LEGACY_SOURCES'. So this validation check is just to
     confirm that user doesn't define any source which is aready defined as standard oracle journal source.
     If user defines any standard oracle journal source in this lookup, program will be terminated with
     a error message. */

   BEGIN

     l_journalsource_check := 0;

     SELECT 1
       INTO l_journalsource_check
       FROM fnd_lookups
      WHERE lookup_type = 'JLBR_SPED_LEGACY_SOURCES'
        AND lookup_code in ('AX Inventory','AX Payables','AX Receivables','Assets','Average Consolidation',
                            'Budget Journal','Carryforward','Consolidation','Conversion','Encumbrance',
                            'Inflation','Intercompany','Inventory','Manual','Manufacturing','MassAllocation',
                            'Move/Merge','Move/Merge Reversal','Other','Payables','Payroll','Personnel','Projects',
                            'Purchasing','Receivables','Recurring','Revaluation','Revenue','Spreadsheet','Statistical','Transfer');

     IF l_journalsource_check = 1 THEN
      --  fnd_message.set_name('JL','JLBR_SPED_OTHER_SL_SOURCE');
      --  fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_message.set_name('JL','JLBR_SPED_OTHER_SL_SOURCE');
        g_errbuf  :=fnd_message.get;
        g_retcode :=2;
        RETURN;
     END IF;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
          null;
       WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' : '||SUBSTR(SQLERRM,1,80));
          g_errbuf :=  'Error occurred while validating the journal sources.';
          g_retcode :=2;
          RETURN;
   END;

   END IF; --End for IF g_bookkeeping_type = 'A/R' AND g_bookkeeping_type = 'A/B' THEN

END validation_before_extract;

PROCEDURE validation_after_extract AS
l_summary_balance1    NUMBER;
l_summary_balance2    NUMBER;
l_cnt                 NUMBER := 0;
l_api_name            CONSTANT VARCHAR2(100) := 'VALIDATE_AFTER_EXTRACT';

CURSOR valor_deb_cur IS
   SELECT  DISTINCT I250.field2,I250.field3 -- natural account and costcenter
     FROM  JL_BR_SPED_EXTR_DATA_T I155,
           JL_BR_SPED_EXTR_DATA_T I250
    WHERE  I155.request_id = g_concurrent_request_id
      AND  I155.field1 = 'I155'
      AND  I250.request_id = g_concurrent_request_id
      AND  I250.field1 = 'I250'
      AND  I155.field2 = I250.field2 -- Natural Account
      AND  I155.field3 = I250.field3 -- Cost Center
      AND  I250.field5 = 'D'  --Debit
      GROUP BY I250.field2,I250.field3
      HAVING SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
             MIN(to_number(I155.field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

CURSOR valor_cred_cur IS
    SELECT  DISTINCT I250.field2,I250.field3  -- natural account and costcenter
      FROM  JL_BR_SPED_EXTR_DATA_T I155,
            JL_BR_SPED_EXTR_DATA_T I250
     WHERE  I155.request_id = g_concurrent_request_id
       AND  I155.field1 = 'I155'
       AND  I250.request_id = g_concurrent_request_id
       AND  I250.field1 = 'I250'
       AND  I155.field2 = I250.field2 -- Natural Account
       AND  I155.field3 = I250.field3 -- Cost Center
       AND  I250.field5 = 'C'  --Credit
      GROUP BY I250.field2,I250.field3
    HAVING SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
           MIN(to_number(I155.field7,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

CURSOR vl_lcto_deb_cur IS
      SELECT  DISTINCT I250.field6  -- Journal Name
        FROM  JL_BR_SPED_EXTR_DATA_T I200,
              JL_BR_SPED_EXTR_DATA_T I250
       WHERE  I200.request_id = g_concurrent_request_id
         AND  I200.field1 = 'I200'
         AND  I250.request_id = g_concurrent_request_id
         AND  I250.field1 = 'I250'
         AND  I200.field2 = I250.field6 -- Jounral Name || BATCH ID
         AND  I250.field5 = 'D'  --Debit
    GROUP BY  I250.field6
      HAVING  SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
              MIN(to_number(I200.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

CURSOR vl_lcto_cred_cur IS
      SELECT  DISTINCT I250.field6  -- Journal Name
        INTO  l_cnt
        FROM  JL_BR_SPED_EXTR_DATA_T I200,
              JL_BR_SPED_EXTR_DATA_T I250
       WHERE  I200.request_id = g_concurrent_request_id
         AND  I200.field1 = 'I200'
         AND  I250.request_id = g_concurrent_request_id
         AND  I250.field1 = 'I250'
         AND  I200.field2 = I250.field6 -- Jounral Name || BATCH ID
         AND  I250.field5 = 'C'  --Credit
    GROUP BY  I250.field6
      HAVING  sum(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
              min(to_number(I200.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		     G_PKG_NAME||': '||l_api_name||'()+');
    END IF;
  /*When the running the report in detail mode, Check if summary mode posted data exists or not?
    If summary data exists warn the user. If program is run for summary mode info check if detail data exists,If exists earn the user*/

     l_cnt := 0;

           SELECT  COUNT(*)         -- Payables invoices posted in Summary mode.
	     INTO  l_cnt
	     FROM (SELECT jl.code_combination_id
                     FROM  gl_je_headers jh
                           ,gl_je_lines jl
                           ,gl_import_references glimp
                           ,xla_ae_lines xll
                           ,xla_ae_headers xlh
                           ,xla_distribution_links xld
                    WHERE  jh.ledger_id = g_ledger_id
                       AND  jh.je_source in ('Payables')
                       AND  jh.je_header_id     = jl.je_header_id
                       AND  glimp.je_header_id  = jh.je_header_id
                       AND  xlh.ae_header_id    = xll.ae_header_id
                       AND  xlh.EVENT_ID        = xld.EVENT_ID
                       AND  xlh.ae_header_id    = xld.ae_header_id
                       AND  jl.je_line_num      = glimp.je_line_num
                       AND  glimp.gl_sl_link_id = xll.gl_sl_link_id
		       AND  glimp.gl_sl_link_table = xll.gl_sl_link_table
		       AND  jh.status      = 'P'
                       AND  jl.status      = 'P'
                       AND  jh.default_effective_date between g_start_date and g_end_date
                  GROUP BY  glimp.je_header_id,glimp.je_line_num,jl.code_combination_id
                    HAVING  count(*) >1);


     IF g_bookkeeping_type = 'G'  THEN
           IF l_cnt > 0 THEN
        --      FND_FILE.PUT_LINE(FND_FILE.LOG,'There exists '||l_cnt||' journals which are posted in Summary Mode');
              FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DATA_DETAIL_CHECK');
              FND_MESSAGE.SET_TOKEN('SOURCE','Payables');
              FND_MESSAGE.SET_TOKEN('PERIOD',g_period_name);
              FND_MESSAGE.SET_TOKEN('BOOKKEEPING_TYPE',g_bookkeeping_type);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
           END IF;
     ELSIF g_bookkeeping_type = 'A/R' OR g_bookkeeping_type = 'A/B' OR  g_bookkeeping_type = 'R' OR g_bookkeeping_type = 'B' THEN
          IF l_cnt = 0 THEN
        --      FND_FILE.PUT_LINE(FND_FILE.LOG,'No journals were posted in Summary Mode');
              FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DATA_SUMMARY_CHECK');
              FND_MESSAGE.SET_TOKEN('SOURCE','Payables');
              FND_MESSAGE.SET_TOKEN('PERIOD',g_period_name);
              FND_MESSAGE.SET_TOKEN('BOOKKEEPING_TYPE',g_bookkeeping_type);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
          END IF;
     END IF;

     l_cnt := 0;

           SELECT  COUNT(*)         -- Receivables transactions posted in Summary mode.
	     INTO  l_cnt
	     FROM (SELECT jl.code_combination_id
                     FROM  gl_je_headers jh
                           ,gl_je_lines jl
                           ,gl_import_references glimp
                           ,xla_ae_lines xll
                           ,xla_ae_headers xlh
                           ,xla_distribution_links xld
                    WHERE  jh.ledger_id = g_ledger_id
                       AND  jh.je_source in ('Receivables')
                       AND  jh.je_header_id     = jl.je_header_id
                       AND  glimp.je_header_id  = jh.je_header_id
                       AND  xlh.ae_header_id    = xll.ae_header_id
                       AND  xlh.EVENT_ID        = xld.EVENT_ID
                       AND  xlh.ae_header_id    = xld.ae_header_id
                       AND  jl.je_line_num      = glimp.je_line_num
                       AND  glimp.gl_sl_link_id = xll.gl_sl_link_id
		       AND  glimp.gl_sl_link_table = xll.gl_sl_link_table
		       AND  jh.status      = 'P'
                       AND  jl.status      = 'P'
                       AND  jh.default_effective_date between g_start_date and g_end_date
                  GROUP BY  glimp.je_header_id,glimp.je_line_num,jl.code_combination_id
                    HAVING  count(*) >1);

     IF g_bookkeeping_type = 'G'  THEN
           IF l_cnt > 0 THEN
         --     FND_FILE.PUT_LINE(FND_FILE.LOG,'There exists '||l_cnt||' journals which are posted in Summary Mode');
              FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DATA_DETAIL_CHECK');
              FND_MESSAGE.SET_TOKEN('SOURCE','Receivables');
              FND_MESSAGE.SET_TOKEN('PERIOD',g_period_name);
              FND_MESSAGE.SET_TOKEN('BOOKKEEPING_TYPE',g_bookkeeping_type);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
           END IF;
     ELSIF g_bookkeeping_type = 'A/R' OR g_bookkeeping_type = 'A/B' OR  g_bookkeeping_type = 'R' OR g_bookkeeping_type = 'B' THEN
          IF l_cnt = 0 THEN
          --    FND_FILE.PUT_LINE(FND_FILE.LOG,'No journals were posted in Summary Mode');
              FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DATA_SUMMARY_CHECK');
              FND_MESSAGE.SET_TOKEN('SOURCE','Receivables');
              FND_MESSAGE.SET_TOKEN('PERIOD',g_period_name);
              FND_MESSAGE.SET_TOKEN('BOOKKEEPING_TYPE',g_bookkeeping_type);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
          END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for Journal''s Posting done ');
     END IF;

  BEGIN
    l_cnt :=0;

    SELECT  COUNT(*)
      INTO  l_cnt
      FROM  jl_br_sped_extr_data_t
     WHERE  request_id = g_concurrent_request_id
       AND  field1 ='I155';

IF l_cnt >0 THEN  -- Only if I155 registers exists, then check the validation rules related to that register
    --Validation rules for I155 register.

/* validation for REGRA_VALIDACAO_SOMA_SALDO_INICIAL - Verifies if the sum of VL_SLD_INI (Register I155)
  is equal to zero for each period reported in the periodic balance register (Register I150)
  (It considers the Debit and Credit Indicator). */

   BEGIN

     l_cnt := 0;


/*     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  (SELECT  to_number(field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') vl_sld_ini
                FROM  JL_BR_SPED_EXTR_DATA_T
               WHERE  request_id = g_concurrent_request_id
                 AND  field1 = 'I155')
      WHERE   vl_sld_ini<> 0; --VL_SLD_INI    */

      SELECT  COUNT(*)
        INTO  l_cnt
        FROM  JL_BR_SPED_EXTR_DATA_T
       WHERE  request_id = g_concurrent_request_id
         AND  field1 = 'I155'
         AND  field4 <>'0,00';  --vl_sld_ini


    IF l_cnt > 0 THEN


       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_SOMA_SALDO_INICIAL');
       INSERT INTO jl_br_sped_extr_msgs
       (request_id,
        block,
        register,
        field,
        message_txt,
        validation_rule,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
       )
       values (g_concurrent_request_id,
               'I',
               'I155',
                4,-- 'field4',
                FND_MESSAGE.GET,
               'REGRA_VALIDACAO_SOMA_SALDO_INICIAL'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login );

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_MESSAGE.SET_NAME('JL','JLBR_SPED_SOMA_SALDO_INICIAL');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_SOMA_SALDO_INICIAL : '||FND_MESSAGE.GET);

    END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_SOMA_SALDO_INICIAL'' was completed ');
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data for ''REGRA_VALIDACAO_SOMA_SALDO_INICIAL'''||SQLERRM);
        END IF;
   END;

    /*validation for REGRA_VALIDACAO_SOMA_SALDO_FINAL - Verifies if the sum of VL_SLD_FIN (Register I155)
      is equal to zero for each period reported in the periodic balance register (Register I150)
      (It considers the  Debit and Credit Indicator). */
   BEGIN
     l_cnt := 0;

/*     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  (SELECT  to_number(field8,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') vl_sld_fin
                FROM  JL_BR_SPED_EXTR_DATA_T
               WHERE  request_id = g_concurrent_request_id
                 AND  field1 = 'I155')
      WHERE   vl_sld_fin<> 0;  */

     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  JL_BR_SPED_EXTR_DATA_T
      WHERE  request_id = g_concurrent_request_id
        AND  field1 = 'I155'
        AND  field8 <>'0,00';

     IF l_cnt > 0 THEN
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_SOMA_SALDO_FINAL');
       INSERT INTO jl_br_sped_extr_msgs
       (request_id,
        block,
        register,
        field,
        message_txt,
        validation_rule,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
       )
       values (g_concurrent_request_id,
               'I',
               'I155',
               8,--'field8',
               FND_MESSAGE.GET,
               'REGRA_VALIDACAO_SOMA_SALDO_FINAL'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login );

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      FND_MESSAGE.SET_NAME('JL','JLBR_SPED_SOMA_SALDO_FINAL');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_SOMA_SALDO_FINAL : '||FND_MESSAGE.GET);
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_SOMA_SALDO_FINAL'' was completed ');
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data for ''REGRA_VALIDACAO_SOMA_SALDO_FINAL'''||SQLERRM);
        END IF;
   END;


    /* validation for REGRA_VALIDACAO_DEB_DIF_CRED - Verifies if the sum of VL_DEB (Register I155) is equal
    to the sum of VL_CRED (Register I155) for each period reported in the periodic balance register
   (Register I150).*/

   BEGIN
     l_cnt := 0;


/*     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  (SELECT  to_number(field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') vl_deb,
                      to_number(field7,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') vl_cred
                FROM  JL_BR_SPED_EXTR_DATA_T
               WHERE  request_id = g_concurrent_request_id
                 AND  field1 = 'I155')
      WHERE   vl_deb <> vl_cred;  */


     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  JL_BR_SPED_EXTR_DATA_T
      WHERE  request_id = g_concurrent_request_id
        AND  field1 = 'I155'
        AND  field6 <> field7;

    IF l_cnt > 0 THEN
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DEB_DIF_CRED');
       INSERT INTO jl_br_sped_extr_msgs
       (request_id,
        block,
        register,
        field,
        message_txt,
        validation_rule,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
       )
       values (g_concurrent_request_id,
               'I',
               'I155',
               6,--'field6',
               FND_MESSAGE.GET,
               'REGRA_VALIDACAO_DEB_DIF_CRED'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login );
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_DEB_DIF_CRED'' was completed ');
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DEB_DIF_CRED');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_DEB_DIF_CRED : '||FND_MESSAGE.GET);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data for ''REGRA_VALIDACAO_DEB_DIF_CRED'''||SQLERRM);
        END IF;
   END;

END IF;  --End for check on number of records existance for I155 register.
END;

   /* Validation for REGRA_VALIDACAO_VALOR_DEB*/
   /*journals total debits (month, account and cost center)  should equal to monthly balance from gl_balances */
  IF g_bookkeeping_type <> 'B' THEN

  BEGIN

   l_cnt := 0;

     select count(*) into l_cnt
 from (
   SELECT
          I250.field2,I250.field3,I155.field2,I155.field3
          ,SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
          , MIN(to_number(I155.field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
     FROM  JL_BR_SPED_EXTR_DATA_T I155,
           JL_BR_SPED_EXTR_DATA_T I250
    WHERE  I155.request_id = g_concurrent_request_id
      AND  I155.field1 = 'I155'
      AND  I250.request_id = g_concurrent_request_id
      AND  I250.field1 = 'I250'
      AND  I155.field2 = I250.field2 -- Natural Account
      AND  I155.field3 = I250.field3 -- Cost Center
      AND  I250.field5 = 'D'  --Debit
      GROUP BY I250.field2,I250.field3,I155.field2,I155.field3
      HAVING SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
             MIN(to_number(I155.field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) -- sum(jounral debit lines) <> Balances debit amount
     );

    IF l_cnt > 0 THEN
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VALOR_DEB');
       INSERT INTO jl_br_sped_extr_msgs
       (request_id,
        block,
        register,
        field,
        message_txt,
        validation_rule,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
       )
       values (g_concurrent_request_id,
               'I',
               'I155',
                6,--'field6',
                FND_MESSAGE.GET,
               'REGRA_VALIDACAO_VALOR_DEB'
               ,g_created_by
               ,g_creation_date
               ,g_last_updated_by
               ,g_last_update_date
               ,g_last_update_login );

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VALOR_DEB');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_VALOR_DEB : '||FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'COD_CTA     COD_CCUS');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------     --------');
       FOR rec IN valor_deb_cur
       LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rec.field2||'     '||rec.field3);
       END LOOP;

    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_VALOR_DEB'' was completed ');
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data for ''REGRA_VALIDACAO_VALOR_DEB'''||SQLERRM);
        END IF;
   END;
    /* validation for REGRA_VALIDACAO_VALOR_CRED*/
    /*journals total credits (month, account and cost center) should equal to monthly balance from gl_balances */

  BEGIN
    l_cnt := 0;

    select count(*) into l_cnt
 from (
   SELECT
          I250.field2,I250.field3,I155.field2,I155.field3
          ,SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
          , MIN(to_number(I155.field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''))
     FROM  JL_BR_SPED_EXTR_DATA_T I155,
           JL_BR_SPED_EXTR_DATA_T I250
    WHERE  I155.request_id = g_concurrent_request_id
      AND  I155.field1 = 'I155'
      AND  I250.request_id = g_concurrent_request_id
      AND  I250.field1 = 'I250'
      AND  I155.field2 = I250.field2 -- Natural Account
      AND  I155.field3 = I250.field3 -- Cost Center
      AND  I250.field5 = 'C'  --Debit
      GROUP BY I250.field2,I250.field3,I155.field2,I155.field3
      HAVING SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
             MIN(to_number(I155.field6,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) -- sum(jounral debit lines) <> Balances debit amount
     );


      IF l_cnt > 0 THEN
          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VALOR_CRED');
          INSERT INTO jl_br_sped_extr_msgs
          (request_id,
           block,
           register,
           field,
           message_txt,
           validation_rule,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          values (g_concurrent_request_id,
                  'I',
                  'I155',
                   6,--'field6',
                   FND_MESSAGE.GET,
                   'REGRA_VALIDACAO_VALOR_CRED'
                  ,g_created_by
                  ,g_creation_date
                  ,g_last_updated_by
                  ,g_last_update_date
                  ,g_last_update_login );
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VALOR_CRED');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_VALOR_CRED : '||FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'COD_CTA     COD_CCUS');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------     --------');
       FOR rec IN valor_cred_cur
       LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rec.field2||'     '||rec.field3);
       END LOOP;

       END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_VALOR_CRED'' was completed ');
     END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data fpr ''REGRA_VALIDACAO_VALOR_CRED'''||SQLERRM);
        END IF;
   END;


  IF g_bookkeeping_type <> 'A/R' AND g_bookkeeping_type <> 'A/B' THEN
     /* validation rule for REGRA_VALIDACAO_VL_LCTO_DEB */
     /* total debit  for a journal header (from journal lines) should match running_total_accounted_dr
        of that journal header    */

    BEGIN
      l_cnt := 0;

      SELECT  count(I250.field6)  -- Journal Name
        INTO  l_cnt
        FROM  JL_BR_SPED_EXTR_DATA_T I200,
              JL_BR_SPED_EXTR_DATA_T I250
       WHERE  I200.request_id = g_concurrent_request_id
         AND  I200.field1 = 'I200'
         AND  I250.request_id = g_concurrent_request_id
         AND  I250.field1 = 'I250'
         AND  I200.field2 = I250.field6 -- Jounral Name || BATCH ID
         AND  I250.field5 = 'D'  --Debit
    GROUP BY  I250.field6
      HAVING  SUM(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
              MIN(to_number(I200.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

    IF l_cnt >0 THEN
          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VL_LCTO_DEB');
          INSERT INTO jl_br_sped_extr_msgs
          (request_id,
           block,
           register,
           field,
           message_txt,
           validation_rule,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          values (g_concurrent_request_id,
                  'I',
                  'I200',
                   2,--'field2',
                    FND_MESSAGE.GET,
                  'REGRA_VALIDACAO_VL_LCTO_DEB'
                  ,g_created_by
                  ,g_creation_date
                  ,g_last_updated_by
                  ,g_last_update_date
                  ,g_last_update_login );

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_VL_LCTO_DEB : '||FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'JOURNAL NAME - BATCH ID');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-----------------------');
       FOR rec IN vl_lcto_deb_cur
       LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rec.field6);
       END LOOP;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_VL_LCTO_DEB'' was completed ');
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data for ''REGRA_VALIDACAO_VL_LCTO_DEB'''||SQLERRM);
        END IF;
   END;
       /* validation for REGRA_VALIDACAO_VL_LCTO_CRED */

     /* total credit  for a journal header (from journal lines) should match running_total_accounted_dr
        of that journal header     */

   BEGIN
      l_cnt := 0 ;

      SELECT  COUNT(I250.field6)-- Journal Name
        INTO  l_cnt
        FROM  JL_BR_SPED_EXTR_DATA_T I200,
              JL_BR_SPED_EXTR_DATA_T I250
       WHERE  I200.request_id = g_concurrent_request_id
         AND  I200.field1 = 'I200'
         AND  I250.request_id = g_concurrent_request_id
         AND  I250.field1 = 'I250'
         AND  I200.field2 = I250.field6 -- Jounral Name || BATCH ID
         AND  I250.field5 = 'C'  --Credit
    GROUP BY  I250.field6
      HAVING  sum(to_number(I250.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''')) <>
              min(to_number(I200.field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.'''));

   IF l_cnt <>0 THEN
          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VL_LCTO_CRED');
          INSERT INTO jl_br_sped_extr_msgs
          (request_id,
           block,
           register,
           field,
           message_txt,
           validation_rule,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          values (g_concurrent_request_id,
                  'I',
                  'I200',
                   2,--'field2',
                   FND_MESSAGE.GET,
                   'REGRA_VALIDACAO_VL_LCTO_CRED'
                   ,g_created_by
                   ,g_creation_date
                   ,g_last_updated_by
                   ,g_last_update_date
                   ,g_last_update_login );

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
       FND_MESSAGE.SET_NAME('JL','JLBR_SPED_VL_LCTO_CRED');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_VL_LCTO_CRED : '||FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'JOURNAL NAME - BATCH ID');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-----------------------');
       FOR rec IN vl_lcto_deb_cur
       LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rec.field6);
       END LOOP;

       END IF;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_VL_LCTO_CRED'' was completed ');
       END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data fpr ''REGRA_VALIDACAO_VL_LCTO_CRED'''||SQLERRM);
        END IF;
   END;
  END IF;  --END IF for g_bookkeeping_type logic
 END IF;   --END FOR IF g_bookkeeping_type <> 'B' THEN

  IF g_bookkeeping_type = 'B' THEN
  /* validation for REGRA_VALIDACAO_DC_BALANCETE */
    /*
    There should not be any I310 register record whose credit <> debit.
    I.e. credit and debit should match for each effective date
  */
  BEGIN
    l_cnt := 0;

    SELECT  COUNT(*)
      INTO  l_cnt
      FROM  JL_BR_SPED_EXTR_DATA_T
     WHERE  request_id = g_concurrent_request_id
       AND  field1 = 'I310';

    IF l_cnt >0 THEN

/*        SELECT  COUNT(*)
          INTO  l_cnt
          FROM  (SELECT  to_number(field4,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') deb,
                         to_number(field5,'9999999990D00','NLS_NUMERIC_CHARACTERS = '',.''') cred
                   FROM  JL_BR_SPED_EXTR_DATA_T
                  WHERE  request_id = g_concurrent_request_id
                    AND  field1 = 'I310')
         WHERE   deb <> cred;    */

        SELECT  COUNT(*)
          INTO  l_cnt
          FROM  JL_BR_SPED_EXTR_DATA_T
         WHERE  request_id = g_concurrent_request_id
           AND  field1 = 'I310'
           AND  field4 <> field5;

         IF l_cnt <> 0 THEN
             FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DC_BALANCETE');
             INSERT INTO jl_br_sped_extr_msgs
             (request_id,
              block,
              register,
              field,
              message_txt,
              validation_rule,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
              )
              values (g_concurrent_request_id,
                     'I',
                     'I310',
                     4,--'field4',
                     FND_MESSAGE.GET,
                     'REGRA_VALIDACAO_DC_BALANCETE'
                     ,g_created_by
                     ,g_creation_date
                     ,g_last_updated_by
                     ,g_last_update_date
                     ,g_last_update_login );
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_DC_BALANCETE');
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_VALIDACAO_DC_BALANCETE : '||FND_MESSAGE.GET);

	END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_VALIDACAO_DC_BALANCETE'' was completed ');
        END IF;
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data fpr ''REGRA_VALIDACAO_DC_BALANCETE'''||SQLERRM);
        END IF;
   END;
 END IF;  -- END FOR IF g_bookkeeping_type = 'B' THEN

    /* Validation for REGRA_OBRIGATORIO_ASSIN_CONTADOR  */
    /*It is mandatory the existence of at least one register J930
      whose COD_ASSIN is equal to 900 (accountant) and
     at least one register J930 whose COD_ASSIN is different than 900 */

    BEGIN
          l_cnt := 0;

          SELECT  COUNT(*)
            INTO  l_cnt
            FROM  jl_br_sped_extr_data_t
           WHERE  field1 = 'J930'
             AND  field5 = '900';

          IF  l_cnt < 1 THEN

           FND_MESSAGE.SET_NAME('JL','JLBR_SPED_ASSIN_CONTADOR');

           INSERT INTO jl_br_sped_extr_msgs
           (request_id,
            block,
            register,
            field,
            message_txt,
            validation_rule,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
           )
           VALUES (g_concurrent_request_id,
                   'J',
                   'J930',
                    5,--'field5',
                    FND_MESSAGE.GET,
                   'REGRA_OBRIGATORIO_ASSIN_CONTADOR'
                   ,g_created_by
                   ,g_creation_date
                   ,g_last_updated_by
                   ,g_last_update_date
                   ,g_last_update_login );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_MESSAGE.SET_NAME('JL','JLBR_SPED_ASSIN_CONTADOR');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_OBRIGATORIO_ASSIN_CONTADOR : '||FND_MESSAGE.GET);

     END IF;

     l_cnt := 0;

     SELECT  COUNT(*)
       INTO  l_cnt
       FROM  jl_br_sped_extr_data_t
      WHERE  field1 = 'J930'
        AND  field5 <> '900';

      IF  l_cnt < 1 THEN

          FND_MESSAGE.SET_NAME('JL','JLBR_SPED_ASSIN_CONTADOR');
          INSERT INTO jl_br_sped_extr_msgs
          (request_id,
           block,
           register,
           field,
           message_txt,
           validation_rule,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          values (g_concurrent_request_id,
                  'J',
                  'J930',
                  5,--'field5',
                  FND_MESSAGE.GET,
                  'REGRA_OBRIGATORIO_ASSIN_CONTADOR'
                  ,g_created_by
                  ,g_creation_date
                  ,g_last_updated_by
                  ,g_last_update_date
                  ,g_last_update_login );

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      FND_MESSAGE.SET_NAME('JL','JLBR_SPED_ASSIN_CONTADOR');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'REGRA_OBRIGATORIO_ASSIN_CONTADOR : '||FND_MESSAGE.GET);
      END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       G_PKG_NAME||': ' ||l_api_name||'(): Validation for ''REGRA_OBRIGATORIO_ASSIN_CONTADOR'' was completed ');
    END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'ERROR Occurred while validating extract data fpr ''REGRA_OBRIGATORIO_ASSIN_CONTADOR'''||SQLERRM);
        END IF;
  END;   /* End for Validation for REGRA_OBRIGATORIO_ASSIN_CONTADOR  */

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		     G_PKG_NAME||': '||l_api_name||'()-');
  END IF;

END validation_after_extract;


PROCEDURE  purge_data(p_request_id NUMBER DEFAULT NULL) AS
l_request_id      NUMBER;
l_api_name        CONSTANT VARCHAR2(30) := 'purge_data';
BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
         G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   BEGIN

    IF p_request_id IS NULL THEN

       SELECT  request_id
         INTO  l_request_id
         FROM  jl_br_sped_extr_param
        WHERE  legal_entity_id    =  g_legal_entity_id
          AND  bookkeeping_type   =  g_bookkeeping_type
          AND  estb_acct_type     =  g_accounting_type
          AND  ((g_establishment_id IS NULL AND establishment_id is NULL) OR
	        (establishment_id   =  g_establishment_id  AND g_establishment_id IS NOT NULL))
          AND  period_name        =  g_period_name
          AND  request_id         <> g_concurrent_request_id
          AND  data_exist         =  'Y';

    ELSE
        l_request_id := p_request_id;
    END IF;
    EXCEPTION
       WHEN  NO_DATA_FOUND THEN
             l_request_id := 0;
       WHEN  OTHERS THEN
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'LE: '||g_legal_entity_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Book keeping type: '||g_bookkeeping_type||'ESTB'||g_establishment_id);
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Period: '||g_period_name);
             END IF;
             --l_request_id := 0;
             g_errbuf := 'Error in finding the request_id to purge the data ';
             g_retcode := 2;
             return;
     END;

     IF l_request_id <> 0 THEN

     --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Purging data of request_id:' || l_request_id);

        DELETE        --purging the data as user running the extract prg for the combination which is already existing in temp table
          FROM jl_br_sped_extr_data_t
         WHERE request_id = l_request_id;

        UPDATE  jl_br_sped_extr_param
           SET  data_exist = 'N'
         WHERE  request_id = l_request_id;

     END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME||': '||l_api_name||'()-');
   END IF;
END  purge_data;


PROCEDURE  main ( errbuf                          OUT NOCOPY VARCHAR2,
                  retcode                         OUT NOCOPY NUMBER,
                  p_accounting_type               VARCHAR2,
                  p_legal_entity_id               XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
                  p_chart_of_accounts_id          GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
		  p_ledger_id                     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE,
                  p_establishment_id              XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
                  p_is_special_situation          VARCHAR2,
                  p_is_special_situation_dummy          VARCHAR2,
                  p_is_special_situation_dummy1          VARCHAR2,
		  p_period_type                   VARCHAR2,
  		  p_period_type_dummy             VARCHAR2,
                  p_period_type_dummy1             VARCHAR2,
                  p_period_name                   GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                  p_adjustment_period_name        GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
                  p_special_situation_indicator   VARCHAR2,
		  p_start_date                    VARCHAR2,
                  p_end_date                      VARCHAR2,
                  p_bookkeeping_type              VARCHAR2,
                  p_bookkeeping_type_dummy        VARCHAR2,
                  p_bookkeeping_type_dummy1       VARCHAR2,
                  p_participant_type              JL_BR_SPED_PARTIC_CODES.PARTICIPANT_TYPE%TYPE,
                  p_participant_type_dummy        JL_BR_SPED_PARTIC_CODES.PARTICIPANT_TYPE%TYPE,
                  p_accounting_segment_type       VARCHAR2,
                  p_coa_mapping_id                VARCHAR2,
                  p_balance_statement_request_id   fnd_concurrent_requests.request_id%TYPE,
                  p_income_statement_request_id    fnd_concurrent_requests.request_id%TYPE,
                  p_agglutination_code_source     VARCHAR2,
                  p_journal_for_rtf               NUMBER,
                  p_acct_stmt_ident               VARCHAR2,
                  p_acct_stmt_ident_dummy         VARCHAR2,
                  p_acct_stmt_header              VARCHAR2,
                  p_hash_code                     VARCHAR2, -- auxillary book
                  p_inscription_source            VARCHAR2,
                  p_inscription_source_dummy      VARCHAR2,
                  p_inscription_source_dummy1     VARCHAR2,
		  p_le_state_reg_code             VARCHAR2,
		  p_le_municipal_reg_code          VARCHAR2,
		  p_state_tax_id                  NUMBER,
		  p_ebtax_state_reg_code          VARCHAR2,
		  p_municipal_reg_tax_id           NUMBER,
		  p_ebtax_municipal_reg_code       VARCHAR2,
		  p_gen_sped_text_file            VARCHAR2) AS

l_api_name        CONSTANT VARCHAR2(30) := 'main';
l_request_id      NUMBER;
l_return          BOOLEAN;
l_phase           varchar2(30);
l_status          varchar2(30);
l_dev_phase       varchar2(30);
l_dev_stage       varchar2(30);
l_message         varchar2(100);
printable_chars   varchar2(99);
non_printable_chars varchar2(35):='|';
l_cnt              NUMBER;
l_sequence_value   NUMBER;
/*CURSOR msg_cur IS SELECT message_txt,validation_rule
                    FROM jl_br_sped_extr_msgs
                   WHERE request_id = g_concurrent_request_id  ;*/
BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Parameter values:');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------------------------------');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Ledger Id   :'||p_ledger_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Chart Of Accounts Id :'||p_chart_of_accounts_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Establishment Accounting Type:'||p_accounting_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Legal Entity Id  :'||p_legal_entity_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Establishment Id :'||p_establishment_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Is Special Situation :'||p_is_special_situation);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Period Name :'||p_period_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Period Type :'||p_period_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'01 - Regular Period, 02- Closing Period With Adjustment Period');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Adjustment Period :'||p_adjustment_period_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Special Situation Indicator :'||p_special_situation_indicator);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Period Start Date :'||p_start_date);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Period End Date   :'||p_end_date);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Book Keeping Type :'||p_bookkeeping_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Participant Type :'||p_participant_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Accounting Segment :'||p_accounting_segment_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Referential Chart Of Accounts Mapping :'||p_coa_mapping_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Balance Sheet Report Name :'||p_balance_statement_request_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Income Statement Report Name :'||p_income_statement_request_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Agglutination Code Source :'||p_agglutination_code_source);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Journal Source for RTF File :'||p_journal_for_rtf);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Hash Code :'||p_hash_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Accounting Statements Indication :'||p_acct_stmt_ident);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Accounting Statements Header :'||p_acct_stmt_header);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Generate SPED Text File :'||p_gen_sped_text_file);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'State And Munciple Inscription Source :'||p_inscription_source);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Lookup Type for LE State Inscription	 :'||p_le_state_reg_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Lookup Type for LE Munciple Inscription :'||p_le_municipal_reg_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Tax Used to define State Inscription  :'||p_state_tax_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Lookup Type for EBTax State Inscription :'||p_ebtax_state_reg_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Tax Used to define Munciple Inscription :'||p_municipal_reg_tax_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Lookup Type for EBTax Munciple Inscription :'||p_ebtax_municipal_reg_code);


   FND_FILE.PUT_LINE(FND_FILE.LOG,'--------Parameters End-----------------------------------------');



   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling Initialize proc');

    Initialize (p_ledger_id,
                p_chart_of_accounts_id,
                p_accounting_type,
		p_legal_entity_id,
		p_establishment_id,
                p_is_special_situation,
		p_period_type,
		p_period_name,
	        p_adjustment_period_name,
                p_start_date,
                p_end_date,
                p_special_situation_indicator,
                p_bookkeeping_type,
                p_participant_type,
                p_accounting_segment_type,
                p_coa_mapping_id,
                p_balance_statement_request_id,
                p_agglutination_code_source,
                p_income_statement_request_id,
                p_journal_for_rtf,
                p_hash_code,
                p_acct_stmt_ident,
                p_acct_stmt_header,
                p_gen_sped_text_file,
     		p_inscription_source,
     	        p_le_state_reg_code,
     		p_le_municipal_reg_code,
     		p_state_tax_id,
     		p_ebtax_state_reg_code,
     		p_municipal_reg_tax_id,
     		p_ebtax_municipal_reg_code
     );

    IF g_retcode = 2 THEN
     errbuf := g_errbuf;
     retcode := 2;
     return;
    END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'End of Initialize proc' );
 --  FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling validation_before_extract proc' );

   validation_before_extract;

    IF g_retcode = 2 THEN
     errbuf := g_errbuf;
     retcode := 2;
     return;
    END IF;

  --  FND_FILE.PUT_LINE(FND_FILE.LOG,'END Of validation_before_extract proc' );

--Start Block 0
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0000 proc');
     register_0000;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0001 proc');
     register_0001;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0007 proc');
     register_0007;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0020 proc');
     register_0020;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0150_0180 proc');
     register_0150_0180;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_0990 proc');
     register_0990;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

--Start Block I

  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I001 proc');
     register_I001;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

   --  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I010 proc');
     register_I010;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I012 proc');
     register_I012;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I015 proc');
     register_I015;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

--- custom code hook call for register I015

     IF  substrb(g_bookkeeping_type,1,1) <> 'G' THEN

        SELECT jl_br_sped_extr_data_t_s.CURRVAL INTO l_sequence_value
	FROM DUAL;

--      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling code hook, which populates I015 for Integrated Receiving system');
--	FND_FILE.PUT_LINE(FND_FILE.LOG,'Code Hook Starting Sequence Value :'||l_sequence_value);

	 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Start of Code Hook register_I015');
         END IF;
	 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Code Hook register_I105 : Starting Sequence Value :'||l_sequence_value);
         END IF;


	 JL_BR_SPED_DATA_EXTRACT_PUB.register_I015( g_retcode
                                                    ,g_errbuf
                                                    ,g_ledger_id
                                                    ,g_legal_entity_id
                                                    ,g_establishment_id
                                                    ,g_period_set_name
                                                    ,g_start_date
                                                    ,g_end_date
                                                    ,g_bsv_segment
                                                    ,g_account_segment
                                                    ,g_cost_center_segment          --can be null if the customer doesn't have the cost center setup.
                                                    ,g_bookkeeping_type
                                                    ,g_concurrent_request_id);

        SELECT jl_br_sped_extr_data_t_s.CURRVAL INTO l_sequence_value
	FROM DUAL;

--	FND_FILE.PUT_LINE(FND_FILE.LOG,'Code Hook Ending Sequence Value :'||l_sequence_value);
	IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Code Hook register_I105 : Ending Sequence Value :'||l_sequence_value);
         END IF;

        IF g_retcode = 2 THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occurred in Custom package JL_BR_SPED_DATA_EXTRACT_PUB.register_I015');
           errbuf := g_errbuf;
           retcode :=2;
           RETURN;
         END IF;
     END IF;

 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I030 proc');
     register_I030;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I050 proc');

     FND_FILE.PUT_LINE(FND_FILE.LOG,'before I050:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I050;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I100 proc');

      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I100:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I100;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I150 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I150:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I150;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I155 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I155:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I155;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I200 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I200:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I200;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;

-- custom code hook call for register I200 and I250

     IF  substrb(g_bookkeeping_type,1,1) <> 'B' THEN

        SELECT jl_br_sped_extr_data_t_s.CURRVAL INTO l_sequence_value
	FROM DUAL;

--      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling code hook, which populates I200 and I250 for Integrated Receiving system');
--	FND_FILE.PUT_LINE(FND_FILE.LOG,'Code Hook Starting Sequence Value :'||l_sequence_value);

	 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Start of Code Hook register_I200_I250');
         END IF;
	 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Code Hook register_I200_I250 Starting Sequence Value :'||l_sequence_value);
         END IF;


	 JL_BR_SPED_DATA_EXTRACT_PUB.register_I200_I250( g_retcode
                                                         ,g_errbuf
						         ,g_ledger_id
                                                         ,g_legal_entity_id
                                                         ,g_establishment_id
                                                         ,g_period_set_name
                                                         ,g_start_date
                                                         ,g_end_date
                                                         ,g_bsv_segment
                                                         ,g_account_segment
                                                         ,g_cost_center_segment          --can be null if the customer doesn't have the cost center setup.
                                                         ,g_bookkeeping_type
                                                         ,g_concurrent_request_id);

        SELECT jl_br_sped_extr_data_t_s.CURRVAL INTO l_sequence_value
	FROM DUAL;

--	FND_FILE.PUT_LINE(FND_FILE.LOG,'Code Hook Ending Sequence Value :'||l_sequence_value);
	IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME, 'Code Hook register_I200_I250 Ending  Sequence Value :'||l_sequence_value);
         END IF;

        IF g_retcode = 2 THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occurred in Custom package JL_BR_SPED_DATA_EXTRACT_PUB.register_I200_I250');
           errbuf := g_errbuf;
           retcode :=2;
           RETURN;
         END IF;
     END IF;


 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I300_I310 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I300_I310:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I300_I310;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I350 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I350:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I350;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I355 proc');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'before I355:'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
     register_I355;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_I990 proc');
     register_I990;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J001 proc');
     register_J001;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J001 proc');
     register_J005;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      return;
     END IF;
     IF  substr(g_bookkeeping_type,1,1) <> 'A' AND g_bookkeeping_type <> 'Z' THEN

       IF g_balance_statement_request_id IS NOT NULL OR g_income_statement_request_id IS NOT NULL THEN
           --Submit concurrent request which call the JCP to populate J100 and J150 registers.
           l_request_id := fnd_request.submit_request ('JL',
                                                       'JLBRASFS',
                                                       '',
                                                       '',
                                                       FALSE,
                                                       g_concurrent_request_id,        --arguement1
                                                       g_balance_statement_request_id, --arguement2
                                                       g_income_statement_request_id,-- Income statement Request Id
                                                       'Y' -- Debug flag
                                                       );


   --    FND_FILE.PUT_LINE(FND_FILE.LOG,'Request Id: '|| l_request_id);
         commit;
            --wait till the request completed.
       l_return  := FND_CONCURRENT.WAIT_FOR_REQUEST(    l_request_id,
                                                        1,                    --interval (no of secs to wait to check the status)
                                                        60,                   --max_wait
                                                        l_phase,        --  phase      OUT varchar2,
                                                        l_status,        -- status     OUT varchar2,
                                                        l_dev_phase,     -- dev_phase OUT varchar2,
                                                        l_dev_stage,     --dev_status OUT varchar2,
                                                        l_message);       --message    OUT varchar2)


/* Amount column in both J100 and J150 is a required field. So we shouldn't display
   the FSG records with the amount as not null. so Delete those records */

    IF l_return  THEN
  --      FND_FILE.PUT_LINE(FND_FILE.LOG,  'Return Status: True');
   --     FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_status: '||l_status);

	IF l_status = 'Error' THEN  --If FSG concurrent program ended in error then error out the data extract progam
           errbuf := 'Brazilian Accounting SPED Financial Statements Data Extraction Program Ended in Error.';
           retcode := 2;
           purge_data(g_concurrent_request_id);
	   commit;
           return;
        END IF;

        BEGIN
             SELECT count(*)
               INTO l_cnt
               FROM jl_br_sped_extr_data_t
              WHERE request_id = g_concurrent_request_id
                AND field1 = 'J100';

        --     FND_FILE.PUT_LINE(FND_FILE.LOG,'cnt of rows from FSG for bal: '||l_cnt);

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'No records found');
        END;

         DELETE  FROM  jl_br_sped_extr_data_t
	           WHERE  field1 ='J100'
	             AND  request_id = g_concurrent_request_id
	             AND  field6 is null;

            DELETE  FROM  jl_br_sped_extr_data_t
	           WHERE  field1 ='J150'
	             AND  request_id = g_concurrent_request_id
	             AND  field5 is null;

        BEGIN
             SELECT count(*)
               INTO l_cnt
               FROM jl_br_sped_extr_data_t
              WHERE request_id = g_concurrent_request_id
                AND field1 = 'J100';

       --      FND_FILE.PUT_LINE(FND_FILE.LOG,'cnt of rows from FSG for bal: '||l_cnt);

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'No records found');
        END;

         IF g_balance_statement_request_id IS NOT NULL THEN
       --     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J100 proc');
            register_J100;
            IF g_retcode = 2 THEN
               errbuf := g_errbuf;
               retcode := 2;
               purge_data(g_concurrent_request_id);
	       commit;
               return;
            END IF;
         END IF;
         IF g_income_statement_request_id IS NOT NULL THEN
       --     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J150 proc');
            register_J150;
            IF g_retcode = 2 THEN
               errbuf := g_errbuf;
               retcode := 2;
               purge_data(g_concurrent_request_id);
	       commit;
               return;
            END IF;
         END IF;

    --  ELSE
      --  FND_FILE.PUT_LINE(FND_FILE.LOG , 'Return Status: False');
      END IF;

       END IF;  -- End for check on FSG request Ids.

     END IF; -- End for check on book_keeping_type.

  --   FND_FILE.PUT_LINE(FND_FILE.LOG,'End Of FSG registers');

 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J800 proc');
     register_J800;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      purge_data(g_concurrent_request_id);
      commit;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J900 proc');
     register_J900;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      purge_data(g_concurrent_request_id);
      commit;
      return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J930 proc');
     register_J930;
     IF g_retcode = 2 THEN
      errbuf := g_errbuf;
      retcode := 2;
      purge_data(g_concurrent_request_id);
      commit;
      return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_J990 proc');
     register_J990;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_9001 proc');
     register_9001;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_9900 proc');
     register_9900;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;
 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_9990 proc');
     register_9990;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;
  --   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling register_9999 proc');
     register_9999;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;
    /* SPED table fields shouldn't contain Non pritable and pipe symbol.
       So need to remove non Printable characters. */

     printable_chars      := null;
     non_printable_chars  := '|';

     for i in 0 .. 31 loop  --ASCII characters 0 to 31 are non printable characters
         non_printable_chars:= non_printable_chars||fnd_global.local_chr(i);
     end loop;
     for i in 32 .. 123 loop -- printable characters
         printable_chars := printable_chars||fnd_global.local_chr(i);
     end loop;

     /*ASCII characters 32 to 126 are printable characters. But as we even want to remove pipe,don't include chr(124) */

     printable_chars := printable_chars||fnd_global.local_chr(125)||fnd_global.local_chr(126);

 --   FND_FILE.PUT_LINE(FND_FILE.LOG,'Removing non printable characters');

     UPDATE  jl_br_sped_extr_data_t
        SET  field2  = translate(field2, printable_chars|| non_printable_chars, printable_chars),
             field3  = translate(field3, printable_chars|| non_printable_chars, printable_chars),
             field4  = translate(field4, printable_chars|| non_printable_chars, printable_chars),
             field5  = translate(field5, printable_chars|| non_printable_chars, printable_chars),
             field6  = translate(field6, printable_chars|| non_printable_chars, printable_chars),
             field7  = translate(field7, printable_chars|| non_printable_chars, printable_chars),
             field8  = translate(field8, printable_chars|| non_printable_chars, printable_chars),
             field9  = translate(field9, printable_chars|| non_printable_chars, printable_chars),
             field10 = translate(field10, printable_chars|| non_printable_chars, printable_chars),
             field11 = translate(field11, printable_chars|| non_printable_chars, printable_chars),
             field12 = translate(field12, printable_chars|| non_printable_chars, printable_chars),
             field13 = translate(field13, printable_chars|| non_printable_chars, printable_chars),
             field14 = translate(field14, printable_chars|| non_printable_chars, printable_chars),
             field15 = translate(field15, printable_chars|| non_printable_chars, printable_chars)
      WHERE  request_id = g_concurrent_request_id;

 --  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling update_register_cnt proc');
       update_register_cnt;


 --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling validation_after_extract proc');
     validation_after_extract;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;

 --    FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling purge_data proc');
     purge_data;
     IF g_retcode = 2 THEN
        errbuf := g_errbuf;
        retcode := 2;
        purge_data(g_concurrent_request_id);
	commit;
        return;
     END IF;

      UPDATE  JL_BR_SPED_EXTR_PARAM    -- After successfull data extraction, updating the data_exist column in Parameter's table.
        SET  data_exist = 'Y'
      WHERE  request_id = g_concurrent_request_id;


      IF p_gen_sped_text_file = 'Y' THEN
     /* p_gen_sped_text_file is a parameter which indicates whether to generate text file
        or not. So if the paramter value is 'Y' then submit request for text file generation program. */

      l_request_id := fnd_request.submit_request ('JL',
                                    'JLBRASTF',
                                    '',
                                    '',
                                    FALSE,
                                  --  g_ledger_id,
                                    g_concurrent_request_id, -- request Id of data extract program
                                    'P' -- preliminary mode
                                   );

 --    FND_FILE.PUT_LINE(FND_FILE.LOG,'Request Id: '|| l_request_id);

       END IF;  -- End for check on p_gen_sped_text_file.
     RETURN;

END main;

END JL_BR_SPED_DATA_EXTRACT_PKG;


/
