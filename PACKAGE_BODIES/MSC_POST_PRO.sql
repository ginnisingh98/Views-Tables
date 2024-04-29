--------------------------------------------------------
--  DDL for Package Body MSC_POST_PRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_POST_PRO" 
-- $Header: MSCPOSTB.pls 120.8.12010000.12 2010/03/15 06:22:08 aksaxena ship $
AS

MAXVALUE                CONSTANT NUMBER := 999999;

PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

-- for summary enhancement
G_ALLOC_ATP                     VARCHAR2(1);
G_CLASS_HRCHY                   NUMBER;
G_ALLOC_METHOD                  NUMBER;

-- Declaration of new private procedures for summary enhancement - Begin
PROCEDURE Truncate_Summ_Plan_Partition(p_plan_id        IN NUMBER,
                                p_applsys_schema        IN varchar2);
PROCEDURE LOAD_PLAN_SUMMARY_SD (p_plan_id               IN NUMBER,
                                p_share_partition       IN varchar2,
                                p_optimized_plan        IN NUMBER,  -- 1:Yes, 2:No
                                p_full_refresh          IN NUMBER,  -- 1:Yes, 2:No
                                p_time_phased_pf        IN NUMBER,  -- 1:Yes, 2:No
                                p_plan_type             IN NUMBER,  -- ATP4drp
                                p_last_refresh_number   IN NUMBER,
                                p_new_refresh_number    IN NUMBER,
                                p_sys_date              IN DATE);
PROCEDURE LOAD_SD_FULL_ALLOC(p_plan_id                  IN NUMBER,
                             p_sys_date                 IN DATE);
PROCEDURE LOAD_SD_FULL_UNALLOC_OPT(p_plan_id            IN NUMBER,
                                   p_sys_date           IN DATE);
PROCEDURE LOAD_SD_FULL_UNALLOC_OPT_PF(p_plan_id         IN NUMBER,
                                      p_sys_date        IN DATE);
PROCEDURE LOAD_SD_FULL_UNALLOC_UNOPT(p_plan_id          IN NUMBER,
                                     p_sys_date         IN DATE);
PROCEDURE LOAD_SD_FULL_UNALLOC_UNOPT_PF(p_plan_id       IN NUMBER,
                                        p_sys_date      IN DATE);
PROCEDURE LOAD_SD_NET_ALLOC(p_plan_id                   IN NUMBER,
                            p_last_refresh_number       IN NUMBER,
                            p_new_refresh_number        IN NUMBER,
                            p_sys_date                  IN DATE);
PROCEDURE LOAD_SD_NET_UNALLOC(p_plan_id                 IN NUMBER,
                              p_last_refresh_number     IN NUMBER,
                              p_new_refresh_number      IN NUMBER,
                              p_time_phased_pf          IN NUMBER,  -- 1:Yes, 2:No
                              p_sys_date                IN DATE);
PROCEDURE LOAD_SUP_DATA_FULL(p_plan_id                  IN NUMBER,
                             p_sys_date                 IN DATE);
PROCEDURE LOAD_SUP_DATA_NET(p_plan_id                   IN NUMBER,
                            p_last_refresh_number       IN NUMBER,
                            p_new_refresh_number        IN NUMBER,
                            p_sys_date                  IN DATE);
PROCEDURE LOAD_RES_FULL_UNOPT_BATCH(p_plan_id           IN NUMBER,
                                    p_plan_start_date   IN DATE,
                                    p_sys_date          IN DATE);
PROCEDURE LOAD_RES_FULL_OPT_BATCH(p_plan_id             IN NUMBER,
                                  p_plan_start_date     IN DATE,
                                  p_sys_date            IN DATE);
PROCEDURE LOAD_RES_FULL_UNOPT_NOBATCH(p_plan_id         IN NUMBER,
                                      p_plan_start_date IN DATE,
                                      p_sys_date        IN DATE);
PROCEDURE LOAD_RES_FULL_OPT_NOBATCH(p_plan_id           IN NUMBER,
                                    p_plan_start_date   IN DATE,
                                    p_sys_date          IN DATE);
PROCEDURE LOAD_RES_DATA_NET(p_plan_id                   IN NUMBER,
                            p_last_refresh_number       IN NUMBER,
                            p_new_refresh_number        IN NUMBER,
                            p_sys_date                  IN DATE);
PROCEDURE Gather_Summ_Plan_Stats(p_plan_id              IN NUMBER,
                                 p_share_partition      IN varchar2);
-- Declaration of new private procedures for summary enhancement - End



PROCEDURE LOAD_SUPPLY_DEMAND ( ERRBUF             OUT    NoCopy VARCHAR2,
                              RETCODE           OUT    NoCopy NUMBER,
                              P_INSTANCE_ID      IN     NUMBER,
                              P_COLLECT_TYPE     IN     NUMBER)
AS

-- p_collect type is used to decide on what entity do we need to do full refresh on:
--   1-  Full refresh on Sales Orders -- ATP is not available
--   2-  Full refresh on supply/demands-- ATP is available
--   3-  Full refresh on both S/O and S/D -- ATP is not available

        atp_summ_tab MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                        'ATP_SUMMARY_SO',
                                        'ATP_SUMMARY_SD');
	l_instance_id  number;
       	i number;
	l_org_ids MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
	i integer;
	l_sql_stmt               	varchar2(3000);
        l_sql_stmt_1		 	varchar2(3000);
	l_applsys_schema         	varchar2(10);
        l_msc_schema             	VARCHAR2(30);
        l_retval                	BOOLEAN;
        dummy1                  	varchar2(10);
        dummy2                  	varchar2(10);
        l_count				number;
	l_sysdate_seq_num               NUMBER;
	l_default_atp_rule_id           NUMBER;
	l_calendar_code                 VARCHAR2(14);
	l_calendar_exception_set_id     NUMBER;
	l_default_demand_class          VARCHAR2(34);
        l_organization_id		number;
        l_inv_ctp			number;
        l_partition_name 		varchar2(30);
        l_table_name                varchar2(30);
        l_ret_code                      number;
        l_err_msg			varchar2(1000);
        l_summary_flag                  number;
        l_enable_summary_mode           varchar2(1);
        l_sys_date		        date;
        l_user_id                       number;

        l_org_code                      VARCHAR2(7);
        l_sys_next_date                 date;
        -- Bug 2516506
        l_instance_code                 varchar2(3);
        -- rajjain 12/20/2002
        l_spid                          VARCHAR2(12);

BEGIN
        -- Bug 3304390 Disable Trace
        -- Deleted Related code.

        l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);
        msc_util.msc_log('inv_ctp := ' || l_inv_ctp);

        l_enable_summary_mode := NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N');
        msc_util.msc_log(' l_enable_summary_mode := ' || l_enable_summary_mode);
        IF l_enable_summary_mode <> 'Y' THEN
            msc_util.msc_log('Summary Mode is not enabled. Please enable Summary mode to run this program');
            RETCODE := G_WARNING;
            RETURN;
        END IF;

        IF l_inv_ctp = 4 THEN
            -- we are not doing ODS ATP so we wont  continue
            msc_util.msc_log('Not Doing ODS ATP. Please check profile - INV: Capable to Promise. Will Exit ');
            RETCODE := G_WARNING;
            RETURN;
        ELSIF l_inv_ctp <> 5 THEN
	    l_inv_ctp := 5;
        END IF;

        -- Bug 2516506 - get instance_code as well
        -- SELECT NVL(summary_flag, 1)
        -- into   l_summary_flag
        SELECT NVL(summary_flag, 1), instance_code
        into   l_summary_flag, l_instance_code
        FROM   msc_apps_instances
        where  instance_id = p_instance_id;

        msc_util.msc_log('l_summary_flag := ' || l_summary_flag);
        -- 2301524: Summary is not supported for sites using backlog workbench
        IF l_summary_flag = 200 THEN
            msc_util.msc_log('Site is Using backlog workbench');
            msc_util.msc_log('Summary Approach is not supported for sites using  backlog workbench');
            RETCODE := G_WARNING;
            RETURN;
        ELSIF l_summary_flag = 2 THEN
           msc_util.msc_log('Full summary is in  progress for the same instance by other session');
           RETCODE := G_ERROR;
           RETURN;
        ELSIF ((P_COLLECT_TYPE = 1) OR (P_COLLECT_TYPE = 2)) and (NVL(l_summary_flag, 1) <> 3) THEN
           msc_util.msc_log('Tables have not been succefully summarized. Net Change/ Targeted summarization'
                                || '  can not be run without sucessfully running complete summarization ');
           RETCODE := G_ERROR;
           RETURN;
        END IF;

        msc_util.msc_log('sr_instance_id := ' || P_INSTANCE_ID);
        msc_util.msc_log('Collection _type := ' || P_COLLECT_TYPE);
        RETCODE := G_SUCCESS;
	msc_util.msc_log('Begin Post Processing');
	l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);
	SELECT  a.oracle_username
      	INTO    l_msc_schema
      	FROM    FND_ORACLE_USERID a,
                FND_PRODUCT_INSTALLATIONS b
      	WHERE   a.oracle_id = b.oracle_id
      	AND     b.application_id = 724;

        msc_util.msc_log('l_applsys_schema ;= ' || l_applsys_schema);
        msc_util.msc_log('dummy1 := ' || dummy1);
        msc_util.msc_log('dummy2 := ' || dummy2);
        msc_util.msc_log('l_msc_schema := ' || l_msc_schema);

        --check whether the partitions exist in tables or not. In not then error out

        IF (P_COLLECT_TYPE = 3) THEN
           --- for full collection, check if  partition exist or not
           --  if partition doesn't exist for partial chnage then we wont make this far
           FOR i in 1..atp_summ_tab.count LOOP
              l_table_name := 'MSC_' || atp_summ_tab(i);
              l_partition_name :=  atp_summ_tab(i)|| '__' || p_instance_id;
              BEGIN
                  SELECT count(*)
                  INTO l_count
		  --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                  --FROM DBA_TAB_PARTITIONS
                  FROM ALL_TAB_PARTITIONS
                  WHERE TABLE_NAME = l_table_name
                  AND   PARTITION_NAME = l_partition_name
                  AND   table_owner = l_msc_schema;
                  EXCEPTION
                     WHEN OTHERS THEN
                        msc_util.msc_log('Inside Exception');
                        l_count := 0;
              END;
              IF  (l_count = 0) THEN
                  -- Bug 2516506
                  FND_MESSAGE.SET_NAME('MSC', 'MSC_ATP_INS_PARTITION_MISSING');
                  FND_MESSAGE.SET_TOKEN('INSTANCE_CODE', l_instance_code);
                  FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'MSC_' || atp_summ_tab(i));
                  msc_util.msc_log(FND_MESSAGE.GET);
                  RETCODE := G_ERROR;
                  RETURN;
              END IF;
           END LOOP;
        END IF;

       --- update the tbl_status so that user can't do ATP in full refresh mode
       IF  (P_COLLECT_TYPE = 1) OR (P_COLLECT_TYPE = 3) THEN
          BEGIN
              UPDATE msc_apps_instances
              set    so_tbl_status = 2,
                     summary_flag = 2
              where  instance_id = p_instance_id;

              -- commit the change
             commit;
          END;
       END IF;

        l_sys_date := sysdate;
        l_user_id  := FND_GLOBAL.USER_ID;
        msc_util.msc_log('l_sys_date := ' || l_sys_date);
        msc_util.msc_log('l_user_id := ' || l_user_id);

        /* rajjain 02/17/2003 GOP Performance Improvement - ODS Summary changes begin
         * Now we do summarization for all the organizations in one go*/
        IF  (p_collect_type = 1) OR (p_collect_type = 3) THEN
                msc_util.msc_log('Sales Order, should be full collection');

                INSERT INTO MSC_TEMP_SUMM_SO (
                            organization_id,
                            inventory_item_id,
                            demand_class,
                            sd_date,
                            sd_qty,
                            plan_id,
                            sr_instance_id,
                            last_update_date,
                            last_updated_by,
		            creation_date,
                            created_by)
                (SELECT so.organization_id,
                        so.inventory_item_id,
                        so.demand_class,
                        so.SD_DATE,
                        sum(so.sd_qty),
                        -1,
                        p_instance_id,
                        l_sys_date,
                        l_user_id,
                        l_sys_date,
                        l_user_id
                 FROM
	         (SELECT
	       	         I.organization_id,
	       	         I.inventory_item_id,
	                 Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1, NVL(D.DEMAND_CLASS,
	                    NVL(TP.default_demand_class,'@@@')), '@@@') demand_class,
	                 DECODE(D.RESERVATION_TYPE,2,C2.next_date, trunc(D.REQUIREMENT_DATE)) SD_DATE,
	                 (D.PRIMARY_UOM_QUANTITY-
	                    GREATEST(NVL(D.RESERVATION_QUANTITY,0),
	                    D.COMPLETED_QUANTITY)) sd_qty
	          FROM
	                 MSC_SYSTEM_ITEMS I,
	                 MSC_ATP_RULES R,
	                 MSC_SALES_ORDERS D,
	                 MSC_CALENDAR_DATES C,
	                 MSC_CALENDAR_DATES C2,
	                 MSC_TRADING_PARTNERS TP
	          WHERE   I.ATP_FLAG = 'Y'
	          AND     I.ORGANIZATION_ID = TP.SR_TP_ID
	          AND     I.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
	          AND     I.PLAN_ID = -1
	          AND     I.BOM_ITEM_TYPE <> 5
     	          AND     R.RULE_ID  = NVL(I.ATP_RULE_ID,  TP.default_atp_rule_id)
	          AND     R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
	          AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
	          AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
	          AND 	 D.ORGANIZATION_ID = I.ORGANIZATION_ID
	          AND     D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
	          AND     D.DEMAND_SOURCE_TYPE <>
	                               DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
	          AND     D.PRIMARY_UOM_QUANTITY >
	                           GREATEST(NVL(D.RESERVATION_QUANTITY,0),
	               	              D.COMPLETED_QUANTITY)
	          AND     (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
	                        (SELECT S.SUB_INVENTORY_CODE
	                         FROM   MSC_SUB_INVENTORIES S
	                         WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
	                         AND    S.PLAN_ID = I.PLAN_ID
	                         AND    S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
	                         AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
	                       		            1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
	                         AND    S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
	                      		            2, 1, S.NETTING_TYPE)))
	    		         AND         (D.RESERVATION_TYPE = 2
	                 	        OR D.PARENT_DEMAND_ID IS NULL
	                 	        OR (D.RESERVATION_TYPE = 3 AND
	                     		        ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
	                      		        (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
	          AND     C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
	                         NULL, C.PRIOR_SEQ_NUM,
	          	        C2.next_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
	          AND     C.CALENDAR_CODE = TP.CALENDAR_CODE
	          AND     C.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
	          AND     C.EXCEPTION_SET_ID = -1
	          AND     C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
	          AND     C2.CALENDAR_CODE = TP.calendar_code
	          AND     C2.EXCEPTION_SET_ID = TP.calendar_exception_set_id
	          AND     C2.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
	          AND     C2.CALENDAR_DATE = TRUNC(l_sys_date)
	          AND     TP.SR_INSTANCE_ID = p_instance_id
	          AND     TP.PARTNER_TYPE   = 3
			       	         ) SO
                  GROUP BY so.inventory_item_id, so.organization_id, so.demand_class,
                           so.sd_date, -1, p_instance_id, l_sys_date, l_user_id);

        END IF;
        msc_util.msc_log('Load SD details in msc_atp_summary_sd table');

        IF (P_COLLECT_TYPE= 2 ) OR (P_COLLECT_TYPE= 3 ) THEN
                msc_util.msc_log('Load SD Details, ODS Case');

		INSERT INTO MSC_TEMP_SUMM_SD (
                            organization_id,
                            inventory_item_id,
                            demand_class,
                            sd_date,
                            sd_qty,
                            plan_id,
                            sr_instance_id,
                            last_update_date,
                            last_updated_by,
		            creation_date,
                            created_by)
                (SELECT sd.organization_id,
                        sd.inventory_item_id,
                        sd.demand_class,
                        sd.SD_DATE,
                        sum(sd.sd_qty),
                        -1,
                        p_instance_id,
                        l_sys_date,
                        l_user_id,
                        l_sys_date,
                        l_user_id
                 FROM
		       (SELECT  I.organization_id,
		                DECODE(I2.ATP_FLAG, 'Y', I2.INVENTORY_ITEM_ID,
		                       I.INVENTORY_ITEM_ID) inventory_item_id,
		                Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 , NVL(D.DEMAND_CLASS,
		                    NVL(TP.default_demand_class,'@@@')), '@@@') demand_class,
		                C.PRIOR_DATE SD_DATE, -- 2859130
		                -1* D.USING_REQUIREMENT_QUANTITY SD_QTY
		        FROM
		                MSC_SYSTEM_ITEMS I,
		                MSC_SYSTEM_ITEMS I2,
		                MSC_ATP_RULES R,
		                MSC_DEMANDS D,
		                MSC_CALENDAR_DATES C,
		                MSC_CALENDAR_DATES C2,
		                MSC_TRADING_PARTNERS TP
		        WHERE   I.ATP_FLAG = 'Y'
		        AND     I.ORGANIZATION_ID = TP.SR_TP_ID
		        AND     I.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		        AND     I.PLAN_ID = -1
		        AND     I.BOM_ITEM_TYPE <> 5
		        AND     I.PLAN_ID = I2.PLAN_ID
		        AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
		        AND     I2.ORGANIZATION_ID = I.ORGANIZATION_ID
		        AND     I2.INVENTORY_ITEM_ID = NVL(I.PRODUCT_FAMILY_ID,
		                                                I.INVENTORY_ITEM_ID)
		        AND     R.RULE_ID  = NVL(I.ATP_RULE_ID ,TP.default_atp_rule_id)
		        AND     R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
		        AND     D.PLAN_ID = I.PLAN_ID
		        AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
		        AND     D.INVENTORY_ITEM_ID =  I.INVENTORY_ITEM_ID
		        AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
		        AND     USING_REQUIREMENT_QUANTITY <> 0
		        AND     D.ORIGINATION_TYPE in (
		                   DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
		                   DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
		                   DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
		                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
		                   DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
		        AND     C.CALENDAR_CODE = TP.calendar_code
		        AND     C.EXCEPTION_SET_ID = -1
		        AND     C.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		        AND     C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE)
		                        AND TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
		                                   D.USING_ASSEMBLY_DEMAND_DATE))
		        AND     C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
		                   NULL, C.PRIOR_SEQ_NUM,
		                   C2.next_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
		        AND     C2.CALENDAR_CODE = TP.calendar_code
		        AND     C2.EXCEPTION_SET_ID = TP.calendar_exception_set_id
		        AND     C2.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		        AND     C2.CALENDAR_DATE = TRUNC(l_sys_date)
		        AND     TP.SR_INSTANCE_ID = p_instance_id
		        AND     TP.PARTNER_TYPE   = 3
		   UNION ALL
		      SELECT
		              I.organization_id,
		              I.inventory_item_id,
		              Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
		                    NVL(DECODE(S.ORDER_TYPE, 5,
		                MSC_ATP_FUNC.Get_MPS_Demand_Class(S.SCHEDULE_DESIGNATOR_ID),
		                S.DEMAND_CLASS), NVL(TP.default_demand_class, '@@@')), '@@@')
		                demand_class,
		              C.NEXT_DATE SD_DATE, -- 2859130 remove trunc
		              Decode(order_type, -- 2859130 remove trunc
		                 30, Decode(Sign(S.Daily_rate * (C.Calendar_date -
		                 TRUNC(S.FIRST_UNIT_START_DATE))- S.qty_completed),
		                -1,S.Daily_rate*(C.Calendar_date - TRUNC(S.First_Unit_Start_date)+1)
		                           - S.qty_completed, S.Daily_rate),
		                           NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) ) SD_QTY
		      FROM
		              MSC_SYSTEM_ITEMS I,
		              MSC_SYSTEM_ITEMS I2,
		              MSC_ATP_RULES R,
		              MSC_SUPPLIES S,
		              MSC_SUB_INVENTORIES MSI,
		              MSC_CALENDAR_DATES C,
		              MSC_CALENDAR_DATES C2,
		              MSC_TRADING_PARTNERS TP
		     WHERE   I.ATP_FLAG = 'Y'
		     AND     I.ORGANIZATION_ID = TP.SR_TP_ID
		     AND     I.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		     AND     I.PLAN_ID = -1
		     AND     I.PLAN_ID = I2.PLAN_ID
		     AND     I.ORGANIZATION_ID = I2.ORGANIZATION_ID
		     AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
		     AND     NVL(I.PRODUCT_FAMILY_ID, I.INVENTORY_ITEM_ID) =
		                  I2.INVENTORY_ITEM_ID
		     AND     DECODE(I.PRODUCT_FAMILY_ID, NULL, 'N', I2.ATP_FLAG ) = 'N'
		     AND     R.RULE_ID  = NVL(I.ATP_RULE_ID, TP.default_atp_rule_id)
		     AND     R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
		     AND     S.PLAN_ID = I.PLAN_ID
		     AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
		     AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
		     AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
                     -- 2859130 remove trunc
		     AND     Decode(S.order_type, 30, S.Daily_rate*
		                  (C.Calendar_date - TRUNC(S.First_Unit_Start_date) + 1) ,
		                  NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) >
		                  Decode(S.order_type, 30, S.qty_completed,0)
		     AND     (S.ORDER_TYPE IN (
		                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
		                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), --1882898
		                   DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
		                   DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
		                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
		                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1),
		                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
		                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
		                   DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
		                   DECODE(R.INCLUDE_INTERNAL_REQS, 1, 2, -1),
		                   DECODE(R.INCLUDE_SUPPLIER_REQS, 1, 2, -1),
		                   DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1),
		                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
		                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
		               OR
		                   ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
		                   S.ORDER_TYPE = 5
		               AND exists (SELECT '1'
		                      FROM    MSC_DESIGNATORS
		                      WHERE   INVENTORY_ATP_FLAG = 1
		                      AND     DESIGNATOR_TYPE = 2
		                      AND     DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID)))
		    AND      C.CALENDAR_CODE = TP.calendar_code
		    AND      C.EXCEPTION_SET_ID = TP.calendar_exception_set_id
		    AND      C.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		    AND      C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,
		                       S.NEW_SCHEDULE_DATE))
		                   AND   TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
		                       NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
		    AND      DECODE(S.LAST_UNIT_COMPLETION_DATE,
		                    NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
		    AND      C.NEXT_SEQ_NUM >= DECODE(S.ORDER_TYPE, 18, C.NEXT_SEQ_NUM,
		                  DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
		                  NULL, C.NEXT_SEQ_NUM,
		                  C2.next_seq_num - NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
		    AND      C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
		                                        28, TRUNC(SYSDATE),
		                             C.NEXT_DATE)   -- to_date removed to avoid GSCC error
		    AND     MSI.plan_id (+) =  -1
		    AND     MSI.organization_id (+) = S.ORGANIZATION_ID
		    AND     MSI.sr_instance_id (+) =  S.sr_instance_id
		    AND     MSI.sub_inventory_code (+) = S.subinventory_code
		    AND     NVL(MSI.inventory_atp_code,1) <> 2
		    AND     C2.CALENDAR_CODE = TP.calendar_code
		    AND     C2.EXCEPTION_SET_ID = TP.calendar_exception_set_id
		    AND     C2.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
		    AND     C2.CALENDAR_DATE = TRUNC(l_sys_date)
		    AND     TP.SR_INSTANCE_ID = p_instance_id
		    AND     TP.PARTNER_TYPE   = 3
		   ) SD
                 GROUP BY sd.inventory_item_id, sd.organization_id, sd.demand_class,
                           sd.sd_date, -1, p_instance_id, l_sys_date, l_user_id);

        END IF;
	-- rajjain 02/17/2003 GOP Performance Improvement - ODS Summary changes end

	---exchange  partition
        IF  (P_COLLECT_TYPE = 1) OR (P_COLLECT_TYPE = 3)  THEN
	   msc_util.msc_log('Swap partition for Slaes Orders. Only for full collection');
           ---- Create index on MSC_ATP_SUMMARY_SO
           BEGIN
              msc_util.msc_log('Create index on MSC_TEMP_SUMM_SO');
              l_sql_stmt_1 := 'create UNIQUE index MSC_TEMP_SUMM_SO_N1 on MSC_TEMP_SUMM_SO ' ||
               '
               -- NOLOGGING
              (sr_instance_id, organization_id, inventory_item_id, sd_date, demand_class)
              storage(INITIAL 40K NEXT 2M PCTINCREASE 0)'; --tablespace ' || l_tbspace(i);
              msc_util.msc_log('Before create index on MSC_atp_summary_so: ');
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
               		   APPLICATION_SHORT_NAME => 'MSC',
               		   STATEMENT_TYPE => ad_ddl.create_index,
               		   STATEMENT => l_sql_stmt_1,
               		   OBJECT_NAME => 'MSC_TEMP_SUMM_SO');
           END;
           --analyze temp table
           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_SUMM_SO', granularity => 'ALL');

           l_partition_name := 'ATP_SUMMARY_SO__' || to_char(p_instance_id);
           msc_util.msc_log('Sales order partition name := ' || l_partition_name);
           l_sql_stmt := 'ALTER TABLE MSC_ATP_SUMMARY_SO exchange partition ' || l_partition_name  ||
           ' with table MSC_TEMP_SUMM_SO'||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table MSC_ATP_SUMMARY_SO: ');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ATP_SUMMARY_SO');
       	   END;
	END IF;

        IF (P_COLLECT_TYPE = 2) OR (P_COLLECT_TYPE = 3) THEN
           ----swap partiton for supplies and demand part
           msc_util.msc_log('swap partition for supply-demand');
           BEGIN
              l_sql_stmt_1 := 'create unique index MSC_TEMP_SUMM_SD_N1 on MSC_TEMP_SUMM_SD ' ||
               '
               -- NOLOGGING
              (plan_id, sr_instance_id, organization_id,inventory_item_id,sd_date, demand_class)
              storage(INITIAL 40K NEXT 2M PCTINCREASE 0)'; --tablespace ' || l_tbspace(i);
              msc_util.msc_log('Before create index on MSC_atp_summary_sd: ');
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
               		   APPLICATION_SHORT_NAME => 'MSC',
               		   STATEMENT_TYPE => ad_ddl.create_index,
               		   STATEMENT => l_sql_stmt_1,
               		   OBJECT_NAME => 'MSC_TEMP_SUMM_SD');
           END;
           ---analyze supply demand table
           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_SUMM_SD', granularity => 'ALL');

           l_partition_name := 'ATP_SUMMARY_SD__' || to_char(p_instance_id) ;

           msc_util.msc_log('Partition name for msc_atp_summary table sd part := ' || l_partition_name);

           l_sql_stmt := 'ALTER TABLE MSC_ATP_SUMMARY_SD exchange partition ' || l_partition_name  ||
           ' with table MSC_TEMP_SUMM_SD'||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table MSC_ATP_SUMMARY_sd: ');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ATP_SUMMARY_SD');
       	   END;
        END IF;

        ---- clean tables
        MSC_POST_PRO.CLEAN_TABLES(l_applsys_schema);

	--update the so_tbl_status to 1 so that user can do ATP
        BEGIN
           UPDATE msc_apps_instances
           set    so_tbl_status = 1,
                  summary_flag = 3
           where  instance_id = p_instance_id;
           --- commit the change
          commit;
        END;

ERRBUF := null;
RETCODE := G_SUCCESS;
commit;

EXCEPTION
     WHEN OTHERS  THEN
          msc_util.msc_log('Inside main exception');
          msc_util.msc_log(sqlerrm);
          ERRBUF := sqlerrm;
          RETCODE := G_ERROR;
          --- clean tables
          MSC_POST_PRO.CLEAN_TABLES(l_applsys_schema);
          ----update so_tbl_status
          BEGIN
            UPDATE msc_apps_instances
            set    so_tbl_status = 1,
                    summary_flag = 1
            where  instance_id = p_instance_id;
          END;
          commit;


END LOAD_SUPPLY_DEMAND;

-- 24x7
-- Function logic modified.
PROCEDURE LOAD_PLAN_SD ( ERRBUF                 OUT     NoCopy VARCHAR2,
                         RETCODE                OUT     NoCopy NUMBER,
                         p_plan_id              IN      NUMBER,
                         p_calling_module       IN      NUMBER := 1) /* Bug 3478888 Added input parameter
                                                                        to identify how ATP Post Plan Processing
                                                                        has been launched */
IS

share_partition   		VARCHAR2(1);
l_applsys_schema                varchar2(10);
l_msc_schema                    VARCHAR2(30);
l_retval                        BOOLEAN;
dummy1                          varchar2(10);
dummy2                          varchar2(10);
l_partition_name                varchar2(30);
l_table_name			varchar2(30);
l_ret_code			number;
l_err_msg			varchar2(1000);
l_inv_ctp                       number;
l_summary_flag			number;
l_plan_id                       number;
i                               number;
l_count				number;
l_sysdate                       date;
l_user_id                       number;
l_alloc_atp   			VARCHAR2(1);
atp_summ_tab MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                        'ATP_SUMMARY_SD',
                                        'ATP_SUMMARY_RES',
                                        'ATP_SUMMARY_SUP');
-- Bug 2516506
l_plan_name                     varchar2(10);

-- 24x7
l_old_plan                      number;
l_plan_to_use                   number;
l_24_plan                       number;

l_new_plan_id                   number;
l_new_cp_plan_id                number;
l_old_plan_id                   number;
l_old_cp_plan_id                number;
-- rajjain 12/20/2002
l_spid                          VARCHAR2(12);

-- 2859130
l_optimized_plan                number;
l_old_optimized_plan            number;

-- time_phased_atp
l_member_count                  number;
l_return_status                 varchar2(1);
l_alloc_type                    number;
l_demand_priority               varchar2(1);
l_time_phased_pf                number;

-- summary enhancement
l_plan_start_date               date;
-- IO Perf:3693983: Don't Launch ATP Post Plan Processes for IO Plans
l_plan_type						NUMBER := 0;
l_organization_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_sr_instance_id        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
j                       pls_integer;
l_is_cmro               number := 0; --bug 7209209
BEGIN
    msc_util.msc_log ('LOAD_PLAN_SD: ' || 'Calling Module: ' || p_calling_module);

    -- Bug 3304390 Disable Trace
    -- Commented out
    -- rajjain 12/20/2002 begin
    -- IF G_TRACE = 'N' AND PG_DEBUG in ('T', 'C') THEN
    --    SELECT spid
    --    INTO   l_spid
    --    FROM   v$process
    --    WHERE  addr = (SELECT paddr FROM v$session
    --                    WHERE audsid=userenv('SESSIONID'));
    --    msc_util.msc_log('LOAD_PLAN_SD: ' || 'spid: ' || l_spid);
        -- dbms_session.set_sql_trace(true);
    --    G_TRACE := 'Y';
    -- END IF;
    -- rajjain 12/20/2002 end
    -- End Bug 3304390 Disable Trace

    -- For summary enhancement - initiallizing retcode with success
    RETCODE := G_SUCCESS;

    l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);
    msc_util.msc_log('LOAD_PLAN_SD: ' || 'inv_ctp := ' || l_inv_ctp);
    IF l_inv_ctp <> 4 THEN
        -- we are not doing PDS ATP so we wont  continue
        msc_util.msc_log('LOAD_PLAN_SD: ' || 'Not Doing PDS ATP. Please check profile - INV: Capable to Promise". Will Exit ');
        RETCODE := G_WARNING;
        RETURN;
    ELSE

        -- 24x7 Switch
        msc_util.msc_log ('LOAD_PLAN_SD: ' || 'Trying to see if this is a 24x7 run');
        msc_util.msc_log ('LOAD_PLAN_SD: ' || 'Plan ID : ' || p_plan_id);
        BEGIN

            -- 2859130
            select  newp.plan_id, NVL(newp.copy_plan_id, -1),
                    DECODE(newp.plan_type, 4, 2,
                        DECODE(daily_material_constraints, 1, 1,
                            DECODE(daily_resource_constraints, 1, 1,
                                DECODE(weekly_material_constraints, 1, 1,
                                    DECODE(weekly_resource_constraints, 1, 1,
                                        DECODE(period_material_constraints, 1, 1,
                                            DECODE(period_resource_constraints, 1, 1, 2)
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    -- IO Perf:3693983: Don't Launch ATP Post Plan Processes for IO Plans
                    newp.plan_type
            into    l_new_plan_id, l_new_cp_plan_id, l_optimized_plan, l_plan_type
            from    msc_plans newp
            where   newp.plan_id = p_plan_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                msc_util.msc_log('Unable to find plan data');
                RETCODE := G_ERROR;
                ERRBUF := sqlerrm;
                RETURN;
        END;

        msc_util.msc_log ('LOAD_PLAN_SD: ' || 'Plan Type : ' || l_plan_type);
        IF l_plan_type = 4 THEN
           IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('LOAD_PLAN_SD: Do not Launch process for IO Plan');
           END IF;
           RETCODE := G_SUCCESS;
           RETURN;
        END IF;

        -- IO Perf:3693983: Moved update of msc_system_items to Load_Plan_SD from atp_snapshot_hook

        select  organization_id, sr_instance_id
        BULK COLLECT INTO l_organization_id, l_sr_instance_id
        from msc_plan_organizations
        WHERE plan_id=p_plan_id;

        --FORALL j IN l_organization_id.first.. l_organization_id.last
        FOR j IN l_organization_id.first.. l_organization_id.last LOOP
        UPDATE msc_system_items mst1
        SET (REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG,ATP_RULE_ID,DEMAND_TIME_FENCE_DAYS) =(SELECT REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG,ATP_RULE_ID,DEMAND_TIME_FENCE_DAYS
                    FROM msc_system_items mst2
                    WHERE mst2.sr_instance_id=mst1.sr_instance_id
                    AND mst2.organization_id=mst1.organization_id
                    AND mst2.INVENTORY_ITEM_ID=mst1.INVENTORY_ITEM_ID
                    AND mst2.plan_id=-1
                     )
        WHERE   plan_id=p_plan_id
        AND     mst1.ORGANIZATION_ID = l_organization_id(j)
        AND     mst1.SR_INSTANCE_ID = l_sr_instance_id(j)
        --populate replenish to order flag for option items as well.
        AND     mst1.bom_item_type  in (1,2,4,5)
        --bug 3713374: Missing brackets was making OR condition to be stand alone filtering criteria
        AND     (mst1.atp_flag <> 'N' OR  mst1.atp_components_flag <> 'N');

           --5027568
        msc_util.msc_log('LOAD_PLAN_SD: deleting reservation records from msc_demands'); --5027568

        Delete MSC_DEMANDS
        where origination_type = -100
        and plan_id = p_plan_id
        and ORGANIZATION_ID = l_organization_id(j)
        and sr_instance_id = l_sr_instance_id(j);

        msc_util.msc_log('LOAD_PLAN_SD: no of records deleted: '|| SQL%ROWCOUNT);
         --5027568, to insert a record for hard reservation in msc_demands.

        msc_util.msc_log('LOAD_PLAN_SD: populating msc_demands with reservation records');

        INSERT INTO MSC_DEMANDS(
                    DEMAND_ID,
                    USING_REQUIREMENT_QUANTITY,
                    RESERVED_QUANTITY,
                    USING_ASSEMBLY_DEMAND_DATE,
                    DEMAND_TYPE,
                    DEMAND_SOURCE_TYPE,
                    ORIGINATION_TYPE,
                    USING_ASSEMBLY_ITEM_ID,
                    PLAN_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    SALES_ORDER_LINE_ID,
                    SR_INSTANCE_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    DEMAND_CLASS,
                    REFRESH_NUMBER,
                    ORDER_NUMBER,
                    APPLIED,
                    STATUS,
                    CUSTOMER_ID,
                    SHIP_TO_SITE_ID,
                    RECORD_SOURCE,
                    ATP_SYNCHRONIZATION_FLAG,
                    DMD_SATISFIED_DATE,
                    DISPOSITION_ID,
                    LINK_TO_LINE_ID,
                    wip_supply_type,
                    ORIGINAL_ITEM_ID )
            (select
                    msc_demands_s.nextval,
                    RESERVED_QUANTITY,
                    0, --putting 0 in reserved qty
                    sysdate, --USING_ASSEMBLY_DEMAND_DATE,
                    DEMAND_TYPE,
                    DEMAND_SOURCE_TYPE,
                    -100, -- putting orgination_type as -100 so that planning UI will not pick it up.
                    USING_ASSEMBLY_ITEM_ID,
                    PLAN_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    SALES_ORDER_LINE_ID,
                    SR_INSTANCE_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    DEMAND_CLASS,
                    REFRESH_NUMBER,
                    ORDER_NUMBER,
                    APPLIED,
                    STATUS,
                    CUSTOMER_ID,
                    SHIP_TO_SITE_ID,
                    RECORD_SOURCE,
                    ATP_SYNCHRONIZATION_FLAG,
                    DMD_SATISFIED_DATE,
                    DISPOSITION_ID,
                    LINK_TO_LINE_ID,
                    wip_supply_type,
                    ORIGINAL_ITEM_ID
                    from msc_demands
                    where plan_id = p_plan_id
                    and   reserved_quantity <> 0
                    and   organization_id = l_organization_id(j)
                    and   sr_instance_id  = l_sr_instance_id(j)
                    and   origination_type in (30,6)
                    );

         msc_util.msc_log('LOAD_PLAN_SD: no of records updated: '|| SQL%ROWCOUNT);
         END LOOP;
        --5027568

        l_plan_to_use := -1;
        l_24_plan := 0;

        if l_new_cp_plan_id > 0 then
            -- the plan that is passed in is the new copy.
            -- this is what we need to process.
            -- this will happen when we are called from planning
            l_plan_to_use := p_plan_id ;
            l_old_plan := l_new_cp_plan_id;
            l_24_plan := 1;
        else
            -- the plan id we got does not look like a copy.
            -- check to see if there is a plan with a copy plan_id
            -- equal to this
            BEGIN

                -- 2859130
                select  plan_id,
                        DECODE(plan_type, 4, 2,
                            DECODE(daily_material_constraints, 1, 1,
                                DECODE(daily_resource_constraints, 1, 1,
                                    DECODE(weekly_material_constraints, 1, 1,
                                        DECODE(weekly_resource_constraints, 1, 1,
                                            DECODE(period_material_constraints, 1, 1,
                                                DECODE(period_resource_constraints, 1, 1, 2)
                                            )
                                        )
                                    )
                                )
                            )
                        )
                into    l_old_plan_id, l_old_optimized_plan
                from    msc_plans
                where   copy_plan_id = p_plan_id;
            EXCEPTION
                when NO_DATA_FOUND then
                    l_plan_to_use := p_plan_id;
            END;

            if (NVL(l_old_plan_id, -1) > 0) then
                -- there is a copy plan for this plan
                -- we need to use this.
                -- this is the case when post_pro is launched
                -- as a separate concurrent proram
                l_plan_to_use := l_old_plan_id;
                l_old_plan := p_plan_id;
                l_24_plan := 1;
                l_optimized_plan := l_old_optimized_plan; -- 2859130
                msc_util.msc_log ('---- A Copy plan found ----');
                msc_util.msc_log ('  A copy of the plan for a 24x7 plan run was found');
                msc_util.msc_log ('  Switching to that plan ID for future processing');
                msc_util.msc_log ('  The plan ID that will be used : ' || l_plan_to_use);

            else
                l_plan_to_use := p_plan_id;
            end if;
        end if;
        msc_util.msc_log ('After processing the plan ID');
        msc_util.msc_log ('The following plan ID will be used for further post processing');
        msc_util.msc_log ('Using plan  : ' || l_plan_to_use);

        --bug 7209209 start
        /* Find out if this is CMRO scenario */
        FOR j IN l_organization_id.first.. l_organization_id.last LOOP
          select count(*)
          into l_is_cmro
          from msc_sales_orders so
          where demand_source_type = 100
          and organization_id=l_organization_id(j)
          and sr_instance_id = l_sr_instance_id(j);

          if(l_is_cmro > 0) then
          	exit;
          end if;
        END LOOP;

        if(l_is_cmro > 0) then
        	 msc_util.msc_log ('This is a CMRO scenario...');
           FORALL j IN l_organization_id.first.. l_organization_id.last
           update msc_demands dem
           set demand_source_type = (select distinct demand_source_type
                                     from msc_sales_orders so
                                     where so.sales_order_number = dem.order_number
                                       and so.organization_id = dem.organization_id
                                       and so.sr_instance_id = dem.sr_instance_id
                                       and so.inventory_item_id = dem.inventory_item_id
                                     )
           where organization_id = l_organization_id(j)
           and sr_instance_id = l_sr_instance_id(j)
           and origination_type in (6,30)
           and plan_id = l_plan_to_use;
        end if;
        --bug 7209209 end

        -- Begin ATP4drp In case we are dealing with a DRP plan reset variables.
        IF l_plan_type = 5 THEN
           G_ALLOC_ATP := 'N';
           G_CLASS_HRCHY := 2;
           G_ALLOC_METHOD := 2;
           -- Do not Call Populate_ATF_Dates for PF ATP.
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
              msc_util.msc_log('G_ALLOC_ATP    := ' || G_ALLOC_ATP);
              msc_util.msc_log('LOAD_PLAN_SD: DRP Plan Populate ATF_Dates not called');
              msc_util.msc_log('LOAD_PLAN_SD: G_ALLOC_ATP ' || G_ALLOC_ATP);
              msc_util.msc_log('LOAD_PLAN_SD: DRP Plan Allocation not supported');
              msc_util.msc_log('LOAD_PLAN_SD: DRP Plan, Hence Post Plan Pegging not called');
              msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
           END IF;
        ELSE -- Carry out processing for non-DRP plan.
           G_ALLOC_ATP := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
           G_CLASS_HRCHY := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);
           G_ALLOC_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'), 2);

           msc_util.msc_log('G_ALLOC_ATP    := ' || G_ALLOC_ATP);
           msc_util.msc_log('G_CLASS_HRCHY  := ' || G_CLASS_HRCHY);
           msc_util.msc_log('G_ALLOC_METHOD := ' || G_ALLOC_METHOD);
           -- time_phased_atp changes begin
           /* Populate ATF dates*/
           MSC_ATP_PF.Populate_ATF_Dates(l_plan_to_use, l_member_count, l_return_status);

           /* Print error in conc log file if return status is not success*/
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               msc_util.msc_log('Return status after call to Populate_ATF_Dates is ' || l_return_status);
               msc_util.msc_log(' ');
               msc_util.msc_log('******************************************************************');
               msc_util.msc_log('*                            WARNING                             *');
               msc_util.msc_log('*  Please note that the results of post plan processing may not  *');
               msc_util.msc_log('*  be accurate for product family/product family member items.   *');
               msc_util.msc_log('*  Please re-run ATP Post Plan Processing seperately to ensure   *');
               msc_util.msc_log('*  correct ATP results                                           *');
               msc_util.msc_log('******************************************************************');
               msc_util.msc_log(' ');
           END IF;

           /* Call pf_post_plan_proc procedure only if:
               o There are finite member items having ATF set up. This is to make sure
                 that the customers not using time phased ATP are not affected.
           */
           IF l_member_count > 0 THEN
               msc_util.msc_log('Found finite member items having ATF.');

               IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
                   msc_util.msc_log('Calling pf_post_plan_proc for pre-allocation, supplies rollup and bucketing');
                   l_demand_priority := 'Y';
               ELSE
                   msc_util.msc_log('Calling pf_post_plan_proc for supplies rollup and bucketing');
                   l_demand_priority := 'N';
               END IF;
               msc_atp_pf.pf_post_plan_proc(ERRBUF, RETCODE, l_plan_to_use, l_demand_priority);
           -- time_phased_atp changes end

               -- Begin CTO ODR Simplified Pegging Generation
               msc_util.msc_log('Calling post_plan_pegging to generate ATP pegging ' );

               MSC_ATP_PEG.post_plan_pegging(ERRBUF, RETCODE, l_plan_to_use);

               msc_util.msc_log('After Call to Post_Plan_Pegging ' );
               IF RETCODE = G_SUCCESS THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed successfully');
               ELSIF RETCODE = G_WARNING THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed with WARNING');
               ELSE
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging failed. Will exit');
                   -- RETURN;
               END IF;
               -- End CTO ODR Simplified Pegging Generation

           -- for summary enhancement
           ELSIF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
               -- we are doing Allocated ATP so we need to call post_plan_allocation
               msc_util.msc_log('Doing demand priority allocated ATP. Will call post_plan_allocation ');

               msc_post_pro.post_plan_allocation(ERRBUF, RETCODE, l_plan_to_use);

               IF RETCODE <> G_SUCCESS THEN
                   msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan allocation failed. Will exit');
                   RETURN;
               END IF;
               msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan allocation completed successfully');

               -- Begin CTO ODR Simplified Pegging Generation
               msc_util.msc_log('Calling post_plan_pegging to generate ATP pegging ' );

               MSC_ATP_PEG.post_plan_pegging(ERRBUF, RETCODE, l_plan_to_use);

               msc_util.msc_log('After Call to Post_Plan_Pegging ' );
               IF RETCODE = G_SUCCESS THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed successfully');
               ELSIF RETCODE = G_WARNING THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed with WARNING');
               ELSE
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging failed. Will exit');
                   -- RETURN;
               END IF;
               -- End CTO ODR Simplified Pegging Generation

               -- for summary enhancement - synchronization call moved to end
               -- 24x7 Hooks
               /*
               if (l_24_plan > 0) then
                   -- call 24x7 ATP Synchronize
                   msc_util.msc_log ('Calling 24x7 Synchronization');
                   MSC_ATP_24X7.Call_Synchronize (ERRBUF, RETCODE, l_old_plan);
               end if;
               RETURN;
               */
           ELSE -- Always carry out post_plan_pegging.

               -- Begin CTO ODR Simplified Pegging Generation
               msc_util.msc_log('Calling post_plan_pegging to generate ATP pegging ' );

               MSC_ATP_PEG.post_plan_pegging(ERRBUF, RETCODE, l_plan_to_use);

               msc_util.msc_log('After Call to Post_Plan_Pegging ' );
               IF RETCODE = G_SUCCESS THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed successfully');
               ELSIF RETCODE = G_WARNING THEN
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging completed with WARNING');
               ELSE
                  msc_util.msc_log('LOAD_PLAN_SD: ' || 'Post plan Pegging failed. Will exit');
                   --RETURN;
               END IF;
           END IF;
        END IF;
        -- ATP4drp End

    END IF;

    IF ((NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N') = 'Y')
         AND (G_ALLOC_ATP = 'N'                                 -- After summary ehancement summary will be
              OR (G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1)     -- supported fot demand priority based
             )                                                  -- allocated ATP
        ) THEN
        msc_util.msc_log('begin Loading data for plan ' || l_plan_to_use);

        share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');
        msc_util.msc_log('share_partition := ' || share_partition);

        -- for summary enhancement - backlog workbench will be supported with summary
        /*
        SELECT  NVL(SUMMARY_FLAG,1)
        into   l_summary_flag
        from   msc_apps_instances
        where  rownum = 1;

        IF NVL(l_summary_flag,1) = 200 THEN
            msc_util.msc_log('Summary Approach is not supported for sites using backlog workbench');
            RETCODE := G_WARNING;
            RETURN;
        END IF;
        */

        -- Bug 2516506 - select plan name also
        SELECT NVL(SUMMARY_FLAG,1), COMPILE_DESIGNATOR, trunc(plan_start_date)
        into   l_summary_flag, l_plan_name, l_plan_start_date
        from   msc_plans
        where  plan_id = l_plan_to_use;

        -- for summary enhancement
        IF NVL(l_summary_flag,1) NOT IN (G_SF_SUMMARY_NOT_RUN, G_SF_PREALLOC_COMPLETED, G_SF_ATPPEG_COMPLETED, G_SF_SUMMARY_COMPLETED) THEN
            msc_util.msc_log('LOAD_PLAN_SD: ' || 'Another session is running post-plan processing for this plan');
            RETCODE :=  G_ERROR;
            RETURN;
        END IF;

        l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);
        SELECT  a.oracle_username
        INTO    l_msc_schema
        FROM    FND_ORACLE_USERID a,
                FND_PRODUCT_INSTALLATIONS b
        WHERE   a.oracle_id = b.oracle_id
        AND     b.application_id = 724;

        FOR i in 1..atp_summ_tab.count LOOP
            l_table_name := 'MSC_' || atp_summ_tab(i);
            IF (share_partition = 'Y') THEN
                l_plan_id := MAXVALUE;
            ELSE
                l_plan_id := l_plan_to_use;
            END IF;

            l_partition_name :=  atp_summ_tab(i)|| '_' || l_plan_id;
            msc_util.msc_log('l_partition_name := ' || l_partition_name);

            BEGIN
                SELECT  count(*)
                INTO    l_count
                --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                --FROM DBA_TAB_PARTITIONS
                FROM    ALL_TAB_PARTITIONS
                WHERE   TABLE_NAME = l_table_name
                AND     PARTITION_NAME = l_partition_name
                AND     table_owner = l_msc_schema;
            EXCEPTION
                WHEN OTHERS THEN
                    msc_util.msc_log('Inside Exception');
                    l_count := 0;
            END;
            IF  (l_count = 0) THEN
                -- Bug 2516506
                FND_MESSAGE.SET_NAME('MSC', 'MSC_ATP_PLAN_PARTITION_MISSING');
                FND_MESSAGE.SET_TOKEN('PLAN_NAME', l_plan_name);
                FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'MSC_' || atp_summ_tab(i));
                msc_util.msc_log(FND_MESSAGE.GET);
                RETCODE := G_ERROR;
                RETURN;
            END IF;
        END LOOP;

        BEGIN
            update msc_plans
            set    summary_flag = G_SF_FULL_SUMMARY_RUNNING -- for summary enhancement: ATP is up hereafter
            where  plan_id = l_plan_to_use;
            commit;
        EXCEPTION
            WHEN OTHERS THEN
                ERRBUF := sqlerrm;
                RETCODE := G_ERROR;
                RETURN;
        END;


        msc_util.msc_log('LOAD_PLAN_SD: ' || 'share_partition := ' || share_partition);
        l_sysdate := sysdate;
        l_user_id := FND_GLOBAL.USER_ID;

        BEGIN   -- Enclose summary specific operations within BEGIN-EXCEPTION-END block for summary enhancement

            IF share_partition='N' THEN
                -- Need to truncate partitions in all tables in one go as it causes implicit commit - for summary enhancement
                Truncate_Summ_Plan_Partition(l_plan_to_use, l_applsys_schema);
            END IF;

            -- s/d processing moved to new procedure with summary enhancement
            IF l_member_count > 0 THEN
                -- PF setup exists
                l_time_phased_pf := 1;
            ELSE
                -- PF setup does not exist
                l_time_phased_pf := 2;
            END IF;
            MSC_POST_PRO.LOAD_PLAN_SUMMARY_SD(l_plan_to_use,
                                        share_partition,
                                        l_optimized_plan,
                                        1,                -- p_full_refresh :         Full summation
                                        l_time_phased_pf, -- p_time_phased_pf :       Time phased pf setup exists
                                        l_plan_type,      -- ATP4drp Pass plan_type as a parameter
                                        null,             -- p_last_refresh_number :  Null for full summation
                                        null,             -- p_new_refresh_number :   Null for full summation
                                        l_sysdate);
            -- ATP4drp Call Resource summation only for non-DRP plan
            IF l_plan_type <> 5 THEN
               MSC_POST_PRO.LOAD_RESOURCES(l_plan_to_use,
                                           share_partition,
                                           l_applsys_schema,
                                           1,                  -- Full summation
                                           l_plan_start_date,
                                           l_sysdate);
            END IF;
            -- End ATP4drp
            MSC_POST_PRO.INSERT_SUPPLIER_DATA(l_plan_to_use,
                                              share_partition,
                                              l_applsys_schema,
                                              1,            -- Full summation
                                              l_sysdate);

            -- refresh number should be updated before gather stats as gathering stats causes implicit commit
            BEGIN
                msc_util.msc_log ('LOAD_PLAN_SD: ' || 'updating summary flag and refresh number');
                update  msc_plans
                set     summary_flag = G_SF_SUMMARY_COMPLETED, -- For summary enhancement
                        latest_refresh_number = (SELECT apps_lrn
                                                 FROM   MSC_PLAN_REFRESHES
                                                 WHERE  plan_id = l_plan_to_use)
                where   plan_id = l_plan_to_use;
            END;

            -- All stats should be gathered in one go as that also causes imlpicit commit - for summary enhancement
            Gather_Summ_Plan_Stats(l_plan_to_use, share_partition);

            RETCODE := G_SUCCESS;
            commit;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;

                IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
                    update  msc_plans
                    set     summary_flag = G_SF_PREALLOC_COMPLETED
                    where   plan_id = l_plan_to_use;
                ELSE
                    update  msc_plans
                    set     summary_flag = G_SF_SUMMARY_NOT_RUN
                    where   plan_id = l_plan_to_use;
                END IF;
                commit;
        END;
    END IF; --IF NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N') = 'Y' THEN

    -- 24x7 Hooks
    if (l_24_plan > 0) then
        -- Bug 3478888 Reset ATP_SYNCHRONIZATION_FLAG only if ATP Post Plan Processing
        -- is launched from plan
        if p_calling_module = 2 then
                -- Reset the ATP_SYNCHRONIZATION_FLAG to 0 for the original plan.
                -- Moved this from MSCPLAPB.pls
                msc_util.msc_debug('Update atp_synchronization_flag for 24x7 plan to support re-run after sync failure');

                update  msc_demands
                set     atp_synchronization_flag = 0 -- null
                where  (plan_id, sr_instance_id, organization_id) IN
                       (select  mpo.plan_id, mpo.sr_instance_id, mpo.organization_id
                        from    msc_plan_organizations mpo
                        where   mpo.plan_id = l_old_plan)
                and     origination_type in (6,30);

                COMMIT;
        end if;

        -- call 24x7 ATP Synchronize
        msc_util.msc_log ('Calling 24x7 Synchronization');
        MSC_ATP_24X7.Call_Synchronize (ERRBUF, RETCODE, l_old_plan);
    end if;
EXCEPTION
    WHEN OTHERS THEN
        -- For summary enhancement - No need to reset summary_flag here
        /*
        BEGIN
            update msc_plans
            set    summary_flag = 1
            where  plan_id = l_plan_to_use;
            commit;
        END;
        */

        msc_util.msc_log('Inside main exception');
        msc_util.msc_log(sqlerrm);
        ERRBUF := sqlerrm;
        RETCODE := G_ERROR;

        -- For summary enhancement - Need to rollback incomplete changes
        ROLLBACK;
END LOAD_PLAN_SD;


-- For summary enhancement - Entry point for Incremental PDS Summary
PROCEDURE Load_Net_Plan(
        ERRBUF          OUT     NoCopy VARCHAR2,
        RETCODE         OUT     NoCopy NUMBER,
        p_plan_id       IN      NUMBER)
IS
    l_spid                  VARCHAR2(12);
    l_inv_ctp               number;
    l_summary_flag          NUMBER;
    l_plan_completion_date  Date;
    l_enable_summary_mode   varchar2(1);
    l_time_phased           NUMBER;
    l_last_refresh_number   NUMBER;
    l_new_refresh_number    NUMBER;
    l_share_partition       VARCHAR2(1);
    l_plan_start_date       DATE;
    l_sysdate               DATE;
    -- ATP4drp define new plan_type variable.
    l_plan_type             NUMBER;
BEGIN
    -- Bug 3304390 Disable Trace
    -- Deleted Related Code.

    RETCODE := G_SUCCESS;
    l_sysdate := sysdate;

    msc_util.msc_log ('Load_Net_Plan: ' || 'Plan ID : ' || p_plan_id);

    l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);
    msc_util.msc_log('Load_Net_Plan: ' || 'inv_ctp := ' || l_inv_ctp);
    IF l_inv_ctp <> 4 THEN
        -- we are not doing PDS ATP so we wont  continue
        msc_util.msc_log('Load_Net_Plan: ' || 'Not Doing PDS ATP. Please check profile - INV: Capable to Promise". Will Exit ');
        RETCODE := G_WARNING;
        RETURN;
    END IF;

    l_enable_summary_mode := NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N');
    msc_util.msc_log('Load_Net_Plan: ' || 'l_enable_summary_mode := ' || l_enable_summary_mode);
    IF l_enable_summary_mode = 'N' THEN
        -- summary is not enabled so we wont continue
        msc_util.msc_log('Load_Net_Plan: ' || 'Not Doing Summary ATP. Please check profile - MSC: Enable ATP Summary Mode. Will Exit ');
        RETCODE := G_WARNING;
        RETURN;
    END IF;

    BEGIN
        select  summary_flag,
                plan_completion_date,
                latest_refresh_number,
                trunc(plan_start_date),
        -- ATP4drp obtain plan_type info.
                plan_type
        into    l_summary_flag, l_plan_completion_date, l_last_refresh_number, l_plan_start_date, l_plan_type
        -- End ATP4drp
        from    msc_plans
        where   plan_id = p_plan_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            msc_util.msc_log('Unable to find plan data');
            RETCODE := G_ERROR;
            ERRBUF := sqlerrm;
            RETURN;
    END;

    IF l_plan_completion_date IS NULL THEN
        msc_util.msc_log('Load_Net_Plan: ' || 'Either the plan is currently running or it ' ||
                         'did not complete successfully or it was never run. Will exit');
        RETCODE :=  G_WARNING;
        RETURN;
    END IF;

    --IF NVL(l_summary_flag,1) <> G_SF_SUMMARY_COMPLETED THEN 4754549 excluded 6 meaning 24X7 synch completed successfully.
    IF NVL(l_summary_flag,1) not in ( G_SF_SUMMARY_COMPLETED,G_SF_SYNC_SUCCESS)THEN
        msc_util.msc_log('Load_Net_Plan: ' || 'Full summary was not run. l_summary_flag is ' || l_summary_flag || '. Will Exit');
        RETCODE :=  G_ERROR;
        RETURN;
    END IF;

    -- Re-arranged code to keep variables initialization in one place.
    -- ATP4drp Re-set variables to disable Allocation and PF
    IF l_plan_type = 5 THEN
       l_time_phased := 2;
       G_ALLOC_ATP := 'N';
       G_CLASS_HRCHY := 2;
       G_ALLOC_METHOD := 2;
       IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
            msc_sch_wb.atp_debug('Load_Net_Plan: ' || 'PF and Allocated ATP not applicable for DRP plans');
            msc_util.msc_log('G_ALLOC_ATP    := ' || G_ALLOC_ATP);
            msc_util.msc_log('G_CLASS_HRCHY  := ' || G_CLASS_HRCHY);
            msc_util.msc_log('G_ALLOC_METHOD := ' || G_ALLOC_METHOD);
       END IF;
    ELSE -- ATP4drp Execute rest for only for non-DRP plans
       G_ALLOC_ATP := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
       G_CLASS_HRCHY := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);
       G_ALLOC_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'), 2);

       msc_util.msc_log('G_ALLOC_ATP    := ' || G_ALLOC_ATP);
       msc_util.msc_log('G_CLASS_HRCHY  := ' || G_CLASS_HRCHY);
       msc_util.msc_log('G_ALLOC_METHOD := ' || G_ALLOC_METHOD);

       IF G_ALLOC_ATP = 'Y' AND (G_CLASS_HRCHY <> 1 OR G_ALLOC_METHOD <> 1) THEN
           msc_util.msc_log('Load_Net_Plan: ' || 'Summary not supported for User-defined allocation. Will Exit ');
           RETCODE := G_WARNING;
           RETURN;
       END IF;

       -- Check if time phased pf setup exists
       IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
           -- does not matter for demand priority allocation as anyway we look at the alloc tables
           l_time_phased := NULL;
       ELSE

           BEGIN
               --bug3663487 start SQL_ID  9428030
               --  ATP4drp Removed commented code for fetch from msc_system_items.
               SELECT  1
               INTO    l_time_phased
               FROM    msc_system_items i ,msc_plan_organizations po
               WHERE   po.plan_id = p_plan_id
               AND     i.aggregate_time_fence_date IS NOT NULL
               AND     i.plan_id = po.plan_id
               AND     i.organization_id = po.organization_id
               AND     i.sr_instance_id  = po.sr_instance_id
               AND     rownum = 1;
            --bug3663487 end
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_time_phased := 2;
           END;

       END IF;

    END IF;
    -- End ATP4drp


    BEGIN
        update msc_plans
        set    summary_flag = G_SF_NET_SUMMARY_RUNNING
        where  plan_id = p_plan_id;
        commit;
    EXCEPTION
        WHEN OTHERS THEN
            ERRBUF := sqlerrm;
            RETCODE := G_ERROR;
            RETURN;
    END;

    -- Obtain the new refresh number
    SELECT  max(refresh_number)
    INTO    l_new_refresh_number
    FROM   (SELECT  refresh_number
            FROM    msc_demands
            WHERE   plan_id = p_plan_id

            UNION ALL

            SELECT  refresh_number
            FROM    msc_supplies
            WHERE   plan_id = p_plan_id

            UNION ALL

            SELECT  refresh_number
            FROM    msc_resource_requirements
            WHERE   plan_id = p_plan_id
           );

    IF l_new_refresh_number IS NULL THEN
        -- No data to summarize
        msc_util.msc_log('Load_Net_Plan: ' || 'No data to summarize. Will Exit');
        RETCODE :=  G_WARNING;
        RETURN;
    END IF;

    IF l_new_refresh_number = l_last_refresh_number THEN
        -- No change since last summary
        msc_util.msc_log('Load_Net_Plan: ' || 'No change since last summary');
        msc_util.msc_log('Load_Net_Plan: ' || 'updating summary flag and refresh number');
        update  msc_plans
        set     summary_flag = G_SF_SUMMARY_COMPLETED,
                latest_refresh_number = l_new_refresh_number
        where   plan_id = p_plan_id;
        RETCODE :=  G_SUCCESS;
        RETURN;
    END IF;

    MSC_POST_PRO.LOAD_PLAN_SUMMARY_SD(p_plan_id,
                                      null,     -- p_share_partition ->  Not required for
                                      null,     -- p_optimized_plan, ->  incremental summation
                                      2,        -- Incremental summation
                                      l_time_phased,
                                      l_plan_type,      -- ATP4drp Pass plan_type as a parameter
                                      l_last_refresh_number,
                                      l_new_refresh_number,
                                      l_sysdate);

    -- ATP4drp Call Resource summation only for non-DRP plan
    IF l_plan_type <> 5 THEN
       MSC_POST_PRO.LOAD_RESOURCES(p_plan_id,
                                   null,     -- p_share_partition ->  Not required for
                                   null,     -- p_optimized_plan, ->  incremental summation
                                   2,        -- Incremental summation
                                   l_plan_start_date,
                                   l_sysdate,
                                   l_last_refresh_number,
                                   l_new_refresh_number);
    END IF;
    -- End ATP4drp

    MSC_POST_PRO.INSERT_SUPPLIER_DATA(p_plan_id,
                                      null,     -- p_share_partition ->  Not required for
                                      null,     -- p_applsys_schema  ->  incremental summation
                                      2,        -- Incremental summation
                                      l_sysdate,
                                      l_last_refresh_number,
                                      l_new_refresh_number);

    BEGIN
        msc_util.msc_log ('Load_Net_Plan: ' || 'updating summary flag and refresh number');
        update  msc_plans
        set     summary_flag = G_SF_SUMMARY_COMPLETED, -- For summary enhancement
                latest_refresh_number = l_new_refresh_number
        where   plan_id = p_plan_id;
    END;

    -- All stats should be gathered in one go as that also causes imlpicit commit - for summary enhancement
    l_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');
    msc_util.msc_log('Load_Net_Plan: ' || 'l_share_partition := ' || l_share_partition);
    Gather_Summ_Plan_Stats(p_plan_id, l_share_partition);

    RETCODE := G_SUCCESS;
    commit;


EXCEPTION
    WHEN OTHERS THEN
        msc_util.msc_log('Load_Net_Plan: Inside main exception');
        msc_util.msc_log(sqlerrm);
        ERRBUF := sqlerrm;
        RETCODE := G_ERROR;

        -- For summary enhancement - Need to rollback incomplete changes
        ROLLBACK;

        update msc_plans
        set    summary_flag = G_SF_SUMMARY_COMPLETED
        where  plan_id = p_plan_id;
        commit;
END Load_Net_Plan;


PROCEDURE CLEAN_TABLES(p_applsys_schema IN  varchar2
                      )
IS
l_sql_stmt varchar2(300);
BEGIN
           --- clean up the tables
           msc_util.msc_log('Inside clean_tables_procedure ');
           l_sql_stmt := 'TRUNCATE TABLE MSC_TEMP_SUMM_SO';

           BEGIN
                   msc_util.msc_log('Tuncate Table MSC_TEMP_SUMM_SO');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.truncate_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SO');
           EXCEPTION
                   WHEN OTHERS THEN
                           msc_util.msc_log(sqlerrm);
                           msc_util.msc_log('Truncate table  MSC_TEMP_SUMM_SO failed');
           END;
           l_sql_stmt := 'TRUNCATE TABLE MSC_TEMP_SUMM_SD';

           BEGIN
                   msc_util.msc_log('Tuncate Table MSC_TEMP_SUMM_SD');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.truncate_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SD');
           EXCEPTION
                   WHEN OTHERS THEN
                           msc_util.msc_log(sqlerrm);
                           msc_util.msc_log('Truncate table  MSC_TEMP_SUMM_SD failed');
           END;
           l_sql_stmt := 'DROP INDEX MSC_TEMP_SUMM_SO_N1';

           BEGIN
                   msc_util.msc_log('Drop Index MSC_TEMP_SUMM_SO_N1');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.drop_index,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SO_N1');
           EXCEPTION
                   WHEN OTHERS THEN
                           msc_util.msc_log(sqlerrm);
                           msc_util.msc_log('Drop Index  MSC_TEMP_SUMM_SO_N1 failed');
           END;

	   l_sql_stmt := 'DROP INDEX MSC_TEMP_SUMM_SD_N1';

           BEGIN
                   msc_util.msc_log('Drop Index MSC_TEMP_SUMM_SD_N1');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.drop_index,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SD_N1');
           EXCEPTION
                   WHEN OTHERS THEN
                           msc_util.msc_log(sqlerrm);
                           msc_util.msc_log('Drop index MSC_TEMP_SUMM_SD_N1  failed');
           END;

END CLEAN_TABLES;

PROCEDURE INSERT_SUPPLIER_DATA(p_plan_id         IN NUMBER,
                               p_share_partition IN varchar2,
                               p_applsys_schema  IN varchar2,
                               p_full_refresh    IN NUMBER, -- 1:Yes, 2:No
                               p_sys_date        IN DATE,          -- For summary enhancement
                               p_last_refresh_number    IN NUMBER, -- For summary enhancement
                               p_new_refresh_number     IN NUMBER) -- For summary enhancement
AS
    l_partition_name varchar2(30);
    L_SQL_STMT varchar2(300);
    L_SQL_STMT_1 varchar2(300);
    l_sysdate    date;
    l_user_id    number;

BEGIN
    l_sysdate := sysdate;
    l_user_id := FND_GLOBAL.USER_ID;

    ---profile option for including purchase order
    MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE := NVL(FND_PROFILE.VALUE('MSC_PO_DOCK_DATE_CALC_PREF'), 2);

    IF p_full_refresh = 1 THEN  -- Full refresh - for summary enhancement

        -- Data for share_partition='N' has already been deleted
        IF p_share_partition = 'Y' THEN
            msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'Share partition ');
            --- first delete data from the table
            msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'Delete Data from msc_atp_summary_sup');
            delete MSC_ATP_SUMMARY_SUP where plan_id = p_plan_id;
        END IF;

        msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'Loading complete summary in MSC_ATP_SUMMARY_SUP');
        -- The actual SQL is moved to new procedure for summary enhancement
        LOAD_SUP_DATA_FULL(p_plan_id, p_sys_date);
        msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'After loading complete summary in MSC_ATP_SUMMARY_SUP');

        -- Code to gather stats was here. Removed for summary enhancement as stats are gathered right in the end.

	ELSE

        msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'Loading net summary in MSC_ATP_SUMMARY_SUP');
        LOAD_SUP_DATA_NET(p_plan_id, p_last_refresh_number, p_new_refresh_number, p_sys_date);
        msc_util.msc_log('INSERT_SUPPLIER_DATA: ' || 'After loading net summary in MSC_ATP_SUMMARY_SUP');


    END IF;

END INSERT_SUPPLIER_DATA;


FUNCTION get_tolerance_defined( p_plan_id IN NUMBER,
                                p_instance_id IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_inventory_item_id IN NUMBER,
                                p_supplier_id IN NUMBER,
                                p_supplier_site_id IN NUMBER)
RETURN NUMBER
IS
l_count number;
BEGIN

     SELECT count(*)
     INTO   l_count
     FROM   msc_supplier_flex_fences
     WHERE  plan_id = p_plan_id
     AND    sr_instance_id = p_instance_id
     AND    organization_id = p_organization_id
     AND    inventory_item_id = p_inventory_item_id
     AND    supplier_id = p_supplier_id
     AND    supplier_site_id = p_supplier_site_id;
     return l_count;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
            return 0;
END get_tolerance_defined;


PROCEDURE LOAD_RESOURCES (p_plan_id             IN NUMBER,
                          p_share_partition     IN varchar2,
                          p_applsys_schema      IN varchar2,
                          p_full_refresh        IN NUMBER,     -- 1:Yes, 2:No   -- for summary enhancement
                          p_plan_start_date     IN DATE,                        -- for summary enhancement
                          p_sys_date            IN DATE,                        -- for summary enhancement
                          p_last_refresh_number IN NUMBER DEFAULT NULL,         -- for summary enhancement
                          p_new_refresh_number  IN NUMBER DEFAULT NULL)         -- for summary enhancement
AS
l_optimized_plan number;
l_constraint_plan number;
l_use_bor number;
l_count number;
l_partition_name varchar2(30);
L_SQL_STMT varchar2(300);
L_SQL_STMT_1 varchar2(300);
l_MSO_Batch_flag varchar2(1);
l_use_batching number;
l_sysdate  date;
l_user_id  number;
BEGIN

    l_MSO_Batch_flag := NVL(fnd_profile.value('MSO_BATCHABLE_FLAG'),'N');
    msc_util.msc_log('LOAD_RESOURCES: ' || 'mso batchable flag := ' || l_MSO_Batch_flag );
    Begin
        SELECT  decode(designator_type, 2, 1, 0),
                DECODE(plans.plan_type, 4, 2,
                    DECODE(daily_material_constraints, 1, 1,
                        DECODE(daily_resource_constraints, 1, 1,
                            DECODE(weekly_material_constraints, 1, 1,
                                DECODE(weekly_resource_constraints, 1, 1,
                                    DECODE(period_material_constraints, 1, 1,
                                        DECODE(period_resource_constraints, 1, 1, 2)
                                          )
                                      )
                                  )
                              )
                          )
                      ),
                DECODE(l_MSO_Batch_Flag, 'Y', DECODE(plans.plan_type, 4, 0,2,0,  -- filter out MPS plans
                    DECODE(daily_material_constraints, 1, 1,
                        DECODE(daily_resource_constraints, 1, 1,
                            DECODE(weekly_material_constraints, 1, 1,
                                DECODE(weekly_resource_constraints, 1, 1,
                                    DECODE(period_material_constraints, 1, 1,
                                        DECODE(period_resource_constraints, 1, 1, 0)
                                          )
                                      )
                                  )
                              )
                          )
                      ), 0)
        INTO    l_use_bor, l_optimized_plan, l_constraint_plan
        FROM    msc_designators desig,
                msc_plans plans
        WHERE   plans.plan_id = p_plan_id
        AND     desig.designator = plans.compile_designator
        AND     desig.sr_instance_id = plans.sr_instance_id
        AND     desig.organization_id = plans.organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
            msc_util.msc_log('LOAD_RESOURCES: ' || 'In Exception : ' || sqlcode || ': ' || sqlerrm);
            l_use_bor := 0;
            l_optimized_plan := 2;
            l_constraint_plan := 0;
    END;

    msc_util.msc_log('LOAD_RESOURCES: ' || 'l_use_bor := ' || l_use_bor);
    msc_util.msc_log('LOAD_RESOURCES: ' || 'l_optimized_plan := ' || l_optimized_plan);
    msc_util.msc_log('LOAD_RESOURCES: ' || 'l_constraint_plan := ' || l_constraint_plan);

    IF (l_MSO_Batch_Flag = 'Y') and (l_use_bor = 0) and (l_constraint_plan = 1) THEN
        msc_util.msc_log('LOAD_RESOURCES: ' || 'Do Batching');
        l_use_batching := 1;
    ELSE
        msc_util.msc_log('LOAD_RESOURCES: ' || 'No Batching');
        l_use_batching := 0;
    END IF;
    l_sysdate := sysdate;
    l_user_id := FND_GLOBAL.USER_ID;

    IF p_full_refresh = 1 THEN  -- Full refresh - for summary enhancement

        -- Data for share_partition='N' has already been deleted
        IF p_share_partition = 'Y' THEN
            msc_util.msc_log('LOAD_RESOURCES: ' || 'Share partition ');
            --- first delete data from the table
            msc_util.msc_log('LOAD_RESOURCES: ' || 'Delete Data from MSC_ATP_SUMMARY_RES');
            DELETE MSC_ATP_SUMMARY_RES where plan_id = p_plan_id;
            msc_util.msc_log('LOAD_RESOURCES: ' || 'After deleting old resources info');
        END IF;

        -- The actual SQLs moved to private procedures for modularity : summary enhancement
        IF l_use_batching = 1 THEN
            msc_util.msc_log('LOAD_RESOURCES: ' || 'Doing Batching');

            --2859130
            IF nvl(l_optimized_plan, 2) <> 1 THEN
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Unconstrained plan.');
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Insert data into res table');

                load_res_full_unopt_batch(p_plan_id, p_plan_start_date, p_sys_date);

                msc_util.msc_log('LOAD_RESOURCES: ' || 'After inserting into MSC_ATP_SUMMARY_RES');
            ELSE
             -- constrained plan
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Constrained plan.');
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Insert data into res table');

                load_res_full_opt_batch(p_plan_id, p_plan_start_date, p_sys_date);

                msc_util.msc_log('LOAD_RESOURCES: ' || 'After inserting into MSC_ATP_SUMMARY_RES');
            END IF;

        ELSE --- if l_use_batching =1
            msc_util.msc_log('LOAD_RESOURCES: ' || 'Not doing Batching');

            --2859130
            IF nvl(l_optimized_plan, 2) <> 1 THEN
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Unconstrained plan.');
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Insert data into res table');

                load_res_full_unopt_nobatch(p_plan_id, p_plan_start_date, p_sys_date);

                msc_util.msc_log('LOAD_RESOURCES: ' || 'After inserting into MSC_ATP_SUMMARY_RES');
            ELSE
                -- 2859130 constrained plan
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Constrained plan.');
                msc_util.msc_log('LOAD_RESOURCES: ' || 'Insert data into res table');

                load_res_full_opt_nobatch(p_plan_id, p_plan_start_date, p_sys_date);

                msc_util.msc_log('LOAD_RESOURCES: ' || 'After inserting into MSC_ATP_SUMMARY_RES');
          END IF;

        END IF; --- if l_use_batching = 1

        -- Code to gather stats was here. Removed for summary enhancement as stats are gathered right in the end.

    ELSE -- Net refresh - for summary enhancement
        -- IF p_full_refresh = 1 THEN  -- Full refresh - for summary enhancement

        msc_util.msc_log('LOAD_RESOURCES: ' || 'Loading net summary in MSC_ATP_SUMMARY_RES');
        -- since at this point we need to bother only about ATP generated records we dont look for opt/unopt or batching
        load_res_data_net(p_plan_id, p_last_refresh_number, p_new_refresh_number, p_sys_date);
        msc_util.msc_log('LOAD_RESOURCES: ' || 'After loading net summary in MSC_ATP_SUMMARY_RES');

    END IF;
END LOAD_RESOURCES;


Procedure Clean_Plan_Tables( p_applsys_schema IN  varchar2 )
IS
l_sql_stmt varchar2(100);
BEGIN

    l_sql_stmt := 'TRUNCATE TABLE MSC_TEMP_SUMM_SD';

    BEGIN
        msc_util.msc_log('Tuncate Table MSC_TEMP_SUMM_SD');
        ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.truncate_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SD');
    EXCEPTION
        WHEN OTHERS THEN
             msc_util.msc_log(sqlerrm);
             msc_util.msc_log('Truncate table failed');
    END;

    l_sql_stmt := 'DROP INDEX MSC_TEMP_SUMM_SD_N1';

    BEGIN
        msc_util.msc_log('Drop Index MSC_TEMP_SUMM_SD_N1');
	ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
		   APPLICATION_SHORT_NAME => 'MSC',
		   STATEMENT_TYPE => ad_ddl.drop_index,
		   STATEMENT => l_sql_stmt,
		   OBJECT_NAME => 'MSC_TEMP_SUMM_SD_N1');
     EXCEPTION
	WHEN OTHERS THEN
	     msc_util.msc_log(sqlerrm);
	     msc_util.msc_log('Truncate table failed');
     END;

     l_sql_stmt := 'TRUNCATE TABLE MSC_TEMP_SUMM_SUP';

     BEGIN
         msc_util.msc_log('Tuncate Table MSC_TEMP_SUMM_SUP');
         ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.truncate_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SUP');
     EXCEPTION
         WHEN OTHERS THEN
              msc_util.msc_log(sqlerrm);
              msc_util.msc_log('Truncate table  MSC_TEMP_SUMM_SUP failed');
     END;

     l_sql_stmt := 'DROP INDEX MSC_TEMP_SUMM_SUP_N1';

     BEGIN
         msc_util.msc_log('Drop Index MSC_TEMP_SUMM_SUP_N1');
         ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.drop_index,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_SUP_N1');
     EXCEPTION
         WHEN OTHERS THEN
              msc_util.msc_log(sqlerrm);
              msc_util.msc_log('Drop Index MSC_TEMP_SUMM_SUP_N1  failed');
     END;

     l_sql_stmt := 'TRUNCATE TABLE MSC_TEMP_SUMM_RES';

     BEGIN
         msc_util.msc_log('Tuncate Table MSC_TEMP_SUMM_RES');
         ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.truncate_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_RES');
     EXCEPTION
         WHEN OTHERS THEN
              msc_util.msc_log(sqlerrm);
              msc_util.msc_log('Truncate table  MSC_TEMP_SUMM_RES failed');
     END;

     l_sql_stmt := 'DROP INDEX MSC_TEMP_SUMM_RES_N1';

     BEGIN
         msc_util.msc_log('Drop Index MSC_TEMP_SUMM_RES_N1');
         ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.drop_index,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_TEMP_SUMM_RES_N1');
     EXCEPTION
         WHEN OTHERS THEN
              msc_util.msc_log(sqlerrm);
              msc_util.msc_log('Drop Index MSC_TEMP_SUMM_RES_N1  failed');
     END;
END Clean_Plan_Tables;


PROCEDURE LOAD_NET_SO (
                       ERRBUF          OUT     NoCopy VARCHAR2,
        	       RETCODE         OUT     NoCopy NUMBER,
                       P_INSTANCE_ID   IN      NUMBER
                       )
IS
        TYPE number_arr IS TABLE OF NUMBER;
	l_inv_ctp                   NUMBER;
        l_sd_date                   date;
        l_sd_qty                    NUMBER;
        l_refresh_number            NUMBER;
        l_organization_id           NUMBER;
        l_old_sd_date               DATE;
        l_old_sd_qty                NUMBER;
        l_demand_class              varchar2(30);
        l_inventory_item_id         number;
        l_instance_id               number;
        l_default_atp_rule_id       NUMBER;
        l_sysdate_seq_num           NUMBER;
        l_calendar_code             VARCHAR2(20);
        l_default_demand_class      VARCHAR2(10);
        l_calendar_exception_set_id NUMBER;
        l_summary_flag		    NUMBER;

        l_org_ids                       number_arr;
        l_enable_summary_mode      VARCHAR2(1);
        l_sysdate                  date;
        l_user_id                  number;

        l_org_code                 VARCHAR2(7);
        l_sys_next_date            date;
        -- rajjain 12/20/2002
        l_spid                          VARCHAR2(12);
        l_apps_lrn			NUMBER; --Bug3049003
        l_reserved_quantity             Number;
        l_reservation_date                 date;
        l_refresh_number1               number;
        l_count                         number :=0;
 -- new records cursor

CURSOR NET_CHANGE_SO_NEW (l_refresh_number            number,
                          l_instance_id               number,
                          l_organization_id           NUMBER,
                          l_calendar_code             VARCHAR2,
                          l_calendar_exception_set_id NUMBER) IS
           SELECT  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') demand_class ,
                   ---bug 2287148: move reservations to  sysdate
                   DECODE(D.RESERVATION_TYPE,2,l_sys_next_date,trunc(D.REQUIREMENT_DATE)) SD_DATE,
                   SUM ( (D.PRIMARY_UOM_QUANTITY -
                         GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                          D.COMPLETED_QUANTITY)) ) sd_qty
             FROM
                   MSC_SALES_ORDERS D,
                   MSC_ATP_RULES R,
                   MSC_SYSTEM_ITEMS I
            WHERE  D.SR_INSTANCE_ID = l_instance_id
              AND  I.REFRESH_NUMBER > l_refresh_number -- get all new flag items
              AND  I.ORGANIZATION_ID = l_organization_id
              AND  D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
              AND  D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
              AND  D.ORGANIZATION_ID = I.ORGANIZATION_ID
              AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_DEFAULT_ATP_RULE_ID)
              AND  R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
              AND  D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                                      D.COMPLETED_QUANTITY)
              AND  I.NEW_ATP_FLAG = 'Y' -- New flag to indicate new ATPable item.
              AND  I.plan_id = -1
              AND  ((D.PARENT_DEMAND_ID IS NOT NULL) OR -- new sales order and
                     -- equivalently D.reservation_type = 1
                     -- the demand for which the sales_order has been pegged
                    (D.RESERVATION_TYPE = 2 AND D.DEMAND_SOURCE_LINE IS NOT NULL))
              AND  (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                      (SELECT S.SUB_INVENTORY_CODE
                         FROM MSC_SUB_INVENTORIES S
                        WHERE S.ORGANIZATION_ID=D.ORGANIZATION_ID
                          AND S.PLAN_ID = I.PLAN_ID
                          AND S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                          AND S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                       1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                          AND S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                               2, 1, S.NETTING_TYPE)))
              AND (D.RESERVATION_TYPE = 2
                   OR D.PARENT_DEMAND_ID IS NULL
                   OR (D.RESERVATION_TYPE = 3 AND
                       ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                       (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
              AND  EXISTS
                      (SELECT 1
                         FROM msc_calendar_dates c
                        WHERE C.PRIOR_SEQ_NUM >=
                              DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                               NULL, C.PRIOR_SEQ_NUM,
                               MSC_ATP_FUNC.NEXT_WORK_DAY_SEQNUM
                                   (D.ORGANIZATION_ID, P_INSTANCE_ID, l_sysdate)
                                - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
                          AND C.CALENDAR_CODE = l_CALENDAR_CODE
                          AND C.SR_INSTANCE_ID = p_instance_id
                          AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                          AND C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
                      )
         GROUP BY  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') ,
                   -- rajjain 02/06/2003 Bug 2782882
                   DECODE(D.RESERVATION_TYPE,2,l_sys_next_date,trunc(D.REQUIREMENT_DATE));

   -- reservation type cursor
--bug 5357370,This cursor selects sales order which have unreserved

CURSOR NET_CHANGE_UNRESRV(l_refresh_number              number,
                           l_instance_id               number,
                           l_organization_id           NUMBER
                           ) IS
            SELECT
                   D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') demand_class ,
                   trunc(D.REQUIREMENT_DATE) SD_DATE,
                   sum(d.old_RESERVATION_QUANTITY) sd_qty
            FROM
                   MSC_SALES_ORDERS D,
                   MSC_ATP_RULES R,
                   MSC_SYSTEM_ITEMS I
            WHERE  D.SR_INSTANCE_ID = l_instance_id
              AND  D.REFRESH_NUMBER > l_refresh_number
              AND  I.ORGANIZATION_ID = l_organization_id
              AND  D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
              AND  D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
              AND  D.ORGANIZATION_ID = I.ORGANIZATION_ID
              AND  I.plan_id = -1
              AND  I.ATP_FLAG = 'Y'             -- Get ATP'able items which have
              AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_DEFAULT_ATP_RULE_ID)
              AND  R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
              AND (D.RESERVATION_TYPE=1 and reservation_quantity=0 and old_reservation_quantity <>0)
              AND  D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                                      NVL(D.COMPLETED_QUANTITY,0))
              AND  (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                      (SELECT S.SUB_INVENTORY_CODE
                         FROM MSC_SUB_INVENTORIES S
                        WHERE S.ORGANIZATION_ID=D.ORGANIZATION_ID
                          AND S.PLAN_ID = I.PLAN_ID
                          AND S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                          AND S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                       1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                          AND S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                               2, 1, S.NETTING_TYPE)))
              AND  EXISTS
                      (SELECT 1
                         FROM msc_calendar_dates c
                        WHERE C.PRIOR_SEQ_NUM >=
                              DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                               NULL, C.PRIOR_SEQ_NUM,
                               MSC_ATP_FUNC.NEXT_WORK_DAY_SEQNUM(D.ORGANIZATION_ID,
                               P_INSTANCE_ID,
                               l_sysdate) - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
                          AND C.CALENDAR_CODE = l_CALENDAR_CODE
                          AND C.SR_INSTANCE_ID = p_instance_id
                          AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                          AND C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
                      )
         GROUP BY  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') ,
                   trunc(D.REQUIREMENT_DATE);

--bug 5357370,This cursor selects sales order which have been reserved
--we need these to subtract the quantity from the original date when they were schedules and move to sysdate

CURSOR NET_CHANGE_RESRV (l_refresh_number              number,
                           l_instance_id               number,
                           l_organization_id           NUMBER
                           ) IS
SELECT
            D.organization_id,
            D.inventory_item_id,
            NVL(D.DEMAND_CLASS,'@@@') demand_class ,
            trunc(d.requirement_date) SD_DATE,
            sum(nvl(d.old_primary_uom_quantity, 0) - d.primary_uom_quantity) SD_QTY
                   -- QUESTION ? Does the above SUM actually result in a DELTA??
             FROM
                  msc_sales_orders d
             WHERE
             d.reservation_type =2
             and d.refresh_number > l_refresh_number
             and d.organization_id = l_organization_id
             and d.sr_instance_id =l_instance_id
             GROUP BY
             D.organization_id,
             D.inventory_item_id,
             NVL(D.DEMAND_CLASS,'@@@'),
             trunc(d.requirement_date);


CURSOR NET_CHANGE_SO_RSRV (l_refresh_number            number,
                           l_instance_id               number,
                           l_organization_id           NUMBER,
                           l_calendar_code             VARCHAR2,
                           l_calendar_exception_set_id NUMBER) IS
           SELECT  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') demand_class ,
                   ---bug 2287148: move reservations to  sysdate
                   DECODE(D.RESERVATION_TYPE,2,l_sys_next_date, trunc(D.REQUIREMENT_DATE)) SD_DATE,
                   sum(d.primary_uom_quantity -nvl(d.old_primary_uom_quantity, 0)) sd_qty
                   --SUM ( (D.PRIMARY_UOM_QUANTITY -
                         --GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                            --NVL(D.COMPLETED_QUANTITY,0))) ) sd_qty
                   -- QUESTION ? Does the above SUM actually result in a DELTA??
             FROM
                   MSC_SALES_ORDERS D,
                   MSC_ATP_RULES R,
                   MSC_SYSTEM_ITEMS I
            WHERE  D.SR_INSTANCE_ID = l_instance_id
              AND  D.REFRESH_NUMBER > l_refresh_number
              AND  I.ORGANIZATION_ID = l_organization_id
              AND  D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
              AND  D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
              AND  D.ORGANIZATION_ID = I.ORGANIZATION_ID
              AND  I.plan_id = -1
              AND  I.ATP_FLAG = 'Y'             -- Get ATP'able items which have
              AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_DEFAULT_ATP_RULE_ID)
              AND  R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
              AND  D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                                      NVL(D.COMPLETED_QUANTITY,0))
              --AND  D.DEMAND_SOURCE_LINE is NULL -- new inventory reservations.
              AND  D.RESERVATION_TYPE <> 1      -- Not a Sales Order item.
              AND  (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                      (SELECT S.SUB_INVENTORY_CODE
                         FROM MSC_SUB_INVENTORIES S
                        WHERE S.ORGANIZATION_ID=D.ORGANIZATION_ID
                          AND S.PLAN_ID = I.PLAN_ID
                          AND S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                          AND S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                       1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                          AND S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                               2, 1, S.NETTING_TYPE)))
              AND (D.RESERVATION_TYPE = 2
                   OR D.PARENT_DEMAND_ID IS NULL
                   OR (D.RESERVATION_TYPE = 3 AND
                       ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                       (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
              AND  EXISTS
                      (SELECT 1
                         FROM msc_calendar_dates c
                        WHERE C.PRIOR_SEQ_NUM >=
                              DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                               NULL, C.PRIOR_SEQ_NUM,
                               MSC_ATP_FUNC.NEXT_WORK_DAY_SEQNUM(D.ORGANIZATION_ID,
                               P_INSTANCE_ID,
                               l_sysdate) - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
                          AND C.CALENDAR_CODE = l_CALENDAR_CODE
                          AND C.SR_INSTANCE_ID = p_instance_id
                          AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                          AND C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
                      )
         GROUP BY  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') ,
                   -- rajjain 02/06/2003 Bug 2782882
                   DECODE(D.RESERVATION_TYPE,2,l_sys_next_date, trunc(D.REQUIREMENT_DATE))
         UNION ALL
           SELECT  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') demand_class ,
                   ---bug 2287148: move reservations to  sysdate
                   -- bug 5357370: since reservation_type 1 is only selected when it is shipped,  we need to either use sysdate if we had reservation or use oldrequirement date if we did not have reservation
                   decode(NVL(D.old_reservation_quantity, 0), 0, trunc(nvl(D.old_requirement_date, D.requirement_date)), l_sys_next_date) SD_DATE,
                   -- DECODE(D.RESERVATION_TYPE,2,l_sys_next_date,trunc(D.old_REQUIREMENT_DATE)) SD_DATE,
                   --5125969 In cases of reservation type 1 and some complete qty
                    --we want to substract that from total qty
                   SUM(DECODE(D.RESERVATION_TYPE,1, -1*D.COMPLETED_QUANTITY,
                                                    -1*(NVL(D.old_PRIMARY_UOM_QUANTITY,0) -
                         GREATEST(NVL(D.old_RESERVATION_QUANTITY,0),
                            NVL(D.old_COMPLETED_QUANTITY,0))))) sd_qty
                   -- QUESTION ? Does the above SUM actually result in a DELTA??
                   -- ANSWER : We are subtratcting the sum of the old quantities.
             FROM
                   MSC_SALES_ORDERS D,
                   MSC_ATP_RULES R,
                   MSC_SYSTEM_ITEMS I
            WHERE  D.SR_INSTANCE_ID = l_instance_id
              AND  D.REFRESH_NUMBER > l_refresh_number
              AND  I.ORGANIZATION_ID = l_organization_id
              AND  D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
              AND  D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
              AND  D.ORGANIZATION_ID = I.ORGANIZATION_ID
              AND  I.plan_id = -1
              AND  I.ATP_FLAG = 'Y'             -- Get ATP'able items which have
              AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_DEFAULT_ATP_RULE_ID)
              AND  R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
              AND  D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
              --5125969 Also consider rows where completed_qty is not 0
              AND  (D.OLD_PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.OLD_RESERVATION_QUANTITY,0),
                                      NVL(D.OLD_COMPLETED_QUANTITY,0))
                                      OR ((NVL(D.COMPLETED_QUANTITY,0) <> 0)AND D.OLD_PRIMARY_UOM_QUANTITY-NVL(D.OLD_COMPLETED_QUANTITY,0)>0))
             --5125969 Include reservation type 1 when complete qty is not 0
              AND  ((D.DEMAND_SOURCE_LINE is NULL -- new inventory reservations.
                    AND
                    D.RESERVATION_TYPE <> 1)      -- Not a Sales Order item.
                    OR (D.RESERVATION_TYPE = 1 AND NVL(D.COMPLETED_QUANTITY,0) <> 0))

              AND  (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                      (SELECT S.SUB_INVENTORY_CODE
                         FROM MSC_SUB_INVENTORIES S
                        WHERE S.ORGANIZATION_ID=D.ORGANIZATION_ID
                          AND S.PLAN_ID = I.PLAN_ID
                          AND S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                          AND S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                       1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                          AND S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                               2, 1, S.NETTING_TYPE)))
              AND (D.RESERVATION_TYPE = 2
                   OR D.PARENT_DEMAND_ID IS NULL
                   OR (D.RESERVATION_TYPE = 3 AND
                       ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                       (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
              AND  EXISTS
                      (SELECT 1
                         FROM msc_calendar_dates c
                        WHERE C.PRIOR_SEQ_NUM >=
                              DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                               NULL, C.PRIOR_SEQ_NUM,
                               MSC_ATP_FUNC.NEXT_WORK_DAY_SEQNUM(D.ORGANIZATION_ID,
                               P_INSTANCE_ID,
                               l_sysdate) - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
                          AND C.CALENDAR_CODE = l_CALENDAR_CODE
                          AND C.SR_INSTANCE_ID = p_instance_id
                          AND C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                          AND C.CALENDAR_DATE = TRUNC(D.old_REQUIREMENT_DATE)
                      )
         GROUP BY  D.organization_id,
                   D.inventory_item_id,
                   Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                      NVL(D.DEMAND_CLASS,'@@@'), '@@@') ,
                   -- rajjain 02/06/2003 Bug 2782882
                   decode(NVL(D.old_reservation_quantity, 0), 0, trunc(nvl(D.old_requirement_date, D.requirement_date)), l_sys_next_date);


BEGIN
  -- Bug 3304390 Disable Trace
  -- Deleted Related Code

  l_instance_id := p_instance_id;
  l_sysdate := sysdate;
  l_user_id := FND_GLOBAL.USER_ID;
  l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);
  l_enable_summary_mode := NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N');

  msc_util.msc_log('inv_ctp := ' || l_inv_ctp);
  msc_util.msc_log(' l_enable_summary_mode := ' || l_enable_summary_mode);

  IF l_enable_summary_mode <> 'Y' THEN
       msc_util.msc_log('Summary Mode is not enabled. Please enable Summary mode to run this program');
       RETCODE := G_WARNING;
       RETURN;
  END IF;

  IF l_inv_ctp = 4 THEN
      -- we are not doing ODS ATP so we wont  continue
      msc_util.msc_log('Not Doing ODS ATP. Please check profile - INV: Capable to Promise. Will Exit ');
      RETCODE := G_WARNING;
      RETURN;
  ELSIF l_inv_ctp <> 5 THEN
      l_inv_ctp := 5;
  END IF;

  SELECT NVL(summary_flag, 1), NVL(summary_refresh_number,0),apps_lrn  ---LCID
  INTO   l_summary_flag,l_refresh_number,l_apps_lrn	---bug3049003
  from   msc_apps_instances
  where  instance_id = p_instance_id;

  IF NVL(l_summary_flag, 1) = 2 THEN
     msc_util.msc_log('Another session is running Complete summary for this instance');
     RETCODE := G_ERROR;
     RETURN;
  ELSIF (NVL(l_summary_flag, 1) = 1) THEN
     msc_util.msc_log('Partial summary of tables can be done only after complete summary has been run successfuly');
     RETCODE := G_ERROR;
     RETURN;
  END IF;

  msc_util.msc_log('l_refresh_number := ' || l_refresh_number);

/*  SELECT  sr_tp_id
  BULK  COLLECT INTO l_org_ids
  FROM    msc_trading_partners
  WHERE    sr_instance_id = p_instance_id and partner_type = 3;*/

  SELECT  ORGANIZATION_ID                 ---bug3049003
  BULK  COLLECT INTO l_org_ids
  FROM    msc_instance_orgs
  WHERE   sr_instance_id = p_instance_id
  and     org_lrn=l_apps_lrn
  and     enabled_flag=1;

  msc_util.msc_log(' org count := ' || l_org_ids.count);

  -- Update summary record per organization
  FOR i in 1..l_org_ids.count LOOP
      l_organization_id := l_org_ids(i);
      msc_util.msc_log('processing org '|| i ||' := '||l_organization_id);

      MSC_ATP_PROC.get_org_default_info(p_instance_id,
                                        l_organization_id,
                                        l_default_atp_rule_id,
                                        l_calendar_code,
                                        l_calendar_exception_set_id,
                                        l_default_demand_class,
                                        l_org_code);

      msc_util.msc_log('l_calendar_code := ' || l_calendar_code);
      msc_util.msc_log('l_calendar_exception_set_id := ' || l_calendar_exception_set_id);
      msc_util.msc_log('l_default_atp_rule_id := ' || l_default_atp_rule_id);
      msc_util.msc_log('l_default_demand_class := ' || l_default_demand_class);
      BEGIN
          SELECT  cal.next_date
          INTO    l_sys_next_date
          FROM    msc_calendar_dates  cal
          WHERE   cal.exception_set_id = l_calendar_exception_set_id
          AND     cal.calendar_code = l_calendar_code
          AND     cal.calendar_date = TRUNC(l_sysdate)
          AND     cal.sr_instance_id = p_instance_id ;
      EXCEPTION
          WHEN OTHERS THEN
               null;
      END;

      OPEN  NET_CHANGE_SO_NEW ( l_refresh_number   ,
                                 l_instance_id      ,
                                 l_organization_id  ,
                                 l_calendar_code    ,
                                 l_calendar_exception_set_id );
      msc_util.msc_log('after opening cursor NET_CHANGE_SO_NEW');

      LOOP
           FETCH NET_CHANGE_SO_NEW INTO
                  l_organization_id,
                  l_inventory_item_id,
                  l_demand_class,
                  l_sd_date,
                  l_sd_qty;

           EXIT WHEN NET_CHANGE_SO_NEW%NOTFOUND;

           msc_util.msc_log('l_organization_id := ' || l_organization_id);
           msc_util.msc_log('l_demand_class := ' || l_organization_id);
           msc_util.msc_log('l_sd_date := ' || l_sd_date);
           msc_util.msc_log('l_sd_qty := ' || l_sd_qty);
           msc_util.msc_log('l_old_sd_date := ' || l_old_sd_date);
           msc_util.msc_log('l_old_sd_qty := ' || l_old_sd_qty);
           msc_util.msc_log('l_inventory_item_id := ' || l_inventory_item_id);

           --- With 9i the entire set can be accomplished in one MERGE statement.
           --- Insert the new record
           BEGIN
              INSERT INTO MSC_ATP_SUMMARY_SO
                          (plan_id,
                          sr_instance_id,
                          organization_id,
                          inventory_item_id,
                          demand_class,
                          sd_date,
                          sd_qty,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by)
                  VALUES (-1, p_instance_id, l_organization_id,
                           l_inventory_item_id, l_demand_class, trunc(l_sd_date),
                           l_sd_qty, l_sysdate, l_user_id ,
                           l_sysdate, l_user_id
                         );
              COMMIT;
           EXCEPTION
              -- If a record has already been inserted by another process
              WHEN DUP_VAL_ON_INDEX THEN
                -- Update the record.
                UPDATE MSC_ATP_SUMMARY_SO
                   SET sd_qty = sd_qty + l_sd_qty,   -- The value is now a DELTA
                       last_update_date = l_sysdate,
                       last_updated_by = l_user_id
                 WHERE plan_id = -1
                   AND sr_instance_id = p_instance_id
                   AND organization_id = l_organization_id
                   AND inventory_item_id = l_inventory_item_id
                   AND demand_class = l_demand_class
                   AND trunc(sd_date) = trunc(l_sd_date);

                COMMIT;
           END;

      END LOOP; --- end of fetch loop

      CLOSE NET_CHANGE_SO_NEW;
      msc_util.msc_log('l_refresh_number := ' || l_refresh_number);
      msc_util.msc_log('l_instance_id := ' || l_instance_id);
      msc_util.msc_log('l_organization_id := ' || l_organization_id);

      ----bug 5357370,We will remove the unreserved quantity from sysdate and add the quantity to the schedule date
      OPEN NET_CHANGE_UNRESRV(l_refresh_number   ,
                             l_instance_id     ,
                             l_organization_id
                           ) ;
      msc_util.msc_log('after opening cursor NET_CHANGE_UNRESRV');
      msc_util.msc_log('l_refresh_number := ' || l_refresh_number);
      msc_util.msc_log('l_instance_id := ' || l_instance_id);
      msc_util.msc_log('l_organization_id := ' || l_organization_id);

      LOOP
          FETCH NET_CHANGE_UNRESRV INTO
                 l_organization_id,
                 l_inventory_item_id,
                 l_demand_class,
                 l_sd_date,
                 l_sd_qty;

          EXIT WHEN NET_CHANGE_UNRESRV%NOTFOUND;

          msc_util.msc_log('l_organization_id := ' || l_organization_id);
          msc_util.msc_log('l_demand_class := ' || l_demand_class);
          msc_util.msc_log('l_sd_date := ' || l_sd_date);
          msc_util.msc_log('l_sd_qty := ' || l_sd_qty);
          msc_util.msc_log('l_inventory_item_id := ' || l_inventory_item_id);

         UPDATE MSC_ATP_SUMMARY_SO
              SET sd_qty = sd_qty + l_sd_qty,   -- APPLY THE DELTA
                  last_update_date = l_sysdate,
                  last_updated_by = l_user_id
            WHERE plan_id = -1
              AND sr_instance_id = p_instance_id
              AND organization_id = l_organization_id
              AND inventory_item_id = l_inventory_item_id
              AND demand_class = l_demand_class
              AND trunc(sd_date) = trunc(l_sd_date);
         IF (SQL%NOTFOUND) THEN
           BEGIN
                    INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
                             sr_instance_id,
                             organization_id,
                             inventory_item_id,
                             demand_class,
                             sd_date,
                             sd_qty,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by)
                    VALUES ( -1,
                             p_instance_id,
                             l_organization_id,
                             l_inventory_item_id,
                             l_demand_class,
                             trunc(l_sd_date),
                             l_sd_qty,
                             l_sysdate,
                             l_user_id ,
                             l_sysdate,
                             l_user_id
                           );
                  EXCEPTION

                  -- If a record has already been inserted by another process
                  -- If insert fails then update.
                    WHEN DUP_VAL_ON_INDEX THEN
                      -- Update the record.
                      update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                      set sd_qty = (sd_qty + l_sd_qty),
                          last_update_date = l_sysdate,
                          last_updated_by = l_user_id
                      where inventory_item_id = l_inventory_item_id
                      and sr_instance_id = p_instance_id
                      and organization_id = l_organization_id
                      and sd_date = trunc(l_sd_date)
                      and demand_class = l_demand_class ;

           END;
         END IF;

         UPDATE MSC_ATP_SUMMARY_SO
              SET sd_qty = sd_qty - l_sd_qty,   -- APPLY THE DELTA
                  last_update_date = l_sysdate,
                  last_updated_by = l_user_id
            WHERE plan_id = -1
              AND sr_instance_id = p_instance_id
              AND organization_id = l_organization_id
              AND inventory_item_id = l_inventory_item_id
              AND demand_class = l_demand_class
              AND trunc(sd_date) = trunc(l_sys_next_date);
         IF (SQL%NOTFOUND) THEN
           BEGIN
                    INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
                             sr_instance_id,
                             organization_id,
                             inventory_item_id,
                             demand_class,
                             sd_date,
                             sd_qty,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by)
                    VALUES ( -1,
                             p_instance_id,
                             l_organization_id,
                             l_inventory_item_id,
                             l_demand_class,
                             trunc(l_sys_next_date),
                             - l_sd_qty,
                             l_sysdate,
                             l_user_id ,
                             l_sysdate,
                             l_user_id
                           );
                  EXCEPTION

                  -- If a record has already been inserted by another process
                  -- If insert fails then update.
                    WHEN DUP_VAL_ON_INDEX THEN
                      -- Update the record.
                      update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                      set sd_qty = (sd_qty - l_sd_qty),
                          last_update_date = l_sysdate,
                          last_updated_by = l_user_id
                      where inventory_item_id = l_inventory_item_id
                      and sr_instance_id = p_instance_id
                      and organization_id = l_organization_id
                      and sd_date = trunc(l_sys_next_date)
                      and demand_class = l_demand_class ;

           END;
         END IF;
         commit;
      END LOOP; --- end of fetch loop

      CLOSE NET_CHANGE_UNRESRV;

      ----bug 5357370,Remove the Reservation records from the date they were originally scheduled.
      OPEN NET_CHANGE_RESRV(l_refresh_number   ,
                             l_instance_id     ,
                             l_organization_id
                           ) ;

      msc_util.msc_log('after opening cursor NET_CHANGE_RESRV');
      msc_util.msc_log('l_refresh_number := ' || l_refresh_number);
      msc_util.msc_log('l_instance_id := ' || l_instance_id);
      msc_util.msc_log('l_organization_id := ' || l_organization_id);

      LOOP
          FETCH NET_CHANGE_RESRV INTO
                 l_organization_id,
                 l_inventory_item_id,
                 l_demand_class,
                 l_sd_date,
                 l_sd_qty;

          EXIT WHEN NET_CHANGE_RESRV%NOTFOUND;

          msc_util.msc_log('l_organization_id := ' || l_organization_id);
          msc_util.msc_log('l_demand_class := ' || l_demand_class);
          msc_util.msc_log('l_sd_date := ' || l_sd_date);
          msc_util.msc_log('l_sd_qty := ' || l_sd_qty);
          msc_util.msc_log('l_inventory_item_id := ' || l_inventory_item_id);

         UPDATE MSC_ATP_SUMMARY_SO
              SET sd_qty = sd_qty + l_sd_qty,   -- APPLY THE DELTA
                  last_update_date = l_sysdate,
                  last_updated_by = l_user_id
            WHERE plan_id = -1
              AND sr_instance_id = p_instance_id
              AND organization_id = l_organization_id
              AND inventory_item_id = l_inventory_item_id
              AND demand_class = l_demand_class
              AND trunc(sd_date) = trunc(l_sd_date);
         IF (SQL%NOTFOUND) THEN
           BEGIN
                    INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
                             sr_instance_id,
                             organization_id,
                             inventory_item_id,
                             demand_class,
                             sd_date,
                             sd_qty,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by)
                    VALUES ( -1,
                             p_instance_id,
                             l_organization_id,
                             l_inventory_item_id,
                             l_demand_class,
                             trunc(l_sd_date),
                             l_sd_qty,
                             l_sysdate,
                             l_user_id ,
                             l_sysdate,
                             l_user_id
                           );
                  EXCEPTION

                  -- If a record has already been inserted by another process
                  -- If insert fails then update.
                    WHEN DUP_VAL_ON_INDEX THEN
                      -- Update the record.
                      update /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ msc_atp_summary_so
                      set sd_qty = (sd_qty + l_sd_qty),
                          last_update_date = l_sysdate,
                          last_updated_by = l_user_id
                      where inventory_item_id = l_inventory_item_id
                      and sr_instance_id = p_instance_id
                      and organization_id = l_organization_id
                      and sd_date = trunc(l_sd_date)
                      and demand_class = l_demand_class ;

           END;
         END IF;
         commit;
      END LOOP; --- end of fetch loop

      CLOSE NET_CHANGE_RESRV;

      OPEN  NET_CHANGE_SO_RSRV ( l_refresh_number,
                                  l_instance_id,
                                  l_organization_id,
                                  l_calendar_code,
                                  l_calendar_exception_set_id );
      msc_util.msc_log('after opening cursor NET_CHANGE_SO_RSRV');
      msc_util.msc_log('l_calendar_code := ' || l_calendar_code);
      msc_util.msc_log('l_calendar_exception_set_id := ' ||
                             TO_CHAR(l_calendar_exception_set_id));


      LOOP
          FETCH NET_CHANGE_SO_RSRV INTO
                 l_organization_id,
                 l_inventory_item_id,
                 l_demand_class,
                 l_sd_date,
                 l_sd_qty;

          EXIT WHEN NET_CHANGE_SO_RSRV%NOTFOUND;

          msc_util.msc_log('l_organization_id := ' || l_organization_id);
          msc_util.msc_log('l_demand_class := ' || l_demand_class);
          msc_util.msc_log('l_sd_date := ' || l_sd_date);
          msc_util.msc_log('l_sd_qty := ' || l_sd_qty);
          msc_util.msc_log('l_inventory_item_id := ' || l_inventory_item_id);


           --- With 9i the entire set can be accomplished in one MERGE statement.
           --- Try to update it first and then

           UPDATE MSC_ATP_SUMMARY_SO
              SET sd_qty = sd_qty + l_sd_qty,   -- APPLY THE DELTA
                  last_update_date = l_sysdate,
                  last_updated_by = l_user_id
            WHERE plan_id = -1
              AND sr_instance_id = p_instance_id
              AND organization_id = l_organization_id
              AND inventory_item_id = l_inventory_item_id
              AND demand_class = l_demand_class
              AND trunc(sd_date) = trunc(l_sd_date);
           --COMMIT; 5078448


             --- if not found insert it.
           IF (SQL%NOTFOUND) THEN
             --- Insert the new record
             BEGIN
                INSERT INTO MSC_ATP_SUMMARY_SO
                            (plan_id,
                             sr_instance_id,
                             organization_id,
                             inventory_item_id,
                             demand_class,
                             sd_date,
                             sd_qty,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by)
                    VALUES (-1, p_instance_id, l_organization_id,
                             l_inventory_item_id, l_demand_class, trunc(l_sd_date),
                             l_sd_qty, l_sysdate, l_user_id ,
                             l_sysdate, l_user_id
                           );
                --COMMIT; 5078448
             EXCEPTION
               -- If a record has already been inserted by another process
               -- If insert fails then update.
               WHEN DUP_VAL_ON_INDEX THEN
                 -- Update the record.
                 UPDATE MSC_ATP_SUMMARY_SO
                    SET sd_qty = sd_qty + l_sd_qty,   -- The value is a DELTA
                        last_update_date = l_sysdate,
                        last_updated_by = l_user_id
                  WHERE plan_id = -1
                    AND sr_instance_id = p_instance_id
                    AND organization_id = l_organization_id
                    AND inventory_item_id = l_inventory_item_id
                    AND demand_class = l_demand_class
                    AND trunc(sd_date) = trunc(l_sd_date);

                --COMMIT; 5078448
             END;
           END IF;
           COMMIT; --5078448

      END LOOP; --- end of fetch loop

      CLOSE NET_CHANGE_SO_RSRV;

   END LOOP;

   -- Take care of OUT parameters
   ERRBUF  := null;
   RETCODE := G_SUCCESS;

   EXCEPTION
      WHEN OTHERS THEN
          IF (NET_CHANGE_SO_RSRV%ISOPEN) THEN
             CLOSE NET_CHANGE_SO_RSRV;
          END IF;
          IF (NET_CHANGE_SO_NEW%ISOPEN) THEN
             CLOSE NET_CHANGE_SO_NEW;
          END IF;
          --- update summary flag in msc_apps_instances so that summary not available to use
          update msc_apps_instances
          set summary_flag = 1
          where instance_id = p_instance_id;
          msc_util.msc_log('An error  occured while running net change on Sales Orders');
          msc_util.msc_log('Complete refresh would need to be run to activate Summary ATP');
          msc_util.msc_log('Inside main exception');
          msc_util.msc_log(sqlerrm);
          ERRBUF := sqlerrm;
          RETCODE := G_ERROR;
END LOAD_NET_SO;


PROCEDURE LOAD_NET_SD (
                       ERRBUF          OUT     NoCopy VARCHAR2,
        	       RETCODE         OUT     NoCopy NUMBER,
                       P_INSTANCE_ID   IN      NUMBER
                       )
IS
    TYPE number_arr IS TABLE OF NUMBER;
    l_organization_id               NUMBER;
    l_default_atp_rule_id           NUMBER;
    l_sysdate_seq_num               NUMBER;
    l_calendar_code                 VARCHAR2(20);
    l_default_demand_class          VARCHAR2(10);
    l_calendar_exception_set_id     NUMBER;
    l_org_ids                       number_arr;
    l_refresh_number                NUMBER;
    l_sd_date                       DATE;
    l_sd_qty                        NUMBER;
    l_inventory_item_id             NUMBER;
    l_demand_class                  varchar(30);
    l_inv_ctp                       number;
    l_summary_flag		    number;
    l_enable_summary_mode           varchar2(1);
    l_sysdate                       date;
    l_user_id                       number;

    l_org_code                      VARCHAR2(7);

    -- rajjain 12/20/2002
    l_spid                          VARCHAR2(12);
    l_apps_lrn			    NUMBER; --Bug3049003

-- Cursor is defined such that the four way union actually returns a DELTA (SUPPLY - DEMAND)

CURSOR c_net_supply_demand (l_refresh_number                NUMBER,
                            p_instance_id                   NUMBER,
                            l_organization_id               NUMBER,
                            l_default_atp_rule_id           NUMBER,
                            l_sysdate_seq_num               NUMBER,
                            l_calendar_code                 VARCHAR2,
                            l_default_demand_class          VARCHAR2,
                            l_calendar_exception_set_id     NUMBER
                           ) IS
   SELECT inventory_item_id, demand_class, SD_DATE, sum(sd_qty) SD_QTY
   FROM
   ((SELECT
           --- bug 2162571: Use Pf's id if doing PF based ATP
           DECODE(I2.ATP_FLAG, 'Y', I2.INVENTORY_ITEM_ID,
                                                    I.INVENTORY_ITEM_ID) inventory_item_id,
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,  NVL(D.DEMAND_CLASS,
                 NVL(l_default_demand_class,'@@@')), '@@@') demand_class,
           C.PRIOR_DATE SD_DATE,
           -1* D.USING_REQUIREMENT_QUANTITY SD_QTY
                     --2 SD_TYPE
     FROM  MSC_CALENDAR_DATES C,
           MSC_DEMANDS D,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           MSC_SYSTEM_ITEMS I2
    WHERE  I.ATP_FLAG = 'Y'    --- I.SR_INVENTORY_ITEM_ID = p_inventory_item_id
      AND  I.ORGANIZATION_ID = l_organization_id
      AND  I.SR_INSTANCE_ID = p_instance_id
      AND  I.PLAN_ID = -1
      --- bug 2162571
      AND     I.PLAN_ID = I2.PLAN_ID
      AND     I.ORGANIZATION_ID = I2.ORGANIZATION_ID
      AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
      AND     I2.INVENTORY_ITEM_ID = NVL(I.PRODUCT_FAMILY_ID, I.INVENTORY_ITEM_ID)
      AND  D.REFRESH_NUMBER > l_refresh_number
      AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_default_atp_rule_id)
      AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
      AND     D.PLAN_ID = I.PLAN_ID
      AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
      AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
      AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
                   -- 1243985
      AND     USING_REQUIREMENT_QUANTITY <> 0
      AND     D.ORIGINATION_TYPE in (
              DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
              DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
              DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
              DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
              DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
                                 -- Bug 1530311, forecast to be excluded
      AND     C.CALENDAR_CODE = l_calendar_code
      AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
      AND     C.SR_INSTANCE_ID = p_instance_id
               -- since we store repetitive schedule demand in different ways for
               -- ods (total quantity on start date) and pds  (daily quantity from
               -- start date to end date), we need to make sure we only
               -- select work day for pds's repetitive schedule demand.
      AND     C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                         TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                         D.USING_ASSEMBLY_DEMAND_DATE))
      AND     C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE ,
                        NULL, C.PRIOR_SEQ_NUM,
                        l_sysdate_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
   )
   UNION ALL    -- with old demand information
   (SELECT
           --- bug 2162571
           --I.inventory_item_id,
           DECODE(I2.ATP_FLAG, 'Y', I2.INVENTORY_ITEM_ID,
                                                    I.INVENTORY_ITEM_ID) inventory_item_id,
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,  NVL(D.DEMAND_CLASS,
                 NVL(l_default_demand_class,'@@@')), '@@@') demand_class,
           C.PRIOR_DATE SD_DATE,
           NVL(D.OLD_USING_REQUIREMENT_QUANTITY,0) SD_QTY
                     --2 SD_TYPE
     FROM  MSC_CALENDAR_DATES C,
           MSC_DEMANDS D,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           MSC_SYSTEM_ITEMS I2
    WHERE  I.ATP_FLAG = 'Y'    --- I.SR_INVENTORY_ITEM_ID = p_inventory_item_id
      AND  I.ORGANIZATION_ID = l_organization_id
      AND  I.SR_INSTANCE_ID = p_instance_id
      AND  I.PLAN_ID = -1
      --- bug 2162571
      AND     I.PLAN_ID = I2.PLAN_ID
      AND     I.ORGANIZATION_ID = I2.ORGANIZATION_ID
      AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
      AND     I2.INVENTORY_ITEM_ID = NVL(I.PRODUCT_FAMILY_ID, I.INVENTORY_ITEM_ID)

      AND  D.REFRESH_NUMBER > l_refresh_number
      AND  R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_default_atp_rule_id)
      AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
      AND     D.PLAN_ID = I.PLAN_ID
      AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
      AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
      AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
                   -- 1243985
      AND     NVL(D.OLD_USING_REQUIREMENT_QUANTITY,0) <> 0
      AND     D.ORIGINATION_TYPE in (
              DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
              DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
              DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
              DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
              DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
                                 -- Bug 1530311, forecast to be excluded
      AND     C.CALENDAR_CODE = l_calendar_code
      AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
      AND     C.SR_INSTANCE_ID = p_instance_id
               -- since we store repetitive schedule demand in different ways for
               -- ods (total quantity on start date) and pds  (daily quantity from
               -- start date to end date), we need to make sure we only
               -- select work day for pds's repetitive schedule demand.
      AND     C.CALENDAR_DATE BETWEEN TRUNC(D.OLD_USING_ASSEMBLY_DEMAND_DATE) AND
                         TRUNC(NVL(D.OLD_ASSEMBLY_DEMAND_COMP_DATE,
                         D.OLD_USING_ASSEMBLY_DEMAND_DATE))
      AND     C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE ,
                        NULL, C.PRIOR_SEQ_NUM,
                        l_sysdate_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
   )
   UNION ALL  -- new supplies information
   (SELECT /*+ ordered index(C,MSC_CALENDAR_DATES_U1) */I.inventory_item_id, -- 5098576/5199686
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                   NVL(DECODE(S.ORDER_TYPE,
                   5, MSC_ATP_FUNC.Get_MPS_Demand_Class(S.SCHEDULE_DESIGNATOR_ID),
                   S.DEMAND_CLASS), NVL(l_default_demand_class, '@@@')), '@@@'),
           C.NEXT_DATE SD_DATE,
           --- bug 1843471, 2619493
           Decode(order_type, -- 2859130 remove trunc
            30, Decode(Sign(S.Daily_rate * (C.Calendar_date -
                TRUNC(S.FIRST_UNIT_START_DATE))- S.qty_completed),
                -1,S.Daily_rate* (C.Calendar_date - TRUNC(S.First_Unit_Start_date) +1) -
                 S.qty_completed, S.Daily_rate),
                 NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) ) SD_QTY
           -- Changed the order of the tables for 5098576/5199686
     FROM    MSC_SYSTEM_ITEMS I,
             MSC_SYSTEM_ITEMS I2,
             MSC_SUPPLIES S,
             MSC_ATP_RULES R,
             MSC_SUB_INVENTORIES MSI,
             MSC_CALENDAR_DATES C

/*   FROM    MSC_CALENDAR_DATES C,
           MSC_SUPPLIES S,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           --- bug 2162571 add to another table to get info about product family
           MSC_SYSTEM_ITEMS I2,
           MSC_SUB_INVENTORIES MSI*/ -- commented for 5098576/5199686
   WHERE   I.ATP_FLAG = 'Y'   ---I.SR_INVENTORY_ITEM_ID = p_inventory_item_id
   AND     I.ORGANIZATION_ID = l_organization_id
   AND     I.SR_INSTANCE_ID = p_instance_id
   AND     I.PLAN_ID = -1
   AND     I.PLAN_ID = I2.PLAN_ID
   --- bug 2162571: add system items tables to itself to filter out supplies of
   --  product family members if we are doing PF based atp on the member
   -- the logic is:1. If it is a regular member then we consider supplies ond demand of that itme
   -- 2. If we do product family with config PF --> A then
   --              a. If atp flag on PF is yes then we consider supplies of PF and demand of A
   --              b. If atp flag on PF in 'N' then we consider supplies and demands of A
   AND     I.ORGANIZATION_ID = I2.ORGANIZATION_ID
   AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
   AND     NVL(I.PRODUCT_FAMILY_ID, I.INVENTORY_ITEM_ID) = I2.INVENTORY_ITEM_ID
   ---     in case of PF, if atp_flag on PF is yes then we want to filter out supplies of A
   --      For A, the following condition will be true only if ATP_FLAG on PF is 'N'
   ---     and therefore we will consider supplies of A. If atp_flag on PF is 'Y"
   --     then following condition will be false and we will omit supplies of A
   AND     DECODE(I.PRODUCT_FAMILY_ID, NULL, 'N', I2.ATP_FLAG ) = 'N'
   AND  S.REFRESH_NUMBER > l_refresh_number
   AND     R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_default_atp_rule_id)
   AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
   AND     S.PLAN_ID = I.PLAN_ID
   AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
   AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
   AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
                   ---bug 1843471, 2619493
   AND     Decode(S.order_type, 30, S.Daily_rate* (C.Calendar_date -- 2859130 remove trunc
              - TRUNC(S.First_Unit_Start_date) + 1),
                NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) >
           Decode(S.order_type, 30, S.qty_completed,0)
   AND     (S.ORDER_TYPE IN (
                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), --1882898
                   DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
                   DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1) ,
                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
                   DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
                   DECODE(R.INCLUDE_INTERNAL_REQS, 1, 2, -1),
                   DECODE(R.INCLUDE_SUPPLIER_REQS, 1, 2, -1),
                   DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1) ,
                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
            OR ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                   S.ORDER_TYPE = 5
                 AND exists (SELECT '1'
                               FROM   MSC_DESIGNATORS
                              WHERE   INVENTORY_ATP_FLAG = 1
                                AND   DESIGNATOR_TYPE = 2
                                AND   DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID)))
   AND   C.CALENDAR_CODE = l_calendar_code
   AND   C.EXCEPTION_SET_ID = l_calendar_exception_set_id
   AND   C.SR_INSTANCE_ID = p_instance_id
   AND   C.CALENDAR_DATE BETWEEN
              TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
           AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                  NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
   AND   DECODE(S.LAST_UNIT_COMPLETION_DATE,
                    NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
   AND   C.NEXT_SEQ_NUM >= DECODE(S.ORDER_TYPE, 18, C.NEXT_SEQ_NUM,
              DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                NULL, C.NEXT_SEQ_NUM, l_sysdate_seq_num -
                      NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
   AND   C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(l_sysdate),
                                         28, TRUNC(l_sysdate),
                                         C.NEXT_DATE)
                 --- filter out non-atpable sub-inventories
   AND     MSI.plan_id (+) =  -1
   AND     MSI.organization_id (+) = l_organization_id
   AND     MSI.sr_instance_id (+) =  p_instance_id
   AND     MSI.sub_inventory_code (+) = S.subinventory_code
   AND     NVL(MSI.inventory_atp_code,1) <> 2
                             -- filter out non-atpable subinventories
   )
   UNION ALL    -- with old supplies information
   (SELECT /*+ ordered index(C,MSC_CALENDAR_DATES_U1) */I.inventory_item_id, -- 5098576/5199686
           Decode(NVL(R.DEMAND_CLASS_ATP_FLAG,0),1 ,
                   NVL(DECODE(S.ORDER_TYPE,
                   5, MSC_ATP_FUNC.Get_MPS_Demand_Class(S.SCHEDULE_DESIGNATOR_ID),
                   S.DEMAND_CLASS), NVL(l_default_demand_class, '@@@')), '@@@'),
           C.NEXT_DATE SD_DATE,
           --- bug 1843471, 2619493
           -- 2859130 remove trunc on calendar_date
           -1 * Decode(order_type,
               30, Decode(Sign(NVL(S.OLD_Daily_rate,0) * (C.Calendar_date -
                      TRUNC(S.OLD_FIRST_UNIT_START_DATE))- NVL(S.OLD_qty_completed,0)),
                          -1,NVL(S.OLD_Daily_rate,0)* (C.Calendar_date -
                                              TRUNC(S.OLD_First_Unit_Start_date) +1) -
                          NVL(S.OLD_qty_completed,0), NVL(S.OLD_Daily_rate,0)),
             NVL( NVL(S.OLD_FIRM_QUANTITY,S.OLD_NEW_ORDER_QUANTITY),0) ) SD_QTY

      /*FROM    MSC_CALENDAR_DATES C,
           MSC_SUPPLIES S,
           MSC_ATP_RULES R,
           MSC_SYSTEM_ITEMS I,
           MSC_SYSTEM_ITEMS I2,
           MSC_SUB_INVENTORIES MSI*/
     -- Commented 5098576./5199686
     -- changed order of tables for 5098576/5199686
      FROM    MSC_SYSTEM_ITEMS I,
             MSC_SYSTEM_ITEMS I2,
             MSC_SUPPLIES S,
             MSC_ATP_RULES R,
             MSC_SUB_INVENTORIES MSI,
             MSC_CALENDAR_DATES C

   WHERE   I.ATP_FLAG = 'Y'
   AND     I.ORGANIZATION_ID = l_organization_id
   AND     I.SR_INSTANCE_ID = p_instance_id
   AND     I.PLAN_ID = -1
   AND     I.PLAN_ID = I2.PLAN_ID
   --- bug 2162571: add system items tables to itself to filter out supplies of
   --  product family members if we are doing PF based atp on the member
   -- the logic is:1. If it is a regular member then we consider supplies ond demand of that itme
   -- 2. If we do product family with config PF --> A then
   --              a. If atp flag on PF is yes then we consider supplies of PF and demand of A
   --              b. If atp flag on PF in 'N' then we consider supplies and demands of A
   AND     I.ORGANIZATION_ID = I2.ORGANIZATION_ID
   AND     I.SR_INSTANCE_ID = I2.SR_INSTANCE_ID
   AND     NVL(I.PRODUCT_FAMILY_ID, I.INVENTORY_ITEM_ID) = I2.INVENTORY_ITEM_ID
   ---     in case of PF, if atp_flag on PF is yes then we want to filter out supplies of A
   --      For A, the following condition will be true only if ATP_FLAG on PF is 'N'
   ---     and therefore we will consider supplies of A. If atp_flag on PF is 'Y"
   --     then following condition will be false and we will omit supplies of A
   AND     DECODE(I.PRODUCT_FAMILY_ID, NULL, 'N', I2.ATP_FLAG ) = 'N'
   AND     S.REFRESH_NUMBER > l_refresh_number
   AND     R.RULE_ID (+) = NVL(I.ATP_RULE_ID, l_default_atp_rule_id)
   AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
   AND     S.PLAN_ID = I.PLAN_ID
   AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
   AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
   AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
                   ---bug 1843471, 2619493
           -- 2859130 remove trunc
   AND     Decode(S.order_type, 30, NVL(S.OLD_Daily_rate,0)* (C.Calendar_date
              - TRUNC(S.OLD_First_Unit_Start_date) + 1),
                NVL(NVL(S.OLD_FIRM_QUANTITY,S.OLD_NEW_ORDER_QUANTITY),0) ) >
           Decode(S.order_type, 30, NVL(S.OLD_qty_completed,0),0)
   AND     (S.ORDER_TYPE IN (
                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
                   DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), --1882898
                   DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
                   DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
                   DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1) ,
                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                   DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
                   DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
                   DECODE(R.INCLUDE_INTERNAL_REQS, 1, 2, -1),
                   DECODE(R.INCLUDE_SUPPLIER_REQS, 1, 2, -1),
                   DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1) ,
                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
                   DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
            OR ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                   S.ORDER_TYPE = 5
                 AND exists (SELECT '1'
                               FROM   MSC_DESIGNATORS
                              WHERE   INVENTORY_ATP_FLAG = 1
                                AND   DESIGNATOR_TYPE = 2
                                AND   DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID)))
   AND   C.CALENDAR_CODE = l_calendar_code
   AND   C.EXCEPTION_SET_ID = l_calendar_exception_set_id
   AND   C.SR_INSTANCE_ID = p_instance_id
   AND   C.CALENDAR_DATE BETWEEN
              TRUNC(NVL(S.OLD_FIRM_DATE,S.OLD_NEW_SCHEDULE_DATE))
           AND TRUNC(NVL(S.OLD_LAST_UNIT_COMPLETION_DATE,
                  NVL(S.OLD_FIRM_DATE,S.OLD_NEW_SCHEDULE_DATE)))
   AND   DECODE(S.OLD_LAST_UNIT_COMPLETION_DATE,
                    NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
   AND   C.NEXT_SEQ_NUM >= DECODE(S.ORDER_TYPE, 18, C.NEXT_SEQ_NUM,
              DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                NULL, C.NEXT_SEQ_NUM, l_sysdate_seq_num -
                      NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
   AND   C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(l_sysdate),
                                         28, TRUNC(l_sysdate),
                                         C.NEXT_DATE)
                 --- filter out non-atpable sub-inventories
   AND     MSI.plan_id (+) =  -1
   AND     MSI.organization_id (+) = l_organization_id
   AND     MSI.sr_instance_id (+) =  p_instance_id
   AND     MSI.sub_inventory_code (+) = S.subinventory_code
   AND     NVL(MSI.inventory_atp_code,1) <> 2
                             -- filter out non-atpable subinventories
   )
  )
  GROUP BY inventory_item_id, demand_class, sd_date ;

BEGIN
   -- Bug 3304390 Disable Trace
   -- Deleted Related Code.

   ---- select org ids for the instance as we are going to do the summary per organization

   l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);
   l_sysdate := sysdate;
   l_user_id := FND_GLOBAL.USER_ID;
   l_enable_summary_mode := NVL(FND_PROFILE.value('MSC_ENABLE_ATP_SUMMARY'), 'N');

   msc_util.msc_log('inv_ctp := ' || l_inv_ctp);
   msc_util.msc_log('l_enable_summary_mode := ' || l_enable_summary_mode);

   IF l_enable_summary_mode <> 'Y' THEN
       msc_util.msc_log('Summary Mode is not enabled. Please enable Summary mode to run this program');
       RETCODE := G_WARNING;
       RETURN;
   END IF;

   IF l_inv_ctp <> 5 THEN
       -- we are not doing ODS ATP so we wont  continue
       msc_util.msc_log('Not Doing ODS ATP. Will Exit ');
       RETCODE := G_WARNING;
       RETURN;
   END IF;

/*   SELECT NVL(summary_flag, 1), NVL(summary_refresh_number,0) ---LCID
   INTO   l_summary_flag, l_refresh_number
   from   msc_apps_instances
   where  instance_id = p_instance_id;*/

  SELECT NVL(summary_flag, 1), NVL(summary_refresh_number,0),apps_lrn  ---LCID
  INTO   l_summary_flag,l_refresh_number,l_apps_lrn		---bug3049003
  from   msc_apps_instances
  where  instance_id = p_instance_id;

   msc_util.msc_log('l_refresh_number := ' || l_refresh_number);

   IF l_summary_flag = 2 THEN
       msc_util.msc_log('Another session is running full summary for this instance');
       RETCODE := G_ERROR;
       RETURN;
   ELSIF (NVL(l_summary_flag, 0) = 2 ) THEN
      msc_util.msc_log('Partial summary of tables can be done only after complete summary has been run successfuly');
      RETCODE := G_ERROR;
      RETURN;
   END IF;

   /*SELECT  sr_tp_id
     BULK  COLLECT INTO l_org_ids
     FROM  msc_trading_partners
    WHERE  sr_instance_id = p_instance_id and partner_type = 3;*/


  SELECT  ORGANIZATION_ID                 ---bug3049003
  BULK  COLLECT INTO l_org_ids
  FROM    msc_instance_orgs
  WHERE   sr_instance_id = p_instance_id
  and     org_lrn=l_apps_lrn
  and     enabled_flag=1;

   msc_util.msc_log(' org count := ' || l_org_ids.count);

   -- Update summary record per organization
   FOR i in 1..l_org_ids.count LOOP
       l_organization_id := l_org_ids(i);
       msc_util.msc_log('processing org '|| i ||' := '||l_organization_id);

       MSC_ATP_PROC.get_org_default_info ( p_instance_id,
                                           l_organization_id,
                                           l_default_atp_rule_id,
                                           l_calendar_code,
                                           l_calendar_exception_set_id,
                                           l_default_demand_class,
                                           l_org_code);

       msc_util.msc_log('l_calendar_code := ' || l_calendar_code);
       msc_util.msc_log('l_calendar_exception_set_id := ' || l_calendar_exception_set_id);
       msc_util.msc_log('l_default_atp_rule_id := ' || l_default_atp_rule_id);
       msc_util.msc_log('l_default_demand_class := ' || l_default_demand_class);

       BEGIN
            SELECT  cal.next_seq_num
              INTO  l_sysdate_seq_num
              FROM  msc_calendar_dates  cal
             WHERE  cal.exception_set_id = l_calendar_exception_set_id
               AND  cal.calendar_code = l_calendar_code
               AND  cal.calendar_date = TRUNC(l_sysdate)
               AND  cal.sr_instance_id = p_instance_id ;
       EXCEPTION
              WHEN OTHERS THEN
                   null;
       END;

       OPEN C_NET_SUPPLY_DEMAND (l_refresh_number,
                                 p_instance_id,
                                 l_organization_id,
                                 l_default_atp_rule_id,
                                 l_sysdate_seq_num,
                                 l_calendar_code,
                                 l_default_demand_class,
                                 l_calendar_exception_set_id);

       msc_util.msc_log('after opening cursor C_NET_SUPPLY_DEMAND');

       LOOP
          FETCH C_NET_SUPPLY_DEMAND INTO
                l_inventory_item_id,
                l_demand_class,
                l_sd_date,
                l_sd_qty;

          EXIT WHEN  C_NET_SUPPLY_DEMAND%NOTFOUND;

          msc_util.msc_log('l_demand_class := ' || l_demand_class);
          msc_util.msc_log('l_sd_date := ' || l_sd_date);
          msc_util.msc_log('l_sd_qty := ' || l_sd_qty);
          msc_util.msc_log('l_inventory_item_id := ' || l_inventory_item_id);

          --- With 9i the entire set can be accomplished in one MERGE statement.
          --- Try to update record first and then
          UPDATE  MSC_ATP_SUMMARY_SD
             SET  sd_qty = sd_qty + l_sd_qty,   -- APPLY THE DELTA
                  last_update_date = l_sysdate,
                  last_updated_by = l_user_id
           WHERE  plan_id = -1
             AND  sr_instance_id = p_instance_id
             AND  organization_id = l_organization_id
             AND  inventory_item_id = l_inventory_item_id
             AND  demand_class = l_demand_class
             AND  trunc(sd_date) = trunc(l_sd_date);
          --COMMIT; 5078448

              --- if not found insert it.
          IF (SQL%NOTFOUND) THEN
            --- Insert the new record
            BEGIN
              INSERT INTO MSC_ATP_SUMMARY_SD
                          (plan_id,
                           sr_instance_id,
                           organization_id,
                           inventory_item_id,
                           demand_class,
                           sd_date,
                           sd_qty,
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by)
                  VALUES (-1, p_instance_id, l_organization_id,
                           l_inventory_item_id, l_demand_class, trunc(l_sd_date),
                           l_sd_qty, l_sysdate, l_user_id ,
                           l_sysdate, l_user_id
                         );
              --COMMIT; 5078448
            EXCEPTION
              -- If a record has already been inserted by another process
              -- If insert fails then update.
               WHEN DUP_VAL_ON_INDEX THEN
                 -- Update the record.
                 UPDATE MSC_ATP_SUMMARY_SD
                    SET sd_qty = sd_qty + l_sd_qty,   -- The value is a DELTA
                        last_update_date = l_sysdate,
                        last_updated_by = l_user_id
                  WHERE plan_id = -1
                    AND sr_instance_id = p_instance_id
                    AND organization_id = l_organization_id
                    AND inventory_item_id = l_inventory_item_id
                    AND demand_class = l_demand_class
                    AND trunc(sd_date) = trunc(l_sd_date);

                --COMMIT; 5078448
            END;
          END IF;
          COMMIT; --5078448

       END LOOP;

       CLOSE C_NET_SUPPLY_DEMAND;

   END LOOP;

   -- TAke care of OUT parameters
   ERRBUF  := null;
   RETCODE := G_SUCCESS;

   EXCEPTION
        WHEN OTHERS THEN

            IF (C_NET_SUPPLY_DEMAND%ISOPEN) THEN
               CLOSE C_NET_SUPPLY_DEMAND;
            END IF;
            --- update summary flag in msc_apps_instances so that summary not available to use
            update msc_apps_instances
            set summary_flag = 1
            where instance_id = p_instance_id;
            msc_util.msc_log('An error  occured while running net change on Sales Orders');
            msc_util.msc_log('Complete refresh would need to be run to activate Summary ATP');

            msc_util.msc_log('Inside main exception');
            msc_util.msc_log(sqlerrm);
            ERRBUF := sqlerrm;
            RETCODE := G_ERROR;

END LOAD_NET_SD;


PROCEDURE CREATE_PLAN_PARTITIONS( p_plan_id         IN   NUMBER,
                                 p_applsys_schema   IN   VARCHAR2,
                                 p_share_partition IN   VARCHAR2,
                                 p_owner	   IN   VARCHAR2,
                                 p_ret_code        OUT  NoCopy NUMBER,
                                 p_err_msg         OUT  NoCopy VARCHAR2)
AS
atp_summ_tab MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                        'ATP_SUMMARY_SD',
                                        'ATP_SUMMARY_RES',
                                        'ATP_SUMMARY_SUP');
i                 NUMBER;
l_partition_name  VARCHAR2(30);
l_name  	  VARCHAR2(30);
l_split_partition VARCHAR2(30);
l_summary_flag    varchar2(30);
l_plan_id         number;
l_higher_plan     number;
l_sql_stmt        varchar2(1000);
l_table_name      varchar2(30);

CURSOR C_PLAN IS
SELECT	plan_id
FROM	msc_plans
WHERE	plan_id > p_plan_id
AND	NVL(SUMMARY_FLAG, 0) <> 0
ORDER BY plan_id;

BEGIN
        msc_util.msc_log('p_plan_id := ' || p_plan_id);
        msc_util.msc_log('p_applsys_schema := ' || p_applsys_schema);
        msc_util.msc_log('p_share_partition := ' || p_share_partition);
        msc_util.msc_log('p_owner := ' || p_owner);

        p_ret_code := G_SUCCESS;
        p_err_msg  := null;

	For i in 1..atp_summ_tab.COUNT LOOP

            IF p_share_partition = 'Y' then
                 l_partition_name := atp_summ_tab(i) || '_' || MAXVALUE;
                 l_plan_id := MAXVALUE;
            ELSE
                 l_partition_name := atp_summ_tab(i) || '_' || p_plan_id;
                 l_plan_id := p_plan_id;
            END IF;
            l_table_name := 'MSC_' || atp_summ_tab(i);
            msc_util.msc_log('table := ' || l_table_name);
            msc_util.msc_log('partition_name : '|| l_partition_name);
            BEGIN
               IF p_share_partition = 'Y' then
		  BEGIN
	             SELECT   partition_name
                     INTO     l_name
                     --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                     FROM     all_tab_partitions
                     WHERE    table_name = l_table_name
                     AND      table_owner = p_owner
                     AND      partition_name = l_partition_name;

                     msc_util.msc_log('found partition_name : '|| l_name);
		  EXCEPTION
		     WHEN no_data_found THEN
			l_summary_flag := 0;
			msc_util.msc_log('before create partition_name : '|| l_partition_name);
		  END;
	       ELSE
                  SELECT   NVL(summary_flag, 0)
                  INTO     l_summary_flag
                  FROM     msc_plans
                  WHERE    plan_id = p_plan_id;
	       END IF;

               msc_util.msc_log('summary_flag for plan : '|| p_plan_id || ' : '|| l_summary_flag);

	       IF l_summary_flag <> 0 THEN
                  msc_util.msc_log('found partition for plan_id : '|| p_plan_id);
           	  p_ret_code := G_SUCCESS;
           	  p_err_msg  := null;
		  RETURN;
	       ELSIF l_summary_flag = 0 THEN
                  msc_util.msc_log('l_plan_id:= ' || l_plan_id);

		  OPEN C_PLAN;
		  FETCH C_PLAN INTO l_higher_plan;
                  msc_util.msc_log('l_higher_plan : ' || l_higher_plan);

		     IF C_PLAN%NOTFOUND THEN
                        l_sql_stmt := 'alter table ' || l_table_name || ' add partition '
                              || l_partition_name
                              || ' VALUES LESS THAN ('
                              || to_char(l_plan_id) || ', ' ||to_char(MAXVALUE + 1)
                              || ')';
		     ELSE 		-- IF C_PLAN%NOTFOUND THEN

			l_split_partition := atp_summ_tab(i) || '_' || to_char(l_higher_plan);

                        l_sql_stmt := 'alter table ' || l_table_name || ' split partition '
                              || l_split_partition || ' AT ( -1, ' || to_char(l_plan_id) || ')'
                              || ' INTO ( PARTITION ' || l_partition_name || ','
                              || ' PARTITION ' || l_split_partition || ')';
		     END IF; 	-- C_PLAN%NOTFOUND THEN

                     msc_util.msc_log('l_sql_stmt := ' || l_sql_stmt);
		  CLOSE C_PLAN;

                  ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                            APPLICATION_SHORT_NAME => 'MSC',
                            STATEMENT_TYPE => ad_ddl.alter_table,
                            STATEMENT => l_sql_stmt,
                            OBJECT_NAME => l_table_name);
                  msc_util.msc_log('Create Partition successful');
	       END IF;		-- l_summary_flag <> 0 THEN
            EXCEPTION
               WHEN no_data_found THEN
                  msc_util.msc_log('Plan Not Found : ' || p_plan_id );
           	  p_ret_code := G_ERROR;
           	  p_err_msg  := sqlerrm;
		  RETURN;
            END;

        END LOOP;

EXCEPTION
        WHEN OTHERS THEN
           msc_util.msc_log('In exception of CREATE_PLAN_PARTITIONS');
           p_ret_code := G_ERROR;
           p_err_msg  := sqlerrm;
END CREATE_PLAN_PARTITIONS;


PROCEDURE CREATE_INST_PARTITIONS(p_instance_id     IN   NUMBER,
                                 p_applsys_schema  IN   VARCHAR2,
                                 p_owner	   IN   VARCHAR2,
                                 p_ret_code        OUT  NoCopy NUMBER,
                                 p_err_msg         OUT  NoCopy VARCHAR2)
AS
atp_summ_tab MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                        'ATP_SUMMARY_SD',
                                        'ATP_SUMMARY_SO');
i                 NUMBER;
l_partition_name  VARCHAR2(30);
l_split_partition VARCHAR2(30);
l_summary_flag    varchar2(30);
l_higher_instance number;
l_sql_stmt        varchar2(1000);
l_table_name      varchar2(30);

CURSOR C_INST IS
SELECT	instance_id
FROM	msc_apps_instances
WHERE	instance_id > p_instance_id
AND	NVL(summary_flag, 0) <> 0
ORDER BY instance_id;

BEGIN
        msc_util.msc_log('p_instance_id := ' || p_instance_id);
        msc_util.msc_log('p_applsys_schema := ' || p_applsys_schema);
        msc_util.msc_log('p_owner := ' || p_owner);

        p_ret_code := G_SUCCESS;
        p_err_msg  := null;

	For i in 1..atp_summ_tab.COUNT LOOP

            l_partition_name := atp_summ_tab(i) || '__' || p_instance_id;

            l_table_name := 'MSC_' || atp_summ_tab(i);
            msc_util.msc_log('table := ' || l_table_name);
            msc_util.msc_log('partition_name : '|| l_partition_name);
            BEGIN
               SELECT  NVL(summary_flag, 0)
               INTO     l_summary_flag
               FROM     msc_apps_instances
               WHERE    instance_id = p_instance_id;

               msc_util.msc_log('summary_flag for instance : '|| p_instance_id || ' : '|| l_summary_flag);

	       IF l_summary_flag <> 0 THEN
                  msc_util.msc_log('found partition for instance_id : '|| p_instance_id);
           	  p_ret_code := G_SUCCESS;
           	  p_err_msg  := null;
		  RETURN;
	       ELSIF l_summary_flag = 0 THEN
                  msc_util.msc_log('p_instance_id : ' || p_instance_id);

		  OPEN C_INST;
		  FETCH C_INST INTO l_higher_instance;

		     IF C_INST%NOTFOUND THEN
                        l_split_partition := atp_summ_tab(i) || '_0';
		     ELSE 		-- IF C_INST%NOTFOUND THEN
                        l_split_partition := atp_summ_tab(i) || '__' || l_higher_instance;
		     END IF; 	-- C_INST%NOTFOUND THEN

		  CLOSE C_INST;

                  IF l_table_name = 'MSC_ATP_SUMMARY_SO' THEN
                    l_sql_stmt := 'alter table ' || l_table_name || ' split partition '
                                || l_split_partition || ' AT ( '
                                || to_char(p_instance_id +1) || ')'
                                || ' INTO ( PARTITION ' || l_partition_name || ','
                                || ' PARTITION ' || l_split_partition || ')';
                  ELSIF l_table_name = 'MSC_ATP_SUMMARY_SD' THEN
                    l_sql_stmt := 'alter table ' || l_table_name || ' split partition '
                                || l_split_partition || ' AT ( -1, '
                                || to_char(p_instance_id +1) || ')'
                                || ' INTO ( PARTITION ' || l_partition_name || ','
                                || ' PARTITION ' ||l_split_partition || ')';
                  END IF;       -- l_table_name = 'MSC_ATP_SUMMARY_SO' THEN
                  msc_util.msc_log('l_sql_stmt := ' || l_sql_stmt);
                  ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                            APPLICATION_SHORT_NAME => 'MSC',
                            STATEMENT_TYPE => ad_ddl.alter_table,
                            STATEMENT => l_sql_stmt,
                            OBJECT_NAME => l_table_name);
                  msc_util.msc_log('Create Partition successful');
	       END IF;		-- l_summary_flag <> 0 THEN
            EXCEPTION
               WHEN no_data_found THEN
                  msc_util.msc_log('Instance Not Found : ' || p_instance_id );
           	  p_ret_code := G_ERROR;
           	  p_err_msg  := sqlerrm;
		  RETURN;
            END;

        END LOOP;

EXCEPTION
        WHEN OTHERS THEN
           msc_util.msc_log('In exception of CREATE_INST_PARTITIONS');
           p_ret_code := G_ERROR;
           p_err_msg  := sqlerrm;
END CREATE_INST_PARTITIONS;



PROCEDURE CREATE_PARTITIONS( ERRBUF             OUT    NoCopy VARCHAR2,
                             RETCODE           OUT    NoCopy NUMBER)
AS

atp_summ_tab MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                        'ATP_SUMMARY_SO',
                                        'ATP_SUMMARY_SD',
 				        'ATP_SUMMARY_RES',
                                        'ATP_SUMMARY_SUP',
					'ALLOC_DEMANDS',
					'ALLOC_SUPPLIES',
                                        -- CTO ODR Simplified Pegging
                                        'ATP_PEGGING');
i                 NUMBER;
j		  NUMBER;
l_partition_name  VARCHAR2(30);
l_split_partition VARCHAR2(30);
l_summary_flag    varchar2(30);
l_higher_instance number;
l_sql_stmt        varchar2(1000);
l_table_name      varchar2(30);
INSTANCE_IDS      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
PLAN_IDS          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_applsys_schema                varchar2(10);
l_msc_schema                    VARCHAR2(30);
l_retval                        BOOLEAN;
dummy1                          varchar2(10);
dummy2                          varchar2(10);
l_count			        number;
l_share_partition		varchar2(1);
l_plan_id			number;
-- rajjain 12/20/2002
l_spid                          VARCHAR2(12);


BEGIN
        -- Bug 3304390 Disable Trace
        -- Deleted Related Code

        l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);
        SELECT  a.oracle_username
        INTO    l_msc_schema
        FROM    FND_ORACLE_USERID a,
                FND_PRODUCT_INSTALLATIONS b
        WHERE   a.oracle_id = b.oracle_id
        AND     b.application_id = 724;


        RETCODE := G_SUCCESS;
        ERRBUF  := null;

        BEGIN
           SELECT INSTANCE_ID
           BULK COLLECT INTO INSTANCE_IDS
           ---bug 2389523: use msc_ins_partitions instead of
           -- msc_apps_instances to look for existing instance partitions
           --FROM   MSC_APPS_INSTANCES
           FROM  MSC_INST_PARTITIONS
           ORDER BY INSTANCE_ID;
        END;

        --- create Instance partitions

        FOR j in 1..INSTANCE_IDS.COUNT LOOP

           msc_util.msc_log('j := ' || j);
	   For i in 1..2 LOOP --- loop for only first two enteries of the atp_summ_tab array

               l_partition_name := atp_summ_tab(i) || '__' || INSTANCE_IDS(j);
               l_table_name := 'MSC_' || atp_summ_tab(i);
               l_split_partition := atp_summ_tab(i) || '_0';
               msc_util.msc_log('table := ' || l_table_name);
               msc_util.msc_log('partition_name : '|| l_partition_name);
               BEGIN
                     BEGIN
                         SELECT count(*)
                         INTO l_count
                         --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                         --FROM DBA_TAB_PARTITIONS
                         FROM ALL_TAB_PARTITIONS
                         WHERE TABLE_NAME = l_table_name
                         AND   PARTITION_NAME = l_partition_name
                         AND   table_owner = l_msc_schema;
                     EXCEPTION
                         WHEN OTHERS THEN
                             msc_util.msc_log('Inside Exception');
                             l_count := 1;
                     END;
                     msc_util.msc_log('l_count := ' || l_count);
                     IF l_count = 0 THEN
                        ---partition doesn't exist


                        IF l_table_name = 'MSC_ATP_SUMMARY_SO' THEN
                          l_sql_stmt := 'alter table ' || l_table_name || ' split partition '
                                      || l_split_partition || ' AT ( '
                                      || to_char(instance_ids(j) +1) || ')'
                                      || ' INTO ( PARTITION ' || l_partition_name || ','
                                      || ' PARTITION ' || l_split_partition || ')';
                        ELSIF l_table_name = 'MSC_ATP_SUMMARY_SD' THEN
                          l_sql_stmt := 'alter table ' || l_table_name || ' split partition '
                                      || l_split_partition || ' AT ( -1, '
                                      || to_char(instance_ids(j) +1) || ')'
                                      || ' INTO ( PARTITION ' || l_partition_name || ','
                                      || ' PARTITION ' ||l_split_partition || ')';
                        END IF;       -- l_table_name = 'MSC_ATP_SUMMARY_SO' THEN
                        msc_util.msc_log('l_sql_stmt := ' || l_sql_stmt);
                        ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                                  APPLICATION_SHORT_NAME => 'MSC',
                                  STATEMENT_TYPE => ad_ddl.alter_table,
                                  STATEMENT => l_sql_stmt,
                                  OBJECT_NAME => l_table_name);
                        msc_util.msc_log('Create Partition successful');
                     ELSE
                        msc_util.msc_log('Partition for instance ' || instance_ids(j) || ' already exists');
	             END IF;
               END;

           END LOOP;
        END LOOP;

        l_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');
        msc_util.msc_log('l_share_partition := ' || l_share_partition);

        IF l_share_partition = 'Y' then
            msc_util.msc_log('Share partition is on');
            ---first we check if _999999 partition exists on MSC_SYSTEM_ITEMS or not.
            ---1) If it exists then the _999999 partition might or might not exist om
            --- the atp summary tables. In this case we check and create it if it doesn't exist
            ---2) If partition on msc_system_items doesn't exist then that means customer is running
            ---   create APS partition proram for the first time. So we let create_partition_pvt
            --- in MSCPRPRB.pls create the patitions
            l_table_name := 'MSC_SYSTEM_ITEMS';
            l_partition_name := 'SYSTEM_ITEMS'  || '_' || MAXVALUE;

            BEGIN
               select count(*)
               into   l_count
               --bug 2495962: Change refrence from dba_xxx to all_xxx tables
               --from dba_tab_partitions
               from ALL_tab_partitions
               where table_name = l_table_name
               and   table_owner = l_msc_schema
               and    partition_name = l_partition_name;
            EXCEPTION
               WHEN OTHERS THEN
                  l_count := 1;
            END;
            msc_util.msc_log('Count of partition om msc_system_items := ' || l_count);
            IF l_count > 0 THEN --- patiton on msc_system items exist



	       For i in 2..atp_summ_tab.COUNT LOOP

                   l_partition_name := atp_summ_tab(i) || '_' || MAXVALUE;
                   l_plan_id := MAXVALUE;
                   l_table_name := 'MSC_' || atp_summ_tab(i);
                   msc_util.msc_log('table := ' || l_table_name);
                   msc_util.msc_log('partition_name : '|| l_partition_name);

                   BEGIN
                      select count(*)
                      into   l_count
                      --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                      --from dba_tab_partitions
                      from all_tab_partitions
                      where table_name = l_table_name
                      and   table_owner = l_msc_schema
                      and    partition_name = l_partition_name;
                   EXCEPTION
                      WHEN OTHERS THEN
                         l_count := 1;
                   END;
                   IF (l_count = 0)  THEN

                        l_sql_stmt := 'alter table ' || l_table_name || ' add partition '
                                     || l_partition_name
                                     || ' VALUES LESS THAN ('
                                     || to_char(l_plan_id) || ', ' ||to_char(MAXVALUE + 1)
                                     || ')';
                         ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                                APPLICATION_SHORT_NAME => 'MSC',
                                STATEMENT_TYPE => ad_ddl.alter_table,
                                STATEMENT => l_sql_stmt,
                                OBJECT_NAME => atp_summ_tab(i));

                         msc_util.msc_log('Create Partition successful');
                   ELSE
                         msc_util.msc_log('Plan partition for plan ' || l_plan_id || ' already exists');
                   END IF;		-- l_summary_flag <> 0 THEN

               END LOOP; --- For i in 2..atp_summ_tab.COUNT LOOP
            ELSE
               msc_util.msc_log(' No partition on msc_system_items exist.');
               msc_util.msc_log('Partitions will be created by the main program');
            END IF; -- if l_count > 0

        ELSE --- IF l_share_partition = 'Y' then
           --- create plan partitions
           --- select plan_ids
           BEGIN
              select plan_id
              bulk collect into   plan_ids
              --bug 2389523: use msc_plan_partitions instead of msc_plans
              --from   msc_plans
              from msc_plan_partitions
              order by plan_id;

           END;

           msc_util.msc_log('plan count := ' || plan_ids.count);
           FOR j in 1..plan_ids.count LOOP
              msc_util.msc_log('j := ' || j );
              msc_util.msc_log('plan_ids := ' || plan_ids(j));

	      For i in 2..atp_summ_tab.COUNT LOOP

                  l_partition_name := atp_summ_tab(i) || '_' || ABS(plan_ids(j));
                  l_plan_id := plan_ids(j);
                  l_table_name := 'MSC_' || atp_summ_tab(i);
                  msc_util.msc_log('table := ' || l_table_name);
                  msc_util.msc_log('partition_name : '|| l_partition_name);

                  BEGIN
                     select count(*)
                     into   l_count
                     --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                     --from dba_tab_partitions
                     from all_tab_partitions
                     where table_name = l_table_name
                     and   table_owner = l_msc_schema
                     and    partition_name = l_partition_name;
                  EXCEPTION
                     WHEN OTHERS THEN
                        l_count := 1;
                  END;
                  IF (l_count = 0)  AND (l_plan_id <> -1) THEN

                       l_sql_stmt := 'alter table ' || l_table_name || ' add partition '
                                    || l_partition_name
                                    || ' VALUES LESS THAN ('
                                    || to_char(l_plan_id) || ', ' ||to_char(MAXVALUE + 1)
                                    || ')';
                        ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                               APPLICATION_SHORT_NAME => 'MSC',
                               STATEMENT_TYPE => ad_ddl.alter_table,
                               STATEMENT => l_sql_stmt,
                               OBJECT_NAME => atp_summ_tab(i));

                        msc_util.msc_log('Create Partition successful');
                  ELSE
                        msc_util.msc_log('Plan partition for plan ' || l_plan_id || ' already exists');
	          END IF;		-- l_summary_flag <> 0 THEN

              END LOOP;
           END LOOP;
        END IF; -- IF l_share_partition = 'Y' then
        msc_util.msc_log('After Create Partitions');

EXCEPTION
        WHEN OTHERS THEN
           msc_util.msc_log('In exception of CREATE_PARTITIONS');
           msc_util.msc_log('sqlerrm := ' || sqlerrm);
           RETCODE := G_ERROR;
           ERRBUF  := sqlerrm;
END CREATE_PARTITIONS;

PROCEDURE LAUNCH_CONC_PROG(ERRBUF          IN OUT     NoCopy VARCHAR2,
                           RETCODE         IN OUT     NoCopy NUMBER,
                           P_INSTANCE_ID   IN      NUMBER,
                           P_COLLECT_TYPE  IN      NUMBER,
                           REFRESH_SO      IN      NUMBER,
                           REFRESH_SD      IN      NUMBER)
AS
-- rajjain 12/20/2002
l_spid                          VARCHAR2(12);

BEGIN
        -- Bug 3304390 Disable Trace
        -- Deleted Related Code.

        IF P_COLLECT_TYPE = 1 THEN ---- full refresh

           IF REFRESH_SO = 1 THEN -- full refresh S/O and S/D

              MSC_POST_PRO.LOAD_SUPPLY_DEMAND(ERRBUF, RETCODE, P_INSTANCE_ID, 3);

           ELSE

              MSC_POST_PRO.LOAD_SUPPLY_DEMAND(ERRBUF, RETCODE, P_INSTANCE_ID, 2); --full S/D
              IF RETCODE <> G_SUCCESS THEN
                  RETURN;
              END IF;
              MSC_POST_PRO.LOAD_NET_SO(ERRBUF, RETCODE, P_INSTANCE_ID);           -- Net S/O

           END IF;

        ELSIF P_COLLECT_TYPE = 2 THEN   ---- Net change Refresh

              MSC_POST_PRO.LOAD_NET_SO(ERRBUF, RETCODE, P_INSTANCE_ID); -- Net SO
              IF RETCODE <> G_SUCCESS THEN
                  RETURN;
              END IF;
              MSC_POST_PRO.LOAD_NET_SD(ERRBUF, RETCODE, P_INSTANCE_ID); -- Net SD

        ELSIF P_COLLECT_TYPE = 3 THEN ---TARGETED

           IF REFRESH_SO = 1 AND REFRESH_SD = 1 THEN

              MSC_POST_PRO.LOAD_SUPPLY_DEMAND(ERRBUF, RETCODE, P_INSTANCE_ID, 3); -- full S/O, S/D

           ELSIF REFRESH_SO = 1 THEN

              MSC_POST_PRO.LOAD_SUPPLY_DEMAND(ERRBUF, RETCODE, P_INSTANCE_ID, 1); -- full S/O

           ELSIF REFRESH_SD = 1 THEN

              MSC_POST_PRO.LOAD_SUPPLY_DEMAND(ERRBUF, RETCODE, P_INSTANCE_ID, 2); -- full S/D

           END IF;
        END IF;
        IF RETCODE <> G_SUCCESS THEN
            RETURN;
        END IF;
        --- update the summary refresh number with refresh number
        --- Summary refresh number is used by net change/targeted refresh.
        --- Net Chnage/Targeted refresh is done only for those
        --- Sales orders or supply/demands where refresh number is greater than summary refresh number
        --- This is done this way to avoid summarizing in partial refresh if it is run erroneously after
        --- full refresh by user.
        UPDATE msc_apps_instances
        SET summary_refresh_number = LCID
        WHERE instance_id = p_instance_id;

        commit;                 --bug3049003

END LAUNCH_CONC_PROG;


-- 2/14/2002 ngoel, added this procedure for cleaning pre-allocating demands and supplies temp tables
-- while using pegging from the plan in case allocation method profile is set to "Use Planning Output".

-- 6/19/2002 ngoel, modified this procedure to drop dynamically created temp tables
-- Added input parameters to drop newly added temp table MSC_ALLOC_TEMP_ as well for forecast at PF
PROCEDURE clean_temp_tables(
	p_applsys_schema 	IN  	varchar2,
	p_plan_id		IN	NUMBER,
	p_plan_id2              IN      NUMBER,
	p_demand_priority       IN      VARCHAR2)
IS
l_sql_stmt              VARCHAR2(1000);
BEGIN
        -- Drop newly added temp table for forecast at PF as well
        IF p_demand_priority = 'Y' THEN
                l_sql_stmt := 'DROP TABLE MSC_ALLOC_TEMP_' || to_char(p_plan_id2);

                BEGIN
                    msc_util.msc_log(l_sql_stmt);
                    ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.drop_table,
                           STATEMENT => l_sql_stmt,
                           OBJECT_NAME => 'MSC_ALLOC_TEMP_' || to_char(p_plan_id2));
                EXCEPTION
                    WHEN OTHERS THEN
                         msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                         msc_util.msc_log(l_sql_stmt || ' failed');
                END;
        END IF;

        IF p_plan_id = p_plan_id2 THEN -- Means share plan partition is No
                l_sql_stmt := 'DROP TABLE MSC_TEMP_ALLOC_DEM_' || to_char(p_plan_id);

                BEGIN
                    msc_util.msc_log(l_sql_stmt);
                    ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.drop_table,
                           STATEMENT => l_sql_stmt,
                           OBJECT_NAME => 'MSC_TEMP_ALLOC_DEM_' || to_char(p_plan_id));
                EXCEPTION
                    WHEN OTHERS THEN
                         msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                         msc_util.msc_log(l_sql_stmt || ' failed');
                END;

                l_sql_stmt := 'DROP TABLE MSC_TEMP_ALLOC_SUP_' || to_char(p_plan_id);

                BEGIN
                    msc_util.msc_log(l_sql_stmt);
                    ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.drop_table,
                           STATEMENT => l_sql_stmt,
                           OBJECT_NAME => 'MSC_TEMP_ALLOC_SUP_' || to_char(p_plan_id));
                EXCEPTION
                    WHEN OTHERS THEN
                         msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                         msc_util.msc_log(l_sql_stmt || ' failed');
                END;
        END IF;
END clean_temp_tables;


-- 2/14/2002 ngoel, added this procedure for pre-allocating demands and supplies using
-- pegging from the plan in case allocation method profile is set to "Demand Priority".

-- 6/19/2002 ngoel, modified to use dynamically created temp tables instead of pre-seeded temp tables
-- in case profile "MSC: Share Plan Partition" is "No". This was needed to enable multiple plan support.

PROCEDURE post_plan_allocation(
	ERRBUF          OUT     NoCopy VARCHAR2,
	RETCODE         OUT     NoCopy NUMBER,
	p_plan_id       IN 	NUMBER)
IS

G_ERROR				NUMBER := 1;
G_SUCCESS			NUMBER := 0;
MAXVALUE               CONSTANT NUMBER := 999999;

l_retval                        BOOLEAN;
l_sysdate                       DATE;
i                               NUMBER;
l_alloc_method                  NUMBER;
l_class_hrchy                   NUMBER;
l_count				NUMBER;
l_inv_ctp                       NUMBER;
l_plan_id                       NUMBER;
l_ret_code			NUMBER;
l_summary_flag			NUMBER;
l_user_id                       NUMBER;
dummy1                          VARCHAR2(10);
dummy2                          VARCHAR2(10);
l_alloc_atp                     VARCHAR2(1);
l_applsys_schema                VARCHAR2(10);
l_err_msg			VARCHAR2(1000);
l_ind_tbspace                   VARCHAR2(30);
l_insert_stmt                   VARCHAR2(8000); -- ssurendr: increased the string length
l_msc_schema                    VARCHAR2(30);
l_other_dc                      VARCHAR2(30) := '-1';
l_partition_name                VARCHAR2(30);
l_share_partition   		VARCHAR2(1);
l_sql_stmt                      VARCHAR2(300);
l_sql_stmt_1                    VARCHAR2(8000);
l_table_name			VARCHAR2(30);
l_tbspace                       VARCHAR2(30);
l_temp_table			VARCHAR2(30);
atp_summ_tab 			MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
								'ALLOC_DEMANDS',
								'ALLOC_SUPPLIES');
-- Bug 2516506
l_plan_name                     varchar2(10);

-- 2566795
cur_handler			NUMBER;
rows_processed			NUMBER;
l_hash_size			NUMBER := -1;
l_sort_size			NUMBER := -1;
l_parallel_degree		NUMBER := 1;

-- project atp
l_excess_supply_by_dc           varchar2(1);

BEGIN
    msc_util.msc_log('Begin procedure post_plan_allocation');

    l_inv_ctp := FND_PROFILE.value('INV_CTP');
    msc_util.msc_log('inv_ctp := ' || l_inv_ctp);

    IF l_inv_ctp <> 4 THEN
       -- we are not doing PDS ATP so we wont  continue
       msc_util.msc_log('Not Doing PDS ATP. Will Exit ');
       RETCODE := G_ERROR;
       RETURN;
    END IF;

    l_alloc_atp := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
    msc_util.msc_log('l_alloc_atp := ' || l_alloc_atp);

    IF l_alloc_atp <> 'Y' THEN
       -- we are not doing Allocated ATP so we wont  continue
       msc_util.msc_log('Not Doing Allocated ATP. Will Exit ');
       RETCODE := G_ERROR;
       RETURN;
    END IF;

    l_class_hrchy := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);
    msc_util.msc_log('l_class_hrchy := ' || l_class_hrchy);

    IF l_class_hrchy <> 1 THEN
       -- we are not doing Demand Class based AATP so we wont  continue
       msc_util.msc_log('Not Doing Demand Class based AATP. Will Exit ');
       RETCODE := G_ERROR;
       RETURN;
    END IF;

    l_alloc_method := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'), 2);
    msc_util.msc_log('l_alloc_method := ' || l_alloc_method);

    IF l_alloc_method <> 1 THEN
       -- we are not doing Demand Class based AATP using pegging from planning so we wont  continue
       msc_util.msc_log('Not Doing Demand Class based AATP using pegging from planning. Will Exit ');
       RETCODE := G_ERROR;
       RETURN;
    END IF;

    -- rajjain project atp changes 07/24/2003 begin
    l_excess_supply_by_dc := NVL(FND_PROFILE.VALUE('MSC_EXCESS_SUPPLY_BY_DC'), 'N');
    msc_util.msc_log('l_excess_supply_by_dc := ' || l_excess_supply_by_dc);

    BEGIN
        msc_util.msc_log('Calling custom procedure MSC_ATP_CUSTOM.Custom_Pre_Allocation...');
        MSC_ATP_CUSTOM.Custom_Pre_Allocation(p_plan_id);
        msc_util.msc_log('End MSC_ATP_CUSTOM.Custom_Pre_Allocation.');
    EXCEPTION
        WHEN OTHERS THEN
	    msc_util.msc_log('Error in custom procedure call');
	    msc_util.msc_log('Error Code: '|| sqlerrm);
    END;
    -- rajjain project atp changes 07/24/2003 end

    msc_util.msc_log('begin Loading pre-allocation demand/supply data for plan: ' || p_plan_id);
    RETCODE := G_SUCCESS;

    l_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

    msc_util.msc_log('l_share_partition := ' || l_share_partition);

    -- Bug 2516506 - select plan name also
    -- SELECT NVL(summary_flag,1)
    -- INTO   l_summary_flag
    SELECT NVL(summary_flag,1), compile_designator
    INTO   l_summary_flag, l_plan_name
    FROM   msc_plans
    WHERE  plan_id = p_plan_id;

    IF NVL(l_summary_flag,1) = 2 THEN
       msc_util.msc_log('Another session is running post-plan allocation program for this plan');
       RETCODE :=  G_ERROR;
       RETURN;
    END IF;

    l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);
    SELECT  a.oracle_username,
	    sysdate,
	    FND_GLOBAL.USER_ID
    INTO    l_msc_schema,
	    l_sysdate,
	    l_user_id
    FROM    fnd_oracle_userid a,
            fnd_product_installations b
    WHERE   a.oracle_id = b.oracle_id
    AND     b.application_id = 724;

    FOR i in 1..atp_summ_tab.count LOOP

        l_table_name := 'MSC_' || atp_summ_tab(i);

        IF (l_share_partition = 'Y') THEN
           l_plan_id := MAXVALUE;
        ELSE
           l_plan_id := p_plan_id;
        END IF;

        l_partition_name :=  atp_summ_tab(i)|| '_' || l_plan_id;
        msc_util.msc_log('l_partition_name := ' || l_partition_name);

        BEGIN
            SELECT count(*)
            INTO   l_count
            --bug 2495962: Change refrence from dba_xxx to all_xxx tables
            --FROM   dba_tab_partitions
            FROM   all_tab_partitions
            WHERE  table_name = l_table_name
            AND    partition_name = l_partition_name
            AND    table_owner = l_msc_schema;
        EXCEPTION
            WHEN OTHERS THEN
                 msc_util.msc_log('Inside Exception');
                 l_count := 0;
        END;

        IF (l_count = 0) THEN
           -- Bug 2516506
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ATP_PLAN_PARTITION_MISSING');
           FND_MESSAGE.SET_TOKEN('PLAN_NAME', l_plan_name);
           FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'MSC_' || atp_summ_tab(i));
           msc_util.msc_log(FND_MESSAGE.GET);
           RETCODE := G_ERROR;
           RETURN;
        END IF;
    END LOOP;

    BEGIN
        update msc_plans
        set    summary_flag = 2
        where  plan_id = p_plan_id;
        commit;
    EXCEPTION
        WHEN OTHERS THEN
             ERRBUF := sqlerrm;
             RETCODE := G_ERROR;
             RETURN;
    END;

        msc_util.msc_log('l_share_partition := ' || l_share_partition);

	-- performance bug 2566795. dsting: forward port from 1157

	BEGIN
	    SELECT	NVL(pre_alloc_hash_size, -1),
			NVL(pre_alloc_sort_size, -1),
			NVL(pre_alloc_parallel_degree, 1)
	    INTO	l_hash_size,
			l_sort_size,
			l_parallel_degree
	    FROM	msc_atp_parameters
	    WHERE	rownum = 1;
	EXCEPTION
	    WHEN others THEN
		 msc_util.msc_log('Error getting performance param: ' || sqlcode || ': ' || sqlerrm);
		 l_hash_size := -1;
		 l_sort_size := -1;
		 l_parallel_degree := 1;
	END;

	msc_util.msc_log('Hash: ' || l_hash_size || ' Sort: ' || l_sort_size || ' Parallel: ' || l_parallel_degree);

	IF NVL(l_hash_size, -1) <> -1 THEN
	   l_sql_stmt_1 := 'alter session set hash_area_size = ' || to_char(l_hash_size);
	   msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
	   execute immediate l_sql_stmt_1;
	END IF;

	IF NVL(l_sort_size, -1) <> -1 THEN
	   l_sql_stmt_1 := 'alter session set sort_area_size = ' || to_char(l_sort_size);
	   msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
	   execute immediate l_sql_stmt_1;
	END IF;

        IF l_share_partition = 'Y' THEN

           msc_util.msc_log('Inside shared partition');

           -- first delete the existing data from tables
           msc_util.msc_log('before deleteing data from the table');

           DELETE MSC_ALLOC_DEMANDS where plan_id = p_plan_id;
           msc_util.msc_log('After deleting data from MSC_ALLOC_DEMANDS table');

           DELETE MSC_ALLOC_SUPPLIES where plan_id = p_plan_id;
           msc_util.msc_log('After deleting data from MSC_ALLOC_SUPPLIES table');

           /* --------------------------------------------------------------- */
	   -- 2566795
	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
           -- to move demand on non-working day to prior working day.

           l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_DEMANDS(
			plan_id,
			inventory_item_id,
			organization_id,
			sr_instance_id,
			demand_class,
			demand_date,
			allocated_quantity,
			parent_demand_id,
			origination_type,
			order_number,
			sales_order_line_id,
			demand_source_type, --cmro
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			demand_quantity, -- ssurendr 25-NOV-2002: added for alloc w/b
			request_date,--bug3263368
			--bug3684383 added as in Insert_SD_Into_Details_Temp we need these columns populated
			-- to show partner name and location.
			customer_id,
                        ship_to_site_id)
		( -- Bug 3370201
		SELECT  -- Bug 3416241 changes begin Removed all hints to avoid full table scan
		        -- causing performance issues which in turn causes ORA-01555: snapshot too old
		        --/*+ use_hash(mv) parallel(mv,' || to_char(l_parallel_degree) || ')
			--	full(peg1.d1) full(peg1.d2) full(peg1.peg1) full(peg1.peg2) full(mv) */
                        --        -- 2859130 full(peg1.cal)
			peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num),
			peg1.demand_date,
			SUM(peg1.allocated_quantity) - MIN(peg1.reserved_quantity), --5027568
			peg1.demand_id,
			peg1.origination_type,
			peg1.order_number,
			peg1.sales_order_line_id,
			peg1.demand_source_type, --cmro
			:l_user_id,
			:l_sysdate,
			:l_user_id,
			:l_sysdate,
			MIN(peg1.demand_quantity), -- ssurendr 25-NOV-2002: added for alloc w/b
			peg1.request_date, --bug3263368
			--bug3684383
			peg1.customer_id,
			peg1.ship_to_site_id
			-- min is used to select distinct values as demand_quantity would be
			-- repeating for the same demand_id
		FROM
                        -- use inline view so that view parallel hint could be used.
			-- msc_demand_pegging_v peg1,
                        -- 2859130 (SELECT /*+ ordered use_hash(d2 peg2 peg1 d1 tp cal)
                        (SELECT -- Bug 3416241 changes begin Removed all hints to avoid full table scan
		                -- causing performance issues which in turn causes ORA-01555: snapshot too old
		                --/*+ ordered use_hash(d2 peg2 peg1 tp)
				--	parallel(d2,' || to_char(l_parallel_degree) || ')
				--	parallel(d1,' || to_char(l_parallel_degree) || ')
				--	parallel(peg2,' || to_char(l_parallel_degree) || ')
				--	parallel(peg1,' || to_char(l_parallel_degree) || ')*/
                                        -- time_phased_atp
                                        -- parallel(tp,'  || to_char(l_parallel_degree) || ')

                                        -- 2859130
                                        -- parallel(cal,' || to_char(l_parallel_degree) || ')
				peg2.plan_id,
				peg2.inventory_item_id,
				peg2.organization_id,
				peg2.sr_instance_id,
				-- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
				NVL(d1.demand_class, :def_num) demand_class,
				trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
					     2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
					        NVL(d2.SCHEDULE_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE))) demand_date,----plan by request date, promise date or schedule date
				-- cal.prior_date demand_date, -- 2859130
				-- cal.calendar_date demand_date,
				peg2.allocated_quantity,
				DECODE( d2.origination_type, 30, NVL(d2.reserved_quantity, 0), 0) reserved_quantity, --5027568
				d2.demand_id,
				d2.origination_type,
				--d2.order_number,
				-- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id
                                -- in order_number column
				decode(d2.origination_type, 1, to_char(d2.disposition_id), d2.order_number) order_number,
				d2.sales_order_line_id,
				d2.demand_source_type, --cmro
			        decode(d2.origination_type, 4, d2.daily_demand_rate,
			           d2.using_requirement_quantity) demand_quantity , -- rajjain 02/06/2003 Bug 2782882
			        decode(d2.order_date_type_code,2,d2.request_date,
			           d2.request_ship_date)request_date, --bug3263368
				--peg2.demand_quantity -- ssurendr 25-NOV-2002: added for alloc w/b
				--bug3684383
				d2.customer_id,
                                d2.ship_to_site_id
                        FROM	msc_demands d2,
				msc_full_pegging peg2,
				msc_full_pegging peg1 ,
				msc_demands d1
				-- time_phased_atp
				-- msc_trading_partners tp
                                -- 2859130
				-- msc_calendar_dates cal
                        WHERE	peg2.plan_id = peg1.plan_id
                        AND	peg2.end_pegging_id = peg1.pegging_id
                        AND	peg2.sr_instance_id = peg1.sr_instance_id
                        AND	d1.plan_id = peg1.plan_id
                        AND	d1.demand_id = peg1.demand_id
                        AND	d1.sr_instance_id = peg1.sr_instance_id
                        AND	d2.plan_id = peg2.plan_id
                        AND	d2.demand_id = peg2.demand_id
                        AND	d2.sr_instance_id = peg2.sr_instance_id
                        AND	d2.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)
			-- time_phased_atp
			-- AND	tp.sr_tp_id = peg2.organization_id
			-- AND	tp.partner_type = 3 -- bug2646304
			-- AND	tp.sr_instance_id = peg2.sr_instance_id
                        -- 2859130
			-- AND	tp.sr_instance_id = cal.sr_instance_id
			-- AND	tp.calendar_code = cal.calendar_code
			-- AND	tp.calendar_exception_set_id = cal.exception_set_id
			-- AND	TRUNC(d2.using_assembly_demand_date) = cal.calendar_date
                        ) peg1,
			msc_item_hierarchy_mv mv
		WHERE   peg1.plan_id = :p_plan_id
		AND     peg1.inventory_item_id = mv.inventory_item_id(+)
		AND     peg1.organization_id = mv.organization_id (+)
		AND     peg1.sr_instance_id = mv.sr_instance_id (+)
		AND     peg1.demand_date >=  mv.effective_date (+)
		AND     peg1.demand_date <=  mv.disable_date (+)
		AND	peg1.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		GROUP BY
			peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num),
			peg1.demand_date,
			peg1.demand_id,
			peg1.origination_type,
			peg1.order_number,
			peg1.sales_order_line_id,
			peg1.demand_source_type,--cmro
			:l_user_id,
			:l_sysdate,
			:l_user_id,
			:l_sysdate,
			peg1.request_date,
			--bug3684383
			peg1.customer_id,
			peg1.ship_to_site_id)';

	   -- performance bug 2566795
           -- parallel hint can't be used with union all. Use two queries instead

		-- UNION ALL
           msc_util.msc_log('After Generating the sql');

           -- Obtain cursor handler for sql_stmt
           cur_handler := DBMS_SQL.OPEN_CURSOR;

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing the sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);
           msc_util.msc_log('After inserting in msc_alloc_demands part 1');

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
	   -- to move demand on non-working day to prior working day.

           /* time_phased_atp - project atp forward port
            * If the profile is set to 'Yes' then:
            *    o If the supply pegged to the demand has a demand class existing on allocation rule then
            *      allocate the demand to that demand class.
            *    o If the supply pegged to the demand has a demand class not present on allocation rule then
            *      allocate the demand to 'OTHER'.
            *    o If the supply pegged to the demand does not have a demand class present, allocate the demand
            *      to 'OTHER'.
            * Else: Allocate the demand to 'OTHER'*/
           IF l_excess_supply_by_dc = 'Y' THEN
                   l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_DEMANDS(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                order_number,
                                sales_order_line_id,
                                demand_source_type, --cmro
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                demand_quantity,
                                request_date)--bug3263368
                	(
                        SELECT	--5053818
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.demand_date,
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                MIN(pegging_v.demand_quantity),
                                pegging_v.request_date --bug3263368
                        FROM
                                (SELECT -- Bug 3416241 changes begin Removed all hints to avoid full table scan
		                        -- causing performance issues which in turn causes ORA-01555: snapshot too old
		                        --/*+ ordered use_hash(peg2 peg1 d s)
                        		--	parallel(peg2,' || to_char(l_parallel_degree) || ')
                        		--	parallel(peg1,' || to_char(l_parallel_degree) || ')
                        		--	parallel(d,' || to_char(l_parallel_degree) || ')
                                        --      parallel(s,' || to_char(l_parallel_degree) || ')
                        		--	full(peg2) full(peg1) full(d) full(s) */
                                        peg1.plan_id plan_id,
                        	        peg1.inventory_item_id,
                        	        peg1.organization_id,
                        	        peg1.sr_instance_id,
                        	        NVL(s.demand_class, :def_num) demand_class,
                        	        -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                                        trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))) demand_date,--plan by request date, promise date or schedule date
                        		peg1.allocated_quantity,
                                        d.demand_id,
                        		d.origination_type,
                        		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                        		d.sales_order_line_id,
                        		d.demand_source_type, --cmro
                        		decode(d.origination_type, 4, d.daily_demand_rate,
                        		           d.using_requirement_quantity) demand_quantity ,
                        		decode(d.order_date_type_code,2,d.request_date,
                        		           d.request_ship_date)request_date --bug3263368
                        	FROM    msc_full_pegging peg2,
                        	        msc_full_pegging peg1,
                        		msc_demands d,
                                        msc_supplies s
                        	WHERE   peg1.plan_id = :p_plan_id
                        	AND     peg2.plan_id = peg1.plan_id
                        	AND     peg2.pegging_id = peg1.end_pegging_id
                        	AND     peg2.demand_id IN (-1, -2)
                        	AND     d.demand_id = peg1.demand_id
                        	AND     peg1.plan_id = d.plan_id
                        	AND     d.sr_instance_id = peg1.sr_instance_id
                        	AND     peg1.sr_instance_id=s.sr_instance_id
                        	AND     peg1.plan_id = s.plan_id
                        	AND     peg1.transaction_id = s.transaction_id
                        	AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.inventory_item_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.demand_date >=  mv.effective_date (+)
                        AND     pegging_v.demand_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                	GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.demand_date,
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                pegging_v.request_date)';
           ELSE
                   l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_DEMANDS(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                order_number,
                                sales_order_line_id,
                                demand_source_type, --cmro
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                demand_quantity,  -- ssurendr 25-NOV-2002: added for alloc w/b
                                request_date)--bug3263368
        		 (SELECT -- Bug 3416241 changes begin Removed all hints to avoid full table scan
		                 -- causing performance issues which in turn causes ORA-01555: snapshot too old
		                 --/*+ ordered use_hash(peg2 peg1 d)
        			--	parallel(peg2,' || to_char(l_parallel_degree) || ')
        			--	parallel(peg1,' || to_char(l_parallel_degree) || ')
        			--	parallel(d,' || to_char(l_parallel_degree) || ')
        			--	full(peg2) full(peg1) full(d) */
                                        -- time_phased_atp
                                        -- parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- 2859130 parallel(cal,' || to_char(l_parallel_degree) || ')
                                        -- full(cal)
                                peg1.plan_id plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num demand_class,
                                -- cal.prior_date, -- 2859130
                                -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
        			trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),--plan by request date, promise date or schedule date
        			SUM(peg1.allocated_quantity),
                                d.demand_id,
        			d.origination_type,
        			--d.order_number,
        			-- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id
                                -- in order_number column
        			decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
        			d.sales_order_line_id,
        			d.demand_source_type, --cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
        			MIN(decode(d.origination_type, 4, d.daily_demand_rate,
        			           d.using_requirement_quantity)), -- rajjain 02/06/2003 Bug 2782882
        			--MIN(peg1.demand_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
        			-- min is used to select distinct values as demand_quantity would be
        			-- repeating for the same demand_id
        			--decode(d.order_date_type_code,2,d2.request_date,
        			decode(d.order_date_type_code,2,d.request_date, -- Bug 3370201
        			            d.request_ship_date)request_date --bug3263368
        		FROM    msc_full_pegging peg2,
        		        msc_full_pegging peg1,
        			msc_demands d
                                -- time_phased_atp msc_trading_partners tp
                                -- 2859130 msc_calendar_dates cal
        		WHERE   peg1.plan_id = :p_plan_id
        		AND     peg2.plan_id = peg1.plan_id
        		AND     peg2.pegging_id = peg1.end_pegging_id
        		AND     peg2.demand_id IN (-1, -2)
        		AND     d.demand_id = peg1.demand_id
        		AND     peg1.plan_id = d.plan_id
        		AND     d.sr_instance_id = peg1.sr_instance_id
        		AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                        --AND     tp.sr_tp_id = peg1.organization_id
        		--AND	tp.partner_type = 3 -- bug2646304
                        --AND     tp.sr_instance_id = peg1.sr_instance_id
                        --AND     tp.sr_instance_id = cal.sr_instance_id
                        --AND     tp.calendar_code = cal.calendar_code
                        --AND     tp.calendar_exception_set_id = cal.exception_set_id
                        --AND     TRUNC(d.using_assembly_demand_date) = cal.calendar_date
        		GROUP BY
        			peg1.plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num,
        		        -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),--plan by request date, promise date or schedule date
                                -- 2859130 cal.prior_date,
        			d.demand_id,
                                d.origination_type,
                                decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                --decode(d.order_date_type_code,2,d2.request_date,
                                decode(d.order_date_type_code,2,d.request_date, -- Bug 3370201
        			            d.request_ship_date) --bug3263368
        		)';
           END IF;
           -- time_phased_atp - project atp forward port

           msc_util.msc_log('After Generating the sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing the sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);
           msc_util.msc_log('after inserting item data into MSC_ALLOC_DEMANDS tables');

	   /* ------------------------------------------------------------------ */

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
           -- to move demand on non-working day to prior working day.

           l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_SUPPLIES(
			plan_id,
			inventory_item_id,
			organization_id,
			sr_instance_id,
			demand_class,
			supply_date,
			allocated_quantity,
			parent_transaction_id,
			order_type,
			order_number,
			schedule_designator_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
		(
		SELECT	/*+  use_hash(peg1 mv) parallel(mv,' || to_char(l_parallel_degree) || ')  */
			peg1.plan_id plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num) demand_class,
			peg1.supply_date,
			SUM(peg1.allocated_quantity),
                        peg1.transaction_id,
			peg1.order_type,
			peg1.order_number,
			peg1.schedule_designator_id,
                        :l_user_id,
                        :l_sysdate,
                        :l_user_id,
                        :l_sysdate,
			MIN(peg1.supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
			-- min is used to select distinct values as supply_quantity would be
			-- repeating for the same transaction_id
		FROM    -- msc_supply_pegging_v peg1,
			(SELECT --5053818
                                        -- time_phased_atp
                                        -- parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- 2859130 parallel(cal,' || to_char(l_parallel_degree) || ')
				peg2.plan_id,
				peg2.inventory_item_id,
				peg2.organization_id,
				peg2.sr_instance_id,
				NVL (d.demand_class, :def_num) demand_class,
				trunc(s.new_schedule_date) supply_date,
				-- cal.next_date supply_date,  --2859130
				peg2.allocated_quantity,
				peg2.transaction_id,
				s.order_type,
				s.order_number,
				s.schedule_designator_id ,
				nvl(s.firm_quantity,s.new_order_quantity) supply_quantity -- rajjain 02/06/2003 Bug 2782882
				--peg2.supply_quantity  -- ssurendr 25-NOV-2002: added for alloc w/b
			FROM	msc_supplies s,
				msc_full_pegging peg2,
				msc_full_pegging peg1,
				msc_demands d
                                -- time_phased_atp msc_trading_partners tp
                                -- 2859130 msc_calendar_dates cal
			WHERE	peg2.plan_id = peg1.plan_id
			  AND	peg2.end_pegging_id = peg1.pegging_id
			  AND	d.plan_id = peg1.plan_id
			  AND	d.demand_id = peg1.demand_id
			  AND	d.sr_instance_id = peg1.sr_instance_id
			  AND	d.inventory_item_id = peg1.inventory_item_id
			  AND	s.plan_id = peg2.plan_id
			  AND	s.transaction_id = peg2.transaction_id
			  AND	s.sr_instance_id = peg2.sr_instance_id
                          -- time_phased_atp
                          -- AND   tp.sr_tp_id = peg2.organization_id
			  -- AND	tp.partner_type = 3 -- bug2646304
                          -- AND   tp.sr_instance_id = peg2.sr_instance_id
                          -- 2859130 AND   tp.sr_instance_id = cal.sr_instance_id
                          --AND   tp.calendar_code = cal.calendar_code
                          --AND   tp.calendar_exception_set_id = cal.exception_set_id
                          --AND   TRUNC(s.new_schedule_date) = cal.calendar_date
                        ) peg1,
			msc_item_hierarchy_mv mv
		WHERE	peg1.plan_id = :p_plan_id
		AND     peg1.inventory_item_id = mv.inventory_item_id(+)
		AND     peg1.organization_id = mv.organization_id (+)
		AND     peg1.sr_instance_id = mv.sr_instance_id (+)
		AND     peg1.supply_date >=  mv.effective_date (+)
		AND     peg1.supply_date <=  mv.disable_date (+)
		AND	peg1.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		GROUP BY
			peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num),
			peg1.supply_date,
                        peg1.transaction_id,
			peg1.order_type,
			peg1.order_number,
			peg1.schedule_designator_id,
                        :l_user_id,
                        :l_sysdate,
                        :l_user_id,
                        :l_sysdate)';

           msc_util.msc_log('After Generating first supplies sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing first supplies sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing first supplies cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);

           msc_util.msc_log('After inserting in msc_alloc_supplies part 1');

           -- parallel hint can't be used with union all. Use two query instead

	   --UNION ALL

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
           -- to move demand on non-working day to prior working day.

           /* time_phased_atp - project atp forward port
            * If the profile is set to 'Yes' then:
            *    o If supply has a demand class existing on allocation rule then
            *      allocate the supply to that demand class.
            *    o If supply has a demand class not present on allocation rule then
            *      allocate the supply to 'OTHER'.
            *    o If supply does not have a demand class present, allocate the supply
            *      to 'OTHER'.
            * Else: Allocate the supply to 'OTHER'*/
           IF l_excess_supply_by_dc = 'Y' THEN
                   l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_SUPPLIES(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                allocated_quantity,
                                parent_transaction_id,
                                order_type,
                                order_number,
                                schedule_designator_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                supply_quantity)
        		(
        	        SELECT	--5053818
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.supply_date,
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                MIN(pegging_v.supply_quantity)
                        FROM
                                (SELECT  --5053818
                                        peg1.plan_id plan_id,
                                        peg1.inventory_item_id,
                                        peg1.organization_id,
                                        peg1.sr_instance_id,
                                        NVL(s.demand_class, :def_num) demand_class,
                                        TRUNC(s.new_schedule_date) supply_date,
                                        peg1.allocated_quantity,
                                        peg1.transaction_id,
                                        s.order_type,
                                        s.order_number,
                                        s.schedule_designator_id,
                                        nvl(s.firm_quantity,s.new_order_quantity) supply_quantity
                                FROM    msc_full_pegging peg2,
                                        msc_full_pegging peg1,
                                	msc_supplies s
                                WHERE   peg1.plan_id = :p_plan_id
                                AND     peg2.plan_id = peg1.plan_id
                                AND     peg2.pegging_id = peg1.end_pegging_id
                                AND     peg2.demand_id IN (-1, -2)
                                AND     s.plan_id = peg1.plan_id
                                AND     s.transaction_id = peg1.transaction_id
                                AND     s.sr_instance_id = peg1.sr_instance_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.inventory_item_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.supply_date >=  mv.effective_date (+)
                        AND     pegging_v.supply_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
        		GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';

           ELSE
                   l_sql_stmt_1 := 'INSERT INTO MSC_ALLOC_SUPPLIES(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                allocated_quantity,
                                parent_transaction_id,
                                order_type,
                                order_number,
                                schedule_designator_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
        		(
        		SELECT  --5053818
                                        -- time_phased_atp parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- 2859130 parallel(cal,' || to_char(l_parallel_degree) || ')
        			peg1.plan_id plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num demand_class,
        			trunc(s.new_schedule_date),
        			-- cal.next_date, --2859130
        			-- cal.calendar_date,
        			SUM(peg1.allocated_quantity),
                                peg1.transaction_id,
        			s.order_type,
        			s.order_number,
        			s.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
        			MIN(nvl(s.firm_quantity,s.new_order_quantity)) -- rajjain 02/06/2003 Bug 2782882
        			--MIN(peg1.supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
        			-- min is used to select distinct values as supply_quantity would be
        			-- repeating for the same transaction_id
        		FROM    msc_full_pegging peg2,
        		        msc_full_pegging peg1,
        			msc_supplies s
                                -- time_phased_atp msc_trading_partners tp
                                -- 2859130 msc_calendar_dates cal
        		WHERE   peg1.plan_id = :p_plan_id
        		AND     peg2.plan_id = peg1.plan_id
        		AND     peg2.pegging_id = peg1.end_pegging_id
        		AND     peg2.demand_id IN (-1, -2)
        		AND     s.plan_id = peg1.plan_id
        		AND     s.transaction_id = peg1.transaction_id
        		AND     s.sr_instance_id = peg1.sr_instance_id
                        -- time_phased_atp
                        -- AND     tp.sr_tp_id = peg1.organization_id
        		-- AND	tp.partner_type = 3 -- bug2646304
                        -- AND     tp.sr_instance_id = peg1.sr_instance_id
                        -- 2859130 AND     tp.sr_instance_id = cal.sr_instance_id
                        -- AND     tp.calendar_code = cal.calendar_code
                        -- AND     tp.calendar_exception_set_id = cal.exception_set_id
                        -- AND     TRUNC(s.new_schedule_date) = cal.calendar_date
        		GROUP BY
        			peg1.plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num,
        			trunc(s.new_schedule_date),
        			-- 2859130 cal.next_date,
                                peg1.transaction_id,
        			s.order_type,
        			s.order_number,
        			s.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
           END IF;
           -- time_phased_atp - project atp forward port

           msc_util.msc_log('After Generating second supplies sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_sql_stmt_1, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing second supplies sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing second supplies cursor');

           msc_util.msc_log('rows processed: ' || rows_processed);
           msc_util.msc_log('After inserting in msc_alloc_supplies part 2');

           msc_util.msc_log('after inserting item data into MSC_ALLOC_SUPPLIES tables');

           msc_util.msc_log('Analyze Plan partition for MSC_ALLOC_DEMANDS');
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>'MSC_ALLOC_DEMANDS',
                                   partname=>'ALLOC_DEMANDS_999999',
                                   granularity=>'PARTITION',
                                   percent =>10);

           msc_util.msc_log('Analyze Plan partition for MSC_ALLOC_SUPPLIES');
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>'MSC_ALLOC_SUPPLIES',
                                   partname=>'ALLOC_SUPPLIES_999999',
                                   granularity=>'PARTITION',
                                   percent =>10);
        ELSE
	   -- IF l_share_partition = 'Y' THEN
           msc_util.msc_log('not a shared plan partition, insert data into temp tables');

           l_temp_table := 'MSC_TEMP_ALLOC_DEM_' || to_char(l_plan_id);

           msc_util.msc_log('temp table : ' || l_temp_table);

           SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
	   INTO    l_tbspace, l_ind_tbspace
           --bug 2495962: Change refrence from dba_xxx to all_xxx tables
           --FROM    dba_tab_partitions t,
           --       dba_part_indexes i
           FROM    all_tab_partitions t,
                   all_part_indexes i
           WHERE   t.table_owner = l_msc_schema
           AND     t.table_name = 'MSC_ALLOC_DEMANDS'
	   AND     t.partition_name = 'ALLOC_DEMANDS_' || to_char(l_plan_id)
           AND     i.owner (+) = t.table_owner
           AND     i.table_name (+) = t.table_name
           AND     rownum = 1;

           msc_util.msc_log('tb space : ' || l_tbspace);
           msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);

           --bug 6113544
         l_insert_stmt := 'CREATE TABLE ' || l_temp_table
           || ' TABLESPACE ' || l_tbspace
           || ' PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)'
           || ' as select * from MSC_ALLOC_DEMANDS where 1=2 ';

			/*
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table || '(
				 PLAN_ID                    NUMBER           NOT NULL,
				 INVENTORY_ITEM_ID          NUMBER           NOT NULL,
				 ORGANIZATION_ID            NUMBER           NOT NULL,
				 SR_INSTANCE_ID             NUMBER           NOT NULL,
				 DEMAND_CLASS               VARCHAR2(30)     ,   --bug3272444
				 DEMAND_DATE                DATE             NOT NULL,
				 PARENT_DEMAND_ID           NUMBER           NOT NULL,
				 ALLOCATED_QUANTITY         NUMBER           NOT NULL,
				 ORIGINATION_TYPE           NUMBER           NOT NULL,
				 ORDER_NUMBER               VARCHAR2(62),
				 SALES_ORDER_LINE_ID        NUMBER,
				 OLD_DEMAND_DATE            DATE,
				 OLD_ALLOCATED_QUANTITY     NUMBER,
				 CREATED_BY                 NUMBER           NOT NULL,
				 CREATION_DATE              DATE             NOT NULL,
				 LAST_UPDATED_BY            NUMBER           NOT NULL,
				 LAST_UPDATE_DATE           DATE             NOT NULL,
				 DEMAND_QUANTITY            NUMBER,   -- ssurendr 25-NOV-2002: added for alloc w/b
				 PF_DISPLAY_FLAG            NUMBER,   -- For time_phased_atp
				 ORIGINAL_ITEM_ID           NUMBER,   -- For time_phased_atp
				 ORIGINAL_ORIGINATION_TYPE  NUMBER,   -- For time_phased_atp
				 ORIGINAL_DEMAND_DATE       DATE,     -- For time_phased_atp
		                 SOURCE_ORGANIZATION_ID     NUMBER,   -- For time_phased_atp --bug3272444
                                 USING_ASSEMBLY_ITEM_ID     NUMBER,   -- For time_phased_atp --bug3272444
                                 CUSTOMER_ID                NUMBER,   -- For time_phased_atp
                                 SHIP_TO_SITE_ID            NUMBER,   -- For time_phased_atp
                                 REFRESH_NUMBER             NUMBER,   --bug3272444
                                 OLD_REFRESH_NUMBER         NUMBER,   --bug3272444
                                 DEMAND_SOURCE_TYPE         NUMBER,   --cmro
                                 REQUEST_DATE               DATE)     --bug3263368
			    TABLESPACE ' || l_tbspace || '
                            -- NOLOGGING
                            PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';
			*/
           msc_util.msc_log('before creating table : ' || l_temp_table);
           BEGIN
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.create_table,
                   STATEMENT => l_insert_stmt,
                   OBJECT_NAME => l_temp_table);
              msc_util.msc_log('after creating table : ' || l_temp_table);

           EXCEPTION
              WHEN others THEN
                 msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                 msc_util.msc_log('Exception of create table : ' || l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.drop_table,
                        STATEMENT =>  'DROP TABLE ' || l_temp_table,
                        OBJECT_NAME => l_temp_table);

                 msc_util.msc_log('After Drop table : ' ||l_temp_table);
                 msc_util.msc_log('Before exception create table : ' ||l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.create_table,
                        STATEMENT => l_insert_stmt,
                        OBJECT_NAME => l_temp_table);
                 msc_util.msc_log('After exception create table : ' ||l_temp_table);
           END;

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
           -- to move demand on non-working day to prior working day.

           -- cannot use append with other hints
           --l_insert_stmt := 'INSERT /*+ APPEND */ INTO ' || l_temp_table || '(
           l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                        plan_id,
                        inventory_item_id,
                        organization_id,
                        sr_instance_id,
                        demand_class,
                        demand_date,
                        allocated_quantity,
                        parent_demand_id,
                        origination_type,
                        order_number,
                        sales_order_line_id,
                        demand_source_type,--cmro
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        demand_quantity,  -- ssurendr 25-NOV-2002: added for alloc w/b
                        request_date,-- Bug 3370201
                        --bug3684383
                        customer_id,
                        ship_to_site_id)
                (
		SELECT	--5053818
				-- full(peg1.tp)
                                -- full(peg1.cal)
                        peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num) demand_class,
			peg1.demand_date,
			(SUM(peg1.allocated_quantity)- MIN(peg1.reserved_quantity)) allocated_quantity, --5027568
			peg1.demand_id,
			peg1.origination_type,
			peg1.order_number,
			peg1.sales_order_line_id,
			peg1.demand_source_type,--cmro
			:l_user_id created_by,
			:l_sysdate creation_date,
			:l_user_id last_updated_by,
			:l_sysdate last_update_date,
			MIN(peg1.demand_quantity) demand_quantity,  -- ssurendr 25-NOV-2002: added for alloc w/b
			-- min is used to select distinct values as demand_quantity would be
			-- repeating for the same demand_id
			peg1.request_date, -- Bug 3370201
                        --bug3684383
			peg1.customer_id,
			peg1.ship_to_site_id
		FROM
                        -- use inline view so that view parallel hint could be used.
			-- msc_demand_pegging_v peg1,
                        (SELECT --5053818
                                        -- parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- parallel(cal,' || to_char(l_parallel_degree) || ')
                        	peg2.plan_id,
				peg2.inventory_item_id,
				peg2.organization_id,
				peg2.sr_instance_id,
				NVL(d1.demand_class, :def_num) demand_class,
				-- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
				trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d2.PLANNED_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d2.SCHEDULE_SHIP_DATE,d2.USING_ASSEMBLY_DEMAND_DATE))) demand_date, --plan by request date, promise date or schedule date
				-- cal.prior_date demand_date,
				-- cal.calendar_date demand_date, -- 2859130
				peg2.allocated_quantity,
				DECODE( d2.origination_type, 30, NVL(d2.reserved_quantity, 0), 0) reserved_quantity, --5027568
				d2.demand_id,
				d2.origination_type,
				--d2.order_number,
				-- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id
                                -- in order_number column
				decode(d2.origination_type, 1, to_char(d2.disposition_id), d2.order_number) order_number,
				d2.sales_order_line_id,
				d2.demand_source_type,--cmro
			        decode(d2.origination_type, 4, d2.daily_demand_rate,
			           d2.using_requirement_quantity) demand_quantity, -- rajjain 02/06/2003 Bug 2782882
				--peg2.demand_quantity -- ssurendr 25-NOV-2002: added for alloc w/b
			        decode(d2.order_date_type_code,2,d2.request_date,
			           d2.request_ship_date) request_date, -- Bug 3370201
                                --bug3684383
				d2.customer_id,
                                d2.ship_to_site_id
                        FROM	msc_demands d2,
				msc_full_pegging peg2,
				msc_full_pegging peg1,
				msc_demands d1
				-- time_phased_atp msc_trading_partners tp
				-- 2859130 msc_calendar_dates cal
                        WHERE	peg2.plan_id = peg1.plan_id
                        AND	peg2.end_pegging_id = peg1.pegging_id
                        AND	peg2.sr_instance_id = peg1.sr_instance_id
                        AND	d1.plan_id = peg1.plan_id
                        AND	d1.demand_id = peg1.demand_id
                        AND	d1.sr_instance_id = peg1.sr_instance_id
                        AND	d2.plan_id = peg2.plan_id
                        AND	d2.demand_id = peg2.demand_id
                        AND	d2.sr_instance_id = peg2.sr_instance_id
                        AND	d2.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)
			-- time_phased_atp
			-- AND	tp.sr_tp_id = peg2.organization_id
			-- AND	tp.partner_type = 3 -- bug2646304
			-- AND	tp.sr_instance_id = peg2.sr_instance_id
			-- 2859130
                        -- AND	tp.sr_instance_id = cal.sr_instance_id
			--AND	tp.calendar_code = cal.calendar_code
			--AND	tp.calendar_exception_set_id = cal.exception_set_id
			--AND	TRUNC(d2.using_assembly_demand_date) = cal.calendar_date
                        ) peg1,
			msc_item_hierarchy_mv mv
		WHERE   peg1.plan_id = :p_plan_id
		AND     peg1.inventory_item_id = mv.inventory_item_id(+)
		AND     peg1.organization_id = mv.organization_id (+)
		AND     peg1.sr_instance_id = mv.sr_instance_id (+)
		AND     peg1.demand_date >=  mv.effective_date (+)
		AND     peg1.demand_date <=  mv.disable_date (+)
		AND	peg1.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		GROUP BY
			peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num),
			peg1.demand_date,
			peg1.demand_id,
			peg1.origination_type,
			peg1.order_number,
			peg1.sales_order_line_id,
			peg1.demand_source_type,--cmro
			:l_user_id,
			:l_sysdate,
			:l_user_id,
			:l_sysdate,
			peg1.request_date, -- Bug 3370201
                        --bug3684383
			peg1.customer_id,
			peg1.ship_to_site_id)';

           msc_util.msc_log('After Generating the sql');

           -- Obtain cursor handler for sql_stmt
           cur_handler := DBMS_SQL.OPEN_CURSOR;

           DBMS_SQL.PARSE(cur_handler, l_insert_stmt, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing the sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');

           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');

           -- parallel hint can't be used with union all. Use two query instead */

           -- UNION ALL

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
           -- to move demand on non-working day to prior working day.

           /* time_phased_atp - project atp forward port
            * If the profile is set to 'Yes' then:
            *    o If the supply pegged to the demand has a demand class existing on allocation rule then
            *      allocate the demand to that demand class.
            *    o If the supply pegged to the demand has a demand class not present on allocation rule then
            *      allocate the demand to 'OTHER'.
            *    o If the supply pegged to the demand does not have a demand class present, allocate the supply
            *      to 'OTHER'.
            * Else: Allocate the demand to 'OTHER'*/
           IF l_excess_supply_by_dc = 'Y' THEN
                   l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                demand_quantity,
                                request_date) -- Bug 3370201
                	(
                        SELECT	--5053818
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.demand_date,
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                MIN(pegging_v.demand_quantity),
                                pegging_v.request_date -- Bug 3370201
                        FROM
                                (SELECT --5053818
                                        peg1.plan_id plan_id,
                        	        peg1.inventory_item_id,
                        	        peg1.organization_id,
                        	        peg1.sr_instance_id,
                        	        NVL(s.demand_class, :def_num) demand_class,
                        	        -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                                        trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))) demand_date,--plan by request date, promise date or schedule date
                        		peg1.allocated_quantity,
                                        d.demand_id,
                        		d.origination_type,
                        		decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number) order_number,
                        		d.sales_order_line_id,
                        		d.demand_source_type,--cmro
                        		decode(d.origination_type, 4, d.daily_demand_rate,
                        		           d.using_requirement_quantity) demand_quantity,
        			        decode(d.order_date_type_code,2,d.request_date,
        			           d.request_ship_date) request_date -- Bug 3370201
                        	FROM    msc_full_pegging peg2,
                        	        msc_full_pegging peg1,
                        		msc_demands d,
                                        msc_supplies s
                        	WHERE   peg1.plan_id = :p_plan_id
                        	AND     peg2.plan_id = peg1.plan_id
                        	AND     peg2.pegging_id = peg1.end_pegging_id
                        	AND     peg2.demand_id IN (-1, -2)
                        	AND     d.demand_id = peg1.demand_id
                        	AND     peg1.plan_id = d.plan_id
                        	AND     d.sr_instance_id = peg1.sr_instance_id
                        	AND     peg1.sr_instance_id=s.sr_instance_id
                        	AND     peg1.plan_id = s.plan_id
                        	AND     peg1.transaction_id = s.transaction_id
                        	AND	d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.inventory_item_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.demand_date >=  mv.effective_date (+)
                        AND     pegging_v.demand_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
                	GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.demand_date,
                                pegging_v.demand_id,
                                pegging_v.origination_type,
                                pegging_v.order_number,
                                pegging_v.sales_order_line_id,
                                pegging_v.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                pegging_v.request_date)'; -- Bug 3370201
           ELSE
                   -- cannot use append with other hints
                   --l_insert_stmt := 'INSERT /*+ APPEND */ INTO ' || l_temp_table || '(
                   l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                demand_date,
                                allocated_quantity,
                                parent_demand_id,
                                origination_type,
                                order_number,
                                sales_order_line_id,
                                demand_source_type,--cmro
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                demand_quantity,  -- ssurendr 25-NOV-2002: added for alloc w/b
                                request_date) -- Bug 3370201
                        (SELECT  --5053818
                                        -- time_phased_atp
                                        -- parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- 2859130 full(cal)
                                        --parallel(cal,' || to_char(l_parallel_degree) || ')
                                peg1.plan_id plan_id,
                                peg1.inventory_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                :def_num demand_class,
                                -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),--plan by request date, promise date or schedule date -- 2859130
                                -- cal.prior_date,
                                SUM(peg1.allocated_quantity),
                                d.demand_id,
                                d.origination_type,
        			--d.order_number,
        			-- rajjain 04/25/2003 Bug 2771075
                                -- For Planned Order Demands We will populate disposition_id
                                -- in order_number column
        			decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
        			MIN(decode(d.origination_type, 4, d.daily_demand_rate,
        			           d.using_requirement_quantity)), -- rajjain 02/06/2003 Bug 2782882
        			--MIN(peg1.demand_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
        			-- min is used to select distinct values as demand_quantity would be
        			-- repeating for the same demand_id
			        decode(d.order_date_type_code,2,d.request_date,
			           d.request_ship_date) request_date -- Bug 3370201
                        FROM    msc_full_pegging peg2,
                                msc_full_pegging peg1,
                                msc_demands d
                                -- time_phased_atp msc_trading_partners tp
                                -- 2859130 msc_calendar_dates cal
                        WHERE   peg1.plan_id = :p_plan_id
                        AND     peg2.plan_id = peg1.plan_id
                        AND     peg2.pegging_id = peg1.end_pegging_id
                        AND     peg2.demand_id IN (-1, -2)
                        AND     d.demand_id = peg1.demand_id
                        AND     peg1.plan_id = d.plan_id
                        AND     d.sr_instance_id = peg1.sr_instance_id
                        AND     d.origination_type NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                        -- time_phased_atp
                        --AND     tp.sr_tp_id = peg1.organization_id
        		--AND	tp.partner_type = 3 -- bug2646304
                        --AND     tp.sr_instance_id = peg1.sr_instance_id
                        -- 2859130 AND     tp.sr_instance_id = cal.sr_instance_id
                        --AND     tp.calendar_code = cal.calendar_code
                        --AND     tp.calendar_exception_set_id = cal.exception_set_id
                        --AND     TRUNC(d.using_assembly_demand_date) = cal.calendar_date
                        GROUP BY
                                peg1.plan_id,
                                peg1.inventory_item_id,
                                peg1.organization_id,
                                peg1.sr_instance_id,
                                :def_num,
                                -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                                trunc(DECODE('||MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF||',
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(d.SCHEDULE_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),--plan by request date, promise date or schedule date
                                --cal.prior_date,
                                d.demand_id,
                                d.origination_type,
                                decode(d.origination_type, 1, to_char(d.disposition_id), d.order_number),
                                d.sales_order_line_id,
                                d.demand_source_type,--cmro
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
			        decode(d.order_date_type_code,2,d.request_date,
			           d.request_ship_date) -- Bug 3370201
        		)';
           END IF;
           -- time_phased_atp - project atp forward port

           msc_util.msc_log('After Generating the sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_insert_stmt, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing the sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing the cursor');

           msc_util.msc_log('after inserting item data into MSC_TEMP_ALLOC_DEMANDS table');

           commit;

           msc_util.msc_log('before creating indexes on temp demand table');
           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N1 ON ' || l_temp_table || '
                           --NOLOGGING
                           (plan_id, inventory_item_id, organization_id, sr_instance_id, demand_class, demand_date)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N2 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           sales_order_line_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N3 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           parent_demand_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N3');
           msc_util.msc_log('Done creating indexes on temp demand table');


           l_temp_table := 'MSC_TEMP_ALLOC_SUP_' || to_char(l_plan_id);

           SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
           INTO    l_tbspace, l_ind_tbspace
           --bug 2495962: Change refrence from dba_xxx to all_xxx tables
           --FROM    dba_tab_partitions t,
           --        dba_part_indexes i
           FROM    all_tab_partitions t,
                   all_part_indexes i
           WHERE   t.table_owner = l_msc_schema
           AND     t.table_name = 'MSC_ALLOC_SUPPLIES'
           AND     t.partition_name = 'ALLOC_SUPPLIES_' || to_char(l_plan_id)
           AND     i.owner (+) = t.table_owner
           AND     i.table_name (+) = t.table_name
           AND     rownum = 1;

           msc_util.msc_log('tb space : ' || l_tbspace);
           msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);

           --bug 6113544
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table
           || ' TABLESPACE ' || l_tbspace
           || ' PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)'
           || ' as select * from msc_alloc_supplies where 1=2 ';

        /*
           l_insert_stmt := 'CREATE TABLE ' || l_temp_table || '(
                                 PLAN_ID                    NUMBER           NOT NULL,
                                 INVENTORY_ITEM_ID          NUMBER           NOT NULL,
                                 ORGANIZATION_ID            NUMBER           NOT NULL,
                                 SR_INSTANCE_ID             NUMBER           NOT NULL,
                                 DEMAND_CLASS               VARCHAR2(30)      ,  --bug3272444
                                 SUPPLY_DATE                DATE             NOT NULL,
                                 PARENT_TRANSACTION_ID      NUMBER           NOT NULL,
                                 ALLOCATED_QUANTITY         NUMBER           NOT NULL,
                                 ORDER_TYPE                 NUMBER           NOT NULL,
                                 ORDER_NUMBER               VARCHAR2(240),
				 SCHEDULE_DESIGNATOR_ID	    NUMBER,
                                 SALES_ORDER_LINE_ID        NUMBER,
                                 OLD_SUPPLY_DATE            DATE,
                                 OLD_ALLOCATED_QUANTITY     NUMBER,
				 STEALING_FLAG		    NUMBER,
                                 CREATED_BY                 NUMBER           NOT NULL,
                                 CREATION_DATE              DATE             NOT NULL,
                                 LAST_UPDATED_BY            NUMBER           NOT NULL,
                                 LAST_UPDATE_DATE           DATE             NOT NULL,
                                 FROM_DEMAND_CLASS          VARCHAR2(80),  -- ssurendr 25-NOV-2002: added for alloc w/b
                                 SUPPLY_QUANTITY            NUMBER,        -- ssurendr 25-NOV-2002: added for alloc w/b
                                 ORIGINAL_ORDER_TYPE        NUMBER,        -- For time_phased_atp --bug3272444
                                 ORIGINAL_ITEM_ID           NUMBER,        -- For time_phased_atp --bug3272444
                                 CUSTOMER_ID                NUMBER,        -- For time_phased_atp
                                 SHIP_TO_SITE_ID            NUMBER,
                                 REFRESH_NUMBER             NUMBER,
                                 OLD_REFRESH_NUMBER         NUMBER,        --bug3272444
                                 ATO_MODEL_LINE_ID          NUMBER,
                               --ATO_MODEL_LINE_ID          NUMBER)        -- For time_phased_atp commented as part of cmro
                                 DEMAND_SOURCE_TYPE         NUMBER)        --cmro
                            TABLESPACE ' || l_tbspace || '
                            -- NOLOGGING
                            PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';
        */

           msc_util.msc_log('before creating table : ' || l_temp_table);
           BEGIN
              ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.create_table,
                   STATEMENT => l_insert_stmt,
                   OBJECT_NAME => l_temp_table);
              msc_util.msc_log('after creating table : ' || l_temp_table);

           EXCEPTION
              WHEN others THEN
                 msc_util.msc_log(sqlcode || ': ' || sqlerrm);
                 msc_util.msc_log('Exception of create table : ' || l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.drop_table,
                        STATEMENT =>  'DROP TABLE ' || l_temp_table,
                        OBJECT_NAME => l_temp_table);

                 msc_util.msc_log('After Drop table : ' ||l_temp_table);
                 msc_util.msc_log('Before exception create table : ' ||l_temp_table);

                 ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                        APPLICATION_SHORT_NAME => 'MSC',
                        STATEMENT_TYPE => ad_ddl.create_table,
                        STATEMENT => l_insert_stmt,
                        OBJECT_NAME => l_temp_table);
                 msc_util.msc_log('After exception create table : ' ||l_temp_table);
           END;

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
	   -- to move demand on non-working day to prior working day.

           -- cannot use append with other hints
           --l_insert_stmt := 'INSERT INTO /*+ APPEND */ ' || l_temp_table || '(
           l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                        plan_id,
                        inventory_item_id,
                        organization_id,
                        sr_instance_id,
                        demand_class,
                        supply_date,
                        allocated_quantity,
                        parent_transaction_id,
                        order_type,
                        order_number,
                        schedule_designator_id,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
                (
		SELECT	--5053818
			peg1.plan_id plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num) demand_class,
			peg1.supply_date,
			SUM(peg1.allocated_quantity) allocated_quantity,
                        peg1.transaction_id,
			peg1.order_type,
			peg1.order_number,
			peg1.schedule_designator_id,
                        :l_user_id created_by,
                        :l_sysdate creation_date,
                        :l_user_id last_updated_by,
                        :l_sysdate last_update_date,
			MIN(peg1.supply_quantity) supply_quantity  -- ssurendr 25-NOV-2002: added for alloc w/b
			-- min is used to select distinct values as supply_quantity would be
			-- repeating for the same transaction_id
		FROM    -- msc_supply_pegging_v peg1,
			(SELECT --5053818
                                        -- time_phased_atp parallel(tp,' || to_char(l_parallel_degree) || ')
                                        -- parallel(cal,' || to_char(l_parallel_degree) || ')
				peg2.plan_id,
				peg2.inventory_item_id,
				peg2.organization_id,
				peg2.sr_instance_id,
				NVL (d.demand_class, :def_num) demand_class,
				trunc(s.new_schedule_date) supply_date,
				-- cal.next_date supply_date,
				-- cal.calendar_date supply_date, -- 2859130
				peg2.allocated_quantity,
				peg2.transaction_id,
				s.order_type,
				s.order_number,
				s.schedule_designator_id,
				nvl(s.firm_quantity,s.new_order_quantity) supply_quantity -- rajjain 02/06/2003 Bug 2782882
				--peg2.supply_quantity  -- ssurendr 25-NOV-2002: added for alloc w/b
			FROM	msc_supplies s,
				msc_full_pegging peg2,
				msc_full_pegging peg1,
				msc_demands d
                                -- time_phased_atp msc_trading_partners tp
                                -- 2859130 msc_calendar_dates cal
			WHERE	peg2.plan_id = peg1.plan_id
			  AND	peg2.end_pegging_id = peg1.pegging_id
			  AND	d.plan_id = peg1.plan_id
			  AND	d.demand_id = peg1.demand_id
			  AND	d.sr_instance_id = peg1.sr_instance_id
			  AND	d.inventory_item_id = peg1.inventory_item_id
			  AND	s.plan_id = peg2.plan_id
			  AND	s.transaction_id = peg2.transaction_id
			  AND	s.sr_instance_id = peg2.sr_instance_id
                          -- time_phased_atp
                          --AND   tp.sr_tp_id = peg2.organization_id
			  --AND	tp.partner_type = 3 -- bug2646304
                          --AND   tp.sr_instance_id = peg2.sr_instance_id
                          -- 2859130 AND   tp.sr_instance_id = cal.sr_instance_id
                          --AND   tp.calendar_code = cal.calendar_code
                          --AND   tp.calendar_exception_set_id = cal.exception_set_id
                          --AND   TRUNC(s.new_schedule_date) = cal.calendar_date
                        ) peg1,
			msc_item_hierarchy_mv mv
		WHERE   peg1.plan_id = :p_plan_id
		AND     peg1.inventory_item_id = mv.inventory_item_id(+)
		AND     peg1.organization_id = mv.organization_id (+)
		AND     peg1.sr_instance_id = mv.sr_instance_id (+)
		AND     peg1.supply_date >=  mv.effective_date (+)
		AND     peg1.supply_date <=  mv.disable_date (+)
		AND	peg1.demand_class = mv.demand_class (+)
		AND     mv.level_id (+) = -1
		GROUP BY
			peg1.plan_id,
			peg1.inventory_item_id,
			peg1.organization_id,
			peg1.sr_instance_id,
			NVL(mv.demand_class, :def_num),
			peg1.supply_date,
                        peg1.transaction_id,
			peg1.order_type,
			peg1.order_number,
			peg1.schedule_designator_id,
                        :l_user_id,
                        :l_sysdate,
                        :l_user_id,
                        :l_sysdate)';

           msc_util.msc_log('After Generating first supplies sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_insert_stmt, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing first supplies sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing first supplies cursor');

           msc_util.msc_log('After inserting in msc_alloc_supplies part 1');

           -- parallel hint can't be used with union all. Use two query instead */

	   -- UNION ALL

	   -- 2623646 Modified to join with msc_trading_partners/ msc_calendar_dates
	   -- to move demand on non-working day to prior working day.

           /* time_phased_atp - project atp forward port
            * If the profile is set to 'Yes' then:
            *    o If supply has a demand class existing on allocation rule then
            *      allocate the supply to that demand class.
            *    o If supply has a demand class not present on allocation rule then
            *      allocate the supply to 'OTHER'.
            *    o If supply does not have a demand class present, allocate the supply
            *      to 'OTHER'.
            * Else: Allocate the supply to 'OTHER'*/
           IF l_excess_supply_by_dc = 'Y' THEN
                   l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                allocated_quantity,
                                parent_transaction_id,
                                order_type,
                                order_number,
                                schedule_designator_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                supply_quantity)
        		(
        	        SELECT	--5053818
                                pegging_v.plan_id plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num) demand_class,
                                pegging_v.supply_date,
                                SUM(pegging_v.allocated_quantity),
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
                                MIN(pegging_v.supply_quantity)
                        FROM
                                (SELECT  --5053818
                                        peg1.plan_id plan_id,
                                        peg1.inventory_item_id,
                                        peg1.organization_id,
                                        peg1.sr_instance_id,
                                        NVL(s.demand_class, :def_num) demand_class,
                                        trunc(s.new_schedule_date) supply_date,
                                        peg1.allocated_quantity,
                                        peg1.transaction_id,
                                        s.order_type,
                                        s.order_number,
                                        s.schedule_designator_id,
                                        nvl(s.firm_quantity,s.new_order_quantity) supply_quantity
                                FROM    msc_full_pegging peg2,
                                        msc_full_pegging peg1,
                                	msc_supplies s
                                WHERE   peg1.plan_id = :p_plan_id
                                AND     peg2.plan_id = peg1.plan_id
                                AND     peg2.pegging_id = peg1.end_pegging_id
                                AND     peg2.demand_id IN (-1, -2)
                                AND     s.plan_id = peg1.plan_id
                                AND     s.transaction_id = peg1.transaction_id
                                AND     s.sr_instance_id = peg1.sr_instance_id) pegging_v,
                                msc_item_hierarchy_mv mv
                        WHERE	pegging_v.inventory_item_id = mv.inventory_item_id(+)
                        AND     pegging_v.organization_id = mv.organization_id (+)
                        AND     pegging_v.sr_instance_id = mv.sr_instance_id (+)
                        AND     pegging_v.supply_date >=  mv.effective_date (+)
                        AND     pegging_v.supply_date <=  mv.disable_date (+)
                        AND	pegging_v.demand_class = mv.demand_class (+)
                        AND     mv.level_id (+) = -1
        		GROUP BY
                                pegging_v.plan_id,
                                pegging_v.inventory_item_id,
                                pegging_v.organization_id,
                                pegging_v.sr_instance_id,
                                NVL(mv.demand_class, :def_num),
                                pegging_v.supply_date,
                                pegging_v.transaction_id,
                                pegging_v.order_type,
                                pegging_v.order_number,
                                pegging_v.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';

           ELSE
                   -- cannot use append with other hints
                   --l_insert_stmt := 'INSERT INTO /*+ APPEND */ ' || l_temp_table || '(
                   l_insert_stmt := 'INSERT INTO ' || l_temp_table || '(
                                plan_id,
                                inventory_item_id,
                                organization_id,
                                sr_instance_id,
                                demand_class,
                                supply_date,
                                allocated_quantity,
                                parent_transaction_id,
                                order_type,
                                order_number,
                                schedule_designator_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
                        (
        		SELECT  --5053818
                                        -- time_phased_atp parallel(tp,' || to_char(l_parallel_degree) || ')
                                        --2859130 parallel(cal,' || to_char(l_parallel_degree) || ')
                                peg1.plan_id plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num demand_class,
        			trunc(s.new_schedule_date),
        			-- cal.next_date,
                                --cal.calendar_date, -- 2859130
        			SUM(peg1.allocated_quantity),
                                peg1.transaction_id,
        			s.order_type,
        			s.order_number,
        			s.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate,
        			MIN(nvl(s.firm_quantity,s.new_order_quantity))  -- rajjain 02/06/2003 Bug 2782882
        			--MIN(peg1.supply_quantity)  -- ssurendr 25-NOV-2002: added for alloc w/b
        			-- min is used to select distinct values as supply_quantity would be
        			-- repeating for the same transaction_id
        		FROM    msc_full_pegging peg2,
        		        msc_full_pegging peg1,
        			msc_supplies s
                                -- msc_trading_partners tp
                                -- msc_calendar_dates cal
        		WHERE   peg1.plan_id = :p_plan_id
        		AND     peg2.plan_id = peg1.plan_id
        		AND     peg2.pegging_id = peg1.end_pegging_id
        		AND     peg2.demand_id IN (-1, -2)
        		AND     s.plan_id = peg1.plan_id
        		AND     s.transaction_id = peg1.transaction_id
        		AND     s.sr_instance_id = peg1.sr_instance_id
                        -- time_phased_atp
                        --AND     tp.sr_tp_id = peg1.organization_id
        		--AND	tp.partner_type = 3 -- bug2646304
                        --AND     tp.sr_instance_id = peg1.sr_instance_id
                        -- 2859130 AND     tp.sr_instance_id = cal.sr_instance_id
                        --AND     tp.calendar_code = cal.calendar_code
                        --AND     tp.calendar_exception_set_id = cal.exception_set_id
                        --AND     TRUNC(s.new_schedule_date) = cal.calendar_date
        		GROUP BY
        			peg1.plan_id,
        		        peg1.inventory_item_id,
        		        peg1.organization_id,
        		        peg1.sr_instance_id,
        		        :def_num,
        			trunc(s.new_schedule_date),
        			-- cal.next_date, -- 2859130
                                peg1.transaction_id,
        			s.order_type,
        			s.order_number,
        			s.schedule_designator_id,
                                :l_user_id,
                                :l_sysdate,
                                :l_user_id,
                                :l_sysdate)';
           END IF;
           -- time_phased_atp - project atp forward port

           msc_util.msc_log('After Generating second supplies sql');

           -- Parse cursor handler for sql_stmt: Don't open as its already opened

           DBMS_SQL.PARSE(cur_handler, l_insert_stmt, DBMS_SQL.NATIVE);
           msc_util.msc_log('After parsing second supplies sql');

           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_user_id', l_user_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':l_sysdate', l_sysdate);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':p_plan_id', p_plan_id);
           DBMS_SQL.BIND_VARIABLE(cur_handler, ':def_num', '-1');
           msc_util.msc_log('after binding the variables');

           -- Execute the cursor
           rows_processed := DBMS_SQL.EXECUTE(cur_handler);
           msc_util.msc_log('After executing second supplies cursor');

           msc_util.msc_log('After inserting in msc_alloc_supplies part 2');
           commit;

           msc_util.msc_log('before creating indexes on temp supply table');
           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N1 ON ' || l_temp_table || '
                           -- NOLOGGING
                           (plan_id, inventory_item_id, organization_id, sr_instance_id, demand_class, supply_date)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N1');

           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N2 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           parent_transaction_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N2');

           -- 2623646
           l_sql_stmt_1 := 'CREATE INDEX ' || l_temp_table || '_N3 ON ' || l_temp_table || '
                           -- NOLOGGING
                           --Bug 3629191
                           (plan_id,
                           sales_order_line_id)
                           STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0) tablespace ' || l_ind_tbspace;

           msc_util.msc_log('Before index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                           APPLICATION_SHORT_NAME => 'MSC',
                           STATEMENT_TYPE => ad_ddl.create_index,
                           STATEMENT => l_sql_stmt_1,
                           OBJECT_NAME => l_temp_table);

           msc_util.msc_log('After index : ' || l_temp_table || '.' || l_temp_table || '_N3');

           msc_util.msc_log('Gather Table Stats for Allocated S/D Tables');

           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_ALLOC_DEM_' || to_char(l_plan_id), granularity => 'ALL');
           fnd_stats.gather_table_stats('MSC', 'MSC_TEMP_ALLOC_SUP_' || to_char(l_plan_id), granularity => 'ALL');

           msc_util.msc_log('swap partition for demands');
           l_partition_name := 'ALLOC_DEMANDS_' || to_char(l_plan_id);

           msc_util.msc_log('Partition name for msc_alloc_demands table : ' || l_partition_name);

           -- swap partiton for supplies and demand part

           l_sql_stmt := 'ALTER TABLE msc_alloc_demands EXCHANGE PARTITION ' || l_partition_name  ||
           ' with table MSC_TEMP_ALLOC_DEM_'|| to_char(l_plan_id) ||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table msc_alloc_demands');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ALLOC_DEMANDS');
       	   END;

           msc_util.msc_log('swap partition for supplies');
           l_partition_name := 'ALLOC_SUPPLIES_' || to_char(l_plan_id);

           msc_util.msc_log('Partition name for msc_alloc_supplies table : ' || l_partition_name);

           l_sql_stmt := 'ALTER TABLE msc_alloc_supplies EXCHANGE PARTITION ' || l_partition_name  ||
           ' with table MSC_TEMP_ALLOC_SUP_'|| to_char(l_plan_id) ||
           ' including indexes without validation';

           BEGIN
        	   msc_util.msc_log('Before alter table msc_alloc_supplies');
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ALLOC_SUPPLIES');
       	   END;

	   msc_util.msc_log('Call procedure clean_temp_tables');

	   -- clean temp tables after exchanging partitions
	   clean_temp_tables(l_applsys_schema, l_plan_id, p_plan_id, NULL);

	   msc_util.msc_log('After procedure clean_temp_tables');

	END IF; -- IF l_share_partition = 'Y'

	--5027568
	--insert reservation_records to msc_alloc_demands.
	msc_util.msc_log('inserting reservation rows in msc_alloc_demands');
	INSERT INTO MSC_ALLOC_DEMANDS(
			plan_id,
			inventory_item_id,
			organization_id,
			sr_instance_id,
			demand_class,
			demand_date,
			allocated_quantity,
			parent_demand_id,
			origination_type,
			order_number,
			sales_order_line_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			demand_quantity
                        )
        (SELECT
            plan_id,
            USING_ASSEMBLY_ITEM_ID,
            ORGANIZATION_ID,
            SR_INSTANCE_ID,
            NVL(DEMAND_CLASS, -1),
            TRUNC(SYSDATE),
            using_requirement_quantity,
            demand_id,
            origination_type,
            ORDER_NUMBER,
            SALES_ORDER_LINE_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            using_requirement_quantity
            from msc_demands
            where plan_id = p_plan_id
            and origination_type = -100
            and using_requirement_quantity <> 0
            );
	msc_util.msc_log('inserted reservation rows in msc_alloc_demands :' || SQL%ROWCOUNT);

        BEGIN
            update msc_plans
            set    summary_flag = 3
            where  plan_id = p_plan_id;
        END;

	RETCODE := G_SUCCESS;
	commit;

	msc_util.msc_log('End procedure post_plan_allocation');

EXCEPTION
       WHEN OTHERS THEN
            msc_util.msc_log('Inside main exception of post_plan_allocation');
            msc_util.msc_log(sqlerrm);
            ERRBUF := sqlerrm;

            BEGIN
               update msc_plans
               set    summary_flag = 1
               where  plan_id = p_plan_id;
               commit;
            END;

            RETCODE := G_ERROR;
            IF (l_share_partition = 'Y') THEN
               ROLLBACK;
            ELSE
	       msc_util.msc_log('Call procedure clean_temp_tables in exception');

	       -- clean temp tables after exchanging partitions
	       IF l_plan_id IS NOT NULL THEN
	          clean_temp_tables(l_applsys_schema, l_plan_id, p_plan_id, NULL);
	       END IF;

	       msc_util.msc_log('After procedure clean_temp_tables in exception');
            END IF;
END post_plan_allocation;

-- ngoel 5/7/2002, added new API to be called from planning process to launch concurrent program
-- for post-plan process for summary/ pre-allocation process.

procedure atp_post_plan_proc(
        p_plan_id               IN      NUMBER,
        p_alloc_mode            IN      NUMBER := 0,
        p_summary_mode          IN      NUMBER := 0,
        x_retcode		OUT	NoCopy NUMBER,
        x_errbuf		OUT	NoCopy VARCHAR2
)
IS
l_count                         NUMBER;
l_inv_ctp                       NUMBER;
l_alloc_atp                     VARCHAR2(1);
l_class_hrchy                   NUMBER;
l_alloc_method                  NUMBER;
l_enable_summary_mode           VARCHAR2(1);
-- Bug 3491498, this variable is not being used anymore after timephased ATP changes
--l_submit_request                VARCHAR2(1) := 'N';
l_request_id			NUMBER;

-- 24x7 ATP
l_copy_plan_id                  NUMBER;

BEGIN
    msc_util.msc_log('Begin procedure atp_post_plan_proc');
    msc_util.msc_log('plan : ' || p_plan_id);
    msc_util.msc_log('Allocation Mode : ' || p_alloc_mode);
    msc_util.msc_log('Summary Mode : ' || p_summary_mode);

    x_retcode := G_SUCCESS;

    l_inv_ctp := NVL(FND_PROFILE.value('INV_CTP'), 5);

    msc_util.msc_log('inv_ctp := ' || l_inv_ctp);

    /* time_phased_atp changes begin
       Always call atp post plan processing conc prog if PDS
    IF l_enable_summary_mode = 'Y' AND l_inv_ctp = 4 AND l_alloc_atp = 'N' THEN
       l_submit_request := 'Y';
    ELSIF l_inv_ctp = 4 AND l_alloc_atp = 'Y' AND l_class_hrchy = 1 AND l_alloc_method = 1 THEN
       l_submit_request := 'Y';
    END IF;

    -- Bug 3491498, this variable is not being used anymore after timephased ATP changes
    IF l_inv_ctp = 4 THEN
       l_submit_request := 'Y';
    END IF;*/
    -- time_phased_atp changes end

    ---bug 3274373
    IF l_inv_ctp = 4 THEN

	   -- Bug 3491498, check if plan is ATPable. Moved up to check it prior to refresh MSC_ATP_PLAN_SN
       SELECT count(*)
       INTO   l_count
       FROM   msc_plans plans,
              msc_designators desig
       WHERE  desig.inventory_atp_flag = 1
       AND    plans.plan_id = p_plan_id
       AND    plans.compile_designator = desig.designator
       AND    plans.sr_instance_id = desig.sr_instance_id
       AND    plans.organization_id = desig.organization_id
       AND    plans.plan_completion_date is not null
       AND    plans.data_completion_date is not null
       -- IO Perf:3693983: Don't Launch ATP Post Plan Processes for IO Plans
       AND    plans.plan_type <> 4;

       msc_util.msc_log('Count	 for plan : ' || l_count);

       IF l_count > 0 THEN
          msc_util.msc_log('Before refreshing MSC_ATP_PLAN_SN');
          l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'MSC',
                                        'MSCREFMV',
                                        NULL,   -- description
                                        NULL,   -- start time
                                        FALSE,  -- sub request
                                        'MSC_ATP_PLAN_SN',
                                        724);
          msc_util.msc_log('Request id for refreshing snapshot := ' || l_request_id);
          msc_util.msc_log('After refreshing MSC_ATP_PLAN_SN');
       END IF; 	--IF l_count = 0 THEN
    END IF;

    -- Bug 3491498, moved prior to call to refresh MSC_ATP_PLAN_SN
/*
    SELECT count(*)
    INTO   l_count
    FROM   msc_plans plans,
           msc_designators desig
    WHERE  desig.inventory_atp_flag = 1
    AND    plans.plan_id = p_plan_id
    AND    plans.compile_designator = desig.designator
    AND    plans.sr_instance_id = desig.sr_instance_id
    AND    plans.organization_id = desig.organization_id
    AND    plans.plan_completion_date is not null
    AND    plans.data_completion_date is not null;

    msc_util.msc_log('Count for plan : ' || l_count);
    msc_util.msc_log('l_submit_request : ' || l_submit_request);
*/

    -- 24x7 ATP
    BEGIN
        select  nvl (copy_plan_id, -1)
        into    l_copy_plan_id
        from    msc_plans
        where   plan_id = p_plan_id
        -- IO Perf:3693983: Don't Launch ATP Post Plan Processes for IO Plans
        AND     plan_type <> 4;
    EXCEPTION
        when others then
            l_copy_plan_id := -1;
    END;

    if (l_copy_plan_id > 0) then
        -- plan copy exists . force the execution of other things.
        l_count := 1;
        msc_util.msc_log ('Plan determined to be a 24x7 plan');
    end if;

    IF l_count = 0 THEN
       UPDATE msc_plans
       SET    summary_flag = 1
       WHERE  plan_id = p_plan_id;

	   COMMIT;
       RETURN;
    END IF;

    BEGIN
	msc_util.msc_log('before launching concurrent program');
        -- Bug 3292949
        UPDATE msc_plans
        SET    summary_flag = 1
        WHERE  plan_id = p_plan_id;
        msc_util.msc_log('Reset summary flag back to default:1 before conc prg launch');
         -- End Bug 3292949
        l_request_id := FND_REQUEST.SUBMIT_REQUEST(
					'MSC',
					'MSC_ATP_PDS_SUMM',
					NULL,   -- description
					NULL,   -- start time
					FALSE,  -- sub request
					p_plan_id,
					2); -- Bug 3478888 Pass calling module as 2 as
					    -- ATP Post Plan Processing is called from planning

	UPDATE msc_plans       /* for 24x7 ATP */
        SET     request_id = l_request_id
        WHERE   plan_id = p_plan_id;

	COMMIT;

	msc_util.msc_log('Request ID :' || l_request_id);

    EXCEPTION
        WHEN OTHERS THEN
             msc_util.msc_log ('Conc. program error : ' || sqlcode || ':' || sqlerrm);
	     x_retcode := G_ERROR;
	     x_errbuf := sqlerrm;
    END;
END atp_post_plan_proc;

/*
 * dsting 7/24/2002
 *
 * Deletes entries from mrp_atp_schedule_temp and mrp_atp_details_temp
 * older than p_hours old
 *
 */
PROCEDURE ATP_Purge_MRP_Temp(
  ERRBUF		OUT	NoCopy VARCHAR2,
  RETCODE		OUT	NoCopy NUMBER,
  p_hours		IN	NUMBER
)
IS
l_retain_date		DATE;
-- rajjain 12/20/2002
l_spid                          VARCHAR2(12);
l_mrp_schema             	VARCHAR2(30); --bug3545959
l_msc_schema             	VARCHAR2(30); --bug3940999
BEGIN

        -- Bug 3304390 Disable Trace
        -- Deleted Related Code.

	RETCODE := G_SUCCESS;

	msc_util.msc_log('********** MRP_ATP_Purge_Temp **********');
	msc_util.msc_log('p_hours: '      || p_hours );

	IF NVL(p_hours,0) > 0 THEN

		l_retain_date := sysdate - p_hours/24;

		msc_util.msc_log('Delete records older than l_retain_date ' ||
					   to_char(l_retain_date, 'DD:MM:YYYY hh24:mi:ss'));
		msc_util.msc_log('Now sysdate: ' ||
					   to_char(sysdate, 'DD:MM:YYYY hh24:mi:ss'));


		DELETE FROM mrp_atp_schedule_temp
		WHERE last_update_date < l_retain_date;

		msc_util.msc_log('Records Deleted from mrp_atp_schedule_temp : ' ||
					  SQL%ROWCOUNT);

                --3670695: issue commit so that rollback segment is freed
                commit;

		DELETE FROM mrp_atp_details_temp
		WHERE last_update_date < l_retain_date;

		msc_util.msc_log('Records Deleted from mrp_atp_details_temp : ' ||
					  SQL%ROWCOUNT);
                --bug3940999
                DELETE FROM msc_atp_src_profile_temp
		WHERE last_update_date < l_retain_date;

		msc_util.msc_log('Records Deleted from msc_atp_src_profile_temp : ' ||
					  SQL%ROWCOUNT);

	ELSE
		msc_util.msc_log('completely purging temp tables');
                --bug3545959 start
	        SELECT  a.oracle_username
      	        INTO    l_mrp_schema
      	        FROM    FND_ORACLE_USERID a,
                        FND_PRODUCT_INSTALLATIONS b
      	        WHERE   a.oracle_id = b.oracle_id
      	        AND     b.application_id = 704;

      	        msc_util.msc_log('l_mrp_schema: '      || l_mrp_schema );
      	        --bug3545959 end
		EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_mrp_schema ||'.mrp_atp_schedule_temp';
		EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_mrp_schema ||'.mrp_atp_details_temp';

		--bug3940999
		SELECT  a.oracle_username
      	        INTO    l_msc_schema
      	        FROM    FND_ORACLE_USERID a,
                        FND_PRODUCT_INSTALLATIONS b
      	        WHERE   a.oracle_id = b.oracle_id
      	        AND     b.application_id = 724;

      	        msc_util.msc_log('l_msc_schema: '      || l_msc_schema );

      	        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_msc_schema ||'.msc_atp_src_profile_temp';

	END IF;

	commit;
EXCEPTION
    WHEN others THEN
         msc_util.msc_log('Error while purging temp tables : ' ||
						sqlcode || ' : ' || sqlerrm);
         rollback;
END ATP_Purge_MRP_Temp;


-- New procedure for summary enhancement
PROCEDURE LOAD_PLAN_SUMMARY_SD (p_plan_id               IN NUMBER,
                                p_share_partition       IN varchar2,
                                p_optimized_plan        IN NUMBER,  -- 1:Yes, 2:No
                                p_full_refresh          IN NUMBER,  -- 1:Yes, 2:No
                                p_time_phased_pf        IN NUMBER,  -- 1:Yes, 2:No
                                p_plan_type             IN NUMBER,  -- ATP4drp
                                p_last_refresh_number   IN NUMBER,
                                p_new_refresh_number    IN NUMBER,
                                p_sys_date              IN DATE)
IS
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_inventory_item_id_tab     MRP_ATP_PUB.number_arr;
    l_supplier_id_tab           MRP_ATP_PUB.number_arr;
    l_supplier_site_id_tab      MRP_ATP_PUB.number_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;
    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_inventory_item_id_tab MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_supplier_id_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_supplier_site_id_tab  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    -- ATPR4drp
    l_plan_type                 NUMBER;
BEGIN
    msc_util.msc_log('************ LOAD_PLAN_SUMMARY_SD begin *************');
    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'p_plan_id         - ' || p_plan_id);
    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'p_share_partition - ' || p_share_partition);
    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'p_optimized_plan  - ' || p_optimized_plan);
    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'p_full_refresh    - ' || p_full_refresh);

    -- ATP4drp changes begin
    -- print plan_type

    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Plan Type p_plan_type -> ' || p_plan_type);
    msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');

    -- END ATP4drp


    IF p_full_refresh = 1 THEN
        msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside full summation');

        -- first delete existing data. p_share_partition = 'N' data has already been deleted
        IF p_share_partition = 'Y' THEN

            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside shared part_partition');
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'before deleteing data from the table');

            DELETE MSC_ATP_SUMMARY_SD where plan_id = p_plan_id;
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'After deleting data from the table');

        END IF; --- IF share_partition = 'Y'

        -- Now insert new data
        IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside demand priority allocated ATP');
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Insert data into sd table');

            load_sd_full_alloc(p_plan_id, p_sys_date);

            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'After inserting into MSC_ATP_SUMMARY_SD');
        ELSE -- IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Unallocated ATP');
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Insert data into sd table');

            IF nvl(p_optimized_plan, 2) <> 1 THEN
                msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Unconstrained plan');
                IF p_time_phased_pf = 1 THEN
                    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Time phased pf setup exists.');
                    load_sd_full_unalloc_unopt_pf(p_plan_id, p_sys_date);
                ELSE
                    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Time phased pf setup does not exist.');
                    load_sd_full_unalloc_unopt(p_plan_id, p_sys_date);
                END IF;
            ELSE
                msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Constrained plan');
                IF p_time_phased_pf = 1 THEN
                    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Time phased pf setup exists.');
                    load_sd_full_unalloc_opt_pf(p_plan_id, p_sys_date);
                ELSE
                    msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Time phased pf setup does not exist.');
                    -- ATP4drp Call DRP specific summary
                    IF (p_plan_type = 5) THEN
                       msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Call FULL Summary for DRP plan.');
                       msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                       MSC_ATP_DRP.load_sd_full_drp(p_plan_id, p_sys_date);
                    ELSE -- Call rest summary
                       load_sd_full_unalloc_opt(p_plan_id, p_sys_date);
                    END IF;
                    -- End ATP4drp
                END IF;
            END IF;

            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'After inserting into MSC_ATP_SUMMARY_SD');
        END IF; -- IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN

	ELSE --- IF p_full_refresh = 1 THEN
        msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside incremental summation');

        IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside demand priority allocated ATP');
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Insert data into sd table');

            load_sd_net_alloc(p_plan_id, p_last_refresh_number, p_new_refresh_number, p_sys_date);

            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'After inserting into MSC_ATP_SUMMARY_SD');
        ELSE -- IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Inside unallocated ATP');
            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Insert data into sd table');

            -- ATP4drp Call DRP specific summary
            IF (p_plan_type = 5) THEN
                msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'Call NET Summary for DRP plan.');
                MSC_ATP_DRP.load_sd_net_drp(p_plan_id, p_last_refresh_number, p_new_refresh_number, p_sys_date);
            ELSE -- Call rest summary
                load_sd_net_unalloc(p_plan_id, p_last_refresh_number, p_new_refresh_number, p_time_phased_pf, p_sys_date);
            END IF;
            -- ATP4drp

            msc_util.msc_log('LOAD_PLAN_SUMMARY_SD: ' || 'After inserting into MSC_ATP_SUMMARY_SD');
        END IF; -- IF G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1 THEN

	END IF; --- IF p_full_refresh = 1 THEN

END LOAD_PLAN_SUMMARY_SD;

-- summary enhancement : private procedure for full summation of supply/demand
--                       for unconstrained plans for unallocated cases if no time
--                       phased PF ATP setup exist for the plan
PROCEDURE LOAD_SD_FULL_UNALLOC_UNOPT(p_plan_id  IN NUMBER,
                                     p_sys_date IN DATE)
IS
    l_user_id NUMBER;
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_UNOPT Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
            --Bug 6046524 added index hint for performance improvement.
    from   (SELECT /*+ ORDERED index(C,MSC_CALENDAR_DATES_U1)*/
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- TRUNC(C.PRIOR_DATE) SD_DATE,
                    C.CALENDAR_DATE SD_DATE, -- 2859130
                    -1* DECODE(D.ORIGINATION_TYPE,
                               4, D.DAILY_DEMAND_RATE,
                                  D.USING_REQUIREMENT_QUANTITY) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_TRADING_PARTNERS P,
                    MSC_DEMANDS D,
                    MSC_CALENDAR_DATES C
            WHERE   I.ATP_FLAG = 'Y'
            AND     I.PLAN_ID = p_plan_id
            AND     D.PLAN_ID = I.PLAN_ID
            AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
                    -- 1243985
            AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                    -- Bug 1530311, forecast to be excluded
            AND     C.CALENDAR_CODE = P.CALENDAR_CODE
            AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
            AND     C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    -- since we store repetitive schedule demand in different ways for
                    -- ods (total quantity on start date) and pds  (daily quantity from
                    -- start date to end date), we need to make sure we only select work day
                    -- for pds's repetitive schedule demand.
                    -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
            AND     C.CALENDAR_DATE
                        BETWEEN
                        TRUNC(DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                     2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                        NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))
                        AND
                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                  DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                     2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                        NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))--plan by request date, promise date or schedule date
            AND     ((D.ORIGINATION_TYPE = 4 AND C.SEQ_NUM IS NOT NULL) OR
                    (D.ORIGINATION_TYPE  <> 4))
            AND     I.ORGANIZATION_ID = P.SR_TP_ID
            AND     I.SR_INSTANCE_ID  = P.SR_INSTANCE_ID
            AND     P.PARTNER_TYPE    = 3
            AND     D.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

    --Bug 6046524 added index hint for performance improvement.
            SELECT  /*+ ORDERED index(C,MSC_CALENDAR_DATES_U1)*/
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- TRUNC(C.NEXT_DATE) SD_DATE, -- 2859130
                    C.CALENDAR_DATE SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_TRADING_PARTNERS P,
                    MSC_SUPPLIES S,
                    MSC_CALENDAR_DATES C
            WHERE   I.ATP_FLAG = 'Y'
            AND     I.PLAN_ID = p_plan_id
            AND     S.PLAN_ID = I.PLAN_ID
            AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
                    -- Exclude Cancelled Supplies 2460645
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND     C.CALENDAR_CODE = P.CALENDAR_CODE
            AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
            AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
            AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
            AND     TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                           NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
            AND     I.ORGANIZATION_ID = P.SR_TP_ID
            AND     I.SR_INSTANCE_ID  = P.SR_INSTANCE_ID
            AND     P.PARTNER_TYPE    = 3
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY plan_id, inventory_item_id,organization_id, sr_instance_id,demand_class, sd_date,
            last_update_date, last_updated_by, creation_date, created_by );

    msc_util.msc_log('LOAD_SD_FULL_UNALLOC_UNOPT: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_UNOPT End ********');

END LOAD_SD_FULL_UNALLOC_UNOPT;


-- summary enhancement : private procedure for full summation of supply/demand
--                       for unconstrained plans for unallocated cases if time
--                       phased PF ATP setup exists for the plan
PROCEDURE LOAD_SD_FULL_UNALLOC_UNOPT_PF(p_plan_id  IN NUMBER,
                                        p_sys_date IN DATE)
IS
    l_user_id NUMBER;
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_UNOPT_PF Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    from   (SELECT /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- TRUNC(C.PRIOR_DATE) SD_DATE,
                    C.CALENDAR_DATE SD_DATE, -- 2859130
                    -1* DECODE(D.ORIGINATION_TYPE,
                               4, D.DAILY_DEMAND_RATE,
                                  D.USING_REQUIREMENT_QUANTITY) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_TRADING_PARTNERS P,
                    MSC_DEMANDS D,
                    MSC_CALENDAR_DATES C
            WHERE   I.ATP_FLAG = 'Y'
            AND     I.PLAN_ID = p_plan_id
            AND     D.PLAN_ID = I.PLAN_ID
            AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
                    -- 1243985
            AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                    -- Bug 1530311, forecast to be excluded
            AND     C.CALENDAR_CODE = P.CALENDAR_CODE
            AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
            AND     C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    -- since we store repetitive schedule demand in different ways for
                    -- ods (total quantity on start date) and pds  (daily quantity from
                    -- start date to end date), we need to make sure we only select work day
                    -- for pds's repetitive schedule demand.
                    -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
            AND     C.CALENDAR_DATE
                        BETWEEN TRUNC(DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))
                        AND     TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                          DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                             2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                                NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))--plan by request date, promise date or schedule date
            AND     ((D.ORIGINATION_TYPE = 4 AND C.SEQ_NUM IS NOT NULL) OR
                    (D.ORIGINATION_TYPE  <> 4))
            AND     I.ORGANIZATION_ID = P.SR_TP_ID
            AND     I.SR_INSTANCE_ID  = P.SR_INSTANCE_ID
            AND     P.PARTNER_TYPE    = 3
            AND     D.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
            AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

            UNION ALL

            SELECT  /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- TRUNC(C.NEXT_DATE) SD_DATE, -- 2859130
                    C.CALENDAR_DATE SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    MSC_TRADING_PARTNERS P,
                    MSC_SUPPLIES S,
                    MSC_CALENDAR_DATES C
            WHERE   I.ATP_FLAG = 'Y'
            AND     I.PLAN_ID = p_plan_id
            AND     S.PLAN_ID = I.PLAN_ID
            AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
                    -- Exclude Cancelled Supplies 2460645
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND     C.CALENDAR_CODE = P.CALENDAR_CODE
            AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
            AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
            AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
            AND     TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                           NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
            AND     I.ORGANIZATION_ID = P.SR_TP_ID
            AND     I.SR_INSTANCE_ID  = P.SR_INSTANCE_ID
            AND     P.PARTNER_TYPE    = 3
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
            AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

            UNION ALL

            SELECT  /*+ ORDERED */
                    AD.plan_id,
                    AD.sr_instance_id,
                    AD.organization_id,
                    AD.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(AD.demand_date) SD_DATE,
                    -1 * AD.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_DEMANDS AD
            WHERE   AD.PLAN_ID = p_plan_id
            AND     AD.allocated_quantity <> 0
            AND     AD.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  /*+ ORDERED */
                    SA.plan_id,
                    SA.sr_instance_id,
                    SA.organization_id,
                    SA.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(SA.supply_date) SD_DATE,
                    SA.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_SUPPLIES SA
            WHERE   SA.PLAN_ID = p_plan_id
            AND     SA.allocated_quantity <> 0
            AND     SA.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY plan_id, inventory_item_id,organization_id, sr_instance_id,demand_class, sd_date,
            last_update_date, last_updated_by, creation_date, created_by );

    msc_util.msc_log('LOAD_SD_FULL_UNALLOC_UNOPT_PF: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_UNOPT_PF End ********');

END LOAD_SD_FULL_UNALLOC_UNOPT_PF;


-- summary enhancement : private procedure for full summation of supply/demand
--                       for constrained plans for unallocated cases if no time
--                       phased PF ATP setup exist for the plan
PROCEDURE LOAD_SD_FULL_UNALLOC_OPT(p_plan_id  IN NUMBER,
                                   p_sys_date IN DATE)
IS
    l_user_id NUMBER;
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_OPT Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    from   (SELECT  /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                    TRUNC(DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                 2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                    NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) SD_DATE,
                                    --plan by request date, promise date or schedule date -- 2859130
                    -1* D.USING_REQUIREMENT_QUANTITY SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    -- MSC_TRADING_PARTNERS P,  -- Removed with summary enhancement changes
                                                -- Not required as calendar has been removed
                    MSC_DEMANDS D
            WHERE   I.ATP_FLAG          = 'Y'
            AND     I.PLAN_ID           = p_plan_id
            AND     D.PLAN_ID           = I.PLAN_ID
            AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
            --AND   I.ORGANIZATION_ID   = P.SR_TP_ID        -- Removed with summary enhancement
            --AND   I.SR_INSTANCE_ID    = P.SR_INSTANCE_ID  -- changes. Not required as calendar
            --AND   P.PARTNER_TYPE      = 3                 -- has been removed
            AND     D.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    -- MSC_TRADING_PARTNERS P,  -- Removed with summary enhancement changes
                                                -- Not required as calendar has been removed
                    MSC_SUPPLIES S
            WHERE   I.ATP_FLAG          = 'Y'
            AND     I.PLAN_ID           = p_plan_id
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            --AND   I.ORGANIZATION_ID   = P.SR_TP_ID        -- Removed with summary enhancement
            --AND   I.SR_INSTANCE_ID    = P.SR_INSTANCE_ID  -- changes. Not required as calendar
            --AND   P.PARTNER_TYPE      = 3                 -- has been removed
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY plan_id, inventory_item_id,organization_id, sr_instance_id, demand_class, sd_date,
             last_update_date, last_updated_by, creation_date, created_by );

    msc_util.msc_log('LOAD_SD_FULL_UNALLOC_OPT: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_OPT End ********');

END LOAD_SD_FULL_UNALLOC_OPT;


-- summary enhancement : private procedure for full summation of supply/demand
--                       for constrained plans for unallocated cases if time
--                       phased PF ATP setup exists for the plan
PROCEDURE LOAD_SD_FULL_UNALLOC_OPT_PF(p_plan_id  IN NUMBER,
                                      p_sys_date IN DATE)
IS
    l_user_id NUMBER;
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_OPT_PF Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    from   (SELECT  /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    -- Bug 3574164 DMD_SATISFIED_DATE IS CHANGED TO PLANNED_SHIP_DATE.
                    TRUNC(DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                 2, NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE),
                                    NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) SD_DATE,
                                    --plan by request date, promise date or schedule date -- 2859130
                    -1* D.USING_REQUIREMENT_QUANTITY SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    -- MSC_TRADING_PARTNERS P,  -- Removed with summary enhancement changes
                                                -- Not required as calendar has been removed
                    MSC_DEMANDS D
            WHERE   I.ATP_FLAG          = 'Y'
            AND     I.PLAN_ID           = p_plan_id
            AND     D.PLAN_ID           = I.PLAN_ID
            AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
            --AND   I.ORGANIZATION_ID   = P.SR_TP_ID        -- Removed with summary enhancement
            --AND   I.SR_INSTANCE_ID    = P.SR_INSTANCE_ID  -- changes. Not required as calendar
            --AND   P.PARTNER_TYPE      = 3                 -- has been removed
            AND     D.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
            AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

            UNION ALL

            SELECT  /*+ ORDERED */
                    I.plan_id plan_id,
                    I.sr_instance_id,
                    I.organization_id,
                    I.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_SYSTEM_ITEMS I,
                    -- MSC_TRADING_PARTNERS P,  -- Removed with summary enhancement changes
                                                -- Not required as calendar has been removed
                    MSC_SUPPLIES S
            WHERE   I.ATP_FLAG          = 'Y'
            AND     I.PLAN_ID           = p_plan_id
            AND     S.PLAN_ID           = I.PLAN_ID
            AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0
            --AND   I.ORGANIZATION_ID   = P.SR_TP_ID        -- Removed with summary enhancement
            --AND   I.SR_INSTANCE_ID    = P.SR_INSTANCE_ID  -- changes. Not required as calendar
            --AND   P.PARTNER_TYPE      = 3                 -- has been removed
            AND     S.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
            AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

            UNION ALL

            SELECT  /*+ ORDERED */
                    AD.plan_id,
                    AD.sr_instance_id,
                    AD.organization_id,
                    AD.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(AD.demand_date) SD_DATE,
                    -1 * AD.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_DEMANDS AD
            WHERE   AD.PLAN_ID = p_plan_id
            AND     AD.allocated_quantity <> 0
            AND     AD.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  /*+ ORDERED */
                    SA.plan_id,
                    SA.sr_instance_id,
                    SA.organization_id,
                    SA.inventory_item_id,
                    '@@@' demand_class,
                    TRUNC(SA.supply_date) SD_DATE,
                    SA.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_SUPPLIES SA
            WHERE   SA.PLAN_ID = p_plan_id
            AND     SA.allocated_quantity <> 0
            AND     SA.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY plan_id, inventory_item_id,organization_id, sr_instance_id, demand_class, sd_date,
             last_update_date, last_updated_by, creation_date, created_by );

    msc_util.msc_log('LOAD_SD_FULL_UNALLOC_OPT_PF: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_UNALLOC_OPT_PF End ********');

END LOAD_SD_FULL_UNALLOC_OPT_PF;


-- summary enhancement : private procedure for full summation of supply/demand
--                       for allocated cases. separate procedures for PF/non-PF
--                       cases are not required because we always select from
--                       alloc tables. separate procedures for opt/unopt not required
--                       because data in alloc tables is populated using pegging and
--                       pegging for repetitive schedules would not have been generated
--                       on non-working days.
PROCEDURE LOAD_SD_FULL_ALLOC(p_plan_id  IN NUMBER,
                             p_sys_date IN DATE)
IS
    l_user_id  number;
BEGIN

    msc_util.msc_log('******** LOAD_SD_FULL_ALLOC Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SD (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
   (SELECT  plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            demand_class,
            SD_DATE,
            sum(sd_qty),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    from   (SELECT  /*+ ORDERED */
                    AD.plan_id,
                    AD.sr_instance_id,
                    AD.organization_id,
                    AD.inventory_item_id,
                    AD.demand_class,
                    TRUNC(AD.demand_date) SD_DATE,
                    -1 * AD.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_DEMANDS AD
            WHERE   AD.PLAN_ID = p_plan_id
            AND     AD.allocated_quantity <> 0
            AND     AD.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  /*+ ORDERED */
                    SA.plan_id,
                    SA.sr_instance_id,
                    SA.organization_id,
                    SA.inventory_item_id,
                    SA.demand_class,
                    TRUNC(SA.supply_date) SD_DATE,
                    SA.allocated_quantity SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_ALLOC_SUPPLIES SA
            WHERE   SA.PLAN_ID = p_plan_id
            AND     SA.allocated_quantity <> 0
            AND     SA.refresh_number IS NULL   -- consider only planning records in full summation - summary enhancement
           )
    GROUP BY plan_id, inventory_item_id, organization_id, sr_instance_id,demand_class, sd_date,
            last_update_date, last_updated_by, creation_date, created_by
    HAVING sum(SD_QTY) <> 0);

    msc_util.msc_log('LOAD_SD_FULL_ALLOC: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SD_FULL_ALLOC End ********');

END LOAD_SD_FULL_ALLOC;


-- summary enhancement : private procedure for net summation of supply/demand
--                       for unallocated cases. separate procedures for opt/unopt not required
--                       because we bother only about ATP generated records.
PROCEDURE LOAD_SD_NET_UNALLOC(p_plan_id             IN NUMBER,
                              p_last_refresh_number IN NUMBER,
                              p_new_refresh_number  IN NUMBER,
                              p_time_phased_pf      IN NUMBER, -- 1:Yes, 2:No
                              p_sys_date            IN DATE)
IS
    l_user_id   number;
    j           pls_integer;
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_organization_id_tab       MRP_ATP_PUB.number_arr;
    l_inventory_item_id_tab     MRP_ATP_PUB.number_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;
    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_organization_id_tab   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_inventory_item_id_tab MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    CURSOR c_net_sd (p_plan_id             IN NUMBER,
                     p_last_refresh_number IN NUMBER,
                     p_new_refresh_number  IN NUMBER)
    IS
        SELECT  sr_instance_id,
                organization_id,
                inventory_item_id,
                SD_DATE,
                sum(sd_qty)
                -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
        from   (SELECT  I.sr_instance_id,
                        I.organization_id,
                        I.inventory_item_id,
                        TRUNC(DECODE(D.RECORD_SOURCE,
                                     2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                        DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                               2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),
                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) SD_DATE,
                                                  --plan by request date, promise date or schedule date
                        decode(D.USING_REQUIREMENT_QUANTITY,            -- Consider unscheduled orders as dummy supplies
                               0, D.OLD_DEMAND_QUANTITY,                -- For summary enhancement
                                  -1 * D.USING_REQUIREMENT_QUANTITY)  SD_QTY
                FROM    MSC_SYSTEM_ITEMS I,
                        MSC_DEMANDS D
                WHERE   I.ATP_FLAG          = 'Y'
                AND     I.PLAN_ID           = p_plan_id
                AND     D.PLAN_ID           = I.PLAN_ID
                AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
                AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
                AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                AND     D.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number

                UNION ALL

                SELECT  I.sr_instance_id,
                        I.organization_id,
                        I.inventory_item_id,
                        TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
                FROM    MSC_SYSTEM_ITEMS I,
                        MSC_SUPPLIES S
                WHERE   I.ATP_FLAG          = 'Y'
                AND     I.PLAN_ID           = p_plan_id
                AND     S.PLAN_ID           = I.PLAN_ID
                AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
                AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
                AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2          -- These two conditions
                AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0  -- may not be required
                AND     S.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
               )
        GROUP BY inventory_item_id, organization_id, sr_instance_id, sd_date;


    CURSOR c_net_sd_pf (p_plan_id             IN NUMBER,
                        p_last_refresh_number IN NUMBER,
                        p_new_refresh_number  IN NUMBER)
    IS
        SELECT  sr_instance_id,
                organization_id,
                inventory_item_id,
                SD_DATE,
                sum(sd_qty)
                -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
        from   (SELECT  I.sr_instance_id,
                        I.organization_id,
                        I.inventory_item_id,
                        TRUNC(DECODE(D.RECORD_SOURCE,
                                     2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                        DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                               2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(d.PLANNED_SHIP_DATE,d.USING_ASSEMBLY_DEMAND_DATE))),
                                                  NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) SD_DATE,
                                                  --plan by request date, promise date or schedule date
                        decode(D.USING_REQUIREMENT_QUANTITY,            -- Consider unscheduled orders as dummy supplies
                               0, D.OLD_DEMAND_QUANTITY,                -- For summary enhancement
                                  -1 * D.USING_REQUIREMENT_QUANTITY)  SD_QTY
                FROM    MSC_SYSTEM_ITEMS I,
                        MSC_DEMANDS D
                WHERE   I.ATP_FLAG          = 'Y'
                AND     I.PLAN_ID           = p_plan_id
                AND     D.PLAN_ID           = I.PLAN_ID
                AND     D.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
                AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                AND     D.ORGANIZATION_ID   = I.ORGANIZATION_ID
                AND     D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,70)
                AND     D.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
                AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

                UNION ALL

                SELECT  I.sr_instance_id,
                        I.organization_id,
                        I.inventory_item_id,
                        TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
                FROM    MSC_SYSTEM_ITEMS I,
                        MSC_SUPPLIES S
                WHERE   I.ATP_FLAG          = 'Y'
                AND     I.PLAN_ID           = p_plan_id
                AND     S.PLAN_ID           = I.PLAN_ID
                AND     S.SR_INSTANCE_ID    = I.SR_INSTANCE_ID
                AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                AND     S.ORGANIZATION_ID   = I.ORGANIZATION_ID
                AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2          -- These two conditions
                AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0  -- may not be required
                AND     S.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
                AND     I.AGGREGATE_TIME_FENCE_DATE IS NULL -- PF and members to be picked from alloc tables

                UNION ALL

                SELECT  AD.sr_instance_id,
                        AD.organization_id,
                        AD.inventory_item_id,
                        TRUNC(AD.demand_date) SD_DATE,
                        decode(AD.allocated_quantity,
                               0, AD.old_allocated_quantity,
                                  -1 * AD.allocated_quantity) SD_QTY
                FROM    MSC_ALLOC_DEMANDS AD
                WHERE   AD.PLAN_ID = p_plan_id
                AND     AD.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number

                UNION ALL

                SELECT  SA.sr_instance_id,
                        SA.organization_id,
                        SA.inventory_item_id,
                        TRUNC(SA.supply_date) SD_DATE,
                        SA.allocated_quantity SD_QTY
                FROM    MSC_ALLOC_SUPPLIES SA
                WHERE   SA.PLAN_ID = p_plan_id
                AND     SA.allocated_quantity <> 0
                AND     SA.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
               )
        GROUP BY inventory_item_id, organization_id, sr_instance_id, sd_date;

BEGIN

    msc_util.msc_log('******** LOAD_SD_NET_UNALLOC Begin ********');
    msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'p_last_refresh_number - ' || p_last_refresh_number);
    msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'p_new_refresh_number -  ' || p_new_refresh_number);
    msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'p_time_phased_pf -      ' || p_time_phased_pf);

    l_user_id := FND_GLOBAL.USER_ID;

    IF p_time_phased_pf = 2 THEN
        OPEN c_net_sd(p_plan_id, p_last_refresh_number, p_new_refresh_number);
        FETCH c_net_sd BULK COLLECT INTO l_sr_instance_id_tab,
                                         l_organization_id_tab,
                                         l_inventory_item_id_tab,
                                         l_sd_date_tab,
                                         l_sd_quantity_tab;
        CLOSE c_net_sd;
    ELSE
        OPEN c_net_sd_pf(p_plan_id, p_last_refresh_number, p_new_refresh_number);
        FETCH c_net_sd_pf BULK COLLECT INTO l_sr_instance_id_tab,
                                            l_organization_id_tab,
                                            l_inventory_item_id_tab,
                                            l_sd_date_tab,
                                            l_sd_quantity_tab;
        CLOSE c_net_sd_pf;
    END IF;

    IF l_inventory_item_id_tab IS NOT NULL AND l_inventory_item_id_tab.COUNT > 0 THEN

        msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'l_inventory_item_id_tab.COUNT := ' || l_inventory_item_id_tab.COUNT);

        forall j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last
        UPDATE MSC_ATP_SUMMARY_SD
        SET    sd_qty = sd_qty + l_sd_quantity_tab(j),
               last_update_date  = p_sys_date,
               last_updated_by   = l_user_id
        WHERE  plan_id           = p_plan_id
        AND    sr_instance_id    = l_sr_instance_id_tab(j)
        AND    inventory_item_id = l_inventory_item_id_tab(j)
        AND    organization_id   = l_organization_id_tab(j)
        AND    sd_date           = l_sd_date_tab(j);

        msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'After FORALL UPDATE');

        FOR j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last LOOP
            IF SQL%BULK_ROWCOUNT(j) = 0 THEN
                l_ins_sr_instance_id_tab.EXTEND;
                l_ins_organization_id_tab.EXTEND;
                l_ins_inventory_item_id_tab.EXTEND;
                l_ins_sd_date_tab.EXTEND;
                l_ins_sd_quantity_tab.EXTEND;

                l_ins_sr_instance_id_tab(l_ins_sr_instance_id_tab.COUNT)        := l_sr_instance_id_tab(j);
                l_ins_organization_id_tab(l_ins_organization_id_tab.COUNT)      := l_organization_id_tab(j);
                l_ins_inventory_item_id_tab(l_ins_inventory_item_id_tab.COUNT)  := l_inventory_item_id_tab(j);
                l_ins_sd_date_tab(l_ins_sd_date_tab.COUNT)                      := l_sd_date_tab(j);
                l_ins_sd_quantity_tab(l_ins_sd_quantity_tab.COUNT)              := l_sd_quantity_tab(j);
            END IF;
        END LOOP;

        IF l_ins_inventory_item_id_tab IS NOT NULL AND l_ins_inventory_item_id_tab.COUNT > 0 THEN

            msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'l_ins_inventory_item_id_tab.COUNT := ' || l_ins_inventory_item_id_tab.COUNT);

            forall  j IN l_ins_inventory_item_id_tab.first.. l_ins_inventory_item_id_tab.last
            INSERT  INTO MSC_ATP_SUMMARY_SD (
                    plan_id,
                    sr_instance_id,
                    organization_id,
                    inventory_item_id,
                    demand_class,
                    sd_date,
                    sd_qty,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
            VALUES (p_plan_id,
                    l_ins_sr_instance_id_tab(j),
                    l_ins_organization_id_tab(j),
                    l_ins_inventory_item_id_tab(j),
                    '@@@',
                    l_ins_sd_date_tab(j),
                    l_ins_sd_quantity_tab(j),
                    p_sys_date,
                    l_user_id,
                    p_sys_date,
                    l_user_id);

            msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'After FORALL INSERT');

        ELSE
            msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'No records to be inserted');
        END IF;
    ELSE
        msc_util.msc_log('LOAD_SD_NET_UNALLOC: ' || 'No records fetched in the net cursor');
    END IF;

    msc_util.msc_log('******** LOAD_SD_NET_UNALLOC End ********');

END LOAD_SD_NET_UNALLOC;


-- summary enhancement : private procedure for net summation of supply/demand
--                       for allocated cases.
PROCEDURE LOAD_SD_NET_ALLOC(p_plan_id             IN NUMBER,
                            p_last_refresh_number IN NUMBER,
                            p_new_refresh_number  IN NUMBER,
                            p_sys_date            IN DATE)
IS
    l_user_id   number;
    j           pls_integer;
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_organization_id_tab       MRP_ATP_PUB.number_arr;
    l_inventory_item_id_tab     MRP_ATP_PUB.number_arr;
    l_demand_class_tab          MRP_ATP_PUB.char30_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;

    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_organization_id_tab   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_inventory_item_id_tab MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_demand_class_tab      MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    CURSOR c_net_sd (p_plan_id             IN NUMBER,
                     p_last_refresh_number IN NUMBER,
                     p_new_refresh_number  IN NUMBER)
    IS
        SELECT  sr_instance_id,
                organization_id,
                inventory_item_id,
                demand_class,
                SD_DATE,
                sum(sd_qty)
        from   (SELECT  AD.sr_instance_id,
                        AD.organization_id,
                        AD.inventory_item_id,
                        AD.demand_class,
                        TRUNC(AD.demand_date) SD_DATE,
                        decode(AD.allocated_quantity,
                               0, AD.old_allocated_quantity,
                                  -1 * AD.allocated_quantity) SD_QTY
                FROM    MSC_ALLOC_DEMANDS AD
                WHERE   AD.PLAN_ID = p_plan_id
                AND     AD.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number

                UNION ALL

                SELECT  SA.sr_instance_id,
                        SA.organization_id,
                        SA.inventory_item_id,
                        SA.demand_class,
                        TRUNC(SA.supply_date) SD_DATE,
                        decode(SA.ALLOCATED_QUANTITY,           -- Consider deleted stealing records as dummy demands
                               0, -1 * OLD_ALLOCATED_QUANTITY,  -- For summary enhancement
                                  SA.ALLOCATED_QUANTITY) SD_QTY
                FROM    MSC_ALLOC_SUPPLIES SA
                WHERE   SA.PLAN_ID = p_plan_id
                AND     SA.REFRESH_NUMBER BETWEEN (p_last_refresh_number + 1) and p_new_refresh_number
               )
        GROUP BY inventory_item_id, organization_id, sr_instance_id, demand_class, sd_date;

BEGIN

    msc_util.msc_log('******** LOAD_SD_NET_ALLOC Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    OPEN c_net_sd(p_plan_id, p_last_refresh_number, p_new_refresh_number);
    FETCH c_net_sd BULK COLLECT INTO l_sr_instance_id_tab,
                                     l_organization_id_tab,
                                     l_inventory_item_id_tab,
                                     l_demand_class_tab,
                                     l_sd_date_tab,
                                     l_sd_quantity_tab;
    CLOSE c_net_sd;

    IF l_inventory_item_id_tab IS NOT NULL AND l_inventory_item_id_tab.COUNT > 0 THEN

        msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'l_inventory_item_id_tab.COUNT := ' || l_inventory_item_id_tab.COUNT);

        forall j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last
        UPDATE MSC_ATP_SUMMARY_SD
        SET    sd_qty = sd_qty + l_sd_quantity_tab(j),
               last_update_date  = p_sys_date,
               last_updated_by   = l_user_id
        WHERE  plan_id           = p_plan_id
        AND    sr_instance_id    = l_sr_instance_id_tab(j)
        AND    inventory_item_id = l_inventory_item_id_tab(j)
        AND    organization_id   = l_organization_id_tab(j)
        AND    sd_date           = l_sd_date_tab(j)
        AND    demand_class      = l_demand_class_tab(j);

        msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'After FORALL UPDATE');

        FOR j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last LOOP
            IF SQL%BULK_ROWCOUNT(j) = 0 THEN
                l_ins_sr_instance_id_tab.EXTEND;
                l_ins_organization_id_tab.EXTEND;
                l_ins_inventory_item_id_tab.EXTEND;
                l_ins_demand_class_tab.EXTEND;
                l_ins_sd_date_tab.EXTEND;
                l_ins_sd_quantity_tab.EXTEND;

                l_ins_sr_instance_id_tab(l_ins_sr_instance_id_tab.COUNT)        := l_sr_instance_id_tab(j);
                l_ins_organization_id_tab(l_ins_organization_id_tab.COUNT)      := l_organization_id_tab(j);
                l_ins_inventory_item_id_tab(l_ins_inventory_item_id_tab.COUNT)  := l_inventory_item_id_tab(j);
                l_ins_demand_class_tab(l_ins_demand_class_tab.COUNT)            := l_demand_class_tab(j);
                l_ins_sd_date_tab(l_ins_sd_date_tab.COUNT)                      := l_sd_date_tab(j);
                l_ins_sd_quantity_tab(l_ins_sd_quantity_tab.COUNT)              := l_sd_quantity_tab(j);
            END IF;
        END LOOP;

        IF l_ins_inventory_item_id_tab IS NOT NULL AND l_ins_inventory_item_id_tab.COUNT > 0 THEN

            msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'l_ins_inventory_item_id_tab.COUNT := ' || l_ins_inventory_item_id_tab.COUNT);

            forall  j IN l_ins_inventory_item_id_tab.first.. l_ins_inventory_item_id_tab.last
            INSERT  INTO MSC_ATP_SUMMARY_SD (
                    plan_id,
                    sr_instance_id,
                    organization_id,
                    inventory_item_id,
                    demand_class,
                    sd_date,
                    sd_qty,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
            VALUES (p_plan_id,
                    l_ins_sr_instance_id_tab(j),
                    l_ins_organization_id_tab(j),
                    l_ins_inventory_item_id_tab(j),
                    l_ins_demand_class_tab(j),
                    l_ins_sd_date_tab(j),
                    l_ins_sd_quantity_tab(j),
                    p_sys_date,
                    l_user_id,
                    p_sys_date,
                    l_user_id);

            msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'After FORALL INSERT');

        ELSE
            msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'No records to be inserted');
        END IF;
    ELSE
        msc_util.msc_log('LOAD_SD_NET_ALLOC: ' || 'No records fetched in the net cursor');
    END IF;

    msc_util.msc_log('******** LOAD_SD_NET_ALLOC End ********');

END LOAD_SD_NET_ALLOC;


PROCEDURE LOAD_SUP_DATA_FULL(p_plan_id  IN NUMBER,
                             p_sys_date IN DATE)
IS
    l_plan_start_date date;
    l_instance_id number;
    l_cutoff_date date;
    l_org_id number;
    -- l_default_atp_rule_id number;            -- Bug 3912422
    l_calendar_code  VARCHAR2(14);
    l_calendar_exception_set_id  NUMBER := -1;  -- Bug 3912422 - Initiallize to -1
    -- l_default_demand_class VARCHAR2(34);     -- Bug 3912422
    l_user_id  number;
    -- l_org_code     VARCHAR2(7);              -- Bug 3912422
BEGIN

    msc_util.msc_log('******** LOAD_SUP_DATA_FULL Begin ********');

    SELECT  trunc(p.plan_start_date),
            p.sr_instance_id,
            p.organization_id,
            trunc(p.cutoff_date),
            tp.calendar_code
    INTO    l_plan_start_date,
            l_instance_id,
            l_org_id,
            l_cutoff_date,
            l_calendar_code
    FROM    msc_plans p,
            msc_trading_partners tp
    WHERE   p.plan_id           = p_plan_id
    AND     p.organization_id   = tp.sr_tp_id
    AND     p.sr_instance_id    = tp.sr_instance_id
    AND     tp.partner_type     = 3;

    msc_util.msc_log('LOAD_SUP_DATA_FULL: ' || 'l_plan_start_date = ' || l_plan_start_date);
    msc_util.msc_log('LOAD_SUP_DATA_FULL: ' || 'l_instance_id =     ' || l_instance_id);
    msc_util.msc_log('LOAD_SUP_DATA_FULL: ' || 'l_org_id =          ' || l_org_id);
    msc_util.msc_log('LOAD_SUP_DATA_FULL: ' || 'l_calendar_code =   ' || l_calendar_code);

    l_user_id := FND_GLOBAL.USER_ID;

    INSERT INTO MSC_ATP_SUMMARY_SUP(
                plan_id,
                sr_instance_id,
                inventory_item_id,
                supplier_id,
                supplier_site_id,
                sd_date,
                sd_qty,
                demand_class,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by)
    (SELECT plan_id, sr_instance_id, inventory_item_id, supplier_id, supplier_site_id, sd_date, sum(sd_qty),
    demand_class, last_update_date, last_updated_by, creation_date, created_by
    FROM (
            SELECT  SV.plan_id plan_id,
                    SV.sr_instance_id,
                    SV.inventory_item_id inventory_item_id,
                    SV.supplier_id supplier_id,
                    SV.supplier_site_id supplier_site_id,
                    c.calendar_date sd_date, -- 2859130 remove trunc
                    SV.capacity sd_qty,
                    null demand_class,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    msc_calendar_dates c,
                   (SELECT  /*+ LEADING (I) */
                            I.plan_id plan_id,
                            I.sr_instance_id,
                            I.inventory_item_id inventory_item_id,
                            S.supplier_id supplier_id,
                            S.supplier_site_id supplier_site_id,
                            S.capacity,
                            trunc(S.from_date) from_date,
                            trunc(S.to_date) to_date,
                            mis.delivery_calendar_code,
                            mis.supplier_lead_time_date
                    FROM    msc_system_items I,
                            msc_supplier_capacities s,
                            msc_item_suppliers mis                      -- Bug 3912422 - Move to the inner query
                    WHERE   I.plan_id = p_plan_id
                    AND     I.atp_components_flag in ('Y', 'C')
                    AND     s.inventory_item_id = I.inventory_item_id
                    AND     s.sr_instance_id = I.sr_instance_id
                    AND     s.plan_id = I.plan_id
                    AND     s.organization_id = i.organization_id       --\
                    AND     s.inventory_item_id = mis.inventory_item_id --|
                    AND     s.sr_instance_id = mis.sr_instance_id       --> Bug 3912422
                    AND     s.plan_id = mis.plan_id                     --|
                    AND     s.organization_id = mis.organization_id     --/
                    AND NOT EXISTS --Bug 3912422, Replaced 'NOT IN' by 'NOT EXISTS'
                    --AND     (I.inventory_item_id, S.supplier_id, nvl(S.supplier_site_id,-1)) NOT IN
                             -- Bug 3912422
                            (SELECT 'x'        -- summary is not supported with flex flences : summary enhancement
                             FROM   msc_supplier_flex_fences msff
                             WHERE  plan_id = p_plan_id
                             AND msff.inventory_item_id = s.inventory_item_id --\
                             AND msff.supplier_id = s.supplier_id             -- } Bug 3912422
                             AND msff.supplier_site_id = s.supplier_site_id   --/
                             AND rownum = 1)
                    group by I.plan_id,
                            I.inventory_item_id,
                            I.sr_instance_id,
                            s.supplier_id,
                            s.supplier_site_id,
                            s.capacity,
                            trunc(s.from_date),
                            trunc(s.to_date),
                            mis.delivery_calendar_code,
                            mis.supplier_lead_time_date) SV
                    -- msc_item_suppliers mis                           -- Bug 3912422 - Move to the inner query
            WHERE   /* SV.inventory_item_id        = mis.inventory_item_id
            AND     SV.supplier_id              = mis.supplier_id
            AND     nvl(SV.supplier_site_id,-1) = nvl(mis.supplier_site_id, -1)
            AND     SV.sr_instance_id           = mis.sr_instance_id
            AND     c.calendar_code             = nvl(mis.delivery_calendar_code, l_calendar_code)
            AND*/     c.calendar_code             = nvl(SV.delivery_calendar_code, l_calendar_code)
            AND     c.calendar_date BETWEEN trunc(SV.from_date)
                                    AND NVL(SV.to_date,l_cutoff_date)
            -- AND     (c.seq_num IS NOT NULL OR mis.delivery_calendar_code IS NULL) -- Bug 3912422
            AND     (c.seq_num IS NOT NULL OR SV.delivery_calendar_code IS NULL) -- NULL means FOC
            AND     c.exception_set_id          = l_calendar_exception_set_id
            AND     c.sr_instance_id            = l_instance_id
            -- AND     c.calendar_date             >= mis.supplier_lead_time_date -- Bug 3912422
            AND     c.calendar_date             > SV.supplier_lead_time_date
                    -- Bug 3912422 - We should start looking from the day after supplier_lead_time_date
                    -- to accomodate for planning's additional "-1". If SMC is found in ASL then this
                    -- would mean one day offset as per ASL. If it is FOC then it would mean starting
                    -- from the next day.

            UNION ALL
            -- Net out planned orders, purchase orders and purchase requisitions /
            -- bug 1303196

            SELECT  /*+ LEADING (I) */
                    I.plan_id,
                    I.sr_instance_id,
                    I.inventory_item_id,
                    P.supplier_id,
                    P.supplier_site_id,
                    DECODE(tps.shipping_control,'BUYER',p.new_ship_date,p.new_dock_date),
                    (NVL(p.implement_quantity,0) - p.new_order_quantity) sd_qty,
                    null demand_class,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    msc_supplies p,
            --      msc_trading_partners tp,
            --      msc_calendar_dates c,
            --      msc_calendar_dates c1,
                    msc_trading_partner_sites tps,
                    msc_system_items I
            WHERE   I.plan_id = p_plan_id
            AND     I.atp_components_flag in ( 'Y', 'C')
            AND     (p.order_type IN (5, 2)
                    OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                        AND p.order_type = 1 AND p.promised_date IS NULL))
            AND     p.plan_id = I.plan_id
            AND     p.sr_instance_id = I.sr_instance_id
            AND     p.inventory_item_id = I.inventory_item_id
            AND     p.organization_id = I.organization_id
            AND     p.sr_instance_id  = I.sr_instance_id
            AND     NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2
            AND     p.supplier_id is not null
            AND     p.supplier_id = tps.partner_id (+)
            AND     p.supplier_site_id = tps.partner_site_id (+)
            AND NOT EXISTS  --Bug 3912422, Replaced 'NOT IN' by 'NOT EXISTS'
            --AND     (i.inventory_item_id, p.supplier_id, nvl(p.supplier_site_id,-1)) NOT IN
                     -- Bug 3912422
                    (SELECT 'x'     -- summary is not supported with flex flences : summary enhancement
                     FROM   msc_supplier_flex_fences msff
                     WHERE  plan_id = p_plan_id
                     AND msff.inventory_item_id = p.inventory_item_id  --\
                     AND msff.supplier_id = p.supplier_id              -- } Bug 3912422
                     AND msff.supplier_site_id = p.supplier_site_id    --/
                     AND rownum = 1)
    /*      AND     tp.sr_tp_id = p.organization_id
            AND     tp.sr_instance_id = p.sr_instance_id
            AND     tp.partner_type = 3
            AND     c.calendar_date = trunc(p.new_schedule_date) -- 1529756
            AND     c.calendar_code = tp.calendar_code
            AND     c.exception_set_id = tp.calendar_exception_set_id
            AND     c.sr_instance_id = tp.sr_instance_id
            AND     c1.seq_num = c.prior_seq_num-
                                 nvl(I.postprocessing_lead_time, 0)
            AND     c1.calendar_code = c.calendar_code
            AND     c1.exception_set_id = c.exception_set_id
            AND     c1.sr_instance_id = c.sr_instance_id*/
            AND     p.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation  - summary enhancement
        )
    group by plan_id,inventory_item_id, supplier_id, supplier_site_id, sr_instance_id,
             sd_date, demand_class, last_update_date, last_updated_by, creation_date, created_by
    );

    msc_util.msc_log('LOAD_SUP_DATA_FULL: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_SUP_DATA_FULL End ********');

END LOAD_SUP_DATA_FULL;


PROCEDURE LOAD_SUP_DATA_NET(p_plan_id                   IN NUMBER,
                            p_last_refresh_number       IN NUMBER,
                            p_new_refresh_number        IN NUMBER,
                            p_sys_date                  IN DATE)
IS
    l_user_id                   number;
    j                           pls_integer;
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_inventory_item_id_tab     MRP_ATP_PUB.number_arr;
    l_supplier_id_tab           MRP_ATP_PUB.number_arr;
    l_supplier_site_id_tab      MRP_ATP_PUB.number_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;

    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_inventory_item_id_tab MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_supplier_id_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_supplier_site_id_tab  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    CURSOR c_net_sup (p_plan_id             IN NUMBER, -- Cursor does not require msc_supplier_capacities because
                      p_last_refresh_number IN NUMBER, -- data in that does not change between plan runs
                      p_new_refresh_number  IN NUMBER)
    IS
        SELECT  I.sr_instance_id,
                I.inventory_item_id,
                P.supplier_id,
                P.supplier_site_id,
                DECODE(tps.shipping_control,'BUYER',p.new_ship_date,p.new_dock_date),
                sum(NVL(p.implement_quantity,0) - p.new_order_quantity) sd_qty
        FROM    msc_supplies p,
        --      msc_trading_partners tp,
        --      msc_calendar_dates c,
        --      msc_calendar_dates c1,
                msc_trading_partner_sites tps,
                msc_system_items I
        WHERE   I.plan_id = p_plan_id
        AND     I.atp_components_flag in ( 'Y', 'C')
        AND     (p.order_type IN (5, 2)
                OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                    AND p.order_type = 1 AND p.promised_date IS NULL))
        AND     p.plan_id = I.plan_id
        AND     p.sr_instance_id = I.sr_instance_id
        AND     p.inventory_item_id = I.inventory_item_id
        AND     p.organization_id = I.organization_id
        AND     p.sr_instance_id  = I.sr_instance_id
        AND     NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2
        AND     p.supplier_id is not null
        AND     p.supplier_id = tps.partner_id (+)
        AND     p.supplier_site_id = tps.partner_site_id (+)
        AND NOT EXISTS -- Bug 3912422, Replaced 'NOT IN' by 'NOT EXISTS'
        --AND     (i.inventory_item_id, p.supplier_id, nvl(p.supplier_site_id,-1)) NOT IN
                -- Bug 3912422
                (SELECT 'x'      -- summary is not supported with flex flences : summary enhancement
                 FROM   msc_supplier_flex_fences msff
                 WHERE  plan_id = p_plan_id
                 AND msff.inventory_item_id = p.inventory_item_id  --\
                 AND msff.supplier_id = p.supplier_id              -- } Bug 3912422
                 AND msff.supplier_site_id = p.supplier_site_id    --/
                 AND rownum = 1)
    /*  AND     tp.sr_tp_id = p.organization_id
        AND     tp.sr_instance_id = p.sr_instance_id
        AND     tp.partner_type = 3
        AND     c.calendar_date = trunc(p.new_schedule_date)
        AND     c.calendar_code = tp.calendar_code
        AND     c.exception_set_id = tp.calendar_exception_set_id
        AND     c.sr_instance_id = tp.sr_instance_id
        AND     c1.seq_num = c.prior_seq_num-
                             nvl(I.postprocessing_lead_time, 0)
        AND     c1.calendar_code = c.calendar_code
        AND     c1.exception_set_id = c.exception_set_id
        AND     c1.sr_instance_id = c.sr_instance_id  */
        AND     p.refresh_number between (p_last_refresh_number + 1) and p_new_refresh_number
        GROUP BY I.inventory_item_id, P.supplier_id, P.supplier_site_id, I.sr_instance_id,
                DECODE(tps.shipping_control,'BUYER',p.new_ship_date,p.new_dock_date);


BEGIN

    msc_util.msc_log('******** LOAD_SUP_DATA_NET Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    OPEN c_net_sup(p_plan_id, p_last_refresh_number, p_new_refresh_number);
    FETCH c_net_sup BULK COLLECT INTO l_sr_instance_id_tab,
                                    l_inventory_item_id_tab,
                                    l_supplier_id_tab,
                                    l_supplier_site_id_tab,
                                    l_sd_date_tab,
                                    l_sd_quantity_tab;
    CLOSE c_net_sup;

    IF l_inventory_item_id_tab IS NOT NULL AND l_inventory_item_id_tab.COUNT > 0 THEN

        msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'l_inventory_item_id_tab.COUNT := ' || l_inventory_item_id_tab.COUNT);

        forall j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last
        UPDATE MSC_ATP_SUMMARY_SUP
        SET    sd_qty = sd_qty + l_sd_quantity_tab(j),
               last_update_date  = p_sys_date,
               last_updated_by   = l_user_id
        WHERE  plan_id           = p_plan_id
        AND    sr_instance_id    = l_sr_instance_id_tab(j)
        AND    inventory_item_id = l_inventory_item_id_tab(j)
        AND    supplier_id       = l_supplier_id_tab(j)
        AND    supplier_site_id  = l_supplier_site_id_tab(j)
        AND    sd_date           = l_sd_date_tab(j);

        msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'After FORALL UPDATE');

        FOR j IN l_inventory_item_id_tab.first.. l_inventory_item_id_tab.last LOOP
            IF SQL%BULK_ROWCOUNT(j) = 0 THEN
                l_ins_sr_instance_id_tab.EXTEND;
                l_ins_inventory_item_id_tab.EXTEND;
                l_ins_supplier_id_tab.EXTEND;
                l_ins_supplier_site_id_tab.EXTEND;
                l_ins_sd_date_tab.EXTEND;
                l_ins_sd_quantity_tab.EXTEND;

                l_ins_sr_instance_id_tab(l_ins_sr_instance_id_tab.COUNT)        := l_sr_instance_id_tab(j);
                l_ins_inventory_item_id_tab(l_ins_inventory_item_id_tab.COUNT)  := l_inventory_item_id_tab(j);
                l_ins_supplier_id_tab(l_ins_supplier_id_tab.COUNT)              := l_supplier_id_tab(j);
                l_ins_supplier_site_id_tab(l_ins_supplier_site_id_tab.COUNT)    := l_supplier_site_id_tab(j);
                l_ins_sd_date_tab(l_ins_sd_date_tab.COUNT)                      := l_sd_date_tab(j);
                l_ins_sd_quantity_tab(l_ins_sd_quantity_tab.COUNT)              := l_sd_quantity_tab(j);
            END IF;
        END LOOP;

        IF l_ins_inventory_item_id_tab IS NOT NULL AND l_ins_inventory_item_id_tab.COUNT > 0 THEN

            msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'l_ins_inventory_item_id_tab.COUNT := ' || l_ins_inventory_item_id_tab.COUNT);

            forall  j IN l_ins_inventory_item_id_tab.first.. l_ins_inventory_item_id_tab.last
            INSERT  INTO MSC_ATP_SUMMARY_SUP (
                    plan_id,
                    sr_instance_id,
                    inventory_item_id,
                    supplier_id,
                    supplier_site_id,
                    sd_date,
                    sd_qty,
                    demand_class,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
            VALUES (p_plan_id,
                    l_ins_sr_instance_id_tab(j),
                    l_ins_inventory_item_id_tab(j),
                    l_ins_supplier_id_tab(j),
                    l_ins_supplier_site_id_tab(j),
                    l_ins_sd_date_tab(j),
                    l_ins_sd_quantity_tab(j),
                    NULL,
                    p_sys_date,
                    l_user_id,
                    p_sys_date,
                    l_user_id);

            msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'After FORALL INSERT');

        ELSE
            msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'No records to be inserted');
        END IF;
    ELSE
        msc_util.msc_log('LOAD_SUP_DATA_NET: ' || 'No records fetched in the net cursor');
    END IF;

    msc_util.msc_log('******** LOAD_SUP_DATA_NET End ********');

END LOAD_SUP_DATA_NET;


PROCEDURE LOAD_RES_FULL_UNOPT_BATCH(p_plan_id           IN NUMBER,
                                    p_plan_start_date   IN DATE,
                                    p_sys_date          IN DATE)
IS
    l_user_id   number;
BEGIN

    msc_util.msc_log('******** LOAD_RES_FULL_UNOPT_BATCH Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    -- summary enhancement - made changes to make it consistent with regular SQLs in MSCRATPB
    INSERT INTO MSC_ATP_SUMMARY_RES(
            plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    (SELECT plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            SD_DATE,
            SUM(SD_QTY),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    FROM
           (SELECT  RES_VIEW.plan_id plan_id,
                    RES_VIEW.department_id department_id,
                    RES_VIEW.resource_id resource_id,
                    RES_VIEW.organization_id organization_id,
                    RES_VIEW.sr_instance_id sr_instance_id,
                    trunc(RES_VIEW.SD_DATE) SD_DATE,
                    RES_VIEW.SD_QTY
                        * DECODE(RES_VIEW.BATCHABLE_FLAG, 0, 1, NVL(MUC.CONVERSION_RATE,1)) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_UOM_CONVERSIONS MUC,
                   (SELECT  -- hint for better performance.
                            /*+  ORDERED index(REQ MSC_RESOURCE_REQUIREMENTS_N2) */
                            DR.PLAN_ID plan_id,
                            NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) department_id,
                            DR.RESOURCE_ID resource_id,
                            DR.organization_id organization_id,
                            DR.SR_INSTANCE_ID sr_instance_id,
                            C.CALENDAR_DATE SD_DATE,
                            -- Bug 3321897, 2943979 For Line Based Resources,
                            -- Resource_ID is not NULL but -1
                            -1 * DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                                    DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                                        REQ.DAILY_RESOURCE_HOURS)) *
                                 DECODE(NVL(DR.BATCHABLE_FLAG,2), 1,
                                    (DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, I.UNIT_VOLUME) *
                                        NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY)), 1)  SD_QTY,
                            NVL(DR.BATCHABLE_FLAG,2) BATCHABLE_FLAG,
                            DECODE(DR.UOM_CLASS_TYPE,1 , I.WEIGHT_UOM, 2, I.VOLUME_UOM) UOM_CODE
                    FROM    MSC_DEPARTMENT_RESOURCES DR,
                            MSC_TRADING_PARTNERS P,
                            MSC_RESOURCE_REQUIREMENTS REQ,
                            MSC_SYSTEM_ITEMS I,
                            MSC_SUPPLIES S,
                            ----  re-ordered tables for performance
                            MSC_CALENDAR_DATES C
                    WHERE   DR.PLAN_ID = REQ.PLAN_ID
                    AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=REQ.DEPARTMENT_ID
                    AND     DR.RESOURCE_ID = REQ.RESOURCE_ID
                    AND     DR.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
                    AND     DR.organization_id = REQ.ORGANIZATION_ID
                    AND     REQ.PLAN_ID = p_plan_id
                    AND     NVL(REQ.PARENT_ID, 2) = 2
                    AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_Id
                    AND     I.PLAN_ID = S.PLAN_ID
                    AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
                    AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
                    AND     I.inventory_item_id = REQ.assembly_item_id    ----\
                    AND     ((I.bom_item_type <> 1                          --|
                              and I.bom_item_type <> 2                      --|- summary enhancement change for CTO ODR
                              AND I.atp_flag <> 'N')                        --|
                             OR (REQ.record_source = 2))                  ----/
                    AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
                    AND     S.PLAN_ID = REQ.PLAN_ID
                    AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
                    AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                    AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                    AND     P.SR_TP_ID = DR.ORGANIZATION_ID
                    AND     P.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
                    AND     P.PARTNER_TYPE = 3
                    AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
                    AND     C.CALENDAR_CODE = P.CALENDAR_CODE
                    AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
                    AND     C.CALENDAR_DATE BETWEEN TRUNC(REQ.START_DATE) AND
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                    AND     C.SEQ_NUM IS NOT NULL
                    AND     C.CALENDAR_DATE >= p_plan_start_date  -- summary enhancement - made consistent
                    AND     REQ.REFRESH_NUMBER IS NULL)RES_VIEW   -- consider only planning records in full summation - summary enhancement
            WHERE   RES_VIEW.UOM_CODE = MUC.UOM_CODE (+)
            AND     RES_VIEW.SR_INSTANCE_ID = MUC.SR_INSTANCE_ID (+)
            AND     MUC.INVENTORY_ITEM_ID (+)= 0

            UNION ALL

            SELECT  MNRA.plan_id plan_id,
                    MNRA.department_id,
                    MNRA.resource_id,
                    MNRA.organization_id,
                    MNRA.sr_instance_id,
                    trunc(MNRA.SHIFT_DATE) SD_DATE,
                    MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                        MNRA.to_time,to_time + 24*3600,
                        MNRA.to_time) - MNRA.from_time)/3600)
                            * DECODE(NVL(DR.BATCHABLE_FLAG, 2), 1,
                            DR.MAX_CAPACITY *  NVL(MUC.CONVERSION_RATE, 1), 1) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                    MSC_DEPARTMENT_RESOURCES DR,
                    MSC_UOM_CONVERSIONS MUC         -- noted in summary enhancement : inconsistent with MSCRATPB
            WHERE   MNRA.PLAN_ID = p_plan_id
            AND     NVL(MNRA.PARENT_ID, -2) <> -1
            AND     DR.PLAN_ID = MNRA.PLAN_ID
            AND     DR.SR_INSTANCE_ID = MNRA.SR_INSTANCE_ID
            AND     DR.ORGANIZATION_ID = MNRA.ORGANIZATION_ID
            AND     DR.RESOURCE_ID = MNRA.RESOURCE_ID
            AND     DR.DEPARTMENT_ID = MNRA.DEPARTMENT_ID
            AND     DR.UNIT_OF_MEASURE = MUC.UOM_CODE (+)
            AND     DR.SR_INSTANCE_ID =  MUC.SR_INSTANCE_ID (+)
            AND     MUC.INVENTORY_ITEM_ID (+) = 0
                    --- un commented the following row. This is done so that less number of rows are selected
            AND     SHIFT_DATE >= p_plan_start_date  -- summary enhancement - made consistent
            ) group by plan_id, department_id, resource_id, organization_id, sr_instance_id, sd_date,
            last_update_date,last_updated_by, creation_date, created_by
    );

    msc_util.msc_log('LOAD_RES_FULL_UNOPT_BATCH: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_RES_FULL_UNOPT_BATCH End ********');

END LOAD_RES_FULL_UNOPT_BATCH;


PROCEDURE LOAD_RES_FULL_OPT_BATCH(p_plan_id           IN NUMBER,
                                  p_plan_start_date   IN DATE,
                                  p_sys_date          IN DATE)
IS
    l_user_id   number;
BEGIN

    msc_util.msc_log('******** LOAD_RES_FULL_OPT_BATCH Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    -- summary enhancement - made changes to make it consistent with regular SQLs in MSCRATPB
    INSERT INTO MSC_ATP_SUMMARY_RES(
            plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    (SELECT plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            SD_DATE,
            SUM(SD_QTY),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    FROM
            (SELECT RES_VIEW.plan_id plan_id,
                    RES_VIEW.department_id department_id,
                    RES_VIEW.resource_id resource_id,
                    RES_VIEW.organization_id organization_id,
                    RES_VIEW.sr_instance_id sr_instance_id,
                    trunc(RES_VIEW.SD_DATE) SD_DATE,
                    RES_VIEW.SD_QTY
                    * DECODE(RES_VIEW.BATCHABLE_FLAG, 0, 1, NVL(MUC.CONVERSION_RATE,1)) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_UOM_CONVERSIONS MUC,
                    (SELECT -- hint for better performance.
                            /*+  ORDERED index(REQ MSC_RESOURCE_REQUIREMENTS_N2) */
                            DR.PLAN_ID plan_id,
                            NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) department_id,
                            DR.RESOURCE_ID resource_id,
                            DR.organization_id organization_id,
                            DR.SR_INSTANCE_ID sr_instance_id,
                            TRUNC(REQ.START_DATE) SD_DATE,
                            -- Bug 3321897, 2943979 For Line Based Resources,
                            -- Resource_ID is not NULL but -1
                            -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                            REQ.RESOURCE_HOURS) * -- 2859130         -- noted in summary enhancement : inconsistent with MSCRATPB
                            -- DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                            -- REQ.DAILY_RESOURCE_HOURS)) *
                            DECODE(NVL(DR.BATCHABLE_FLAG,2), 1,
                                (DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, I.UNIT_VOLUME) *
                                    NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY)), 1)  SD_QTY,
                            NVL(DR.BATCHABLE_FLAG,2) BATCHABLE_FLAG,
                            DECODE(DR.UOM_CLASS_TYPE,1 , I.WEIGHT_UOM, 2, I.VOLUME_UOM) UOM_CODE
                    FROM    MSC_DEPARTMENT_RESOURCES DR,
                            MSC_RESOURCE_REQUIREMENTS REQ,
                            MSC_SYSTEM_ITEMS I,
                            MSC_SUPPLIES S
                            ----  re-ordered tables for performance
                    WHERE   DR.PLAN_ID = REQ.PLAN_ID
                    AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=REQ.DEPARTMENT_ID
                    AND     DR.RESOURCE_ID = REQ.RESOURCE_ID
                    AND     DR.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
                    AND     DR.organization_id = REQ.ORGANIZATION_ID
                    AND     REQ.PLAN_ID = p_plan_id
                    AND     NVL(REQ.PARENT_ID, 1) = 1
                    AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_Id
                    AND     I.PLAN_ID = S.PLAN_ID
                    AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
                    AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
                    AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
                    AND     S.PLAN_ID = REQ.PLAN_ID
                    AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
                    AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                    AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2
                    AND     I.inventory_item_id = REQ.assembly_item_id    ----\
                    AND     ((I.bom_item_type <> 1                          --|
                              and I.bom_item_type <> 2                      --|- summary enhancement change for CTO ODR
                              AND I.atp_flag <> 'N')                        --|
                             OR (REQ.record_source = 2))                  ----/
                    AND     REQ.START_DATE >= p_plan_start_date     -- summary enhancement - made consistent
                    AND     REQ.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement
                    )RES_VIEW
            WHERE RES_VIEW.UOM_CODE = MUC.UOM_CODE (+)
            AND   RES_VIEW.SR_INSTANCE_ID = MUC.SR_INSTANCE_ID (+)
            AND   MUC.INVENTORY_ITEM_ID (+)= 0

            UNION ALL

            SELECT  MNRA.plan_id plan_id,
                    MNRA.department_id,
                    MNRA.resource_id,
                    MNRA.organization_id,
                    MNRA.sr_instance_id,
                    trunc(MNRA.SHIFT_DATE) SD_DATE,
                    MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                        MNRA.to_time,to_time + 24*3600,
                        MNRA.to_time) - MNRA.from_time)/3600)
                            * DECODE(NVL(DR.BATCHABLE_FLAG, 2), 1,
                              DR.MAX_CAPACITY *  NVL(MUC.CONVERSION_RATE, 1), 1) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                    MSC_DEPARTMENT_RESOURCES DR,
                    MSC_UOM_CONVERSIONS MUC             -- noted in summary enhancement : inconsistent with MSCRATPB
            WHERE   MNRA.PLAN_ID = p_plan_id
            AND     NVL(MNRA.PARENT_ID, -2) <> -1
            AND     DR.PLAN_ID = MNRA.PLAN_ID
            AND     DR.SR_INSTANCE_ID = MNRA.SR_INSTANCE_ID
            AND     DR.ORGANIZATION_ID = MNRA.ORGANIZATION_ID
            AND     DR.RESOURCE_ID = MNRA.RESOURCE_ID
            AND     DR.DEPARTMENT_ID = MNRA.DEPARTMENT_ID
            AND     DR.UNIT_OF_MEASURE = MUC.UOM_CODE (+)
            AND     DR.SR_INSTANCE_ID =  MUC.SR_INSTANCE_ID (+)
            AND     MUC.INVENTORY_ITEM_ID (+) = 0
                    --- un commented the following row. This is done so that less number of rows are selected
            AND     SHIFT_DATE >= p_plan_start_date -- summary enhancement - made consistent
            )
    group by plan_id, department_id, resource_id, organization_id, sr_instance_id, sd_date,
            last_update_date,last_updated_by, creation_date, created_by
    );

    msc_util.msc_log('LOAD_RES_FULL_OPT_BATCH: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_RES_FULL_OPT_BATCH End ********');

END LOAD_RES_FULL_OPT_BATCH;


PROCEDURE LOAD_RES_FULL_UNOPT_NOBATCH(p_plan_id           IN NUMBER,
                                      p_plan_start_date   IN DATE,
                                      p_sys_date          IN DATE)
IS
    l_user_id   number;
BEGIN

    msc_util.msc_log('******** LOAD_RES_FULL_UNOPT_NOBATCH Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    -- summary enhancement - made changes to make it consistent with regular SQLs in MSCRATPB
    INSERT INTO MSC_ATP_SUMMARY_RES(
            plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    (SELECT plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            SD_DATE,
            SUM(SD_QTY),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    FROM
        (
            SELECT  /*+ ORDERED index(REQ MSC_RESOURCE_REQUIREMENTS_N2) index(C MSC_CALENDAR_DATES_U1) */
                    DR.PLAN_ID plan_id,
                    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) department_id,
                    DR.RESOURCE_ID resource_id,
                    DR.organization_id organization_id,
                    DR.SR_INSTANCE_ID sr_instance_id,
                    C.CALENDAR_DATE SD_DATE, -- 2859130 remove trunc
                    -- Bug 3321897, 2943979 For Line Based Resources,
                    -- Resource_ID is not NULL but -1
                    -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                        DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                            REQ.DAILY_RESOURCE_HOURS))  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_DEPARTMENT_RESOURCES DR,
                    MSC_TRADING_PARTNERS P,
                    MSC_RESOURCE_REQUIREMENTS REQ,
                    MSC_SYSTEM_ITEMS I,                 -- summary enhancement change for CTO ODR
                    MSC_CALENDAR_DATES C
                    ----  re-ordered tables for performance
            WHERE   DR.PLAN_ID = REQ.PLAN_ID
            AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=REQ.DEPARTMENT_ID    -- summary enhancement - made consistent
            AND     DR.RESOURCE_ID = REQ.RESOURCE_ID
            AND     DR.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
            AND     DR.organization_id = REQ.ORGANIZATION_ID
            AND     REQ.PLAN_ID = p_plan_id
            AND     NVL(REQ.PARENT_ID, 2) = 2
            AND     P.SR_TP_ID = DR.ORGANIZATION_ID
            AND     P.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
            AND     P.PARTNER_TYPE = 3
            AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
            AND     C.CALENDAR_CODE = P.CALENDAR_CODE
            AND     C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
            AND     C.CALENDAR_DATE BETWEEN TRUNC(REQ.START_DATE) AND
                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
            AND     C.SEQ_NUM IS NOT NULL
            AND     C.CALENDAR_DATE >= p_plan_start_date
            AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id         ----\
            AND     I.PLAN_ID = REQ.PLAN_ID                         --|
            AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID         --|
            AND     I.inventory_item_id = REQ.assembly_item_id      --|\ summary enhancement
            AND     ((I.bom_item_type <> 1                          --|/ change for CTO ODR
                      and I.bom_item_type <> 2                      --|
                      AND I.atp_flag <> 'N')                        --|
                     OR (REQ.record_source = 2))                  ----/
            AND     REQ.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  plan_id plan_id,
                    department_id,
                    resource_id,
                    organization_id,
                    sr_instance_id,
                    trunc(SHIFT_DATE) SD_DATE,
                    CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                        to_time,to_time + 24*3600,
                        to_time) - from_time)/3600) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_NET_RESOURCE_AVAIL
            WHERE   PLAN_ID = p_plan_id
            AND     NVL(PARENT_ID, -2) <> -1
                    -- uncommented following line so that less number of rows are selected
            AND     SHIFT_DATE >= p_plan_start_date     -- summary enhancement - made consistent
        )
    group by plan_id, department_id, resource_id, organization_id, sr_instance_id, sd_date,
            last_update_date,last_updated_by, creation_date, created_by
    );

    msc_util.msc_log('LOAD_RES_FULL_UNOPT_NOBATCH: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_RES_FULL_UNOPT_NOBATCH End ********');

END LOAD_RES_FULL_UNOPT_NOBATCH;


PROCEDURE LOAD_RES_FULL_OPT_NOBATCH(p_plan_id           IN NUMBER,
                                    p_plan_start_date   IN DATE,
                                    p_sys_date          IN DATE)
IS
    l_user_id   number;
BEGIN

    msc_util.msc_log('******** LOAD_RES_FULL_OPT_NOBATCH Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    -- summary enhancement - made changes to make it consistent with regular SQLs in MSCRATPB
    INSERT INTO MSC_ATP_SUMMARY_RES(
            plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            sd_date,
            sd_qty,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    (SELECT plan_id,
            department_id,
            resource_id,
            organization_id,
            sr_instance_id,
            SD_DATE,
            SUM(SD_QTY),
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
    FROM
        (
            SELECT  /*+ ORDERED index(REQ MSC_RESOURCE_REQUIREMENTS_N2) index(C MSC_CALENDAR_DATES_U1) */
                    DR.PLAN_ID plan_id,
                    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) department_id,
                    DR.RESOURCE_ID resource_id,
                    DR.organization_id organization_id,
                    DR.SR_INSTANCE_ID sr_instance_id,
                    TRUNC(REQ.START_DATE) SD_DATE,
                    -- Bug 3321897, 2943979 For Line Based Resources,
                    -- Resource_ID is not NULL but -1
                    -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                        REQ.RESOURCE_HOURS) SD_QTY, --2859130
                    -- DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,   -- noted in summary enhancement : inconsistent with MSCRATPB
                        -- REQ.DAILY_RESOURCE_HOURS))  SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_DEPARTMENT_RESOURCES DR,
                    MSC_RESOURCE_REQUIREMENTS REQ,
                    MSC_SYSTEM_ITEMS I                  -- summary enhancement change for CTO ODR
            WHERE   DR.PLAN_ID = REQ.PLAN_ID
            AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=REQ.DEPARTMENT_ID    -- summary enhancement: made consistent
            AND     DR.RESOURCE_ID = REQ.RESOURCE_ID
            AND     DR.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
            AND     DR.organization_id = REQ.ORGANIZATION_ID
            AND     REQ.PLAN_ID = p_plan_id
            AND     NVL(REQ.PARENT_ID, 1) = 1
            AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id         ----\
            AND     I.PLAN_ID = REQ.PLAN_ID                         --|
            AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID         --|
            AND     I.inventory_item_id = REQ.assembly_item_id      --|\ summary enhancement
            AND     ((I.bom_item_type <> 1                          --|/ change for CTO ODR
                      and I.bom_item_type <> 2                      --|
                      AND I.atp_flag <> 'N')                        --|
                     OR (REQ.record_source = 2))                  ----/
            AND     REQ.START_DATE >= p_plan_start_date                                     -- summary enhancement: made consistent
            AND     REQ.REFRESH_NUMBER IS NULL   -- consider only planning records in full summation - summary enhancement

            UNION ALL

            SELECT  plan_id plan_id,
                    department_id,
                    resource_id,
                    organization_id,
                    sr_instance_id,
                    trunc(SHIFT_DATE) SD_DATE,
                    CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                        to_time,to_time + 24*3600,
                        to_time) - from_time)/3600) SD_QTY,
                    p_sys_date last_update_date,
                    l_user_id last_updated_by,
                    p_sys_date creation_date,
                    l_user_id created_by
            FROM    MSC_NET_RESOURCE_AVAIL
            WHERE   PLAN_ID = p_plan_id
            AND     NVL(PARENT_ID, -2) <> -1
            AND     SHIFT_DATE >= p_plan_start_date         -- summary enhancement: made consistent
        )
    group by plan_id, department_id, resource_id, organization_id, sr_instance_id, sd_date,
            last_update_date,last_updated_by, creation_date, created_by
    );

    msc_util.msc_log('LOAD_RES_FULL_OPT_NOBATCH: ' || 'Records inserted : ' || SQL%ROWCOUNT);
    msc_util.msc_log('******** LOAD_RES_FULL_OPT_NOBATCH End ********');

END LOAD_RES_FULL_OPT_NOBATCH;


PROCEDURE LOAD_RES_DATA_NET(p_plan_id                   IN NUMBER,
                            p_last_refresh_number       IN NUMBER,
                            p_new_refresh_number        IN NUMBER,
                            p_sys_date                  IN DATE)
IS
    l_user_id   number;
    j           pls_integer;
    l_department_id_tab         MRP_ATP_PUB.number_arr;
    l_resource_id_tab           MRP_ATP_PUB.number_arr;
    l_organization_id_tab       MRP_ATP_PUB.number_arr;
    l_sr_instance_id_tab        MRP_ATP_PUB.number_arr;
    l_sd_date_tab               MRP_ATP_PUB.date_arr;
    l_sd_quantity_tab           MRP_ATP_PUB.number_arr;

    l_ins_department_id_tab     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_resource_id_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_organization_id_tab   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sr_instance_id_tab    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
    l_ins_sd_date_tab           MRP_ATP_PUB.date_arr   := MRP_ATP_PUB.date_arr();
    l_ins_sd_quantity_tab       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

    CURSOR c_net_res (p_plan_id             IN NUMBER, -- Cursor does not require msc_net_resource_avail because
                      p_last_refresh_number IN NUMBER, -- data in that does not change between plan runs
                      p_new_refresh_number  IN NUMBER)
    IS
        SELECT  NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) department_id,
                DR.RESOURCE_ID resource_id,
                DR.organization_id organization_id,
                DR.SR_INSTANCE_ID sr_instance_id,
                -- Bug 3348095
                -- Only ATP created records, so use end_date
                TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) SD_DATE,
                -- TRUNC(REQ.START_DATE) SD_DATE,
                -- End Bug 3348095
                SUM((-1) * REQ.RESOURCE_HOURS) SD_QTY -- ATP always populates resource_hours
        FROM    MSC_DEPARTMENT_RESOURCES DR,
                MSC_RESOURCE_REQUIREMENTS REQ
        WHERE   DR.PLAN_ID = p_plan_id
        AND     REQ.PLAN_ID = DR.PLAN_ID
        AND     REQ.SR_INSTANCE_ID = DR.sr_instance_id
        AND     REQ.RESOURCE_ID = DR.resource_id
        AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID) = DR.DEPARTMENT_ID
        AND     REQ.refresh_number between (p_last_refresh_number + 1) and p_new_refresh_number
        GROUP BY DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID, DR.RESOURCE_ID, DR.organization_id, DR.SR_INSTANCE_ID, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE));
                  -- Bug 3348095  Only ATP created records, so use end_date.

BEGIN

    msc_util.msc_log('******** LOAD_RES_DATA_NET Begin ********');

    l_user_id := FND_GLOBAL.USER_ID;

    OPEN c_net_res(p_plan_id, p_last_refresh_number, p_new_refresh_number);
    FETCH c_net_res BULK COLLECT INTO l_department_id_tab,
                                      l_resource_id_tab,
                                      l_organization_id_tab,
                                      l_sr_instance_id_tab,
                                      l_sd_date_tab,
                                      l_sd_quantity_tab;
    CLOSE c_net_res;

    IF l_resource_id_tab IS NOT NULL AND l_resource_id_tab.COUNT > 0 THEN

        msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'l_resource_id_tab.COUNT := ' || l_resource_id_tab.COUNT);

        forall j IN l_resource_id_tab.first.. l_resource_id_tab.last
        UPDATE MSC_ATP_SUMMARY_RES
        SET    sd_qty = sd_qty + l_sd_quantity_tab(j),
               last_update_date  = p_sys_date,
               last_updated_by   = l_user_id
        WHERE  plan_id           = p_plan_id
        AND    sr_instance_id    = l_sr_instance_id_tab(j)
        AND    organization_id   = l_organization_id_tab(j)
        AND    resource_id       = l_resource_id_tab(j)
        AND    department_id     = l_department_id_tab(j)
        AND    sd_date           = l_sd_date_tab(j);

        msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'After FORALL UPDATE');

        FOR j IN l_resource_id_tab.first.. l_resource_id_tab.last LOOP
            IF SQL%BULK_ROWCOUNT(j) = 0 THEN
                l_ins_department_id_tab.EXTEND;
                l_ins_resource_id_tab.EXTEND;
                l_ins_organization_id_tab.EXTEND;
                l_ins_sr_instance_id_tab.EXTEND;
                l_ins_sd_date_tab.EXTEND;
                l_ins_sd_quantity_tab.EXTEND;

                l_ins_department_id_tab(l_ins_department_id_tab.COUNT)          := l_department_id_tab(j);
                l_ins_resource_id_tab(l_ins_resource_id_tab.COUNT)              := l_resource_id_tab(j);
                l_ins_organization_id_tab(l_ins_organization_id_tab.COUNT)      := l_organization_id_tab(j);
                l_ins_sr_instance_id_tab(l_ins_sr_instance_id_tab.COUNT)        := l_sr_instance_id_tab(j);
                l_ins_sd_date_tab(l_ins_sd_date_tab.COUNT)                      := l_sd_date_tab(j);
                l_ins_sd_quantity_tab(l_ins_sd_quantity_tab.COUNT)              := l_sd_quantity_tab(j);
            END IF;
        END LOOP;

        IF l_ins_resource_id_tab IS NOT NULL AND l_ins_resource_id_tab.COUNT > 0 THEN

            msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'l_ins_resource_id_tab.COUNT := ' || l_ins_resource_id_tab.COUNT);

            forall  j IN l_ins_resource_id_tab.first.. l_ins_resource_id_tab.last
            INSERT  INTO MSC_ATP_SUMMARY_RES (
                    plan_id,
                    department_id,
                    resource_id,
                    organization_id,
                    sr_instance_id,
                    sd_date,
                    sd_qty,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
            VALUES (p_plan_id,
                    l_ins_department_id_tab(j),
                    l_ins_resource_id_tab(j),
                    l_ins_organization_id_tab(j),
                    l_ins_sr_instance_id_tab(j),
                    l_ins_sd_date_tab(j),
                    l_ins_sd_quantity_tab(j),
                    p_sys_date,
                    l_user_id,
                    p_sys_date,
                    l_user_id);

            msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'After FORALL INSERT');

        ELSE
            msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'No records to be inserted');
        END IF;
    ELSE
        msc_util.msc_log('LOAD_RES_DATA_NET: ' || 'No records fetched in the net cursor');
    END IF;

    msc_util.msc_log('******** LOAD_RES_DATA_NET End ********');

END LOAD_RES_DATA_NET;


PROCEDURE Truncate_Summ_Plan_Partition(p_plan_id IN NUMBER,
                                       p_applsys_schema IN Varchar2)
IS
    l_partition_name            varchar2(30);
    l_sql_stmt                  varchar2(300);
BEGIN
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'p_plan_id  - ' || p_plan_id);
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'p_applsys_schema  - ' || p_applsys_schema);

------------------------------------------------

    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'truncate partition for sd');
    l_partition_name := 'ATP_SUMMARY_SD_' || to_char(p_plan_id);
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'Partition name : ' || l_partition_name);
    l_sql_stmt := 'ALTER TABLE MSC_ATP_SUMMARY_SD TRUNCATE PARTITION ' ||
                    l_partition_name  || ' DROP STORAGE';

    BEGIN
        msc_util.msc_log('Before alter table MSC_ATP_SUMMARY_SD');
        ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                      APPLICATION_SHORT_NAME => 'MSC',
                      STATEMENT_TYPE => ad_ddl.alter_table,
                      STATEMENT => l_sql_stmt,
                      OBJECT_NAME => 'MSC_ATP_SUMMARY_SD');
    END;
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'After truncating SD partition');

------------------------------------------------

    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'truncate partition for sup');
    l_partition_name := 'ATP_SUMMARY_SUP_' || to_char(p_plan_id);
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'Partition name : ' || l_partition_name);
    l_sql_stmt := 'ALTER TABLE MSC_ATP_SUMMARY_SUP TRUNCATE PARTITION ' ||
                    l_partition_name  || ' DROP STORAGE';

    BEGIN
        msc_util.msc_log('Before alter table MSC_ATP_SUMMARY_SUP');
        ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                      APPLICATION_SHORT_NAME => 'MSC',
                      STATEMENT_TYPE => ad_ddl.alter_table,
                      STATEMENT => l_sql_stmt,
                      OBJECT_NAME => 'MSC_ATP_SUMMARY_SUP');
    END;
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'After truncating sup partition');

------------------------------------------------

    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'truncate partition for res');
    l_partition_name := 'ATP_SUMMARY_RES_' || to_char(p_plan_id);
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'Partition name : ' || l_partition_name);
    l_sql_stmt := 'ALTER TABLE MSC_ATP_SUMMARY_RES TRUNCATE PARTITION ' ||
                    l_partition_name  || ' DROP STORAGE';

    BEGIN
        msc_util.msc_log('Before alter table MSC_ATP_SUMMARY_RES');
        ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                      APPLICATION_SHORT_NAME => 'MSC',
                      STATEMENT_TYPE => ad_ddl.alter_table,
                      STATEMENT => l_sql_stmt,
                      OBJECT_NAME => 'MSC_ATP_SUMMARY_RES');
    END;
    msc_util.msc_log('Truncate_Summ_Plan_Partition: ' || 'After truncating res partition');

------------------------------------------------

END Truncate_Summ_Plan_Partition;


PROCEDURE Gather_Summ_Plan_Stats(p_plan_id              IN NUMBER,
                                 p_share_partition      IN varchar2)
IS
    l_partition_name            varchar2(30);
BEGIN

------------------------------------------------
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'Gather Table Stats for S/D Tables');
    IF p_share_partition = 'Y' THEN
        l_partition_name := 'ATP_SUMMARY_SD_999999';
    ELSE
        l_partition_name := 'ATP_SUMMARY_SD_' || to_char(p_plan_id);
    END IF;

    fnd_stats.gather_table_stats(ownname=>'MSC',
                                 tabname=>'MSC_ATP_SUMMARY_SD',
                                 partname=>l_partition_name,
                                 granularity=>'PARTITION',
                                 percent =>10);
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'After gathering stats for S/D tables');
------------------------------------------------
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'Gather Table Stats for Sup Tables');
    IF p_share_partition = 'Y' THEN
        l_partition_name := 'ATP_SUMMARY_SUP_999999';
    ELSE
        l_partition_name := 'ATP_SUMMARY_SUP_' || to_char(p_plan_id);
    END IF;

    fnd_stats.gather_table_stats(ownname=>'MSC',
                                 tabname=>'MSC_ATP_SUMMARY_SUP',
                                 partname=>l_partition_name,
                                 granularity=>'PARTITION',
                                 percent =>10);
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'After gathering stats for Sup tables');
------------------------------------------------
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'Gather Table Stats for Res Tables');
    IF p_share_partition = 'Y' THEN
        l_partition_name := 'ATP_SUMMARY_RES_999999';
    ELSE
        l_partition_name := 'ATP_SUMMARY_RES_' || to_char(p_plan_id);
    END IF;

    fnd_stats.gather_table_stats(ownname=>'MSC',
                                 tabname=>'MSC_ATP_SUMMARY_RES',
                                 partname=>l_partition_name,
                                 granularity=>'PARTITION',
                                 percent =>10);
    msc_util.msc_log('Gather_Summ_Plan_Stats: ' || 'After gathering stats for Res tables');
------------------------------------------------


END Gather_Summ_Plan_Stats;

--*************************************************************---
--New Procedure added for collection enhancement --bug3049003
--*************************************************************--
PROCEDURE atp_snapshot_hook(
	                      p_plan_id       IN 	NUMBER
                         )

IS
--bug3663487 start SQL_ID  9425117
-- IO Perf:3693983: Don't Launch ATP Post snapshot Processes for IO Plans
l_count                 NUMBER := 0;
--bug3663487 end
Begin

        msc_util.msc_log('Begin procedure atp_snapshot_hook');

        SELECT count(*)
        INTO   l_count
        FROM   msc_plans plans,
               msc_designators desig
        WHERE  plans.plan_id = p_plan_id
        AND    plans.plan_type <> 4
        AND    plans.compile_designator = desig.designator
        AND    plans.sr_instance_id = desig.sr_instance_id
        AND    plans.organization_id = desig.organization_id
        AND    (desig.inventory_atp_flag = 1
                OR plans.copy_plan_id IS NOT NULL);

        msc_util.msc_log('atp_snapshot_hook: l_count: '|| nvl(l_count,0));

        IF ( NVL(l_count,0) > 0) THEN
        msc_util.msc_log('atp_snapshot_hook: Updating msc_plan_organizations..');
        UPDATE msc_plan_organizations mpo
        SET so_lrn =(SELECT so_lrn
                    FROM msc_instance_orgs mio
                    WHERE mio.sr_instance_id=mpo.sr_instance_id
                    AND mio.organization_id=mpo.organization_id
                     )
        WHERE plan_id=p_plan_id;
        --RETURNING organization_id, sr_instance_id
        --BULK COLLECT INTO l_organization_id, l_sr_instance_id;
        msc_util.msc_log('atp_snapshot_hook: No. of Rows updated: '|| SQL%ROWCOUNT );
        END IF;

        --bug3663487 start
        /*
        UPDATE msc_system_items mst1
        SET (REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG) =(SELECT REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG
                    FROM msc_system_items mst2
                    WHERE mst2.sr_instance_id=mst1.sr_instance_id
                    AND mst2.organization_id=mst1.organization_id
                    AND mst2.INVENTORY_ITEM_ID=mst1.INVENTORY_ITEM_ID
                    AND mst2.plan_id=-1
                     )
        WHERE plan_id=p_plan_id;
        */
        -- ATP_RULE_ID and DEMAND_TIME_FENCE_DAYS is also flushed as we are using it in populate_atf_date
        -- to make its performance better.
        -- IO Perf:3693983: Moved update of msc_system_items to Load_Plan_SD
        /*
        FORALL j IN l_organization_id.first.. l_organization_id.last
        UPDATE msc_system_items mst1
        SET (REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG,ATP_RULE_ID,DEMAND_TIME_FENCE_DAYS) =(SELECT REPLENISH_TO_ORDER_FLAG,PICK_COMPONENTS_FLAG,ATP_RULE_ID,DEMAND_TIME_FENCE_DAYS
                    FROM msc_system_items mst2
                    WHERE mst2.sr_instance_id=mst1.sr_instance_id
                    AND mst2.organization_id=mst1.organization_id
                    AND mst2.INVENTORY_ITEM_ID=mst1.INVENTORY_ITEM_ID
                    AND mst2.plan_id=-1
                     )
        WHERE plan_id=p_plan_id
        AND     mst1.ORGANIZATION_ID = l_organization_id(j)
        AND     mst1.SR_INSTANCE_ID = l_sr_instance_id(j)
        AND     mst1.bom_item_type  in (1,4,5)
        AND     mst1.atp_flag <> 'N'
        OR      mst1.atp_components_flag <> 'N';
        */
        --bug3663487 end

        commit;

EXCEPTION
	WHEN others THEN
	     msc_util.msc_log('Error in atp_snapshot_hook: ' || SQLCODE || '-' || SQLERRM);
END atp_snapshot_hook;

-- NGOEL 1/15/2004, API to delete CTO BOM and OSS data from ATP temp tables for standalone and post 24x7 plan run plan purging
-- This API will be called by "Purge Plan" conc program.

Procedure Delete_CTO_BOM_OSS(
          p_plan_id			IN		NUMBER)
IS
BEGIN
    msc_util.msc_log('Begin Delete_CTO_BOM_OSS for plan_id: ' || p_plan_id);
    msc_util.msc_log('Before Delete data for CTO BOM');

    DELETE msc_cto_bom
	WHERE  nvl(plan_id, p_plan_id) = p_plan_id;

    msc_util.msc_log('After Delete data for CTO BOM: ' || SQL%ROWCOUNT);

    msc_util.msc_log('Before Delete data for CTO OSS');

    DELETE msc_cto_sources
	WHERE  nvl(plan_id, p_plan_id) = p_plan_id;

    msc_util.msc_log('After Delete data for CTO OSS: ' || SQL%ROWCOUNT);

	commit;

    msc_util.msc_log('End Delete_CTO_BOM_OSS');
EXCEPTION
	WHEN others THEN
		 msc_util.msc_log('Exception in Delete_CTO_BOM_OSS :' || SQLCODE || '-' || SQLERRM);
END Delete_CTO_BOM_OSS;

END MSC_POST_PRO;

/
