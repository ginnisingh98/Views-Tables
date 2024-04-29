--------------------------------------------------------
--  DDL for Package Body FV_ECON_BENF_DISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_ECON_BENF_DISC" AS
-- $Header: FVXAPCHB.pls 120.8.12010000.2 2008/08/04 11:39:13 gnrajago ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_ECON_BENF_DISC.';

FUNCTION EBD_CHECK(x_batch_name IN VARCHAR2,
                   x_invoice_id IN NUMBER,
                   x_check_date IN DATE,
                   x_inv_due_date   IN DATE,
                   x_discount_amount  IN NUMBER,
                   x_discount_date IN DATE) RETURN CHAR AS
  l_module_name VARCHAR2(200) := g_module_name || 'EBD_CHECK';

--MOAC changes
--v_org_id number := to_number(fnd_profile.value('ORG_ID'));

v_include char(1);

BEGIN

	-- --------------------------------------
	-- Just a dummy package body.
	-- Created to be used by FV to implement
	-- economically beneficial discount related details.
	-- ------------------------------------------

--MOAC Changes : removed the org_id parameter that was being passed to the fv_install.enabled
  IF fv_install.enabled THEN
     -- if FV is installed then call the function to determine if
     -- invoice should be included in the payment batch.

     v_include := FV_ECON_BENF_DISC_PVT.EBD_CHECK(x_batch_name,
                                     x_invoice_id,
                                     x_check_date,
                                     x_inv_due_date,
                                     x_discount_amount,
                                     x_discount_date);
     RETURN v_include;
  ELSE
        RETURN 'Y';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      fnd_message.set_token('ERROR',sqlerrm);
      fnd_message.set_token('CALLING_SEQUENCE','FV_ECON_BENF_DISC.EBD_CHECK');
      fnd_message.set_token('PARAMETERS','X_BATCH_NAME = '||x_batch_name||' X_INVOICE_ID = '||to_char(x_invoice_id)||' X_CHECK_DATE = '||to_char(x_check_date,'dd-MM-YYYY')||' X_INV_DUE_DATE = '||to_char(x_inv_due_date,'dd-MON-YYYY'));
      fnd_message.set_token('DEBUG_INFO','FV EBD Code Hook');
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception');

      app_exception.raise_exception;

END EBD_CHECK;


PROCEDURE FV_CALCULATE_INTEREST(x_invoice_id IN NUMBER,
                                x_sys_auto_flg IN VARCHAR2,
                                x_auto_calc_int_flg IN VARCHAR2,
                                x_check_date IN  DATE,
                                x_payment_num NUMBER,
                                x_amount_remaining IN NUMBER,
                                x_discount_taken IN NUMBER,
                                x_discount_available IN NUMBER,
                                x_interest_amount OUT NOCOPY NUMBER) IS
p_set_of_books_id               Gl_Sets_Of_Books.set_of_books_id%TYPE;
l_module_name                   VARCHAR2(2000);
P_interest_tolerance_amount     NUMBER;
C_interest_amount               NUMBER;
l_code				VARCHAR2(30);
l_precision 			NUMBER;
BEGIN
        l_module_name := g_module_name || 'fv_calculate_interest';
  -------------------------------
  -- Set the interest invoice_num
  -------------------------------

FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,'FVCI CODE HOOK');

    -- modifed select below so that it does not fetch multiple rows
    -- joined with ap_invoice_all to get ledger_id and org_id
    -- Bug 5470357
    SELECT nvl(aspa.interest_tolerance_amount,0)
    INTO P_interest_tolerance_amount
    FROM ap_system_parameters_all aspa,
         ap_invoices_all aia
    WHERE aia.invoice_id = x_invoice_id
    AND   aia.set_of_books_id = aspa.set_of_books_id
    AND   aia.org_id = nvl(aspa.org_id, aia.org_id)
    AND   rownum < 2;

   -- comment out statement below. Bug 5470357
  -- p_set_of_books_id := to_number(fnd_profile.value('GL_SET_OF_BKS_ID'));

BEGIN

 SELECT (nvl(x_amount_remaining -
             least(nvl(x_discount_taken, 0), x_discount_available), 0) *
                    power(1 + (annual_interest_rate / (12 * 100)),
                          trunc((least(x_check_date, due_date + 360)
                                 -due_date) / 30)) *
                    (1 + ((annual_interest_rate / (360 * 100)) *
                          mod((least(x_check_date,due_date + 360)
                               -due_date), 30)))) -
            nvl(x_amount_remaining - least(nvl(x_discount_taken, 0),
                                          x_discount_available), 0)
     INTO    C_interest_amount
     FROM    ap_payment_schedules_all, ap_interest_periods
     WHERE   x_sys_auto_flg = 'Y'
     AND     x_auto_calc_int_flg = 'Y'
     AND     trunc(x_check_date) > trunc(due_date)
     AND     payment_num = x_payment_num
     AND     invoice_id = x_invoice_id
     AND     trunc(due_date+1) BETWEEN trunc(start_date) AND trunc(end_date)
     AND     (nvl(x_amount_remaining -
             least(nvl(x_discount_taken, 0), x_discount_available), 0) *
                    power(1 + (annual_interest_rate / (12 * 100)),
                          trunc((least(x_check_date, due_date + 360)
                                 -due_date) / 30)) *
                    (1 + ((annual_interest_rate / (360 * 100)) *
                          mod((least(x_check_date, due_date + 360)
                               -due_date), 30)))) -
        nvl(x_amount_remaining - least(nvl(x_discount_taken, 0),
                                       x_discount_available), 0)
        >= P_interest_tolerance_amount;


Select invoice_currency_code
into l_code
from ap_invoices_all
where invoice_id =x_invoice_id;

select precision
into l_precision
from fnd_currencies
where currency_code =l_code;

      -- Bug 5470357. Without this assignment statement the output would always be NULL
      x_interest_amount := round(C_interest_amount ,l_precision);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 x_interest_amount := NULL;
 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                        l_module_name,'FV Interest Amount is NULL');

 WHEN OTHERS THEN

 fnd_message.set_name('SQLAP','AP_DEBUG');
 fnd_message.set_token('ERROR',sqlerrm);
 fnd_message.set_token('CALLING_SEQUENCE','FV_ECON_BENF_DISC.FV_CALCULATE_INTEREST');
 fnd_message.set_token('PARAMETERS','X_INVOICE_ID = '||x_invoice_id||' X_CHECK_DATE = '||to_char(x_check_date));
 fnd_message.set_token('DEBUG_INFO','FV INTEREST Code Hook');
 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                        l_module_name,'Error in Calculating FV Interest Amount');

 app_exception.raise_exception;
END;

END FV_CALCULATE_INTEREST;


END FV_ECON_BENF_DISC;

/
