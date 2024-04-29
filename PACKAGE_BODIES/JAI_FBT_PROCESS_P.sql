--------------------------------------------------------
--  DDL for Package Body JAI_FBT_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_FBT_PROCESS_P" AS
--$Header: jainfbtprc.plb 120.2.12010000.5 2008/12/31 06:40:37 huhuliu ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_fbt_process_p.plb                                             |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To fetch eligible ap invoices and gl journals for FBT assessment  |
--|     and calculate the tax and insert data into jai_fbt_repository     |
--|     table                                                             |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Fbt_Inv_Process                                        |
--|      PROCEDURE Insert_Fbt_Repository                                  |
--|      PROCEDURE Calculate_Fbt_Amount                                   |
--|      FUNCTION  Check_Inv_Validation                                   |
--|      FUNCTION  Get_Natural_Acc_Seg                                    |
--|      FUNCTION  Get_Balance_Acc_Seg                                    |
--|      FUNCTION  currency_conversion                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     2007/10/11 Kevin Cheng     Created                                |
--|     2008/03/21 Kevin Cheng     bug#6908012                            |
--|                Add legal entity criteria for illegible invoice        |
--|                fetching.                                              |
--|     2008/07/22 Eric Ma         Code change for 11.5 backport          |
--|     2008/07/29 Eric Ma         Code change for 11.5 backport          |
--|     2008/08/11 Xiao Lv         Code change for 11i new changes        |
--|     2008/08/25 Xiao Lv         Fixing bug#7347306, bug#7347401        |
--|                Commented this piece of code in Fbt_Inv_process        |
--|                  UPDATE jai_fbt_repository                            |
--|                     SET settlement_id = NULL                          |
--|                   WHERE legal_entity_id = pn_legal_entity_id          |
--|                     AND period_start_date >= ld_start_date            |
--|                     AND period_end_date <= ld_end_date                |
--|                     AND settlement_id IS NOT NULL;                    |
--|                Commented the benifit_type_code query condition of     |
--|                judging settlement flag                                |
--|     2008/11/06 Xiao Lv         Code change for FBT new changes in R12 |
--|     2008/12/23 Xiao Lv         Fixing bug#7661991                     |
--|     2008/12/26 Xiao Lv         Fixing bug#7670949                     |
--|     2008/12/30  Jia Li         Fixing bug#7675638                     |
--+======================================================================*/

--==========================================================================
--  FUNCTION NAME:
--
--    currency_conversion                       Private
--
--  DESCRIPTION:
--
--    As jai_cmn_utils_pkg.currency_conversion is not available in the IL 11.5
--    This function is added for compalibity with R12 FBT code.
--
--  PARAMETERS:
--      In:  c_set_of_books_id            sob id
--      In:  c_from_currency_code         currency code
--      In:  c_conversion_date            currency conversion date
--      In:  c_conversion_type            currency conversion type
--      In:  c_conversion_rate            currency conversion rate
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           17-JUL-2008   Eric Ma  created


FUNCTION currency_conversion
(
  c_set_of_books_id    IN NUMBER
 ,c_from_currency_code IN VARCHAR2
 ,c_conversion_date    IN DATE
 ,c_conversion_type    IN VARCHAR2
 ,c_conversion_rate    IN NUMBER
) RETURN NUMBER IS
  v_func_curr VARCHAR2(15);
  ret_value   NUMBER;

  CURSOR currency_code_cur IS
    SELECT currency_code
      FROM gl_sets_of_books
     WHERE set_of_books_id = c_set_of_books_id;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'JAI_FBT_PROCESS_P.currency_conversion';

  lv_procedure_name VARCHAR2(40) := 'currency_conversion';
  ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter Function'
                  );

  END IF; --l_proc_level>=l_dbg_level

  -- Bug 5148770. Added by Lakshmi Gopalsami

  --print_log('jai_cmn_utils_pkg.currency_conversion.log',' SOB'|| c_set_of_books_id);

   OPEN currency_code_cur;
  FETCH currency_code_cur
   INTO v_func_curr;
  CLOSE currency_code_cur;

  -- Bug 5148770. Added by Lakshmi Gopalsami

  --print_log('jai_cmn_utils_pkg.currency_conversion.log',' Func curr '|| v_func_curr);
  --print_log('jai_cmn_utils_pkg.currency_conversion.log', 'FROM curr code '|| c_from_currency_code);

  IF NVL(v_func_curr,'NO') = c_from_currency_code
  THEN
    -- Bug 5148770. Added by Lakshmi Gopalsami
    --print_log('jai_cmn_utils_pkg.currency_conversion.log',' func curr and from curr same - return 1');

    ret_value := 1;

  ELSIF upper(c_conversion_type) = 'USER'
  THEN
    -- Bug 5148770. Added by Lakshmi Gopalsami
    --print_log('jai_cmn_utils_pkg.currency_conversion.log',' User entered the rate - return ' || c_conversion_rate);
    ret_value := c_conversion_rate;
  ELSE

    DECLARE

      v_frm_curr VARCHAR2(10) := c_from_currency_code; -- added by Subbu, Sri on 02-NOV-2000

      v_dr_type VARCHAR2(20); -- added by Subbu, Sri on 02-NOV-2000

      -- Cursor for checking currency whether derived from Euro Derived / Euro Currency or not
      -- added by Subbu, Sri on 02-NOV-2000

        CURSOR Chk_Derived_Type_Cur IS
        SELECT Derive_type
          FROM Fnd_Currencies
         WHERE Currency_Code IN (v_frm_curr);
      /*  Bug 5148770. Added by Lakshmi Gopalsami
          Changed the select to get the rate into cursor.
      */
      CURSOR get_curr_rate(p_to_curr IN VARCHAR2, p_from_curr IN VARCHAR2) IS
        SELECT Conversion_Rate
          FROM Gl_Daily_Rates
         WHERE To_Currency = p_to_curr
           AND From_Currency = p_from_curr
           AND trunc(Conversion_Date) = trunc(nvl(c_conversion_date,SYSDATE))
           AND Conversion_Type = c_conversion_type;
    BEGIN

      OPEN Chk_Derived_Type_Cur;
      FETCH Chk_Derived_Type_Cur
        INTO v_dr_type;
      CLOSE Chk_Derived_Type_Cur;

      -- Bug 5148770. Added by Lakshmi Gopalsami
      --print_log('jai_cmn_utils_pkg.currency_conversion.log',' derived type ' || v_dr_type);

      IF v_dr_type IS NULL
      THEN

        -- If currency is not derived from Euro derived / Euro Currency  by Subbu, Sri on 02-NOV-2000
        /* Bug 5148770. Added by Lakshmi Gopalsami
           Removed the select and changed the same into a cursor.
        */
        OPEN  get_curr_rate(v_func_curr,v_frm_curr);
        FETCH get_curr_rate
         INTO ret_value;
        CLOSE get_curr_rate;

        -- Bug 5148770. Added by Lakshmi Gopalsami
        --print_log('jai_cmn_utils_pkg.currency_conversion.log',' derive type null - return value ' || ret_value);ELSE

        IF v_dr_type IN
           ('EMU', 'EURO')
        THEN

          -- If currency is derived from Euro derived / Euro Currency  by Subbu, Sri on 02-NOV-2000

          v_frm_curr := 'EUR';

          /* Bug 5148770. Added by Lakshmi Gopalsami
            Removed the select and changed the same into a cursor.
          */
          OPEN  get_curr_rate(v_func_curr,v_frm_curr);
          FETCH get_curr_rate
           INTO ret_value;
          CLOSE get_curr_rate;

          -- Bug 5148770. Added by Lakshmi Gopalsami
          --print_log('jai_cmn_utils_pkg.currency_conversion.log',' EURO/EMU - derive type  - return value '|| ret_value);
        END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        --old code      ret_value := 1;
        RAISE_APPLICATION_ERROR(-20120,'Currency Conversion Rate Not Defined In The System');
    END;
  END IF;

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter Function'
                  );

  END IF; --l_proc_level>=l_dbg_level

  RETURN(nvl(ret_value,1));

  /* Added by Ramananda for bug#4407165 */
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG',lv_object_name || '. Err:' || SQLERRM);
    app_exception.raise_exception;
END currency_conversion;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Inv_Validation                       Public
--
--  DESCRIPTION:
--
--    This function checks whether the invoice is validate or not
--
--  PARAMETERS:
--      In:  pn_invoice_id            Identifier of ap invoices
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created

FUNCTION Check_Inv_Validation
( pn_invoice_id IN NUMBER
)
RETURN VARCHAR2
IS

lv_val          VARCHAR2(25);

CURSOR check_not_validated_cur
( pn_invoice_id NUMBER
)
IS
SELECT
  SUM( decode(match_status_flag, 'A', 1, 0))
, COUNT(invoice_distribution_id)
FROM
  ap_invoice_distributions_all
WHERE invoice_id = pn_invoice_id;

ln_total_count   NUMBER;
ln_validated_cnt NUMBER;

lv_procedure_name VARCHAR2(40) := 'Check_Inv_Validation';
ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter Function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  OPEN check_not_validated_cur(pn_invoice_id);
  FETCH check_not_validated_cur
  INTO
    ln_total_count
  , ln_validated_cnt;
  CLOSE check_not_validated_cur;

  IF ln_total_count = ln_validated_cnt
  THEN
    lv_val := 'VALIDATED';
  ELSE  --ln_total_count <> ln_validated_cnt
    lv_val := 'UNVALIDATED';
  END IF; --ln_total_count = ln_validated_cnt

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit Function'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)
    RETURN lv_val;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                      || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Check_Inv_Validation;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Natural_Acc_Seg                       Public
--
--  DESCRIPTION:
--
--    This function is used to get the natural account segment value
--
--  PARAMETERS:
--      In:  pv_col_name            Identifier of natural account name
--           pn_ccid                Identifier of code combination id
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created
--           14-NOV-2008   Xiao Lv      modified
--                         Return value type changes to VARCHAR2 from NUMBER

FUNCTION Get_Natural_Acc_Seg
( pv_col_name IN VARCHAR2
, pn_ccid     IN NUMBER
)
RETURN VARCHAR2
IS

--ln_val NUMBER;
lv_val VARCHAR2(25);

lv_procedure_name VARCHAR2(40) := 'Get_Natural_Acc_Seg';
ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter Function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  EXECUTE IMMEDIATE
     'SELECT '
  || pv_col_name
  || ' FROM gl_code_combinations WHERE code_combination_id = :a'
  INTO
    lv_val
  USING
    pn_ccid;

  IF lv_val IS NULL
  THEN
    lv_val := '-999';
  END IF;  --ln_val IS NULL

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit Function'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

  RETURN lv_val;
EXCEPTION
  WHEN no_data_found THEN
    RETURN '-999';
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                      || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Get_Natural_Acc_Seg;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Balance_Acc_Seg                       Public
--
--  DESCRIPTION:
--
--    This function is used to get the balance account segment value
--
--  PARAMETERS:
--      In:  pv_col_name            Identifier of natural account name
--           pn_ccid                Identifier of code combination id
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-AUG-2008   Xiao Lv  created

FUNCTION Get_Balance_Acc_Seg
( pv_col_name IN VARCHAR2
, pn_ccid     IN NUMBER
)
RETURN VARCHAR2
IS

lv_val VARCHAR2(25);

lv_procedure_name VARCHAR2(40) := 'Get_Balance_Acc_Seg';
ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter Function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  EXECUTE IMMEDIATE
     'SELECT '
  || pv_col_name
  || ' FROM gl_code_combinations WHERE code_combination_id = :a'
  INTO
    lv_val
  USING
    pn_ccid;

  IF lv_val IS NULL
  THEN
    lv_val := '-999';
  END IF;  --ln_val IS NULL

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit Function'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

  RETURN lv_val;
EXCEPTION
  WHEN no_data_found THEN
    RETURN '-999';
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                      || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Get_Balance_Acc_Seg;


--==========================================================================
--  PROCEDURE NAME:
--
--    Calculate_Fbt_Amount                       Private
--
--  DESCRIPTION:
--
--    This procedure calculates the various tax amounts which need to be
--    populated in jai_fbt_repository table
--
--  PARAMETERS:
--      In:  pn_legal_entity_id          Identifier of legal entity
--           pv_fringe_benefit_type_code Identifier of FB type code
--           pn_inv_dist_id              Identifier of invoice dist id
--           pn_inv_dist_amt             Identifier of invoice dist amount
--           pv_currency                 Identifier of invoice currency
--           pv_exchange_rate_type       Identifier of exchange rate type
--           pd_exchange_date            Identifier of exchange date
--           pn_source                   Identifier of Source, 'Others' or 'Payables'
--           pn_je_header_id             Identifier of GL JE Header
--           pn_fbt_year                 Identifier of FBT Year
--
--      Out: x_fbt_repository_type       Returns the repository record
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created
--           11-AUG-2008   Xiao Lv      modified for 11i new changes
--           06-NOV-2008   Xiao Lv      modified for R12 new changes
--           23-DEV-2008   Xiao Lv      modified for bug#7661991
--           26-DEV-2008   Xiao Lv      modified for bug#7670949

PROCEDURE Calculate_Fbt_Amount
( pn_legal_entity_id          IN NUMBER
, pv_fringe_benefit_type_code IN VARCHAR2
, pn_inv_dist_id              IN NUMBER
, pn_inv_dist_amt             IN NUMBER
, pv_currency                 IN VARCHAR2
, pv_exchange_rate_type       IN VARCHAR2
, pd_exchange_date            IN DATE
, pn_source                   IN VARCHAR2
, pn_je_header_id             IN NUMBER
, pn_fbt_year                 IN NUMBER
, x_fbt_repository_type       OUT NOCOPY JAI_FBT_REPOSITORY%ROWTYPE
)
IS
CURSOR get_fbt_rates_cur
IS
SELECT DISTINCT
  line.taxable_basis
, head.fbt_rate
, head.surcharge_rate
, head.edu_cess_rate
, head.sh_cess_rate
FROM
  jai_fbt_setup_lines   line
, jai_fbt_setup_headers head
WHERE line.legal_entity_id = pn_legal_entity_id
  AND line.legal_entity_id = head.legal_entity_id
--modified by lvxiao for R12 new changegs on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
  AND head.fbt_year        = pn_fbt_year
-----------------------------------------------------------------------------------
--modified by lvxiao for R12 new changegs on 06-Nov-2008, end
  AND fringe_benefit_type_code = pv_fringe_benefit_type_code;

--modified by lvxiao for upgrade code to R12 on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
CURSOR get_sob_id_cur
IS
SELECT
  ledger_id
FROM
  xle_fp_ou_ledger_v
WHERE legal_entity_id = pn_legal_entity_id;
/*
CURSOR get_sob_id_cur
IS
SELECT
  org_information1
FROM
  HR_ORGANIZATION_INFORMATION
WHERE ORGANIZATION_ID=pn_legal_entity_id
  AND ORG_INFORMATION_CONTEXT ='Legal Entity Accounting';*/
-----------------------------------------------------------------------------------
--modified by lvxiao for upgrade code to R12 on 06-Nov-2008, end

fbt_rates_rec         get_fbt_rates_cur%ROWTYPE;
ln_sob_id             NUMBER;
ln_conv_rate          NUMBER;

lv_procedure_name VARCHAR2(40) := 'Calculate_Fbt_Amount';
ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;
ln_fbt_cum_amt    NUMBER;
ln_precision      NUMBER;

--modified by lvxiao to fix bug#7325653 on 14-August-2008, begin
-----------------------------------------------------------------------------------
ln_exchange_rate   NUMBER := 0;
-----------------------------------------------------------------------------------
--modified by lvxiao to fix bug#7325653 on 14-August-2008, end

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  OPEN get_fbt_rates_cur;
  FETCH get_fbt_rates_cur INTO fbt_rates_rec;
  CLOSE get_fbt_rates_cur;

  OPEN get_sob_id_cur;
  FETCh get_sob_id_cur INTO ln_sob_id;
  CLOSE get_sob_id_cur;

  SELECT
    NVL( fc.precision
       , 2
       ) precision
  INTO
    ln_precision
  FROM
    gl_sets_of_books gsob
  , fnd_currencies   fc
 WHERE gsob.set_of_books_id = fnd_profile.Value('GL_SET_OF_BKS_ID')
   AND gsob.currency_code = fc.currency_code;

  /* this package is called for converting the amounts in SOB currency */

--modified by lvxiao to fix bug#7325653 on 14-August-2008, begin
-----------------------------------------------------------------------------------
    IF upper(pv_exchange_rate_type) = 'USER'
    THEN
       IF pn_source = 'Payables' THEN
         SELECT aia.exchange_rate
           INTO ln_exchange_rate
           FROM AP_INVOICES_ALL              aia
              , Ap_Invoice_Distributions_All aida
          WHERE aida.invoice_distribution_id = pn_inv_dist_id
            AND aida.invoice_id              = aia.invoice_id;
       ELSE --pn_source = 'Others'
         SELECT currency_conversion_rate
           INTO ln_exchange_rate
           FROM gl_je_headers head
          WHERE je_header_id = pn_je_header_id;
       END IF;
    END IF;

/*
  ln_conv_rate := jai_cmn_utils_pkg.currency_conversion( ln_sob_id
                                                       , pv_currency
                                                       , pd_exchange_date
                                                       , pv_exchange_rate_type
                                                       , 1 );
*/
/*  ln_conv_rate := currency_conversion( ln_sob_id
                                      , pv_currency
                                      , pd_exchange_date
                                      , pv_exchange_rate_type
                                      , 1 );
*/
  ln_conv_rate := currency_conversion( ln_sob_id
                                      , pv_currency
                                      , pd_exchange_date
                                      , pv_exchange_rate_type
                                      , ln_exchange_rate );
-----------------------------------------------------------------------------------
--modified by lvxiao to fix bug#7325653 on 14-August-2008, end

--modified by lvxiao to R12 new changes on 06-nov-2008, begin
-----------------------------------------------------------------------------------
  x_fbt_repository_type.converted_amount:= pn_inv_dist_amt * ln_conv_rate;
  x_fbt_repository_type.conversion_rate := ln_conv_rate;
  x_fbt_repository_type.conversion_type := pv_exchange_rate_type;
  x_fbt_repository_type.conversion_date := pd_exchange_date;

  x_fbt_repository_type.taxable_basis
    := fbt_rates_rec.taxable_basis;

  x_fbt_repository_type.fbt_taxable_amount
    := ROUND( x_fbt_repository_type.converted_amount
             *fbt_rates_rec.taxable_basis / 100
            , ln_precision
            );

/*  x_fbt_repository_type.fbt_taxable_amount
    := ROUND( pn_inv_dist_amt*fbt_rates_rec.taxable_basis*ln_conv_rate/100
            , ln_precision
            );            */
-----------------------------------------------------------------------------------
--modified by lvxiao to R12 new changes on 06-nov-2008, end



  x_fbt_repository_type.fbt_tax_amount
    := ROUND( x_fbt_repository_type.fbt_taxable_amount
               * fbt_rates_rec.fbt_rate / 100
            , ln_precision
            );

--modified by Lv Xiao for bug#7661991 on 22-Dec-2008, begin
-----------------------------------------------------------------------------------
/*
  x_fbt_repository_type.fbt_surcharge_amount
    := ROUND( X_FBT_REPOSITORY_TYPE.fbt_tax_amount
               * fbt_rates_rec.surcharge_rate / 100
            , ln_precision
            );

*/
  x_fbt_repository_type.fbt_surcharge_amount
    := ROUND( X_FBT_REPOSITORY_TYPE.fbt_taxable_amount
               * fbt_rates_rec.surcharge_rate / 100
            , ln_precision
            );

-----------------------------------------------------------------------------------
--modified by Lv Xiao for bug#7661991 on 22-Dec-2008, end

  ln_fbt_cum_amt := x_fbt_repository_type.fbt_tax_amount
      + x_fbt_repository_type.fbt_surcharge_amount;

  x_fbt_repository_type.fbt_edu_cess_amount
    := ROUND( ln_fbt_cum_amt * fbt_rates_rec.edu_cess_rate / 100
            , ln_precision
            );
  x_fbt_repository_type.fbt_sh_cess_amount
    := ROUND( ln_fbt_cum_amt * fbt_rates_rec.sh_cess_rate / 100
            , ln_precision
            );
  x_fbt_repository_type.legal_entity_id
    := pn_legal_entity_id;
  x_fbt_repository_type.fringe_benefit_type_code
    := pv_fringe_benefit_type_code;

  SELECT
      currency_code
    INTO
      x_fbt_repository_type.FBT_CURRENCY
    FROM
      gl_sets_of_books
   WHERE set_of_books_id = ln_sob_id;

    IF ( pn_source = 'Payables')
    THEN
        x_fbt_repository_type.invoice_distribution_id
          := pn_inv_dist_id;
        x_fbt_repository_type.distribution_amt
          := pn_inv_dist_amt;
        x_fbt_repository_type.invoice_currency_code
          := pv_currency;

        --set invoice_date as ap_invoice_distributions_all.accounting_date.
        SELECT aida.accounting_date
          INTO x_fbt_repository_type.invoice_date
          FROM ap_invoice_distributions_all aida
         WHERE aida.invoice_distribution_id = pn_inv_dist_id;

        SELECT invoice_num
          INTO x_fbt_repository_type.je_name
          FROM ap_invoices_all aia
             , ap_invoice_distributions_all aida
         WHERE invoice_distribution_id = pn_inv_dist_id
           AND aia.invoice_id = aida.invoice_id;

--modified by Lv Xiao for bug#7670949 on 26-Dec-2008, begin
-----------------------------------------------------------------------------------
--get invoice line number according to the distribution id
        SELECT aida.invoice_line_number
        --aida.distribution_line_number
          INTO x_fbt_repository_type.JE_LINE_NUM
          FROM ap_invoice_distributions_all aida
         WHERE aida.invoice_distribution_id = pn_inv_dist_id;
-----------------------------------------------------------------------------------
--modified by Lv Xiao for bug#7670949 on 26-Dec-2008, end

    END IF; -- (pn_source = 'Payables')

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                    || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Calculate_Fbt_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Fbt_Repository                       Private
--
--  DESCRIPTION:
--
--    This procedure insert one record into table jai_fbt_repository
--
--  PARAMETERS:
--      In:  p_fbt_repository          Identifier of record containing
--                                       fbt repository information
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created
--           11-AUG-2008   Xiao Lv      modified for 11i new changes
--           14-NOV-2008   Xiao Lv      modified for R12 new changes

PROCEDURE Insert_Fbt_Repository
( p_fbt_repository IN JAI_FBT_REPOSITORY%ROWTYPE
)
IS
ln_fbt_trans_id    NUMBER;
lv_procedure_name  VARCHAR2(40) := 'Insert_Fbt_Repository';
ln_dbg_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level      NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  SELECT Jai_Fbt_Repository_s.NEXTVAL
    INTO ln_fbt_trans_id
    FROM dual;

  INSERT INTO JAI_FBT_REPOSITORY
              ( FBT_TRANSACTION_ID
              , LEGAL_ENTITY_ID
              , PERIOD_START_DATE
              , PERIOD_END_DATE

              , SOURCE
              , JE_HEADER_ID
              , BATCH_NAME
              , JE_SOURCE
              , JE_NAME
              , PERIOD_NAME
              , JE_LINE_NUM

              , INVOICE_DISTRIBUTION_ID
              , INVOICE_DATE
              , INVOICE_CURRENCY_CODE
              , DISTRIBUTION_AMT
              , DIST_CODE_COMBINATION_ID
              , DIST_NATURAL_ACCOUNT_VALUE
              , DIST_BALANCE_ACCOUNT_VALUE

              , FRINGE_BENEFIT_TYPE_CODE
              , FBT_CURRENCY
              , TAXABLE_BASIS
              , FBT_TAXABLE_AMOUNT
              , FBT_TAX_AMOUNT
              , FBT_SURCHARGE_AMOUNT
              , FBT_EDU_CESS_AMOUNT
              , FBT_SH_CESS_AMOUNT
              , MANUAL_FLAG
--modified by lvxiao for R12 new changes on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
              , CONVERSION_RATE
              , CONVERTED_AMOUNT
              , CONVERSION_TYPE
              , CONVERSION_DATE
              , MODIFIED_FLAG
-----------------------------------------------------------------------------------
--modified by lvxiao for R12 new changes on 06-Nov-2008, end
              , CREATION_DATE
              , CREATED_BY
              , LAST_UPDATE_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_LOGIN
              )
  VALUES      ( ln_fbt_trans_id
              , P_FBT_REPOSITORY.LEGAL_ENTITY_ID
              , P_FBT_REPOSITORY.PERIOD_START_DATE
              , P_FBT_REPOSITORY.PERIOD_END_DATE

              , P_FBT_REPOSITORY.SOURCE
              , P_FBT_REPOSITORY.JE_HEADER_ID
              , P_FBT_REPOSITORY.BATCH_NAME
              , P_FBT_REPOSITORY.JE_SOURCE
              , P_FBT_REPOSITORY.JE_NAME
              , P_FBT_REPOSITORY.PERIOD_NAME
              , P_FBT_REPOSITORY.JE_LINE_NUM

              , P_FBT_REPOSITORY.INVOICE_DISTRIBUTION_ID
              , P_FBT_REPOSITORY.INVOICE_DATE
              , P_FBT_REPOSITORY.INVOICE_CURRENCY_CODE
              , P_FBT_REPOSITORY.DISTRIBUTION_AMT
              , P_FBT_REPOSITORY.DIST_CODE_COMBINATION_ID
              , P_FBT_REPOSITORY.DIST_NATURAL_ACCOUNT_VALUE
              , P_FBT_REPOSITORY.DIST_BALANCE_ACCOUNT_VALUE

              , P_FBT_REPOSITORY.FRINGE_BENEFIT_TYPE_CODE
              , P_FBT_REPOSITORY.FBT_CURRENCY
              , P_FBT_REPOSITORY.TAXABLE_BASIS
              , P_FBT_REPOSITORY.FBT_TAXABLE_AMOUNT
              , P_FBT_REPOSITORY.FBT_TAX_AMOUNT
              , P_FBT_REPOSITORY.FBT_SURCHARGE_AMOUNT
              , P_FBT_REPOSITORY.FBT_EDU_CESS_AMOUNT
              , P_FBT_REPOSITORY.FBT_SH_CESS_AMOUNT
              , 'N'        -- indicate manual transactions
--modified by lvxiao for R12 new changes on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
              , P_FBT_REPOSITORY.CONVERSION_RATE
              , P_FBT_REPOSITORY.CONVERTED_AMOUNT
              , P_FBT_REPOSITORY.CONVERSION_TYPE
              , P_FBT_REPOSITORY.CONVERSION_DATE
              , 0          -- indicate no modification transactions
-----------------------------------------------------------------------------------
--modified by lvxiao for R12 new changes on 06-Nov-2008, end
              , SYSDATE
              , fnd_global.user_id
              , SYSDATE
              , fnd_global.user_id
              , fnd_global.login_id
              );

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                    || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Insert_Fbt_Repository;

--==========================================================================
--  PROCEDURE NAME:
--
--    Fbt_Inv_Process                       Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program to check eligible invoices, calculate FBT taxes and insert
--    data into jai_fbt_repository table
--
--  PARAMETERS:
--      In:  pn_legal_entity_id          Identifier of legal entity
--           pv_start_date               Identifier of period start date
--           pv_end_date                 Identifier of period end date
--           pv_fringe_benefit_type_code Identifier of FB type code
--           pv_generate_return          Identifier of supplier id
--
--      Out: pv_errbuf           Returns the error if concurrent program
--                               does not execute completely
--           pv_retcode          Returns success or failure
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           11-OCT-2007   Kevin Cheng  created
--           21-MAR-2008   Kevin Cheng  bug#6908012
--                         Add legal entity criteria for illegible invoice
--                         fetching.
--           29-Jul-2008   Eric commented out code in the cursor get_eligible_invoices_cur
--                         to leave the invoice case of accrue_on_receipt_flag ='Y' to GL module
--           11-Aug-2008   Lv Xiao      modified for 11i new changes.
--           25-Aug-2008   Lv Xiao      fix bug#7347306 and bug#7347401.
--           06-Nov-2008   Lv Xiao      modified for FBT R12 new changes.
--           30-Dec-2008   Li Jia       fix bug#7675638

PROCEDURE Fbt_Inv_Process
( pv_errbuf                   OUT NOCOPY VARCHAR2
, pv_retcode                  OUT NOCOPY VARCHAR2
, pn_legal_entity_id          IN  NUMBER
, pn_fbt_year                 IN  NUMBER
, pv_start_date               IN  VARCHAR2
, pv_end_date                 IN  VARCHAR2
, pv_fringe_benefit_type_code IN  VARCHAR2
)
IS

ld_start_date             DATE;
ld_end_date               DATE;

-- Deleted by Jia for bug#7675638 on 30-Nov-2008, Begin
--------------------------------------------------------------
/*
\* fetch all the operating nits within the LE *\
--modified by lvxiao for upgrade code to R12 from 11i on 06-Nov-2008,begin
-----------------------------------------------------------------------------------

CURSOR GET_OPERATING_UNIT_CUR IS
SELECT
  OPERATING_UNIT_ID
FROM
  XLE_FP_OU_LEDGER_V
WHERE LEGAL_ENTITY_ID = pn_legal_entity_id;

\*
CURSOR GET_OPERATING_UNIT_CUR
IS
SELECT
  organization_id operating_unit_id
FROM
  hr_organization_information
WHERE org_information2 = pn_legal_entity_id  --LEGAL ENTITY ID
  AND ORG_INFORMATION_CONTEXT='Operating Unit Information';
*\
----------------------------------------------------------------------------------
--modified by lvxiao for upgrade code to R12 from 11i on 06-Nov-2008,end
*/
--------------------------------------------------------------
-- Deleted by Jia for bug#7675638 on 30-Nov-2008, End


/* chart_of_accounts_id related with SOB which is attached to an LE */
CURSOR get_chart_of_accounts_id_cur IS
SELECT
  chart_of_accounts_id
FROM
  gl_sets_of_books
WHERE
  set_of_books_id = fnd_profile.Value('GL_SET_OF_BKS_ID');

-- get the natural account segment
CURSOR get_natural_account_col_cur
( pn_coa NUMBER
)
IS
SELECT
  application_column_name
FROM
  FND_SEGMENT_ATTRIBUTE_VALUES
WHERE application_id = 101
  AND id_flex_code ='GL#'
  AND segment_attribute_type = 'GL_ACCOUNT'
  AND id_flex_num = pn_coa
  AND attribute_value = 'Y';

-- get the balance account segment
CURSOR get_balance_account_col_cur
( pn_coa NUMBER
)
IS
SELECT
  application_column_name
FROM
  FND_SEGMENT_ATTRIBUTE_VALUES
WHERE application_id = 101
  AND id_flex_code ='GL#'
  AND segment_attribute_type = 'GL_BALANCING'
  AND id_flex_num = pn_coa
  AND attribute_value = 'Y';

/* cursor to select all the eligible invoices exclude manual modified transactions in JAI_FBT_REPOSITORY
The invoice to be eligible for FBT should meet the following criteria
  1) invoice should be of type
     ('STANDARD','DEBIT', 'CREDIT', 'EXPENSE REPORT','MIXED')
  2) invoice should be validated invoice
  3) only non-recoverable tax lines are eligible for FBT
  4) match the criteria entered by the user in CP parameters form
  5) do not re-fetch transactions that have been modified in JAI_FBT_REPOSITORY
*/
-- this clause gets all the matched invoices with non-recoverable tax lines
CURSOR get_eligible_invoices_cur
( pv_nat_acc_seg    VARCHAR2
, pv_bal_acc_seg    VARCHAR2
-- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
----------------------------------------------------------
--, pn_operating_unit NUMBER
, pn_legal_entity_id NUMBER
----------------------------------------------------------
-- Modified by Jia for bug#7675638 on 30-Dec-2008, End
, pn_fbt_year       NUMBER
)
IS
SELECT
  Get_Natural_Acc_Seg( pv_nat_acc_seg
                     , /*commented out the below section for FBT 11.5 backport by Eric Ma on 29-July-2008
                         decode( NVL(accrue_on_receipt_flag, 'N')
                             , 'N'
                             , det.DIST_CODE_COMBINATION_ID
                             , 'Y'
                             , po.code_combination_id
                             )
                       */
                       det.DIST_CODE_COMBINATION_ID
                     ) nat_acct_seg
, Get_Balance_Acc_Seg( pv_bal_acc_seg
                     , det.DIST_CODE_COMBINATION_id
                     ) bal_acct_seg
, det.amount
, det.dist_match_type
, det.invoice_distribution_id
, det.dist_code_combination_id
, head.invoice_currency_code
, head.exchange_rate_type
, head.exchange_rate
, head.exchange_date
FROM
  ap_invoices_all head
, ap_invoice_distributions_all det
, po_distributions_all po
WHERE head.invoice_id = det.invoice_id
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
  --------------------------------------------------------------
  --AND head.org_id = pn_operating_unit
  AND head.legal_entity_id = pn_legal_entity_id
  --------------------------------------------------------------
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, End

  AND det.po_distribution_id = po.po_distribution_id
  AND invoice_type_lookup_code IN ( 'STANDARD'
                                  , 'DEBIT'
                                  , 'CREDIT'
                                  , 'EXPENSE REPORT'
                                  ,'MIXED'
                                  )
  AND Check_Inv_Validation( head.invoice_id
                          ) = 'VALIDATED'
  AND (det.dist_match_type IN ( 'ITEM_TO_PO'
                              , 'ITEM_TO_RECEIPT'
                              )
--modified by lvxiao for upgrade code for new changes to R12 from 11i on 06-Nov-2008, begin
-------------------------------------------------------------------------------------------
      OR EXISTS (SELECT 1
                   FROM jai_ap_match_inv_taxes       jamit
                      , ap_invoice_distributions_all aida1
                  WHERE jamit.invoice_distribution_id
                        = det.invoice_distribution_id
                    AND jamit.parent_invoice_distribution_id
                        = aida1.invoice_distribution_id
                    AND aida1.dist_match_type IN ('ITEM_TO_PO'
                                                , 'ITEM_TO_RECEIPT'
                                                )
/*                     ja_in_ap_tax_distributions   jiatd
                   , ap_invoice_distributions_all aida1
                 WHERE jiatd.invoice_id
                       = det.invoice_id
                   AND jiatd.distribution_line_number
                       = det.distribution_line_number
                   AND jiatd.parent_invoice_distribution_id
                       = aida1.invoice_distribution_id       */
                )
      )
  AND det.accounting_date BETWEEN ld_start_date AND ld_end_date
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
  --------------------------------------------------------------
  --AND det.org_id = pn_operating_unit
  AND det.org_id = head.org_id
  --------------------------------------------------------------
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
  AND det.invoice_distribution_id IN ( SELECT
                                         aida.invoice_distribution_id
                                       FROM
                                         AP_INVOICE_DISTRIBUTIONS_ALL AIDA
                                       WHERE aida.invoice_id = head.invoice_id
                                         AND NOT EXISTS
                                           ( SELECT 1
                                               FROM JAI_AP_MATCH_INV_TAXES JAMIT
                                              WHERE JAMIT.INVOICE_DISTRIBUTION_ID
                                                   = AIDA.INVOICE_DISTRIBUTION_ID
                                                AND RECOVERABLE_FLAG = 'Y'
 /*                                              ja_in_ap_tax_distributions   jiatdi
                                             WHERE jiatdi.invoice_id
                                                   = AIDA.invoice_id
                                               AND jiatdi.distribution_line_number
                                                   = AIDA.distribution_line_number */
                                           )
                                     )
/* following code excludes the manual modified transactions in JAI_FBT_REPOSITORY
   this is for FBT R12 new change
*/
  AND NOT EXISTS
      ( SELECT 1
          FROM JAI_FBT_REPOSITORY jfr
         WHERE jfr.invoice_distribution_id
             = det.invoice_distribution_id
       )
-------------------------------------------------------------------------------------------
--modified by lvxiao for upgrade code for new changes to R12 from 11i on 06-Nov-2008, end

  AND ( ( NVL(accrue_on_receipt_flag, 'N') = 'N'
          AND Get_Natural_Acc_Seg( pv_nat_acc_seg
                                 , det.DIST_CODE_COMBINATION_id
                                 ) IN ( SELECT NATURAL_ACCOUNT_VALUE
                                          FROM jai_fbt_setup_lines
                                         WHERE legal_entity_id = pn_legal_entity_id
                                           AND fbt_year = pn_fbt_year
                                           AND FRINGE_BENEFIT_TYPE_CODE
                                              = NVL(pv_fringe_benefit_type_code
                                                  , FRINGE_BENEFIT_TYPE_CODE)
                                      )
        )
      )

UNION

-- this clause gets all the unmatched invoices
SELECT
  Get_Natural_Acc_Seg( pv_nat_acc_seg
                     , det.DIST_CODE_COMBINATION_id
                     ) nat_acct_seg
, Get_Balance_Acc_Seg( pv_bal_acc_seg
                     , det.DIST_CODE_COMBINATION_id
                     ) bal_acct_seg
, det.amount
, det.dist_match_type
, det.invoice_distribution_id
, det.dist_code_combination_id
, head.invoice_currency_code
, head.exchange_rate_type
, head.exchange_rate
, head.exchange_date
FROM
  ap_invoices_all head
, ap_invoice_distributions_all det
WHERE head.invoice_id = det.invoice_id
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
  --------------------------------------------------------------
  --AND head.org_id = pn_operating_unit
  AND head.legal_entity_id = pn_legal_entity_id
  --------------------------------------------------------------
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, End

  AND invoice_type_lookup_code IN ( 'STANDARD'
                                  , 'DEBIT'
                                  , 'CREDIT'
                                  , 'EXPENSE REPORT'
                                  , 'MIXED'
                                  )
  AND Check_Inv_Validation( head.invoice_id
                          ) = 'VALIDATED'
  AND (det.dist_match_type IS NULL
         OR det.dist_match_type NOT IN ( 'ITEM_TO_PO'
                                       , 'ITEM_TO_RECEIPT'
                                       )
      )
--modified by lvxiao for upgrade code for new changes to R12 from 11i on 06-Nov-2008, begin
-------------------------------------------------------------------------------------------
  AND NOT EXISTS ( SELECT 1
                     FROM jai_ap_match_inv_taxes jamit
                    WHERE jamit.invoice_distribution_id
                          = det.invoice_distribution_id
/*                     ja_in_ap_tax_distributions   jiatd
                   WHERE jiatd.invoice_id
                         = det.invoice_id
                     AND jiatd.distribution_line_number
                         = det.distribution_line_number      */
                 )

------------------------------------------------------------------------------------------
--modified by lvxiao for upgrade code for new changes to R12 from 11i on 06-Nov-2008, end

/* following code excludes the manual modified transactions in JAI_FBT_REPOSITORY
   this is for FBT R12 new change
*/
  AND NOT EXISTS
      ( SELECT 1
          FROM JAI_FBT_REPOSITORY jfr
         WHERE jfr.invoice_distribution_id
             = det.invoice_distribution_id
       )
  AND det.accounting_date BETWEEN ld_start_date AND ld_end_date
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
  --------------------------------------------------------------
  --AND det.org_id = pn_operating_unit
  AND det.org_id = head.org_id
  --------------------------------------------------------------
  -- Modified by Jia for bug#7675638 on 30-Dec-2008, End
  AND Get_Natural_Acc_Seg( pv_nat_acc_seg
                         , det.DIST_CODE_COMBINATION_id
                         ) IN (  SELECT
                                  NATURAL_ACCOUNT_VALUE
                                FROM
                                  jai_fbt_setup_lines
                                WHERE legal_entity_id = pn_legal_entity_id
                                  AND fbt_year = pn_fbt_year
                                  AND FRINGE_BENEFIT_TYPE_CODE =
                                    NVL( pv_fringe_benefit_type_code
                                       , FRINGE_BENEFIT_TYPE_CODE
                                       )
                              );


/* cursor to select all the eligible journals from GL exclude manual modified journals in JAI_FBT_REPOSITORY
The invoice to be eligible for FBT should meet the following criteria
  1) all journal entries should be considered for FBT process excluding the
     following source:('Payables')
  2) only posted journals are considered
  3) only journal entries with matched nature account are considered
  4) match the criteria entered by the user in CP parameters form
  5) do not re-fetch journals that have been modified in JAI_FBT_REPOSITORY
*/

CURSOR get_eligible_journals_cur
( pv_nat_acc_seg    VARCHAR2,
  pv_bal_acc_seg    VARCHAR2,
  pn_fbt_year       NUMBER
)
IS

SELECT /* Rowid(head)
           Index(head,GL_JE_HEADERS_U1)
           Index(batch,GL_JE_BATCHES_U1)
           */

       Get_Natural_Acc_Seg(PV_NAT_ACC_SEG
                   , LINE.CODE_COMBINATION_ID)      NAT_ACCT_SEG,
       Get_Balance_Acc_Seg(PV_BAL_ACC_SEG
                   , LINE.CODE_COMBINATION_ID)      BAL_ACCT_SEG,
       (NVL(LINE.ENTERED_DR, 0)
       -NVL(LINE.ENTERED_CR, 0))                    DISTRIBUTION_AMT,
       LINE.JE_LINE_NUM                             JE_LINE_NUM,
       LINE.CODE_COMBINATION_ID                     JE_LINE_CCID,
       HEAD.JE_HEADER_ID                            JE_HEADER_ID,
       BATCH.NAME                                   JE_BATCH_NAME,
       HEAD.JE_SOURCE                               JE_SOURCE,
       HEAD.NAME                                    JE_NAME,
       HEAD.PERIOD_NAME                             PERIOD_NAME,
       LINE.EFFECTIVE_DATE                          JE_LINE_EFFECTIVE_DATE,
       HEAD.CURRENCY_CODE                           CURRENCY_CODE,
       HEAD.CURRENCY_CONVERSION_TYPE,
       HEAD.CURRENCY_CONVERSION_RATE,
       HEAD.CURRENCY_CONVERSION_DATE

FROM
  gl_je_headers head
, gl_je_lines line
, gl_je_batches batch
WHERE line.effective_date >= ld_start_date
  AND line.effective_date <= ld_end_date
  AND line.STATUS = 'P'
  AND head.je_source <> 'Payables'
  AND head.JE_HEADER_ID = line.JE_HEADER_ID
  AND head.JE_BATCH_ID = batch.JE_BATCH_ID
  AND Get_Natural_Acc_Seg( pv_nat_acc_seg
                         , line.CODE_COMBINATION_ID
                         ) IN (  SELECT NATURAL_ACCOUNT_VALUE
                                   FROM jai_fbt_setup_lines
                                  WHERE legal_entity_id = pn_legal_entity_id
                                    AND fbt_year = pn_fbt_year
                                    AND FRINGE_BENEFIT_TYPE_CODE =
                                      NVL( pv_fringe_benefit_type_code
                                         , FRINGE_BENEFIT_TYPE_CODE
                                         )
                               )
--modified by lvxiao for upgrade code to R12 on 06-Nov-2008,begin
-----------------------------------------------------------------------------------
  AND Get_Balance_Acc_Seg( pv_bal_acc_seg
                         , line.CODE_COMBINATION_ID
                         ) IN (  SELECT segment_value
                                   FROM GL_LEDGER_NORM_SEG_VALS
                                  WHERE legal_entity_id = pn_legal_entity_id
                                    AND SEGMENT_TYPE_CODE = 'B'
                               )
-----------------------------------------------------------------------------------
--modified by lvxiao for upgrade code to R12 on 06-Nov-2008,end

--Following code excludes manual modified journals in JAI_FBT_REPOSITORY
  AND NOT EXISTS
          ( SELECT 1
              FROM JAI_FBT_REPOSITORY jfr
             WHERE jfr.je_header_id  = head.JE_HEADER_ID
               AND jfr.je_line_num   = line.JE_LINE_NUM
               AND head.je_header_id = line.je_header_id
  );


/* cursor to check whether the returned ccid has the fbt benefit type
   attached to it
*/
CURSOR get_benefit_type_cur
( pn_nat_account NUMBER
)
IS
SELECT
  fringe_benefit_type_code
FROM
  jai_fbt_setup_lines
WHERE natural_account_value = pn_nat_account
  AND legal_entity_id = pn_legal_entity_id
--modified by lvxiao for R12 new change on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
  AND fbt_year = pn_fbt_year;
-----------------------------------------------------------------------------------
--modified by lvxiao for R12 new change on 06-Nov-2008, end
ln_coa_id                 NUMBER;
lv_nat_acc_seg_name       VARCHAR2(30);
ln_nat_acct               NUMBER;
ln_dist_ccid              NUMBER;

lv_bal_acct               VARCHAR2(15);
lv_bal_acc_seg_name       VARCHAR2(30);
ln_settlement_id          NUMBER(15);
lv_source                 VARCHAR2(30);

ld_period_end_date        DATE;

lv_fringe_ben_type_code   JAI_FBT_SETUP_HEADERS.BUSINESS_TYPE_CODE%TYPE;

fbt_repository_rec        jai_fbt_repository%ROWTYPE;

lv_procedure_name         VARCHAR2(40) := 'Fbt_Inv_Process';
ln_dbg_level              NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level             NUMBER := FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

-- the source date format like '2007/06/01 00:00:00', format it to standard format
  ld_start_date := TRUNC(fnd_date.canonical_to_date (pv_start_date));
  ld_end_date   := TRUNC(fnd_date.canonical_to_date (pv_end_date));

--  ld_start_date       := TO_DATE(pv_start_date, GV_DATE_MASK);
--  ld_end_date         := TO_DATE(pv_end_date, GV_DATE_MASK);

  DELETE
  FROM
    jai_fbt_repository
  WHERE legal_entity_id = pn_legal_entity_id
--modified by lvxiao for R12 new change on 06-Nov-2008, begin
-----------------------------------------------------------------------------------
    AND invoice_date >= ld_start_date
    AND invoice_date <= ld_end_date
/*        AND period_start_date >= ld_start_date
        AND period_end_date <= ld_end_date*/
    AND fringe_benefit_type_code = NVL( pv_fringe_benefit_type_code
                                      , FRINGE_BENEFIT_TYPE_CODE
                                      )
    AND (manual_flag IS NULL OR manual_flag = 'N')      -- not manual transactions
    AND (modified_flag IS NULL OR modified_flag = 0 );  -- transactions not been modified.
-----------------------------------------------------------------------------------
--modified by lvxiao for R12 new change on 06-Nov-2008, end

       OPEN get_chart_of_accounts_id_cur;
      FETCH get_chart_of_accounts_id_cur
       INTO ln_coa_id;
      CLOSE get_chart_of_accounts_id_cur;

       OPEN get_natural_account_col_cur(ln_coa_id);
      FETCH get_natural_account_col_cur
       INTO lv_nat_acc_seg_name;
      CLOSE get_natural_account_col_cur;


       OPEN get_balance_account_col_cur(ln_coa_id);
      FETCH get_balance_account_col_cur
       INTO lv_bal_acc_seg_name;
      CLOSE get_balance_account_col_cur;

-- Removed by Jia for bug#6775638 on 30-Dec-2008, Begin
----------------------------------------------------------------
/*      FOR operating_unit_rec IN get_operating_unit_cur
      LOOP
*/
----------------------------------------------------------------
-- Removed by Jia for bug#6775638 on 30-Dec-2008, End
        FOR eligible_invoices_rec IN
          get_eligible_invoices_cur( lv_nat_acc_seg_name
                                   , lv_bal_acc_seg_name
                                   -- Modified by Jia for bug#7675638 on 30-Dec-2008, Begin
                                   ----------------------------------------------------------
                                   --, operating_unit_rec.operating_unit_id
                                   , pn_legal_entity_id
                                   ----------------------------------------------------------
                                   -- Modified by Jia for bug#7675638 on 30-Dec-2008, End
                                   , pn_fbt_year
                                   )
        LOOP

              ln_nat_acct  := eligible_invoices_rec.nat_acct_seg;
              lv_bal_acct  := eligible_invoices_rec.bal_acct_seg;
              ln_dist_ccid := eligible_invoices_rec.dist_code_combination_id;

              lv_source                        := 'Payables';

           OPEN get_benefit_type_cur(ln_nat_acct);
          FETCH get_benefit_type_cur
           INTO lv_fringe_ben_type_code;

          IF get_benefit_type_cur%FOUND THEN
            Calculate_Fbt_Amount( pn_legal_entity_id
                                , lv_fringe_ben_type_code
                                , eligible_invoices_rec.invoice_distribution_id
                                , eligible_invoices_rec.amount
                                , eligible_invoices_rec.invoice_currency_code
                                , eligible_invoices_rec.exchange_rate_type
                                , eligible_invoices_rec.exchange_date
                                , lv_source
                                , NULL
                                , pn_fbt_year
                                , fbt_repository_rec
                                );
          END IF;  --get_benefit_type_cur%FOUND
          CLOSE get_benefit_type_cur;

          fbt_repository_rec.source        := 'Payables';
          fbt_repository_rec.settlement_id := ln_settlement_id;

          fbt_repository_rec.PERIOD_START_DATE          := ld_start_date;
          fbt_repository_rec.PERIOD_END_DATE            := ld_end_date;
          fbt_repository_rec.dist_code_combination_id   := ln_dist_ccid;
          fbt_repository_rec.dist_natural_account_value := ln_nat_acct;
          fbt_repository_rec.dist_balance_account_value := lv_bal_acct;

          /* put all the required values  in the record type for insertion
             into jai_fbt_repository table
          */
          INSERT_FBT_REPOSITORY( fbt_repository_rec
                               );
        END LOOP;  -- eligible_invoices_rec IN get_eligible_invoices_cur

      -- Removed by Jia for bug#7675638 on 30-Dec-2008, Begin
      ----------------------------------------------------------
      --END LOOP;  -- operating_unit_rec IN get_operating_unit_cur
      -----------------------------------------------------------
      -- Removed by Jia for bug#7675638 on 30-Dec-2008, End


--get journals and import into FBT repository on 28-July-2008,begin
-----------------------------------------------------------------------------------
      FOR eligible_journals IN
        get_eligible_journals_cur( lv_nat_acc_seg_name
                                   , lv_bal_acc_seg_name
                                   , pn_fbt_year
                                   )
      LOOP
          ln_nat_acct    := eligible_journals.nat_acct_seg;
          lv_bal_acct    := eligible_journals.bal_acct_seg;

          lv_source                       := 'Others';

           OPEN get_benefit_type_cur(ln_nat_acct);
          FETCH get_benefit_type_cur
           INTO lv_fringe_ben_type_code;

          IF get_benefit_type_cur%FOUND THEN
            Calculate_Fbt_Amount( pn_legal_entity_id
                                , lv_fringe_ben_type_code
                                , eligible_journals.je_line_ccid
                                , eligible_journals.distribution_amt
                                , eligible_journals.currency_code
                                , eligible_journals.CURRENCY_CONVERSION_TYPE
                                , eligible_journals.CURRENCY_CONVERSION_DATE
                                , lv_source
                                , eligible_journals.je_header_id
                                , pn_fbt_year
                                , fbt_repository_rec
                                );

          END IF;  --get_benefit_type_cur%FOUND
          CLOSE get_benefit_type_cur;

          fbt_repository_rec.source       := 'Others'; -- Indicate journals from GL
          fbt_repository_rec.je_header_id := eligible_journals.je_header_id;
          fbt_repository_rec.batch_name   := eligible_journals.je_batch_name;
          fbt_repository_rec.je_source    := eligible_journals.je_source;
          fbt_repository_rec.je_name      := eligible_journals.je_name;
          fbt_repository_rec.period_name  := eligible_journals.period_name;
          fbt_repository_rec.je_line_num  := eligible_journals.je_line_num;

          fbt_repository_rec.invoice_date             := eligible_journals.je_line_effective_date;
          fbt_repository_rec.invoice_currency_code    := eligible_journals.currency_code;
          fbt_repository_rec.distribution_amt         := eligible_journals.distribution_amt;
          fbt_repository_rec.dist_code_combination_id := eligible_journals.je_line_ccid;
          fbt_repository_rec.settlement_id            := ln_settlement_id;

          fbt_repository_rec.dist_natural_account_value := ln_nat_acct;
          fbt_repository_rec.dist_balance_account_value := lv_bal_acct;

          fbt_repository_rec.PERIOD_START_DATE          := ld_start_date;
          fbt_repository_rec.PERIOD_END_DATE            := ld_end_date;

          /* put all the required values  in the record type for insertion
             into jai_fbt_repository table
          */
          INSERT_FBT_REPOSITORY( fbt_repository_rec
                               );
        END LOOP;  -- eligible_journals IN get_eligible_journals_cur


 -----------------------------------------------------------------------------------
--get journals and import into FBT repository on 28-July-2008,end


--update processing date in JAI_FBT_PROCESS_DATE for R12 new change on 06-Nov-2008, begin
-----------------------------------------------------------------------------------------
  BEGIN
    SELECT period_end_date
      INTO ld_period_end_date
      FROM jai_fbt_process_date
     WHERE legal_entity_id = pn_legal_entity_id
       AND fbt_year        = pn_fbt_year;

    IF (ld_end_date >= ld_period_end_date) THEN
       UPDATE jai_fbt_process_date
          SET period_end_date = ld_end_date
        WHERE legal_entity_id = pn_legal_entity_id
          AND fbt_year        = pn_fbt_year;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    INSERT
      INTO JAI_FBT_PROCESS_DATE(LEGAL_ENTITY_ID,
                                FBT_YEAR,
                                PERIOD_START_DATE,
                                PERIOD_END_DATE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN)
                         VALUES(pn_legal_entity_id,
                                pn_fbt_year,
                                ld_start_date,
                                ld_end_date,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                FND_GLOBAL.LOGIN_ID);

   END;
-----------------------------------------------------------------------------------------
--update processing date in JAI_FBT_PROCESS_DATE for R12 new change on 06-Nov-2008, end

   COMMIT;


  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    pv_errbuf :=SQLERRM;
    pv_retcode:=2;
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                    || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Fbt_Inv_Process;

END JAI_FBT_PROCESS_P; --END OF PACKAGE



/
