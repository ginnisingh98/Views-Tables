--------------------------------------------------------
--  DDL for Package Body JA_CN_GL_INTER_VALID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_GL_INTER_VALID_PKG" AS
--$Header: JACNGIVB.pls 120.6.12010000.3 2009/01/04 06:32:00 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNGIVB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for GL Journals and Intercompany Transactions|
--|     Validation in the CNAO Project.                                   |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      FUNCTION  Source_Meaning                   PRIVATE               |
--|      FUNCTION  Line_Check                       PRIVATE               |
--|      PROCEDURE Get_Account_Combo_and_Desc       PRIVATE               |
--|      PROCEDURE GL_Validation                    PUBLIC                |
--|      PROCEDURE Intercompany_Validation          PUBLIC                |
--|                                                                       |
--| HISTORY                                                               |
--|      02/24/2006     Andrew Liu          Created                       |
--|      04/30/2007     Yucheng Sun         Updated                       |
--|      12/07/2007     Arming Chen         Fix bug#6654759
--|      04/09/2008     Chaoqun Wu          Updated for CNAO Enhancement  |
--|      10/10/2008     Chaoqun Wu          Fix bug#7475903               |
--|      14/10/2008     Chaoqun Wu          Fix bug# 7481841              |
--|      17/10/2008     Chaoqun Wu          Fix bug#7487439               |
--+======================================================================*/

  l_module_prefix                     VARCHAR2(100) :='JA_CN_GL_INTER_VALID_PKG';

  JA_CN_INCOMPLETE_DFF_ASSIGN         exception;
  JA_CN_NO_CASHFLOWITEM               exception;
  JA_CN_NO_CASHACCOUNT                exception;
  l_msg_incomplete_dff_assign         VARCHAR2(2000); -- 'The descriptive flexfield assignments are incomplete...';
  l_msg_no_cashflow_item              VARCHAR2(2000); -- 'No cash flow item in the DFF';
  l_msg_no_cash_account               VARCHAR2(2000); -- 'No cash related account';

  --==========================================================================
  --  FUNCTION NAME:
  --    Source_Meaning                private
  --
  --  DESCRIPTION:
  --      This function gets meaning of source, GL Journal/Intercompany Transaction.
  --
  --  PARAMETERS:
  --      In: P_SOURCE                VARCHAR2            Source: GLJE/INTR
  --  RETURN:
  --      VARCHAR2
  --         Meaning of the source
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --==========================================================================
  FUNCTION  Source_Meaning( P_SOURCE IN VARCHAR2 )
  RETURN VARCHAR2  IS
    l_source                            VARCHAR2(150);
  BEGIN
    SELECT FLV.meaning                         source
      INTO l_source
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = P_SOURCE          --using parameter P_SOURCE: 'GLJE'/'INTR'
       AND FLV.lookup_type = 'JA_CN_CASHFLOW_SRC_TYPE'
       AND FLV.LANGUAGE = userenv('LANG')
          ;

    RETURN l_source;
  End Source_Meaning;

  --==========================================================================
  --  FUNCTION NAME:
  --    Line_Check                    private
  --
  --  DESCRIPTION:
  --      This function checks whether line of GL journals OR Intercompany
  --      transactions can be output as a invalid one or not.
  --
  --  PARAMETERS:
  --      IN: P_COA_ID                NUMBER              ID of chart of accounts
  --      In: P_LEDGER_ID             NUMBER              ID of ledger
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_SOURCE                VARCHAR2            Source:GL/GIS
  --      In: P_COM_SEGMENT           VARCHAR2            Specified company segment
  --      In: P_JT_ID                 VARCHAR2            ID of the Journal/Tr
  --      In: P_LINE_NUM              VARCHAR2            Number of the line
  --      In: P_CCID                  NUMBER              ID of chart of account
  --      In: P_CASH_RELATED_ITEM     VARCHAR2            Cash related item of the line
  --  RETURN:
  --      VARCHAR2
  --         'NO_ITEM'    for the line has cash related account but no such item
  --         'NO_ACCOUNT' for the line has cash related item but no such account
  --         'EXCLUDED'   for the line should be excluded
  --         'OK'         for the line is a good line
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/16/2007     Yucheng Sun         Changed
  --===========================================================================
  FUNCTION  Line_Check( P_COA_ID             IN NUMBER
                       ,P_LEDGER_ID          IN NUMBER
                       ,P_LE_ID              IN NUMBER
                       ,P_SOURCE             IN VARCHAR2
                       ,P_JT_ID              IN NUMBER
                       ,P_LINE_NUM           IN VARCHAR2
                       ,P_CCID               IN NUMBER
                       ,P_CASH_RELATED_ITEM  IN VARCHAR2
  ) RETURN VARCHAR2  IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Line_Check';

    l_coa_id                            number := P_COA_ID;
    l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_le_id                             NUMBER := P_LE_ID;
    l_source                            VARCHAR2(10) := P_SOURCE;
    --l_com_segment                       VARCHAR2(150) := P_COM_SEGMENT;
    l_jt_id                             NUMBER := P_JT_ID;
    l_line_num                          VARCHAR2(20) := P_LINE_NUM;
    l_cc_id                             NUMBER := P_CCID;
    l_csi_check                         varchar2(2) := P_CASH_RELATED_ITEM;

    l_seg_type                          FND_SEGMENT_ATTRIBUTE_VALUES.SEGMENT_ATTRIBUTE_TYPE%TYPE;
    l_ffv_flex_value                    varchar2(150);
    l_seg_fsav_gcc                      varchar2(150);

    l_account_num                       varchar2(150); --account number of a line's account
    l_com_seg                           varchar2(150); --company segment of a line's account
    l_com_seg_check                     number;        --flag of an account's company segment belongs to current LE or not
    l_account_check                     number;        --flag of an account in cash related table or not
    l_line_chk                          varchar2(20);  --result of a line's validation
    l_cash_flow_item_from_GL            gl_je_lines.attribute1%TYPE;

    --Cursor to get FFV.Flex_Value and segment FSAV.APPLICATION_COLUMN_NAME of gcc
    CURSOR c_ffv IS
    SELECT FFV.Flex_Value                      ffv_flex_value
          ,DECODE(FSAV.APPLICATION_COLUMN_NAME, --segment FSAV.APPLICATION_COLUMN_NAME of gcc
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
                                               seg_fsav_gcc
      FROM GL_CODE_COMBINATIONS                gcc
          ,GL_LEDGERS                          ledger
          ,FND_ID_FLEX_SEGMENTS                FIFS
          ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV
          ,FND_FLEX_VALUE_SETS                 FFVS
          ,FND_FLEX_VALUES                     FFV
     WHERE gcc.code_combination_id = l_cc_id           --using variable l_cc_id
       AND ledger.chart_of_accounts_id = gcc.chart_of_accounts_id
       AND ledger.ledger_id = l_ledger_id              --using variable l_sob_id
       AND FIFS.id_flex_num = gcc.chart_of_accounts_id
       AND FIFS.id_flex_num = FSAV.id_flex_num
       AND FIFS.application_id = 101
       AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
       AND FIFS.application_id = FSAV.application_id
       AND FSAV.SEGMENT_ATTRIBUTE_TYPE = l_seg_type    --using variable l_seg_type
       AND FSAV.ATTRIBUTE_VALUE = 'Y'
       AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
       AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
          ;

  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure for Journal/Transaction '||TO_CHAR(l_jt_id)
                        || '''s Line ' || l_line_num
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    l_line_chk := '';

    --Get account segment
    l_seg_type := 'GL_ACCOUNT';
    OPEN c_ffv;
    LOOP
      FETCH c_ffv INTO l_ffv_flex_value
                      ,l_seg_fsav_gcc
                      ;
      EXIT WHEN c_ffv%NOTFOUND;
      IF l_ffv_flex_value = l_seg_fsav_gcc THEN
        l_account_num := l_ffv_flex_value;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_ffv;

    IF l_account_num is not null
    THEN
      --check the line's account is cash related or not.
      --Account is cash related one when its number is in table JA_CN_CASH_ACCOUNTS_ALL
      SELECT count(*)                            row_count
        INTO l_account_check
        FROM JA_CN_CASH_ACCOUNTS_ALL             cash_acc
       WHERE cash_acc.ACCOUNT_SEGMENT_VALUE = l_account_num --using variable l_account_num
         AND cash_acc.chart_of_accounts_id = l_coa_id       --using variable l_coa_id
            ;

      IF l_source = 'GL' THEN
      --GL
        --Get account's company segment
        l_seg_type := 'GL_BALANCING';
        OPEN c_ffv;
        LOOP
          FETCH c_ffv INTO l_ffv_flex_value
                          ,l_seg_fsav_gcc
                          ;
          EXIT WHEN c_ffv%NOTFOUND;
          IF l_ffv_flex_value is not null AND
             l_seg_fsav_gcc is not null   AND
             l_ffv_flex_value = l_seg_fsav_gcc
          THEN
            l_com_seg := l_ffv_flex_value;
            EXIT;
          END IF;
        END LOOP;
        CLOSE c_ffv;

        /*
        IF l_com_segment is not null AND
           l_com_seg is not null AND
           l_com_seg <> l_com_segment     --?? not sure
        THEN
          l_com_seg := '';
        END IF;
        */

        IF l_com_seg is not null
        THEN
          --check the company segment belongs to the current legal entity or not.
          SELECT  count(*)                            row_count
            INTO  l_com_seg_check
            FROM  JA_CN_LEDGER_LE_BSV_GT              tmpbsv
           WHERE  tmpbsv.LEGAL_ENTITY_ID = l_le_id         --using variable l_le_id
             AND  tmpbsv.ledger_id = l_ledger_id           --using variable l_ledger_id
             AND  tmpbsv.bal_seg_value = l_com_seg;        --using variable l_com_seg

          IF l_com_seg_check > 0 THEN --the company segment belongs to the current legal entity
            --line has cash related account AND the cash flow item DFF is blank, JA_CN_NO_CASHFLOWITEM
            IF l_account_check > 0 AND l_csi_check = 'B' THEN
              l_line_chk := 'NO_ITEM';
            --line has no cash related account AND the cash flow item DFF is NOT blank, JA_CN_NO_CASHACCOUNT
            ELSIF l_account_check < 1 AND l_csi_check = 'NB' THEN
              l_line_chk := 'NO_ACCOUNT';
            ELSE
              l_line_chk := 'OK';
            END IF;
          END IF; --l_com_seg_check > 0
        END IF; --l_com_seg is not null

      ELSE
      --'AGIS'
        --line has cash related account AND the cash flow item DFF is blank, JA_CN_NO_CASHFLOWITEM
        --IF l_account_check > 0 THEN
              -- get the cash relate item from GL
              BEGIN
                  SELECT decode(jel.context, dffa.context_code,
                                decode(dffa.attribute_column, 'ATTRIBUTE1',jel.attribute1, 'ATTRIBUTE2',jel.attribute2,
                                 'ATTRIBUTE3',jel.attribute3, 'ATTRIBUTE4',jel.attribute4, 'ATTRIBUTE5',jel.attribute5,
                                 'ATTRIBUTE6',jel.attribute6, 'ATTRIBUTE7',jel.attribute7, 'ATTRIBUTE8',jel.attribute8,
                                 'ATTRIBUTE9',jel.attribute9, 'ATTRIBUTE10',jel.attribute10, 'ATTRIBUTE11',jel.attribute11,
                                 'ATTRIBUTE12',jel.attribute12, 'ATTRIBUTE13',jel.attribute13, 'ATTRIBUTE14',jel.attribute14,
                                 'ATTRIBUTE15',jel.attribute15)
                                )                            cash_related_item
                    INTO l_cash_flow_item_from_GL
                    FROM gl_je_lines                         jel
                       , fun_trx_headers                     trxh
                       , fun_trx_lines                       trxl
                       , fun_dist_lines                      distl
                       ,ja_cn_dff_assignments                dffa
                   WHERE distl.dist_id = l_jt_id                 -- transaction header id
                     AND distl.line_id=trxl.line_id
                     AND trxh.trx_id = trxl.trx_id
                     AND jel.reference_2 = TO_CHAR(trxh.batch_id)
                     AND jel.reference_3 = TO_CHAR(trxh.trx_id)
                     AND jel.reference_4 = TO_CHAR(trxl.line_id)
                     AND jel.reference_5 = TO_CHAR(distl.dist_id)
                     AND jel.ledger_id=l_ledger_id               -- care only current ledgers'
                     --AND jel.status='P'                        -- care only post journels from trxes  --?? NOT SURE
                         -- to locate cash flow item in dff_assignment
                     AND dffa.Application_Id = 101
                     AND dffa.chart_of_accounts_id = l_coa_id    --using variable l_coa_id
                     AND dffa.dff_title_code='GLLI';
               Exception
                  WHEN NO_DATA_FOUND THEN
                       l_cash_flow_item_from_GL := null;
               END;
        --END IF;

        -- set the cash flow item check status If the journel cash flow item is not null
        IF  l_cash_flow_item_from_GL IS NOT NULL THEN
           l_csi_check := 'NB';
        END IF;

        IF l_account_check > 0 AND l_csi_check = 'B'
        THEN
          l_line_chk := 'NO_ITEM';
        --line has no cash related account AND the cash flow item DFF is NOT blank, JA_CN_NO_CASHACCOUNT
        ELSIF l_account_check < 1 AND l_csi_check = 'NB'
        THEN
          l_line_chk := 'NO_ACCOUNT';
        ELSE
          l_line_chk := 'OK';
        END IF;
      END IF; --l_source = 'GL'/'GIS'
    END IF; --l_account_num is not null

    IF l_line_chk is null --The account should be excluded
    THEN
      l_line_chk := 'EXCLUDED';
    END IF;

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.end'
                     ,'Exit procedure for Journal/Transaction '||TO_CHAR(l_jt_id)
                        || '''s Line ' || l_line_num
                        ||' and its l_line_chk is ' || l_line_chk
                    );
    END IF;  --(l_proc_level >= l_dbg_level)
    return l_line_chk;

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,'For Journal/Transaction '||TO_CHAR(l_jt_id)
                          || '''s Line ' || l_line_num
                          || ', So set the check as ''EXCLUDED'', meaning excluded the line.'
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        return 'EXCLUDED';
  END Line_Check;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Get_Account_Combo_and_Desc    public
  --
  --  DESCRIPTION:
  --      This procedure gets flexfiled and description of specified account.
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID             NUMBER              Chart of accounts ID
  --      In: P_CCID                  NUMBER              ID of code commbination
  --      Out: P_ACCOUNT              VARCHAR2            Combined account
  --      Out: P_ACCOUNT_DESC         VARCHAR2            Description of account
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE  Get_Account_Combo_and_Desc( P_LEDGER_ID     IN NUMBER
                                        ,P_CCID          IN NUMBER
                                        ,P_ACCOUNT       OUT NOCOPY VARCHAR2
                                        ,P_ACCOUNT_DESC  OUT NOCOPY VARCHAR2
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Get_Account_Combo_and_Desc';

    l_ledger_id                         number := P_LEDGER_ID;
    l_cc_id                             number := P_CCID;

    l_delimiter_label                   FND_ID_FLEX_STRUCTURES.Concatenated_Segment_Delimiter%TYPE;

    TYPE t_segemnt_type IS RECORD      ( seg_num      FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE
                                        ,seg_name     FND_ID_FLEX_SEGMENTS.Segment_Name%TYPE
                                        ,column_name  FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE
                                        ,value_set_id FND_ID_FLEX_SEGMENTS.FLEX_VALUE_SET_ID%TYPE
                                        );
    TYPE t_segemnt_array IS TABLE OF    t_segemnt_type;
    l_all_segemnts                      t_segemnt_array;
    l_segemnt                           t_segemnt_type;

    TYPE t_acc_seg_type IS RECORD      ( seg_num      FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE
                                        ,seg_name     FND_ID_FLEX_SEGMENTS.SEGMENT_NAME%TYPE
                                        ,flex_val     FND_FLEX_VALUES.Flex_Value%TYPE
                                        ,flex_desc    FND_FLEX_VALUES_TL.Description%TYPE
                                        );
    TYPE t_acc_segt_array IS TABLE OF   t_acc_seg_type;
    l_all_acc_seg                       t_acc_segt_array;
    l_acc_seg                           t_acc_seg_type;
    l_has_the_seg                       number;

    --l_sql                               varchar2(4000);

  BEGIN
    --Get delimiter label
    SELECT FIFStr.Concatenated_Segment_Delimiter
      INTO l_delimiter_label
      FROM GL_CODE_COMBINATIONS                gcc
          ,FND_ID_FLEX_STRUCTURES              FIFStr
     WHERE gcc.code_combination_id = l_cc_id   --using variable l_cc_id
       AND FIFStr.APPLICATION_ID=101
       AND FIFStr.ID_FLEX_CODE='GL#'
       AND FIFStr.ID_FLEX_NUM = gcc.chart_of_accounts_id
          ;

    --Get all segments of ACCOUNTING FLEXFIELD
    BEGIN
    SELECT FIFS.SEGMENT_NUM
          ,FIFS.Segment_Name
          ,FIFS.APPLICATION_COLUMN_NAME
          ,FIFS.FLEX_VALUE_SET_ID
      BULK COLLECT INTO                        l_all_segemnts
      FROM GL_CODE_COMBINATIONS                gcc
          ,FND_ID_FLEX_SEGMENTS                FIFS
     WHERE gcc.code_combination_id = l_cc_id   --using variable l_cc_id
       AND FIFS.APPLICATION_ID=101
       AND FIFS.ID_FLEX_CODE='GL#'             -- using standard flex code, without it the output will be reduplicate
       AND FIFS.ID_FLEX_NUM = gcc.chart_of_accounts_id
     ORDER BY FIFS.SEGMENT_NUM
          ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;

    /*
    --Get value and description of all segments
    l_sql :=
      'SELECT DISTINCT '
      ||'     FIFS.SEGMENT_NUM                    seg_num'  --the output will order by it!
      ||'    ,FIFS.SEGMENT_NAME                   seg_name'
      ||'    ,FFV.Flex_Value                      flex_value'
      ||'    ,FFVT.Description                    flex_desc'
      ||' BULK COLLECT INTO                       :1'
      ||' FROM GL_CODE_COMBINATIONS               gcc'
      ||'    ,GL_SETS_OF_BOOKS                    sob'
      ||'    ,FND_ID_FLEX_SEGMENTS                FIFS'
      ||'    ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV'
      ||'    ,FND_FLEX_VALUE_SETS                 FFVS'
      ||'    ,FND_FLEX_VALUES                     FFV'
      ||'    ,FND_FLEX_VALUES_TL                  FFVT'
      ||' WHERE gcc.code_combination_id = :2'          --using variable l_cc_id
      ||'   AND sob.chart_of_accounts_id = gcc.chart_of_accounts_id'
      ||'   AND sob.set_of_books_id = :3'              --using variable l_sob_id
      ||'   AND FIFS.id_flex_num = gcc.chart_of_accounts_id'
      ||'   AND FIFS.id_flex_num = FSAV.id_flex_num'
      ||'   AND FIFS.application_id = 101'
      ||'   AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME'
         --AND FSAV.SEGMENT_ATTRIBUTE_TYPE = l_seg_type  --Just not check the type!
      ||'   AND FIFS.application_id = FSAV.application_id'
      ||'   AND FSAV.ATTRIBUTE_VALUE = ''Y'''
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID'
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID'
      ||'   AND GCC.' || FSAV.APPLICATION_COLUMN_NAME || ' = FFV.Flex_Value'
      ||'   and FFVT.flex_value_id = FFV.flex_value_id'
      ||'   and nvl(FFVT.LANGUAGE, userenv(''LANG'')) = userenv(''LANG'')';

    execute immediate l_sql using l_all_acc_seg, l_cc_id, l_sob_id;
    */

    --Get flex_value and description of account segments in ACCOUNTING FLEXFIELD
    BEGIN
    SELECT DISTINCT
           FIFS.SEGMENT_NUM                    seg_num   --the output will order by it!
          ,FIFS.SEGMENT_NAME                   seg_name
          ,FFV.Flex_Value                      flex_value
          ,FFVT.Description                    flex_desc
      BULK COLLECT INTO                        l_all_acc_seg
      FROM GL_CODE_COMBINATIONS                gcc
          ,GL_LEDGERS                          ledger
          ,FND_ID_FLEX_SEGMENTS                FIFS
          ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV
          ,FND_FLEX_VALUE_SETS                 FFVS
          ,FND_FLEX_VALUES                     FFV
          ,FND_FLEX_VALUES_TL                  FFVT
     WHERE gcc.code_combination_id = l_cc_id           --using variable l_cc_id
       AND ledger.chart_of_accounts_id = gcc.chart_of_accounts_id
       AND ledger.ledger_id = l_ledger_id              --using variable l_ledger_id
       AND FIFS.id_flex_num = gcc.chart_of_accounts_id
       AND FIFS.id_flex_num = FSAV.id_flex_num
       AND FIFS.application_id = 101
       AND FIFS.ID_FLEX_CODE='GL#'                     -- using standard flex code, without it the output will be reduplicate
       AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
       --AND FSAV.SEGMENT_ATTRIBUTE_TYPE = l_seg_type  --Just not check the type!
       AND FSAV.ATTRIBUTE_VALUE = 'Y'
       AND FIFS.application_id = FSAV.application_id
       AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
       AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
       AND DECODE(FSAV.APPLICATION_COLUMN_NAME, --segment FSAV.APPLICATION_COLUMN_NAME of gcc
                  'SEGMENT1',GCC.SEGMENT1, 'SEGMENT2',GCC.SEGMENT2, 'SEGMENT3',GCC.SEGMENT3,
                  'SEGMENT4',GCC.SEGMENT4, 'SEGMENT5',GCC.SEGMENT5, 'SEGMENT6',GCC.SEGMENT6,
                  'SEGMENT7',GCC.SEGMENT7, 'SEGMENT8',GCC.SEGMENT8, 'SEGMENT9',GCC.SEGMENT9,
                  'SEGMENT10',GCC.SEGMENT10, 'SEGMENT11',GCC.SEGMENT11, 'SEGMENT12',GCC.SEGMENT12,
                  'SEGMENT13',GCC.SEGMENT13, 'SEGMENT14',GCC.SEGMENT14, 'SEGMENT15',GCC.SEGMENT15,
                  'SEGMENT16',GCC.SEGMENT16, 'SEGMENT17',GCC.SEGMENT17, 'SEGMENT18',GCC.SEGMENT18,
                  'SEGMENT19',GCC.SEGMENT19, 'SEGMENT20',GCC.SEGMENT20, 'SEGMENT21',GCC.SEGMENT21,
                  'SEGMENT22',GCC.SEGMENT22, 'SEGMENT23',GCC.SEGMENT23, 'SEGMENT24',GCC.SEGMENT24,
                  'SEGMENT25',GCC.SEGMENT25, 'SEGMENT26',GCC.SEGMENT26, 'SEGMENT27',GCC.SEGMENT27,
                  'SEGMENT28',GCC.SEGMENT28, 'SEGMENT29',GCC.SEGMENT29, 'SEGMENT30',GCC.SEGMENT30) = FFV.Flex_Value
       AND FFVT.flex_value_id = FFV.flex_value_id
       AND nvl(FFVT.LANGUAGE, userenv('LANG')) = userenv('LANG')
          ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;

    --Check account's all segments one by one, and
    --Generate its flexfield and description
    P_ACCOUNT := '';
    P_ACCOUNT_DESC := '';
    IF l_all_segemnts.first is not null
    THEN
      FOR i IN l_all_segemnts.first .. l_all_segemnts.last LOOP
        l_segemnt := l_all_segemnts(i);

        l_has_the_seg := 0;
        IF l_all_acc_seg.first is not null
        THEN
          FOR j IN l_all_acc_seg.first .. l_all_acc_seg.last LOOP
            l_acc_seg := l_all_acc_seg(j);
            IF l_acc_seg.seg_num = l_segemnt.seg_num
            THEN
               l_has_the_seg := 1;
               EXIT;
            END IF;
          END LOOP;
        END IF;

        IF l_has_the_seg = 0 --the account don't have this segment
        THEN
            P_ACCOUNT := P_ACCOUNT || l_delimiter_label;
            P_ACCOUNT_DESC := P_ACCOUNT_DESC || l_delimiter_label;
        ELSE
            P_ACCOUNT := P_ACCOUNT || l_delimiter_label || l_acc_seg.flex_val;
            P_ACCOUNT_DESC := P_ACCOUNT_DESC || l_delimiter_label || l_acc_seg.flex_desc;
        END IF; --l_has_the_seg = 0 OR 1
      END LOOP; --FOR i IN l_all_segemnts.first .. l_all_segemnts.last LOOP
    END IF;

    --trim off the delimiter before first segment
    P_ACCOUNT := SUBSTR(P_ACCOUNT, 2, length(P_ACCOUNT)-1);
    P_ACCOUNT_DESC := SUBSTR(P_ACCOUNT_DESC, 2, length(P_ACCOUNT_DESC)-1);

    --dbms_output.put_line(P_ACCOUNT);
    --dbms_output.put_line(P_ACCOUNT_DESC);

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        P_ACCOUNT := '';
        P_ACCOUNT_DESC := '';
  END Get_Account_Combo_and_Desc;

  --==========================================================================
  --  PROCEDURE NAME:
  --    GL_Validation                 Public
  --
  --  DESCRIPTION:
  --      This procedure checks GL Journals and output the invalid ones.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      IN: P_COA_ID                NUMBER              ID of chart of accounts
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of the ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Specified journal source
  --      In: P_JOURNAL_CTG           VARCHAR2            Specified journal category,All the cash related journal categories.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      03/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --      10/10/2008     Chaoqun Wu          Fix bug#7475903
  --      14/10/2008     Chaoqun Wu          Fix bug#7481841
  --      15/12/2008     Shujuan Yan         Fix bug#7626489
  --===========================================================================
  PROCEDURE GL_Validation( errbuf          OUT NOCOPY VARCHAR2
                          ,retcode         OUT NOCOPY VARCHAR2
                          ,P_COA_ID        IN NUMBER
                          ,P_LE_ID         IN NUMBER
                          ,P_LEDGER_ID     IN NUMBER
                          ,P_START_PERIOD  IN VARCHAR2
                          ,P_END_PERIOD    IN VARCHAR2
                          ,P_SOURCE        IN VARCHAR2
                          ,P_JOURNAL_CTG   IN VARCHAR2
                          ,P_STATUS        IN VARCHAR2
                          ,P_COM_SEG       IN VARCHAR2  --Added for CNAO Enhancement
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='GL_Validation';

    l_le_id                             NUMBER := P_LE_ID;
    l_coa_id                            NUMBER := P_COA_ID;
    l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_period_from                       GL_PERIODS.period_name%TYPE := P_START_PERIOD;
    l_period_to                         GL_PERIODS.period_name%TYPE := P_END_PERIOD;
    l_source                            gl_je_sources_tl.je_source_name%TYPE :=P_SOURCE;
    l_journal_ctg                       gl_je_categories_tl.user_je_category_name%TYPE :=P_JOURNAL_CTG;
    l_le_name                           VARCHAR2(240);
    l_status                            GL_JE_HEADERS.STATUS%TYPE := P_STATUS;
    l_sts_settle                        VARCHAR2(200) := '';    -- the 'where' limitation sqls for certain status
    l_check_flg                         VARCHAR2(10) :='FALSE'; -- Flag to determine whether the check of JOURNAL will be continued

    -- leger parameters
    --l_sob_id                            NUMBER := P_SOB_ID;
    l_ledger_name                       VARCHAR2(30);

    l_xml_item                          XMLTYPE;
    l_xml_line_items                    XMLTYPE;
    l_xml_line                          XMLTYPE;
    l_xml_jnl_items                     XMLTYPE;
    l_xml_journal                       XMLTYPE;
    l_xml_all                           XMLTYPE;
    l_xml_root                          XMLTYPE;

    l_dff_check                         VARCHAR2(1);   --result of DFF Assignment check
    --l_source_meaning                    varchar2(150); --meaning of GL journal OR InterCom Transaction
    l_period_name                       gl_periods.period_name%TYPE;
    l_period_year                       gl_periods.period_year%TYPE;
    l_period_num                        gl_periods.period_num%TYPE;
    l_ccid                              GL_CODE_COMBINATIONS.Code_Combination_Id%TYPE;
    l_account                           VARCHAR2(2000); --account's flexfield
    l_account_desc                      VARCHAR2(4000);--account's description
    l_cash_related_item                 varchar2(150); --cash related item of a line
    l_csi_check                         varchar2(2);   --blank or not of cash related item
    l_line_check                        varchar2(20);  --result of a line's validation
    l_line_err_msg                      varchar2(2000);--error message of the line

    l_jnl_count                         number;        --count of all journals
    l_jnl_valided                       number;        --flag of a journal is valided or not
    l_invalid_jnl_count                 number;        --count of all invalid journals
    l_invalid_lines                     number;        --count of all invalid lines
    l_invalid_line_4_jnl                number;        --count of invalid lines of a journal

    type t_bulk_jnl_catg   is table of  gl_je_categories_tl.je_category_name%type;
    l_all_jnl_catg                      t_bulk_jnl_catg;
    l_jnl_catg                          gl_je_categories_tl.je_category_name%TYPE;
    l_jnl_src                           gl_je_sources_tl.je_source_name%TYPE;

    l_je_header_id                      GL_JE_HEADERS.JE_HEADER_ID%TYPE;
    l_je_status                         GL_JE_HEADERS.STATUS%TYPE;      -- JOURNAL status
    l_je_batch_name                     GL_JE_BATCHES.name%TYPE;
    l_je_name                           GL_JE_HEADERS.name%TYPE;
    l_je_source                         GL_JE_HEADERS.je_source%TYPE;
    l_je_usr_source                     gl_je_sources_tl.user_je_source_name%TYPE;
    l_je_catg                           GL_JE_HEADERS.je_category%TYPE;
    l_je_usr_catg                       gl_je_categories_tl.user_je_category_name%TYPE;
    l_je_eff_date                       GL_JE_HEADERS.default_effective_date%TYPE;
    l_je_desc                           GL_JE_HEADERS.description%TYPE;
    l_je_line_num                       GL_JE_LINES.je_line_num%TYPE;
    l_je_line_desc                      GL_JE_LINES.description%TYPE;
    l_language                          VARCHAR(100):=userenv('LANG');
    l_characterset                      varchar(245);

    --Cursor to get all periods between (P_START_PERIOD, P_END_PERIOD).
    CURSOR c_period_name IS
    SELECT gp.period_name, gp.period_year, gp.period_num
      FROM gl_periods gp, GL_LEDGERS ledger
     WHERE ledger.ledger_id = l_ledger_id           --using variable P_LEDGER_ID
       AND ledger.period_set_name = gp.PERIOD_SET_NAME
       AND ledger.accounted_period_type = gp.period_type
       AND gp.start_date between
           (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND GP.period_name = l_period_from) --using parameter P_START_PERIOD
       and (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND GP.period_name = l_period_to)   --using parameter P_END_PERIOD
     ORDER BY gp.start_date
          ;

    --Cursor to get all Cash Related Journal Categories
    -- ?? not sure
    CURSOR c_all_jnl_catg IS
    SELECT jec.je_category_name                catg_name
          --,jec.user_je_category_name           catg_user_name
      FROM gl_je_categories_tl                 jec
          ,JA_CN_DFF_ASSIGNMENTS               DFF
     WHERE DFF.DFF_TITLE_CODE = 'JOCA'
       AND jec.context = DFF.CONTEXT_CODE
       AND jec.language = userenv('LANG')
       AND nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',jec.attribute1, 'ATTRIBUTE2',jec.attribute2,
                 'ATTRIBUTE3',jec.attribute3, 'ATTRIBUTE4',jec.attribute4, 'ATTRIBUTE5',jec.attribute5),
               'N') = 'Y'
       AND DFF.Chart_Of_Accounts_Id = l_coa_id --Added for fixing bug#7475903
          ;

    /*--Cursor to get all Journal Sources
      CURSOR c_all_jnl_src IS
      SELECT jes.je_source_name                  src_name
             --,jes.user_je_source_name             src_user_name
      FROM gl_je_sources_tl                    jes
      WHERE jes.language = userenv('LANG')
      ;
    */

    --Cursor to get information of GL journals in the specified period,
    -- whose categories are the specified one and thus surely cash ralated.
    CURSOR c_gl IS
    SELECT DISTINCT
           jeh.je_header_id                    jnl_id
          ,jeb.name                            batch
          ,jeh.name                            jnl_name
          ,jeh.je_source                       jnl_source
          ,jeh.je_category                     jnl_catg
          ,jeh.default_effective_date          jnl_eff_date
          ,jeh.description                     jnl_des
          ,src_t.user_je_source_name           jnl_usr_source
          ,catg_t.user_je_category_name        jnl_usr_catg
          ,jeh.status                          jeh_status
      FROM GL_JE_BATCHES                       jeb
          ,GL_JE_HEADERS                       jeh
          ,gl_je_sources_tl                    src_t
          ,gl_je_categories_tl                 catg_t
     WHERE jeh.ledger_id = l_ledger_id         --using variable l_sob_id
       AND jeb.je_batch_id + 0 = jeh.je_batch_id + 0
       AND jeb.je_batch_id > 0
       AND jeh.period_name = l_period_name     --using variable l_period_name
       AND jeh.je_category = l_jnl_catg        --using variable l_jnl_catg
       AND jeh.je_source = l_jnl_src           --using variable l_jnl_src
           -- Select certain transactions settle for the certain P_STATUS :
           -- While 'null' return all the status,while not return transactions with status of 'P_status'
       AND (jeh.status = NVL(P_STATUS,'') or P_STATUS IS NULL)
       AND src_t.je_source_name = jeh.je_source
       AND src_t.language = userenv('LANG')         -- ?? l_language
       AND catg_t.je_category_name = jeh.je_category
       AND catg_t.language = userenv('LANG')        -- ?? l_language
          ;

    --Cursor to get specified GL Journal's lines.
    CURSOR c_gl_lines IS
    SELECT DISTINCT               --Added for fixing bug#7475903
           jel.je_line_num                     line_num
          ,jel.description                     line_desc
          ,jel.code_combination_id             account_ccid
          ,decode(jel.context, dffa.context_code,
                  decode(dffa.attribute_column, 'ATTRIBUTE1',jel.attribute1, 'ATTRIBUTE2',jel.attribute2,
                       'ATTRIBUTE3',jel.attribute3, 'ATTRIBUTE4',jel.attribute4, 'ATTRIBUTE5',jel.attribute5,
                       'ATTRIBUTE6',jel.attribute6, 'ATTRIBUTE7',jel.attribute7, 'ATTRIBUTE8',jel.attribute8,
                       'ATTRIBUTE9',jel.attribute9, 'ATTRIBUTE10',jel.attribute10, 'ATTRIBUTE11',jel.attribute11,
                       'ATTRIBUTE12',jel.attribute12, 'ATTRIBUTE13',jel.attribute13, 'ATTRIBUTE14',jel.attribute14,
                       'ATTRIBUTE15',jel.attribute15)
                  )                            cash_related_item
      FROM GL_JE_LINES                         jel
          ,ja_cn_dff_assignments               dffa
          ,GL_CODE_COMBINATIONS                codecmb  --Added for CNAO Enhancement
          ,FND_SEGMENT_ATTRIBUTE_VALUES        fsav
     WHERE jel.je_header_id = l_je_header_id   --using variable l_je_header_id
           -- to locate cash flow item in dff_assignment
       AND dffa.Application_Id = 101
       AND dffa.chart_of_accounts_id = l_coa_id    --using variable l_coa_id
       AND dffa.dff_title_code='GLLI'

       --Added for CNAO Enhancement begin
       AND codecmb.chart_of_accounts_id=dffa.chart_of_accounts_id
       AND codecmb.code_combination_id = jel.code_combination_id
       AND fsav.application_id  = 101
       AND fsav.id_flex_num  = l_coa_id
       AND fsav.attribute_value = 'Y'
       AND fsav.segment_attribute_type = 'GL_BALANCING'
       AND  (P_COM_SEG is null
          OR P_COM_SEG =
              DECODE(FSAV.APPLICATION_COLUMN_NAME,
                    'SEGMENT1',codecmb.SEGMENT1, 'SEGMENT2',codecmb.SEGMENT2, 'SEGMENT3',codecmb.SEGMENT3,
                    'SEGMENT4',codecmb.SEGMENT4, 'SEGMENT5',codecmb.SEGMENT5, 'SEGMENT6',codecmb.SEGMENT6,
                    'SEGMENT7',codecmb.SEGMENT7, 'SEGMENT8',codecmb.SEGMENT8, 'SEGMENT9',codecmb.SEGMENT9,
                    'SEGMENT10',codecmb.SEGMENT10, 'SEGMENT11',codecmb.SEGMENT11, 'SEGMENT12',codecmb.SEGMENT12,
                    'SEGMENT13',codecmb.SEGMENT13, 'SEGMENT14',codecmb.SEGMENT14, 'SEGMENT15',codecmb.SEGMENT15,
                    'SEGMENT16',codecmb.SEGMENT16, 'SEGMENT17',codecmb.SEGMENT17, 'SEGMENT18',codecmb.SEGMENT18,
                    'SEGMENT19',codecmb.SEGMENT19, 'SEGMENT20',codecmb.SEGMENT20, 'SEGMENT21',codecmb.SEGMENT21,
                    'SEGMENT22',codecmb.SEGMENT22, 'SEGMENT23',codecmb.SEGMENT23, 'SEGMENT24',codecmb.SEGMENT24,
                    'SEGMENT25',codecmb.SEGMENT25, 'SEGMENT26',codecmb.SEGMENT26, 'SEGMENT27',codecmb.SEGMENT27,
                    'SEGMENT28',codecmb.SEGMENT28, 'SEGMENT29',codecmb.SEGMENT29, 'SEGMENT30',codecmb.SEGMENT30
                    )
             )
        ORDER BY jel.je_line_num ASC;
      --Added for CNAO Enhancement end


  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_LE_ID '||P_LE_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_START_PERIOD '||P_START_PERIOD
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_END_PERIOD '||P_END_PERIOD
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_SOURCE '||P_SOURCE
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_JOURNAL_CTG '||P_JOURNAL_CTG
                    );
      FND_LOG.String( l_proc_level                                      --Added for CNAO Enhancement
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_COM_SEG '||P_COM_SEG
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    --Check Profile
    IF NOT(JA_CN_UTILITY.Check_Profile)
    THEN
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF;

    --Get the BSV reffered to the current legal entity and ledger
    DELETE
    FROM   JA_CN_LEDGER_LE_BSV_GT
           ;
    COMMIT ;
    --
    IF ja_cn_utility.populate_ledger_le_bsv_gt( P_LEDGER_ID,P_LE_ID) <> 'S' THEN
       RETURN;
    END IF;

    --Start the XML file
    -- Updated by shujuan for bug 7626489
   l_characterset :=Fnd_Profile.VALUE(NAME => 'ICX_CLIENT_IANA_ENCODING');
   FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding= '||'"'||l_characterset||'"?>');

    --FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding="utf-8" ?>');
    /*FND_FILE.put_line(FND_FILE.output, '<GL_INVALID_JOURNALS>');
    FND_FILE.put_line(FND_FILE.output, '<P_START_PERIOD>' ||P_START_PERIOD||'</P_START_PERIOD>');
    FND_FILE.put_line(FND_FILE.output, '<P_END_PERIOD>' ||P_END_PERIOD||'</P_END_PERIOD>');
    FND_FILE.put_line(FND_FILE.output, '<P_COMPANY_SEGMENT>' ||P_COM_SEGMENT||'</P_COMPANY_SEGMENT>');
    FND_FILE.put_line(FND_FILE.output, '<P_SOURCE>' ||P_SOURCE||'</P_SOURCE>');
    FND_FILE.put_line(FND_FILE.output, '<P_JOURNAL_CTG>' ||P_JOURNAL_CTG||'</P_JOURNAL_CTG>');*/
    SELECT XMLELEMENT( "P_START_PERIOD",P_START_PERIOD ) INTO l_xml_item FROM dual;
      l_xml_all := l_xml_item;
    SELECT XMLELEMENT( "P_END_PERIOD",P_END_PERIOD ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "P_COMPANY_SEGMENT",P_COM_SEG ) INTO l_xml_item FROM dual;     -- not sure
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    -- ?? not sure of the source
    SELECT XMLELEMENT( "P_SOURCE",P_SOURCE ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "P_JOURNAL_CTG",P_JOURNAL_CTG ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "P_STATUS",P_STATUS ) INTO l_xml_item FROM dual;     --Fix bug# 7481841 added
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --Get ledger Name
    SELECT ledger.name
      INTO l_ledger_name
      FROM GL_LEDGERS ledger
     WHERE ledger.ledger_id = l_ledger_id
          ;
    -- FND_FILE.put_line(FND_FILE.output, '<SOB_NAME>' ||l_sob_name||'</SOB_NAME>');
    SELECT XMLELEMENT( "LEDGER_NAME",l_ledger_name ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    -- Fix bug#6654759 delete start
    /*
    --Get LE Name
    -- ?? not sure , the name from hr_all_organization looks make no sense.
    SELECT HAOTL.name -- hao.name
      INTO l_le_name
      FROM HR_ALL_ORGANIZATION_UNITS    HAO
          ,HR_ALL_ORGANIZATION_UNITS_TL HAOTL
     WHERE HAO.ORGANIZATION_ID = l_le_id
       AND HAO.ORGANIZATION_ID = HAOTL.ORGANIZATION_ID
       AND HAOTL.LANGUAGE = USERENV('LANG')
       ;*/
    -- Fix bug#6654759 delete end

    -- Fix bug#6654759 add start
    --Get LE Name
    SELECT XEP.name
      INTO l_le_name
      FROM XLE_ENTITY_PROFILES XEP
    WHERE XEP.LEGAL_ENTITY_ID = l_le_id;
    -- Fix bug#6654759 add end

    /*FND_FILE.put_line(FND_FILE.output, '<LE_NAME>' ||l_le_name||'</LE_NAME>');*/
    SELECT XMLELEMENT( "LE_NAME",l_le_name ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --1. Check whether the DFF assignment of Journal Categories has been set or not.
    BEGIN
    SELECT DECODE(nvl(DFF.CONTEXT_CODE, ''), '', 'N',
                  DECODE(nvl(DFF.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
      INTO l_dff_check
      FROM JA_CN_DFF_ASSIGNMENTS               DFF
     WHERE DFF.DFF_TITLE_CODE = 'JOCA'
       AND DFF.CHART_OF_ACCOUNTS_ID=l_coa_id
          ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_dff_check := 'N';
    END;
    IF l_dff_check = 'N'
    THEN
      raise JA_CN_INCOMPLETE_DFF_ASSIGN;
    END IF;

    --l_source_meaning := Source_Meaning(P_SOURCE => 'GLJE');   --Get source meaning

    --Get Journal Source; P_SOURCE is a required parameter.
    SELECT jes.je_source_name
      INTO l_jnl_src
      FROM gl_je_sources_tl                    jes
     WHERE jes.user_je_source_name = l_source              -- ?? not sure
       AND jes.language = l_language;                        -- ?? userenv('LANG');

    --Get cash related Journal Categories: specified in P_JOURNAL_CTG or all.
    l_all_jnl_catg := t_bulk_jnl_catg();
    l_all_jnl_catg.EXTEND(1);
    IF l_journal_ctg is not null
    THEN
      SELECT distinct jec.je_category_name                catg_name
        INTO l_jnl_catg
        FROM gl_je_categories_tl                 jec
            ,JA_CN_DFF_ASSIGNMENTS               DFF
       WHERE DFF.DFF_TITLE_CODE = 'JOCA'
         AND jec.context = DFF.CONTEXT_CODE
         AND jec.language = l_language
         AND jec.user_je_category_name = l_journal_ctg
         AND nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',jec.attribute1,
                   'ATTRIBUTE2',jec.attribute2, 'ATTRIBUTE3',jec.attribute3,
                   'ATTRIBUTE4',jec.attribute4, 'ATTRIBUTE5',jec.attribute5),
                 'N') = 'Y'
            ;
      l_all_jnl_catg(1) := l_jnl_catg;
    ELSE
      OPEN c_all_jnl_catg;
        FETCH c_all_jnl_catg BULK COLLECT INTO l_all_jnl_catg;
      CLOSE c_all_jnl_catg;
    END IF;

    --2. Get invalid journals
    l_jnl_count := 0;
    l_invalid_jnl_count := 0;
    l_invalid_lines := 0;

    IF l_all_jnl_catg.first is not null
    THEN
      FOR i IN l_all_jnl_catg.first .. l_all_jnl_catg.last LOOP --For cash related Categories.
        l_jnl_catg := l_all_jnl_catg(i);

        OPEN c_period_name; --Get name of all periods between (P_START_PERIOD, P_END_PERIOD).
        LOOP
          FETCH c_period_name INTO l_period_name
                                  ,l_period_year
                                  ,l_period_num
                                  ;
          EXIT WHEN c_period_name%NOTFOUND;

          -- For all journals in the specified Category, Source, and period.
          -- Do not check journals' status.
          OPEN c_gl;
          LOOP
            FETCH c_gl INTO l_je_header_id
                           ,l_je_batch_name
                           ,l_je_name
                           ,l_je_source
                           ,l_je_catg
                           ,l_je_eff_date
                           ,l_je_desc
                           ,l_je_usr_source
                           ,l_je_usr_catg
                           ,l_je_status
                           ;
            EXIT WHEN c_gl%NOTFOUND;

       /*     -- Select certain ledger settle for the certain P_STATUS :
            l_check_flg := 'FALSE';         --flag to determin whether the check will continue

            IF NVL(l_je_status,'')<>NVL(l_status,'NULL') THEN
               IF l_je_status<>'P' OR l_je_status<>'U' THEN
                  l_check_flg:='TRUE';
               END IF;
            ELSE
               l_check_flg:='TRUE';
            END IF;

            IF l_check_flg = 'TRUE' THEN*/

                l_jnl_count := l_jnl_count + 1; --This journal is a new one
                l_invalid_line_4_jnl := 0;
                l_jnl_valided := 0;
                l_xml_jnl_items := null;

                OPEN c_gl_lines; --for the journal's lines.
                LOOP
                  FETCH c_gl_lines INTO l_je_line_num
                                       ,l_je_line_desc
                                       ,l_ccid
                                       ,l_cash_related_item
                                       ;
                  EXIT WHEN c_gl_lines%NOTFOUND;

                  l_csi_check := 'NB';
                  IF l_cash_related_item is null
                  THEN
                    l_csi_check := 'B';
                  END IF;

                  l_line_check := Line_Check( P_COA_ID            => P_COA_ID
                                             ,P_LEDGER_ID         => P_LEDGER_ID
                                             ,P_LE_ID             => l_le_id
                                             ,P_SOURCE            => 'GL'
                                             ,P_JT_ID             => l_je_header_id
                                             ,P_LINE_NUM          => TO_CHAR(l_je_line_num)
                                             ,P_CCID              => l_ccid
                                             ,P_CASH_RELATED_ITEM => l_csi_check
                                            );
                  IF l_line_check <> 'EXCLUDED'
                  THEN  --The line has been checked, so the journal is valided.
                    l_jnl_valided := 1;
                  END IF;

                  IF l_line_check = 'NO_ITEM' or l_line_check = 'NO_ACCOUNT'
                  THEN
                    l_invalid_line_4_jnl := l_invalid_line_4_jnl + 1;
                    Get_Account_Combo_and_Desc( P_LEDGER_ID       => P_LEDGER_ID
                                               ,P_CCID            => l_ccid
                                               ,P_ACCOUNT         => l_account
                                               ,P_ACCOUNT_DESC    => l_account_desc
                                              );

                    IF l_line_check = 'NO_ITEM'
                    THEN
                      l_line_err_msg := l_msg_no_cashflow_item;
                    ELSE
                      l_line_err_msg := l_msg_no_cash_account;
                    END IF;

                    --Before first line of the journal, output the journal info
                    IF l_invalid_line_4_jnl = 1
                    THEN
                      /*FND_FILE.put_line(FND_FILE.output, '<JOURNAL>');
                      FND_FILE.put_line(FND_FILE.output, '<BATCH>' ||l_je_batch_name||'</BATCH>');
                      FND_FILE.put_line(FND_FILE.output, '<JOURNAL_NAME>' ||l_je_name||'</JOURNAL_NAME>');
                      FND_FILE.put_line(FND_FILE.output, '<SOURCE>' ||l_je_usr_source||'</SOURCE>');
                      FND_FILE.put_line(FND_FILE.output, '<JOURNAL_CTG>' ||l_je_usr_catg||'</JOURNAL_CTG>');
                      FND_FILE.put_line(FND_FILE.output, '<JOURNAL_EFF_DATE>' ||l_je_eff_date||'</JOURNAL_EFF_DATE>');
                      FND_FILE.put_line(FND_FILE.output, '<DESCRIPTION>' ||l_je_desc||'</DESCRIPTION>');*/
                      SELECT XMLELEMENT( "BATCH",l_je_batch_name ) INTO l_xml_item FROM dual;
                        l_xml_jnl_items := l_xml_item;
                      SELECT XMLELEMENT( "JOURNAL_NAME",l_je_name ) INTO l_xml_item FROM dual;
                        SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;
                      SELECT XMLELEMENT( "SOURCE",l_je_usr_source ) INTO l_xml_item FROM dual;
                        SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;
                      SELECT XMLELEMENT( "JOURNAL_CTG",l_je_usr_catg ) INTO l_xml_item FROM dual;
                        SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;
                      SELECT XMLELEMENT( "JOURNAL_EFF_DATE",l_je_eff_date ) INTO l_xml_item FROM dual;
                        SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;
                      SELECT XMLELEMENT( "DESCRIPTION",l_je_desc ) INTO l_xml_item FROM dual;
                        SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;
                    END IF;

                    --output the line
                    /*FND_FILE.put_line(FND_FILE.output, '<LINE>');
                      FND_FILE.put_line(FND_FILE.output, '<LINE_NUMBER>' ||l_je_line_num||'</LINE_NUMBER>');
                      FND_FILE.put_line(FND_FILE.output, '<ACCOUNT>' ||l_account||'</ACCOUNT>');
                      FND_FILE.put_line(FND_FILE.output, '<ACCOUNT_DESC>' ||l_account_desc||'</ACCOUNT_DESC>');
                      FND_FILE.put_line(FND_FILE.output, '<CASH_FLOW_ITEM>' ||l_cash_related_item||'</CASH_FLOW_ITEM>');
                      FND_FILE.put_line(FND_FILE.output, '<EXC_REASON>' ||l_line_err_msg||'</EXC_REASON>');
                    FND_FILE.put_line(FND_FILE.output, '</LINE>');*/
                    SELECT XMLELEMENT( "LINE_NUMBER",l_je_line_num ) INTO l_xml_item FROM dual;
                      l_xml_line_items := l_xml_item;
                    SELECT XMLELEMENT( "ACCOUNT",l_account ) INTO l_xml_item FROM dual;
                      SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                    SELECT XMLELEMENT( "ACCOUNT_DESC",l_account_desc ) INTO l_xml_item FROM dual;
                      SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                    SELECT XMLELEMENT( "CASH_FLOW_ITEM",l_cash_related_item ) INTO l_xml_item FROM dual;
                      SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                    SELECT XMLELEMENT( "EXC_REASON",l_line_err_msg ) INTO l_xml_item FROM dual;
                      SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;

                    SELECT XMLELEMENT( "LINE",l_xml_line_items ) INTO l_xml_line FROM dual;
                    --To concatenate the XML line as a journal item
                    SELECT XMLCONCAT( l_xml_jnl_items,l_xml_line ) INTO l_xml_jnl_items FROM dual;
                  END IF; --l_line_check = 'NO_ITEM' or l_line_check = 'NO_ACCOUNT'
                END LOOP;
                CLOSE c_gl_lines;

                IF l_jnl_valided = 0 --The journal has no line been checked, so excluded it.
                THEN
                  l_jnl_count := l_jnl_count -1;
                END IF;

                IF l_invalid_line_4_jnl > 0 --Has invalid lines, so the journal is a invalid one
                THEN
                  l_invalid_jnl_count := l_invalid_jnl_count + 1; --This journal is a invalid one
                  l_invalid_lines := l_invalid_lines + l_invalid_line_4_jnl; --Add the invalid lines of this journal

                  --Has output lines, should end the journal
                  /*FND_FILE.put_line(FND_FILE.output, '<INVALID_LINES_4_JNL>' ||l_invalid_line_4_jnl||'</INVALID_LINES_4_JNL>');
                  FND_FILE.put_line(FND_FILE.output, '</JOURNAL>');*/
                  SELECT XMLELEMENT( "INVALID_LINES_4_JNL",l_invalid_line_4_jnl ) INTO l_xml_item FROM dual;
                      SELECT XMLCONCAT( l_xml_jnl_items,l_xml_item) INTO l_xml_jnl_items FROM dual;

                  SELECT XMLELEMENT( "JOURNAL",l_xml_jnl_items ) INTO l_xml_journal FROM dual;
                  --To concatenate the journal into the output
                  SELECT XMLCONCAT( l_xml_all,l_xml_journal ) INTO l_xml_all FROM dual;
                END IF; --l_invalid_line_4_jnl

            --END IF; --cancle the Status judgment for Post and Unpost

          END LOOP;
          CLOSE c_gl;
        END LOOP;
        CLOSE c_period_name;
      END LOOP; --FOR i IN l_all_jnl_catg.first .. l_all_jnl_catg.last LOOP
    END IF;

    --End the XML file
    /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>' || TO_CHAR(l_jnl_count) || '</TOTAL_COUNT>');
    FND_FILE.put_line(FND_FILE.output, '<TOTAL_INVALID_JNL>' || TO_CHAR(l_invalid_jnl_count) || '</TOTAL_INVALID_JNL>');
    FND_FILE.put_line(FND_FILE.output, '<TOTAL_INVALID_LINES>' || TO_CHAR(l_invalid_lines) || '</TOTAL_INVALID_LINES>');
    FND_FILE.put_line(FND_FILE.output, '</GL_INVALID_JOURNALS>');*/
    SELECT XMLELEMENT( "TOTAL_COUNT",TO_CHAR(l_jnl_count) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "TOTAL_INVALID_JNL",TO_CHAR(l_invalid_jnl_count) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "TOTAL_INVALID_LINES",TO_CHAR(l_invalid_lines) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --To add root node for the xml output and then output it
    SELECT XMLELEMENT( "GL_INVALID_JOURNALS",l_xml_all ) INTO l_xml_root FROM dual;
    --FND_FILE.put_line(FND_FILE.output,l_xml_root.getclobval());

    JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.end'
                     ,'Exit procedure'
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    EXCEPTION
  	  WHEN JA_CN_INCOMPLETE_DFF_ASSIGN THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_INCOMPLETE_DFF_ASSIGN '
                         ,l_msg_incomplete_dff_assign);
        END IF;  --(l_proc_level >= l_dbg_level)
        /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>0</TOTAL_COUNT>');
        FND_FILE.put_line(FND_FILE.output, '<DFF_EXCEPTION>' || l_msg_incomplete_dff_assign || '</DFF_EXCEPTION>');
        FND_FILE.put_line(FND_FILE.output, '</GL_INVALID_JOURNALS>');*/
        SELECT XMLELEMENT( "TOTAL_COUNT",0 ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        SELECT XMLELEMENT( "DFF_EXCEPTION",l_msg_incomplete_dff_assign ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        --To add root node for the xml output and then output it
        SELECT XMLELEMENT( "GL_INVALID_JOURNALS",l_xml_all ) INTO l_xml_root FROM dual;
        JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

        retcode := 1;
        errbuf  := l_msg_incomplete_dff_assign;
    	/*WHEN JA_CN_NO_CASHACCOUNT THEN
    		Report it with l_msg_no_cash_account;
    	WHEN JA_CN_NO_CASHFLOWITEM THEN
    		Report it with l_msg_no_cashflow_item;*/
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>0</TOTAL_COUNT>');
        FND_FILE.put_line(FND_FILE.output, '<OTHER_EXCEPTION>' || 'Other_Exception' || '</OTHER_EXCEPTION>');
        FND_FILE.put_line(FND_FILE.output, '</GL_INVALID_JOURNALS>');*/
        SELECT XMLELEMENT( "TOTAL_COUNT",0 ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        SELECT XMLELEMENT( "DFF_EXCEPTION",'Other_Exception' ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        --To add root node for the xml output and then output it
        SELECT XMLELEMENT( "GL_INVALID_JOURNALS",l_xml_all ) INTO l_xml_root FROM dual;
        JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

        retcode := 2;
        errbuf  := SQLCODE||':'||SQLERRM;
  END GL_Validation;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Intercompany_Validation       Public
  --
  --  DESCRIPTION:
  --      This procedure checks Intercompany transactions and output
  --      the invalid ones.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              chart of accounts ID
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of the ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_STATUS                VARCHAR2            The gl status transfered from AGIS
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      02/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --      14/10/2008     Chaoqun Wu          Fix bug#7481841
  --      17/10/2008     Chaoqun Wu          Fix bug#7487439
  --      15/12/2008     Shujuan Yan         Fix bug#7626489
  --===========================================================================
  PROCEDURE Intercompany_Validation( errbuf          OUT NOCOPY VARCHAR2
                                    ,retcode         OUT NOCOPY VARCHAR2
                                    ,P_COA_ID        IN NUMBER
                                    ,P_LE_ID         IN NUMBER
                                    ,P_LEDGER_ID     IN NUMBER
                                    ,P_START_PERIOD  IN VARCHAR2
                                    ,P_END_PERIOD    IN VARCHAR2
                                    ,P_STATUS        IN VARCHAR2
                                    ,P_COM_SEG       IN VARCHAR2  --Added for CNAO Enhancement
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Intercompany_Validation';

    l_coa_id                            NUMBER := P_COA_ID;
    l_le_id                             NUMBER := P_LE_ID;
    l_le_name                           VARCHAR2(240);
    l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_period_from                       gl_periods.period_name%TYPE := P_START_PERIOD;
    l_period_to                         gl_periods.period_name%TYPE := P_END_PERIOD;
    l_com_seg                           VARCHAR2(25) := P_COM_SEG; --Added for CNAO Enhancement
    l_ledger_name                       VARCHAR2(30);
    --l_com_segment                       VARCHAR2(150) := P_COM_SEGMENT;
    --l_status                            FUN_TRX_HEADERS.STATUS%TYPE := P_STATUS;
    --l_sts_settle                        VARCHAR2(200) := '';

    l_xml_item                          XMLTYPE;
    l_xml_line_items                    XMLTYPE;
    l_xml_line                          XMLTYPE;
    l_xml_tr_items                      XMLTYPE;
    l_xml_tr                            XMLTYPE;
    l_xml_all                           XMLTYPE;
    l_xml_root                          XMLTYPE;

    l_dff_check                         varchar2(1);   --result of DFF Assignment check
    --l_source_meaning                    varchar2(150); --meaning of GL journal OR InterCom Transaction
    l_period_name                       gl_periods.period_name%TYPE;
    l_period_year                       gl_periods.period_year%TYPE;
    l_period_num                        gl_periods.period_num%TYPE;
    l_ccid                              GL_CODE_COMBINATIONS.Code_Combination_Id%TYPE;
    l_account                           VARCHAR2(2000);        --account's flexfield
    l_account_desc                      VARCHAR2(4000);        --account's description
    l_cash_related_item                 varchar2(150);         --cash related item of a line
    l_csi_check                         varchar2(2);           --blank or not of cash related item
    l_line_check                        varchar2(20);          --result of a line's validation
    l_line_err_msg                      varchar2(2000);        --error message of the line

    -- trx_batch
    l_trxb_id                            fun_trx_batches.batch_id%TYPE;
    l_trxb_num                           fun_trx_batches.batch_number%TYPE;

    -- trx_headers
    l_trx_id                             fun_trx_headers.Trx_Id%TYPE;
    l_trx_num                            fun_trx_headers.Trx_Number%TYPE;
    l_trx_type                           fun_trx_types_tl.trx_type_name%TYPE;
    l_trx_send_name                      hz_parties.party_name%TYPE;
    l_trx_recv_name                      hz_parties.party_name%TYPE;
    l_trx_gl_date                        fun_trx_batches.gl_date%TYPE;
    l_trx_desc                           fun_trx_headers.description%TYPE;
    l_trx_line_num                       varchar2(20);
    l_trx_line_sob                       NUMBER;
    l_trx_line_le                        NUMBER;
    l_trx_line_com_seg                   fun_trx_batches.description%TYPE;

    -- trx_lines
    l_trxl_num                           fun_trx_lines.line_id%TYPE;
    l_trxl_id                            fun_trx_lines.trx_id%TYPE;
    l_distl_id                           NUMBER;
    l_distl_num                          fun_dist_lines.dist_number%TYPE;
    l_distl_party_id                     fun_dist_lines.party_id%Type;
    l_distl_party_type_flg               fun_dist_lines.party_type_flag%TYPE;
    l_distl_dist_type_flg                fun_dist_lines.dist_type_flag%TYPE;
    l_distl_ccid                         fun_dist_lines.ccid%TYPE;
    l_codecmb_coa_id                     gl_code_combinations.chart_of_accounts_id%TYPE;
    l_codecmb_com_seg                    gl_code_combinations.segment1%TYPE;

    --trx date
    l_period_start_date                 date;
    l_perioD_end_date                   date;

    -- l_trx_send_com_seg                   gl_iea_subsidiaries.company_value%TYPE;
    -- l_trx_recv_com_seg                   gl_iea_subsidiaries.company_value%TYPE;
    l_trx_send_ledger_id                 NUMBER;                --ledger id of tr's sender
    l_trx_recv_ledger_id                 NUMBER;                --ledger id of tr's receiver
    l_trx_send_le_id                     NUMBER;                --legal entity id of tr's sender
    l_trx_recv_le_id                     NUMBER;                --legal entity id of tr's receiver
    l_trx_sender_c                       NUMBER;                --flag of tr's sender is in current LE or not
    l_trx_receiver_c                     NUMBER;                --flag of tr's receiver is in current LE or not

    -- globale flg for transactions
    l_trx_sr_flg                         varchar2(1):='X';      -- flag to distinguish the diference between sender(S) and receiver(R)(S/R/X).
    l_trx_inter_flg                      varchar2(1):='N';      -- flag to distinguish whether the header is a intercompany  operation(Y/N).
    l_trx_line_inter_flag                varchar2(1):='N';      -- flag to distinguish whether the dist_line is a intercompany  operation(Y/N).
    l_tr_valided_flg                     varchar2(1):='N';      -- flag to distinguish whether the header in one loop is recorded;
    -- counters
    l_tr_count                          number;                --count of all transactions
    l_tr_valided                        number;                --flag of a transaction is valided or not
    l_invalid_tr_count                  number;                --count of all invalid transactions
    l_invalid_lines                     number;                --count of all invalid lines
    l_invalid_line_4_tr                 number;                --count of invalid lines of a transaction
    l_characterset                      varchar(245);

    --Cursor to get all periods between (P_START_PERIOD, P_END_PERIOD).
    CURSOR c_period_name IS
    SELECT gp.period_name
         , gp.period_year
         , gp.period_num
         , gp.start_date
         , gp.end_date
      FROM gl_periods gp, GL_LEDGERS ledger
     WHERE ledger.ledger_id = l_ledger_id           --using variable l_ledger_id
       AND ledger.period_set_name = GP.PERIOD_SET_NAME
       AND ledger.accounted_period_type = gp.period_type
       AND gp.start_date between
           (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND gp.period_name = l_period_from) --using parameter P_START_PERIOD
       and (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND gp.period_name = l_period_to)   --using parameter P_END_PERIOD
     ORDER BY gp.start_date
          ;
    /*
    --Cursor to get the BSV according to the current legal entity and ledger id
    CURSOR c_bsvs IS
    SELECT bsv.*
    FROM   JA_CN_LEDGER_LE_BSV_GT bsv
    WHERE  bsv.ledger_id = P_LEDGER_ID
      AND  bsv.legal_entity_id = P_LE_ID
      AND  bsv.chart_of_accounts_id = P_COA_ID
           ;
    */

    --Cursor to get information of Transactions in the specified period.
    --Only consider Transactions whose sender and receiver transfer flag are 'Yes'.
    CURSOR c_tr IS
    SELECT trxh.trx_id                         trxh_id
          ,trxh.trx_number                     trxh_number
          ,trxtype.trx_type_name               trxtype_name
          ,party_init.party_name               trxh_send_name
          ,party_reci.party_name               trxh_recv_name
          ,trxb.gl_date                        trxb_gl_date
          ,trxh.description                    trxb_desc
          ,trxb.from_ledger_id                 trxb_send_ledger_id
          ,trxh.to_ledger_id                   trxh_recv_ledger_id
          ,trxb.from_le_id                     trxb_send_le_id
          ,trxh.to_le_id                       trxh_recv_le_id
          ,trxb.batch_number                   trxb_number
/*          ,nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',trxh.attribute1, 'ATTRIBUTE2',trxh.attribute2,
               'ATTRIBUTE3',trxh.attribute3, 'ATTRIBUTE4',trxh.attribute4, 'ATTRIBUTE5',trxh.attribute5,
               'ATTRIBUTE6',trxh.attribute6, 'ATTRIBUTE7',trxh.attribute7, 'ATTRIBUTE8',trxh.attribute8,
               'ATTRIBUTE9',trxh.attribute9, 'ATTRIBUTE10',trxh.attribute10, 'ATTRIBUTE11',trxh.attribute11,
               'ATTRIBUTE12',trxh.attribute12, 'ATTRIBUTE13',trxh.attribute13, 'ATTRIBUTE14',trxh.attribute14,
               'ATTRIBUTE15',trxh.attribute15)
               , '')                           trxh_cash_related_item*/
    FROM   FUN_TRX_HEADERS                     trxh
          ,FUN_TRX_BATCHES                     trxb
          ,FUN_TRX_TYPES_TL                    trxtype
          ,HZ_PARTIES                          party_init
          ,HZ_PARTIES                          party_reci
          --,JA_CN_DFF_ASSIGNMENTS              dff
     WHERE trxh.batch_id=trxb.batch_id
      AND  trxb.trx_type_id=trxtype.trx_type_id
      AND  party_init.party_id=trxh.initiator_id
      AND  party_reci.Party_Id=trxh.recipient_id
      --   AND  dff.DFF_TITLE_CODE='IITL'--'JOCA'
      --AND  trxh.status = 'COMPLETE'
      --AND  trxb.status = 'COMPLETE'
           -- Select certain transactions settle for the certain P_STATUS :
           -- While 'null' return all the status,while not return transactions with status of 'P_status'
      AND  (trxh.status = NVL(P_STATUS,'') or P_STATUS IS NULL)
           -- determine the trx type is transfered to GL
      AND  trxh.invoice_flag='N'
           -- add period limite , have to limite the gl_date in the period.
      AND  trxb.gl_date between l_period_start_date and l_perioD_end_date
      AND  trxtype.language=userenv('LANG');

    --Cursor to get specified transaction's lines, including both sender and receiver parts.
    CURSOR c_tr_lines IS
    SELECT DISTINCT
           trl.Line_Number                     line_num
          ,trl.line_id                         line_id
          ,trldist.dist_id                     distl_id
          ,trldist.dist_number                 distl_num
          ,trldist.party_id                    distl_party_id
          ,trldist.party_type_flag             distl_party_flg
          ,trldist.dist_type_flag              distl_dist_flg
          ,trldist.ccid                        distl_ccid
          ,codecmb.chart_of_accounts_id        codecmb_coa_id
           --segment FSAV.APPLICATION_COLUMN_NAME of codecmb
          ,DECODE(FSAV.APPLICATION_COLUMN_NAME,
                  'SEGMENT1',codecmb.SEGMENT1, 'SEGMENT2',codecmb.SEGMENT2, 'SEGMENT3',codecmb.SEGMENT3,
                  'SEGMENT4',codecmb.SEGMENT4, 'SEGMENT5',codecmb.SEGMENT5, 'SEGMENT6',codecmb.SEGMENT6,
                  'SEGMENT7',codecmb.SEGMENT7, 'SEGMENT8',codecmb.SEGMENT8, 'SEGMENT9',codecmb.SEGMENT9,
                  'SEGMENT10',codecmb.SEGMENT10, 'SEGMENT11',codecmb.SEGMENT11, 'SEGMENT12',codecmb.SEGMENT12,
                  'SEGMENT13',codecmb.SEGMENT13, 'SEGMENT14',codecmb.SEGMENT14, 'SEGMENT15',codecmb.SEGMENT15,
                  'SEGMENT16',codecmb.SEGMENT16, 'SEGMENT17',codecmb.SEGMENT17, 'SEGMENT18',codecmb.SEGMENT18,
                  'SEGMENT19',codecmb.SEGMENT19, 'SEGMENT20',codecmb.SEGMENT20, 'SEGMENT21',codecmb.SEGMENT21,
                  'SEGMENT22',codecmb.SEGMENT22, 'SEGMENT23',codecmb.SEGMENT23, 'SEGMENT24',codecmb.SEGMENT24,
                  'SEGMENT25',codecmb.SEGMENT25, 'SEGMENT26',codecmb.SEGMENT26, 'SEGMENT27',codecmb.SEGMENT27,
                  'SEGMENT28',codecmb.SEGMENT28, 'SEGMENT29',codecmb.SEGMENT29, 'SEGMENT30',codecmb.SEGMENT30
                  )                            fsav_com_seg
           -- get cash flow item
          ,nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',trldist.attribute1, 'ATTRIBUTE2',trldist.attribute2,
               'ATTRIBUTE3',trldist.attribute3, 'ATTRIBUTE4',trldist.attribute4, 'ATTRIBUTE5',trldist.attribute5,
               'ATTRIBUTE6',trldist.attribute6, 'ATTRIBUTE7',trldist.attribute7, 'ATTRIBUTE8',trldist.attribute8,
               'ATTRIBUTE9',trldist.attribute9, 'ATTRIBUTE10',trldist.attribute10, 'ATTRIBUTE11',trldist.attribute11,
               'ATTRIBUTE12',trldist.attribute12, 'ATTRIBUTE13',trldist.attribute13, 'ATTRIBUTE14',trldist.attribute14,
               'ATTRIBUTE15',trldist.attribute15)
               , '')                           trxh_cash_related_item
      FROM FUN_TRX_LINES                       trl
          ,FUN_DIST_LINES                      trldist
          ,GL_CODE_COMBINATIONS                codecmb
          ,FND_SEGMENT_ATTRIBUTE_VALUES        fsav
          ,JA_CN_DFF_ASSIGNMENTS               dff
     WHERE trl.line_id=trldist.line_id
       AND trl.trx_id=trldist.trx_id
       AND trldist.ccid=codecmb.code_combination_id
       AND trl.trx_id=l_trx_id                     --using variable l_trx_id
       AND codecmb.chart_of_accounts_id=P_COA_ID   --using variable p_coa_id
       AND trldist.dist_type_flag='L'              --select ones only transfered to GL
           --locate to the right segment attribute value
       AND fsav.application_id  = 101
       AND fsav.id_flex_num  = P_COA_ID
       AND fsav.attribute_value = 'Y'
       AND fsav.segment_attribute_type = 'GL_BALANCING'
       AND dff.DFF_TITLE_CODE='IITL'--'JOCA'
      --Added for CNAO Enhancement begin
       AND  (l_com_seg is null
          OR l_com_seg =
              DECODE(FSAV.APPLICATION_COLUMN_NAME,
                    'SEGMENT1',codecmb.SEGMENT1, 'SEGMENT2',codecmb.SEGMENT2, 'SEGMENT3',codecmb.SEGMENT3,
                    'SEGMENT4',codecmb.SEGMENT4, 'SEGMENT5',codecmb.SEGMENT5, 'SEGMENT6',codecmb.SEGMENT6,
                    'SEGMENT7',codecmb.SEGMENT7, 'SEGMENT8',codecmb.SEGMENT8, 'SEGMENT9',codecmb.SEGMENT9,
                    'SEGMENT10',codecmb.SEGMENT10, 'SEGMENT11',codecmb.SEGMENT11, 'SEGMENT12',codecmb.SEGMENT12,
                    'SEGMENT13',codecmb.SEGMENT13, 'SEGMENT14',codecmb.SEGMENT14, 'SEGMENT15',codecmb.SEGMENT15,
                    'SEGMENT16',codecmb.SEGMENT16, 'SEGMENT17',codecmb.SEGMENT17, 'SEGMENT18',codecmb.SEGMENT18,
                    'SEGMENT19',codecmb.SEGMENT19, 'SEGMENT20',codecmb.SEGMENT20, 'SEGMENT21',codecmb.SEGMENT21,
                    'SEGMENT22',codecmb.SEGMENT22, 'SEGMENT23',codecmb.SEGMENT23, 'SEGMENT24',codecmb.SEGMENT24,
                    'SEGMENT25',codecmb.SEGMENT25, 'SEGMENT26',codecmb.SEGMENT26, 'SEGMENT27',codecmb.SEGMENT27,
                    'SEGMENT28',codecmb.SEGMENT28, 'SEGMENT29',codecmb.SEGMENT29, 'SEGMENT30',codecmb.SEGMENT30
                    )
             )

      --Added for CNAO Enhancement end
      -- Fix bug#7487439 added begin
       AND EXISTS
       (
          SELECT * FROM   FUN_TRX_HEADERS                     trxh
                         ,FUN_TRX_BATCHES                     trxb
           WHERE trxh.batch_id=trxb.batch_id
            AND  trxh.invoice_flag='N'
            AND  trxh.trx_id=l_trx_id       --using variable l_trx_id
            AND
            (
             (     trxh.to_le_id = l_le_id --using variable l_le_id
               AND trxh.to_ledger_id = l_ledger_id --using variable l_le_id
               AND trldist.party_type_flag='R'
               AND trldist.dist_type_flag ='L'
             )
             OR
             (    trxb.from_le_id = l_le_id --using variable l_le_id
              AND trxb.from_ledger_id = l_ledger_id --using variable l_le_id
              AND trldist.party_type_flag='I'
              AND trldist.dist_type_flag ='L'
             )
            )
         )
        -- Fix bug#7487439 added end
          ;
  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_LE_ID '||P_LE_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_START_PERIOD '||l_period_from
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_END_PERIOD '||l_period_to
                    );
      FND_LOG.String( l_proc_level                                      --Added for CNAO Enhancement
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_COM_SEG '||l_com_seg
                    );
    END IF;  --(l_proc_level >= l_dbg_level)


    --Get the BSV reffered to the current legal entity and ledger
    DELETE
    FROM   JA_CN_LEDGER_LE_BSV_GT
           ;
    COMMIT ;
    --
    IF ja_cn_utility.populate_ledger_le_bsv_gt( P_LEDGER_ID,P_LE_ID) <> 'S' THEN
       RETURN;
    END IF;

    --Check Profile
    IF NOT(JA_CN_UTILITY.Check_Profile)
    THEN
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF;

    --Start the XML file
    -- Updated by shujuan for bug 7626489
    l_characterset :=Fnd_Profile.VALUE(NAME => 'ICX_CLIENT_IANA_ENCODING');
    FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding= '||'"'||l_characterset||'"?>');

    --FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding="utf-8" ?>');
    /*FND_FILE.put_line(FND_FILE.output, '<GIS_INVALID_TRANSACTIONS>');
    FND_FILE.put_line(FND_FILE.output, '<P_START_PERIOD>' ||P_START_PERIOD||'</P_START_PERIOD>');
    FND_FILE.put_line(FND_FILE.output, '<P_END_PERIOD>' ||P_END_PERIOD||'</P_END_PERIOD>');
    FND_FILE.put_line(FND_FILE.output, '<P_COMPANY_SEGMENT>' ||P_COM_SEGMENT||'</P_COMPANY_SEGMENT>');*/
    SELECT XMLELEMENT( "P_START_PERIOD",l_period_from ) INTO l_xml_item FROM dual;
      l_xml_all := l_xml_item;
    SELECT XMLELEMENT( "P_END_PERIOD",l_period_to ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "P_COMPANY_SEGMENT",l_com_seg) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "P_STATUS",P_STATUS) INTO l_xml_item FROM dual;  --Fix bug# 7481841
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

   --Get ledger Name
    SELECT ledger.name
      INTO l_ledger_name
      FROM GL_LEDGERS ledger
     WHERE ledger.ledger_id = l_ledger_id
          ;
    /*FND_FILE.put_line(FND_FILE.output, '<LEDGRT_NAME>' ||l_LEDGER_name||'</LEDGER_NAME>');*/
    --  sob name --> ledger name ,
    --  didn't change the xml schemal,
    SELECT XMLELEMENT( "LEDGER_NAME",l_ledger_name ) INTO l_xml_item FROM dual; --Fix bug#7481545
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --Get LE Name
/*    SELECT HAOTL.name
      INTO l_le_name
      FROM HR_ALL_ORGANIZATION_UNITS    HAO
          ,HR_ALL_ORGANIZATION_UNITS_TL HAOTL
     WHERE HAO.ORGANIZATION_ID = l_le_id
       AND HAO.ORGANIZATION_ID = HAOTL.ORGANIZATION_ID
       AND HAOTL.LANGUAGE = USERENV('LANG')
          ;*/
    SELECT XEP.name     --Updated to fix the issue that no legal entity name was found based on current legal entity id
      INTO l_le_name
      FROM XLE_ENTITY_PROFILES   XEP
     WHERE XEP.LEGAL_ENTITY_ID = l_le_id
          ;

    /*FND_FILE.put_line(FND_FILE.output, '<LE_NAME>' ||l_le_name||'</LE_NAME>');*/
    SELECT XMLELEMENT( "LE_NAME",l_le_name ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --1. Check whether the DFF assignment of Intercompany Transaction Lines has been set or not.
    BEGIN
    SELECT distinct DECODE(nvl(DFF.CONTEXT_CODE, ''), '', 'N',
                  DECODE(nvl(DFF.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
      INTO l_dff_check
      FROM JA_CN_DFF_ASSIGNMENTS               DFF
     WHERE DFF.DFF_TITLE_CODE = 'IITL'
       AND DFF.chart_of_accounts_id=l_coa_id
          ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_dff_check := 'N';
    END;

    IF l_dff_check = 'N' THEN
       raise JA_CN_INCOMPLETE_DFF_ASSIGN;
    END IF;

    --   l_source_meaning := Source_Meaning(P_SOURCE => 'INTR');   --Get source meaning

    --2. Get invalid transactions.
    --Note:
    -- a) Only consider Transactions whose sender's and receiver's invoice_flag are 'N'.
    -- b) Only check the lines of Current SOB AND under Current LE, AND
    --    their company segment should be the specified one if user inputed.
    l_tr_count := 0;
    l_invalid_tr_count := 0;
    l_invalid_lines := 0;

    OPEN c_period_name; --Get year and month of all periods between (P_START_PERIOD, P_END_PERIOD).
    LOOP
      FETCH c_period_name INTO l_period_name
                              ,l_period_year
                              ,l_period_num
                              ,l_period_start_date
                              ,l_perioD_end_date
                              ;
      EXIT WHEN c_period_name%NOTFOUND;
      -- initial the header counter
      l_tr_count :=0;
      l_tr_valided_flg := 'N';
      --For all transfered transactions in the period.

      OPEN c_tr;
      LOOP
        FETCH c_tr INTO l_trx_id
                       ,l_trx_num
                       ,l_trx_type
                       ,l_trx_send_name
                       ,l_trx_recv_name
                       ,l_trx_gl_date
                       ,l_trx_desc
                       ,l_trx_send_ledger_id
                       ,l_trx_recv_ledger_id
                       ,l_trx_send_le_id
                       ,l_trx_recv_le_id
                       ,l_trxb_num
                       --,l_cash_related_item
                       ;
        EXIT WHEN c_tr%NOTFOUND;

        -- Initial the counters
        -- l_tr_count := l_tr_count + 1; --This transaction is a new one
        l_invalid_line_4_tr := 0;
        l_tr_valided := 0;
        l_xml_tr_items := null;
        l_tr_valided_flg := 'N';

        -- For each lines in current transaction
        OPEN c_tr_lines;
        LOOP
          FETCH c_tr_lines INTO l_trxl_num
                               ,l_trxl_id
                               ,l_distl_id
                               ,l_distl_num
                               ,l_distl_party_id
                               ,l_distl_party_type_flg
                               ,l_distl_dist_type_flg
                               ,l_distl_ccid
                               ,l_codecmb_coa_id
                               ,l_codecmb_com_seg
                               ,l_cash_related_item
                               ;
          EXIT WHEN c_tr_lines%NOTFOUND;

          -- initial the lines' error message
          l_line_err_msg :='';
          --BEGIN

          -- check current line whether its company setment belong to the BSV
          -- and whether it is a intercompay operation
             -- sender amounts;
             BEGIN
               SELECT count(*)
                 INTO l_trx_sender_c
                 FROM JA_CN_LEDGER_LE_BSV_GT    tmp_bsv
                WHERE tmp_bsv.ledger_id = l_trx_send_ledger_id     -- ?? not sure
                  AND tmp_bsv.legal_entity_id = l_trx_send_le_id   -- ?? not sure
                  AND tmp_bsv.bal_seg_value = l_codecmb_com_seg
                      ;


             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_trx_sender_c := 0;
             END;
            -- receiver amounts;
            BEGIN
              SELECT count(*)
                INTO l_trx_receiver_c
                FROM JA_CN_LEDGER_LE_BSV_GT    tmp_bsv
               WHERE tmp_bsv.ledger_id = l_trx_recv_ledger_id        -- ?? not sure
                 AND tmp_bsv.legal_entity_id = l_trx_recv_le_id      -- ?? not sure
                 AND tmp_bsv.bal_seg_value = l_codecmb_com_seg
                      ;


            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_trx_receiver_c := 0;
            END;
            -- check the relationship between S/R
            l_trx_line_inter_flag := 'N';
            l_trx_sr_flg := 'X';

            IF l_trx_sender_c < 1 AND l_trx_receiver_c < 1 THEN
               --no one belongs to Current LE
               l_trx_line_inter_flag := 'N'; --ignore the tr
               l_trx_sr_flg := 'X';          --neither sender nor receiver
            ELSIF l_trx_sender_c >= 1 AND l_trx_receiver_c < 1 AND l_distl_party_type_flg='I' THEN
               l_trx_line_inter_flag := 'Y'; -- it is a intercompany operation
               l_trx_sr_flg := 'S';          -- it is sender
            ELSIF l_trx_sender_c < 1 AND l_trx_receiver_c >= 1 AND l_distl_party_type_flg='R' THEN
               l_trx_line_inter_flag := 'Y'; -- it is a intercompany operation
               l_trx_sr_flg := 'R';          -- it is sender
            ELSE --The transaction should be gone through all its lines
               l_trx_line_inter_flag := 'N'; --ignore the tr
               l_trx_sr_flg := 'X';          --neither sender nor receiver
            END IF ;

            -- Check only the intercompay operations
            IF l_trx_line_inter_flag <> 'X' THEN --l_trx_line_inter_flag = 'y'
              -- init
              l_csi_check := 'NB';

              IF l_cash_related_item is null
              THEN
                l_csi_check := 'B';
              END IF;

              l_line_check := Line_Check( P_COA_ID            => l_coa_id             -- ?? not sure
                                         ,P_LEDGER_ID         => l_ledger_id
                                         ,P_LE_ID             => l_le_id              --l_trx_line_le
                                         ,P_SOURCE            => 'AGIS'
                                         ,P_JT_ID             => l_distl_id
                                         ,P_LINE_NUM          => l_trx_line_num       -- ?? NOT SURE
                                         ,P_CCID              => l_distl_ccid
                                         ,P_CASH_RELATED_ITEM => l_csi_check
                                        );

              -- set header validated amounts
              --  if the transactio is ok then increase the trx amount
              IF l_line_check ='OK' AND l_tr_valided_flg = 'N' THEN
                --The line has been checked, so the transaction is valided.
                l_tr_count :=  l_tr_count + 1;
                l_tr_valided_flg := 'Y';
              END IF;
              -- If the trx amount had increased but in the next line, found that
              --    the trx is wrong, then decrease the trx amount at the first wrong time
              IF l_line_check <>'OK' AND  l_line_check <>'EXCLUDE' AND l_tr_valided_flg = 'Y' THEN
                --The line has been checked, so the transaction is valided.
                l_tr_count :=  l_tr_count - 1;
                l_tr_valided_flg := 'X';
              END IF;

              IF l_line_check = 'NO_ITEM' or l_line_check = 'NO_ACCOUNT' THEN
                -- increase the line counter
                l_invalid_line_4_tr := l_invalid_line_4_tr + 1;

                -- get the cash flow item if its cash releted item is null
                Get_Account_Combo_and_Desc( P_LEDGER_ID       => l_ledger_id             -- ?? not sure
                                           ,P_CCID            => l_distl_ccid
                                           ,P_ACCOUNT         => l_account
                                           ,P_ACCOUNT_DESC    => l_account_desc
                                          );

                IF l_line_check = 'NO_ITEM' THEN
                  l_line_err_msg := l_msg_no_cashflow_item;
                ELSE
                  l_line_err_msg := l_msg_no_cash_account;
                END IF;

                --Before first line of the transaction, output the transaction info
                IF l_invalid_line_4_tr = 1 THEN
                  /*FND_FILE.put_line(FND_FILE.output, '<TRANSACTION>');
                  FND_FILE.put_line(FND_FILE.output, '<TR_NUMBER>' ||l_tr_num||'</TR_NUMBER>');
                  FND_FILE.put_line(FND_FILE.output, '<TR_TYPE>' ||l_tr_type||'</TR_TYPE>');
                  FND_FILE.put_line(FND_FILE.output, '<SENDER>' ||l_tr_send_name||'</SENDER>');
                  FND_FILE.put_line(FND_FILE.output, '<RECEIVER>' ||l_tr_recv_name||'</RECEIVER>');
                  FND_FILE.put_line(FND_FILE.output, '<GL_DATE>' ||l_tr_gl_date||'</GL_DATE>');*/

                  -- using batch_number/trx_number to show the current item
                  SELECT XMLELEMENT( "TR_NUMBER",l_trxb_num||'/'||l_trx_num ) INTO l_xml_item FROM dual;
                    l_xml_tr_items := l_xml_item;
                  SELECT XMLELEMENT( "TR_TYPE",l_trx_type ) INTO l_xml_item FROM dual;
                    SELECT XMLCONCAT( l_xml_tr_items,l_xml_item) INTO l_xml_tr_items FROM dual;
                  SELECT XMLELEMENT( "SENDER",l_trx_send_name ) INTO l_xml_item FROM dual;
                    SELECT XMLCONCAT( l_xml_tr_items,l_xml_item) INTO l_xml_tr_items FROM dual;
                  SELECT XMLELEMENT( "RECEIVER",l_trx_recv_name ) INTO l_xml_item FROM dual;
                    SELECT XMLCONCAT( l_xml_tr_items,l_xml_item) INTO l_xml_tr_items FROM dual;
                  SELECT XMLELEMENT( "GL_DATE",l_trx_gl_date ) INTO l_xml_item FROM dual;
                    SELECT XMLCONCAT( l_xml_tr_items,l_xml_item) INTO l_xml_tr_items FROM dual;
                 END IF;

                --output the line
                /*FND_FILE.put_line(FND_FILE.output, '<LINE>');
                  FND_FILE.put_line(FND_FILE.output, '<LINE_NUMBER>' ||l_tr_line_num||'</LINE_NUMBER>');
                  FND_FILE.put_line(FND_FILE.output, '<ACCOUNT>' ||l_account||'</ACCOUNT>');
                  FND_FILE.put_line(FND_FILE.output, '<ACCOUNT_DESC>' ||l_account_desc||'</ACCOUNT_DESC>');
                  FND_FILE.put_line(FND_FILE.output, '<CASH_FLOW_ITEM>' ||l_cash_related_item||'</CASH_FLOW_ITEM>');
                  FND_FILE.put_line(FND_FILE.output, '<EXC_REASON>' ||l_line_err_msg||'</EXC_REASON>');
                FND_FILE.put_line(FND_FILE.output, '</LINE>');*/

                SELECT XMLELEMENT( "LINE_NUMBER",l_trxl_num ) INTO l_xml_item FROM dual;  -- using trx line number to markup recorde with error
                  l_xml_line_items := l_xml_item;
                SELECT XMLELEMENT( "ACCOUNT",l_account ) INTO l_xml_item FROM dual;
                  SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                SELECT XMLELEMENT( "ACCOUNT_DESC",l_account_desc ) INTO l_xml_item FROM dual;
                  SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                SELECT XMLELEMENT( "CASH_FLOW_ITEM",l_cash_related_item ) INTO l_xml_item FROM dual;
                  SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;
                SELECT XMLELEMENT( "EXC_REASON",l_line_err_msg ) INTO l_xml_item FROM dual;
                  SELECT XMLCONCAT( l_xml_line_items,l_xml_item) INTO l_xml_line_items FROM dual;

                SELECT XMLELEMENT( "LINE",l_xml_line_items ) INTO l_xml_line FROM dual;
                --To concatenate the XML line as a transaction item
                SELECT XMLCONCAT( l_xml_tr_items,l_xml_line ) INTO l_xml_tr_items FROM dual;

               END IF; -- line check
             END IF; -- line inner flag
          END LOOP; -- line loop
        CLOSE c_tr_lines;

        /*
        IF l_tr_valided = 0 --The transaction has no line been checked, so excluded it.
        THEN
          l_tr_count := l_tr_count -1;
        END IF;
        */
        IF l_invalid_line_4_tr > 0 THEN--Has invalid lines, so the transaction is a invalid one
          l_invalid_tr_count := l_invalid_tr_count + 1;             --This transaction is a invalid one
          l_invalid_lines := l_invalid_lines + l_invalid_line_4_tr; --Add the invalid lines of this transaction

          --Has output lines, should end the transaction
          /*FND_FILE.put_line(FND_FILE.output, '<INVALID_LINES_4_TR>' ||l_invalid_line_4_tr||'</INVALID_LINES_4_TR>');
          FND_FILE.put_line(FND_FILE.output, '</TRANSACTION>');*/
          SELECT XMLELEMENT( "INVALID_LINES_4_TR",l_invalid_line_4_tr ) INTO l_xml_item FROM dual;
              SELECT XMLCONCAT( l_xml_tr_items,l_xml_item) INTO l_xml_tr_items FROM dual;

          SELECT XMLELEMENT( "TRANSACTION",l_xml_tr_items ) INTO l_xml_tr FROM dual;
          --To concatenate the transaction into the output
          SELECT XMLCONCAT( l_xml_all,l_xml_tr ) INTO l_xml_all FROM dual;
        END IF; --l_invalid_line_4_tr > 0

     END LOOP; -- loop header
     CLOSE c_tr;

   END LOOP;-- loop period
   CLOSE c_period_name;

    --End the XML file
    /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>' || TO_CHAR(l_tr_count) || '</TOTAL_COUNT>');
    FND_FILE.put_line(FND_FILE.output, '<TOTAL_INVALID_TR>' || TO_CHAR(l_invalid_tr_count) || '</TOTAL_INVALID_TR>');
    FND_FILE.put_line(FND_FILE.output, '<TOTAL_INVALID_LINES>' || TO_CHAR(l_invalid_lines) || '</TOTAL_INVALID_LINES>');
    FND_FILE.put_line(FND_FILE.output, '</GIS_INVALID_TRANSACTIONS>');*/
    SELECT XMLELEMENT( "TOTAL_COUNT",TO_CHAR(l_tr_count) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "TOTAL_INVALID_TR",TO_CHAR(l_invalid_tr_count) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
    SELECT XMLELEMENT( "TOTAL_INVALID_LINES",TO_CHAR(l_invalid_lines) ) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;

    --To add root node for the xml output and then output it
    SELECT XMLELEMENT( "GIS_INVALID_TRANSACTIONS",l_xml_all ) INTO l_xml_root FROM dual;
    --FND_FILE.put_line(FND_FILE.output,l_xml_root.getclobval());
    JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

    --log for debug
    IF (l_proc_level >= l_dbg_level)  THEN
      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.end'
                    ,'Exit procedure'
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    EXCEPTION
  	  WHEN JA_CN_INCOMPLETE_DFF_ASSIGN THEN
        IF (l_proc_level >= l_dbg_level)   THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_INCOMPLETE_DFF_ASSIGN '
                         ,l_msg_incomplete_dff_assign);
        END IF;  --(l_proc_level >= l_dbg_level)
        /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>0</TOTAL_COUNT>');
        FND_FILE.put_line(FND_FILE.output, '<DFF_EXCEPTION>' || l_msg_incomplete_dff_assign || '</DFF_EXCEPTION>');
        FND_FILE.put_line(FND_FILE.output, '</GIS_INVALID_TRANSACTIONS>');*/
        SELECT XMLELEMENT( "TOTAL_COUNT",0 ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        SELECT XMLELEMENT( "DFF_EXCEPTION",l_msg_incomplete_dff_assign ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        --To add root node for the xml output and then output it
        SELECT XMLELEMENT( "GIS_INVALID_TRANSACTIONS",l_xml_all ) INTO l_xml_root FROM dual;
        JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

        retcode := 1;
        errbuf  := l_msg_incomplete_dff_assign;
    	/*WHEN JA_CN_NO_CASHACCOUNT THEN
    		Report it with l_msg_no_cash_account;
    	WHEN JA_CN_NO_CASHFLOWITEM THEN
    		Report it with l_msg_no_cashflow_item;*/
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)  THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        /*FND_FILE.put_line(FND_FILE.output, '<TOTAL_COUNT>0</TOTAL_COUNT>');
        FND_FILE.put_line(FND_FILE.output, '<OTHER_EXCEPTION>' || 'Other_Exception' || '</OTHER_EXCEPTION>');
        FND_FILE.put_line(FND_FILE.output, '</GIS_INVALID_TRANSACTIONS>');*/
        SELECT XMLELEMENT( "TOTAL_COUNT",0 ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        SELECT XMLELEMENT( "DFF_EXCEPTION",'Other_Exception' ) INTO l_xml_item FROM dual;
          SELECT XMLCONCAT( l_xml_all,l_xml_item) INTO l_xml_all FROM dual;
        --To add root node for the xml output and then output it
        SELECT XMLELEMENT( "GIS_INVALID_TRANSACTIONS",l_xml_all ) INTO l_xml_root FROM dual;
        JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());

        retcode := 2;
        errbuf  := SQLCODE||':'||SQLERRM;
  END Intercompany_Validation;

BEGIN
  -- Initialization
  FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                       ,NAME => 'JA_CN_INCOMPLETE_DFF_ASSIGN'
                      );
  l_msg_incomplete_dff_assign := FND_MESSAGE.Get;

  FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                       ,NAME => 'JA_CN_NO_CASHFLOWITEM'
                      );
  l_msg_no_cashflow_item := FND_MESSAGE.Get;

  FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                       ,NAME => 'JA_CN_NO_CASHACCOUNT'
                      );
  l_msg_no_cash_account := FND_MESSAGE.Get;

END JA_CN_GL_INTER_VALID_PKG;

/
