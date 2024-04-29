--------------------------------------------------------
--  DDL for Package Body POA_PORTAL_POPULATE_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_PORTAL_POPULATE_C" AS
/* $Header: poaporsb.pls 120.0 2005/06/01 15:18:56 appldev noship $ */

procedure populate_poa  (Errbuf	in out NOCOPY Varchar2,
		 	 Retcode in out NOCOPY Varchar2) IS

  	cycq_start 	DATE :=NULL;
  	cycq_end   	DATE :=NULL;
  	lycq_start    	DATE :=NULL;
	lycq_end   	DATE :=NULL;
	l_number1	NUMBER;
	l_number2	NUMBER;
	l_number3	NUMBER;
	l_number4	NUMBER;
	l_number5	NUMBER;
	l_number6	NUMBER;
	success		VARCHAR2(50);

BEGIN
	truncate_tables(1, success);
	--dbms_output.put_line('Tables were truncated = ' || success);

	cycq_start := FII_TIME_WH_API.ent_cycq_start;
	cycq_end := fii_time_wh_api.today;

	lycq_start := FII_TIME_WH_API.ent_lycq_start;
	lycq_end := FII_TIME_WH_API.ent_lycq_today1;

	insert_rows_pd(cycq_start, cycq_end, 'C', l_number1, success);
	--dbms_output.put_line(
	--	'PD: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number1 || ':' || success);

	insert_rows_pd(lycq_start, lycq_end, 'L', l_number2, success);
	--dbms_output.put_line(
	--	'PD: ' || lycq_start || ' to ' || lycq_end || ': Rows= ' || l_number2 || ':' || success);

	insert_rows_sp(cycq_start, cycq_end, l_number3, success);
	--dbms_output.put_line(
	--	'SP: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number3 || ':' || success);

        insert_rows_sr(cycq_start, cycq_end, l_number4, success);
        --dbms_output.put_line(
        --      'SR: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number1 || ':' || success);

        insert_rows_cm(cycq_start, cycq_end, l_number5, success);
        --dbms_output.put_line(
        --      'CM: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number5 || ':' || success);

        insert_rows_rcv(cycq_start, cycq_end, l_number6, success);
        --dbms_output.put_line(
        --      'CM: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number6 || ':' || success);

	Errbuf := 'PD_C: '||l_number1 || '; PD_L: '||l_number2 ||
                  '; SP: '||l_number3 || ': SR: ' ||l_number4  ||
                  '; CM: '||l_number5 || ': RCV: ' ||l_number6;

EXCEPTION
   WHEN OTHERS THEN
	Errbuf := 'Error in main: ' || SQLERRM;
	Raise;

end populate_poa;


PROCEDURE truncate_tables (p_type IN NUMBER,
			   success OUT NOCOPY VARCHAR2) IS

  l_poa_schema          VARCHAR2(30);
  l_stmt                VARCHAR2(200);
  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);

 BEGIN

  IF (p_type = 1) THEN

      IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_PDIST';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_PDIST1';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_PDIST2';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_SPERF';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_RISK_IND';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_RISK_SUMMARY';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_SUP_RISK';
         EXECUTE IMMEDIATE l_stmt;
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_PORTAL_RCPT_SUM';
         EXECUTE IMMEDIATE l_stmt;
      END IF;

   END IF;

   IF (p_type = 2) THEN
      IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry,
                                         l_poa_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||
                   '.POA_PORTAL_FII_SUMMARY';
         EXECUTE IMMEDIATE l_stmt;
      END IF;

   END IF;

   success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
	success := 'Error in truncate: ' || SQLERRM;
	RAISE;
end truncate_tables;


PROCEDURE insert_rows_sp(	p_start   IN DATE,
				p_end     IN DATE,
				p_count   OUT NOCOPY NUMBER,
				success   OUT NOCOPY varchar2) IS
BEGIN

	INSERT into POA_PORTAL_SPERF (
	   	NUM_LATE_RCPT,
	   	NUM_RCPT_LINES,
                AVG_Rcpt_Late_Days,
                Max_Days_Lt,
                Late_Rcpt_Amount,
                Supplier_PK_Key,
                Supplier_Name,
	   	OPERATING_UNIT_PK_KEY,
           	OPERATING_UNIT_NAME)
	SELECT 	0,
		count(rcv.rcv_txn_pk),
                0, 0, 0,
                tp.tprt_trade_partner_pk_key,
                tp.tprt_name,
		org.oper_operating_unit_pk_key,
	  	org.oper_name
	FROM	poa_edw_rcv_txns_f rcv,
		edw_organization_m org,
                edw_trd_partner_m  tp,
		edw_lookup_m lku,
                edw_time_m         time
	WHERE	rcv.RCV_DEL_TO_ORG_FK_KEY = org.ORGA_ORGANIZATION_PK_KEY
          and   rcv.Supplier_Site_FK_Key = tp.TPLO_TPARTNER_LOC_PK_KEY
          and   rcv.TXN_CREAT_FK_KEY = time.CDAY_CAL_DAY_PK_KEY
	  and   rcv.txn_type_fk_key = lku.lucd_lookup_code_pk_key
	  and   lku.LUCD_LOOKUP_CODE = 'RECEIVE'
          and   time.CDAY_CALENDAR_DATE between FII_TIME_WH_API.ent_cycq_start
                                            and FII_TIME_WH_API.today
	GROUP BY org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
                 tp.TPRT_Trade_Partner_PK_Key, tp.TPRT_NAME
        UNION ALL
        SELECT  count(sp.num_late_receipt),
                0,
                avg(FII_TIME_WH_API.today-time.CDAY_CALENDAR_DATE),
                max(FII_TIME_WH_API.today-time.CDAY_CALENDAR_DATE),
                sum((sp.Qty_Ordered_B-sp.Qty_Received_B)*sp.Price_G),
                tp.tprt_trade_partner_pk_key,
                tp.tprt_name,
                org.oper_operating_unit_pk_key,
                org.oper_name
        FROM    poa_edw_sup_perf_f sp,
                edw_organization_m org,
                edw_trd_partner_m  tp,
                edw_time_m         time
        WHERE   ((sp.Qty_Ordered_B-sp.Qty_Received_B) > 0)
          and   sp.SHIP_TO_ORG_FK_KEY = org.ORGA_ORGANIZATION_PK_KEY
          and   sp.Supplier_Site_FK_Key = tp.TPLO_TPARTNER_LOC_PK_KEY
          and   sp.Promised_Date_FK_Key = time.CDAY_CAL_DAY_PK_KEY
          and   time.CDAY_CALENDAR_DATE < FII_TIME_WH_API.today
        GROUP BY org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
                 tp.TPRT_Trade_Partner_PK_Key, tp.TPRT_NAME;

    p_count := sql%rowcount;

    success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
	success := 'Error in insert_sp: ' || SQLERRM;
	RAISE;
end insert_rows_sp;


PROCEDURE populate_poa_fii (	Errbuf	in out NOCOPY Varchar2,
		  		Retcode	in out NOCOPY Varchar2) IS

  	cycq_start 	DATE :=NULL;
  	cycq_end   	DATE :=NULL;
	l_number	NUMBER;
	success		VARCHAR2(50);

BEGIN
	truncate_tables(2, success);
	--dbms_output.put_line('Tables were truncated = ' || success);

	cycq_start := FII_TIME_WH_API.ent_cycq_start;
	cycq_end := fii_time_wh_api.today;

	insert_rows_cross(cycq_start, cycq_end, l_number, success);
	--dbms_output.put_line(
	--	'CR: ' || cycq_start || ' to ' || cycq_end || ': Rows= ' || l_number || ':' || success);

	Errbuf := 'POA_FII: '|| l_number;

EXCEPTION
   WHEN OTHERS THEN
	Errbuf := 'Error in main: ' || SQLERRM;
	Raise;

end populate_poa_fii;


PROCEDURE insert_rows_cross(	p_start   IN DATE,
				p_end     IN DATE,
				p_count   OUT NOCOPY NUMBER,
				success   OUT NOCOPY varchar2) IS
BEGIN

   INSERT INTO POA_PORTAL_FII_SUMMARY(
	OPERATING_UNIT_PK_KEY		,
 	OPERATING_UNIT_NAME		,
	LATE_RECEIPTS			,
        LATE_RECEIPTS_AVG_AGE           ,
	RECEIPT_LINES_COUNT		,
 	PO_LINE_COUNT			,
 	PO_CYCLE_TIME_AVG		,
	INVOICE_LINES_COUNT		,
	PAYMENT_LINES_COUNT		,
	OPEN_PAYMENTS			,
	OPEN_PAY_AGE			,
 	CNT_LATE_SUPPLIER_CONF		,
 	AVG_LATE_SUP_CONF_AGE)
   SELECT ou_pk_key,
	  ou_name,
	  sum(late_receipts),
          avg(Late_Receipts_Avg_Age),
	  sum(receipt_lines),
	  sum(po_lines),
	  sum(cycle_time),
	  sum(invoice_lines),
	  sum(payment_lines),
	  sum(open_payments),
	  sum(open_pay_age),
	  sum(late_supplier_conf),
	  sum(late_conf_age)
   FROM (select operating_unit_pk_key ou_pk_key,
		operating_unit_name ou_name,
		sum(num_late_rcpt) late_receipts,
                avg(AVG_Rcpt_Late_Days) Late_Receipts_Avg_Age,
		sum(num_rcpt_lines) receipt_lines,
		0 po_lines,
		0 cycle_time,
		0 invoice_lines,
		0 payment_lines,
		0 open_payments,
		0 open_pay_age,
		0 late_supplier_conf,
		0 late_conf_age
	 from   poa_portal_sperf
	 group by operating_unit_pk_key,
		  operating_unit_name
	UNION ALL
       select operating_unit_pk_key,
                operating_unit_name,
                0,
                0,
                0,
                sum(cnt_po_lines),
                decode(sum(weight_avg_cycle),0,0,
                       sum(avg_cycle_time*weight_avg_cycle)/
                       sum(weight_avg_cycle)),
                0,
                0,
                0,
                0,
                0,
                0
        from   poa_portal_pdist
         where  Quarter = 'C'
         group by operating_unit_pk_key,
                  operating_unit_name
        UNION ALL
        select operating_unit_pk_key,
		operating_unit_name,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		sum(cnt_late_supplier_conf),
		avg(AVG_LATE_SUP_CONF_AGE)
	 from  	poa_portal_pdist
         where  Quarter = 'C'
           and  AVG_LATE_SUP_CONF_AGE <> 0
   	 group by operating_unit_pk_key,
		  operating_unit_name
	UNION ALL
        select operating_unit_pk_key,
	  	operating_unit_name,
		0,
		0,
		0,
		0,
		0,
		sum(inv_lines_count) invoice_lines,
       		sum(inv_payment_count) payment_lines,
		0,
		0,
		0,
		0
	 from fii_ap_op_indicator_summary
	 group by operating_unit_pk_key,
                  operating_unit_name
	UNION ALL
	select operating_unit_pk_key,
       		operating_unit_name,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
       		count(sch_payment_id) open_payments,
       		round(avg(fii_time_wh_api.today-payment_due_date)) open_pay_age,
		0,
		0
	 from fii_ap_trans_backlog_summary
	 group by operating_unit_pk_key,
		  operating_unit_name)
	GROUP BY ou_name, ou_pk_key;

    p_count := sql%rowcount;

    success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
	success := 'Error in insert_pd: ' || SQLERRM;
	RAISE;
end insert_rows_cross;


PROCEDURE insert_rows_pd(	p_start   IN DATE,
				p_end     IN DATE,
				p_quarter IN VARCHAR2,
				p_count   OUT NOCOPY NUMBER,
				success   OUT NOCOPY varchar2) IS
BEGIN

   insert into POA_PORTAL_PDIST (
      SUM_PURCHASES,
      SUM_LEAKAGE,
      SUM_NON_CONTRACT,
      SUM_CONTRACT,
      OPERATING_UNIT_PK_KEY,
      OPERATING_UNIT_NAME,
      ORGANIZATION_PK_KEY,
      ORGANIZATION_NAME,
      CATEGORY_PK_KEY,
      CATEGORY_NAME,
      SUPPLIER_PK_KEY,
      SUPPLIER_NAME,
      AVG_CYCLE_TIME,
      CNT_PO_LINES,
      CNT_PO_HEADERS,
      SUM_LATE_PURCHASES,
      CNT_LATE_SUPPLIER_CONF,
      AVG_LATE_SUP_CONF_AGE,
      WEIGHT_AVG_CYCLE,
      WEIGHT_AVG_CONF,
      POS_POTENTIAL_SVG,
      NEG_POTENTIAL_SVG,
      QUARTER,
      ITEM_PURCHASABLE_FLAG)
   select sum(pod.amt_purchased_g),
          sum(pod.amt_leakage_g),
          sum(pod.amt_noncontract_g),
          sum(pod.amt_contract_g),
          org.oper_operating_unit_pk_key,
	  org.oper_name,
          org.Orga_Organization_PK_Key,
          org.Orga_Name,
          item.ci11_category_pk_key,
	  item.ci11_name,
          tp.tprt_trade_partner_pk_key,
          tp.tprt_name,
          avg(pod.po_creation_cycle_time),
	  count(distinct po_line_id || '-' || po_app_date_fk_key),
          count(distinct po_header_id || '-' || po_app_date_fk_key),
          0,
	  0,
          0,
          count(*),
          sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                          time3.CDAY_CALENDAR_DATE),1,1,0)),
          sum(greatest(pod.Potential_Svg_G,0)),
          sum(least(pod.Potential_Svg_G,0)),
	  p_quarter,
          item.IORG_Purchaseable_Flag
     from poa_edw_po_dist_f  pod,
          edw_items_m        item,
          edw_organization_m org,
          edw_trd_partner_m  tp,
          edw_time_m         time1,
	  edw_time_m	     time2,
	  edw_time_m         time3
    where pod.ITEM_FK_KEY = item.IREV_ITEM_REVISION_PK_KEY
      and pod.SHIP_TO_ORG_FK_KEY = org.ORGA_ORGANIZATION_PK_KEY
      and pod.SUPPLIER_SITE_FK_KEY = tp.TPLO_TPARTNER_LOC_PK_KEY
      and pod.PO_APP_DATE_FK_KEY = time1.CDAY_CAL_DAY_PK_KEY
      and time1.CDAY_CALENDAR_DATE between p_start and p_end
      and pod.PO_ACCEPT_DATE_FK_KEY = time2.CDAY_CAL_DAY_PK_KEY
      and pod.ACCPT_DUE_DATE_FK_KEY = time3.CDAY_CAL_DAY_PK_KEY
    group by org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
             org.Orga_Organization_PK_Key, org.Orga_Name,
             item.Ci11_Category_PK_Key, item.CI11_NAME,
             tp.TPRT_Trade_Partner_PK_Key, tp.TPRT_NAME,
             item.IORG_Purchaseable_Flag
    UNION ALL
    select 0, 0, 0, 0,
          org.oper_operating_unit_pk_key,
          org.oper_name,
          org.Orga_Organization_PK_Key,
          org.Orga_Name,
          item.ci11_category_pk_key,
          item.ci11_name,
          tp.tprt_trade_partner_pk_key,
          tp.tprt_name,
          0, 0, 0,
          sum(pod.amt_purchased_g),
          count(*),
          avg(fii_time_wh_api.today-time2.CDAY_CALENDAR_DATE),
          0, 0, 0, 0,
          p_quarter,
          item.IORG_Purchaseable_Flag
     from poa_edw_po_dist_f  pod,
          edw_items_m        item,
          edw_organization_m org,
          edw_trd_partner_m  tp,
          edw_time_m         time1,
          edw_time_m         time2
    where pod.ITEM_FK_KEY = item.IREV_ITEM_REVISION_PK_KEY
      and pod.SHIP_TO_ORG_FK_KEY = org.ORGA_ORGANIZATION_PK_KEY
      and pod.SUPPLIER_SITE_FK_KEY = tp.TPLO_TPARTNER_LOC_PK_KEY
      and pod.PO_APP_DATE_FK_KEY = time1.CDAY_CAL_DAY_PK_KEY
      and time1.CDAY_CALENDAR_DATE between p_start and p_end
      and pod.PO_ACCEPT_DATE_FK_KEY = 0
      and pod.ACCPT_DUE_DATE_FK_KEY <> 0
      and pod.ACCPT_DUE_DATE_FK_KEY = time2.CDAY_CAL_DAY_PK_KEY
      and time2.CDAY_CALENDAR_DATE < fii_time_wh_api.today
    group by org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
             org.Orga_Organization_PK_Key, org.Orga_Name,
             item.Ci11_Category_PK_Key, item.CI11_NAME,
             tp.TPRT_Trade_Partner_PK_Key, tp.TPRT_NAME,
             item.IORG_Purchaseable_Flag;

    p_count := sql%rowcount;

    insert into POA_PORTAL_PDIST1 (
      SUM_PURCHASES,
      SUM_LEAKAGE,
      SUM_NON_CONTRACT,
      SUM_CONTRACT,
      CATEGORY_PK_KEY,
      CATEGORY_NAME,
      ITEM_PK_KEY,
      ITEM_NAME,
      AVG_CYCLE_TIME,
      CNT_PO_LINES,
      CNT_PO_HEADERS,
      CNT_LATE_SUPPLIER_CONF,
      AVG_LATE_SUP_CONF_AGE,
      WEIGHT_AVG_CYCLE,
      WEIGHT_AVG_CONF,
      QUARTER,
      ITEM_PURCHASABLE_FLAG)
   select sum(pod.amt_purchased_g),
          sum(pod.amt_leakage_g),
          sum(pod.amt_noncontract_g),
          sum(pod.amt_contract_g),
          item.ci11_category_pk_key,
          item.ci11_name,
          item.Item_Item_Number_PK_Key,
          item.ITEM_ITEM_NAME,
          avg(pod.po_creation_cycle_time),
          count(distinct po_line_id || '-' || po_app_date_fk_key),
          count(distinct po_header_id || '-' || po_app_date_fk_key),
          sum(decode(sign(time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE),
                     1,1,0)),
          decode(sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                 time3.CDAY_CALENDAR_DATE),1,1,0)),
                0,0,
                sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                time3.CDAY_CALENDAR_DATE),1,
                time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE,0)) /
                sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                time3.CDAY_CALENDAR_DATE),1,1,0))),
          count(*),
          sum(decode(sign(time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE),
                     1,1,0)),
          p_quarter,
          item.IORG_Purchaseable_Flag
     from poa_edw_po_dist_f  pod,
          edw_items_m        item,
          edw_time_m         time1,
          edw_time_m         time2,
          edw_time_m         time3
    where pod.ITEM_FK_KEY = item.IREV_ITEM_REVISION_PK_KEY
      and pod.PO_APP_DATE_FK_KEY = time1.CDAY_CAL_DAY_PK_KEY
      and time1.CDAY_CALENDAR_DATE between p_start and p_end
      and pod.PO_ACCEPT_DATE_FK_KEY = time2.CDAY_CAL_DAY_PK_KEY
      and pod.ACCPT_DUE_DATE_FK_KEY = time3.CDAY_CAL_DAY_PK_KEY
    group by item.Ci11_Category_PK_Key, item.CI11_NAME,
             item.Item_Item_Number_PK_Key, item.ITEM_ITEM_NAME,
             item.IORG_Purchaseable_Flag;

    p_count := p_count + sql%rowcount;

    insert into POA_PORTAL_PDIST2  (
      SUM_PURCHASES,
      SUM_LEAKAGE,
      SUM_NON_CONTRACT,
      SUPPLIER_PK_KEY,
      SUPPLIER_NAME,
      SUPPLIER_SITE_PK_KEY,
      SUPPLIER_SITE_NAME,
      AVG_CYCLE_TIME,
      CNT_PO_LINES,
      CNT_PO_HEADERS,
      CNT_LATE_SUPPLIER_CONF,
      AVG_LATE_SUP_CONF_AGE,
      WEIGHT_AVG_CYCLE,
      WEIGHT_AVG_CONF,
      QUARTER,
      ITEM_PURCHASABLE_FLAG)
   select sum(pod.amt_purchased_g),
          sum(pod.amt_leakage_g),
          sum(pod.amt_noncontract_g),
          tp.tprt_trade_partner_pk_key,
          tp.tprt_name,
          tp.TPLO_TPartner_Loc_PK_Key,
          tp.TPLO_NAME,
          avg(pod.po_creation_cycle_time),
          count(distinct po_line_id || '-' || po_app_date_fk_key),
          count(distinct po_header_id || '-' || po_app_date_fk_key),
          sum(decode(sign(time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE),
                     1,1,0)),
          decode(sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                 time3.CDAY_CALENDAR_DATE),1,1,0)),
                0,0,
                sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                time3.CDAY_CALENDAR_DATE),1,
                time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE,0)) /
                sum(decode(sign(time2.CDAY_CALENDAR_DATE-
                                time3.CDAY_CALENDAR_DATE),1,1,0))),
          count(*),
          sum(decode(sign(time2.CDAY_CALENDAR_DATE-time3.CDAY_CALENDAR_DATE),
                     1,1,0)),
          p_quarter,
          item.IORG_Purchaseable_Flag
     from poa_edw_po_dist_f  pod,
          edw_trd_partner_m  tp,
          edw_time_m         time1,
          edw_time_m         time2,
          edw_time_m         time3,
           edw_items_m        item
    where pod.SUPPLIER_SITE_FK_KEY = tp.TPLO_TPARTNER_LOC_PK_KEY
      and pod.ITEM_FK_KEY = item.IREV_ITEM_REVISION_PK_KEY
      and pod.PO_APP_DATE_FK_KEY = time1.CDAY_CAL_DAY_PK_KEY
      and time1.CDAY_CALENDAR_DATE between p_start and p_end
      and pod.PO_ACCEPT_DATE_FK_KEY = time2.CDAY_CAL_DAY_PK_KEY
      and pod.ACCPT_DUE_DATE_FK_KEY = time3.CDAY_CAL_DAY_PK_KEY
    group by tp.tprt_trade_partner_pk_key, tp.tprt_name,
             tp.TPLO_TPartner_Loc_PK_Key, tp.TPLO_NAME,
             item.IORG_Purchaseable_Flag;
    success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
	success := 'Error in insert_pd: ' || SQLERRM;
	RAISE;
end insert_rows_pd;


PROCEDURE insert_rows_sr(       p_start   IN DATE,
                                p_end     IN DATE,
                                p_count   OUT NOCOPY NUMBER,
                                success   OUT NOCOPY varchar2) IS
BEGIN
   insert into POA_PORTAL_RISK_SUMMARY (
      Status,
      Risk_Category,
      Supplier_PK_Key,
      Supplier_Name,
      Total_Range_Low,
      Total_Range_High,
      Price_Range_Low,
      Price_Range_High,
      Quality_Range_Low,
      Quality_Range_High,
      Delivery_Range_Low,
      Delivery_Range_High,
      Service_Range_Low,
      Service_Range_High,
      Total_Score,
      Price_Score,
      Quality_Score,
      Delivery_Score,
      Service_Score,
      Purchase_Amount)
      select 'Problem Suppliers', 1,
             Supplier.tprt_trade_partner_pk_key,
             Supplier.tprt_name,
             POA_PORTAL_SUP_RISK_IND.get_range1_low(1),
             POA_PORTAL_SUP_RISK_IND.get_range1_high(1),
             POA_PORTAL_SUP_RISK_IND.get_range1_low(2),
             POA_PORTAL_SUP_RISK_IND.get_range1_high(2),
             POA_PORTAL_SUP_RISK_IND.get_range1_low(3),
             POA_PORTAL_SUP_RISK_IND.get_range1_high(3),
             POA_PORTAL_SUP_RISK_IND.get_range1_low(4),
             POA_PORTAL_SUP_RISK_IND.get_range1_high(4),
             POA_PORTAL_SUP_RISK_IND.get_range1_low(5),
             POA_PORTAL_SUP_RISK_IND.get_range1_high(5),
             decode(sign(round(avg(Total_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range1_low(1)),
                    -1,-999,
                    0, avg(Total_Score),
                    1, decode(sign(round(avg(Total_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range1_high(1)),
                    -1, avg(Total_Score),
                    0, avg(Total_Score), -999)),
             decode(sign(round(avg(Price_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range1_low(2)),
                    -1,-999,
                    0, avg(Price_Score),
                    1, decode(sign(round(avg(Price_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range1_high(2)),
                    -1, avg(Price_Score),
                    0, avg(Price_Score), -999)),
             decode(sign(round(avg(Quality_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range1_low(3)),
                    -1,-999,
                    0, avg(Quality_Score),
                    1, decode(sign(round(avg(Quality_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range1_high(3)),
                    -1, avg(Quality_Score),
                    0, avg(Quality_Score), -999)),
             decode(sign(round(avg(Delivery_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range1_low(4)),
                    -1,-999,
                    0, avg(Delivery_Score),
                    1, decode(sign(round(avg(Delivery_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range1_high(4)),
                    -1, avg(Delivery_Score),
                   0, avg(Delivery_Score), -999)),
             decode(sign(round(avg(Survey_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range1_low(5)),
                    -1,-999,
                    0, avg(Survey_Score),
                    1, decode(sign(round(avg(Survey_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range1_high(5)),
                    -1, avg(Survey_Score),
                   0, avg(Survey_Score), -999)),
           sum(pod.amt_purchased_g)
      from poa_edw_po_dist_f  pod,
           (select Supplier_Site,
                   avg(NVL(Price_Score,25) +
                       NVL(Quality_Score,25) +
                       NVL(Delivery_Score,25) +
                       NVL(Survey_Score,25)) Total_Score,
                   avg(NVL(Price_Score,25)) Price_Score,
                   avg(NVL(Quality_Score,25)) Quality_Score,
                   avg(NVL(Delivery_Score,25)) Delivery_Score,
                   avg(NVL(Survey_Score,25)) Survey_Score from
            POA_REP_SUP_SCORE_V
            group by Supplier_Site) Cstm_Msr,
           EDW_TRD_Partner_M Supplier
      where pod.SUPPLIER_SITE_FK_KEY = Supplier.TPLO_TPartner_Loc_PK_Key
        and pod.SUPPLIER_SITE_FK_KEY = Cstm_Msr.Supplier_Site
      group by Supplier.tprt_trade_partner_pk_key,
               Supplier.tprt_name;

   p_count := sql%rowcount;

   insert into POA_PORTAL_RISK_SUMMARY (
      Status,
      Risk_Category,
      Supplier_PK_Key,
      Supplier_Name,
      Total_Range_Low,
      Total_Range_High,
      Price_Range_Low,
      Price_Range_High,
      Quality_Range_Low,
      Quality_Range_High,
      Delivery_Range_Low,
      Delivery_Range_High,
      Service_Range_Low,
      Service_Range_High,
      Total_Score,
      Price_Score,
      Quality_Score,
      Delivery_Score,
      Service_Score,
      Purchase_Amount)
      select 'At Risk Suppliers', 2,
            Supplier.tprt_trade_partner_pk_key,
             Supplier.tprt_name,
             POA_PORTAL_SUP_RISK_IND.get_range2_low(1),
             POA_PORTAL_SUP_RISK_IND.get_range2_high(1),
             POA_PORTAL_SUP_RISK_IND.get_range2_low(2),
             POA_PORTAL_SUP_RISK_IND.get_range2_high(2),
             POA_PORTAL_SUP_RISK_IND.get_range2_low(3),
             POA_PORTAL_SUP_RISK_IND.get_range2_high(3),
             POA_PORTAL_SUP_RISK_IND.get_range2_low(4),
             POA_PORTAL_SUP_RISK_IND.get_range2_high(4),
             POA_PORTAL_SUP_RISK_IND.get_range2_low(5),
             POA_PORTAL_SUP_RISK_IND.get_range2_high(5),
             decode(sign(round(avg(Total_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range2_low(1)),
                    -1,-999,
                    0, avg(Total_Score),
                    1, decode(sign(round(avg(Total_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range2_high(1)),
                    -1, avg(Total_Score),
                    0, avg(Total_Score), -999)),
             decode(sign(round(avg(Price_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range2_low(2)),
                    -1,-999,
                    0, avg(Price_Score),
                    1, decode(sign(round(avg(Price_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range2_high(2)),
                    -1, avg(Price_Score),
                    0, avg(Price_Score), -999)),
             decode(sign(round(avg(Quality_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range2_low(3)),
                    -1,-999,
                    0, avg(Quality_Score),
                    1, decode(sign(round(avg(Quality_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range2_high(3)),
                    -1, avg(Quality_Score),
                    0, avg(Quality_Score), -999)),
             decode(sign(round(avg(Delivery_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range2_low(4)),
                    -1,-999,
                    0, avg(Delivery_Score),
                    1, decode(sign(round(avg(Delivery_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range2_high(4)),
                    -1, avg(Delivery_Score),
                   0, avg(Delivery_Score), -999)),
             decode(sign(round(avg(Survey_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range2_low(5)),
                    -1,-999,
                    0, avg(Survey_Score),
                    1, decode(sign(round(avg(Survey_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range2_high(5)),
                    -1, avg(Survey_Score),
                   0, avg(Survey_Score), -999)),
           sum(pod.amt_purchased_g)
      from poa_edw_po_dist_f  pod,
           (select Supplier_Site,
                   avg(NVL(Price_Score,25) +
                       NVL(Quality_Score,25) +
                       NVL(Delivery_Score,25) +
                       NVL(Survey_Score,25)) Total_Score,
                   avg(NVL(Price_Score,25)) Price_Score,
                   avg(NVL(Quality_Score,25)) Quality_Score,
                   avg(NVL(Delivery_Score,25)) Delivery_Score,
                   avg(NVL(Survey_Score,25)) Survey_Score from
            POA_REP_SUP_SCORE_V
            group by Supplier_Site) Cstm_Msr,
           EDW_TRD_Partner_M Supplier
      where pod.SUPPLIER_SITE_FK_KEY = Supplier.TPLO_TPartner_Loc_PK_Key
        and pod.SUPPLIER_SITE_FK_KEY = Cstm_Msr.Supplier_Site
      group by Supplier.tprt_trade_partner_pk_key,
               Supplier.tprt_name;

  p_count := p_count + sql%rowcount;

   insert into POA_PORTAL_RISK_SUMMARY (
      Status,
      Risk_Category,
      Supplier_PK_Key,
      Supplier_Name,
      Total_Range_Low,
      Total_Range_High,
      Price_Range_Low,
      Price_Range_High,
      Quality_Range_Low,
      Quality_Range_High,
      Delivery_Range_Low,
      Delivery_Range_High,
      Service_Range_Low,
      Service_Range_High,
      Total_Score,
      Price_Score,
      Quality_Score,
      Delivery_Score,
      Service_Score,
      Purchase_Amount)
      select 'Good Suppliers', 3,
            Supplier.tprt_trade_partner_pk_key,
             Supplier.tprt_name,
             POA_PORTAL_SUP_RISK_IND.get_range3_low(1),
             POA_PORTAL_SUP_RISK_IND.get_range3_high(1),
             POA_PORTAL_SUP_RISK_IND.get_range3_low(2),
             POA_PORTAL_SUP_RISK_IND.get_range3_high(2),
             POA_PORTAL_SUP_RISK_IND.get_range3_low(3),
             POA_PORTAL_SUP_RISK_IND.get_range3_high(3),
             POA_PORTAL_SUP_RISK_IND.get_range3_low(4),
             POA_PORTAL_SUP_RISK_IND.get_range3_high(4),
             POA_PORTAL_SUP_RISK_IND.get_range3_low(5),
             POA_PORTAL_SUP_RISK_IND.get_range3_high(5),
             decode(sign(round(avg(Total_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range3_low(1)),
                    -1,-999,
                    0, avg(Total_Score),
                    1, decode(sign(round(avg(Total_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range3_high(1)),
                    -1, avg(Total_Score),
                    0, avg(Total_Score), -999)),
             decode(sign(round(avg(Price_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range3_low(2)),
                    -1,-999,
                    0, avg(Price_Score),
                    1, decode(sign(round(avg(Price_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range3_high(2)),
                    -1, avg(Price_Score),
                    0, avg(Price_Score), -999)),
             decode(sign(round(avg(Quality_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range3_low(3)),
                    -1,-999,
                    0, avg(Quality_Score),
                    1, decode(sign(round(avg(Quality_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range3_high(3)),
                    -1, avg(Quality_Score),
                    0, avg(Quality_Score), -999)),
             decode(sign(round(avg(Delivery_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range3_low(4)),
                    -1,-999,
                    0, avg(Delivery_Score),
                    1, decode(sign(round(avg(Delivery_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range3_high(4)),
                    -1, avg(Delivery_Score),
                   0, avg(Delivery_Score), -999)),
             decode(sign(round(avg(Survey_Score)) -
                          POA_PORTAL_SUP_RISK_IND.get_range3_low(5)),
                    -1,-999,
                    0, avg(Survey_Score),
                    1, decode(sign(round(avg(Survey_Score)) -
                                    POA_PORTAL_SUP_RISK_IND.get_range3_high(5)),
                    -1, avg(Survey_Score),
                   0, avg(Survey_Score), -999)),
           sum(pod.amt_purchased_g)
      from poa_edw_po_dist_f  pod,
           (select Supplier_Site,
                   avg(NVL(Price_Score,25) +
                       NVL(Quality_Score,25) +
                       NVL(Delivery_Score,25) +
                       NVL(Survey_Score,25)) Total_Score,
                   avg(NVL(Price_Score,25)) Price_Score,
                   avg(NVL(Quality_Score,25)) Quality_Score,
                   avg(NVL(Delivery_Score,25)) Delivery_Score,
                   avg(NVL(Survey_Score,25)) Survey_Score from
            POA_REP_SUP_SCORE_V
            group by Supplier_Site) Cstm_Msr,
           EDW_TRD_Partner_M Supplier
      where pod.SUPPLIER_SITE_FK_KEY = Supplier.TPLO_TPartner_Loc_PK_Key
        and pod.SUPPLIER_SITE_FK_KEY = Cstm_Msr.Supplier_Site
      group by Supplier.tprt_trade_partner_pk_key,
               Supplier.tprt_name;

  p_count := p_count + sql%rowcount;

   insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Problem Suppliers',
             count(distinct Supplier_PK_key), 0,0,0,0,1
      from POA_PORTAL_RISK_SUMMARY
      where (Total_Score <> -999 and
             Risk_Category = 1);

  p_count := p_count + sql%rowcount;

      insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Problem Suppliers',
             0, count(distinct Supplier_PK_key), 0,0,0,1
      from POA_PORTAL_RISK_SUMMARY
      where (Price_Score <> -999 and
             Risk_Category = 1);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Problem Suppliers',
             0, 0, count(distinct Supplier_PK_key), 0,0,1
      from POA_PORTAL_RISK_SUMMARY
      where (Quality_Score <> -999 and
             Risk_Category = 1);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Problem Suppliers',
             0, 0, 0, count(distinct Supplier_PK_key), 0,1
      from POA_PORTAL_RISK_SUMMARY
      where (Delivery_Score <> -999 and
             Risk_Category = 1);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Problem Suppliers',
             0, 0, 0, 0, count(distinct Supplier_PK_key),1
      from POA_PORTAL_RISK_SUMMARY
      where (Service_Score <> -999 and
             Risk_Category = 1);

  p_count := p_count + sql%rowcount;

   insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
   select 'At Risk Suppliers',
             count(distinct Supplier_PK_key), 0,0,0,0,2
      from POA_PORTAL_RISK_SUMMARY
      where (Total_Score <> -999 and
             Risk_Category = 2);

  p_count := p_count + sql%rowcount;

      insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'At Risk Suppliers',
             0, count(distinct Supplier_PK_key), 0,0,0,2
      from POA_PORTAL_RISK_SUMMARY
      where (Price_Score <> -999 and
             Risk_Category = 2);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'At Risk Suppliers',
             0, 0, count(distinct Supplier_PK_key), 0,0,2
      from POA_PORTAL_RISK_SUMMARY
      where (Quality_Score <> -999 and
             Risk_Category = 2);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'At Risk Suppliers',
             0, 0, 0, count(distinct Supplier_PK_key), 0,2
      from POA_PORTAL_RISK_SUMMARY
      where (Delivery_Score <> -999 and
             Risk_Category = 2);

  p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'At Risk Suppliers',
             0, 0, 0, 0, count(distinct Supplier_PK_key),2
      from POA_PORTAL_RISK_SUMMARY
      where (Service_Score <> -999 and
             Risk_Category = 2);

  p_count := p_count + sql%rowcount;

      insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Good Suppliers',
             count(distinct Supplier_PK_key), 0,0,0,0,3
      from POA_PORTAL_RISK_SUMMARY
      where (Total_Score <> -999 and
             Risk_Category = 3);

  p_count := p_count + sql%rowcount;

      insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Good Suppliers',
             0, count(distinct Supplier_PK_key), 0,0,0,3
      from POA_PORTAL_RISK_SUMMARY
      where (Price_Score <> -999 and
             Risk_Category = 3);

   p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Good Suppliers',
             0, 0, count(distinct Supplier_PK_key), 0,0,3
      from POA_PORTAL_RISK_SUMMARY
      where (Quality_Score <> -999 and
             Risk_Category = 3);

   p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Good Suppliers',
             0, 0, 0, count(distinct Supplier_PK_key), 0,3
      from POA_PORTAL_RISK_SUMMARY
      where (Delivery_Score <> -999 and
             Risk_Category = 3);

   p_count := p_count + sql%rowcount;

     insert into POA_PORTAL_RISK_IND (
      Status,
      Aggregate,
      Price,
      Quality,
      Delivery,
      Service,
      Risk_Category)
      select 'Good Suppliers',
             0, 0, 0, 0, count(distinct Supplier_PK_key),3
      from POA_PORTAL_RISK_SUMMARY
      where (Service_Score <> -999 and
             Risk_Category = 3);

   p_count := p_count + sql%rowcount;
   success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
      success := 'Error in insert_sr: ' || SQLERRM;
      RAISE;
end insert_rows_sr;

PROCEDURE insert_rows_cm(       p_start   IN DATE,
                                p_end     IN DATE,
                                p_count   OUT NOCOPY NUMBER,
                                success   OUT NOCOPY varchar2) IS
BEGIN

   insert into POA_PORTAL_SUP_RISK (
         Supplier_PK_Key,
         Supplier_Name,
         Supplier_Site_PK_Key,
         Supplier_Site_Name,
         Operating_Unit_PK_Key,
         Operating_Unit_Name,
         Price_Score,
         Quality_Score,
         Delivery_Score,
         Service_Score)
   select Supplier.tprt_trade_partner_pk_key,
          Supplier.tprt_name,
          Supplier.TPLO_TPartner_Loc_PK_Key,
          Supplier.TPLO_NAME,
          Organization.oper_operating_unit_pk_key,
          Organization.oper_name,
          avg(NVL(Price_Score, 25)),
          avg(NVL(Delivery_Score, 25)),
          avg(NVL(Quality_Score, 25)),
          avg(NVL(Survey_Score, 25))
    from POA_REP_CSTM_MSR_V Cstm_Msr,
         EDW_Organization_M Organization,
         EDW_TRD_Partner_M Supplier,
         EDW_Time_M Time
    where
      Cstm_Msr.Ship_To_Org_FK_Key = Organization.Orga_Organization_PK_Key and
      Cstm_Msr.Supplier_Site_FK_Key = Supplier.TPLO_TPartner_Loc_PK_Key and
      Cstm_Msr.Eval_Date_FK_Key = Time.CDay_Cal_Day_PK_Key and
      Time.CDAY_CALENDAR_DATE between p_start and p_end
    group by Supplier.tprt_trade_partner_pk_key,
          Supplier.tprt_name,
          Supplier.TPLO_TPartner_Loc_PK_Key,
          Supplier.TPLO_NAME,
          Organization.oper_operating_unit_pk_key,
          Organization.oper_name;

    p_count := sql%rowcount;

    success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
        success := 'Error in insert_pd: ' || SQLERRM;
	RAISE;
end insert_rows_cm;

PROCEDURE insert_rows_rcv(       p_start   IN DATE,
                                p_end     IN DATE,
                                p_count   OUT NOCOPY NUMBER,
                                success   OUT NOCOPY varchar2) IS
BEGIN

        INSERT into POA_PORTAL_RCPT_SUM (
               Operating_Unit_PK_Key,
               Operating_Unit_Name,
               Organization_PK_Key,
               Organization_Name,
               No_of_Lines,
               No_of_Headers,
               Total_Amount,
               Corrections,
               Corrections_Percent,
               Vendor_Returns_No,
               Vendor_Returns_Percent)
        SELECT org.oper_operating_unit_pk_key,
               org.oper_name,
               org.Orga_Organization_PK_Key,
               org.Orga_Name,
               to_number(NULL),
               to_number(NULL),
               sum(sp.amt_purchased_g),
               to_number(NULL),
               to_number(NULL),
               to_number(NULL),
               to_number(NULL)
        FROM poa_edw_sup_perf_f sp,
             edw_organization_m org,
             edw_time_m time
        WHERE sp.SHIP_TO_ORG_FK_KEY  = org.ORGA_ORGANIZATION_PK_KEY
          and sp.DATE_DIM_FK_KEY = time.CDAY_CAL_DAY_PK_KEY
          and sp.NUM_RECEIPT_LINES <> 0
          and time.CDAY_CALENDAR_DATE between  FII_TIME_WH_API.ent_cycq_start
                                          and  FII_TIME_WH_API.today
        GROUP BY org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
                 org.Orga_Organization_PK_Key, org.Orga_Name
        UNION ALL
        SELECT org.oper_operating_unit_pk_key,
               org.oper_name,
               org.Orga_Organization_PK_Key,
               org.Orga_Name,
               sum(DECODE(lookup.LUCD_Lookup_code, 'RECEIVE', 1, 0)),
               count(distinct DECODE(lookup.LUCD_LOOKUP_CODE, 'RECEIVE', rcv.receipt_num_inst, null)),
               to_number(NULL),
               count(distinct DECODE(lookup.LUCD_Lookup_Code, 'CORRECT', rcv.receipt_num_inst, null)),
               to_number(NULL),
	       count(distinct DECODE(lookup.LUCD_Lookup_Code, 'RETURN TO VENDOR', rcv.receipt_num_inst, null)),
               to_number(NULL)
        FROM POA_EDW_RCV_TXNS_F Rcv,
             edw_organization_m org,
             EDW_Lookup_M lookup,
             edw_time_m time
        WHERE rcv.RCV_Del_To_Org_FK_Key  = org.ORGA_ORGANIZATION_PK_KEY
          and rcv.TXn_Type_FK_Key = lookup.lucd_lookup_Code_PK_Key
          and rcv.TXN_Creat_FK_Key = time.CDAY_CAL_DAY_PK_KEY
          and time.CDAY_CALENDAR_DATE between  FII_TIME_WH_API.ent_cycq_start
                                          and  FII_TIME_WH_API.today
        GROUP BY org.Oper_Operating_Unit_PK_Key, org.OPER_NAME,
                 org.Orga_Organization_PK_Key, org.Orga_Name;

    p_count := sql%rowcount;

    success := 'ok';

EXCEPTION
   WHEN OTHERS THEN
        success := 'Error in insert_rcv: ' || SQLERRM;
	RAISE;
end insert_rows_rcv;

END POA_PORTAL_POPULATE_C;

/
