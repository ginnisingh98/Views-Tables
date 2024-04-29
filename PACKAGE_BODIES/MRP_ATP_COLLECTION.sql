--------------------------------------------------------
--  DDL for Package Body MRP_ATP_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ATP_COLLECTION" AS
/* $Header: MRPATPCB.pls 115.4 1999/11/11 18:25:07 pkm ship     $  */
PROCEDURE Collect_Atp_Info(
	                ERRBUF              OUT VARCHAR2,
			RETCODE             OUT NUMBER)
IS
l_oe_install  VARCHAR2(3);
BEGIN

    RETCODE := 0;
    -- Before inserting new records, delete existing records
    -- to prevent duplicates.

    DELETE FROM mrp_atp_supply_demand;

    -- SUPPLY DEMAND SOURCE TYPE (existing in mfg_lookups:)
        --  1: Purchase order
        --  2: Sales order
        --  3: Account number
        --  4: WIP repetitive schedule
        --  5: WIP discrete job
        --  6: Account alias
        --  7: WIP nonstandard job
        --  8: Onhand quantity
        --  9: Reserved sales order
        -- 10: Reserved account number
        -- 11: Reserved account alias
        -- 12: Intransit receipt
        -- 13: Discrete MPS
        -- 14: Repetitive MPS
        -- 15: Onhand Reservation
        -- 16: User supply
        -- 17: User Demand
        -- 18: PO Requisition
        -- 19: Reserved user source
        -- 20: Internal requisition
        -- 21: Internal order
        -- 22: Reserved internal order
        -- 23: WIP Supply Reservation
        -- 24: Flow Schedule

    -- SUPPLY DEMAND TYPE:
        --  1: Demand
        --  2: Supply


    -- source_identifier1: instance id.  -1 for non-distributed environment
    -- source_identifier2: null for now

    -- plan_id: -1 if it is from execution system
    --                      (-2 if populated from scheduling manager)

    -- Inserting new records.

    -- First insert onhand information.
    INSERT INTO mrp_atp_supply_demand(
        	source_identifier1,
		source_identifier2,
		source_identifier3,
		plan_id,
		organization_id,
		inventory_item_id,
		supply_demand_date,
		supply_demand_source_type,
		supply_demand_quantity,
		reservation_quantity,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		demand_class,
		supply_demand_type,
                product_family_item_id)
    SELECT	-1, -- instance id
		to_number(NULL),
		0,  -- source identifier
		-1, -- plan_id
		org_id,
		item_id,
		MRP_CALENDAR.next_work_day(org_id, 1, SYSDATE),
		8,  -- onhand
		sum(transaction_qty),
		NULL, -- reservation quantity
		SYSDATE,
		FND_GLOBAL.USER_ID,
		SYSDATE,
                FND_GLOBAL.USER_ID,
		NULL,
		2, -- supply
                NULL
    FROM	(
		SELECT	I.INVENTORY_ITEM_ID item_id,
			I.ORGANIZATION_ID org_id,
			Q.TRANSACTION_QUANTITY	transaction_qty
		FROM 	MTL_SECONDARY_INVENTORIES S,
			MTL_PARAMETERS P ,
			MTL_ONHAND_QUANTITIES Q ,
			MTL_ATP_RULES R ,
			MTL_SYSTEM_ITEMS I
		WHERE	I.ATP_FLAG in ('Y', 'C')
		AND	Q.ORGANIZATION_ID = I.ORGANIZATION_ID
		AND     Q.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
		AND     S.SECONDARY_INVENTORY_NAME = Q.SUBINVENTORY_CODE
		AND     S.ORGANIZATION_ID = Q.ORGANIZATION_ID
		AND     R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
		AND     S.INVENTORY_ATP_CODE = 1 -- atpable
		AND     Q.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_ONHAND_AVAILABLE,
                                     2, -1, Q.INVENTORY_ITEM_ID)
		AND     P.ORGANIZATION_ID=I.ORGANIZATION_ID
                UNION ALL
                SELECT  I.INVENTORY_ITEM_ID item_id,
                        I.ORGANIZATION_ID org_id,
                        T.PRIMARY_QUANTITY  transaction_qty
		FROM 	MTL_SECONDARY_INVENTORIES S,
                        MTL_PARAMETERS P ,
                        MTL_MATERIAL_TRANSACTIONS_TEMP T ,
                        MTL_ATP_RULES R ,
                        MTL_SYSTEM_ITEMS I
                WHERE   I.ATP_FLAG in ('Y', 'C')
		AND	T.ORGANIZATION_ID = I.ORGANIZATION_ID
                AND     T.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                AND     S.SECONDARY_INVENTORY_NAME = T.SUBINVENTORY_CODE
                AND     S.ORGANIZATION_ID = T.ORGANIZATION_ID
                AND     R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
                AND     S.INVENTORY_ATP_CODE = 1 -- atpable
                AND     T.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_ONHAND_AVAILABLE,
                                     2, -1, T.INVENTORY_ITEM_ID)
                AND     P.ORGANIZATION_ID=I.ORGANIZATION_ID
                )
    GROUP BY item_id, org_id;

    -- insert MPS supply
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT	-1,	-- instance id
		NULL,
		D2.MPS_TRANSACTION_ID ,
		-1, -- plan_id
		I.ORGANIZATION_ID,
		I.INVENTORY_ITEM_ID,
		C.CALENDAR_DATE,
  		DECODE(I.REPETITIVE_PLANNING_FLAG, 'Y', 14, 13) ,
        	DECODE(I.REPETITIVE_PLANNING_FLAG, 'Y',D2.REPETITIVE_DAILY_RATE,
                	D2.SCHEDULE_QUANTITY) ,
        	NULL, -- reservation quantity
        	SYSDATE,
        	FND_GLOBAL.USER_ID,
        	SYSDATE,
        	FND_GLOBAL.USER_ID,
        	D1.DEMAND_CLASS,
        	2, -- supply
                DECODE(I.BOM_ITEM_TYPE, 5, I.INVENTORY_ITEM_ID, NULL)
    FROM 	BOM_CALENDAR_DATES C ,
        	MTL_ATP_RULES R ,
		MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I,
        	MRP_SCHEDULE_DATES D2,
		MRP_SCHEDULE_DESIGNATORS D1
    WHERE	D1.INVENTORY_ATP_FLAG=1
    AND		D1.SCHEDULE_TYPE=2
    AND		D2.SCHEDULE_DESIGNATOR=D1.SCHEDULE_DESIGNATOR
    AND		DECODE(I.REPETITIVE_PLANNING_FLAG, 'Y',
                   D2.REPETITIVE_DAILY_RATE,D2.SCHEDULE_QUANTITY) > 0
    AND		D2.SUPPLY_DEMAND_TYPE = 2
    AND		D2.SCHEDULE_LEVEL = 2
    AND 	I.ORGANIZATION_ID=D2.ORGANIZATION_ID
    AND		I.INVENTORY_ITEM_ID= D2.INVENTORY_ITEM_ID
    AND		I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		(R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1)
    AND		C.CALENDAR_CODE=P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE BETWEEN D2.SCHEDULE_DATE
			AND NVL(D2.RATE_END_DATE, D2.SCHEDULE_DATE)
    AND		C.SEQ_NUM IS NOT NULL
    AND		C.CALENDAR_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
			NULL, C.CALENDAR_DATE,
			MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
			-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)));

    -- insert user defined supply
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
  		NULL ,
		U.SOURCE_ID ,
        	-1,
        	U.ORGANIZATION_ID,
		U.INVENTORY_ITEM_ID,
		C.NEXT_DATE,
		16 ,
		U.PRIMARY_UOM_QUANTITY ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                U.DEMAND_CLASS,
                2, -- supply
                NULL
    FROM 	BOM_CALENDAR_DATES C,
		MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I ,
        	MTL_USER_SUPPLY U
    WHERE 	I.ORGANIZATION_ID = U.ORGANIZATION_ID
    AND		I.INVENTORY_ITEM_ID = U.INVENTORY_ITEM_ID
    AND		I.ATP_FLAG in ('C', 'Y')
    AND 	P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_USER_DEFINED_SUPPLY = 1
    AND		C.NEXT_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.NEXT_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
    AND 	C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE = TRUNC(U.EXPECTED_DELIVERY_DATE);

    -- insert mtl_supply information, that is PO, REQ, SHIP, RCV
    -- question here,
    -- I select NVL(S.MRP_PRIMARY_QUANTITY, S.TO_ORG_PRIMARY_QUANTITY)
    -- as the supply_demand_quantity if discrete mps is included,
    -- S.TO_ORG_PRIMARY_QUANTITY if not included.
    -- However, in inldsd.ppc, it selects
    -- S.TO_ORG_PRIMARY_QUANTITY for shipment, NVL(S.MRP_PRIMARY_QUANTITY, 0)
    -- if discrete mps is included, S.TO_ORG_PRIMARY_QUANTITY if not included

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT	-1,
		NULL,
        	DECODE(	S.PO_HEADER_ID,
	       		NULL,DECODE(S.SUPPLY_TYPE_CODE,
			    	    'REQ', REQ_HEADER_ID,
		   	SHIPMENT_HEADER_ID),
		PO_HEADER_ID),
                -1,
		I.ORGANIZATION_ID,
		I.INVENTORY_ITEM_ID,
		C.NEXT_DATE,
        	DECODE( S.PO_HEADER_ID,
                	NULL, DECODE(S.SUPPLY_TYPE_CODE,'REQ',
                             	     DECODE(S.FROM_ORGANIZATION_ID,NULL,18,20),
                      		     12),
                        1) ,
		DECODE(R.INCLUDE_DISCRETE_MPS,
		       1,NVL(S.MRP_PRIMARY_QUANTITY, S.TO_ORG_PRIMARY_QUANTITY),
                       S.TO_ORG_PRIMARY_QUANTITY),
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                NULL,
                2, -- supply
                NULL
    FROM	BOM_CALENDAR_DATES C ,
		MTL_SUPPLY S,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
		MTL_SYSTEM_ITEMS I
    WHERE 	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND
    (
		(  -- this identifies interorg shipping and receiving
		R.INCLUDE_INTERORG_TRANSFERS = 1 AND
	  	S.REQ_HEADER_ID IS NULL AND
	  	S.PO_HEADER_ID IS NULL
         	)
		OR
		(  -- this identifies internal req
		S.REQ_HEADER_ID=DECODE(R.INCLUDE_INTERNAL_REQS,
				       1,S.REQ_HEADER_ID) AND
 		S.FROM_ORGANIZATION_ID IS NOT NULL
		)
		OR
		(  -- this identifies vendor req
		S.SUPPLY_TYPE_CODE= DECODE(R.INCLUDE_VENDOR_REQS,1,'REQ') AND
		S.FROM_ORGANIZATION_ID IS NULL
		)
  		OR -- this identifies PO
		S.PO_HEADER_ID=DECODE(R.INCLUDE_PURCHASE_ORDERS,
				      1, S.PO_HEADER_ID)
    )
    AND		S.TO_ORGANIZATION_ID=I.ORGANIZATION_ID
    AND		S.ITEM_ID = I.INVENTORY_ITEM_ID
    AND		S.DESTINATION_TYPE_CODE='INVENTORY'
    AND		(S.TO_SUBINVENTORY IS NULL OR
        	EXISTS (SELECT 'X'
                	FROM MTL_SECONDARY_INVENTORIES S2
                	WHERE S2.ORGANIZATION_ID=S.TO_ORGANIZATION_ID
                	AND S2.SECONDARY_INVENTORY_NAME = S.TO_SUBINVENTORY
                	AND S2.INVENTORY_ATP_CODE = 1))
    AND		C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE = TRUNC(S.EXPECTED_DELIVERY_DATE)
    AND		C.NEXT_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.NEXT_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)));

    -- insert wip discrete job information
    -- question here: do I need to apply bug 791215 here?
    -- that is , using net_quantity instead of mps_net_quantity?
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
		NULL,
  		D.WIP_ENTITY_ID,
		-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.NEXT_DATE,
		DECODE(D.JOB_TYPE, 1, 5, 7) ,
                (DECODE(R.INCLUDE_DISCRETE_MPS,
                      1, DECODE(D.JOB_TYPE,
			  	1, DECODE(I.MRP_PLANNING_CODE,
                                          4, NVL(D.MPS_NET_QUANTITY,0),
                                          8, NVL(D.MPS_NET_QUANTITY,0),
                                          D.NET_QUANTITY),
                                D.NET_QUANTITY),
                      D.NET_QUANTITY)-D.QUANTITY_COMPLETED-D.QUANTITY_SCRAPPED),
		NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                2, -- supply
                NULL
    FROM	BOM_CALENDAR_DATES C ,
		WIP_DISCRETE_JOBS D,
		MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND 	(R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1 OR
		R.INCLUDE_NONSTD_WIP_RECEIPTS = 1)
    AND		D.STATUS_TYPE IN (1,3,4,6)
    AND		(D.START_QUANTITY-D.QUANTITY_COMPLETED-D.QUANTITY_SCRAPPED) >0
    AND		D.ORGANIZATION_ID=I.ORGANIZATION_ID
    AND		D.PRIMARY_ITEM_ID= I.INVENTORY_ITEM_ID
    AND		(D.JOB_TYPE =DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 1, -1)
	 	OR
  	 	D.JOB_TYPE =DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 3, -1))
    AND		C.NEXT_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.NEXT_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
    AND		C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE = TRUNC(D.SCHEDULED_COMPLETION_DATE);


    -- insert wip neg requirement information
    -- I have applied bug 454103 here.

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
		NULL,
		D.WIP_ENTITY_ID ,
        	-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.NEXT_DATE,
		DECODE(D.JOB_TYPE, 1, 5, 7) ,
  		-1*O.REQUIRED_QUANTITY ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                2, -- supply
                NULL
    FROM	BOM_CALENDAR_DATES C ,
  		WIP_DISCRETE_JOBS D,
        	WIP_REQUIREMENT_OPERATIONS O ,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE	I.ATP_FLAG in ('C', 'Y')
    AND     	P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		(R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1 OR
        	R.INCLUDE_NONSTD_WIP_RECEIPTS = 1)
    AND		O.ORGANIZATION_ID=I.ORGANIZATION_ID
    AND		O.INVENTORY_ITEM_ID=I.INVENTORY_ITEM_ID
    AND		O.WIP_SUPPLY_TYPE <> 6
    AND		O.REQUIRED_QUANTITY < 0
    AND		O.OPERATION_SEQ_NUM > 0
    AND		D.WIP_ENTITY_ID= O.WIP_ENTITY_ID
    AND		D.ORGANIZATION_ID = O.ORGANIZATION_ID
    AND		(D.JOB_TYPE= DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 1, -1)
		OR
		D.JOB_TYPE = DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 3, -1))
    AND		D.STATUS_TYPE IN (1,3, 4,6)
    AND		C.NEXT_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.NEXT_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)))
    AND		C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE = TRUNC(D.SCHEDULED_COMPLETION_DATE);


    -- insert wip repetitive supply

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id )
    SELECT 	-1,
		NULL,
        	WRS.WIP_ENTITY_ID ,
        	-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.NEXT_DATE,
		4 ,
  		DECODE(SIGN(WRS.DAILY_PRODUCTION_RATE*
		  (C.NEXT_SEQ_NUM-C1.NEXT_SEQ_NUM) -WRS.QUANTITY_COMPLETED),
		  -1, WRS.DAILY_PRODUCTION_RATE* LEAST(C.NEXT_SEQ_NUM
			-C1.NEXT_SEQ_NUM+1, WRS.PROCESSING_WORK_DAYS)
			-WRS.QUANTITY_COMPLETED,
            	  LEAST(C1.NEXT_SEQ_NUM+WRS.PROCESSING_WORK_DAYS
			-C.NEXT_SEQ_NUM,1) *WRS.DAILY_PRODUCTION_RATE) ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                WRS.DEMAND_CLASS,
                2, -- supply
                NULL
    FROM 	BOM_CALENDAR_DATES C ,
		BOM_CALENDAR_DATES C1 ,
  		WIP_REPETITIVE_SCHEDULES WRS ,
		WIP_REPETITIVE_ITEMS WRI,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE 	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_REP_WIP_RECEIPTS = 1
    AND		WRI.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		WRI.PRIMARY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND		WRS.WIP_ENTITY_ID = WRI.WIP_ENTITY_ID
    AND		WRS.LINE_ID = WRI.LINE_ID
    AND		WRS.ORGANIZATION_ID = WRI.ORGANIZATION_ID
    AND		WRS.STATUS_TYPE IN (1,3,4,6)
    AND		C1.CALENDAR_CODE=P.CALENDAR_CODE
    AND		C1.EXCEPTION_SET_ID= P.CALENDAR_EXCEPTION_SET_ID
    AND		C1.CALENDAR_DATE= TRUNC(WRS.FIRST_UNIT_COMPLETION_DATE)
    AND		C.CALENDAR_CODE=P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
    AND		C.SEQ_NUM BETWEEN C1.NEXT_SEQ_NUM AND
			C1.NEXT_SEQ_NUM + CEIL(WRS.PROCESSING_WORK_DAYS - 1)
    AND 	WRS.DAILY_PRODUCTION_RATE*
			LEAST(C.NEXT_SEQ_NUM-C1.NEXT_SEQ_NUM+1,
  			WRS.PROCESSING_WORK_DAYS) > WRS.QUANTITY_COMPLETED
    AND		C.CALENDAR_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.CALENDAR_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,0)));

    -- insert flow schedule supply information

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
   SELECT 	-1,
        	NULL,
        	D.WIP_ENTITY_ID ,
        	-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.NEXT_DATE,
  		24 ,
		(DECODE(R.INCLUDE_DISCRETE_MPS,
		        1, DECODE(I.MRP_PLANNING_CODE,
			          4, NVL(D.MPS_NET_QUANTITY,0),
			          8, NVL(D.MPS_NET_QUANTITY,0),
			          D.PLANNED_QUANTITY),
                        D.PLANNED_QUANTITY) - D.QUANTITY_COMPLETED) ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                2, -- supply
                NULL
    FROM 	BOM_CALENDAR_DATES C ,
		WIP_FLOW_SCHEDULES D,
		MTL_PARAMETERS P ,
		MTL_ATP_RULES R,
        	MTL_SYSTEM_ITEMS I
    WHERE	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_FLOW_SCHEDULE_RECEIPTS = 1
    AND		D.STATUS = 1
    AND 	(D.PLANNED_QUANTITY-D.QUANTITY_COMPLETED) >0
    AND 	D.ORGANIZATION_ID=I.ORGANIZATION_ID
    AND 	D.PRIMARY_ITEM_ID= I.INVENTORY_ITEM_ID
    AND		C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND 	C.CALENDAR_DATE = TRUNC(D.SCHEDULED_COMPLETION_DATE)
    AND 	C.NEXT_DATE >= MRP_CALENDAR.next_work_day(
				P.ORGANIZATION_ID,1,SYSDATE);

    -- now we insert the demand information
    -- insert wip discrete requirement information

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
		NULL,
		D.WIP_ENTITY_ID ,
		-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
		C.PRIOR_DATE,
		DECODE(D.JOB_TYPE, 1, 5, 7) ,
		LEAST(-1*(O.REQUIRED_QUANTITY-O.QUANTITY_ISSUED),0) ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM 	BOM_CALENDAR_DATES C ,
        	WIP_DISCRETE_JOBS D,
        	WIP_REQUIREMENT_OPERATIONS O ,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE 	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		(R.INCLUDE_DISCRETE_WIP_DEMAND = 1 OR
        	R.INCLUDE_NONSTD_WIP_DEMAND = 1)
    AND		O.ORGANIZATION_ID=I.ORGANIZATION_ID
    AND		O.INVENTORY_ITEM_ID=I.INVENTORY_ITEM_ID
    AND		O.WIP_SUPPLY_TYPE <> 6
    AND		O.REQUIRED_QUANTITY > 0
    AND		(O.REQUIRED_QUANTITY-O.QUANTITY_ISSUED) > 0
    AND		O.OPERATION_SEQ_NUM > 0
    AND 	D.ORGANIZATION_ID=O.ORGANIZATION_ID
    AND		D.WIP_ENTITY_ID=O.WIP_ENTITY_ID
    AND		(D.JOB_TYPE=DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 1, -1)
        	OR
        	D.JOB_TYPE =DECODE(R.INCLUDE_NONSTD_WIP_DEMAND, 1, 3, -1))
    AND		D.STATUS_TYPE IN (1,3,4,6)
    AND		C.PRIOR_DATE >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                	NULL, C.PRIOR_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)))
    AND		C.CALENDAR_CODE = P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND		C.CALENDAR_DATE = TRUNC(O.DATE_REQUIRED);


    -- insert wip repetitive requirement information
    -- unlike inldsd.ppc, I combine DRJ1 and DRJ2

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
        	NULL,
        	WRS.WIP_ENTITY_ID ,
        	-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.PRIOR_DATE,
		4 ,
  		DECODE(SIGN(WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY*
			(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM)-WRO.QUANTITY_ISSUED),
			-1, -1*(WRS.DAILY_PRODUCTION_RATE*
			WRO.QUANTITY_PER_ASSEMBLY*
			LEAST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM+1,
			WRS.PROCESSING_WORK_DAYS)-WRO.QUANTITY_ISSUED),
  			GREATEST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM-
			WRS.PROCESSING_WORK_DAYS,-1)*WRS.DAILY_PRODUCTION_RATE
			*WRO.QUANTITY_PER_ASSEMBLY) ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                WRS.DEMAND_CLASS,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM	BOM_CALENDAR_DATES C ,
		BOM_CALENDAR_DATES C1 ,
		WIP_REPETITIVE_SCHEDULES WRS ,
		WIP_REQUIREMENT_OPERATIONS WRO,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE   	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_REP_WIP_DEMAND = 1
    AND 	WRO.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		WRO.INVENTORY_ITEM_ID= I.INVENTORY_ITEM_ID
    AND		WRO.WIP_SUPPLY_TYPE <> 6
    AND		WRO.REQUIRED_QUANTITY > 0
    AND		(WRO.REQUIRED_QUANTITY-WRO.QUANTITY_ISSUED) > 0
    AND		WRO.OPERATION_SEQ_NUM > 0
    AND		WRS.ORGANIZATION_ID = WRO.ORGANIZATION_ID
    AND		WRS.REPETITIVE_SCHEDULE_ID = WRO.REPETITIVE_SCHEDULE_ID
    AND		WRS.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
    AND		WRS.STATUS_TYPE IN (1,3,4,6)
    AND		WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY*
        		LEAST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM+1,
			WRS.PROCESSING_WORK_DAYS) >WRO.QUANTITY_ISSUED
    AND		C1.CALENDAR_CODE= P.CALENDAR_CODE
    AND		C1.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
    AND		C1.CALENDAR_DATE=TRUNC(WRS.FIRST_UNIT_START_DATE)
    AND		C.CALENDAR_CODE=P.CALENDAR_CODE
    AND		C.EXCEPTION_SET_ID= P.CALENDAR_EXCEPTION_SET_ID
    AND		C.SEQ_NUM BETWEEN C1.PRIOR_SEQ_NUM AND
  			C1.PRIOR_SEQ_NUM + CEIL(WRS.PROCESSING_WORK_DAYS - 1)
    AND		C.CALENDAR_DATE >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                	NULL, C.CALENDAR_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)));

    -- insert user defined demand information
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
		NULL,
		U.SOURCE_ID,
		-1,
        	U.ORGANIZATION_ID,
        	U.INVENTORY_ITEM_ID,
		C.PRIOR_DATE,
		17 ,
		-1*U.PRIMARY_UOM_QUANTITY ,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                U.DEMAND_CLASS,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM 	BOM_CALENDAR_DATES C,
		MTL_ATP_RULES R ,
		MTL_PARAMETERS P ,
  		MTL_SYSTEM_ITEMS I ,
		MTL_USER_DEMAND U
    WHERE	I.ORGANIZATION_ID = U.ORGANIZATION_ID
    AND		I.INVENTORY_ITEM_ID = U.INVENTORY_ITEM_ID
    AND		I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_USER_DEFINED_DEMAND = 1
    AND		C.PRIOR_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                	NULL, C.PRIOR_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)))
    AND 	C.CALENDAR_CODE = P.CALENDAR_CODE
    AND 	C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND 	C.CALENDAR_DATE = TRUNC(U.REQUIREMENT_DATE);

    -- insert wip flow schedule demand information
    -- haven't added the logic to explode phantom

    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT 	-1,
        	NULL,
        	F.WIP_ENTITY_ID ,
		-1,
        	I.ORGANIZATION_ID,
        	I.INVENTORY_ITEM_ID,
        	C.PRIOR_DATE,
		24 ,
            	LEAST(-1*(F.PLANNED_QUANTITY-F.QUANTITY_COMPLETED)*
	    	COMPONENT_QUANTITY, 0),
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                F.DEMAND_CLASS,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM 	WIP_FLOW_SCHEDULES F,
		BOM_BILL_OF_MATERIALS BOM ,
		BOM_INVENTORY_COMPONENTS BIC ,
		BOM_CALENDAR_DATES C ,
        	MTL_PARAMETERS P ,
        	MTL_ATP_RULES R,
        	MTL_SYSTEM_ITEMS I
    WHERE 	I.ATP_FLAG in ('C', 'Y')
    AND		P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.INCLUDE_FLOW_SCHEDULE_DEMAND = 1
    AND 	BIC.COMPONENT_ITEM_ID = I.INVENTORY_ITEM_ID
    AND		TRUNC(BIC.EFFECTIVITY_DATE)<=TRUNC(F.SCHEDULED_COMPLETION_DATE)
    AND		TRUNC(NVL(BIC.DISABLE_DATE, F.SCHEDULED_COMPLETION_DATE+1))
		> TRUNC(F.SCHEDULED_COMPLETION_DATE)
    AND		BIC.COMPONENT_QUANTITY > 0
    AND		BOM.COMMON_BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
    AND 	BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
    AND 	F.PRIMARY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
    AND 	F.ORGANIZATION_ID = BOM.ORGANIZATION_ID
    AND 	F.STATUS = 1
    AND 	(F.PLANNED_QUANTITY - F.QUANTITY_COMPLETED) >0
    AND 	C.CALENDAR_CODE = P.CALENDAR_CODE
    AND 	C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND 	C.CALENDAR_DATE = TRUNC(F.SCHEDULED_COMPLETION_DATE)
    AND		C.PRIOR_DATE>=MRP_CALENDAR.next_work_day
			(P.ORGANIZATION_ID, 1, SYSDATE);

    SELECT OE_INSTALL.Get_Active_Product
    INTO l_oe_install
    FROM DUAL;

    IF l_oe_install = 'OE' THEN

    -- insert sales order demand
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                source_identifier4,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT      -1,
                NULL,
                D.DEMAND_SOURCE_LINE,
                D.DEMAND_SOURCE_HEADER_ID,
                -1,
		I.ORGANIZATION_ID,
		I.INVENTORY_ITEM_ID,
		C.PRIOR_DATE,
		DECODE(D.DEMAND_SOURCE_TYPE,
		       2,DECODE(D.RESERVATION_TYPE,1,2, 3,23,9),
		       8,DECODE(D.RESERVATION_TYPE,1,21,22),
		       D.DEMAND_SOURCE_TYPE),
		-1*(D.PRIMARY_UOM_QUANTITY-
		  GREATEST(NVL(D.RESERVATION_QUANTITY,0),D.COMPLETED_QUANTITY)),
		NULL,
	        SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM        BOM_CALENDAR_DATES C ,
                MTL_DEMAND D,
                MTL_ATP_RULES R ,
                MTL_PARAMETERS P ,
                MTL_SYSTEM_ITEMS I
    WHERE       I.ATP_FLAG in ('C', 'Y')
    AND         P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND		D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
		D.COMPLETED_QUANTITY)
    AND		D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    AND		D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    AND		D.AVAILABLE_TO_ATP = 1
    AND		(D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                   (SELECT S.SECONDARY_INVENTORY_NAME
                    FROM   MTL_SECONDARY_INVENTORIES S
		    WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
                    AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                    AND    S.AVAILABILITY_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   2, 1, S.AVAILABILITY_TYPE)))
    AND		(D.RESERVATION_TYPE = 2
                 OR D.PARENT_DEMAND_ID IS NULL
                 OR (D.RESERVATION_TYPE = 3 AND
                     ((R.include_DISCRETE_WIP_RECEIPTS = 1) or
                      (R.include_NONSTD_WIP_RECEIPTS = 1))))
    AND         C.PRIOR_DATE >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
                        NULL, C.PRIOR_DATE,
                        MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                        -NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)))
    AND         C.CALENDAR_CODE = P.CALENDAR_CODE
    AND         C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND         C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE);

    ELSE
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT      -1,
                NULL,
                L.LINE_ID,
                -1,
                I.ORGANIZATION_ID,
                I.INVENTORY_ITEM_ID,
                C.PRIOR_DATE,
                2 ,
                -1*(L.ORDERED_QUANTITY-NVL(SHIPPED_QUANTITY, 0)),
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                L.DEMAND_CLASS_CODE,
                1, -- demand
                I.PRODUCT_FAMILY_ITEM_ID
    FROM    	BOM_CALENDAR_DATES C ,
        	OE_ORDER_LINES L,
        	MTL_ATP_RULES R ,
        	MTL_PARAMETERS P ,
        	MTL_SYSTEM_ITEMS I
    WHERE   	I.ATP_FLAG in ('C', 'Y')
    AND     	P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND     	R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND     	R.INCLUDE_SALES_ORDERS = 1
    AND     	L.SHIP_FROM_ORG_ID = I.ORGANIZATION_ID
    AND     	L.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND     	L.VISIBLE_DEMAND_FLAG = 'Y'
    AND         L.ORDERED_QUANTITY > NVL(L.SHIPPED_QUANTITY,0)
    AND         C.PRIOR_DATE >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                	NULL, C.PRIOR_DATE,
                	MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                	-NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)))
    AND     	C.CALENDAR_CODE = P.CALENDAR_CODE
    AND     	C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
    AND     	C.CALENDAR_DATE = TRUNC(L.SCHEDULE_SHIP_DATE);

    END IF;

/*
    This part is for planning server

    l_instance_id := ****

    -- select demand records from ODS for items
    INSERT INTO mrp_atp_supply_demand(
                source_identifier1,
                source_identifier2,
                source_identifier3,
                plan_id,
                organization_id,
                inventory_item_id,
                supply_demand_date,
                supply_demand_source_type,
                supply_demand_quantity,
                reservation_quantity,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                demand_class,
                supply_demand_type,
                product_family_item_id)
    SELECT      l_instance_id,
                NULL,
                D.DISPOSITION_ID,
                -1,
                D.SR_INVENTORY_ITEM_ID,
                D.ORGANIZATION_ID,
                D.USING_ASSEMBLY_DEMAND_DATE,
                DECODE(D.ORIGINATION_TYPE,
                       2, NONSTD_JOBS_DEMAND,
                       3, DISCRETE_JOBS_DEMAND,
		       4, REPETITIVE_SCHEDULE_DEMAND,
                       6, SALES_ORDER_DEMAND,
                      24, SALES_ORDER_DEMAND),
                -1*D.USING_REQUIREMENT_QUANTITY,
                NULL, -- reservation quantity
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                D.DEMAND_CLASS,
                1, -- demand
                NULL -- actually this should be the product family item id
    FROM        MSC_DEMANDS D,
                MSC_ATP_RULES R,
                MSC_PARAMETERS P ,
                MSC_SYSTEM_ITEMS I
    WHERE       I.ATP_FLAG in ('C', 'Y')
    AND		I.SR_INSTANCE_ID = l_instance_id
    AND		I.PLAN_ID = -1
    AND         P.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         P.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND         R.RULE_ID = NVL(I.ATP_RULE_ID, P.DEFAULT_ATP_RULE_ID)
    AND		R.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.PLAN_ID = -1
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND		D.PLAN_ID = -1
    AMD		D.ORIGINATION_TYPE in (
                DECODE(R.INCLUDE_SALES_ORDERS, 1, 6, -1),
                DECODE(R.INCLUDE_SALES_ORDERS, 1, 24, -1),
                DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
                DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
    AND         D.USING_ASSEMBLY_DEMAND_DATE  >=
                DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
                        NULL,NVL(D.FIRM_DATE, D.USING_REQUIREMENT_QUANTITY),
                        MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID, 1, SYSDATE,
                        -NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)));

*/
END Collect_Atp_Info;

END MRP_ATP_COLLECTION;

/
