--------------------------------------------------------
--  DDL for Package Body IEX_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_BUS_EVENT_SUB_PVT" AS
/* $Header: iexbsubb.pls 120.0.12010000.3 2009/08/11 11:26:05 pnaveenk ship $*/

pg_debug NUMBER := nvl(to_number(fnd_profile.value('IEX_DEBUG_LEVEL')),20);

FUNCTION isRefreshProgramsRunning RETURN BOOLEAN IS
CURSOR C1 IS
select request_id
from AR_CONC_PROCESS_REQUESTS
where CONCURRENT_PROGRAM_NAME in ('ARSUMREF','IEX_POPULATE_UWQ_SUM');
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

END isRefreshProgramsRunning;

--Function For Transactions Events. Passes trx_id

FUNCTION SYNC_SUMMARY
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS


  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  x_return_status    VARCHAR2(30);




 BEGIN

    IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.Synch_Summary Started  ' );
    END IF;

  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');




   SAVEPOINT  Event;
    IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('l_customer_trx_id= '||l_customer_trx_id);
       iex_debug_pub.LogMessage ('l_org_id= '||l_org_id);
       iex_debug_pub.LogMessage ('l_user_id= '||l_user_id);
       iex_debug_pub.LogMessage ('l_resp_id= '||l_resp_id);
       iex_debug_pub.LogMessage ('l_application_id= '||l_application_id);
       iex_debug_pub.LogMessage ('l_security_gr_id= '||l_security_gr_id);
       null;
    END IF;

   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);

  IF NOT isRefreshProgramsRunning THEN
	x_return_status := UPDATE_SUMMARY(l_customer_trx_id,l_org_id ,'INV');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.Synch_Summary Skipped ' );
   END IF;
  END IF;

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.Synch_Summary Finished  ' );
   END IF;

  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_SUMMARY', 'IEX SUMMARY', NULL);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END SYNC_SUMMARY;

--Function For Receipts Events. Passes Payment_schedule_id
FUNCTION SYNC_CASHRECEIPT
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2 IS
l_payment_schedule_id NUMBER;
  l_org_id            NUMBER;
  l_user_id           NUMBER;
  l_resp_id           NUMBER;
  l_application_id    NUMBER;
  l_cash_receipt_id  NUMBER;
l_receipt_date   DATE ;
l_receipt_amount  NUMBER;
l_receipt_number  VARCHAR2(30);
l_customer_id  NUMBER;
l_customer_site_use_id NUMBER;
l_currency_code VARCHAR2(30);
l_cust_account_id	ar_payment_schedules.customer_id%type;
l_security_gr_id   NUMBER;

x_return_status  VARCHAR2(30);
BEGIN

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CASHRECEIPT Started  ' );
   END IF;

  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  l_cust_account_id := p_event.GetValueForParameter('CUST_ACCOUNT_ID');

  --
  --set the application context.
  --
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT Pmt Sch. Id: ' || l_payment_schedule_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT cust acct Id: ' || l_cust_account_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX SYNC_CASHRECEIPT Grp Id :  ' || l_security_gr_id);
   END IF;

  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);

  IF NOT isRefreshProgramsRunning THEN
	  x_return_status := UPDATE_SUMMARY(l_payment_schedule_id,l_org_id ,'REC');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CASHRECEIPT Skipped  ' );
   END IF;
  END IF;

    IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CASHRECEIPT Finished  ' );
   END IF;


  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_SUMMARY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_CASHRECEIPT;

--Function For Credit Memo and Cash Apply. Both these events pass receivables_application_id
FUNCTION SYNC_CM
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2 IS

  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_receivable_application_id  NUMBER;
  x_return_status   VARCHAR2(30);
BEGIN

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CM Started  ' );
   END IF;

  l_receivable_application_id :=
                  p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  --
  --set the application context.
  --
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX SYNC_CM RECEIVABLE_APPLICATION_ID: ' || l_receivable_application_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX SYNC_CM Grp Id :  ' || l_security_gr_id);
   END IF;
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);

  IF NOT isRefreshProgramsRunning THEN
	x_return_status := UPDATE_SUMMARY(l_receivable_application_id,l_org_id ,'CM');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CM Skipped  ' );
   END IF;
  END IF;


 IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_CM Finished  ' );
   END IF;
  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_SUMMARY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_CM;

--Function For Adjustment Events. Passes adjustment_id

FUNCTION SYNC_ADJ
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_adjustment_id   NUMBER;
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  x_return_status   VARCHAR2(30);

BEGIN

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_ADJ Started  ' );
  END IF;
--  insert into sch_test values('IEX_BUS_EVENT_SUB_PVT.SYNC_ADJ Started  ');
  commit;
  l_adjustment_id   := p_event.GetValueForParameter('ADJUSTMENT_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX SYNC_ADJ ADJUSTMENT_ID: ' || l_adjustment_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX SYNC_CM Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX SYNC_CM Grp Id :  ' || l_security_gr_id);
   END IF;
  --
  --set the application context.
  --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  --  insert into sch_test values('initialized ');
    commit;
  IF NOT isRefreshProgramsRunning THEN
	x_return_status := UPDATE_SUMMARY(l_adjustment_id,l_org_id ,'ADJ');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_ADJ Skipped  ' );
   END IF;
  END IF;

    IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_ADJ Finished  ' );
   END IF;

   Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_SUMMARY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_ADJ;


--Function For Auto Adjustments. Passes request_id
FUNCTION SYNC_AUTOADJ
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_request_id      NUMBER;
  x_return_status  VARCHAR2(30);
BEGIN
   IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOADJ Started  ' );
   END IF;

  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  --
  --set the application context.
  --

 IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Auto Receipts Request Id: ' || l_request_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX Auto Receipts Grp Id :  ' || l_security_gr_id);
   END IF;

  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  IF NOT isRefreshProgramsRunning THEN
	 x_return_status := UPDATE_SUMMARY(l_request_id,l_org_id ,'AUTOADJ');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOADJ Skipped  ' );
   END IF;
  END IF;

    IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOADJ Finished  ' );
   END IF;


  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_ADJ', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_AUTOADJ;


--Function For AutoReceipts. Passes request_id
FUNCTION SYNC_AUTOREC
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  x_return_status  VARCHAR2(30);
BEGIN

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOREC Started  ' );
  END IF;


  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  --
  --set the application context.
  --
  IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Auto Receipts Request Id: ' || l_request_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX Auto Receipts Grp Id :  ' || l_security_gr_id);
   END IF;



  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  IF NOT isRefreshProgramsRunning THEN
	x_return_status := UPDATE_SUMMARY(l_request_id,l_org_id ,'AUTOREC');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOREC Skipped  ' );
   END IF;
  END IF;

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOREC Finished  ' );
  END IF;

  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_RECEIPTS', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_AUTOREC;


--Function For AutoInvoices. Passes request_id
FUNCTION SYNC_AUTOINV
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  x_return_status  VARCHAR2(30);
BEGIN
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOINV Started  ' );
   END IF;

  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  --
  --set the application context.
  --
 IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Auto Receipts Request Id: ' || l_request_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Org Id :' || l_org_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts User Id : ' || l_user_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Resp Id : ' || l_resp_id);
       iex_debug_pub.LogMessage ('IEX Auto Receipts Appl Id: ' || l_application_id );
       iex_debug_pub.LogMessage ('IEX Auto Receipts Grp Id :  ' || l_security_gr_id);
   END IF;
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  IF NOT isRefreshProgramsRunning THEN
	x_return_status := UPDATE_SUMMARY(l_request_id,l_org_id ,'AUTOINV');
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOINV Skipped  ' );
   END IF;
  END IF;

  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_BUS_EVENT_SUB_PVT.SYNC_AUTOINV Finished ' );
   END IF;

  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_INVOICES', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END SYNC_AUTOINV;

--Function to Synchronize IEX and AR.

FUNCTION UPDATE_SUMMARY(
id_val    IN NUMBER
,l_org_id IN NUMBER
,trx_type IN VARCHAR2
)
RETURN VARCHAR2 IS
l_customer_trx_id NUMBER;
 TYPE ps_tab_type IS TABLE OF ar_payment_schedules%rowtype
  INDEX BY BINARY_INTEGER;
  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR select_ps (cust_trx_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id;

  CURSOR select_ps_rec (l_payment_schedule_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE payment_schedule_id = l_payment_schedule_id;

  CURSOR select_ps_cm (p_ra_id  IN NUMBER ) IS
  SELECT trx_ps.*
  FROM  ar_payment_schedules trx_ps,
      ar_receivable_applications ra,
      ar_payment_schedules rcpt_ps
  WHERE ra.receivable_application_id = p_ra_id
  AND   ra.status in ('APP')
  AND   ra.payment_schedule_id = rcpt_ps.payment_schedule_id
  AND   ra.applied_payment_schedule_id = trx_ps.payment_schedule_id;

  CURSOR select_ps_adj (p_adj_id IN NUMBER) IS
  SELECT ps.*
  FROM ar_adjustments adj,
       ar_payment_schedules ps
  WHERE adj.payment_schedule_id = ps.payment_schedule_id
   and  adj.adjustment_id = p_adj_id ;

  CURSOR select_ps_auto_adj (p_req_id  IN NUMBER) IS
   SELECT ps.*
   FROM ar_adjustments adj,
        ar_payment_schedules ps
   WHERE adj.request_id = p_req_id
     and adj.payment_schedule_id = ps.payment_schedule_id;


  CURSOR select_ps_auto_rec (p_request_id IN NUMBER) IS
    SELECT ps.*
    FROM   ar_receivable_applications ra,
        ar_payment_schedules ps
    WHERE ra.request_id = p_request_id
    AND ra.status IN('APP','UNAPP')
    AND ps.payment_schedule_id = ra.applied_payment_schedule_id;

   CURSOR select_ps_auto_inv (p_request_id IN NUMBER) IS
   SELECT ps.*
   FROM ra_customer_trx trx,
       ar_payment_schedules ps
   WHERE
   trx.customer_trx_id = ps.customer_trx_id
   AND trx.request_id = p_request_id;
  --begin mls
   cursor c_uwq_level(p_account_id number) is
   select business_level
   from iex_dln_uwq_summary
   where party_id = (select party_id
                     from hz_cust_accounts
                     where cust_account_id=p_account_id);
  /*CURSOR select_pref IS SELECT PREFERENCE_VALUE FROM IEX_APP_PREFERENCES_VL
                        WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL';*/
  --end mls

  CURSOR update_iex_sum_billto(p_cust_account_id IN NUMBER,
                        p_site_use_id     IN NUMBER,
			p_org_id          IN NUMBER) IS
   SELECT
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(TRX_SUMM.PAST_DUE_INV_INST_COUNT) PAST_DUE_INV_INST_COUNT,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    (SELECT SUM(b.acctd_amount_due_remaining)
     FROM iex_delinquencies_all a,
       ar_payment_schedules_all b
     WHERE a.customer_site_use_id = trx_summ.site_use_id
     AND a.payment_schedule_id = b.payment_schedule_id
     AND b.status = 'OP'
     AND a.status IN('DELINQUENT',    'PREDELINQUENT')) past_due_inv_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    MAX(trx_summ.last_payment_date) last_payment_date,         --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
    MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   0,   trx_summ.site_use_id)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(iex_uwq_view_pkg.get_last_payment_number(0,   0,   trx_summ.site_use_id)) last_payment_number,
   trx_summ.site_use_id,
   trx_summ.org_id
   FROM AR_TRX_BAL_SUMMARY  trx_summ,
        GL_SETS_OF_BOOKS gl,
        AR_SYSTEM_PARAMETERS_all sys
    WHERE
    gl.SET_OF_BOOKS_ID             = sys.SET_OF_BOOKS_ID
    AND sys.org_id                 = trx_summ.org_id
    AND trx_summ.cust_account_id   = p_cust_account_id
    AND trx_summ.site_use_id       = p_site_use_id
    AND trx_summ.org_id            = p_org_id
    GROUP BY trx_summ.site_use_id, trx_summ.org_id;

   CURSOR update_iex_sum_acc(p_cust_account_id IN NUMBER,
			         p_org_id          IN NUMBER) IS
   SELECT
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(TRX_SUMM.PAST_DUE_INV_INST_COUNT) PAST_DUE_INV_INST_COUNT,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    (SELECT SUM(b.acctd_amount_due_remaining)
       FROM iex_delinquencies_all a,
         ar_payment_schedules_all b
       WHERE a.cust_account_id = trx_summ.cust_account_id
       AND a.payment_schedule_id = b.payment_schedule_id
       AND b.status = 'OP'
       AND a.status IN('DELINQUENT',    'PREDELINQUENT')) past_due_inv_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    MAX(trx_summ.last_payment_date) last_payment_date,                       --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
    MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   trx_summ.cust_account_id,   0)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(iex_uwq_view_pkg.get_last_payment_number(0,   trx_summ.cust_account_id,   0)) last_payment_number,
    TRX_SUMM.cust_account_id,
    TRX_SUMM.org_id
   FROM AR_TRX_BAL_SUMMARY  TRX_SUMM,
        GL_SETS_OF_BOOKS gl,
        AR_SYSTEM_PARAMETERS_all sys
    WHERE
    gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
    AND sys.org_id = trx_summ.org_id
    AND TRX_SUMM.cust_account_id = p_cust_account_id
    AND   TRX_SUMM.org_id          = p_org_id
   GROUP BY TRX_SUMM.cust_account_id,TRX_SUMM.org_id;


   CURSOR update_iex_sum_cu(p_cust_account_id IN NUMBER,
			         p_org_id          IN NUMBER) IS
   SELECT
   max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(TRX_SUMM.PAST_DUE_INV_INST_COUNT) PAST_DUE_INV_INST_COUNT,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
     (SELECT SUM(b.acctd_amount_due_remaining)
      FROM iex_delinquencies_all a,
           ar_payment_schedules_all b
      WHERE a.party_cust_id = party.party_id
      AND a.payment_schedule_id = b.payment_schedule_id
      AND b.status = 'OP'
      AND a.status IN('DELINQUENT',      'PREDELINQUENT')) past_due_inv_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    MAX(trx_summ.last_payment_date) last_payment_date,          --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
    MAX(iex_uwq_view_pkg.get_last_payment_amount(party.party_id,     0,     0)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(iex_uwq_view_pkg.get_last_payment_number(party.party_id,     0,     0)) last_payment_number,
    party.party_id party_id,
    trx_summ.org_id org_id
   FROM AR_TRX_BAL_SUMMARY   trx_summ, hz_cust_accounts acc,hz_parties party,
        GL_SETS_OF_BOOKS gl,
        AR_SYSTEM_PARAMETERS_all sys
    WHERE
    gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
    AND sys.org_id = trx_summ.org_id
    AND trx_summ.cust_account_id       = acc.cust_account_id
    AND party.party_id        = acc.party_id
    AND trx_summ.cust_account_id   = p_cust_account_id
    AND   trx_summ.org_id          = p_org_id
   GROUP BY party.party_id,trx_summ.org_id;

   L_OP_INVOICES_COUNT           NUMBER;
   L_OP_DEBIT_MEMOS_COUNT        NUMBER;
   L_OP_DEPOSITS_COUNT		 NUMBER;
   L_OP_BILLS_RECEIVABLES_COUNT  NUMBER;
   L_OP_CHARGEBACK_COUNT	 NUMBER;
   L_OP_CREDIT_MEMOS_COUNT	 NUMBER;
   L_UNRESOLVED_CASH_COUNT	 NUMBER;
   L_DISPUTED_INV_COUNT		 NUMBER;
   L_BEST_CURRENT_RECEIVABLES	 NUMBER;
   L_OP_INVOICES_VALUE		 NUMBER;
   L_OP_DEBIT_MEMOS_VALUE	 NUMBER;
   L_OP_DEPOSITS_VALUE		 NUMBER;
   L_OP_BILLS_RECEIVABLES_VALUE	 NUMBER;
   L_OP_CHARGEBACK_VALUE	 NUMBER;
   L_OP_CREDIT_MEMOS_VALUE	 NUMBER;
   L_UNRESOLVED_CASH_VALUE	 NUMBER;
   L_RECEIPTS_AT_RISK_VALUE	 NUMBER;
   L_INV_AMT_IN_DISPUTE		 NUMBER;
   L_PENDING_ADJ_VALUE		 NUMBER;
   L_PAST_DUE_INV_VALUE		 NUMBER;
   L_PAST_DUE_INV_INST_COUNT	 NUMBER;
   i                             NUMBER;
   l_pref_value                  VARCHAR2(30);
   l_ps_exists                   BOOLEAN;
   l_cash VARCHAR2(240);



BEGIN

--begin bug#6717849 31-Jul-2009 schekuri
 /*OPEN  select_pref;
 FETCH select_pref INTO l_pref_value;
 CLOSE select_pref;*/
 --end mls

-- l_cash := IEX_UTILITIES.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', 'SELECT DEFAULT_EXCHANGE_RATE_TYPE FROM AR_CMGT_SETUP_OPTIONS');
    l_cash := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate'); -- Added for bug 8630157 by PNAVEENK
 -- Invoice Events Start.

--insert into sch_test values('IEX Update Summary started for Invoice Event with id ' || id_val);
commit;

 IF (trx_type = 'INV') THEN
 IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Invoice Event with id ' || id_val);
 END IF;
 OPEN select_ps (id_val); --id_val Contains Transaction ID .
    i := 1;
   LOOP
   FETCH select_ps INTO  l_ps_tab(i);

   IF select_ps%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps;

  --Receipts.
  ELSIF (trx_type = 'REC') THEN
 IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Receipt Event with id ' || id_val);
 END IF;
   OPEN select_ps_rec (id_val); --id_val Contains Payment Schedule ID .
    i := 1;
   LOOP
   FETCH select_ps_rec INTO  l_ps_tab(i);

   IF select_ps_rec%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_rec;

  ELSIF (trx_type = 'CM') THEN
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for credit memo Event with id ' || id_val);
   END IF;
    OPEN select_ps_cm (id_val); --id_val Contains Transaction ID .
    i := 1;
   LOOP
   FETCH select_ps_cm INTO  l_ps_tab(i);

   IF select_ps_cm%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_cm;

 ELSIF (trx_type = 'ADJ') THEN
  IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Adjustment Event with id ' || id_val);
  END IF;
    OPEN select_ps_adj (id_val); --id_val Contains Adjustment ID
    i := 1;
   LOOP
   FETCH select_ps_adj INTO  l_ps_tab(i);

   IF select_ps_adj%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_adj;

  ELSIF (trx_type = 'AUTOADJ') THEN
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Auto Adjustment Event with id ' || id_val);
   END IF;
    OPEN select_ps_auto_adj (id_val); --id_val Contains Request ID
    i := 1;
   LOOP
   FETCH select_ps_auto_adj INTO  l_ps_tab(i);

   IF select_ps_auto_adj%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_auto_adj;

  ELSIF (trx_type = 'AUTOREC') THEN
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Auto Receipt Event with id ' || id_val);
   END IF;
    OPEN select_ps_auto_rec (id_val); --id_val Contains Request ID
    i := 1;
   LOOP
   FETCH select_ps_auto_rec INTO  l_ps_tab(i);

   IF select_ps_auto_rec%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_auto_rec;

  ELSIF (trx_type = 'AUTOINV') THEN
 IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary started for Auto Invoice Event with id ' || id_val);
 END IF;
    OPEN select_ps_auto_inv (id_val); --id_val Contains Request ID
    i := 1;
   LOOP
   FETCH select_ps_auto_inv INTO  l_ps_tab(i);

   IF select_ps_auto_inv%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE select_ps_auto_inv;


  END IF;


   IF l_ps_exists  THEN
    IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary l_ps_exists , Starting...' );
    END IF;
     FOR j in 1..l_ps_tab.COUNT
      LOOP

       --begin mls
       l_pref_value := null;
       open c_uwq_level(l_ps_tab(j).customer_id);
       fetch c_uwq_level into l_pref_value;
       close c_uwq_level;
       --end mls


       --Update for Strategy Level Bill To.
       IF (l_pref_value = 'BILL_TO') THEN

        FOR upd_billto in update_iex_sum_billto
	                  (l_ps_tab(j).customer_id,l_ps_tab(j).customer_site_use_id,
	                  l_org_id)
	LOOP
	 --Synchronize ar and iex summary tables

	 UPDATE iex_dln_uwq_summary
	  SET
	     OP_INVOICES_COUNT           = upd_billto.OP_INVOICES_COUNT,
	     OP_DEBIT_MEMOS_COUNT        = upd_billto.OP_DEBIT_MEMOS_COUNT,
	     OP_DEPOSITS_COUNT		 = upd_billto.OP_DEPOSITS_COUNT,
	     OP_BILLS_RECEIVABLES_COUNT  = upd_billto.OP_BILLS_RECEIVABLES_COUNT,
	     OP_CHARGEBACK_COUNT         = upd_billto.OP_CHARGEBACK_COUNT,
	     OP_CREDIT_MEMOS_COUNT       = upd_billto.OP_CREDIT_MEMOS_COUNT,
	     UNRESOLVED_CASH_COUNT       = upd_billto.UNRESOLVED_CASH_COUNT,
	     DISPUTED_INV_COUNT          = upd_billto.DISPUTED_INV_COUNT,
	     BEST_CURRENT_RECEIVABLES    = upd_billto.BEST_CURRENT_RECEIVABLES,
	     OP_INVOICES_VALUE           = upd_billto.OP_INVOICES_VALUE,
	     OP_DEBIT_MEMOS_VALUE        = upd_billto.OP_DEBIT_MEMOS_VALUE,
	     OP_DEPOSITS_VALUE		 = upd_billto.OP_DEPOSITS_VALUE,
	     OP_BILLS_RECEIVABLES_VALUE  = upd_billto.OP_BILLS_RECEIVABLES_VALUE,
	     OP_CHARGEBACK_VALUE	 = upd_billto.OP_CHARGEBACK_VALUE,
	     OP_CREDIT_MEMOS_VALUE	 = upd_billto.OP_CREDIT_MEMOS_VALUE,
	     UNRESOLVED_CASH_VALUE	 = upd_billto.UNRESOLVED_CASH_VALUE,
	     RECEIPTS_AT_RISK_VALUE	 = upd_billto.RECEIPTS_AT_RISK_VALUE,
	     INV_AMT_IN_DISPUTE		 = upd_billto.INV_AMT_IN_DISPUTE,
	     PENDING_ADJ_VALUE		 = upd_billto.PENDING_ADJ_VALUE,
	     PAST_DUE_INV_VALUE		 = upd_billto.PAST_DUE_INV_VALUE,
	     PAST_DUE_INV_INST_COUNT     = upd_billto.PAST_DUE_INV_INST_COUNT,
	     LAST_PAYMENT_DATE           = upd_billto.LAST_PAYMENT_DATE,   --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
             LAST_PAYMENT_AMOUNT         = upd_billto.LAST_PAYMENT_AMOUNT,
             LAST_PAYMENT_AMOUNT_CURR    = upd_billto.LAST_PAYMENT_AMOUNT_CURR,
             LAST_PAYMENT_NUMBER         = upd_billto.LAST_PAYMENT_NUMBER,
	     LAST_UPDATE_DATE            = SYSDATE,
	     LAST_UPDATED_BY             = FND_GLOBAL.USER_ID
           WHERE cust_account_id         = l_ps_tab(j).customer_id
            AND site_use_id              = l_ps_tab(j).customer_site_use_id
            AND org_id                   = l_org_id;
	END LOOP;

       ELSIF (l_pref_value = 'ACCOUNT') THEN --Update for Strategy Level Account
        FOR upd_acc in update_iex_sum_acc
	                  (l_ps_tab(j).customer_id,l_org_id)
	LOOP
	 --Synchronize ar and iex summary tables

	 UPDATE iex_dln_uwq_summary
	  SET
	     OP_INVOICES_COUNT           = upd_acc.OP_INVOICES_COUNT,
	     OP_DEBIT_MEMOS_COUNT        = upd_acc.OP_DEBIT_MEMOS_COUNT,
	     OP_DEPOSITS_COUNT		 = upd_acc.OP_DEPOSITS_COUNT,
	     OP_BILLS_RECEIVABLES_COUNT  = upd_acc.OP_BILLS_RECEIVABLES_COUNT,
	     OP_CHARGEBACK_COUNT         = upd_acc.OP_CHARGEBACK_COUNT,
	     OP_CREDIT_MEMOS_COUNT       = upd_acc.OP_CREDIT_MEMOS_COUNT,
	     UNRESOLVED_CASH_COUNT       = upd_acc.UNRESOLVED_CASH_COUNT,
	     DISPUTED_INV_COUNT          = upd_acc.DISPUTED_INV_COUNT,
	     BEST_CURRENT_RECEIVABLES    = upd_acc.BEST_CURRENT_RECEIVABLES,
	     OP_INVOICES_VALUE           = upd_acc.OP_INVOICES_VALUE,
	     OP_DEBIT_MEMOS_VALUE        = upd_acc.OP_DEBIT_MEMOS_VALUE,
	     OP_DEPOSITS_VALUE		 = upd_acc.OP_DEPOSITS_VALUE,
	     OP_BILLS_RECEIVABLES_VALUE  = upd_acc.OP_BILLS_RECEIVABLES_VALUE,
	     OP_CHARGEBACK_VALUE	 = upd_acc.OP_CHARGEBACK_VALUE,
	     OP_CREDIT_MEMOS_VALUE	 = upd_acc.OP_CREDIT_MEMOS_VALUE,
	     UNRESOLVED_CASH_VALUE	 = upd_acc.UNRESOLVED_CASH_VALUE,
	     RECEIPTS_AT_RISK_VALUE	 = upd_acc.RECEIPTS_AT_RISK_VALUE,
	     INV_AMT_IN_DISPUTE		 = upd_acc.INV_AMT_IN_DISPUTE,
	     PENDING_ADJ_VALUE		 = upd_acc.PENDING_ADJ_VALUE,
	     PAST_DUE_INV_VALUE		 = upd_acc.PAST_DUE_INV_VALUE,
	     PAST_DUE_INV_INST_COUNT     = upd_acc.PAST_DUE_INV_INST_COUNT,
	     LAST_PAYMENT_DATE           = upd_acc.LAST_PAYMENT_DATE,   --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
             LAST_PAYMENT_AMOUNT         = upd_acc.LAST_PAYMENT_AMOUNT,
             LAST_PAYMENT_AMOUNT_CURR    = upd_acc.LAST_PAYMENT_AMOUNT_CURR,
             LAST_PAYMENT_NUMBER         = upd_acc.LAST_PAYMENT_NUMBER,
     	     LAST_UPDATE_DATE            = SYSDATE,
	     LAST_UPDATED_BY             = FND_GLOBAL.USER_ID
           WHERE cust_account_id         = l_ps_tab(j).customer_id
            AND org_id                   = l_org_id;
	END LOOP;

       ELSIF (l_pref_value = 'CUSTOMER') then --Update for Strategy Level Customer
        FOR upd_cu in update_iex_sum_cu
	                  (l_ps_tab(j).customer_id,l_org_id)
	LOOP
	 --Synchronize ar and iex summary tables

	 UPDATE iex_dln_uwq_summary
	  SET
	     OP_INVOICES_COUNT           = upd_cu.OP_INVOICES_COUNT,
	     OP_DEBIT_MEMOS_COUNT        = upd_cu.OP_DEBIT_MEMOS_COUNT,
	     OP_DEPOSITS_COUNT		 = upd_cu.OP_DEPOSITS_COUNT,
	     OP_BILLS_RECEIVABLES_COUNT  = upd_cu.OP_BILLS_RECEIVABLES_COUNT,
	     OP_CHARGEBACK_COUNT         = upd_cu.OP_CHARGEBACK_COUNT,
	     OP_CREDIT_MEMOS_COUNT       = upd_cu.OP_CREDIT_MEMOS_COUNT,
	     UNRESOLVED_CASH_COUNT       = upd_cu.UNRESOLVED_CASH_COUNT,
	     DISPUTED_INV_COUNT          = upd_cu.DISPUTED_INV_COUNT,
	     BEST_CURRENT_RECEIVABLES    = upd_cu.BEST_CURRENT_RECEIVABLES,
	     OP_INVOICES_VALUE           = upd_cu.OP_INVOICES_VALUE,
	     OP_DEBIT_MEMOS_VALUE        = upd_cu.OP_DEBIT_MEMOS_VALUE,
	     OP_DEPOSITS_VALUE		 = upd_cu.OP_DEPOSITS_VALUE,
	     OP_BILLS_RECEIVABLES_VALUE  = upd_cu.OP_BILLS_RECEIVABLES_VALUE,
	     OP_CHARGEBACK_VALUE	 = upd_cu.OP_CHARGEBACK_VALUE,
	     OP_CREDIT_MEMOS_VALUE	 = upd_cu.OP_CREDIT_MEMOS_VALUE,
	     UNRESOLVED_CASH_VALUE	 = upd_cu.UNRESOLVED_CASH_VALUE,
	     RECEIPTS_AT_RISK_VALUE	 = upd_cu.RECEIPTS_AT_RISK_VALUE,
	     INV_AMT_IN_DISPUTE		 = upd_cu.INV_AMT_IN_DISPUTE,
	     PENDING_ADJ_VALUE		 = upd_cu.PENDING_ADJ_VALUE,
	     PAST_DUE_INV_VALUE		 = upd_cu.PAST_DUE_INV_VALUE,
	     PAST_DUE_INV_INST_COUNT     = upd_cu.PAST_DUE_INV_INST_COUNT,
	     LAST_PAYMENT_DATE           = upd_cu.LAST_PAYMENT_DATE,   --Added last payment columns for bug#5938261 by schekuri on 19-Mar-2007
             LAST_PAYMENT_AMOUNT         = upd_cu.LAST_PAYMENT_AMOUNT,
             LAST_PAYMENT_AMOUNT_CURR    = upd_cu.LAST_PAYMENT_AMOUNT_CURR,
             LAST_PAYMENT_NUMBER         = upd_cu.LAST_PAYMENT_NUMBER,
     	     LAST_UPDATE_DATE            = SYSDATE,
	     LAST_UPDATED_BY             = FND_GLOBAL.USER_ID
           WHERE party_id                = upd_cu.party_id
            AND org_id                   = l_org_id;
	END LOOP;
      END IF;

     END LOOP;

   ELSE --l_ps_exists if no payment schedule exits for the given customer_trx_id
        --then we do not update the summary table.
     null;
   END IF; --l_ps_exists
   IF pg_debug <=10
    THEN
       iex_debug_pub.LogMessage ('IEX Update Summary updated ' || sql%rowcount || ' Rows' );
    END IF;
 COMMIT;
 RETURN 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('IEX_BUS_EVENT_SUB_PVT', 'SYNC_SUMMARY', 'IEX SUMMARY', NULL);

     RETURN 'ERROR';
END UPDATE_SUMMARY;



END IEX_BUS_EVENT_SUB_PVT; -- Package spec

/
