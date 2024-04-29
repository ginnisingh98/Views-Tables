--------------------------------------------------------
--  DDL for Package Body AR_BUS_EVENT_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BUS_EVENT_COVER" AS
/* $Header: ARBEPKGB.pls 120.17.12010000.3 2009/12/28 21:37:20 mraymond ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION isRefreshProgramRunning RETURN BOOLEAN IS
CURSOR C1 IS
select request_id
from AR_CONC_PROCESS_REQUESTS
where CONCURRENT_PROGRAM_NAME = 'ARSUMREF';
l_request_id  number;
BEGIN

OPEN C1;

  FETCH C1 INTO l_request_id;

  IF C1%NOTFOUND THEN
   return false;
  ELSE
   return true;
  END IF;

CLOSE C1;

END isRefreshProgramRunning;

PROCEDURE insert_events_hist (p_be_name VARCHAR2,
                              p_event_key VARCHAR2,
                              p_ps_id    NUMBER,
                              p_ctx_id   NUMBER,
                              p_cr_id    NUMBER,
                              p_ra_id    NUMBER,
                              p_adj_id   NUMBER,
                              p_hist_id  NUMBER,
                              p_req_id   NUMBER
                              )
 IS

BEGIN

   INSERT INTO AR_SUM_REF_EVENT_HIST
              (business_event_name,
               event_key,
               payment_schedule_id,
               customer_trx_id,
               cash_receipt_id,
               receivable_application_id,
               adjustment_id,
               history_id,
               request_id,
               last_update_date,
               last_update_by,
               creation_date,
               created_by,
               last_update_login)
       VALUES (p_be_name,
               p_event_key,
               p_ps_id,
               p_ctx_id,
               p_cr_id,
               p_ra_id,
               p_adj_id,
               p_hist_id,
               p_req_id,
               sysdate,
               FND_GLOBAL.user_id,
               sysdate,
               FND_GLOBAL.user_id,
               FND_GLOBAL.login_id);

END insert_events_hist;

PROCEDURE p_insert_trx_sum_hist(p_trx_sum_hist_rec IN AR_TRX_SUMMARY_HIST%rowtype,
                                p_history_id OUT NOCOPY NUMBER,
                                p_trx_type IN VARCHAR2,
                                p_event_type  IN VARCHAR2 DEFAULT NULL)
IS
l_event_name VARCHAR2(100);
l_previous_history_id  NUMBER;
l_history_id   NUMBER;
CURSOR get_prev_hist_id (p_ps_id IN NUMBER) IS
SELECT max(history_id)
FROM AR_TRX_SUMMARY_HIST
WHERE payment_schedule_id = p_ps_id;

BEGIN
  OPEN get_prev_hist_id (p_trx_sum_hist_rec.payment_schedule_id);

  FETCH get_prev_hist_id  INTO l_previous_history_id;

  CLOSE get_prev_hist_id;


  IF p_trx_type = 'INV'  AND
     p_event_type = 'INCOMPLETE_TRX' THEN

     l_event_name := 'oracle.apps.ar.transaction.Invoice.incomplete';
  ELSIF p_trx_type = 'INV' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.Invoice.modify';
  ELSIF p_trx_type = 'CM' AND
     p_event_type = 'INCOMPLETE_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.CreditMemo.incomplete';
  ELSIF p_trx_type = 'CM' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.CreditMemo.modify';
  ELSIF p_trx_type = 'DM' AND
     p_event_type = 'INCOMPLETE_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.DebitMemo.incomplete';
  ELSIF p_trx_type = 'DM' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.DebitMemo.modify';
  ELSIF p_trx_type = 'DEP' AND
     p_event_type = 'INCOMPLETE_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.Deposit.incomplete';
  ELSIF p_trx_type = 'DEP' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.Deposit.modify';
  ELSIF p_trx_type = 'BR' AND
     p_event_type = 'INCOMPLETE_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.BillsReceivables.incomplete';
  ELSIF p_trx_type = 'BR' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.BillsReceivables.modify';
  ELSIF p_trx_type = 'GUAR' AND
     p_event_type = 'INCOMPLETE_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.Guarantee.incomplete';
  ELSIF p_trx_type = 'GUAR' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.Guarantee.modify';
  ELSIF p_trx_type = 'CB' AND
     p_event_type = 'MODIFY_TRX'  THEN

     l_event_name := 'oracle.apps.ar.transaction.ChargeBack.modify';
  ELSIF p_trx_type = 'PMT' AND
     p_event_type = 'MODIFY_PMT'  THEN

     l_event_name := 'oracle.apps.ar.receipts.CashReceipt.modify';
  ELSIF p_trx_type = 'PMT' AND
      p_event_type = 'DM_REVERSE_PMT'  THEN

      l_event_name := 'oracle.apps.ar.receipts.CashReceipt.DebitMemoReverse';
  ELSIF p_trx_type = 'PMT' AND
      p_event_type = 'REVERSE_PMT'  THEN

      l_event_name := 'oracle.apps.ar.receipts.CashReceipt.reverse';
  ELSIF p_trx_type = 'PMT' AND
      p_event_type = 'DELETE_PMT'  THEN

      l_event_name := 'oracle.apps.ar.receipts.CashReceipt.Delete';
  END IF;


  SELECT AR_TRX_SUMMARY_HIST_S.nextval
  INTO l_history_id
  FROM dual;

     INSERT INTO AR_TRX_SUMMARY_HIST
          (history_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           customer_trx_id,
           cash_receipt_id,
           payment_schedule_id,
           currency_code,
           previous_history_id,
           due_date,
           amount_in_dispute,
           amount_due_original,
           amount_due_remaining,
           amount_adjusted,
           complete_flag,
           customer_id,
           site_use_id,
           trx_date,
           installments,
           event_name)
       VALUES
          (l_history_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           p_trx_sum_hist_rec.customer_trx_id,
           p_trx_sum_hist_rec.cash_receipt_id,
           p_trx_sum_hist_rec.payment_schedule_id,
           p_trx_sum_hist_rec.currency_code,
           l_previous_history_id,
           p_trx_sum_hist_rec.due_date,
           p_trx_sum_hist_rec.amount_in_dispute,
           p_trx_sum_hist_rec.amount_due_original,
           p_trx_sum_hist_rec.amount_due_remaining,
           p_trx_sum_hist_rec.amount_adjusted,
           p_trx_sum_hist_rec.complete_flag,
           p_trx_sum_hist_rec.customer_id,
           p_trx_sum_hist_rec.site_use_id,
           p_trx_sum_hist_rec.trx_date,
           p_trx_sum_hist_rec.installments,
           l_event_name
          );
    p_history_id := l_history_id;
END;

/* 9216062 - set ORG_ID parameter correctly if MOAC is
   enabled */
FUNCTION  get_org_id (p_unique_id IN NUMBER,
                      p_column_name IN VARCHAR2,
                      p_trx_type    IN VARCHAR2 DEFAULT 'NOT_REQUIRED')
RETURN NUMBER
IS
   l_org_id NUMBER;
BEGIN

   IF p_column_name = 'PAYMENT_SCHEDULE_ID'
   THEN

     SELECT org_id
     INTO   l_org_id
     FROM   AR_PAYMENT_SCHEDULES_ALL
     WHERE  payment_schedule_id = p_unique_id;

   ELSIF p_column_name = 'CUSTOMER_TRX_ID'
   THEN

     SELECT org_id
     INTO   l_org_id
     FROM   RA_CUSTOMER_TRX_ALL
     WHERE  customer_trx_id = p_unique_id;

   ELSIF p_column_name = 'CASH_RECEIPT_ID'
   THEN

     SELECT org_id
     INTO   l_org_id
     FROM   AR_CASH_RECEIPTS_ALL
     WHERE  cash_receipt_id = p_unique_id;

   ELSIF p_column_name = 'RECEIVABLE_APPLICATION_ID'
   THEN

     SELECT org_id
     INTO   l_org_id
     FROM   AR_RECEIVABLE_APPLICATIONS_ALL
     WHERE  receivable_application_id = p_unique_id;

   ELSIF p_column_name = 'ADJUSTMENT_ID'
   THEN

     SELECT org_id
     INTO   l_org_id
     FROM   AR_ADJUSTMENTS_ALL
     WHERE  adjustment_id = p_unique_id;

   ELSIF p_column_name = 'REQUEST_ID'
   THEN

     IF p_trx_type = 'INVOICES'
     THEN

        SELECT org_id
        INTO   l_org_id
        FROM   ra_customer_trx_all
        WHERE  request_id = p_unique_id
        AND    rownum = 1;

     ELSIF p_trx_type = 'RECEIPTS'
     THEN

        SELECT org_id
        INTO   l_org_id
        FROM   ar_cash_receipts_all
        WHERE  request_id = p_unique_id
        AND    rownum = 1;

     ELSIF p_trx_type = 'ADJUSTMENTS'
     THEN

        SELECT org_id
        INTO   l_org_id
        FROM   ar_adjustments_all
        WHERE  request_id = p_unique_id
        AND    rownum = 1;

     ELSE
      /* Not a valid p_trx_type so display a message */
      arp_debug.debug('EXCEPTION:  Invalid p_trx_type ' || p_trx_type ||
               ' in call to get_org_id');

     END IF;
   ELSE
      /* Not a valid column_name so display a message in log and do
         nothing else */
      arp_debug.debug('EXCEPTION:  Invalid p_column_name ' || p_column_name ||
              ' in call to get_org_id');
   END IF;

   arp_debug.debug('  get_org_id returning ' || l_org_id);

   RETURN l_org_id;

END get_org_id;

PROCEDURE Raise_Trx_Creation_Event
( p_doc_type  IN VARCHAR2,
  p_customer_trx_id  IN  NUMBER,
  p_prev_cust_old_state IN prev_cust_old_state_tab
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50);
    l_prev_ps_op_status    NUMBER;
    l_prev_ps_cl_status    NUMBER;
CURSOR cm_prev_ctx (p_ctx_id IN NUMBER) IS
  select prev_trx_ps.status,
         prev_trx_ps.payment_schedule_id,
         prev_trx_ps.amount_applied,
         prev_trx_ps.class,
         prev_trx_ps.amount_credited,
         prev_trx_ps.due_date
  from ar_payment_schedules prev_trx_ps,
       ra_customer_trx ctx
  where ctx.customer_trx_id = p_ctx_id
   and  ctx.previous_customer_trx_id = prev_trx_ps.customer_trx_id
        ;

  l_prev_trx_op_count NUMBER;
  l_cm_op_trx_count   NUMBER;
  l_cm_cl_trx_count   NUMBER;
  l_prev_trx_app_amt  NUMBER;
  l_past_due_inv_amt  NUMBER;
  l_past_due_inv_count NUMBER;
  l_org_id            NUMBER;

BEGIN
  IF  p_doc_type = 'INV'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Invoice.complete';
  ELSIF p_doc_type = 'CM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.CreditMemo.complete';
  ELSIF p_doc_type = 'DEP'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Deposit.complete';
  ELSIF p_doc_type = 'DM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.DebitMemo.complete';
  ELSIF p_doc_type = 'CB'   THEN
   l_event_name := 'oracle.apps.ar.transaction.ChargeBack.create';
  ELSIF p_doc_type = 'GUAR' THEN
   l_event_name := 'oracle.apps.ar.transaction.Guarantee.complete';
  ELSIF p_doc_type = 'BR' THEN
   l_event_name := 'oracle.apps.ar.transaction.BillsReceivables.complete';
  END IF;

        --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                        p_customer_trx_id );

  IF (isRefreshProgramRunning)  THEN


         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => p_customer_trx_id,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

     -- initialization of object variables
     l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_customer_trx_id,
                            'CUSTOMER_TRX_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'CUSTOMER_TRX_ID',
                           p_value => p_customer_trx_id,
                           p_parameterlist => l_list);


    IF p_doc_type = 'CM'  THEN
     l_cm_cl_trx_count := 0;
     l_cm_op_trx_count := 0;
     l_prev_trx_app_amt := 0;
     l_past_due_inv_amt := 0;
     l_past_due_inv_count := 0;

     FOR i in cm_prev_ctx(p_customer_trx_id) LOOP


      --check if the status of this PS has changed.
      IF p_prev_cust_old_state(i.payment_schedule_id).status = 'OP' AND
         i.status = 'CL'  THEN
         l_cm_cl_trx_count := l_cm_cl_trx_count + 1;
         l_prev_trx_app_amt := l_prev_trx_app_amt + nvl(i.amount_applied,0);

         IF i.due_date < sysdate and i.class = 'INV' THEN
          l_past_due_inv_count := l_past_due_inv_count - 1;
         END IF;
      ELSIF p_prev_cust_old_state(i.payment_schedule_id).status = 'CL' AND
         i.status = 'OP'  THEN
         l_cm_op_trx_count := l_cm_op_trx_count + 1;
         l_prev_trx_app_amt := l_prev_trx_app_amt - nvl(i.amount_applied,0);

         IF i.due_date < sysdate and i.class = 'INV' THEN
          l_past_due_inv_count := l_past_due_inv_count + 1;
         END IF;
      END IF;

      IF i.due_date < sysdate and i.class = 'INV' THEN
        l_past_due_inv_amt := l_past_due_inv_amt +
          ( nvl(p_prev_cust_old_state(i.payment_schedule_id).amount_credited,0) -
                                                 nvl(i.amount_credited,0));
      END IF;

     END LOOP;


     l_prev_trx_op_count := l_cm_op_trx_count - l_cm_cl_trx_count;

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PREV_TRX_OP_COUNT',
                           p_value => l_prev_trx_op_count,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PREV_TRX_APP_AMT',
                           p_value => fnd_number.number_to_canonical(l_prev_trx_app_amt),
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PAST_DUE_INV_AMT',
                           p_value => fnd_number.number_to_canonical(l_past_due_inv_amt),
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'PAST_DUE_INV_COUNT',
                           p_value => l_past_due_inv_count,
                           p_parameterlist => l_list);

    END IF;




        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Trx_Creation_Event;

PROCEDURE Raise_Trx_Incomplete_Event
( p_doc_type  IN VARCHAR2,
  p_customer_trx_id  IN  NUMBER,
  p_ps_id            IN NUMBER,
  p_history_id      IN NUMBER,
  p_prev_cust_old_state IN PREV_CUST_OLD_STATE_TAB
 )  IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50);

    l_prev_ps_op_status    NUMBER;
    l_prev_ps_cl_status    NUMBER;
    l_org_id               NUMBER;
CURSOR cm_prev_ctx (p_ctx_id IN NUMBER) IS
  select prev_trx_ps.status,
         prev_trx_ps.payment_schedule_id,
         prev_trx_ps.amount_applied,
         prev_trx_ps.class,
         prev_trx_ps.amount_credited,
         prev_trx_ps.due_date,
         ctx.previous_customer_trx_id
  from ar_payment_schedules prev_trx_ps,
       ra_customer_trx ctx
  where ctx.customer_trx_id = p_ctx_id
   and  ctx.previous_customer_trx_id = prev_trx_ps.customer_trx_id
        ;

  l_prev_trx_op_count NUMBER;
  l_cm_op_trx_count   NUMBER;
  l_cm_cl_trx_count   NUMBER;
  l_prev_trx_app_amt  NUMBER;
  l_past_due_inv_amt  NUMBER;
  l_past_due_inv_count NUMBER;
  l_prev_trx_type     VARCHAR2(10);
  l_prev_ctx_id      NUMBER;
BEGIN

  IF  p_doc_type = 'INV'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Invoice.incomplete';
  ELSIF p_doc_type = 'CM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.CreditMemo.incomplete';
  ELSIF p_doc_type = 'DEP'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Deposit.incomplete';
  ELSIF p_doc_type = 'DM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.DebitMemo.incomplete';
  ELSIF p_doc_type = 'GUAR' THEN
   l_event_name := 'oracle.apps.ar.transaction.Guarantee.incomplete';
  ELSIF p_doc_type = 'BR' THEN
   l_event_name := 'oracle.apps.ar.transaction.BillsReceivables.incomplete';
  END IF;

        --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_customer_trx_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_ps_id,
                              p_ctx_id   => p_customer_trx_id,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => p_history_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_customer_trx_id,
                            'CUSTOMER_TRX_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'CUSTOMER_TRX_ID',
                           p_value => p_customer_trx_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_ps_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => p_history_id,
                           p_parameterlist => l_list);
    IF p_doc_type = 'CM'  THEN
     l_cm_cl_trx_count := 0;
     l_cm_op_trx_count := 0;
     l_prev_trx_app_amt := 0;
     l_past_due_inv_amt := 0;
     l_past_due_inv_count := 0;

     FOR i in cm_prev_ctx(p_customer_trx_id) LOOP

      l_prev_trx_type := i.class;
      l_prev_ctx_id  := i.previous_customer_trx_id;

      --check if the status of this PS has changed.
      IF p_prev_cust_old_state(i.payment_schedule_id).status = 'OP' AND
         i.status = 'CL'  THEN
         l_cm_cl_trx_count := l_cm_cl_trx_count + 1;
         l_prev_trx_app_amt := l_prev_trx_app_amt + nvl(i.amount_applied,0);

         IF i.due_date < sysdate and i.class = 'INV' THEN
          l_past_due_inv_count := l_past_due_inv_count - 1;
         END IF;
      ELSIF p_prev_cust_old_state(i.payment_schedule_id).status = 'CL' AND
         i.status = 'OP'  THEN
         l_cm_op_trx_count := l_cm_op_trx_count + 1;
         l_prev_trx_app_amt := l_prev_trx_app_amt - nvl(i.amount_applied,0);

         IF i.due_date < sysdate and i.class = 'INV' THEN
          l_past_due_inv_count := l_past_due_inv_count + 1;
         END IF;
      END IF;

      IF i.due_date < sysdate and i.class = 'INV' THEN
        l_past_due_inv_amt := l_past_due_inv_amt +
          ( nvl(p_prev_cust_old_state(i.payment_schedule_id).amount_credited,0) -
                                                 nvl(i.amount_credited,0));
      END IF;

     END LOOP;


     l_prev_trx_op_count := l_cm_op_trx_count - l_cm_cl_trx_count;

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PREV_TRX_OP_COUNT',
                           p_value => l_prev_trx_op_count,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PREV_TRX_APP_AMT',
                           p_value => fnd_number.number_to_canonical(l_prev_trx_app_amt),
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PAST_DUE_INV_AMT',
                           p_value => fnd_number.number_to_canonical(l_past_due_inv_amt),
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PAST_DUE_INV_COUNT',
                           p_value => l_past_due_inv_count,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PREV_TRX_TYPE',
                           p_value => l_prev_trx_type,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'PREV_TRX_ID',
                           p_value => l_prev_ctx_id,
                           p_parameterlist => l_list);

    END IF;


        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
    END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Trx_Incomplete_Event;

--
-- This has to be raised per payment_schedule_id modified
--

PROCEDURE Raise_Trx_Modify_Event
( p_payment_schedule_id  IN NUMBER,
  p_doc_type  IN VARCHAR2,
  p_history_id           IN NUMBER
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50);
    l_org_id                                NUMBER;
BEGIN

  IF  p_doc_type = 'INV'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Invoice.modify';
  ELSIF p_doc_type = 'CM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.CreditMemo.modify';
  ELSIF p_doc_type = 'DM'  THEN
   l_event_name := 'oracle.apps.ar.transaction.DebitMemo.modify';
  ELSIF p_doc_type = 'DEP'  THEN
   l_event_name := 'oracle.apps.ar.transaction.Deposit.modify';
  ELSIF p_doc_type = 'CB'   THEN
   l_event_name := 'oracle.apps.ar.transaction.ChargeBack.modify';
  ELSIF p_doc_type = 'GUAR' THEN
   l_event_name := 'oracle.apps.ar.transaction.Guarantee.modify';
  END IF;

    --Get the item key
     l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                          p_payment_schedule_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => p_history_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
     l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_payment_schedule_id,
                            'PAYMENT_SCHEDULE_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => p_history_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Trx_Modify_Event;

PROCEDURE Raise_Rcpt_Creation_Event
 ( p_payment_schedule_id  IN  NUMBER
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50) := 'oracle.apps.ar.receipts.CashReceipt.create';

    l_cust_account_id						ar_payment_schedules.customer_id%type;
    l_org_id NUMBER;

    -- bug 3979914.
    CURSOR getCustomerC IS
    	SELECT nvl(customer_id, -99) cust_account_id
    	FROM   ar_payment_schedules
    	WHERE  payment_schedule_id = p_payment_schedule_id;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Raise_Rcpt_Creation_Event (+)');
 END IF;

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_payment_schedule_id);
  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_payment_schedule_id,
                            'PAYMENT_SCHEDULE_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- Get Customer Id
     OPEN getCustomerC;
     	FETCH getCustomerC INTO l_cust_account_id;
	 CLOSE getCustomerC;
	 -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

	 wf_event.AddParameterToList(p_name => 'CUST_ACCOUNT_ID',
                        	p_value => l_cust_account_id,
                           	p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
   END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Raise_Rcpt_Creation_Event (-)');
END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Rcpt_Creation_Event;

PROCEDURE Raise_Rcpt_Modify_Event
 ( p_cash_receipt_id  IN  NUMBER,
   p_payment_schedule_id  IN  NUMBER,
   p_history_id       IN NUMBER
 )
IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.receipts.CashReceipt.modify';
    l_org_id                                NUMBER;

BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_payment_schedule_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => p_cash_receipt_id,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => p_history_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_cash_receipt_id,
                            'CASH_RECEIPT_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'CASH_RECEIPT_ID',
                           p_value => p_cash_receipt_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => p_history_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Rcpt_Modify_Event;

PROCEDURE Raise_Rcpt_Reverse_Event
 (p_cash_receipt_id  IN  NUMBER,
  p_payment_schedule_id  IN  NUMBER,
  p_history_id       IN NUMBER
 )
IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.receipts.CashReceipt.reverse';

    l_org_id                                NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_payment_schedule_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => p_cash_receipt_id,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => p_history_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_cash_receipt_id,
                            'CASH_RECEIPT_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'CASH_RECEIPT_ID',
                           p_value => p_cash_receipt_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => p_history_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Rcpt_Reverse_Event;

PROCEDURE Raise_Rcpt_DMReverse_Event
 (p_cash_receipt_id  IN  NUMBER,
  p_payment_schedule_id  IN  NUMBER,
  p_history_id       IN NUMBER
 )
IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(100)
                                             := 'oracle.apps.ar.receipts.CashReceipt.DebitMemoReverse';

    l_org_id                                NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_payment_schedule_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => p_cash_receipt_id,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => p_history_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_cash_receipt_id,
                            'CASH_RECEIPT_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'CASH_RECEIPT_ID',
                           p_value => p_cash_receipt_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => p_history_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Rcpt_DMReverse_Event;

PROCEDURE Raise_Rcpt_Confirm_Event
 ( p_rec_appln_id  IN  NUMBER,
   p_cash_receipt_id  IN  NUMBER)
IS

BEGIN

null;
END Raise_Rcpt_Confirm_Event;

PROCEDURE Raise_Rcpt_UnConfirm_Event
 ( p_rec_appln_id  IN  NUMBER,
   p_cash_receipt_id  IN  NUMBER)
IS

BEGIN

null;
END Raise_Rcpt_UnConfirm_Event;

PROCEDURE Raise_CR_Apply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.applications.CashApp.apply';
 CURSOR get_ps_status(ra_id IN NUMBER) IS
 select inv_ps.status  trx_ps_status,
        rcpt_ps.status rcpt_ps_status,
        to_char(inv_ps.due_date , 'J') due_date,
        inv_ps.amount_applied
 from ar_receivable_applications ra,
      ar_payment_schedules inv_ps,
      ar_payment_schedules rcpt_ps
 where ra.receivable_application_id = ra_id
  and  ra.applied_payment_schedule_id = inv_ps.payment_schedule_id
  and  ra.payment_schedule_id = rcpt_ps.payment_schedule_id;
 l_trx_ps_status   VARCHAR2(10);
 l_rcpt_ps_status  VARCHAR2(10);
 l_due_date        VARCHAR2(20);
 l_trx_amt_applied NUMBER;
 l_org_id          NUMBER;

BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_receivable_application_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => p_receivable_application_id,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE
    OPEN get_ps_status(p_receivable_application_id);
     FETCH get_ps_status INTO l_trx_ps_status, l_rcpt_ps_status, l_due_date,
                               l_trx_amt_applied;
    CLOSE get_ps_status;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_receivable_application_id,
                            'RECEIVABLE_APPLICATION_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'RECEIVABLE_APPLICATION_ID',
                           p_value => p_receivable_application_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_PS_STATUS',
                           p_value => l_trx_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'RCPT_PS_STATUS',
                           p_value => l_rcpt_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_DUE_DATE',
                           p_value => l_due_date,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_APP_AMT',
                           p_value => fnd_number.number_to_canonical(l_trx_amt_applied),
                           p_parameterlist => l_list);


        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_CR_Apply_Event;

PROCEDURE Raise_CR_UnApply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                          := 'oracle.apps.ar.applications.CashApp.unapply';
 CURSOR get_ps_status(ra_id IN NUMBER) IS
 select inv_ps.status  trx_ps_status,
        rcpt_ps.status rcpt_ps_status,
        to_char(inv_ps.due_date , 'J') due_date,
        inv_ps.amount_applied,
        ra.amount_applied,
        ra.amount_applied_from,
        inv_ps.amount_due_remaining,
        ra.earned_discount_taken,
        ra.unearned_discount_taken
 from ar_receivable_applications ra,
      ar_payment_schedules inv_ps,
      ar_payment_schedules rcpt_ps
 where ra.receivable_application_id = ra_id
  and  ra.applied_payment_schedule_id = inv_ps.payment_schedule_id
  and  ra.payment_schedule_id = rcpt_ps.payment_schedule_id;
 l_old_trx_ps_status   VARCHAR2(10);
 l_new_trx_ps_status   VARCHAR2(10);
 l_old_rcpt_ps_status  VARCHAR2(10);
 l_new_rcpt_ps_status  VARCHAR2(10);
 l_due_date              VARCHAR2(20);
 l_trx_amt_applied       NUMBER;
 l_trx_adr               NUMBER;
 l_rcpt_adr              NUMBER;
 l_amount_applied           NUMBER;
 l_amount_applied_from   NUMBER;
 l_earned_discount_taken  NUMBER;
 l_unearned_discount_taken  NUMBER;
 l_tot_amt_applied          NUMBER;
 l_org_id                   NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('Raise_CR_UnApply_Event(+)');
 END IF;
    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                         p_receivable_application_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name   => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                             p_ctx_id   => null,
                             p_cr_id    => null,
                             p_ra_id    => p_receivable_application_id,
                             p_adj_id   => null,
                             p_hist_id  => null,
                             p_req_id   => null);
  ELSE
    OPEN get_ps_status(p_receivable_application_id);
     FETCH get_ps_status INTO l_new_trx_ps_status, l_new_rcpt_ps_status, l_due_date,
                              l_tot_amt_applied, l_amount_applied, l_amount_applied_from,l_trx_adr,
                              l_earned_discount_taken, l_unearned_discount_taken;


   /* If  the amount applied and the discounts on the application
      that is being reversed adds up to the new amount_due_remaining
      on the trx payment schedule that means that the trx PS was
      closed prior to the application reversal.

     The idea here is to capure the trx PS status prior to the unapply
     and pass that to the business event as parameter.
   */
    IF l_new_trx_ps_status = 'OP' THEN
      IF ( nvl(l_trx_adr,0) +
             (  nvl(l_amount_applied,0)
              + nvl(l_earned_discount_taken,0)
              + nvl(l_unearned_discount_taken,0)
              )
        ) = 0  THEN
        l_old_trx_ps_status := 'CL';

      ELSE
        l_old_trx_ps_status := 'OP';
      END IF;
    ELSIF l_new_trx_ps_status = 'CL'  THEN
      l_old_trx_ps_status := 'OP';
    END IF;

    IF l_new_rcpt_ps_status = 'OP'
     THEN
       IF( nvl(l_rcpt_adr,0) +
              nvl(l_amount_applied_from,l_amount_applied)
          ) = 0  THEN
         l_old_rcpt_ps_status := 'CL';
       ELSE
         l_old_rcpt_ps_status := 'OP';
       END IF;
    ELSIF l_new_rcpt_ps_status = 'CL'  THEN
      l_old_rcpt_ps_status := 'OP';
    END IF;

    CLOSE get_ps_status;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_receivable_application_id,
                            'RECEIVABLE_APPLICATION_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'RECEIVABLE_APPLICATION_ID',
                           p_value => p_receivable_application_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'OLD_TRX_PS_STATUS',
                           p_value => l_old_trx_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'NEW_TRX_PS_STATUS',
                           p_value => l_new_trx_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'OLD_RCPT_PS_STATUS',
                           p_value => l_old_rcpt_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'NEW_RCPT_PS_STATUS',
                           p_value => l_new_rcpt_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_DUE_DATE',
                           p_value => l_due_date,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_APP_AMT',
                           p_value =>fnd_number.number_to_canonical(l_tot_amt_applied),
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'AMT_DUE_REMAINING',
                           p_value =>fnd_number.number_to_canonical(l_trx_adr),
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'OLD_AMT_DUE_REMAINING',
                           p_value => fnd_number.number_to_canonical( nvl(l_trx_adr,0) +
                                         (  nvl(l_amount_applied,0)
                                          + nvl(l_earned_discount_taken,0)
                                          + nvl(l_unearned_discount_taken,0)
                                          )),
                           p_parameterlist => l_list);


        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Raise_CR_UnApply_Event(-)');
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_CR_UnApply_Event;

PROCEDURE Raise_CM_Apply_Event
 (p_receivable_application_id  IN NUMBER ,--pass in the rec_app_id of the APP rec
  p_app_ps_status   IN VARCHAR2  DEFAULT NULL
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.applications.CreditMemoApp.apply';
 CURSOR get_ps_status(ra_id IN NUMBER) IS
 select inv_ps.status  trx_ps_status,
        cm_ps.status cm_ps_status,
        to_char(inv_ps.due_date , 'J') due_date,
        inv_ps.amount_applied
 from ar_receivable_applications ra,
      ar_payment_schedules inv_ps,
      ar_payment_schedules cm_ps
 where ra.receivable_application_id = ra_id
  and  ra.applied_payment_schedule_id = inv_ps.payment_schedule_id
  and  ra.payment_schedule_id = cm_ps.payment_schedule_id;

 l_trx_ps_status   VARCHAR2(10);
 l_cm_ps_status  VARCHAR2(10);
 l_due_date        VARCHAR2(20);
 l_trx_amt_applied NUMBER;
 l_org_id          NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_receivable_application_id);

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => p_receivable_application_id,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

    OPEN get_ps_status(p_receivable_application_id);
     FETCH get_ps_status INTO l_trx_ps_status, l_cm_ps_status, l_due_date,
                               l_trx_amt_applied;
    CLOSE get_ps_status;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_receivable_application_id,
                            'RECEIVABLE_APPLICATION_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'RECEIVABLE_APPLICATION_ID',
                           p_value => p_receivable_application_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_PS_STATUS',
                           p_value => l_trx_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'CM_PS_STATUS',
                           p_value => l_cm_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_DUE_DATE',
                           p_value => l_due_date,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_APP_AMT',
                           p_value => fnd_number.number_to_canonical(l_trx_amt_applied),
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_CM_Apply_Event;

PROCEDURE Raise_CM_UnApply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 ) IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.applications.CreditMemoApp.unapply';
 CURSOR get_ps_status(ra_id IN NUMBER) IS
 select inv_ps.status  trx_ps_status,
        cm_ps.status cm_ps_status,
        to_char(inv_ps.due_date , 'J') due_date,
        inv_ps.amount_applied
 from ar_receivable_applications ra,
      ar_payment_schedules inv_ps,
      ar_payment_schedules cm_ps
 where ra.receivable_application_id = ra_id
  and  ra.applied_payment_schedule_id = inv_ps.payment_schedule_id
  and  ra.payment_schedule_id = cm_ps.payment_schedule_id;

 l_trx_ps_status   VARCHAR2(10);
 l_cm_ps_status  VARCHAR2(10);
 l_due_date        VARCHAR2(20);
 l_trx_amt_applied NUMBER;
 l_org_id          NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_receivable_application_id);

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => p_receivable_application_id,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

    OPEN get_ps_status(p_receivable_application_id);
     FETCH get_ps_status INTO l_trx_ps_status, l_cm_ps_status, l_due_date,
                               l_trx_amt_applied;
    CLOSE get_ps_status;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_receivable_application_id,
                            'RECEIVABLE_APPLICATION_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'RECEIVABLE_APPLICATION_ID',
                           p_value => p_receivable_application_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_PS_STATUS',
                           p_value => l_trx_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'CM_PS_STATUS',
                           p_value => l_cm_ps_status,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_DUE_DATE',
                           p_value => l_due_date,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'TRX_APP_AMT',
                           p_value => fnd_number.number_to_canonical(l_trx_amt_applied),
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_CM_UnApply_Event;

PROCEDURE Raise_Adj_Create_Event
 (p_adjustment_id  IN NUMBER,
  p_app_ps_status  IN VARCHAR2 DEFAULT NULL,
  p_adj_status   IN VARCHAR2 DEFAULT NULL)
IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.adjustments.Adjustment.create';
    l_org_id                                NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_adjustment_id);

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => p_adjustment_id,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_adjustment_id,
                            'ADJUSTMENT_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'ADJUSTMENT_ID',
                           p_value => p_adjustment_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'APPLIED_PS_STATUS',
                           p_value => p_app_ps_status,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'ADJ_STATUS',
                           p_value => p_adj_status,
                           p_parameterlist => l_list);


        -- Raise Event
       AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Adj_Create_Event;

PROCEDURE Raise_Adj_Approve_Event
 (p_adjustment_id IN NUMBER,
  p_approval_actn_hist_id IN NUMBER,
  p_app_ps_status IN VARCHAR2 DEFAULT NULL)
IS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(50)
                                             := 'oracle.apps.ar.adjustments.Adjustment.approve';
    l_org_id                                NUMBER;
BEGIN

    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_adjustment_id);
  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => p_adjustment_id,
                              p_hist_id  => p_approval_actn_hist_id,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_adjustment_id,
                            'ADJUSTMENT_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'ADJUSTMENT_ID',
                           p_value => p_adjustment_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'APPROVAL_ACTN_HIST_ID',
                           p_value => p_approval_actn_hist_id,
                           p_parameterlist => l_list);
     wf_event.AddParameterToList(p_name => 'APPLIED_PS_STATUS',
                           p_value => p_app_ps_status,
                           p_parameterlist => l_list);

        -- Raise Event
       AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_Adj_Approve_Event;

PROCEDURE Raise_AutoInv_Run_Event
         ( p_request_id IN   NUMBER)
IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50) := 'oracle.apps.ar.batch.AutoInvoice.run';
    l_org_id         NUMBER;
BEGIN

   --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                        p_request_id);
  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => null,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => p_request_id);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_request_id,
                            'REQUEST_ID',
                            'INVOICES');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => p_request_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
      l_list.DELETE;
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_AutoInv_Run_Event;

PROCEDURE Raise_AutoRec_Run_Event
 ( p_request_id  IN  NUMBER,
   p_req_confirmation IN VARCHAR2)
IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50) := 'oracle.apps.ar.batch.AutoReceipts.run';
    l_org_id         NUMBER;
BEGIN

 --We raise the bisiness event only in case the confirmation is
 --not required for the batch. In this case the PS of the receipt would
 --get created and the PS of the invoice would get updated upon the
 --Auto Receipt Run with approval.
  IF p_req_confirmation = 'Y'  THEN
   --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name,
                                        p_request_id );

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key=> l_key,
                             p_ps_id    => null,
                             p_ctx_id   => null,
                             p_cr_id    => null,
                             p_ra_id    => null,
                             p_adj_id   => null,
                             p_hist_id  => null,
                             p_req_id   => p_request_id);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_request_id,
                            'REQUEST_ID',
                            'RECEIPTS');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => p_request_id,
                           p_parameterlist => l_list);

        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
      l_list.DELETE;
   END IF;

   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_AutoRec_Run_Event;

PROCEDURE Raise_PostBatch_Run_Event
 ( p_request_id  IN  NUMBER)
IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50) := 'oracle.apps.ar.batch.QuickCash.PostBatch';
    l_org_id         NUMBER;
BEGIN

  IF p_request_id is not null  THEN
   --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                        p_request_id);

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key=> l_key,
                             p_ps_id    => null,
                             p_ctx_id   => null,
                             p_cr_id    => null,
                             p_ra_id    => null,
                             p_adj_id   => null,
                             p_hist_id  => null,
                             p_req_id   => p_request_id);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_request_id,
                            'REQUEST_ID',
                            'RECEIPTS');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => p_request_id,
                           p_parameterlist => l_list);

     -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
      l_list.DELETE;
   END IF;
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_PostBatch_Run_Event;

PROCEDURE Raise_AutoAdj_Run_Event
 ( p_request_id  IN  NUMBER) IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50)  := 'oracle.apps.ar.batch.AutoAdjustments.run';
    l_org_id         NUMBER;
BEGIN

 --
 -- We do not need to create a history record in AR_TRX_SUMMARY_HIST for the
 -- adjustments done against the transactions because of fllowing reasons:
 -- 1) The adjustment history is stored in AR_ADJUSTMENTS table
 -- 2) AR Subscription of no other core event would look at the adjustment.

  IF p_request_id is not null  THEN
   --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                        p_request_id);

  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key=> l_key,
                             p_ps_id    => null,
                             p_ctx_id   => null,
                             p_cr_id    => null,
                             p_ra_id    => null,
                             p_adj_id   => null,
                             p_hist_id  => null,
                             p_req_id   => p_request_id);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_request_id,
                            'REQUEST_ID',
                            'ADJUSTMENTS');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => p_request_id,
                           p_parameterlist => l_list);

     -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
      l_list.DELETE;

   END IF;
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_AutoAdj_Run_Event;

PROCEDURE Raise_CopyInv_Run_Event
 ( p_request_id  IN  NUMBER) IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50) := 'oracle.apps.ar.batch.CopyInvoices.run';
    l_org_id         NUMBER;
BEGIN

  IF p_request_id is not null  THEN
   --Get the item key
   l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                        p_request_id);
  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name  => l_event_name,
                             p_event_key=> l_key,
                             p_ps_id    => null,
                             p_ctx_id   => null,
                             p_cr_id    => null,
                             p_ra_id    => null,
                             p_adj_id   => null,
                             p_hist_id  => null,
                             p_req_id   => p_request_id);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_request_id,
                            'REQUEST_ID',
                            'INVOICES');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => p_request_id,
                           p_parameterlist => l_list);

     -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );
      l_list.DELETE;
   END IF;

   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END Raise_CopyInv_Run_Event;

PROCEDURE Raise_Rcpt_Deletion_Event
 ( p_payment_schedule_id  IN  NUMBER,
   p_receipt_number	  IN  ar_cash_receipts.receipt_number%type,
   p_receipt_date	  IN  ar_cash_receipts.receipt_date%type
 ) IS
    l_list           WF_PARAMETER_LIST_T;
    l_param          WF_PARAMETER_T;
    l_key            VARCHAR2(240);
    l_exist          VARCHAR2(1);
    l_event_name     VARCHAR2(50) := 'oracle.apps.ar.receipts.CashReceipt.Delete';
    l_org_id         NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Raise_Rcpt_Deletion_Event (+)');
 END IF;
    --Get the item key
    l_key := AR_CMGT_EVENT_PKG.item_key( l_event_name ,
                                         p_payment_schedule_id);
  IF (isRefreshProgramRunning)  THEN

         insert_events_hist (p_be_name => l_event_name,
                             p_event_key => l_key,
                             p_ps_id     => p_payment_schedule_id,
                              p_ctx_id   => null,
                              p_cr_id    => null,
                              p_ra_id    => null,
                              p_adj_id   => null,
                              p_hist_id  => null,
                              p_req_id   => null);
  ELSE

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     /* 9216062 - set org based on trx */
     l_org_id := get_org_id(p_payment_schedule_id,
                            'PAYMENT_SCHEDULE_ID');

     -- Add Context values to the list
     ar_cmgt_event_pkg.AddParamEnvToList(x_list => l_list,
                                         p_org_id => l_org_id);

     -- add more parameters to the parameters list
     wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => p_payment_schedule_id,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'DELETION_DATE',
                           p_value => trunc(sysdate),
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'RECEIPT_NUMBER',
                           p_value => p_receipt_number,
                           p_parameterlist => l_list);

     wf_event.AddParameterToList(p_name => 'RECEIPT_DATE',
                           p_value => p_receipt_date,
                           p_parameterlist => l_list);
        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
  END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Raise_Rcpt_Deletion_Event (-)');
END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ERR RAISING EVENT: '||l_event_name);
  END IF;

END;

END AR_BUS_EVENT_COVER; -- Package spec

/
