--------------------------------------------------------
--  DDL for Package Body JAI_AP_IDA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_IDA_TRIGGER_PKG" AS
/* $Header: jai_ap_ida_t.plb 120.10.12010000.15 2010/04/01 13:22:04 bgowrava ship $ */
  /*
  REM +======================================================================+
  REM NAME          ARUID_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_IDA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_IDA_ARIUD_T2
  REM
  REM +======================================================================+
  */
  PROCEDURE ARUID_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 )
  IS

     /* Cursor to check whether Tax lines exists for
     this invoice in localization tables */

     Cursor check_loc_tax(ln_invoice_id number) is
     select 'Y'
     from JAI_AP_MATCH_INV_TAXES
     where invoice_id = ln_invoice_id ;

    /* Check for localization tax existence */

    lv_exists varchar2(1) := 'N' ;

     -- Log file Generation
     lv_log_file_name VARCHAR2(50) := 'ja_in_ap_aida_after_trg.log';
     lv_utl_location  VARCHAR2(512);
     lv_myfilehandle    UTL_FILE.FILE_TYPE;
     lv_debug VARCHAR2(1) := 'N'; -- Harshita for Bug 5219176

    /* Variables related to CP */

    lb_result          BOOLEAN;
    ln_request_id      Number;

    /* Emd for bug4406963 */

BEGIN
      pv_return_code := jai_constants.successful ;

/*------------------------------------------------------------------------------------------
 FILENAME: jai_ap_ida_t.plb

CHANGE HISTORY:
S.No      Date          Author and Details

1.        22/11/2004    Aparajita, created  for bug # 3924692. Version # 115.0

                        This is the common after row level trigger for all events, that is
                        insert, update and delete.

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

2.      08-Jun-2005     This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.1

5.      13-Jun-2005    File Version: 116.3
                       Ramananda for bug#4428980. Removal of SQL LITERALs is done

6.      03/11/2006     Sanjikum for Bug#5131075, File Version 120.1
                       1) Changes are done for forward porting of bugs - 4722011, 4683207

                       Dependency Due to this Bug
                       --------------------------
                       Yes, as Package spec is changed and there are multiple files changed as part of current

7       13-JUNE-2007    ssawant for bug 6074957
      Modified cursor c_get_rnd_factor to check whether the current date is between start and end date.

8.       10/Jul/2009        Bgowrava for Bug 5911913 . File Version 120.0.12000000.12
				   Added two parameters
				   (1) p_old_input_dff_value_wct
				   (2) p_old_input_dff_value_essi
					 in procedure processs_invoice.

9.       28/Jan/2010  Modified by Jia for FP Bug#8656402
                      Issue: TDS amount is not rounded as per setup.
                          This was a forward port issue of the R11i Bug#8597476.
                      Fix:  Modified cursor c_get_rnd_factor in procedure BRIUD_T1 to include a filter
                         on invoice (accounting) date. Also, the rounding setup will be fetched for each invoice.


Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      3924692    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0
------------------------------------------------------------------------------------------ */
  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_AIDA_AFTER_TRG',
  --                               p_org_id           =>  pr_new.org_id,
  --                               p_set_of_books_id  =>  pr_new.set_of_books_id )
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  --end if;

  -- Bug 7114863. Added by Lakshmi Gopalsami
  -- Removed the reference to jai_ap_tolerance_pkg.check_tolerance_hold

  /* Bug 4406963. Added by LGOPALSA */

  /* Proceed only when Match_Status_Flag is changed to 'A'.
     Implies invoice is in validated status */



  If lv_debug = 'Y' Then
    Begin
      Select DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
             Value,SUBSTR (value,1,INSTR(value,',') -1))
        INTO lv_utl_location
        from v$parameter
       where name = 'utl_file_dir';

     lv_myfilehandle := UTL_FILE.FOPEN(lv_utl_location, lv_log_file_name ,'A');
     UTL_FILE.PUT_LINE(lv_myfilehandle, '********* Start ja_in_ap_aida_after_trg('||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||') *********');

     EXCEPTION
       WHEN OTHERS THEN
        lv_debug := 'N';
     END;
  End if; /* lv_debug ='Y' */

  If lv_debug = 'Y' Then -- added, Harshita for Bug 5219176
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' inside update ');
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' line type lookup code '|| pr_new.line_type_lookup_code);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' reversal flag '|| pr_new.reversal_flag);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' old match status flag '|| pr_old.match_status_flag);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' match status flag '|| pr_new.match_status_flag);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' old price variance '|| pr_old.invoice_price_variance);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' new price variance '|| pr_new.invoice_price_variance);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' old exc. vari '|| pr_old.exchange_rate_variance);
    UTL_FILE.PUT_LINE(lv_myfilehandle, ' exc. vari '|| pr_new.exchange_rate_variance);
    UTL_FILE.PUT_LINE(lv_myfilehandle, '  invoice id '|| pr_new.invoice_id);
    UTL_FILE.PUT_LINE(lv_myfilehandle, '  invoice dist id '||  pr_new.invoice_distribution_id);
  end if ;

  If updating Then

    If  (  ( pr_new.line_type_lookup_code = 'ITEM') AND
           ( ( nvl(pr_old.invoice_price_variance,0) <>  nvl(pr_new.invoice_price_variance,0) ) OR
             (  nvl(pr_old.base_invoice_price_variance,0) <>  nvl(pr_new.base_invoice_price_variance,0) ) OR
             ( nvl(pr_old.exchange_rate_variance,0) <>  nvl(pr_new.exchange_rate_variance,0) )
           )

        ) Then

      If lv_debug = 'Y' Then -- added, Harshita for Bug 5219176

         UTL_FILE.PUT_LINE(lv_myfilehandle, ' inside all condition chec k ');

         UTL_FILE.PUT_LINE(lv_myfilehandle, ' inside match status flag ');

      End If ;

      /* Check whether MISC (Tax lines) exists for this invoice
        Then proceed. Else return.
      */
      Open check_loc_tax(pr_new.invoice_id);
      Fetch check_loc_tax into lv_exists;
      Close check_loc_tax;

      If nvl(lv_exists , 'N') = 'Y' Then

       /* Proceed only when the variances are calculated and old variance
          is not equal to the new variances */

        IF lv_debug = 'Y' THEN
               UTL_FILE.PUT_LINE(lv_myfilehandle, '  exists flag ');
               UTL_FILE.PUT_LINE(lv_myfilehandle,
                                 'invoice_id => '|| pr_new.invoice_id
                              || ', po_distribution_id    => ' ||pr_new.po_distribution_id
            || ', line_type_lookup_code => ' ||pr_new.line_type_lookup_code
            || ', amount                => ' ||pr_new.amount
            || ', Dist Line number      => ' || pr_new.distribution_line_number
                             );
                UTL_FILE.PUT_LINE(lv_myfilehandle,
                                 ', amount                => ' ||pr_new.amount
            || ', base_amount           => ' ||pr_new.base_amount
            || ', Old Price Variance    => ' || pr_old.invoice_price_variance
            || ', New Price Variance    => ' || pr_new.invoice_price_variance
            || ', Base Old Price Variance => ' || pr_old.base_invoice_price_variance
            || ', Base New Price Variance => ' || pr_new.base_invoice_price_variance
            || ', Var CCID              => '||pr_new.price_var_code_combination_id
            || ', org_id                => ' ||pr_new.org_id
                             );
        END IF;

        -- Call the CP for calculating the IPV

        lb_result := Fnd_Request.set_mode(TRUE);
        ln_request_id := Fnd_Request.submit_request
                   ('JA',  -- Changed to JA from SQLAP, 4579729
                    'JAIAPIPV',
                    'India -  Create Variances for Payables Tax line',
                    '',
                    FALSE,
                    pr_new.invoice_id,
                    pr_new.po_distribution_id,
                    pr_new.invoice_distribution_id,
                    pr_new.amount,
                    pr_new.base_amount,
                    pr_new.rcv_transaction_id,
                    pr_new.invoice_price_variance,
                    pr_new.base_invoice_price_variance,
                    pr_new.price_var_code_combination_id,
                    pr_new.Exchange_rate_variance,
                    pr_new.rate_var_code_combination_id
                   );
          IF lv_debug = 'Y' THEN
            UTL_FILE.fclose(lv_myfilehandle);
          END IF;

        End if; /* lv_exists ='Y' */

      End if; /* For Variances */

    End if; /* updating */

   IF lv_debug = 'Y' THEN
       UTL_FILE.fclose(lv_myfilehandle);
   END IF;

/* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
   WHEN OTHERS THEN
     IF lv_debug ='Y' Then
       UTL_FILE.PUT_LINE(lv_myfilehandle, 'Error in trigger , errm -> '||SQLERRM);
       UTL_FILE.fclose(lv_myfilehandle);
     End if;
    RAISE;
  END ARUID_T1 ;
  /*
  REM +======================================================================+
  REM NAME          BRIUD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_IDA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_IDA_BRIUD_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new in out  t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    lv_final_dff_value_tds    varchar2(150);
  lv_process_flag           varchar2(20);
  lv_process_message        varchar2(200);
  ln_final_tds_tax_id       JAI_CMN_TAXES_ALL.tax_id%type;

   cursor c_ap_invoices_all is
    select ai.vendor_id,
           ai.vendor_site_id,
           ai.invoice_currency_code,
           ai.exchange_rate,
           ai.set_of_books_id,
           ai.source,
           ai.cancelled_date,
           -- Bug#5131075(4683207). Added by Lakshmi Gopalsami
           ai.invoice_type_lookup_code,
           ai.invoice_num,         /*added for bug 6493858 ref-6318997*/
           pv.vendor_type_lookup_code /* Bug 8330522. Added by Lakshmi Gopalsami */
    from   ap_invoices_all ai, po_vendors pv
    where  ai.invoice_id = pr_new.invoice_id
      and  ai.vendor_id = pv.vendor_id;

  --Added by Sanjikum for Bug#5131075(4722011)
  CURSOR c_check_prepayment_apply IS
  SELECT  '1'
  FROM    jai_ap_tds_prepayments
  WHERE   invoice_distribution_id_prepay = pr_new.invoice_distribution_id;

  CURSOR c_check_prepayment_unapply IS
  SELECT  '1'
  FROM    jai_ap_tds_prepayments
  WHERE   invoice_distribution_id_prepay = pr_new.parent_reversal_id
  AND     unapply_flag = 'Y';

  lv_prepay_flag            VARCHAR2(1);
  --End addition by Sanjikum for Bug#5131075(4722011)

  c_rec_ap_invoices_all     c_ap_invoices_all%rowtype;
  lv_codepath               VARCHAR2(1996);
  lv_is_invoice_validated   varchar2(1);
  lv_new_transaction_si     varchar2(1);
  lv_new_transaction_pp     varchar2(1);
  ln_org_id                 ap_invoices_all.org_id%type;
  ln_set_of_books_id        ap_invoices_all.set_of_books_id%type;
/*  bug 5640993 FP of 5553489. Added by JMEENA
   * Created variable which decides whether the prepayment
   * created prior to upgrade(TDS-Threshold) has to be processed
   */
  lv_process_old_trxn       VARCHAR2(1);

  /*Bug 5989740 bduvarag start*/
    /* Commented for bug# 6459941
     CURSOR c_get_rnd_factor (p_org_id IN NUMBER ) IS
   SELECT NVL(tds_rounding_factor,0) , tds_rounding_start_date
     FROM JAI_AP_TDS_YEARS
    WHERE legal_entity_id IN (SELECT legal_entity_id
                             FROM hr_operating_units
          where organization_id = p_org_id
        )
          AND trunc (sysdate) between start_date and end_date; --added by ssawant for bug 6074957
Bug 5989740 bduvarag end */

  /* Added for bug# 6459941 */
  CURSOR c_get_rnd_factor (p_org_id IN NUMBER, p_inv_date IN DATE ) IS -- Added a parameter p_inv_date by Jia for FP Bug#8656402
  SELECT
         nvl(tds_rounding_factor,0) ,
         tds_rounding_start_date
  FROM
         jai_ap_tds_years
  WHERE
         legal_entity_id  = p_org_id
   AND   trunc (p_inv_date) between start_date and end_date ; -- Modified by Jia for FP Bug#8656402, change sysdate to p_inv_date

/*start changes for bug 6493858 - logic for 5662741 moved from jai_ap_ia_t.plb*/
   CURSOR c_tds_invoice_id(cp_invoice_id	NUMBER)
   IS
   SELECT	invoice_to_tds_authority_id invoice_id,
  			invoice_to_tds_authority_num invoice_num
   FROM 	jai_ap_tds_thhold_trxs
   WHERE 	invoice_id = cp_invoice_id;

  /*  Bug 8330522. Added by Lakshmi Gopalsami  */

   CURSOR c_tds_invoice_id1(cp_invoice_to_vendor_id	NUMBER)
   IS
   SELECT	invoice_to_tds_authority_id invoice_id,
  			invoice_to_tds_authority_num invoice_num
   FROM 	jai_ap_tds_thhold_trxs
   WHERE 	invoice_to_vendor_id = cp_invoice_to_vendor_id;
   -- end for bug 83305222.

  r_tds_invoice_id	c_tds_invoice_id%ROWTYPE;

  lv_invoice_payment_status ap_invoices_all.payment_status_flag%TYPE;

	FUNCTION get_invoice_payment_status(p_invoice_id  IN  NUMBER)
		RETURN VARCHAR2
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;

	BEGIN
		RETURN (ap_invoices_utility_pkg.get_payment_status(p_invoice_id));
  END get_invoice_payment_status;

/*end changes for bug 6493858*/


  --Inline procedure added by Sanjikum for Bug#5131075(4722011)
  PROCEDURE process_prepayment(cp_event varchar2)   --Added parameter cp_event for Bug 8431516
  IS
  BEGIN
  /* Check if the prepayment transaction should be processed by the code before
    TDS Clean up or after TDS clean up.

    if SI is created in the new regime and also the Prepay is created in the new regime,
    then code should invoke the new regime or else
    old concurrent shd be invoked  */


    --Check for SI
    jai_ap_tds_tax_defaultation.check_old_transaction
    (
    p_invoice_id                    =>    pr_new.invoice_id,
    p_new_transaction               =>    lv_new_transaction_si
    );

    --Check for Pprepayment
    jai_ap_tds_tax_defaultation.check_old_transaction
    (
    p_invoice_distribution_id      =>    pr_new.prepay_distribution_id,
    p_new_transaction               =>   lv_new_transaction_pp
    );

    if lv_new_transaction_si = 'Y' and lv_new_transaction_pp = 'Y' then

      lv_codepath := null;

      jai_ap_tds_prepayments_pkg.process_prepayment
      (
        p_event                          =>     cp_event,           --Added parameter cp_event for Bug 8431516
        p_invoice_id                     =>     pr_new.invoice_id,
        p_invoice_distribution_id        =>     pr_new.invoice_distribution_id,
        p_prepay_distribution_id         =>     pr_new.prepay_distribution_id,
        p_parent_reversal_id             =>     pr_new.parent_reversal_id,
        p_prepay_amount                  =>     pr_new.amount,
        p_vendor_id                      =>     c_rec_ap_invoices_all.vendor_id,
        p_vendor_site_id                 =>     c_rec_ap_invoices_all.vendor_site_id,
        p_accounting_date                =>     pr_new.accounting_date,
        p_invoice_currency_code          =>     c_rec_ap_invoices_all.invoice_currency_code,
        p_exchange_rate                  =>     c_rec_ap_invoices_all.exchange_rate,
        p_set_of_books_id                =>     c_rec_ap_invoices_all.set_of_books_id,
        p_org_id                         =>     pr_new.org_id,
        p_creation_date                  =>     pr_new.creation_date, /*Bug 5989740 bduvarag*/
        p_process_flag                   =>     lv_process_flag,
        p_process_message                =>     lv_process_message,
        p_codepath                       =>     lv_codepath
      );

      if   nvl(lv_process_flag, 'N') = 'E' then
        raise_application_error(-20007,
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message);
      end if;

    else
	  /* Bug 5640993 FP of 5553489. Added by JMEENA
                 * Invoking the processing of prepayments only during
                 * prepayment application and not during validation
                 */
        IF lv_process_old_trxn  = 'Y' THEN

      --Invoke the old regime functionality
      jai_ap_tds_prepayments_pkg.process_old_transaction
      (
        p_invoice_id                     =>     pr_new.invoice_id,
        p_invoice_distribution_id        =>     pr_new.invoice_distribution_id,
        p_prepay_distribution_id         =>     pr_new.prepay_distribution_id,
        p_amount                         =>     pr_new.amount,
        p_last_updated_by                =>     pr_new.last_updated_by,
        p_last_update_date               =>     pr_new.last_update_date,
        p_created_by                     =>     pr_new.created_by,
        p_creation_date                  =>     pr_new.creation_date,
        p_org_id                         =>     pr_new.org_id,
        p_process_flag                   =>     lv_process_flag,
        p_process_message                =>     lv_process_message
      );

      if   nvl(lv_process_flag, 'N') = 'E' then
        raise_application_error(-20008,
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message);
      end if;
END IF ; --End of bug#5640993

    end if; --Transactions in new regime
  END process_prepayment;


  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_ap_aida_before_trg.sql

CHANGE HISTORY:
S.No      Date            Author and Details

1.       25/03/2004       Aparajita. Bug # 4088186. TDS Clean up. Version#115.0

                          This is the only trigger introduced for all the before event
                          on the table on which this is based.

2.     11/05/2005         rchandan for bug#4333488. Version 116.1
                          The Invoice Distribution DFF is eliminated and a new global DFF is used to
                          maintain the functionality. From now the TDS tax, WCT tax and ESSI will not
                          be populated in the attribute columns of ap_invoice_distributions_all table
                          instead these will be populated in the global attribute columns. So the code changes are
                          made accordingly.

3.      24/05/2005        Ramananda for bug# 4388958 File Version: 116.1
                          Changed AP Lookup code from 'TDS' to 'INDIA TDS'

4.    08-Jun-2005         This Object is Modified to refer to New DB Entity names in place of Old
                          DB Entity as required for CASE COMPLAINCE.  Version 116.2

5     13-Jun-2005         File Version: 116.3
                          Ramananda for bug#4428980. Removal of SQL LITERALs is done

6.    06-jul-2005        AP lines change.
7.  18/04/2007    bduvarag for the Bug#5989740, file version 120.2
      Forward porting the changes done in 11i bug#5907436
8.    21/10/2008  Bug 5640993 FP of 5553489. Added by JMEENA
                      Invoked processing of old prepayment application using variable lv_process_old_trxn. Processing of TDS prepayment application for transactions created
                      prior to upgrade to TDS Threshold will be done only at the time of application and not during validation.

9.  18-Jul-2009  Bug 8641199
 	             Need to update match_status_flag in jai_ap_tds_inv_taxes with the match_status_flag of
 	             ap_invoice_distributions_all

8. 11-Jan-2010  Xiao Lv for bug#7347508, related 11i bug#6417285
                         Added new conditions to check if either TDS, WCT or ESSI taxes are getting modified or inserted
												 after the invoice has been validated. In such cases an error message is thrown stating that once an
			                   invoice is validated, there should not be any modifications made to these three taxes.

			                   Added the new condition 'nvl(pr_new.global_attribute_category, 'JA.IN.APXINWKB.DISTRIBUTIONS' ) =
			                   'JA.IN.APXINWKB.DISTRIBUTIONS'' to make sure the checks are made only when the context is
			                   'JA.IN.APXINWKB.DISTRIBUTIONS'

9. 14-Jan-2010  Xiao Lv for bug#7154864, related 11i bug#6767347
                         Commented two if condition section code.

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      3924692    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

2.    4088186     4088186           Call to Package jai_ap_tds_tax_defaultation.
-------------------------------------------------------------------------------------------------

8.    17/Sep/2007  Bug 5911913. Added by vkantamn version 120.6
                        Added two parameters
      (1) p_old_input_dff_value_wct
      (2) p_old_input_dff_value_essi
      in the call to procedure process_invoice.

      Dependencies:
      -------------
      jai_ap_tds_dflt.pls  120.1
      jai_ap_tds_dflt.plb  120.3
      jai_ap_ida_t.plb     120.5


9.    18-Oct-07   Bug 6493858, File version 120.8
                      Moved the validation done for invoice cancellation process from jai_ap_ia_t.plb.
		      Through this, changes done for bug 6318997 have been forward ported to R12 code.

10.   21-Dec-2007  Sanjikum for Bug#6708042, Version 120.10
                  Obsoleted the changes done for verion 120.6

11.    05-Dec-2008    Bgowrava for Bug#7433241, file Version  120.10.12010000.4
                                    moved the end if condition in the code of intercepting the validate event. this enables that only the call to the
			    process_tds_at_inv_validate procedure is dependent on the value of variable lv_is_invoice_validated. Thus enabling
			   the code for prepayment to execute when a prepayment application or unapplication to execute when the prepayment is
			   applied before validation of the std invoice.

 12. 01-Apr-2010   Bgowrava for bug#9457695, file version 120.10.12010000.15
                              Added the code to populate global_attribute1 and global attribute context in ap_invoice_distributions table
		         at the place after the validation procedure.

------------------------------------------------------------------------------------------ */

/*CHANGE HISTORY:
S.No  Bug        Date            Author and Details
1    6493858	4-DEC-2007       Added by Nitin Prashar, for cancelation of Base Invoice*/


if pv_action = jai_constants.inserting or pv_action = jai_constants.updating then
    ln_org_id := pr_new.org_id;
    ln_set_of_books_id := pr_new.set_of_books_id;
  elsif pv_action = jai_constants.deleting then
    ln_org_id := pr_old.org_id;
    ln_set_of_books_id := pr_old.set_of_books_id;
  end if;

  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_AIDA_BEFORE_TRG',
  --                               p_org_id           =>  ln_org_id,
  --                               p_set_of_books_id  =>  ln_set_of_books_id )
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  --end if;


  /* TDS Tax Defaultation Functionality Bug # 4088186 */
  open  c_ap_invoices_all;
  fetch c_ap_invoices_all into c_rec_ap_invoices_all;
  close c_ap_invoices_all;

 /* Bug 5640993 FP of 5553489. Added by JMEENA
   * Initialized the variable lv_process_old_trxn to 'Y' so that
   * prepayments will be processed during insert event.
   */
  lv_process_old_trxn := 'Y';

  /*Bug 5989740 bduvarag start*/
  -- Rmoved by Jia for FP Bug#8656402, Begin
  ------------------------------------------------------------------------
  /*
  IF JAI_AP_TDS_GENERATION_pkg.gn_tds_rounding_factor IS NULL
     OR JAI_AP_TDS_GENERATION_pkg.gd_tds_rounding_effective_date IS NULL
  THEN
  */
  ------------------------------------------------------------------------
  -- Rmoved by Jia for FP Bug#8656402, End
   OPEN c_get_rnd_factor (pr_new.org_id, pr_new.accounting_date); -- Added a parameter pr_new.accounting_date for cursor by Jia for FP Bug#8656402
    FETCH c_get_rnd_factor into
        JAI_AP_TDS_GENERATION_pkg.gn_tds_rounding_factor,
  JAI_AP_TDS_GENERATION_pkg.gd_tds_rounding_effective_date;
   CLOSE c_get_rnd_factor ;
  --END IF;  -- Rmoved by Jia for FP Bug#8656402


/*Bug 5989740 bduvarag end*/

   --Added by Xiao Lv for bug#7347508 on 11-Jan-2010, begin
  if pv_action = jai_constants.updating
  then
     IF nvl(pr_new.global_attribute_category, 'JA.IN.APXINWKB.DISTRIBUTIONS' ) = 'JA.IN.APXINWKB.DISTRIBUTIONS'
     AND (   nvl(pr_old.global_attribute1, 0) <> nvl(pr_new.global_attribute1, 0)
          OR nvl(pr_old.global_attribute2, 0) <> nvl(pr_new.global_attribute2, 0)
          OR nvl(pr_old.global_attribute3, 0) <> nvl(pr_new.global_attribute3, 0)
          )
     AND pr_old.match_status_flag = 'A'
	   THEN
	  raise_application_error(-20036,
      		 'Error - Cannot Modify or Insert the values for TDS, WCT or ESSI tax id once Invoice is validated ');
     end if;
   end if;
   --Added by Xiao Lv for bug#7347508 on 11-Jan-2010, end


  if pv_action = jai_constants.inserting or pv_action = jai_constants.updating then

    if  nvl(pr_new.global_attribute_category, 'JA.IN.APXINWKB.DISTRIBUTIONS' ) = 'JA.IN.APXINWKB.DISTRIBUTIONS' and   -- rchandan for bug#4333488
        pr_new.line_type_lookup_code <> 'PREPAY' and
        c_rec_ap_invoices_all.source <> 'INDIA TDS' and /*'TDS' and --Ramanand for bug#4388958 */
        c_rec_ap_invoices_all.cancelled_date is null
    then

      jai_ap_tds_tax_defaultation.process_invoice
      (
        p_invoice_id                  =>  pr_new.invoice_id,
        p_invoice_line_number         =>  pr_new.invoice_line_number ,   /* AP  Lines*/
        p_invoice_distribution_id     =>  pr_new.invoice_distribution_id,
        p_line_type_lookup_code       =>  pr_new.line_type_lookup_code,
        p_distribution_line_number    =>  pr_new.distribution_line_number,
        p_parent_reversal_id          =>  pr_new.parent_reversal_id,
        p_reversal_flag               =>  pr_new.reversal_flag,
        p_amount                      =>  pr_new.amount,
        p_invoice_currency_code       =>  c_rec_ap_invoices_all.invoice_currency_code,
        p_exchange_rate               =>  c_rec_ap_invoices_all.exchange_rate,
        p_set_of_books_id             =>  c_rec_ap_invoices_all.set_of_books_id,
        p_po_distribution_id          =>  pr_new.po_distribution_id,
        p_rcv_transaction_id          =>  pr_new.rcv_transaction_id,
        p_vendor_id                   =>  c_rec_ap_invoices_all.vendor_id,
        p_vendor_site_id              =>  c_rec_ap_invoices_all.vendor_site_id,
        p_input_dff_value_tds         =>  pr_new.global_attribute1,   -- rchandan for bug#4333488
        p_input_dff_value_wct         =>  pr_new.global_attribute2,   -- rchandan for bug#4333488
        p_old_input_dff_value_wct     =>  pr_old.global_attribute2,  -- Added by Bgowrava for Bug 5911913
        p_input_dff_value_essi        =>  pr_new.global_attribute3,   -- rchandan for bug#4333488
        p_old_input_dff_value_essi    =>  pr_old.global_attribute3,  -- Added by Bgowrava for Bug 5911913
        p_org_id                      =>  pr_new.org_id,
        p_accounting_date             =>  pr_new.accounting_date,
        p_call_from                   =>  'ja_in_ap_aida_after_trg',
        p_final_tds_tax_id            =>  ln_final_tds_tax_id,
        p_process_flag                =>  lv_process_flag,
        p_process_message             =>  lv_process_message,
        p_codepath                    =>  lv_codepath
      );

      if   nvl(lv_process_flag, 'N') = 'E' then
/*         raise_application_error(-20004,
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_codepath); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_codepath ; return ;
      end if;

      /*Bug 8641199 - Start*/
      jai_ap_tds_generation_pkg.status_update_chk_validate
      (
       p_invoice_id                  =>  pr_new.invoice_id,
       p_invoice_distribution_id     =>  pr_new.invoice_distribution_id,
       p_match_status_flag           =>  pr_new.match_status_flag,
       p_is_invoice_validated        =>  lv_is_invoice_validated,
       p_process_flag                =>  lv_process_flag,
       p_process_message             =>  lv_process_message,
       p_codepath                    =>  lv_codepath
      );
      /*Bug 8641199 - End*/

      /*if pr_new.global_attribute1 is null and ln_final_tds_tax_id is not null then    --rchandan for bug#4333488
        pr_new.global_attribute1 := to_char(ln_final_tds_tax_id);--rchandan for bug#4333488
      end if;

      if pr_new.global_attribute1 is not null or pr_new.global_attribute2 is not null or pr_new.global_attribute3 is not null then--rchandan for bug#4333488
        pr_new.global_attribute_category :=  'JA.IN.APXINWKB.DISTRIBUTIONS';   --rchandan for bug#4333488
      end if; */ --Commented by xiao for bug#7154864

    end if; /* Additional conditions */

  end if; /*inserting or updating */

  /* TDS Tax Defaultation Functionality Bug # 4088186 */

  /* Intercepting  Validate event */
  if pv_action = jai_constants.updating then

    if nvl(pr_old.match_status_flag, 'Q') <> nvl(pr_new.match_status_flag, 'Q') and
      pr_new.match_status_flag = 'A' and
      c_rec_ap_invoices_all.source <> 'INDIA TDS' and /*'TDS' and --Ramanand for bug#4388958 */
      c_rec_ap_invoices_all.cancelled_date is null
    then

      /* Bug#5131075(4683207). Added by Lakshmi Gopalsami
          Don't proceed for TDS invoice creation if the invoice type
        is either 'CREDIT' or 'DEBIT'
      */

      If c_rec_ap_invoices_all.invoice_type_lookup_code
                  IN ('CREDIT', 'DEBIT')
      Then
         return;
      End if;

      lv_codepath := null;

      jai_ap_tds_generation_pkg.status_update_chk_validate
      (
        p_invoice_id                  =>  pr_new.invoice_id,
        p_invoice_line_number         =>  pr_new.invoice_line_number, /* AP  Lines*/
        p_invoice_distribution_id     =>  pr_new.invoice_distribution_id,
        p_match_status_flag           =>  pr_new.match_status_flag,
        p_is_invoice_validated        =>  lv_is_invoice_validated,
        p_process_flag                =>  lv_process_flag,
        p_process_message             =>  lv_process_message,
        p_codepath                    =>  lv_codepath
        );

        if   nvl(lv_process_flag, 'N') = 'E' then
/*           raise_application_error(-20005,
          'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
          'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ; return ;
        end if;

        if lv_is_invoice_validated = 'Y' then

          lv_codepath := null;
          jai_ap_tds_generation_pkg.process_tds_at_inv_validate
          (
            p_invoice_id               =>     pr_new.invoice_id,
            p_vendor_id                =>     c_rec_ap_invoices_all.vendor_id,
            p_vendor_site_id           =>     c_rec_ap_invoices_all.vendor_site_id,
            p_accounting_date          =>     pr_new.accounting_date,
            p_invoice_currency_code    =>     c_rec_ap_invoices_all.invoice_currency_code,
            p_exchange_rate            =>     c_rec_ap_invoices_all.exchange_rate,
            p_set_of_books_id          =>     c_rec_ap_invoices_all.set_of_books_id,
            p_org_id                   =>     pr_new.org_id,
            p_call_from                =>     'ja_in_ap_aida_before_trg',
          p_creation_date            =>     pr_new.creation_date,/*Bug 5989740 bduvarag*/
            p_process_flag             =>     lv_process_flag,
            p_process_message          =>     lv_process_message,
            p_codepath                 =>     lv_codepath
          );

          if   nvl(lv_process_flag, 'N') = 'E' then
/*             raise_application_error(-20006,
            'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
            'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ; return ;
          end if;

		 end if;   --moved this from below for Bug#7433241

          --Start added by Sanjikum for Bug#5131075(4722011)
          --To handle the condition, if there are PP applications/Unapplications, before the SI is validated
          IF pr_new.line_type_lookup_code = 'PREPAY' THEN


            lv_prepay_flag := NULL;

            --Apply Scenario
            IF NVL(pr_new.amount,0) < 0 THEN

              OPEN c_check_prepayment_apply;
              FETCH c_check_prepayment_apply INTO lv_prepay_flag;
              CLOSE c_check_prepayment_apply;

            --Unapply Scenario
            ELSIF NVL(pr_new.amount,0) > 0 THEN

              OPEN c_check_prepayment_unapply;
              FETCH c_check_prepayment_unapply INTO lv_prepay_flag;
              CLOSE c_check_prepayment_unapply;

            END IF;

            --should be run, only if prepayment application/unapplication is not already processed
            IF lv_prepay_flag IS NULL THEN
 			 /* Bug 5640993 FP of  5553489.  Added by JMEENA
                                                 * Set the variable  lv_process_old_trxn so that old prepayments will not be processed during validation. */
                lv_process_old_trxn := 'N';
              process_prepayment(cp_event => 'UPDATE');    --Added parameter cp_event for Bug 8431516
            END IF;

          END IF;
          --End added by Sanjikum for Bug#5131075(4722011)

      -- end if; --commented by bgowrava for Bug#7433241, moved this end if to a different place at the top.
      /*START, Added by Bgowrava for Bug#9457695*/
      if pr_new.global_attribute1 is null and ln_final_tds_tax_id is not null then
        pr_new.global_attribute1 := to_char(ln_final_tds_tax_id);
      end if;

      if pr_new.global_attribute1 is not null or pr_new.global_attribute2 is not null or pr_new.global_attribute3 is not null then
        pr_new.global_attribute_category :=  'JA.IN.APXINWKB.DISTRIBUTIONS';
      end if;
      /*END, Added by Bgowrava for Bug#9457695*/

    end if; /* pr_old.match_status_flag <> pr_new.match_status_flag */
  end if; /* updating */
  /* Intercepting  Validate event */


  /* Prepayment functionality */
  if pv_action = jai_constants.inserting then

    if  pr_new.line_type_lookup_code = 'PREPAY'   and
        c_rec_ap_invoices_all.source <> 'INDIA TDS' and /*'TDS'   and --Ramanand for bug#4388958 */
        c_rec_ap_invoices_all.cancelled_date is null
    then

      /* Bug#5131075(4683207). Added by Lakshmi Gopalsami
          Don't proceed for TDS invoice creation if the invoice type
        is either 'CREDIT' or 'DEBIT'
      */

      If c_rec_ap_invoices_all.invoice_type_lookup_code
                  IN ('CREDIT', 'DEBIT')
      Then
         return;
      End if;


      --Start Added by Sanjikum for Bug#5131075(4722011)
      --If SI is not validated at this stage, then return

      lv_codepath := null;

      jai_ap_tds_generation_pkg.status_update_chk_validate
      (
        p_invoice_id                  =>  pr_new.invoice_id,
        /* p_invoice_line_id          =>  null,  Future use AP  Lines
        /*p_invoice_distribution_id     =>  null,*/
        p_match_status_flag           =>  pr_new.match_status_flag, --Changed by Sanjikum for Bug#5131075(4722011)
        p_is_invoice_validated        =>  lv_is_invoice_validated,
        p_process_flag                =>  lv_process_flag,
        p_process_message             =>  lv_process_message,
        p_codepath                    =>  lv_codepath
        );

        if   nvl(lv_process_flag, 'N') = 'E' then
          raise_application_error(-20005,
          'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message);
        end if;

      IF lv_is_invoice_validated = 'N' THEN
        RETURN;
      END IF;

      process_prepayment(cp_event => 'INSERT');    --Added parameter cp_event for Bug 8431516

      --Removed the existing code for Handling PP and moved it into inline procedure process_prepayment
      --End Added by Sanjikum for Bug#5131075(4722011)


       /*--Check if the prepayment transaction should be processed by the code before
       --TDS Clean up or after TDS clean up.

       --if SI is created in the new regime and also the Prepay is created in the new regime,
       --then code should invoke the new regime or else
       --old concurrent shd be invoked


      --Check for SI
      jai_ap_tds_tax_defaultation.check_old_transaction
      (
      p_invoice_id                    =>    pr_new.invoice_id,
      p_new_transaction               =>    lv_new_transaction_si
      );

      --Check for Prepayment
      jai_ap_tds_tax_defaultation.check_old_transaction
      (
      p_invoice_distribution_id      =>    pr_new.prepay_distribution_id,
      p_new_transaction               =>   lv_new_transaction_pp
      );

      if lv_new_transaction_si = 'Y' and lv_new_transaction_pp = 'Y' then

        lv_codepath := null;

        jai_ap_tds_prepayments_pkg.process_prepayment
        (
          p_invoice_id                     =>     pr_new.invoice_id,
          p_invoice_distribution_id        =>     pr_new.invoice_distribution_id,
          p_prepay_distribution_id         =>     pr_new.prepay_distribution_id,
          p_parent_reversal_id             =>     pr_new.parent_reversal_id,
          p_prepay_amount                  =>     pr_new.amount,
          p_vendor_id                      =>     c_rec_ap_invoices_all.vendor_id,
          p_vendor_site_id                 =>     c_rec_ap_invoices_all.vendor_site_id,
          p_accounting_date                =>     pr_new.accounting_date,
          p_invoice_currency_code          =>     c_rec_ap_invoices_all.invoice_currency_code,
          p_exchange_rate                  =>     c_rec_ap_invoices_all.exchange_rate,
          p_set_of_books_id                =>     c_rec_ap_invoices_all.set_of_books_id,
          p_org_id                         =>     pr_new.org_id,
          p_process_flag                   =>     lv_process_flag,
          p_process_message                =>     lv_process_message,
          p_codepath                       =>     lv_codepath
        );

        if   nvl(lv_process_flag, 'N') = 'E' then
          -- raise_application_error(-20007,
          --'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message);
          pv_return_code := jai_constants.expected_error ;
          pv_return_message := 'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ;
          return ;
        end if;

      else
        --
        --|| Invoke the old regime functionality
        --
        jai_ap_tds_prepayments_pkg.process_old_transaction
        (
          p_invoice_id                     =>     pr_new.invoice_id,
          p_invoice_distribution_id        =>     pr_new.invoice_distribution_id,
          p_prepay_distribution_id         =>     pr_new.prepay_distribution_id,
          p_amount                         =>     pr_new.amount,
          p_last_updated_by                =>     pr_new.last_updated_by,
          p_last_update_date               =>     pr_new.last_update_date,
          p_created_by                     =>     pr_new.created_by,
          p_creation_date                  =>     pr_new.creation_date,
          p_org_id                         =>     pr_new.org_id,
          p_process_flag                   =>     lv_process_flag,
          p_process_message                =>     lv_process_message
        );

        if   nvl(lv_process_flag, 'N') = 'E' then
          --raise_application_error(-20008,
          --'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message);
          pv_return_code := jai_constants.expected_error ;
          pv_return_message := 'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ;
          return ;
        end if;


      end if; --Transactions in new regime*/


    end if; /* Prepayment functionality */

/*Code Started start changes for bug 6493858 - cancellation functionality*/
   IF pr_new.cancellation_flag = 'Y' AND c_rec_ap_invoices_all.source <> 'INDIA TDS'
   THEN
    --commented the following for bug#9052839
    /*OPEN c_tds_invoice_id(pr_new.invoice_id);
    FETCH c_tds_invoice_id INTO r_tds_invoice_id;
    CLOSE c_tds_invoice_id;*/

    --added the FOR loop for bug#9052839
    FOR r_tds_invoice_id IN c_tds_invoice_id (pr_new.invoice_id)
    LOOP
      IF r_tds_invoice_id.invoice_id IS NOT NULL THEN
        lv_invoice_payment_status := get_invoice_payment_status(r_tds_invoice_id.invoice_id);

        IF NVL(lv_invoice_payment_status,'N') <> 'N' THEN
          raise_application_error(-20011,
          'Invoice to TDS Authority - '||r_tds_invoice_id.invoice_num||' is already paid. Current invoice can''t be cancelled' );
        END IF;
      END IF;
    END LOOP;
   END IF;
/*end changes for bug 6493858  -Code Ended */

  /* Bug 8330522. Added by Lakshmi Gopalsami */
  IF pr_new.cancellation_flag = 'Y' AND c_rec_ap_invoices_all.source = 'INDIA TDS'
  AND c_rec_ap_invoices_all.vendor_type_lookup_code <> 'INDIA TDS AUTHORITY'
  THEN
   	--commented the following for bug#9052839
    /*OPEN c_tds_invoice_id1(pr_new.invoice_id);
    FETCH c_tds_invoice_id1 INTO r_tds_invoice_id;
    CLOSE c_tds_invoice_id1;*/

    --added the FOR loop for bug#9052839
    FOR r_tds_invoice_id IN c_tds_invoice_id1 (pr_new.invoice_id)
    LOOP
      IF r_tds_invoice_id.invoice_id IS NOT NULL THEN
        lv_invoice_payment_status := get_invoice_payment_status(
                                     r_tds_invoice_id.invoice_id);

        IF NVL(lv_invoice_payment_status,'N') <> 'N' THEN
          raise_application_error(-20011,
          'Invoice to TDS Authority - '||r_tds_invoice_id.invoice_num||' is already paid. TDS Credit memo to supplier invoice can''t be cancelled' );
        END IF;
      END IF;
    END LOOP;
  END IF;
  /*End for bug 8330522*/

  end if; /* inserting */

  if pv_action = jai_constants.deleting  then

    jai_ap_tds_tax_defaultation.process_delete
    (
      p_invoice_id                  =>  pr_old.invoice_id,
      p_invoice_line_number         =>  pr_new.invoice_line_number, /* AP  Lines*/
      p_invoice_distribution_id     =>  pr_old.invoice_distribution_id,
      p_process_flag                =>  lv_process_flag,
      P_process_message             =>  lv_process_message
    );

      if   nvl(lv_process_flag, 'N') = 'E' then
/*         raise_application_error(-20009,
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ; return ;
      end if;

  end if; /* Deleting */


exception
  when others then
    --raise_application_error(-20010, 'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || sqlerrm);
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_IDA_TRIGGER_PKG.BRIUD_T1  '  ||
                             'Error on ap_invoice_distributions_all : ' || substr(sqlerrm,1,1900);

  END BRIUD_T1 ;

END JAI_AP_IDA_TRIGGER_PKG ;

/
