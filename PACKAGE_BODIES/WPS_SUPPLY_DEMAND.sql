--------------------------------------------------------
--  DDL for Package Body WPS_SUPPLY_DEMAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WPS_SUPPLY_DEMAND" AS
/* $Header: wpsmtsdb.pls 120.2 2006/03/09 11:17:31 mlouie noship $  */


    -- Used SUPPLY DEMAND SOURCE TYPE (from the existing ones in mfg_lookups:)
        --  1: Purchase order                  (Used)
        --  2: Sales order                     (Used)
        --  3: Account number                  (Not Used)
        --  4: WIP repetitive schedule         (Used)
        --  5: WIP discrete job                (Used)
        --  6: Account alias                   (Not Used)
        --  7: WIP nonstandard job             (Used)
        --  8: Onhand quantity                 (Used)
        --  9: Reserved sales order            (Not Used)
        -- 10: Reserved account number         (Not Used)
        -- 11: Reserved account alias          (Not Used)
        -- 12: Intransit receipt               (Used)
        -- 13: Discrete MPS                    (Not Used)
        -- 14: Repetitive MPS                  (Not Used)
        -- 15: Onhand Reservation              (Not Used)
        -- 16: User supply                     (Used)
        -- 17: User Demand                     (Used)
        -- 18: PO Requisition                  (Not Used)
        -- 19: Reserved user source            (Not Used)
        -- 20: Internal requisition            (Not Used)
        -- 21: Internal order                  (Used)
        -- 22: Reserved internal order         (Not Used)
        -- 23: WIP Supply Reservation          (Not Used)
        -- 24: Flow Schedule                   (Used)



    -- SUPPLY DEMAND TYPE:
        --  1: Demand
        --  2: Supply


    -- source_identifier1: instance id.  -1 for non-distributed environment
    -- source_identifier2: null for now

    -- plan_id: -1 if it is from execution system
    --                      (-2 if populated from scheduling manager)




/*
  This function calls the procedure by the same name and returns the number of
  records collected in the global pl/sql variable. Returns -1 on error.
*/
FUNCTION Collect_Supply_Demand_Info(p_group_id          IN NUMBER,
				    p_sys_seq_num       IN NUMBER,
				    p_mrp_status        IN NUMBER,
				    p_org_id            IN NUMBER) RETURN NUMBER
  IS
     l_err_buf   VARCHAR2(2000);
     l_ret_code  NUMBER;
BEGIN

   Clear_Supply_Demand_Info;

   Collect_Supply_Demand_Info(p_group_id          => p_group_id,
			      p_sys_seq_num       => p_sys_seq_num,
			      p_mrp_status        => p_mrp_status,
	 		      p_org_id            => p_org_id,
			      p_sup_dem_table     => g_supply_demand_table,
			      ERRBUF              => l_err_buf,
			      RETCODE             => l_ret_code);

   RETURN g_supply_demand_table.COUNT;

EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;

END Collect_Supply_Demand_Info;



PROCEDURE Get_Supply_Demand_Info(x_supply_demand_table OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE)
  IS
BEGIN
   x_supply_demand_table := g_supply_demand_table;

END Get_Supply_Demand_Info;


/*
  This procedure exists only for the sake of Pro*C. At this point Pro*C allows only
  arrays of primitives in pl/sql blocks, so this procedure essentially converts the
  global "table of records" into a bunch of "table of numbers"
*/
PROCEDURE Get_Supply_Demand_Info(p_starting_index                  IN  NUMBER DEFAULT 1,
				 p_ending_index                    IN  NUMBER DEFAULT -1,
				 x_rows_fetched                    OUT NOCOPY NUMBER,
				 x_reservation_type_tbl            OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_src_type_tbl      OUT NOCOPY Number_Tbl_Type,
				 x_txn_source_type_id_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_source_id_tbl     OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_type_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_quantity_tbl      OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_date_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_inventory_item_id_tbl           OUT NOCOPY Number_Tbl_Type,
				 x_organization_id_tbl             OUT NOCOPY Number_Tbl_Type)
  IS
     l_ending_index   NUMBER;
     l_starting_index NUMBER;
     l_max_length     NUMBER := g_supply_demand_table.COUNT;
BEGIN

   x_rows_fetched := 0;

   IF p_ending_index < 0 THEN
      l_ending_index := l_max_length;
    ELSIF p_ending_index > l_max_length THEN
      l_ending_index := l_max_length;
    ELSE
      l_ending_index := p_ending_index;
   END IF;

   IF p_starting_index < 0 THEN
      l_starting_index := 1;
    ELSIF p_starting_index > l_max_length THEN
      RETURN;
    ELSE
      l_starting_index := p_starting_index;
   END IF;


   FOR i IN l_starting_index..l_ending_index LOOP

      x_reservation_type_tbl(x_rows_fetched+1)       :=
	Nvl(g_supply_demand_table(i).reservation_type,0);

      x_supply_demand_src_type_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).supply_demand_source_type,0);

      x_txn_source_type_id_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).txn_source_type_id,0);

      x_supply_demand_source_id_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).supply_demand_source_id,0);

      x_supply_demand_type_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).supply_demand_type,0);

      x_supply_demand_quantity_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).supply_demand_quantity,0);

      x_supply_demand_date_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).supply_demand_date,0);

      x_inventory_item_id_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).inventory_item_id,0);

      x_organization_id_tbl(x_rows_fetched+1) :=
	Nvl(g_supply_demand_table(i).organization_id,0);

      x_rows_fetched := x_rows_fetched + 1;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END Get_Supply_Demand_Info;



PROCEDURE Clear_Supply_Demand_Info
  IS
BEGIN

   g_supply_demand_table.delete;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END Clear_Supply_Demand_Info;


/*
  This procedure calls two separate procedures, one to collect the supply information
  and the other to collect the demand information. All the results are stored in a
  global pl/sql table of records.
*/
PROCEDURE Collect_Supply_Demand_Info(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_org_id            IN NUMBER,
				     p_sup_dem_table     IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER)
IS

BEGIN

   Collect_Supply_Info(p_group_id          => p_group_id,
		       p_sys_seq_num       => p_sys_seq_num,
		       p_mrp_status        => p_mrp_status,
		       p_supply_table      => p_sup_dem_table,
		       ERRBUF              => ERRBUF,
		       RETCODE             => RETCODE);

   Collect_Demand_Info(p_group_id          => p_group_id,
		       p_sys_seq_num       => p_sys_seq_num,
		       p_mrp_status        => p_mrp_status,
		       p_org_id            => p_org_id,
		       p_demand_table      => p_sup_dem_table,
		       ERRBUF              => ERRBUF,
		       RETCODE             => RETCODE);

END Collect_Supply_Demand_Info;


/*
This procedure is a wrapper to collect all the individual supply types.
*/
PROCEDURE Collect_Supply_Info(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER)
IS

BEGIN

   Collect_OnHand_Supply(p_group_id          => p_group_id,
			 p_sys_seq_num       => p_sys_seq_num,
			 p_mrp_status        => p_mrp_status,
			 p_supply_table      => p_supply_table,
			 ERRBUF              => ERRBUF,
			 RETCODE             => RETCODE);

   Collect_User_Supply(p_group_id          => p_group_id,
		       p_sys_seq_num       => p_sys_seq_num,
		       p_mrp_status        => p_mrp_status,
		       p_supply_table      => p_supply_table,
		       ERRBUF              => ERRBUF,
		       RETCODE             => RETCODE);

   Collect_MTL_Supply(p_group_id          => p_group_id,
		      p_sys_seq_num       => p_sys_seq_num,
		      p_mrp_status        => p_mrp_status,
		      p_supply_table      => p_supply_table,
		      ERRBUF              => ERRBUF,
		      RETCODE             => RETCODE);

   Collect_DiscreteJob_Supply(p_group_id          => p_group_id,
			      p_sys_seq_num       => p_sys_seq_num,
			      p_mrp_status        => p_mrp_status,
			      p_supply_table      => p_supply_table,
			      ERRBUF              => ERRBUF,
			      RETCODE             => RETCODE);

   Collect_WipNegReq_Supply(p_group_id          => p_group_id,
			    p_sys_seq_num       => p_sys_seq_num,
			    p_mrp_status        => p_mrp_status,
			    p_supply_table      => p_supply_table,
			    ERRBUF              => ERRBUF,
			    RETCODE             => RETCODE);

   Collect_RepSched_Supply(p_group_id          => p_group_id,
			   p_sys_seq_num       => p_sys_seq_num,
			   p_mrp_status        => p_mrp_status,
			   p_supply_table      => p_supply_table,
			   ERRBUF              => ERRBUF,
			   RETCODE             => RETCODE);

   Collect_FlowSched_Supply(p_group_id          => p_group_id,
			    p_sys_seq_num       => p_sys_seq_num,
			    p_mrp_status        => p_mrp_status,
			    p_supply_table      => p_supply_table,
			    ERRBUF              => ERRBUF,
			    RETCODE             => RETCODE);




END Collect_Supply_Info;


/*
This procedure is a wrapper to collect all the individual demand types.
*/
PROCEDURE Collect_Demand_Info(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_org_id            IN NUMBER,
			      p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER)
IS

BEGIN

   Collect_DiscreteJob_Demand(p_group_id          => p_group_id,
			      p_sys_seq_num       => p_sys_seq_num,
			      p_mrp_status        => p_mrp_status,
			      p_demand_table      => p_demand_table,
			      ERRBUF              => ERRBUF,
			      RETCODE             => RETCODE);

   Collect_RepSched_Demand(p_group_id          => p_group_id,
			   p_sys_seq_num       => p_sys_seq_num,
			   p_mrp_status        => p_mrp_status,
			   p_demand_table      => p_demand_table,
			   ERRBUF              => ERRBUF,
			   RETCODE             => RETCODE);

   Collect_User_Demand(p_group_id          => p_group_id,
		       p_sys_seq_num       => p_sys_seq_num,
		       p_mrp_status        => p_mrp_status,
		       p_demand_table      => p_demand_table,
		       ERRBUF              => ERRBUF,
		       RETCODE             => RETCODE);

   Collect_FlowSched_Demand(p_group_id          => p_group_id,
			    p_sys_seq_num       => p_sys_seq_num,
			    p_mrp_status        => p_mrp_status,
			    p_demand_table      => p_demand_table,
			    ERRBUF              => ERRBUF,
			    RETCODE             => RETCODE);

   Collect_SalesOrder_Demand(p_group_id          => p_group_id,
			     p_sys_seq_num       => p_sys_seq_num,
			     p_mrp_status        => p_mrp_status,
			     p_org_id            => p_org_id,
			     p_demand_table      => p_demand_table,
			     ERRBUF              => ERRBUF,
			     RETCODE             => RETCODE);


END Collect_Demand_Info;



--
-- The procedures to collect individual supply/demand information follow.
--


PROCEDURE Collect_OnHand_Supply(p_group_id          IN NUMBER,
				p_sys_seq_num       IN NUMBER,
				p_mrp_status        IN NUMBER,
				p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				ERRBUF              OUT NOCOPY VARCHAR2,
				RETCODE             OUT NOCOPY NUMBER)
  IS

    CURSOR OH_SUPPLY_CURSOR IS
       SELECT
	 1 reservation_type,
	 8 supply_demand_source_type,
	 0 txn_source_type_id,
	 0 supply_demand_source_id,
	 2 supply_demand_type,
	 SUM(Q.TRANSACTION_QUANTITY) supply_demand_quantity,
	 TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	 V.INVENTORY_ITEM_ID inventory_item_id,
	 V.ORGANIZATION_ID organization_id
       FROM
	 MTL_SECONDARY_INVENTORIES S,
	 BOM_CALENDAR_DATES C,
	 MTL_PARAMETERS P,
	 MTL_ONHAND_QUANTITIES Q,
	 MTL_ATP_RULES R,
	 MTL_SYSTEM_ITEMS I,
	 MTL_GROUP_ITEM_ATPS_VIEW V
       WHERE I.ORGANIZATION_ID = V.ORGANIZATION_ID
	 AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	 AND Q.ORGANIZATION_ID = V.ORGANIZATION_ID
	 AND Q.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	 AND S.SECONDARY_INVENTORY_NAME = Q.SUBINVENTORY_CODE
	 AND S.ORGANIZATION_ID = Q.ORGANIZATION_ID
	 AND S.INVENTORY_ATP_CODE = DECODE(R.DEFAULT_ATP_SOURCES, 1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
	 AND S.AVAILABILITY_TYPE = DECODE(R.DEFAULT_ATP_SOURCES, 2, 1, S.AVAILABILITY_TYPE)
	 AND V.AVAILABLE_TO_ATP = 1
	 AND V.ATP_RULE_ID = R.RULE_ID
	 AND V.INVENTORY_ITEM_ID = DECODE(R.INCLUDE_ONHAND_AVAILABLE, 2, -1, V.INVENTORY_ITEM_ID)
	 AND V.ATP_GROUP_ID = P_GROUP_ID
	 AND R.DEMAND_CLASS_ATP_FLAG=2
	 AND P.CALENDAR_CODE = C.CALENDAR_CODE
	 AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	 AND C.CALENDAR_DATE = TRUNC(SYSDATE)
	 AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	 GROUP BY V.INVENTORY_ITEM_ID, V.ORGANIZATION_ID, C.NEXT_DATE, C.NEXT_SEQ_NUM
   UNION ALL
       SELECT
	 1 reservation_type,
	 8 supply_demand_source_type,
	 0 txn_source_type_id,
	 0 supply_demand_source_id,
	 2 supply_demand_type,
	 SUM(T.PRIMARY_QUANTITY) supply_demand_quantity,
	 TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	 V.INVENTORY_ITEM_ID inventory_item_id,
	 V.ORGANIZATION_ID organization_id
       FROM       MTL_SECONDARY_INVENTORIES S,
	 BOM_CALENDAR_DATES C,
	 MTL_PARAMETERS P,
	 MTL_MATERIAL_TRANSACTIONS_TEMP T,
	 MTL_SYSTEM_ITEMS I,
	 MTL_ATP_RULES R,
	 MTL_GROUP_ITEM_ATPS_VIEW V
       WHERE I.ORGANIZATION_ID = V.ORGANIZATION_ID
	 AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	 AND T.ORGANIZATION_ID = V.ORGANIZATION_ID
	 AND T.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	 AND T.POSTING_FLAG = 'Y'
	 AND S.SECONDARY_INVENTORY_NAME = T.SUBINVENTORY_CODE
	 AND S.ORGANIZATION_ID = T.ORGANIZATION_ID
	 AND S.INVENTORY_ATP_CODE = DECODE(R.DEFAULT_ATP_SOURCES, 1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
	 AND S.AVAILABILITY_TYPE = DECODE(R.DEFAULT_ATP_SOURCES, 2, 1, S.AVAILABILITY_TYPE)
	 AND V.AVAILABLE_TO_ATP = 1
	 AND V.ATP_RULE_ID = R.RULE_ID
	 AND V.INVENTORY_ITEM_ID = DECODE(R.INCLUDE_ONHAND_AVAILABLE, 2, -1, V.INVENTORY_ITEM_ID)
	 AND V.ATP_GROUP_ID = P_GROUP_ID
	 AND R.DEMAND_CLASS_ATP_FLAG=2
	 AND P.CALENDAR_CODE = C.CALENDAR_CODE
	 AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	 AND C.CALENDAR_DATE = TRUNC(SYSDATE)
	 AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	 GROUP BY V.INVENTORY_ITEM_ID, V.ORGANIZATION_ID, C.NEXT_DATE, C.NEXT_SEQ_NUM;

    l_supply_rec        OH_SUPPLY_CURSOR%ROWTYPE;
    j                   NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN OH_SUPPLY_CURSOR;

   LOOP
      FETCH OH_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN OH_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE OH_SUPPLY_CURSOR;

END Collect_OnHand_Supply;


PROCEDURE Collect_User_Supply(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER)
  IS

     CURSOR USER_SUPPLY_CURSOR IS
	SELECT
	  1 reservation_type,
	  16 supply_demand_source_type,
	  U.SOURCE_TYPE_ID txn_source_type_id,
	  U.SOURCE_ID supply_demand_source_id,
	  2 supply_demand_type,
	  U.PRIMARY_UOM_QUANTITY supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
FROM
	BOM_CALENDAR_DATES C,
	MTL_USER_SUPPLY U,
	MTL_SYSTEM_ITEMS I,
	MTL_PARAMETERS P,
	MTL_ATP_RULES R,
	MTL_GROUP_ITEM_ATPS_VIEW V
WHERE U.ORGANIZATION_ID = V.ORGANIZATION_ID
	AND U.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	AND V.AVAILABLE_TO_ATP = 1
	AND V.ATP_RULE_ID = R.RULE_ID
	AND V.INVENTORY_ITEM_ID = DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 2, -1, V.INVENTORY_ITEM_ID)
	AND V.ATP_GROUP_ID = P_GROUP_ID
	AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	AND NVL(U.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									  1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									  NVL(U.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
				     NULL, C.NEXT_SEQ_NUM,
				     P_SYS_SEQ_NUM-R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
	AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM +(DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
						       1, I.CUMULATIVE_TOTAL_LEAD_TIME,
						       2, I.CUM_MANUFACTURING_LEAD_TIME,
						       3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
						       4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1)
	AND P.CALENDAR_CODE = C.CALENDAR_CODE
	AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	AND C.CALENDAR_DATE = TRUNC(U.EXPECTED_DELIVERY_DATE);

     l_supply_rec   USER_SUPPLY_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN USER_SUPPLY_CURSOR;

   LOOP
      FETCH USER_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN USER_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE USER_SUPPLY_CURSOR;


END Collect_User_Supply;


PROCEDURE Collect_MTL_Supply(p_group_id          IN NUMBER,
			     p_sys_seq_num       IN NUMBER,
			     p_mrp_status        IN NUMBER,
			     p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			     ERRBUF              OUT NOCOPY VARCHAR2,
			     RETCODE             OUT NOCOPY NUMBER)
  IS

    -- queries mtl_supply information, that is PO, REQ, SHIP, RCV
    -- question here,
    -- I select NVL(S.MRP_PRIMARY_QUANTITY, S.TO_ORG_PRIMARY_QUANTITY)
    -- as the supply_demand_quantity if discrete mps is included,
    -- S.TO_ORG_PRIMARY_QUANTITY if not included.
    -- However, in inldsd.ppc, it selects
    -- S.TO_ORG_PRIMARY_QUANTITY for shipment, NVL(S.MRP_PRIMARY_QUANTITY, 0)
    -- if discrete mps is included, S.TO_ORG_PRIMARY_QUANTITY if not included

      CURSOR MTL_SUPPLY_CURSOR IS
SELECT
      1 reservation_type,
      DECODE(S.PO_HEADER_ID,
	     NULL,DECODE(S.SUPPLY_TYPE_CODE,
			 'REQ',DECODE(S.FROM_ORGANIZATION_ID,
				      NULL,18,
				      20),
			 12),
	     1) supply_demand_source_type,
      DECODE(S.PO_HEADER_ID,
	     NULL,DECODE(S.SUPPLY_TYPE_CODE,
			 'REQ',10,
			 8),
	     1) txn_source_type_id,
      DECODE(S.PO_HEADER_ID,
	     NULL,DECODE(S.SUPPLY_TYPE_CODE,
			 'REQ',REQ_HEADER_ID,
			 SHIPMENT_HEADER_ID),
	     PO_HEADER_ID) supply_demand_source_id,
      2 supply_demand_type,
      DECODE(P_MRP_STATUS,
	     1, DECODE(S.SUPPLY_TYPE_CODE,
		       'SHIPMENT', S.TO_ORG_PRIMARY_QUANTITY,
		       DECODE(NVL(V.N_COLUMN1,R.INCLUDE_DISCRETE_MPS),
			      1,NVL(S.MRP_PRIMARY_QUANTITY, 0),
			      S.TO_ORG_PRIMARY_QUANTITY)),
	     S.TO_ORG_PRIMARY_QUANTITY) supply_demand_quantity,
      TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
      V.INVENTORY_ITEM_ID inventory_item_id,
      V.ORGANIZATION_ID organization_id
FROM
      MTL_GROUP_ITEM_ATPS_VIEW V,
      MTL_ATP_RULES R,
      MTL_SYSTEM_ITEMS I,
      MTL_PARAMETERS P,
      BOM_CALENDAR_DATES C,
      MTL_SUPPLY S
WHERE V.ATP_GROUP_ID = P_GROUP_ID
      AND R.DEMAND_CLASS_ATP_FLAG=2
      AND V.AVAILABLE_TO_ATP = 1
      AND V.ATP_RULE_ID = R.RULE_ID
      AND((R.INCLUDE_INTERORG_TRANSFERS = 1
	   AND S.REQ_HEADER_ID IS NULL
	   AND S.PO_HEADER_ID IS NULL)
	  OR (S.REQ_HEADER_ID=DECODE(R.INCLUDE_INTERNAL_REQS,1,S.REQ_HEADER_ID)
	      AND S.FROM_ORGANIZATION_ID IS NOT NULL)
	  OR (S.SUPPLY_TYPE_CODE=DECODE(R.INCLUDE_VENDOR_REQS,1,'REQ')
	      AND S.FROM_ORGANIZATION_ID IS NULL)
	  OR S.PO_HEADER_ID=DECODE(R.INCLUDE_PURCHASE_ORDERS,1, S.PO_HEADER_ID))
      AND S.TO_ORGANIZATION_ID=V.ORGANIZATION_ID
      AND S.ITEM_ID = V.INVENTORY_ITEM_ID
      AND S.DESTINATION_TYPE_CODE='INVENTORY'
      AND (S.TO_SUBINVENTORY IS NULL OR EXISTS (SELECT
						'X' FROM MTL_SECONDARY_INVENTORIES S2
						WHERE S2.ORGANIZATION_ID=S.TO_ORGANIZATION_ID
						AND S.TO_SUBINVENTORY=S2.SECONDARY_INVENTORY_NAME
						AND S2.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
										  1, 1,
										  NULL, 1,
										  S2.INVENTORY_ATP_CODE)
						AND S2.AVAILABILITY_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
										 2, 1,
										 S2.AVAILABILITY_TYPE)))
      AND I.ORGANIZATION_ID= V.ORGANIZATION_ID
      AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
      AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
      AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
				   NULL, C.NEXT_SEQ_NUM,
				   P_SYS_SEQ_NUM-R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
      AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
						      1, I.CUMULATIVE_TOTAL_LEAD_TIME,
						      2, I.CUM_MANUFACTURING_LEAD_TIME,
						      3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
						      4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1)
      AND P.CALENDAR_CODE = C.CALENDAR_CODE
      AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
      AND C.CALENDAR_DATE = TRUNC(S.EXPECTED_DELIVERY_DATE);

     l_supply_rec   MTL_SUPPLY_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN MTL_SUPPLY_CURSOR;

   LOOP
      FETCH MTL_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN MTL_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE MTL_SUPPLY_CURSOR;

END Collect_MTL_Supply;

PROCEDURE Collect_DiscreteJob_Supply(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert wip discrete job information
    -- question here: do I need to apply bug 791215 here?
    -- that is , using net_quantity instead of mps_net_quantity?

   CURSOR DISCRETEJOB_SUPPLY_CURSOR IS
      SELECT
	1 reservation_type,
	DECODE(D.JOB_TYPE, 1, 5, 7) supply_demand_source_type,
	5 txn_source_type_id,
	D.WIP_ENTITY_ID supply_demand_source_id,
	2 supply_demand_type,
	DECODE(P_MRP_STATUS,
	       1, DECODE(NVL(V.N_COLUMN1,R.INCLUDE_DISCRETE_MPS),
			 1, DECODE(D.JOB_TYPE,1,
				   DECODE(I.MRP_PLANNING_CODE,
					  4,NVL(D.MPS_NET_QUANTITY,0),
					  D.START_QUANTITY),
				   D.START_QUANTITY),
			 D.START_QUANTITY) - D.QUANTITY_COMPLETED - D.QUANTITY_SCRAPPED,
	       D.START_QUANTITY - D.QUANTITY_COMPLETED - D.QUANTITY_SCRAPPED) supply_demand_quantity,
	TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	V.INVENTORY_ITEM_ID inventory_item_id,
	V.ORGANIZATION_ID organization_id
FROM       WIP_DISCRETE_JOBS D,
           BOM_CALENDAR_DATES C,
           MTL_PARAMETERS P,
           MTL_SYSTEM_ITEMS I,
           MTL_ATP_RULES R,
           MTL_GROUP_ITEM_ATPS_VIEW V
WHERE D.STATUS_TYPE IN (1,3,4,6)
	  AND (D.START_QUANTITY-D.QUANTITY_COMPLETED-D.QUANTITY_SCRAPPED) >0
	  AND D.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND D.PRIMARY_ITEM_ID=V.INVENTORY_ITEM_ID
	  AND V.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1,
					V.INVENTORY_ITEM_ID, DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS,
								    1,V.INVENTORY_ITEM_ID,
								    -1))
	  AND (D.JOB_TYPE =DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 1, -1)
	       OR D.JOB_TYPE =DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 3, -1))
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND I.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									     NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
				       NULL, C.NEXT_SEQ_NUM,
				       P_SYS_SEQ_NUM-R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
	  AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							  1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							  2, I.CUM_MANUFACTURING_LEAD_TIME,
							  3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							  4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1)
	  AND P.CALENDAR_CODE = C.CALENDAR_CODE
	  AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	  AND C.CALENDAR_DATE = TRUNC(D.SCHEDULED_COMPLETION_DATE);

   l_supply_rec   DISCRETEJOB_SUPPLY_CURSOR%ROWTYPE;
   j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN DISCRETEJOB_SUPPLY_CURSOR;

   LOOP
      FETCH DISCRETEJOB_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN DISCRETEJOB_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE DISCRETEJOB_SUPPLY_CURSOR;

END Collect_DiscreteJob_Supply;

PROCEDURE Collect_WipNegReq_Supply(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER)
  IS


    -- insert wip neg requirement information
    -- I have applied bug 454103 here.

     CURSOR WIPNEGREQ_SUPPLY_CURSOR IS
	SELECT
	  1 reservation_type,
	  DECODE(D.JOB_TYPE, 1, 5, 7) supply_demand_source_type,
	  5 txn_source_type_id,
	  D.WIP_ENTITY_ID supply_demand_source_id,
	  2 supply_demand_type,
	  -1*O.REQUIRED_QUANTITY supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
FROM	   MTL_GROUP_ITEM_ATPS_VIEW V,
           MTL_PARAMETERS P,
           MTL_ATP_RULES R,
           MTL_SYSTEM_ITEMS I,
           BOM_CALENDAR_DATES C,
           WIP_REQUIREMENT_OPERATIONS O,
           WIP_DISCRETE_JOBS D
WHERE O.ORGANIZATION_ID=D.ORGANIZATION_ID
	  AND O.INVENTORY_ITEM_ID=V.INVENTORY_ITEM_ID
	  AND O.WIP_ENTITY_ID=D.WIP_ENTITY_ID
	  AND O.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND O.WIP_SUPPLY_TYPE <> 6
	  AND O.REQUIRED_QUANTITY < 0
	  AND O.OPERATION_SEQ_NUM > 0
	  AND (D.JOB_TYPE=DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 1, -1)
	       OR D.JOB_TYPE =DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 3, -1))
	  AND D.STATUS_TYPE IN (1,3,4,6)
	  AND D.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND V.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1,
					V.INVENTORY_ITEM_ID, DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1,
								    V.INVENTORY_ITEM_ID, -1))
	  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									     NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
           AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
					NULL, C.NEXT_SEQ_NUM,
					P_SYS_SEQ_NUM-R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
	  AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							  1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							  2, I.CUM_MANUFACTURING_LEAD_TIME,
							  3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							  4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1)
	  AND P.CALENDAR_CODE = C.CALENDAR_CODE
	  AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	  AND C.CALENDAR_DATE = TRUNC(O.DATE_REQUIRED);

     l_supply_rec   WIPNEGREQ_SUPPLY_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN WIPNEGREQ_SUPPLY_CURSOR;

   LOOP
      FETCH WIPNEGREQ_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN WIPNEGREQ_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE WIPNEGREQ_SUPPLY_CURSOR;

END Collect_WipNegReq_Supply;


PROCEDURE Collect_RepSched_Supply(p_group_id          IN NUMBER,
				  p_sys_seq_num       IN NUMBER,
				  p_mrp_status        IN NUMBER,
				  p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				  ERRBUF              OUT NOCOPY VARCHAR2,
				  RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert wip repetitive supply

     CURSOR REPSCHED_SUPPLY_CURSOR IS
	SELECT
	  1 reservation_type,
	  4 supply_demand_source_type,
	  5 txn_source_type_id,
	  WRS.REPETITIVE_SCHEDULE_ID supply_demand_source_id,
	  2 supply_demand_type,
	  DECODE(SIGN(WRS.DAILY_PRODUCTION_RATE*(C.NEXT_SEQ_NUM-C1.NEXT_SEQ_NUM)-WRS.QUANTITY_COMPLETED),
		 -1,WRS.DAILY_PRODUCTION_RATE*LEAST(C.NEXT_SEQ_NUM-C1.NEXT_SEQ_NUM+1,
						    WRS.PROCESSING_WORK_DAYS)-WRS.QUANTITY_COMPLETED,
		 LEAST(C1.NEXT_SEQ_NUM+WRS.PROCESSING_WORK_DAYS-C.NEXT_SEQ_NUM,1)*WRS.DAILY_PRODUCTION_RATE) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
FROM
	  MTL_GROUP_ATPS_VIEW V,
	  MTL_ATP_RULES R,
	  MTL_SYSTEM_ITEMS I,
	  MTL_PARAMETERS P,
	  BOM_CALENDAR_DATES C,
	  BOM_CALENDAR_DATES C1,
	  WIP_REPETITIVE_SCHEDULES WRS,
	  WIP_REPETITIVE_ITEMS WRI
WHERE V.ATP_GROUP_ID = P_GROUP_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND WRI.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND WRI.PRIMARY_ITEM_ID=V.INVENTORY_ITEM_ID
	  AND R.INCLUDE_REP_WIP_RECEIPTS = 1
	  AND WRI.WIP_ENTITY_ID = WRS.WIP_ENTITY_ID
	  AND WRI.LINE_ID = WRS.LINE_ID
	  AND WRS.ORGANIZATION_ID = WRI.ORGANIZATION_ID
	  AND WRS.STATUS_TYPE IN (1,3,4,6)
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND C1.CALENDAR_CODE=P.CALENDAR_CODE
	  AND C1.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
	  AND C1.CALENDAR_DATE=TRUNC(WRS.FIRST_UNIT_COMPLETION_DATE)
	  AND C.CALENDAR_CODE=P.CALENDAR_CODE
	  AND C.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
	  AND C.SEQ_NUM BETWEEN C1.NEXT_SEQ_NUM AND C1.NEXT_SEQ_NUM + CEIL(WRS.PROCESSING_WORK_DAYS - 1)
	  AND WRS.DAILY_PRODUCTION_RATE*LEAST(C.NEXT_SEQ_NUM-C1.NEXT_SEQ_NUM+1,WRS.PROCESSING_WORK_DAYS) > WRS.QUANTITY_COMPLETED
	  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(WRS.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									       1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									       NVL(WRS.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
				       NULL, C.NEXT_SEQ_NUM,
				       P_SYS_SEQ_NUM-R.PAST_DUE_DEMAND_CUTOFF_FENCE)
	  AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (
						   DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							  1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							  2, I.CUM_MANUFACTURING_LEAD_TIME,
							  3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							  4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1);

     l_supply_rec   REPSCHED_SUPPLY_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN REPSCHED_SUPPLY_CURSOR;

   LOOP
      FETCH REPSCHED_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN REPSCHED_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE REPSCHED_SUPPLY_CURSOR;

END Collect_RepSched_Supply;

PROCEDURE Collect_FlowSched_Supply(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER)
  IS
    -- insert flow schedule supply information
     CURSOR FLOWSCHED_SUPPLY_CURSOR IS
	SELECT
	  1 reservation_type,
	  24 supply_demand_source_type,
	  5 txn_source_type_id,
	  D.WIP_ENTITY_ID supply_demand_source_id,
	  2 supply_demand_type,
	  DECODE(P_MRP_STATUS,
		 1,DECODE(NVL(V.N_COLUMN1,R.INCLUDE_DISCRETE_MPS),
			  1,DECODE(I.MRP_PLANNING_CODE,
				   4,NVL(D.MPS_NET_QUANTITY,0),
				   8,NVL(D.MPS_NET_QUANTITY,0),
				   D.PLANNED_QUANTITY),
			  D.PLANNED_QUANTITY - D.QUANTITY_COMPLETED), /* I missed something here */
		 D.PLANNED_QUANTITY - D.QUANTITY_COMPLETED) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.NEXT_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
FROM
           WIP_FLOW_SCHEDULES D,
           BOM_CALENDAR_DATES C,
           MTL_PARAMETERS P,
           MTL_SYSTEM_ITEMS I,
           MTL_ATP_RULES R,
           MTL_GROUP_ITEM_ATPS_VIEW V
WHERE D.STATUS = 1
	  AND (D.PLANNED_QUANTITY-D.QUANTITY_COMPLETED) >0
	  AND D.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND D.PRIMARY_ITEM_ID=V.INVENTORY_ITEM_ID
	  AND D.SCHEDULED_FLAG = 1
	  AND V.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, V.INVENTORY_ITEM_ID, -1)
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND I.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									     NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND C.NEXT_SEQ_NUM >= DECODE(R.PAST_DUE_SUPPLY_CUTOFF_FENCE,
				       NULL, C.NEXT_SEQ_NUM,
				       P_SYS_SEQ_NUM-R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
	  AND C.NEXT_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							  1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							  2, I.CUM_MANUFACTURING_LEAD_TIME,
							  3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							  4, R.INFINITE_SUPPLY_TIME_FENCE)), C.NEXT_SEQ_NUM+1)
	  AND P.CALENDAR_CODE = C.CALENDAR_CODE
	  AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	  AND C.CALENDAR_DATE = TRUNC(D.SCHEDULED_COMPLETION_DATE)
	  AND C.NEXT_SEQ_NUM >= P_SYS_SEQ_NUM;

     l_supply_rec   FLOWSCHED_SUPPLY_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_supply_table.LAST,0) + 1;
BEGIN

   OPEN FLOWSCHED_SUPPLY_CURSOR;

   LOOP
      FETCH FLOWSCHED_SUPPLY_CURSOR INTO l_supply_rec;
      EXIT WHEN FLOWSCHED_SUPPLY_CURSOR%NOTFOUND;

      p_supply_table(j).reservation_type          := l_supply_rec.reservation_type;
      p_supply_table(j).supply_demand_source_type := l_supply_rec.supply_demand_source_type;
      p_supply_table(j).txn_source_type_id        := l_supply_rec.txn_source_type_id;
      p_supply_table(j).supply_demand_source_id   := l_supply_rec.supply_demand_source_id;
      p_supply_table(j).supply_demand_type        := l_supply_rec.supply_demand_type;
      p_supply_table(j).supply_demand_quantity    := l_supply_rec.supply_demand_quantity;
      p_supply_table(j).supply_demand_date        := l_supply_rec.supply_demand_date;
      p_supply_table(j).inventory_item_id         := l_supply_rec.inventory_item_id;
      p_supply_table(j).organization_id           := l_supply_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE FLOWSCHED_SUPPLY_CURSOR;

END Collect_FlowSched_Supply;

--
-- The rest of the procedures collect demand information.
--

PROCEDURE Collect_DiscreteJob_Demand(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER)
  IS
    -- insert wip discrete requirement information

     CURSOR DISCRETEJOB_DEMAND_CURSOR IS
	SELECT
	  1 reservation_type,
	  DECODE(D.JOB_TYPE, 1, 5, 7) supply_demand_source_type,
	  5 txn_source_type_id,
	  D.WIP_ENTITY_ID supply_demand_source_id,
	  1 supply_demand_type,
	  LEAST(-1*(O.REQUIRED_QUANTITY-O.QUANTITY_ISSUED),0) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
	FROM
	  MTL_GROUP_ITEM_ATPS_VIEW V,
	  MTL_PARAMETERS P,
	  MTL_ATP_RULES R,
	  MTL_SYSTEM_ITEMS I,
	  BOM_CALENDAR_DATES C,
	  WIP_REQUIREMENT_OPERATIONS O,
	  WIP_DISCRETE_JOBS D,
	  BOM_CALENDAR_DATES C1
WHERE O.INVENTORY_ITEM_ID=V.INVENTORY_ITEM_ID
  AND O.ORGANIZATION_ID = V.ORGANIZATION_ID
  AND O.WIP_SUPPLY_TYPE <> 6
  AND O.REQUIRED_QUANTITY > 0
  AND O.OPERATION_SEQ_NUM > 0
  AND O.WIP_ENTITY_ID=D.WIP_ENTITY_ID
  AND O.ORGANIZATION_ID=D.ORGANIZATION_ID
  AND O.DATE_REQUIRED >= c1.calendar_date
  AND ((D.JOB_TYPE= 1 AND R.INCLUDE_DISCRETE_WIP_DEMAND = 1)
	OR (D.JOB_TYPE = 3 AND R.INCLUDE_NONSTD_WIP_DEMAND = 1))
  AND D.STATUS_TYPE IN (1,3,4,6)
  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
  AND V.AVAILABLE_TO_ATP = 1
  AND V.ATP_RULE_ID = R.RULE_ID
  AND V.ATP_GROUP_ID = P_GROUP_ID
  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
  AND NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
								     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
								     NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
  AND C1.SEQ_NUM = greatest(1,P_SYS_SEQ_NUM-Nvl(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
  AND C.PRIOR_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
						   1, I.CUMULATIVE_TOTAL_LEAD_TIME,
						   2, I.CUM_MANUFACTURING_LEAD_TIME,
						   3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
						   4, R.INFINITE_SUPPLY_TIME_FENCE)), C.PRIOR_SEQ_NUM+1)
  AND P.CALENDAR_CODE = C.CALENDAR_CODE
  AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
  AND P.CALENDAR_CODE = C1.CALENDAR_CODE
  AND P.CALENDAR_EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
  AND C.CALENDAR_DATE = TRUNC(O.DATE_REQUIRED)
  AND NOT EXISTS (SELECT 'exists in group?'
		  FROM MTL_DEMAND_INTERFACE MDI1
		  WHERE MDI1.ATP_GROUP_ID = P_GROUP_ID
		  AND MDI1.ORGANIZATION_ID + 0 = V.ORGANIZATION_ID
		  AND MDI1.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
		  AND NVL(MDI1.SUPPLY_HEADER_ID, -1) = D.WIP_ENTITY_ID);

     l_demand_rec   DISCRETEJOB_DEMAND_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_demand_table.LAST,0) + 1;
BEGIN

   OPEN DISCRETEJOB_DEMAND_CURSOR;

   LOOP
      FETCH DISCRETEJOB_DEMAND_CURSOR INTO l_demand_rec;
      EXIT WHEN DISCRETEJOB_DEMAND_CURSOR%NOTFOUND;

      p_demand_table(j).reservation_type          := l_demand_rec.reservation_type;
      p_demand_table(j).supply_demand_source_type := l_demand_rec.supply_demand_source_type;
      p_demand_table(j).txn_source_type_id        := l_demand_rec.txn_source_type_id;
      p_demand_table(j).supply_demand_source_id   := l_demand_rec.supply_demand_source_id;
      p_demand_table(j).supply_demand_type        := l_demand_rec.supply_demand_type;
      p_demand_table(j).supply_demand_quantity    := l_demand_rec.supply_demand_quantity;
      p_demand_table(j).supply_demand_date        := l_demand_rec.supply_demand_date;
      p_demand_table(j).inventory_item_id         := l_demand_rec.inventory_item_id;
      p_demand_table(j).organization_id           := l_demand_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE DISCRETEJOB_DEMAND_CURSOR;

END Collect_DiscreteJob_Demand;

PROCEDURE Collect_RepSched_Demand(p_group_id          IN NUMBER,
				  p_sys_seq_num       IN NUMBER,
				  p_mrp_status        IN NUMBER,
				  p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				  ERRBUF              OUT NOCOPY VARCHAR2,
				  RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert wip repetitive requirement information
    -- unlike inldsd.ppc, I combine DRJ1 and DRJ2

     CURSOR REPSCHED_DEMAND_CURSOR IS
	SELECT
	  1 reservation_type,
	  4 supply_demand_source_type,
	  5 txn_source_type_id,
	  WRS.REPETITIVE_SCHEDULE_ID supply_demand_source_id,
	  1 supply_demand_type,
	  DECODE(SIGN(WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY*(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM)-WRO.QUANTITY_ISSUED),
		 -1,-1*(WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY*LEAST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM+1,WRS.PROCESSING_WORK_DAYS)-WRO.QUANTITY_ISSUED),
		 GREATEST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM-WRS.PROCESSING_WORK_DAYS,-1)*WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
	FROM
	  MTL_GROUP_ITEM_ATPS_VIEW V,
	  MTL_PARAMETERS P,
	  MTL_ATP_RULES R,
	  MTL_SYSTEM_ITEMS I,
	  BOM_CALENDAR_DATES C,
	  BOM_CALENDAR_DATES C1,
	  WIP_REPETITIVE_SCHEDULES WRS,
	  WIP_OPERATIONS WO,
	  WIP_REQUIREMENT_OPERATIONS WRO
	WHERE WRO.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND WRO.INVENTORY_ITEM_ID=V.INVENTORY_ITEM_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND R.INCLUDE_REP_WIP_DEMAND = 1
	  AND WRO.WIP_SUPPLY_TYPE <> 6
	  AND WRO.REQUIRED_QUANTITY > 0
	  AND WRO.OPERATION_SEQ_NUM > 0
	  AND WRO.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM(+)
	  AND WRO.REPETITIVE_SCHEDULE_ID = WO.REPETITIVE_SCHEDULE_ID(+)
	  AND WRO.ORGANIZATION_ID = WO.ORGANIZATION_ID(+)
	  AND WRO.REPETITIVE_SCHEDULE_ID = WRS.REPETITIVE_SCHEDULE_ID
	  AND WRS.ORGANIZATION_ID = WRO.ORGANIZATION_ID
	  AND WRS.STATUS_TYPE IN (1,3,4,6)
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND C1.CALENDAR_CODE=P.CALENDAR_CODE
	  AND C1.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
	  AND C1.CALENDAR_DATE=TRUNC(WRS.FIRST_UNIT_START_DATE)
	  AND C.CALENDAR_CODE=P.CALENDAR_CODE
	  AND C.EXCEPTION_SET_ID=P.CALENDAR_EXCEPTION_SET_ID
	  AND C.SEQ_NUM BETWEEN C1.PRIOR_SEQ_NUM AND C1.PRIOR_SEQ_NUM + CEIL(WRS.PROCESSING_WORK_DAYS - 1)
	  AND WRS.DAILY_PRODUCTION_RATE*WRO.QUANTITY_PER_ASSEMBLY*LEAST(C.PRIOR_SEQ_NUM-C1.PRIOR_SEQ_NUM+1,WRS.PROCESSING_WORK_DAYS)>WRO.QUANTITY_ISSUED
	  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(WRS.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									       1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									       NVL(WRS.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
					NULL, C.PRIOR_SEQ_NUM,
					P_SYS_SEQ_NUM-R.PAST_DUE_DEMAND_CUTOFF_FENCE)
	  AND C.PRIOR_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							    1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							    2, I.CUM_MANUFACTURING_LEAD_TIME,
							    3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							    4, R.INFINITE_SUPPLY_TIME_FENCE)), C.PRIOR_SEQ_NUM+1)
	  AND NOT EXISTS (SELECT 'exists in group?'
			  FROM MTL_DEMAND_INTERFACE MDI1
			  WHERE MDI1.ATP_GROUP_ID = P_GROUP_ID
			  AND MDI1.ORGANIZATION_ID = V.ORGANIZATION_ID
			  AND MDI1.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
			  AND NVL(MDI1.SUPPLY_HEADER_ID, -1) = WRS.WIP_ENTITY_ID);


     l_demand_rec   REPSCHED_DEMAND_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_demand_table.LAST,0) + 1;
BEGIN

   OPEN REPSCHED_DEMAND_CURSOR;

   LOOP
      FETCH REPSCHED_DEMAND_CURSOR INTO l_demand_rec;
      EXIT WHEN REPSCHED_DEMAND_CURSOR%NOTFOUND;

      p_demand_table(j).reservation_type          := l_demand_rec.reservation_type;
      p_demand_table(j).supply_demand_source_type := l_demand_rec.supply_demand_source_type;
      p_demand_table(j).txn_source_type_id        := l_demand_rec.txn_source_type_id;
      p_demand_table(j).supply_demand_source_id   := l_demand_rec.supply_demand_source_id;
      p_demand_table(j).supply_demand_type        := l_demand_rec.supply_demand_type;
      p_demand_table(j).supply_demand_quantity    := l_demand_rec.supply_demand_quantity;
      p_demand_table(j).supply_demand_date        := l_demand_rec.supply_demand_date;
      p_demand_table(j).inventory_item_id         := l_demand_rec.inventory_item_id;
      p_demand_table(j).organization_id           := l_demand_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE REPSCHED_DEMAND_CURSOR;

END Collect_RepSched_Demand;

PROCEDURE Collect_User_Demand(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert user defined demand information
     CURSOR USER_DEMAND_CURSOR IS
	SELECT
	  1 reservation_type,
	  17 supply_demand_source_type,
	  U.SOURCE_TYPE_ID txn_source_type_id,
	  U.SOURCE_ID supply_demand_source_id,
	  1 supply_demand_type,
	  -1*U.PRIMARY_UOM_QUANTITY supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
	FROM
	  MTL_GROUP_ITEM_ATPS_VIEW V,
	  MTL_PARAMETERS P,
	  MTL_ATP_RULES R,
	  MTL_SYSTEM_ITEMS I,
	  MTL_USER_DEMAND U,
	  BOM_CALENDAR_DATES C
	WHERE U.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND U.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.INVENTORY_ITEM_ID = DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 2, -1, V.INVENTORY_ITEM_ID)
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(U.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),NVL(U.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
					NULL, C.PRIOR_SEQ_NUM,
					P_SYS_SEQ_NUM-R.PAST_DUE_DEMAND_CUTOFF_FENCE)
	  AND C.PRIOR_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							    1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							    2, I.CUM_MANUFACTURING_LEAD_TIME,
							    3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							    4, R.INFINITE_SUPPLY_TIME_FENCE)), C.PRIOR_SEQ_NUM+1)
	  AND P.CALENDAR_CODE = C.CALENDAR_CODE
	  AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	  AND C.CALENDAR_DATE = TRUNC(U.REQUIREMENT_DATE);

     l_demand_rec   USER_DEMAND_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_demand_table.LAST,0) + 1;
BEGIN

   OPEN USER_DEMAND_CURSOR;

   LOOP
      FETCH USER_DEMAND_CURSOR INTO l_demand_rec;
      EXIT WHEN USER_DEMAND_CURSOR%NOTFOUND;

      p_demand_table(j).reservation_type          := l_demand_rec.reservation_type;
      p_demand_table(j).supply_demand_source_type := l_demand_rec.supply_demand_source_type;
      p_demand_table(j).txn_source_type_id        := l_demand_rec.txn_source_type_id;
      p_demand_table(j).supply_demand_source_id   := l_demand_rec.supply_demand_source_id;
      p_demand_table(j).supply_demand_type        := l_demand_rec.supply_demand_type;
      p_demand_table(j).supply_demand_quantity    := l_demand_rec.supply_demand_quantity;
      p_demand_table(j).supply_demand_date        := l_demand_rec.supply_demand_date;
      p_demand_table(j).inventory_item_id         := l_demand_rec.inventory_item_id;
      p_demand_table(j).organization_id           := l_demand_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE USER_DEMAND_CURSOR;

END Collect_User_Demand;

PROCEDURE Collect_FlowSched_Demand(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert wip flow schedule demand information
    -- haven't added the logic to explode phantom

     CURSOR FLOWSCHED_DEMAND_CURSOR IS
	SELECT
	  1 reservation_type,
	  24 supply_demand_source_type,
	  5 txn_source_type_id,
	  F.WIP_ENTITY_ID supply_demand_source_id,
	  1 supply_demand_type,
	  LEAST(-1*(F.PLANNED_QUANTITY-F.QUANTITY_COMPLETED)*EXTENDED_QUANTITY, 0) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
	FROM  WIP_FLOW_SCHEDULES F,
           BOM_BILL_OF_MATERIALS BOM ,
           BOM_EXPLOSIONS BE ,
           BOM_CALENDAR_DATES C,
           MTL_PARAMETERS P,
           MTL_SYSTEM_ITEMS I,
           MTL_ATP_RULES R,
           MTL_GROUP_ITEM_ATPS_VIEW V
        WHERE V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND V.INVENTORY_ITEM_ID=DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1,
					 V.INVENTORY_ITEM_ID, -1)
	  AND I.ORGANIZATION_ID=V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND BE.COMPONENT_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND BE.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND BE.EXPLOSION_TYPE = 'ALL'
	  AND BE.EXTENDED_QUANTITY > 0
	  AND BE.COMPONENT_ITEM_ID <> BE.TOP_ITEM_ID
	  AND BOM.COMMON_BILL_SEQUENCE_ID = BE.TOP_BILL_SEQUENCE_ID
	  AND BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
	  AND TRUNC(BE.EFFECTIVITY_DATE) <= TRUNC(F.SCHEDULED_COMPLETION_DATE)
	  AND TRUNC(BE.DISABLE_DATE) > TRUNC(F.SCHEDULED_COMPLETION_DATE)
	  AND F.PRIMARY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
	  AND F.ORGANIZATION_ID = BOM.ORGANIZATION_ID
	  AND F.STATUS = 1
	  AND F.SCHEDULED_FLAG = 1
	  AND (F.PLANNED_QUANTITY - F.QUANTITY_COMPLETED) >0
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND NVL(F.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),
									     NVL(F.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND C.CALENDAR_CODE = P.CALENDAR_CODE
	  AND C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
	  AND C.CALENDAR_DATE = TRUNC(F.SCHEDULED_COMPLETION_DATE)
	  AND C.PRIOR_SEQ_NUM >= P_SYS_SEQ_NUM
	  AND C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
					NULL, C.PRIOR_SEQ_NUM,
					P_SYS_SEQ_NUM-R.PAST_DUE_DEMAND_CUTOFF_FENCE)
	  AND C.PRIOR_SEQ_NUM < NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
							    1, I.CUMULATIVE_TOTAL_LEAD_TIME,
							    2, I.CUM_MANUFACTURING_LEAD_TIME,
							    3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
							    4, R.INFINITE_SUPPLY_TIME_FENCE)), C.PRIOR_SEQ_NUM+1)
	    AND NOT EXISTS (SELECT 'exists in group?'
			    FROM MTL_DEMAND_INTERFACE MDI1
			    WHERE MDI1.ATP_GROUP_ID = P_GROUP_ID
			    AND MDI1.ORGANIZATION_ID + 0 = V.ORGANIZATION_ID
			    AND MDI1.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
			    AND NVL(MDI1.SUPPLY_HEADER_ID, -1) = F.WIP_ENTITY_ID);

     l_demand_rec   FLOWSCHED_DEMAND_CURSOR%ROWTYPE;
     j              NUMBER := Nvl(p_demand_table.LAST,0) + 1;
BEGIN

   OPEN FLOWSCHED_DEMAND_CURSOR;

   LOOP
      FETCH FLOWSCHED_DEMAND_CURSOR INTO l_demand_rec;
      EXIT WHEN FLOWSCHED_DEMAND_CURSOR%NOTFOUND;

      p_demand_table(j).reservation_type          := l_demand_rec.reservation_type;
      p_demand_table(j).supply_demand_source_type := l_demand_rec.supply_demand_source_type;
      p_demand_table(j).txn_source_type_id        := l_demand_rec.txn_source_type_id;
      p_demand_table(j).supply_demand_source_id   := l_demand_rec.supply_demand_source_id;
      p_demand_table(j).supply_demand_type        := l_demand_rec.supply_demand_type;
      p_demand_table(j).supply_demand_quantity    := l_demand_rec.supply_demand_quantity;
      p_demand_table(j).supply_demand_date        := l_demand_rec.supply_demand_date;
      p_demand_table(j).inventory_item_id         := l_demand_rec.inventory_item_id;
      p_demand_table(j).organization_id           := l_demand_rec.organization_id;

      j := j+1;

   END LOOP;

   CLOSE FLOWSCHED_DEMAND_CURSOR;

END Collect_FlowSched_Demand;

PROCEDURE Collect_SalesOrder_Demand(p_group_id          IN NUMBER,
				    p_sys_seq_num       IN NUMBER,
				    p_mrp_status        IN NUMBER,
				    p_org_id            IN NUMBER,
				    p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				    ERRBUF              OUT NOCOPY VARCHAR2,
				    RETCODE             OUT NOCOPY NUMBER)
  IS

    -- insert sales order demand
     CURSOR OE_SALESORDER_DEMAND_CURSOR IS
	SELECT D.RESERVATION_TYPE reservation_type,
	  DECODE(D.DEMAND_SOURCE_TYPE,
		 2, DECODE(D.RESERVATION_TYPE,1,2,3,23,9),
		 8, DECODE(D.RESERVATION_TYPE,1,21,22),D.DEMAND_SOURCE_TYPE) supply_demand_source_type,
	  DECODE(D.DEMAND_SOURCE_TYPE,
		 8,2,D.DEMAND_SOURCE_TYPE) txn_source_type_id,
	  D.DEMAND_SOURCE_HEADER_ID supply_demand_source_id,
	  1 supply_demand_type,
	  -1*(D.PRIMARY_UOM_QUANTITY-GREATEST(NVL(D.RESERVATION_QUANTITY,0),D.COMPLETED_QUANTITY)) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  V.INVENTORY_ITEM_ID inventory_item_id,
	  V.ORGANIZATION_ID organization_id
	FROM
	  MTL_GROUP_ITEM_ATPS_VIEW V,
	  MTL_PARAMETERS P,
	  MTL_SYSTEM_ITEMS I,
	  MTL_ATP_RULES R,
	  BOM_CALENDAR_DATES C,
	  MTL_DEMAND D,
	  BOM_CALENDAR_DATES C1
	WHERE D.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),D.COMPLETED_QUANTITY)
	  AND D.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND D.AVAILABLE_TO_ATP = 1
	  AND D.RESERVATION_TYPE <> DECODE(NVL(V.N_COLUMN1,R.INCLUDE_ONHAND_AVAILABLE), 2, 2, -1)
	  AND D.RESERVATION_TYPE <> DECODE(R.DEMAND_CLASS_ATP_FLAG, 1, 2, -1)
	  AND D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS, 2, 2, -1)
	  AND D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS, 2, 8, -1)
	  AND (D.SUBINVENTORY IS NULL
	       OR D.SUBINVENTORY IN (SELECT S.SECONDARY_INVENTORY_NAME
				     FROM MTL_SECONDARY_INVENTORIES S
				     WHERE S.ORGANIZATION_ID=D.ORGANIZATION_ID
				     AND S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES, 1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
				     AND S.AVAILABILITY_TYPE =DECODE(R.DEFAULT_ATP_SOURCES, 2, 1, S.AVAILABILITY_TYPE)))
	  AND V.AVAILABLE_TO_ATP = 1
	  AND V.ATP_RULE_ID = R.RULE_ID
	  AND V.ATP_GROUP_ID = P_GROUP_ID
	  AND I.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND I.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	  AND NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@'))= DECODE(R.DEMAND_CLASS_ATP_FLAG,
									     1,NVL(V.DEMAND_CLASS,NVL(P.DEFAULT_DEMAND_CLASS, '@@@')),NVL(D.DEMAND_CLASS, NVL(P.DEFAULT_DEMAND_CLASS,'@@@')))
	  AND P.ORGANIZATION_ID = V.ORGANIZATION_ID
	  AND C1.SEQ_NUM = greatest(1, P_SYS_SEQ_NUM - Nvl(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
	  AND D.REQUIREMENT_DATE >= C1.CALENDAR_DATE
	  AND D.RESERVATION_TYPE <> 2
	  AND C.PRIOR_SEQ_NUM < DECODE(D.RESERVATION_TYPE,
				       2,C.PRIOR_SEQ_NUM+1,
				       NVL(P_SYS_SEQ_NUM + (DECODE(R.INFINITE_SUPPLY_FENCE_CODE,
								    1, I.CUMULATIVE_TOTAL_LEAD_TIME,
								    2, I.CUM_MANUFACTURING_LEAD_TIME,
								    3, I.PREPROCESSING_LEAD_TIME+I.FULL_LEAD_TIME+I.POSTPROCESSING_LEAD_TIME,
								    4, R.INFINITE_SUPPLY_TIME_FENCE)), C.PRIOR_SEQ_NUM+1))
	    AND NOT EXISTS
	    (SELECT 'exists in group?'
	     FROM MTL_GROUP_ATPS_VIEW V1
	     WHERE V1.ATP_GROUP_ID = P_GROUP_ID
	     AND V1.ORGANIZATION_ID + 0 = V.ORGANIZATION_ID
	     AND V1.INVENTORY_ITEM_ID = V.INVENTORY_ITEM_ID
	     AND V1.AVAILABLE_TO_ATP = 1
	     AND NVL(V1.DEMAND_SOURCE_TYPE, -1) = D.DEMAND_SOURCE_TYPE
	     AND NVL(V1.DEMAND_SOURCE_HEADER_ID, -1) = D.DEMAND_SOURCE_HEADER_ID
	     AND NVL(V1.DEMAND_SOURCE_LINE, '@@@') = NVL(D.DEMAND_SOURCE_LINE, '@@@')
	     AND NVL(V1.DEMAND_SOURCE_DELIVERY, '@@@') = NVL(D.DEMAND_SOURCE_DELIVERY, '@@@')
	     AND NVL(V1.DEMAND_SOURCE_NAME, '@@@') = NVL(D.DEMAND_SOURCE_NAME, '@@@'))
 	     AND P.CALENDAR_CODE = C.CALENDAR_CODE
	     AND P.CALENDAR_EXCEPTION_SET_ID = C.EXCEPTION_SET_ID
	     AND P.CALENDAR_CODE = C1.CALENDAR_CODE
	     AND P.CALENDAR_EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
	     AND C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
	     AND V.INVENTORY_ITEM_ID=DECODE(D.RESERVATION_TYPE,
					    1,DECODE(D.PARENT_DEMAND_ID, NULL,V.INVENTORY_ITEM_ID,-1),
					    2,V.INVENTORY_ITEM_ID,
					    3,DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS,
						     1,V.INVENTORY_ITEM_ID,
						     DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS,
							    1,V.INVENTORY_ITEM_ID, -1)),-1)
	    AND V.INVENTORY_ITEM_ID=
	    DECODE(R.INCLUDE_SALES_ORDERS, 2,
		   DECODE(R.INCLUDE_INTERNAL_ORDERS, 2,
			  DECODE(R.INCLUDE_ONHAND_AVAILABLE, 2,
				 DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 2,
					DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 2, -1,
					       V.INVENTORY_ITEM_ID),
					V.INVENTORY_ITEM_ID),
				 V.INVENTORY_ITEM_ID),
			  V.INVENTORY_ITEM_ID),
		   V.INVENTORY_ITEM_ID);


     CURSOR ONT_SALESORDER_DEMAND_CURSOR IS
	SELECT
	  1  reservation_type, -- fake
	  2 supply_demand_source_type,
	  2  txn_source_type_id, -- fake
	  L.LINE_ID supply_demand_source_id,
	  1 supply_demand_type,
	  -1*(L.ORDERED_QUANTITY-NVL(SHIPPED_QUANTITY, 0)) supply_demand_quantity,
	  TO_NUMBER(TO_CHAR(C.PRIOR_DATE,'J')) supply_demand_date,
	  I.INVENTORY_ITEM_ID inventory_item_id,
	  I.ORGANIZATION_ID organization_id
        FROM    BOM_CALENDAR_DATES C ,
	  OE_ORDER_LINES L,
	  MTL_ATP_RULES R ,
	  MTL_GROUP_ATPS_VIEW G ,
	  MTL_PARAMETERS P ,
	  MTL_SYSTEM_ITEMS I
	WHERE   I.ATP_FLAG in ('C', 'Y')
	  AND   P.ORGANIZATION_ID = I.ORGANIZATION_ID
	  AND   G.ATP_GROUP_ID = p_group_id
	  AND   G.ORGANIZATION_ID = I.ORGANIZATION_ID
	  AND   G.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
	  AND   G.ATP_RULE_ID = R.RULE_ID
	  AND   R.INCLUDE_SALES_ORDERS = 1
	  AND   L.SHIP_FROM_ORG_ID = I.ORGANIZATION_ID
	  AND   L.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
	  AND   L.VISIBLE_DEMAND_FLAG = 'Y'
	  AND   L.ORDERED_QUANTITY > NVL(L.SHIPPED_QUANTITY,0)
	  AND   C.PRIOR_DATE >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
				       NULL, C.PRIOR_DATE,
				       MRP_CALENDAR.DATE_OFFSET(P.ORGANIZATION_ID,
								1,
								SYSDATE,
								-NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0)))
	  AND   C.CALENDAR_CODE = P.CALENDAR_CODE
	  AND   C.EXCEPTION_SET_ID = P.CALENDAR_EXCEPTION_SET_ID
	  AND   C.CALENDAR_DATE = TRUNC(L.SCHEDULE_SHIP_DATE);


     l_oe_demand_rec   OE_SALESORDER_DEMAND_CURSOR%ROWTYPE;
     l_ont_demand_rec  ONT_SALESORDER_DEMAND_CURSOR%ROWTYPE;
     l_oe_install        VARCHAR2(10);
     j                   NUMBER := Nvl(p_demand_table.LAST,0) + 1;
BEGIN

   SELECT OE_INSTALL.Get_Active_Product
     INTO l_oe_install
     FROM DUAL;

   IF l_oe_install = 'OE' THEN
      OPEN OE_SALESORDER_DEMAND_CURSOR;

      LOOP
	 FETCH OE_SALESORDER_DEMAND_CURSOR INTO l_oe_demand_rec;
	 EXIT WHEN OE_SALESORDER_DEMAND_CURSOR%NOTFOUND;

	 p_demand_table(j).reservation_type          := l_oe_demand_rec.reservation_type;
	 p_demand_table(j).supply_demand_source_type := l_oe_demand_rec.supply_demand_source_type;
	 p_demand_table(j).txn_source_type_id        := l_oe_demand_rec.txn_source_type_id;
	 p_demand_table(j).supply_demand_source_id   := l_oe_demand_rec.supply_demand_source_id;
	 p_demand_table(j).supply_demand_type        := l_oe_demand_rec.supply_demand_type;
	 p_demand_table(j).supply_demand_quantity    := l_oe_demand_rec.supply_demand_quantity;
	 p_demand_table(j).supply_demand_date        := l_oe_demand_rec.supply_demand_date;
	 p_demand_table(j).inventory_item_id         := l_oe_demand_rec.inventory_item_id;
	 p_demand_table(j).organization_id           := l_oe_demand_rec.organization_id;

	 j := j+1;

      END LOOP;

      CLOSE OE_SALESORDER_DEMAND_CURSOR;

    ELSE

      -- fix for bug 4270650
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', p_org_id);

      OPEN ONT_SALESORDER_DEMAND_CURSOR;

      LOOP
	 FETCH ONT_SALESORDER_DEMAND_CURSOR INTO l_ont_demand_rec;
	 EXIT WHEN ONT_SALESORDER_DEMAND_CURSOR%NOTFOUND;

	 p_demand_table(j).reservation_type          := l_ont_demand_rec.reservation_type;
	 p_demand_table(j).supply_demand_source_type := l_ont_demand_rec.supply_demand_source_type;
	 p_demand_table(j).txn_source_type_id        := l_ont_demand_rec.txn_source_type_id;
	 p_demand_table(j).supply_demand_source_id   := l_ont_demand_rec.supply_demand_source_id;
	 p_demand_table(j).supply_demand_type        := l_ont_demand_rec.supply_demand_type;
	 p_demand_table(j).supply_demand_quantity    := l_ont_demand_rec.supply_demand_quantity;
	 p_demand_table(j).supply_demand_date        := l_ont_demand_rec.supply_demand_date;
	 p_demand_table(j).inventory_item_id         := l_ont_demand_rec.inventory_item_id;
	 p_demand_table(j).organization_id           := l_ont_demand_rec.organization_id;

	 j := j+1;

       END LOOP;

       CLOSE ONT_SALESORDER_DEMAND_CURSOR;
   END IF;

END Collect_SalesOrder_Demand;


END WPS_SUPPLY_DEMAND;

/
