--------------------------------------------------------
--  DDL for Package Body BOMPBXIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPBXIN" AS
-- $Header: BOMBXINB.pls 120.5.12010000.6 2010/02/22 11:03:15 agoginen ship $
-- =========================================================================+
--  Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
--                         All rights reserved.                             |
-- =========================================================================+
--                                                                          |
-- File Name    : BOMBXINB.pls                                              |
-- Description  : This is the bom exploder.                                 |
-- Parameters:  org_id          organization_id                             |
--              order_by        1 - Op seq, item seq                        |
--                              2 - Item seq, op seq                        |
--              grp_id          unique value to identify current explosion  |
--                              use value from seq bom_small_expl_temp_s    |
--              levels_to_explode                                           |
--              bom_or_eng      1 - BOM                                     |
--                              2 - ENG                                     |
--              impl_flag       1 - implemented only                        |
--                              2 - both impl and unimpl                    |
--              explode_option  1 - All                                     |
--                              2 - Current                                 |
--                              3 - Current and future                      |
--		incl_oc_flag	1 - include OC and M under standard item    |
--				2 - do not include                          |
--              show_rev        1 - obtain current revision of component    |
--				2 - don't obtain current revision           |
--		material_ctrl   1 - obtain subinventory locator             |
--				2 - don't obtain subinventory locator       |
--		lead_time	1 - calculate offset percent                |
--				2 - don't calculate offset percent          |
--              max_level       max bom levels permissible for org          |
--              rev_date        explosion date                              |
--              err_msg         error message out buffer                    |
--              error_code      error code out.  returns sql error code     |
--                              if sql error, 9999 if loop detected.        |
-- Revision                                                                 |
--		Shreyas Shah	Creation                                    |
-- 02/10/94	Shreyas Shah	added common_bill_Seq_id to cursor          |
--				added multi-org explosion                   |
-- 08/03/95	Rob Yee		added parameters for 10SC                   |
-- 11/20/97	Rob Yee		check max level one level farther	    |
--                                                                          |
-- =========================================================================

PROCEDURE bom_exploder(
	verify_flag		IN NUMBER DEFAULT 0,
	online_flag		IN NUMBER DEFAULT 1,
	org_id 			IN NUMBER,
	order_by 		IN NUMBER DEFAULT 1,
	grp_id			IN NUMBER,
	levels_to_explode 	IN NUMBER DEFAULT 1,
	bom_or_eng		IN NUMBER DEFAULT 1,
	impl_flag		IN NUMBER DEFAULT 1,
	plan_factor_flag	IN NUMBER DEFAULT 2,
	explode_option 		IN NUMBER DEFAULT 2,
	std_comp_flag		IN NUMBER DEFAULT 2,
	incl_oc_flag		IN NUMBER DEFAULT 1,
	max_level		IN NUMBER,
	unit_number_from 	IN VARCHAR2,
	unit_number_to 		IN VARCHAR2,
	rev_date		IN DATE DEFAULT sysdate,
        show_rev        	IN NUMBER DEFAULT 2,
 	material_ctrl   	IN NUMBER DEFAULT 2,
 	lead_time		IN NUMBER DEFAULT 2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

    -- prev_sort_order		VARCHAR2(4000);
    prev_sort_order		Bom_Common_Definitions.G_Bom_SortCode_Type;
    prev_top_bill_id		NUMBER;
    cum_count			NUMBER;
    total_rows			NUMBER;
    cat_sort			VARCHAR2(7);
    impl_eco                    varchar2(20);

    -- verify local vars
    cur_component               VARCHAR2(16);
    cur_substr                  VARCHAR2(16);
    cur_loopstr                 VARCHAR2(1000);
    cur_loopflag                VARCHAR2(1);
    loop_found                  BOOLEAN := false;
    max_level_exceeded		BOOLEAN := false;
    start_pos                   NUMBER;
   -- Added Flex field values ATTRIBUTE1-ATTRIBUTE15 in the SELECT clause
   -- #1409015
   --- Bulk Collect Functioanlity Addition Bug 6039025 Start

   TYPE number_tab_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE varchar_tab_tp IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

   TYPE DateTabType IS TABLE OF DATE INDEX BY BINARY_INTEGER;

--- Added for Bug:9355186
   bulk_limit NUMBER := 10000; -- Limit for bulk collect

		p_oltp						number_tab_tp;
		l_TBSI						number_tab_tp;
		l_BSI						number_tab_tp;
		l_CBSI						number_tab_tp;
		l_CID						number_tab_tp;
		l_CSI						number_tab_tp;
		l_BT							number_tab_tp;
		l_CQ							number_tab_tp;
		l_EQ							number_tab_tp;
		l_SO							varchar_tab_tp;
		l_TID						number_tab_tp;
		l_TAD						varchar_tab_tp;
		l_CYF						number_tab_tp;
		l_OI							number_tab_tp;
		l_CC							varchar_tab_tp;
		l_IICR						number_tab_tp;
		l_LF							number_tab_tp;
		l_PF							number_tab_tp;
		l_OSN						number_tab_tp;
		l_BIT							number_tab_tp;
		l_PBIT						number_tab_tp;
		l_PAID						number_tab_tp;
		l_WST						number_tab_tp;
		l_ITN						number_tab_tp;
		l_ED							DateTabType;
		l_DD							DateTabType;
		l_ID							DateTabType;
		l_FUN						varchar_tab_tp;
		l_EUN						varchar_tab_tp;
		l_OPT						number_tab_tp;
		l_SS							varchar_tab_tp;
		l_SLI							number_tab_tp;
		l_CR							varchar_tab_tp;
		l_CN							varchar_tab_tp;
		l_OLTP						number_tab_tp;
		l_MEO						number_tab_tp;
		l_CATP						number_tab_tp;
		l_RTS						number_tab_tp;
		l_RFR						number_tab_tp;
		l_IOSD						number_tab_tp;
		l_LQ							number_tab_tp;
		l_HQ							number_tab_tp;
		l_SB							number_tab_tp;
		l_OPERATION_OFFSET			number_tab_tp;
 		l_CURRENT_REVISION			varchar_tab_tp;
 		l_LOCATOR					varchar_tab_tp;
		/*Bug 6350231 Changed the datatype of l_locator from
			number_tab_tp to varchar_tab_tp */
		l_ALTERNATE_BOM_DESIGNATOR	varchar_tab_tp;
		l_ATTRIBUTE_CATEGORY			varchar_tab_tp;
		l_ATTRIBUTE1					varchar_tab_tp;
		l_ATTRIBUTE2					varchar_tab_tp;
		l_ATTRIBUTE3					varchar_tab_tp;
		l_ATTRIBUTE4					varchar_tab_tp;
		l_ATTRIBUTE5					varchar_tab_tp;
		l_ATTRIBUTE6					varchar_tab_tp;
		l_ATTRIBUTE7					varchar_tab_tp;
		l_ATTRIBUTE8					varchar_tab_tp;
		l_ATTRIBUTE9					varchar_tab_tp;
		l_ATTRIBUTE10					varchar_tab_tp;
		l_ATTRIBUTE11					varchar_tab_tp;
		l_ATTRIBUTE12					varchar_tab_tp;
		l_ATTRIBUTE13					varchar_tab_tp;
		l_ATTRIBUTE14					varchar_tab_tp;
		l_ATTRIBUTE15 				varchar_tab_tp;

	loop_count_val        Number := 0;

---   BulK Collect Functionality addition Bug 6039025 Stop

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
	c_incl_oc NUMBER
    ) IS
	SELECT
		BET.TOP_BILL_SEQUENCE_ID TBSI,
		BOM.BILL_SEQUENCE_ID BSI,
		BOM.COMMON_BILL_SEQUENCE_ID CBSI,
		BIC.COMPONENT_ITEM_ID CID,
		BIC.COMPONENT_SEQUENCE_ID CSI,
                BIC.BASIS_TYPE BT,
		BIC.COMPONENT_QUANTITY CQ,
		(BIC.COMPONENT_QUANTITY *
                    decode(BIC.BASIS_TYPE , null,BET.EXTENDED_QUANTITY,1) *
		    decode(c_plan_factor_flag, 1, BIC.PLANNING_FACTOR/100, 1) /
			decode(BIC.COMPONENT_YIELD_FACTOR, 0, 1,
				BIC.COMPONENT_YIELD_FACTOR)) EQ,
		BET.SORT_ORDER SO,
		BET.TOP_ITEM_ID TID,
		BET.TOP_ALTERNATE_DESIGNATOR TAD,
		BIC.COMPONENT_YIELD_FACTOR CYF,
		BOM.ORGANIZATION_ID OI,
		BET.COMPONENT_CODE CC,
		BIC.INCLUDE_IN_COST_ROLLUP IICR,
		BET.LOOP_FLAG LF,
		BIC.PLANNING_FACTOR PF, BIC.OPERATION_SEQ_NUM OSN,
		BIC.BOM_ITEM_TYPE BIT, BET.BOM_ITEM_TYPE PBIT,
		BET.COMPONENT_ITEM_ID PAID, BIC.WIP_SUPPLY_TYPE WST,
		BIC.ITEM_NUM ITN,
		BIC.EFFECTIVITY_DATE ED,
      		BIC.DISABLE_DATE DD,
      		BIC.IMPLEMENTATION_DATE ID,
		BIC.FROM_END_ITEM_UNIT_NUMBER    FUN,
		BIC.TO_END_ITEM_UNIT_NUMBER	EUN,
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
 		BET.OPERATION_OFFSET,
  		BET.CURRENT_REVISION,
  		BET.LOCATOR,
                BOM.ALTERNATE_BOM_DESIGNATOR, -- for routing
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
                BIC.ATTRIBUTE15
	FROM    BOM_SMALL_EXPL_TEMP BET, BOM_BILL_OF_MATERIALS BOM,
                MTL_SYSTEM_ITEMS   SI,
		BOM_INVENTORY_COMPONENTS BIC
	WHERE   BET.PLAN_LEVEL = c_level - 1
	AND	BET.GROUP_ID = c_grp_id
        AND     BOM.ASSEMBLY_ITEM_ID  = SI.INVENTORY_ITEM_ID
        AND     BOM.ORGANIZATION_ID   = SI.ORGANIZATION_ID
	AND     BOM.COMMON_BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
	AND     BET.COMPONENT_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
	AND	BOM.ORGANIZATION_ID = c_org_id
	AND	NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
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
                   c_impl_flag = 2 )
		)
            OR
	     (
	         NVL(SI.EFFECTIVITY_CONTROL,1) =1
       AND ( (c_explode_option = 1
               AND (c_level = 1
                     or
                     ( bic.effectivity_date <= nvl(bet.disable_date, bic.effectivity_date )
                       and nvl(bic.disable_date,bet.effectivity_date ) >= bet.effectivity_date
                     )
                   )  -- c_level Bug 4721383
           ) -- ALL
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
			 FROM BOM_INVENTORY_COMPONENTS CIB
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
			) -- end of subquery
		    ) -- CURRENT
		    OR
		    (c_explode_option = 3 AND not exists
			(SELECT null
			 FROM BOM_INVENTORY_COMPONENTS CIB
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
               (bor.alternate_routing_designator is null and not exists (
                  select null
                  from bom_operational_routings bor2
                  where bor2.assembly_item_id = P_Assembly
                  and   bor2.organization_id = org_id
                  and   bor2.alternate_routing_designator = P_Alternate)
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
	  From mtl_system_items msi
          Where msi.inventory_item_id = P_ParentItem
	  And   msi.organization_id = Org_Id;

	No_Revision_Found exception;
	Pragma exception_init(no_revision_found, -20001);

	Cursor l_TopBill_csr is
          Select msi.concatenated_segments,
	         bom.alternate_bom_designator
	  From mtl_system_items_kfv msi,
               bom_bill_of_materials bom,
	       bom_small_expl_temp bet
	  Where msi.inventory_item_id = bom.assembly_item_id
	  And   msi.organization_id = bom.organization_id
	  And   bom.bill_sequence_id = bet.top_bill_sequence_id
	  And   bet.group_id = grp_id
	  And   rownum = 1;
BEGIN


    -- Added savepoint for bug 3863319
    SAVEPOINT	bom_exploder_pvt;

    -- Added +1. Do not remove +1. This creates regression to the public API
    -- BOMPXINQ.EXPORT_BOM. The API should throw error BOM_LEVELS_EXCEEDED when the
    -- bill has more number of levels than the maximum number of levels allowed for
    -- a bill in that organization. Removing +1, the error will never be thrown.

    for cur_level in 1..levels_to_explode+1 loop /*+1 Commented +1 for bug 6975225*/

	total_rows	:= 0;
	cum_count	:= 0;



--- Bulk Collect Functionality Bug 6039025 Start

-- Delete Pl/Sql Table

		l_TBSI.delete;
		l_BSI.delete;
		l_CBSI.delete;
		l_CID.delete;
		l_CSI.delete;
		l_BT.delete;
		l_CQ.delete;
		l_EQ.delete;
		l_SO.delete;
		l_TID.delete;
		l_TAD.delete;
		l_CYF.delete;
		l_OI.delete;
		l_CC.delete;
		l_IICR.delete;
		l_LF.delete;
		l_PF.delete;
		l_OSN.delete;
		l_BIT.delete;
		l_PBIT.delete;
		l_PAID.delete;
		l_WST.delete;
		l_ITN.delete;
		l_ED.delete;
		l_DD.delete;
		l_ID.delete;
		l_FUN.delete;
		l_EUN.delete;
		l_OPT.delete;
		l_SS.delete;
		l_SLI.delete;
		l_CR.delete;
		l_CN.delete;
		l_OLTP.delete;
		l_MEO.delete;
		l_CATP.delete;
		l_RTS.delete;
		l_RFR.delete;
		l_IOSD.delete;
		l_LQ.delete;
		l_HQ.delete;
		l_SB.delete;
		l_OPERATION_OFFSET.delete;
 		l_CURRENT_REVISION.delete;
 		l_LOCATOR.delete;
		l_ALTERNATE_BOM_DESIGNATOR.delete;
		l_ATTRIBUTE_CATEGORY.delete;
		l_ATTRIBUTE1.delete;
		l_ATTRIBUTE2.delete;
		l_ATTRIBUTE3.delete;
		l_ATTRIBUTE4.delete;
		l_ATTRIBUTE5.delete;
		l_ATTRIBUTE6.delete;
		l_ATTRIBUTE7.delete;
		l_ATTRIBUTE8.delete;
		l_ATTRIBUTE9.delete;
		l_ATTRIBUTE10.delete;
		l_ATTRIBUTE11.delete;
		l_ATTRIBUTE12.delete;
		l_ATTRIBUTE13.delete;
		l_ATTRIBUTE14.delete;
		l_ATTRIBUTE15.delete;

	If not exploder%isopen then
          OPEN exploder(
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
	End If;
	LOOP -- Added for bug 9355186. Bulk fetch should be limited
	 FETCH exploder BULK COLLECT into
		l_TBSI,
		l_BSI,
		l_CBSI,
		l_CID,
		l_CSI,
		l_BT,
		l_CQ,
		l_EQ,
		l_SO,
		l_TID,
		l_TAD,
		l_CYF,
		l_OI,
		l_CC,
		l_IICR,
		l_LF,
		l_PF,
		l_OSN,
		l_BIT,
		l_PBIT,
		l_PAID,
		l_WST,
		l_ITN,
		l_ED,
		l_DD,
		l_ID,
		l_FUN,
		l_EUN,
		l_OPT,
		l_SS,
		l_SLI,
		l_CR,
		l_CN,
		l_OLTP,
		l_MEO,
		l_CATP,
		l_RTS,
		l_RFR,
		l_IOSD,
		l_LQ,
		l_HQ,
		l_SB,
		l_OPERATION_OFFSET,
 		l_CURRENT_REVISION,
 		l_LOCATOR,
		l_ALTERNATE_BOM_DESIGNATOR,
		l_ATTRIBUTE_CATEGORY,
		l_ATTRIBUTE1,
		l_ATTRIBUTE2,
		l_ATTRIBUTE3,
		l_ATTRIBUTE4,
		l_ATTRIBUTE5,
		l_ATTRIBUTE6,
		l_ATTRIBUTE7,
		l_ATTRIBUTE8,
		l_ATTRIBUTE9,
		l_ATTRIBUTE10,
		l_ATTRIBUTE11,
		l_ATTRIBUTE12,
		l_ATTRIBUTE13,
		l_ATTRIBUTE14,
		l_ATTRIBUTE15 LIMIT bulk_limit;-- Bug 9355186: Bulk fetch should be limited
	  EXIT WHEN l_BSI.count=0 ;

	loop_count_val   := exploder%rowcount;

	-- Cursor should be closed after fetching all rows
	-- Commented in bug:9355186
	--  CLOSE exploder;


         FOR i IN 1..loop_count_val loop
/*
	for expl_row in exploder (
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
	) loop
*/


            if cur_level > levels_to_explode then
              if cur_level > max_level then
    	        max_level_exceeded := true;
              end if; -- exceed max level
              exit; -- do not insert extra level
            end if; -- exceed lowest level

	    total_rows	:= total_rows + 1;
--
-- for very first iteration of the loop, set prevbillid = bill_id
--
            if (cum_count = 0) then
		prev_top_bill_id := l_TBSI(i);
		prev_sort_order := l_SO(i);
	    end if;
--
-- whenever a diff assy at a particular level is being exploded, reset
-- the cum_count so that the sort code always starts from 001 for each
-- assembly
--
            if ( prev_top_bill_id <> l_TBSI(i) or
		(prev_top_bill_id = l_TBSI(i) and
		   prev_sort_order <> l_SO(i))) then
		cum_count	:= 0;
		prev_top_bill_id := l_TBSI(i);
		prev_sort_order := l_SO(i);
	    end if;

	    cum_count		:= cum_count + 1;
--
-- lpad cat_sort with 0s upto 7 characters
--
	    cat_sort := lpad(to_char(cum_count), G_SortWidth, '0');


	    l_SO(i)	:= l_SO(i) || cat_sort;

            -- SQL has been modified to carry the loopstr and loopflag
            loop_found := FALSE;
            cur_loopstr := l_CC(i);
            cur_component := LPAD( TO_CHAR( l_CID(i) ), 16, '0' );

            -- search the current loop_string for current component
            FOR i IN 1..max_level LOOP
              start_pos := 1+( (i-1) * 16 );
              cur_substr := SUBSTR( cur_loopstr, start_pos, 16 );
              if (cur_component = cur_substr) then
                loop_found := TRUE;
                EXIT;
              end if;
            END LOOP;

            -- deal with the search results
            l_CC(i) :=
            l_CC(i) || cur_component;
            if loop_found then
              l_LF(i) := 1;
            else
              l_LF(i) := 2;
            end if;
/* Commented for bug 9355186
	    l_Current_Revision(i) := Null;
	    If show_rev = 1 then
            Begin
	      ***Added as fix for 1036465 *******
              if impl_flag = 1 then
                     impl_eco := 'IMPL_ONLY';
              else
                     impl_eco := 'ALL';
              end if;
	      *************************************
              Bom_Revisions.Get_Revision(
	        type => 'PART',
        	eco_status => 'ALL',
        	-- examine_type => 'IMPL_ONLY',
        	examine_type => impl_eco,
        	org_id => l_OI(i),
        	item_id => l_CID(i),
        	rev_date => rev_date,
        	itm_rev => l_Current_Revision(i));
            Exception
              When no_revision_found then
                  null;
            End; -- nested block
	    End if; -- current component revision
*/
	    l_Locator(i) := Null;

	    If material_ctrl = 1 then
             	IF FND_FLEX_KEYVAL.validate_ccid
               		(appl_short_name         =>      'INV',
               		key_flex_code           =>      'MTLL',
               	 	structure_number        =>      101,
                	combination_id          =>      l_SLI(i),
                	displayable             =>      'ALL',
                	data_set                =>      l_OI(i)
               		 )
             	THEN
                     /*Bug 8859324: replaced  l_Locator(i) := FND_FLEX_KEYVAL.concatenated_values ;
                     with the following line of code*/
               	     l_Locator(i) := substr(FND_FLEX_KEYVAL.concatenated_values, 1, 40) ;
             	End if;
	      	/* Commented after bug fix 1252837. New code added above
	      	For X_Location in Get_Locator(expl_row.SLI) loop
	 		Expl_Row.Locator := X_Location.Concatenated_Segments;
	      	End loop;
	      	*/
	    End if; -- supply locator

	     l_OLTP(i) := Null;
            For X_Operation in Get_OLTP(
            P_Assembly => l_PAID(i),
            P_Alternate => l_alternate_bom_designator(i),
            P_Operation => l_OSN(i)) loop
              l_OLTP(i) := X_Operation.OLTP;
            End loop;

	    l_Operation_Offset(i) := Null;
	    If lead_time = 1 then
	      For X_Item in Calculate_Offset(P_ParentItem => l_PAID(i),
              P_Percent => l_OLTP(i)) loop
	        l_Operation_Offset(i) := X_Item.offset;
              End loop;
	    End if; -- operation offset
    -- Inserting the Flex field values ATTRIBUTE1-ATTRIBUTE15 also in the
    -- BOM_SMALL_EXPL_TEMP table #1409015.

            end loop;    -- cursor fetch loop

	-- Added to fix bug 9355186
	If cur_level > levels_to_explode then
		exit;
	End if;

	FORALL i IN 1..loop_count_val

	    INSERT INTO BOM_SMALL_EXPL_TEMP (
		TOP_BILL_SEQUENCE_ID,
		BILL_SEQUENCE_ID,
		COMMON_BILL_SEQUENCE_ID,
		ORGANIZATION_ID,
		COMPONENT_SEQUENCE_ID,
		COMPONENT_ITEM_ID,
                BASIS_TYPE,
		COMPONENT_QUANTITY,
		PLAN_LEVEL,
		EXTENDED_QUANTITY,
		SORT_ORDER,
		GROUP_ID,
		TOP_ALTERNATE_DESIGNATOR,
		COMPONENT_YIELD_FACTOR,
		TOP_ITEM_ID,
		COMPONENT_CODE,
		INCLUDE_IN_ROLLUP_FLAG,
		LOOP_FLAG,
		PLANNING_FACTOR,
		OPERATION_SEQ_NUM,
		BOM_ITEM_TYPE,
		PARENT_BOM_ITEM_TYPE,
		ASSEMBLY_ITEM_ID,
		WIP_SUPPLY_TYPE,
		ITEM_NUM,
		EFFECTIVITY_DATE,
      		DISABLE_DATE,
		FROM_END_ITEM_UNIT_NUMBER,
		TO_END_ITEM_UNIT_NUMBER,
      		IMPLEMENTATION_DATE,
      		OPTIONAL,
      		SUPPLY_SUBINVENTORY,
      		SUPPLY_LOCATOR_ID,
      		COMPONENT_REMARKS,
      		CHANGE_NOTICE,
      		OPERATION_LEAD_TIME_PERCENT,
      		MUTUALLY_EXCLUSIVE_OPTIONS,
      		CHECK_ATP,
      		REQUIRED_TO_SHIP,
      		REQUIRED_FOR_REVENUE,
      		INCLUDE_ON_SHIP_DOCS,
      		LOW_QUANTITY,
      		HIGH_QUANTITY,
		SO_BASIS,
		OPERATION_OFFSET,
 		CURRENT_REVISION,
 		LOCATOR,
		CONTEXT,
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
                ATTRIBUTE15
	    ) VALUES (
		l_TBSI(i),
		l_BSI(i),
		l_CBSI(i),
		l_OI(i),
		l_CSI(i),
		l_CID(i),
                l_BT(i),
	l_CQ(i),
		cur_level,
		l_EQ(i),
		l_SO(i),
		grp_id,
		l_TAD(i),
		l_CYF(i),
		l_TID(i),
		l_CC(i),
		l_IICR(i),
		l_LF(i),
		l_PF(i),
		l_OSN(i),
		l_BIT(i),
		l_PBIT(i),
		l_PAID(i),
		l_WST(i),
		l_ITN(i),
		l_ED(i),
		l_DD(i),
		l_FUN(i),
		l_EUN(i),
		l_ID(i),
		l_OPT(i),
		l_SS(i),
		l_SLI(i),
		l_CR(i),
		l_CN(i),
		l_OLTP(i),
		l_MEO(i),
		l_CATP(i),
		l_RTS(i),
		l_RFR(i),
		l_IOSD(i),
		l_LQ(i),
		l_HQ(i),
		l_SB(i),
		l_OPERATION_OFFSET(i),
 		l_CURRENT_REVISION(i),
 		l_LOCATOR(i),
		l_ATTRIBUTE_CATEGORY(i),
                l_ATTRIBUTE1(i),
                l_ATTRIBUTE2(i),
                l_ATTRIBUTE3(i),
                l_ATTRIBUTE4(i),
                l_ATTRIBUTE5(i),
                l_ATTRIBUTE6(i),
                l_ATTRIBUTE7(i),
                l_ATTRIBUTE8(i),
                l_ATTRIBUTE9(i),
                l_ATTRIBUTE10(i),
                l_ATTRIBUTE11(i),
                l_ATTRIBUTE12(i),
                l_ATTRIBUTE13(i),
                l_ATTRIBUTE14(i),
                l_ATTRIBUTE15(i)
	    );
	END LOOP; -- bulk collect loop
	  CLOSE exploder;
--
-- if total rows fetched is 0, then break the loop here since nothing
-- more to explode
--

	if total_rows = 0 then
	   exit;
	end if;


    END LOOP; -- while level

    if max_level_exceeded then
      error_code  := 9998;
      Fnd_Message.Set_Name('BOM', 'BOM_LEVELS_EXCEEDED');
      For l_bill_rec in l_TopBill_csr loop
        Fnd_Message.Set_Token('ENTITY', l_bill_rec.concatenated_segments);
        Fnd_Message.Set_Token('ENTITY1', l_bill_rec.concatenated_segments);
        Fnd_Message.Set_Token('ENTITY2', l_bill_rec.alternate_bom_designator);
      End loop;
      err_msg := Fnd_Message.Get_Encoded;
    else
      error_code  := 0;
      err_msg := null;
    end if;

/* Bug: 9355186
   Moved the revision specific code outside the loop for performance issues */
    If show_rev = 1 then
      update BOM_SMALL_EXPL_TEMP BSET
      set CURRENT_REVISION =
	(select MAX(MIR.revision)
	      FROM   MTL_ITEM_REVISIONS_B MIR
	      where INVENTORY_ITEM_ID = BSET.COMPONENT_ITEM_ID
	      AND ORGANIZATION_ID = BSET.ORGANIZATION_ID
	      AND MIR.EFFECTIVITY_DATE  <= rev_date
	      AND (impl_flag <> 1 OR (impl_flag = 1 AND IMPLEMENTATION_DATE IS NOT NULL))
	)
	where GROUP_ID=grp_id;
      End if; -- current component revision

EXCEPTION
    WHEN OTHERS THEN
	error_code	:= SQLCODE;
	Fnd_Msg_Pub.Build_Exc_Msg(
	  p_pkg_name => 'BOMPBXIN',
          p_procedure_name => 'BOM_EXPLODER',
          p_error_text => SQLERRM);
	err_msg	:= Fnd_Message.Get_Encoded;
	ROLLBACK TO bom_exploder_pvt; -- bug 3863319
END bom_exploder;

END BOMPBXIN;

/
