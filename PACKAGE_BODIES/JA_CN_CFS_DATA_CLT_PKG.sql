--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_DATA_CLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_DATA_CLT_PKG" AS
--$Header: JACNCDCB.pls 120.2.12010000.3 2009/07/31 05:44:42 wuwu ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNCDCB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used in Collecting CFS Data from GL/Intercompany/ |
--|     AR/AP in the CNAO Project.                                        |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Cfs_Data_Clt                     PUBLIC                |
--|      PROCEDURE Collect_GL_InterCom_Data         PRIVATE               |
--|      FUNCTION  GL_InterCom_Line_Check           PRIVATE               |
--|      PROCEDURE Process_GL_Rounding              PRIVATE               |
--|      PROCEDURE Collect_AR_Data                  PRIVATE               |
--|      PROCEDURE Collect_AP_Data                  PRIVATE               |
--|      PROCEDURE put_line                         PRIVATE               |
--|      PROCEDURE put_log                          PRIVATE               |
--|      FUNCTION  get_period_name                  PUBLIC                |
--|      PROCEDURE collect_AR_data                  PUBLIC                |
--|      PROCEDURE process_AP_rounding              PRIVATE               |
--|      PROCEDURE collect_AP_data                  PUBLIC                |
--|                                                                       |
--| HISTORY                                                               |
--|      03/01/2006  Andrew Liu       Created                             |
--|      03/24/2006  Jogen Hu         merge AR,AP parts                   |
--|      07/17/2006  Shujuan Yan      In procedure Collect_AP_Data,Added  |
--|                                   the process when invoice amount is  |
--|                                   zero for bug 5393574.               |
--|	     30/10/2006  Andrew Liu       Update Collect_GL_InterCom_Data for |
--|                                   fix bug 5624013.                    |
--|      11/13/2006  Shujuan          Added the logic of future dated     |
--|                                   payment for bug 5641261             |
--|      11/13/2006  Shujuan          In procedure Collect_AP_Data, should|
--|                                   store accounting date into gl_date  |
--|                                   of the table ja_cn_cfs_activities_gt|
--|                                   for bug 5641324                     |
--|      11/13/2006  Shujuan          In procedure Collect_AR_Data, should|
--|                                   store the gl_date into the table    |
--|                                   ja_cn_cfs_activities_all, not the   |
--|                                   posted gl date for bug 5651671      |
--|                                   5657210.                            |
--|      11/16/2006  Shujuan          In procedure Collect_AP_Data,Payment|
--|                                   should not be apporationed to the   |
--|                                   pre payment distribution line for   |
--|                                   bug 5664969                         |
--|	     16/11/2006  Andrew Liu       Update GL_InterCom_Line_Check and   |
--|                                   Collect_GL_InterCom_Data for        |
--|                                   fix bug 5665083.                    |
--|      12/16/2006  Shujuan          In the procedure Collect_AP_Data,   |
--|                                   should be based on payment base     |
--|                                   amount for bug 5700098              |
--|      12/16/2006  Shujuan          In the procedure Process_AP_Rounding|
--|                                   the cursor c_func_diff c_orig_diff  |
--|                                   should grouded by transaction id,   |
--|                                   functional amount and gl date for   |
--|                                   bug 5701909.                        |
--|      08/09/2008  Yao Zhang        Fix bug 7334017 add balance segment |
--|                                   value to table ja_cn_cfs_activities |
--|                                   _all                                |
--|      17/10/2008 Yao Zhang         Fix bug 7488191 TRX_NUMBER OF AGIS  |
--|                                   Data SHOULD Be BATCH NUMBER         |
--|      17/10/2008 Yao Zhang         Fix BUG 7488206 AGIS SOURCE         |
--|                                   TRANSACTION IS COLLECTED REPEATEDLY |
--|      21/10/2008 Yao Zhang         Fix bug 7488223 DATA COLLECTION     |
--|                                   PROGRAM COLLECT AGIS DATA BEYOND BSV|
--|                                   QUALIFICATION
--|      30/07/2009 Chaoqun Wu        Fixing bug# 8744259                 |
--+======================================================================*/

  l_module_prefix                VARCHAR2(100) :='JA_CN_CFS_DATA_CLT_PKG';

  G_MODULE_PREFIX   VARCHAR2(30):='JA_CN_CFS_DATA_CLT_PKG.';
  G_PROC_LEVEL      INT         :=fnd_log.LEVEL_PROCEDURE;
  G_STATEMENT_LEVEL INT         :=fnd_log.LEVEL_STATEMENT;
  g_debug_devel     INT;
--  G_PERIOD_TYPE     VARCHAR2(30):='Month';

   --==========================================================================
  --  FUNCTION NAME:
  --    GL_InterCom_Line_Check        private
  --
  --  DESCRIPTION:
  --      This function checks whether line of GL journals OR Intercompany
  --      transactions can be inserted or not.
  --
  --  PARAMETERS:
  --      In: P_SOB_ID                NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_SOURCE                VARCHAR2            Source:GL/GIS
  --      In: P_JT_ID                 VARCHAR2            ID of the Journal/Tr
  --      In: P_LINE_NUM              VARCHAR2            Number of the line
  --      In: P_CCID                  NUMBER              ID of chart of account
  --      In: P_CASH_RELATED_ITEM     VARCHAR2            Cash related item of the line
  --      In: P_GIS_JNL_CRI           VARCHAR2            Cash related item of the transfered
  --                                                      jounarl line of a transaction
  --  RETURN:
  --      VARCHAR2
  --         'Y' for passed and 'N' for not pass.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/01/2006     Andrew Liu          Created
  --      16/11/2006     Andrew Liu          Added the logic of check cash related item
  --                                         of transaction's transferred GL journal
  --                                         for fix bug 5665083.
  --      04/21/2007     Yucheng Sun         Updated:
  --===========================================================================
  FUNCTION  GL_InterCom_Line_Check( P_COA_ID             IN NUMBER
                                   ,P_LEDGER_ID          IN NUMBER
                                   ,P_LE_ID              IN NUMBER
                                   ,P_SOURCE             IN VARCHAR2
                                   ,P_JT_ID              IN NUMBER
                                   ,P_LINE_NUM           IN VARCHAR2
                                   ,P_CCID               IN NUMBER
                                   ,P_CASH_RELATED_ITEM  IN VARCHAR2
                                   ,P_GIS_JNL_CRI        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2  IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='GL_InterCom_Line_Check';

    l_ledger_id                         NUMBER := P_LEDGER_ID;   --
    l_le_id                             NUMBER := P_LE_ID;
    l_source                            VARCHAR2(10) := P_SOURCE;
    l_coa_id                            NUMBER := P_COA_ID;
    l_jt_id                             NUMBER := P_JT_ID;
    l_line_num                          VARCHAR2(20) := P_LINE_NUM;
    l_cc_id                             NUMBER := P_CCID;
    l_csi_check                         varchar2(2) := P_CASH_RELATED_ITEM;
    l_tr_csi_check                      varchar2(150);

    l_seg_type                          FND_SEGMENT_ATTRIBUTE_VALUES.SEGMENT_ATTRIBUTE_TYPE%TYPE;
    l_ffv_flex_value                    varchar2(150);
    l_seg_fsav_gcc                      varchar2(150);

    l_account_num                       varchar2(150); --account number of a line's account
    l_com_seg                           varchar2(150); --company segment of a line's account
    l_com_seg_check                     number;        --flag of an account's company segment belongs to current LE or not
    l_account_check                     number;        --flag of an account in cash related table or not
    l_line_check                        varchar2(1);   --result of a line's validation

    --Cursor to get FND_FLEX_VALUES.Flex_Value and segment FND_SEGMENT_ATTRIBUTE_VALUES.APPLICATION_COLUMN_NAME of gcc
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
       AND gcc.chart_of_accounts_id = l_coa_id         --using variable P_COA_ID
       AND ledger.chart_of_accounts_id = ledger.chart_of_accounts_id
       AND ledger.ledger_id = l_ledger_id              --using variable l_sob_id
       AND FIFS.id_flex_num = gcc.chart_of_accounts_id
       AND FIFS.id_flex_num = FSAV.id_flex_num
       AND FIFS.application_id = 101                   -- seeded data
       AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
       AND FIFS.application_id = FSAV.application_id
       AND FSAV.SEGMENT_ATTRIBUTE_TYPE = l_seg_type    --using variable l_seg_type ,'gl_account'
       AND FSAV.ATTRIBUTE_VALUE = 'Y'
       AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
       AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID;

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

    l_line_check := 'N';
    P_GIS_JNL_CRI := null;

    --Get account segment
    l_seg_type := 'GL_ACCOUNT';
    OPEN c_ffv;
    LOOP
      FETCH c_ffv INTO l_ffv_flex_value
                      ,l_seg_fsav_gcc;
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
       WHERE cash_acc.ACCOUNT_SEGMENT_VALUE = TO_CHAR(l_account_num) --using variable l_account_num
         AND cash_acc.chart_of_accounts_id = l_coa_id;               --using variable P_COA_ID
         --AND cash_acc.SET_OF_BOOKS_ID = l_sob_id;                  --using variable l_sob_id

      IF l_source = 'GL'
      THEN
        --Get account's company segment
        l_seg_type := 'GL_BALANCING';
        --  ?? why Loop again ??
        OPEN c_ffv;
        LOOP
          FETCH c_ffv INTO l_ffv_flex_value
                          ,l_seg_fsav_gcc;
          EXIT WHEN c_ffv%NOTFOUND;
          IF l_ffv_flex_value is not null AND l_seg_fsav_gcc is not null AND
             l_ffv_flex_value = l_seg_fsav_gcc
          THEN
            l_com_seg := l_ffv_flex_value;
            EXIT;
          END IF;
        END LOOP;
        CLOSE c_ffv;

        IF l_com_seg is not null
        THEN
          --check the company segment belongs to the current legal entity or not.
          l_com_seg_check := 0;
          SELECT count(*)                            row_count
           INTO  l_com_seg_check
          FROM   JA_CN_LEDGER_LE_BSV_GT              tmpbsv
          WHERE  tmpbsv.LEGAL_ENTITY_ID = l_le_id         --using variable l_le_id
            AND  tmpbsv.ledger_id = l_ledger_id           --using variable l_ledger_id
            AND  tmpbsv.bal_seg_value = l_com_seg;        --using variable l_com_seg

          IF l_com_seg_check > 0 AND --the company segment belongs to the current legal entity
             l_account_check > 0 AND --the line's account is cash related
             l_csi_check = 'NB'
          THEN
            l_line_check := 'Y';
          END IF;
        END IF; --l_com_seg is not null

      ELSE
      --l_source = 'AGIS'
        --  fix bug 5665083, 2006-11-16, Andrew:
        --  should check the cash related item of GL journal transferred from this line
        --  when its cash related item is balnk.
        --IF l_csi_check = 'B'   THEN
          --Get company segment
          l_seg_type := 'GL_BALANCING';

          OPEN c_ffv;
          LOOP
            FETCH c_ffv INTO l_ffv_flex_value
                            ,l_seg_fsav_gcc;
            EXIT WHEN c_ffv%NOTFOUND;
            IF l_ffv_flex_value is not null AND l_seg_fsav_gcc is not null AND
               l_ffv_flex_value = l_seg_fsav_gcc
            THEN
              l_com_seg := l_ffv_flex_value;
              EXIT;
            END IF;
          END LOOP;
          CLOSE c_ffv;

          l_com_seg_check := 0;
          IF l_com_seg is not null
          THEN
            --check the company segment belongs to the current legal entity or not.
            l_com_seg_check := 0;
            SELECT count(*)                            row_count
             INTO  l_com_seg_check
            FROM   JA_CN_LEDGER_LE_BSV_GT              tmpbsv
            WHERE  tmpbsv.LEGAL_ENTITY_ID = l_le_id                  --using variable l_le_id
              AND  tmpbsv.ledger_id = l_ledger_id                    --using variable l_ledger_id
              AND  tmpbsv.bal_seg_value = TO_CHAR(l_com_seg);        --using variable l_com_seg
          END IF;
          /*
          ----------------------------for test--------------------------------------------
          SELECT count(*)                            row_count
           INTO  l_com_seg_check
          FROM   JA_CN_LEDGER_LE_BSV_GT              tmpbsv
          WHERE  tmpbsv.LEGAL_ENTITY_ID = l_le_id         --using variable l_le_id
            AND  tmpbsv.ledger_id = l_ledger_id;           --using variable l_ledger_id
          ----------------------------fro test--------------------------------------------
          */

          IF l_com_seg_check >0 THEN
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
                    INTO l_tr_csi_check
                    FROM gl_je_lines                         jel
                       , fun_trx_headers                     trxh
                       , fun_trx_lines                       trxl
                       , fun_dist_lines                      distl
                       ,ja_cn_dff_assignments                dffa  --
                   WHERE distl.dist_id = l_jt_id             -- transaction header id
                     AND distl.line_id=trxl.line_id
                     AND trxh.trx_id = trxl.trx_id
                     AND jel.reference_2 = TO_CHAR(trxh.batch_id)
                     AND jel.reference_3 = TO_CHAR(trxh.trx_id)
                     AND jel.reference_4 = TO_CHAR(trxl.line_id)
                     AND jel.reference_5 = TO_CHAR(distl.dist_id)
                     AND jel.ledger_id=l_ledger_id           -- care only current ledgers'
                     AND jel.status='P'                      -- care only post journels from trxes
                         -- to locate cash flow item in dff_assignment
                     AND dffa.Application_Id = 101
                     AND dffa.chart_of_accounts_id = l_coa_id    --using variable l_coa_id
                     AND dffa.dff_title_code='GLLI';
               Exception
                  WHEN NO_DATA_FOUND THEN
                       l_tr_csi_check := null;                -- not sure
                       -- the trx had been transfered to GL, but not post, which will be excluded
                       l_line_check := 'N';
                       return 'N';
               END;

                IF l_tr_csi_check is not null
                THEN
                  P_GIS_JNL_CRI := l_tr_csi_check;
                  l_csi_check := 'NB';
                END IF;
              END IF;
        --END IF;

        IF l_account_check > 0  AND --the line's account is cash related
           l_csi_check = 'NB'
           AND l_com_seg_check >0 --fix bug 7488223 add
        THEN
          l_line_check := 'Y';
        END IF;
      END IF; --l_source = 'GL'/'GIS'
    END IF; --l_account_num is not null

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.end'
                     ,'Exit procedure for Journal/Transaction '||TO_CHAR(l_jt_id)
                        || '''s Line ' || l_line_num
                        ||' and its l_line_check is ' || l_line_check
                    );
    END IF;  --(l_proc_level >= l_dbg_level)
    return l_line_check;

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
                          || ', So set the check as ''N'', meaning fall the check.'
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        return 'N';
  END GL_InterCom_Line_Check;


  --==========================================================================
  --  FUNCTION NAME:
  --    AGIS_Get_Curr_Rate_Type        private
  --
  --  DESCRIPTION:
  --      This function checks the type of item: sender or receiver
  --      return the currency rate and type
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID                NUMBER            ID of Set Of ledger
  --      In: P_LE_ID                    NUMBER            ID of Legal Entity
  --      In: P_AGIS_LE_ID               NUMBER            Source:GL/GIS
  --      In: P_AGIS_LEDGER_ID           NUMBER            ID of the ledger in agis
  --      In: P_GL_DATE                  DATE              ID of the legal entity in agis
  --      In: P_AGIS_CURR_COV_TYPE       VARCHAR2(30)      Currency convert type in AGIS
  --      In: P_AGIS_CURR_CODE           VARCHAR2(15)      Currenc code in AGIS
  --     OUT: P_AGIS_CURR_RATE           NUMBER            Currency rate to be got form the daily rates table
  --
  --  RETURN:
  --      boolean
  --         true for getatable value and false for no value got.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    04/10/2007     Yucheng Sun          Created
  --===========================================================================
  FUNCTION  AGIS_Get_Curr_Rate_Type(  P_LEDGER_ID             IN NUMBER
                                     ,P_LE_ID                 IN NUMBER
                                     ,P_AGIS_LE_ID            IN NUMBER
                                     ,P_AGIS_LEDGER_ID        IN NUMBER
                                     ,P_GL_DATE               IN DATE
                                     ,P_AGIS_CURR_COV_TYPE    IN VARCHAR2
                                     ,P_AGIS_CURR_CODE        IN VARCHAR2
                                     ,P_AGIS_CURR_RATE        OUT NOCOPY NUMBER

  ) RETURN boolean  IS

  l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
  l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
  l_proc_name                         VARCHAR2(100) :='GL_InterCom_Line_Check';

  --l_trx_curr_cov_type                GL_DAILY_RATES.CONVERSION_TYPE%TYPE;
  --l_trx_curr_cov_rate                GL_DAILY_RATES.CONVERSION_RATE%TYPE;
  l_gl_curr_code                     GL_LEDGERS.Currency_Code%TYPE;

 BEGIN
   --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure for Journal/Transaction '
                     --||TO_CHAR(l_jt_id) || '''s Line ' || l_line_num
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    --check whether the currency code is the same to its function currency code
    SELECT  leg.currency_code into l_gl_curr_code
    FROM    GL_LEDGERS leg
    WHERE   leg.ledger_id=P_LEDGER_ID;

    IF l_gl_curr_code=P_AGIS_CURR_CODE THEN
       -- in the same currency code,the convert rate is 1
       P_AGIS_CURR_RATE:=1;
       RETURN TRUE;
    END IF;

   /*
    -- ?? To deal with the null situation of currency convertion type
    IF NVL(P_AGIS_CURR_COV_TYPE,'')='' THEN
       -- there should be a error message
       RETURN FALSE;
    END IF;
    */

    -- get the covertion rate between different currency codes
    SELECT  cur.conversion_rate INTO P_AGIS_CURR_RATE
    FROM    GL_DAILY_RATES cur
    WHERE cur.from_currency =P_AGIS_CURR_CODE
      AND cur.to_currency=l_gl_curr_code
      AND cur.conversion_type=P_AGIS_CURR_COV_TYPE
      AND cur.conversion_date=P_GL_DATE;

    IF  P_AGIS_CURR_RATE IS NULL THEN
        P_AGIS_CURR_RATE:=1;
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

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
                         ,--'For Journal/Transaction '||TO_CHAR(l_jt_id)
                          --|| '''s Line ' || l_line_num
                          ''|| ', So set the check as ''N'', meaning fall the check.'
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
     return FALSE;
  END AGIS_Get_Curr_Rate_Type;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Process_GL_Rounding           Public
  --
  --  DESCRIPTION:
  --      	This procedure is used to process amount rounding in GL/Intercompany.
  --
  --  PARAMETERS:
  --      In: P_LE_ID                VARCHAR2             ID of Legal Entity
  --          P_AMOUNT               NUMBER               Amount
  --          P_CURRENCY_CODE        VARCHAR2             Code of the currency
  --      Out:P_AMOUNT_ROUNDED       NUMBER               Rounded amount
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_collection_TD.doc
  --
  --  CHANGE HISTORY:
  --	    03/01/2006     Jogen Hu          Created
  --===========================================================================
  PROCEDURE Process_GL_Rounding( P_LE_ID           IN VARCHAR2
                                ,P_AMOUNT          IN NUMBER
                                ,P_CURRENCY_CODE   IN VARCHAR2
                                ,P_AMOUNT_ROUNDED  OUT NOCOPY NUMBER
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Process_GL_Rounding';

    l_amount                            NUMBER := P_AMOUNT;
    l_currency_code                     VARCHAR2(15) := P_CURRENCY_CODE;
    l_precision                         NUMBER;
    l_amount_rounded                    NUMBER;
    l_round_flag                        ja_cn_system_parameters_all.rounding_rule%TYPE;

  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    BEGIN
      SELECT rounding_rule
        INTO l_round_flag
        FROM ja_cn_system_parameters_all
       WHERE legal_entity_id = P_LE_ID;  --Using parameter P_LE_ID

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF(l_proc_level >= l_dbg_level)
          THEN
            FND_LOG.string( l_proc_level
                           ,l_module_prefix||'.'||l_proc_name||'.NO_DATA_FOUND'
                           ,'The legal entity has no system parameters defined'
                          );
          END IF;
          RAISE;
    END;

    SELECT PRECISION
      INTO l_precision
      FROM fnd_currencies
     WHERE currency_code=l_currency_code;

    --rounding
    IF l_round_flag = 'N' --'NEAREST'
    THEN
      l_amount_rounded := round(l_amount, l_precision);
    ELSIF l_round_flag = 'D' --'DOWN'
    THEN
      l_amount_rounded := trunc(l_amount, l_precision);
    ELSE --l_round_flag = 'U' --'UP'
      l_amount_rounded := ceil(l_amount*power(10,l_precision))
                          /power(10, l_precision);
    END IF;

    P_AMOUNT_ROUNDED := l_amount_rounded;

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.end'
                     ,'Exit procedure'
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;
  END Process_GL_Rounding;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Collect_GL_InterCom_Data      private
  --
  --  DESCRIPTION:
  --      This procedure collects data from GL journals OR Intercompany transactions.
  --
  --  PARAMETERS:
  --      In: P_SOB_ID                NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_PERIOD_SET_NAME       VARCHAR2            Name of the period set
  --                                                      in the set of book
  --      In: P_GL_PERIOD_FROM        VARCHAR2            Start period
  --      In: P_GL_PERIOD_TO          VARCHAR2            End period
  --      In: P_SOURCE_APP_ID         NUMBER              The soure id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/01/2006     Andrew Liu          Created
  --      30/10/2006     Andrew Liu          Added the logic of brother relationship
  --                                         check in GIS collection to fix bug 5624013.
  --      16/11/2006     Andrew Liu          Added the logic of exclude GIS, AP, AR
  --                                         in GL collection for fix bug 5665083.
  --      04/02/2007     Yucheng Sun         Updated to Release 12.0,
  --      08/09/2008     Yao Zhang           Fix bug #7334017 for R12 enhancement
  --      30/07/2009     Chaoqun Wu          Fixing bug# 8744259
  --===========================================================================
 PROCEDURE Collect_GL_InterCom_Data( P_COA_ID           IN NUMBER
                                   ,P_LEDGER_ID        IN NUMBER
                                   ,P_LE_ID            IN NUMBER
                                   ,P_PERIOD_SET_NAME  IN VARCHAR2
                                   ,P_GL_PERIOD_FROM   IN VARCHAR2
                                   ,P_GL_PERIOD_TO     IN VARCHAR2
                                   ,P_SOURCE_APP_ID    IN NUMBER
) IS
--variables
  l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
  l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
  l_proc_name                         VARCHAR2(100) :='Collect_GL_InterCom_Data';

  l_le_id                             NUMBER        :=P_LE_ID;
  l_ledger_id                         NUMBER        :=P_LEDGER_ID;
  l_coa_id                            NUMBER        :=P_COA_ID;
  l_source_application_id             NUMBER        :=P_SOURCE_APP_ID;
  l_source_name                       fnd_application.application_short_name%TYPE;
  --  PERIODS e current item
  l_period_name                       gl_periods.period_name%TYPE; --period name of th
  l_period_year                       gl_periods.period_year%TYPE;
  l_period_num                        gl_periods.period_num%TYPE;
  l_period_start_date                 gl_periods.start_date%TYPE;
  l_period_end_date                   gl_periods.end_date%TYPE;
  l_period_name_from                  gl_periods.period_name%TYPE:=P_GL_PERIOD_FROM; --period name of th
  l_period_name_to                    gl_periods.period_name%TYPE:=P_GL_PERIOD_TO;   --period name of th

  --  GL: GL_JE_HEADER
  l_je_func_curr_code                 gl_sets_of_books.currency_code%TYPE;
  l_je_header_id                      GL_JE_HEADERS.JE_HEADER_ID%TYPE;
  l_je_catg                           GL_JE_HEADERS.je_category%TYPE;
  l_je_jnl_name                       GL_JE_HEADERS.name%TYPE;
  l_je_jnl_doc_seq_num                GL_JE_HEADERS.Doc_Sequence_Value%TYPE;
  l_je_curr_code                      GL_JE_HEADERS.currency_code%TYPE;
  l_je_curr_cov_rate                  GL_JE_HEADERS.currency_conversion_rate%TYPE;
  l_je_curr_cov_type                  GL_JE_HEADERS.currency_conversion_type%TYPE;
  l_je_curr_cov_date                  GL_JE_HEADERS.currency_conversion_date%TYPE;
  l_je_inter_flag                     GL_JE_HEADERS.global_attribute1%TYPE;
  l_je_effective_date                 GL_JE_HEADERS.DEFAULT_EFFECTIVE_DATE%TYPE;
  l_je_line_num                       GL_JE_LINES.je_line_num%TYPE;
  l_je_line_desc                      GL_JE_LINES.description%TYPE;
  l_je_line_amount                    NUMBER;
  l_je_line_func_amount               NUMBER;
  --  GL: Gl_JE_LINES
  l_ccid                              GL_CODE_COMBINATIONS.Code_Combination_Id%TYPE;
  l_cash_related_item                 varchar2(150); --cash related item of a line
  l_cash_related_item_1               varchar2(150); --copy of cash related item of a line
  l_csi_check                         varchar2(2);   --blank or not of cash related item
  l_line_check                        varchar2(16);  --result of a line's validation
  -- AGIS: FUN_TRX_BATCHES
  l_trxb_batch_id                     fun_trx_batches.batch_id%TYPE;
  l_trxb_batch_num                    fun_trx_batches.batch_number%TYPE;
  l_trxb_gl_date                      fun_trx_batches.gl_date%TYPE;
  l_trxb_curr_code                    fun_trx_batches.currency_code%TYPE;
  l_trxb_entered_date                 fun_trx_batches.batch_date%TYPE;
  l_trxb_from_le_id                   fun_trx_batches.from_le_id%TYPE;
  l_trxb_from_ledger_id               fun_trx_batches.from_ledger_id%TYPE;
  l_trxb_curr_cov_type                fun_trx_batches.exchange_rate_type%TYPE;   --currency convertion type
  -- AGIS: FUN_TRX_HEADERES
  l_trxh_header_id                    fun_trx_headers.trx_id%TYPE;
  l_trxh_header_num                   fun_trx_headers.trx_number%TYPE;
  l_trxh_desc                         fun_trx_headers.description%TYPE;
  l_trxh_initiator_id                 fun_trx_headers.initiator_id%TYPE;
  l_trxh_recipient_id                 fun_trx_headers.recipient_id%TYPE;
  l_trxh_to_le_id                     fun_trx_headers.to_le_id%TYPE;
  l_trxh_to_ledger_id                 fun_trx_headers.to_ledger_id%TYPE;
  l_trxh_init_amount_cr               fun_trx_headers.init_amount_cr%TYPE;
  l_trxh_init_amount_dr               fun_trx_headers.init_amount_dr%TYPE;
  l_trxh_reci_amount_cr               fun_trx_headers.reci_amount_cr%TYPE;
  l_trxh_reci_amount_dr               fun_trx_headers.reci_amount_dr%TYPE;
  l_distl_cash_rel_item               fun_dist_lines.attribute1%TYPE;
  l_distl_cash_rel_item_l             fun_dist_lines.attribute1%TYPE;
  -- AGIS: FUN_TRX_LINES
  l_trxl_num                           fun_trx_lines.line_id%TYPE;
  l_trxl_id                            fun_trx_lines.trx_id%TYPE;
  l_distl_party_id                     fun_dist_lines.party_id%Type;
  l_distl_party_type_flg               fun_dist_lines.party_type_flag%TYPE;
  l_distl_dist_type_flg                fun_dist_lines.dist_type_flag%TYPE;
  l_distl_amount_cr                    fun_dist_lines.amount_cr%TYPE;
  l_distl_amount_dr                    fun_dist_lines.amount_dr%TYPE;
  l_distl_number                       fun_dist_lines.dist_number%TYPE;
  l_distl_ccid                         fun_dist_lines.ccid%TYPE;
  l_codecmb_coa_id                     gl_code_combinations.chart_of_accounts_id%TYPE;
  l_codecmb_com_seg                    gl_code_combinations.segment1%TYPE;
  l_distl_id                           NUMBER;

  -- AGIS: CURRENCY RATE
  l_trxh_curr_cov_rate                GL_DAILY_RATES.CONVERSION_RATE%TYPE := 1;

  -- AGIS: tempory parameters, to deal with the data in logic no matter it is sender or receiver;
  l_current_initiator_id              fun_trx_headers.initiator_id%TYPE;
  l_current_recipient_id              fun_trx_headers.recipient_id%TYPE;
  l_current_amount_cr                 fun_trx_headers.init_amount_cr%TYPE;
  l_current_amount_dr                 fun_trx_headers.init_amount_cr%TYPE;
  l_get_trx_cov_rate_flg              BOOLEAN := FALSE;
  l_tr_func_amount                    number:=0;

--cursor
  --GL
    --  Cursor to get all periods between (P_GL_PERIOD_FROM, P_GL_PERIOD_TO).
    CURSOR c_period_name IS
    SELECT   gp.period_name
           , gp.period_year
           , gp.period_num
           , gp.start_date
           , gp.end_date
     FROM  gl_periods gp, GL_LEDGERS ledger
     WHERE ledger.ledger_id = l_ledger_id           --using variable P_LEDGER_ID
       AND ledger.period_set_name = gp.PERIOD_SET_NAME
       AND ledger.accounted_period_type = gp.period_type
       AND gp.start_date between
           (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND GP.period_name = l_period_name_from) --using parameter P_START_PERIOD
       and (SELECT start_date
              FROM GL_PERIODS GP
             WHERE ledger.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
               AND ledger.ACCOUNTED_PERIOD_TYPE = GP.PERIOD_TYPE
               AND GP.period_name = l_period_name_to)   --using parameter P_END_PERIOD
     ORDER BY gp.start_date
          ;

    --  Cursor to get information of GL journals in the specified period,
    --  Only consider Journals whose categories is Cash Related and Status is Posted.
    CURSOR c_gl IS
    SELECT jeh.je_header_id                    jnl_id
          ,jeh.je_category                     jnl_catg
          ,jeh.name                            jnl_name
          ,jeh.doc_sequence_value              jnl_doc_seq_num
          ,jeh.currency_code                   curr_code
          ,jeh.currency_conversion_rate        curr_cov_rate
          ,jeh.currency_conversion_type        curr_cov_type
          ,jeh.currency_conversion_date        curr_cov_date
          ,decode(jeh.global_attribute_category, 'JE.CN.GLXJEENT.HEADER',
                  nvl(jeh.global_attribute1, 'N'), 'N'
                 )                             inter_flag
          ,jeh.DEFAULT_EFFECTIVE_DATE          effective_date
    FROM GL_JE_HEADERS                       jeh
        ,gl_je_categories_tl                 jec
        ,JA_CN_DFF_ASSIGNMENTS               DFF
    WHERE jeh.ledger_id = l_ledger_id              --using variable P_LEDGER_ID
      AND jeh.period_name = l_period_name          --using variable l_period_name
          --check the Journal Category is Cash Related or not
      AND jeh.je_category = jec.je_category_name   --user_je_category_name
      AND DFF.DFF_TITLE_CODE = 'JOCA'
      AND jec.context = DFF.CONTEXT_CODE
      AND jec.language = userenv('LANG')
      AND nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',jec.attribute1, 'ATTRIBUTE2',jec.attribute2,
              'ATTRIBUTE3',jec.attribute3, 'ATTRIBUTE4',jec.attribute4, 'ATTRIBUTE5',jec.attribute5),
           'N') = 'Y'
          -- to locate cash flow item in dff_assignment
      AND dff.Application_Id = 101
      AND dff.chart_of_accounts_id = l_coa_id    --using variable l_coa_id
          --check the Journal's Status
      AND jeh.status = 'P'
      --fix bug 5665083, 2006-11-16, Andrew/ 4/03/2007, Altered by Yucheng.Sun :
      --  should exclude AGIS, AP, AR in GL data collection.
      AND jeh.je_source NOT IN ('Intercompany')--, 'Payables', 'Receivables'
      --  exclude the source defined in in cash flow item mapping form (ja_cn_cfs_item_mapping_hdrs)
      AND jeh.je_source NOT IN ( SELECT FAPP.APPLICATION_SHORT_NAME
                                 FROM FND_APPLICATION FAPP, JA_CN_CFS_ITEM_MAPPING_HDRS JCCIMH
                                 WHERE FAPP.APPLICATION_ID=JCCIMH.APPLICATION_ID
                                )
        ;

    --  Cursor to get specified GL Journal's lines.
    --  Accoding to the user's decision, there can be some lines have entered DR/CR
    --  but the accounted DR/CR have no relevant values, or even null.
    CURSOR c_gl_lines IS
    SELECT jel.je_line_num                     line_num
          ,nvl(jel.description,
               jeh.description)                line_desc
          ,jel.code_combination_id             account_ccid
          ,decode(jel.context, dffa.context_code,
              decode(dffa.attribute_column, 'ATTRIBUTE1',jel.attribute1, 'ATTRIBUTE2',jel.attribute2,
               'ATTRIBUTE3',jel.attribute3, 'ATTRIBUTE4',jel.attribute4, 'ATTRIBUTE5',jel.attribute5,
               'ATTRIBUTE6',jel.attribute6, 'ATTRIBUTE7',jel.attribute7, 'ATTRIBUTE8',jel.attribute8,
               'ATTRIBUTE9',jel.attribute9, 'ATTRIBUTE10',jel.attribute10, 'ATTRIBUTE11',jel.attribute11,
               'ATTRIBUTE12',jel.attribute12, 'ATTRIBUTE13',jel.attribute13, 'ATTRIBUTE14',jel.attribute14,
               'ATTRIBUTE15',jel.attribute15) )cash_related_item
          ,nvl(jel.ENTERED_DR, 0) -
              nvl(jel.ENTERED_CR, 0)           je_entered_amount
          ,nvl(jel.ACCOUNTED_DR, 0) -
              nvl(jel.ACCOUNTED_CR, 0)         je_accounted_amount
      FROM GL_JE_LINES                         jel
          ,GL_JE_HEADERS                       jeh
          ,ja_cn_dff_assignments               dffa
     WHERE jel.je_header_id = l_je_header_id       --using variable l_je_header_id
       AND jeh.je_header_id = jel.je_header_id
           -- to locate cash flow item in dff_assignment
       AND dffa.Application_Id = 101
       AND dffa.chart_of_accounts_id = l_coa_id    --using variable l_coa_id
       AND dffa.dff_title_code='GLLI';


  --AGIS
    --  Cursor to get AGIS transactions in the specified period,
    --  Only consider transactions whose accounts are Cash Related and Status are complete.
    CURSOR c_trx_header IS
    SELECT  trxh.trx_id                        trxh_ID
          , trxh.trx_number                    trxh_num
          , nvl(trxh.description,nvl(trxb.description,''))
                                               trxh_decription
          , trxh.initiator_id                  trxh_initiator_ID
          , trxh.recipient_id                  trxh_recipient_ID
          , trxh.to_le_id                      trxh_to_le_ID
          , trxh.to_ledger_id                  trxh_to_ledger_ID
          --, trxh.status                        trxh_status
          , trxh.init_amount_cr                trxh_init_amount_cr
          , trxh.init_amount_dr                trxh_init_amount_dr
          , trxh.reci_amount_cr                trxh_reci_amount_cr
          , trxh.reci_amount_dr                trxh_reci_amount_dr
          , trxb.batch_id                      trxb_batch_ID
          , trxb.batch_number                  trxb_batch_num
          , trxb.gl_date                       trxb_gl_date
          , trxb.currency_code                 trxb_curr_code
          , trxb.from_le_id                    trxb_from_le_ID
          , trxb.from_ledger_id                trxb_from_ledger_ID
          , nvl(trxb.exchange_rate_type,'')    trxb_curr_cov_rate
          , trxb.batch_date                    trxb_batch_date
/*          , nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',trxh.attribute1, 'ATTRIBUTE2',trxh.attribute2,
               'ATTRIBUTE3',trxh.attribute3, 'ATTRIBUTE4',trxh.attribute4, 'ATTRIBUTE5',trxh.attribute5,
               'ATTRIBUTE6',trxh.attribute6, 'ATTRIBUTE7',trxh.attribute7, 'ATTRIBUTE8',trxh.attribute8,
               'ATTRIBUTE9',trxh.attribute9, 'ATTRIBUTE10',trxh.attribute10, 'ATTRIBUTE11',trxh.attribute11,
               'ATTRIBUTE12',trxh.attribute12, 'ATTRIBUTE13',trxh.attribute13, 'ATTRIBUTE14',trxh.attribute14,
               'ATTRIBUTE15',trxh.attribute15)
               , '')                           trxh_cash_related_item*/
    FROM   FUN_TRX_HEADERS                    trxh
         , FUN_TRX_BATCHES                    trxb
         , FUN_TRX_TYPES_TL                   trxtype
         --, JA_CN_DFF_ASSIGNMENTS              dff
    WHERE  trxh.batch_id=trxb.batch_id
      AND  trxb.trx_type_id=trxtype.trx_type_id
      --
      --AND  dff.DFF_TITLE_CODE='IITL'--'JOCA'
           -- check the transaction status, care only complete trx.
           -- and its journel had been post to GL
      AND  trxh.status = 'COMPLETE'
      AND  trxb.status = 'COMPLETE'
           -- determine the trx type is transfered to GL
      AND  trxh.invoice_flag='N'
           -- add period limite , have to limite the gl_date in the period.
      AND  trxb.gl_date between l_period_start_date and l_perioD_end_date
      AND  trxtype.language=userenv('LANG')

/*      -- FOR TEST-----------------------------------------------------------
      and  trxh.batch_id in (83193,83194)
      -- FOR TEST-----------------------------------------------------------
      */;

    --Cursor to get specified transaction's lines, including both sender and receiver parts.
    CURSOR c_trx_line IS
    SELECT DISTINCT
           trl.Line_Number                     line_num
          ,trl.line_id                         line_id
          ,trldist.dist_id                     distl_id
          ,trldist.party_id                    distl_party_id
          ,trldist.party_type_flag             distl_party_flg
          ,trldist.dist_type_flag              distl_dist_flg
          ,trldist.ccid                        distl_ccid
          ,trldist.amount_cr                   distl_amount_cr
          ,trldist.amount_dr                   distl_amount_dr
          ,trldist.dist_number                 distl_number
          ,codecmb.chart_of_accounts_id        codecmb_coa_id
          ,nvl(DECODE(DFF.ATTRIBUTE_COLUMN, 'ATTRIBUTE1',trldist.attribute1, 'ATTRIBUTE2',trldist.attribute2,
               'ATTRIBUTE3',trldist.attribute3, 'ATTRIBUTE4',trldist.attribute4, 'ATTRIBUTE5',trldist.attribute5,
               'ATTRIBUTE6',trldist.attribute6, 'ATTRIBUTE7',trldist.attribute7, 'ATTRIBUTE8',trldist.attribute8,
               'ATTRIBUTE9',trldist.attribute9, 'ATTRIBUTE10',trldist.attribute10, 'ATTRIBUTE11',trldist.attribute11,
               'ATTRIBUTE12',trldist.attribute12, 'ATTRIBUTE13',trldist.attribute13, 'ATTRIBUTE14',trldist.attribute14,
               'ATTRIBUTE15',trldist.attribute15)
               , '')                           distl_cash_related_item
      FROM FUN_TRX_LINES                       trl
          ,FUN_DIST_LINES                      trldist
          ,GL_CODE_COMBINATIONS                codecmb
          ,FND_SEGMENT_ATTRIBUTE_VALUES        fsav
          --,JA_CN_LEDGER_LE_BSV_GT              tmpbsv
          ,JA_CN_DFF_ASSIGNMENTS               dff
          ,xle_entity_profiles                 xep  -- Added for fixing bug# 8744259 by Chaoqun on 30-Jul-2009
     WHERE trl.line_id=trldist.line_id
       AND trl.trx_id=trldist.trx_id
       AND trldist.ccid=codecmb.code_combination_id
       AND trl.trx_id=l_trxh_header_id                     --using variable l_trx_id
       AND codecmb.chart_of_accounts_id=l_coa_id           --using variable p_coa_id
       AND  dff.DFF_TITLE_CODE='IITL'             --'JOCA'
       --AND trldist.dist_type_flag='L'           -- ?? not sure
       /*AND  tmpbsv.ledger_id = l_ledger_id
       AND  tmpbsv.legal_entity_id = l_le_id
       AND  DECODE(fsav.APPLICATION_COLUMN_NAME,           --segment FSAV.APPLICATION_COLUMN_NAME of codecmb
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
                  ) = tmpbsv.bal_seg_value                 --select only company segment list in the ja_cn_ledger_le_bsv_gt table */
           --locate to the right segment attribute value
       AND fsav.application_id  = 101
       AND fsav.id_flex_num  = l_coa_id
       AND fsav.attribute_value = 'Y'
       AND fsav.segment_attribute_type = 'GL_BALANCING'
       AND FUN_TCA_PKG.GET_LE_ID(trldist.party_id)= xep.Party_Id -- Added for fixing bug# 8744259 by Chaoqun on 30-Jul-2009
       AND xep.legal_entity_id = l_le_id                         -- Added for fixing bug# 8744259 by Chaoqun on 30-Jul-2009
          ;

--body
 BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.P_SOURCE'
                     ,P_SOURCE_APP_ID
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    --Get the BSV reffered to the current legal entity and ledger
    DELETE
    FROM   JA_CN_LEDGER_LE_BSV_GT;
    COMMIT ;
    --
    --ja_cn_utility_pkg.populate_ledger_le_bsv_gt( P_LEDGER_ID,P_LE_ID);

    IF ja_cn_utility.populate_ledger_le_bsv_gt( P_LEDGER_ID,P_LE_ID) <> 'S' THEN
       RETURN;
    END IF;

    --GET SOURCR SHORT NAME FROM FND_APPLICATION
    SELECT appl.application_short_name
      INTO l_source_name
    FROM   fnd_application appl
    WHERE  appl.application_id= l_source_application_id;

    --Collect Data from GL/GIS

    IF l_source_application_id = 101 THEN
    --Collect Data from GL
      --Get Functional currency code of Current ledger
      SELECT ledger.currency_code
        INTO l_je_func_curr_code
        FROM GL_LEDGERS ledger
       WHERE ledger.ledger_id=P_LEDGER_ID;

      --Get all periods between (P_GL_PERIOD_FROM, P_GL_PERIOD_TO).
      OPEN c_period_name;
      LOOP
        FETCH c_period_name INTO l_period_name
                                ,l_period_year
                                ,l_period_num
                                ,l_period_start_date
                                ,l_period_end_date ;
        EXIT WHEN c_period_name%NOTFOUND;

        --Delete all rows from GL and between FROM/TO Periods in table JA_CN_CFS_ACTIVITIES_ALL.
        DELETE
        FROM JA_CN_CFS_ACTIVITIES_ALL s
        WHERE LEGAL_ENTITY_ID=P_LE_ID
          -- Fix bug by arming delete start
          -- AND SOURCE='GL'
          -- Fix bug by arming delete end
          -- Fix bug by arming add start
          AND SOURCE=l_source_name
          AND NVL(UPGRADE_FLAG, ' ')<>'P'
          -- Fix bug by arming add end
          AND PERIOD_NAME=l_period_Name;
        --
        COMMIT;

        --Collect Data from GL and between the FROM/TO Periods.
        --  Only consider Journals whose categories is Cash Related and Status is Posted.
        OPEN c_gl;
        LOOP
          FETCH c_gl INTO l_je_header_id
                         ,l_je_catg
                         ,l_je_jnl_name
                         ,l_je_jnl_doc_seq_num
                         ,l_je_curr_code
                         ,l_je_curr_cov_rate
                         ,l_je_curr_cov_type
                         ,l_je_curr_cov_date
                         ,l_je_inter_flag
                         ,l_je_effective_date;
          EXIT WHEN c_gl%NOTFOUND;
          --
          OPEN c_gl_lines;
          LOOP
            FETCH c_gl_lines INTO l_je_line_num
                                 ,l_je_line_desc
                                 ,l_ccid
                                 ,l_cash_related_item
                                 ,l_je_line_amount
                                 ,l_je_line_func_amount;
            EXIT WHEN c_gl_lines%NOTFOUND;

            l_csi_check := 'NB';
            IF l_cash_related_item is null
            THEN
              l_csi_check := 'B';
            END IF;

            -- to check whether the gl is cash related AND its company segment belongs to current LE.
            l_line_check := GL_InterCom_Line_Check( P_COA_ID            => l_coa_id--P_COA_ID
                                                   ,P_LEDGER_ID         => l_ledger_id
                                                   ,P_LE_ID             => l_le_id
                                                   ,P_SOURCE            => 'GL'
                                                   ,P_JT_ID             => l_je_header_id
                                                   ,P_LINE_NUM          => TO_CHAR(l_je_line_num)
                                                   ,P_CCID              => l_ccid
                                                   ,P_CASH_RELATED_ITEM => l_csi_check
                                                   ,P_GIS_JNL_CRI       => l_cash_related_item_1
                                                  );
             --The line's is Cash Related AND its company segment belongs to current LE.
            IF l_line_check = 'Y' THEN
              IF l_cash_related_item_1 is not null
              THEN
                 l_cash_related_item := l_cash_related_item_1;
              END IF;
              --insert the row
              INSERT INTO JA_CN_CFS_ACTIVITIES_ALL
                    ( CFS_ACTIVITY_ID
                     ,LEGAL_ENTITY_ID
                     ,LEDGER_ID
                     ,ORG_ID
                     ,TRX_ID
                     ,TRX_NUMBER
                     ,TRX_LINE_ID
                     ,SOURCE_APPLICATION_ID
                     ,TRANSACTION_TYPE
                     ,DOCUMENT_SEQUENCE_NUMBER
                     ,TRANSACTION_DATE
                     ,GL_DATE
                     ,PERIOD_NAME
                     ,FUNC_CURR_CODE
                     ,FUNC_AMOUNT
                     ,ORIGINAL_CURR_CODE
                     ,ORIGINAL_AMOUNT
                     ,CURRENCY_CONVERSION_RATE
                     ,CURRENCY_CONVERSION_TYPE
                     ,CURRENCY_CONVERSION_DATE
                     ,DESCRIPTION
                     ,DETAILED_CFS_ITEM
                     --,INTERCOMPANY_FLAG
                     ,CREATION_DATE
                     ,CREATED_BY
                     ,LAST_UPDATE_DATE
                     ,LAST_UPDATED_BY
                     ,LAST_UPDATE_LOGIN
                     ,source
                     --,reference_number
                     ,BALANCING_SEGMENT--Fix bug#7334017  add
                    )
              VALUES( ja_cn_cfs_activities_s.nextval
                     ,l_le_id
                     ,P_LEDGER_ID                   -- ledger id
                     ,null
                     ,l_je_header_id
                     ,l_je_jnl_name
                     ,TO_CHAR(l_je_line_num)
                     ,l_source_application_id
                     ,'JOURNAL'
                     ,l_je_jnl_doc_seq_num
                     ,l_je_effective_date
                     ,l_je_effective_date
                     ,l_period_name
                     ,l_je_func_curr_code           --  currency code from gl_ledger
                     ,l_je_line_func_amount
                     ,l_je_curr_code
                     ,l_je_line_amount
                     ,l_je_curr_cov_rate
                     ,l_je_curr_cov_type
                     ,l_je_curr_cov_date
                     ,l_je_line_desc
                     ,l_cash_related_item           --lines GDF
                     --,l_je_inter_flag             -- not sure
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,fnd_global.LOGIN_ID
                     ,l_source_name                 --'GL'   -- for source,seeded data
                     --,l_je_jnl_name     --sanme as TRX_NUMBER
                     ,get_balancing_segment(l_ccid)--Fix bug#7334017  add
                    );
                commit;
             END IF;
          END LOOP;
          CLOSE c_gl_lines;
       END LOOP;
       CLOSE c_gl;
     END LOOP;
     CLOSE c_period_name;

 --  ELSIF P_SOURCE = 'AGIS' THEN
 ELSIF l_source_application_id = 435 THEN
 --AGIS
      --Get Functional currency code of Current ledger
      SELECT ledger.currency_code
        INTO l_je_func_curr_code
        FROM GL_LEDGERS ledger
       WHERE ledger.ledger_id=P_LEDGER_ID;

      --Collect Data from AGIS, Collect Data from Intercompany
      --  Get all periods between (P_START_PERIOD, P_END_PERIOD).
      OPEN c_period_name;
      LOOP
        FETCH c_period_name INTO l_period_name
                                ,l_period_year
                                ,l_period_num
                                ,l_period_start_date
                                ,l_period_end_date ;
        EXIT WHEN c_period_name%NOTFOUND;

        --Delete all rows from GIS and between FROM/TO Periods in table JA_CN_CFS_ACTIVITIES_ALL.
        DELETE
          FROM JA_CN_CFS_ACTIVITIES_ALL
         WHERE LEGAL_ENTITY_ID = l_le_id
           AND PERIOD_NAME = l_period_name
           --AND SOURCE = 'GIS' --fix bug 7488206 delete
            AND SOURCE=l_source_name  ;--fix bug 7488206 add
        --
        commit;

        --Collect Data from Intercompany and between the FROM/TO Periods.
        --  Only consider Transactions whose sender and receiver transfer flag are 'Yes'.
        OPEN c_trx_header;
        LOOP
          FETCH c_trx_header INTO l_trxh_header_id
                                 ,l_trxh_header_num
                                 ,l_trxh_desc
                                 ,l_trxh_initiator_id     -- sender
                                 ,l_trxh_recipient_id     -- receivor
                                 ,l_trxh_to_le_id
                                 ,l_trxh_to_ledger_id
                                 ,l_trxh_init_amount_cr
                                 ,l_trxh_init_amount_dr
                                 ,l_trxh_reci_amount_cr
                                 ,l_trxh_reci_amount_dr
                                 ,l_trxb_batch_id
                                 ,l_trxb_batch_num
                                 ,l_trxb_gl_date
                                 ,l_trxb_curr_code
                                 ,l_trxb_from_le_id
                                 ,l_trxb_from_ledger_id
                                 ,l_trxb_curr_cov_type
                                 ,l_trxb_entered_date -- ?? not sure, the batch date or the header last update date
                                 --,l_trxh_cash_rel_item
                                 ;
          EXIT WHEN c_trx_header%NOTFOUND;

          -- For each lines in current transaction
          OPEN c_trx_line;
          LOOP
            FETCH c_trx_line INTO l_trxl_num
                                 ,l_trxl_id
                                 ,l_distl_id
                                 ,l_distl_party_id
                                 ,l_distl_party_type_flg
                                 ,l_distl_dist_type_flg
                                 ,l_distl_ccid
                                 ,l_distl_amount_cr
                                 ,l_distl_amount_dr
                                 ,l_distl_number
                                 ,l_codecmb_coa_id
                                 ,l_distl_cash_rel_item
                                 ;
            EXIT WHEN c_trx_line%NOTFOUND;

            -- get current currency rate from the gl_ledger and gl_daily_rates tables.
            IF l_distl_party_type_flg='I' THEN
              -- sender convertion rate
               l_get_trx_cov_rate_flg := FALSE;
               l_get_trx_cov_rate_flg := AGIS_Get_Curr_Rate_Type(
                                            P_LEDGER_ID             => l_ledger_id
                                           ,P_LE_ID                 => l_le_id
                                           ,P_AGIS_LE_ID            => l_trxb_from_le_id
                                           ,P_AGIS_LEDGER_ID        => l_trxb_from_ledger_id
                                           ,P_GL_DATE               => l_trxb_gl_date
                                           ,P_AGIS_CURR_COV_TYPE    => l_trxb_curr_cov_type
                                           ,P_AGIS_CURR_CODE        => l_trxb_curr_code
                                           ,P_AGIS_CURR_RATE        => l_trxh_curr_cov_rate
                                           );
                IF l_get_trx_cov_rate_flg = FALSE THEN
                   EXIT;
                END IF;
            ELSIF l_distl_party_type_flg='R' THEN
              -- receiver convertion rate
               l_get_trx_cov_rate_flg:=FALSE;
               l_get_trx_cov_rate_flg := AGIS_Get_Curr_Rate_Type(
                                            P_LEDGER_ID             => l_ledger_id
                                           ,P_LE_ID                 => l_le_id
                                           ,P_AGIS_LE_ID            => l_trxh_to_le_id
                                           ,P_AGIS_LEDGER_ID        => l_trxh_to_ledger_id
                                           ,P_GL_DATE               => l_trxb_gl_date
                                           ,P_AGIS_CURR_COV_TYPE    => l_trxb_curr_cov_type
                                           ,P_AGIS_CURR_CODE        => l_trxb_curr_code
                                           ,P_AGIS_CURR_RATE        => l_trxh_curr_cov_rate
                                           );
                IF  l_get_trx_cov_rate_flg = FALSE THEN
                    EXIT;
                END IF;

            END IF;
            -- set the currente amount
            l_current_amount_cr := nvl(l_distl_amount_cr,0);--nvl(l_trxh_reci_amount_cr,0);
            l_current_amount_dr := nvl(l_distl_amount_dr,0);--nvl(l_trxh_reci_amount_dr,0);

            l_csi_check := 'NB';
            IF l_distl_cash_rel_item ='' OR l_distl_cash_rel_item is null THEN
                 l_csi_check := 'B';
            END IF;

            -- secondly: check whether there are cash related segment
            l_line_check := GL_InterCom_Line_Check( P_COA_ID            => l_coa_id
                                                   ,P_LEDGER_ID         => l_ledger_id
                                                   ,P_LE_ID             => l_le_id
                                                   ,P_SOURCE            => 'AGIS'
                                                   ,P_JT_ID             => l_distl_id
                                                   ,P_LINE_NUM          => TO_CHAR(l_trxh_header_num)
                                                   ,P_CCID              => l_distl_ccid
                                                   ,P_CASH_RELATED_ITEM => l_csi_check              -- not sure
                                                   ,P_GIS_JNL_CRI       => l_distl_cash_rel_item_l  -- not sure
                                      );

            --The line's is Cash Related AND its company segment belongs to current LE.
            IF l_line_check = 'Y' THEN
                IF l_distl_cash_rel_item_l is not null
                THEN
                   l_distl_cash_rel_item := l_distl_cash_rel_item_l;
                END IF;

                Process_GL_Rounding( P_LE_ID          =>  P_LE_ID
                                    ,P_AMOUNT         =>  (l_current_amount_dr-l_current_amount_cr) * l_trxh_curr_cov_rate
                                    ,P_CURRENCY_CODE  =>  l_trxb_curr_code
                                    ,P_AMOUNT_ROUNDED =>  l_tr_func_amount
                                   );
                 --insert the row
                INSERT INTO JA_CN_CFS_ACTIVITIES_ALL
                      ( CFS_ACTIVITY_ID
                       ,LEGAL_ENTITY_ID
                       ,LEDGER_ID
                       ,ORG_ID
                       ,TRX_ID
                       ,TRX_NUMBER
                       ,TRX_LINE_ID
                       ,SOURCE_APPLICATION_ID
                       ,TRANSACTION_TYPE
                       ,DOCUMENT_SEQUENCE_NUMBER
                       ,TRANSACTION_DATE
                       ,GL_DATE
                       ,PERIOD_NAME
                       ,FUNC_CURR_CODE
                       ,FUNC_AMOUNT
                       ,ORIGINAL_CURR_CODE
                       ,ORIGINAL_AMOUNT
                       ,CURRENCY_CONVERSION_RATE
                       ,CURRENCY_CONVERSION_TYPE
                       ,CURRENCY_CONVERSION_DATE
                       ,DESCRIPTION
                       ,DETAILED_CFS_ITEM
                       --,INTERCOMPANY_FLAG           -- delete in R12
                       ,CREATION_DATE
                       ,CREATED_BY
                       ,LAST_UPDATE_DATE
                       ,LAST_UPDATED_BY
                       ,LAST_UPDATE_LOGIN
                       ,SOURCE
                       --,reference_number
                       ,BALANCING_SEGMENT
                      )
                VALUES( ja_cn_cfs_activities_s.nextval
                       ,l_le_id
                       ,P_LEDGER_ID                    -- ledger id
                       ,NULL
                       ,l_trxh_header_id               -- ?? batch id
                      -- ,l_trxh_header_num              -- ?? batch number: transaction header number fix bug 7488191 delete
                       ,l_trxb_batch_num                -- fix bug 7488191 add
                       ,TO_CHAR(l_distl_number)        -- ?? header number
                       ,l_source_application_id        -- application TD of  AGIS
                       ,'AGIS'                         -- seeded data
                       ,NULL
                       ,l_trxb_entered_date           -- batches: batch_date
                       ,l_trxb_gl_date                -- batches: gl_date
                       ,l_period_name                 -- parameters: period name
                       ,l_je_func_curr_code           --  function currency of current Ledger to FUNC_CURR_CODE
                       ,l_tr_func_amount              -- lines: acounted_dr-accounted_cr                            --?? not sure
                       ,l_trxb_curr_code              -- batches: currency code
                       ,l_current_amount_dr-l_current_amount_cr       -- lines: entered_dr-entered_cr               --?? not sure
                       ,l_trxh_curr_cov_rate          -- GL_DAILY_RATES.CONVERSION_RATE
                       ,l_trxb_curr_cov_type          -- conversion_type of line's subsidary(s/r)
                       ,l_trxb_gl_date                -- batches: gl_date
                       ,l_trxh_desc                   -- header: description
                       ,l_distl_cash_rel_item         -- the attribute* name
                       --,l_je_inter_flag             -- delete in R12
                       ,SYSDATE
                       ,fnd_global.user_id
                       ,SYSDATE
                       ,fnd_global.user_id
                       ,fnd_global.LOGIN_ID
                       ,l_source_name                 --'GIS'  -- for source,seeded data
                       --,l_je_jnl_name     --sanme as TRX_NUMBER
                       ,get_balancing_segment(l_distl_ccid)--Fix bug#7334017  add
                      );
                  --
                  commit;
            END IF;

          END LOOP;
          CLOSE c_trx_line;
       END LOOP;
       CLOSE c_trx_header;
    END LOOP;
    CLOSE c_period_name;
  END IF;

END Collect_GL_InterCom_Data;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfs_Data_Clt                  public
  --
  --  DESCRIPTION:
  --      This procedure calls data collection programs according to
  --      the specified source.
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID             NUMBER              ID of LEDGER
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_PERIOD_SET_NAME       VARCHAR2            Name of the period set
  --                                                      in the set of book
  --      In: P_GL_PERIOD_FROM        VARCHAR2            Start period
  --      In: P_GL_PERIOD_TO          VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Source of the collection
  --
  --      In: P_DFT_ITEM              VARCHAR2            default CFS item
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/01/2006     Andrew Liu          Created
  --      04/02/2007     Yucheng Sun         Altered: Added the logic of AGIS model.
  --                                         Delete the AP,AR logic
  --===========================================================================
   PROCEDURE Cfs_Data_Clt( P_COA_ID           IN NUMBER
                         ,P_LEDGER_ID        IN NUMBER
                         ,P_LE_ID            IN NUMBER
                         ,P_PERIOD_SET_NAME  IN VARCHAR2
                         ,P_GL_PERIOD_FROM   IN VARCHAR2
                         ,P_GL_PERIOD_TO     IN VARCHAR2
                         ,P_SOURCE           IN VARCHAR2
  ) IS

  l_source_id               NUMBER(15);
  --l_source                  varchar(200):=P_SOURCE;
  l_source                  VARCHAR2(15):= P_SOURCE;

  BEGIN
   	IF L_source is null
    THEN
		  Collect_GL_InterCom_Data( P_COA_ID          => P_COA_ID
                               ,P_LEDGER_ID       => P_LEDGER_ID
                               ,P_LE_ID           => P_LE_ID
                               ,P_PERIOD_SET_NAME => P_PERIOD_SET_NAME
                               ,P_GL_PERIOD_FROM  => P_GL_PERIOD_FROM
                               ,P_GL_PERIOD_TO    => P_GL_PERIOD_TO
                               ,P_SOURCE_APP_ID   => 101  --Gl
                              );

		  Collect_GL_InterCom_Data( P_COA_ID          => P_COA_ID
                               ,P_LEDGER_ID       => P_LEDGER_ID
                               ,P_LE_ID           => P_LE_ID
                               ,P_PERIOD_SET_NAME => P_PERIOD_SET_NAME
                               ,P_GL_PERIOD_FROM  => P_GL_PERIOD_FROM
                               ,P_GL_PERIOD_TO    => P_GL_PERIOD_TO
                               ,P_SOURCE_APP_ID   => 435  --AGIS
                              );

     JA_CN_CFS_CLT_SLA_PKG.Collect_SLA_Data( P_COA_ID          =>P_COA_ID
                                             ,P_LEDGER_ID       => P_LEDGER_ID
                                             ,P_LE_ID           => P_LE_ID
                                             ,P_PERIOD_SET_NAME => P_PERIOD_SET_NAME
                                             ,P_GL_PERIOD_FROM  => P_GL_PERIOD_FROM
                                             ,P_GL_PERIOD_TO    => P_GL_PERIOD_TO
                                             ,P_SOURCE          => 'ALL'
                                             );
     ELSE
         BEGIN
           SELECT application_id
             INTO l_source_id
             FROM fnd_application
            WHERE application_short_name = TO_CHAR(l_source);
         EXCEPTION
           WHEN no_data_found THEN
             l_source_id := NULL;
           WHEN too_many_rows THEN
             l_source_id := NULL;
         END;
            IF nvl(l_source_id,-1) = 101 or nvl(l_source_id ,-1)= 435 THEN
		           Collect_GL_InterCom_Data(  P_COA_ID          =>P_COA_ID
                                         ,P_LEDGER_ID       => P_LEDGER_ID
                                         ,P_LE_ID           => P_LE_ID
                                         ,P_PERIOD_SET_NAME => P_PERIOD_SET_NAME
                                         ,P_GL_PERIOD_FROM  => P_GL_PERIOD_FROM
                                         ,P_GL_PERIOD_TO    => P_GL_PERIOD_TO
                                         ,P_SOURCE_APP_ID   => l_source_id
                                        );
             ELSE
              JA_CN_CFS_CLT_SLA_PKG.Collect_SLA_Data( P_COA_ID   =>P_COA_ID
                                              ,P_LEDGER_ID       => P_LEDGER_ID
                                              ,P_LE_ID           => P_LE_ID
                                              ,P_PERIOD_SET_NAME => P_PERIOD_SET_NAME
                                              ,P_GL_PERIOD_FROM  => P_GL_PERIOD_FROM
                                              ,P_GL_PERIOD_TO    => P_GL_PERIOD_TO
                                              ,P_SOURCE          => P_SOURCE
                                              );
              END IF;

    END IF;
  END Cfs_Data_Clt;


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
--	    09/01/2008     Yao Zhang          Created
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
     AND FSAV.SEGMENT_ATTRIBUTE_TYPE = 'GL_BALANCING'
     AND FSAV.ID_FLEX_NUM = GCC.CHART_OF_ACCOUNTS_ID
     AND FSAV.ID_FLEX_CODE = 'GL#';--Fix bug#7334017  add

   RETURN L_BALANCING_SEGMENT;
END get_balancing_segment;
-- Fix bug#6359169 add end

--==========================================================================

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
--	    03/01/2006     Jogen Hu          Created
--===========================================================================
PROCEDURE put_line
( p_str                  IN        VARCHAR2
)
IS
BEGIN
     FND_FILE.Put_Line(FND_FILE.Output,p_str);
END put_line;

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
--	    03/01/2006     Jogen Hu          Created
--===========================================================================
PROCEDURE put_log
( p_module               IN        VARCHAR2
, p_message              IN        VARCHAR2
)
IS
BEGIN
    --fnd_file.PUT_LINE(fnd_file.LOG,p_module||':'||p_message);
    IF(  fnd_log.LEVEL_STATEMENT >= g_debug_devel )
    THEN
       fnd_log.STRING( LOG_LEVEL => fnd_log.LEVEL_STATEMENT
                     , MODULE    => p_module
                     , MESSAGE   => p_message
                     );
    END IF;
--     xx_jogen_log(p_module||':'||p_message);
END put_log;

--==========================================================================
--  FUNCTION NAME:
--    get_period_name                     Public
--
--  DESCRIPTION:
--      	This FUNCTION is used to get period name from a period set and given date
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
--	    03/08/2006     Jogen Hu          Created
--===========================================================================
FUNCTION get_period_name
(
  p_period_set_name      IN VARCHAR2
, p_gl_date              IN DATE
, p_period_type          IN VARCHAR2
)RETURN VARCHAR2
IS
l_period_name            VARCHAR2(30);
BEGIN
   SELECT period_name
     INTO l_period_name
     FROM gl_periods
    WHERE period_set_name = p_period_set_name
      AND start_date      <=p_gl_date
      AND End_Date        >=p_gl_date
      AND period_type     = p_period_type
      AND adjustment_period_flag = 'N';

   RETURN l_period_name;

END get_period_name;




   /*   IF(  G_PROC_LEVEL >= g_debug_devel )
      THEN
        put_log(G_MODULE_PREFIX||l_procedure_name||'.period rowcount'
               ,l_row_count);
      END IF;  --( G_PROC_LEVEL >= g_debug_devel)*/
BEGIN
   g_debug_devel:=fnd_log.G_CURRENT_RUNTIME_LEVEL;

  -- Initialization
  --l_resp_id := FND_PROFILE.VALUE('RESP_ID');
  --l_org_id := FND_PROFILE.VALUE('ORG_ID')
  --:$PROFILES$.JA_CN_LEGAL_ENTITY
  --null;

END JA_CN_CFS_DATA_CLT_PKG;


/
