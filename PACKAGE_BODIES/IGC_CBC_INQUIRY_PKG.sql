--------------------------------------------------------
--  DDL for Package Body IGC_CBC_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_INQUIRY_PKG" AS
/* $Header: IGCINQRB.pls 120.2.12000000.1 2007/08/20 12:15:23 mbremkum ship $ */

g_period_name         gl_periods.period_name%TYPE;
g_period_year         gl_periods.period_year%TYPE;
g_quarter_num         gl_periods.quarter_num%TYPE;
g_period_num          gl_periods.period_num%TYPE;
g_gl_budget_version_id      gl_budget_versions.budget_version_id%TYPE;
g_true VARCHAR2(1);
g_false VARCHAR2(1);

g_amount_type VARCHAR2(4);

--PJTD
--PTD
--QTD
--YTD

PROCEDURE Initialize
(
  p_amount_type         IN    VARCHAR2,
  p_period_cutoff       IN    gl_periods.period_name%TYPE,
  p_set_of_books_id     IN    gl_period_statuses.set_of_books_id%TYPE,
  p_gl_budget_version_id IN   gl_budget_versions.budget_version_id%TYPE
) IS

l_gl_application_id    fnd_application.application_id%TYPE;

CURSOR c_gl_periods IS
  SELECT period_name,
         period_num,
         quarter_num,
         period_year
    FROM gl_period_statuses
   WHERE set_of_books_id = p_set_of_books_id
     AND period_name     = p_period_cutoff
     AND application_id  = l_gl_application_id;

BEGIN

-- --------------------------------------------------------------------
-- Obtain the application ID that will be used throughout this process.
-- --------------------------------------------------------------------
   SELECT application_id
     INTO l_gl_application_id
     FROM fnd_application
    WHERE application_short_name = 'SQLGL';

  OPEN c_gl_periods;
  FETCH c_gl_periods INTO g_period_name,g_period_num,g_quarter_num,g_period_year;

  IF c_gl_periods%NOTFOUND THEN
      CLOSE c_gl_periods;
      raise NO_DATA_FOUND;
  END IF;

  CLOSE c_gl_periods;
  g_amount_type:=p_amount_type;
  g_gl_budget_version_id:=p_gl_budget_version_id;
  g_true  :='T';
  g_false :='F';

END Initialize;


FUNCTION Check_Amount_Type
  (p_period_name          IN gl_periods.period_name%TYPE,
   p_period_year          IN gl_periods.period_year%TYPE,
   p_quarter_num          IN gl_periods.quarter_num%TYPE,
   p_period_num           IN gl_periods.period_num%TYPE,
   p_actual_flag          IN igc_cbc_je_lines.actual_flag%TYPE,
   p_gl_budget_version_id IN  gl_budget_versions.budget_version_id%TYPE
   )  RETURN VARCHAR2
   IS
 l_ret_status VARCHAR2(1) :=g_false;
BEGIN

  IF (NVL(p_gl_budget_version_id,0)  <> g_gl_budget_version_id  OR g_gl_budget_version_id IS NULL)
     AND p_actual_flag='B' THEN
    RETURN g_false;
  END IF;

  IF  (      g_amount_type='PJTD'
         AND p_period_year <= g_period_year
         AND p_quarter_num <= g_quarter_num
         AND p_period_num  <= g_period_num
      )
    OR
      (      g_amount_type='PTD'
         AND p_period_year =  g_period_year
         AND p_quarter_num =  g_quarter_num
         AND p_period_num  =  g_period_num
      )
    OR
      (      g_amount_type='QTD'
         AND p_period_year  = g_period_year
         AND p_quarter_num  = g_quarter_num
         AND p_period_num  <= g_period_num
      )
    OR
      (      g_amount_type='YTD'
         AND p_period_year  = g_period_year
         AND p_quarter_num <= g_quarter_num
         AND p_period_num  <= g_period_num
      )
    THEN

    l_ret_status:=g_true;

  END IF;

  return l_ret_status;

END Check_Amount_Type;


FUNCTION  Get_Amount_Type RETURN VARCHAR2
IS
BEGIN
 return g_amount_type;
END Get_Amount_type;

FUNCTION  Get_Period_Name RETURN VARCHAR2
IS
BEGIN
 return g_period_name;
END Get_Period_Name;

FUNCTION Get_FC_Balances(
  p_mode       IN  VARCHAR2,
  p_dccid      IN  igc_cbc_je_lines.code_combination_id%TYPE,   -- Detail CCID
  p_sob_id     IN  igc_cbc_je_lines.set_of_books_id%TYPE,   -- Set of Books ID
  p_budget_ver IN  igc_cbc_je_lines.budget_version_id%TYPE, -- Budget ID
  p_period_yr  IN  igc_cbc_je_lines.period_year%TYPE,  -- Period year, ie 2000
  p_period_nm  IN  igc_cbc_je_lines.period_num%TYPE,  -- Period number
  p_quarter_nm IN  igc_cbc_je_lines.quarter_num%TYPE, -- Quarter number (1-4)
  p_batch_id   IN  igc_cbc_je_lines.cbc_je_batch_id%TYPE,
  p_actual_flg IN  igc_cbc_je_lines.actual_flag%TYPE, --- 'B' or 'E'
  p_enc_type_id IN igc_cbc_je_lines.encumbrance_type_id%TYPE, -- 1000 or 1082
  p_line_num   IN  igc_cbc_je_lines.cbc_je_line_num%TYPE
		     )
RETURN NUMBER IS

  -- Local variables
  l_budget_bal    NUMBER;
  l_commit_bal    NUMBER;
  l_actual_bal    NUMBER;
  l_funds_avail   NUMBER DEFAULT 0;
  l_return_bal    NUMBER DEFAULT 0;

  l_api_name      CONSTANT VARCHAR2(30)  := 'Get_FC_Balances';

  -- Remove this once the function has been integrated into the package
  G_PKG_NAME      CONSTANT VARCHAR2(30)  := 'IGCBEFCB';
BEGIN

  -- Budget balance with amount_type of year-to-date ('YTD')
  IF(p_actual_flg = 'B') and (p_mode = 'ytd_balance') THEN

    -- Total the debit balance of the budget from PSB
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO  l_budget_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'B'                    -- 'B' for Budget
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.set_of_books_id = p_sob_id
    and   JE.status = 'P'                      --Permanent
    and   JE.period_num <= p_period_nm
    and   JE.budget_version_id = p_budget_ver;

  l_return_bal := l_budget_bal;

  END IF;


  -- Budget balance with amount_type of quarter-to-date ('QTD')
  IF(p_actual_flg = 'B') and (p_mode = 'qtd_balance') THEN

    -- Total the debit balance of the budget from PSB
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO  l_budget_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'B'                    -- 'B' for Budget
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.set_of_books_id = p_sob_id
    and   JE.status = 'P'                      --Permanent
    and   JE.quarter_num = p_quarter_nm
    and   JE.period_num <= p_period_nm
    and   JE.budget_version_id = p_budget_ver;

  l_return_bal := l_budget_bal;

  END IF;

  -- Budget balance with amount_type of period-to-date ('PTD')
  IF(p_actual_flg = 'B') and (p_mode = 'ptd_balance') THEN

    -- Total the debit balance of the budget from PSB
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO  l_budget_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'B'                    -- 'B' for Budget
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.set_of_books_id = p_sob_id
    and   JE.status = 'P'                      --Permanent status
    and   JE.period_num = p_period_nm
    and   JE.budget_version_id = p_budget_ver;

  l_return_bal := l_budget_bal;

  END IF;


  -- Encumbrance balance with amount_type of period_to_date ('PTD')
  IF(p_actual_flg = 'E') and (p_mode = 'ptd_balance') THEN

    -- Total the debit balance from the provisional contract commitments
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO l_commit_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'E'
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.encumbrance_type_id = p_enc_type_id
    and   JE.set_of_books_id = p_sob_id
    and   JE.period_num = p_period_nm;

  l_return_bal := l_commit_bal;

  END IF;


  -- Encumbrance balance with amount_type of quarter_to_date ('QTD')
  IF(p_actual_flg = 'E') and (p_mode = 'qtd_balance') THEN

    -- Total the debit balance from the provisional contract commitments
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO l_commit_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'E'
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.encumbrance_type_id = p_enc_type_id
    and   JE.set_of_books_id = p_sob_id
    and   JE.quarter_num = p_quarter_nm
    and   JE.period_num <= p_period_nm;

    l_return_bal := l_commit_bal;

  END IF;


  -- Encumbrance balance with amount_type of year_to_date ('YTD')
  IF(p_actual_flg = 'E') and (p_mode = 'ytd_balance') THEN

    -- Total the debit balance from the provisional contract commitments
    SELECT nvl(sum(entered_dr),0)  - nvl(sum(entered_cr),0)
    INTO l_commit_bal
    FROM  igc_cbc_je_lines  JE
    WHERE JE.actual_flag = 'E'
    and   JE.code_combination_id = p_dccid
    and   JE.period_year = p_period_yr
    and   JE.encumbrance_type_id = p_enc_type_id
    and   JE.set_of_books_id = p_sob_id
    and   JE.period_num <= p_period_nm;

  l_return_bal := l_commit_bal;

  END IF;


  -- Return balance
  return(l_return_bal);


-- Return a debit balance of 0 in the case of an error
EXCEPTION

  WHEN NO_DATA_FOUND THEN
    l_return_bal := 0;
    return(l_return_bal);


END Get_FC_Balances;

END IGC_CBC_INQUIRY_PKG;

/
