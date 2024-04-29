--------------------------------------------------------
--  DDL for Package Body CSTPACWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACWS" AS
/* $Header: CSTPACSB.pls 120.2.12010000.3 2009/04/30 15:29:53 jkwac ship $ */

PROCEDURE scrap (
 i_trx_id               IN      NUMBER,
 i_txn_qty		IN	NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_inv_item_id		IN	NUMBER,
 i_org_id               IN      NUMBER,
 i_cost_group_id	IN	NUMBER,
 i_op_seq_num		IN	NUMBER,
 i_cost_type_id		IN	NUMBER,
 i_res_cost_type_id	IN	NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2)

is

 stmt_num			NUMBER;
 i_lot_size			NUMBER;
 l_system_option_id             NUMBER;
 l_comp_cost_source		NUMBER;
 l_future_issued_qty            NUMBER := 0;  /* Added for bug 3715567 */
 i_txn_date                     DATE;
 l_include_comp_yield           NUMBER;

 /* Cursor added for bug 3715567 */
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
         wro.quantity_per_assembly     <> 0            AND
         wro.operation_seq_num         <= i_op_seq_num;

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

	SELECT start_quantity
 	into i_lot_size
	from
	WIP_DISCRETE_JOBS
	where
	WIP_ENTITY_ID = i_wip_entity_id and
	ORGANIZATION_ID = i_org_id;


        stmt_num := 50;

        select wac.completion_cost_source,
               nvl(wac.SYSTEM_OPTION_ID,-1)
        into l_comp_cost_source,l_system_option_id
        from
        wip_accounting_classes wac,
        wip_discrete_jobs wdj
        where
        wdj.wip_entity_id               =       i_wip_entity_id         and
        wdj.organization_id             =       i_org_id                and
        wdj.class_code                  =       wac.class_code          and
        wdj.organization_id             =       wac.organization_id;


--	/******************************************************
--	* Relieve PL Costs from WIP ....		      *
--	******************************************************/



	stmt_num :=  90;
        -- If no material has been issued to the Job, there will be no
        -- rows in WROCD for the components. However, the cost relief is
        -- supposed to be based on the current average cost of the
        -- components. Therefore insert rows for all components.
        -- If some components have been issued, they should not be inserted


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
         -1,
         SYSDATE,
         SYSDATE,
         -1,
         -1,
         -1,
         -1,
         -1,
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
	WRO.OPERATION_SEQ_NUM	<=	i_op_seq_num		AND
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

        /* Added for bug 3715567 */
        stmt_num := 95;
        select transaction_date
        into i_txn_date
        from mtl_material_transactions
        where transaction_id = i_trx_id;

        stmt_num := 98;
        /* Get the value of Include Component yield flag, which will determine
        whether to include or not component yield factor in quantity per assembly*/
        SELECT  nvl(include_component_yield,1)
        INTO    l_include_comp_yield
        FROM    wip_parameters
        WHERE   organization_id = i_org_id;

	stmt_num := 100;
        /* Added loop for bug 3715567 */
        FOR wro_rec in c_wip_req_op LOOP
        BEGIN

           l_future_issued_qty := 0;

            BEGIN
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
               AND      nvl(move_transaction_id,-999) <>
                           ( Select   nvl(move_transaction_id,-999)
                             from     mtl_material_transactions
                             where    transaction_id = i_trx_id);
            EXCEPTION
              WHEN Others THEN
                  l_future_issued_qty := 0;
            END;

	UPDATE WIP_REQ_OPERATION_COST_DETAILS w1
	SET (temp_relieved_value,
	     relieved_matl_scrap_value) =
	    (SELECT
	     decode(SIGN(nvl(wro.quantity_issued,0)-
		         nvl(wro.relieved_matl_completion_qty,0)-
                         nvl(wro.relieved_matl_final_comp_qty,0)-
		         nvl(wro.relieved_matl_scrap_quantity,0)-
                         /* LBM Project Changes */
			 i_txn_qty*(decode(wro.basis_type, 2,
                                          wro.quantity_per_assembly/i_lot_size,
                                          wro.quantity_per_assembly)/
                                    decode(l_include_comp_yield,
                                           1, nvl(wro.component_yield_factor,1),
                                           1)) +
                         l_future_issued_qty), /* Bug 6485658 */
		    SIGN(wro.quantity_per_assembly),
                    /* LBM project Changes */
		    i_txn_qty*(decode(wro.basis_type, 2,
                                     wro.quantity_per_assembly/i_lot_size,
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
				nvl(wro.relieved_matl_scrap_quantity,0)+
                                l_future_issued_qty), /* Fix for bug 3715567 */
			   nvl(decode(cost_element_id,
				      1,cic.material_cost,
				      2,cic.material_overhead_cost,
				      3,cic.resource_cost,
				      4,cic.outside_processing_cost,
				      5,cic.overhead_cost),0)),
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
                            /* LBM Project Changes */
			    i_txn_qty*(decode(wro.basis_type, 2,
                                             wro.quantity_per_assembly/i_lot_size,
                                             wro.quantity_per_assembly)/
                                       decode(l_include_comp_yield,
                                              1, nvl(wro.component_yield_factor,1),
                                              1))*
			    nvl(decode(cost_element_id,
			    	       1,cic.material_cost,
				       2,cic.material_overhead_cost,
				       3,cic.resource_cost,
				       4,cic.outside_processing_cost,
				       5,cic.overhead_cost),0)),
		    -1*SIGN(wro.quantity_per_assembly),
		    decode(SIGN(nvl(applied_matl_value,0)-
                                nvl(relieved_matl_completion_value,0)-
   			        nvl(relieved_variance_value,0)-
                                nvl(relieved_matl_scrap_value,0)),
                           /* Bug 3479419: AVTR = 0 Start*/
                           /* LBM Project Changes */
                           0, (i_txn_qty*(decode(wro.basis_type, 2,
                                                wro.quantity_per_assembly/i_lot_size,
                                                wro.quantity_per_assembly)/
                                          decode(l_include_comp_yield,
                                                 1, nvl(wro.component_yield_factor,1),
                                                 1))-
                            (wro.quantity_issued -
                             nvl(wro.relieved_matl_completion_qty,0) -
                             nvl(wro.relieved_matl_final_comp_qty,0) -
                             nvl(wro.relieved_matl_scrap_quantity,0) +
                             l_future_issued_qty))* /* Bug 6485658 */
                             nvl(decode(cost_element_id,
                                        1,cic.material_cost,
                                        2,cic.material_overhead_cost,
                                        3,cic.resource_cost,
                                        4,cic.outside_processing_cost,
                                        5,cic.overhead_cost),0),
                           /* Bug 3479419: AVTR = 0 End*/
                           SIGN(wro.quantity_per_assembly),
			   (nvl(applied_matl_value,0)-
                            nvl(relieved_matl_completion_value,0)-
   			    nvl(relieved_variance_value,0)-
                            nvl(relieved_matl_scrap_value,0)+
                            /* LBM Project Changes */
			    (i_txn_qty*(decode(wro.basis_type, 2,
                                              wro.quantity_per_assembly/i_lot_size,
                                              wro.quantity_per_assembly)/
                                        decode(l_include_comp_yield,
                                               1, nvl(wro.component_yield_factor,1),
                                               1)) -
			    (wro.quantity_issued -
			     nvl(wro.relieved_matl_completion_qty,0)-
                             nvl(wro.relieved_matl_final_comp_qty,0)-
			     nvl(wro.relieved_matl_scrap_quantity,0) +
                             l_future_issued_qty)) * /* Bug 6485658 */
			     nvl(decode(cost_element_id,
                                        1,cic.material_cost,
                                        2,cic.material_overhead_cost,
                                        3,cic.resource_cost,
                                        4,cic.outside_processing_cost,
                                        5,cic.overhead_cost),0)),
                           /* LBM Project Changes */
			   i_txn_qty*(decode(wro.basis_type, 2,
                                            wro.quantity_per_assembly/i_lot_size,
                                            wro.quantity_per_assembly)/
                                      decode(l_include_comp_yield,
                                             1, nvl(wro.component_yield_factor,1),
                                             1))*
                            nvl(decode(cost_element_id,
                                       1,cic.material_cost,
                                       2,cic.material_overhead_cost,
                                       3,cic.resource_cost,
                                       4,cic.outside_processing_cost,
                                       5,cic.overhead_cost),0))),

	     nvl(w1.relieved_matl_scrap_value,0)+
             decode(SIGN(nvl(wro.quantity_issued,0)-
                         nvl(wro.relieved_matl_completion_qty,0)-
                         nvl(wro.relieved_matl_final_comp_qty,0)-
                         nvl(wro.relieved_matl_scrap_quantity,0)-
                         /* LBM Project Changes  */
                         i_txn_qty*(decode(wro.basis_type, 2,
                                          wro.quantity_per_assembly/i_lot_size,
                                          wro.quantity_per_assembly)/
                                    decode(l_include_comp_yield,
                                           1, nvl(wro.component_yield_factor,1),
                                           1)) +
                         l_future_issued_qty), /* Bug 6485658 */
                    SIGN(wro.quantity_per_assembly),
                    /* LBM Project Changes */
                    i_txn_qty*(decode(wro.basis_type, 2,
                                     wro.quantity_per_assembly/i_lot_size,
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
                           /* Bug 3479419: AVTR = End*/
                           SIGN(wro.quantity_per_assembly),
                           ( nvl(applied_matl_value,0)-
                             nvl(relieved_matl_completion_value,0)-
			     nvl(relieved_variance_value,0)-
                             nvl(relieved_matl_scrap_value,0))
                             /(wro.quantity_issued-
                                nvl(wro.relieved_matl_completion_qty,0)-
			        nvl(wro.relieved_matl_final_comp_qty,0)-
                                nvl(wro.relieved_matl_scrap_quantity,0)+
                                l_future_issued_qty), /* Fix for bug 3715567 */
                           nvl(decode(cost_element_id,
                                      1,cic.material_cost,
                                      2,cic.material_overhead_cost,
                                      3,cic.resource_cost,
                                      4,cic.outside_processing_cost,
                                      5,cic.overhead_cost),0)),
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
                            /* LBM Project Changes */
                            i_txn_qty*(decode(wro.basis_type, 2,
                                             wro.quantity_per_assembly/i_lot_size,
                                             wro.quantity_per_assembly)/
                                       decode(l_include_comp_yield,
                                              1, nvl(wro.component_yield_factor,1),
                                              1))*
                            nvl(decode(cost_element_id,
                                       1,cic.material_cost,
                                       2,cic.material_overhead_cost,
                                       3,cic.resource_cost,
                                       4,cic.outside_processing_cost,
                                       5,cic.overhead_cost),0)),
                    -1*SIGN(wro.quantity_per_assembly),
                    decode(SIGN(nvl(applied_matl_value,0)-
                                nvl(relieved_matl_completion_value,0)-
           			nvl(relieved_variance_value,0)-
	                        nvl(relieved_matl_scrap_value,0)),
                           /* Bug 3479419: AVTR = 0 Start*/
                           /* LBM Project Changes */
                           0, (i_txn_qty*(decode(wro.basis_type, 2,
                                                wro.quantity_per_assembly/i_lot_size,
                                                wro.quantity_per_assembly)/
                                          decode(l_include_comp_yield,
                                                 1, nvl(wro.component_yield_factor,1),
                                                 1)) -
                            (wro.quantity_issued -
                             nvl(wro.relieved_matl_completion_qty,0) -
                             nvl(wro.relieved_matl_final_comp_qty,0) -
                             nvl(wro.relieved_matl_scrap_quantity,0) +
                             l_future_issued_qty)) * /* Bug 6485658 */
                             nvl(decode(cost_element_id,
                                        1,cic.material_cost,
                                        2,cic.material_overhead_cost,
                                        3,cic.resource_cost,
                                        4,cic.outside_processing_cost,
                                        5,cic.overhead_cost),0),
                           /* Bug 3479419: AVTR = 0 End*/
                           SIGN(wro.quantity_per_assembly),
                           (nvl(applied_matl_value,0)-
                            nvl(relieved_matl_completion_value,0)-
       			    nvl(relieved_variance_value,0)-
                            nvl(relieved_matl_scrap_value,0)+
                            /* LBM Project Changes */
                            (i_txn_qty*(decode(wro.basis_type, 2,
                                              wro.quantity_per_assembly/i_lot_size,
                                              wro.quantity_per_assembly)/
                                        decode(l_include_comp_yield,
                                               1, nvl(wro.component_yield_factor,1),
                                               1)) -
                            (wro.quantity_issued -
                             nvl(wro.relieved_matl_completion_qty,0)-
   			     nvl(wro.relieved_matl_final_comp_qty,0)-
                             nvl(wro.relieved_matl_scrap_quantity,0) +
                             l_future_issued_qty)) * /* Bug 6485658 */
                             nvl(decode(cost_element_id,
                                        1,cic.material_cost,
                                        2,cic.material_overhead_cost,
                                        3,cic.resource_cost,
                                        4,cic.outside_processing_cost,
                                        5,cic.overhead_cost),0)),
                           /* LBM Project Changes */
                           i_txn_qty*(decode(wro.basis_type, 2,
                                            wro.quantity_per_assembly/i_lot_size,
                                            wro.quantity_per_assembly)/
                                      decode(l_include_comp_yield,
                                             1, nvl(wro.component_yield_factor,1),
                                             1))*
                            nvl(decode(cost_element_id,
                                       1,cic.material_cost,
                                       2,cic.material_overhead_cost,
                                       3,cic.resource_cost,
                                       4,cic.outside_processing_cost,
                                       5,cic.overhead_cost),0)))
	     FROM
	     WIP_REQ_OPERATION_COST_DETAILS w2,
	     WIP_REQUIREMENT_OPERATIONS wro,
	     CST_QUANTITY_LAYERS cic
	     where
	     w2.WIP_ENTITY_ID	   =	w1.WIP_ENTITY_ID AND
	     w2.ORGANIZATION_ID	   =	w1.ORGANIZATION_ID AND
	     w2.INVENTORY_ITEM_ID  =	w1.INVENTORY_ITEM_ID AND
	     w2.OPERATION_SEQ_NUM  =	w1.OPERATION_SEQ_NUM AND
	     w2.COST_ELEMENT_ID	   =	w1.COST_ELEMENT_ID AND
	     w2.WIP_ENTITY_ID	   =  	wro.WIP_ENTITY_ID AND
	     w2.ORGANIZATION_ID	   =	wro.ORGANIZATION_ID AND
	     w2.INVENTORY_ITEM_ID  = 	wro.INVENTORY_ITEM_ID AND
	     w2.OPERATION_SEQ_NUM  =	wro.OPERATION_SEQ_NUM AND
	     i_cost_group_id       =    cic.COST_GROUP_ID(+)     AND
	     wro.INVENTORY_ITEM_ID =	cic.INVENTORY_ITEM_ID(+) AND
	     wro.ORGANIZATION_ID   =	cic.ORGANIZATION_ID(+))
	WHERE
          w1.wip_entity_id   = wro_rec.wip_entity_id    AND
          w1.organization_id = wro_rec.organization_id  AND
          w1.inventory_item_id = wro_rec.inventory_item_id  AND
          w1.operation_seq_num = wro_rec.operation_seq_num;

        END;
        END LOOP;
        /* End loop for bug 3715567 */

--      /******************************************************
--      * Relieve PL Units from WIP ....                      *
--      ******************************************************/

        stmt_num := 110;

        UPDATE WIP_REQUIREMENT_OPERATIONS w
        SET RELIEVED_MATL_SCRAP_QUANTITY =
           (SELECT
                 nvl(w.RELIEVED_MATL_SCRAP_QUANTITY,0) +
                 /* LBM Project Changes */
                 i_txn_qty*(decode(w2.basis_type, 2,
                                  w2.quantity_per_assembly/i_lot_size,
                                  w2.quantity_per_assembly)/
                            decode(l_include_comp_yield,
                                   1, nvl(w2.component_yield_factor,1),
                                   1))
            FROM
            WIP_REQUIREMENT_OPERATIONS w2
            where
            w.WIP_ENTITY_ID     =       w2.WIP_ENTITY_ID AND
            w.INVENTORY_ITEM_ID =       w2.INVENTORY_ITEM_ID AND
            w.OPERATION_SEQ_NUM =       w2.OPERATION_SEQ_NUM AND
            w.ORGANIZATION_ID   =       w2.ORGANIZATION_ID)
        WHERE
        w.WIP_ENTITY_ID         =       i_wip_entity_id AND
        w.ORGANIZATION_ID       =       i_org_id        AND
        w.WIP_SUPPLY_TYPE       not in  (4,5,6)         AND
        w.OPERATION_SEQ_NUM     <=      i_op_seq_num;




	stmt_num := 130;

	INSERT INTO WIP_SCRAP_VALUES
	(
	 transaction_id,
         level_type,
	 cost_element_id,
	 cost_update_id,
	 last_update_date,
	 last_updated_by,
	 created_by,
	 creation_date,
	 last_update_login,
	 cost_element_value,
	 request_id,
 	 program_application_id,
	 program_id,
	 program_update_date
	)
	SELECT
	i_trx_id,
	2,
	wrocd.cost_element_id,
	NULL,
	SYSDATE,
	-1,
	-1,
	SYSDATE,
	-1,
	sum(nvl(temp_relieved_value,0))/i_txn_qty,
	-1,
	-1,
 	-1,
	SYSDATE
	FROM
	 WIP_REQ_OPERATION_COST_DETAILS wrocd
	 where
	 wrocd.WIP_ENTITY_ID	=	i_wip_entity_id	AND
	 wrocd.ORGANIZATION_ID	=	i_org_id
	GROUP BY wrocd.COST_ELEMENT_ID
	HAVING sum(nvl(temp_relieved_value,0))	<> 0;


	IF (l_system_option_id = 1) THEN

	stmt_num := 140;

        UPDATE wip_operation_resources w1
        SET
        (relieved_res_scrap_units,
         temp_relieved_value,
         relieved_res_scrap_value) =
        (SELECT
         NVL(w1.relieved_res_scrap_units,0) +
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
	-- ie. flush out 1*value remain in the job  same as completion 8/28/98
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
        nvl(w1.relieved_res_scrap_value,0) +
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
        W1.WIP_ENTITY_ID        =       W2.WIP_ENTITY_ID        AND
        W1.OPERATION_SEQ_NUM    =       W2.OPERATION_SEQ_NUM    AND
        W1.RESOURCE_SEQ_NUM     =       W2.RESOURCE_SEQ_NUM     AND
        W1.ORGANIZATION_ID      =       W2.ORGANIZATION_ID      AND
        W2.OPERATION_SEQ_NUM    =       COCD.OPERATION_SEQ_NUM  AND
        COCD.NEW_OPERATION_FLAG	=       2                       AND
        COCD.TRANSACTION_ID     =       I_TRX_ID)
        WHERE
        W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
        W1.ORGANIZATION_ID      =       I_ORG_ID		AND
	/*bug7346242: Commented the condition below. Usage rate for
	resource shouldn't be checked, when system option is
	Actual resource charges
        w1.USAGE_RATE_OR_AMOUNT <>      0                       AND*/
        w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;


	stmt_num := 145;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_scrap_units,
          temp_relieved_value,
          relieved_ovhd_scrap_value) =
        (SELECT
         NVL(w1.relieved_ovhd_scrap_units,0) +
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
        nvl(W1.relieved_ovhd_scrap_value,0) +
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
        wip_operation_overheads W2,
        cst_comp_snapshot COCD
        WHERE
        w1.wip_entity_id        =       w2.wip_entity_id        AND
        w1.operation_seq_num    =       w2.operation_seq_num    AND
        w1.resource_seq_num     =       w2.resource_seq_num     AND
        w1.overhead_id          =       w2.overhead_id          AND
/*bug#3469342. */
        w1.basis_type           =       w2.basis_type           AND
        w1.organization_id      =       w2.organization_id      AND
        w2.operation_seq_num    =       cocd.operation_seq_num  AND
        cocd.new_operation_flag =       2                       AND
        cocd.transaction_id     =       i_trx_id)
        WHERE
        w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id                AND
        w1.operation_seq_num    <=      i_op_seq_num;

	ELSE

--	/******************************************************
--	* Relieve This Level Resource costs/units from WIP ...*
--	******************************************************/

	stmt_num := 150;

	UPDATE WIP_OPERATION_RESOURCES w1
	SET
	 (relieved_res_scrap_units,
	  temp_relieved_value,
	  relieved_res_scrap_value) =
	(SELECT
	   nvl(w1.relieved_res_scrap_units,0)+
	   decode(basis_type,
		  1,i_txn_qty*usage_rate_or_amount,
		  2,i_txn_qty*usage_rate_or_amount/i_lot_size,
		  i_txn_qty*usage_rate_or_amount),
             decode(SIGN(applied_resource_units-
                         nvl(relieved_res_completion_units,0)-
			 nvl(relieved_res_final_comp_units,0)-
                         nvl(relieved_res_scrap_units,0)-
                         i_txn_qty*decode(basis_type,
					  1,usage_rate_or_amount,
					  2,usage_rate_or_amount/i_lot_size,
					  usage_rate_or_amount)),
                    SIGN(usage_rate_or_amount),
                    i_txn_qty*decode(basis_type,
				     1,usage_rate_or_amount,
				     2,usage_rate_or_amount/i_lot_size,
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
  				 /* Bug4213652 dividing by applied units
                                  to get the correct relieved value*/
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
                            nvl(relieved_res_scrap_value,0)),-
                            i_txn_qty*decode(basis_type,
					     1,usage_rate_or_amount,
					     2,usage_rate_or_amount/i_lot_size,
					     usage_rate_or_amount)*
                                       crc.resource_rate),
                    -1*SIGN(usage_rate_or_amount),
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
			        nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),-
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
		            nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)+
                           (i_txn_qty*
			    decode(basis_type,
			    1,usage_rate_or_amount,
			    2,usage_rate_or_amount/i_lot_size,
			    usage_rate_or_amount) -
                           (applied_resource_units -
                            nvl(relieved_res_completion_units,0) -
			    nvl(relieved_res_final_comp_units,0) -
                            nvl(relieved_res_scrap_units,0)))*
                           crc.resource_rate),
                           i_txn_qty*
			   decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/i_lot_size,
                            usage_rate_or_amount)*
                            crc.resource_rate)),
	     nvl(w1.relieved_res_scrap_value,0) +
             decode(SIGN(applied_resource_units-
                         nvl(relieved_res_completion_units,0)-
			 nvl(relieved_res_final_comp_units,0)-
                         nvl(relieved_res_scrap_units,0)-
                         i_txn_qty*decode(basis_type,
                                          1,usage_rate_or_amount,
                                          2,usage_rate_or_amount/i_lot_size,
                                          usage_rate_or_amount)),
                    SIGN(usage_rate_or_amount),
                    i_txn_qty*decode(basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/i_lot_size,
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
  				 /* Bug4213652 dividing by applied units
                                  to get the correct relieved value*/
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
                            nvl(relieved_res_scrap_value,0)),-
                            i_txn_qty*decode(basis_type,
                                             1,usage_rate_or_amount,
                                             2,usage_rate_or_amount/i_lot_size,
                                             usage_rate_or_amount)*
                                       crc.resource_rate),
                    -1*SIGN(usage_rate_or_amount),
                    decode(SIGN(nvl(applied_resource_value,0)-
                                nvl(relieved_res_completion_value,0)-
				nvl(relieved_variance_value,0)-
                                nvl(relieved_res_scrap_value,0)),-
                           SIGN(usage_rate_or_amount),
                           (nvl(applied_resource_value,0)-
                            nvl(relieved_res_completion_value,0)-
			    nvl(relieved_variance_value,0)-
                            nvl(relieved_res_scrap_value,0)+
                           (i_txn_qty*
                            decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/i_lot_size,
                            usage_rate_or_amount) -
                           (applied_resource_units -
                            nvl(relieved_res_completion_units,0)-
			    nvl(relieved_res_final_comp_units,0)-
                            nvl(relieved_res_scrap_units,0)))*
                           crc.resource_rate),
                           i_txn_qty*
                           decode(basis_type,
                            1,usage_rate_or_amount,
                            2,usage_rate_or_amount/i_lot_size,
                            usage_rate_or_amount)*
                            crc.resource_rate))
	 FROM
	 wip_operation_resources w2,
	 cst_resource_costs crc
	 WHERE
	 w2.wip_entity_id	=	w1.wip_entity_id	AND
	 w2.operation_seq_num	=	w1.operation_seq_num	AND
	 w2.resource_seq_num	=	w1.resource_seq_num	AND
	 w2.organization_id	=	w2.organization_id	AND
	 w2.resource_id		=	crc.resource_id		AND
	 w2.organization_id	=	crc.organization_id	AND
	 crc.cost_type_id	=	i_res_cost_type_id)
	WHERE
	w1.wip_entity_id	=	i_wip_entity_id		AND
	w1.organization_id	=	i_org_id		AND
	w1.usage_rate_or_amount <>	0			AND
	w1.operation_seq_num	<=	i_op_seq_num;



	/***********************************************************
	* Relieve TL Ovhd (Move based) units and Costs ..	   *
	***********************************************************/

	stmt_num := 185;

        -- For the pre-defined completion/scrap algorithm, if no overheads have
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
        CDO.COST_TYPE_ID        =       i_res_cost_type_id      AND
        CDO.BASIS_TYPE          IN      (1,2)                   AND
	WO.OPERATION_SEQ_NUM	<=	i_op_seq_num		AND
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

	stmt_num := 190;

	UPDATE wip_operation_overheads w1
	SET
	 (relieved_ovhd_scrap_units,
	  temp_relieved_value,
	  relieved_ovhd_scrap_value) =
	(SELECT
	   nvl(w1.relieved_ovhd_scrap_units,0)+
	   decode(w2.basis_type,
	 	  1,i_txn_qty,
	 	  2,i_txn_qty/i_lot_size),
	   decode(SIGN(nvl(w2.applied_ovhd_units,0)-
		  nvl(relieved_ovhd_completion_units,0)-
		  nvl(relieved_ovhd_final_comp_units,0)-
	 	  nvl(relieved_ovhd_scrap_units,0)-
	 	  decode(w2.basis_type,
		  	 1,i_txn_qty,
			 2,i_txn_qty/i_lot_size)),
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
				 2,i_txn_qty/i_lot_size),
			  cdo.rate_or_amount*
			  decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/i_lot_size)),
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
                                 2,i_txn_qty/i_lot_size)),
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
                                 2,i_txn_qty/i_lot_size)-
			  (nvl(w2.applied_ovhd_units,0)-
			  nvl(relieved_ovhd_completion_units,0)-
			  nvl(relieved_ovhd_final_comp_units,0)-
			  nvl(relieved_ovhd_scrap_units,0)))*
			  cdo.rate_or_amount),
			  cdo.rate_or_amount*
			  decode(w2.basis_type,
			  1,i_txn_qty,
			  2,i_txn_qty/i_lot_size))),
	   nvl(w1.relieved_ovhd_scrap_value,0) +
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
		  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         1,i_txn_qty,
                         2,i_txn_qty/i_lot_size)),
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
                                 2,i_txn_qty/i_lot_size),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/i_lot_size)),
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
                                 2,i_txn_qty/i_lot_size)),
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
                                 2,i_txn_qty/i_lot_size)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
			  nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          cdo.rate_or_amount),
                          cdo.rate_or_amount*
                          decode(w2.basis_type,
                          1,i_txn_qty,
                          2,i_txn_qty/i_lot_size)))
	 FROM
	 wip_operation_overheads w2,
	 cst_department_overheads cdo,
	 wip_operations wo
	 WHERE
	 w2.wip_entity_id	=	w1.wip_entity_id	AND
	 w2.organization_id	=	w1.organization_id	AND
	 w2.operation_seq_num	=	w1.operation_seq_num	AND
	 w2.resource_seq_num	=	w1.resource_seq_num 	AND
	 w2.overhead_id		=	w1.overhead_id		AND
	 w2.basis_type		=	w1.basis_type		AND
	 w2.wip_entity_id	=	wo.wip_entity_id	AND
	 w2.organization_id	=	wo.organization_id	AND
	 w2.operation_seq_num	=	wo.operation_seq_num	AND
	 cdo.department_id	=	wo.department_id	AND
	 cdo.overhead_id	=	w2.overhead_id		AND
	 cdo.basis_type		=	w2.basis_type		AND
	 cdo.cost_type_id	=	i_res_cost_type_id)
	WHERE
	w1.wip_entity_id	=	i_wip_entity_id		AND
	w1.organization_id	=	i_org_id		AND
	w1.operation_seq_num	<=	i_op_seq_num		AND
	w1.basis_type		IN	(1,2)			AND
	w1.resource_seq_num	=	-1			AND
	EXISTS
	 (
	  SELECT 'X'
	  FROM
	  cst_department_overheads cdo2,
	  wip_operations wo2
	  WHERE
	  wo2.wip_entity_id	=	w1.wip_entity_id	AND
	  wo2.organization_id	=	w1.organization_id	AND
	  wo2.operation_seq_num	=	w1.operation_seq_num	AND
	  wo2.department_id	=	cdo2.department_id	AND
	  w1.overhead_id	= 	cdo2.overhead_id	AND
	  w1.basis_type 	=	cdo2.basis_type		AND
	  cdo2.cost_type_id	=	i_res_cost_type_id);


	/**********************************************************
	* There may be overheads in wip_operation_overheads whose *
	* Basis may be different from thatin  cst_dept_ovhds ,so  *
	* we need to relieve these anyway if there is value to re-*
	* lieve. - OPEN ISSUE - DO WE DO THIS OR NOT?? 		  *
	**********************************************************/


	stmt_num := 210;

	UPDATE WIP_OPERATION_OVERHEADS w1
        set
         (relieved_ovhd_scrap_units,
          temp_relieved_value,
	  relieved_ovhd_scrap_value) =
        (SELECT
           nvl(w1.relieved_ovhd_scrap_units,0)+
           decode(w2.basis_type,
                  1,i_txn_qty,
                  2,i_txn_qty/i_lot_size),
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         1,i_txn_qty,
                         2,i_txn_qty/i_lot_size)),
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
                                  /
				 (nvl(applied_ovhd_units,0)-
                                  nvl(relieved_ovhd_completion_units,0)-
		                  nvl(relieved_ovhd_final_comp_units,0)-
                                  nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/i_lot_size),
                          0),
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
                          0),
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
                                 2,i_txn_qty/i_lot_size)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
	                  nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          0),
                          0)),
	   nvl(w1.relieved_ovhd_scrap_value,0)+
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         1,i_txn_qty,
                         2,i_txn_qty/i_lot_size)),
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
                                  /
                                 (nvl(applied_ovhd_units,0)-
                                  nvl(relieved_ovhd_completion_units,0)-
		                  nvl(relieved_ovhd_final_comp_units,0)-
                                  nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 1,i_txn_qty,
                                 2,i_txn_qty/i_lot_size),
                          0),
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
                          0),
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
                                 2,i_txn_qty/i_lot_size)-
                          (nvl(w2.applied_ovhd_units,0)-
                          nvl(relieved_ovhd_completion_units,0)-
	                  nvl(relieved_ovhd_final_comp_units,0)-
                          nvl(relieved_ovhd_scrap_units,0)))*
                          0),
                          0))
         FROM
         WIP_OPERATION_OVERHEADS w2
         WHERE
         W2.WIP_ENTITY_ID       =       W1.WIP_ENTITY_ID        AND
         W2.ORGANIZATION_ID     =       W1.ORGANIZATION_ID      AND
         W2.OPERATION_SEQ_NUM   =       W1.OPERATION_SEQ_NUM    AND
         W2.OVERHEAD_ID         =       W1.OVERHEAD_ID          AND
         W2.RESOURCE_SEQ_NUM	=       W1.RESOURCE_SEQ_NUM	AND
         W2.BASIS_TYPE          =       W1.BASIS_TYPE)
	WHERE
	W1.WIP_ENTITY_ID        =       i_wip_entity_id         AND
        W1.ORGANIZATION_ID      =       i_org_id                AND
        W1.OPERATION_SEQ_NUM    <=      i_op_seq_num            AND
        W1.BASIS_TYPE           IN      (1,2)                   AND
	W1.RESOURCE_SEQ_NUM 	= 	-1			AND
	NOT EXISTS
	 (
	  SELECT 'X'
	  FROM
	  CST_DEPARTMENT_OVERHEADS CDO2,
          WIP_OPERATIONS WO2
	  WHERE
	  WO2.WIP_ENTITY_ID     =       W1.WIP_ENTITY_ID        AND
          WO2.ORGANIZATION_ID   =       W1.ORGANIZATION_ID      AND
          WO2.OPERATION_SEQ_NUM =       W1.OPERATION_SEQ_NUM    AND
          WO2.DEPARTMENT_ID     =       CDO2.DEPARTMENT_ID      AND
          W1.OVERHEAD_ID        =       CDO2.OVERHEAD_ID        AND
          W1.BASIS_TYPE         =       CDO2.BASIS_TYPE         AND
          CDO2.COST_TYPE_ID     =       i_res_cost_type_id);


	/***********************************************************
	* Relieve TL Res based overheads and Units ...		   *
	***********************************************************/

	stmt_num := 225;

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
	                 		1, WOR.DEPARTMENT_ID,
		                	WO.DEPARTMENT_ID)        AND
        CDO.COST_TYPE_ID        =       i_res_cost_type_id      AND
        CDO.BASIS_TYPE          IN      (3,4)                           AND
        CRO.COST_TYPE_ID        =       i_res_cost_type_id      AND
        CRO.RESOURCE_ID         =       WOR.RESOURCE_ID                 AND
        CRO.OVERHEAD_ID         =       CDO.OVERHEAD_ID                 AND
	WO.OPERATION_SEQ_NUM    <=      i_op_seq_num            AND
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

	stmt_num := 230;

	UPDATE wip_operation_overheads w1
	SET
	 (relieved_ovhd_scrap_units,
	  temp_relieved_value,
	  relieved_ovhd_scrap_value) =
	(SELECT
	   nvl(w1.relieved_ovhd_scrap_units,0)+
	   decode(w2.basis_type,
		  3,i_txn_qty*decode(wor.basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/i_lot_size,
                                     usage_rate_or_amount),
                  4,wor.temp_relieved_value),
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/i_lot_size,
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
                                        2,wor.usage_rate_or_amount/i_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                         nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/i_lot_size),
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
                                        2,wor.usage_rate_or_amount/i_lot_size),
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
                                            2,usage_rate_or_amount/i_lot_size,
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
                                 2,wor.usage_rate_or_amount/i_lot_size),
                          4,nvl(wor.temp_relieved_value,0)))),
	   nvl(w1.relieved_ovhd_scrap_value,0) +
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
		  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/i_lot_size,
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
                                        2,wor.usage_rate_or_amount/i_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                         nvl(cdo.rate_or_amount,0)*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/i_lot_size),
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
                                        2,wor.usage_rate_or_amount/i_lot_size),
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
                                            2,usage_rate_or_amount/i_lot_size,
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
                                 2,wor.usage_rate_or_amount/i_lot_size),
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
	 w2.resource_seq_num	=	w1.resource_seq_num	AND
	 w2.wip_entity_id       =       wo.wip_entity_id        AND
         w2.organization_id     =       wo.organization_id      AND
         w2.operation_seq_num   =       wo.operation_seq_num    AND
	 w2.wip_entity_id       =       wor.wip_entity_id       AND
	 w2.organization_id     =       wor.organization_id	AND
	 w2.operation_seq_num	=	wor.operation_seq_num	AND
	 w2.resource_seq_num	=	wor.resource_seq_num	AND
	 CDO.DEPARTMENT_ID      =       DECODE(WOR.PHANTOM_FLAG,
	                 		1, WOR.DEPARTMENT_ID,
		                	WO.DEPARTMENT_ID)       AND
	 cdo.overhead_id	=	w2.overhead_id		AND
	 cdo.basis_type 	=	w2.basis_type		AND
	 cdo.cost_type_id	=	i_res_cost_type_id	AND
	 cro.overhead_id	=	cdo.overhead_id		AND
	 cro.resource_id	=	wor.resource_id		AND
	 cro.cost_type_id       =       i_res_cost_type_id)
	WHERE
	w1.wip_entity_id        =       i_wip_entity_id         AND
        w1.organization_id      =       i_org_id                AND
        w1.operation_seq_num    <=      i_op_seq_num            AND
        w1.basis_type           IN      (3,4)			AND
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
              				1, wor2.department_id,
					wo2.department_id)      AND
	 cdo2.overhead_id	=	w1.overhead_id		AND
	 cdo2.basis_type	=	w1.basis_type		AND
	 cdo2.cost_type_id	=       i_res_cost_type_id	AND
	 cdo2.overhead_id	=	cro2.overhead_id	AND
	 cro2.resource_id	=	wor2.resource_id	AND
	 cro2.cost_type_id	=	i_res_cost_type_id);



	/************************************************************
	* Relieve TL Res based Ovhds and Units where association no *
	* longer exists. Relieve excess units at zero cost.	    *
	************************************************************/

	stmt_num := 250;

        UPDATE wip_operation_overheads w1
        SET
         (relieved_ovhd_scrap_units,
          temp_relieved_value,
	  relieved_ovhd_scrap_value) =
        (SELECT
           nvl(w1.relieved_ovhd_scrap_units,0)+
           decode(w2.basis_type,
		  3,i_txn_qty*decode(wor.basis_type,
                                     1,usage_rate_or_amount,
                                     2,usage_rate_or_amount/i_lot_size,
                                     usage_rate_or_amount),
                  4,wor.temp_relieved_value),
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
                  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/i_lot_size,
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
                            /
			   (nvl(applied_ovhd_units,0)-
                            nvl(relieved_ovhd_completion_units,0)-
			    nvl(relieved_ovhd_final_comp_units,0)-
                            nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/i_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                          0),
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
                          0),
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
                          0),
                          0)),
	   nvl(w1.relieved_ovhd_scrap_value,0) +
           decode(SIGN(nvl(w2.applied_ovhd_units,0)-
                  nvl(relieved_ovhd_completion_units,0)-
		  nvl(relieved_ovhd_final_comp_units,0)-
                  nvl(relieved_ovhd_scrap_units,0)-
                  decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/i_lot_size,
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
                            /
                           (nvl(applied_ovhd_units,0)-
                            nvl(relieved_ovhd_completion_units,0)-
 			    nvl(relieved_ovhd_final_comp_units,0)-
                            nvl(relieved_ovhd_scrap_units,0)))*
                          decode(w2.basis_type,
                                 3,i_txn_qty*
                                 decode(wor.basis_type,
                                        1,wor.usage_rate_or_amount,
                                        2,wor.usage_rate_or_amount/i_lot_size),
                                 4,nvl(wor.temp_relieved_value,0)),
                          0),
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
                          0),
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
                          0),
                          0))
         FROM
         WIP_OPERATION_OVERHEADS w2,
	 WIP_OPERATION_RESOURCES WOR
         WHERE
         W2.WIP_ENTITY_ID       =       W1.WIP_ENTITY_ID        AND
         W2.ORGANIZATION_ID     =       W1.ORGANIZATION_ID      AND
         W2.OPERATION_SEQ_NUM   =       W1.OPERATION_SEQ_NUM    AND
         W2.OVERHEAD_ID         =       W1.OVERHEAD_ID          AND
         W2.BASIS_TYPE          =       W1.BASIS_TYPE		AND
         W2.RESOURCE_SEQ_NUM    =       W1.RESOURCE_SEQ_NUM     AND
	 W2.WIP_ENTITY_ID	=	WOR.WIP_ENTITY_ID	AND
	 W2.ORGANIZATION_ID	=	WOR.ORGANIZATION_ID	AND
	 W2.OPERATION_SEQ_NUM	=	WOR.OPERATION_SEQ_NUM	AND
	 W2.RESOURCE_SEQ_NUM	=	WOR.RESOURCE_SEQ_NUM)

        WHERE
        W1.WIP_ENTITY_ID        =       i_wip_entity_id         AND
        W1.ORGANIZATION_ID      =       i_org_id                AND
        W1.OPERATION_SEQ_NUM    <=      i_op_seq_num            AND
        W1.BASIS_TYPE           IN      (3,4)                   AND
        NOT EXISTS
         (
          SELECT 'X'
          FROM
          CST_DEPARTMENT_OVERHEADS CDO2,
          WIP_OPERATIONS WO2,
          CST_RESOURCE_OVERHEADS CRO2,
          WIP_OPERATION_RESOURCES WOR2
          WHERE
         W1.WIP_ENTITY_ID       =       WO2.WIP_ENTITY_ID       AND
         W1.ORGANIZATION_ID     =       WO2.ORGANIZATION_ID     AND
         W1.OPERATION_SEQ_NUM   =       WO2.OPERATION_SEQ_NUM   AND
         W1.WIP_ENTITY_ID       =       WOR2.WIP_ENTITY_ID      AND
         W1.ORGANIZATION_ID     =       WOR2.ORGANIZATION_ID    AND
         W1.OPERATION_SEQ_NUM   =       WOR2.OPERATION_SEQ_NUM  AND
         W1.RESOURCE_SEQ_NUM    =       WOR2.RESOURCE_SEQ_NUM   AND
         cdo2.department_id     =       DECODE(wor2.phantom_flag,
              				1, wor2.department_id,
					wo2.department_id)      AND
         CDO2.OVERHEAD_ID       =       W1.OVERHEAD_ID          AND
         CDO2.BASIS_TYPE        =       W1.BASIS_TYPE           AND
         CDO2.COST_TYPE_ID      =       i_res_cost_type_id	AND
         CDO2.OVERHEAD_ID       =       CRO2.OVERHEAD_ID        AND
         CRO2.RESOURCE_ID       =       WOR2.RESOURCE_ID        AND
         CRO2.COST_TYPE_ID      =       i_res_cost_type_id);

	END IF; -- The system option if ends here.


        stmt_num := 260;

        INSERT INTO wip_scrap_values
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
         i_trx_id,
         1,
         br.cost_element_id,
         NULL,
         SYSDATE,
         -1,
         -1,
         SYSDATE,
         -1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         -1,
         -1,
         -1,
         SYSDATE
        FROM
        wip_operation_resources wor,
        bom_resources br
        WHERE
        br.resource_id  	=       wor.resource_id         AND
        br.organization_id 	=    	wor.organization_id     AND
        wip_entity_id   	=       i_wip_entity_id         AND
        wor.organization_id     =       i_org_id
        group by br.cost_element_id
        HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;


	stmt_num := 270;

        INSERT INTO wip_scrap_values
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
         i_trx_id,
         1,
	 5,
	 NULL,
         SYSDATE,
         -1,
         -1,
         SYSDATE,
         -1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         -1,
         -1,
         -1,
         SYSDATE
        FROM
	WIP_OPERATION_OVERHEADS
	WHERE
	wip_entity_id		=	i_wip_entity_id         AND
	organization_id     	=       i_org_id
	HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;



	/******************************************************
	* Insert rows into mtl_cst_txn_cost_details	      *
	******************************************************/

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
	 cost_element_id,
	 level_type,
	 cost_element_value,
	 NULL,
	 NULL,
	 NULL,
	 SYSDATE,
	 -1,
	 SYSDATE,
	 -1,
	 -1,
	 -1,
	 -1,
	 -1,
 	 SYSDATE
	FROM
	wip_scrap_values
	WHERE
	transaction_id	=	i_trx_id	AND
	cost_update_id IS NULL;


 EXCEPTION

 	WHEN OTHERS THEN
	err_num := SQLCODE;
	err_msg := 'CSTPACWS' || to_char(stmt_num) || substr(SQLERRM,1,150);

 END scrap;





PROCEDURE scrap_return (
 i_trx_id               IN      NUMBER,
 i_txn_qty              IN      NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_inv_item_id          IN      NUMBER,
 i_org_id               IN      NUMBER,
 i_op_seq_num           IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2)

is

	stmt_num		NUMBER;
	i_lot_size		NUMBER;
	l_system_option_id	NUMBER;
	l_comp_cost_source	NUMBER;
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

        SELECT start_quantity
        into i_lot_size
        from
        WIP_DISCRETE_JOBS
        where
        WIP_ENTITY_ID = i_wip_entity_id and
        ORGANIZATION_ID = i_org_id;

	stmt_num := 50;

        select wac.completion_cost_source,nvl(system_option_id,-1)
        into l_comp_cost_source,l_system_option_id
        from
        wip_accounting_classes wac,
        wip_discrete_jobs wdj
        where
        wdj.wip_entity_id               =       i_wip_entity_id         and
        wdj.organization_id             =       i_org_id                and
        wdj.class_code                  =       wac.class_code          and
        wdj.organization_id             =       wac.organization_id;

        stmt_num := 60;
        /* Get the value of Include Component yield flag, which will determine
        whether to include or not component yield factor in quantity per assembly*/
        SELECT  nvl(include_component_yield, 1)
        INTO    l_include_comp_yield
        FROM    wip_parameters
        WHERE   organization_id = i_org_id;


      /******************************************************
      * Compute PL Costs for  WIP Scrap Return ...          *
      ******************************************************/
        stmt_num := 100;

	UPDATE WIP_REQ_OPERATION_COST_DETAILS W1
	SET
	 (TEMP_RELIEVED_VALUE,
	  RELIEVED_MATL_SCRAP_VALUE) =
	(SELECT
	  decode(SIGN(nvl(wro.RELIEVED_MATL_SCRAP_QUANTITY,0)-
                      /* LBM Project Changes */
		      abs(i_txn_qty)*(decode(wro.basis_type, 2,
                                            wro.quantity_per_assembly/i_lot_size,
                                            wro.quantity_per_assembly)/
                                      decode(l_include_comp_yield,
                                             1, nvl(wro.component_yield_factor,1),
                                             1))),
		 SIGN(wro.quantity_per_assembly),
                /* LBM Project Changes */
	         i_txn_qty*(decode(wro.basis_type, 2,
                                  wro.quantity_per_assembly/i_lot_size,
                                  wro.quantity_per_assembly)/
                            decode(l_include_comp_yield,
                                   1, nvl(wro.component_yield_factor,1),
                                   1))*
	    	(nvl(relieved_matl_scrap_value,0)/
		 decode(RELIEVED_MATL_SCRAP_QUANTITY,
			0,1,
			NULL,1,RELIEVED_MATL_SCRAP_QUANTITY)),
		 0,
	  	-1*nvl(relieved_matl_scrap_value,0),
		-1*SIGN(wro.quantity_per_assembly),
		-1*nvl(relieved_matl_scrap_value,0)),
	  nvl(w1.relieved_matl_scrap_value,0) +
	  decode(SIGN(nvl(wro.RELIEVED_MATL_SCRAP_QUANTITY,0)-
                      /* LBM Project Changes */
                      abs(i_txn_qty)*(decode(wro.basis_type, 2,
                                            wro.quantity_per_assembly/i_lot_size,
                                            wro.quantity_per_assembly)/
                                      decode(l_include_comp_yield,
                                             1, nvl(wro.component_yield_factor,1),
                                             1))),
                 SIGN(wro.quantity_per_assembly),
                 /* LBM Project Changes */
                 i_txn_qty*(decode(wro.basis_type, 2,
                                  wro.quantity_per_assembly/i_lot_size,
                                  wro.quantity_per_assembly)/
                            decode(l_include_comp_yield,
                                   1, nvl(wro.component_yield_factor,1),
                                   1))*
                (nvl(relieved_matl_scrap_value,0)/
                 decode(RELIEVED_MATL_SCRAP_QUANTITY,
                        0,1,
                        NULL,1,RELIEVED_MATL_SCRAP_QUANTITY)),
                 0,
                -1*nvl(relieved_matl_scrap_value,0),
                -1*SIGN(wro.quantity_per_assembly),
                -1*nvl(relieved_matl_scrap_value,0))
	 FROM
	 WIP_REQ_OPERATION_COST_DETAILS W2,
	 WIP_REQUIREMENT_OPERATIONS WRO
	 WHERE
	 W1.WIP_ENTITY_ID	=	W2.WIP_ENTITY_ID	AND
	 W1.ORGANIZATION_ID	=	W2.ORGANIZATION_ID	AND
	 W1.OPERATION_SEQ_NUM	=	W2.OPERATION_SEQ_NUM	AND
	 W1.INVENTORY_ITEM_ID	=	W2.INVENTORY_ITEM_ID	AND
	 W1.COST_ELEMENT_ID	=	W2.COST_ELEMENT_ID	AND
	 W2.WIP_ENTITY_ID	=	WRO.WIP_ENTITY_ID	AND
	 W2.ORGANIZATION_ID	=	WRO.ORGANIZATION_ID	AND
	 W2.OPERATION_SEQ_NUM	=	WRO.OPERATION_SEQ_NUM	AND
	 W2.INVENTORY_ITEM_ID	=	WRO.INVENTORY_ITEM_ID)
	WHERE
	(w1.WIP_ENTITY_ID, w1.ORGANIZATION_ID,
         w1.INVENTORY_ITEM_ID, w1.OPERATION_SEQ_NUM) IN
        (SELECT
         WIP_ENTITY_ID, ORGANIZATION_ID,
         INVENTORY_ITEM_ID,OPERATION_SEQ_NUM
         from
         WIP_REQUIREMENT_OPERATIONS wro2
         where
         wro2.WIP_ENTITY_ID     =       i_wip_entity_id AND
         wro2.ORGANIZATION_ID   =       i_org_id        AND
         wro2.QUANTITY_PER_ASSEMBLY     <> 0            AND
         wro2.OPERATION_SEQ_NUM <=      i_op_seq_num    AND
         wro2.WIP_SUPPLY_TYPE   not in (4,5,6));




        stmt_num := 120;

        UPDATE WIP_REQUIREMENT_OPERATIONS w
        SET RELIEVED_MATL_SCRAP_QUANTITY =
           (SELECT
	      nvl(w.RELIEVED_MATL_SCRAP_QUANTITY,0) +
	      decode(w2.RELIEVED_MATL_SCRAP_QUANTITY,
		     0,0,
                     /* LBM Project Changes */
                     i_txn_qty*(decode(w2.basis_type, 2,
                                      w2.quantity_per_assembly/i_lot_size,
                                      w2.quantity_per_assembly)/
                                decode(l_include_comp_yield,
                                       1, nvl(w2.component_yield_factor,1),
                                       1)))
            FROM
            WIP_REQUIREMENT_OPERATIONS w2
            where
            w.WIP_ENTITY_ID     =       w2.WIP_ENTITY_ID AND
            w.INVENTORY_ITEM_ID =       w2.INVENTORY_ITEM_ID AND
            w.OPERATION_SEQ_NUM =       w2.OPERATION_SEQ_NUM AND
            w.ORGANIZATION_ID   =       w2.ORGANIZATION_ID)
        WHERE
        w.WIP_ENTITY_ID         =       i_wip_entity_id AND
        w.ORGANIZATION_ID       =       i_org_id        AND
        w.WIP_SUPPLY_TYPE       not in  (4,5,6)         AND
	w.QUANTITY_PER_ASSEMBLY	<>	0		AND
        w.OPERATION_SEQ_NUM     <=      i_op_seq_num;

	stmt_num := 140;

        INSERT INTO WIP_SCRAP_VALUES
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
        i_trx_id,
        2,
        wrocd.cost_element_id,
        NULL,
        SYSDATE,
        -1,
        -1,
        SYSDATE,
        -1,
        sum(nvl(temp_relieved_value,0))/i_txn_qty,
        -1,
        -1,
        -1,
        SYSDATE
        FROM
         WIP_REQ_OPERATION_COST_DETAILS wrocd
         where
         wrocd.WIP_ENTITY_ID    =       i_wip_entity_id AND
         wrocd.ORGANIZATION_ID  =       i_org_id
        GROUP BY wrocd.COST_ELEMENT_ID
        HAVING sum(nvl(temp_relieved_value,0))  <> 0;



	If (l_system_option_id = 1) THEN

 	stmt_num := 150;

        UPDATE WIP_OPERATION_RESOURCES W1
        SET
         (RELIEVED_RES_SCRAP_UNITS,
          TEMP_RELIEVED_VALUE,
          RELIEVED_RES_scrap_VALUE) =
        (SELECT
          nvl(W1.RELIEVED_RES_scrap_UNITS,0)+
          nvl(W2.RELIEVED_RES_scrap_UNITS,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
                 i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY)),
          nvl(W2.RELIEVED_RES_scrap_VALUE,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
                 i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY)),
          nvl(W1.RELIEVED_RES_scrap_VALUE,0)+
          nvl(W2.RELIEVED_RES_scrap_VALUE,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
                 i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY))
        FROM
        WIP_OPERATION_RESOURCES W2,
        cst_comp_snapshot COCD
        WHERE
        W2.WIP_ENTITY_ID        =       W1.WIP_ENTITY_ID        AND
        W2.ORGANIZATION_ID      =       W1.ORGANIZATION_ID      AND
        W2.OPERATION_SEQ_NUM    =       W1.OPERATION_SEQ_NUM    AND
        W2.RESOURCE_SEQ_NUM     =       W1.RESOURCE_SEQ_NUM     AND
        W2.WIP_ENTITY_ID        =       COCD.WIP_ENTITY_ID      AND
        W2.OPERATION_SEQ_NUM    =       COCD.OPERATION_SEQ_NUM  AND
        COCD.NEW_OPERATION_FLAG =       2                       AND
        COCD.TRANSACTION_ID     =       I_TRX_ID)
        WHERE
        W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
        W1.ORGANIZATION_ID      =       I_ORG_ID		AND
        w1.usage_rate_or_amount <>      0                       AND
        w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;


	stmt_num := 155;

        UPDATE wip_operation_overheads W1
        SET
         (RELIEVED_ovhd_SCRAP_UNITS,
          TEMP_RELIEVED_VALUE,
          RELIEVED_ovhd_scrap_value) =
        (SELECT
          nvl(W1.RELIEVED_ovhd_SCRAP_UNITS,0)+
          nvl(W2.RELIEVED_ovhd_SCRAP_UNITS,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
            i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY)),
          nvl(W2.RELIEVED_ovhd_scrap_value,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
           i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY)),
          nvl(W1.RELIEVED_ovhd_scrap_value,0)+
          nvl(W2.RELIEVED_ovhd_scrap_value,0)*
          decode(abs(i_txn_qty),
                 PRIOR_SCRAP_QUANTITY,-1,
           i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,PRIOR_SCRAP_QUANTITY))
        FROM
        wip_operation_overheads W2,
        cst_comp_snapshot COCD
        WHERE
        W2.WIP_ENTITY_ID        =       W1.WIP_ENTITY_ID        AND
        W2.ORGANIZATION_ID      =       W1.ORGANIZATION_ID      AND
        W2.OPERATION_SEQ_NUM    =       W1.OPERATION_SEQ_NUM    AND
        W2.RESOURCE_SEQ_NUM     =       W1.RESOURCE_SEQ_NUM     AND
        W2.OVERHEAD_ID		=       W1.OVERHEAD_ID		AND
/*bug#3469342. */
        w1.basis_type           =       w2.basis_type           AND
        W2.WIP_ENTITY_ID        =       COCD.WIP_ENTITY_ID      AND
        W2.OPERATION_SEQ_NUM    =       COCD.OPERATION_SEQ_NUM  AND
        COCD.NEW_OPERATION_FLAG =       2                       AND
        COCD.TRANSACTION_ID     =       I_TRX_ID)
        WHERE
        W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
        W1.ORGANIZATION_ID      =       I_ORG_ID                AND
        w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;


	ELSE

	stmt_num := 160;

	UPDATE WIP_OPERATION_RESOURCES W1
	SET
	 (RELIEVED_RES_SCRAP_UNITS,
	  TEMP_RELIEVED_VALUE,
	  RELIEVED_RES_SCRAP_VALUE) =
	(SELECT
	  nvl(w1.RELIEVED_RES_SCRAP_UNITS,0) +
	  decode(w2.RELIEVED_RES_SCRAP_UNITS,
		 0,0,
	  	 i_txn_qty*decode(w2.basis_type,
	 		   	  1,usage_rate_or_amount,
			   	  2,usage_rate_or_amount/i_lot_size,
			   	  usage_rate_or_amount)),
	  decode(SIGN(nvl(relieved_res_scrap_units,0)-
		      abs(i_txn_qty)*
		      decode(w2.basis_type,
			     1,usage_rate_or_amount,
                             2,usage_rate_or_amount/i_lot_size,
                             usage_rate_or_amount)),
	 	 SIGN(usage_rate_or_amount),
		 i_txn_qty*decode(basis_type,
				  1,usage_rate_or_amount,
			 	  2,usage_rate_or_amount/i_lot_size,
				  usage_rate_or_amount)*
		 (nvl(relieved_res_scrap_value,0)/
		 decode(relieved_res_scrap_units,
			0,1,
			NULL,1,
			relieved_res_scrap_units)),
		 0,
		-1*nvl(relieved_res_scrap_value,0),
		-1*SIGN(usage_rate_or_amount),
		 0),
	 nvl(w1.relieved_res_scrap_value,0) +
	 decode(SIGN(nvl(relieved_res_scrap_units,0)-
                      abs(i_txn_qty)*
                      decode(w2.basis_type,
                             1,usage_rate_or_amount,
                             2,usage_rate_or_amount/i_lot_size,
                             usage_rate_or_amount)),
                 SIGN(usage_rate_or_amount),
                 i_txn_qty*decode(basis_type,
                                  1,usage_rate_or_amount,
                                  2,usage_rate_or_amount/i_lot_size,
                                  usage_rate_or_amount)*
                 (nvl(relieved_res_scrap_value,0)/
                 decode(relieved_res_scrap_units,
                        0,1,
                        NULL,1,
                        relieved_res_scrap_units)),
                 0,
                -1*nvl(relieved_res_scrap_value,0),
                -1*SIGN(usage_rate_or_amount),
                 0)
	FROM
	WIP_OPERATION_RESOURCES w2
	where
         w2.WIP_ENTITY_ID       =       w1.WIP_ENTITY_ID        AND
         w2.OPERATION_SEQ_NUM   =       w1.OPERATION_SEQ_NUM    AND
         w2.RESOURCE_SEQ_NUM    =       w1.RESOURCE_SEQ_NUM     AND
         w2.ORGANIZATION_ID     =       w2.ORGANIZATION_ID)
	where
        w1.WIP_ENTITY_ID        =       i_wip_entity_id         AND
        w1.ORGANIZATION_ID      =       i_org_id                AND
	w1.usage_rate_or_amount	<>	0			AND
        w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;



	/********************************************************
	* Compute TL Move based Ovhd costs for Scrap Return ... *
	*********************************************************/

	stmt_num := 200;

	UPDATE WIP_OPERATION_OVERHEADS W1
	SET
	 (RELIEVED_OVHD_SCRAP_UNITS,
	  TEMP_RELIEVED_VALUE,
	  RELIEVED_OVHD_SCRAP_VALUE) =
	(SELECT
	 nvl(w1.relieved_ovhd_scrap_units,0) +
	 decode(w2.relieved_ovhd_scrap_units,
		0,0,
		decode(basis_type,
		       1,i_txn_qty,
		       2,i_txn_qty/i_lot_size)),
	 decode(SIGN(nvl(relieved_ovhd_scrap_units,0) -
		     abs(i_txn_qty)*
	 	     decode(basis_type,
			    1,1,
			    2,1/i_lot_size)),
		1,
		decode(basis_type,
		       1,i_txn_qty,
		       2,i_txn_qty/i_lot_size)*
		(nvl(relieved_ovhd_scrap_value,0)/
		 decode(relieved_ovhd_scrap_units,
			0,1,
			NULL,1,
			relieved_ovhd_scrap_units)),
		0,
	       -1*nvl(relieved_ovhd_scrap_value,0),
	       -1,
		0),
	nvl(w1.relieved_ovhd_scrap_value,0) +
	decode(SIGN(nvl(relieved_ovhd_scrap_units,0) -
                     abs(i_txn_qty)*
                     decode(basis_type,
                            1,1,
                            2,1/i_lot_size)),
                1,
                decode(basis_type,
                       1,i_txn_qty,
                       2,i_txn_qty/i_lot_size)*
                (nvl(relieved_ovhd_scrap_value,0)/
                 decode(relieved_ovhd_scrap_units,
                        0,1,
                        NULL,1,
                        relieved_ovhd_scrap_units)),
                0,
               -1*nvl(relieved_ovhd_scrap_value,0),
               -1,
                0)
	FROM
	WIP_OPERATION_OVERHEADS W2
	WHERE
	W1.WIP_ENTITY_ID	=	W2.WIP_ENTITY_ID	AND
	W1.ORGANIZATION_ID	=	W2.ORGANIZATION_ID	AND
	W1.OPERATION_SEQ_NUM	=	W2.OPERATION_SEQ_NUM	AND
	W1.OVERHEAD_ID		=	W2.OVERHEAD_ID		AND
	W1.BASIS_TYPE 		=	W2.BASIS_TYPE)
	where
	W1.WIP_ENTITY_ID	=	i_wip_entity_id 	and
	W1.ORGANIZATION_ID	=	i_org_id		and
	W1.OPERATION_SEQ_NUM	<=	i_op_seq_num		and
	W1.BASIS_TYPE		IN	(1,2);



        /********************************************************
        * Compute TL Res based Ovhd costs for Scrap Return ...  *
        *********************************************************/

	stmt_num := 220;


        UPDATE WIP_OPERATION_OVERHEADS W1
        SET
         (RELIEVED_OVHD_SCRAP_UNITS,
          TEMP_RELIEVED_VALUE,
          RELIEVED_OVHD_SCRAP_VALUE) =
        (SELECT
	 nvl(w1.relieved_ovhd_scrap_units,0) +
	 decode(w2.relieved_ovhd_scrap_units,
		0,0,
		decode(w2.basis_type,
		       3,i_txn_qty*decode(wor.basis_type,
				          1,usage_rate_or_amount,
				          2,usage_rate_or_amount/i_lot_size),
		       4,wor.temp_relieved_value)),
	 decode(SIGN(nvl(relieved_ovhd_scrap_units,0) -
		     abs(decode(w2.basis_type,
			 3,i_txn_qty*decode(wor.basis_type,
			 		    1,usage_rate_or_amount,
					    2,usage_rate_or_amount/i_lot_size),
			 4,wor.temp_relieved_value))),
		SIGN(wor.usage_rate_or_amount),
	 	decode(w2.basis_type,
		       3,i_txn_qty*decode(wor.basis_type,
					  1,usage_rate_or_amount,
					  2,usage_rate_or_amount/i_lot_size),
		       4,wor.temp_relieved_value)*
		(nvl(relieved_ovhd_scrap_value,0)/
		 decode(relieved_ovhd_scrap_units,
                        0,1,
                        NULL,1,
                        relieved_ovhd_scrap_units)),
		0,
	       -1*nvl(relieved_ovhd_scrap_value,0),
	       -1*SIGN(wor.usage_rate_or_amount),
		0),
	 nvl(relieved_ovhd_scrap_value,0) +
	 decode(SIGN(nvl(relieved_ovhd_scrap_units,0) -
                     abs(decode(w2.basis_type,
                         3,i_txn_qty*decode(wor.basis_type,
                                            1,usage_rate_or_amount,
                                            2,usage_rate_or_amount/i_lot_size),
                         4,wor.temp_relieved_value))),
                SIGN(wor.usage_rate_or_amount),
                decode(w2.basis_type,
                       3,i_txn_qty*decode(wor.basis_type,
                                          1,usage_rate_or_amount,
                                          2,usage_rate_or_amount/i_lot_size),
                       4,wor.temp_relieved_value)*
                (nvl(relieved_ovhd_scrap_value,0)/
                 decode(relieved_ovhd_scrap_units,
                        0,1,
                        NULL,1,
                        relieved_ovhd_scrap_units)),
                0,
               -1*nvl(relieved_ovhd_scrap_value,0),
               -1*SIGN(wor.usage_rate_or_amount),
                0)
	FROM
	WIP_OPERATION_OVERHEADS W2,
	WIP_OPERATION_RESOURCES WOR
	where
	W2.WIP_ENTITY_ID	=	W1.WIP_ENTITY_ID	AND
	W2.ORGANIZATION_ID	=	W1.ORGANIZATION_ID	AND
	W2.OPERATION_SEQ_NUM	=	W1.OPERATION_SEQ_NUM	AND
	W2.RESOURCE_SEQ_NUM	=	W1.RESOURCE_SEQ_NUM	AND
	W2.OVERHEAD_ID		=	W1.OVERHEAD_ID	  	AND
	W2.BASIS_TYPE		=	W1.BASIS_TYPE		AND
	W2.WIP_ENTITY_ID	=	WOR.WIP_ENTITY_ID	AND
	W2.ORGANIZATION_ID	=	WOR.ORGANIZATION_ID	AND
	W2.OPERATION_SEQ_NUM	=	WOR.OPERATION_SEQ_NUM	AND
	W2.RESOURCE_SEQ_NUM	=	WOR.RESOURCE_SEQ_NUM)
	where
	W1.WIP_ENTITY_ID        =       i_wip_entity_id         AND
        W1.ORGANIZATION_ID      =       i_org_id                AND
        W1.OPERATION_SEQ_NUM    <=      i_op_seq_num            AND
        W1.BASIS_TYPE           IN      (3,4);


	END IF; -- The If for system option ends here.

        stmt_num := 245;

                INSERT INTO WIP_SCRAP_VALUES
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
         i_trx_id,
         1,
         br.cost_element_id,
         NULL,
         SYSDATE,
         -1,
         -1,
         SYSDATE,
         -1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         -1,
         -1,
         -1,
         SYSDATE
        FROM
        WIP_OPERATION_RESOURCES wor,
        BOM_RESOURCES br
        WHERE
        br.RESOURCE_ID  =       WOR.RESOURCE_ID         AND
        br.ORGANIZATION_ID =    WOR.ORGANIZATION_ID     AND
        WIP_ENTITY_ID   =       i_wip_entity_id         AND
        wor.ORGANIZATION_ID =       i_org_id
        group by br.cost_element_id
        HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;


	stmt_num := 250;

        INSERT INTO WIP_SCRAP_VALUES
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
         i_trx_id,
         1,
         5,
         NULL,
         SYSDATE,
         -1,
         -1,
         SYSDATE,
         -1,
         SUM(nvl(temp_relieved_value,0))/i_txn_qty,
         -1,
         -1,
         -1,
         SYSDATE
        FROM
        WIP_OPERATION_OVERHEADS
        WHERE
        WIP_ENTITY_ID           =       i_wip_entity_id         AND
        ORGANIZATION_ID         =       i_org_id
        HAVING
        SUM(nvl(temp_relieved_value,0)) <>      0;


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
         cost_element_id,
         level_type,
         cost_element_value,
         NULL,
         NULL,
         NULL,
         SYSDATE,
         -1,
         SYSDATE,
         -1,
         -1,
         -1,
         -1,
         -1,
         SYSDATE
        FROM
        WIP_SCRAP_VALUES
        WHERE
        TRANSACTION_ID  =       i_trx_id        AND
        COST_UPDATE_ID IS NULL;


 EXCEPTION

        WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := 'CSTPACWS' || to_char(stmt_num) || substr(SQLERRM,1,150);


 END scrap_return;


END CSTPACWS;

/
