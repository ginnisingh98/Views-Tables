--------------------------------------------------------
--  DDL for Package Body CSTPLCIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLCIN" as
/* $Header: CSTLCINB.pls 120.8.12000000.2 2007/09/26 07:27:36 akhadika ship $ */

procedure cost_inv_txn (
  i_txn_id                  in number,
  i_org_id		    in number,
  i_cost_group_id	    in number,
  i_txfr_cost_group_id	    in number,
  i_cost_type_id	    in number,
  i_cost_method		    in number,
  i_rates_ct_id	            in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_id                 in number,
  i_prog_appl_id            in number,
  i_item_id	    	    in number,
  i_txn_qty		    in number,
  i_txn_action_id	    in number,
  i_txn_src_type_id	    in number,
  i_txn_org_id		    in number,
  i_txfr_org_id		    in number,
  i_fob_point		    in number,
  i_exp_flag		    in number,
  i_exp_item		    in number,
  i_citw_flag		    in number,
  i_flow_schedule	    in number,
  i_tprice_option           in number,
  i_txf_price               in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
is
  l_layer_cost_org          number;
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);

    -- Bug 3062249
  l_txn_source_id           number;
  l_entity_type             number;
  l_return_status           varchar2(1);
  l_msg_count               number := 0;
  l_msg_data                varchar2(8000);
  l_msg_return_status       varchar2(1);
  -- Bug 3062249


  l_layer_id                number;
  l_txfr_layer_id           number;
  l_stmt_num		    number;
  cost_inv_txn_error	    EXCEPTION;

  l_pd_txfr_ind NUMBER; --OPM INVCONV sschinch
  /* SLA Uptake */
  l_trx_info                CST_XLA_PVT.t_xla_inv_trx_info;
  l_txn_source_code         MTL_MATERIAL_TRANSACTIONS.SOURCE_CODE%TYPE;
  l_std_txfr_flag           VARCHAR2(1);
  l_enc_reversal_flag       NUMBER;
  l_encumbrance_amount      NUMBER;
  l_bc_status               VARCHAR2(2000);
  l_packet_id               NUMBER;


begin

  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_layer_id := 0;
  l_txfr_layer_id := 0;

  /*------------------------------------------------------------+
   | Begin OPM INVCONV sschinch/umoogala Process/discrete Xfer changes.
   | Following query will return:
   | 1 for process/discrete xfer
   | 0 for discrete/discrete xfer
   +------------------------------------------------------------*/
  l_stmt_num := 5;
  SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
    INTO l_pd_txfr_ind
    FROM MTL_PARAMETERS MP
   WHERE MP.ORGANIZATION_ID = i_txn_org_id
      OR MP.ORGANIZATION_ID = i_txfr_org_id;
 /*End OPM INVCONV sschinch process discrete changes */

  l_stmt_num := 10;
  SELECT
    transaction_date,
    transaction_source_id,
    source_code,
    encumbrance_amount
  INTO
    l_trx_info.TRANSACTION_DATE,
    l_txn_source_id,
    l_txn_source_code,
    l_encumbrance_amount
  FROM   MTL_MATERIAL_TRANSACTIONS
  WHERE  TRANSACTION_ID = i_txn_id;

  /*------------------------------------------------------------+
   |  Check cost group layer for following three transaction cases.
   |  1) Direct InterOrg Transfer
   |  2) FOB shipment Shipment
   |  3) FOB receipt Receipt
   |  4) Logical Intransit Receipt for process discrete transactions. (OPM INVCONV)
   |  5) Logical Intransit Shipment for process discrete transactions. (OPM INVCONV)
   |     Bug 5324241: Without this condition, control is going to
   |     elsif block and layer is being created with discrete org and
   |     opm orgs cost group id.
   +------------------------------------------------------------*/
  if ((i_txn_action_id = 3) or
      (i_txn_action_id = 12 and i_fob_point = 2) or
      (i_txn_action_id = 21 and i_fob_point = 1) or
      (i_txn_action_id = 15 ) or/* Logical Intransit Receipt OPM INVCONV sschinch*/
      (i_txn_action_id = 22 ) ) then

    l_stmt_num := 10;
    SELECT count(*)
    INTO l_layer_cost_org
    FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = i_txn_org_id
    AND PRIMARY_COST_METHOD in (5,6);

    if (l_layer_cost_org > 0) then
      -- check the existence of layer
      l_layer_id := CSTPACLM.layer_id(i_txn_org_id, i_item_id,
				    i_cost_group_id, l_err_num,
				    l_err_code, l_err_msg);
      -- check error
      if (l_err_num <> 0) then
        raise cost_inv_txn_error;
      end if;

      -- create a layer
      if (l_layer_id = 0) then
        l_layer_id := CSTPACLM.create_layer(i_txn_org_id, i_item_id,
					  i_cost_group_id, i_user_id,
					  i_request_id, i_prog_id,
                                          i_prog_appl_id, i_txn_id, l_err_num,
					  l_err_code, l_err_msg);
        -- check error
        if (l_layer_id = 0) then
          raise cost_inv_txn_error;
        end if;
      end if;
    end if;

    /*------------------------------------------------------------+
     |  OPM INVCONV sschinch/umoogala
     |  Assumption here is that we are calling
     |  this routine for discrete organization as receiving org.
     |  It is important that we do not create cost layers for shipping
     |  organization if it is a process org.
     |  So before we create lets check if this transfer is between
     |  a process and discretre organization
    +------------------------------------------------------------*/

    IF (l_pd_txfr_ind = 0)
    THEN

        SELECT count(*)
        INTO l_layer_cost_org
        FROM MTL_PARAMETERS
        WHERE ORGANIZATION_ID = i_txfr_org_id
        AND PRIMARY_COST_METHOD in (5,6);


        if (l_layer_cost_org > 0) then
                -- check the existence of layer
                l_txfr_layer_id := CSTPACLM.layer_id(i_txfr_org_id, i_item_id,
				             i_txfr_cost_group_id, l_err_num,
				             l_err_code, l_err_msg);
                -- check error
                if (l_err_num <> 0) then
                        raise cost_inv_txn_error;
                end if;

                -- create a layer
                if (l_txfr_layer_id = 0) then
                        l_txfr_layer_id := CSTPACLM.create_layer(i_txfr_org_id, i_item_id,
	               				  i_txfr_cost_group_id, i_user_id,
		                	          i_request_id, i_prog_id,
                                                  i_prog_appl_id, i_txn_id, l_err_num,
					          l_err_code, l_err_msg);
                        -- check error
                        if (l_txfr_layer_id = 0) then
                                raise cost_inv_txn_error;
                        end if;
                end if;
        end if;
    END IF;
    /* End OPM INVCONV sschinch */

  /*------------------------------------------------------------+
   |  Check layer for following three transaction cases.
   |  1) Subinventory Transfer
   |  2) FOB shipment Receipt
   |  3) FOB receipt Shipment
   +------------------------------------------------------------*/
   /* Bug #2002105. Txf_cost_group_id defaults to -1 if value in database is NULL.*/
  elsif (i_txfr_cost_group_id <> -1 ) then

    SELECT count(*)
    INTO l_layer_cost_org
    FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = i_txn_org_id
    AND PRIMARY_COST_METHOD in (5,6);

    if (l_layer_cost_org > 0) then
      -- check the existence of layer
      l_layer_id := CSTPACLM.layer_id(i_txn_org_id, i_item_id,
				    i_cost_group_id, l_err_num,
				    l_err_code, l_err_msg);
      -- check error
      if (l_err_num <> 0) then
        raise cost_inv_txn_error;
      end if;

      -- create a layer
      if (l_layer_id = 0) then
        l_layer_id := CSTPACLM.create_layer(i_txn_org_id, i_item_id,
					  i_cost_group_id, i_user_id,
					  i_request_id, i_prog_id,
                                          i_prog_appl_id, i_txn_id, l_err_num,
					  l_err_code, l_err_msg);
        -- check error
        if (l_layer_id = 0) then
          raise cost_inv_txn_error;
        end if;
      end if;
      -- check the existence of layer
      l_txfr_layer_id := CSTPACLM.layer_id(i_txn_org_id, i_item_id,
	                 	             i_txfr_cost_group_id, l_err_num,
			                     l_err_code, l_err_msg);
      -- check error
      if (l_err_num <> 0) then
        raise cost_inv_txn_error;
      end if;

      -- create a layer
      if (l_txfr_layer_id = 0) then
        l_txfr_layer_id := CSTPACLM.create_layer(i_txn_org_id, i_item_id,
	                             	         i_txfr_cost_group_id, i_user_id,
			                         i_request_id, i_prog_id,
                                                 i_prog_appl_id, i_txn_id, l_err_num,
					         l_err_code, l_err_msg);
        -- check error
        if (l_txfr_layer_id = 0) then
          raise cost_inv_txn_error;
        end if;
    end if;
  end if; /*Checking for FIFO,LIFO org*/

  /*------------------------------------------------------------+
   |  Rest of cases other than subinv txfr, inter org txfr,
   |  fob shipment, or fob receipt transactions
   +------------------------------------------------------------*/
  else
    SELECT count(*)
    INTO l_layer_cost_org
    FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = i_txn_org_id
    AND PRIMARY_COST_METHOD in (5,6);

    if (l_layer_cost_org > 0) then

    -- check the existence of layer
    l_layer_id := CSTPACLM.layer_id(i_txn_org_id, i_item_id,
				    i_cost_group_id, l_err_num,
				    l_err_code, l_err_msg);
    -- check error
    if (l_err_num <> 0) then
      raise cost_inv_txn_error;
    end if;

    -- create a layer
    if (l_layer_id = 0) then
      l_layer_id := CSTPACLM.create_layer(i_txn_org_id, i_item_id,
					  i_cost_group_id, i_user_id,
					  i_request_id, i_prog_id,
                                          i_prog_appl_id, i_txn_id, l_err_num,
					  l_err_code, l_err_msg);
      -- check error
      if (l_layer_id = 0) then
        raise cost_inv_txn_error;
      end if;
    end if;
   end if;

  end if;

  l_stmt_num := 60;

  /*
  ** call the layer cost processor to cost transactions
  */
  CSTPLVCP.cost_processor(i_org_id,
                          i_txn_id,
                          l_layer_id,
			  i_cost_type_id,
			  i_cost_method,
			  i_rates_ct_id,
			  i_rates_ct_id,
			  i_item_id,
			  i_txn_qty,
			  i_txn_action_id,
			  i_txn_src_type_id,
			  i_txn_org_id,
			  i_txfr_org_id,
			  i_cost_group_id,
			  i_txfr_cost_group_id,
                          l_txfr_layer_id,
			  i_fob_point,
  			  i_exp_item,
			  i_exp_flag,
			  i_citw_flag,
			  i_flow_schedule,
                          i_user_id,
                          i_login_id,
                          i_request_id,
                          i_prog_appl_id,
                          i_prog_id,
                          i_tprice_option,
                          i_txf_price,
                          l_err_num,
                          l_err_code,
                          l_err_msg);

  /*
  ** check the return value from the average cost processor
  */
  if (l_err_num <> 0) then
    -- Error occurred
    raise cost_inv_txn_error;
  end if;

  l_stmt_num := 70;

  /*
  ** call the material distribution processor if it's not
     a layer cost update transaction.  This type of transaction
     has call its own distribution procedure.
  */

  if (i_txn_action_id = 24 ) then /*Removed i_txn_src_type_id = 15 for bug 6030287*/
     CSTPLENG.layer_cost_update_dist(i_org_id,
                    i_txn_id,
                    l_layer_id,
                    i_exp_item,
                    i_user_id,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    l_err_num,
                    l_err_code,
                    l_err_msg);

     if (l_err_num <> 0) then
       -- Error occurred
       raise cost_inv_txn_error;
     end if;

   else
     CSTPACDP.cost_txn(i_org_id,
                    i_txn_id,
                    l_layer_id,
                    i_fob_point,
                    i_exp_item,
		    i_citw_flag,
		    i_flow_schedule,
                    i_user_id,
                    i_login_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    i_tprice_option,
                    i_txf_price,
                    l_err_num,
                    l_err_code,
                    l_err_msg);

      -- check the return value from the material distribution
      -- processor
      if (l_err_num <> 0) then
         raise cost_inv_txn_error;
      end if;

  /* Bug 3062249 */
  /* If a CITW transaction and an EAM job, then call EAM Cost API to
     update EAM Elemental costs */

     if (i_citw_flag = 1) then
           select entity_type
           into l_entity_type
           from wip_entities
           where wip_entity_id = l_txn_source_id;

           if (l_entity_type in (6,7)) then
                CST_eamCost_PUB.process_matCost (
                        p_api_version   =>      1.0,
                        x_return_status =>      l_return_status,
                        x_msg_count     =>      l_msg_count,
                        x_msg_data      =>      l_msg_data,
                        p_txn_id        =>      i_txn_id,
                        p_user_id       =>      i_user_id,
                        p_request_id    =>      i_request_id,
                        p_prog_id       =>      i_prog_id,
                        p_prog_app_id   =>      i_prog_appl_id,
                        p_login_id      =>      i_login_id
                    );

                if (l_return_status <> fnd_api.g_ret_sts_success) then
                     CST_UTILITY_PUB.writelogmessages
                        ( p_api_version       =>      1.0,
                          p_msg_count         =>      l_msg_count,
                          p_msg_data          =>      l_msg_data,
                          x_return_status     =>      l_msg_return_status );
                     l_err_num := l_msg_count;
                else
                     l_err_num := 0;
                end if;
          end if;
     end if;
   end if;

  /* SLA Event Seeding */
  /* Structure used so that API signature is not disrupted
    when additional transactional parameters are required
    (without making redundant calls to TXN tables) */

  /* For intransit interorg transactions that are picked by
     the cost worker of the non-transaction organization, do not
     create the events since they have been created by the cost
     worker of the transaction organization */
  /* For Std-Ave or Ave-Std transfers, the average/layer cost worker
   * processes both the sending and receiving transactions. This case
   * should be excluded from the scenario described above */

  l_stmt_num := 171;

  l_std_txfr_flag := 'N';

  IF ( I_TXN_ACTION_ID in (12, 21) ) THEN
    BEGIN
      SELECT 'Y'
      INTO   l_std_txfr_flag
      FROM   MTL_PARAMETERS
      WHERE  ORGANIZATION_ID IN ( i_txn_org_id, i_txfr_org_id )
      AND    PRIMARY_COST_METHOD = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_std_txfr_flag := 'N';
    END;
  END IF;

  IF NOT ( ( ( I_TXN_ACTION_ID = 21 AND I_FOB_POINT = 1 ) OR
           ( I_TXN_ACTION_ID = 12 AND I_FOB_POINT = 2 ) ) AND
           I_TXN_ORG_ID <> I_ORG_ID AND l_std_txfr_flag = 'N' ) THEN
    l_stmt_num := 205;

    SELECT
      encumbrance_reversal_flag
    INTO
      l_enc_reversal_flag
    FROM
      MTL_PARAMETERS
    WHERE
      organization_id = i_txn_org_id;

    l_trx_info.TRANSACTION_ID       := i_txn_id;
    l_trx_info.TXN_ACTION_ID        := i_txn_action_id;
    l_trx_info.TXN_ORGANIZATION_ID  := i_txn_org_id;
    l_trx_info.TXN_SRC_TYPE_ID      := i_txn_src_type_id;
    l_trx_info.TXFR_ORGANIZATION_ID := i_txfr_org_id;
    l_trx_info.FOB_POINT            := i_fob_point;
    l_trx_info.PRIMARY_QUANTITY     := i_txn_qty;

    IF I_TPRICE_OPTION <> 0 THEN
      l_trx_info.TP := 'Y';
    ELSE
      l_trx_info.TP := 'N';
    END IF;

    IF i_txn_action_id = 24 and l_txn_source_code is not null THEN
      l_trx_info.attribute := l_txn_source_code;
    ELSIF i_citw_flag = 1 THEN
      l_trx_info.attribute := 'CITW';
    ELSIF i_txn_action_id = 3 THEN
      IF i_txn_qty < 0 THEN
        l_trx_info.attribute := 'SAME';
      ELSE
        l_trx_info.attribute := 'TRANSFER';
      END IF;
    END IF;

    l_trx_info.ENCUMBRANCE_FLAG := 'N';
    IF ( i_txn_src_type_id  in (1, 7, 8) )  THEN
      IF (l_encumbrance_amount is NOT NULL AND l_enc_reversal_flag = 1 ) THEN
        l_trx_info.ENCUMBRANCE_FLAG := 'Y';
      END IF;
    END IF;

    l_stmt_num := 210;
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
      l_err_code := 'Error raising SLA Event for transaction: '||to_char(i_txn_id);    l_err_msg := 'CSTPLCIN.COST_INV_TXN:('||l_stmt_num||'): '||l_err_code;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF; /* Main IF NOT ( ( ( I_TXN_ACTION_ID = 21 .. */

EXCEPTION
  when cost_inv_txn_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPLCIN.COST_INV_TXN:' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCIN.COST_INV_TXN: (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,150);

end cost_inv_txn;

end cstplcin;

/
