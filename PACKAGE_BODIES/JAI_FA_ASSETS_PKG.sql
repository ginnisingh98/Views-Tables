--------------------------------------------------------
--  DDL for Package Body JAI_FA_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_FA_ASSETS_PKG" AS
/* $Header: jai_fa_ast.plb 120.4 2007/04/18 13:41:04 kunkumar ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_fa_ast -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

14-Jun-2005   rchandan for bug#4428980, Version 116.3
              Modified the object to remove literals from DML statements and CURSORS.

24-Jun-2005   rchandan for bug#4454657, Version 116.4
              Modified the object as a part of AP LINES Impact Uptake
        A column invoice_line_number ie added to jai_fa_mass_additions.
        The ap_invoice_lines_all is used instead of ap_invoice_distributions_all while querying wherever applicable.
        While calculating the apportion factor the distribution amount is taken instead of line amount.

10     07/12/2005   Hjujjuru for the bug 4866533 File version 120.2
                    added the who columns in the insert into table JAI_RCV_CENVAT_CLAIM_T
                    Dependencies Due to this bug:-
                    None
02/11/2006  for Bug 5228046, File version 120.3
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.

16/04/2007  Kunkumar for bug no 5989740 for
              forward porting ja_in_fa_mass_additions_p.sql;     version 115.3.6107.2  to R12
-------------------------------------------------------------------------------------------
*/

procedure mass_additions
(
errbuf               out NOCOPY varchar2,
retcode              out NOCOPY varchar2,
p_parent_request_id           in  number
)
is

  cursor c_ja_in_fa_mass_additions(p_parent_request_id number) is
    select  a.rowid, a.*
    from   JAI_FA_MASS_ADDITIONS a
    where (p_parent_request_id IS NULL OR create_batch_id = p_parent_request_id)
    and    process_flag <> 'Y'
    FOR UPDATE OF process_flag;

 /* cursor c_ap_invoice_distributions_all
  (p_invoice_id number, p_distribution_line_number  number) is
    select  po_distribution_id,
            rcv_transaction_id,
            invoice_distribution_id,
            set_of_books_id,
            exchange_rate
    from    ap_invoice_distributions_all
    where   invoice_id = p_invoice_id
    and     distribution_line_number = p_distribution_line_number;*/ /*rchandan for bug#4454657 commented AND the following two CURSORs have been added */

  cursor c_ap_invoice_lines_all
  (p_invoice_id number, p_line_number  number) is
    select  po_distribution_id,
            rcv_transaction_id,
            set_of_books_id,
            amount
    from    ap_invoice_lines_all
    where   invoice_id = p_invoice_id
    and     line_number = p_line_number;

   CURSOR c_exchange_rate
    (p_invoice_id number) is
    SELECT exchange_rate
      FROM ap_invoices_all
     WHERE invoice_id = p_invoice_id;

   cursor c_ap_invoice_distributions_all(p_invoice_id number, p_invoice_line_number number, p_distribution_line_number number) is /*rchandan for bug#4428980*/
    select amount
    from   ap_invoice_distributions_all
    where  invoice_id =  p_invoice_id
    and    invoice_line_number = p_invoice_line_number
    and    distribution_line_number = p_distribution_line_number;


  cursor c_rcv_transactions(p_transaction_id number) is
    select  shipment_line_id,
            vendor_id
    from    rcv_transactions
    where   transaction_id = p_transaction_id;

  /* Added by LGOPALSA. Bug 4210102.
   * Added CVD and Customs Education Cess */
  cursor  c_ja_in_receipt_tax_lines(p_shipment_line_id number, p_po_vendor_id number) is
    select  tax_id, currency, tax_amount, tax_type, tax_name, vendor_id
    from    JAI_RCV_LINE_TAXES
    where   shipment_line_id = p_shipment_line_id
    and
            (
              (tax_type in  (
	                       jai_constants.tax_type_cvd,
			       jai_constants.tax_type_add_cvd ,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI
			       jai_constants.tax_type_customs,/*rchandan for bug#4428980*/
                               jai_constants.tax_type_customs_Edu_cess,
                               jai_constants.tax_type_cvd_edu_Cess,jai_constants.tax_type_sh_customs_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess)) /* BOE Tax Added higher education cess for bug #5907436  ; kundan kumar */
			                   or
              (tax_type not in (jai_constants.tax_type_tds,  jai_constants.tax_type_modvat_recovery) /* Third party tax */--rchandan for bug#4428980
              and  vendor_id > 0
              and  vendor_id <> p_po_vendor_id
              )
            );

  cursor  c_ja_in_tax_codes(p_tax_id number) is
    select  mod_cr_percentage
    from    JAI_CMN_TAXES_ALL
    where   tax_id = p_tax_id;

  cursor c_get_fa_mass_addition_id is
    select fa_mass_additions_s.nextval
    from dual;

  r_ap_invoice_lines_all        c_ap_invoice_lines_all%rowtype;
  r_rcv_transactions                    c_rcv_transactions%rowtype;
  r_ja_in_receipt_tax_lines             c_ja_in_receipt_tax_lines%rowtype;
  r_ja_in_tax_codes                     c_ja_in_tax_codes%rowtype;
  ln_no_of_tax_for_inv_line             number;
  lv_phase                              varchar2(100);
  lv_status                             varchar2(100);
  lv_dev_phase                          varchar2(100);
  lv_dev_status                         varchar2(100);
  lv_message                            varchar2(100);
  lb_req_status                         boolean := true;
  ln_fa_mass_addition_id                number;
  ln_apportion_factor                   number;
  ln_tax_amount                         number;
  lv_error_message                      varchar2(150);

  lv_object_name CONSTANT VARCHAR2(61) := 'jai_fa_ast_pkg.mass_additions';
  lv_new         CONSTANT varchar2(30) := 'NEW';  --rchandan for bug#4428980
  lv_feeder_system_name fa_mass_additions.feeder_system_name%TYPE ;--rchandan for bug#4428980
  lv_exchange_rate  ap_invoices_all.exchange_rate%type; --rchandan for ap lines
  ln_distribution_amount               number;



begin

/*-----------------------------------------------------------------------------
Filename: mass_additions.sql

CHANGE HISTORY:

S.No    dd/mm/yyyy      Author and Details
----    -------         ------------------
1       22/07/2004      Aparajita. Version # 115.0. Created for ER#3575112.

            This procedure processes all records that have not already
            been processed earlier. This is checked by the process_flag
            value of 'Y' for processed records.

            Records are populated onto the table JAI_FA_MASS_ADDITIONS by
            the trigger ja_in_fa_mass_additions_boe3p after insert
            on fa_mass_additions.

            In FA all amounts are posted in functional currency and hence 'INR'
            is hardcoded.

            IF called from the trigger a parent request id is passed on to
            this procedure, but for submission from SRS, this is null.

2     12/03/2005        Bug 4210102. Added by LGOPALSA  Version 115.1
                        (1) Added CVD and customs education cess
            (2) Added check file syntax in dbdrv


===============================================================================
Dependencies

Version   Author       Dependency     Comments
115.1     LGOPALSA      IN60106 +     Service + Cess tax dependency
                        4146708
-----------------------------------------------------------------------------*/

  if p_parent_request_id is not null then

    lb_req_status :=
    Fnd_concurrent.wait_for_request
    (
    p_parent_request_id,
    60, /* default value - sleep time in secs */
    0, /* default value - max wait in secs */
    lv_phase,
    lv_status,
    lv_dev_phase,
    lv_dev_status,
    lv_message
    );

    if lv_dev_phase = 'COMPLETE' then
      if lv_dev_status <> 'NORMAL' then
        Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as parent request not completed with normal status');
        Fnd_File.put_line(Fnd_File.LOG, 'Message from parent request :' || lv_message);
        retcode := 1;
        errbuf := 'Exiting with warningr as parent request not completed with normal status';
        return;
      end if;
    end if;

  end if; /* p_parent_request_id is not null */

  Fnd_File.put_line(Fnd_File.LOG,
  'Process Details for mass addition id / Invoice number / Distribution Line No / No of tax lines inserted :');

  for cur_rec_invoice_line in c_ja_in_fa_mass_additions(p_parent_request_id) loop


    begin

      open c_ap_invoice_lines_all
      (cur_rec_invoice_line.invoice_id, cur_rec_invoice_line.invoice_line_number);
      fetch c_ap_invoice_lines_all into r_ap_invoice_lines_all;
      close c_ap_invoice_lines_all;


      open c_rcv_transactions(r_ap_invoice_lines_all.rcv_transaction_id);
      fetch c_rcv_transactions into r_rcv_transactions;
      close c_rcv_transactions;

      /* Appotion factor between receipt and invoice */
      ln_apportion_factor :=
      jai_ap_utils_pkg.get_apportion_factor(cur_rec_invoice_line.invoice_id, cur_rec_invoice_line.invoice_line_number);  /*rchandan for bug#4454657*/

      open  c_ap_invoice_distributions_all  /*rchandan for bug#4454657*/
      (cur_rec_invoice_line.invoice_id, cur_rec_invoice_line.invoice_line_number, cur_rec_invoice_line.distribution_line_number);
      fetch c_ap_invoice_distributions_all into ln_distribution_amount;
      close c_ap_invoice_distributions_all;

      ln_apportion_factor := ln_apportion_factor * (ln_distribution_amount / r_ap_invoice_lines_all.amount); /*rchandan for bug#4454657*/

      ln_no_of_tax_for_inv_line := 0;

      for cur_rec_taxes in
      c_ja_in_receipt_tax_lines(r_rcv_transactions.shipment_line_id, r_rcv_transactions.vendor_id)
      loop

        open  c_ja_in_tax_codes(cur_rec_taxes.tax_id);
        fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
        close c_ja_in_tax_codes;

        ln_tax_amount := cur_rec_taxes.tax_amount * ln_apportion_factor;

        if  cur_rec_taxes.currency <> 'INR' then
          /* Tax currenyc is not the functional currency -- need to convert */
    OPEN c_exchange_rate(cur_rec_invoice_line.invoice_id); /*rchandan for bug#4454657*/
    FETCH c_exchange_rate INTO lv_exchange_rate;
    CLOSE c_exchange_rate;

          ln_tax_amount := ln_tax_amount * nvl(lv_exchange_rate, 1); /*rchandan for bug#4454657*/
        end if;

        /* get recoverrable portion of the tax */
        ln_tax_amount := ln_tax_amount * ( ( 100 - nvl(r_ja_in_tax_codes.mod_cr_percentage, 0) ) / 100 );

        ln_tax_amount := round(ln_tax_amount, 2);

        if ln_tax_amount = 0 then
          goto continue_with_next_tax;
        end if;

        ln_fa_mass_addition_id := null;

        open c_get_fa_mass_addition_id;
        fetch c_get_fa_mass_addition_id into ln_fa_mass_addition_id;
        close c_get_fa_mass_addition_id;

  lv_feeder_system_name := 'ORACLE INDIA PAYABLES';   /*rchandan for bug#4428980*/

        insert into fa_mass_additions
        (
        mass_addition_id,
        description,
        book_type_code,
        date_placed_in_service,
        fixed_assets_cost,
        payables_units,
        fixed_assets_units,
        payables_code_combination_id,
        feeder_system_name,
        create_batch_date,
        invoice_number,
        accounting_date,
        vendor_number,
        po_number,
        po_vendor_id,
        posting_status,
        queue_name,
        invoice_date,
        payables_cost,
        depreciate_flag,
        asset_type,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login
        )
        values
        (
        ln_fa_mass_addition_id,
        cur_rec_taxes.tax_name,
        cur_rec_invoice_line.book_type_code,
        cur_rec_invoice_line.date_placed_in_service,
        ln_tax_amount, /* fixed_assets_cost */
        1, /*payables_units*/
        1, /*fixed_assets_units */
        cur_rec_invoice_line.payables_code_combination_id,
        lv_feeder_system_name, /*feeder_system_name */  /*rchandan for bug#4428980*/
        cur_rec_invoice_line.create_batch_date,
        cur_rec_invoice_line.invoice_number,
        cur_rec_invoice_line.accounting_date,
        cur_rec_invoice_line.vendor_number,
        cur_rec_invoice_line.po_number,
        cur_rec_taxes.vendor_id, /* Tax vendor */
        lv_new, /* posting status *//*rchandan for bug#4428980*/
        lv_new, /* Queue Name *//*rchandan for bug#4428980*/
        cur_rec_invoice_line.invoice_date,
        ln_tax_amount, /*payables_cost*/
        cur_rec_invoice_line.depreciate_status,
        cur_rec_invoice_line.asset_type,
        cur_rec_invoice_line.created_by,
        sysdate, /* creation_date */
        sysdate,  /*last_update_date*/
        cur_rec_invoice_line.last_updated_by,
        cur_rec_invoice_line.last_update_login
        );

        ln_no_of_tax_for_inv_line := ln_no_of_tax_for_inv_line +1;

        << continue_with_next_tax >>
        null;

      end loop;  /** tax for the given invoice item line from corresponding receipt line **/
      lv_error_message := 'Processed Successfully on / no of tax lines inserted :'
                                || to_char(sysdate) || ' / ' || to_char(ln_no_of_tax_for_inv_line);/*rchandan for bug#4428980*/

      update  JAI_FA_MASS_ADDITIONS
      set     process_flag = 'Y',
              process_message = lv_error_message,/*rchandan for bug#4428980*/
              last_update_date = sysdate
      where   rowid = cur_rec_invoice_line.rowid;

      Fnd_File.put_line(Fnd_File.LOG,
      '  Successful :' ||
      to_char(cur_rec_invoice_line.mass_addition_id) || ' / ' ||
      cur_rec_invoice_line.invoice_number || ' / ' ||
      cur_rec_invoice_line.distribution_line_number || ' / ' ||
      to_char(ln_no_of_tax_for_inv_line)
      );


    exception

      when others then

        lv_error_message := substr(sqlerrm, 1, 150);

        update  JAI_FA_MASS_ADDITIONS
        set     process_flag = 'E',
                process_message = lv_error_message,
                last_update_date = sysdate
      where   rowid = cur_rec_invoice_line.rowid;

        Fnd_File.put_line(Fnd_File.LOG,
        '****  Processed with Error for mass addition id / Invoice number / Distribution Line No / Error :' ||
        to_char(cur_rec_invoice_line.mass_addition_id) || ' / ' ||
        cur_rec_invoice_line.invoice_number || ' / ' ||
        cur_rec_invoice_line.distribution_line_number || ' / ' ||
        lv_error_message
        );
    end;

  end loop; /*cur_rec_invoice_line*/

exception
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;
end mass_additions;

PROCEDURE claim_excise_on_retirement(
   retcode                out nocopy  varchar2,
   errbuf                 out nocopy  varchar2,
   p_organization_id                  number,
   p_location_id                      number,
   p_receipt_num                      varchar2,
   p_shipment_line_id                 number,
   p_booktype_id                      varchar2,
   p_asset_id                         number
 )is

  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. V_ERRBUF VARCHAR2(1000);
  --V_RETCODE NUMBER;
  --V_SYSDATE      DATE := SYSDATE;
  --V_UID          NUMBER := UID;

  V_DEBUG             CHAR(1); --:='Y'; --Ramananda for File.Sql.35
  V_PO_NUMBER_ASSET   NUMBER;
  V_PO_NUMBER_RECEIPT NUMBER;

  /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  lv_errbuf     VARCHAR2(1000);
  lv_retcode    VARCHAR2(30);
  ln_batch_identifier NUMBER;
  lv_transaction_type VARCHAR2(30);--rchandan for bug#4428980

BEGIN
/*------------------------------------------------------------------------------------------
   FILENAME: claim_excise_on_retirement.sql
   CHANGE HISTORY:

    1.  2002/12/16   Nagaraj.s - For Bug#2635151 - 116.0(615.1)
                     This Procedure is a wrapper which is called
                     from India-Claim Modvat on Retired Assets concurrent Program
                     registered in India Local Fixed Assets. This will first select
                     the PO Number for the Asset and also the PO Number for the
                     receipt selected by the user and if these 2 tally will loop
                     around for the Organization_Id,Receipt_Num and shipment_line_id
                     combination and calls ja_in_claim_modvat_process which in turn
                     handles RG and Accounting Entries. This is mainly for claiming balance
                     50% cenvat for Assets Purchased/Retired in the same financial year.

2. 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *

--------------------------------------------------------------------------------------------*/
  V_DEBUG := jai_constants.yes ; --Ramananda for File.Sql.35

  IF V_DEBUG ='Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'********Start of Claiming Modvat for FA Retirement *********');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'1.0 The Value of p_organization_id:' ||p_organization_id
      ||', p_location_id:' ||p_location_id||', p_receipt_num:' ||p_receipt_num
      ||', p_shipment_line_id:' ||p_shipment_line_id||', p_booktype_id:' ||p_booktype_id
      ||', p_asset_id:' ||p_asset_id);
  END IF;

   --This is  fetching the PO Number for the Asset........
   FOR C_FETCH_PO_NUMBER IN
   (SELECT PO_NUMBER
    FROM FA_ASSET_INVOICES
    WHERE ASSET_ID=P_ASSET_ID
   )
   LOOP
    V_PO_NUMBER_ASSET := C_FETCH_PO_NUMBER.PO_NUMBER;
   END LOOP;
   IF V_DEBUG ='Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'1.5 The PO Number for the Asset is ' ||V_PO_NUMBER_ASSET);
   END IF;
   --Ends here for PO Number Asset
   lv_transaction_type := 'RECEIVE';  --rchandan for bug#4428980
    --This is for Fetching the PO Number for the Receipt Number...............
   FOR C_FETCH_PO_NUMBER_RECEIPT IN
    (
    SELECT SEGMENT1
    FROM PO_HEADERS_ALL A, RCV_TRANSACTIONS B, RCV_SHIPMENT_HEADERS C
    WHERE A.PO_HEADER_ID     = B.PO_HEADER_ID
    AND B.SHIPMENT_HEADER_ID = C.SHIPMENT_HEADER_ID
    AND B.TRANSACTION_TYPE   =lv_transaction_type--rchandan for bug#4428980
    AND A.VENDOR_ID          = B.VENDOR_ID
    AND A.VENDOR_SITE_ID     = B.VENDOR_SITE_ID
    AND C.RECEIPT_NUM        =P_RECEIPT_NUM
    AND B.ORGANIZATION_ID    =P_ORGANIZATION_ID
    AND B.SHIPMENT_LINE_ID   =P_SHIPMENT_LINE_ID
    AND ROWNUM=1
   )
   LOOP
    V_PO_NUMBER_RECEIPT := C_FETCH_PO_NUMBER_RECEIPT.SEGMENT1;
   END LOOP;
   IF V_DEBUG ='Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'1.6 The PO Number for the Receipt is ' ||V_PO_NUMBER_RECEIPT);
   END IF;
   --Ends here for PO Number Asset
   IF V_PO_NUMBER_ASSET <> V_PO_NUMBER_RECEIPT THEN
    IF V_DEBUG ='Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'1.61 The PO Numbers are not Matching hence further Processing will not be done');
    END IF;
   END IF;

   IF V_PO_NUMBER_ASSET = V_PO_NUMBER_RECEIPT THEN

    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
    select JAI_RCV_CENVAT_CLAIM_T_S.nextval into ln_batch_identifier from dual; /* changd the name of the sequence - ssumaith - sequence change process*/

    FOR CUR_REC IN
    (
     SELECT
      shipment_line_id,
      -- ATTRIBUTE1,
      -- TO_DATE(ATTRIBUTE2,'YYYY/MM/DD HH24:MI:SS') ATTRIBUTE2,
      transaction_id,
      quantity
     FROM
      JAI_RCV_CLAIM_MODVAT_V
     WHERE
      receipt_num=p_receipt_num
      and to_organization_id=p_organization_id
      and shipment_line_id  =p_shipment_line_id
    )
    LOOP
     IF V_DEBUG ='Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'1.7 shipment_line_id:' ||cur_rec.shipment_line_id
            ||', quantity:' ||cur_rec.quantity||', transaction_id:' ||cur_rec.transaction_id);
     END IF;

    /*Commented. Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
     BEGIN

      UPDATE JAI_RCV_CENVAT_CLAIMS
        SET cenvat_claimed_ptg = 100,
            cenvat_sequence = NVL(cenvat_sequence, 0) + 1,
            last_update_date = trunc(v_sysdate),
            last_updated_by = v_uid,
            last_update_login = v_uid
      WHERE transaction_id = CUR_REC.transaction_id;

    Exception
      WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20010,'Exception Raised in Updation of JAI_RCV_CENVAT_CLAIMS ' || SQLERRM) ;
     END;

     IF V_DEBUG ='Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'2.2 After Update of JAI_RCV_CENVAT_CLAIMS');
     END IF;
    */

     BEGIN
     IF V_DEBUG ='Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'2.3 Before Insert into JAI_RCV_CENVAT_CLAIM_T');
     END IF;


    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    INSERT INTO JA_IN_TEMP_MOD_PARAMS
                 (shipment_line_id,
                  attribute1,
                  attribute2,
                  transaction_id,
                  quantity,
                  cenvat_percent)
    VALUES (CUR_REC.shipment_line_id,
            CUR_REC.ATTRIBUTE1,
            CUR_REC.ATTRIBUTE2, --'YYYY/MM/DD HH24:MI:SS',
            CUR_REC.transaction_id,
            CUR_REC.QUANTITY,
            0.5);--This is made as 0.5 assuming 50% is already claimed.
           */

        /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
        following added as part of DFF Elimination */

        INSERT INTO JAI_RCV_CENVAT_CLAIM_T
        (
          batch_identifier,
          shipment_line_id,
          transaction_id,
          quantity,
          --Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. attribute1,
          --attribute2,
          --cenvat_percent,
          creation_date,
          process_date,
          error_flag,
          error_description,
          process_flag,
          unclaimed_cenvat_amount,
          -- added, Harshita for Bug 4866533
          created_by,
          last_updated_by,
          last_update_date
        )
        VALUES
        (
          ln_batch_identifier,
          CUR_REC.shipment_line_id,
          CUR_REC.transaction_id,
          CUR_REC.quantity,
          --Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. :JA_IN_RCP_LINES.EXCISE_INVOICE_NO,
          --:JA_IN_RCP_LINES.EXCISE_INVOICE_DATE,
          --:JA_IN_RCP_LINES.CURRENT_CENVAT / 100,
          trunc(sysdate),
          null,
          null,
          null,
          'M',    -- Means Claim
          null,
          -- added, Harshita for Bug 4866533
          fnd_global.user_id,
          fnd_global.user_id,
          sysdate
        );

   EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20010,'Exception Raised in Insert of JA_IN_TEMP_MOD_PARAMS ' || SQLERRM) ;
   END;

     IF V_DEBUG ='Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'2.4 After Insert into ja_in_temp_mod_params');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'2.5 Before Claim Modvat Process is called');
     END IF;

     /*
     JA_IN_CLAIM_MODVAT_PROCESS(V_ERRBUF,
                               V_RETCODE,
                               CUR_REC.SHIPMENT_LINE_ID,
                               CUR_REC.ATTRIBUTE1,
                               CUR_REC.ATTRIBUTE2,
                               CUR_REC.TRANSACTION_ID,
                               CUR_REC.QUANTITY,
                               0.5); --This is made as 0.5 assuming 50% is already claimed.
      */


    END LOOP;

    jai_rcv_trx_processing_pkg.process_batch(
        errbuf                => lv_errbuf,
        retcode               => lv_retcode,
        p_organization_id     => null,
        pv_transaction_from    => null,
        pv_transaction_to      => null,
        p_transaction_type    => null,
        p_parent_trx_type     => null,
        p_shipment_header_id  => ln_batch_identifier,
        p_receipt_num         => null,
        p_shipment_line_id    => null,
        p_transaction_id      => null,
        p_commit_switch       => 'N',
        p_called_from         => 'JAINMVAT',
        p_simulate_flag       => 'N',
        p_trace_switch        => 'N'
    );

    if lv_retcode = '1' then
      RAISE_APPLICATION_ERROR(-20111, 'Problem in invocation to jai_rcv_trx_processing_pkg.process_batch.');
    end if;

    IF V_DEBUG ='Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'2.6 After Claim Modvat Process Procedure');
    END IF;

   END IF; --End If for comparison of PO Numbers

EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     RETCODE := 2 ;
     ERRBUF := 'EXCEPTION - JA_IN_BATCH_CLAIM_MODVAT ' || sqlerrm;
END claim_excise_on_retirement;


function get_date_place_in_service(p_asset_id in number) return varchar2
IS
 lv_object_name CONSTANT VARCHAR2(61):= 'jai_fa_assets_pkg.get_date_place_in_service';
 CURSOR cc is SELECT DATE_PLACED_IN_SERVICE FROM FA_BOOKS
WHERE ASSET_ID =p_ASSET_ID;
 da date;
begin
 OPEN cc;
 fetch cc into da;
 close cc;
 return to_char(da,'dd-mon-rrrr');
exception
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

end get_date_place_in_service;

END jai_fa_assets_pkg;

/
