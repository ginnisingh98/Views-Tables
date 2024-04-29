--------------------------------------------------------
--  DDL for Package Body FV_LOCKBOX_FC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_LOCKBOX_FC_PKG" AS
--$Header: FVDCLKBB.pls 120.7 2005/10/21 11:19:28 kbhatt noship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_LOCKBOX_FC_PKG.';


-- -----------------------------------------------------------------------
--                            Variable Declarations
-- -----------------------------------------------------------------------
v_test number;
 v_transmission_id       ar_transmissions_all.transmission_id%TYPE;
 v_batch_id              ar_batches.batch_id%TYPE;
 v_org_id                ar_batches.org_id%TYPE;
 v_invoice_id            ra_customer_trx.customer_trx_id%TYPE;
 v_temp_id               fv_lockbox_ipa_temp.temp_id%TYPE;
 v_debit_memo_id         ra_customer_trx.customer_trx_id%TYPE;
 v_amount                ar_payment_schedules.amount_due_remaining%TYPE;
 v_priority              fv_finance_charge_controls.priority%TYPE;
 v_payment_schedule_id ar_payment_schedules.payment_schedule_id%TYPE;
 v_appl_inv_id           ra_customer_trx.customer_trx_id%TYPE;
 v_appl_inv_ps_id        ar_payment_schedules.payment_schedule_id%TYPE;
 v_sold_to_customer      ar_interim_cash_rcpt_lines_all.sold_to_customer%TYPE;
 v_transaction_code      ar_interim_cash_receipts.ussgl_transaction_code%TYPE;
 v_appl_inv_amt          number;
 v_appl_amt_remain       number;
 v_appl_dm_id            fv_lockbox_ipa_temp.debit_memo_id%TYPE;
 v_dm_amt                fv_lockbox_ipa_temp.amount%TYPE;
 v_prioirty              fv_lockbox_ipa_temp.priority%TYPE;
 v_dm_pay_sch_id         fv_lockbox_ipa_temp.payment_schedule_id%TYPE;
 v_origin                varchar2(1);
 v_cash_receipt_id       number;
 v_cash_receipt_line_id_ctr number;
 v_cash_receipt_line_id  number;
 v_retcode               varchar2(1);
 v_errbuf                varchar2(1000);

 -- record creation variables
 v_created_by            number(15)      := fnd_global.user_id;
 v_creation_date         date            := sysdate;
 v_last_updated_by       number(15)      := fnd_global.user_id;
 v_last_update_date      date            := sysdate;


-- -----------------------------------------------------------------------
--                            Cursor Declarations
-- -----------------------------------------------------------------------

 cursor c_batches(cv_transmission_id ar_batches.transmission_id%TYPE) is
        select *
          from ar_batches
         where transmission_id = cv_transmission_id;

 cursor c_invoices(cv_batch_id ar_batches.batch_id%TYPE,
                   cv_org_id ar_batches.org_id%TYPE) is
/*
        select distinct(decode(a.customer_trx_id,null,b.customer_trx_id,
                                             a.customer_trx_id)) customer_trx_id
          from ar_interim_cash_receipts a,
               ar_interim_cash_rcpt_lines_all b
         where a.batch_id = cv_batch_id
           and a.cash_receipt_id = b.cash_receipt_id (+)
           and(a.customer_trx_id is not null or b.customer_trx_id is not null);
*/
        select distinct(customer_trx_id) customer_trx_id
          from ar_interim_cash_receipts
         where batch_id = cv_batch_id
           and customer_trx_id is not null
        union
        select distinct(customer_trx_id) customer_trx_id
          from ar_interim_cash_rcpt_lines_all
         where batch_id =  cv_batch_id
           and org_id = cv_org_id
           and customer_trx_id is not null;

  cursor c_debit_memos(cv_invoice_id ra_customer_trx.customer_trx_id%TYPE) IS
        Select aps.customer_trx_id,
               aps.amount_due_remaining,
               fcc.priority,
               aps.payment_schedule_id
          from ra_customer_trx      rct,
               ar_payment_schedules aps,
               fv_finance_charge_controls fcc
          where rct.related_customer_trx_id = cv_invoice_id
          and   aps.customer_trx_id = rct.customer_trx_id
          and   rct.interface_header_attribute3    = fcc.charge_type
          and   rct.set_of_books_id    = fcc.set_of_books_id
          and   aps.amount_due_remaining > 0
          order by fcc.priority ;

   cursor c_receipt_dms(cv_batch_id ar_batches.batch_id%TYPE,
                        cv_org_id   ar_interim_cash_receipts.org_id%TYPE) is
          select sum(amount) amount,
                aicr.customer_trx_id,
                aicr.payment_schedule_id
          from ar_interim_cash_receipts aicr,
               ra_customer_trx rct,
               fv_finance_charge_controls fcc
          where aicr.batch_id = cv_batch_id
          and aicr.customer_trx_id is not null
          and aicr.customer_trx_id = rct.customer_trx_id
          and rct.interface_header_attribute3 = fcc.charge_type
          and rct.set_of_books_id             = fcc.set_of_books_id
          group by aicr.customer_trx_id, aicr.payment_schedule_id
          union
          select sum(payment_amount) amount,
                 aicrl.customer_trx_id,
                 aicrl.payment_schedule_id
          from ar_interim_cash_rcpt_lines_all aicrl,
               ra_customer_trx rct,
               fv_finance_charge_controls fcc
          where aicrl.batch_id = cv_batch_id
          and aicrl.customer_trx_id is not null
          and aicrl.customer_trx_id = rct.customer_trx_id
          and rct.interface_header_attribute3 = fcc.charge_type
          and rct.set_of_books_id             = fcc.set_of_books_id
          and aicrl.org_id = cv_org_id
          group by aicrl.customer_trx_id, aicrl.payment_schedule_id;


   cursor c_receipt_details(cv_batch_id ar_batches.batch_id%TYPE,
                        cv_org_id   ar_interim_cash_receipts.org_id%TYPE) is
        select customer_trx_id, aicr.amount amount, 'R' origin,
               cash_receipt_id, 0 cash_receipt_line_id, payment_schedule_id,
               0 sold_to_customer, ussgl_transaction_code
          from ar_interim_cash_receipts aicr
         where batch_id = cv_batch_id
           and customer_trx_id is not null
           and exists (select 'x' from fv_lockbox_ipa_temp f
                                 where f.invoice_id = aicr.customer_trx_id
                                   and f.batch_id = aicr.batch_id)
        union
        select customer_trx_id, aicrl.payment_amount amount, 'L' origin,
               cash_receipt_id, cash_receipt_line_id, payment_schedule_id,
               sold_to_customer, ussgl_transaction_code
          from ar_interim_cash_rcpt_lines_all aicrl
         where batch_id =  cv_batch_id
           and org_id = cv_org_id
           and customer_trx_id is not null
           and exists (select 'x' from fv_lockbox_ipa_temp f
                                 where f.invoice_id = aicrl.customer_trx_id
                                   and f.batch_id = aicrl.batch_id);

    cursor c_finchrg_total(cv_trans_id fv_lockbox_ipa_temp.transmission_id%TYPE,
                           cv_batch_id fv_lockbox_ipa_temp.batch_id%TYPE,
                           cv_invoice_id fv_lockbox_ipa_temp.invoice_id%TYPE) is
         select debit_memo_id, amount, priority, payment_schedule_id
           from fv_lockbox_ipa_temp
          where transmission_id = cv_trans_id
            and batch_id = cv_batch_id
            and invoice_id = cv_invoice_id
         order by priority;
-- --------------------------------------------------------------------------
--                             PROCEDURE Main
-- --------------------------------------------------------------------------

 PROCEDURE main(x_errbuf            OUT NOCOPY varchar2,
                x_retcode           OUT NOCOPY varchar2,
                x_transmission_id IN NUMBER) AS
  l_module_name VARCHAR2(200) := g_module_name || 'main';
 BEGIN

   v_transmission_id := x_transmission_id;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'STARTING THE MAIN PROCESS. PROCESSING TRANSMISSION '||
                           'ID '||to_char(v_transmission_id));
   END IF;

    -- clear records out of fv_lockbox_ipa_temp for current transmission
   delete from fv_lockbox_ipa_temp
    where transmission_id = v_transmission_id;

   -- finding all batches within the transmission.
   FOR c_batches_rec IN c_batches(v_transmission_id) LOOP

     v_batch_id := c_batches_rec.batch_id;
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESSING BATCH_ID = '||TO_CHAR(V_BATCH_ID));
     END IF;

     v_org_id   := c_batches_rec.org_id;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FINDING ALL RECEIPTS THAT ARE APPLIED TO INVOICES');
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'POPULATING FV_LOCKBOX_IPA_TEMP W/TOTALS OF DEBIT MEMOS');
     END IF;
     -- finding all the receipts applied to invoices within the batch
     FOR c_invoices_rec IN c_invoices(v_batch_id,v_org_id) LOOP

         v_invoice_id := c_invoices_rec.customer_trx_id;

         --finding all debit memos and total for each invoice
         FOR c_debit_memo_rec IN c_debit_memos(v_invoice_id) LOOP

             v_debit_memo_id := c_debit_memo_rec.customer_trx_id;
             v_amount := c_debit_memo_rec.amount_due_remaining;
             v_priority := c_debit_memo_rec.priority;
             v_payment_schedule_id := c_debit_memo_rec.payment_schedule_id;

             BEGIN
               SELECT fv_lockbox_ipa_temp_s.nextval
                 INTO v_temp_id
                 FROM dual;

             EXCEPTION
               WHEN others THEN
                 v_retcode := '2';
                 v_errbuf  := 'fv_lockbox_ipa_temp_s '||sqlerrm;
                 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',v_errbuf);
                 ROLLBACK;
                 RAISE;
             END;

             -- setting up debit memo temp data
             insert into fv_lockbox_ipa_temp(temp_id,
			invoice_id,
			debit_memo_id,
			amount,
			priority,
			batch_id,
			payment_schedule_id,
                        transmission_id)
                values(v_temp_id,
                       v_invoice_id,
                       v_debit_memo_id,
                       nvl(v_amount,0),
                       v_priority,
		       v_batch_id,
                       v_payment_schedule_id,
                       v_transmission_id);

         END LOOP;  -- c_debit_memos

     END LOOP;  -- c_invoices

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FINDING RECEIPT WITH APPLICATION TO DEBIT MEMOS');
     END IF;

     -- find all finance charge debit memos within batch
     FOR c_receipt_dms_rec IN c_receipt_dms(v_batch_id, v_org_id) LOOP

        -- update the total amount available to apply to receipts for
        -- any debit memos in the batch.  This is being done by finding
	-- all finance charge debit memo's in the batch and reducing the
        -- the total amount of the fc dm available to apply.

        update fv_lockbox_ipa_temp
           set amount = amount - nvl(c_receipt_dms_rec.amount,0)
         where debit_memo_id = c_receipt_dms_rec.customer_trx_id
           and batch_id = v_batch_id
           and transmission_id = v_transmission_id
	   and payment_schedule_id = c_receipt_dms_rec.payment_schedule_id;

     END LOOP;  -- c_receipts_dm

     -- process each receipt application to find related finance charge debit
     -- memos to pay off.

     process_receipt_applications;

   END LOOP;  -- c_batches

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'***COMPLETED PROCESS SUCCESFULLY***');
   END IF;

   x_retcode := '0';
 EXCEPTION
   when others then
    IF v_errbuf is null THEN
       x_errbuf := 'Main '||sqlerrm;
       x_retcode := '2';
    ELSE
       x_retcode := v_retcode;
       x_errbuf  := v_errbuf;
    END If;

    IF c_batches%ISOPEN THEN
       close c_batches;
    END IF;

    IF c_invoices%ISOPEN THEN
       close c_invoices;
    END IF;

    IF c_debit_memos%ISOPEN THEN
       close c_debit_memos;
    END IF;

    IF c_receipt_dms%ISOPEN THEN
       close c_debit_memos;
    END IF;

    IF c_receipt_details%ISOPEN THEN
       close c_receipt_details;
    END IF;

    IF c_finchrg_total%ISOPEN THEN
       close c_finchrg_total;
    END IF;

    ROLLBACK;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',x_errbuf);


 END main;

-- ------------------------------------------------------------------------
--             PROCEDURE process_receipt_applications
-- ------------------------------------------------------------------------
--  This process determines for each receipt applied to an invoice, if
--  there are any finance charge debit memos to paid off first.  If there
--  are they will be received against prior to the prinicipal invoice if
--  there is monies left after paying off all outstanding finance charge
--  debit memos.
-- ------------------------------------------------------------------------
 PROCEDURE process_receipt_applications is
  l_module_name VARCHAR2(200) := g_module_name || 'process_receipt_applications';

 BEGIN

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'STARTING PROCESS_RECEIPT_APPLICATIONS');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FINDING ALL INVOICE APPLICATIONS WITHIN THE BATCH');
   END IF;

  -- getting all invoices to pay off within the batch
  FOR c_receipt_details_rec IN c_receipt_details(v_batch_id, v_org_id) LOOP

      v_origin                := c_receipt_details_rec.origin;
      v_cash_receipt_id       := c_receipt_details_rec.cash_receipt_id;
      v_cash_receipt_line_id  := c_receipt_details_rec.cash_receipt_line_id;
      v_appl_inv_id           := c_receipt_details_rec.customer_trx_id;
      v_appl_inv_ps_id        := c_receipt_details_rec.payment_schedule_id;
      v_appl_inv_amt          := c_receipt_details_rec.amount;
      v_sold_to_customer      := c_receipt_details_rec.sold_to_customer;
      v_transaction_code      := c_receipt_details_rec.ussgl_transaction_code;

      v_appl_amt_remain       := v_appl_inv_amt;

      -- reset cash_receipt_line_id used during insert_cash_receipt
      v_cash_receipt_line_id_ctr := 0;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_CASH_RECEIPT_ID = '||TO_CHAR(V_CASH_RECEIPT_ID));
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_CASH_RECEIPT_LINE_ID = '
                                        ||to_char(v_cash_receipt_line_id));
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_APPL_INV_AMT = '||TO_CHAR(V_APPL_INV_AMT));
       END IF;

     -- get finance charge debit memo totals for an invoice
     OPEN c_finchrg_total(v_transmission_id, v_batch_id,v_appl_inv_id);

     WHILE (v_appl_amt_remain > 0) LOOP
     FETCH c_finchrg_total INTO v_appl_dm_id,
                                v_dm_amt,
                                v_prioirty,
                                v_dm_pay_sch_id;

     EXIT when c_finchrg_total%NOTFOUND;

         -- amount remaining is >= to the total amount due on the debit memo
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DEBIT MEMO ID = '||TO_CHAR(V_APPL_DM_ID));
     END IF;

         IF v_appl_amt_remain >= v_dm_amt THEN
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AMT REMAIN > DM AMT');
           END IF;

            v_appl_amt_remain := v_appl_amt_remain - v_dm_amt;

            -- insert new cash receipt applied to a finance charge debit memo
            -- into ar_interim_cash_rcpt_lines_all
            IF v_dm_amt >0 THEN  -- don't want to insert $0 receipts
               insert_cash_receipt(v_appl_dm_id, v_dm_pay_sch_id, v_dm_amt, null);

               --update temp table subtracting v_dm_amt
               update_lockbox_temp(v_dm_amt);
            END IF;

         ELSE -- amount remaining is less than the amount due of the debit memo.
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'AMT REMAIN < DM AMT');
           END IF;

            IF v_origin = 'R' THEN
               -- when a receipt comes from ar_interim_cash_receipts table
               -- and we want to update it and apply it to a debit memo, because
               -- of form validation we must instead do the following:
               -- move the invoice appl record to the interim lines table and
               -- update the original record so that it is 'MULTIPLE' and not
               -- applied to invoice

               insert_cash_receipt(v_appl_dm_id, v_dm_pay_sch_id,
                                     v_appl_amt_remain, null);

               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATE AR_INTERIM_CASH_RECEIPTS TO MULTIPLE');
               END IF;
               update ar_interim_cash_receipts
                  set customer_trx_id = null,
                      payment_schedule_id = null,
                      special_type = 'MULTIPLE',
                      amount_applied = null,
                      last_updated_by = v_last_updated_by,
                      last_update_date = v_last_update_date
                where cash_receipt_id = v_cash_receipt_id;

            ELSE  -- v_origin = L

                -- update interim table w/amount remaining and finance charge
                -- debit memo id

                update_interim_table(v_origin, v_appl_amt_remain,
                               v_appl_dm_id,v_dm_pay_sch_id);

                --since the original receipt appl record is being updated to
                --to apply to a finance charge debit memo, the ussgl_transaction
                --_code should be set to null.  There should not be a tc
                --applied to a debit memo.

                update ar_interim_cash_rcpt_lines_all
                   set ussgl_transaction_code = null
                 where cash_receipt_id = v_cash_receipt_id
                   and cash_receipt_line_id = v_cash_receipt_line_id;

            END IF;

            -- update temp table subtract v_appl_amt_remain
            update_lockbox_temp(v_appl_amt_remain);

            v_appl_amt_remain := 0; -- no more to apply
         END IF;

     END LOOP; -- c_finchrg_total while

     IF c_finchrg_total%NOTFOUND and (v_appl_amt_remain > 0) and
         (v_appl_amt_remain <> v_appl_inv_amt) THEN

        -- this is for the case when have paid off all the finance charge debit
        -- memo and monies still remain to apply.  Adjust the original
        -- invoice application receipt record.

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'3RD BRANCH');
         END IF;

        IF v_origin = 'R' THEN
               -- when a receipt comes from ar_interim_cash_receipts table
               -- and we want to update it and apply it to a debit memo, because
               -- of form validation we must instead do the following:
               -- move the invoice appl record to the interim lines table and
               -- update the original record so that it is 'MULTIPLE' and not
               -- applied to invoice

               insert_cash_receipt(v_appl_inv_id, v_appl_inv_ps_id,
                  v_appl_amt_remain, v_transaction_code);

               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATE AR_INTERIM_CASH_RECEIPTS TO MULTIPLE');
               END IF;
               update ar_interim_cash_receipts
                  set customer_trx_id = null,
                      payment_schedule_id = null,
                      special_type = 'MULTIPLE',
                      amount_applied = null,
                      last_updated_by = v_last_updated_by,
                      last_update_date = v_last_update_date
                where cash_receipt_id = v_cash_receipt_id;

        ELSE -- v_origin = L

             -- update the invoice appl receipt in the interim table with
             -- the amount remaining
             update_interim_table(v_origin, v_appl_amt_remain,
                           v_appl_inv_id, v_appl_inv_ps_id);
        END IF;

        -- update temp table subtract v_appl_amt_remain
        update_lockbox_temp(v_appl_amt_remain);

        v_appl_amt_remain := 0; -- no more to apply

     END IF;
   CLOSE c_finchrg_total;
  END LOOP;  -- c_receipt_details

 EXCEPTION
   WHEN others THEN
    IF v_retcode is null THEN
       v_retcode := '2';
       v_errbuf  := 'process_receipt_application '||sqlerrm;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'ERROR OCCURRED IN PROCESS_RECEIPT_APPLICATION - '||SQLERRM);
    END IF;

    ROLLBACK;
    RAISE;

 END process_receipt_applications;

-- ------------------------------------------------------------------------
--             PROCEDURE  insert_cash_receipt
-- ------------------------------------------------------------------------
-- This procedures inserts a record into ar_interim_cash_rcpt_lines_all
-- for a new receipt.
-- ------------------------------------------------------------------------
 PROCEDURE insert_cash_receipt(v_cust_trx_id IN number,
                               v_pay_sch_id  IN number,
                                    v_amount IN number,
                               v_ussgl_tran_code IN varchar2) AS
  l_module_name VARCHAR2(200) := g_module_name || 'insert_cash_receipt';

 BEGIN

    IF v_cash_receipt_line_id_ctr = 0 THEN

         --find current max cash_receipt_line_id for current cash_receipt_id
         select max(cash_receipt_line_id)
           into v_cash_receipt_line_id_ctr
           from ar_interim_cash_rcpt_lines_all
          where batch_id = v_batch_id
            and cash_receipt_id = v_cash_receipt_id;

   END IF;

   v_cash_receipt_line_id_ctr := nvl(v_cash_receipt_line_id_ctr,0) + 1;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CTR = '||TO_CHAR(V_CASH_RECEIPT_LINE_ID_CTR));
   END IF;

   insert into ar_interim_cash_rcpt_lines_all
    (cash_receipt_id,
     cash_receipt_line_id,
     last_updated_by,
     last_update_date,
     created_by,
     creation_date,
     sold_to_customer,
     payment_amount,
     payment_schedule_id,
     customer_trx_id,
     batch_id,
     ussgl_transaction_code)
   values
    (v_cash_receipt_id,
     v_cash_receipt_line_id_ctr,
     v_last_updated_by,
     v_last_update_date,
     v_created_by,
     v_creation_date,
     v_sold_to_customer,
     v_amount,
     v_pay_sch_id,  -- fin chrg debit memo or invoice_id payment_schedule_id
     v_cust_trx_id,     -- fin chrg debit memo or invoice_id customer_trx_id
     v_batch_id,
     v_ussgl_tran_code);


   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INSERTED NEW CASH RECEIPT FOR CUSTOMER_TRX_ID '||
                    to_char(v_cust_trx_id));
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FOR THE AMOUNT OF '||TO_CHAR(V_AMOUNT));
   END IF;

 EXCEPTION
   WHEN others THEN
     v_retcode := '2';
     v_errbuf  := 'insert_cash_receipt '||sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'ERROR OCCURRED IN INSERT_CASH_RECEIPT - '||SQLERRM);
     ROLLBACK;
     RAISE;

 END insert_cash_receipt;

-- ------------------------------------------------------------------------
--             PROCEDURE updated_lockbox_temp
-- ------------------------------------------------------------------------
-- This process updates fv_lockbox_ipa_temp.  It decreases the total amount
-- available for application on a debit memo.  This is done so that the process
-- knows the current amount available for application in  a receipt.
-- ------------------------------------------------------------------------

 PROCEDURE update_lockbox_temp(v_decrease_dm_amount IN NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'update_lockbox_temp';

 BEGIN

    update fv_lockbox_ipa_temp
      set amount        = nvl(amount,0) - nvl(v_decrease_dm_amount,0)
    where debit_memo_id = v_appl_dm_id   -- current debit memo being processed
      and invoice_id    = v_appl_inv_id  -- current invoice being processed
      and batch_id      = v_batch_id;     -- curent batch being processed

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATE TEMP TABLE DECREASING BY '
                                ||to_char(v_decrease_dm_amount));
    END IF;
 EXCEPTION
   WHEN others THEN
     v_retcode := '2';
     v_errbuf  := 'update_lockbox_temp '||sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'ERROR OCCURRED IN UPDATE_LOCKBOX_TEMP - '||SQLERRM);
     ROLLBACK;
     RAISE;

 END update_lockbox_temp;

-- ------------------------------------------------------------------------
--             PROCEDURE update_interim_table
-- ------------------------------------------------------------------------
-- Since all the debit memos have been applied against and monies
-- remain and the amount remaining is not equal to the original application
-- amount (meaning we have paid off some portion of debit memo(s), then
-- the orginal application receipt record must be updated with the amount
-- remaining on the receipt and the debit memo being paid off.
-- V_table will contain a 'R' if the receipt
-- record is in ar_interim_cash_receipts or a 'L' if the receipt record
-- is in ar_interim_cash_rcpt_lines_all.
-- ------------------------------------------------------------------------

 PROCEDURE update_interim_table(v_table IN VARCHAR2,
                                v_decrease_appl_amt IN NUMBER,
                                v_upd_customer_trx_id IN NUMBER,
                                v_upd_pay_sch_id IN NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'update_interim_table';

 BEGIN


      update ar_interim_cash_rcpt_lines_all
         set payment_amount = nvl(v_decrease_appl_amt,0),
             customer_trx_id = v_upd_customer_trx_id,
             payment_schedule_id = v_upd_pay_sch_id,
             last_updated_by = v_last_updated_by,
             last_update_date = v_last_update_date
       where cash_receipt_id = v_cash_receipt_id
         and cash_receipt_line_id = v_cash_receipt_line_id;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATE INTERIM LINES TABLE SETTING AMOUNT = '
                         ||to_char(v_decrease_appl_amt)||' on cash_receipt_id '
                         ||to_char(v_cash_receipt_id));
   END IF;


 EXCEPTION
   WHEN others THEN
     v_retcode := '2';
     v_errbuf  := 'update_interim_table '||sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'ERROR OCCURRED IN UPDATE_INTERIM_TABLE - '||SQLERRM);
     ROLLBACK;
     RAISE;

 END update_interim_table;


END FV_LOCKBOX_FC_PKG;

/
