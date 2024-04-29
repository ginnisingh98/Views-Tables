--------------------------------------------------------
--  DDL for Package Body CSTPLCAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLCAC" AS
/* $Header: CSTLCACB.pls 120.2.12010000.2 2008/08/08 12:30:43 smsasidh ship $ */


PROCEDURE assembly_completion (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_txn_date            IN      DATE,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_final_comp_flag     IN      VARCHAR2,
  i_cost_type_id        IN      NUMBER,
  i_res_cost_type_id    IN      NUMBER,
  i_cost_group_id       IN      NUMBER,
  i_acct_period_id      IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_movhd_cost_type_id  OUT NOCOPY     NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS

  l_stmt_num          NUMBER := 0;

  l_sql_stmt          VARCHAR2(8000);
  l_layer_cursor      CSTPLMWI.REF_CURSOR_TYPE;
  l_layer             cst_wip_layers%ROWTYPE;

  l_txn_qty_remaining NUMBER;
  l_consumed_qty      NUMBER;

  /* Bug 2186966 */

  l_exp_item          NUMBER;

  l_lot_size          NUMBER := 1; /* Added as part of LBM */
  l_include_comp_yield NUMBER;

  /* Changed as a part of LBM project Bug #3926918
     Added decode to WRO.qpa to get proportioned qpa in
     case of Lot Based Materials
     Divide the value of quantity per assembly by component
     yield factor if Include Component Yield Flag is checked
     in WIP Parameters.*/
  cursor wro_cursor is
    select WRO.operation_seq_num,
           WRO.inventory_item_id,
           Decode(WRO.basis_type, 2, WRO.quantity_per_assembly/l_lot_size,
                                     WRO.quantity_per_assembly)/
                  DECODE(l_include_comp_yield,
                         1, nvl(WRO.component_yield_factor,1),
                         1) quantity_per_assembly,
           WRO.component_yield_factor
    from   wip_requirement_operations WRO
    where  WRO.wip_entity_id         =      i_wip_entity_id and
           WRO.wip_supply_type       not in (4,5,6)         and
           WRO.quantity_per_assembly <>     0;

  l_comp_cost_source  NUMBER;
  l_c_cost_type_id    NUMBER;
  l_use_val_cost_type NUMBER;
  l_err_code          VARCHAR2(240);
  l_src_cost_type_id  NUMBER;
  l_wip_entity_type   NUMBER;
  l_wro_count         NUMBER; /* Added for bug 4246122*/


BEGIN

  -- normally i_txn_qty > 0 for assembly completions

  ----------------------------------------------------
  -- Update temp_relieved_value to zero in all tables
  ----------------------------------------------------

  l_stmt_num := 10;

  CSTPLMWI.reset_temp_columns
  (
    i_wip_entity_id,
    o_err_num,
    o_err_msg
  );
  IF o_err_num <> 0 THEN
    RETURN;
  END IF;


  /*---------------------------------------------
       Get the lot size of the job
   (Form validation takes care lot size is not 0)
       Added for Lot Based Materials project
  ----------------------------------------------*/
  l_stmt_num := 20;
  SELECT  wdj.start_quantity
  INTO    l_lot_size
  FROM    wip_discrete_jobs wdj
  WHERE   wdj.wip_entity_id     =   i_wip_entity_id
  AND     wdj.organization_id   =   i_org_id;

  /*----------------------------------------------
  Get the value of Include Component yield flag,
  which will determine whether to include or not
  component yield factor in quantity per assembly
  ------------------------------------------------*/
  l_stmt_num := 25;
  SELECT  nvl(include_component_yield, 1)
  INTO    l_include_comp_yield
  FROM    wip_parameters
  WHERE   organization_id = i_org_id;

  -----------------------------------------
  -- retrieve information for determining
  -- one of five cases
  -----------------------------------------

  l_stmt_num := 45;
  select we.entity_type
  into   l_wip_entity_type
  from   wip_entities we
  where  we.wip_entity_id = i_wip_entity_id and
         we.entity_type in (1,3,4);  /* excludes Repetitive */


  IF l_wip_entity_type in (1,3) /* Discrete */ THEN

    l_stmt_num := 50;
    select
      wac.completion_cost_source,
      nvl( wac.cost_type_id, -1 )
    into
      l_comp_cost_source,
      l_c_cost_type_id
    from
      wip_accounting_classes wac,
      wip_discrete_jobs wdj
    where
      wdj.wip_entity_id   = i_wip_entity_id         and
      wdj.organization_id = i_org_id                and
      wdj.class_code      = wac.class_code          and
      wdj.organization_id = wac.organization_id;

  ELSIF l_wip_entity_type = 4 /* Flow */ THEN

    l_stmt_num := 53;
    select
      wac.completion_cost_source,
      nvl( wac.cost_type_id, -1 )
    into
      l_comp_cost_source,
      l_c_cost_type_id
    from
      wip_accounting_classes wac,
      wip_flow_schedules wfs
    where
      wfs.wip_entity_id   = i_wip_entity_id         and
      wfs.organization_id = i_org_id                and
      wfs.class_code      = wac.class_code          and
      wfs.organization_id = wac.organization_id;

  END IF;

  -----------------------------------------------------
  -- If a non-std job has no bill or routing associated
  -- with it or if a std job has no bill or routing
  -- associated with it - these need to be treated
  -- specially.
  -----------------------------------------------------

  IF l_wip_entity_type in (1,3) /* Discrete */ THEN

    l_stmt_num := 60;
    SELECT
      decode( job_type,
	1, decode( bom_revision,
		   NULL, decode(routing_revision,NULL,-1,1),
		   1 ),
	3, decode( bom_reference_id,
		   NULL, decode(routing_reference_id,NULL,-1,1),
		   1 ),
	1 )
    into
      l_use_val_cost_type
    from
      WIP_DISCRETE_JOBS
    WHERE
      WIP_ENTITY_ID   = i_wip_entity_id AND
      ORGANIZATION_ID = i_org_id;

  ELSIF l_wip_entity_type = 4 /* Flow */ THEN

    l_stmt_num := 63;
    SELECT
	decode( bom_revision,
	        NULL, decode(routing_revision,NULL,-1,1),
		1 )
    into
      l_use_val_cost_type
    from
      wip_flow_schedules wfs
    WHERE
      wfs.WIP_ENTITY_ID   = i_wip_entity_id AND
      wfs.ORGANIZATION_ID = i_org_id;

  END IF;

  /* Added for bug 4246122
     Material Requirement can be added manually for the job */
     IF (l_use_val_cost_type = -1) THEN
/* Commented for Bug6734270.If there is a resource
   added manually then also the l_use_val_cost_type
   should be 1

              SELECT COUNT(*)
              INTO   l_wro_count
              FROM   wip_requirement_operations
              WHERE  wip_entity_id = i_wip_entity_id
              AND    organization_id = i_org_id
              AND    quantity_per_assembly <> 0;
*/

              SELECT 	COUNT(1)
              INTO 	l_wro_count
              FROM 	dual
              WHERE 	EXISTS ( SELECT NULL
                                 FROM 	wip_requirement_operations wro
                                 WHERE 	wro.wip_entity_id = i_wip_entity_id
                                 AND 	wro.quantity_per_assembly <>0
                                   UNION ALL
                                 SELECT NULL
                                 FROM 	wip_operation_resources wor
                                 WHERE 	wor.wip_entity_id = i_wip_entity_id
                                 AND wor.usage_rate_or_amount <>0
                                );


              if (l_wro_count > 0) then
                 l_use_val_cost_type := 1;
              end if;
     END IF;


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

  l_stmt_num := 70;

  IF( l_comp_cost_source = 1 ) THEN
    o_movhd_cost_type_id := i_res_cost_type_id;
  ELSE
    o_movhd_cost_type_id := l_c_cost_type_id;
  END IF;







  ---------------------------------------------------------
  -- Final Completion
  ---------------------------------------------------------

  IF ( i_final_comp_flag = 'Y' ) THEN
    -- If final completion, flush out all WIP layer quantities,
    -- then call Avg completion algorithm to flush out the values
    -- from WROCD, WRO, WOO, WOR

    l_stmt_num := 80;
    update cst_wip_layers CWL
    set
      CWL.relieved_matl_comp_qty =
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty ),
      CWL.temp_relieved_qty =
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty )
    where
      CWL.wip_entity_id = i_wip_entity_id and
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty ) >= 0;

    l_stmt_num := 90;
    update cst_wip_layers CWL
    set
      CWL.relieved_matl_final_comp_qty =
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty ),
      CWL.temp_relieved_qty =
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty )
    where
      CWL.wip_entity_id = i_wip_entity_id and
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty ) < 0;

    -- Call the Average Costing WIP Assembly Completion routine.
    l_stmt_num := 100;
    CSTPACWC.complete
    (
      i_trx_id             => i_txn_id,
      i_txn_qty            => i_txn_qty,
      i_txn_date           => i_txn_date,
      i_acct_period_id     => i_acct_period_id,
      i_wip_entity_id      => i_wip_entity_id,
      i_org_id             => i_org_id,
      i_inv_item_id        => i_inv_item_id,
      i_cost_type_id       => i_cost_type_id,
      i_res_cost_type_id   => i_res_cost_type_id,
      i_final_comp_flag    => i_final_comp_flag,
      i_layer_id           => i_layer_id,
      i_movhd_cost_type_id => o_movhd_cost_type_id,
      i_cost_group_id      => i_cost_group_id,
      i_user_id            => i_user_id,
      i_login_id           => i_login_id,
      i_request_id         => i_request_id,
      i_prog_id            => i_prog_id,
      i_prog_appl_id       => i_prog_appl_id,
      err_num              => o_err_num,
      err_code             => l_err_code,
      err_msg              => o_err_msg
    );

    RETURN;



  ELSIF( l_comp_cost_source = 2 OR
       ( l_comp_cost_source = 1 AND l_use_val_cost_type = -1) ) THEN

  ---------------------------------------------------------------
  -- Regular Completion, with user-specified cost type
  --   OR
  -- Regular Completion, supposed to be dynamic, but no bom/routing
  --
  -- In this case we complete using the cost from CICD
  ---------------------------------------------------------------


    -- If this was to be dynamically computed, but without
    -- bom/routing, then we use the valuation cost type, which
    -- should be the cost_type_id passed in to this function.

    IF l_comp_cost_source = 1 THEN
      l_src_cost_type_id := i_cost_type_id;
    ELSE
      l_src_cost_type_id := l_c_cost_type_id;
    END IF;

    l_stmt_num := 110;

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
      PROGRAM_UPDATE_DATE
    )
    SELECT
      i_txn_id,
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
    FROM CST_LAYER_COST_DETAILS
    WHERE LAYER_ID = i_layer_id
      AND NOT ( COST_ELEMENT_ID = 2 AND
                LEVEL_TYPE      = 1 );

  ELSE

  ------------------------------------------------------------
  -- Derive the Comp costs dynamically based on current costs
  -- in the JOb ...
  ------------------------------------------------------------

   ----------------------------------------------
    -- Consume component material quantities
    ----------------------------------------------


   FOR wro_rec IN wro_cursor LOOP
   /* Get the expense flag for the item */
   --------------------------------------------------------
   -- Get whether the Component is Asset/Expense
   --------------------------------------------------------

     SELECT decode(INVENTORY_ASSET_FLAG,'Y',0,1)
     INTO   l_exp_item
     FROM   MTL_SYSTEM_ITEMS
     WHERE  INVENTORY_ITEM_ID = wro_rec.inventory_item_id
     AND    ORGANIZATION_ID   = i_org_id;


   /* If item is not an expense item, create-consume layers */
     IF ( l_exp_item <> 1 ) THEN
      CSTPLMWI.init_wip_layers
      (
        i_wip_entity_id,
        wro_rec.operation_seq_num,
        wro_rec.inventory_item_id,
        i_org_id,
        i_txn_id,
        i_layer_id,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_id,
        i_prog_appl_id,
        o_err_num,
        o_err_msg
      );
      IF o_err_num <> 0 THEN
        RETURN;
      END IF;


      -- consume WIP layer(s)
      -- assembly completions consume WIP in normal order
      l_stmt_num := 120;
      l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                    (
                      ' sign( CWL.applied_matl_qty -               ' ||
                      '       CWL.relieved_matl_comp_qty -         ' ||
                      '       CWL.relieved_matl_scrap_qty -        ' ||
                      '       CWL.relieved_matl_final_comp_qty ) = ' ||
                      ' sign( :quantity_per_assembly )             ',
                      i_cost_method_id,
                      CSTPLMWI.NORMAL
                    );

      l_stmt_num := 130;
      open  l_layer_cursor
      for   l_sql_stmt
      using i_wip_entity_id,
            wro_rec.operation_seq_num,
            wro_rec.inventory_item_id,
            wro_rec.quantity_per_assembly;

      l_txn_qty_remaining := i_txn_qty * wro_rec.quantity_per_assembly;

      LOOP
        exit when l_txn_qty_remaining = 0;

        l_stmt_num := 140;
        fetch l_layer_cursor into l_layer;

        l_stmt_num := 150;
        IF l_layer_cursor%NOTFOUND THEN

          l_layer := CSTPLMWI.get_last_layer
                     (
                       i_wip_entity_id,
                       wro_rec.operation_seq_num,
                       wro_rec.inventory_item_id,
                       o_err_num,
                       o_err_msg
                     );
          IF o_err_num <> 0 THEN
            RETURN;
          END IF;

          l_consumed_qty := l_txn_qty_remaining;

        ELSE
          l_consumed_qty := sign( wro_rec.quantity_per_assembly ) *
                            least( sign( wro_rec.quantity_per_assembly ) *
                                   ( l_layer.applied_matl_qty -
                                     l_layer.relieved_matl_comp_qty -
                                     l_layer.relieved_matl_scrap_qty -
                                     l_layer.relieved_matl_final_comp_qty ),
                                   sign( wro_rec.quantity_per_assembly ) *
                                     l_txn_qty_remaining );
        END IF;


        l_stmt_num := 160;
        update cst_wip_layers CWL
        set
          relieved_matl_comp_qty = relieved_matl_comp_qty + l_consumed_qty,
          temp_relieved_qty      = temp_relieved_qty      + l_consumed_qty
        where
          wip_layer_id = l_layer.wip_layer_id and
          inv_layer_id = l_layer.inv_layer_id;

        l_txn_qty_remaining := l_txn_qty_remaining - l_consumed_qty;

      END LOOP; -- l_layer_cursor

      l_stmt_num := 170;
      close l_layer_cursor;

    /* Don't close cursor here */
    --    END LOOP; -- wro_cursor


    /* Update WROCD for the non expense item */


    -- update WROCD

    l_stmt_num := 180;
    update wip_req_operation_cost_details WROCD
    set
    (
      WROCD.relieved_matl_completion_value,
      WROCD.temp_relieved_value
    )
    =
    (
      select
        NVL( WROCD.relieved_matl_completion_value, 0 ) +
          sum( CWL.temp_relieved_qty * CWLCD.layer_cost ),
        sum( CWL.temp_relieved_qty * CWLCD.layer_cost )
      from
        cst_wip_layers CWL,
        cst_wip_layer_cost_details CWLCD
      where
        CWL.wip_entity_id     =  WROCD.wip_entity_id     and
        CWL.operation_seq_num =  WROCD.operation_seq_num and
        CWL.inventory_item_id =  WROCD.inventory_item_id and
        CWL.temp_relieved_qty <> 0                       and
        CWLCD.wip_layer_id    =  CWL.wip_layer_id        and
        CWLCD.inv_layer_id    =  CWL.inv_layer_id        and
        CWLCD.cost_element_id =  WROCD.cost_element_id   and
        CWLCD.level_type in (1, 2)
    )
    where
      (
        WROCD.wip_entity_id,
        WROCD.operation_seq_num,
        WROCD.inventory_item_id
      )
      IN
      (
        select wip_entity_id,
               operation_seq_num,
               inventory_item_id
        from   wip_requirement_operations WRO
        where
          WRO.wip_entity_id         =      i_wip_entity_id   and
          /* Restrict only to the current Item */
          WRO.operation_seq_num  = wro_rec.operation_seq_num and
          WRO.inventory_item_id  = wro_rec.inventory_item_id and
          --
          -- exclude bulk, supplier, phantom
          --
          WRO.wip_supply_type       not in (4,5,6)         and
          WRO.quantity_per_assembly <>     0
      );

/* Update WRO record for this item. */

    -- update WRO
    update wip_requirement_operations WRO
    set relieved_matl_completion_qty
    =
    (
      select
        NVL( WRO.relieved_matl_completion_qty, 0 ) +
          sum( CWL.temp_relieved_qty )
      from
        cst_wip_layers CWL
      where
        CWL.wip_entity_id     =  WRO.wip_entity_id     and
        CWL.operation_seq_num =  WRO.operation_seq_num and
        CWL.inventory_item_id =  WRO.inventory_item_id and
        CWL.temp_relieved_qty <> 0
    )
    where
     WRO.wip_entity_id      = i_wip_entity_id           and
     /* Only for Current Item */
     WRO.operation_seq_num  = wro_rec.operation_seq_num and
     WRO.inventory_item_id  = wro_rec.inventory_item_id and
      --
      -- exclude bulk, supplier, phantom
      --
      WRO.wip_supply_type       not in (4,5,6)         and
      WRO.quantity_per_assembly <>     0;

   ELSE
    -- If Item is an Expense Item
    -- Just Insert into WROCD if not already there and
    -- update relieved_matl_completion_qty

     INSERT INTO WIP_REQ_OPERATION_COST_DETAILS
     (
     WIP_ENTITY_ID,
     OPERATION_SEQ_NUM,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     COST_ELEMENT_ID,
     APPLIED_MATL_VALUE,
     RELIEVED_MATL_COMPLETION_VALUE,
     RELIEVED_MATL_SCRAP_VALUE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE
    )
    SELECT
     i_wip_entity_id,       -- WIP_ENTITY_ID,
     wro_rec.operation_seq_num,          -- OPERATION_SEQ_NUM,
     i_org_id,              -- ORGANIZATION_ID,
     wro_rec.inventory_item_id,         -- INVENTORY_ITEM_ID,
     CCE.cost_element_id,   -- COST_ELEMENT_ID,
     0,                     -- APPLIED_MATL_VALUE,
     0,                     -- RELIEVED_MATL_COMPLETION_VALUE,
     0,                     -- RELIEVED_MATL_SCRAP_VALUE,
     i_user_id,             -- LAST_UPDATED_BY,
     sysdate,               -- LAST_UPDATE_DATE,
     sysdate,               -- CREATION_DATE,
     i_user_id,             -- CREATED_BY,
     i_login_id,            -- LAST_UPDATE_LOGIN,
     i_request_id,          -- REQUEST_ID,
     i_prog_appl_id,        -- PROGRAM_APPLICATION_ID,
     i_prog_id,             -- PROGRAM_ID,
     sysdate                -- PROGRAM_UPDATE_DATE
   from
    cst_cost_elements CCE
   where
    NOT EXISTS
    (
      SELECT 'X'
      FROM   WIP_REQ_OPERATION_COST_DETAILS WROCD2
      WHERE
        WROCD2.WIP_ENTITY_ID     = i_wip_entity_id       AND
        WROCD2.OPERATION_SEQ_NUM = wro_rec.operation_seq_num          AND
        WROCD2.INVENTORY_ITEM_ID = wro_rec.inventory_item_id          AND
        WROCD2.COST_ELEMENT_ID   = CCE.cost_element_id
    ) AND
    EXISTS
    (
      select 'x'
      from   wip_requirement_operations WRO
      where  WRO.wip_entity_id     = i_wip_entity_id  and
             WRO.operation_seq_num = wro_rec.operation_seq_num     and
             WRO.inventory_item_id = wro_rec.inventory_item_id     and
             WRO.wip_supply_type not in (4, 5, 6)
    )
   group by
    CCE.cost_element_id;

   /* Changed as part of LBM project. Added decode to qpa for Lot Based Materials */

   UPDATE wip_requirement_operations w1
   SET
   relieved_matl_completion_qty =
   (SELECT
     nvl(w1.relieved_matl_completion_qty,0) +
     i_txn_qty*(Decode(w2.basis_type, 2,w2.quantity_per_assembly/l_lot_size,
	                             w2.quantity_per_assembly) /
                      decode(l_include_comp_yield,
                             1, nvl(w2.component_yield_factor,1),
                             1))
    FROM
     wip_requirement_operations w2
    WHERE
     w1.wip_entity_id       =       w2.wip_entity_id        AND
     w1.organization_id     =       w2.organization_id      AND
     w1.inventory_item_id   =       w2.inventory_item_id    AND
     w1.operation_seq_num   =       w2.operation_seq_num )
    WHERE
     --
     -- Exclude bulk, supplier, phantom
     --
     w1.wip_supply_type     not in  (4,5,6)			AND
     w1.wip_entity_id       =       i_wip_entity_id         AND
     w1.organization_id     =       i_org_id                AND
     w1.inventory_item_id   =       wro_rec.inventory_item_id   AND
     w1.operation_seq_num   =       wro_rec.operation_seq_num   AND
     w1.quantity_per_assembly  <>   0;


    END IF; -- End IF Not Expense Item


  END LOOP; -- wro_cursor


    --------------------------------------------------------------
    -- BEGIN Dual maintenance section with CSTPACCB.pls
    --------------------------------------------------------------

    -----------------------------------------------------------
    -- Relieve This Level Resource costs/units from WIP ...
    -----------------------------------------------------------

    -- If we use the actual resource option, then use the snapshot for
    -- both resources and overheads.

    l_stmt_num := 190;

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
    w1.wip_entity_id        =       w2.wip_entity_id        AND
    w1.operation_seq_num    =       w2.operation_seq_num    AND
    w1.resource_seq_num     =       w2.resource_seq_num     AND
    w1.organization_id      =       w2.organization_id      AND
    w1.basis_type           =       w2.basis_type           AND /* Added for bug 5247584 */
    w2.operation_seq_num    =       cocd.operation_seq_num  AND
    cocd.new_operation_flag =       2                       AND
    cocd.transaction_id     =       i_txn_id)
    WHERE
    w1.wip_entity_id        =       i_wip_entity_id         AND
    w1.organization_id      =       i_org_id;



    l_stmt_num := 200;

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
    w1.basis_type           =       w2.basis_type           AND /* Added for bug 5247584 */
    w2.operation_seq_num    =       cocd.operation_seq_num  AND
    cocd.new_operation_flag =       2                       AND
    cocd.transaction_id     =       i_txn_id)
    WHERE
    w1.wip_entity_id        =       i_wip_entity_id         AND
    w1.organization_id      =       i_org_id;



    /************************************************************
    * Insert into mtl_cst_txn_cost_details now that the         *
    * Costs have been computed ...                              *
    * 3 statements are required --> one each for PL costs       *
    * , TL Res/OSP costs and TL ovhd costs.                     *
    * Remember - the cst_txn_cost_detail tables stores unit     *
    * cost - but the wip tables store the value in the          *
    * temp_relieved_value column - so we have to divide by the  *
    * txn_qty to arrive at the unit cost.                       *
    ************************************************************/


    l_stmt_num := 210;

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
      PROGRAM_UPDATE_DATE
    )
    SELECT
      i_txn_id,
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
    GROUP BY
      wrocd.cost_element_id
    HAVING
      sum(nvl(wrocd.temp_relieved_value,0))  <> 0;


    l_stmt_num := 220;

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
      PROGRAM_UPDATE_DATE
    )
    SELECT
      i_txn_id,
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
    GROUP BY
      BR.COST_ELEMENT_ID
    HAVING
      sum(nvl(wor.temp_relieved_value,0))  <> 0;

    l_stmt_num := 230;

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
      PROGRAM_UPDATE_DATE
    )
    SELECT
      i_txn_id,
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


    --------------------------------------------------------------
    -- END Dual maintenance section with CSTPACCB.pls
    --------------------------------------------------------------


  END IF;  -- main IF


EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCAC.assembly_completion():' ||
           to_char(l_stmt_num) || ':' ||
           substr(SQLERRM,1,150);

END assembly_completion;







PROCEDURE assembly_return (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS

  l_stmt_num          NUMBER := 0;

  l_sql_stmt          VARCHAR2(8000);
  l_layer_cursor      CSTPLMWI.REF_CURSOR_TYPE;
  l_layer             cst_wip_layers%ROWTYPE;

  l_txn_qty_remaining NUMBER;
  l_consumed_qty      NUMBER;

  /* Bug 2186966 */
  l_exp_item          NUMBER;

  l_lot_size          NUMBER := 1; /* Added as part of LBM */
  l_include_comp_yield NUMBER;

  /* Changed as a part of LBM project Bug #3926918
     Added decode to WRO.qpa to get proportioned qpa in
     case of Lot Based Materials
     Divide the value of quantity per assembly by component
     yield factor if Include Component Yield Flag is checked
     in WIP Parameters.*/

 /* Begin Bug 4246122 */
   l_use_val_cost_type   NUMBER;
   l_wip_entity_type     NUMBER;
   l_comp_cost_source    NUMBER;
   l_c_cost_type_id      NUMBER;
   l_prior_completed_qty NUMBER;
   l_wro_count           NUMBER;
  /* End Bug 4246122 */

  cursor wro_cursor is
    select WRO.operation_seq_num,
           WRO.inventory_item_id,
           Decode(WRO.basis_type, 2, WRO.quantity_per_assembly/l_lot_size,
                                     WRO.quantity_per_assembly)/
                        DECODE(l_include_comp_yield,
                               1, nvl(WRO.component_yield_factor,1),
                               1) quantity_per_assembly,
           WRO.relieved_matl_completion_qty,
           decode( nvl( CCS.prior_completion_quantity, 0 ), 0, 1,
             i_txn_qty / CCS.prior_completion_quantity ) component_ratio
    from   wip_requirement_operations WRO,
           cst_comp_snapshot          CCS
    where  WRO.wip_entity_id         =      i_wip_entity_id       and
           WRO.wip_supply_type       not in (4,5,6)               and
           WRO.quantity_per_assembly <>     0                     and
           CCS.transaction_id        =      i_txn_id              and
           CCS.wip_entity_id         =      WRO.wip_entity_id     and
           CCS.operation_seq_num     =      WRO.operation_seq_num and
           CCS.new_operation_flag    =      2
	   /* Begin Bug 4246122*/
    UNION ALL
     select   WRO.operation_seq_num,
              WRO.inventory_item_id,
              WRO.quantity_per_assembly,
              WRO.relieved_matl_completion_qty,
              decode( nvl( WRO.relieved_matl_completion_qty, 0 ), 0, 1,
                i_txn_qty /l_prior_completed_qty  ) component_ratio
       from   wip_requirement_operations WRO
       where  WRO.wip_entity_id         =      i_wip_entity_id       and
              WRO.wip_supply_type       not in (4,5,6)               and
              WRO.quantity_per_assembly <>     0                     and
         NOT EXISTS ( select 'Exists'
                       from wip_operations wo
                        where wo.wip_entity_id = i_wip_entity_id  and
                              wo.organization_id = i_org_id) ;
     /* End Bug 4246122 */

BEGIN

  -- normally i_txn_qty < 0 for assembly return
  ----------------------------------------------------
  -- Update temp_relieved_value to zero in all tables
  ----------------------------------------------------

  l_stmt_num := 10;

  CSTPLMWI.reset_temp_columns
  (
    i_wip_entity_id,
    o_err_num,
    o_err_msg
  );
  IF o_err_num <> 0 THEN
    RETURN;
  END IF;

/* Begin Addition for Bug 4246122 */

   l_stmt_num := 15;
   select we.entity_type
   into   l_wip_entity_type
   from   wip_entities we
   where  we.wip_entity_id = i_wip_entity_id and
          we.entity_type in (1,3,4);  /* excludes Repetitive */


   IF l_wip_entity_type in (1,3) /* Discrete */ THEN

     l_stmt_num := 20;
     select
       wac.completion_cost_source,
       nvl( wac.cost_type_id, -1 )
     into
       l_comp_cost_source,
       l_c_cost_type_id
     from
       wip_accounting_classes wac,
       wip_discrete_jobs wdj
     where
       wdj.wip_entity_id   = i_wip_entity_id         and
       wdj.organization_id = i_org_id                and
       wdj.class_code      = wac.class_code          and
       wdj.organization_id = wac.organization_id;

   ELSIF l_wip_entity_type = 4 /* Flow */ THEN

     l_stmt_num := 23;
     select
       wac.completion_cost_source,
       nvl( wac.cost_type_id, -1 )
     into
       l_comp_cost_source,
       l_c_cost_type_id
     from
       wip_accounting_classes wac,
       wip_flow_schedules wfs
     where
       wfs.wip_entity_id   = i_wip_entity_id         and
       wfs.organization_id = i_org_id                and
       wfs.class_code      = wac.class_code          and
       wfs.organization_id = wac.organization_id;

   END IF;

   /*-----------------------------------------------------
   -- If a non-std job has no bill or routing associated
   -- with it or if a std job has no bill or routing
   -- associated with it - these need to be treated
   -- specially.
   ----------------------------------------------------- */

   IF l_wip_entity_type in (1,3) /* Discrete */ THEN

     l_stmt_num := 25;
     SELECT
       decode( job_type,
         1, decode( bom_revision,
                    NULL, decode(routing_revision,NULL,-1,1),
                    1 ),
         3, decode( bom_reference_id,
                    NULL, decode(routing_reference_id,NULL,-1,1),
                    1 ),
         1 )
     into
       l_use_val_cost_type
     from
       WIP_DISCRETE_JOBS
     WHERE
       WIP_ENTITY_ID   = i_wip_entity_id AND
       ORGANIZATION_ID = i_org_id;

   ELSIF l_wip_entity_type = 4 /* Flow */ THEN

     l_stmt_num := 30;
     SELECT
         decode( bom_revision,
                 NULL, decode(routing_revision,NULL,-1,1),
                 1 )
     into
       l_use_val_cost_type
     from
       wip_flow_schedules wfs
     WHERE
       wfs.WIP_ENTITY_ID   = i_wip_entity_id AND
       wfs.ORGANIZATION_ID = i_org_id;

   END IF;

   /* Material Requirements can be added manually for a job */
   if (l_use_val_cost_type = -1) then
/* Commented for Bug6734270.If there is a resource
   added manually then also the l_use_val_cost_type
   should be 1
      select count(*)
      into l_wro_count
      from wip_requirement_operations
      where wip_entity_id = i_wip_entity_id
      and organization_id = i_org_id
      and quantity_per_assembly <>0;
*/
            SELECT COUNT(1)
            INTO   l_wro_count
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

      if (l_wro_count > 0) then
         l_use_val_cost_type := 1;
      end if;
   end if;

    IF ( l_comp_cost_source = 1 and l_use_val_cost_type = -1) THEN
             l_stmt_num :=35;
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
             PROGRAM_UPDATE_DATE
           )
           SELECT
             i_txn_id,
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
           WHERE LAYER_ID = i_layer_id
            AND NOT ( COST_ELEMENT_ID = 2 AND
                      LEVEL_TYPE      = 1 );

     ELSE
             l_prior_completed_qty :=i_txn_qty;
             l_stmt_num :=40;
             select decode( nvl(sum(mmt.primary_quantity),0),0,i_txn_qty,sum(mmt.primary_quantity))
              into l_prior_completed_qty
             from mtl_material_transactions mmt
              where mmt.transaction_source_type_id=5
                and mmt.transaction_action_id in (31,32)
                and mmt.transaction_source_id = i_wip_entity_id
                and mmt.organization_id = i_org_id
                and mmt.costed_flag is NULL;
     /*End of Addition for Bug 4246122 */

  /*---------------------------------------------
       Get the lot size of the job
   (Form validation takes care lot size is not 0)
       Added for Lot Based Materials project
  ----------------------------------------------*/

  SELECT  wdj.start_quantity
  INTO    l_lot_size
  FROM    wip_discrete_jobs wdj
  WHERE   wdj.wip_entity_id     =   i_wip_entity_id
  AND     wdj.organization_id   =   i_org_id;

  /*----------------------------------------------
  Get the value of Include Component yield flag,
  which will determine whether to include or not
  component yield factor in quantity per assembly
  ------------------------------------------------*/
  SELECT  nvl(include_component_yield, 1)
  INTO    l_include_comp_yield
  FROM    wip_parameters
  WHERE   organization_id = i_org_id;

  ---------------------------------------------
  -- Replenish component material quantities
  ---------------------------------------------

  FOR wro_rec IN wro_cursor LOOP

   /* Get the expense flag for the item */
   --------------------------------------------------------
   -- Get whether the Component is Asset/Expense
   --------------------------------------------------------

     SELECT decode(INVENTORY_ASSET_FLAG,'Y',0,1)
     INTO   l_exp_item
     FROM   MTL_SYSTEM_ITEMS
     WHERE  INVENTORY_ITEM_ID = wro_rec.inventory_item_id
     AND    ORGANIZATION_ID   = i_org_id;


   /* If item is not an expense item, create-consume layers */
  IF ( l_exp_item <> 1 ) THEN

    CSTPLMWI.init_wip_layers
    (
      i_wip_entity_id,
      wro_rec.operation_seq_num,
      wro_rec.inventory_item_id,
      i_org_id,
      i_txn_id,
      i_layer_id,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      o_err_num,
      o_err_msg
    );
    IF o_err_num <> 0 THEN
      RETURN;
    END IF;


    -- assembly completions consume WIP layer(s) in reverse order
    l_stmt_num := 50;
    l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                  (
                    ' sign( CWL.relieved_matl_comp_qty ) = ' ||
                    ' sign( :quantity_per_assembly )       ',
                    i_cost_method_id,
                    CSTPLMWI.REVERSE
                  );

    l_stmt_num := 60;
    open  l_layer_cursor
    for   l_sql_stmt
    using i_wip_entity_id,
          wro_rec.operation_seq_num,
          wro_rec.inventory_item_id,
          wro_rec.quantity_per_assembly;


    -- reduce the relieved_matl_completion_qty
    -- by percentage using cst_comp_snapshot
    l_txn_qty_remaining := nvl(wro_rec.relieved_matl_completion_qty, 0) *
                           nvl(wro_rec.component_ratio, 0);

    LOOP
      exit when l_txn_qty_remaining = 0;

      l_stmt_num := 70;
      fetch l_layer_cursor into l_layer;

      l_stmt_num := 80;
      IF l_layer_cursor%NOTFOUND THEN
        l_layer := CSTPLMWI.get_last_layer
                   (
                     i_wip_entity_id,
                     wro_rec.operation_seq_num,
                     wro_rec.inventory_item_id,
                     o_err_num,
                     o_err_msg
                   );
        l_consumed_qty := l_txn_qty_remaining;

      ELSE
        l_consumed_qty := sign( wro_rec.quantity_per_assembly ) *
                          greatest( sign( wro_rec.quantity_per_assembly ) *
                                      -( l_layer.relieved_matl_comp_qty ),
                                    sign( wro_rec.quantity_per_assembly ) *
                                      l_txn_qty_remaining );
      END IF;

      l_stmt_num := 90;
      update cst_wip_layers CWL
      set
        relieved_matl_comp_qty = relieved_matl_comp_qty + l_consumed_qty,
        temp_relieved_qty      = temp_relieved_qty      + l_consumed_qty
      where
        wip_layer_id = l_layer.wip_layer_id and
        inv_layer_id = l_layer.inv_layer_id;

      l_txn_qty_remaining := l_txn_qty_remaining - l_consumed_qty;

    END LOOP; -- l_layer_cursor

    l_stmt_num := 100;
    close l_layer_cursor;

 -- Don't close wro_cursor here - Bug 2186966
 -- END LOOP; -- wro_cursor





  -- update WROCD
  l_stmt_num := 110;
  update wip_req_operation_cost_details WROCD
  set
  (
    WROCD.relieved_matl_completion_value,
    WROCD.temp_relieved_value
  )
  =
  (
    select
      NVL( WROCD.relieved_matl_completion_value, 0 ) +
        sum( CWL.temp_relieved_qty * CWLCD.layer_cost ),
      sum( CWL.temp_relieved_qty * CWLCD.layer_cost )
    from
      cst_wip_layers CWL,
      cst_wip_layer_cost_details CWLCD
    where
      CWL.wip_entity_id     =  WROCD.wip_entity_id     and
      CWL.operation_seq_num =  WROCD.operation_seq_num and
      CWL.inventory_item_id =  WROCD.inventory_item_id and
      CWL.temp_relieved_qty <> 0                       and
      CWLCD.wip_layer_id    =  CWL.wip_layer_id        and
      CWLCD.inv_layer_id    =  CWL.inv_layer_id        and
      CWLCD.cost_element_id =  WROCD.cost_element_id   and
      CWLCD.level_type in (1, 2)
  )
  where
    (
      WROCD.wip_entity_id,
      WROCD.operation_seq_num,
      WROCD.inventory_item_id
    )
    IN
    (
      select wip_entity_id,
             operation_seq_num,
             inventory_item_id
      from   wip_requirement_operations WRO
      where
        WRO.wip_entity_id         =      i_wip_entity_id and
        /* Restrict only to the current Item  */
        WRO.operation_seq_num  = wro_rec.operation_seq_num and
        WRO.inventory_item_id  = wro_rec.inventory_item_id and
        --
        -- exclude bulk, supplier, phantom
        --
        WRO.wip_supply_type       not in (4,5,6)         and
        WRO.quantity_per_assembly <>     0
    );



  -- update WRO
  update wip_requirement_operations WRO
  set relieved_matl_completion_qty
  =
  (
    select
      NVL( WRO.relieved_matl_completion_qty, 0 ) +
        sum( CWL.temp_relieved_qty )
    from
      cst_wip_layers CWL
    where
      CWL.wip_entity_id     =  WRO.wip_entity_id     and
      CWL.operation_seq_num =  WRO.operation_seq_num and
      CWL.inventory_item_id =  WRO.inventory_item_id and
      CWL.temp_relieved_qty <> 0
  )
  where
    WRO.wip_entity_id         =      i_wip_entity_id and
    /* Only for Current Item */
    WRO.operation_seq_num  = wro_rec.operation_seq_num and
    WRO.inventory_item_id  = wro_rec.inventory_item_id and
    --
    -- exclude bulk, supplier, phantom
    --
    WRO.wip_supply_type       not in (4,5,6)         and
    WRO.quantity_per_assembly <>     0;

    ELSE
    -- If Item is an Expense Item
    -- Just Insert into WROCD if not already there and
    -- update relieved_matl_completion_qty

      INSERT INTO WIP_REQ_OPERATION_COST_DETAILS
     (
     WIP_ENTITY_ID,
     OPERATION_SEQ_NUM,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     COST_ELEMENT_ID,
     APPLIED_MATL_VALUE,
     RELIEVED_MATL_COMPLETION_VALUE,
     RELIEVED_MATL_SCRAP_VALUE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE
    )
    SELECT
     i_wip_entity_id,       -- WIP_ENTITY_ID,
     wro_rec.operation_seq_num,          -- OPERATION_SEQ_NUM,
     i_org_id,              -- ORGANIZATION_ID,
     wro_rec.inventory_item_id,         -- INVENTORY_ITEM_ID,
     CCE.cost_element_id,   -- COST_ELEMENT_ID,
     0,                     -- APPLIED_MATL_VALUE,
     0,                     -- RELIEVED_MATL_COMPLETION_VALUE,
     0,                     -- RELIEVED_MATL_SCRAP_VALUE,
     i_user_id,             -- LAST_UPDATED_BY,
     sysdate,               -- LAST_UPDATE_DATE,
     sysdate,               -- CREATION_DATE,
     i_user_id,             -- CREATED_BY,
     i_login_id,            -- LAST_UPDATE_LOGIN,
     i_request_id,          -- REQUEST_ID,
     i_prog_appl_id,        -- PROGRAM_APPLICATION_ID,
     i_prog_id,             -- PROGRAM_ID,
     sysdate                -- PROGRAM_UPDATE_DATE
   from
    cst_cost_elements CCE
   where
    NOT EXISTS
    (
      SELECT 'X'
      FROM   WIP_REQ_OPERATION_COST_DETAILS WROCD2
      WHERE
        WROCD2.WIP_ENTITY_ID     = i_wip_entity_id       AND
        WROCD2.OPERATION_SEQ_NUM = wro_rec.operation_seq_num          AND
        WROCD2.INVENTORY_ITEM_ID = wro_rec.inventory_item_id          AND
        WROCD2.COST_ELEMENT_ID   = CCE.cost_element_id
    ) AND
    EXISTS
    (
      select 'x'
      from   wip_requirement_operations WRO
      where  WRO.wip_entity_id     = i_wip_entity_id  and
             WRO.operation_seq_num = wro_rec.operation_seq_num     and
             WRO.inventory_item_id = wro_rec.inventory_item_id     and
             WRO.wip_supply_type not in (4, 5, 6)
    )
   group by
    CCE.cost_element_id;

   /* Changed for LBM project. Added decode to qpa for Lot Based Materials */

   UPDATE wip_requirement_operations w1
   SET
   relieved_matl_completion_qty =
   (SELECT
     nvl(w1.relieved_matl_completion_qty,0) +
     i_txn_qty*(DECODE(w2.basis_type, 2, w2.quantity_per_assembly/l_lot_size,
                                     w2.quantity_per_assembly)/
                       DECODE(l_include_comp_yield,
                              1, nvl(w2.component_yield_factor,1),
                              1))
    FROM
     wip_requirement_operations w2
    WHERE
     w1.wip_entity_id       =       w2.wip_entity_id        AND
     w1.organization_id     =       w2.organization_id      AND
     w1.inventory_item_id   =       w2.inventory_item_id    AND
     w1.operation_seq_num   =       w2.operation_seq_num )
    WHERE
     --
     -- Exclude bulk, supplier, phantom
     --
     w1.wip_supply_type     not in  (4,5,6)			AND
     w1.wip_entity_id       =       i_wip_entity_id         AND
     w1.organization_id     =       i_org_id                AND
     w1.inventory_item_id   =       wro_rec.inventory_item_id   AND
     w1.operation_seq_num   =       wro_rec.operation_seq_num   AND
     w1.quantity_per_assembly  <>   0;


    END IF; -- End IF Not Expense Item


  END LOOP; -- wro_cursor



  --------------------------------------------------------------
  -- BEGIN Dual maintenance section with CSTPACCB.pls
  --------------------------------------------------------------

  l_stmt_num := 120;

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
     bom_resources BR,
     cst_comp_snapshot cocd
  WHERE
     w2.wip_entity_id     =       w1.wip_entity_id        AND
     w2.organization_id   =       w1.organization_id      AND
     w2.operation_seq_num =       w1.operation_seq_num    AND
     w2.resource_seq_num  =       w1.resource_seq_num     AND
     w2.basis_type        =       w1.basis_type           AND /* Added for bug 5247584 */
     BR.resource_id       =       w2.resource_id          AND
     w2.wip_entity_id     =       cocd.wip_entity_id      AND
     w2.operation_seq_num =       cocd.operation_seq_num  AND
     cocd.new_operation_flag =    2                       AND
     cocd.transaction_id  =       i_txn_id)
  WHERE
     w1.wip_entity_id     =       i_wip_entity_id         AND
     w1.organization_id   =       i_org_id;




  l_stmt_num := 130;

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
    w2.basis_type           =       w1.basis_type           AND /* Added for bug 5247584 */
    w2.wip_entity_id        =       cocd.wip_entity_id      AND
    w2.operation_seq_num    =       cocd.operation_seq_num  AND
    cocd.new_operation_flag =       2                       AND
    cocd.transaction_id     =       i_txn_id)
  WHERE
    w1.wip_entity_id        =       i_wip_entity_id         AND
    w1.organization_id      =       i_org_id;




  l_stmt_num := 140;

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
    PROGRAM_UPDATE_DATE
  )
  SELECT
    i_txn_id,
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
  GROUP BY
    wrocd.cost_element_id
  HAVING
    sum(nvl(wrocd.temp_relieved_value,0))  <> 0;

  l_stmt_num := 150;

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
    PROGRAM_UPDATE_DATE
  )
  SELECT
    i_txn_id,
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
  GROUP BY
    BR.COST_ELEMENT_ID
  HAVING
    sum(nvl(wor.temp_relieved_value,0))  <> 0;

  l_stmt_num := 160;

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
    PROGRAM_UPDATE_DATE
  )
  SELECT
    i_txn_id,
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

  --------------------------------------------------------------
  -- BEGIN Dual maintenance section with CSTPACCB.pls
  --------------------------------------------------------------

END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCAC.assembly_return():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END assembly_return;







END CSTPLCAC;

/
