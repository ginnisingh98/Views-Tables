--------------------------------------------------------
--  DDL for Package Body BOM_OE_EXPLODER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OE_EXPLODER_PKG" as
/* $Header: BOMORXPB.pls 120.9.12010000.6 2012/12/13 12:18:26 ntungare ship $ */

/*==========================================================================+
|   Copyright (c) 1996 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOEXPB.pls                                               |
| DESCRIPTION  : This file is the body for a packaged procedure for the
|		 custom bom exploder for use by Order Entry. It creates
|		 a time independent 'OPTIONAL' or 'INCLUDED' or 'ALL' bom
|                for the given item in the BOM_EXPLOSIONS table.
|
| Parameters:	arg_org_id	organization_id
|		arg_starting_rev_date
|		arg_expl_type	'OPTIONAL' or 'INCLUDED' or 'ALL'
|		arg_order_by	1 - Op seq, item seq
|				2 - Item seq, op seq
|		arg_levels_to_explode
|		arg_item_id		item id of asembly to explode
|		arg_user_id		user id
|		arg_comp_code	concatenated component code (not used)
|		arg_err_msg		error message out buffer
|		arg_error_code	error code out.  returns sql error code
|				if sql error, 9999 if loop detected.
| Revision
|   13-SEP-95	Raj Jain	Creation
|   26-SEP-95   Raj Jain	Split .sql into spec and body files
|   04-JAN-96   Rob Yee         Include 'ALL' explosion type for zoom to
|                               Configurator from Bill form
|   22-MAR-96   Rob Yee         Filter strictly negative quantities
|   02-JAN-97   Rob Yee         Correct Loop Check
|   03-MAR-03	Sangeetha Mani	Added bulk insert and bulk fetch improvement
|                               for better performance. Rows are fetched in
|                               batches of 1000.
|   15-Sep-03   Rahul Chitko	Modified the for inserting and selecting
|                               data for all parents at a given level.
|                               This will reduce the overall number of selects
|                               Added procedure Generate_Sort_Order which will
|                               help in generating the sort_order for every batch
|                               of 1000 rows.
|  15-Sep-03	Rahul Chitko	Deletes are moved into an Autonomous block.
|                                                                           |
+==========================================================================*/

/* Package Globals */
/* Type and Table definition that can be reused in the package without having to pass them around */

-- Bug 2822347

     TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

     TYPE date_tab_tp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_1 IS TABLE OF VARCHAR2(1)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_3 IS TABLE OF VARCHAR2(3)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_10 IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_20 IS TABLE OF VARCHAR2(20)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_25 IS TABLE OF VARCHAR2(25)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_30 IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_150 IS TABLE OF VARCHAR2(150)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_2000 IS TABLE OF VARCHAR2(2000)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_1000 IS TABLE OF VARCHAR2(1000)
       INDEX BY BINARY_INTEGER;

     OB_TOP_BILL_SEQUENCE_ID  	number_tab_tp;
     OB_BILL_SEQUENCE_ID	number_tab_tp;
     OB_ORGANIZATION_ID		number_tab_tp;
     OB_EXPLOSION_TYPE		varchar_tab_20;
     OB_COMPONENT_SEQUENCE_ID	number_tab_tp;
     OB_COMPONENT_ITEM_ID	number_tab_tp;
     OB_PLAN_LEVEL		number_tab_tp;
     OB_EXTENDED_QUANTITY	number_tab_tp;
     OB_SORT_ORDER		varchar_tab_2000;
     OB_CREATION_DATE		date_tab_tp;
     OB_CREATED_BY		number_tab_tp;
     OB_LAST_UPDATE_DATE	date_tab_tp;
     OB_LAST_UPDATED_BY		number_tab_tp;
     OB_TOP_ITEM_ID		number_tab_tp;
     OB_ATTRIBUTE1		varchar_tab_150;
     OB_ATTRIBUTE2		varchar_tab_150;
     OB_ATTRIBUTE3		varchar_tab_150;
     OB_ATTRIBUTE4		varchar_tab_150;
     OB_ATTRIBUTE5		varchar_tab_150;
     OB_ATTRIBUTE6		varchar_tab_150;
     OB_ATTRIBUTE7		varchar_tab_150;
     OB_ATTRIBUTE8		varchar_tab_150;
     OB_ATTRIBUTE9		varchar_tab_150;
     OB_ATTRIBUTE10		varchar_tab_150;
     OB_ATTRIBUTE11		varchar_tab_150;
     OB_ATTRIBUTE12		varchar_tab_150;
     OB_ATTRIBUTE13		varchar_tab_150;
     OB_ATTRIBUTE14		varchar_tab_150;
     OB_ATTRIBUTE15		varchar_tab_150;
     OB_BASIS_TYPE		number_tab_tp;
     OB_COMPONENT_QUANTITY	number_tab_tp;
     OB_SO_BASIS		number_tab_tp;
     OB_OPTIONAL		number_tab_tp;
     OB_MUTUALLY_EXCLUSIVE_OPTIONS	number_tab_tp;
     OB_CHECK_ATP		number_tab_tp;
     OB_SHIPPING_ALLOWED	number_tab_tp;
     OB_REQUIRED_TO_SHIP	number_tab_tp;
     OB_REQUIRED_FOR_REVENUE	number_tab_tp;
     OB_INCLUDE_ON_SHIP_DOCS	number_tab_tp;
     OB_INCLUDE_ON_BILL_DOCS	number_tab_tp;
     OB_LOW_QUANTITY		number_tab_tp;
     OB_HIGH_QUANTITY		number_tab_tp;
     OB_PICK_COMPONENTS		number_tab_tp;
     OB_PRIMARY_UOM_CODE	varchar_tab_3;
     OB_PRIMARY_UNIT_OF_MEASURE varchar_tab_25;
     OB_BASE_ITEM_ID		number_tab_tp;
     OB_ATP_COMPONENTS_FLAG	varchar_tab_1;
     OB_ATP_FLAG		varchar_tab_1;
     OB_BOM_ITEM_TYPE		number_tab_tp;
     OB_PICK_COMPONENTS_FLAG	varchar_tab_1;
     OB_REPLENISH_TO_ORDER_FLAG varchar_tab_1;
     OB_SHIPPABLE_ITEM_FLAG	varchar_tab_1;
     OB_CUSTOMER_ORDER_FLAG	varchar_tab_1;
     OB_INTERNAL_ORDER_FLAG	varchar_tab_1;
     OB_CUSTOMER_ORDER_ENABLED_FLAG	varchar_tab_1;
     OB_INTERNAL_ORDER_ENABLED_FLAG	varchar_tab_1;
     OB_SO_TRANSACTIONS_FLAG	varchar_tab_1;
     OB_DESCRIPTION		varchar_tab_2000;
     OB_ASSEMBLY_ITEM_ID	number_tab_tp;
     OB_COMPONENT_CODE		varchar_tab_1000;
     OB_LOOP_FLAG		number_tab_tp;
     OB_PARENT_BOM_ITEM_TYPE	number_tab_tp;
     OB_OPERATION_SEQ_NUM	number_tab_tp;
     OB_ITEM_NUM		number_tab_tp;
     OB_EFFECTIVITY_DATE	date_tab_tp;
     OB_DISABLE_DATE		date_tab_tp;
     OB_IMPLEMENTATION_DATE	date_tab_tp;
     OB_REXPLODE_FLAG		number_tab_tp;
     OB_COMMON_BILL_SEQUENCE_ID number_tab_tp;
     OB_COMP_BILL_SEQ_ID	number_tab_tp;
     OB_COMP_COMMON_BILL_SEQ_ID	number_tab_tp;
     OB_AUTO_REQUEST_MATERIAL   varchar_tab_1;
     OB_SOURCE_BILL_SEQUENCE_ID	number_tab_tp;
     OB_COMMON_COMPONENT_SEQ_ID	number_tab_tp;
     OB_COMP_SOURCE_BILL_SEQ_ID	number_tab_tp;

     X_SortWidth CONSTANT NUMBER := Bom_Common_Definitions.G_Bom_SortCode_Width ; -- at most 9999999 components
     G_MAX_BATCH_FETCH_SIZE CONSTANT NUMBER := 10000;

/*
** Procedure: Empty_Sql_Tables
** Purpose: Local procedure, Used only for cleaning up the pl/sql tables
**          Every iteration of the loop that selects the data will need to cleanup before
**	    appending.
*/
PROCEDURE Empty_Sql_Tables
AS
BEGIN
	--      Delete pl/sql table Bug 2822347
	OB_TOP_BILL_SEQUENCE_ID.delete;
	OB_BILL_SEQUENCE_ID.delete;
	OB_ORGANIZATION_ID.delete	;
	OB_EXPLOSION_TYPE.delete;
	OB_COMPONENT_SEQUENCE_ID.delete;
	OB_COMPONENT_ITEM_ID.delete;
	OB_PLAN_LEVEL.delete;
	OB_EXTENDED_QUANTITY.delete;
	OB_SORT_ORDER.delete;
	OB_CREATION_DATE.delete;
	OB_CREATED_BY.delete;
	OB_LAST_UPDATE_DATE.delete;
	OB_LAST_UPDATED_BY.delete;
	OB_TOP_ITEM_ID.delete;
	OB_ATTRIBUTE1.delete;
	OB_ATTRIBUTE2.delete;
	OB_ATTRIBUTE3.delete;
	OB_ATTRIBUTE4.delete;
	OB_ATTRIBUTE5.delete;
	OB_ATTRIBUTE6.delete;
	OB_ATTRIBUTE7.delete;
	OB_ATTRIBUTE8.delete;
	OB_ATTRIBUTE9.delete;
	OB_ATTRIBUTE10.delete;
	OB_ATTRIBUTE11.delete;
	OB_ATTRIBUTE12.delete;
	OB_ATTRIBUTE13.delete;
	OB_ATTRIBUTE14.delete;
	OB_ATTRIBUTE15.delete;
	OB_BASIS_TYPE.delete;
	OB_COMPONENT_QUANTITY.delete;
	OB_SO_BASIS.delete;
	OB_OPTIONAL.delete;
	OB_MUTUALLY_EXCLUSIVE_OPTIONS.delete;
	OB_CHECK_ATP.delete;
	OB_SHIPPING_ALLOWED.delete;
	OB_REQUIRED_TO_SHIP.delete;
	OB_REQUIRED_FOR_REVENUE.delete;
	OB_INCLUDE_ON_SHIP_DOCS.delete;
	OB_INCLUDE_ON_BILL_DOCS.delete;
	OB_LOW_QUANTITY.delete;
	OB_HIGH_QUANTITY.delete;
	OB_PICK_COMPONENTS.delete;
	OB_PRIMARY_UOM_CODE.delete;
	OB_PRIMARY_UNIT_OF_MEASURE.delete;
	OB_BASE_ITEM_ID.delete;
	OB_ATP_COMPONENTS_FLAG.delete;
	OB_ATP_FLAG.delete;
	OB_BOM_ITEM_TYPE.delete;
	OB_PICK_COMPONENTS_FLAG.delete;
	OB_REPLENISH_TO_ORDER_FLAG.delete;
	OB_SHIPPABLE_ITEM_FLAG.delete;
	OB_CUSTOMER_ORDER_FLAG.delete;
	OB_INTERNAL_ORDER_FLAG.delete;
	OB_CUSTOMER_ORDER_ENABLED_FLAG.delete;
	OB_INTERNAL_ORDER_ENABLED_FLAG.delete;
	OB_SO_TRANSACTIONS_FLAG.delete;
	OB_DESCRIPTION.delete;
	OB_ASSEMBLY_ITEM_ID.delete;
	OB_COMPONENT_CODE.delete;
	OB_LOOP_FLAG.delete;
	OB_PARENT_BOM_ITEM_TYPE.delete;
	OB_OPERATION_SEQ_NUM.delete;
	OB_ITEM_NUM.delete;
	OB_EFFECTIVITY_DATE.delete;
	OB_DISABLE_DATE.delete;
	OB_IMPLEMENTATION_DATE.delete;
	OB_REXPLODE_FLAG.delete;
	OB_COMMON_BILL_SEQUENCE_ID.delete;
	OB_COMP_BILL_SEQ_ID.delete;
	OB_COMP_COMMON_BILL_SEQ_ID.delete;
	OB_AUTO_REQUEST_MATERIAL.delete;
  OB_SOURCE_BILL_SEQUENCE_ID.delete;
  OB_COMMON_COMPONENT_SEQ_ID.delete;
  OB_COMP_SOURCE_BILL_SEQ_ID.delete;

END Empty_Sql_Tables;

/*
** Procedure: DELETE_EXPL_BILL
** Purpose: Local procedure used for deleting records from the explosion table
belonging to the same parent
*/
Procedure DELETE_EXPL_BILL(top_bill_id	Number,
			   arg_expl_type	Varchar2)
IS
pragma  AUTONOMOUS_TRANSACTION;

CURSOR c_rows_to_delete IS
	select sort_order
	  from bom_explosions
	 where top_bill_sequence_id = top_bill_id
	   and explosion_type = arg_expl_type
	   and rexplode_flag = 1;
BEGIN

	for parent in c_rows_to_delete
	loop
		DELETE from bom_explosions
		 WHERE top_bill_sequence_id = top_bill_id
           	   AND explosion_type = arg_expl_type
		   AND sort_order like parent.sort_order || '%'
		   AND sort_order <> parent.sort_order;
		commit;
	end loop;
END Delete_Expl_Bill;

/*
** Procedure: Generate_Sort_Order
** Purpose: Local procedure used for generating the sort_order for a node within the pl/sql table
*/
PROCEDURE Generate_Sort_Order
AS
	l_parent_id    Number;
	l_parent_sort_order VARCHAR2(2000);
	x_sort_counter Number;
BEGIN
	IF ob_sort_order.count > 0
	THEN
		l_parent_id := OB_BILL_SEQUENCE_ID(1);
		l_parent_sort_order := ob_sort_order(1);
	ELSE
		return;
	END IF;

	/* When starting the number generation, fetch the count and then proceed
	   This is because the fetch size is 1000 and the sort_order should be unique.
	*/
	SELECT count(bill_sequence_id)
	  INTO x_sort_counter
	  FROM bom_explosions
	 WHERE top_bill_sequence_id = OB_TOP_BILL_SEQUENCE_ID(1)
	   AND bill_sequence_id     = OB_BILL_SEQUENCE_ID(1)
	   AND ( sort_order like OB_SORT_ORDER(1)||'%' AND
		 sort_order <> OB_SORT_ORDER(1)
	       )
	   AND explosion_type       = OB_EXPLOSION_TYPE(1);

	FOR l_node_count in 1..ob_sort_order.count
	LOOP
	   IF ( l_parent_sort_order <> ob_sort_order(l_node_count)
	      )
	    THEN
	    	x_sort_counter := 1;
                l_parent_id := OB_BILL_SEQUENCE_ID(l_node_count);
	        l_parent_sort_order := ob_sort_order(l_node_count);
	    ELSE
	    	x_sort_counter := x_sort_counter + 1;
	    END IF;
	    ob_sort_order(l_node_count) := ob_sort_order(l_node_count) ||
				lpad(to_char(x_sort_counter), X_SortWidth, '0');
	END LOOP;
END Generate_Sort_Order;


/*
** Procedure: Be_Exploder
** Purpose  : This is the driving procedure for the Explosion
**            External applications requiring data from explosion table will first invoke
**            this procedure before selecting directly from the table.
*/

procedure be_exploder (
        arg_org_id                  IN  NUMBER,
        arg_starting_rev_date       IN  DATE,
        arg_expl_type               IN  VARCHAR2 DEFAULT 'OPTIONAL',
        arg_order_by                IN  NUMBER DEFAULT 1,
        arg_levels_to_explode       IN  NUMBER DEFAULT 20,
        arg_item_id                 IN  NUMBER,
        arg_comp_code               IN  VARCHAR2 DEFAULT '',
	arg_user_id		    IN  NUMBER DEFAULT 0,
        arg_err_msg                 OUT NOCOPY VARCHAR2,
        arg_error_code              OUT NOCOPY NUMBER,
        arg_alt_bom_desig	    IN  VARCHAR2
) IS

    x_expl_qty			NUMBER := 1;
    stmt_num			NUMBER := 0;

    x_no_top_assy		EXCEPTION;
    x_loop_detected		EXCEPTION;
    x_bom_expl_del              EXCEPTION;
    x_bom_expl_run  	        EXCEPTION; /* Fix for bug 9198518-added this exception */

    x_top_bill_id		NUMBER;
    x_top_common_bill_id	NUMBER;
    x_top_source_bill_id NUMBER;

    x_sort_counter		NUMBER := 0;
    x_req_id                    NUMBER := 0;
    x_delete_bom_expl           NUMBER := 2;

    x_yes			constant number := 1;
    x_no			constant number := 2;
    bill_exists			Number	:= 0;
    l_count number := 0; -- Added to fix bug #8496032
    update_exp EXCEPTION; -- Added to fix bug #8496032

	CURSOR get_bill_id IS
	SELECT 	bill_sequence_id,
		common_bill_sequence_id,
    source_bill_sequence_id
	FROM    bom_bill_of_materials
	WHERE   assembly_item_id = arg_item_id
	AND	organization_id = arg_org_id
	AND	NVL(alternate_bom_designator,'NONE') = NVL(arg_alt_bom_desig,'NONE');

	CURSOR bom_expl(top_bill_id Number) IS
	Select  REQUEST_ID
	FROM    BOM_EXPLOSIONS
	WHERE   top_bill_sequence_id = top_bill_id
	AND     explosion_type = arg_expl_type;
	-- bug 15961704
	--AND     sort_order = Bom_Common_Definitions.G_Bom_Init_SortCode;

	Cursor GetExplodeFlags is
	Select rowid,
	       plan_level,
	       sort_order
	From bom_explosions
	Where rexplode_flag = 1
	And   top_bill_sequence_id = x_top_bill_id
	And   explosion_type = arg_expl_type
	Order by plan_level;

	X_MoreLevels boolean := true; -- more levels to explode
	X_FirstLevel number; -- first level needing re-explosion

	Cursor ordered_bill(p_plan_level number) IS
	SELECT  /*+ LEADING (BE) */
		x_top_bill_id TOP_BILL_SEQUENCE_ID,
		BOM.BILL_SEQUENCE_ID,
		BOM.ORGANIZATION_ID,
		arg_expl_type EXPLOSION_TYPE,
		BIC.COMPONENT_SEQUENCE_ID,
		BIC.COMPONENT_ITEM_ID,
		BE.PLAN_LEVEL + 1 PLAN_LEVEL,
		decode(BIC.BASIS_TYPE, null, BE.EXTENDED_QUANTITY,1) * BIC.COMPONENT_QUANTITY EXTENDED_QUANTITY,
		BE.SORT_ORDER,
		sysdate CREATION_DATE,
		arg_user_id CREATED_BY,
		sysdate LAST_UPDATE_DATE,
		arg_user_id	LAST_UPDATED_BY,
		BE.TOP_ITEM_ID,
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
		BIC.BASIS_TYPE,
		BIC.COMPONENT_QUANTITY,
		BIC.SO_BASIS,
		BIC.OPTIONAL,
		BIC.MUTUALLY_EXCLUSIVE_OPTIONS,
		BIC.CHECK_ATP,
		BIC.SHIPPING_ALLOWED,
		BIC.REQUIRED_TO_SHIP,
		BIC.REQUIRED_FOR_REVENUE,
		BIC.INCLUDE_ON_SHIP_DOCS,
		BIC.INCLUDE_ON_BILL_DOCS,
		BIC.LOW_QUANTITY,
		BIC.HIGH_QUANTITY,
		BIC.PICK_COMPONENTS,
		MSI.PRIMARY_UOM_CODE,
		MSI.PRIMARY_UNIT_OF_MEASURE,
		MSI.BASE_ITEM_ID,
		MSI.ATP_COMPONENTS_FLAG,
		MSI.ATP_FLAG,
		MSI.BOM_ITEM_TYPE,
		MSI.PICK_COMPONENTS_FLAG,
		MSI.REPLENISH_TO_ORDER_FLAG,
		MSI.SHIPPABLE_ITEM_FLAG,
		MSI.CUSTOMER_ORDER_FLAG,
		MSI.INTERNAL_ORDER_FLAG,
		MSI.CUSTOMER_ORDER_ENABLED_FLAG,
		MSI.INTERNAL_ORDER_ENABLED_FLAG,
		MSI.SO_TRANSACTIONS_FLAG,
		MSITL.DESCRIPTION,
		BOM.ASSEMBLY_ITEM_ID,
		BE.COMPONENT_CODE,
		BE.LOOP_FLAG,
		BE.BOM_ITEM_TYPE PARENT_BOM_ITEM_TYPE,
		BIC.OPERATION_SEQ_NUM,
		BIC.ITEM_NUM,
		GREATEST(BE.EFFECTIVITY_DATE, BIC.EFFECTIVITY_DATE) EFFECTIVITY_DATE,
		LEAST(BE.DISABLE_DATE, NVL(BIC.DISABLE_DATE,BE.DISABLE_DATE)) DISABLE_DATE,
		BIC.IMPLEMENTATION_DATE,
		1 REXPLODE_FLAG,
		BOM.COMMON_BILL_SEQUENCE_ID,
		BBOM_C.BILL_SEQUENCE_ID COMP_BILL_SEQ_ID,
		 BBOM_C.COMMON_BILL_SEQUENCE_ID COMP_COMMON_BILL_SEQ_ID,
		-- chrng: added auto_request_material
    		BIC.AUTO_REQUEST_MATERIAL,
    BOM.SOURCE_BILL_SEQUENCE_ID,
    BIC.COMMON_COMPONENT_SEQUENCE_ID,
    BBOM_C.SOURCE_BILL_SEQUENCE_ID COMP_SOURCE_BILL_SEQ_ID
	FROM
		BOM_STRUCTURES_B BBOM_C,
		MTL_SYSTEM_ITEMS MSI,
    MTL_SYSTEM_ITEMS_TL MSITL,
		BOM_COMPONENTS_B BIC,
		BOM_STRUCTURES_B BOM,
		BOM_EXPLOSIONS BE
    -- FP bug fix for 12.1.1. The bug # is 7307613.
    -- Fixed by Minling on 10/15/08.
    -- Changed the WHERE condition to improve performance of the query.
        WHERE (  ( BBOM_C.obj_name IS NULL AND fnd_global.RESP_APPL_ID = 431 )
                        OR ( BBOM_C.obj_name IS NULL AND fnd_global.RESP_APPL_ID = -1 )
                        OR ( BBOM_C.obj_name is null and fnd_global.RESP_APPL_ID <> 431 and nvl(BBOM_C.effectivity_control,1) <= 3 ) )
           AND   (  ( BOM.obj_name IS NULL AND fnd_global.RESP_APPL_ID = 431 )
                        OR ( BOM.obj_name IS NULL AND fnd_global.RESP_APPL_ID = -1 )
                        OR ( BOM.obj_name is null and fnd_global.RESP_APPL_ID <> 431 and nvl(BOM.effectivity_control,1) <= 3 ) )
           AND        BE.TOP_BILL_SEQUENCE_ID = x_top_bill_id
    -- END of bug fix 7307613.


	AND	BE.EXPLOSION_TYPE = arg_expl_type
	--AND   BE.SORT_ORDER = P_Parent
  AND nvl(BBOM_C.effectivity_control,1) <= 3
  AND
  (
      BBOM_C.obj_name is null
      OR BBOM_C.obj_name = 'EGO_ITEM'
  )
  AND
  (
      BOM.obj_name is null
      OR BOM.obj_name = 'EGO_ITEM'
  )
  AND NVL(BOM.effectivity_control,1) <= 3     --Bug 7444587(7450613,7450614)
  AND BIC.overlapping_changes is null
  AND
  (
      BIC.obj_name is null
      OR BIC.obj_name = 'EGO_ITEM'
  )
	AND   BE.rexplode_flag = 1
  AND   BE.PLAN_LEVEL = p_plan_level
	AND	BOM.ORGANIZATION_ID = BE.ORGANIZATION_ID
	AND	BOM.ASSEMBLY_ITEM_ID = BE.COMPONENT_ITEM_ID
	AND	(
		( arg_alt_bom_desig IS NULL
			AND
		BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
			)
		OR
		(arg_alt_bom_desig IS NOT NULL
			AND
		BOM.ALTERNATE_BOM_DESIGNATOR IS NOT NULL
			AND
		BOM.ALTERNATE_BOM_DESIGNATOR=arg_alt_bom_desig
		)
		OR
			( arg_alt_bom_desig IS NOT NULL
			AND BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
			AND NOT EXISTS
				(SELECT 'X'
				FROM BOM_BILL_OF_MATERIALS BOM2
				WHERE BOM2.ORGANIZATION_ID = arg_org_id
				AND   BOM2.ASSEMBLY_ITEM_ID = BE.COMPONENT_ITEM_ID
				AND   BOM2.ALTERNATE_BOM_DESIGNATOR =
					arg_alt_bom_desig
				AND   BOM2.ASSEMBLY_TYPE = 1
				) -- subquery
			)
			) -- end of alt logic
	AND	BIC.BILL_SEQUENCE_ID = BOM.COMMON_BILL_SEQUENCE_ID
	AND	NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
	AND	BIC.IMPLEMENTATION_DATE IS NOT NULL
	AND   BIC.COMPONENT_QUANTITY >= 0
	AND	MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
  AND	MSI.INVENTORY_ITEM_ID = BIC.COMPONENT_ITEM_ID
  AND	MSITL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
  AND	MSITL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
  AND MSITL.LANGUAGE = USERENV('LANG')
	AND   ( (arg_expl_type = 'OPTIONAL'
		AND BE.BOM_ITEM_TYPE in (1,2)  -- parent is a model or opt class
		AND (BIC.BOM_ITEM_TYPE IN (1,2) OR -- comp is a model or opt class
			(BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 1)))
					-- comp is an optional standard item
	OR   (arg_expl_type = 'INCLUDED'
		AND BE.PICK_COMPONENTS_FLAG = 'Y' -- parent is PTO
		AND BIC.BOM_ITEM_TYPE = 4  -- comp is a mandatory standard item
		AND BIC.OPTIONAL = 2)
	OR   (arg_expl_type not in ('OPTIONAL', 'INCLUDED')) -- both
	)
    AND  ( (BE.BASE_ITEM_ID IS NOT NULL AND
        BIC.BOM_ITEM_TYPE NOT IN (1,2)
        )
        OR
        BE.BASE_ITEM_ID IS NULL
         )  /* Added for bug 3531716*/
	AND	BOM.ASSEMBLY_TYPE = 1
	AND	LEAST(BE.DISABLE_DATE,  NVL(BIC.DISABLE_DATE,BE.DISABLE_DATE)) >=
		GREATEST(BE.EFFECTIVITY_DATE, BIC.EFFECTIVITY_DATE)
	AND   BE.LOOP_FLAG = x_no
	AND	BBOM_C.ORGANIZATION_ID(+) = arg_org_id
	AND	BBOM_C.ASSEMBLY_ITEM_ID (+) = BIC.COMPONENT_ITEM_ID
	AND	(
		( arg_alt_bom_desig IS NULL
			AND
		BBOM_C.ALTERNATE_BOM_DESIGNATOR IS NULL
			)
		OR
		(arg_alt_bom_desig IS NOT NULL
			AND
		BBOM_C.ALTERNATE_BOM_DESIGNATOR IS NOT NULL
			AND
		BBOM_C.ALTERNATE_BOM_DESIGNATOR=arg_alt_bom_desig
		)
		OR
			( arg_alt_bom_desig IS NOT NULL
			AND BBOM_C.ALTERNATE_BOM_DESIGNATOR IS NULL
			AND NOT EXISTS
				(SELECT 'X'
				FROM BOM_BILL_OF_MATERIALS BOM2
				WHERE BOM2.ORGANIZATION_ID = arg_org_id
				AND   BOM2.ASSEMBLY_ITEM_ID = BIC.COMPONENT_ITEM_ID
				AND   BOM2.ALTERNATE_BOM_DESIGNATOR =
					arg_alt_bom_desig
				AND   BOM2.ASSEMBLY_TYPE = 1
				) -- subquery
			)
			) -- end of alt logic
	ORDER BY be.sort_order,
		decode(arg_order_by,1,bic.operation_seq_num, bic.item_num),
		decode(arg_order_by,1,bic.item_num, bic.operation_seq_num);


	X_ParentCode bom_explosions.component_code%type;
	X_Ancestor number; -- component item id within component code

	Loop_Count_Val  Number := 0;
	L_Bulk_Count 	Number := 0;
	l_plan_level 	Number := 0;

	-- New plsql tables, etc added for resolving Bug 2822347

pragma  AUTONOMOUS_TRANSACTION; --added for bug 2709042

BEGIN

SAVEPOINT BE;

x_top_bill_id := 0;
x_req_id      := 0;
x_delete_bom_expl    := 2;
x_top_common_bill_id := 0;
x_top_source_bill_id := 0;

stmt_num := 10;

-- Get the bill sequence id for the given item/org. If no primary bill exists
-- raise an exception

FOR cr IN get_bill_id LOOP
  x_top_bill_id := cr.bill_sequence_id;
  x_top_common_bill_id := cr.common_bill_sequence_id;
  x_top_source_bill_id := cr.source_bill_sequence_id;
END LOOP;

IF (x_top_bill_id = 0) THEN
  raise x_no_top_assy;
END IF;

--Added for bug 2700606

x_delete_bom_expl := fnd_profile.value('BOM:DELETE_BOM_EXPLOSIONS');

stmt_num := 15;

IF (x_delete_bom_expl = 1) THEN

        For cr in bom_expl(x_top_bill_id) Loop
        /* Fix for bug 9198518 - modify the If condition to ignore rows with request_id -999 */
           IF  ( (cr.request_id IS NOT NULL) AND (cr.request_id <> -999))THEN
                x_req_id := cr.request_id;
                raise x_bom_expl_del;
           END IF;
        End Loop;

END IF;

/* Fix for bug 9198518 - check whether explosion of the top model is currently underway,
   and if so throw an error msg asking users to wait till the explosion completes */
stmt_num := 16;

        For cr in bom_expl(x_top_bill_id) Loop
           IF (cr.request_id is not null) AND (cr.request_id = -999) THEN
                raise x_bom_expl_run;
           END IF;
        End Loop;

stmt_num := 20;

-- Insert a record for the assembly in BOM_EXPLOSIONS. This will serve as the
-- parent (plan_level = 0) for the rest of the explosion.
/*Bug 6407303 Added the attribute parent_sort_order and set its value to null*/
insert into bom_explosions
	(TOP_BILL_SEQUENCE_ID            	 ,
	BILL_SEQUENCE_ID                        ,
	ORGANIZATION_ID                         ,
	EXPLOSION_TYPE				 ,
	COMPONENT_SEQUENCE_ID                   ,
	COMPONENT_ITEM_ID                       ,
	PLAN_LEVEL                              ,
	EXTENDED_QUANTITY                       ,
	SORT_ORDER                              ,
	CREATION_DATE				 ,
	CREATED_BY				 ,
	LAST_UPDATE_DATE			 ,
	LAST_UPDATED_BY			 ,
	TOP_ITEM_ID                             ,
	BASIS_TYPE				,
	COMPONENT_QUANTITY                      ,
	BOM_ITEM_TYPE                           ,
	PARENT_BOM_ITEM_TYPE                    ,
	COMMON_BILL_SEQUENCE_ID                 ,
	EFFECTIVITY_DATE			 ,
	DISABLE_DATE				 ,
	COMPONENT_CODE				,
	DESCRIPTION				,
	PRIMARY_UOM_CODE			,
	PRIMARY_UNIT_OF_MEASURE			,
	BASE_ITEM_ID				,
	ATP_COMPONENTS_FLAG			,
	ATP_FLAG				,
	PICK_COMPONENTS_FLAG			,
	REPLENISH_TO_ORDER_FLAG			,
	SHIPPABLE_ITEM_FLAG			,
	CUSTOMER_ORDER_FLAG			,
	INTERNAL_ORDER_FLAG			,
	CUSTOMER_ORDER_ENABLED_FLAG		,
	INTERNAL_ORDER_ENABLED_FLAG		,
	SO_TRANSACTIONS_FLAG			,
	REXPLODE_FLAG				,
	COMP_BILL_SEQ_ID			,
	COMP_COMMON_BILL_SEQ_ID			,
	LOOP_FLAG				,
	-- chrng: added auto_request_material
 	AUTO_REQUEST_MATERIAL,
  SOURCE_BILL_SEQUENCE_ID,
  COMP_SOURCE_BILL_SEQ_ID,
  PARENT_SORT_ORDER)
	SELECT
		x_top_bill_id				,
		x_top_bill_id				,
		arg_org_id				,
		arg_expl_type				,
		x_top_bill_id				,
		arg_item_id				,
		0					,
		x_expl_qty				,
		lpad('1', X_SortWidth, '0')            ,
		sysdate				,
		arg_user_id				,
		sysdate				,
		arg_user_id				,
		arg_item_id				,
		1					,
                1					,
		msi.bom_item_type			,
		msi.bom_item_type			,
		x_top_common_bill_id			,
		arg_starting_rev_date			,
		sysdate + 30000			,
		to_char(msi.inventory_item_id)		,
		msitl.description			,
		msi.PRIMARY_UOM_CODE			,
		msi.PRIMARY_UNIT_OF_MEASURE		,
		msi.BASE_ITEM_ID			,
		msi.ATP_COMPONENTS_FLAG		,
		msi.ATP_FLAG				,
		msi.PICK_COMPONENTS_FLAG		,
		msi.REPLENISH_TO_ORDER_FLAG		,
		msi.SHIPPABLE_ITEM_FLAG		,
		msi.CUSTOMER_ORDER_FLAG		,
		msi.INTERNAL_ORDER_FLAG		,
		msi.CUSTOMER_ORDER_ENABLED_FLAG	,
		msi.INTERNAL_ORDER_ENABLED_FLAG	,
		msi.SO_TRANSACTIONS_FLAG		,
		1	 				,
		x_top_bill_id				,
		x_top_common_bill_id			,
		x_no					,
		-- chrng: added 'Y' as default for auto_request_material
 		'Y',
    x_top_source_bill_id,
    x_top_source_bill_id,
    NULL
		FROM 	mtl_system_items msi,
    mtl_system_items_tl msitl
		WHERE	msi.organization_id = arg_org_id
		AND	msi.inventory_item_id = arg_item_id
    AND msitl.organization_id = msi.organization_id
    AND	msitl.inventory_item_id = msi.inventory_item_id
    AND msitl.language = userenv('LANG')
		and not exists (
			select null
			from bom_explosions be
			where be.top_bill_sequence_id = x_top_bill_id
			and be.explosion_type = arg_expl_type
			);

-- Moved code for Performance from the while loop to the outer loop
-- Do not execute the update statement if the insert statement just inserted
--the record, bug: 3809420
 If (sql%rowcount = 0) then

     /* Fix for bug 9198518 - check whether explosion of the top model is currently underway,
     and if so throw an error msg asking users to wait till the explosion completes */
  stmt_num := 21;

        For cr in bom_expl(x_top_bill_id) Loop
           IF (cr.request_id is not null) AND (cr.request_id = -999) THEN
                   raise x_bom_expl_run;
           END IF;
        End Loop;

	 /* Start : Additions to fix bug #8496032 */

 	   select count(*)
 	   into   l_count
 	   from   BOM_EXPLOSIONS be
 	   where  be.rexplode_flag = 1
 	   And    be.top_bill_sequence_id = x_top_bill_id
 	   And    be.explosion_type = arg_expl_type
 	   and    exists  (select *
 	                   FROM MTL_SYSTEM_ITEMS msi
 	                   WHERE msi.organization_id = arg_org_id
 	                   and be.component_item_id = msi.inventory_item_id);

 	   if(l_count > 0) then

 	   BEGIN
 	   /* End : Additions to fix bug #8479442
 	 Also see exception below */

    update BOM_EXPLOSIONS be
    SET (BOM_ITEM_TYPE			,
	 DESCRIPTION                    ,
	 PRIMARY_UOM_CODE               ,
	 PRIMARY_UNIT_OF_MEASURE        ,
	 BASE_ITEM_ID                   ,
	 ATP_COMPONENTS_FLAG            ,
	 ATP_FLAG                       ,
	 PICK_COMPONENTS_FLAG           ,
	 REPLENISH_TO_ORDER_FLAG        ,
	 SHIPPABLE_ITEM_FLAG            ,
	 CUSTOMER_ORDER_FLAG            ,
	 INTERNAL_ORDER_FLAG            ,
	 CUSTOMER_ORDER_ENABLED_FLAG    ,
	 INTERNAL_ORDER_ENABLED_FLAG    ,
	 SO_TRANSACTIONS_FLAG)
      = (select msi.bom_item_type		,
	 msitl.description                        ,
	 msi.PRIMARY_UOM_CODE                   ,
	 msi.PRIMARY_UNIT_OF_MEASURE            ,
	 msi.BASE_ITEM_ID                       ,
	 msi.ATP_COMPONENTS_FLAG                ,
	 msi.ATP_FLAG                           ,
	 msi.PICK_COMPONENTS_FLAG               ,
	 msi.REPLENISH_TO_ORDER_FLAG            ,
	 msi.SHIPPABLE_ITEM_FLAG                ,
	 msi.CUSTOMER_ORDER_FLAG                ,
	 msi.INTERNAL_ORDER_FLAG                ,
	 msi.CUSTOMER_ORDER_ENABLED_FLAG        ,
	 msi.INTERNAL_ORDER_ENABLED_FLAG        ,
	 msi.SO_TRANSACTIONS_FLAG
	 from MTL_SYSTEM_ITEMS msi,
        MTL_SYSTEM_ITEMS_TL msitl
         WHERE msi.organization_id = arg_org_id
         and msi.inventory_item_id = be.component_item_id
         AND msitl.organization_id = msi.organization_id
         AND msitl.inventory_item_id = msi.inventory_item_id
         AND msitl.language = userenv('LANG'))
     WHERE be.rexplode_flag = 1
     And   be.top_bill_sequence_id = x_top_bill_id
     And   be.explosion_type = arg_expl_type;

	 /* Exception also added for bug 8479442 */
 	   EXCEPTION
 	   when Others THEN
 	   raise update_exp;
 	   END;
 	 /* Exception added for bug 8479442 */

     Commit;  -- Added commit after Update as it was causing deadlock

  /* Fix for bug 9198518 - Populate the request_id for top model as - 999 signifying
     that the explosion is in process. Commit it so as to be visible for other explosion runs. */

   UPDATE  BOM_EXPLOSIONS
   SET     request_id= -999
   WHERE   top_bill_sequence_id = x_top_bill_id
   AND     explosion_type = arg_expl_type
   -- Bug 15961704
   -- AND     sort_order = Bom_Common_Definitions.G_Bom_Init_SortCode
   AND     request_id is null;

   If (sql%rowcount = 0) Then
         raise x_bom_expl_run;
   End If;

   commit;
	End If; --closing if statement introduced by bug 8496032
  End If;
    -- delete the subtree needing re-explosion

    /*stmt_num := 40;
    Delete from bom_explosions be
    Where be.top_bill_sequence_id = x_top_bill_id
    And be.explosion_type = arg_expl_type
    and be.rexplode_flag = 1;
    and be.sort_order like be.sort_order||'%'
    and be.sort_order <> be.sort_order
*/

	Delete_Expl_Bill(x_top_bill_id,arg_expl_type);
    /*Delete from bom_explosions be
    Where be.top_bill_sequence_id = x_top_bill_id
    and be.explosion_type = arg_expl_type
    and exists (select 'X'
                from bom_explosions be1
                where be1.top_bill_sequence_id = x_top_bill_id
                and be1.explosion_type = arg_expl_type
                and be1.sort_order <> be.sort_order
                and be.sort_order like  be1.sort_order || '%'
                and be1.rexplode_flag = 1);
*/

-- End of code moved

l_plan_level := 0;
While X_MoreLevels
LOOP
  X_MoreLevels := true;
  stmt_num := 30;

   /*
   For X_Flags in GetExplodeFlags loop
    If GetExplodeFlags%rowcount = 1 then
      X_FirstLevel := X_Flags.plan_level;
    End if;
    If X_Flags.plan_level > X_FirstLevel then
      X_MoreLevels := true;
      Exit;
    End if;
   */

    -- Explode the next level unless  we've reached the maximum level

    stmt_num := 50;
    If l_plan_level > arg_levels_to_explode
    then
      	Exit;
    else
      x_sort_counter := 0;

      /*
      	Update the sort_order for the plan_level =0 to sort_order in constant as the
      	first never gets deleted even if the re_explode flag is 1.This has to be done else
      	the existing BOM's sort_order will go wrong during re_explosion
      */
      IF  l_plan_level = 0
      THEN
	UPDATE bom_explosions be
	  SET sort_order =  Bom_Common_Definitions.G_Bom_Init_SortCode
	 WHERE be.plan_level = 0
	  AND  be.top_bill_sequence_id = x_top_bill_id
     	  AND  be.explosion_type = arg_expl_type
	  AND  be.rexplode_flag = 1;
       END IF;

     stmt_num := 60;
     Loop_Count_Val	:= 0;
     l_bulk_count	:= 0;

     LOOP
     	/* Empty the pl/sql tables before the iteration */
     	Empty_Sql_Tables;

        If not ordered_bill%isopen then
		open ordered_bill(p_plan_level => l_plan_level);
        end if;
     	Fetch ordered_bill bulk collect into
     		OB_TOP_BILL_SEQUENCE_ID,
     		OB_BILL_SEQUENCE_ID,
     		OB_ORGANIZATION_ID,
     		OB_EXPLOSION_TYPE,
     		OB_COMPONENT_SEQUENCE_ID,
     		OB_COMPONENT_ITEM_ID,
     		OB_PLAN_LEVEL,
     		OB_EXTENDED_QUANTITY,
     		OB_SORT_ORDER,
     		OB_CREATION_DATE,
     		OB_CREATED_BY,
     		OB_LAST_UPDATE_DATE,
     		OB_LAST_UPDATED_BY,
     		OB_TOP_ITEM_ID,
     		OB_ATTRIBUTE1,
     		OB_ATTRIBUTE2,
     		OB_ATTRIBUTE3,
     		OB_ATTRIBUTE4,
     		OB_ATTRIBUTE5,
     		OB_ATTRIBUTE6,
     		OB_ATTRIBUTE7,
     		OB_ATTRIBUTE8,
     		OB_ATTRIBUTE9,
     		OB_ATTRIBUTE10,
     		OB_ATTRIBUTE11,
     		OB_ATTRIBUTE12,
     		OB_ATTRIBUTE13,
     		OB_ATTRIBUTE14,
     		OB_ATTRIBUTE15,
                OB_BASIS_TYPE,
     		OB_COMPONENT_QUANTITY,
     		OB_SO_BASIS,
     		OB_OPTIONAL,
     		OB_MUTUALLY_EXCLUSIVE_OPTIONS,
     		OB_CHECK_ATP,
     		OB_SHIPPING_ALLOWED,
     		OB_REQUIRED_TO_SHIP,
     		OB_REQUIRED_FOR_REVENUE,
     		OB_INCLUDE_ON_SHIP_DOCS,
     		OB_INCLUDE_ON_BILL_DOCS,
     		OB_LOW_QUANTITY,
     		OB_HIGH_QUANTITY,
     		OB_PICK_COMPONENTS,
     		OB_PRIMARY_UOM_CODE,
     		OB_PRIMARY_UNIT_OF_MEASURE,
     		OB_BASE_ITEM_ID,
     		OB_ATP_COMPONENTS_FLAG,
     		OB_ATP_FLAG,
     		OB_BOM_ITEM_TYPE,
     		OB_PICK_COMPONENTS_FLAG,
     		OB_REPLENISH_TO_ORDER_FLAG,
     		OB_SHIPPABLE_ITEM_FLAG,
     		OB_CUSTOMER_ORDER_FLAG,
     		OB_INTERNAL_ORDER_FLAG,
     		OB_CUSTOMER_ORDER_ENABLED_FLAG,
     		OB_INTERNAL_ORDER_ENABLED_FLAG,
     		OB_SO_TRANSACTIONS_FLAG,
		OB_DESCRIPTION,
     		OB_ASSEMBLY_ITEM_ID,
     		OB_COMPONENT_CODE,
     		OB_LOOP_FLAG,
     		OB_PARENT_BOM_ITEM_TYPE,
     		OB_OPERATION_SEQ_NUM,
     		OB_ITEM_NUM,
     		OB_EFFECTIVITY_DATE,
     		OB_DISABLE_DATE,
     		OB_IMPLEMENTATION_DATE,
     		OB_REXPLODE_FLAG,
     		OB_COMMON_BILL_SEQUENCE_ID,
     		OB_COMP_BILL_SEQ_ID,
     		OB_COMP_COMMON_BILL_SEQ_ID,
     		OB_AUTO_REQUEST_MATERIAL,
        OB_SOURCE_BILL_SEQUENCE_ID,
        OB_COMMON_COMPONENT_SEQ_ID,
        OB_COMP_SOURCE_BILL_SEQ_ID
		limit G_MAX_BATCH_FETCH_SIZE;

		loop_Count_Val := ordered_bill%rowcount - l_bulk_count;
		If (ordered_bill%rowcount = 0) then
                     X_MoreLevels := false; --bug 3809420
		End If;
		/* Generate the sort order for the node based on it count in
		in the parent.
		*/
		generate_sort_order;

	-- Loop the values from the above fetch and assign values for sort_order and
	-- component code
			FOR i  IN 1..loop_Count_Val loop
				/*
				x_sort_counter := x_sort_counter + 1;
				ob_sort_order(i) := ob_sort_order(i) ||
				lpad(to_char(x_sort_counter), X_SortWidth, '0');
				*/
				-- Loop Check
				X_ParentCode := ob_component_code(i);
				While X_ParentCode is not null
				LOOP
					If instr(X_ParentCode, '-') = 0 then
						X_Ancestor := to_number(X_ParentCode);
						X_ParentCode := null;
					Else
						X_Ancestor := to_number(substr(X_ParentCode, 1,
						instr(X_ParentCode, '-') - 1));
						X_ParentCode := substr(X_ParentCode, instr(X_ParentCode, '-')+1);
					End if;
					If X_Ancestor =  ob_component_item_id(i)
					then -- loop detected
						ob_loop_flag(i) := x_yes;
						If ob_disable_date(i) > sysdate then
							close ordered_bill;
							raise x_loop_detected;
						End if;
						Exit;
					End if; -- loop found
				END LOOP; -- Loop Check while loop

				/* assign the comoponent code */
				ob_component_code(i) := ob_component_code(i)||'-'||
				to_char(ob_component_item_id(i));

				/* check if the component is a having a BOM. If the component has a BOM
				only then the component should be fetched for rexplosion
				*/
					Begin
						select count(*)
						into bill_exists
						from bom_bill_of_materials
					where assembly_item_id = ob_component_item_id(i)
						and organization_id = OB_ORGANIZATION_ID(i);

					If bill_exists =  0 then
						OB_REXPLODE_FLAG(i) := 0;
					end if;
					bill_exists := 0;
					End;

			End Loop; -- For loop_Count_Val FOR LOOP

			l_bulk_count := ordered_bill%rowcount;

			-- Insert the pl/sql table using FORALL.
				stmt_num := 70;
			FORALL i IN 1..loop_Count_Val
                                -- Removed append hint for bug 6065696 INSERT /*+ append */ INTO bom_explosions(
                                INSERT INTO bom_explosions(
				TOP_BILL_SEQUENCE_ID,
				BILL_SEQUENCE_ID,
				ORGANIZATION_ID,
				EXPLOSION_TYPE,
				COMPONENT_SEQUENCE_ID,
				COMPONENT_ITEM_ID,
				PLAN_LEVEL,
				EXTENDED_QUANTITY,
				SORT_ORDER,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				TOP_ITEM_ID,
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
                                BASIS_TYPE,
				COMPONENT_QUANTITY,
				SO_BASIS,
				OPTIONAL,
				MUTUALLY_EXCLUSIVE_OPTIONS,
				CHECK_ATP,
				SHIPPING_ALLOWED,
				REQUIRED_TO_SHIP,
				REQUIRED_FOR_REVENUE,
				INCLUDE_ON_SHIP_DOCS,
				INCLUDE_ON_BILL_DOCS,
				LOW_QUANTITY,
				HIGH_QUANTITY,
				PICK_COMPONENTS,
				PRIMARY_UOM_CODE,
				PRIMARY_UNIT_OF_MEASURE,
				BASE_ITEM_ID,
				ATP_COMPONENTS_FLAG,
				ATP_FLAG,
				BOM_ITEM_TYPE,
				PICK_COMPONENTS_FLAG,
				REPLENISH_TO_ORDER_FLAG,
				SHIPPABLE_ITEM_FLAG,
				CUSTOMER_ORDER_FLAG,
				INTERNAL_ORDER_FLAG,
				CUSTOMER_ORDER_ENABLED_FLAG,
				INTERNAL_ORDER_ENABLED_FLAG,
				SO_TRANSACTIONS_FLAG,
				DESCRIPTION,
				ASSEMBLY_ITEM_ID,
				COMPONENT_CODE,
				LOOP_FLAG,
				PARENT_BOM_ITEM_TYPE,
				OPERATION_SEQ_NUM,
				ITEM_NUM,
				EFFECTIVITY_DATE,
				DISABLE_DATE,
				IMPLEMENTATION_DATE,
				REXPLODE_FLAG,
				COMMON_BILL_SEQUENCE_ID,
				COMP_BILL_SEQ_ID,
			        COMP_COMMON_BILL_SEQ_ID,
				-- chrng: added auto_request_material,
	  		AUTO_REQUEST_MATERIAL,
        SOURCE_BILL_SEQUENCE_ID,
        COMMON_COMPONENT_SEQUENCE_ID,
        COMP_SOURCE_BILL_SEQ_ID,
	PARENT_SORT_ORDER)
				Values(
				OB_TOP_BILL_SEQUENCE_ID(i),
				OB_BILL_SEQUENCE_ID(i),
				OB_ORGANIZATION_ID(i),
				OB_EXPLOSION_TYPE(i),
				OB_COMPONENT_SEQUENCE_ID(i),
				OB_COMPONENT_ITEM_ID(i),
				OB_PLAN_LEVEL(i),
				OB_EXTENDED_QUANTITY(i),
				OB_SORT_ORDER(i),
				OB_CREATION_DATE(i),
				OB_CREATED_BY(i),
				OB_LAST_UPDATE_DATE(i),
				OB_LAST_UPDATED_BY(i),
				OB_TOP_ITEM_ID(i),
				OB_ATTRIBUTE1(i),
				OB_ATTRIBUTE2(i),
				OB_ATTRIBUTE3(i),
				OB_ATTRIBUTE4(i),
				OB_ATTRIBUTE5(i),
				OB_ATTRIBUTE6(i),
				OB_ATTRIBUTE7(i),
				OB_ATTRIBUTE8(i),
				OB_ATTRIBUTE9(i),
				OB_ATTRIBUTE10(i),
				OB_ATTRIBUTE11(i),
				OB_ATTRIBUTE12(i),
				OB_ATTRIBUTE13(i),
				OB_ATTRIBUTE14(i),
				OB_ATTRIBUTE15(i),
				OB_BASIS_TYPE(i),
				OB_COMPONENT_QUANTITY(i),
				OB_SO_BASIS(i),
				OB_OPTIONAL(i),
				OB_MUTUALLY_EXCLUSIVE_OPTIONS(i),
				OB_CHECK_ATP(i),
				OB_SHIPPING_ALLOWED(i),
				OB_REQUIRED_TO_SHIP(i),
				OB_REQUIRED_FOR_REVENUE(i),
				OB_INCLUDE_ON_SHIP_DOCS(i),
				OB_INCLUDE_ON_BILL_DOCS(i),
				OB_LOW_QUANTITY(i),
				OB_HIGH_QUANTITY(i),
				OB_PICK_COMPONENTS(i),
				OB_PRIMARY_UOM_CODE(i),
				OB_PRIMARY_UNIT_OF_MEASURE(i),
				OB_BASE_ITEM_ID(i),
				OB_ATP_COMPONENTS_FLAG(i),
				OB_ATP_FLAG(i),
				OB_BOM_ITEM_TYPE(i),
				OB_PICK_COMPONENTS_FLAG(i),
				OB_REPLENISH_TO_ORDER_FLAG(i),
				OB_SHIPPABLE_ITEM_FLAG(i),
				OB_CUSTOMER_ORDER_FLAG(i),
				OB_INTERNAL_ORDER_FLAG(i),
				OB_CUSTOMER_ORDER_ENABLED_FLAG(i),
				OB_INTERNAL_ORDER_ENABLED_FLAG(i),
				OB_SO_TRANSACTIONS_FLAG(i),
				OB_DESCRIPTION(i),
				OB_ASSEMBLY_ITEM_ID(i),
				OB_COMPONENT_CODE(i),
				OB_LOOP_FLAG(i),
				OB_PARENT_BOM_ITEM_TYPE(i),
				OB_OPERATION_SEQ_NUM(i),
				OB_ITEM_NUM(i),
				OB_EFFECTIVITY_DATE(i),
				OB_DISABLE_DATE(i),
				OB_IMPLEMENTATION_DATE(i),
				OB_REXPLODE_FLAG(i),
				OB_COMMON_BILL_SEQUENCE_ID(i),
				OB_COMP_BILL_SEQ_ID(i),
				OB_COMP_COMMON_BILL_SEQ_ID(i),
				OB_AUTO_REQUEST_MATERIAL(i),
        OB_SOURCE_BILL_SEQUENCE_ID(i),
        OB_COMMON_COMPONENT_SEQ_ID(i),
        OB_COMP_SOURCE_BILL_SEQ_ID(i),
	substr(OB_SORT_ORDER(i), 0 ,length(OB_SORT_ORDER(i)) - X_SortWidth ) );
/* Bug 6407303 Added the new attribute parent_sort_order*/
				exit when Loop_Count_Val < G_MAX_BATCH_FETCH_SIZE;
		End loop;
			/* End of Bulk Fetch . Exit when all components are inserted for that level */

		close ordered_bill; -- Close the cursor

		X_MoreLevels := true;

		End If; -- explode next level



	stmt_num := 80;
	/* Update the current level level so that the next iteration does not pick the
	   the rows
	*/
	UPDATE bom_explosions be
	   SET be.rexplode_flag = 0
	 WHERE be.plan_level = l_plan_level
	  AND  be.top_bill_sequence_id = x_top_bill_id
     	  AND  be.explosion_type = arg_expl_type
	  AND  be.rexplode_flag = 1;


	l_plan_level := l_plan_level + 1;

	IF (l_plan_level > arg_levels_to_explode)
	THEN
		X_MoreLevels := false;
	END IF;
  --End loop; -- get flags
End loop; -- more levels

arg_error_code := 0;
arg_err_msg := '';

  /* Fix for bug 9198518 - After successful explosion of the entire top model,
     reset the request_id for top model back to NULL. */

   UPDATE  BOM_EXPLOSIONS
   SET     request_id= NULL
   WHERE   top_bill_sequence_id = x_top_bill_id
   AND     explosion_type = arg_expl_type
   -- Bug 15961704
   --AND     sort_order = Bom_Common_Definitions.G_Bom_Init_SortCode
   AND     request_id = -999;

commit;

EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        arg_error_code  := SQLCODE;
        arg_err_msg	:= 'BOMORXPB Duplicate(' || stmt_num ||'): ' ||
          substrb(SQLERRM,1,60);
        ROLLBACK ;
    WHEN x_loop_detected THEN
	arg_error_code 	:= 9999;
	FND_MESSAGE.Set_Name('BOM', 'BOM_LOOP_EXISTS');
        arg_err_msg     := FND_MESSAGE.GET;
	ROLLBACK;	--bug 2709042
    WHEN x_no_top_assy THEN
	arg_error_code 	:= 9998;
        FND_MESSAGE.Set_Name('BOM', 'BOM_BILL_DOES_NOT_EXIST');
        arg_err_msg     := FND_MESSAGE.GET;
	ROLLBACK;	--bug 2709042
    WHEN x_bom_expl_del THEN
        arg_error_code  := 9997;
        FND_MESSAGE.Set_Name('BOM', 'BOM_EXPL_DEL_IN_PROGRESS');
        FND_MESSAGE.Set_Token('REQUEST_ID', x_req_id);
        arg_err_msg     := FND_MESSAGE.GET;
        ROLLBACK;       --bug 2709042
  /* Fix for bug 9198518- handle below exception which gets thrown
     when bom explosion is already underway.
     Rollback all the changes, then explicitly reset request_id as NULL.*/
    WHEN x_bom_expl_run THEN
        arg_error_code  := 9996;
        FND_MESSAGE.Set_Name('BOM', 'BOM_EXPLOSION_IN_PROGRESS');
        arg_err_msg     := FND_MESSAGE.GET;
        ROLLBACK;

    WHEN update_exp THEN
 	ROLLBACK; --update_exp definition added for bug 8496032
    WHEN OTHERS THEN
        arg_error_code 	:= SQLCODE;
        arg_err_msg	:= 'BOMORXPB(' || stmt_num ||'): ' ||
          substrb(SQLERRM,1,60);
	--ROLLBACK TO SAVEPOINT BE;
	ROLLBACK;	--bug 2709042

END be_exploder;


PROCEDURE delete_config_exp (
	arg_session_id		IN  NUMBER
) is

BEGIN
	DELETE FROM BOM_CONFIG_EXPLOSIONS
	WHERE  SESSION_ID = arg_session_id;
END delete_config_exp;

END bom_oe_exploder_pkg;

/
