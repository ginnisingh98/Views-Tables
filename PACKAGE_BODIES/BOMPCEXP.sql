--------------------------------------------------------
--  DDL for Package Body BOMPCEXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCEXP" AS
/* $Header: BOMCEXPB.pls 120.1.12010000.3 2009/11/09 22:10:05 vbrobbey ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCEXPB.pls						    |
| Description  : This is the costing exploder.  This exploder needs	    |
|		 to join to cst_default_cost_view to get the costing 	    |
|		 attributes.						    |
| Parameters:	org_id		organization_id				    |
|		grp_id		unique value to identify current explosion  |
|				use value from sequence bom_explosion_temp_s|
|		cst_type_id	cost type id				    |
|		err_msg		error message out buffer		    |
|		error_code	error code out.  returns sql error code     |
| History:								    |
|	01-FEB-93  Shreyas Shah  Initial coding				    |
|	06-JUN-93  Shreyas Shah  Scrapped the costing exploder that joined  |
|				 to CST_DEFAULT_COST_VIEW since it was      |
|				 very  slow.  Now just calling bom exploder |
|				 and doing a post explosion update	    |
|       23-JUN-93  Evelyn Tran   Add checking of COMPONENT_YIELD_FLAG when  |
|                                computing extended quantity		    |
|       09/05/96  Robert Yee    Increase Sort Order Width to 4 from 3       |
|				(Bills can have >= 1000 components          |
+==========================================================================*/

PROCEDURE cst_exploder(
	grp_id			IN NUMBER,
	org_id 			IN NUMBER,
	cst_type_id 		IN NUMBER,
	inq_flag		IN NUMBER := 2,
	err_msg			IN OUT NOCOPY VARCHAR2,
	error_code		IN OUT NOCOPY NUMBER) AS

    counter			NUMBER;
    cost_org_id			NUMBER;
    l_comp_yield_flag           NUMBER;
    l_default_cost_type_id      NUMBER;
    l_error_code		NUMBER;
    exploded_levels		NUMBER;
    l_err_msg			VARCHAR2(80);
    X_SortWidth                 number := BOMPBEXP.G_SortWidth; -- 4

/* Added following cursor for Bug 2566842 */

   CURSOR Explosion (c_grp_id  NUMBER,
                     c_counter NUMBER,
                     c_cost_org_id NUMBER,
                     c_org_id NUMBER,
                     c_cst_type_id NUMBER,
                     c_l_comp_yield_flag NUMBER,
                     c_l_default_cost_type_id NUMBER,
                     c_X_SortWidth NUMBER
                    ) IS
   SELECT
     nvl(CIC.ITEM_COST, nvl(CIC_DEF.ITEM_COST, 0)),
     nvl(CIC.BASED_ON_ROLLUP_FLAG,nvl(CIC_DEF.BASED_ON_ROLLUP_FLAG, 2)),
     nvl(CIC.SHRINKAGE_RATE, nvl(CIC_DEF.SHRINKAGE_RATE, 0)),
     (decode(BET.BASIS_TYPE, null, BET1.EXTENDED_QUANTITY, 1) * nvl(BET.COMPONENT_QUANTITY, 0)
                              * (nvl(BET.PLANNING_FACTOR, 100) / 100)
     ) / (decode(c_l_comp_yield_flag, 2, 1,
      decode(nvl(BET.COMPONENT_YIELD_FACTOR, 0), 0, 1,
             nvl(BET.COMPONENT_YIELD_FACTOR, 0)
           )
     ) * (1 - nvl(BET1.SHRINKAGE_RATE, 0))
     ),
     decode(BET1.EXTEND_COST_FLAG, 2, 2,
           decode(BET1.INVENTORY_ASSET_FLAG, 2, 2,
           decode(BET1.BASED_ON_ROLLUP_FLAG, 2, 2,
     decode(BET.INCLUDE_IN_ROLLUP_FLAG, 1, 1, 2)))),
     nvl(CIC.COST_TYPE_ID,
           nvl(CIC_DEF.COST_TYPE_ID, BET1.ACTUAL_COST_TYPE_ID)),
     nvl(CIC.INVENTORY_ASSET_FLAG,
          nvl(CIC_DEF.INVENTORY_ASSET_FLAG, 2)),
     BET.TOP_BILL_SEQUENCE_ID,
     BET.ROWID
   FROM    CST_ITEM_COSTS CIC,
           CST_ITEM_COSTS CIC_DEF,
           BOM_EXPLOSION_TEMP BET_MUST_HAVE,
           BOM_EXPLOSION_TEMP BET1,
           BOM_EXPLOSION_TEMP BET
   WHERE BET1.GROUP_ID = c_grp_id
   AND   BET1.TOP_BILL_SEQUENCE_ID = BET.TOP_BILL_SEQUENCE_ID
   AND   BET1.SORT_ORDER =
       SUBSTR(BET.SORT_ORDER, 1, c_counter*c_X_SortWidth)
   AND   BET_MUST_HAVE.ROWID = BET.ROWID
   AND   CIC.COST_TYPE_ID(+) = c_cst_type_id
   AND   CIC.ORGANIZATION_ID(+) = c_cost_org_id
   AND   CIC.INVENTORY_ITEM_ID(+) =
                  BET_MUST_HAVE.COMPONENT_ITEM_ID
   AND   CIC_DEF.COST_TYPE_ID(+) = c_l_default_cost_type_id
   AND   CIC_DEF.ORGANIZATION_ID(+) = c_cost_org_id
   AND   CIC_DEF.INVENTORY_ITEM_ID(+)
                = BET_MUST_HAVE.COMPONENT_ITEM_ID
   AND BET.GROUP_ID = c_grp_id
   AND   BET.PLAN_LEVEL = c_counter
   AND   EXISTS (SELECT 'Costing must be enabled'
    FROM MTL_SYSTEM_ITEMS
    WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
    AND   ORGANIZATION_ID = c_org_id
    AND   COSTING_ENABLED_FLAG = 'Y');

       /* Added For Bug 6973616.*/
       CURSOR Explosion_small (c_grp_id  NUMBER,
                               c_counter NUMBER,
                               c_cost_org_id NUMBER,
                               c_org_id NUMBER,
                               c_cst_type_id NUMBER,
                               c_l_comp_yield_flag NUMBER,
                               c_l_default_cost_type_id NUMBER,
                               c_X_SortWidth NUMBER)
       IS
       SELECT
         nvl(CIC.ITEM_COST, nvl(CIC_DEF.ITEM_COST, 0)),
         nvl(CIC.BASED_ON_ROLLUP_FLAG,nvl(CIC_DEF.BASED_ON_ROLLUP_FLAG, 2)),
         nvl(CIC.SHRINKAGE_RATE, nvl(CIC_DEF.SHRINKAGE_RATE, 0)),
         (decode(BET.BASIS_TYPE, null, BET1.EXTENDED_QUANTITY, 1)*nvl(BET.COMPONENT_QUANTITY, 0)*(nvl(BET.PLANNING_FACTOR,100)/100))/
          (decode(c_l_comp_yield_flag,2,1,decode(nvl(BET.COMPONENT_YIELD_FACTOR,0),0,1,nvl(BET.COMPONENT_YIELD_FACTOR,0)))*(1-nvl(BET1.SHRINKAGE_RATE,0))),
         decode(BET1.EXTEND_COST_FLAG, 2, 2,decode(BET1.INVENTORY_ASSET_FLAG, 2, 2,decode(BET1.BASED_ON_ROLLUP_FLAG, 2, 2,decode(BET.INCLUDE_IN_ROLLUP_FLAG, 1, 1, 2)))),
         nvl(CIC.COST_TYPE_ID,
         nvl(CIC_DEF.COST_TYPE_ID, BET1.ACTUAL_COST_TYPE_ID)),
         nvl(CIC.INVENTORY_ASSET_FLAG,nvl(CIC_DEF.INVENTORY_ASSET_FLAG, 2)),
         BET.TOP_BILL_SEQUENCE_ID,
         BET.ROWID
       FROM
         CST_ITEM_COSTS CIC,
         CST_ITEM_COSTS CIC_DEF,
         BOM_SMALL_EXPL_TEMP BET_MUST_HAVE,
         BOM_SMALL_EXPL_TEMP BET1,
         BOM_SMALL_EXPL_TEMP BET
       WHERE BET1.GROUP_ID = c_grp_id
       AND   BET1.TOP_BILL_SEQUENCE_ID = BET.TOP_BILL_SEQUENCE_ID
       AND   BET1.SORT_ORDER = SUBSTR(BET.SORT_ORDER, 1, c_counter*c_X_SortWidth)
       AND   BET_MUST_HAVE.ROWID = BET.ROWID
       AND   CIC.COST_TYPE_ID(+) = c_cst_type_id
       AND   CIC.ORGANIZATION_ID(+) = c_cost_org_id
       AND   CIC.INVENTORY_ITEM_ID(+) = BET_MUST_HAVE.COMPONENT_ITEM_ID
       AND   CIC_DEF.COST_TYPE_ID(+) = c_l_default_cost_type_id
       AND   CIC_DEF.ORGANIZATION_ID(+) = c_cost_org_id
       AND   CIC_DEF.INVENTORY_ITEM_ID(+) = BET_MUST_HAVE.COMPONENT_ITEM_ID
       AND BET.GROUP_ID = c_grp_id
       AND   BET.PLAN_LEVEL = c_counter
       AND   EXISTS (SELECT 'Costing must be enabled'
                     FROM MTL_SYSTEM_ITEMS
                     WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                     AND   ORGANIZATION_ID = c_org_id
                     AND   COSTING_ENABLED_FLAG = 'Y');


 TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

 TYPE varchar_tab_tp IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

   l_item_cost       number_tab_tp;
   l_rollup          number_tab_tp;
   l_shrinkage       number_tab_tp;
   l_extnd_qty       number_tab_tp;
   l_extnd_cost      number_tab_tp;
   l_actual_cost     number_tab_tp;
   l_asset_flag      number_tab_tp;
   l_top_bill_id     number_tab_tp;
   l_row_id          varchar_tab_tp;

   Loop_Count_Val        Number := 0;

/* Bug 2566842 */

BEGIN
/*
** select the cost org id
*/
    SELECT COST_ORGANIZATION_ID
	    INTO cost_org_id
	    FROM MTL_PARAMETERS
	    WHERE ORGANIZATION_ID = org_id;

/*
** select COMPONENT_YIELD_FLAG
*/
    SELECT COMPONENT_YIELD_FLAG
    INTO   l_comp_yield_flag
    FROM   CST_COST_TYPES
    WHERE  COST_TYPE_ID = cst_type_id;

/*
** for non-inquiry calls use the bigger temp table
*/
    if (inq_flag = 2) then

/*
** need to update certain columns dependent on the cost rollup
** update level 0 seperately
*/

    UPDATE BOM_EXPLOSION_TEMP BET
        SET (ITEM_COST, BASED_ON_ROLLUP_FLAG, EXTEND_COST_FLAG,
	    ACTUAL_COST_TYPE_ID, SHRINKAGE_RATE, INVENTORY_ASSET_FLAG) =
	    (SELECT /*+ ORDERED
			INDEX (CIC,CST_ITEM_COSTS_U1)
			INDEX (CCT,CST_COST_TYPES_U1)
			USE_NL (CIC CCT) */
		nvl(CIC.ITEM_COST,0),
		nvl(CIC.BASED_ON_ROLLUP_FLAG, 2),
	    DECODE(CIC.INVENTORY_ASSET_FLAG, 2, 2,
		DECODE(CIC.BASED_ON_ROLLUP_FLAG, 1, 1, 2)),
	    nvl(CIC.COST_TYPE_ID, cst_type_id),
	    nvl(CIC.SHRINKAGE_RATE,0),
	    nvl(CIC.INVENTORY_ASSET_FLAG, 2)
	    FROM CST_ITEM_COSTS CIC,
		 CST_COST_TYPES CCT
          Where CIC.ORGANIZATION_ID=NVL(CCT.ORGANIZATION_ID,CIC.ORGANIZATION_ID)
	      AND (((CIC.COST_TYPE_ID = CCT.DEFAULT_COST_TYPE_ID)
	      AND (NOT EXISTS
			(SELECT 'X' FROM CST_ITEM_COSTS CIC2
			 WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
			   AND CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
			   AND CIC2.COST_TYPE_ID = CCT.COST_TYPE_ID)))
			   OR (CIC.COST_TYPE_ID = CCT.COST_TYPE_ID))
	   AND CCT.COST_TYPE_ID(+) = cst_type_id
	   AND   CIC.INVENTORY_ITEM_ID(+) = BET.TOP_ITEM_ID
	   AND   CIC.ORGANIZATION_ID(+) = cost_org_id)
	WHERE GROUP_ID = grp_id
	AND   PLAN_LEVEL = 0;

    SELECT nvl(MAX(PLAN_LEVEL), 0)
        INTO exploded_levels
        FROM BOM_EXPLOSION_TEMP
        WHERE GROUP_ID = grp_id;

    SELECT DEFAULT_COST_TYPE_ID
    INTO l_default_cost_type_id
    FROM cst_cost_types
    WHERE COST_TYPE_ID = cst_type_id;

/* Bug 2566842 */

  FOR counter IN 1..exploded_levels LOOP

--      Delete pl/sql tables.

   l_item_cost.delete;
   l_rollup.delete;
   l_shrinkage.delete;
   l_extnd_qty.delete;
   l_extnd_cost.delete;
   l_actual_cost.delete;
   l_asset_flag.delete;
   l_top_bill_id.delete;
   l_row_id.delete;


    IF not Explosion%isopen then
       open explosion( grp_id,
                     counter,
                     cost_org_id,
                     org_id,
                     cst_type_id,
                     l_comp_yield_flag,
                     l_default_cost_type_id,
                     X_SortWidth);
    End if;

    FETCH Explosion bulk collect into
          l_item_cost,
          l_rollup,
          l_shrinkage,
          l_extnd_qty,
          l_extnd_cost,
          l_actual_cost,
          l_asset_flag,
          l_top_bill_id,
          l_row_id;

   loop_count_val   := explosion%rowcount;

   CLOSE Explosion;


      FORALL i IN 1..loop_count_val

    	UPDATE BOM_EXPLOSION_TEMP BET
	    SET ITEM_COST   = l_item_cost(i),
                 BASED_ON_ROLLUP_FLAG = l_rollup(i),
		 SHRINKAGE_RATE = l_shrinkage(i),
                 EXTENDED_QUANTITY = l_extnd_qty(i),
                 EXTEND_COST_FLAG = l_extnd_cost(i),
		 ACTUAL_COST_TYPE_ID = l_actual_cost(i),
                 INVENTORY_ASSET_FLAG = l_asset_flag(i)
	    WHERE BET.GROUP_ID = grp_id
	    AND   BET.PLAN_LEVEL = counter
            AND   BET.TOP_BILL_SEQUENCE_ID = l_top_bill_id(i)
            AND   BET.ROWID = l_row_id(i)
	    AND   EXISTS (SELECT 'Costing must be enabled'
		FROM MTL_SYSTEM_ITEMS
		WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
		AND   ORGANIZATION_ID = org_id);
    END LOOP;

/* Bug 2566842 */

/*
    FOR counter IN 1..exploded_levels LOOP
    	UPDATE BOM_EXPLOSION_TEMP BET
	    SET (ITEM_COST,
                 BASED_ON_ROLLUP_FLAG,
		 SHRINKAGE_RATE,
                 EXTENDED_QUANTITY,
                 EXTEND_COST_FLAG,
		 ACTUAL_COST_TYPE_ID,
                 INVENTORY_ASSET_FLAG) =
             (SELECT
                 nvl(CIC.ITEM_COST, nvl(CIC_DEF.ITEM_COST, 0)),
		 nvl(CIC.BASED_ON_ROLLUP_FLAG,
                           nvl(CIC_DEF.BASED_ON_ROLLUP_FLAG, 2)),
		 nvl(CIC.SHRINKAGE_RATE, nvl(CIC_DEF.SHRINKAGE_RATE, 0)),
		 (BET1.EXTENDED_QUANTITY * nvl(BET.COMPONENT_QUANTITY, 0)
		     * (nvl(BET.PLANNING_FACTOR, 100) / 100)
		    ) / (decode(l_comp_yield_flag, 2, 1,
		 	     decode(nvl(BET.COMPONENT_YIELD_FACTOR, 0), 0, 1,
				nvl(BET.COMPONENT_YIELD_FACTOR, 0)
			     )
		 	  )
			 *
			 (1 - nvl(BET1.SHRINKAGE_RATE, 0))
		    ),
		 decode(BET1.EXTEND_COST_FLAG, 2, 2,
		    decode(BET1.INVENTORY_ASSET_FLAG, 2, 2,
		    decode(BET1.BASED_ON_ROLLUP_FLAG, 2, 2,
		    decode(BET.INCLUDE_IN_ROLLUP_FLAG, 1, 1, 2)))),
		nvl(CIC.COST_TYPE_ID,
                         nvl(CIC_DEF.COST_TYPE_ID, BET1.ACTUAL_COST_TYPE_ID)),
		nvl(CIC.INVENTORY_ASSET_FLAG,
                         nvl(CIC_DEF.INVENTORY_ASSET_FLAG, 2))
		FROM 	CST_ITEM_COSTS CIC,
			CST_ITEM_COSTS CIC_DEF,
                        BOM_EXPLOSION_TEMP BET_MUST_HAVE,
			BOM_EXPLOSION_TEMP BET1
		WHERE BET1.GROUP_ID = grp_id
		AND   BET1.TOP_BILL_SEQUENCE_ID = BET.TOP_BILL_SEQUENCE_ID
		AND   BET1.SORT_ORDER =
                      SUBSTR(BET.SORT_ORDER, 1, counter*X_SortWidth)
		AND   BET_MUST_HAVE.ROWID = BET.ROWID
		AND   CIC.COST_TYPE_ID(+) = cst_type_id
		AND   CIC.ORGANIZATION_ID(+) = cost_org_id
		AND   CIC.INVENTORY_ITEM_ID(+) =
                                 BET_MUST_HAVE.COMPONENT_ITEM_ID
		AND   CIC_DEF.COST_TYPE_ID(+) = l_default_cost_type_id
		AND   CIC_DEF.ORGANIZATION_ID(+) = cost_org_id
		AND   CIC_DEF.INVENTORY_ITEM_ID(+)
                               = BET_MUST_HAVE.COMPONENT_ITEM_ID)
	    WHERE BET.GROUP_ID = grp_id
	    AND   BET.PLAN_LEVEL = counter
	    AND   EXISTS (SELECT 'Costing must be enabled'
		FROM MTL_SYSTEM_ITEMS
		WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
		AND   ORGANIZATION_ID = org_id
		AND   COSTING_ENABLED_FLAG = 'Y');

    END LOOP;

*/
    else

    UPDATE BOM_SMALL_EXPL_TEMP BET
        SET (ITEM_COST, BASED_ON_ROLLUP_FLAG, EXTEND_COST_FLAG,
	    ACTUAL_COST_TYPE_ID, SHRINKAGE_RATE, INVENTORY_ASSET_FLAG) =
            (SELECT /*+ ORDERED
                        INDEX (CIC,CST_ITEM_COSTS_U1)
                        INDEX (CCT,CST_COST_TYPES_U1)
                        USE_NL (CIC CCT) */
	    	nvl(CIC.ITEM_COST,0),
		nvl(CIC.BASED_ON_ROLLUP_FLAG, 2),
	    DECODE(CIC.INVENTORY_ASSET_FLAG, 2, 2,
		DECODE(CIC.BASED_ON_ROLLUP_FLAG, 1, 1, 2)),
	    nvl(CIC.COST_TYPE_ID, cst_type_id),
	    nvl(CIC.SHRINKAGE_RATE,0),
	    nvl(CIC.INVENTORY_ASSET_FLAG, 2)
            FROM CST_ITEM_COSTS CIC,
                 CST_COST_TYPES CCT
         Where CIC.ORGANIZATION_ID=NVL(CCT.ORGANIZATION_ID,CIC.ORGANIZATION_ID)
              AND (((CIC.COST_TYPE_ID = CCT.DEFAULT_COST_TYPE_ID)
              AND (NOT EXISTS
                        (SELECT 'X' FROM CST_ITEM_COSTS CIC2
                         WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
                           AND CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
                           AND CIC2.COST_TYPE_ID = CCT.COST_TYPE_ID)))
                           OR (CIC.COST_TYPE_ID = CCT.COST_TYPE_ID))
	    AND   CCT.COST_TYPE_ID(+) = cst_type_id
	    AND   CIC.INVENTORY_ITEM_ID(+) = BET.TOP_ITEM_ID
	    AND   CIC.ORGANIZATION_ID(+) = cost_org_id)
	WHERE GROUP_ID = grp_id
	AND   PLAN_LEVEL = 0;

    SELECT nvl(MAX(PLAN_LEVEL), 0)
        INTO exploded_levels
        FROM BOM_SMALL_EXPL_TEMP
        WHERE GROUP_ID = grp_id;
    /*
    FOR counter IN 1..exploded_levels LOOP
    	UPDATE BOM_SMALL_EXPL_TEMP BET
	    SET (ITEM_COST,
                 BASED_ON_ROLLUP_FLAG,
		 SHRINKAGE_RATE,
                 EXTENDED_QUANTITY,
                 EXTEND_COST_FLAG,
		 ACTUAL_COST_TYPE_ID,
                 INVENTORY_ASSET_FLAG) =
             (SELECT
                 nvl(CIC.ITEM_COST, nvl(CIC_DEF.ITEM_COST, 0)),
		 nvl(CIC.BASED_ON_ROLLUP_FLAG,
                           nvl(CIC_DEF.BASED_ON_ROLLUP_FLAG, 2)),
		 nvl(CIC.SHRINKAGE_RATE, nvl(CIC_DEF.SHRINKAGE_RATE, 0)),
		 (BET1.EXTENDED_QUANTITY * nvl(BET.COMPONENT_QUANTITY, 0)
		     * (nvl(BET.PLANNING_FACTOR, 100) / 100)
		    ) / (decode(l_comp_yield_flag, 2, 1,
		 	     decode(nvl(BET.COMPONENT_YIELD_FACTOR, 0), 0, 1,
				nvl(BET.COMPONENT_YIELD_FACTOR, 0)
			     )
		 	  )
			 *
			 (1 - nvl(BET1.SHRINKAGE_RATE, 0))
		    ),
		 decode(BET1.EXTEND_COST_FLAG, 2, 2,
		    decode(BET1.INVENTORY_ASSET_FLAG, 2, 2,
		    decode(BET1.BASED_ON_ROLLUP_FLAG, 2, 2,
		    decode(BET.INCLUDE_IN_ROLLUP_FLAG, 1, 1, 2)))),
		nvl(CIC.COST_TYPE_ID,
                         nvl(CIC_DEF.COST_TYPE_ID, BET1.ACTUAL_COST_TYPE_ID)),
		nvl(CIC.INVENTORY_ASSET_FLAG,
                         nvl(CIC_DEF.INVENTORY_ASSET_FLAG, 2))
		FROM 	CST_ITEM_COSTS CIC,
			CST_ITEM_COSTS CIC_DEF,
			BOM_SMALL_EXPL_TEMP BET_MUST_HAVE,
                        BOM_SMALL_EXPL_TEMP BET1
		WHERE BET1.GROUP_ID = grp_id
		AND   BET1.TOP_BILL_SEQUENCE_ID = BET.TOP_BILL_SEQUENCE_ID
		AND   BET1.SORT_ORDER =
                      SUBSTR(BET.SORT_ORDER, 1, counter*X_SortWidth)
		AND   BET_MUST_HAVE.ROWID = BET.ROWID
		AND   CIC.COST_TYPE_ID(+) = cst_type_id
		AND   CIC.ORGANIZATION_ID(+) = cost_org_id
		AND   CIC.INVENTORY_ITEM_ID(+) =
                                 BET_MUST_HAVE.COMPONENT_ITEM_ID
		AND   CIC_DEF.COST_TYPE_ID(+) = l_default_cost_type_id
		AND   CIC_DEF.ORGANIZATION_ID(+) = cost_org_id
		AND   CIC_DEF.INVENTORY_ITEM_ID(+)
                               = BET_MUST_HAVE.COMPONENT_ITEM_ID)
	    WHERE BET.GROUP_ID = grp_id
	    AND   BET.PLAN_LEVEL = counter
	    AND   EXISTS (SELECT 'Costing must be enabled'
		FROM MTL_SYSTEM_ITEMS
		WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
		AND   ORGANIZATION_ID = org_id
		AND   COSTING_ENABLED_FLAG = 'Y');

    END LOOP;
    */
  /* Modified For Bug 6973616.*/

       FOR counter IN 1..exploded_levels LOOP

          l_item_cost.delete;
          l_rollup.delete;
          l_shrinkage.delete;
          l_extnd_qty.delete;
          l_extnd_cost.delete;
          l_actual_cost.delete;
          l_asset_flag.delete;
          l_top_bill_id.delete;
          l_row_id.delete;

          IF not Explosion_small%isopen then
             open Explosion_small( grp_id,
                                   counter,
                                   cost_org_id,
                                   org_id,
                                   cst_type_id,
                                   l_comp_yield_flag,
                                   l_default_cost_type_id,
                                   X_SortWidth);
          End if;

          FETCH Explosion_small bulk collect into
                l_item_cost,
                l_rollup,
                l_shrinkage,
                l_extnd_qty,
                l_extnd_cost,
                l_actual_cost,
                l_asset_flag,
                l_top_bill_id,
                l_row_id;

          loop_count_val   := Explosion_small%rowcount;

          CLOSE Explosion_small;

          FORALL i IN 1..loop_count_val

              UPDATE BOM_SMALL_EXPL_TEMP BET SET
                ITEM_COST   = l_item_cost(i),
                BASED_ON_ROLLUP_FLAG = l_rollup(i),
                SHRINKAGE_RATE = l_shrinkage(i),
                EXTENDED_QUANTITY = l_extnd_qty(i),
                EXTEND_COST_FLAG = l_extnd_cost(i),
                ACTUAL_COST_TYPE_ID = l_actual_cost(i),
                INVENTORY_ASSET_FLAG = l_asset_flag(i)
              WHERE BET.GROUP_ID = grp_id
              AND   BET.PLAN_LEVEL = counter
              AND   BET.TOP_BILL_SEQUENCE_ID = l_top_bill_id(i)
              AND   BET.ROWID = l_row_id(i)
              AND   EXISTS (SELECT 'Costing must be enabled'
                            FROM MTL_SYSTEM_ITEMS
                            WHERE INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                            AND   ORGANIZATION_ID = org_id);
       END LOOP;

    end if;
/*
** exception handlers
*/
EXCEPTION
    WHEN OTHERS THEN
	error_code	:= SQLCODE;
	err_msg		:= 'BOMPCEXP:' || substrb(SQLERRM,1,60);

END cst_exploder;

END BOMPCEXP;

/
