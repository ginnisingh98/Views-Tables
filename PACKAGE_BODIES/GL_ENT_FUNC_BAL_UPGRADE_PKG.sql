--------------------------------------------------------
--  DDL for Package Body GL_ENT_FUNC_BAL_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ENT_FUNC_BAL_UPGRADE_PKG" AS
/* $Header: gluefbub.pls 120.4 2006/11/19 10:17:23 ticheng noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api  CONSTANT VARCHAR2(40) := 'gl.plsql.GL_ENT_FUNC_BAL_UPGRADE_PKG';

  g_std_bal_table CONSTANT VARCHAR2(30) := 'GL_BALANCES';
  g_adb_bal_table CONSTANT VARCHAR2(30) := 'GL_DAILY_BALANCES';
  g_mm_std_table  CONSTANT VARCHAR2(30) := 'GL_MOVEMERGE_BAL_';
  g_mm_adb_table  CONSTANT VARCHAR2(30) := 'GL_MOVEMERGE_DAILY_BAL_';

  g_table_name    CONSTANT VARCHAR2(30) := 'GL_CODE_COMBINATIONS';
  g_id_column     CONSTANT VARCHAR2(30) := 'CODE_COMBINATION_ID';
  g_script_name   CONSTANT VARCHAR2(30) := 'gluefbub.pls';

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   prepare_std_bal_gt
  -- Purpose
  --   Insert data into the standard balances GT, gl_efb_upgrade_std.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_BALANCES
  --                  or GL_MOVEMERGE_BAL_<req_id>
  --   x_start_id     Start id for AD parallel range, gl_balances upgrade only
  --   x_end_id       End id for AD parallel range, gl_balances upgrade only
  --
  PROCEDURE prepare_std_bal_gt(x_src_table   VARCHAR2,
                               x_start_id    NUMBER DEFAULT NULL,
                               x_end_id      NUMBER DEFAULT NULL) IS
    fn_name       CONSTANT VARCHAR2(30) := 'PREPARE_STD_BAL_GT';
    StdInterimInsertStr    VARCHAR2(2200);
    ccid_range             VARCHAR2(100);
    hint_txt               VARCHAR2(500);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);

    IF (x_src_table = g_std_bal_table) THEN
      ccid_range :=
        'AND   b1.code_combination_id between :start_id and :end_id ';
      hint_txt := '/*+ ORDERED INDEX(b1 gl_balances_n1) ' ||
                      'INDEX(p1 gl_period_statuses_u3) ' ||
                      'INDEX(ps gl_period_statuses_u4) */ ';
    ELSE
      ccid_range := '';
      hint_txt := '';
    END IF;

    StdInterimInsertStr :=
    'INSERT INTO gl_efb_upgrade_std ' ||
    '(ledger_id, code_combination_id, currency_code,' ||
    ' period_name, actual_flag, translated_flag,' ||
    ' period_net_dr_beq, period_net_cr_beq,' ||
    ' quarter_to_date_dr_beq, quarter_to_date_cr_beq,' ||
    ' begin_balance_dr_beq, begin_balance_cr_beq,' ||
    ' project_to_date_dr_beq, project_to_date_cr_beq,' ||
    ' template_id) '||
    'SELECT ' || hint_txt ||
    'b1.ledger_id, b1.code_combination_id, b1.currency_code, ' ||
    'ps.period_name, b1.actual_flag, b1.translated_flag, ' ||
    'sum(decode(b1.period_name, ps.period_name, b1.period_net_dr_beq,0)), ' ||
    'sum(decode(b1.period_name, ps.period_name, b1.period_net_cr_beq,0)), ' ||
    'sum(decode(p1.period_year, ps.period_year, ' ||
    '           decode(p1.quarter_num, ps.quarter_num, ' ||
    '                  decode(p1.period_num, ps.period_num, 0, ' ||
    '                         b1.period_net_dr_beq),0),0)), ' ||
    'sum(decode(p1.period_year, ps.period_year, ' ||
    '           decode(p1.quarter_num, ps.quarter_num, ' ||
    '                  decode(p1.period_num, ps.period_num, 0, ' ||
    '                         b1.period_net_cr_beq),0),0)), ' ||
    'sum(decode(b1.period_name, ps.period_name, b1.begin_balance_dr_beq,0)),'||
    'sum(decode(b1.period_name, ps.period_name, b1.begin_balance_cr_beq,0)),'||
    'sum(decode(p1.period_year, ps.period_year, ' ||
    '           decode(p1.period_num, ps.period_num, 0, ' ||
    '                  b1.period_net_dr_beq), b1.period_net_dr_beq)), ' ||
    'sum(decode(p1.period_year, ps.period_year, ' ||
    '           decode(p1.period_num, ps.period_num, 0, ' ||
    '                  b1.period_net_cr_beq), b1.period_net_cr_beq)), ' ||
    'b1.template_id ' ||
    'FROM ' || x_src_table ||
    ' b1, gl_period_statuses p1, gl_period_statuses ps ' ||
    'WHERE b1.actual_flag = ''A'' ' ||
    'AND   b1.currency_code <> ''STAT'' ' ||
    'AND   b1.translated_flag = ''R'' ' ||
    ccid_range ||
    'AND   ps.ledger_id = b1.ledger_id ' ||
    'AND   ps.application_id = 101 ' ||
    'AND   ps.closing_status not in (''N'', ''F'') ' ||
    'AND   p1.effective_period_num <= ps.effective_period_num ' ||
    'AND   p1.ledger_id = b1.ledger_id ' ||
    'AND   p1.application_id = 101 ' ||
    'AND   p1.period_name = b1.period_name ' ||
    'GROUP BY b1.ledger_id, b1.code_combination_id,b1.currency_code, ' ||
    '      b1.actual_flag, b1.translated_flag, b1.template_id, ps.period_name';

    IF (x_src_table = g_std_bal_table) THEN
      EXECUTE IMMEDIATE StdInterimInsertStr USING x_start_id, x_end_id;
    ELSE
      EXECUTE IMMEDIATE StdInterimInsertStr;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END prepare_std_bal_gt;


  --
  -- Procedure
  --   update_std_foreign_ent_bal
  -- Purpose
  --   Update the QTD and PJTD BEQ columns for foreign entered balances.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_BALANCES
  --                  or GL_MOVEMERGE_BAL_<req_id>
  --   x_start_id     Start id for AD parallel range, gl_balances upgrade only
  --   x_end_id       End id for AD parallel range, gl_balances upgrade only
  --
  PROCEDURE update_std_foreign_ent_bal(x_src_table   VARCHAR2,
                                       x_start_id    NUMBER DEFAULT NULL,
                                       x_end_id      NUMBER DEFAULT NULL) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPDATE_STD_FOREIGN_ENT_BAL';
    StdUpdateFrgnEntBalStr VARCHAR2(1000);
    bal_where_clause       VARCHAR2(200);
    hint_txt               VARCHAR2(500);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);

    IF (x_src_table = g_std_bal_table) THEN
      bal_where_clause :=
        'AND   b1.code_combination_id between :start_id and :end_id ' ||
        'AND  (b1.code_combination_id, b1.period_name) in ' ||
        '     (select code_combination_id, period_name ' ||
        '      from gl_efb_upgrade_std) ';
      hint_txt := '/*+ INDEX(b1 gl_balances_n1) */';
    ELSE
      bal_where_clause := '';
      hint_txt := '';
    END IF;

    StdUpdateFrgnEntBalStr :=
      'UPDATE ' || x_src_table || ' b1 ' ||
      'SET (b1.quarter_to_date_dr_beq, b1.quarter_to_date_cr_beq, ' ||
      '     b1.project_to_date_dr_beq, b1.project_to_date_cr_beq) ' ||
      '  = (select /*+ INDEX (b2 gl_efb_upgrade_std_n1 ) */ b2.quarter_to_date_dr_beq, b2.quarter_to_date_cr_beq, ' ||
      '            b2.project_to_date_dr_beq, b2.project_to_date_cr_beq ' ||
      '     from gl_efb_upgrade_std b2 ' ||
      '     where b2.ledger_id = b1.ledger_id ' ||
      '     and   b2.code_combination_id = b1.code_combination_id ' ||
      '     and   b2.currency_code = b1.currency_code ' ||
      '     and   b2.period_name = b1.period_name ' ||
      '     and   b2.actual_flag = ''A'' ' ||
      '     and   b2.translated_flag = ''R'') ' ||
      'WHERE b1.translated_flag = ''R'' ' ||
      'AND   b1.actual_flag = ''A'' ' ||
      bal_where_clause;

    IF (x_src_table = g_std_bal_table) THEN
      EXECUTE IMMEDIATE StdUpdateFrgnEntBalStr USING x_start_id, x_end_id;
    ELSE
      EXECUTE IMMEDIATE StdUpdateFrgnEntBalStr;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END update_std_foreign_ent_bal;


  --
  -- Procedure
  --   update_std_func_ent_bal
  -- Purpose
  --   Update all 8 BEQ columns for functional entered balances.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_BALANCES
  --                  or GL_MOVEMERGE_BAL_<req_id>
  --   x_start_id     Start id for AD parallel range, gl_balances upgrade only
  --   x_end_id       End id for AD parallel range, gl_balances upgrade only
  --
  PROCEDURE update_std_func_ent_bal(x_src_table   VARCHAR2,
                                    x_start_id    NUMBER DEFAULT NULL,
                                    x_end_id      NUMBER DEFAULT NULL) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPDATE_STD_FUNC_ENT_BAL';
    StdUpdateFuncEntBalStr VARCHAR2(1400);
    ccid_range             VARCHAR2(100);
    hint_txt               VARCHAR2(500);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);

    IF (x_src_table = g_std_bal_table) THEN
      ccid_range :=
        'AND   b1.code_combination_id between :start_id and :end_id ';
      hint_txt := '/*+ INDEX(b1 gl_balances_n1) */';
    ELSE
      ccid_range := '';
      hint_txt := '';
    END IF;

    StdUpdateFuncEntBalStr :=
      'UPDATE ' || hint_txt || x_src_table || ' b1 ' ||
      'SET (b1.period_net_dr_beq, b1.period_net_cr_beq, ' ||
      '     b1.begin_balance_dr_beq, b1.begin_balance_cr_beq, ' ||
      '     b1.quarter_to_date_dr_beq, b1.quarter_to_date_cr_beq, ' ||
      '     b1.project_to_date_dr_beq, b1.project_to_date_cr_beq) ' ||
      '  = (select /*+ INDEX (b2 gl_efb_upgrade_std_n1 ) */ ' ||
      '     (b1.period_net_dr - nvl(sum(b2.period_net_dr_beq),0)), ' ||
      '     (b1.period_net_cr - nvl(sum(b2.period_net_cr_beq),0)), ' ||
      '     (b1.begin_balance_dr - nvl(sum(b2.begin_balance_dr_beq),0)), ' ||
      '     (b1.begin_balance_cr - nvl(sum(b2.begin_balance_cr_beq),0)), ' ||
      '     (b1.quarter_to_date_dr - nvl(sum(b2.quarter_to_date_dr_beq),0)),'||
      '     (b1.quarter_to_date_cr - nvl(sum(b2.quarter_to_date_cr_beq),0)),'||
      '     (b1.project_to_date_dr - nvl(sum(b2.project_to_date_dr_beq),0)),'||
      '     (b1.project_to_date_cr - nvl(sum(b2.project_to_date_cr_beq),0)) '||
      '     from gl_efb_upgrade_std b2 ' ||
      '     where b2.period_name = b1.period_name ' ||
      '     and   b2.ledger_id = b1.ledger_id ' ||
      '     and   b2.actual_flag = ''A'' ' ||
      '     and   b2.translated_flag = ''R'' ' ||
      '     and   b2.code_combination_id = b1.code_combination_id) ' ||
      'WHERE b1.currency_code <> ''STAT'' ' ||
      'AND   b1.actual_flag = ''A'' ' ||
      ccid_range ||
      'AND   b1.translated_flag IS NULL ' ||
      'AND   b1.currency_code = ' ||
      '      (select currency_code ' ||
      '       from gl_ledgers ' ||
      '       where ledger_id = b1.ledger_id)';

    IF (x_src_table = g_std_bal_table) THEN
      EXECUTE IMMEDIATE StdUpdateFuncEntBalStr USING x_start_id, x_end_id;
    ELSE
      EXECUTE IMMEDIATE StdUpdateFuncEntBalStr;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END update_std_func_ent_bal;


  --
  -- Procedure
  --   prepare_adb_bal_gt
  -- Purpose
  --   Insert data into the ADB balances GT, gl_efb_upgrade_adb.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_DAILY_BALANCES
  --                  or GL_MOVEMERGE_DAILY_BAL_<req_id>
  --   x_start_id     Start id for AD parallel range, gl_daily_balances only
  --   x_end_id       End id for AD parallel range, gl_daily_balances only
  --
  PROCEDURE prepare_adb_bal_gt(x_src_table   VARCHAR2,
                               x_start_id    NUMBER DEFAULT NULL,
                               x_end_id      NUMBER DEFAULT NULL) IS
    fn_name       CONSTANT VARCHAR2(30) := 'PREPARE_ADB_BAL_GT';
    AdbInterimInsertStr    VARCHAR2(8000);
    ccid_range             VARCHAR2(100);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);

    IF (x_src_table = g_adb_bal_table) THEN
      ccid_range :=
        'AND   b1.code_combination_id between :start_id and :end_id ';
    ELSE
      ccid_range := '';
    END IF;

    AdbInterimInsertStr :=
      'INSERT INTO gl_efb_upgrade_adb ' ||
      '(ledger_id, code_combination_id, currency_code,' ||
      ' period_name, period_start_date, period_end_date,' ||
      ' quarter_start_date, year_start_date,'||
      ' period_type, period_year, period_num, template_id,' ||
      ' opening_period_aggregate,' ||
      ' opening_quarter_aggregate,' ||
      ' opening_year_aggregate,' ||
      ' period_aggregate1, period_aggregate2, period_aggregate3,'||
      ' period_aggregate4, period_aggregate5, period_aggregate6,' ||
      ' period_aggregate7, period_aggregate8, period_aggregate9,' ||
      ' period_aggregate10, period_aggregate11, period_aggregate12,' ||
      ' period_aggregate13, period_aggregate14, period_aggregate15,' ||
      ' period_aggregate16, period_aggregate17, period_aggregate18,' ||
      ' period_aggregate19, period_aggregate20, period_aggregate21,' ||
      ' period_aggregate22, period_aggregate23, period_aggregate24,' ||
      ' period_aggregate25, period_aggregate26, period_aggregate27,' ||
      ' period_aggregate28, period_aggregate29, period_aggregate30,' ||
      ' period_aggregate31, period_aggregate32, period_aggregate33,' ||
      ' period_aggregate34, period_aggregate35) ' ||
      'SELECT ' ||
      'b1.ledger_id, b1.code_combination_id, max(ldg.currency_code), ' ||
      'b1.period_name, max(b1.period_start_date), max(b1.period_end_date), ' ||
      'max(b1.quarter_start_date), max(b1.year_start_date), ' ||
      'max(b1.period_type), max(b1.period_year), max(b1.period_num), ' ||
      'b1.template_id, ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.opening_period_aggregate,' ||
      '                  ''C'', -b1.opening_period_aggregate,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.opening_quarter_aggregate,' ||
      '                  ''C'', -b1.opening_quarter_aggregate,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.opening_year_aggregate,'||
      '                  ''C'', -b1.opening_year_aggregate,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate1,' ||
      '                  ''C'', -b1.period_aggregate1,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate2,' ||
      '                  ''C'', -b1.period_aggregate2,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate3,' ||
      '                  ''C'', -b1.period_aggregate3,0),0)),  ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate4,' ||
      '                  ''C'', -b1.period_aggregate4,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate5,' ||
      '                  ''C'', -b1.period_aggregate5,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate6,' ||
      '                  ''C'', -b1.period_aggregate6,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate7,' ||
      '                  ''C'', -b1.period_aggregate7,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate8,' ||
      '                  ''C'', -b1.period_aggregate8,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate9,' ||
      '                  ''C'', -b1.period_aggregate9,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate10,' ||
      '                  ''C'', -b1.period_aggregate10,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate11,' ||
      '                  ''C'', -b1.period_aggregate11,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate12,' ||
      '                  ''C'', -b1.period_aggregate12,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate13,' ||
      '                  ''C'', -b1.period_aggregate13,0),0)),  ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate14,' ||
      '                  ''C'', -b1.period_aggregate14,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate15,' ||
      '                  ''C'', -b1.period_aggregate15,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate16,' ||
      '                  ''C'', -b1.period_aggregate16,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate17,' ||
      '                  ''C'', -b1.period_aggregate17,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate18,' ||
      '                  ''C'', -b1.period_aggregate18,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate19,' ||
      '                  ''C'', -b1.period_aggregate19,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate20,' ||
      '                  ''C'', -b1.period_aggregate20,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate21,' ||
      '                  ''C'', -b1.period_aggregate21,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate22,' ||
      '                  ''C'', -b1.period_aggregate22,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate23,' ||
      '                  ''C'', -b1.period_aggregate23,0),0)),  ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate24,' ||
      '                  ''C'', -b1.period_aggregate24,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate25,' ||
      '                  ''C'', -b1.period_aggregate25,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate26,' ||
      '                  ''C'', -b1.period_aggregate26,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate27,' ||
      '                  ''C'', -b1.period_aggregate27,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate28,' ||
      '                  ''C'', -b1.period_aggregate28,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate29,' ||
      '                  ''C'', -b1.period_aggregate29,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate30,' ||
      '                  ''C'', -b1.period_aggregate30,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate31,' ||
      '                  ''C'', -b1.period_aggregate31,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate32,' ||
      '                  ''C'', -b1.period_aggregate32,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate33,' ||
      '                  ''C'', -b1.period_aggregate33,0),0)),  ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate34,' ||
      '                  ''C'', -b1.period_aggregate34,0),0)), ' ||
      'sum(decode(b1.currency_code, ldg.currency_code,' ||
      '           decode(b1.currency_type, ''U'', b1.period_aggregate35,' ||
      '                  ''C'', -b1.period_aggregate35,0),0)) ' ||
      'FROM ' || x_src_table || ' b1, gl_ledgers ldg ' ||
      'WHERE ldg.ledger_id = b1.ledger_id ' ||
      'AND   ldg.currency_code = b1.currency_code ' ||
      'AND   ldg.enable_average_balances_flag = ''Y'' ' ||
      'AND   b1.actual_flag = ''A'' ' ||
      ccid_range ||
      'GROUP BY b1.ledger_id, b1.code_combination_id, ' ||
      '          b1.period_name, b1.template_id';

    IF (x_src_table = g_adb_bal_table) THEN
      EXECUTE IMMEDIATE AdbInterimInsertStr USING x_start_id, x_end_id;
    ELSE
      EXECUTE IMMEDIATE AdbInterimInsertStr;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END prepare_adb_bal_gt;


  --
  -- Procedure
  --   update_adb_func_ent_bal
  -- Purpose
  --   Update existing functional entered balances.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_DAILY_BALANCES
  --                  or GL_MOVEMERGE_DAILY_BAL_<req_id>
  --   x_start_id     Start id for AD parallel range, gl_daily_balances only
  --   x_end_id       End id for AD parallel range, gl_daily_balances only
  --
  PROCEDURE update_adb_func_ent_bal(x_src_table   VARCHAR2,
                                    x_start_id    NUMBER DEFAULT NULL,
                                    x_end_id      NUMBER DEFAULT NULL) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPDATE_ADB_FUNC_ENT_BAL';
    AdbUpdateFuncEntBalStr VARCHAR2(2600);
    ccid_range             VARCHAR2(200);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);

    IF (x_src_table = g_adb_bal_table) THEN
      ccid_range :=
        'AND   b1.code_combination_id between :start_id and :end_id ';
    ELSE
      ccid_range := '';
    END IF;

    AdbUpdateFuncEntBalStr :=
      'UPDATE ' || x_src_table || ' b1 ' ||
      'SET (b1.opening_period_aggregate,'||
      '     b1.opening_quarter_aggregate,' ||
      '     b1.opening_year_aggregate,' ||
      '     b1.period_aggregate1, b1.period_aggregate2,' ||
      '     b1.period_aggregate3, b1.period_aggregate4,' ||
      '     b1.period_aggregate5, b1.period_aggregate6,' ||
      '     b1.period_aggregate7, b1.period_aggregate8,' ||
      '     b1.period_aggregate9, b1.period_aggregate10,' ||
      '     b1.period_aggregate11, b1.period_aggregate12,' ||
      '     b1.period_aggregate13, b1.period_aggregate14,' ||
      '     b1.period_aggregate15, b1.period_aggregate16,' ||
      '     b1.period_aggregate17, b1.period_aggregate18,' ||
      '     b1.period_aggregate19, b1.period_aggregate20,' ||
      '     b1.period_aggregate21, b1.period_aggregate22,' ||
      '     b1.period_aggregate23, b1.period_aggregate24,' ||
      '     b1.period_aggregate25, b1.period_aggregate26,' ||
      '     b1.period_aggregate27, b1.period_aggregate28,' ||
      '     b1.period_aggregate29, b1.period_aggregate30,' ||
      '     b1.period_aggregate31, b1.period_aggregate32,' ||
      '     b1.period_aggregate33, b1.period_aggregate34,' ||
      '     b1.period_aggregate35) ' ||
      ' = (SELECT '||
      '    di.opening_period_aggregate,' ||
      '    di.opening_quarter_aggregate,' ||
      '    di.opening_year_aggregate,' ||
      '    di.period_aggregate1, di.period_aggregate2,' ||
      '    di.period_aggregate3, di.period_aggregate4,' ||
      '    di.period_aggregate5, di.period_aggregate6,' ||
      '    di.period_aggregate7, di.period_aggregate8,' ||
      '    di.period_aggregate9, di.period_aggregate10,' ||
      '    di.period_aggregate11, di.period_aggregate12,' ||
      '    di.period_aggregate13, di.period_aggregate14,' ||
      '    di.period_aggregate15, di.period_aggregate16,' ||
      '    di.period_aggregate17, di.period_aggregate18,' ||
      '    di.period_aggregate19, di.period_aggregate20,' ||
      '    di.period_aggregate21, di.period_aggregate22,' ||
      '    di.period_aggregate23, di.period_aggregate24,' ||
      '    di.period_aggregate25, di.period_aggregate26,' ||
      '    di.period_aggregate27, di.period_aggregate28,' ||
      '    di.period_aggregate29, di.period_aggregate30,' ||
      '    di.period_aggregate31, di.period_aggregate32,' ||
      '    di.period_aggregate33, di.period_aggregate34,' ||
      '    di.period_aggregate35' ||
      '    FROM gl_efb_upgrade_adb di' ||
      '    WHERE di.ledger_id = b1.ledger_id' ||
      '    AND   di.code_combination_id = b1.code_combination_id' ||
      '    AND   di.currency_code = b1.currency_code' ||
      '    AND   di.period_name = b1.period_name) ' ||
      'WHERE b1.currency_code = ' ||
      '      (select currency_code' ||
      '       from gl_ledgers' ||
      '       where ledger_id = b1.ledger_id) ' ||
      'AND   b1.actual_flag = ''A'' ' ||
      'AND   b1.currency_type = ''E'' ' ||
      'AND   b1.converted_from_currency IS NULL ' ||
      ccid_range;

    IF (x_src_table = g_adb_bal_table) THEN
      EXECUTE IMMEDIATE AdbUpdateFuncEntBalStr USING x_start_id, x_end_id;
    ELSE
      EXECUTE IMMEDIATE AdbUpdateFuncEntBalStr;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END update_adb_func_ent_bal;


  --
  -- Procedure
  --   insert_adb_func_ent_bal
  -- Purpose
  --   Insert missing functional entered balances.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_src_table    Source table of the balances, either GL_DAILY_BALANCES
  --                  or GL_MOVEMERGE_DAILY_BAL_<req_id>
  --
  PROCEDURE insert_adb_func_ent_bal(x_src_table   VARCHAR2) IS
    fn_name       CONSTANT VARCHAR2(30) := 'INSERT_ADB_FUNC_ENT_BAL';
    AdbInsertFuncEntBalStr VARCHAR2(2800);

    l_who_cols             VARCHAR2(150);
    l_who_vals             VARCHAR2(30);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || x_src_table);

    IF (x_src_table = g_adb_bal_table) THEN
      l_who_cols := ' creation_date, created_by, last_update_date,' ||
                    ' last_updated_by, last_update_login,';
      l_who_vals := '   sysdate, 1, sysdate, 1, 0,';
    ELSE
      l_who_cols := '';
      l_who_vals := '';
    END IF;

    AdbInsertFuncEntBalStr :=
      'INSERT INTO ' || x_src_table || ' ' ||
      '(ledger_id, code_combination_id, currency_code,' ||
      ' currency_type, actual_flag, period_name,' ||
      ' period_start_date, period_end_date,' ||
      ' quarter_start_date, year_start_date,' ||
      l_who_cols ||
      ' converted_from_currency, period_type, period_year,' ||
      ' period_num, template_id,' ||
      ' opening_period_aggregate,' ||
      ' opening_quarter_aggregate,' ||
      ' opening_year_aggregate,' ||
      ' period_aggregate1, period_aggregate2, period_aggregate3,'||
      ' period_aggregate4, period_aggregate5, period_aggregate6,' ||
      ' period_aggregate7, period_aggregate8, period_aggregate9,' ||
      ' period_aggregate10, period_aggregate11, period_aggregate12,' ||
      ' period_aggregate13, period_aggregate14, period_aggregate15,' ||
      ' period_aggregate16, period_aggregate17, period_aggregate18,' ||
      ' period_aggregate19, period_aggregate20, period_aggregate21,' ||
      ' period_aggregate22, period_aggregate23, period_aggregate24,' ||
      ' period_aggregate25, period_aggregate26, period_aggregate27,' ||
      ' period_aggregate28, period_aggregate29, period_aggregate30,' ||
      ' period_aggregate31, period_aggregate32, period_aggregate33,' ||
      ' period_aggregate34, period_aggregate35) ' ||
      'SELECT ' ||
      ' di.ledger_id, di.code_combination_id, di.currency_code,' ||
      ' ''E'', ''A'', di.period_name,' ||
      ' di.period_start_date, di.period_end_date,' ||
      ' di.quarter_start_date, di.year_start_date,' ||
      l_who_vals ||
      ' NULL, di.period_type, di.period_year,' ||
      ' di.period_num, di.template_id,' ||
      ' di.opening_period_aggregate,' ||
      ' di.opening_quarter_aggregate,' ||
      ' di.opening_year_aggregate,' ||
      ' di.period_aggregate1, di.period_aggregate2, di.period_aggregate3,' ||
      ' di.period_aggregate4, di.period_aggregate5, di.period_aggregate6,' ||
      ' di.period_aggregate7, di.period_aggregate8, di.period_aggregate9,' ||
      ' di.period_aggregate10, di.period_aggregate11, di.period_aggregate12,'||
      ' di.period_aggregate13, di.period_aggregate14, di.period_aggregate15,'||
      ' di.period_aggregate16, di.period_aggregate17, di.period_aggregate18,'||
      ' di.period_aggregate19, di.period_aggregate20, di.period_aggregate21,'||
      ' di.period_aggregate22, di.period_aggregate23, di.period_aggregate24,'||
      ' di.period_aggregate25, di.period_aggregate26, di.period_aggregate27,'||
      ' di.period_aggregate28, di.period_aggregate29, di.period_aggregate30,'||
      ' di.period_aggregate31, di.period_aggregate32, di.period_aggregate33,'||
      ' di.period_aggregate34, di.period_aggregate35 ' ||
      'FROM gl_efb_upgrade_adb di ' ||
      'WHERE not exists' ||
      '     (select 1' ||
      '      from ' || x_src_table || ' b2' ||
      '      where b2.ledger_id = di.ledger_id' ||
      '      and   b2.code_combination_id = di.code_combination_id' ||
      '      and   b2.currency_code = di.currency_code' ||
      '      and   b2.currency_type = ''E''' ||
      '      and   b2.actual_flag = ''A''' ||
      '      and   b2.period_name = di.period_name' ||
      '      and   b2.converted_from_currency is null)';

    EXECUTE IMMEDIATE AdbInsertFuncEntBalStr;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END insert_adb_func_ent_bal;


  --
  -- Procedure
  --   check_mm_table_column
  -- Purpose
  --   Check if the given move/merge table name exists, and if it has
  --   a set_of_books_id column.
  -- History
  --   03/11/2005   T Cheng      Created
  -- Arguments
  --   x_gl_schema      GL schema
  --   x_table_name     Movemerge interim table name
  --   x_table_exists   If the given table exists
  --   x_column_exists  If a set_of_books_id column exists in the table.
  --                    Default to false if table does not exist.
  --
  PROCEDURE check_mm_table_column(x_gl_schema                 VARCHAR2,
                                  x_table_name                VARCHAR2,
                                  x_table_exists   OUT NOCOPY BOOLEAN,
                                  x_column_exists  OUT NOCOPY BOOLEAN) IS
    fn_name       CONSTANT VARCHAR2(30) := 'CHECK_MM_TABLE_COLUMN';
    l_table_exists         NUMBER := 0;
    l_column_exists        NUMBER := 0;
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_gl_schema = ' || x_gl_schema);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_table_name = ' || x_table_name);

    x_table_exists  := FALSE;
    x_column_exists := FALSE;

    -- check if table exists
    SELECT nvl(max(1), 0)
    INTO   l_table_exists
    FROM   DBA_TABLES
    WHERE  table_name = x_table_name
    AND    owner = x_gl_schema;

    IF (l_table_exists = 1) THEN
      x_table_exists := TRUE;

      -- check if the table was created in 11i with set_of_books_id column
      SELECT nvl(max(1), 0)
      INTO   l_column_exists
      FROM   ALL_TAB_COLUMNS
      WHERE  table_name = x_table_name
      AND    owner = x_gl_schema
      AND    column_name = 'SET_OF_BOOKS_ID';

      IF (l_column_exists = 1) THEN
        x_column_exists := TRUE;
      END IF;
    END IF;

    -- out parameters (print the local variables)
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'l_table_exists = ' || l_table_exists);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'l_column_exists = ' || l_column_exists);
    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END check_mm_table_column;

  --
  -- Procedure
  --   alter_movemerge_tables
  -- Purpose
  --   Add new columns to the move/merge interim tables for the given request.
  -- History
  --   03/11/2005   T Cheng      Created
  -- Arguments
  --   x_mm_request_id  Move/Merge request ID
  --   x_gl_schema      GL schema
  --   x_applsys_schema FND schema
  --
  PROCEDURE alter_movemerge_tables(x_mm_request_id             NUMBER,
                                   x_gl_schema                 VARCHAR2,
                                   x_applsys_schema            VARCHAR2,
                                   x_std_tab_exists OUT NOCOPY BOOLEAN,
                                   x_adb_tab_exists OUT NOCOPY BOOLEAN) IS
    fn_name       CONSTANT VARCHAR2(30) := 'ALTER_MOVEMERGE_TABLES';
    l_table_name           VARCHAR2(30);
    l_column_exists        BOOLEAN;

    sql_stmt               VARCHAR2(200);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_mm_request_id = ' || x_mm_request_id);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_gl_schema = ' || x_gl_schema);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_applsys_schema = ' || x_applsys_schema);

    -- upgrade standard balances table
    l_table_name := g_mm_std_table || x_mm_request_id;

    check_mm_table_column(x_gl_schema, l_table_name,
                          x_std_tab_exists, l_column_exists);
    IF (l_column_exists) THEN
      -- rename set_books_id column to ledger_id
      sql_stmt := 'ALTER TABLE ' || l_table_name ||
                  ' RENAME COLUMN set_of_books_id TO ledger_id';

      AD_DDL.DO_DDL(x_applsys_schema, 'SQLGL', AD_DDL.ALTER_TABLE,
                    sql_stmt, l_table_name);

      -- add four BEQ columns
      sql_stmt := 'ALTER TABLE ' || l_table_name || ' ADD ' ||
                  '(QUARTER_TO_DATE_DR_BEQ NUMBER,' ||
                  ' QUARTER_TO_DATE_CR_BEQ NUMBER,' ||
                  ' PROJECT_TO_DATE_DR_BEQ NUMBER,' ||
                  ' PROJECT_TO_DATE_CR_BEQ NUMBER)';

      AD_DDL.DO_DDL(x_applsys_schema, 'SQLGL', AD_DDL.ALTER_TABLE,
                    sql_stmt, l_table_name);
    END IF;

    -- upgrade ADB balances table
    l_table_name := g_mm_adb_table || x_mm_request_id;

    check_mm_table_column(x_gl_schema, l_table_name,
                          x_adb_tab_exists, l_column_exists);
    IF (l_column_exists) THEN
      -- rename set_books_id column to ledger_id
      sql_stmt := 'ALTER TABLE ' || l_table_name ||
                  ' RENAME COLUMN set_of_books_id TO ledger_id';

      AD_DDL.DO_DDL(x_applsys_schema, 'SQLGL', AD_DDL.ALTER_TABLE,
                    sql_stmt, l_table_name);
    END IF;

    -- dummy commit, to make sure the rollback segment will be set
    FND_CONCURRENT.AF_COMMIT;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END alter_movemerge_tables;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE upgrade_ent_func_bal(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_num_workers             NUMBER) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPGRADE_ENT_FUNC_BAL';
    SUBMIT_REQ_ERROR       EXCEPTION;

    l_req_data          VARCHAR2(10);
    l_req_id            NUMBER;

    l_efb_upgrade_flag  VARCHAR2(1);

    l_retstatus         BOOLEAN;
    l_status            VARCHAR2(30);
    l_industry          VARCHAR2(30);
    l_table_owner       VARCHAR2(30);
    l_gl_schema         VARCHAR2(30);
    l_applsys_schema    VARCHAR2(30);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_batch_size = ' || x_batch_size);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_num_workers = ' || x_num_workers);

    -- AD_CONC_UTILS_PKG.submit_subrequests sets request data
    l_req_data := FND_CONC_GLOBAL.request_data;

    IF (l_req_data IS NULL) THEN  -- First time
      -- if the balances upgrade were done, no need to submit requests
      SELECT efb_upgrade_flag
      INTO   l_efb_upgrade_flag
      FROM   GL_SYSTEM_USAGES
      WHERE  rownum = 1;

      IF (l_efb_upgrade_flag <> 'Y') THEN
        -- get schema name for GL and FND
        l_retstatus := fnd_installation.get_app_info(
                            'SQLGL', l_status, l_industry, l_gl_schema);
        IF (   (NOT l_retstatus)
            OR (l_gl_schema is null)) THEN
          raise_application_error(-20001,
               'Cannot get schema name for product : SQLGL');
        END IF;

        l_retstatus := fnd_installation.get_app_info(
                            'FND', l_status, l_industry, l_applsys_schema);
        IF (   (NOT l_retstatus)
            OR (l_applsys_schema is null)) THEN
          raise_application_error(-20001,
               'Cannot get schema name for product : FND');
        END IF;

        -- Submit one child request for move/merge
        l_req_id := FND_REQUEST.submit_request(
                      APPLICATION    => 'SQLGL',
                      PROGRAM        => 'GLEFBMM',
                      SUB_REQUEST    => TRUE,
                      ARGUMENT1      => l_gl_schema,
                      ARGUMENT2      => l_applsys_schema);

        IF (l_req_id = 0) THEN
          RAISE SUBMIT_REQ_ERROR;
        END IF;

        -- Clean up AD update information in case number of workers changed
        -- Note: this procedure implicitly commits
        AD_PARALLEL_UPDATES_PKG.delete_update_information(
                    ad_parallel_updates_pkg.ID_RANGE,
                    l_gl_schema,
                    g_table_name,
                    g_script_name);

        -- Submit child requests to upgrade balances
        AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                    => x_errbuf,
               X_retcode                   => x_retcode,
               X_workerconc_app_shortname  => 'SQLGL',
               X_workerconc_progname       => 'GLEFBAL',
               X_batch_size                => x_batch_size,
               -- One worker is used for the move/merge request
               X_num_workers               => x_num_workers - 1,
               X_argument4                 => l_gl_schema);

        -- If the request data hasn't been set, then the AD API did not
        -- successfully submit all child requests.
        l_req_data := FND_CONC_GLOBAL.request_data;
        IF (l_req_data IS NULL) THEN
          RAISE SUBMIT_REQ_ERROR;
        END IF;

      ELSE
        GL_MESSAGE.WRITE_LOG(msg_name  => 'EFCB0001',
                             log_level => FND_LOG.LEVEL_PROCEDURE,
                             module    => g_api || '.' || fn_name);
        x_retcode := AD_CONC_UTILS_PKG.CONC_WARNING;
      END IF;

    ELSE  -- Restart case
      -- check status of all subrequests (including the move/merge one, since
      -- the program is not really used for a restart)
      -- * If we want to produce an execution report, it may be more effecient
      --   not to use the API since that would mean we are getting
      --   sub-requests and loop through them twice.

      AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                    => x_errbuf,
               X_retcode                   => x_retcode,
               -- for restart, the rest of the parameters are not really used
               X_workerconc_app_shortname  => 'SQLGL',
               X_workerconc_progname       => 'GLEFBAL',
               X_batch_size                => x_batch_size,
               X_num_workers               => x_num_workers - 1,
               X_argument4                 => l_gl_schema);

      IF (x_retcode = AD_CONC_UTILS_PKG.CONC_SUCCESS) THEN
        UPDATE GL_SYSTEM_USAGES
        SET    efb_upgrade_flag = 'Y',
               last_update_date = sysdate,
               last_updated_by = 1,
               last_update_login = 0;
      END IF;
    END IF;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN SUBMIT_REQ_ERROR THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      GL_MESSAGE.WRITE_LOG(msg_name  => 'SHRD0055',
                           token_num => 1,
                           t1        => 'ROUTINE',
                           v1        => fn_name,
                           log_level => FND_LOG.LEVEL_PROCEDURE,
                           module    => g_api || '.' || fn_name);
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
    WHEN OTHERS THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END upgrade_ent_func_bal;


  PROCEDURE upgrade_balance_tables(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_worker_Id               NUMBER,
                  x_num_workers             NUMBER,
                  x_argument4               VARCHAR2) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPGRADE_BALANCE_TABLES';

    l_any_rows_to_process  BOOLEAN;

    l_start_id             NUMBER;
    l_end_id               NUMBER;
    l_rows_processed       NUMBER;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Worker_Id   : ' || X_Worker_Id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : ' || X_Num_Workers);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Session Id    : ' ||
                                    FND_GLOBAL.session_id);

    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_batch_size = ' || x_batch_size);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_argument4 = ' || x_argument4);

    ad_parallel_updates_pkg.initialize_id_range(
                    ad_parallel_updates_pkg.ID_RANGE,
                    x_argument4,
                    g_table_name,
                    g_script_name,
                    g_id_column,
                    x_worker_id,
                    x_num_workers,
                    x_batch_size, 0);

    ad_parallel_updates_pkg.get_id_range(
                    l_start_id,
                    l_end_id,
                    l_any_rows_to_process,
                    x_batch_size,
                    TRUE);

    while (l_any_rows_to_process)
    loop
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_start_id : ' || l_start_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_end_id   : ' || l_end_id);

      prepare_std_bal_gt(g_std_bal_table, l_start_id, l_end_id);
      update_std_foreign_ent_bal(g_std_bal_table, l_start_id, l_end_id);
      update_std_func_ent_bal(g_std_bal_table, l_start_id, l_end_id);

      prepare_adb_bal_gt(g_adb_bal_table, l_start_id, l_end_id);
      update_adb_func_ent_bal(g_adb_bal_table, l_start_id, l_end_id);
      insert_adb_func_ent_bal(g_adb_bal_table);

      SELECT count(*)
      INTO   l_rows_processed
      FROM   gl_code_combinations
      WHERE  code_combination_id between l_start_id and l_end_id;

      ad_parallel_updates_pkg.processed_id_range(
                  l_rows_processed,
                  l_end_id);

      fnd_concurrent.af_commit;

      ad_parallel_updates_pkg.get_id_range(
                 l_start_id,
                 l_end_id,
                 l_any_rows_to_process,
                 x_batch_size,
                 FALSE);

    end loop;

    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_errbuf := SUBSTR(SQLERRM, 1, 240);
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END upgrade_balance_tables;


  PROCEDURE upgrade_movemerge_int_tables(
                  x_errbuf         OUT NOCOPY VARCHAR2,
                  x_retcode        OUT NOCOPY VARCHAR2,
                  x_gl_schema                 VARCHAR2,
                  x_applsys_schema            VARCHAR2) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPGRADE_MOVEMERGE_INT_TABLES';

    l_last_purged_eff_period_num NUMBER;
    l_std_table_exists           BOOLEAN;
    l_adb_table_exists           BOOLEAN;

    l_table_name                 VARCHAR2(30);
    sql_stmt                     VARCHAR2(200);

    CURSOR c_ledgers IS
      SELECT ledger_id
      FROM   GL_LEDGERS
      WHERE  object_type_code = 'L';

    -- requests that have completed move/merge successfully
    CURSOR c_mm_requests(v_ledger_id NUMBER) IS
      SELECT movemerge_request_id mm_req_id
      FROM   gl_movemerge_requests
      WHERE  ledger_id = v_ledger_id
      AND    status_code = 'MC';
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_gl_schema = ' || x_gl_schema);
    GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_applsys_schema = ' || x_applsys_schema);

    FOR rec IN c_ledgers LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'ledger_id : ' || rec.ledger_id);

      -- get latest purged period for the ledger
      SELECT NVL(MAX(last_purged_eff_period_num), 0)
      INTO   l_last_purged_eff_period_num
      FROM   GL_ARCHIVE_HISTORY
      WHERE  ledger_id = rec.ledger_id
      AND    actual_flag = 'A'
      AND    data_type = 'A';

      FOR req IN c_mm_requests(rec.ledger_id) LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'mm_req_id : ' || req.mm_req_id);

        -- data model changes
        alter_movemerge_tables(req.mm_req_id, x_gl_schema, x_applsys_schema,
                               l_std_table_exists, l_adb_table_exists);
        -- data upgrades:
        -- always delete data for purged periods first, then upgrade data
        IF (l_std_table_exists) THEN
          l_table_name := g_mm_std_table || req.mm_req_id;
          sql_stmt := 'DELETE FROM ' || l_table_name ||
                      ' WHERE (PERIOD_YEAR * 10000 + PERIOD_NUM) <= :p_num' ||
                      ' AND ACTUAL_FLAG = ''A'' ';
          EXECUTE IMMEDIATE sql_stmt USING l_last_purged_eff_period_num;

          prepare_std_bal_gt(l_table_name);
          update_std_foreign_ent_bal(l_table_name);
          update_std_func_ent_bal(l_table_name);
        END IF;

        IF (l_adb_table_exists) THEN
          l_table_name := g_mm_adb_table || req.mm_req_id;
          sql_stmt := 'DELETE FROM ' || l_table_name ||
                      ' WHERE (PERIOD_YEAR * 10000 + PERIOD_NUM) <= :p_num' ||
                      ' AND ACTUAL_FLAG = ''A'' ';
          EXECUTE IMMEDIATE sql_stmt USING l_last_purged_eff_period_num;

          prepare_adb_bal_gt(l_table_name);
          update_adb_func_ent_bal(l_table_name);
          insert_adb_func_ent_bal(l_table_name);
        END IF;

        FND_CONCURRENT.AF_COMMIT;
      END LOOP;
    END LOOP;

    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

    GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_errbuf := SUBSTR(SQLERRM, 1, 240);
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
      GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      RAISE;
  END upgrade_movemerge_int_tables;

END GL_ENT_FUNC_BAL_UPGRADE_PKG;

/
