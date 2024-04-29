--------------------------------------------------------
--  DDL for Package Body JAI_RCV_THIRD_PARTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_THIRD_PARTY_PKG" AS
/* $Header: jai_rcv_3p_prc.plb 120.13.12010000.7 2010/02/01 06:48:02 mramados ship $ */
/* --------------------------------------------------------------------------------------
Filename: jai_rcv_third_party_pkg_b.sql

Change History:

Date         Bug          Remarks
---------    ----------   -------------------------------------------------------------
27-jan-05    Bug#3940741  Created by Aparajita. Version # 115.0.

                          This is a part of correction ER, done in phases and is concluded
                          with the receipt deplug, which is being shipped along with
                          Service and Education Cess solution.

                          This obsoletes the third party code in the old receiving, namely the procedures,
                          1. Ja_In_Con_Ap_Req
                          2. ja_in_receipt_ap_interface.

                          Here procedure Process_batch is attached to the concurrent JAINTPRE
                          for generating third party invoices and it calls the procedure
                          process_receipt for each pending shipment_header_id.

                          Functionality addressed here is that a receipt is processed for
                          third party invoices only once. All RECEIVE and CORRECT of RECEIVE
                          type of transactions are considered for generating third party invoices.

                          If a CORRECT to RECEIVE happens after third party invoice is
                          generated, third_party_flag in JAI_RCV_TRANSACTIONS is set to 'G'
                          to indicate that third party invoice has already been generated.

                          This clean up also has introduced two tables which help in tracking
                          third party invoices.

                          1. jai_rcv_tp_batches
                          2. jai_rcv_tp_invoices


14-mar-2005 bug#4284505   ssumaith - version 115.1

                          Code has been added in the package body to insert third party taxes in the
                          new table created for this bug. The table is jai_rcv_tp_inv_details.

                          A new procedure populate_tp_invoice_id has been created which does the actual
                          invoice id update in the jai_Rcv_Tp_inv_Details table.


                          This table maintains tax level details of third party taxes, and it will be
                          used by the service tax processing concurrent.


24/05/2005              Ramananda for bug# 4388958 File Version: 116.1
                        Changed AP Lookup code from 'TDS' to 'INDIA TDS'

08-Jun-2005             Version 116.3 jai_rcv_3p_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
            as required for CASE COMPLAINCE.

13-Jun-2005             File Version: 116.4
                        Ramananda for bug#4428980. Removal of SQL LITERALs is done

08-Jul-2005             Sanjikum for Bug#4482462
                        1) Removed the column payment_method_lookup_code from cursor - c_get_vendor_details
                        2) In the procedure process_receipt, commented the value of parameter - p_payment_method_lookup_code
                           while calling procedure - jai_ap_utils_pkg.insert_ap_inv_interface

13-Aug-2005              rchandan for bug#4551623. File version 120.2.
                         Changed the order of parameters of process_batch and added a default NULL to p_simulation.
                         p_simulation is replaced with nvl(p_simulation,'N') in process_batch procedure

02-Dec-2005    Bug 4774647. Added by Lakshmi Gopalsami  Version 120.3
                     Passed operating unit also as this parameter
                     has been added by base .

23-Jan-2006   Bug4941642. Added by Lakshmi Gopalsami Version 120.4
              (1) Added conditions in procedure process_receipt
                  in cursor c_thirdparty_tax_rec.
       (a) Added shipment header id condition
       (b) added aliases.
       (c) Removed two separate conditions on jai_rcv_Transactions
           and clubbed into a single one.
              (2) Added aliases for the following cursors.
                   (a) c_get_thirdparty_count
                   (b) c_get_thirdparty_null_site_cnt
                   (c) c_get_tparty_invalid_comb_cnt
                   Also added shipment_header_id and shipment_line_id
       condition in the above cursors. Changed IN clause to
       exists due to performance issue.

              (3) Added transaction_id in cursor c_pending_tp_receipts

25-Aug-2006  Bug 5490479, Added by aiyer, File version 120.7
               Issue:-
                Org_id parameter in all MOAC related Concurrent programs is getting derived from the profile org_id
                As this parameter is hidden hence not visible to users and so users cannot choose any other org_id from the security profile.

               Fix:-
                1. The Multi_org_category field for all MOAC related concurrent programs should be set to 'S' (indicating single org reports).
                   This would enable the SRS Operating Unit field. User would then be able to select operating unit values related to the
                   security profile.
                2. Remove the default value for the parameter p_org_id and make it Required false, Display false. This would ensure that null value gets passed
                   to the called procedures/ reports.
                3. Change the called procedures/reports. Remove the use of p_org_id and instead derive the org_id using the function mo_global.get_current_org_id
               This change has been made many procedures and reports.

11-May-2007   Bug5620503, CSahoo, File Version 120.8
              FORWARD PORTING BUG FOR R11I BUG 5613772
              Made some changes to the cursor c_get_vendor_details.

20-Jun-2007   CSahoo for bug#6139899, File Version 120.9
              modified the code in process_receipt procedure. added the p_org_id paramter in the call to
              jai_ap_utils_pkg.insert_ap_inv_lines_interface and jai_ap_utils_pkg.insert_ap_inv_interface procedures.

09-Dec-2007             Code changed for inclusive tax by Eric

06-Feb-2008             Code changed for bug#6790599  by Eric

21-Apr-2008             Code changed for bug#6971486 by Eric
23-Apr-2008             Code changed for bug#6997730  and bug#6988610

06-AUG-2009  Bug: 8238608  File Version 120.13.12010000.3
             Issue: Service Accounting does not happen, when Accrue on reciept = N for third party Invoices.
             Fix: The scenario was not handled earlier. Required code changes are done.

07-Aug-2009 bug: 8567640 File Version  120.13.12010000.4
             Issue :  Performance issue with 3rd party invoices concurrent
             Fix:  Modified the below cursor queries
                                  + c_pending_tp_receipts

08-Oct-2009 CSahoo for bug#8965721, File Version 120.13.12010000.6
            Issue: TST1212.XB2.QA:SERVICE TAX CREDIT NOT ACCOUNTED FOR GOODS TRANSPORT OPERATORS
            Fix: Did the Fp of the transaporter scenario correctly again.
                 modified the code in the procedure process_receipt

Future Dependencies For the release Of this Object:-
==================================================
(Please add a row in the section below only if your bug introduces a dependency due to spec change/
A new call to a object/A datamodel change )

------------------------------------------------------------------------------------------------------
Version       Bug       Dependencies (including other objects like files if any)
-------------------------------------------------------------------------------------------------------
115.0         4146708   The new tables have been created through the script attached to bug
                        for service and cess datamodel change.

----------------------------------------------------------------------------------------- */

/****************************** Start process_pending_receipts  ****************************/

  procedure process_batch
  (
    errbuf                   out nocopy  VARCHAR2,
    retcode                  out nocopy  VARCHAR2,
    p_batch_name             in          VARCHAR2,
    /* Bug 5096787. Added by LGOPALSA  Added parameter p_org_id */
    p_org_id                 in          NUMBER    /* This parameter would no more be used after application of the bug 5490479- Aiyer, */,
    p_simulation             in          VARCHAR2 default null,
    p_debug                  in          NUMBER    default 1
  )
  is

/* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive   JAI_RCV_TRANSACTIONS.transaction_type%type;
  lv_ttype_correct   JAI_RCV_TRANSACTIONS.transaction_type%type;

 cursor c_pending_tp_receipts(cp_org_id number)  is  /* modified the cursor query for bug 8567640 */
  SELECT
 /*+ no_expand */ jrt.shipment_header_id
 FROM jai_rcv_transactions jrt,
   jai_rcv_lines jrl
   WHERE(jrt.transaction_type = 'RECEIVE' OR(jrt.transaction_type = 'CORRECT'
    AND jrt.parent_transaction_type = 'RECEIVE'))
    AND jrt.third_party_flag = 'N'
  AND jrt.shipment_header_id = jrl.shipment_header_id
  AND jrt.shipment_line_id = jrl.shipment_line_id
  AND jrl.tax_modified_flag <> 'Y'
  AND jrt.organization_id = cp_org_id
  GROUP BY jrt.shipment_header_id
  ORDER BY jrt.shipment_header_id;

  cursor c_get_tp_batch_id  is
    select jai_rcv_tp_batches_s.nextval from dual;

  cursor c_no_of_invoice_generated(cp_batch_id number) is
    select count(batch_invoice_id)
    from   jai_rcv_tp_invoices
    where  batch_id = cp_batch_id;


  r_pending_tp_receipts               c_pending_tp_receipts%rowtype;

  lv_process_flag                     VARCHAR2(1);
  lv_process_message                  VARCHAR2(256);
  ln_batch_id                         NUMBER;
  ln_no_of_invoice_generated          NUMBER;

  ln_req_id                           NUMBER;
  ln_uid                              NUMBER;   --File.Sql.35 Cbabu  := fnd_global.user_id;
  lv_temp                             VARCHAR2(100);
  ln_org_id                           NUMBER;       /*Added by aiyer for the bug 5490479 */

begin

  ln_uid  := fnd_global.user_id;
  /*
  || Start of bug 5490479
  || Added by aiyer for the bug 5490479
  || Get the operating unit (org_id)
  */
  ln_org_id := mo_global.get_current_org_id;
  fnd_file.put_line(fnd_file.log, 'Operating unit ln_org_id is -> '||ln_org_id);

  /*End of bug 5490479 */
  /* This is to identify the path in SQL TRACE file if any problem occured */
  SELECT 'jai_rcv_third_party_pkg.process_pending_receipts' INTO lv_temp FROM DUAL;

  open  c_get_tp_batch_id;
  fetch c_get_tp_batch_id into ln_batch_id;
  close c_get_tp_batch_id;

  if p_debug >= 1 then
    Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 1 : Start of procedure jai_rcv_third_party_pkg.process_pending_receipts ****');
  end if;

  /* Get all receipts where third party needs to be processed. Here only
     RECEIVE or CORRECT to RECEIVE type of transactions are considered */

/* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive := 'RECEIVE' ;
  lv_ttype_correct := 'CORRECT' ;

       /* Bug 4695630 Added by vumaasha
        Depending on the  value of the ln_org_id(operating unit)
        we have to process the records
        Added the following cursor and added cursor parameter for r_pending_tp_receipts
    */

/* start of bug 4695630 */

    for c_sel_org in (SELECT organization_id
                             FROM org_organization_definitions
                            WHERE operating_unit = ln_org_id
                          )

     loop

      Fnd_File.put_line(Fnd_File.LOG,
                       'Debug Msg 1 : Inside org definition and processing org '||
                        c_sel_org.organization_id);


    for r_pending_tp_receipts in c_pending_tp_receipts(c_sel_org.organization_id)  loop

    lv_process_flag := null;
    lv_process_message := null;

    process_receipt
    (
      p_batch_id             =>   ln_batch_id,
      p_shipment_header_id   =>   r_pending_tp_receipts.shipment_header_id,
      p_process_flag         =>   lv_process_flag,
      p_process_message      =>   lv_process_message,
      p_debug                =>   p_debug,
      p_simulation           =>   nvl(p_simulation, 'N')
    );


    insert into jai_rcv_tp_batches
    (
      batch_id           ,
      shipment_header_id ,
      process_flag       ,
      process_message    ,
      dummy_flag         ,
      created_by         ,
      creation_date      ,
      last_update_login  ,
      last_update_date   ,
      last_updated_by     ,
      program_application_id,
      program_id,
      program_login_id,
      request_id
     )
     values
     (
      ln_batch_id           ,
      r_pending_tp_receipts.shipment_header_id,
      lv_process_flag       ,
      lv_process_message    ,
      nvl(p_simulation, 'N') ,
      ln_uid                ,
      sysdate               ,
      ln_uid                ,
      sysdate               ,
      null    ,
     fnd_profile.value('PROG_APPL_ID'),
     fnd_profile.value('CONC_PROGRAM_ID'),
     fnd_profile.value('CONC_LOGIN_ID'),
     fnd_profile.value('CONC_REQUEST_ID')
     );


    if nvl(p_simulation, 'N') <> 'Y' then
     update   JAI_RCV_TRANSACTIONS jrt
     set      third_party_flag = lv_process_flag
     where    shipment_header_id = r_pending_tp_receipts.shipment_header_id
     and    ( transaction_type = 'RECEIVE'
              or
              (transaction_type = 'CORRECT' and parent_transaction_type = 'RECEIVE')
            )
     and    third_party_flag = 'N'
     and    exists
             (
               select '1'
               from   JAI_RCV_LINES jrl
               where  jrt.shipment_header_id = jrl.shipment_header_id
               and    jrt.shipment_line_id = jrl.shipment_line_id
               and    jrl.tax_modified_flag <> 'Y'
             );
     end if;


  end loop; /* c_pending_tp_receipts */
    END loop; /* c_sel_org */
  /* end of bug 4695630 */


  open c_no_of_invoice_generated(ln_batch_id);
  fetch c_no_of_invoice_generated into ln_no_of_invoice_generated;
  close c_no_of_invoice_generated;

  if ln_no_of_invoice_generated > 0 and nvl(p_simulation, 'N') <> 'Y' then

    /* Processing has created some invoices, invoking the payable open interface for their import */
    if p_debug >= 1 then
      Fnd_File.put_line(Fnd_File.LOG,
                        'Debug Level 1 : Invoking APXIIMPT as no of invoices created is :'
                        || to_char(ln_no_of_invoice_generated) );
    end if;

    ln_uid := fnd_global.user_id;
    ln_req_id :=
      Fnd_Request.submit_request
      (
      'SQLAP',
      'APXIIMPT',
      'Third party Invoices - Payables open interface Import',
      '',
      false,
          /*Bug 4774647. Added by Lakshmi Gopalsami
          Passed operating unit also as this parameter has been
          added by base .*/

      '',
      'INDIA TAX INVOICE', /*--'RECEIPT', --Ramanand for bug#4388958 */
      '',
      p_batch_name,
      '',
      '',
      '',
      'Y',
      'N',
      'Y',  /* modified for bug 4695630 */
      'N',
      1000,
      ln_uid,
      NULL
      );

  end if; /*ln_total_no_of_invoices > 0 then*/

  << exit_from_procedure >>

  if p_debug >= 1 then
    Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 1 : End of procedure jai_rcv_third_party_pkg.process_pending_receipts ****');
  end if;

  return;

exception
  when others then
    retcode    := 2;
    errbuf := 'jai_rcv_third_party_pkg.process_pending_receipts:' || sqlerrm;
    FND_FILE.put_line(FND_FILE.log, 'Error in jai_rcv_third_party_pkg.process_pending_receipts :'||sqlerrm);
    return;
end process_batch;
/****************************** End process_pending_receipts  ****************************/


/****************************** Start process_receipt  ****************************/

  procedure process_receipt
  (
    p_batch_id                                in         number,
    p_shipment_header_id                      in         number,
    p_process_flag                            OUT NOCOPY varchar2,
    p_process_message                         OUT NOCOPY varchar2,
    p_debug                                   in         number    default 1,
    p_simulation                              in         varchar2
  )
  is

  cursor c_rcv_shipment_headers(p_shipment_header_id number) is
    select receipt_num
    from   rcv_shipment_headers
    where  shipment_header_id = p_shipment_header_id;

  cursor c_rcv_transactions
  (p_shipment_header_id  number)is
    select
      vendor_id,
      vendor_site_id,    --added by eric for inclusive tax on 20-dec-2007
      organization_id,
      transaction_date,
      po_header_id,
      po_line_location_id,
      po_distribution_id,
      currency_code,
      currency_conversion_type,
      currency_conversion_date,
      currency_conversion_rate
    from   rcv_transactions
    where  shipment_header_id = p_shipment_header_id
    and    transaction_type = 'RECEIVE';

/* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive   JAI_RCV_TRANSACTIONS.transaction_type%type;
  lv_ttype_correct   JAI_RCV_TRANSACTIONS.transaction_type%type;

    /* Bug 4941642. Added by Lakshmi Gopalsami
       Added aliases for the following cursors and
        Added alias and shipment_header_id  and
       shipment_line_id condition in inner query
        (1) c_get_thirdparty_count
  (2) c_get_thirdparty_null_site_cnt
  (3) c_get_tparty_invalid_comb_cnt

    */
    cursor c_get_thirdparty_count     /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    (
      p_shipment_header_id  number,
      p_po_vendor_id        number
    )
    is
      select count(jrlt.tax_line_no)
      from   JAI_RCV_LINE_TAXES jrlt
      where  jrlt.shipment_header_id = p_shipment_header_id
      and    EXISTS
            (
              select 1
              from   JAI_RCV_TRANSACTIONS jrt
              where  jrt.shipment_header_id = jrlt.shipment_header_id
          AND  jrt.shipment_line_id = jrlt.shipment_line_id
          AND  ( jrt.transaction_type = lv_ttype_receive --'RECEIVE'
                       or
                       (jrt.transaction_type = lv_ttype_correct
            and jrt.parent_transaction_type = lv_ttype_receive
           )
                     )
              and    jrt.third_party_flag = 'N'
            )
      and   jrlt.tax_type not in (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
      and   jrlt.vendor_id > 0
      and   jrlt.tax_amount <> 0
      and   jrlt.tax_amount <> 0
      and   jrlt.vendor_id <> p_po_vendor_id;

    /* Bug 4941642. Added by Lakshmi Gopalsami
      Added alias and shipment_header_id  and
       shipment_line_id condition in inner query
    */
    cursor c_get_thirdparty_null_site_cnt /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    (
      p_shipment_header_id  number,
      p_po_vendor_id        number
    )
    is
      select count(jrlt.tax_line_no)
      from   JAI_RCV_LINE_TAXES jrlt
      where  jrlt.shipment_header_id = p_shipment_header_id
      and    EXISTS
            (
              select 1
              from   JAI_RCV_TRANSACTIONS jrt
              where jrt.shipment_header_id = jrlt.shipment_header_id
          AND jrt.shipment_line_id = jrlt.shipment_line_id
          AND ( jrt.transaction_type = lv_ttype_receive --'RECEIVE'
                       or
                       (jrt.transaction_type = lv_ttype_correct
            and jrt.parent_transaction_type = lv_ttype_receive
           )
                     )
              and    jrt.third_party_flag = 'N'
            )
      and   jrlt.tax_type not in (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
      and   jrlt.vendor_id > 0
      and   jrlt.tax_amount <> 0
      and   jrlt.vendor_id <> p_po_vendor_id
      and   jrlt.vendor_site_id is null;

    /* Bug 4941642. Added by Lakshmi Gopalsami
       Added alias and shipment_header_id  and
       shipment_line_id condition in inner query
    */

    cursor c_get_tparty_invalid_comb_cnt  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    (
      p_shipment_header_id  number,
      p_po_vendor_id        number
    )
    is
      select count(jrlt.tax_line_no)
      from   JAI_RCV_LINE_TAXES jrlt
      where  jrlt.shipment_header_id = p_shipment_header_id
      and    EXISTS
            (
              select 1
              from   JAI_RCV_TRANSACTIONS jrt
              where jrt.shipment_header_id = jrlt.shipment_header_id
          AND jrt.shipment_line_id = jrlt.shipment_line_id
          AND ( jrt.transaction_type = lv_ttype_receive
                       or
                       (jrt.transaction_type = lv_ttype_correct
            and jrt.parent_transaction_type = lv_ttype_receive
           )
                     )
              and    jrt.third_party_flag = 'N'
            )
      and   jrlt.tax_type not in (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
      and   jrlt.vendor_id > 0
      and   jrlt.tax_amount <> 0
      and   jrlt.vendor_id <> p_po_vendor_id
      and   jrlt.vendor_site_id is not null
      and   not exists
            (select '1'
             from   po_vendor_sites_all pvs
             where  pvs.vendor_id = jrlt.vendor_id
             and    pvs.vendor_site_id = jrlt.vendor_site_id
             );

    cursor  c_get_assets_tracking_flag(p_shipment_header_id  number) is
    select decode(count(inventory_item_id), 0, 'N', 'Y')
    from   JAI_INV_ITM_SETUPS
    where  item_class = 'CGIN'
    and    (inventory_item_id, organization_id)
        in
        (
        select item_id, ship_to_location_id
        from   rcv_shipment_lines
        where  shipment_header_id = p_shipment_header_id
        );

    cursor    c_get_po_dist_account (p_po_distribution_id number) is
      select  accrual_account_id
      from    po_distributions_all
      where   po_distribution_id = p_po_distribution_id;

    cursor  c_get_latest_po_dist_account (p_line_location_id  number) is
    select  accrual_account_id
    from    po_distributions_all
    where   line_location_id = p_line_location_id
    and     creation_date in
            (
             select max(creation_date)
             from   po_distributions_all
             where  line_location_id = p_line_location_id
            );


   cursor c_get_vendor_details (p_vendor_id number) is
     select
      vendor_name,
      terms_id,
       NULL payment_method_lookup_code, --commented the column by Sanjikum for Bug#4482462
       /* added the null in the above line by csahoo 5620503 */
      pay_group_lookup_code,
      NULL org_id   -- added by csahoo for bug#6139899
     from   po_vendors
     where  vendor_id = p_vendor_id;

 /* cbabu for Bug#5613772 */
   cursor c_get_vendor_site_dtls (p_vendor_site_id number) is
     SELECT
      b.vendor_name,
      a.terms_id,
      a.payment_method_lookup_code,
      a.pay_group_lookup_code,
      a.org_id    -- added by csahoo for bug#6139899
     from   po_vendor_sites_all a, po_vendors b
     where  a.vendor_id = b.vendor_id
     AND a.vendor_site_id = p_vendor_site_id;


   cursor   c_get_goods_received_date(p_vendor_id number, p_vendor_site_id number) is
     select
      decode(terms_date_basis, 'Goods Received', sysdate, null)
     from     po_vendor_sites_all
     where    vendor_id = p_vendor_id
     and      vendor_site_id = p_vendor_site_id;

  cursor c_get_inv_run_no is
    select  jai_rcv_tp_invoices_s1.nextval /* renamed the sequence to point to the correct sequence name - ssumaith - sequence change process */
    from   dual;

  cursor c_check_if_already_processed(p_shipment_header_id number) is
    select count(transaction_id)
    from   JAI_RCV_TRANSACTIONS
    where  shipment_header_id = p_shipment_header_id
    and    third_party_flag not in ('N', 'X');

  cursor c_jai_regimes (cpv_regime_code jai_rgm_definitions.regime_code%type) is /* added by vumaasha for bug 8238608 */
     select regime_id
     from   jai_rgm_definitions
     where  regime_code = cpv_regime_code;

 cursor c_trx_dtls(cp_transaction_id rcv_transactions.transaction_id%TYPE) is /* added by vumaasha for bug 8238608 */
  SELECT rt.po_distribution_id,
  rt.po_line_location_id     ,
  rt.po_line_id              ,
  rt.organization_id,
  pll.ship_to_organization_id,
  pll.ship_to_location_id
  FROM
   rcv_transactions rt,
   po_line_locations_all pll
   where rt.po_line_location_id=pll.line_location_id AND
   rt.transaction_id=cp_transaction_id;


    lv_temp                             varchar2(100);
    ln_thirdparty_count                 number;
    ln_thirdparty_null_site_cnt         number;
    ln_tparty_invalid_comb_cnt          number;
    lv_assets_tracking_flag             varchar2(1);
    ln_accrual_account                  number;
    ld_goods_received_date              date;
    lv_receipt_num                      rcv_shipment_headers.receipt_num%type;

    r_rcv_transactions                  c_rcv_transactions%rowtype;
    r_get_vendor_details                c_get_vendor_details%rowtype;

    lv_description                      ap_invoices_interface.description%type;
    ln_tax_amount                       number;
    lv_currency_conversion_type         rcv_transactions.currency_conversion_type%type;
    lv_currency_conversion_rate         rcv_transactions.currency_conversion_rate%type;
    lv_currency_conversion_date         date;
    ln_uid                              number; --File.Sql.35 Cbabu  := fnd_global.user_id;
    ln_inv_run_no                       number;
    lv_invoice_num                      ap_invoices_all.invoice_num%type;
    lv_func_currency                    gl_sets_of_books.currency_code%type;
    ln_gl_set_of_books_id               gl_sets_of_books.set_of_books_id%type;
    ln_interface_invoice_id             number;
    ln_interface_line_id                number;
    ln_check_if_already_processed       number;


    ln_vendor_id                        po_vendors.vendor_id%type;
    ln_vendor_site                      po_vendor_sites_all.vendor_site_id%type;
    lv_currency                         fnd_currencies.currency_code%type;
    lv_vendor_has_changed               VARCHAR2(10);
    lb_tp_taxes_processed               VARCHAR2(10);
    ln_batch_invoice_id                 NUMBER;
    ln_batch_line_id                    NUMBER;
    ln_line_number                      NUMBER;
    ln_cm_line_number                   NUMBER; --added by eric for inclusive tax
    ln_to_insert_line_number            NUMBER; --added by eric for inclusive tax
    ln_org_id       po_vendor_sites_all.org_id%type;   -- added by csahoo for bug#6139899
    ln_lines_to_insert                  NUMBER  default 1; --added by eric for inclusive tax on 20-dec-2007
    ln_tax_line_amount                  NUMBER;            --added by eric for inclusive tax on 20-dec-2007
    orig_vndr_details_rec               c_get_vendor_details%rowtype;   --added by eric for inclusive tax on 20-dec-2007
    ld_orig_goods_recv_date             DATE;              --added by eric for inclusive tax on 20-dec-2007
    lv_orig_currcy_conver_type          rcv_transactions.currency_conversion_type%type;    --added by eric for inclusive tax on 20-dec-2007
    lv_orig_currcy_conver_rate          rcv_transactions.currency_conversion_rate%type;    --added by eric for inclusive tax on 20-dec-2007
    lv_orig_currcy_conver_date          date;                                              --added by eric for inclusive tax on 20-dec-2007
  r_trx_dtls              c_trx_dtls%ROWTYPE;     /* added by vumaasha for bug 8238608 */
    ln_regime_id                        jai_rgm_definitions.regime_id%TYPE;  /* added by vumaasha for bug 8238608 */
  ln_accrue_on_receipt_flag         po_distributions_all.accrue_on_receipt_flag%TYPE; /* added by vumaasha for bug 8238608 */

--added the below cursor for bug#6988610 by eric on Apr 24,2008 ,begin
-----------------------------------------------------------------------
ln_totl_incl_tax_amount   number;

CURSOR get_totl_incl_tax_amount
( pn_shipment_header_id IN NUMBER
, pn_vendor_id          IN NUMBER
, pn_vendor_site_id     IN NUMBER
, pv_currency           IN VARCHAR2
)
IS
select
  sum(nvl(jrtv.tax_amount,0)) totl_incl_tax_amount
from
    JAI_RCV_TAX_V jrtv
  , jai_cmn_taxes_all jcta --added by eric for inclusive tax
  where
  ( jrtv.transaction_id, jrtv.shipment_line_id ) IN
  (  select transaction_id, shipment_line_id
              from   JAI_RCV_TRANSACTIONS jrt
              where shipment_header_id = pn_shipment_header_id
          and ( transaction_type = lv_ttype_receive --'RECEIVE'
                       or
                       (transaction_type = lv_ttype_correct
           and parent_transaction_type = lv_ttype_receive)
                     )
              and    third_party_flag = 'N'

  )
  and   jrtv.tax_type not in (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
  and   jrtv.vendor_id > 0
  and   nvl(jrtv.tax_amount, 0) is not null
  and   jrtv.shipment_header_id = pn_shipment_header_id
  and   jrtv.tax_id             = jcta.tax_id
  and   jcta.inclusive_tax_flag = 'Y'
  and   jrtv.vendor_id          = pn_vendor_id
  and   jrtv.vendor_site_id     = pn_vendor_site_id
  and   jrtv.currency           = pv_currency
  having sum(nvl(jrtv.tax_amount,0))  > 0 ; /* added to take care of complete CORRECTION */
------------------------------------------------------------------------------------------
--added by eric for bug#6988610 on Apr 24,2008 ,end


begin

  ln_uid                := fnd_global.user_id;
  ln_vendor_id          :=  -999;
  ln_vendor_site        :=  -999;
  lv_currency           := '$$$';
  lv_vendor_has_changed := 'TRUE';
  lb_tp_taxes_processed := 'FALSE';
  ln_line_number        := 1; /* modified by vumaasha for bug 8965721 */

  -- This is to identify the path in SQL TRACE file if any problem occured
  select 'jai_rcv_third_party_pkg.process_receipt : shipment header - ' || to_char(p_shipment_header_id)
  into lv_temp from dual;

  if p_debug >= 1 then
    Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 1 : ' ||
                                    'Start of procedure jai_rcv_third_party_pkg.process_receipt for shipment header :' ||
                                    to_char(p_shipment_header_id)
                                    );
  end if;

  /* Validation#0 : Check if third party has already been processed for the receipt */
  ln_check_if_already_processed := 0;
  open  c_check_if_already_processed(p_shipment_header_id);
  fetch c_check_if_already_processed into ln_check_if_already_processed;
  close c_check_if_already_processed;

  if ln_check_if_already_processed > 0 then
    p_process_flag := 'G';
    p_process_message :=  'Third party invoices have already got generated for this receipt, cannot process again';
    goto exit_from_procedure;
  end if;


  /* Validation#1 : Check if PO details exist */
  open c_rcv_transactions(p_shipment_header_id);
  fetch c_rcv_transactions into r_rcv_transactions;
  close c_rcv_transactions;

  if r_rcv_transactions.vendor_id is null then

    if p_debug >= 1 then
      Fnd_File.put_line(Fnd_File.LOG,
      '  Debug Level 1 : Details from rcv_transactions are not found for this shipment header, cannot process' );
    end if;

    p_process_flag := 'E';
    p_process_message :=  'Details from rcv_transactions are not found for this shipment header, cannot process';
    goto exit_from_procedure;

  end if;

/* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive := 'RECEIVE' ;
  lv_ttype_correct := 'CORRECT' ;

  /* Validation#2 : Check if third party taxes exist */
  open c_get_thirdparty_count
  (p_shipment_header_id, r_rcv_transactions.vendor_id);
  fetch c_get_thirdparty_count into ln_thirdparty_count;
  close c_get_thirdparty_count;

  if nvl(ln_thirdparty_count, 0) = 0 then
    /* Not an error condition, but no need to process */

    if p_debug >= 1 then
      Fnd_File.put_line(Fnd_File.LOG,
      '  Debug Level 1 : There does not exist any third party tax for this shipment, no need to process' );
    end if;

    goto exit_from_procedure;
  end if;


  /* Validation#3 : Check if any third party taxes exist  with null site*/
/* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive := 'RECEIVE' ;
  lv_ttype_correct := 'CORRECT' ;

  open c_get_thirdparty_null_site_cnt
  (p_shipment_header_id, r_rcv_transactions.vendor_id);
  fetch c_get_thirdparty_null_site_cnt into ln_thirdparty_null_site_cnt;
  close c_get_thirdparty_null_site_cnt;

  if nvl(ln_thirdparty_null_site_cnt, 0) > 0 then

    if p_debug >= 1 then
      Fnd_File.put_line(Fnd_File.LOG,
      '  Debug Level 1 : Error : Third party tax for this shipment exists without site, cannot process ' );
    end if;

    p_process_flag := 'E';
    p_process_message :=  'Error : Third party tax for this shipment exists without site, cannot process ';
    goto exit_from_procedure;

  end if;


  /* Validation#4 : Check if any third party taxes exist with invalid vendor and site combinations */
  /* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive := 'RECEIVE' ;
  lv_ttype_correct := 'CORRECT' ;
  open c_get_tparty_invalid_comb_cnt
  (p_shipment_header_id, r_rcv_transactions.vendor_id);
  fetch c_get_tparty_invalid_comb_cnt into ln_tparty_invalid_comb_cnt;
  close c_get_tparty_invalid_comb_cnt;

  if nvl(ln_tparty_invalid_comb_cnt, 0) > 0 then

    if p_debug >= 1 then
      Fnd_File.put_line(Fnd_File.LOG,
      '  Debug Level 1 : Error : ' ||
      'Third party tax for this shipment exists with invalid vendor and site combination, cannot process ' );
    end if;

    p_process_flag := 'E';
    p_process_message :=
    'Error : Third party tax for this shipment exists with invalid vendor and site combination, cannot process ';
    goto exit_from_procedure;

  end if;


  /* All validations are over, control comes here only when the record to be processed is valid */

  /* Get the details required for generating AP invoices */
  open c_get_assets_tracking_flag(p_shipment_header_id);
  fetch c_get_assets_tracking_flag into lv_assets_tracking_flag;
  close c_get_assets_tracking_flag;

  open c_rcv_shipment_headers(p_shipment_header_id);
  fetch c_rcv_shipment_headers into lv_receipt_num;
  close c_rcv_shipment_headers;

  if r_rcv_transactions.po_distribution_id is not null then

    open c_get_po_dist_account(r_rcv_transactions.po_distribution_id);
    fetch c_get_po_dist_account into ln_accrual_account;
    close c_get_po_dist_account;

  elsif r_rcv_transactions.po_line_location_id is not null  then

    open c_get_latest_po_dist_account(r_rcv_transactions.po_line_location_id);
    fetch c_get_latest_po_dist_account into ln_accrual_account;
    close c_get_latest_po_dist_account;

  end if;

  if ln_accrual_account is null then
    p_process_flag := 'E';
    p_process_message :=  'Error : Accrual account not defined, cannot process ';
    goto exit_from_procedure;
  end if;

  -- get the functional currency
  jai_rcv_utils_pkg.get_func_curr
  (
  r_rcv_transactions.organization_id,
  lv_func_currency,
  ln_gl_set_of_books_id
  );

  /* Added by Ramananda for removal of SQL LITERALs */
  lv_ttype_receive := 'RECEIVE' ;
  lv_ttype_correct := 'CORRECT' ;

  For c_thirdparty_tax_rec IN
  (
  /*Bug 4941642. Added by Lakshmi Gopalsami
    (1) Added shipment header id condition
    (2) added aliases.
    (3) Removed two separate conditions on jai_rcv_Transactions
        and clubbed into a single one.
  */
 select
   jrtv.vendor_id
 , jrtv.vendor_site_id
 , jrtv.currency
 , sum(nvl(jrtv.tax_amount,0)) tax_amount
 --, nvl(jcta.inclusive_tax_flag,'N') inc_tax_flag --added by eric for inclusive tax
 , MAX(NVL(jcta.inclusive_tax_flag,'N')) inc_tax_flag --modified by eric for bug#6997730 on Apr-24,2008
 from
    JAI_RCV_TAX_V jrtv
  , jai_cmn_taxes_all jcta --added by eric for inclusive tax
  where
  ( jrtv.transaction_id, jrtv.shipment_line_id ) IN
  (  select transaction_id, shipment_line_id
              from   JAI_RCV_TRANSACTIONS jrt
              where shipment_header_id = p_shipment_header_id
          and ( transaction_type = lv_ttype_receive --'RECEIVE'
                       or
                       (transaction_type = lv_ttype_correct
           and parent_transaction_type = lv_ttype_receive)
                     )
              and    third_party_flag = 'N'

  )
  and   jrtv.tax_type not in (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
  and   jrtv.vendor_id > 0
  and   nvl(jrtv.tax_amount, 0) is not null
  and   jrtv.vendor_id <> r_rcv_transactions.vendor_id /* bug#3957167 */
  and   jrtv.shipment_header_id = p_shipment_header_id
  and   jrtv.tax_id     = jcta.tax_id --added by eric for inclusive tax
  GROUP BY
    jrtv.vendor_id
  , jrtv.vendor_site_id
  , jrtv.currency
  -- , NVL(jcta.inclusive_tax_flag,'N') --deleted by eric for bug#6997730 on Apr-24,2008
  having sum(nvl(jrtv.tax_amount,0))  > 0 /* added to take care of complete CORRECTION */
  )
  loop
    Fnd_File.put_line(Fnd_File.LOG, ' ');
    Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 2 : Loop Begin');
    Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : c_thirdparty_tax_rec.vendor_id,c_thirdparty_tax_rec.vendor_site_id,c_thirdparty_tax_rec.currency,c_thirdparty_tax_rec.inc_tax_flag :'
                     || c_thirdparty_tax_rec.vendor_id ||' , '||c_thirdparty_tax_rec.vendor_site_id ||' , '||c_thirdparty_tax_rec.currency ||' , '||c_thirdparty_tax_rec.inc_tax_flag  );
    Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : ln_vendor_id,ln_vendor_site,lv_currency :'|| ln_vendor_id||' , '||ln_vendor_site||' , '||lv_currency );

    IF ln_vendor_id <> c_thirdparty_tax_rec.vendor_id  OR  ln_vendor_site <> c_thirdparty_tax_rec.vendor_site_id OR lv_currency <> c_thirdparty_tax_rec.currency
    THEN
       lv_vendor_has_changed := 'TRUE';

       ln_vendor_id   := c_thirdparty_tax_rec.vendor_id;
       ln_vendor_site := c_thirdparty_tax_rec.vendor_site_id;
       lv_currency    := c_thirdparty_tax_rec.currency;
    ELSE
       lv_vendor_has_changed := 'FALSE';
    END IF;

    Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : lv_vendor_has_changed :'|| lv_vendor_has_changed );

    if lv_vendor_has_changed = 'TRUE' THEN

        lv_description := null;
        ln_tax_amount := null;
        ld_goods_received_date := null;

        -- get the third party vendor details
        r_get_vendor_details := null;
/* following cursor open added by cbabu for bug#5613772 */
        OPEN c_get_vendor_site_dtls(c_thirdparty_tax_rec.vendor_site_id);
        FETCH c_get_vendor_site_dtls INTO r_get_vendor_details;
        CLOSE c_get_vendor_site_dtls;

  ln_org_id := r_get_vendor_details.org_id;    -- added by csahoo for bug#6139899
        /* following if added by cbabu for bug#5613772 */
        IF r_get_vendor_details.terms_id IS NULL
          OR r_get_vendor_details.payment_method_lookup_code IS null
          OR r_get_vendor_details.pay_group_lookup_code IS NULL
        then
        open c_get_vendor_details(c_thirdparty_tax_rec.vendor_id);
        fetch c_get_vendor_details into r_get_vendor_details;
        close c_get_vendor_details;
        END if;

      --commented out by eric for inclusive tax ,begin
      --lv_description := 'Invoice for vendor '|| r_get_vendor_details.vendor_name ||' against receipt no. '|| lv_receipt_num;
      --commented out by eric for inclusive tax ,end


      --added by eric for inclusive tax on 20-dec,2007, Begin
      -----------------------------------------------------------------------
      IF (c_thirdparty_tax_rec.inc_tax_flag = 'N') --exclusive tax case
      THEN
        ln_lines_to_insert :=1 ;
        Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 :Tax is an exclusive tax.Only one AP invoice will be created');
      ELSE
        ln_lines_to_insert :=2 ;
        Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 :Tax is an inclusive tax. Two AP invoices will be created');
      END IF;--(c_thirdparty_tax_rec.inc_tax_flag = 'N')

      Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 :c_thirdparty_tax_rec.inc_tax_flag :'|| c_thirdparty_tax_rec.inc_tax_flag);
      Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 :ln_lines_to_insert: ' || ln_lines_to_insert );
      Fnd_File.put_line(Fnd_File.LOG, ' ');

      FOR i in 1 .. ln_lines_to_insert
      LOOP
      -----------------------------------------------------------------------
      --added by eric for inclusive tax on 20-dec,2007,END

        open c_get_inv_run_no;
        fetch c_get_inv_run_no into ln_inv_run_no;
        close c_get_inv_run_no;


        --commented out by eric for inclusive tax ,begin
        --lv_invoice_num := 'RECEIPT/'||lv_receipt_num || '/' || to_char(ln_inv_run_no);
        --commented out by eric for inclusive tax ,end



        --added by eric for inclusive tax on 20-dec,2007, Begin
        -----------------------------------------------------------------------
        Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : lv_description and lv_invoice_num  begin:');
        IF (i =1 ) --normal third party invoice
        THEN
          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2,i =1 Branch :');


          lv_description := 'Invoice for vendor '
                            || r_get_vendor_details.vendor_name
                            ||' against receipt no. '|| lv_receipt_num;
          lv_invoice_num := 'RECEIPT/'||lv_receipt_num || '/'
                            || to_char(ln_inv_run_no);

          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2,i =1 Branch :  lv_description :' || lv_description);
          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2,i =1 Branch :  lv_invoice_num :' || lv_invoice_num);
        ELSE --(i =2 ),normal third party invoice--debit memo invoice
          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2 : i =2 Branch :');

          lv_description := 'Credit Memo for inclusive 3rd party taxes for'
                              ||' receipt No. ' || lv_receipt_num;
          lv_invoice_num := 'ITP-CM/'|| lv_receipt_num || '/'
                            ||to_char(ln_inv_run_no);

          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2,i =2 Branch :  lv_description :' || lv_description);
          Fnd_File.put_line(Fnd_File.LOG, '    ** Debug Level 2,i =2 Branch :  lv_invoice_num :' || lv_invoice_num);
        END IF;--(i =1 )

        Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : lv_description and lv_invoice_num  end:');
        Fnd_File.put_line(Fnd_File.LOG, ' ');
        -----------------------------------------------------------------------
        --added by eric for inclusive tax on 20-dec,2007, end


        ln_tax_amount := c_thirdparty_tax_rec.tax_amount;

        if c_thirdparty_tax_rec.currency  <> lv_func_currency  then
            lv_currency_conversion_type := r_rcv_transactions.currency_conversion_type;
            lv_currency_conversion_rate := r_rcv_transactions.currency_conversion_rate;
            lv_currency_conversion_date := r_rcv_transactions.currency_conversion_date;
        else
            lv_currency_conversion_type := null;
            lv_currency_conversion_rate := null;
            lv_currency_conversion_date := null;
        end if;

        -- get the details for the vendor site
        open c_get_goods_received_date(c_thirdparty_tax_rec.vendor_id , c_thirdparty_tax_rec.vendor_site_id);
        fetch c_get_goods_received_date into ld_goods_received_date;
        close c_get_goods_received_date;

        SELECT jai_rcv_tp_invoices_s.nextval
        INTO   ln_batch_invoice_id
        FROM   DUAL;

        --Tax table need to be inserted once only
        --added by eric for inclusive tax on 20-dec,2007, Begin
        -----------------------------------------------------------------------
        IF (i =1 )
        THEN
          Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : jai_rcv_tp_invoice stable insert beign:');
        -----------------------------------------------------------------------
        --added by eric for inclusive tax on 20-dec,2007, end
          Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 ,jai_rcv_tp_invoice table insert : i =1 Branch :');
          Fnd_File.put_line(Fnd_File.LOG, '       DEBUG : 1. Before insert into jai_rcv_tp_invoices ' );


           insert into jai_rcv_tp_invoices
           (
             batch_invoice_id           ,
             batch_id                   ,
             shipment_header_id         ,
             vendor_id                  ,
             vendor_site_id             ,
             invoice_num                ,
             invoice_currency_code      ,
             invoice_amount             ,
             created_by                 ,
             creation_date              ,
             last_update_login          ,
             last_update_date           ,
             last_updated_by,
             program_application_id,
            program_id,
            program_login_id,
            request_id
           )
           values
           (
             ln_batch_invoice_id ,
             p_batch_id,
             p_shipment_header_id,
             c_thirdparty_tax_rec.vendor_id,
             c_thirdparty_tax_rec.vendor_site_id,
             lv_invoice_num,
             c_thirdparty_tax_rec.currency,
             round(ln_tax_amount,2),
             ln_uid,
             sysdate,
             ln_uid,
             sysdate,
             null,
            fnd_profile.value('PROG_APPL_ID'),
            fnd_profile.value('CONC_PROGRAM_ID'),
            fnd_profile.value('CONC_LOGIN_ID'),
            fnd_profile.value('CONC_REQUEST_ID')
           );

           Fnd_File.put_line(Fnd_File.LOG, '       DEBUG : 2. After insert into jai_rcv_tp_invoices ' );
           Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 :jai_rcv_tp_invoice table insert end:');
           Fnd_File.put_line(Fnd_File.LOG, '   ');
        --added by eric for inclusive tax on 20-dec,2007, Begin
        -----------------------------------------------------------------------
        END IF;--(i =1 )
        -----------------------------------------------------------------------
        --added by eric for inclusive tax on 20-dec,2007, end


        /* Call the package to insert data into ap interface */
        if p_simulation <> 'Y' then

          ln_interface_invoice_id := null;
          ln_interface_line_id    := null;

          --Ap invoice interface table need to be inserted twice if necessary
          --the first time is for the normal third party inv
          --the second time is for the credit memo ,in case of inclusive tax

          Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : insertface table insert begin:');

          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          IF (i =1 )
          THEN
          -----------------------------------------------------------------------
          --added by eric for inclusive tax on 20-dec,2007, end
            Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 ,insertface table : i =1 Branch :');
            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 3. Before insert into insert_ap_inv_interface for Standard Invoice' );

            jai_ap_utils_pkg.insert_ap_inv_interface
            (
              p_jai_source                  =>        'Third Party Invoices',
              p_invoice_id                  =>        ln_interface_invoice_id,
              p_invoice_num                 =>        lv_invoice_num,
              p_invoice_type_lookup_code    =>        'STANDARD',
              p_invoice_date                =>        r_rcv_transactions.transaction_date,  /* bug 9141528 */
              p_vendor_id                   =>        c_thirdparty_tax_rec.vendor_id,
              p_vendor_site_id              =>        c_thirdparty_tax_rec.vendor_site_id,
              p_invoice_amount              =>        round(ln_tax_amount,2),
              p_invoice_currency_code       =>        c_thirdparty_tax_rec.currency,
              p_exchange_rate               =>        lv_currency_conversion_rate,
              p_exchange_rate_type          =>        lv_currency_conversion_type,
              p_exchange_date               =>        lv_currency_conversion_date,
              p_terms_id                    =>        r_get_vendor_details.terms_id,
              p_description                 =>        lv_description,
              p_source                      =>        'INDIA TAX INVOICE', /*  --'RECEIPT', --Ramanand for bug#4388958 */
              p_voucher_num                 =>        lv_invoice_num,
              --p_payment_method_lookup_code  =>        r_get_vendor_details.payment_method_lookup_code, --commented by Sanjikum for Bug#4482462
              p_pay_group_lookup_code       =>        r_get_vendor_details.pay_group_lookup_code,
              p_goods_received_date         =>        ld_goods_received_date,
              p_created_by                  =>        ln_uid,
              p_creation_date               =>        sysdate,
              p_last_updated_by             =>        ln_uid,
              p_last_update_date            =>        sysdate,
              p_last_update_login           =>        null,
              p_org_id          =>        ln_org_id    -- added by csahoo for bug#6139899
            );

            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 4. After insert Standard third party Invoice :' || lv_invoice_num ||' into insert_ap_inv_interface');
          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          ELSIF (i =2 )
          THEN
            Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 ,insertface table : i =2 Branch :');
            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 5. Before insert into insert_ap_inv_interface for CM ' );

           --added by eric for BUG#6988610  on Apr-24,2008, Begin
           -----------------------------------------------------------------------
            OPEN get_totl_incl_tax_amount
            ( pn_shipment_header_id =>p_shipment_header_id
            , pn_vendor_id          =>c_thirdparty_tax_rec.vendor_id
            , pn_vendor_site_id     =>c_thirdparty_tax_rec.vendor_site_id
            , pv_currency           =>c_thirdparty_tax_rec.currency
            );
            FETCH get_totl_incl_tax_amount
            INTO  ln_totl_incl_tax_amount;
            CLOSE get_totl_incl_tax_amount;
           -----------------------------------------------------------------------
           --added by eric for BUG#6988610  on Apr-24,2008, End

            OPEN  c_get_vendor_site_dtls(r_rcv_transactions.vendor_site_id);
            FETCH c_get_vendor_site_dtls
             INTO orig_vndr_details_rec;
            CLOSE c_get_vendor_site_dtls;


            IF(   orig_vndr_details_rec.terms_id IS NULL
               OR orig_vndr_details_rec.payment_method_lookup_code IS NULL
               OR orig_vndr_details_rec.pay_group_lookup_code IS NULL
              )
            THEN
              OPEN   c_get_vendor_details(r_rcv_transactions.vendor_id);
              FETCH  c_get_vendor_details
               INTO  orig_vndr_details_rec;
              CLOSE  c_get_vendor_details;
            END IF; --  IF( orig_vndr_details_rec.terms_id IS NULL)

            OPEN  c_get_goods_received_date(r_rcv_transactions.vendor_id , r_rcv_transactions.vendor_site_id);
            FETCH c_get_goods_received_date
             INTO ld_orig_goods_recv_date;
            CLOSE c_get_goods_received_date;

            IF r_rcv_transactions.currency_code  <> lv_func_currency  then
              lv_orig_currcy_conver_type  := r_rcv_transactions.currency_conversion_type;
              lv_orig_currcy_conver_rate  := r_rcv_transactions.currency_conversion_rate;
              lv_orig_currcy_conver_date  := r_rcv_transactions.currency_conversion_date;
            ELSE
              lv_orig_currcy_conver_type  := null;
              lv_orig_currcy_conver_rate  := null;
              lv_orig_currcy_conver_date  := null;
            END IF;


            jai_ap_utils_pkg.insert_ap_inv_interface
            (
              p_jai_source                  =>        'Third Party Invoices', --changed by eric for inclusive tax
              p_invoice_id                  =>        ln_interface_invoice_id,
              p_invoice_num                 =>        lv_invoice_num,
              p_invoice_type_lookup_code    =>        'CREDIT', /* CREDIT Memo*/ --changed by eric for inclusive tax
              p_invoice_date                =>        SYSDATE,
              p_vendor_id                   =>        r_rcv_transactions.vendor_id,                 --changed by eric for inclusive tax
              p_vendor_site_id              =>        r_rcv_transactions.vendor_site_id,            --changed by eric for inclusive tax
              --p_invoice_amount              =>        ROUND(-ln_tax_amount,2),                    --changed by eric for inclusive tax,deleted by eric for bug#6988610
              p_invoice_amount              =>        ROUND(-ln_totl_incl_tax_amount,2),            --changed by eric for bug#6988610 on Apr 23,2008
              p_invoice_currency_code       =>        r_rcv_transactions.currency_code,             --changed by eric for inclusive tax
              p_exchange_rate               =>        lv_orig_currcy_conver_type,  --changed by eric for inclusive tax
              p_exchange_rate_type          =>        lv_orig_currcy_conver_rate,  --changed by eric for inclusive tax
              p_exchange_date               =>        lv_orig_currcy_conver_date,  --changed by eric for inclusive tax
              p_terms_id                    =>        orig_vndr_details_rec.terms_id,               --changed by eric for inclusive tax
              p_description                 =>        lv_description,
              p_source                      =>        'INDIA TAX INVOICE', /*  --'RECEIPT', --Ramanand for bug#4388958 */
              p_voucher_num                 =>        lv_invoice_num,
              p_pay_group_lookup_code       =>        orig_vndr_details_rec.pay_group_lookup_code, --changed by eric for inclusive tax
              p_goods_received_date         =>        ld_orig_goods_recv_date,                     --changed by eric for inclusive tax
              p_created_by                  =>        ln_uid,
              p_creation_date               =>        sysdate,
              p_last_updated_by             =>        ln_uid,
              p_last_update_date            =>        sysdate,
              p_last_update_login           =>        null,
              p_org_id          =>        ln_org_id    -- added by csahoo for bug#6139899
            );

            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 6. After insert Credit Memo of third party Invoice :' || lv_invoice_num ||' into insert_ap_inv_interface');
          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          END IF; --(i =1 )
          -----------------------------------------------------------------------
          Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 2 : insertface table insert end:');
          Fnd_File.put_line(Fnd_File.LOG, '   ');
          --added by eric for inclusive tax on 20-dec,2007, end
        end if; /* if p_simulation <> 'Y' then  */



        --Moved the 'END IF' to the line before the end of the first loop

        --Deleted by eric for inclusive tax on Dec 14,2007 Begin
        --END IF; /*  END IF FOR if lv_vendor_has_changed = 'TRUE' THEN */
        --Deleted by eric for inclusive tax on Dec 14,2007 Begin

        /*
        || The following for loop added by ssumaith - bug# 4284505
        */

        /* Added by Ramananda for removal of SQL LITERALs */
        lv_ttype_receive := 'RECEIVE' ;
        lv_ttype_correct := 'CORRECT' ;

        /*Bug 4941642. Added by Lakshmi Gopalsami
          (1) Added shipment header id condition
          (2) added aliases.
          (3) Removed two separate conditions on jai_rcv_Transactions
              and clubbed into a single one.
        */
        FOR Tax_rec IN
        (  SELECT
             jrlt.*
           , NVL(jcta.inclusive_tax_flag,'N') inc_tax_flag --added by eric for inclusive tax
           FROM
             JAI_RCV_LINE_TAXES jrlt
           , jai_cmn_taxes_all  jcta --added by eric for inclusive tax
           WHERE  jrlt.shipment_header_id = p_shipment_header_id
             AND (jrlt.transaction_id, jrlt.shipment_header_id,jrlt.shipment_line_id) in /*modified for bug 8567640 */
                  ( SELECT jrt.transaction_id,jrt.shipment_header_id,jrt.shipment_line_id
                      FROM   JAI_RCV_TRANSACTIONS jrt
                     WHERE jrt.shipment_header_id = p_shipment_header_id
                       AND ( jrt.transaction_type = lv_ttype_receive
                              or
                              (jrt.transaction_type = lv_ttype_correct
                               and jrt.parent_transaction_type = lv_ttype_receive
                              )
                            )
                       AND  jrt.third_party_flag = 'N'
                 )
             AND   jrlt.tax_type NOT IN  (jai_constants.tax_type_tds,jai_constants.tax_type_modvat_recovery)  --'TDS', 'Modvat Recovery')
             AND   jrlt.vendor_id > 0
             AND   nvl(jrlt.tax_amount, 0) IS NOT NULL
             AND   jrlt.vendor_id <> r_rcv_transactions.vendor_id
             AND   jrlt.vendor_id = c_thirdparty_tax_rec.vendor_id
             AND   jrlt.vendor_site_id = c_thirdparty_tax_rec.vendor_site_id
             AND   jrlt.currency       = c_thirdparty_tax_rec.currency
             AND   jrlt.tax_id         = jcta.tax_id  --added by eric for inclusive tax
        )
        LOOP

          Fnd_File.put_line(Fnd_File.LOG, ' ');
          Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 3 : Loop Begin');
          --SELECT  jai_rcv_tp_inv_details_s.nextval      INTO    ln_batch_line_id      FROM    DUAL;

          --tax table need to be populated once only
          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          IF (i =1 )
          THEN
          -----------------------------------------------------------------------
          --added by eric for inclusive tax on 20-dec,2007, end
            Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 3 ,jai_rcv_tp_inv_details table : i =1 Branch :');
            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 7. Before insert into jai_rcv_tp_inv_details' );

            INSERT INTO jai_rcv_tp_inv_details
            (
             BATCH_LINE_ID        ,
             BATCH_INVOICE_ID     ,
             RCV_TRANSACTION_ID   ,
             LINE_NUMBER          ,
             TAX_ID               ,
             TAX_AMOUNT           ,
             TAX_RATE             ,
             TAX_TYPE             ,
             CREATED_BY           ,
             CREATION_DATE        ,
             LAST_UPDATE_DATE     ,
             LAST_UPDATED_BY      ,
             LAST_UPDATE_LOGIN
             )
             VALUES
             (
             --ln_batch_line_id      ,
             jai_rcv_tp_inv_details_s.nextval,
             ln_batch_invoice_id   ,
             tax_rec.transaction_id,
             ln_line_number        ,
             Tax_rec.tax_id        ,
             tax_Rec.tax_amount    ,
             tax_rec.tax_rate      ,
             tax_rec.tax_type      ,
             fnd_global.user_id    ,
             sysdate               ,
             sysdate               ,
             fnd_global.user_id    ,
             fnd_global.login_id
             ) returning BATCH_LINE_ID into ln_BATCH_LINE_ID;
             Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 8. After insert into jai_rcv_tp_inv_details' );
          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          END IF; --(i =1 )
          -----------------------------------------------------------------------
          --added by eric for inclusive tax on 20-dec,2007, end

          lv_description := 'Tax Record for invoice num ' ||  lv_invoice_num || ' For Tax Type =  '|| tax_rec.tax_type ;

          --added by eric for inclusive tax on 20-dec,2007, Begin
          -----------------------------------------------------------------------
          IF (i =1 )
          THEN
            ln_tax_line_amount:=round(tax_Rec.tax_amount,2);
          ELSE--(i =2 )
            ln_tax_line_amount:=round(-tax_Rec.tax_amount,2);
          END IF; --(i =1 )
          -----------------------------------------------------------------------
          --added by eric for inclusive tax on 20-dec,2007, end


          --added by eric for bug 6971486 on 20-Apr,2008, Begin
          -----------------------------------------------------------------------
          IF ( (i =1) OR (i =2 AND tax_rec.inc_tax_flag = 'Y'))
          THEN
          -----------------------------------------------------------------------
          --added by eric for bug 6971486 on 20-Apr,2008, End

            --added by eric for inclusive tax on 20-dec,2007, Begin
            -----------------------------------------------------------------------

  /* added by vumaasha for bug 8238608 */
    OPEN c_trx_dtls(Tax_rec.transaction_id);
    FETCH c_trx_dtls INTO r_trx_dtls;
    CLOSE c_trx_dtls;

    OPEN c_jai_regimes(jai_constants.service_regime); /* SERVICE */
    FETCH c_jai_regimes INTO ln_regime_id;
    CLOSE c_jai_regimes;

    ln_accrue_on_receipt_flag := jai_rcv_trx_processing_pkg.get_accrue_on_receipt
                  (
                    p_po_distribution_id => r_trx_dtls.po_distribution_id,
                    p_po_line_location_id => r_trx_dtls.po_line_location_id
                  );

    IF ln_accrue_on_receipt_flag = 'N' THEN

      ln_accrual_account  :=  jai_cmn_rgm_recording_pkg.get_account
                  (
                    p_regime_id            =>      ln_regime_id,
                    p_organization_type    =>      jai_constants.orgn_type_io,
                    p_organization_id      =>      r_trx_dtls.ship_to_organization_id,
                    p_location_id          =>      r_trx_dtls.ship_to_location_id,
                    p_tax_type             =>      tax_rec.tax_type,
                    p_account_name         =>      jai_constants.recovery_interim
                  );

              Fnd_File.put_line(Fnd_File.LOG, 'Interim Acct CCID for the Transaction id ' || Tax_rec.transaction_id ||' is: '||ln_accrual_account);
    END IF;
  /* end of changes for bug 8238608 */

            jai_ap_utils_pkg.insert_ap_inv_lines_interface
            (
              p_jai_source                  =>        'Third Party Invoices',
              p_invoice_id                  =>        ln_interface_invoice_id,
              p_invoice_line_id             =>        ln_interface_line_id,
              p_line_number                 =>        ln_to_insert_line_number,
              --p_line_type_lookup_code     =>        'MISCELLANEOUS', --deleted by eric FOR BUG bug#6790599
              p_line_type_lookup_code       =>        'ITEM',          --added by eric FOR BUG bug#6790599
              --Modified by eric for inclusive tax ,begin
              p_amount                      =>        ln_tax_line_amount,--  round(tax_Rec.tax_amount,2),
              --Modified by eric for inclusive tax ,end
              p_accounting_date             =>        r_rcv_transactions.transaction_date,
              p_description                 =>        lv_description,
              p_dist_code_combination_id    =>        ln_accrual_account,
              p_assets_tracking_flag        =>        lv_assets_tracking_flag,
              p_created_by                  =>        ln_uid,
              p_creation_date               =>        sysdate,
              p_last_updated_by             =>        ln_uid,
              p_last_update_date            =>        sysdate,
              p_last_update_login           =>        null,
              p_org_id                      =>        ln_org_id   -- added by csahoo for bug#139899
            );
            Fnd_File.put_line(Fnd_File.LOG, '     DEBUG : 10. After insert into insert_ap_inv_lines_interface' );
          --added by eric for bug 6971486 on 20-Apr,2008, Begin
          -----------------------------------------------------------------------
      ln_line_number:=ln_line_number+1; /* added by vumaasha for bug 8965721 */
          END IF;
          -----------------------------------------------------------------------
          --added by eric for bug 6971486 on 20-Apr,2008, End
        END LOOP;
        ln_line_number := 1;     /* modified by vumaasha for bug 8965721 */
    --Added by eric for inclusive tax on Dec 14,2007 Begin
    ------------------------------------------------------------------------------

        Fnd_File.put_line(Fnd_File.LOG, ' ');
        Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 3 : Loop end');
      END LOOP;--( i in 1 .. ln_lines_to_insert)
    END IF; /*  END IF FOR if lv_vendor_has_changed = 'TRUE' THEN */
    ------------------------------------------------------------------------------
    --Added by eric for inclusive tax on Dec 14,2007 End
    Fnd_File.put_line(Fnd_File.LOG, '**** Debug Level 2 : Loop end');
    Fnd_File.put_line(Fnd_File.LOG, '  ');
  end loop; --(For c_thirdparty_tax_rec IN)


  << exit_from_procedure >>
  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug >= 1 then
    Fnd_File.put_line(Fnd_File.LOG, '  ** Debug Level 1 : ' ||
                                    'End of procedure jai_rcv_third_party_pkg.process_receipt for shipment header :' ||
                                    to_char(p_shipment_header_id)
                                    );
  end if;

  return;

exception
  when others then
    p_process_flag := 'E';
    p_process_message := 'jai_rcv_third_party_pkg.process_receipt:' || sqlerrm;
    fnd_file.put_line( fnd_file.log, '******** Error in '||p_process_message);
    raise;

end process_receipt;
/****************************** End process_receipt  ****************************/

/****************************** Start populate_tp_invoice_id  ****************************/
 procedure populate_tp_invoice_id
  (
  p_invoice_id                IN  ap_invoices_all.invoice_id%TYPE,
  p_invoice_num               IN  ap_invoices_all.invoice_num%TYPE,
  p_vendor_id                 IN  ap_invoices_all.vendor_id%TYPE,
  p_vendor_site_id            IN  ap_invoices_all.vendor_site_id%TYPE,
  p_process_flag OUT NOCOPY VARCHAR2,
  p_process_message OUT NOCOPY VARCHAR2
  )
  IS

  /*
  || This procedure is added by ssumaith - bug# 4284505 for updating the invoice_id in the jai_Rcv_tp_invoices table
  || This procedure will be called from the trigger - ja_in_ap_aia_before_trg on ap_invoices_all
  */
  BEGIN

    UPDATE    jai_rcv_tp_invoices
    SET       invoice_id     = p_invoice_id ,
              last_update_date = sysdate ,
              last_updated_by  = fnd_global.user_id
    WHERE     invoice_num    = p_invoice_num
    AND       vendor_id      = p_vendor_id
    AND       vendor_site_id = p_vendor_site_id;

    p_process_flag := jai_constants.successful;

  EXCEPTION
  WHEN OTHERS THEN
     p_process_flag    := jai_constants.unexpected_error;
     p_process_message := substr(sqlerrm,1,1000);

  END;

/****************************** End populate_tp_invoice_id  ****************************/


end jai_rcv_third_party_pkg;

/
