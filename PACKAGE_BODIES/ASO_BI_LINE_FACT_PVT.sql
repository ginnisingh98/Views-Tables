--------------------------------------------------------
--  DDL for Package Body ASO_BI_LINE_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_LINE_FACT_PVT" AS
/* $Header: asovbiqlinb.pls 120.1 2005/07/06 00:45:34 kedukull noship $ */

g_schema VARCHAR2(30):= NULL;

 -- This deletes quote lines that have got updated in date range
 -- This is done to remove quote lines that belonged to older versions
 -- of the quote
 PROCEDURE Cleanup_Line_Data
 AS
 BEGIN

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Start deleting the updated rows from ' ||
                                 'ASO_BI_QUOTE_LINES_ALL table');
  END IF;

  DELETE FROM ASO_BI_QUOTE_LINES_ALL qlin
  WHERE qlin.quote_number IN (
    SELECT quote_number
    FROM ASO_BI_QUOTE_IDS
  );

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Deleted the updated rows from '||
                                 'ASO_BI_QUOTE_LINES_ALL table');
  END IF;

 COMMIT;
 END Cleanup_Line_Data;


 -- Inserts the quote lines id into ASO_BI_LINE_IDS table
 -- corresponding the quotes that got changed in the given window
 -- of dates
 PROCEDURE initLoad_Quote_Line_ids
 AS

 BEGIN

  INSERT/*+ APPEND PARALLEL(ASO_LINE_IDS)*/ INTO ASO_BI_LINE_IDS ASO_LINE_IDS
  ( QUOTE_HEADER_ID,
    QUOTE_NUMBER,
    MAX_QUOTE_VERSION,
    QUOTE_CREATION_DATE,
    QUOTE_LINE_ID,
    BATCH_ID
  )
  SELECT  /*+ PARALLEL(qlin) PARALLEL(qid)*/
          qid.quote_header_id,
          qid.quote_number,
          qid.max_quote_version,
          qid.quote_creation_date,
          qlin.quote_line_id,
          NULL
  FROM  ASO_QUOTE_LINES_ALL qlin,
        ASO_BI_QUOTE_IDS qid
  WHERE qid.quote_header_id = qlin.quote_header_id;

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Inserted '||SQL%ROWCOUNT||' rows in ' ||
                                 'ASO_BI_LINE_IDS.');
  END IF;

 COMMIT;
 ASO_BI_UTIL_PVT.Analyze_Table('ASO_BI_LINE_IDS');

END initLoad_Quote_Line_ids;


 -- Inserts the updated quote line ids into ASO_BI_LINE_IDS table
 PROCEDURE  Populate_Quote_Line_ids
 AS
  l_batch_size  Number := 1000;
 BEGIN

  /* For Transactions with Average Complexity */
  l_batch_size:= bis_common_parameters.get_batch_size(
                                  BIS_COMMON_PARAMETERS.MEDIUM);

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Started populating ASO_BI_LINE_IDS table');
  END IF;

  INSERT INTO ASO_BI_LINE_IDS
  ( QUOTE_HEADER_ID,
    QUOTE_NUMBER,
    MAX_QUOTE_VERSION,
    QUOTE_CREATION_DATE,
    QUOTE_LINE_ID,
    BATCH_ID
  )
  SELECT  qid.quote_header_id,
          qid.quote_number,
          qid.max_quote_version,
          qid.quote_creation_date,
          qlin.quote_line_id,
          CEIL(ROWNUM/l_batch_size)
  FROM  ASO_QUOTE_LINES_ALL qlin,
        ASO_BI_QUOTE_IDS qid
  WHERE qid.quote_header_id = qlin.quote_header_id;

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Inserted '||SQL%ROWCOUNT||' rows in ' ||
                                 'ASO_BI_QUOTE_IDS.');
  END IF;

 COMMIT;
 END Populate_Quote_Line_ids;


 -- Inserts records into ASO_BI_QUOTE_FACT_JOBS as many as the batches
 PROCEDURE Register_Line_jobs
 AS
 BEGIN

  INSERT INTO ASO_BI_QUOTE_FACT_JOBS
  ( batch_id,
    worker_number,
    status
  )
  SELECT DISTINCT batch_id, 0, 'UNASSIGNED'
  FROM ASO_BI_LINE_IDS ;
  COMMIT;

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Inserted '||SQL%ROWCOUNT||' jobs into '||
                                 'ASO_BI_QUOTE_FACT_JOBS');
  END IF;

 END Register_Line_jobs;

Procedure InitiLoad_QotLineStg
 As
  l_rate_type varchar2(50);
  l_rpt_curr varchar2(50);
  l_sec_currency varchar2(50);
 Begin

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('populating the Quote Lines Staging');
  END IF;

  l_rate_type := bis_common_parameters.get_rate_type;
  l_rpt_curr  := bis_common_parameters.get_currency_code;
  l_sec_currency  := bis_common_parameters.get_secondary_currency_code;


  INSERT/*+ APPEND PARALLEL(STG) */ INTO ASO_BI_QUOTE_LINES_STG STG
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      cust_party_id,
      minisite_id_hdr,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      item_type_code,
      config_header_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      order_creation_date,
      Config_Item_Id,
      Charge_periodicity_code
    )
    SELECT  /*+
            USE_HASH(qhd) USE_HASH(linid) USE_HASH(ord) USE_HASH(hzcst)
            USE_HASH(qlin) USE_HASH(qdtl) USE_HASH(qshp)
            PARALLEL(qlin) PARALLEL(qhd) PARALLEL(qshp) PARALLEL(qdtl)
            PARALLEL(linid) PARALLEL(hzcst) PARALLEL(ord) PARALLEL(RATE)*/
            qhd.quote_header_id ,
            qhd.quote_number,
            linid.max_quote_version,
            linid.QUOTE_CREATION_DATE,
            qhd.last_update_date,
            TRUNC(qhd.quote_expiration_date) + 1,
            qhd.resource_id,
            qhd.resource_grp_id,
            qhd.quote_source_code,
            qhd.cust_account_id,
            qhd.invoice_to_cust_account_id,
            hzcst.party_id cust_party_id,
            qhd.minisite_id,
            qhd.quote_status_id,
            qhd.sales_channel_code,
            qhd.org_id,
            qhd.order_id,
            qhd.currency_code,
            l_rpt_curr,
            rate.func_currency_code functional_currency,
            rate.prim_conversion_rate, -- primary conv rate
            rate.func_conversion_rate, -- functional currency conversion rate
            rate.sec_conversion_rate, -- secondary currency conversion rate
            qshp.shipment_id,
            qlin.line_list_price*qlin.quantity,
            qlin.line_quote_price*qlin.quantity,
            qlin.quantity,
            qlin.uom_code,
            qlin.minisite_id,
            qlin.marketing_source_code_id,
            qlin.inventory_item_id,
            qlin.organization_id,
            qlin.invoice_to_cust_account_id,
            qlin.agreement_id,
            qlin.item_type_code,
            qdtl.config_header_id,
            qlin.quote_line_id,
            qlin.line_category_code,
            qhd.marketing_source_code_id,
            TRUNC(ord.creation_date),
            qdtl.config_item_id,
            qlin.Charge_periodicity_code
    FROM  aso_quote_lines_all qlin,
          aso_quote_headers_all qhd,
          aso_shipments qshp,
          aso_quote_line_details qdtl,
          aso_bi_line_ids linid,
          aso_bi_currency_rates rate,
          hz_cust_accounts hzcst,
          OE_ORDER_HEADERS_ALL ORD
    WHERE qlin.quote_header_id = qhd.quote_header_id
    AND   qlin.quote_line_id = qshp.quote_line_id
    AND   qhd.quote_header_id = linid.quote_header_id
    AND   qhd.org_id = rate.org_id
    AND   qhd.currency_code = rate.txn_currency
    AND   rate.exchange_date = trunc(qhd.last_update_date)
    AND   qlin.quote_line_id = qdtl.quote_line_id(+)
    AND   qlin.quote_line_id = linid.quote_line_id
    AND   qhd.cust_account_id = hzcst.CUST_ACCOUNT_ID(+)
    AND   QHD.Order_id = ord.header_id(+);

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote Line Staging:'||
                                 'Rowcount:'|| SQL%ROWCOUNT);
  END IF;

  COMMIT;

  ASO_BI_UTIL_PVT.Analyze_Table('ASO_BI_QUOTE_LINES_STG');

 End InitiLoad_QotLineStg ;


 -- Populates the Staging table. Will be called as a part of
 -- incremental load of the quote lines
 PROCEDURE Populate_Qot_Line_Fact_Stg(p_batch_id IN NUMBER)
 AS
  l_rate_type varchar2(50);
  l_rpt_curr varchar2(50);
  l_sec_currency varchar2(50);
 BEGIN

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Stared populating the Quote line fact Staging');
  END IF;

  l_rate_type := bis_common_parameters.get_rate_type;
  l_rpt_curr  := bis_common_parameters.get_currency_code;
  l_sec_currency := bis_common_parameters.get_secondary_currency_code;
  -- Check for reporting currency null
  INSERT/*+ append */ INTO ASO_BI_QUOTE_LINES_STG
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      cust_party_id,
      minisite_id_hdr,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      item_type_code,
      config_header_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      order_creation_date,
      config_item_id,
      Charge_periodicity_code
    )
    SELECT  qhd.quote_header_id ,
            qhd.quote_number,
            linid.max_quote_version,
            linid.QUOTE_CREATION_DATE,
            qhd.last_update_date,
            TRUNC(qhd.quote_expiration_date)+1,
            qhd.resource_id,
            qhd.resource_grp_id,
            qhd.quote_source_code,
            qhd.cust_account_id,
            qhd.invoice_to_cust_account_id,
            hzcst.party_id cust_party_id,
            qhd.minisite_id,
            qhd.quote_status_id,
            qhd.sales_channel_code,
            qhd.org_id,
            qhd.order_id,
            qhd.currency_code,
            l_rpt_curr,
            rate.func_currency_code functional_currency,
            rate.prim_conversion_rate, -- Primary Currency Conv. rate
            rate.func_conversion_rate,      -- Functional Currency conv. Rate
            rate.sec_conversion_rate, -- Seondary Currency Conv. rate
            qshp.shipment_id,
            qlin.line_list_price*qlin.quantity,
            qlin.line_quote_price*qlin.quantity,
            qlin.quantity,
            qlin.uom_code,
            qlin.minisite_id,
            qlin.marketing_source_code_id,
            qlin.inventory_item_id,
            qlin.organization_id,
            qlin.invoice_to_cust_account_id,
            qlin.agreement_id,
            qlin.item_type_code,
            qdtl.config_header_id,
            qlin.quote_line_id,
            qlin.line_category_code,
            qhd.marketing_source_code_id,
            TRUNC(ord.creation_date),
            qdtl.config_item_id,
            qlin.Charge_periodicity_code
    FROM  aso_quote_lines_all qlin,
          aso_quote_headers_all qhd,
          aso_shipments qshp,
          aso_quote_line_details qdtl,
          aso_bi_line_ids linid,
          aso_bi_currency_rates rate,
          hz_cust_accounts hzcst,
          OE_ORDER_HEADERS_ALL ORD
    WHERE qlin.quote_header_id = qhd.quote_header_id
    AND   qlin.quote_line_id = qshp.quote_line_id
    AND   qhd.quote_header_id = linid.quote_header_id
    AND   qhd.org_id = rate.org_id
    AND   qhd.currency_code = rate.txn_currency
    AND   rate.exchange_date = trunc(qhd.last_update_date)
    AND   qlin.quote_line_id = qdtl.quote_line_id(+)
    AND   qlin.quote_line_id = linid.quote_line_id
    AND   qhd.cust_account_id = hzcst.CUST_ACCOUNT_ID(+)
    AND   qhd.Order_id = ord.header_id(+)
    AND   linid.batch_id = p_batch_id;

    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote line fact '||
                                   'Staging:Rowcount: '||SQL%ROWCOUNT);
    END IF;

    COMMIT;

    ASO_BI_UTIL_PVT.Analyze_Table('ASO_BI_QUOTE_LINES_STG');

  END Populate_Qot_Line_Fact_Stg;

  -- Initial Load of ASO_BI_QUOTE_LINES_ALL
  -- Called as a part of initial load of quote lines
  Procedure InitiLoad_QotLine
  As
  l_user_id number;
  l_login_id number;
  l_sysdate date;
  Begin

    l_user_id := FND_GLOBAL.user_id;
    l_login_id := FND_GLOBAL.login_id;
    l_sysdate := sysdate;

    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Start populating the Quote Line fact');
    END IF;

    EXECUTE IMMEDIATE
    'INSERT/*+ APPEND PARALLEL(QOT_LINES_ALL)*/
        INTO ASO_BI_QUOTE_LINES_ALL QOT_LINES_ALL
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      minisite_id_hdr,
      cust_party_id,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      publish_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      order_creation_date,
      Top_Inventory_Item_Id,
      Top_Organization_Id,
      Charge_periodicity_code
    )
    SELECT  /*+ PARALLEL(qlinstg)*/
            qlinstg.quote_header_id,
            qlinstg.quote_number,
            qlinstg.quote_version,
            qlinstg.quote_creation_date,
            qlinstg.quote_last_update_date,
            qlinstg.quote_expiration_date,
            qlinstg.resource_id,
            qlinstg.resource_grp_id,
            qlinstg.quote_source_code,
            qlinstg.cust_account_id,
            qlinstg.invoice_to_cust_account_id_hdr,
            qlinstg.minisite_id_hdr,
            qlinstg.cust_party_id,
            qlinstg.quote_status_id,
            qlinstg.sales_channel_code,
            qlinstg.org_id,
            qlinstg.order_id,
            qlinstg.currency_code,
            qlinstg.reporting_currency,
            qlinstg.functional_currency,
            qlinstg.reporting_conversion_rate,
            qlinstg.functional_conversion_rate,
            qlinstg.sec_conversion_rate,
            qlinstg.shipment_id,
            qlinstg.line_value,
            qlinstg.line_quote_value,
            qlinstg.quantity,
            qlinstg.uom_code,
            qlinstg.minisite_id,
            qlinstg.marketing_source_code_id,
            qlinstg.inventory_item_id,
            qlinstg.organization_id,
            qlinstg.invoice_to_cust_account_id,
            qlinstg.agreement_id,
            qlinstg.quote_line_id,
            qlinstg.line_category_code,
            qlinstg.marketing_source_code_id_hdr,
            null publish_flag,
            :l_sysdate,
            :l_user_id,
            :l_sysdate,
            :l_user_id,
            :l_login_id,
            qlinstg.order_creation_date,
            FIRST_VALUE(inventory_item_id)OVER(
              PARTITION BY config_header_id
              ORDER BY config_item_id ASC
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                  Top_Inventory_Item_Id,
            FIRST_VALUE(organization_id)OVER(
              PARTITION BY config_header_id
              ORDER BY config_item_id ASC
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                  Top_Organization_Id,
             qlinstg.Charge_periodicity_code
    FROM ASO_BI_QUOTE_LINES_STG qlinstg
    WHERE Config_Header_Id IS NOT NULL'
    USING  l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            l_login_id;

    COMMIT;

    EXECUTE IMMEDIATE
    'INSERT/*+ APPEND PARALLEL(QOT_LINES_ALL)*/
        INTO ASO_BI_QUOTE_LINES_ALL QOT_LINES_ALL
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      minisite_id_hdr,
      cust_party_id,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      publish_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      order_creation_date,
      Top_Inventory_Item_Id,
      Top_Organization_Id,
      Charge_periodicity_code
    )
    SELECT  /*+ PARALLEL(qlinstg)*/
            qlinstg.quote_header_id,
            qlinstg.quote_number,
            qlinstg.quote_version,
            qlinstg.quote_creation_date,
            qlinstg.quote_last_update_date,
            qlinstg.quote_expiration_date,
            qlinstg.resource_id,
            qlinstg.resource_grp_id,
            qlinstg.quote_source_code,
            qlinstg.cust_account_id,
            qlinstg.invoice_to_cust_account_id_hdr,
            qlinstg.minisite_id_hdr,
            qlinstg.cust_party_id,
            qlinstg.quote_status_id,
            qlinstg.sales_channel_code,
            qlinstg.org_id,
            qlinstg.order_id,
            qlinstg.currency_code,
            qlinstg.reporting_currency,
            qlinstg.functional_currency,
            qlinstg.reporting_conversion_rate,
            qlinstg.functional_conversion_rate,
            qlinstg.sec_conversion_rate,
            qlinstg.shipment_id,
            qlinstg.line_value,
            qlinstg.line_quote_value,
            qlinstg.quantity,
            qlinstg.uom_code,
            qlinstg.minisite_id,
            qlinstg.marketing_source_code_id,
            qlinstg.inventory_item_id,
            qlinstg.organization_id,
            qlinstg.invoice_to_cust_account_id,
            qlinstg.agreement_id,
            qlinstg.quote_line_id,
            qlinstg.line_category_code,
            qlinstg.marketing_source_code_id_hdr,
            null publish_flag,
            :l_sysdate,
            :l_user_id,
            :l_sysdate,
            :l_user_id,
            :l_login_id,
            qlinstg.order_creation_date,
            Inventory_item_id Top_Inventory_Item_Id,
            Organization_id Top_Organization_Id,
            qlinstg.Charge_periodicity_code
    FROM ASO_BI_QUOTE_LINES_STG qlinstg
    WHERE Config_Header_Id IS NULL'
    USING  l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            l_login_id;

    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote Line fact'||
                                   ':Rowcount:'||SQL%ROWCOUNT);
    END IF;

    COMMIT;

 End InitiLoad_QotLine ;


 -- Inserts Records into ASO_BI_QUOTE_LINES_ALL reading from
 -- ASO_BI_QUOTE_LINES_STG table.
 PROCEDURE Populate_Line_data AS
  l_user_id number;
  l_login_id number;
  l_sysdate date;
 BEGIN

  l_user_id := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;
  l_sysdate := sysdate;

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Start populating the Quote Line fact');
  END IF;

  EXECUTE IMMEDIATE
  'INSERT/*+ append */ INTO ASO_BI_QUOTE_LINES_ALL
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      minisite_id_hdr,
      cust_party_id,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      publish_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      order_creation_date,
      Top_Inventory_Item_Id,
      Top_Organization_Id,
      Charge_periodicity_code
    )
    SELECT
            qlinstg.quote_header_id,
            qlinstg.quote_number,
            qlinstg.quote_version,
            qlinstg.quote_creation_date,
            qlinstg.quote_last_update_date,
            qlinstg.quote_expiration_date,
            qlinstg.resource_id,
            qlinstg.resource_grp_id,
            qlinstg.quote_source_code,
            qlinstg.cust_account_id,
            qlinstg.invoice_to_cust_account_id_hdr,
            qlinstg.minisite_id_hdr,
            qlinstg.cust_party_id,
            qlinstg.quote_status_id,
            qlinstg.sales_channel_code,
            qlinstg.org_id,
            qlinstg.order_id,
            qlinstg.currency_code,
            qlinstg.reporting_currency,
            qlinstg.functional_currency,
            qlinstg.reporting_conversion_rate,
            qlinstg.functional_conversion_rate,
            qlinstg.sec_conversion_rate,
            qlinstg.shipment_id,
            qlinstg.line_value,
            qlinstg.line_quote_value,
            qlinstg.quantity,
            qlinstg.uom_code,
            qlinstg.minisite_id,
            qlinstg.marketing_source_code_id,
            qlinstg.inventory_item_id,
            qlinstg.organization_id,
            qlinstg.invoice_to_cust_account_id,
            qlinstg.agreement_id,
            qlinstg.quote_line_id,
            qlinstg.line_category_code,
            qlinstg.marketing_source_code_id_hdr,
            null publish_flag,
            :l_sysdate,
            :l_user_id,
            :l_sysdate,
            :l_user_id,
            :l_login_id,
            qlinstg.order_creation_date,
            FIRST_VALUE(inventory_item_id)OVER(
              PARTITION BY config_header_id
              ORDER BY config_item_id ASC
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                  Top_Inventory_Item_Id,
            FIRST_VALUE(organization_id)OVER(
              PARTITION BY config_header_id
              ORDER BY config_item_id ASC
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                  Top_Organization_Id,
              qlinstg.Charge_periodicity_code
    FROM
          ASO_BI_QUOTE_LINES_STG qlinstg
    WHERE Config_Header_Id IS NOT NULL'
    USING   l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            l_login_id;

    COMMIT;

    EXECUTE IMMEDIATE
    'INSERT/*+ append */ INTO ASO_BI_QUOTE_LINES_ALL
    ( quote_header_id,
      quote_number,
      quote_version,
      quote_creation_date,
      quote_last_update_date,
      quote_expiration_date,
      resource_id,
      resource_grp_id,
      quote_source_code,
      cust_account_id,
      invoice_to_cust_account_id_hdr,
      minisite_id_hdr,
      cust_party_id,
      quote_status_id,
      sales_channel_code,
      org_id,
      order_id,
      currency_code,
      reporting_currency,
      functional_currency,
      reporting_conversion_rate,
      functional_conversion_rate,
      sec_conversion_rate,
      shipment_id,
      line_value,
      line_quote_value,
      quantity,
      uom_code,
      minisite_id,
      marketing_source_code_id,
      inventory_item_id,
      organization_id,
      invoice_to_cust_account_id,
      agreement_id,
      quote_line_id,
      line_category_code,
      marketing_source_code_id_hdr,
      publish_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      order_creation_date,
      Top_Inventory_Item_Id,
      Top_Organization_Id,
      Charge_periodicity_code
    )
    SELECT
            qlinstg.quote_header_id,
            qlinstg.quote_number,
            qlinstg.quote_version,
            qlinstg.quote_creation_date,
            qlinstg.quote_last_update_date,
            qlinstg.quote_expiration_date,
            qlinstg.resource_id,
            qlinstg.resource_grp_id,
            qlinstg.quote_source_code,
            qlinstg.cust_account_id,
            qlinstg.invoice_to_cust_account_id_hdr,
            qlinstg.minisite_id_hdr,
            qlinstg.cust_party_id,
            qlinstg.quote_status_id,
            qlinstg.sales_channel_code,
            qlinstg.org_id,
            qlinstg.order_id,
            qlinstg.currency_code,
            qlinstg.reporting_currency,
            qlinstg.functional_currency,
            qlinstg.reporting_conversion_rate,
            qlinstg.functional_conversion_rate,
            qlinstg.sec_conversion_rate,
            qlinstg.shipment_id,
            qlinstg.line_value,
            qlinstg.line_quote_value,
            qlinstg.quantity,
            qlinstg.uom_code,
            qlinstg.minisite_id,
            qlinstg.marketing_source_code_id,
            qlinstg.inventory_item_id,
            qlinstg.organization_id,
            qlinstg.invoice_to_cust_account_id,
            qlinstg.agreement_id,
            qlinstg.quote_line_id,
            qlinstg.line_category_code,
            qlinstg.marketing_source_code_id_hdr,
            null publish_flag,
            :l_sysdate,
            :l_user_id,
            :l_sysdate,
            :l_user_id,
            :l_login_id,
            qlinstg.order_creation_date,
            Inventory_item_id Top_Inventory_Item_Id,
            Organization_id Top_Organization_Id,
            qlinstg.Charge_periodicity_code
    FROM
          ASO_BI_QUOTE_LINES_STG qlinstg
    WHERE Config_Header_Id IS NULL'
    USING   l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            l_login_id;

    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Done populating the Quote line fact '||
                                   'Staging:Rowcount: '||SQL%ROWCOUNT);
    END IF;

    COMMIT;

 END Populate_Line_data;



 -- This procedure is called as a part of incremental load of quote lines.
 -- Populates ASO_BI_QUOTE_LINES_STG table
 PROCEDURE Line_Worker(
   Errbuf   IN OUT NOCOPY VARCHAR2,
   Retcode  IN OUT NOCOPY NUMBER,
   p_worker_no IN NUMBER)
 AS
  l_unassigned_cnt NUMBER := 0;
  l_failed_cnt     NUMBER := 0;
  l_comp_cnt       NUMBER := 0;
  l_total_cnt      NUMBER := 0;
  l_count          NUMBER := 0;
  l_batch_id       NUMBER := 0;
 BEGIN
  errbuf := NULL;
  retcode := 0;

 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_QOT_LINE_SUBWORKER'||p_worker_no)) = false
 THEN
   errbuf := FND_MESSAGE.Get;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 END IF;

  IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('ASO_BI_QOT_LINE_SUBWORKER'||p_worker_no||
                                 ' starting.');
  END IF;

  -- This call is to populate functional currency again
  -- as each of these subworkers are started in a new session
  -- and we are using a global session temporary table
  -- for storing functional currency
--  ASO_BI_LINE_FACT_PVT.Get_Functional_Currency;

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
    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Another worker have errored out.'||
                                        ' Stop Processing.');
    END IF;
    Exit;
   Elsif (l_unassigned_cnt = 0) Then
    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('No More jobs left.Terminating.');
    END IF;
    EXIT;
   Elsif( l_comp_cnt = l_total_cnt) Then
    IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
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
   END IF;
   COMMIT;

   If (l_count > 0) Then
    BEGIN
      SELECT batch_id
        INTO l_batch_id
        FROM ASO_BI_QUOTE_FACT_JOBS
      WHERE  worker_number = p_worker_no
        AND  status = 'IN_PROCESS';

      IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
        BIS_COLLECTION_UTILITIES.Debug('Start populate line Staging:'||
                               TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
      END IF;

      POPULATE_QOT_LINE_FACT_STG(p_batch_id => l_batch_id);

      IF (BIS_COLLECTION_UTILITIES.g_debug) THEN
        BIS_COLLECTION_UTILITIES.Debug('End populate line Staging:'||
                               TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
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
   END IF; --if l_count > 0
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
 END Line_Worker;

END ASO_BI_LINE_FACT_PVT;

/
