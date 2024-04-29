--------------------------------------------------------
--  DDL for Package Body JAI_FA_MA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_FA_MA_TRIGGER_PKG" AS
/* $Header: jai_fa_ma_t.plb 120.1 2007/07/05 12:45:46 brathod ship $ */

/*  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_FA_MA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_FA_MA_ARI_T1
  REM
  REM +======================================================================+

  ------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  1.  09/05/2007   brathod, Bug#5763527 - File Version 120.1
                   Forward Ported 11i Bug 5763527
  ------------------------------------------------------------------------------------------------------------

  */
 PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   /* cursor c_ap_invoice_distributions_all
  (p_invoice_id number, p_distribution_line_number  number) is
    select  line_type_lookup_code,
            po_distribution_id,
            rcv_transaction_id,
            set_of_books_id
    from    ap_invoice_distributions_all
    where   invoice_id = p_invoice_id
    and     distribution_line_number = p_distribution_line_number;*/
  /*
  || rchandan for bug#4454657 commented the above and added the following cursor
  */
  cursor c_ap_invoice_lines_all
  (p_invoice_id number, p_line_number  number) is
    select  line_type_lookup_code,
            po_distribution_id,
            rcv_transaction_id,
            set_of_books_id
    from    ap_invoice_lines_all /*rchandan for bug#4428980*/
    where   invoice_id = p_invoice_id
    and     line_number = p_line_number;

  cursor c_gl_sets_of_books(p_set_of_books_id number) is
    select  currency_code
    from    gl_sets_of_books
    where   set_of_books_id = p_set_of_books_id;

  cursor c_rcv_transactions(p_transaction_id number) is
    select  shipment_line_id,
            vendor_id
    from    rcv_transactions
    where   transaction_id = p_transaction_id;

  /* Added by LGOPALSA. Bug 4210102.
   * Added CVD and Customs Education Cess */

  cursor  c_ja_in_receipt_tax_lines(p_shipment_line_id number, p_po_vendor_id number) is
    select  count(1)
    from    JAI_RCV_LINE_TAXES
    where   shipment_line_id = p_shipment_line_id
    and     nvl(tax_amount, 0) <> 0
    and
            (
              (upper(tax_type) in
           ( jai_constants.tax_type_cvd, /*--'CVD', 'CUSTOMS', Ramananda for removal of SQL LITERALs */
            jai_constants.tax_type_customs,
                  jai_constants.tax_type_customs_edu_cess,
                  jai_constants.tax_type_cvd_Edu_cess))
                              /* BOE Tax */
              or
              (upper(tax_type) not in --('TDS', 'MODVAT RECOVERY') /* Third party tax */
        (
               jai_constants.tax_type_tds,
         jai_constants.tax_type_modvat_recovery
         )
              and  vendor_id > 0
              and  vendor_id <> p_po_vendor_id
              )
            );

  cursor c_ja_in_fa_mass_additions(p_parent_request_id  number) is
    select  count(1)
    from    JAI_FA_MASS_ADDITIONS
    where   create_batch_id = p_parent_request_id
    and     process_flag <> 'Y';


  r_ap_invoice_lines_all        c_ap_invoice_lines_all%rowtype;   /*rchandan for bug#4454657*/
  r_rcv_transactions                    c_rcv_transactions%rowtype;
  r_ja_in_receipt_tax_lines             c_ja_in_receipt_tax_lines%rowtype;
  r_gl_sets_of_books                    c_gl_sets_of_books%rowtype;
  ln_boe_3p_count                       number:=0;
  lb_result                             boolean;
  ln_req_id                             number;
  ln_first_record                       number := 0;


  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------
    Filename: ja_in_fa_mass_additions_boe3p_trg.sql

    CHANGE HISTORY:

    S.No    dd/mm/yyyy      Author and Details
    ----    -------         ------------------
    1       22/07/2004      Aparajita. Version # 115.0. Created for ER#3575112.

                Enhancement is done for bringing over the third party
                and the BOE taxes attahed to a receipt to fixed asset
                cost whenever the payable invoice against the receipt
                is processed by the mass additions create program.

                BOE and third party taxes do not flow into the invoice
                that is created against the receipt. Third party taxes
                become one or more 3rd party invoices where as BOE is
                matched against the BOE invoice already raised.

                This trigger is populating data into the localization
                fa mass additions table for invoices being processed
                by base. Data in this table is further processed by
                localization concurrent 'India Local Mass Additions'
                to populate data on to the fa mass additions table
                with references to PO/ Receipt and payable invoice.

    2.   29/11/2004  ssumaith - bug# 4037690  - File version 115.1
                       Check whether india localization is being used was done using a INR check in every trigger.
                       This check has now been moved into a new package and calls made to this package from this trigger
                       If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                       Hence if this function returns FALSE , control should return.

    3.   12/Mar/05   Bug 4210102. Added by LGOPALSA  - Version 115.2
                     (1) Added CVD and Customs education Cess
         (2) Added check file syntax in dbdrv command

    4.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                       DB Entity as required for CASE COMPLAINCE.  Version 116.1

    5. 10-Jun-2005    File Version: 116.2
                          Removal of SQL LITERALs is done

    6.  24-Jun-2005    rchandan for bug#4454657,File Version: 116.3
                       Modified the object as a part of AP LINES Impact Uptake
                 A column invoice_line_number ie added to jai_fa_mass_additions.
                 The ap_invoice_lines_all is used instead of ap_invoice_distributions_all while querying wherever applicable.

    Future Dependencies For the release Of this Object:-
    (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
    A datamodel change )
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
    Of File                           On Bug/Patchset    Dependent On

    ja_in_fa_mass_additions_boe3p_trg.sql
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                         ja_in_util_pkg_s.sql  115.0     ssumaith

    115.2              4210102        IN60106 +                                          LGOPALSA 12-Mar-2005  Added cess implementation
                                      4146708

    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


      /* check if invoice is against a receipt */
      open c_ap_invoice_lines_all
      (pr_new.invoice_id, pr_new.invoice_line_number);
      fetch c_ap_invoice_lines_all into r_ap_invoice_lines_all;
      close c_ap_invoice_lines_all;

      --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JAI_FA_MA_ARI_T1', P_SET_OF_BOOKS_ID => r_ap_invoice_lines_all.set_of_books_id) = false then
      --   return;
      --end if;

      /*The following code has been commented and added the above code instead - ssumaith - bug# 4037690*/

     /* open  c_gl_sets_of_books(r_ap_invoice_distributions_all.set_of_books_id);
      fetch c_gl_sets_of_books into r_gl_sets_of_books;
      close c_gl_sets_of_books;
    */
      /* check if functional currency is INR, if not there is no need to process further */

     /*
      if nvl(r_gl_sets_of_books.currency_code, 'XXX') <> 'INR' then
        return;
      end if;
     */

      if  r_ap_invoice_lines_all.line_type_lookup_code not in  ('ITEM', 'ACCRUAL')  then
        /* the invoice distribution line being processed is not an item line.*/
        /* no need to check for existance of receipt taxes against it.*/
        return;
      end if;

     if  r_ap_invoice_lines_all.po_distribution_id is null or
          r_ap_invoice_lines_all.rcv_transaction_id is null then
        /* PO and/or Receipt references does not exist, no need to process */
        return;
      end if;

      open c_rcv_transactions(r_ap_invoice_lines_all.rcv_transaction_id);
      fetch c_rcv_transactions into r_rcv_transactions;
      close c_rcv_transactions;

      /*  All validations are over at this point, now check if BOE or third party tax exists */
      open c_ja_in_receipt_tax_lines(r_rcv_transactions.shipment_line_id, r_rcv_transactions.vendor_id);
      fetch c_ja_in_receipt_tax_lines into ln_boe_3p_count;
      close c_ja_in_receipt_tax_lines;

      if ln_boe_3p_count <=  0 then
        /* BOE or third party type of taxes do not exist for the item line */
        return;
      end if;

      insert into JAI_FA_MASS_ADDITIONS
      (
      mass_addition_id,
      invoice_id,
      distribution_line_number,
      invoice_line_number,   /*rchandan for bug#4454657*/
      process_flag,
      book_type_code,
      date_placed_in_service,
      create_batch_date,
      invoice_number,
      invoice_date,
      vendor_number,
      po_number,
      DEPRECIATE_STATUS,
      asset_type,
      accounting_date,
      payables_code_combination_id,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by,
      create_batch_id
      )
      values
      (
      pr_new.mass_addition_id,
      pr_new.invoice_id,
      pr_new.ap_distribution_line_number,
      pr_new.invoice_line_number,
      'N',
      pr_new.book_type_code,
      pr_new.date_placed_in_service,
      pr_new.create_batch_date,
      pr_new.invoice_number,
      pr_new.invoice_date,
      pr_new.vendor_number,
      pr_new.po_number,
      pr_new.depreciate_flag,
      pr_new.asset_type,
      pr_new.accounting_date,
      pr_new.payables_code_combination_id,
      pr_new.created_by,
      pr_new.creation_date,
      pr_new.last_update_login,
      pr_new.last_update_date,
      pr_new.last_updated_by,
      pr_new.create_batch_id
      );

      open c_ja_in_fa_mass_additions(pr_new.create_batch_id);
      fetch c_ja_in_fa_mass_additions into ln_first_record;
      close c_ja_in_fa_mass_additions;

      if nvl(ln_first_record, 0) > 1 then
        /* Not the firstrecord to be inserted by the trigger for the batch
           No need to invoke the concurrent */
        return;
      end if;

      lb_result := Fnd_Request.set_mode(TRUE);
      ln_req_id := Fnd_Request.submit_request
      ('JA',
      'JAINMACR',
      'India - Mass Additions Create',
      '',
      false,
       pr_new.create_batch_id
      );
    /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_FA_MA_TRIGGER_PKG.ARI_T1 '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_FA_MA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_FA_MA_BRI_T2
  REM
  REM +======================================================================+
  */
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_modvat_per                NUMBER;
    v_mod_per_diff              NUMBER;

    /*CURSOR c_get_line_info IS
    SELECT A.invoice_id,
           A.rcv_transaction_id,
           A.distribution_line_number,
           A.line_type_lookup_code,
           A.amount
      FROM JAI_CMN_FA_INV_DIST_ALL A, ap_invoice_distributions_all B
     WHERE A.line_type_lookup_code    NOT like 'ITEM'
       AND B.invoice_id = pr_new.invoice_id
   AND A.INVOICE_ID = B.INVOICE_ID
       AND A.distribution_line_number = B.distribution_line_number
       AND B.distribution_line_number = pr_new.ap_distribution_line_number;*/

  /*
  || rchandan for bug#4454657 commented the aboce cursor and following cursor has been added by rchandan for ap lines change
  */
  CURSOR c_get_line_info IS
    SELECT A.rcv_transaction_id
      FROM jai_ap_match_inv_taxes A, ap_invoice_lines_all B  /*  rchandan for bug#4454657 JAI_CMN_FA_INV_DIST_ALL is obsolete and so replaced by JAI_AP_MATCH_INV_TAXES */
     WHERE A.line_type_lookup_code    NOT like 'ITEM'
       AND B.invoice_id = pr_new.invoice_id
       AND A.INVOICE_ID = B.INVOICE_ID
       AND A.invoice_line_number = B.line_number
       AND B.line_number = pr_new.invoice_line_number;


  CURSOR c_get_ship_head_id(p_rcv_transaction_id NUMBER) is
    SELECT shipment_header_id,
           shipment_line_id
      FROM rcv_transactions
     WHERE transaction_id = p_rcv_transaction_id;


  CURSOR item_mod_cur(c_shipment_line_id number) IS
    SELECT jmsi.modvat_flag
      FROM JAI_INV_ITM_SETUPS jmsi,
           rcv_shipment_lines rsl
     WHERE rsl.shipment_line_id = c_shipment_line_id
       AND jmsi.organization_id = rsl.to_organization_id
       AND jmsi.inventory_item_id = rsl.item_id;


  CURSOR dist_tax_cur IS
    SELECT b.mod_cr_percentage,
           a.tax_id
          ,a.parent_invoice_distribution_id   -- 5763527
          ,a.line_no                          -- 5763527
      FROM JAI_AP_MATCH_INV_TAXES a,
           JAI_CMN_TAXES_ALL b
     WHERE a.invoice_id = pr_new.invoice_id
       AND a.invoice_line_number = pr_new.invoice_line_number   /*rchandan for bug#4454657*/
       AND a.tax_id = b.tax_id;


  CURSOR c_get_receipt_details(p_ship_head_id NUMBER) IS
    SELECT receipt_num,
           shipment_header_id
      FROM rcv_shipment_headers
     WHERE shipment_header_id =p_ship_head_id;


  CURSOR c_get_modvat_details(p_ship_head_id NUMBER,p_ship_line_id NUMBER) IS
    SELECT mfg_trading
      FROM JAI_RCV_LINES
     WHERE shipment_header_id = p_ship_head_id
       AND shipment_line_id = p_ship_line_id;


  CURSOR c_get_rcp_tax_details(c_ship_line_id NUMBER, c_tax_id number) IS
    SELECT tax_amount,
           modvat_flag
      FROM JAI_RCV_LINE_TAXES
     WHERE shipment_line_id = c_ship_line_id
       AND tax_id = c_tax_id;


  CURSOR c_set_of_books is
  SELECT set_of_Books_id
  FROM   ap_invoices_all
  WHERE  invoice_id = pr_new.invoice_id; /*rchandan for bug#4454657*/

  c_get_line_info_rec          c_get_line_info%ROWTYPE ;
  c_get_ship_head_id_rec       c_get_ship_head_id%ROWTYPE;
  c_get_modvat_details_rec     c_get_modvat_details%ROWTYPE;
  c_get_receipt_details_rec    c_get_receipt_details%ROWTYPE;
  c_get_rcp_tax_details_rec    c_get_rcp_tax_details%ROWTYPE;
  dist_tax_rec                 dist_tax_cur % rowtype;
  item_mod_rec                 item_mod_cur % rowtype;
  ln_set_of_books_id           gl_sets_of_books.set_of_books_id%type;

  --
  -- Begin 5763527
  --
  ln_cnt  number;
  cursor c_get_tax_line_cnt (cp_tax_id              JAI_AP_MATCH_INV_TAXES.tax_id%type
                            ,cp_parent_inv_dist_id  JAI_AP_MATCH_INV_TAXES.parent_invoice_distribution_id%type
                            ,cp_tax_line_num        JAI_AP_MATCH_INV_TAXES.line_no%type
                            )
  is
    select count(1)
    from   JAI_AP_MATCH_INV_TAXES a
    where  a.invoice_id = pr_new.invoice_id
    and    a.parent_invoice_distribution_id = cp_parent_inv_dist_id
    and    a.tax_id = cp_tax_id
    and    a.line_no = cp_tax_line_num ;
  --
  -- End 5763527
  --


  BEGIN
    pv_return_code := jai_constants.successful ;
   /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_fa_mass_add_trg1.sql

 CHANGE HISTORY:

S.No      Date          Author and Details

1.  2002/06/07        RPK: For BUG#2391562

                1.For updating the date format of the column attribute1 of the table
                        fa_mass_addtions_b for the assets added thru the ADI tool.The assets will
                        be interfaced from the legacy system to the fa_mass_additions table
                        thru ADI or any other data migration tool.The date format of the columns will
                        be maintained same as that of the valueset for the report
                        'India Income fixed assets schedule' ie 'DD-MON-RRRR'.Now,the user will be
                        able to query the assets added through ADI.

2.  30/03/2004         Aparajita for bug#3448803. Version#619.1
                       Removed the when condition for checking the context = 'India B Of Assets' as this
                       context is not used at the time of inserting records into FA_MASS_ADDITIONS. The process
                       here is mass additions create and the dff is not used at that point.

                       There was no need to put extra condtion as the cursor dist_tax_cur would return null for
                       non localization record and the control would return from here.

3.    29-nov-2004  ssumaith - bug# 4037690  - File version 115.1
                   Check whether india localization is being used was done using a INR check in every trigger.
                   This check has now been moved into a new package and calls made to this package from this trigger
                   If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                   Hence if this function returns FALSE , control should return.

4.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                   DB Entity as required for CASE COMPLAINCE.  Version 116.1

5. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

6.  24-Jun-2005    rchandan for bug#4454657,File Version: 116.3
                   Modified the object as a part of AP LINES Impact Uptake
             A column invoice_line_number ie added to jai_fa_mass_additions.
             The ap_invoice_lines_all is used instead of ap_invoice_distributions_all while querying wherever applicable.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_fa_mass_add_trg1.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* pr_new.Attribute1 := TO_CHAR(TO_DATE(pr_new.Attribute1, 'DD/MM/YYYY'),'DD-MON-RRRR'); */

  OPEN dist_tax_cur;
  FETCH dist_tax_cur INTO dist_tax_rec;
  CLOSE dist_tax_cur;

  IF dist_tax_rec.tax_id IS NULL  THEN
      RETURN;
  END IF;

  --
  -- Brathod, 5763527
  --
  if dist_tax_rec.mod_cr_percentage > 0 and dist_tax_rec.mod_cr_percentage < 100 then
    ln_cnt := 0;
    open  c_get_tax_line_cnt (dist_tax_rec.tax_id, dist_tax_rec.parent_invoice_distribution_id, dist_tax_rec.line_no);
    fetch c_get_tax_line_cnt into ln_cnt;
    close c_get_tax_line_cnt ;

    if ln_cnt > 1 then
    --
    --  For a partially recoverable tax line two split already exists hence no need to do further processing
    --  for the legacy lines (lines which exists for uptaking the projects) only one line will exists and
    --  apportionment is required
    --
      return;
    end if;
  end if;
  --
  -- End 5763527
  --



  /*The following code has added - ssumaith - bug# 4037690*/

  open  c_set_of_books;
  fetch c_set_of_books into ln_set_of_books_id;
  close c_set_of_books;

  --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_FA_MASS_ADD_TRG1', P_SET_OF_BOOKS_ID => ln_set_of_books_id) = false then
  --  return;
  --end if;

  /* ends here*/

  OPEN c_get_line_info;
  FETCH c_get_line_info INTO c_get_line_info_rec;
  CLOSE c_get_line_info;

  OPEN c_get_SHIP_head_id(c_get_line_info_rec.rcv_transaction_id);
  FETCH c_get_ship_head_id INTO c_get_ship_head_id_rec;
  CLOSE c_get_ship_head_id;

  OPEN c_get_modvat_details(c_get_ship_head_id_rec.shipment_header_id, c_get_ship_head_id_rec.shipment_line_id);
  FETCH c_get_modvat_details INTO c_get_modvat_details_rec;
  CLOSE c_get_modvat_details;

  OPEN c_get_receipt_details(c_get_ship_head_id_rec.shipment_header_id);
  FETCH c_get_receipt_details INTO c_get_receipt_details_rec;
  CLOSE c_get_receipt_details;

  OPEN item_mod_cur(c_get_ship_head_id_rec.shipment_line_id);
  FETCH item_mod_cur INTO item_mod_rec;
  CLOSE item_mod_cur;

  OPEN c_get_rcp_tax_details(c_get_ship_head_id_rec.shipment_line_id, dist_tax_rec.tax_id);
  FETCH c_get_rcp_tax_details INTO c_get_rcp_tax_details_rec;
  CLOSE c_get_rcp_tax_details;



--   IF NVL(item_mod_rec.modvat_flag, 'N') = 'Y' AND
   --   NVL(c_get_modvat_details_rec.mfg_trading_flag, '#') = 'YN' AND
    IF  NVL(c_get_rcp_tax_details_rec.modvat_flag, 'N') = 'Y'
  THEN

    v_modvat_per := dist_tax_rec.mod_cr_percentage;

    IF nvl(v_modvat_per, 0) > 0 THEN
       v_mod_per_diff := 100 - nvl(v_modvat_per, 0);
       pr_new.Fixed_Assets_Cost := pr_new.Fixed_Assets_Cost * v_mod_per_diff / 100;

       pr_new.payables_cost := pr_new.payables_cost * v_mod_per_diff / 100;
    END IF;
  END IF;
    /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_FA_MA_TRIGGER_PKG.BRI_T1 '  || substr(sqlerrm,1,1900);
  END BRI_T1 ;

END JAI_FA_MA_TRIGGER_PKG ;

/
