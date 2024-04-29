--------------------------------------------------------
--  DDL for Package Body MSC_WS_SNO_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_SNO_PUBLISH" AS
/* $Header: MSCWSPBB.pls 120.17.12010000.5 2010/03/24 17:14:46 saskrish ship $ */
  PROCEDURE LOG_MESSAGE (p_message varchar2) AS
      msg varchar2(1000);
      begin
      msg := p_message || ' : ' || SQLERRM;
      fnd_file.put_line(fnd_file.log, msg);
  END LOG_MESSAGE;

  PROCEDURE SET_ASCP_ALERTS (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    -- implementation starts here
    -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_EXCEPTION_DETAILS table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_EXCEPTION_DETAILS WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE Part 1A - for Demand category and organizationId <> -1
        INSERT INTO MSC_EXCEPTION_DETAILS (PLAN_ID,
                     SR_INSTANCE_ID,
	             ORGANIZATION_ID,
	             INVENTORY_ITEM_ID,
	             DEPARTMENT_ID,
                     RESOURCE_ID,
                     EXCEPTION_DETAIL_ID,
                     EXCEPTION_TYPE,
                     QUANTITY,
		     NUMBER2,
	             DATE1,
                     DATE2,
	             NUMBER1,
                     ZONE_ID,
                     CUSTOMER_SITE_ID,
                     CUSTOMER_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY)
	SELECT
        MSC_INT_ASCP_EXCEPTION_DETAILS.Plan_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID,
        DepartmentID,
        -1,
        MSC_EXCEPTION_DETAILS_S.NEXTVAL,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ViolationCode, -- Used to be: 28,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Quantity,
	MSC_INT_ASCP_EXCEPTION_DETAILS.Percentage,
        TO_DATE(PeriodStart, 'YYYY-MM-DD'),
        TO_DATE(PeriodEnd, 'YYYY-MM-DD')-1/86400,
        case WHEN MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Demand'
              AND msc_demands.plan_id=MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID
              AND TO_DATE(MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400 =msc_demands.dmd_satisfied_date
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.INSTANCE_ID=msc_demands.sr_instance_id
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID=msc_demands.inventory_item_id
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.ORGANIZATION_ID=msc_demands.organization_id
              AND msc_demands.origination_type=81
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id <> -1
        then
          msc_demands.demand_id
        else
        null
        end,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':') = 0 )
          THEN TO_NUMBER(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID)
        ELSE
          NULL
        END,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
          THEN SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)+1) -- CUSTOMER_SITE_ID
        ELSE
          NULL
        END,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
                  THEN SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, 1, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)-1) -- CUSTOMER_ID
                ELSE
                  NULL
        END,
        SYSDATE,
        '-1',
        SYSDATE,
        '-1'
        FROM msc_demands, MSC_INT_ASCP_EXCEPTION_DETAILS
        where MSC_INT_ASCP_EXCEPTION_DETAILS.ALERTCATEGORY = 'Demand'
          AND msc_demands.plan_id=MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID
          AND TO_DATE( MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400 =msc_demands.dmd_satisfied_date
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.INSTANCE_ID=msc_demands.sr_instance_id
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID=msc_demands.inventory_item_id
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.ORGANIZATION_ID=msc_demands.organization_id
          AND msc_demands.origination_type=81
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id <> -1;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_ALERTS_001001' || ' : ' || SQLERRM;
            raise;
    END;
    BEGIN
        -- CODE GOES HERE Part 1B - for Demand category and organizationId = -1
        INSERT INTO MSC_EXCEPTION_DETAILS (PLAN_ID,
                     SR_INSTANCE_ID,
	             ORGANIZATION_ID,
	             INVENTORY_ITEM_ID,
	             DEPARTMENT_ID,
                     RESOURCE_ID,
                     EXCEPTION_DETAIL_ID,
                     EXCEPTION_TYPE,
                     QUANTITY,
		     NUMBER2,
	             DATE1,
                     DATE2,
	             NUMBER1,
                     ZONE_ID,
                     CUSTOMER_SITE_ID,
                     CUSTOMER_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY)
	SELECT
        MSC_INT_ASCP_EXCEPTION_DETAILS.Plan_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID,
        DepartmentID,
        -1,
        MSC_EXCEPTION_DETAILS_S.NEXTVAL,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ViolationCode, -- Used to be: 28,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Quantity,
	MSC_INT_ASCP_EXCEPTION_DETAILS.Percentage,
        TO_DATE(PeriodStart, 'YYYY-MM-DD'),
        TO_DATE(PeriodEnd, 'YYYY-MM-DD')-1/86400,
        case WHEN MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Demand'
              AND msc_demands.plan_id=MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID
              AND TO_DATE(MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400 =msc_demands.dmd_satisfied_date
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.INSTANCE_ID= -1
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID=msc_demands.inventory_item_id
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.ORGANIZATION_ID=msc_demands.organization_id
              AND msc_demands.origination_type=81
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id = -1
               -- CUSTOMER_SITE_ID:
              AND (
                    ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null )
                    AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
                    AND (SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)+1) ) = msc_demands.CUSTOMER_SITE_ID )
               -- CUSTOMER_ID:
              AND (
                  MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null )
                  AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
                  AND ( SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, 1, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)-1) = msc_demands.CUSTOMER_ID
                    )
        then
          msc_demands.demand_id
        else
          null
        end,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':') = 0 )
          THEN TO_NUMBER(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID)
        ELSE
          NULL
        END,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
          THEN SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)+1) -- CUSTOMER_SITE_ID
        ELSE
          NULL
        END,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1) <> 0 )
                  THEN SUBSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID, 1, INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':',1,1)-1) -- CUSTOMER_ID
                ELSE
                  NULL
        END,
        SYSDATE,
        '-1',
        SYSDATE,
        '-1'
        FROM msc_demands, MSC_INT_ASCP_EXCEPTION_DETAILS
        where MSC_INT_ASCP_EXCEPTION_DETAILS.ALERTCATEGORY = 'Demand'
          AND msc_demands.plan_id=MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID
          AND TO_DATE( MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400 =msc_demands.dmd_satisfied_date
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.INSTANCE_ID=-1
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID=msc_demands.inventory_item_id
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.ORGANIZATION_ID=msc_demands.organization_id
          AND msc_demands.origination_type=81
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id = -1;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_ALERTS_001001' || ' : ' || SQLERRM;
            raise;
    END;
    BEGIN
        -- CODE GOES HERE Part 2, for Supply category. Need to
        -- use MSC_PLANS to find owning org and instance
        INSERT INTO MSC_EXCEPTION_DETAILS (PLAN_ID,
                     SR_INSTANCE_ID,
	             ORGANIZATION_ID,
	             INVENTORY_ITEM_ID,
	             DEPARTMENT_ID,
                     RESOURCE_ID,
                     EXCEPTION_DETAIL_ID,
                     EXCEPTION_TYPE,
                     QUANTITY,
		     NUMBER2,
	             DATE1,
                     DATE2,
	             NUMBER1,
                     ZONE_ID,
                     SUPPLIER_SITE_ID,
                     SUPPLIER_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY)
	SELECT
        MSC_INT_ASCP_EXCEPTION_DETAILS.Plan_Id,
        MSC_PLANS.sr_instance_id,
        MSC_PLANS.organization_id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID,
        -1,
        -1,
        MSC_EXCEPTION_DETAILS_S.NEXTVAL,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ViolationCode, -- Used to be: 28,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Quantity,
	MSC_INT_ASCP_EXCEPTION_DETAILS.Percentage,
        TO_DATE(PeriodStart, 'YYYY-MM-DD'),
        TO_DATE(PeriodEnd, 'YYYY-MM-DD')-1/86400,
        case when MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Supply'
              AND msc_supplies.Plan_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID
              AND msc_supplies.ORGANIZATION_ID=MSC_PLANS.organization_id -- no org id in Supply category
          AND msc_supplies.SUPPLIER_SITE_ID =MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id
          AND msc_supplies.SUPPLIER_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
              AND msc_supplies.SR_INSTANCE_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_Id
              AND msc_supplies.INVENTORY_ITEM_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID
              AND msc_supplies.NEW_SCHEDULE_DATE= TO_DATE( MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400
              AND msc_supplies.order_type=1
              AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id <> -1
        then
          msc_supplies.transaction_id
        else
        null
        end,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':') = 0 )
          THEN TO_NUMBER(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID)
        ELSE
          NULL
        END,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id, --SupplierSiteId
        MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId, --SupplierId
        SYSDATE,
        '-1',
        SYSDATE,
        '-1'
    FROM msc_supplies, MSC_INT_ASCP_EXCEPTION_DETAILS, MSC_PLANS
    WHERE MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory='Supply'
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.PLAN_ID=PlanIdVar
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.plan_id=msc_supplies.Plan_ID
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.plan_id=MSC_PLANS.PLAN_ID
          AND msc_supplies.organization_id = MSC_PLANS.organization_id -- use owning org id to suppress extra records
          AND msc_supplies.SUPPLIER_SITE_ID =MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id
          AND msc_supplies.SUPPLIER_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
          AND msc_supplies.SR_INSTANCE_ID = MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_Id
          AND msc_supplies.INVENTORY_ITEM_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID
          AND msc_supplies.NEW_SCHEDULE_DATE=TO_DATE( MSC_INT_ASCP_EXCEPTION_DETAILS.PERIODEND, 'YYYY-MM-DD')-1/86400
          AND (msc_supplies.order_type=1) AND (msc_supplies.FIRM_PLANNED_TYPE=2)
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.organization_id <> -1;

      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_ALERTS_001002' || ' : ' || SQLERRM;
            raise;
    END;

    BEGIN
        -- CODE GOES HERE Part 3
        INSERT INTO MSC_EXCEPTION_DETAILS (PLAN_ID,
                     SR_INSTANCE_ID,
	             ORGANIZATION_ID,
	             INVENTORY_ITEM_ID,
	             DEPARTMENT_ID,
                     RESOURCE_ID,
                     EXCEPTION_DETAIL_ID,
                     EXCEPTION_TYPE,
                     QUANTITY,
		     NUMBER2,
	             DATE1,
                     DATE2,
	             NUMBER1,
                     ZONE_ID,
                     CUSTOMER_SITE_ID,
                     CUSTOMER_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY)
	SELECT
        MSC_INT_ASCP_EXCEPTION_DETAILS.Plan_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_Id,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id,
        -- inventory_item_id
        case when( ( MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Manufacturing') AND
                      ( ( SELECT COUNT(*) FROM MSC_DEPARTMENT_RESOURCES WHERE
                      MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND
                      MSC_DEPARTMENT_RESOURCES.Organization_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_ID AND
                      MSC_DEPARTMENT_RESOURCES.Sr_Instance_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_ID AND
                      MSC_DEPARTMENT_RESOURCES.Resource_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID AND
                      MSC_DEPARTMENT_RESOURCES.Department_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
                      ) > 0 ) )
        then -1
        else (
          case when ( MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory <> 'Manufacturing' )
             then MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID -- Inventory, Transportation and Others
             else MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentID end
             )
        end,
        -- department_id
       case when( ( MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Manufacturing') AND
                      ( ( SELECT COUNT(*) FROM MSC_DEPARTMENT_RESOURCES WHERE
                      MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND
                      MSC_DEPARTMENT_RESOURCES.Organization_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_ID AND
                      MSC_DEPARTMENT_RESOURCES.Sr_Instance_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_ID AND
                      MSC_DEPARTMENT_RESOURCES.Resource_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID AND
                      MSC_DEPARTMENT_RESOURCES.Department_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
                      ) > 0 ))
        then MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
        else -1
        end,
        -- resource_id
        case when( ( MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory = 'Manufacturing') AND
                      ( ( SELECT COUNT(*) FROM MSC_DEPARTMENT_RESOURCES WHERE
                      MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND
                      MSC_DEPARTMENT_RESOURCES.Organization_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_ID AND
                      MSC_DEPARTMENT_RESOURCES.Sr_Instance_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.Instance_ID AND
                      MSC_DEPARTMENT_RESOURCES.Resource_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID AND
                      MSC_DEPARTMENT_RESOURCES.Department_ID=MSC_INT_ASCP_EXCEPTION_DETAILS.DepartmentId
                      ) > 0 ) )
        then MSC_INT_ASCP_EXCEPTION_DETAILS.ItemID
        else -1
        end,
        MSC_EXCEPTION_DETAILS_S.NEXTVAL,
        MSC_INT_ASCP_EXCEPTION_DETAILS.ViolationCode, -- Used to be: 28,
        MSC_INT_ASCP_EXCEPTION_DETAILS.Quantity,
	MSC_INT_ASCP_EXCEPTION_DETAILS.Percentage,
        TO_DATE(PeriodStart, 'YYYY-MM-DD'),
        TO_DATE(PeriodEnd, 'YYYY-MM-DD')-1/86400,
        NULL,
        CASE WHEN ( MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID is not null ) AND ( INSTR(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID,':') = 0 )
          THEN TO_NUMBER(MSC_INT_ASCP_EXCEPTION_DETAILS.Zone_ID)
        ELSE
          NULL
        END,
        null, --customerSiteId
        null, --customerId
        SYSDATE,
        '-1',
        SYSDATE,
        '-1'
        FROM MSC_INT_ASCP_EXCEPTION_DETAILS
        WHERE MSC_INT_ASCP_EXCEPTION_DETAILS.Plan_Id = PlanIdVar
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.Organization_Id <> -1
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory <> 'Demand'
          AND MSC_INT_ASCP_EXCEPTION_DETAILS.AlertCategory <> 'Supply';

      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_ALERTS_001003' || ' : ' || SQLERRM;
            raise;
    END;

    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;

  END SET_ASCP_ALERTS;

  PROCEDURE SET_UP_SYSTEM_ITEMS(
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS

  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation start here */
    -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_SYSTEM_ITEMS table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_SYSTEM_ITEMS WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;


	--Now update the temp table in order to get Number Of Sources measure for each item
	-- delete records from MSC_INT_APCC_ITEM_SOURCE table for the given PlanId, if any
    --BEGIN
    --DELETE FROM MSC_INT_APCC_ITEM_SOURCE WHERE PLAN_ID=PlanIdVar;
    --EXCEPTION WHEN others THEN
      --NULL; -- do nothing
    --END;

	--BEGIN
        --INSERT into msc_int_apcc_item_source
	--		( plan_id,
	--		sr_instance_id,
	--		organization_id,
	--		inventory_item_id,
	--		source_organization_id,
	--		source_org_instance_id  )
        --SELECT DISTINCT
	--		TO_NUMBER(msc_int_src_recommend_detail.planName),
			--sr_instance_id
	--		TO_NUMBER(substr(msc_int_src_recommend_detail.destination_code,1,instr(msc_int_src_recommend_detail.destination_code,':',1,1)-1)),
			--organization_id
	--		TO_NUMBER(substr(msc_int_src_recommend_detail.destination_code,instr(msc_int_src_recommend_detail.destination_code,':',1,1)+1)),
			--inventory_item_id
	--		TO_NUMBER(substr(msc_int_src_recommend_detail.item_code,instr(msc_int_src_recommend_detail.item_code,':',1,1)+1)),
            --source_organization_id
        --    TO_NUMBER(substr( MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, ':', 1,1) + 1 )),
			---source_org_instance_id
        --    TO_NUMBER(substr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,1,instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,':',1,1)-1))
        --FROM msc_int_src_recommend_detail
        --WHERE msc_int_src_recommend_detail.planName = PlanIdVar
        --GROUP BY msc_int_src_recommend_detail.planName,
	--		msc_int_src_recommend_detail.origin_code,
	--		msc_int_src_recommend_detail.destination_code,
	--		msc_int_src_recommend_detail.item_code;
    --EXCEPTION WHEN others THEN
      --g_ErrorCode := 'ERROR_UPDATE_MSC_SYSTEM_ITEMS_001001' || ' : ' || SQLERRM;
      --raise;
    --END;

    BEGIN
        -- CODE GOES HERE
        -- duplicate system items needed in the msc_system_items table with changed PlanId
        INSERT INTO MSC_SYSTEM_ITEMS (
                    PLAN_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    SR_INSTANCE_ID,
                    SR_INVENTORY_ITEM_ID,
                    ITEM_NAME,
                    LOTS_EXPIRATION,
                    LOT_CONTROL_CODE,
                    SHRINKAGE_RATE,
                    FIXED_DAYS_SUPPLY,
                    FIXED_ORDER_QUANTITY,
                    FIXED_LOT_MULTIPLIER,
                    MINIMUM_ORDER_QUANTITY,
                    MAXIMUM_ORDER_QUANTITY,
                    ROUNDING_CONTROL_TYPE,
                    PLANNING_TIME_FENCE_DAYS,
                    PLANNING_TIME_FENCE_DATE,
                    DEMAND_TIME_FENCE_DAYS,
                    DEMAND_TIME_FENCE_DATE,
                    DESCRIPTION,
                    RELEASE_TIME_FENCE_CODE,
                    RELEASE_TIME_FENCE_DAYS,
                    IN_SOURCE_PLAN,
                    REVISION,
                    SR_CATEGORY_ID,
                    ABC_CLASS,
                    CATEGORY_NAME,
                    MRP_PLANNING_CODE,
                    FIXED_LEAD_TIME,
                    VARIABLE_LEAD_TIME,
                    PREPROCESSING_LEAD_TIME,
                    POSTPROCESSING_LEAD_TIME,
                    FULL_LEAD_TIME,
                    CUMULATIVE_TOTAL_LEAD_TIME,
                    CUM_MANUFACTURING_LEAD_TIME,
                    UOM_CODE,
                    UNIT_WEIGHT,
                    UNIT_VOLUME,
                    WEIGHT_UOM,
                    VOLUME_UOM,
                    PRODUCT_FAMILY_ID,
                    ATP_RULE_ID,
                    ATP_COMPONENTS_FLAG,
                    BUILD_IN_WIP_FLAG,
                    PURCHASING_ENABLED_FLAG,
                    PLANNING_MAKE_BUY_CODE,
                    REPETITIVE_TYPE,
                    REPETITIVE_VARIANCE,
                    STANDARD_COST,
                    CARRYING_COST,
                    ORDER_COST,
                    MATERIAL_COST,
                    DMD_LATENESS_COST,
                    RESOURCE_COST,
                    SS_PENALTY_COST,
                    SUPPLIER_CAP_OVERUTIL_COST,
                    LIST_PRICE,
                    AVERAGE_DISCOUNT,
                    ENGINEERING_ITEM_FLAG,
                    WIP_SUPPLY_TYPE,
                    SAFETY_STOCK_CODE,
                    SAFETY_STOCK_PERCENT,
                    SAFETY_STOCK_BUCKET_DAYS,
                    INVENTORY_USE_UP_DATE,
                    BUYER_NAME,
                    PLANNER_CODE,
                    PLANNING_EXCEPTION_SET,
                    EXCESS_QUANTITY,
                    EXCEPTION_SHORTAGE_DAYS,
                    EXCEPTION_EXCESS_DAYS,
                    EXCEPTION_OVERPROMISED_DAYS,
                    EXCEPTION_CODE,
                    BOM_ITEM_TYPE,
                    ATO_FORECAST_CONTROL,
                    EFFECTIVITY_CONTROL,
                    ORGANIZATION_CODE,
                    ACCEPTABLE_RATE_INCREASE,
                    ACCEPTABLE_RATE_DECREASE,
                    EXCEPTION_REP_VARIANCE_DAYS,
                    OVERRUN_PERCENTAGE,
                    INVENTORY_PLANNING_CODE,
                    ACCEPTABLE_EARLY_DELIVERY,
                    CALCULATE_ATP,
                    END_ASSEMBLY_PEGGING_FLAG,
                    END_ASSEMBLY_PEGGING,
                    FULL_PEGGING,
                    INVENTORY_ITEM_FLAG,
                    SOURCE_ORG_ID,
                    BASE_ITEM_ID,
                    ABC_CLASS_NAME,
                    FIXED_SAFETY_STOCK_QTY,
                    PRIMARY_SUPPLIER_ID,
                    ATP_FLAG,
                    LOW_LEVEL_CODE,
                    PLANNER_STATUS_CODE,
                    NETTABLE_INVENTORY_QUANTITY,
                    NONNETTABLE_INVENTORY_QUANTITY,
                    REFRESH_NUMBER,
                    REQUEST_ID,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    REVISION_QTY_CONTROL_CODE,
                    EXPENSE_ACCOUNT,
                    INVENTORY_ASSET_FLAG,
                    BUYER_ID,
                    REPETITIVE_PLANNING_FLAG,
                    PICK_COMPONENTS_FLAG,
                    SERVICE_LEVEL,
                    REPLENISH_TO_ORDER_FLAG,
                    PIP_FLAG,
                    YIELD_CONV_FACTOR,
                    MIN_MINMAX_QUANTITY,
                    MAX_MINMAX_QUANTITY,
                    NEW_ATP_FLAG,
                    SOURCE_TYPE,
                    SUBSTITUTION_WINDOW,
                    CREATE_SUPPLY_FLAG,
                    REORDER_POINT,
                    AVERAGE_ANNUAL_DEMAND,
                    ECONOMIC_ORDER_QUANTITY,
                    SERIAL_NUMBER_CONTROL_CODE,
                    CONVERGENCE,
                    DIVERGENCE,
                    CONTINOUS_TRANSFER,
                    CRITICAL_COMPONENT_FLAG,
                    REDUCE_MPS,
                    CONSIGNED_FLAG,
                    VMI_MINIMUM_UNITS,
                    VMI_MINIMUM_DAYS,
                    VMI_MAXIMUM_UNITS,
                    VMI_MAXIMUM_DAYS,
                    AVERAGE_DAILY_DEMAND,
                    VMI_FIXED_ORDER_QUANTITY,
                    SO_AUTHORIZATION_FLAG,
                    VMI_FORECAST_TYPE,
                    FORECAST_HORIZON,
                    ASN_AUTOEXPIRE_FLAG,
                    VMI_REFRESH_FLAG,
                    BUDGET_CONSTRAINED,
                    MAX_QUANTITY,
                    MAX_QUANTITY_DOS,
                    DAYS_TGT_INV_WINDOW,
                    DAYS_MAX_INV_WINDOW,
                    DAYS_TGT_INV_SUPPLY,
                    DAYS_MAX_INV_SUPPLY,
                    DRP_PLANNED,
                    AGGREGATE_TIME_FENCE_DATE,
                    INFERRED_CRITICAL_FLAG,
                    SS_WINDOW_SIZE,
                    ITEM_CREATION_DATE,
                    PLANNING_TIME_FENCE_CODE,
                    SHORTAGE_TYPE,
                    EXCESS_TYPE,
                    PEGGING_DEMAND_WINDOW_DAYS,
                    PEGGING_SUPPLY_WINDOW_DAYS,
                    UNSATISFIED_DEMAND_FACTOR,
                    SAFETY_LEAD_TIME,
                    -- COUNT_OF_SOURCES,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN  )
	SELECT DISTINCT PlanIdVar,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    SR_INSTANCE_ID,
                    SR_INVENTORY_ITEM_ID,
                    ITEM_NAME,
                    LOTS_EXPIRATION,
                    LOT_CONTROL_CODE,
                    SHRINKAGE_RATE,
                    FIXED_DAYS_SUPPLY,
                    FIXED_ORDER_QUANTITY,
                    FIXED_LOT_MULTIPLIER,
                    MINIMUM_ORDER_QUANTITY,
                    MAXIMUM_ORDER_QUANTITY,
                    ROUNDING_CONTROL_TYPE,
                    PLANNING_TIME_FENCE_DAYS,
                    PLANNING_TIME_FENCE_DATE,
                    DEMAND_TIME_FENCE_DAYS,
                    DEMAND_TIME_FENCE_DATE,
                    DESCRIPTION,
                    RELEASE_TIME_FENCE_CODE,
                    RELEASE_TIME_FENCE_DAYS,
                    IN_SOURCE_PLAN,
                    REVISION,
                    SR_CATEGORY_ID,
                    ABC_CLASS,
                    CATEGORY_NAME,
                    MRP_PLANNING_CODE,
                    FIXED_LEAD_TIME,
                    VARIABLE_LEAD_TIME,
                    PREPROCESSING_LEAD_TIME,
                    POSTPROCESSING_LEAD_TIME,
                    FULL_LEAD_TIME,
                    CUMULATIVE_TOTAL_LEAD_TIME,
                    CUM_MANUFACTURING_LEAD_TIME,
                    UOM_CODE,
                    UNIT_WEIGHT,
                    UNIT_VOLUME,
                    WEIGHT_UOM,
                    VOLUME_UOM,
                    PRODUCT_FAMILY_ID,
                    ATP_RULE_ID,
                    ATP_COMPONENTS_FLAG,
                    BUILD_IN_WIP_FLAG,
                    PURCHASING_ENABLED_FLAG,
                    PLANNING_MAKE_BUY_CODE,
                    REPETITIVE_TYPE,
                    REPETITIVE_VARIANCE,
                    STANDARD_COST,
                    CARRYING_COST,
                    ORDER_COST,
                    MATERIAL_COST,
                    DMD_LATENESS_COST,
                    RESOURCE_COST,
                    SS_PENALTY_COST,
                    SUPPLIER_CAP_OVERUTIL_COST,
                    LIST_PRICE,
                    AVERAGE_DISCOUNT,
                    ENGINEERING_ITEM_FLAG,
                    WIP_SUPPLY_TYPE,
                    SAFETY_STOCK_CODE,
                    SAFETY_STOCK_PERCENT,
                    SAFETY_STOCK_BUCKET_DAYS,
                    INVENTORY_USE_UP_DATE,
                    BUYER_NAME,
                    PLANNER_CODE,
                    PLANNING_EXCEPTION_SET,
                    EXCESS_QUANTITY,
                    EXCEPTION_SHORTAGE_DAYS,
                    EXCEPTION_EXCESS_DAYS,
                    EXCEPTION_OVERPROMISED_DAYS,
                    EXCEPTION_CODE,
                    BOM_ITEM_TYPE,
                    ATO_FORECAST_CONTROL,
                    EFFECTIVITY_CONTROL,
                    ORGANIZATION_CODE,
                    ACCEPTABLE_RATE_INCREASE,
                    ACCEPTABLE_RATE_DECREASE,
                    EXCEPTION_REP_VARIANCE_DAYS,
                    OVERRUN_PERCENTAGE,
                    INVENTORY_PLANNING_CODE,
                    ACCEPTABLE_EARLY_DELIVERY,
                    CALCULATE_ATP,
                    END_ASSEMBLY_PEGGING_FLAG,
                    END_ASSEMBLY_PEGGING,
                    FULL_PEGGING,
                    INVENTORY_ITEM_FLAG,
                    SOURCE_ORG_ID,
                    BASE_ITEM_ID,
                    ABC_CLASS_NAME,
                    FIXED_SAFETY_STOCK_QTY,
                    PRIMARY_SUPPLIER_ID,
                    ATP_FLAG,
                    LOW_LEVEL_CODE,
                    PLANNER_STATUS_CODE,
                    NETTABLE_INVENTORY_QUANTITY,
                    NONNETTABLE_INVENTORY_QUANTITY,
                    REFRESH_NUMBER,
                    REQUEST_ID,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    REVISION_QTY_CONTROL_CODE,
                    EXPENSE_ACCOUNT,
                    INVENTORY_ASSET_FLAG,
                    BUYER_ID,
                    REPETITIVE_PLANNING_FLAG,
                    PICK_COMPONENTS_FLAG,
                    SERVICE_LEVEL,
                    REPLENISH_TO_ORDER_FLAG,
                    PIP_FLAG,
                    YIELD_CONV_FACTOR,
                    MIN_MINMAX_QUANTITY,
                    MAX_MINMAX_QUANTITY,
                    NEW_ATP_FLAG,
                    SOURCE_TYPE,
                    SUBSTITUTION_WINDOW,
                    CREATE_SUPPLY_FLAG,
                    REORDER_POINT,
                    AVERAGE_ANNUAL_DEMAND,
                    ECONOMIC_ORDER_QUANTITY,
                    SERIAL_NUMBER_CONTROL_CODE,
                    CONVERGENCE,
                    DIVERGENCE,
                    CONTINOUS_TRANSFER,
                    CRITICAL_COMPONENT_FLAG,
                    REDUCE_MPS,
                    CONSIGNED_FLAG,
                    VMI_MINIMUM_UNITS,
                    VMI_MINIMUM_DAYS,
                    VMI_MAXIMUM_UNITS,
                    VMI_MAXIMUM_DAYS,
                    AVERAGE_DAILY_DEMAND,
                    VMI_FIXED_ORDER_QUANTITY,
                    SO_AUTHORIZATION_FLAG,
                    VMI_FORECAST_TYPE,
                    FORECAST_HORIZON,
                    ASN_AUTOEXPIRE_FLAG,
                    VMI_REFRESH_FLAG,
                    BUDGET_CONSTRAINED,
                    MAX_QUANTITY,
                    MAX_QUANTITY_DOS,
                    DAYS_TGT_INV_WINDOW,
                    DAYS_MAX_INV_WINDOW,
                    DAYS_TGT_INV_SUPPLY,
                    DAYS_MAX_INV_SUPPLY,
                    DRP_PLANNED,
                    AGGREGATE_TIME_FENCE_DATE,
                    INFERRED_CRITICAL_FLAG,
                    SS_WINDOW_SIZE,
                    ITEM_CREATION_DATE,
                    PLANNING_TIME_FENCE_CODE,
                    SHORTAGE_TYPE,
                    EXCESS_TYPE,
                    PEGGING_DEMAND_WINDOW_DAYS,
                    PEGGING_SUPPLY_WINDOW_DAYS,
                    UNSATISFIED_DEMAND_FACTOR,
                    SAFETY_LEAD_TIME,
		    -- number of sources ( new measure )
                    --(select COUNT( DISTINCT MSC_INT_APCC_ITEM_SOURCE.source_organization_id )
                    --              from  MSC_INT_APCC_ITEM_SOURCE
                    --                WHERE PlanIdVar =  MSC_INT_APCC_ITEM_SOURCE.plan_ID AND
                    --                MSC_SYSTEM_ITEMS.SR_INSTANCE_ID =  MSC_INT_APCC_ITEM_SOURCE.sr_instance_id AND
                    --                MSC_SYSTEM_ITEMS.ORGANIZATION_ID =  MSC_INT_APCC_ITEM_SOURCE.organization_id AND
                    --                MSC_SYSTEM_ITEMS.INVENTORY_ITEM_ID =  MSC_INT_APCC_ITEM_SOURCE.inventory_item_id
                    --                ), -- must specify table name before columns to avoid duplicate count
					SYSDATE,
					'-1',
					SYSDATE,
					'-1',
				-- last update login :
					-- we do not have the userId here ( no validation should be done at this point as required earlier) :
					'-1'
 	FROM MSC_SYSTEM_ITEMS LEFT JOIN MSC_INT_ASCP_INVENTORY ON
              MSC_INT_ASCP_INVENTORY.OrganizationID = MSC_SYSTEM_ITEMS.ORGANIZATION_ID AND
              MSC_INT_ASCP_INVENTORY.InstanceID = MSC_SYSTEM_ITEMS.SR_INSTANCE_ID AND
              MSC_INT_ASCP_INVENTORY.ItemId = MSC_SYSTEM_ITEMS.INVENTORY_ITEM_ID
        WHERE  MSC_SYSTEM_ITEMS.PLAN_ID=-1 AND MSC_INT_ASCP_INVENTORY.PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_MSC_SYSTEM_ITEMS_001002' || ' : ' || SQLERRM;
            raise;
    END;

    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;

  END SET_UP_SYSTEM_ITEMS;



  PROCEDURE SET_ASCP_PLAN_BUCKETS(
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS

  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation start here */
    -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_PLAN_BUCKETS table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_PLAN_BUCKETS WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_PLAN_BUCKETS (PLAN_ID,
			      ORGANIZATION_ID,
			      SR_INSTANCE_ID,
			      BUCKET_INDEX,
			      CURR_FLAG,
			      BKT_START_DATE,
			      BKT_END_DATE,
			      DAYS_IN_BKT,
			      BUCKET_TYPE,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY)
	SELECT PlanIdVar, MSC_PLANS.ORGANIZATION_ID, MSC_PLANS.SR_INSTANCE_ID,
               TO_NUMBER(BucketIndex), 1,
               TO_DATE(BktStartDate,'YYYY-MM-DD'), TO_DATE(BktEndDate,'YYYY-MM-DD')-1/86400,
               TO_NUMBER(DaysInBucket), TO_NUMBER(BucketType),
               SYSDATE, '-1',
               SYSDATE, '-1'
 	FROM MSC_INT_ASCP_EXPORT_BUCKETS, MSC_PLANS
        WHERE PLANID=PlanIdVar AND
              MSC_PLANS.PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_PLAN_BUCKETS_001001' || ' : ' || SQLERRM;
            raise;
    END;




    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;

  END SET_ASCP_PLAN_BUCKETS;

  -- New FacilityCosts measure
  PROCEDURE SET_APCC_FACILITY_COST(
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS

  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation start here */
    -- init global variables
    g_ErrorCode := '';

    -- delete records from MSC_BIS_ORG_DETAIL table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_BIS_ORG_DETAIL WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_BIS_ORG_DETAIL (PLAN_ID,
			      SR_INSTANCE_ID,
			      ORGANIZATION_ID,
			      DETAIL_DATE,
			      FACILITY_COST,
			      FACILITY_COST_TYPE,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN)
	SELECT
			PlanIdVar,
			SR_INSTANCE_ID,
			ORGANIZATION_ID,
			TO_DATE(PERIOD_END,'YYYY-MM-DD'),
                        FACILITY_COST,
			FACILITY_COST_TYPE,
            SYSDATE, '-1',
            SYSDATE, '-1', -1
 	FROM MSC_INT_APCC_ORG_DETAIL
        WHERE PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_FACILITY_COSTS_001001' || ' : ' || SQLERRM;
            raise;
    END

    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;

   END SET_APCC_FACILITY_COST;


  PROCEDURE SET_ASCP_DEMANDS(
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation start here */
    -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_WS_DEMANDS table for the given PlanIdVar, if any
    BEGIN
    DELETE FROM MSC_DEMANDS WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;
    -- insert new rows


    BEGIN
        -- CODE GOES HERE
        --
        -- populate MSC_DEMANDS from ASCP Demand (Forecast/Satisfied)
        --
        INSERT INTO MSC_DEMANDS (
                  ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  PLAN_ID,
                  SR_INSTANCE_ID,
		  DEMAND_ID,
                  ORIGINATION_TYPE,
                  USING_REQUIREMENT_QUANTITY,
                  QUANTITY_BY_DUE_DATE,
                  DMD_SATISFIED_DATE,
                  ZONE_ID,
                  CUSTOMER_SITE_ID,
                  CUSTOMER_ID,
                  SERVICE_LEVEL,
                  USING_ASSEMBLY_DEMAND_DATE,
                  USING_ASSEMBLY_ITEM_ID,
                  DEMAND_TYPE,
                  UNMET_QUANTITY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY)
	SELECT
                CASE WHEN ( ZoneID is not null )
                  THEN  -1
                ELSE
                  OrganizationID
                END,
		ItemID,
		PlanIdVar,
                InstanceID,
		MSC_DEMANDS_S.NEXTVAL,
		81,
		Demand,
		Satisfied,
                TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
                CASE WHEN ( ZoneID is not null ) AND ( INSTR(ZoneID,':') = 0 )
                  THEN TO_NUMBER(ZoneID)
                ELSE
                  NULL
                END,
                CASE WHEN ( ZoneID is not null ) AND ( INSTR(ZoneID,':',1,1) <> 0 )
                  THEN SUBSTR(ZoneID, INSTR(ZoneID,':',1,1)+1) -- CUSTOMER_SITE_ID
                ELSE
                  NULL
                END,
                CASE WHEN ( ZoneID is not null ) AND ( INSTR(ZoneID,':',1,1) <> 0 )
                  THEN SUBSTR(ZoneID, 1, INSTR(ZoneID,':',1,1)-1) -- CUSTOMER_ID
                ELSE
                  NULL
                END,
                0,
                TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
                ItemID,
                1,
                Demand-Satisfied,
                SYSDATE, '-1', SYSDATE, '-1'
	FROM MSC_INT_ASCP_DEMANDS
        WHERE PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_DEMAND_FROM_ASCP_DEMAND_001001' || ' : ' || SQLERRM;
            raise;
    END;
    BEGIN
		-- populate MSC_DEMANDS from ASCP Dependent Demand
        --
        INSERT INTO MSC_DEMANDS (
                  ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  PLAN_ID,
                  SR_INSTANCE_ID,
				  DEMAND_ID,
                  ORIGINATION_TYPE,
                  USING_REQUIREMENT_QUANTITY,
                  DMD_SATISFIED_DATE,
                  USING_ASSEMBLY_DEMAND_DATE,
                  USING_ASSEMBLY_ITEM_ID,
                  DEMAND_TYPE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY)
	SELECT
                FromOrgID,
				ItemID,
				PlanIdVar,
				InstanceID,
				MSC_DEMANDS_S.NEXTVAL, --DEMAND_ID,
				1, --ORIGINATION_TYPE,
				Quantity,	--BUGBUG: how to show Infinity ? --USING_REQUIREMENT_QUANTITY
                TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400, --DMD_SATISFIED_DATE
                TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400, --USING_ASSEMBLY_DEMAND_DATE
                ItemID, --USING_ASSEMBLY_ITEM_ID
                1, --DEMAND_TYPE
                SYSDATE, '-1', SYSDATE, '-1'
	FROM MSC_INT_ASCP_DEPENDENT_DEMAND
        WHERE PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_DEMAND_FROM_ASCP_DEPENDENT_DEMAND_001002' || ' : ' || SQLERRM;
            raise;
    END;

    BEGIN
    -- CODE GOES HERE
    --
    -- populate MSC_DEMANDS from ASCP Transportation (Move Order)
    --
    INSERT INTO MSC_DEMANDS (ORGANIZATION_ID,
			      INVENTORY_ITEM_ID,
                  PLAN_ID,
			      SR_INSTANCE_ID,
			      DEMAND_ID,
                  ORIGINATION_TYPE,
                  USING_REQUIREMENT_QUANTITY,
                  QUANTITY_BY_DUE_DATE,
                  DMD_SATISFIED_DATE,
                  ZONE_ID,
                  CUSTOMER_SITE_ID,
                  CUSTOMER_ID,
                  SERVICE_LEVEL,
                  USING_ASSEMBLY_DEMAND_DATE,
                  USING_ASSEMBLY_ITEM_ID,
                  DEMAND_TYPE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY)
	SELECT
		FromOrgID,
		ItemID,
		PlanIdVar,
		FromInstanceID,
		MSC_DEMANDS_S.NEXTVAL,
		82,
		Quantity,
		Quantity,
        TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
        NULL,
		NULL,
        NULL,
		0,
		TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
		ItemID,
        1,
        SYSDATE, '-1', SYSDATE, '-1'
	FROM MSC_INT_ASCP_TRANSPORTATION
    WHERE PLAN_ID=PlanIdVar AND
          Subcategory <> 'Customer';
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_DEMAND_FROM_ASCP_TRANSPORTATION_001003' || ' : ' || SQLERRM;
            raise;
    END;



    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_DEMANDS;

    PROCEDURE SET_ASCP_SUPPLIES (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation starts here */
   -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_SUPPLIES table for the given PlanIdVar, if any
    BEGIN
     DELETE FROM MSC_SUPPLIES WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;
    -- insert new rows


    BEGIN
          -- CODE GOES HERE
          --
          -- Fill in data from MSC_INT_ASCP_SUPPLY
          --
          INSERT INTO MSC_SUPPLIES (PLAN_ID,
                           TRANSACTION_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   INVENTORY_ITEM_ID,
			   ORDER_TYPE,
			   NEW_SCHEDULE_DATE,
			   NEW_ORDER_QUANTITY,
			   FIRM_PLANNED_TYPE,
                           SUPPLIER_ID,
                           SUPPLIER_SITE_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                                   CREATED_BY)
          SELECT PlanIdVar, msc_supplies_s.nextval, organizationID,
                 instanceID, itemID, 1, TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
                 supply, 2, SupplierID,
                 supplierSiteID,
                 SYSDATE, '-1', SYSDATE, '-1'
          FROM MSC_INT_ASCP_SUPPLY
          WHERE PLAN_ID=PlanIdVar AND MSC_INT_ASCP_SUPPLY.CATEGORY='Supply';

          -- NOTE: Last four fields: LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY are non-NULL,
          -- so I harcoded an arbitrary value
              EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_SUPPLIES_FROM_MSC_INT_ASCP_SUPPLY_001001' || ' : ' || SQLERRM;
                    raise;
    END;

    BEGIN
          -- CODE GOES HERE
          --
          -- Fill in data from MSC_INT_ASCP_TRANSPORTATION
          --
          INSERT INTO MSC_SUPPLIES (
                          PLAN_ID,
                           TRANSACTION_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   INVENTORY_ITEM_ID,
			   ORDER_TYPE,
			   NEW_SCHEDULE_DATE,
			   NEW_ORDER_QUANTITY,
			   FIRM_PLANNED_TYPE,
                           SOURCE_ORGANIZATION_ID,
                           SOURCE_SR_INSTANCE_ID,
                           SHIP_METHOD,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY)
          SELECT
            PlanIdVar,
            msc_supplies_s.nextval,
            toOrgID,
            toInstanceID,
                 itemID,
                 80,
                 TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400,
                 quantity,
                 2,
                 fromOrgID,
                 fromInstanceID,
                 transportMode,
                 SYSDATE, '-1', SYSDATE, '-1'
          FROM MSC_INT_ASCP_TRANSPORTATION
          WHERE PLAN_ID=PlanIdVar AND
                Subcategory <> 'Customer';
              EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_SUPPLIES_FROM_ASCP_TRANSPORTATION_001002' || ' : ' || SQLERRM;
                    raise;
    END;


    BEGIN
        -- CODE GOES HERE
        --
        -- Fill in data from MSC_INT_ASCP_INVENTORY
        --
        INSERT INTO MSC_SUPPLIES (PLAN_ID,
                           TRANSACTION_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   INVENTORY_ITEM_ID,
			   ORDER_TYPE,
			   NEW_SCHEDULE_DATE,
			   NEW_ORDER_QUANTITY,
			   FIRM_PLANNED_TYPE,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY)
          SELECT PlanIdVar, msc_supplies_s.nextval, organizationId, instanceId,
                 itemID, 18, TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400, onHand, 2,
                 SYSDATE, '-1', SYSDATE, '-1'
          FROM MSC_INT_ASCP_INVENTORY
          WHERE PLAN_ID=PlanIdVar AND MSC_INT_ASCP_INVENTORY.CATEGORY='Inventory';
              EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_SUPPLIES_FROM_MSC_INT_ASCP_INVENTORY_001003' || ' : ' || SQLERRM;
                    raise;
    END;

    BEGIN
        -- CODE GOES HERE
        --
        -- Fill in data from MSC_INT_ASCP_MFG_PLAN_MACHINE
        -- Note that the temp table has resource and department id
        -- to distinguish records but these two ids are not relevant
        -- to supplies. As a result if we directly write to the table
        -- we will get duplcates. Change the selection base to pick unique rows.
        --
        INSERT INTO MSC_SUPPLIES (PLAN_ID,
		                         TRANSACTION_ID,
		                         ORGANIZATION_ID,
		                         SR_INSTANCE_ID,
		                         INVENTORY_ITEM_ID,
		                         ORDER_TYPE,
		                         NEW_SCHEDULE_DATE,
		                         NEW_ORDER_QUANTITY,
		                         FIRM_PLANNED_TYPE,
		                         LAST_UPDATE_DATE,
		                         LAST_UPDATED_BY,
		                         CREATION_DATE,
		                         CREATED_BY)
		select PlanIdVar, msc_supplies_s.nextval,
		       organizationID, instanceID, itemID, 88,
		       TO_DATE(PeriodEnd,'YYYY-MM-DD')-1/86400, flow,
		       2,
		       SYSDATE, '-1', SYSDATE, '-1'
                from (
                    ( select distinct organizationID, instanceID, itemID, PeriodEnd, flow
                    from MSC_INT_ASCP_MFG_PLAN_MACHINE where PLAN_ID=PlanIdVar AND CATEGORY='Manufacturing')
                    UNION
                    ( select distinct organizationID, instanceID, itemID, PeriodEnd, flow
                    from MSC_INT_ASCP_MFG_PLAN_LABOUR where PLAN_ID=PlanIdVar AND CATEGORY='Manufacturing') );
            EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_SUPPLIES_FROM_MSC_INT_ASCP_MFG_PLAN_MACHINE_001004' || ' : ' || SQLERRM;
                    raise;
    END;


    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;

  END SET_ASCP_SUPPLIES;



    PROCEDURE SET_ASCP_SAFETY_STOCKS (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation starts here */
   -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_SAFETY_STOCKS table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_SAFETY_STOCKS WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_SAFETY_STOCKS (PLAN_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   INVENTORY_ITEM_ID,
			   PERIOD_START_DATE,
			   SAFETY_STOCK_QUANTITY,
                           TASK_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY)
          SELECT PlanIdVar, OrganizationID, InstanceID,
                 ItemID, TO_DATE(Period,'YYYY-MM-DD'), Safety,
                 ROWNUM, --BUGBUG this value is in, just to make index unique
                 SYSDATE, '-1', SYSDATE, '-1'
          FROM MSC_INT_ASCP_INVENTORY
          WHERE PLAN_ID=PlanIdVar;
          -- NOTE: Last four fields: LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY are non-NULL,
          -- so I harcoded an arbitrary value
              EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_MSC_SAFETY_STOCKS_001001' || ' : ' || SQLERRM;
                    raise;
    END;




    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_SAFETY_STOCKS;


  PROCEDURE SET_ASCP_DEPARTMENT_RESOURCES (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation starts here */
   -- init global variables
    g_ErrorCode := '';


    -- delete records from MSC_DEPARTMENT_RESOURCES table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_DEPARTMENT_RESOURCES WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE
        -- insert records from MSC_INT_ASCP_MACHINE_UTIL
        INSERT INTO MSC_DEPARTMENT_RESOURCES (PLAN_ID,
               ORGANIZATION_ID,
               SR_INSTANCE_ID,
               RESOURCE_ID,
               DEPARTMENT_ID,
               OWNING_DEPARTMENT_ID,
               CAPACITY_UNITS,
               RESOURCE_TYPE,
               RESOURCE_CODE,
               RESOURCE_DESCRIPTION,
               DEPARTMENT_CODE,
               DEPARTMENT_DESCRIPTION,
               DEPARTMENT_CLASS,
               RESOURCE_GROUP_NAME,
               BOTTLENECK_FLAG,
               LINE_FLAG,
               AGGREGATE_RESOURCE_FLAG,
               AVAILABLE_24_HOURS_FLAG,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY)
        SELECT DISTINCT MSC_INT_ASCP_MACHINE_UTIL.PLAN_ID,
               MSC_INT_ASCP_MACHINE_UTIL.OrganizationID,
               MSC_INT_ASCP_MACHINE_UTIL.InstanceID,
               MSC_INT_ASCP_MACHINE_UTIL.ResourceID,
               MSC_INT_ASCP_MACHINE_UTIL.DepartmentID,
               CASE WHEN MSC_INT_ASCP_MACHINE_UTIL.ResourceID = -1
                    THEN NULL
                    ELSE MSC_INT_ASCP_MACHINE_UTIL.DepartmentID
               END,--OWNING_DEPARTMENT_ID
               NULL, --CAPACITY_UNITS: nullable column, resource units
               1, -- RESOURCE_TYPE it is a machine
               MSC_DEPARTMENT_RESOURCES.RESOURCE_CODE, --RESOURCE_CODE *
               MSC_DEPARTMENT_RESOURCES.RESOURCE_DESCRIPTION, --RESOURCE_DESCRIPTION,*
               MSC_DEPARTMENT_RESOURCES.DEPARTMENT_CODE, --DEPARTMENT_CODE,*
               MSC_DEPARTMENT_RESOURCES.DEPARTMENT_DESCRIPTION, --DEPARTMENT_DESCRIPTION,*
               NULL, --DEPARTMENT_CLASS,
               MSC_DEPARTMENT_RESOURCES.RESOURCE_GROUP_NAME, -- resource_group_name*
               MSC_DEPARTMENT_RESOURCES.BOTTLENECK_FLAG, -- bottleneck_flag*
               MSC_DEPARTMENT_RESOURCES.LINE_FLAG, --LINE_FLAG: 1 means line resource, 2 regular resource
               1, --AGGREGATE_RESOURCE_FLAG: fill in with "1"
               MSC_DEPARTMENT_RESOURCES.AVAILABLE_24_HOURS_FLAG,  --Look up the table for the field using PLAN_ID=-1, ORG_ID, INST_ID and DEPT_ID
               SYSDATE, '-1', SYSDATE, '-1'
        FROM MSC_INT_ASCP_MACHINE_UTIL LEFT JOIN MSC_DEPARTMENT_RESOURCES ON
              MSC_INT_ASCP_MACHINE_UTIL.OrganizationID = MSC_DEPARTMENT_RESOURCES.ORGANIZATION_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.InstanceID = MSC_DEPARTMENT_RESOURCES.SR_INSTANCE_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.DepartmentID = MSC_DEPARTMENT_RESOURCES.DEPARTMENT_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.ResourceID = MSC_DEPARTMENT_RESOURCES.RESOURCE_ID
        WHERE  MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND MSC_INT_ASCP_MACHINE_UTIL.PLAN_ID=PlanIdVar;
        EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_DEPARTMENT_RESOURCES_FROM_MSC_INT_ASCP_MACHINE_UTIL_001001' || ' : ' || SQLERRM;
                    raise;
    END;

    BEGIN
        -- CODE GOES HERE
        -- insert records from MSC_INT_ASCP_LABOUR_UTIL
        INSERT INTO MSC_DEPARTMENT_RESOURCES (PLAN_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
                           RESOURCE_ID,
			   DEPARTMENT_ID,
			   OWNING_DEPARTMENT_ID,
			   CAPACITY_UNITS,
                           RESOURCE_TYPE,
			   RESOURCE_CODE,
                           RESOURCE_DESCRIPTION,
                           DEPARTMENT_CODE,
                           DEPARTMENT_DESCRIPTION,
                           DEPARTMENT_CLASS,
                           RESOURCE_GROUP_NAME,
                           BOTTLENECK_FLAG,
                           LINE_FLAG,
			   AGGREGATE_RESOURCE_FLAG,
			   AVAILABLE_24_HOURS_FLAG,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY)
  SELECT DISTINCT MSC_INT_ASCP_LABOUR_UTIL.PLAN_ID,
         MSC_INT_ASCP_LABOUR_UTIL.OrganizationID,
         MSC_INT_ASCP_LABOUR_UTIL.InstanceID,
         MSC_INT_ASCP_LABOUR_UTIL.ResourceID,
         MSC_INT_ASCP_LABOUR_UTIL.DepartmentID,
         CASE WHEN MSC_INT_ASCP_LABOUR_UTIL.ResourceID = -1
              THEN NULL
              ELSE MSC_INT_ASCP_LABOUR_UTIL.DepartmentID
         END,--OWNING_DEPARTMENT_ID
         NULL, --CAPACITY_UNITS: nullable column, resource units
         2, -- RESOURCE_TYPE - it is a labour
         MSC_DEPARTMENT_RESOURCES.RESOURCE_CODE, --RESOURCE_CODE *
         MSC_DEPARTMENT_RESOURCES.RESOURCE_DESCRIPTION, --RESOURCE_DESCRIPTION,*
         MSC_DEPARTMENT_RESOURCES.DEPARTMENT_CODE, --DEPARTMENT_CODE,*
         MSC_DEPARTMENT_RESOURCES.DEPARTMENT_DESCRIPTION, --DEPARTMENT_DESCRIPTION,*
         NULL, --DEPARTMENT_CLASS,
         MSC_DEPARTMENT_RESOURCES.RESOURCE_GROUP_NAME, -- resource_group_name*
         MSC_DEPARTMENT_RESOURCES.BOTTLENECK_FLAG, -- bottleneck_flag*
         MSC_DEPARTMENT_RESOURCES.LINE_FLAG, --LINE_FLAG: 1 means line resource, 2 regular resource
         1, --AGGREGATE_RESOURCE_FLAG: fill in with "1"
         MSC_DEPARTMENT_RESOURCES.AVAILABLE_24_HOURS_FLAG,  --Look up the table for the field using PLAN_ID=-1, ORG_ID, INST_ID and DEPT_ID
         SYSDATE, '-1', SYSDATE, '-1'
  FROM MSC_INT_ASCP_LABOUR_UTIL LEFT JOIN MSC_DEPARTMENT_RESOURCES ON
              MSC_INT_ASCP_LABOUR_UTIL.OrganizationID = MSC_DEPARTMENT_RESOURCES.ORGANIZATION_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.InstanceID = MSC_DEPARTMENT_RESOURCES.SR_INSTANCE_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.DepartmentID = MSC_DEPARTMENT_RESOURCES.DEPARTMENT_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.ResourceID = MSC_DEPARTMENT_RESOURCES.RESOURCE_ID
        WHERE  MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND MSC_INT_ASCP_LABOUR_UTIL.PLAN_ID=PlanIdVar;
        EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_DEPARTMENT_RESOURCES_FROM_MSC_INT_ASCP_LABOUR_UTIL_001002' || ' : ' || SQLERRM;
                    raise;
    END;



    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_DEPARTMENT_RESOURCES;

  PROCEDURE SET_ASCP_RES_SUMMARY (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER,
	ScenarioNameVar      OUT NOCOPY VARCHAR2
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation starts here */
    -- init global variables
    g_ErrorCode := '';
    ScenarioNameVar := '';


    -- delete records from MSC_RES_SUMMARY table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_BIS_RES_SUMMARY WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
    select DISTINCT ScenarioName into ScenarioNameVar from MSC_INT_ASCP_KPI where  PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      ScenarioNameVar := '';
    END;

    BEGIN
        -- CODE GOES HERE
        -- insert records from MSC_INT_ASCP_MACHINE_UTIL
        INSERT INTO MSC_BIS_RES_SUMMARY (PLAN_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   DEPARTMENT_ID,
			   RESOURCE_ID,
			   DETAIL_LEVEL,
			   PERIOD_TYPE,
			   RESOURCE_DATE,
			   REQUIRED_HOURS,
			   AVAILABLE_HOURS,
			   UTILIZATION,
			   RESOURCE_GROUP,
			   OVERUTILIZATION_COST,
                           RESOURCE_COST)
        SELECT MSC_INT_ASCP_MACHINE_UTIL.PLAN_ID, MSC_INT_ASCP_MACHINE_UTIL.OrganizationID,
               MSC_INT_ASCP_MACHINE_UTIL.InstanceID, MSC_INT_ASCP_MACHINE_UTIL.DepartmentID, MSC_INT_ASCP_MACHINE_UTIL.ResourceID,
               CASE WHEN MSC_INT_ASCP_MACHINE_UTIL.DETAIL_LEVEL='Week' THEN '1' ELSE NULL END, 1,
               TO_DATE(MSC_INT_ASCP_MACHINE_UTIL.PERIODEND,'YYYY-MM-DD')-1/86400, MSC_INT_ASCP_MACHINE_UTIL.USED,
               MSC_INT_ASCP_MACHINE_UTIL.CAPACITY, MSC_INT_ASCP_MACHINE_UTIL.UTILIZATION,
               MSC_DEPARTMENT_RESOURCES.RESOURCE_GROUP_NAME, MSC_INT_ASCP_MACHINE_UTIL.OVERCOST,
               NVL(MSC_INT_ASCP_KPI.PRODUCTIONCOST, 0)
        FROM MSC_INT_ASCP_MACHINE_UTIL, MSC_DEPARTMENT_RESOURCES, MSC_INT_ASCP_KPI
        WHERE MSC_INT_ASCP_MACHINE_UTIL.PLAN_ID=PlanIdVar AND
              MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND
              MSC_INT_ASCP_MACHINE_UTIL.OrganizationID = MSC_DEPARTMENT_RESOURCES.ORGANIZATION_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.InstanceID = MSC_DEPARTMENT_RESOURCES.SR_INSTANCE_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.DepartmentID = MSC_DEPARTMENT_RESOURCES.DEPARTMENT_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.ResourceID = MSC_DEPARTMENT_RESOURCES.RESOURCE_ID AND
              MSC_INT_ASCP_MACHINE_UTIL.PLAN_ID = MSC_INT_ASCP_KPI.PLAN_ID (+) AND
              MSC_INT_ASCP_MACHINE_UTIL.InstanceID = MSC_INT_ASCP_KPI.INSTANCEID (+) AND
              MSC_INT_ASCP_MACHINE_UTIL.OrganizationID = MSC_INT_ASCP_KPI.ORGANIZATIONID (+) AND
              MSC_INT_ASCP_MACHINE_UTIL.DepartmentID = MSC_INT_ASCP_KPI.ITEMID (+) AND -- the dept and item are toggled due to lack of category
              MSC_INT_ASCP_MACHINE_UTIL.ResourceID = MSC_INT_ASCP_KPI.DEPARTMENTID (+) AND -- toggled dept and resource id because in KPI export
              MSC_INT_ASCP_MACHINE_UTIL.PERIODEND = MSC_INT_ASCP_KPI.PERIODEND (+);
        EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_RES_SUMMARY_FROM_MSC_INT_ASCP_MACHINE_UTIL_001001' || ' : ' || SQLERRM;
                    raise;
    END;

    BEGIN
        -- CODE GOES HERE
        -- insert records from MSC_INT_ASCP_LABOUR_UTIL
        INSERT INTO MSC_BIS_RES_SUMMARY (PLAN_ID,
                           ORGANIZATION_ID,
			   SR_INSTANCE_ID,
			   DEPARTMENT_ID,
			   RESOURCE_ID,
			   DETAIL_LEVEL,
			   PERIOD_TYPE,
			   RESOURCE_DATE,
			   REQUIRED_HOURS,
			   AVAILABLE_HOURS,
			   UTILIZATION,
			   RESOURCE_GROUP,
			   OVERUTILIZATION_COST,
                           RESOURCE_COST)
        SELECT MSC_INT_ASCP_LABOUR_UTIL.PLAN_ID, MSC_INT_ASCP_LABOUR_UTIL.OrganizationID,
               MSC_INT_ASCP_LABOUR_UTIL.InstanceID, MSC_INT_ASCP_LABOUR_UTIL.DepartmentID,
               MSC_INT_ASCP_LABOUR_UTIL.ResourceID,
               CASE WHEN MSC_INT_ASCP_LABOUR_UTIL.DETAIL_LEVEL='Week' THEN '1' ELSE NULL END, 1,
               TO_DATE(MSC_INT_ASCP_LABOUR_UTIL.PERIODEND,'YYYY-MM-DD')-1/86400, MSC_INT_ASCP_LABOUR_UTIL.USED,
               MSC_INT_ASCP_LABOUR_UTIL.CAPACITY, MSC_INT_ASCP_LABOUR_UTIL.UTILIZATION,
               MSC_DEPARTMENT_RESOURCES.RESOURCE_GROUP_NAME, MSC_INT_ASCP_LABOUR_UTIL.OVERCOST,
               NVL(MSC_INT_ASCP_KPI.PRODUCTIONCOST, 0 )
        FROM MSC_INT_ASCP_LABOUR_UTIL, MSC_DEPARTMENT_RESOURCES, MSC_INT_ASCP_KPI
        WHERE MSC_INT_ASCP_LABOUR_UTIL.PLAN_ID=PlanIdVar AND
              MSC_DEPARTMENT_RESOURCES.PLAN_ID=-1 AND
              MSC_INT_ASCP_LABOUR_UTIL.OrganizationID = MSC_DEPARTMENT_RESOURCES.ORGANIZATION_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.InstanceID = MSC_DEPARTMENT_RESOURCES.SR_INSTANCE_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.DepartmentID = MSC_DEPARTMENT_RESOURCES.DEPARTMENT_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.ResourceID = MSC_DEPARTMENT_RESOURCES.RESOURCE_ID AND
              MSC_INT_ASCP_LABOUR_UTIL.PLAN_ID = MSC_INT_ASCP_KPI.PLAN_ID (+) AND
              MSC_INT_ASCP_LABOUR_UTIL.InstanceID = MSC_INT_ASCP_KPI.INSTANCEID (+) AND
              MSC_INT_ASCP_LABOUR_UTIL.OrganizationID = MSC_INT_ASCP_KPI.ORGANIZATIONID (+) AND
              MSC_INT_ASCP_LABOUR_UTIL.DepartmentID = MSC_INT_ASCP_KPI.ITEMID (+) AND
              MSC_INT_ASCP_LABOUR_UTIL.ResourceID = MSC_INT_ASCP_KPI.DEPARTMENTID (+) AND
              MSC_INT_ASCP_LABOUR_UTIL.PERIODEND = MSC_INT_ASCP_KPI.PERIODEND (+);
        EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UPDATE_RES_SUMMARY_FROM_MSC_INT_ASCP_LABOUR_UTIL_001002' || ' : ' || SQLERRM;
                    raise;
    END;



    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_RES_SUMMARY;

PROCEDURE SET_ASCP_BIS_INV_DETAIL (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    /* implementation starts here */
    -- init global variables
    g_ErrorCode := '';


    -- delete all from  temporary tables to aid in the calculation of ProductionCost in the main procedure...

    BEGIN
    DELETE FROM msc_int_ascp_prodcost_kpi; -- where msc_int_ascp_prodcost_kpi.plan_id=PlanIdVar; --??BUGBUG ??
    EXCEPTION WHEN others THEN
      g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001001' || ' : ' || SQLERRM;
      raise;
    END;

    BEGIN
    DELETE FROM msc_int_ascp_totalprodcost; -- where msc_int_ascp_totalprodcost.plan_id=PlanIdVar; --??BUGBUG ??
    EXCEPTION WHEN others THEN
      g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001002' || ' : ' || SQLERRM;
      raise;
    END;


    -- delete records from MSC_BIS_INV_DETAIL table for the given PlanId, if any
    BEGIN
    DELETE FROM MSC_BIS_INV_DETAIL WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    BEGIN
        -- CODE GOES HERE
        -- fill in data from msc_int_ascp_mfg_plan_labour and msc_int_ascp_mfg_plan_machine
        INSERT INTO msc_int_ascp_prodcost_kpi ( plan_id,
            organizationID,
            instanceID,
            itemID,
            periodEnd,
            prodCost )
        SELECT plan_id, organizationID, instanceID, itemID, periodEnd, SUM(resourcecost*resourceusage)
          FROM msc_int_ascp_mfg_plan_machine
          WHERE plan_id=PlanIdVar
          GROUP BY plan_id, organizationID, instanceID, itemID, periodEnd;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001004' || ' : ' || SQLERRM;
            raise;
    END;

    BEGIN
        -- CODE GOES HERE
        -- fill in data from msc_int_ascp_mfg_plan_labour and msc_int_ascp_mfg_plan_machine
        INSERT INTO msc_int_ascp_prodcost_kpi ( plan_id,
                    organizationID,
                    instanceID,
                    itemID,
                    periodEnd,
                    prodCost )
        SELECT plan_id, organizationID, instanceID, itemID, periodEnd, SUM
(resourcecost*resourceusage)
              FROM msc_int_ascp_mfg_plan_labour
              WHERE plan_id=PlanIdVar
              GROUP BY plan_id, organizationID, instanceID, itemID, periodEnd;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001005' || ' : ' || SQLERRM;
            raise;
    END;

    BEGIN
        -- CODE GOES HERE
        -- fill in data from msc_int_ascp_prodcost_kpi
        -- Due to reansporation cost being mvoed out of msc_int_ascp_kpi, the table
	-- no longer has corresponding org-item records for heere to compare. But the
	-- records are already unique so we directly sum them up.
        INSERT INTO msc_int_ascp_totalprodcost ( plan_id,
                  organizationID,
                  instanceID,
                  itemID,
                  periodEnd,
                  totalProdCost )
              SELECT msc_int_ascp_prodcost_kpi.plan_id,
msc_int_ascp_prodcost_kpi.organizationID, msc_int_ascp_prodcost_kpi.instanceID,
                  msc_int_ascp_prodcost_kpi.itemID, msc_int_ascp_prodcost_kpi.periodEnd,
SUM(msc_int_ascp_prodcost_kpi.prodCost)
              FROM msc_int_ascp_prodcost_kpi
              --, MSC_INT_ASCP_KPI
              WHERE
              --MSC_INT_ASCP_KPI.PLAN_ID=PlanIdVar AND
                    msc_int_ascp_prodcost_kpi.plan_id=PlanIdVar -- AND
                    --msc_int_ascp_prodcost_kpi.organizationID=MSC_INT_ASCP_KPI.OrganizationID AND
                    --msc_int_ascp_prodcost_kpi.itemID=MSC_INT_ASCP_KPI.ItemID AND
                    --msc_int_ascp_prodcost_kpi.periodEnd=MSC_INT_ASCP_KPI.PERIODEND AND
                    --msc_int_ascp_prodcost_kpi.instanceID=MSC_INT_ASCP_KPI.InstanceID
              GROUP BY msc_int_ascp_prodcost_kpi.plan_id,
msc_int_ascp_prodcost_kpi.organizationID, msc_int_ascp_prodcost_kpi.instanceID,
                    msc_int_ascp_prodcost_kpi.itemID, msc_int_ascp_prodcost_kpi.PeriodEnd;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001006' || ' : ' || SQLERRM;
            raise;
    END;

    -- final table: MSC_BIS_INV_DETAIL

    ----------------------------------------
    -- Purchasing cost
    ----------------------------------------
    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_BIS_INV_DETAIL (PLAN_ID,
                                        ORGANIZATION_ID,
                                        SR_INSTANCE_ID,
                                        INVENTORY_ITEM_ID,
                                        DETAIL_LEVEL,
                                        PERIOD_TYPE,
                                        DETAIL_DATE,
                                        MDS_PRICE,
                                        ZONE_ID,
                                        PRODUCTION_COST,
                                        PURCHASING_COST,
                                        CARRYING_COST,
                                        TRANSPORTATION_COST,
                                        OTHER_COST,
                                        PAB,
                                        TOTAL_COST,
                                        SERVICE_LEVEL_1,
                                        SERVICE_LEVEL_2,
                                        SHIP_METHOD,
                                        SUPPLIER_ID,
                                        SUPPLIER_SITE_ID,
                                        SUPPLIER_USAGE,
                                        SUPPLIER_CAPACITY,
                                        SOURCE_ORG_INSTANCE_ID,
										SOURCE_ORGANIZATION_ID,
										CUSTOMER_SITE_ID,
										CUSTOMER_ID,
                                        MDS_QUANTITY,
                                        INVENTORY_QUANTITY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY)
                --------------------------------
                -- Supplier-dependent records
                --------------------------------
                SELECT MSC_INT_ASCP_SUPPLY.PLAN_ID,
                     MSC_INT_ASCP_SUPPLY.OrganizationID,
                     MSC_INT_ASCP_SUPPLY.InstanceID,
                     MSC_INT_ASCP_SUPPLY.ItemID,
                     ( select DISTINCT MSC_INT_ASCP_KPI.PeriodType from MSC_INT_ASCP_KPI where MSC_INT_ASCP_KPI.PLAN_ID = PlanIdVar ), -- we do not have it ASCP_Supply report ( BUGBUG does not accept FIRST )
                     1,
                     TO_DATE( MSC_INT_ASCP_SUPPLY.PeriodEnd,'YYYY-MM-DD' )-1/86400,
                     0, --TO_NUMBER(NULL) MDS_PRICE,
                     -23453, -- ZONEID,
                     0, --TO_NUMBER(NULL) PRODUCTION_COST,
                     -- supplier related column: purchase cost
                     MSC_INT_ASCP_SUPPLY.COST * MSC_INT_ASCP_SUPPLY.SUPPLY,
                     0,--TO_NUMBER(NULL) CARRYING_COST,
                     0,--TO_NUMBER(NULL) TRANSPORTATION_COST,
                     0,--TO_NUMBER(NULL) OTHER_COST,
                     0,--TO_NUMBER(NULL) PAB,
                     0,--TO_NUMBER(NULL) TOTAL_COST,
                     0,--TO_NUMBER(NULL) SERVICE_LEVEL_1,
                     0,--TO_NUMBER(NULL) SERVICE_LEVEL_2,
                     null,--TO_CHAR(NULL) SHIP_METHOD,
                     -- supplier related columns
                     MSC_INT_ASCP_SUPPLY.SupplierID,
                     MSC_INT_ASCP_SUPPLY.SupplierSiteID,
                     MSC_INT_ASCP_SUPPLY.SUPPLY,
                     MSC_INT_ASCP_SUPPLY.CAPACITY,
                     -23453, -- SOURCE_ORG_INSTANCE_ID
                     -23453, -- SOURCE_ORGANIZATION_ID
                     -23453, -- CUSTOMER_SITE_ID
		     -23453, -- CUSTOMER_ID
                     0,--TO_NUMBER(NULL) MDS_QUANTITY,
                     0,--TO_NUMBER(NULL) INVENTORY_QUANTITY,
                     SYSDATE, '-1', SYSDATE, '-1'
                FROM MSC_INT_ASCP_SUPPLY
                WHERE MSC_INT_ASCP_SUPPLY.PLAN_ID=PlanIdVar;
		EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001008'  || ' : ' || SQLERRM;
            raise;
	END;

	----------------------------------------
    -- Transportation cost + Contrained Forecast
    ----------------------------------------
    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_BIS_INV_DETAIL (PLAN_ID,
                                        ORGANIZATION_ID,
                                        SR_INSTANCE_ID,
                                        INVENTORY_ITEM_ID,
                                        DETAIL_LEVEL,
                                        PERIOD_TYPE,
                                        DETAIL_DATE,
										SHIP_METHOD,
										TRANSPORTATION_COST,
                                        MDS_QUANTITY,
                                        INVENTORY_QUANTITY,
                                        SUPPLIER_ID,
										SUPPLIER_SITE_ID,
										SOURCE_ORG_INSTANCE_ID,
										SOURCE_ORGANIZATION_ID,
										ZONE_ID,
										CUSTOMER_SITE_ID,
										CUSTOMER_ID,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN)
	SELECT
			PlanIdVar,
			-- Next 2 lines are changed to accomodate the S&OP request to populate dest org with source org when shipping to a customer:
			-- case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN -23453 else MSC_INT_ASCP_TRANSPORTATION.ToOrgID end,
			-- case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN -23453 else MSC_INT_ASCP_TRANSPORTATION.ToInstanceID end,
			case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN MSC_INT_ASCP_TRANSPORTATION.FromOrgID else MSC_INT_ASCP_TRANSPORTATION.ToOrgID end,
			case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN MSC_INT_ASCP_TRANSPORTATION.FromInstanceID else MSC_INT_ASCP_TRANSPORTATION.ToInstanceID end,
			MSC_INT_ASCP_TRANSPORTATION.ItemID,
			( select DISTINCT MSC_INT_ASCP_KPI.PeriodType from MSC_INT_ASCP_KPI where MSC_INT_ASCP_KPI.PLAN_ID = PlanIdVar ), -- we do not have it ASCP_Transportation report, -- DETAIL_LEVEL ( BUGBUG does not accept FIRST )
			1, --PERIOD_TYPE
			TO_DATE( MSC_INT_ASCP_TRANSPORTATION.PeriodEnd,'YYYY-MM-DD' )-1/86400,
			MSC_INT_ASCP_TRANSPORTATION.TransportMode,
			MSC_INT_ASCP_TRANSPORTATION.Cost * MSC_INT_ASCP_TRANSPORTATION.Quantity,
			-- Constrained Forecast
CASE
				WHEN MSC_INT_ASCP_TRANSPORTATION.CATEGORY='Transportation' THEN
                                ( case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Inter-Organization' then
					( case when (select count( MSC_INT_ASCP_DEMANDS.Satisfied ) from MSC_INT_ASCP_DEMANDS
					where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
					MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
					MSC_INT_ASCP_DEMANDS.InstanceID = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
					MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
					MSC_INT_ASCP_DEMANDS.OrganizationID = MSC_INT_ASCP_TRANSPORTATION.ToOrgID  and
					MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd ) > 0 then ( select MSC_INT_ASCP_DEMANDS.Satisfied from MSC_INT_ASCP_DEMANDS
					where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
					MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
					MSC_INT_ASCP_DEMANDS.InstanceID = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
					MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
					MSC_INT_ASCP_DEMANDS.OrganizationID = MSC_INT_ASCP_TRANSPORTATION.ToOrgID  and
					MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd )  else 0 end )
				  else
					( case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' then
						( case when ( SELECT COUNT( MSC_INT_ASCP_DEMANDS.Satisfied ) from MSC_INT_ASCP_DEMANDS
							where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
							MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
              ( MSC_INT_ASCP_DEMANDS.ZoneID is not null ) AND ( INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1) = 0 )  and
							TO_NUMBER(MSC_INT_ASCP_DEMANDS.ZoneID) = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
							MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
							--MSC_INT_ASCP_DEMANDS.OrganizationID = -1 and --BUGBUG Constrained Forecast - SS in ??
							--MSC_INT_ASCP_TRANSPORTATION.ToOrgID is NULL and --BUGBUG Constrained Forecast - SS in ??
							MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd ) > 0 then
                                                  ( select MSC_INT_ASCP_DEMANDS.Satisfied from MSC_INT_ASCP_DEMANDS
							where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
							MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
              ( MSC_INT_ASCP_DEMANDS.ZoneID is not null ) AND ( INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1) = 0 )  and
							TO_NUMBER(MSC_INT_ASCP_DEMANDS.ZoneID) = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
							MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
							--MSC_INT_ASCP_DEMANDS.OrganizationID = -1 and --BUGBUG Constrained Forecast - SS in ??
							--MSC_INT_ASCP_TRANSPORTATION.ToOrgID is NULL and --BUGBUG Constrained Forecast - SS in ??
							MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd )
						else ( case when ( SELECT COUNT( MSC_INT_ASCP_DEMANDS.Satisfied ) from MSC_INT_ASCP_DEMANDS
							where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
							MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
              ( MSC_INT_ASCP_DEMANDS.ZoneID is not null ) AND ( INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1) <> 0 ) and
							TO_NUMBER( SUBSTR(MSC_INT_ASCP_DEMANDS.ZoneID, INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1)+1) )= MSC_INT_ASCP_TRANSPORTATION.ToOrgID  and
							MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
							TO_NUMBER( SUBSTR(MSC_INT_ASCP_DEMANDS.ZoneID, 1, INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1)-1) ) = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
							MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd) > 0 then
                                                       ( select MSC_INT_ASCP_DEMANDS.Satisfied from MSC_INT_ASCP_DEMANDS
							where MSC_INT_ASCP_DEMANDS.Category ='Demand' and
							MSC_INT_ASCP_DEMANDS.PLAN_ID = planIdVar and
              ( MSC_INT_ASCP_DEMANDS.ZoneID is not null ) AND ( INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1) <> 0 ) and
							TO_NUMBER( SUBSTR(MSC_INT_ASCP_DEMANDS.ZoneID, INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1)+1) ) = MSC_INT_ASCP_TRANSPORTATION.ToOrgID  and
							MSC_INT_ASCP_DEMANDS.ItemID = MSC_INT_ASCP_TRANSPORTATION.ItemID  and
							TO_NUMBER( SUBSTR(MSC_INT_ASCP_DEMANDS.ZoneID, 1, INSTR(MSC_INT_ASCP_DEMANDS.ZoneID,':',1,1)-1) ) = MSC_INT_ASCP_TRANSPORTATION.ToInstanceID  and
							MSC_INT_ASCP_DEMANDS.PeriodEnd = MSC_INT_ASCP_TRANSPORTATION.PeriodEnd ) else 0	end )
                                                end )
                                          else 0
                                          end   )
                                  end  )
			ELSE 0
			END,
			0,
			-23453, --SUPPLIER_ID
			-23453, --SUPPLIER_SITE_ID
			MSC_INT_ASCP_TRANSPORTATION.FromInstanceID, --SOURCE_ORG_INSTANCE_ID
			MSC_INT_ASCP_TRANSPORTATION.FromOrgID, --SOURCE_ORGANIZATION_ID

			--Zone_Id
			case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN
				CASE WHEN ( ToInstanceID is not null ) AND (  ToOrgID is null )
                THEN ToInstanceID
                else -23453 end
            ELSE
               -23453
            END,

            --Customer_Site_Id
            case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN
				CASE WHEN ( ToInstanceID is not null ) AND ( ToOrgID is not null )
                THEN ToOrgID
                else -23453 end
             ELSE
                -23453
             END,
            -- Customer_Id
            case when MSC_INT_ASCP_TRANSPORTATION.SUBCATEGORY='Customer' THEN
                CASE WHEN ( ToInstanceID is not null ) AND ( ToOrgID is not null )
                THEN ToInstanceID
                else -23453 end
            ELSE
              -23453
            END,
            SYSDATE, '-1',
            SYSDATE, '-1',
            -1
 	FROM MSC_INT_ASCP_TRANSPORTATION
        WHERE  MSC_INT_ASCP_TRANSPORTATION.PLAN_ID=PlanIdVar;
		EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001009'  || ' : ' || SQLERRM;
            raise;
	END;

	BEGIN
                --------------------------------
                -- Supplier-independent records ( Revenue, Production, Carry and Other costs )
                --------------------------------
                INSERT INTO MSC_BIS_INV_DETAIL (PLAN_ID,
                                        ORGANIZATION_ID,
                                        SR_INSTANCE_ID,
                                        INVENTORY_ITEM_ID,
                                        DETAIL_LEVEL,
                                        PERIOD_TYPE,
                                        DETAIL_DATE,
                                        MDS_PRICE,
                                        SOURCE_ORG_INSTANCE_ID,
										SOURCE_ORGANIZATION_ID,
										ZONE_ID,
										CUSTOMER_SITE_ID,
										CUSTOMER_ID,
                                        PRODUCTION_COST,
                                        CARRYING_COST,
                                        OTHER_COST,
                                        PAB,
                                        SERVICE_LEVEL_1,
                                        SERVICE_LEVEL_2,
                                        SUPPLIER_ID,
                                        SUPPLIER_SITE_ID,
                                        SUPPLIER_USAGE,
                                        SUPPLIER_CAPACITY,
                                        MDS_QUANTITY,
                                        INVENTORY_QUANTITY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY)
						SELECT MSC_INT_ASCP_KPI.PLAN_ID,
						-- Next 2 lines are changed to accomodate the S&OP request to populate dest org with source org when shipping to a customer:
						-- case when MSC_INT_ASCP_KPI.DemandCost<>0 then Source_Organization_ID else MSC_INT_ASCP_KPI.OrganizationID end,
						-- case when MSC_INT_ASCP_KPI.DemandCost<>0 then Source_Org_Instance_ID else MSC_INT_ASCP_KPI.InstanceID end,
                       case when MSC_INT_ASCP_KPI.DemandCost<>0 AND OrganizationID = -23453 THEN Source_Organization_ID ELSE OrganizationID END,
                       case when MSC_INT_ASCP_KPI.DemandCost<>0 AND InstanceID = -23453 THEN Source_Org_Instance_ID ELSE InstanceID END,
                       MSC_INT_ASCP_KPI.ItemID,
                       MSC_INT_ASCP_KPI.PeriodType,
                       1,
                       TO_DATE( MSC_INT_ASCP_KPI.PeriodEnd,'YYYY-MM-DD' )-1/86400,
                       -- demand cost
                       MSC_INT_ASCP_KPI.DemandCost,
					   case when MSC_INT_ASCP_KPI.DemandCost<>0 then Source_Org_Instance_ID else -23453 end, -- SOURCE_ORG_INSTANCE_ID,
					   case when MSC_INT_ASCP_KPI.DemandCost<>0 then Source_Organization_ID else -23453 end, -- SOURCE_ORGANIZATION_ID,
                       MSC_INT_ASCP_KPI.ZoneID,
                       MSC_INT_ASCP_KPI.Customer_Site_ID, --CUSTOMER_SITE_ID,
                       MSC_INT_ASCP_KPI.Customer_ID, --CUSTOMER_ID,

                       -- production_cost: added as separate records
                       0,
                       --case when (SELECT COUNT(*) FROM msc_int_ascp_totalprodcost
                       --             WHERE PLAN_ID=PlanIdVar AND
                       --                   OrganizationID=MSC_INT_ASCP_KPI.OrganizationID AND
                       --                   ItemID=MSC_INT_ASCP_KPI.ItemID AND
                       --                   PERIODEND=MSC_INT_ASCP_KPI.PERIODEND AND
                       --                   InstanceID=MSC_INT_ASCP_KPI.InstanceID
                       --             )=0 then 0
                       --  else (SELECT DISTINCT ( totalProdCost ) FROM -- ( BUGBUG Does not accept FIRST )
			--				   msc_int_ascp_totalprodcost
                       --        WHERE PLAN_ID=PlanIdVar AND
                       --              OrganizationID=MSC_INT_ASCP_KPI.OrganizationID AND
                       --              ItemID=MSC_INT_ASCP_KPI.ItemID AND
                       --              PERIODEND=MSC_INT_ASCP_KPI.PERIODEND AND
                       --              InstanceID=MSC_INT_ASCP_KPI.InstanceID)
                       --end,

                       -- carrying cost
                       MSC_INT_ASCP_KPI.InventoryCost,

                       -- other cost
                       MSC_INT_ASCP_KPI.OtherCost,
                       -- PAB
                       case when (SELECT COUNT(*) FROM MSC_INT_ASCP_INVENTORY
                                    WHERE PLAN_ID=PlanIdVar AND
                                          OrganizationID=MSC_INT_ASCP_KPI.OrganizationID AND
                                          ItemID=MSC_INT_ASCP_KPI.ItemID AND
                                          PERIODEND=MSC_INT_ASCP_KPI.PERIODEND AND
                                          InstanceID=MSC_INT_ASCP_KPI.InstanceID
                                   )=0 then 0
                        else (SELECT DISTINCT ( StorageAmount ) FROM MSC_INT_ASCP_INVENTORY -- ( BUGBUG Does not accept FIRST )
							WHERE
                                 PLAN_ID=PlanIdVar AND
                                 OrganizationID=MSC_INT_ASCP_KPI.OrganizationID AND
                                 ItemID=MSC_INT_ASCP_KPI.ItemID AND
                                 PERIODEND=MSC_INT_ASCP_KPI.PERIODEND AND
                                 InstanceID=MSC_INT_ASCP_KPI.InstanceID )
                       end,
                       MSC_INT_ASCP_KPI.DemandFillRate,
                       1,
                       -- supplier related columns
                       -23453, --SUPPLIER_ID,
                       -23453, --SUPPLIER_SITE_ID,
                       0,-- TO_NUMBER(NULL) SUPPLIER_USAGE,
                       0,-- TO_NUMBER(NULL) SUPPLIER_CAPACITY,
                       0,
                       0,
                       SYSDATE, '-1', SYSDATE, '-1'
                FROM MSC_INT_ASCP_KPI
                WHERE MSC_INT_ASCP_KPI.PLAN_ID=PlanIdVar;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001009' || ' : ' || SQLERRM;
            raise;

    END;

    ----------------------------------------------
    -- Production cost: totalprodcost doesn't
    -- necessarily have same org-item combo
    -- as msc_int_ascp_kpi, so we insert ditectly
    -- from total prod cost
    ----------------------------------------------
    BEGIN
        INSERT INTO MSC_BIS_INV_DETAIL (PLAN_ID,
                                        ORGANIZATION_ID,
                                        SR_INSTANCE_ID,
                                        INVENTORY_ITEM_ID,
                                        DETAIL_LEVEL,
                                        PERIOD_TYPE,
                                        DETAIL_DATE,
                                        MDS_PRICE,
                                        ZONE_ID,
                                        PRODUCTION_COST,
                                        PURCHASING_COST,
                                        CARRYING_COST,
                                        TRANSPORTATION_COST,
                                        OTHER_COST,
                                        PAB,
                                        TOTAL_COST,
                                        SERVICE_LEVEL_1,
                                        SERVICE_LEVEL_2,
                                        SHIP_METHOD,
                                        SUPPLIER_ID,
                                        SUPPLIER_SITE_ID,
                                        SUPPLIER_USAGE,
                                        SUPPLIER_CAPACITY,
                                        SOURCE_ORG_INSTANCE_ID,
					SOURCE_ORGANIZATION_ID,
					CUSTOMER_SITE_ID,
					CUSTOMER_ID,
                                        MDS_QUANTITY,
                                        INVENTORY_QUANTITY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY)
                SELECT msc_int_ascp_totalprodcost.PLAN_ID,
                     msc_int_ascp_totalprodcost.OrganizationID,
                     msc_int_ascp_totalprodcost.InstanceID,
                     msc_int_ascp_totalprodcost.ItemID,
                     ( select DISTINCT MSC_INT_ASCP_KPI.PeriodType from MSC_INT_ASCP_KPI where MSC_INT_ASCP_KPI.PLAN_ID = PlanIdVar ), -- we do not have it ASCP_Supply report ( BUGBUG does not accept FIRST )
                     1,
                     TO_DATE( msc_int_ascp_totalprodcost.PeriodEnd,'YYYY-MM-DD' )-1/86400,
                     0, --TO_NUMBER(NULL) MDS_PRICE,
                     -23453, -- ZONEID,

                     msc_int_ascp_totalprodcost.totalprodcost,
                     0, -- purchase cost
                     0,--TO_NUMBER(NULL) CARRYING_COST,
                     0,--TO_NUMBER(NULL) TRANSPORTATION_COST,
                     0,--TO_NUMBER(NULL) OTHER_COST,
                     0,--TO_NUMBER(NULL) PAB,
                     0,--TO_NUMBER(NULL) TOTAL_COST,
                     0,--TO_NUMBER(NULL) SERVICE_LEVEL_1,
                     0,--TO_NUMBER(NULL) SERVICE_LEVEL_2,
                     null,--TO_CHAR(NULL) SHIP_METHOD,
                     -23453,
                     -23453,
                     0,
                     0,
                     -23453, -- SOURCE_ORG_INSTANCE_ID
                     -23453, -- SOURCE_ORGANIZATION_ID
                     -23453, -- CUSTOMER_SITE_ID
		     -23453, -- CUSTOMER_ID
                     0,--TO_NUMBER(NULL) MDS_QUANTITY,
                     0,--TO_NUMBER(NULL) INVENTORY_QUANTITY,
                     SYSDATE, '-1', SYSDATE, '-1'
                FROM msc_int_ascp_totalprodcost
                WHERE msc_int_ascp_totalprodcost.PLAN_ID=PlanIdVar;
		EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001118'  || ' : ' || SQLERRM;
            raise;
	END;

    --------------------------------
    -- ItemTravelDistance records
    --------------------------------
    BEGIN
        -- CODE GOES HERE
        INSERT INTO MSC_BIS_INV_DETAIL (PLAN_ID,
                                        ORGANIZATION_ID,
                                        SR_INSTANCE_ID,
                                        INVENTORY_ITEM_ID,
                                        DETAIL_LEVEL,
                                        PERIOD_TYPE,
                                        DETAIL_DATE,
										SHIP_METHOD,
										ITEM_TRAVEL_DISTANCE,
                                        MDS_QUANTITY,
                                        INVENTORY_QUANTITY,
                                        SUPPLIER_ID,
										SUPPLIER_SITE_ID,
                                        ZONE_ID,
										SOURCE_ORG_INSTANCE_ID,
										SOURCE_ORGANIZATION_ID,
										CUSTOMER_ID,
										CUSTOMER_SITE_ID,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN)
	SELECT
			PlanIdVar,
			-23453,
			SR_INSTANCE_ID,
			INVENTORY_ITEM_ID,
			PERIOD_TYPE, -- DETAIL_LEVEL
			1, --PERIOD_TYPE
			TO_DATE( MSC_INT_ITEM_TRAVEL_DISTANCE.Period_End,'YYYY-MM-DD' )-1/86400,
			TRANSPORTATION_MODE,
			ITEM_TRAVEL_DISTANCE,
			0,
			0,
			-23453, --SUPPLIER_ID
			-23453, --SUPPLIER_SITE_ID
			-23453, --ZONE_ID,
			-23453, --SOURCE_ORG_INSTANCE_ID
			-23453, --SOURCE_ORGANIZATION_ID
			-23453, --CUSTOMER_ID
			-23453, --CUSTOMER_SITE_ID
            SYSDATE, '-1',
            SYSDATE, '-1',
            -1
 	FROM MSC_INT_ITEM_TRAVEL_DISTANCE
        WHERE PLAN_ID=PlanIdVar;
      EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UPDATE_BIS_INV_DETAIL_001010' || ' : ' || SQLERRM;
            raise;
    END;

    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_BIS_INV_DETAIL;

  PROCEDURE SET_ASCP_SRC_RECOMMEND_DETAIL (
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER,
        AssignmentSetOutIdVar IN        NUMBER
        ) AS
  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    -- 1. and 2. drop, create, populate 2 temp tables msc_int_source1, msc_int_source2
    --BEGIN
    --DELETE FROM msc_int_source1; -- where msc_int_ascp_prodcost_kpi.plan_id=PlanIdVar;  --??BUGBUG ??
    --EXCEPTION WHEN others THEN
    --  g_ErrorCode := 'ERROR_DELETE_msc_int_source1_001011' || ' : ' || SQLERRM;
    --  raise;
    --END;

    --BEGIN
    --DELETE FROM msc_int_source2; -- where msc_int_ascp_prodcost_kpi.plan_id=PlanIdVar; --??BUGBUG ??
    --EXCEPTION WHEN others THEN
    --  g_ErrorCode := 'ERROR_DELETE_msc_int_source2_001012' || ' : ' || SQLERRM;
    --  raise;
    --END;

    --  1. SourceItem
    --BEGIN
    --  INSERT into msc_int_source1 ( item_code, branch_code )
    --    SELECT DISTINCT msc_int_src_recommend_detail.item_code,
    --           msc_int_src_recommend_detail.destination_code
    --    FROM msc_int_src_recommend_detail
    --    WHERE msc_int_src_recommend_detail.available = 'Yes';
    --EXCEPTION WHEN others THEN
    --  g_ErrorCode := 'ERROR_INSERT_msc_int_source1_001021' || ' : ' || SQLERRM;
    --  raise;
    --END;

    --  2. SourceItemBranch
    --BEGIN
    --  INSERT into msc_int_source2 ( item_code, branch_code, enable_date, disable_date )
    --    SELECT DISTINCT msc_int_src_recommend_detail.item_code,
    --            msc_int_src_recommend_detail.destination_code,
    --            TO_DATE(msc_int_src_recommend_detail.start_date, 'YYYY-MM-DD'),
    --            TO_DATE(msc_int_src_recommend_detail.end_date, 'YYYY-MM-DD')
    --    FROM msc_int_src_recommend_detail
    --    WHERE msc_int_src_recommend_detail.available = 'Yes';
    --EXCEPTION WHEN others THEN
    --  g_ErrorCode := 'ERROR_INSERT_msc_int_source2_001022' || ' : ' || SQLERRM;
    --  raise;
    --END;

    -- 3. clear msc_sr_source_org
    --g_ErrorCode := '';
    --BEGIN
    --DELETE from MSC_SR_SOURCE_ORG
    --	WHERE
    --    MSC_SR_SOURCE_ORG.SR_RECEIPT_ID in
    --      ( select MSC_SR_RECEIPT_ORG.SR_RECEIPT_ID from MSC_SR_ASSIGNMENTS, MSC_SR_RECEIPT_ORG
    --      where MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar and
    --      MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID = MSC_SR_RECEIPT_ORG.SOURCING_RULE_ID );
    -- EXCEPTION WHEN others THEN
    --      g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001001' || ' : ' || SQLERRM;
    --      NULL;
    --END;

    -- 4. clear msc_sr_receipt_org
    --BEGIN
    --DELETE from MSC_SR_RECEIPT_ORG
    --  WHERE
    --    MSC_SR_RECEIPT_ORG.SOURCING_RULE_ID in
    --    ( select MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID from MSC_SR_ASSIGNMENTS
    --    where MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar );
    -- EXCEPTION WHEN others THEN
    --      g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001002' || ' : ' || SQLERRM;
    --      NULL;
    --END;

    -- 5. clear msc_sourcing_rules
    --BEGIN
    --DELETE from MSC_SOURCING_RULES
    --  WHERE
    --  MSC_SOURCING_RULES.SOURCING_RULE_ID in
    --  ( select MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID from MSC_SR_ASSIGNMENTS
    --  where MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar );
    --EXCEPTION WHEN others THEN
    --      g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001003' || ' : ' || SQLERRM;
    --      NULL;
    --END;

    -- 6. clear msc_sr_assignments
    --BEGIN
    --DELETE from MSC_SR_ASSIGNMENTS
    --  WHERE
    --MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar;
    --EXCEPTION WHEN others THEN
    --    g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001004' || ' : ' || SQLERRM;
    --    NULL;
    --END;

    -- 7. clear msc_item_sourcing
    BEGIN
    DELETE from MSC_ITEM_SOURCING
    WHERE MSC_ITEM_SOURCING.PLAN_ID = PlanIdVar;
    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001005' || ' : ' || SQLERRM;
        NULL;
    END;

    -- 8. Insert into MSC_SR_ASSIGNMENTS
    --BEGIN
    --INSERT into MSC_SR_ASSIGNMENTS (
    --                      ASSIGNMENT_ID,
    --                      SR_ASSIGNMENT_ID,
    --                      SR_ASSIGNMENT_INSTANCE_ID,
    --                      ASSIGNMENT_SET_ID,
    --                      ASSIGNMENT_TYPE,
    --                      SOURCING_RULE_ID,
    --                      SOURCING_RULE_TYPE,
    --                      ORGANIZATION_ID,
    --                      SR_INSTANCE_ID,
    --                      INVENTORY_ITEM_ID,
    --                      LAST_UPDATE_DATE,
    --                      LAST_UPDATED_BY,
    --                      CREATION_DATE,
    --                      CREATED_BY)
    --         SELECT
    --                    MSC_SR_ASSIGNMENTS_S.NEXTVAL,
    --	                  -1 * MSC_SR_ASSIGNMENTS_S.NEXTVAL, -- Part of unique key. Maybe should use current value.
    --                    -1, -- // -1 until we figure out what goes here.
    --                    assignmentSetOutIdVar,
    --                    6, -- // 6 is item-org assignment type
    --                    MSC_SOURCING_RULES_S.NEXTVAL, -- //Cache these because we cannot look them up by name
    --                    1,
    --                    substr(msc_int_source1.branch_code,instr(msc_int_source1.branch_code,':',1,1)+1),
    --                    substr(msc_int_source1.item_code,1,instr(msc_int_source1.item_code,':',1,1)-1),
    --                    substr(msc_int_source1.item_code,instr(msc_int_source1.item_code,':',1,1)+1), -- CHANGE
    --                    sysdate,
    --                    '-1',
    --                    sysdate,
    --                    '-1'
    --            FROM msc_int_source1;
    -- EXCEPTION WHEN others THEN
    --      g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001006' || ' : ' || SQLERRM;
    --      raise;
    --END;

    -- 9. INSERT into MSC_SOURCING_RULES
    --BEGIN
    --INSERT into MSC_SOURCING_RULES (
    --            SOURCING_RULE_ID,
    --            SR_SOURCING_RULE_ID,
    --            SR_INSTANCE_ID,
    --            ORGANIZATION_ID,
    --            SOURCING_RULE_NAME,
    --            STATUS,
    --            SOURCING_RULE_TYPE,
    --            PLANNING_ACTIVE,
    --            LAST_UPDATE_DATE,
    --            LAST_UPDATED_BY,
    --            CREATION_DATE,
    --            CREATED_BY,
    --            DELETED_FLAG )
    --      SELECT DISTINCT
    --            MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID,
    --            -1 * MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID,
    --            MSC_SR_ASSIGNMENTS.SR_INSTANCE_ID, -- // I suppose these are the same.
    --            MSC_SR_ASSIGNMENTS.ORGANIZATION_ID,
    --            (MSC_ASSIGNMENT_SETS.ASSIGNMENT_SET_NAME || ':' || MSC_SYSTEM_ITEMS.ITEM_NAME || ':' || MSC_PLAN_ORGANIZATIONS.ORGANIZATION_CODE),
    --            1, -- // STATUS
    --            1, -- // 1 means sourcing rule type
    --            1,
    --            sysdate,
    --            '-1',
    --            sysdate,
    --            '-1',
    --            '2'
    --      FROM MSC_SR_ASSIGNMENTS , MSC_ASSIGNMENT_SETS , MSC_SYSTEM_ITEMS , MSC_PLAN_ORGANIZATIONS -- ( alias org )
    --      WHERE
    --      MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar and
    --        MSC_ASSIGNMENT_SETS.ASSIGNMENT_SET_ID = MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID and
    --        MSC_SYSTEM_ITEMS.SR_INSTANCE_ID = MSC_SR_ASSIGNMENTS.SR_INSTANCE_ID and
    --        MSC_SYSTEM_ITEMS.ORGANIZATION_ID = MSC_SR_ASSIGNMENTS.ORGANIZATION_ID and
    --        MSC_SYSTEM_ITEMS.INVENTORY_ITEM_ID = MSC_SR_ASSIGNMENTS.INVENTORY_ITEM_ID and
    --        MSC_SYSTEM_ITEMS.PLAN_ID = -1 and
    --        MSC_PLAN_ORGANIZATIONS.PLAN_ID = planIdVar and
    --        MSC_PLAN_ORGANIZATIONS.SR_INSTANCE_ID = MSC_SR_ASSIGNMENTS.SR_INSTANCE_ID and
    --        MSC_PLAN_ORGANIZATIONS.ORGANIZATION_ID = MSC_SR_ASSIGNMENTS.ORGANIZATION_ID;
    --      EXCEPTION WHEN others THEN
    --      g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001007' || ' : ' || SQLERRM;
    --      raise;
    --END;

    -- 10. INSERT into MSC_SR_RECEIPT_ORG
    --BEGIN
    --INSERT into MSC_SR_RECEIPT_ORG (
    --            SR_RECEIPT_ID,
    --            SR_SR_RECEIPT_ID,
    --            SR_INSTANCE_ID,
    --            SR_RECEIPT_ORG,
    --            RECEIPT_ORG_INSTANCE_ID,
    --            SOURCING_RULE_ID,
    --            RECEIPT_PARTNER_ID,
    --            RECEIPT_PARTNER_SITE_ID,
    --            EFFECTIVE_DATE,
    --            DISABLE_DATE,
    --            LAST_UPDATE_DATE,
    --            LAST_UPDATED_BY,
    --            CREATION_DATE,
    --            CREATED_BY
    --         ) -- // msc_int_source2 == source
    --        SELECT
    --            MSC_SR_RECEIPT_ORG_S.NEXTVAL,
    --            -1 * MSC_SR_RECEIPT_ORG_S.NEXTVAL,
    --            substr(msc_int_source2.branch_code,1,instr(msc_int_source2.branch_code,':',1,1)-1), -- // I suspect I am supposed to put something here but I don't know what.
    --            substr(msc_int_source2.branch_code,instr(msc_int_source2.branch_code,':',1,1)+1),
    --            substr(msc_int_source2.branch_code,1,instr(msc_int_source2.branch_code,':',1,1)-1), -- // Eventually this should be obtained from the branch code.
    --            MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID,
    --            NULL, -- This is empty until we get customer sourcing
    --            NULL, -- This is empty until we get customer sourcing
    --            msc_int_source2.enable_date,
    --            msc_int_source2.disable_date,
    --            sysdate,
    --            '-1',
    --            sysdate,
    --            '-1'
    --        FROM MSC_SR_ASSIGNMENTS, msc_int_source2
    --        WHERE
    --            MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar and
    --            MSC_SR_ASSIGNMENTS.SR_INSTANCE_ID || ':' || MSC_SR_ASSIGNMENTS.INVENTORY_ITEM_ID = msc_int_source2.item_code and
    --            MSC_SR_ASSIGNMENTS.SR_INSTANCE_ID || ':' || MSC_SR_ASSIGNMENTS.ORGANIZATION_ID = msc_int_source2.branch_code;
    --        EXCEPTION WHEN others THEN
    --            g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001008' || ' : ' || SQLERRM;
    --            raise;
    --END;

    -- 11. INSERT into MSC_SR_SOURCE_ORG
    --BEGIN
    --INSERT into MSC_SR_SOURCE_ORG (
    --          SR_SOURCE_ID,
    --          SR_SR_SOURCE_ID,
    --          SR_RECEIPT_ID,
    --          SOURCE_PARTNER_ID,
    --          SOURCE_PARTNER_SITE_ID,
    --          SR_INSTANCE_ID,
    --            SOURCE_ORGANIZATION_ID,
    --            SOURCE_ORG_INSTANCE_ID,
    --            SHIP_METHOD,
    --            ALLOCATION_PERCENT,
    --            RANK,
    --            SOURCE_TYPE,
    --            LAST_UPDATE_DATE,
    --            LAST_UPDATED_BY,
    --            CREATION_DATE,
    --            CREATED_BY
    --           )
    --        SELECT
    --            MSC_SR_SOURCE_ORG_S.NEXTVAL,
    --            -1 * MSC_SR_SOURCE_ORG_S.NEXTVAL,
    --            MSC_SR_RECEIPT_ORG.SR_RECEIPT_ID,
    --            case when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Supplier'
    --                 then substr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,1,instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,':',1,1)-1)
    --                 else NULL
    --            end,
    --            case when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Supplier'
    --                 then substr( MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, ':', 1,1) + 1 )
    --                 else NULL
    --            end,
    --            MSC_SR_RECEIPT_ORG.SR_INSTANCE_ID,
    --            case when not MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Supplier'
    --                 then substr( MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code, ':', 1,1) + 1 )
    --                 else NULL
    --            end,
    --            case when not MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Supplier'
    --                 then substr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,1,instr(MSC_INT_SRC_RECOMMEND_DETAIL.origin_code,':',1,1)-1)
    --                 else NULL
    --            end,
    --            case when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Internal'
    --                 then MSC_INT_SRC_RECOMMEND_DETAIL.transport_mode_code
    --            end,
    --            NVL(MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_percent,100),
    --            MSC_INT_SRC_RECOMMEND_DETAIL.preference,
    --            case when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Internal' then 1
    --                 when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Manufactured' then 2
    --                 when MSC_INT_SRC_RECOMMEND_DETAIL.sourcing_type = 'Supplier' then 3
    --                 else 1
    --            end,
    --            sysdate,
    --            '-1',
    --            sysdate,
    --            '-1'
    --        FROM MSC_SR_ASSIGNMENTS, MSC_SR_RECEIPT_ORG, MSC_INT_SRC_RECOMMEND_DETAIL
    --        WHERE MSC_SR_ASSIGNMENTS.ASSIGNMENT_SET_ID = assignmentSetOutIdVar
    --          AND MSC_SR_ASSIGNMENTS.SOURCING_RULE_ID = MSC_SR_RECEIPT_ORG.SOURCING_RULE_ID
    --          AND MSC_SR_RECEIPT_ORG.SR_RECEIPT_ORG = MSC_SR_ASSIGNMENTS.ORGANIZATION_ID
    --          AND MSC_SR_RECEIPT_ORG.RECEIPT_ORG_INSTANCE_ID || ':' || MSC_SR_RECEIPT_ORG.SR_RECEIPT_ORG = MSC_INT_SRC_RECOMMEND_DETAIL.destination_code
    --          AND MSC_SR_RECEIPT_ORG.EFFECTIVE_DATE = TO_DATE( MSC_INT_SRC_RECOMMEND_DETAIL.start_date, 'YYYY-MM-DD' )
    --          AND MSC_SR_ASSIGNMENTS.INVENTORY_ITEM_ID = substr(MSC_INT_SRC_RECOMMEND_DETAIL.item_code,instr(MSC_INT_SRC_RECOMMEND_DETAIL.item_code,':',1)+1)
    --          AND MSC_INT_SRC_RECOMMEND_DETAIL.available = 'Yes';
    --        EXCEPTION WHEN others THEN
    --            g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001009' || ' : ' || SQLERRM;
    --            raise;
    --END;

    -- 12. INSERT into MSC_ITEM_SOURCING for item source count
    BEGIN
    INSERT into MSC_ITEM_SOURCING (
                    PLAN_ID,
                    SR_INSTANCE_ID,
                    ORGANIZATION_ID,
                    SR_INSTANCE_ID2,
                    SOURCE_ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    EFFECTIVE_DATE,
                    ASSIGNMENT_ID,
		    ASSIGNMENT_SET_ID,
		    ASSIGNMENT_TYPE,
                    SOURCING_RULE_TYPE,
                    SUPPLIER_ID,
                    SUPPLIER_SITE_ID,
                    CUSTOMER_ID,
		    CUSTOMER_SITE_ID,
                    ZONE_ID,
                    SHIP_METHOD,
                    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
                    CREATED_BY
                )
            SELECT
                    PlanIdVar,
                    -- Destination Instance: when destination is customer, assign to -23453
                    CASE WHEN (sourcing_type = 'Sale') THEN
                        -23453
                    ELSE
                        TO_NUMBER(substr(destination_code,1,instr(destination_code,':',1,1)-1))
                    END,
                    -- Destination Org: when destination is customer, assign to -23453
                    CASE WHEN (sourcing_type = 'Sale') THEN
		        -23453
                    ELSE
		        TO_NUMBER(substr(destination_code,instr(destination_code,':',1,1)+1))
		    END,
		    -- Origin Instance: when origin is supplier, assign to -23453
                    CASE WHEN (sourcing_type = 'Supplier') THEN
                        -23453
                    ELSE
                        TO_NUMBER(substr(origin_code,1,instr(origin_code,':',1,1)-1))
                    END,
		    -- Origin Org: when origin is supplier, assign to -23453
                    CASE WHEN (sourcing_type = 'Supplier') THEN
                        -23453
                    ELSE
                        TO_NUMBER(substr(origin_code,instr(origin_code,':',1,1)+1))
                    END,
                    TO_NUMBER(substr(item_code,instr(item_code,':',1,1)+1)),
                    -- Effective date is string type in temp table
                    TO_DATE((select start_date from msc_int_src_recommend_detail where rownum=1), 'YYYY-MM-DD'),
                    -23453,
                    assignmentSetOutIdVar,
                    -23453,
                    -23453,
                    -- Supplier: when origin is not supplier, assign to -23453
                    CASE WHEN (sourcing_type <> 'Supplier') THEN
		        -23453
		    ELSE
		        TO_NUMBER(substr(origin_code,1,instr(origin_code,':',1,1)-1))
                    END,
                    -- Supplier Site: when origin is not supplier, assign to -23453
                    CASE WHEN (sourcing_type <> 'Supplier') THEN
		        -23453
		    ELSE
                        TO_NUMBER(substr(origin_code,instr(origin_code,':',1,1)+1))
                    END,
                    -- Customer: when destination is not customer, assign to -23453
                    CASE WHEN (sourcing_type <> 'Sale') THEN
		        -23453
		    ELSE
		        -- if zone, assign to -23453
		        (CASE WHEN (INSTR(destination_code,':') = 0) THEN
		            -23453
		        ELSE
		            TO_NUMBER(substr(destination_code,1,instr(destination_code,':',1,1)-1))
		        END)
                    END,
                    -- Customer Site: when destination is not customer, assign to -23453
                    CASE WHEN (sourcing_type <> 'Sale') THEN
		        -23453
		    ELSE
		        -- if zone, assign to -23453
		        (CASE WHEN (INSTR(destination_code,':') = 0) THEN
		            -23453
		        ELSE
		            TO_NUMBER(substr(destination_code,instr(destination_code,':',1,1)+1))
		        END)
                    END,
                    -- Zone: when destination is not customer, assign to -23453
                    CASE WHEN (sourcing_type <> 'Sale') THEN
		        -23453
		    ELSE
		        -- if not zone, assign to -23453
		        (CASE WHEN (INSTR(destination_code,':') = 0) THEN
		            TO_NUMBER(destination_code)
		        ELSE
		            -23453
		        END)
                    END,
                    transport_mode_code,
                    sysdate,
		    -1,
		    sysdate,
                    -1
            FROM msc_int_src_recommend_detail
            WHERE planName = PlanIdVar
            GROUP BY planName, origin_code, destination_code,
		     item_code, sourcing_type, transport_mode_code;
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UPDATE_MSC_INT_SRC_RECOMMEND_DETAIL_001010' || ' : ' || SQLERRM;
                raise;
    END;

    Status := 'SUCCESS';


    COMMIT; -- BUGBUG SHould this be -- checkpoint commit INSTEAD
    -- checkpoint commit;

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;
            ROLLBACK;
  END SET_ASCP_SRC_RECOMMEND_DETAIL;



  -- =============================================================
--
-- Helper functions used defined in MSC_WS_COMMON package ( copies here ).
-- =============================================================

 -- get plan name from plan Id

 FUNCTION GET_PLAN_NAME_BY_PLAN_ID(
                 Status OUT NOCOPY  VARCHAR2,
                 PlanId IN NUMBER
                 ) RETURN BOOLEAN AS
 l_PlanName    VARCHAR2(100);

 BEGIN
     BEGIN
         SELECT COMPILE_DESIGNATOR INTO l_PlanName
         FROM MSC_PLANS
         WHERE PLAN_ID = PlanId;
         EXCEPTION WHEN NO_DATA_FOUND THEN
             Status := 'INVALID_PLANID';
             RETURN FALSE;
         WHEN others THEN
             raise;
     END;

     Status := l_PlanName;
     RETURN TRUE;
 END GET_PLAN_NAME_BY_PLAN_ID;

  -- validate userId
  PROCEDURE  VALIDATE_USER_RESP( VRETURN OUT NOCOPY VARCHAR2,
                                  USERID IN  NUMBER,
                                  RESPID  IN NUMBER) AS
    V_USER_ID NUMBER;
    V_RESPID NUMBER;
    V_APPID NUMBER :=0;
    BEGIN

     BEGIN
       SELECT USER_ID INTO V_USER_ID
       FROM FND_USER
       WHERE USER_ID = USERID;
       EXCEPTION WHEN no_data_found THEN
              VRETURN := 'INVALID_USERID';
              RETURN;
                    WHEN others THEN
              raise;
     END;

     BEGIN
           SELECT RESPONSIBILITY_ID  INTO V_RESPID
           FROM FND_USER_RESP_GROUPS
           WHERE USER_ID = V_USER_ID AND RESPONSIBILITY_ID = RESPID AND
          (sysdate BETWEEN nvl(start_date,sysdate) AND nvl(end_date,sysdate));
           EXCEPTION WHEN no_data_found THEN
                VRETURN := 'INVALID_RESP_ID';
                 RETURN;
                    WHEN others THEN
              raise;
      END;

     BEGIN
           SELECT APPLICATION_ID  INTO  V_APPID
           FROM FND_RESPONSIBILITY
           WHERE  RESPONSIBILITY_ID = V_RESPID;
           EXCEPTION  WHEN others THEN
              raise;
      END;


     fnd_global.apps_initialize(USERID, RESPID, V_APPID);
     VRETURN :='OK';

END VALIDATE_USER_RESP;

-- no validation done
PROCEDURE PUBLISH_SNO_RESULTS( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                planIdVar         IN         Number,
                                assignmentSetOutIdVar IN Number) AS
  l_String            VARCHAR2(1000);
  l_PlanName          VARCHAR2(100);
  l_valid             BOOLEAN;
  errbuf              varchar2(1000);
  retcode             varchar2(1000);
  l_plan_run_id       number := null;
  ScenarioNameVar     varchar2(100);
  g_ErrorCode      VARCHAR2(1000);
  internal_SNO_Publish_Error     exception;
  BEGIN
    -- init global variables
    g_ErrorCode := '';
    ScenarioNameVar := '';


    -- initialize items for the given PlanId
    BEGIN
    SET_UP_SYSTEM_ITEMS(l_string, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 01' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00023' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;


    -- call procedure #1
    BEGIN
    SET_ASCP_PLAN_BUCKETS (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 02' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00023' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #2
    BEGIN
    SET_ASCP_DEMANDS (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 03' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00024' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #3
    BEGIN
    SET_ASCP_SUPPLIES (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 04' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00025' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #4
    BEGIN
    SET_ASCP_SAFETY_STOCKS (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 05' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00026' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #5

    BEGIN
    SET_ASCP_ALERTS (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 06' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00027' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #6
    BEGIN
    SET_ASCP_DEPARTMENT_RESOURCES (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 07' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00028' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

	-- new temp tables upload
	BEGIN
    SET_APCC_FACILITY_COST (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 12' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00033' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #7
    BEGIN
    SET_ASCP_RES_SUMMARY (l_String, PlanIdVar, ScenarioNameVar );
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
    END IF;
    IF ( ScenarioNameVar = '' ) THEN
          processid := -1;
          status := 'Invalid or empty Scenario Name';
          raise internal_SNO_Publish_Error;
          RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 08' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00029' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #8
    BEGIN
    SET_ASCP_BIS_INV_DETAIL (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 09' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00030' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #9
    BEGIN
    SET_ASCP_SRC_RECOMMEND_DETAIL (l_String, PlanIdVar, assignmentSetOutIdVar );
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 10' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00031' || ' : ' || status || ' : ' || SQLERRM;
          raise;
	END;


    BEGIN
    -- 5th parameter p_archive_flag is invoked with default value = -1, which means  p_archive_flag - yes;( TBD )
    -- values -1 ( default ) or 1, mean archive - Yes, otherwise No - based on the procedure definition.

    MSC_PHUB_PKG.populate_sno_details(errbuf, retcode, PlanIdVar, l_plan_run_id, -1,  ScenarioNameVar);


    IF (retcode <> null AND retcode <> '0') THEN
          processid := -1;
          status := errbuf;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;

     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 11' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00032' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

  COMMIT;
  processid := 1;
  Status := '';

  EXCEPTION
      WHEN others THEN
          Status := g_ErrorCode;
          processid := -1;
          log_message( Status );
          ROLLBACK;
  END PUBLISH_SNO_RESULTS;

PROCEDURE PUBLISH_SNO_RESULTS_WITH_VAL( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                userId            IN         Number,
                                responsibilityId  IN         Number,
                                planIdVar         IN         Number,
                                assignmentSetOutIdVar IN Number) AS
  l_String            VARCHAR2(1000);
  l_processId         NUMBER;
  l_PlanName          VARCHAR2(100);
  l_valid             BOOLEAN;


  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    -- init global variables
    g_ErrorCode := '';

     -- validate and initialize apps
    l_processId := 1;
    VALIDATE_FOR_PUBLISH_SNO_RES( l_processId, l_String, userId, responsibilityId, planIdVar );
    IF ( l_processId='-1' OR l_String <> '' ) THEN
      processid := -1;
      status := l_String;
      log_message( status );
      RETURN;
    END IF;
    PUBLISH_SNO_RESULTS( processId, status, planIdVar, assignmentSetOutIdVar);

  END PUBLISH_SNO_RESULTS_WITH_VAL;

PROCEDURE VALIDATE_FOR_PUBLISH_SNO_RES( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                userId            IN         Number,
                                responsibilityId  IN         Number,
                                planIdVar         IN         Number) AS
  l_String            VARCHAR2(1000);
  l_valid             BOOLEAN;


  g_ErrorCode      VARCHAR2(1000);
  BEGIN
    -- init global variables
    g_ErrorCode := '';

     -- validate and initialize apps
    BEGIN
      VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
      IF (l_String <> 'OK') THEN
          processid := -1;
          status := l_String;
          RETURN;
      END IF;
    EXCEPTION WHEN others THEN
       g_ErrorCode := 'ERROR_UNEXPECTED_00021' || ' : ' || SQLERRM;
       raise;
    END;

    -- check plan id
    BEGIN
        l_valid := GET_PLAN_NAME_BY_PLAN_ID(l_String, PlanIdVar);
        IF ( (l_String = 'INVALID_PLANID') OR l_valid=false ) THEN
            processid := -1;
            status := l_String;
            RETURN;
        END IF;
     EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_00022' || ' : ' || SQLERRM;
        raise;
    END;

  processid := 1;
  Status := '';

  EXCEPTION
      WHEN others THEN
          Status := g_ErrorCode || ' : ' || SQLERRM;
          processid := -1;
          log_message( Status );
          ROLLBACK;
  END VALIDATE_FOR_PUBLISH_SNO_RES;

-- SOP Publish - Cost Modeling ( no validation done )
PROCEDURE PUBLISH_SNO_RESULTS_SOP( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                planIdVar         IN         Number ) AS
  l_String            VARCHAR2(1000);
  l_PlanName          VARCHAR2(100);
  g_ErrorCode      VARCHAR2(1000);
  internal_SNO_Publish_Error     exception;
  BEGIN
    -- init global variables
    g_ErrorCode := '';


    -- initialize items for the given PlanId --  OUT for SOP -- SET_UP_SYSTEM_ITEMS

    -- call procedure #1 -- IN for SOP
    BEGIN
    SET_ASCP_PLAN_BUCKETS (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 02' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00023' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #2 -- OUT for SOP - we do not need data from msc_demand for the SOP case
    --BEGIN
    --SET_ASCP_DEMANDS (l_String, PlanIdVar);
    --IF (l_String <> 'SUCCESS') THEN
    --      processid := -1;
    --      status := l_String;
    --      raise internal_SNO_Publish_Error; --RETURN;
    -- END IF;
    -- EXCEPTION
    -- WHEN internal_SNO_Publish_Error THEN
    --      g_ErrorCode := 'Internal SNO Publish Error 03' || ' : ' || status;
    --     raise;
    --  WHEN others THEN
    --      g_ErrorCode := 'ERROR_UNEXPECTED_00024' || ' : ' || status || ' : ' || SQLERRM;
    --      raise;
    --END;

    -- call procedure #3 -- OUT for SOP - we do not need data from msc_supplies for the SOP case
    --BEGIN
    --SET_ASCP_SUPPLIES (l_String, PlanIdVar);
    --IF (l_String <> 'SUCCESS') THEN
    --      processid := -1;
    --      status := l_String;
    --      raise internal_SNO_Publish_Error; --RETURN;
    -- END IF;
    -- EXCEPTION
    --  WHEN internal_SNO_Publish_Error THEN
    --      g_ErrorCode := 'Internal SNO Publish Error 04' || ' : ' || status;
    --      raise;
    --  WHEN others THEN
    --      g_ErrorCode := 'ERROR_UNEXPECTED_00025' || ' : ' || status || ' : ' || SQLERRM;
    --      raise;
    --END;

    -- call procedure #4 -- OUT for SOP -- SET_ASCP_SAFETY_STOCKS

    -- call procedure #5 -- OUT for SOP -- SET_ASCP_ALERTS

    -- call procedure #6 -- OUT for SOP -- SET_ASCP_DEPARTMENT_RESOURCES

    -- call procedure #7 -- OUT for SOP SET_ASCP_RES_SUMMARY



    -- call SET_ASCP_BIS_INV_DETAIL ( procedure #8 ) -- IN for SOP - however ...

    -- ... first clear the records from MSC_INT_ITEM_TRAVEL_DISTANCE table for the given PlanIdVar if any
    -- ... 'cause for SOP there should not be any in there
        BEGIN
    DELETE FROM MSC_INT_ITEM_TRAVEL_DISTANCE WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

    -- ... then clear the records from MSC_INT_ASCP_INVENTORY table for the given PlanIdVar if any
     BEGIN
    DELETE FROM MSC_INT_ASCP_INVENTORY WHERE PLAN_ID=PlanIdVar;
    EXCEPTION WHEN others THEN
      NULL; -- do nothing
    END;

	-- ... then	call SET_ASCP_BIS_INV_DETAIL procedure -- IN for SOP
    BEGIN
    SET_ASCP_BIS_INV_DETAIL (l_String, PlanIdVar);
    IF (l_String <> 'SUCCESS') THEN
          processid := -1;
          status := l_String;
          raise internal_SNO_Publish_Error; --RETURN;
     END IF;
     EXCEPTION
      WHEN internal_SNO_Publish_Error THEN
          g_ErrorCode := 'Internal SNO Publish Error 09' || ' : ' || status;
          raise;
      WHEN others THEN
          g_ErrorCode := 'ERROR_UNEXPECTED_00030' || ' : ' || status || ' : ' || SQLERRM;
          raise;
    END;

    -- call procedure #9 -- SET_ASCP_SRC_RECOMMEND_DETAIL OUT for SOP

	-- OUT for SOP -- MSC_PHUB_PKG.populate_sno_details

  COMMIT;
  processid := 1;
  Status := '';

  EXCEPTION
      WHEN others THEN
          Status := g_ErrorCode;
          processid := -1;
          log_message( Status );
          ROLLBACK;
  END PUBLISH_SNO_RESULTS_SOP;
END MSC_WS_SNO_PUBLISH;

/
