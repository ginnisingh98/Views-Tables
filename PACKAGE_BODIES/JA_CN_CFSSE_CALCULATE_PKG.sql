--------------------------------------------------------
--  DDL for Package Body JA_CN_CFSSE_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFSSE_CALCULATE_PKG" AS
  --$Header: JACNCSCB.pls 120.2.12010000.2 2008/10/28 06:26:06 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCSCB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to implement calculation for main part of    |
  --|       cash flow statement                                             |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE  Populate_LastYear_Period_Names                        |
  --|      PROCEDURE  Generate_Cfs_Xml                                      |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/22/2006     Jackey Li          Created
  --|      22/09/2008     Chaoqun Wu         Updated for CNAO Enhancement   |
  --|      14/10/2008     Chaoqun Wu         Fix bug# 7481478
  --+======================================================================*/

  --TYPE G_PERIOD_NAME_TBL IS TABLE OF gl_periods.period_name%TYPE INDEX BY BINARY_INTEGER;

  --==== Golbal Variables ============
  g_module_name VARCHAR2(30) := 'JA_CN_CFSSE_CALCULATE_PKG';
  g_dbg_level   NUMBER := FND_LOG.G_Current_Runtime_Level;
  g_proc_level  NUMBER := FND_LOG.Level_Procedure;
  g_stmt_level  NUMBER := FND_LOG.Level_Statement;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Populate_LastYear_Period_Names          Private
  --
  --  DESCRIPTION:
  --        It is to retrieve period names through the whole last year
  --            depends on the parameter 'p_period_name'.
  --
  --  PARAMETERS:
  --      In: p_le_id                     legal entity ID
  --          p_period_name               period name
  --          x_period_names              period names as G_PERIOD_NAME_TBL type
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/22/2006      Jackey Li          Created
  --===========================================================================
  PROCEDURE Populate_LastYear_Period_Names(p_ledger_id IN NUMBER
                                          ,p_period_name   IN VARCHAR2
                                          ,x_period_names  OUT NOCOPY JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL) IS

    l_procedure_name       VARCHAR2(30) := 'Populate_LastYear_Period_Names';
    l_ledger_id            gl_ledgers.ledger_id %TYPE := p_ledger_id;--updated by lyb
    l_period_set_name      gl_periods.period_set_name%TYPE;
    l_period_type          gl_periods.period_type%TYPE;
    l_period_name          gl_periods.period_name%TYPE := p_period_name;
    l_cur_period_year      gl_periods.period_year%TYPE;
    l_last_period_year     gl_periods.period_year%TYPE;
    l_lastyear_period_name gl_periods.period_name%TYPE;

    l_period_idx   NUMBER;
    l_period_names JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;

    -- this cursor is
      CURSOR c_period_set
      IS
      SELECT
        period_set_name
       ,accounted_period_type
      FROM
        gl_ledgers
      WHERE ledger_id=l_ledger_id;

    -- this cursor is
    CURSOR c_cur_period_year IS
      SELECT period_year
        FROM gl_periods
       WHERE period_set_name = l_period_set_name
         AND period_name = l_period_name;

    -- this cursor is
    CURSOR c_lastyear_period_names IS
      SELECT period_name
        FROM gl_periods
       WHERE period_set_name = l_period_set_name
         AND period_year = l_last_period_year
         AND period_type = l_period_type;

  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    --To Get current period set name and period type per gl set of book
    OPEN c_period_set;
    FETCH c_period_set
      INTO l_period_set_name, l_period_type;
    CLOSE c_period_set;

    --To retrive set of period names according to parameters period_name and period_type

    --Get current period year  by the parameter period_name
    OPEN c_cur_period_year;
    FETCH c_cur_period_year
      INTO l_cur_period_year;
    CLOSE c_cur_period_year;

    l_last_period_year := l_cur_period_year - 1;
    l_period_idx       := 0;

    OPEN c_lastyear_period_names;
    FETCH c_lastyear_period_names
      INTO l_lastyear_period_name;
    WHILE c_lastyear_period_names%FOUND
    LOOP
      l_period_idx := l_period_idx + 1;
      l_period_names(l_period_idx) := l_lastyear_period_name;
      FETCH c_lastyear_period_names
        INTO l_lastyear_period_name;
    END LOOP; -- WHILE c_lastyear_period_names%FOUND

    --FND_FILE.Put_Line(FND_FILE.LOG,
    --                  'LastYear Period amount = ' || to_char(l_period_idx));
    x_period_names := l_period_names;

    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || l_procedure_name ||
                       '.OTHER_EXCEPTION',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      RAISE;

  END Populate_LastYear_Period_Names;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Generate_Cfs_Xml                  Public
  --
  --  DESCRIPTION:
  --        It is to generate xml output for main part of cash flow statement
  --            for small enterprise by following format of FSG xml output.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           legal entity ID
  --          p_set_of_bks_id             set of books ID
  --          p_period_name               period name
  --          p_axis_set_id               axis set id
  --          p_rounding_option           rounding option
  --          p_balance_type              balance type
  --          p_internal_trx_flag         is intercompany transactions
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/22/2006      Jackey Li          Created
  --      22/09/2008      Chaoqun Wu         Updated for CNAO Enhancement
  --      14/10/2008      Chaoqun Wu         Fix bug# 7481478
  --===========================================================================
PROCEDURE Generate_Cfs_Xml(p_legal_entity_id   IN NUMBER
                          ,p_ledger_id         IN NUMBER--updated by lyb
                          ,p_period_name       IN VARCHAR2
                          ,p_axis_set_id       IN NUMBER
                          ,p_rounding_option   IN VARCHAR2
                          ,p_balance_type      IN VARCHAR2
                         -- ,p_internal_trx_flag IN VARCHAR2
                          ,p_coa               IN NUMBER
                          ,p_segment_override  IN VARCHAR2 --Added for CNAO Enhancement
                           ) IS --added by lyb
  l_coa                      Number              :=p_coa;--added by lyb
  l_segment_override         VARCHAR2(100)       :=p_segment_override;  --addded for CNAO Enhancement
  l_procedure_name           VARCHAR2(30) := 'Generate_Cfs_Xml';
  l_thousands_separator_flag VARCHAR2(1);
  l_format_mask              VARCHAR2(100);
  l_final_display_format     VARCHAR2(30);
  l_legal_entity_id          NUMBER := p_legal_entity_id;
 -- l_set_of_bks_id            gl_sets_of_books.set_of_books_id%TYPE := p_set_of_bks_id;
  l_ledger_id                 gl_ledgers.ledger_id%TYPE    :=p_ledger_id;
  l_func_currency_code        fnd_currencies.currency_code%TYPE;
  l_period_name              gl_periods.period_name%TYPE := p_period_name;
  l_axis_set_id              rg_report_axis_sets.axis_set_id%TYPE := p_axis_set_id;
  l_rounding_option          VARCHAR2(50) := p_rounding_option;
  l_balance_type             VARCHAR2(50) := p_balance_type;
  --l_internal_trx_flag        VARCHAR2(1) := p_internal_trx_flag;
  l_period_names             JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;
  l_lastyear_period_names    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;
  l_axis_seq                 rg_report_axes.axis_seq%TYPE;
  l_type                     VARCHAR2(1);
  l_calculation_flag         VARCHAR2(1);
  l_display_zero_amount_flag VARCHAR2(1);
  l_change_sign_flag         VARCHAR2(1);
  l_display_format           VARCHAR2(30);
  l_amount                   NUMBER;
  l_amount_display           VARCHAR2(40);
  l_last_year_amount         NUMBER;
  l_last_year_amount_display VARCHAR2(40);
  l_row_count                NUMBER;

  l_rowcnt  VARCHAR2(50);
  l_lincnt  VARCHAR2(50);
  l_colcnt1 VARCHAR2(50) := 'c1001';
  l_colcnt2 VARCHAR2(50) := 'c1002';
  l_rptcnt  VARCHAR2(50) := 'p1001';

  l_xml_output_row  XMLTYPE;
  l_xml_output      XMLTYPE;
  l_xml_output_root XMLTYPE;

  l_operator  VARCHAR2(10);
  l_operand   VARCHAR2(500);
  l_operands1 VARCHAR2(4000);
  l_operands2 VARCHAR2(4000);
  l_formula   VARCHAR2(4000);

  l_cal_lincnt    VARCHAR2(50);
  l_error_message VARCHAR2(4000);

  -- this cursor is
  CURSOR c_axis_seq IS
    SELECT axis_seq
      FROM ja_cn_cfs_row_cgs_gt
     WHERE axis_set_id = l_axis_set_id
       AND display_flag = 'Y'
     ORDER BY axis_seq
       FOR UPDATE;

  -- this cursor is
  CURSOR c_rows IS
    SELECT axis_seq
          ,TYPE
          ,calculation_flag
          ,display_zero_amount_flag
          ,change_sign_flag
          ,display_format
          ,amount
          ,last_year_amount
          ,rowcnt
          ,lincnt
      FROM ja_cn_cfs_row_cgs_gt
     WHERE axis_set_id = l_axis_set_id
       AND display_flag = 'Y'
     ORDER BY axis_seq;

  -- this cursor is
  CURSOR c_calculation_lines(pc_axis_seg rg_report_axes.axis_seq%TYPE) IS
    SELECT jcccg.operator
          ,jccrcg.lincnt
          ,jccrcg.change_sign_flag
      FROM ja_cn_cfs_calculations_gt jcccg
          ,ja_cn_cfs_row_cgs_gt      jccrcg
     WHERE jcccg.axis_set_id = l_axis_set_id
       AND jcccg.axis_seq = pc_axis_seg
       AND jcccg.axis_set_id = jccrcg.axis_set_id
       AND jcccg.cal_axis_seq = jccrcg.axis_seq
     ORDER BY jcccg.calculation_seq;

BEGIN
  --log for debug
  IF (g_proc_level >= g_dbg_level)
  THEN
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name || '.begin',
                   'begin procedure');
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_legal_entity_id is',
                   p_legal_entity_id);
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_ledger_id is',
                   p_ledger_id);
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_period_name is',
                   p_period_name);
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_axis_set_id is',
                   p_axis_set_id);
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_rounding_option is',
                   p_rounding_option);
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_balance_type is',
                   p_balance_type);

    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.p_coa',
                   p_coa);

    FND_LOG.STRING(g_proc_level,                --Added for CNAO Enhancement
                   g_module_name || '.' ||  l_segment_override ||
                   '.p_segment_override',
                   p_segment_override);
  END IF; --( g_proc_level >= g_dbg_level)

  --To get value of the profile 'CURRENCY: Thousands Separator' to decide if
  --it is need to export throusands separator for amount.
  l_thousands_separator_flag := fnd_profile.VALUE(NAME => 'CURRENCY:THOUSANDS_SEPARATOR');

  --To get format mask for functional currency
  --updated by lyb
  SELECT
    currency_code
  INTO
    l_func_currency_code
  FROM
    gl_ledgers
  WHERE
    ledger_id=l_ledger_id ;

  l_format_mask := FND_CURRENCY.Get_Format_Mask(currency_code => l_func_currency_code,
                                                field_length  => 30);

  --Fix bug# 7481478 added begin
  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Populate_Fomula' to popluate most detailed
  --calculation lines for FSG row with calculation.
  JA_CN_CFS_CALCULATE_PKG.Populate_Formula(p_coa              =>p_coa
                                          ,p_axis_set_id      =>l_axis_set_id
                                          );
  --Fix bug# 7481478 added end

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Categorize_Rows start');
  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Categorize_Rows' to categorize FSG row
  JA_CN_CFS_CALCULATE_PKG.Categorize_Rows(p_coa             => p_coa,
                                          p_axis_set_id     => l_axis_set_id);

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Categorize_Rows end');

  --log for debug
  IF (g_stmt_level >= g_dbg_level)
  THEN
    FND_LOG.STRING(g_stmt_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.call JA_CN_CFS_CALCULATE_PKG.Categorize_Rows',
                   'Successfully');
  END IF; --( g_stmt_level >= g_dbg_level)

  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Populate_Period_Names'
  -- to populate qualified period names by 'period name' and
  -- 'balance type' for calculation
  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Populate_Period_Names start');
  JA_CN_CFS_CALCULATE_PKG.Populate_Period_Names(p_ledger_id     =>l_ledger_id,--updated by lyb
                                                p_period_name   => l_period_name,
                                                p_balance_type  => l_balance_type,
                                                x_period_names  => l_period_names);
  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Populate_Period_Names end');

  --log for debug
  IF (g_stmt_level >= g_dbg_level)
  THEN
    FND_LOG.STRING(g_stmt_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.call JA_CN_CFS_CALCULATE_PKG.Populate_Period_Names',
                   'Successfully');
  END IF; --( g_stmt_level >= g_dbg_level)

  --Call the procedure 'JA_CN_CFSSE_CALCULATE_PKG.Populate_LastYear_Period_Names'
  -- to populate qualified period names belonging to last fiscal year
  -- by 'period name' for calculation
  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Populate_LastYear_Period_Names start');
  JA_CN_CFSSE_CALCULATE_PKG.Populate_LastYear_Period_Names(p_ledger_id => l_ledger_id,--updted by lyb
                                                           p_period_name   => l_period_name,
                                                           x_period_names  => l_lastyear_period_names);

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Populate_LastYear_Period_Names end');

  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Calculate_Rows_Amount' to
  --calculate amount for items in the main part of Cash Flow Statement
  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Calculate_Rows_Amount start');
  JA_CN_CFS_CALCULATE_PKG.Calculate_Rows_Amount(p_legal_entity_id         => l_legal_entity_id,
                                                p_ledger_id               => l_ledger_id,--updated by lyb
                                                p_coa                     => l_coa,
                                                p_axis_set_id             => l_axis_set_id,
                                                p_period_names            => l_period_names,
                                                p_lastyear_period_names   => l_lastyear_period_names,
                                                p_rounding_option         => l_rounding_option,
                                                p_segment_override        =>l_segment_override ); --added for CNAO Enhancement
                                              --  p_internal_trx_flag     => l_internal_trx_flag


  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'Calculate_Rows_Amount end');

  --log for debug
  IF (g_stmt_level >= g_dbg_level)
  THEN
    FND_LOG.STRING(g_stmt_level,
                   g_module_name || '.' || l_procedure_name ||
                   '.call JA_CN_CFS_CALCULATE_PKG.Calculate_Rows_Amount',
                   'Successfully');
  END IF; --( g_stmt_level >= g_dbg_level)

  --To populate row count and line count for each row in the rowset <l_axis_set_id>
  l_row_count := 0;

  FOR rec_axis_seq IN c_axis_seq
  LOOP
    --To number the row
    l_row_count := l_row_count + 1;

    --To populate rowcount and linecount for output xml like FSG
    l_rowcnt := 'r1' || lpad(to_char(l_row_count),
                             5,
                             '0');
    l_lincnt := 'l1' || lpad(to_char(l_row_count),
                             5,
                             '0');

    --Update current row with row count and line count
    UPDATE ja_cn_cfs_row_cgs_gt
       SET rowcnt = l_rowcnt,
           lincnt = l_lincnt
     WHERE CURRENT OF c_axis_seq;

  END LOOP;

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'update row number');

  --Retrive all rows which display_flag is 'Y' and belong to rowset 'l_rowset_id' from
  --the table JA_CN_CFS_ROW_CGS_gt by cursor c_rows in ascending order of axis_seq
  FOR rec_rows IN c_rows
  LOOP

    --log for debug
    IF (g_stmt_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_stmt_level,
                     g_module_name || '.' || l_procedure_name ||
                     '.operate each row',
                     rec_rows.TYPE);
    END IF; --( g_stmt_level >= g_dbg_level)

    --If the type of current row is 'F', then the row is a item in the
    --subsidiary part of cash flow statement,it will not be handle the
    --by this program, just skip it
    IF rec_rows.TYPE = 'F'
    THEN
      NULL;

      --If the type of current row is 'C', then the row is a item in the
      --main part of cash flow statment, it would be exported in FSG xml
      --output format
    ELSIF rec_rows.TYPE = 'C'
    THEN
      --To judge if output zero for the row or not
      IF rec_rows.display_zero_amount_flag = 'N'
      THEN
        IF NVL(rec_rows.amount,
               0) = 0
        THEN
          rec_rows.amount := '';
        END IF;

        IF NVL(rec_rows.last_year_amount,
               0) = 0
        THEN
          rec_rows.last_year_amount := '';
        END IF;

      ELSE
        --To change sign for the amount if need
        IF rec_rows.change_sign_flag = 'Y'
        THEN
          rec_rows.amount           := nvl(rec_rows.amount,
                                           0) * -1;
          rec_rows.last_year_amount := nvl(rec_rows.last_year_amount,
                                           0) * -1;
        END IF; --l_change_sign_flag='Y'

        --To apply format_mask to amount if any
        IF rec_rows.display_format IS NOT NULL
        THEN
          SELECT to_char(nvl(rec_rows.amount,
                             0),
                         'FM' || to_char(rec_rows.display_format,
                                         l_format_mask))
            INTO l_amount_display
            FROM dual;

          SELECT to_char(nvl(rec_rows.last_year_amount,
                             0),
                         'FM' || to_char(rec_rows.display_format,
                                         l_format_mask))
            INTO l_last_year_amount_display
            FROM dual;

        ELSE
          SELECT to_char(nvl(rec_rows.amount,
                             0),
                         l_format_mask)
            INTO l_amount_display
            FROM dual;

          SELECT to_char(nvl(rec_rows.last_year_amount,
                             0),
                         l_format_mask)
            INTO l_last_year_amount_display
            FROM dual;
        END IF; -- rec_rows.display_format IS NOT NULL

      END IF; --l_display_zero_amount_flag='N' AND NVL(l_amount,0)=0

      --To generate xml output for current row
      SELECT XMLELEMENT("fsggRptLine",
                        XMLATTRIBUTES(l_rptcnt AS "RptCnt",
                                      rec_rows.rowcnt AS "RowCnt",
                                      rec_rows.lincnt AS "LinCnt"),
                        XMLELEMENT("fsggRptCell",
                                   XMLATTRIBUTES(l_colcnt1 AS "ColCnt"),
                                   nvl(l_last_year_amount_display,
                                       0)),
                        XMLELEMENT("fsggRptCell",
                                   XMLATTRIBUTES(l_colcnt2 AS "ColCnt"),
                                   nvl(l_amount_display,
                                       0)))
        INTO l_xml_output_row
        FROM dual;

      --log for debug
      IF (g_stmt_level >= g_dbg_level)
      THEN
        FND_LOG.STRING(g_stmt_level,
                       g_module_name || '.' || l_procedure_name ||
                       '.row detail',
                       l_xml_output_row.getclobval());
      END IF; --( g_stmt_level >= g_dbg_level)

      --To concatenate xml output
      IF l_xml_output IS NULL
      THEN
        l_xml_output := l_xml_output_row;
      ELSE
        SELECT XMLCONCAT(l_xml_output,
                         l_xml_output_row)
          INTO l_xml_output
          FROM dual;
      END IF; --l_xml_output IS NULL

      --If the type of current row is 'M', then the row is calculated by
      --items in both main part and subsidiary part of cash flow statment
      --so export formula for this row in xml and 'Cash Flow Statement - combination'
      --program will perform calcuation for the row.
      --The formula format should be like '<Formula DisplayZero="Y" ChangeSign="N">
      --LinCnt1:ColCnt=+LinCnt2:ColCnt+LinCnt3:ColCnt </Formula>
    ELSIF rec_rows.TYPE = 'M'
    THEN
      --Retrieve calculation lines for current row
      --to Populate formula as requirement of combination

      --Variables initialization
      l_operands1 := '';
      l_operands2 := '';
      l_formula   := '';

      --To populater operands and operaters at right side of '=' in the formula
      FOR rec_calculation_lines IN c_calculation_lines(rec_rows.axis_seq)
      LOOP

        --operator should be generated according to 'Change Sign Flag
        IF rec_calculation_lines.change_sign_flag = 'Y'
        THEN
          SELECT decode(rec_calculation_lines.operator,
                        '+',
                        '-',
                        '-',
                        '+',
                        '+')
            INTO l_operator
            FROM dual;
        ELSE
          l_operator := rec_calculation_lines.operator;
        END IF; --_calculation_lines.change_sign_flag='Y'

        IF l_operands1 IS NULL
        THEN
          l_operands1 := rec_calculation_lines.operator ||
                         rec_calculation_lines.lincnt || ':' || l_colcnt1;
        ELSE
          l_operands1 := l_operands1 || rec_calculation_lines.operator ||
                         rec_calculation_lines.lincnt || ':' || l_colcnt1;
        END IF; --l_operands1 IS NULL

        IF l_operands2 IS NULL
        THEN
          l_operands2 := rec_calculation_lines.operator ||
                         rec_calculation_lines.lincnt || ':' || l_colcnt2;
        ELSE
          l_operands2 := l_operands2 || rec_calculation_lines.operator ||
                         rec_calculation_lines.lincnt || ':' || l_colcnt2;
        END IF; --l_operands2 IS NULL

      END LOOP; --For rec_calculation_lines

      --To populate final display format
      IF rec_rows.display_format IS NOT NULL
      THEN
        SELECT 'FM' || to_char(rec_rows.display_format,
                               l_format_mask)
          INTO l_final_display_format
          FROM dual;
      ELSE
        l_final_display_format := l_format_mask;
      END IF; --l_display_format IS NOT NULL

      --To populate final formula for last year amount
      l_formula := rec_rows.lincnt || ':' || l_colcnt1 || '=' ||
                   l_operands1;

      --To generate xml output that contains formula for currrent row
      SELECT XMLELEMENT("Formula",
                        XMLATTRIBUTES(rec_rows.display_zero_amount_flag AS
                                      "DisplayZero",
                                      rec_rows.change_sign_flag AS
                                      "ChangeSign",
                                      l_final_display_format AS
                                      "DisplayFormat"),
                        l_formula)
        INTO l_xml_output_row
        FROM dual;

      --log for debug
      IF (g_stmt_level >= g_dbg_level)
      THEN
        FND_LOG.STRING(g_stmt_level,
                       g_module_name || '.' || l_procedure_name ||
                       '.row detail',
                       l_xml_output_row.getclobval());
      END IF; --( g_stmt_level >= g_dbg_level)

      --To concatenate xml output
      IF l_xml_output IS NULL
      THEN
        l_xml_output := l_xml_output_row;
      ELSE
        SELECT XMLCONCAT(l_xml_output,
                         l_xml_output_row)
          INTO l_xml_output
          FROM dual;
      END IF; --l_xml_output IS NULL

      --To populate final formula for amount
      l_formula := rec_rows.lincnt || ':' || l_colcnt2 || '=' ||
                   l_operands2;

      --To generate xml output that contains formula for currrent row
      SELECT XMLELEMENT("Formula",
                        XMLATTRIBUTES(rec_rows.display_zero_amount_flag AS
                                      "DisplayZero",
                                      rec_rows.change_sign_flag AS
                                      "ChangeSign",
                                      l_final_display_format AS
                                      "DisplayFormat"),
                        l_formula)
        INTO l_xml_output_row
        FROM dual;

      --log for debug
      IF (g_stmt_level >= g_dbg_level)
      THEN
        FND_LOG.STRING(g_stmt_level,
                       g_module_name || '.' || l_procedure_name ||
                       '.row detail',
                       l_xml_output_row.getclobval());
      END IF; --( g_stmt_level >= g_dbg_level)

      --To concatenate xml output
      IF l_xml_output IS NULL
      THEN
        l_xml_output := l_xml_output_row;
      ELSE
        SELECT XMLCONCAT(l_xml_output,
                         l_xml_output_row)
          INTO l_xml_output
          FROM dual;
      END IF; --l_xml_output IS NULL

      --If the type of current row is 'E', then the row is calculated item,but its formual
      --is wrong, so amount of current row cannot be calculated, an error message will be
      --output in xml instead.
    ELSIF rec_rows.TYPE = 'E'
    THEN
      --Get error message from FND message directory
      -- TODO:
      l_error_message := 'wrong fomula exists';

      --To generate xml output for current row
      SELECT XMLELEMENT("fsggRptLine",
                        XMLATTRIBUTES(l_rptcnt AS "RptCnt",
                                      rec_rows.rowcnt AS "RowCnt",
                                      rec_rows.lincnt AS "LinCnt"),
                        XMLELEMENT("fsggRptCell",
                                   XMLATTRIBUTES(l_colcnt1 AS "ColCnt"),
                                   l_error_message),
                        XMLELEMENT("fsggRptCell",
                                   XMLATTRIBUTES(l_colcnt2 AS "ColCnt"),
                                   l_error_message))
        INTO l_xml_output_row
        FROM dual;

      --To concatenate xml output
      IF l_xml_output IS NULL
      THEN
        l_xml_output := l_xml_output_row;
      ELSE
        SELECT XMLCONCAT(l_xml_output,
                         l_xml_output_row)
          INTO l_xml_output
          FROM dual;

      END IF; --l_xml_output IS NULL

    END IF; --l_type='F'

  END LOOP; --for rec_rows

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  'output all rows');

  --To add root node for the xml output
  SELECT XMLELEMENT("MasterReport",
                    XMLATTRIBUTES('http://www.w3.org/2001/XMLSchema-instance' AS
                                  "xmlns:xsi",
                                  'http://www.oracle.com/fsg/2002-03-20/' AS
                                  "xmlns:fsg",
                                  'http://www.oracle.com/2002-03-20/fsg.xsd' AS
                                  "xsi:schemaLocation"),
                    l_xml_output)
    INTO l_xml_output_root
    FROM dual;

  --FND_FILE.Put_Line(FND_FILE.LOG,
  --                  REPLACE(l_xml_output_root.getclobval(),
  --                          'fsgg',
  --                          'fsg:'));

  FND_FILE.Put_Line(FND_FILE.Output,
                    REPLACE(l_xml_output_root.getclobval(),
                            'fsgg',
                            'fsg:'));

  --log for debug
  IF (g_proc_level >= g_dbg_level)
  THEN
    FND_LOG.STRING(g_proc_level,
                   g_module_name || '.' || l_procedure_name || '.end',
                   'end procedure');
  END IF; --( g_proc_level >= g_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level)
    THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     g_module_name || l_procedure_name ||
                     '.OTHER_EXCEPTION',
                     SQLCODE || ':' || SQLERRM);
    END IF;
    RAISE;

END Generate_Cfs_Xml;

END JA_CN_CFSSE_CALCULATE_PKG;

/
