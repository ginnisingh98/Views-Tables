--------------------------------------------------------
--  DDL for Package Body BOMPEXPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPEXPL" as
/* $Header: BOMEXPLB.pls 120.12.12010000.4 2009/06/10 12:11:18 ajmittal ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPEXPL.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the exploders.
|      This package contains 3 different exploders for the
|      modules it can be called from.  The procedure exploders
|    calls the correct exploder based on the module option.
|    Each of the 3 exploders can be called on directly too.
| Parameters: org_id    organization_id
|   order_by  1 - Op seq, item seq
|       2 - Item seq, op seq
|   grp_id    unique value to identify current explosion
|       use value from sequence bom_explosion_temp_s
|   session_id  unique value to identify current session
|       use value from bom_explosion_temp_session_s
|   levels_to_explode
|   bom_or_eng  1 - BOM
|       2 - ENG
|   impl_flag 1 - implemented only
|       2 - both impl and unimpl
|   explode_option  1 - All
|       2 - Current
|       3 - Current and future
|   module    1 - Costing
|       2 - Bom
|       3 - Order entry
|                               4 - ATO
|                               5 - WSM
|   cst_type_id cost type id for costed explosion
|   std_comp_flag 1 - explode only standard components
|       2 - all components
|   expl_qty  explosion quantity
|   item_id   item id of asembly to explode
|   list_id   unique id for lists in bom_lists for range
|   report_option 1 - cost rollup with report
|       2 - cost rollup no report
|       3 - temp cost rollup with report
|   cst_rlp_id  rollup_id
|   req_id    request id
|   prgm_appl_id  program application id
|   prg_id    program id
|   user_id   user id
|   lock_flag 1 - do not lock the table
|       2 - lock the table
|   alt_rtg_desg  alternate routing designator
|   rollup_option 1 - single level rollup
|       2 - full rollup
|   plan_factor_flag1 - Yes
|       2 - No
|   incl_lt_flag    1 - Yes
|       2 - No
|   alt_desg  alternate bom designator
|   rev_date  explosion date YYYY/MM/DD HH24:MI:SS
|   comp_code concatenated component code lpad 16
|   err_msg   error message out buffer
|   error_code  error code out.  returns sql error code
|       if sql error
| Revision
      Shreyas Shah  creation
  02/10/94  Shreyas Shah  added multi-org capability from bom_lists
        max_bom_levels of all orgs for multi-org
  03/24/94  Shreyas Shah    added 4 to module parameter so that
        if ATO calls it dont commit but if CST
        calls it then commit data
  10/19/95      Robert Yee      Added lead time flags
| 09/05/96      Robert Yee      Increase Sort Order Width to 4 from 3       |
|       (Bills can have >= 1000 components          |
| 09/20/97      Robert Yee      Use depth first search for loop check       |
| 04/15/02  Rahul Chitko  Added a new value for module. Module = 5    |
|                               added for WSM. When the calling application |
|                               is WSM, the process will only explode sub-  |
|                               assemblies that are Phantom.
| 07/14/04  Refai Farook  Modified the depth first logic into breadth first.
|                         Implemented bulk.
| 15-Jun-05  Hari Gelli   Reverted the populating the component code to 11.5.10 style.
+==========================================================================*/

	-- globals for loop checking
	Type StackTabType is table of number index by binary_integer;
	G_Yes constant number := 1;
	G_No constant number := 2;
	G_LoopErrorCode constant number := 9999;
	G_MaxLevelCode constant number := 9998;
	-- G_SortWidth constant number := 7;
	G_SortWidth constant number := Bom_Common_Definitions.G_Bom_SortCode_Width;

	-- Added new parameter which will decide if trimmed dates need to be populated
	-- to the explosions table. If the flag is not set, the effectivity_date and
	-- disable date in Bom-Inventory_components table will only be populated even
	-- when explosion_type is 'ALL'

	G_Allow_Date_Trimming_Flag  Varchar2(1) := 'N';
  G_Module                    Number := 2;


/**************************************************************************************/

  g_parent_sort_order VARCHAR2(2000) := lpad('1', G_SortWidth, '0');
  g_sort_count NUMBER := 0;

	TYPE G_VARCHAR2_TBL_TYPE_2000 IS TABLE OF VARCHAR2(2000)
	INDEX BY BINARY_INTEGER;

	TYPE G_NUMBER_TBL_TYPE IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;

	g_parent_sort_order_tbl 					G_VARCHAR2_TBL_TYPE_2000;
	g_quantity_of_children_tbl				G_NUMBER_TBL_TYPE;
	g_total_qty_at_next_level_tbl			G_NUMBER_TBL_TYPE;

	g_global_count		NUMBER := 1;
	g_total_quantity  NUMBER := 0;


	PROCEDURE Reset_Globals IS
	BEGIN

		/* Reset all the globally used values */

		g_quantity_of_children_tbl.DELETE;
		g_total_qty_at_next_level_tbl.DELETE;
		g_parent_sort_order_tbl.DELETE;
		g_global_count := 1;
		g_total_quantity  := 0;
		g_sort_count := 0;
		g_parent_sort_order := '0000001';

	END;

  FUNCTION Get_Sort_Order (p_parent_sort_order IN VARCHAR2,
  												 p_component_quantity IN NUMBER := NULL)
  RETURN VARCHAR2 IS

  BEGIN

  	IF p_parent_sort_order <> g_parent_sort_order THEN

			g_parent_sort_order_tbl(g_global_count) 			:= g_parent_sort_order;
			g_quantity_of_children_tbl(g_global_count)		:= g_sort_count;
			g_total_qty_at_next_level_tbl(g_global_count) := g_total_quantity;

  		g_sort_count 				:= 0;
			g_total_quantity		:= 0;
  		g_parent_sort_order := p_parent_sort_order;
			g_global_count			:= g_global_count + 1;

  	END IF;

  	g_sort_count 			:= g_sort_count + 1;
  	g_total_quantity	:= g_total_quantity + p_component_quantity;

  	Return (g_parent_sort_order||lpad(to_char(g_sort_count), G_SortWidth, '0'));

  END;

  PROCEDURE bom_exploder(
  verify_flag   IN NUMBER DEFAULT 0,
  online_flag   IN NUMBER DEFAULT 1,
  top_bill_id   IN NUMBER,
  org_id      IN NUMBER,
  order_by    IN NUMBER DEFAULT 1,
  grp_id      IN NUMBER,
  levels_to_explode   IN NUMBER DEFAULT 1,
  bom_or_eng    IN NUMBER DEFAULT 1,
  impl_flag   IN NUMBER DEFAULT 1,
  plan_factor_flag  IN NUMBER DEFAULT 2,
  explode_option    IN NUMBER DEFAULT 2,
  std_comp_flag   IN NUMBER DEFAULT 2,
  incl_oc_flag    IN NUMBER DEFAULT 1,
  max_level   IN NUMBER,
  rev_date    IN DATE DEFAULT sysdate,
  show_rev          IN NUMBER DEFAULT 2,
  material_ctrl     IN NUMBER DEFAULT 2,
  lead_time   IN NUMBER DEFAULT 2,
  unit_number   IN VARCHAR2,
  release_option IN NUMBER DEFAULT 0,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER) IS

    prev_sort_order   VARCHAR2(4000);
    prev_top_bill_id    NUMBER;
    cum_count     NUMBER;
    total_rows      NUMBER;
    cat_sort      VARCHAR2(7);
    impl_eco                    varchar2(20);

    -- verify local vars
    cur_component               VARCHAR2(20);
    cur_substr                  VARCHAR2(20);
    cur_loopstr                 VARCHAR2(4000);
    cur_loopflag                VARCHAR2(1);
    loop_found                  BOOLEAN := false;
    max_level_exceeded    			BOOLEAN := false;
    start_pos                   NUMBER;
    end_pos                     NUMBER;


      CURSOR exploder (
			c_level NUMBER,
			c_grp_id NUMBER,
			c_org_id NUMBER,
			c_bom_or_eng NUMBER,
			c_rev_date date,
			c_impl_flag NUMBER,
			c_explode_option NUMBER,
			c_order_by NUMBER,
			c_verify_flag NUMBER,
			c_plan_factor_flag NUMBER,
			c_std_comp_flag NUMBER,
			c_incl_oc NUMBER ) IS
			SELECT
				BET.TOP_BILL_SEQUENCE_ID TBSI,
				BOM.BILL_SEQUENCE_ID BSI,
				BOM.COMMON_BILL_SEQUENCE_ID CBSI,
				BOM.COMMON_ORGANIZATION_ID COI,
				BOM.ORGANIZATION_ID OI,
				BIC.COMPONENT_SEQUENCE_ID CSI,
				BIC.COMPONENT_ITEM_ID CID,
				BIC.BASIS_TYPE BT,
				BIC.COMPONENT_QUANTITY CQ,
				c_level,
				(BIC.COMPONENT_QUANTITY *
                                DECODE(BIC.BASIS_TYPE, null,BET.EXTENDED_QUANTITY,1) *
				decode(c_plan_factor_flag, 1, BIC.PLANNING_FACTOR/100, 1) /
				decode(BIC.COMPONENT_YIELD_FACTOR, 0, 1,
				BIC.COMPONENT_YIELD_FACTOR)) EQ,
				BET.SORT_ORDER SO,
				c_grp_id,
				BET.TOP_ALTERNATE_DESIGNATOR TAD,
				BIC.COMPONENT_YIELD_FACTOR CYF,
				BET.TOP_ITEM_ID TID,
				BET.COMPONENT_CODE CC,
				BIC.INCLUDE_IN_COST_ROLLUP IICR,
				BET.LOOP_FLAG LF,
				BIC.PLANNING_FACTOR PF,
				BIC.OPERATION_SEQ_NUM OSN,
				BIC.BOM_ITEM_TYPE BIT,
				BET.BOM_ITEM_TYPE PBIT,
				BET.COMPONENT_ITEM_ID PAID,
				BOM.ALTERNATE_BOM_DESIGNATOR,
				BIC.WIP_SUPPLY_TYPE WST,
				BIC.ITEM_NUM ITN,
				DECODE(G_Allow_Date_Trimming_Flag,'N',BIC.EFFECTIVITY_DATE,Greatest(BIC.EFFECTIVITY_DATE,Nvl(BET.EFFECTIVITY_DATE,BIC.EFFECTIVITY_DATE))) ED,
				DECODE(G_Allow_Date_Trimming_Flag,'N',BIC.DISABLE_DATE,Least(Nvl(BIC.DISABLE_DATE,BET.DISABLE_DATE),Nvl(BET.DISABLE_DATE,BIC.DISABLE_DATE))) DD,
				--BIC.EFFECTIVITY_DATE ED,
				--BIC.DISABLE_DATE DD,
				BIC.FROM_END_ITEM_UNIT_NUMBER    FUN,
				BIC.TO_END_ITEM_UNIT_NUMBER	EUN,
				BIC.IMPLEMENTATION_DATE ID,
				BIC.OPTIONAL OPT,
				BIC.SUPPLY_SUBINVENTORY SS,
				BIC.SUPPLY_LOCATOR_ID SLI,
				BIC.COMPONENT_REMARKS CR,
				BIC.CHANGE_NOTICE CN,
				BIC.OPERATION_LEAD_TIME_PERCENT OLTP,
				BIC.MUTUALLY_EXCLUSIVE_OPTIONS MEO,
				BIC.CHECK_ATP CATP,
				BIC.REQUIRED_TO_SHIP RTS,
				BIC.REQUIRED_FOR_REVENUE RFR,
				BIC.INCLUDE_ON_SHIP_DOCS IOSD,
				BIC.LOW_QUANTITY LQ,
				BIC.HIGH_QUANTITY HQ,
				BIC.SO_BASIS SB,
				--BET.OPERATION_OFFSET,
				--BET.CURRENT_REVISION,
				--BET.LOCATOR,
				BIC.ATTRIBUTE_CATEGORY,
				BIC.ATTRIBUTE1,
				BIC.ATTRIBUTE2,
				BIC.ATTRIBUTE3,
				BIC.ATTRIBUTE4,
				BIC.ATTRIBUTE5,
				BIC.ATTRIBUTE6,
				BIC.ATTRIBUTE7,
				BIC.ATTRIBUTE8,
				BIC.ATTRIBUTE9,
				BIC.ATTRIBUTE10,
				BIC.ATTRIBUTE11,
				BIC.ATTRIBUTE12,
				BIC.ATTRIBUTE13,
				BIC.ATTRIBUTE14,
				BIC.ATTRIBUTE15,
				BET.SORT_ORDER PARENT_SORT_ORDER,
				BIC.AUTO_REQUEST_MATERIAL
			FROM    BOM_EXPLOSION_TEMP BET, BOM_BILL_OF_MATERIALS BOM,
		          MTL_SYSTEM_ITEMS_B   SI,
							BOM_INVENTORY_COMPONENTS BIC,
              ENG_REVISED_ITEMS ERI
			WHERE BET.PLAN_LEVEL = c_level - 1
			AND	BET.GROUP_ID = c_grp_id
			AND BET.TOP_BILL_SEQUENCE_ID = top_bill_id
			AND     BOM.ASSEMBLY_ITEM_ID  = SI.INVENTORY_ITEM_ID
			AND     BOM.ORGANIZATION_ID   = SI.ORGANIZATION_ID
			AND     BOM.COMMON_BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
			AND     BET.COMPONENT_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
			AND	BET.ORGANIZATION_ID = BOM.ORGANIZATION_ID  -- Bug 7159394 .. Reverting fix 6707314
			--AND	BOM.ORGANIZATION_ID = decode(BET.COMMON_BILL_SEQUENCE_ID,BET.BILL_SEQUENCE_ID,BET.ORGANIZATION_ID,BET.COMMON_ORGANIZATION_ID)  /* Bug: 6707314 */
			AND	NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
      AND (G_Module <> 5 OR (G_Module = 5 AND (nvl(BET.wip_supply_type, si.wip_supply_type) = 6     /*Added nvl for bug 7700219 (FP of 7638607)*/
                                               OR BET.PLAN_LEVEL = 0
                                              )
                            )
          )
      --Explode only Phantom components when module=5
			AND   ( (c_std_comp_flag = 1 -- only std components
				  AND BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 2
				)
				OR
				(c_std_comp_flag = 2)
				OR
				(c_std_comp_flag = 3 AND nvl(BET.BOM_ITEM_TYPE, 1) IN (1,2)
				   AND (BIC.BOM_ITEM_TYPE IN (1,2)
				         OR
				        (BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 1)
				       )
				)
			      )
			AND	( (c_bom_or_eng = 1 and BOM.ASSEMBLY_TYPE = 1)
				  OR
				  (c_bom_or_eng = 2)
			 	)
			AND	(
				  (BET.TOP_ALTERNATE_DESIGNATOR IS NULL
				    AND
				    BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
				   )
				  OR
				   (BET.TOP_ALTERNATE_DESIGNATOR IS NOT NULL
				    AND
				    BOM.ALTERNATE_BOM_DESIGNATOR=BET.TOP_ALTERNATE_DESIGNATOR
				   )
				  OR
				  ( BET.TOP_ALTERNATE_DESIGNATOR IS NOT NULL
				    AND BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
				    AND NOT EXISTS
					(SELECT 'X'
					 FROM BOM_BILL_OF_MATERIALS BOM2
					 WHERE BOM2.ORGANIZATION_ID = c_org_id
					 AND   BOM2.ASSEMBLY_ITEM_ID = BET.COMPONENT_ITEM_ID
					 AND   BOM2.ALTERNATE_BOM_DESIGNATOR =
						BET.TOP_ALTERNATE_DESIGNATOR
					 AND   ((c_bom_or_eng = 1 and BOM2.ASSEMBLY_TYPE = 1)
						OR c_bom_or_eng = 2
					       )
					) -- subquery
				   )
				) -- end of alt logic
		-- whether to include option classes and models under a standard item
		-- special logic added at CST request
			AND ( (c_incl_oc = 1)
			      or
			      (c_incl_oc = 2 AND
				( BET.BOM_ITEM_TYPE = 4 AND BIC.BOM_ITEM_TYPE = 4)
				OR
				( BET.BOM_ITEM_TYPE <> 4)
			      )
			    )
		-- do not explode if immediate parent is standard and current
		-- component is option class or model - special logic for config items
			AND NOT ( BET.PARENT_BOM_ITEM_TYPE = 4
				    AND
				  BET.BOM_ITEM_TYPE IN (1,2)
			 	)
			AND (
			      ( NVL(SI.EFFECTIVITY_CONTROL,1) = 2
				AND ((c_explode_option = 1)  --  ALL
		                     OR (c_explode_option IN (2,3) AND BIC.DISABLE_DATE IS NULL)
		                    )
		                    /*
				AND unit_number_from <=
		                    NVL(BIC.TO_END_ITEM_UNIT_NUMBER,unit_number_from)
		                AND unit_number_to  >=  BIC.FROM_END_ITEM_UNIT_NUMBER
		                AND BIC.FROM_END_ITEM_UNIT_NUMBER <=
				    NVL(BET.TO_END_ITEM_UNIT_NUMBER,BIC.FROM_END_ITEM_UNIT_NUMBER)
		                AND
				    NVL(BIC.TO_END_ITEM_UNIT_NUMBER,
		                        NVL(BET.FROM_END_ITEM_UNIT_NUMBER,BIC.FROM_END_ITEM_UNIT_NUMBER)) >=
				        NVL(BET.FROM_END_ITEM_UNIT_NUMBER,BIC.FROM_END_ITEM_UNIT_NUMBER)
			        AND
		                  ( (c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
		                   OR
		                   c_impl_flag = 2 )*/

            AND BIC.from_end_item_unit_number IS NOT NULL
            AND ( (c_explode_option = 2
            AND unit_number >= BIC.from_end_item_unit_number
            AND unit_number <= Nvl( BIC.to_end_item_unit_number, unit_number))
            OR
            (c_explode_option = 3
              AND unit_number <= Nvl( BIC.to_end_item_unit_number, unit_number))
            )
            AND ( (c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
            OR c_impl_flag = 2 )
				    )
		            OR
			     (
			         NVL(SI.EFFECTIVITY_CONTROL,1) =1
		               AND
				( --(c_explode_option = 1 ) -- ALL

      (c_explode_option = 1 /* ALL */  /* When option is all, level 0 should pick all comps */
          AND ( (c_level-1 = 0) OR             /* but the subsequent levels should continue to narrow */
          ( bic.effectivity_date <= nvl(bet.disable_date, bic.effectivity_date)
         AND  NVL(bic.disable_date, bet.effectivity_date) >= bet.effectivity_date) ) )
				OR
				  (c_explode_option = 2 AND -- CURRENT
			 	  c_rev_date >=
				  BIC.EFFECTIVITY_DATE AND
		                  c_rev_date <  -- Bug #3138456
				  nvl(BIC.DISABLE_DATE,
					c_rev_date+1)
				   ) -- CURRENT
				  OR
				  (c_explode_option = 3 -- CURRENT AND FUTURE
				   AND nvl(BIC.DISABLE_DATE, c_rev_date + 1) > c_rev_date
		                   /* Modified above line for Bug #3138456 */
				   ) -- CURRENT AND FUTURE
		                 )
			      AND ( (c_impl_flag = 2 AND
				   ( c_explode_option = 1
				    OR
				    (c_explode_option = 2 AND not exists
					(SELECT null
					 FROM BOM_INVENTORY_COMPONENTS CIB,
            ENG_REVISED_ITEMS ERI2
					 WHERE CIB.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
		 			 AND CIB.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
					 AND NVL(CIB.ECO_FOR_PRODUCTION,2) = 2
					 AND ( decode(CIB.IMPLEMENTATION_DATE, NULL,
						CIB.OLD_COMPONENT_SEQUENCE_ID,
						CIB.COMPONENT_SEQUENCE_ID) =
					       decode(BIC.IMPLEMENTATION_DATE, NULL,
						BIC.OLD_COMPONENT_SEQUENCE_ID,
						BIC.COMPONENT_SEQUENCE_ID)
					      OR
					       CIB.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
					     ) -- decode
					 AND CIB.EFFECTIVITY_DATE <=
					     c_rev_date
				         AND BIC.EFFECTIVITY_DATE < cib.EFFECTIVITY_DATE
           AND CIB.REVISED_ITEM_SEQUENCE_ID = ERI2.REVISED_ITEM_SEQUENCE_ID (+)
           AND   ( ( release_option = 1  AND nvl(ERI2.STATUS_TYPE,6) IN (4,6,7) )
                  OR
                   ( release_option = 2 AND nvl(ERI2.STATUS_TYPE,6) IN (1,4,6,7))
                  OR
                   ( release_option = 0 AND nvl(ERI2.STATUS_TYPE,6) = 6 )
                  OR
                   (release_option = 3)
                 )
					) -- end of subquery
				    ) -- CURRENT
				    OR
				    (c_explode_option = 3 AND not exists
					(SELECT null
					 FROM BOM_INVENTORY_COMPONENTS CIB,
             ENG_REVISED_ITEMS ERI2
					 WHERE CIB.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
		 			 AND CIB.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
					 AND NVL(CIB.ECO_FOR_PRODUCTION,2) = 2
					 AND ( decode(CIB.IMPLEMENTATION_DATE, NULL,
						CIB.OLD_COMPONENT_SEQUENCE_ID,
						CIB.COMPONENT_SEQUENCE_ID) =
					       decode(BIC.IMPLEMENTATION_DATE, NULL,
						BIC.OLD_COMPONENT_SEQUENCE_ID,
						BIC.COMPONENT_SEQUENCE_ID)
					      OR
					       CIB.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
					     ) -- decode
					 AND CIB.EFFECTIVITY_DATE <=
					     c_rev_date
				        AND BIC.EFFECTIVITY_DATE < cib.EFFECTIVITY_DATE
           AND CIB.REVISED_ITEM_SEQUENCE_ID = ERI2.REVISED_ITEM_SEQUENCE_ID (+)
           AND   ( ( release_option = 1  AND nvl(ERI2.STATUS_TYPE,6) IN (4,6,7) )
                  OR
                   ( release_option = 2 AND nvl(ERI2.STATUS_TYPE,6) IN (1,4,6,7))
                  OR
                   ( release_option = 0 AND nvl(ERI2.STATUS_TYPE,6) = 6 )
                  OR
                   (release_option = 3)
                 )
					    ) -- end of subquery
				      OR BIC.EFFECTIVITY_DATE >
					c_rev_date
				    ) -- CURRENT AND FUTURE
				  ) -- explode_option
				) -- impl_flag = 2
				  OR
				(c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
			      ) -- explode option
		            )
			)
			AND BET.LOOP_FLAG = 2
      AND   BIC.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID (+)
      AND   (
              ( release_option = 1
                AND nvl(ERI.STATUS_TYPE,6) IN (4,6,7)
              )
              OR
              ( release_option = 2
                AND nvl(ERI.STATUS_TYPE,6) IN (1,4,6,7)
              )
              OR
              (
                release_option = 0
                AND nvl(ERI.STATUS_TYPE,6) = 6
              )
              OR
              (release_option = 3)
            )
		        ORDER BY BET.TOP_BILL_SEQUENCE_ID, BET.SORT_ORDER,
				decode(c_order_by, 1, BIC.OPERATION_SEQ_NUM, BIC.ITEM_NUM),
				decode(c_order_by, 1, BIC.ITEM_NUM, BIC.OPERATION_SEQ_NUM);

  	Cursor Get_Locator (P_Locator in number) is
			Select mil.concatenated_segments
			From mtl_item_locations_kfv mil
			Where mil.inventory_location_id = P_Locator;

		Cursor Get_OLTP (P_Assembly in number,
											P_Alternate in varchar2,
											P_Operation in number) is
			Select round(bos.operation_lead_time_percent, 2) oltp
			From Bom_Operation_Sequences bos,
					 Bom_Operational_Routings bor
			Where bor.assembly_item_id = P_Assembly
			And   bor.organization_Id = org_id
			And  (bor.alternate_routing_designator = P_Alternate
						or
					 (bor.alternate_routing_designator is null AND not exists (
							SELECT null
							FROM bom_operational_routings bor2
							WHERE bor2.assembly_item_id = P_Assembly
							AND   bor2.organization_id = org_id
							AND   bor2.alternate_routing_designator = P_Alternate)
					 ))
			And   bor.common_routing_sequence_id = bos.routing_sequence_id
			And   bos.operation_seq_num = P_Operation
			And   bos.effectivity_date <=
						trunc(rev_date)
			And   nvl(bos.disable_date,
									 rev_date + 1) >=
						trunc(rev_date);

		Cursor Calculate_Offset(P_ParentItem in number, P_Percent in number) is
			Select  P_Percent/100 * msi.full_lead_time offset
			From mtl_system_items_b msi
						Where msi.inventory_item_id = P_ParentItem
			And   msi.organization_id = Org_Id;

		No_Revision_Found exception;
		Pragma exception_init(no_revision_found, -20001);

		Cursor l_TopBill_csr is
						Select msi.concatenated_segments,
						 bom.alternate_bom_designator
			From mtl_system_items_b_kfv msi,
								 bom_bill_of_materials bom,
					 BOM_EXPLOSION_TEMP bet
			Where msi.inventory_item_id = bom.assembly_item_id
			And   msi.organization_id = bom.organization_id
			And   bom.bill_sequence_id = bet.top_bill_sequence_id
			And   bet.group_id = grp_id
			And   rownum = 1;

		total number;

		CURSOR getItemRevDetails (p_revision_id IN NUMBER) IS
		  SELECT revision_id, revision, revision_label FROM mtl_item_revisions_vl WHERE revision_id = p_revision_id;


		CURSOR getItemRevision (p_inventory_item_id IN NUMBER,
														p_organization_id IN NUMBER,
														p_revision_date IN DATE,
														p_impl_flag IN NUMBER) IS
       SELECT revision,revision_label,revision_id
       FROM   mtl_item_revisions_b MIR
       WHERE  mir.inventory_item_id = p_inventory_item_id
       AND    mir.organization_id = p_organization_id
       AND    mir.effectivity_date  <= p_revision_date
       AND (p_impl_flag = 2  OR (p_impl_flag = 1 AND mir.implementation_date IS NOT NULL) )
       ORDER BY mir.effectivity_date DESC;

		l_revision_id 		NUMBER;
		l_revision_label	VARCHAR2(100);
		l_revision				VARCHAR2(10);

		l_comp_common_bill_seq_id NUMBER;

	  /*
	  TYPE be_temp_TYPE IS TABLE OF bom_plm_explosion_temp%ROWTYPE;
	  be_temp_TBL be_temp_TYPE;
	  */

	  l_batch_size NUMBER := 20000;

	  /* Declare pl/sql tables for all coulmns in the select list. BULK BIND and INSERT with
	     pl/sql table of records work fine in 9i releases but not in 8i. So, the only option is
	     to use individual pl/sql table for each column in the cursor select list */


		TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER
		INDEX BY BINARY_INTEGER;

		TYPE DATE_TBL_TYPE IS TABLE OF DATE
		INDEX BY BINARY_INTEGER;

		/* Declared seperate tables based on the column size since pl/sql preallocates the memory for the varchar variable
				when it is lesser than 2000 chars */

		/*
		TYPE VARCHAR2_TBL_TYPE IS TABLE OF VARCHAR2(2000)
		INDEX BY BINARY_INTEGER;
		*/

		TYPE VARCHAR2_TBL_TYPE_1 IS TABLE OF VARCHAR2(1)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_3 IS TABLE OF VARCHAR2(3)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_10 IS TABLE OF VARCHAR2(10)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_20 IS TABLE OF VARCHAR2(20)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_25 IS TABLE OF VARCHAR2(25)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_30 IS TABLE OF VARCHAR2(30)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_40 IS TABLE OF VARCHAR2(40)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_80 IS TABLE OF VARCHAR2(80)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_150 IS TABLE OF VARCHAR2(150)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_240 IS TABLE OF VARCHAR2(240)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_260 IS TABLE OF VARCHAR2(260)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_1000 IS TABLE OF VARCHAR2(1000)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_2000 IS TABLE OF VARCHAR2(2000)
		INDEX BY BINARY_INTEGER;

		TYPE VARCHAR2_TBL_TYPE_4000 IS TABLE OF VARCHAR2(4000)
		INDEX BY BINARY_INTEGER;

		top_bill_sequence_id_tbl                    NUMBER_TBL_TYPE;
		bill_sequence_id_tbl                    		NUMBER_TBL_TYPE;
		common_bill_sequence_id_tbl                 NUMBER_TBL_TYPE;
		common_organization_id_tbl                  NUMBER_TBL_TYPE;
		organization_id_tbl                    			NUMBER_TBL_TYPE;
		component_sequence_id_tbl                   NUMBER_TBL_TYPE;
		component_item_id_tbl                    		NUMBER_TBL_TYPE;
		basis_type_tbl                   		NUMBER_TBL_TYPE;
		component_quantity_tbl                   		NUMBER_TBL_TYPE;
		plan_level_tbl 				                  		NUMBER_TBL_TYPE;
		extended_quantity_tbl                    		NUMBER_TBL_TYPE;
		sort_order_tbl 															VARCHAR2_TBL_TYPE_2000;
		group_id_tbl	 															NUMBER_TBL_TYPE;
		top_alternate_designator_tbl 								VARCHAR2_TBL_TYPE_10;
		component_yield_factor_tbl                  NUMBER_TBL_TYPE;
		top_item_id_tbl               					    NUMBER_TBL_TYPE;
		component_code_tbl 													VARCHAR2_TBL_TYPE_1000;
		include_in_cost_rollup_tbl                  NUMBER_TBL_TYPE;
		loop_flag_tbl              						      NUMBER_TBL_TYPE;
		planning_factor_tbl        			           	NUMBER_TBL_TYPE;
		operation_seq_num_tbl                    		NUMBER_TBL_TYPE;
		bom_item_type_tbl                    				NUMBER_TBL_TYPE;
		parent_bom_item_type_tbl                    NUMBER_TBL_TYPE;
		parent_item_id_tbl                   				NUMBER_TBL_TYPE;
		alternate_bom_designator_tbl 								VARCHAR2_TBL_TYPE_10;
		wip_supply_type_tbl                  			  NUMBER_TBL_TYPE;
		item_num_tbl                    						NUMBER_TBL_TYPE;
		effectivity_date_tbl 												DATE_TBL_TYPE;
		disable_date_tbl 														DATE_TBL_TYPE;
		from_end_item_unit_number_tbl 							VARCHAR2_TBL_TYPE_30;
		to_end_item_unit_number_tbl 								VARCHAR2_TBL_TYPE_30;
		implementation_date_tbl 										DATE_TBL_TYPE;
		optional_tbl                    						NUMBER_TBL_TYPE;
		supply_subinventory_tbl 										VARCHAR2_TBL_TYPE_10;
		supply_locator_id_tbl  		                  NUMBER_TBL_TYPE;
		component_remarks_tbl 											VARCHAR2_TBL_TYPE_240;
		change_notice_tbl													 	VARCHAR2_TBL_TYPE_10;
		operation_leadtime_percent_tbl     	        NUMBER_TBL_TYPE;
		mutually_exclusive_options_tbl              NUMBER_TBL_TYPE;
		check_atp_tbl                    						NUMBER_TBL_TYPE;
		required_to_ship_tbl            		        NUMBER_TBL_TYPE;
		required_for_revenue_tbl                    NUMBER_TBL_TYPE;
		include_on_ship_docs_tbl                    NUMBER_TBL_TYPE;
		low_quantity_tbl                				    NUMBER_TBL_TYPE;
		high_quantity_tbl               				    NUMBER_TBL_TYPE;
		so_basis_tbl                   							NUMBER_TBL_TYPE;
		operation_offset_tbl                    		NUMBER_TBL_TYPE;
		current_revision_tbl 												VARCHAR2_TBL_TYPE_3;
		primary_uom_code_tbl 												VARCHAR2_TBL_TYPE_3;
		locator_tbl 																VARCHAR2_TBL_TYPE_40;
		attribute_category_tbl 											VARCHAR2_TBL_TYPE_30;
		attribute1_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute2_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute3_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute4_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute5_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute6_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute7_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute8_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute9_tbl 															VARCHAR2_TBL_TYPE_150;
		attribute10_tbl 														VARCHAR2_TBL_TYPE_150;
		attribute11_tbl 														VARCHAR2_TBL_TYPE_150;
		attribute12_tbl 														VARCHAR2_TBL_TYPE_150;
		attribute13_tbl 														VARCHAR2_TBL_TYPE_150;
		attribute14_tbl 														VARCHAR2_TBL_TYPE_150;
		attribute15_tbl 														VARCHAR2_TBL_TYPE_150;
		component_item_revision_id_tbl        	    NUMBER_TBL_TYPE;
		parent_sort_order_tbl 											VARCHAR2_TBL_TYPE_2000;
		assembly_type_tbl                    				NUMBER_TBL_TYPE;
		revision_label_tbl 													VARCHAR2_TBL_TYPE_260;
		revision_id_tbl             					      NUMBER_TBL_TYPE;
		bom_implementation_date_tbl 								DATE_TBL_TYPE;
		creation_date_tbl														DATE_TBL_TYPE;
		created_by_tbl															NUMBER_TBL_TYPE;
		last_update_date_tbl												DATE_TBL_TYPE;
		last_updated_by_tbl													NUMBER_TBL_TYPE;
		auto_request_material_tbl 									VARCHAR2_TBL_TYPE_3;


		l_rows_fetched NUMBER := 0;

BEGIN
	Reset_Globals;

	FOR cur_level in 1..levels_to_explode
	LOOP

		--dbms_output.put_line('cur level is '||cur_level);

		total_rows  := 0;
		cum_count := 0;

		OPEN exploder (
		cur_level,
		grp_id,
		org_id,
		bom_or_eng,
		rev_date,
		impl_flag,
		explode_option,
		order_by,
		verify_flag,
		plan_factor_flag,
		std_comp_flag,
		incl_oc_flag
		);

		l_rows_fetched := 0;

		LOOP

			FETCH exploder BULK COLLECT INTO
				top_bill_sequence_id_tbl ,
				bill_sequence_id_tbl,
				common_bill_sequence_id_tbl,
				common_organization_id_tbl,
				organization_id_tbl,
				component_sequence_id_tbl,
				component_item_id_tbl,
				basis_type_tbl,
				component_quantity_tbl,
				plan_level_tbl,
				extended_quantity_tbl,
				sort_order_tbl,
				group_id_tbl,
				top_alternate_designator_tbl,
				component_yield_factor_tbl ,
				top_item_id_tbl,
				component_code_tbl,
				include_in_cost_rollup_tbl ,
				loop_flag_tbl,
				planning_factor_tbl,
				operation_seq_num_tbl,
				bom_item_type_tbl ,
				parent_bom_item_type_tbl,
				parent_item_id_tbl,
				alternate_bom_designator_tbl,
				wip_supply_type_tbl,
				item_num_tbl,
				effectivity_date_tbl,
				disable_date_tbl,
				from_end_item_unit_number_tbl,
				to_end_item_unit_number_tbl ,
				implementation_date_tbl,
				optional_tbl,
				supply_subinventory_tbl,
				supply_locator_id_tbl,
				component_remarks_tbl,
				change_notice_tbl,
				operation_leadtime_percent_tbl  ,
				mutually_exclusive_options_tbl  ,
				check_atp_tbl   ,
				required_to_ship_tbl,
				required_for_revenue_tbl ,
				include_on_ship_docs_tbl ,
				low_quantity_tbl  ,
				high_quantity_tbl ,
				so_basis_tbl      ,
				--operation_offset_tbl ,
				--Current_revision_tbl ,
				--locator_tbl 	,
				attribute_category_tbl 	,
				attribute1_tbl 		,
				attribute2_tbl 		,
				attribute3_tbl 		,
				attribute4_tbl 		,
				attribute5_tbl 		,
				attribute6_tbl 		,
				attribute7_tbl 		,
				attribute8_tbl 		,
				attribute9_tbl 		,
				attribute10_tbl 	,
				attribute11_tbl 	,
				attribute12_tbl 	,
				attribute13_tbl 	,
				attribute14_tbl 	,
				attribute15_tbl,
				parent_sort_order_tbl,
				auto_request_material_tbl		LIMIT l_batch_size;

			EXIT WHEN exploder%ROWCOUNT = l_rows_fetched;
			l_rows_fetched := exploder%ROWCOUNT;

			--dbms_output.put_line('Exploder Row count is '||exploder%ROWCOUNT);

			FOR i IN 1..top_bill_sequence_id_tbl.COUNT
			LOOP

				--dbms_output.put_line('inside expl_rows');

				IF cur_level > levels_to_explode THEN
					IF cur_level > max_level THEN
						max_level_exceeded := true;
					END IF; -- exceed max level
					exit; -- do not insert extra level
				END IF; -- exceed lowest level

				total_rows  := total_rows + 1;

				-- Get the sort order

				--dbms_output.put_line('calling sort order : '||parent_sort_order_tbl(i));
				sort_order_tbl(i)        := Get_Sort_Order(parent_sort_order_tbl(i), component_quantity_tbl(i));

				-- Get the component code

				--dbms_output.put_line('Get the component code');

				loop_found := FALSE;
				cur_loopstr := component_code_tbl(i);

				cur_component := component_item_id_tbl(i);

				-- search the current loop_string for current component

				start_pos := 1;
				FOR i IN 1..cur_level LOOP

					end_pos  := INSTR(cur_loopstr, '-', start_pos,1);
					IF end_pos = 0 THEN
						end_pos := LENGTH(cur_loopstr);
					ELSE
						End_pos := end_pos-1;
					END IF;

					cur_substr := SUBSTR( cur_loopstr, start_pos, (end_pos-start_pos+1));

					IF (cur_component = cur_substr) THEN
						loop_found := TRUE;
						EXIT;
					END IF;
					start_pos := end_pos + 2;
				END LOOP;

				component_code_tbl(i) := component_code_tbl(i) || '-' || cur_component;
				IF loop_found THEN
					loop_flag_tbl(i) := 1;
				ELSE
					loop_flag_tbl(i) := 2;
				END IF;

				--dbms_output.put_line('Get the revision');

				--current_revision_tbl(i) := Null;

				-- The following pieces are valid only IF the component row is an inventory item

				/*
				IF show_rev = 1 THEN

					IF component_item_revision_id_tbl(i) IS NOT NULL THEN

						FOR r1 IN getItemRevDetails(component_item_revision_id_tbl(i))
						LOOP
							revision_id_tbl(i)       := component_item_revision_id_tbl(i);
							current_revision_tbl(i)  := r1.revision;
							revision_label_tbl(i)    := r1.revision_label;
						END LOOP;

					ELSE

						FOR r1 IN getItemRevision(component_item_id_tbl(i),
																			nvl(common_organization_id_tbl(i),organization_id_tbl(i)),
																			rev_date,
																			impl_flag)
						LOOP
							revision_id_tbl(i)        := r1.revision_id;
							current_revision_tbl(i)   := r1.revision;
							revision_label_tbl(i)     := r1.revision_label;
							Exit;
						END LOOP;

					END IF; -- current component revision

				END IF;  -- show rev
				*/

				--dbms_output.put_line('Get the locator');

				locator_tbl(i) := Null;

				IF  material_ctrl = 1 THEN

					IF FND_FLEX_KEYVAL.validate_ccid
						(appl_short_name         =>     'INV',
						key_flex_code           =>      'MTLL',
						structure_number        =>      101,
						combination_id          =>      supply_locator_id_tbl(i),
						displayable             =>      'ALL',
						data_set                =>      organization_id_tbl(i)
						)
					THEN
						locator_tbl(i) := FND_FLEX_KEYVAL.concatenated_values ;
					END IF;

				END IF; -- supply locator

				--dbms_output.put_line('Get the lead time');

				operation_leadtime_percent_tbl(i) := Null;

				FOR X_Operation in Get_OLTP(
					P_Assembly => parent_item_id_tbl(i),
					P_Alternate => alternate_bom_designator_tbl(i),
					P_Operation => operation_seq_num_tbl(i))
				LOOP
					operation_leadtime_percent_tbl(i) := X_Operation.OLTP;
				END LOOP;

				/*
				operation_offset_tbl(i) := Null;

				IF lead_time = 1 THEN
					For X_Item in Calculate_Offset(P_ParentItem => parent_item_id_tbl(i),
						P_Percent => operation_leadtime_percent_tbl(i))
					LOOP
						operation_offset_tbl(i) := X_Item.offset;
					END LOOP;
				END IF; -- operation offset
				*/

			END LOOP;

			-- We are doing this to capture the values for the last parent
			g_parent_sort_order_tbl(g_global_count) 			:= g_parent_sort_order;
			g_quantity_of_children_tbl(g_global_count)		:= g_sort_count;
			g_total_qty_at_next_level_tbl(g_global_count) := g_total_quantity;

			--dbms_output.put_line('O.K. enough. insert now');

			FORALL i IN 1..top_bill_sequence_id_tbl.COUNT
				INSERT INTO bom_explosion_temp
				(
				TOP_BILL_SEQUENCE_ID           ,
				BILL_SEQUENCE_ID               ,
				COMMON_BILL_SEQUENCE_ID        ,
				COMMON_ORGANIZATION_ID         ,
				ORGANIZATION_ID                ,
				COMPONENT_SEQUENCE_ID          ,
				COMPONENT_ITEM_ID              ,
                                BASIS_TYPE	               ,
				COMPONENT_QUANTITY             ,
				PLAN_LEVEL                     ,
				EXTENDED_QUANTITY              ,
				SORT_ORDER                     ,
				GROUP_ID                       ,
				TOP_ALTERNATE_DESIGNATOR       ,
				COMPONENT_YIELD_FACTOR         ,
				TOP_ITEM_ID                    ,
				COMPONENT_CODE                 ,
				INCLUDE_IN_ROLLUP_FLAG         ,
				LOOP_FLAG                      ,
				PLANNING_FACTOR                ,
				OPERATION_SEQ_NUM              ,
				BOM_ITEM_TYPE                  ,
				PARENT_BOM_ITEM_TYPE           ,
				ASSEMBLY_ITEM_ID               ,
				--ALTERNATE_BOM_DESIGNATOR       ,
				WIP_SUPPLY_TYPE                ,
				ITEM_NUM                       ,
				EFFECTIVITY_DATE               ,
				DISABLE_DATE                   ,
				FROM_END_ITEM_UNIT_NUMBER      ,
				TO_END_ITEM_UNIT_NUMBER        ,
				IMPLEMENTATION_DATE            ,
				OPTIONAL                       ,
				SUPPLY_SUBINVENTORY            ,
				SUPPLY_LOCATOR_ID              ,
				COMPONENT_REMARKS              ,
				CHANGE_NOTICE                  ,
				OPERATION_LEAD_TIME_PERCENT    ,
				MUTUALLY_EXCLUSIVE_OPTIONS     ,
				CHECK_ATP                      ,
				REQUIRED_TO_SHIP               ,
				REQUIRED_FOR_REVENUE           ,
				INCLUDE_ON_SHIP_DOCS           ,
				LOW_QUANTITY                   ,
				HIGH_QUANTITY                  ,
				SO_BASIS                       ,
				--OPERATION_OFFSET               ,
				--CURRENT_REVISION               ,
				--LOCATOR                        ,
				CONTEXT                        ,
				ATTRIBUTE1                     ,
				ATTRIBUTE2                     ,
				ATTRIBUTE3                     ,
				ATTRIBUTE4                     ,
				ATTRIBUTE5                     ,
				ATTRIBUTE6                     ,
				ATTRIBUTE7                     ,
				ATTRIBUTE8                     ,
				ATTRIBUTE9                     ,
				ATTRIBUTE10                    ,
				ATTRIBUTE11                    ,
				ATTRIBUTE12                    ,
				ATTRIBUTE13                    ,
				ATTRIBUTE14                    ,
				ATTRIBUTE15                    ,
				--PARENT_SORT_ORDER              ,
				AUTO_REQUEST_MATERIAL )
				VALUES
				(
				top_bill_sequence_id_tbl(i)                    ,
				bill_sequence_id_tbl(i)                    		,
				common_bill_sequence_id_tbl(i)                 ,
				common_organization_id_tbl(i)                  ,
				organization_id_tbl(i)                    			,
				component_sequence_id_tbl(i)                   ,
				component_item_id_tbl(i)                    		,
				basis_type_tbl(i)                   		,
				component_quantity_tbl(i)                   		,
				plan_level_tbl(i)																,
				extended_quantity_tbl(i)                    		,
				sort_order_tbl(i) 															,
				group_id_tbl(i)																		,
				top_alternate_designator_tbl(i) 								,
				component_yield_factor_tbl(i)                  ,
				top_item_id_tbl(i)               					    ,
				component_code_tbl(i) 													,
				include_in_cost_rollup_tbl(i)                  ,
				loop_flag_tbl(i)              						      ,
				planning_factor_tbl(i)        			           	,
				operation_seq_num_tbl(i)                    		,
				bom_item_type_tbl(i)                    				,
				parent_bom_item_type_tbl(i)                    ,
				parent_item_id_tbl(i)                   				,
				--alternate_bom_designator_tbl(i) 								,
				wip_supply_type_tbl(i)                  			  ,
				item_num_tbl(i)                    						,
				effectivity_date_tbl(i) 												,
				disable_date_tbl(i) 														,
				from_end_item_unit_number_tbl(i) 							,
				to_end_item_unit_number_tbl(i) 								,
				implementation_date_tbl(i) 										,
				optional_tbl(i)                    						,
				supply_subinventory_tbl(i) 										,
				supply_locator_id_tbl(i)  		                  ,
				component_remarks_tbl(i) 											,
				change_notice_tbl(i)													 	,
				operation_leadtime_percent_tbl(i)             ,
				mutually_exclusive_options_tbl(i)              ,
				check_atp_tbl(i)                    						,
				required_to_ship_tbl(i)            		        ,
				required_for_revenue_tbl(i)                    ,
				include_on_ship_docs_tbl(i)                    ,
				low_quantity_tbl(i)                				    ,
				high_quantity_tbl(i)               				    ,
				so_basis_tbl(i)                   							,
				--operation_offset_tbl(i)                    		,
				--Current_revision_tbl(i) 												,
				--locator_tbl(i) 																,
				attribute_category_tbl(i) 											,
				attribute1_tbl(i) 															,
				attribute2_tbl(i) 															,
				attribute3_tbl(i) 															,
				attribute4_tbl(i) 															,
				attribute5_tbl(i) 															,
				attribute6_tbl(i) 															,
				attribute7_tbl(i) 															,
				attribute8_tbl(i) 															,
				attribute9_tbl(i) 															,
				attribute10_tbl(i) 														,
				attribute11_tbl(i) 														,
				attribute12_tbl(i) 														,
				attribute13_tbl(i) 														,
				attribute14_tbl(i) 														,
				attribute15_tbl(i) 														,
				--parent_sort_order_tbl(i),
				auto_request_material_tbl(i) );

				--dbms_output.put_line('O.K. insert done. now what?');

		END LOOP;

		CLOSE exploder;

		/* Update the quantity of children for every parent, total quantity for every parent */

		/*
		FORALL i IN 1..g_parent_sort_order_tbl.COUNT
			UPDATE bom_explosion_temp
				SET quantity_of_children = g_quantity_of_children_tbl(i),
					  total_qty_at_next_level = g_total_qty_at_next_level_tbl(i)
				WHERE group_id = grp_id AND sort_order = g_parent_sort_order_tbl(i);
		*/

		--
		-- IF total rows fetched is 0, THEN break the loop here since nothing
		-- more to explode
		--

		IF total_rows = 0 THEN
			exit;
		END IF;

	END LOOP; -- while level


	IF max_level_exceeded THEN

		error_code  := 9998;
		Fnd_Message.Set_Name('BOM', 'BOM_LEVELS_EXCEEDED');

		FOR l_bill_rec in l_TopBill_csr
		LOOP
			Fnd_Message.Set_Token('ENTITY', l_bill_rec.concatenated_segments);
			Fnd_Message.Set_Token('ENTITY1', l_bill_rec.concatenated_segments);
			Fnd_Message.Set_Token('ENTITY2', l_bill_rec.alternate_bom_designator);
		END LOOP;

		err_msg := Fnd_Message.Get_Encoded;
	ELSE
		error_code  := 0;
		err_msg := null;

	END IF;

	EXCEPTION	WHEN OTHERS THEN
		error_code  := SQLCODE;
		Fnd_Msg_Pub.Build_Exc_Msg(
		p_pkg_name => 'BOMPEXPL',
		p_procedure_name => 'BOM_EXPLODER',
		p_error_text => SQLERRM);
		err_msg := Fnd_Message.Get_Encoded;
		ROLLBACK;

END bom_exploder;

procedure exploders(
  verify_flag   IN  NUMBER DEFAULT 0,
  online_flag   IN  NUMBER DEFAULT 0,
  item_id     IN  NUMBER DEFAULT null, -- for forms
  org_id      IN  NUMBER,
  alternate   IN  VARCHAR2 DEFAULT null, -- for forms
  list_id     IN  NUMBER DEFAULT null, -- for reports
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  req_id      IN  NUMBER DEFAULT 0,
  prgm_appl_id    IN  NUMBER DEFAULT -1,
  prgm_id     IN  NUMBER DEFAULT -1,
  l_levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  incl_lt_flag          IN  NUMBER DEFAULT 2,
  l_explode_option  IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  rev_date    IN  VARCHAR2,
  expl_qty    IN  NUMBER DEFAULT 1,
  unit_number IN  VARCHAR2,
  release_option IN NUMBER DEFAULT 0,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER) AS

	max_level     NUMBER;
	levels_to_explode   NUMBER;
	explode_option    NUMBER;
	cost_org_id     NUMBER;
	incl_oc_flag    NUMBER;
	counter     NUMBER;
	l_std_comp_flag   NUMBER;
	l_error_code    NUMBER := 0;
	l_err_msg     VARCHAR2(2000) := null;
	loop_detected   boolean := false;
	l_path      StackTabType;
	l_level     binary_integer := 0;

	-- Bug Fix: 3633030
	-- Description: Performance issue, FTS on table BOM_STRUCTURES_B
	-- Commented as part of bugfix.
	/*cursor l_list_csr is
		Select bl.assembly_item_id,
		bl.alternate_designator,
		bl.conc_flex_string,
		bom.bill_sequence_id,
		bom.common_bill_sequence_id,
		msi.bom_item_type
		From mtl_system_items msi,
		Bom_Bill_Of_Materials bom,
		Bom_Lists bl
		Where bl.sequence_id = list_id
		And bom.assembly_item_id = bl.assembly_item_id
		And bom.organization_id = org_id
		And nvl(bom.alternate_bom_designator, 'PRIMARY ALTERNATE') =
		nvl(bl.alternate_designator, 'PRIMARY ALTERNATE')
		And msi.inventory_item_id = bom.assembly_item_id
		And msi.organization_id = bom.organization_id;*/

	-- Bug Fix: 3633030
	-- Description: Performance issue, FTS on table BOM_STRUCTURES_B
	-- Query modified with UNION ALL avoiding the NVL statement.

		cursor l_list_csr is
		SELECT
			bl.assembly_item_id,
			bl.alternate_designator,
			bl.conc_flex_string,
			bom.bill_sequence_id,
			bom.common_bill_sequence_id,
			bom.common_organization_id,
			msi.bom_item_type
		FROM
			mtl_system_items msi,
			Bom_Bill_Of_Materials bom,
			Bom_Lists bl
		WHERE
			bl.sequence_id = list_id        And
			bom.assembly_item_id = bl.assembly_item_id        And
			bom.organization_id = org_id        And
			bom.alternate_bom_designator = bl.alternate_designator And
			BOM.alternate_bom_designator IS NOT NULL And
			bl.alternate_designator is NOT null And
			msi.inventory_item_id = bom.assembly_item_id        And
			msi.organization_id = bom.organization_id
		UNION ALL
		SELECT
			bl.assembly_item_id,
			bl.alternate_designator,
			bl.conc_flex_string,
			bom.bill_sequence_id,
			bom.common_bill_sequence_id,
			bom.common_organization_id,
			msi.bom_item_type
		FROM
			mtl_system_items msi,
			Bom_Bill_Of_Materials bom,
			Bom_Lists bl
		WHERE
			bl.sequence_id = list_id        And
			bom.assembly_item_id = bl.assembly_item_id        And
			bom.organization_id = org_id        And
			bom.alternate_bom_designator is null And
			bl.alternate_designator is null And
			msi.inventory_item_id = bom.assembly_item_id        And
			msi.organization_id = bom.organization_id;

		cursor l_bill_csr(p_ItemId number, p_OrgId number, p_alternate varchar2) is
		Select bom.bill_sequence_id,
			bom.common_bill_sequence_id,
			bom.common_organization_id,
			msi.bom_item_type,
			msi.item_number
		From mtl_item_flexfields msi,
			bom_bill_of_materials bom
		Where bom.assembly_item_id = p_ItemId
			And bom.organization_id = P_OrgId
			And nvl(alternate_bom_designator, 'PRIMARY ALTERNATE') =
			nvl(p_alternate, 'PRIMARY ALTERNATE')
			And msi.inventory_item_id = bom.assembly_item_id
			And msi.organization_id = bom.organization_id;


    l_LoopFlag number := g_no;
    -- l_SortCode varchar2(4000) := '0000001';
    l_SortCode Bom_Common_Definitions.G_Bom_SortCode_Type := Bom_Common_Definitions.G_Bom_Init_SortCode;
    l_FatalError exception;

BEGIN

	levels_to_explode := l_levels_to_explode;
	explode_option  := l_explode_option;

	/*
	** fetch the max permissible levels for explosion
	** doing a max since if no row exist to prevent no_Data_found exception
	** from being raised
	*/

	SELECT max(MAXIMUM_BOM_LEVEL)
	INTO max_level
	FROM BOM_PARAMETERS
	WHERE (org_id = -1
	or
	(org_id <> -1 and ORGANIZATION_ID = org_id)
	);

	/* Since sort width is increased to 7 and the sort_order column is only 2000
	wide, we must reduce maximum levels to 59 */

	IF nvl(max_level, 60) > 59 THEN
		max_level := 59; -- 60 levels including level 0
	END IF;

	/*
	** if levels to explode > max levels or < 0, set it to max_level
	*/
	IF (levels_to_explode < 0) OR (levels_to_explode > max_level) THEN
		levels_to_explode := max_level;
	END IF;

	/*
	** if levels_to_explode > 1, then explode_option = CURRENT is the
	** only valid option
	** 05/20/93 removed this condition to make it generic.  Also the verify
	** needs current+future indented explosion.

	IF levels_to_explode > 1 THEN
		explode_option  := 2;
	END IF;
	*/

	IF (module = 1 or module = 2 or module = 4 or module = 5) THEN /* cst, bom, ato*/
		l_std_comp_flag := 2;   /* ALL */
	ELSE
		l_std_comp_flag := std_comp_flag;
	END IF;

	IF (module = 1 or module = 4 ) THEN    /* CST or ATO */
		incl_oc_flag := 2;
	ELSE
		incl_oc_flag := 1;
	END IF;

	--dbms_output.put_line ('incl_oc_flag' ||incl_oc_flag);

	If online_flag = g_yes THEN

		For l_bill_rec in l_bill_csr( p_ItemId => item_id, p_OrgId => org_id,	p_alternate => alternate)
		loop

				l_err_msg := null;
				l_error_code := 0;


				insert into bom_explosion_temp(
				group_id,
				bill_sequence_id,
				common_bill_sequence_id,
				component_sequence_id,
				organization_id,
  			      common_organization_id,
				top_item_id,
				component_item_id,
				plan_level,
				extended_quantity,
                                basis_type,
				component_quantity,
				sort_order,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				top_bill_sequence_id,
				component_code,
				loop_flag,
				top_alternate_designator,
				bom_item_type,
				parent_bom_item_type,
				auto_request_material
				)
				values(
				grp_id,
				l_bill_rec.bill_sequence_id,
				l_bill_rec.common_bill_sequence_id,
				NULL,
				org_id,
				l_bill_rec.common_organization_id,
				item_id,
				item_id,
				0,
				expl_qty,
				NULL,
				1,
				lpad('1', G_SortWidth, '0'),
				req_id,
				prgm_appl_id,
				prgm_id,
				sysdate,
				l_bill_rec.bill_sequence_id,
				item_id,
				--to_char(item_id),
				--l_LoopFlag,
				g_no,
				alternate,
				l_bill_rec.bom_item_type,
				l_bill_rec.bom_item_type,
				'Y'
				);

				bom_exploder(
				verify_flag => verify_flag,
				online_flag => online_flag,
				top_bill_id => l_bill_rec.bill_sequence_id,
				org_id => org_id,
				order_by => order_by,
				grp_id => grp_id,
				levels_to_explode => levels_to_explode,
				bom_or_eng => bom_or_eng,
				impl_flag => impl_flag,
				std_comp_flag => l_std_comp_flag,
				plan_factor_flag => plan_factor_flag,
				explode_option => explode_option,
				incl_oc_flag => incl_oc_flag,
				max_level => max_level,
				rev_date => to_date(rev_date, 'YYYY/MM/DD HH24:MI:SS'),
				show_rev => g_no,
				material_ctrl => g_no,
				lead_time => incl_lt_flag,
        unit_number => unit_number,
        release_option => release_option,
				err_msg => l_err_msg,
				error_code => l_error_code
				);

				If l_error_code < 0 or l_error_code = G_MaxLevelCode THEN
					Raise l_FatalError;
				End if;

				/*
				If verify_flag = g_yes THEN
					If loop_detected THEN
						l_err_msg := l_bill_rec.item_number || l_err_msg;
					End if;
				Else
					If loop_detected THEN
						l_LoopFlag := g_yes;
					Else
						l_LoopFlag := g_no;
					End if;
				End if; -- verify flag
				*/

			End loop; -- from form

		Else -- report

		For l_list_rec in l_list_csr
		loop

				insert into bom_explosion_temp(
				group_id,
				bill_sequence_id,
				common_bill_sequence_id,
				component_sequence_id,
				organization_id,
  			      common_organization_id,
				top_item_id,
				component_item_id,
				plan_level,
				extended_quantity,
                                basis_type,
				component_quantity,
				sort_order,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				top_bill_sequence_id,
				component_code,
				loop_flag,
				top_alternate_designator,
				bom_item_type,
				parent_bom_item_type,
				auto_request_material
				)
				values(
				grp_id,
				l_list_rec.bill_sequence_id,
				l_list_rec.common_bill_sequence_id,
				NULL,
				org_id,
				l_list_rec.common_organization_id,
				l_list_rec.assembly_item_id,
				l_list_rec.assembly_item_id,
				0,
				expl_qty,
                                1,
				1,
				lpad('1', G_SortWidth, '0'),
				req_id,
				prgm_appl_id,
				prgm_id,
				sysdate,
				l_list_rec.bill_sequence_id,
				l_list_rec.assembly_item_id,
				--l_LoopFlag,
				g_no,
				l_list_rec.alternate_designator,
				l_list_rec.bom_item_type,
				l_list_rec.bom_item_type,
				'Y'
				);


				bom_exploder(
				verify_flag => verify_flag,
				online_flag => online_flag,
				top_bill_id => l_list_rec.bill_sequence_id,
				org_id => org_id,
				order_by => order_by,
				grp_id => grp_id,
				levels_to_explode => levels_to_explode,
				bom_or_eng => bom_or_eng,
				impl_flag => impl_flag,
				std_comp_flag => l_std_comp_flag,
				plan_factor_flag => plan_factor_flag,
				explode_option => explode_option,
				incl_oc_flag => incl_oc_flag,
				max_level => max_level,
				rev_date => to_date(rev_date, 'YYYY/MM/DD HH24:MI:SS'),
				show_rev => g_no,
				material_ctrl => g_no,
				lead_time => incl_lt_flag,
                                unit_number => unit_number,
				release_option =>release_option,     /*bug 8299615 Passed Released Option Variable earlier not passing anything*/
				err_msg => l_err_msg,
				error_code => l_error_code
				);

				If l_error_code < 0 or l_error_code = G_MaxLevelCode THEN
					Raise l_FatalError;
				End if;

				IF module = 1 THEN    -- intermittent commits for CST
					commit;
				END IF;

		End loop; -- from list

	End If; -- online_flag

	error_code  := l_error_code;
	err_msg := l_err_msg;

	EXCEPTION
	When l_FatalError THEN
		error_code  := l_error_code;
		err_msg   := l_err_msg;
	WHEN OTHERS THEN
		error_code  := sqlcode;
		err_msg   := 'BOMPEXPL[exploders] '||sqlerrm;
END exploders;

procedure exploder_userexit (
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  item_id     IN  NUMBER,
  alt_desg    IN  VARCHAR2 DEFAULT '',
  comp_code               IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  unit_number IN  VARCHAR2 DEFAULT '',
  release_option IN NUMBER DEFAULT 0,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER) AS

	out_code      NUMBER;
	cost_org_id     NUMBER;
	stmt_num      NUMBER := 1;
	out_message     VARCHAR2(240);
	expl_date     VARCHAR2(25);
	parameter_error   EXCEPTION;
	bom_exploder_error          EXCEPTION;

BEGIN

	--DBMS_PROFILER.Start_Profiler(session_id);

	IF (verify_flag = 1) AND (module <> 2) THEN
		raise parameter_error;
	END IF;

	IF (grp_id is null or item_id is null) THEN
		raise parameter_error;
	END IF;

	expl_date := substr(rev_date, 1, 16);
  G_Module := module;

	IF (expl_date is null) THEN
		select to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
		into expl_date
		from dual;
	ELSE
		-- we will  make sure that the canonical and the nls_date formats are supported.
		BEGIN
			select  fnd_date.date_to_canonical(fnd_date.displayDT_to_date(rev_date))
			into expl_date
			from dual;
			EXCEPTION	WHEN OTHERS THEN
				BEGIN
					 select to_char(to_date(rev_date, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS')
					 into expl_date
					 from dual;
				END;
		END;
	END IF;

	G_Allow_Date_Trimming_Flag  := 'Y';

	exploders(
	verify_flag   =>  verify_flag,
	online_flag   =>  g_yes,
	item_id     =>  item_id, -- for forms
	org_id      =>  org_id,
	alternate   =>  alt_desg, -- for forms
	list_id     =>  null, -- for reports
	order_by    =>  order_by,
	grp_id      =>  grp_id,
	session_id    =>  session_id,
	req_id      =>  0,
	prgm_appl_id    =>  -1,
	prgm_id     =>  -1,
	l_levels_to_explode   =>  levels_to_explode,
	bom_or_eng    =>  bom_or_eng,
	impl_flag   =>  impl_flag,
	plan_factor_flag  =>  plan_factor_flag,
	incl_lt_flag          =>  g_no,
	l_explode_option  =>  explode_option,
	module      =>  module,
	cst_type_id   =>  cst_type_id,
	std_comp_flag   =>  std_comp_flag,
	rev_date    =>  expl_date,
	expl_qty    =>  expl_qty,
  unit_number => unit_number,
  release_option => release_option,
	err_msg     =>  out_message,
	error_code    =>  out_code);

	IF verify_flag <> 1 THEN
		IF out_code <> 0 THEN
			raise bom_exploder_error;
		END IF;
	ELSIF verify_flag = 1 THEN
		IF out_code not in (9999, 0) THEN
			raise bom_exploder_error;
		END IF;
	END IF;

	IF (module = 1 or module = 4) THEN  /* CST or ATO */
		BOMPCEXP.cst_exploder(
		grp_id => grp_id,
		org_id => org_id,
		cst_type_id => cst_type_id,
		err_msg => out_message,
		error_code => out_code);
	END IF;

	error_code  := out_code;
	err_msg := out_message;

	--DBMS_PROFILER.Stop_Profiler;

	EXCEPTION
	WHEN bom_exploder_error THEN
		error_code  := out_code;
		err_msg   := out_message;
	WHEN parameter_error THEN
		error_code  := 9997;
		err_msg   := 'BOMPEXPL: verify parameters';
	WHEN no_data_found THEN
		error_code := SQLCODE;
		err_msg := 'BOMPEXPL: ' || substrb(SQLERRM,1,60);
	WHEN OTHERS THEN
		error_code  := SQLCODE;
		err_msg   := 'BOMPEXPL (' || stmt_num ||'): ' ||substrb(SQLERRM,1,60);

END exploder_userexit;

PROCEDURE explosion_report(
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  list_id     IN  NUMBER,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  incl_lt_flag          IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  report_option   IN  NUMBER DEFAULT 0,
  req_id      IN  NUMBER DEFAULT 0,
  cst_rlp_id    IN  NUMBER DEFAULT 0,
  lock_flag   IN  NUMBER DEFAULT 2,
  rollup_option   IN  NUMBER DEFAULT 2,
  alt_rtg_desg    IN  VARCHAR2 DEFAULT '',
  alt_desg    IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER) AS

  rollup_error    EXCEPTION;
  explode_error   EXCEPTION;
  parameter_error   EXCEPTION;
  prgm_appl_id    NUMBER;
  prg_id      NUMBER;
  user_id     NUMBER;
  cost_org_id   NUMBER;
  out_code    NUMBER;
  rollup_status   NUMBER;
  num_of_assys    NUMBER;
  unimpl_flag   NUMBER;
  stmt_num    NUMBER;
  out_message   VARCHAR2(80);
  expl_date   VARCHAR2(25);
  rollup_date   VARCHAR2(25);
  leaves_found    boolean := true;

  CURSOR loop_flag_rows ( c_group_id NUMBER )
  IS
    SELECT SORT_ORDER
    FROM BOM_EXPLOSION_TEMP
    WHERE
        LOOP_FLAG = 1
    AND GROUP_ID = c_group_id;


BEGIN

	IF (verify_flag = 1) AND (module <> 2) THEN
		raise parameter_error;
	END IF;

	IF (grp_id is null) THEN
		raise parameter_error;
	END IF;

	expl_date := substr(rev_date, 1, 16);
  G_Module := module;

	stmt_num := 0;

	IF (expl_date is null) THEN
		select to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
		into expl_date
		from dual;
	ELSE
		-- we will make sure that the canonical and the nls_date formats are supported.
		-- Bug 4740913. Removed fnd_date.charDT_to_date as both fnd_date.charDT_to_date
		-- and fnd_date.displayDT_to_date do the same operation.
		BEGIN
			select  fnd_date.date_to_canonical(fnd_date.displayDT_to_date(rev_date))
			into expl_date
			from dual;
			EXCEPTION WHEN OTHERS THEN
				BEGIN
					select to_char(to_date(rev_date, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS')
					into expl_date
					from dual;
				END;
		END;
	END IF;

	IF (module = 1 or module = 4) THEN /* CST */

		stmt_num := 3;

		INSERT INTO BOM_EXPLOSION_TEMP
		(
		GROUP_ID,
		BILL_SEQUENCE_ID,
		COMPONENT_SEQUENCE_ID,
		ORGANIZATION_ID,
		COMPONENT_ITEM_ID,
		PLAN_LEVEL,
		EXTENDED_QUANTITY,
                BASIS_TYPE,
		COMPONENT_QUANTITY,
		SORT_ORDER,
		PROGRAM_UPDATE_DATE,
		TOP_BILL_SEQUENCE_ID,
		TOP_ITEM_ID,
		TOP_ALTERNATE_DESIGNATOR,
		COMPONENT_CODE,
		LOOP_FLAG
		)
		SELECT grp_id,
		0,
		NULL,
		nvl(BL.ORGANIZATION_ID, org_id),
		BL.ASSEMBLY_ITEM_ID,
		0,
		expl_qty,
                1,
		1,
		lpad('1', G_SortWidth, '0'),
		sysdate,
		0,
		BL.ASSEMBLY_ITEM_ID,
		NULL,
		to_char(BL.ASSEMBLY_ITEM_ID),
		2
		FROM BOM_LISTS BL
		WHERE BL.SEQUENCE_ID = list_id
		AND   BL.ALTERNATE_DESIGNATOR IS NULL
		AND   NOT EXISTS (SELECT 'NO BILL' FROM BOM_BILL_OF_MATERIALS BOM
		WHERE BOM.ORGANIZATION_ID =
		nvl(BL.ORGANIZATION_ID, org_id)
		AND   BOM.ASSEMBLY_ITEM_ID = BL.ASSEMBLY_ITEM_ID
		AND   BOM.ALTERNATE_BOM_DESIGNATOR IS NULL);

		IF SQL%NOTFOUND and num_of_assys = 0 THEN
			raise no_data_found;
		END IF;

	END IF;

	/*
	** get the conc who values
	*/
	IF (req_id <> 0) THEN
		stmt_num := 4;
		SELECT PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
		REQUESTED_BY
		INTO prgm_appl_id, prg_id, user_id
		FROM FND_CONCURRENT_REQUESTS
		WHERE REQUEST_ID = req_id;
	ELSE
		prgm_appl_id  := 1;
		prg_id    := 1;
		user_id   := 1;
	END IF;

	/*
	** call the exploder
	*/

	G_Allow_Date_Trimming_Flag  := 'N';

	exploders(
	verify_flag   =>  verify_flag,
	online_flag   =>  g_no,
	item_id     =>  null, -- for forms
	org_id      =>  org_id,
	alternate   =>  null, -- for forms
	list_id     =>  list_id, -- for reports
	order_by    =>  order_by,
	grp_id      =>  grp_id,
	session_id    =>  session_id,
	req_id      =>  req_id,
	prgm_appl_id    =>  prgm_appl_id,
	prgm_id     =>  prg_id,
	l_levels_to_explode   =>  levels_to_explode,
	bom_or_eng    =>  bom_or_eng,
	impl_flag   =>  impl_flag,
	plan_factor_flag  =>  plan_factor_flag,
	incl_lt_flag          =>  incl_lt_flag,
	l_explode_option  =>  explode_option,
	module      =>  module,
	cst_type_id   =>  cst_type_id,
	std_comp_flag   =>  std_comp_flag,
	rev_date    =>  expl_date,
	expl_qty    =>  expl_qty,
        unit_number => '',
	release_option =>2,            /*bug 8299615 Passed Released Option variable earlier not passing anything*/
	err_msg     =>  out_message,
	error_code    =>  out_code);

  --bug:5362238 For Loop Report, propage loop flag up the hierarchy.
  IF ( verify_flag = 1 ) THEN
    FOR l_loop_flag_row_rec IN loop_flag_rows( grp_id )
    LOOP
      UPDATE  BOM_EXPLOSION_TEMP bet_update
      SET bet_update.LOOP_FLAG = 1
      WHERE bet_update.SORT_ORDER IN
                ( SELECT  bet.SORT_ORDER
                  FROM BOM_EXPLOSION_TEMP bet
                  WHERE
                    bet.GROUP_ID = grp_id
                  CONNECT BY PRIOR
                    SubStr( bet.SORT_ORDER, 1, (bet.PLAN_LEVEL * 7) ) = bet.SORT_ORDER
                  START WITH bet.SORT_ORDER = l_loop_flag_row_rec.sort_order )
      AND bet_update.GROUP_ID = grp_id;
    END LOOP;
  END IF; -- end if ( :P_VERIFY_FLAG = 1 )


	IF  verify_flag <> 1   THEN
		IF out_code <> 0 THEN
			raise explode_error;
		END IF;
	ELSE
		IF out_code not in (0, 9999) THEN
			raise explode_error;
		END IF;
	END IF;

	/*
	** for a costed explosion, if temp or permanent rollup
	** need to do rollup related stuff.  But only if not frozen std cst type
	*/

	IF ((module = 1 or module = 4)and (report_option = 1 or report_option = 3 or
			report_option = 2)) THEN

		/*
		** commit here else may run out of rollback segments
		*/
		IF (module = 1) THEN
			commit;
		END IF;


		/*
		** insert low level codes from the explosion that was
		** just performed
		*/
		stmt_num := 5;

		INSERT INTO CST_LOW_LEVEL_CODES
		(ROLLUP_ID, INVENTORY_ITEM_ID, LOW_LEVEL_CODE,
		LAST_UPDATE_DATE, LAST_UPDATED_BY,
		CREATION_DATE, CREATED_BY)

		SELECT cst_rlp_id, COMPONENT_ITEM_ID, max(PLAN_LEVEL),
		sysdate, user_id, sysdate, user_id
		FROM BOM_EXPLOSION_TEMP
		WHERE GROUP_ID = grp_id
		GROUP BY COMPONENT_ITEM_ID;

		/*
		** if single level rollup, delete items that do not exist in bom_lists
		*/

		IF (rollup_option = 1) THEN
			stmt_num := 6;

			DELETE CST_LOW_LEVEL_CODES CLLC
			WHERE NOT EXISTS (SELECT 'Item in list'
			FROM BOM_LISTS BL
			WHERE SEQUENCE_ID = list_id
			AND   BL.ASSEMBLY_ITEM_ID = CLLC.INVENTORY_ITEM_ID)
			AND ROLLUP_ID = cst_rlp_id;

		END IF;

		rollup_date := to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS');

		/*
		** call the cost rollup here
		*/

		IF (impl_flag = 1) THEN
			unimpl_flag := 2;
		ELSE
			unimpl_flag := 1;
		END IF;
/*
		rollup_status := CSTPUCRU.cstflcru(
		l_group_id => grp_id,
		l_organization_id => org_id,
		l_rollup_id => cst_rlp_id,
		l_cost_type_id => cst_type_id,
		req_id => req_id,
		prgm_appl_id => prgm_appl_id,
		prgm_id => prg_id,
		l_last_updated_by => user_id,
		conc_flag => 1,
		unimp_flag => unimpl_flag,
		locking_flag => lock_flag,
		rollup_date => rollup_date,
		revision_date => expl_date,
		alt_bom_designator => alt_desg,
		alt_rtg_designator => alt_rtg_desg,
		rollup_option => rollup_option,
		report_option => report_option,
		l_mfg_flag => bom_or_eng,
		err_buf => out_message);

		IF (rollup_status <> 0) THEN
			raise rollup_error;
		END IF;
*/
--commented for bug 5322048.
		/*
		** delete low level codes
		*/
/*		delete from cst_low_level_codes
		where rollup_id = cst_rlp_id;
*/
	END IF;

	/*
	** do the post explosion updates for costing attributes only if no
	** report is selected

	*/
	IF ((module = 1 or module = 4) and report_option <> 2) THEN
		BOMPCEXP.cst_exploder(
		grp_id => grp_id,
		org_id => org_id,
		cst_type_id => cst_type_id,
		err_msg => out_message,
		error_code => out_code);
	END IF;

    error_code  := out_code;
    err_msg := out_message;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		error_code  := SQLCODE;
		err_msg   := 'BOMPEXPL(' || stmt_num || '): ' ||
		substrb(SQLERRM, 1, 60);
/*	WHEN rollup_error THEN
		error_code  := rollup_status;
		err_msg   := out_message;*/
	WHEN explode_error THEN
		error_code  := out_code;
		err_msg   := out_message;
	WHEN parameter_error THEN
		error_code  := 9997;
		err_msg   := 'BOMPEXPL: verify parameters';
	WHEN OTHERS THEN
		error_code  := SQLCODE;
		err_msg   := 'BOMPEXPL(' || stmt_num ||  '): ' ||
		substrb(SQLERRM, 1, 60);
END explosion_report;

/* new procedure for PDI usage.
This exploder will populate trimmed dates in the explosion table
*/
procedure explode(
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 1,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  item_id     IN  NUMBER,
  alt_desg    IN  VARCHAR2 DEFAULT '',
  comp_code               IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  unit_number IN  VARCHAR2 DEFAULT '',
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER) AS

Begin

	G_Allow_Date_Trimming_Flag   := 'Y';

	exploder_userexit (
		verify_flag   ,
		org_id      ,
		order_by    ,
		grp_id      ,
		session_id    ,
		levels_to_explode   ,
		bom_or_eng    ,
		impl_flag   ,
		plan_factor_flag  ,
		explode_option    ,
		module      ,
		cst_type_id   ,
		std_comp_flag   ,
		expl_qty    ,
		item_id     ,
		alt_desg    ,
		comp_code   ,
		rev_date    ,
    unit_number ,
    0, --release_option
		err_msg     ,
		error_code  ) ;
	end;

END bompexpl;

/
