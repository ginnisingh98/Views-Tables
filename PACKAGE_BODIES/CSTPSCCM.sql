--------------------------------------------------------
--  DDL for Package Body CSTPSCCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSCCM" AS
/* $Header: CSTSCCMB.pls 120.2 2007/12/19 08:07:23 smsasidh ship $ */

FUNCTION merge_costs (
p_rollup_id             IN      NUMBER,
p_dest_cost_type_id     IN      NUMBER,
p_buy_cost_type_id      IN      NUMBER,
p_inventory_item_id     IN      NUMBER,
p_dest_organization_id  IN      NUMBER,
p_assignment_set_id     IN      NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2,
p_buy_cost_detail       IN      NUMBER  -- SCAPI: option to preserve buy cost details
)
RETURN INTEGER
IS
x_return_code           NUMBER;
l_stmt_num              NUMBER;
l_counter               NUMBER;
curr_org_make_weight    NUMBER;
curr_vendor_buy_weight  NUMBER;
l_count_src_rows        NUMBER;
l_curr_rowid		NUMBER;
t_inventory_item_id	NUMBER;
default_cost_type_id    NUMBER;
default_buy_cost_type_id  NUMBER;
wsm_flag                VARCHAR2(1);


l_user_id           number := -1;
l_login_id          number := -1;
l_request_id        number := -1;
l_prog_appl_id      number := -1;
l_prog_id           number := -1;


CURSOR based_on_rollup_costs_cur (
			l_dest_cost_type_id     NUMBER,
			l_inventory_item_id     NUMBER,
			l_dest_organization_id  NUMBER) IS
	SELECT	cic.inventory_item_id
	FROM	cst_item_costs cic
	WHERE	cic.inventory_item_id = l_inventory_item_id
	AND	cic.organization_id = l_dest_organization_id
	AND	cic.cost_type_id = l_dest_cost_type_id
        /* Bug 2077929 - When no costs are defined for l_dest_cost_type_id,
           the present logic treats this as based_on_rollup_flag=1 and merges costs*/
        /* AND  cic.based_on_rollup_flag = 2; */
	AND	cic.based_on_rollup_flag = 1;

/* Bug 4547027 -Changed the cursor to ignore the Inactive items in the source organization */
CURSOR src_orgs_cur(l_rollup_id IN NUMBER,
                    l_inventory_item_id IN NUMBER,
                    l_dest_organization_id IN NUMBER,
                    l_assignment_set_id IN NUMBER) IS
    SELECT
            cssr.source_organization_id,
            (cssr.allocation_percent/100.00) allocation_factor,
            cssr.markup_code,
            cssr.markup,
	    cssr.ship_charge_code,
	    cssr.ship_charge,
            cssr.conversion_rate,
	    cssr.ship_method
    FROM
            CST_SC_SOURCING_RULES CSSR,
            MTL_SYSTEM_ITEMS MSI,
            BOM_PARAMETERS BP
    WHERE
            CSSR.ROLLUP_ID         = l_rollup_id
    AND     CSSR.inventory_item_id = l_inventory_item_id
    AND     CSSR.organization_id   = l_dest_organization_id
    AND	    CSSR.source_organization_id <> CSSR.organization_id
    AND     CSSR.assignment_set_id = l_assignment_set_id
    AND     CSSR.source_type       = 1
    AND     MSI.inventory_item_id = l_inventory_item_id
    AND     MSI.organization_id = CSSR.source_organization_id
    AND     BP.organization_id (+) = CSSR.source_organization_id
    AND     nvl(MSI.inventory_item_status_code,'NOT'||BP.bom_delete_status_code) <> nvl(BP.bom_delete_status_code,' ');

CURSOR vendors(     l_rollup_id IN NUMBER,
                    l_inventory_item_id IN NUMBER,
                    l_dest_organization_id IN NUMBER,
                    l_assignment_set_id IN NUMBER) IS
    SELECT
	    ROWID,
            vendor_id,
	    vendor_site_id,
            item_cost,
            buy_cost_flag
    FROM
            CST_SC_SOURCING_RULES CSSR
    WHERE
            CSSR.ROLLUP_ID         = l_rollup_id
    AND     CSSR.inventory_item_id = l_inventory_item_id
    AND     CSSR.organization_id   = l_dest_organization_id
    AND     CSSR.assignment_set_id = l_assignment_set_id
    AND     CSSR.source_type       = 3;



BEGIN


        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Merge Routine');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Item = '||p_inventory_item_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Org = '||p_dest_organization_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

    x_return_code := 0;

    l_stmt_num := 1;
        /* Supply chain enhancement: support default cost type */
        SELECT DEFAULT_COST_TYPE_ID
        INTO default_cost_type_id
        FROM CST_COST_TYPES
        WHERE COST_TYPE_ID = p_dest_cost_type_id;

        /* SCAPI: to preserve buy cost details */
        SELECT DEFAULT_COST_TYPE_ID
        INTO default_buy_cost_type_id
        FROM CST_COST_TYPES
        WHERE COST_TYPE_ID = p_buy_cost_type_id;

   /* The Who columns are not being correctly populated using FND_GLOBAL
      structure.
      CST_SC_ROLLUP_HISTORY has the correct information for the rollup_id
    */
   l_stmt_num := 2;

  	select
  	  nvl( min( LAST_UPDATED_BY  ), -1 ),
  	  nvl( min( LAST_UPDATE_LOGIN  ), -1 ),
  	  nvl( min( request_id ), -1 ),
  	  nvl( min( program_application_id ), -1 ),
  	  nvl( min( program_id ), -1 )
  	into
  	  l_user_id,
  	  l_login_id,
  	  l_request_id,
  	  l_prog_appl_id,
  	  l_prog_id
  	from
  	  cst_sc_rollup_history
  	where
  	  rollup_id = p_rollup_id;





    l_stmt_num := 5;
	/* *********************************************************************
	| Not to merge costs for items that have BASED_ON_ROLLUP_FLAG not set
	********************************************************************* */

	OPEN based_on_rollup_costs_cur(
			p_dest_cost_type_id,
                        p_inventory_item_id,
                        p_dest_organization_id);

	FETCH based_on_rollup_costs_cur INTO t_inventory_item_id;
       /* Bug 2077929 - Need to check for NOTFOUND as per modification
          done in cursor defintion */
       /* IF (based_on_rollup_costs_cur%FOUND) THEN */
	IF (based_on_rollup_costs_cur%NOTFOUND) THEN
		CLOSE based_on_rollup_costs_cur;
		x_err_buf := 'CSTPSCCM.remove_rollup_history' ||': Not Merged asbased_on_rollup_flag set to No ';

		RETURN x_return_code;
	END IF;
	CLOSE based_on_rollup_costs_cur;

    l_stmt_num := 10;

    /* **********************************************
    |   Obtain weightage for the current org        |
    |   for the MAKE rules                          |
    ********************************************** */

    SELECT
            SUM(allocation_percent)/100
    INTO
            curr_org_make_weight
    FROM
            CST_SC_SOURCING_RULES CSSC
    WHERE
            CSSC.rollup_id                 = p_rollup_id
    AND     CSSC.assignment_set_id         = p_assignment_set_id
    AND     CSSC.inventory_item_id         = p_inventory_item_id
    AND     CSSC.organization_id           = p_dest_organization_id
    AND     CSSC.source_type               = 2;


     /* *******************************************
        FOR SRC:
                1-txf
                2-make
                3-buy
     ****************************************** */

    l_stmt_num := 20;

    IF(curr_org_make_weight IS NULL OR curr_org_make_weight < 0 ) THEN
        curr_org_make_weight := 0;
    END IF;


    SELECT	count(1)
    INTO	l_count_src_rows
    FROM	CST_SC_SOURCING_RULES CSSR
    WHERE       CSSR.rollup_id 		       = p_rollup_id
    AND     	CSSR.assignment_set_id         = p_assignment_set_id
    AND     	CSSR.inventory_item_id         = p_inventory_item_id
    AND     	CSSR.organization_id           = p_dest_organization_id
    and         ROWNUM                         < 2; /* Added for Bug 5678464 */

   IF (l_count_src_rows = 0 ) THEN
	curr_org_make_weight := 1;
   END IF;




    /* *****************************************************
    |   Reduce CICD rows for the current org by weightage |
    ***************************************************** */
        l_stmt_num := 30;

        UPDATE  CST_ITEM_COST_DETAILS CICD
        SET     ITEM_COST = (ITEM_COST * curr_org_make_weight),
                /* Propagate changes for Bug 2347889
                   Scale the yielded cost also */
                YIELDED_COST = DECODE(YIELDED_COST,NULL,NULL,(YIELDED_COST * curr_org_make_weight)),
		ALLOCATION_PERCENT = curr_org_make_weight*100,
		USAGE_RATE_OR_AMOUNT = (USAGE_RATE_OR_AMOUNT
					* curr_org_make_weight)
        WHERE   CICD.inventory_item_id  = p_inventory_item_id
        AND     CICD.organization_id    = p_dest_organization_id
        AND     CICD.cost_type_id       = p_dest_cost_type_id
        AND     CICD.rollup_source_type NOT IN (1,2)
	-- Bug 2302328: Do not reaverage for user-defined and default rows
        AND     curr_org_make_weight <> 1;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Make Updated = '||SQL%ROWCOUNT);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Alloc = '||curr_org_make_weight);





    FOR vendor_cur IN vendors(  p_rollup_id,
                                p_inventory_item_id,
                                p_dest_organization_id,
                                p_assignment_set_id)
    LOOP

    l_stmt_num := 40;

    /* **********************************************
    |   Obtain weightage for the current org        |
    |   ONLY for Buy items                          |
    ********************************************** */

    SELECT
            NVL(allocation_percent,0)/100
    INTO
            curr_vendor_buy_weight
    FROM
            CST_SC_SOURCING_RULES CSSC
    WHERE
            CSSC.ROWID			   = vendor_cur.ROWID;


     /* *******************************************
        FOR SRC:
                1-txf
                2-make
                3-buy
     ****************************************** */


    l_stmt_num := 50;

    IF(curr_vendor_buy_weight IS NULL OR curr_vendor_buy_weight <0 ) THEN
        curr_vendor_buy_weight := 0;
    END IF;

    IF (curr_vendor_buy_weight <> 0) THEN

    /* *****************************************************
    |   Create CICD rows with Buy Cost                      |
    ***************************************************** */
        l_stmt_num := 60;

        -- SCAPI: option to preserve the buy cost details
        IF (p_buy_cost_detail <> 1 or p_buy_cost_detail is null) THEN
            INSERT INTO CST_ITEM_COST_DETAILS
            (
                inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                yielded_cost,
                source_organization_id,
		vendor_id,
		vendor_site_id,
		allocation_percent
             )
             SELECT
                p_inventory_item_id,
                p_dest_organization_id,
                p_dest_cost_type_id,
                SYSDATE,
                l_user_id,
                SYSDATE, --creation_date,
                l_user_id,
                l_login_id,
                NULL, --operation_sequence_id,
                NULL, --operation_seq_num,
                NULL, --department_id,
                1,  -- level_type = This Level
                NULL, --activity_id,
                NULL, --resource_seq_num,
                NULL, --resource_id,
                NULL, --resource_rate,
                NULL, --item_units,
                NULL, --activity_units,
                (vendor_cur.item_cost * curr_vendor_buy_weight), --usage_rate_or_amount,
                1, -- ALWAYS basis_type= item,
                NULL, --basis_resource_id,
                1, -- Always basis_factor=1,
                1, --net_yield_or_shrinkage_factor,
                (vendor_cur.item_cost * curr_vendor_buy_weight), --item_cost, Item Buy cost,
                1, -- ALways MAT cost_element_id,
                3,  -- rollup_source_type = Always rolled up
                NULL, --activity_context,
                l_request_id,
                l_prog_appl_id,
                l_prog_id,
                SYSDATE, --program_update_date,  Need to put correct one
                NULL, --yielded_cost,
                NULL, --source_organization_id
		NVL(vendor_cur.vendor_id, -1),   -- SCAPI: use -1 if no vendor name
		NVL(vendor_cur.vendor_site_id, -1),
		curr_vendor_buy_weight*100
             FROM
                CST_SC_SOURCING_RULES CSSR
             WHERE
                CSSR.organization_id            = p_dest_organization_id AND
                CSSR.inventory_item_id          = p_inventory_item_id AND
                UPPER(vendor_cur.buy_cost_flag) = 'Y' AND
	     	CSSR.rollup_id 			= p_rollup_id AND
	     	CSSR.ROWID			= vendor_cur.ROWID;

        ELSE
             INSERT INTO CST_ITEM_COST_DETAILS
             (
                inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                yielded_cost,
                source_organization_id,
		vendor_id,
                vendor_site_id,
		allocation_percent
             )
             SELECT
                p_inventory_item_id,
                p_dest_organization_id,
                p_dest_cost_type_id,
                SYSDATE,
                l_user_id,
                SYSDATE,  -- creation_date
                l_user_id, -- create_by
                l_login_id,
                CICD2.operation_sequence_id, --operation_sequence_id,
                CICD2.operation_seq_num, --operation_seq_num,
                CICD2.department_id, --department_id,
                CICD2.level_type,  -- level_type = Always Prev Level
                CICD2.activity_id, --activity_id,
                CICD2.resource_seq_num, --resource_seq_num,
                CICD2.resource_id, --resource_id,
		CICD2.resource_rate, -- resource_rate
                CICD2.item_units,
                CICD2.activity_units,
		(CICD2.item_cost * curr_vendor_buy_weight) / decode(NVL(CICD2.resource_rate,0),0,1,nvl(CICD2.resource_rate, 1)),
								 -- usage_rate_or_amount
                1, -- basis_type, -- Always Item Based
                CICD2.basis_resource_id, -- basis_resource_id,
                1, -- basis_factor, -- Always Item Based
                1, -- net_yield_or_shrinkage_factor,
                CICD2.item_cost * curr_vendor_buy_weight, -- item cost
                CICD2.cost_element_id,
                3,  -- rollup_source_type = Always rolled up
                CICD2.activity_context, --CICD2.activity_context,
                l_request_id,
                l_prog_appl_id,
                l_prog_id,
                SYSDATE, --program_update_date,
                CICD2.yielded_cost * curr_vendor_buy_weight,
                NULL,  -- source_organization_id
                NVL(vendor_cur.vendor_id, -1),   -- SCAPI: use -1 if no vendor name
                NVL(vendor_cur.vendor_site_id, -1),
		curr_vendor_buy_weight*100
             FROM
                CST_ITEM_COST_DETAILS CICD2,
                MTL_PARAMETERS MP
             WHERE
                -- If buy cost type equals destination cost type, do not include rolled-up costs.
                -- This is to get consistent results with the no-buy-cost-detail option.
                CICD2.rollup_source_type <> decode(p_buy_cost_type_id, p_dest_cost_type_id, 3, -1) AND
                CICD2.inventory_item_id     = p_inventory_item_id AND
                CICD2.organization_id       = p_dest_organization_id AND
                MP.organization_id = p_dest_organization_id AND
                (
                   CICD2.cost_type_id = p_buy_cost_type_id
                   OR
                   (
                     CICD2.cost_type_id = default_buy_cost_type_id
                     AND NOT EXISTS (
                     SELECT 'X'
                     FROM CST_ITEM_COSTS CIA3
                     WHERE CIA3.inventory_item_id = p_inventory_item_id
                     AND   CIA3.organization_id = p_dest_organization_id
                     AND   CIA3.cost_type_id = p_buy_cost_type_id)
                   )
                   OR
                   (
                     CICD2.cost_type_id = MP.primary_cost_method
                     AND NOT EXISTS (
                     SELECT 'X'
                     FROM CST_ITEM_COSTS CIA4
                     WHERE CIA4.inventory_item_id = p_inventory_item_id
                     AND   CIA4.organization_id = p_dest_organization_id
                     AND   CIA4.cost_type_id in (p_buy_cost_type_id,default_buy_cost_type_id))
                   )
                );

        END IF;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Buy Inserted = '||SQL%ROWCOUNT);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Vendor = '||vendor_cur.vendor_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Alloc = '||curr_vendor_buy_weight);

    END IF;

    END LOOP;
    /* *****************************************************
    |   Create CICD rows with Weighted Other Org CICD rows |
    ***************************************************** */
   l_stmt_num  := 65;
   SELECT wsm_enabled_flag
   INTO wsm_flag
   FROM MTL_PARAMETERS
   WHERE organization_id = p_dest_organization_id;


    l_stmt_num  := 70;
    l_counter   := 0;

    FOR src_org IN src_orgs_cur(p_rollup_id,
                                p_inventory_item_id,
                                p_dest_organization_id,
                                p_assignment_set_id)
    LOOP

        l_stmt_num := 80;
        l_counter := l_counter + 1;


       INSERT INTO CST_ITEM_COST_DETAILS
            (
                inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                yielded_cost,
                source_organization_id,
		vendor_id,
		allocation_percent,
		ship_method
             )
             SELECT
                CICD2.inventory_item_id,
                p_dest_organization_id,
                p_dest_cost_type_id,
                SYSDATE,
                l_user_id,
                SYSDATE,  -- creation_date
                l_user_id,  -- created_by
                l_login_id,
                NULL, --operation_sequence_id,
                NULL, --operation_seq_num,
                NULL, --department_id,
                2,  -- level_type = Always Prev Level
                NULL, --activity_id,
                NULL, --resource_seq_num,
                NULL, --resource_id,
		CICD2.resource_rate, -- resource_rate
                CICD2.item_units,
                CICD2.activity_units,
		(CICD2.item_cost * NVL(src_org.conversion_rate,1))
			 * src_org.allocation_factor / decode(NVL(CICD2.resource_rate,0),0,1,nvl(CICD2.resource_rate, 1)),
											 -- usage_rate_or_amount
                1, -- basis_type, -- Always Item Based
                NULL, -- basis_resource_id,
                1, -- basis_factor, -- Always Item Based
                1, -- net_yield_or_shrinkage_factor,
                (CICD2.item_cost * NVL(src_org.conversion_rate,1))
		           * src_org.allocation_factor, -- item cost
                CICD2.cost_element_id,
                3,  -- rollup_source_type = Always rolled up
                NULL, --CICD2.activity_context,
                l_request_id,
                l_prog_appl_id,
                l_prog_id,
                SYSDATE, --program_update_date,
                /* Propagate Changes for Bug 2347889 - Scale yielded costs
                   Also, propagate yielded costs only if organization is
                   WSM_ENABLED */
                decode(wsm_flag, 'Y', (CICD2.yielded_cost * NVL(src_org.conversion_rate,1))* src_org.allocation_factor, NULL),
                src_org.source_organization_id,
		NULL,
		src_org.allocation_factor*100,
		src_org.ship_method
        FROM
                CST_ITEM_COST_DETAILS CICD2,
                MTL_PARAMETERS MP
        WHERE
                CICD2.inventory_item_id     = p_inventory_item_id
        AND     CICD2.organization_id       = src_org.source_organization_id
        AND     MP.organization_id = src_org.source_organization_id
        AND     (
                   CICD2.cost_type_id = p_dest_cost_type_id
                   OR
                   (
                     CICD2.cost_type_id = default_cost_type_id
                     AND NOT EXISTS (
                     SELECT 'X'
                     FROM CST_ITEM_COSTS CIA3
                     WHERE CIA3.inventory_item_id = p_inventory_item_id
                     AND   CIA3.organization_id = src_org.source_organization_id
                     AND   CIA3.cost_type_id = p_dest_cost_type_id)
                   )
                   OR
                   (
                     CICD2.cost_type_id = MP.primary_cost_method
                     AND NOT EXISTS (
                     SELECT 'X'
                     FROM CST_ITEM_COSTS CIA4
                     WHERE CIA4.inventory_item_id = p_inventory_item_id
                     AND   CIA4.organization_id = src_org.source_organization_id
                     AND   CIA4.cost_type_id in (p_dest_cost_type_id,default_cost_type_id))
                   )
                );  /* Supply chain enhancement: support default valuation cost type */

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Txf Inserted = '||SQL%ROWCOUNT);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Org = '||src_org.source_organization_id);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Alloc = '||src_org.allocation_factor);



    l_stmt_num := 90;
    /***************************************************************************
    | Insert rows into CICD for Markup and Shipping costs as MOH               |
    ***************************************************************************/

   INSERT INTO CST_ITEM_COST_DETAILS
            (
                inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                yielded_cost,
                source_organization_id,
                vendor_id,
                allocation_percent,
		ship_method
             )
             SELECT
                p_inventory_item_id,
                p_dest_organization_id,
                p_dest_cost_type_id,
                SYSDATE,
                l_user_id,
                SYSDATE, --creation_date,
                l_user_id,
                l_login_id,
                NULL, --operation_sequence_id,
                NULL, --operation_seq_num,
                NULL, --department_id,
                1,  --level_type = THIS Level
                NULL, --activity_id,
                NULL, --resource_seq_num,
			min(MP.default_matl_ovhd_cost_id), --resource_id, /* Supply chain enhancement */
                NULL, --resource_rate,
                NULL, --item_units,
                NULL, --activity_units,
                DECODE(src_org.MARKUP_CODE,
                        2,
                        src_org.MARKUP ,
                        3,
                        SUM(CICD2.ITEM_COST)*(src_org.MARKUP/100),
                        4,
                        SUM(CICD2.ITEM_COST)*(src_org.MARKUP/100)), --usage_rate_or_amount,
                1, -- ALWAYS basis_type= item,
                NULL, --basis_resource_id,
                1, -- Always basis_factor=1,
                1, --net_yield_or_shrinkage_factor,
                DECODE(src_org.MARKUP_CODE,
                	2,
                	src_org.MARKUP ,
                	3,
                	SUM(CICD2.ITEM_COST)*(src_org.MARKUP/100) ,
                	4,
                	SUM(CICD2.ITEM_COST)*(src_org.MARKUP/100)), --item_cost,
                2, -- ALways MOH cost_element_id,
                3,  -- rollup_source_type = Always rolled up
                NULL, --activity_context,
                l_request_id,
                l_prog_appl_id,
                l_prog_id,
                SYSDATE, --program_update_date, /* Need to put correct one */
                NULL, --yielded_cost,
                src_org.source_organization_id, -- source_organization_id
		NULL,
		src_org.allocation_factor * 100,
		src_org.ship_method
        FROM
                CST_ITEM_COST_DETAILS CICD2,
                MTL_PARAMETERS MP
        WHERE
                CICD2.inventory_item_id = p_inventory_item_id
        AND     CICD2.organization_id   = p_dest_organization_id
        AND     CICD2.cost_type_id = p_dest_cost_type_id
        AND     CICD2.source_organization_id = src_org.source_organization_id
        AND     CICD2.rollup_source_type = 3
        AND     MP.organization_id = p_dest_organization_id
        AND     src_org.MARKUP IS NOT NULL
        AND     src_org.MARKUP_CODE IN (2, 3, 4)
        AND     src_org.MARKUP <> 0
        GROUP BY CICD2.inventory_item_id, CICD2.organization_id, MP.organization_id
        HAVING SUM(CICD2.ITEM_COST) > 0

        UNION ALL

             SELECT
                p_inventory_item_id,
                p_dest_organization_id,
                p_dest_cost_type_id,
                SYSDATE,
                l_user_id,
                SYSDATE, --creation_date,
                l_user_id,
                l_login_id,
                NULL, --operation_sequence_id,
                NULL, --operation_seq_num,
                NULL, --department_id,
                1,  -- level_type = THIS Level
                NULL, --activity_id,
                NULL, --resource_seq_num,
                min(MP.default_matl_ovhd_cost_id), --resource_id,  /* Supply chain enhancement */
                NULL, --resource_rate,
                NULL, --item_units,
                NULL, --activity_units,
                DECODE(src_org.SHIP_CHARGE_CODE,
                2,
                src_org.SHIP_CHARGE ,
                3,
                SUM(CICD2.ITEM_COST)*(src_org.SHIP_CHARGE/100),0), --usage_rate_or_amount,
                1, -- ALWAYS basis_type= item,
                NULL, --basis_resource_id,
                1, -- Always basis_factor=1,
                1, --net_yield_or_shrinkage_factor,
		DECODE(src_org.SHIP_CHARGE_CODE,
		2,
		src_org.SHIP_CHARGE ,
		3,
                SUM(CICD2.ITEM_COST)*(src_org.SHIP_CHARGE/100),0), --item_cost,
                2, -- ALways MOH cost_element_id,
                3,  -- rollup_source_type = Always rolled up
                NULL, --activity_context,
                l_request_id,
                l_prog_appl_id,
                l_prog_id,
                SYSDATE, --program_update_date, /* Need to put correct one */
                NULL, --yielded_cost,
                src_org.source_organization_id, -- source_organization_id
		NULL,
		src_org.allocation_factor * 100,
		src_org.ship_method
        FROM
                CST_ITEM_COST_DETAILS CICD2,
                MTL_PARAMETERS MP
        WHERE
                CICD2.inventory_item_id = p_inventory_item_id
        AND     CICD2.organization_id   = p_dest_organization_id
        AND     CICD2.cost_type_id = p_dest_cost_type_id
        AND     CICD2.source_organization_id = src_org.source_organization_id
        AND     CICD2.rollup_source_type = 3
        AND     MP.organization_id = p_dest_organization_id
        AND     src_org.SHIP_CHARGE IS NOT NULL
        AND     src_org.SHIP_CHARGE_CODE in (2, 3)
        AND     src_org.SHIP_CHARGE <> 0
        GROUP BY CICD2.inventory_item_id, CICD2.organization_id, MP.organization_id
        HAVING SUM(CICD2.ITEM_COST) > 0;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Markup and Ship Inserted = '||SQL%ROWCOUNT);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Org = '||src_org.source_organization_id);


END LOOP;

    x_return_code := 0;
    x_err_buf := 'CSTPSCCM.merge_costs' ||': Returned Success';
    return x_return_code;

EXCEPTION
    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'CSTPSCCM.merge_costs' ||'stmt_num='||l_stmt_num||' : '||substrb(sqlerrm,1,1000);
	--dbms_output.put_line(x_err_buf);
	--dbms_output.put_line(to_char(x_return_code));

        return x_return_code;


END merge_costs;


FUNCTION remove_rollup_history (
p_rollup_id             IN      NUMBER,
p_sc_cost_type_id	IN	NUMBER,
p_rollup_option		IN	NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
)
RETURN INTEGER
IS
l_stmt_num	NUMBER;
x_return_code	NUMBER;

BEGIN

    x_return_code := 0;

    l_stmt_num := 10;

    -- SCAPI: delete data of previous reports including the consolidated report
    DELETE	CST_SC_BOM_STRUCTURES CSBS
    WHERE	CSBS.ROLLUP_ID  IN 	(
			SELECT	CSRH.ROLLUP_ID
			FROM	CST_SC_ROLLUP_HISTORY CSRH
			WHERE	CSRH.ROLLUP_ID <> p_rollup_id
			AND	CSRH.COST_TYPE_ID = p_sc_cost_type_id
                        UNION
			SELECT	-1*CSRH.ROLLUP_ID
			FROM	CST_SC_ROLLUP_HISTORY CSRH
			WHERE	CSRH.ROLLUP_ID <> p_rollup_id
			AND	CSRH.COST_TYPE_ID = p_sc_cost_type_id
                                        )
    AND		(CSBS.COMPONENT_ITEM_ID,
		CSBS.COMPONENT_ORGANIZATION_ID)
    		IN
		(SELECT	CSBS1.COMPONENT_ITEM_ID,
			CSBS1.COMPONENT_ORGANIZATION_ID
		FROM	CST_SC_BOM_STRUCTURES CSBS1,
			CST_SC_LOW_LEVEL_CODES CSLLC
		WHERE	CSBS1.ROLLUP_ID	= p_rollup_id
		AND	CSBS1.ROLLUP_ID = CSLLC.ROLLUP_ID
		AND	CSBS1.COMPONENT_ITEM_ID = CSLLC.INVENTORY_ITEM_ID
		AND	CSBS1.COMPONENT_ORGANIZATION_ID = CSLLC.ORGANIZATION_ID);

    l_stmt_num := 20;

    DELETE      CST_SC_BOM_EXPLOSION CSBE
    WHERE       CSBE.ROLLUP_ID  IN (
                        SELECT  CSRH.ROLLUP_ID
                        FROM    CST_SC_ROLLUP_HISTORY CSRH
                        WHERE   CSRH.ROLLUP_ID <> p_rollup_id
                        AND     CSRH.COST_TYPE_ID = p_sc_cost_type_id)
    AND         (CSBE.COMPONENT_ITEM_ID,
                CSBE.COMPONENT_ORGANIZATION_ID)
                IN
                (SELECT CSBE1.COMPONENT_ITEM_ID,
                        CSBE1.COMPONENT_ORGANIZATION_ID
                FROM    CST_SC_BOM_EXPLOSION CSBE1,
                        CST_SC_LOW_LEVEL_CODES CSLLC
                WHERE   CSBE1.ROLLUP_ID = p_rollup_id
                AND     CSBE1.ROLLUP_ID = CSLLC.ROLLUP_ID
                AND     CSBE1.COMPONENT_ITEM_ID = CSLLC.INVENTORY_ITEM_ID
                AND     CSBE1.COMPONENT_ORGANIZATION_ID = CSLLC.ORGANIZATION_ID);

    l_stmt_num := 30;

    DELETE      CST_SC_SOURCING_RULES CSSR
    WHERE       CSSR.ROLLUP_ID  IN (
                        SELECT  CSRH.ROLLUP_ID
                        FROM    CST_SC_ROLLUP_HISTORY CSRH
                        WHERE   CSRH.ROLLUP_ID <> p_rollup_id
                        AND     CSRH.COST_TYPE_ID = p_sc_cost_type_id)
    AND         (CSSR.INVENTORY_ITEM_ID,
                CSSR.ORGANIZATION_ID)
                IN
                (SELECT CSSR1.INVENTORY_ITEM_ID,
                        CSSR1.ORGANIZATION_ID
                FROM    CST_SC_SOURCING_RULES CSSR1,
			CST_SC_LOW_LEVEL_CODES CSLLC
                WHERE   CSSR1.ROLLUP_ID = p_rollup_id
                AND     CSSR1.ROLLUP_ID = CSLLC.ROLLUP_ID
                AND     CSSR1.INVENTORY_ITEM_ID = CSLLC.INVENTORY_ITEM_ID
                AND     CSSR1.ORGANIZATION_ID = CSLLC.ORGANIZATION_ID);

    l_stmt_num := 40;

    DELETE      CST_SC_LOW_LEVEL_CODES CSLLC
    WHERE       CSLLC.ROLLUP_ID  IN (
                        SELECT  CSRH.ROLLUP_ID
                        FROM    CST_SC_ROLLUP_HISTORY CSRH
                        WHERE   CSRH.ROLLUP_ID <> p_rollup_id
                        AND     CSRH.COST_TYPE_ID = p_sc_cost_type_id)
    AND         (CSLLC.INVENTORY_ITEM_ID,
                CSLLC.ORGANIZATION_ID)
                IN
                (SELECT CSLLC1.INVENTORY_ITEM_ID,
                        CSLLC1.ORGANIZATION_ID
                FROM    CST_SC_LOW_LEVEL_CODES CSLLC1
                WHERE   CSLLC1.ROLLUP_ID       = p_rollup_id);

    -- SCAPI: need to delete CST_SC_LISTS also
    l_stmt_num := 50;

    DELETE      CST_SC_LISTS CSL
    WHERE       CSL.ROLLUP_ID  IN (
                        SELECT  CSRH.ROLLUP_ID
                        FROM    CST_SC_ROLLUP_HISTORY CSRH
                        WHERE   CSRH.ROLLUP_ID <> p_rollup_id
                        AND     CSRH.COST_TYPE_ID = p_sc_cost_type_id)
    AND         (CSL.INVENTORY_ITEM_ID,
                CSL.ORGANIZATION_ID)
                IN
                (SELECT CSL1.INVENTORY_ITEM_ID,
                        CSL1.ORGANIZATION_ID
                FROM    CST_SC_LISTS CSL1,
                        CST_SC_LOW_LEVEL_CODES CSLLC
                WHERE   CSL1.ROLLUP_ID = p_rollup_id
                AND     CSL1.ROLLUP_ID = CSLLC.ROLLUP_ID
                AND     CSL1.INVENTORY_ITEM_ID = CSLLC.INVENTORY_ITEM_ID
                AND     CSL1.ORGANIZATION_ID = CSLLC.ORGANIZATION_ID);

    x_return_code := 0;
    x_err_buf := 'CSTPSCCM.remove_rollup_history' ||': Returned Success';
    return x_return_code;

EXCEPTION
    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_err_buf := 'CSTPSCCM.remove_rollup_history' ||'stmt_num='||l_stmt_num||' : '||substrb(sqlerrm,1,240);

        return x_return_code;


END remove_rollup_history;

/* Added for Bug 5678464 */
PROCEDURE proc_remove_rollup_history(
x_err_buf               OUT NOCOPY     VARCHAR2,
retcode                 OUT NOCOPY     NUMBER,
p_rollup_id             IN      VARCHAR2,
p_sc_cost_type_id	IN	VARCHAR2,
p_rollup_option		IN	VARCHAR2

) IS


BEGIN
  retcode := CSTPSCCM.remove_rollup_history
  (
    p_rollup_id       => to_number(p_rollup_id),
    p_sc_cost_type_id => to_number(p_sc_cost_type_id),
    p_rollup_option   => to_number(p_rollup_option),
    x_err_buf         => x_err_buf
  );
END proc_remove_rollup_history;

END CSTPSCCM;

/
