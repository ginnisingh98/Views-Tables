--------------------------------------------------------
--  DDL for Package Body JA_CN_POST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_POST_UTILITY_PKG" AS
--$Header: JACNPSTB.pls 120.1.12000000.1 2007/08/13 14:09:45 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNPSTB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used in account and journal itemizatoin to post   |
--|     the CNAO journal to CNAO balance                                  |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE put_line                                               |
--|      PROCEDURE put_log                                                |
--|      PROCEDURE post_journal_itemized                                  |
--|      PROCEDURE open_period                                            |
--|                                                                       |
--| HISTORY                                                               |
--|      02/21/2006     Jogen Hu          Created                         |
--|      04/28/2007     Qingjun Zhao      change SOB to Ledger for        |
--                                        upgrade from 11i to R12         |
--+======================================================================*/

TYPE cnao_balance_rec IS RECORD
(  ledger_id       ja_cn_account_balances.ledger_ID%TYPE
,  LEGAL_ENTITY_ID       ja_cn_account_balances.LEGAL_ENTITY_ID%TYPE
,  COMPANY_SEGMENT       ja_cn_account_balances.COMPANY_SEGMENT%TYPE
,  PERIOD_NAME           ja_cn_account_balances.PERIOD_NAME          %TYPE
,  CURRENCY_CODE         ja_cn_account_balances.CURRENCY_CODE        %TYPE
,  COST_CENTER           ja_cn_account_balances.COST_CENTER          %TYPE
,  THIRD_PARTY_TYPE      ja_cn_account_balances.THIRD_PARTY_TYPE     %TYPE
,  THIRD_PARTY_ID        ja_cn_account_balances.THIRD_PARTY_ID       %TYPE
,  THIRD_PARTY_NUMBER    ja_cn_account_balances.THIRD_PARTY_NUMBER   %TYPE
,  PROJECT_ID            ja_cn_account_balances.PROJECT_ID           %TYPE
,  PROJECT_NUMBER        ja_cn_account_balances.PROJECT_NUMBER       %TYPE
,  PROJECT_SOURCE        ja_cn_account_balances.PROJECT_SOURCE       %TYPE
,  ACCOUNT_SEGMENT       ja_cn_account_balances.ACCOUNT_SEGMENT      %TYPE
,  ACCOUNT_type          ja_cn_account_balances.ACCOUNT_type         %TYPE
,  PERSONNEL_ID          ja_cn_account_balances.PERSONNEL_ID         %TYPE
,  PERSONNEL_NUMBER      ja_cn_account_balances.PERSONNEL_NUMBER     %TYPE
,  FUNC_PERIOD_NET_DR    ja_cn_account_balances.FUNC_PERIOD_NET_DR   %TYPE
,  FUNC_PERIOD_NET_CR    ja_cn_account_balances.FUNC_PERIOD_NET_CR   %TYPE
,  ORIG_PERIOD_NET_DR    ja_cn_account_balances.ORIG_PERIOD_NET_DR   %TYPE
,  ORIG_PERIOD_NET_CR    ja_cn_account_balances.ORIG_PERIOD_NET_CR   %TYPE
,  PERIOD_MON            ja_cn_account_balances.PERIOD_MON           %TYPE
);

G_MODULE_PREFIX   VARCHAR2(30):='JA_CN_POST_UTILITY_PKG.';
G_PROC_LEVEL      INT         :=fnd_log.LEVEL_PROCEDURE;
G_STATEMENT_LEVEL INT         :=fnd_log.LEVEL_STATEMENT;
g_debug_devel     INT;

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
--	    02/21/2006     Jogen Hu          Created
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
--	    02/21/2006     Jogen Hu          Created
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
END put_log;

--==========================================================================
--  PROCEDURE NAME:
--    open_period                     private
--
--  DESCRIPTION:
--      		This procedure is used to open a period which had never post
--          journal from "Itemized journal table" to "Itemized balance table".
--          if the period is the first period of the fiscal year, transfer the
--          income and expense account to retained earnings account
--
--  PARAMETERS:
--      In: p_period_name          	     the period name needing to open
--          p_ledger_id             Set of book ID
--          p_legal_entity_ID            Legal entity id

--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    02/21/2006     Jogen Hu          Created
--      04/28/2007     Qingjun Zhao      Change SOB to Ledger for upgrade
--                                       from 11i to R12
--===========================================================================
PROCEDURE open_period
( p_period_name          IN        VARCHAR2
, p_ledger_id       IN        NUMBER
, p_legal_entity_ID      IN        NUMBER
)
IS
l_procedure_name    VARCHAR2(30):='open_period';
l_row_count         NUMBER;
--l_period_set_name   GL_PERIODS.PERIOD_SET_NAME%TYPE;
l_period_wrong      EXCEPTION;
l_flex_value_set_id FND_FLEX_VALUE_SETS.Flex_Value_Set_Id%TYPE;
l_period_year       gl_periods.period_year%TYPE;
l_period_num        ja_cn_periods.period_num%TYPE;
l_first_fiscal_period_flag CHAR(1);
l_prior_period_name gl_periods.period_name%TYPE;
l_prior_period_num  ja_cn_periods.period_num%TYPE;

l_period_month             ja_cn_account_balances.period_mon%TYPE;
/*l_RET_EARN_CODE_COMBINATION_ID gl_ledgers.ret_earn_code_combination_id%TYPE;

l_ret_company_segment  ja_cn_account_balances.company_segment%TYPE;
l_ret_cost_center_seg  ja_cn_account_balances.cost_center%TYPE;
l_ret_account_segment  ja_cn_account_balances.account_segment%TYPE;
l_ret_project_number   ja_cn_account_balances.company_segment%TYPE;
l_ret_project_id       ja_cn_account_balances.cost_center%TYPE;
l_ret_currence_code    ja_cn_account_balances.currency_code%TYPE;

l_ret_acct_balance_dr      gl_balances.begin_balance_dr%TYPE;
l_ret_acct_balance_cr      gl_balances.begin_balance_cr%TYPE;
l_ret_acct_balance_dr_beq  gl_balances.begin_balance_dr_beq%TYPE;
l_ret_acct_balance_cr_beq  gl_balances.begin_balance_cr_beq%TYPE;

l_ret_account_type     ja_cn_account_balances.account_type%TYPE;

l_cost_center_second_tracking BOOLEAN:=FALSE;

--get retained earning account segements: company, account, cost center
CURSOR c_retain_account1(pc_RET_EARN_CODE_COMBIN_ID IN NUMBER
                        ,pc_flex_value_set_id            IN NUMBER) IS
SELECT jcc.company_segment
    , jcc.account_segment
    , jcc.cost_segment
    , jcc.project_number
    , jcc.project_id
    , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1) account_type
 FROM ja_cn_code_combination_v jcc
    , FND_FLEX_VALUES ffv
WHERE jcc.ledger_id     = p_ledger_id
  AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
  AND ffv.FLEX_VALUE_SET_ID = pc_flex_value_set_id
  AND ffv.flex_value    = jcc.account_segment
  AND (jcc.company_segment, jcc.account_segment, jcc.cost_segment) IN
        (SELECT jcc1.company_segment
              , jcc1.account_segment
              , jcc1.cost_segment
           FROM ja_cn_code_combination_v jcc1
          WHERE jcc1.CODE_COMBINATION_ID = pc_RET_EARN_CODE_COMBIN_ID
            AND jcc1.ledger_id     = p_ledger_id);

--get retained earning account segements: company, account, cost center
CURSOR c_retain_account2(pc_RET_EARN_CODE_COMBIN_ID IN NUMBER
                        ,pc_flex_value_set_id            IN NUMBER) IS
SELECT jcc.company_segment
    , jcc.account_segment
    , jcc.cost_segment
    , jcc.project_number
    , jcc.project_id
    , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1) account_type
 FROM ja_cn_code_combination_v jcc
    , FND_FLEX_VALUES ffv
WHERE jcc.ledger_id     = p_ledger_id
  AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
  AND ffv.FLEX_VALUE_SET_ID = pc_flex_value_set_id
  AND ffv.flex_value    = jcc.account_segment
  AND (jcc.company_segment, jcc.account_segment) IN
        (SELECT jcc1.company_segment
              , jcc1.account_segment
           FROM ja_cn_code_combination_v jcc1
          WHERE jcc1.CODE_COMBINATION_ID = pc_RET_EARN_CODE_COMBIN_ID
            AND jcc1.ledger_id     = p_ledger_id);*/

BEGIN

  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.begin'
                  ,'Enter procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel )

  put_log('open_period parameter',p_period_name);

  SELECT ifs.flex_value_set_id
    INTO l_flex_value_set_id
    FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
       , gl_ledgers led
       , Fnd_Id_Flex_Segments ifs
   WHERE sav.SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
     AND sav.ID_FLEX_CODE           = 'GL#'
     AND sav.APPLICATION_ID         = 101
     AND sav.attribute_value        = 'Y'
     AND sav.ID_FLEX_NUM            = led.chart_of_accounts_id
     AND ifs.application_id         = 101
     AND ifs.Id_Flex_Code           = 'GL#'
     AND ifs.id_flex_num            = led.chart_of_accounts_id
     AND ifs.APPLICATION_COLUMN_NAME= sav.APPLICATION_COLUMN_NAME
     AND led.ledger_id        = p_ledger_id;

  IF(  G_STATEMENT_LEVEL >= g_debug_devel )
  THEN
    put_log( G_MODULE_PREFIX||l_procedure_name||'.flex_value_set_id'
           , l_flex_value_set_id);
  END IF;  --(  G_STATEMENT_LEVEL >= g_debug_devel )

  SELECT COUNT(*)
    INTO l_row_count
    FROM JA_CN_PERIODS
   WHERE period_name = p_period_name
     AND ledger_id=p_ledger_id;

  IF l_row_count = 0 --The period is not processed before
  THEN
    --open the period
    INSERT INTO JA_CN_PERIODS
               ( ledger_id
               , START_DATE
               , END_DATE
               , PERIOD_NAME
               , PERIOD_NUM
               , PERIOD_YEAR
               , FIRST_FISCAL_PERIOD_FLAG
               , STATUS
               , CREATION_DATE
               , CREATED_BY
               , LAST_UPDATE_DATE
               , LAST_UPDATED_BY
               , LAST_UPDATE_LOGIN
               )
         SELECT p_ledger_id
              , gp.start_date
              , gp.end_date
              , p_period_name
              , gp.period_num+gp.period_year*1000
              , gp.period_year
              , decode(gp.period_num,1,'Y','N')
              , 'O'
              , SYSDATE
              , fnd_global.USER_ID
              , SYSDATE
              , fnd_global.USER_ID
              , fnd_global.LOGIN_ID
           FROM gl_ledgers led
              , gl_periods gp
          WHERE led.ledger_id=p_ledger_id
            AND led.period_set_name = gp.period_set_name
            AND gp.period_name      = p_period_name;

    IF SQL%ROWCOUNT = 0 --the given set of book ID or period name error
    THEN
       RAISE l_period_wrong;
    END IF;

    --get the prior period
    SELECT gp.period_year
         , gp.period_num
         , decode(gp.period_num,1,'Y','N')
      INTO l_period_year
         , l_period_num
         , l_first_fiscal_period_flag
      FROM gl_ledgers led
         , gl_periods gp
     WHERE led.ledger_id=p_ledger_id
       AND led.period_set_name = gp.period_set_name
       AND gp.period_name      = p_period_name;

    l_period_month :=  l_period_num;

    IF(  G_STATEMENT_LEVEL >= g_debug_devel )
    THEN
      put_log( G_MODULE_PREFIX||l_procedure_name||'.first_fiscal_period_flag'
             , l_first_fiscal_period_flag);
    END IF;  --(  G_STATEMENT_LEVEL >= g_debug_devel )

    SELECT MAX(period_num)
      INTO l_prior_period_num
      FROM JA_CN_PERIODS jjb
    WHERE jjb.ledger_id=p_ledger_id
      AND jjb.period_num     <l_period_year*1000+l_period_num;

    IF(  G_STATEMENT_LEVEL >= g_debug_devel )
    THEN
      put_log( G_MODULE_PREFIX||l_procedure_name||'.prior_period_num'
             , l_prior_period_num);
    END IF;  --(  G_STATEMENT_LEVEL >= g_debug_devel )

    --first time to open period, needn't transfer prior periond end balance
    IF l_prior_period_num IS NOT NULL
    THEN
      SELECT period_name
        INTO l_prior_period_name
        FROM JA_CN_PERIODS jjb
      WHERE jjb.ledger_id=p_ledger_id
        AND jjb.period_num     =l_prior_period_num;

      --transfer prior period end balance the period begin balance
      INSERT INTO ja_cn_account_balances(
                    ledger_id
                  , legal_entity_id
                  , company_segment
                  , period_name
                  , currency_code
                  , cost_center
                  , third_party_type
                  , third_party_id
                  , third_party_number
                  , project_id
                  , project_number
                  , project_source
                  , account_segment
                  , account_type
                  , personnel_id
                  , personnel_number
                  , func_begin_balance_dr
                  , func_begin_balance_cr
                  , orig_begin_balance_dr
                  , Orig_Begin_Balance_Cr
                  , func_period_net_dr
                  , func_period_net_cr
                  , Orig_Period_Net_Dr
                  , Orig_Period_Net_Cr
                  , period_mon
                  , created_by
                  , creation_date
                  , last_updated_by
                  , last_update_date
                  , last_update_login
                  )
           SELECT ledger_id
                , legal_entity_id
                , company_segment
                , p_period_name
                , currency_code
                , cost_center
                , third_party_type
                , third_party_id
                , third_party_number
                , project_id
                , project_number
                , project_source
                , account_segment
                , account_type
                , personnel_id
                , personnel_number
                , func_end_Balance_dr
                , func_end_balance_cr
                , orig_end_balance_dr
                , orig_end_balance_cr
                , 0
                , 0
                , 0
                , 0
                , l_period_month
                , fnd_global.USER_ID
                , SYSDATE
                , fnd_global.USER_ID
                , SYSDATE
                , fnd_global.LOGIN_ID
           FROM ja_cn_account_balances_v a
          WHERE a.ledger_id = p_ledger_id
            AND a.legal_entity_id = p_legal_entity_ID
            AND a.period_name     = l_prior_period_name;

      IF l_first_fiscal_period_flag='Y'
      --transfer the income and expense account to retained earnings account
      THEN
        --set the non-retained earning account balance to zero
        UPDATE ja_cn_account_balances jab
           SET func_begin_balance_dr = 0
             , func_begin_balance_cr = 0
             , orig_begin_balance_dr = 0
             , Orig_Begin_Balance_Cr = 0
         WHERE ledger_id = p_ledger_id
           AND legal_entity_id = p_legal_entity_ID
           AND period_name     = p_period_name
           AND EXISTS(SELECT *
                        FROM FND_FLEX_VALUES ffv
                       WHERE PARENT_FLEX_VALUE_LOW IS NULL
                         AND FLEX_VALUE_SET_ID = l_flex_value_set_id
                         AND ffv.flex_value    = jab.account_segment
                         AND substr(COMPILED_VALUE_ATTRIBUTES,5,1) IN ('R','E')
                     );
/*
         --get retain ccid and base currency code
          SELECT sob.RET_EARN_CODE_COMBINATION_ID
               , sob.currency_code
            INTO l_RET_EARN_CODE_COMBINATION_ID
               , l_ret_currence_code
            FROM gl_ledgers sob
           WHERE sob.ledger_id = p_ledger_id;

            SELECT COUNT(*)
              INTO l_row_count
              FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
                 , gl_ledgers sob
                 , Fnd_Id_Flex_Segments ifs
             WHERE sav.ID_FLEX_CODE           = 'GL#'
               AND sav.APPLICATION_ID         = 101
               AND sav.attribute_value        = 'Y'
               AND sav.ID_FLEX_NUM            = sob.chart_of_accounts_id
               AND ifs.application_id         = 101
               AND ifs.Id_Flex_Code           = 'GL#'
               AND ifs.id_flex_num            = sob.chart_of_accounts_id
               AND ifs.APPLICATION_COLUMN_NAME= sav.APPLICATION_COLUMN_NAME
               AND sob.ledger_id        = p_ledger_id
               AND sav.SEGMENT_ATTRIBUTE_TYPE IN ('FA_COST_CTR','GL_SECONDARY_TRACKING');

           IF l_row_count>=2
           THEN
              l_cost_center_second_tracking := TRUE;
           END IF;

          --get retained earning account segements: company, account, cost center
           SELECT jcc.company_segment
                , jcc.account_segment
                , jcc.cost_segment
                , jcc.project_number
                , jcc.project_id
                , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
             INTO l_ret_company_segment
                , l_ret_account_segment
                , l_ret_cost_center_seg
                , l_ret_project_number
                , l_ret_project_id
                , l_ret_account_type
             FROM ja_cn_code_combination_v jcc
                , FND_FLEX_VALUES ffv
            WHERE jcc.CODE_COMBINATION_ID = l_RET_EARN_CODE_COMBINATION_ID
              AND jcc.ledger_id     = p_ledger_id
              AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
              AND ffv.FLEX_VALUE_SET_ID = l_flex_value_set_id
              AND ffv.flex_value    = jcc.account_segment;

          IF l_cost_center_second_tracking = TRUE
          THEN
            FOR rec_retain_accout1 IN c_retain_account1
            LOOP
              /*BEGIN
                --get retain ccid and its balance
                SELECT sob.RET_EARN_CODE_COMBINATION_ID
                     , gb.begin_balance_dr
                     , gb.begin_balance_cr
                     , gb.begin_balance_dr_beq
                     , gb.begin_balance_cr_beq
                     , gb.currency_code
                  INTO l_RET_EARN_CODE_COMBINATION_ID
                     , l_ret_acct_balance_dr
                     , l_ret_acct_balance_cr
                     , l_ret_acct_balance_dr_beq
                     , l_ret_acct_balance_cr_beq
                     , l_ret_currence_code
                  FROM gl_ledgers sob
                     , gl_balances      gb
                 WHERE sob.ledger_id = p_ledger_id
                   AND sob.ret_earn_code_combination_id = gb.code_combination_id
                   AND gb.ledger_id = p_ledger_id
                   AND gb.period_name     = p_period_name
                   AND gb.actual_flag     = 'A'
                   AND gb.currency_code   = sob.currency_code;

               --get retained earning account segements: company, account, cost center
               SELECT jcc.company_segment
                    , jcc.account_segment
                    , jcc.cost_segment
                    , jcc.project_number
                    , jcc.project_id
                    , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
                 INTO l_ret_company_segment
                    , l_ret_account_segment
                    , l_ret_cost_center_seg
                    , l_ret_project_number
                    , l_ret_project_id
                    , l_ret_account_type
                 FROM ja_cn_code_combination_v jcc
                    , FND_FLEX_VALUES ffv
                WHERE jcc.CODE_COMBINATION_ID = l_RET_EARN_CODE_COMBINATION_ID
                  AND jcc.ledger_id     = p_ledger_id
                  AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
                  AND ffv.FLEX_VALUE_SET_ID = l_flex_value_set_id
                  AND ffv.flex_value    = jcc.account_segment;

               --change the retained earning account balance
               UPDATE ja_cn_account_balances
                  SET func_begin_balance_dr  = l_ret_acct_balance_dr_beq
                    , func_begin_balance_cr  = l_ret_acct_balance_cr_beq
                    , orig_begin_balance_dr  = l_ret_acct_balance_dr
                    , Orig_Begin_Balance_Cr  = l_ret_acct_balance_cr
                    , last_updated_by        = fnd_global.USER_ID
                    , last_update_date       = SYSDATE
                    , last_update_login      = fnd_global.LOGIN_ID
               WHERE ledger_id    = p_ledger_id
                 AND legal_entity_id    = p_legal_entity_ID
                 AND company_segment    = l_ret_company_segment
                 AND period_name        = p_period_name
                 AND currency_code      = l_ret_currence_code
                 AND cost_center        = l_ret_cost_center_seg
        --         AND project_id         = l_ret_project_id
                 AND nvl(project_number,'0')= nvl(l_ret_project_number,'0')
                 AND account_segment    = l_ret_account_segment;

            --first period after EBS run
              IF SQL%ROWCOUNT = 0
              THEN
                 INSERT INTO ja_cn_account_balances(
                               ledger_id
                             , LEGAL_ENTITY_ID
                             , COMPANY_SEGMENT
                             , PERIOD_NAME
                             , CURRENCY_CODE
                             , COST_CENTER
                             , THIRD_PARTY_TYPE
                             , THIRD_PARTY_ID
                             , THIRD_PARTY_NUMBER
                             , PROJECT_ID
                             , PROJECT_NUMBER
                             , PROJECT_SOURCE
                             , ACCOUNT_SEGMENT
                             , account_type
                             , PERSONNEL_ID
                             , PERSONNEL_NUMBER
                             , FUNC_BEGIN_BALANCE_DR
                             , FUNC_BEGIN_BALANCE_CR
                             , ORIG_BEGIN_BALANCE_DR
                             , ORIG_BEGIN_BALANCE_CR
                             , FUNC_PERIOD_NET_DR
                             , FUNC_PERIOD_NET_CR
                             , ORIG_PERIOD_NET_DR
                             , ORIG_PERIOD_NET_CR
                             , PERIOD_MON
                             , CREATED_BY
                             , CREATION_DATE
                             , LAST_UPDATED_BY
                             , LAST_UPDATE_DATE
                             , LAST_UPDATE_LOGIN )
                     VALUES( p_ledger_id
                           , p_legal_entity_ID
                           , l_ret_company_segment
                           , p_period_name
                           , l_ret_currence_code
                           , l_ret_cost_center_seg
                           , NULL
                           , NULL
                           , NULL
                           , l_ret_project_id
                           , l_ret_project_number
                           , 'COA'
                           , l_ret_account_segment
                           , l_ret_account_type
                           , NULL
                           , NULL
                           , l_ret_acct_balance_dr_beq
                           , l_ret_acct_balance_cr_beq
                           , l_ret_acct_balance_dr
                           , l_ret_acct_balance_cr
                           , 0
                           , 0
                           , 0
                           , 0
                           , l_period_month
                           , fnd_global.USER_ID
                           , SYSDATE
                           , fnd_global.USER_ID
                           , SYSDATE
                           , fnd_global.LOGIN_ID);
              END IF;
            EXCEPTION --get retain ccid and its balance
              WHEN NO_DATA_FOUND THEN
                IF(  G_PROC_LEVEL >= g_debug_devel )
                THEN
                  put_log( G_MODULE_PREFIX||l_procedure_name||'.end'
                         ,'The retain earning account is not startup in period '
                         ||p_period_name);
                END IF;  --( G_PROC_LEVEL >= g_debug_devel)

            END; --get retain ccid and its balance
          END LOOP;
        END IF;--l_cost_center_second_tracking = TRUE */
      END IF;--l_first_fiscal_period_flag='Y'
    END IF; --l_prior_period_num IS NULL
  END IF; --l_row_count = 0

  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.end'
                  ,'End procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)
EXCEPTION
  WHEN l_period_wrong THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , 'The input period is invalid.');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;

END open_period;

--==========================================================================
--  PROCEDURE NAME:
--      update_balance                    Private
--
--  DESCRIPTION:
--      	Update CNAO balance table
--
--  PARAMETERS:
--      In: p_balance_rec         	     cnao_balance_rec
--          p_current_period_flag        whether update period is current period
--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    05/24/2006     Jogen Hu          Created
--      04/28/2007     Qingjun Zhao      Change SOB to Ledger for upgrade
--                                       from 11i to R12
--===========================================================================
PROCEDURE update_balance
( p_balance_rec         	IN     cnao_balance_rec
, p_current_period_flag   IN     VARCHAR2
)
IS
l_procedure_name VARCHAR2(20):='update_balance';
BEGIN
  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.begin'
                  ,'Begin procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)

  IF(  G_STATEMENT_LEVEL >= g_debug_devel )
  THEN
    put_log( G_MODULE_PREFIX||l_procedure_name||'.update_balance'
           , p_balance_rec.PERIOD_NAME||':'||p_balance_rec.PERIOD_MON);
  END IF;

  --if the period in parameter is the journal's period
  IF p_current_period_flag='Y'
  THEN
      UPDATE ja_cn_account_balances
         SET FUNC_PERIOD_NET_DR   = FUNC_PERIOD_NET_DR + p_balance_rec.FUNC_PERIOD_NET_DR
           , FUNC_PERIOD_NET_CR   = FUNC_PERIOD_NET_CR + p_balance_rec.FUNC_PERIOD_NET_CR
           , ORIG_PERIOD_NET_DR   = ORIG_PERIOD_NET_DR + p_balance_rec.ORIG_PERIOD_NET_DR
           , ORIG_PERIOD_NET_CR   = ORIG_PERIOD_NET_CR + p_balance_rec.ORIG_PERIOD_NET_CR
           , LAST_UPDATED_BY      = fnd_global.USER_ID
           , LAST_UPDATE_DATE     = SYSDATE
           , LAST_UPDATE_LOGIN    = fnd_global.login_id
      WHERE  ledger_id     = p_balance_rec.ledger_id
        AND  LEGAL_ENTITY_ID     = p_balance_rec.LEGAL_ENTITY_ID
        AND  COMPANY_SEGMENT     = p_balance_rec.COMPANY_SEGMENT
        AND  PERIOD_NAME         = p_balance_rec.PERIOD_NAME
        AND  CURRENCY_CODE       = p_balance_rec.CURRENCY_CODE
        AND  nvl(COST_CENTER,0)  = nvl(p_balance_rec.COST_CENTER,0)
        AND  ACCOUNT_SEGMENT     = p_balance_rec.ACCOUNT_SEGMENT
        AND  nvl(THIRD_PARTY_TYPE  ,0)  = nvl(p_balance_rec.THIRD_PARTY_TYPE  ,0)
        AND  nvl(THIRD_PARTY_ID    ,0)  = nvl(p_balance_rec.THIRD_PARTY_ID    ,0)
        AND  nvl(THIRD_PARTY_NUMBER,0)  = nvl(p_balance_rec.THIRD_PARTY_NUMBER,0)
--        AND  nvl(PROJECT_ID        ,0)  = nvl(p_balance_rec.PROJECT_ID        ,0)
        AND  nvl(PROJECT_NUMBER    ,0)  = nvl(p_balance_rec.PROJECT_NUMBER    ,0)
        AND  nvl(PROJECT_SOURCE    ,0)  = nvl(p_balance_rec.PROJECT_SOURCE    ,0)
        AND  nvl(PERSONNEL_ID      ,0)  = nvl(p_balance_rec.PERSONNEL_ID      ,0)
        AND  nvl(PERSONNEL_NUMBER  ,0)  = nvl(p_balance_rec.PERSONNEL_NUMBER  ,0)
        AND  nvl(PERIOD_MON        ,0)  = nvl(p_balance_rec.PERIOD_MON        ,0);

      --first time balance
      IF SQL%ROWCOUNT = 0
      THEN

        IF(  G_STATEMENT_LEVEL >= g_debug_devel )
        THEN

          put_log( G_MODULE_PREFIX||l_procedure_name||'.update_balance'
                 , p_balance_rec.ledger_id
                 ||':'|| p_balance_rec.LEGAL_ENTITY_ID
                 ||':'|| p_balance_rec.COMPANY_SEGMENT
                 ||':'|| p_balance_rec.PERIOD_NAME
                 ||':'|| p_balance_rec.CURRENCY_CODE
                 ||':'|| p_balance_rec.COST_CENTER
                 ||':'|| p_balance_rec.THIRD_PARTY_TYPE
                 ||':'|| p_balance_rec.THIRD_PARTY_ID
                 ||':'|| p_balance_rec.THIRD_PARTY_NUMBER
                 ||':'|| p_balance_rec.PROJECT_ID
                 ||':'|| p_balance_rec.PROJECT_NUMBER
                 ||':'|| p_balance_rec.PROJECT_SOURCE
                 ||':'|| p_balance_rec.ACCOUNT_SEGMENT
                 ||':'|| p_balance_rec.ACCOUNT_type
                 ||':'|| p_balance_rec.PERSONNEL_ID
                 ||':'|| p_balance_rec.PERSONNEL_NUMBER);
        END IF;

        INSERT INTO ja_cn_account_balances(
           ledger_id
         , LEGAL_ENTITY_ID
         , COMPANY_SEGMENT
         , PERIOD_NAME
         , CURRENCY_CODE
         , COST_CENTER
         , THIRD_PARTY_TYPE
         , THIRD_PARTY_ID
         , THIRD_PARTY_NUMBER
         , PROJECT_ID
         , PROJECT_NUMBER
         , PROJECT_SOURCE
         , ACCOUNT_SEGMENT
         , account_type
         , PERSONNEL_ID
         , PERSONNEL_NUMBER
         , FUNC_BEGIN_BALANCE_DR
         , FUNC_BEGIN_BALANCE_CR
         , ORIG_BEGIN_BALANCE_DR
         , ORIG_BEGIN_BALANCE_CR
         , FUNC_PERIOD_NET_DR
         , FUNC_PERIOD_NET_CR
         , ORIG_PERIOD_NET_DR
         , ORIG_PERIOD_NET_CR
         , PERIOD_MON
         , CREATED_BY
         , CREATION_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
         )
        VALUES
        (  p_balance_rec.ledger_id
         , p_balance_rec.LEGAL_ENTITY_ID
         , p_balance_rec.COMPANY_SEGMENT
         , p_balance_rec.PERIOD_NAME
         , p_balance_rec.CURRENCY_CODE
         , p_balance_rec.COST_CENTER
         , p_balance_rec.THIRD_PARTY_TYPE
         , p_balance_rec.THIRD_PARTY_ID
         , p_balance_rec.THIRD_PARTY_NUMBER
         , p_balance_rec.PROJECT_ID
         , p_balance_rec.PROJECT_NUMBER
         , p_balance_rec.PROJECT_SOURCE
         , p_balance_rec.ACCOUNT_SEGMENT
         , p_balance_rec.ACCOUNT_type
         , p_balance_rec.PERSONNEL_ID
         , p_balance_rec.PERSONNEL_NUMBER
         , 0
         , 0
         , 0
         , 0
         , p_balance_rec.FUNC_PERIOD_NET_DR
         , p_balance_rec.FUNC_PERIOD_NET_CR
         , p_balance_rec.ORIG_PERIOD_NET_DR
         , p_balance_rec.ORIG_PERIOD_NET_CR
         , p_balance_rec.PERIOD_MON
         , fnd_global.USER_ID
         , SYSDATE
         , fnd_global.USER_ID
         , SYSDATE
         , fnd_global.login_id
        );
      END IF; --SQL%ROWCOUNT = 0
  ELSE  --p_current_period_flag='Y'
      UPDATE ja_cn_account_balances
         SET FUNC_begin_BALANCE_DR  = FUNC_begin_BALANCE_DR + p_balance_rec.FUNC_PERIOD_NET_DR
           , FUNC_begin_BALANCE_CR  = FUNC_begin_BALANCE_cR + p_balance_rec.FUNC_PERIOD_NET_CR
           , ORIG_begin_BALANCE_DR  = FUNC_begin_BALANCE_DR + p_balance_rec.ORIG_PERIOD_NET_DR
           , ORIG_begin_BALANCE_CR  = FUNC_begin_BALANCE_cR + p_balance_rec.ORIG_PERIOD_NET_CR
           , LAST_UPDATED_BY      = fnd_global.USER_ID
           , LAST_UPDATE_DATE     = SYSDATE
           , LAST_UPDATE_LOGIN    = fnd_global.login_id
      WHERE  ledger_id     = p_balance_rec.ledger_id
        AND  LEGAL_ENTITY_ID     = p_balance_rec.LEGAL_ENTITY_ID
        AND  COMPANY_SEGMENT     = p_balance_rec.COMPANY_SEGMENT
        AND  PERIOD_NAME         = p_balance_rec.PERIOD_NAME
        AND  CURRENCY_CODE       = p_balance_rec.CURRENCY_CODE
        AND  nvl(COST_CENTER,0)  = nvl(p_balance_rec.COST_CENTER,0)
        AND  ACCOUNT_SEGMENT     = p_balance_rec.ACCOUNT_SEGMENT
        AND  nvl(THIRD_PARTY_TYPE  ,0)  = nvl(p_balance_rec.THIRD_PARTY_TYPE  ,0)
        AND  nvl(THIRD_PARTY_ID    ,0)  = nvl(p_balance_rec.THIRD_PARTY_ID    ,0)
        AND  nvl(THIRD_PARTY_NUMBER,0)  = nvl(p_balance_rec.THIRD_PARTY_NUMBER,0)
--        AND  nvl(PROJECT_ID        ,0)  = nvl(p_balance_rec.PROJECT_ID        ,0)
        AND  nvl(PROJECT_NUMBER    ,0)  = nvl(p_balance_rec.PROJECT_NUMBER    ,0)
        AND  nvl(PROJECT_SOURCE    ,0)  = nvl(p_balance_rec.PROJECT_SOURCE    ,0)
        AND  nvl(PERSONNEL_ID      ,0)  = nvl(p_balance_rec.PERSONNEL_ID      ,0)
        AND  nvl(PERSONNEL_NUMBER  ,0)  = nvl(p_balance_rec.PERSONNEL_NUMBER  ,0)
        AND  nvl(PERIOD_MON        ,0)  = nvl(p_balance_rec.PERIOD_MON        ,0);

      --first time balance
      IF SQL%ROWCOUNT = 0
      THEN

        IF(  G_STATEMENT_LEVEL >= g_debug_devel )
        THEN
          put_log( G_MODULE_PREFIX||l_procedure_name||'.update_balance'
                 , p_balance_rec.ledger_id
                 ||':'|| p_balance_rec.LEGAL_ENTITY_ID
                 ||':'|| p_balance_rec.COMPANY_SEGMENT
                 ||':'|| p_balance_rec.PERIOD_NAME
                 ||':'|| p_balance_rec.CURRENCY_CODE
                 ||':'|| p_balance_rec.COST_CENTER
                 ||':'|| p_balance_rec.THIRD_PARTY_TYPE
                 ||':'|| p_balance_rec.THIRD_PARTY_ID
                 ||':'|| p_balance_rec.THIRD_PARTY_NUMBER
                 ||':'|| p_balance_rec.PROJECT_ID
                 ||':'|| p_balance_rec.PROJECT_NUMBER
                 ||':'|| p_balance_rec.PROJECT_SOURCE
                 ||':'|| p_balance_rec.ACCOUNT_SEGMENT
                 ||':'|| p_balance_rec.ACCOUNT_type
                 ||':'|| p_balance_rec.PERSONNEL_ID
                 ||':'|| p_balance_rec.PERSONNEL_NUMBER);
        END IF;

        INSERT INTO ja_cn_account_balances(
           ledger_id
         , LEGAL_ENTITY_ID
         , COMPANY_SEGMENT
         , PERIOD_NAME
         , CURRENCY_CODE
         , COST_CENTER
         , THIRD_PARTY_TYPE
         , THIRD_PARTY_ID
         , THIRD_PARTY_NUMBER
         , PROJECT_ID
         , PROJECT_NUMBER
         , PROJECT_SOURCE
         , ACCOUNT_SEGMENT
         , account_type
         , PERSONNEL_ID
         , PERSONNEL_NUMBER
         , FUNC_BEGIN_BALANCE_DR
         , FUNC_BEGIN_BALANCE_CR
         , ORIG_BEGIN_BALANCE_DR
         , ORIG_BEGIN_BALANCE_CR
         , FUNC_PERIOD_NET_DR
         , FUNC_PERIOD_NET_CR
         , ORIG_PERIOD_NET_DR
         , ORIG_PERIOD_NET_CR
         , PERIOD_MON
         , CREATED_BY
         , CREATION_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
         )
        VALUES
        (  p_balance_rec.ledger_id
         , p_balance_rec.LEGAL_ENTITY_ID
         , p_balance_rec.COMPANY_SEGMENT
         , p_balance_rec.PERIOD_NAME
         , p_balance_rec.CURRENCY_CODE
         , p_balance_rec.COST_CENTER
         , p_balance_rec.THIRD_PARTY_TYPE
         , p_balance_rec.THIRD_PARTY_ID
         , p_balance_rec.THIRD_PARTY_NUMBER
         , p_balance_rec.PROJECT_ID
         , p_balance_rec.PROJECT_NUMBER
         , p_balance_rec.PROJECT_SOURCE
         , p_balance_rec.ACCOUNT_SEGMENT
         , p_balance_rec.ACCOUNT_type
         , p_balance_rec.PERSONNEL_ID
         , p_balance_rec.PERSONNEL_NUMBER
         , p_balance_rec.FUNC_PERIOD_NET_DR
         , p_balance_rec.FUNC_PERIOD_NET_CR
         , p_balance_rec.ORIG_PERIOD_NET_DR
         , p_balance_rec.ORIG_PERIOD_NET_CR
         , 0
         , 0
         , 0
         , 0
         , p_balance_rec.PERIOD_MON
         , fnd_global.USER_ID
         , SYSDATE
         , fnd_global.USER_ID
         , SYSDATE
         , fnd_global.login_id
        );
      END IF; --SQL%ROWCOUNT = 0
  END IF;--p_current_period_flag='Y'

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
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;
END update_balance;

--==========================================================================
--  PROCEDURE NAME:
--    update_retained_account                     private
--
--  DESCRIPTION:
--      	This procedure update the retained earning account
--
--  PARAMETERS:
--      In: p_period_name          	     the end period name after which
--                                       the CNAO journal should be processed
--          p_ledger_id             Set of book ID
--          p_legal_entity_ID            Legal entity id

--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    02/21/2006     Jogen Hu          Created
--      04/28/2007     Qingjun Zhao      Change SOB to Ledger for upgrade
--                                       from 11i to R12
--===========================================================================
PROCEDURE update_retained_parent_account
( p_period_name          IN        VARCHAR2
, p_ledger_id       IN        NUMBER
, p_legal_entity_ID      IN        NUMBER
)
IS
l_procedure_name         VARCHAR2(30):='update_retained_account';
l_period_year            ja_cn_periods.period_year%TYPE;
--l_period_name            ja_cn_periods.period_name%TYPE;

l_RET_EARN_CODE_COMBINATION_ID gl_ledgers.ret_earn_code_combination_id%TYPE;
l_ret_currence_code    ja_cn_account_balances.currency_code%TYPE;
l_row_count             NUMBER;
l_cost_center_second_tracking BOOLEAN:=FALSE;
l_period_num            ja_cn_periods.period_num%TYPE;
l_last_period_num       ja_cn_periods.period_num%TYPE;
l_flex_value_set_id     FND_FLEX_VALUE_SETS.Flex_Value_Set_Id%TYPE;
i                       NUMBER;

l_number                NUMBER;


BEGIN
  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.begin'
                  ,'Begin procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)

  --------------------------------------------------------
  --get retain ccid and base currency code
  SELECT led.RET_EARN_CODE_COMBINATION_ID
       , led.currency_code
    INTO l_RET_EARN_CODE_COMBINATION_ID
       , l_ret_currence_code
    FROM gl_ledgers led
   WHERE led.ledger_id = p_ledger_id;

    SELECT COUNT(*)
      INTO l_row_count
      FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
         , gl_ledgers led
         , Fnd_Id_Flex_Segments ifs
     WHERE sav.ID_FLEX_CODE           = 'GL#'
       AND sav.APPLICATION_ID         = 101
       AND sav.attribute_value        = 'Y'
       AND sav.ID_FLEX_NUM            = led.chart_of_accounts_id
       AND ifs.application_id         = 101
       AND ifs.Id_Flex_Code           = 'GL#'
       AND ifs.id_flex_num            = led.chart_of_accounts_id
       AND ifs.APPLICATION_COLUMN_NAME= sav.APPLICATION_COLUMN_NAME
       AND led.ledger_id        = p_ledger_id
       AND sav.SEGMENT_ATTRIBUTE_TYPE IN ('FA_COST_CTR','GL_SECONDARY_TRACKING');

   IF l_row_count>=2
   THEN
      l_cost_center_second_tracking := TRUE;
   END IF;

  SELECT period_year
    INTO l_period_year
    FROM ja_cn_periods
   WHERE period_name=p_period_name
     AND ledger_id=p_ledger_id;

  l_period_num:=l_period_year*1000+1;

  SELECT max(period_num)
    INTO l_last_period_num
    FROM ja_cn_periods
   WHERE ledger_id=p_ledger_id;

  SELECT ifs.flex_value_set_id
    INTO l_flex_value_set_id
    FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
       , gl_ledgers led
       , Fnd_Id_Flex_Segments ifs
   WHERE sav.SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
     AND sav.ID_FLEX_CODE           = 'GL#'
     AND sav.APPLICATION_ID         = 101
     AND sav.attribute_value        = 'Y'
     AND sav.ID_FLEX_NUM            = led.chart_of_accounts_id
     AND ifs.application_id         = 101
     AND ifs.Id_Flex_Code           = 'GL#'
     AND ifs.id_flex_num            = led.chart_of_accounts_id
     AND ifs.APPLICATION_COLUMN_NAME= sav.APPLICATION_COLUMN_NAME
     AND led.ledger_id        = p_ledger_id;

  IF l_cost_center_second_tracking
  THEN
     --insert all possible retain account into temp table
     INSERT INTO ja_cn_account_balances_post_gt(
                   ledger_id
                 , LEGAL_ENTITY_ID
                 , COMPANY_SEGMENT
                 , PERIOD_NAME
                 , CURRENCY_CODE
                 , COST_CENTER
                 , THIRD_PARTY_TYPE
                 , THIRD_PARTY_ID
                 , THIRD_PARTY_NUMBER
                 , PROJECT_ID
                 , PROJECT_NUMBER
                 , PROJECT_SOURCE
                 , ACCOUNT_SEGMENT
                 , PERSONNEL_ID
                 , PERSONNEL_NUMBER
                 , FUNC_BEGIN_BALANCE_DR
                 , FUNC_BEGIN_BALANCE_CR
                 , ORIG_BEGIN_BALANCE_DR
                 , ORIG_BEGIN_BALANCE_CR
                 , FUNC_PERIOD_NET_DR
                 , FUNC_PERIOD_NET_CR
                 , ORIG_PERIOD_NET_DR
                 , ORIG_PERIOD_NET_CR
                 , PERIOD_MON
                 , ACCOUNT_TYPE
                 , period_num
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATE_LOGIN
                 )
      SELECT DISTINCT p_ledger_id
           , p_legal_entity_ID
           , jcc.company_segment
           , jcp.period_name
           , l_ret_currence_code
           , jcc.cost_segment
           , NULL
           , NULL
           , NULL
           , jcc.project_id
           , jcc.project_number
           , 'COA'
           , jcc.account_segment
           , NULL
           , NULL
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , jcp.period_num - jcp.period_year*1000
           , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
           , jcp.period_num
           , fnd_global.USER_ID
           , SYSDATE
           , fnd_global.USER_ID
           , SYSDATE
           , fnd_global.LOGIN_ID
       FROM ja_cn_code_combination_v jcc
          , FND_FLEX_VALUES          ffv
          , ja_cn_periods            jcp
      WHERE jcc.ledger_id     = p_ledger_id
        AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
        AND ffv.FLEX_VALUE_SET_ID = l_flex_value_set_id
        AND ffv.flex_value    = jcc.account_segment
        AND jcp.ledger_id=p_ledger_id
        AND jcp.period_num BETWEEN l_period_num AND l_last_period_num
        AND EXISTS((SELECT *
                 FROM ja_cn_code_combination_v jcc1
                WHERE jcc1.CODE_COMBINATION_ID = l_RET_EARN_CODE_COMBINATION_ID
                  AND jcc1.ledger_id     = p_ledger_id
                  AND jcc1.account_segment=jcc.account_segment
                  AND nvl(jcc1.project_id,'0')     =nvl(jcc.project_id     ,'0')
                  AND nvl(jcc1.project_number,'0') =nvl(jcc.project_number,'0') ) );

  ELSE     --l_cost_center_second_tracking = false

       INSERT INTO ja_cn_account_balances_post_gt(
                   ledger_id
                 , LEGAL_ENTITY_ID
                 , COMPANY_SEGMENT
                 , PERIOD_NAME
                 , CURRENCY_CODE
                 , COST_CENTER
                 , THIRD_PARTY_TYPE
                 , THIRD_PARTY_ID
                 , THIRD_PARTY_NUMBER
                 , PROJECT_ID
                 , PROJECT_NUMBER
                 , PROJECT_SOURCE
                 , ACCOUNT_SEGMENT
                 , PERSONNEL_ID
                 , PERSONNEL_NUMBER
                 , FUNC_BEGIN_BALANCE_DR
                 , FUNC_BEGIN_BALANCE_CR
                 , ORIG_BEGIN_BALANCE_DR
                 , ORIG_BEGIN_BALANCE_CR
                 , FUNC_PERIOD_NET_DR
                 , FUNC_PERIOD_NET_CR
                 , ORIG_PERIOD_NET_DR
                 , ORIG_PERIOD_NET_CR
                 , PERIOD_MON
                 , ACCOUNT_TYPE
                 , period_num
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATE_LOGIN  )
      SELECT DISTINCT p_ledger_id
           , p_legal_entity_ID
           , jcc.company_segment
           , jcp.period_name
           , l_ret_currence_code
           , jcc.cost_segment
           , NULL
           , NULL
           , NULL
           , jcc.project_id
           , jcc.project_number
           , 'COA'
           , jcc.account_segment
           , NULL
           , NULL
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , jcp.period_num - jcp.period_year*1000
           , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
           , jcp.period_num
           , fnd_global.USER_ID
           , SYSDATE
           , fnd_global.USER_ID
           , SYSDATE
           , fnd_global.LOGIN_ID
       FROM ja_cn_code_combination_v jcc
          , FND_FLEX_VALUES          ffv
          , ja_cn_periods            jcp
      WHERE jcc.ledger_id     = p_ledger_id
        AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
        AND ffv.FLEX_VALUE_SET_ID = l_flex_value_set_id
        AND ffv.flex_value    = jcc.account_segment
        AND jcp.ledger_id=p_ledger_id
        AND jcp.period_num BETWEEN l_period_num AND l_last_period_num
        AND EXISTS((SELECT *
                 FROM ja_cn_code_combination_v jcc1
                WHERE jcc1.CODE_COMBINATION_ID = l_RET_EARN_CODE_COMBINATION_ID
                  AND jcc1.ledger_id     = p_ledger_id
                  AND jcc1.account_segment=jcc.account_segment
                  AND jcc1.cost_segment   =jcc.cost_segment
                  AND nvl(jcc1.project_id,'0')     =nvl(jcc.project_id     ,'0')
                  AND nvl(jcc1.project_number,'0') =nvl(jcc.project_number,'0') ) );

  END IF;--l_cost_center_second_tracking

  --update the period net occurance DR and CR
  UPDATE ja_cn_account_balances_post_gt u
     SET  (FUNC_PERIOD_NET_DR
         , FUNC_PERIOD_NET_CR
         , ORIG_PERIOD_NET_DR
         , ORIG_PERIOD_NET_CR
         , project_source)=
   (SELECT FUNC_PERIOD_NET_DR
         , FUNC_PERIOD_NET_CR
         , ORIG_PERIOD_NET_DR
         , ORIG_PERIOD_NET_CR
         , project_source
      FROM ja_cn_account_balances
     WHERE ledger_id    = p_ledger_id
       AND period_name        = u.period_name
       AND LEGAL_ENTITY_ID    = p_legal_entity_ID
       AND COMPANY_SEGMENT    = u.company_segment
       AND CURRENCY_CODE      = u.currency_code
       AND nvl(COST_CENTER,0) = nvl(u.cost_center,0)
       AND THIRD_PARTY_TYPE   IS NULL
       AND THIRD_PARTY_ID     IS NULL
       AND THIRD_PARTY_NUMBER IS NULL
       AND nvl(PROJECT_ID,'0')= nvl(u.project_id,'0')
       AND nvl(PROJECT_NUMBER,'0')= nvl(u.project_number,'0')/*
       and nvl(PROJECT_source,' ')=nvl(u.PROJECT_source,'COA')*/
       AND ACCOUNT_SEGMENT    = u.account_segment
       AND PERSONNEL_ID       IS NULL
       AND PERSONNEL_NUMBER   IS NULL
    );

--   INSERT INTO hu_hu SELECT * FROM ja_cn_account_balances_post_gt;

  --update the first priod begin balance in each year
  UPDATE ja_cn_account_balances_post_gt u
     SET ( FUNC_BEGIN_BALANCE_DR
         , FUNC_BEGIN_BALANCE_CR
         , ORIG_BEGIN_BALANCE_DR
         , ORIG_BEGIN_BALANCE_CR)=
         ( SELECT sum(nvl(gb.begin_balance_dr_beq,gb.begin_balance_dr))
                , sum(nvl(gb.begin_balance_cr_beq,gb.begin_balance_cr))
                , sum(gb.begin_balance_dr)
                , sum(gb.begin_balance_cr)
             FROM gl_balances gb
                , ja_cn_code_combination_v jcc
                , ja_cn_code_combination_v jcc1
            WHERE gb.ledger_id     = p_ledger_id
              AND jcc.ledger_id    = p_ledger_id
              AND gb.code_combination_id = jcc.CODE_COMBINATION_ID
              AND jcc.company_segment    = u.company_segment
              AND jcc.account_segment    = u.account_segment
              AND nvl(jcc.cost_segment,0)= nvl(u.cost_center,0)
              AND nvl(jcc.project_number,'0') = nvl(u.project_number,'0')
              AND gb.currency_code       = u.currency_code
              AND gb.period_name         = u.period_name
              AND jcc1.CODE_COMBINATION_ID = l_RET_EARN_CODE_COMBINATION_ID
              AND jcc1.ledger_id    = p_ledger_id
              AND jcc1.company_segment    = jcc.company_segment
              AND jcc1.account_segment    = jcc.account_segment
              AND jcc1.cost_segment       = jcc.cost_segment
              AND jcc1.other_columns      = jcc.other_columns
              AND gb.actual_flag          = 'A'
              )
    WHERE period_mon=1;

   UPDATE ja_cn_account_balances_post_gt u
     SET   FUNC_BEGIN_BALANCE_DR = nvl(FUNC_BEGIN_BALANCE_DR,0)
         , FUNC_BEGIN_BALANCE_CR = nvl(FUNC_BEGIN_BALANCE_CR,0)
         , ORIG_BEGIN_BALANCE_DR = nvl(ORIG_BEGIN_BALANCE_DR,0)
         , ORIG_BEGIN_BALANCE_CR = nvl(ORIG_BEGIN_BALANCE_CR,0)
         , FUNC_PERIOD_NET_DR    = nvl(FUNC_PERIOD_NET_DR   ,0)
         , FUNC_PERIOD_NET_CR    = nvl(FUNC_PERIOD_NET_CR   ,0)
         , ORIG_PERIOD_NET_DR    = nvl(ORIG_PERIOD_NET_DR   ,0)
         , ORIG_PERIOD_NET_CR    = nvl(ORIG_PERIOD_NET_CR   ,0);

    --update the other month balance
    SELECT max(jcp.period_num - l_period_year*1000)
      INTO l_number
      FROM ja_cn_periods jcp;

    FOR i IN 2..l_number
    LOOP
      UPDATE ja_cn_account_balances_post_gt u
        SET (FUNC_BEGIN_BALANCE_DR
           , FUNC_BEGIN_BALANCE_CR
           , ORIG_BEGIN_BALANCE_DR
           , ORIG_BEGIN_BALANCE_CR )=
           (SELECT FUNC_BEGIN_BALANCE_DR + FUNC_PERIOD_NET_DR
                 , FUNC_BEGIN_BALANCE_CR + FUNC_PERIOD_NET_CR
                 , ORIG_BEGIN_BALANCE_DR + ORIG_PERIOD_NET_DR
                 , ORIG_BEGIN_BALANCE_CR + ORIG_PERIOD_NET_CR
              FROM ja_cn_account_balances_post_gt
             WHERE period_num=u.period_num - 1
               AND ledger_id    = p_ledger_id
               AND LEGAL_ENTITY_ID    = p_legal_entity_ID
               AND COMPANY_SEGMENT    = u.company_segment
               AND CURRENCY_CODE      = u.currency_code
               AND nvl(COST_CENTER,0) = nvl(u.cost_center,0)
               AND THIRD_PARTY_TYPE   IS NULL
               AND THIRD_PARTY_ID     IS NULL
               AND THIRD_PARTY_NUMBER IS NULL
               AND nvl(PROJECT_ID     ,'0')    = nvl(u.project_id    ,'0')
               AND nvl(PROJECT_NUMBER ,'0')    = nvl(u.project_number,'0')
               AND ACCOUNT_SEGMENT    = u.account_segment
               AND PERSONNEL_ID       IS NULL
               AND PERSONNEL_NUMBER   IS NULL
           )
       WHERE u.period_mon=i;

     END LOOP;

  -- replace the new balance of retain earning account
  DELETE ja_cn_account_balances u
   WHERE EXISTS
       (SELECT *
       FROM ja_cn_account_balances_post_gt t
      WHERE t.ledger_id    =u.ledger_id
       AND  t.LEGAL_ENTITY_ID    =u.LEGAL_ENTITY_ID
       AND  t.COMPANY_SEGMENT    =u.COMPANY_SEGMENT
       AND  t.CURRENCY_CODE      =u.CURRENCY_CODE
       AND  nvl(t.COST_CENTER,0) =nvl(u.COST_CENTER,0)
       AND  t.ACCOUNT_SEGMENT    =u.ACCOUNT_SEGMENT
       AND  nvl(t.THIRD_PARTY_TYPE  ,'0') =nvl(u.THIRD_PARTY_TYPE  ,'0')
       AND  nvl(t.THIRD_PARTY_ID    ,'0') =nvl(u.THIRD_PARTY_ID    ,'0')
       AND  nvl(t.THIRD_PARTY_NUMBER,'0') =nvl(u.THIRD_PARTY_NUMBER,'0')
       AND  nvl(t.PROJECT_ID        ,'0') =nvl(u.PROJECT_ID        ,'0')
       AND  nvl(t.PROJECT_NUMBER    ,'0') =nvl(u.PROJECT_NUMBER    ,'0')
       AND  nvl(t.PERSONNEL_ID      ,'0') =nvl(u.PERSONNEL_ID      ,'0')
       AND  nvl(t.PERSONNEL_NUMBER  ,'0') =nvl(u.PERSONNEL_NUMBER  ,'0'));

  INSERT INTO ja_cn_account_balances(
                ledger_id
                , LEGAL_ENTITY_ID
                , COMPANY_SEGMENT
                , PERIOD_NAME
                , CURRENCY_CODE
                , COST_CENTER
                , THIRD_PARTY_TYPE
                , THIRD_PARTY_ID
                , THIRD_PARTY_NUMBER
                , PROJECT_ID
                , PROJECT_NUMBER
                , PROJECT_SOURCE
                , ACCOUNT_SEGMENT
                , PERSONNEL_ID
                , PERSONNEL_NUMBER
                , FUNC_BEGIN_BALANCE_DR
                , FUNC_BEGIN_BALANCE_CR
                , ORIG_BEGIN_BALANCE_DR
                , ORIG_BEGIN_BALANCE_CR
                , FUNC_PERIOD_NET_DR
                , FUNC_PERIOD_NET_CR
                , ORIG_PERIOD_NET_DR
                , ORIG_PERIOD_NET_CR
                , PERIOD_MON
                , ACCOUNT_TYPE
                , CREATED_BY
                , CREATION_DATE
                , LAST_UPDATED_BY
                , LAST_UPDATE_DATE
                , LAST_UPDATE_LOGIN
                )
     SELECT     ledger_id
                , LEGAL_ENTITY_ID
                , COMPANY_SEGMENT
                , PERIOD_NAME
                , CURRENCY_CODE
                , COST_CENTER
                , THIRD_PARTY_TYPE
                , THIRD_PARTY_ID
                , THIRD_PARTY_NUMBER
                , PROJECT_ID
                , PROJECT_NUMBER
                , PROJECT_SOURCE
                , ACCOUNT_SEGMENT
                , PERSONNEL_ID
                , PERSONNEL_NUMBER
                , FUNC_BEGIN_BALANCE_DR
                , FUNC_BEGIN_BALANCE_CR
                , ORIG_BEGIN_BALANCE_DR
                , ORIG_BEGIN_BALANCE_CR
                , FUNC_PERIOD_NET_DR
                , FUNC_PERIOD_NET_CR
                , ORIG_PERIOD_NET_DR
                , ORIG_PERIOD_NET_CR
                , PERIOD_MON
                , ACCOUNT_TYPE
                , fnd_global.USER_ID
                , SYSDATE
                , fnd_global.USER_ID
                , SYSDATE
                , fnd_global.LOGIN_ID
       FROM ja_cn_account_balances_post_gt;

 /* -- delete the old parent account balance
  DELETE ja_cn_account_balances jcb
   WHERE jcb.ledger_id = p_ledger_id
     AND jcb.legal_entity_id = p_legal_entity_ID
     AND EXISTS (SELECT jcp.ledger_id
                   FROM ja_cn_periods            jcp
                      , fnd_flex_values          ffv
                  WHERE jcp.period_name=jcb.period_name
                    AND jcp.ledger_id   = p_ledger_id
                    AND jcp.period_num BETWEEN l_period_num AND l_last_period_num
                    AND ffv.flex_value_set_id = l_flex_value_set_id
                    AND ffv.flex_value        = jcb.account_segment
                    AND ffv.summary_flag      = 'Y'
                 );

  -- insert the parent account balance
   INSERT INTO ja_cn_account_balances(
                   ledger_id
                 , LEGAL_ENTITY_ID
                 , COMPANY_SEGMENT
                 , PERIOD_NAME
                 , CURRENCY_CODE
                 , COST_CENTER
                 , THIRD_PARTY_TYPE
                 , THIRD_PARTY_ID
                 , THIRD_PARTY_NUMBER
                 , PROJECT_ID
                 , PROJECT_NUMBER
                 , PROJECT_SOURCE
                 , ACCOUNT_SEGMENT
                 , PERSONNEL_ID
                 , PERSONNEL_NUMBER
                 , FUNC_BEGIN_BALANCE_DR
                 , FUNC_BEGIN_BALANCE_CR
                 , ORIG_BEGIN_BALANCE_DR
                 , ORIG_BEGIN_BALANCE_CR
                 , FUNC_PERIOD_NET_DR
                 , FUNC_PERIOD_NET_CR
                 , ORIG_PERIOD_NET_DR
                 , ORIG_PERIOD_NET_CR
                 , PERIOD_MON
                 , ACCOUNT_TYPE
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATE_LOGIN  )
  SELECT p_ledger_id
       , p_legal_entity_ID
       , jcc.company_segment
       , gb.period_name
       , l_ret_currence_code
       , jcc.cost_segment
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , 'COA'
       , jcc.account_segment
       , NULL
       , NULL
       , SUM(nvl(gb.begin_balance_dr_beq,0))
       , SUM(nvl(gb.begin_balance_cr_beq,0))
       , SUM(nvl(gb.begin_balance_dr,0))
       , SUM(nvl(gb.begin_balance_cr,0))
       , SUM(nvl(gb.period_net_dr_beq,0))
       , SUM(nvl(gb.period_net_cr_beq,0))
       , SUM(nvl(gb.period_net_dr,0))
       , SUM(nvl(gb.period_net_cr,0))
       , gb.period_num
       , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
       , fnd_global.USER_ID
       , SYSDATE
       , fnd_global.USER_ID
       , SYSDATE
       , fnd_global.LOGIN_ID
    FROM gl_balances              gb
       , ja_cn_code_combination_v jcc
       , fnd_flex_values          ffv
   WHERE gb.ledger_id       = p_ledger_id
     AND jcc.ledger_id      = p_ledger_id
     AND gb.code_combination_id   = jcc.CODE_COMBINATION_ID
     AND jcc.account_segment      = ffv.flex_value
     AND ffv.flex_value_set_id    = l_flex_value_set_id
     AND ffv.summary_flag         = 'Y'
     AND gb.actual_flag           = 'Y'
     AND gb.currency_code         = l_ret_currence_code
     AND gb.period_year*1000+gb.period_num BETWEEN l_period_num AND l_last_period_num
   GROUP BY jcc.company_segment
       , gb.period_name
       , l_ret_currence_code
       , jcc.cost_segment
       , jcc.account_segment
       , gb.period_num
       , ffv.COMPILED_VALUE_ATTRIBUTES;*/

  -- delete the old parent account balance
  DELETE ja_cn_account_balances jcb
   WHERE jcb.ledger_id = p_ledger_id
     AND jcb.legal_entity_id = p_legal_entity_ID
     AND EXISTS (SELECT jcp.ledger_id
                   FROM ja_cn_periods            jcp
                      , fnd_flex_values          ffv
                  WHERE jcp.period_name=jcb.period_name
                    AND jcp.ledger_id   = p_ledger_id
                    AND jcp.period_num BETWEEN l_period_num AND l_last_period_num
                    AND ffv.flex_value_set_id = l_flex_value_set_id
                    AND ffv.flex_value        = jcb.account_segment
                    AND ffv.summary_flag      = 'Y'
                 );

  -- generate the account structure to lowest level
  INSERT INTO JA_CN_ACCOUNT_CHILDREN_GT(
          parent_account
        , child_account
        , summary_flag
        , PARENT_TYPE
        )
    SELECT H.PARENT_FLEX_VALUE
         , V.FLEX_VALUE
         , V.SUMMARY_FLAG
         , substr(v2.compiled_value_attributes,5,1)
      FROM FND_FLEX_VALUES               V
         , FND_FLEX_VALUE_NORM_HIERARCHY H
         , FND_FLEX_VALUES               V2
     WHERE v.flex_value_set_id = l_flex_value_set_id
       AND h.flex_value_set_id = l_flex_value_set_id
       AND V.FLEX_VALUE BETWEEN H.CHILD_FLEX_VALUE_LOW AND H.CHILD_FLEX_VALUE_HIGH
       AND ((V.SUMMARY_FLAG = 'Y' AND H.RANGE_ATTRIBUTE = 'P') OR
            (V.SUMMARY_FLAG = 'N' AND H.RANGE_ATTRIBUTE = 'C'))
       AND v2.flex_value_set_id = l_flex_value_set_id
       AND h.PARENT_FLEX_VALUE = v2.FLEX_VALUE;

  i:=0;
  LOOP
     i:=i+1;
     IF i>6
     THEN
        EXIT;
     END IF;

     INSERT INTO JA_CN_ACCOUNT_CHILDREN_GT(
          parent_account
        , child_account
        , summary_flag
        , PARENT_TYPE
        )
     SELECT DISTINCT jca.parent_account
          , v.FLEX_VALUE
          , v.SUMMARY_FLAG
          , jca.parent_type
       FROM JA_CN_ACCOUNT_CHILDREN_GT     jca
          , FND_FLEX_VALUES               v
          , FND_FLEX_VALUE_NORM_HIERARCHY h
      WHERE jca.child_account   = h.parent_flex_value
        AND v.flex_value_set_id = l_flex_value_set_id
        AND h.flex_value_set_id = l_flex_value_set_id
        AND V.FLEX_VALUE BETWEEN H.CHILD_FLEX_VALUE_LOW AND H.CHILD_FLEX_VALUE_HIGH
        AND ((V.SUMMARY_FLAG = 'Y' AND H.RANGE_ATTRIBUTE = 'P') OR
             (V.SUMMARY_FLAG = 'N' AND H.RANGE_ATTRIBUTE = 'C'))
        AND NOT EXISTS(SELECT *
                         FROM JA_CN_ACCOUNT_CHILDREN_GT t
                        WHERE t.parent_account = jca.parent_account
                          AND t.child_account  = v.FLEX_VALUE);

     IF SQL%ROWCOUNT = 0 THEN
        EXIT;
     END IF;

  END LOOP;

  DELETE JA_CN_ACCOUNT_CHILDREN_GT WHERE summary_flag = 'Y';

  --insert the parent account balance
  INSERT INTO ja_cn_account_balances(
                   ledger_id
                 , LEGAL_ENTITY_ID
                 , COMPANY_SEGMENT
                 , PERIOD_NAME
                 , CURRENCY_CODE
                 , COST_CENTER
                 , THIRD_PARTY_TYPE
                 , THIRD_PARTY_ID
                 , THIRD_PARTY_NUMBER
                 , PROJECT_ID
                 , PROJECT_NUMBER
                 , PROJECT_SOURCE
                 , ACCOUNT_SEGMENT
                 , PERSONNEL_ID
                 , PERSONNEL_NUMBER
                 , FUNC_BEGIN_BALANCE_DR
                 , FUNC_BEGIN_BALANCE_CR
                 , ORIG_BEGIN_BALANCE_DR
                 , ORIG_BEGIN_BALANCE_CR
                 , FUNC_PERIOD_NET_DR
                 , FUNC_PERIOD_NET_CR
                 , ORIG_PERIOD_NET_DR
                 , ORIG_PERIOD_NET_CR
                 , PERIOD_MON
                 , ACCOUNT_TYPE
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATE_LOGIN  )
   SELECT p_ledger_id
        , p_legal_entity_ID
        , jcb.company_segment
        , jcb.period_name
        , l_ret_currence_code
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , 'COA'
        , jcc.parent_account
        , NULL
        , NULL
        , SUM(nvl(FUNC_BEGIN_BALANCE_DR,0))
        , SUM(nvl(FUNC_BEGIN_BALANCE_CR,0))
        , SUM(nvl(FUNC_BEGIN_BALANCE_DR,0))
        , SUM(nvl(FUNC_BEGIN_BALANCE_CR,0))
        , SUM(nvl(FUNC_PERIOD_NET_DR,0))
        , SUM(nvl(FUNC_PERIOD_NET_CR,0))
        , SUM(nvl(FUNC_PERIOD_NET_DR,0))
        , SUM(nvl(FUNC_PERIOD_NET_CR,0))
        , jcb.period_mon
        , jcc.parent_type
        , fnd_global.USER_ID
        , SYSDATE
        , fnd_global.USER_ID
        , SYSDATE
        , fnd_global.LOGIN_ID
     FROM ja_cn_account_balances    jcb
        , JA_CN_ACCOUNT_CHILDREN_GT jcc
        , ja_cn_periods             jcp
    WHERE jcc.child_account        = jcb.account_segment
      AND jcp.ledger_id      = p_ledger_id
      AND jcb.legal_entity_id      = p_legal_entity_ID
      AND jcb.ledger_id      = p_ledger_id
      AND jcb.period_name          = jcp.period_name
      AND jcp.period_num BETWEEN l_period_num AND l_last_period_num
    GROUP BY jcb.company_segment
          , jcb.period_name
          , jcc.parent_account
          , jcb.period_mon
          , jcc.parent_type;


/*  --initiate the working area
  DELETE ja_cn_account_balances_post_gt;*/

  --insert all parent account having only non-parent account
 /* INSERT INTO ja_cn_account_balances(
                   ledger_id
                 , LEGAL_ENTITY_ID
                 , COMPANY_SEGMENT
                 , PERIOD_NAME
                 , CURRENCY_CODE
                 , COST_CENTER
                 , THIRD_PARTY_TYPE
                 , THIRD_PARTY_ID
                 , THIRD_PARTY_NUMBER
                 , PROJECT_ID
                 , PROJECT_NUMBER
                 , PROJECT_SOURCE
                 , ACCOUNT_SEGMENT
                 , PERSONNEL_ID
                 , PERSONNEL_NUMBER
                 , FUNC_BEGIN_BALANCE_DR
                 , FUNC_BEGIN_BALANCE_CR
                 , ORIG_BEGIN_BALANCE_DR
                 , ORIG_BEGIN_BALANCE_CR
                 , FUNC_PERIOD_NET_DR
                 , FUNC_PERIOD_NET_CR
                 , ORIG_PERIOD_NET_DR
                 , ORIG_PERIOD_NET_CR
                 , PERIOD_MON
                 , ACCOUNT_TYPE
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATE_LOGIN  )
  SELECT p_ledger_id
       , p_legal_entity_ID
       , jcc.company_segment
       , gb.period_name
       , l_ret_currence_code
       , jcc.cost_segment
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , 'COA'
       , jcc.account_segment
       , NULL
       , NULL
       , SUM(nvl(gb.begin_balance_dr_beq,0))
       , SUM(nvl(gb.begin_balance_cr_beq,0))
       , SUM(nvl(gb.begin_balance_dr,0))
       , SUM(nvl(gb.begin_balance_cr,0))
       , SUM(nvl(gb.period_net_dr_beq,0))
       , SUM(nvl(gb.period_net_cr_beq,0))
       , SUM(nvl(gb.period_net_dr,0))
       , SUM(nvl(gb.period_net_cr,0))
       , gb.period_num
       , substr(ffv.COMPILED_VALUE_ATTRIBUTES,5,1)
       , fnd_global.USER_ID
       , SYSDATE
       , fnd_global.USER_ID
       , SYSDATE
       , fnd_global.LOGIN_ID
   FROM ja_cn_periods             jcp
      , ja_cn_account_balances    jca
      , FND_FLEX_VALUE_CHILDREN_V ffvc
      , fnd_flex_values           ffv
  WHERE jca.account_segment = ffvc.flex_value*/

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
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;
END update_retained_parent_account;

--==========================================================================
--  PROCEDURE NAME:
--    post_journal_itemized                     Public
--
--  DESCRIPTION:
--      	This procedure is used to open a period which had never post
--        journal from "Itemized journal table" to "Itemized balance table"
--
--  PARAMETERS:
--      In: p_period_name          	     the end period name in which
--                                       the CNAO journal should be processed
--          p_ledger_id                  Ledger ID
--          p_legal_entity_ID            Legal entity id

--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    02/21/2006     Jogen Hu          Created
--      04/28/2007     Qingjun Zhao      Change SOB to Ledger for upgrade
--                                       from 11i to R12
--===========================================================================
PROCEDURE post_journal_itemized
( p_period_name          IN        VARCHAR2
, p_ledger_id       IN        NUMBER
, p_legal_entity_ID      IN        NUMBER
)
IS
l_procedure_name         VARCHAR2(30):='post_journal_itemized';
--l_last_open_period_year  ja_cn_periods.period_name%TYPE;
--l_last_open_period       ja_cn_periods.period_name%TYPE;
l_period_year            ja_cn_periods.period_year%TYPE;
l_period_num             ja_cn_periods.period_num%TYPE;
l_flex_value_set_id      FND_FLEX_VALUES.Flex_Value_Set_Id%TYPE;
l_row_count              NUMBER;
l_balance_rec            cnao_balance_rec;

l_earliest_changed_year  ja_cn_periods.period_year%TYPE;
l_earliest_changed_period ja_cn_periods.period_name%TYPE;

CURSOR c_periods(pc_year IN NUMBER
                ,pc_num IN NUMBER) IS
SELECT DISTINCT gp.period_name,gp.period_year,gp.period_num
  FROM /*JA_CN_JOURNAL_LINES jjl
     , */gl_periods          gp
     , gl_ledgers    led
 WHERE /*jjl.ledger_id = p_ledger_id
   AND jjl.legal_entity_id = p_legal_entity_ID
   AND jjl.status          = 'U'
   AND */led.ledger_id = p_ledger_id
   --AND jjl.period_name     = gp.period_name
   AND gp.period_set_name  = led.period_set_name
   AND gp.period_type      = led.accounted_period_type
   AND (gp.period_year<pc_year
        OR (gp.period_year=pc_year AND gp.period_num<=pc_num)
       )
 ORDER BY gp.period_year,gp.period_num;

CURSOR c_journal_lines(pc_flex_value_set_id IN NUMBER
                      ,pc_period_name       IN VARCHAR2) IS
SELECT  jjl.journal_number
      , SUM(nvl(jjl.ENTERED_DR,0))      entered_dr
      , SUM(nvl(jjl.ENTERED_CR,0))      entered_cr
      , SUM(nvl(jjl.ACCOUNTED_DR,0))    accounted_dr
      , SUM(nvl(jjl.ACCOUNTED_CR,0))    accounted_cr
      , jjl.CURRENCY_CODE
      , jjl.CURRENCY_CONVERSION_RATE
      , jjl.COMPANY_SEGMENT
      , jjl.CODE_COMBINATION_ID
      , jjl.COST_CENTER
      , jjl.THIRD_PARTY_ID
      , jjl.THIRD_PARTY_NUMBER
      , jjl.third_party_type
      , jjl.PERSONNEL_ID
      , jjl.PERSONNEL_NUMBER
      , jjl.PROJECT_ID
      , jjl.PROJECT_NUMBER
      , jjl.project_source
      , jjl.ACCOUNT_SEGMENT
      , jjl.period_name
      , substr(COMPILED_VALUE_ATTRIBUTES,5,1) account_type
  FROM JA_CN_JOURNAL_LINES jjl
     , FND_FLEX_VALUES     ffv
 WHERE jjl.ledger_id = p_ledger_id
   AND jjl.legal_entity_id = p_legal_entity_ID
   AND jjl.status          = 'U'
   AND ffv.PARENT_FLEX_VALUE_LOW IS NULL
   AND ffv.FLEX_VALUE_SET_ID=pc_flex_value_set_id
   AND ffv.flex_value       =jjl.account_segment
   AND jjl.period_name      =pc_period_name
 GROUP BY jjl.journal_number
      , jjl.CURRENCY_CODE
      , jjl.CURRENCY_CONVERSION_RATE
      , jjl.COMPANY_SEGMENT
      , jjl.CODE_COMBINATION_ID
      , jjl.COST_CENTER
      , jjl.THIRD_PARTY_ID
      , jjl.THIRD_PARTY_NUMBER
      , jjl.third_party_type
      , jjl.PERSONNEL_ID
      , jjl.PERSONNEL_NUMBER
      , jjl.PROJECT_ID
      , jjl.PROJECT_NUMBER
      , jjl.project_source
      , jjl.ACCOUNT_SEGMENT
      , jjl.period_name
      , COMPILED_VALUE_ATTRIBUTES;

CURSOR c_after_periods(pc_period_num IN NUMBER) IS
SELECT period_name
     , (period_num - period_year*1000) period_month
 FROM ja_cn_periods
WHERE period_num>pc_period_num
  AND ledger_id=p_ledger_id
  AND status='O';

CURSOR c_after_periods_in_year( pc_period_num  IN NUMBER
                              , pc_period_year IN NUMBER) IS
SELECT period_name
     , (period_num - period_year*1000) period_month
 FROM ja_cn_periods
WHERE period_num>pc_period_num
  AND status='O'
  AND period_year=pc_period_year
  AND ledger_id=p_ledger_id;

BEGIN
  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.begin'
                  ,'Begin procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)

  --get period year and num
  SELECT gp.period_year
       , gp.period_num
    INTO l_period_year
       , l_period_num
    FROM gl_periods         gp
       , gl_ledgers   led
   WHERE gp.period_name=p_period_name
     AND gp.period_set_name=led.period_set_name
     AND led.ledger_id=p_ledger_id;

  l_earliest_changed_year:=l_period_year;
  l_earliest_changed_period:=p_period_name;

  IF(  G_STATEMENT_LEVEL >= g_debug_devel )
  THEN
    put_log(G_MODULE_PREFIX||l_procedure_name||'.period year and num'
           ,l_period_year||':'||l_period_num);
  END IF;  --( G_STATEMENT_LEVEL >= g_debug_devel)

  --get the flexfield set ID for chart of account
  SELECT ifs.flex_value_set_id
    INTO l_flex_value_set_id
    FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
       , gl_ledgers             led
       , Fnd_Id_Flex_Segments         ifs
   WHERE sav.SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
     AND sav.ID_FLEX_CODE           = 'GL#'
     AND sav.APPLICATION_ID         = 101
     AND sav.attribute_value        = 'Y'
     AND sav.ID_FLEX_NUM            = led.chart_of_accounts_id
     AND ifs.application_id         = 101
     AND ifs.Id_Flex_Code           = 'GL#'
     AND ifs.id_flex_num            = led.chart_of_accounts_id
     AND ifs.APPLICATION_COLUMN_NAME= sav.APPLICATION_COLUMN_NAME
     AND led.ledger_id        = p_ledger_id;

  IF(  G_STATEMENT_LEVEL >= g_debug_devel )
  THEN
    put_log(G_MODULE_PREFIX||l_procedure_name||'.l_flex_value_set_id'
           ,l_flex_value_set_id);
  END IF;  --( G_STATEMENT_LEVEL >= g_debug_devel)

  FOR rec_period IN c_periods(l_period_year,l_period_num)
  LOOP

    SAVEPOINT each_periods;
        put_log(G_MODULE_PREFIX||l_procedure_name||'.period name'
               ,rec_period.period_name||':'||to_char(SYSDATE,'hh:mi:ss'));
     SELECT COUNT(*)
       INTO l_row_count
       FROM ja_cn_periods
      WHERE period_name=rec_period.period_name
        AND ledger_id=p_ledger_id;

      IF(  G_STATEMENT_LEVEL >= g_debug_devel )
      THEN
        put_log(G_MODULE_PREFIX||l_procedure_name||'.period rowcount'
               ,l_row_count);
      END IF;  --( G_STATEMENT_LEVEL >= g_debug_devel)

     IF l_row_count=0 --current period is processed first time
     THEN
       open_period( p_period_name     => rec_period.period_name
                  , p_ledger_id  => p_ledger_id
                  , p_legal_entity_ID => p_legal_entity_ID
                  );
     END IF;--l_row_count=0

     FOR rec_line IN c_journal_lines(l_flex_value_set_id,rec_period.period_name)
     LOOP

       IF l_earliest_changed_year > rec_period.period_year
       THEN
         l_earliest_changed_year:=rec_period.period_year;
         l_earliest_changed_period:=rec_period.period_name;
       END IF;

       l_balance_rec.ledger_id    := p_ledger_id           ;
       l_balance_rec.LEGAL_ENTITY_ID    := p_legal_entity_ID          ;
       l_balance_rec.COMPANY_SEGMENT    := rec_line.company_segment   ;
       l_balance_rec.PERIOD_NAME        := rec_line.period_name       ;
       l_balance_rec.CURRENCY_CODE      := rec_line.currency_code     ;
       l_balance_rec.COST_CENTER        := rec_line.COST_CENTER       ;
       l_balance_rec.THIRD_PARTY_TYPE   := rec_line.third_party_type  ;
       l_balance_rec.THIRD_PARTY_ID     := rec_line.third_party_id    ;
       l_balance_rec.THIRD_PARTY_NUMBER := rec_line.third_party_number;
       l_balance_rec.PROJECT_ID         := rec_line.project_id        ;
       l_balance_rec.PROJECT_NUMBER     := rec_line.project_number    ;
       l_balance_rec.PROJECT_SOURCE     := rec_line.project_source    ;
       l_balance_rec.ACCOUNT_SEGMENT    := rec_line.account_segment   ;
       l_balance_rec.account_type       := rec_line.account_type      ;
       l_balance_rec.PERSONNEL_ID       := rec_line.personnel_id      ;
       l_balance_rec.PERSONNEL_NUMBER   := rec_line.personnel_number  ;
       l_balance_rec.FUNC_PERIOD_NET_DR := rec_line.accounted_dr      ;
       l_balance_rec.FUNC_PERIOD_NET_CR := rec_line.accounted_cr      ;
       l_balance_rec.ORIG_PERIOD_NET_DR := rec_line.entered_dr        ;
       l_balance_rec.ORIG_PERIOD_NET_CR := rec_line.entered_cr        ;
       l_balance_rec.PERIOD_MON         := rec_period.period_num      ;

       -- the account is retained account
       IF rec_line.account_type IN ('A','L','O')
       THEN
          update_balance( p_balance_rec         => l_balance_rec
                        , p_current_period_flag => 'Y'
                        );

          IF(  G_STATEMENT_LEVEL >= g_debug_devel )
          THEN
            put_log( G_MODULE_PREFIX||l_procedure_name||'.after period'
                   , l_period_year*1000+l_period_num);
          END IF;  --(  G_STATEMENT_LEVEL >= g_debug_devel)

          FOR rec_after_period IN
               c_after_periods(rec_period.period_year*1000+
                              rec_period.period_num)
          LOOP
            l_balance_rec.PERIOD_NAME   := rec_after_period.period_name ;
            l_balance_rec.PERIOD_MON    := rec_after_period.period_month;
            update_balance( p_balance_rec         => l_balance_rec
                          , p_current_period_flag => 'N'
                          );

          END LOOP;

       ELSE  --the account is not-retained earning account
          IF(  G_STATEMENT_LEVEL >= g_debug_devel )
          THEN
            put_log( G_MODULE_PREFIX||l_procedure_name||'.after period in the same year'
                   , l_period_year*1000+l_period_num);
          END IF;  --(  G_STATEMENT_LEVEL >= g_debug_devel)

          update_balance( p_balance_rec         => l_balance_rec
                        , p_current_period_flag => 'Y'
                        );

          FOR rec_after_period_in_year IN
              c_after_periods_in_year(
                         rec_period.period_year*1000+rec_period.period_num
                         ,rec_period.period_year)
          LOOP
            l_balance_rec.PERIOD_NAME   := rec_after_period_in_year.period_name;
            l_balance_rec.PERIOD_MON    := rec_after_period_in_year.period_month;
            update_balance( p_balance_rec         => l_balance_rec
                          , p_current_period_flag => 'N'
                          );

          END LOOP;
       END IF;--rec_line.account_type IN ('R','E')

     END LOOP;

     --update the journal status
     UPDATE ja_cn_journal_lines jl
        SET jl.status='P'
      WHERE jl.ledger_id    = p_ledger_id
        AND jl.LEGAL_ENTITY_ID    = p_legal_entity_ID
        AND jl.PERIOD_NAME        = rec_period.period_name
        AND jl.status             = 'U';

     COMMIT;
--          AND jl.PERSONNEL_NUMBER   = rec_line.personnel_number
  END LOOP;

  update_retained_parent_account
  ( p_period_name     => l_earliest_changed_period
  , p_ledger_id  => p_ledger_id
  , p_legal_entity_ID => p_legal_entity_ID
  );

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
                    , SQLCODE||SQLERRM);
    END IF;
    RAISE;
END post_journal_itemized;

BEGIN
   g_debug_devel:=fnd_log.G_CURRENT_RUNTIME_LEVEL;

END JA_CN_POST_UTILITY_PKG;

/
