--------------------------------------------------------
--  DDL for Package Body CSTPLCWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLCWP" AS
/* $Header: CSTLCWPB.pls 120.1 2005/10/13 08:52:39 visrivas noship $ */

PROCEDURE cost_wip_trx (
  l_trx_id                IN      NUMBER,
  l_comm_iss_flag         IN      NUMBER,
  l_cost_type_id          IN      NUMBER,
  l_cost_method           IN      NUMBER,
  l_rates_cost_type_id    IN      NUMBER,
  l_cost_grp_id           IN      NUMBER,
  l_txfr_cost_grp_id      IN      NUMBER,
  l_exp_flag              IN      NUMBER,
  l_exp_item_flag         IN      NUMBER,
  l_flow_schedule         IN      NUMBER,
  l_user_id               IN      NUMBER,
  l_login_id              IN      NUMBER,
  l_request_id            IN      NUMBER,
  l_prog_id               IN      NUMBER,
  l_prog_app_id           IN      NUMBER,
  err_num                 OUT NOCOPY     NUMBER,
  err_code                OUT NOCOPY     VARCHAR2,
  err_msg                 OUT NOCOPY     VARCHAR2
)
is

  l_layer_id              NUMBER;
  l_cost_group_id         NUMBER;
  l_inv_item_id           NUMBER;
  l_org_id                NUMBER;
  l_txn_date              DATE;
  l_period_id             NUMBER;
  l_action_id             NUMBER;
  l_src_type_id           NUMBER;
  l_txn_qty               NUMBER;
  l_wip_entity_id         NUMBER;
  l_op_seq_num            NUMBER;
  l_final_comp_flag       VARCHAR2(1);
  l_movhd_cost_type_id    NUMBER;
  stmt_num                NUMBER;
  l_return                NUMBER;
  l_row_count             NUMBER;
  l_mtl_txn_exists        NUMBER;
  l_entity_type		  NUMBER;
  l_err_num               NUMBER;
  l_err_code              VARCHAR2(240);
  l_err_msg               VARCHAR2(240);
  proc_fail               EXCEPTION;


  l_trx_info              CST_XLA_PVT.t_xla_inv_trx_info;

  l_msg_data		  VARCHAR2(8000);
  l_msg_count		  NUMBER;
  l_return_status	  VARCHAR2(1);
  l_msg_return_status	  VARCHAR2(1);
BEGIN

  --
  -- initialize l_movhd_cost_type_id. Bug 609 -
  l_movhd_cost_type_id := l_rates_cost_type_id;

  err_num:=0;
  l_err_num := 0;

  stmt_num := 110;

  select
    inventory_item_id,
    organization_id,
    transaction_date,
    transaction_action_id,
    transaction_source_type_id,
    primary_quantity,
    transaction_source_id,
    operation_seq_num,
    nvl(final_completion_flag,'N'),
    acct_period_id
  into
    l_inv_item_id,
    l_org_id,
    l_txn_date,
    l_action_id,
    l_src_type_id,
    l_txn_qty,
    l_wip_entity_id,
    l_op_seq_num,
    l_final_comp_flag,
    l_period_id
  from
    mtl_material_transactions
  where
    transaction_id = l_trx_id;






  -- Check to see if the item has a row in cst_quantity_layers.

  -- For a regular transaction the layer_id in MCACD corresponds to
  -- the cost_group_id in MMT. For a CITW txn however, the WIP issue
  -- is being done from the txfr_cost_group in MMT and so we should
  -- fetch the layer_id corresponding to this.

  IF l_comm_iss_flag <> 1 THEN

    l_layer_id := CSTPACLM.layer_id
    (
      l_org_id,
      l_inv_item_id,
      l_cost_grp_id,
      l_err_num,
      l_err_code,
      l_err_msg
    );

  ELSE

    l_layer_id := CSTPACLM.layer_id
    (
      l_org_id,
      l_inv_item_id,
      l_txfr_cost_grp_id,
      l_err_num,
      l_err_code,
      l_err_msg
    );

  END IF;

  IF l_err_num <> 0 THEN
    raise proc_fail;
  END IF;


  -- If row exists proceed, else create row.

  IF l_layer_id = 0 THEN
    l_layer_id:= CSTPACLM.create_layer
    (
      i_org_id        => l_org_id,
      i_item_id       => l_inv_item_id,
      i_cost_group_id => l_cost_grp_id,
      i_user_id       => l_user_id,
      i_request_id    => l_request_id,
      i_prog_id       => l_prog_id,
      i_prog_appl_id  => l_prog_app_id,
      i_txn_id        => l_trx_id,
      o_err_num       => l_err_num,
      o_err_code      => l_err_code,
      o_err_msg       => l_err_msg
    );

    IF (l_err_num<>0) THEN
      raise proc_fail;
    END IF;

  END IF;




  -- Prior to doing any further processing, check for a CFM txn if a row
  -- exists in WPB for that schedule. If no row exists then this fn will
  -- create a row automatically.


  If (l_flow_schedule = 1) THEN

    l_return := CSTPCFMS.wip_cfm_cbr
    (
      i_org_id         => l_org_id,
      i_user_id        => l_user_id,
      i_login_id       => l_user_id,
      i_acct_period_id => l_period_id,
      i_wip_entity_id  => l_wip_entity_id,
      err_buf          => l_err_msg
    );

    If (l_return <> 0) THEN
      raise proc_fail;
    END IF;

  END IF;


  -- Based on transaction_action_id call appropriate function for processing.
  -- Need to also account for the 2 new wip txns.



  IF ( l_action_id = 1 OR l_action_id = 34 ) THEN

    CSTPLCIR.component_issue
    (
      i_cost_method_id => l_cost_method,
      i_txn_id         => l_trx_id,
      i_layer_id       => l_layer_id,
      i_inv_item_id    => l_inv_item_id,
      i_org_id         => l_org_id,
      i_wip_entity_id  => l_wip_entity_id,
      i_txn_qty        => l_txn_qty,
      i_op_seq_num     => l_op_seq_num,
      i_cost_type_id   => l_cost_type_id,
      i_exp_flag       => l_exp_flag,
      i_user_id        => l_user_id,
      i_login_id       => l_login_id,
      i_request_id     => l_request_id,
      i_prog_id        => l_prog_id,
      i_prog_appl_id   => l_prog_app_id,
      o_err_num        => l_err_num,
      o_err_msg        => l_err_msg
    );

  ELSIF ( l_action_id = 27 OR l_action_id = 33 ) THEN

    CSTPLCIR.component_return
    (
      i_cost_method_id => l_cost_method,
      i_txn_id         => l_trx_id,
      i_layer_id       => l_layer_id,
      i_inv_item_id    => l_inv_item_id,
      i_org_id         => l_org_id,
      i_wip_entity_id  => l_wip_entity_id,
      i_txn_qty        => l_txn_qty,
      i_op_seq_num     => l_op_seq_num,
      i_user_id        => l_user_id,
      i_login_id       => l_login_id,
      i_request_id     => l_request_id,
      i_prog_id        => l_prog_id,
      i_prog_appl_id   => l_prog_app_id,
      o_err_num        => l_err_num,
      o_err_msg        => l_err_msg
    );

  ELSIF ( l_action_id = 31 and l_flow_schedule <> 1 ) THEN

    CSTPLCAC.assembly_completion
    (
      i_cost_method_id      => l_cost_method,
      i_txn_id              => l_trx_id,
      i_txn_date            => l_txn_date,
      i_layer_id            => l_layer_id,
      i_inv_item_id         => l_inv_item_id,
      i_org_id              => l_org_id,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_qty             => l_txn_qty,
      i_final_comp_flag     => l_final_comp_flag,
      i_cost_type_id        => l_cost_type_id,
      i_res_cost_type_id    => l_rates_cost_type_id,
      i_cost_group_id       => l_cost_grp_id,
      i_acct_period_id      => l_period_id,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      o_movhd_cost_type_id  => l_movhd_cost_type_id,
      o_err_num             => l_err_num,
      o_err_msg             => l_err_msg
    );

  ELSIF ( l_action_id = 32 and l_flow_schedule <> 1 ) THEN

    -- Note that we're not passing the l_movhd_cost_type_id anymore;
    -- this is because we always return at the WIP component layer
    -- cost, so we'll ignore the user-specified cost type for
    -- assembly returns.

    CSTPLCAC.assembly_return
    (
      i_cost_method_id      => l_cost_method,
      i_txn_id              => l_trx_id,
      i_layer_id            => l_layer_id,
      i_inv_item_id         => l_inv_item_id,
      i_org_id              => l_org_id,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_qty             => l_txn_qty,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      o_err_num             => l_err_num,
      o_err_msg             => l_err_msg
    );

  ELSIF ( l_action_id = 30 and l_txn_qty >= 0 and l_flow_schedule <> 1 ) THEN

    CSTPLCAS.scrap
    (
      i_cost_method_id      => l_cost_method,
      i_txn_id              => l_trx_id,
      i_layer_id            => l_layer_id,
      i_inv_item_id         => l_inv_item_id,
      i_org_id              => l_org_id,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_qty             => l_txn_qty,
      i_op_seq_num          => l_op_seq_num,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      o_err_num             => l_err_num,
      o_err_msg             => l_err_msg
    );

  ELSIF ( l_action_id = 30 and l_txn_qty < 0 and l_flow_schedule <> 1 ) THEN

    CSTPLCAS.scrap_return
    (
      i_cost_method_id      => l_cost_method,
      i_txn_id              => l_trx_id,
      i_layer_id            => l_layer_id,
      i_inv_item_id         => l_inv_item_id,
      i_org_id              => l_org_id,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_qty             => l_txn_qty,
      i_op_seq_num          => l_op_seq_num,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      o_err_num             => l_err_num,
      o_err_msg             => l_err_msg
    );

  ELSIF ( (l_action_id = 31 OR (l_action_id=30 AND l_txn_qty>0) ) AND
          l_flow_schedule = 1 ) THEN

    CSTPCFMS.wip_cfm_complete
    (
      i_trx_id              => l_trx_id,
      i_org_id              => l_org_id,
      i_inv_item_id         => l_inv_item_id,
      i_txn_qty             => l_txn_qty,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_src_type_id     => 5,
      i_flow_schedule       => l_flow_schedule,
      i_txn_action_id       => l_action_id,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      err_num               => l_err_num,
      err_code              => l_err_code,
      err_msg               => l_err_msg
    );

  ELSIF ( (l_action_id = 32 OR (l_action_id=30 AND l_txn_qty<0) ) AND
          l_flow_schedule = 1 ) THEN

    CSTPCFMS.wip_cfm_assy_return
    (
      i_trx_id              => l_trx_id,
      i_org_id              => l_org_id,
      i_inv_item_id         => l_inv_item_id,
      i_txn_qty             => l_txn_qty,
      i_wip_entity_id       => l_wip_entity_id,
      i_txn_src_type_id     => 5,
      i_flow_schedule       => l_flow_schedule,
      i_txn_action_id       => l_action_id,
      i_user_id             => l_user_id,
      i_login_id            => l_login_id,
      i_request_id          => l_request_id,
      i_prog_id             => l_prog_id,
      i_prog_appl_id        => l_prog_app_id,
      err_num               => l_err_num,
      err_code              => l_err_code,
      err_msg               => l_err_msg
    );

  ELSE

    l_err_num  := 1101;
    l_err_code := 'CSTPLCWP: Unsupported MMT transaction type';
    l_err_msg  := 'CSTPLCWP: Unsupported MMT transaction type';

  END IF;


  -- Check if processing is succesful, if not, pass control back to calling
  -- module.

  IF (l_err_num<>0) THEN
    raise proc_fail;
  END IF;




    -- Flush out all WIP layer quantities after CFM completion, return,
    -- or scrap transactions

  IF ( l_flow_schedule = 1 and l_action_id in (30, 31, 32) ) THEN

    stmt_num := 120;
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
      CWL.wip_entity_id = l_wip_entity_id and
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty ) >= 0;

    stmt_num := 130;
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
      CWL.wip_entity_id = l_wip_entity_id and
      ( CWL.applied_matl_qty -
        CWL.relieved_matl_comp_qty -
        CWL.relieved_matl_scrap_qty -
        CWL.relieved_matl_final_comp_qty ) < 0;

  END IF;




  -- All the logic below should be exectued only if the transaction
  -- is not a CITW txn.  If it is then the cost proc and distbn proc
  -- is done within CSTPACIn, the Inv library.

  IF (l_comm_iss_flag <> 1) THEN


    /*----------------------------------------------------
    | The cost processor operates under the assumption that
    | if there are no rows in the transaction cost table,
    | then the transaction occured at the current average
    | cost. For component issue/return transactions we
    | therefore deliberately refrain from inserting a
    | cost row. For completions, assembly returns and
    | scrap transactions however, in the respective
    | packages, we do not insert  row if the cost is zero.
    | To prevent such transactions from being processed at
    | current average cost, we need to insert a dummy
    | TL materil row into the cost table with zero cost.
    |------------------------------------------------------*/



    stmt_num := 140;

    select count(*)
    into   l_mtl_txn_exists
    from   mtl_cst_txn_cost_details
    where  transaction_id = l_trx_id;

    IF( l_mtl_txn_exists=0 AND
        ( l_action_id=30 OR l_action_id=31 OR l_action_id=32 ) ) THEN


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
        PROGRAM_UPDATE_DATE
      )
      VALUES
      (
        l_trx_id,
        l_org_id,
        l_inv_item_id,
        1,
        1,
        0,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_login_id,
        l_request_id,
        l_prog_app_id,
        l_prog_id,
        SYSDATE
      );

    END IF;




    -- For all txns call the cost processor, then the distribution
    -- processor. Note that for scrap there is no avg cost recomputed though.

    -- This calls the new FIFO cost processor

    CSTPLVCP.cost_processor
    (
      i_org_id          => l_org_id,
      i_txn_id          => l_trx_id,
      i_layer_id        => l_layer_id,
      i_cost_type       => l_cost_type_id,
      i_cost_method     => l_cost_method,
      i_mat_ct_id       => l_movhd_cost_type_id,
      i_avg_rates_id    => l_rates_cost_type_id,
      i_item_id         => l_inv_item_id,
      i_txn_qty         => l_txn_qty,
      i_txn_action_id   => l_action_id,
      i_txn_src_type    => 5,
      i_txn_org_id      => l_org_id,
      i_txfr_org_id     => NULL,
      i_cost_grp_id     => l_cost_grp_id,
      i_txfr_cost_grp   => l_txfr_cost_grp_id,
      i_txfr_layer_id   => NULL,
      i_fob_point       => NULL,
      i_exp_item        => l_exp_item_flag,
      i_exp_flag        => l_exp_flag,
      i_citw_flag       => 0,
      i_flow_schedule   => l_flow_schedule,
      i_user_id         => l_user_id,
      i_login_id        => l_login_id,
      i_req_id          => l_request_id,
      i_prg_appl_id     => l_prog_app_id,
      i_prg_id          => l_prog_id,
      i_tprice_option     => 0,
      i_txf_price         => 0,
      o_err_num         => l_err_num,
      o_err_code        => l_err_code,
      o_err_msg         => l_err_msg
    );


    /****************************************************
    *Call distribution processor - if the avg cost proc**
    *succeeds                                          **
    *****************************************************/

    IF (l_err_num<>0) THEN
       raise proc_fail;
    ELSE

      CSTPACDP.cost_txn
      (
        i_org_id            => l_org_id,
        i_txn_id            => l_trx_id,
        i_layer_id          => l_layer_id,
        i_fob_point         => NULL,
        i_exp_item          => l_exp_item_flag,
        I_COMM_ISS_FLAG     => L_COMM_ISS_FLAG,
        i_flow_schedule     => l_flow_schedule,
        I_USER_ID           => l_user_id,
        i_login_id          => l_login_id,
        i_req_id            => l_request_id,
        i_prg_appl_id       => l_prog_app_id,
        i_prg_id            => l_prog_id,
        i_tprice_option     => 0,
        i_txf_price         => 0,
        o_error_num         => l_err_num,
        o_error_code        => l_err_code,
        o_error_message     => l_err_msg
      );

    END IF;



    IF (l_err_num<>0) THEN
      raise proc_fail;
    END IF;

    /* Create SLA Event */
    l_trx_info.TRANSACTION_ID       := l_trx_id;
    l_trx_info.TXN_ACTION_ID        := l_action_id;
    l_trx_info.TXN_ORGANIZATION_ID  := l_org_id;
    l_trx_info.TXN_SRC_TYPE_ID      := l_src_type_id;
    l_trx_info.TRANSACTION_DATE     := l_txn_date;

    CST_XLA_PVT.Create_INVXLAEvent (
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_FALSE,
      p_commit            => FND_API.G_FALSE,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_trx_info          => l_trx_info
    );
    IF l_return_status <> 'S' THEN
      l_err_num := -1;
      l_err_code := 'Error raising SLA Event for transaction: '||to_char(l_trx_id);
      RAISE proc_fail;
    END IF;


  END IF; -- CITW condition check IF statement ends here.

  /*---------------------------------------------------------
  | If processing was succesful in the prior step, we need
  | to update wip_period_balances.
  |----------------------------------------------------------*/

  stmt_num := 160;

  select count(*)
  into   l_row_count
  from   mtl_cst_actual_cost_details
  where  transaction_id = l_trx_id;


  IF (l_row_count <> 0) THEN

    IF ( l_action_id = 1  OR
         l_action_id = 27 OR
         l_action_id = 33 OR
         l_action_id = 34 ) THEN

      CSTPACWB.cost_in
      (
        i_trx_id               => l_trx_id,
        i_layer_id             => l_layer_id,
        i_comm_iss_flag        => l_comm_iss_flag,
        I_COST_TXN_ACTION_ID   => l_action_id,
        i_txn_qty              => l_txn_qty,
        i_period_id            => l_period_id,
        i_wip_entity_id        => l_wip_entity_id,
        i_org_id               => l_org_id,
        i_user_id              => l_user_id,
        i_request_id           => l_request_id,
        err_num                => l_err_num,
        err_code               => l_err_code,
        err_msg                => l_err_msg
      );

      /* Bug 3062249 - Call EAM API only if transaction is not CITW
         This is because, distributions have not yet been created for
         CITW txns. For these, EAM API will be called in CSTPACIN */
      if (l_comm_iss_flag <> 1) then

      /* Check if the job is EAM. If yes, then update material asset cost */
      if (l_err_num = 0) then
        select entity_type
        into l_entity_type
        from wip_entities
        where wip_entity_id = l_wip_entity_id;

        if (l_entity_type in (6,7)) then
         CST_eamCost_PUB.process_matCost (
		p_api_version	=>	1.0,
		x_return_status	=>	l_return_status,
		x_msg_count	=>	l_msg_count,
		x_msg_data	=>	l_msg_data,
		p_txn_id	=>	l_trx_id,
		p_user_id	=>	l_user_id,
		p_request_id	=>	l_request_id,
		p_prog_id	=>	l_prog_id,
		p_prog_app_id	=>	l_prog_app_id,
		p_login_id	=>	l_login_id
          );

          if (l_return_status <> fnd_api.g_ret_sts_success) then
             CST_UTILITY_PUB.writelogmessages
                  ( p_api_version	=>	1.0,
		    p_msg_count		=>	l_msg_count,
		    p_msg_data		=>	l_msg_data,
		    x_return_status	=>	l_msg_return_status );
             l_err_num := l_msg_count;
          else
             l_err_num := 0;
          end if;
        end if;
      end if;
     end if; --not citw for EAM API check

    ELSIF( (l_action_id = 31 OR
           l_action_id = 32 OR
           l_action_id = 30) AND l_exp_item_flag <>1 ) THEN

      CSTPACWB.cost_out
      (
        i_trx_id          => l_trx_id,
        i_txn_qty         => l_txn_qty,
        i_period_id       => l_period_id,
        i_wip_entity_id   => l_wip_entity_id,
        i_org_id          => l_org_id,
        i_user_id         => l_user_id,
        i_request_id      => l_request_id,
        err_num           => l_err_num,
        err_code          => l_err_code,
        err_msg           => l_err_msg
      );

    END IF;



    -- Raise exception if there is an error in updating WPB.

    IF (l_err_num<>0) THEN
      raise proc_fail;
    END IF;

  END IF;




EXCEPTION

  WHEN proc_fail THEN
    err_num := l_err_num;
    err_code := l_err_code;
    err_msg := l_err_msg;
    ROLLBACK;

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := 'CSTPLCWP:' || to_char(stmt_num) || substr(SQLERRM,1,150);
    ROLLBACK;

END cost_wip_trx;


END CSTPLCWP;

/