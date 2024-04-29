--------------------------------------------------------
--  DDL for Package Body JAI_AP_MATCH_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_MATCH_TAX_PKG" 
/* $Header: jai_ap_match_tax.plb 120.34.12010000.15 2010/04/15 10:40:48 boboli ship $ */
AS

/*  Bug 5401111. Added by Lakshmi Gopalsami
 |  Created private procedure for getting Account type.
 |  This procedure call will have performance issue. Later we need
 |  to implement this call using caching logic.
 */
FUNCTION get_gl_account_type
 ( cp_code_combination_id IN NUMBER  )
 RETURN VARCHAR2
IS
  CURSOR get_account_type IS
  SELECT account_type
    FROM gl_code_combinations
   WHERE code_combination_id = cp_code_combination_id ;

  lv_account_type gl_code_combinations.account_type%TYPE;
BEGIN
 OPEN get_account_type;
  FETCH get_account_type INTO lv_account_type;
 CLOSE get_account_type;
 RETURN lv_account_type;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'X'; -- if required exception can be handled.
END ;

/*Removed the function check_service_interim_account from process_online and process_batch_record procedure
  and added here for bug#6833506 by JMEENA */

 function check_service_interim_account /* Service */
  (
    p_accrue_on_receipt_flag     varchar2,
    p_accounting_method_option   varchar2,
    p_is_item_an_expense         varchar2,
    p_service_regime_id          number,
    p_org_id                     number,
    p_rematch                    varchar2,
    p_tax_type                   varchar2,
    po_dist_id       NUMBER   --Added by JMEENA for bug#6833506
  )
  return number is

    lb_charge_service_interim         boolean;
    ln_service_interim_account        number;


 /*5694855..start* kunkumar for forward porting to R12*/
                        CURSOR cur_fetch_io IS
                        SELECT ship_to_organization_id,
                                                 ship_to_location_id
                                FROM po_line_locations_all
                         WHERE line_location_id IN ( SELECT line_location_id

                      FROM po_distributions_all
WHERE po_distribution_id = po_dist_id) ;

    ln_organization_id                NUMBER;
    ln_location_id                    NUMBER;

    /*5694855..end*/



  begin

    /* Bug 5358788. Added by Lakshmi Gopalsami
     * Commented out the check for p_rematch = 'PO_MATCHING'
     */

    if p_accrue_on_receipt_flag = 'N'
       /*(
        (p_rematch = 'PO_MATCHING' and p_accrue_on_receipt_flag = 'N')
        or
        (p_accounting_method_option = 'Cash' and  p_is_item_an_expense = 'Y')
       )*/
    then
      lb_charge_service_interim := true;
    else
      lb_charge_service_interim := false;
    end if;

    if lb_charge_service_interim then

      OPEN cur_fetch_io;/*5694855*/
      FETCH cur_fetch_io INTO ln_organization_id,ln_location_id;
      CLOSE cur_fetch_io;

      ln_service_interim_account :=
      jai_cmn_rgm_recording_pkg.get_account
      (
       p_regime_id            =>      p_service_regime_id,
  p_organization_type    =>      jai_constants.orgn_type_io,/*5694855*/
         p_organization_id      =>      ln_organization_id,/*5694855*/
         p_location_id          =>      ln_location_id, /*5694855*/
p_tax_type             =>      p_tax_type,
       p_account_name         =>      jai_constants.recovery_interim
      );

      return ln_service_interim_account;

    else
      return null;
    end if;

END check_service_interim_account; /* Service */

PROCEDURE process_batch
(
p_errbuf OUT NOCOPY VARCHAR2,
p_retcode OUT NOCOPY VARCHAR2,
p_org_id              IN        number, -- added by bug#3218695
p_process_all_org     IN        varchar2 -- added by bug#3218695
)
IS
  v_errbuf                VARCHAR2(1996);
  v_retcode               VARCHAR2(1996);
  v_prev_invoice_id       NUMBER(15);
  v_rowid                 ROWID;
  v_error_invoice         CHAR(1);
  error_from_called_unit  EXCEPTION;
  v_error_mesg            VARCHAR2(200);
  v_invoice_number        VARCHAR2(50);
  v_org_id                number; -- added by bug#3218695



/* ------------------------------------------------------------------------------------------------------------------------
FILE NAME     : jai_ap_match_tax_pkg.process_batch_p.sql
CHANGE HISTORY:
S.No      DATE                Author AND Details
---------------------------------------------------------------------------------------------------------------------------
1         05-may-2002         Aparajita, Created this procedure. bug # 2359737 (enhancement for ti)
                              This trigger was created to move the processing of invoice lines while invoices get generated
                              from purchasing with pay on receipt option. the concurrent was getting submitted for every item
                              lines of the invoice, to generate associate tax lines. With this procedure all such invoice lines
                              will be processed as 1 concurrent. The temporary table used here is being populated from the
                              trigger ja_in_tds_temp_after_insert_trg on ap_invoice_distributions_all. The main concepts
                              used here are,
                              - if an error occurs while processing a particular record, the program will skip processing
                                all other distributions lines of the error invoice.
                              - the program will continue to process other invoices.
                              - the program will update the temporary table for an error record, with error flag time and error
                              - if a particular line has error flag set to 'Y', this program will not pick up that record and
                                also all other lines pertaining to such an error invoice.

2.      30-oct-2003           Aparajita. bug#3218695. Version#616.1.
                              Intrduced parameters p_org_id(current operating unit) and p_process_all_org(Y/N).

                              If p_process_all_org is Y, this program processed records of all operating units. When
                              p_process_all_org is 'N', records pertaining to org id p_org_id is only peocessed.

3.    08-Jun-2005             Version 116.2 jai_ap_match_tax -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                               as required for CASE COMPLAINCE.

4.    22-Jun-05               rallamse bug#4448789 116.3 Pefomed LE changes by adding legal_entity_id at the required places

5.    03-Feb-2006         avallabh for bug 4926094. Version 120.4.
        Modified the cursor c_dist_reversal_cnt to check for rownum=1, to enhance performance.
        Removed the default initialization of v_dist_reversal_cnt to 0 and added it just before
        opening the cursor and assigning the value to the variable.


6.    01/11/2006    SACSETHI for bug 5228046, File version 120.8
                          Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                    This bug has datamodel and spec changes.

7.    13-April-2007   ssawant for bug 5989740 ,File version 120.13
                      Forward porting Budget07-08 changes of handling secondary and
                Higher Secondary Education Cess from 11.5( bug no 5907436) to R12 (bug no 5989740).
          Changes were done for following files
          ja_in_pay_on_recpt_dist_match_p.sql;
8.   27-jun-2007      kunkumar for made changes for bug#5593895.File version 120.14
                       removed project changes for RUP03

9.   05/07/2007      brathod, for Bug# 5763527, File Version 120.19
                     FP: 11.5.9 - 12.0:FORWARD PORTING FROM 115 BUG 5763527
10.  16-07-2007      Changed shipment_num to shipment_number
                             excise_inv_num to excise_inv_number in jai_cmn_lines table
11.   24-oct-2007     vkaranam for bug#6457733,File version 120.25
                     Issue:
         UNABLE TO FIND LOV VALUES IN INDIA - TO INSERT TAXES  FOR PAY ON RECEIPT"
         Changes are done in  process_batch procedure

12. 31-oct-2007 Bug 6595773 File version 120.7.12000000.5
        Forward ported the changes done for bug 5416515 - AP ACCRUAL ACCOUNT IS NOT DEBITED FOR
        VAT TAXES IN INVOICE DISTRIBUTION

13.   20-Dec-2007   Eric modified and added code for the inclusive tax

14.   09-JAN-2008   Jason Liu
                    Modified for Retroactive Price

15. 18-Feb-2010 CSahoo for bug#9386496, File Version 120.34.12010000.13
                Issue: TAXES ARE GETTING INSERTED WITH PO EXPENSE ACCOUNT INSTEAD OF SERVICE TAX INTERI
                Fix: Added NVl condition to the parameter po_dist_id in the call to the function
                     check_service_interim_account.

Future Dependencies For the release Of this Object:-
==================================================
(Please add a row in the section below only if your bug introduces a dependency due to spec change/
A new call to a object/A datamodel change )

------------------------------------------------------------------------------------------------------
Version       Bug       Dependencies (including other objects like files if any)
-------------------------------------------------------------------------------------------------------
616.1         3218695   This fix introduced two input parameters p_org_id and p_process_all_org.
                        The associated ldt for concurrent registration is the dependency..


------------------------------------------------------------------------------------------------------------------------ */
BEGIN


  Fnd_File.put_line(Fnd_File.LOG, 'Start procedure - jai_ap_match_tax_pkg.process_batch');

  -- this cursor picks up the invoice lines from the temporary table but does not pick up such invoices which have
  -- error_flag set to 'Y' for any of it's distribution lines.

  -- start added by bug#3218695
  if p_process_all_org = 'Y' then
    v_org_id := null;
  else
    v_org_id := p_org_id;
  end if;
  -- end added by bug#3218695

  FOR  c_rec IN
  (
SELECT
    temp.ROWID,
    temp.invoice_id,
    temp.invoice_line_number,
    temp.po_distribution_id,
    temp.quantity_invoiced,
    temp.shipment_header_id,
    temp.receipt_num,
    temp.receipt_code,
    temp.rematching,
    temp.rcv_transaction_id,
    temp.amount,
    --project_id,
    --task_id,
    --expenditure_type,
    --expenditure_organization_id,
    --expenditure_item_date,
    temp.org_id
    /* 5763527 */
    ,apla.project_id
    ,apla.task_id
    ,apla.expenditure_type
    ,apla.expenditure_organization_id
    ,apla.expenditure_item_date
    /* End 5763527 */
   FROM JAI_AP_MATCH_ERS_T          temp
       ,ap_invoice_lines_all apla  -- 5763527
   WHERE  temp.invoice_id NOT IN
     (SELECT invoice_id
      FROM   JAI_AP_MATCH_ERS_T
      WHERE  error_flag = 'Y'
      )
   AND ( (v_org_id is null and mo_global.check_access(temp.org_id)='Y' )
         OR ( (v_org_id is not null) and  (temp.org_id = v_org_id) )
       ) ----added and mo_global.check_access(org_id)='Y' for bug#6457733, added by bug#3218695
   /* 5763527 */
   and  apla.invoice_id = temp.invoice_id
   and  apla.line_number = temp.invoice_line_number
   --and  aida.invoice_distribution_id = temp.invoice_distribution_id
   /* End 5763527 */
   ORDER BY  invoice_id, invoice_line_number
  )
  LOOP

   BEGIN

    v_rowid := c_rec.ROWID;
    v_errbuf := NULL;
    v_retcode := NULL;
    v_error_mesg := NULL;


    -- Check if the first record from the cursor is being processed.

    IF v_prev_invoice_id IS NULL THEN

     -- processing first invoice,
      -- assign current to previous, no need to check change in invoice and initialize eror invoice flag.

      v_prev_invoice_id :=  c_rec.invoice_id;
      v_error_invoice := 'N';

    ELSE

      -- not processing the first record.
      -- check if there is a change in invoice, that is a new invoice line is being picked up for processing.

      IF  v_prev_invoice_id = c_rec.invoice_id THEN

        -- different line of the same invoice is being picked up for processing.
        -- check if an error has alreay happened for any previous lines of the invoice skip the record.

        IF  v_error_invoice = 'Y' THEN
          -- error has already happened for an earlier distribution line of the same invoice, skip the record.
          GOTO continue_with_next;
        END IF;

      ELSE

        -- a different invoice is picked up for processing,
        -- commit for the previous invoice and also delete from temp for the previous invoice if no error has happened.

        IF  v_error_invoice <> 'Y' THEN

          -- not an error invoice, do the invoice level processing.
          DELETE  JAI_AP_MATCH_ERS_T
          WHERE   invoice_id = v_prev_invoice_id;

          COMMIT;
          -- get the invoice number for writing onto the log file.
          SELECT invoice_num
          INTO   v_invoice_number
          FROM   ap_invoices_all
          WHERE  invoice_id = v_prev_invoice_id;

          Fnd_File.put_line(Fnd_File.LOG, ' Processed invoice number(id) : ' || v_invoice_number || '(' || v_prev_invoice_id || ')' );

        END IF;

        -- set the prev to current.
        v_prev_invoice_id :=  c_rec.invoice_id;
        v_error_invoice := 'N';

      END IF; -- different invoice

    END IF; -- not first invoice

    -- the control comes here only when no error has happened.
    -- for each record call distribution matching procedure to process the invoice.
    -- invoice has not hit error for earlier lines if any.


    jai_ap_match_tax_pkg.process_batch_record
    (
    v_errbuf,
    c_rec.invoice_id,
    c_rec.invoice_line_number,
    c_rec.po_distribution_id,
    c_rec.quantity_invoiced,
    c_rec.shipment_header_id,
    c_rec.receipt_num,
    c_rec.receipt_code,
    c_rec.rematching,
    c_rec.rcv_transaction_id,
    c_rec.amount,
    --c_rec.project_id,
    --c_rec.task_id,
    --c_rec.expenditure_type,
    --c_rec.expenditure_organization_id,
    --c_rec.expenditure_item_date,
    c_rec.org_id
    /* 5763527 */
    ,c_rec.project_id
    ,c_rec.task_id
    ,c_rec.expenditure_type
    ,c_rec.expenditure_organization_id
    ,c_rec.expenditure_item_date
    /* End 5763527 */
    );

    IF ( v_errbuf IS NOT NULL) THEN

      -- Called unit has returned error.
      v_error_mesg := 'Error from called unit jai_ap_match_tax_pkg.process_batch_record, ';
      RAISE  error_from_called_unit;

    END IF; -- error return from distribution matching


   EXCEPTION

    WHEN OTHERS THEN

     IF v_error_mesg IS NULL  THEN
       -- the exception condition is not because of returned error from jai_ap_match_tax_pkg.process_batch_record.
       v_errbuf  := SQLERRM;
         v_error_mesg := 'Error in loop(not jai_ap_match_tax_pkg.process_batch_record), ';
     END IF;

     ROLLBACK;

      -- update the record for error
      UPDATE JAI_AP_MATCH_ERS_T
      SET    error_flag = 'Y',
             processing_time = SYSDATE,
             error_message = v_errbuf
      WHERE  ROWID = v_rowid;

      COMMIT;

      -- get the invoice number for writing onto the log file.
      SELECT invoice_num
    INTO   v_invoice_number
    FROM   ap_invoices_all
    WHERE  invoice_id = c_rec.invoice_id;


      Fnd_File.put_line(Fnd_File.LOG, v_error_mesg || ' FOR invoice number(id)/line id : ' ||  v_invoice_number
                                      || '(' || c_rec.invoice_id || ')/' || c_rec.invoice_line_number );
      Fnd_File.put_line(Fnd_File.LOG, 'Error message - ' || v_errbuf);

      v_prev_invoice_id :=  c_rec.invoice_id;
      v_error_invoice := 'Y';

   END;

   <<continue_with_next>>

   NULL;

  END LOOP; -- CURSOR FOR

  -- do the processing for the last invoice that was picked up and processed by the cursor if it has not hit any error yet.

  IF ( v_prev_invoice_id IS NOT NULL AND v_error_invoice <> 'Y') THEN

    DELETE  JAI_AP_MATCH_ERS_T
    WHERE   invoice_id = v_prev_invoice_id;

    COMMIT;
    -- get the invoice number for writing onto the log file.
    SELECT invoice_num
    INTO   v_invoice_number
    FROM   ap_invoices_all
    WHERE  invoice_id = v_prev_invoice_id;

    Fnd_File.put_line(Fnd_File.LOG, ' Processed invoice number(id) : ' || v_invoice_number || '(' || v_prev_invoice_id || ')' );

  END IF;


  Fnd_File.put_line(Fnd_File.LOG, 'SUCCESSFUL END PROCEDURE - jai_ap_match_tax_pkg.process_batch');

EXCEPTION

  WHEN OTHERS THEN

    p_errbuf := SQLERRM;
    p_retcode := 2;

    -- rollback for all the lines of the invoice which have already been processed.
    ROLLBACK;

    -- update the record for error
    UPDATE JAI_AP_MATCH_ERS_T
    SET    error_flag = 'Y',
           processing_time = SYSDATE,
           error_message = p_errbuf
    WHERE  ROWID = v_rowid;

    COMMIT;

    Fnd_File.put_line(Fnd_File.LOG, 'Error END PROCEDURE - jai_ap_match_tax_pkg.process_batch');
    Fnd_File.put_line(Fnd_File.LOG, 'Error message - ' || p_errbuf);
    RETURN;

END process_batch;

PROCEDURE process_online
(
errbuf                        OUT  NOCOPY       VARCHAR2,
retcode                       OUT  NOCOPY       VARCHAR2,
inv_id                                IN        NUMBER,
pn_invoice_line_number                IN        NUMBER, -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
po_dist_id                            IN        NUMBER,
qty_inv                               IN        NUMBER,
p_shipment_header_id                  IN        NUMBER,
p_packing_slip_num                    IN        VARCHAR2,
p_receipt_code                                  VARCHAR2,
p_rematch                                       VARCHAR2,
rcv_tran_id                           IN        NUMBER,
v_dist_amount                         IN        NUMBER,
--p_project_id                                    NUMBER, Obsoleted  Bug# 4445989
--p_task_id                                       NUMBER, Obsoleted  Bug# 4445989
--p_expenditure_type                              VARCHAR2, Obsoleted , Bug# 4445989
--p_expenditure_organization_id                   NUMBER, Obsoleted , Bug# 4445989
--p_expenditure_item_date                         DATE, Obsoleted , Bug# 4445989
v_org_id                              IN        NUMBER
 /* 5763527, Introduced for Project implementation */
 , p_project_id                                    NUMBER
 , p_task_id                                       NUMBER
 , p_expenditure_type                              VARCHAR2
 , p_expenditure_organization_id                   NUMBER
 , p_expenditure_item_date                         DATE
  /* End 5763527 */
)
IS
CURSOR get_ven_info(v_invoice_id NUMBER) IS
    SELECT vendor_id, vendor_site_id, org_id, cancelled_date, invoice_num, set_of_books_id,  -- added for bug#3354932
           legal_entity_id /* rallamse bug#4448789 */
    FROM   ap_invoices_all
    WHERE  invoice_id = v_invoice_id;

  CURSOR c_functional_currency(p_sob NUMBER) IS -- cursor added for bug#3354932
    SELECT currency_code
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = p_sob;

  CURSOR checking_for_packing_slip(ven_id NUMBER, ven_site_id NUMBER, v_org_id NUMBER) IS
    SELECT pay_on_code, pay_on_receipt_summary_code
    FROM   po_vendor_sites_all
    WHERE  vendor_id = ven_id
    AND    vendor_site_id = ven_site_id
    AND    NVL(org_id, -1) = NVL(v_org_id, -1);

  /*below cursor added for bug 6595773*/
  cursor c_get_ship_to_org_loc (cpn_line_location_id po_line_locations_all.line_location_id%type)
  is
  select ship_to_organization_id
     ,ship_to_location_id
  from  po_line_locations_all plla
  where plla.line_location_id = cpn_line_location_id;


   -- Cursor modified to use pn_invoice_line_number instead of distribution_line_number, bug#4445989
   CURSOR cur_items(inv_id IN NUMBER, line_no IN NUMBER, cpn_min_dist_line_no number) IS
     SELECT pod.po_header_id,
      pod.po_line_id,
      pod.line_location_id,
      pod.set_of_books_id,
      pod.org_id,
      poh.rate,
      poh.rate_type,
      pod.rate_date,
      poh.currency_code,
      api.last_update_login,
      apd.dist_code_combination_id,
      api.creation_date,
      api.created_by,
      api.last_update_date,
      api.last_updated_by,
      api.invoice_date
    FROM  ap_invoices_all api,
      ap_invoice_distributions_all apd,
      po_distributions_all pod,
      po_headers_all poh
     WHERE  apd.invoice_id               = api.invoice_id
     AND    pod.po_header_id             = poh.po_header_id
     AND    apd.po_distribution_id       = pod.po_distribution_id
     AND    apd.invoice_line_number      = line_no
     AND    api.invoice_id               = inv_id
     AND    apd.distribution_line_number = cpn_min_dist_line_no;
     -- Added by Brathod to get minimum invoice line number from invoice distributions, Bug#4445989
     CURSOR cur_get_min_dist_linenum
           ( cpn_invoice_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_ID%TYPE
            ,cpn_invoice_line_number AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_LINE_NUMBER%TYPE
           )
     IS
     SELECT min(distribution_line_number)
     FROM   ap_invoice_distributions_all apid
     WHERE  apid.invoice_id = cpn_invoice_id
     AND    apid.invoice_line_number = cpn_invoice_line_number;


   CURSOR from_po_distributions(po_dist_id NUMBER) IS
    SELECT line_location_id, po_line_id
    FROM   po_distributions_all
    WHERE  po_distribution_id = po_dist_id;

    ln_min_dist_line_num  NUMBER ;
    -- End of Bug # 4445989


    /*bug 9346307*/
    CURSOR c_po_details IS
    SELECT po_line_id, po_line_location_id
    FROM ap_invoice_lines_all
    WHERE invoice_id = inv_id
    AND line_number = pn_invoice_line_number;

    CURSOR c_ap_dist(cp_invoice_id NUMBER, cp_line_num NUMBER) IS
    SELECT a.accounting_date,
           a.accrual_posted_flag,
           a.assets_addition_flag,
           a.assets_tracking_flag,
           a.cash_posted_flag,
           a.dist_code_combination_id,
           a.last_updated_by,
           a.last_update_date,
           a.line_type_lookup_code,
           a.period_name,
           a.set_of_books_id,
           a.amount,
           a.base_amount,
           a.batch_id,
           a.created_by,
           a.creation_date,
           a.description,
           a.accts_pay_code_combination_id,
           a.exchange_rate_variance,
           a.last_update_login,
           a.match_status_flag,
           a.posted_flag,
           a.rate_var_code_combination_id,
           a.reversal_flag,
           a.vat_code,
           a.exchange_date,
           a.exchange_rate,
           a.exchange_rate_type,
           a.price_adjustment_flag,
           a.program_application_id,
           a.program_id,
           a.program_update_date,
           a.global_attribute1,
           a.global_attribute2,
           a.global_attribute3,
           a.po_distribution_id,--rchandan for bug#4333488
           a.project_id,
           a.task_id,
           a.expenditure_type,
           a.expenditure_item_date,
           a.expenditure_organization_id,
           a.quantity_invoiced,
           Nvl(a.quantity_invoiced,1)/Nvl(b.quantity_invoiced,1) qty_apportion_factor,
           a.unit_price,
           price_var_code_combination_id,
           invoice_distribution_id,
           matched_uom_lookup_code,
           invoice_price_variance,
           a.distribution_line_number,
           a.org_id -- Test for Bug 4863208
           /* 5763527 */
           ,project_accounting_context
           ,pa_addition_flag
           /* End 5763527 */
     FROM   ap_invoice_distributions_all a,
            ap_invoice_lines_all b
     WHERE  a.invoice_id = cp_invoice_id
     AND    a.invoice_line_number = cp_line_num
     AND    b.invoice_id = cp_invoice_id
     AND    b.line_number = cp_line_num
     AND    a.invoice_id = b.invoice_id
     AND    a.invoice_line_number = b.line_number
     ORDER BY a.distribution_line_number;

     r_ap_dist c_ap_dist%ROWTYPE;
     v_tax_amt_dist NUMBER;


    ln_po_line_id ap_invoice_lines_all.po_line_id%TYPE;
    ln_po_line_location_id ap_invoice_lines_all.po_line_location_id%TYPE;
    ln_po_dist_id ap_invoice_lines_all.po_distribution_id%TYPE;
    /*end bug 9346307*/

  /* Added by LGOPALSa. Bug 4210102.
   * Added CVD and Customs Education Cess
   * */
  /* commented out by eric for inclusive tax
  CURSOR from_line_location_taxes(p_line_location_id NUMBER, vend_id NUMBER) IS
    SELECT tax_id, tax_amount, currency, tax_target_amount, nvl(modvat_flag,'Y') modvat_flag,
    tax_type, tax_line_no -- added by kunkumar for bug 5593895
    FROM   JAI_PO_TAXES
    -- WHERE line_focus_id = focus_id
    WHERE line_location_id = p_line_location_id   -- 3096578
    AND    NVL(upper(tax_type), 'A') NOT IN
                              ('TDS',
             'CVD',
             jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
             'CUSTOMS',
                    jai_constants.tax_type_cvd_edu_cess,
              jai_constants.tax_type_customs_edu_cess,
              jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_customs_edu_cess --Added higher education cess by csahoo for bug#5989740
              )
    AND    NVL(vendor_id, -1) = vend_id --Modified by kunkumar for bug 5593895
    order by  tax_line_no; -- added bug#3038566
    -- AND    tax_amount  <> 0 ; -- commented by aparajita on 10/03/2003 for bug # 2841363
  */

  CURSOR from_line_location_taxes
  ( p_line_location_id NUMBER
  , vend_id NUMBER
  , p_source VARCHAR2 -- Added by Jason Liu for bug#6918386
  )
  IS
    SELECT
      jpt.tax_id
    , jpt.tax_amount
    , jpt.currency
    , jpt.tax_target_amount
    , nvl(jpt.modvat_flag,'Y') modvat_flag
    , jpt.tax_type
    , jpt.tax_line_no -- added by kunkumar for bug 5593895
    , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
    FROM
      JAI_PO_TAXES jpt
    , JAI_CMN_TAXES_ALL  jcta              --Added by Eric for Inclusive Tax
    -- WHERE line_focus_id = focus_id
    WHERE line_location_id = p_line_location_id   -- 3096578
      AND NVL(UPPER(jpt.tax_type), 'A')
          NOT IN( 'TDS'
                , 'CVD'
                , jai_constants.tax_type_add_cvd      -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                , 'CUSTOMS'
                , jai_constants.tax_type_cvd_edu_cess
                , jai_constants.tax_type_customs_edu_cess
                , jai_constants.tax_type_sh_cvd_edu_cess
                , jai_constants.tax_type_sh_customs_edu_cess --Added higher education cess by csahoo for bug#5989740
                )
      AND jcta.tax_id   = jpt.tax_id
      AND NVL(jpt.vendor_id, -1) = vend_id --Modified by kunkumar for bug 5593895
      AND p_source <> 'PPA'
    -- Added by Jason Liu for bug#6918386
    ---------------------------------------------------------------------
    UNION

    SELECT
      jrl.tax_id
    , (jrl.modified_tax_amount - jrl.original_tax_amount) tax_amount
    , jrl.currency_code currency
    , (jrl.modified_tax_amount - jrl.original_tax_amount) tax_target_amount
    , jrl.recoverable_flag modvat_flag
    , jrl.tax_type tax_type
    , jrl.tax_line_no tax_line_no
    , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag
    FROM
      jai_retro_tax_changes  jrl
    , jai_retro_line_changes jrlc
    , jai_cmn_taxes_all      jcta
    WHERE jrlc.line_location_id = p_line_location_id
      AND jrlc.line_change_id = jrl.line_change_id
      AND jrlc.doc_version_number = (SELECT max(doc_version_number)
                                     FROM jai_retro_line_changes
                                     WHERE doc_type IN ('STANDARD PO', 'RELEASE')
                                       AND doc_line_id = jrlc.doc_line_id
                                     )
      AND jrlc.doc_type IN ('STANDARD PO', 'RELEASE')
      AND jrl.tax_id = jcta.tax_id
      AND NVL(jrlc.vendor_id, -1) = vend_id
      AND p_source = 'PPA'
      AND NVL(upper(jrl.tax_type),'TDS') NOT IN ( jai_constants.tax_type_tds
                                                , jai_constants.tax_type_cvd
                                                , jai_constants.tax_type_add_cvd
                                                , jai_constants.tax_type_customs
                                                , jai_constants.tax_type_sh_customs_edu_cess
                                                , jai_constants.tax_type_customs_edu_cess
                                                , jai_constants.tax_type_sh_cvd_edu_cess
                                                , jai_constants.tax_type_cvd_edu_cess
                                                )
      AND NVL(jrl.third_party_flag, 'N') = 'N' -- Added by Jason Liu for bug#6936416
      ---------------------------------------------------------------------
    ORDER BY  tax_line_no; -- added bug#3038566
    -- AND    tax_amount  <> 0 ; -- commented by aparajita on 10/03/2003 for bug # 284136

    CURSOR c_tax(t_id NUMBER) IS
     SELECT tax_name,
        tax_account_id,
        mod_cr_percentage, -- bug 3051828
        adhoc_flag,  -- added by aparajita on 23/01/2003 for bug # 2694011
        nvl(tax_rate,-1) tax_rate,  --Modified by kunkumar for bug 5593895
        tax_type,
    NVL(rounding_factor,0) rounding_factor /* added by vumaasha for bug 6761425 */
     FROM   JAI_CMN_TAXES_ALL
     WHERE  tax_id = t_id;

    CURSOR c_inv(inv_id NUMBER) IS
      SELECT batch_id,source
      FROM   ap_invoices_all
      WHERE  invoice_id = inv_id;

    CURSOR for_org_id(inv_id NUMBER) IS
     SELECT org_id, vendor_id, NVL(exchange_rate, 1) exchange_rate, invoice_currency_code
     FROM   ap_invoices_all
     WHERE  invoice_id = inv_id;

  CURSOR for_acct_id(orgn_id NUMBER) IS
     SELECT accts_pay_code_combination_id
     FROM   ap_system_parameters_all
     WHERE  NVL(org_id, -1) = NVL(orgn_id, -1);--uncommented and modified by kunkumar for bug 5593895
     --commented the above by Sanjikum For Bug#4474501, as this cursor is not being used anywhere

    CURSOR for_dist_insertion(cpn_invoice_id NUMBER, cpn_inv_line_num NUMBER,cpn_min_dist_line_num NUMBER) IS  /* Picks up dtls from std apps inserted line */
    SELECT a.accounting_date,a.accrual_posted_flag,
                a.assets_addition_flag,a.assets_tracking_flag,
    a.cash_posted_flag, a.dist_code_combination_id,
    a.last_updated_by,a.last_update_date,
    a.line_type_lookup_code,  a.period_name,
    a.set_of_books_id,a.amount,a.base_amount,
    a.batch_id,a.created_by,a.creation_date,
    a.description,a.accts_pay_code_combination_id,
    a.exchange_rate_variance,a.last_update_login,
    a.match_status_flag,a.posted_flag, a.rate_var_code_combination_id,
    a.reversal_flag,a.vat_code,a.exchange_date,a.exchange_rate,
    a.exchange_rate_type,a.price_adjustment_flag,
    a.program_application_id,a.program_id,
    a.program_update_date,a.global_attribute1,
    a.global_attribute2,
    a.global_attribute3, a.po_distribution_id,--rchandan for bug#4333488
                a.project_id,a.task_id,a.expenditure_type,a.expenditure_item_date,
    a.expenditure_organization_id,     quantity_invoiced,
    a.unit_price, price_var_code_combination_id,
    invoice_distribution_id, matched_uom_lookup_code, invoice_price_variance,
    org_id -- Test for Bug 4863208
     /* 5763527 */
     ,project_accounting_context
     ,pa_addition_flag
   /* End 5763527 */
     FROM   ap_invoice_distributions_all a
     WHERE  invoice_id               = cpn_invoice_id
     AND    invoice_line_number      = cpn_inv_line_num
     AND    distribution_line_number = cpn_min_dist_line_num;

   /* Added by LGOPALSa. Bug 4210102.
    * Added CVD and Customs Education Cess
    * */

  --deleted by eric for inclusive tax on 20-dec-2007,begin
  ---------------------------------------------------------------------------
  /*
  CURSOR tax_lines1_cur(tran_id NUMBER,ven_id NUMBER)
  IS
    SELECT jrl.tax_amount tax_amount, jrl.tax_id, jrl.currency,jrl.tax_type tax_type, jrl.modvat_flag,
    jrl.tax_line_no tax_line_no --modified by kunkumar for bug 5593895
    FROM JAI_RCV_LINE_TAXES jrl,rcv_shipment_lines rsl,rcv_transactions rt
    WHERE jrl.shipment_line_id = rsl.shipment_line_id
    AND rt.shipment_line_id = rsl.shipment_line_id
    AND rt.transaction_id = tran_id
    AND jrl.vendor_id = ven_id
    AND NVL(upper(jrl.tax_type),'TDS') NOT IN (
                                                 'TDS',
             'CVD',
             jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
             'CUSTOMS',
                        JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,jai_constants.tax_type_customs_edu_cess, -- added by ssawant for bug 5989740
            JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess --added by ssawant for bug 5989740
                 )
    order by  tax_line_no -- added bug#3038566
    ;
   */
   ---------------------------------------------------------------------------
   --deleted  by eric for inclusive tax on 20-dec-2007,end


   CURSOR tax_lines1_cur(tran_id NUMBER,ven_id NUMBER)
   IS
   SELECT
     jrl.tax_amount tax_amount
   , jrl.tax_id
   , jrl.currency
   , jrl.tax_type tax_type
   , jrl.modvat_flag
   , jrl.tax_line_no tax_line_no --modified by kunkumar for bug 5593895
   , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
  FROM
    JAI_RCV_LINE_TAXES jrl
  , RCV_SHIPMENT_LINES RSL
  , RCV_TRANSACTIONS RT
  , jai_cmn_taxes_all  jcta
  WHERE jrl.shipment_line_id = rsl.shipment_line_id
    AND rt.shipment_line_id  = rsl.shipment_line_id
    AND rt.transaction_id    = tran_id
    AND jrl.vendor_id        = ven_id
    AND jcta.tax_id          = jrl.tax_id  --Added by Eric for Inclusive Tax
    AND NVL(upper(jrl.tax_type),'TDS')
        NOT IN ( 'TDS'
               , 'CVD'
               , jai_constants.tax_type_add_cvd      -- Date 31/10/2006 Bug 5228046 added by SACSETHI
               , 'CUSTOMS'
               , JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS
               , jai_constants.tax_type_customs_edu_cess /* added by ssawant for bug 5989740 */
               , JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS
               , jai_constants.tax_type_cvd_edu_cess /* added by ssawant for bug 5989740 */
               )
    order by  tax_line_no; -- added


  ----------------------------------------------- Receipt Matching Cursors ----------------------------
  /* Added by LGOPALSa. Bug 4210102.
   * Added CVD and Customs Education Cess
   * */

  -- Modified by Jason Liu for retroactive price on 2008/01/09
  -- Added the parameter p_source, added the UNION(p_source = 'PPA')
  CURSOR r_tax_lines_cur(tran_id NUMBER,ven_id NUMBER,p_source IN VARCHAR2) IS
    SELECT
      jrl.tax_amount tax_amount
    , jrl.tax_id
    , jrl.currency
    , jrl.tax_type tax_type
    , jrl.modvat_flag
    , jrl.tax_line_no tax_line_no --Added by kunkumar for bug 5593895
    , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
    FROM
      jai_rcv_line_taxes jrl
    , rcv_shipment_lines rsl
    , rcv_transactions rt
    , jai_cmn_taxes_all jcta          --Added by Eric for Inclusive Tax
    WHERE jrl.shipment_line_id = rsl.shipment_line_id
      AND rt.shipment_line_id = rsl.shipment_line_id
      AND rt.transaction_id = tran_id
      AND jrl.vendor_id = ven_id
      AND jcta.tax_id   = jrl.tax_id  --Added by Eric for Inclusive Tax
      AND NVL(upper(jrl.tax_type),'TDS') NOT IN
                                             ('TDS',
                'CVD',
                       jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                'CUSTOMS',
                                              JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,jai_constants.tax_type_customs_edu_cess, /* added by ssawant for bug 5989740 */
                JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,jai_constants.tax_type_cvd_edu_cess /* added by ssawant for bug 5989740 */
       )
      AND p_source <> 'PPA'

    UNION

    SELECT
      (jrl.modified_tax_amount - jrl.original_tax_amount) tax_amount
    , jrl.tax_id
    , jrl.currency_code currency
    , jrl.tax_type tax_type
    , jrl.recoverable_flag modvat_flag
    , jrl.tax_line_no tax_line_no
    , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag
    FROM
      jai_retro_tax_changes  jrl
    , rcv_shipment_lines     rsl
    , rcv_transactions       rt
    , jai_retro_line_changes jrlc
    , jai_cmn_taxes_all      jcta
    WHERE jrlc.doc_line_id = rsl.shipment_line_id
      AND jrlc.line_change_id = jrl.line_change_id
      AND jrlc.doc_version_number = (SELECT max(doc_version_number)
                                     FROM jai_retro_line_changes
                                     WHERE doc_type = 'RECEIPT'
                                       AND doc_line_id = jrlc.doc_line_id
                                     )
      AND jrlc.doc_type = 'RECEIPT'
      AND jrl.tax_id = jcta.tax_id
      AND rt.shipment_line_id = rsl.shipment_line_id
      AND rt.transaction_id = tran_id
      AND jrlc.vendor_id = ven_id
      AND p_source = 'PPA'
      AND NVL(upper(jrl.tax_type),'TDS') NOT IN ( jai_constants.tax_type_tds
                                                , jai_constants.tax_type_cvd
                                                , jai_constants.tax_type_add_cvd
                                                , jai_constants.tax_type_customs
                                                , jai_constants.tax_type_sh_customs_edu_cess
                                                , jai_constants.tax_type_customs_edu_cess
                                                , jai_constants.tax_type_sh_cvd_edu_cess
                                                , jai_constants.tax_type_cvd_edu_cess
                                                )
      AND NVL(jrl.third_party_flag, 'N') = 'N' -- Added by Jason Liu for bug#6936416
    -- GROUP BY jrl.tax_id,jrl.currency,jrl.tax_type, jrl.modvat_flag; commented by bug#3038566
    order by tax_line_no; -- added bug#3038566


    -- Start add for bug#3632810
  CURSOR c_get_invoice_distribution  is -- bug#3332988
  select ap_invoice_distributions_s.nextval
  from   dual;

 -- start addition by ssumaith -bug# 3127834

 cursor c_fnd_curr_precision(cp_currency_code fnd_currencies.currency_code%type) is
 select precision
 from   fnd_currencies
 where  currency_code = cp_currency_code;

  -- ends here additions by ssumaith -bug# 3127834
--Added by kunkumar for porting 4454499
  Cursor c_tax_curr_prec(cp_tax_id jai_cmn_taxes_all.tax_id%type) is
 select NVL(rounding_factor,-1)
 from jai_cmn_taxes_all
 where tax_id = cp_tax_id  ;

  /*Bug 8866084 - Added cursor to fetch Source of Invoice*/
  cursor c_get_ap_invoice_src (p_inv_id NUMBER)
  is
  select source
  from ap_invoices_all
  where invoice_id = p_inv_id;

  ln_source                           VARCHAR2(50);

  ln_precision                        fnd_currencies.precision%type; -- added by sssumaith - bug# 3127834
  v_po_unit_meas_lookup_code          po_lines_all.unit_meas_lookup_code%type;
  r_tax_lines_rec                     r_tax_lines_cur%ROWTYPE;
  /* r_cur_items_rec                  r_cur_items%ROWTYPE; Bug#4095234*/
  vPoUomCode                          mtl_units_of_measure.unit_of_measure%TYPE;
  vReceiptUomCode                     mtl_units_of_measure.unit_of_measure%TYPE;
  vReceiptToPoUomConv                 NUMBER;
  v_attribute12                       VARCHAR2(150);
  v_ATTRIBUTE2                        VARCHAR2(150);
  v_sup_po_header_id                  NUMBER;
  v_sup_po_line_id                    NUMBER;
  v_sup_line_location_id              NUMBER;
  v_sup_set_of_books_id               NUMBER;
  v_sup_org_id                        NUMBER;
  v_sup_conversion_rate               NUMBER;
  v_sup_tax_date                      DATE;
  v_sup_currency                      VARCHAR2(10);
  v_sup_invoice_date                  DATE;
  v_invoice_num                       VARCHAR2(50);
  v_sup_inv_type                      VARCHAR2(25);
  get_ven_info_rec                    get_ven_info%ROWTYPE;
  chk_for_pcking_slip_rec             checking_for_packing_slip%ROWTYPE;
  v_invoice_num_for_log               VARCHAR2(50);
  v_tax_variance_inv_cur              number; -- bug # 2775043
  v_tax_variance_fun_cur              number; -- bug # 2775043
  v_price_var_accnt                   ap_invoice_distributions_all.price_var_code_combination_id%type;
  v_distribution_no                   ap_invoice_distributions_all.distribution_line_number%type;
  v_assets_tracking_flag              ap_invoice_distributions_all.assets_tracking_flag%type;
  v_dist_code_combination_id          ap_invoice_distributions_all.dist_code_combination_id%type;--bug#367196
  v_update_payment_schedule           boolean; -- bug#3218978
  v_invoice_distribution_id           ap_invoice_distributions_all.invoice_distribution_id%type; -- bug#3332988
  v_functional_currency               gl_sets_of_books.currency_code%type; -- bug#3354932
  v_batch_id                          NUMBER;
  c_tax_rec                           c_tax%ROWTYPE;
  v_source                            VARCHAR2(25);
  apccid                              ap_invoices_all.ACCTS_PAY_CODE_COMBINATION_ID%TYPE;
  shpmnt_ln_id                        rcv_shipment_lines.shipment_line_id%TYPE;
  cur_items_rec                       cur_items%ROWTYPE;
  caid                                gl_sets_of_books.chart_of_accounts_id%TYPE;
  from_po_distributions_rec           from_po_distributions%ROWTYPE;
  for_dist_insertion_rec              for_dist_insertion%ROWTYPE;
  cum_tax_amt                         NUMBER := -1;--modified by kunkumar for 5593895
  v_tax_amount                        NUMBER;
  result                              BOOLEAN;
  req_id                              NUMBER;
  for_org_id_rec                      for_org_id%ROWTYPE;
  -- for_acct_id_rec                     for_acct_id%ROWTYPE;
  --commented the above by Sanjikum For Bug#4474501, as this variable is not being used anywhere
  v_cor_factor                        NUMBER;
  v_tax_type                          VARCHAR2(50);
  v_apportn_factor_for_item_line      NUMBER; -- Bug#3752887

/*following variables added for bug 6595773*/
  ln_vat_regime_id                    jai_rgm_definitions.regime_id%type;
  ln_ship_to_organization_id          po_line_locations_all.ship_to_organization_id%type;
  ln_ship_to_location_id              po_line_locations_all.ship_to_location_id%type;


   /* 5763527 , Project costing Fwd porting*/
  ln_project_id                       ap_invoice_distributions_all.project_id%TYPE;
  ln_task_id                          ap_invoice_distributions_all.task_id%TYPE;
  lv_exp_type                         ap_invoice_distributions_all.expenditure_type%TYPE;
  ld_exp_item_date                    ap_invoice_distributions_all.expenditure_item_date%TYPE;
  ln_exp_organization_id              ap_invoice_distributions_all.expenditure_organization_id%TYPE;
  lv_project_accounting_context       ap_invoice_distributions_all.project_accounting_context%TYPE;
  lv_pa_addition_flag                 ap_invoice_distributions_all.pa_addition_flag%TYPE;

  ln_lines_to_insert                  number;
  ln_nrec_tax_amt                     number;
  ln_rec_tax_amt                      number;
  lv_modvat_flag                      jai_ap_match_inv_taxes.recoverable_flag%type;

  lv_excise_costing_flag              varchar2 (1);

  lv_tax_type                         varchar2(5); --added by eric for inclusive tax
  lv_tax_line_amount                  NUMBER := 0; --added by eric for inclusive tax
  lv_ap_line_to_inst_flag             VARCHAR2(1); --added by eric for inclusive tax
  lv_tax_line_to_inst_flag            VARCHAR2(1); --added by eric for inclusive tax

  cursor c_get_excise_costing_flag (cp_rcv_transaction_id   rcv_transactions.transaction_id%type,
                                     cp_organization_id      JAI_RCV_TRANSACTIONS.organization_id%type,  --Added by Bgowrava for Bug#7503308
                                    cp_shipment_header_id    JAI_RCV_TRANSACTIONS.shipment_header_id%type,  --Added by Bgowrava for Bug#7503308
                  cp_txn_type             JAI_RCV_TRANSACTIONS.transaction_type%type,  --Added by Bgowrava for Bug#7503308
                                    cp_attribute1           VARCHAR2)  --Added by Bgowrava for Bug#7503308
  is
    select cenvat_costed_flag excise_costing_flag
    from   jai_rcv_transactions jrcvt
    where  jrcvt.parent_transaction_id = cp_rcv_transaction_id
  and    jrcvt.organization_id  = cp_organization_id --Added by Bgowrava for Bug#7503308
    and jrcvt.shipment_header_id = cp_shipment_header_id --Added by Bgowrava for Bug#7503308
    and    jrcvt.transaction_type = cp_txn_type  ;--'DELIVER' --Modified by Bgowrava for Bug#7503308
    --and    jrcvt.attribute1= cp_attribute1 ; --'CENVAT_COSTED_FLAG';  ----Modified by Bgowrava for Bug#7503308 --Commented by Bo Li for Bug9305067

  /* End 5763527 */


  -- Bug 5401111. Added by Lakshmi Gopalsami
  lv_account_type gl_code_combinations.account_type%TYPE;

  /* Service Tax */
  cursor c_rcv_transactions(p_transaction_id  number) is
     select po_line_id, organization_id
     from   rcv_transactions
     where  transaction_id = p_transaction_id;


   cursor c_po_lines_all(p_po_line_id number) is
     select item_id
     from   po_lines_all
     where  po_line_id = p_po_line_id;

   /* Bug 5358788. Added by Lakshmi Gopalsami
    * Added parameter cp_regime_code instead of
    * hardcoding the value for service. This is required
    * for re-using the same cursor to avoid performance issue
    * in using jai_regime_tax_types_v.
    */
   cursor c_jai_regimes(cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE)
   IS
     select regime_id
     from   JAI_RGM_DEFINITIONS
     where  regime_code = cp_regime_code ; /* SERVICE or VAT */

   cursor c_regime_tax_type(cp_regime_id  number, cp_tax_type varchar2) is
    select attribute_code tax_type
    from   JAI_RGM_REGISTRATIONS
    where  regime_id = cp_regime_id
    and    registration_type = jai_constants.regn_type_tax_types  /* TAX_TYPES */
    and    attribute_code = cp_tax_type;


   r_rcv_transactions               c_rcv_transactions%rowtype;
   r_po_lines_all                   c_po_lines_all%rowtype;
   r_jai_regimes                    c_jai_regimes%rowtype;
   r_service_regime_tax_type        c_regime_tax_type%rowtype;
   lv_is_item_an_expense            varchar2(20); /* Service */
   lv_accounting_method_option      varchar2(20); /* Service */
   lv_accrue_on_receipt_flag        po_distributions_all.accrue_on_receipt_flag%type;
  /* Service Tax */
   ln_base_amount number ;  -- kunkumar for bug  5593895
  /* Bug 5358788. Added by Lakshmi Gopalsami
   * Defined variable for fetching VAT regime/
   */

  r_VAT_regime_tax_type        c_regime_tax_type%rowtype;
  r_vat_regimes                 c_jai_regimes%rowtype;

  /* Added by Brathod, Bug# 4445989 */
  --> Cursor to fetch the maximum line_number for current invoice, Bug# 4445989
  CURSOR cur_get_max_line_number
  IS
  SELECT max (line_number)
  FROM   ap_invoice_lines_all
  WHERE  invoice_id = inv_id;

  --> Cursor to fetch maximum line from ap_invoice_lines_all for current invoice, Bug# 4445989
  CURSOR cur_get_max_ap_inv_line (cpn_max_line_num AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE)
  IS
  SELECT   accounting_date
          ,period_name
          ,deferred_acctg_flag
          ,def_acctg_start_date
          ,def_acctg_end_date
          ,def_acctg_number_of_periods
          ,def_acctg_period_type
          ,set_of_books_id
    ,wfapproval_status -- Bug 4863208
  FROM    ap_invoice_lines_all
  WHERE   invoice_id = inv_id
  AND     line_number = cpn_max_line_num;

  -- Added by Jason Liu for retroactive price on 2008/01/09
  -----------------------------------------------------------
  CURSOR get_source_csr IS
  SELECT aia.source
  FROM ap_invoices_all aia
  WHERE aia.invoice_id = inv_id;
  lv_source  ap_invoices_all.source%TYPE;
  -----------------------------------------------------------
  rec_max_ap_lines_all    CUR_GET_MAX_AP_INV_LINE%ROWTYPE;

  ln_max_lnno  NUMBER;
  ln_inv_line_num AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;
  ln_user_id  NUMBER;
  ln_login_id NUMBER;
  lv_misc     VARCHAR2 (15);
  lv_match_type VARCHAR2(15);
  /* End of Bug# 4445989 */
  -- Bug 7249100. Added by Lakshmi Gopalsami
  lv_dist_class VARCHAR2(30);


  FUNCTION update_payment_schedule (p_total_tax NUMBER) RETURN boolean IS -- bug # 3218978

    v_total_tax_in_payment  number;
    v_tax_installment       number;
    v_payment_num           ap_payment_schedules_all.payment_num%type;
    v_total_payment_amt     number;
    v_diff_tax_amount       number;

    cursor  c_total_payment_amt is
    select  sum(gross_amount)
    from    ap_payment_schedules_all
    where   invoice_id = inv_id;

  begin

  Fnd_File.put_line(Fnd_File.LOG, 'Start of function  update_payment_schedule');

    open  c_total_payment_amt;
    fetch   c_total_payment_amt into v_total_payment_amt;
    close   c_total_payment_amt;

  if nvl(v_total_payment_amt, -1) = -1 then --Modified by kunkumar for 5593895
    Fnd_File.put_line(Fnd_File.LOG, 'Cannot update payment schedule, total payment amount :'
                                    || to_char(v_total_payment_amt));
    return false;
  end if;

    v_total_tax_in_payment := -1;  --Modified by kunkumar for  5593895

    for c_installments in
    (
    select  gross_amount,
        payment_num
    from    ap_payment_schedules_all
    where   invoice_id = inv_id
    order by payment_num
    )
    loop

      v_tax_installment := -1 ;--Modified by kunkumar for  5593895
      v_payment_num  :=  c_installments.payment_num;

      v_tax_installment := p_total_tax * (c_installments.gross_amount / v_total_payment_amt);

      v_tax_installment := round(v_tax_installment, ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        = gross_amount          + v_tax_installment,
         amount_remaining      = amount_remaining      + v_tax_installment,
         inv_curr_gross_amount = inv_curr_gross_amount + v_tax_installment,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
            -- bug#3624898
      where  invoice_id = inv_id
      and    payment_num = v_payment_num;

      v_total_tax_in_payment := v_total_tax_in_payment + v_tax_installment;

    end loop;

    -- any difference in tax because of rounding has to be added to the last installment.
    if v_total_tax_in_payment <> p_total_tax then

      v_diff_tax_amount := round( p_total_tax - v_total_tax_in_payment,ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        = gross_amount          + v_diff_tax_amount,
         amount_remaining      = amount_remaining      + v_diff_tax_amount,
         inv_curr_gross_amount = inv_curr_gross_amount + v_diff_tax_amount
      where  invoice_id = inv_id
      and    payment_num = v_payment_num;
    end if;

    return true;

  exception
    when others then
      Fnd_File.put_line(Fnd_File.LOG, 'exception from function  update_payment_schedule');
      Fnd_File.put_line(Fnd_File.LOG, sqlerrm);
      return false;
  end update_payment_schedule; -- bug # 3218978

  -- Start added for bug#3332988
  procedure insert_mrc_data (p_invoice_distribution_id number) is
    -- Vijay Shankar for bug#3461030
    v_mrc_string VARCHAR2(10000);
  begin

       v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data (
      p_operation_mode    => ''INSERT'',
      p_table_name        => ''AP_INVOICE_DISTRIBUTIONS_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax line as Miscellaneous distribution line (jai_ap_match_tax_pkg.process_online procedure)''
       ); END;';

      -- Vijay Shankar for bug#3461030
      EXECUTE IMMEDIATE v_mrc_string USING p_invoice_distribution_id;

  -- Vijay Shankar for bug#3461030
  exception
    when others then
    IF SQLCODE = -6550 THEN
      -- object referred in EXECUTE IMMEDIATE is not available in the database
      null;
      FND_FILE.put_line(FND_FILE.log, '*** MRC API is not existing(insert)');
    ELSE
      FND_FILE.put_line(FND_FILE.log, 'MRC API exists and different err(insert)->'||SQLERRM);
      RAISE;
    END IF;
  end;


  procedure update_mrc_data is
    -- Vijay Shankar for bug#3461030
    v_mrc_string VARCHAR2(10000);
  begin

       v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data (
      p_operation_mode    => ''UPDATE'',
      p_table_name        => ''AP_INVOICES_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax amount added to invoice header (jai_ap_match_tax_pkg.process_online procedure)''
       ); END;';

      -- Vijay Shankar for bug#3461030
      EXECUTE IMMEDIATE v_mrc_string USING inv_id;

  -- Vijay Shankar for bug#3461030
  exception
    when others then
    IF SQLCODE = -6551 THEN --Modified by kunkumar for  5593895
      -- object referred in EXECUTE IMMEDIATE is not available in the database
      null;
      FND_FILE.put_line(FND_FILE.log, 'MRC API is not existing(update)');
    ELSE
      FND_FILE.put_line(FND_FILE.log, 'MRC API exists and different err(update)->'||SQLERRM);
      RAISE;
    END IF;
  end;
  /* End added for bug#3332988 */

  -- start bug#4103473
  FUNCTION apportion_tax_4_price_cor_inv (p_tax_amount  number, p_tax_id number) return number is

      -- get the corresponding base line amount in original invoice
    cursor c_check_orig_item_line(p_price_correct_inv_id number, p_po_distribution_id number) is
    select amount, invoice_distribution_id
    from   ap_invoice_distributions_all
  WHERE  invoice_id = p_price_correct_inv_id
  and    po_distribution_id = p_po_distribution_id
  AND    line_type_lookup_code = 'ITEM';


  --  get the corresponding tax lin amount in the original invoice
  cursor c_get_orig_tax_line
  (p_orig_invoice_id number, p_orig_invoice_dist_id number, p_tax_id number) is
  -- 5763527 , Added SUM as there can be two tax lines against the same tax_id because of partialy recoverable taxes
  select  sum(tax_amount) tax_amount-- project costing fwd porting
  from    JAI_AP_MATCH_INV_TAXES
  where   p_orig_invoice_id = p_orig_invoice_id
  and   parent_invoice_distribution_id = p_orig_invoice_dist_id
  and   tax_id = p_tax_id;

  c_check_orig_item_line_rec  c_check_orig_item_line%rowtype;
  c_get_orig_tax_line_rec   c_get_orig_tax_line%rowtype;
  v_amount          number;
  cur_price_correct_inv_id  NUMBER(15);
  cur_po_distribution_id    NUMBER(15);
  cur_amount                NUMBER;
  cur_quantity_invoiced     NUMBER;
  v_count NUMBER;
  begin

     Fnd_File.put_line(Fnd_File.LOG, 'Start of function apportion_tax_4_price_cor_inv');

    begin
      execute immediate 'select /* price_correct_inv_id */, po_distribution_id, amount, quantity_invoiced
                         from   ap_invoice_lines_all
                         where  invoice_id = :inv_id
                         and    line_number = :inv_line_num'
                         into cur_price_correct_inv_id, cur_po_distribution_id, cur_amount, cur_quantity_invoiced
                         USING inv_id, pn_invoice_line_number;  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989


     exception
      when others  then
        return p_tax_amount;
    end;

  -- control comes here when it is a case of price correction
   open c_check_orig_item_line
   (cur_price_correct_inv_id, cur_po_distribution_id);
   fetch c_check_orig_item_line into c_check_orig_item_line_rec;
   close c_check_orig_item_line;

   open c_get_orig_tax_line
   (
   cur_price_correct_inv_id,
   c_check_orig_item_line_rec.invoice_distribution_id,
   p_tax_id
   );
   fetch c_get_orig_tax_line into c_get_orig_tax_line_rec;
   close c_get_orig_tax_line;

     if c_check_orig_item_line_rec.amount = -1 then --Modified by kunkumar for  5593895
     Fnd_File.put_line(Fnd_File.LOG, 'Original item line has -1 amount, cannot apportion tax');--Modified by kunkumar for  5593895
       return p_tax_amount;
     end if;

   v_amount := ( c_get_orig_tax_line_rec.tax_amount / c_check_orig_item_line_rec.amount)
         * cur_amount;

   Fnd_File.put_line(Fnd_File.LOG, ' original amount / tax :' || c_check_orig_item_line_rec.amount
                   || '/' || c_get_orig_tax_line_rec.tax_amount);

   return round(v_amount, 2);


  exception
    when others then
      Fnd_File.put_line(Fnd_File.LOG, 'Exception function apportion_tax_4_price_cor_inv :' || sqlerrm);
      return p_tax_amount;
  end apportion_tax_4_price_cor_inv;


  -- End bug#4103473


BEGIN

/*------------------------------------------------------------------------------------------
 FILENAME: ja_in_jai_ap_match_tax_pkg.process_online_p.sql
 CHANGE HISTORY:
S.No      Date          Author and Details
1.       20-mar-01      Subbu and Pavan for AP to FA issue added
                        insert statemnt for temp table JAI_CMN_FA_INV_DIST_ALL

2.       29-mar-01      Subramanyam S.K added modifications for STForm
                        Tracking at AP level. Insert statments for JA_in_po_st_forms_hdr
                        and ja_in_po_st_forms_dtl after validating whether
                        the tax line is Sales Tax or CST and for these taxes
                        stform_type(JAI_CMN_TAXES_ALL) is not null.

3.       20-apr-01      Modifications done by Ajay Sharma for correct calculation
                        of taxes and invoice amount at the time of RCV_MATCHING

4.       17-aug-01      Code Added by Vijay for Multi-Org support of ST Form Tracking

5.       24-Aug-01      Modification done by Ajay Sharma to insert records in case of
                        running of pay on receipt for subsequent receipt against same PO

6.       08-Sep-01      Modifications done by Pavan to care of the split payment terms

7.       09-Mar-02      RPK: for BUG#2255404
                        Code modified to facilitate the invoice matching with more than
                        one receipt.When the invoice is matched to more than one receipts
                        getting the error 'Unique constraint(AP.AP_INVOICE_DITRIBUTIONS_U1) violated

8.       22-may-2002    Aparajita for bug # 2387481.
                        The calculation of tax amount for RCV_MATCHING case when there exists
                        some return to vendor for the receipt, was not correct.

                        Corrected it by using quantity_shipped in the r_for_shipment_line
                        cursor instead of quantity_received.
                        Quantity_shipped gives the original quantity of the receipt.

                        Added the Fnd_File.put_line(Fnd_File.LOG,'') statements to
                        generate the log also.

9.       09/10/2002     Aparajita for bug # 2483164 Version#615.1
                        Populate the po distribution id and rcv_transactions id for the tax
                        lines for backtracking tax to purchasing side.


10.       03/11/2002    Aparajita for bug # 2567799  Version#615.2
                       Added a function apportion_tax_pay_on_rect_f and using it to apportion
                       the tax amount. This is useful when there are multiple distributions for the PO.

                       Deleted the code for supplementary invoices as this is not being used.

11.       05/11/2002    Aparajita for bug # 2506453, Version#615.3

                       Changed the cursor definition get_tax_ln_no, to look into the receipt tax
                       instead of the po tax table for getting the line number.
                       This was running into error when no taxes exist at po and have been
                       added at receipt.

                       Added the cursor get_tax_ln_no_po, to fetch the tax line number from PO
                       if it is the case of PO matching.

                       Also Changed the cursor definition get_sales_tax_dtl to fetch on the
                       basis of tax id instead of name.

12.      02/12/2002    Aparajita for bug # 2689826 Version # 615.4

                       The distribution line numbers were getting  skipped every time the tax is
                       inserted for a 2nd item line onwards. This was happening because the
                       distribution line number is calulated by taking the max distribution
                       line number and also the no of tax lines which have a shipment line id
                       less than corresponding shipment line id for the same shipment header.

                       This logic is not required as the distribution line number should
                       always be the next number. commented the cursor count_tax_lines.

13.      14/01/2003     Aparajita for bug # 2694011. Version # 615.5

                       The taxes in case of PO matching were wrong when the price is changed
                       at PO matching. Added code to check the price at invoice to the price
                       at PO and apportioning the tax amount in case of a price change.
                       This is applicable to non-adhoc taxes only as they depend on the po amount.

                       Added unit price in cursor for_dist_insertion to get invoice price.
                       Added  price_override in cursor for_line_qty to get po price.
                       Added code to compare the above prices and apportion the calculated
                       tax in case of change.

                       Used the cursor for_line_qty in case of receipt matching with the
                       line location id from rcv_transactions to get the price.
                       Price of a receipt cannot be changed, so same as po price.
                       Logic of apportioning was also added in receipt matching cases.

14       31/01/2003    Aparajita for bug # 2775043. Version # 615.6
                       When price is changed at the time of po/receipt matching the tax amount is
                       apportioned appropriately. This should also hit the invoice price variance
                       account, but this is not happening as base apps expects the variance amount
                       and account code to be loaded into the following fields.

                        - price_var_code_combination_id
                        - invoice_price_variance
                        - base_invoice_price_variance (in functional currency)

15       21/02/2003     Aparajita for bug # 2805527. Version # 615.7
                       This procedure is run as a concurrent, this concurrent should be
                       incompatible to itself as more than 1 request may be entering tax lines for
                       the same invoice. For some reason if the incompatibility is not set or
                       does not work, this concurrent runs into error.

                       Added the concept of locking the distribution lines so that even if they
                       run concurrently there should not be any error.
                       The code was using two variables dno and dlno for distribution
                       number,

                       stream lines it to consider only v_distribution_no and changed the related logic.

16.      14/03/2003    Aparajita for bug # 2841363. Version # 615.8
                       Taxes having 0 amount were not considered, changed the cursor
                       from_line_location_taxes to consider such tax lines for propagation into AP.

17.      23/03/2003    Vijay Shankar for Bug# 2827356. Version # 615.9
                        When Receipt line Uom is different from PO shipment line Uom,
                        then Invoice Matching with Receipt is calculating taxes wrongly for distribution
                        item lines. This is resolved by incorporating Receipt Line to PO Shipment
                        line UOM converion rate to be multiplied with PO Shipment price (used to proportionate the receipt tax along with invoice distribution price).
                        This issue happens only during receipt matching.

18.      07/04/2003    Aparajita for bug # 2851123. Version # 615.10
                       The assets_tracking_flag in ap_invoice_distributions_all,
                       JAI_AP_MATCH_INV_TAXES and JAI_CMN_FA_INV_DIST_ALL should
                       be set as 'N' if the tax line against which the line is being generated
                       is excise type of tax and is modvatable. By default this flag gets the value
                       from the corresponding item line for which the tax is attached.

                       Introduced a variable v_assets_tracking_flag.
                       Modified the following cursors to fetch modvat_flag.
                       - from_line_location_taxes
                       - tax_lines1_cur
                       - r_tax_lines_cur

19      17/07/2003     Aparajita for bug#3038566. Version#616.1

                       Introduced a new function getSTformsTaxBaseAmount to calculate the
                       tax base amount to be populated into the table ja_in_po_st_forms_dtl.
                       Calculating the tax base amount from the tax amount and percentage was
                       giving problem because of rounding.

20     14/08/2003     kpvs for bug # 3051828, version # 616.2
                      OPM code merged into this version of the procedure.
                      Changes made to pull in the OPM code fixes done for bugs 2616100
                      and 2616107 Used 'v_opm_flag' to check for the process enabled flag of the
                      organization.

21.    17/08/2003     Aparajita for bug#3094025. Generic for bug#3054140. version # 616.3
                      There may be taxes at receipt without having any tax at PO.
                      For such cases, the st forms population has to cater.
                      Precedences are not available, so calculation of tax base is not possible.
                      Added the backward calcultion for such cases.

                      Changes in the function getSTformsTaxBaseAmount.
                      Introduced two new parameters tax amount and rate to calculate backward
                      in case PO tax details are not found.

                      It was observed that the function getSTformsTaxBaseAmount was always
                      considering the precedence 0 amount irrespective of the valus of the precendences.
                      This has been corrected.

22.   22/08/2003    Aparajita for bug# 2828928. Version # 616.4
                      Added the condition to consider null vendor id and modvat = 'N'taxes in the following
                      cursors. Also added the code to consider mod_cr_percentage.

                      - C_third_party_tax_recipt
                      - C_third_party_tax_po


23.     27/08/2003    Aparajita for bug#3116659. Version#616.5
                      Projects clean up.

24.   27/08/2003     Vijay Shankar for bug# 3096578. Version # 616.6
                       All taxes are not picked from PO Shipment if the taxes are selected based on
                       line_focus_id as there are different line_focus_id's for same line_location_id
                       which is wrong.Also we should use line_location_id to fetch the taxes instead of
                       line_focus_id as line_location_id refers to the PO Shipments in which taxes are
                       attached and line_focus_id is just a unique key for JAI_PO_LINE_LOCATIONS table.
                       Modified the cursor from_line_locations_taxes to fetch the taxes based on
                       line_location_id.

25      16/10/2003    Aparajita for bug#3193849. Version#616.7

                      Removed the ST forms functionality from here as ST forms population is now being
                      handled through a concurrent.

26    28/10/2003      Aparajita for bug#3206083. Version#616.7

                      If the base invoice is cancelled, there is no need to bring the tax lines.
                      Added code to check the cancelled date and if populated, returning from the proc.

27    28/10/2003    Aparajita for bug#3218978. Version#616.7

                      Tax amount is apportioned properly between the installments.
                      Differential tax amounts if any because of rounding is added to the last installment.

                      Code is not reading anything from terms master, instead based on the
                      distribution of the amount before tax, tax amount is distributed. coded in
                      in line function update_payment_schedule.


28      23/12/2003    Aparajita for bug#3306090. Version 618.1
                      Tax amount was calculated wrongly when tax currency is different from
                      invoice currency. This was not handled in the function
                      apportion_tax_pay_on_rect_f. Added code for the same.

29    07/01/2003    Aparajita for bug#3354932. Version#618.2
                    When the invoice is in foreign currency, for ERS invoice, base_amount in
                    ap_invoices_all should be updated to include the loc taxes as otherwise
                    it is creating wrong accounting entries.

                    This update needs to be done only for ERS invoices as other cases localization
                    does not update the invoice header amounts. p_rematch = 'PAY_ON_RECEIPT'.
                    Additionally this should be done only when the invoice currency is not
                    the functional currency.

30      27/01/2004   Aparajita for bug#3332988. Version#618.3

                    Call to AP_MRC_ENGINE_PKG.Maintain_MRC_Data for MRC functionality.

                    This call is made after every distribution line is inserted.
                    This has been implemented as a in line procedure insert_mrc_data.

                    The procedure is called after every insert into ap_invoice_distributions_all.

                    Procedure update_mrc_data has been created and invoked whereever invoice
                    header is being updated.

31     03/02/2004   Aparajita for bug#3015112. Version#618.4.
                    Removed the OPM costing functionality.
                    This was updating quantity invoiced and unit price for miscellaneous lines
                    and this was creating problem for subsequent transactions against the same
                    PO / Receipt.

                    The changes removed were brought in for bug#3051828.

32     24/02/2004   Vijay Shankar for bug#3461030. Version#618.5
                     Modified the MRC call to be dynamic by using EXECUTE IMMEDIATE.
                     This is done to take care of Ct.s who are on base version less than 11.5.7

33    25/02/2004   Aparajita for bug#3315162. Version#618.6

                    Base application gives problem while reversing localization tax lines.
                    This was analyzed with base and found out that the problem was because of
                    null value for matched_uom_lookup_code field of the miscellaneous tax distribution.
                    Further null value of quantity also creats problem as the billed quantity
                    on PO/receipt gets updated to null when the loc taxes does get reversed with
                    value populated for UOM.

                    Changes have been made to populate matched_uom_lookup_code same as item line
                    and quantity as 0.

34    30/03/2004   Aparajita for bug#3448803. Version#619.1.

                     track as asset flag for the distribution for tax line in payable invoice now
                     considers partially recoverable taxes. The logic is now as follows,

                     - default value of this flag is same as that of the corresponding item line.
                     - if the corresponding tax is modvatable to the extent of 100% then the value of
                     the flag is over written to 'N' irrespective of the value of the corresponding
                     base item line.

35      15/05/2004   Aparajita for bug#3624898. Version#619.2
                     Whenever the tax lines are populated, if the invoice is already fully paid
                     the paid amount is displayed wrongly to be including the tax amount.

                     Fixed the problem by updating the payment_status_flag in ap_invoices_all and
                     ap_payment_shedules_all to 'P' in case it was Y.

36      21/05/2004   Aparajita for bug#3632810. Version#115.1

                     Tax lines are apportioned when being brought over to AP for changes like
                     price, quantity etc. In cases where the UOM has been changed, it triggers a
                     change in price too. In such cases, UOM is also taken into account for changes
                     in quantity and price.

                     UOM at PO was being checked always from po_line_locations. But there are cases
                     like BPA, where the UOM is in po_lines_all in stead of po_line_locations_all.
                     Changed the code to check from po_lines_all whenever UOM does not exist in
                     Po_line_locations_all.

37     11/06/2004    Aparajita for bug#3671967. Version#115.2

                     When the tax line being brought over from PO by way of PO matching,
                     for completely recoverable taxes and a tax account has been defined for the tax
                     then tax account should be used.

                     This is applicable for PO matching only.

38    08/07/2004     Aparajita for bug#3752887. Version#115.3. Clean up.

                     Function apportion_tax_pay_on_rect_f was considering the quantity
                     from rcv_transactions and  taxes from JAI_RCV_LINE_TAXES.
                     This fails when there have been corrections as taxes are modified as
                     per the corrected quantity.

                     Cleaned the entire logic of apportioning of tax from PO to AP.
                     Used the function jai_ap_interface_pkg.get_apportion_factor which has been
                     designed new to find out the factor that needs to be applied. All Logic
                     of apportioning is now in the external function and removed a lot of code
                     from here which was trying to do the same here at more than one place.
                     Also rmoved the in line function function apportion_tax_pay_on_rect_f.

                     Function jai_ap_interface_pkg.get_apportion_factor was designed for purchase register report
                     through bug#3633078. Added the procedure here also in the patch as it is not
                     required to have the report to have the function. So no dependency.

                     Changes done via bug#2775043 earlier in this procedure for IPV for tax
                     line  was redone as it would again involve details of apportion.
                     Instead used the following logic to arrive at IPV amount.

                     tax invoice price variance :=
                     tax amount * (base item line variance amount / base item line amount).

39. 01/11/2003       ssumaith - bug# 3127834 - file version 115.4

                     currency precision was not used for rounding the tax amounts when inserting / updating
                     records into  ap_invoices_all , ap_invoices_distributions_all , ap_payment_Schedules_all
                     tables. As a result the invoice was going into automatic hold because the invoice amount
                     does not equal sum of distributions amount.

                     This has been resolved in the bug by getting the currency precision for the invoice
                     currency from FND_CURRENCIES table and using it in all the inserts and updates which
                     involve the tax amounts.

40. 30/12/2004       Aparajita - Bug#4095234. Version#115.5

                     Cursor r_cur_items_rec was getting used without being opened. There is no need to use this,
                     replaced with cur_items_rec. Removed the cursor r_cur_items.

41. 21/01/2005       Aparajita - Bug#4078546 Service Tax. Version#115.6

                     4106633  Base Bug For Education Cess on Excise, CVD and Customs.
                     4059774  Base Bug For Service Tax Regime Implementation.
                     4078546  Modification in receive and rtv accounting for service tax


                     Service Tax interim account needs to be populated as the charge account,
                     if the following condition is true.

                     Case of PO Matching or Accrue on receipt is No.

42. 11/02/2005      Aparajita - Bug#4177452. Version#115.7

                    Charge account for non-recoverable taxes were going was null.
                    This was because of the default assignment of,
                      v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;

                    inside the if of recoverable taxes.

                    Changed it to after the end if.

43  03/03/2005      Sanjikum for bug#4103473 Version 115.8

                    Price Correction. Added an in line function apportion_tax_4_price_cor_inv for
                    calculating the tax amount for price correction cases. This is being called before
                    each insertion of tax line if the tax amount is 0.


44  12/03/2005      Bug 4210102. Added by LGOPALSA Version 115.9
                    (1) Added CVD, Excise and Customs education cess
        (2) Added Check file syntax in dbdrv command
        (3) Added NOCOPY for OUT variables

45 8/05/2005        rchandan for bug#4333488. Version 116.1
                    The Invoice Distribution DFF is eliminated and a new global DFF is used to
                    maintain the functionality. From now the TDS tax, WCT tax and ESSI will not
                    be populated in the attribute columns of ap_invoice_distributions_all table
                    instead these will be populated in the global attribute columns. So the code changes are
                    made accordingly.

46 10-Jun-2005      rallamse for bug#  Version 116.2
                    All inserts into JAI_AP_MATCH_INV_TAXES table now include legal_entity_id as
                    part of R12 LE Initiative. The legal_entity_id is selected from ap_invoices_all in
                    cursor get_ven_info.

47  23-Jun-2005     Brathod for Bug# 4445989, Version 120.0
                    Issue: Impact uptake on IL Product for AP_INVOICE_LINES_ALL Uptake
                    Resolution:- Code modified to consider ap_invoice_lines_all instead of
                    ap_invoice_distributions_all.
                    Following changes done
                      -  Code refering to ap_invoice_distributions_all modified to consider
                         invoice_id and invoice_line_number as unique combination
                      -  invoice line record is created in ap_invoice_lines_all where ever previously
                         distribution was created
                      -  Obsoleted JAI_CMN_FA_INV_DIST_ALL
                      -  Modified structure of JAI_AP_MATCH_INV_TAXES to incorporate invoice lines
                         and also the fields from JAI_CMN_FA_INV_DIST_ALL
                      -  Code modfied to insert appropriate fields in JAI_AP_MATCH_INV_TAXES

48. 06-Jul-2005       Sanjikum for Bug#4474501
                      1) Commented the cursor - for_acct_id and corresponding open/fetch/close for the same.
                      2) Commented the call to function - jai_general_pkg.get_accounting_method

49. 25-Apr-2007       CSahoo for bug#5989740, File Version 120.14
                      Forward Porting of 11i bug#5907436
                      ENH: Handling of secondary and higher education cess.
                      Added the sh cess tax types.

50. 20-dec-2007      eric modified and added code for inclusive tax

51. 09-Jan-2008      Modifed by Jason Liu for retroactive price

52. 04-Feb-2008      JMEENA for bug#6780154

         Modify the insert statement of ap_invoice_lines_all to populate the po_distribution_id.


53. 21-Feb-2008      JMEENA for bug#6835548
         Changed the value of lv_match_type from NOT MATCHED to NOT_MATCHED.

54. 03-APR-2008      Jason Liu for bug#6918386
         Modified the cursor from_line_location_taxes
         1) Added the parameter p_source
         2) Added the UNION for PPA invoice
55.  03-APR-2008      Jason Liu for bug#66936416
         Added a condition to exclude the third party taxes

56. 19-May-2008     JMEENA for bug#7008161
        Modified the insert statement of ap_invoice_distributions_all to populate the charge_applicable_to_dist_id
        based on v_assets_tracking_flag and removed the condition of account_type.

 57.  12-Dec-2008  Added by Bgowrava for Bug#7503308, File Version 120.7.12000000.15, 120.34.12010000.4, 120.38
                  Issue: INDIA - TO INSERT TAXES FOR PAY ON RECEIPT REQUESTPERFORMANCE ISSUE
                  Reason: full table scan on JAI_RCV_TRANSACTIONS table in cursor c_get_excise_costing_flag
                  Fix:   Added organization_id and shipment_headder_id columns

58.  06-Apr-2010   Bgowrava For Bug#9499146, File Version 120.34.12010000.14,
                                 Issue: WRONG AP ACCRUAL ACCOUNT TAKING FOR RECOVERABLE TAXES LIKE EXCISE IN AP INVOICE
                                 Fix: Modified code so that all taxes will hit the same account as that of the  item line (except service type of taxes)

Future Dependencies For the release Of this Object:-
==================================================
(Please add a row in the section below only if your bug introduces a dependency due to spec change/
A new call to a object/A datamodel change )

-------------------------------------------------------------------------------------------------------
Version       Bug       Dependencies (including other objects like files if any)
--------------------------------------------------------------------------------------------------------
616.1         3038566   ALTER Script  JAI_AP_MATCH_INV_TAXES Table is altered.

115.3         3752887   Dependency on function jai_ap_interface_pkg.get_apportion_factor which is also added
                        in this patch. So no pre - req.

115.6         4146708   Base Bug for Service + Cess Release.

                        Variable usage of jai_constants package.

                        Call to following,
                        jai_general_pkg.is_item_an_expense
                        jai_general_pkg.get_accounting_method
                        jai_rcv_trx_processing_pkg.get_accrue_on_receipt
                        jai_cmn_rgm_recording_pkg.get_account


------------------------------------------------------------------------------------------------------- */


  Fnd_File.put_line(Fnd_File.LOG, 'Start procedure - jai_ap_match_tax_pkg.process_online ');

  OPEN  get_ven_info(inv_id);
  FETCH get_ven_info INTO get_ven_info_rec;
  CLOSE get_ven_info;
  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  Fnd_File.put_line(Fnd_File.LOG,
  'Input parameters - invoice number(id)/ invoice line no/Matching option :'
  || get_ven_info_rec.invoice_num  || '(' || inv_id || ')/' || pn_invoice_line_number || '/' || p_rematch);


  -- start added by bug#3206083
  if get_ven_info_rec.cancelled_date is not null then
    -- base invoice has been cancelled, no need to process tax.
    Fnd_File.put_line(Fnd_File.LOG, 'Base invoice has been cancelled, no need to process tax');
    return;
  end if;
  -- end added by bug#3206083

  ln_user_id  := fnd_global.user_id;
  ln_login_id := fnd_global.login_id;

  -- Start added for bug#3354932
  open c_functional_currency(get_ven_info_rec.set_of_books_id);
  fetch c_functional_currency into v_functional_currency;
  close c_functional_currency;
  -- End added for bug#3354932

  OPEN  checking_for_packing_slip(get_ven_info_rec.vendor_id, get_ven_info_rec.vendor_site_id, get_ven_info_rec.org_id);
  FETCH checking_for_packing_slip INTO chk_for_pcking_slip_rec;
  CLOSE checking_for_packing_slip;


  OPEN  c_inv(inv_id);
  FETCH c_inv INTO v_batch_id, v_source;
  CLOSE c_inv;

  -- Get mininum invoice distribution line number, Brathod, Bug# 4445989
  lv_match_type := 'NOT_MATCHED'; --Changed from NOT MATCHED to NOT_MATCHED for bug#6835548 by JMEENA
  lv_misc := 'MISCELLANEOUS';
  -- Bug 7249100. Added by Lakshmi Gopalsami
  lv_dist_class := 'PERMANENT';

  OPEN  cur_get_min_dist_linenum (inv_id, pn_invoice_line_number);
  FETCH cur_get_min_dist_linenum INTO ln_min_dist_line_num;
  CLOSE cur_get_min_dist_linenum;

  -- Added by Brathod for Bug# 4445989
  OPEN  cur_get_max_line_number;
  FETCH cur_get_max_line_number INTO ln_max_lnno;
  CLOSE cur_get_max_line_number;

  OPEN  cur_get_max_ap_inv_line (cpn_max_line_num => ln_max_lnno );
  FETCH cur_get_max_ap_inv_line INTO rec_max_ap_lines_all;
  CLOSE cur_get_max_ap_inv_line;
  -- End of Bug 4445989


  IF v_source <> 'SUPPLEMENT' THEN
    -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
    OPEN  cur_items(inv_id,pn_invoice_line_number,ln_min_dist_line_num);
    FETCH cur_items INTO cur_items_rec;
    CLOSE cur_items;
  END IF;

  OPEN  for_org_id(inv_id);
  FETCH for_org_id INTO for_org_id_rec;
  CLOSE for_org_id;

/* added by ssumaith  */

  open  c_fnd_curr_precision(for_org_id_rec.invoice_currency_code);
  fetch c_fnd_curr_precision into ln_precision;
  close c_fnd_curr_precision;

  if ln_precision is null then
     ln_precision := -1;--Modified by kunkumar for  5593895
  end if;

 /* ends here addition by ssumaith */

  /*OPEN  for_acct_id(NVL(for_org_id_rec.org_id, -1));
  FETCH for_acct_id INTO for_acct_id_rec;
  CLOSE for_acct_id;*/
  --commented the above by Sanjikum For Bug#4474501, as this cursor is not being used anywhere

  IF v_source <> 'SUPPLEMENT' THEN

    BEGIN  --06-Mar-2002
      SELECT chart_of_accounts_id INTO caid
      FROM   gl_sets_of_books
      WHERE  set_of_books_id = cur_items_rec.set_of_books_id;
    EXCEPTION
      WHEN OTHERS THEN
      ERRBUF := SQLERRM;
      RETCODE := 2;
    END ;-- end 06-Mar-2002

  END IF;

  begin
    -- following update statement is to just get a lock on the distribution lines of the invoice.
    -- the distribution line numbers should be unique and in sequence.
    update ap_invoice_distributions_all
    set    last_update_date = last_update_date
    where  invoice_id = inv_id;

    -- Added by Brathod for Bug# 4445989
    update ap_invoice_lines_all
    set    last_update_date = last_update_date
    where  invoice_id = inv_id;
    -- Cursor to select maximum line number from invoice lines for particular invoice
    SELECT max(line_number)
    INTO   ln_inv_line_num
    FROM   ap_invoice_lines_all
    WHERE  invoice_id = inv_id;
    -- End of Bug# 4445989

    /*
    Commented by Brathod for Bug# 4445989
    select max(DISTRIBUTION_LINE_NUMBER)
    into   v_distribution_no
    from   ap_invoice_distributions_all
    where  invoice_id = inv_id;
    */

  exception
    when others then
    errbuf := 'Unable to lock the distributions to get the next distributions number';
    retcode := 2;
    Return;
  end ;
  -- End: bug # 2805527

  SELECT accts_pay_code_combination_id
  INTO   apccid
  FROM   ap_invoices_all
  WHERE  invoice_id = inv_id;

  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  OPEN  for_dist_insertion(inv_id,pn_invoice_line_number, ln_min_dist_line_num);
  FETCH for_dist_insertion INTO for_dist_insertion_rec;
  CLOSE for_dist_insertion;

  -- deleted supplementary invoice block by Aparajita on 03/11/2002 for bug # 2567799.
  -- supplemntary invoice not being used.

  v_apportn_factor_for_item_line :=
  jai_ap_utils_pkg.get_apportion_factor(inv_id, pn_invoice_line_number);
  -- bug#3752887

  /* service Start */

  open c_rcv_transactions(rcv_tran_id);
  fetch c_rcv_transactions into r_rcv_transactions;
  close c_rcv_transactions;

/*following fetches added/modified for bug 6595773*/
  OPEN  from_po_distributions(po_dist_id);
  FETCH from_po_distributions INTO from_po_distributions_rec;
  CLOSE from_po_distributions;


  open c_po_lines_all(from_po_distributions_rec.po_line_id);
  fetch c_po_lines_all into r_po_lines_all;
  close c_po_lines_all;

  lv_is_item_an_expense := null;
  lv_is_item_an_expense := jai_general_pkg.is_item_an_expense
                           (
                              p_organization_id   =>     r_rcv_transactions.organization_id,
                              p_item_id           =>     r_po_lines_all.item_id
                           );

  /*lv_accounting_method_option := jai_general_pkg.get_accounting_method
                          (
                             p_org_id            =>    v_org_id,
                             p_sob_id            =>    for_dist_insertion_rec.set_of_books_id,
                             p_organization_id   =>    r_rcv_transactions.organization_id
                          );*/

  /*bug 9346307*/
    OPEN c_po_details;
    FETCH c_po_details INTO ln_po_line_id, ln_po_line_location_id;
    CLOSE c_po_details;

  IF po_dist_id IS NULL
  THEN
   SELECT Min(po_distribution_id)
   INTO ln_po_dist_id
   FROM po_distributions_all
   WHERE po_line_id = ln_po_line_id
   AND line_location_id = ln_po_line_location_id;
  END IF;
  /*end bug 9346307*/

  -- commented the above by Sanjikum for Bug#4474501
  lv_accrue_on_receipt_flag := jai_rcv_trx_processing_pkg.get_accrue_on_receipt
                         (
                            p_po_distribution_id => Nvl(po_dist_id,ln_po_dist_id)
                         );

  Fnd_File.put_line(Fnd_File.LOG, 'lv_accrue_on_receipt_flag='||lv_accrue_on_receipt_flag);

  open c_jai_regimes(jai_constants.service_regime);
  fetch c_jai_regimes into r_jai_regimes;
  close c_jai_regimes;

  /* service End */

  /* Bug 5358788. Added by Lakshmi Gopalsami
   * Fetch VAT Regime id
   */

  OPEN  c_jai_regimes(jai_constants.vat_regime);
  FETCH  c_jai_regimes INTO  r_vat_regimes;
  CLOSE  c_jai_regimes;

  /* Bug 5401111. Added by Lakshmi Gopalsami
   | Get the account type for the distribution.
   | This is required to find out whether charge_applicable_to_dist
   */
   lv_account_type := get_gl_account_type
                    (for_dist_insertion_rec.dist_code_combination_id);

  IF  p_rematch = 'PO_MATCHING' THEN

    Fnd_File.put_line(Fnd_File.LOG, 'inside  p_rematch = PO_MATCHING ');
    ---commented as receipt not required for pure po match
/*following fetch commented out for bug 6595773*/
    /*OPEN  from_po_distributions(po_dist_id);
    FETCH from_po_distributions INTO from_po_distributions_rec;
    CLOSE from_po_distributions;*/

      -- Added by Jason Liu for retroactive price on 2008/03/26
      -----------------------------------------------------------
      OPEN get_source_csr;
      FETCH get_source_csr INTO lv_source;
      CLOSE get_source_csr;
      -----------------------------------------------------------
      FOR i IN
      from_line_location_taxes(ln_po_line_location_id, for_org_id_rec.vendor_id, lv_source)/*bug 9346307*/
      LOOP  --L2

        /*5763527 */
        ln_project_id           := null;
        ln_task_id              := null;
        lv_exp_type             := null;
        ld_exp_item_date        := null;
        ln_exp_organization_id  := null;
        lv_project_accounting_context := null;
        lv_pa_addition_flag           := null;
        /* END 5763527 */

       -- Added by Brathod for Bug# 4445989
       /* v_distribution_no := v_distribution_no + 1; */
       v_distribution_no :=1;
       -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527, moved increment just before insert statement
       -- End Bug# 4445989

      -- start bug # 2775043
      v_tax_variance_inv_cur := null;
      v_tax_variance_fun_cur := null;
      v_price_var_accnt := null;
      v_tax_amount := -1;--Modified by kunkumar for  5593895
      r_service_regime_tax_type := null;
      -- end bug # 2775043

      -- Bug 5358788. Added by Lakshmi Gopalsami
      r_VAT_regime_tax_type := null;

      -- Start for bug#3752887
      v_tax_amount := i.tax_amount * v_apportn_factor_for_item_line;

      if i.currency <> for_org_id_rec.invoice_currency_code then
          v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
      end if;

      fnd_file.put_line(FND_FILE.LOG, ' Value of tax amount  -> '|| v_tax_amount);

      OPEN  c_tax(i.tax_id);
      FETCH c_tax INTO c_tax_rec;
      CLOSE c_tax;

      /* Service Start */
      v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
      v_dist_code_combination_id := null;

      --initial the tax_type
      lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

      -- 5763527, Brathod
      -- Modified the if condition to consider partial recoverable lines previous logic was hadling only when it is 100
      if i.modvat_flag = jai_constants.YES
      and nvl(c_tax_rec.mod_cr_percentage, -1) > 0 then

        --recoverable tax
        lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007

       /*  recoverable tax */
        v_assets_tracking_flag := 'N';

        open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
        fetch c_regime_tax_type into r_service_regime_tax_type;
        close c_regime_tax_type;

        fnd_file.put_line(FND_FILE.LOG,
                   ' Service regime: '||r_service_regime_tax_type.tax_type);

  /* Bug 5358788. Added by Lakshmi Gopalsami
   * Fetched the details of VAT regime
   */

        open c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
        fetch c_regime_tax_type into r_vat_regime_tax_type;
        close c_regime_tax_type;

        fnd_file.put_line(FND_FILE.LOG,
                   ' VAT regime: '||r_vat_regime_tax_type.tax_type);

/*following code added for bug 6595773*/
/*6595773 start*/
        /* Fetch ship_to_location_id and ship_to_organization_id from po_line_locations */
        ln_ship_to_organization_id := null;
        ln_ship_to_location_id := null;
        open c_get_ship_to_org_loc (cur_items_rec.line_location_id);
        fetch c_get_ship_to_org_loc  into ln_ship_to_organization_id
                                         ,ln_ship_to_location_id;
        close c_get_ship_to_org_loc;


       Fnd_File.put_line(Fnd_File.LOG, 'ln_ship_to_organization_id='||ln_ship_to_organization_id
                                     ||', r_po_lines_all.item_id='||r_po_lines_all.item_id
                                     );
       lv_is_item_an_expense := jai_general_pkg.is_item_an_expense
                           (
                              p_organization_id   =>     ln_ship_to_organization_id,
                              p_item_id           =>     r_po_lines_all.item_id
                           );
/*6595773 end*/
        if r_service_regime_tax_type.tax_type is not null then
          /* Service type of tax */
          v_dist_code_combination_id := check_service_interim_account
                                        (
                                          lv_accrue_on_receipt_flag,
                                          lv_accounting_method_option,
                                          lv_is_item_an_expense,
                                          r_jai_regimes.regime_id,
                                          v_org_id,
                                          p_rematch,
                                          c_tax_rec.tax_type,
                                          --added nvl for bug#9386496
                                          Nvl(po_dist_id,ln_po_dist_id) --Added by JMEENA for bug#6833506
                                        );
        fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_service_regime_tax_type.tax_type
             ||', ' || v_dist_code_combination_id);
        /* Bug 5358788. Added by Lakshmi Gopalsami
   * Commented p_rematch and added validation for
   * VAT regime.
   */
/*following elsif and else modified / added for bug 6595773*/
        ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
        -- p_rematch = 'PO_MATCHING' then
      Fnd_File.put_line(Fnd_File.LOG, 'lv_is_item_an_expense='||lv_is_item_an_expense);
    /*  v_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account
              (
               p_regime_id            =>      ln_vat_regime_id,
               p_organization_type    =>      jai_constants.orgn_type_io,
               p_organization_id      =>      ln_ship_to_organization_id ,
               p_location_id          =>      ln_ship_to_location_id ,
               p_tax_type             =>      c_tax_rec.tax_type,
               p_account_name         =>      jai_constants.recovery --RECOVERY
              );*/  --commented by Bgowrava for Bug#9499146
     v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;  --Added by Bgowrava for Bug#9499146
    ELSE
          /*v_dist_code_combination_id := c_tax_rec.tax_account_id;*/ --commented by Bgowrava for Bug#9499146
          v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id; --Added by Bgowrava for Bug#9499146
          fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
     || r_vat_regime_tax_type.tax_type
           ||', ' || v_dist_code_combination_id);

        end if;
      else -- NR tax ,project infor is same as the parent line
        /* 5763527 introduced for PROJETCS COSTING Impl */
        /* 5763527 */
        ln_project_id           := p_project_id;
        ln_task_id              := p_task_id;
        lv_exp_type             := p_expenditure_type;
        ld_exp_item_date        := p_expenditure_item_date;
        ln_exp_organization_id  := p_expenditure_organization_id;

        --non recoverable
        lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
      end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/


      /* Service End */

      -- Start bug#4103473
      if nvl(v_tax_amount,-1) = -1 then --Modified by kunkumar for bug 5593895
        v_tax_amount := apportion_tax_4_price_cor_inv(v_tax_amount,  i.tax_id);
      END IF;
      v_tax_amount := nvl(v_tax_amount,-1); --Modified by kunkumar for bug 5593895
      -- End bug#4103473

      fnd_file.put_line(FND_FILE.LOG, ' Value of tax amount  after apportion -> '|| v_tax_amount);

      --
      -- Begin 5763527
      --
      ln_rec_tax_amt  := null;
      ln_nrec_tax_amt := null;

      --added by Eric for inclusive tax on 20-dec-2007,begin
      -------------------------------------------------------------------------------------

      --1.If tax is FR (fully recoverable) or NR tax,one line need to be inserted into tax table
      --  For inclusive taxes without project info,there are no lines in the ap/dist line tables for a tax line.
      --  For inclusive taxes with project info,there are two lines in the ap/dist line tables for a tax line.
      --  For exclusive taxes, one tax  line maps to one corresponding ap/dist line in AP table.
      --

      --2.If tax is exclusive Partially Recoverable tax, two lines will be inserted into all 3 tables
      --  one is for NR and another is for R tax


      --3.If tax is inclusive Partially Recoverable tax,

      --3.1 with project information:  2 lines will be inserted into tax tables;2 lines will be inserted into AP lines
      --    the tax table store the NR and R tax,while Ap line/dist lines stores 2 new inserted line. One line is with
      --    recoverable amount/null project information and another is with negative recoverable amount/item project information


      --3.2 without project information: only two lines,one NR and one R tax line need to be inserted into tax table only
      --    no Ap line/dist lines need to be inserted into Ap line/dist lines

      -- So exclusive tax will be inserted into ap line /dist line and inclusive tax with prj infor

      -------------------------------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end



      ln_lines_to_insert := 1;



      --added by Eric for inclusive tax on 20-dec-2007,begin
      -------------------------------------------------------------------------------------
      --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
      --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
      --PR(partially recoverable) tax is processed in another logic

      IF ( NVL(i.inc_tax_flag,'N') = 'N'
           OR ( NVL(i.inc_tax_flag,'N') = 'Y'
                AND p_project_id IS NULL
              )
         )
      THEN
        ln_lines_to_insert := 1;
      ELSIF ( NVL(i.inc_tax_flag,'N') = 'Y'
              AND p_project_id IS NOT NULL
              AND lv_tax_type = 'RE'
            )
      THEN
        ln_lines_to_insert := 2;
      END IF;--( NVL(i.inc_tax_flag,'N') = 'N' OR ( NVL(i.inc_tax_flag,'N'))
      -------------------------------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end

      Fnd_File.put_line(Fnd_File.LOG, 'i.modvat_flag ='||i.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

      if i.modvat_flag = jai_constants.YES
      and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
      and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
      then
        --
        -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
        -- and instead of one line, two lines needs to be inserted.
        -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
        --
        ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
        ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
        ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
    /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */

        lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008

      end if;
      fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                      ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                      ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                       );

      --
      --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
      --  non recoverable tax amount and the second line will be for a recoverable tax amount
      --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
      --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
      --

      for line in 1..ln_lines_to_insert
      loop

        --Commented out the existing partially tax processing logic
        --replace it with new logic to cover inclusive tax case
        /*
        if line = 1 then

          v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
          lv_modvat_flag := i.modvat_flag ;

        elsif line = 2 then

          v_tax_amount := ln_nrec_tax_amt;

          if for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES then
            v_assets_tracking_flag := jai_constants.YES;
          end if;

          lv_modvat_flag := jai_constants.NO ;

          --
          -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
          -- projects related columns so that PROJECTS can consider this line for Project Costing
          --

          ln_project_id           := p_project_id;
          ln_task_id              := p_task_id;
          lv_exp_type             := p_expenditure_type;
          ld_exp_item_date        := p_expenditure_item_date;
          ln_exp_organization_id  := p_expenditure_organization_id;
          lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
          lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

          -- For non recoverable line charge account should be same as of the parent line
          v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

        end if;
        */

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -------------------------------------------------------------------------------------
        -- v_tax_amount is for storing the tax amount and  saving into the those 2 ap tables.
        -- lv_tax_line_amount is for storing the tax amount and saving into the tax table.

        -----------Exclusive Tax :

        -- *In FR/NR tax case, ln_lines_to_insert  =1
        -- v_tax_amount :=v_tax_amount; ( ln_rec_tax_amt IS Null)
        -- lv_tax_line_amount:=  v_tax_amount
        -- this line need to be inserted into 2 ap tables and 1 jai tax table

        -- *In PR tax case, ln_lines_to_insert   =2
        -- line 1:
        -- v_tax_amount :=ln_rec_tax_amt;
        -- lv_tax_line_amount:=  v_tax_amount
        -- this line need to be inserted into 2 ap tables and 1 jai tax table

        -- line2:
        -- v_tax_amount :=ln_nrec_tax_amt;
        -- lv_tax_line_amount:=  v_tax_amount
        -- this line need to be inserted into 2 ap tables and 1 jai tax table


        -----------Inclusive Tax :

        -- *In FR/NR tax without project case, ln_lines_to_insert  =1
        -- v_tax_amount :=v_tax_amount;
        -- lv_tax_line_amount:=  v_tax_amount
        -- this line need to be inserted into the jai tax table


        -- *In FR/NR tax with project case, ln_lines_to_insert is =2
        -- line 1:
        -- v_tax_amount       :=  v_tax_amount;
        -- lv_tax_line_amount :=  v_tax_amount;
        -- no project information
        -- this line need to be inserted into the jai tax table

        -- line2:
        -- v_tax_amount       := -v_tax_amount;
        -- lv_tax_line_amount :=  v_tax_amount;
        -- project information is same as parent line
        -- this line need to be inserted into 2 ap tables


        --* In PR tax without project case, ln_lines_to_insert =2
        -- line 1:
        -- v_tax_amount       :=  ln_rec_tax_amt;
        -- lv_tax_line_amount :=  ln_rec_tax_amt;
        -- no project information
        -- this line need to be inserted the jai tax table

        -- line2:
        -- v_tax_amount       :=  ln_nrec_tax_amt;
        -- lv_tax_line_amount :=  ln_nrec_tax_amt
        -- no project information
        -- this line need to be inserted the jai tax table


        --* In PR tax with project case, ln_lines_to_insert  =4
        -- line 1:
        -- v_tax_amount       :=  ln_rec_tax_amt;
        -- lv_tax_line_amount :=  ln_rec_tax_amt;
        -- no project information
        -- this line need to be inserted into the jai tax table only

        -- line 2:
        -- v_tax_amount       := ln_nrec_tax_amt;
        -- lv_tax_line_amount:=  ln_nrec_tax_amt;
        -- project information is same as parent line
        -- this line need to be inserted into the jai tax table only

        -- line 3:
        -- v_tax_amount       :=  ln_rec_tax_amt;
        -- lv_tax_line_amount :=  ln_rec_tax_amt;
        -- no project information
        -- this line need to be inserted into 2 ap tables only

        -- line 4:
        -- v_tax_amount       := -ln_rec_tax_amt;
        -- lv_tax_line_amount:=  ln_rec_tax_amt;
        -- project information is same as parent line
         -- this line need to be inserted into 2 ap tables only




        -- v_tax_amount is for storing the tax amount saving into the ap  tax table.
        --

        IF (NVL(i.inc_tax_flag,'N') = 'N')--exclusive case
        THEN
          IF line = 1 then

            v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
            lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
            lv_modvat_flag := i.modvat_flag ;

            lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
          ELSIF line = 2 then

            v_tax_amount             := ln_nrec_tax_amt;
            lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
            lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


            IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
              v_assets_tracking_flag := jai_constants.YES;
            END IF;

            lv_modvat_flag := jai_constants.NO ;

            --
            -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
            -- projects related columns so that PROJECTS can consider this line for Project Costing
            --
            IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
            END if;

            -- For non recoverable line charge account should be same as of the parent line
            v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

          END IF; --line = 1
        ELSIF (NVL(i.inc_tax_flag,'N') = 'Y')       --inclusive case
        THEN
          IF( lv_tax_type ='PR')
          THEN
            IF ( line = 1 )
            THEN
              --recoverable part
              v_tax_amount       := ln_rec_tax_amt ;
              lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
              lv_modvat_flag     := i.modvat_flag  ;
              lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

              --non recoverable part
            ELSIF ( line = 2 )
            THEN
              v_tax_amount       := ln_nrec_tax_amt  ;
              lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
              lv_modvat_flag     := jai_constants.NO ;
              lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

              --recoverable part without project infor
            ELSIF ( line = 3 )
            THEN
              v_tax_amount                  := ln_rec_tax_amt;
              lv_tax_line_amount            := NULL;

              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

              --recoverable part in negative amount with project infor
            ELSIF ( line = 4 )
            THEN
              v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
              lv_tax_line_amount            := NULL;
              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
            END IF; --line = 1
          ELSIF ( lv_tax_type = 'RE'
                  AND p_project_id IS NOT NULL
                )
          THEN
            --recoverable tax without project infor
            IF ( line = 1 )
            THEN
              v_tax_amount       :=  v_tax_amount  ;
              lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
              lv_modvat_flag     :=  i.modvat_flag ;
              lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            --recoverable tax in negative amount with project infor
            ELSIF ( line = 2 )
            THEN
              v_tax_amount       :=  v_tax_amount * -1;
              lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
              lv_modvat_flag     :=  i.modvat_flag  ;

              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            END IF;
          --  ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
          --  THEN
          ELSE -- eric removed the above criteria for bug 6888665 and 6888209
            Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
            --The case process the inclusive NR tax and inclusive RE tax not for project

            lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
            lv_modvat_flag     := i.modvat_flag  ;
            lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

          END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
        END IF; --(NVL(r_tax_lines_r ec.inc_tax_flag,'N') = 'N')
        -------------------------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end



        --
        -- End 5763527
        --

      --ln_inv_line_num := ln_inv_line_num + 1; commented out by eric for inclusive tax

      -- Added by Brathod for Bug#4445989
      Fnd_File.put_line(Fnd_File.LOG,
      'Before inserting into ap_invoice_lines_all for line no :' || ln_inv_line_num );

      --insert exclusive tax to the ap tables
      --or insert recoverable inclusive tax with project information the ap tables


      --1.Only exlusive taxes or inclusive taxes with project information
      --  are inserted into Ap Lines and Dist Lines

      --2.All taxes need to be inserted into jai tax tables. Futher the
      --  partially recoverable tax need to be splitted into 2 lines

      --added by Eric for inclusive tax on 20-dec-2007,begin
      ------------------------------------------------------------------------
      IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y' OR NVL(lv_tax_line_to_inst_flag,'N')='Y')
      THEN
        ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
      ---------------------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end
       IF  NVL(lv_ap_line_to_inst_flag,'N')='Y'
       THEN
        INSERT INTO ap_invoice_lines_all
        (
          INVOICE_ID
        , LINE_NUMBER
        , LINE_TYPE_LOOKUP_CODE
        , DESCRIPTION
        , ORG_ID
        , MATCH_TYPE
  , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
        , ACCOUNTING_DATE
        , PERIOD_NAME
        , DEFERRED_ACCTG_FLAG
        , DEF_ACCTG_START_DATE
        , DEF_ACCTG_END_DATE
        , DEF_ACCTG_NUMBER_OF_PERIODS
        , DEF_ACCTG_PERIOD_TYPE
        , SET_OF_BOOKS_ID
        , AMOUNT
        , WFAPPROVAL_STATUS
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATE_LOGIN
        /* 5763527 */
        , project_id
        , task_id
        , expenditure_type
        , expenditure_item_date
        , expenditure_organization_id
        /* End 5763527 */
        ,po_distribution_id --Added for bug#6780154
         )
        VALUES
        (
          inv_id
        , ln_inv_line_num
        , lv_misc
        , c_tax_rec.tax_name
        , v_org_id
        , lv_match_type
  , v_dist_code_combination_id  --Changes by nprashar for bug #6995437
        , rec_max_ap_lines_all.accounting_date
        , rec_max_ap_lines_all.period_name
        , rec_max_ap_lines_all.deferred_acctg_flag
        , rec_max_ap_lines_all.def_acctg_start_date
        , rec_max_ap_lines_all.def_acctg_end_date
        , rec_max_ap_lines_all.def_acctg_number_of_periods
        , rec_max_ap_lines_all.def_acctg_period_type
        , rec_max_ap_lines_all.set_of_books_id
        , ROUND(v_tax_amount,ln_precision)
        , rec_max_ap_lines_all.wfapproval_status -- Bug 4863208
        , sysdate
        , ln_user_id
        , ln_user_id
        , sysdate
        , ln_login_id
        /* 5763527 */
        , ln_project_id
        , ln_task_id
        , lv_exp_type
        , ld_exp_item_date
        , ln_exp_organization_id
        /* End 5763527 */
        ,po_dist_id --Added for bug#6780154
        );
       END IF;

     /*bug 9346307 - new LOOP added to insert multiple distributions for
     same line, if the matched PO shipment has multiple distributions*/
     v_distribution_no := 1;

     FOR r_ap_dist IN c_ap_dist(inv_id, pn_invoice_line_number)
     LOOP
      v_tax_amt_dist := v_tax_amount * r_ap_dist.qty_apportion_factor;

      IF nvl(r_ap_dist.invoice_price_variance, -1) <> -1 AND
         nvl(r_ap_dist.amount, -1) <> -1
      THEN
        v_price_var_accnt := r_ap_dist.price_var_code_combination_id;
        v_tax_variance_inv_cur := v_tax_amt_dist * (r_ap_dist.invoice_price_variance / r_ap_dist.amount);
        v_tax_variance_fun_cur := v_tax_variance_inv_cur * nvl(for_org_id_rec.exchange_rate, 1);
      END IF;

      IF i.modvat_flag = jai_constants.no OR line = 2 OR line = 4
      THEN
        v_assets_tracking_flag := r_ap_dist.assets_tracking_flag;
        lv_project_accounting_context := r_ap_dist.project_accounting_context;
        lv_pa_addition_flag := r_ap_dist.pa_addition_flag;
      END IF;

      v_dist_code_combination_id := Nvl(v_dist_code_combination_id,r_ap_dist.dist_code_combination_id);

      --Added by kunkumar for bug 5593895
       ln_base_amount := null ;
      if i.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
        ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt(
                            p_invoice_id          =>   inv_id ,
                            p_line_location_id    =>   ln_po_line_location_id ,
                            p_transaction_id       =>   null  ,
                            p_parent_dist_id      =>   r_ap_dist.invoice_distribution_id ,
                            p_tax_id              =>   i.tax_id
                          ) ;
      end if ;

      --End; --Added by kunkumar for bug 5593895
        Fnd_File.put_line(Fnd_File.LOG,
        'Before inserting into ap_invoice_distributions_all for distribution line no :'
        ||v_distribution_no  );

        -- Start bug#3332988
        open c_get_invoice_distribution;
        fetch c_get_invoice_distribution into v_invoice_distribution_id;
        close c_get_invoice_distribution;
        -- End bug#3332988

        fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

       IF  NVL(lv_ap_line_to_inst_flag,'N')='Y'
       THEN
        INSERT INTO ap_invoice_distributions_all
        (
        accounting_date,
        accrual_posted_flag,
        assets_addition_flag,
        assets_tracking_flag,
        cash_posted_flag,
        distribution_line_number,
        dist_code_combination_id,
        invoice_id,
        last_updated_by,
        last_update_date,
        line_type_lookup_code,
        period_name,
        set_of_books_id ,
        amount,
        base_amount,
        batch_id,
        created_by,
        creation_date,
        description,
        exchange_rate_variance,
        last_update_login,
        match_status_flag,
        posted_flag,
        rate_var_code_combination_id ,
        reversal_flag ,
        program_application_id,
        program_id,
        program_update_date,
        accts_pay_code_combination_id,
        invoice_distribution_id,     /*  Added on 11-sep-00  */
        quantity_invoiced,
        po_distribution_id , -- added for bug # 2483164
        rcv_transaction_id, -- added for bug # 2483164
        price_var_code_combination_id, -- following three lines added for bug # 2775043.
        invoice_price_variance,
        base_invoice_price_variance,
        matched_uom_lookup_code  -- bug#3315162
        ,invoice_line_number -- Added by Brathod for Bug# 4445989
        ,org_id   -- Bug 4863208
        ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
        /* 5763527 */
        , project_id
        , task_id
        , expenditure_type
        , expenditure_item_date
        , expenditure_organization_id
        , project_accounting_context
        , pa_addition_flag
        -- Bug 7249100. Added by Lakshmi Gopalsami
          ,distribution_class
        )
        VALUES
        (
        rec_max_ap_lines_all.accounting_date,
        'N',
      r_ap_dist.assets_addition_flag,
        v_assets_tracking_flag,
        'N',
        v_distribution_no,
        v_dist_code_combination_id,
        inv_id,
        ln_user_id,
        sysdate,
        lv_misc,
        rec_max_ap_lines_all.period_name,
        rec_max_ap_lines_all.set_of_books_id ,
      ROUND(v_tax_amt_dist,ln_precision), -- replaced 2 with ln_precision - ssumaith - bug# 3127834
      ROUND(v_tax_amt_dist * r_ap_dist.exchange_rate, ln_precision),
        v_batch_id,
        ln_user_id,
        sysdate,
        c_tax_rec.tax_name,
        null,--kunkumar for forward porting to R12
        ln_login_id,
      r_ap_dist.match_status_flag , -- Bug 4863208
        'N',
        NULL,
      r_ap_dist.reversal_flag,  -- Bug 4863208
      r_ap_dist.program_application_id,
      r_ap_dist.program_id,
      r_ap_dist.program_update_date,
      r_ap_dist.accts_pay_code_combination_id,
        v_invoice_distribution_id,
        -1, --Modified by kunkumar for bug# 5593895
      r_ap_dist.po_distribution_id ,
        rcv_tran_id,
        v_price_var_accnt,
        v_tax_variance_inv_cur,
        v_tax_variance_fun_cur,
      r_ap_dist.matched_uom_lookup_code,
        ln_inv_line_num,
      r_ap_dist.org_id, -- Bug 4863208
        -- Bug 5401111. Added by Lakshmi Gopalsami
        decode(v_assets_tracking_flag,'N',
             NULL,r_ap_dist.invoice_distribution_id)
          /* 5763527 */
        , ln_project_id
        , ln_task_id
        , lv_exp_type
        , ld_exp_item_date
        , ln_exp_organization_id
        , lv_project_accounting_context
        , lv_pa_addition_flag
        /* End 5763527 */
        -- Bug 7249100. Added by Lakshmi Gopalsami
        ,lv_dist_class
        );
      --added by Eric for inclusive tax on 20-dec-2007,begin
      -----------------------------------------------------------------
      END IF;--( NVL(lv_ap_line_to_inst_flag,'N')='Y')
      -----------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end


      Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_AP_MATCH_INV_TAXES ');

      --added by Eric for inclusive tax on 20-dec-2007,begin
      -----------------------------------------------------------------
      IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
      THEN
      -----------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end
        INSERT INTO JAI_AP_MATCH_INV_TAXES
        (
        tax_distribution_id,

        assets_tracking_flag,
        invoice_id,
        po_header_id,
        po_line_id,
        line_location_id,
        set_of_books_id,
        --org_id,
        exchange_rate,
        exchange_rate_type,
        exchange_date,
        currency_code,
        code_combination_id,
        last_update_login,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        acct_pay_code_combination_id,
        accounting_date,
        tax_id,
        tax_amount,
        base_amount,
        chart_of_accounts_id,
        distribution_line_number,
        po_distribution_id,  -- added  by bug#3038566
        parent_invoice_distribution_id,  -- added  by bug#3038566
        legal_entity_id -- added by rallamse bug#
        ,INVOICE_LINE_NUMBER  --    Added by Brathod, Bug# 4445989
        ,INVOICE_DISTRIBUTION_ID ------------|
        ,PARENT_INVOICE_LINE_NUMBER----------|
        ,RCV_TRANSACTION_ID
        ,LINE_TYPE_LOOKUP_CODE
        /* 5763527 */
        , recoverable_flag
        , line_no            -- Bug 5553150, 5593895
        )
        -- End Bug# 4445989
        VALUES
        (
        JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,

        v_assets_tracking_flag, -- 'N', Commented by Aparajita for bug # 2851123
        inv_id,
        cur_items_rec.po_header_id,
        cur_items_rec.po_line_id,
        cur_items_rec.line_location_id,
        cur_items_rec.set_of_books_id,
        --cur_items_rec.org_id,
        cur_items_rec.rate,
        cur_items_rec.rate_type,
        cur_items_rec.rate_date,
        cur_items_rec.currency_code,
        v_dist_code_combination_id,
        cur_items_rec.last_update_login,
        cur_items_rec.creation_date,
        cur_items_rec.created_by,
        cur_items_rec.last_update_date,
        cur_items_rec.last_updated_by,
        apccid,
        cur_items_rec.invoice_date,
        i.tax_id,
        --ROUND(v_tax_amount, ln_precision), deleted by eric for inclusvice tax on 20-dec-2007
        ROUND(lv_tax_line_amount * r_ap_dist.qty_apportion_factor, ln_precision),  --added by eric for compatibility of inclusvice tax on 20-dec-2007
        nvl(ln_base_amount, ROUND(ROUND(i.tax_amount*r_ap_dist.qty_apportion_factor, ln_precision), ln_precision)),
        caid,
        v_distribution_no,
      r_ap_dist.po_distribution_id, -- added  by bug#3038566
      r_ap_dist.invoice_distribution_id, -- added  by bug#3038566
        get_ven_info_rec.legal_entity_id -- added by rallamse bug#
        --, ln_inv_line_num , modified by eric for inclusvice tax
        --v_invoice_distribution_id,deleted by eric for inclusvice tax on 20-dec-2007

        --added by eric for inclusvice tax on 20-dec-2007,begin
        ---------------------------------------------------------------
        , DECODE ( NVL(i.inc_tax_flag,'N')
                 , 'N',ln_inv_line_num
                 , 'Y',pn_invoice_line_number
                 )
        , NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
        ---------------------------------------------------------------
        --added by eric for inclusvice tax on 20-dec-2007,end
        , pn_invoice_line_number
        , rcv_tran_id
        , lv_misc
        , lv_modvat_flag -- 5763527
        , i.tax_line_no  -- Bug 5553150, 5593895
        );

      --added by Eric for inclusive tax on 20-dec-2007,begin
      -----------------------------------------------------------------
      END IF;--(NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
      -----------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end


      /*  Bug 46863208. Added by Lakshmi Gopalsami
           Commented the MRC call
      insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
      */

      v_distribution_no := v_distribution_no +1;

      END LOOP;  /*bug 9346307*/

      /* Commented out by Eric for bug 8345512
      cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
      */

      --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
      ------------------------------------------------------------------
      IF NVL(i.inc_tax_flag,'N') ='N'
      THEN
        cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
      END IF;
      ------------------------------------------------------------------
      --Modified by Eric for bug 8345512 on 13-Jul-2009,end
      END IF;
      /* Obsoleted as a part of R12 , Bug# 4445989
      Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_CMN_FA_INV_DIST_ALL');
      INSERT INTO JAI_CMN_FA_INV_DIST_ALL
      (
      invoice_id,
      invoice_distribution_id,
      set_of_books_id,
      batch_id,
      po_distribution_id,
      rcv_transaction_id,
      dist_code_combination_id,
      accounting_date,
      assets_addition_flag,
      assets_tracking_flag,
      distribution_line_number,
      line_type_lookup_code,
      amount,
      description,
      match_status_flag,
      quantity_invoiced
      )
      VALUES
      (
      inv_id,
      ap_invoice_distributions_s.CURRVAL,
      for_dist_insertion_rec.set_of_books_id,
      v_batch_id,
      for_dist_insertion_rec.po_distribution_id,
      rcv_tran_id,
      v_dist_code_combination_id,
      for_dist_insertion_rec.accounting_date,
      for_dist_insertion_rec.assets_addition_flag,
      v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
      v_distribution_no,
      'MISCELLANEOUS',
      ROUND(v_tax_amount, ln_precision),
      c_tax_rec.tax_name,
      NULL,
      NULL);
      */
      end loop ;--> for line in 1 to ln_lines_to_insert Brathod, 5763527
    END LOOP;

    /* Bug 5358788. Added by Lakshmi Gopalsami
     * Removed the update which is updating ap_invoices_all
     * and ap_payment_schedules_all
     */

    /* Bug 8866084 - Start
     * Added the update which is updating ap_invoices_all
     * and ap_payment_schedules_all
     * Needs to be updated for Invoices created from iSupplier
    */

     open c_get_ap_invoice_src (inv_id);
     fetch c_get_ap_invoice_src into ln_source;
     close c_get_ap_invoice_src;

     if (ln_source = 'ISP') then

         /*
         cum_tax_amt is initialized with -1 for Bug 5593895. Bug updates are not clear as to why it was done
         This causes Tax Amount to be less by 1 when PO Matched Invoice is created from iSupplier
         Hence incrementing Tax Amount by 1 for this specific scenario as modifying initialization to 0 may cause regression
         */
         cum_tax_amt := cum_tax_amt + 1;

         v_update_payment_schedule:=update_payment_schedule(cum_tax_amt);

         UPDATE ap_invoices_all
         SET   invoice_amount       =  invoice_amount   + cum_tax_amt,
               approved_amount      =  approved_amount  + cum_tax_amt,
               pay_curr_invoice_amount =  pay_curr_invoice_amount + cum_tax_amt,
               amount_applicable_to_discount =  amount_applicable_to_discount + cum_tax_amt,
               payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
         WHERE  invoice_id = inv_id;

         if for_org_id_rec.invoice_currency_code <> v_functional_currency then
            -- invoice currency is not the functional currency.
            update ap_invoices_all
            set    base_amount = invoice_amount  * exchange_rate
            where  invoice_id = inv_id;
         end if;

     end if;

     /*Bug 8866084 - End*/

  ELSIF p_rematch = 'PAY_ON_RECEIPT' THEN

    Fnd_File.put_line(Fnd_File.LOG, 'inside  p_rematch = PAY_ON_RECEIPT ');

    IF p_receipt_code = 'RECEIPT' THEN

      Fnd_File.put_line(Fnd_File.LOG, 'inside  p_receipt_code = RECEIPT ');

      /* Begin 5763527 */
      fnd_file.put_line(fnd_file.log, 'rcv_tran_id='||rcv_tran_id);
      open  c_get_excise_costing_flag (cp_rcv_transaction_id => rcv_tran_id
                                    ,cp_organization_id =>  r_rcv_transactions.organization_id   --Added by Bgowrava for Bug#7503308
                                      ,cp_shipment_header_id     =>  p_shipment_header_id          --Added by Bgowrava for Bug#7503308
                    ,cp_txn_type        =>  'DELIVER'                           --Added by Bgowrava for Bug#7503308
                                      ,cp_attribute1      =>  'CENVAT_COSTED_FLAG');              --Added by Bgowrava for Bug#7503308
      fetch c_get_excise_costing_flag into lv_excise_costing_flag;
      close c_get_excise_costing_flag ;
      /* End 5763527 */

      FOR tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP

        -- Added By Brathod, Bug# 44459989
        /* v_distribution_no := v_distribution_no + 1 ; */
        -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527 moved the increment to just before insert statement
        v_distribution_no  := 1;
        -- End Bug# 4445989

        r_service_regime_tax_type := null;

        -- Bug 5358788. Added by Lakshmi Gopalsami
        r_VAT_regime_tax_type := null;

        /* 5763527 */
        ln_project_id           := null;
        ln_task_id              := null;
        lv_exp_type             := null;
        ld_exp_item_date        := null;
        ln_exp_organization_id  := null;
        lv_project_accounting_context := null;
        lv_pa_addition_flag := null;


        OPEN  c_tax(tax_lines1_rec.tax_id);
        FETCH c_tax INTO c_tax_rec;
        CLOSE c_tax;


   -- added, kunkumar for 5593895
        ln_base_amount := null ;
        if tax_lines1_rec.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
          ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                            (
                              p_invoice_id          =>   inv_id ,
                              p_line_location_id    =>   null ,
                              p_transaction_id      =>   rcv_tran_id  ,
                              p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                              p_tax_id              =>   tax_lines1_rec.tax_id
                            ) ;
        end if ;
        -- ended, Harshita for Bug 5593895


        /* Service Start */
        v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
        v_dist_code_combination_id := null;

        --initial the tax_type
        lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007


        -- 5763527, Brathod
        -- Modified the if condition to consider partial recoverable lines previous logic was hadling only when it is 100
        if tax_lines1_rec.modvat_flag = jai_constants.YES
        and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
        then


         /*  recoverable tax */
          v_assets_tracking_flag := 'N';

          --recoverable tax
          lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007

          open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
          fetch c_regime_tax_type into r_service_regime_tax_type;
          close c_regime_tax_type;

    fnd_file.put_line(FND_FILE.LOG,
                   ' Service regime: '||r_service_regime_tax_type.tax_type);

     /* Bug 5358788. Added by Lakshmi Gopalsami
    * Fetched the details of VAT regime
    */

         OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
          FETCH  c_regime_tax_type INTO  r_vat_regime_tax_type;
         CLOSE  c_regime_tax_type;

         fnd_file.put_line(FND_FILE.LOG,
                   ' VAT regime: '||r_vat_regime_tax_type.tax_type);

          if r_service_regime_tax_type.tax_type is not null then
            /* Service type of tax */
            v_dist_code_combination_id := check_service_interim_account
                                          (
                                            lv_accrue_on_receipt_flag,
                                            lv_accounting_method_option,
                                            lv_is_item_an_expense,
                                            r_jai_regimes.regime_id,
                                            v_org_id,
                                            p_rematch,
                                            c_tax_rec.tax_type,
              po_dist_id  --Added by JMEENA for bug#6833506
                                          );
    fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
     || r_service_regime_tax_type.tax_type
           ||', ' || v_dist_code_combination_id);

         /* Bug 5358788. Added by Lakshmi Gopalsami
    * Commented p_rematch and added validation for
    * VAT regime.
    */
  /*following elsif block modified for bug 6595773*/
          ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
            --p_rematch = 'PO_MATCHING' then

            v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
            fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
                 || r_vat_regime_tax_type.tax_type
                 ||', ' || v_dist_code_combination_id);
           END IF;

        ELSE  /* 5763527 introduced for PROJETCS COSTING Impl */
          -- Bug 6338371
          -- Added if condition.  Project details should be populated only if
          -- the accrue_on_receipt is not checked on po shipment
          IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN
            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
    END IF;          /* End 5763527 */

          --non recoverable
          lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
        END IF; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/


        /* Bug#4177452*/
        if v_dist_code_combination_id is null then
          v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
        end if;


        /* Service End */


        -- Start for bug#3752887
        v_tax_amount := tax_lines1_rec.tax_amount * v_apportn_factor_for_item_line;

        if for_org_id_rec.invoice_currency_code <> tax_lines1_rec.currency then
          v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
        end if;
        -- End for bug#3752887


        -- Start bug#4103473
        if nvl(v_tax_amount,-1) = -1 then
          v_tax_amount := apportion_tax_4_price_cor_inv(v_tax_amount,  tax_lines1_rec.tax_id);
        END IF;
        v_tax_amount := nvl(v_tax_amount,-1);
        -- End bug#4103473

        /* Bug#5763527 */
        Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.tax_type='||c_tax_rec.tax_type  ||',lv_excise_costing_flag='||lv_excise_costing_flag);
        if UPPER(c_tax_rec.tax_type)  like  '%EXCISE%' then
          if lv_excise_costing_flag = 'Y' then
            IF  nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' -- Bug 6338371
            then
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
            end if;
            v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id;
          END if;
        end if;
        /* End# 5763527 */

        --
        -- Begin 5763527
        --
        ln_rec_tax_amt  := null;
        ln_nrec_tax_amt := null;
        ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -------------------------------------------------------------------------------------
        --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
        --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
        --PR(partially recoverable) tax is processed in another logic

        IF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N'
             OR ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                  AND p_project_id IS NULL
                )
           )
        THEN
          ln_lines_to_insert := 1;
        ELSIF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                AND p_project_id IS NOT NULL
                AND lv_tax_type = 'RE'
              )
        THEN
          ln_lines_to_insert := 2;
        END IF;--( NVL(tax_lines1_recinc_tax_flag,'N') = 'N')
        -------------------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

        Fnd_File.put_line(Fnd_File.LOG, 'tax_lines1_rec.modvat_flag ='||tax_lines1_rec.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

        if tax_lines1_rec.modvat_flag = jai_constants.YES
        and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
        and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
        then
          --
          -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
          -- and instead of one line, two lines needs to be inserted.
          -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
          --
          ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
      ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
          ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
      /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */
          lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008
        end if;
        fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                        ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                        ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                         );

        --
        --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
        --  non recoverable tax amount and the second line will be for a recoverable tax amount
        --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
        --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
        --

        for line in 1..ln_lines_to_insert
        loop
          --commented out by eric for inclusive tax on 20-dec-2007,begin
          /*
          if line = 1 then

            v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
            lv_modvat_flag := tax_lines1_rec.modvat_flag ;

          elsif line = 2 then

            v_tax_amount := ln_nrec_tax_amt;

            if for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES then
              v_assets_tracking_flag := jai_constants.YES;
            end if;

            lv_modvat_flag := jai_constants.NO ;

            --
            -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
            -- projects related columns so that PROJECTS can consider this line for Project Costing
            --
            IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
            END if;
            -- For non recoverable line charge account should be same as of the parent line
            v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

          end if;
          */
          --commented out by eric for inclusive tax on 20-dec-2007,end

          --added by Eric for inclusive tax on 20-dec-2007,begin
          -------------------------------------------------------------------------------------
          IF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N')--exclusive case
          THEN
            IF line = 1 then

              v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
              lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
              lv_modvat_flag := tax_lines1_rec.modvat_flag ;

              lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
            ELSIF line = 2 then

              v_tax_amount             := ln_nrec_tax_amt;
              lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


              IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
                v_assets_tracking_flag := jai_constants.YES;
              END IF;

              lv_modvat_flag := jai_constants.NO ;

              --
              -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
              -- projects related columns so that PROJECTS can consider this line for Project Costing
              --
              IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
                ln_project_id           := p_project_id;
                ln_task_id              := p_task_id;
                lv_exp_type             := p_expenditure_type;
                ld_exp_item_date        := p_expenditure_item_date;
                ln_exp_organization_id  := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
              END if;

              -- For non recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

            END IF; --line = 1
          ELSIF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y')       --inclusive case
          THEN
            IF( lv_tax_type ='PR')
            THEN
              IF ( line = 1 )
              THEN
                --recoverable part
                v_tax_amount       := ln_rec_tax_amt ;
                lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
                lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

                --non recoverable part
              ELSIF ( line = 2 )
              THEN
                v_tax_amount       := ln_nrec_tax_amt  ;
                lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
                lv_modvat_flag     := jai_constants.NO ;
                lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

                --recoverable part without project infor
              ELSIF ( line = 3 )
              THEN
                v_tax_amount                  := ln_rec_tax_amt;
                lv_tax_line_amount            := NULL;

                lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                --Project information
                ln_project_id                 := NULL;
                ln_task_id                    := NULL;
                lv_exp_type                   := NULL;
                ld_exp_item_date              := NULL;
                ln_exp_organization_id        := NULL;
                lv_project_accounting_context := NULL;
                lv_pa_addition_flag           := NULL;

                -- For inclusive recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

                --recoverable part in negative amount with project infor
              ELSIF ( line = 4 )
              THEN
                v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
                lv_tax_line_amount            := NULL;
                lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                --Project information
                ln_project_id                 := p_project_id;
                ln_task_id                    := p_task_id;
                lv_exp_type                   := p_expenditure_type;
                ld_exp_item_date              := p_expenditure_item_date;
                ln_exp_organization_id        := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

                -- For inclusive recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
              END IF; --line = 1
            ELSIF ( lv_tax_type = 'RE'
                    AND p_project_id IS NOT NULL
                  )
            THEN
              --recoverable tax without project infor
              IF ( line = 1 )
              THEN
                v_tax_amount       :=  v_tax_amount  ;
                lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
                lv_modvat_flag     :=  tax_lines1_rec.modvat_flag ;
                lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

                ln_project_id                 := NULL;
                ln_task_id                    := NULL;
                lv_exp_type                   := NULL;
                ld_exp_item_date              := NULL;
                ln_exp_organization_id        := NULL;
                lv_project_accounting_context := NULL;
                lv_pa_addition_flag           := NULL;
                v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
              --recoverable tax in negative amount with project infor
              ELSIF ( line = 2 )
              THEN
                v_tax_amount       :=  v_tax_amount * -1;
                lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
                lv_modvat_flag     :=  tax_lines1_rec.modvat_flag  ;

                ln_project_id                 := p_project_id;
                ln_task_id                    := p_task_id;
                lv_exp_type                   := p_expenditure_type;
                ld_exp_item_date              := p_expenditure_item_date;
                ln_exp_organization_id        := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
              END IF;
            --  ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
            --  THEN
            ELSE -- eric removed the above criteria for bug 6888665 and 6888209
              Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
              --The case process the inclusive NR tax and inclusive RE tax not for project

              lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
              lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
              lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

            END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
          END IF; --(NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N')
          -------------------------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end




          fnd_file.put_line(fnd_file.log, 'line='||line||', v_tax_amount='|| v_tax_amount
                                          ||'lv_modvat_flag='||lv_modvat_flag
                                          ||'v_assets_tracking_flag='||v_assets_tracking_flag
                              );

          --ln_inv_line_num := ln_inv_line_num + 1;commented out by eric for inclusive tax
          --
          -- End 5763527
          --

          Fnd_File.put_line(Fnd_File.LOG,
          'Before inserting into ap_invoice_lines_all for line no :'|| ln_inv_line_num  );


          --insert exclusive tax to the ap tables
          --or insert recoverable inclusive tax with project information the ap tables


          --1.Only exlusive taxes or inclusive taxes with project information
          --  are  inserted into Ap Lines and Dist Lines

          --2.All taxes need to be inserted into jai tax tables. Futher the
          --  partially recoverable tax need to be splitted into 2 lines

          --added by Eric for inclusive tax on 20-dec-2007,begin
          ------------------------------------------------------------------------
          IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
          THEN
            ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
          ---------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

            INSERT INTO ap_invoice_lines_all
            (
              INVOICE_ID
            , LINE_NUMBER
            , LINE_TYPE_LOOKUP_CODE
            , DESCRIPTION
            , ORG_ID
            , MATCH_TYPE
      , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
            , ACCOUNTING_DATE
            , PERIOD_NAME
            , DEFERRED_ACCTG_FLAG
            , DEF_ACCTG_START_DATE
            , DEF_ACCTG_END_DATE
            , DEF_ACCTG_NUMBER_OF_PERIODS
            , DEF_ACCTG_PERIOD_TYPE
            , SET_OF_BOOKS_ID
            , AMOUNT
            , WFAPPROVAL_STATUS
            , CREATION_DATE
            , CREATED_BY
            , LAST_UPDATED_BY
            , LAST_UPDATE_DATE
            , LAST_UPDATE_LOGIN
              /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
            /* End 5763527 */
            ,po_distribution_id --Added for bug#6780154

            )
            VALUES
            (
              inv_id
            , ln_inv_line_num
            , lv_misc
            , c_tax_rec.tax_name
            , v_org_id
            , NULL
      ,v_dist_code_combination_id
            , rec_max_ap_lines_all.accounting_date
            , rec_max_ap_lines_all.period_name
            , rec_max_ap_lines_all.deferred_acctg_flag
            , rec_max_ap_lines_all.def_acctg_start_date
            , rec_max_ap_lines_all.def_acctg_end_date
            , rec_max_ap_lines_all.def_acctg_number_of_periods
            , rec_max_ap_lines_all.def_acctg_period_type
            , rec_max_ap_lines_all.set_of_books_id
            , ROUND(v_tax_amount,ln_precision)
            , rec_max_ap_lines_all.wfapproval_status -- Bug 4863208
            , sysdate
            , ln_user_id
            , ln_user_id
            , sysdate
            , ln_login_id
              /* 5763527 */
              , ln_project_id
              , ln_task_id
              , lv_exp_type
              , ld_exp_item_date
              , ln_exp_organization_id
              /* End 5763527 */
           ,po_dist_id  --Added for bug#6780154
            );

            Fnd_File.put_line(Fnd_File.LOG,
            'Before inserting into ap_invoice_distributions_all for distribution line no : '
            ||v_distribution_no);

            -- Start bug#3332988
            open c_get_invoice_distribution;
            fetch c_get_invoice_distribution into v_invoice_distribution_id;
            close c_get_invoice_distribution;
            -- End bug#3332988

            fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

            INSERT INTO ap_invoice_distributions_all
            (
            accounting_date,
            accrual_posted_flag,
            assets_addition_flag,
            assets_tracking_flag,
            cash_posted_flag,
            distribution_line_number,
            dist_code_combination_id,
            invoice_id,
            last_updated_by,
            last_update_date,
            line_type_lookup_code,
            period_name,
            set_of_books_id,
            amount,
            base_amount,
            batch_id,
            created_by,
            creation_date,
            description,
            exchange_rate_variance,
            last_update_login,
            match_status_flag,
            posted_flag,
            rate_var_code_combination_id,
            reversal_flag,
            program_application_id,
            program_id,
            program_update_date,
            accts_pay_code_combination_id,
            invoice_distribution_id,
            quantity_invoiced,
            po_distribution_id ,
            rcv_transaction_id,
            matched_uom_lookup_code
            ,INVOICE_LINE_NUMBER
            ,org_id -- Bug 4863208
            ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
            /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
            , project_accounting_context
            , pa_addition_flag
            /* End 5763527 */
           -- Bug 7249100. Added by Lakshmi Gopalsami
            ,distribution_class
            )
            VALUES
            (
            rec_max_ap_lines_all.accounting_date,
            'N', --for_dist_insertion_rec.accrual_posted_flag,
            for_dist_insertion_rec.assets_addition_flag,
            v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
            'N',
            v_distribution_no,
            /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
                   * for_dist_insertion_rec.dist_code_combination_id
             * and v_dist_code_combination_id
             */
            v_dist_code_combination_id,
            inv_id,
            ln_user_id,
            sysdate,
            lv_misc,
            rec_max_ap_lines_all.period_name,
            rec_max_ap_lines_all.set_of_books_id,
            round(v_tax_amount,ln_precision),
            ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision),
            v_batch_id,
            ln_user_id,
            sysdate,
            c_tax_rec.tax_name,
            null,--kunkumar for forward porting to R12
            ln_login_id,
            for_dist_insertion_rec.match_status_flag , -- Bug 4863208
            'N',
            NULL,
            -- 'N',
            for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
            for_dist_insertion_rec.program_application_id,
            for_dist_insertion_rec.program_id,
            for_dist_insertion_rec.program_update_date,
            for_dist_insertion_rec.accts_pay_code_combination_id,
            v_invoice_distribution_id,
            decode(v_assets_tracking_flag, 'Y', NULL, 0), /* Modified for bug 8406404 by vumaasha */
            po_dist_id,
            rcv_tran_id,
            for_dist_insertion_rec.matched_uom_lookup_code
            ,ln_inv_line_num
            ,for_dist_insertion_rec.org_id -- Bug 4863208
            -- Bug 5401111. Added by Lakshmi Gopalsami
            ,decode(v_assets_tracking_flag,'N',
                    NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
            /* 5763527 */
            , ln_project_id
            , ln_task_id
            , lv_exp_type
            , ld_exp_item_date
            , ln_exp_organization_id
            , lv_project_accounting_context
            , lv_pa_addition_flag
            -- Bug 7249100. Added by Lakshmi Gopalsami
            ,lv_dist_class
            );
          --added by Eric for inclusive tax on 20-dec-2007,begin
          ------------------------------------------------------
          END IF; --( NVL(lv_ap_line_to_inst_flag,'N')='Y')
          ------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

        Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_AP_MATCH_INV_TAXES ');
        INSERT INTO JAI_AP_MATCH_INV_TAXES
        (
        tax_distribution_id,
        exchange_rate_variance,
        assets_tracking_flag,
        invoice_id,
        po_header_id,
        po_line_id,
        line_location_id,
        set_of_books_id,
        --org_id,
        exchange_rate,
        exchange_rate_type,
        exchange_date,
        currency_code,
        code_combination_id,
        last_update_login,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        acct_pay_code_combination_id,
        accounting_date,
        tax_id,
        tax_amount,
        base_amount,
        chart_of_accounts_id,
        distribution_line_number,
        --project_id,
        --task_id,
        po_distribution_id,  -- added  by bug#3038566
        parent_invoice_distribution_id,  -- added  by bug#3038566
        legal_entity_id -- added by rallamse bug#
        -- Added by Brathod, Bug# 4445989
        ,invoice_line_number
        ,INVOICE_DISTRIBUTION_ID
        ,PARENT_INVOICE_LINE_NUMBER
        ,RCV_TRANSACTION_ID
        ,LINE_TYPE_LOOKUP_CODE
        -- End Bug# 4445989
        ,recoverable_flag -- 5763527
        ,line_no          -- Bug 5553150, 5593895
        )
        VALUES
        (
        JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
       null,--kunkumar for forward porting to R12
        v_assets_tracking_flag, -- 'N', bug # 2851123
        inv_id,
        cur_items_rec.po_header_id,
        cur_items_rec.po_line_id,
        cur_items_rec.line_location_id,
        cur_items_rec.set_of_books_id,
        --cur_items_rec.org_id,
        cur_items_rec.rate,
        cur_items_rec.rate_type,
        cur_items_rec.rate_date,
        cur_items_rec.currency_code,
  /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
         * c_tax_rec.tax_account_id and v_dist_code_combination_id
   */
        v_dist_code_combination_id,
        cur_items_rec.last_update_login,
        cur_items_rec.creation_date,
        cur_items_rec.created_by,
        cur_items_rec.last_update_date,
        cur_items_rec.last_updated_by,
        apccid,
        cur_items_rec.invoice_date,
        tax_lines1_rec.tax_id,
        /*commented out by eric for inclusive tax
        round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
        */
        ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
        ROUND(tax_lines1_rec.tax_amount, ln_precision),
        caid,
        v_distribution_no,
        --p_project_id,
        --p_task_id ,
        po_dist_id, -- added  by bug#3038566
        for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
        get_ven_info_rec.legal_entity_id, -- added by rallamse bug#
        --, ln_inv_line_num , modified by eric for inclusvice tax
        --, v_invoice_distribution_id , modified by eric for inclusvice tax
        --added by eric for inclusvice tax on 20-dec-2007,begin
        --------------------------------------------------------------------------
        DECODE ( NVL(tax_lines1_rec.inc_tax_flag,'N')
               , 'N',ln_inv_line_num
               , 'Y',pn_invoice_line_number
               )
        , NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
        --------------------------------------------------------------------------
        --added by eric for inclusvice tax on 20-dec-2007,end
        , pn_invoice_line_number
       , rcv_tran_id
       , lv_misc
       , lv_modvat_flag -- 5763527
       , tax_lines1_rec.tax_line_no  -- Bug 5553150, 5593895

        );

        /*  Bug 46863208. Added by Lakshmi Gopalsami
         Commented the MRC call
        insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
       */
       /* commented out by for bug 8345512 on 13-Jul-2009
          cum_tax_amt := cum_tax_amt + round(v_tax_amount, ln_precision);
       */

        --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
        ------------------------------------------------------------------
        IF NVL(tax_lines1_rec.inc_tax_flag,'N') ='N'
        THEN
          cum_tax_amt := cum_tax_amt + round(v_tax_amount, ln_precision);  -- ROUND(v_tax_amount, 2),bug#2567799
        END IF;
        ------------------------------------------------------------------
        --Modified by Eric for bug 8345512 on 13-Jul-2009,end


        /* Obsoleted as part of R12 , Bug# 4445989
        Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_CMN_FA_INV_DIST_ALL ');

        INSERT INTO JAI_CMN_FA_INV_DIST_ALL
        (
        invoice_id,
        invoice_distribution_id,
        set_of_books_id,
        batch_id,
        po_distribution_id,
        rcv_transaction_id,
        dist_code_combination_id,
        accounting_date,
        assets_addition_flag,
        assets_tracking_flag,
        distribution_line_number,
        line_type_lookup_code,
        amount,
        description,
        match_status_flag,
        quantity_invoiced
        )
        VALUES
        (
        inv_id,
        ap_invoice_distributions_s.CURRVAL,
        for_dist_insertion_rec.set_of_books_id,
        v_batch_id,
        for_dist_insertion_rec.po_distribution_id,
        rcv_tran_id,
        for_dist_insertion_rec.dist_code_combination_id,
        for_dist_insertion_rec.accounting_date,
        for_dist_insertion_rec.assets_addition_flag,
        v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
        v_distribution_no,
        'MISCELLANEOUS',
        round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799,
        c_tax_rec.tax_name,
        NULL,
        NULL
        );
        */
        end loop ;--> for line in 1 to ln_lines_to_insert Brathod, 5763527

      END LOOP; --tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)


      v_update_payment_schedule:=update_payment_schedule(cum_tax_amt); -- bug#3218978


      UPDATE ap_invoices_all
      SET   invoice_amount       =  invoice_amount   + cum_tax_amt,
        approved_amount      =  approved_amount  + cum_tax_amt,
        pay_curr_invoice_amount =  pay_curr_invoice_amount + cum_tax_amt,
        amount_applicable_to_discount =  amount_applicable_to_discount + cum_tax_amt,
        payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
        -- bug#3624898
      WHERE  invoice_id = inv_id;

      -- start added for bug#3354932
      if for_org_id_rec.invoice_currency_code <> v_functional_currency then
        -- invoice currency is not the functional currency.
        update ap_invoices_all
        set    base_amount = invoice_amount  * exchange_rate
        where  invoice_id = inv_id;
      end if;
      -- end added for bug#3354932

     /* Bug 4863208. Added by Lakshmi Gopalsami
         Commented the MRC call
     update_mrc_data; -- bug#3332988
     */

    ELSIF p_receipt_code = 'PACKING_SLIP' THEN

      Fnd_File.put_line(Fnd_File.LOG, 'inside  p_receipt_code = PACKING_SLIP');

      /* Begin 5763527 */
      fnd_file.put_line(fnd_file.log, 'rcv_tran_id='||rcv_tran_id);
       open  c_get_excise_costing_flag (cp_rcv_transaction_id => rcv_tran_id
                                    ,cp_organization_id =>  r_rcv_transactions.organization_id    --Added by Bgowrava for Bug#7503308
                                      ,cp_shipment_header_id   =>  p_shipment_header_id                    --Added by Bgowrava for Bug#7503308
                    ,cp_txn_type        =>  'DELIVER'                             --Added by Bgowrava for Bug#7503308
                                      ,cp_attribute1      =>  'CENVAT_COSTED_FLAG');                --Added by Bgowrava for Bug#7503308
      fetch c_get_excise_costing_flag into lv_excise_costing_flag;
      close c_get_excise_costing_flag ;
      /* End 5763527 */


      FOR tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP

        -- Added By Brathod, Bug# 44459989
        /* v_distribution_no := v_distribution_no + 1 ; */
        -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527, moved increment to just before insert statment
        v_distribution_no  := 1;
        -- End Bug# 4445989

        r_service_regime_tax_type := null;

        -- Bug 5358788. Added by Lakshmi Gopalsami
        r_VAT_regime_tax_type := null;

        /* 5763527 */
        ln_project_id           := null;
        ln_task_id              := null;
        lv_exp_type             := null;
        ld_exp_item_date        := null;
        ln_exp_organization_id  := null;
        lv_project_accounting_context := null;
        lv_pa_addition_flag := null;


        OPEN  c_tax(tax_lines1_rec.tax_id);
        FETCH c_tax INTO c_tax_rec;
        CLOSE c_tax;
       -- added, kunkumar for bug 5593895
        ln_base_amount := null ;
        if tax_lines1_rec.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
          ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                            (
                              p_invoice_id          =>   inv_id ,
                              p_line_location_id    =>   null ,
                              p_transaction_id      =>   rcv_tran_id  ,
                              p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                              p_tax_id              =>   tax_lines1_rec.tax_id
                            ) ;
        end if ;
        -- ended,  kunkumar for bug 5593895


        /* Service Start */
        v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
        v_dist_code_combination_id := null;

        --initial the tax_type
        lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

        -- 5763527, Brathod
        -- Modified the if condition to consider partial recoverable lines previous logic was hadling only when it is 100
        if tax_lines1_rec.modvat_flag = jai_constants.YES
        and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
        then
          --recoverable tax
          lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007


         /*  recoverable tax */
          v_assets_tracking_flag := 'N';

          open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
          fetch c_regime_tax_type into r_service_regime_tax_type;
          close c_regime_tax_type;

    fnd_file.put_line(FND_FILE.LOG,
                   ' Service regime: '||r_service_regime_tax_type.tax_type);

     /* Bug 5358788. Added by Lakshmi Gopalsami
    * Fetched the details of VAT regime
    */

         OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
          FETCH  c_regime_tax_type INTO  r_vat_regime_tax_type;
         CLOSE  c_regime_tax_type;

         fnd_file.put_line(FND_FILE.LOG,
                   ' VAT regime: '||r_vat_regime_tax_type.tax_type);

          if r_service_regime_tax_type.tax_type is not null then
            /* Service type of tax */
            v_dist_code_combination_id := check_service_interim_account
                                          (
                                            lv_accrue_on_receipt_flag,
                                            lv_accounting_method_option,
                                            lv_is_item_an_expense,
                                            r_jai_regimes.regime_id,
                                            v_org_id,
                                            p_rematch,
                                            c_tax_rec.tax_type,
              po_dist_id  --Added by JMEENA for bug#6833506
                                          );

             fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
     || r_service_regime_tax_type.tax_type
           ||', ' || v_dist_code_combination_id);

            /* Bug 5358788. Added by Lakshmi Gopalsami
           * Commented p_rematch and added validation for
       * VAT regime.
       */
  /* following elsif block modified for bug 6595773*/
          ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
           --p_rematch = 'PO_MATCHING' then

            v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
      fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
     || r_vat_regime_tax_type.tax_type
           ||', ' || v_dist_code_combination_id);

          end if;
        else  /* 5763527 introduced for PROJETCS COSTING Impl */
          /* 5763527 */
          IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
          END if;
          --non recoverable
          lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007

        end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/

        /* Bug#4177452*/
        if v_dist_code_combination_id is null then
          v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
        end if;

        /* Service End */

        /* Bug#5763527 */
        Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.tax_type='||c_tax_rec.tax_type  ||',lv_excise_costing_flag='||lv_excise_costing_flag);
        if UPPER(c_tax_rec.tax_type) like  '%EXCISE%' then
          if lv_excise_costing_flag = 'Y' then
            IF  nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' -- Bug 6338371
            then
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
            end if;
            v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id;
          END if;
        end if;
        /* End# 5763527 */


        -- Start for bug#3752887
        v_tax_amount := tax_lines1_rec.tax_amount * v_apportn_factor_for_item_line;


        if for_org_id_rec.invoice_currency_code <> tax_lines1_rec.currency then
          v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
        end if;
        -- End for bug#3752887

        -- Start bug#4103473
        if nvl(v_tax_amount,-1) = -1 then --Modified by kunkumar for bug#5593895
          v_tax_amount := apportion_tax_4_price_cor_inv(v_tax_amount,  tax_lines1_rec.tax_id);
        END IF;
        v_tax_amount := nvl(v_tax_amount,-1); --Modified by kunkumar for bug#5593895
        -- End bug#4103473
        --
        -- Begin 5763527
        --
        ln_rec_tax_amt  := null;
        ln_nrec_tax_amt := null;
        ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -------------------------------------------------------------------------------------
        --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
        --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
        --PR(partially recoverable) tax is processed in another logic

        IF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N'
             OR ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                  AND p_project_id IS NULL
                )
           )
        THEN
          ln_lines_to_insert := 1;
        ELSIF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                AND p_project_id IS NOT NULL
                AND lv_tax_type = 'RE'
              )
        THEN
          ln_lines_to_insert := 2;
        END IF;--( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N' OR )
        -------------------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end


      Fnd_File.put_line(Fnd_File.LOG, 'tax_lines1_rec.modvat_flag ='||tax_lines1_rec.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

      if tax_lines1_rec.modvat_flag = jai_constants.YES
      and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
      and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
      then
        --
        -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
        -- and instead of one line, two lines needs to be inserted.
        -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
        --
        ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
        ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
        ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
    /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */

         lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008

      end if;
      fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                      ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                      ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                       );

      --
      --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
      --  non recoverable tax amount and the second line will be for a recoverable tax amount
      --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
      --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
      --

      for line in 1..ln_lines_to_insert
      loop

        --commented out by eric for inclusive tax
        /*
        if line = 1 then

          v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
          lv_modvat_flag := tax_lines1_rec.modvat_flag ;

        elsif line = 2 then

          v_tax_amount := ln_nrec_tax_amt;

          if for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES then
            v_assets_tracking_flag := jai_constants.YES;
          end if;

          lv_modvat_flag := jai_constants.NO ;

          --
          -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
          -- projects related columns so that PROJECTS can consider this line for Project Costing
          --
          IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371

            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
          END if;          -- For non recoverable line charge account should be same as of the parent line
          v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
        end if;
        */
      --ln_inv_line_num := ln_inv_line_num + 1;commented out by eric for inclusive tax
      --
      -- End 5763527
      --

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -------------------------------------------------------------------------------------
        IF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N')--exclusive case
        THEN
          IF line = 1 then

            v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
            lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
            lv_modvat_flag := tax_lines1_rec.modvat_flag ;

            lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
          ELSIF line = 2 then

            v_tax_amount             := ln_nrec_tax_amt;
            lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
            lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


            IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
              v_assets_tracking_flag := jai_constants.YES;
            END IF;

            lv_modvat_flag := jai_constants.NO ;

            --
            -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
            -- projects related columns so that PROJECTS can consider this line for Project Costing
            --
            IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
            END if;

            -- For non recoverable line charge account should be same as of the parent line
            v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

          END IF; --line = 1
        ELSIF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y')       --inclusive case
        THEN
          IF( lv_tax_type ='PR')
          THEN
            IF ( line = 1 )
            THEN
              --recoverable part
              v_tax_amount       := ln_rec_tax_amt ;
              lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
              lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
              lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

              --non recoverable part
            ELSIF ( line = 2 )
            THEN
              v_tax_amount       := ln_nrec_tax_amt  ;
              lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
              lv_modvat_flag     := jai_constants.NO ;
              lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

              --recoverable part without project infor
            ELSIF ( line = 3 )
            THEN
              v_tax_amount                  := ln_rec_tax_amt;
              lv_tax_line_amount            := NULL;

              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

              --recoverable part in negative amount with project infor
            ELSIF ( line = 4 )
            THEN
              v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
              lv_tax_line_amount            := NULL;
              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
            END IF; --line = 1
          ELSIF ( lv_tax_type = 'RE'
                  AND p_project_id IS NOT NULL
                )
          THEN
            --recoverable tax without project infor
            IF ( line = 1 )
            THEN
              v_tax_amount       :=  v_tax_amount  ;
              lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
              lv_modvat_flag     :=  tax_lines1_rec.modvat_flag ;
              lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            --recoverable tax in negative amount with project infor
            ELSIF ( line = 2 )
            THEN
              v_tax_amount       :=  v_tax_amount * -1;
              lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
              lv_modvat_flag     :=  tax_lines1_rec.modvat_flag  ;

              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            END IF;
          -- ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
          -- THEN
          ELSE -- eric removed the above criteria for bug 6888665 and 6888209
            Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
            --The case process the inclusive NR tax and inclusive RE tax not for project

            lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
            lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
            lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

          END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
        END IF; --(NVL(r_tax_lines_r ec.inc_tax_flag,'N') = 'N')
        -------------------------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end



      Fnd_File.put_line(Fnd_File.LOG,'Before inserting into ap_invoice_lines_all for line no :'
      || ln_inv_line_num  );


      --insert exclusive tax to the ap tables
      --or insert recoverable inclusive tax with project information the ap tables


      --1.Only exlusive taxes or inclusive recoverable taxes with project information
      --  are  inserted into Ap Lines and Dist Lines

      --2.All taxes need to be inserted into jai tax tables. Futher the
      --  partially recoverable tax need to be splitted into 2 lines

      --added by Eric for inclusive tax on 20-dec-2007,begin
      ------------------------------------------------------------------------
      IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
      THEN
        ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
      ---------------------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end

          INSERT INTO ap_invoice_lines_all
          (
            INVOICE_ID
          , LINE_NUMBER
          , LINE_TYPE_LOOKUP_CODE
          , DESCRIPTION
          , ORG_ID
          , MATCH_TYPE
    , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
          , ACCOUNTING_DATE
          , PERIOD_NAME
          , DEFERRED_ACCTG_FLAG
          , DEF_ACCTG_START_DATE
          , DEF_ACCTG_END_DATE
          , DEF_ACCTG_NUMBER_OF_PERIODS
          , DEF_ACCTG_PERIOD_TYPE
          , SET_OF_BOOKS_ID
          , AMOUNT
          , WFAPPROVAL_STATUS
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATE_LOGIN
          /* 5763527 */
          , project_id
          , task_id
          , expenditure_type
          , expenditure_item_date
          , expenditure_organization_id
          /* End 5763527 */
         ,po_distribution_id --Added for bug#6780154

          )
          VALUES
          (
            inv_id
          , ln_inv_line_num
          , lv_misc
          , c_tax_rec.tax_name
          , v_org_id
          , lv_match_type
    , v_dist_code_combination_id
          , rec_max_ap_lines_all.accounting_date
          , rec_max_ap_lines_all.period_name
          , rec_max_ap_lines_all.deferred_acctg_flag
          , rec_max_ap_lines_all.def_acctg_start_date
          , rec_max_ap_lines_all.def_acctg_end_date
          , rec_max_ap_lines_all.def_acctg_number_of_periods
          , rec_max_ap_lines_all.def_acctg_period_type
          , rec_max_ap_lines_all.set_of_books_id
          , ROUND(v_tax_amount,ln_precision)
          , rec_max_ap_lines_all.wfapproval_status -- Bug 4863208
          , sysdate
          , ln_user_id
          , ln_user_id
          , sysdate
          , ln_login_id
          /* 5763527 */
          , ln_project_id
          , ln_task_id
          , lv_exp_type
          , ld_exp_item_date
          , ln_exp_organization_id
          /* End 5763527 */
          ,po_dist_id --Added for bug#6780154
          );

          Fnd_File.put_line(Fnd_File.LOG,
          'Before inserting into ap_invoice_distributions_all for distribution line no : ' || v_distribution_no);

          -- Start bug#3332988
          open c_get_invoice_distribution;
          fetch c_get_invoice_distribution into v_invoice_distribution_id;
          close c_get_invoice_distribution;
          -- End bug#3332988

          fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

          INSERT INTO ap_invoice_distributions_all
          (
          accounting_date,
          accrual_posted_flag,
          assets_addition_flag,
          assets_tracking_flag,
          cash_posted_flag,
          distribution_line_number,
          dist_code_combination_id,
          invoice_id,
          last_updated_by,
          last_update_date,
          line_type_lookup_code,
          period_name,
          set_of_books_id,
          amount,
          base_amount,
          batch_id,
          created_by,
          creation_date,
          description,
          exChange_rate_variance,
          last_update_login,
          match_status_flag,
          posted_flag,
          rate_var_code_combination_id,
          reversal_flag,
          program_application_id,
          program_id,
          program_update_date,
          accts_pay_code_combination_id,
          invoice_distribution_id,
          quantity_invoiced,
          po_distribution_id ,
          rcv_transaction_id,
          matched_uom_lookup_code,
          invoice_line_number,
          org_id -- Bug 4863208
          ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
          /* 5763527 */
          , project_id
          , task_id
          , expenditure_type
          , expenditure_item_date
          , expenditure_organization_id
          , project_accounting_context
          , pa_addition_flag
          /* End 5763527 */
          -- Bug 7249100. Added by Lakshmi Gopalsami
          ,distribution_class
          )
          VALUES
          (
          rec_max_ap_lines_all.accounting_date,
          'N', --for_dist_insertion_rec.accrual_posted_flag,
          for_dist_insertion_rec.assets_addition_flag,
          v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
          'N',
          v_distribution_no,
    /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
           * for_dist_insertion_rec.dist_code_combination_id
     * and v_dist_code_combination_id
     */
          v_dist_code_combination_id,
          inv_id,
          ln_user_id,
          sysdate,
          lv_misc,
          rec_max_ap_lines_all.period_name,
          rec_max_ap_lines_all.set_of_books_id,
          round(v_tax_amount,ln_precision),
          ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision),
          v_batch_id,
          ln_user_id,
          sysdate,
          c_tax_rec.tax_name,
          null,--kunkumar for forward porting to R12
          ln_login_id,
          for_dist_insertion_rec.match_status_flag , -- Bug 4863208
          'N',
          NULL,
          -- 'N',
          for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
          for_dist_insertion_rec.program_application_id,
          for_dist_insertion_rec.program_id,
          for_dist_insertion_rec.program_update_date,
          for_dist_insertion_rec.accts_pay_code_combination_id,
          v_invoice_distribution_id,
          decode(v_assets_tracking_flag, 'Y', NULL, 0), /* Modified for bug 8406404 by vumaasha */
          po_dist_id ,
          rcv_tran_id,
          for_dist_insertion_rec.matched_uom_lookup_code,
          ln_inv_line_num,
          for_dist_insertion_rec.org_id    -- Bug 4863208
          -- Bug 5401111. Added by Lakshmi Gopalsami
          ,decode(v_assets_tracking_flag,'N',
                  NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
          /* 5763527 */
          , ln_project_id
          , ln_task_id
          , lv_exp_type
          , ld_exp_item_date
          , ln_exp_organization_id
          , lv_project_accounting_context
          , lv_pa_addition_flag
          /* End 5763527 */
          -- Bug 7249100. Added by Lakshmi Gopalsami
          , lv_dist_class
          );

        --added by Eric for inclusive tax on 20-dec-2007,begin
        ----------------------------------------------------------------
        END IF; --( NVL(lv_ap_line_to_inst_flag,'N')='Y')
        ----------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end


        Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_AP_MATCH_INV_TAXES ');

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -----------------------------------------------------------------
        IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
        THEN
        -----------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

          INSERT INTO JAI_AP_MATCH_INV_TAXES
          (
          tax_distribution_id,
          exchange_rate_variance,
          assets_tracking_flag,
          invoice_id,
          po_header_id,
          po_line_id,
          line_location_id,
          set_of_books_id,
          --org_id,
          exchange_rate,
          exchange_rate_type,
          exchange_date,
          currency_code,
          code_combination_id,
          last_update_login,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          acct_pay_code_combination_id,
          accounting_date,
          tax_id,
          tax_amount,
          base_amount,
          chart_of_accounts_id,
          distribution_line_number,
          --project_id,
          --task_id,
          po_distribution_id,  -- added  by bug#3038566
          parent_invoice_distribution_id,  -- added  by bug#3038566
          legal_entity_id -- added by rallamse bug#
          -- Added by Brathod, Bug# 4445989
          ,invoice_line_number
          ,INVOICE_DISTRIBUTION_ID
          ,PARENT_INVOICE_LINE_NUMBER
          ,RCV_TRANSACTION_ID
          ,LINE_TYPE_LOOKUP_CODE
          -- End Bug# 4445989
          /*5763527 */
          ,recoverable_flag
          /* End 5763527 */
          ,line_no  -- Bug 5553150, 5593895
          )
          VALUES
          (
          JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
          null,--kunkumar for forward porting to R12
          v_assets_tracking_flag, -- 'N', bug # 2851123
          inv_id,
          cur_items_rec.po_header_id,
          cur_items_rec.po_line_id,
          cur_items_rec.line_location_id,
          cur_items_rec.set_of_books_id,
          --cur_items_rec.org_id,
          cur_items_rec.rate,
          cur_items_rec.rate_type,
          cur_items_rec.rate_date,
          cur_items_rec.currency_code,
          /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
                * c_tax_rec.tax_account_id and v_dist_code_combination_id
          */
          v_dist_code_combination_id,
          cur_items_rec.last_update_login,
          cur_items_rec.creation_date,
          cur_items_rec.created_by,
          cur_items_rec.last_update_date,
          cur_items_rec.last_updated_by,
          apccid,
          cur_items_rec.invoice_date,
          tax_lines1_rec.tax_id,
          /*commented out by eric for inclusive tax
          round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
          */
          ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
          ROUND(tax_lines1_rec.tax_amount, ln_precision),
          caid,
          v_distribution_no,
          --p_project_id,
          --p_task_id,
          po_dist_id, -- added  by bug#3038566
          for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
          get_ven_info_rec.legal_entity_id,-- added by rallamse bug#
          --, ln_inv_line_num , commented out by eric for inclusvice tax
          --, v_invoice_distribution_id , commented out by eric for inclusvice tax
          --added by eric for inclusvice tax on 20-dec-2007,begin
          ---------------------------------------------------------------
          DECODE ( NVL(tax_lines1_rec.inc_tax_flag,'N')
                 , 'N',ln_inv_line_num
                 , 'Y',pn_invoice_line_number
                 )
          ,NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
          ---------------------------------------------------------------
          --added by eric for inclusvice tax on 20-dec-2007,end
          , pn_invoice_line_number
          , rcv_tran_id
          , lv_misc
          /* 5763527 */
          ,lv_modvat_flag
          /* End 5763527 */
          ,tax_lines1_rec.tax_line_no  -- --Bug 5553150, 5593895
          );
        --added by Eric for inclusive tax on 20-dec-2007,begin
        -----------------------------------------------------------------
        END IF;--  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
        -----------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

        /*  Bug 46863208. Added by Lakshmi Gopalsami
         Commented the MRC call
        insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
        */
        /*Commented out by Eric for bug 8345512 on 13-Jul-2009
          cum_tax_amt := cum_tax_amt + round(v_tax_amount,ln_precision);
        */

        --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
        ------------------------------------------------------------------
        IF NVL(tax_lines1_rec.inc_tax_flag,'N') ='N'
        THEN
          cum_tax_amt := cum_tax_amt + round(v_tax_amount,ln_precision); -- ROUND(v_tax_amount, 2) bug#2567799;
        END IF;
        ------------------------------------------------------------------
        --Modified by Eric for bug 8345512 on 13-Jul-2009,end

        /* Obsoleted as part of R12 , Bug# 4445989
        Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_CMN_FA_INV_DIST_ALL ');
        INSERT INTO JAI_CMN_FA_INV_DIST_ALL
        (
        invoice_id,
        invoice_distribution_id,
        set_of_books_id,
        batch_id,
        po_distribution_id,
        rcv_transaction_id,
        dist_code_combination_id,
        accounting_date,
        assets_addition_flag,
        assets_tracking_flag,
        distribution_line_number,
        line_type_lookup_code,
        amount,
        description,
        match_status_flag,
        quantity_invoiced
        )
        VALUES
        (
        inv_id,
        ap_invoice_distributions_s.CURRVAL,
        for_dist_insertion_rec.set_of_books_id,
        v_batch_id,
        for_dist_insertion_rec.po_distribution_id,
        rcv_tran_id,
        for_dist_insertion_rec.dist_code_combination_id,
        for_dist_insertion_rec.accounting_date,
        for_dist_insertion_rec.assets_addition_flag,
        v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
        v_distribution_no,
        'MISCELLANEOUS',
        round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
        c_tax_rec.tax_name,
        NULL,
        NULL
        );*/

        end loop; --> for line in 1..ln_lines_to_insert; -- Brathod, 5763527
      END LOOP; --tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP



      v_update_payment_schedule:=update_payment_schedule(cum_tax_amt); -- bug#3218978

      UPDATE ap_invoices_all
      SET     invoice_amount       =  invoice_amount   + cum_tax_amt,
          approved_amount      =  approved_amount  + cum_tax_amt,
          pay_curr_invoice_amount =  pay_curr_invoice_amount + cum_tax_amt,
          amount_applicable_to_discount =  amount_applicable_to_discount + cum_tax_amt,
          payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
          -- bug#3624898
      WHERE  invoice_id = inv_id;


      -- start added for bug#3354932
      if for_org_id_rec.invoice_currency_code <> v_functional_currency then
        -- invoice currency is not the functional currency.
        update ap_invoices_all
        set    base_amount = invoice_amount  * exchange_rate
        where  invoice_id = inv_id;
      end if;
      -- end added for bug#3354932

     /* Bug 4863208. Added by Lakshmi Gopalsami
         Commented the MRC call
      update_mrc_data; -- bug#3332988
      */


    END IF;    --  p_receipt_code = 'PACKING_SLIP' THEN


  ELSIF p_rematch = 'RCV_MATCHING' THEN


    Fnd_File.put_line(Fnd_File.LOG, 'inside  p_receipt_code = RCV_MATCHING');

    /* Begin 5763527 */
    fnd_file.put_line(fnd_file.log, 'rcv_tran_id='||rcv_tran_id);
    open  c_get_excise_costing_flag (cp_rcv_transaction_id => rcv_tran_id
                                   ,cp_organization_id =>  r_rcv_transactions.organization_id     --Added by Bgowrava for Bug#7503308
                                     ,cp_shipment_header_id     =>  p_shipment_header_id            --Added by Bgowrava for Bug#7503308
                   ,cp_txn_type        =>  'DELIVER'                              --Added by Bgowrava for Bug#7503308
                                      ,cp_attribute1      =>  'CENVAT_COSTED_FLAG');                --Added by Bgowrava for Bug#7503308
    fetch c_get_excise_costing_flag into lv_excise_costing_flag;
    close c_get_excise_costing_flag ;
    /* End 5763527 */


    OPEN  for_org_id(inv_id);
    FETCH for_org_id INTO for_org_id_rec;
    CLOSE for_org_id;

    -- Added by Jason Liu for retroactive price on 2008/01/09
    -----------------------------------------------------------
    OPEN get_source_csr;
    FETCH get_source_csr INTO lv_source;
    CLOSE get_source_csr;
    -----------------------------------------------------------
    -- Modified by Jason Liu for retroactive price on 2008/01/09
    -- Added the parameter lv_source
    FOR r_tax_lines_rec IN r_tax_lines_cur(rcv_tran_id,for_org_id_rec.vendor_id,lv_source)  LOOP
      Fnd_File.put_line(Fnd_File.LOG, ' ');
        /* 5763527 */
        ln_project_id           := null;
        ln_task_id              := null;
        lv_exp_type             := null;
        ld_exp_item_date        := null;
        ln_exp_organization_id  := null;
        lv_project_accounting_context := null;
        lv_pa_addition_flag := null;


        -- Added by Brathod, For Bug# 4445989
        /* v_distribution_no:= v_distribution_no+1; */
        v_distribution_no := 1;
        -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527, moved the increment to just before insert statement
        -- End Bug# 4445989

        -- start added by Aparajita for bug # 2775043 on 30/01/2003
        v_tax_variance_inv_cur := null;
        v_tax_variance_fun_cur := null;
        v_price_var_accnt := null;
        r_service_regime_tax_type := null;
        -- end added by Aparajita for bug # 2775043 on 30/01/2003

        -- Bug 5358788. Added by Lakshmi Gopalsami
        r_VAT_regime_tax_type := null;

        BEGIN

        OPEN c_tax(r_tax_lines_rec.tax_id);
        FETCH c_tax INTO c_tax_rec;
        CLOSE c_tax;
             -- added, kunkumar for bug#5593895
        ln_base_amount := null ;
        if r_tax_lines_rec.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
          ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                            (
                              p_invoice_id          =>   inv_id ,
                              p_line_location_id    =>   null ,
                              p_transaction_id      =>   rcv_tran_id  ,
                              p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                              p_tax_id              =>   r_tax_lines_rec.tax_id
                            ) ;
        end if ;
         -- added, kunkumar for bug#5593895
        /* Service Start */
        v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
        v_dist_code_combination_id := null;
        --initial the tax_type
        lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

        Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.mod_cr_percentage = '||c_tax_rec.mod_cr_percentage);
        -- 5763527, Brathod
        -- Modified the if condition to consider partial recoverable lines previous logic was hadling only when it is 100
        if r_tax_lines_rec.modvat_flag = jai_constants.YES
        and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
        then
         /*  recoverable tax */
          lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007
          v_assets_tracking_flag := 'N';

          Fnd_File.put_line(Fnd_File.LOG, 'lv_tax_type = '||lv_tax_type);

          open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
          fetch c_regime_tax_type into r_service_regime_tax_type;
          close c_regime_tax_type;

          fnd_file.put_line(FND_FILE.LOG,
                     ' Service regime: '||r_service_regime_tax_type.tax_type);

      /* Bug 5358788. Added by Lakshmi Gopalsami
     * Fetched the details of VAT regime
     */

          OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
           FETCH  c_regime_tax_type INTO  r_vat_regime_tax_type;
          CLOSE  c_regime_tax_type;

          fnd_file.put_line(FND_FILE.LOG,
                     ' VAT regime: '||r_vat_regime_tax_type.tax_type);

          if r_service_regime_tax_type.tax_type is not null then
            /* Service type of tax */
            v_dist_code_combination_id := check_service_interim_account
                                          (
                                            lv_accrue_on_receipt_flag,
                                            lv_accounting_method_option,
                                            lv_is_item_an_expense,
                                            r_jai_regimes.regime_id,
                                            v_org_id,
                                            p_rematch,
                                            c_tax_rec.tax_type,
              po_dist_id  --Added by JMEENA for bug#6833506
                                          );
               fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_service_regime_tax_type.tax_type
             ||', ' || v_dist_code_combination_id);

              /* Bug 5358788. Added by Lakshmi Gopalsami
             * Commented p_rematch and added validation for
         * VAT regime.
         */
    /*following elsif block modified for bug 6595773*/
            ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
             --p_rematch = 'RCV_MATCHING' then

              v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
        fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_vat_regime_tax_type.tax_type
             ||', ' || v_dist_code_combination_id);

          end if;

        else  /* 5763527 introduced for PROJETCS COSTING Impl */
          /* 5763527 */
          IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' -- Bug 6338371
          then
            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
          END if;

          --non recoverable
          lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
          Fnd_File.put_line(Fnd_File.LOG, 'lv_tax_type = '||lv_tax_type);
          Fnd_File.put_line(Fnd_File.LOG, 'lv_accrue_on_receipt_flag = '||lv_accrue_on_receipt_flag);
        end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/


        /* Bug#4177452*/
        if v_dist_code_combination_id is null then
          v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
        end if;

        /*following line added for bug 6595773*/
        Fnd_File.put_line(Fnd_File.LOG, 'v_dist_code_combination_id : ' || v_dist_code_combination_id ) ;
        /* Service End */

        -- Start for bug#3752887
        v_tax_amount := r_tax_lines_rec.tax_amount * v_apportn_factor_for_item_line;
        Fnd_File.put_line(Fnd_File.LOG, 'v_apportn_factor_for_item_line = '||v_apportn_factor_for_item_line);
        Fnd_File.put_line(Fnd_File.LOG, 'v_tax_amount = '||v_tax_amount);

        if for_org_id_rec.invoice_currency_code <> r_tax_lines_rec.currency then
          v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
        end if;

        /* Bug#5763527 */
        Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.tax_type='||c_tax_rec.tax_type  ||',lv_excise_costing_flag='||lv_excise_costing_flag);
        if UPPER(c_tax_rec.tax_type) like  '%EXCISE%' then

          if lv_excise_costing_flag = 'Y'  THEN
            IF  nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' -- Bug 6338371
            then
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
      END if;
            v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id;
          end if;
        end if;
        /* End# 5763527 */

        if nvl(for_dist_insertion_rec.invoice_price_variance, -1) <>-1 --Modified by kunkumar for bug#5593895
           and
           nvl(for_dist_insertion_rec.amount, -1) <> -1 then  --Modified by kunkumar for bug#5593895

          v_tax_variance_inv_cur :=
          v_tax_amount *
          (for_dist_insertion_rec.invoice_price_variance / for_dist_insertion_rec.amount);

          if nvl(v_tax_variance_inv_cur, -1) <> -1 then --Modified by kunkumar for bug#5593895
            v_tax_variance_fun_cur := v_tax_variance_inv_cur * nvl(for_org_id_rec.exchange_rate, 1);
          end if;

          v_price_var_accnt := for_dist_insertion_rec.price_var_code_combination_id;

        end if;
        -- End for bug#3752887

        -- Start bug#4103473
        if nvl(v_tax_amount,-1) = -1 then --Modified by kunkumar for bug#5593895
          v_tax_amount := apportion_tax_4_price_cor_inv(v_tax_amount,  r_tax_lines_rec.tax_id);
        END IF;
        v_tax_amount := nvl(v_tax_amount, -1); --Modified by kunkumar for bug#5593895
        -- End bug#4103473

        --
        -- Begin 5763527
        --
        ln_rec_tax_amt  := null;
        ln_nrec_tax_amt := null;
        ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -------------------------------------------------------------------------------------
        --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
        --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
        --PR(partially recoverable) tax is processed in another logic

        IF ( NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'N'
             OR ( NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'Y'
                  AND p_project_id IS NULL
                )
           )
        THEN
          ln_lines_to_insert := 1;
        ELSIF ( NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'Y'
                AND p_project_id IS NOT NULL
                AND lv_tax_type = 'RE'
              )
        THEN
          ln_lines_to_insert := 2;
        END IF;--( NVL(i.inc_tax_flag,'N') = 'N' OR ( NVL(i.inc_tax_flag,'N'))
      -------------------------------------------------------------------------------------
      --added by Eric for inclusive tax on 20-dec-2007,end




        Fnd_File.put_line(Fnd_File.LOG, 'r_tax_lines_rec.modvat_flag ='||r_tax_lines_rec.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

        if r_tax_lines_rec.modvat_flag = jai_constants.YES
        and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
        and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
        then
          --
          -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
          -- and instead of one line, two lines needs to be inserted.
          -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
          --

          --ln_lines_to_insert := 2;--commented eric for inclusive tax on Jan 4,2008
          ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
          ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
          ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
      /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */

          lv_tax_type := 'PR';  --added by eric for inclusive tax on Jan 4,2008
        end if;
        fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                        ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                        ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                         );

        --
        --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
        --  non recoverable tax amount and the second line will be for a recoverable tax amount
        --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
        --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
        --

      Fnd_File.put_line(Fnd_File.LOG, 'ln_lines_to_insert ='|| ln_lines_to_insert);
      for line in 1..ln_lines_to_insert
      loop
        --deleted by eric for inclusive tax on 04-Jan-2008,begin
        ---------------------------------------------------------------------------
        /*
        if line = 1 then

          v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
          lv_modvat_flag := r_tax_lines_rec.modvat_flag ;

        elsif line = 2 then

          v_tax_amount := ln_nrec_tax_amt;

          if for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES then
            v_assets_tracking_flag := jai_constants.YES;
          end if;

          lv_modvat_flag := jai_constants.NO ;

          --
          -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
          -- projects related columns so that PROJECTS can consider this line for Project Costing
          --
          IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' THEN -- Bug 6338371
            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
          END if;          -- For non recoverable line charge account should be same as of the parent line
          v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

        end if;

        ln_inv_line_num := ln_inv_line_num + 1;
          --
          -- End 5763527
          --

        */
        ---------------------------------------------------------------------------
        --deleted by eric for inclusive tax on 04-Jan-2008,end

        --added by Eric for inclusive tax on 20-dec-2007,begin
        ---------------------------------------------------------------------------
        Fnd_File.put_line(Fnd_File.LOG, 'line = '|| line);
        Fnd_File.put_line(Fnd_File.LOG, 'inc_tax_flag = '|| NVL(r_tax_lines_rec.inc_tax_flag,'N'));
        Fnd_File.put_line(Fnd_File.LOG, 'lv_tax_type = '|| lv_tax_type);
        Fnd_File.put_line(Fnd_File.LOG, 'v_tax_amount = '|| v_tax_amount);
        Fnd_File.put_line(Fnd_File.LOG, 'ln_nrec_tax_amt = '|| ln_nrec_tax_amt);
        Fnd_File.put_line(Fnd_File.LOG, 'ln_rec_tax_amt  = '|| ln_rec_tax_amt );

        IF (NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'N')--exclusive case
        THEN
          Fnd_File.put_line(Fnd_File.LOG, 'Exclusive Branch');
          IF line = 1 then

            v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
            lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
            lv_modvat_flag := r_tax_lines_rec.modvat_flag ;

            lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
          ELSIF line = 2 then

            v_tax_amount             := ln_nrec_tax_amt;
            lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
            lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


            IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
              v_assets_tracking_flag := jai_constants.YES;
            END IF;

            lv_modvat_flag := jai_constants.NO ;

            --
            -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
            -- projects related columns so that PROJECTS can consider this line for Project Costing
            --
            IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
            END if;

            -- For non recoverable line charge account should be same as of the parent line
            v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

          END IF; --line = 1
        ELSIF (NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'Y')       --inclusive case
        THEN
          Fnd_File.put_line(Fnd_File.LOG, 'Inclusive Branch');
          IF( lv_tax_type ='PR')
          THEN
            Fnd_File.put_line(Fnd_File.LOG, 'PR Tax');
            IF ( line = 1 )
            THEN
              --recoverable part
              v_tax_amount       := ln_rec_tax_amt ;
              lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
              lv_modvat_flag     := r_tax_lines_rec.modvat_flag  ;
              lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

            ELSIF ( line = 2 )
            THEN
              --non recoverable part
              v_tax_amount       := ln_nrec_tax_amt  ;
              lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
              lv_modvat_flag     := jai_constants.NO ;
              lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

              --recoverable part without project infor
            ELSIF ( line = 3 )
            THEN
              v_tax_amount                  := ln_rec_tax_amt;
              lv_tax_line_amount            := NULL;

              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

              --recoverable part in negative amount with project infor
            ELSIF ( line = 4 )
            THEN
              v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
              lv_tax_line_amount            := NULL;
              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

              --Project information
              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

              -- For inclusive recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
            END IF; --line = 1
          ELSIF ( lv_tax_type = 'RE'
                  AND p_project_id IS NOT NULL
                )
          THEN
            Fnd_File.put_line(Fnd_File.LOG, 'RE Tax ,p_project_id IS NOT NULL');
            --recoverable tax without project infor
            IF ( line = 1 )
            THEN
              v_tax_amount       :=  v_tax_amount  ;
              lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
              lv_modvat_flag     :=  r_tax_lines_rec.modvat_flag ;
              lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

              ln_project_id                 := NULL;
              ln_task_id                    := NULL;
              lv_exp_type                   := NULL;
              ld_exp_item_date              := NULL;
              ln_exp_organization_id        := NULL;
              lv_project_accounting_context := NULL;
              lv_pa_addition_flag           := NULL;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            --recoverable tax in negative amount with project infor
            ELSIF ( line = 2 )
            THEN
              v_tax_amount       :=  v_tax_amount * -1;
              lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
              lv_modvat_flag     :=  r_tax_lines_rec.modvat_flag  ;

              ln_project_id                 := p_project_id;
              ln_task_id                    := p_task_id;
              lv_exp_type                   := p_expenditure_type;
              ld_exp_item_date              := p_expenditure_item_date;
              ln_exp_organization_id        := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
            END IF;
          --  ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
          --  THEN
          ELSE -- eric removed the above criteria for bug 6888665 and 6888209
            Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
            --The case process the inclusive NR tax and inclusive RE tax not for project

            lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
            lv_modvat_flag     := r_tax_lines_rec.modvat_flag  ;
            lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
            lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

          END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
        END IF; --(NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'N')
        -------------------------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end


        --insert exclusive tax to the ap tables
        --or insert recoverable inclusive tax with project information the ap tables

        Fnd_File.put_line(Fnd_File.LOG,'r_tax_lines_rec.tax_id :'|| r_tax_lines_rec.tax_id );
        Fnd_File.put_line(Fnd_File.LOG,'line  :'|| line );
        Fnd_File.put_line(Fnd_File.LOG,'lv_ap_line_to_inst_flag   :'|| lv_ap_line_to_inst_flag );
        Fnd_File.put_line(Fnd_File.LOG,'lv_tax_line_to_inst_flag  :'|| lv_tax_line_to_inst_flag );

        --1.Only exlusive taxes or inclusive recoverable taxes with project information
        --  are  inserted into Ap Lines and Dist Lines

        --2.All taxes need to be inserted into jai tax tables. Futher the
        --  partially recoverable tax need to be splitted into 2 lines

        --added by Eric for inclusive tax on 20-dec-2007,begin
        ------------------------------------------------------------------------
        IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
        THEN
          ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
        ---------------------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

          Fnd_File.put_line(Fnd_File.LOG,'Before inserting into ap_invoice_lines_all for line no :'|| ln_inv_line_num );

          INSERT INTO ap_invoice_lines_all
          (
            INVOICE_ID
          , LINE_NUMBER
          , LINE_TYPE_LOOKUP_CODE
          , DESCRIPTION
          , ORG_ID
          , MATCH_TYPE
    , DEFAULT_DIST_CCID ----Changes by nprashar for bug #6995437
          , ACCOUNTING_DATE
          , PERIOD_NAME
          , DEFERRED_ACCTG_FLAG
          , DEF_ACCTG_START_DATE
          , DEF_ACCTG_END_DATE
          , DEF_ACCTG_NUMBER_OF_PERIODS
          , DEF_ACCTG_PERIOD_TYPE
          , SET_OF_BOOKS_ID
          , AMOUNT
          , WFAPPROVAL_STATUS
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATE_LOGIN
          /* 5763527 */
          , project_id
          , task_id
          , expenditure_type
          , expenditure_item_date
          , expenditure_organization_id
          ,po_distribution_id --Added for bug#6780154
          )
          VALUES
          (
              inv_id
          , ln_inv_line_num
          , lv_misc
          , c_tax_rec.tax_name
          , v_org_id
          , lv_match_type
    , v_dist_code_combination_id
          , rec_max_ap_lines_all.accounting_date
          , rec_max_ap_lines_all.period_name
          , rec_max_ap_lines_all.deferred_acctg_flag
          , rec_max_ap_lines_all.def_acctg_start_date
          , rec_max_ap_lines_all.def_acctg_end_date
          , rec_max_ap_lines_all.def_acctg_number_of_periods
          , rec_max_ap_lines_all.def_acctg_period_type
          , rec_max_ap_lines_all.set_of_books_id
          , ROUND(v_tax_amount,ln_precision)
          , rec_max_ap_lines_all.wfapproval_status  -- Bug 4863208
          , sysdate
          , ln_user_id
          , ln_user_id
          , sysdate
          , ln_login_id
          /* 5763527 */
          , ln_project_id
          , ln_task_id
          , lv_exp_type
          , ld_exp_item_date
          , ln_exp_organization_id
          /* End 5763527 */
          ,po_dist_id --Added for bug#6780154
           );


          Fnd_File.put_line(Fnd_File.LOG,
          'Before inserting into ap_invoice_distributions_all for distribution line no :' || v_distribution_no);

          -- Start bug#3332988
          open c_get_invoice_distribution;
          fetch c_get_invoice_distribution into v_invoice_distribution_id;
          close c_get_invoice_distribution;
          -- End bug#3332988

          fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

          INSERT INTO ap_invoice_distributions_all
          (
          accounting_date,
          accrual_posted_flag,
          assets_addition_flag,
          assets_tracking_flag,
          cash_posted_flag,
          distribution_line_number,
          dist_code_combination_id,
          invoice_id,
          last_updated_by,
          last_update_date,
          line_type_lookup_code,
          period_name,
          set_of_books_id,
          amount,
          base_amount,
          batch_id,
          created_by,
          creation_date,
          description,
          exchange_rate_variance,
          last_update_login,
          match_status_flag,
          posted_flag,
          rate_var_code_combination_id,
          reversal_flag,
          program_application_id,
          program_id,
          program_update_date,
          accts_pay_code_combination_id,
          invoice_distribution_id,
          quantity_invoiced,
          po_distribution_id ,
          rcv_transaction_id,
          price_var_code_combination_id,
          invoice_price_variance,
          base_invoice_price_variance,
          matched_uom_lookup_code,
          INVOICE_LINE_NUMBER,
          org_id    -- Bug 4863208
          ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
            /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
            , project_accounting_context
            , pa_addition_flag
            -- Bug 7249100. Added by Lakshmi Gopalsami
            ,distribution_class
      )

          VALUES
          (
          for_dist_insertion_rec.accounting_date,
          'N', --for_dist_insertion_rec.accrual_posted_flag,
          for_dist_insertion_rec.assets_addition_flag,
          v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
          'N',
          v_distribution_no,
          /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
           * for_dist_insertion_rec.dist_code_combination_id
           * and v_dist_code_combination_id
           */
          v_dist_code_combination_id,
          inv_id,
          for_dist_insertion_rec.last_updated_by,
          for_dist_insertion_rec.last_update_date,
          lv_misc,
          for_dist_insertion_rec.period_name,
          for_dist_insertion_rec.set_of_books_id,
          ROUND(v_tax_amount, ln_precision),
          ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision),
          v_batch_id,
          for_dist_insertion_rec.created_by,
          for_dist_insertion_rec.creation_date,
          c_tax_rec.tax_name,
          null,--kunkumar for forwad porting to R12
          for_dist_insertion_rec.last_update_login,
          for_dist_insertion_rec.match_status_flag , -- Bug 4863208
          'N',
          NULL,
          --'N',
          for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
          for_dist_insertion_rec.program_application_id,
          for_dist_insertion_rec.program_id,
          for_dist_insertion_rec.program_update_date,
          for_dist_insertion_rec.accts_pay_code_combination_id,
          v_invoice_distribution_id,
          decode(v_assets_tracking_flag, 'Y', NULL, 0),/* Modified for bug 8406404 by vumaasha */
          po_dist_id ,
          rcv_tran_id,
          v_price_var_accnt,
          v_tax_variance_inv_cur,
          v_tax_variance_fun_cur,
          for_dist_insertion_rec.matched_uom_lookup_code,
          ln_inv_line_num,
          for_dist_insertion_rec.org_id   -- bug 4863208
          -- Bug 5401111. Added by Lakshmi Gopalsami
          ,decode(v_assets_tracking_flag,'N',
                  NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
            /* 5763527 */
            , ln_project_id
            , ln_task_id
            , lv_exp_type
            , ld_exp_item_date
            , ln_exp_organization_id
            , lv_project_accounting_context
            , lv_pa_addition_flag
            -- Bug 7249100. Added by Lakshmi Gopalsami
            , lv_dist_class

          );
        --added by Eric for inclusive tax on 20-dec-2007,begin
        ---------------------------------------------------------------
        END IF;  --( NVL(lv_ap_line_to_inst_flag,'N')='Y')
        ---------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

        --added by Eric for inclusive tax on 20-dec-2007,begin
        -----------------------------------------------------------------
        IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
        THEN
        -----------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

          Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_AP_MATCH_INV_TAXES ');
          INSERT INTO JAI_AP_MATCH_INV_TAXES
          (
          tax_distribution_id,
          --shipment_line_id,
          exchange_rate_variance,
          assets_tracking_flag,
          invoice_id,
          po_header_id,
          po_line_id,
          line_location_id,
          set_of_books_id,
          --org_id,
          exchange_rate,
          exchange_rate_type,
          exchange_date,
          currency_code,
          code_combination_id,
          last_update_login,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          acct_pay_code_combination_id,
          accounting_date,
          tax_id,
          tax_amount,
          base_amount,
          chart_of_accounts_id,
          distribution_line_number,
          --project_id,
          --task_id,
          po_distribution_id,  -- added  by bug#3038566
          parent_invoice_distribution_id,  -- added  by bug#3038566
          legal_entity_id -- added by rallamse bug#
          -- Added by Brathod, Bug# 4445989
          ,invoice_line_number
          ,INVOICE_DISTRIBUTION_ID
          ,PARENT_INVOICE_LINE_NUMBER
          ,RCV_TRANSACTION_ID
          ,LINE_TYPE_LOOKUP_CODE
          -- End Bug# 4445989
          /* 5763527 */
          , recoverable_flag
          /* End 5763527 */
          ,line_no    -- Bug 5553150, 5593895
          )

          VALUES
          (
          JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
          null,--kunkumar for forward porting to R12
          v_assets_tracking_flag, -- 'N', bug # 2851123
          inv_id,
          cur_items_rec.po_header_id, /* All references to r_cur_items_rec have been replaced by cur_items_rec */
          cur_items_rec.po_line_id,
          cur_items_rec.line_location_id,
          cur_items_rec.set_of_books_id,
          --cur_items_rec.org_id,
          cur_items_rec.rate,
          cur_items_rec.rate_type,
          cur_items_rec.rate_date,
          cur_items_rec.currency_code,
          /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
           * c_tax_rec.tax_account_id and v_dist_code_combination_id
           */
          v_dist_code_combination_id,
          cur_items_rec.last_update_login,
          cur_items_rec.creation_date,
          cur_items_rec.created_by,
          cur_items_rec.last_update_date,
          cur_items_rec.last_updated_by,
          apccid,
          cur_items_rec.invoice_date,
          r_tax_lines_rec.tax_id,
          /*commented out by eric for inclusive tax
          round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
          */
          ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
          ROUND(r_tax_lines_rec.tax_amount, ln_precision),
          caid,
          v_distribution_no,
          --p_project_id,
          --p_task_id,
          po_dist_id, -- added  by bug#3038566
          for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
          get_ven_info_rec.legal_entity_id -- added by rallamse bug#
          --, ln_inv_line_num , commented out by eric for inclusvice tax
          --, v_invoice_distribution_id
          --added by Eric for inclusive tax on 20-dec-2007,begin
          --------------------------------------------------------------
          , DECODE ( NVL(r_tax_lines_rec.inc_tax_flag,'N')
                   , 'N',ln_inv_line_num
                   , 'Y',pn_invoice_line_number
                   )
          , NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
          --------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end
          , pn_invoice_line_number
          , rcv_tran_id
          , lv_misc
          /* 5763527 */
          , lv_modvat_flag
          /* End 5763527 */
          ,r_tax_lines_rec.tax_line_no  -- Bug 5553150, 5593895
          );
        --added by Eric for inclusive tax on 20-dec-2007,begin
        -----------------------------------------------------------------
        END IF;--(NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
        -----------------------------------------------------------------
        --added by Eric for inclusive tax on 20-dec-2007,end

        /*  Bug 46863208. Added by Lakshmi Gopalsami
           Commented the MRC call
        insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
        */

        /* Commented out  by Eric for bug 8345512 on 13-Jul-2009
            cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
        */


        --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
        ------------------------------------------------------------------
        IF NVL(r_tax_lines_rec.inc_tax_flag,'N') ='N'
        THEN
          cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
        END IF;
        ------------------------------------------------------------------
        --Modified by Eric for bug 8345512 on 13-Jul-2009,end

        /* Obsoleted as part of R12 , Bug# 4445989
        Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_CMN_FA_INV_DIST_ALL ');
        INSERT INTO JAI_CMN_FA_INV_DIST_ALL
        (
        invoice_id,
        invoice_distribution_id,
        set_of_books_id,
        batch_id,
        po_distribution_id,
        rcv_transaction_id,
        dist_code_combination_id,
        accounting_date,
        assets_addition_flag,
        assets_tracking_flag,
        distribution_line_number,
        line_type_lookup_code,
        amount,
        description,
        match_status_flag,
        quantity_invoiced
        )
        VALUES
        (
        inv_id,
        ap_invoice_distributions_s.CURRVAL,
        for_dist_insertion_rec.set_of_books_id,
        v_batch_id,
        for_dist_insertion_rec.po_distribution_id,
        rcv_tran_id,
        for_dist_insertion_rec.dist_code_combination_id,
        for_dist_insertion_rec.accounting_date,
        for_dist_insertion_rec.assets_addition_flag,
        v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug # 2851123
        v_distribution_no,
        'MISCELLANEOUS',
        ROUND(v_tax_amount, ln_precision),
        c_tax_rec.tax_name,
        NULL,
        NULL
        );*/

        /* end modification for ap to fa modavatable taxes issue. on 19-mar-01 by subbu and pavan*/
        -----------------------------------------------------------------------------------------------

          end loop ;  --> for line in 1 to ln_lines_to_insert Brathod, 5763527
        END;
    END LOOP; -- r_tax_lines_rec IN r_tax_lines_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP


  END IF; -- p_rematch = 'RCV_MATCHING'


    Fnd_File.put_line(Fnd_File.LOG, 'SUCCESSFUL END PROCEDURE - jai_ap_match_tax_pkg.process_online');

EXCEPTION
    WHEN OTHERS THEN
      ERRBUF := SQLERRM;
      RETCODE := 2;
      Fnd_File.put_line(Fnd_File.LOG, 'EXCEPTION END PROCEDURE - jai_ap_match_tax_pkg.process_online');
      Fnd_File.put_line(Fnd_File.LOG, 'Error : ' || ERRBUF);
END process_online;

PROCEDURE process_batch_record (
  err_mesg OUT NOCOPY VARCHAR2,
  inv_id                          IN      NUMBER,
  pn_invoice_line_number          IN      NUMBER,  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  po_dist_id                      IN      NUMBER,
  qty_inv                         IN      NUMBER,
  p_shipment_header_id            IN      NUMBER,
  p_packing_slip_num              IN      VARCHAR2,
  p_receipt_code                          VARCHAR2,
  p_rematch                               VARCHAR2,
  rcv_tran_id                     IN      NUMBER,
  v_dist_amount                   IN      NUMBER,
  --p_project_id                            NUMBER,
  --p_task_id                               NUMBER,
  --p_expenditure_type                      VARCHAR2,
  --p_expenditure_organization_id           NUMBER,
  --p_expenditure_item_date                 DATE,
  v_org_id                        IN      NUMBER
  /* 5763527, Introduced parameters for Project Implementation */
  ,p_project_id                            NUMBER
  ,p_task_id                               NUMBER
  ,p_expenditure_type                      VARCHAR2
  ,p_expenditure_organization_id           NUMBER
  ,p_expenditure_item_date                 DATE
  /* End 5763527 */

)
IS

CURSOR get_ven_info(v_invoice_id NUMBER) IS
    SELECT vendor_id, vendor_site_id, org_id, cancelled_date -- cancelled date added by bug#3206083
         ,set_of_books_id -- added for bug#3354932
         ,legal_entity_id -- added rallamse for bug#
     ,invoice_num -- added by pramasub FP
    FROM   ap_invoices_all
    WHERE  invoice_id = v_invoice_id;

  CURSOR c_functional_currency(p_sob NUMBER) IS -- cursor added for bug#3354932
    SELECT currency_code
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = p_sob;

   CURSOR checking_for_packing_slip(ven_id NUMBER, ven_site_id NUMBER, v_org_id NUMBER) IS
    SELECT pay_on_code, pay_on_receipt_summary_code
    FROM   po_vendor_sites_all
    WHERE  vendor_id = ven_id
    AND    vendor_site_id = ven_site_id
    AND    NVL(org_id, 0) = NVL(v_org_id, 0);

   -- Modified by Brathod for BUg# 4445989
   CURSOR cur_items(inv_id IN NUMBER, line_no IN NUMBER, cpn_max_dist_line_num NUMBER) IS
     SELECT pod.po_header_id,
      pod.po_line_id,
      pod.line_location_id,
      pod.set_of_books_id,
      pod.org_id,
      poh.rate,
      poh.rate_type,
      pod.rate_date,
      poh.currency_code,
      api.last_update_login,
      apd.dist_code_combination_id,
      api.creation_date,
      api.created_by,
      api.last_update_date,
      api.last_updated_by,
      api.invoice_date
    FROM  ap_invoices_all api,
      ap_invoice_distributions_all apd,
      po_distributions_all pod,
      po_headers_all poh
     WHERE  api.invoice_id               = inv_id
     AND    api.invoice_id               = apd.invoice_id
     AND    pod.po_header_id             = poh.po_header_id
     AND    apd.po_distribution_id       = pod.po_distribution_id
     AND    apd.invoice_line_number      = line_no
     AND    apd.distribution_line_number = cpn_max_dist_line_num;

    -- Added by Brathod to get minimum invoice line number from invoice distributions, Bug#4445989
     CURSOR cur_get_min_dist_linenum
           ( cpn_invoice_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_ID%TYPE
            ,cpn_invoice_line_number AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_LINE_NUMBER%TYPE
           )
     IS
     SELECT min(distribution_line_number)
     FROM   ap_invoice_distributions_all apid
     WHERE  apid.invoice_id = cpn_invoice_id
     AND    apid.invoice_line_number = cpn_invoice_line_number;

     --> Cursor to fetch the maximum line_number for current invoice, Bug# 4445989
     CURSOR cur_get_max_line_number
     IS
      SELECT max (line_number)
      FROM   ap_invoice_lines_all
      WHERE  invoice_id = inv_id;

     ln_min_dist_line_num NUMBER;
     lv_match_type varchar2(15);
     ln_max_lnno  NUMBER;
     ln_inv_line_num AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;
     ln_user_id  NUMBER;
     ln_login_id NUMBER;
     lv_misc     VARCHAR2 (15);
     -- Bug 7249100. Added by Lakshmi Gopalsami
     lv_dist_class VARCHAR2(30);

       --> Cursor to fetch maximum line from ap_invoice_lines_all for current invoice, Bug# 4445989
      CURSOR cur_get_max_ap_inv_line (cpn_max_line_num AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE)
      IS
      SELECT   accounting_date
              ,period_name
              ,deferred_acctg_flag
              ,def_acctg_start_date
              ,def_acctg_end_date
              ,def_acctg_number_of_periods
              ,def_acctg_period_type
              ,set_of_books_id
        , wfapproval_status
      FROM    ap_invoice_lines_all
      WHERE   invoice_id = inv_id
      AND     line_number = cpn_max_line_num;

      rec_max_ap_lines_all    CUR_GET_MAX_AP_INV_LINE%ROWTYPE;

      -- End Bug# 4445989

    CURSOR c_tax(t_id NUMBER) IS
     SELECT tax_name, tax_account_id, mod_cr_percentage, tax_type,
   NVL(rounding_factor,0) rounding_factor /* added by vumaasha for bug 6761425 */
     -- bug 3051832, mod_cr_percentage added by aparajita on 10/10/2002 for bug # 2616100
     FROM   JAI_CMN_TAXES_ALL
     WHERE  tax_id = t_id;

    CURSOR c_inv(inv_id NUMBER) IS
      SELECT batch_id,source
      FROM   ap_invoices_all
      WHERE  invoice_id = inv_id;

    CURSOR for_org_id(inv_id NUMBER) IS
     SELECT org_id, vendor_id, NVL(exchange_rate, 1) exchange_rate, invoice_currency_code
     FROM   ap_invoices_all
     WHERE  invoice_id = inv_id;

    /*CURSOR for_acct_id(orgn_id NUMBER) IS
     SELECT accts_pay_code_combination_id
     FROM   ap_system_parameters_all
     WHERE  NVL(org_id, 0) = NVL(orgn_id, 0);
     */
     --commented the above by Sanjikum For Bug#4474501, as this cursor is not being used anywhere

    CURSOR for_dist_insertion(inv_id NUMBER, inv_line_num NUMBER, cpn_min_dist_line_num NUMBER) IS  /* Picks up dtls from std apps inserted line */
     SELECT a.accounting_date,a.accrual_posted_flag,
                a.assets_addition_flag,a.assets_tracking_flag,
    a.cash_posted_flag,a.dist_code_combination_id,
    a.last_updated_by,a.last_update_date,
    a.line_type_lookup_code,a.period_name,
    a.set_of_books_id,a.amount,a.base_amount,a.batch_id,
    a.created_by,a.creation_date,a.description,
    a.accts_pay_code_combination_id,
    a.exchange_rate_variance,
    a.last_update_login,a.match_status_flag,
    a.posted_flag, a.rate_var_code_combination_id,
    a.reversal_flag,a.vat_code,a.exchange_date,
    a.exchange_rate, a.exchange_rate_type,
    a.price_adjustment_flag,a.program_application_id,
    a.program_id, a.program_update_date,
    a.global_attribute1, a.global_attribute2, a.global_attribute3,
    a.po_distribution_id,  a.project_id,a.task_id,a.expenditure_type,
    a.expenditure_item_date,a.expenditure_organization_id,
    quantity_invoiced,
    invoice_distribution_id,
    matched_uom_lookup_code,
    org_id -- Bug 4863208
    , project_accounting_context    /* 5763527 */
    , pa_addition_flag    /* 5763527 */
  , asset_book_type_code /* 8406404 */
     FROM   ap_invoice_distributions_all a
     WHERE  invoice_id               = inv_id
     AND    invoice_line_number      = inv_line_num
     AND    distribution_line_number = cpn_min_dist_line_num;

  /* Added by LGOPALSA. Bug 4210102
   * Added CVD and Customs education cess */
   CURSOR tax_lines1_cur(tran_id NUMBER,ven_id NUMBER)
   IS
   SELECT
     jrl.tax_amount tax_amount
   , jrl.tax_id
   , jrl.currency
   , jrl.tax_type tax_type
   , jrl.modvat_flag
   , jrl.tax_line_no --Added by kunkumar for bug#5593895
   , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
   FROM
     JAI_RCV_LINE_TAXES jrl
   , rcv_shipment_lines rsl
   , rcv_transactions   rt
   , jai_cmn_taxes_all   jcta
   WHERE jrl.shipment_line_id = rsl.shipment_line_id
     AND rt.shipment_line_id = rsl.shipment_line_id
     AND rt.transaction_id = tran_id
     AND jrl.vendor_id = ven_id
     AND jcta.tax_id   = jrl.tax_id  --Added by Eric for Inclusive Tax
     AND NVL(upper(jrl.tax_type),'TDS') NOT IN ('TDS',
                                               'CVD',
                        jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                 'CUSTOMS',
                                                jai_constants.tax_type_customs_edu_cess,
                                                jai_constants.tax_type_cvd_edu_cess)
    -- GROUP BY jrl.tax_id,jrl.currency,jrl.tax_type, jrl.modvat_flag  -- commented bug#3038566
    order by  tax_line_no -- added bug#3038566
    ;

  /* Added by LGOPALSA. Bug 4210102
   * Added CVD and Customs Education Cess */
  --CURSOR from_line_location_taxes(p_line_location_id NUMBER, vend_id NUMBER) IS  | pramasub commented and modified for FP
  CURSOR from_line_location_taxes
  ( p_line_location_id NUMBER
  , vend_id NUMBER
  , cp_source VARCHAR2  --pramasub FP
  , cp_shipment_num VARCHAR2
  ) --pramasub FP
  IS
  SELECT * FROM( --PRAMASUB FP
      SELECT
        jpt.tax_id
      , jpt.tax_amount
      , jpt.currency
      , jpt.tax_target_amount
      , jpt.modvat_flag
      , jpt.tax_type
      , jpt.tax_line_no --Added by kunkumar for bug#5593895
      , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
      FROM
        jai_po_taxes          jpt
      , jai_cmn_taxes_all     jcta           --Added by Eric for Inclusive Tax
      -- WHERE line_focus_id = focus_id
      WHERE jpt.line_location_id = p_line_location_id   -- 3096578
        AND jcta.tax_id   = jpt.tax_id                  --Added by Eric for Inclusive Tax
        AND NVL(upper(jpt.tax_type), 'A') NOT IN ('TDS',
                                            'CVD',
               jai_constants.tax_type_add_cvd ,     -- Date 31/10/2006 Bug 5228046 added by SACSETHI
              'CUSTOMS',
                                            jai_constants.tax_type_customs_edu_cess,
                                            jai_constants.tax_type_cvd_edu_cess
             )
        AND NVL(jpt.vendor_id, 0) = vend_id
        AND cp_source <> 'ASBN'
      --ORDER BY  tax_line_no; -- added bug#3038566  --pramasub FP  | commented and order by is moved to end of the qry
      -- AND tax_amount  <> 0 ;-- commented by aparajita on 10/03/2003 for bug # 2841363
      UNION -- added by pramasub for ISupp IL FP start
  SELECT
    taxes.tax_id
  , taxes.TAX_AMT       tax_amount
  , taxes.CURRENCY_CODE currency
  , taxes.TAX_AMT       tax_target_amount
  , taxes.modvat_flag
  , taxes.tax_type
  , taxes.tax_line_no -- added, Harshita for Bug 5553150
  , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --Added by Eric for Inclusive Tax
  FROM
    jai_cmn_lines lines
  , jai_cmn_document_Taxes taxes
  , jai_cmn_taxes_all     jcta           --Added by Eric for Inclusive Tax
  WHERE lines.cmn_line_id = taxes.source_doc_line_id
    AND taxes.source_doc_type = 'ASBN'
    AND lines.po_line_location_id = p_line_location_id
    AND lines.shipment_number = cp_shipment_num
    AND NVL(taxes.vendor_id, 0) = vend_id
    AND jcta.tax_id   = taxes.tax_id   --Added by Eric for Inclusive Tax
    AND cp_source = 'ASBN')
  ORDER BY  tax_line_no; --pramasub FP end

  CURSOR c_dist_reversal_cnt(p_invoice_id IN NUMBER) IS
      SELECT 1
      FROM ap_invoice_distributions_all
      WHERE invoice_id = p_invoice_id
      AND reversal_flag = 'Y'
      AND rownum = 1; -- Added by avallabh for bug 4926094 on 03-Feb-2006

  CURSOR count_dist_no(inv_id NUMBER) IS
    SELECT NVL(DISTRIBUTION_LINE_NUMBER,1) FROM
     AP_INVOICE_DISTRIBUTIONS_ALL WHERE
     INVOICE_ID = inv_id
     AND DISTRIBUTION_LINE_NUMBER =
       (SELECT MAX(DISTRIBUTION_LINE_NUMBER)
        FROM AP_INVOICE_DISTRIBUTIONS_ALL
        WHERE INVOICE_ID = inv_id)
        FOR UPDATE OF DISTRIBUTION_LINE_NUMBER;

  cursor c_get_invoice_distribution  is -- bug#3332988
    select ap_invoice_distributions_s.nextval
    from   dual;

  -- start addition by ssumaith -bug# 3127834

  cursor c_fnd_curr_precision(cp_currency_code fnd_currencies.currency_code%type) is
  select precision
  from   fnd_currencies
  where  currency_code = cp_currency_code;

  -- ends here additions by ssumaith -bug# 3127834

  ln_precision                         fnd_currencies.precision%type; -- added by sssumaith - bug# 3127834
  v_statement_no                      VARCHAR2(6);
  v_dist_reversal_cnt                 NUMBER;
  v_batch_id                          NUMBER;
  c_tax_rec                           c_tax%ROWTYPE;
  v_source                            VARCHAR2(25);
  shpmnt_ln_id                        rcv_shipment_lines.shipment_line_id%TYPE;
  cur_items_rec                       cur_items%ROWTYPE;
  caid                                gl_sets_of_books.chart_of_accounts_id%TYPE;
  for_dist_insertion_rec              for_dist_insertion%ROWTYPE;
  cum_tax_amt                         NUMBER := 0;
  v_distribution_no                   NUMBER;
  v_tax_amount                        NUMBER;
  result                              BOOLEAN;
  req_id                              NUMBER;
  for_org_id_rec                      for_org_id%ROWTYPE;
  -- for_acct_id_rec                     for_acct_id%ROWTYPE;
  --commented the above by Sanjikum For Bug#4474501, as this variable is not being used anywhere
  v_cor_factor                        NUMBER;
  v_functional_currency               gl_sets_of_books.currency_code%type; -- added for bug#3354932
  count_dist_no_rec                   NUMBER;
  v_attribute12                       VARCHAR2(150);
  v_ATTRIBUTE2                        VARCHAR2(150);
  v_sup_po_header_id                  NUMBER;
  v_sup_po_line_id                    NUMBER;
  v_sup_line_location_id              NUMBER;
  v_sup_set_of_books_id               NUMBER;
  v_sup_org_id                        NUMBER;
  v_sup_conversion_rate               NUMBER;
  v_sup_tax_date                      DATE;
  v_sup_currency                      VARCHAR2(10);
  v_sup_invoice_date                  DATE;
  v_invoice_num                       VARCHAR2(50);
  v_sup_inv_type                      VARCHAR2(25);
  v_ship_num                          VARCHAR2(30); -- added pramasub FP
  get_ven_info_rec                    get_ven_info%ROWTYPE;
  chk_for_pcking_slip_rec             checking_for_packing_slip%ROWTYPE;
  v_assets_tracking_flag              ap_invoice_distributions_all.assets_tracking_flag%type;
  v_update_payment_schedule           boolean; -- bug#3206083
  v_invoice_distribution_id           ap_invoice_distributions_all.invoice_distribution_id%type; -- bug#3332988
  v_apportn_factor_for_item_line      number;
  v_dist_code_combination_id          ap_invoice_distributions_all.dist_code_combination_id%type;--bug#367196

  -- Bug 5401111. Added by Lakshmi Gopalsami
  lv_account_type gl_code_combinations.account_type%TYPE;

  /* 5763527 */
  ln_project_id           ap_invoice_distributions_all.project_id%TYPE;
  ln_task_id              ap_invoice_distributions_all.task_id%TYPE;
  lv_exp_type             ap_invoice_distributions_all.expenditure_type%TYPE;
  ld_exp_item_date        ap_invoice_distributions_all.expenditure_item_date%TYPE;
  ln_exp_organization_id  ap_invoice_distributions_all.expenditure_organization_id%TYPE;
  lv_project_accounting_context       ap_invoice_distributions_all.project_accounting_context%TYPE;
  lv_pa_addition_flag                 ap_invoice_distributions_all.pa_addition_flag%TYPE;

  ln_lines_to_insert                  number;
  ln_nrec_tax_amt                     number;
  ln_rec_tax_amt                      number;
  lv_modvat_flag                      jai_ap_match_inv_taxes.recoverable_flag%type;

  lv_excise_costing_flag              varchar2 (1);
  lv_tax_type                         varchar2(5); --added by eric for inclusive tax
  lv_tax_line_amount                  NUMBER := 0; --added by eric for inclusive tax
  lv_ap_line_to_inst_flag             VARCHAR2(1); --added by eric for inclusive tax
  lv_tax_line_to_inst_flag            VARCHAR2(1); --added by eric for inclusive tax



  cursor c_get_excise_costing_flag (cp_rcv_transaction_id   rcv_transactions.transaction_id%type,
                                    cp_organization_id      JAI_RCV_TRANSACTIONS.organization_id%type,      --Added by Bgowrava for Bug#7503308
                                    cp_shipment_header_id   JAI_RCV_TRANSACTIONS.shipment_header_id%type,          --Added by Bgowrava for Bug#7503308
                                    cp_txn_type             JAI_RCV_TRANSACTIONS.transaction_type%type,      --Added by Bgowrava for Bug#7503308
                                    cp_attribute1           VARCHAR2)           --Added by Bgowrava for Bug#7503308
  is
    select cenvat_costed_flag excise_costing_flag
    from   jai_rcv_transactions jrcvt
    where  jrcvt.parent_transaction_id = cp_rcv_transaction_id
  and    jrcvt.organization_id  = cp_organization_id --Added by Bgowrava for Bug#7503308
    and    jrcvt.shipment_header_id = cp_shipment_header_id
    and    jrcvt.transaction_type = cp_txn_type ;--'DELIVER'     --Modified by Bgowrava for Bug#7503308
  --  and    jrcvt.attribute1= cp_attribute1 ; --'CENVAT_COSTED_FLAG';    --Modified by Bgowrava for Bug#7503308 --Commented by Bo Li for bug9305067
   /* End 5763527 */

  /* Service Tax */
  cursor c_rcv_transactions(p_transaction_id  number) is
     select po_line_id, organization_id
     from   rcv_transactions
     where  transaction_id = p_transaction_id;

   cursor c_po_lines_all(p_po_line_id number) is
     select item_id
     from   po_lines_all
     where  po_line_id = p_po_line_id;

   /* Bug 5358788. Added by Lakshmi Gopalsami
    * Added parameter cp_regime_code instead of
    * hardcoding the value for service. This is required
    * for re-using the same cursor to avoid performance issue
    * in using jai_regime_tax_types_v.
    */
   cursor c_jai_regimes(cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE)
   IS
     select regime_id
     from   JAI_RGM_DEFINITIONS
     where  regime_code = cp_regime_code ; /* SERVICE or VAT */

   cursor c_regime_tax_type(cp_regime_id  number, cp_tax_type varchar2) is
    select attribute_code tax_type
    from   JAI_RGM_REGISTRATIONS
    where  regime_id = cp_regime_id
    and    registration_type = jai_constants.regn_type_tax_types  /* TAX_TYPES */
    and    attribute_code = cp_tax_type;

   /*Added by kunkumar for bug#5593895*/
  Cursor c_tax_curr_prec(cp_tax_id jai_cmn_taxes_all.tax_id%type) is
  select NVL(rounding_factor,-1)
  from jai_cmn_taxes_all
  where tax_id = cp_tax_id  ;
  /*End, Added by kunkumar for bug#5593895*/

   r_rcv_transactions               c_rcv_transactions%rowtype;
   r_po_lines_all                   c_po_lines_all%rowtype;
   r_jai_regimes                    c_jai_regimes%rowtype;
   r_service_regime_tax_type            c_regime_tax_type%rowtype;
   lv_is_item_an_expense            varchar2(20); /* Service */
   lv_accounting_method_option      varchar2(20); /* Service */
   lv_accrue_on_receipt_flag        po_distributions_all.accrue_on_receipt_flag%type;
  /* Service Tax */

  /* Bug 5358788. Added by Lakshmi Gopalsami
   * Defined variable for fetching VAT regime/
   */
   r_vat_regimes                    c_jai_regimes%rowtype;
   r_vat_regime_tax_type            c_regime_tax_type%rowtype;

   ln_base_amount number ; --Added by kunkumar for bug#5593895
   ln_tax_precision                    JAI_CMN_TAXES_ALL.rounding_factor%type;--Added by kunkumar for bug#5593895

  FUNCTION update_payment_schedule (p_total_tax NUMBER) RETURN boolean IS -- bug # 3218978

    v_total_tax_in_payment            number;
    v_tax_installment                 number;
    v_payment_num                     ap_payment_schedules_all.payment_num%type;
    v_total_payment_amt               number;
    v_diff_tax_amount                 number;

    cursor  c_total_payment_amt is
    select  sum(gross_amount)
    from    ap_payment_schedules_all
    where   invoice_id = inv_id;

  begin

  Fnd_File.put_line(Fnd_File.LOG, 'Start of function  update_payment_schedule');

    open  c_total_payment_amt;
    fetch   c_total_payment_amt into v_total_payment_amt;
    close   c_total_payment_amt;

  if nvl(v_total_payment_amt, 0) = 0 then
    Fnd_File.put_line(Fnd_File.LOG, 'Cannot update payment schedule, total payment amount :'
                                    || to_char(v_total_payment_amt));
    return false;
  end if;

    v_total_tax_in_payment := 0;

    for c_installments in
    (
    select  gross_amount,
        payment_num
    from    ap_payment_schedules_all
    where   invoice_id = inv_id
    order by payment_num
    )
    loop

      v_tax_installment := 0 ;
      v_payment_num  :=  c_installments.payment_num;

      v_tax_installment := p_total_tax * (c_installments.gross_amount / v_total_payment_amt);

      v_tax_installment := round(v_tax_installment, ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        = gross_amount          + v_tax_installment,
         amount_remaining      = amount_remaining      + v_tax_installment,
         inv_curr_gross_amount = inv_curr_gross_amount + v_tax_installment,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
            -- bug#3624898
      where  invoice_id = inv_id
      and    payment_num = v_payment_num;

      v_total_tax_in_payment := v_total_tax_in_payment + v_tax_installment;

    end loop;

    -- any difference in tax because of rounding has to be added to the last installment.
    if v_total_tax_in_payment <> p_total_tax then

      v_diff_tax_amount := p_total_tax - v_total_tax_in_payment;

      v_diff_tax_amount := round(v_diff_tax_amount,ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        = gross_amount          + v_diff_tax_amount,
         amount_remaining      = amount_remaining      + v_diff_tax_amount,
         inv_curr_gross_amount = inv_curr_gross_amount + v_diff_tax_amount,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
            -- bug#3624898
      where  invoice_id = inv_id
      and    payment_num = v_payment_num;
    end if;

    return true;

  exception
    when others then
      Fnd_File.put_line(Fnd_File.LOG, 'exception from function  update_payment_schedule');
      Fnd_File.put_line(Fnd_File.LOG, sqlerrm);
      return false;

  end update_payment_schedule; -- bug # 3218978

  -- Start added for bug#3332988
  procedure insert_mrc_data (p_invoice_distribution_id number) is
    -- Vijay Shankar for bug#3461030
    v_mrc_string VARCHAR2(10000);
  begin

       v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data (
      p_operation_mode    => ''INSERT'',
      p_table_name        => ''AP_INVOICE_DISTRIBUTIONS_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax line as Miscellaneous distribution line (jai_ap_match_tax_pkg.process_batch_record procedure)''
       ); END;';

      -- Vijay Shankar for bug#3461030
      EXECUTE IMMEDIATE v_mrc_string USING p_invoice_distribution_id;

  -- Vijay Shankar for bug#3461030
  exception
    when others then
    IF SQLCODE = -6550 THEN
      -- object referred in EXECUTE IMMEDIATE is not available in the database
      null;
      FND_FILE.put_line(FND_FILE.log, '*** MRC API is not existing(insert)');
    ELSE
      FND_FILE.put_line(FND_FILE.log, 'MRC API exists and different err(insert)->'||SQLERRM);
      RAISE;
    END IF;
  end;

  procedure update_mrc_data is
    -- Vijay Shankar for bug#3461030
    v_mrc_string VARCHAR2(10000);
  begin

       v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data
       (
      p_operation_mode    => ''UPDATE'',
      p_table_name        => ''AP_INVOICES_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax amount added to invoice header (jai_ap_match_tax_pkg.process_batch_record procedure)''
       ); END;';

      -- Vijay Shankar for bug#3461030
      EXECUTE IMMEDIATE v_mrc_string USING inv_id;

  -- Vijay Shankar for bug#3461030
  exception
    when others then
    IF SQLCODE = -6550 THEN
      -- object referred in EXECUTE IMMEDIATE is not available in the database
      null;
      FND_FILE.put_line(FND_FILE.log, '*** MRC API is not existing(update)');
    ELSE
      FND_FILE.put_line(FND_FILE.log, 'MRC API exists and different err(update)->'||SQLERRM);
      RAISE;
    END IF;
  end;

  -- End added for bug#3332988

BEGIN

/*------------------------------------------------------------------------------------------------------
CHANGE HISTORY:            FILENAME: jai_ap_match_tax_pkg.process_batch_record_p.sql
S.No     dd/mm/yyyy    Author and Details
----------------------------------------------------------------------------------------------------------
1.       23/05/2002    Aparajita for bug # 2359737 Version# 614.1
                       this procedure is extracted from jai_ap_match_tax_pkg.process_online and contains
                       only the pay on receipt functionality which will be now used by the
                       concurrent for pay on receipt which will call this procedure.

2.     21/06/2002      Aparajita for bug # 2428264 Version# 614.2
                       In the insertion to ap_invoice_distributions_all, populated the
                       org id that is supplied as a parameter to this program. Without this
                       the org id gets defaulted from the session variables and may go wrong.

3.       09/10/2002    Aparajita for bug # 2483164 Version# 615.1
                       Populate the po distribution id and rcv_transactions id for the tax
                       lines for backtracking tax to purchasing side.

                       Deleted the code for supplementary invoices as this is only for pay on
                       receipt. This code was here as this procedure was extracted from
                       distribution matching.

4.       03/11/2002    Aparajita for bug # 2567799 Version# 615.2
                       Added a function apportion_tax_pay_on_rect_f and using it to apportion the
                       tax amount. This is useful when there are multiple distributions for the PO.


5.       05/11/2002    Aparajita for bug # 2506453, Version# 615.3
                       Changed the cursor definition get_tax_ln_no, to look into the receipt tax
                       instead of the po tax table for getting the line number. This was running
                       into error when no taxes exist at po and have been added at receipt.

                       Also Changed the cursor definition get_sales_tax_dtl to fetch on the
                       basis of tax id instead of name.

6.       15/11/2002    cbabu for bug # 2665306, Version# 615.4
                       Added the code when rcv_tran_id is NULL.

                       the code that is added was copied from jai_ap_match_tax_pkg.process_online code with
                       p_rematch = 'PO_MATCHING' Now the taxes for ERS invoice will be defaulted
                       here and header amount is updated if the invoice is created for the first
                       time. If any reversal is happened for distribution lines, then invoice
                       header amount is not modified.

7.       02/12/2002    Aparajita for bug # 2689834 Version # 615.5
                       In the insertion to ap_invoice_distributions_all, populated the org id
                       that is supplied as a parameter to this program. Without this the org id
                       gets defaulted from the session variables and may go wrong.

                       Bug # 2428264 had addressed this issue before but that was only for
                       pay on receipt scenario. Bug # 2665306  added the PO setup where the
                       rcv_transaction id goes as blank. In this scenario, the org id was
                       not getting populated, have done the same changes for that scenario.

8.       16/12/2002    cbabu for bug# 2713601, FileVersion # 615.6
                       AP_PAYMENTS_SCHEDULES_ALL is not getting updated with the tax amount
                       as soon as AP_INVOICES_ALL isgetting updated. Update statement for
                       ap_payment_schedules_all is written for scenario where rcv_transaction_id
                       in ap_invoice_distributions_all is NULL. Thsi happens in PO matching
                       setup for ERS invoices.

9.      20/12/2002    Aparajita for bug # 2689826 Version # 615.7

                       The distribution line numbers were getting  skipped every time the tax
                       is inserted for a 2nd item line onwards. This was happening because the
                       distribution line number is calulated by taking the max distribution
                       line number and also the no of tax lines which have a shipment line id
                       less than corresponding shipment line id for the same shipment header.
                       This logic is not required as the distribution line number should always
                       be the next number. commented the cursor count_tax_lines.


10.      14/03/2003    Aparajita for bug # 2841363. Version # 615.8
                       Taxes having 0 amount were not considered, changed the cursor
                       from_line_location_taxes to conside such tax lines for propagation into AP.

11.      15/03/2003    Aparajita for bug # 2851123. Version # 615.9
                       The assets_tracking_flag in ap_invoice_distributions_all,
                       JAI_AP_MATCH_INV_TAXES and JAI_CMN_FA_INV_DIST_ALL should be set as 'N'
                       if the tax line against which the line is being generated is excise type of
                       tax and is modvatable. By default this flag gets the value from the
                       corresponding item line for which the tax is attached.

                       Introduced a variable v_assets_tracking_flag.
                       Modified the following cursors to fetch modvat_flag.
                       - from_line_location_taxes
                       - tax_lines1_cur

12.      13/04/2003    bug#2799217. Version # 615.10
                       line focus id from JAI_PO_TAXES instead of
                       JAI_PO_LINE_LOCATIONS, changed cursor get_focus_id.

                       This was done as in some cases data does not exist in
                       JAI_PO_LINE_LOCATIONS but exists in JAI_PO_TAXES.
                       The root cause of this will be looked into separately.

13      17/07/2003     Aparajita for bug#3038566, version # 616.1

                       Introduced a new function getSTformsTaxBaseAmount to calculate the
                       tax base amount to be populated into the table ja_in_po_st_forms_dtl.
                       Calculating the tax base amount from the tax amount and percentage was
                       giving problem because of rounding.

14     14/08/2003      kpvs for bug # 3051832, version # 616.2
                       OPM code merged into this version of the procedure.
                       Changes made to pull in the OPM code fixes done for bugs 2616100 and 2616107
                       Used 'v_opm_flag' to check for the process enabled flag of the
                       organization.


15.    17/08/2003     Aparajita for bug#3094025. Generic for bug#3054140. version # 616.3
                      There may be taxes at receipt without having any tax at PO.
                      For such cases, the st forms population has to cater.
                      Precedences are not available, so calculation of tax base is not possible.
                      Added the backward calcultion for such cases.

                      Changes in the function getSTformsTaxBaseAmount.
                      Introduced two new parameters tax amount and rate to calculate backward
                      in case PO tax details are not found. It was observed that the function
                      getSTformsTaxBaseAmount was always considering the precedence
                      0 amount irrespective of the valus of the precendences.
                      This has been corrected.

16.   22/08/2003    Aparajita for bug# 2828928. Version # 616.4 .
                      Added the condition to consider null vendor id
                      and modvat = 'N' taxes in the following
                      cursor. Also added the code to consider mod_cr_percentage.
                       - C_third_party_tax cursor definition modified.


17.     27/08/2003    Aparajita for bug#3116659. Version#616.5
                      Projects clean up.

18.   27/08/2003    Vijay Shankar for bug# 3096578. Version # 616.6
                       All taxes are not picked from PO Shipment if the taxes are selected based on
                       line_focus_id as there are different line_focus_id's for same
                       line_location_id which is wrong. Also we should use line_location_id
                       to fetch the taxes instead of line_focus_id as line_location_id
                       refers to the PO Shipments in which taxes are attached and line_focus_id
                       is just a unique key for JAI_PO_LINE_LOCATIONS table.
                       Modified the cursor from_line_locations_taxes to fetch the taxes
                       based on line_location_id

            Bug# 3114596, Version same as bug# 3096578 (616.6)
                       When DEBIT MEMO created for RTS transaction, then if Supplier setup has
                       PO Matching, then dist_match_type is coming as ITEM_TO_RECEIPT
                       but rcv_transaction_id is not getting populated because of which taxes
                       are not getting defaulted by giving an error which is written in default
                       ELSIf. Code is modified to take the route of PO matching
                       if rcv_transaction_id is not populated for DEBIT MEMO
                       i.e source = 'RTS'


19      16/10/2003    Aparajita for bug#3193849. Version#616.7

                      Removed the ST forms functionality from here as ST forms population is now being
                      handled through a concurrent.

20    28/10/2003    Aparajita for bug#3206083. Version#616.7

                      If the base invoice is cancelled, there is no need to bring the tax lines.
                      Added code to check the cancelled date and if populated, returning from the proc.

21    28/10/2003    Aparajita for bug#3218978. Version#616.7

                      Tax amount is apportioned properly between the installments.Differential
                      tax amounts if any because of rounding is added to the last installment.

                      Code is not reading anything from terms master, instead based on
                      the distribution of the amount before tax, tax amount is distributed.
                      coded in in line function update_payment_schedule.

22      23/12/2003    Aparajita for bug#3306090. Version 618.1
                      Tax amount was calculated wrongly when tax currency is different from
                      invoice currency. This was not handled in the function
                      apportion_tax_pay_on_rect_f. Added code for the same.

29    07/01/2003    Aparajita for bug#3354932. Version#618.2
                    When the invoice is in foreign currency, for ERS invoice, base_amount in
                    ap_invoices_all should be updated to include the loc taxes as otherwise
                    it is creating wrong accounting entries.

                    This update needs to be done only for ERS invoices as other cases
                    localization does not update the
                    invoice header amounts. p_rematch = 'PAY_ON_RECEIPT'.
                    Additionally this should be done only when the invoice currency
                    is not the functional currency.

30      27/01/2004   Aparajita for bug#3332988. Version#618.3

                     Call to AP_MRC_ENGINE_PKG.Maintain_MRC_Data for MRC functionality.

                     This call is made after every distribution line is inserted.
                     This has been implemented as a in line procedure insert_mrc_data.
                     The procedure is called after every insert into
                     ap_invoice_distributions_all.

                    Procedure update_mrc_data has been created and invoked whereever
                    invoice header is being updated.


31     03/02/2004   Aparajita for bug#3015112. Version#618.4
                    Removed the OPM costing functionality. This was updating quantity invoiced
                    and unit price for miscellaneous lines and this was creating problem
                    for subsequent transactions against the same PO / Receipt.

                    The changes removed were brought in for bug#3051828.

32     24/02/2004   Vijay Shankar for bug#3461030. Version#618.5
                     Modified the MRC call to be dynamic by using EXECUTE IMMEDIATE.
                     This is done to take care of Ct.s who are on base version less than 11.5.7

33    25/02/2004   Aparajita for bug#3315162. Version#618.6

                     Base application gives problem while reversing localization tax lines.
                     This was analyzed with base and found out that the problem was because of
                     null value for matched_uom_lookup_code field of the miscellaneous
                     tax distribution.  Further null value of quantity also creats problem as
                     the billed quantity on PO/receipt gets updated to null when the loc taxes
                     does get reversed with value populated for UOM.

                     Changes have been made to populate matched_uom_lookup_code same
                     as item line and quantity as 0.

34    30/03/2004   Aparajita for bug#3448803. Version#619.1.
                     track as asset flag for the distribution for tax line in payable invoice now
                     considers partially recoverable taxes. The logic is now as follows,

                     - default value of this flag is same as that of the corresponding item line.
                     - if the corresponding tax is modvatable to teh extent of 100% then the value
                     of the flag is over written to 'N' irrespective of the value of the
                     corresponding base item line.

35      15/05/2004   Aparajita for bug#3624898. Version#619.2
                     Whenever the tax lines are populated, if the invoice is already fully paid
                     the paid amount is displayed wrongly to be including the tax amount.

                     Fixed the problem by updating the payment_status_flag in ap_invoices)_all and
                     ap_payment_shedules_all to 'P' in case it was Y.

36    08/07/2004     Aparajita for bug#3752887. Version#115.1, Clean up.

                     Function apportion_tax_pay_on_rect_f was considering the quantity
                     from rcv_transactions and  taxes from JAI_RCV_LINE_TAXES.
                     This fails when there have been corrections as taxes are modified as
                     per the corrected quantity.

                     Cleaned the entire logic of apportioning of tax from PO to AP.
                     Used the function jai_ap_interface_pkg.get_apportion_factor which has been
                     designed new to find out the factor that needs to be applied. All Logic
                     of apportioning is now in the external function and removed a lot of code
                     from here which was trying to do the same here at more than one place.
                     Also rmoved the in line function function apportion_tax_pay_on_rect_f.

                     Function jai_ap_interface_pkg.get_apportion_factor was designed for purchase register report
                     through bug#3633078. Added the procedure here also in the patch as it is not
                     required to have the report to have the function. So no dependency.

                     tax invoice price variance :=
                     tax amount * (base item line variance amount / base item line amount).


37. 01/11/2003       ssumaith - bug# 3127834 - file version 115.2

                     currency precision was not used for rounding the tax amounts when inserting / updating
                     records into  ap_invoices_all , ap_invoices_distributions_all , ap_payment_Schedules_all
                     tables. As a result the invoice was going into automatic hold because the invoice amount
                     does not equal sum of distributions amount.

                     This has been resolved in the bug by getting the currency precision for the invoice
                     currency from FND_CURRENCIES table and using it in all the inserts and updates which
                     involve the tax amounts.

38. 21/01/2005       Aparajita - Bug#4078546 Service Tax. Version#115.3

                    4106633    Base Bug For Education Cess on Excise, CVD and Customs.
                    4059774    Base Bug For Service Tax Regime Implementation.
                    4078546    Modification in receive and rtv accounting for service tax


                     Service Tax interim account needs to be populated as the charge account,
                     if the following condition is true.

                     Case of PO Matching or Accrue on receipt is No.


39. 11/02/2005      Aparajita - Bug#4177452. Version#115.4

                    Charge account for non-recoverable taxes were going was null.
                    This was because of the default assignment of,
                      v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;

                    inside the if of recoverable taxes.

                    Changed it to after the end if.

40.  24/02/2005     Aparajita - Bug#4204600. Version#115.5.

                    from_po_distributions was getting used without being opened.
                    Changed it to access cur_items_rec.line_location_id.

41. 12/03/2005      Bug 4210102. Added by LGOPALSA  Version - 115.6
                    (1) Added CVD and Customs education cess

42. 8/05/2005        rchandan for bug#4333488. Version 116.1
                    The Invoice Distribution DFF is eliminated and a new global DFF is used to
                    maintain the functionality. From now the TDS tax, WCT tax and ESSI will not
                    be populated in the attribute columns of ap_invoice_distributions_all table
                    instead these will be populated in the global attribute columns. So the code changes are
                    made accordingly.

43. 10-Jun-2005      rallamse for bug#  Version 116.2
                    All inserts into JAI_AP_MATCH_INV_TAXES table now include legal_entity_id as
                    part of R12 LE Initiative. The legal_entity_id is selected from ap_invoices_all in
                    cursor get_ven_info.

44  23-Jun-2005     Brathod for Bug# 4445989, Version 120.0
                    Issue: Impact uptake on IL Product for AP_INVOICE_LINES_ALL Uptake
                    Resolution:- Code modified to consider ap_invoice_lines_all instead of
                    ap_invoice_distributions_all.
                    Following changes done
                      -  Code refering to ap_invoice_distributions_all modified to consider
                         invoice_id and invoice_line_number as unique combination
                      -  invoice line record is created in ap_invoice_lines_all where ever previously
                         distribution was created
                      -  Obsoleted JAI_CMN_FA_INV_DIST_ALL
                      -  Modified structure of JAI_AP_MATCH_INV_TAXES to incorporate invoice lines
                         and also the fields from JAI_CMN_FA_INV_DIST_ALL
                      -  Code modfied to insert appropriate fields in JAI_AP_MATCH_INV_TAXES

45. 06-Jul-2005       Sanjikum for Bug#4474501
                      1) Commented the cursor - for_acct_id and corresponding open/fetch/close for the same.
                      2) Commented the call to function - jai_general_pkg.get_accounting_method

46.  08-Dec-2005  Bug 4863208. Added by Lakshmi Gopalsami Version 120.2
                          (1) Added wfapproval_Status in insert to ap_invoice_lines_all
        (2) Derived the org_id for inserting into ap_invoice_distributions_all
             This is added in CURSOR for_dist_insertion
                          (3) Added values for match_status_flag, reversal_flag in insert

47. 04-Feb-2008   JMEENA for bug#6780154

          Modify the insert statement of ap_invoice_lines_all to populate the po_distribution_id.


48.  21-Feb-2008  JMEENA for bug#6835548
          Changed the value of lv_match_type from NOT MATCHED to NOT_MATCHED.

49.  19-May-2008    JMEENA for bug#7008161
        Modified the insert statement of ap_invoice_distributions_all to populate the charge_applicable_to_dist_id
        based on v_assets_tracking_flag and removed the condition of account_type.


Future Dependencies For the release Of this Object:-
==================================================
(Please add a row in the section below only if your bug introduces a dependency due to spec change/
A new call to a object/A datamodel change )

------------------------------------------------------------------------------------------------------
Version       Bug       Dependencies (including other objects like files if any)
-------------------------------------------------------------------------------------------------------
616.1         3038566   ALTER Script  JAI_AP_MATCH_INV_TAXES Table is altered.

115.1         3752887   Dependency on function jai_ap_interface_pkg.get_apportion_factor which is also added
                        in this patch. So no pre - req.

115.3         4146708   Base Bug for Service + Cess Release.

                        Variable usage of jai_constants package.

                        Call to following,
                        jai_general_pkg.is_item_an_expense
                        jai_general_pkg.get_accounting_method
                        jai_rcv_trx_processing_pkg.get_accrue_on_receipt
                        jai_cmn_rgm_recording_pkg.get_account

------------------------------------------------------------------------------------------------------*/


  ln_user_id := fnd_global.user_id;
  ln_login_id := fnd_global.login_id;

  OPEN  get_ven_info(inv_id);
  FETCH get_ven_info INTO get_ven_info_rec;
  CLOSE get_ven_info;

-- start added by bug#3206083
  if get_ven_info_rec.cancelled_date is not null then
  -- base invoice has been cancelled, no need to process tax.
  Fnd_File.put_line(Fnd_File.LOG, 'Base invoice has been cancelled, no need to process tax');
  return;
  end if;
  -- end added by bug#3206083

  -- Start added for bug#3354932
  open c_functional_currency(get_ven_info_rec.set_of_books_id);
  fetch c_functional_currency into v_functional_currency;
  close c_functional_currency;
  -- End added for bug#3354932

  OPEN  checking_for_packing_slip(get_ven_info_rec.vendor_id, get_ven_info_rec.vendor_site_id,
  get_ven_info_rec.org_id);
  FETCH checking_for_packing_slip INTO chk_for_pcking_slip_rec;
  CLOSE checking_for_packing_slip;


  OPEN  c_inv(inv_id);
  FETCH c_inv INTO v_batch_id, v_source;
  CLOSE c_inv;

  -- Get mininum invoice distribution line number, Brathod, Bug# 4445989
  lv_match_type := 'NOT_MATCHED'; --Changed from NOT MATCHED to NOT_MATCHED for bug#6835548 by JMEENA
  lv_misc       := 'MISCELLANEOUS';
  -- Bug 7249100. Added by Lakshmi Gopalsami
  lv_dist_class := 'PERMANENT';

  OPEN cur_get_min_dist_linenum (inv_id, pn_invoice_line_number);
  FETCH cur_get_min_dist_linenum INTO ln_min_dist_line_num;
  CLOSE cur_get_min_dist_linenum;

  -- Added by Brathod for Bug# 4445989
  OPEN  cur_get_max_line_number;
  FETCH cur_get_max_line_number INTO ln_max_lnno;
  CLOSE cur_get_max_line_number;

  OPEN  cur_get_max_ap_inv_line (cpn_max_line_num => ln_max_lnno );
  FETCH cur_get_max_ap_inv_line INTO rec_max_ap_lines_all;
  CLOSE cur_get_max_ap_inv_line;
  -- End of Bug 4445989

  IF v_source <> 'SUPPLEMENT' THEN
   -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  OPEN  cur_items(inv_id,pn_invoice_line_number,ln_min_dist_line_num);
  FETCH cur_items INTO cur_items_rec;
  CLOSE cur_items;
  END IF;

  OPEN  for_org_id(inv_id);
  FETCH for_org_id INTO for_org_id_rec;
  CLOSE for_org_id;

  /* added by ssumaith  */

  open  c_fnd_curr_precision(for_org_id_rec.invoice_currency_code);
  fetch c_fnd_curr_precision into ln_precision;
  close c_fnd_curr_precision;

  if ln_precision is null then
     ln_precision := 0;
  end if;

  /* ends here addition by ssumaith */



  /*OPEN  for_acct_id(NVL(for_org_id_rec.org_id, 0));
  FETCH for_acct_id INTO for_acct_id_rec;
  CLOSE for_acct_id;
  */
  --commented the above by Sanjikum For Bug#4474501, as this cursor is not being used anywhere

  IF v_source <> 'SUPPLEMENT' THEN

    BEGIN  --06-Mar-2002
      SELECT chart_of_accounts_id INTO caid
      FROM   gl_sets_of_books
      WHERE  set_of_books_id = cur_items_rec.set_of_books_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END ;-- end 06-Mar-2002

  END IF;


  BEGIN  --06-Mar-2002


    -- Cursor to select maximum line number from invoice lines for particular invoice
    -- Lock ap_invoice_lines_all
    UPDATE ap_invoice_lines_all
    SET    last_update_date = last_update_date
    WHERE invoice_id = inv_id;

    SELECT max(line_number)
    INTO   ln_inv_line_num
    FROM   ap_invoice_lines_all
    WHERE  invoice_id = inv_id;
    -- End of Bug# 4445989
    /*
    Commented by Brathod for Bug# 4445989
    SELECT NVL(DISTRIBUTION_LINE_NUMBER,1)
    INTO v_distribution_no
    FROM   AP_INVOICE_DISTRIBUTIONS_ALL
    WHERE  INVOICE_ID = inv_id
    AND    DISTRIBUTION_LINE_NUMBER =
      (
      SELECT MAX(DISTRIBUTION_LINE_NUMBER)
      FROM   AP_INVOICE_DISTRIBUTIONS_ALL
      WHERE  INVOICE_ID = inv_id
      )
    FOR UPDATE OF DISTRIBUTION_LINE_NUMBER;
    */

  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END ;--end 06-Mar-2002

  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  OPEN  for_dist_insertion(inv_id,pn_invoice_line_number, ln_min_dist_line_num);
  FETCH for_dist_insertion INTO for_dist_insertion_rec;
  CLOSE for_dist_insertion;


  v_apportn_factor_for_item_line :=
  jai_ap_utils_pkg.get_apportion_factor(inv_id, pn_invoice_line_number);
  -- bug#3752887

/* service Start */

  open c_rcv_transactions(rcv_tran_id);
  fetch c_rcv_transactions into r_rcv_transactions;
  close c_rcv_transactions;

  open c_po_lines_all(po_dist_id);
  fetch c_po_lines_all into r_po_lines_all;
  close c_po_lines_all;

  lv_is_item_an_expense :=
  jai_general_pkg.is_item_an_expense
  (
  p_organization_id   =>     r_rcv_transactions.organization_id,
  p_item_id           =>     r_po_lines_all.item_id
  );

  /*lv_accounting_method_option :=
  jai_general_pkg.get_accounting_method
  (
   p_org_id            =>    v_org_id,
   p_organization_id   =>    r_rcv_transactions.organization_id,
   p_sob_id            =>    for_dist_insertion_rec.set_of_books_id
  );*/
  --commented the above by Sanjikum for Bug#4474501

  lv_accrue_on_receipt_flag :=
  jai_rcv_trx_processing_pkg.get_accrue_on_receipt(p_po_distribution_id => po_dist_id);

  open c_jai_regimes(jai_constants.service_regime);
  fetch c_jai_regimes into r_jai_regimes;
  close c_jai_regimes;

  /* service End */

 /* Bug 5358788. Added by Lakshmi Gopalsami
  * Fetch VAT Regime id
  */

  OPEN  c_jai_regimes(jai_constants.vat_regime);
  FETCH  c_jai_regimes INTO  r_vat_regimes;
  CLOSE  c_jai_regimes;

  /* Bug 5401111. Added by Lakshmi Gopalsami
   | Get the account type for the distribution.
   | This is required to find out whether charge_applicable_to_dist
   */
   lv_account_type := get_gl_account_type
                    (for_dist_insertion_rec.dist_code_combination_id);

  IF p_rematch = 'PAY_ON_RECEIPT' THEN

    IF rcv_tran_id IS NOT NULL THEN

      /* Begin 5763527 */
      open  c_get_excise_costing_flag (cp_rcv_transaction_id => rcv_tran_id
                                     ,cp_organization_id =>  r_rcv_transactions.organization_id          --Added by Bgowrava for Bug#7503308
                                      ,cp_shipment_header_id     =>  p_shipment_header_id                           --Added by Bgowrava for Bug#7503308
                                      ,cp_txn_type        =>  'DELIVER'                                    --Added by Bgowrava for Bug#7503308
                                      ,cp_attribute1      =>  'CENVAT_COSTED_FLAG');                       --Added by Bgowrava for Bug#7503308
      fetch c_get_excise_costing_flag into lv_excise_costing_flag;
      close c_get_excise_costing_flag ;
      fnd_file.put_line(fnd_file.log, 'rcv_tran_id='||rcv_tran_id||',lv_excise_costing_flag='||lv_excise_costing_flag);
      /* End 5763527 */


      IF p_receipt_code  = 'RECEIPT' THEN

        OPEN count_dist_no(inv_id);
        FETCH count_dist_no INTO count_dist_no_rec;
        CLOSE count_dist_no;

        v_distribution_no := nvl(count_dist_no_rec, 0);


        FOR tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP
            -- Added by Brathod for Bug# 4445989
            /* v_distribution_no := v_distribution_no + 1; */
            v_distribution_no :=1;
            -- ln_inv_line_num := ln_inv_line_num + 1;  -- 5763527, moved the increment to just before insert statement
            -- End Bug# 4445989

            r_service_regime_tax_type := null;

            /* 5763527 */
            ln_project_id           := null;
            ln_task_id              := null;
            lv_exp_type             := null;
            ld_exp_item_date        := null;
            ln_exp_organization_id  := null;
            lv_project_accounting_context := null;
            lv_pa_addition_flag := null;


      -- Bug 5358788. Added by Lakshmi Gopalsami
      r_vat_regime_tax_type := null;

       -- added, Kunkumar for Bug#5593895
            ln_base_amount := null ;
            if tax_lines1_rec.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
              ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                                (
                                  p_invoice_id          =>   inv_id ,
                                  p_line_location_id    =>   null ,
                                  p_transaction_id      =>   rcv_tran_id  ,
                                  p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                                  p_tax_id              =>   tax_lines1_rec.tax_id
                                ) ;
            end if ;
            -- ended,Kunkumar for Bug#5593895

            OPEN  c_tax(tax_lines1_rec.tax_id);
            FETCH c_tax INTO c_tax_rec;
            CLOSE c_tax;

            /* Service Start */
            v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
            v_dist_code_combination_id := null;

            --initial the tax_type
            lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

            -- 5763527, Brathod
            -- Modified the if condition to consider partial recoverable lines previous logic was hadling only when it is 100

            if tax_lines1_rec.modvat_flag = 'Y'
            and nvl(c_tax_rec.mod_cr_percentage, 0) > 0 then

              --recoverable tax
              lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007

             /*  recoverable tax */
              v_assets_tracking_flag := 'N';

              open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
              fetch c_regime_tax_type into r_service_regime_tax_type;
              close c_regime_tax_type;

                fnd_file.put_line(FND_FILE.LOG,
                  ' Service regime: '||r_service_regime_tax_type.tax_type);

              /* Bug 5358788. Added by Lakshmi Gopalsami
         * Fetched the details of VAT regime
         */

              OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
                FETCH  c_regime_tax_type into r_vat_regime_tax_type;
              CLOSE  c_regime_tax_type;

            fnd_file.put_line(FND_FILE.LOG,
                       ' VAT regime: '||r_vat_regime_tax_type.tax_type);

              if r_service_regime_tax_type.tax_type is not null then
                /* Service type of tax */
                v_dist_code_combination_id := check_service_interim_account
                                              (
                                                lv_accrue_on_receipt_flag,
                                                lv_accounting_method_option,
                                                lv_is_item_an_expense,
                                                r_jai_regimes.regime_id,
                                                v_org_id,
                                                p_rematch,
                                                c_tax_rec.tax_type,
            po_dist_id  --Added by JMEENA for bug#6833506
                                              );
                 fnd_file.put_line(FND_FILE.LOG,
                  ' Regime type , CCID '
            || r_service_regime_tax_type.tax_type
            ||', ' || v_dist_code_combination_id);
               /* Bug 5358788. Added by Lakshmi Gopalsami
          * Commented p_rematch and added validation for
          * VAT regime.
          */
      /*following elsif block modified for bug 6595773*/
            ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
            -- p_rematch = 'PO_MATCHING' then

              v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
              fnd_file.put_line(FND_FILE.LOG,
                     ' Regime type , CCID '
         || r_vat_regime_tax_type.tax_type
               ||', ' || v_dist_code_combination_id);

              end if;

            else  /* 5763527 introduced for PROJETCS COSTING Impl */
              /* 5763527 */
              IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' THEN -- Bug 6338371
                ln_project_id           := p_project_id;
                ln_task_id              := p_task_id;
                lv_exp_type             := p_expenditure_type;
                ld_exp_item_date        := p_expenditure_item_date;
                ln_exp_organization_id  := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              END if;

              --non recoverable
              lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
            end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/

            /* Bug#4177452*/
            if v_dist_code_combination_id is null then
              v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
            end if;

            /* Bug#5763527 */
            Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.tax_type='||c_tax_rec.tax_type  ||',lv_excise_costing_flag='||lv_excise_costing_flag);
            if upper(c_tax_rec.tax_type) like  '%EXCISE%' then

              if lv_excise_costing_flag = 'Y' then
                IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' -- Bug 6338371
                then
                  ln_project_id           := p_project_id;
                  ln_task_id              := p_task_id;
                  lv_exp_type             := p_expenditure_type;
                  ld_exp_item_date        := p_expenditure_item_date;
                  ln_exp_organization_id  := p_expenditure_organization_id;
                  lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                  lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                END if;
                v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id;
              end if;
            end if;

            /* End# 5763527 */
            /* Service End */

              -- Start for bug#3752887
              v_tax_amount := tax_lines1_rec.tax_amount * v_apportn_factor_for_item_line;


              if for_org_id_rec.invoice_currency_code <> tax_lines1_rec.currency then
                v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
              end if;
              -- End for bug#3752887

            --
            -- Begin 5763527
            --
            ln_rec_tax_amt  := null;
            ln_nrec_tax_amt := null;
            ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

            --added by Eric for inclusive tax on 20-dec-2007,begin
            -------------------------------------------------------------------------------------
            --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
            --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
            --PR(partially recoverable) tax is processed in another logic

            IF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N'
                 OR ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                      AND p_project_id IS NULL
                    )
               )
            THEN
              ln_lines_to_insert := 1;
            ELSIF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                    AND p_project_id IS NOT NULL
                    AND lv_tax_type = 'RE'
                  )
            THEN
              ln_lines_to_insert := 2;
            END IF;--( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N' OR )
            -------------------------------------------------------------------------------------
            --added by Eric for inclusive tax on 20-dec-2007,end

            Fnd_File.put_line(Fnd_File.LOG, 'tax_lines1_rec.modvat_flag ='||tax_lines1_rec.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

            if tax_lines1_rec.modvat_flag = jai_constants.YES
            and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
            and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
            then
              --
              -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
              -- and instead of one line, two lines needs to be inserted.
              -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
              --
              ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
        ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
        ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
        /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */
              lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008

            end if;
            fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                            ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                            ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                             );

            --
            --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
            --  non recoverable tax amount and the second line will be for a recoverable tax amount
            --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
            --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
            --

            for line in 1..ln_lines_to_insert
            loop
              /* commented out by eric for inclusive tax
              if line = 1 then

                v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
                lv_modvat_flag := tax_lines1_rec.modvat_flag ;

              elsif line = 2 then

                v_tax_amount := ln_nrec_tax_amt;
                v_assets_tracking_flag := jai_constants.YES;
                lv_modvat_flag := jai_constants.NO ;

                --
                -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
                -- projects related columns so that PROJECTS can consider this line for Project Costing
                --
                IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' then -- Bug 6338371
                  ln_project_id           := p_project_id;
                  ln_task_id              := p_task_id;
                  lv_exp_type             := p_expenditure_type;
                  ld_exp_item_date        := p_expenditure_item_date;
                  ln_exp_organization_id  := p_expenditure_organization_id;
                  lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                  lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                END if;
                -- For non recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

              end if;
              */
              --
              -- End 5763527
              --

              --added by Eric for inclusive tax on 20-dec-2007,begin
              -------------------------------------------------------------------------------------
              IF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N')--exclusive case
              THEN
                IF line = 1 then

                  v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
                  lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
                  lv_modvat_flag := tax_lines1_rec.modvat_flag ;

                  lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
                ELSIF line = 2 then

                  v_tax_amount             := ln_nrec_tax_amt;
                  lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
                  lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


                  IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
                    v_assets_tracking_flag := jai_constants.YES;
                  END IF;

                  lv_modvat_flag := jai_constants.NO ;

                  --
                  -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
                  -- projects related columns so that PROJECTS can consider this line for Project Costing
                  --
                  IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
                    ln_project_id           := p_project_id;
                    ln_task_id              := p_task_id;
                    lv_exp_type             := p_expenditure_type;
                    ld_exp_item_date        := p_expenditure_item_date;
                    ln_exp_organization_id  := p_expenditure_organization_id;
                    lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                    lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
                  END if;

                  -- For non recoverable line charge account should be same as of the parent line
                  v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

                END IF; --line = 1
              ELSIF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y')       --inclusive case
              THEN
                IF( lv_tax_type ='PR')
                THEN
                  IF ( line = 1 )
                  THEN
                    --recoverable part
                    v_tax_amount       := ln_rec_tax_amt ;
                    lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                    lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
                    lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                    lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

                    --non recoverable part
                  ELSIF ( line = 2 )
                  THEN
                    v_tax_amount       := ln_nrec_tax_amt  ;
                    lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
                    lv_modvat_flag     := jai_constants.NO ;
                    lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
                    lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

                    --recoverable part without project infor
                  ELSIF ( line = 3 )
                  THEN
                    v_tax_amount                  := ln_rec_tax_amt;
                    lv_tax_line_amount            := NULL;

                    lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                    lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                    --Project information
                    ln_project_id                 := NULL;
                    ln_task_id                    := NULL;
                    lv_exp_type                   := NULL;
                    ld_exp_item_date              := NULL;
                    ln_exp_organization_id        := NULL;
                    lv_project_accounting_context := NULL;
                    lv_pa_addition_flag           := NULL;

                    -- For inclusive recoverable line charge account should be same as of the parent line
                    v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

                    --recoverable part in negative amount with project infor
                  ELSIF ( line = 4 )
                  THEN
                    v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
                    lv_tax_line_amount            := NULL;
                    lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                    lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                    --Project information
                    ln_project_id                 := p_project_id;
                    ln_task_id                    := p_task_id;
                    lv_exp_type                   := p_expenditure_type;
                    ld_exp_item_date              := p_expenditure_item_date;
                    ln_exp_organization_id        := p_expenditure_organization_id;
                    lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                    lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

                    -- For inclusive recoverable line charge account should be same as of the parent line
                    v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
                  END IF; --line = 1
                ELSIF ( lv_tax_type = 'RE'
                        AND p_project_id IS NOT NULL
                      )
                THEN
                  --recoverable tax without project infor
                  IF ( line = 1 )
                  THEN
                    v_tax_amount       :=  v_tax_amount  ;
                    lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
                    lv_modvat_flag     :=  tax_lines1_rec.modvat_flag ;
                    lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
                    lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

                    ln_project_id                 := NULL;
                    ln_task_id                    := NULL;
                    lv_exp_type                   := NULL;
                    ld_exp_item_date              := NULL;
                    ln_exp_organization_id        := NULL;
                    lv_project_accounting_context := NULL;
                    lv_pa_addition_flag           := NULL;
                    v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
                  --recoverable tax in negative amount with project infor
                  ELSIF ( line = 2 )
                  THEN
                    v_tax_amount       :=  v_tax_amount * -1;
                    lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
                    lv_modvat_flag     :=  tax_lines1_rec.modvat_flag  ;

                    ln_project_id                 := p_project_id;
                    ln_task_id                    := p_task_id;
                    lv_exp_type                   := p_expenditure_type;
                    ld_exp_item_date              := p_expenditure_item_date;
                    ln_exp_organization_id        := p_expenditure_organization_id;
                    lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                    lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                    v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
                  END IF;
                --  ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
                --  THEN
                ELSE -- eric removed the above criteria for bug 6888665 and 6888209
                  Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
                  --The case process the inclusive NR tax and inclusive RE tax not for project

                  lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                  lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
                  lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

                END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
              END IF; --(NVL(r_tax_lines_r ec.inc_tax_flag,'N') = 'N')
              -------------------------------------------------------------------------------------------
              --added by Eric for inclusive tax on 20-dec-2007,end

              --insert exclusive tax to the ap tables
              --or insert recoverable inclusive tax with project information the ap tables


              --1.Only exlusive taxes or inclusive taxes with project information
              --  are allowed to be inserted into Ap Lines and Dist Lines

              --2.All taxes need to be inserted into jai tax tables. Futher the
              --  partially recoverable tax need to be splitted into 2 lines

              --added by Eric for inclusive tax on 20-dec-2007,begin
              ------------------------------------------------------------------------
              IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
              THEN
                ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
              ---------------------------------------------------------------------------
              --added by Eric for inclusive tax on 20-dec-2007,end

                INSERT INTO ap_invoice_lines_all
                (
                  INVOICE_ID
                , LINE_NUMBER
                , LINE_TYPE_LOOKUP_CODE
                , DESCRIPTION
                , ORG_ID
                , MATCH_TYPE
    , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
                , ACCOUNTING_DATE
                , PERIOD_NAME
                , DEFERRED_ACCTG_FLAG
                , DEF_ACCTG_START_DATE
                , DEF_ACCTG_END_DATE
                , DEF_ACCTG_NUMBER_OF_PERIODS
                , DEF_ACCTG_PERIOD_TYPE
                , SET_OF_BOOKS_ID
                , AMOUNT
                , WFAPPROVAL_STATUS
                , CREATION_DATE
                , CREATED_BY
                , LAST_UPDATED_BY
                , LAST_UPDATE_DATE
                , LAST_UPDATE_LOGIN
                /* 5763527 */
                , project_id
                , task_id
                , expenditure_type
                , expenditure_item_date
                , expenditure_organization_id
                /* End 5763527 */
                ,po_distribution_id --Added for bug#6780154
                )
                VALUES
                (
                  inv_id
                , ln_inv_line_num
                , lv_misc
                , c_tax_rec.tax_name
                , v_org_id
                , lv_match_type
    , v_dist_code_combination_id
                , rec_max_ap_lines_all.accounting_date
                , rec_max_ap_lines_all.period_name
                , rec_max_ap_lines_all.deferred_acctg_flag
                , rec_max_ap_lines_all.def_acctg_start_date
                , rec_max_ap_lines_all.def_acctg_end_date
                , rec_max_ap_lines_all.def_acctg_number_of_periods
                , rec_max_ap_lines_all.def_acctg_period_type
                , rec_max_ap_lines_all.set_of_books_id
                , ROUND(v_tax_amount,ln_precision)
                , rec_max_ap_lines_all.wfapproval_status  -- Bug 4863208
                , sysdate
                , ln_user_id
                , ln_user_id
                , sysdate
                , ln_login_id
                /* 5763527 */
                , ln_project_id
                , ln_task_id
                , lv_exp_type
                , ld_exp_item_date
                , ln_exp_organization_id
          ,po_dist_id --Added for bug#6780154
                );


                -- Start bug#3332988
                open c_get_invoice_distribution;
                fetch c_get_invoice_distribution into v_invoice_distribution_id;
                close c_get_invoice_distribution;
                -- End bug#3332988
                fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

                INSERT INTO ap_invoice_distributions_all
                (
                accounting_date,
                accrual_posted_flag,
                assets_addition_flag,
                assets_tracking_flag,
                cash_posted_flag,
                distribution_line_number,
                dist_code_combination_id,
                invoice_id,
                last_updated_by,
                last_update_date,
                line_type_lookup_code,
                period_name,
                set_of_books_id,
                amount,
                base_amount,
                batch_id,
                created_by,
                creation_date,
                description,
                last_update_login,
                match_status_flag,
                posted_flag,
                rate_var_code_combination_id,
                reversal_flag,
                program_application_id,
                program_id,
                program_update_date,
                accts_pay_code_combination_id,
                invoice_distribution_id,
                quantity_invoiced,
                org_id,
                po_distribution_id ,
                rcv_transaction_id,
                matched_uom_lookup_code,
                invoice_line_number
                -- Bug 5401111. Added by Lakshmi Gopalsami
                ,charge_applicable_to_dist_id --5763527
                , project_id
                , task_id
                , expenditure_type
                , expenditure_item_date
                , expenditure_organization_id
                , project_accounting_context
                , pa_addition_flag
               -- Bug 7249100. Added by Lakshmi Gopalsami
                ,distribution_class
        ,asset_book_type_code /* added for bug 8406404 by vumaasha */
                )
                VALUES
                (
                rec_max_ap_lines_all.accounting_date,
                'N', --for_dist_insertion_rec.accrual_posted_flag,
                for_dist_insertion_rec.assets_addition_flag,
                v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug#2851123
                'N',
                v_distribution_no,
                v_dist_code_combination_id,
                inv_id,
                ln_user_id,
                SYSDATE,
                lv_misc,
                rec_max_ap_lines_all.period_name,
                rec_max_ap_lines_all.set_of_books_id,
                round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
                ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision), --
                v_batch_id,
                ln_user_id,
                SYSDATE,
                c_tax_rec.tax_name,
                ln_login_id,
                for_dist_insertion_rec.match_status_flag , -- Bug 4863208
                'N',
                NULL,
                for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
                for_dist_insertion_rec.program_application_id,
                for_dist_insertion_rec.program_id,
                for_dist_insertion_rec.program_update_date,
                for_dist_insertion_rec.accts_pay_code_combination_id,
                v_invoice_distribution_id, -- BUG#3332988 ap_invoice_distributions_s.NEXTVAL,
               decode(v_assets_tracking_flag, 'Y', NULL, 0),/* Modified for bug 8406404 by vumaasha */
                for_dist_insertion_rec.org_id, -- Bug 4863208
                po_dist_id ,
                rcv_tran_id,
                for_dist_insertion_rec.matched_uom_lookup_code,
                ln_inv_line_num
                /* Bug 5361931. Added by Lakshmi Gopalsami
                 * Passed ln_inv_line_num instead of
                 * pn_invoice_line_number
                 */
                 -- Bug 5401111. Added by Lakshmi Gopalsami
                 ,decode(v_assets_tracking_flag,'N',
                         NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
                /* 5763527 */
                , ln_project_id
                , ln_task_id
                , lv_exp_type
                , ld_exp_item_date
                , ln_exp_organization_id
                , lv_project_accounting_context
                , lv_pa_addition_flag
                -- Bug 7249100. Added by Lakshmi Gopalsami
               ,lv_dist_class
        , decode(v_assets_tracking_flag,'Y',for_dist_insertion_rec.asset_book_type_code,NULL) /* added for bug 8406404 by vumaasha */
                );
              --added by Eric for inclusive tax on 20-dec-2007,begin
              -------------------------------------------------------------
              END IF; --( NVL(r_tax_lines_rec.inc_tax_flag,'N') = 'N' or )
              -------------------------------------------------------------
              --added by Eric for inclusive tax on 20-dec-2007,end


              OPEN c_tax_curr_prec( tax_lines1_rec.tax_id ) ;
              FETCH c_tax_curr_prec INTO ln_tax_precision ;
              CLOSE c_tax_curr_prec ;

              --added by Eric for inclusive tax on 20-dec-2007,begin
              -----------------------------------------------------------------
              IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
              THEN
              -----------------------------------------------------------------
              --added by Eric for inclusive tax on 20-dec-2007,end

                INSERT INTO JAI_AP_MATCH_INV_TAXES
                (
                tax_distribution_id,
                exchange_rate_variance,
                assets_tracking_flag,
                invoice_id,
                po_header_id,
                po_line_id,
                line_location_id,
                set_of_books_id,
                --org_id,
                exchange_rate,
                exchange_rate_type,
                exchange_date,
                currency_code,
                code_combination_id,
                last_update_login,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                acct_pay_code_combination_id,
                accounting_date,
                tax_id,
                tax_amount,
                base_amount,
                chart_of_accounts_id,
                distribution_line_number,
                --project_id,
                --task_id,
                po_distribution_id,  -- added  by bug#3038566
                parent_invoice_distribution_id,  -- added  by bug#3038566
                legal_entity_id -- added by rallamse bug#
                ,INVOICE_LINE_NUMBER  -- Added by Brathod, Bug# 4445989
                ,INVOICE_DISTRIBUTION_ID -------|
                ,PARENT_INVOICE_LINE_NUMBER-----|
                ,RCV_TRANSACTION_ID
                ,LINE_TYPE_LOOKUP_CODE
                , recoverable_flag -- 5763527
                ,line_no            -- Bug 5553150

                )
                VALUES
                (
                JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
                null,--kunkumar for forward porting to R12
                v_assets_tracking_flag , -- 'N', bug#2851123
                inv_id,
                cur_items_rec.po_header_id,
                cur_items_rec.po_line_id,
                cur_items_rec.line_location_id,
                cur_items_rec.set_of_books_id,
                --cur_items_rec.org_id,
                cur_items_rec.rate,
                cur_items_rec.rate_type,
                cur_items_rec.rate_date,
                cur_items_rec.currency_code,
                /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
                 * c_tax_rec.tax_account_id and v_dist_code_combination_id
                */
                v_dist_code_combination_id,
                cur_items_rec.last_update_login,
                cur_items_rec.creation_date,
                cur_items_rec.created_by,
                cur_items_rec.last_update_date,
                cur_items_rec.last_updated_by,
                v_dist_code_combination_id,
                cur_items_rec.invoice_date,
                tax_lines1_rec.tax_id,
                /*commented out by eric for inclusive tax
                round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
                */
                ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
                nvl(ln_base_amount,ROUND(ROUND(tax_lines1_rec.tax_amount,ln_tax_precision), ln_precision)), --Modified by kunkumar for Bug#5593895
                caid,
                v_distribution_no,
                --p_project_id,
                --p_task_id,
                po_dist_id, -- added  by bug#3038566
                for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
                get_ven_info_rec.legal_entity_id -- added by rallamse bug#
                --ln_inv_line_num,deleted by Eric for inclusive tax
                --, v_invoice_distribution_id,deleted by Eric for inclusive tax

                --added by Eric for inclusive tax on 20-dec-2007,begin
                ----------------------------------------------------------------
                , DECODE ( NVL(tax_lines1_rec.inc_tax_flag,'N')
                         , 'N',ln_inv_line_num
                         , 'Y',pn_invoice_line_number
                         )
               , NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
                -----------------------------------------------------------------
                --added by Eric for inclusive tax on 20-dec-2007,end

                , pn_invoice_line_number
                , rcv_tran_id
                , lv_misc
                , lv_modvat_flag -- 5763527
                , tax_lines1_rec.tax_line_no  -- added, Harshita for Bug 5553150
                );
             --added by Eric for inclusive tax on 20-dec-2007,begin
             -----------------------------------------------------------------
             END IF;--  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
             -----------------------------------------------------------------
             --added by Eric for inclusive tax on 20-dec-2007,end



              /*  Bug 46863208. Added by Lakshmi Gopalsami
             Commented the MRC call
              insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
              */

              /* Commented out by Eric for bug 8345512 on 13-Jul-2009

                cum_tax_amt := cum_tax_amt + round(v_tax_amount, ln_precision)
              */

              --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
              ------------------------------------------------------------------
              IF NVL(tax_lines1_rec.inc_tax_flag,'N') ='N'
              THEN
                cum_tax_amt := cum_tax_amt + round(v_tax_amount, ln_precision);  -- ROUND(v_tax_amount, 2),bug#2567799
              END IF;
             ------------------------------------------------------------------
             --Modified by Eric for bug 8345512 on 13-Jul-2009,end

              /* Obsoleted as part of R12 , Bug# 4445989
              INSERT INTO JAI_CMN_FA_INV_DIST_ALL
              (
              invoice_id,
              invoice_distribution_id,
              set_of_books_id,
              batch_id,
              po_distribution_id,
              rcv_transaction_id,
              dist_code_combination_id,
              accounting_date,
              assets_addition_flag,
              assets_tracking_flag,
              distribution_line_number,
              line_type_lookup_code,
              amount,
              description,
              match_status_flag,
              quantity_invoiced
              )
              VALUES
              (
              inv_id,
              ap_invoice_distributions_s.CURRVAL,
              for_dist_insertion_rec.set_of_books_id,
              v_batch_id,
              for_dist_insertion_rec.po_distribution_id,
              rcv_tran_id,
              v_dist_code_combination_id,
              for_dist_insertion_rec.accounting_date,
              for_dist_insertion_rec.assets_addition_flag,
              v_assets_tracking_flag , -- for_dist_insertion_rec.assets_tracking_flag, bug#2851123
              v_distribution_no,
              'MISCELLANEOUS',
              round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
              c_tax_rec.tax_name,
              NULL,
              NULL
              ); */

              END LOOP; --> for line in ... 5763527
        END LOOP; --tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)

        v_update_payment_schedule:=update_payment_schedule(cum_tax_amt); -- bug#3218978

--        cum_tax_amt := round(cum_Tax_amt,ln_precision);
        UPDATE  ap_invoices_all
        SET   invoice_amount = invoice_amount   + cum_tax_amt,
            approved_amount = approved_amount  + cum_tax_amt,
            pay_curr_invoice_amount =  pay_curr_invoice_amount + cum_tax_amt,
            amount_applicable_to_discount =  amount_applicable_to_discount + cum_tax_amt,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
        WHERE  invoice_id = inv_id;

        -- start added for bug#3354932
        if for_org_id_rec.invoice_currency_code <> v_functional_currency then
          -- invoice currency is not the functional currency.
          update ap_invoices_all
          set    base_amount = invoice_amount  * exchange_rate
          where  invoice_id = inv_id;
        end if;
        -- end added for bug#3354932

     /* Bug 4863208. Added by Lakshmi Gopalsami
         Commented the MRC call
        update_mrc_data; -- bug#3332988
     */


      ELSIF p_receipt_code = 'PACKING_SLIP' THEN  -- IF p_receipt_code  = 'RECEIPT' THEN


        OPEN count_dist_no(inv_id);
        FETCH count_dist_no INTO count_dist_no_rec;
        CLOSE count_dist_no;

        v_distribution_no := nvl(count_dist_no_rec, 0);


        FOR tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP

           -- Added by Brathod for Bug# 4445989
           /* v_distribution_no := v_distribution_no + 1; */
           v_distribution_no :=1;
           -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527, moved the increment to just before the insert statement
           -- End Bug# 4445989

          r_service_regime_tax_type := null;

          /* 5763527 */
          ln_project_id           := null;
          ln_task_id              := null;
          lv_exp_type             := null;
          ld_exp_item_date        := null;
          ln_exp_organization_id  := null;
          lv_project_accounting_context := null;
          lv_pa_addition_flag := null;


    -- Bug 5358788. Added by Lakshmi Gopalsami
    r_vat_regime_tax_type := null;

          -- added, Kunkumar for bug#5593895
          ln_base_amount := null ;
          if tax_lines1_rec.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
            ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                              (
                                p_invoice_id          =>   inv_id ,
                                p_line_location_id    =>   null ,
                                p_transaction_id      =>   rcv_tran_id  ,
                                p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                                p_tax_id              =>   tax_lines1_rec.tax_id
                              ) ;
          end if ;
          -- ended, Kunkumar for bug#5593895
          OPEN  c_tax(tax_lines1_rec.tax_id);
          FETCH c_tax INTO c_tax_rec;
          CLOSE c_tax;

          /* Service Start */
          v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
          v_dist_code_combination_id := null;


          --initial the tax_type
          lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

          if tax_lines1_rec.modvat_flag = 'Y'
          and nvl(c_tax_rec.mod_cr_percentage, 0) > 0 then -- 5763527

            --recoverable tax
            lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007

           /*  recoverable tax */
            v_assets_tracking_flag := 'N';

            open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
            fetch c_regime_tax_type into r_service_regime_tax_type;
            close c_regime_tax_type;

            fnd_file.put_line(FND_FILE.LOG,
                   ' Service regime: '||r_service_regime_tax_type.tax_type);

            /* Bug 5358788. Added by Lakshmi Gopalsami
       * Fetched the details of VAT regime
       */

            OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
              FETCH  c_regime_tax_type INTO  r_vat_regime_tax_type;
            CLOSE  c_regime_tax_type;

            fnd_file.put_line(FND_FILE.LOG,
                   ' VAT regime: '||r_vat_regime_tax_type.tax_type);

            if r_service_regime_tax_type.tax_type is not null then
              /* Service type of tax */
              v_dist_code_combination_id := check_service_interim_account
                                            (
                                              lv_accrue_on_receipt_flag,
                                              lv_accounting_method_option,
                                              lv_is_item_an_expense,
                                              r_jai_regimes.regime_id,
                                              v_org_id,
                                              p_rematch,
                                              c_tax_rec.tax_type,
                po_dist_id  --Added by JMEENA for bug#6833506
                                            );
               fnd_file.put_line(FND_FILE.LOG,
                 ' Regime type , CCID '
     || r_service_regime_tax_type.tax_type
           ||', ' || v_dist_code_combination_id);

               /* Bug 5358788. Added by Lakshmi Gopalsami
          * Commented p_rematch and added validation for
    * VAT regime.
    */
    /*following elsif block modified for bug 6595773*/
             ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
           --p_rematch = 'PO_MATCHING' then

               v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
         fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_vat_regime_tax_type.tax_type
       ||', ' || v_dist_code_combination_id);

            end if;

          else  /* 5763527 introduced for PROJETCS COSTING Impl */
            /* 5763527 */
            IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' THEN -- Bug 6338371
              ln_project_id           := p_project_id;
              ln_task_id              := p_task_id;
              lv_exp_type             := p_expenditure_type;
              ld_exp_item_date        := p_expenditure_item_date;
              ln_exp_organization_id  := p_expenditure_organization_id;
              lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
              lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
            END if;

            --non recoverable
            lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
          end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/

          /* Bug#4177452*/
          if v_dist_code_combination_id is null then
            v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
          end if;


          /* Bug#5763527 */
          Fnd_File.put_line(Fnd_File.LOG, 'c_tax_rec.tax_type='||c_tax_rec.tax_type  ||',lv_excise_costing_flag='||lv_excise_costing_flag);
          if upper(c_tax_rec.tax_type) like  '%EXCISE%' then

            if lv_excise_costing_flag = 'Y' THEN
              IF nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' THEN -- Bug 6338371
                ln_project_id           := p_project_id;
                ln_task_id              := p_task_id;
                lv_exp_type             := p_expenditure_type;
                ld_exp_item_date        := p_expenditure_item_date;
                ln_exp_organization_id  := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              END if;
              v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id;
            end if;
          end if;
          /* End# 5763527 */

          /* Service End */

          -- Start for bug#3752887
          v_tax_amount := tax_lines1_rec.tax_amount * v_apportn_factor_for_item_line;


          if for_org_id_rec.invoice_currency_code <> tax_lines1_rec.currency then
            v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
          end if;
          -- End for bug#3752887

          --
          -- Begin 5763527
          --
          ln_rec_tax_amt  := null;
          ln_nrec_tax_amt := null;
          ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

          --added by Eric for inclusive tax on 20-dec-2007,begin
          -------------------------------------------------------------------------------------
          --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
          --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
          --PR(partially recoverable) tax is processed in another logic

          IF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N'
               OR ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                    AND p_project_id IS NULL
                  )
             )
          THEN
            ln_lines_to_insert := 1;
          ELSIF ( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y'
                  AND p_project_id IS NOT NULL
                  AND lv_tax_type = 'RE'
                )
          THEN
            ln_lines_to_insert := 2;
          END IF;--( NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N' OR )
          -------------------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end



          Fnd_File.put_line(Fnd_File.LOG, 'tax_lines1_rec.modvat_flag ='||tax_lines1_rec.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

          if tax_lines1_rec.modvat_flag = jai_constants.YES
          and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
          and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
          then
            --
            -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
            -- and instead of one line, two lines needs to be inserted.
            -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
            --
            ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
            ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
            ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
        /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */

            lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008
          end if;
          fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                          ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                          ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                           );

          --
          --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
          --  non recoverable tax amount and the second line will be for a recoverable tax amount
          --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
          --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
          --

          for line in 1..ln_lines_to_insert
          loop

            --deleted by Eric for inclusive tax on 20-dec-2007,begin
            -------------------------------------------------------------------------------------
            /* commented out by eric for inclusive tax
            if line = 1 then

              v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
              lv_modvat_flag := tax_lines1_rec.modvat_flag ;

            elsif line = 2 then

              v_tax_amount := ln_nrec_tax_amt;
              v_assets_tracking_flag := jai_constants.YES;
              lv_modvat_flag := jai_constants.NO ;
              --
              -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
              -- projects related columns so that PROJECTS can consider this line for Project Costing
              --
              IF  nvl(lv_accrue_on_receipt_flag , '#') <> 'Y' then-- Bug 6338371
                ln_project_id           := p_project_id;
                ln_task_id              := p_task_id;
                lv_exp_type             := p_expenditure_type;
                ld_exp_item_date        := p_expenditure_item_date;
                ln_exp_organization_id  := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
              END IF;
              -- For non recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

            end if;

            --ln_inv_line_num := ln_inv_line_num + 1;
            -- End 5763527
            --
            */
            -------------------------------------------------------------------------------------
            --deleted by Eric for inclusive tax on 20-dec-2007,end

            --added by Eric for inclusive tax on 20-dec-2007,begin
            -------------------------------------------------------------------------------------
            IF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'N')--exclusive case
            THEN
              IF line = 1 then

                v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
                lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
                lv_modvat_flag := tax_lines1_rec.modvat_flag ;

                lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
              ELSIF line = 2 then

                v_tax_amount             := ln_nrec_tax_amt;
                lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
                lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


                IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
                  v_assets_tracking_flag := jai_constants.YES;
                END IF;

                lv_modvat_flag := jai_constants.NO ;

                --
                -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
                -- projects related columns so that PROJECTS can consider this line for Project Costing
                --
                IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
                  ln_project_id           := p_project_id;
                  ln_task_id              := p_task_id;
                  lv_exp_type             := p_expenditure_type;
                  ld_exp_item_date        := p_expenditure_item_date;
                  ln_exp_organization_id  := p_expenditure_organization_id;
                  lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                  lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
                END if;

                -- For non recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

              END IF; --line = 1
            ELSIF (NVL(tax_lines1_rec.inc_tax_flag,'N') = 'Y')       --inclusive case
            THEN
              IF( lv_tax_type ='PR')
              THEN
                IF ( line = 1 )
                THEN
                  --recoverable part
                  v_tax_amount       := ln_rec_tax_amt ;
                  lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                  lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
                  lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

                  --non recoverable part
                ELSIF ( line = 2 )
                THEN
                  v_tax_amount       := ln_nrec_tax_amt  ;
                  lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
                  lv_modvat_flag     := jai_constants.NO ;
                  lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

                  --recoverable part without project infor
                ELSIF ( line = 3 )
                THEN
                  v_tax_amount                  := ln_rec_tax_amt;
                  lv_tax_line_amount            := NULL;

                  lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                  --Project information
                  ln_project_id                 := NULL;
                  ln_task_id                    := NULL;
                  lv_exp_type                   := NULL;
                  ld_exp_item_date              := NULL;
                  ln_exp_organization_id        := NULL;
                  lv_project_accounting_context := NULL;
                  lv_pa_addition_flag           := NULL;

                  -- For inclusive recoverable line charge account should be same as of the parent line
                  v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

                  --recoverable part in negative amount with project infor
                ELSIF ( line = 4 )
                THEN
                  v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
                  lv_tax_line_amount            := NULL;
                  lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                  --Project information
                  ln_project_id                 := p_project_id;
                  ln_task_id                    := p_task_id;
                  lv_exp_type                   := p_expenditure_type;
                  ld_exp_item_date              := p_expenditure_item_date;
                  ln_exp_organization_id        := p_expenditure_organization_id;
                  lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                  lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

                  -- For inclusive recoverable line charge account should be same as of the parent line
                  v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
                END IF; --line = 1
              ELSIF ( lv_tax_type = 'RE'
                      AND p_project_id IS NOT NULL
                    )
              THEN
                --recoverable tax without project infor
                IF ( line = 1 )
                THEN
                  v_tax_amount       :=  v_tax_amount  ;
                  lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
                  lv_modvat_flag     :=  tax_lines1_rec.modvat_flag ;
                  lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
                  lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

                  ln_project_id                 := NULL;
                  ln_task_id                    := NULL;
                  lv_exp_type                   := NULL;
                  ld_exp_item_date              := NULL;
                  ln_exp_organization_id        := NULL;
                  lv_project_accounting_context := NULL;
                  lv_pa_addition_flag           := NULL;
                  v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
                --recoverable tax in negative amount with project infor
                ELSIF ( line = 2 )
                THEN
                  v_tax_amount       :=  v_tax_amount * -1;
                  lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
                  lv_modvat_flag     :=  tax_lines1_rec.modvat_flag  ;

                  ln_project_id                 := p_project_id;
                  ln_task_id                    := p_task_id;
                  lv_exp_type                   := p_expenditure_type;
                  ld_exp_item_date              := p_expenditure_item_date;
                  ln_exp_organization_id        := p_expenditure_organization_id;
                  lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                  lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                  v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
                END IF;
              --ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
              --THEN
              ELSE -- eric removed the above criteria for bug 6888665 and 6888209
                Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
                --The case process the inclusive NR tax and inclusive RE tax not for project

                lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                lv_modvat_flag     := tax_lines1_rec.modvat_flag  ;
                lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

              END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
            END IF; --(NVL(r_tax_lines_r ec.inc_tax_flag,'N') = 'N')
            -------------------------------------------------------------------------------------------
            --added by Eric for inclusive tax on 20-dec-2007,end





          fnd_file.put_line(fnd_file.log, 'line='||line||', v_tax_amount='|| v_tax_amount
                                          ||'lv_modvat_flag='||lv_modvat_flag
                                          ||'v_assets_tracking_flag='||v_assets_tracking_flag
                              );



          --insert exclusive tax to the ap tables
          --or insert recoverable inclusive tax with project information the ap tables


          --1.Only exlusive taxes or inclusive taxes with project information
          --  are allowed to be inserted into Ap Lines and Dist Lines

          --2.All taxes need to be inserted into jai tax tables. Futher the
          --  partially recoverable tax need to be splitted into 2 lines

          --added by Eric for inclusive tax on 20-dec-2007,begin
          ------------------------------------------------------------------------
          IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
          THEN
            ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
          ---------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end


            INSERT INTO ap_invoice_lines_all
            (
              INVOICE_ID
            , LINE_NUMBER
            , LINE_TYPE_LOOKUP_CODE
            , DESCRIPTION
            , ORG_ID
            , MATCH_TYPE
      , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
            , ACCOUNTING_DATE
            , PERIOD_NAME
            , DEFERRED_ACCTG_FLAG
            , DEF_ACCTG_START_DATE
            , DEF_ACCTG_END_DATE
            , DEF_ACCTG_NUMBER_OF_PERIODS
            , DEF_ACCTG_PERIOD_TYPE
            , SET_OF_BOOKS_ID
            , AMOUNT
            , WFAPPROVAL_STATUS
            , CREATION_DATE
            , CREATED_BY
            , LAST_UPDATED_BY
            , LAST_UPDATE_DATE
            , LAST_UPDATE_LOGIN
            /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
      ,po_distribution_id --Added for bug#6780154
            )
            VALUES
            (
                inv_id
              , ln_inv_line_num
              , lv_misc
              , c_tax_rec.tax_name
              , v_org_id
              , lv_match_type
        , v_dist_code_combination_id
              , rec_max_ap_lines_all.accounting_date
              , rec_max_ap_lines_all.period_name
              , rec_max_ap_lines_all.deferred_acctg_flag
              , rec_max_ap_lines_all.def_acctg_start_date
              , rec_max_ap_lines_all.def_acctg_end_date
              , rec_max_ap_lines_all.def_acctg_number_of_periods
              , rec_max_ap_lines_all.def_acctg_period_type
              , rec_max_ap_lines_all.set_of_books_id
              , ROUND(v_tax_amount,ln_precision)
              , rec_max_ap_lines_all.wfapproval_status  -- Bug 4863208
              , sysdate
              , ln_user_id
              , ln_user_id
              , sysdate
              , ln_login_id
              /* 5763527 */
              , ln_project_id
              , ln_task_id
              , lv_exp_type
              , ld_exp_item_date
              , ln_exp_organization_id
        ,po_dist_id --Added for bug#6780154
            );


            -- Start bug#3332988
            open c_get_invoice_distribution;
            fetch c_get_invoice_distribution into v_invoice_distribution_id;
            close c_get_invoice_distribution;
            -- End bug#3332988
            fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

            INSERT INTO ap_invoice_distributions_all
            (
            accounting_date,
            accrual_posted_flag,
            assets_addition_flag,
            assets_tracking_flag,
            cash_posted_flag,
            distribution_line_number,
            dist_code_combination_id,
            invoice_id,
            last_updated_by,
            last_update_date,
            line_type_lookup_code,
            period_name,
            set_of_books_id,
            amount,
            base_amount,
            batch_id,
            created_by,
            creation_date,
            description,
             exchange_rate_variance,
            last_update_login,
            match_status_flag,
            posted_flag,
            rate_var_code_combination_id,
            reversal_flag,
            program_application_id,
            program_id,
            program_update_date,
            accts_pay_code_combination_id,
            invoice_distribution_id,
            quantity_invoiced,
            org_id,
            po_distribution_id ,
            rcv_transaction_id,
            matched_uom_lookup_code,
            invoice_line_number
            ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
            /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
            , project_accounting_context
            , pa_addition_flag
            -- Bug 7249100. Added by Lakshmi Gopalsami
            ,distribution_class
      ,asset_book_type_code /* added for bug 8406404 by vumaasha */
            )
            VALUES
            (
            rec_max_ap_lines_all.accounting_date,
            'N', --for_dist_insertion_rec.accrual_posted_flag,
            for_dist_insertion_rec.assets_addition_flag,
            v_assets_tracking_flag ,
            'N',
            v_distribution_no,
            v_dist_code_combination_id,
            inv_id,
            ln_user_id,
            sysdate,
            lv_misc,
            rec_max_ap_lines_all.period_name,
            rec_max_ap_lines_all.set_of_books_id,
            round(v_tax_amount,ln_precision),
            ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision),
            v_batch_id,
            ln_user_id,
            sysdate,
            c_tax_rec.tax_name,
              null,--kunkumar for forward porting to R12
            ln_login_id,
            for_dist_insertion_rec.match_status_flag , -- Bug 4863208
            'N',
            NULL,
            for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
            for_dist_insertion_rec.program_application_id,
            for_dist_insertion_rec.program_id,
            for_dist_insertion_rec.program_update_date,
            for_dist_insertion_rec.accts_pay_code_combination_id,
            v_invoice_distribution_id,
            decode(v_assets_tracking_flag, 'Y', NULL, 0), /* Modified for bug 8406404 by vumaasha */
            for_dist_insertion_rec.org_id,  -- bug 4863208
            po_dist_id ,
            rcv_tran_id,
            for_dist_insertion_rec.matched_uom_lookup_code,
            ln_inv_line_num
            /* Bug 5361931. Added by Lakshmi Gopalsami
             * Passed ln_inv_line_num instead of
             * pn_invoice_line_number
             */
            -- Bug 5401111. Added by Lakshmi Gopalsami
            ,decode(v_assets_tracking_flag,'N',
                    NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
            /* 5763527 */
            , ln_project_id
            , ln_task_id
            , lv_exp_type
            , ld_exp_item_date
            , ln_exp_organization_id
            , lv_project_accounting_context
            , lv_pa_addition_flag
            -- Bug 7249100. Added by Lakshmi Gopalsami
            , lv_dist_class
      , decode(v_assets_tracking_flag,'Y',for_dist_insertion_rec.asset_book_type_code,NULL) /* added for bug 8406404 by vumaasha */
            );
          --added by Eric for inclusive tax on 20-dec-2007,begin
          ------------------------------------------------------------
          END IF; --( NVL(lv_ap_line_to_inst_flag,'N')='Y') )
          ------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

          /*Added by kunkumar for Bug#5593895*/
          OPEN c_tax_curr_prec( tax_lines1_rec.tax_id ) ;
          FETCH c_tax_curr_prec INTO ln_tax_precision ;
          CLOSE c_tax_curr_prec ;
          /*End, Added by kunkumar for bug#5593895*/


          --added by Eric for inclusive tax on 20-dec-2007,begin
          -----------------------------------------------------------------
          IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
          THEN
          -----------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

            INSERT INTO JAI_AP_MATCH_INV_TAXES
            (
            tax_distribution_id,
            exchange_rate_variance,
            assets_tracking_flag,
            invoice_id,
            po_header_id,
            po_line_id,
            line_location_id,
            set_of_books_id,
            --org_id,
            exchange_rate,
            exchange_rate_type,
            exchange_date,
            currency_code,
            code_combination_id,
            last_update_login,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            acct_pay_code_combination_id,
            accounting_date,
            tax_id,
            tax_amount,
            base_amount,
            chart_of_accounts_id,
            distribution_line_number,
            --project_id,
            --task_id,
            po_distribution_id,  -- added  by bug#3038566
            parent_invoice_distribution_id,  -- added  by bug#3038566
            legal_entity_id -- added by rallamse bug#
            ,INVOICE_LINE_NUMBER  --    Added by Brathod, Bug# 4445989
            ,INVOICE_DISTRIBUTION_ID ------------|
            ,PARENT_INVOICE_LINE_NUMBER----------|
            ,RCV_TRANSACTION_ID
            ,LINE_TYPE_LOOKUP_CODE
            /* 5763527*/
            , recoverable_flag
            , line_no                          -- added, Harshita for Bug 5553150
            /* End 5763527 */
            )
            VALUES
            (
            JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
            null,--kunkumar for forward porting to R12
            v_assets_tracking_flag , -- 'N', bug#2851123
            inv_id,
            cur_items_rec.po_header_id,
            cur_items_rec.po_line_id,
            cur_items_rec.line_location_id,
            cur_items_rec.set_of_books_id,
            --cur_items_rec.org_id,
            cur_items_rec.rate,
            cur_items_rec.rate_type,
            cur_items_rec.rate_date,
            cur_items_rec.currency_code,
            /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
                   * c_tax_rec.tax_account_id and v_dist_code_combination_id
             */
            v_dist_code_combination_id,
            cur_items_rec.last_update_login,
            cur_items_rec.creation_date,
            cur_items_rec.created_by,
            cur_items_rec.last_update_date,
            cur_items_rec.last_updated_by,
            v_dist_code_combination_id,
            cur_items_rec.invoice_date,
            tax_lines1_rec.tax_id,
            /*commented out by eric for inclusive tax
            round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
            */
            ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
            nvl(ln_base_amount,ROUND(ROUND(tax_lines1_rec.tax_amount,ln_tax_precision), ln_precision)), --Kunkumar for Bug#5593895
            caid,
            v_distribution_no,
            --p_project_id,
            --p_task_id,
            po_dist_id, -- added  by bug#3038566
            for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
            get_ven_info_rec.legal_entity_id -- added by rallamse bug#
            -- ln_inv_line_num, deleted by Eric for inclusive tax
            --, v_invoice_distribution_id ,deleted by Eric for inclusive tax on 20-dec-2007
            --added by Eric for inclusive tax on 20-dec-2007,begin
            ---------------------------------------------------------------
            , DECODE ( NVL( tax_lines1_rec.inc_tax_flag,'N')
                     , 'N',ln_inv_line_num
                     , 'Y',pn_invoice_line_number
                     )
            , NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
            ---------------------------------------------------------------
            --added by Eric for inclusive tax on 20-dec-2007,end
            , pn_invoice_line_number
            , rcv_tran_id
            , lv_misc
            /* 5763527*/
            , lv_modvat_flag
            , tax_lines1_rec.tax_line_no  -- added, Harshita for Bug 5553150
            /* End of 5763527 */
            );


            /*  Bug 46863208. Added by Lakshmi Gopalsami
            Commented the MRC call
            insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
            */
            --cum_tax_amt stores total exclusive amount
            /* commented out by Eric for bug 8345512 on 13-Jul-2009
               cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
            */

            --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
            ------------------------------------------------------------------
            IF NVL(tax_lines1_rec.inc_tax_flag,'N') ='N'
            THEN
              cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
            END IF;
            ------------------------------------------------------------------
            --Modified by Eric for bug 8345512 on 13-Jul-2009,end
            /* Obsoleted as part of R12 , Bug# 4445989
            INSERT INTO JAI_CMN_FA_INV_DIST_ALL
            (
            invoice_id,
            invoice_distribution_id,
            set_of_books_id,
            batch_id,
            po_distribution_id,
            rcv_transaction_id,
            dist_code_combination_id,
            accounting_date,
            assets_addition_flag,
            assets_tracking_flag,
            distribution_line_number,
            line_type_lookup_code,
            amount,
            description,
            match_status_flag,
            quantity_invoiced
            )
            VALUES
            (
            inv_id,
            ap_invoice_distributions_s.CURRVAL,
            for_dist_insertion_rec.set_of_books_id,
            v_batch_id,
            for_dist_insertion_rec.po_distribution_id,
            rcv_tran_id,
            v_dist_code_combination_id,
            for_dist_insertion_rec.accounting_date,
            for_dist_insertion_rec.assets_addition_flag,
            v_assets_tracking_flag, -- for_dist_insertion_rec.assets_tracking_flag, bug#2851123
            v_distribution_no,
            'MISCELLANEOUS',
            round(v_tax_amount,ln_precision), -- ROUND(v_tax_amount, 2), by Aparajita bug#2567799
            c_tax_rec.tax_name,
            NULL,
            NULL
            );
            */
            --added by Eric for inclusive tax on 20-dec-2007,begin
            -----------------------------------------------------------------
            END IF;--  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
            -----------------------------------------------------------------
            --added by Eric for inclusive tax on 20-dec-2007,end


          end loop; --> for line in ... 5763527
        END LOOP; --tax_lines1_rec IN tax_lines1_cur(rcv_tran_id,for_org_id_rec.vendor_id)  LOOP

        v_update_payment_schedule:=update_payment_schedule(cum_tax_amt); -- added by bug 321978.

--        cum_tax_amt := round(cum_tax_amt,ln_precision);
        UPDATE  ap_invoices_all
        SET     invoice_amount = invoice_amount   + cum_tax_amt,
            approved_amount      =  approved_amount  + cum_tax_amt,
            pay_curr_invoice_amount =  pay_curr_invoice_amount + cum_tax_amt,
            amount_applicable_to_discount =  amount_applicable_to_discount + cum_tax_amt,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
        WHERE  invoice_id = inv_id;

        -- start added for bug#3354932
        if for_org_id_rec.invoice_currency_code <> v_functional_currency then
          update ap_invoices_all
          set    base_amount = invoice_amount  * exchange_rate
          where  invoice_id = inv_id;
        end if;
        -- end added for bug#3354932

     /* Bug 4863208. Added by Lakshmi Gopalsami
         Commented the MRC call
        update_mrc_data; -- bug#3332988
     */

      END IF;    --  p_receipt_code = 'PACKING_SLIP' or  p_receipt_code  = 'RECEIPT'



    ELSIF rcv_tran_id IS NULL and v_source IN ('ERS', 'ASBN', 'RTS') THEN

      --IF rcv_tran_id IS NOT NULL THEN
      -- to be fired when po_line_locations_all.match_option = 'P'

      Fnd_File.put_line(Fnd_File.LOG, 'Fired when rcv_tran_id IS NULL, match_option is P');

    -- fetch shipment_num from rcv_headers_interface based on invoice_num
    -- pramasub start for isupplier IL FP
    -- local cursor to fetch shipment number
    For rcv_hdr_intf_rec in
    (Select shipment_num
    From   rcv_headers_interface
    Where  invoice_num = get_ven_info_rec.invoice_num)
    Loop
      v_ship_num := rcv_hdr_intf_rec.shipment_num;
    End loop;
    -- pramasub end FP


      FOR i IN
      from_line_location_taxes
      (
      cur_items_rec.line_location_id, /* from_po_distributions_rec.line_location_id, bug # 4204600 */
      for_org_id_rec.vendor_id,
    v_source, -- added by pramasub Isupplier IL FP
    v_ship_num -- added pramasub FP
      )LOOP
          -- Added by Brathod for Bug# 4445989
          /* v_distribution_no := v_distribution_no + 1; */
          v_distribution_no :=1;
          -- ln_inv_line_num := ln_inv_line_num + 1; -- 5763527, moved the increment to just beofore the insert statement
          -- End Bug# 4445989

          r_service_regime_tax_type := null;
          -- Bug 5358788. Added by Lakshmi Gopalsami
          r_VAT_regime_tax_type := null;

          /* 5763527 */
          ln_project_id           := null;
          ln_task_id              := null;
          lv_exp_type             := null;
          ld_exp_item_date        := null;
          ln_exp_organization_id  := null;
          lv_project_accounting_context := null;
          lv_pa_addition_flag := null;


          -- Start for bug#3752887
          v_tax_amount := i.tax_amount * v_apportn_factor_for_item_line;


          if i.currency <> for_org_id_rec.invoice_currency_code then
              v_tax_amount := v_tax_amount / for_org_id_rec.exchange_rate;
          end if;
          -- End for bug#3752887

          OPEN  c_tax(i.tax_id);
          FETCH c_tax INTO c_tax_rec;
          CLOSE c_tax;

            -- added, kunkumar for Bug#5593895
          ln_base_amount := null ;
          if i.tax_type IN ( jai_constants.tax_type_value_added, jai_constants.tax_type_cst )  then
            ln_base_amount := jai_ap_utils_pkg.fetch_tax_target_amt
                              (
                                p_invoice_id          =>   inv_id ,
                                p_line_location_id    =>   cur_items_rec.line_location_id ,
                                p_transaction_id       =>   null  ,
                                p_parent_dist_id      =>   for_dist_insertion_rec.invoice_distribution_id ,
                                p_tax_id              =>   i.tax_id
                              ) ;
          end if ;
                -- ended, kunkumar for Bug#5593895

          /* Service Start */
          v_assets_tracking_flag := for_dist_insertion_rec.assets_tracking_flag;
          v_dist_code_combination_id := null;

          --initial the tax_type
          lv_tax_type := NULL;--added by eric for inclusive tax on 20-Dec,2007

          if i.modvat_flag = 'Y'
          and nvl(c_tax_rec.mod_cr_percentage, 0) > 0
          then  -- 5763527

            --recoverable tax
            lv_tax_type := 'RE'; --added by eric for inclusive tax on 20-dec,2007


           /*  recoverable tax */
            v_assets_tracking_flag := 'N';

            open c_regime_tax_type(r_jai_regimes.regime_id, c_tax_rec.tax_type);
            fetch c_regime_tax_type into r_service_regime_tax_type;
            close c_regime_tax_type;

            fnd_file.put_line(FND_FILE.LOG,
                     ' Service regime: '||r_service_regime_tax_type.tax_type);

       /* Bug 5358788. Added by Lakshmi Gopalsami
      * Fetched the details of VAT regime
      */

           OPEN  c_regime_tax_type(r_vat_regimes.regime_id, c_tax_rec.tax_type);
            FETCH  c_regime_tax_type INTO  r_vat_regime_tax_type;
           CLOSE  c_regime_tax_type;

           fnd_file.put_line(FND_FILE.LOG,
                     ' VAT regime: '||r_vat_regime_tax_type.tax_type);

            if r_service_regime_tax_type.tax_type is not null then
              /* Service type of tax */
              v_dist_code_combination_id := check_service_interim_account
                                            (
                                              lv_accrue_on_receipt_flag,
                                              lv_accounting_method_option,
                                              lv_is_item_an_expense,
                                              r_jai_regimes.regime_id,
                                              v_org_id,
                                              p_rematch,
                                              c_tax_rec.tax_type,
                po_dist_id  --Added by JMEENA for bug#6833506
                                            );
              fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_service_regime_tax_type.tax_type
             ||', ' || v_dist_code_combination_id);

              /* Bug 5358788. Added by Lakshmi Gopalsami
             * Commented p_rematch and added validation for
         * VAT regime.
         */
      /*following elsif block modified for bug 6595773*/
             ELSIF r_vat_regime_tax_type.tax_type IS NOT NULL THEN
             --p_rematch = 'PO_MATCHING' then

              v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
        fnd_file.put_line(FND_FILE.LOG,
                   ' Regime type , CCID '
       || r_vat_regime_tax_type.tax_type
             ||', ' || v_dist_code_combination_id);

            end if;

          else  /* 5763527 introduced for PROJETCS COSTING Impl */
            /* 5763527 */
            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

            --non recoverable
            lv_tax_type := 'NR';  --added by eric for inclusive tax on 20-dec,2007
          end if; /*nvl(c_tax_rec.mod_cr_percentage, 0) = 100  and c_tax_rec.tax_account_id is not null*/


          /* Bug#4177452*/
          if v_dist_code_combination_id is null then
            v_dist_code_combination_id := for_dist_insertion_rec.dist_code_combination_id;
          end if;

          /* Service End */

          --
          -- Begin 5763527
          --
          ln_rec_tax_amt  := null;
          ln_nrec_tax_amt := null;
          ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

          --added by Eric for inclusive tax on 20-dec-2007,begin
          -------------------------------------------------------------------------------------
          --exclusive tax or inlcusive tax without project info,  ln_lines_to_insert := 1;
          --inclusive recoverable tax with project info,  ln_lines_to_insert := 2;
          --PR(partially recoverable) tax is processed in another logic

          IF ( NVL(i.inc_tax_flag,'N') = 'N'
               OR ( NVL(i.inc_tax_flag,'N') = 'Y'
                    AND p_project_id IS NULL
                  )
             )
          THEN
            ln_lines_to_insert := 1;
          ELSIF ( NVL(i.inc_tax_flag,'N') = 'Y'
                  AND p_project_id IS NOT NULL
                  AND lv_tax_type = 'RE'
                )
          THEN
            ln_lines_to_insert := 2;
          END IF;--( NVL(i.inc_tax_flag,'N') = 'N' OR ( NVL(i.inc_tax_flag,'N'))
          -------------------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

          Fnd_File.put_line(Fnd_File.LOG, 'i.modvat_flag ='||i.modvat_flag ||',c_tax_rec.mod_cr_percentage='||c_tax_rec.mod_cr_percentage);

          if i.modvat_flag = jai_constants.YES
          and nvl(c_tax_rec.mod_cr_percentage, -1) > 0
          and nvl(c_tax_rec.mod_cr_percentage, -1) < 100
          then
            --
            -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
            -- and instead of one line, two lines needs to be inserted.
            -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
            --

            ln_lines_to_insert := 2 *ln_lines_to_insert; --changed by eric for inclusive tax on Jan 4,2008
      ln_rec_tax_amt  :=  round ( nvl(v_tax_amount,0) * (c_tax_rec.mod_cr_percentage/100) , c_tax_rec.rounding_factor) ;
      ln_nrec_tax_amt :=  round ( nvl(v_tax_amount,0) - nvl(ln_rec_tax_amt,0) , c_tax_rec.rounding_factor) ;
      /* Added Tax rounding based on tax rounding factor for bug 6761425 by vumaasha */

            lv_tax_type := 'PR';  --changed by eric for inclusive tax on Jan 4,2008
          end if;

          fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                        ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                        ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                         );

          --
          --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
          --  non recoverable tax amount and the second line will be for a recoverable tax amount
          --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
          --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
          --

          for line in 1..ln_lines_to_insert
          loop
          /*commented out by eric for inclusive tax

          if line = 1 then

            v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
            lv_modvat_flag := i.modvat_flag ;

          elsif line = 2 then

            v_tax_amount := ln_nrec_tax_amt;
            v_assets_tracking_flag := jai_constants.YES;
            lv_modvat_flag := jai_constants.NO ;

            --
            -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
            -- projects related columns so that PROJECTS can consider this line for Project Costing
            --

            ln_project_id           := p_project_id;
            ln_task_id              := p_task_id;
            lv_exp_type             := p_expenditure_type;
            ld_exp_item_date        := p_expenditure_item_date;
            ln_exp_organization_id  := p_expenditure_organization_id;
            lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
            lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

            -- For non recoverable line charge account should be same as of the parent line
            v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

            v_distribution_no := v_distribution_no + 1;

          end if;

          ln_inv_line_num := ln_inv_line_num + 1;

          --
          -- End 5763527
          --
          */

          --added by Eric for inclusive tax on 20-dec-2007,begin
          -------------------------------------------------------------------------------------
          IF (NVL(i.inc_tax_flag,'N') = 'N')--exclusive case
          THEN
            IF line = 1 then

              v_tax_amount  := nvl(ln_rec_tax_amt, v_tax_amount);
              lv_tax_line_amount:=  v_tax_amount       ;   --added by eric for inclusive tax
              lv_modvat_flag := i.modvat_flag ;

              lv_ap_line_to_inst_flag  := 'Y'; --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y'; --added by eric for inclusive tax
            ELSIF line = 2 then

              v_tax_amount             := ln_nrec_tax_amt;
              lv_tax_line_amount       :=  v_tax_amount  ; --added by eric for inclusive tax
              lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';             --added by eric for inclusive tax


              IF for_dist_insertion_rec.assets_tracking_flag = jai_constants.YES THEN
                v_assets_tracking_flag := jai_constants.YES;
              END IF;

              lv_modvat_flag := jai_constants.NO ;

              --
              -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
              -- projects related columns so that PROJECTS can consider this line for Project Costing
              --
              IF nvl(lv_accrue_on_receipt_flag,'#') <> 'Y' THEN -- Bug 6338371
                ln_project_id           := p_project_id;
                ln_task_id              := p_task_id;
                lv_exp_type             := p_expenditure_type;
                ld_exp_item_date        := p_expenditure_item_date;
                ln_exp_organization_id  := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag         := for_dist_insertion_rec.pa_addition_flag;
              END if;

              -- For non recoverable line charge account should be same as of the parent line
              v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id;

            END IF; --line = 1
          ELSIF (NVL(i.inc_tax_flag,'N') = 'Y')       --inclusive case
          THEN
            IF( lv_tax_type ='PR')
            THEN
              IF ( line = 1 )
              THEN
                --recoverable part
                v_tax_amount       := ln_rec_tax_amt ;
                lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
                lv_modvat_flag     := i.modvat_flag  ;
                lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

                --non recoverable part
              ELSIF ( line = 2 )
              THEN
                v_tax_amount       := ln_nrec_tax_amt  ;
                lv_tax_line_amount :=  v_tax_amount    ;   --added by eric for inclusive tax
                lv_modvat_flag     := jai_constants.NO ;
                lv_ap_line_to_inst_flag  := 'N';           --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';           --added by eric for inclusive tax

                --recoverable part without project infor
              ELSIF ( line = 3 )
              THEN
                v_tax_amount                  := ln_rec_tax_amt;
                lv_tax_line_amount            := NULL;

                lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                --Project information
                ln_project_id                 := NULL;
                ln_task_id                    := NULL;
                lv_exp_type                   := NULL;
                ld_exp_item_date              := NULL;
                ln_exp_organization_id        := NULL;
                lv_project_accounting_context := NULL;
                lv_pa_addition_flag           := NULL;

                -- For inclusive recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;

                --recoverable part in negative amount with project infor
              ELSIF ( line = 4 )
              THEN
                v_tax_amount                  := NVL(ln_rec_tax_amt, v_tax_amount)* -1;
                lv_tax_line_amount            := NULL;
                lv_ap_line_to_inst_flag  := 'Y';             --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'N';             --added by eric for inclusive tax

                --Project information
                ln_project_id                 := p_project_id;
                ln_task_id                    := p_task_id;
                lv_exp_type                   := p_expenditure_type;
                ld_exp_item_date              := p_expenditure_item_date;
                ln_exp_organization_id        := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;

                -- For inclusive recoverable line charge account should be same as of the parent line
                v_dist_code_combination_id  :=  for_dist_insertion_rec.dist_code_combination_id ;
              END IF; --line = 1
            ELSIF ( lv_tax_type = 'RE'
                    AND p_project_id IS NOT NULL
                  )
            THEN
              --recoverable tax without project infor
              IF ( line = 1 )
              THEN
                v_tax_amount       :=  v_tax_amount  ;
                lv_tax_line_amount :=  v_tax_amount  ;    --added by eric for inclusive tax
                lv_modvat_flag     :=  i.modvat_flag ;
                lv_ap_line_to_inst_flag  := 'Y';          --added by eric for inclusive tax
                lv_tax_line_to_inst_flag := 'Y';          --added by eric for inclusive tax

                ln_project_id                 := NULL;
                ln_task_id                    := NULL;
                lv_exp_type                   := NULL;
                ld_exp_item_date              := NULL;
                ln_exp_organization_id        := NULL;
                lv_project_accounting_context := NULL;
                lv_pa_addition_flag           := NULL;
                v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
              --recoverable tax in negative amount with project infor
              ELSIF ( line = 2 )
              THEN
                v_tax_amount       :=  v_tax_amount * -1;
                lv_tax_line_amount :=  NULL ;   --added by eric for inclusive tax
                lv_modvat_flag     :=  i.modvat_flag  ;

                ln_project_id                 := p_project_id;
                ln_task_id                    := p_task_id;
                lv_exp_type                   := p_expenditure_type;
                ld_exp_item_date              := p_expenditure_item_date;
                ln_exp_organization_id        := p_expenditure_organization_id;
                lv_project_accounting_context := for_dist_insertion_rec.project_accounting_context;
                lv_pa_addition_flag           := for_dist_insertion_rec.pa_addition_flag;
                v_dist_code_combination_id    := for_dist_insertion_rec.dist_code_combination_id ;
              END IF;
            --ELSIF ( lv_tax_type <> 'PR' AND p_project_id IS NULL )
            --THEN
            ELSE -- eric removed the above criteria for bug 6888665 and 6888209
              Fnd_File.put_line(Fnd_File.LOG, 'NOT Inclusive PR Tax,NOT Inclusive RE for project ');
              --The case process the inclusive NR tax and inclusive RE tax not for project

              lv_tax_line_amount := v_tax_amount   ;   --added by eric for inclusive tax
              lv_modvat_flag     := i.modvat_flag  ;
              lv_ap_line_to_inst_flag  := 'N';         --added by eric for inclusive tax
              lv_tax_line_to_inst_flag := 'Y';         --added by eric for inclusive tax

            END IF;--( tax_type ='PR' and (ln_lines_to_insert =4 OR )
          END IF; --(NVL(r_tax_lines_r ec.inc_tax_flag,'N') = 'N')
          -------------------------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end


          Fnd_File.put_line(Fnd_File.LOG,
          'Before inserting into ap_invoice_lines_all for line no :' || ln_inv_line_num );

          --insert exclusive tax to the ap tables
          --or insert recoverable inclusive tax with project information the ap tables


          --1.Only exlusive taxes or inclusive recoverable taxes with project information
          --  are  inserted into Ap Lines and Dist Lines

          --2.All taxes need to be inserted into jai tax tables. Futher the
          --  partially recoverable tax need to be splitted into 2 lines

          --added by Eric for inclusive tax on 20-dec-2007,begin
          ------------------------------------------------------------------------
          IF ( NVL(lv_ap_line_to_inst_flag,'N')='Y')
          THEN
            ln_inv_line_num := ln_inv_line_num + 1; --added by eric for inlcusive tax
          ---------------------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

            INSERT INTO ap_invoice_lines_all
            (
                INVOICE_ID
              , LINE_NUMBER
              , LINE_TYPE_LOOKUP_CODE
              , DESCRIPTION
              , ORG_ID
              , MATCH_TYPE
        , DEFAULT_DIST_CCID --Changes by nprashar for bug #6995437
              , ACCOUNTING_DATE
              , PERIOD_NAME
              , DEFERRED_ACCTG_FLAG
              , DEF_ACCTG_START_DATE
              , DEF_ACCTG_END_DATE
              , DEF_ACCTG_NUMBER_OF_PERIODS
              , DEF_ACCTG_PERIOD_TYPE
              , SET_OF_BOOKS_ID
              , AMOUNT
              , WFAPPROVAL_STATUS
              , CREATION_DATE
              , CREATED_BY
              , LAST_UPDATED_BY
              , LAST_UPDATE_DATE
              , LAST_UPDATE_LOGIN
              /* 5763527 */
              , project_id
              , task_id
              , expenditure_type
              , expenditure_item_date
              , expenditure_organization_id
              /* End 5763527 */
        ,po_distribution_id --Added for bug#6780154

            )
            VALUES
            (
                inv_id
              , ln_inv_line_num
              , lv_misc
              , c_tax_rec.tax_name
              , v_org_id
              , lv_match_type
        , v_dist_code_combination_id
              , rec_max_ap_lines_all.accounting_date
              , rec_max_ap_lines_all.period_name
              , rec_max_ap_lines_all.deferred_acctg_flag
              , rec_max_ap_lines_all.def_acctg_start_date
              , rec_max_ap_lines_all.def_acctg_end_date
              , rec_max_ap_lines_all.def_acctg_number_of_periods
              , rec_max_ap_lines_all.def_acctg_period_type
              , rec_max_ap_lines_all.set_of_books_id
              , ROUND(v_tax_amount,ln_precision)
              , rec_max_ap_lines_all.wfapproval_status  -- Bug 4863208
              , sysdate
              , ln_user_id
              , ln_user_id
              , sysdate
              , ln_login_id
              /* 5763527 */
              , ln_project_id
              , ln_task_id
              , lv_exp_type
              , ld_exp_item_date
              , ln_exp_organization_id
              /* End 5763527 */
          ,po_dist_id --Added for bug#6780154
             );

            Fnd_File.put_line(Fnd_File.LOG,
            'Before inserting into ap_invoice_distributions_all for distribution line no :'
            || v_distribution_no);

            -- Start bug#3332988
            open c_get_invoice_distribution;
            fetch c_get_invoice_distribution into v_invoice_distribution_id;
            close c_get_invoice_distribution;
            -- End bug#3332988
            fnd_file.put_line(FND_FILE.LOG, ' Invoice distribution id '|| v_invoice_distribution_id);

            INSERT INTO ap_invoice_distributions_all
            (
            accounting_date,
            accrual_posted_flag,
            assets_addition_flag,
            assets_tracking_flag,
            cash_posted_flag,
            distribution_line_number,
            dist_code_combination_id,
            invoice_id,
            last_updated_by,
            last_update_date,
            line_type_lookup_code,
            period_name,
            set_of_books_id ,
            amount,
            base_amount,
            batch_id,
            created_by,
            creation_date,
            description,
             exChange_rate_variance,
            last_update_login,
            match_status_flag,
            posted_flag,
            rate_var_code_combination_id ,
            reversal_flag ,
            program_application_id,
            program_id,
            program_update_date,
            accts_pay_code_combination_id,
            invoice_distribution_id,
            quantity_invoiced,
            po_distribution_id ,
            rcv_transaction_id,
            org_id,
            matched_uom_lookup_code
            ,invoice_line_number
      ,charge_applicable_to_dist_id -- Bug 5401111. Added by Lakshmi Gopalsami
            /* 5763527 */
            , project_id
            , task_id
            , expenditure_type
            , expenditure_item_date
            , expenditure_organization_id
            , project_accounting_context
            , pa_addition_flag
            /* End of 5763527 */
            -- Bug 7249100. Added by Lakshmi Gopalsami
            ,distribution_class
      ,asset_book_type_code /* added for bug 8406404 by vumaasha */
            )
            VALUES
            (
            rec_max_ap_lines_all.accounting_date,
            'N', --for_dist_insertion_rec.accrual_posted_flag,
            for_dist_insertion_rec.assets_addition_flag,
            v_assets_tracking_flag , -- for_dist_insertion_rec.assets_tracking_flag, bug#2851123
            'N',
            -- dln,
            v_distribution_no,
            v_dist_code_combination_id,
            inv_id,
            ln_user_id,
            sysdate,
            lv_misc,
            rec_max_ap_lines_all.period_name,
            rec_max_ap_lines_all.set_of_books_id ,
            ROUND(v_tax_amount,ln_precision),
            ROUND(v_tax_amount * for_dist_insertion_rec.exchange_rate, ln_precision), --ROUND(for_dist_insertion_rec.base_amount,2),
            v_batch_id,
            ln_user_id,
            sysdate,
            c_tax_rec.tax_name,
            null,--kunkumar for forward porting to R12
            ln_login_id,
            for_dist_insertion_rec.match_status_flag , -- Bug 4863208
            'N',
            NULL,
            for_dist_insertion_rec.reversal_flag,  -- Bug 4863208
            for_dist_insertion_rec.program_application_id,
            for_dist_insertion_rec.program_id,
            for_dist_insertion_rec.program_update_date,
            for_dist_insertion_rec.accts_pay_code_combination_id,
            v_invoice_distribution_id,
            decode(v_assets_tracking_flag, 'Y', NULL, 0), /* Modified for bug 8406404 by vumaasha */
            po_dist_id ,
            rcv_tran_id,
            for_dist_insertion_rec.org_id,  -- Bug 4863208
            for_dist_insertion_rec.matched_uom_lookup_code,
            ln_inv_line_num
      -- Bug 5401111. Added by Lakshmi Gopalsami
      ,decode(v_assets_tracking_flag,'N',
              NULL,for_dist_insertion_rec.invoice_distribution_id)
/*Commented the account_type condition for bug#7008161 by JMEENA
       decode(lv_account_type, 'A',
              for_dist_insertion_rec.invoice_distribution_id,NULL)
            )
*/
            /* 5763527 */
            , ln_project_id
            , ln_task_id
            , lv_exp_type
            , ld_exp_item_date
            , ln_exp_organization_id
            , lv_project_accounting_context
            , lv_pa_addition_flag
            /* End Of 5763527 */
            -- Bug 7249100. Added by Lakshmi Gopalsami
            , lv_dist_class
      , decode(v_assets_tracking_flag,'Y',for_dist_insertion_rec.asset_book_type_code,NULL) /* added for bug 8406404 by vumaasha */
            );
          --added by Eric for inclusive tax on 20-dec-2007,begin
          -----------------------------------------------------------------
          END IF;--( NVL(lv_ap_line_to_inst_flag,'N')='Y') )
          -----------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end


            Fnd_File.put_line(Fnd_File.LOG,
            'Before inserting into JAI_AP_MATCH_INV_TAXES tax id ' || i.tax_id );
          --added by Eric for inclusive tax on 20-dec-2007,begin
          -----------------------------------------------------------------
          IF  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
          THEN
          -----------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end
            INSERT INTO JAI_AP_MATCH_INV_TAXES
            (
            tax_distribution_id,
            exchange_rate_variance,
            assets_tracking_flag,
            invoice_id,
            po_header_id,
            po_line_id,
            line_location_id,
            set_of_books_id,
            --org_id,
            exchange_rate,
            exchange_rate_type,
            exchange_date,
            currency_code,
            code_combination_id,
            last_update_login,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            acct_pay_code_combination_id,
            accounting_date,
            tax_id,
            tax_amount,
            base_amount,
            chart_of_accounts_id,
            distribution_line_number,
            po_distribution_id,
            parent_invoice_distribution_id,
            legal_entity_id
            ,INVOICE_LINE_NUMBER
            ,INVOICE_DISTRIBUTION_ID
            ,PARENT_INVOICE_LINE_NUMBER
            ,RCV_TRANSACTION_ID
            ,LINE_TYPE_LOOKUP_CODE
            ,recoverable_flag -- 5763527
            ,line_no            -- added, Harshita for Bug 5553150
            )
            VALUES
            (
            JAI_AP_MATCH_INV_TAXES_S.NEXTVAL,
            null,--kunkumar for forward porting to R12
            v_assets_tracking_flag , -- 'N', bug#2851123
            inv_id,
            cur_items_rec.po_header_id,
            cur_items_rec.po_line_id,
            cur_items_rec.line_location_id,
            cur_items_rec.set_of_books_id,
            --cur_items_rec.org_id,
            cur_items_rec.rate,
            cur_items_rec.rate_type,
            cur_items_rec.rate_date,
            cur_items_rec.currency_code,
      /* Bug 5358788. Added by Lakshmi Gopalsami. Commented
             * c_tax_rec.tax_account_id and v_dist_code_combination_id
       */
            v_dist_code_combination_id,
            cur_items_rec.last_update_login,
            cur_items_rec.creation_date,
            cur_items_rec.created_by,
            cur_items_rec.last_update_date,
            cur_items_rec.last_updated_by,
            v_dist_code_combination_id,
            cur_items_rec.invoice_date,
            i.tax_id,
            /*commented out by eric for inclusive tax
            round(v_tax_amount,ln_precision),
            */
            ROUND(lv_tax_line_amount,ln_precision), --added by eric for inclusive tax
            ROUND(i.tax_amount, ln_precision),
            caid,
            -- dln,
            v_distribution_no,
            po_dist_id, -- added  by bug#3038566
            for_dist_insertion_rec.invoice_distribution_id, -- added  by bug#3038566
            get_ven_info_rec.legal_entity_id  -- added by rallamse bug#
            --ln_inv_line_num, deletedt by eric for inclusive tax
            --, v_invoice_distribution_id, deletedt by eric for inclusive tax
            --added by Eric for inclusive tax on 20-dec-2007,begin
            --------------------------------------------------------------
            , DECODE ( NVL(i.inc_tax_flag,'N')
                     , 'N',ln_inv_line_num
                     , 'Y',pn_invoice_line_number
                     )
            ,NVL(v_invoice_distribution_id,for_dist_insertion_rec.invoice_distribution_id)
            --------------------------------------------------------------
            --added by Eric for inclusive tax on 20-dec-2007,end
            , pn_invoice_line_number
            , rcv_tran_id
            , lv_misc
            , lv_modvat_flag -- 5763527
            , i.tax_line_no  -- added, Harshita for Bug 5553150
            );
          --added by Eric for inclusive tax on 20-dec-2007,begin
          -----------------------------------------------------------------
          END IF;--  (NVL(lv_tax_line_to_inst_flag,'N') = 'Y')
          -----------------------------------------------------------------
          --added by Eric for inclusive tax on 20-dec-2007,end

            /* Bug 46863208. Added by Lakshmi Gopalsami
             Commented the MRC call
            insert_mrc_data(v_invoice_distribution_id); -- bug#3332988
      */
      /* commented out by Eric for bug 8345512 on 13-Jul-2009
        cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
      */


          --Modified by Eric for bug 8345512 on 13-Jul-2009,begin
          ------------------------------------------------------------------
          IF NVL(i.inc_tax_flag,'N') ='N'
          THEN
            cum_tax_amt := cum_tax_amt + ROUND(v_tax_amount, ln_precision);
          END IF;
          ------------------------------------------------------------------
          --Modified by Eric for bug 8345512 on 13-Jul-2009,end

            ---------------------------------------------------------------------------------------------

            v_statement_no := '50';

            /* Obsoleted as part of R12 , Bug# 4445989
            Fnd_File.put_line(Fnd_File.LOG, 'Before inserting into JAI_CMN_FA_INV_DIST_ALL');
            INSERT INTO JAI_CMN_FA_INV_DIST_ALL
            (
            invoice_id,
            invoice_distribution_id,
            set_of_books_id,
            batch_id,
            po_distribution_id,
            rcv_transaction_id,
            dist_code_combination_id,
            accounting_date,
            assets_addition_flag,
            assets_tracking_flag,
            distribution_line_number,
            line_type_lookup_code,
            amount,
            description,
            match_status_flag,
            quantity_invoiced
            )
            VALUES
            (
            inv_id,
            ap_invoice_distributions_s.CURRVAL,
            for_dist_insertion_rec.set_of_books_id,
            v_batch_id,
            for_dist_insertion_rec.po_distribution_id,
            rcv_tran_id,
            v_dist_code_combination_id,
            for_dist_insertion_rec.accounting_date,
            for_dist_insertion_rec.assets_addition_flag,
            v_assets_tracking_flag , -- for_dist_insertion_rec.assets_tracking_flag, bug#2851123
            v_distribution_no,
            'MISCELLANEOUS',
            ROUND(v_tax_amount, ln_precision),
            c_tax_rec.tax_name,
            NULL,
            NULL);*/

            --  end modification for ap to fa modavatable taxes issue. on 19-mar-01 by subbu and pavan

          END LOOP; --> for line in  -- 5763527
      END LOOP;

      -- check to avoid amount updation in the invoice header when any of the dist lines are reversed
      v_dist_reversal_cnt := 0; -- Added by avallabh for bug 4926094 on 03-Feb-2006
      OPEN c_dist_reversal_cnt(inv_id);
      FETCH c_dist_reversal_cnt INTO v_dist_reversal_cnt;
      CLOSE c_dist_reversal_cnt;

      if v_dist_reversal_cnt = 0 then
        v_statement_no := '66';

        v_update_payment_schedule:=update_payment_schedule(cum_tax_amt); -- bug#3218978
--        cum_tax_amt := round(cum_Tax_amt,ln_precision);
        UPDATE ap_invoices_all
        SET invoice_amount = invoice_amount + cum_tax_amt,
        approved_amount = approved_amount + cum_tax_amt,
        pay_curr_invoice_amount = pay_curr_invoice_amount + cum_tax_amt,
        amount_applicable_to_discount = amount_applicable_to_discount + cum_tax_amt,
        payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
        -- bug#3624898
        WHERE invoice_id = inv_id;

        -- start added for bug#3354932
        if for_org_id_rec.invoice_currency_code <> v_functional_currency then
          -- invoice currency is not the functional currency.
          update ap_invoices_all
          set    base_amount = invoice_amount  * exchange_rate
          where  invoice_id = inv_id;
        end if;
        -- end added for bug#3354932

      /* Bug 4863208. Added by Lakshmi Gopalsami
         Commented the MRC call
        update_mrc_data; -- bug#3332988
     */

      end if; -- v_dist_reversal_cnt = 0

    ELSE

        err_mesg :=
        'This procedure should be called for RCV_MATCHING only, the input parameter is : '
        || p_rematch;

      RETURN;

    END IF; -- if rcv_tran_id is not null

  END IF; -- 'PAY_ON_RECEIPT'


  EXCEPTION
      WHEN OTHERS THEN
      err_mesg := SQLERRM;
      Fnd_File.put_line(Fnd_File.LOG, 'SQLERRM -> '|| SQLERRM ||', SQLCODE -> '||SQLCODE);
      Fnd_File.put_line(Fnd_File.LOG, 'Statement -> '|| v_statement_no);
      RETURN;
  END process_batch_record;

END;

/
