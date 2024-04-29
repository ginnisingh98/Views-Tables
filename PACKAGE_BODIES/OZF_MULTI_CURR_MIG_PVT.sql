--------------------------------------------------------
--  DDL for Package Body OZF_MULTI_CURR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_MULTI_CURR_MIG_PVT" AS
/* $Header: ozfvmmcb.pls 120.0.12010000.2 2010/03/03 07:05:10 nepanda ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   ozf_multi_curr_mig_pvt
  --
  -- PURPOSE
  --   This package contains migration related code for sales team.
  --
  -- NOTES
  --
  -- HISTORY
  -- nirprasa      10/22/2009           Created
  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='ozf_multi_curr_mig_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12):='ozfvmmcb.pls';

--
--

FUNCTION get_functional_curr (p_org_id  NUMBER) RETURN VARCHAR2 IS

CURSOR c_functional_currency IS
  SELECT
  gs.currency_code
FROM
  gl_sets_of_books gs,
  ozf_sys_parameters_all os
WHERE
  os.set_of_books_id = gs.set_of_books_id
  AND os.org_id = p_org_id;

 l_currency_code           VARCHAR2(30);

  BEGIN
    OPEN c_functional_currency;
    FETCH c_functional_currency INTO l_currency_code;
    CLOSE c_functional_currency;
 return l_currency_code;

END get_functional_curr;

PROCEDURE Mig_Utilization_Records (x_errbuf OUT NOCOPY VARCHAR2,
                                   x_retcode OUT NOCOPY NUMBER,
				   p_debug_flag IN VARCHAR2)
 IS



  TYPE utilIdTbl            IS TABLE OF ozf_funds_utilized_all_b.utilization_id%TYPE;
  TYPE planIdTbl            IS TABLE OF ozf_funds_utilized_all_b.plan_id%TYPE;
  TYPE planCurrCodeTbl      IS TABLE OF ozf_funds_utilized_all_b.plan_currency_code%TYPE;
  TYPE fundReqCurrCodeTbl   IS TABLE OF ozf_funds_utilized_all_b.fund_request_currency_code%TYPE;
  TYPE orgIdTbl	            IS TABLE OF ozf_funds_utilized_all_b.org_id%TYPE;
  TYPE currCodeTbl	    IS TABLE OF ozf_funds_utilized_all_b.currency_code%TYPE;
  TYPE planCurrAmtTbl		IS TABLE OF ozf_funds_utilized_all_b.plan_curr_amount%TYPE;
  TYPE planCurrAmtRemTbl	IS TABLE OF ozf_funds_utilized_all_b.plan_curr_amount_remaining%TYPE;
  TYPE excTypeTbl		IS TABLE OF ozf_funds_utilized_all_b.exchange_rate_type%TYPE;
  TYPE excDateTbl		IS TABLE OF ozf_funds_utilized_all_b.exchange_rate_date%TYPE;


  l_utilIdTbl               utilIdTbl;
  l_planIdTbl               planIdTbl;
  l_planCurrCodeTbl         planCurrCodeTbl;
  l_fundReqCurrCodeTbl      fundReqCurrCodeTbl;
  l_currCodeTbl		    currCodeTbl;
  l_orgIdTbl                orgIdTbl;
  l_planCurrAmtTbl          planCurrAmtTbl;
  l_planCurrAmtRemTbl       planCurrAmtRemTbl;
  l_excTypeTbl              excTypeTbl;
  l_excDateTbl		    excDateTbl;
  l_msg_data                VARCHAR2 (32000);
  l_msg_count               NUMBER;



CURSOR c_report_header IS
select rpad('Offer Name',40, ' ') ||
       rpad('Status',10, ' ') ||
       rpad('Transaction Currency',20, ' ') ||
       rpad('Total Records',20, ' ') ||
       rpad('Total Amount',20, ' ') ||
       rpad('Fund Request Currency',20, ' ') column_val
from   DUAL;

CURSOR c_report_offers IS
SELECT  rpad(qpl.description,40, ' ')||
  rpad(off.status_code,10, ' ')||
  rpad(utiz.plan_currency_code,20, ' ')||
  rpad(count(utiz.utilization_id) ,20, ' ')||
  rpad(sum(utiz.fund_request_amount),20, ' ')||
  rpad(utiz.fund_request_currency_code ,20, ' '), utiz.plan_id
FROM
  ozf_offers off,
  qp_list_headers_all qpl,
  ozf_funds_utilized_all_b utiz
WHERE
  off.qp_list_header_id = utiz.plan_id
AND off.transaction_currency_code IS NULL
AND off.fund_request_curr_code <> utiz.plan_currency_code
AND off.QP_LIST_HEADER_ID = qpl.list_header_id
AND NVL(utiz.plan_curr_amount,0) <> 0
AND plan_type='OFFR'
AND utiz.last_updated_by = -2
GROUP BY
    qpl.description,
  off.status_code,
  utiz.fund_request_currency_code,
  utiz.plan_currency_code,
  utiz.plan_id;

CURSOR c_backup_exists IS
SELECT 1
FROM OZF_MULTI_CURR_UTIL_BCK;


TYPE reportOfferRecTbl	 IS TABLE OF VARCHAR2(32000);
l_reportOfferRecTbl reportOfferRecTbl;
l_report_header_rec c_report_header%Rowtype;
l_backup_exists             NUMBER;
l_row_count                 NUMBER;


BEGIN
 SAVEPOINT  Mig_Utilization_Records;

 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------Accruals to be Migrated for Multi Currency Report ------------------------------*');
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*--------------------------------------------------------------------------------------------------------------*');

 /*Update all 4 new columns. This will get executed only for the first time due to the where clause
   1) fund_request_amount
   2) fund_request_amount_remaining
   3) fund_request_currency_code
   4) plan_currency_code*/

   UPDATE /* PARALLEL */ ozf_funds_utilized_all_b
      SET  fund_request_amount = plan_curr_amount,
           fund_request_amount_remaining = plan_curr_amount_remaining,
           fund_request_currency_code = DECODE(plan_type,'OFFR', (SELECT NVL(transaction_currency_code,fund_request_curr_code)
                                        FROM ozf_offers
                                        WHERE qp_list_header_id=plan_id)
                              ,'CAMP', (SELECT transaction_currency_code
                                        FROM ams_campaigns_vl
                                        WHERE campaign_id = plan_id)
                              ,'CSCH', (SELECT transaction_currency_code
                                        FROM ams_campaign_schedules_vl
                                        WHERE schedule_id = plan_id)
                              ,'DELV', (SELECT transaction_currency_code
                                        FROM ams_deliverables_vl
                                        WHERE deliverable_id = plan_id)
                              ,'EVEH', (SELECT currency_code_tc
                                        FROM ams_event_headers_vl
                                        WHERE event_header_id = plan_id)
                              ,'EVEO', (SELECT currency_code_tc
                                        FROM ams_event_offers_vl
                                        WHERE event_offer_id = plan_id)
                              ,'PRIC',(SELECT currency_code
                                        FROM qp_list_headers_all
                                        WHERE list_header_id = plan_id)
               ),
           plan_currency_code = DECODE(plan_type,'OFFR',
                               DECODE(object_type,'ORDER', (SELECT header.transactional_curr_code
                                                                            FROM   oe_order_headers_all header
                                                                            WHERE  header.header_id = object_id)
                                                              ,'TP_ORDER', (SELECT line.currency_code
                                                                            FROM   ozf_resale_lines_all line
                                                                            WHERE  line.resale_line_id = object_id)
                                                              ,'INVOICE',  (SELECT invoice_currency_code
                                                                            FROM ra_customer_trx_all
                                                                            WHERE customer_trx_id = object_id)
                                                              ,'PCHO',     (SELECT currency_code
                                                                            FROM po_headers_all
                                                                            WHERE po_header_id = object_id)
                                                              ,'CM',     (SELECT invoice_currency_code
                                                                            FROM ra_customer_trx_all
                                                                            WHERE customer_trx_id = object_id)
                                                              ,'DM',     (SELECT invoice_currency_code
                                                                            FROM ra_customer_trx_all
                                                                            WHERE customer_trx_id = object_id)
                                                             ,(SELECT NVL(transaction_currency_code,fund_request_curr_code)
                                                              FROM ozf_offers
                                                              WHERE qp_list_header_id=plan_id)
                                )
                              ,'CAMP', (SELECT transaction_currency_code
                                        FROM ams_campaigns_vl
                                        WHERE campaign_id = plan_id)
                              ,'CSCH', (SELECT transaction_currency_code
                                        FROM ams_campaign_schedules_vl
                                        WHERE schedule_id = plan_id)
                              ,'DELV', (SELECT transaction_currency_code
                                        FROM ams_deliverables_vl
                                        WHERE deliverable_id = plan_id)
                              ,'EVEH', (SELECT currency_code_tc
                                        FROM ams_event_headers_vl
                                        WHERE event_header_id = plan_id)
                              ,'EVEO',(SELECT currency_code_tc
                                        FROM ams_event_offers_vl
                                        WHERE event_offer_id = plan_id)
                              ,'PRIC',(SELECT line.currency_code
                                        FROM ozf_resale_lines_all line
                                        WHERE line.resale_line_id = object_id)
               ),
           last_updated_by = -2,
           last_update_date = sysdate
      WHERE fund_request_amount IS NULL
      AND fund_request_amount_remaining IS NULL
      AND fund_request_currency_code IS NULL
      AND plan_currency_code IS NULL;

   IF p_debug_flag = 'Y' THEN
   l_row_count := sql%rowcount;
   ozf_utility_pvt.write_conc_log (' <===> mandatory columns are updated for <===>'||l_row_count||' rows updated');
   END IF;
   /* Check if any rows are updated by the first sql. If Yes (first time when conc. prog is run), then generate the
   report and re-calculate the 3 columns for which the definition has been modified
   1) plan_curr_amount
   2) plan_curr_amount_remaining
   3) exchange_rate */

   IF l_row_count > 0 THEN
	   OPEN c_report_header;
	   FETCH c_report_header INTO l_report_header_rec;
	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_report_header_rec.column_val);
	   CLOSE c_report_header;

	   IF p_debug_flag = 'Y' THEN
	   ozf_utility_pvt.write_conc_log (' <===> Report Header Added <===>');
	   END IF;

	   OPEN c_report_offers;
	   FETCH c_report_offers BULK COLLECT INTO l_reportOfferRecTbl,l_planIdTbl;
	   FOR t_i IN NVL(l_planIdTbl.FIRST, 1) .. NVL(l_planIdTbl.LAST, 0)
	       LOOP
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_reportOfferRecTbl(t_i));
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*--------------------------------------------------------------------------------------------------------------*');
	       END LOOP;
	   CLOSE c_report_offers;

	   IF p_debug_flag = 'Y' THEN
	   ozf_utility_pvt.write_conc_log (' <===> Report Completed <===>');
	   END IF;

	   INSERT INTO OZF_MULTI_CURR_UTIL_BCK (SELECT utilization_id,
						plan_curr_amount,
						plan_curr_amount_remaining,
						exchange_rate
						FROM ozf_funds_utilized_all_b
						WHERE NVL(plan_curr_amount,0) <> 0
						AND plan_currency_code <> (SELECT fund_request_curr_code FROM ozf_offers WHERE qp_list_header_id=plan_id AND transaction_currency_code IS NULL)
						AND plan_type='OFFR'
						AND last_updated_by = -2);

	   IF p_debug_flag = 'Y' THEN
	   ozf_utility_pvt.write_conc_log (' <===> Backup Completed <===>'||sql%rowcount||' rows inserted');
	   END IF;

	   UPDATE /* PARALLEL */ ozf_funds_utilized_all_b
	   SET plan_curr_amount = gl_currency_api.convert_closest_amount_sql(fund_request_currency_code,plan_currency_code,
						   exchange_rate_date,exchange_rate_type,NULL,fund_request_amount,-1),
	       plan_curr_amount_remaining = gl_currency_api.convert_closest_amount_sql(fund_request_currency_code,plan_currency_code,
						   exchange_rate_date,exchange_rate_type,NULL,fund_request_amount_remaining,-1),
	       exchange_rate = gl_currency_api.get_closest_rate(plan_currency_code,get_functional_curr(org_id),exchange_rate_date,exchange_rate_type,0),
	       last_updated_by = -2,
	       last_update_date = sysdate
	   WHERE plan_currency_code <> (SELECT fund_request_curr_code FROM ozf_offers WHERE qp_list_header_id=plan_id AND transaction_currency_code IS NULL)
	   AND NVL(plan_curr_amount,0) <> 0
	   AND plan_type='OFFR'
	   AND last_updated_by = -2;

	   IF p_debug_flag = 'Y' THEN
	   ozf_utility_pvt.write_conc_log (' <===> Update for plan_curr_amount/remaining exchange_rate Completed <===>'||sql%rowcount||' rows updated');
	   END IF;

   END IF;


   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO Mig_Utilization_Records;
	 ozf_utility_pvt.write_conc_log('    Mig_Utilization_Records: exception '||SQLERRM);
         fnd_msg_pub.count_and_get (
            p_count=> l_msg_count,
            p_data=> l_msg_data,
            p_encoded=> fnd_api.g_false
         );

      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO Mig_Utilization_Records;
	 ozf_utility_pvt.write_conc_log('    Mig_Utilization_Records: exception2 '||SQLERRM);
         fnd_msg_pub.count_and_get (
            p_count=> l_msg_count,
            p_data=> l_msg_data,
            p_encoded=>fnd_api.g_false
         );
     WHEN OTHERS THEN
       ROLLBACK TO Mig_Utilization_Records;
       ozf_utility_pvt.write_conc_log('    Mig_Utilization_Records: exception '||SQLERRM);
       fnd_msg_pub.count_and_get (
            p_count=> l_msg_count,
            p_data=> l_msg_data,
            p_encoded=> fnd_api.g_false
      );
      FOR I IN 1..l_msg_count LOOP
      ozf_utility_pvt.write_conc_log(SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254));
      END LOOP;

END Mig_Utilization_Records;

END ozf_multi_curr_mig_pvt;

/
