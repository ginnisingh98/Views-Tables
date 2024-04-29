--------------------------------------------------------
--  DDL for Package Body ASO_BI_QUOTE_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_QUOTE_FACT_PVT" AS
/* $Header: asovbiqhdb.pls 120.1 2005/07/06 00:44:56 kedukull noship $ */
Procedure InitLoad_Quote_Ids (p_from_date IN Date,
         p_to_date   IN Date)
 As
 Begin
  INSERT/*+ APPEND PARALLEL(ASO_QOT_IDS) */  INTO ASO_BI_QUOTE_IDS ASO_QOT_IDS
   (Quote_header_id,
    Quote_number,
    Max_quote_version,
    Quote_creation_date,
    quote_amount_first,
    batch_id)
  SELECT /*+ PARALLEL(QV)*/
      QV.quote_header_id,
      QV.quote_number,
      QV.max_quote_version,
      QV.quote_creation_date,
      (NVL(qv.total_list_price_first,0)+NVL(qv.total_adjusted_amount_first,0)) quote_amount_first,
      NULL
  FROM
      (SELECT  /*+ full(QHD) PARALLEL(QHD)*/  QHD.quote_version,
      QHD.quote_number,
      QHD.quote_header_id quote_header_id,
      LAST_VALUE(QHD.quote_version) OVER(
        PARTITION BY QHD.quote_number
        ORDER BY Quote_version ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
        AS MAX_QUOTE_VERSION,
      first_value(trunc(qhd.creation_date))
        over(partition by qhd.quote_number
        order by quote_version asc rows unbounded preceding)
        as quote_creation_date,
      first_value(qhd.TOTAL_list_price)
                        over(partition by qhd.quote_number
                      order by quote_version asc rows unbounded preceding)
                      as total_list_price_first,
      first_value(qhd.total_adjusted_amount)
                        over(partition by qhd.quote_number
                      order by quote_version asc rows unbounded preceding)
                      as total_adjusted_amount_first
      from    aso_quote_headers_all  qhd
      where   qhd.last_update_date
      between p_from_date and p_to_date
      and     nvl(qhd.quote_type,'q')<>'t') qv
  where  qv.quote_version = qv.max_quote_version ;

  if (bis_collection_utilities.g_debug) then
     bis_collection_utilities.debug('inserted '||sql%rowcount||' rows in ' ||'aso_bi_quote_ids.');
  end if;

  commit;

  aso_bi_util_pvt.analyze_table('aso_bi_quote_ids');

 end initload_quote_ids ;

 procedure populate_quote_ids(p_from_date date,
         p_to_date   date)
 as
  l_batch_size  number := 1000;
 begin

  /* for transactions with average complexity */
 l_batch_size:= bis_common_parameters.get_batch_size(bis_common_parameters.medium);

-- NVL(QHD.TOTAL_list_price,0)+NVL(QHD.total_adjusted_amount,0)

  insert/*+ append */ into aso_bi_quote_ids
   (quote_header_id,
    quote_number,
    max_quote_version,
    quote_creation_date,
    quote_amount_first,
    batch_id)
  select  qv.quote_header_id,
      qv.quote_number,
      qv.max_quote_version,
      qv.quote_creation_date,
      (NVL(qv.total_list_price_first,0)+NVL(qv.total_adjusted_amount_first,0)) quote_amount_first,
      ceil(rownum/l_batch_size)
  from
      (select  qhd.quote_version,
          qhd.quote_number,
          qhd.quote_header_id quote_header_id,
          last_value(qhd.quote_version) over(
            partition by qhd.quote_number
            order by quote_version asc
            rows between unbounded preceding and unbounded following)
            as max_quote_version,
          first_value(trunc(qhd.creation_date))
            over(partition by qhd.quote_number
            order by quote_version asc rows unbounded preceding)
            as quote_creation_date,
          first_value(qhd.TOTAL_list_price)
                        over(partition by qhd.quote_number
                      order by quote_version asc rows unbounded preceding)
                      as total_list_price_first,
          first_value(qhd.total_adjusted_amount)
                        over(partition by qhd.quote_number
                      order by quote_version asc rows unbounded preceding)
                      as total_adjusted_amount_first
      from  aso_quote_headers_all  qhd
      WHERE QHD.last_update_date
        BETWEEN p_from_date AND p_to_date
      AND   NVL(QHD.QUOTE_TYPE,'Q')<>'T') QV
  WHERE  QV.quote_version = QV.max_quote_version ;
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Inserted '||SQL%ROWCOUNT||' rows in ' ||'ASO_BI_QUOTE_IDS.');
  END IF;
  COMMIT;
 End Populate_Quote_ids;

 Procedure Register_jobs
 As
 Begin
  Insert Into ASO_BI_QUOTE_FACT_JOBS(batch_id,worker_number,status)
  SELECT DISTINCT batch_id,0,'UNASSIGNED'
    FROM ASO_BI_QUOTE_IDS ;
  COMMIT;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Inserted '||SQL%ROWCOUNT||' jobs into '||'ASO_BI_QUOTE_FACT_JOBS');
  END IF;

 End Register_jobs;

 -- This procedure is called as a part of incremental load of quote headers.
 Procedure Populate_Qot_Fact_Stg(p_batch_id IN NUMBER)
 As
  l_global_prim_currency  Varchar2(10);
  l_global_sec_currency  Varchar2(10);
 Begin

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('populating the Quote fact Staging');
  END IF;

  l_global_prim_currency := BIS_COMMON_PARAMETERS.Get_Currency_code ;
  l_global_sec_currency := BIS_COMMON_PARAMETERS.Get_Secondary_Currency_code ;

  COMMIT;

  MERGE INTO ASO_BI_QUOTE_HDRS_STG  STG
  USING ( SELECT * FROM
          (SELECT QHD.quote_number quote_number,
                  QHD.quote_version,
                  QHD.quote_header_id,
                  QHD.quote_name,
                  QID.quote_creation_date,
                  QHD.last_update_date quote_last_update_date,
                  NVL(QHD.TOTAL_list_price,0)+NVL(QHD.total_adjusted_amount,0) Quote_value,
                  QID.quote_amount_first,
                  QHD.total_adjusted_amount,
                  TRUNC(QHD.Quote_expiration_date) + 1 quote_expiration_date,
                  ORD.Header_id order_id,
                  QHD.currency_code,
                  RATE.prim_conversion_rate,
		  RATE.sec_conversion_rate,
                  QHD.resource_grp_id,
                  QHD.resource_id,
                  TRUNC(ORD.creation_date) order_creation_date,
                  QROBJ.object_id          lead_id,
                  QHD.cust_party_id party_id,
                  QHD.marketing_source_code_id,
                  NVL(QHD.Total_adjusted_percent,0) Total_adjusted_percent,
                  (SELECT CASE WHEN count(LIN.charge_periodicity_code) = (CASE WHEN count(LIN.quote_line_id) = 0
                                                                               THEN -1 ELSE
                                                                               count(LIN.quote_line_id) END)
                               THEN  'Y' ELSE  'N' END FROM ASO_QUOTE_LINES_ALL  LIN
                   WHERE LIN.quote_header_id = QHD.quote_header_id) recurring_charge_flag
           FROM   ASO_QUOTE_HEADERS_ALL  QHD,
                  OE_ORDER_HEADERS_ALL   ORD,
                  ASO_BI_QUOTE_IDS       QID,
                  ASO_QUOTE_RELATED_OBJECTS QROBJ,
                  ASO_BI_CURRENCY_RATES RATE
          WHERE   QHD.order_id = ord.header_id(+)
            AND   QHD.quote_header_id = QID.quote_header_id
            AND   QID.batch_id = p_batch_id
            AND   QHD.quote_header_id = QROBJ.quote_object_id(+)
            AND   QROBJ.quote_object_type_code(+) = 'HEADER'
            AND   QROBJ.object_type_code(+) = 'LDID'
            AND   QROBJ.relationship_type_code(+) = 'OPP_QUOTE'
            AND   QHD.resource_grp_id IS NOT NULL
            AND   RATE.org_id(+) = QHD.org_id
	    AND   RATE.exchange_date(+) = trunc(QHD.last_update_date)
	    AND   RATE.txn_currency(+) = QHD.currency_code
         )  )S
 ON ( STG.quote_number = S.quote_number)
 WHEN MATCHED THEN
 UPDATE SET STG.quote_version = S.quote_version,
  STG.quote_header_id = S.quote_header_id,
  STG.quote_value   = S.quote_value ,
  STG.quote_name = S.quote_name,
  STG.total_adjusted_amount = S.total_adjusted_amount,
  STG.quote_amount_first = S.quote_amount_first,
  STG.conversion_rate = S.prim_conversion_rate,
  STG.sec_conversion_rate = S.sec_conversion_rate,
  STG.quote_expiration_date = S.quote_expiration_date,
  STG.order_id = S.order_id,
  STG.currency_code = S.currency_code,
  STG.resource_grp_id = S.resource_grp_id,
  STG.resource_id = S.resource_id,
  STG.order_creation_date = S.order_creation_date,
  STG.lead_id = S.lead_id,
  STG.party_id = S.party_id ,
  STG.marketing_source_code_id = S.marketing_source_code_id,
  STG.Total_adjusted_percent = S.Total_adjusted_percent,
  STG.recurring_charge_flag =  S.recurring_charge_flag
 WHEN NOT MATCHED THEN
 INSERT(quote_number,
    quote_version,
    quote_header_id,
    quote_name,
    quote_creation_date,
    quote_last_update_date,
    resource_id,
    resource_grp_id,
    quote_expiration_date,
    currency_code,
    reporting_currency,
    conversion_rate,
    sec_conversion_rate,
    quote_value,
    quote_amount_first,
    total_adjusted_amount,
    order_id,
    order_creation_date,
    lead_id,
    party_id,
    marketing_source_code_id,
    Total_adjusted_percent,
    recurring_charge_flag)
 VALUES( S.quote_number,
    S.quote_version,
    S.quote_header_id,
    S.quote_name,
    S.quote_creation_date,
    S.quote_last_update_date,
    S.resource_id ,
    S.resource_grp_id,
    S.quote_expiration_date,
    S.currency_code,
    l_global_prim_currency ,
    S.prim_conversion_rate,
    S.sec_conversion_rate,
    S.Quote_value,
    S.Quote_amount_first,
    S.total_adjusted_amount,
    S.order_id,
    S.order_creation_date,
    S.lead_id,
    S.party_id,
    S.marketing_source_code_id,
    S.Total_adjusted_percent,
    S.recurring_charge_flag) ;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote fact Staging:'||'Rowcount:'|| SQL%ROWCOUNT);
  END IF;

  COMMIT;

  ASO_BI_UTIL_PVT.Analyze_Table('ASO_BI_QUOTE_HDRS_STG');

 End Populate_Qot_Fact_Stg;

 -- Initial Load of ASO_BI_QUOTE_HDRS_ALL
 Procedure InitiLoad_QotHdr
 As
 l_user_id number;
 l_login_id number;
 l_global_prim_currency VARCHAR2(20);
 Begin

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Start populating the Quote fact Table');
 END IF;

 l_user_id := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;
 l_global_prim_currency := BIS_COMMON_PARAMETERS.Get_Currency_code ;

  INSERT/*+ APPEND PARALLEL(QOTHDR)*/  INTO ASO_BI_QUOTE_HDRS_ALL QOTHDR
                      (quote_number,
                       quote_version,
                       quote_header_id,
		       quote_name,
                       quote_creation_date,
                       quote_last_update_date,
                       resource_id,
                       resource_grp_id,
                       quote_expiration_date,
                       currency_code,
                       reporting_currency,
                       conversion_rate,
                       sec_conversion_rate,
                       quote_value,
                       quote_amount_first,
                       total_adjusted_amount,
                       order_id,
                       order_creation_date,
                       lead_id,
                       creation_date,
                       created_by,
                       last_update_date,
                       last_updated_by,
                       LAST_UPDATE_LOGIN,
                       party_id,
                       marketing_source_code_id,
                       Total_adjusted_percent,
                       recurring_charge_flag
                       )
                       SELECT
                         /*+ USE_HASH(ORD) PARALLEL(QHD) PARALLEL(QROBJ) PARALLEL(ORD) PARALLEL(QID) PARALLEL(RATE) */
                         QHD.quote_number quote_number,
                         QHD.quote_version,
                         QHD.quote_header_id,
			 QHD.quote_name,
                         QID.quote_creation_date,
                         QHD.last_update_date quote_last_update_date,
                         QHD.resource_id,
                         QHD.resource_grp_id,
                         TRUNC(QHD.Quote_expiration_date) + 1 quote_expiration_date,
                         QHD.currency_code,
                         l_global_prim_currency ,
                         RATE.prim_conversion_rate,
                         RATE.sec_conversion_rate,
                         NVL(QHD.TOTAL_list_price,0)+NVL(QHD.total_adjusted_amount,0) Quote_value,
                         QID.quote_amount_first,
                         QHD.total_adjusted_amount,
                         ORD.Header_id order_id,
                         TRUNC(ORD.creation_date) order_creation_date,
                         QROBJ.object_id lead_id,
                         SYSDATE,
                         l_user_id,
                         SYSDATE,
                         l_user_id,
                         l_login_id,
                         QHD.cust_party_id party_id,
                         QHD.marketing_source_code_id,
                         NVL(QHD.Total_adjusted_percent, 0),
                         (SELECT CASE WHEN count(LIN.charge_periodicity_code) = (CASE WHEN count(LIN.quote_line_id) = 0
                                                                               THEN -1 ELSE
                                                                               count(LIN.quote_line_id) END)
                               THEN  'Y' ELSE  'N' END FROM ASO_QUOTE_LINES_ALL  LIN
                   WHERE LIN.quote_header_id = QHD.quote_header_id) recurring_charge_flag
                       FROM
                         ASO_QUOTE_HEADERS_ALL  QHD,
                         OE_ORDER_HEADERS_ALL   ORD,
                         ASO_BI_QUOTE_IDS       QID,
                         ASO_QUOTE_RELATED_OBJECTS QROBJ,
                         ASO_BI_CURRENCY_RATES RATE
                       WHERE
                         QHD.order_id = ord.header_id(+) AND
                         QHD.quote_header_id = QID.quote_header_id AND
                         QHD.quote_header_id = QROBJ.quote_object_id(+) AND
                         QROBJ.quote_object_type_code(+) = 'HEADER' AND
                         QROBJ.object_type_code(+) = 'LDID' AND
                         QROBJ.relationship_type_code(+) = 'OPP_QUOTE' AND
                         QHD.resource_grp_id IS NOT NULL AND
                         RATE.org_id(+) = QHD.org_id AND
                         RATE.txn_currency(+) = QHD.currency_code AND
                         RATE.exchange_date(+)  = trunc(QHD.last_update_date);

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);
  END IF;
  COMMIT;
 End InitiLoad_QotHdr ;

 -- This procedure is called as a part of incremental load of quote headers fact table.
 Procedure Populate_data
 As
 l_user_id NUMBER;
 l_login_id NUMBER;
 Begin

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Start populating the Quote fact Table');
 END IF;

  l_user_id := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;

  EXECUTE IMMEDIATE
  'MERGE INTO ASO_BI_QUOTE_HDRS_ALL QOTHDR
   USING(SELECT quote_number,
                quote_version,
                quote_header_id,
                quote_name,
                quote_creation_date,
                quote_last_update_date,
                resource_id,
                resource_grp_id,
                quote_expiration_date,
                currency_code,
                reporting_currency,
                conversion_rate,
                sec_conversion_rate,
                quote_value,
                quote_amount_first,
                total_adjusted_amount,
                order_id,
                order_creation_date,
                lead_id,
                party_id,
                marketing_source_code_id,
                total_adjusted_percent,
                recurring_charge_flag
         FROM ASO_BI_QUOTE_HDRS_STG
         WHERE (conversion_rate > 0)) STG
   ON (QOTHDR.quote_number = STG.quote_number)
  WHEN MATCHED THEN UPDATE
   SET  QOTHDR.quote_version = STG.quote_version,
      QOTHDR.quote_header_id = STG.quote_header_id,
      QOTHDR.quote_name = STG.quote_name,
      QOTHDR.quote_value   = STG.quote_value ,
      QOTHDR.quote_amount_first   = STG.quote_amount_first ,
      QOTHDR.total_adjusted_amount = STG.total_adjusted_amount,
      QOTHDR.conversion_rate = STG.conversion_rate,
      QOTHDR.sec_conversion_rate = STG.sec_conversion_rate,
      QOTHDR.quote_expiration_date = STG.quote_expiration_date,
      QOTHDR.order_id = STG.order_id,
      QOTHDR.currency_code = STG.currency_code,
      QOTHDR.resource_grp_id = STG.resource_grp_id,
      QOTHDR.resource_id = STG.resource_id,
      QOTHDR.order_creation_date = STG.order_creation_date,
      QOTHDR.lead_id = STG.lead_id,
      QOTHDR.last_update_date = :sys_date,
      QOTHDR.last_updated_by = :l_user_id,
      QOTHDR.LAST_UPDATE_LOGIN = :l_login_id,
      QOTHDR.party_id = STG.party_id,
      QOTHDR.marketing_source_code_id = STG.marketing_source_code_id,
      QOTHDR.total_adjusted_percent = STG.total_adjusted_percent,
      QOTHDR.recurring_charge_flag = STG.recurring_charge_flag
 WHEN NOT MATCHED THEN
 INSERT(quote_number,
    quote_version,
    quote_header_id,
    quote_name,
    quote_creation_date,
    quote_last_update_date,
    resource_id,
    resource_grp_id,
    quote_expiration_date,
    currency_code,
    reporting_currency,
    conversion_rate,
    sec_conversion_rate,
    quote_value,
    quote_amount_first,
    total_adjusted_amount,
    order_id,
    order_creation_date,
    lead_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    LAST_UPDATE_LOGIN,
    party_id,
    marketing_source_code_id,
    Total_adjusted_percent,
    recurring_charge_flag )
 VALUES( STG.quote_number,
    STG.quote_version,
    STG.quote_header_id,
    STG.quote_name,
    STG.quote_creation_date,
    STG.quote_last_update_date,
    STG.resource_id ,
    STG.resource_grp_id,
    STG.quote_expiration_date,
    STG.currency_code,
    STG.reporting_currency ,
    STG.conversion_rate,
    STG.sec_conversion_rate,
    STG.Quote_value,
    STG.quote_amount_first,
    STG.total_adjusted_amount,
    STG.order_id,
    STG.order_creation_date,
    STG.lead_id,
    :sys_date,
    :l_user_id,
    :sys_date,
    :l_user_id,
    :l_login_id,
    STG.party_id,
    STG.marketing_source_code_id,
    STG.total_adjusted_percent,
    STG.recurring_charge_flag)' USING SYSDATE, l_user_id,l_login_id,SYSDATE,l_user_id,SYSDATE,l_user_id,l_login_id;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);
  END IF;

  COMMIT;

 End Populate_data;

 Procedure Worker(
   Errbuf   IN OUT NOCOPY VARCHAR2,
   Retcode  IN OUT NOCOPY NUMBER,
   p_worker_no IN NUMBER)
 As
  l_unassigned_cnt NUMBER := 0;
  l_failed_cnt     NUMBER := 0;
  l_comp_cnt       NUMBER := 0;
  l_total_cnt      NUMBER := 0;
  l_count          NUMBER := 0;
  l_batch_id       NUMBER := 0;
 Begin
  errbuf := NULL;
  retcode := 0;

 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_QOT_HDR_SUBWORKER'||p_worker_no)) = false
 Then
   errbuf := FND_MESSAGE.Get;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 End if;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('ASO_BI_QOT_HDR_SUBWORKER'||p_worker_no||' starting.');
  END IF;

  LOOP
   SELECT NVL(SUM(DECODE(status,'UNASSIGNED',1,0)),0),
          NVL(SUM(DECODE(status,'FAILED',1,0)),0),
          NVL(SUM(DECODE(status,'COMPLETED',1,0)),0),
          COUNT(*)
     INTO l_unassigned_cnt,
          l_failed_cnt,
          l_comp_cnt,
          l_total_cnt
     FROM ASO_BI_QUOTE_FACT_JOBS;

   IF(l_failed_cnt > 0) Then
    IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
       BIS_COLLECTION_UTILITIES.Debug('Another worker have errored out.Stop Processing.');
    END IF;
    Exit;
   Elsif (l_unassigned_cnt = 0) Then
    IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
       BIS_COLLECTION_UTILITIES.Debug('No More jobs left.Terminating.');
    END IF;
    EXIT;
   Elsif( l_comp_cnt = l_total_cnt) Then
    IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
       BIS_COLLECTION_UTILITIES.Debug('All Jobs completed.Terminating.');
    END IF;
    EXIT;
   Elsif(l_unassigned_cnt > 0) Then
    UPDATE ASO_BI_QUOTE_FACT_JOBS
       SET status = 'IN_PROCESS',
           worker_number = p_worker_no
     WHERE status = 'UNASSIGNED'
       AND rownum < 2;
     l_count := SQL%ROWCOUNT;
   End If;
   COMMIT;

   If (l_count > 0) Then
    BEGIN
      SELECT batch_id
        INTO l_batch_id
        FROM ASO_BI_QUOTE_FACT_JOBS
      WHERE  worker_number = p_worker_no
        AND  status = 'IN_PROCESS';

      IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
         BIS_COLLECTION_UTILITIES.Debug('Start populate Staging:'||TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
      END IF;

      POPULATE_QOT_FACT_STG(p_batch_id => l_batch_id);

      IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
         BIS_COLLECTION_UTILITIES.Debug('End populate Staging:'||TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
      END IF;

      UPDATE ASO_BI_QUOTE_FACT_JOBS
         SET status = 'COMPLETED'
      WHERE  status = 'IN_PROCESS'
         AND worker_number = p_worker_no;

      COMMIT;
    EXCEPTION
     WHEN OTHERS Then
       retcode := -1;
       UPDATE ASO_BI_QUOTE_FACT_JOBS
          SET status = 'FAILED'
       WHERE  worker_number = p_worker_no
          AND status = 'IN_PROCESS';
       COMMIT;
       RAISE;
    END;
   End If; --if l_count > 0
  END LOOP;
 EXCEPTION
  WHEN OTHERS THEN
   retcode := -1;
   errbuf := FND_MESSAGE.Get;

   UPDATE ASO_BI_QUOTE_FACT_JOBS
      SET status = 'FAILED'
    WHERE worker_number = p_worker_no
      AND status = 'IN_PROCESS';
   COMMIT;
 End Worker;

END ASO_BI_QUOTE_FACT_PVT ;

/
