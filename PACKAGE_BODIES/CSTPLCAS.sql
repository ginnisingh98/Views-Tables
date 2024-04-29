--------------------------------------------------------
--  DDL for Package Body CSTPLCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLCAS" AS
/* $Header: CSTLCASB.pls 120.1.12010000.2 2010/02/01 13:55:50 svelumur ship $ */



PROCEDURE scrap (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
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
  l_lot_size          NUMBER := 1;
  l_include_comp_yield NUMBER;

  /* Changed as a part of LBM project Bug #3926918
     Removed select * and added required columns and
     added decode to qpa to get proportioned qpa for
     Lot Based Materials.
     Divide the value of quantity per assembly by component
     yield factor if Include Component Yield Flag is checked
     in WIP Parameters.*/

  cursor wro_cursor( i_wip_entity_id NUMBER, i_op_seq_num NUMBER ) is
    select operation_seq_num,
           inventory_item_id,
           Decode(basis_type, 2, quantity_per_assembly/l_lot_size,
                                 quantity_per_assembly)/
                  DECODE(l_include_comp_yield,
                         1, nvl(component_yield_factor,1),
                         1) quantity_per_assembly
    from   wip_requirement_operations WRO
    where  WRO.wip_entity_id         =      i_wip_entity_id and
           WRO.operation_seq_num     <=     i_op_seq_num    and
           WRO.wip_supply_type       not in (4,5,6)         and
           WRO.quantity_per_assembly <>     0;

BEGIN

  /* normally i_txn_qty > 0 for scrap */

  /*----------------------------------------------------
     Update temp_relieved_value to zero in all tables
  ----------------------------------------------------*/

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
  L_STMT_NUM := 20;
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

  /*--------------------------------------------
       Consume material component quantities
  --------------------------------------------*/

  l_stmt_num := 60;
  FOR wro_rec IN wro_cursor( i_wip_entity_id, i_op_seq_num ) LOOP

    l_stmt_num := 70;
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



    /* consume WIP layer(s)
       scraps consume WIP in normal order */
    l_stmt_num := 80;
    l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                  (
                    ' sign( CWL.applied_matl_qty -                ' ||
                    '       CWL.relieved_matl_comp_qty -          ' ||
                    '       CWL.relieved_matl_scrap_qty -         ' ||
                    '       CWL.relieved_matl_final_comp_qty ) =  ' ||
                    ' sign( :quantity_per_assembly )              ',
                    i_cost_method_id,
                    CSTPLMWI.NORMAL
                  );

    l_stmt_num := 90;
    open  l_layer_cursor
    for   l_sql_stmt
    using i_wip_entity_id,
          wro_rec.operation_seq_num,
          wro_rec.inventory_item_id,
          wro_rec.quantity_per_assembly;

    l_txn_qty_remaining := i_txn_qty * wro_rec.quantity_per_assembly;

    LOOP
      exit when l_txn_qty_remaining = 0;

      l_stmt_num := 100;
      fetch l_layer_cursor into l_layer;

      l_stmt_num := 110;
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

      l_stmt_num := 120;
      update cst_wip_layers CWL
      set
        relieved_matl_scrap_qty = relieved_matl_scrap_qty + l_consumed_qty,
        temp_relieved_qty       = temp_relieved_qty       + l_consumed_qty
      where
        wip_layer_id = l_layer.wip_layer_id and
        inv_layer_id = l_layer.inv_layer_id;

      l_txn_qty_remaining := l_txn_qty_remaining - l_consumed_qty;

    END LOOP; /* l_layer_cursor */

    l_stmt_num := 130;
    close l_layer_cursor;

  END LOOP; /* wro_cursor */



  /* update WROCD */
  l_stmt_num := 140;
  update wip_req_operation_cost_details WROCD
  set
  (
    WROCD.relieved_matl_scrap_value,
    WROCD.temp_relieved_value
  )
  =
  (
    select
      NVL( WROCD.relieved_matl_scrap_value, 0 ) +
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
        WRO.operation_seq_num     <=     i_op_seq_num    and

        /* exclude bulk, supplier, phantom */

        WRO.wip_supply_type       not in (4,5,6)         and
        WRO.quantity_per_assembly <>     0
    );



  /* update WRO */
  update wip_requirement_operations WRO
  set relieved_matl_scrap_quantity
  =
  (
    select
      NVL( WRO.relieved_matl_scrap_quantity, 0 ) +
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
    WRO.operation_seq_num     <=     i_op_seq_num    and

    /* exclude bulk, supplier, phantom */

    WRO.wip_supply_type       not in (4,5,6)         and
    WRO.quantity_per_assembly <>     0;



  /*--------------------------------------------------------------
     BEGIN Dual maintenance section with CSTPACSB.pls
  --------------------------------------------------------------*/

  /* insert into wip_scrap_values for WROCD */

  l_stmt_num := 150;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,        */
    2,                     /* level_type,            */
    WROCD.cost_element_id, /* cost_element_id,       */
    sum( NVL( WROCD.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,    */
    NULL,                  /* cost_update_id,        */
    sysdate,               /* last_update_date,      */
    i_user_id,             /* last_updated_by,       */
    i_user_id,             /* created_by,            */
    sysdate,               /* creation_date,         */
    i_login_id,            /* last_update_login,     */
    i_request_id,          /* request_id,            */
    i_prog_appl_id,        /* program_application_id,*/
    i_prog_id,             /* program_id,            */
    sysdate                /* program_update_date    */
  FROM
    wip_req_operation_cost_details WROCD
  where
    wrocd.WIP_ENTITY_ID    =       i_wip_entity_id
  GROUP BY
    wrocd.COST_ELEMENT_ID
  HAVING
    sum( NVL( WROCD.temp_relieved_value, 0 ) ) <> 0;




  l_stmt_num := 160;

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
  /*
   new to solve divided by zero and over relieved
   when txn_qty/completed - prior_completion - prior_scrap
   is greater than or equal to one, set it to one
   ie. flush out 1*value remain in the job  same as completion 8/28/98
  */
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

  /* new to solve divided by zero and over relieved */

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

  /* new to solve divided by zero and over relieved */

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
  COCD.NEW_OPERATION_FLAG =       2                       AND
  COCD.TRANSACTION_ID     =       I_TXN_ID)
  WHERE
  W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
  W1.ORGANIZATION_ID      =       I_ORG_ID                AND
/*  w1.USAGE_RATE_OR_AMOUNT <>      0                       AND  Bug 9338256*/
  w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;


  l_stmt_num := 170;

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

  /* new to solve divided by zero and over relieved */

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

  /* new to solve divided by zero and over relieved */

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

  /* new to solve divided by zero and over relieved */

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
    w1.organization_id      =       w2.organization_id      AND
    w1.basis_type	    =	    w2.basis_type	    AND
    w2.operation_seq_num    =       cocd.operation_seq_num  AND
    cocd.new_operation_flag =       2                       AND
    cocd.transaction_id     =       i_txn_id)
  WHERE
    w1.wip_entity_id        =       i_wip_entity_id         AND
    w1.organization_id      =       i_org_id                AND
    w1.operation_seq_num    <=      i_op_seq_num;




  l_stmt_num := 180;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,         */
    1,                     /* level_type,             */
    BR.cost_element_id,    /* cost_element_id,        */
    sum( NVL( WOR.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,     */
    NULL,                  /* cost_update_id,         */
    sysdate,               /* last_update_date,       */
    i_user_id,             /* last_updated_by,        */
    i_user_id,             /* created_by,             */
    sysdate,               /* creation_date,          */
    i_login_id,            /* last_update_login,      */
    i_request_id,          /* request_id,             */
    i_prog_appl_id,        /* program_application_id, */
    i_prog_id,             /* program_id,             */
    sysdate                /* program_update_date     */
  FROM
    wip_operation_resources WOR,
    bom_resources BR
  WHERE
    WOR.wip_entity_id       =       i_wip_entity_id         AND
    WOR.organization_id     =       i_org_id                AND
    BR.resource_id          =       WOR.resource_id         AND
    BR.organization_id      =       WOR.organization_id
  group by
    BR.cost_element_id
  HAVING
    SUM(nvl(temp_relieved_value,0)) <>      0;


  l_stmt_num := 190;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,         */
    1,                     /* level_type,             */
    5,                     /* cost_element_id,        */
    sum( NVL( WOO.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,     */
    NULL,                  /* cost_update_id,         */
    sysdate,               /* last_update_date,       */
    i_user_id,             /* last_updated_by,        */
    i_user_id,             /* created_by,             */
    sysdate,               /* creation_date,          */
    i_login_id,            /* last_update_login,      */
    i_request_id,          /* request_id,             */
    i_prog_appl_id,        /* program_application_id, */
    i_prog_id,             /* program_id,             */
    sysdate                /* program_update_date     */
  FROM
    wip_operation_overheads WOO
  WHERE
    WOO.wip_entity_id           =       i_wip_entity_id         AND
    WOO.organization_id         =       i_org_id
  HAVING
    SUM(nvl(temp_relieved_value,0)) <>      0;



  /******************************************************
  * Insert rows into mtl_cst_txn_cost_details           *
  ******************************************************/

  l_stmt_num := 200;

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
    cost_element_id,
    level_type,
    cost_element_value,
    NULL,
    NULL,
    NULL,
    sysdate,        /* LAST_UPDATE_DATE,      */
    i_user_id,      /* LAST_UPDATED_BY,       */
    sysdate,        /* CREATION_DATE,         */
    i_user_id,      /* CREATED_BY,            */
    i_login_id,     /* LAST_UPDATE_LOGIN,     */
    i_request_id,   /* REQUEST_ID,            */
    i_prog_appl_id, /* PROGRAM_APPLICATION_ID,*/
    i_prog_id,      /* PROGRAM_ID,            */
    sysdate         /* PROGRAM_UPDATE_DATE    */
  FROM
    wip_scrap_values WSV
  WHERE
    WSV.transaction_id  =       i_txn_id        AND
    WSV.cost_update_id IS NULL;


  /*------------------------------------------------------------
     END Dual maintenance section with CSTPACSB.pls
  ------------------------------------------------------------*/


EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCAS.scrap():' ||
                 to_char(l_stmt_num) || ':' ||
                 substrb(SQLERRM,1,150);

END scrap;







PROCEDURE scrap_return (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
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
  l_lot_size          NUMBER := 1; /* Added as part of LBM */
  l_include_comp_yield  NUMBER;

  /* Changed as a part of LBM project Bug #3926918
     Added decode to WRO.qpa to get proportioned qpa in
     case of Lot Based Materials
     Divide the value of quantity per assembly by component
     yield factor if Include Component Yield Flag is checked
     in WIP Parameters. */

  cursor wro_cursor is
    select WRO.operation_seq_num,
           WRO.inventory_item_id,
           Decode(WRO.basis_type, 2, WRO.quantity_per_assembly/l_lot_size,
                                     WRO.quantity_per_assembly)/
                  DECODE(l_include_comp_yield,
                         1, nvl(WRO.component_yield_factor,1),
                         1) quantity_per_assembly,
           WRO.relieved_matl_scrap_quantity,
           decode( nvl( CCS.prior_scrap_quantity, 0 ), 0, 1,
             i_txn_qty / CCS.prior_scrap_quantity ) component_ratio
    from   wip_requirement_operations WRO,
           cst_comp_snapshot          CCS
    where  WRO.wip_entity_id         =      i_wip_entity_id       and
           WRO.operation_seq_num     <=     i_op_seq_num          and
           WRO.wip_supply_type       not in (4,5,6)               and
           WRO.quantity_per_assembly <>     0                     and
           CCS.transaction_id        =      i_txn_id              and
           CCS.wip_entity_id         =      WRO.wip_entity_id     and
           CCS.operation_seq_num     =      WRO.operation_seq_num and
           CCS.new_operation_flag    =      2;

BEGIN

  /* normally i_txn_qty < 0 for scrap return */

  /*--------------------------------------------------
     Update temp_relieved_value to zero in all tables
  --------------------------------------------------*/

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

  /*-------------------------------------------
     Replenish component material quantities
  -------------------------------------------*/

  l_stmt_num := 60;
  FOR wro_rec IN wro_cursor LOOP

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



    /* replenish WIP layer(s)
       scrap return replenishes WIP in reverse order */
    l_stmt_num := 70;
    l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                  (
                    ' sign( CWL.relieved_matl_scrap_qty ) = ' ||
                    ' sign( :quantity_per_assembly )        ',
                    i_cost_method_id,
                    CSTPLMWI.REVERSE
                  );

    l_stmt_num := 80;
    open  l_layer_cursor
    for   l_sql_stmt
    using i_wip_entity_id,
          wro_rec.operation_seq_num,
          wro_rec.inventory_item_id,
          wro_rec.quantity_per_assembly;


    /* reduce the relieved_matl_scrap_quantity
       by percentage using cst_comp_snapshot */
    l_txn_qty_remaining := nvl(wro_rec.relieved_matl_scrap_quantity, 0) *
                           nvl(wro_rec.component_ratio, 0);


    LOOP
      exit when l_txn_qty_remaining = 0;

      l_stmt_num := 90;
      fetch l_layer_cursor into l_layer;

      l_stmt_num := 100;
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
			    greatest( sign( wro_rec.quantity_per_assembly ) *
					-( l_layer.relieved_matl_scrap_qty ),
				      sign( wro_rec.quantity_per_assembly ) *
					l_txn_qty_remaining );
      END IF;


      l_stmt_num := 110;
      update cst_wip_layers CWL
      set
	relieved_matl_scrap_qty = relieved_matl_scrap_qty + l_consumed_qty,
	temp_relieved_qty       = temp_relieved_qty       + l_consumed_qty
      where
	wip_layer_id = l_layer.wip_layer_id and
	inv_layer_id = l_layer.inv_layer_id;

      l_txn_qty_remaining := l_txn_qty_remaining - l_consumed_qty;

    END LOOP; /* l_layer_cursor */

    l_stmt_num := 120;
    close l_layer_cursor;

  END LOOP; /* wro_cursor */




  /* update WROCD */
  l_stmt_num := 130;
  update wip_req_operation_cost_details WROCD
  set
  (
    WROCD.relieved_matl_scrap_value,
    WROCD.temp_relieved_value
  )
  =
  (
    select
      NVL( WROCD.relieved_matl_scrap_value, 0 ) +
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
        WRO.operation_seq_num     <=     i_op_seq_num    and

        /* exclude bulk, supplier, phantom */

        WRO.wip_supply_type       not in (4,5,6)         and
        WRO.quantity_per_assembly <>     0
    );



  /* update WRO */
  update wip_requirement_operations WRO
  set relieved_matl_scrap_quantity
  =
  (
    select
      NVL( WRO.relieved_matl_scrap_quantity, 0 ) +
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
    WRO.operation_seq_num     <=     i_op_seq_num    and

    /* exclude bulk, supplier, phantom */

    WRO.wip_supply_type       not in (4,5,6)         and
    WRO.quantity_per_assembly <>     0;



  /*------------------------------------------------------------
     BEGIN Dual maintenance section with CSTPACSB.pls
  ------------------------------------------------------------*/


  /* insert into wip_scrap_values for WROCD */

  l_stmt_num := 140;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,         */
    2,                     /* level_type,             */
    WROCD.cost_element_id, /* cost_element_id,        */
    sum( NVL( WROCD.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,     */
    NULL,                  /* cost_update_id,         */
    sysdate,               /* last_update_date,       */
    i_user_id,             /* last_updated_by,        */
    i_user_id,             /* created_by,             */
    sysdate,               /* creation_date,          */
    i_login_id,            /* last_update_login,      */
    i_request_id,          /* request_id,             */
    i_prog_appl_id,        /* program_application_id, */
    i_prog_id,             /* program_id,             */
    sysdate                /* program_update_date     */
  FROM
    wip_req_operation_cost_details WROCD
  where
    wrocd.WIP_ENTITY_ID    =       i_wip_entity_id
  GROUP BY
    wrocd.COST_ELEMENT_ID
  HAVING
    sum( NVL( WROCD.temp_relieved_value, 0 ) ) <> 0;



  l_stmt_num := 150;

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
	   i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,
                            PRIOR_SCRAP_QUANTITY)),
    nvl(W2.RELIEVED_RES_scrap_VALUE,0)*
    decode(abs(i_txn_qty),
	   PRIOR_SCRAP_QUANTITY,-1,
	   i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,
                            PRIOR_SCRAP_QUANTITY)),
    nvl(W1.RELIEVED_RES_scrap_VALUE,0)+
    nvl(W2.RELIEVED_RES_scrap_VALUE,0)*
    decode(abs(i_txn_qty),
	   PRIOR_SCRAP_QUANTITY,-1,
	   i_txn_qty/decode(PRIOR_SCRAP_QUANTITY,NULL,1,0,1,
                            PRIOR_SCRAP_QUANTITY))
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
    COCD.TRANSACTION_ID     =       I_TXN_ID)
  WHERE
    W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
    W1.ORGANIZATION_ID      =       I_ORG_ID                AND
    w1.usage_rate_or_amount <>      0                       AND
    w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;


  l_stmt_num := 160;

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
    W2.OVERHEAD_ID          =       W1.OVERHEAD_ID          AND
    W2.BASIS_TYPE	    = 	    W1.BASIS_TYPE	    AND
    W2.WIP_ENTITY_ID        =       COCD.WIP_ENTITY_ID      AND
    W2.OPERATION_SEQ_NUM    =       COCD.OPERATION_SEQ_NUM  AND
    COCD.NEW_OPERATION_FLAG =       2                       AND
    COCD.TRANSACTION_ID     =       I_TXN_ID)
  WHERE
    W1.WIP_ENTITY_ID        =       I_WIP_ENTITY_ID         AND
    W1.ORGANIZATION_ID      =       I_ORG_ID                AND
    w1.OPERATION_SEQ_NUM    <=      i_op_seq_num;




  l_stmt_num := 170;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,         */
    1,                     /* level_type,             */
    BR.cost_element_id,    /* cost_element_id,        */
    sum( NVL( WOR.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,     */
    NULL,                  /* cost_update_id,         */
    sysdate,               /* last_update_date,       */
    i_user_id,             /* last_updated_by,        */
    i_user_id,             /* created_by,             */
    sysdate,               /* creation_date,          */
    i_login_id,            /* last_update_login,      */
    i_request_id,          /* request_id,             */
    i_prog_appl_id,        /* program_application_id, */
    i_prog_id,             /* program_id,             */
    sysdate                /* program_update_date     */
  FROM
    wip_operation_resources WOR,
    bom_resources BR
  WHERE
    WOR.wip_entity_id       =       i_wip_entity_id         AND
    WOR.organization_id     =       i_org_id                AND
    BR.resource_id          =       WOR.resource_id         AND
    BR.organization_id      =       WOR.organization_id
  group by
    BR.cost_element_id
  HAVING
    SUM(nvl(temp_relieved_value,0)) <>      0;


  l_stmt_num := 180;

  INSERT INTO WIP_SCRAP_VALUES
  (
    transaction_id,
    level_type,
    cost_element_id,
    cost_element_value,
    cost_update_id,
    last_update_date,
    last_updated_by,
    created_by,
    creation_date,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
  )
  SELECT
    i_txn_id,              /* transaction_id,         */
    1,                     /* level_type,             */
    5,                     /* cost_element_id,        */
    sum( NVL( WOO.temp_relieved_value, 0 ) ) / i_txn_qty,
                           /* cost_element_value,     */
    NULL,                  /* cost_update_id,         */
    sysdate,               /* last_update_date,       */
    i_user_id,             /* last_updated_by,        */
    i_user_id,             /* created_by,             */
    sysdate,               /* creation_date,          */
    i_login_id,            /* last_update_login,      */
    i_request_id,          /* request_id,             */
    i_prog_appl_id,        /* program_application_id, */
    i_prog_id,             /* program_id,             */
    sysdate                /* program_update_date     */
  FROM
    wip_operation_overheads WOO
  WHERE
    WOO.wip_entity_id           =       i_wip_entity_id         AND
    WOO.organization_id         =       i_org_id
  HAVING
    SUM(nvl(temp_relieved_value,0)) <>      0;



  l_stmt_num := 190;

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
    cost_element_id,
    level_type,
    cost_element_value,
    NULL,
    NULL,
    NULL,
    sysdate,        /* LAST_UPDATE_DATE,       */
    i_user_id,      /* LAST_UPDATED_BY,        */
    sysdate,        /* CREATION_DATE,          */
    i_user_id,      /* CREATED_BY,             */
    i_login_id,     /* LAST_UPDATE_LOGIN,      */
    i_request_id,   /* REQUEST_ID,             */
    i_prog_appl_id, /* PROGRAM_APPLICATION_ID, */
    i_prog_id,      /* PROGRAM_ID,             */
    sysdate         /* PROGRAM_UPDATE_DATE     */
  FROM
    wip_scrap_values WSV
  WHERE
    WSV.transaction_id  =       i_txn_id        AND
    WSV.cost_update_id IS NULL;


  /*------------------------------------------------------------
     END Dual maintenance section with CSTPACSB.pls
  ------------------------------------------------------------*/



EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCAS.scrap_return():' ||
                 to_char(l_stmt_num) || ':' ||
                 substrb(SQLERRM,1,150);

END scrap_return;







END CSTPLCAS;

/
