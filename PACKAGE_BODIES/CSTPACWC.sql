--------------------------------------------------------
--  DDL for Package Body CSTPACWC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACWC" AS
/* $Header: CSTPACCB.pls 120.8.12010000.7 2009/05/26 10:46:45 mpuranik ship $ */

PROCEDURE complete (
 i_trx_id               IN      NUMBER,
 i_txn_qty		IN	NUMBER,
 i_txn_date		IN   	DATE,
 i_acct_period_id       IN      NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_org_id               IN      NUMBER,
 i_inv_item_id          IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 i_res_cost_type_id     IN      NUMBER,
 i_final_comp_flag      IN      VARCHAR2,
 i_layer_id		IN	NUMBER,
 i_movhd_cost_type_id	OUT NOCOPY	NUMBER,
 i_cost_group_id        IN      NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2)

is

 l_auto_final_comp_condition	VARCHAR2(1);
 l_auto_final_comp		VARCHAR2(1);
 l_comp_cost_source		NUMBER;
 l_c_cost_type_id		NUMBER;
 l_system_option_id		NUMBER;
 l_lot_size			NUMBER;
 l_insert_ind			NUMBER;
 l_use_val_cost_type		NUMBER;
 l_acct_period_id		NUMBER;
 l_wcti_txn_id			NUMBER;
 l_count			NUMBER;
 stmt_num			NUMBER;
 l_err_num               	NUMBER;
 l_err_code              	VARCHAR2(240);
 l_err_msg               	VARCHAR2(240);
 proc_fail			EXCEPTION;
 l_future_issued_qty            NUMBER := 0 ; /* Added as bugfix 2158763 */
 l_include_comp_yield           NUMBER;
 l_cost_element                 NUMBER; /* 2937695 */
 l_job_value                    NUMBER; /* 2937695 */
 l_qty_per_assy                 NUMBER; /* bug 3504776 */

 /* Cursor added for bug 2158763 */
 CURSOR c_wip_req_op IS
      SELECT
         wip_entity_id,
         organization_id,
         inventory_item_id,
         operation_seq_num,
         wip_supply_type
      FROM
         wip_requirement_operations wro
      WHERE
         --
         -- Exclude bulk, supplier, phantom
         --
         wro.wip_supply_type   not in  (4,5,6)         AND
         wro.wip_entity_id     =       i_wip_entity_id AND
         wro.organization_id   =       i_org_id        AND
         wro.quantity_per_assembly     <> 0;

  /*Bug6734270: Final completion cursor should not bother
     about the quantity per assembly and flush every component
     if it has value
    */
   CURSOR c_wip_final_req_op IS
         SELECT
            wip_entity_id,
            organization_id,
            inventory_item_id,
            operation_seq_num,
            wip_supply_type
         FROM
            wip_requirement_operations wro
         WHERE
            wro.wip_entity_id     =       i_wip_entity_id AND
            wro.organization_id   =       i_org_id ;


 /* 2937695 */
 CURSOR c_cost_elements IS
      SELECT
         cost_element_id,
         sum(
                nvl(applied_matl_value,0) -
                nvl(relieved_matl_completion_value,0) -
                nvl(relieved_variance_value,0) -
                nvl(relieved_matl_scrap_value,0)
            )
      FROM
         wip_req_operation_cost_details
      WHERE
         wip_entity_id = i_wip_entity_id
      GROUP BY
         cost_element_id;
 BEGIN

-- The Algorithm for the Completion processing is as below.

/****************************************************************************
*  									    *
*  Is this a  final comp ?   ----> Flush all costs in Job!		    *
*		||            YES      and STOP.			    *
*		|| NO                  					    *
*	        \/                     					    *
*	Dynamically derive (use cost type spec.)			    *
*	comp. costs ??  ------------------------>  Derive completion costs  *
*   YES	    ||               NO			   from cost type.	    *
*	    \/   				   and STOP.    /\	    *
*	Is this a job with no				        || YES      *
*	Routing and NO Bill?? ------------------------------------	    *
*	   	||		(use valuation cost type)		    *
*		|| NO 							    *
*		\/							    *
*	Derive completion costs 					    *
*   	based on incurred costs of Job and STOP!			    *
*									    *
****************************************************************************/


-- Set temp_relieved_value to zero in all tables.



        stmt_num := 10;

        UPDATE wip_req_operation_cost_details
        SET temp_relieved_value = 0
        WHERE
        WIP_ENTITY_ID = i_wip_entity_id AND
        ORGANIZATION_ID = i_org_id;

        stmt_num := 20;

        UPDATE WIP_OPERATION_RESOURCES
        SET temp_relieved_value = 0
        WHERE
        WIP_ENTITY_ID = i_wip_entity_id AND
        ORGANIZATION_ID = i_org_id;

        stmt_num := 30;

        UPDATE WIP_OPERATION_OVERHEADS
        SET temp_relieved_value = 0
        WHERE
        WIP_ENTITY_ID = i_wip_entity_id AND
        ORGANIZATION_ID = i_org_id;


        stmt_num := 50;

        select wac.completion_cost_source, nvl(wac.cost_type_id,-1),
               wdj.start_quantity,nvl(wac.SYSTEM_OPTION_ID,-1)
        into l_comp_cost_source,l_c_cost_type_id,l_lot_size,l_system_option_id
        from
        wip_accounting_classes wac,
        wip_discrete_jobs wdj
        where
        wdj.wip_entity_id		=	i_wip_entity_id		and
        wdj.organization_id		=	i_org_id		and
        wdj.class_code			=	wac.class_code		and
        wdj.organization_id		=	wac.organization_id;


        stmt_num := 80;

        /*---------------------------------------------------
        | If a non-std job has no bill or routing associated
        | with it or if a std job has no bill or routing
        | associated with it - these need to be treated
        | specially.
        |-----------------------------------------------------+*/

        SELECT
        decode(job_type,
               1,decode(bom_revision,
                        NULL,decode(routing_revision,NULL,-1,1),
                        1),
               3,decode(bom_reference_id,
                        NULL,decode(routing_reference_id,NULL,-1,1),
                        1),
               1)
        into
        l_use_val_cost_type
        from
        WIP_DISCRETE_JOBS
        WHERE
        WIP_ENTITY_ID		=		i_wip_entity_id		AND
        ORGANIZATION_ID		=		i_org_id;

        /* Bug 3504776 - the standard material requirements can be added manually for the job.
           In this case, we want to derive the completion costs based on job costs */
        if (l_use_val_cost_type = -1) then
        /* Commented for Bug6734270.If there is a resource added manually
           then also the l_use_val_cost_type should be 1
           select count(*)
           into l_qty_per_assy
           from wip_requirement_operations
           where wip_entity_id = i_wip_entity_id
           and quantity_per_assembly <>0;
         */
            SELECT count(1)
            INTO   l_qty_per_assy
            FROM   dual
            WHERE  EXISTS ( SELECT NULL
                            FROM   wip_requirement_operations wro
                            WHERE  wro.wip_entity_id = i_wip_entity_id
                            AND    wro.quantity_per_assembly <>0
                                UNION ALL
                            SELECT NULL
                            FROM   wip_operation_resources wor
                            WHERE  wor.wip_entity_id = i_wip_entity_id
                            AND    wor.usage_rate_or_amount <>0
                           );


           if (l_qty_per_assy > 0) then
              l_use_val_cost_type := 1;
           end if;
        end if;

        /*----------------------------------------------
        | If the completions are costed by the system, we
        | follow the system rules for earning material
        | ovhd upon completion. If the completion is
        | costed by the cost type then we will earn
        | material overhead based on the costs in the cost type
        | We need to figure out, for the given job, where the
        | costs are coming from and hence how MO is to be
        | earned. This info will passed back to the calling
        | rotuine and used by the cost processor.
        |--------------------------------------------------+*/

        stmt_num := 90;

        IF (l_comp_cost_source=1) THEN
        i_movhd_cost_type_id:= i_res_cost_type_id;
        ELSE i_movhd_cost_type_id:=l_c_cost_type_id;
        END IF;


        /*-------------------------------------------------------------+
        | Initialize insert indicator : This will indicate to us if we
        | need to insert a row into cst_txn_cost_details in the last
        | step. There are cases where the algorithm inserts into
        | cst_txn_cost_details without updating the detailed wip
        | tables. In these cases
        | we will directly insert into cst_txn_cost_details
        | and so we need to skip the insert stmt in
        | the end.
        |--------------------------------------------------------------*/

        l_insert_ind := 0;


        /***********************************************************
        * If this is a  final completion ==>			   *
        * Relieve all costs:		   			   *
        * 							   *
        * CASE 1: Applicable if regular completions are costed     *
        *	  based on the system derived costs		   *
        *  	  and the job has a bill and/or routing		   *
        * -------------------------------------------------------  *
        * 1. If there is value to relieve - flush it out ans set   *
        *    any available units to zero.			   *
        * 2. If there is no value to relieve, but there are units  *
        *    to relieve, flush units out.			   *
        * 3. If there are no units, there is no value, so STOP.	   *
        *							   *
        * CASE 2 : Applicable if the regular completions are based *
        *          on the user specified costs (in a cost type)	   *
        * 	   OR						   *
        *	   regular completions are SYSTEM derived and the  *
        *	   the job has no bill and no routing.		   *
        * -------------------------------------------------------  *
        * In this case, we do not maintain costs for resources,    *
        * ovhds, components in our tables. We go to wip_period_ba- *
        * lances to figure out the residual costs in the Job.	   *
        *							   *
        * Note :						   *
        * For automatic final completion, the condition is	   *
        * satisfied if :					   *
        * Completed_quantity + Scrapped quantity >= Job qtty	   *
        * This is needed because for Jobs with no routings it is   *
        * possible to overcomplete in WIP, so the condition may be *
        * satified multiple times. We will flush out costs for all *
        * instances of the condition being satisfied.		   *
        * We however, do not have to worry about computing this    *
        * since WIP code checks this condition before commiting a  *
        * a completion transaction and flags the completion as a   *
        * final completion.					   *
        ***********************************************************/

 --
 -- 			Actual Logic begins here.
 --

     IF (i_final_comp_flag = 'Y' AND l_comp_cost_source = 1
            AND l_use_val_cost_type <> -1) THEN

        /*---------------------------------------------------------
        | This is for Case 1 explained above ...		  |
        | i.e. This is a FINAL COMP and regular completions are	  |
        | costed by the system AND the job has a bill and/or 	  |
        | routing.						  |
        ----------------------------------------------------------*/

        /*-----------------------------------------------------
        New Final Completion Algorithm
        ------------------------------

        IF the total InValue (Applied value - completion Value - Scrap Value)
                of all the sub-elements (operation level) > 0

        THEN   	Flush out all the cost in all the sub-elements
                even though it MIGHT drive some of the InValue of
                the sub-elements to -ve
        ------------------------------------------------------*/

        /*******************************************************
        * Flush out PL costs and units ...		       *
        * If we have components with a -ve qtty_per_assembly   *
        * Then the relieved_value will be -ve ==> Hence check  *
        * the Available Value to Relieve based on  the 	       *
        * SIGN(quantity_per_assembly); However, if the 	       *
        * quantity_per_assembly = 0 then we assume a +ve value *
        *******************************************************/

	/* Bug 4246122: Included l_future_issued_qty for final
           completion also.Update of WRO is now in loop */
     FOR wro_rec IN c_wip_final_req_op LOOP

      l_future_issued_qty := 0;

      BEGIN
        stmt_num := 100;
            SELECT   nvl(sum(primary_quantity),0)
            INTO     l_future_issued_qty
            FROM     mtl_material_transactions
            WHERE    organization_id = wro_rec.organization_id
            AND      inventory_item_id = wro_rec.inventory_item_id
            AND      operation_seq_num = wro_rec.operation_seq_num
            AND      transaction_source_id = wro_rec.wip_entity_id
            AND      ( (transaction_date > i_txn_date) or
                       (transaction_date = i_txn_date and transaction_id > i_trx_id) )
            AND      costed_flag IS NOT NULL
            AND      nvl(completion_transaction_id,-999) <>
                        ( Select   nvl(completion_transaction_id,-999)
                          from     mtl_material_transactions
                          where    transaction_id = i_trx_id);
         EXCEPTION
           WHEN Others THEN
               l_future_issued_qty := 0;
    END;


        stmt_num := 102;
        UPDATE wip_requirement_operations w
        SET
         relieved_matl_completion_qty =
         (SELECT
           nvl(quantity_issued,0)-
           nvl(relieved_matl_final_comp_qty,0)-
           nvl(relieved_matl_scrap_quantity,0) +
	   l_future_issued_qty /* for bug  4246122 */
          FROM wip_requirement_operations w2
          WHERE
          w.wip_entity_id     = w2.wip_entity_id     AND
          w.organization_id   = w2.organization_id   AND
          w.inventory_item_id = w2.inventory_item_id AND
          w.operation_seq_num = w2.operation_seq_num
         )
        WHERE
         w.wip_entity_id   = i_wip_entity_id AND
         w.organization_id = i_org_id AND
	 w.inventory_item_id = wro_rec.inventory_item_id AND /*added for bug 4246122 */
         w.operation_seq_num = wro_rec.operation_seq_num /*added for bug 4246122 */
        AND  exists (
                  SELECT 'x'
                  FROM  wip_req_operation_cost_details wrocd
                  WHERE wrocd.wip_entity_id   = w.wip_entity_id
                  AND   wrocd.organization_id = w.organization_id
                  GROUP BY
                  wrocd.wip_entity_id,
                  wrocd.organization_id,
                  wrocd.cost_element_id
                  HAVING sum(nvl(applied_matl_value,0) -
                             nvl(relieved_matl_completion_value,0) -
                             nvl(relieved_variance_value,0) -
                             nvl(relieved_matl_scrap_value,0)) >= 0
               );

        stmt_num := 105;
        /* New final completion algorithm */
        /* when net is -ve */
        UPDATE wip_requirement_operations w
        SET
         relieved_matl_final_comp_qty =
         (SELECT
           nvl(quantity_issued,0)-
           nvl(relieved_matl_completion_qty,0)-
           nvl(relieved_matl_scrap_quantity,0) +
	   l_future_issued_qty /* for bug 4246122 */
          FROM wip_requirement_operations w2
          WHERE
          w.wip_entity_id     = w2.wip_entity_id     AND
          w.organization_id   = w2.organization_id   AND
          w.inventory_item_id = w2.inventory_item_id AND
          w.operation_seq_num = w2.operation_seq_num
         )
        WHERE
         w.wip_entity_id   = i_wip_entity_id AND
         w.organization_id = i_org_id AND
         w.inventory_item_id = wro_rec.inventory_item_id AND /* added for bug 4246122 */
         w.operation_seq_num = wro_rec.operation_seq_num /*added for bug 4246122 */
        AND  not exists (
                  SELECT 'x'
                  FROM  wip_req_operation_cost_details wrocd
                  WHERE wrocd.wip_entity_id   = w.wip_entity_id
                  AND   wrocd.organization_id = w.organization_id
                  GROUP BY
                  wrocd.wip_entity_id,
                  wrocd.organization_id,
                  wrocd.cost_element_id
                  HAVING sum(nvl(applied_matl_value,0) -
                             nvl(relieved_matl_completion_value,0) -
                             nvl(relieved_variance_value,0) -
                             nvl(relieved_matl_scrap_value,0)) >= 0
               );
     END LOOP ; /* Added for bug 4246122 */

        /* 2937695 */
        OPEN c_cost_elements;
        LOOP
                FETCH c_cost_elements INTO l_cost_element, l_job_value;
                EXIT WHEN c_cost_elements%NOTFOUND;

                IF l_job_value >= 0 THEN
                        stmt_num := 110;
                        UPDATE 	wip_req_operation_cost_details w
                        SET    	relieved_matl_completion_value =
                                        nvl(applied_matl_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0),
                                temp_relieved_value =
                                        nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)
                        WHERE	w.wip_entity_id = i_wip_entity_id AND
                                w.cost_element_id = l_cost_element;
                ELSE
                        stmt_num := 115;
                        UPDATE 	wip_req_operation_cost_details w
                        SET	relieved_variance_value =
                                        nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_matl_scrap_value,0),
                                temp_relieved_value =
                                        nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)
                        WHERE	w.wip_entity_id = i_wip_entity_id AND
                                w.cost_element_id = l_cost_element;
                END IF;
        END LOOP;

        /*******************************************************
        * flush out TL Resource costs and units ...            *
        *******************************************************/

        stmt_num := 120;
        UPDATE wip_operation_resources w
        SET
        (relieved_res_completion_units,
         relieved_res_completion_value,
         temp_relieved_value
         ) = (
              SELECT
                 ---
                 ---  relieved_res_completion_units
                 ---
                 nvl(applied_resource_units,0)-
                 nvl(relieved_res_final_comp_units,0)-
                 nvl(relieved_res_scrap_units,0),
                 ---
                 ---  relieved_res_completion_value
                 ---
                 nvl(applied_resource_value,0)-
                 nvl(relieved_variance_value,0)-
                 nvl(relieved_res_scrap_value,0),
                 ---
                 ---  temp_relieved_value
                 ---
                 nvl(applied_resource_value,0)-
                 nvl(relieved_res_completion_value,0)-
                 nvl(relieved_variance_value,0)-
                 nvl(relieved_res_scrap_value,0)
              FROM wip_operation_resources w2
              WHERE
               w.wip_entity_id     = w2.wip_entity_id and
               w.organization_id   = w2.organization_id and
               w.operation_seq_num = w2.operation_seq_num and
               w.resource_seq_num  = w2.resource_seq_num
             )
        WHERE w.wip_entity_id   = i_wip_entity_id
        AND   w.organization_id = i_org_id
        AND EXISTS
            (SELECT null
             FROM  wip_operation_resources   wor,
                   bom_resources             br
             WHERE wor.wip_entity_id   = i_wip_entity_id
             AND   wor.organization_id = i_org_id
             AND   wor.organization_id = br.organization_id
             AND   wor.resource_id     = br.resource_id
             AND EXISTS
                 (SELECT null
                  FROM wip_operation_resources      w3,
                       bom_resources                br3
                  WHERE w3.wip_entity_id      = i_wip_entity_id
                  AND   w3.organization_id    = i_org_id
                  AND   w3.resource_seq_num   = w.resource_seq_num
                  AND   w3.operation_seq_num  = w.operation_seq_num
                  AND   w3.resource_id        = br3.resource_id
                  AND   w3.organization_id    = br3.organization_id
                  AND   br3.cost_element_id   = br.cost_element_id)
            GROUP BY br.cost_element_id
            HAVING sum(nvl(applied_resource_value,0) -
                       nvl(relieved_res_completion_value,0) -
                       nvl(relieved_variance_value,0) -
                       nvl(relieved_res_scrap_value,0)) >= 0);

 /*Bug #2518907 - Moved stmt 121 within if statement to prevent its execution
if stmt 120 updates wor rows*/
       if (SQL%ROWCOUNT = 0) then
        stmt_num := 121;
        /* new final completion algorithm */
        /* if Net is -ve, write to variance */
        UPDATE wip_operation_resources w
        SET
         (relieved_res_final_comp_units,
          relieved_variance_value,
          temp_relieved_value
         ) = (
              SELECT
                 ---
                 ---  relieved_res_final_comp_units
                 ---
                 nvl(applied_resource_units,0)-
                 nvl(relieved_res_completion_units,0)-
                 nvl(relieved_res_scrap_units,0),
                 ---
                 ---  relieved_variance_value
                 ---
                 nvl(applied_resource_value,0)-
                 nvl(relieved_res_completion_value,0)-
                 nvl(relieved_res_scrap_value,0),
                 ---
                 ---  temp_relieved_value
                 ---
                 nvl(applied_resource_value,0)-
                 nvl(relieved_res_completion_value,0)-
                 nvl(relieved_variance_value,0)-
                 nvl(relieved_res_scrap_value,0)
              FROM wip_operation_resources w2
              WHERE
               w.wip_entity_id     = w2.wip_entity_id and
               w.organization_id   = w2.organization_id and
               w.operation_seq_num = w2.operation_seq_num and
               w.resource_seq_num  = w2.resource_seq_num
             )
        WHERE w.wip_entity_id   = i_wip_entity_id
        AND   w.organization_id = i_org_id
        AND EXISTS
            (SELECT null
             FROM  wip_operation_resources   wor,
                   bom_resources             br
             WHERE wor.wip_entity_id   = i_wip_entity_id
             AND   wor.organization_id = i_org_id
             AND   wor.organization_id = br.organization_id
             AND   wor.resource_id     = br.resource_id
             AND EXISTS
                 (SELECT null
                  FROM wip_operation_resources      w3,
                       bom_resources                br3
                  WHERE w3.wip_entity_id      = i_wip_entity_id
                  AND   w3.organization_id    = i_org_id
                  AND   w3.resource_seq_num   = w.resource_seq_num
                  AND   w3.operation_seq_num  = w.operation_seq_num
                  AND   w3.resource_id        = br3.resource_id
                  AND   w3.organization_id    = br3.organization_id
                  AND   br3.cost_element_id   = br.cost_element_id)
            GROUP BY br.cost_element_id
            HAVING sum(nvl(applied_resource_value,0) -
                       nvl(relieved_res_completion_value,0) -
                       nvl(relieved_variance_value,0) -
                       nvl(relieved_res_scrap_value,0)) < 0);
        end if;

        /*******************************************************
        * Flush out TL Res based Overhead costs and units ...  *
        *******************************************************/

        /*******************************************************
        * Flush out TL Move based Overhead costs and units ...  *
        *******************************************************/

        stmt_num := 132;

        /* flush out TL Overhead move based resources based */
        UPDATE wip_operation_overheads w
        set (relieved_ovhd_completion_units,
             relieved_ovhd_completion_value,
             temp_relieved_value) =
                (SELECT
                   ---
                   ---  relieved_ovhd_completion_units
                   ---
                   nvl(applied_ovhd_units,0)-
                   nvl(relieved_ovhd_scrap_units,0) -
                   nvl(relieved_ovhd_final_comp_units,0),
                   ---
                   ---  relieved_ovhd_completion_value
                   ---
                   nvl(applied_ovhd_value,0)-
                   nvl(relieved_ovhd_scrap_value,0) -
                   nvl(relieved_variance_value,0),
                   ---
                   ---  temp_relieved_value
                   ---
                   nvl(applied_ovhd_value,0)-
                   nvl(relieved_ovhd_completion_value,0)-
                   nvl(relieved_variance_value,0)-
                   nvl(relieved_ovhd_scrap_value,0)
                FROM
                 wip_operation_overheads w2
                 where
                 w.wip_entity_id     = w2.wip_entity_id     AND
                 w.organization_id   = w2.organization_id   AND
                 w.operation_seq_num = w2.operation_seq_num AND
                 w.resource_seq_num  = w2.resource_seq_num  AND
                 w.overhead_id       = w2.overhead_id       AND
                 w.basis_type        = w2.basis_type
                 )
        WHERE
        w.wip_entity_id   = i_wip_entity_id AND
        w.organization_id = i_org_id
        AND  exists (
                  SELECT 'x'
                  FROM  wip_operation_overheads woo
                  WHERE woo.wip_entity_id   = w.wip_entity_id
                  AND   woo.organization_id = w.organization_id
                  HAVING sum(nvl(applied_ovhd_value,0) -
                             nvl(relieved_ovhd_completion_value,0) -
                             nvl(relieved_variance_value,0) -
                             nvl(relieved_ovhd_scrap_value,0)) >= 0
               );

/*Bug #2518907 - Moved stmt 133 within if statement to prevent its execution
if stmt 132 updates woo rows*/
       if (SQL%ROWCOUNT = 0) then
        stmt_num := 133;
        /* New final completion algorithm */
        /* for net value of overhead is -ve, write to variance */
        UPDATE wip_operation_overheads w
        set (relieved_ovhd_final_comp_units,
             relieved_variance_value,
             temp_relieved_value) =
                (SELECT
                   ---
                   ---  relieved_ovhd_final_comp_units
                   ---
                   nvl(applied_ovhd_units,0)-
                   nvl(relieved_ovhd_completion_units,0)-
                   nvl(relieved_ovhd_scrap_units,0),
                   ---
                   ---  relieved_variance_value
                   ---
                   nvl(applied_ovhd_value,0)-
                   nvl(relieved_ovhd_completion_value,0)-
                   nvl(relieved_ovhd_scrap_value,0),
                   ---
                   ---  temp_relieved_value
                   ---
                   nvl(applied_ovhd_value,0)-
                   nvl(relieved_ovhd_completion_value,0)-
                   nvl(relieved_variance_value,0)-
                   nvl(relieved_ovhd_scrap_value,0)
                FROM
                 wip_operation_overheads w2
                 where
                 w.wip_entity_id     = w2.wip_entity_id     AND
                 w.organization_id   = w2.organization_id   AND
                 w.operation_seq_num = w2.operation_seq_num AND
                 w.resource_seq_num  = w2.resource_seq_num  AND
                 w.overhead_id       = w2.overhead_id       AND
                 w.basis_type        = w2.basis_type
                 )
        WHERE
        w.wip_entity_id   = i_wip_entity_id AND
        w.organization_id = i_org_id
        AND  exists (
                  SELECT 'x'
                  FROM  wip_operation_overheads woo
                  WHERE woo.wip_entity_id   = w.wip_entity_id
                  AND   woo.organization_id = w.organization_id
                  HAVING sum(nvl(applied_ovhd_value,0) -
                             nvl(relieved_ovhd_completion_value,0) -
                             nvl(relieved_variance_value,0) -
                             nvl(relieved_ovhd_scrap_value,0)) < 0
               );
      end if;


        /*------------------------------------------------------+
        | This is for the Case 2 - completion based on user spec
        | cost type, and this is a final completion.
        | We also need to include the case where the job has
        | SYSTEM derived costs but has no bill/rtg ==> regular
        | completions are costed from the valuation cost type and
        | final completions are computed off wip_period_balances.
        |-------------------------------------------------------*/


        ELSIF (i_final_comp_flag = 'Y'
               AND
              ((l_comp_cost_source = 2 and l_c_cost_type_id > 0)
              OR (l_comp_cost_source = 1 AND l_use_val_cost_type = -1))) THEN

        /*----------------------------------------------------------
        | Set the insert indicator to ensure that we skip the insert
        | into cst_txn_cst_details at the end of the file.
        | Then insert into mtl_cst_txn_cost_details in 2 passes,
        | one for PL costs and one for TL costs ...
        |-----------------------------------------------------------*/


        /*-------------------------------------------------------
        | TL MO should never be inserted - it will be earned by
        | the Cost processor, so weed out cost_element_id = 2
        |______________________________________________________*/

        l_insert_ind := 1;

        stmt_num := 135;
	/* Bug 7346243: Removed Variance value from Available
        Value for Final Completion */
        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        cce.cost_element_id,
        1,
        decode(cce.cost_element_id,
	       1,sum(0 - nvl(tl_material_out,0)-nvl(tl_material_var,0)),
	       2,sum(0 - nvl(tl_material_overhead_out,0)-nvl(tl_material_overhead_var,0)),
	       3,sum(nvl(tl_resource_in,0)-nvl(tl_resource_out,0)-nvl(tl_resource_var,0)),
	       4,sum(nvl(tl_outside_processing_in,0)-nvl(tl_outside_processing_out,0)-nvl(tl_outside_processing_var,0)),
	       5,sum(nvl(tl_overhead_in,0)-nvl(tl_overhead_out,0)-nvl(tl_overhead_var,0)))/i_txn_qty,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        CST_COST_ELEMENTS CCE,
        WIP_PERIOD_BALANCES WPB
        WHERE
        WPB.WIP_ENTITY_ID		=	I_WIP_ENTITY_ID		AND
        WPB.ORGANIZATION_ID		=	I_ORG_ID		AND
        CCE.COST_ELEMENT_ID		<>	2
        GROUP BY CCE.COST_ELEMENT_ID, WPB.WIP_ENTITY_ID
        HAVING
        decode(cce.cost_element_id,
               1,sum(0 - nvl(tl_material_out,0)-nvl(tl_material_var,0)),
               2,sum(0 - nvl(tl_material_overhead_out,0)-nvl(tl_material_overhead_var,0)),
               3,sum(nvl(tl_resource_in,0)-nvl(tl_resource_out,0)-nvl(tl_resource_var,0)),
               4,sum(nvl(tl_outside_processing_in,0)-nvl(tl_outside_processing_out,0)-nvl(tl_outside_processing_var,0)),
               5,sum(nvl(tl_overhead_in,0)-nvl(tl_overhead_out,0)-nvl(tl_overhead_var,0))) > 0;

        stmt_num := 150;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        cce.cost_element_id,
        2,
        decode(cce.cost_element_id,
               1,sum(nvl(pl_material_in,0) - nvl(pl_material_out,0)-nvl(pl_material_var,0)),
               2,sum(nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)-nvl(pl_material_overhead_var,0)),
               3,sum(nvl(pl_resource_in,0)-nvl(pl_resource_out,0)-nvl(pl_resource_var,0)),
               4,sum(nvl(pl_outside_processing_in,0)-nvl(pl_outside_processing_out,0)-nvl(pl_outside_processing_var,0)),
               5,sum(nvl(pl_overhead_in,0)-nvl(pl_overhead_out,0)-nvl(pl_overhead_var,0)))/i_txn_qty,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        CST_COST_ELEMENTS CCE,
        WIP_PERIOD_BALANCES WPB
        WHERE
        WPB.WIP_ENTITY_ID               =       I_WIP_ENTITY_ID         AND
        WPB.ORGANIZATION_ID             =       I_ORG_ID
        GROUP BY CCE.COST_ELEMENT_ID, WPB.WIP_ENTITY_ID
        HAVING
        decode(cce.cost_element_id,
               1,sum(nvl(pl_material_in,0) - nvl(pl_material_out,0)-nvl(pl_material_var,0)),
               2,sum(nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)-nvl(pl_material_overhead_var,0)),
               3,sum(nvl(pl_resource_in,0)-nvl(pl_resource_out,0)-nvl(pl_resource_var,0)),
               4,sum(nvl(pl_outside_processing_in,0)-nvl(pl_outside_processing_out,0)-nvl(pl_outside_processing_var,0)),
               5,sum(nvl(pl_overhead_in,0)-nvl(pl_overhead_out,0)-nvl(pl_overhead_var,0))) > 0;


      /*=====================================================================
           Bug6734270: Added the following to flush out the values
           From WROCD,WRO,WOR,WOO if any exists.(Requirements which have
           quantity per assembly as 0 or usage rate as 0 can be added to
           work order for assemblies having no BOM or Routing and those
           will have WROCD,WOR etc which needs to be flushed as otherwise
           in subsequent Scrap or Completion after adding a requirement
           having quantity per assembly as <> 0 or usage rate as <> 0
           extra value would be relieved.
         ======================================================================*/


     FOR wro_rec IN c_wip_final_req_op LOOP
       l_future_issued_qty := 0;

          BEGIN
           stmt_num := 160;
               SELECT   nvl(sum(primary_quantity),0)
               INTO     l_future_issued_qty
               FROM     mtl_material_transactions
               WHERE    organization_id = wro_rec.organization_id
               AND      inventory_item_id = wro_rec.inventory_item_id
               AND      operation_seq_num = wro_rec.operation_seq_num
               AND      transaction_source_id = wro_rec.wip_entity_id
               AND      ( (transaction_date > i_txn_date) or
                          (transaction_date = i_txn_date and transaction_id > i_trx_id) )
               AND      costed_flag IS NOT NULL
               AND      nvl(completion_transaction_id,-999) <>
                           ( Select   nvl(completion_transaction_id,-999)
                             from     mtl_material_transactions
                             where    transaction_id = i_trx_id);
          EXCEPTION
              WHEN Others THEN
                  l_future_issued_qty := 0;
           END;

       stmt_num :=170;
           UPDATE wip_requirement_operations w
           SET
            relieved_matl_completion_qty =
            (SELECT
              nvl(quantity_issued,0)-
              nvl(relieved_matl_final_comp_qty,0)-
              nvl(relieved_matl_scrap_quantity,0)
              + l_future_issued_qty
             FROM wip_requirement_operations w2
             WHERE
             w.wip_entity_id     = w2.wip_entity_id     AND
             w.organization_id   = w2.organization_id   AND
             w.inventory_item_id = w2.inventory_item_id AND
             w.operation_seq_num = w2.operation_seq_num
            )
           WHERE
            w.wip_entity_id   = i_wip_entity_id AND
            w.organization_id = i_org_id AND
            w.inventory_item_id = wro_rec.inventory_item_id AND
            w.operation_seq_num = wro_rec.operation_seq_num
           AND  exists (
                     SELECT 'x'
                     FROM  wip_req_operation_cost_details wrocd
                     WHERE wrocd.wip_entity_id   = w.wip_entity_id
                     AND   wrocd.organization_id = w.organization_id
                     GROUP BY
                     wrocd.wip_entity_id,
                     wrocd.organization_id,
                     wrocd.cost_element_id
                     HAVING sum(nvl(applied_matl_value,0) -
                                nvl(relieved_matl_completion_value,0) -
                                nvl(relieved_variance_value,0) -
                                nvl(relieved_matl_scrap_value,0)) >= 0
                  );

        END LOOP ;


           OPEN c_cost_elements;
           LOOP
                   FETCH c_cost_elements INTO l_cost_element, l_job_value;
                   EXIT WHEN c_cost_elements%NOTFOUND;

                   IF l_job_value >= 0 THEN
                           stmt_num := 180;
                           UPDATE         wip_req_operation_cost_details w
                           SET            relieved_matl_completion_value =
                                           nvl(applied_matl_value,0)-
                                             nvl(relieved_variance_value,0)-
                                           nvl(relieved_matl_scrap_value,0),
                                     temp_relieved_value =
                                           nvl(applied_matl_value,0)-
                                           nvl(relieved_matl_completion_value,0)-
                                              nvl(relieved_variance_value,0)-
                                           nvl(relieved_matl_scrap_value,0)
                           WHERE        w.wip_entity_id = i_wip_entity_id AND
                                   w.cost_element_id = l_cost_element;
                   END IF;
           END LOOP;

           /*******************************************************
           * flush out TL Resource costs and units ...            *
           *******************************************************/

           stmt_num := 190;
           UPDATE wip_operation_resources w
           SET
           (relieved_res_completion_units,
            relieved_res_completion_value,
            temp_relieved_value
            ) = (
                 SELECT
                    ---
                    ---  relieved_res_completion_units
                    ---
                    nvl(applied_resource_units,0)-
                    nvl(relieved_res_final_comp_units,0)-
                    nvl(relieved_res_scrap_units,0),
                    ---
                    ---  relieved_res_completion_value
                    ---
                    nvl(applied_resource_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_res_scrap_value,0),
                    ---
                    ---  temp_relieved_value
                    ---
                    nvl(applied_resource_value,0)-
                    nvl(relieved_res_completion_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_res_scrap_value,0)
                 FROM wip_operation_resources w2
                 WHERE
                  w.wip_entity_id     = w2.wip_entity_id and
                  w.organization_id   = w2.organization_id and
                  w.operation_seq_num = w2.operation_seq_num and
                  w.resource_seq_num  = w2.resource_seq_num
                )
           WHERE w.wip_entity_id   = i_wip_entity_id
           AND   w.organization_id = i_org_id
           AND EXISTS
               (SELECT null
                FROM  wip_operation_resources   wor,
                      bom_resources             br
                WHERE wor.wip_entity_id   = i_wip_entity_id
                AND   wor.organization_id = i_org_id
                AND   wor.organization_id = br.organization_id
                AND   wor.resource_id     = br.resource_id
                AND EXISTS
                    (SELECT null
                     FROM wip_operation_resources      w3,
                          bom_resources                br3
                     WHERE w3.wip_entity_id      = i_wip_entity_id
                     AND   w3.organization_id    = i_org_id
                     AND   w3.resource_seq_num   = w.resource_seq_num
                     AND   w3.operation_seq_num  = w.operation_seq_num
                     AND   w3.resource_id        = br3.resource_id
                     AND   w3.organization_id    = br3.organization_id
                     AND   br3.cost_element_id   = br.cost_element_id)
               GROUP BY br.cost_element_id
               HAVING sum(nvl(applied_resource_value,0) -
                          nvl(relieved_res_completion_value,0) -
                          nvl(relieved_variance_value,0) -
                          nvl(relieved_res_scrap_value,0)) >= 0);

           /*******************************************************
           * Flush out TL Res based Overhead costs and units ...  *
           *******************************************************/

           /*******************************************************
           * Flush out TL Move based Overhead costs and units ...  *
           *******************************************************/

           stmt_num := 200;

           /* flush out TL Overhead move based resources based */
           UPDATE wip_operation_overheads w
           set (relieved_ovhd_completion_units,
                relieved_ovhd_completion_value,
                temp_relieved_value) =
                   (SELECT
                      ---
                      ---  relieved_ovhd_completion_units
                      ---
                      nvl(applied_ovhd_units,0)-
                      nvl(relieved_ovhd_scrap_units,0) -
                      nvl(relieved_ovhd_final_comp_units,0),
                      ---
                      ---  relieved_ovhd_completion_value
                      ---
                      nvl(applied_ovhd_value,0)-
                      nvl(relieved_ovhd_scrap_value,0) -
                      nvl(relieved_variance_value,0),
                      ---
                      ---  temp_relieved_value
                      ---
                      nvl(applied_ovhd_value,0)-
                      nvl(relieved_ovhd_completion_value,0)-
                      nvl(relieved_variance_value,0)-
                      nvl(relieved_ovhd_scrap_value,0)
                   FROM
                    wip_operation_overheads w2
                    where
                    w.wip_entity_id     = w2.wip_entity_id     AND
                    w.organization_id   = w2.organization_id   AND
                    w.operation_seq_num = w2.operation_seq_num AND
                    w.resource_seq_num  = w2.resource_seq_num  AND
                    w.overhead_id       = w2.overhead_id       AND
                    w.basis_type        = w2.basis_type
                    )
           WHERE
           w.wip_entity_id   = i_wip_entity_id AND
           w.organization_id = i_org_id
           AND  exists (
                     SELECT 'x'
                     FROM  wip_operation_overheads woo
                     WHERE woo.wip_entity_id   = w.wip_entity_id
                     AND   woo.organization_id = w.organization_id
                     HAVING sum(nvl(applied_ovhd_value,0) -
                                nvl(relieved_ovhd_completion_value,0) -
                                nvl(relieved_variance_value,0) -
                                nvl(relieved_ovhd_scrap_value,0)) >= 0
                  );




        /*---------------------------------------------------------
        | Completion from a User specified cost type 		  |
        | ------------------------------------------		  |
        | We could go to CICD or Cst_layer_cost_details if the    |
        | entire org has one average cost, which will be the case |
        | for Average costing in a non-project environment. 	  |
        | In a project system however, the average cost could be  |
        | different within the same org. If the user chooses to   |
        | use the average cost of a given project to cost comple- |
        | tions then CICD will not contain all the 		  |
        | information. We have to go to CLCD in that case.        |
        | 							  |
        ---------------------------------------------------------*/

        /*--------------------------------------------------------
        | This is a regular completion. The costs are specified by
        | the user and the cost type specified in a cost type which
        | is different from the average cost type.
        |---------------------------------------------------------*/



        ELSIF(l_comp_cost_source = 2 AND l_c_cost_type_id >0 AND
              l_c_cost_type_id <> 2) THEN


        l_insert_ind := 1;


        stmt_num := 220;

        INSERT INTO mtl_cst_txn_cost_details
        (
        TRANSACTION_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        COST_ELEMENT_ID,
        LEVEL_TYPE,
        TRANSACTION_COST,
        NEW_AVERAGE_COST,
        PERCENTAGE_CHANGE,
        VALUE_CHANGE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        COST_ELEMENT_ID,
        LEVEL_TYPE,
        SUM(ITEM_COST),
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        CST_ITEM_COST_DETAILS
        WHERE
        INVENTORY_ITEM_ID		=	I_INV_ITEM_ID		AND
        ORGANIZATION_ID			=	I_ORG_ID		AND
        COST_TYPE_ID			=	L_C_COST_TYPE_ID	AND
        NOT (COST_ELEMENT_ID		=	2			AND
             LEVEL_TYPE			=	1)
        GROUP BY COST_ELEMENT_ID,LEVEL_TYPE
        HAVING SUM(ITEM_COST) <> 0;



        ELSIF((l_comp_cost_source = 2 AND l_c_cost_type_id = i_cost_type_id)
                                OR
             (l_comp_cost_source = 1  AND l_use_val_cost_type = -1)) THEN

        /*--------------------------------------------------------
        | This is for the case where :
        |
        | Costs are obtained from user cost type and the user cost
        | type happens to be the valuation cost type
        | 			OR
        | Costs are supposed to be SYSTEM derived but the job has no
        | bill/routing (==> we use the valuation cost type).
        |----------------------------------------------------------*/


        l_insert_ind := 1;

        stmt_num := 230;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
         SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         ITEM_COST,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
         FROM
         CST_LAYER_COST_DETAILS
         WHERE
         LAYER_ID 		=		i_layer_id	AND
         NOT (COST_ELEMENT_ID            =       2              AND
              LEVEL_TYPE                 =       1);

        ELSE

        /*************************************************************
        * Derive the Comp costs dynamically based on current costs   *
        * in the JOb ...					     *
        *************************************************************/

        -- If no material has been issued to the Job, there will be no
        -- rows in WROCD for the components. However, the cost relief is
        -- supposed to be based on the current average cost of the
        -- components. Therefore insert rows for all components.
        -- If some components have been issued, they should not be inserted

        stmt_num := 240;

        INSERT INTO WIP_REQ_OPERATION_COST_DETAILS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         APPLIED_MATL_VALUE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
         i_wip_entity_id,
         wro.operation_seq_num,
         i_org_id,
         wro.inventory_item_id,
         clcd.cost_element_id,
         0,
         i_user_id,
         SYSDATE,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_id,
         i_prog_appl_id,
         SYSDATE
        from
        WIP_REQUIREMENT_OPERATIONS WRO,
        CST_LAYER_COST_DETAILS CLCD,
        CST_QUANTITY_LAYERS CQL
        WHERE
        WRO.WIP_ENTITY_ID       =       i_wip_entity_id         AND
        WRO.INVENTORY_ITEM_ID   =       CQL.INVENTORY_ITEM_ID   AND
        WRO.ORGANIZATION_ID     =       CQL.ORGANIZATION_ID     AND
        CQL.COST_GROUP_ID       =       I_COST_GROUP_ID         AND
        CQL.LAYER_ID            =       CLCD.LAYER_ID           AND
        not EXISTS
        (SELECT
         'X'
         FROM
         WIP_REQ_OPERATION_COST_DETAILS WROCD
         WHERE
         WROCD.WIP_ENTITY_ID    =       i_wip_entity_id         AND
         WROCD.INVENTORY_ITEM_ID=       WRO.INVENTORY_ITEM_ID   AND
         WROCD.OPERATION_SEQ_NUM=       WRO.OPERATION_SEQ_NUM   AND
         WROCD.COST_ELEMENT_ID  =       CLCD.COST_ELEMENT_ID)
        GROUP BY CLCD.COST_ELEMENT_ID,wro.operation_seq_num,
                 wro.inventory_item_id;

        stmt_num := 245;

        /* Get the value of Include Component yield flag, which will determine
        whether to include or not component yield factor in quantity per assembly*/
        SELECT  nvl(include_component_yield, 1)
        INTO    l_include_comp_yield
        FROM    wip_parameters
        WHERE   organization_id = i_org_id;

        stmt_num := 250;

        /* fix for bug 2158763 */
        FOR wro_rec in c_wip_req_op LOOP
         BEGIN

           l_future_issued_qty := 0;

           /* IF wro_rec.wip_supply_type = 2 THEN -- commented as bugfix
               to allow component issue transactions for both, PUSH and PULL, components
               to be considered for calculation of l_future_issued_qty  */

            BEGIN
               SELECT   nvl(sum(primary_quantity),0)
               INTO     l_future_issued_qty
               FROM     mtl_material_transactions
               WHERE    organization_id = wro_rec.organization_id
               AND      inventory_item_id = wro_rec.inventory_item_id
               AND      operation_seq_num = wro_rec.operation_seq_num
               AND      transaction_source_id = wro_rec.wip_entity_id
               /* Bug 3715567: use txn_date to determine the future issued qty */
               AND      ( (transaction_date > i_txn_date) or
                          (transaction_date = i_txn_date and transaction_id > i_trx_id) )
               AND      costed_flag IS NOT NULL
               /* Applied nvl for bug 2391936 */
               AND      nvl(completion_transaction_id,-999) <>
                           ( Select   nvl(completion_transaction_id,-999)
                             from     mtl_material_transactions
                             where    transaction_id = i_trx_id);
            EXCEPTION
              WHEN Others THEN
                  l_future_issued_qty := 0;
            END;

           /* END IF; -- commented as bug fix 2391936 */

                   UPDATE WIP_REQ_OPERATION_COST_DETAILS w1
                   SET (temp_relieved_value,
                       relieved_matl_completion_value) =
                      (SELECT
                       decode(SIGN(nvl(wro.quantity_issued,0)-
                                 nvl(wro.relieved_matl_completion_qty,0)-
                                 nvl(wro.relieved_matl_final_comp_qty,0)-
                                 nvl(wro.relieved_matl_scrap_quantity,0)-
                                 /* LBM project Changes */
                                 i_txn_qty*(decode(wro.basis_type, 2,
                                                   wro.quantity_per_assembly/l_lot_size,
                                                   wro.quantity_per_assembly)/
                                            decode(l_include_comp_yield,
                                                   1, nvl(wro.component_yield_factor,1),
                                                   1)) + l_future_issued_qty),   /* Added l_future_issued_qty for bug 4259782 */
                            SIGN(wro.quantity_per_assembly),
                            /* LBM project Changes */
                            i_txn_qty*(decode(wro.basis_type, 2,
                                                   wro.quantity_per_assembly/l_lot_size,
                                                   wro.quantity_per_assembly)/
                                      decode(l_include_comp_yield,
                                             1, nvl(wro.component_yield_factor,1),
                                             1))*
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   0, 0,
                                   /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   ( nvl(applied_matl_value,0)-
                                     nvl(relieved_matl_completion_value,0)-
                                     nvl(relieved_variance_value,0)-
                                     nvl(relieved_matl_scrap_value,0))/
                                     (wro.quantity_issued-
                                        nvl(wro.relieved_matl_completion_qty,0)-
                                        nvl(wro.relieved_matl_final_comp_qty,0)-
                                        nvl(wro.relieved_matl_scrap_quantity,0)+
                                        l_future_issued_qty), /* Fix for bug 2158763 */
                                   nvl(decode(cost_element_id,
                                              1,cql.material_cost,
                                              2,cql.material_overhead_cost,
                                              3,cql.resource_cost,
                                              4,cql.outside_processing_cost,
                                              5,cql.overhead_cost),0)),
                            0,
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   0, 0,
                                   /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   (nvl(applied_matl_value,0)-
                                    nvl(relieved_matl_completion_value,0)-
                                    nvl(relieved_variance_value,0)-
                                    nvl(relieved_matl_scrap_value,0)),
                                    /* LBM project Changes */
                                    i_txn_qty*(decode(wro.basis_type, 2,
                                                      wro.quantity_per_assembly/l_lot_size,
                                                      wro.quantity_per_assembly)/
                                               decode(l_include_comp_yield,
                                                      1, nvl(wro.component_yield_factor,1),
                                                      1))*
                                    nvl(decode(cost_element_id,
                                               1,cql.material_cost,
                                               2,cql.material_overhead_cost,
                                               3,cql.resource_cost,
                                               4,cql.outside_processing_cost,
                                               5,cql.overhead_cost),0)),
                            -1*SIGN(wro.quantity_per_assembly),
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   /* LBM project Changes */
                                   0, (i_txn_qty*(decode(wro.basis_type, 2,
                                                         wro.quantity_per_assembly/l_lot_size,
                                                         wro.quantity_per_assembly)/
                                                  decode(l_include_comp_yield,
                                                         1, nvl(wro.component_yield_factor,1),
                                                         1))-
                                    (wro.quantity_issued -
                                     nvl(wro.relieved_matl_completion_qty,0) -
                                     nvl(wro.relieved_matl_final_comp_qty,0) -
                                     nvl(wro.relieved_matl_scrap_quantity,0) +
                                     l_future_issued_qty))*   /* Added l_future_issued_qty for bug 4259782 */
                                     nvl(decode(cost_element_id,
                                                1,cql.material_cost,
                                                2,cql.material_overhead_cost,
                                                3,cql.resource_cost,
                                                4,cql.outside_processing_cost,
                                                5,cql.overhead_cost),0),
                                    /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   (nvl(applied_matl_value,0)-
                                    nvl(relieved_matl_completion_value,0)-
                                    nvl(relieved_variance_value,0)-
                                    nvl(relieved_matl_scrap_value,0)+
                                    /* LBM project Changes */
                                    (i_txn_qty*(decode(wro.basis_type, 2,
                                                       wro.quantity_per_assembly/l_lot_size,
                                                       wro.quantity_per_assembly)/
                                               decode(l_include_comp_yield,
                                                      1, nvl(wro.component_yield_factor,1),
                                                      1))-
                                    (wro.quantity_issued -
                                     nvl(wro.relieved_matl_completion_qty,0) -
                                     nvl(wro.relieved_matl_final_comp_qty,0) -
                                     nvl(wro.relieved_matl_scrap_quantity,0) +
                                     l_future_issued_qty))*    /* Added l_future_issued_qty for bug 4259782 */
                                     nvl(decode(cost_element_id,
                                                1,cql.material_cost,
                                                2,cql.material_overhead_cost,
                                                3,cql.resource_cost,
                                                4,cql.outside_processing_cost,
                                                5,cql.overhead_cost),0)),
                                   /* LBM project Changes */
                                   i_txn_qty*(decode(wro.basis_type, 2,
                                                     wro.quantity_per_assembly/l_lot_size,
                                                     wro.quantity_per_assembly)/
                                              decode(l_include_comp_yield,
                                                     1, nvl(wro.component_yield_factor,1),
                                                     1))*
                                    nvl(decode(cost_element_id,
                                               1,cql.material_cost,
                                               2,cql.material_overhead_cost,
                                               3,cql.resource_cost,
                                               4,cql.outside_processing_cost,
                                               5,cql.overhead_cost),0))),

                     nvl(w1.relieved_matl_completion_value,0)+
                                 /* LBM project Changes */
                                 decode(SIGN(nvl(wro.quantity_issued,0)-
                                 nvl(wro.relieved_matl_completion_qty,0)-
                                 nvl(wro.relieved_matl_final_comp_qty,0)-
                                 nvl(wro.relieved_matl_scrap_quantity,0)-
                                 /* LBM project Changes */
                                 i_txn_qty*(decode(wro.basis_type, 2, wro.quantity_per_assembly/l_lot_size,
                                                                     wro.quantity_per_assembly)/
                                            decode(l_include_comp_yield,
                                                   1, nvl(wro.component_yield_factor,1),
                                                   1)) + l_future_issued_qty), /* Added l_future_issued_qty for bug 4259782 */
                            SIGN(wro.quantity_per_assembly),
                            /* LBM project Changes */
                            i_txn_qty*(decode(wro.basis_type, 2,
                                              wro.quantity_per_assembly/l_lot_size,
                                              wro.quantity_per_assembly)/
                                       decode(l_include_comp_yield,
                                              1, nvl(wro.component_yield_factor,1),
                                              1))*
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   0, 0,
                                   /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   ( nvl(applied_matl_value,0)-
                                     nvl(relieved_matl_completion_value,0)-
                                     nvl(relieved_variance_value,0)-
                                     nvl(relieved_matl_scrap_value,0))
                                     /(wro.quantity_issued-
                                        nvl(wro.relieved_matl_completion_qty,0)-
                                        nvl(wro.relieved_matl_final_comp_qty,0)-
                                        nvl(wro.RELIEVED_MATL_SCRAP_QUANTITY,0)+
                                        l_future_issued_qty), /* Fix for bug 2158763 */
                                   nvl(decode(cost_element_id,
                                              1,cql.material_cost,
                                              2,cql.material_overhead_cost,
                                              3,cql.resource_cost,
                                              4,cql.outside_processing_cost,
                                              5,cql.overhead_cost),0)),
                            0,
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   0, 0,
                                   /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   (nvl(applied_matl_value,0)-
                                    nvl(relieved_matl_completion_value,0)-
                                    nvl(relieved_variance_value,0)-
                                    nvl(relieved_matl_scrap_value,0)),
                                    /* LBM project Changes */
                                    i_txn_qty*(decode(wro.basis_type, 2,
                                                      wro.quantity_per_assembly/l_lot_size,
                                                      wro.quantity_per_assembly)/
                                               decode(l_include_comp_yield,
                                                      1, nvl(wro.component_yield_factor,1),
                                                      1))*
                                    nvl(decode(cost_element_id,
                                               1,cql.material_cost,
                                               2,cql.material_overhead_cost,
                                               3,cql.resource_cost,
                                               4,cql.outside_processing_cost,
                                               5,cql.overhead_cost),0)),
                            -1*SIGN(wro.quantity_per_assembly),
                            decode(SIGN(nvl(applied_matl_value,0)-
                                        nvl(relieved_matl_completion_value,0)-
                                        nvl(relieved_variance_value,0)-
                                        nvl(relieved_matl_scrap_value,0)),
                                   /* Bug 3479419: AVTR = 0 Start*/
                                   /* LBM project Changes */
                                   0, (i_txn_qty*(decode(wro.basis_type, 2,
                                                         wro.quantity_per_assembly/l_lot_size,
                                                         wro.quantity_per_assembly)/
                                                  decode(l_include_comp_yield,
                                                         1, nvl(wro.component_yield_factor,1),
                                                         1)) -
                                    (wro.quantity_issued -
                                     nvl(wro.relieved_matl_completion_qty,0) -
                                     nvl(wro.relieved_matl_final_comp_qty,0) -
                                     nvl(wro.relieved_matl_scrap_quantity,0) +
                                     l_future_issued_qty))*    /* Added l_future_issued_qty for bug 4259782 */
                                     nvl(decode(cost_element_id,
                                                1,cql.material_cost,
                                                2,cql.material_overhead_cost,
                                                3,cql.resource_cost,
                                                4,cql.outside_processing_cost,
                                                5,cql.overhead_cost),0),
                                    /* Bug 3479419: AVTR = 0 End*/
                                   SIGN(wro.quantity_per_assembly),
                                   (nvl(applied_matl_value,0)-
                                    nvl(relieved_matl_completion_value,0)-
                                    nvl(relieved_variance_value,0)-
                                    nvl(relieved_matl_scrap_value,0)+
                                    /* LBM project Changes */
                                    (i_txn_qty*(decode(wro.basis_type, 2,
                                                       wro.quantity_per_assembly/l_lot_size,
                                                       wro.quantity_per_assembly)/
                                                decode(l_include_comp_yield,
                                                       1, nvl(wro.component_yield_factor,1),
                                                       1))-
                                    (wro.quantity_issued -
                                     nvl(wro.relieved_matl_completion_qty,0) -
                                     nvl(wro.relieved_matl_final_comp_qty,0) -
                                     nvl(wro.relieved_matl_scrap_quantity,0) +
                                     l_future_issued_qty))*    /* Added l_future_issued_qty for bug 4259782 */
                                     nvl(decode(cost_element_id,
                                                1,cql.material_cost,
                                                2,cql.material_overhead_cost,
                                                3,cql.resource_cost,
                                                4,cql.outside_processing_cost,
                                                5,cql.overhead_cost),0)),
                                   /* LBM project Changes */
                                   i_txn_qty*(decode(wro.basis_type, 2,
                                                     wro.quantity_per_assembly/l_lot_size,
                                                     wro.quantity_per_assembly)/
                                              decode(l_include_comp_yield,
                                                     1, nvl(wro.component_yield_factor,1),
                                                     1))*
                                    nvl(decode(cost_element_id,
                                               1,cql.material_cost,
                                               2,cql.material_overhead_cost,
                                               3,cql.resource_cost,
                                               4,cql.outside_processing_cost,
                                               5,cql.overhead_cost),0)))
                     FROM
                     wip_req_operation_cost_details w2,
                     wip_requirement_operations wro,
                     cst_quantity_layers cql
                     WHERE
                     w2.wip_entity_id      =    w1.wip_entity_id        AND
                     w2.organization_id    =    w1.organization_id      AND
                     w2.inventory_item_id  =    w1.inventory_item_id    AND
                     w2.operation_seq_num  =    w1.operation_seq_num    AND
                     w2.cost_element_id    =    w1.cost_element_id      AND
                     w2.wip_entity_id      =    wro.wip_entity_id       AND
                     w2.organization_id    =    wro.organization_id     AND
                     w2.inventory_item_id  =    wro.inventory_item_id   AND
                     w2.operation_seq_num  =    wro.operation_seq_num   AND
                     i_cost_group_id       =    cql.cost_group_id(+)    AND
                     wro.inventory_item_id =    cql.inventory_item_id(+) AND
                     wro.organization_id   =    cql.organization_id(+))
                 WHERE
                  w1.wip_entity_id   = wro_rec.wip_entity_id    AND
                  w1.organization_id = wro_rec.organization_id  AND
                  w1.inventory_item_id = wro_rec.inventory_item_id  AND
                  w1.operation_seq_num = wro_rec.operation_seq_num;
                 END;
                END LOOP;

                /*---------------------------------------------------
                | Qty must be updated after value ...
                |--------------------------------------------------*/


                stmt_num := 270;

                 UPDATE wip_requirement_operations w1
                 SET
                 relieved_matl_completion_qty =
                 (SELECT
                  nvl(w1.relieved_matl_completion_qty,0) +
                  /* LBM project Changes */
                  i_txn_qty*(decode(basis_type, 2,
                                       quantity_per_assembly/l_lot_size,
                                       quantity_per_assembly)/
                             decode(l_include_comp_yield,
                                    1, nvl(component_yield_factor,1),
                                    1))
                 FROM
                 wip_requirement_operations w2
                 WHERE
                 w1.wip_entity_id       =       w2.wip_entity_id        AND
                 w1.organization_id     =       w2.organization_id      AND
                 w1.inventory_item_id   =       w2.inventory_item_id    AND
                 w1.operation_seq_num   =       w2.operation_seq_num)
                 WHERE
                 --
                 -- Exclude bulk, supplier, phantom
                 --
                 w1.wip_supply_type     not in  (4,5,6)                        AND
                 w1.wip_entity_id       =       i_wip_entity_id         AND
                 w1.organization_id     =       i_org_id                AND
                 w1.quantity_per_assembly  <>   0;


--      /******************************************************
--      * Relieve This Level Resource costs/units from WIP ...*
--      ******************************************************/

        IF (l_system_option_id = 1) THEN

        -- If we use the actual resource option, then use the snapshot for
        -- both resources and overheads.

        stmt_num := 290;

        UPDATE wip_operation_resources w1
        SET
        (relieved_res_completion_units,
         temp_relieved_value,
         relieved_res_completion_value) =
        (SELECT
         nvl(w1.relieved_res_completion_units,0) +
         decode(sign(applied_resource_units -
                     nvl(relieved_res_completion_units,0)-
                     nvl(relieved_res_final_comp_units,0)-
                     nvl(relieved_res_scrap_units,0)),
                1,
                (applied_resource_units -
                nvl(relieved_res_completion_units,0)-
                nvl(relieved_res_final_comp_units,0)-
                nvl(relieved_res_scrap_units,0))*
        --
        -- new to solve divided by zero and over relieved
        -- when txn_qty/completed - prior_completion - prior_scrap
        -- is greater than or equal to one, set it to one
        -- ie. flush out 1*value remain in the job 1/30/98
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0),
         decode(sign(applied_resource_value -
                    nvl(relieved_res_completion_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_res_scrap_value,0)),
                1,
                (applied_resource_value -
                nvl(relieved_res_completion_value,0)-
                nvl(relieved_variance_value,0)-
                nvl(relieved_res_scrap_value,0))*
        --
        -- new to solve divided by zero and over relieved
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0),
        nvl(w1.relieved_res_completion_value,0) +
        decode(sign(applied_resource_value -
                    nvl(relieved_res_completion_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_res_scrap_value,0)),
                1,
                (applied_resource_value -
                nvl(relieved_res_completion_value,0)-
                nvl(relieved_variance_value,0)-
                nvl(relieved_res_scrap_value,0))*
        --
        -- new to solve divided by zero and over relieved
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0)
        FROM
        wip_operation_resources w2,
        cst_comp_snapshot cocd
        WHERE
        w1.wip_entity_id	=	w2.wip_entity_id	AND
        w1.operation_seq_num	=	w2.operation_seq_num	AND
        w1.resource_seq_num	=	w2.resource_seq_num	AND
        w1.organization_id	=	w2.organization_id	AND
	w2.wip_entity_id        =       cocd.wip_entity_id      AND -- Added for FP: bug#4608231
        w2.operation_seq_num	=	cocd.operation_seq_num	AND
        cocd.new_operation_flag =	2			AND
        cocd.transaction_id	=	i_trx_id)
        WHERE
        w1.wip_entity_id	=	i_wip_entity_id		AND
        w1.organization_id	=	i_org_id;



        stmt_num := 295;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_completion_units,
          temp_relieved_value,
          relieved_ovhd_completion_value) =
        (SELECT
         NVL(w1.relieved_ovhd_completion_units,0) +
         decode(sign(applied_ovhd_units -
                     nvl(relieved_ovhd_completion_units,0)-
                     nvl(relieved_ovhd_final_comp_units,0)-
                     nvl(relieved_ovhd_scrap_units,0)),
                1,
                (applied_ovhd_units -
                nvl(relieved_ovhd_completion_units,0)-
                nvl(relieved_ovhd_final_comp_units,0)-
                nvl(relieved_ovhd_scrap_units,0))*
        --
        -- new to solve divided by zero and over relieved
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0),
         decode(sign(applied_ovhd_value -
                    nvl(relieved_ovhd_completion_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_ovhd_scrap_value,0)),
                1,
                (applied_ovhd_value -
                nvl(relieved_ovhd_completion_value,0)-
                nvl(relieved_variance_value,0)-
                nvl(relieved_ovhd_scrap_value,0))*
        --
        -- new to solve divided by zero and over relieved
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0),
        nvl(w1.relieved_ovhd_completion_value,0) +
        decode(sign(applied_ovhd_value -
                    nvl(relieved_ovhd_completion_value,0)-
                    nvl(relieved_variance_value,0)-
                    nvl(relieved_ovhd_scrap_value,0)),
                1,
                (applied_ovhd_value -
                nvl(relieved_ovhd_completion_value,0)-
                nvl(relieved_variance_value,0)-
                nvl(relieved_ovhd_scrap_value,0))*
        --
        -- new to solve divided by zero and over relieved
        --
                decode(sign(i_txn_qty - (cocd.quantity_completed -
                                         nvl(prior_completion_quantity,0) -
                                         nvl(prior_scrap_quantity,0))),
                        -1,i_txn_qty/(cocd.quantity_completed -
                                     nvl(prior_completion_quantity,0) -
                                     nvl(prior_scrap_quantity,0)),
                        1),
                0)
        FROM
        wip_operation_overheads w2,
        cst_comp_snapshot cocd
        WHERE
        w1.wip_entity_id        =       w2.wip_entity_id        AND
        w1.operation_seq_num    =       w2.operation_seq_num    AND
        w1.resource_seq_num     =       w2.resource_seq_num     AND
        w1.overhead_id          =       w2.overhead_id          AND
        w1.organization_id      =       w2.organization_id      AND
	w2.wip_entity_id        =       cocd.wip_entity_id      AND -- Added for FP: bug#4608231
        w1.basis_type           =       w2.basis_type           AND
        w2.operation_seq_num    =       cocd.operation_seq_num  AND
        cocd.new_operation_flag =       2                       AND
        cocd.transaction_id     =       i_trx_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id;


        ELSIF (l_system_option_id = 2) THEN

        -- Or ... If we are using the Pre defined resource option, use
        -- the pre defined rates for resources and overheads.

        stmt_num := 300;

        UPDATE wip_operation_resources w1
        SET
         (relieved_res_completion_units,
          temp_relieved_value,
          relieved_res_completion_value) =
        (SELECT
           nvl(w1.relieved_res_completion_units,0)+
           decode(basis_type,
                  1,i_txn_qty*usage_rate_or_amount,
                  2,i_txn_qty*usage_rate_or_amount/l_lot_size,
                  i_txn_qty*usage_rate_or_amount),
             decode(SIGN(applied_resource_units-
                         nvl(relieved_res_completion_units,0)-
                         nvl(relieved_res_final_comp_units,0)-
                         nvl(relieved_res_scrap_units,0)-
                         i_txn_qty*decode(basis_type,
                                          1,usage_rate_or_amount,
                                          2,usage_rate_or_amount/l_lot_size,
                                          usage_rate_or_amount)),
                    SIGN(usage_rate_or_amount),
                    i_txn_qty*decode(basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/l_lot_size,
                                     usage_rate_or_amount)*
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           decode(basis_type,
                                  1,((nvl(applied_resource_value,0)-
                                  nvl(relieved_res_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_res_scrap_value,0))
                                  /(applied_resource_units-
                                  nvl(relieved_res_completion_units,0)-
                                  nvl(relieved_res_final_comp_units,0)-
                                  nvl(relieved_res_scrap_units,0))),
                                  2,nvl(applied_resource_value,0)/
                                    decode(applied_resource_units,
                                           0,1,applied_resource_units),
                                  ((nvl(applied_resource_value,0)-
                                  nvl(relieved_res_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_res_scrap_value,0))
                                  /(applied_resource_units-
                                  nvl(relieved_res_completion_units,0)-
                                  nvl(relieved_res_final_comp_units,0)-
                                  nvl(relieved_res_scrap_units,0)))),
                           crc.resource_rate),
                    0,
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
                            nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)),
                            i_txn_qty*decode(basis_type,
                                             1,usage_rate_or_amount,
                                             2,usage_rate_or_amount/l_lot_size,
                                             usage_rate_or_amount)*
                                       crc.resource_rate),
                    -1*SIGN(usage_rate_or_amount),
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
                            nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)+
                           (i_txn_qty*
                            decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/l_lot_size,
                            usage_rate_or_amount) -
                           (applied_resource_units -
                            nvl(relieved_res_completion_units,0) -
                            nvl(relieved_res_final_comp_units,0) -
                            nvl(relieved_res_scrap_units,0)))*
                           crc.resource_rate),
                           i_txn_qty*
                           decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/l_lot_size,
                            usage_rate_or_amount)*
                            crc.resource_rate)),
             nvl(w1.relieved_res_completion_value,0) +
             decode(SIGN(applied_resource_units-
                         nvl(relieved_res_completion_units,0)-
                         nvl(relieved_res_final_comp_units,0)-
                         nvl(relieved_res_scrap_units,0)-
                         i_txn_qty*decode(basis_type,
                                          1,usage_rate_or_amount,
                                          2,usage_rate_or_amount/l_lot_size,
                                          usage_rate_or_amount)),
                    SIGN(usage_rate_or_amount),
                    i_txn_qty*decode(basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/l_lot_size,
                                     usage_rate_or_amount)*
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           decode(basis_type,
                                  1,((nvl(applied_resource_value,0)-
                                  nvl(relieved_res_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_res_scrap_value,0))
                                  /(applied_resource_units-
                                  nvl(relieved_res_completion_units,0)-
                                  nvl(relieved_res_final_comp_units,0)-
                                  nvl(relieved_res_scrap_units,0))),
                                  2,nvl(applied_resource_value,0)/
                                    decode(applied_resource_units,
                                           0,1,applied_resource_units),
                                  ((nvl(applied_resource_value,0)-
                                  nvl(relieved_res_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_res_scrap_value,0))
                                  /(applied_resource_units-
                                  nvl(relieved_res_completion_units,0)-
                                  nvl(relieved_res_final_comp_units,0)-
                                  nvl(relieved_res_scrap_units,0)))),
                           crc.resource_rate),
                    0,
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
                            nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)),
                            i_txn_qty*decode(basis_type,
                                             1,usage_rate_or_amount,
                                             2,usage_rate_or_amount/l_lot_size,
                                             usage_rate_or_amount)*
                                       crc.resource_rate),
                    -1*SIGN(usage_rate_or_amount),
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
                                nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
                            nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)+
                           (i_txn_qty*
                            decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/l_lot_size,
                            usage_rate_or_amount) -
                           (applied_resource_units -
                            nvl(relieved_res_completion_units,0) -
                            nvl(relieved_res_final_comp_units,0) -
                            nvl(relieved_res_scrap_units,0)))*
                           crc.resource_rate),
                           i_txn_qty*
                           decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/l_lot_size,
                            usage_rate_or_amount)*
                            crc.resource_rate))
         FROM
         wip_operation_resources w2,
         cst_resource_costs crc
         WHERE
         w2.wip_entity_id       =       w1.wip_entity_id        AND
         w2.operation_seq_num	=	w1.operation_seq_num	AND
         w2.resource_seq_num    =       w1.resource_seq_num     AND
         w2.organization_id     =       w2.organization_id      AND
         w2.resource_id         =       crc.resource_id         AND
         w2.organization_id     =       crc.organization_id     AND
         crc.cost_type_id       =       i_res_cost_type_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id                AND
        w1.usage_rate_or_amount <>      0;


        /***********************************************************
        * Relieve TL Ovhd (Move based) units and Costs ..          *
        * Open Issue : Do we relieve Ovhds for which associations  *
        * no longer exist in CDO.				   *
        ***********************************************************/


        stmt_num := 305;

        -- For the pre-defined completion algorithm, if no overheads have
        -- been charged then they must be relieved at the cost in the
        -- rates cost type. However, if nothing has been charged, there are
        -- no rows in WOO. So insert these rows.

        INSERT INTO WIP_OPERATION_OVERHEADS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         RESOURCE_SEQ_NUM,
         ORGANIZATION_ID,
         OVERHEAD_ID,
         BASIS_TYPE,
         APPLIED_OVHD_UNITS,
         APPLIED_OVHD_VALUE,
         RELIEVED_OVHD_COMPLETION_UNITS,
         RELIEVED_OVHD_SCRAP_UNITS,
         RELIEVED_OVHD_COMPLETION_VALUE,
         RELIEVED_OVHD_SCRAP_VALUE,
         TEMP_RELIEVED_VALUE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         LAST_UPDATE_DATE)
        SELECT
         i_wip_entity_id,
         wo.operation_seq_num,
         -1,
         i_org_id,
         cdo.overhead_id,
         cdo.basis_type,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         -1,
         SYSDATE,
         -1,
         -1,
         -1,
         -1,
         -1,
         SYSDATE,
         SYSDATE
        FROM
        WIP_OPERATIONS WO,
        CST_DEPARTMENT_OVERHEADS CDO
        WHERE
        WO.WIP_ENTITY_ID        =       i_wip_entity_id         AND
        WO.DEPARTMENT_ID        =       CDO.DEPARTMENT_ID       AND
        CDO.COST_TYPE_ID        =       i_res_cost_type_id	AND
        CDO.BASIS_TYPE          IN      (1,2)                   AND
        NOT EXISTS
        (SELECT 'X'
        FROM
        WIP_OPERATION_OVERHEADS WOO
        where
        WOO.WIP_ENTITY_ID       =       i_wip_entity_id         AND
        WOO.OPERATION_SEQ_NUM   =       WO.OPERATION_SEQ_NUM    AND
        WOO.OVERHEAD_ID         =       CDO.OVERHEAD_ID         AND
        WOO.BASIS_TYPE          =       CDO.BASIS_TYPE          AND
        WOO.RESOURCE_SEQ_NUM    =       -1);


        stmt_num := 310;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_completion_units,
          temp_relieved_value,
          relieved_ovhd_completion_value) =
        (SELECT
           nvl(w1.relieved_ovhd_completion_units,0)+
           decode(w2.basis_type,
                  1,i_txn_qty,
                  2,i_txn_qty/l_lot_size),
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         1,i_txn_qty,
                         2,i_txn_qty/l_lot_size)),
                   1,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          decode(w2.basis_type,
                                 2,nvl(applied_ovhd_value,0),
                                 (nvl(applied_ovhd_value,0)-
                                  nvl(relieved_ovhd_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_ovhd_scrap_value,0))
                                  /(nvl(applied_ovhd_units,0)-
                                  nvl(relieved_ovhd_completion_units,0)-
                                  nvl(relieved_ovhd_final_comp_units,0)-
                                  nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)),
                   0,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)),
                   -1,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)+
                          (decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
                          nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          cdo.rate_or_amount),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                          1,i_txn_qty,
                          2,i_txn_qty/l_lot_size))),
           nvl(w1.relieved_ovhd_completion_value,0) +
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         1,i_txn_qty,
                         2,i_txn_qty/l_lot_size)),
                   1,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          decode(w2.basis_type,
                                 2,nvl(applied_ovhd_value,0),
                                 (nvl(applied_ovhd_value,0)-
                                  nvl(relieved_ovhd_completion_value,0)-
                                  nvl(relieved_variance_value,0)-
                                  nvl(relieved_ovhd_scrap_value,0))
                                  /(nvl(applied_ovhd_units,0)-
                                  nvl(relieved_ovhd_completion_units,0)-
                                  nvl(relieved_ovhd_final_comp_units,0)-
                                  nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)),
                   0,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)),
                   -1,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          1,
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0) +
                          (decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/l_lot_size)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
                          nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          cdo.rate_or_amount),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                          1,i_txn_qty,
                          2,i_txn_qty/l_lot_size)))
         FROM
         wip_operation_overheads w2,
         cst_department_overheads cdo,
         wip_operations wo
         WHERE
         w2.wip_entity_id       =       w1.wip_entity_id        AND
         w2.organization_id     =       w1.organization_id      AND
         w2.operation_seq_num   =       w1.operation_seq_num    AND
         w2.overhead_id         =       w1.overhead_id          AND
         w2.basis_type          =       w1.basis_type           AND
         w2.wip_entity_id       =       wo.wip_entity_id        AND
         w2.organization_id     =       wo.organization_id      AND
         w2.operation_seq_num   =       wo.operation_seq_num    AND
         cdo.department_id      =       wo.department_id        AND
         cdo.overhead_id        =       w2.overhead_id          AND
         cdo.basis_type         =       w2.basis_type           AND
         cdo.cost_type_id       =       i_res_cost_type_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id                AND
        w1.basis_type           IN      (1,2)                   AND
        EXISTS
         (
          SELECT 'X'
          FROM
          cst_department_overheads cdo2,
          wip_operations wo2
          WHERE
          wo2.wip_entity_id     =       w1.wip_entity_id        AND
          wo2.organization_id   =       w1.organization_id      AND
          wo2.operation_seq_num =       w1.operation_seq_num    AND
          wo2.department_id     =       cdo2.department_id      AND
          w1.overhead_id        =       cdo2.overhead_id        AND
          w1.basis_type         =       cdo2.basis_type         AND
          cdo2.cost_type_id     =       i_res_cost_type_id);

        /***********************************************************
        * Relieve TL Res based overheads and Units ...             *
        ***********************************************************/

        stmt_num := 320;

        INSERT INTO WIP_OPERATION_OVERHEADS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         RESOURCE_SEQ_NUM,
         ORGANIZATION_ID,
         OVERHEAD_ID,
         BASIS_TYPE,
         APPLIED_OVHD_UNITS,
         APPLIED_OVHD_VALUE,
         RELIEVED_OVHD_COMPLETION_UNITS,
         RELIEVED_OVHD_SCRAP_UNITS,
         RELIEVED_OVHD_COMPLETION_VALUE,
         RELIEVED_OVHD_SCRAP_VALUE,
         TEMP_RELIEVED_VALUE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         LAST_UPDATE_DATE)
        SELECT
         i_wip_entity_id,
         wo.operation_seq_num,
         wor.resource_seq_num,
         i_org_id,
         cdo.overhead_id,
         cdo.basis_type,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         -1,
         SYSDATE,
         -1,
         -1,
         -1,
         -1,
         -1,
         SYSDATE,
         SYSDATE
        FROM
        WIP_OPERATIONS WO,
        WIP_OPERATION_RESOURCES WOR,
        CST_DEPARTMENT_OVERHEADS CDO,
        CST_RESOURCE_OVERHEADS CRO
        WHERE
        WO.WIP_ENTITY_ID        =       i_wip_entity_id                 AND
        WO.OPERATION_SEQ_NUM    =       WOR.OPERATION_SEQ_NUM           AND
        WO.WIP_ENTITY_ID        =       WOR.WIP_ENTITY_ID               AND
        CDO.DEPARTMENT_ID       =       DECODE(WOR.PHANTOM_FLAG,
	                 		1,WOR.DEPARTMENT_ID,
			                WO.DEPARTMENT_ID)        AND
        CDO.COST_TYPE_ID        =       i_res_cost_type_id	AND
        CDO.BASIS_TYPE          IN      (3,4)                           AND
        CRO.COST_TYPE_ID        =       i_res_cost_type_id	AND
        CRO.RESOURCE_ID         =       WOR.RESOURCE_ID                 AND
        CRO.OVERHEAD_ID         =       CDO.OVERHEAD_ID                 AND
        NOT EXISTS
        (SELECT 'X'
        FROM
        WIP_OPERATION_OVERHEADS WOO
        WHERE
        WOO.WIP_ENTITY_ID       =       i_wip_entity_id                 AND
        WOO.OPERATION_SEQ_NUM   =       WO.OPERATION_SEQ_NUM            AND
        WOO.RESOURCE_SEQ_NUM    =       WOR.RESOURCE_SEQ_NUM            AND
        WOO.OVERHEAD_ID         =       CDO.OVERHEAD_ID                 AND
        WOO.BASIS_TYPE          =       CDO.BASIS_TYPE);

        stmt_num := 330;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_completion_units,
          temp_relieved_value,
          relieved_ovhd_completion_value) =
        (SELECT
           nvl(w1.relieved_ovhd_completion_units,0)+
           decode(w2.basis_type,
                  3,i_txn_qty*decode(wor.basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/l_lot_size,
                                     usage_rate_or_amount),
                  4,wor.temp_relieved_value),
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/l_lot_size,
                                            usage_rate_or_amount),
                         4,wor.temp_relieved_value)),
                   SIGN(wor.usage_rate_or_amount),
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          ((nvl(applied_ovhd_value,0)-
                            nvl(relieved_ovhd_completion_value,0)-
                            nvl(w2.relieved_variance_value,0)-
                            nvl(relieved_ovhd_scrap_value,0))
                            /(nvl(applied_ovhd_units,0)-
                           nvl(relieved_ovhd_completion_units,0)-
                           nvl(relieved_ovhd_final_comp_units,0)-
                            nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                         nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0))),
                   0,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(w2.relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)),
                          nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0))),
                   -1*SIGN(wor.usage_rate_or_amount),
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(w2.relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)+
                          (decode(w2.basis_type,
                                 3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/l_lot_size,
                                            usage_rate_or_amount),
                                 4,wor.temp_relieved_value)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
                          nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          nvl(cdo.rate_or_amount,0)),
                          nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                          3,i_txn_qty*
                          decode(wor.basis_type,
                                 1,wor.usage_rate_or_amount,
                                 2,wor.usage_rate_or_amount/l_lot_size),
                          4,nvl(wor.temp_relieved_value,0)))),
           nvl(w1.relieved_ovhd_completion_value,0) +
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/l_lot_size,
                                            usage_rate_or_amount),
                         4,wor.temp_relieved_value)),
                   SIGN(wor.usage_rate_or_amount),
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          ((nvl(applied_ovhd_value,0)-
                            nvl(relieved_ovhd_completion_value,0)-
                            nvl(w2.relieved_variance_value,0)-
                            nvl(relieved_ovhd_scrap_value,0))
                            /(nvl(applied_ovhd_units,0)-
                           nvl(relieved_ovhd_completion_units,0)-
                           nvl(relieved_ovhd_final_comp_units,0)-
                            nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                         nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0))),
                   0,
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(w2.relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)),
                          nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/l_lot_size),
                                 4,nvl(wor.temp_relieved_value,0))),
                   -1*SIGN(wor.usage_rate_or_amount),
                   decode(SIGN(nvl(applied_ovhd_value,0)-
                               nvl(relieved_ovhd_completion_value,0)-
                               nvl(w2.relieved_variance_value,0)-
                               nvl(relieved_ovhd_scrap_value,0)),
                          SIGN(wor.usage_rate_or_amount),
                          (nvl(applied_ovhd_value,0)-
                          nvl(relieved_ovhd_completion_value,0)-
                          nvl(w2.relieved_variance_value,0)-
                          nvl(relieved_ovhd_scrap_value,0)+
                          (decode(w2.basis_type,
                                 3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/l_lot_size,
                                            usage_rate_or_amount),
                                 4,wor.temp_relieved_value)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
                          nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          nvl(cdo.rate_or_amount,0)),
                          nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                          3,i_txn_qty*
                          decode(wor.basis_type,
                                 1,wor.usage_rate_or_amount,
                                 2,wor.usage_rate_or_amount/l_lot_size),
                          4,nvl(wor.temp_relieved_value,0))))
        FROM
         wip_operation_overheads w2,
         cst_department_overheads cdo,
         wip_operations wo,
         wip_operation_resources wor,
         cst_resource_overheads cro
        WHERE
         w2.wip_entity_id       =       w1.wip_entity_id        AND
         w2.organization_id     =       w1.organization_id      AND
         w2.operation_seq_num   =       w1.operation_seq_num    AND
         w2.overhead_id         =       w1.overhead_id          AND
         w2.basis_type          =       w1.basis_type           AND
         w2.resource_seq_num    =       w1.resource_seq_num     AND
         w2.wip_entity_id       =       wo.wip_entity_id        AND
         w2.organization_id     =       wo.organization_id      AND
         w2.operation_seq_num   =       wo.operation_seq_num    AND
         w2.wip_entity_id       =       wor.wip_entity_id       AND
         w2.organization_id     =       wor.organization_id     AND
         w2.operation_seq_num   =       wor.operation_seq_num   AND
         w2.resource_seq_num    =       wor.resource_seq_num    AND
         CDO.DEPARTMENT_ID      =       DECODE(WOR.PHANTOM_FLAG,
	                 		1,WOR.DEPARTMENT_ID,
			                WO.DEPARTMENT_ID)       AND
         cdo.overhead_id        =       w2.overhead_id          AND
         cdo.basis_type         =       w2.basis_type           AND
         cdo.cost_type_id       =       i_res_cost_type_id	AND
         cro.overhead_id        =       cdo.overhead_id         AND
         cro.resource_id        =       wor.resource_id         AND
         cro.cost_type_id       =       i_res_cost_type_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id                AND
        w1.basis_type           IN      (3,4)                   AND
        EXISTS
         (
          SELECT 'X'
          FROM
          cst_department_overheads cdo2,
          wip_operations wo2,
          cst_resource_overheads cro2,
          wip_operation_resources wor2
          WHERE
         w1.wip_entity_id       =       wo2.wip_entity_id       AND
         w1.organization_id     =       wo2.organization_id     AND
         w1.operation_seq_num   =       wo2.operation_seq_num   AND
         w1.wip_entity_id       =       wor2.wip_entity_id      AND
         w1.organization_id     =       wor2.organization_id    AND
         w1.operation_seq_num   =       wor2.operation_seq_num  AND
         w1.resource_seq_num    =       wor2.resource_seq_num   AND
         wor2.usage_rate_or_amount <>	0			AND
         cdo2.department_id     =       DECODE(wor2.phantom_flag,
	                                1,wor2.department_id,
                        		wo2.department_id)      AND
         cdo2.overhead_id       =       w1.overhead_id          AND
         cdo2.basis_type        =       w1.basis_type           AND
         cdo2.cost_type_id      =       i_res_cost_type_id      AND
         cdo2.overhead_id       =       cro2.overhead_id        AND
         cro2.resource_id       =       wor2.resource_id        AND
         cro2.cost_type_id      =       i_res_cost_type_id);

        END IF; -- System option if condition ends here.


      END IF;   -- Main If ends here.

        /************************************************************
        * Insert into mtl_cst_txn_cost_details now that the         *
        * Costs have been computed ...				    *
        * 3 statements are required --> one each for PL costs 	    *
        * , TL Res/OSP costs and TL ovhd costs.			    *
        * Remember - the cst_txn_cost_detail tables stores unit     *
        * cost - but the wip tables store the value in the          *
        * temp_relieved_value column - so we have to divide by the  *
        * txn_qty to arrive at the unit cost.			    *
        ************************************************************/

        IF(l_insert_ind <> 1) THEN
        /*BUG 7346225: For Final completion the MCTCD should be populated from
         WPB since this one has rounded values not like WROCD, WOR or WOO and
         this is prefered since Final completion should relieve the accounted
         value */

        IF (i_final_comp_flag='Y') THEN
        stmt_num := 350;
        /* Bug 7346243: Removed Variance value from Available
                        Value for Final Completion */
           INSERT INTO mtl_cst_txn_cost_details
           (
            TRANSACTION_ID,
            ORGANIZATION_ID,
            INVENTORY_ITEM_ID,
            COST_ELEMENT_ID,
            LEVEL_TYPE,
            TRANSACTION_COST,
            NEW_AVERAGE_COST,
            PERCENTAGE_CHANGE,
            VALUE_CHANGE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE)
           SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           1,
           decode(cce.cost_element_id,
               1,sum(0 - nvl(tl_material_out,0)-nvl(tl_material_var,0)),
	       2,sum(0 - nvl(tl_material_overhead_out,0)-nvl(tl_material_overhead_var,0)),
	       3,sum(nvl(tl_resource_in,0)-nvl(tl_resource_out,0)-nvl(tl_resource_var,0)),
	       4,sum(nvl(tl_outside_processing_in,0)-nvl(tl_outside_processing_out,0)-nvl(tl_outside_processing_var,0)),
	       5,sum(nvl(tl_overhead_in,0)-nvl(tl_overhead_out,0)-nvl(tl_overhead_var,0)))/i_txn_qty,
           NULL,
           NULL,
           NULL,
           SYSDATE,
           i_user_id,
           SYSDATE,
           i_user_id,
           i_login_id,
           i_request_id,
           i_prog_appl_id,
           i_prog_id,
           SYSDATE
           FROM
           CST_COST_ELEMENTS CCE,
           WIP_PERIOD_BALANCES WPB
           WHERE
           WPB.WIP_ENTITY_ID  = I_WIP_ENTITY_ID  AND
           WPB.ORGANIZATION_ID = I_ORG_ID AND
           CCE.COST_ELEMENT_ID  <> 2
           GROUP BY CCE.COST_ELEMENT_ID, WPB.WIP_ENTITY_ID;

           stmt_num := 355;
           /* Bug 7346243: Removed Variance value from Available
                       Value for Final Completion */
           INSERT INTO mtl_cst_txn_cost_details
           (
            TRANSACTION_ID,
            ORGANIZATION_ID,
            INVENTORY_ITEM_ID,
            COST_ELEMENT_ID,
            LEVEL_TYPE,
            TRANSACTION_COST,
            NEW_AVERAGE_COST,
            PERCENTAGE_CHANGE,
            VALUE_CHANGE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE)
           SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           2,
           decode(cce.cost_element_id,
               1,sum(nvl(pl_material_in,0) - nvl(pl_material_out,0)-nvl(pl_material_var,0)),
               2,sum(nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)-nvl(pl_material_overhead_var,0)),
               3,sum(nvl(pl_resource_in,0)-nvl(pl_resource_out,0)-nvl(pl_resource_var,0)),
               4,sum(nvl(pl_outside_processing_in,0)-nvl(pl_outside_processing_out,0)-nvl(pl_outside_processing_var,0)),
               5,sum(nvl(pl_overhead_in,0)-nvl(pl_overhead_out,0)-nvl(pl_overhead_var,0)))/i_txn_qty,
           NULL,
           NULL,
           NULL,
           SYSDATE,
           i_user_id,
           SYSDATE,
           i_user_id,
           i_login_id,
           i_request_id,
           i_prog_appl_id,
           i_prog_id,
           SYSDATE
           FROM
           CST_COST_ELEMENTS CCE,
           WIP_PERIOD_BALANCES WPB
           WHERE
           WPB.WIP_ENTITY_ID  = I_WIP_ENTITY_ID AND
           WPB.ORGANIZATION_ID             =       I_ORG_ID
           GROUP BY CCE.COST_ELEMENT_ID, WPB.WIP_ENTITY_ID;

           ELSE
        stmt_num := 360;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        wrocd.cost_element_id,
        2,
        sum(nvl(wrocd.temp_relieved_value,0))/i_txn_qty,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        WIP_REQ_OPERATION_COST_DETAILS wrocd
        where
        WIP_ENTITY_ID	=	i_wip_entity_id 	AND
        ORGANIZATION_ID	=	i_org_id
        GROUP BY wrocd.cost_element_id
        HAVING sum(nvl(wrocd.temp_relieved_value,0))  <> 0;


        stmt_num := 370;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         br.cost_element_id,
         1,
         sum(nvl(wor.temp_relieved_value,0))/i_txn_qty,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
        FROM
        BOM_RESOURCES BR,
        WIP_OPERATION_RESOURCES WOR
        WHERE
        WOR.RESOURCE_ID	 	=	BR.RESOURCE_ID		AND
        WOR.ORGANIZATION_ID	=	BR.ORGANIZATION_ID	AND
        WOR.WIP_ENTITY_ID	=	i_wip_entity_id		AND
        WOR.ORGANIZATION_ID	=	i_org_id
        GROUP BY BR.COST_ELEMENT_ID
        HAVING sum(nvl(wor.temp_relieved_value,0))  <> 0;

        stmt_num := 390;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         5,
         1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
        FROM
        WIP_OPERATION_OVERHEADS
        WHERE
        WIP_ENTITY_ID           =       i_wip_entity_id         AND
        ORGANIZATION_ID         =       i_org_id
        HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;

        END IF;

        stmt_num := 400;
        --
        -- R11.5  Enhanced Final Completion
        --
        IF (i_final_comp_flag = 'Y' AND l_comp_cost_source = 1
        AND l_use_val_cost_type <> -1) THEN

           ---------------------------------------------
           -- Check if there is any -ve final completion
           -- for TL R, O, OSP and PL cost elements
           ---------------------------------------------
           stmt_num := 410;
           SELECT count(*)
           INTO l_count
           FROM   mtl_cst_txn_cost_details  mctcd,
                  mtl_material_transactions mmt
           WHERE mctcd.transaction_id = mmt.transaction_id
           AND   mctcd.transaction_id = i_trx_id
           AND   mctcd.transaction_cost < 0;

           IF (l_count <> 0) THEN

                -----------------------------------------
                -- insert into wip_cost_txn_interface
                -----------------------------------------
                -- Get wip txn_id
                -----------------------------------------
                stmt_num := 440;

                SELECT wip_transactions_s.nextval
                INTO l_wcti_txn_id
                FROM dual;

                ----------------------------------------------------------------
                -- Insert into WCTI
                ----------------------------------------------------------------
                stmt_num := 460;
                INSERT INTO wip_cost_txn_interface
                 (transaction_id,
                 acct_period_id,
                 process_status,
                 process_phase,
                 transaction_type,
                 organization_id,
                 wip_entity_id,
                 wip_entity_name,
                 entity_type,
                 transaction_date,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
                 SELECT
                    l_wcti_txn_id,
                    i_acct_period_id,
                    2,
                    3,
                    7,  -- new transaction_type for final completion variance
                    i_org_id,
                    i_wip_entity_id,
                    w.wip_entity_name,
                    1,
                    i_txn_date,
                    sysdate,
                    i_user_id,
                    i_login_id,
                    sysdate,
                    i_user_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate
                 FROM
                    wip_entities w
                 WHERE
                     w.wip_entity_id   = i_wip_entity_id
                 AND w.organization_id = i_org_id;

              neg_final_completion(  i_org_id  		=> i_org_id,
                                     i_txn_date  	=> i_txn_date,
                                     i_wip_entity_id 	=> i_wip_entity_id,
                                     i_wcti_txn_id   	=> l_wcti_txn_id,
                                     i_txn_qty		=> i_txn_qty,
                                     i_trx_id 		=> i_trx_id,
                                     i_acct_period_id	=> i_acct_period_id,
                                     i_user_id   	=> i_user_id,
                                     i_login_id  	=> i_login_id,
                                     i_request_id    	=> i_request_id,
                                     i_prog_id 		=> i_prog_id,
                                     i_prog_appl_id	=> i_prog_appl_id,
                                     err_num		=> l_err_num,
                                     err_code 		=> l_err_code,
                                     err_msg 		=> l_err_msg);

              IF (l_err_num <> 0) THEN
                 raise proc_fail;
              END IF;

              END IF;
           END IF;
        END IF;

 EXCEPTION
        WHEN proc_fail THEN
        err_num := l_err_num;
        err_code := l_err_code;
        err_msg := l_err_msg;

        WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := 'CSTPACWC:' || ' complete:' || to_char(stmt_num) || ':' ||
                    substr(SQLERRM,1,150);

 END complete;

 PROCEDURE neg_final_completion (
 i_org_id  		IN      NUMBER,
 i_txn_date		IN      DATE,
 i_wip_entity_id 	IN	NUMBER,
 i_wcti_txn_id 		IN      NUMBER,
 i_txn_qty		IN	NUMBER,
 i_trx_id		IN 	NUMBER,
 i_acct_period_id	IN 	NUMBER,
 i_user_id		IN      NUMBER,
 i_login_id 		IN      NUMBER,
 i_request_id 		IN      NUMBER,
 i_prog_id 		IN      NUMBER,
 i_prog_appl_id 	IN      NUMBER,
 err_num		OUT NOCOPY     NUMBER,
 err_code		OUT NOCOPY     VARCHAR2,
 err_msg		OUT NOCOPY     VARCHAR2)
IS
 stmt_num 	NUMBER;
 l_pri_curr	VARCHAR2(15);
 l_sob_id 	NUMBER;

 /* Bug 8277421 */
 l_trx_info         CST_XLA_PVT.t_xla_wip_trx_info;
 l_return_status    VARCHAR2(10);
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);

BEGIN

   stmt_num := 461;

 /* The following line in the FROM clause has been commented out because
     we will now have to refer cst_organization_definitions as an impact
    of the HR-PROFILE option.*/

   SELECT set_of_books_id
   INTO l_sob_id
   /*FROM org_organization_definitions*/
   FROM cst_organization_definitions
   WHERE organization_id = i_org_id;

   stmt_num := 462;
   SELECT currency_code
   INTO l_pri_curr
   FROM gl_sets_of_books
   WHERE set_of_books_id = l_sob_id;

   stmt_num := 465;
   INSERT INTO wip_transactions
  (transaction_id,
   acct_period_id,
   transaction_type,
   organization_id,
   wip_entity_id,
   transaction_date,
   last_update_date,
   last_updated_by,
   last_update_login,
   creation_date,
   created_by,
   request_id,
   program_application_id,
   program_id,
   program_update_date)
SELECT
   wcti.transaction_id,
   wcti.acct_period_id,
   wcti.transaction_type,
   wcti.organization_id,
   wcti.wip_entity_id,
   wcti.transaction_date,
   sysdate,
   i_user_id,
   i_login_id,
   sysdate,
   i_user_id,
   i_request_id,
   i_prog_appl_id,
   i_prog_id,
   sysdate
FROM wip_cost_txn_interface wcti
WHERE transaction_id = i_wcti_txn_id;

/*------------------------------------------+
| Do Accounting for wip valuation accounts
+-------------------------------------------*/
stmt_num := 470;
INSERT INTO wip_transaction_accounts
  (transaction_id,            reference_account,
   last_update_date,           last_updated_by,
   creation_date,              created_by,
   last_update_login,          organization_id,
   transaction_date,           wip_entity_id,
   repetitive_schedule_id,     accounting_line_type,
   transaction_value,          base_transaction_value,
   contra_set_id,              primary_quantity,
   rate_or_amount,             basis_type,
   resource_id,                cost_element_id,
   activity_id,                currency_code,
   currency_conversion_date,   currency_conversion_type,
   currency_conversion_rate,
   request_id,                 program_application_id,
   program_id,                 program_update_date)
SELECT
   i_wcti_txn_id,
   decode(mctcd.cost_element_id,
      1, wdj.material_account,
      2, wdj.material_overhead_account,
      3, wdj.resource_account,
      4, wdj.outside_processing_account,
      5, wdj.overhead_account),
   sysdate,		i_user_id,
   sysdate,		i_user_id,
   i_login_id,		i_org_id,
   i_txn_date,		i_wip_entity_id,
   NULL,		7,
   NULL,
   decode(c1.minimum_accountable_unit,
        NULL, round(-SUM(mctcd.transaction_cost)*i_txn_qty,c1.precision),
        round(-SUM(mctcd.transaction_cost)*i_txn_qty/c1.minimum_accountable_unit)
        * c1.minimum_accountable_unit),
   NULL,		NULL,
   NULL,		NULL,
   NULL,		mctcd.cost_element_id,
   NULL,		NULL,
   NULL,		NULL,
   NULL,
   i_request_id,	i_prog_appl_id,
   i_prog_id,		sysdate
FROM mtl_cst_txn_cost_details mctcd,
     mtl_material_transactions mmt,
     wip_discrete_jobs wdj,
     fnd_currencies c1
WHERE mctcd.transaction_id = mmt.transaction_id
AND   mmt.transaction_source_id = wdj.wip_entity_id
AND   mctcd.transaction_id = i_trx_id
AND   mctcd.transaction_cost < 0
 AND   c1.currency_code = l_pri_curr
GROUP BY
  decode(mctcd.cost_element_id,
        1, wdj.material_account,
        2, wdj.material_overhead_account,
        3, wdj.resource_account,
        4, wdj.outside_processing_account,
        5, wdj.overhead_account),
        mctcd.cost_element_id,
  c1.minimum_accountable_unit,
  c1.precision;
/*------------------------------------------+
| Do Accounting for wip variance accounts
+-------------------------------------------*/
stmt_num := 480;
INSERT INTO wip_transaction_accounts
   (transaction_id,            reference_account,
    last_update_date,           last_updated_by,
    creation_date,              created_by,
    last_update_login,          organization_id,
    transaction_date,           wip_entity_id,
    repetitive_schedule_id,     accounting_line_type,
    transaction_value,          base_transaction_value,
    contra_set_id,              primary_quantity,
    rate_or_amount,             basis_type,
    resource_id,                cost_element_id,
    activity_id,                currency_code,
    currency_conversion_date,   currency_conversion_type,
    currency_conversion_rate,
    request_id,                 program_application_id,
    program_id,                 program_update_date)
SELECT
    i_wcti_txn_id,
    wdj.material_variance_account,
    sysdate,		i_user_id,
    sysdate,		i_user_id,
    i_login_id,		i_org_id,
    i_txn_date,		i_wip_entity_id,
    NULL,		8,
    NULL,
   /* decode(c1.minimum_accountable_unit,
        NULL, round(SUM(mctcd.transaction_cost)*i_txn_qty,c1.precision),
        round(SUM(mctcd.transaction_cost)*i_txn_qty/c1.minimum_accountable_unit)
        * c1.minimum_accountable_unit), */
   decode(c1.minimum_accountable_unit,
         NULL, SUM(round((mctcd.transaction_cost*i_txn_qty),c1.precision)),
 	 sum(round((mctcd.transaction_cost*i_txn_qty)/c1.minimum_accountable_unit)
 	 * c1.minimum_accountable_unit)),
    NULL,		NULL,
    NULL,		NULL,
    NULL,		1,
    NULL,		NULL,
    NULL,		NULL,
    NULL,
    i_request_id,	i_prog_appl_id,
    i_prog_id,		sysdate
FROM mtl_cst_txn_cost_details mctcd,
     mtl_material_transactions mmt,
     wip_discrete_jobs wdj,
     fnd_currencies c1
WHERE mctcd.transaction_id = mmt.transaction_id
AND   mmt.transaction_source_id = wdj.wip_entity_id
AND   mctcd.transaction_id = i_trx_id
AND   mctcd.transaction_cost < 0
AND   mctcd.level_type = 2
AND   c1.currency_code = l_pri_curr
GROUP BY
  wdj.material_variance_account,
  c1.minimum_accountable_unit,
  c1.precision;

stmt_num := 490;
INSERT INTO wip_transaction_accounts
  (transaction_id,            reference_account,
   last_update_date,           last_updated_by,
   creation_date,              created_by,
   last_update_login,          organization_id,
   transaction_date,           wip_entity_id,
   repetitive_schedule_id,     accounting_line_type,
   transaction_value,          base_transaction_value,
   contra_set_id,              primary_quantity,
   rate_or_amount,             basis_type,
   resource_id,                cost_element_id,
   activity_id,                currency_code,
   currency_conversion_date,   currency_conversion_type,
   currency_conversion_rate,
   request_id,                 program_application_id,
   program_id,                 program_update_date)
SELECT
   i_wcti_txn_id,
   decode(mctcd.cost_element_id,
      3, wdj.resource_variance_account,
      4, wdj.outside_proc_variance_account,
      5, wdj.overhead_variance_account),
   sysdate,		i_user_id,
   sysdate,		i_user_id,
   i_login_id,		i_org_id,
   i_txn_date,	i_wip_entity_id,
   NULL,		8,
   NULL,
   decode(c1.minimum_accountable_unit,
        NULL, round(mctcd.transaction_cost*i_txn_qty,c1.precision),
        round(mctcd.transaction_cost*i_txn_qty/c1.minimum_accountable_unit)
        * c1.minimum_accountable_unit),
   NULL,		NULL,
   NULL,		NULL,
   NULL,		mctcd.cost_element_id,
   NULL,		NULL,
   NULL,		NULL,
   NULL,
   i_request_id,	i_prog_appl_id,
   i_prog_id,		sysdate
FROM mtl_cst_txn_cost_details mctcd,
     mtl_material_transactions mmt,
     wip_discrete_jobs wdj,
     fnd_currencies c1
WHERE mctcd.transaction_id = mmt.transaction_id
AND   mmt.transaction_source_id = wdj.wip_entity_id
AND   mctcd.transaction_id = i_trx_id
AND   mctcd.transaction_cost < 0
AND   mctcd.level_type = 1
AND   mctcd.cost_element_id in (3,4,5)
AND   c1.currency_code = l_pri_curr;

stmt_num := 491;

UPDATE WIP_TRANSACTION_ACCOUNTS
SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
WHERE  TRANSACTION_ID = i_wcti_txn_id;

/* Bug 8277421 */
stmt_num := 492;
IF SQL%ROWCOUNT > 0 THEN

  stmt_num := 493;
  l_trx_info.transaction_id      := i_wcti_txn_id;
  l_trx_info.inv_organization_id := i_org_id;
  l_trx_info.wip_resource_id     := -1;
  l_trx_info.wip_basis_type_id   := -1;
  l_trx_info.txn_type_id         := 7;
  l_trx_info.transaction_date    := i_txn_date;

  CST_XLA_PVT.Create_WIPXLAEvent  (
    p_api_version       => 1,
    p_init_msg_list    => FND_API.G_FALSE,
    p_commit           => FND_API.G_FALSE,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_trx_info         => l_trx_info);

END IF;

stmt_num := 495;
DELETE wip_cost_txn_interface
WHERE transaction_id = i_wcti_txn_id;

stmt_num := 500;
UPDATE wip_period_balances wpb
SET
  (last_update_date,
   last_updated_by,
   last_update_login,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   pl_material_var,
   pl_material_overhead_var,
   pl_resource_var,
   pl_outside_processing_var,
   pl_overhead_var,
   tl_material_var,
   tl_material_overhead_var,
   tl_resource_var,
   tl_outside_processing_var,
   tl_overhead_var) =
(SELECT
    sysdate,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    sysdate,
    pl_material_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty*sum(decode(level_type,
                                              2,decode(cost_element_id,
                                             1,nvl(transaction_cost,0)
                                             ,0),0)),c1.precision),
                                  round((i_txn_qty*sum(decode(level_type,
                                              2,decode(cost_element_id,
                                              1,nvl(transaction_cost,0)
                                              ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    pl_material_overhead_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty*sum(decode(level_type,
                                                2,decode(cost_element_id,
                                               2,nvl(transaction_cost,0)
                                               ,0),0)),c1.precision),
                                  round((i_txn_qty*sum(decode(level_type,
                                                2,decode(cost_element_id,
                                                2,nvl(transaction_cost,0)
                                                ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    pl_resource_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty*sum(decode(level_type,
                                                2,decode(cost_element_id,
                                                3,nvl(transaction_cost,0)
                                                ,0),0)),c1.precision),
                                  round((i_txn_qty*sum(decode(level_type,
                                                2,decode(cost_element_id,
                                                 3,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    pl_outside_processing_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty*sum(decode(level_type,
                                                 2,decode(cost_element_id,
                                                 4,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty*sum(decode(level_type,
                                                 2,decode(cost_element_id,
                                                 4,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    pl_overhead_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty*sum(decode(level_type,
                                                 2,decode(cost_element_id,
                                                 5,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty*sum(decode(level_type,
                                                 2,decode(cost_element_id,
                                                 5,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    tl_material_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 1,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 1,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    tl_material_overhead_var + 0,       /* The TL MO never gets Cr to the Job*/
    tl_resource_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 3,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 3,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    tl_outside_processing_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 4,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 4,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit),
    tl_overhead_var + decode(c1.minimum_accountable_unit,
                                  NULL, round(i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 5,nvl(transaction_cost,0)
                                                 ,0),0)),c1.precision),
                                  round((i_txn_qty* sum(decode(level_type,
                                                 1,decode(cost_element_id,
                                                 5,nvl(transaction_cost,0)
                                                 ,0),0)))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit)
FROM
    mtl_cst_txn_cost_details        mctcd,
    fnd_currencies                  c1
WHERE  transaction_id          = i_trx_id
AND    transaction_cost        < 0
AND    c1.currency_code        = l_pri_curr
GROUP BY c1.minimum_accountable_unit, c1.precision)
WHERE
    wip_entity_id           =       i_wip_entity_id         AND
    organization_id         =       i_org_id                AND
    acct_period_id          =       i_acct_period_id;

stmt_num := 510;
--
-- We have to re-avg with 0 cost but not -ve cost
--
UPDATE mtl_cst_txn_cost_details
SET transaction_cost = 0
WHERE transaction_cost < 0
AND transaction_id = i_trx_id;

EXCEPTION
WHEN OTHERS THEN
   err_code := 'neg_final_completion';
   err_num := SQLCODE;
   err_msg := 'CSTPACWC:' || 'neg_final_comletion: ' ||
              to_char(stmt_num) || ':' || substr(SQLERRM,1,150);

END neg_final_completion;

 PROCEDURE assembly_return (
 i_trx_id               IN      NUMBER,
 i_txn_qty              IN      NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_org_id               IN      NUMBER,
 i_inv_item_id          IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 i_layer_id		IN	NUMBER,
 i_movhd_cost_type_id	OUT NOCOPY	NUMBER,
 i_res_cost_type_id     IN	NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2)

 is

        stmt_num                NUMBER;
        l_system_option_id	NUMBER;
        i_lot_size              NUMBER;
        l_comp_cost_source      NUMBER;
        l_c_cost_type_id        NUMBER;
        l_insert_ind		NUMBER;
        l_use_val_cost_type 	NUMBER;
        l_routing_check         NUMBER := 0;
        l_qty_per_assy          NUMBER; /* bug 3504776 */
        l_include_comp_yield    NUMBER;


 BEGIN

        /***************************************************
        * Update temp_relieved_value to zero in all tables *
        ***************************************************/

        stmt_num := 10;

        UPDATE WIP_REQ_OPERATION_COST_DETAILS
        SET temp_relieved_value = 0
        where
        WIP_ENTITY_ID = i_wip_entity_id;

        stmt_num := 20;

        UPDATE WIP_OPERATION_RESOURCES
        SET temp_relieved_value = 0
        where
        WIP_ENTITY_ID = i_wip_entity_id;

        stmt_num := 30;

        UPDATE WIP_OPERATION_OVERHEADS
        SET temp_relieved_value = 0
        where
        WIP_ENTITY_ID = i_wip_entity_id;

        stmt_num := 40;



        select wac.completion_cost_source, nvl(wac.cost_type_id,-1),
               wdj.start_quantity,nvl(system_option_id,-1)
        into l_comp_cost_source,l_c_cost_type_id,i_lot_size,
             l_system_option_id
        from
        wip_accounting_classes wac,
        wip_discrete_jobs wdj
        where
        wdj.wip_entity_id               =       i_wip_entity_id         and
        wdj.organization_id             =       i_org_id                and
        wdj.class_code                  =       wac.class_code          and
        wdj.organization_id             =       wac.organization_id;


        l_insert_ind := 0;

        stmt_num := 60;

        /*---------------------------------------------------
        | If a non-std job has no bill or routing associated
        | with it or if a std job has no bill or routing
        | associated with it - these need to be treated
        | specially.
        |-----------------------------------------------------+*/

        SELECT
        decode(job_type,
               1,decode(bom_revision,
                        NULL,decode(routing_revision,NULL,-1,1),
                        1),
               3,decode(bom_reference_id,
                        NULL,decode(routing_reference_id,NULL,-1,1),
                        1),
               1)
        into
        l_use_val_cost_type
        from
        WIP_DISCRETE_JOBS
        WHERE
        WIP_ENTITY_ID           =               i_wip_entity_id         AND
        ORGANIZATION_ID         =               i_org_id;

        /* Bug 3504776 - the standard material requirements can be added manually for the job.
           In this case, we want to derive the completion costs based on job costs */
        if (l_use_val_cost_type = -1) then
        /* Commented for Bug6734270.If there is a resource added manually
           then also the l_use_val_cost_type should be 1
           select count(*)
           into l_qty_per_assy
           from wip_requirement_operations
           where wip_entity_id = i_wip_entity_id
           and quantity_per_assembly <>0;
         */
            SELECT COUNT(1)
            INTO   l_qty_per_assy
            FROM   dual
            WHERE  EXISTS ( SELECT NULL
                            FROM   wip_requirement_operations wro
                            WHERE  wro.wip_entity_id = i_wip_entity_id
                            AND    wro.quantity_per_assembly <>0
                                UNION ALL
                            SELECT NULL
                            FROM   wip_operation_resources wor
                            WHERE  wor.wip_entity_id = i_wip_entity_id
                            AND    wor.usage_rate_or_amount <>0
                           );


           if (l_qty_per_assy > 0) then
              l_use_val_cost_type := 1;
           end if;
        end if;

        /*----------------------------------------------
        | If the completions are costed by the system, we
        | follow the system rules for earning material
        | ovhd upon completion. If the completion is
        | costed by the cost type then we will earn
        | material overhead based on the costs in the cost type
        | We need to figure out, for the given job, where the
        | costs are coming from and hence how MO is to be
        | earned. This info will passed back to the calling
        | rotuine and used by the cost processor.
        |--------------------------------------------------+*/

        stmt_num := 90;

        IF (l_comp_cost_source=1) THEN
        i_movhd_cost_type_id:= i_res_cost_type_id;
        ELSE i_movhd_cost_type_id:=l_c_cost_type_id;
        END IF;

        /*-------------------------------------------------
        | If the Completions are performed from a User spec
        | cost type, the returns should also be performed
        | from that cost type. So, check this condition.
        --------------------------------------------------*/

        /*-------------------------------------------------
        | As in the case of completions from a cost type, if
        | the cost type specified is different from the avg
        | cost type we drive from CICD.
        |--------------------------------------------------*/

        IF (l_comp_cost_source = 2 AND l_c_cost_type_id > 0 AND
            l_c_cost_type_id <> 2) THEN

        l_insert_ind := 1;

        stmt_num := 70;

         INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        COST_ELEMENT_ID,
        LEVEL_TYPE,
        SUM(ITEM_COST),
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        CST_ITEM_COST_DETAILS
        WHERE
        INVENTORY_ITEM_ID               =       I_INV_ITEM_ID           AND
        ORGANIZATION_ID                 =       I_ORG_ID                AND
        COST_TYPE_ID                    =       L_C_COST_TYPE_ID	AND
        NOT (COST_ELEMENT_ID		=	2			AND
             LEVEL_TYPE			=	1)
        GROUP BY COST_ELEMENT_ID,LEVEL_TYPE
        HAVING SUM(ITEM_COST) <> 0;



        /*------------------------------------------------------
        | If completions are from a cost type and the cost type
        | is the average cost type, drive from CLCD.
        | 			OR
        | If completions are supposed to be system derived but
        | the job has no bill/routing(==> we use valuation
        | cost type).
        |-----------------------------------------------------*/

        ELSIF((l_comp_cost_source = 2 AND l_c_cost_type_id = 2)
                                  OR
             (l_comp_cost_source = 1 AND l_use_val_cost_type = -1)) THEN


        l_insert_ind := 1;

        stmt_num := 80;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
         SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         ITEM_COST,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
         FROM
         CST_LAYER_COST_DETAILS
         WHERE
         LAYER_ID               =               i_layer_id	AND
         NOT (COST_ELEMENT_ID	=		2		AND
              LEVEL_TYPE	=		1);

        /*---------------------------------------------------
                New Assembly Return Algorithm

        For System I (User-defined)
        ---------------------------
        - PL materials (Both System I and System II)
        - Resources
        - Ovhd
        If CompU = 0 OR CompV = 0
        CompU, CompV = unchanged

        If Sign(CompU) <> Sign(CompV)
        CompU, CompV = unchanged

        If Sign(CompU) = Sign(CompV)
                IF CompU > Q*Usage_rate => QTR (quantity to Relieve)
                CompU = CompU + Q*Usage_rate
                CompV = CompV + CompV/CompU * Q * Usage_rate

                IF CompU = Q*Usage
                CompU = 0
                CompV = 0

                IF CompU < Q*Usage
                        IF CompU and CompV > 0
                        CompU = 0
                        CompV = 0

                        IF CompU and CompV < 0
                        CompU, CompV = unchanged


        For System II (Actual)
        ---------------------
        - Resources
        - Ovhd

        IF CompU < 0
        CompU and CompV unchanged

        ----------------------------------------------------*/

        /*---------------------------------------------------
        | If completion costs are system calculated ...
        |---------------------------------------------------*/

        ELSIF (l_comp_cost_source = 1 AND l_use_val_cost_type <> -1) THEN


      /******************************************************
      * Compute PL Costs for  WIP Assembly Return 	    *
      ******************************************************/

      /* Bug fix for 918694
         Assembly return for PL cost elements should be the same
         as TL resource, ovhd and OSP.
         ie. using actual alogrithm to return for all the PL/TL
         cost elements no matter what system alogrithm users
         has chosen.
         I am still keeping the codes but comment out
         in case users request in the future.
      */

        stmt_num := 100;

       /* Bug fix for 2138569
         For jobs that have no routing, but the assembly has a BOM.
         The table cst_comp_snap_temp does not get populated and thus
         there are no rows in cst_comp_snapshot table.  Resulting which
         the calculations based on the CCS table returns zero value.
         And value of Assembly returned is incorrect.

         To fix this, have decided to check if the wip_operations table
         has any rows for the job(wip_entity_id).  If no rows exist then
         will use the WRO and WROCD tables to calculate the value else
         will use the CCS table to calculate the values.
      */

        l_routing_check := 0;

        select count(1)
          into l_routing_check
          from wip_operations wo
         where wo.wip_entity_id = i_wip_entity_id;

        if l_routing_check > 0
        then

          stmt_num := 105;

          UPDATE wip_req_operation_cost_details w1
          SET
            (temp_relieved_value,
             relieved_matl_completion_value) =
            (SELECT
                --
                -- temp_relieved_value
                --
                decode(SIGN(w2.relieved_matl_completion_value),sign(wro.quantity_per_assembly),
                nvl(W2.relieved_matl_completion_value,0)*
                decode(abs(i_txn_qty),
                       prior_completion_quantity,-1,
                       i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                        prior_completion_quantity)),
                       0),
                ---
                --- relieved_matl_completion_value
                ---
                nvl(w1.relieved_matl_completion_value,0)+
                decode(SIGN(w2.relieved_matl_completion_value),sign(wro.quantity_per_assembly),
                       nvl(w2.relieved_matl_completion_value,0)*
                       decode(abs(i_txn_qty),
                              prior_completion_quantity,-1,
                              i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                               prior_completion_quantity)),
                       0)
             FROM
                wip_req_operation_cost_details w2,
		wip_requirement_operations wro,
                cst_comp_snapshot cocd
             WHERE
                w1.wip_entity_id       =       w2.wip_entity_id        AND
                w1.organization_id     =       w2.organization_id      AND
                w1.operation_seq_num   =       w2.operation_seq_num    AND
                w1.inventory_item_id   =       w2.inventory_item_id    AND
                w1.cost_element_id     =       w2.cost_element_id      AND
                w2.wip_entity_id	=	cocd.wip_entity_id	AND
                w2.operation_seq_num	=	cocd.operation_seq_num	AND
                cocd.new_operation_flag =	2			AND
                cocd.transaction_id	=	i_trx_id                AND
		wro.wip_entity_id       =       w2.wip_entity_id        AND
		wro.organization_id     =       w2.organization_id      AND
		wro.inventory_item_id   =       w2.inventory_item_id    AND
		wro.operation_seq_num   =       w2.operation_seq_num
             )
          WHERE
           w1.wip_entity_id	=	i_wip_entity_id		AND
           w1.organization_id	=	i_org_id;

          stmt_num := 107;

          UPDATE wip_requirement_operations w1
          SET
            relieved_matl_completion_qty =
            (SELECT
                --
                -- relieved_matl_completion_qty
                --
                nvl(w1.relieved_matl_completion_qty,0)+
                decode(SIGN(SUM(nvl(wrocd.relieved_matl_completion_value  - wrocd.temp_relieved_value,0))),sign(w1.quantity_per_assembly),
                       nvl(w2.relieved_matl_completion_qty,0)*
                       decode(abs(i_txn_qty),
                              prior_completion_quantity,-1,
                              i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                               prior_completion_quantity)),
                0)
             FROM
                wip_req_operation_cost_details wrocd,
                wip_requirement_operations w2,
                cst_comp_snapshot cocd
             WHERE
                w1.wip_entity_id        = w2.wip_entity_id        AND
                w1.inventory_item_id    = w2.inventory_item_id    AND
                w1.operation_seq_num    = w2.operation_seq_num    AND
                w1.organization_id      = w2.organization_id      AND
                w2.wip_entity_id        = wrocd.wip_entity_id     AND
                w2.organization_id      = wrocd.organization_id   AND
                w2.operation_seq_num    = wrocd.operation_seq_num AND
                w2.inventory_item_id    = wrocd.inventory_item_id AND
                w2.wip_entity_id	   = cocd.wip_entity_id	     AND
                w2.operation_seq_num	   = cocd.operation_seq_num  AND
                cocd.new_operation_flag = 2			     AND
                cocd.transaction_id	   = i_trx_id
             GROUP BY
                w2.wip_entity_id,
                w2.organization_id,
                w2.inventory_item_id,
                w2.operation_seq_num,
                prior_completion_quantity,
                w2.relieved_matl_completion_qty
             )
          WHERE
            w1.wip_entity_id         =       i_wip_entity_id AND
            w1.organization_id       =       i_org_id;

        else

          stmt_num := 110;

          /* Get the value of Include Component yield flag, which will
          determine whether to include or not component yield factor in
          quantity per assembly*/
          SELECT  nvl(include_component_yield, 1)
          INTO    l_include_comp_yield
          FROM    wip_parameters
          WHERE   organization_id = i_org_id;

          stmt_num := 115;

                  UPDATE wip_req_operation_cost_details w1
                  SET
                    (temp_relieved_value,
                     relieved_matl_completion_value) =
                    (SELECT
                        ---
                        --- temp_relieved_value
                        ---
                        DECODE(wro.relieved_matl_completion_qty,0,
                               0,
                               NULL,
                               0,
                               DECODE(w1.relieved_matl_completion_value,0,
                                      0,
                                      NULL,
                                      0,
                                      DECODE(SIGN(wro.relieved_matl_completion_qty),
                                             SIGN(w1.relieved_matl_completion_value),
                                             DECODE(SIGN(wro.relieved_matl_completion_qty-
                                                         /* LBM project Changes */
                                                         ABS(i_txn_qty)*(decode(wro.basis_type, 2,
                                                                        wro.quantity_per_assembly/i_lot_size,
                                                                                wro.quantity_per_assembly)/
                                                                        decode(l_include_comp_yield,
                                                                               1, nvl(wro.component_yield_factor,1),
                                                                               1))),
                                                    SIGN(wro.quantity_per_assembly),
                                                    /* LBM project Changes */
                                                    i_txn_qty*(decode(wro.basis_type, 2,
                                                              wro.quantity_per_assembly/i_lot_size,
                                                                        wro.quantity_per_assembly)/
                                                              decode(l_include_comp_yield,
                                                                     1, nvl(wro.component_yield_factor,1),
                                                                     1))*
                                                      relieved_matl_completion_value/
                                                      wro.relieved_matl_completion_qty,
                                                    0,
                                                    -1*relieved_matl_completion_value,
                                                    DECODE(SIGN(wro.relieved_matl_completion_qty),
                                                           SIGN(wro.quantity_per_assembly),
                                                           -1*relieved_matl_completion_value,
                                                           0)),
                                      0))),
                        ---
                        --- relieved_matl_completion_value
                        ---
                        NVL(relieved_matl_completion_value,0)+
                        DECODE(wro.relieved_matl_completion_qty,0,
                               0,
                               NULL,
                               0,
                               DECODE(w1.relieved_matl_completion_value,0,
                                      0,
                                      NULL,
                                      0,
                                      DECODE(SIGN(wro.relieved_matl_completion_qty),
                                             SIGN(w1.relieved_matl_completion_value),
                                             DECODE(SIGN(wro.relieved_matl_completion_qty-
                                                      /* LBM project Changes */
                                                      ABS(i_txn_qty)*(decode(wro.basis_type, 2,
                                                                      wro.quantity_per_assembly/i_lot_size,
                                                                                wro.quantity_per_assembly)/
                                                                     decode(l_include_comp_yield,
                                                                            1, nvl(wro.component_yield_factor,1),
                                                                            1))),
                                                    SIGN(wro.quantity_per_assembly),
                                                    /* LBM project Changes */
                                                    i_txn_qty*(decode(wro.basis_type, 2,
                                                                wro.quantity_per_assembly/i_lot_size,
                                                                         wro.quantity_per_assembly)/
                                                               decode(l_include_comp_yield,
                                                                      1, nvl(wro.component_yield_factor,1),
                                                                      1))*
                                                      relieved_matl_completion_value/
                                                    wro.relieved_matl_completion_qty,
                                                    0,
                                                    -1*relieved_matl_completion_value,
                                                    DECODE(SIGN(wro.relieved_matl_completion_qty),
                                                           SIGN(wro.quantity_per_assembly),
                                                           -1*relieved_matl_completion_value,
                                                           0)),
                                             0)))
                     FROM
                        wip_req_operation_cost_details w2,
                        wip_requirement_operations wro
                     WHERE
                        w1.wip_entity_id       =       w2.wip_entity_id        AND
                        w1.organization_id     =       w2.organization_id      AND
                        w1.operation_seq_num   =       w2.operation_seq_num    AND
                        w1.inventory_item_id   =       w2.inventory_item_id    AND
                        w1.cost_element_id     =       w2.cost_element_id      AND
                        w2.wip_entity_id       =       wro.wip_entity_id       AND
                        w2.organization_id     =       wro.organization_id     AND
                        w2.operation_seq_num   =       wro.operation_seq_num   AND
                        w2.inventory_item_id   =       wro.inventory_item_id
                     )
                  WHERE
                    (w1.wip_entity_id, w1.organization_id,
                     w1.inventory_item_id, w1.operation_seq_num) IN
                      (SELECT
                        wip_entity_id, organization_id,
                        inventory_item_id,operation_seq_num
                       FROM
                        wip_requirement_operations wro2
                       WHERE
                        wro2.wip_entity_id     =       i_wip_entity_id AND
                        wro2.organization_id   =       i_org_id        AND
                        wro2.quantity_per_assembly     <> 0);

                   stmt_num := 117;

                   UPDATE wip_requirement_operations w
                   SET relieved_matl_completion_qty =
                     (SELECT
                       NVL(w.relieved_matl_completion_qty,0)+
                       DECODE(w.relieved_matl_completion_qty,0,
                           0,
                           NULL,
                           0,
                           DECODE(SUM(nvl(wrocd.relieved_matl_completion_value  - wrocd.temp_relieved_value,0)),0,
                                  0,
                                  NULL,
                                  0,
                                  DECODE(SIGN(w.relieved_matl_completion_qty),
                                         SIGN(SUM(nvl(wrocd.relieved_matl_completion_value - wrocd.temp_relieved_value,0))),
                                         DECODE(SIGN(w.relieved_matl_completion_qty-
                                                      /* LBM project Changes */
                                                      ABS(i_txn_qty)*(decode(w.basis_type, 2,
                                                                w.quantity_per_assembly/i_lot_size,
                                                                         w.quantity_per_assembly)/
                                                                     decode(l_include_comp_yield,
                                                                            1, nvl(w.component_yield_factor,1),
                                                                            1))),
                                                SIGN(w.quantity_per_assembly),
                                                /* LBM project Changes */
                                                i_txn_qty*(decode(w.basis_type, 2,
                                                                w.quantity_per_assembly/i_lot_size,
                                                                        w.quantity_per_assembly)/
                                                           decode(l_include_comp_yield,
                                                                  1, nvl(w.component_yield_factor,1),
                                                                  1)),
                                                0,
                                                -1*relieved_matl_completion_qty,
                                                DECODE(SIGN(w.relieved_matl_completion_qty),
                                                       SIGN(w.quantity_per_assembly),
                                                       -1*relieved_matl_completion_qty,
                                                       0)),
                                         0)))
                      FROM
                        wip_req_operation_cost_details wrocd,
                        wip_requirement_operations w2
                      WHERE
                        w.wip_entity_id     = w2.wip_entity_id         AND
                        w.inventory_item_id = w2.inventory_item_id     AND
                        w.operation_seq_num = w2.operation_seq_num     AND
                        w.organization_id   = w2.organization_id       AND
                        w2.wip_entity_id    = wrocd.wip_entity_id      AND
                        w2.organization_id  = wrocd.organization_id    AND
                        w2.operation_seq_num = wrocd.operation_seq_num AND
                        w2.inventory_item_id = wrocd.inventory_item_id
                      GROUP BY
                        w2.wip_entity_id,
                        w2.organization_id,
                        w2.inventory_item_id,
                        w2.operation_seq_num,
                        w2.quantity_per_assembly,
                        w2.relieved_matl_completion_qty
                      )
                   WHERE
                    w.wip_entity_id         =       i_wip_entity_id AND
                    w.organization_id       =       i_org_id        AND
                    w.quantity_per_assembly <>      0;

        end if;

        /*******************************************************
        * Compute TL resource costs for Assembly return ...    *
        *******************************************************/

        /*
        R11.5 Assembly Return at average cost
        For resources, overheads and OSP
        all return using Actual resources algorithm
        regardless of which system option
        */

        -- If the option is to use Actual resources, then go with the
        -- snapshot table.

        stmt_num := 160;

        UPDATE wip_operation_resources w1
        SET
         (relieved_res_completion_units,
          temp_relieved_value,
          relieved_res_completion_value) =
        (SELECT
          --
          -- relieved_res_completion_units
          --
          nvl(w1.relieved_res_completion_units,0)+
          decode(SIGN(w2.relieved_res_completion_value),1,
                 nvl(w2.relieved_res_completion_units,0)*
                 decode(abs(i_txn_qty),
                        prior_completion_quantity,-1,
                        i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                         prior_completion_quantity)),
                0),
          --
          -- temp_relieved_value
          --
          decode(SIGN(w2.relieved_res_completion_value),1,
          nvl(W2.relieved_res_completion_value,0)*
          decode(abs(i_txn_qty),
                 prior_completion_quantity,-1,
                 i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                  prior_completion_quantity)),
                 0),
          ---
          --- relieved_res_completion_value
          ---
          nvl(w1.relieved_res_completion_value,0)+
          decode(SIGN(w2.relieved_res_completion_value),1,
                 nvl(w2.relieved_res_completion_value,0)*
                 decode(abs(i_txn_qty),
                        prior_completion_quantity,-1,
                        i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                  prior_completion_quantity)),
                 0)
        FROM
           wip_operation_resources w2,
           cst_comp_snapshot cocd
        WHERE
           w2.wip_entity_id 	=	w1.wip_entity_id	AND
           w2.organization_id	=	w1.organization_id	AND
           w2.operation_seq_num	=	w1.operation_seq_num	AND
           w2.resource_seq_num	=	w1.resource_seq_num	AND
           w2.wip_entity_id	=	cocd.wip_entity_id	AND
           w2.operation_seq_num	=	cocd.operation_seq_num	AND
           cocd.new_operation_flag =	2			AND
           cocd.transaction_id	=	i_trx_id)
        WHERE
           w1.wip_entity_id	=	i_wip_entity_id		AND
           w1.organization_id	=	i_org_id;



        stmt_num := 165;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_completion_units,
          temp_relieved_value,
          relieved_ovhd_completion_value) =
        (SELECT
          ---
          --- relieved_ovhd_completion_units
          ---
          nvl(w1.relieved_ovhd_completion_units,0)+
          decode(SIGN(w2.relieved_ovhd_completion_value),1,
                 nvl(W2.relieved_ovhd_completion_units,0)*
                 decode(abs(i_txn_qty),
                        prior_completion_quantity,-1,
                        i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                         prior_completion_quantity)),
                 0),
          ---
          --- temp_relieved_value
          ---
          decode(SIGN(w2.relieved_ovhd_completion_value),1,
                 nvl(w2.relieved_ovhd_completion_value,0)*
                 decode(abs(i_txn_qty),
                        prior_completion_quantity,-1,
                        i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                         prior_completion_quantity)),
                 0),

          ---
          --- relieved_ovhd_completion_value
          ---
          nvl(w1.relieved_ovhd_completion_value,0)+
          decode(SIGN(w2.relieved_ovhd_completion_value),1,
                 nvl(w2.relieved_ovhd_completion_value,0)*
                 decode(abs(i_txn_qty),
                        prior_completion_quantity,-1,
                        i_txn_qty/decode(prior_completion_quantity,null,1,0,1,
                                         prior_completion_quantity)),
                 0)

        FROM
        wip_operation_overheads w2,
        cst_comp_snapshot cocd
        WHERE
        w2.wip_entity_id        =       w1.wip_entity_id        AND
        w2.organization_id      =       w1.organization_id      AND
        w2.operation_seq_num    =       w1.operation_seq_num    AND
        w2.resource_seq_num     =       w1.resource_seq_num     AND
        w2.overhead_id          =       w1.overhead_id          AND
        w2.basis_type           =       w1.basis_type           AND
        w2.wip_entity_id        =       cocd.wip_entity_id      AND
        w2.operation_seq_num    =       cocd.operation_seq_num  AND
        cocd.new_operation_flag =       2                       AND
        cocd.transaction_id     =       i_trx_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id;

    END IF;

        /************************************************************
        * Insert into mtl_cst_txn_cost_details now that the     *
        * Costs have been computed ...                              *
        * 3 statements are required --> one each for PL costs       *
        * , TL Res/OSP costs and TL ovhd costs.                     *
        * Remember - the cst_txn_cost_detail tables stores unit     *
        * cost - but the wip tables store the value in the          *
        * temp_relieved_value column - so we have to divide by the  *
        * txn_qty to arrive at the unit cost.                       *
        * Also, this insert should only be performed if the indicat *
        * or is <> 1.
        ************************************************************/

        IF (l_insert_ind <>1) THEN

        stmt_num := 270;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
        i_trx_id,
        i_org_id,
        i_inv_item_id,
        wrocd.cost_element_id,
        2,
        sum(nvl(wrocd.temp_relieved_value,0))/i_txn_qty,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
        WIP_REQ_OPERATION_COST_DETAILS wrocd
        where
        WIP_ENTITY_ID   =       i_wip_entity_id         AND
        ORGANIZATION_ID =       i_org_id
        GROUP BY wrocd.cost_element_id
        HAVING sum(nvl(wrocd.temp_relieved_value,0))  <> 0;

        stmt_num := 290;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         br.cost_element_id,
         1,
         sum(nvl(wor.temp_relieved_value,0))/i_txn_qty,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
        FROM
        BOM_RESOURCES BR,
        WIP_OPERATION_RESOURCES WOR
        WHERE
        WOR.RESOURCE_ID         =       BR.RESOURCE_ID          AND
        WOR.ORGANIZATION_ID     =       BR.ORGANIZATION_ID      AND
        WOR.WIP_ENTITY_ID       =       i_wip_entity_id         AND
        WOR.ORGANIZATION_ID     =       i_org_id
        GROUP BY BR.COST_ELEMENT_ID
        HAVING sum(nvl(wor.temp_relieved_value,0))  <> 0;

        stmt_num := 310;

        INSERT INTO mtl_cst_txn_cost_details
        (
         TRANSACTION_ID,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         COST_ELEMENT_ID,
         LEVEL_TYPE,
         TRANSACTION_COST,
         NEW_AVERAGE_COST,
         PERCENTAGE_CHANGE,
         VALUE_CHANGE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE)
        SELECT
         i_trx_id,
         i_org_id,
         i_inv_item_id,
         5,
         1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         i_user_id,
         SYSDATE,
         i_user_id,
         i_login_id,
         i_request_id,
         i_prog_appl_id,
         i_prog_id,
         SYSDATE
        FROM
        WIP_OPERATION_OVERHEADS
        WHERE
        WIP_ENTITY_ID           =       i_wip_entity_id         AND
        ORGANIZATION_ID         =       i_org_id
        HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;

        END IF;

 EXCEPTION
        WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := 'CSTPACWC:' || 'assembly_return:' || to_char(stmt_num) ||
                    ' ' || substr(SQLERRM,1,150);

END assembly_return;

END CSTPACWC;

/
