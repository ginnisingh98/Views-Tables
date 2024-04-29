--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_OLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_OLD_PKG" 
/* $Header: jai_ap_tds_old.plb 120.8 2007/05/10 09:46:39 rallamse ship $ */
AS

/*------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_ap_tds_old.plb
------------------------------------------------------------------------------------------
S.No      Date          Author and Details
------------------------------------------------------------------------------------------
1. 02-Sep-2005       Ramananda for Bug#4584221. File Version 120.3
                     1. Procedure PROCESS_PREPAYMENT_UNAPPLY
                        ===================================
                        Made the following changes
                        1) Before submitting the request - APXIIMPT,
                           called the jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id) to get the batch_name.
                        2) In submitting the request - APXIIMPT,
                           changed the parameter batch_name from hardcoded value to variable - lv_batch_name

                     2. Procedure PROCESS_PREPAYMENT_APPLY
                        ==================================
                        Made the following changes -
                        1) Before submitting the request - APXIIMPT,
                           called the jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id) to get the batch_name.
                        2) In submitting the request - APXIIMPT,
                           changed the parameter batch_name from hardcoded value to variable - lv_batch_name

                     3. Procedure CANCEL_INVOICE
                        ========================
                        Made the following changes -
                        1) Before submitting the request - APXIIMPT,
                           called the jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id) to get the batch_name.
                        2) In submitting the request - APXIIMPT,
                           changed the parameter batch_name from hardcoded value to variable - lv_batch_name

                        Dependency Due to this Bug (Functional)
                        --------------------------
                        jai_ap_utils.pls   (120.2)
                        jai_ap_utils.plb   (120.2)
                        jai_ap_tds_gen.plb (120.8)
                        jai_constants.pls  (120.3)
                        jaiorgdffsetup.sql (120.2)
                         jaivmlu.ldt 120.3

2.  02-Dec-2005  Bug 4774647. Added by Lakshmi Gopalsami  Version 120.4
                        Passed operating unit also as this parameter
                        has been added by base .

3    07/12/2005   Hjujjuru ,File version 120.5
                  Bug 4866533
                    added the who columns in the insert of JAI_CMN_ERRORS_T
                    Dependencies Due to this bug:-
                    None
                  Bug 4870243, File version 120.5
                    Issue : Invoice Import Program is rejecting the Invoices.
                    Fix   : Commented the voucher_num insert into the ap_invoices_interface table
4    23/02/07      bduvarag for bug#4716884,File version 120.7
                Forward porting the changes done in 11i bug 4629783

------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE cancel_invoice
(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_invoice_id IN NUMBER    --cbabu Bug#2448040
) IS

--cbabu Bug#2448040
  lv_statement_no  VARCHAR2(3); --  := '0'; --Ramananda for File.Sql.35
  lv_procedure_name VARCHAR2(25); -- := 'jai_ap_tds_old_pkg.cancel_invoice'; --Ramananda for File.Sql.35
  lv_error_mesg VARCHAR2(255); -- := ''; --Ramananda for File.Sql.35

/*CURSOR cancelled_invoices IS
  SELECT *
  FROM ja_in_ap_inv_cancel_temp;
*/

--cbabu Bug#2448040
/* TDS clean up > commented the cursor definition by the one below

CURSOR cancelled_invoices(p_inv_id IN NUMBER) IS
  SELECT *
  FROM  ja_in_ap_inv_cancel_temp
  WHERE invoice_id = p_inv_id;*/

cursor cancelled_invoices(p_inv_id in number) is
  select
        invoice_id,
        invoice_num,
        vendor_id,
        org_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
  from  ap_invoices_all
  where invoice_id = p_inv_id;

CURSOR tds_invoices(inv_id NUMBER) IS
   SELECT tds_invoice_num,tds_tax_id,dm_invoice_num,tds_amount,tds_tax_rate,invoice_amount  -- 4333449
   FROM   JAI_AP_TDS_INVOICES
   WHERE  invoice_id = inv_id;

CURSOR vendor(t_id NUMBER) IS
   SELECT vendor_id
   FROM   JAI_CMN_TAXES_ALL
   WHERE  tax_id = t_id;


CURSOR for_payment_status(inv_num VARCHAR2,vend_id NUMBER,organization NUMBER) IS       ----for information about tds invoice
    SELECT payment_status_flag,invoice_amount,invoice_id, cancelled_date
    FROM   ap_invoices_all
    WHERE  invoice_num = inv_num
    AND    vendor_id = vend_id
    AND    NVL(org_id, 0) = NVL(organization, 0);

CURSOR for_distribution_insertion(inv_id NUMBER) IS
    SELECT distribution_line_number,accounting_date,accrual_posted_flag,reversal_flag,
           assets_addition_flag,assets_tracking_flag,cash_posted_flag,dist_code_combination_id,
           accts_pay_code_combination_id,
           period_name,set_of_books_id,
         amount,match_status_flag,base_amount_to_post,prepay_amount_remaining,
         parent_invoice_id,org_id,description
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = inv_id
    AND    distribution_line_number = (SELECT MAX(distribution_line_number)
                                         FROM   ap_invoice_distributions_all
                                        WHERE  invoice_id = inv_id);

CURSOR for_std_invoice(inv_id NUMBER) IS
    SELECT invoice_type_lookup_code,vendor_id,vendor_site_id,invoice_currency_code,
           exchange_rate,exchange_rate_type,exchange_date,terms_id,payment_method_lookup_code,
           pay_group_lookup_code,goods_received_date,invoice_received_date  --added on 03-12-2001
    FROM   ap_invoices_all
    WHERE  invoice_id = inv_id;

CURSOR Fetch_Inv_Date_Cur( inv_id IN NUMBER ) IS
  SELECT Invoice_date
  FROM   Ap_Invoices_All
  WHERE  Invoice_Id = inv_id;

CURSOR Fetch_App_Inv_Flag_Cur( p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER ) IS
  SELECT NVL( Approved_Invoice_Flag, 'N' ) Approved_Invoice_Flag
  FROM   JAI_CMN_VENDOR_SITES
  WHERE  Vendor_Id = p_vendor_id
  AND    Vendor_Site_Id = p_vendor_site_id;

-- start added for bug#3556035
cursor c_get_can_inv_amount(p_invoice_num in varchar2,
                            p_vendor_id in number,
                            p_vendor_site_id  in number
                           ) is
select -1 * invoice_amount
from   ap_invoices_all
where  invoice_num = p_invoice_num
and    vendor_id = p_vendor_id
and    vendor_site_id = p_vendor_site_id;

CURSOR cur_prnt_pay_priority     -- 4333449
IS
SELECT payment_priority
  FROM ap_payment_schedules_all
 WHERE invoice_id = p_invoice_id;

CURSOR cur_prnt_exchange_rate     -- 4333449
IS
SELECT exchange_rate
  FROM ap_invoices_all
 WHERE invoice_id = p_invoice_id;

-- end added for bug#3556035



for_pay_status_tds_rec                 for_payment_status%ROWTYPE;
for_pay_status_original_rec            for_payment_status%ROWTYPE;
for_distribution_insertion_rec         for_distribution_insertion%ROWTYPE;
for_std_invoice_rec                  for_std_invoice%ROWTYPE;
for_insertion_invoice_id               NUMBER;
insertion_amount                       NUMBER := 0;
new_std_invoice_amount                 NUMBER := 0;
cancelled_invoices_rec               cancelled_invoices%ROWTYPE;
vendor_rec                         vendor%ROWTYPE;
tds_invoices_rec                     tds_invoices%ROWTYPE;
result                           BOOLEAN;
req_id                           NUMBER;
req1_id                          NUMBER;


v_invoice_date                         NUMBER;
v_flag                           VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35
v_approve_flag                         VARCHAR2(1);

v_Approved_Invoice_Flag                CHAR(1); -- := 'N';  -- added by Aparajita on 29/07/2002 for bug # 2475416 --Ramananda for File.Sql.35

-- start added by Aparajita on 05/11/2002 for bug # 2586784
v_open_period              gl_period_statuses.period_name%type;
v_open_gl_date               date;
-- start added by Aparajita on 05/11/2002 for bug # 2586784

-- start for bug#3536079
v_out_message_name            varchar2(240);
v_out_invoice_amount        number;
v_out_base_amount           number;
v_out_tax_amount            number;
v_out_temp_cancelled_amount     number;
v_out_cancelled_by            number;
v_out_cancelled_amount        number;
v_out_cancelled_date          date;
v_out_last_update_date        date;
v_out_original_prepay_amount    number;
v_out_pay_curr_inv_amount       number;
v_return_value                      boolean;
ln_invoice_id                 NUMBER; --4333449
ln_prnt_pay_priority          ap_payment_schedules_all.payment_priority%TYPE; -- 4333449
ln_prnt_exchange_rate         ap_invoices_all.exchange_rate%TYPE;  --4333449
lv_invoice_num                ap_invoices_interface.invoice_num%type;   --rchandan for bug#4428980
lv_description                ap_invoices_interface.description%type;--rchandan for bug#4428980
lv_lookup_type_code           ap_invoices_interface.invoice_type_lookup_code%type;--rchandan for bug#4428980
lv_source                     ap_invoices_interface.source%type;--rchandan for bug#4428980
lv_voucher_num                ap_invoices_interface.voucher_num%type;--rchandan for bug#4428980
-- End for bug#3536079

-- bug#3607133
cursor c_get_cm_status(p_invoice_num  in varchar2,
             p_vendor_id    in number,
             p_vendor_site_id in number)is
select cancelled_date
from   ap_invoices_all
where  invoice_num = p_invoice_num
and    vendor_id = p_vendor_id
and    vendor_site_id = p_vendor_site_id ;

v_cancelled_date_cm      date;

-- bug#3607133


/* start additions by ssumaith - bug# 4448789 */
ln_legal_entity_id      NUMBER;
lv_legal_entity_name    VARCHAR2(240);
lv_return_status        VARCHAR2(100);
ln_msg_count            NUMBER;
ln_msg_data             VARCHAR2(1000);
 /*  ends additions by ssumaith - bug# 4448789*/

lv_token                VARCHAR2(100);

lv_batch_name                     ap_batches_all.batch_name%TYPE; --added by Ramananda for Bug#4584221

BEGIN

/* Cancellation of invoice */
/*------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_ap_tds_old_pkg.cancel_invoice_p.sql
S.No      Date          Author and Details
------------------------------------------------------------------------------------------
1     03-Dec-2001     Pavan : Code modified to populate the fields goods_received_date,
              invoice_received_date into interfaces inorder to prevent it from
                  getting stuck up in interfaces

2   04-JUL-2002     Vijay Shankar: Code added to process only one invoice and delete the same
              Bug#2448040

3.      29-july-2002    Aparajita for bug # 2475416
            Approved TDS and CM setup was allowed at null site, so changed the code to look into null site setup
          if the site setup does not exist for the vendor for pre approved TDS and CM.
          This was done to find out if the approval of TDS an CM concurrent needs to be submitted.

4.      23-sep-2002     Aparajita for bug # 2503751
                        Populate the invoice id of the original invoice in attribute1 of the tds related invoice for
                        context value 'India Original Invoice for TDS'

5.      05-nov-2002    Aparajita for bug # 2586784
                       While generating the negative distribution line, checking for open/close accounting
                       period for accounting date.

                       Using ap_utilities_pkg procedures get_current_gl_date and get_open_gl_date.

6.      26-MAR-2003    Vijay Shankar for Bug# 2869481, FileVersion# 615.4
                       when an invoice is cancelled, then related TDS invoices also gets cancelled. upon cancelling the tds invoice,
                ap_invoice_payments_all should get updated
                with amount_remaining as 0 which is not happening previously and fixed with this bug.
                 An update statement is written on ap_payment_schedules_all to update amount_remaining and gross_amount fields

7.      27-apr-2003    Aparajita for bug#2906202. Version#616.1
           The negative distribution line in the TDS invoice, has the period name of the original distribution line it was reversing.
       Added the check to populate the period name of the current accounting period.

8.      15-oct-2003     kpvs for bug # 3109138, version # 616.2
                        Changed the procedure to insert v_open_gl_date instead of trunc(sysdate)
                        as invoice_date into ap_invoices_interface and as accounting_date into
                        ap_invoice_lines_interface.
                        This is for the invoice_date and GL date of the SI created for
                        supplier on cancellation of the vendor invoice.

 9.   29-oct-2003    Aparajita for bug#3205957. Version#616.3
             When the base invoice is getting cancelled, this procedure is cancelling the related tds
             invoice. It was not updating the pay_curr_invoice_amount field in ap_invoices_all for the
             tds invoice. Because of this the amount was still being displayed as before cancellation
             in the payment schedule screen. Added code to update it to 0.

10.      8-apr-2004    Aparajita for bug#3536079. Version#619.1

                       TDS invoice was being cancelled manually, that is being manually updated
                       by our code. This was creating problem as in this case accounting was not
                       being done for the reversed line as all info like accounting event id is
                       not being populated. Moreoevr, with any additional change / validation
                       in base, we had to change the code.

                       To avoid all this, used base API ap_cancel_pkg.Ap_Cancel_Single_Invoice
                       to cancel the TDS invoice. This way,much of the task is being done by base
                       and hence no inconsistency.

11       12-apr-2004   Aparajita for bug#3556035. Version#619.2

                       When the stadard invoice being cancelled is in forex, the
                       cancellation invoice generated for rversing the TDS amount was
                       getting generated in wrong currency. Amount always in INR, but
                       currency same as the stadard invoice.

                       Added a cursor c_get_can_inv_amount to fetch the amount from
                       the credit memo created initially for the invoice.

12.      5-may-2004    Aparajita for bug#3607133. Version#619.3
                       This procedure gets invoked whenever a base invoice having TDS is cancelled.
                       The functionality required here is to cancel the related TDS invoice and generate
                       a CAN invoice to negate the credit memo.

                       The problem is if the credit memo is already cancelled, there is no need to
                       generate the CAN invoice to negate it. Added a cursor to check the status
                       of the credit memo before creating the CAN invoice.

13.      31-jan-2005  rchandan - bug#4149343  - File version 115.1

                      When an invoice is cancelled , it was not getting cancelled and instead throwing an error
                      cannot update null into ap_invoices_all.last_update_date. This error was captured in
                      JAI_CMN_ERRORS_T on the client's instance through an exception handler.
                      The value to be set into this column was retreived through an API call to   ap_cancel_pkg.Ap_Cancel_Single_Invoice

                      Due to some internal exception, the out parameter corresponding to the the last_update_date is null

                      Spoke to lgopalsa she was of the opinion that in the  ap_cancel_pkg.Ap_Cancel_Single_Invoice API ,
                      the standard who columns are being set anyway and there is no need to set it explicitly in the
                      procedure.

                      As part of this fix , removed the last_update_date from the columns in the update ap_invoices_all
                      table.

14        25/3/2005   Aparajita - Bug#4088186 . File Version # 115.3 TDS Clean up.

                      Removed usage of table ja_in_ap_inv_cancel_temp.

15.     02/05/2005    rchandan for bug#4333449. Version 116.1
                      India Original Invoice for TDS DFF is eliminated. So attribute1 of ap_invoices_al
                      is not populated whenevr an invoice is generated. Instead the Invoice details are
                      populated into jai_ap_tds_thhold_trxs. So whenever data is inserted into interface
                      tables the jai_ap_tds_thhold_trxs table is also populated.

16.     24/05/2005    Ramananda for bug# 4388958 File Version: 116.1
                      Changed AP Lookup code from 'TDS' to 'INDIA TDS'

17.     02/05/2005    Ramananda for bug#4407165 File Version: 116.2
                      Added Exception block for non-compliant procedures and functions

18.     02/05/2005    Ramananda for bug# 4407184 File Version: 116.3
                      SQL Bind Varibale Compliance is done

19. 08-Jun-2005       Version 116.4 jai_ap_tds_old -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
          as required for CASE COMPLAINCE.

20. 14-Jun-2005       rchandan for bug#4428980, Version 116.5
                      Modified the object to remove literals from DML statements and CURSORS.

21. 02/05/2005        Ramananda for bug# 4407184 File Version: 116.6
                      Re-done: SQL Bind Varibale Compliance

22. 23-Aug-2005       Bug 4559756. Added by Lakshmi Gopalsami version 120.2
                      Passed org_id in call to ap_utilities_pkg to get the correct gl_date and period_name


--------------------------------------------------------------------------------------------*/

-- OPEN  cancelled_invoices;

/* Ramananda for File.Sql.35 */
  lv_statement_no   := '0';
  lv_procedure_name := 'jai_ap_tds_old_pkg.cancel_invoice';
  lv_error_mesg     := '';
  v_flag                           := 'N';
  v_Approved_Invoice_Flag          := 'N';  -- added by Aparajita on 29/07/2002 for bug # 2475416

/* Ramananda for File.Sql.35 */


 lv_statement_no := '1';
 OPEN  cancelled_invoices(p_invoice_id);    --cbabu Bug#2448040
 FETCH cancelled_invoices INTO cancelled_invoices_rec;
 CLOSE cancelled_invoices;

 OPEN cur_prnt_pay_priority;      -- 4333449
 FETCH cur_prnt_pay_priority INTO ln_prnt_pay_priority;
 CLOSE cur_prnt_pay_priority;

 OPEN cur_prnt_exchange_rate;     -- 4333449
 FETCH cur_prnt_exchange_rate INTO ln_prnt_exchange_rate;
 CLOSE cur_prnt_exchange_rate;

 lv_statement_no := '2';
 OPEN  tds_invoices(cancelled_invoices_rec.invoice_id);

 LOOP
   FETCH tds_invoices INTO tds_invoices_rec;
   IF tds_invoices%NOTFOUND THEN
      EXIT; --RETURN;
   END IF;

   lv_statement_no := '3';

   OPEN  vendor(tds_invoices_rec.tds_tax_id);
   FETCH vendor INTO vendor_rec;
   CLOSE vendor;

   lv_statement_no := '4';
   OPEN  for_payment_status(tds_invoices_rec.tds_invoice_num,vendor_rec.vendor_id, cancelled_invoices_rec.org_id);
   FETCH for_payment_status INTO for_pay_status_tds_rec;
   CLOSE for_payment_status;

   if for_pay_status_tds_rec.cancelled_date is not null then -- bug#3607133
       Fnd_File.put_line(Fnd_File.LOG, 'The TDS invoice has already been cancelled');
   end if;

   IF for_pay_status_tds_rec.payment_status_flag = 'N' THEN --1

  lv_statement_no := '5';

  /* Start comment for bug#3536079

    UPDATE ap_invoices_all
    SET    cancelled_date   = SYSDATE,
           cancelled_amount = for_pay_status_tds_rec.invoice_amount,
         cancelled_by     = cancelled_invoices_rec.last_updated_by,
         base_amount      = 0,
         invoice_amount   = 0,
         pay_curr_invoice_amount = 0 -- added by bug#3205957
    WHERE  invoice_num    = tds_invoices_rec.tds_invoice_num
    AND    vendor_id      = vendor_rec.vendor_id
    AND    NVL(org_id, 0) = NVL(cancelled_invoices_rec.org_id, 0);

  -- cbabu for Bug# 2869481
  UPDATE ap_payment_schedules_all
  SET gross_amount = 0,
    amount_remaining = 0
    -- , inv_curr_gross_amount = 0
    -- base applications is not updating this field when a standard invoice is cancelled. so not updating this field in our code also
  WHERE invoice_id in    (select invoice_id
              from   ap_invoices_all
              WHERE  invoice_num    = tds_invoices_rec.tds_invoice_num
              AND    vendor_id      = vendor_rec.vendor_id
              AND    NVL(org_id, 999999) = NVL(cancelled_invoices_rec.org_id, 999999)
              );

  End comment for bug#3536079  */

  lv_statement_no := '6';

    OPEN  for_distribution_insertion(for_pay_status_tds_rec.invoice_id);
    FETCH for_distribution_insertion INTO for_distribution_insertion_rec;
    CLOSE for_distribution_insertion;

    -- new_std_invoice_amount := for_pay_status_tds_rec.invoice_amount; Commented for bug#3556035

  lv_statement_no := '7';
    OPEN  for_std_invoice(cancelled_invoices_rec.invoice_id);
    FETCH for_std_invoice INTO for_std_invoice_rec;
    CLOSE for_std_invoice;

    -- Start added for bug#3556035
    if for_std_invoice_rec.invoice_currency_code <> 'INR' then
        open c_get_can_inv_amount(  tds_invoices_rec.dm_invoice_num,
                      for_std_invoice_rec.vendor_id,
                  for_std_invoice_rec.vendor_site_id);
    fetch c_get_can_inv_amount into new_std_invoice_amount;
    close c_get_can_inv_amount;
    else
      new_std_invoice_amount  := for_pay_status_tds_rec.invoice_amount;
    end if;
    -- end added for bug#3556035



    --REVERSE THE DISRTIBUTION LINE IN THE TDS INVOICE
  /*UPDATE ap_invoices_all
  SET    invoice_amount = 0
        WHERE  invoice_id     = for_pay_status_tds_rec.invoice_id;
    */

  lv_statement_no := '8';

  -- start added by Aparajita on 05/11/2002 for bug # 2586784

  /* Bug 4559756. Added by Lakshmi Gopalsami
     Passed org_id to ap_utilities_pkg
  */

  v_open_period :=  ap_utilities_pkg.get_current_gl_date(
                      for_distribution_insertion_rec.accounting_date,
          cancelled_invoices_rec.org_id);

  /* Bug 4559756. Added by Lakshmi Gopalsami
     Passed org_id to ap_utilities_pkg
  */

  if v_open_period is null then

    ap_utilities_pkg.get_open_gl_date
    (
    for_distribution_insertion_rec.accounting_date,
    v_open_period,
    v_open_gl_date,
    cancelled_invoices_rec.org_id
    );

    if v_open_period is null then
      raise_application_error(-20001,'No Open period ... after '||for_distribution_insertion_rec.accounting_date);
    end if;

  else

    v_open_gl_date := for_distribution_insertion_rec.accounting_date;
    v_open_period := for_distribution_insertion_rec.period_name; -- bug#2906202

    end if;

  -- end added by Aparajita on 05/11/2002 for bug # 2586784

  -- Start for bug#3536079
  v_return_value :=
  ap_cancel_pkg.Ap_Cancel_Single_Invoice
  (
  for_pay_status_tds_rec.invoice_id     ,
  cancelled_invoices_rec.last_updated_by,
  cancelled_invoices_rec.last_update_login ,
  --for_distribution_insertion_rec.set_of_books_id   ,
  v_open_gl_date   ,
  --v_open_period    ,
  v_out_message_name   ,
  v_out_invoice_amount ,
  v_out_base_amount  ,
  --v_out_tax_amount   ,
  v_out_temp_cancelled_amount  ,
  v_out_cancelled_by          ,
  v_out_cancelled_amount         ,
  v_out_cancelled_date          ,
  v_out_last_update_date         ,
  v_out_original_prepay_amount,
  --null, -- check_id                 ,
  v_out_pay_curr_inv_amount      ,
  lv_token,
  'India Localization - cancel TDS invoice'
  );


    update ap_invoices_all
    set
    invoice_amount  = v_out_invoice_amount ,
    base_amount = v_out_base_amount  ,
    tax_amount = v_out_tax_amount  ,
    temp_cancelled_amount = v_out_temp_cancelled_amount  ,
    cancelled_by = v_out_cancelled_by         ,
    cancelled_amount = v_out_cancelled_amount        ,
    cancelled_date = v_out_cancelled_date           ,---4149343
    original_prepayment_amount = v_out_original_prepay_amount,
    pay_curr_invoice_amount = v_out_pay_curr_inv_amount
    where  invoice_id = for_pay_status_tds_rec.invoice_id;


  -- End for bug#3536079


  /* Start comment for bug#3536079

    INSERT INTO ap_invoice_distributions_all
    (
    accounting_date,
  accrual_posted_flag,
  reversal_flag,
  assets_addition_flag,
  assets_tracking_flag,
  cash_posted_flag,
  distribution_line_number,
  dist_code_combination_id,
    accts_pay_code_combination_id,
  invoice_id,
  period_name,
  set_of_books_id,
  amount,
  match_status_flag,
  base_amount_to_post,
  prepay_amount_remaining,
  parent_invoice_id,
  line_type_lookup_code,
  last_updated_by,
  last_update_date,
  org_id,
  invoice_distribution_id, -- Added on 15-Sep-2000
    description,
  posted_flag
  )
    VALUES
    (
    v_open_gl_date, -- for_distribution_insertion_rec.accounting_date, commented by Aparajita on 05/11/2002 for bug # 2586784
  'N', --for_distribution_insertion_rec.accrual_posted_flag,
  'Y',
  for_distribution_insertion_rec.assets_addition_flag,
  for_distribution_insertion_rec.assets_tracking_flag,
  for_distribution_insertion_rec.cash_posted_flag,
  for_distribution_insertion_rec.distribution_line_number + 1,
  for_distribution_insertion_rec.dist_code_combination_id,
    for_distribution_insertion_rec.accts_pay_code_combination_id,
  for_pay_status_tds_rec.invoice_id,
  v_open_period, -- for_distribution_insertion_rec.period_name, bug#2906202
  for_distribution_insertion_rec.set_of_books_id,
  (-1)*for_pay_status_tds_rec.invoice_amount,
  for_distribution_insertion_rec.match_status_flag,
  for_distribution_insertion_rec.base_amount_to_post,
  for_distribution_insertion_rec.prepay_amount_remaining,
  for_distribution_insertion_rec.parent_invoice_id,
  'ITEM',
  cancelled_invoices_rec.last_updated_by,
  cancelled_invoices_rec.last_update_date,
  for_distribution_insertion_rec.org_id,
  ap_invoice_distributions_s.NEXTVAL,   -- Added on 15-sep-2000
  for_distribution_insertion_rec.description,
  'N'
  );

    End comment for bug#3536079 */


    --GENERATE A STANDARD INVOICE FOR THE AMOUNT EQUAL TO THAT OF THE TDS INVOICE
  lv_statement_no := '9';
  -- start bug#3607133
  open c_get_cm_status
  (tds_invoices_rec.dm_invoice_num,
   for_std_invoice_rec.vendor_id,
   for_std_invoice_rec.vendor_site_id
   );
  fetch c_get_cm_status into v_cancelled_date_cm;
  close c_get_cm_status;

  if v_cancelled_date_cm is not null then
    Fnd_File.put_line(Fnd_File.LOG,
    'Not generating cancelled invoice as the supplier CM is already cancelled');
    v_flag := 'N';

  else
    -- end bug#3607133
    lv_invoice_num := 'CAN/'||SUBSTR(tds_invoices_rec.dm_invoice_num,1,47);   --rchandan for bug#4428980
    lv_description := 'Invoice Generated in lieu of Cancelled TDS Invoice';  --rchandan for bug#4428980
    lv_lookup_type_code := 'STANDARD';   --rchandan for bug#4428980
    lv_source := 'INDIA TDS';   --rchandan for bug#4428980


    /* start additions by ssumaith - bug# 4448789 */
    jai_cmn_utils_pkg.GET_LE_INFO(
    P_API_VERSION            =>  NULL ,
    P_INIT_MSG_LIST          =>  NULL ,
    P_COMMIT                 =>  NULL ,
    P_LEDGER_ID              =>  NULL,
    P_BSV                    =>  NULL,
    P_ORG_ID                 =>  cancelled_invoices_rec.org_id,
    X_RETURN_STATUS          =>  lv_return_status ,
    X_MSG_COUNT              =>  ln_msg_count,
    X_MSG_DATA               =>  ln_msg_data,
    X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
    X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
    );
    /*  ends additions by ssumaith - bug# 4448789*/


    INSERT INTO ap_invoices_interface
    (
    invoice_id,
    invoice_num,
    invoice_type_lookup_code,
    invoice_date,
    vendor_id,
    vendor_site_id,
    invoice_amount,
    invoice_currency_code,
    exchange_rate,
    exchange_rate_type,
    exchange_date,
    terms_id,
    description,
    source,
    --voucher_num, Harshita for Bug 4870243
    payment_method_lookup_code,
    pay_group_lookup_code,
    org_id,
    legal_entity_id ,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    goods_received_date,
    invoice_received_date,
    group_id	/*Bug 4716884 bduvarag*/
    )
    VALUES
    (
    ap_invoices_interface_s.NEXTVAL,
    lv_invoice_num,
    lv_lookup_type_code,
    v_open_gl_date, -- bug 3109138 TRUNC( SYSDATE ),
    for_std_invoice_rec.vendor_id,
    for_std_invoice_rec.vendor_site_id,
    new_std_invoice_amount,
    for_std_invoice_rec.invoice_currency_code,
    for_std_invoice_rec.exchange_rate,
    for_std_invoice_rec.exchange_rate_type,
    for_std_invoice_rec.exchange_date,
    for_std_invoice_rec.terms_id,
    lv_description,   --rchandan for bug#4428980
    lv_source, /*--'TDS', --Ramanand for bug#4388958*/   --rchandan for bug#4428980
    -- lv_invoice_num,  --rchandan for bug#4428980 , Harshita for Bug 4870243
    for_std_invoice_rec.payment_method_lookup_code,
    for_std_invoice_rec.pay_group_lookup_code,
    cancelled_invoices_rec.org_id,
    ln_legal_entity_id ,
    cancelled_invoices_rec.created_by,
    cancelled_invoices_rec.creation_date,
    cancelled_invoices_rec.last_updated_by,
    cancelled_invoices_rec.last_update_date,
    cancelled_invoices_rec.last_update_login,
    for_std_invoice_rec.goods_received_date, --Added on 03-Dec-2001
    for_std_invoice_rec.invoice_received_date,
    to_char(p_invoice_id)	/*ug 4716884 bduvarag*/
    );

    lv_statement_no := '10';
    lv_lookup_type_code := 'ITEM';   --rchandan for bug#4428980
    INSERT INTO ap_invoice_lines_interface
    (
    invoice_id,
    invoice_line_id,
    line_number,
    line_type_lookup_code,
    amount,
    accounting_date,
    description,
    dist_code_combination_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )
    VALUES
    (
    ap_invoices_interface_s.CURRVAL,
    ap_invoice_lines_interface_s.NEXTVAL,
    1, --THERE WILL ALWAYS BE ONLY ONE LINE.
    lv_lookup_type_code,    --rchandan for bug#4428980
    new_std_invoice_amount,
    v_open_gl_date, -- bug 3109138  TRUNC( SYSDATE ),
    lv_description,     --rchandan for bug#4428980
    for_distribution_insertion_rec.dist_code_combination_id,
    cancelled_invoices_rec.created_by,
    cancelled_invoices_rec.creation_date,
    cancelled_invoices_rec.last_updated_by,
    cancelled_invoices_rec.last_update_date,
    cancelled_invoices_rec.last_update_login
    );


    jai_ap_tds_generation_pkg.insert_tds_thhold_trxs        -------4333449
      (
        p_invoice_id                      =>      p_invoice_id,
        p_tds_event                       =>      'OLD TDS INVOICE CANCEL',
        p_tax_id                          =>      tds_invoices_rec.tds_tax_id,
        p_tax_rate                        =>      tds_invoices_rec.tds_tax_rate,
        p_taxable_amount                  =>      tds_invoices_rec.invoice_amount,
        p_tax_amount                      =>      tds_invoices_rec.tds_amount,
        p_vendor_id                       =>      for_std_invoice_rec.vendor_id,
        p_vendor_site_id                  =>      for_std_invoice_rec.vendor_site_id,
        p_invoice_vendor_num              =>      'CAN/'||SUBSTR(tds_invoices_rec.dm_invoice_num,1,47),
        p_invoice_vendor_type             =>      'STANDARD',
        p_invoice_vendor_curr             =>      for_std_invoice_rec.invoice_currency_code,
        p_invoice_vendor_amt              =>      new_std_invoice_amount,
        p_parent_inv_payment_priority     =>      ln_prnt_pay_priority,
        p_parent_inv_exchange_rate        =>      ln_prnt_exchange_rate
    );

    v_flag := 'Y';

     end if; -- bug#3607133 if condition.


   END IF;            --1

  END LOOP;

  CLOSE tds_invoices;


  lv_statement_no := '10';

  /* start Commented for TDS clean up, obsoleted table ja_in_ap_inv_cancel_temp

  DELETE FROM ja_in_ap_inv_cancel_temp
  WHERE invoice_id = p_invoice_id;  --cbabu 08/07/02 Bug#2448040

  lv_statement_no := '10a';
  COMMIT;   --cbabu 08/07/02 Bug#2448040
  end  Commented for TDS clean up, obsoleted table ja_in_ap_inv_cancel_temp */



  IF v_flag = 'Y' THEN      --2

    result := Fnd_Request.set_mode(TRUE);
    lv_statement_no := '11';

    lv_batch_name := jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id); --Ramananda for Bug#4584221

    req_id := Fnd_Request.submit_request
    (
    'SQLAP',
    'APXIIMPT',
    'Localization Payables Open Interface Import',
    '',
    FALSE,
    /* Bug 4774647. Added by Lakshmi Gopalsami
          Passed operating unit also as this parameter has been
          added by base .
    */
     '',
    'INDIA TDS', /*--'TDS', --Ramanand for bug#4388958*/
    to_char(p_invoice_id), /*Bug 4716884 bduvarag*/
    --'TDS'||TO_CHAR(TRUNC(SYSDATE)),
    --commented the above and commented the below by Ramananda for Bug#4584221
    lv_batch_name,
    '',
    '',
    '',
    'Y',
    'N',
    'N',
    'N',
    1000,
    cancelled_invoices_rec.created_by,
    cancelled_invoices_rec.last_update_login
  );

  lv_statement_no := '12';
  /*
        OPEN  Fetch_App_Inv_Flag_Cur(for_std_invoice_rec.vendor_id,for_std_invoice_rec.vendor_site_id);
        FETCH Fetch_App_Inv_Flag_Cur INTO v_approve_flag;
        CLOSE Fetch_App_Inv_Flag_Cur;
        IF NVL(v_approve_flag, 'N') = 'Y' THEN
        result := Fnd_Request.set_mode(TRUE);
  */

  -- above block commented by Aparajita on 29/07/2002 for bug # 2475416, and the block below added.

  v_Approved_Invoice_Flag := 'N';

  BEGIN

      SELECT NVL( Approved_Invoice_Flag, 'N' )
    INTO   v_Approved_Invoice_Flag
      FROM   JAI_CMN_VENDOR_SITES
      WHERE  Vendor_Id = for_std_invoice_rec.vendor_id
      AND    Vendor_Site_Id = for_std_invoice_rec.vendor_site_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      BEGIN

              SELECT NVL( Approved_Invoice_Flag, 'N' )
        INTO   v_Approved_Invoice_Flag
              FROM   JAI_CMN_VENDOR_SITES
          WHERE  Vendor_Id = for_std_invoice_rec.vendor_id
          AND    Vendor_Site_Id = 0;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
        NULL;
      END;

   END;


     IF  v_Approved_Invoice_Flag = 'Y' THEN

        lv_statement_no := '13';

          result := Fnd_Request.set_mode(TRUE);
          req1_id := Fnd_Request.submit_request
                     (
                     'JA', 'JAINAPIN', 'Approval of TDS and CM',
           SYSDATE, FALSE, req_id, for_std_invoice_rec.vendor_id,
           for_std_invoice_rec.vendor_site_id, cancelled_invoices_rec.invoice_id,
           NULL, 'CAN'
           );
     END IF;

   -- end addition by Aparajita on 29/07/2002 for bug # 2475416

   END IF;                                 --2

   --cbabu 08/07/02 Bug#2448040

   EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;
    lv_error_mesg := SQLERRM;

    INSERT INTO JAI_CMN_ERRORS_T
    (
    APPLICATION_SOURCE, error_message,  additional_error_mesg,  creation_date, created_by,
    last_updated_by, last_update_date       -- added, Harshita for Bug 4866533
    )
    VALUES
    (
      lv_procedure_name, lv_error_mesg,
      'EXCEPTION captured BY WHEN OTHERS IN the PROCEDURE. STATEMENT No:' || lv_statement_no,
      SYSDATE, Fnd_Global.user_id,
      fnd_global.user_id, sysdate       -- added, Harshita for Bug 4866533
    );

    COMMIT;  --commit for the above insert statement
        --cbabu 08/07/02 Bug#2448040

END cancel_invoice;

/*
|| Changed the procedure name from ja_in_ap_prepay_unapply_p to process_prepayment_unapply
*/
PROCEDURE process_prepayment_unapply
(
errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_invoice_id                IN          NUMBER,
p_last_updated_by           IN          NUMBER,
p_last_update_date          IN          DATE,
p_created_by                IN          NUMBER,
p_creation_date             IN          DATE,
p_org_id                    IN          NUMBER,
p_prepay_dist_id            IN          NUMBER,
p_inv_dist_id               IN          NUMBER,
p_attribute                 IN          VARCHAR2
)
IS

/*  CURSOR check_prep_amt_app(p_id NUMBER,inv_id NUMBER) IS
  SELECT amount amt_app
  FROM ap_invoice_distributions_all
  WHERE prepay_distribution_id = p_id
  AND invoice_id = inv_id
  AND amount < 0 ;
*/

  -- above definition comented by Aparajita  Reopen issue - 1 for bug #2461706 and replaced by code below

  CURSOR check_prep_amt_app(p_id NUMBER,inv_id NUMBER) IS
  SELECT -1 * amount amt_app
  FROM   ap_invoice_distributions_all
  WHERE  invoice_id = inv_id
  AND    invoice_distribution_id = p_inv_dist_id
  AND    prepay_distribution_id = p_id
  -- AND amount < 0 ;
  ;

  CURSOR check_prep_amt_unapp(p_id NUMBER,inv_id NUMBER) IS
  SELECT amount amt_unapp
  FROM   ap_invoice_distributions_all
  WHERE  prepay_distribution_id = p_id
  AND    invoice_id = inv_id
  AND    amount >0 ;

  CURSOR check_for_tds_invoice_o(inv_id NUMBER, p_att VARCHAR2) IS
   SELECT  tds_invoice_num,invoice_id,invoice_amount,amt_reversed,
           amt_applied,tds_tax_id,
           tds_amount,
          tds_tax_rate,
          organization_id
   FROM   JAI_AP_TDS_INVOICES
   WHERE  invoice_id =inv_id
   AND    source_attribute=p_att;


  CURSOR check_for_tds_invoice(prepay_dist_id NUMBER, p_att VARCHAR2) IS
   SELECT tds_invoice_num,invoice_id,invoice_amount,amt_reversed,
          amt_applied,tds_tax_id,
          tds_amount,
          tds_tax_rate,
          organization_id
   FROM   JAI_AP_TDS_INVOICES
   WHERE  source_attribute=p_att
   AND    invoice_id = (SELECT invoice_id
                        FROM   ap_invoice_distributions_all
                        WHERE  invoice_distribution_id=prepay_dist_id);

   /*CURSOR check_for_tds_invoice(inv_id NUMBER) IS
     SELECT tds_invoice_num,invoice_id,invoice_amount,amt_reversed,amt_applied,tds_tax_id,organization_id
     FROM   JAI_AP_TDS_INVOICES
     WHERE  invoice_id = inv_id
     AND    source_attribute = p_attribute;*/

  CURSOR for_vendor_id(t_id NUMBER) IS
   SELECT vendor_id
   FROM   JAI_CMN_TAXES_ALL
   WHERE  tax_id = t_id;

  CURSOR for_payment_status(inv_num VARCHAR2,vend_id NUMBER,organization NUMBER) IS
    ----for information about tds invoice
    SELECT payment_status_flag,invoice_amount,invoice_id
    FROM   ap_invoices_all
    WHERE  invoice_num = inv_num
    AND    vendor_id = vend_id
    AND    NVL(org_id, 0) = NVL(organization, 0);

  CURSOR for_distribution_insertion(inv_id NUMBER) IS
    SELECT distribution_line_number,accounting_date,accrual_posted_flag,reversal_flag,
           assets_addition_flag,assets_tracking_flag,cash_posted_flag,dist_code_combination_id,
           accts_pay_code_combination_id,
         period_name,set_of_books_id,
         amount,match_status_flag,base_amount_to_post,prepay_amount_remaining,
         parent_invoice_id,org_id,description
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = inv_id
    AND    distribution_line_number = (SELECT MAX(distribution_line_number)
                               FROM   ap_invoice_distributions_all
                               WHERE  invoice_id = inv_id);

  CURSOR for_std_invoice(inv_id NUMBER) IS
    SELECT invoice_type_lookup_code,vendor_id,vendor_site_id,invoice_currency_code,
           exchange_rate,exchange_rate_type,exchange_date,terms_id,payment_method_lookup_code,
           pay_group_lookup_code,invoice_num,
       invoice_received_date,  -- added by Aparajita on 10/07/2002 for bug # 2439034
       goods_received_date -- added by Aparajita on 10/07/2002 for bug # 2439034
    FROM   ap_invoices_all
    WHERE  invoice_id = inv_id;

  CURSOR for_payment_amount(inv_id NUMBER) IS
    SELECT amount
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = inv_id
    AND    distribution_line_number = 1;

  CURSOR for_approved_amount(inv_id NUMBER) IS
    SELECT approved_amount,amount_applicable_to_discount
    FROM   ap_invoices_all
    WHERE  invoice_id = inv_id;

  CURSOR Fetch_Invoice_Num_Cur IS
    SELECT Invoice_Num
    FROM   Ap_Invoices_All
    WHERE  Invoice_Id = p_invoice_id;

 /* CURSOR Fetch_App_Inv_Flag_Cur( p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER ) IS
    SELECT NVL( Approved_Invoice_Flag, 'N' ) Approved_Invoice_Flag
    FROM   JAI_CMN_VENDOR_SITES
    WHERE  Vendor_Id = p_vendor_id
     AND   Vendor_Site_Id = p_vendor_site_id;
*/
   CURSOR Fetch_App_Inv_Flag_Cur( p_inv_id  IN  NUMBER) IS
    SELECT NVL( Approved_Invoice_Flag, 'N' ) Approved_Invoice_Flag
    FROM   JAI_CMN_VENDOR_SITES
    WHERE  (Vendor_Id, vendor_site_id) =
         (SELECT vendor_id, vendor_site_id FROM ap_invoices_all WHERE invoice_id = p_inv_id);



  --Added by Abhay on 20-JAN-2000 to tackle unapplication of prepayment {

  CURSOR fetch_amount(inv_id NUMBER) IS
     SELECT amount
     FROM   ap_invoice_distributions_all
     WHERE  invoice_id = inv_id
     AND    distribution_line_number = 1;

  --Added by Abhay on 20-JAN-2000 to tackle unapplication of prepayment }

  /* Commented by Aparajita on 07/07/2002 for bug # 2439034 as it was not being used.
  CURSOR for_invoice_num(invoice_num VARCHAR2) IS
    SELECT 'RTN/'|| invoice_num || '/' ||TO_CHAR(JAI_AP_TDS_INVOICE_NUM_S.CURRVAL)
    FROM DUAL;
  */

  Cursor get_prepay_dist_date is  -- bug 3112711 kpvs
  select accounting_date
  from   ap_invoice_distributions_all
  where  invoice_distribution_id = p_inv_dist_id;

  CURSOR cur_prnt_pay_priority     -- Ravi
  IS
  SELECT payment_priority
    FROM ap_payment_schedules_all
   WHERE invoice_id = p_invoice_id;

  CURSOR cur_prnt_exchange_rate     -- Ravi
  IS
  SELECT exchange_rate
    FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

lv_object_name VARCHAR2(61) ; --:= '<Package_name>.<procedure_name>'; /* Added by Ramananda for bug#4407165 */

check_tds_prepayment_rec               check_for_tds_invoice%ROWTYPE;
check_tds_original_rec                 check_for_tds_invoice_o%ROWTYPE;
for_payment_status_prepay_rec          for_payment_status%ROWTYPE;
for_pay_status_original_rec            for_payment_status%ROWTYPE;
for_distribution_insertion_rec         for_distribution_insertion%ROWTYPE;
for_vendor_id_prepay_rec             for_vendor_id%ROWTYPE;
for_vendor_id_original_rec             for_vendor_id%ROWTYPE;
for_std_invoice_rec                for_std_invoice%ROWTYPE;
for_prepay_payment_amount_rec        for_payment_amount%ROWTYPE;
for_approved_amount_rec              for_approved_amount%ROWTYPE;
for_insertion_invoice_id               NUMBER;
insertion_amount                       NUMBER := 0;
reversal_amount                  NUMBER := 0;
updation_amount                        NUMBER := 0;
updation_prepay_amount                 NUMBER := 0;
reversal_prepay_amount               NUMBER := 0;
new_std_invoice_amount                 NUMBER := 0;
if_part                      NUMBER := 0;
else_part                    NUMBER := 0;
req_id                         NUMBER;
req1_id                        NUMBER;
result                         BOOLEAN;

v_invoice_num                          VARCHAR2(100);
fetch_amount_rec                       fetch_amount%ROWTYPE;
v_unapply                  NUMBER := 0;
v_rtn_amt                          NUMBER := 0;
check_prep_amt_app_rec           check_prep_amt_app%ROWTYPE;
check_prep_amt_unapp_rec         check_prep_amt_unapp%ROWTYPE;
for_std_inv_tds_rec            for_std_invoice%ROWTYPE;
for_dist_tds_rec             for_distribution_insertion%ROWTYPE;
for_std_inv_rec              for_std_invoice%ROWTYPE;
for_dist_rec               for_distribution_insertion%ROWTYPE;
insert_amt_ap                NUMBER;
insert_inv_id                NUMBER;

-- Start : following variables added by Aparajita on 07/07/2002 for bug # 2439034
v_tds_inv_num                 ap_invoices_all.invoice_num%TYPE;
v_sup_cm_num                  ap_invoices_all.invoice_num%TYPE;

v_tds_inv_run_num           NUMBER;
v_sup_cm_run_num            NUMBER;

v_Approved_Invoice_Flag         CHAR(1); -- := 'N'; -- added by Aparajita for bug # 2441683 on 23/07/2002 --Ramananda for File.Sql.35
-- End : following variables added by Aparajita on 07/07/2002 for bug # 2439034

-- variables added by Aparajita on 08-jul-2002 for bug # 2461706
v_tds_invoice_num            ap_invoices_all.invoice_num%TYPE;
v_invoice_id             NUMBER;
v_invoice_amount           NUMBER;
v_amt_reversed               NUMBER;
v_amt_applied                NUMBER;
v_tds_tax_id             NUMBER;
v_organization_id              NUMBER;
-- variables added by Aparajita on 08-jul-2002 for bug # 2461706

v_prepay_dist_date   ap_invoice_distributions_all.accounting_date%TYPE; -- bug 3112711 kpvs

v_insertion_amount_tds_si          NUMBER := 0; -- bug#3469847
ln_prnt_pay_priority          ap_payment_schedules_all.payment_priority%TYPE;
ln_prnt_exchange_rate         ap_invoices_all.exchange_rate%TYPE;
ln_tax_rate                   JAI_AP_TDS_INVOICES.tds_tax_rate%type;
ln_tax_amount                 JAI_AP_TDS_INVOICES.tds_amount%type;
ln_taxable_amount             JAI_AP_TDS_INVOICES.invoice_amount%type;
lv_invoice_num                ap_invoices_interface.invoice_num%type; --rchandan for bug#4428980
lv_description                ap_invoices_interface.description%type;  --rchandan for bug#4428980
lv_lookup_type_code           ap_invoices_interface.invoice_type_lookup_code%TYPE; --rchandan for bug#4428980
lv_source                     ap_invoices_interface.source%type; --rchandan for bug#4428980
lv_voucher_num                ap_invoices_interface.voucher_num%type;--rchandan for bug#4428980
/* ramanand for SQL BIND Compliance */
lv_rtn_tds_inv   VARCHAR2(100);
lv_rtn_tds_auth  VARCHAR2(100);

/* start additions by ssumaith - bug# 4448789 */
ln_legal_entity_id      NUMBER;
lv_legal_entity_name    VARCHAR2(240);
lv_return_status        VARCHAR2(100);
ln_msg_count            NUMBER;
ln_msg_data             VARCHAR2(1000);
 /*  ends additions by ssumaith - bug# 4448789*/

lv_batch_name                     ap_batches_all.batch_name%TYPE; --added by Ramananda for Bug#4584221

/* PrePayment to Standard */

/*---------------------------------------------------------------------------------------------------------------------
FILENAME: jai_ap_tds_old_pkg.process_prepayment_unapply.sql

CHANGE HISTORY:
Sl. No    Date        Author and Details
1.        10/07/2002  Aparajita Das for bug # 2439034. RCS version 615.1
                      Called the concurrent for TDS and CM approval with changed parameters.
            - hardcoded UNAPPLY to pass to approval program
            - the invoice numbers of the return TDS inv and supplier CM concatenated .
            - added code to populate the invoice received date and goods recd date to the interface table
              as otheriwise when terms is set to any of them, it was getting into error.

2.        29/07/2002  Aparajita for bug # 2475416. RCS version 615.2
            Approved TDS and CM setup was allowed at null site, so changed the code to look into null site
            setup if the site setup does not exist for the vendor for pre approved TDS and CM. This was done
            to find out if the approval of TDS an CM concurrent needs to be submitted.

3.        08/08/2002  Aparajita for bug # 2461706. RCS version 615.3
                      When a prepayment is applied to an unapproved standard invoice, tds related invoices get
            generated. But when the prepayment is unapplied, tds invoices were not getting generated. Modified
            the code to generate the tds related invoices at unapplying.

4.        24/09/2002  Aparajita  Reopen issue - 1 for bug #2461706. RCS version 615.4
                  When a prepayment is applied, unapplied, applied, unapplied on the same invoice and the application
            amount is different between the first and the second time, the tds related invoices that were
            getting generated at the second time used to be of the value corresponding to the first time.

            For this, the cursor definition check_prep_amt_app was changed to consider the application amount
            corresponding to the iteration, earlier it was always considering the first applied amount.

5.       23/09/2002   Aparajita for  bug # 2503751.RCS version 615.5
                      Populate the invoice id of the original invoice in attribute1 of the tds related invoice
                      for context value 'India Original Invoice for TDS'.

6        15/01/2003   Aparajita  for Bug # 2738340. RCS version 615.6
                      Added the commit interval parameter in the request for APXIIMPT. This was missing.
7        15/10/2003   kpvs for bug # 3112711, version 616.1
                      Cursor get_prepay_dist_date incorporated to get the GL date of the distribution line
                  created in ap_invoice_distributions_all .

                  This date is inserted as invoice_date into ap_invoices_interface
            and as accounting_date into ap_invoice_lines_interface.
            This would ensure that the invoice date and GL date of the TDS invoices
            are in sync with the date entered on Apply/Unapply prepayment screen if the
            user changes this date.

8.    31/10/2003    Aparajita for bug#3205948. Version#616.2

            Applied round function to the amount of the invoices that is being generated to be in sync
            with apply.

9.      08/03/2004    Aparajita for bug#3469847. Version#619.1
                      For Prepeyment having forex, the amount for return standard invoice for TDS authority
                      was not getting converted though the inv is always generated in INR.

10.     29/04/2004    Aparajita for bug#3583708. Version#619.2
                      The Credit memo that is generated was not picking up the right dist_code_combination_id. It has to be the same as used in case of the
                      stadard invoice that is being generated for the TDS authority.

11.     02/05/2005    rchandan for bug#4333449. Version 116.1
                      India Original Invoice for TDS DFF is eliminated. So attribute1 of ap_invoices_al
                      is not populated whenevr an invoice is generated. Instead the Invoice details are
                      populated into jai_ap_tds_thhold_trxs. So whenever data is inserted into interface
                      tables the jai_ap_tds_thhold_trxs table is also populated.


----------------------------------------------------------------------------------------------------*/
BEGIN

  v_Approved_Invoice_Flag         := 'N'; -- added by Aparajita for bug # 2441683 on 23/07/2002 --Ramananda for File.Sql.35
  lv_object_name                  := 'jai_ap_tds_old_pkg.process_prepayment_unapply'; /* Added by Ramananda for bug#4407165 */

  OPEN check_prep_amt_app(p_prepay_dist_id,p_invoice_id);
  FETCH check_prep_amt_app INTO check_prep_amt_app_rec;
  CLOSE check_prep_amt_app;

  OPEN check_prep_amt_unapp(p_prepay_dist_id,p_invoice_id);
  FETCH check_prep_amt_unapp INTO check_prep_amt_unapp_rec;
  CLOSE check_prep_amt_unapp;

  OPEN cur_prnt_pay_priority;      -- 4333449
  FETCH cur_prnt_pay_priority INTO ln_prnt_pay_priority;
  CLOSE cur_prnt_pay_priority;

  OPEN cur_prnt_exchange_rate;     -- 4333449
  FETCH cur_prnt_exchange_rate INTO ln_prnt_exchange_rate;
  CLOSE cur_prnt_exchange_rate;



    IF ABS(check_prep_amt_app_rec.amt_app) < 0 THEN
      v_unapply := 1;
    END IF;

  --CHECK IF TDS INVOICE FOR PREPAYMENT INVOICE EXISTS.
  OPEN  check_for_tds_invoice(p_prepay_dist_id,p_attribute);
  FETCH check_for_tds_invoice INTO check_tds_prepayment_rec;
  CLOSE check_for_tds_invoice;


    IF check_tds_prepayment_rec.invoice_id IS NOT NULL THEN      --1

       --GET VENDOR ID BASED ON THE TAX-ID FOR THE PREPAYMENT INVOICE.
       OPEN  for_vendor_id(check_tds_prepayment_rec.tds_tax_id);
       FETCH for_vendor_id INTO for_vendor_id_prepay_rec;
       CLOSE for_vendor_id;

       --GET PAYMENT_STATUS, INVOICE_AMOUNT AND INVOICE_ID OF TDS INVOICE FOR PREPAYMENT INVOICE.
       OPEN  for_payment_status(check_tds_prepayment_rec.tds_invoice_num,
                          for_vendor_id_prepay_rec.vendor_id,NVL(check_tds_prepayment_rec.organization_id, 0));
       FETCH for_payment_status INTO for_payment_status_prepay_rec;
       CLOSE for_payment_status;

     OPEN  for_std_invoice(p_invoice_id);  --added on 05-Feb-2002
       FETCH for_std_invoice INTO for_std_invoice_rec;
       CLOSE for_std_invoice;

       --CHECK IF TDS INVOICE FOR ORIGINAL INVOICE EXISTS.
       OPEN  check_for_tds_invoice_o(p_invoice_id,p_attribute);
       FETCH check_for_tds_invoice_o INTO check_tds_original_rec;



       IF check_for_tds_invoice_o%FOUND THEN    --2
          Fnd_File.put_line(Fnd_File.LOG,'Inside IF check_for_tds_invoice_o%FOUND');
          v_tds_invoice_num := check_tds_original_rec.tds_invoice_num;
        v_invoice_id := check_tds_original_rec.invoice_ID;
        v_invoice_amount := check_tds_original_rec.invoice_amount;
        v_amt_reversed := check_tds_original_rec.amt_reversed;
        v_amt_applied := check_tds_original_rec.amt_applied;
        v_tds_tax_id := check_tds_original_rec.tds_tax_id;
        v_organization_id := check_tds_original_rec.organization_id;
        ln_tax_rate         := check_tds_original_rec.tds_tax_rate;
        ln_tax_amount       := check_tds_original_rec.tds_amount;
        ln_taxable_amount   := check_tds_original_rec.invoice_amount;

        -- line below added by Aparajita for bug 2338345.
        v_tds_inv_num := check_tds_original_rec.tds_invoice_num;


            -- start the following else part is added on 08/08/2002 by Aparajita for bug # 2461706
        ELSIF   check_for_tds_invoice_o%NOTFOUND THEN

          Fnd_File.put_line(Fnd_File.LOG,'Inside ELSIF check_for_tds_invoice_o%NOTFOUND');

        v_tds_invoice_num := check_tds_prepayment_rec.tds_invoice_num;
        v_invoice_id := check_tds_prepayment_rec.invoice_ID;
        v_invoice_amount := check_tds_prepayment_rec.invoice_amount;
        v_amt_reversed := check_tds_prepayment_rec.amt_reversed;
        v_amt_applied := check_tds_prepayment_rec.amt_applied;
        v_tds_tax_id := check_tds_prepayment_rec.tds_tax_id;
        v_organization_id := check_tds_prepayment_rec.organization_id;
        ln_tax_rate         := check_tds_prepayment_rec.tds_tax_rate;
        ln_tax_amount       := check_tds_prepayment_rec.tds_amount;
        ln_taxable_amount   := check_tds_prepayment_rec.invoice_amount;

     END IF; -- check_for_tds_invoice_o%FOUND THEN    --2

    -- following If added by Aparajita on 29th April for bug # 2338345
    IF v_tds_inv_num IS NULL THEN
        -- the TDS invoice corrosponding to the standard invoice is not found, this would be when
      -- the standard invoice is not approved yet.
      -- the CM for TDS authortiy should then should have the standard invoice number suffixed by TDS
      v_tds_inv_num := for_std_invoice_rec.invoice_num || 'TDS';
    END IF;

            -- end the following else part is added on 08/08/2002 by Aparajita for bug # 2461706

       --GET VENDOR ID BASED ON THE TAX-ID FOR THE ORIGINAL INVOICE.
       OPEN  for_vendor_id(v_tds_tax_id);
       FETCH for_vendor_id INTO for_vendor_id_original_rec;
       CLOSE for_vendor_id;

       --GET PAYMENT_STATUS, INVOICE_AMOUNT AND INVOICE_ID OF TDS INVOICE FOR ORIGINAL INVOICE.
       OPEN  for_payment_status(v_tds_invoice_num,
                  for_vendor_id_original_rec.vendor_id,
                NVL(v_organization_id, 0)
                );

       FETCH for_payment_status INTO for_pay_status_original_rec;
       CLOSE for_payment_status;

       --GET PREPAYMENT TDS INVOICE_AMOUNT, THIS IS THE AMOUNT OF INVOICE ORIGINALLY CREATED
       --AND NOT THE LATEST AMOUNT
       OPEN  for_payment_amount(for_payment_status_prepay_rec.invoice_id);
       FETCH for_payment_amount INTO for_prepay_payment_amount_rec;
       CLOSE for_payment_amount;


     --CALCULATING THE PROPORTIONATE TAX TO BE APPLIED.
       IF (v_invoice_amount =
                  v_amt_applied +  ABS(check_prep_amt_app_rec.amt_app))  THEN  --13

         insertion_amount := (for_prepay_payment_amount_rec.amount - v_amt_reversed);

    ELSE                --13

            insertion_amount :=FLOOR(ABS(check_prep_amt_app_rec.amt_app))
                         * ( for_prepay_payment_amount_rec.amount /  check_tds_prepayment_rec.invoice_amount);

        END IF; --13

        insertion_amount := round(insertion_amount); -- added by bug#3205948

        -- Start added for bug#3469847
        if  for_std_invoice_rec.invoice_currency_code <> 'INR' then
            v_insertion_amount_tds_si := insertion_amount * nvl(for_std_invoice_rec.exchange_rate, 1);
        else
          v_insertion_amount_tds_si := insertion_amount;
        end if;
    -- End added for bug#3469847

    IF      for_pay_status_original_rec.payment_status_flag = 'N'
        AND for_payment_status_prepay_rec.payment_status_flag = 'N'
      AND for_vendor_id_original_rec.vendor_id = for_vendor_id_prepay_rec.vendor_id THEN

        -----------------------CASE 1

          OPEN for_std_invoice(for_pay_status_original_rec.invoice_id);
      FETCH for_std_invoice INTO for_std_inv_tds_rec ;
      CLOSE for_std_invoice;

      OPEN for_distribution_insertion(for_pay_status_original_rec.invoice_id);
      FETCH for_distribution_insertion INTO for_dist_tds_rec;
      CLOSE for_distribution_insertion;


      -- added by Aparajita to remove references to currval
            SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval --JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL  changed by rchandan for bug#4487676
      INTO   v_tds_inv_run_num
      FROM   dual;

   Open get_prepay_dist_date; -- bug 3112711 kpvs
   fetch get_prepay_dist_date into v_prepay_dist_date;
         close get_prepay_dist_date;


/* Modified by Ramananda for bug# 4407184 , start */

     lv_rtn_tds_inv   := 'RTN/'|| v_tds_inv_num ||'/'||TO_CHAR(v_tds_inv_run_num);
     lv_rtn_tds_auth  := 'RTN FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_std_inv_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ;

  /* start additions by ssumaith - bug# 4448789 */
  jai_cmn_utils_pkg.GET_LE_INFO(
  P_API_VERSION            =>  NULL ,
  P_INIT_MSG_LIST          =>  NULL ,
  P_COMMIT                 =>  NULL ,
  P_LEDGER_ID              =>  NULL,
  P_BSV                    =>  NULL,
  P_ORG_ID                 =>  P_ORG_ID,
  X_RETURN_STATUS          =>  lv_return_status ,
  X_MSG_COUNT              =>  ln_msg_count,
  X_MSG_DATA               =>  ln_msg_data,
  X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
  X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
  );
   /*  ends additions by ssumaith - bug# 4448789*/


      INSERT INTO ap_invoices_interface
      (
      invoice_id,
      invoice_num,
      invoice_type_lookup_code,
      invoice_date,
      vendor_id,
      vendor_site_id,
      invoice_amount,
      invoice_currency_code,
      exchange_rate,
      exchange_rate_type,
      exchange_date,
      terms_id,
      description,
      source,
      -- voucher_num, Harshita for Bug 4870243
      payment_method_lookup_code,
      pay_group_lookup_code,
      org_id,
      Legal_entity_id ,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      invoice_received_date, -- Added by aparajita on 10/08/2002 for bug # 2439034
      goods_received_date,    -- Added by aparajita on 10/08/2002 for bug # 2439034
      group_id	/*Bug 4716884*/
      )
               VALUES
       (
       ap_invoices_interface_s.NEXTVAL,
      lv_rtn_tds_inv, --'RTN/'|| v_tds_inv_num ||'/'||TO_CHAR(v_tds_inv_run_num),
      'STANDARD',
      v_prepay_dist_date, -- bug 3112711 kpvs TRUNC( SYSDATE ), --for_std_inv_tds_rec.invoice_date,
      for_std_inv_tds_rec.vendor_id,
      for_std_inv_tds_rec.vendor_site_id,
      v_insertion_amount_tds_si , -- insertion_amount, bug#3469847
      for_std_inv_tds_rec.invoice_currency_code,
      for_std_inv_tds_rec.exchange_rate,
      for_std_inv_tds_rec.exchange_rate_type,
      for_std_inv_tds_rec.exchange_date,
      for_std_inv_tds_rec.terms_id,
      lv_rtn_tds_auth, --'RTN FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_std_inv_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ,
       'INDIA TDS', /*--'TDS', ----Ramanand for bug#4388958*/
      -- lv_rtn_tds_inv, --'RTN/'|| v_tds_inv_num ||'/'||TO_CHAR(v_tds_inv_run_num), Harshita for Bug 4870243
      for_std_inv_tds_rec.payment_method_lookup_code,
      for_std_inv_tds_rec.pay_group_lookup_code,
      p_org_id,
      ln_legal_entity_id ,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by,
      for_std_inv_tds_rec.invoice_received_date,  -- Added by aparajita on 10/08/2002 for bug # 2439034
      for_std_inv_tds_rec.goods_received_date,    -- Added by aparajita on 10/08/2002 for bug # 2439034
      to_char(p_invoice_id)	/*Bug 4716884*/
      );
/* Modified by Ramananda for bug# 4407184 , end */

            -- following line added by Aparajita on 07/07/2002 for bug # 2439034
      v_tds_inv_num := 'RTN/'||v_tds_inv_num||'/'||TO_CHAR(v_tds_inv_run_num);
      lv_description := 'RTN FOR TDS TAX AUTHORITY FOR TAX APPLIED BY  ';
      lv_lookup_type_code := 'ITEM';
            INSERT INTO ap_invoice_lines_interface
      (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      amount,
      accounting_date,
      description,
      dist_code_combination_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
               VALUES
      (
      ap_invoices_interface_s.CURRVAL,
      ap_invoice_lines_interface_s.NEXTVAL,
      1, --THERE WILL ALWAYS BE ONLY ONE LINE.
      lv_lookup_type_code,
      v_insertion_amount_tds_si , -- insertion_amount, bug#3469847
      v_prepay_dist_date, -- bug 3112711 kpvs  TRUNC( SYSDATE ),
      lv_description,
      for_dist_tds_rec.dist_code_combination_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by
      );


          OPEN for_std_invoice(p_invoice_id);--check_tds_original_rec.invoice_id);
      FETCH for_std_invoice INTO for_std_inv_rec ;
      CLOSE for_std_invoice;


      OPEN for_distribution_insertion(p_invoice_id); --check_tds_original_rec.invoice_id);
      FETCH for_distribution_insertion INTO for_dist_rec;
      CLOSE for_distribution_insertion;


            SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval --JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL  changed by rchandan for bug#4487676
      INTO   v_sup_cm_run_num
      FROM   dual;
      lv_lookup_type_code:= 'CREDIT';
      lv_invoice_num := for_std_inv_rec.invoice_num||'CM/'||TO_CHAR(v_sup_cm_run_num);   --rchandan for bug#4428980
      lv_description := 'CM FOR SUPPLIER FOR TDS DEDUCTED AFTER UNAPPLY ';     --rchandan for bug#4428980
      lv_source      := 'INDIA TDS';     --rchandan for bug#4428980
      lv_voucher_num := for_std_inv_rec.invoice_num || 'CM/' ||TO_CHAR(v_sup_cm_run_num);   --rchandan for bug#4428980

        /* start additions by ssumaith - bug# 4448789 */
        jai_cmn_utils_pkg.GET_LE_INFO(
        P_API_VERSION            =>  NULL ,
        P_INIT_MSG_LIST          =>  NULL ,
        P_COMMIT                 =>  NULL ,
        P_LEDGER_ID              =>  NULL,
        P_BSV                    =>  NULL,
        P_ORG_ID                 =>  P_ORG_ID,
        X_RETURN_STATUS          =>  lv_return_status ,
        X_MSG_COUNT              =>  ln_msg_count,
        X_MSG_DATA               =>  ln_msg_data,
        X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
        X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
        );
         /*  ends additions by ssumaith - bug# 4448789*/



      INSERT INTO ap_invoices_interface
      (
      invoice_id,
                  invoice_num,
      invoice_type_lookup_code,
      invoice_date,
      vendor_id,
      vendor_site_id,
      invoice_amount,
      invoice_currency_code,
      exchange_rate,
      exchange_rate_type,
      exchange_date,
      terms_id,
      description,
      source,
      -- voucher_num, Harshita for Bug 4870243
      payment_method_lookup_code,
      pay_group_lookup_code,
      org_id,
      legal_entity_id ,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      invoice_received_date,  -- Added by aparajita on 10/08/2002 for bug # 2439034
      goods_received_date,    -- Added by aparajita on 10/08/2002 for bug # 2439034
      group_id	/*Bug 4716884*/
      )
               VALUES
      (
      ap_invoices_interface_s.NEXTVAL,
      lv_invoice_num,   --rchandan for bug#4428980
      lv_lookup_type_code,   --rchandan for bug#4428980
      v_prepay_dist_date, -- bug 3112711 kpvs  TRUNC( SYSDATE ),
      for_std_inv_rec.vendor_id,
      for_std_inv_rec.vendor_site_id,
      (-1) * insertion_amount,
      for_std_inv_rec.invoice_currency_code,
      for_std_inv_rec.exchange_rate,
      for_std_inv_rec.exchange_rate_type,
      for_std_inv_rec.exchange_date,
      for_std_inv_rec.terms_id,
      lv_description,    --rchandan for bug#4428980
      lv_source, /*--'TDS', --Ramanand for bug#4388958*/    --rchandan for bug#4428980
      -- lv_voucher_num,   --rchandan for bug#4428980 Harshita for Bug 4870243
      for_std_inv_rec.payment_method_lookup_code,
      for_std_inv_rec.pay_group_lookup_code,
      p_org_id,
      ln_legal_entity_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by,
      for_std_inv_rec.invoice_received_date,  -- Added by aparajita on 10/08/2002 for bug # 2439034
      for_std_inv_rec.goods_received_date,     -- Added by aparajita on 10/08/2002 for bug # 2439034
      to_char(p_invoice_id)	/*Bug 4716884*/
      );

            -- following line added by Aparajita on 07/07/2002 for bug # 2439034
      v_sup_cm_num := for_std_inv_rec.invoice_num || 'CM/' ||TO_CHAR(v_sup_cm_run_num);
      lv_lookup_type_code := 'ITEM';
      lv_description := 'CM FOR SUPPLIER ON TDS AFTER UNAPPLY';
               INSERT INTO ap_invoice_lines_interface
      (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      amount,
      accounting_date,
      description,
      dist_code_combination_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
               VALUES
      (
      ap_invoices_interface_s.CURRVAL,
      ap_invoice_lines_interface_s.NEXTVAL,
      1, --THERE WILL ALWAYS BE ONLY ONE LINE.
      lv_lookup_type_code,   --rchandan for bug#4428980
      (-1) * insertion_amount,
      v_prepay_dist_date, -- bug 3112711 kpvs  TRUNC( SYSDATE ),
      lv_description,   --rchandan for bug#4428980
      for_dist_tds_rec.dist_code_combination_id,--bug#3583708 for_dist_rec.dist_code_combination_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by);


      jai_ap_tds_generation_pkg.insert_tds_thhold_trxs        -------4333449
        (
          p_invoice_id                          =>      p_invoice_id,
          p_tds_event                           =>      'OLD TDS PREPAY UNAPPLY',
          p_tax_id                              =>      v_tds_tax_id,
          p_tax_rate                            =>      ln_tax_rate,
          p_taxable_amount                      =>      ln_taxable_amount,
          p_tax_amount                          =>      ln_tax_amount,
          p_tds_authority_vendor_id             =>      for_std_inv_tds_rec.vendor_id,
          p_tds_authority_vendor_site_id        =>      for_std_inv_tds_rec.vendor_site_id,
          p_invoice_tds_authority_num           =>      'RTN/'|| v_tds_inv_num ||'/'||TO_CHAR(v_tds_inv_run_num),
          p_invoice_tds_authority_type          =>      'STANDARD',
          p_invoice_tds_authority_curr          =>      for_std_inv_tds_rec.invoice_currency_code,
          p_invoice_tds_authority_amt           =>      v_insertion_amount_tds_si,
          p_vendor_id                           =>      for_std_inv_rec.vendor_id,
          p_vendor_site_id                      =>      for_std_inv_rec.vendor_site_id,
          p_invoice_vendor_num                  =>      for_std_inv_rec.invoice_num||'CM/'||TO_CHAR(v_sup_cm_run_num),
          p_invoice_vendor_type                 =>      'CREDIT',
          p_invoice_vendor_curr                 =>      for_std_inv_rec.invoice_currency_code,
          p_invoice_vendor_amt                  =>      (-1) * insertion_amount,
          p_parent_inv_payment_priority         =>      ln_prnt_pay_priority,
          p_parent_inv_exchange_rate            =>      ln_prnt_exchange_rate
        );

          result := Fnd_Request.set_mode(TRUE);

          lv_batch_name := jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id); --Ramananda for Bug#4584221

          req_id := Fnd_Request.submit_request(
              'SQLAP',
              'APXIIMPT',
              'Localization Payables Open Interface Import',
              '',
              FALSE,
        /* Bug 4774647. Added by Lakshmi Gopalsami
            Passed operating unit also as this parameter has been
            added by base .
         */
              '',
              'INDIA TDS',/*--'TDS', --Ramanand for bug#4388958*/
              to_char(p_invoice_id),	/*Bug 4716884*/
              --'TDS'||TO_CHAR(TRUNC(SYSDATE)),
              --commented the above and commented the below by Ramananda for Bug#4584221
              lv_batch_name,
              '',
              '',
              '',
              'Y',
              'N',
              'N',
              'N',
              1000, -- commit interval parameter added by Aparajita for bug # 2738340 on 15/01/2003
              p_created_by,
              p_last_updated_by);

       insert_amt_ap := ABS(check_prep_amt_app_rec.amt_app);
       insert_inv_id := check_tds_prepayment_rec.invoice_id ;

       UPDATE JAI_AP_TDS_INVOICES
       SET    amt_reversed = NVL(amt_reversed,0) - insertion_amount,
              amt_applied = NVL(amt_applied,0) - insert_amt_ap
       WHERE  invoice_id = insert_inv_id ;


         -- FOR  App_Flag_Rec IN Fetch_App_Inv_Flag_Cur( for_std_invoice_rec.vendor_id,
           --                                            for_std_invoice_rec.vendor_site_id ) LOOP
       -- Above was commented by Aparajita on 07/07/2002 and replaced by the line below.

       -- FOR  App_Flag_Rec IN   Fetch_App_Inv_Flag_Cur( p_invoice_id)
       -- LOOP

                -- IF App_Flag_Rec.Approved_Invoice_Flag = 'Y' THEN

                    /* Commented by Aparajita for as this variables is not being used at all in the
            called unit
         OPEN  for_invoice_num(for_std_invoice_rec.invoice_num);
                   FETCH for_invoice_num INTO v_invoice_num;
                   CLOSE for_invoice_num;
         */
         -- above block commented by Aparajita on 29/07/2002 for bug # 2475416, and the block below added.
        v_Approved_Invoice_Flag := 'N';

        BEGIN

                SELECT NVL( Approved_Invoice_Flag, 'N' )
          INTO   v_Approved_Invoice_Flag
                FROM   JAI_CMN_VENDOR_SITES
            WHERE  Vendor_Id = for_std_inv_rec.vendor_id
            AND    Vendor_Site_Id = for_std_inv_rec.vendor_site_id;

        EXCEPTION

          WHEN NO_DATA_FOUND THEN

            BEGIN

                  SELECT NVL( Approved_Invoice_Flag, 'N' )
            INTO   v_Approved_Invoice_Flag
                  FROM   JAI_CMN_VENDOR_SITES
              WHERE  Vendor_Id = for_std_inv_rec.vendor_id
              AND    Vendor_Site_Id = 0;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
            NULL;
          END;

        END;

          -- end addition by Aparajita on 29/07/2002 for bug # 2475416
            IF  v_Approved_Invoice_Flag = 'Y' THEN

                    result := Fnd_Request.set_mode(TRUE);
                    req1_id := Fnd_Request.submit_request( 'JA', 'JAINAPIN', 'Approval OF TDS AND CM - Localization',
                                                           SYSDATE, FALSE, req_id, for_std_invoice_rec.vendor_id,
                                                           for_std_invoice_rec.vendor_site_id, p_invoice_Id ,
                                                           v_tds_inv_num || ';' || v_sup_cm_num , 'UNAPPLY' );



                 END IF;

              -- END LOOP;

      END IF; --      IF  for_pay_status_original_rec.payment_status_flag = 'N'

  -- END IF ; -- IF check_for_tds_invoice_o%FOUND THEN    --2

  END IF; -- IF check_tds_prepayment_rec.invoice_id IS NOT NULL THEN      --1

  /* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    errbuf := null;
    retcode:= null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END process_prepayment_unapply;


/*
|| Changed from ja_in_ap_prepay_invoice_p(11.5) to process_prepayment_apply(12.0)
*/
PROCEDURE process_prepayment_apply(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_invoice_id        IN     NUMBER,
  p_invoice_distribution_id   IN     NUMBER,
  p_amount          IN     NUMBER,
  p_last_updated_by       IN     NUMBER,
  p_last_update_date      IN     DATE,
  p_created_by        IN     NUMBER,
  p_creation_date       IN     DATE,
  p_org_id          IN     NUMBER,
  p_prepay_dist_id      IN     NUMBER,
  p_param           IN     VARCHAR2,
  p_attribute         IN     VARCHAR2
)
IS

CURSOR check_for_tds_invoice_o(inv_id NUMBER, p_att VARCHAR2) IS
   SELECT tds_invoice_num,invoice_id,
          invoice_amount,amt_reversed,
          amt_applied,
          tds_tax_id,
          tds_amount,   -- 4333449
          tds_tax_rate, -- 4333449
          organization_id
     FROM JAI_AP_TDS_INVOICES
    WHERE invoice_id =inv_id
      AND source_attribute=p_att;

CURSOR check_for_tds_invoice(prepay_dist_id NUMBER, p_att VARCHAR2) IS
   SELECT tds_invoice_num,
          invoice_id,
          invoice_amount,
          amt_reversed,
          amt_applied,
          tds_tax_id,
          tds_amount,       -- 4333449
          tds_tax_rate,    -- 4333449
          organization_id
     FROM JAI_AP_TDS_INVOICES
    WHERE source_attribute=p_att
      AND invoice_id = (SELECT invoice_id
                          FROM   ap_invoice_distributions_all
                         WHERE  invoice_distribution_id=prepay_dist_id);

CURSOR for_vendor_id(t_id NUMBER) IS
   SELECT vendor_id
   FROM   JAI_CMN_TAXES_ALL
   WHERE  tax_id = t_id;

CURSOR for_payment_status(inv_num VARCHAR2,vend_id NUMBER,organization NUMBER) IS  --for information about tds invoice
    SELECT payment_status_flag,
       invoice_amount,
       invoice_id
    FROM   ap_invoices_all
    WHERE  invoice_num = inv_num
    AND    vendor_id = vend_id
    AND    NVL(org_id, 0) = NVL(organization, 0);

CURSOR for_distribution_insertion(inv_id NUMBER) IS
    SELECT distribution_line_number,
       accounting_date,
       accrual_posted_flag,
       reversal_flag,
         assets_addition_flag,
       assets_tracking_flag,
       cash_posted_flag,
       dist_code_combination_id,
         period_name,
       set_of_books_id,
         accts_pay_code_combination_id,
         amount,
       match_status_flag,
       base_amount_to_post,
       prepay_amount_remaining,
         parent_invoice_id,
       org_id,
       description
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = inv_id
    AND    distribution_line_number = (SELECT MAX(distribution_line_number)
                           FROM   ap_invoice_distributions_all
                         WHERE  invoice_id = inv_id);

CURSOR for_std_invoice(inv_id NUMBER) IS
    SELECT invoice_type_lookup_code,
       vendor_id,
       vendor_site_id,
       invoice_currency_code,
         exchange_rate,
       exchange_rate_type,
       exchange_date,
       terms_id,
       payment_method_lookup_code,
         pay_group_lookup_code,
       invoice_num,invoice_date,
         goods_received_date,
       invoice_received_date
       --Added the above line by pavan on 06-Jun-01 to populate the goods_received_date
       --column for the RTN invoice generated
    FROM   ap_invoices_all
    WHERE  invoice_id = inv_id;

CURSOR for_payment_amount(inv_id NUMBER) IS
    SELECT amount
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = inv_id
    AND    distribution_line_number = 1;

CURSOR Fetch_Invoice_Num_Cur IS
  SELECT Invoice_Num
  FROM   Ap_Invoices_All
  WHERE  Invoice_Id = p_invoice_id;

CURSOR Fetch_App_Inv_Flag_Cur( p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER ) IS
     SELECT NVL( Approved_Invoice_Flag, 'N' ) Approved_Invoice_Flag
     FROM   JAI_CMN_VENDOR_SITES
     WHERE  Vendor_Id = p_vendor_id
     AND   Vendor_Site_Id = p_vendor_site_id;

/* commented by Aparajita for bug 2364106 on 15-may-2002
CURSOR for_invoice_num(invoice_num VARCHAR2) IS
   SELECT 'RTN/'|| invoice_num || '/' ||TO_CHAR(JAI_AP_TDS_INVOICE_NUM_S.CURRVAL)
   FROM DUAL;
*/


CURSOR get_fun_det1(inv_id NUMBER) IS
  SELECT invoice_amount,
       payment_status_flag,
       invoice_type_lookup_code,
       org_id
  FROM   ap_invoices_all
  WHERE  invoice_id = inv_id;

for_dist_insertion_tds_rec         for_distribution_insertion%ROWTYPE;
check_tds_prepayment_rec           check_for_tds_invoice%ROWTYPE;
check_tds_original_rec             check_for_tds_invoice_o%ROWTYPE;
for_payment_status_prepay_rec      for_payment_status%ROWTYPE;
for_pay_status_original_rec        for_payment_status%ROWTYPE;
for_distribution_insertion_rec     for_distribution_insertion%ROWTYPE;
for_vendor_id_prepay_rec         for_vendor_id%ROWTYPE;
for_vendor_id_original_rec         for_vendor_id%ROWTYPE;
for_std_invoice_rec              for_std_invoice%ROWTYPE;
for_std_invoice_tds_rec        for_std_invoice%ROWTYPE;
for_prepay_payment_amount_rec    for_payment_amount%ROWTYPE;
for_insertion_invoice_id           NUMBER;
insertion_amount                   NUMBER := 0;
reversal_amount                NUMBER := 0;
updation_amount                    NUMBER := 0;
updation_prepay_amount             NUMBER := 0;
reversal_prepay_amount           NUMBER := 0;
new_std_invoice_amount             NUMBER := 0;
if_part                    NUMBER := 0;
else_part                  NUMBER := 0;
req_id                       NUMBER;
req1_id                      NUMBER;
result                       BOOLEAN;
v_invoice_num                      VARCHAR2(100);
lv_app_source  VARCHAR2(100);--rchandan for bug#4428980
lv_add_err_msg  VARCHAR2(1000);--rchandan for bug#4428980

for_pre_invoice_tds_rec        for_std_invoice%ROWTYPE;
FOR_DIST_INSERTION_REC         for_distribution_insertion %ROWTYPE ;
for_dist_inst_rec            for_distribution_insertion %ROWTYPE ;
for_std_inv_rec_r            for_std_invoice%ROWTYPE ;
upd_amt_ap               NUMBER;
upd_inv_id               NUMBER;
get_fun_det_r1                 get_fun_det1%ROWTYPE;
X                    VARCHAR2(25);
--03-Jan-2002
-- added by Aparajita on 20 mar 2002
debug_flag                     CHAR(1); -- := 'N' ; --Ramananda for File.Sql.35
error_mesg                     VARCHAR2(255);
-- end addition by Aparajita on 20 mar 2002

v_tds_cm_num             VARCHAR2(60); -- Added by Aparajita for bug # 2338345 on 19th April'02

v_ja_ap_invoices_interface_no      NUMBER; -- added by Aparajita on 14-may-2002 for bug # 2364106.
v_ap_invoices_interface_no         NUMBER; -- added by Aparajita on 14-may-2002 for bug # 2364106.

v_Approved_Invoice_Flag        CHAR(1); -- := 'N';-- added by Aparajita on 29/07/2002 for bug # 2475416 --Ramananda for File.Sql.35


CURSOR get_base_inv_id(v_inv_num VARCHAR2) IS
SELECT invoice_id
FROM   JAI_AP_TDS_INVOICES
WHERE  tds_invoice_num = v_inv_num;

get_base_inv_id_rec            get_base_inv_id%ROWTYPE;

CURSOR get_exchange_rate_base_inv(v_inv_id NUMBER) IS
SELECT exchange_rate
FROM   ap_invoices_all
WHERE  invoice_id = v_inv_id;

Cursor get_prepay_dist_date is  -- bug 3112711 kpvs
select accounting_date
from   ap_invoice_distributions_all
where  invoice_distribution_id = p_invoice_distribution_id;

CURSOR cur_prnt_pay_priority     -- 4333449
IS
SELECT payment_priority
  FROM ap_payment_schedules_all
 WHERE invoice_id = p_invoice_id;

CURSOR cur_prnt_exchange_rate     -- 4333449
IS
SELECT exchange_rate
  FROM ap_invoices_all
 WHERE invoice_id = p_invoice_id;


get_exchange_rate_base_inv_rec     get_exchange_rate_base_inv%ROWTYPE;

--Below code added on 02-Feb-2002 for BUG#2205735

var_tds_invoice_num            VARCHAR2(40);
var_invoice_id             NUMBER;
var_tds_tax_id             NUMBER;
var_organization_id          NUMBER;
v_stage                            NUMBER(2):= 0; -- added by Aparajita on 23-may-2002 for tracking the stage in case of exception

---end addition of 02-Feb-2002
-- following added by Aparajita on 07/07/2002 for bug 2439034
v_ap_tds_cm_num                  ap_invoices_all.invoice_num%TYPE;
v_ap_sup_inv_num             ap_invoices_all.invoice_num%TYPE;
v_prepay_dist_date   ap_invoice_distributions_all.accounting_date%TYPE; -- bug 3112711 kpvs
ln_prnt_pay_priority          ap_payment_schedules_all.payment_priority%TYPE; -- 4333449
ln_prnt_exchange_rate         ap_invoices_all.exchange_rate%TYPE;  --4333449
ln_tax_rate                   JAI_AP_TDS_INVOICES.tds_tax_rate%type; -- 4333449
ln_tax_amount                 JAI_AP_TDS_INVOICES.tds_amount%type; -- 4333449
ln_taxable_amount             JAI_AP_TDS_INVOICES.invoice_amount%type; -- 4333449

/* Ramananda for BIND VARIABLES Compliance */
lv_tds_cm_num      VARCHAR2(100);
lv_credit_note_tds VARCHAR2(100);
lv_invoice_num_cm  VARCHAR2(100);
lv_rtn_invoice_num      VARCHAR2(100);
lv_standard_invoice_num VARCHAR2(100);
lv_rtn_std_invoice_num  VARCHAR2(100);
lv_invoice_num          VARCHAR2(100);
lv_credit_tds_auth      VARCHAR2(100);
lv_standard_return_excess VARCHAR2(100);


/* start additions by ssumaith - bug# 4448789 */
ln_legal_entity_id      NUMBER;
lv_legal_entity_name    VARCHAR2(240);
lv_return_status        VARCHAR2(100);
ln_msg_count            NUMBER;
ln_msg_data             VARCHAR2(1000);
 /*  ends additions by ssumaith - bug# 4448789*/

lv_batch_name ap_batches_all.batch_name%TYPE; --added by Ramananda for Bug#4584221

-- start function added by bug#3218881
function f_return_inv_amount
(
p_invoice_id      in  number,
p_distribution_id   in  number,
p_applied_prepay_amt  in  number,
p_attribute       in  varchar2
)
return number
is

  type v_table_of_number is table of number(15) index by binary_integer;
  type v_table_of_number_decimal is table of number(15, 4) index by binary_integer;

  v_distribution_amount_t   v_table_of_number;
  v_prepaid_amount_t      v_table_of_number;
  v_net_amount_t        v_table_of_number;
  v_tax_rate_t        v_table_of_number_decimal;

  v_return_inv_amt    number;

  -- cursor to fetch the distribution lines having taxes which are not prepayment lines.
  -- reversed lines if any also should not be considered.
  Cursor c_inv_distribution_details(cp_line_type_lookup_code ap_invoice_distributions_all.line_type_lookup_code%type,
                                    cp_global_attribute_category ap_invoice_distributions_all.global_attribute_category%TYPE ) is--rchandan for bug#4428980
  select amount, prepay_distribution_id, global_attribute1, global_attribute2, global_attribute3  --  rchandan for bug#4333488
  from   ap_invoice_distributions_all
  where  invoice_id = p_invoice_id
  and    nvl(reversal_flag, 'N') <> 'Y'
  and    line_type_lookup_code <> cp_line_type_lookup_code--rchandan for bug#4428980
  and    global_attribute_category = cp_global_attribute_category--rchandan for bug#4428980
  order by invoice_distribution_id;


  -- cursor to get the total of prepayment amoun having tds already applied
  Cursor c_inv_prepayments is
  select si.amount amount, pp.global_attribute1 global_attribute1, pp.global_attribute2 global_attribute2, pp.global_attribute3 global_attribute3   --  rchandan for bug#4333488
  from   ap_invoice_distributions_all si ,
       ap_invoice_distributions_all pp
  where  si.invoice_id=  p_invoice_id
  and    si.invoice_distribution_id <> p_distribution_id
  and    si.prepay_distribution_id = pp.invoice_distribution_id;


  cursor c_get_tax_rate(p_tax_id  number) is
  select  tax_rate
  from  JAI_CMN_TAXES_ALL
  where   tax_id = p_tax_id;

  v_tax_id      JAI_CMN_TAXES_ALL.tax_id%type;
  v_tax_rate      JAI_CMN_TAXES_ALL.tax_rate%type;

  v_distribution_cnt    number;
  v_loop_index      number;
  v_prepayment_amount   number;
  v_prepay_to_consider  number;
  v_distribution_amt    number;


begin

  fnd_file.put_line(fnd_file.log, 'Start of function f_return_inv_amount ');

  v_distribution_cnt:=0;

  for c_rec in c_inv_distribution_details('PREPAY','JA.IN.APXINWKB.DISTRIBUTIONS')   --rchandan for bug#4428980
  loop

    if p_attribute = 'ATTRIBUTE1' then

      if c_rec.global_attribute1 is null then   --  rchandan for bug#4333488
        goto continue_with_next;
      else
        v_tax_id := c_rec.global_attribute1;  --  rchandan for bug#4333488
      end if;

    elsif p_attribute = 'ATTRIBUTE2' then

      if c_rec.global_attribute2 is null then   --  rchandan for bug#4333488
        goto continue_with_next;
      else
        v_tax_id := c_rec.global_attribute2;   --  rchandan for bug#4333488
      end if;


    elsif p_attribute = 'ATTRIBUTE3' then

      if c_rec.global_attribute3 is null then   --  rchandan for bug#4333488
        goto continue_with_next;
      else
        v_tax_id := c_rec.global_attribute3;   --  rchandan for bug#4333488
      end if;

    end if;

    -- control comes here when the distribution line is qualified
    open c_get_tax_rate(v_tax_id);
    fetch c_get_tax_rate into v_tax_rate;
    close c_get_tax_rate;

    v_distribution_cnt := v_distribution_cnt + 1;

    v_distribution_amount_t(v_distribution_cnt) := c_rec.amount;
    v_tax_rate_t(v_distribution_cnt) := v_tax_rate;

    <<continue_with_next>>
    null;

  end loop; -- eligible distributions

  -- check if any prepayment is there
  v_prepayment_amount := 0;

  for c_rec in c_inv_prepayments loop

    if p_attribute = 'ATTRIBUTE1' then

      if c_rec.global_attribute1 is null then   --  rchandan for bug#4333488
        goto continue_with_next_prepay;
      end if;

    elsif p_attribute = 'ATTRIBUTE2' then

      if c_rec.global_attribute2 is null then  --  rchandan for bug#4333488
        goto continue_with_next_prepay;
      end if;

    elsif p_attribute = 'ATTRIBUTE3' then

      if c_rec.global_attribute3 is null then  --  rchandan for bug#4333488
        goto continue_with_next_prepay;
      end if;
    end if;

    -- control comes here when the prepayment line has tds.
    v_prepayment_amount := v_prepayment_amount + ( -1 * c_rec.amount) ;

    << continue_with_next_prepay >>
      null;

  end loop; -- prepayment

  fnd_file.put_line(fnd_file.log, 'Prepayment amount : ' || v_prepayment_amount);

  -- set the prepaid amount and net amount.
  for v_loop_index in 1 .. v_distribution_cnt loop

    if v_prepayment_amount >= v_distribution_amount_t(v_loop_index) then
      v_prepaid_amount_t(v_loop_index) :=  v_distribution_amount_t(v_loop_index);
    else
      v_prepaid_amount_t(v_loop_index) := v_prepayment_amount;
    end if;

    if v_prepayment_amount > 0 then
      v_prepayment_amount := v_prepayment_amount - v_prepaid_amount_t(v_loop_index);
    end if;

    v_net_amount_t(v_loop_index) :=  v_distribution_amount_t(v_loop_index) - v_prepaid_amount_t(v_loop_index);

  end loop;

  -- calculate the tax amount and amount to be reversed based on the current prepayment amount applied;
  v_return_inv_amt:=0;
  v_prepay_to_consider := p_applied_prepay_amt;

  for v_loop_index in 1 .. v_distribution_cnt loop

    v_distribution_amt := v_net_amount_t(v_loop_index);

    if v_distribution_amt > v_prepay_to_consider then
      v_distribution_amt := v_prepay_to_consider;
    end if;

    v_return_inv_amt := v_return_inv_amt + (  v_distribution_amt * ( v_tax_rate_t(v_loop_index) / 100) );
    v_prepay_to_consider := v_prepay_to_consider - v_distribution_amt;

    if v_prepay_to_consider <= 0 then
      exit;
    end if;

  end loop;

  fnd_file.put_line(fnd_file.log, 'End of function f_return_inv_amount. Return invoice amount :' || v_return_inv_amt);
  return v_return_inv_amt;

exception
  when others then
    fnd_file.put_line(fnd_file.log, 'Exception function f_return_inv_amount :' || sqlerrm);
    return 0;
end f_return_inv_amount;

-- End function added by bug#3218881



BEGIN

--  DECODE(vendor_rec.exchange_rate_type,'USER',vendor_rec.exchange_rate,NULL),
/*------------------------------------------------------------------------------------------
FILENAME: jai_ap_tds_old_pkg.process_prepayment_apply.sql

CHANGE HISTORY:
S.No    Date          Author           Details
-------------------------------------------------------------------------------------------------------------
1       10-May-01     Ajay Sharma      Procedure was prevented from firing once more (double
                                       RTN invoice and Credit Memos were getting generated)after
                                       application of prepayment if user approves the
                                       invoice (whose status becomes 'NEEDS REAPPROVAL'
                                       immediately after applying prepayment)immediately before
                                       completion of firing of related requests

2       06-Jun-01     Pavan          Code modified to populate the goods_received_date field
                                       in interfaces so that the Credit memos are imported
                                       successfully.

3      09-Aug-01      Ajay Sharma      Code modified to charge the RTN amount to tax account

4    11-Dec-01      RPK              Code modified to fire this program when the payment is
                           made/not made for the TDS Invoice of the Prepayment Invoice

5    08-Jan-02      RPK              Credit memo invoice generation for TDS Authority,when prepayment
                                       in foreign currency is applied for foreign currency standard invoices,
                                       ie ,the credit memo should be generated with the functional currency.

6    05-FEB-02      RPK              BUG # 2205735
                           Code modified to generate the RTN invoice and the credit memos
                           when the prepayment is applied to the unapproved standard invoices

7      20-Mar-2002    Aparajita        Bug # 2272378
                           Code modified to generate credit note and return invoice amount with correct tax
                           when a prepayment is applied to a standard invoice.


8      26-APR-02      Aparajita        Bug # 2338345
                                       The credit memo for Tax authority was getting generated starting with
                     the prepayment invoice number when an prepayment is applied to an unapproved
                     invoice, Changed it to start with the standard invoice number as the program for
                     approving the credit memo (jai_ap_tds_old_pkg.approve_invoice),expects the name to start
                     with standard invoice number.

9      14-may-2002    Aparajita        Bug # 2364106
                                       This procedure was giving ORA-08002:sequence
                                       JAI_AP_TDS_INVOICE_NUM_S.CURRVAL is not yet defined in this session. Changed
                                       All references to currval and also commented the cursor for_invoice_num as the
                                       cursor was referring JAI_AP_TDS_INVOICE_NUM_S.CURRVAL and passing the retrieved value
                                       to the request for approval, but that parameter was not getting used in the called object.

10    23-may-2002     Aparajita        bug # 2385421
                                       RTN invoice and TDS CM not created on applying a prepayment to a tds invoice. The
                                       procedure was raising a no data found exception. Added Fnd_File.put_line(Fnd_File.LOG,'') statements to generate log for this concurrent.

11.   08-july-2002    Aparajita       Bug # 2439034.
                                      Changes on the same line as that done for this bug in unapply prepayment, the
                                      object is jai_ap_tds_old_pkg.process_prepayment_unapply.

                    Change is to call the procedure for approval with code as 'APPLY' and the
                    invoice and credit memo numbers concatenated.

12.   29-july-2002    Aparajita     Bug # 2475416, RCS Version 615.2
                    Approved TDS and CM setup was allowed at null site, so changed the code to look
                    into null site setup if the site setup does not exist for the vendor for pre
                    approved TDS and CM. This was done to find out if the approval of TDS an CM
                    concurrent needs to be submitted.

12.   29-july-2002    Vijay Shankar   Bug # 2508086, RCS Version 615.3
                    During RTN invoice generation for foreign currency transaction, interface table is getting populated with exchange rate even if the exchange_rate_type
                    is NOT USER. This is giving INCONSISTANT RATE as rejection code. This is fixed by populating NULL if the
                    exchange_rate_type != 'USER'

13.   23-sep-2002     Aparajita       bug # 2503751, RCS vesrion 615.4
                                      Populate the invoice id of the original invoice in attribute1 of the tds related invoice
                                      for context value 'India Original Invoice for TDS'.

14.   08-nov-2002     Aparajita       bug # 2647361, RCS version 615.5
                                      Commented the formula at calculation of the amount for the RTN invoice and the credit note.
                                      There was no need of a if clause there and the if part was doing wrong
                                      caluclation when there were multiple distribution lines in the prepayment that is
                                      being applied.

15    15/01/2003     Aparajita        Bug # 2738340, RCV version 615.6
                                      Added the commit interval parameter in the request for APXIIMPT. This was missing.

16.   10/02/2003     Aparajita       Bug # 2779968. Version # 615.7.
                           If TDS invoices does not exist for the prepayment invoice, no processing like
                           return invoices generation is required.

17.   15/10/2003      kpvs            bug # 3112711 kpvs, version 616.1
                                      Cursor get_prepay_dist_date incorporated to get the GL date of the negative
                                      distribution line created in ap_invoice_distributions_all when the prepay invoice
                                      is applied to a standard invoice.

                        This date is inserted as invoice_date into ap_invoices_interface and as
                        accounting_date into ap_invoice_lines_interface. This would ensure that the CM for
                        TDS authority and SI for the supplier that get created on cancellation of a vendor
                        invoice, would bear proper invoice date and GL date instead of sysdate.

18.   22/12/2003     Aparajita        Bug#3218881. Version#618.1
                    Added inline function f_return_inv_amount to calculate the amount for the return
                    invoices when the standard invoice on which the prepayment is being applied is
                    approved.

                    As per the requirements, the amount to be reversed is to be based on the standard
                    invoice if the same is approved at the time of application. Application is for a
                    distribution line of the prepayment and with this changed approach all
                    distribution lines of the SI with TDS attached is considered in the first line
                    first basis to check the amount that should be reversed.

19.   09/02/2004  Aparajita     Bug#3408429. Version#618.2

                                      Whenever the standard invoice and prepeyment are in foreign currency, the exchange rate
                                      should be populated if the exchange rate type is 'User'. This is hard coded as 'USER',
                                      where as the lookup code used by base is User. Changed the code to convert the rate
                                      type to upper case and compare it with 'USER'

20.   02/05/2005    rchandan for bug#4333449. Version 116.1
                      India Original Invoice for TDS DFF is eliminated. So attribute1 of ap_invoices_al
                      is not populated whenevr an invoice is generated. Instead the Invoice details are
                      populated into jai_ap_tds_thhold_trxs. So whenever data is inserted into interface
                      tables the jai_ap_tds_thhold_trxs table is also populated.

21    11/05/2005     rchandan for bug#4333488. Version 116.2
                   The Invoice Distribution DFF is eliminated and a new global DFF is used to
                   maintain the functionality. From now the TDS tax, WCT tax and ESSI will not
                   be populated in the attribute columns of ap_invoice_distributions_all table
                   instead these will be populated in the global attribute columns. So the code changes are
                   made accordingly.
22.   14-Jul-2005  rchandan for bug#4487676.File version 117.2
                       Sequnece jai_ap_tds_invoice_num_s is renamed to JAI_AP_TDS_THHOLD_TRXS_S1


----------------------------------------------------------------------------------------------------------------------*/
  /* Ramananda for File.Sql.35*/
  debug_flag                     := 'N' ;
  v_Approved_Invoice_Flag        := 'N';-- added by Aparajita on 29/07/2002 for bug # 2475416
    /* Ramananda for File.Sql.35*/

  Fnd_File.put_line(Fnd_File.LOG,'Starting OF PROCEDURE Ja_In_Ap_Prepay_Invoice_P');
  fnd_file.put_line(fnd_file.log,'invoice_id ='||p_invoice_id);
  fnd_file.put_line(fnd_file.log,'invoice_distribution_id ='||p_invoice_distribution_id);
  fnd_file.put_line(fnd_file.log,'prepay_invoice_distribution_id ='||p_prepay_dist_id);


  /***   --CHECK IF TDS INVOICE FOR PREPAYMENT INVOICE EXISTS.**************/
  OPEN  check_for_tds_invoice(p_prepay_dist_id, p_attribute); -- replaced prepay_id with p_prepay_dist_id 25-09-00
  FETCH check_for_tds_invoice INTO check_tds_prepayment_rec;
  CLOSE check_for_tds_invoice;


  OPEN cur_prnt_pay_priority;      -- 4333449
  FETCH cur_prnt_pay_priority INTO ln_prnt_pay_priority;
  CLOSE cur_prnt_pay_priority;

  OPEN cur_prnt_exchange_rate;     -- 4333449
  FETCH cur_prnt_exchange_rate INTO ln_prnt_exchange_rate;
  CLOSE cur_prnt_exchange_rate;


  -- Start added by Aparajita for bug # 2779968 on 10/02/2003
  if check_tds_prepayment_rec.invoice_id is  null then
      Fnd_File.put_line(Fnd_File.LOG,
                       'Returning as TDS does not exist for the Prepayment invoice. No further processing is required ');

      Return;
  end if;
  -- End added by Aparajita for bug # 2779968 on 10/02/2003




  OPEN get_fun_det1(p_invoice_id);
  FETCH get_fun_det1 INTO get_fun_det_r1;
  CLOSE get_fun_det1;

  X:=jai_ap_tds_old_pkg.get_invoice_status(
          p_invoice_id,
          get_fun_det_r1.invoice_amount,
          get_fun_det_r1.payment_status_flag,
          get_fun_det_r1.invoice_type_lookup_code,
          get_fun_det_r1.org_id);

  v_stage:=1;

  --IF (X = 'NEVER APPROVED'  and p_param = 'I')  --commented on 31-Jan-2002
  --OR  p_param = 'U'  THEN     -- Condition added by Ajay Sharma on 10-May-01

  IF  p_param = 'U'  THEN --added on 31-Jan-2002
    x:= NULL;
  Fnd_File.put_line(Fnd_File.LOG,'END OF PROCEDURE Ja_In_Ap_Prepay_Invoice_P AS param = U');
  RETURN;
  END IF;



  IF check_tds_prepayment_rec.invoice_id IS NOT NULL THEN      --1

    Fnd_File.put_line(Fnd_File.LOG,'Inside IF check_tds_prepayment_rec.invoice_id IS NOT NULL');
    v_stage:=2;

    --GET VENDOR ID BASED ON THE TAX-ID FOR THE PREPAYMENT INVOICE.

  OPEN  for_vendor_id(check_tds_prepayment_rec.tds_tax_id);
  FETCH for_vendor_id INTO for_vendor_id_prepay_rec;
    CLOSE for_vendor_id;

  --GET PAYMENT_STATUS, INVOICE_AMOUNT AND INVOICE_ID OF TDS INVOICE FOR PREPAYMENT INVOICE.

    OPEN  for_payment_status(check_tds_prepayment_rec.tds_invoice_num,
                             for_vendor_id_prepay_rec.vendor_id,
               NVL(check_tds_prepayment_rec.organization_id, 0)
               );
    FETCH for_payment_status INTO for_payment_status_prepay_rec;
  CLOSE for_payment_status;

  OPEN  for_std_invoice(p_invoice_id);  --added on 05-Feb-2002
    FETCH for_std_invoice INTO for_std_invoice_rec;
    CLOSE for_std_invoice;

  -- CHECK IF TDS INVOICE FOR ORIGINAL INVOICE EXISTS.

    OPEN  check_for_tds_invoice_o(p_invoice_id,p_attribute);         -- *NEW.invoice_id
    FETCH check_for_tds_invoice_o INTO check_tds_original_rec;       -- Commented on 02-Feb-2002


    IF check_for_tds_invoice_o%FOUND THEN    --2
      --added on 05-Feb-2002
      Fnd_File.put_line(Fnd_File.LOG,'Inside IF check_for_tds_invoice_o%FOUND');
      v_stage:=3;
      var_tds_invoice_num := check_tds_original_rec.tds_invoice_num;
      var_invoice_id := check_tds_original_rec.invoice_ID;
      var_tds_tax_id := check_tds_original_rec.tds_tax_id;
      var_organization_id := check_tds_original_rec.organization_id;
      ln_tax_rate         := check_tds_original_rec.tds_tax_rate;
      ln_tax_amount       := check_tds_original_rec.tds_amount;
      ln_taxable_amount   := check_tds_original_rec.invoice_amount;

    -- line below added by Aparajita for bug 2338345.
    v_tds_cm_num := check_tds_original_rec.tds_invoice_num;

    ELSIF   check_for_tds_invoice_o%NOTFOUND THEN

      Fnd_File.put_line(Fnd_File.LOG,'Inside ELSIF check_for_tds_invoice_o%NOTFOUND');
      v_stage:=4;
      var_tds_invoice_num := check_tds_prepayment_rec.tds_invoice_num;
      var_invoice_id := check_tds_prepayment_rec.invoice_ID;
      var_tds_tax_id := check_tds_prepayment_rec.tds_tax_id;
      var_organization_id := check_tds_prepayment_rec.organization_id;
      ln_tax_rate         := check_tds_prepayment_rec.tds_tax_rate;
      ln_tax_amount       := check_tds_prepayment_rec.tds_amount;
      ln_taxable_amount   := check_tds_prepayment_rec.invoice_amount;


    END IF;

  -- following If added by Aparajita on 29th April for bug # 2338345
  IF v_tds_cm_num IS NULL THEN
      -- the TDS invoice corrosponding to the standard invoice is not found, this would be when
    -- the standard invoice is not approved yet.
    -- the CM for TDS authortiy should then should have the standard invoice number suffixed by TDS
    v_tds_cm_num := for_std_invoice_rec.invoice_num || 'TDS';
  END IF;

    --end addition of 05-Feb-2002

  --GET VENDOR ID BASED ON THE TAX-ID FOR THE ORIGINAL INVOICE.
    OPEN  for_vendor_id(var_tds_tax_id);
    FETCH for_vendor_id INTO for_vendor_id_original_rec;
    CLOSE for_vendor_id;

  --GET PAYMENT_STATUS, INVOICE_AMOUNT AND INVOICE_ID OF TDS INVOICE FOR ORIGINAL INVOICE.

    OPEN  for_payment_status(var_tds_invoice_num,
                 for_vendor_id_original_rec.vendor_id,
               NVL(var_organization_id, 0)
              );

    FETCH for_payment_status INTO for_pay_status_original_rec;
  CLOSE for_payment_status;

  --GET PREPAYMENT TDS INVOICE_AMOUNT, THIS IS THE AMOUNT OF INVOICE ORIGINALLY CREATED
    --AND NOT THE LATEST AMOUNT

    OPEN  for_payment_amount(for_payment_status_prepay_rec.invoice_id);
    FETCH for_payment_amount INTO for_prepay_payment_amount_rec;
  CLOSE for_payment_amount;

    --CALCULATING THE PROPORTIONATE TAX TO BE APPLIED.

    Fnd_File.put_line(Fnd_File.LOG,'calculating the proportionate tax TO be applied');
    Fnd_File.put_line(Fnd_File.LOG,'p_amount = ' || p_amount);
    Fnd_File.put_line(Fnd_File.LOG,'for_prepay_payment_amount_rec.amount = ' || for_prepay_payment_amount_rec.amount);
    Fnd_File.put_line(Fnd_File.LOG,'check_tds_prepayment_rec.invoice_amount = ' || check_tds_prepayment_rec.invoice_amount);

    v_stage:=5;

  -- the following if commented by Aparajita for bug # 2647361
  -- This was creating problem when prepayment has multiple line and partail amount is being applied.
  -- There is no need for this if
    /*
  IF var_invoice_amount =   var_amt_applied + p_amount  THEN  --13
    insertion_amount := (for_prepay_payment_amount_rec.amount - var_amt_reversed);
    ELSE                --13
      -- insertion_amount :=FLOOR(p_amount * ( for_prepay_payment_amount_rec.amount /  var_invoice_amount));

      --  The above line changed to the line below by Aparajita for correct calculation of tax on 20-mar-2002
      --  the function FLOOR was also changed to ROUND. Bug # 2272378
     end comment by Aparajita on 08/11/2002 for bug #  2647361
     */

  -- start added for bug#3218881
  if check_for_tds_invoice_o%found then
    -- SI has been approved at the time of application and has TDS invoices generated.
    insertion_amount := round(f_return_inv_amount(p_invoice_id, p_invoice_distribution_id, p_amount, p_attribute));
  else
    -- SI has not been approved at the time of application and has no TDS invoices generated.
    insertion_amount :=round (p_amount * ( for_prepay_payment_amount_rec.amount /  check_tds_prepayment_rec.invoice_amount));
   end if;
  -- End added for bug#3218881

  -- END IF;                --13


    IF      for_pay_status_original_rec.payment_status_flag = 'N'
     -- AND for_payment_status_prepay_rec.payment_status_flag = 'N'        --Commented on 11-Dec-01
        AND for_payment_status_prepay_rec.payment_status_flag IN ('Y','N')     --Added on 11-Dec-01
        AND for_vendor_id_original_rec.vendor_id = for_vendor_id_prepay_rec.vendor_id   THEN

    ----------------CASE 1
      Fnd_File.put_line(Fnd_File.LOG,'inside case1 : payment_status_flag = N');
      v_stage:=6;

      OPEN for_std_invoice(for_pay_status_original_rec.invoice_id);
      FETCH for_std_invoice INTO for_std_invoice_tds_rec;
      CLOSE for_std_invoice;

      OPEN for_distribution_insertion(for_pay_status_original_rec.invoice_id);
      FETCH for_distribution_insertion INTO for_dist_insertion_tds_rec ;
      CLOSE for_distribution_insertion ;

      --03-Jan-2002
      OPEN get_base_inv_id(for_std_invoice_tds_rec.invoice_num);
      FETCH get_base_inv_id INTO get_base_inv_id_rec;
      CLOSE get_base_inv_id;

      OPEN Get_exchange_rate_base_inv(get_base_inv_id_rec.invoice_id);
      FETCH get_exchange_rate_base_inv INTO get_exchange_rate_base_inv_rec;
      CLOSE get_exchange_rate_base_inv;
      --end 03-Jan-2002

    v_ja_ap_invoices_interface_no := NULL;
    SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval--JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL changed by rchandan for bug#4487676
    INTO   v_ja_ap_invoices_interface_no
    FROM dual;

    v_ap_invoices_interface_no := NULL;
    SELECT ap_invoices_interface_s.NEXTVAL
    INTO   v_ap_invoices_interface_no
    FROM dual;

          Open get_prepay_dist_date; -- bug 3112711 kpvs
          fetch get_prepay_dist_date into v_prepay_dist_date;
          close get_prepay_dist_date;

      Fnd_File.put_line(Fnd_File.LOG,
      'BEFORE INSERTING INTO ap_invoices_interface 1 : CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX');

      v_stage:=7;

/* Modified by Ramananda for bug# 4407184 ,start */


      lv_tds_cm_num      := v_tds_cm_num ||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no);
      lv_credit_note_tds := 'CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_std_invoice_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ;
      lv_invoice_num_cm  := for_std_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no) ;


    /* start additions by ssumaith - bug# 4448789 */
    jai_cmn_utils_pkg.GET_LE_INFO(
    P_API_VERSION            =>  NULL ,
    P_INIT_MSG_LIST          =>  NULL ,
    P_COMMIT                 =>  NULL ,
    P_LEDGER_ID              =>  NULL,
    P_BSV                    =>  NULL,
    P_ORG_ID                 =>  P_ORG_ID,
    X_RETURN_STATUS          =>  lv_return_status ,
    X_MSG_COUNT              =>  ln_msg_count,
    X_MSG_DATA               =>  ln_msg_data,
    X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
    X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
    );
     /*  ends additions by ssumaith - bug# 4448789*/


     INSERT INTO ap_invoices_interface (
       invoice_id,
       invoice_num,
       invoice_type_lookup_code,
       invoice_date,
       vendor_id,
       vendor_site_id,
       invoice_amount,
       invoice_currency_code,
       exchange_rate,
       exchange_rate_type,
       exchange_date,
       terms_id,
       description,
       source,
       -- voucher_num, Harshita for Bug 4870243
       payment_method_lookup_code,
       pay_group_lookup_code,
       org_id,
       legal_entity_id ,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       group_id	/*Bug 4716884*/
   ) VALUES (
       v_ap_invoices_interface_no,
       --for_std_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL),
       -- v_tds_cm_num ||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL)
       lv_tds_cm_num , --v_tds_cm_num ||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
       -- the line below is being commented and replaced by line above by Aparajita on 29 apr 2002 for bug 2338345
       -- var_tds_invoice_num||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL),
       'CREDIT',
       v_prepay_dist_date,-- bug 3112711 kpvs  --TRUNC( SYSDATE ), --for_std_invoice_tds_rec.invoice_date,
       for_std_invoice_tds_rec.vendor_id,
       for_std_invoice_tds_rec.vendor_site_id,
       --(-1)*insertion_amount, --commented on 13-Dec-2001
       ((-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1)), --added on 03-Jan-2002
       for_std_invoice_tds_rec.invoice_currency_code,
       for_std_invoice_tds_rec.exchange_rate,
       for_std_invoice_tds_rec.exchange_rate_type,
       for_std_invoice_tds_rec.exchange_date,
       for_std_invoice_tds_rec.terms_id,
       lv_credit_note_tds, --'CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_std_invoice_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ,
       'INDIA TDS', /* --'TDS',--Ramanand for bug#4388958 */
       -- for_std_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.CURRVAL),
     --   lv_invoice_num_cm, --for_std_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no), Harshita for Bug 4870243
       for_std_invoice_tds_rec.payment_method_lookup_code,
       for_std_invoice_tds_rec.pay_group_lookup_code,
       p_org_id,
       ln_legal_entity_id,
       p_created_by,
       p_creation_date,
       p_last_updated_by,
       p_last_update_date,
       p_last_updated_by,
       to_char(p_invoice_id)	/*Bug 4716884*/
    );

/* Modified by Ramananda for bug# 4407184 , end */

    -- following line added by Aparajita for bug # 2439034.
    v_ap_tds_cm_num := v_tds_cm_num ||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no);

      Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoice_lines_interface 1 : CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED');
      v_stage:=8;


/* Modified by Ramananda for bug# 4407184 ,start */

   lv_credit_note_tds := 'CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED BY  '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id) ;

   INSERT INTO ap_invoice_lines_interface (
    invoice_id,
    invoice_line_id,
    line_number,
    line_type_lookup_code,
    amount,
    accounting_date,
    description,
    dist_code_combination_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login

  ) VALUES (
       v_ap_invoices_interface_no,
       ap_invoice_lines_interface_s.NEXTVAL,
       1, --THERE WILL ALWAYS BE ONLY ONE LINE.
       'ITEM',
       --(-1)*insertion_amount,--commented on 13-Dec-2001
       (-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1), --added on 03-Jan-2002
       v_prepay_dist_date, -- bug 3112711 kpvsTRUNC( SYSDATE )
       lv_credit_note_tds, --'CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED BY  '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id),
       for_dist_insertion_tds_rec.dist_code_combination_id,
       p_created_by,
       p_creation_date,
       p_last_updated_by,
       p_last_update_date,
       p_last_updated_by

    );

/* Modified by Ramananda for bug# 4407184 , end */

    /*OPEN  for_std_invoice(p_invoice_id);
      FETCH for_std_invoice INTO for_std_invoice_rec;
      CLOSE for_std_invoice;
    */   --commented on 05-Feb-2002

    OPEN  for_distribution_insertion(p_invoice_id);
    FETCH for_distribution_insertion INTO for_dist_insertion_rec;
    CLOSE for_distribution_insertion;

    v_ja_ap_invoices_interface_no := NULL;

    SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval--JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL changed by rchandan for bug#4487676
    INTO   v_ja_ap_invoices_interface_no
    FROM   dual;

    v_ap_invoices_interface_no := NULL;

    SELECT ap_invoices_interface_s.NEXTVAL
    INTO   v_ap_invoices_interface_no
    FROM dual;

      Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoices_interface 2 : STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED');
      v_stage:=9;

/* Modified by Ramananda for bug# 4407184 ,start */

      lv_rtn_invoice_num      := 'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no);
      lv_standard_invoice_num := 'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||for_std_invoice_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id);  --  NEW.prepay_id replaced with p_invoice_id


    /* start additions by ssumaith - bug# 4448789 */
    jai_cmn_utils_pkg.GET_LE_INFO(
    P_API_VERSION            =>  NULL ,
    P_INIT_MSG_LIST          =>  NULL ,
    P_COMMIT                 =>  NULL ,
    P_LEDGER_ID              =>  NULL,
    P_BSV                    =>  NULL,
    P_ORG_ID                 =>  P_ORG_ID,
    X_RETURN_STATUS          =>  lv_return_status ,
    X_MSG_COUNT              =>  ln_msg_count,
    X_MSG_DATA               =>  ln_msg_data,
    X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
    X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
    );
     /*  ends additions by ssumaith - bug# 4448789*/

      INSERT INTO ap_invoices_interface (
       invoice_id,
       invoice_num,
       invoice_type_lookup_code,
       invoice_date,
       vendor_id,
       vendor_site_id,
       invoice_amount,
       invoice_currency_code,
       exchange_rate,
       exchange_rate_type,
       exchange_date,
       terms_id,
       description,
       source,
       -- voucher_num, Harshita for Bug 4870243
       payment_method_lookup_code,
       pay_group_lookup_code,
       org_id,
       legal_entity_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       goods_received_date,
       invoice_received_date, --Added by pavan on 06-Jun-01
       group_id	/*Bug 4716884*/
    ) VALUES (
       v_ap_invoices_interface_no,
       -- 'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL),
       lv_rtn_invoice_num, --'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
       'STANDARD',
       v_prepay_dist_date, --bug 3112711 kpvs -- TRUNC(SYSDATE), --for_std_invoice_rec.invoice_date,
       for_std_invoice_rec.vendor_id,
       for_std_invoice_rec.vendor_site_id,
       insertion_amount,
       for_std_invoice_rec.invoice_currency_code,
       -- for_std_invoice_rec.exchange_rate, -- commented by cbabu for Bug#2508086
       DECODE( upper(for_std_invoice_rec.exchange_rate_type), 'USER', for_std_invoice_rec.exchange_rate, NULL),
       -- Bug#3408429, cbabu for Bug#2508086
       for_std_invoice_rec.exchange_rate_type,
       for_std_invoice_rec.exchange_date,
       for_std_invoice_rec.terms_id,
       lv_standard_invoice_num , --'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||for_std_invoice_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id), --  NEW.prepay_id replaced with p_invoice_id
       'INDIA TDS', /* --'TDS', --Ramanand for bug#4388958 */
       -- 'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.CURRVAL),
       -- lv_rtn_invoice_num      , --'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no), Harshita for Bug 4870243
       for_std_invoice_rec.payment_method_lookup_code,
       for_std_invoice_rec.pay_group_lookup_code,
       p_org_id,
       ln_legal_entity_id,
       p_created_by,
       p_creation_date,
       p_last_updated_by,
       p_last_update_date,
       p_last_updated_by,
       for_std_invoice_rec.goods_received_date,
       for_std_invoice_rec.invoice_received_date,
       to_char(p_invoice_id)	/*Bug 4716884*/
    ); --Added by pavan on 06-Jun-01

/* Modified by Ramananda for bug# 4407184 , end */


    -- following line added by Aparajita on 07/07/2002 for bug # 2439034
    v_ap_sup_inv_num := 'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no);

      Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoice_lines_interface 2 : STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED');
      v_stage:=10;

/* Modified by Ramananda for bug# 4407184 , start */
    lv_standard_invoice_num := 'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id) ;

    INSERT INTO ap_invoice_lines_interface
     (
     invoice_id,
     invoice_line_id,
     line_number,
     line_type_lookup_code,
     amount,
     accounting_date,
     description,
     dist_code_combination_id,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login
    )
    VALUES
    (
     v_ap_invoices_interface_no,
     ap_invoice_lines_interface_s.NEXTVAL,
     1, --THERE WILL ALWAYS BE ONLY ONE LINE.
     'ITEM',
     insertion_amount,
     v_prepay_dist_date, --bug 3112711 kpvs TRUNC( SYSDATE ),
     lv_standard_invoice_num, --'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id) ,
     --for_dist_insertion_rec.dist_code_combination_id,  --Commented by Ajay Sharma on 09-AUG-01
     for_dist_insertion_tds_rec.dist_code_combination_id, --Added by Ajay Sharma --on 09-AUG-01
     p_created_by,
     p_creation_date,
     p_last_updated_by,
     p_last_update_date,
     p_last_updated_by
      );

/* Modified by Ramananda for bug# 4407184 , end */

     jai_ap_tds_generation_pkg.insert_tds_thhold_trxs        -------4333449
          (
            p_invoice_id                        =>      p_invoice_id,
            p_tds_event                         =>      'OLD TDS INVOICE PREPAY',
            p_tax_id                            =>      var_tds_tax_id,
            p_tax_rate                          =>      ln_tax_rate,
            p_taxable_amount                    =>      ln_taxable_amount,
            p_tax_amount                        =>      ln_tax_amount,
            p_tds_authority_vendor_id           =>      for_std_invoice_tds_rec.vendor_id,
            p_tds_authority_vendor_site_id      =>      for_std_invoice_tds_rec.vendor_site_id,
            p_invoice_tds_authority_num         =>      v_tds_cm_num ||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
            p_invoice_tds_authority_type        =>      'CREDIT',
            p_invoice_tds_authority_curr        =>      for_std_invoice_tds_rec.invoice_currency_code,
            p_invoice_tds_authority_amt         =>      ((-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1)),
            p_vendor_id                         =>      for_std_invoice_rec.vendor_id,
            p_vendor_site_id                    =>      for_std_invoice_rec.vendor_site_id,
            p_invoice_vendor_num                =>      'RTN/'||for_std_invoice_rec.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
            p_invoice_vendor_type               =>      'STANDARD',
            p_invoice_vendor_curr               =>      for_std_invoice_rec.invoice_currency_code,
            p_invoice_vendor_amt                =>      insertion_amount,
            p_parent_inv_payment_priority       =>      ln_prnt_pay_priority,
            p_parent_inv_exchange_rate          =>      ln_prnt_exchange_rate
        );


      Fnd_File.put_line(Fnd_File.LOG,'BEFORE submitting the Payables OPEN INTERFACE Import concurrent request 1');
      v_stage:=11;
      result := Fnd_Request.set_mode(TRUE);

      lv_batch_name := jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id); --Ramananda for Bug#4584221

      req_id := Fnd_Request.submit_request
      (
        'SQLAP',
        'APXIIMPT',
        'Localization Payables OPEN INTERFACE Import',
                '',
        FALSE,
  /* Bug 4774647. Added by Lakshmi Gopalsami
          Passed operating unit also as this parameter has been
          added by base .
        */
        '',
        'INDIA TDS', /* --'TDS', --Ramanand for bug#4388958*/
        to_char(p_invoice_id),	/*Bug 4716884*/
        --'TDS'||TO_CHAR(TRUNC(SYSDATE)),
        --commented the above and added the below by Ramananda for bug#4584221
        lv_batch_name,
        '',
        '',
        '',
                'Y',
        'N',
        'N',
        'N',
        1000, -- commit interval parameter added by Aparajita for bug # 2738340 on 15/01/2003
        p_created_by,
        p_last_updated_by
        );

      upd_inv_id := var_invoice_id ;

    UPDATE JAI_AP_TDS_INVOICES
    SET    amt_reversed = NVL(amt_reversed,0) + insertion_amount,
         amt_applied = NVL(amt_applied,0) + p_amount
    WHERE  invoice_id = upd_inv_id ;


    END IF; --  CASE 1

    /*FOR  App_Flag_Rec IN Fetch_App_Inv_Flag_Cur( for_std_invoice_rec.vendor_id,for_std_invoice_rec.vendor_site_id ) LOOP

      IF App_Flag_Rec.Approved_Invoice_Flag = 'Y' THEN
    */
    /* This has been commented by Aparajita as this variable v_invoice_num is no more used and
       this cursor was using currval for sequence  JAI_AP_TDS_INVOICE_NUM_S,bug 2364106

      OPEN  for_invoice_num(for_std_invoice_rec.invoice_num);
      FETCH for_invoice_num INTO v_invoice_num;
      CLOSE for_invoice_num;
    end comment by Aparajita on 15th May for bug 2364106 */

    v_Approved_Invoice_Flag := 'N';

    BEGIN

            SELECT NVL( Approved_Invoice_Flag, 'N' )
      INTO   v_Approved_Invoice_Flag
            FROM   JAI_CMN_VENDOR_SITES
        WHERE  Vendor_Id = for_std_invoice_rec.vendor_id
        AND    Vendor_Site_Id = for_std_invoice_rec.vendor_site_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        BEGIN

              SELECT NVL( Approved_Invoice_Flag, 'N' )
        INTO   v_Approved_Invoice_Flag
              FROM   JAI_CMN_VENDOR_SITES
          WHERE  Vendor_Id = for_std_invoice_rec.vendor_id
          AND    Vendor_Site_Id = 0;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
        NULL;
      END;

    END;

        IF  v_Approved_Invoice_Flag = 'Y' THEN

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE submitting the Approval OF TDS AND CM concurrent request FOR invoice id '|| p_invoice_id);
        v_stage:=12;
    result := Fnd_Request.set_mode(TRUE);
    req1_id := Fnd_Request.submit_request
           (
            'JA',
          'JAINAPIN',
          'Approval OF TDS AND CM - Localization)',
          SYSDATE,
          FALSE,
          req_id,
          for_std_invoice_rec.vendor_id,
          for_std_invoice_rec.vendor_site_id,
          p_invoice_id, --  NEW.Invoice_Id replaced with p_invoice_id
          v_ap_tds_cm_num || ';' || v_ap_sup_inv_num, -- Changed by aparajita on 07/07/2002 for bug 2439034, earlier was null
          'APPLY'
           );

      END IF;

    -- END LOOP;


    IF  for_pay_status_original_rec.payment_status_flag <> 'N'
         OR for_vendor_id_original_rec.vendor_id <> for_vendor_id_prepay_rec.vendor_id THEN

        Fnd_File.put_line(Fnd_File.LOG,'Inside Case2 : payment_status_flag <> N ');
        v_stage:=13;
        -- CASE 2

        OPEN for_std_invoice(for_payment_status_prepay_rec.invoice_id);
    FETCH for_std_invoice INTO for_pre_invoice_tds_rec;
    CLOSE for_std_invoice;

    OPEN for_distribution_insertion(for_payment_status_prepay_rec.invoice_id);
    FETCH for_distribution_insertion INTO for_dist_insertion_tds_rec ;
    CLOSE for_distribution_insertion ;

      v_ja_ap_invoices_interface_no := NULL;

      SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval--JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL changed by rchandan for bug#4487676
      INTO   v_ja_ap_invoices_interface_no
      FROM dual;

       v_ap_invoices_interface_no := NULL;
     SELECT ap_invoices_interface_s.NEXTVAL
     INTO   v_ap_invoices_interface_no
     FROM dual;

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoices_interface 3:CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX');
        v_stage:=14;

/* Modified by Ramananda for bug# 4407184 ,start */

      lv_invoice_num     :=for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no);
      lv_credit_tds_auth :='CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_pre_invoice_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ;

   /* start additions by ssumaith - bug# 4448789 */
   jai_cmn_utils_pkg.GET_LE_INFO(
   P_API_VERSION            =>  NULL ,
   P_INIT_MSG_LIST          =>  NULL ,
   P_COMMIT                 =>  NULL ,
   P_LEDGER_ID              =>  NULL,
   P_BSV                    =>  NULL,
   P_ORG_ID                 =>  P_ORG_ID,
   X_RETURN_STATUS          =>  lv_return_status ,
   X_MSG_COUNT              =>  ln_msg_count,
   X_MSG_DATA               =>  ln_msg_data,
   X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
   X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
   );
    /*  ends additions by ssumaith - bug# 4448789*/

    INSERT INTO ap_invoices_interface (
       invoice_id,
       invoice_num,
       invoice_type_lookup_code,
       invoice_date,
       vendor_id,
       vendor_site_id,
       invoice_amount,
       invoice_currency_code,
       exchange_rate,
       exchange_rate_type,
       exchange_date,
       terms_id,
       description,
       source,
       -- voucher_num, Harshita for Bug 4870243
       payment_method_lookup_code,
       pay_group_lookup_code,
       org_id,
       legal_entity_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       group_id	/*Bug 4716884*/
    ) VALUES (
      v_ap_invoices_interface_no,
      -- for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL),
      lv_invoice_num, --for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
      'CREDIT',
      v_prepay_dist_date, --bug 3112711 kpvs TRUNC( SYSDATE ) --for_std_invoice_tds_rec.invoice_date,
      for_pre_invoice_tds_rec.vendor_id,
      for_pre_invoice_tds_rec.vendor_site_id,
      --(-1)*insertion_amount,
      (-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1), --added on 03-Jan-2002
      for_pre_invoice_tds_rec.invoice_currency_code,
      for_pre_invoice_tds_rec.exchange_rate,
      for_pre_invoice_tds_rec.exchange_rate_type,
      for_pre_invoice_tds_rec.exchange_date,
      for_pre_invoice_tds_rec.terms_id,
      lv_credit_tds_auth, --'CREDIT NOTE FOR TDS AUTHORITY FOR APPLIED AMOUNT OF TAX '||for_pre_invoice_tds_rec.invoice_num||' OR '||TO_CHAR(p_invoice_id) ,
      'INDIA TDS', /* --'TDS',--Ramanand for bug#4388958*/
      -- for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.CURRVAL),
      -- lv_invoice_num, --for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no), Harshita for Bug 4870243
      for_pre_invoice_tds_rec.payment_method_lookup_code,
      for_pre_invoice_tds_rec.pay_group_lookup_code,
      p_org_id,
      ln_legal_entity_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by,
      to_char(p_invoice_id)	/*Bug 4716884*/
        );

/* Modified by Ramananda for bug# 4407184 , end */

    -- following line added by Aparajita for bug # 2439034.
    v_ap_tds_cm_num := for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no);

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoice_lines_interface 3 :CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED' );
        v_stage:=14;

/* Modified by Ramananda for bug# 4407184 , start */
      lv_credit_note_tds := 'CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED BY  '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id);

      INSERT INTO ap_invoice_lines_interface (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      amount,
      accounting_date,
      description,
      dist_code_combination_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
       ) VALUES (
      v_ap_invoices_interface_no,
      ap_invoice_lines_interface_s.NEXTVAL,
      1, --THERE WILL ALWAYS BE ONLY ONE LINE.
      'ITEM',
      --(-1)*insertion_amount,--commented on 13-Dec-2001
      (-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1), --added on 03-Jan-2002
      v_prepay_dist_date, --bug 3112711 kpvs TRUNC( SYSDATE )
      lv_credit_note_tds, --'CREDIT NOTE FOR TDS TAX AUTHORITY FOR TAX APPLIED BY  '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id),
      for_dist_insertion_tds_rec.dist_code_combination_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by
        );

/* Modified by Ramananda for bug# 4407184 , end */

        OPEN  for_std_invoice(var_invoice_id);
        FETCH for_std_invoice INTO for_std_inv_rec_r;
        CLOSE for_std_invoice;

    OPEN  for_distribution_insertion(var_invoice_id);
    FETCH for_distribution_insertion INTO for_dist_inst_rec;
    CLOSE for_distribution_insertion;

      v_ja_ap_invoices_interface_no := NULL;

      SELECT JAI_AP_TDS_THHOLD_TRXS_S1.nextval--JAI_AP_TDS_INVOICE_NUM_S.NEXTVAL changed by rchandan for bug#4487676
      INTO   v_ja_ap_invoices_interface_no
      FROM dual;

      v_ap_invoices_interface_no := NULL;

      SELECT ap_invoices_interface_s.NEXTVAL
      INTO   v_ap_invoices_interface_no
      FROM dual;

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoices_interface 4: STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED');
        v_stage:=15;

/* Modified by Ramananda for bug# 4407184 ,start */

    lv_rtn_invoice_num  := 'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no);
    lv_standard_return_excess := 'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||for_std_inv_rec_r.invoice_num||' OR '||TO_CHAR(p_invoice_id);/**** NEW.prepay_id replaced with p_invoice_id*******/

/* start additions by ssumaith - bug# 4448789 */
jai_cmn_utils_pkg.GET_LE_INFO(
P_API_VERSION            =>  NULL ,
P_INIT_MSG_LIST          =>  NULL ,
P_COMMIT                 =>  NULL ,
P_LEDGER_ID              =>  NULL,
P_BSV                    =>  NULL,
P_ORG_ID                 =>  P_ORG_ID,
X_RETURN_STATUS          =>  lv_return_status ,
X_MSG_COUNT              =>  ln_msg_count,
X_MSG_DATA               =>  ln_msg_data,
X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
);
 /*  ends additions by ssumaith - bug# 4448789*/

    INSERT INTO ap_invoices_interface (
      invoice_id,
      invoice_num,
      invoice_type_lookup_code,
      invoice_date,
      vendor_id,
      vendor_site_id,
      invoice_amount,
      invoice_currency_code,
      exchange_rate,
      exchange_rate_type,
      exchange_date,
      terms_id,
      description,
      source,
      -- voucher_num, Harshita for Bug 4870243
      payment_method_lookup_code,
      pay_group_lookup_code,
      org_id,
      legal_entity_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      goods_received_date,
      invoice_received_date,   --Added by pavan on 06-Jun-01
      group_id	/*Bug 4716884*/
  ) VALUES (
      v_ap_invoices_interface_no,
      -- 'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.NEXTVAL),
      lv_rtn_invoice_num , --'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
      'STANDARD',
      v_prepay_dist_date, --bug 3112711 kpvs TRUNC(SYSDATE), --for_std_invoice_rec.invoice_date,
      for_std_inv_rec_r.vendor_id,
      for_std_inv_rec_r.vendor_site_id,
      insertion_amount,
      for_std_inv_rec_r.invoice_currency_code,
      -- for_std_inv_rec_r.exchange_rate, -- commented by cbabu for Bug#2508086
        DECODE( upper(for_std_inv_rec_r.exchange_rate_type), 'USER', for_std_inv_rec_r.exchange_rate, NULL),
        -- cbabu for Bug#2508086 Bug#3408429
      for_std_inv_rec_r.exchange_rate_type,
      for_std_inv_rec_r.exchange_date,
      for_std_inv_rec_r.terms_id,
      lv_standard_return_excess, --'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||for_std_inv_rec_r.invoice_num||' OR '||TO_CHAR(p_invoice_id) ,/**** NEW.prepay_id replaced with p_invoice_id*******/
      'INDIA TDS', /*--'TDS', --Ramanand for bug#4388958*/
      -- 'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(ja_in_ap_invoices_interface_s1.CURRVAL),
      --lv_rtn_invoice_num, --'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no), Harshita for Bug 4870243
      for_std_inv_rec_r.payment_method_lookup_code,
      for_std_inv_rec_r.pay_group_lookup_code,
      p_org_id,
      ln_legal_entity_id,
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by,
      for_std_inv_rec_r.goods_received_date,
      for_std_inv_rec_r.invoice_received_date,  --Added by RPK on 13-DEC-01
      to_char(p_invoice_id)	/*Bug 4716884*/
    );

/* Modified by Ramananda for bug# 4407184 , end */

      -- following line added by Aparajita on 07/07/2002 for bug # 2439034
      v_ap_sup_inv_num := 'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no);

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE INSERTING INTO ap_invoice_lines_interface 4: STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED');
        v_stage:=15;

/* Modified by Ramananda for bug# 4407184 , start */
      lv_standard_return_excess := 'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id) ;

      INSERT INTO ap_invoice_lines_interface (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      amount,
      accounting_date,
      description,
      dist_code_combination_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
    ) VALUES (
      v_ap_invoices_interface_no,
      ap_invoice_lines_interface_s.NEXTVAL,
      1, --THERE WILL ALWAYS BE ONLY ONE LINE.
      'ITEM',
      insertion_amount,
      v_prepay_dist_date, --bug 3112711 kpvs TRUNC( SYSDATE )
      lv_standard_return_excess, --'STANDARD INVOICE FOR RETURNING EXCESS TDS DEDUCTED ON '||TO_CHAR(p_invoice_id)||' OR '||TO_CHAR(p_invoice_distribution_id) ,
      -- for_dist_inst_rec.dist_code_combination_id,  --Commented by Ajay Sharma on 09-AUG-01
      for_dist_insertion_tds_rec.dist_code_combination_id, --Added by Ajay Sharma on 09-AUG-01
      p_created_by,
      p_creation_date,
      p_last_updated_by,
      p_last_update_date,
      p_last_updated_by
    );

/* Modified by Ramananda for bug# 4407184 , end */


    jai_ap_tds_generation_pkg.insert_tds_thhold_trxs        -------4333449
              (
                p_invoice_id                        =>      p_invoice_id,
                p_tds_event                         =>      'OLD TDS INVOICE PREPAY',
                p_tax_id                            =>      var_tds_tax_id,
                p_tax_rate                          =>      ln_tax_rate,
                p_taxable_amount                    =>      ln_taxable_amount,
                p_tax_amount                        =>      ln_tax_amount,
                p_tds_authority_vendor_id           =>      for_pre_invoice_tds_rec.vendor_id,
                p_tds_authority_vendor_site_id      =>      for_pre_invoice_tds_rec.vendor_site_id,
                p_invoice_tds_authority_num         =>      for_pre_invoice_tds_rec.invoice_num||'/'|| 'CM/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
                p_invoice_tds_authority_type        =>      'CREDIT',
                p_invoice_tds_authority_curr        =>      for_pre_invoice_tds_rec.invoice_currency_code,
                p_invoice_tds_authority_amt         =>      (-1)*insertion_amount * NVL(get_exchange_rate_base_inv_rec.exchange_rate,1),
                p_vendor_id                         =>      for_std_inv_rec_r.vendor_id,
                p_vendor_site_id                    =>      for_std_inv_rec_r.vendor_site_id,
                p_invoice_vendor_num                =>      'RTN/'||for_std_inv_rec_r.invoice_num|| '/' ||TO_CHAR(v_ja_ap_invoices_interface_no),
                p_invoice_vendor_type               =>      'STANDARD',
                p_invoice_vendor_curr               =>      for_std_inv_rec_r.invoice_currency_code,
                p_invoice_vendor_amt                =>      insertion_amount,
                p_parent_inv_payment_priority       =>      ln_prnt_pay_priority,
                p_parent_inv_exchange_rate          =>      ln_prnt_exchange_rate
        );

        Fnd_File.put_line(Fnd_File.LOG,'BEFORE submitting Payables OPEN INTERFACE Import concurrent request 2');
    result := Fnd_Request.set_mode(TRUE);

    lv_batch_name := jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id); --Ramananda for Bug#4584221

    req_id := Fnd_Request.submit_request
            (
            'SQLAP',
          'APXIIMPT',
          'Localization Payables OPEN INTERFACE Import',
          '',
          FALSE,
    /* Bug 4774647. Added by Lakshmi Gopalsami
              Passed operating unit also as this parameter has been
              added by base .
          */
          '',
          'INDIA TDS', /* --'TDS', --Ramanand for bug#4388958*/
          to_char(p_invoice_id),	/*Bug 4716884 */
          --'TDS'||TO_CHAR(TRUNC(SYSDATE)),
          --commented the above and added the below by Ramananda for Bug#4584221
          lv_batch_name,
          '',
          '',
          '',
          'Y',
          'N',
          'N',
          'N',
                  1000, -- commit interval parameter added by Aparajita for bug # 2738340 on 15/01/2003
          p_created_by,
          p_last_updated_by
          );

    END IF; --CASE 2

    /* FOR  App_Flag_Rec IN
       Fetch_App_Inv_Flag_Cur( for_vendor_id_prepay_rec.vendor_id,for_std_invoice_rec.vendor_site_id ) LOOP


      IF App_Flag_Rec.Approved_Invoice_Flag = 'Y' THEN
    */

    /* This has been commented by Aparajita as this variable v_invoice_num is no more used and
       this cursor was using currval for sequence  JAI_AP_TDS_INVOICE_NUM_S,bug 2364106

        OPEN  for_invoice_num(for_std_invoice_rec.invoice_num);
        FETCH for_invoice_num INTO v_invoice_num;
        CLOSE for_invoice_num;
    end comment by Aparajita on 15th May for bug 2364106 */

    -- above block commented by Aparajita on 29/07/2002 for bug # 2475416, and the block below added.
    v_Approved_Invoice_Flag := 'N';

    BEGIN

            SELECT NVL( Approved_Invoice_Flag, 'N' )
      INTO   v_Approved_Invoice_Flag
            FROM   JAI_CMN_VENDOR_SITES
        WHERE  Vendor_Id = for_std_inv_rec_r.vendor_id
        AND    Vendor_Site_Id = for_std_inv_rec_r.vendor_site_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        BEGIN

              SELECT NVL( Approved_Invoice_Flag, 'N' )
        INTO   v_Approved_Invoice_Flag
              FROM   JAI_CMN_VENDOR_SITES
          WHERE  Vendor_Id = for_std_inv_rec_r.vendor_id
          AND    Vendor_Site_Id = 0;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
        NULL;
      END;

    END;
    -- end addition by Aparajita on 29/07/2002 for bug # 2475416

        IF  v_Approved_Invoice_Flag = 'Y' THEN


        Fnd_File.put_line(Fnd_File.LOG,'BEFORE submitting Approval OF TDS AND CM concurrent request FOR invoice id ' || p_invoice_id);
        v_stage:=16;
        result := Fnd_Request.set_mode(TRUE);
        req1_id := Fnd_Request.submit_request
                (
          'JA',
          'JAINAPIN',
          'Approval OF TDS AND CM - Localization',
          SYSDATE,
                    FALSE,
          req_id,
          for_std_inv_rec_r.vendor_id,
                    for_std_inv_rec_r.vendor_site_id,
          p_invoice_id,
                    -- NULL, -- v_invoice_num, Changed to null by Aparajita on 15th may for bug 2364106.
          v_ap_tds_cm_num || ';' || v_ap_sup_inv_num, -- Changed by aparajita on 07/07/2002 for bug 2439034, earlier was null
          -- 'RTN'
          'APPLY'
            );

      END IF; -- App_Flag_Rec.Approved_Invoice_Flag

    -- END LOOP; -- App_Flag_Rec

  END IF;

  --END IF;

  -- exception handler added by Aparajita on 22nd March 2002.
  Fnd_File.put_line(Fnd_File.LOG,'SUCCESSFUL END OF PROCEDURE Ja_In_Ap_Prepay_Invoice_P');

EXCEPTION

  WHEN OTHERS THEN

    error_mesg := SQLERRM;
    lv_app_source := 'jai_ap_tds_old_pkg.process_prepayment_apply';  --rchandan for bug#4428980
    lv_add_err_msg := 'EXCEPTION captured BY WHEN OTHERS IN the PROCEDURE. stage - ' || TO_CHAR(v_stage);  --rchandan for bug#4428980

    INSERT INTO JAI_CMN_ERRORS_T (
    APPLICATION_SOURCE,
    error_message,
    additional_error_mesg,
    creation_date,
    created_by,
    -- added, Harshita for Bug 4866533
    last_updated_by, last_update_date
    ) VALUES (
    lv_app_source,  --rchandan for bug#4428980
    error_mesg,
    lv_add_err_msg,  --rchandan for bug#4428980
    SYSDATE,
    fnd_global.user_id, -- USER, -- Harshita for Bug 4866533
    -- added, Harshita for Bug 4866533
    fnd_global.user_id, sysdate
    );
  Fnd_File.put_line(Fnd_File.LOG,'EXCEPTION END OF PROCEDURE Ja_In_Ap_Prepay_Invoice_P');
  Fnd_File.put_line(Fnd_File.LOG,'Error message : ' || error_mesg);

END process_prepayment_apply;

PROCEDURE approve_invoice
(
errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_parent_request_id     IN      NUMBER,
p_vendor_id         IN      NUMBER,
p_vendor_site_id      IN      NUMBER,
p_invoice_id        IN      NUMBER,
p_invoice_num         IN      VARCHAR2 DEFAULT NULL,
p_inv_type          IN      VARCHAR2 DEFAULT NULL
)
IS
  v_request_id           NUMBER;
  v_set_of_books_id      NUMBER;
  v_approval_inv_flag    VARCHAR2(1);
  v_vendor_id            NUMBER;
  result                 BOOLEAN;
  req_status             BOOLEAN        := TRUE;
  req_id                 NUMBER;
  REQ1_ID        NUMBER;
  v_phase                VARCHAR2(100);
  v_status               VARCHAR2(100);
  v_dev_phase            VARCHAR2(100);
  v_dev_status           VARCHAR2(100);
  v_message              VARCHAR2(100);
  v_tds_inv_id           NUMBER;
  v_cm_inv_id            NUMBER;
  v_parent_request_id    NUMBER;
  v_rtn_inv              NUMBER;
  v_can_inv              NUMBER;
  v_tds_cm_inv_id        NUMBER;   --Added by Ajay Sharma
  v_std_inv_num          VARCHAR2(50);         --Added by Ajay Sharma

  CURSOR Fetch_Set_Of_Books_Id_Cur(inv_id NUMBER) IS
    SELECT Set_Of_Books_Id
    FROM   Ap_Invoices_All
    WHERE  Invoice_Id = inv_id;

  /*CURSOR Fetch_App_Inv_Flag_Cur IS
    SELECT NVL( Approved_Invoice_Flag, 'N' ) Approved_Invoice_Flag
    FROM   JAI_CMN_VENDOR_SITES
    WHERE  Vendor_Id = p_vendor_id
     AND   Vendor_Site_Id = p_vendor_site_id; */

  CURSOR Fetch_Inv_Num_Cur IS
    SELECT Tds_Invoice_Num, Dm_Invoice_Num, Tds_Tax_Id
    FROM   JAI_AP_TDS_INVOICES
    WHERE  Invoice_Id = p_invoice_id;

  CURSOR Fetch_Tds_Vendor_Dtls_Cur( v_tds_tax_id IN NUMBER ) IS
    SELECT Vendor_Id, Vendor_Site_Id
    FROM   JAI_CMN_TAXES_ALL
    WHERE  Tax_Id = v_tds_tax_id;

  CURSOR Fetch_Inv_Id_Cur( v_inv_num IN VARCHAR2, v_vendor_id IN NUMBER, v_vendor_site_id IN NUMBER  ) IS
    SELECT Invoice_Id
    FROM   Ap_Invoices_All
    WHERE  Invoice_Num = v_inv_num
     AND   Vendor_Id = v_vendor_id
     AND   Vendor_Site_Id = v_vendor_site_id;

  CURSOR for_cancelled_invoices(inv_id NUMBER) IS
     SELECT dm_invoice_num
     FROM   JAI_AP_TDS_INVOICES
     WHERE  invoice_id = inv_id;

  CURSOR cancelled_info(inv_id NUMBER) IS
   SELECT cancelled_date
   FROM   ap_invoices_all
   WHERE  invoice_id = inv_id;
  ----------------------------------------- PREPAY -------------------------------------
  CURSOR check_dist_type(inv NUMBER,cp_line_type_lookup_code ap_invoice_distributions_all.line_type_lookup_code%type) IS
  SELECT invoice_id, invoice_distribution_id, amount, org_id,prepay_distribution_id,line_type_lookup_code,
         last_updated_by,last_update_date,created_by,creation_date
  FROM   ap_invoice_distributions_all
  WHERE  invoice_id = inv
  and   distribution_line_number in (select max(distribution_line_number)
                                     from   ap_invoice_distributions_all
                                     where  invoice_id = inv
                                     and    line_type_lookup_code =cp_line_type_lookup_code )  ;
-----------------------------------------------------------------------------------------------
/*  added by Ajay Sharma on 15-apr-01 */

   CURSOR Fetch_Std_Inv_Num_Cur IS
      SELECT invoice_num
      FROM   ap_invoices_all
      WHERE  invoice_id = p_invoice_id;

   CURSOR Fetch_Like_Inv_Id_Cur( v_inv_num IN VARCHAR2, v_vendor_id IN NUMBER, v_vendor_site_id IN NUMBER  ) IS
    SELECT Invoice_Id
    FROM   Ap_Invoices_All  inv
    WHERE  Invoice_Num  LIKE v_inv_num
     AND   Vendor_Id = v_vendor_id
     AND   Vendor_Site_Id = v_vendor_site_id
   --following added by Aparajita to avoid approval of already approved invoice on 07/07/2002.
   AND    NOT EXISTS (SELECT '1'
                      FROM   ap_invoice_distributions_all
            WHERE invoice_id = inv.invoice_id
            AND   NVL(match_status_flag, 'T') = 'A')
            ;

/*  end of code by Ajay Sharma on 15-apr-01 */
---------------------------------------------------------------------------------------------
check_dist_type_r     check_dist_type%ROWTYPE;
for_cancelled_invoices_rec          for_cancelled_invoices%ROWTYPE;
v_cancelled_date                    DATE;

  /* Start : Added by Aparajita Das for bug # 2439034 */

  -- for unapplying prepayment.
  v_uap_tds_inv_num         ap_invoices_all.invoice_num%TYPE;
  v_uap_sup_cm_num          ap_invoices_all.invoice_num%TYPE;
  v_uap_inv_id            NUMBER;
  v_uap_vendor_id         NUMBER;

  -- for applying prepayment.
  v_ap_tds_cm_num         ap_invoices_all.invoice_num%TYPE;
  v_ap_sup_inv_num          ap_invoices_all.invoice_num%TYPE;
  v_ap_inv_id           NUMBER;
  v_ap_vendor_id          NUMBER;

  -- Common cursor for both applying and unapplying prepayment
  CURSOR c_get_invoice(p_inv_num VARCHAR2) IS
  SELECT invoice_id, vendor_id
  FROM   ap_invoices_all
  WHERE  invoice_num = p_inv_num;

  /* End : Added by Aparajita Das for bug # 2439034 */

 lv_object_name VARCHAR2(61); -- := '<Package_name>.<procedure_name>'; /* Added by Ramananda for bug#4407165 */

BEGIN

/*------------------------------------------------------------------------------------------
 FILENAME: jai_ap_tds_old_pkg.approve_invoice_p.sql
 CHANGE HISTORY:
S.No      Date          Author and Details

1       15-Apr-01     Ajay Sharma
                      Code modified to approve the credit memo on TDS AUTHORITY
                        and RTN invoice for the vendor,if the pre-approve flag is
                        checked at the vendor site

2.      07/07/2002      Aparajita Das for bug # 2439034
                        Added the section (elsif) for APPLY and UNAPPLY.

            APPLY caters to the situation where a prepayment is applied to the standard invoice. In this
            case the calling program (jai_ap_tds_old_pkg.process_prepayment_apply), that is the concurrent for apply sends the
            tds credit note and return invoice for vendor concatenated in the p_invoice_num parameter
            separated by a ';'.

            UNAPPLY  caters to the situation where an applied invoice is unapplied.
            In this case the calling program (jai_ap_tds_old_pkg.process_prepayment_unapply, that is the concurrent for
            unapply sends the concatenated invoice_numbers in the p_invoice_num parameter.
            The invoices numbers to be approved are always two, the tds invoice and the credit memo. These
            two invoices are separated by a ';'.

3.      27/08/2002       Aparajita for bug # 2518531
            Added where clause in cursor Fetch_Like_Inv_Id_Cur to avoid reapproval of approved invoice.
                        added code for this concurrent to return with warning when the parent request ap payable
            open interface fails.

            changed the Fnd_concurrent.get_request_status to Fnd_concurrent.wait_for_request to introduce
            wait period between polling for status of parent request.

4.       25/03/2005     Aparajita Forr TDS Clean up Bug #4088186. Version#115.2
                        Removed the dependency on table JA_IN_AP_INV_PRE_TEMP.


----------------------------------------------------------------------------------------------------------------------*/

  lv_object_name  := 'jai_ap_tds_old_pkg.approve_invoice'; /* Added by Ramananda for bug#4407165 */

  v_parent_request_id := p_parent_request_id;
  OPEN  Fetch_Set_Of_Books_Id_Cur(p_invoice_id);
  FETCH Fetch_Set_Of_Books_Id_Cur INTO v_set_of_books_id;
  CLOSE Fetch_Set_Of_Books_Id_Cur;

  -- LOOP
    -- req_status := Fnd_concurrent.get_request_status( v_parent_request_id,
  -- above line changed to the line below by Aparajita on  27/8/2002 for bug # 2518531.
    req_status := Fnd_concurrent.wait_for_request(  v_parent_request_id,
                                                  60, -- default value - sleep time in secs
                            0, -- default value - max wait in secs
                                                    v_phase,
                                                    v_status,
                                                    v_dev_phase,
                                                    v_dev_status,
                                                    v_message );

  /*   commented by Aparajita on  27/8/2002 for bug # 2518531.
    IF v_dev_phase = 'COMPLETE' THEN
       EXIT;
    END IF;

  END LOOP;
  */

  -- start added by Aparajita on  27/8/2002 for bug # 2518531.
  IF v_dev_phase = 'COMPLETE' THEN

      IF v_dev_status <> 'NORMAL' THEN
      Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as parent request not completed with normal status');
    Fnd_File.put_line(Fnd_File.LOG, 'Message from parent request :' || v_message);
    retcode := 1;
    errbuf := 'Exiting with warningr as parent request not completed with normal status';
    RETURN;
    END IF;

  END IF;

  -- end  added by Aparajita on  27/8/2002 for bug # 2518531.


  IF v_dev_phase = 'COMPLETE' /*OR v_dev_phase = 'INACTIVE'*/  THEN

    IF v_dev_status = 'NORMAL' THEN

    OPEN check_dist_type(p_invoice_id, 'PREPAY');
    FETCH check_dist_type INTO check_dist_type_r;

    IF check_dist_type%FOUND THEN
     result := Fnd_Request.set_mode(TRUE);
     req_id := Fnd_Request.submit_request('JA','JAINPREP','To Insert Prepayment Distributions',
                                             '',FALSE,check_dist_type_r.invoice_id,check_dist_type_r.invoice_distribution_id,
                                         ABS(check_dist_type_r.amount),check_dist_type_r.last_updated_by,check_dist_type_r.last_update_date,
                                         check_dist_type_r.created_by,check_dist_type_r.creation_date,check_dist_type_r.org_id,
                 check_dist_type_r.prepay_distribution_id,'U','ATTRIBUTE1');
                                                           -- Parameter ATTRIBUTE1 added by Ajay Sharma
      END IF ;

      CLOSE check_dist_type;

    -- DELETE JA_IN_AP_INV_PRE_TEMP ;

  END IF; -- v_dev_status = 'NORMAL'

  END IF; -- v_dev_phase = 'COMPLETE'

  /*  IF p_invoice_num IS NOT NULL AND p_inv_type = 'RTN' THEN                     --10
            OPEN  Fetch_Inv_Id_Cur( p_invoice_num, p_vendor_id, p_vendor_site_id );
            FETCH Fetch_Inv_Id_Cur INTO v_rtn_inv;
            CLOSE Fetch_Inv_Id_Cur;
            result := Fnd_request.set_mode(TRUE);
            v_request_id := FND_REQUEST.SUBMIT_REQUEST ( 'SQLAP',
                                                         'APPRVL',
                                                         'Payables Approval Localization -- RTN Invoice',
                                                         SYSDATE,
                                                         FALSE,
                                                         'All',
                                                         UID,
                                                         '',
                                                         '',
                                                         v_vendor_id,
                                                         '',
                                                         TO_CHAR( v_rtn_inv ),
                                                         UID,
                                                         TO_CHAR( v_set_of_books_id ),
                                                         'N' );
  ELSE */                                                                          --10

  IF p_inv_type = 'CAN' THEN                                                  --20

    FOR i IN for_cancelled_invoices(p_invoice_id) LOOP

      OPEN  Fetch_Inv_Id_Cur('CAN/'||SUBSTR(i.dm_invoice_num, 1, 47), p_vendor_id, p_vendor_site_id);
      FETCH Fetch_Inv_Id_Cur INTO v_can_inv;
      CLOSE Fetch_Inv_Id_Cur;

      result := Fnd_Request.set_mode(TRUE);
      /* Bug 5378544. Added by Lakshmi Gopalsami
       * Included org_id and commit size.
       */
      v_request_id := Fnd_Request.SUBMIT_REQUEST ( 'SQLAP',
                                                   'APPRVL',
                                                   'TDS Invoice (Cancellation)- Localization ',
                                                   SYSDATE,
						   FALSE,
                                                   '', -- org_id
						   'All',
						   UID,
						   '',
						   '',
						   v_vendor_id,
						   '',
						   TO_CHAR( v_can_inv ),
						   UID,
						   TO_CHAR( v_set_of_books_id ),
						   'N',
						   '');-- commit size
    END LOOP;


  -- Start addition by Aparajita for bug # 2439034 on 07/07/2002.
  ELSIF p_inv_type = 'UNAPPLY' THEN

    -- unapply prepayment --> Return invoice for tax authority and credit note for supplier

    v_uap_tds_inv_num := SUBSTR(p_invoice_num, 1, INSTR(p_invoice_num, ';') -1);
  v_uap_sup_cm_num :=  SUBSTR(p_invoice_num, INSTR(p_invoice_num, ';') + 1);

  IF v_uap_tds_inv_num IS NOT NULL THEN

    v_uap_inv_id := NULL;
    v_uap_vendor_id := NULL;

    OPEN c_get_invoice(v_uap_tds_inv_num);
    FETCH c_get_invoice INTO v_uap_inv_id, v_uap_vendor_id;
    CLOSE c_get_invoice;

    IF  v_uap_inv_id IS NOT NULL THEN
        result := Fnd_Request.set_mode(TRUE);
	/* Bug 5378544. Added by Lakshmi Gopalsami
         * Included org_id and commit size.
         */
        v_request_id := Fnd_Request.SUBMIT_REQUEST ( 'SQLAP',
                                                     'APPRVL',
                                                     'Return TDS Invoice(Unapply Prepayment)- Localization ',
                                                     SYSDATE,
                                                     FALSE,
						     '', -- org id
                                                     'All',
                                                     UID,
                                                       '',
                                                     '',
                                                     v_uap_vendor_id,
                                                     '',
                                                     TO_CHAR( v_uap_inv_id ),
                                                     UID,
                                                     TO_CHAR( v_set_of_books_id ),
                                                     'N',
						     '' );-- commit size

      END IF;

  END IF; -- tds inv num not null

  IF v_uap_sup_cm_num IS NOT NULL THEN

    v_uap_inv_id := NULL;
    v_uap_vendor_id := NULL;

    OPEN c_get_invoice(v_uap_sup_cm_num);
    FETCH c_get_invoice INTO v_uap_inv_id, v_uap_vendor_id;
    CLOSE c_get_invoice;

    IF  v_uap_inv_id IS NOT NULL THEN
        result := Fnd_Request.set_mode(TRUE);
	/* Bug 5378544. Added by Lakshmi Gopalsami
         * Included org_id and commit size.
         */
        v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                'SQLAP',
			'APPRVL',
			'Credit Note Supplier(Unapply Prepayment)- Localization ',
			SYSDATE,
			FALSE,
			'', -- org id
			'All',
			UID,
			'',
			'',
			v_uap_vendor_id,
			'',
			TO_CHAR( v_uap_inv_id ),
			UID,
			TO_CHAR( v_set_of_books_id ),
			'N',
			'');-- commit size

      END IF;

  END IF; -- sup cm num not null

    -- end of unapply

  ELSIF p_inv_type = 'APPLY' THEN

    -- apply prepayment --> credit note for tax authority and retrun invoice for supplier

    v_ap_tds_cm_num := SUBSTR(p_invoice_num, 1, INSTR(p_invoice_num, ';') -1);
  v_ap_sup_inv_num :=  SUBSTR(p_invoice_num, INSTR(p_invoice_num, ';') + 1);

  IF v_ap_tds_cm_num IS NOT NULL THEN

    v_ap_inv_id := NULL;
    v_ap_vendor_id := NULL;

    OPEN c_get_invoice(v_ap_tds_cm_num);
    FETCH c_get_invoice INTO v_ap_inv_id, v_ap_vendor_id;
    CLOSE c_get_invoice;

    IF  v_ap_inv_id IS NOT NULL THEN
        result := Fnd_Request.set_mode(TRUE);
	/* Bug 5378544. Added by Lakshmi Gopalsami
         * Included org_id and commit size.
	 */
        v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                  'SQLAP',
			  'APPRVL',
			  'TDS Credit Note(Apply Prepayment)- Localization ',
			  SYSDATE,
			  FALSE,
			  '', -- org id
			  'All',
			  UID,
			  '',
			  '',
			  v_ap_vendor_id,
			  '',
			  TO_CHAR( v_ap_inv_id ),
			  UID,
			  TO_CHAR( v_set_of_books_id ),
			  'N',
			  ''); -- commit size

      END IF;

  END IF; -- tds inv num not null

  IF v_ap_sup_inv_num IS NOT NULL THEN

    v_ap_inv_id := NULL;
    v_ap_vendor_id := NULL;

    OPEN c_get_invoice(v_ap_sup_inv_num);
    FETCH c_get_invoice INTO v_ap_inv_id, v_ap_vendor_id;
    CLOSE c_get_invoice;

    IF  v_ap_inv_id IS NOT NULL THEN
        result := Fnd_Request.set_mode(TRUE);
	/* Bug 5378544. Added by Lakshmi Gopalsami
         * Included org_id and commit size.
	 */
        v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                 'SQLAP',
			 'APPRVL',
			 'Return Invoice Supplier(Apply Prepayment)- Localization ',
			 SYSDATE,
			 FALSE,
			 '', -- org id
			 'All',
			 UID,
			 '',
			 '',
			 v_ap_vendor_id,
			 '',
			 TO_CHAR( v_ap_inv_id ),
			 UID,
			 TO_CHAR( v_set_of_books_id ),
			 'N',
			 ''); -- commit size

      END IF;

  END IF; -- sup cm num not null

    -- end of apply

  -- End addition by Aparajita for bug # 2439034 on 07/07/2002.

  ELSE                                                                        --20

    OPEN  cancelled_info(p_invoice_id);
    FETCH cancelled_info INTO v_cancelled_date;
    CLOSE cancelled_info;

    IF v_cancelled_date IS NOT NULL THEN
      RETURN;
    END IF;

    FOR Inv_Num_Rec IN Fetch_Inv_Num_Cur
  LOOP

      FOR  Vendor_Rec IN Fetch_Tds_Vendor_Dtls_Cur( Inv_Num_Rec.Tds_Tax_Id )
    LOOP

        OPEN  Fetch_Inv_Id_Cur( Inv_Num_Rec.Tds_Invoice_Num, Vendor_Rec.Vendor_Id, Vendor_Rec.Vendor_Site_Id );
        FETCH Fetch_Inv_Id_Cur INTO v_tds_inv_id;
        CLOSE Fetch_Inv_Id_Cur;

        v_vendor_id := Vendor_Rec.Vendor_Id;
        --END LOOP;

        OPEN  Fetch_Inv_Id_Cur( Inv_Num_Rec.Dm_Invoice_Num, p_vendor_id, p_vendor_site_id );
        FETCH Fetch_Inv_Id_Cur INTO v_cm_inv_id;
        CLOSE Fetch_Inv_Id_Cur;

        --END LOOP;

        result := Fnd_Request.set_mode(TRUE);
        /* Bug 5378544. Added by Lakshmi Gopalsami
	 * Included org_id and commit size.
	 */
        v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                    'SQLAP',
			    'APPRVL',
			    'TDS Invoice - Localization ',
			    SYSDATE,
			    FALSE,
			    '', -- org_id
			    'All',
			    UID,
			    '',
			    '',
			    v_vendor_id,
			    '',
			    TO_CHAR( v_tds_inv_id ),
			    UID,
			    TO_CHAR( v_set_of_books_id ),
			    'N',
			    ''); -- commit size

        result := Fnd_Request.set_mode(TRUE);
	/* Bug 5378544. Added by Lakshmi Gopalsami
         * Included org_id and commit size.
	 */
        v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                      'SQLAP',
			      'APPRVL',
			      'Credit Memo - Localization',
			      SYSDATE,
			      FALSE,
			      '', -- org_id
			      'All',
			      UID,
			      '',
			      '',
			      p_vendor_id,
			      '',
			      TO_CHAR( v_cm_inv_id ),
			      UID,
			      TO_CHAR( v_set_of_books_id ),
			      'N',
			      ''); -- commit size
        ------------------------------------------------------------------------------------------------
    /*  added by Ajay Sharma on 15-apr-01
          to approve RTN invoice for Vendor  and CM for TDS authority*/

        OPEN  Fetch_Std_Inv_Num_Cur;
        FETCH Fetch_Std_Inv_Num_Cur  INTO  v_std_inv_num;
        CLOSE Fetch_Std_Inv_Num_Cur;

        OPEN  Fetch_Like_Inv_Id_Cur( v_std_inv_num||'TDS%CM%', Vendor_Rec.Vendor_Id, Vendor_Rec.Vendor_Site_Id );
        FETCH Fetch_Like_Inv_Id_Cur  INTO  v_tds_cm_inv_id;
        CLOSE Fetch_Like_Inv_Id_Cur;

        v_vendor_id := Vendor_Rec.Vendor_id;

        IF v_tds_cm_inv_id  IS NOT NULL  THEN
          result := Fnd_Request.set_mode(TRUE);
	  /* Bug 5378544. Added by Lakshmi Gopalsami
	   * Included org_id and commit size.
	   */
          v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                         'SQLAP',
				 'APPRVL',
				 'Credit Memo For Excess TDS - Localization' ,
				 SYSDATE,
				 FALSE,
				 '', -- org_id
				 'All',
				 UID,
				 '',
				 '',
				 v_vendor_id,
				 '',
				 TO_CHAR( v_tds_cm_inv_id ),
				 UID,
				 TO_CHAR( v_set_of_books_id ),
				 'N',
				 ''); -- commit size
        END IF;

        OPEN  Fetch_Like_Inv_Id_Cur('RTN/'||v_std_inv_num||'%',p_vendor_id,p_vendor_site_id);
        FETCH Fetch_Like_Inv_Id_Cur  INTO  v_rtn_inv;
        CLOSE Fetch_Like_Inv_Id_Cur;

        IF  v_rtn_inv   IS NOT NULL  THEN
          result := Fnd_Request.set_mode(TRUE);
	  /* Bug 5378544. Added by Lakshmi Gopalsami
	   * Included org_id and commit size.
	   */
          v_request_id := Fnd_Request.SUBMIT_REQUEST (
	                    'SQLAP',
			    'APPRVL',
			    'RTN Invoice -- Localization ',
			    SYSDATE,
			    FALSE,
			    '', -- org_id
			    'All',
			    UID,
			    '',
			    '',
			    p_vendor_id,
			    '',
			    TO_CHAR( v_rtn_inv ),
			    UID,
			    TO_CHAR( v_set_of_books_id ),
			    'N',
			    ''); -- commit size
        END IF;

        /* End of addition of code  15-apr-01*/
        --------------------------------------------------------------------------------------------------
      END LOOP;

    END LOOP;

  END IF;                                                              --20
                                       --10
/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    errbuf  := null;
    retcode := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END approve_invoice;

FUNCTION get_invoice_status (l_invoice_id IN NUMBER,
                                                            l_invoice_amount IN NUMBER,
                                                            l_payment_status_flag IN VARCHAR2,
                                                            l_invoice_type_lookup_code IN VARCHAR2,
                                                            I_org_id number )
         RETURN VARCHAR2
     IS
         invoice_approval_status         VARCHAR2(25);
         invoice_approval_flag           VARCHAR2(1);
         distribution_approval_flag      VARCHAR2(1);
         encumbrance_flag                VARCHAR2(1);
         invoice_holds                   NUMBER;
         cancelled_date                  DATE;
         ---------------------------------------------------------------------
         -- Declare cursor to establish the invoice-level approval flag
         --
         -- The first select simply looks at the match status flag for the
         -- distributions.  The rest is to cover one specific case when some
         -- of the distributions are tested (T or A) and some are untested
         -- (NULL).  The status should be needs reapproval (N).
         --

-----------------------------------------------------------------------------------
         CURSOR approval_cursor IS
         SELECT match_status_flag
         FROM   ap_invoice_distributions_all
         WHERE  invoice_id = l_invoice_id
         UNION
         SELECT 'N'
         FROM   ap_invoice_distributions_all
         WHERE  invoice_id = l_invoice_id
         AND    match_status_flag IS NULL
         AND EXISTS
                (SELECT 'There are both untested and tested lines'
                 FROM   ap_invoice_distributions_all
                 WHERE  invoice_id = l_invoice_id
                 AND    match_status_flag IN ('T','A'));
     BEGIN

         ---------------------------------------------------------------------
         -- Get the encumbrance flag
         --
         SELECT NVL(purch_encumbrance_flag,'N')
         INTO   encumbrance_flag
         FROM   financials_system_params_all


-----------------------------------------------------------------------------------------------------------------------
         WHERE org_id = I_org_id ;
         ---------------------------------------------------------------------
         -- Get the number of holds for the invoice
         --
         SELECT count(*)
         INTO   invoice_holds
         FROM   ap_holds
         WHERE  invoice_id = l_invoice_id
         AND    release_lookup_code is NULL;
         ---------------------------------------------------------------------
         -- If invoice is cancelled, return 'CANCELLED'.
         --
         SELECT ai.cancelled_date
         INTO   cancelled_date
         FROM   ap_invoices_all ai
         WHERE  ai.invoice_id = l_invoice_id;
         IF (cancelled_date IS NOT NULL) THEN
             RETURN('CANCELLED');
         END IF;
         ---------------------------------------------------------------------
         -- Establish the invoice-level approval flag


-----------------------------------------------------------------------------------------------------------------------
         --
         -- Use the following ordering sequence to determine the invoice-level
         -- approval flag:
         --                     'N' - Needs Reapproval
         --                     'T' - Tested
         --                     'A' - Approved
         --                     ''  - Never Approved
         --
         -- Initialize invoice-level approval flag
         --
         invoice_approval_flag := '';
         OPEN approval_cursor;
         LOOP
             FETCH approval_cursor INTO distribution_approval_flag;
             EXIT WHEN approval_cursor%NOTFOUND;
             IF (distribution_approval_flag = 'N') THEN
                 invoice_approval_flag := 'N';
             ELSIF (distribution_approval_flag = 'T' AND
                    (invoice_approval_flag <> 'N'
                     or invoice_approval_flag is null)) THEN
                 invoice_approval_flag := 'T';


-----------------------------------------------------------------------------------------------------------------------
             ELSIF (distribution_approval_flag = 'A' AND
                    (invoice_approval_flag NOT IN ('N','T')
                     or invoice_approval_flag is null)) THEN
                 invoice_approval_flag := 'A';
             END IF;
         END LOOP;
         CLOSE approval_cursor;
         ---------------------------------------------------------------------
         -- Derive the translated approval status from the approval flag
         --
         IF (encumbrance_flag = 'Y') THEN
             IF (invoice_approval_flag = 'A' AND invoice_holds = 0) THEN
                 invoice_approval_status := 'APPROVED';
             ELSIF ((nvl(invoice_approval_flag,'A') = 'A' AND invoice_holds > 0)
                     OR (invoice_approval_flag IN ('T','N'))) THEN
                 invoice_approval_status := 'NEEDS REAPPROVAL';
             ELSIF (invoice_approval_flag is null) THEN
                 invoice_approval_status := 'NEVER APPROVED';
             END IF;
         ELSIF (encumbrance_flag = 'N') THEN
             IF (invoice_approval_flag IN ('A','T') AND invoice_holds = 0) THEN


-----------------------------------------------------------------------------------------------------------------------
                 invoice_approval_status := 'APPROVED';
             ELSIF ((nvl(invoice_approval_flag,'A') IN ('A','T') AND
                     invoice_holds > 0) OR
                    (invoice_approval_flag = 'N')) THEN
                 invoice_approval_status := 'NEEDS REAPPROVAL';
             ELSIF (invoice_approval_flag is null) THEN
                 invoice_approval_status := 'NEVER APPROVED';
             ELSIF (invoice_approval_flag is null and invoice_holds > 0 ) THEN
                 invoice_approval_status := 'NEEDS REAPPROVAL';
             END IF;
         END IF;
         ---------------------------------------------------------------------
         -- If this a prepayment, find the appropriate prepayment status
         --
         if (l_invoice_type_lookup_code = 'PREPAYMENT') then
           if (invoice_approval_status = 'APPROVED') then
             if (l_payment_status_flag IN ('P','N')) then
               invoice_approval_status := 'UNPAID';
             else
               -- This prepayment is paid
               if (AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(l_invoice_id) = 0) then


-----------------------------------------------------------------------------------------------------------------------
                 invoice_approval_status := 'FULL';
               elsif (AP_INVOICES_UTILITY_PKG.get_prepayment_type(l_invoice_id) = 'PERMANENT') THEN
                 invoice_approval_status := 'PERMANENT';
               else
                 invoice_approval_status := 'AVAILABLE';
               end if;
             end if;
           elsif (invoice_approval_status = 'NEVER APPROVED') then
             -- This prepayment in unapproved
             invoice_approval_status := 'UNAPPROVED';
           end if;
         end if;
         RETURN(invoice_approval_status);
END get_invoice_status ;


END jai_ap_tds_old_pkg;

/
