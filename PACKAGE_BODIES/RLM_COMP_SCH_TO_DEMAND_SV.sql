--------------------------------------------------------
--  DDL for Package Body RLM_COMP_SCH_TO_DEMAND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_COMP_SCH_TO_DEMAND_SV" as
/* $Header: RLMCOMDB.pls 120.1 2005/07/17 18:25:15 rlanka noship $*/
/*=============================================================================

  PROCEDURE NAME: proc_comp_sch_to_demand

  ==============================================================================*/

  PROCEDURE  proc_comp_sch_to_demand
                         (p_schedule_type             IN      VARCHAR2,
                          p_header_id                 IN      NUMBER    :=NULL,
                          p_Customer_name_from        IN      VARCHAR2  :=NULL,
                          p_customer_name_to          IN      varchar2  :=NULL,
                          p_ship_from_org_id          IN      NUMBER    :=NULL,
                          p_ship_to                   IN      NUMBER    :=NULL,
                          p_tp_code_from              IN      VARCHAR2  :=NULL,
                          p_tp_code_to                IN      VARCHAR2  :=NULL,
                          p_tp_location_from          IN      VARCHAR2  :=NULL,
                          p_tp_location_to            IN      VARCHAR2  :=NULL,
                          p_process_date_from         IN      VARCHAR2  :=NULL,
                          p_process_date_to           IN      VARCHAR2  :=NULL,
                          p_issue_date_from           IN      VARCHAR2  :=NULL,
                          p_issue_date_to             IN      VARCHAR2  :=NULL,
                          p_request_date_from         IN      VARCHAR2  :=NULL,
                          p_request_date_to           IN      VARCHAR2  :=NULL,
                          p_customer_item_from        IN      VARCHAR2  :=NULL,
                          p_customer_item_to          IN      VARCHAR2  :=NULL,
                          p_internal_item_from        IN      VARCHAR2  :=NULL,
                          p_internal_item_to          IN      VARCHAR2  :=NULL,
                          p_demand_type               IN      VARCHAR2  :=NULL
                         )
  IS

    TYPE t_match_attributes IS RECORD (
      Attribute_Name       VARCHAR2(80),
      within_key           VARCHAR2(20),
      across_key           VARCHAR2(20)
    );

    TYPE tab_match_attribute IS TABLE OF t_match_attributes INDEX BY BINARY_INTEGER;

    l_match_attribute     tab_match_attribute ;
    l_Count               NUMBER       := 1;
    l_Buckets             NUMBER       := 1;
    l_WholeNumber         BOOLEAN      :=TRUE;
    l_LastDayQuarter      DATE;
    l_WeeksInQuarter      NUMBER := 12;
    l_customer_id         NUMBER := -9999;
    l_ship_from           NUMBER := -9999;
    l_ship_to             NUMBER := -9999;
    l_customer_item_id    number := -9999;
    l_terms_rec           RLM_SETUP_TERMS_SV.setup_terms_rec_typ;
    l_return_message      varchar2(32767);
    l_return_status       Boolean;
    l_NULL                varchar2(32767);
    l_ship_del_pattern    VARCHAR2(240);
    l_week_name           varchar2(150)  DEFAULT NULL;
    l_frozen_day_from     number;
    l_frozen_day_to       number;
    l_firm_day_from       number;
    l_firm_day_to         number;
    l_forecast_day_from   number;
    l_forecast_day_to     number;
    v_item_detail_quantity number ;
    l_frozen_flag         varchar2(1);
    l_inputrec        rlm_ship_delivery_pattern_sv.t_InputRec;

    CURSOR csr_sdp(p_ship_del_pattern IN VARCHAR2) IS
      SELECT description
      FROM  rlm_ship_delivery_codes
      WHERE ship_delivery_rule_name = p_ship_del_pattern;


    CURSOR cur_comp_sch_to_demand
    IS
      SELECT    schheaders.header_id                      header_id,
                schheaders.customer_id                    customer_id,
                hzparties.party_name              	  customer_name,
                schheaders.schedule_type                  schedule_type ,
                schheaders.sched_generation_date          sched_generation_date,
                schheaders.schedule_source                schedule_source,
                schheaders.ece_tp_translator_code         ece_tp_translator_code,
                schheaders.ece_tp_location_code_ext       ece_tp_location_code_ext,
                schheaders.schedule_reference_num         schedule_reference_num,
                schheaders.schedule_purpose               schedule_purpose,
                schheaders.sched_horizon_start_date       sched_horizon_start_date,
                schheaders.sched_horizon_end_date         sched_horizon_end_date,
                schheaders.last_update_date               last_update_date,
                schheaders.creation_date                  creation_date,
                schlines.ship_from_org_id                 ship_from_org_id,
                schlines.ship_to_org_id                   ship_to_org_id,
                schlines.ship_to_address_id               ship_to_address_id,
                schlines.inventory_item_id                inventory_item_id,
                schlines.customer_item_id                 customer_item_id,
                invitems.segment1                      inventory_item_number,
                cusitems.customer_item_number             customer_item_number,
                invitems.description                      inventory_item_desc,
                cusitems.customer_item_desc               customer_item_desc,
                schlines.start_date_time                  start_date_time,
                schlines.end_date_time                    end_date_time,
                schlines.line_id                          line_id ,
                schlines.order_header_id                  order_header_id,
                schlines.item_detail_quantity             item_detail_quantity,
                schlines.uom_code                         uom_code,
                schlines.item_detail_subtype              item_detail_subtype,
                schlines.item_detail_type                 item_detail_type,
                schlines.qty_type_code                    qty_type_code,
                schlines.date_type_code                   date_type_code,
                schlines.customer_job                     customer_job,
                schlines.cust_production_line             cust_production_line,
                schlines.cust_production_seq_num          cust_production_seq_num,
                schlines.cust_model_serial_number         cust_model_serial_number,
                schlines.cust_po_number                   cust_po_number,
                schlines.customer_item_revision           customer_item_revision,
                schlines.Customer_docK_Code               Customer_docK_Code,
                schlines.industry_attribute1              record_year,
                schlines.industry_attribute2              customer_request_date,
                schlines.industry_attribute4              pull_signal_ref_num,
                schlines.industry_attribute5              pull_signal_start_serial_num ,
                schlines.industry_attribute6              pull_signal_end_serial_num

        --
        FROM    rlm_schedule_headers      schheaders,
                rlm_schedule_lines_all    schlines,
                mtl_customer_items        cusitems,
                mtl_system_items_b        invitems,
                hz_parties                hzparties ,
                hz_cust_accounts          hzcustacc
        --
        WHERE schheaders.ORG_ID = schlines.ORG_ID
        AND   schheaders.schedule_type      =  P_SCHEDULE_TYPE
        AND   schlines.item_detail_subtype  IN ('1','2','4','5')
        AND   ((p_demand_type = 'O'AND schlines.item_detail_type = '2') OR
              (p_demand_type = 'F' AND schlines.item_detail_type = '1') OR
              (p_demand_type = 'B' AND schlines.item_detail_type IN ('0', '1', '2')))
        AND   hzparties.party_id  =  hzcustacc.party_id
        AND   hzcustacc.cust_account_id = schheaders.customer_id
        AND   cusitems.customer_id = schheaders.customer_id
        AND   schlines.customer_item_id = cusitems.customer_item_id
        AND   schlines.inventory_item_id = invitems.inventory_item_id
        AND   schlines.ship_from_org_id  = invitems.organization_id
        AND   schlines.qty_type_code <> 'CUMULATIVE'
        AND   schlines.process_status = 5
        AND   schheaders.Process_status  IN (5,7)
        AND   schheaders.edi_test_indicator <> 'T'
        AND   schheaders.header_id      =  schlines.header_id
        AND ((p_customer_name_from IS NULL)  oR  (hzparties.party_name >=p_customer_name_from and
                hzparties.party_name <=p_customer_name_to))
        AND ((p_header_id  IS NULL) OR (schheaders.header_id = p_header_id))
        AND ((p_ship_from_org_id IS NULL) OR (schlines.ship_from_org_id = p_ship_from_org_id))
        AND ((p_ship_to  IS NULL) OR (schlines.ship_to_address_id = p_ship_to))
        AND ((p_tp_code_from IS NULL) OR (schheaders.ece_tp_translator_code >= p_tp_code_from
                               AND schheaders.ece_tp_translator_code <= p_tp_code_to))
        AND  ((p_tp_location_from IS NULL)OR (schheaders.ece_tp_location_code_ext >=p_tp_location_from
                               AND schheaders.ece_tp_location_code_ext <= p_tp_location_to))
        AND  ((p_process_date_from IS NULL) OR
                   (schheaders.creation_date >= to_date(p_process_date_from,'yyyy/MM/DD HH24:MI:SS')
               AND schheaders.creation_date <= to_date(p_process_date_to,'yyyy/MM/DD HH24:MI:SS')))
        AND  ((p_issue_date_from IS NULL) OR
                    (schheaders.sched_generation_date >= to_date(p_issue_date_from,'yyyy/MM/DD HH24:MI:SS')
               AND schheaders.sched_generation_date <=to_date(p_issue_date_to,'yyyy/MM/DD HH24:MI:SS')))
        AND  ((p_request_date_from IS NULL)  OR
                     (schlines.start_date_time >= to_date(p_request_date_from,'yyyy/MM/DD HH24:MI:SS')
                AND schlines.start_date_time <= to_date(p_request_date_to,'yyyy/MM/DD HH24:MI:SS')))
        AND  ((p_customer_item_from IS NULL) OR (cusitems.customer_item_number >= p_customer_item_from
                               AND cusitems.customer_item_number <= p_customer_item_to))
        AND  ((p_internal_item_from IS NULL) OR (invitems.segment1 >= p_internal_item_from
                               AND invitems.segment1 <= p_internal_item_to))
        AND  schlines.customer_item_id NOT IN (
                SELECT corr_schlines.customer_item_id
                        --
                FROM   rlm_schedule_headers  corr_schheaders,
                       rlm_schedule_lines_all    corr_schlines,
                       mtl_customer_items        corr_cusitems,
                       mtl_system_items_b        corr_invitems,
                       hz_parties                corr_hzparties,
                       hz_cust_accounts          corr_hzcustacc
                        --
               WHERE corr_schheaders.ORG_ID = corr_schlines.ORG_ID
               AND   corr_schheaders.customer_id       =  schheaders.customer_id
               AND   corr_schheaders.schedule_type      =  schheaders.schedule_type
               AND   corr_schheaders.last_update_date   >  Schheaders.last_update_date
               AND   corr_hzparties.party_id  =  corr_hzcustacc.party_id
               AND   corr_hzcustacc.cust_account_id = corr_schheaders.customer_id
               AND   corr_cusitems.customer_id =  corr_schheaders.customer_id
               AND   corr_schlines.customer_item_id = corr_cusitems.customer_item_id
               AND   corr_schlines.inventory_item_id = corr_invitems.inventory_item_id
               AND   corr_schlines.ship_from_org_id  = corr_invitems.organization_id
               AND   ((p_demand_type = 'O' AND corr_schlines.item_detail_type = '2') OR
                      (p_demand_type = 'F' AND corr_schlines.item_detail_type = '1') OR
                      (p_demand_type = 'B' AND corr_schlines.item_detail_type IN ('0', '1', '2')))
               AND   corr_schlines.qty_type_code <> 'CUMULATIVE'
               AND   corr_schlines.item_detail_subtype  IN ('1','2','4','5')
               AND   corr_schheaders.Process_status     IN (5, 7)
               AND   corr_schlines.process_status =   5
               AND   corr_schheaders.edi_test_indicator <> 'T'
               AND   corr_schlines.header_id        = corr_schheaders.header_id
               AND ((p_header_id  IS NULL) OR (corr_schheaders.header_id = p_header_id))
               AND ((p_customer_name_from IS NULL)  oR  (corr_hzparties.party_name >=p_customer_name_from and
                      corr_hzparties.party_name <=p_customer_name_to))
               AND ((p_ship_from_org_id IS NULL) OR (corr_schlines.ship_from_org_id = p_ship_from_org_id))
               AND ((p_ship_to  IS NULL) OR (corr_schlines.ship_to_address_id = p_ship_to))
               AND  ((p_tp_code_from IS NULL) OR (corr_schheaders.ece_tp_translator_code >=
                     p_tp_code_from AND corr_schheaders.ece_tp_translator_code <= p_tp_code_to))
               AND  ((p_tp_location_from IS NULL) OR (corr_schheaders.ece_tp_location_code_ext >=
                  p_tp_location_from AND corr_schheaders.ece_tp_location_code_ext <= p_tp_location_to))
               AND  ((p_process_date_from IS NULL) OR
                       (corr_schheaders.creation_date >=to_date(p_process_date_from,'yyyy/MM/DD HH24:MI:SS')
                    AND corr_schheaders.creation_date <=to_date(p_process_date_to,'yyyy/MM/DD HH24:MI:SS')))
               AND  ((p_issue_date_from IS NULL) OR
                       (corr_schheaders.sched_generation_date >= to_date(p_issue_date_from,'yyyy/MM/DD HH24:MI:SS')
                    AND corr_schheaders.sched_generation_date <= to_date(p_issue_date_to,'yyyy/MM/DD HH24:MI:SS')))
               AND  ((p_request_date_from IS NULL)  OR
                       (corr_schlines.start_date_time >= to_date(p_request_date_from,'yyyy/MM/DD HH24:MI:SS')
                    AND  corr_schlines.start_date_time <= to_date(p_request_date_to,'yyyy/MM/DD HH24:MI:SS')))
               AND  ((p_customer_item_from IS NULL) OR (corr_cusitems.customer_item_number >= p_customer_item_from
                               AND corr_cusitems.customer_item_number <= p_customer_item_to))
               AND  ((p_internal_item_from IS NULL) OR (corr_invitems.segment1 >= p_internal_item_from
                               AND corr_invitems.segment1 <= p_internal_item_to))

               ) ORDER BY schheaders.customer_id, ship_from_org_id, ship_to_org_id, schlines.customer_item_id;

      /*=============================================================================

      PROCEDURE NAME: populate_within_across

      ==============================================================================*/

      PROCEDURE populate_within_across
      IS
         l_Iterations          NUMBER ;
         l_match_Within_key    VARCHAR2(20) :=NULL;
         l_match_Across_key    VARCHAR2(20) :=NULL;
         l_Within_key          VARCHAR2(20) :=NULL;
         l_Across_key          VARCHAR2(20) :=NULL;
         l_attribute_name      varchar2(80) :=NULL;
         l_attribute_found     VARCHAR2(1)  :='N';

      BEGIN

         l_match_Within_key := replace(l_terms_rec.match_within_key, '0');
         l_match_across_key := replace(l_terms_rec.match_across_key, '0');

         FOR i in 1..nvl(length(l_match_Within_key),0)
         LOOP

            l_within_key := substr(l_match_Within_key,i,1);

            BEGIN
               SELECT meaning
               INTO   l_attribute_name
               FROM   FND_LOOKUP_VALUES_VL
               WHERE  LOOKUP_TYPE = 'RLM_OPTIONAL_MATCH_ATTRIBUTES'
               AND    ENABLED_FLAG = 'Y'
               AND    SUBSTR(LOOKUP_CODE, INSTR(LOOKUP_CODE, ',') + 1) = l_Within_key ;
            EXCEPTION
              WHEN OTHERS THEN
                l_attribute_name := null;
            END;

           l_match_attribute(i).Attribute_Name := l_attribute_name;
           l_match_attribute(i).within_key     := l_within_key;

       END LOOP;

         FOR i in 1..nvl(length(l_match_across_key),0)
         LOOP

            l_Across_key := substr(l_match_across_key, i, 1);

            IF l_match_attribute.count > 0 THEN
               FOR j in 1..l_match_attribute.count
               LOOP

                 IF l_Across_key = l_match_attribute(j).within_key THEN
                    l_match_attribute(j).across_key := l_Across_key;
                    l_attribute_found := 'Y';
                    EXIT;
                 END IF;
               END LOOP;
            END IF;

             IF NOT (l_attribute_found = 'Y') THEN

               BEGIN
                  SELECT meaning
                  INTO   l_attribute_name
                  FROM   FND_LOOKUP_VALUES_VL
                  WHERE  LOOKUP_TYPE = 'RLM_OPTIONAL_MATCH_ATTRIBUTES'
                  AND    ENABLED_FLAG = 'Y'
                  AND    SUBSTR(LOOKUP_CODE, INSTR(LOOKUP_CODE, ',') + 1) = l_across_key ;
               EXCEPTION
                  WHEN OTHERS THEN
                    l_attribute_name := null;
                END;

               l_match_attribute(l_match_attribute.count+1).Attribute_name := l_attribute_name;
               l_match_attribute(l_match_attribute.count).across_key       := l_Across_key;

         END IF;

         l_attribute_found := 'N';

        END LOOP;

      END populate_within_across;
      ------------------------------------------------------------------------------------

      /*=============================================================================

      PROCEDURE NAME: insert_rlm_attributes

      ==============================================================================*/

      PROCEDURE insert_rlm_attributes ( P_CUSTOMER_ID              NUMBER,
                                        P_SHIP_FROM_ORG_ID         NUMBER,
                                        P_SHIP_TO_ORG_ID           NUMBER,
                                        P_SHIP_TO_ADDRESS_ID       NUMBER,
                                        P_CUSTOMER_ITEM_ID         NUMBER,
                                        P_CUSTOMER_ITEM_NUMBER     VARCHAR2,
                                        P_CUSTOMER_ITEM_DESC       VARCHAR2,
                                        P_FROZEN_DAY_FROM          NUMBER,
                                        P_FROZEN_DAY_TO            NUMBER,
                                        P_FIRM_DAY_FROM            NUMBER,
                                        P_FIRM_DAY_TO              NUMBER,
                                        P_FORECAST_DAY_FROM        NUMBER,
                                        P_FORECAST_DAY_TO          NUMBER,
                                        P_INTRANSIT_TIME           NUMBER,
                                        P_TIME_UOM_CODE            VARCHAR2,
                                        P_SHIP_DELIVERY_PATTERN    VARCHAR2,
                                        P_ROUND_TO_STANDARD_PACK   NUMBER,
                                        P_INVENTORY_ITEM_ID        NUMBER,
                                        P_INVENTORY_ITEM_NUMBER    VARCHAR2,
                                        P_INVENTORY_ITEM_DESC      VARCHAR2,
                                        P_CUM_CONTROL_CODE         VARCHAR2,
                                        P_CUM_ORG_LEVEL_CODE       VARCHAR2,
                                        P_CUM_SHIPMENT_RULE_CODE   VARCHAR2,
                                        P_CUM_YESTERD_TIME_CUTOFF  NUMBER,
                                        P_UNSHIP_FIRM_CUTOFF_DAYS  NUMBER,
                                        P_UNSHIPPED_FIRM_DISP_CD   VARCHAR2,
                                        P_INTRANSIT_CALC_BASIS     VARCHAR2,
                                        P_SCH_LINE_ID              NUMBER,
                                        P_SCH_HEADER_ID            NUMBER,
                                        P_FROZEN_FLAG              VARCHAR2,
                                   P_EXCLUDE_NON_WORKDAYS_FLAG     VARCHAR2
                                        )
      IS
      BEGIN

         INSERT INTO RLM_MATCH_SETUP_TEMP (CUSTOMER_ID       ,
                                           SHIP_FROM_ORG_ID       ,
                                           SHIP_TO_ORG_ID         ,
                                           SHIP_TO_ADDRESS_ID     ,
                                           CUSTOMER_ITEM_ID       ,
                                           CUSTOMER_ITEM_NUMBER   ,
                                           CUSTOMER_ITEM_DESC     ,
                                           FROZEN_DAY_FROM        ,
                                           FROZEN_DAY_TO          ,
                                           FIRM_DAY_FROM          ,
                                           FIRM_DAY_TO            ,
                                           FORECAST_DAY_FROM      ,
                                           FORECAST_DAY_TO        ,
                                           INTRANSIT_TIME         ,
                                           TIME_UOM_CODE          ,
                                           SHIP_DELIVERY_PATTERN  ,
                                           ROUND_TO_STANDARD_PACK ,
                                           INVENTORY_ITEM_ID      ,
                                           INVENTORY_ITEM_NUMBER  ,
                                           INVENTORY_ITEM_DESC    ,
                                           CUM_CONTROL_CODE       ,
                                           CUM_ORG_LEVEL_CODE     ,
                                           CUM_SHIPMENT_RULE_CODE ,
                                           CUM_YESTERD_TIME_CUTOFF,
                                           UNSHIP_FIRM_CUTOFF_DAYS,
                                           UNSHIPPED_FIRM_DISP_CD ,
                                           INTRANSIT_CALC_BASIS   ,
                                           SCH_LINE_ID            ,
                                           SCH_HEADER_ID          ,
                                           FROZEN_FLAG            ,
                                           EXCLUDE_NON_WORKDAYS_FLAG
                                        )
                                VALUES (
                                        P_CUSTOMER_ID             ,
                                        P_SHIP_FROM_ORG_ID        ,
                                        P_SHIP_TO_ORG_ID          ,
                                        P_SHIP_TO_ADDRESS_ID      ,
                                        P_CUSTOMER_ITEM_ID        ,
                                        P_CUSTOMER_ITEM_NUMBER    ,
                                        P_CUSTOMER_ITEM_DESC      ,
                                        P_FROZEN_DAY_FROM         ,
                                        P_FROZEN_DAY_TO           ,
                                        P_FIRM_DAY_FROM           ,
                                        P_FIRM_DAY_TO             ,
                                        P_FORECAST_DAY_FROM       ,
                                        P_FORECAST_DAY_TO         ,
                                        P_INTRANSIT_TIME          ,
                                        P_TIME_UOM_CODE           ,
                                        P_SHIP_DELIVERY_PATTERN   ,
                                        P_ROUND_TO_STANDARD_PACK  ,
                                        P_INVENTORY_ITEM_ID       ,
                                        P_INVENTORY_ITEM_NUMBER   ,
                                        P_INVENTORY_ITEM_DESC     ,
                                        P_CUM_CONTROL_CODE        ,
                                        P_CUM_ORG_LEVEL_CODE      ,
                                        P_CUM_SHIPMENT_RULE_CODE  ,
                                        P_CUM_YESTERD_TIME_CUTOFF ,
                                        P_UNSHIP_FIRM_CUTOFF_DAYS ,
                                        P_UNSHIPPED_FIRM_DISP_CD  ,
                                        P_INTRANSIT_CALC_BASIS    ,
                                        P_SCH_LINE_ID             ,
                                        P_SCH_HEADER_ID           ,
                                        P_FROZEN_FLAG ,
                                        P_EXCLUDE_NON_WORKDAYS_FLAG);

      END insert_rlm_attributes;
      ------------------------------------------------------------------------------------

      /*=============================================================================

      PROCEDURE NAME: insert_rlm_comp_sch_to_demand
      ==============================================================================*/


      PROCEDURE insert_rlm_comp_sch_to_demand( P_SCH_HEADER_ID                  NUMBER,
                                           P_CUSTOMER_ID                    NUMBER,
                                           P_SCHEDULE_TYPE                  VARCHAR2,
                                           P_SCHED_HORIZON_END_DATE         DATE,
                                           P_SCHED_HORIZON_START_DATE       DATE,
                                           P_SCHEDULE_SOURCE                VARCHAR2 ,
                                           P_SCHEDULE_PURPOSE               VARCHAR2,
                                           P_SCHEDULE_REFERENCE_NUM         VARCHAR2,
                                           P_SCHED_GENERATION_DATE          DATE,
                                           P_ECE_TP_LOCATION_CODE_EXT       VARCHAR2,
                                           P_ECE_TP_TRANSLATOR_CODE         VARCHAR2,
                                           P_LAST_UPDATE_DATE               DATE ,
                                           P_CREATION_DATE                  DATE,
                                           P_SCH_LINE_ID                    NUMBER,
                                           P_CUSTOMER_ITEM_ID               NUMBER,
                                           P_DATE_TYPE_CODE                 VARCHAR2,
                                           P_EDI_TEST_INDICATOR             VARCHAR2,
                                           P_INVENTORY_ITEM_ID              NUMBER,
                                           P_ITEM_DETAIL_SUBTYPE            VARCHAR2,
                                           P_ITEM_DETAIL_TYPE               VARCHAR2,
                                           P_QTY_TYPE_CODE                  VARCHAR2,
                                           P_START_DATE_TIME                DATE,
                                           P_END_DATE_TIME                  DATE,
                                           P_ITEM_DETAIL_QUANTITY           NUMBER,
                                           P_UOM_CODE                       VARCHAR2,
                                           P_SHIP_FROM_ORG_ID               NUMBER,
                                           P_SHIP_TO_ORG_ID                 NUMBER,
                                           P_SHIP_TO_ADDRESS_ID             NUMBER,
                                           P_INTMED_SHIP_TO_ORG_ID          NUMBER,
                                           P_CUSTOMER_DOCK_CODE             VARCHAR2,
                                           P_CUSTOMER_JOB                   VARCHAR2,
                                           P_CUST_MODEL_SERIAL_NUMBER       VARCHAR2,
                                           P_CUST_PRODUCTION_LINE           VARCHAR2,
                                           P_CUST_PRODUCTION_SEQ_NUM        VARCHAR2,
                                           P_WEEK_START_DATE                DATE,
                                           P_WEEK_SCHEDULE_QTY              NUMBER,
                                           P_WEEK_END_DATE                  DATE,
                                           P_ORDER_HEADER_ID                NUMBER,
                                           P_CUST_PO_NUMBER                 VARCHAR2,
                                           P_CUSTOMER_ITEM_REVISION         VARCHAR2,
                                           P_PULL_SIGNAL_START_SERIAL_NUM   VARCHAR2,
                                           P_PULL_SIGNAL_END_SERIAL_NUM     VARCHAR2 ,
                                           P_PULL_SIGNAL_REF_NUM            VARCHAR2,
                                           P_CUSTOMER_REQUEST_DATE          VARCHAR2,
                                           P_RECORD_YEAR                    VARCHAR2,
                                           P_WEEK_NAME                      VARCHAR2 ,
                                           P_CUSTOMER_NAME                  VARCHAR2)
     IS

     BEGIN

        INSERT INTO rlm_comp_sched_to_demand_temp (
                                           SCH_HEADER_ID ,
                                           CUSTOMER_ID,
                                           SCHEDULE_TYPE ,
                                           SCHED_HORIZON_END_DATE,
                                           SCHED_HORIZON_START_DATE,
                                           SCHEDULE_SOURCE ,
                                           SCHEDULE_PURPOSE,
                                           SCHEDULE_REFERENCE_NUM,
                                           SCHED_GENERATION_DATE,
                                           ECE_TP_LOCATION_CODE_EXT,
                                           ECE_TP_TRANSLATOR_CODE,
                                           LAST_UPDATE_DATE,
                                           CREATION_DATE,
                                           SCH_LINE_ID ,
                                           CUSTOMER_ITEM_ID,
                                           DATE_TYPE_CODE ,
                                           EDI_TEST_INDICATOR,
                                           INVENTORY_ITEM_ID,
                                           ITEM_DETAIL_SUBTYPE,
                                           ITEM_DETAIL_TYPE,
                                           QTY_TYPE_CODE ,
                                           START_DATE_TIME,
                                           END_DATE_TIME,
                                           ITEM_DETAIL_QUANTITY,
                                           UOM_CODE ,
                                           SHIP_FROM_ORG_ID,
                                           SHIP_TO_ORG_ID ,
                                           SHIP_TO_ADDRESS_ID ,
                                           INTMED_SHIP_TO_ORG_ID,
                                           CUSTOMER_DOCK_CODE ,
                                           CUSTOMER_JOB  ,
                                           CUST_MODEL_SERIAL_NUMBER,
                                           CUST_PRODUCTION_LINE,
                                           CUST_PRODUCTION_SEQ_NUM,
                                           WEEK_START_DATE,
                                           WEEK_SCHEDULE_QTY,
                                           WEEK_END_DATE,
                                           ORDER_HEADER_ID,
                                           CUST_PO_NUMBER,
                                           CUSTOMER_ITEM_REVISION,
                                           PULL_SIGNAL_START_SERIAL_NUM,
                                           PULL_SIGNAL_END_SERIAL_NUM,
                                           PULL_SIGNAL_REF_NUM,
                                           CUSTOMER_REQUEST_DATE,
                                           RECORD_YEAR,
                                           WEEK_NAME,
                                           CUSTOMER_NAME )
                                 VALUES   (P_SCH_HEADER_ID                 ,
                                           P_CUSTOMER_ID                   ,
                                           P_SCHEDULE_TYPE                 ,
                                           P_SCHED_HORIZON_END_DATE        ,
                                           P_SCHED_HORIZON_START_DATE      ,
                                           P_SCHEDULE_SOURCE               ,
                                           P_SCHEDULE_PURPOSE              ,
                                           P_SCHEDULE_REFERENCE_NUM        ,
                                           P_SCHED_GENERATION_DATE         ,
                                           P_ECE_TP_LOCATION_CODE_EXT      ,
                                           P_ECE_TP_TRANSLATOR_CODE        ,
                                           P_LAST_UPDATE_DATE              ,
                                           P_CREATION_DATE                 ,
                                           P_SCH_LINE_ID                   ,
                                           P_CUSTOMER_ITEM_ID              ,
                                           P_DATE_TYPE_CODE                ,
                                           P_EDI_TEST_INDICATOR            ,
                                           P_INVENTORY_ITEM_ID             ,
                                           P_ITEM_DETAIL_SUBTYPE           ,
                                           P_ITEM_DETAIL_TYPE              ,
                                           P_QTY_TYPE_CODE                 ,
                                           P_START_DATE_TIME               ,
                                           P_END_DATE_TIME                 ,
                                           P_ITEM_DETAIL_QUANTITY          ,
                                           P_UOM_CODE                      ,
                                           P_SHIP_FROM_ORG_ID              ,
                                           P_SHIP_TO_ORG_ID                ,
                                           P_SHIP_TO_ADDRESS_ID            ,
                                           P_INTMED_SHIP_TO_ORG_ID         ,
                                           P_CUSTOMER_DOCK_CODE            ,
                                           P_CUSTOMER_JOB                  ,
                                           P_CUST_MODEL_SERIAL_NUMBER      ,
                                           P_CUST_PRODUCTION_LINE          ,
                                           P_CUST_PRODUCTION_SEQ_NUM       ,
                                           P_WEEK_START_DATE               ,
                                           P_WEEK_SCHEDULE_QTY             ,
                                           P_WEEK_END_DATE                 ,
                                           P_ORDER_HEADER_ID               ,
                                           P_CUST_PO_NUMBER                ,
                                           P_CUSTOMER_ITEM_REVISION        ,
                                           P_PULL_SIGNAL_START_SERIAL_NUM  ,
                                           P_PULL_SIGNAL_END_SERIAL_NUM    ,
                                           P_PULL_SIGNAL_REF_NUM           ,
                                           P_CUSTOMER_REQUEST_DATE         ,
                                           P_RECORD_YEAR                   ,
                                           P_WEEK_NAME                     ,
                                           P_CUSTOMER_NAME                ) ;
     END insert_rlm_comp_sch_to_demand;
     --------------------------------------------------------------------------------------

  --
  -- Main Procedure begins here
  --

  BEGIN
    --
    FOR v_cur_comp_sch_to_demand IN cur_comp_sch_to_demand  LOOP

       IF (l_customer_id = -9999 AND l_ship_from = -9999 AND l_ship_to = -9999 AND l_customer_item_id = -9999) OR
               (l_customer_id <> v_cur_comp_sch_to_demand.customer_id
                OR  l_ship_from <> v_cur_comp_sch_to_demand.ship_from_org_id
                OR  l_ship_to <> v_cur_comp_sch_to_demand.ship_to_address_id
                OR  l_customer_item_id <> v_cur_comp_sch_to_demand.customer_item_id)
       THEN

             RLM_TPA_SV.get_setup_terms (   v_cur_comp_sch_to_demand.ship_from_org_id,
	 		                            v_cur_comp_sch_to_demand.customer_id ,
	 		                            v_cur_comp_sch_to_demand.ship_to_address_id,
	 		                            v_cur_comp_sch_to_demand.customer_item_id,
	 		                            l_NULL,
	 		                            l_terms_rec ,
	 		                            l_return_message ,
	 		                            l_return_status
	 				);

         OPEN csr_sdp(l_terms_rec.ship_delivery_rule_name);
         FETCH csr_sdp INTO l_ship_del_pattern;
         CLOSE csr_sdp;

         IF P_SCHEDULE_TYPE ='SHIPPING' THEN

           l_frozen_day_from   := l_terms_rec.shp_frozen_day_from;
           l_frozen_day_to     := l_terms_rec.shp_frozen_day_to ;
           l_firm_day_from     := l_terms_rec.shp_firm_day_from;
           l_firm_day_to       := l_terms_rec.shp_firm_day_to ;
           l_forecast_day_from := l_terms_rec.shp_forecast_day_from;
           l_forecast_day_to   := l_terms_rec.shp_forecast_day_to;
           l_frozen_flag       := l_terms_rec.shp_frozen_flag ;

         ELSIF P_SCHEDULE_TYPE ='SEQUENCED' THEN

           l_frozen_day_from   := l_terms_rec.seq_frozen_day_from;
           l_frozen_day_to     := l_terms_rec.seq_frozen_day_to;
           l_firm_day_from     := l_terms_rec.seq_firm_day_from;
           l_firm_day_to       := l_terms_rec.seq_firm_day_to;
           l_forecast_day_from := l_terms_rec.seq_forecast_day_from;
           l_forecast_day_to   := l_terms_rec.seq_forecast_day_to;
           l_frozen_flag       := l_terms_rec.seq_frozen_flag;

         ELSE

           l_frozen_day_from   := l_terms_rec.pln_frozen_day_from;
           l_frozen_day_to     := l_terms_rec.pln_frozen_day_to;
           l_firm_day_from     := l_terms_rec.pln_firm_day_from ;
           l_firm_day_to       := l_terms_rec.pln_firm_day_to;
           l_forecast_day_from := l_terms_rec.pln_forecast_day_from ;
           l_forecast_day_to   := l_terms_rec.pln_forecast_day_to;
           l_frozen_flag       := l_terms_rec.pln_frozen_flag ;

         END IF ;

                insert_rlm_attributes ( v_cur_comp_sch_to_demand.customer_id,
                                         v_cur_comp_sch_to_demand.ship_from_org_id,
                                         v_cur_comp_sch_to_demand.ship_to_org_id,
                                         v_cur_comp_sch_to_demand.ship_to_address_id,
                                         v_cur_comp_sch_to_demand.customer_item_id,
                                         v_cur_comp_sch_to_demand.customer_item_number,
                                         v_cur_comp_sch_to_demand.customer_item_desc,
                                         l_frozen_day_from,
                                         l_frozen_day_to,
                                         l_firm_day_from,
                                         l_firm_day_to,
                                         l_forecast_day_from,
                                         l_forecast_day_to,
                                         l_terms_rec.intransit_time,
                                         l_terms_rec.time_uom_code,
                                         l_ship_del_pattern,
                                         l_terms_rec.std_pack_qty,
                                         v_cur_comp_sch_to_demand.inventory_item_id,
                                         v_cur_comp_sch_to_demand.inventory_item_number,
                                         v_cur_comp_sch_to_demand.inventory_item_desc,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         l_terms_rec.unship_firm_cutoff_days,
                                         l_terms_rec.unshipped_firm_disp_cd,
                                         l_terms_rec.intransit_calc_basis,
                                         v_cur_comp_sch_to_demand.line_id,
                                         v_cur_comp_sch_to_demand.header_id,
                                         l_frozen_flag,
                                         l_terms_rec.exclude_non_workdays_flag);
         populate_within_across;

         DECLARE

            v_within_key     VARCHAR2(100) ;
            v_across_key     VARCHAR2(100) ;
            v_attribute_name VARCHAR2(100) ;

         BEGIN

            FOR i in 1..l_match_attribute.count

             LOOP
               IF l_match_attribute.count > 0 THEN
                  v_within_key     := l_match_attribute(i).Within_key;
                  v_across_key     := l_match_attribute(i).across_key;
                  v_attribute_name := l_match_attribute(i).attribute_name;
              ELSE
                  v_within_key     := NULL;
                  v_across_key     := NULL;
                  v_attribute_name := NULL;
               END IF;

               INSERT INTO  RLM_SEQ_MATCH_TEMP (CUSTOMER_ID ,
                                                SHIP_FROM_ORG_ID ,
                                                SHIP_TO_ORG_ID,
                                                SHIP_TO_ADDRESS_ID,
                                                CUSTOMER_ITEM_ID,
                                                MATCH_WITHIN ,
                                                MATCH_ACROSS,
                                                MEANING
                                 )
                VALUES
                                ( v_cur_comp_sch_to_demand.customer_id,
                                  v_cur_comp_sch_to_demand.ship_from_org_id,
                                  v_cur_comp_sch_to_demand.ship_to_org_id,
                                  v_cur_comp_sch_to_demand.ship_to_address_id,
                                  v_cur_comp_sch_to_demand.customer_item_id,
                                  v_within_key,
                                  v_across_key,
                                  v_attribute_name);
            END LOOP;

         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         l_match_attribute.delete;

         l_customer_id      := v_cur_comp_sch_to_demand.customer_id;
         l_ship_from        := v_cur_comp_sch_to_demand.ship_from_org_id;
         l_ship_to          := v_cur_comp_sch_to_demand.ship_to_address_id;
         l_customer_item_id := v_cur_comp_sch_to_demand.customer_item_id;
         l_NULL             := NULL ;

       END IF; -- New combination of customer_id, ship_from_org_id, ship_to_address_id, customer_item_id

       IF v_cur_comp_sch_to_demand.schedule_type <> 'SEQUENCED'  THEN

          -- For Quarterly demand

          IF  v_cur_comp_sch_to_demand.item_detail_subtype = g_quarter THEN

             IF (MOD(v_cur_comp_sch_to_demand.item_detail_quantity,1)>0) THEN
                l_WholeNumber := FALSE;
             END IF;

             l_LastDayQuarter := last_day(ADD_MONTHS(v_cur_comp_sch_to_demand.start_date_time,2));

             l_WeeksInQuarter := TRUNC((l_LastDayQuarter - v_cur_comp_sch_to_demand.start_date_time)/7 );

             FOR week IN 0..l_WeeksInQuarter-1 LOOP

                l_week_name := get_week_name( week+1);

                l_inputrec.primaryquantity := v_cur_comp_sch_to_demand.item_detail_quantity;

                v_item_detail_quantity := RLM_TPA_SV.get_weekly_quantity(
                                                                                 l_wholenumber,
                                                                                 week+1,
                                                                                 l_inputrec,
                                                                                 l_WeeksInQuarter) ;

                insert_rlm_comp_sch_to_demand(
                                          v_cur_comp_sch_to_demand.header_id ,
                                          v_cur_comp_sch_to_demand.customer_id ,
                                          v_cur_comp_sch_to_demand.schedule_type ,
                                          v_cur_comp_sch_to_demand.sched_horizon_end_date,
                                          v_cur_comp_sch_to_demand.sched_horizon_start_date,
                                          v_cur_comp_sch_to_demand.schedule_source ,
                                          v_cur_comp_sch_to_demand.schedule_purpose,
                                          v_cur_comp_sch_to_demand.schedule_reference_num,
                                          v_cur_comp_sch_to_demand.sched_generation_date,
                                          v_cur_comp_sch_to_demand.ece_tp_location_code_ext,
                                          v_cur_comp_sch_to_demand.ece_tp_translator_code,
                                          v_cur_comp_sch_to_demand.last_update_date,
                                          v_cur_comp_sch_to_demand.creation_date,
                                          v_cur_comp_sch_to_demand.line_id ,
                                          v_cur_comp_sch_to_demand.customer_item_id,
                                          v_cur_comp_sch_to_demand.date_type_code ,
                                          NULL ,  ---edi_test_indicator,
                                          v_cur_comp_sch_to_demand.inventory_item_id,
                                          v_cur_comp_sch_to_demand.item_detail_subtype,
                                          v_cur_comp_sch_to_demand.item_detail_type,
                                          v_cur_comp_sch_to_demand.qty_type_code ,
                                          v_cur_comp_sch_to_demand.start_date_time + 7*week,
                                          v_cur_comp_sch_to_demand.end_date_time,
                                          v_item_detail_quantity ,
                                          v_cur_comp_sch_to_demand.uom_code ,
                                          v_cur_comp_sch_to_demand.ship_from_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_org_id ,
                                          v_cur_comp_sch_to_demand.ship_to_address_id,
                                          NULL ,--- intmed_ship_to_org_id,
                                          v_cur_comp_sch_to_demand.customer_dock_code ,
                                          v_cur_comp_sch_to_demand.customer_job ,
                                          v_cur_comp_sch_to_demand.cust_model_serial_number,
                                          v_cur_comp_sch_to_demand.cust_production_line,
                                          v_cur_comp_sch_to_demand.cust_production_seq_num,
                                          get_monday_date(v_cur_comp_sch_to_demand.start_date_time + 7*week),
                                          NULL ,
                                          NULL ,
                                          v_cur_comp_sch_to_demand.order_header_id,
                                          v_cur_comp_sch_to_demand.cust_po_number,
                                          v_cur_comp_sch_to_demand.customer_item_revision,
                                          v_cur_comp_sch_to_demand.pull_signal_start_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_end_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_ref_num,
                                          v_cur_comp_sch_to_demand.customer_request_date,
                                          v_cur_comp_sch_to_demand.record_year,
                                          l_week_name,
                                          v_cur_comp_sch_to_demand.customer_name
                                          ) ;

             END LOOP;

          l_week_name := NULL ;

          -- For Monthly demand

          ELSIF  v_cur_comp_sch_to_demand.item_detail_subtype = g_month THEN

             IF (MOD(v_cur_comp_sch_to_demand .item_detail_quantity, 1) > 0) THEN
               l_WholeNumber := FALSE;
             END IF;

             FOR DAY IN  0..3 LOOP

                l_week_name := get_week_name(DAY+1 );

                l_inputrec.primaryquantity := v_cur_comp_sch_to_demand.item_detail_quantity;

                v_item_detail_quantity := RLM_TPA_SV.get_weekly_quantity(
                                                        l_wholenumber,
                                                        day+1,
                                                        l_inputrec,
                                                        4);

                insert_rlm_comp_sch_to_demand

                                         (v_cur_comp_sch_to_demand.header_id ,
                                          v_cur_comp_sch_to_demand.customer_id ,
                                          v_cur_comp_sch_to_demand.schedule_type ,
                                          v_cur_comp_sch_to_demand.sched_horizon_end_date,
                                          v_cur_comp_sch_to_demand.sched_horizon_start_date,
                                          v_cur_comp_sch_to_demand.schedule_source ,
                                          v_cur_comp_sch_to_demand.schedule_purpose,
                                          v_cur_comp_sch_to_demand.schedule_reference_num,
                                          v_cur_comp_sch_to_demand.sched_generation_date,
                                          v_cur_comp_sch_to_demand.ece_tp_location_code_ext,
                                          v_cur_comp_sch_to_demand.ece_tp_translator_code,
                                          v_cur_comp_sch_to_demand.last_update_date,
                                          v_cur_comp_sch_to_demand.creation_date,
                                          v_cur_comp_sch_to_demand.line_id ,
                                          v_cur_comp_sch_to_demand.customer_item_id,
                                          v_cur_comp_sch_to_demand.date_type_code ,
                                          NULL ,  ---edi_test_indicator,
                                          v_cur_comp_sch_to_demand.inventory_item_id,
                                          v_cur_comp_sch_to_demand.item_detail_subtype,
                                          v_cur_comp_sch_to_demand.item_detail_type,
                                          v_cur_comp_sch_to_demand.qty_type_code ,
                                          v_cur_comp_sch_to_demand.start_date_time + 7*day,
                                          v_cur_comp_sch_to_demand.end_date_time,
                                          v_item_detail_quantity,
                                          v_cur_comp_sch_to_demand.uom_code ,
                                          v_cur_comp_sch_to_demand.ship_from_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_address_id,
                                          NULL ,--- intmed_ship_to_org_id,
                                          v_cur_comp_sch_to_demand.customer_dock_code ,
                                          v_cur_comp_sch_to_demand.customer_job ,
                                          v_cur_comp_sch_to_demand.cust_model_serial_number,
                                          v_cur_comp_sch_to_demand.cust_production_line,
                                          v_cur_comp_sch_to_demand.cust_production_seq_num,
                                          get_monday_date(v_cur_comp_sch_to_demand.start_date_time + 7 * day),
                                          NULL , ---week_schedule_qty
                                          NULL , -- week_end_date
                                          v_cur_comp_sch_to_demand.order_header_id,
                                          v_cur_comp_sch_to_demand.cust_po_number,
                                          v_cur_comp_sch_to_demand.customer_item_revision,
                                          v_cur_comp_sch_to_demand.pull_signal_start_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_end_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_ref_num,
                                          v_cur_comp_sch_to_demand.customer_request_date,
                                          v_cur_comp_sch_to_demand.record_year,
                                          l_week_name,
                                          v_cur_comp_sch_to_demand.customer_name
                                    ) ;
             END LOOP;

           l_week_name := NULL ;

          -- For flexible demand

          ELSIF  v_cur_comp_sch_to_demand.item_detail_subtype = g_flexible THEN

             IF (MOD(v_cur_comp_sch_to_demand.ITEM_DETAIL_QUANTITY,1)>0) THEN
               l_WholeNumber := FALSE;
             END IF;

             WHILE ((v_cur_comp_sch_to_demand.start_date_time+(7*l_Buckets)) <= v_cur_comp_sch_to_demand.end_date_time )
             LOOP

                l_Buckets := l_Buckets + 1;

             END LOOP;

             FOR l_Count IN 1..l_buckets
             LOOP

                l_week_name := get_week_name(l_count);

                l_inputrec.primaryquantity := v_cur_comp_sch_to_demand.item_detail_quantity ;

                v_item_detail_quantity := RLM_TPA_SV.get_weekly_quantity(
                                                        l_wholenumber,
                                                        l_count,
                                                        l_inputrec,
                                                        l_buckets);

                insert_rlm_comp_sch_to_demand (v_cur_comp_sch_to_demand.header_id ,
                                          v_cur_comp_sch_to_demand.customer_id ,
                                          v_cur_comp_sch_to_demand.schedule_type ,
                                          v_cur_comp_sch_to_demand.sched_horizon_end_date,
                                          v_cur_comp_sch_to_demand.sched_horizon_start_date,
                                          v_cur_comp_sch_to_demand.schedule_source ,
                                          v_cur_comp_sch_to_demand.schedule_purpose,
                                          v_cur_comp_sch_to_demand.schedule_reference_num,
                                          v_cur_comp_sch_to_demand.sched_generation_date,
                                          v_cur_comp_sch_to_demand.ece_tp_location_code_ext,
                                          v_cur_comp_sch_to_demand.ece_tp_translator_code,
                                          v_cur_comp_sch_to_demand.last_update_date,
                                          v_cur_comp_sch_to_demand.creation_date,
                                          v_cur_comp_sch_to_demand.line_id ,
                                          v_cur_comp_sch_to_demand.customer_item_id,
                                          v_cur_comp_sch_to_demand.date_type_code ,
                                          NULL ,  ---edi_test_indicator,
                                          v_cur_comp_sch_to_demand.inventory_item_id,
                                          v_cur_comp_sch_to_demand.item_detail_subtype,
                                          v_cur_comp_sch_to_demand.item_detail_type,
                                          v_cur_comp_sch_to_demand.qty_type_code ,
                                          v_cur_comp_sch_to_demand.start_date_time + 7*(l_Count-1),
                                          v_cur_comp_sch_to_demand.end_date_time,
                                          v_item_detail_quantity ,
                                          v_cur_comp_sch_to_demand.uom_code ,
                                          v_cur_comp_sch_to_demand.ship_from_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_org_id ,
                                          v_cur_comp_sch_to_demand.ship_to_address_id,
                                          NULL,
                                          v_cur_comp_sch_to_demand.customer_dock_code ,
                                          v_cur_comp_sch_to_demand.customer_job ,
                                          v_cur_comp_sch_to_demand.cust_model_serial_number,
                                          v_cur_comp_sch_to_demand.cust_production_line,
                                          v_cur_comp_sch_to_demand.cust_production_seq_num,
                                          get_monday_date(v_cur_comp_sch_to_demand.start_date_time + 7*(l_Count-1)),
                                          NULL ,
                                          NULL ,
                                          v_cur_comp_sch_to_demand.order_header_id,
                                          v_cur_comp_sch_to_demand.cust_po_number,
                                          v_cur_comp_sch_to_demand.customer_item_revision,
                                          v_cur_comp_sch_to_demand.pull_signal_start_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_end_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_ref_num,
                                          v_cur_comp_sch_to_demand.customer_request_date,
                                          v_cur_comp_sch_to_demand.record_year,
                                          l_week_name,
                                          v_cur_comp_sch_to_demand.customer_name
                                    ) ;
              END LOOP;
          l_week_name := NULL;
          -- For Daily and weekly demand
          --
          ELSE

             insert_rlm_comp_sch_to_demand(
                                          v_cur_comp_sch_to_demand.header_id ,
                                          v_cur_comp_sch_to_demand.customer_id ,
                                          v_cur_comp_sch_to_demand.schedule_type ,
                                          v_cur_comp_sch_to_demand.sched_horizon_end_date,
                                          v_cur_comp_sch_to_demand.sched_horizon_start_date,
                                          v_cur_comp_sch_to_demand.schedule_source ,
                                          v_cur_comp_sch_to_demand.schedule_purpose,
                                          v_cur_comp_sch_to_demand.schedule_reference_num,
                                          v_cur_comp_sch_to_demand.sched_generation_date,
                                          v_cur_comp_sch_to_demand.ece_tp_location_code_ext,
                                          v_cur_comp_sch_to_demand.ece_tp_translator_code,
                                          v_cur_comp_sch_to_demand.last_update_date,
                                          v_cur_comp_sch_to_demand.creation_date,
                                          v_cur_comp_sch_to_demand.line_id ,
                                          v_cur_comp_sch_to_demand.customer_item_id,
                                          v_cur_comp_sch_to_demand.date_type_code ,
                                          NULL ,  ---edi_test_indicator,
                                          v_cur_comp_sch_to_demand.inventory_item_id,
                                          v_cur_comp_sch_to_demand.item_detail_subtype,
                                          v_cur_comp_sch_to_demand.item_detail_type,
                                          v_cur_comp_sch_to_demand.qty_type_code ,
                                          v_cur_comp_sch_to_demand.start_date_time,
                                          v_cur_comp_sch_to_demand.end_date_time,
                                          v_cur_comp_sch_to_demand.item_detail_quantity,
                                          v_cur_comp_sch_to_demand.uom_code ,
                                          v_cur_comp_sch_to_demand.ship_from_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_org_id ,
                                          v_cur_comp_sch_to_demand.ship_to_address_id,
                                          NULL ,--- intmed_ship_to_org_id,
                                          v_cur_comp_sch_to_demand.customer_dock_code ,
                                          v_cur_comp_sch_to_demand.customer_job ,
                                          v_cur_comp_sch_to_demand.cust_model_serial_number,
                                          v_cur_comp_sch_to_demand.cust_production_line,
                                          v_cur_comp_sch_to_demand.cust_production_seq_num,
                                          get_monday_date(v_cur_comp_sch_to_demand .start_date_time),
                                          NULL ,
                                          NULL ,
                                          v_cur_comp_sch_to_demand.order_header_id,
                                          v_cur_comp_sch_to_demand.cust_po_number,
                                          v_cur_comp_sch_to_demand.customer_item_revision,
                                          v_cur_comp_sch_to_demand.pull_signal_start_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_end_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_ref_num,
                                          v_cur_comp_sch_to_demand.customer_request_date,
                                          v_cur_comp_sch_to_demand.record_year,
                                          NULL,
                                          v_cur_comp_sch_to_demand.customer_name
                                    ) ;


          END IF; -- Demand Type

       -- Sequence schedule

       ELSE -- schedule type

          insert_rlm_comp_sch_to_demand  (
                                          v_cur_comp_sch_to_demand.header_id ,
                                          v_cur_comp_sch_to_demand.customer_id ,
                                          v_cur_comp_sch_to_demand.schedule_type ,
                                          v_cur_comp_sch_to_demand.sched_horizon_end_date,
                                          v_cur_comp_sch_to_demand.sched_horizon_start_date,
                                          v_cur_comp_sch_to_demand.schedule_source ,
                                          v_cur_comp_sch_to_demand.schedule_purpose,
                                          v_cur_comp_sch_to_demand.schedule_reference_num,
                                          v_cur_comp_sch_to_demand.sched_generation_date,
                                          v_cur_comp_sch_to_demand.ece_tp_location_code_ext,
                                          v_cur_comp_sch_to_demand.ece_tp_translator_code,
                                          v_cur_comp_sch_to_demand.last_update_date,
                                          v_cur_comp_sch_to_demand.creation_date,
                                          v_cur_comp_sch_to_demand.line_id ,
                                          v_cur_comp_sch_to_demand.customer_item_id,
                                          v_cur_comp_sch_to_demand.date_type_code ,
                                          NULL ,
                                          v_cur_comp_sch_to_demand.inventory_item_id,
                                          v_cur_comp_sch_to_demand.item_detail_subtype,
                                          v_cur_comp_sch_to_demand.item_detail_type,
                                          v_cur_comp_sch_to_demand.qty_type_code ,
                                          v_cur_comp_sch_to_demand.start_date_time,
                                          v_cur_comp_sch_to_demand.end_date_time,
                                          v_cur_comp_sch_to_demand.item_detail_quantity,
                                          v_cur_comp_sch_to_demand.uom_code ,
                                          v_cur_comp_sch_to_demand.ship_from_org_id,
                                          v_cur_comp_sch_to_demand.ship_to_org_id ,
                                          v_cur_comp_sch_to_demand.ship_to_address_id,
                                          NULL ,--- intmed_ship_to_org_id,
                                          v_cur_comp_sch_to_demand.customer_dock_code ,
                                          v_cur_comp_sch_to_demand.customer_job ,
                                          v_cur_comp_sch_to_demand.cust_model_serial_number,
                                          v_cur_comp_sch_to_demand.cust_production_line,
                                          v_cur_comp_sch_to_demand.cust_production_seq_num,
                                          sysdate,
                                          NULL ,
                                          NULL ,
                                          v_cur_comp_sch_to_demand.order_header_id,
                                          v_cur_comp_sch_to_demand.cust_po_number,
                                          v_cur_comp_sch_to_demand.customer_item_revision,
                                          v_cur_comp_sch_to_demand.pull_signal_start_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_end_serial_num,
                                          v_cur_comp_sch_to_demand.pull_signal_ref_num,
                                          v_cur_comp_sch_to_demand.customer_request_date,
                                          v_cur_comp_sch_to_demand.record_year,
                                          NULL,
                                          v_cur_comp_sch_to_demand.customer_name
                                    ) ;
       END IF ;

    END LOOP ;  -- Outer loop

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END proc_comp_sch_to_demand;

  /*=============================================================================

  FUNCTION NAME: get_monday_date

  ==============================================================================*/

  FUNCTION get_monday_date (p_date  DATE) RETURN  DATE
  IS

    l_date    date;
    l_p_date  date;

  BEGIN
    l_p_date := trunc(p_date);

    SELECT  l_p_date-decode(to_char(l_p_date,'D'),1,6,3,1,4,2,5,3,6,4,7,5,0)
    INTO    l_date
    FROM    dual;

    RETURN  l_date;

  END get_monday_date ;

 /*=============================================================================

  FUNCTION NAME: get_week_name

  ==============================================================================*/

  Function get_week_name(v_week_number in NUMBER) RETURN VARCHAR2 is
    v_week_name  Varchar2(100) ;
 BEGIN

    IF v_week_number = 1 then
     fnd_message.set_name('RLM','RLM_FIRST_WEEK');
     v_week_name :=fnd_message.get;
    ELSIF
     v_week_number = 2 then
     fnd_message.set_name('RLM','RLM_SECOND_WEEK');
     v_week_name :=fnd_message.get;
    ELSIF
     v_week_number = 3 then
     fnd_message.set_name('RLM','RLM_THIRD_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 4 then
     fnd_message.set_name('RLM','RLM_FOURTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 5 then
     fnd_message.set_name('RLM','RLM_FIFTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 6 then
     fnd_message.set_name('RLM','RLM_SIXTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 7 then
     fnd_message.set_name('RLM','RLM_SEVENTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 8 then
     fnd_message.set_name('RLM','RLM_EIGHTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 9 then
     fnd_message.set_name('RLM','RLM_NINTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 10 then
     fnd_message.set_name('RLM','RLM_TENTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 11 then
     fnd_message.set_name('RLM','RLM_ELEVENTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 12 then
     fnd_message.set_name('RLM','RLM_TWELFTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSIF
     v_week_number = 13 then
     fnd_message.set_name('RLM','RLM_THIRTEENTH_WEEK');
     v_week_name :=fnd_message.get;
   ELSE
       RETURN(NULL);
   END IF ;
  RETURN (v_week_name);
 END get_week_name;


END RLM_COMP_SCH_TO_DEMAND_SV;

/
