--------------------------------------------------------
--  DDL for Package Body JAI_AR_RGM_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_RGM_PROCESSING_PKG" 
/* $Header: jai_ar_rgm_proc.plb 120.7.12010000.9 2010/04/16 09:59:02 boboli ship $ */

/******************************************************************************************************************************************************
Created By       : aiyer
Created Date     : 27-jan-2005
Enhancement Bug  : 4146634
Purpose          : Process the Service Tax AR records (Invoices,Credit memo's and Cash Receipts Applications) and populate
                   the jai_rgm_trx_refs and jai_rgms_trx_records appropriately.
Called From      : jai_rgm_trx_processing.process_batch

                   Dependency Due To The Current Bug :
                   This object has been newly created with as a part of the service tax enhancement.
                   Needs to be always released along with the bug 4146708.

Change History: -
=================
1  20-Feb-2005  aiyer - Bug # 4193633 - File Version# 115.1
   Issue
    The tax earned and unearned discount are not getting apportioned properly for the service type of taxes and hence the India - Service Tax concurrent
    ends up in a warning for records with these issues

   Fix
    The procedure get_ar_tax_disc_accnt has been modified for the fix of this bug.
    Please refer the procedure change history for the details of this bug

   Dependency Due To This Bug:
    Dependency exists due to specification change of the current procedure.
    Always sent the following packages together:-

    1. jai_rgm_process_ar_taxes_pkg_s.sql          (115.1)
    2. jai_rgm_process_ar_taxes_pkg_b.sql          (115.1)
    3. jai_rgm_trx_recording_pkg_s.sql version     (115.1)
    4. jai_rgm_trx_recording_pkg_b.sql version     (115.1)

2. 08-Jun-2005  Version 116.2 jai_ar_rgm_proc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

3.     14-Jun-2005      rchandan for bug#4428980, Version 116.3
                        Modified the object to remove literals from DML statements and CURSORS.

4.   14-May-2005      CSahoo for bug#5879769. File Version 120.4
          Forward porting of 11i BUG#5694855
          SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION

5.   29-Nov-2006      Walton for inclusive tax computation

6.   26-June-2008           Changes by nprashar for bug 6997453
                    Issue : Invoice date column in 'India - Service tax pending liability' report
                is showing creation date. (The reason for making changes in this file is that
                the service tax processing program's behavior was also wrong w.r.to the date
                paratmeters passed and the way AR invoices are picked up for populating
                jai_rgm_trx_refs table
                    Cause : The query in the report is using jai_rgm_trx_refs.creation_date as
                the invoice date. While checking how this field is populated, observed that
                the records are populated while running the service tax processor.
                In the procedure populate_inv_cm_references, the invoices are picked up
                based on the creation_date. This is wrong behavior, and by common sense it
                should be picked up on the basis of trx_date of the invoice.
        Fix : Modified the cursor c_fetch_inv_cm_rec as described above.

7.   04/11/2008       Forward Port Bug 6474509
                Issue: INDIA TAXES NOT REVERSING ON REVERSING A RECEIPT
                Reason: Cursor c_get_refrec_for_upd doesn't fetch invoices to process the receipt reversals
                      only when there is no discounted amount during receipt application
                Fix   : Cursor c_get_refrec_for_upd (Added = condition) is modified to fetch the invoices
                      "nvl(recoverable_amount,0) - nvl(discounted_amount,0) >= nvl(recovered_amount,0)"

8.  17-May-2009 Bug 7522584
                Issue : Service Tax entered in foreign currency for AR Invoice
                is not converted to Functional Currency
                Fix: Modified the code in the procs populate_inv_cm_references, populate_cm_app
        and populate_receipt_records.
                Added a multipier to the tax amount so as to calulate the tax amount in functional currency.

9.  23-May-2009 Bug 8294236
               Issue: Service Tax Transaction created Fr Exchange Balances on Tax Accounts after Settlement
               Fix: Modified the code in procedures populate_cm_app and populate_receipt_records. Added the call to
               the procedure JAI_RGM_TRX_RECORDING_PKG.exc_gain_loss_accounting.

10.  20/12/2009   Xiao for bug#6773751.
    Issue:
    SERVICE TAX DEBIT ENTRIES ARE NOT UPDATED IN THE SERVICE TAX REGISTER
    Reason:Debit memo is not considered at the time of service tax enhancement
    Fix:
    Changes are done to include to process the debit memos.
     following scenarios are considered:
      1.Credit memo applied to debit memo
      2.Cash Receipt applied to debit memo
      3.Receip unapplication

11. 3-Mar-2010   Bug 9432780
                 Issue - When payment term is not "Immediate" for an AR invoice and a
                 credit memo is applied instead of cash receipt, service tax accounting
                 goes wrong for the 2nd (and later) installment.
                 Fix - In procedure populate_cm_app, the amount to be accounted for the CM
                 is calculated using ratio of (amount applied / total recoverable amount).
                 Total recoverable amount is calculated as sum(recoverable amount - recoverable amount),
                 which gives wrong results for 2nd installment and later.
                 So modified the cursor c_get_cmref_totrd_amt to calculate this amount as
                 simply sum(recoverable amount).

12  4-Apr-2010  Bo Li for Bug9305067
                Replace the old attribute columns of JAI_RGM_TRX_RECORDS with the new meaningful columns


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date         Remarks
Of File                              On Bug/Patchset
jai_rgm_process_ar_taxes_pkg_b.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.0                  4146634       IN60105D2 +                                           Aiyer   27-Jan-2005   4146708 is the release bug
                                     4146708                                                                     for SERVICE/CESS enhancement release
115.1                  4193633                        jai_cmn_rgm_recording_pkg  115.1     Aiyer   23-Feb-2005  Functional dependency due to spec change.

----------------------------------------------------------------------------------------------------------------------------------------------------


********************************************************************************************************************************************************/
AS

/*csahoo for bug#5879769...start*/

lv_service_type_code JAI_PO_LINE_LOCATIONS.service_type_code%TYPE;
ln_organization_id   NUMBER;
ln_location_id       NUMBER;
lv_process_flag      VARCHAR2(15);
lv_process_message   VARCHAR2(4000);

/*csahoo for bug#5879769...end*/

procedure get_regime_info  (    p_regime_code       JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE   ,
                                p_tax_type_code     JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE  ,
                                p_regime_id OUT NOCOPY JAI_RGM_DEFINITIONS.REGIME_ID%TYPE     ,
                                p_error_flag OUT NOCOPY VARCHAR2                       ,
                                p_error_message OUT NOCOPY VARCHAR2
                            )
IS

  -- Start of bug 4089440
  /*
  || Get the regime id based on regime code
  */
  CURSOR c_get_regime_id
  IS
  SELECT
         regime_id
  FROM
         JAI_RGM_DEFINITIONS
  WHERE
         regime_code = p_regime_code;
   /*
   ||Get the meaning for a corresponding lookup_type and lookup_code
   || TBD - Check effectivity for regime end date
   */
   CURSOR c_get_lookup_meaning  ( cp_lookup_type  FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE ,
                                  cp_lookup_code  FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE
                                )
   IS
   SELECT
          meaning
   FROM
          fnd_lookup_values
   WHERE
          lookup_type   =  cp_lookup_type  AND
          lookup_code   =  cp_lookup_code;

   /*
   || Check whether a tax type exists in the regime registrations table for the
   || tax types attached to a invoice tax line.
   */
   CURSOR c_chk_service_tax ( cp_tax_type    JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE ,
                              cp_regime_id   JAI_RGM_DEFINITIONS.REGIME_ID%TYPE
                             )
   IS
   SELECT
          1
   FROM
          JAI_RGM_REGISTRATIONS
   WHERE
          regime_id                = cp_regime_id                                  AND
          upper(registration_type) = upper(jai_constants.regn_type_tax_types)  AND
          upper(attribute_code)    = upper(cp_tax_type);

   lv_exists        VARCHAR2(2)                     ;
   ln_regime_id     JAI_RGM_DEFINITIONS.REGIME_ID%TYPE      ;
   lv_meaning       FND_LOOKUP_VALUES.MEANING%TYPE  ;
   lv_meaning_rgm   FND_LOOKUP_VALUES.MEANING%TYPE  ;

BEGIN

  /*################################################################################################################
  || Initialize the variables
  ################################################################################################################*/
  p_error_flag    := jai_constants.successful ;
  p_error_message := NULL                         ;
  p_regime_id     := NULL                         ;

  /*################################################################################################################
  || Validate Regime Setup Information
  ################################################################################################################*/
  /*
  ||Get the regime id info
  */
  OPEN  c_get_regime_id                   ;
  FETCH c_get_regime_id INTO ln_regime_id ;

  IF c_get_regime_id%NOTFOUND THEN
    /*
    ||As regime has not been defined for this tax type hence error out
    */
    CLOSE c_get_regime_id;

    OPEN  c_get_lookup_meaning   ( cp_lookup_type  => jai_constants.lk_type_tax_type ,
                                   cp_lookup_code  => p_tax_type_code
                                 );
    FETCH  c_get_lookup_meaning INTO lv_meaning;
    CLOSE  c_get_lookup_meaning;
    p_error_flag     := jai_constants.expected_error;
    p_error_message  := 'A regime has to be defined for taxes with tax type as '||lv_meaning;
    return;
  END IF;
  CLOSE c_get_regime_id;



  /*################################################################################################################
  || Validate Regime Registration Setup Information
  ################################################################################################################*/

  /*
  || Check whether a tax type exists in the regime registrations table for the
  || tax types attached to a invoice tax line.
  */
  OPEN c_chk_service_tax ( cp_tax_type   => p_tax_type_code  ,
                           cp_regime_id  => ln_regime_id
                         );
  FETCH c_chk_service_tax INTO lv_exists;
  IF c_chk_service_tax%NOTFOUND THEN
    /*
    ||As regime has not been defined for this tax type hence raise an error.
    */
    CLOSE c_chk_service_tax;
    /*
    || Get the meaning from lookup tables for lookup type TAX_TYPE and the lookup code as the current tax type
    */
    OPEN  c_get_lookup_meaning   ( cp_lookup_type  => jai_constants.lk_type_tax_type ,
                                   cp_lookup_code  => p_tax_type_code
                                 );
    FETCH  c_get_lookup_meaning INTO lv_meaning;
    CLOSE  c_get_lookup_meaning;
    /*
    || Get the meaning from lookup tables for lookup type 'JAI_INDIA_TAX_REGIMES' and the lookup code as 'SERVICE'
    */
    OPEN  c_get_lookup_meaning   ( cp_lookup_type  => jai_constants.lk_type_ind_tax_rgms ,
                                   cp_lookup_code  => p_tax_type_code
                                 );
    FETCH  c_get_lookup_meaning INTO lv_meaning_rgm;
    CLOSE  c_get_lookup_meaning;
    p_error_flag     := jai_constants.expected_error;
    p_error_message  := 'A tax type of '|| lv_meaning ||'should be defined for the regime '||lv_meaning_rgm;
    return;
  END IF;
  CLOSE c_chk_service_tax;

  p_regime_id := ln_regime_id ;

EXCEPTION
  WHEN OTHERS THEN
    p_error_flag     := jai_constants.unexpected_error;
    p_error_message  := 'Unexpected Error Occured in procedure jai_ar_rgm_processing_pkg.get_regime_info - '||substr(sqlerrm,1,300);
END get_regime_info;

procedure get_ar_tax_disc_accnt  ( p_receivable_application_id             AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE   ,
                                   p_org_id                                AR_RECEIVABLES_TRX_ALL.ORG_ID%TYPE                              ,
                                   p_total_disc_amount                     JAI_RGM_TRX_REFS.DISCOUNTED_AMOUNT%TYPE                         ,/*Parameter added for the bug 4193633 */
                                   p_tax_ediscounted OUT NOCOPY AR_RECEIVABLE_APPLICATIONS_ALL.TAX_EDISCOUNTED%TYPE             ,
                                   p_earned_disc_ccid OUT NOCOPY AR_RECEIVABLES_TRX_ALL.CODE_COMBINATION_ID%TYPE                 ,
                                   p_tax_uediscounted OUT NOCOPY AR_RECEIVABLE_APPLICATIONS_ALL.TAX_UEDISCOUNTED%TYPE            ,
                                   p_unearned_disc_ccid OUT NOCOPY AR_RECEIVABLES_TRX_ALL.CODE_COMBINATION_ID%TYPE                 ,
                                   p_process_flag OUT NOCOPY VARCHAR2                                                        ,
                                   p_process_message OUT NOCOPY VARCHAR2
                                 )

/*****************************************************************************************************************************************************************
Created By       : aiyer
Created Date     : 27-jan-2005
Enhancement Bug  : 4146634
Purpose          : Gte the tax earned and Unearned discounts associated with the Receivable application
                   the jai_rgm_trx_refs and jai_rgms_trx_records appropriately.
Called From      : jai_cmn_rgm_recording_pkg.insert_reference

Change History: -
=================
1    20-Feb-2005  aiyer - Bug # 4193633 - File Version# 115.1
   Issue
    The tax earned and unearned discount are not getting apportioned properly of service type of taxes and hence the India - Service Tax concurrent
    ends up in a warning for records with these issues

   Reason:-
    In case of invoices having Service taxes and other type of taxes, the tax earned and unearned discounts should be approtioned across all the type of taxes
    (Both Service and Non Service).
    This apportionment logic was not present initially. This needs to be added

   Fix: -
    Modified the procedure. Did the following :-
    1. Added a extra parameter p_total_disc_amount to the procedure.
    2. used this parameter to apportion the tax earned discount amount and tax unearned discount amount

   Dependency Due To This Bug:
    Dependency exists due to specification change of the current procedure.
    Always sent the following packages together:-

      1. jai_rgm_process_ar_taxes_pkg_s.sql          (115.1)
      2. jai_rgm_process_ar_taxes_pkg_b.sql          (115.1)
      3. jai_rgm_trx_recording_pkg_s.sql version     (115.1)
      4. jai_rgm_trx_recording_pkg_b.sql version     (115.1)


 2.  17/04/2007   Bgowrava for forward porting bug#5989740, 11i BUG#5907436. File Version 120.2
                 ENH: Handling Secondary and Higher Education Cess
                Added a input paramter cp_sh_service_edu_cess to the cursor c_fetch_inv_cm_rec.

 3.     05/06/2007       sacsethi for bug 6109941
                         R12RUP03-ST1: CODE REVIEW COMMENTS FOR ENHANCEMENTS

       Some code was found which missed during fp of bug 5879769

*****************************************************************************************************************************************************************/

IS
  CURSOR cur_get_receivable_app
  IS
  SELECT
         nvl(tax_ediscounted,0)  tax_ediscounted  ,
         nvl(tax_uediscounted,0) tax_uediscounted
  FROM
          ar_receivable_applications_all
  WHERE
          receivable_application_id = p_receivable_application_id  AND
          org_id                    = p_org_id;

   CURSOR cur_get_disc_ccid (cp_type AR_RECEIVABLES_TRX_ALL.TYPE%TYPE,p_lookup_type ar_lookups.lookup_type%type,p_status ar_receivables_trx_all.status%TYPE )--rchandan for bug#4428980
   IS
   SELECT
        code_combination_id
   FROM
        ar_receivables_trx_all  rtrx,
        ar_lookups              lkup
   WHERE
        rtrx.type         = lkup.lookup_code        AND
        lkup.lookup_code  = cp_type                 AND
        lkup.lookup_type  = p_lookup_type           AND   --rchandan for bug#4428980
        org_id            = p_org_id                AND
        status            = p_status;      --rchandan for bug#4428980

  rec_cur_get_receivable_app    CUR_GET_RECEIVABLE_APP%ROWTYPE      ;
  rec_cur_get_disc_ccid       CUR_GET_DISC_CCID%ROWTYPE       ;
  ln_total_rec_disc_amt       JAI_RGM_TRX_REFS.DISCOUNTED_AMOUNT%TYPE ;

BEGIN

 fnd_file.put_line(fnd_file.LOG,'********************* 1 START OF PROCEDURE jai_ar_rgm_processing_pkg.GET_AR_TAX_DISC_ACCNT *********************');

  /*
  || Variable Intialization
  */
  p_process_flag       := jai_constants.successful     ;
  p_process_message    := null                         ;

 fnd_file.put_line(fnd_file.LOG,' 2 Variables Initialised ');

  IF p_total_disc_amount IS NULL THEN
    p_process_flag        := jai_constants.expected_error;
    p_process_message     := 'Service Tax Discounted cannot be NULL ';
    fnd_file.put_line(fnd_file.LOG,' 3 EXPECTED ERROR - Service Tax Discounted amount cannot be NULL ');
    return;
  END IF;

  /*
  || Get the receivable_application Tax Earned and Tax Unearned Discount amounts
  */
  OPEN  cur_get_receivable_app ;
  FETCH cur_get_receivable_app into rec_cur_get_receivable_app ;
  IF CUR_GET_RECEIVABLE_APP%NOTFOUND THEN
    CLOSE cur_get_receivable_app;
    p_process_flag        := jai_constants.expected_error;
    p_process_message     := 'Receivable Application record with the receivable_application_id  -> '||p_receivable_application_id ||' not found ';
    fnd_file.put_line(fnd_file.LOG,' 4 EXPECTED ERROR -Receivable Application record with the receivable_application_id  -> '||p_receivable_application_id ||' not found ');
    return;
  END IF;

  /*
  || Start of 4193633
  || Apportion the discounted tax earned and discounted tax unearned based on the parameter p_total_disc_amount (total discount tax amount
  || applicable all service taxes for a particular invoice
  */
  ln_total_rec_disc_amt := rec_cur_get_receivable_app.tax_ediscounted + rec_cur_get_receivable_app.tax_uediscounted    ;
  --Added by walton for inclusive tax
  -------------------------------------------
  IF nvl(ln_total_rec_disc_amt,0) =0
  THEN
    ln_total_rec_disc_amt:=1;
  END IF;
  ------------------------------------------
  p_tax_ediscounted  := ( rec_cur_get_receivable_app.tax_ediscounted  / ln_total_rec_disc_amt ) *  p_total_disc_amount ;
  p_tax_uediscounted := ( rec_cur_get_receivable_app.tax_uediscounted / ln_total_rec_disc_amt ) *  p_total_disc_amount ;

  /*
  || End of 4193633
  */
 fnd_file.put_line(fnd_file.LOG,' 5 value of p_tax_ediscounted -> '|| p_tax_ediscounted
                                 ||', p_tax_uediscounted -> '   || p_tax_uediscounted
                 ||', ln_total_rec_disc_amt -> '|| ln_total_rec_disc_amt
                 ||', rec_cur_get_receivable_app.tax_ediscounted ->  '||rec_cur_get_receivable_app.tax_ediscounted
                 ||', rec_cur_get_receivable_app.tax_uediscounted -> '||rec_cur_get_receivable_app.tax_uediscounted
           );

  /*
  || Get the code combination id for the Earned Discount Account
  */

  IF rec_cur_get_receivable_app.tax_ediscounted <> 0 THEN

    OPEN  cur_get_disc_ccid ('EDISC','RECEIVABLES_TRX','A');  --rchandan for bug#4428980
    FETCH cur_get_disc_ccid INTO rec_cur_get_disc_ccid;

    IF CUR_GET_DISC_CCID%NOTFOUND THEN
      CLOSE cur_get_receivable_app;
      CLOSE cur_get_disc_ccid;
      p_process_flag        := jai_constants.expected_error  ;
      p_process_message     := 'Earned Discount Account Setup not found in ar_receivables_trx_all ';
      fnd_file.put_line(fnd_file.LOG,' 6 EXPECTED ERROR - Earned Discount Account Setup not found in ar_receivables_trx_all ');
      return;
    END IF;
    p_earned_disc_ccid := rec_cur_get_disc_ccid.code_combination_id ;
    CLOSE cur_get_disc_ccid;
  END IF;

  fnd_file.put_line(fnd_file.LOG,' 6 Earned Discount Account code combination id is  '||rec_cur_get_disc_ccid.code_combination_id);
  /*
  || Get the code combination id for the Unearned Discount Account
  */
  IF rec_cur_get_receivable_app.tax_uediscounted <> 0 THEN

    OPEN  cur_get_disc_ccid ('UNEDISC','RECEIVABLES_TRX','A');   --rchandan for bug#4428980
    FETCH cur_get_disc_ccid INTO rec_cur_get_disc_ccid;

    IF CUR_GET_DISC_CCID%NOTFOUND THEN
      CLOSE cur_get_receivable_app;
      CLOSE cur_get_disc_ccid;
      p_process_flag        := jai_constants.expected_error   ;
      p_process_message     := 'UnEarned Discount Account Setup not found in ar_receivables_trx_all ';
      fnd_file.put_line(fnd_file.LOG,' 8 EXPECTED ERROR - UnEarned Discount Account Setup not found in ar_receivables_trx_all ');
      return;
    END IF;
    p_unearned_disc_ccid := rec_cur_get_disc_ccid.code_combination_id ;
    CLOSE cur_get_disc_ccid;

  END IF;
  fnd_file.put_line(fnd_file.LOG,' 9 Unearned Account CCID is -> '||rec_cur_get_disc_ccid.code_combination_id);
  CLOSE cur_get_receivable_app;
 fnd_file.put_line(fnd_file.LOG,' 10 Value of out variables  p_tax_ediscounted       ->' ||   p_tax_ediscounted
                ||', p_earned_disc_ccid     ->' ||    p_earned_disc_ccid
                ||', p_tax_uediscounted     ->' ||    p_tax_uediscounted
                ||', p_unearned_disc_ccid   ->' ||    p_unearned_disc_ccid
                ||', p_process_flag         ->' ||    p_process_flag
                ||', p_process_message      ->' ||    p_process_message
          );
 fnd_file.put_line(fnd_file.LOG,'********************* 10 END OF PROCEDURE jai_ar_rgm_processing_pkg.GET_AR_TAX_DISC_ACCNT *********************');

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag        := jai_constants.unexpected_error ;
    p_process_message     := 'Unexpeced error occured in procedure get_ar_tax_disc_accnt  for receivable_application_id -> '||p_receivable_application_id ||substr(SQLERRM,1,300);

END get_ar_tax_disc_accnt  ;



procedure populate_inv_cm_references   ( p_regime_id         IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                         p_organization_type IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                         p_from_date         IN  DATE                                        ,
                                         p_to_date           IN  DATE                                        ,
                                         p_org_id            IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                         p_batch_id          IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                         p_source            IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                ,
                                         p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                         p_process_message OUT NOCOPY VARCHAR2,
                                         p_organization_id  IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL
                                       )
IS
  /******************************
  ||Variable Declaration Section
  *******************************/
  ln_reference_id                     JAI_RGM_TRX_REFS.REFERENCE_ID%TYPE                              ;
  lv_process_flag                     VARCHAR2(2)                                                     ;
  lv_process_message                  VARCHAR2(1996)                                                  ;
  ln_invoices_processed               NUMBER(10)                                                      ;

  /******************************
  ||Cursor Declarations Section
  *******************************/

  CURSOR c_fetch_inv_cm_rec  ( cp_invoice_type     varchar2, --File.Sql.35 Cbabu  jai_constants.AR_INVOICE_TYPE_INV%TYPE           ,
                               cp_cm_type          varchar2, --File.Sql.35 Cbabu  jai_constants.AR_INVOICE_TYPE_CM%TYPE            ,
                               cp_dm_type          varchar2, -- Add by Xiao for bug#6773751 on 20-Dec-09
                               cp_service_tax      varchar2, --File.Sql.35 Cbabu  jai_constants.TAX_TYPE_SERVICE%TYPE              ,
                               cp_service_edu_cess varchar2, --File.Sql.35 Cbabu  jai_constants.TAX_TYPE_SERVICE_EDU_CESS%TYPE
                               cp_sh_service_edu_cess  JAI_CONSTANTS.TAX_TYPE_SH_SERVICE_EDU_CESS%TYPE        --Added By Bgowrava for forward porting bug#5989740
                             )
  IS
  SELECT
      trx.customer_trx_id                                                                             ,
      trx.invoice_currency_code                                                                       ,
      trx.exchange_date                                                                               ,
      trx.exchange_rate                                                                               ,
      trx.org_id                                                                                      ,
      trx.cust_trx_type_id                                                                            ,
      trx.previous_customer_trx_id                                                                    ,
      nvl(trx.bill_to_customer_id,trx.ship_to_customer_id) customer_id                                ,
      nvl(trx.bill_to_site_use_id,trx.ship_to_site_use_id) customer_site_id                           ,
      jtc.tax_type                                         tax_type                                   ,
      nvl(decode(upper(trx_types.type),cp_cm_type,'Y','N'),'N')   reversal_flag                       ,
      jtrxl.inventory_item_id                                                                         ,
      jtrxtl.customer_trx_line_id                                                                     ,
      jtrxtl.tax_id                                                                                   ,
      jtrxtl.tax_rate                                                                                 ,
      jtrxtl.tax_amount                                                                               ,
      jtrxtl.func_tax_amount                                                                          ,
      jtrxtl.base_tax_amount                                                                          ,
      decode(upper(trx_types.type),cp_invoice_type,nvl(jtc.mod_cr_percentage,0),100)  mod_cr_percentage      ,
      jtrxtl.link_to_cust_trx_line_id
  FROM
      ra_customer_trx_all          trx                                                                ,
      JAI_AR_TRXS        jtrx                                                               ,
      ra_cust_trx_types_all        trx_types                                                          ,
      JAI_AR_TRX_LINES  jtrxl                                                              ,
      JAI_AR_TRX_TAX_LINES  jtrxtl                                                             ,
      JAI_CMN_TAXES_ALL              jtc
  WHERE
      trx.org_id                   = nvl(p_org_id,trx.org_id)                                         AND
      trx.complete_flag            ='Y'                                                               AND
      trx.customer_trx_id          = jtrx.customer_trx_id                                             AND
      jtrx.organization_id         = p_organization_id                                                AND/*5879769*/
     /* nvl(jtrx.tax_amount,0)       <> 0                                                               AND *//*Safeguard against invoice tax amount being null or zero and service type of taxes still existing at tax level */
     /*trunc(trx.creation_date)*/ trunc(trx.trx_date)    BETWEEN trunc(p_from_date) and trunc(p_to_date) AND /*Commented by nprashar for bug # 6997453*/
      upper(trx_types.type)        IN (cp_invoice_type,cp_cm_type,cp_dm_type)                         AND -- Add by Xiao for bug#6773751 on 20-Dec-09
      trx_types.cust_trx_type_id   = trx.cust_trx_type_id                                             AND
      trx_types.org_id             = trx.org_id                                                       AND
      jtrx.customer_trx_id         = jtrxl.customer_trx_id                                            AND
      jtrxl.customer_trx_line_id   = jtrxtl.link_to_cust_trx_line_id                                  AND
      jtrxtl.tax_id                = jtc.tax_id                                                       AND
      upper(jtc.tax_type)          IN ( cp_service_tax,cp_service_edu_cess ,cp_sh_service_edu_cess)   AND      -- cp_sh_service_edu_cess Bgowrava for forward porting bug#5989740                       AND
      (  /**** Check that in case of INV mod_Cr_percentage should be > 0 and no check in case of CM ****/
        (
          upper(trx_types.type)    = cp_cm_type
        )                                                                                             OR
        (
          upper(trx_types.type)    = cp_invoice_type                                                  AND
          nvl(jtc.mod_cr_percentage,0) > 0
        )                                                                                       OR
   /* Added by Xiao for bug#6773751 */
        (
          upper(trx_types.type)    = cp_dm_type
        )
      )                                                                                              AND
      NOT EXISTS                   ( SELECT  /*A ref of invoice/cm should not exist in the reference table */
                                             1
                                     FROM    jai_rgm_trx_refs  rgtr
                                     WHERE
                                             rgtr.source       = p_source                             AND
                                             rgtr.invoice_id   = trx.customer_trx_id                  AND
                                             rgtr.line_id      = jtrxtl.customer_trx_line_id          AND
                                             rgtr.item_line_id = jtrxtl.link_to_cust_trx_line_id      AND
                                             rgtr.tax_id       = jtrxtl.tax_id
                                   )
  ORDER BY
            trx_types.type desc;

BEGIN


  /*****
  ||Based on the input parameters get invoice details
  ||for which localization has corresponding service tax
  ******/

  fnd_file.put_line(fnd_file.LOG,'1 Entering procedure : jai_ar_rgm_processing_pkg.populate_inv_cm_references' );

fnd_file.put_line(fnd_file.LOG,'p_org_id:'||p_org_id );
  fnd_file.put_line(fnd_file.LOG,'p_organization_id:'||p_organization_id );

  /*
  || Variable Initialization
  */

  lv_process_flag       := jai_constants.successful  ;
  lv_process_message    := NULL                      ;

  p_process_flag        := lv_process_flag           ;
  p_process_message     := lv_process_message        ;

  ln_invoices_processed := 0                         ;

  FOR  rec_c_fetch_inv_cm_rec IN c_fetch_inv_cm_rec ( cp_invoice_type     => upper(jai_constants.ar_invoice_type_inv)           ,
                                                      cp_cm_type          => upper(jai_constants.ar_invoice_type_cm)            ,
                                                      cp_dm_type          => upper(jai_constants.ar_doc_type_dm)            , --Added by Xiao for bug#6773751
                                                      cp_service_tax      => upper(jai_constants.tax_type_service)              ,
                                                      cp_service_edu_cess => upper(jai_constants.tax_type_service_edu_cess),
                                                      cp_sh_service_edu_cess   => upper(jai_constants.tax_type_sh_service_edu_cess)        --Added by Bgowrava for forward porting bug#5989740
                                                     )
  LOOP

    fnd_file.put_line(fnd_file.LOG,'2 processing record, customer_trx_id '||rec_c_fetch_inv_cm_rec.customer_trx_id
                      ||', invoice line id '||rec_c_fetch_inv_cm_rec.link_to_cust_trx_line_id
                      ||', tax line id '||rec_c_fetch_inv_cm_rec.customer_trx_line_id
                      ||', tax_id '||   rec_c_fetch_inv_cm_rec.tax_id
                      ||', tax rate '||rec_c_fetch_inv_cm_rec.tax_rate
                      ||', transactional tax amount '||rec_c_fetch_inv_cm_rec.tax_amount
                      ||', functional tax amount '||rec_c_fetch_inv_cm_rec.func_tax_amount
                      ||', currency '||rec_c_fetch_inv_cm_rec.invoice_currency_code
                      ||', recoverable percentage '||rec_c_fetch_inv_cm_rec.mod_cr_percentage
                      ||', recoverable_amount '||rec_c_fetch_inv_cm_rec.tax_amount * (rec_c_fetch_inv_cm_rec.mod_cr_percentage/100)
                     );

    /****
    ||insert the invoices and credit memo's into the jai_rgm_trx_refs
    ||using the procedure jai_cmn_rgm_recording_pkg.insert_reference
    *****/
    fnd_file.put_line(fnd_file.LOG,'3 before call to procedure jai_cmn_rgm_recording_pkg.insert_reference ');

    savepoint before_ref_inv_cm;

    jai_cmn_rgm_recording_pkg.insert_reference (
                                                   p_reference_id           =>    ln_reference_id                                                                         ,
                                                   p_organization_id        =>    p_organization_id                                                                       ,/*5879769*/
                                                   p_source                 =>    p_source                                                                                ,
                                                   p_invoice_id             =>    rec_c_fetch_inv_cm_rec.customer_trx_id                                                  ,
                                                   p_line_id                =>    rec_c_fetch_inv_cm_rec.customer_trx_line_id                                             ,
                                                   p_tax_type               =>    rec_c_fetch_inv_cm_rec.tax_type                                                         ,
                                                   p_tax_id                 =>    rec_c_fetch_inv_cm_rec.tax_id                                                           ,
                                                   p_tax_rate               =>    rec_c_fetch_inv_cm_rec.tax_rate                                                         ,
                                                   p_recoverable_ptg        =>    rec_c_fetch_inv_cm_rec.mod_cr_percentage                                                ,
                                                   p_party_type             =>    jai_constants.party_type_customer                                                       ,
                                                   p_party_id               =>    rec_c_fetch_inv_cm_rec.customer_id                                                      ,
                                                   p_party_site_id          =>    rec_c_fetch_inv_cm_rec.customer_site_id                                                 ,
                                                   p_trx_tax_amount         =>    rec_c_fetch_inv_cm_rec.tax_amount                                                       ,
                                                   p_trx_currency           =>    rec_c_fetch_inv_cm_rec.invoice_currency_code                                            ,
                                                   p_curr_conv_date         =>    rec_c_fetch_inv_cm_rec.exchange_date                                                    ,
                                                   p_curr_conv_rate         =>    rec_c_fetch_inv_cm_rec.exchange_rate                                                    ,
                           -- Replaced tax_amount by func_tax_amount for Bug 7522584
                                                   p_tax_amount             =>    rec_c_fetch_inv_cm_rec.func_tax_amount * (rec_c_fetch_inv_cm_rec.mod_cr_percentage/100) ,
                                                   p_recoverable_amount     =>    rec_c_fetch_inv_cm_rec.tax_amount * (rec_c_fetch_inv_cm_rec.mod_cr_percentage/100)      ,
                                                   p_recovered_amount       =>    0                                                                                       ,
                                                   p_item_line_id           =>    rec_c_fetch_inv_cm_rec.link_to_cust_trx_line_id                                         ,
                                                   p_item_id                =>    rec_c_fetch_inv_cm_rec.inventory_item_id                                                ,
                                                   p_taxable_basis          =>    rec_c_fetch_inv_cm_rec.base_tax_amount                                                  ,
                                                   p_parent_reference_id    =>    NULL                                                                                    ,
                                                   p_reversal_flag          =>    rec_c_fetch_inv_cm_rec.reversal_flag                                                    ,
                                                   p_batch_id               =>    p_batch_id                                                                              ,
                                                   p_process_flag           =>    lv_process_flag                                                                         ,
                                                   p_process_message        =>    lv_process_message
                                               );

    fnd_file.put_line(fnd_file.LOG,'4 returned from procedure jai_cmn_rgm_recording_pkg.insert_reference, lv_process_flag - '||lv_process_flag
                                   ||'lv_process_message - '||lv_process_message);


      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        /*
        || as Returned status is an error hence:-
        ||1. Rollback to save point
        ||2. Set out variables p_process_flag and p_process_message accordingly
        */
        ROLLBACK to before_ref_inv_cm;
        fnd_file.put_line( fnd_file.log, '5 error in call to jai_cmn_rgm_recording_pkg.insert_reference - lv_process_flag '||lv_process_flag
                                          ||', lv_process_message'||lv_process_message);
        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
      END IF;

    ln_invoices_processed := ln_invoices_processed   + 1;
    fnd_file.put_line(fnd_file.LOG,'6 inserted record in jai_rgm_trx_refs with reference_id '||ln_reference_id  );

  END LOOP;

  fnd_file.put_line(fnd_file.LOG,'5 End of procedure : jai_rgm_process_ar.populate_inv_cm_references, number of invoices/CM processed '||ln_invoices_processed );

EXCEPTION
  WHEN OTHERS THEN

    lv_process_flag    := jai_constants.unexpected_error;
    lv_process_message := 'Unexpected error occured while processing jai_ar_rgm_processing_pkg.populate_inv_cm_references'||substr(SQLERRM,1,500) ;
    ROLLBACK to before_ref_inv_cm;

END populate_inv_cm_references;

procedure delete_non_existant_cm ( p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                   p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                   p_from_date          IN  DATE                                        ,
                                   p_to_date            IN  DATE                                        ,
                                   p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                   p_source             IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                ,
                                   p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                   p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                   p_process_message OUT NOCOPY VARCHAR2
                                 ,p_organization_id    JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL)
IS

  ln_eff_cm_tax_amount              AR_RECEIVABLE_APPLICATIONS_ALL.TAX_APPLIED%TYPE                 ;
  ln_repository_id                  JAI_RGM_TRX_RECORDS.REPOSITORY_ID%TYPE                          ;
  ln_amount                         JAI_RGM_TRX_RECORDS.DEBIT_AMOUNT%TYPE                           ;
  ln_discounted_amount              JAI_RGM_TRX_REFS.DISCOUNTED_AMOUNT%TYPE                         ;
  ln_err_cm_customer_trx_id         JAI_RGM_TRX_REFS.INVOICE_ID%TYPE                                ;
  ln_set_save_point                 JAI_RGM_TRX_REFS.INVOICE_ID%TYPE                                ;
  lv_process_flag                   VARCHAR2(2)                                                     ;
  lv_process_message                VARCHAR2(1996)                                                  ;
  lv_source_trx_type                VARCHAR2(50)                                                    ;
  ln_uncommitted_transactions       NUMBER(10)                                    := 0              ;
  lv_attribute_context              jai_rgm_trx_records.attribute_context%TYPE ; --rchandan for bug#4428980
  lv_source_table                   jai_rgm_trx_records.source_table_name%TYPE ;  --rchandan for bug#4428980

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_ar_rgm_processing_pkg.delete_non_existant_cm';

  /*
  || Get all the cm's which exist in the reference table jai_rgm_trx_refs and have been incompleted/incompleted and deleted from AR base table
  || IF a CM has been incompleted then it would exist with complete_flag = 'N' . if a CM has been incompleted and deleted then it would not exist
  || in the ra_customer_trx_all table.
  */
  CURSOR c_get_incompleted_cm
  IS
  SELECT
         rgtr.invoice_id    cm_customer_trx_id /*,
         rgtr.reference_id  cm_reference_id    */
  FROM
         jai_rgm_trx_refs rgtr
  WHERE
         rgtr.source          = p_source    AND
         rgtr.organization_id     = p_organization_id      AND /*5879769*/
         rgtr.reversal_flag       = 'Y'         AND
     nvl(rgtr.recovered_amount,0)   <> 0          AND
         NOT EXISTS ( SELECT
                                1
                      FROM
                                ra_customer_trx_all          trx       ,
                                ra_cust_trx_types_all        trx_types
                      WHERE
                                trx.customer_trx_id          = rgtr.invoice_id                          AND
                                trx_types.cust_trx_type_id   = trx.cust_trx_type_id                     AND
                                trx_types.org_id             = trx.org_id                               AND
                                upper(trx_types.type)        = upper(jai_constants.ar_invoice_type_cm)  AND
                                trx.complete_flag            = 'Y'
                    )
  GROUP BY
           rgtr.invoice_id;
  /*
  || Get all the data of the incompleted CM from the
  || repository, so that the same record with an exactly opposite amount can be passed. This would be the CM-CM-REV record
  */
  CURSOR c_get_cm_cm_app_rec ( /*cp_cm_reference_id       JAI_RGM_TRX_RECORDS.REFERENCE_ID%TYPE ,*/
                               cp_cm_customer_trx_id    JAI_RGM_TRX_REFS.INVOICE_ID%TYPE,
             cp_attribute_context     jai_rgm_trx_records.trx_reference_context%TYPE  --rchandan for bug#4428980 --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                             )
  IS
  SELECT
         *
  FROM
         jai_rgm_trx_records
  WHERE
         trx_reference_context =  cp_attribute_context                   AND --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
         trx_reference2        =  cp_cm_customer_trx_id    --Bo Li for Bug9305067 change attribute2 to trx_reference2
         /*  AND reference_id      =  cp_cm_reference_id    */;

  /*
  || Update all the credit memo reference records.
  */
  CURSOR cur_upd_cm_ref ( cp_cm_customer_trx_id  JAI_RGM_TRX_REFS.INVOICE_ID%TYPE )
  IS
  SELECT
     *
  FROM
         jai_rgm_trx_refs
  WHERE
     invoice_id                     = cp_cm_customer_trx_id AND
     nvl(recovered_amount,0)   <> 0       ;

  /*
  || Get all the data of the CM applied to invoices (i.e CM-INV-APP) from the repository.
  || So that the same record with an exactly opposite amount can be passed. This would be the new CM-INV-REV record
  */
  CURSOR c_get_cm_inv_app_rec ( cp_cm_customer_trx_id  JAI_RGM_TRX_REFS.INVOICE_ID%TYPE
                               -- cp_attribute_context     jai_rgm_trx_records.attribute_context%TYPE ) --Commented by Xiao for bug#6773751
                               )
  IS
  SELECT
         *
  FROM
         jai_rgm_trx_records
  WHERE
         --attribute_context = cp_attribute_context   AND
         trx_reference_context in ('CM-INV-APP','CM-DM-APP')           AND  --added CM-DM-APP by Xiao for bug#6773751--Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
         trx_reference2        = cp_cm_customer_trx_id ; --Bo Li for Bug9305067 change attribute2 to trx_reference2

BEGIN

  /*
  || Variable Intialization
  */
  lv_process_flag       := jai_constants.successful     ;
  lv_process_message    := null                         ;

  p_process_flag        := lv_process_flag              ;
  p_process_message     := lv_process_message           ;

fnd_file.put_line(fnd_file.LOG,'delete_non_existant_cm p_org_id:'||p_org_id );
  fnd_file.put_line(fnd_file.LOG,'p_organization_id:'||p_organization_id );

/*
  || Source type would indicate CREDIT MEMO REVERSAL
  */
  lv_source_trx_type := jai_constants.trx_type_cm_rvs ;

  /*
  || Update all the credit memo from reference, reset recovered_amount = 0
  || Insert repository records ('CM-CM-APP') corresponding to the above effect
  */
  FOR rec_c_get_incompleted_cm IN c_get_incompleted_cm
  LOOP

    /*########################################################################################################
    || SET SAVE POINT POINT FOR EACH CM_CUSTOMER_TRX_ID RECORD
    ########################################################################################################*/
      fnd_file.put_line(fnd_file.LOG,' ********************1 PROCESSING REC_C_GET_INCOMPLETED_CM.CM_CUSTOMER_TRX_ID -> '||rec_c_get_incompleted_cm.cm_customer_trx_id
                      ||' ******************** ');


    /*
    || Set the savepoint at the begin of processing every new cm_customer_trx_id from jai_rgm_refs table
    || IF an error occurs while processing any reference record of a cm_customer_trx_id then the rollback
    || can be done for all the records of that cm_customer_trx_id
    */
    savepoint roll_to_last_cm;



    /*########################################################################################################
    || PASS CM-CM-REV RECORD ENTRIES IN REPOSITORY AND UPDATE THE CM REFERENCES
    || Insert Credit Memo repository entries to the effect of the CM incompletion.
    || This record would be exactly opposite of the earlier CM creation repository record
    ########################################################################################################*/


    IF nvl(ln_err_cm_customer_trx_id,-1) <> nvl(rec_c_get_incompleted_cm.cm_customer_trx_id,-1) THEN

      FOR  rec_c_get_cm_cm_app_rec IN c_get_cm_cm_app_rec   ( /*cp_cm_reference_id     => rec_c_get_incompleted_cm.cm_reference_id    ,*/
                                                              cp_cm_customer_trx_id  => rec_c_get_incompleted_cm.cm_customer_trx_id,
                    cp_attribute_context   => 'CM-CM-APP'
                                                            ) --rchandan for bug#4428980
      LOOP

        /*
        || Insert a record into the repository corresponding to the 'CM-CM-REV'
        */
        fnd_file.put_line(fnd_file.LOG,' 3 Passing CM-CM-REV record, for the CM-CM-APP with rec_c_get_cm_cm_app_rec.cm_customer_trx_id -> '||rec_c_get_cm_cm_app_rec.trx_reference2 --Bo Li for Bug9305067 change attribute2 to trx_reference2
                                         ||' and reference_id -> '||rec_c_get_cm_cm_app_rec.reference_id
                                         ||',repository_id -> '|| rec_c_get_cm_cm_app_rec.repository_id);



        ln_amount := nvl(rec_c_get_cm_cm_app_rec.debit_amount,rec_c_get_cm_cm_app_rec.credit_amount) * (-1);

        fnd_file.put_line(fnd_file.LOG,' 3.1 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry original amount -> '||nvl(rec_c_get_cm_cm_app_rec.debit_amount,rec_c_get_cm_cm_app_rec.credit_amount)
                                       ||', reversal entry amount -> '||ln_amount       );

        /*csahoo for bug#5879769...start*/

        ln_organization_id   := NULL;
        ln_location_id       := NULL;
        lv_service_type_code := NULL;
        lv_process_flag      := NULL;
        lv_process_message   := NULL;

        jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => rec_c_get_cm_cm_app_rec.reference_id,
                                                        p_organization_id   => ln_organization_id,
                                                        p_location_id       => ln_location_id,
                                                        p_service_type_code => lv_service_type_code,
                                                        p_process_flag      => lv_process_flag,
                                                        p_process_message   => lv_process_message
                                                        );

         IF  lv_process_flag <> jai_constants.successful THEN
           FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
           return;
         END IF;

        /*csahoo for bug#5879769...end*/

        lv_attribute_context  := 'CM-CM-REV'; --rchandan for bug#4428980

        jai_cmn_rgm_recording_pkg.insert_repository_entry (
                                                            p_repository_id              => ln_repository_id                                                                                  ,
                                                            p_regime_id                  => p_regime_id                                                                                       ,
                                                            p_tax_type                   => rec_c_get_cm_cm_app_rec.tax_type                                                                  ,
                                                            p_organization_type          => p_organization_type                                                                               ,
                                                            p_organization_id            => p_organization_id                                                                                  ,/*5879769*/
                                                            p_location_id                => ln_location_id                                                                                     ,/*5879769*/
                                                            p_service_type_code          => lv_service_type_code                                                                               ,/*5879769*/
                                                            p_source                     => p_source                                                                                          ,
                                                            p_source_trx_type            => lv_source_trx_type                                                                                ,
                                                            p_source_table_name          => UPPER(jai_constants.repository_name)                                                              ,
                                                            p_source_document_id         => rec_c_get_cm_cm_app_rec.repository_id                                                             ,
                                                            p_transaction_date           => rec_c_get_cm_cm_app_rec.creation_date                                                             ,
                                                            p_account_name               => NULL                                                                                              ,
                                                            p_charge_account_id          => NULL                                                                                              ,
                                                            p_balancing_account_id       => NULL                                                                                              ,
                                                            p_amount                     => ln_amount                                                                                         ,
                                                            p_assessable_value           => NULL                                                                                              ,
                                                            p_tax_rate                   => rec_c_get_cm_cm_app_rec.tax_rate                                                                  ,
                                                            p_reference_id               => rec_c_get_cm_cm_app_rec.reference_id                                                              ,
                                                            p_batch_id                   => p_batch_id                                                                                        ,
                                                            p_called_from                => lv_object_name                                                                                    , --rchandan for bug#4428980
                                                            p_process_flag               => lv_process_flag                                                                                   ,
                                                            p_process_message            => lv_process_message                                                                                ,
                                                            p_discounted_amount          => ln_discounted_amount                                                                              ,
                                                            p_inv_organization_id        => rec_c_get_cm_cm_app_rec.inv_organization_id                                                       ,
                                                            p_accounting_date            => sysdate                                                                                           ,
                                                            p_currency_code              => rec_c_get_cm_cm_app_rec.trx_currency                                                              ,
                                                            p_curr_conv_date             => rec_c_get_cm_cm_app_rec.curr_conv_date                                                            ,
                                                            p_curr_conv_type             => NULL                                                                                              ,
                                                            p_curr_conv_rate             => rec_c_get_cm_cm_app_rec.curr_conv_rate                                                            ,
                                                            p_trx_amount                 => ln_amount                                                                                         ,
                                                            --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                                                            -- attribute2 to trx_reference2
                                                            -----------------------------------------------------------------------------                                                                                    ,
                                                            p_trx_reference_context          => lv_attribute_context                                                                              ,
                                                            p_trx_reference2                 => rec_c_get_incompleted_cm.cm_customer_trx_id
                                                            ---------------------------------------------------------------------------------
                                                            , p_accntg_required_flag    => jai_constants.yes --File.Sql.35 Cbabu
                                                          );

        fnd_file.put_line(fnd_file.LOG,' 4 Returned from jai_cmn_rgm_recording_pkg.insert_repository_entry ' );


        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || as Returned status is an error hence:-
          ||1. set the ln_err_cm_customer_trx_id to the cm_customer_Trx_id which errored out
          ||2. Rollback to save point
          ||3. Set out variables p_process_flag and p_process_message accordingly
          ||4. Exit from the loop
          */
          ln_err_cm_customer_trx_id := rec_c_get_incompleted_cm.cm_customer_trx_id;
          ROLLBACK to roll_to_last_cm;
          fnd_file.put_line( fnd_file.log, '5 error in call to jai_cmn_rgm_recording_pkg.insert_repository_entry - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message ||'cm_customer_trx_id -  '||ln_err_cm_customer_trx_id);
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          EXIT;
        END IF;

      END LOOP; /*End of 'CM-CM-REV' record processing for an incompleted CM*/
    END IF;     /* End if of ln_err_cm_customer_trx_id <> rec_c_get_incompleted_cm.cm_customer_trx_id*/

    IF nvl(ln_err_cm_customer_trx_id,-1) <> nvl(rec_c_get_incompleted_cm.cm_customer_trx_id,-1) THEN

      /*########################################################################################################
      || Update the Credit Reference and set Recovered Amount to 0 as this credit memo has been incompleted
      ########################################################################################################*/
    FOR rec_cur_upd_cm_ref IN cur_upd_cm_ref (cp_cm_customer_trx_id  => rec_c_get_incompleted_cm.cm_customer_trx_id)
    LOOP
        fnd_file.put_line(fnd_file.LOG,' 6 before call to jai_cmn_rgm_recording_pkg.update_reference for updating CM reference to 0-> '||rec_c_get_incompleted_cm.cm_customer_trx_id
                                     ||', reference_id -> '||rec_cur_upd_cm_ref.reference_id );

        jai_cmn_rgm_recording_pkg.update_reference (
                                                     p_source             => p_source                                        ,
                                                     p_reference_id       => rec_cur_upd_cm_ref.reference_id                 ,
                                                     p_recovered_amount   => rec_cur_upd_cm_ref.recovered_amount * (-1)      ,
                                                     p_process_flag       => lv_process_flag                                 ,
                                                     p_process_message    => lv_process_message
                                                   );
        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || as Returned status is an error hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          ln_err_cm_customer_trx_id := rec_c_get_incompleted_cm.cm_customer_trx_id;
          ROLLBACK to roll_to_last_cm;
          fnd_file.put_line( fnd_file.log, '7 error in call to jai_cmn_rgm_recording_pkg.update_reference - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message);
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
        END IF;

        fnd_file.put_line(fnd_file.LOG,' 8 Returned from jai_cmn_rgm_recording_pkg.update_reference after updating CM reference' );
    END LOOP;

    END IF; /* End if of ln_err_cm_customer_trx_id <> rec_c_get_incompleted_cm.cm_customer_trx_id*/


    /*########################################################################################################
    || PASS CM-INV-REV ENTRIES , UPDATE INV REFERENCES
    || Reverse CM application to invoices into repository entries to the effect of the CM incompletion.
    || This record would be exactly opposite of the earlier CM creation repository record
    ########################################################################################################*/
    IF nvl(ln_err_cm_customer_trx_id,-1) <> nvl(rec_c_get_incompleted_cm.cm_customer_trx_id,-1) THEN

      FOR  rec_c_get_cm_inv_app_rec IN c_get_cm_inv_app_rec ( cp_cm_customer_trx_id  => rec_c_get_incompleted_cm.cm_customer_trx_id
                                                              --, cp_attribute_context   => 'CM-INV-APP'
                                                              )
      LOOP

        fnd_file.put_line(fnd_file.LOG,' 9 Passing CM-INV-REV record, for the CM-INV-APP with rec_c_get_cm_inv_app_rec.inv_customer_trx_id -> '||rec_c_get_cm_inv_app_rec.attribute1
                                         ||', rec_c_get_cm_inv_app_rec.cm_customer_trx_id -> '||rec_c_get_cm_inv_app_rec.attribute2
                                         ||'  reference_id -> '||rec_c_get_cm_inv_app_rec.reference_id
                                         ||', repository_id -> '|| rec_c_get_cm_inv_app_rec.repository_id);

        /*
        || Insert a record into the repository corresponding to the 'CM-CM-REV'
        */
        fnd_file.put_line(fnd_file.LOG,' 9.1 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry ' );

        ln_amount := nvl(rec_c_get_cm_inv_app_rec.debit_amount,rec_c_get_cm_inv_app_rec.credit_amount) * (-1);

        fnd_file.put_line(fnd_file.LOG,' 10 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry original amount -> '||nvl(rec_c_get_cm_inv_app_rec.debit_amount,rec_c_get_cm_inv_app_rec.credit_amount)
                                       ||', reversal entry amount -> '||ln_amount       );

        /*csahoo for bug#5879769...start*/

        ln_organization_id   := NULL;
        ln_location_id       := NULL;
        lv_service_type_code := NULL;
        lv_process_flag      := NULL;
        lv_process_message   := NULL;

        jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => rec_c_get_cm_inv_app_rec.reference_id,
                                                        p_organization_id   => ln_organization_id,
                                                        p_location_id       => ln_location_id,
                                                        p_service_type_code => lv_service_type_code,
                                                        p_process_flag      => lv_process_flag,
                                                        p_process_message   => lv_process_message
                                                        );

         IF  lv_process_flag <> jai_constants.successful THEN
           FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
           return;
         END IF;

        /*csahoo for bug#5879769...end*/
    /*added by Xiao for bug#6773751*/
      lv_attribute_context:=null;
    if rec_c_get_cm_inv_app_rec.attribute_context='CM-INV-APP' then
       lv_attribute_context:='CM-INV-REV'    ;
    else
       lv_attribute_context:='CM-DM-REV'    ;
    end if;
     --end added by Xiao for bug#6773751


        --lv_attribute_context := 'CM-INV-REV'; --rchandan for bug#4428980  -- commented by Xiao for bug#6773751
  lv_source_table      := 'JAI_RGM_TRX_RECORDS'; --rchandan for bug#4428980
        jai_cmn_rgm_recording_pkg.insert_repository_entry (
                                                            p_repository_id              => ln_repository_id                                                                                  ,
                                                            p_regime_id                  => p_regime_id                                                                                       ,
                                                            p_tax_type                   => rec_c_get_cm_inv_app_rec.tax_type                                                                  ,
                                                            p_organization_type          => p_organization_type                                                                               ,
p_organization_id            => ln_organization_id                                                                                 ,/*5879769*/
p_location_id                => ln_location_id                                                                                    ,/*5879769*/
                                                            p_service_type_code          => lv_service_type_code                                                                              ,/*5879769*/
                                                            p_source                     => p_source                                                                                          ,
                                                            p_source_trx_type            => lv_source_trx_type                                                                                ,
                                                            p_source_table_name          => lv_source_table                                                                                   , --rchandan for bug#4428980
                                                            p_source_document_id         => rec_c_get_cm_inv_app_rec.repository_id                                                            ,
                                                            p_transaction_date           => rec_c_get_cm_inv_app_rec.creation_date                                                            ,
                                                            p_account_name               => NULL                                                                                              ,
                                                            p_charge_account_id          => NULL                                                                                              ,
                                                            p_balancing_account_id       => NULL                                                                                              ,
                                                            p_amount                     => ln_amount                                                                                         ,
                                                            p_assessable_value           => NULL                                                                                              ,
                                                            p_tax_rate                   => rec_c_get_cm_inv_app_rec.tax_rate                                                                 ,
                                                            p_reference_id               => rec_c_get_cm_inv_app_rec.reference_id                                                             ,
                                                            p_batch_id                   => p_batch_id                                                                                        ,
                                                            p_called_from                => lv_object_name                                                                                    ,
                                                            p_process_flag               => lv_process_flag                                                                                   ,
                                                            p_process_message            => lv_process_message                                                                                ,
                                                            p_discounted_amount          => ln_discounted_amount                                                                              ,
                                                            p_inv_organization_id        => rec_c_get_cm_inv_app_rec.inv_organization_id                                                      ,
                                                            p_accounting_date            => sysdate                                                                                           ,
                                                            p_currency_code              => rec_c_get_cm_inv_app_rec.trx_currency                                                             ,
                                                            p_curr_conv_date             => rec_c_get_cm_inv_app_rec.curr_conv_date                                                           ,
                                                            p_curr_conv_type             => NULL                                                                                              ,
                                                            p_curr_conv_rate             => rec_c_get_cm_inv_app_rec.curr_conv_rate                                                           ,
                                                            p_trx_amount                 => ln_amount                                                                                         ,
                                                            --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                                                            -- attribute1 to trx_reference1 and attribute2 to trx_reference2
                                                            -----------------------------------------------------------------------------                                                 , --rchandan for bug#4428980
                                                            p_trx_reference_context          => lv_attribute_context                                                                              ,
                                                            p_trx_reference1                 => rec_c_get_cm_inv_app_rec.trx_reference1                                                               ,
                                                            p_trx_reference2                 => rec_c_get_cm_inv_app_rec.trx_reference2
                                                            ---------------------------------------------------------------------------
                                                            , p_accntg_required_flag    => jai_constants.yes --File.Sql.35 Cbabu
                                                          );

        fnd_file.put_line(fnd_file.LOG,' 10.1 Returned from jai_cmn_rgm_recording_pkg.insert_repository_entry ' );


        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || as Returned status is an error hence:-
          ||1. Rollback to save point
          ||2. Set out variables p_process_flag and p_process_message accordingly
          */
          ln_err_cm_customer_trx_id := rec_c_get_incompleted_cm.cm_customer_trx_id;
          ROLLBACK to roll_to_last_cm;
          fnd_file.put_line( fnd_file.log, '11 error in call to jai_cmn_rgm_recording_pkg.insert_repository_entry - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message);
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          EXIT;
        END IF;


        /*########################################################################################################
        || Update the Recovered Amount of the Invoice Reference against the CM application
        ########################################################################################################*/

        fnd_file.put_line(fnd_file.LOG,' 12 before call to jai_cmn_rgm_recording_pkg.update_reference for updating INV reference_id - '||rec_c_get_cm_inv_app_rec.reference_id
                                        ||', amount to be adjusted from recovered_Amount -> '||nvl(rec_c_get_cm_inv_app_rec.debit_amount,rec_c_get_cm_inv_app_rec.credit_amount) * (-1)
                          );


        jai_cmn_rgm_recording_pkg.update_reference (
                                                     p_source             => p_source                                                                                 ,
                                                     p_reference_id       => rec_c_get_cm_inv_app_rec.reference_id                                                    ,
                                                     p_recovered_amount   => ln_amount                                                                                ,
                                                     p_process_flag       => lv_process_flag                                                                          ,
                                                     p_process_message    => lv_process_message
                                                   );
        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || as Returned status is an error hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          ln_err_cm_customer_trx_id := rec_c_get_incompleted_cm.cm_customer_trx_id;
          ROLLBACK to roll_to_last_cm;
          fnd_file.put_line( fnd_file.log, '13 error in call to jai_cmn_rgm_recording_pkg.update_reference - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message);
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          EXIT;
        END IF;

        fnd_file.put_line(fnd_file.LOG,' 14 Returned from jai_cmn_rgm_recording_pkg.update_reference after updating invoice reference' );

      END LOOP; /* End of 'CM-INV-APP record processing for an CM application against an invoice' */

    END IF; /* End if of ln_err_cm_customer_trx_id <> rec_c_get_incompleted_cm.cm_customer_trx_id*/

    /*
    || Reset the savepoint to the previous cm_customer_trx_id
    ln_set_save_point := rec_c_get_incompleted_cm.cm_customer_trx_id;
  */
    fnd_file.put_line(fnd_file.LOG,' 15 ******************** END of one CM processing ******************** ');
  END LOOP;    /* End of CM reference processing */


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      p_process_flag := null;
      p_process_message  := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END delete_non_existant_cm;



procedure populate_cm_app   ( p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                              p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                              p_from_date          IN  DATE                                        ,
                              p_to_date            IN  DATE                                        ,
                              p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                              p_source             IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                ,
                              p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                              p_process_flag OUT NOCOPY VARCHAR2                                    ,
                              p_process_message OUT NOCOPY VARCHAR2
                         ,  p_organization_id   JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL )
IS

  ln_eff_cm_tax_amount              AR_RECEIVABLE_APPLICATIONS_ALL.TAX_APPLIED%TYPE                                       ;
  ln_discounted_amount              JAI_RGM_TRX_REFS.DISCOUNTED_AMOUNT%TYPE                                               ;
  ln_cm_ref_upd                     JAI_RGM_TRX_REFS.RECOVERED_AMOUNT%TYPE                                                ;
  ln_repository_id                  JAI_RGM_TRX_RECORDS.REPOSITORY_ID%TYPE                                                ;
  lv_source_trx_type                VARCHAR2(50)                                                                          ;
  ln_eff_cm_tottax_amt              JAI_RGM_TRX_REFS.RECOVERABLE_AMOUNT%TYPE                                              ;
  ln_tot_effcm_rb_amt               JAI_RGM_TRX_REFS.RECOVERABLE_AMOUNT%TYPE                                              ;
  ln_inv_tot_tax_amt                JAI_AR_TRX_TAX_LINES.TAX_AMOUNT%TYPE                                           ;
  ln_sign_of_credit_memo            NUMBER                                                                                ;
  ln_cm_ref_ratio                   NUMBER                                                                                ;
  ln_amount                         JAI_RGM_TRX_RECORDS.DEBIT_AMOUNT%TYPE                                                 ;
  -- Added ln_func_amount for Bug 7522584
  ln_func_amount                    JAI_RGM_TRX_RECORDS.DEBIT_AMOUNT%TYPE                                                 ;
  ln_receivable_application_id      AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE              := -1      ;
  lv_process_flag                   VARCHAR2(2)                                                                           ;
  lv_process_message                VARCHAR2(1996)                                                                        ;
  ln_uncommitted_transactions       NUMBER(10)                                                                 := 0       ;
  lv_service_type_code              JAI_AR_TRX_LINES.service_type_code%TYPE ;/*5879769*/
  lv_application_type               ar_receivable_applications_all.application_type%TYPE  ;--rchandan for bug#4428980
  lv_status                         ar_receivable_applications_all.status%TYPE ;--rchandan for bug#4428980
  lv_type                           ra_cust_trx_types_all.type%TYPE ;--rchandan for bug#4428980
  lv_source_table                   CONSTANT jai_rgm_trx_records.source_table_name%TYPE := 'AR_RECEIVABLE_APPLICATIONS_ALL';--rchandan for bug#4428980
  lv_called_from                    CONSTANT varchar2(100) := 'jai_ar_rgm_processing_pkg.POPULATE_CM_APP';--rchandan for bug#4428980
  lv_attribute_context              jai_rgm_trx_records.attribute_context%TYPE ;--rchandan for bug#4428980

  ln_total_tax_applied              NUMBER;     --added by walton for inclusive tax 29-Nov-07
  ln_line_total_amt                 NUMBER;      --added by walton for inclusive tax 29-Nov-07
  ln_inclusive_total_amt            NUMBER;     --added by walton for inclusive tax 29-Nov-07

  ln_exc_gain_loss_amt              NUMBER; -- Added for Bug 8294236
  ln_total_tax_amt                  NUMBER; -- Added for Bug 8294236

 /*
  || Get the credit memo applications to invoices and the total invoice tax amount .
  || Consider only those credit memo applications which follow the following conditions:-
  || 1. Invoice tax line reference exists in the jai_rgm_trx_refs table for the invoice against which the cash receipt is being applied
  || 2. The cash receipt tax line does not already exist in the repository i.e jai_rgm_trx_records.
  || 3. Consider cash receipt application against an invoice only
  || 4. Invoice tax line has not been fully recovered i.e recovered_amount < recoverable_amount - discounted_amount in references table
  || 5. Processes DebitMemo for bug#6773751, add by Xiao on 20-Dec-09.
 */


  CURSOR c_get_cm_rec_app     ( cp_source_ar varchar2) --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE )
  IS
  SELECT
          aral.customer_trx_id                                    cm_customer_trx_id                              ,
          aral.applied_customer_trx_id                            inv_customer_trx_id                             ,
          aral.receivable_application_id                                                                          ,
          aral.gl_date                                                                                            ,
          nvl(aral.tax_applied,0)                                 cm_app_tax_amt                                  ,
          nvl(aral.line_applied,0)                                cm_app_line_amt                                , --added by walton for inclusive tax 29-Nov-07
          nvl(aral.amount_applied,0)                              cm_app_amount                                   ,
          cm_trx.trx_date                                         cm_transaction_date                             ,
          cm_trx.invoice_currency_code                            cm_currency_code                                ,
          cm_trx.exchange_date                                    cm_exchange_date                                ,
          cm_trx.exchange_rate                                    cm_exchange_rate                                ,
          cm_trx.exchange_rate_type                               cm_exchange_rate_type                           ,
          inv_jtrx.organization_id                                inv_invn_organization_id                        ,
          cm_jtrx.organization_id                                 cm_invn_organization_id                         ,
          trx_types.type                                          Trx_type, --added by Xiao for bug#6773751
        -- Added for Bug 8294236 - Start
         inv_trx.invoice_currency_code                           invoice_currency_code                           ,
         inv_trx.exchange_rate                                   invoice_exchange_rate                           ,
         inv_trx.exchange_date                                   invoice_exchange_date                           ,
         inv_trx.exchange_rate_type                              invoice_exchange_rate_type
         -- Added for Bug 8294236 - End
  FROM
          ar_receivable_applications_all  aral                                                                    ,
          ra_customer_trx_all             cm_trx                                                                  ,
          ra_customer_trx_all             inv_trx                                                                 ,
          ra_cust_trx_types_all           trx_types                                                               ,
          JAI_AR_TRXS           inv_jtrx                                                                ,
          JAI_AR_TRXS           cm_jtrx
  WHERE
          aral.customer_trx_id         = cm_trx.customer_trx_id                                                   AND
          cm_trx.customer_trx_id       = cm_jtrx.customer_trx_id                                                  AND
          aral.applied_customer_trx_id = inv_trx.customer_trx_id                                                  AND
          trunc(aral.creation_date)    BETWEEN trunc(p_from_date) and trunc(p_to_date)                            AND
          aral.application_type        = lv_application_type                                                      AND--rchandan for bug#4428980
          aral.status                  = lv_status                                                                AND--rchandan for bug#4428980
          /*nvl(aral.tax_applied,0)    <> 0                                                                       AND*/--Commented by walton for inclusive tax 29-Nov-07
          inv_trx.org_id               = nvl(p_org_id,inv_trx.org_id)                                             AND
          cm_trx.org_id                = nvl(p_org_id,cm_trx.org_id)                                              AND
          inv_trx.complete_flag        = 'Y'                                                                      AND
          cm_trx.complete_flag         = 'Y'                                                                      AND
          trx_types.cust_trx_type_id   = inv_trx.cust_trx_type_id                                                 AND
          trx_types.type                in( 'INV', 'DM' )   AND --lv_type   -- modified by Xiao for bug#6773751
          trx_types.org_id             = inv_trx.org_id                                                           AND
          inv_trx.customer_trx_id      = inv_jtrx.customer_trx_id                                                 AND
          inv_jtrx.organization_id     = p_organization_id                                                        AND/*5879769*/
          NOT EXISTS                   ( SELECT         /*A credit memo application does not exist in repository */
                                                 1
                                         FROM
                                                 jai_rgm_trx_records  rgtr
                                         WHERE
                                                 rgtr.source               = cp_source_ar                         AND
                                                 rgtr.organization_id      = p_organization_id AND -- Date 05/06/2007 by sacsethi for bug 6109941
                                                 rgtr.source_table_name    = lv_source_table                      AND--rchandan for bug#4428980
                                                 rgtr.source_document_id   = aral.receivable_application_id
                                       )                                                                          AND
        EXISTS                         (
                                         SELECT        /* A credit memo exists in the reference table with total recoverable amount <> recovered amount*/
                                                 1
                                         FROM
                                                 jai_rgm_trx_refs                rgtf
                                         WHERE
                                                 rgtf.source                    = cp_source_ar                         AND
                                                 rgtf.invoice_id                = aral.customer_trx_id                 AND
                                                 nvl(rgtf.recoverable_amount,0) <> nvl(rgtf.recovered_amount,0)
                                       )                                                                              AND
        EXISTS                         (
                                         SELECT        /* A invoice exists in the reference table with total recoverable amount > recovered amount*/
                                                 1
                                         FROM
                                                 jai_rgm_trx_refs                rgtf
                                         WHERE
                                                 rgtf.source                    = cp_source_ar                         AND
                                                 rgtf.invoice_id                = aral.applied_customer_trx_id         AND
                                                 nvl(rgtf.recoverable_amount,0) - nvl(discounted_amount,0) > nvl(rgtf.recovered_amount,0)
                                       ) ;

   /*
   || Get the Total transactional tax amount for the invoice
   */
   CURSOR cur_get_inv_tottax_amt (cp_inv_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE)
   IS
   SELECT
          nvl(sum(jrttl.tax_amount),0)   inv_tot_tax_amount
   FROM
          JAI_AR_TRX_LINES    jrtl  ,
          JAI_AR_TRX_TAX_LINES    jrttl
   WHERE
          jrtl.customer_trx_line_id   = jrttl.link_to_cust_trx_line_id  AND
          jrtl.customer_trx_id        = cp_inv_customer_trx_id ;


  /*
  || Get the sign of the credit memo
  */
  CURSOR cur_sign_of_cm (cp_cm_customer_trx_id JAI_AR_TRX_LINES.CUSTOMER_TRX_ID%TYPE )
  IS
  SELECT
      sign(nvl(sum(jrttl.tax_amount),0))   sign_of_credit_memo
  FROM
          JAI_AR_TRX_LINES    jrtl  ,
      JAI_AR_TRX_TAX_LINES    jrttl
  WHERE
         jrtl.customer_trx_line_id   = jrttl.link_to_cust_trx_line_id  AND
     jrtl.customer_trx_id        = cp_cm_customer_trx_id;

   --added by walton for inclusive tax 29-Nov-07
   -----------------------------------------------------
   --Get the Total CM inclusive tax amount for the cm,
   CURSOR cur_get_cm_inclusive_tax_amt
   ( pn_cm_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE
   )
   IS
   SELECT
     nvl(sum(jrttl.tax_amount),0) inv_tot_inclusive_tax_amt
   FROM
     JAI_AR_TRX_LINES    jrtl
   , JAI_AR_TRX_TAX_LINES    jrttl
   , jai_cmn_taxes_all    tax
   WHERE jrtl.customer_trx_line_id   = jrttl.link_to_cust_trx_line_id
     AND jrtl.customer_trx_id        = pn_cm_customer_trx_id
     AND jrttl.tax_id                = tax.tax_id
     AND NVL(tax.inclusive_tax_flag,'N') = 'Y' ;

   --Get the Total CM line amount,
   CURSOR cur_get_cm_line_amt
   ( pn_cm_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE
   )
   IS
   SELECT
     nvl(sum(jrtl.line_amount),0) inv_tot_line_amt
   FROM
     JAI_AR_TRX_LINES    jrtl
   WHERE jrtl.customer_trx_id        = pn_cm_customer_trx_id;
   ----------------------------------------------------------

  /*
  || Get the ref tax lines pertaining to the invoice against which the cash receipt has been applied : -

  */
  CURSOR c_get_refinvrec_for_upd    ( cp_source_ar            varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE        ,
                                      cp_inv_customer_trx_id  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                                     )
  IS
  SELECT
          reference_id                                                                                       ,
          tax_type                                                                                           ,
          tax_rate                                                                                           ,
          nvl(recoverable_amount,0) - nvl(discounted_amount,0)    recoverable_amount                         ,
          nvl(recovered_amount,0)                                 recovered_amount                           ,
          recoverable_ptg                                                                                     ,
          item_line_id  /*5879769*/
  FROM
          jai_rgm_trx_refs
  WHERE
          source                             = cp_source_ar                   AND
          invoice_id                           = cp_inv_customer_trx_id         AND
          nvl(recoverable_amount,0) - nvl(discounted_amount,0) > nvl(recovered_amount,0)
 FOR      UPDATE NOWAIT ;


  CURSOR c_get_refcmrec_for_upd    ( cp_source_ar            varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE        ,
                                     cp_cm_customer_trx_id   RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                                   )
  IS
  SELECT
          reference_id                                                                                       ,
          tax_type                                                                                           ,
          tax_rate                                                                                           ,
          nvl(recoverable_amount,0)   recoverable_amount                                                     ,
          nvl(recovered_amount,0)     recovered_amount                                                       ,
          item_line_id  /*5879769*/
  FROM
          jai_rgm_trx_refs
  WHERE
          source                  = cp_source_ar                                                             AND
          invoice_id              = cp_cm_customer_trx_id                                                    AND
          nvl(recoverable_amount,0) <> nvl(recovered_amount,0)
 FOR      UPDATE NOWAIT ;

  /*
  || Get the total effective CM amount from the CM lines in reference table against which a CM application has to be recovered.
  */
  CURSOR c_get_cmref_totrd_amt     ( cp_source_ar            varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE        ,
                                     cp_cm_customer_trx_id   RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                                   )
  IS
  SELECT
          nvl(sum(recoverable_amount),0) tot_effcm_rb_amt  /*bug 9432780*/
  FROM
          jai_rgm_trx_refs
  WHERE
          source                  = cp_source_ar                                                             AND
          invoice_id              = cp_cm_customer_trx_id ;

BEGIN

  fnd_file.put_line(fnd_file.LOG,'1 Entering procedure  : jai_rgm_process_ar.populate_cm_app' );
fnd_file.put_line(fnd_file.LOG,'p_org_id:'||p_org_id );
        fnd_file.put_line(fnd_file.LOG,'p_organization_id:'||p_organization_id );

  p_process_flag     := jai_constants.successful     ;
  p_process_message  := null                         ;

  /*****
  || Get all the valid CM receivables
  *****/
  lv_status   := 'APP';
  lv_application_type:= 'CM';
  --lv_type:= 'INV';   --commented by Xiao for bug#6773751
  FOR rec_c_get_cm_rec_app IN c_get_cm_rec_app ( cp_source_ar => p_source  )
  LOOP

    fnd_file.put_line(fnd_file.LOG,'2 processing credit memo with receivable_application_id as '||rec_c_get_cm_rec_app.receivable_application_id
                                   ||'against invoice with customer_trx_id '||rec_c_get_cm_rec_app.inv_customer_trx_id );

    /*########################################################################################################
    || INITIALIZING THE VARIABLES
    ########################################################################################################*/
    ln_receivable_application_id := null                         ;
    ln_amount                    := null                         ;
  ln_func_amount               := null                         ; -- Added for Bug 7522584
    ln_eff_cm_tax_amount         := null                         ;
    ln_eff_cm_tottax_amt         := null                         ;
    ln_tot_effcm_rb_amt          := null                         ;
    ln_inv_tot_tax_amt           := null                         ;
    ln_cm_ref_ratio              := null                         ;
    ln_cm_ref_upd                := null                         ;
    lv_source_trx_type           := null                         ;
    lv_process_flag              := jai_constants.successful     ;
    lv_process_message           := null                         ;

    ln_inclusive_total_amt       := null                         ; --added by walton for inclusive tax 29-Nov-07

    fnd_file.put_line(fnd_file.LOG,'3 Variables initialized' );

    /*########################################################################################################
    || SET A SAVEPOINT FOR EACH NEW CREDIT MEMO RECEIVABLE APPLICATION
    ########################################################################################################*/

    SAVEPOINT roll_to_cm_app;


    /*########################################################################################################
    || GET THE FOLLOWING INFORMATION:-
    || 1.INVOICE TOTAL TAX AMOUNT
    || 2. SIGN OF CREDIT MEMO
    || 3. DETERMINE THE CM RECEIPT APPLICATION TYPE (CREDIT MEMO APPLICATION, CREDIT MEMO REVERSAL)
    ########################################################################################################*/

    OPEN  cur_get_inv_tottax_amt (cp_inv_customer_trx_id => rec_c_get_cm_rec_app.inv_customer_trx_id);
    FETCH cur_get_inv_tottax_amt INTO ln_inv_tot_tax_amt;
    CLOSE cur_get_inv_tottax_amt ;
    /*
    || get the sign of the credit memo
    */
    OPEN  cur_sign_of_cm (cp_cm_customer_trx_id => rec_c_get_cm_rec_app.cm_customer_trx_id );
    FETCH cur_sign_of_cm INTO ln_sign_of_credit_memo;
    CLOSE cur_sign_of_cm;

    --added by walton for inclusive tax  29-Nov-07
    ------------------------------------------------------------------------------------------------------
    OPEN  cur_get_cm_inclusive_tax_amt( pn_cm_customer_trx_id => rec_c_get_cm_rec_app.cm_customer_trx_id
                                      );
    FETCH cur_get_cm_inclusive_tax_amt
    INTO  ln_inclusive_total_amt;
    CLOSE cur_get_cm_inclusive_tax_amt ;

    OPEN  cur_get_cm_line_amt( pn_cm_customer_trx_id => rec_c_get_cm_rec_app.cm_customer_trx_id
                             );
    FETCH cur_get_cm_line_amt
    INTO  ln_line_total_amt;
    CLOSE cur_get_cm_line_amt ;

    ln_total_tax_applied := rec_c_get_cm_rec_app.cm_app_tax_amt + (rec_c_get_cm_rec_app.cm_app_line_amt/ln_line_total_amt) * ln_inclusive_total_amt;
    ------------------------------------------------------------------------------------------------------

    fnd_file.put_line(fnd_file.LOG,'5 start of determine application source type');

    /*
    || If the CM tax amount is +ve then it is CREDIT MEMO REVERSAL/UNAPPLICATION
    || IF the CM tax receipt amount is -ve then it is CREDIT MEMO APPLICATION
    || This info would go into the source_trx_type in the repository table jai_rgm_trx_records .
    || This would help distinctly identify a CM application, CREDIT MEMO reversal
    || IF sign = 0 i.e CM amount = 0 then skip the cm application and proceed to the next
    */

    IF ln_sign_of_credit_memo > 0 THEN
      /*
      || +ve credit memo hence CREDIT MEMO REVERSAL
      */
      lv_source_trx_type := jai_constants.trx_type_cm_rvs ;

    ELSIF ln_sign_of_credit_memo < 0 THEN
      /*
      || -ve credit memo hence CREDIT MEMO APPLICATION
      */
      lv_source_trx_type := jai_constants.trx_type_cm_app  ;

    END IF;

    fnd_file.put_line(fnd_file.LOG,'7  credit memo type is lv_source_trx_type-> '||lv_source_trx_type);


    IF ln_sign_of_credit_memo <> 0   THEN
      /*########################################################################################################
      || Fetch all invoice reference lines for processing/passing CM-INV-APP  entries
      ########################################################################################################*/

      FOR  rec_c_get_refinvrec_for_upd IN c_get_refinvrec_for_upd  ( cp_source_ar            => p_source                                  ,
                                                                     cp_inv_customer_trx_id  => rec_c_get_cm_rec_app.inv_customer_trx_id
                                                                   )
      LOOP

        fnd_file.put_line(fnd_file.LOG,'4 start of invoice reference tax line, rec_c_get_refinvrec_for_upd.reference_id  -> '|| rec_c_get_refinvrec_for_upd.reference_id  );


        /*########################################################################################################
        || Calculation of the Service Tax Component of Credit Memo Tax Amount which needs to be considered
        ########################################################################################################*/

        fnd_file.put_line(fnd_file.LOG,'8 Start of Credit Memo Service Tax Component calculation');

        ln_eff_cm_tax_amount := (abs(ln_total_tax_applied)/ln_inv_tot_tax_amt) * rec_c_get_refinvrec_for_upd.recoverable_amount; --modified by walton for inclusive tax 29-Nov-07

        fnd_file.put_line(fnd_file.LOG,'9 rec_c_get_cm_rec_app.cm_app_tax_amt effective     -> '||rec_c_get_cm_rec_app.cm_app_tax_amt
                                       ||', ln_inv_tot_tax_amt -> '||ln_inv_tot_tax_amt
                                       ||', rec_c_get_refinvrec_for_upd.recoverable_amount  -> '||rec_c_get_refinvrec_for_upd.recoverable_amount
                                       ||', cash receipt tax amount is ln_eff_cm_tax_amount -> '||ln_eff_cm_tax_amount
                                       ||', rec_c_get_refinvrec_for_upd.recovered_amount    -> '||rec_c_get_refinvrec_for_upd.recovered_amount);

        /*########################################################################################################
        || Validate the effective credit memo tax component does not exceed the invoice recoverable amount on updation
        ########################################################################################################*/


        IF rec_c_get_refinvrec_for_upd.recovered_amount + abs(ln_eff_cm_tax_amount) > rec_c_get_refinvrec_for_upd.recoverable_amount THEN
          /*
          || +ve Credit Memo
          || Check that if recovered amount + credit Memo amount > recoverable amount.
          || IF yes then set Credit Memo amount = recoverable amount - recovered amount
          || so that the recovered amount never exceeds the recoverable amount
          */
          ln_eff_cm_tax_amount := (rec_c_get_refinvrec_for_upd.recoverable_amount - rec_c_get_refinvrec_for_upd.recovered_amount) ;
          fnd_file.put_line(fnd_file.LOG,'10 rec_c_get_refinvrec_for_upd.recovered_amount  +  ln_eff_cm_tax_amount  -> rec_c_get_refinvrec_for_upd.recoverable_amount hence ln_eff_cm_tax_amount '||ln_eff_cm_tax_amount);
        END IF;


        /*########################################################################################################
        || Insert the effective Credit Memo tax amount into the repository
        ########################################################################################################*/
        /*
        || Make an entry into the repository with the apportioned Credit Memo Tax amount to be applied against a reference invoice
        */
        /* ln_amount := abs(ln_eff_cm_tax_amount) * ln_sign_of_credit_memo ; */
        ln_amount := abs(ln_eff_cm_tax_amount) ;
        fnd_file.put_line(fnd_file.LOG,' 14 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry ' );

        /*csahoo for bug#5879769...start*/

        ln_organization_id   := NULL;
        ln_location_id       := NULL;
        lv_service_type_code := NULL;
        lv_process_flag      := NULL;
        lv_process_message   := NULL;

        jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => rec_c_get_refinvrec_for_upd.reference_id,
                                                        p_organization_id   => ln_organization_id,
                                                        p_location_id       => ln_location_id,
                                                        p_service_type_code => lv_service_type_code,
                                                        p_process_flag      => lv_process_flag,
                                                        p_process_message   => lv_process_message
                                                        );

         IF  lv_process_flag <> jai_constants.successful THEN
           FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
           return;
         END IF;

        /*csahoo for bug#5879769...end*/
    /*added the following if condition by Xiao for bug#6773751*/

     if rec_c_get_cm_rec_app.trx_type ='INV' then
        lv_attribute_context := 'CM-INV-APP';
     elsif rec_c_get_cm_rec_app.trx_type ='DM' then
         lv_attribute_context := 'CM-DM-APP';
     end if;
    ln_func_amount := (ln_amount * nvl(rec_c_get_cm_rec_app.cm_exchange_rate,1)) ;    -- Added for Bug 7522584
        jai_cmn_rgm_recording_pkg.insert_repository_entry (
                                                            p_repository_id              => ln_repository_id                                              ,
                                                            p_regime_id                  => p_regime_id                                                   ,
                                                            p_tax_type                   => rec_c_get_refinvrec_for_upd.tax_type                          ,
                                                            p_organization_type          => p_organization_type                                           ,
                  p_organization_id            => ln_organization_id                                            ,/*5879769*/
                  p_location_id                => ln_location_id                                                ,/*5879769*/
                                                            p_service_type_code          => lv_service_type_code                                          ,/*5879769*/
                                                            p_source                     => p_source                                                      ,
                                                            p_source_trx_type            => lv_source_trx_type                                            ,
                                                            p_source_table_name          => lv_source_table                              ,
                                                            p_source_document_id         => rec_c_get_cm_rec_app.receivable_application_id                ,
                                                            p_transaction_date           => rec_c_get_cm_rec_app.cm_transaction_date                      ,
                                                            p_account_name               => NULL                                                          ,
                                                            p_charge_account_id          => NULL                                                          ,
                                                            p_balancing_account_id       => NULL                                                          ,
                              -- Replaced ln_amount by ln_func_amount for Bug 7522584
                                                            p_amount                     => ln_func_amount                                                ,
                                                            p_assessable_value           => NULL                                                          ,
                                                            p_tax_rate                   => rec_c_get_refinvrec_for_upd.tax_rate                          ,
                                                            p_reference_id               => rec_c_get_refinvrec_for_upd.reference_id                      ,
                                                            p_batch_id                   => p_batch_id                                                    ,
                                                            p_called_from                => lv_called_from                    ,
                                                            p_process_flag               => lv_process_flag                                               ,
                                                            p_process_message            => lv_process_message                                            ,
                                                            p_discounted_amount          => ln_discounted_amount                                          ,
                                                            p_inv_organization_id        => ln_organization_id                                            ,/*5879769*/
                                                            p_accounting_date            => rec_c_get_cm_rec_app.gl_date                                  ,
                                                            p_currency_code              => rec_c_get_cm_rec_app.cm_currency_code                         ,
                                                            p_curr_conv_date             => rec_c_get_cm_rec_app.cm_exchange_date                         ,
                                                            p_curr_conv_type             => rec_c_get_cm_rec_app.cm_exchange_rate_type                    ,
                                                            p_curr_conv_rate             => rec_c_get_cm_rec_app.cm_exchange_rate                         ,
                                                            p_trx_amount                 => ln_amount                                                     ,
                                                            --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                                                            -- attribute1 to trx_reference1 and attribute2 to trx_reference2
                                                            -----------------------------------------------------------------------------                                                   ,
                                                            p_trx_reference_context          => lv_attribute_context                                              ,
                                                            p_trx_reference1                 => rec_c_get_cm_rec_app.inv_customer_trx_id                      ,
                                                            p_trx_reference2                 => rec_c_get_cm_rec_app.cm_customer_trx_id
                                                            -----------------------------------------------------------------------------
                                                            , p_accntg_required_flag    => jai_constants.yes --File.Sql.35 Cbabu
                                                          );

        fnd_file.put_line(fnd_file.LOG,' 15 Returned from jai_cmn_rgm_recording_pkg.insert_repository_entry ' );


        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || As Returned status is an error hence:-
          ||1. Rollback to save point
          ||2. Set out variables p_process_flag and p_process_message accordingly
          */
          ln_receivable_application_id := rec_c_get_cm_rec_app.receivable_application_id  ;
          ROLLBACK to roll_to_cm_app;
          fnd_file.put_line( fnd_file.log, '16 error in call to jai_cmn_rgm_recording_pkg.insert_repository_entry - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message);
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          EXIT;
        END IF;


        /*########################################################################################################
        || Update the Invoice Reference Recovered Amount with the effective Credit Memo tax amount
        ########################################################################################################*/

        fnd_file.put_line(fnd_file.LOG,' 11 before call to jai_cmn_rgm_recording_pkg.update_reference for updating invoice reference' );

        jai_cmn_rgm_recording_pkg.update_reference (
                                                     p_source             => p_source                                 ,
                                                     p_reference_id       => rec_c_get_refinvrec_for_upd.reference_id ,
                                                     p_recovered_amount   => ln_amount                                ,
                                                     p_process_flag       => lv_process_flag                          ,
                                                     p_process_message    => lv_process_message
                                                   );
        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || as Returned status is an error hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          ln_receivable_application_id := rec_c_get_cm_rec_app.receivable_application_id  ;
          ROLLBACK to roll_to_cm_app;
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          fnd_file.put_line( fnd_file.log, '12 error in call to jai_cmn_rgm_recording_pkg.update_reference - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'||lv_process_message);

          EXIT;
        END IF;


        fnd_file.put_line(fnd_file.LOG,' 13 Returned from jai_cmn_rgm_recording_pkg.update_reference  after updating invoice reference' );

        /*
        || Get the sum of the effective cm tax amount applied across all the reference invoice lines
        */
        ln_eff_cm_tottax_amt := nvl(abs(ln_eff_cm_tottax_amt),0) + abs(ln_eff_cm_tax_amount);

        fnd_file.put_line( fnd_file.log, '17 value of ln_eff_cm_tottax_amt  is - '||ln_eff_cm_tottax_amt );
      END LOOP; -- End of Invoice Reference line processing



      /*########################################################################################################
      || INSERT CM-CM-APP ENTRIES IN REPOSITORY AND UPDATE THE CREDIT MEMO REFERENCE RECORDS
      ########################################################################################################*/
      IF nvl(ln_receivable_application_id ,-1) <> rec_c_get_cm_rec_app.receivable_application_id    THEN
        /*
        || Get the total effective recoverable credit memo amount from the reference table - CM record
        */
        OPEN  c_get_cmref_totrd_amt ( cp_source_ar           => p_source                                  ,
                                      cp_cm_customer_trx_id  => rec_c_get_cm_rec_app.cm_customer_trx_id
                                    );
        FETCH c_get_cmref_totrd_amt INTO ln_tot_effcm_rb_amt ;
        CLOSE c_get_cmref_totrd_amt;
        /*
        || ln_eff_cm_tottax_amt - represents the total effective cm amount applied across all the corresponding reference invoice records
        || ln_tot_effcm_rb_amt  - represents the sum of the total effective recoverable CM amount from the reference table
        || (Recoverable amount = total R.B amt - total R.D amount for all the CM records inref table).
        || Get the ratio in which the CM needs to be apportioned
        */
        ln_cm_ref_ratio := abs(ln_eff_cm_tottax_amt)/abs(ln_tot_effcm_rb_amt);

        fnd_file.put_line(fnd_file.LOG,'18 Total Effective CM recoverable amount ln_tot_effcm_rb_amt - ' || ln_tot_effcm_rb_amt
                                       ||', actual total cm apportioned amoungst ln_eff_cm_tottax_amt - '|| ln_eff_cm_tottax_amt
                                       ||', cm eff ratio ln_cm_ref_ratio - '||ln_cm_ref_ratio
                                       );


        /*
        || Update the credit memo reference lines
        */
        FOR  rec_c_get_refcmrec_for_upd IN c_get_refcmrec_for_upd  ( cp_source_ar           => p_source                                  ,
                                                                     cp_cm_customer_trx_id  => rec_c_get_cm_rec_app.cm_customer_trx_id
                                                                   )
        LOOP

          /*
          || Initialize the variable ln_cm_ref_upd
          */
          ln_cm_ref_upd := null;

          fnd_file.put_line(fnd_file.LOG,'19 Processing Credit memo reference tax line, rec_c_get_refcmrec_for_upd.reference_id -> '|| rec_c_get_refcmrec_for_upd.reference_id  );

          /*
          || Calculate the value of ln_cm_ref_upd
          */
          ln_cm_ref_upd := abs(ln_cm_ref_ratio) * abs(rec_c_get_refcmrec_for_upd.recoverable_amount) * ln_sign_of_credit_memo;

          /*########################################################################################################
          || Insert the effective Credit Memo tax amount into the repository
          ########################################################################################################*/
           /*
           || Make an entry into the repository with the apportioned Credit Memo Tax amount to be applied against a reference Credit Memo
           */

          /*csahoo for bug#5879769...start*/

          ln_organization_id   := NULL;
          ln_location_id       := NULL;
          lv_service_type_code := NULL;
          lv_process_flag      := NULL;
          lv_process_message   := NULL;

          jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => rec_c_get_refcmrec_for_upd.reference_id,
                                                          p_organization_id   => ln_organization_id,
                                                          p_location_id       => ln_location_id,
                                                          p_service_type_code => lv_service_type_code,
                                                          p_process_flag      => lv_process_flag,
                                                          p_process_message   => lv_process_message
                                                          );

           IF  lv_process_flag <> jai_constants.successful THEN
             FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
             return;
           END IF;

          /*csahoo for bug#5879769...end*/

          fnd_file.put_line(fnd_file.LOG,' 23 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry ' );
          lv_attribute_context := 'CM-CM-APP';--rchandan for bug#4428980
      ln_func_amount := ln_cm_ref_upd * nvl(rec_c_get_cm_rec_app.cm_exchange_rate,1); -- Added for Bug 7522584
          -- Added for Bug 8294236 - Start
         ln_total_tax_amt := abs(ln_cm_ref_upd + nvl(ln_discounted_amount,0));
         IF (nvl(rec_c_get_cm_rec_app.cm_exchange_rate,1) <> nvl(rec_c_get_cm_rec_app.invoice_exchange_rate,1)
            AND rec_c_get_cm_rec_app.cm_currency_code = rec_c_get_cm_rec_app.invoice_currency_code)
         THEN
            ln_exc_gain_loss_amt := (ln_total_tax_amt * nvl(rec_c_get_cm_rec_app.cm_exchange_rate,1))
                                    - (ln_total_tax_amt * nvl(rec_c_get_cm_rec_app.invoice_exchange_rate,1));
         ELSE
            ln_exc_gain_loss_amt := 0;
         END IF;

         fnd_file.put_line(fnd_file.LOG,'ln_total_tax_amt '|| ln_total_tax_amt ||'  rec_c_get_cm_rec_app.cm_exchange_rate '|| rec_c_get_cm_rec_app.cm_exchange_rate ||
                                        ' rec_c_get_cm_rec_app.invoice_exchange_rate '|| rec_c_get_cm_rec_app.invoice_exchange_rate ||
                                        ' ln_exc_gain_loss_amt '|| ln_exc_gain_loss_amt || ' ln_cm_ref_upd '|| ln_cm_ref_upd ||
                                        ' ln_discounted_amount ' ||ln_discounted_amount);

         -- Added for Bug 8294236 - End
          jai_cmn_rgm_recording_pkg.insert_repository_entry (
                                                              p_repository_id              => ln_repository_id                                    ,
                                                              p_regime_id                  => p_regime_id                                         ,
                                                              p_tax_type                   => rec_c_get_refcmrec_for_upd.tax_type                 ,
                                                              p_organization_type          => p_organization_type                                 ,
                                                              p_organization_id            => ln_organization_id                                  ,/*5879769*/
                                                        p_location_id                => ln_location_id                                      ,/*5879769*/
                                                              p_service_type_code          => lv_service_type_code                                ,/*5879769*/
                                                              p_source                     => p_source                                            ,
                                                              p_source_trx_type            => lv_source_trx_type                                  ,
                                                              p_source_table_name          => lv_source_table                    ,
                                                              p_source_document_id         => rec_c_get_cm_rec_app.receivable_application_id      ,
                                                              p_transaction_date           => rec_c_get_cm_rec_app.cm_transaction_date            ,
                                                              p_account_name               => NULL                                                ,
                                                              p_charge_account_id          => NULL                                                ,
                                                              p_balancing_account_id       => NULL                                                ,
                                -- Added ln_func_amount for Bug 7522584
                                                              p_amount                     => ln_func_amount                                      ,
                                                              p_assessable_value           => NULL                                                ,
                                                              p_tax_rate                   => rec_c_get_refcmrec_for_upd.tax_rate                 ,
                                                              p_reference_id               => rec_c_get_refcmrec_for_upd.reference_id             ,
                                                              p_batch_id                   => p_batch_id                                          ,
                                                              p_called_from                => lv_called_from          ,
                                                              p_process_flag               => lv_process_flag                                     ,
                                                              p_process_message            => lv_process_message                                  ,
                                                              p_discounted_amount          => ln_discounted_amount                                ,
                                                              p_inv_organization_id        => ln_organization_id                                  ,/*5879769*/
                                                              p_accounting_date            => rec_c_get_cm_rec_app.gl_date                        ,
                                                              p_currency_code              => rec_c_get_cm_rec_app.cm_currency_code               ,
                                                              p_curr_conv_date             => rec_c_get_cm_rec_app.cm_exchange_date               ,
                                                              p_curr_conv_type             => rec_c_get_cm_rec_app.cm_exchange_rate_type          ,
                                                              p_curr_conv_rate             => rec_c_get_cm_rec_app.cm_exchange_rate               ,
                                                              p_trx_amount                 => ln_cm_ref_upd                                       ,
                                                              --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                                                              -- attribute2 to trx_reference2
                                                              -----------------------------------------------------------------------------                                   ,
                                                              p_trx_reference_context          => lv_attribute_context                                       ,
                                                              p_trx_reference2                 => rec_c_get_cm_rec_app.cm_customer_trx_id
                                                             -------------------------------------------------------------------------------
                                                              , p_accntg_required_flag    => jai_constants.yes --File.Sql.35 Cbabu
                                                            );

          fnd_file.put_line(fnd_file.LOG,' 24 Returned from jai_cmn_rgm_recording_pkg.insert_repository_entry ' );


          IF lv_process_flag = jai_constants.expected_error    OR
             lv_process_flag = jai_constants.unexpected_error
          THEN
            /*
            || as Returned status is an error hence:-
            ||1. Rollback to save point
            ||2. Set out variables p_process_flag and p_process_message accordingly
            */
            ROLLBACK to roll_to_cm_app;
            fnd_file.put_line( fnd_file.log, '25 error in call to jai_cmn_rgm_recording_pkg.insert_repository_entry - lv_process_flag '||lv_process_flag
                                              ||', lv_process_message'||lv_process_message);
            p_process_flag    := lv_process_flag    ;
            p_process_message := lv_process_message ;
            EXIT;
          END IF;

      -- Added for Bug 8294236 - Start
         IF nvl(ln_exc_gain_loss_amt,0) <> 0 THEN

                jai_cmn_rgm_recording_pkg.exc_gain_loss_accounting(
                                        p_repository_id           =>  ln_repository_id                                     ,
                                        p_regime_id               =>  p_regime_id                                         ,
                                        p_tax_type                =>  rec_c_get_refcmrec_for_upd.tax_type                 ,
                                        p_organization_type       =>  p_organization_type                                 ,
                                        p_organization_id         =>  ln_organization_id                                  ,
                                        p_location_id             =>  ln_location_id                                      ,
                                        p_source                  =>  p_source                                            ,
                                        p_source_trx_type         =>  lv_source_trx_type                                  ,
                                        p_source_table_name       =>  'AR_RECEIVABLE_APPLICATIONS_ALL'                    ,
                                        p_source_document_id      =>  rec_c_get_cm_rec_app.receivable_application_id      ,
                                        p_transaction_date        =>  rec_c_get_cm_rec_app.cm_transaction_date            ,
                                        p_account_name            =>  NULL                                                ,
                                        p_charge_account_id       =>  NULL                                                ,
                                        p_balancing_account_id    =>  NULL                                                ,
                                        p_exc_gain_loss_amt       =>  ln_exc_gain_loss_amt                                ,
                                        p_reference_id            =>  rec_c_get_refcmrec_for_upd.reference_id             ,
                                        p_called_from             =>  'JAI_RGM_PROCESS_AR_TAXES.POPULATE_CM_APP'          ,
                                        p_process_flag            =>  lv_process_flag                                     ,
                                        p_process_message         =>  lv_process_message                                  ,
                                        p_accounting_date         =>  rec_c_get_cm_rec_app.gl_date
                                      );

                IF lv_process_flag = jai_constants.expected_error    OR
                   lv_process_flag = jai_constants.unexpected_error
                THEN
                  ln_receivable_application_id :=  rec_c_get_cm_rec_app.receivable_application_id;
                  ROLLBACK to roll_to_last_receivable;
                  p_process_flag    := lv_process_flag    ;
                  p_process_message := lv_process_message ;
                  fnd_file.put_line( fnd_file.log, '16.1 error in call to jai_rgm_trx_recording_pkg.exc_gain_loss_accounting - lv_process_flag '||lv_process_flag
                                                    ||', lv_process_message'||lv_process_message);
                  EXIT;
                END IF;
         END IF;
          -- Added for Bug 8294236 - End

          fnd_file.put_line(fnd_file.LOG,' 20 before call to jai_cmn_rgm_recording_pkg.update_reference for credit memo references '
                                         ||' ,abs(rec_c_get_refcmrec_for_upd.recoverable_amount) -> '||abs(rec_c_get_refcmrec_for_upd.recoverable_amount)
                                         ||' ,recovered amount i.e ln_cm_ref_upd -> '||ln_cm_ref_upd
                           );


          /*
          || Update the cm reference line with the amount in ln_cm_ref_upd
          */
          jai_cmn_rgm_recording_pkg.update_reference (
                                                       p_source             => p_source                                                             ,
                                                       p_reference_id       => rec_c_get_refcmrec_for_upd.reference_id                              ,
                                                       p_recovered_amount   => ln_cm_ref_upd                                                        ,
                                                       p_process_flag       => lv_process_flag                                                      ,
                                                       p_process_message    => lv_process_message
                                                     );
          fnd_file.put_line(fnd_file.LOG,' 21 Returned from jai_cmn_rgm_recording_pkg.update_reference for credit memo references' );

          IF lv_process_flag = jai_constants.expected_error    OR
             lv_process_flag = jai_constants.unexpected_error
          THEN
            /*
            || As Returned status is an error hence:-
            ||1. Rollback to save point
            ||2. Set out variables p_process_flag and p_process_message accordingly
            */
            ROLLBACK to roll_to_cm_app;
            fnd_file.put_line( fnd_file.log, '22 error in call to  jai_cmn_rgm_recording_pkg.update_reference - lv_process_flag '||lv_process_flag
                                              ||', lv_process_message'||lv_process_message);
            p_process_flag    := lv_process_flag    ;
            p_process_message := lv_process_message ;
            EXIT;
          END IF;

        END LOOP; /* End of Update Credit Memo references */
      END IF; /* END IF of nvl(ln_receivable_application_id,-1) <> rec_c_get_cm_rec_app.receivable_application_id  */

    END IF; /* End if of sign of credit memo*/

    ln_uncommitted_transactions := ln_uncommitted_transactions  + 1;
    fnd_file.put_line(fnd_file.LOG,' 26 Finished processing the receivable' );

    IF ln_uncommitted_transactions >= 500 THEN
      commit;
      ln_uncommitted_transactions := 0;
    END IF;
  END LOOP; -- End of receivables fetch loop

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.LOG,' 27 In exception section of jai_ar_rgm_processing_pkg.populate_cm_app' );
    p_process_flag    := jai_constants.unexpected_error;
    p_process_message := 'Unexpected error occured while processing jai_ar_rgm_processing_pkg.populate_cm_app'||SQLERRM ;
END populate_cm_app;


procedure populate_receipt_records   ( p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                  ,
                                       p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE      ,
                                       p_from_date          IN  DATE                                        ,
                                       p_to_date            IN  DATE                                        ,
                                       p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE             ,
                                       p_source             IN  varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                ,
                                       p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE              ,
                                       p_process_flag OUT NOCOPY VARCHAR2                                    ,
                                       p_process_message OUT NOCOPY VARCHAR2
                             ,p_organization_id IN  JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE  DEFAULT NULL        )
IS

  ln_receivable_application_id      AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE         ;
  ln_eff_cr_tax_amount              AR_RECEIVABLE_APPLICATIONS_ALL.TAX_APPLIED%TYPE                       ;
  ln_eff_cr_disc_amount             AR_RECEIVABLE_APPLICATIONS_ALL.TAX_EDISCOUNTED%TYPE                   ;
  ln_repository_id                  JAI_RGM_TRX_RECORDS.REPOSITORY_ID%TYPE                                ;
  ln_inv_tot_tax_amt                JAI_AR_TRX_TAX_LINES.TAX_AMOUNT%TYPE                           ;
  -- Added for Bug 7522584
  ln_func_tax_amt                   NUMBER                                                                ;
  lv_process_flag                   VARCHAR2(2)                                                           ;
  lv_process_message                VARCHAR2(1996)                                                        ;
  lv_source_trx_type                VARCHAR2(50)                                                          ;
  lv_attribute_context              VARCHAR2(50)                                                          ;
  ln_uncommitted_transactions       NUMBER(10)     := 0                                                   ;
  lv_service_type_code              JAI_AR_TRX_LINES.service_type_code%TYPE                    ;/*5879769*/
  ln_location_id                    NUMBER(15);/*5879769*/
  lv_source_table                   CONSTANT jai_rgm_trx_records.source_table_name%TYPE := 'AR_RECEIVABLE_APPLICATIONS_ALL';--rchandan for bug#4428980
  lv_called_from                    CONSTANT varchar2(100) := 'jai_ar_rgm_processing_pkg.POPULATE_RECEIPT_RECORDS';--rchandan for bug#4428980

  ln_total_tax_applied              NUMBER;     --added by walton for inclusive tax 29-Nov-07
  ln_line_total_amt                 NUMBER;     --added by walton for inclusive tax 29-Nov-07
  ln_inclusive_total_amt            NUMBER;     --added by walton for inclusive tax 29-Nov-07

  ln_exc_gain_loss_amt              NUMBER; -- Added for Bug 8294236
  ln_total_tax_amt                  NUMBER; -- Added for Bug 8294236
 /*
  || Get the cash receipt, Invoice and Total Effective Invoice Recoverable Amount for them.
  || Consider only those cash receipts which follow the conditions as given below:-
  || 1. Invoice tax line reference exists in the jai_rgm_trx_refs table for the invoice against which the cash receipt is being applied
  || 2. The cash receipt tax line does not already exist in the repository i.e jai_rgm_trx_records.
  || 3. Consider cash receipt application against an invoice only
  || 4. Invoice tax line has not been fully recovered i.e recovered_amount < recoverable_amount in references table
  || 5.Consider Cash Receipt application for DM ,bug #6773751
 */


  CURSOR c_get_rec_app     ( cp_source_ar varchar2) --File.Sql.35 Cbabu ( jai_constants.SOURCE_AR%TYPE )
  IS
  SELECT
          trx.customer_trx_id                                                                                     ,
          acrl.cash_receipt_id                                                                                    ,
          aral.receivable_application_id                                                                          ,
          aral.gl_date                                                                                            ,
          sign(nvl(aral.tax_applied,0))                           sign_of_cash_receipt                            ,
          sign(nvl(tax_uediscounted,0) + nvl(tax_ediscounted,0))  sign_of_cr_disc                                 ,
          nvl(aral.tax_applied,0)                                 cash_rcpt_tax_amt                               ,
          nvl(tax_uediscounted,0) + nvl(tax_ediscounted,0)        cr_tax_disc_amt                                 ,
          nvl(aral.amount_applied,0)                              receipt_amount                                  ,
          nvl(aral.line_applied,0)                                cash_rcpt_line_amt                              , --added by walton for inclusive tax 29-Nov-07
          acrl.receipt_date                                                                                       ,
          acrl.currency_code                                      receipt_currency_code                           ,
          acrl.exchange_date                                      receipt_exchange_date                           ,
          acrl.exchange_rate                                      receipt_exchange_rate                           ,
          acrl.exchange_rate_type                                 receipt_exchange_rate_type                      ,
          jtrx.organization_id                                    inv_organization_id                             ,
          trx_types.type                                          trx_type, --added by Xiao for bug#6773751

      -- Added for Bug 8294236
         trx.invoice_currency_code                               invoice_currency_code                           ,
         trx.exchange_rate                                       invoice_exchange_rate                           ,
         trx.exchange_date                                       invoice_exchange_date                           ,
         trx.exchange_rate_type                                  invoice_exchange_rate_type
         -- Added for Bug 8294236
  FROM
          ar_receivable_applications_all  aral                                                                    ,
          ar_cash_receipts_all            acrl                                                                    ,
          ra_customer_trx_all             trx                                                                     ,
          ra_cust_trx_types_all           trx_types                                                               ,
          JAI_AR_TRXS           jtrx
  WHERE
          aral.cash_receipt_id         = acrl.cash_receipt_id                                                                       AND
          aral.applied_customer_trx_id = trx.customer_trx_id                                                                        AND
          trunc(aral.creation_date)    BETWEEN trunc(p_from_date) and trunc(p_to_date)                                              AND
          upper(aral.application_type) = upper(jai_constants.ar_cash)                                                               AND
          upper(aral.status)           = upper(jai_constants.ar_status_app)                                                         AND
          jtrx.organization_id =p_organization_id                                                                                   AND --Added by kunkumar for forward porting to R12
          /*nvl(aral.tax_applied,0)    <> 0                                                                                         AND*/--Modified by walton for inclusive tax 29-Nov-07
          trx.org_id                   = nvl(p_org_id,trx.org_id)                                                                   AND
          trx.complete_flag            = 'Y'                                                                                        AND
          trx_types.cust_trx_type_id   = trx.cust_trx_type_id                                                                       AND
          upper(trx_types.type)        IN (upper(jai_constants.ar_invoice_type_inv),upper(jai_constants.ar_invoice_type_cm)
                                          ,upper(jai_constants.ar_doc_type_dm))        AND /* Added ar_doc_type_dm for bug# 6773751 */
          trx_types.org_id             = trx.org_id                                                                                 AND
          trx.customer_trx_id          = jtrx.customer_trx_id                                                                       AND
          NOT EXISTS                   ( SELECT         /*A receipt application does not exist in repository */
                                                 1
                                         FROM
                                                 jai_rgm_trx_records  rgtr
                                         WHERE
                                                 rgtr.source               = cp_source_ar                             AND
                                                 rgtr.organization_id      = p_organization_id                        AND/*5879769*/
                                                 rgtr.source_table_name    = lv_source_table         AND
                                                 rgtr.source_document_id   = aral.receivable_application_id
                                       )                                                                              AND
                EXISTS                (
                                        SELECT        /* A invoice exists in the reference table with total recoverable amount - discounted_amount > recovered amount*/
                                                1
                                        FROM
                                                jai_rgm_trx_refs                rgtf
                                        WHERE
                                                rgtf.source                    =  jai_constants.SOURCE_AR            AND
                                                rgtf.invoice_id                = aral.applied_customer_trx_id         AND
                                                (
                          (   /*Scope of recovery is possible for cash receipt application */
                            nvl(rgtf.recoverable_amount,0) - nvl(rgtf.discounted_amount,0) > nvl(rgtf.recovered_amount,0) AND
                            nvl(aral.tax_applied,0) > 0
                          )                                                                                           OR
                          ( /* As it is a case of cash receipt reversal hence do not check for recovery. */
                                                    nvl(aral.tax_applied,0) < 0
                          )
                        )
                    );

   /*
   || Get the Total transactional tax amount for the invoice
   */
   CURSOR cur_get_inv_tottax_amt (cp_inv_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE)
   IS
   SELECT
          nvl(sum(jrttl.tax_amount),0) inv_tot_tax_amount
   FROM
          JAI_AR_TRX_LINES    jrtl  ,
          JAI_AR_TRX_TAX_LINES    jrttl
   WHERE
          jrtl.customer_trx_line_id   = jrttl.link_to_cust_trx_line_id  AND
          jrtl.customer_trx_id        = cp_inv_customer_trx_id ;

   --added by walton for inclusive tax 29-Nov-07
   ---------------------------------------------------------------
   --Get the Total inclusive tax amount for the invoice,
   CURSOR cur_get_inv_inclusive_tax_amt
   ( pn_inv_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE
   )
   IS
   SELECT
     nvl(sum(jrttl.tax_amount),0) inv_tot_inclusive_tax_amt
   FROM
     JAI_AR_TRX_LINES    jrtl
   , JAI_AR_TRX_TAX_LINES    jrttl
   , jai_cmn_taxes_all    tax
   WHERE jrtl.customer_trx_line_id   = jrttl.link_to_cust_trx_line_id
     AND jrtl.customer_trx_id        = pn_inv_customer_trx_id
     AND jrttl.tax_id                = tax.tax_id
     AND NVL(tax.inclusive_tax_flag,'N') = 'Y' ;

   --Get the Total AR transaction line amount,
   CURSOR cur_get_inv_line_amt
   ( pn_inv_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE
   )
   IS
   SELECT
     nvl(sum(jrtl.line_amount),0) inv_tot_line_amt
   FROM
     JAI_AR_TRX_LINES    jrtl
   WHERE jrtl.customer_trx_id        = pn_inv_customer_trx_id;
   --------------------------------------------------------------------------------
  /*
  || Get the ref tax lines pertaining to the invoice against which the cash receipt has been applied : -
  */
  CURSOR c_get_refrec_for_upd    ( cp_source_ar        varchar2, --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE        ,
                                   cp_customer_trx_id  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                                  )
  IS
  SELECT
          reference_id                                                                                       ,
          tax_type                                                                                           ,
          tax_rate                                                                                           ,
          nvl(discounted_amount,0)                                  discounted_amount                        ,
          nvl(recoverable_amount,0) - nvl(discounted_amount,0)      recoverable_amount                       ,
          nvl(recovered_amount,0)                                   recovered_amount                         ,
          item_line_id                                              /*5879769*/
  FROM
          jai_rgm_trx_refs
  WHERE
          source                                                    = cp_source_ar                           AND
          invoice_id                                                = cp_customer_trx_id                     AND
          nvl(recoverable_amount,0) - nvl(discounted_amount,0) >= nvl(recovered_amount,0) /*Modified the comparison condition to >= for Bug 6474509*/
 FOR      UPDATE NOWAIT ;


BEGIN

  fnd_file.put_line(fnd_file.LOG,'1 Entering procedure  : jai_rgm_process_ar.populate_receipt_records' );

  /*
  ||Initialize the variables
  */
  p_process_flag     := jai_constants.successful     ;
  p_process_message  := null                         ;


  /*****
  || Get all the valid receivables
  *****/
  FOR rec_c_get_rec_app IN c_get_rec_app ( cp_source_ar => p_source  )
  LOOP

    fnd_file.put_line(fnd_file.LOG,'2 processing cash receipt with receivable_application_id as '||rec_c_get_rec_app.receivable_application_id
                                   ||'against invoice with customer_trx_id '||rec_c_get_rec_app.customer_trx_id );

    /*########################################################################################################
    || Initializing the variables
    ########################################################################################################*/
    ln_receivable_application_id := null                      ;
    ln_eff_cr_tax_amount         := null                      ;
    ln_eff_cr_disc_amount        := null                      ;
    lv_source_trx_type           := null                      ;
    ln_inv_tot_tax_amt           := null                      ;
  ln_func_tax_amt              := null                      ; -- Added for Bug 7522584
    lv_process_flag              := jai_constants.successful  ;
    lv_process_message           := null                      ;

    ln_inclusive_total_amt       := null                      ; --added by walton for inclusive tax 29-Nov-07

    fnd_file.put_line(fnd_file.LOG,'3 Variables initialized' );

    SAVEPOINT roll_to_last_receivable;

    OPEN  cur_get_inv_tottax_amt (cp_inv_customer_trx_id => rec_c_get_rec_app.customer_trx_id);
    FETCH cur_get_inv_tottax_amt INTO ln_inv_tot_tax_amt;
    CLOSE cur_get_inv_tottax_amt ;

    --added by walton for inclusive tax  29-Nov-07
    OPEN  cur_get_inv_inclusive_tax_amt( pn_inv_customer_trx_id => rec_c_get_rec_app.customer_trx_id
                                       );
    FETCH cur_get_inv_inclusive_tax_amt
    INTO  ln_inclusive_total_amt;
    CLOSE cur_get_inv_inclusive_tax_amt ;

    OPEN  cur_get_inv_line_amt(pn_inv_customer_trx_id => rec_c_get_rec_app.customer_trx_id
                              );
    FETCH cur_get_inv_line_amt
    INTO  ln_line_total_amt;
    CLOSE cur_get_inv_line_amt ;

    --added by walton for inclusive tax 29-Nov-07
    ln_total_tax_applied := rec_c_get_rec_app.cash_rcpt_tax_amt + (rec_c_get_rec_app.cash_rcpt_line_amt/ln_line_total_amt) * ln_inclusive_total_amt;

    FOR  rec_c_get_refrec_for_upd IN c_get_refrec_for_upd  ( cp_source_ar        => p_source                           ,
                                                             cp_customer_trx_id  => rec_c_get_rec_app.customer_trx_id
                                                           )
    LOOP

      fnd_file.put_line(fnd_file.LOG,'4 start of invoice reference tax line , rec_c_get_refrec_for_upd.reference_id   -> '|| rec_c_get_refrec_for_upd.reference_id  );
      lv_attribute_context := NULL;
      /*########################################################################################################
      || Determine the receipt Application Type (Receipt Application, Receipt Reversal)
      ########################################################################################################*/
      fnd_file.put_line(fnd_file.LOG,'5 start of determine application source type');

      /*
      || If the cash receipt tax amount is -ve then it is RECEIPT REVERSAL/UNAPPLICATION
      || IF the cash receipt tax receipt amount is +ve then it is RECEIPT APPLICATION
      || This info would go into the source_trx_type in the repository table jai_rgm_trx_records .
      || This would help distinctly identify a receipt application, receipt reversal and a credit memo
      || IF sign = 0 i.e cash receipt amount = 0 then proceed exit the current loop and proceed with the next receivable application.
      */
      IF rec_c_get_rec_app.sign_of_cash_receipt > 0  or ln_total_tax_applied >0 THEN --modified by walton for inclusive tax 29-Nov-07
        /*
        || +ve cash receipt hence RECEIPT APPLICATION
        */
        lv_source_trx_type   := jai_constants.trx_type_rct_app ;
  /*the following conditions added by Xiao for bug#6773751*/
  if rec_c_get_rec_app.trx_type='INV'  then
          lv_attribute_context := 'CR-INV-APP'           ;
  elsif  rec_c_get_rec_app.trx_type='DM'  then
       lv_attribute_context := 'CR-DM-APP'           ;
  elsif     rec_c_get_rec_app.trx_type='CM'  then
       lv_attribute_context := 'CR-CM-APP'           ;
   end if;
   --end bug#6773751

      ELSIF rec_c_get_rec_app.sign_of_cash_receipt < 0 or ln_total_tax_applied <0 THEN --modified by walton for inclusive tax 29-Nov-07
        /*
        || -ve cash receipt hence RECEIPT REVERSAL/UNAPPLICATION
        */
        lv_source_trx_type := jai_constants.trx_type_rct_rvs ;
       /*the following conditions added by Xiao for bug#6773751*/
  if rec_c_get_rec_app.trx_type='INV'  then
          lv_attribute_context := 'CR-INV-REV'           ;
  elsif  rec_c_get_rec_app.trx_type='DM'  then
       lv_attribute_context := 'CR-DM-REV'           ;
  elsif     rec_c_get_rec_app.trx_type='CM'  then
       lv_attribute_context := 'CR-CM-REV'           ;
  end if;
   --end bug#6773751

      ELSE
        /*
        || cash receipt amount is zero hence exit current loop and process next receipt application
        */
        fnd_file.put_line(fnd_file.LOG,'6 cash receipt has sign = 0 i.e tax applied amount = 0 hence exit ');
        exit;
      END IF;

      fnd_file.put_line(fnd_file.LOG,'7  cash receipt is  lv_source_trx_type->'||lv_source_trx_type);

      /*########################################################################################################
      || Calculation of the Service Tax Component of Cash Receipt Tax Amount which needs to be considered
      ########################################################################################################*/

      fnd_file.put_line(fnd_file.LOG,'8 Start of Cash Receipt Service Tax Component calculation, ln_inv_tot_tax_amt'||ln_inv_tot_tax_amt);

      ln_eff_cr_tax_amount  := (ln_total_tax_applied/ln_inv_tot_tax_amt ) * rec_c_get_refrec_for_upd.recoverable_amount ; --modified by walton for inclusive tax 29-Nov-07


      IF  rec_c_get_refrec_for_upd.recovered_amount +  ln_eff_cr_tax_amount < 0 THEN
        /*
        || -ve cash receipt
        || Check that if recovered amount + cash receipt amount < 0 then the cash receipt amount should be equal to the recovered amount
        || so that the net recovered amount equals zero.
        */
        ln_eff_cr_tax_amount := rec_c_get_refrec_for_upd.recovered_amount * rec_c_get_rec_app.sign_of_cash_receipt;

        fnd_file.put_line(fnd_file.LOG,'10 rec_c_get_refrec_for_upd.recovered_amount +  ln_eff_cr_tax_amount < 0 , ln_eff_cr_tax_amount '||ln_eff_cr_tax_amount);


      ELSIF rec_c_get_refrec_for_upd.recovered_amount  +  ln_eff_cr_tax_amount  > rec_c_get_refrec_for_upd.recoverable_amount THEN
        /*
        || +ve cash receipt
        || Check that if recoverd amount + cash receipt amount > recoverable amount.
        || IF yes then set cash receipt amount = recoverable amount - recovered amount
        || so that the recovered amount never exceeds the recoverable amount
        */
        ln_eff_cr_tax_amount := rec_c_get_refrec_for_upd.recoverable_amount - rec_c_get_refrec_for_upd.recovered_amount ;
        fnd_file.put_line(fnd_file.LOG,'11 rec_c_get_refrec_for_upd.recovered_amount  +  ln_eff_cr_tax_amount  > rec_c_get_refrec_for_upd.recoverable_amount hence ln_eff_cr_tax_amount '||ln_eff_cr_tax_amount);
      END IF;


      /*########################################################################################################
      || Calculation of the Service Tax Discount Component of Cash Receipt Discounted Amount which needs to be considered
      ########################################################################################################*/

      ln_eff_cr_disc_amount := (rec_c_get_rec_app.cr_tax_disc_amt/ln_inv_tot_tax_amt) * rec_c_get_refrec_for_upd.recoverable_amount ;

      fnd_file.put_line(fnd_file.LOG,'9 rec_c_get_rec_app.cr_tax_disc_amt effective ->'||rec_c_get_rec_app.cr_tax_disc_amt
                                     ||', ln_inv_tot_tax_amt ->'||ln_inv_tot_tax_amt
                                     ||', rec_c_get_refrec_for_upd.recoverable_amount ->'||rec_c_get_refrec_for_upd.recoverable_amount
                                     ||', cash receipt tax amount is ln_eff_cr_tax_amount ->'||ln_eff_cr_tax_amount
                                     ||', rec_c_get_refrec_for_upd.recovered_amount ->'||rec_c_get_refrec_for_upd.recovered_amount);

      IF  nvl(rec_c_get_refrec_for_upd.recoverable_amount,0) - nvl(ln_eff_cr_disc_amount,0)  <
        nvl(rec_c_get_refrec_for_upd.recovered_amount,0)   + nvl(ln_eff_cr_tax_amount,0)
    THEN
        /*
    || +ve discounted amount
        || The effective recovered amount portion should never be greater than the effective recoverable_amount
    || Keeping this condition in mind , the discounted amount should get adjusted
        */
        ln_eff_cr_disc_amount := nvl(rec_c_get_refrec_for_upd.recoverable_amount,0) - (nvl(rec_c_get_refrec_for_upd.recovered_amount,0) + nvl(ln_eff_cr_tax_amount,0) );

        fnd_file.put_line(fnd_file.LOG,'10 effective recovered amount > effective recoverable amount hence, ln_eff_cr_disc_amount '||ln_eff_cr_disc_amount);

      ELSIF  rec_c_get_refrec_for_upd.discounted_amount +  ln_eff_cr_disc_amount < 0 THEN
      /*
      || -ve discounted amount
      || The total discounted amount cannot be lesser than 0
      */
        ln_eff_cr_disc_amount := rec_c_get_refrec_for_upd.discounted_amount * rec_c_get_rec_app.sign_of_cr_disc;

        fnd_file.put_line(fnd_file.LOG,'10 rec_c_get_refrec_for_upd.discounted_amount + ln_eff_cr_disc_amount < 0 , ln_eff_cr_tax_amount '||ln_eff_cr_tax_amount);

      END IF;

      /*########################################################################################################
      || Insert the effective cash receipt tax amount into the repository
      ########################################################################################################*/
       /*
       || Make an entry into the repository with the apportioned Cash Receipt Tax amount
       */

       /*csahoo for bug#5879769...start*/

      ln_organization_id   := NULL;
      ln_location_id       := NULL;
      lv_service_type_code := NULL;
      lv_process_flag      := NULL;
      lv_process_message   := NULL;

      jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => rec_c_get_refrec_for_upd.reference_id,
                                                      p_organization_id   => ln_organization_id,
                                                      p_location_id       => ln_location_id,
                                                      p_service_type_code => lv_service_type_code,
                                                      p_process_flag      => lv_process_flag,
                                                      p_process_message   => lv_process_message
                                                      );

       IF  lv_process_flag <> jai_constants.successful THEN
         FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
         return;
       END IF;

      /*csahoo for bug#5879769...end*/


       fnd_file.put_line(fnd_file.LOG,' 14 before call to jai_cmn_rgm_recording_pkg.insert_repository_entry ' );
       ln_func_tax_amt := ln_eff_cr_tax_amount * nvl(rec_c_get_rec_app.receipt_exchange_rate,1); -- Added for Bug 7522584

     -- Added for Bug 8294236 - Start
      ln_total_tax_amt := ln_eff_cr_tax_amount + nvl(ln_eff_cr_disc_amount,0);
      IF (nvl(rec_c_get_rec_app.receipt_exchange_rate,1) <> nvl(rec_c_get_rec_app.invoice_exchange_rate,1)
         AND rec_c_get_rec_app.receipt_currency_code = rec_c_get_rec_app.invoice_currency_code)
      THEN
        ln_exc_gain_loss_amt := (ln_total_tax_amt * nvl(rec_c_get_rec_app.receipt_exchange_rate,1))
                                      - (ln_total_tax_amt * nvl(rec_c_get_rec_app.invoice_exchange_rate,1));
      ELSE
        ln_exc_gain_loss_amt := 0;
      END IF;

     -- Added for Bug 8294236 - End

       jai_cmn_rgm_recording_pkg.insert_repository_entry (
                                                          p_repository_id              => ln_repository_id                                    ,
                                                          p_regime_id                  => p_regime_id                                         ,
                                                          p_tax_type                   => rec_c_get_refrec_for_upd.tax_type                   ,
                                                          p_organization_type          => p_organization_type                                 ,
                                                          p_organization_id            => ln_organization_id                                  ,/*5879769*/
                                                          p_location_id                => ln_location_id                                      ,/*5879769*/
                                                          p_service_type_code          => lv_service_type_code                                ,/*5879769*/
                                                          p_source                     => p_source                                            ,
                                                          p_source_trx_type            => lv_source_trx_type                                  ,
                                                          p_source_table_name          => lv_source_table                    ,
                                                          p_source_document_id         => rec_c_get_rec_app.receivable_application_id         ,
                                                          p_transaction_date           => rec_c_get_rec_app.receipt_date                      ,
                                                          p_account_name               => NULL                                                ,
                                                          p_charge_account_id          => NULL                                                ,
                                                          p_balancing_account_id       => NULL                                                ,
                              -- Added ln_func_amount for Bug 7522584
                                                         p_amount                     => ln_func_tax_amt                                     ,
                                                          p_assessable_value           => NULL                                                ,
                                                          p_tax_rate                   => rec_c_get_refrec_for_upd.tax_rate                   ,
                                                          p_reference_id               => rec_c_get_refrec_for_upd.reference_id               ,
                                                          p_batch_id                   => p_batch_id                                          ,
                                                          p_called_from                => lv_called_from                                      ,
                                                          p_process_flag               => lv_process_flag                                     ,
                                                          p_process_message            => lv_process_message                                  ,
                                                          p_discounted_amount          => ln_eff_cr_disc_amount                               ,
                                               p_inv_organization_id        => ln_organization_id                                  ,/*5879769*/
                                                          p_accounting_date            => rec_c_get_rec_app.gl_date                           ,
                                                          p_currency_code              => rec_c_get_rec_app.receipt_currency_code             ,
                                                          p_curr_conv_date             => rec_c_get_rec_app.receipt_exchange_date             ,
                                                          p_curr_conv_type             => rec_c_get_rec_app.receipt_exchange_rate_type        ,
                                                          p_curr_conv_rate             => rec_c_get_rec_app.receipt_exchange_rate             ,
                                                          p_trx_amount                 => ln_eff_cr_tax_amount                               ,
                                                           --Bo Li for Bug9305067 change attribute_cotext to trx_reference_context
                                                           --attribute1 to trx_reference1 and attribute2 to trx_reference2
                                                          -----------------------------------------------------------------------------
                                                          p_trx_reference_context          => lv_attribute_context                                ,
                                                          p_trx_reference1                 => rec_c_get_rec_app.customer_trx_id                   ,
                                                          p_trx_reference2                 => rec_c_get_rec_app.cash_receipt_id
                                                          ----------------------------------------------------------------------------
                                                          , p_accntg_required_flag    => jai_constants.yes --File.Sql.35 Cbabu
                                                        );

      fnd_file.put_line(fnd_file.LOG,' 15 Returned from jai_cmn_rgm_recording_pkg.insert_repository_entry ' );


      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        /*
        || as Returned status is an error hence:-
        ||1. Rollback to save point
        ||2. Set out variables p_process_flag and p_process_message accordingly
        */
        ln_receivable_application_id :=  rec_c_get_rec_app.receivable_application_id;
        ROLLBACK to roll_to_last_receivable;
        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        fnd_file.put_line( fnd_file.log, '16 error in call to jai_cmn_rgm_recording_pkg.insert_repository_entry - lv_process_flag '||lv_process_flag
                                          ||', lv_process_message'||lv_process_message);
        EXIT;
      END IF;

    -- Added for Bug 8294236 - Start
     IF nvl(ln_exc_gain_loss_amt,0) <> 0 THEN
            jai_cmn_rgm_recording_pkg.exc_gain_loss_accounting(
                                    p_repository_id              => ln_repository_id                                  ,
                                    p_regime_id               =>  p_regime_id                                         ,
                                    p_tax_type                =>  rec_c_get_refrec_for_upd.tax_type                   ,
                                    p_organization_type       =>  p_organization_type                                 ,
                                    p_organization_id         =>  ln_organization_id                                  ,
                                    p_location_id             =>  ln_location_id                                      ,
                                    p_source                  =>  p_source                                            ,
                                    p_source_trx_type         =>  lv_source_trx_type                                  ,
                                    p_source_table_name       =>  'AR_RECEIVABLE_APPLICATIONS_ALL'                    ,
                                    p_source_document_id      =>  rec_c_get_rec_app.receivable_application_id         ,
                                    p_transaction_date        =>  rec_c_get_rec_app.receipt_date                      ,
                                    p_account_name            =>  NULL                                                ,
                                    p_charge_account_id       =>  NULL                                                ,
                                    p_balancing_account_id    =>  NULL                                                ,
                                    p_exc_gain_loss_amt       =>  ln_exc_gain_loss_amt                                ,
                                    p_reference_id            =>  rec_c_get_refrec_for_upd.reference_id               ,
                                    p_called_from             =>  'JAI_RGM_PROCESS_AR_TAXES.POPULATE_RECEIPT_RECORDS' ,
                                    p_process_flag            =>  lv_process_flag                                     ,
                                    p_process_message         =>  lv_process_message                                  ,
                                    p_accounting_date         =>  rec_c_get_rec_app.gl_date
                                  );

            IF lv_process_flag = jai_constants.expected_error    OR
               lv_process_flag = jai_constants.unexpected_error
            THEN
              ln_receivable_application_id :=  rec_c_get_rec_app.receivable_application_id;
              ROLLBACK to roll_to_last_receivable;
              p_process_flag    := lv_process_flag    ;
              p_process_message := lv_process_message ;
              fnd_file.put_line( fnd_file.log, '16.1 error in call to jai_rgm_trx_recording_pkg.exc_gain_loss_accounting - lv_process_flag '||lv_process_flag
                                                ||', lv_process_message'||lv_process_message);
              EXIT;
            END IF;
     END IF;
     -- Added for Bug 8294236 - End

      /*########################################################################################################
      || update the effective cash receipt tax amount into the reference table
      ########################################################################################################*/

      fnd_file.put_line(fnd_file.LOG,' 12 before call to jai_cmn_rgm_recording_pkg.update_reference ' );

      savepoint before_ref_upd;
      jai_cmn_rgm_recording_pkg.update_reference (
                                                   p_source             => p_source                                ,
                                                   p_reference_id       => rec_c_get_refrec_for_upd.reference_id   ,
                                                   p_recovered_amount   => ln_eff_cr_tax_amount                    ,
                                                   p_discounted_amount  => ln_eff_cr_disc_amount                   ,
                                                   p_process_flag       => lv_process_flag                         ,
                                                   p_process_message    => lv_process_message
                                                 );


      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        /*
        || as Returned status is an error hence:-
        ||Set out variables p_process_flag and p_process_message accordingly
        */
        ln_receivable_application_id :=  rec_c_get_rec_app.receivable_application_id;
        ROLLBACK to roll_to_last_receivable;
        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        fnd_file.put_line( fnd_file.log, '12.1 error in call to jai_cmn_rgm_recording_pkg.update_reference - lv_process_flag '||lv_process_flag
                                          ||', lv_process_message'||lv_process_message);

        EXIT;
      END IF;

      fnd_file.put_line(fnd_file.LOG,' 13 Returned from jai_cmn_rgm_recording_pkg.update_reference ' );

    END LOOP;

    ln_uncommitted_transactions := ln_uncommitted_transactions  + 1;
    fnd_file.put_line(fnd_file.LOG,' 17 Finished processing the cash receipt ' );

    IF ln_uncommitted_transactions >= 50 THEN
      commit;
      ln_uncommitted_transactions := 0;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag    := jai_constants.unexpected_error;
    p_process_message := 'Unexpected error occured while processing jai_ar_rgm_processing_pkg.populate_receipt_records'||SQLERRM ;

END populate_receipt_records;





procedure process_records   ( p_regime_id          IN  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                ,
                              p_organization_type  IN  JAI_RGM_PARTIES.ORGANIZATION_TYPE%TYPE    ,
                              p_from_date          IN  DATE                                      ,
                              p_to_date            IN  DATE                                      ,
                              p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE           ,
                              p_batch_id           IN  JAI_RGM_TRX_REFS.BATCH_ID%TYPE            ,
                              p_process_flag OUT NOCOPY VARCHAR2                                  ,
                              p_process_message OUT NOCOPY VARCHAR2                               ,
                              p_organization_id     IN JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE DEFAULT NULL /*5879769*/
                            )
IS

  lv_source_ar              varchar2(2); --File.Sql.35 Cbabu  jai_constants.SOURCE_AR%TYPE                               ;
  lv_process_flag           VARCHAR2(2)                                                ;
  lv_process_message        VARCHAR2(1996)                                             ;
  lv_organization_id       jai_rgm_parties.organization_id%type;
BEGIN

  fnd_file.put_line(fnd_file.LOG,'############################## 1 START OF PROCEDURE TO jai_ar_rgm_processing_pkg.PROCESS_RECORDS ############################## ');

  /*########################################################################################################
  || VARIABLES INITIALIZATION
  ########################################################################################################*/

  lv_source_ar       := jai_constants.source_ar    ;

  lv_process_flag    := jai_constants.successful   ;
  lv_process_message := null                       ;

  p_process_flag     := lv_process_flag            ;
  p_process_message  := lv_process_message         ;

  fnd_file.put_line(fnd_file.LOG,'2 i/p is p_regime_id ->'||p_regime_id
                                  ||', p_regime_id         ->'||p_regime_id
                                  ||', p_organization_type ->'||p_organization_type
                                  ||', p_from_date         ->'||p_from_date
                                  ||', p_to_date           ->'||p_to_date
                                  ||', p_org_id            ->'||p_org_id
                                  ||', p_batch_id          ->'||p_batch_id
                    );


  /*########################################################################################################
  || PROCESS AR INVOICE AND CREDIT MEMO'S FOR REFERENCE ENTRIES
  ########################################################################################################*/

  fnd_file.put_line(fnd_file.LOG,'############################## 3 BEFORE CALL TO jai_ar_rgm_processing_pkg.POPULATE_INV_CM_REFERENCES ##############################');

  populate_inv_cm_references  (  p_regime_id         =>  p_regime_id             ,
                                 p_organization_type =>  p_organization_type     ,
                                 p_organization_id   =>  p_organization_id       ,/*5879769*/
                                 p_from_date         =>  p_from_date             ,
                                 p_to_date           =>  p_to_date               ,
                                 p_org_id            =>  p_org_id                ,
                                 p_batch_id          =>  p_batch_id              ,
                                 p_source            =>  lv_source_ar            ,
                                 p_process_flag      =>  lv_process_flag         ,
                                 p_process_message   =>  lv_process_message
                               );



  IF lv_process_flag = jai_constants.expected_error    OR
     lv_process_flag = jai_constants.unexpected_error
  THEN
    /*
    || As Returned status is an error hence:-
    || Set out variables p_process_flag and p_process_message accordingly
    */

    fnd_file.put_line( fnd_file.log, '4 ERROR IN CALL TO jai_ar_rgm_processing_pkg.POPULATE_INV_CM_REFERENCES - lv_process_flag '||lv_process_flag
                                      ||', lv_process_message'||lv_process_message);
    p_process_flag    := lv_process_flag    ;
    p_process_message := lv_process_message ;
  END IF;

   fnd_file.put_line(fnd_file.LOG,'############################## 5 RETURNED FROM jai_ar_rgm_processing_pkg.POPULATE_INV_CM_REFERENCES'||'lv_process_flag - '||lv_process_flag||
                                  ' lv_process_message- '||lv_process_message||'############################## ');


  /*########################################################################################################
  || DELETE NON INCOMPLETE/NON-EXISTING CREDIT MEMO'S
  ########################################################################################################*/

  /*
  || Reverse all those AR Credit Memo's which have been incompleted/incompleted
  || and deleted from base ar tables
  */
  fnd_file.put_line(fnd_file.LOG,'############################## 6 BEFORE CALL TO jai_ar_rgm_processing_pkg.DELETE_NON_EXISTANT_CM ############################## ');

  delete_non_existant_cm                (   p_regime_id          =>  p_regime_id             ,
                                            p_organization_type  =>  p_organization_type     ,
                                            p_organization_id   =>  p_organization_id       ,/*5879769*/
                                            p_from_date          =>  p_from_date             ,
                                            p_to_date            =>  p_to_date               ,
                                            p_org_id             =>  p_org_id                ,
                                            p_source             =>  lv_source_ar            ,
                                            p_batch_id           =>  p_batch_id              ,
                                            p_process_flag       =>  lv_process_flag         ,
                                            p_process_message    =>  lv_process_message
                                        );

  IF lv_process_flag = jai_constants.expected_error    OR
     lv_process_flag = jai_constants.unexpected_error
  THEN
    /*
    || As Returned status is an error hence:-
    || Set out variables p_process_flag and p_process_message accordingly
    */

    fnd_file.put_line( fnd_file.log, '7 ERROR IN CALL TO jai_ar_rgm_processing_pkg.DELETE_NON_EXISTANT_CM - lv_process_flag '||lv_process_flag
                                      ||', lv_process_message'||lv_process_message);
    p_process_flag    := lv_process_flag    ;
    p_process_message := lv_process_message ;
  END IF;


  fnd_file.put_line(fnd_file.LOG,'############################## 8 RETURNED FROM jai_ar_rgm_processing_pkg.DELETE_NON_EXISTANT_CM'||'lv_process_flag - '||lv_process_flag||
                                  ' lv_process_message- '||lv_process_message||'############################## ');


  /*########################################################################################################
  || PROCESS AR CREDIT MEMO APPLICATIONS AGAINST INVOICES
  ########################################################################################################*/


  fnd_file.put_line(fnd_file.LOG,'############################## 9 BEFORE CALL TO jai_ar_rgm_processing_pkg.POPULATE_CM_APP ############################## ');

  populate_cm_app   ( p_regime_id          =>  p_regime_id             ,
                      p_organization_type  =>  p_organization_type     ,
                      p_organization_id    =>  p_organization_id       ,/*5879769*/
                      p_from_date          =>  p_from_date             ,
                      p_to_date            =>  p_to_date               ,
                      p_org_id             =>  p_org_id                ,
                      p_source             =>  lv_source_ar            ,
                      p_batch_id           =>  p_batch_id              ,
                      p_process_flag       =>  lv_process_flag         ,
                      p_process_message    =>  lv_process_message
                    );


  IF lv_process_flag = jai_constants.expected_error    OR
     lv_process_flag = jai_constants.unexpected_error
  THEN
    /*
    || As Returned status is an error hence:-
    || Set out variables p_process_flag and p_process_message accordingly
    */
    fnd_file.put_line( fnd_file.log, '10 error in call to jai_ar_rgm_processing_pkg.populate_cm_app - lv_process_flag '||lv_process_flag
                                      ||', lv_process_message'||lv_process_message);
    p_process_flag    := lv_process_flag    ;
    p_process_message := lv_process_message ;
  END IF;


   fnd_file.put_line(fnd_file.LOG,'############################## 11 RETURNED FROM CALL TO jai_ar_rgm_processing_pkg.POPULATE_CM_APP '||'lv_process_flag - '||lv_process_flag||
                                  ' lv_process_message- '||lv_process_message||'##############################');


  /*########################################################################################################
  || PROCESS AR CASH RECEIPT APPLICATIONS AGAINST INVOICES
  ########################################################################################################*/


  fnd_file.put_line(fnd_file.LOG,'############################## 12 BEFORE CALL TO jai_ar_rgm_processing_pkg.POPULATE_RECEIPT_RECORDS ##############################');

  populate_receipt_records   ( p_regime_id          =>  p_regime_id             ,
                               p_organization_type  =>  p_organization_type     ,
                               p_organization_id   =>  p_organization_id       ,/*5879769*/
                               p_from_date          =>  p_from_date             ,
                               p_to_date            =>  p_to_date               ,
                               p_org_id             =>  p_org_id                ,
                               p_batch_id           =>  p_batch_id              ,
                               p_source             =>  lv_source_ar            ,
                               p_process_flag       =>  lv_process_flag         ,
                               p_process_message    =>  lv_process_message
                             );

  IF lv_process_flag = jai_constants.expected_error    OR
     lv_process_flag = jai_constants.unexpected_error
  THEN
    /*
    || As Returned status is an error hence:-
    || Set out variables p_process_flag and p_process_message accordingly
    */
    fnd_file.put_line( fnd_file.log, '13 ERROR IN CALL TO jai_ar_rgm_processing_pkg.POPULATE_RECEIPT_RECORDS - lv_process_flag '||lv_process_flag
                                      ||', lv_process_message'||lv_process_message);
    p_process_flag    := lv_process_flag    ;
    p_process_message := lv_process_message ;
  END IF;

  fnd_file.put_line(fnd_file.LOG,'##############################14 RETURNED FROM jai_ar_rgm_processing_pkg.POPULATE_RECEIPT_RECORDS'||'lv_process_flag - '||lv_process_flag||
                                  ' lv_process_message- '||lv_process_message||'##############################');


  fnd_file.put_line(fnd_file.LOG,'############################## 15 END OF PROCEDURE TO jai_ar_rgm_processing_pkg.PROCESS_RECORDS - ##############################');

EXCEPTION
  WHEN OTHERS THEN
    lv_process_flag    := jai_constants.unexpected_error;
    lv_process_message := ' 16 Unexpected error occured while processing jai_ar_rgm_processing_pkg.process_records'||SQLERRM ;

END process_records;

END jai_ar_rgm_processing_pkg ;

/
