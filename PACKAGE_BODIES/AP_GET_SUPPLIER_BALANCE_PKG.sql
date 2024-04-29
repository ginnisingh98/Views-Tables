--------------------------------------------------------
--  DDL for Package Body AP_GET_SUPPLIER_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_GET_SUPPLIER_BALANCE_PKG" as
/* $Header: apxsoblb.pls 120.14.12010000.4 2009/11/21 09:32:50 ctetala ship $ */

Procedure AP_GET_SUPPLIER_BALANCE( p_request_id in number
                                ,p_set_of_books_id number
                                ,p_as_of_date in date
                               ,p_supplier_name_from in varchar2
                               ,p_supplier_name_to in varchar2
                               ,p_currency in varchar2
                               ,p_min_invoice_balance in number
                               ,p_min_open_balance in number
                               ,p_include_prepayments in varchar2
                               ,p_reference_number in varchar2
                               ,p_debug_flag in  varchar2
                               ,p_trace_flag in varchar2
                                ) is


l_total_inv_balance ap_invoices.invoice_amount%TYPE;
l_discount_avail ap_invoices.invoice_amount%TYPE;
l_tot_discount_avail ap_invoices.invoice_amount%TYPE;
l_amount_remaining ap_invoices.invoice_amount%TYPE;
l_functional_currency_code ap_invoices.invoice_currency_code%TYPE;
l_open_balance ap_invoices.invoice_amount%TYPE;
l_total_prepayment ap_invoices.invoice_amount%TYPE;
l_session_language varchar2(40);/* For MLS changes */
l_base_language varchar2(40); /*For MLS  changes*/
l_inv_balance ap_invoices.invoice_amount%TYPE;
--l_start_date ap_invoices.invoice_date%TYPE;
l_organization_name hr_organization_units.name%TYPE;
l_sum_discount NUMBER; -- 3641604
l_paid_amount NUMBER; -- 2901541
--The cursor vendorinfo holds all the information about the vendor and vendor site

CURSOR vendorinfo(p_base_language po_vendor_sites_all.language%TYPE,
               p_session_language po_vendor_sites_all.language%TYPE ) is
SELECT
pv.vendor_id,
pv.vendor_name supplier_name,
pv.segment1 supplier_number,
pv.num_1099 tax_payer_id,
pv.vat_code vat_registration_number,
pvs.vendor_site_code supplier_site_code,
pvs.vendor_site_id,
pvs.address_line1,
pvs.address_line2,
pvs.address_line3,
pvs.city,
pvs.state,
pvs.zip postal_code,
pvs.province,
pvs.country
FROM
ap_suppliers pv ,
ap_supplier_sites_all pvs
WHERE
upper(pv.vendor_name) between upper(nvl(p_supplier_name_from,'A'))
and upper(nvl(p_supplier_name_to,'Z'))
and pvs.vendor_id = pv.vendor_id
and nvl(pvs.language,p_base_language)=p_session_language;

/*--Cusrsor start date holds the Start date for a period

CURSOR  Start_date(p_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE) IS
SELECT gp.start_date
 FROM  gl_period_types gpt,gl_periods gp,
 gl_period_sets gps,gl_sets_of_books sob
 WHERE
 sob.set_of_books_id=p_set_of_books_id
 and sob.period_set_name=gps.period_set_name
 and sob.accounted_period_type=gpt.period_type
 and gp.period_set_name=gps.period_set_name
 and gp.period_type=gpt.period_type
 and p_as_of_date BETWEEN  gp.start_date and gp.end_date;*/

--Cursor invinfo holds data about invoices for the parameters entered

--Bug 2431936 changed 'prepay' to 'PREPAY'

CURSOR  invinfo(p_vendor_id ap_invoices.vendor_id%TYPE,
               p_vendor_site_id ap_invoices.vendor_site_id%TYPE,
               p_currency ap_invoices.invoice_currency_code%TYPE) is
SELECT
ai.invoice_id,
ai.payment_cross_rate,
-- 3641604  aps.payment_num,
lkv.meaning trans_type,
ai.invoice_num trans_num,
ai.invoice_date trans_date,
ai.invoice_currency_code,
ai.invoice_amount invoice_amount,
nvl(ai.amount_paid,0) payment_amount,
nvl(ai.discount_amount_taken,0) discount_taken,
sum(nvl(aid1.amount,0)) dist_amount,  --bug 3338086
gl.currency_code --bug9050332
FROM
/*bug 5264865*/
ap_invoices_all ai,
ap_invoice_distributions_all aid1,
fnd_lookup_types_vl  lkp,
fnd_lookup_values_vl lkv,
gl_ledgers gl --bug9050332
-- 3641604 ap_payment_schedules aps
WHERE
ai.invoice_id = aid1.invoice_id
and ai.set_of_books_id = gl.ledger_id --bug9050332
-- and ai.payment_status_flag<>'P'
-- Fix for 2545297 commented above line and wrote below one
-- and ai.payment_status_flag in ('N','P')  2901541
-- and aid1.line_type_lookup_code = 'ITEM'   Commented this line for bug: 3338086
and lkp.lookup_type = 'INVOICE TYPE'
and lkp.application_id = 200
and lkv.lookup_code = ai.invoice_type_lookup_code
and lkv.lookup_type=lkp.lookup_type
and ai.invoice_type_lookup_code <> 'PREPAYMENT'
and ai.invoice_date <= p_as_of_date
and ai.vendor_id  = p_vendor_id
and ai.vendor_site_id = p_vendor_site_id
and ai.invoice_currency_code = nvl(p_currency,ai.invoice_currency_code)
-- 3641604 and ai.invoice_id=aps.invoice_id
-- Bug 9001247 Consider only Validated Invoices
and AP_INVOICES_UTILITY_PKG.get_approval_status(AI.INVOICE_ID,
             AI.INVOICE_AMOUNT, AI.PAYMENT_STATUS_FLAG,
             AI.INVOICE_TYPE_LOOKUP_CODE) = 'APPROVED'
GROUP BY
ai.invoice_id,
lkv.meaning ,
invoice_num ,
invoice_date,
ai.invoice_currency_code ,
ai.invoice_amount,
ai.amount_paid,
ai.discount_amount_taken,
ai.invoice_id,
-- 3641604 aps.payment_num,
ai.payment_cross_rate,
gl.currency_code; --bug9050332
--Bug 3338086 Removed group_by for line_type_code. Else
                       --it will fetch multiple rows.

--bug 5264869 replace view with base table
CURSOR curinfo(p_supplier_id po_vendors.vendor_id%TYPE) IS
SELECT DISTINCT(invoice_currency_code) invoice_currency_code
FROM ap_invoices_all ai
WHERE ai.vendor_id=p_supplier_id
and ai.invoice_currency_code=nvl(p_currency,ai.invoice_currency_code);

/*
3641604 : New cursor to get sum of discount available for invoice
*/

CURSOR ps_cursor (p_invoice_id NUMBER) IS
   SELECT payment_num
     FROM ap_payment_schedules
    WHERE invoice_id = p_invoice_id;


BEGIN --#1

  /*Commented the following code fnd added the next two SELECT stmts for bug#1721165 TMANDA
  select substr(userenv('LANG'),1,4) into l_session_language from dual;
  select language_code into l_base_language from fnd_languages where installed_flag='B';
  */
  -- for bug#1721165 Start TMANDA
  -- Get the session language
  select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
  into   l_session_language
  from   dual;

  -- Get the base language
  select nls_language
  into   l_base_language
  from   fnd_languages
  where  installed_flag = 'B';

  -- for bug#1721165 End TMANDA
 /* For bug 2113775
    Selecting the organization from gl_sets_of_books
    in case of single org since the org_id will be
    null in hr_organization_units
 */

  Begin

    SELECT name
    INTO l_organization_name
    FROM hr_organization_units
    WHERE organization_id = FND_PROFILE.VALUE('ORG_ID');

  Exception
     When no_data_found Then
       Begin
	 Select name
	 INTO   l_organization_name
	 FROM   gl_sets_of_books
	 WHERE  set_of_books_id = P_Set_of_books_id;
        Exception
	 When others then
	   null;
	End;
  End;
  -- End for bug 2113775



  --bug9050332 -Not using profile option GL_SET_OF_BKS_ID in R12.
  --Modified cursor invinfo to get functional currency code by join
  --invoices table with gl_ledgers.
  /*SELECT currency_code
  INTO l_functional_currency_code
  FROM gl_sets_of_books
  WHERE set_of_books_id = FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
  */
  /*OPEN  start_date(p_set_of_books_id);
  FETCH start_date into l_start_date;
  CLOSE start_date;*/

  BEGIN --#2 Begin VENDOR BLOCK

     FOR vendor_rec  IN vendorinfo (l_base_language,
                l_session_language)
     LOOP ---Start vendor loop

     	BEGIN  --#3 Begin Currency Block
	   FOR currency_rec IN curinfo(vendor_rec.vendor_id)
	   LOOP

           	l_total_inv_balance:=0;
		l_open_balance:=0;

	BEGIN --#4
	  	   FOR inv_rec IN invinfo (vendor_rec.vendor_id,
                	vendor_rec.vendor_site_id,
                        currency_rec.invoice_currency_code)
               	   LOOP
/*
2901541 Check to see if this invoice has an open balance on the As Of Date
*/
                  IF AP_GET_SUPPLIER_BALANCE_PKG.invoice_is_open_on_ao_date
                     (inv_rec.invoice_id, p_as_of_date)
                     THEN l_paid_amount := AP_GET_SUPPLIER_BALANCE_PKG.get_paid_amount_on_ao_date
                                           (inv_rec.invoice_id, p_as_of_date);
                          l_discount_avail:=0;
    			          l_tot_discount_avail:=0;

/*
3641604 : get the sum of the available discounts for the invoice
*/
                          l_sum_discount := 0;
                          FOR ps_rec IN ps_cursor(inv_rec.invoice_id) LOOP
                             BEGIN
                                l_sum_discount := l_sum_discount +
                                                  ap_payment_schedules_pkg.get_discount_available
                                                  (inv_rec.invoice_id, ps_rec.payment_num, sysdate,
                                                  inv_rec.invoice_currency_code);
                             EXCEPTION
                                WHEN NO_DATA_FOUND
                                   THEN l_sum_discount:= l_sum_discount + 0;
                             END;
                          END LOOP;
                          l_discount_avail := l_sum_discount;
/*
End 3641604 */

			--for Bug 1798542 following line changed such that
      			-- payment_cross_rate doesn't divide invoice_amount


         l_amount_remaining :=   /* Bug3338086  deduct the pmt/disc amt from dist_amount */
           ap_utilities_pkg.ap_round_currency
     ((inv_rec.dist_amount - ((l_paid_amount+
			                inv_rec.discount_taken+l_discount_avail)/
			                nvl(inv_rec.payment_cross_rate,1)))
			                ,inv_rec.invoice_currency_code);

    			--Start amount remaining if
       		       	IF l_amount_remaining>=nvl(p_min_invoice_balance,0) THEN

                      	INSERT INTO AP_SUPPLIER_BALANCE_ITF(
                          	   Request_id ,
                          	   as_of_date ,
                          	   organization_name ,
                          	   functional_currency_code ,
                          	   supplier_name ,
                          	   supplier_number,
                          	   vat_registration_number,
                          	   supplier_site_code ,
                          	   address_line1 ,
                          	   address_line2 ,
                          	   address_line3 ,
                          	   city ,
                          	   state ,
                          	   zip ,
                          	   country ,
                          	   invoice_type,
                          	   invoice_num,
                          	   invoice_date,
                          	   invoice_currency_code,
                          	   invoice_amount ,
                          	   amount_remaining ,
                          	   payment_amount ,
                          	   discount_taken ,
                          	   discount_amount_available )
                        VALUES (p_request_id,
                          	   p_as_of_date,
                          	   l_organization_name ,
                               --l_functional_currency_code ,
                               inv_rec.currency_code, --bug9050332 fucntional currency
                          	   vendor_rec.supplier_name,
 			  	   vendor_rec.supplier_number,
			  	   vendor_rec.vat_registration_number,
			  	   vendor_rec.supplier_site_code,
			  	   vendor_rec.address_line1,
 			  	   vendor_rec.address_line2,
			  	   vendor_rec.address_line3,
                          	   vendor_rec.city,
                          	   vendor_rec.state,
                          	   vendor_rec.postal_code,
                          	   vendor_rec.country,
                          	   inv_rec.trans_type,
                          	   inv_rec.trans_num,
                          	   inv_rec.trans_date,
 			  	   inv_rec.invoice_currency_code,
 			  	   inv_rec.invoice_amount,
                          	   l_amount_remaining,
                          	   inv_rec.payment_amount,
                          	   inv_rec.discount_taken,
                          	   l_tot_discount_avail);

                      	END IF;  --End amount remaining if
		END IF; -- End Invoice is open on As Of date
	   END LOOP;  --End Invoices Loop

	           EXCEPTION
                     	  WHEN NO_DATA_FOUND THEN
                     	     EXIT;
                     	  WHEN OTHERS THEN
                     	     APP_EXCEPTION.RAISE_EXCEPTION;
                END; --#4

                	   /*Bug 2431936 made the following changes to SQL below:
                	   1. Original and remaining amounts were switched. Corrected.
                	   2. Was excluding Partially paid.  According to doc, only paid
                	   should be selected.
                	   3. Was not restricting by minimun invoice balance. According to
                	   doc, the minimum should restrict the transactions in the report.
                	   4. SQL was selecting from vendor tables.  Since we are within
                	   the vendor loop, we can get values from cursor instead of from
                	   the tables, so the SQL is simpler.*/

                     IF (NVL(p_include_prepayments,'N') = 'Y') THEN --bug6800315

                        INSERT INTO ap_supplier_balance_itf(  Request_id ,
                           as_of_date,
                           organization_name ,
                           functional_currency_code ,
                           supplier_name ,
                           supplier_number,
                           vat_registration_number,
                           supplier_site_code ,
                           address_line1 ,
                           address_line2 ,
                           address_line3 ,
                           city ,
                           state ,
                           zip ,
                           country ,
                           invoice_type,
                           invoice_num,
                           invoice_date,
                           invoice_currency_code,
                           prepay_amount_original,
                           prepay_amount_remaining,
                           prepay_amount_applied,
                           invoice_amount ,  -- 8217987 3 Cols added
                           amount_remaining ,
                           payment_amount)
                        SELECT
                           p_request_id,
                           p_as_of_date,
                           l_organization_name ,
                           --l_functional_currency_code,
                           gl.currency_code, --bug9050332
                           vendor_rec.supplier_name,
 			   vendor_rec.supplier_number,
			   vendor_rec.vat_registration_number,
			   vendor_rec.supplier_site_code,
			   vendor_rec.address_line1,
 			   vendor_rec.address_line2,
			   vendor_rec.address_line3,
                           vendor_rec.city,
                           vendor_rec.state,
                           vendor_rec.postal_code,
                           vendor_rec.country,
                           lkv.meaning,
	                   ai.invoice_num,
                           ai.invoice_date ,
	                   ai.invoice_currency_code,
	                   SUM(nvl(AID1.AMOUNT,0)),
	                   SUM(nvl(AID1.PREPAY_AMOUNT_REMAINING,AID1.AMOUNT) ),
	                   (SUM(nvl(AID1.AMOUNT,0)) -
			                  SUM(nvl(AID1.PREPAY_AMOUNT_REMAINING,AID1.AMOUNT))),
			   ai.invoice_amount, -- 8217987
			   SUM(nvl(AID1.PREPAY_AMOUNT_REMAINING,AID1.AMOUNT) ),
			   ai.amount_paid
                        FROM ap_invoices ai,
                             ap_invoice_distributions aid1,
		             fnd_lookup_types_vl  lkp,
                 fnd_lookup_values_vl lkv,
                 gl_ledgers gl  --bug9050332
                        WHERE ai.invoice_id=aid1.invoice_id
                          and ai.set_of_books_id = gl.ledger_id --bug9050332
                          and ((aid1.line_type_lookup_code = 'ITEM') or
                               (aid1.line_type_lookup_code = 'TAX' and aid1.tax_calculated_flag = 'Y'))
		          and ai.invoice_type_lookup_code = 'PREPAYMENT'
			  and ai.payment_status_flag = 'Y'
	                  and lkp.lookup_type  = 'INVOICE TYPE'
	                  and lkp.application_id = 200
                          and lkv.lookup_code  = ai.invoice_type_lookup_code
                          and lkp.lookup_type=lkv.lookup_type
	                  and ai.vendor_id = vendor_rec.vendor_id
			  and ai.vendor_site_id = vendor_rec.vendor_site_id
                          and ai.invoice_date <= p_as_of_date
                          and ai.invoice_currency_code = nvl(currency_rec.invoice_currency_code,
                                                        ai.invoice_currency_code)  --bug6800315
			  and NVL(aid1.reversal_flag,'N') <> 'Y'      --bug6500253/6800315
                          and nvl(aid1.prepay_amount_remaining,aid1.amount)> 0
		       HAVING SUM(nvl(AID1.AMOUNT,0)) >= NVL(p_min_invoice_balance,0)--bug6800315
            GROUP BY gl.currency_code, --bug9050332,
                             lkv.meaning,
                             ai.invoice_num,
                             ai.invoice_date,
                             ai.invoice_currency_code,
		             ai.invoice_amount,
			     ai.amount_paid;

             END IF;--p_include_prepayments bug6800315
           END LOOP; --curinfo cursor

	   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   NULL;
		WHEN OTHERS THEN
		   --APP_EXCEPTION.RAISE_EXCEPTION;
		   NULL;

        END; --#3 Currency Block

     END LOOP; --vendor loop

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   NULL;
	WHEN OTHERS THEN
	   APP_EXCEPTION.RAISE_EXCEPTION;

  END; --#2 vendor block

  EXCEPTION
	WHEN OTHERS THEN
	   APP_EXCEPTION.RAISE_EXCEPTION;
END AP_GET_SUPPLIER_BALANCE; --#1

-- added the following 2 functions Bug: 2901541
FUNCTION get_paid_amount_on_ao_date
         (p_invoice_id IN NUMBER,
          p_as_of_date IN DATE)
   RETURN NUMBER IS
   v_payment_amount NUMBER;

BEGIN

   SELECT NVL(SUM(NVL(amount, 0)), 0)
     INTO v_payment_amount
     FROM ap_invoice_payments
    WHERE invoice_id = p_invoice_id
      AND accounting_date <= p_as_of_date;

    RETURN v_payment_amount;

END get_paid_amount_on_ao_date;

FUNCTION invoice_is_open_on_ao_date
         (p_invoice_id IN NUMBER,
          p_as_of_date IN DATE)
   RETURN BOOLEAN IS
   v_payment_amount NUMBER;
   v_invoice_amount NUMBER;
   v_payment_cross_rate    NUMBER;       -- 3542467
   v_invoice_currency_code VARCHAR2(15); -- 3542467
   v_discount_taken        NUMBER;       -- 3542467

BEGIN

/*
3542467: Get the payment cross rate and invoice currency code
*/
   SELECT AI.payment_cross_rate, AI.invoice_currency_code, NVL(SUM(NVL(AID.amount, 0)), 0)
     INTO v_payment_cross_rate, v_invoice_currency_code, v_invoice_amount
     FROM ap_invoice_distributions AID, ap_invoices AI
    WHERE AI.invoice_id = AID.invoice_id
      AND AI.invoice_id = p_invoice_id
    GROUP BY AI.payment_cross_rate, AI.invoice_currency_code;

/*
3542467: Get the discount taken
*/
   SELECT NVL(SUM(NVL(AIP.amount, 0)), 0), NVL(SUM(NVL(AIP.discount_taken, 0)), 0)
     INTO v_payment_amount, v_discount_taken
     FROM ap_invoice_payments AIP, ap_invoices AI
    WHERE AIP.invoice_id = AI.invoice_id
      AND AI.invoice_id = p_invoice_id
      AND accounting_date <= p_as_of_date;

/*
3542467: Modify the method for determining if there is an open balance
                  to account for payment rate variances and discount
*/
   IF AP_UTILITIES_PKG.ap_round_currency
      ((v_invoice_amount - ((v_payment_amount + v_discount_taken) /
        NVL(v_payment_cross_rate, 1))),
       v_invoice_currency_code) <> 0
      THEN RETURN TRUE;
      ELSE RETURN FALSE;
   END IF;


END invoice_is_open_on_ao_date;

END AP_GET_SUPPLIER_BALANCE_PKG;

/
