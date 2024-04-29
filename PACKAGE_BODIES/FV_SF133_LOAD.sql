--------------------------------------------------------
--  DDL for Package Body FV_SF133_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SF133_LOAD" AS
--$Header: FVXBEGLB.pls 120.7 2003/12/17 21:21:33 ksriniva ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) := 'fv.plsql.fv_sf133_load.';

--
--
  g_set_of_books_id                  NUMBER;
  g_load_accounts                  VARCHAR2(01);
--
-- ---------- End of Package Level Declaritives -----------------------------
-- --------------------------------------------------------------------------
PROCEDURE a000_load_tables
         (errbuf            OUT NOCOPY VARCHAR2,
          retcode           OUT NOCOPY   NUMBER,
	  set_of_books_id   IN    NUMBER,
          load_accounts     IN  VARCHAR2)
--
IS
  l_module_name VARCHAR2(200) := g_module_name || 'a000_load_tables';
--
-- ------------------------------------
-- Work Variables
-- ------------------------------------
  v_boolean                         BOOLEAN;
  v_flex_field_nbr                   NUMBER;
  v_segment_number                   NUMBER;
  v_segment_app_name               VARCHAR2(40);
  v_segment_prompt                 VARCHAR2(25);
  v_segment_value_set_name         VARCHAR2(40);
--
  v_account_segment_name           VARCHAR2(25);
--
  invalid_segment_returned        EXCEPTION;
--
BEGIN
-- ------------------------------------
  retcode           := 0;
  g_set_of_books_id := set_of_books_id;
  g_load_accounts   := UPPER(load_accounts);
--
-- ------------------------------------
-- Clear and Load SF133 Line Definitions
-- ------------------------------------
  DELETE
    FROM fv_sf133_definitions_lines
   WHERE set_of_books_id = g_set_of_books_id;
--

  INSERT
    INTO fv_sf133_definitions_lines
        (sf133_line_id,
         set_of_books_id,
         sf133_line_number,
         sf133_line_label,
         sf133_line_type_code,
	   sf133_goals_line_number,
	   sf133_report_line_number,
         sf133_natural_balance_type,
         sf133_fund_category,
         created_by,
         creation_date,
     	 last_updated_by,
     	 last_update_date,
     	 last_update_login)
     SELECT fv_sf133_line_id_s.NEXTVAL,
            g_set_of_books_id,
            load.sf133_line_number,
            load.sf133_line_label,
            load.sf133_line_type_code,
		load.sf133_goals_line_number,
		load.sf133_report_line_number,
            load.sf133_natural_balance_type,
            load.sf133_fund_category,
            0,
            SYSDATE,
            0,
            SYSDATE,
            0
       FROM fv_sf133_load_lines load;
--
-- ------------------------------------
-- Clear and Load SF133 Line Accounts
-- ------------------------------------
  DELETE
    FROM fv_sf133_definitions_accts
   WHERE (sf133_line_id)
             IN
         (SELECT set_of_books_id
            FROM fv_sf133_definitions_lines
           WHERE g_set_of_books_id = set_of_books_id);
--
  IF g_load_accounts = 'Y' THEN
-- ------------------------------------
-- Determine Account Segment Name
-- ------------------------------------
    SELECT chart_of_accounts_id
      INTO v_flex_field_nbr
      FROM gl_sets_of_books
     WHERE set_of_books_id = g_set_of_books_id;
--
    v_boolean := FND_FLEX_APIS.GET_SEGMENT_COLUMN(101,
                                                    'GL#',
                                                    v_flex_field_nbr,
                                                    'GL_ACCOUNT',
                                                    v_account_segment_name);
    IF (v_boolean) THEN
-- ------------------------------------
-- Load Account Codes for Set of Books
-- ------------------------------------
      v_account_segment_name := UPPER(v_account_segment_name);
--
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- ');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- SET OF BOOKS ID ('||G_SET_OF_BOOKS_ID||')'
                      ||' Account Segment ('||v_account_segment_name||')');
      END IF;
--
      INSERT
        INTO fv_sf133_definitions_accts
            (sf133_line_acct_id,
             sf133_line_id,
             sf133_balance_type,
             sf133_additional_info,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             segment1,
             segment2,
             segment3,
             segment4,
             segment5,
             segment6,
             segment7,
             segment8,
             segment9,
             segment10,
             segment11,
             segment12,
             segment13,
             segment14,
             segment15,
             segment16,
             segment17,
             segment18,
             segment19,
             segment20,
             segment21,
             segment22,
             segment23,
             segment24,
             segment25,
             segment26,
             segment27,
             segment28,
             segment29,
             segment30)
      SELECT fv_sf133_line_acct_id_s.NEXTVAL,
             line.sf133_line_id,
      	     load.sf133_balance_type,
	     load.sf133_additional_info,
             0,
             SYSDATE,
             0,
             SYSDATE,
             0,
             decode(v_account_segment_name,
                       'SEGMENT1',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT2',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT3',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT4',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT5',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT6',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT7',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT8',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT9',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT10',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT11',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT12',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT13',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT14',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT15',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT16',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT17',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT18',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT19',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT20',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT21',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT22',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT23',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT24',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT25',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT26',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT27',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT28',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT29',load.sf133_line_account, NULL),
             decode(v_account_segment_name,
                       'SEGMENT30',load.sf133_line_account, NULL)
        FROM fv_sf133_definitions_lines line,
             fv_sf133_load_accts        load
       WHERE line.sf133_line_number = load.sf133_line_number
         AND line.set_of_books_id   = g_set_of_books_id;
    END IF;
--
  END IF;
--
-- ------------------------------------
-- Exception Processing
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := 2;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

--
END a000_load_tables;
--
END fv_sf133_load;
-- ==========================================================================

/
