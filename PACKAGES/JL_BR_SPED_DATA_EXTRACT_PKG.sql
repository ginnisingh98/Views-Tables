--------------------------------------------------------
--  DDL for Package JL_BR_SPED_DATA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_SPED_DATA_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlbrases.pls 120.1.12010000.1 2009/08/17 14:30:45 mkandula noship $ */


    --Globals for report parameters.


    g_ledger_id                             GL_LEDGERS.LEDGER_ID%TYPE;
    g_chart_of_accounts_id                  GL_LEDGERS.chart_of_accounts_id%TYPE;
    g_accounting_type                  VARCHAR2(30);  --represents 'Centralized' or 'Decentralized'
    g_legal_entity_id                          XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;
    g_establishment_id                         XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE;
    g_period_name                           GL_PERIODS.PERIOD_NAME%TYPE;
    g_start_date                            GL_PERIODS.START_DATE%TYPE;
    g_end_date                              GL_PERIODS.END_DATE%TYPE;
    g_adj_start_date                            GL_PERIODS.START_DATE%TYPE;
    g_adj_end_date                              GL_PERIODS.END_DATE%TYPE;
    g_special_situation_indicator           VARCHAR2(30);
    g_bookkeeping_type                     VARCHAR2(3);
    g_participant_type                      JL_BR_SPED_PARTIC_CODES.PARTICIPANT_TYPE%TYPE;
    g_accounting_segment_type               VARCHAR2(30);
    g_coa_mapping_id                        gl_coa_mappings.coa_mapping_id%TYPE;
    g_balance_statement_request_id          fnd_concurrent_requests.request_id%TYPE;
    g_agglutination_code_source             VARCHAR2(30);
    g_income_statement_request_id           fnd_concurrent_requests.request_id%TYPE;
    g_journal_for_rtf                       NUMBER;
    g_hash_code                             VARCHAR2(200); -- auxillary book
    g_acct_stmt_ident                       VARCHAR2(200);
    g_acct_stmt_header                      VARCHAR2(200);
    g_gen_sped_text_file                    VARCHAR2(3);

    g_inscription_source                    VARCHAR2(50);
    g_le_state_reg_code                     VARCHAR2(100);
    g_le_municipal_reg_code                  VARCHAR2(100);
    g_state_tax_id                        VARCHAR2(100);
    g_ebtax_state_reg_code                  VARCHAR2(100);
    g_municipal_reg_tax_id                 VARCHAR2(100);
    g_ebtax_municipal_reg_code               VARCHAR2(100);

    --Globals for other values

  g_company_name              VARCHAR2(250);
  g_segment_attribute_type    fnd_segment_attribute_values.segment_attribute_type%TYPE;
  g_bsv_segment               fnd_segment_attribute_values.application_column_name%TYPE;
  g_account_segment           fnd_segment_attribute_values.application_column_name%TYPE;
  g_cost_center_segment       fnd_segment_attribute_values.application_column_name%TYPE;

  g_period_set_name           gl_sets_of_books.period_set_name%TYPE;
  g_accounted_period_type     gl_sets_of_books.accounted_period_type%TYPE;
  g_currency_code             gl_sets_of_books.currency_code%TYPE;
  g_account_value_set_id      fnd_id_flex_segments.flex_value_set_id%TYPE;
  g_cost_center_value_set_id  fnd_id_flex_segments.flex_value_set_id%TYPE;

  g_balance_statement_report_id           rg_reports.report_id%TYPE;
  g_income_statement_report_id            rg_reports.report_id%TYPE;

  g_ar_auxbook_exist      number;
  g_ap_auxbook_exist      number;
  g_ap_ar_auxbook_exist   number;

  g_account_qualifier_position    NUMBER;
  g_sped_qualifier_position       NUMBER;
  g_closing_period_flag           VARCHAR2(1);
  g_adjustment_period_name        GL_PERIODS.PERIOD_NAME%TYPE;
  g_adjustment_period_start_date  GL_PERIODS.START_DATE%TYPE;
  g_adjustment_period_end_date    GL_PERIODS.END_DATE%TYPE;

    --Globals for Conc Prg variables

    g_concurrent_request_id      NUMBER;
    g_created_by                 NUMBER(15);
    g_creation_date              DATE;
    g_last_updated_by            NUMBER(15);
    g_last_update_date           DATE;
    g_last_update_login          NUMBER(15);


  -- Globals  for log

  g_current_runtime_level     CONSTANT  NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_level_statement           CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure           CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event               CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected          CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_level_error                     CONSTANT  NUMBER  := FND_LOG.LEVEL_ERROR;
  g_level_exception           CONSTANT  NUMBER  := FND_LOG.LEVEL_EXCEPTION;
  g_error_buffer              VARCHAR2(100);
  g_debug_flag                VARCHAR2(1);
  g_pkg_name                    CONSTANT VARCHAR2(30) := 'JL_BR_SPED_DATA_EXTRACT';
  g_module_name               CONSTANT VARCHAR2(30) := 'JL_SPED';
  g_errbuf                    VARCHAR2(2000);
  g_retcode                   NUMBER;


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
		  p_inscription_source_dummy      varchar2,
                  p_inscription_source_dummy1     varchar2,
		  p_le_state_reg_code             VARCHAR2,
		  p_le_municipal_reg_code          VARCHAR2,
		  p_state_tax_id                  NUMBER,
		  p_ebtax_state_reg_code          VARCHAR2,
		  p_municipal_reg_tax_id           NUMBER,
		  p_ebtax_municipal_reg_code       VARCHAR2,
		  p_gen_sped_text_file            VARCHAR2) ;
    FUNCTION get_segment_value(ccid NUMBER,segment_code VARCHAR2) RETURN VARCHAR2;
    FUNCTION get_account_type(p_flex_Value_id  fnd_flex_values.flex_value_id%TYPE) RETURN VARCHAR2;
    FUNCTION get_participant_code (p_je_header_id gl_je_headers.je_header_id%TYPE,
                               p_je_line_num gl_je_lines.je_line_num%TYPE,
                               p_journal_source gl_je_headers.je_source%TYPE,
                               p_je_line_ccid gl_je_lines.code_combination_id%TYPE,
                               p_third_party_id NUMBER,
                               p_third_party_site_id NUMBER) RETURN VARCHAR2;

END JL_BR_SPED_DATA_EXTRACT_PKG;



/
