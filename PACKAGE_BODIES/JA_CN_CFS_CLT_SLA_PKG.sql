--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_CLT_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_CLT_SLA_PKG" AS
--$Header: JACNSLAB.pls 120.7.12010000.7 2009/09/29 05:25:26 wuwu ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCDCB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in Collecting CFS Data from SLA              |
  --|     in the CNAO Project.                                              |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Collect_SLA_Data                 PUBLIC                |
  --|      PROCEDURE put_line                         PRIVATE               |
  --|      PROCEDURE put_log                          PRIVATE               |
  --|      FUNCTION  get_period_name                  PUBLIC                |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      23/04/2004  Shujuan Yan       Created                            |
  --|      08/09/2008  Yao Zhang         Fix Bug#7334017 for R12 enhancment |
  --|      09/11/2008  Yao Zhang         Fix bug#7535144                    |
  --|      06/01/2009  Shujuan Yan       Fix bug 8370270,8395396,8395408    |
  --|                                    and 8395411 for AP void and AR     |
  --|                                    reverse and Unclearing             |
  --|      29/09/2009  Chaoqun Wu        Fix bug 8969631 for cancelled      |
  --|                                    payment and reversed receipt.      |
  --+======================================================================*/
  --==========================================================================
  --  PROCEDURE NAME:
  --    Put_Line                     private
  --
  --  DESCRIPTION:
  --      This procedure write data to log file.
  --
  --  PARAMETERS:
  --      In: p_str         VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      23/04/2007     Shujuan Yan         Created
  --===========================================================================
  PROCEDURE put_log(p_module IN VARCHAR2, p_message IN VARCHAR2) AS
  BEGIN
    IF (fnd_log.LEVEL_STATEMENT >= g_debug_devel) THEN
      fnd_log.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
                     MODULE    => p_module,
                     MESSAGE   => p_message);
    END IF;

  END put_log;
  --==========================================================================
  --  PROCEDURE NAME:
  --    Put_Line                     private
  --
  --  DESCRIPTION:
  --      This procedure write data to concurrent output file.
  --
  --  PARAMETERS:
  --      In: p_str         VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      23/04/2007     Shujuan Yan          Created
  --===========================================================================
  PROCEDURE put_line(p_str IN VARCHAR2) AS
  BEGIN
    FND_FILE.Put_Line(FND_FILE.Output, p_str);
  END put_line;
  --==========================================================================
  --  FUNCTION NAME:
  --    get_period_name                     Public
  --
  --  DESCRIPTION:
  --        This FUNCTION is used to get period name from a period set and given date
  --        the period name is month type
  --
  --  PARAMETERS:
  --      In: p_period_set_name            period set name
  --          p_gl_date                    date
  --          p_period_type                period type
  --  return: period name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      23/04/2007     Shujuan Yan          Created
  --===========================================================================
  FUNCTION get_period_name(p_period_set_name IN VARCHAR2,
                           p_gl_date         IN DATE,
                           p_period_type     IN VARCHAR2) RETURN VARCHAR2 AS
    l_period_name VARCHAR2(30);
  BEGIN
    SELECT period_name
      INTO l_period_name
      FROM gl_periods
     WHERE period_set_name = p_period_set_name
       AND start_date <= p_gl_date
       AND End_Date >= p_gl_date
       AND period_type = p_period_type
       AND adjustment_period_flag = 'N';

    RETURN l_period_name;

  END get_period_name;


  -- Fix bug#7334017  add begin
--==========================================================================
--  PROCEDURE NAME:
--    get_balancing_segment                     private
--
--  DESCRIPTION:
--      This procedure returns the balancing segment value of a CCID.
--
--  PARAMETERS:
--      In: P_CC_ID         NUMBER
--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    03/09/2008     Yao Zhang         Created
--===========================================================================
FUNCTION get_balancing_segment
( P_CC_ID               IN        NUMBER
)
RETURN VARCHAR2
IS
L_BALANCING_SEGMENT GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
BEGIN
  SELECT
    DECODE(FSAV.APPLICATION_COLUMN_NAME, --segment FSAV.APPLICATION_COLUMN_NAME of gcc
                      'SEGMENT1',GCC.SEGMENT1, 'SEGMENT2',GCC.SEGMENT2, 'SEGMENT3',GCC.SEGMENT3,
                      'SEGMENT4',GCC.SEGMENT4, 'SEGMENT5',GCC.SEGMENT5, 'SEGMENT6',GCC.SEGMENT6,
                      'SEGMENT7',GCC.SEGMENT7, 'SEGMENT8',GCC.SEGMENT8, 'SEGMENT9',GCC.SEGMENT9,
                      'SEGMENT10',GCC.SEGMENT10, 'SEGMENT11',GCC.SEGMENT11, 'SEGMENT12',GCC.SEGMENT12,
                      'SEGMENT13',GCC.SEGMENT13, 'SEGMENT14',GCC.SEGMENT14, 'SEGMENT15',GCC.SEGMENT15,
                      'SEGMENT16',GCC.SEGMENT16, 'SEGMENT17',GCC.SEGMENT17, 'SEGMENT18',GCC.SEGMENT18,
                      'SEGMENT19',GCC.SEGMENT19, 'SEGMENT20',GCC.SEGMENT20, 'SEGMENT21',GCC.SEGMENT21,
                      'SEGMENT22',GCC.SEGMENT22, 'SEGMENT23',GCC.SEGMENT23, 'SEGMENT24',GCC.SEGMENT24,
                      'SEGMENT25',GCC.SEGMENT25, 'SEGMENT26',GCC.SEGMENT26, 'SEGMENT27',GCC.SEGMENT27,
                      'SEGMENT28',GCC.SEGMENT28, 'SEGMENT29',GCC.SEGMENT29, 'SEGMENT30',GCC.SEGMENT30)
      INTO L_BALANCING_SEGMENT
    FROM GL_CODE_COMBINATIONS GCC,
         FND_SEGMENT_ATTRIBUTE_VALUES FSAV
   WHERE GCC.CODE_COMBINATION_ID = P_CC_ID
     AND FSAV.ATTRIBUTE_VALUE = 'Y'
     AND FSAV.APPLICATION_ID = 101
     AND FSAV.ID_FLEX_CODE = 'GL#'--Fix bug#7334017  add
     AND FSAV.SEGMENT_ATTRIBUTE_TYPE = 'GL_BALANCING'
     AND FSAV.ID_FLEX_NUM = GCC.CHART_OF_ACCOUNTS_ID;

   RETURN L_BALANCING_SEGMENT;
END get_balancing_segment;
-- Fix bug#7334017  add end


 --==========================================================================
  --  PROCEDURE NAME:
  --    insert_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to search the record in sla module and insert
  --        the cash flow item into CFS tables
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_le_id                      legal entity ID
  --          p_period_set_name            period_set_name
  --          p_gl_period_from             the calculation period
  --          p_gl_period_to               the calculation period
  --          p_source                     Source
  --          p_bsv                        Balance Segment Value
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_collection_TD.doc
  --
  --  CHANGE HISTORY:
  --      23/04/2006     Shujuan Yan          Created
  --      29/09/2009     Chaoqun Wu           Fix bug 8969631
  --===========================================================================
  PROCEDURE insert_SLA_data(P_COA_ID                     IN NUMBER,
                             P_LEDGER_ID                 IN NUMBER,
                             P_LE_ID                     IN NUMBER,
                             p_period_set_name           IN VARCHAR2,
                             p_application_id            IN NUMBER,
                             p_ae_header_id              IN NUMBER,
                             p_ae_line_num               IN VARCHAR2,
                             p_transaction_date          IN DATE,
                             p_period_type               IN VARCHAR2,
                             p_func_currency_code        IN VARCHAR2,
                             p_currency_code             IN VARCHAR2,
                             p_currency_conversion_rate  IN NUMBER,
                             p_currency_conversion_type  IN VARCHAR2,
                             p_currency_conversion_date  IN DATE,
                             p_detailed_cfs_item         IN VARCHAR2,
                             p_EVENT_CLASS_CODE          IN VARCHAR2,
                             --p_application_id            IN NUMBER,
                             p_ANALYTICAL_CRITERION_CODE IN VARCHAR2,
                             p_ac_value                  IN VARCHAR2,
                             p_cash_date                 IN DATE,
                             p_accounting_class          IN VARCHAR2,
                             p_cash_amount_cr            IN NUMBER,
                             p_cash_amount_dr            IN NUMBER,
                             p_accounted_dr              IN NUMBER,
                             p_entered_dr                IN NUMBER,
                             p_accounted_cr              IN NUMBER,
                             p_entered_cr                IN NUMBER,
                             p_ccid                      In VARCHAR2,--Fix bug#7334017  add
                             p_cash_ae_header_id         in NUMBER,
                             p_cash_ae_line_number       in NUMBER, --Added by Chaoqun for fixing bug 8969631
                             P_event_type_code           in varchar2) AS
   L_GL_date             ja_cn_cfs_activities_all.gl_date%type;
   l_func_amount         ja_cn_cfs_activities_all.func_amount%type;
   l_orig_amount         ja_cn_cfs_activities_all.original_amount%type;
   l_detailed_item_desc  varchar2(240);
   l_period_name         gl_periods.period_name%TYPE;
   l_application_source  fnd_application.application_short_name%TYPE;
   l_status              ar_cash_receipt_history_all.status%TYPE;
   BEGIN
      --Get the application short name for source
      SELECT application_short_name
        INTO l_application_source
        FROM fnd_application
       WHERE application_id = p_application_id;

     -- Get the gl date,
     If p_cash_date > p_transaction_date then
        L_GL_date := p_cash_date;
     Else
        L_GL_date := p_transaction_date;
     End IF;

     -- Check if status is Remitted
     IF p_event_type_code = 'RECP_UPDATE'
        THEN
        begin
          select ach.status
            into l_status
            from ar_cash_receipt_history_all ach,
                 xla_ae_headers ah
            where ah.ae_header_id = p_cash_ae_header_id
            and   ah.event_id = ach.event_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_status :='';
        END;
      END IF;

      -- For Uncleasing case
      IF p_event_type_code = 'PAYMENT UNCLEARED'
          or (p_event_type_code = 'RECP_UPDATE' and l_status = 'REMITTED')
      Then
         -- get the cash related functional amount and orignal amount
         -- If the cash amount is in the credit
         If p_accounting_class is not null and p_cash_amount_cr is not null Then
            If p_accounted_dr is not null Then
               L_func_amount :=  p_accounted_dr;
               L_orig_amount :=  p_entered_dr;
            Else
               L_func_amount := -1* p_accounted_cr;
               L_orig_amount := -1* p_entered_cr;
            End IF;
         Else
         -- If the cash amount is in the debit
         If p_accounting_class is not null and p_cash_amount_dr is not null Then
            If p_accounted_dr is not null Then
              L_func_amount := p_accounted_dr;
              L_orig_amount := p_entered_dr;
            Else
              L_func_amount := -1* p_accounted_cr;
              L_orig_amount := -1* p_entered_cr;
            End IF;
         End IF;
        END IF;
        Else
        -- get the cash related functional amount and orignal amount
        -- If the cash amount is in the credit
           If p_accounting_class is not null and p_cash_amount_cr is not null Then
             If p_accounted_dr is not null Then
                L_func_amount :=  -1* p_accounted_dr;
                L_orig_amount :=  -1* p_entered_dr;
           Else
                L_func_amount :=  p_accounted_cr;
                L_orig_amount :=  p_entered_cr;
           End IF;
           Else
           -- If the cash amount is in the debit
             If p_accounting_class is not null and p_cash_amount_dr is not null Then
                If p_accounted_dr is not null Then
                  L_func_amount := -1* p_accounted_dr;
                  L_orig_amount := -1* p_entered_dr;
                Else
                  L_func_amount := p_accounted_cr;
                  L_orig_amount := p_entered_cr;
                End IF;
             End IF;
           END IF;
      End if;



    --Get the Detailed cfs item description
    BEGIN
    SELECT Ffvt.DESCRIPTION
    INTO l_detailed_item_desc
    FROM Fnd_Flex_Values_Tl Ffvt,
         fnd_flex_values    Ffv,
         ja_cn_cash_valuesets_all Cra
    WHERE Cra.Chart_Of_Accounts_Id = p_coa_id
      AND Ffv.Flex_Value_Set_Id = Cra.Flex_Value_Set_Id
      AND Ffv.Flex_Value_Id = Ffvt.Flex_Value_Id
      AND ffvt.flex_value_meaning = p_detailed_cfs_item
      AND ffvt.LANGUAGE = userenv('LANG');
    EXCEPTION
     WHEN no_data_found THEN
          l_detailed_item_desc :='';
    END;
    --get the period name
    l_period_name := get_period_name(p_period_set_name,l_gl_date,p_period_type);
    INSERT INTO ja_cn_cfs_activities_all(CFS_ACTIVITY_ID,
                                          LEGAL_ENTITY_ID,
                                          LEDGER_ID,
                                          ORG_ID,
                                          TRX_ID,
                                          TRX_NUMBER,
                                          TRX_LINE_ID,
                                          CASH_TRX_ID, --Added by Chaoqun for fixing bug 8969631
                                          CASH_TRX_LINE_ID, --Added by Chaoqun for fixing bug 8969631
                                          SOURCE,
                                          TRANSACTION_TYPE,
                                          DOCUMENT_SEQUENCE_NUMBER,
                                          TRANSACTION_DATE,
                                          GL_DATE,
                                          PERIOD_NAME,
                                          FUNC_CURR_CODE,
                                          FUNC_AMOUNT,
                                          ORIGINAL_CURR_CODE,
                                          ORIGINAL_AMOUNT,
                                          CURRENCY_CONVERSION_RATE,
                                          CURRENCY_CONVERSION_TYPE,
                                          CURRENCY_CONVERSION_DATE,
                                          DESCRIPTION,
                                          DETAILED_CFS_ITEM,
                                          INTERCOMPANY_FLAG,
                                          REFERENCE_NUMBER,
                                          THIRD_PARTY_NAME,
                                          THIRD_PARTY_NUMBER,
                                          EVENT_CLASS_CODE,
                                          SOURCE_APPLICATION_ID,
                                          ANALYTICAL_CRITERION_CODE,
                                          SOURCE_VALUE,
                                          CASH_ITEM_DESC ,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          CREATION_DATE,
                                          CREATED_BY,
                                          LAST_UPDATE_LOGIN,
                                          balancing_segment)--Fix bug#7334017  add
                                   VALUES(
                                          ja_cn_cfs_activities_s.NEXTVAL
                                          ,p_le_id
                                          ,p_ledger_id
                                          ,NULL
                                          ,p_ae_header_id
                                          ,NULL
                                          ,p_ae_line_num
                                          ,p_cash_ae_header_id  --Added by Chaoqun for fixing bug 8969631
                                          ,p_cash_ae_line_number --Added by Chaoqun for fixing bug 8969631
                                          ,l_application_source--p_source
                                          ,'SLA'
                                          ,NULL
                                          ,p_transaction_date
                                          ,l_gl_date
                                          ,l_period_name
                                          ,p_func_currency_code
                                          ,l_func_amount
                                          ,p_currency_code
                                          ,l_orig_amount
                                          ,p_currency_conversion_rate
                                          ,p_currency_conversion_type
                                          ,p_currency_conversion_date
                                          ,''
                                          ,p_detailed_cfs_item
                                          ,''
                                          ,p_ae_header_id
                                          ,''
                                          ,NULL
                                          ,p_EVENT_CLASS_CODE
                                          ,p_application_id
                                          ,p_ANALYTICAL_CRITERION_CODE
                                          ,p_ac_value
                                          ,l_detailed_item_desc
                                          ,SYSDATE
                                          ,fnd_global.user_id
                                          ,SYSDATE
                                          ,fnd_global.user_id
                                          ,fnd_global.LOGIN_ID
                                          ,get_balancing_segment(p_ccid));--Fix bug#7334017  add
 END;
  --==========================================================================
  --  PROCEDURE NAME:
  --    collect_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to search the record in sla module and insert
  --        the cash flow item into CFS tables
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_le_id                      legal entity ID
  --          p_period_set_name            period_set_name
  --          p_gl_period_from             the calculation period
  --          p_gl_period_to               the calculation period
  --          p_source                     Source
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_collection_TD.doc
  --
  --  CHANGE HISTORY:
  --      23/04/2006     Shujuan Yan          Created
  --      08/09/2008     Yao Zhang           Fix bug #7334017
  --      29/09/2009     Chaoqun Wu          Fix bug 8969631
  --===========================================================================
  PROCEDURE collect_SLA_data(P_COA_ID          IN NUMBER,
                             P_LEDGER_ID       IN NUMBER,
                             P_LE_ID           IN NUMBER,
                             P_PERIOD_SET_NAME IN VARCHAR2,
                             P_GL_PERIOD_FROM  IN VARCHAR2,
                             P_GL_PERIOD_TO    IN VARCHAR2,
                             P_SOURCE          IN VARCHAR2) AS
    l_procedure_name     VARCHAR2(30) := 'collect_SLA_data';
    l_period_num_from    gl_periods.period_num%TYPE;
    l_period_num_to      gl_periods.period_num%TYPE;
    l_date_from          gl_periods.start_date%TYPE;
    l_date_to            gl_periods.end_date%TYPE;
    l_func_currency_code fnd_currencies.currency_code%TYPE;
    l_period_type        gl_ledgers.accounted_period_type%TYPE;
    --l_source             fnd_application.application_short_name%TYPE;
    l_source_id          fnd_application.application_id%TYPE;

    -- the interim variables for activities all table
    l_line_org_id         xla_transaction_entities.security_id_int_1%TYPE;
    l_mapping_org_id      NUMBER;
    l_detailed_cfs_item   ja_cn_cfs_activities_all.detailed_cfs_item%type;
    l_event_class_code    ja_cn_cfs_item_mapping_hdrs.event_class_code%TYPE;

    --the analytical criterion variables
    l_analytical_criterion_code           xla_ae_line_acs.analytical_criterion_code%type;
    l_ac_type_code                        xla_ae_line_acs.analytical_criterion_type_code%type;
    l_amb_context_code                    xla_ae_line_acs.amb_context_code%type;
    l_ac_value                            xla_ae_line_acs.ac1%type;

    --sla lines variables
     l_ae_header_id              xla_ae_lines.ae_header_id%TYPE;
     l_ae_line_num               xla_ae_lines.ae_line_num%TYPE;
     l_transaction_date          xla_ae_lines.accounting_date%TYPE;
     l_accounted_dr              xla_ae_lines.accounted_dr%TYPE;
     l_accounted_cr              xla_ae_lines.accounted_cr%TYPE;
     l_entered_dr                xla_ae_lines.entered_dr%TYPE;
     l_entered_cr                xla_ae_lines.entered_cr%TYPE;
     l_currency_code             xla_ae_lines.currency_code%TYPE;
     l_currency_conversion_rate  xla_ae_lines.currency_conversion_rate%TYPE;
     l_currency_conversion_type  xla_ae_lines.currency_conversion_type%TYPE;
     l_currency_conversion_date  xla_ae_lines.currency_conversion_date%TYPE;
     l_transaction_num           xla_ae_line_acs.ac1%TYPE;
     l_application_id            xla_ae_lines.application_id%TYPE;
     l_ccid                      xla_ae_lines.code_combination_id%TYPE;--Fix bug#7334017  add

    -- Cash lines variables
     l_cash_date                 xla_ae_lines.accounting_date%TYPE;
     l_accounting_class          xla_ae_lines.accounting_class_code%TYPE;
     l_cash_amount_cr            xla_ae_lines.accounted_cr%TYPE;
     l_cash_amount_dr            xla_ae_lines.accounted_dr%TYPE;

     l_event_type_code           xla_ae_headers.event_type_code%TYPE; -- Bug fixing  Added by Shujan
     l_cash_ae_header_id         xla_ae_lines.ae_header_id%TYPE;
     l_cash_ae_line_num          xla_ae_lines.ae_line_num%TYPE;
    -- dynatical cursor
    TYPE SLACurTyp IS REF CURSOR;
    c_sla_lines                 SLACurTyp;
    c_cash_lines                SLACurTyp;
    sql_stmt_sla                VARCHAR2(20000);
    sql_stmt_sla_temp           VARCHAR2(20000);
    sql_stmt_cash               VARCHAR2(20000);
    l_flag                      VARCHAR2(15);

  BEGIN
   --l_flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt (P_LEDGER_ID,p_le_id);
    -- sql tatement for sla ae lines
    sql_stmt_sla :=
    'SELECT al.ae_header_id,
       al.ae_line_num,
       al.accounting_date,
       al.accounted_dr,
       al.accounted_cr,
       al.entered_dr,
       al.entered_cr,
       al.currency_code,
       al.currency_conversion_rate,
       al.currency_conversion_type,
       al.currency_conversion_date,
       al.application_id,
       ala.Analytical_Criterion_Code,
       ala.analytical_criterion_type_code,
       ala.amb_context_code,
       ala.ac1,
       al.code_combination_id
    FROM  xla_ae_lines                         al
         ,xla_ae_headers                       ah
         ,xla_ae_line_acs                      ala
         ,fnd_segment_attribute_values         fsav
         ,gl_code_combinations                 gcc
         ,ja_cn_ledger_le_bsv_gt               glsv
   WHERE ah.gl_transfer_status_code  = ''Y''
   AND   al.ae_header_id = ah.ae_header_id
   --AND al.analytical_balance_flag IS NOT NULL
   AND ala.ae_header_id IN (SELECT ae_header_id
                             FROM xla_ae_line_acs
                            WHERE analytical_criterion_code = ''CHECK_ID''
                              AND amb_context_code = ''DEFAULT''
                              AND analytical_criterion_type_code = ''S''
                              AND ac1= :l_transaction_num)
   AND al.ae_header_id = ala.ae_header_id
   AND al.ae_line_num = ala.ae_line_num
   AND al.ledger_id = :p_ledger_id
   AND ala.Analytical_Criterion_Code <> ''CHECK_ID''
   AND al.code_combination_id = gcc.code_combination_id
   AND gcc.chart_of_accounts_id = :p_coa_id
   AND fsav.application_id  = 101
   AND fsav.id_flex_num  = gcc.chart_of_accounts_id
   AND fsav.attribute_value = ''Y''
   AND fsav.segment_attribute_type = ''GL_BALANCING''
   AND FSAV.ID_FLEX_CODE = ''GL#''
   AND glsv.ledger_id = :p_ledger_id
   AND glsv.legal_entity_id = :p_le_id
   @source_sql
   @event_type_sql
   AND DECODE(FSAV.APPLICATION_COLUMN_NAME,
                  ''SEGMENT1'',GCC.SEGMENT1, ''SEGMENT2'',GCC.SEGMENT2, ''SEGMENT3'',GCC.SEGMENT3,
                  ''SEGMENT4'',GCC.SEGMENT4, ''SEGMENT5'',GCC.SEGMENT5, ''SEGMENT6'',GCC.SEGMENT6,
                  ''SEGMENT7'',GCC.SEGMENT7, ''SEGMENT8'',GCC.SEGMENT8, ''SEGMENT9'',GCC.SEGMENT9,
                  ''SEGMENT10'',GCC.SEGMENT10, ''SEGMENT11'',GCC.SEGMENT11, ''SEGMENT12'',GCC.SEGMENT12,
                  ''SEGMENT13'',GCC.SEGMENT13, ''SEGMENT14'',GCC.SEGMENT14, ''SEGMENT15'',GCC.SEGMENT15,
                  ''SEGMENT16'',GCC.SEGMENT16, ''SEGMENT17'',GCC.SEGMENT17, ''SEGMENT18'',GCC.SEGMENT18,
                  ''SEGMENT19'',GCC.SEGMENT19, ''SEGMENT20'',GCC.SEGMENT20, ''SEGMENT21'',GCC.SEGMENT21,
                  ''SEGMENT22'',GCC.SEGMENT22, ''SEGMENT23'',GCC.SEGMENT23, ''SEGMENT24'',GCC.SEGMENT24,
                  ''SEGMENT25'',GCC.SEGMENT25, ''SEGMENT26'',GCC.SEGMENT26, ''SEGMENT27'',GCC.SEGMENT27,
                  ''SEGMENT28'',GCC.SEGMENT28, ''SEGMENT29'',GCC.SEGMENT29, ''SEGMENT30'',GCC.SEGMENT30) = glsv.bal_seg_value';
  --Sql statement for sla cash lines
  sql_stmt_cash :=
  'SELECT al.accounting_date
         ,al.accounting_class_code
         ,al.accounted_cr
         ,al.accounted_dr
         ,ala.ac1
         ,ah.event_type_code
         ,ah.ae_header_id
         ,al.ae_line_num
   FROM xla_ae_lines                   al
     ,xla_ae_headers                   ah
     ,xla_ae_line_acs                  ala
     ,fnd_segment_attribute_values     fsav
     ,fnd_segment_attribute_values     fsav1
     ,gl_code_combinations             gcc
     ,gl_code_combinations             gcc1
     ,ja_cn_ledger_le_bsv_gt           glsv
     ,ja_cn_cash_accounts_all          jca
   WHERE al.accounting_date >= :l_date_from
     AND al.accounting_date < :l_date_to + 1
     AND ah.gl_transfer_status_code  = ''Y''
     AND al.ae_header_id = ah.ae_header_id
     and al.ae_header_id = ala.ae_header_id
    AND  al.ae_line_num = ala.ae_line_num
    --AND  al.analytical_balance_flag IS NOT NULL
    AND  ala.analytical_criterion_code = ''CHECK_ID''
    AND  ala.analytical_criterion_type_code = ''S''
    AND  ala.amb_context_code = ''DEFAULT''
    --AND  ala.ac1 = :l_transaction_num
    AND  al.ledger_id = :p_ledger_id
    AND  (al.accounting_class_code =''CASH''
          OR  (al.accounting_class_code IN (SELECT class_code
                                           FROM ja_cn_accounting_classes_all
                                           WHERE chart_of_accounts_id = :p_coa_id )))
    AND  al.code_combination_id = gcc1.code_combination_id
    AND  gcc1.chart_of_accounts_id = :p_coa_id
    AND  fsav1.application_id  = 101
    AND  fsav1.id_flex_num  = :p_coa_id
    AND  fsav1.attribute_value = ''Y''
    AND  fsav1.segment_attribute_type = ''GL_BALANCING''
    AND  FSAV1.ID_FLEX_CODE = ''GL#''
    AND  glsv.ledger_id = :p_ledger_id
    AND  glsv.legal_entity_id = :p_le_id
    AND  DECODE(FSAV1.APPLICATION_COLUMN_NAME,
                  ''SEGMENT1'',GCC1.SEGMENT1, ''SEGMENT2'',GCC1.SEGMENT2, ''SEGMENT3'',GCC1.SEGMENT3,
                  ''SEGMENT4'',GCC1.SEGMENT4, ''SEGMENT5'',GCC1.SEGMENT5, ''SEGMENT6'',GCC1.SEGMENT6,
                  ''SEGMENT7'',GCC1.SEGMENT7, ''SEGMENT8'',GCC1.SEGMENT8, ''SEGMENT9'',GCC1.SEGMENT9,
                  ''SEGMENT10'',GCC1.SEGMENT10, ''SEGMENT11'',GCC1.SEGMENT11, ''SEGMENT12'',GCC1.SEGMENT12,
                  ''SEGMENT13'',GCC1.SEGMENT13, ''SEGMENT14'',GCC1.SEGMENT14, ''SEGMENT15'',GCC1.SEGMENT15,
                  ''SEGMENT16'',GCC1.SEGMENT16, ''SEGMENT17'',GCC1.SEGMENT17, ''SEGMENT18'',GCC1.SEGMENT18,
                  ''SEGMENT19'',GCC1.SEGMENT19, ''SEGMENT20'',GCC1.SEGMENT20, ''SEGMENT21'',GCC1.SEGMENT21,
                  ''SEGMENT22'',GCC1.SEGMENT22, ''SEGMENT23'',GCC1.SEGMENT23, ''SEGMENT24'',GCC1.SEGMENT24,
                  ''SEGMENT25'',GCC1.SEGMENT25, ''SEGMENT26'',GCC1.SEGMENT26, ''SEGMENT27'',GCC1.SEGMENT27,
                  ''SEGMENT28'',GCC1.SEGMENT28, ''SEGMENT29'',GCC1.SEGMENT29, ''SEGMENT30'',GCC1.SEGMENT30) = glsv.bal_seg_value
    AND al.code_combination_id = gcc.code_combination_id
    AND gcc.chart_of_accounts_id = :p_coa_id
    AND FSAV.ATTRIBUTE_VALUE = ''Y''
    AND FSAV.APPLICATION_ID = 101
    AND FSAV.SEGMENT_ATTRIBUTE_TYPE = ''GL_ACCOUNT''
    AND FSAV.ID_FLEX_NUM = GCC.CHART_OF_ACCOUNTS_ID
    AND FSAV.ID_FLEX_CODE = ''GL#''
    AND JCA.chart_of_accounts_id = :p_coa_id
    @source_sql
    AND DECODE(FSAV.APPLICATION_COLUMN_NAME,
                  ''SEGMENT1'',GCC.SEGMENT1, ''SEGMENT2'',GCC.SEGMENT2, ''SEGMENT3'',GCC.SEGMENT3,
                  ''SEGMENT4'',GCC.SEGMENT4, ''SEGMENT5'',GCC.SEGMENT5, ''SEGMENT6'',GCC.SEGMENT6,
                  ''SEGMENT7'',GCC.SEGMENT7, ''SEGMENT8'',GCC.SEGMENT8, ''SEGMENT9'',GCC.SEGMENT9,
                  ''SEGMENT10'',GCC.SEGMENT10, ''SEGMENT11'',GCC.SEGMENT11, ''SEGMENT12'',GCC.SEGMENT12,
                  ''SEGMENT13'',GCC.SEGMENT13, ''SEGMENT14'',GCC.SEGMENT14, ''SEGMENT15'',GCC.SEGMENT15,
                  ''SEGMENT16'',GCC.SEGMENT16, ''SEGMENT17'',GCC.SEGMENT17, ''SEGMENT18'',GCC.SEGMENT18,
                  ''SEGMENT19'',GCC.SEGMENT19, ''SEGMENT20'',GCC.SEGMENT20, ''SEGMENT21'',GCC.SEGMENT21,
                  ''SEGMENT22'',GCC.SEGMENT22, ''SEGMENT23'',GCC.SEGMENT23, ''SEGMENT24'',GCC.SEGMENT24,
                  ''SEGMENT25'',GCC.SEGMENT25, ''SEGMENT26'',GCC.SEGMENT26, ''SEGMENT27'',GCC.SEGMENT27,
                  ''SEGMENT28'',GCC.SEGMENT28, ''SEGMENT29'',GCC.SEGMENT29, ''SEGMENT30'',GCC.SEGMENT30) IN JCA.ACCOUNT_SEGMENT_VALUE';
    IF (G_PROC_LEVEL >= g_debug_devel) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
                     G_MODULE_PREFIX || l_procedure_name || '.begin',
                     'Begin procedure');
    END IF; --( G_PROC_LEVEL >= g_debug_devel)

    --Get base currency code
    SELECT currency_code, accounted_period_type
      INTO l_func_currency_code, l_period_type
      FROM gl_ledgers
     WHERE ledger_id = p_ledger_id;

    -- Get l_date_from, l_date_to
    BEGIN
      SELECT period_year * 1000 + period_num, start_date
        INTO l_period_num_from, l_date_from
        FROM gl_periods
       WHERE period_set_name = p_period_set_name
         AND period_name = P_GL_PERIOD_FROM
         AND period_type = l_period_type;

      SELECT period_year * 1000 + period_num, end_date
        INTO l_period_num_to, l_date_to
        FROM gl_periods
       WHERE period_set_name = p_period_set_name
         AND period_name = P_GL_PERIOD_to
         AND period_type = l_period_type;

      IF (G_STATEMENT_LEVEL >= g_debug_devel) THEN
        put_log(G_MODULE_PREFIX || l_procedure_name || '.date range',
                l_date_from || ':' || l_date_to);
      END IF; --( G_STATEMENT_LEVEL >= g_debug_devel)

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                         G_MODULE_PREFIX || l_procedure_name ||
                         '.NO_DATA_FOUND',
                         'parameter periods wrong');
        END IF;
        RAISE;
    END;

    -- delete the record calculated before
    IF p_source = 'ALL' THEN
      DELETE ja_cn_cfs_activities_all ca
       WHERE ca.legal_entity_id = P_LE_ID
         AND ledger_id = p_ledger_id
         AND ca.SOURCE_application_id NOT IN (101, 435)
         AND ca.period_name IN
             (SELECT period_name
                FROM Gl_Periods
               WHERE period_set_name = p_period_set_name
                 AND period_year * 1000 + period_num BETWEEN
                     l_period_num_from AND l_period_num_to);
        COMMIT;
        l_source_id := 101;
        sql_stmt_sla := REPLACE(sql_stmt_sla,
                              '@source_sql',
                               'AND al.application_id <> :l_source_id');
        sql_stmt_cash := REPLACE(sql_stmt_cash,
                              '@source_sql',
                               'AND al.application_id <> :l_source_id');

    ELSE
      BEGIN
        SELECT application_id
          INTO l_source_id
          FROM fnd_application
         WHERE application_short_name = p_source;

        DELETE ja_cn_cfs_activities_all ca
         WHERE ca.legal_entity_id = P_LE_ID
           AND ledger_id = p_ledger_id
           AND ca.SOURCE_application_id = l_source_id
           AND ca.period_name IN
               (SELECT period_name
                  FROM Gl_Periods
                 WHERE period_set_name = p_period_set_name
                   AND period_year * 1000 + period_num BETWEEN
                       l_period_num_from AND l_period_num_to);
        COMMIT;
        sql_stmt_sla := REPLACE(sql_stmt_sla,
                              '@source_sql',
                               'And al.application_id = :l_source_id');
        sql_stmt_cash := REPLACE(sql_stmt_cash,
                              '@source_sql',
                               'And al.application_id = :l_source_id');

        IF (G_STATEMENT_LEVEL >= g_debug_devel) THEN
          put_log(G_MODULE_PREFIX || l_procedure_name || '.source',
                  p_source);
        END IF; --( G_STATEMENT_LEVEL >= g_debug_devel)

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                           G_MODULE_PREFIX || l_procedure_name ||
                           '.NO_DATA_FOUND',
                           'parameter periods wrong');
          END IF;
          RAISE;
      END;
    END IF;
    IF(  G_STATEMENT_LEVEL >= g_debug_devel )
    THEN
      put_log(G_MODULE_PREFIX||l_procedure_name||'.chart of accounts id'
             ,p_coa_id);
    END IF;  --( G_STATEMENT_LEVEL >= g_debug_devel)

     OPEN c_cash_lines FOR sql_stmt_cash
          using l_date_from, l_date_to, p_ledger_id, p_coa_id,
                p_coa_id,p_coa_id,p_ledger_id,p_le_id,p_coa_id,p_coa_id,l_source_id;
     LOOP
     FETCH c_cash_lines INTO l_cash_date,
                             l_accounting_class,
                             l_cash_amount_cr,
                             l_cash_amount_dr,
                             l_transaction_num,
                             l_event_type_code,
                             l_cash_ae_header_id,
                             l_cash_ae_line_num; --Added by Chaoqun for fixing bug 8969631
     EXIT WHEN c_cash_lines%NOTFOUND;
          sql_stmt_sla_temp:= sql_stmt_sla;
          -- For payment cancelled and receipt reverse
               IF l_event_type_code not in ('PAYMENT CANCELLED' ,'RECP_REVERSE')
               THEN
                   sql_stmt_sla_temp := REPLACE(sql_stmt_sla_temp,
                              '@event_type_sql',
                               'AND ah.event_type_code not IN (''PAYMENT CANCELLED'',''RECP_REVERSE'')');
               Else
                  sql_stmt_sla_temp:= REPLACE(sql_stmt_sla_temp,
                               '@event_type_sql',
                               'AND ah.event_type_code IN (''PAYMENT CANCELLED'',''RECP_REVERSE'')');
               END IF;
          OPEN c_sla_lines FOR sql_stmt_sla_temp  using l_transaction_num,p_ledger_id, p_coa_id,p_ledger_id,p_le_id,l_source_id;
          LOOP
          FETCH c_sla_lines INTO  l_ae_header_id,
                                  l_ae_line_num,
                                  l_transaction_date,
                                  l_accounted_dr,
                                  l_accounted_cr,
                                  l_entered_dr,
                                  l_entered_cr,
                                  l_currency_code,
                                  l_currency_conversion_rate,
                                  l_currency_conversion_type,
                                  l_currency_conversion_date,
                                  l_application_id,
                                  l_analytical_criterion_code,
                                  l_ac_type_code,
                                  l_amb_context_code,
                                  l_ac_value,
                                  l_ccid;--Fix bug#7334017  add
          EXIT WHEN c_sla_lines%NOTFOUND;
                 --Get org id of the current sla ae line
                 begin
                 Select xte.SECURITY_ID_INT_1
                   Into l_line_org_id
                   FROM XLA_TRANSACTION_ENTITIES xte, xla_ae_headers xah
                  Where xte.entity_id = xah.entity_id
                    And xte.application_id = xah.application_id
                    And xah.ae_header_id = l_ae_header_id
                    AND xah.application_id = l_application_id;
                 exception
                 WHEN no_data_found THEN
                      l_line_org_id:= NULL;
                 end;
                 --Get the detailed cfs item when there is the mapping relationship of
                 --the current analytical criterion and sla ae line org id
                 --in the mapping table
                 BEGIN
                 Select jccl.detailed_cfs_item, jccl.org_id, jcch.event_class_code
                   Into l_detailed_cfs_item, L_mapping_org_id, l_event_class_code
                   From ja_cn_cfs_item_mapping_hdrs  jcch,
                        ja_cn_cfs_item_mapping_lines jccl
                  Where jcch.Chart_of_Accounts_id = p_coa_id
                    And jcch.analytical_criterion_code = l_analytical_criterion_code
                    AND jcch.analytical_criterion_type_code = l_ac_type_code
                    AND jcch.amb_context_code = l_amb_context_code
                    And jcch.mapping_header_id = jccl.mapping_header_id
                    And jccl.ac_value = l_ac_value
                    AND nvl(jccl.effective_start_date, l_transaction_date) <=l_transaction_date
                    AND nvl(jccl.effective_end_date,l_transaction_date) >=l_transaction_date
                    And jccl.org_id = l_line_org_id;
                  EXCEPTION
                  WHEN no_data_found THEN
                       l_detailed_cfs_item := NULL;
                       l_mapping_org_id := NULL;
                  WHEN too_many_rows THEN
                       l_detailed_cfs_item := NULL;
                       l_mapping_org_id := NULL;
                  END;

                   If l_detailed_cfs_item is null THEN
                      -- Get the detailed cfs item when there is the mapping relationship of
                      -- the current analytical criterion in the mapping table and the org id is
                      -- null in the mapping table


                      BEGIN
                      Select jccl.detailed_cfs_item,jcch.event_class_code
                        Into l_detailed_cfs_item,l_event_class_code
                        From ja_cn_cfs_item_mapping_hdrs  jcch,
                             ja_cn_cfs_item_mapping_lines jccl
                       Where jcch.Chart_of_Accounts_id = p_coa_id
                         And jcch.analytical_criterion_code = l_analytical_criterion_code
                         AND jcch.analytical_criterion_type_code = l_ac_type_code
                         AND jcch.amb_context_code = l_amb_context_code
                         And jcch.mapping_header_id = jccl.mapping_header_id
                         And jccl.ac_value = l_ac_value
                         AND nvl(jccl.effective_start_date,l_transaction_date) <= l_transaction_date
                         AND  nvl(jccl.effective_end_date, l_transaction_date) >= l_transaction_date
                         And jccl.org_id is NULL;
                        EXCEPTION
                        WHEN no_data_found THEN
                             l_detailed_cfs_item := NULL;
                        WHEN too_many_rows THEN
                             l_detailed_cfs_item := NULL;
                        END;
                         If l_detailed_cfs_item is not null THEN

                             insert_SLA_data(P_COA_ID,
                             P_LEDGER_ID,
                             P_LE_ID,
                             p_period_set_name,
                             l_application_id,
                             l_ae_header_id,
                             l_ae_line_num,
                             l_transaction_date,
                             l_period_type,
                             l_func_currency_code,
                             l_currency_code,
                             l_currency_conversion_rate,
                             l_currency_conversion_type,
                             l_currency_conversion_date,
                             l_detailed_cfs_item,
                             l_EVENT_CLASS_CODE,
                             --l_application_id,
                             l_ANALYTICAL_CRITERION_CODE,
                             l_ac_value,
                             l_cash_date,
                             l_accounting_class,
                             l_cash_amount_cr,
                             l_cash_amount_dr,
                             l_accounted_dr,
                             l_entered_dr,
                             l_accounted_cr,
                             l_entered_cr,
                             l_ccid, --Fix bug#7334017  add
                             l_cash_ae_header_id,
                             l_cash_ae_line_num,  --Added by Chaoqun for fixing bug 8969631
                             l_event_type_code);
                         End IF;
                     Else
                             insert_SLA_data(P_COA_ID,
                             P_LEDGER_ID,
                             P_LE_ID,
                             p_period_set_name,
                             l_application_id,
                             l_ae_header_id,
                             l_ae_line_num,
                             l_transaction_date,
                             l_period_type,
                             l_func_currency_code,
                             l_currency_code,
                             l_currency_conversion_rate,
                             l_currency_conversion_type,
                             l_currency_conversion_date,
                             l_detailed_cfs_item,
                             l_EVENT_CLASS_CODE,
                             --l_application_id,
                             l_ANALYTICAL_CRITERION_CODE,
                             l_ac_value,
                             l_cash_date,
                             l_accounting_class,
                             l_cash_amount_cr,
                             l_cash_amount_dr,
                             l_accounted_dr,
                             l_entered_dr,
                             l_accounted_cr,
                             l_entered_cr ,
                             l_ccid,--Fix bug#7334017  add
                             l_cash_ae_header_id,
                             l_cash_ae_line_num, --Added by Chaoqun for fixing bug 8969631
                             l_event_type_code);
                     End IF;
           END LOOP;
           CLOSE c_sla_lines;
           COMMIT;
     END LOOP;
    CLOSE c_cash_lines;
  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.end'
                  ,'End procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , SQLCODE||':'||SQLERRM||p_coa_id);
    END IF;
    RAISE;
  END collect_SLA_data;

end JA_CN_CFS_CLT_SLA_PKG;

/
