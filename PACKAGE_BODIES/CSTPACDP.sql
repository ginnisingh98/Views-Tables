--------------------------------------------------------
--  DDL for Package Body CSTPACDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACDP" AS
/* $Header: CSTACDPB.pls 120.64.12010000.17 2010/08/18 02:43:41 anjha ship $ */

--
-- OPM INVCONV  umoogala  Process-Discrete Xfers Enh.
-- Added following global variable for Interorg Profit Account
-- Accounting Line Type
--
G_INTERORG_PROFIT_ACCT  BINARY_INTEGER := 34;

G_DEBUG                 VARCHAR2(10)   := fnd_profile.value('MRP_DEBUG');


--Local procedure
PROCEDURE balance_account_txn_type(
  i_org_id              IN          NUMBER,
  i_txn_id              IN          NUMBER,
  i_txn_type_id         IN          NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2);


-- PROCEDURE
--  cost_txn			This processor writes cost distributions.
--
--
procedure cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_LAYER_ID		IN	NUMBER,
  I_FOB_POINT		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_COMM_ISS_FLAG	IN	NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  I_TPRICE_OPTION       IN      NUMBER,
  I_TXF_PRICE           IN      NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_item_id	NUMBER;
  l_cost_grp_id NUMBER;
  l_txfr_cost_grp NUMBER;
  l_txn_org_id	NUMBER;
  l_txn_date	DATE;
  l_p_qty	NUMBER;
  l_subinv	VARCHAR2(10);
  l_txf_org_id	NUMBER;
  l_qty_adj	NUMBER;
  l_txf_cost 	NUMBER;
  l_trp_cost	NUMBER;
  l_trp_acct	NUMBER;
  l_txn_act_id	NUMBER;
  l_txn_src_id	NUMBER;
  l_txf_subinv	VARCHAR2(10);
  l_txf_txn_id  NUMBER;
  l_src_type_id	NUMBER;
  l_dist_acct	NUMBER;
  l_mat_acct	NUMBER;
  l_mat_ovhd_acct NUMBER;
  l_res_acct	NUMBER;
  l_osp_acct	NUMBER;
  l_ovhd_acct	NUMBER;
  l_pri_curr	VARCHAR2(15);
  l_alt_curr  	VARCHAR2(10);
  l_conv_date	DATE;
  l_conv_rate	NUMBER;
  l_conv_type	VARCHAR2(30);
  l_sob_id	NUMBER;
  l_operating_unit NUMBER;

  l_purch_encum_flag FINANCIALS_SYSTEM_PARAMS_ALL.PURCH_ENCUMBRANCE_FLAG%TYPE;
  l_enc_rev	NUMBER;
  l_enc_amount	NUMBER;
  l_enc_acct	NUMBER;

  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_stmt_num	NUMBER;
  l_debug       VARCHAR2(80);

  l_return_status VARCHAR2(1);
  l_return_message       VARCHAR2(1000);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR2(240);

  -- new variable for dropshipment
  l_logical_txn NUMBER;
  l_txn_type_id NUMBER;

  -- new variables for Revenue COGS Matching
  l_so_issue_accounting NUMBER;
  l_cogs_percentage     NUMBER;
  l_cogs_om_line_id     NUMBER;

  l_onhand_var_acct  NUMBER;/*LCM*/

  process_error	EXCEPTION;

/* NL Changes */
    l_sql_stmt               VARCHAR2(8000);
    l_cse_installed          BOOLEAN;
    l_cse_hook_used          NUMBER;
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
    l_nl_trackable           VARCHAR2(1);
    l_asset_creation_code    VARCHAR2(30);
    CST_FAILED_CSE_CALL      EXCEPTION;
/* NL Changes */
/* Bug 6405593*/
l_hook_used                  NUMBER;
l_loc_non_recoverable_tax    NUMBER;
l_loc_recoverable_tax        NUMBER;
l_total_dist_amount          NUMBER;
l_rcv_transaction_id         NUMBER;
l_loc_po_distribution_id     NUMBER;
/* Bug 6405593*/

  /* OPM INVCONV sschinch/umoogala changes*/
  l_pd_txfr_price   NUMBER;  -- Transfer Price
  l_pd_txfr_ind     NUMBER;  -- Process-Discrete Xfer Flag
  -- End OPM INVCONV umoogala
  l_enc_org_id       NUMBER;
  l_enc_org_cost_method NUMBER;
BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_hook_used:=0;

  l_debug := fnd_profile.value('MRP_DEBUG');


  IF (l_debug = 'Y' ) THEN
    FND_FILE.put_line( FND_FILE.log, 'CSTPACDP.Cost_txn << ' );
  END IF;


  -- Populate local variables

  l_stmt_num := 10;

  --
  -- OPM INVCONV umoogala  Added column to fetch transfer price from mmt.
  --
  select
        inventory_item_id, organization_id,
	nvl(cost_group_id,1), nvl(transfer_cost_group_id,1),
        transaction_date,
        primary_quantity, subinventory_code,
        transfer_organization_id,
        quantity_adjusted, nvl(transfer_cost,0), nvl(transportation_cost,0),
        nvl(transportation_dist_account,-1),
        transaction_action_id,
        nvl(transaction_source_id,-1),
        transfer_subinventory,
        nvl(transfer_transaction_id,-1),
        transaction_source_type_id, nvl(distribution_account_id,-1),
        nvl(material_account, -1), nvl(material_overhead_account, -1),
	nvl(resource_account, -1), nvl(outside_processing_account, -1),
	nvl(overhead_account, -1),
	nvl(encumbrance_account, -1), nvl(encumbrance_amount, 0),
        currency_code,
        nvl(currency_conversion_date,transaction_date),
        nvl(currency_conversion_rate,-1) , currency_conversion_type,
        logical_transaction,
        transaction_type_id,
        transfer_price, -- OPM INVCONV umoogala
        trx_source_line_id, -- COGS OM Line ID
        nvl(so_issue_account_type,1), -- 1=COGS, 2=Deferred COGS
        cogs_recognition_percent,
	rcv_transaction_id,
	nvl(expense_account_id,-1)
  into
	l_item_id,
	l_txn_org_id,
	l_cost_grp_id,
	l_txfr_cost_grp,
	l_txn_date,
	l_p_qty,
	l_subinv,
	l_txf_org_id,
	l_qty_adj,
	l_txf_cost,
	l_trp_cost,
	l_trp_acct,
	l_txn_act_id,
	l_txn_src_id,
	l_txf_subinv,
	l_txf_txn_id,
	l_src_type_id,
	l_dist_acct,
	l_mat_acct,
	l_mat_ovhd_acct,
	l_res_acct,
	l_osp_acct,
	l_ovhd_acct,
	l_enc_acct,
	l_enc_amount,
	l_alt_curr,
	l_conv_date,
	l_conv_rate,
	l_conv_type,
    l_logical_txn,
    l_txn_type_id,
    l_pd_txfr_price,  -- OPM INVCONV umoogala
    l_cogs_om_line_id,
    l_so_issue_accounting,
    l_cogs_percentage,
    l_rcv_transaction_id,
    l_onhand_var_acct
  from mtl_material_transactions
  where transaction_id = i_txn_id;

/* NL Changes */
  l_stmt_num := 12;
    -----------------------------
    -- Get Installation Status --
    -----------------------------

  l_cse_installed := FND_INSTALLATION.GET_APP_INFO ( 'CSE',
                                                    l_status,
                                                    l_industry,
                                                    l_schema);

   /* Check if item is NL trackable and depreciable (asset_creation_code) */
  SELECT   nvl(comms_nl_trackable_flag, 'N'), asset_creation_code
  INTO     l_nl_trackable, l_asset_creation_code
  FROM     mtl_system_items
  WHERE    inventory_item_id = l_item_id
  AND      organization_id =  i_org_id;

/* Write out log warning if Item is NL trackable or depreciable and
 * NL is not installed */

  IF ( (l_nl_trackable = 'Y' OR l_asset_creation_code IS NOT NULL) AND l_status = 'N') THEN
    l_err_msg := 'WARNING: Item NL Trackable/Depreciable but NL not Installed';
    IF (l_debug = 'Y' ) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_msg);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'NL Trackable Flag: ' || l_nl_trackable);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'NL Depreciable Flag: ' || l_asset_creation_code);
    END IF;
  END IF;

  IF (l_status = 'I') THEN

    l_stmt_num := 13;
    CSE_COST_DISTRIBUTION_STUB.cost_distribution (i_txn_id,
                                                  l_cse_hook_used,
                                                  l_err_num,
                                                  l_err_code,
                                                  l_err_msg);
    IF (l_debug = 'Y' ) THEN
      fnd_file.put_line(fnd_file.log,'Debug: CSE cost distribution hook : ' || to_char(l_cse_hook_used));
    END IF;

    IF (l_err_num <> 0) THEN
     RAISE CST_FAILED_CSE_CALL;
    END IF;

  END IF;


  if( l_cse_hook_used = 1 ) then
    return;
  end if;



  l_stmt_num := 15;

IF ( l_src_type_id = 1 OR
     (l_txn_act_id = 29 and l_src_type_id = 7) OR
     (l_txn_act_id = 3 and l_src_type_id in (7,8)) OR
     (l_txn_act_id = 12 and l_src_type_id = 7) OR
     (l_txn_act_id = 21 and l_src_type_id = 8 )) THEN
select decode(encumbrance_reversal_flag,1,1,2,0,0),
       organization_id,
       primary_cost_method
into   l_enc_rev,
       l_enc_org_id,
       l_enc_org_cost_method
from   mtl_parameters
where  ( organization_id = i_org_id
         AND l_src_type_id = 1 )
     OR (organization_id = i_org_id
         AND l_txn_act_id = 29 and l_src_type_id = 7 )
     OR ( organization_id = l_txn_org_id
          AND l_txn_act_id = 3 and l_src_type_id in (7,8) and l_p_qty > 0)
     OR ( organization_id = l_txf_org_id
          AND l_txn_act_id = 3 and l_src_type_id in (7,8) and l_p_qty < 0)
     OR (organization_id = l_txn_org_id
         AND l_txn_act_id = 12 and l_src_type_id = 7)
     OR (organization_id = l_txf_org_id
         AND l_txn_act_id = 21 and l_src_type_id = 8);

ELSE
 select decode(encumbrance_reversal_flag,1,1,2,0,0),
       organization_id,
       primary_cost_method
into   l_enc_rev,
       l_enc_org_id,
       l_enc_org_cost_method
from   mtl_parameters
where  organization_id = i_org_id;

END IF;


  -- Figure out currency stuff.

  l_stmt_num := 20;

/* The following query will be made to refer to cst_organization_definitions
   as an impact of the HR-PROFILE option */

  select set_of_books_id,
         operating_unit
  into l_sob_id,
       l_operating_unit
  /*from org_organization_definitions */
  from cst_organization_definitions
  where organization_id = i_org_id;

  l_stmt_num := 30;

  select currency_code
  into l_pri_curr
  from gl_sets_of_books
  where set_of_books_id = l_sob_id;

  if (l_alt_curr is not NULL and l_conv_rate = -1) then
    if (l_alt_curr <> l_pri_curr) then

      if (l_conv_type is NULL) then
        FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_conv_type);
      end if;

      l_stmt_num := 40;

      l_conv_rate := gl_currency_api.get_rate(l_sob_id,l_alt_curr,l_txn_date,
					   l_conv_type);
    end if;
  end if;

  /*******************************************************************
   ** I break down the inventory transactions into 5 categories:    **
   ** 1) WIP transactions - all wip related transactions such as    **
   **			    wip issue and completions               **
   ** 2) subinventory transfers					    **
   ** 3) interorg transfers					    **
   ** 4) Average cost update					    **
   ** 5) Add if clause for drop ship/global procure                 **
   ** 6) rest of inventory transactions				    **
   *******************************************************************/
  if (i_comm_iss_flag = 1) THEN
 -- call dedicated function for common issue to wip txn here.
    CSTPACDP.comm_iss_to_wip(I_TXN_ID => i_txn_id,
			     I_COMM_ISS_FLAG => i_comm_iss_flag,
			     I_FLOW_SCHEDULE => i_flow_schedule,
			     I_ORG_ID => i_org_id,
			     I_ITEM_ID => l_item_id,
			     I_COST_GRP_ID => l_cost_grp_id,
			     I_TXFR_COST_GRP => l_txfr_cost_grp,
			     I_TXN_DATE => l_txn_date,
			     I_P_QTY => l_p_qty,
			     I_SUBINV => l_subinv,
			     I_SOB_ID => l_sob_id,
			     I_PRI_CURR => l_pri_curr,
			     I_ALT_CURR => l_alt_curr,
			     I_CONV_DATE => l_conv_date,
			     I_CONV_RATE => l_conv_rate,
			     I_CONV_TYPE => l_conv_type,
			     I_EXP_ITEM => i_exp_item,
			     I_TXF_SUBINV => l_txf_subinv,
			     I_TXN_ACT_ID => l_txn_act_id,
			     I_TXN_SRC_ID => l_txn_src_id,
			     I_SRC_TYPE_ID => l_src_type_id,
			     I_USER_ID => i_user_id,
			     I_LOGIN_ID => i_login_id,
			     I_REQ_ID => i_req_id,
			     I_PRG_APPL_ID => i_prg_appl_id,
			     I_PRG_ID => i_prg_id,
			     O_Error_Num => l_err_num,
			     O_Error_Code => l_err_code,
			     O_Error_Message => l_err_msg);



    elsif (l_src_type_id = 5 and l_txn_act_id <> 2) then
    -- WIP transaction
    -- These always occur in base currency.
    CSTPACDP.wip_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_item_id,
			l_txn_date, l_p_qty, l_subinv, l_txn_act_id,
			l_txn_src_id, l_src_type_id,
			l_dist_acct,
			l_sob_id, l_pri_curr,
			i_exp_item,i_flow_schedule,i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
    -- check error;

    if(l_err_num <> 0) then
      raise process_error;
    end if;

  /* Changes for VMI. Adding Planning Transfer transaction */
  elsif (l_txn_act_id in (2,5,28,55)) then
    -- Subinventory transfer,VMI Planning transfer,staging transfer,cost group transfer for WMS mobile
    CSTPACDP.sub_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_txfr_cost_grp,
			l_item_id,
			l_txn_date, l_p_qty, l_subinv, l_txf_subinv,
			l_txf_txn_id, l_txn_act_id,
			l_txn_src_id, l_src_type_id,
			l_sob_id, l_pri_curr, l_alt_curr,
			l_conv_date, l_conv_rate, l_conv_type,
			i_exp_item, i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
    -- check error;

    if(l_err_num <> 0) then
      raise process_error;
    end if;

  elsif (l_txn_act_id in (3,12,21,15,22)) then
    -- OPM INVCONV umoogala: Added 15 (Logical Itr Receipt) and 22 (Logical Itr Shipment) actions.

    -- Interorg transfers

    /* TPRICE: If the transfer pricing option is yes, set transfer credit to be zero */
    if (i_tprice_option <> 0) then
       l_txf_cost := 0;
    end if;

    -- OPM INVCONV umoogala: Added new parameter (l_pd_txfr_price) to send transfer_price
    CSTPACDP.interorg_cost_txn(i_org_id, i_txn_id, l_cost_grp_id,
			l_txfr_cost_grp, l_item_id,
			l_txn_date, l_p_qty, l_subinv,
			l_txn_org_id, l_txf_org_id,
			l_txf_txn_id, l_txf_cost, l_trp_cost,
			l_trp_acct, l_txn_act_id,
			l_txn_src_id, l_src_type_id,
			i_fob_point, i_exp_item, l_pd_txfr_price, i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
    -- check error;

    if(l_err_num <> 0) then
      raise process_error;
    end if;

    /* TPRICE: If the transfer pricing option is yes, need to do accounting adjustment here */
    --
    -- Bug 5172278.
    -- For Process/Discrete Xfers, tp option is set to 2.
    -- For direct xfer do not call the following procedure
    --
    if ( /*(i_exp_item = 0) AND */ /* removed for bug #5569128 */
        (i_tprice_option <> 0) AND
        ((l_txn_act_id = 21 AND l_src_type_id = 8 AND i_fob_point = 1) OR
         (l_txn_act_id = 12 AND l_src_type_id = 7 AND i_fob_point = 2) OR
	 (l_txn_act_id = 15 AND l_src_type_id = 7) OR
	 (l_txn_act_id = 22 AND l_src_type_id = 8))
       )
    then
        CST_TPRICE_PVT.Adjust_Acct(1.0, p_tprice_option => i_tprice_option, p_txf_price => i_txf_price,
                        p_txn_id => i_txn_id, p_cost_grp_id => l_cost_grp_id,
			p_txf_cost_grp => l_txfr_cost_grp, p_item_id => l_item_id,
			p_txn_date => l_txn_date, p_qty => l_p_qty, p_subinv => l_subinv,
                        p_txf_subinv => l_txf_subinv, p_txn_org_id => l_txn_org_id,
                        p_txf_org_id => l_txf_org_id, p_txf_txn_id => l_txf_txn_id,
                        p_txf_cost => l_txf_cost, p_txn_act_id => l_txn_act_id,
			p_txn_src_id => l_txn_src_id, p_src_type_id => l_src_type_id,
			p_fob_point => i_fob_point, p_user_id => i_user_id, p_login_id => i_login_id,
                        p_req_id => i_req_id, p_prg_appl_id => i_prg_appl_id,
                        p_prg_id => i_prg_id, x_return_status => l_return_status,
                        x_msg_count => l_msg_count, x_msg_data => l_msg_data, x_error_num => l_err_num,
                        x_error_code => l_err_code, x_error_message => l_err_msg);

        if (l_err_num <> 0) then
           raise process_error;
        end if;
    end if;

  elsif (l_txn_act_id = 24) then /*Removed i_txn_src_type_id = 15 for bug 6030287*/
    -- Average Cost Update
    CSTPACDP.avcu_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_item_id,
			l_txn_date, l_qty_adj, l_txn_act_id,
			l_txn_src_id, l_src_type_id,
			l_mat_acct, l_mat_ovhd_acct, l_res_acct,
			l_osp_acct, l_ovhd_acct,
			l_sob_id, l_pri_curr, l_alt_curr,
			l_conv_date, l_conv_rate, l_conv_type,
			i_exp_item,l_onhand_var_acct, i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
    -- check error;

    if(l_err_num <> 0) then
      raise process_error;
    end if;

  -- the following 2 elsifs are added for dropshipment project
  elsif (l_logical_txn = 1) then
    -- 11i10 - dropshipment project added logical transaction types
    -- this function handles all new logical transactions
    CSTPACDP.logical_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_item_id,
                      l_txn_date, l_p_qty, l_subinv, l_txn_act_id,
                      l_txn_src_id, l_src_type_id, l_txn_type_id, l_dist_acct,
                      l_sob_id, l_pri_curr, l_alt_curr,
                      l_conv_date, l_conv_rate, l_conv_type,
                      l_so_issue_accounting, l_cogs_percentage, l_cogs_om_line_id,
                      i_exp_item, i_user_id, i_login_id,
                      i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                      l_err_code, l_err_msg);
    if(l_err_num <> 0) then
      raise process_error;
    end if;
  elsif (l_txn_act_id = 25 and l_src_type_id = 1) then
    -- 11i10 - Retroactive Price Update for consigned
    CSTPACDP.consigned_update_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_item_id,
                        l_txn_date, l_p_qty, l_subinv, l_txn_act_id,
                        l_txn_src_id, l_src_type_id, l_dist_acct,
                        l_sob_id, l_pri_curr, l_alt_curr,
                        l_conv_date, l_conv_rate, l_conv_type,
                        i_exp_item, i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                        l_err_code, l_err_msg);
    if(l_err_num <> 0) then
      raise process_error;
    end if;
  else
    -- Rest of inventory transactions
    CSTPACDP.inv_cost_txn(i_org_id, i_txn_id, l_cost_grp_id, l_item_id,
			l_txn_date, l_p_qty, l_subinv, l_txn_act_id,
			l_txn_src_id, l_src_type_id,l_dist_acct,
			l_sob_id, l_pri_curr, l_alt_curr,
			l_conv_date, l_conv_rate, l_conv_type,
            l_so_issue_accounting, l_cogs_percentage, l_cogs_om_line_id,
			i_exp_item, i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
    -- check error;

    if(l_err_num <> 0) then
      raise process_error;
    end if;

  end if;

  -- Take care of rounding errors.

/* FIX bug 668528 -> change i_org_id to l_txn_org_id so it will balance the account own by that txns */
--  balance_account(l_txn_org_id, i_txn_id,l_err_num, l_err_code, l_err_msg);
--BUG#6732955
  balance_account_txn_type(
  i_org_id              => l_txn_org_id,
  i_txn_id              => i_txn_id,
  i_txn_type_id         => l_txn_type_id,
  O_Error_Num           => l_err_num,
  O_Error_Code          => l_err_code,
  O_Error_Message       => l_err_msg);


  -- check error

  if(l_err_num <> 0) then
      raise process_error;
  end if;


  if (l_txn_act_id in (3,12,21)) then
    balance_account(l_txf_org_id, i_txn_id,l_err_num, l_err_code, l_err_msg);

  if(l_err_num <> 0) then
      raise process_error;
    end if;

  end if;



  /*
   * Encumrbance amount would be computed within costing for all cases except
   * PO
   * Use CSTPAVCP.CompEncumbrance_IntOrdersExp to get the amount and the
   * account
   * This is used for transactions that are sourced from Internal Requisitions
   * or Internal Orders
   * For Internal Order Intransit transactions, encumbrance is reversed against
   * based on FOB point. Encumbrance is reversed when ownership changes
   * If FOB point is receipt, it is reversed for the Receipt transaction
   * otherwise, if it the FOB point is shipment, it is reversed against the
   * shipment transaction
   * Also, for Internal Order intransit transfer transactions, if the transfer
   * is either for an expense item (in the shipment organization) or from an
   * an expense subinventory, no reversal of encumbrace takes place.
   * This is required since no reservation takes place in the above case.
   */

  /* Compute Encumbrance Amount and create the reversal entry,
     if applicable */
  IF ( (l_txn_act_id = 29 and l_src_type_id = 7) OR
     (l_txn_act_id = 3 and l_src_type_id in (7,8)) OR
     (l_txn_act_id = 12 and l_src_type_id = 7) OR
     (l_txn_act_id = 21 and l_src_type_id = 8 )) THEN
  BEGIN
   SELECT nvl(req_encumbrance_flag,'N') /*nvl(purch_encumbrance_flag, 'N')Bug 6469694*/,
          gsb.currency_code
    INTO   l_purch_encum_flag,
           l_pri_curr
    FROM   FINANCIALS_SYSTEM_PARAMS_ALL FSP,
           cst_organization_definitions cod,
           gl_sets_of_books gsb
  WHERE  fsp.set_of_books_id = cod.set_of_books_id
    and  fsp.org_id= cod.operating_unit
    and  cod.organization_id = l_enc_org_id
    and  gsb.set_of_books_id = cod.set_of_books_id ;
  EXCEPTION
  WHEN no_data_found THEN
    l_purch_encum_flag := 'N';
  END;
 END IF;

  IF (l_debug = 'Y' ) THEN
        FND_FILE.put_line( FND_FILE.log, 'l_purch_encum_flag : '||l_purch_encum_flag );
        FND_FILE.put_line( FND_FILE.log, 'l_txn_act_id       : '||l_txn_act_id);
        FND_FILE.put_line( FND_FILE.log, 'l_src_type_id      : '||l_src_type_id);
        FND_FILE.put_line( FND_FILE.log, 'i_fob_point        : '||i_fob_point);
        FND_FILE.put_line( FND_FILE.log, 'l_txn_org_id       : '||l_txn_org_id);
	FND_FILE.put_line( FND_FILE.log, 'l_txf_org_id       : '||l_txf_org_id);
	FND_FILE.put_line( FND_FILE.log, 'i_org_id           : '||i_org_id);
   END IF;



  /* Explanation:
     For Shipment transaction and FOB shipment, check if the worker is launched
     by the receipt organization. Same for Receipt organization and FOB receipt
     : Ensure that the worker belongs to the receipt organization
     In these cases, the workers of the transfer orgs do the accounting in those
     organizations */

  IF ( l_enc_rev = 1 AND l_purch_encum_flag = 'Y') THEN

    --{BUG#9702519
    --IF ( ( ( l_txn_act_id = 21 and l_src_type_id = 8 and i_fob_point = 1 ) AND
    --       ( l_txn_org_id <> i_org_id ) ) OR
    --     ( l_txn_act_id = 3 and l_src_type_id in (7,8) and l_p_qty > 0 ) OR
    --     ( l_txn_act_id = 29 and l_src_type_id = 7 ) OR
    --     ( ( l_txn_act_id = 12 and l_src_type_id = 7 and i_fob_point = 2 ) AND
    --          l_txn_org_id = i_org_id ) ) THEN

    IF (  ( l_txn_act_id     = 21
 	    and l_src_type_id    = 8
 	    and i_fob_point      = 1
 	    and l_txn_org_id     <> i_org_id
 	    and l_enc_org_cost_method <> 1 )
 	 OR (l_txn_act_id   = 21
 	     and l_src_type_id  = 8
 	     and i_fob_point    = 1
 	     and l_txn_org_id   = i_org_id
 	     and l_enc_org_cost_method = 1 )
 	 OR (l_txn_act_id   = 3
 	     and l_src_type_id in (7,8)
 	     and l_p_qty        > 0 )
 	 OR (l_txn_act_id   = 29
 	     and l_src_type_id  = 7 )
 	 OR (l_txn_act_id     = 12
 	     and l_src_type_id    = 7
 	     and i_fob_point      = 2
 	     and l_txn_org_id     = i_org_id
 	     and l_enc_org_cost_method <> 1 )
 	 OR (l_txn_act_id     = 12
 	     and l_src_type_id    = 7
 	     and i_fob_point      = 2
 	     and l_txn_org_id     <> i_org_id
 	     and l_enc_org_cost_method = 1 )
        ) THEN

      IF (l_debug = 'Y' ) THEN
        FND_FILE.put_line( FND_FILE.log, 'Encumbrance Reversal' );
      END IF;
      CSTPAVCP.CompEncumbrance_IntOrdersExp (
        p_api_version         => 1.0,
        p_transaction_id      => i_txn_id,
        x_encumbrance_amount  => l_enc_amount,
        x_encumbrance_account => l_enc_acct,
        x_return_status       => l_return_status,
        x_return_message      => l_return_message );

      IF (l_debug = 'Y' ) THEN
        FND_FILE.put_line( FND_FILE.log, 'Encumbrance Amount: '||l_enc_amount||', Encumbrance Account: '||l_enc_acct );
      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      /* Create the encumbrance for this transaction against the receipt
         organization */
      CSTPACDP.encumbrance_account(l_enc_org_id, i_txn_id, l_item_id,
                        -1*l_enc_amount, l_p_qty, l_enc_acct,
                        l_sob_id, l_txn_date,
                        l_txn_src_id, l_src_type_id,
                        l_pri_curr, l_alt_curr,
                        l_conv_date, l_conv_rate, l_conv_type,
                        i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);
      if(l_err_num <> 0) then
        raise process_error;
      end if;
    END IF;
  END IF;
  /* For PO related transactions, use encumbrance amount and account
     on MMT */
  IF ((l_src_type_id = 1 and (l_enc_rev = 1 and l_enc_amount <> 0))) THEN

    /* Bug 6030861 :Added hook call to override the recoverable and Non-Recoverable
                    taxes for ENCUMBRANCE_REVERSAL event */
      IF l_debug = 'Y' THEN
	   fnd_file.put_line(fnd_file.log, 'Getting Po_Distribution_id for Receving transaction :'||l_rcv_transaction_id);
      END IF;

	l_stmt_num := 43;
	SELECT po_distribution_id
	  INTO l_loc_po_distribution_id
	  FROM rcv_transactions
	 WHERE transaction_id =l_rcv_transaction_id;

      IF l_debug = 'Y' THEN
	   fnd_file.put_line(fnd_file.log, 'Calling CST_Common_hooks.Get_NRtax_amount for PO_DIST :'||l_loc_po_distribution_id);
      END IF;

	l_stmt_num := 45;
	 l_hook_used := CST_Common_hooks.Get_NRtax_amount(
	                I_ACCT_TXN_ID        =>i_txn_id,
	                I_SOURCE_DOC_TYPE    =>'PO',
	                I_SOURCE_DOC_ID      =>l_loc_po_distribution_id,
	                I_ACCT_SOURCE        =>'MMT',
	                I_USER_ID            =>i_user_id,
	                I_LOGIN_ID           =>i_login_id,
	                I_REQ_ID             =>i_req_id,
	                I_PRG_APPL_ID        =>i_prg_appl_id,
	                I_PRG_ID             =>i_prg_id,
	                O_DOC_NR_TAX         =>l_loc_non_recoverable_tax,
	                O_DOC_REC_TAX        =>l_loc_recoverable_tax,
	                O_Err_Num            =>l_err_num,
	                O_Err_Code           =>l_err_code,
	                O_Err_Msg            =>l_err_msg
				   );
        IF l_hook_used <>0 THEN

	 IF (l_err_num <> 0) THEN
	      -- Error occured
              IF l_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log, 'Error getting Enc Tax in CST_Common_hooks.Get_NRtax_amount at statement :'||l_stmt_num);
                   fnd_file.put_line(fnd_file.log, 'Error Code :  '||l_err_code||' Error Message : '||l_err_msg);
	      END IF;
              RAISE process_error;
	    END IF;

	IF l_debug = 'Y' THEN
           fnd_file.put_line(fnd_file.log,'Hook Used  CST_Common_hooks.Get_NRtax_amount :'|| l_hook_used ||
	                     ' l_loc_recoverable_tax : '||l_loc_recoverable_tax||
                             ' l_loc_non_recoverable_tax : '||l_loc_non_recoverable_tax);
        END IF;

	l_stmt_num := 46;

		select  pod.quantity_ordered * (poll.price_override) + nvl(pod.nonrecoverable_tax,0)
		  into  l_total_dist_amount
		  from  po_line_locations_all poll,
			po_distributions_all  pod
		 where  poll.po_header_id         =pod.po_header_id
		   and  poll.line_location_id     =pod.line_location_id
		   and  pod.po_distribution_id    =l_loc_po_distribution_id;

	l_stmt_num := 47;

         l_enc_amount:=nvl(l_enc_amount,0)+(nvl(l_enc_amount,0) * nvl(l_loc_non_recoverable_tax,0))/l_total_dist_amount;

       END IF;


      /* Bug 6030861 :Added hook call to override the recoverable and Non-Recoverable
                      taxes for ENCUMBRANCE_REVERSAL event */

    CSTPACDP.encumbrance_account(i_org_id, i_txn_id, l_item_id,
                        -1*l_enc_amount, l_p_qty, l_enc_acct,
                        l_sob_id, l_txn_date,
                        l_txn_src_id, l_src_type_id,
                        l_pri_curr, l_alt_curr,
                        l_conv_date, l_conv_rate, l_conv_type,
                        i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);
  END IF;
    if(l_err_num <> 0) then
        raise process_error;
    end if;


  l_stmt_num := 50;
  -- Update the transaction costed date

  Update mtl_cst_actual_cost_details
  set transaction_costed_date = sysdate
  where transaction_id = i_txn_id
  and transaction_costed_date is NULL;

  IF (l_debug = 'Y' ) THEN
    FND_FILE.put_line( FND_FILE.log, 'CSTPACDP.Cost_Txn >>');
  END IF;

 EXCEPTION

/* NL Changes */
    WHEN CST_FAILED_CSE_CALL THEN
      O_Error_Num   := 20001;
      O_Error_Code  := SUBSTR('CSTACDPB.cost_txn('
                            || to_char(l_stmt_num)
                            || '): '
                            || 'FAILED CSE Package Call. '
                            || l_err_msg,1,240);
      O_Error_Message := substr(l_err_msg,1,240) ;
/* NL Changes */

 when gl_currency_api.NO_RATE then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_GL_RATE';
 FND_MESSAGE.set_name('BOM', 'CST_NO_GL_RATE');
 O_error_message := FND_MESSAGE.Get;


 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.cost_txn' || to_char(l_stmt_num) ||
		     substr(SQLERRM,1,180);

END cost_txn;

procedure comm_iss_to_wip(
  I_TXN_ID              IN      NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_ORG_ID              IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_COST_GRP_ID         IN      NUMBER,
  I_TXFR_COST_GRP       IN      NUMBER,
  I_TXN_DATE            IN      DATE,
  I_P_QTY               IN      NUMBER,
  I_SUBINV              IN      VARCHAR2,
  I_SOB_ID              IN      NUMBER,
  I_PRI_CURR            IN      VARCHAR2,
  I_ALT_CURR            IN      VARCHAR2,
  I_CONV_DATE           IN      DATE,
  I_CONV_RATE           IN      NUMBER,
  I_CONV_TYPE           IN      VARCHAR2,
  I_EXP_ITEM            IN      NUMBER,
  I_TXF_SUBINV          IN      VARCHAR2,
  I_TXN_ACT_ID          IN      NUMBER,
  I_TXN_SRC_ID          IN      NUMBER,
  I_SRC_TYPE_ID         IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY     NUMBER,
  O_Error_Code          OUT NOCOPY     VARCHAR2,
  O_Error_Message       OUT NOCOPY     VARCHAR2
) is

  l_subinv              VARCHAR2(10);
  l_cost_grp_id         NUMBER;
  l_exp_sub1            NUMBER;
  l_exp_acct1           NUMBER;
  l_exp_sub2            NUMBER;
  l_exp_acct2           NUMBER;
  l_exp_sub             NUMBER;
  l_exp_acct            NUMBER;
  l_qty                 NUMBER;
  l_wip_qty     	NUMBER;
  l_acct_class 		VARCHAR2(10);
  l_mat_acct    	NUMBER;
  l_mat_ovhd_acct 	NUMBER;
  l_res_acct    	NUMBER;
  l_osp_acct    	NUMBER;
  l_ovhd_acct   	NUMBER;
  l_exp_job     	NUMBER;
  l_ovhd_absp   	NUMBER;
  l_stmt_num            NUMBER;
  l_msg_count           NUMBER;
  l_return_status       VARCHAR2(11);
  l_msg_data            VARCHAR2(2000);
  l_wms_flg             NUMBER;
  process_error         EXCEPTION;
  l_action_id           NUMBER; /* Bug#4259926 */
  l_err_num     NUMBER;
  l_err_code    VARCHAR2(240);
  l_err_msg     VARCHAR2(240);


 BEGIN

  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


 -- If the item is expense, it has no cost, hence no distributions are
 -- performed for the item.

  if (i_exp_item = 1) then
    return;
  end if;

 -- Figure out expense subinventory for both from and to.
 -- Not sure if this is applicable in the case of a common issue to WIP.

 -- The CITW averaging and acocunting follow the rules below.
 -- Issuing Common Sub	 Job		(assumed) Proj Sub  Costing/Acct
 -- *********************************************************************
 -- * Asset		 Asset		 Asset			Yes	*
 -- * Asset		 Expense	 Asset			Yes	*
 -- * Expense		 Asset		 Asset			Yes	*
 -- * Expense		 Expense	 N/A			No	*
 -- *********************************************************************
 -- Note that in reality there is no project sub in between. The assmpn
 -- of asset is being made. This will enable us to use the Cost group
 -- layer for reaveraging and accounts for distbn to the Project.
 -- The Exp - Exp case involves no entry. This is analogous to the exp - exp
 -- subinv transfer case.

  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,i_org_id)) then
     l_wms_flg := 1;
  else
     l_wms_flg := 0;
  end if;

  l_stmt_num := 10;

  select decode(asset_inventory,1,0,1)
  into l_exp_sub1
  from mtl_secondary_inventories
  where secondary_inventory_name = i_subinv
  and organization_id = i_org_id;

  if (l_wms_flg = 0) then
     select nvl(expense_account, -1)
     into l_exp_acct1
     from mtl_secondary_inventories
     where secondary_inventory_name = i_subinv
     and organization_id = i_org_id;
  else
     if (i_cost_grp_id = 1) then
      /* Need to change cst_avg_dist_accts_v to include expense_account */
       select nvl(expense_account,-1)
       into l_exp_acct1
       from mtl_parameters
       where  organization_id = i_org_id;
     else
       select nvl(expense_account, -1)
       into l_exp_acct1
       from cst_cost_group_accounts
       where cost_group_id = i_cost_grp_id
       and organization_id = i_org_id;
     end if;
  end if;


  l_stmt_num := 20;

  If (i_flow_schedule <> 1) THEN

  select decode(class_type,1,0,3,0,1), -1
  into l_exp_sub2, l_exp_acct2
  from wip_discrete_jobs wdj,
       wip_accounting_classes wac
  where
	wdj.wip_entity_id 	=	I_TXN_SRC_ID 	and
	wdj.class_code 		=	wac.class_code	and
	wdj.organization_id	=	wac.organization_id and
  	wdj.organization_id = i_org_id;

 else

  l_stmt_num := 22;

  select decode(class_type,1,0,3,0,1), -1
  into l_exp_sub2, l_exp_acct2
  from wip_flow_schedules wdj,
       wip_accounting_classes wac
  where
        wdj.wip_entity_id       =       I_TXN_SRC_ID    and
        wdj.class_code          =       wac.class_code  and
        wdj.organization_id     =       wac.organization_id and
        wdj.organization_id = i_org_id;

 End If;


  -- If expense to expense transfer then no accounting entries.
  if (l_exp_sub1 = 1 and l_exp_sub2 = 1) then
    return;
  end if;


 -- In a comm issue to wip txn, we have to perform distributions for both
 -- subs initially, treating the txn first as a sub txfr. Then we have to
 -- do distbns for the Issue part of the txn, treating it as a wip issue.


 /* -- First do the subinv txfr transaction part -- */
 -- Note that the Project sub is always an asset sub, so the
 -- l_exp_sub2 parameter must always reflect asset. This is the case
 -- even if the job is an expense job. So hard code it to Zero to
 -- indicate this.

  -- Do distribution for both subs.
  FOR i in 1..2 loop
    if (i = 1) then
      l_qty := i_p_qty;
      l_exp_sub := l_exp_sub1;
      l_exp_acct := l_exp_acct1;
      l_subinv := i_subinv;
      l_cost_grp_id := i_cost_grp_id;
    else
      l_qty := -1 * i_p_qty;
      l_exp_sub := 0;
      l_exp_acct := l_exp_acct2;
      l_subinv := i_txf_subinv;
      l_cost_grp_id := i_txfr_cost_grp;
    end if;

 -- The transaction_source_type_id that gets passed in for this txn
 -- will correspond to a WIP issue (=5). However, the value that is
 -- used for a subinv txf is 13. This is hard coded into the call to
 -- the inventory_accounts() procedure.

    inventory_accounts(i_org_id, i_txn_id,i_comm_iss_flag,
			2, l_cost_grp_id,
                        i_item_id, l_qty,
                        i_sob_id,i_txn_date, i_txn_src_id, 13,
                        i_exp_item, l_exp_sub, l_exp_acct, l_subinv, 0, NULL,
                        i_pri_curr, i_alt_curr, i_conv_date,
                        i_conv_rate, i_conv_type,
                        i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);

    -- check error
    if (l_err_num <> 0) then
    raise process_error;
    end if;


  end loop;

 --
 -- Now do the wip issue part
 --

  -- There are no cost distributions for expense items.
  if (i_exp_item = 1) then
    return;
  end if;


 -- From the standpoint of CITW, the project sub is always an asset, hence
 -- the l_exp_sub parameter must be set to 0. This will ensure that the
 -- correct acct line type is picked in the inventory_accounts() function.

 	l_exp_sub := 0;

  -- Figure out accts, expense subinventory and expense job flags.

  l_stmt_num := 50;

  IF (i_flow_schedule <> 1) THEN

  select material_account, material_overhead_account, resource_account,
        outside_processing_account, overhead_account, class_code
  into l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct,
        l_acct_class
  from wip_discrete_jobs
  where organization_id = i_org_id
  and wip_entity_id = i_txn_src_id;

 ELSE

   l_stmt_num := 55;

   select material_account, material_overhead_account, resource_account,
        outside_processing_account, overhead_account, class_code
  into l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct,
        l_acct_class
  from wip_flow_schedules
  where organization_id = i_org_id
  and wip_entity_id = i_txn_src_id;

 END IF;

  l_stmt_num := 60;

  select decode(class_type, 4,1,0)
  into l_exp_job
  from wip_accounting_classes
  where class_code = l_acct_class
  and organization_id = i_org_id;


  -- Debit/Credit WIP accounts

  -- the transaction quantity from the WIP point of view is the opposite
  -- of inventory.
  l_wip_qty := -1 * i_p_qty;

   /* Bug#4259926 Added if statement to pass correct transaction_action_id
   value for distribute_account and inventory_accounts procedures. */
     if (i_txn_act_id = 27 and i_src_type_id = 5 and i_comm_iss_flag =1) then
         l_action_id := 27;
     else
         l_action_id := 1;
     end if;
  /* Bug#4259926 replaced 1 with l_action_id  */
  distribute_accounts(i_org_id, i_txn_id,i_comm_iss_flag,i_txfr_cost_grp,l_action_id,
		      i_item_id, l_wip_qty,7, 1, l_ovhd_absp,
                        NULL, l_mat_acct, l_mat_ovhd_acct, l_res_acct,
                        l_osp_acct, l_ovhd_acct,
                        i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                        i_subinv, NULL, i_pri_curr, NULL, NULL, NULL, NULL,
                        i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                        l_err_code, l_err_msg);

 -- check error

    if(l_err_num <> 0) then
      raise process_error;
    end if;

 -- Here the accounting that gets done for the Inventory side
 -- actually gets done for the txfr CG, since the issue is from the
 -- txfr CG to the Job. Hence pass i_txfr_cost_grp in the call to
 -- inventory_accounts().
    /* Bug#4259926 replaced 1 with l_action_id  */
    inventory_accounts(i_org_id, i_txn_id, i_comm_iss_flag,
			l_action_id, i_txfr_cost_grp,
                        i_item_id, i_p_qty,
                        i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
                        i_exp_item, l_exp_sub, l_exp_acct, i_subinv,0,NULL,
                        i_pri_curr, NULL, NULL, NULL, NULL,
                        i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);

    if(l_err_num <> 0) then
    raise process_error;
    end if;



 EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.comm_iss_to_wip (' || to_char(l_stmt_num) ||
                    '): ' ||  substr(SQLERRM,1,180);

 END comm_iss_to_wip;

procedure wip_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_DIST_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_exp_sub	NUMBER;
  l_exp_acct	NUMBER;
  l_exp_job	NUMBER;
  l_ovhd_absp   NUMBER;
  l_mat_ovhd_exists NUMBER;
  l_wip_qty 	NUMBER;
  l_cost	NUMBER;
  l_acct	NUMBER;
  l_mat_acct	NUMBER;
  l_mat_ovhd_acct NUMBER;
  l_res_acct	NUMBER;
  l_osp_acct	NUMBER;
  l_ovhd_acct	NUMBER;
  l_mat_var_acct NUMBER;
  l_res_var_acct NUMBER;
  l_osp_var_acct NUMBER;
  l_ovhd_var_acct NUMBER;
  l_acct_class VARCHAR2(10);
  l_stmt_num 	NUMBER;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_msg_count   NUMBER;
  l_return_status VARCHAR2(11);
  l_msg_data    VARCHAR2(2000);
  l_wms_flg     NUMBER;
  process_error	EXCEPTION;
  l_debug       VARCHAR2(80);

BEGIN
  -- Initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_ovhd_absp := 0;
  l_mat_ovhd_exists := '';
  l_debug := fnd_profile.value('MRP_DEBUG');

  -- There are no cost distributions for expense items.
  if (i_exp_item = 1) then
    return;
  end if;

  -- Figure out accts, expense subinventory and expense job flags.

  l_stmt_num := 10;

 IF (i_flow_schedule <>1) THEN

  select material_account, material_overhead_account, resource_account,
	outside_processing_account, overhead_account, class_code
  into l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct,
	l_acct_class
  from wip_discrete_jobs
  where organization_id = i_org_id
  and wip_entity_id = i_txn_src_id;

 ELSE

    --
    -- cfm scrap
    --
    IF (i_txn_act_id = 30 AND i_dist_acct = -1) THEN
       SELECT material_account, material_overhead_account, resource_account,
              outside_processing_account, overhead_account, class_code,
              material_variance_account, resource_variance_account,
              outside_proc_variance_account, overhead_variance_account
       INTO l_mat_acct, l_mat_ovhd_acct, l_res_acct,
	    l_osp_acct, l_ovhd_acct, l_acct_class,
            l_mat_var_acct, l_res_var_acct,
	    l_osp_var_acct, l_ovhd_var_acct
       FROM wip_flow_schedules
       WHERE organization_id = i_org_id
       AND wip_entity_id = i_txn_src_id;

    ELSE
       SELECT material_account, material_overhead_account, resource_account,
              outside_processing_account, overhead_account, class_code
       INTO l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct,
            l_acct_class
       FROM wip_flow_schedules
       WHERE organization_id = i_org_id
       AND wip_entity_id = i_txn_src_id;
    END IF;

END IF;

  l_stmt_num := 20;

  select decode(class_type, 4,1,0)
  into l_exp_job
  from wip_accounting_classes
  where class_code = l_acct_class
  and organization_id = i_org_id;

  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,i_org_id)) then
     l_wms_flg := 1;
  else
     l_wms_flg := 0;
  end if;

  l_stmt_num := 30;
  -- Scrap transactions do not have inventory impact!!
  if (i_txn_act_id <> 30) then
    select decode(asset_inventory,1,0,1)
    into l_exp_sub
    from mtl_secondary_inventories
    where secondary_inventory_name = i_subinv
    and organization_id = i_org_id;

    if (l_wms_flg = 0) then
      select nvl(expense_account, -1)
      into l_exp_acct
      from mtl_secondary_inventories
      where secondary_inventory_name = i_subinv
      and organization_id = i_org_id;
    else
      if (i_cost_grp_id = 1) then
        /* Need to change cst_avg_dist_accts_v to include expense_account */
        select nvl(expense_account,-1)
        into l_exp_acct
        from mtl_parameters
        where  organization_id = i_org_id;
      else
        select nvl(expense_account, -1)
        into l_exp_acct
        from cst_cost_group_accounts
        where cost_group_id = i_cost_grp_id
        and organization_id = i_org_id;
      end if;
    end if;

    -- Transactions between expense subinventories and expense jobs are
    -- not distributed.
    if (l_exp_sub = 1 and l_exp_job = 1) then
      return;
    end if;

  end if;

  -- Debit/Credit WIP accounts

  -- the transaction quantity from the WIP point of view is the opposite
  -- of inventory.
  l_wip_qty := -1 * i_p_qty;

  -- Material overhead absorption happens for the assembly completion
  -- and asembly return transactions.
  if (i_txn_act_id in (31,32)) then
    l_ovhd_absp := 1;
  end if;

 -- If the txn is not a CITW txn, pass 0 for the comm_iss_flag

  distribute_accounts(i_org_id, i_txn_id,0,i_cost_grp_id,i_txn_act_id,
		      i_item_id, l_wip_qty,7, 1, l_ovhd_absp,
			NULL, l_mat_acct, l_mat_ovhd_acct, l_res_acct,
			l_osp_acct, l_ovhd_acct,
			i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_subinv, NULL, i_pri_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);

 -- check error

    if(l_err_num <> 0) then
      fnd_file.put_line(fnd_file.log, 'failed after distribute_accounts');
      raise process_error;
    end if;

    if (i_txn_act_id = 30) then  /* WIP Scrap */
       if (i_flow_schedule = 1 AND i_dist_acct = -1 ) then
          cfm_scrap_dist_accounts(i_org_id, i_txn_id,0,i_cost_grp_id,i_txn_act_id,
			i_item_id, i_p_qty,2, 1, 0,
			i_dist_acct, l_mat_var_acct, NULL, l_res_var_acct,
			l_osp_var_acct, l_ovhd_var_acct,
			i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_subinv, NULL, i_pri_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
       else
       distribute_accounts(i_org_id, i_txn_id,0,i_cost_grp_id,i_txn_act_id,
			i_item_id, i_p_qty,2, 1, 0,
			i_dist_acct, i_dist_acct, i_dist_acct, i_dist_acct,
			i_dist_acct, i_dist_acct,
			i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_subinv, NULL, i_pri_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id,
			i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
			l_err_code, l_err_msg);
      end if;

 -- check error

    if(l_err_num <> 0) then
    raise process_error;
    end if;

  else
    -- All the other wip transactions have inventory impact.
    inventory_accounts(i_org_id, i_txn_id,2,
		        i_txn_act_id,i_cost_grp_id,
			i_item_id, i_p_qty,
			i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, i_subinv,0,NULL,
			i_pri_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id,
			i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

    if(l_err_num <> 0) then
        fnd_file.put_line(fnd_file.log, 'failed after inv_accounts');
    raise process_error;
    end if;


    if (l_ovhd_absp = 1) then

      l_stmt_num := 40;

      /* assembly completion or assembly return */
      select count(*)
      into l_mat_ovhd_exists
      from mtl_cst_actual_cost_details
      where transaction_id = i_txn_id
      and organization_id = i_org_id
      and cost_element_id = 2
      and level_type = 1;

      if (l_mat_ovhd_exists > 0) then
        ovhd_accounts(i_org_id, i_txn_id, i_item_id, -1 * i_p_qty, i_sob_id,
			i_txn_date,i_txn_src_id, i_src_type_id,
			i_subinv, NULL,
			i_pri_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);


    if(l_err_num <> 0) then
          fnd_file.put_line(fnd_file.log, 'failed after ovhd_accounts');
    raise process_error;
    end if;

      end if;
    end if;
  end if;

 EXCEPTION

 when process_error then
  fnd_file.put_line(fnd_file.log,'process raised');
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then
   fnd_file.put_line(fnd_file.log,'other exceptions  raised');
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.wip_cost_txn (' || to_char(l_stmt_num) ||
                    '): ' ||  substr(SQLERRM,1,180);

END wip_cost_txn;

procedure sub_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_TXFR_COST_GRP	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXF_SUBINV		IN	VARCHAR2,
  I_TXF_TXN_ID		IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_subinv		VARCHAR2(10);
  l_cost_grp_id		NUMBER;
  l_exp_sub1	 	NUMBER;
  l_exp_acct1		NUMBER;
  l_exp_sub2		NUMBER;
  l_exp_acct2		NUMBER;
  l_exp_sub		NUMBER;
  l_exp_acct		NUMBER;
  l_qty			NUMBER;
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_msg_count           NUMBER;
  l_return_status       VARCHAR2(11);
  l_msg_data            VARCHAR2(2000);
  l_wms_flg             NUMBER;

BEGIN
  -- Initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  -- There are no cost distributions for expense items.
  if (i_exp_item = 1) then
    return;
  end if;

  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,i_org_id)) then
     l_wms_flg := 1;
  else
     l_wms_flg := 0;
  end if;


  -- Figure out expense subinventory for both from and to.

  l_stmt_num := 10;

  select decode(asset_inventory,1,0,1)
  into l_exp_sub1
  from mtl_secondary_inventories
  where secondary_inventory_name = i_subinv
  and organization_id = i_org_id;

  l_stmt_num := 20;
  select decode(asset_inventory,1,0,1)
  into l_exp_sub2
  from mtl_secondary_inventories
  where secondary_inventory_name = nvl(i_txf_subinv,i_subinv)
  and organization_id = i_org_id;

  if (l_wms_flg = 0) then
     select nvl(expense_account, -1)
     into l_exp_acct1
     from mtl_secondary_inventories
     where secondary_inventory_name = i_subinv
     and organization_id = i_org_id;

     select nvl(expense_account, -1)
     into l_exp_acct2
     from mtl_secondary_inventories
     where secondary_inventory_name = i_txf_subinv
     and organization_id = i_org_id;

  else
      if (i_cost_grp_id = 1) then
        /* Need to change cst_avg_dist_accts_v to include expense_account */
        select nvl(expense_account,-1)
        into l_exp_acct1
        from mtl_parameters
        where  organization_id = i_org_id;
      else
        select nvl(expense_account, -1)
        into l_exp_acct1
        from cst_cost_group_accounts
        where cost_group_id = i_cost_grp_id
        and organization_id = i_org_id;
      end if;

      if (i_txfr_cost_grp = 1) then
        select nvl(expense_account,-1)
        into l_exp_acct2
        from mtl_parameters
        where  organization_id = i_org_id;
      else
        select nvl(expense_account, -1)
        into l_exp_acct2
        from cst_cost_group_accounts
        where cost_group_id = i_txfr_cost_grp
        and organization_id = i_org_id;
      end if;
  end if;

  -- If expense to expense transfer then no accounting entries.
  if (l_exp_sub1 = 1 and l_exp_sub2 = 1) then
    return;
  end if;

  -- Do distribution for both subs.
  FOR i in 1..2 loop
    if (i = 1) then
      l_qty := i_p_qty;
      l_exp_sub := l_exp_sub1;
      l_exp_acct := l_exp_acct1;
      l_subinv := i_subinv;
      l_cost_grp_id := i_cost_grp_id;
    else
      l_qty := -1 * i_p_qty;
      l_exp_sub := l_exp_sub2;
      l_exp_acct := l_exp_acct2;
      l_subinv := i_txf_subinv;
      l_cost_grp_id := i_txfr_cost_grp;
    end if;

    inventory_accounts(i_org_id, i_txn_id,2,
			i_txn_act_id,l_cost_grp_id,
			i_item_id, l_qty,
			i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, l_subinv, 0, NULL,
			i_pri_curr, i_alt_curr, i_conv_date,
			i_conv_rate, i_conv_type,
			i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

    -- check error
    if (l_err_num <> 0) then
    raise process_error;
    end if;


  end loop;

 EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.sub_cost_txn' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END sub_cost_txn;

procedure inv_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_DIST_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_SO_ACCOUNTING   IN  NUMBER,
  I_COGS_PERCENTAGE IN  NUMBER,
  I_COGS_OM_LINE_ID IN  NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_exp_sub	NUMBER;
  l_exp_acct	NUMBER;
  l_elemental	NUMBER;
  l_acct_line_type	NUMBER;
  l_ovhd_absp	NUMBER;
  l_mat_ovhd_exists NUMBER;
  l_acct	NUMBER;
  l_mat_acct	NUMBER;
  l_mat_ovhd_acct	NUMBER;
  l_res_acct	NUMBER;
  l_osp_acct	NUMBER;
  l_ovhd_acct	NUMBER;
  l_stmt_num 	NUMBER;
  process_error	EXCEPTION;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_msg_count           NUMBER;
  l_return_status       VARCHAR2(11);
  l_msg_data            VARCHAR2(2000);
  l_wms_flg             NUMBER;
  l_drop_ship_type_code NUMBER; -- 11i10 requires clearing account on all drop
                                -- shipments whether old accounting or new
  l_def_cogs_acct_id    NUMBER; -- Revenue COGS Matching
  l_cogs_acct_id        NUMBER;
  l_ref_om_line_id      NUMBER;

  l_txfr_org_id NUMBER;
  l_txfr_txn_id NUMBER;
  l_debug       VARCHAR2(1);

  --
  -- Start INVCONV umoogala: Process/Discrete Xfers
  -- Bug 5349860: Internal Order issues to exp. Book receivables with transfer price.
  --
  l_transfer_price     NUMBER;
  l_pd_xfer_ind        VARCHAR2(1) := 'N';
  l_cost               NUMBER;
  l_io_profit_acct     NUMBER;
  l_io_receivable_acct NUMBER;
  l_value              NUMBER;

BEGIN
  -- Initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_debug := fnd_profile.value('MRP_DEBUG');
    -- Figure out expense subinventory.

  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,i_org_id)) then
     l_wms_flg := 1;
  else
     l_wms_flg := 0;
  end if;

  l_stmt_num := 10;

  select decode(asset_inventory,1,0,1)
  into l_exp_sub
  from mtl_secondary_inventories
  where secondary_inventory_name = i_subinv
  and organization_id = i_org_id;

  if (l_wms_flg = 0) then
    l_stmt_num := 11;
    select nvl(expense_account, -1)
    into l_exp_acct
    from mtl_secondary_inventories
    where secondary_inventory_name = i_subinv	AND
       	  organization_id = i_org_id;
  else
    if (i_cost_grp_id = 1) then
      /* Need to change cst_avg_dist_accts_v to include expense_account */
      l_stmt_num := 12;
      select nvl(expense_account,-1)
      into l_exp_acct
      from mtl_parameters
      where  organization_id = i_org_id;
    else
      l_stmt_num := 13;
      select nvl(expense_account, -1)
      into l_exp_acct
      from cst_cost_group_accounts
      where cost_group_id = i_cost_grp_id   AND
            organization_id = i_org_id;
    end if;
  end if;

  --
  -- Bug 5349860: determine whether this is a Process/Discrete IO issue to expense
  --
  IF (i_src_type_id = 8 and i_txn_act_id = 1)
  THEN
    SELECT decode(MOD(SUM(DECODE(MP.process_enabled_flag,'Y',1,2)), 2), 1, 'Y', 'N')
      INTO l_pd_xfer_ind
      FROM mtl_parameters mp, mtl_material_transactions mmt
     WHERE mmt.transaction_id = i_txn_id
       AND (mp.organization_id = mmt.organization_id
            OR mp.organization_id = mmt.transfer_organization_id);
  END IF;
  -- End Bug 5349860

  -- No accounting entries posted for any transaction involving an expense
  -- item or expense subinventory except in the case of PO receipt, PO
  -- return and PO delivery adjustments, and consigned ownership transactions
  -- as they are costed similar to PO receipts - bug 2815163
  --
  -- Bug 5349860: Exculde Process/Discrete IO issue to expense. Added 4th condition.
  --

  if ((i_exp_item = 1 or l_exp_sub = 1) and
      (i_src_type_id <>1) and
      (i_txn_act_id <> 6) and
      (NOT (l_pd_xfer_ind = 'Y' and i_txn_act_id = 1 and i_src_type_id = 8)))
  then
    fnd_file.put_line(fnd_file.log, 'expense item or sub (not PO source or not consigned). So, no accounting for txn: ' || i_txn_id);
    return;
  elsif (i_exp_item = 1 and l_exp_acct = -1) then

    l_stmt_num := 20;

    select nvl(expense_account, -1)
    into l_exp_acct
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = i_org_id;
  end if;

  /*********************************************************************
   ** First post to the elemental inventory accounts.                 **
   *********************************************************************/

  --
  -- Bug 5349860: determine whether this is a Process/Discrete IO issue to expense
  --
  /****************************************************************************************
  * Bug#5485052: Added conditions for i_exp_item and l_exp_sub in both the IF conditions  *
  * so that for expense items from asset or expense subinventories, the following entries *
  * doesnt get booked                                                                     *
  ****************************************************************************************/
  if (l_pd_xfer_ind = 'Y' and i_txn_act_id = 1 and i_src_type_id = 8 AND l_exp_sub = 1 and i_exp_item = 0) /* Bug#5485052 ANTHIYAG 23-Aug-2006 */
  then
   fnd_file.put_line(fnd_file.log, 'Process/Discrete Internal Order issue for Asset Item from Expense Sub-Inventory.');

    distribute_accounts(i_org_id, i_txn_id,
                 0,i_cost_grp_id,i_txn_act_id,
                 i_item_id, i_p_qty, 2,
                 0, 0, l_exp_acct, NULL, NULL, NULL, NULL,NULL,
                 i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                 i_subinv, 1, i_pri_curr,
                 NULL, NULL, NULL, NULL,
                 i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                 l_err_num, l_err_code, l_err_msg);

    if (l_err_num <> 0) then
      raise process_error;
    end if;
  elsif (l_pd_xfer_ind = 'N') OR
        (l_pd_xfer_ind = 'Y' and i_txn_act_id = 1 and i_src_type_id = 8 AND l_exp_sub = 0 and i_exp_item = 0) /* Bug#5485052 ANTHIYAG 23-Aug-2006 */
  then
    fnd_file.put_line(fnd_file.log, 'Posting elemental inv accounts');

    inventory_accounts(i_org_id, i_txn_id, 2,
		        i_txn_act_id,i_cost_grp_id,
			i_item_id, i_p_qty,
			i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, i_subinv, 0, NULL,
			i_pri_curr, i_alt_curr, i_conv_date,
			i_conv_rate, i_conv_type,
			i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
  end if;

   -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

  /*********************************************************************
   ** Then post to the offsetting accounts.		              **
   *********************************************************************/
  if (i_txn_act_id in (4,8)) then
    /* cycle count adjustment and physical inventory adjustment */
    /* Use the distribution account id as stated in mmt. */
    l_acct := i_dist_acct;

    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;
  elsif (i_txn_act_id in (1,27,29) and i_src_type_id = 1) then
    /* PO Issue, Reciept, delivery adjustments. */
    l_acct := i_dist_acct;
    if (l_acct = -1) then

      l_stmt_num := 30;

      select ap_accrual_account
      into l_acct
      from mtl_parameters
      where organization_id = i_org_id;
    end if;

    l_stmt_num := 35;
    select rt.dropship_type_code
    into l_drop_ship_type_code
    from rcv_transactions rt, mtl_material_transactions mmt
    where rt.transaction_id = mmt.rcv_transaction_id
    and mmt.transaction_id = i_txn_id;

    if (l_drop_ship_type_code = 1 OR  l_drop_ship_type_code = 2) then
      l_acct_line_type := 31; -- As of 11i10, external drop shipments should always use the clearing acct.
    else
      l_acct_line_type := 5; -- Receiving Inspection
    end if;

    l_elemental := 0;
    l_ovhd_absp := 1;
  elsif (i_txn_act_id in (1,27,29) and i_src_type_id in (2,12)) then
    /* Sales order issue, RMA and Rejection of RMA */
    l_acct := i_dist_acct;
    if (l_acct = -1) then

      l_stmt_num := 40;

      select nvl(msi.cost_of_sales_account, mp.cost_of_sales_account)
      into l_acct
      from mtl_system_items msi,
           mtl_parameters mp
      where msi.organization_id = i_org_id
      and msi.inventory_item_id = i_item_id
      and mp.organization_id = msi.organization_id;
    end if;

    l_cogs_acct_id := l_acct;
    l_acct_line_type := 35; -- COGS

    IF (i_src_type_id = 2 AND i_so_accounting = 2) THEN
       /* Deferred COGS Accounting for this sales order */

       l_stmt_num := 43;

       SELECT deferred_cogs_account
       INTO l_def_cogs_acct_id
       FROM mtl_parameters
       WHERE organization_id = i_org_id;

       /* Only call Insert_OneSoIssue if the percentage is NULL. */
       IF (i_cogs_percentage IS NULL) THEN

          l_stmt_num := 45;
          /* Record this sales order issue for COGS deferral by *
           * inserting into the Revenue / COGS matching tables  */
          CST_RevenueCogsMatch_PVT.Insert_OneSoIssue(
                              p_api_version      => 1,
                              p_user_id          => i_user_id,
                              p_login_id         => i_login_id,
                              p_request_id       => i_req_id,
                              p_pgm_app_id       => i_prg_appl_id,
                              p_pgm_id           => i_prg_id,
                              x_return_status    => l_return_status,
                              p_cogs_om_line_id  => i_cogs_om_line_id,
                              p_cogs_acct_id     => l_cogs_acct_id,
                              p_def_cogs_acct_id => l_def_cogs_acct_id,
                              p_mmt_txn_id       => i_txn_id,
                              p_organization_id  => i_org_id,
                              p_item_id          => i_item_id,
                              p_transaction_date => i_txn_date,
                              p_cost_group_id    => i_cost_grp_id,
                              p_quantity         => (-1*i_p_qty)); -- track issue quantities as positive values

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             l_err_num := -1;
             FND_MSG_PUB.count_and_get
             (  p_count   => l_msg_count,
                p_data    => l_msg_data,
                p_encoded => FND_API.g_false
             );
             IF (l_msg_count = 1) THEN
                l_err_msg := substr(l_msg_data,1,240);
             ELSE
                l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Insert_OneSoIssue()';
             END IF;
             raise process_error;
          END IF;
       END IF; -- COGS Percentage is NULL

       l_acct := l_def_cogs_acct_id; -- pass deferred COGS account to distribute_accounts()
       l_acct_line_type := 36; -- Deferred COGS

    ELSIF (i_src_type_id = 12) THEN

       l_stmt_num := 47;
       -- Get the original sales order issue OM line ID, and check
       -- whether the original sales order issue was inserted into
       -- the Revenue / COGS Matching data model.
       SELECT max(ool.reference_line_id)
       INTO l_ref_om_line_id
       FROM oe_order_lines_all ool,
            cst_revenue_cogs_match_lines crcml
       WHERE ool.line_id = i_cogs_om_line_id
       AND   ool.reference_line_id = crcml.cogs_om_line_id
       AND   crcml.pac_cost_type_id IS NULL;

    END IF; -- Deferred COGS Accounting or RMA receipt

    l_stmt_num := 50;

    select l_acct, l_acct, l_acct, l_acct, l_acct
    into l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct
    from dual;

    l_elemental := 1;
    l_ovhd_absp := 0;
  elsif (i_txn_act_id in (1,27,29) and i_src_type_id = 3) then
    /* Account */
    l_acct := i_txn_src_id;
    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;
  elsif (i_txn_act_id in (1,27,29) and i_src_type_id = 6) then
    /* Account Alias*/

    l_stmt_num := 60;

    select distribution_account
    into l_acct
    from mtl_generic_dispositions
    where disposition_id = i_txn_src_id
    and organization_id = i_org_id;

    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;
  elsif (i_txn_act_id = 6 ) then
   /* Change of ownership transaction */
       l_acct := i_dist_acct;
       l_acct_line_type := 16;
       l_elemental :=0;
       l_ovhd_absp :=1;
  elsif (i_txn_act_id = 1 and i_src_type_id = 8) then
    -- Internal Order Issue to Expense
    -- Debit Interorg Receivables Account
    -- Alcatel Enhancements

    -- Internal Order Issue to Expense could be to the same organization
    -- In this case, use the Charge account itself as the clearing
    -- account

    --
    -- Start INVCONV umoogala: Process/Discrete Xfers
    -- Bug 5349860: Book receivables with transfer price
    -- Modified following sql get transfer price and flag to
    -- determine whether this is a process/discrete xfer.
    --

    l_stmt_num := 65;
    SELECT MMT.TRANSFER_ORGANIZATION_ID,
           MMT.TRANSFER_TRANSACTION_ID,
	   MMT.TRANSFER_PRICE,
	   CASE
	     WHEN mpx.process_enabled_flag <> mp.process_enabled_flag
	     THEN
	       'Y'
	     ELSE
	       'N'
	   END
    INTO   l_txfr_org_id,
           l_txfr_txn_id,
	   l_transfer_price,
	   l_pd_xfer_ind
    FROM   MTL_MATERIAL_TRANSACTIONS mmt,
           MTL_PARAMETERS mp, MTL_PARAMETERS mpx
    WHERE  mmt.transaction_id = i_txn_id
      AND  mp.organization_id  = mmt.organization_id
      AND  mpx.organization_id = mmt.transfer_organization_id;

    IF l_txfr_txn_id IS NULL THEN
      l_acct := i_dist_acct;
      l_acct_line_type := 2;
    ELSE
      IF i_org_id <> l_txfr_org_id THEN
        l_stmt_num := 70;
        SELECT interorg_receivables_account,
	       interorg_profit_account     -- Bug 5349860: umoogala
        INTO   l_acct,
               l_io_profit_acct  -- Bug 5349860: umoogala
        FROM   MTL_INTERORG_PARAMETERS
        WHERE  from_organization_id = i_org_id
        AND    to_organization_id   = l_txfr_org_id;

	l_acct_line_type := 10;

      ELSE
        SELECT DISTRIBUTION_ACCOUNT_ID
        INTO   l_acct
        FROM   MTL_MATERIAL_TRANSACTIONS
        WHERE  transaction_id = l_txfr_txn_id;

	l_acct_line_type := 2;
      END IF;
    END IF;

    IF l_debug = 'Y' THEN
      FND_FILE.put_line(FND_FILE.log, 'Internal Order Issue to Expense');
      FND_FILE.put_line(FND_FILE.log, 'Debit Account - Receivables: '||to_char(l_acct) || ' InterOrg profit: ' || l_io_profit_acct);
    END IF;

    l_elemental := 0;
    l_ovhd_absp := 0;

  else
    /* Misc issue, receipt, default*/
    l_acct := i_dist_acct;
    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;
  end if;

  fnd_file.put_line(fnd_file.log, 'distribute_accounts()');

  -- Now for RMA receipts that reference an original sales order line ID
  IF (i_src_type_id = 12 AND i_txn_act_id = 27 AND l_ref_om_line_id IS NOT NULL) THEN

     /* This procedure will create the offsetting credits *
      * split accordingly between COGS and Deferred COGS. */
     CST_RevenueCogsMatch_PVT.Process_RmaReceipt(
                  x_return_status   => l_return_status,
                  x_msg_count       => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_rma_om_line_id  => i_cogs_om_line_id,
                  p_cogs_om_line_id => l_ref_om_line_id,
                  p_cost_type_id    => 2,
                  p_txn_quantity    => (-1*i_p_qty),
                  p_cogs_percentage => i_cogs_percentage,
                  p_organization_id => i_org_id,
                  p_transaction_id  => i_txn_id,
                  p_item_id         => i_item_id,
                  p_sob_id          => i_sob_id,
                  p_txn_date        => i_txn_date,
                  p_txn_src_id      => i_txn_src_id,
                  p_src_type_id     => i_src_type_id,
                  p_pri_curr        => i_pri_curr,
                  p_alt_curr        => i_alt_curr,
                  p_conv_date       => i_conv_date,
                  p_conv_rate       => i_conv_rate,
                  p_conv_type       => i_conv_type,
                  p_user_id         => i_user_id,
                  p_login_id        => i_login_id,
                  p_req_id          => i_req_id,
                  p_prg_appl_id     => i_prg_appl_id,
                  p_prg_id          => i_prg_id);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_err_num := -1;
        IF (l_msg_count = 1) THEN
           l_err_msg := substr(l_msg_data,1,240);
        ELSE
           l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Process_RmaReceipt()';
        END IF;
        raise process_error;
     END IF;

  ELSE -- For all non-RMA transactions, as well as RMAs that don't reference deferred COGS sales orders:

    -- Start INVCONV umoogala: Process/Discrete Xfer.
    -- Bug 5349860: Internal Order issues to exp.
    -- Book Payables with transfer price. Added following IF condition
    -- to handle this case.
    --
    IF l_pd_xfer_ind = 'N'
    THEN

      distribute_accounts(i_org_id, i_txn_id,0,i_cost_grp_id,i_txn_act_id,
                    i_item_id, -1 * i_p_qty,l_acct_line_type, l_elemental,
                    l_ovhd_absp,l_acct, l_mat_acct, l_mat_ovhd_acct, l_res_acct,
                    l_osp_acct, l_ovhd_acct,
                    i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                    i_subinv, NULL, i_pri_curr, i_alt_curr, i_conv_date,
                    i_conv_rate, i_conv_type, i_user_id, i_login_id,
                    i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                    l_err_code, l_err_msg, i_cogs_om_line_id);

      -- check error
      if(l_err_num <> 0) then
         raise process_error;
      end if;

    ELSIF l_pd_xfer_ind = 'Y'
    THEN

      --
      -- Book Receivalbes with transfer price
      -- Book Interorg Profit with diff of transfer price and cost
      --
      fnd_file.put_line(fnd_file.log,'Process/Discrete IO Issue to Exp Destination transaction');

      l_stmt_num := 50;

      l_io_receivable_acct := l_acct;

      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
          			sign(-1 * i_p_qty),
          			l_acct_line_type,
          			NULL, NULL, i_subinv,
          			0, NULL, l_err_num, l_err_code,
          			l_err_msg,NULL);

            -- check error
        if(l_err_num<>0) then
          raise process_error;
        end if;

      if (l_acct = -1) then
      	l_acct := l_io_receivable_acct;
      end if;

      l_stmt_num := 60;

      fnd_file.put_line(fnd_file.log, 'booking receivables: ' || (-1 * i_p_qty * l_transfer_price) ||' ' || i_pri_curr);

      insert_account(i_org_id, i_txn_id, i_item_id, -1 * i_p_qty * l_transfer_price,
          	-1 * i_p_qty, l_acct, i_sob_id, l_acct_line_type,
          	NULL, NULL,
          	i_txn_date, i_txn_src_id, i_src_type_id,
          	i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
          	1, i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
          	l_err_num, l_err_code, l_err_msg);

          -- check error
      if(l_err_num<>0) then
        raise process_error;
      end if;

      --
      -- Book InterOrg Profit
      --
      fnd_file.put_line(fnd_file.log, 'booking interorg profit if necessary');


      l_stmt_num := 70;
      SELECT SUM(NVL(base_transaction_value,0))
       INTO l_value
       FROM mtl_transaction_accounts
      WHERE transaction_id  = i_txn_id
        AND organization_id = i_org_id
      ;

      fnd_file.put_line(fnd_file.log,'InterOrg Profit amount: ' || l_value);

      IF l_value <> 0
      THEN

        l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
            			-1, l_acct_line_type,
            			NULL, NULL, i_subinv,
            			0, NULL, l_err_num, l_err_code,
            			l_err_msg,NULL);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
          l_acct := l_io_profit_acct;
        end if;


        insert_account(i_org_id, i_txn_id, i_item_id, -1 * l_value,
                       sign(-1 * l_value) * abs(i_p_qty), l_acct, i_sob_id,
                       34, NULL, NULL,
                       i_txn_date, i_txn_src_id, i_src_type_id,
          	       i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
                       1, i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                       l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

      END IF;


    END IF;
    -- End bug 5349860

  END IF; -- RMA Receipt with Deferred COGS reference

  l_stmt_num := 70;

  if (l_ovhd_absp = 1) then
    select count(*)
    into l_mat_ovhd_exists
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and cost_element_id = 2
    and level_type = 1;

    if (l_mat_ovhd_exists > 0) then

      fnd_file.put_line(fnd_file.log, 'ovhd_accounts()');
      ovhd_accounts(i_org_id, i_txn_id, i_item_id, -1 * i_p_qty, i_sob_id,
			i_txn_date,i_txn_src_id, i_src_type_id,
			i_subinv, NULL,
			i_pri_curr, i_alt_curr, i_conv_date,
			i_conv_rate, i_conv_type,
			i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
  -- check error

  if(l_err_num <> 0) then
  raise process_error;
  end if;

    end if;
  end if;

 EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.inv_cost_txn (' || to_char(l_stmt_num) ||
                     '): ' || substr(SQLERRM,1,180);

END inv_cost_txn;

-- OPM INVCONV umoogala: Added new parameter i_txf_price for transfer_price
procedure interorg_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_TXFR_COST_GRP	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ORG_ID		IN	NUMBER,
  I_TXF_ORG_ID		IN	NUMBER,
  I_TXF_TXN_ID		IN	NUMBER,
  I_TXF_COST		IN	NUMBER,
  I_TRP_COST		IN	NUMBER,
  I_TRP_ACCT		IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_FOB_POINT		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_TXF_PRICE		IN	NUMBER,  -- OPM INVCONV umoogala
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_intransit	NUMBER;
  l_exp_sub	NUMBER;
  l_exp_acct	NUMBER;
  l_snd_rcv 	NUMBER;
  l_io_inv_acct	NUMBER;
  l_io_txfr_acct NUMBER;
  l_io_rec_acct	NUMBER;
  l_io_pay_acct	NUMBER;
  l_io_ppv_acct	NUMBER;
  l_intansit	NUMBER;
  l_snd_uom	VARCHAR2(3);
  l_rcv_uom	VARCHAR2(3);
  l_snd_sob_id	NUMBER;
  l_snd_curr	VARCHAR2(10);
  l_rcv_sob_id	NUMBER;
  l_rcv_curr	VARCHAR2(10);
  l_curr_type	VARCHAR2(30);
  l_conv_rate	NUMBER;
  l_conv_date	DATE;
  l_std_mat_acct	NUMBER;
  l_std_mat_ovhd_acct	NUMBER;
  l_std_res_acct	NUMBER;
  l_std_osp_acct	NUMBER;
  l_std_ovhd_acct	NUMBER;
  l_value	NUMBER;
  l_ppv		NUMBER;
  l_acct	NUMBER;
  l_from_org	NUMBER;
  l_to_org	NUMBER;
  l_from_cost_grp NUMBER;
  l_to_cost_grp NUMBER;
  l_cg_id       NUMBER;
  l_from_layer  NUMBER;
  l_to_layer    NUMBER;
  l_subinv	VARCHAR2(10);
  l_std_from_org NUMBER;
  l_std_to_org	NUMBER;
  l_std_org	NUMBER;
  l_std_exp_acct NUMBER;
  l_std_exp_item NUMBER;
  l_std_exp_sub NUMBER;
  l_snd_qty	NUMBER;
  l_rcv_qty	NUMBER;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_stmt_num	NUMBER;
  l_msg_count           NUMBER;
  l_return_status       VARCHAR2(11);
  l_msg_data            VARCHAR2(2000);
  l_wms_flg             NUMBER;
  process_error	EXCEPTION;
  -- Changes for PJM for Standard Costing
  l_pjm_flg             NUMBER;
  l_debug               VARCHAR2(1);

 --Changes for MOH Absorption
  l_earn_moh    NUMBER;
  moh_rules_error EXCEPTION;

  -- OPM INVCONV umoogala
  l_io_profit_acct  NUMBER;  -- Inter-Org Profit Account
  l_pd_txfr_ind     NUMBER;  -- Process-Discrete Xfer Flag
  -- End OPM INVCONV umoogala

  --
  -- OPM INVCONV umoogala
  -- Bug 5233635; Should not book InterOrg Profit when Intercompany Invoicing is enabled.
  --
  l_io_invoicing          NUMBER;
  l_org_ou                NUMBER;
  l_txf_org_ou            NUMBER;

  l_exp                   NUMBER;
  l_acct_line_type        NUMBER;

  l_inv_ap_accrual_acct   NUMBER; /* Bug#5471471 ANTHIYAG 18-Aug-2006 */

  l_moh_offset_acct       NUMBER; -- Bug 5677953

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_exp_sub := 0;
  l_exp_acct := -1;

  /*Commented for Bug 3460659*/
  /*
  l_std_exp_item := 0;
  l_std_exp_sub  := 0;
  */

  l_std_exp_item := -1; /*Added for Bug 3460659*/
  l_std_exp_sub := -1;  /*Added for Bug 3460659*/

  l_std_exp_acct := -1;
  l_intransit := 0;
  l_subinv := i_subinv;

  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;


    fnd_file.put_line(fnd_file.log,'interorg_cost_txn(..)');
    fnd_file.put_line(fnd_file.log, 'transaction_id:' || i_txn_id);
    fnd_file.put_line(fnd_file.log,'org_id:' || i_org_id);
    fnd_file.put_line(fnd_file.log,'i_txn_org_id:' || i_txn_org_id);
    fnd_file.put_line(fnd_file.log,'i_txf_org_id:' || i_txf_org_id);
    fnd_file.put_line(fnd_file.log,'i_txf_txn_id:' || i_txf_txn_id);
    fnd_file.put_line(fnd_file.log,'i_exp_item:' || i_exp_item);
    fnd_file.put_line(fnd_file.log,'i_fob_point:' || i_fob_point);

    /* OPM INVCONV sschinch check if this is a process discrete transfer */
    SELECT MOD(SUM(DECODE(MP.process_enabled_flag,'Y',1,2)), 2)
      INTO l_pd_txfr_ind
      FROM mtl_parameters mp
     WHERE mp.organization_id = i_txn_org_id
        OR mp.organization_id = i_txf_org_id;

    SELECT      nvl(ap_accrual_account, -1)
    INTO        l_inv_ap_accrual_acct
    FROM        mtl_parameters
    WHERE       organization_id = i_org_id;

    IF l_pd_txfr_ind = 1
    THEN
      --
      -- Bug 5233635; Should not book InterOrg Profit when Intercompany Invoicing is enabled.
      --
      l_stmt_num := 11;

      SELECT to_number(org_information3)
      INTO   l_org_ou
      FROM   hr_organization_information
      WHERE  org_information_context = 'Accounting Information'
      AND    organization_id = i_txn_org_id;

      l_stmt_num := 12;
      SELECT to_number(org_information3)
      INTO   l_txf_org_ou
      FROM   hr_organization_information
      WHERE  org_information_context = 'Accounting Information'
      AND    organization_id = i_txf_org_id;

      l_io_invoicing := to_number(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'));
      fnd_file.put_line(fnd_file.LOG, 'SrcTypeID/ActID = ' || i_src_type_id ||'/'|| i_txn_act_id ||
        ' OU/xferOU: ' || l_org_ou ||'/'|| l_txf_org_ou ||
        ' Internal Order invoicing: ' || l_io_invoicing);

    END IF;
    --
    -- End Bug 5233635
    --
  -- First figure out expense item flags
  l_stmt_num := 5;
  if (i_exp_item = 1) then
    select nvl(expense_account, -1)
    into l_exp_acct
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = i_org_id;
  end if;

  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,i_org_id)) then
     l_wms_flg := 1;
  else
     l_wms_flg := 0;
  end if;


  -- Figure out sending and receiving expense subs.
  l_stmt_num := 10;

  if (i_org_id = i_txn_org_id) then
    --
    -- umoogala  Bug 4864821  INVCONV: process/discrete xfer enh.
    -- Added the following IF condition since for logical intransit receipt (action_id 15)
    -- SubInv could be null. In this case we'll consider this as asset sub.
    --
    if l_subinv is null
    then
      l_exp_sub := 0;

    else
      select decode(asset_inventory,1,0,1)
      into l_exp_sub
      from mtl_secondary_inventories
      where secondary_inventory_name = l_subinv
      and organization_id = i_org_id;

      if (l_wms_flg = 0) then
         select nvl(expense_account, l_exp_acct)
         into l_exp_acct
         from mtl_secondary_inventories
         where secondary_inventory_name = l_subinv
         and organization_id = i_org_id;
      else
         if (i_cost_grp_id = 1) then
           /* Need to change cst_avg_dist_accts_v to include expense_account */
           select nvl(expense_account,l_exp_acct)
           into l_exp_acct
           from mtl_parameters
           where  organization_id = i_org_id;
         else
           select nvl(expense_account, l_exp_acct)
           into l_exp_acct
           from cst_cost_group_accounts
           where cost_group_id = i_cost_grp_id
           and organization_id = i_org_id;
         end if;
      end if;
    end if;
  end if;

  /********************************************************************
   ** Figure out some local variables:  			     **
   ** 1) l_snd_rcv flag to determine if this is a sending or         **
   **    receiving transaction.					     **
   ** 2) l_from_org and l_to_org 				     **
   ** 3) l_snd_qty and l_rcv_qty				     **
   ** 4) set of books id and currency for sending and receiving org  **
   ** 5) interorg accounts					     **
   ** 6) Figure out if stardard org distribution is requried and if  **
   **    so, get stardard org accts.                                 **
   ********************************************************************/

  --
  -- Figure out the send/receiving flag. 1 is send and 2 is recv.
  -- OPM INVCONV umoogala: Added 15 (Logical Itr Receipt) and 22 (Logical Itr Shipment) actions.
  --
  if ((i_txn_act_id = 3 and i_txn_qty <0) or
      (i_txn_act_id = 21 and i_org_id = i_txn_org_id) or
      (i_txn_act_id = 12 and i_org_id = i_txf_org_id) or
      (i_txn_act_id = 22 and i_org_id = i_txn_org_id)) then  -- OPM INVCONV umoogala
    l_snd_rcv := 1;
  elsif ((i_txn_act_id = 3 and i_txn_qty > 0) or
         (i_txn_act_id = 21 and i_org_id = i_txf_org_id) or
         (i_txn_act_id = 12 and i_org_id = i_txn_org_id) or
         (i_txn_act_id = 15 and i_org_id = i_txn_org_id)) then  -- OPM INVCONV umoogala
    l_snd_rcv := 2;
  end if;

    fnd_file.put_line(fnd_file.log,'l_snd_rcv:' || l_snd_rcv);


  if (l_snd_rcv = 1) then
    if (i_org_id = i_txn_org_id or i_txn_act_id = 3) then
      l_from_org := i_txn_org_id;
      l_to_org := i_txf_org_id;
      l_from_cost_grp := i_cost_grp_id;
      l_to_cost_grp := i_txfr_cost_grp;
      --
      -- Start Bug 5702988
      -- This is Logical Intransit Shipment. Assume it as as asset sub.
      --
      if i_txn_act_id = 22
      then
        l_exp_sub := 0;
        l_subinv := NULL;
      end if;
      -- End Bug 5702988
    else
      l_from_org := i_txf_org_id;
      l_to_org := i_txn_org_id;
      l_from_cost_grp := i_txfr_cost_grp;
      l_to_cost_grp := i_cost_grp_id;
      -- if the header is not for my org, then don't know subinventory.
      -- Assume asset.
      l_exp_sub := 0;
      l_subinv := NULL;
    end if;
  elsif (l_snd_rcv = 2) then
    if (i_org_id = i_txn_org_id or i_txn_act_id = 3) then
      l_from_org := i_txf_org_id;
      l_to_org := i_txn_org_id;
      l_from_cost_grp := i_txfr_cost_grp;
      l_to_cost_grp := i_cost_grp_id;
      --
      -- Start Bug 5702988
      -- This is Logical Intransit Receipt. Assume it as as asset sub.
      --
      if i_txn_act_id = 15
      then
        l_exp_sub := 0;
        l_subinv := NULL;
      end if;
      -- End Bug 5702988
    else
      l_from_org := i_txn_org_id;
      l_to_org := i_txf_org_id;
      l_from_cost_grp := i_cost_grp_id;
      l_to_cost_grp := i_txfr_cost_grp;
      -- if the header is not for my org, then don't know subinventory.
      -- Assume asset.
      l_exp_sub := 0;
      l_subinv := NULL;
    end if;
  end if;

    fnd_file.put_line(fnd_file.log,'l_from_org:' || l_from_org);
    fnd_file.put_line(fnd_file.log,'l_to_org:' || l_to_org);



  CSTPAVCP.get_snd_rcv_rate(i_txn_id, l_from_org, l_to_org,
		l_snd_sob_id, l_snd_curr, l_rcv_sob_id, l_rcv_curr,
		l_curr_type, l_conv_rate, l_conv_date,
		l_err_num, l_err_code, l_err_msg);

  if (l_err_num<>0) then
    raise process_error;
  end if;

  CSTPAVCP.get_snd_rcv_uom(i_item_id, l_from_org, l_to_org, l_snd_uom, l_rcv_uom,
		  l_err_num, l_err_code, l_err_msg);

  if (l_from_org = i_txn_org_id) then
    l_snd_qty := i_txn_qty;
    l_rcv_qty := inv_convert.inv_um_convert
				(i_item_id, NULL, -1 * l_snd_qty,
			  	 l_snd_uom, l_rcv_uom, NULL, NULL);
  else
    l_rcv_qty :=i_txn_qty;
    l_snd_qty := inv_convert.inv_um_convert
				(i_item_id, NULL, -1 * l_rcv_qty,
			  	 l_rcv_uom, l_snd_uom, NULL, NULL);
  end if;

  if (l_err_num<>0) then
    raise process_error;
  end if;


  -- Figure out accts.

  l_stmt_num := 30;

  -- Modified for fob stamping project

  -- OPM INVCONV umoogala: added new column interorg_profit_account
  -- for process-discrete transfers
  select nvl(MMT.intransit_account, MIP.intransit_inv_account),
	MIP.interorg_transfer_cr_account,
	MIP.interorg_receivables_account,
	MIP.interorg_payables_account,
	MIP.interorg_price_var_account,
  MIP.interorg_profit_account  -- OPM INVCONV umoogala
  into
	l_io_inv_acct,
	l_io_txfr_acct,
	l_io_rec_acct,
	l_io_pay_acct,
	l_io_ppv_acct,
  l_io_profit_acct  -- OPM INVCONV umoogala
  from mtl_interorg_parameters MIP, mtl_material_transactions MMT
  where MIP.from_organization_id = l_from_org
  and MIP.to_organization_id = l_to_org
  and MMT.transaction_id = i_txn_id;

  -- Standard org computation
  l_std_from_org := CSTPAVCP.standard_cost_org(l_from_org);
  l_std_to_org := CSTPAVCP.standard_cost_org(l_to_org);

  l_stmt_num := 40;

  /* Bug 2926258 - changed default to -1 to support org_id=0 */
  select decode(l_std_from_org, 1, l_from_org,
                decode(l_std_to_org,1,l_to_org,-1))
  into l_std_org
  from dual;

  -- For direct interorg transfers, we only care about the transction org id.
  --
  -- OPM INVCONV umoogala: For process-discrete xfer, txn_org will always be
  -- standard costing org. Transfer to standard costing org will be processed
  -- by standard cost worker.
  --
  if ((i_txn_act_id = 3 and i_txn_org_id = i_org_id) OR
      (l_pd_txfr_ind = 1))  -- OPM INVCONV umoogala
  then
    l_std_org := -1;  /* Bug 2926258 */
  end if;

  /* Bug 2926258 - changed default to -1 to support org_id=0 */
  if (l_std_org <> -1) then
    l_stmt_num := 45;
    select decode(inventory_asset_flag, 'Y', 0,1), nvl(expense_account, -1)
    into l_std_exp_item, l_std_exp_acct
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = l_std_org;

    -- if the standard org is the transaction org id then need to find out
    -- expense sub flag and inventory accounts.  Otherwise we use intransit
    -- accounts.

    if (l_std_org = i_txn_org_id) then

      if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,l_std_org)) then
          l_wms_flg := 1;
      else
          l_wms_flg := 0;
      end if;

      /* Changes for PJM for Standard costing */
      l_stmt_num := 47;
      SELECT decode(nvl(cost_group_accounting,0),0,0,
             decode(nvl(project_reference_enabled,0),1,1,0))
      INTO l_pjm_flg
      FROM MTL_PARAMETERS
      WHERE organization_id = l_std_org;

      l_stmt_num := 50;
      l_subinv :=  i_subinv;

      select decode(asset_inventory,1,0,1)
      into l_std_exp_sub
      from mtl_secondary_inventories msi
      where msi.organization_id = l_std_org
      and secondary_inventory_name = l_subinv;

      /* Changes for PJM for Standard Costing */
      if (l_wms_flg = 0 AND l_pjm_flg = 0) then
         select material_account, material_overhead_account, resource_account,
                outside_processing_account, overhead_account,
                nvl(expense_account, l_std_exp_acct)
         into   l_std_mat_acct, l_std_mat_ovhd_acct, l_std_res_acct,
                l_std_osp_acct, l_std_ovhd_acct,
                l_std_exp_acct
         from mtl_secondary_inventories msi
         where msi.organization_id = l_std_org
         and secondary_inventory_name = l_subinv;
      else
         select decode(l_std_org,l_from_org,l_from_cost_grp,l_to_cost_grp)
         into l_cg_id
         from dual;

         if (l_cg_id = 1) then
            select material_account, material_overhead_account, resource_account,
                 outside_processing_account, overhead_account,
                 nvl(expense_account, l_std_exp_acct)
            into l_std_mat_acct, l_std_mat_ovhd_acct, l_std_res_acct,
                 l_std_osp_acct, l_std_ovhd_acct,
                 l_std_exp_acct
            from   mtl_parameters
            where  organization_id = l_std_org;
         else
            select material_account, material_overhead_account, resource_account,
                outside_processing_account, overhead_account,
                nvl(expense_account, l_std_exp_acct)
            into   l_std_mat_acct, l_std_mat_ovhd_acct, l_std_res_acct,
                l_std_osp_acct, l_std_ovhd_acct,
                l_std_exp_acct
            from cst_cost_group_accounts
            where organization_id = l_std_org
            and cost_group_id = l_cg_id;
         end if;
      end if;
    end if;
  end if;

  /*******************************************************************
   ** Do sending org distribution 				    **
   *******************************************************************/
     fnd_file.put_line(fnd_file.log,'Sending org distributions');

  if (l_from_org = i_org_id) and (i_txn_act_id = 22)  -- OPM INVCONV  umoogala
  then
    /* INVCONV Bug#5476804 ANTHIYAG 21-Aug-2006 Start */
    /***********************************************************************************************
    * When the Intercompany Invoicing is disabled for a Expense Item, the Receivables and          *
    * Inter-Org profit accounts need to be booked, Otherwise if Intercompany Invoicing is enabled  *
    * for a Expense Item, No need for creating any bookings at all                                 *
    ***********************************************************************************************/
    IF  i_exp_item = 1 AND l_pd_txfr_ind = 1 AND nvl(l_io_invoicing,2) = 1 AND i_src_type_id = 8 AND l_org_ou <> l_txf_org_ou THEN /* INVCONV Bug#5498133/5498041 ANTHIYAG 30-Aug-2006 */
      fnd_file.put_line(fnd_file.log, 'Process/Discrete Xfer: No bookings will be created, since this is an Expense item and Invoicing is enabled');
      RETURN;
    END IF;
    /* INVCONV Bug#5476804 ANTHIYAG 21-Aug-2006 End */
     --
     -- OPM INVCONV umooogala
     -- Logical Intransit Shipment: new txn type introduced for process-discrete
     -- transfers enh to book intransit entries.
     --
    /* Book Intransit, Inter org receivables,freight expense,Transfer variance */

    /* Credit Freight Expense */
    if (i_trp_cost <> 0)
    then
	  -- shipping txn, trp_cost
	  l_value := i_trp_cost;

	l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, -1, 12,
			    NULL, NULL, l_subinv,0, l_snd_rcv,
			    l_err_num, l_err_code, l_err_msg,NULL);

	if (l_err_num <> 0) then
	  raise process_error;
	end if;

	if (l_acct = -1) then
	  l_acct := i_trp_acct;
	end if;

	fnd_file.put_line(fnd_file.log,'Freight account: ' || l_value);

	insert_account(l_from_org, i_txn_id, i_item_id, -1*l_value,
		      l_snd_qty, l_acct, l_snd_sob_id, 12, NULL, NULL,
		      i_txn_date, i_txn_src_id, i_src_type_id,
		      l_snd_curr, NULL, NULL, NULL, NULL,1,
		      i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
		      l_err_num, l_err_code, l_err_msg);

	if (l_err_num <> 0) then
	  raise process_error;
	end if;
    end if;

    /* Debit sending org Receivables. */
    l_stmt_num := 60;

    --
    -- Bug 5346202: InterOrg Receivables at Transfer Price only.
    -- Freight should not be added.
    -- l_value := i_trp_cost + (i_txf_price * l_snd_qty);
    --
    l_value := i_txf_price * l_snd_qty;

    fnd_file.put_line(fnd_file.log,'Receivables amount: ' || l_value);

    l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, 1, 10,
                        NULL, NULL, l_subinv,0, l_snd_rcv,
                        l_err_num, l_err_code, l_err_msg,NULL);

    if (l_err_num <> 0) then
      raise process_error;
    end if;

    if (l_acct = -1) then
      l_acct := l_io_rec_acct;
    end if;

    /*  use -1*l_snd_qty */
    insert_account(l_from_org, i_txn_id, i_item_id,  l_value,
                  -1 * l_snd_qty, l_acct, l_snd_sob_id, 10, NULL, NULL,
                  i_txn_date, i_txn_src_id, i_src_type_id,
                  l_snd_curr, NULL, NULL, NULL, NULL,1,
                  i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                  l_err_num, l_err_code, l_err_msg);

    if (l_err_num <> 0) then
      raise process_error;
    end if;

    /* Book intransit accounts */
    --
    -- Bug 5332813: Process/Discrete Xfer
    -- Do not post zero entry for expense item.
    --
    if i_exp_item = 0
    then

      fnd_file.put_line(fnd_file.log,'Intransit account: with item cost' );

      /*
       --
       -- Bug 4900652
       -- Book intransit with item cost
       --
      distribute_accounts(l_from_org,i_txn_id,0,i_cost_grp_id,i_txn_act_id,
                          i_item_id, l_snd_qty, 14,
                          1, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
                          l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                          l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
                          i_user_id, i_login_id, i_prg_appl_id, i_prg_id, i_req_id,
                          l_err_num, l_err_code, l_err_msg);
      */

      /* Credit Sending Org' intransit. */
      l_intransit := 1;
      inventory_accounts(l_from_org, i_txn_id, 2, i_txn_act_id, i_cost_grp_id,
          	       i_item_id, -1 * l_snd_qty,
          	       l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
          	       i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
          	       l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
          	       i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
          	       l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

    end if;

    --
    -- Bug 5233635: Should not book InterOrg Profit If Intercompany Invoicing is enabled.
    -- Following flag is set at the beginning of the procedure.
    -- Bug 5345102: incorrect variables i_txn_src_id was used instead of using i_src_type_id
    --
    if  (i_src_type_id = 8)
    and (l_org_ou <> l_txf_org_ou)
    and (l_io_invoicing = 1)
    and (i_txn_act_id = 21) -- Bug 5351724
    and (i_exp_item = 1)    -- Bug 5348953: No IC Invoicing for expense items
    then
      NULL;
      fnd_file.put_line(fnd_file.log, 'No need to book InterOrg Profit since InterCompany Invoicing ' ||
        'is enabled.');
    else
      /* Book InterOrg profit  */
      SELECT SUM(NVL(base_transaction_value,0))
       INTO l_value
       FROM mtl_transaction_accounts
      WHERE transaction_id       = i_txn_id
        AND organization_id      = l_from_org
      ;

       fnd_file.put_line(fnd_file.log,'InterOrg Profit amount: ' || l_value);

      l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, 1, 34,
                           NULL, NULL, l_subinv,0, l_snd_rcv,
                           l_err_num, l_err_code, l_err_msg,NULL);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := l_io_profit_acct;
      end if;


      insert_account(l_from_org, i_txn_id, i_item_id, -1 * l_value,
                     l_snd_qty, l_acct, l_snd_sob_id,
                     G_INTERORG_PROFIT_ACCT, NULL, NULL,
                     i_txn_date, i_txn_src_id, i_src_type_id,
                     l_snd_curr, NULL, NULL, NULL, NULL,1,
                     i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                     l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

    end if;

  /* END OPM INVCONV sschinch/umoogala */

  elsif ((l_from_org = i_org_id and
      (i_txn_act_id <> 3 or (i_txn_act_id = 3 and l_from_org = i_txn_org_id))) or
      (l_from_org = l_std_org)) then

    /* sending org distribution */
    -- Set intransit flag. Intransit account is used when FOB is receipt.
    -- for bug 774662, if txn is direct interorg transfer don't set l_intransit
    --
    -- OPM INVCONV umoogala/sschinch
    if (l_pd_txfr_ind = 0)
    then
      -- NOT a process-discrete xfer
      if (i_fob_point = 2) and (i_txn_act_id <>3) then
        l_intransit := 1;
      else
        l_intransit := 0;
      end if;
    else
      --
      -- OPM INVCONV umoogala/sschinch  process-discrete xfer
      -- Intransit entries are booked by new logical intranshit shipment (22)
      -- logical intransit receipt (15)
      -- On the process org side distributions done using SLA.
      --
      l_intransit := 0;
    end if;

    -- First do the distributions for ownership change
    if ((i_txn_act_id = 3 and i_txn_qty < 0) or
	(i_txn_act_id = 21 and i_fob_point = 1) or
	(i_txn_act_id = 12 and i_fob_point = 2)) then
      if ((l_from_org = i_org_id) and (i_exp_item = 0)) then /* Avg Costing */
        /* Credit inventory at sending org's cost */
        inventory_accounts(l_from_org, i_txn_id,2,i_txn_act_id,l_from_cost_grp,
			i_item_id, l_snd_qty,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
			l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

     elsif ((l_from_org = i_org_id) and (i_exp_item = 1)) then /* Avg Costing for expense item*/
       /* Credit sending organization's expense account */

       --
       -- Bug 5348953: Process/Discrete Xfers
       -- For these transfers, do not book to expense account.
       -- Receivalbes and InterOrg Profit Accounts will get booked
       --
       if l_pd_txfr_ind = 1
       then
        /* INVCONV Bug#5465239 ANTHIYAG 18-Aug-2006 Start */
        /***********************************************************************************************
        * When the Intercompany Invoicing is disabled for a Expense Item, the Receivables and          *
        * Inter-Org profit accounts need to be booked, Otherwise if Intercompany Invoicing is enabled  *
        * for a Expense Item, No need for creating any bookings at all                                 *
        ***********************************************************************************************/

         IF nvl(l_io_invoicing,2) = 1 AND i_src_type_id IN (7, 8) AND l_org_ou <> l_txf_org_ou THEN /* INVCONV Bug#5498133/5498041 ANTHIYAG 30-Aug-2006 */
           fnd_file.put_line(fnd_file.log, 'Process/Discrete Xfer: No bookings will be created, since this is a Expense item and Invoicing is enabled');
           RETURN;
         ELSE
	         fnd_file.put_line(fnd_file.log, 'Process/Discrete Xfer: Not booking to expense. Receivables and InterOrg Profit Accounts will get booked');
         END IF;
         /* INVCONV Bug#5465239 ANTHIYAG 18-Aug-2006 End */
       else
         distribute_accounts(l_from_org, i_txn_id,
                     0,i_cost_grp_id,i_txn_act_id,
                     i_item_id, l_snd_qty, 2,
                     0, 0, l_exp_acct, NULL, NULL, NULL, NULL,NULL,
                     l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                     l_subinv, l_snd_rcv, l_snd_curr,
                     NULL, NULL, NULL, NULL,
                     i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                     l_err_num, l_err_code, l_err_msg);

         if (l_err_num <> 0) then
           raise process_error;
         end if;
       end if;

     elsif (l_std_exp_item = 0) then /* Std Costing Org */
        if (l_intransit = 1) then
          distribute_accounts(l_from_org,i_txn_id,0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_snd_qty, 14,
			0, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

	else
          if (l_std_exp_sub = 1) then
          distribute_accounts(l_from_org,i_txn_id,0,i_cost_grp_id,i_txn_act_id,
		        i_item_id, l_snd_qty, 2,
			0, 0, l_std_exp_acct, NULL, NULL, NULL, NULL,NULL,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

	  else
            distribute_accounts(l_from_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
		        i_item_id, l_snd_qty, 1,
			1, 0, NULL, l_std_mat_acct, l_std_mat_ovhd_acct,
			l_std_res_acct, l_std_osp_acct, l_std_ovhd_acct,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

	  end if;
	end if;
      end if;

--check txf cost< 0
      if (i_txf_cost <> 0) then
        --l_value := i_txf_cost; /* Comment out for bug 2827548 and add the following */
        if (i_txn_act_id = 12 and i_fob_point = 2) then
          -- receipt txn, txf_cost is in rec org's currency so need to convert back
          l_value := i_txf_cost / l_conv_rate;
        else
          l_value := i_txf_cost;
        end if;

        fnd_file.put_line(fnd_file.log,'Transfer Credit account: ' || l_value);

        /* Credit sending org transfer credit */
        l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, -1, 11,
					NULL, NULL, l_subinv,0, l_snd_rcv,
					l_err_num, l_err_code, l_err_msg,NULL);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
	  l_acct := l_io_txfr_acct;
        end if;

        insert_account(l_from_org, i_txn_id, i_item_id, -1 * l_value,
			l_snd_qty, l_acct, l_snd_sob_id, 11, NULL, NULL,
			i_txn_date, i_txn_src_id, i_src_type_id,
			l_snd_curr, NULL, NULL, NULL, NULL,1,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

      end if;

      --
      -- OPM INVCONV umoogala/sschinch Process-Discrete Xfer Enh.
      -- book friegt expense only for direct transfer in case
      -- of process discrete transfer. For other cases, it is done during intransit
      -- entries using new Logical Txns (action_id = 15, 22)
      --
      if ((i_trp_cost <> 0) and
          ((i_fob_point = 2 and l_pd_txfr_ind = 0) or  -- OPM INVCONV
           (i_txn_act_id = 3)
          ))
      then
        --l_value := i_trp_cost; /* Comment out for bug 2827548 and add the following */
        if (i_txn_act_id = 12 and i_fob_point = 2) then
          -- receipt txn, trp_cost is in rec org's currency so need to convert back
          l_value := i_trp_cost / l_conv_rate;
        else
          l_value := i_trp_cost;
        end if;

        fnd_file.put_line(fnd_file.log,'Freight account: ' || l_value);

        l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, -1, 12,
  					NULL, NULL, l_subinv,0, l_snd_rcv,
					l_err_num, l_err_code, l_err_msg,NULL);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
	  l_acct := i_trp_acct;
        end if;

        insert_account(l_from_org, i_txn_id, i_item_id, -1 * l_value,
			l_snd_qty, l_acct, l_snd_sob_id, 12, NULL, NULL,
			i_txn_date, i_txn_src_id, i_src_type_id,
			l_snd_curr, NULL, NULL, NULL, NULL,1,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

      end if;

      /* Debit sending org Receivables. */

      --
      -- OPM INVCONV umoogala/sschinch  Process-Discrete Xfers Enh.
      -- For p-d xfers, book Inter org receivables (IOR) only in case of direct
      -- transfers and intransit shipment with fob shipping.
      --
      if ((i_txn_act_id = 3 and l_pd_txfr_ind = 1) or
          (i_txn_act_id = 21 and i_fob_point = 1 and l_pd_txfr_ind = 1) or
          (l_pd_txfr_ind = 0)) then

        l_stmt_num := 60;

        --
        -- OPM INVCONV umoogala/sschinch
        -- For process-discrete transfers book IOR with transfer_price
        -- which is stamped on mmt row
        --
        if (l_pd_txfr_ind = 0)
        then
          select nvl(sum(base_transaction_value),0)
          into l_value
          from mtl_transaction_accounts
          where transaction_id = i_txn_id
          and organization_id = l_from_org;
        else
          l_value := i_txf_price * l_snd_qty;  -- OPM INVCONV umoogala/sschinch
        end if;

        fnd_file.put_line(fnd_file.log,'receivables account: ' || l_value);

        l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, 1, 10,
                                          NULL, NULL, l_subinv,0, l_snd_rcv,
                                          l_err_num, l_err_code, l_err_msg,NULL);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
          l_acct := l_io_rec_acct;
        end if;

        /* Bug 3169767: use -1*l_snd_qty */
        insert_account(l_from_org, i_txn_id, i_item_id, -1 * l_value,
                          -1 * l_snd_qty, l_acct, l_snd_sob_id, 10, NULL, NULL,
                          i_txn_date, i_txn_src_id, i_src_type_id,
                          l_snd_curr, NULL, NULL, NULL, NULL,1,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;
      end if; -- OPM INVCONV umoogala/sschinch

      --
      -- OPM INVCONV umoogala/sschinch
      -- Again for p-d xfers, book InterOrg profit for direct transfers and
      -- Intransit Shipment with FOB Shipping.
      -- InterOrg profit is a new account introduced for this project on
      -- shipping networks form under transfer price tab.
      --
      IF ((l_pd_txfr_ind = 1 and i_txn_act_id = 3) OR
          (l_pd_txfr_ind = 1 and i_txn_act_id = 21 and i_fob_point = 1))
      THEN

        --
        -- Bug 5233635: Should not book InterOrg Profit If Intercompany Invoicing is enabled.
	-- Following flag is set at the beginning of the procedure.
        --
        IF  (i_src_type_id = 8)
	AND (l_org_ou <> l_txf_org_ou)
        AND (l_io_invoicing = 1)
        AND (i_txn_act_id = 21) -- Bug 5351724
	AND (i_exp_item = 0)    -- Bug 5348953: No IC Invoicing for expense items
        THEN
          NULL;
          fnd_file.put_line(fnd_file.log, 'No need to book InterOrg Profit since InterCompany Invoicing ' ||
            'is enabled.');
        ELSE

          /* Book interorg profit  */
          SELECT SUM(NVL(base_transaction_value,0))
            INTO l_value
            FROM mtl_transaction_accounts
           WHERE transaction_id       = i_txn_id
             AND organization_id      = l_from_org
          ;

          fnd_file.put_line(fnd_file.log,'InterOrg profit account: ' || l_value);

          l_acct := CSTPACHK.get_account_id(l_from_org, i_txn_id, 1,
                                            G_INTERORG_PROFIT_ACCT,
                                            NULL, NULL, l_subinv,0, l_snd_rcv,
                                            l_err_num, l_err_code, l_err_msg,NULL);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

          if (l_acct = -1) then
            l_acct := l_io_profit_acct;
          end if;

          insert_account(l_from_org, i_txn_id, i_item_id, -1 * l_value,
                          -1 * l_snd_qty, l_acct, l_snd_sob_id,
                          G_INTERORG_PROFIT_ACCT, NULL, NULL,
                          i_txn_date, i_txn_src_id, i_src_type_id,
                          l_snd_curr, NULL, NULL, NULL, NULL,1,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;
        END IF;

      END IF;
      -- End OPM INVCONV umoogala

    elsif (i_txn_act_id = 21 and i_fob_point = 2) then
      /* Sending org, no ownership change. */
      if ((l_from_org = i_org_id) and (i_exp_item = 0)) then /* Average cost org */
        /* Credit inventory at sending org's cost */
        l_intransit := 0;
        inventory_accounts(l_from_org, i_txn_id,2,i_txn_act_id,l_from_cost_grp,
			i_item_id, l_snd_qty,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
			l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;


        /* Debit Sending Org' intransit. */
        l_intransit := 1;
        inventory_accounts(l_from_org, i_txn_id,2,
		        i_txn_act_id,l_to_cost_grp,
			i_item_id, -1 * l_snd_qty,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
			l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

      elsif ((l_std_exp_item = 0) and (i_exp_item = 0)) then  /* Standard cost org */
        /* Credit inventory at sending org's cost */
        if (l_std_exp_sub = 1) then
          distribute_accounts(l_from_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_snd_qty, 2,
			0, 0, l_std_exp_acct, NULL, NULL, NULL, NULL,NULL,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

	else
          distribute_accounts(l_from_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_snd_qty, 1,
			1, 0, NULL, l_std_mat_acct, l_std_mat_ovhd_acct,
			l_std_res_acct, l_std_osp_acct, l_std_ovhd_acct,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

	end if;

        /* Debit Sending Org' intransit. */
        distribute_accounts(l_from_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, -1 * l_snd_qty, 14,
			0, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
			l_snd_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_snd_curr, NULL, NULL, NULL, NULL,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

      end if;
    end if;

  end if;  -- Sending org distribution

  /*******************************************************************
   ** Do receiving org distribution 				    **
   *******************************************************************/
  fnd_file.put_line(fnd_file.log,'Receiving org distributions');

  /* Begin OPM INVCONV sschinch  Logical Intransit Receipt FOB Shipping*/
  if (i_txn_act_id = 15)
  then
     --
     -- OPM INVCONV umooogala
     -- Logical Intransit Receipt: new txn type introduced for process-discrete
     -- transfers enh to book intransit entries.
     --

    --
    -- Dr Intransit
    -- Amount should be (transfer_price + freight)
    -- actual_cost in mcacd is (transfer_price + freight)
    --
    fnd_file.put_line(fnd_file.log,'Dr intransit account @ org cost');

    /* Dr Receiving Org's intransit. */
    l_intransit := 1;

    /*
     * Bug 5400954: Intransit Account is getting Debited.
     * Fix: Replaced following call with inventory_accounts call.
    distribute_accounts(l_to_org, i_txn_id,
                        0,i_cost_grp_id,i_txn_act_id,
                        i_item_id, -1*l_rcv_qty, 14,
                        0, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
                        l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                        l_subinv, l_snd_rcv, l_rcv_curr,
                        null, null, null, null,
                        i_user_id, i_login_id, i_prg_appl_id, i_prg_id, i_req_id,
                        l_err_num, l_err_code, l_err_msg);

    */
    inventory_accounts(l_to_org, i_txn_id,2,i_txn_act_id,i_cost_grp_id,
                    i_item_id, l_rcv_qty,
                    l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                    i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
                    l_snd_rcv, l_rcv_curr, l_snd_curr,                          /* INVCONV Bug#5462346/5462244 ANTHIYAG 22-Aug-2006 */
                    l_conv_date, l_conv_rate, l_curr_type,                      /* INVCONV Bug#5462346/5462244 ANTHIYAG 22-Aug-2006 */
                    i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                    l_err_num, l_err_code, l_err_msg);

    if (l_err_num <> 0) then
      raise process_error;
    end if;

    --
    -- Cr InterOrg Payables with transfer price.
    --
    l_value := i_txf_price * l_rcv_qty;

    fnd_file.put_line(fnd_file.log,'Cr payable. amount(l_value):' || -1 * l_value);

    /* INVCONV Bug#5471471 ANTHIYAG 18-Aug-2006 Start */
    /************************************************************************************
    * If Intercompany invoicing is enabled, then the booking should be made against the *
    * Inventory AP Accrual account rather than the Inter-Org Payables Account           *
    ************************************************************************************/

    IF nvl(l_io_invoicing, 2) =  1 AND i_src_type_id = 7 AND l_org_ou <> l_txf_org_ou THEN /* INVCONV Bug#5498133/5498041 ANTHIYAG 30-Aug-2006 */
      l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 2,
                          NULL, NULL, l_subinv,0, l_snd_rcv,
                          l_err_num, l_err_code, l_err_msg,NULL);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := l_inv_ap_accrual_acct;
      end if;

      insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                    -1 * l_rcv_qty, l_acct, l_rcv_sob_id, 2, NULL, NULL,
                    i_txn_date, i_txn_src_id, i_src_type_id,
                    l_rcv_curr, l_snd_curr,
                    l_conv_date, l_conv_rate, l_curr_type,1,
                    i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                    l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

    ELSE
      /* INVCONV Bug#5471471 ANTHIYAG 18-Aug-2006 End */

      l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 9,
                          NULL, NULL, l_subinv,0, l_snd_rcv,
                          l_err_num, l_err_code, l_err_msg,NULL);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := l_io_pay_acct;
      end if;

      insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                    -1 * l_rcv_qty, l_acct, l_rcv_sob_id, 9, NULL, NULL,
                    i_txn_date, i_txn_src_id, i_src_type_id,
                    l_rcv_curr, l_snd_curr,
                    l_conv_date, l_conv_rate, l_curr_type,1,
                    i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                    l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;
    END IF;

    --
    -- Cr Inter-org freight charge
    --
    if (i_trp_cost <> 0) then

      l_value := i_trp_cost;

      l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 12,
                          NULL, NULL, l_subinv,0, l_snd_rcv,
                        l_err_num, l_err_code, l_err_msg,NULL);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := i_trp_acct;
      end if;

      fnd_file.put_line(fnd_file.log,'Cr Freight. amount(l_value):' || -1 * l_value);
      insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                    l_rcv_qty, l_acct, l_rcv_sob_id, 12, NULL, NULL,
                    i_txn_date, i_txn_src_id, i_src_type_id,
                    l_rcv_curr, l_snd_curr,
                    l_conv_date, l_conv_rate, l_curr_type,1,
                    i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                    l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

    end if;


    --
    -- Bug 5021305
    -- Overhead Absorption.
    --
    if (l_exp_sub = 0 and i_exp_item = 0)
    then

      if(l_earn_moh <>  0)
      then
        ovhd_accounts(l_to_org, i_txn_id, i_item_id, -1 * l_rcv_qty, l_rcv_sob_id,
                      i_txn_date, i_txn_src_id, i_src_type_id, l_subinv,
                      l_snd_rcv, l_rcv_curr,
                      l_snd_curr, l_conv_date, l_conv_rate, l_curr_type,
                      i_user_id, i_login_id, i_prg_appl_id, i_prg_id, i_req_id,
                      l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0)
        then
          raise process_error;
        end if;

     end if;
    end if;
    --
    -- End Bug 5021305
    -- Overhead Absorption.
/*
    -- ??? do we need all this? I think this is only for std orgs, right?
    select nvl(sum(mctcd.transaction_cost),0)
      into l_ppv
      from mtl_cst_txn_cost_details mctcd
     where mctcd.transaction_id = i_txn_id
       and mctcd.organization_id = l_std_org
    ;

    fnd_file.put_line(fnd_file.log,'ppv:' || l_ppv);

    l_stmt_num := 90;

    -- If MOH Absorption is overridden, the this level moh costs have to be driven to ppv.
    -- Also modified code so only this level moh is absorbed. bug 2277950

    -- Changes for MOH Absorption Rules engine
    cst_mohRules_pub.apply_moh(
                            1.0,
                            p_organization_id => l_std_org,
                            p_earn_moh =>l_earn_moh,
                            p_txn_id => i_txn_id,
                            p_item_id => i_item_id,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data);

    IF l_return_status <> FND_API.g_ret_sts_success
    THEN
       CST_UTILITY_PUB.writelogmessages
                        ( p_api_version   => 1.0,
                          p_msg_count     => l_msg_count,
                          p_msg_data      => l_msg_data,
                          x_return_status => l_return_status);
       RAISE moh_rules_error;
    END IF;

    l_stmt_num := 95;

    IF (l_earn_moh = 0)
    THEN
      select l_ppv -  nvl(sum(mcacd.actual_cost),0)
      into l_ppv
      from mtl_cst_actual_cost_details mcacd
      where mcacd.transaction_id = i_txn_id
      and mcacd.organization_id = l_std_org;

    ELSE
      select l_ppv - nvl(sum(mcacd.actual_cost),0)
      into l_ppv
      from mtl_cst_actual_cost_details mcacd
      where mcacd.transaction_id = i_txn_id
      and mcacd.organization_id = l_std_org
      and not (cost_element_id =  2
      and level_type = 1);
      -- Earn only this level MOH
    END IF;

    fnd_file.put_line(fnd_file.log,'ppv:' || l_ppv);


    -- Changes for PJM for Standard Costing
    l_stmt_num := 95;
    update mtl_material_transactions
       set variance_amount = l_ppv * abs(l_rcv_qty)
     where transaction_id = i_txn_id
       and organization_id = l_std_org;

    if (l_ppv <> 0)
    then
      l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, sign(l_ppv), 6,
                          NULL, NULL, l_subinv,0, l_snd_rcv,
                          l_err_num, l_err_code, l_err_msg,NULL);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := l_io_ppv_acct;
      end if;

      -- change l_from_org to l_std_org so PPV from std org will be used
      insert_account(l_std_org, i_txn_id, i_item_id,
                    l_ppv * abs(l_rcv_qty),
                    l_rcv_qty, l_acct, l_rcv_sob_id, 6, NULL, NULL,
                    i_txn_date, i_txn_src_id, i_src_type_id,
                    l_rcv_curr, l_snd_curr, l_conv_date, l_conv_rate,
                    l_curr_type,1,
                    i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                    l_err_num, l_err_code, l_err_msg);

      if (l_err_num <> 0) then
        raise process_error;
      end if;

    end if;

*/
    /* End OPM INVCONV umoogala/sschinch */

  elsif ((l_to_org = i_org_id) or (l_to_org = l_std_org))
  then
    -- Set intransit flag. Intransit account is used when FOB is shipment.
    -- for bug 774662, if it is direct interorg transfer, don't set intransit to 1
    if (i_fob_point = 1) and (i_txn_act_id <> 3)then
      l_intransit := 1;
    else
      l_intransit := 0;
    end if;

    fnd_file.put_line(fnd_file.log,'l_intransit:' || l_intransit);


    -- First do the distributions for ownership change
    if ((i_txn_act_id = 3 and i_txn_qty > 0) or
	(i_txn_act_id = 21 and i_fob_point = 1) or
	(i_txn_act_id = 12 and i_fob_point = 2)) then
      if (l_to_org = i_org_id) then /* Avg Costing */
        /* Debit inventory or intransit at receiving org's cost */
           fnd_file.put_line(fnd_file.log,'Calling Inventory acct');

        --
        -- OPM INVCONV umoogala
        -- Added if/else block to process process-discrete transfers
        --
        if (l_pd_txfr_ind = 0)
        then
          inventory_accounts(l_to_org, i_txn_id,2,i_txn_act_id, l_to_cost_grp,
                          i_item_id, l_rcv_qty,
                          l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                          i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
                          l_snd_rcv, l_rcv_curr, l_snd_curr,
                          l_conv_date, l_conv_rate, l_curr_type,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);
          if (l_err_num <> 0) then
            raise process_error;
          end if;

        else
          --
          -- OPM INVCONV umoogala
          -- This is a process discrete transfer.
          -- ** For Direct and Intransit Rct with FOB Receipt book
          --    Inv. Val and IOP accounts with transfer price only.
          -- ** For Intransit Rct with FOB Shipping book
          --    Inv. Val and Intransit accounts with (transfer price + freight)
          --
          if (i_txn_act_id = 3 and i_txn_qty > 0) or
             (i_txn_act_id = 12 and i_fob_point = 2)
          then
            l_value := l_rcv_qty * i_txf_price;

            if (l_to_cost_grp = 1) then
              select nvl(material_account,-1), nvl(material_overhead_account,-1)
              into   l_acct, l_moh_offset_acct
              from   mtl_parameters
              where  organization_id = i_org_id;
            else
              select nvl(material_account,-1), nvl(material_overhead_account,-1)
              into   l_acct, l_moh_offset_acct
              from   cst_cost_group_accounts
              where  cost_group_id = l_to_cost_grp
              and    organization_id = i_org_id;
            end if;

            --
            -- Bug 5453173/5453410/5450819/5450615:
            --
            select decode(i_exp_item, 0, nvl(l_exp_sub,0), i_exp_item)
            into l_exp
            from dual;

            if (l_intransit = 1 and i_exp_item = 0) then
              l_acct_line_type := 14;
            elsif (l_exp = 1) then
              l_acct_line_type := 2;
	      l_acct := l_exp_acct;
            else
              l_acct_line_type := 1;
            end if;

            if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'l_acct_line_type:' || l_acct_line_type);
            end if;


            --
            -- Bug 5391121: incorrect sign for qty
            -- was: -1 * l_rcv_qty, now: l_rcv_qty
            --
           fnd_file.put_line(fnd_file.log,'calling insert_account for booking INV with value/qty: ' || l_value ||'/'||l_rcv_qty);
            insert_account(l_to_org, i_txn_id, i_item_id, l_value,
                              l_rcv_qty, l_acct, l_rcv_sob_id, l_acct_line_type, NULL, NULL,
                              i_txn_date, i_txn_src_id, i_src_type_id,
                              l_rcv_curr, l_snd_curr,
                              l_conv_date, l_conv_rate, l_curr_type,1,
                              i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                              l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

          end if;
        end if; -- OPM INVCONV umoogala

      else /* Std Costing Org */
           fnd_file.put_line(fnd_file.log,'Calling distribute accts');

	if (l_intransit = 1 and l_std_exp_item = 0) then
          distribute_accounts(l_to_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_rcv_qty, 14,
			0, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			l_snd_curr, l_conv_date, l_conv_rate, l_curr_type,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
          if (l_err_num <> 0) then
           raise process_error;
          end if;

	else
           fnd_file.put_line(fnd_file.log,'Calling distribute accts(2)');

          if (l_std_exp_item = 1 or l_std_exp_sub = 1) then
            distribute_accounts(l_to_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_rcv_qty, 2,
			0, 0, l_std_exp_acct, NULL, NULL, NULL, NULL,NULL,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			l_snd_curr, l_conv_date, l_conv_rate, l_curr_type,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
            if (l_err_num <> 0) then
              raise process_error;
            end if;

          else
               fnd_file.put_line(fnd_file.log,'Calling distribute accts(3)');

            distribute_accounts(l_to_org, i_txn_id,
				0,i_cost_grp_id,i_txn_act_id,
				i_item_id, l_rcv_qty, 1,
			1, 0, NULL, l_std_mat_acct, l_std_mat_ovhd_acct,
			l_std_res_acct, l_std_osp_acct, l_std_ovhd_acct,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			l_snd_curr, l_conv_date, l_conv_rate, l_curr_type,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
            if (l_err_num <> 0) then
             raise process_error;
            end if;

          end if;
        end if;

        if (l_std_exp_sub <> 1 and  l_std_exp_item <> 1) then
                /* bug 2469829 ppv should be calculated only for asset items
                   into asset subinventories */
		/* Not expense so PPV exists. */
          -- PPV equal to total transaction_cost - total actual cost excluding
          -- material overhead.

	  l_stmt_num:=80;

          select nvl(sum(mctcd.transaction_cost),0)
          into l_ppv
	  from mtl_cst_txn_cost_details mctcd
          where mctcd.transaction_id = i_txn_id
          and mctcd.organization_id = l_std_org;

           fnd_file.put_line(fnd_file.log,'ppv:' || l_ppv);

	  l_stmt_num := 90;

        /* If MOH Absorption is overridden, the this level moh costs
           have to be driven to ppv.*/
        /* Also modified code so only this level moh is absorbed. bug 2277950*/

         /* Changes for MOH Absorption Rules engine */
         cst_mohRules_pub.apply_moh(
                              1.0,
                              p_organization_id => l_std_org,
                              p_earn_moh =>l_earn_moh,
                              p_txn_id => i_txn_id,
                              p_item_id => i_item_id,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data);

         IF l_return_status <> FND_API.g_ret_sts_success THEN

         CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_return_status);
         RAISE moh_rules_error;
         END IF;

         l_stmt_num := 95;

         IF(l_earn_moh = 0) THEN
          select l_ppv -  nvl(sum(mcacd.actual_cost),0)
          into l_ppv
          from mtl_cst_actual_cost_details mcacd
          where mcacd.transaction_id = i_txn_id
          and mcacd.organization_id = l_std_org;

         else

           select l_ppv - nvl(sum(mcacd.actual_cost),0)
          into l_ppv
          from mtl_cst_actual_cost_details mcacd
          where mcacd.transaction_id = i_txn_id
          and mcacd.organization_id = l_std_org
          and not (cost_element_id =  2
          and level_type = 1);
          /* Earn only this level MOH */
         END IF;

           fnd_file.put_line(fnd_file.log,'ppv:' || l_ppv);


	  /* Changes for PJM for Standard Costing */
	  l_stmt_num := 95;
	  update mtl_material_transactions
		set variance_amount = l_ppv * abs(l_rcv_qty)
		where transaction_id = i_txn_id
		and organization_id = l_std_org;

          if (l_ppv <> 0) then
            l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, sign(l_ppv), 6,
					NULL, NULL, l_subinv,0, l_snd_rcv,
					l_err_num, l_err_code, l_err_msg,NULL);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

            if (l_acct = -1) then
	      l_acct := l_io_ppv_acct;
            end if;

/* FIX bug 668528 -> change l_from_org to l_std_org so PPV from std org will be used */
            insert_account(l_std_org, i_txn_id, i_item_id,
			l_ppv * abs(l_rcv_qty),
			l_rcv_qty, l_acct, l_rcv_sob_id, 6, NULL, NULL,
			i_txn_date, i_txn_src_id, i_src_type_id,
			l_rcv_curr, l_snd_curr, l_conv_date, l_conv_rate,
			l_curr_type,1,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

          end if;
        end if;
      end if;

      -- Overhead Absorption.
      if ((l_to_org = i_org_id and l_exp_sub = 0 and i_exp_item = 0) or
          (l_to_org = l_std_org and l_std_exp_sub <> 1 and l_std_exp_item <> 1)) then

       if(l_earn_moh <>  0) then
        ovhd_accounts(l_to_org, i_txn_id, i_item_id, -1 * l_rcv_qty, l_rcv_sob_id,
		 	i_txn_date, i_txn_src_id, i_src_type_id, l_subinv,
			l_snd_rcv, l_rcv_curr,
			l_snd_curr, l_conv_date, l_conv_rate, l_curr_type,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
        if (l_err_num <> 0) then
          raise process_error;
        end if;

	--
	-- Bug 5677953
	-- FOr process/discete xfer, offset moh since we have booked
	-- inventory valuation account was booked at transfer price.
	--
	if l_pd_txfr_ind = 1
	then

          select nvl(sum(base_transaction_value), 0)
            into l_value
            from mtl_transaction_accounts
           where transaction_id = i_txn_id
             and organization_id = l_to_org
             and accounting_line_type = 3
             and cost_element_id = 2;

          if l_value <> 0
          then
            insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                        l_rcv_qty, l_moh_offset_acct, l_rcv_sob_id, 1, NULL, NULL,
                        i_txn_date, i_txn_src_id, i_src_type_id,
                        l_rcv_curr, l_snd_curr,
                        l_conv_date, l_conv_rate, l_curr_type,1,
                        i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
              raise process_error;
            end if;

          end if;
	end if; /* if l_pd_txfr_ind = 1 */
	-- End bug 5677953

       end if;
      end if;

      -- Credit Interorg Payables

      l_stmt_num := 100;

      --
      -- OPM INVCONV umoogala
      -- For process-discrete xfers, use transfer price.
      --
      if (l_pd_txfr_ind = 0)
      then
        select sum(base_transaction_value)
        into l_value
        from mtl_transaction_accounts
        where transaction_id = decode(i_txn_act_id, 3, i_txf_txn_id,i_txn_id)
        and organization_id = l_from_org
        and accounting_line_type = 10;

        l_value := l_value * l_conv_rate;
      elsif ((l_pd_txfr_ind = 1) and
             ((i_txn_act_id = 3  and i_txn_qty > 0) or
              (i_txn_act_id = 12 and i_fob_point = 2)))
      then
        -- process-discrete transfer
        l_value := l_rcv_qty * i_txf_price;
      end if;

      /* INVCONV Bug#5476815 ANTHIYAG 21-Aug-2006 Start */
      /************************************************************************************
      * If Intercompany invoicing is enabled, then the booking should be made against the *
      * Inventory AP Accrual account rather than the Inter-Org Payables Account           *
      ************************************************************************************/
      IF nvl(l_io_invoicing, 2) =  1 AND i_src_type_id IN (7, 8) AND l_org_ou <> l_txf_org_ou THEN /* INVCONV Bug#5498133/5498041 ANTHIYAG 30-Aug-2006 */
        l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 2,
                            NULL, NULL, l_subinv,0, l_snd_rcv,
                            l_err_num, l_err_code, l_err_msg,NULL);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
          l_acct := l_inv_ap_accrual_acct;
        end if;

        insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                      -1 * l_rcv_qty, l_acct, l_rcv_sob_id, 2, NULL, NULL,
                      i_txn_date, i_txn_src_id, i_src_type_id,
                      l_rcv_curr, l_snd_curr,
                      l_conv_date, l_conv_rate, l_curr_type,1,
                      i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                      l_err_num, l_err_code, l_err_msg);

        if (l_err_num <> 0) then
          raise process_error;
        end if;

        fnd_file.put_line(fnd_file.log,'Inter Company Accrual amount(l_value):' || l_value || ' acct: ' || l_acct);

      ELSE
        /* INVCONV Bug#5476815 ANTHIYAG 21-Aug-2006 End */

        l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 9,
                            NULL, NULL, l_subinv,0, l_snd_rcv,
                            l_err_num, l_err_code, l_err_msg,NULL);
        if (l_err_num <> 0) then
          raise process_error;
        end if;

        if (l_acct = -1) then
	        l_acct := l_io_pay_acct;
        end if;

        fnd_file.put_line(fnd_file.log,'Payable amount(l_value):' || l_value || ' acct: ' || l_acct);

        /* Bug 3169767: use -1*l_rcv_qty */
        insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
  			-1 * l_rcv_qty, l_acct, l_rcv_sob_id, 9, NULL, NULL,
  			i_txn_date, i_txn_src_id, i_src_type_id,
  			l_rcv_curr, l_snd_curr,
  			l_conv_date, l_conv_rate, l_curr_type,1,
  			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
  			l_err_num, l_err_code, l_err_msg);
        if (l_err_num <> 0) then
          raise process_error;
        end if;
      END IF;


      /* Transportation credit if FOB is shipment. */
      -- bug 774662 check if it is direct interorg txfer don't do the credit
      if (l_pd_txfr_ind = 0)
        then
        if ((i_trp_cost <> 0) and (i_fob_point = 1)) and (i_txn_act_id <> 3) then
          /* transportation credit need to be converted to receiving currency
             for fob point shipment, because the credit will be in the
             receiving org*/
          if (l_to_org <> i_txn_org_id) then
            l_value := i_trp_cost * l_conv_rate;
          end if;

          l_acct := CSTPACHK.get_account_id(l_to_org, i_txn_id, -1, 12,
                                          NULL, NULL, l_subinv,0, l_snd_rcv,
                                          l_err_num, l_err_code, l_err_msg,NULL);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

          if (l_acct = -1) then
            l_acct := i_trp_acct;
          end if;

          insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                          l_rcv_qty, l_acct, l_rcv_sob_id, 12, NULL, NULL,
                          i_txn_date, i_txn_src_id, i_src_type_id,
                          l_rcv_curr, l_snd_curr,
                          l_conv_date, l_conv_rate, l_curr_type,1,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);
          if (l_err_num <> 0) then
            raise process_error;
          end if;

        end if;
      end if;  -- OPM INVCONV umoogala

    elsif (i_txn_act_id = 12 and i_fob_point = 1) then
      /* Receiving org, no ownership change. */
      if (l_to_org = i_org_id and i_exp_item = 0) then /* Average Cost Org */
        /* Debit Inventory at Rcv org's cost */

        l_intransit := 0;

        --
        -- OPM INVCONV umoogala
        -- Added if/else block
        --
	-- Bug 4900652: Booking Inv Val. and Intransit Acct with current Avg. Cost
	-- to make it consistent with Discrete/Discrete Org.
        -- if (l_pd_txfr_ind = 0)
        -- then
          inventory_accounts(l_to_org, i_txn_id,2,i_txn_act_id,l_to_cost_grp,
                          i_item_id, l_rcv_qty,
                          l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                          i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
                          l_snd_rcv, l_rcv_curr, null,
                          null, null, null,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

	/*
        else
          --
          -- OPM INVCONV  Process-Discrete Transfers
          -- For process-discrete transfer book Inv. Valuation account with
          -- (transfer price + freight).
          --

          l_value := (i_txf_price * l_rcv_qty) + i_trp_cost;

          if (l_to_cost_grp = 1) then
            select nvl(material_account,-1)
            into   l_acct
            from   mtl_parameters
            where  organization_id = i_org_id;
          else
            select nvl(material_account,-1)
            into   l_acct
            from   cst_cost_group_accounts
            where  organization_id = i_org_id
            and    cost_group_id = l_to_cost_grp;
          end if;

          insert_account(l_to_org, i_txn_id, i_item_id, -1 * l_value,
                            -1 * l_rcv_qty, l_acct, l_rcv_sob_id, 1, NULL, NULL,
                            i_txn_date, i_txn_src_id, i_src_type_id,
                            l_rcv_curr, NULL,
                            NULL, NULL, NULL, 1,
                            i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                            l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

        end if;  -- OPM INVCONV umoogala
	*/

        /* Credit Receiving Org's intransit. */
        l_intransit := 1;

        --
        -- OPM INVCONV umoogala
        -- Added if/else block
        --
	-- Bug 4900652: Booking Inv Val. and Intransit Acct with current Avg. Cost
	-- to make it consistent with Discrete/Discrete Org.
        -- if (l_pd_txfr_ind = 0)
        -- then
          inventory_accounts(l_to_org, i_txn_id,2,i_txn_act_id,l_from_cost_grp,
                          i_item_id, -1 * l_rcv_qty,
                          l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                          i_exp_item, l_exp_sub, l_exp_acct, l_subinv, l_intransit,
                          l_snd_rcv, l_rcv_curr, null,
                          null, null, null,
                          i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
                          l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;
	/*
        else
          --
          -- OPM INVCONV umoogala
          -- For process-discrete transfer book Inv. Valuation account with
          -- (transfer price + freight).
          --

          l_value := (i_txf_price * l_rcv_qty) + i_trp_cost;

          if (l_to_cost_grp = 1) then
            select nvl(material_account,-1)
            into   l_acct
            from   mtl_parameters
            where  organization_id = i_org_id;
          else
            select nvl(material_account,-1)
            into   l_acct
            from   cst_cost_group_accounts
            where  organization_id = i_org_id
            and    cost_group_id = l_to_cost_grp;
          end if;

          insert_account(l_to_org, i_txn_id, i_item_id, l_value,
              l_rcv_qty, l_acct, l_rcv_sob_id, 14,
              NULL, NULL,
              i_txn_date, i_txn_src_id, i_src_type_id,
              l_rcv_curr, NULL, NULL, NULL, NULL,
              1, i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
              l_err_num, l_err_code, l_err_msg);

          if (l_err_num <> 0) then
            raise process_error;
          end if;

        end if; -- OPM INVCONV umoogala
	*/

      elsif (l_std_exp_item = 0 AND l_std_org = l_to_org ) then /* Standard Cost Org */

           fnd_file.put_line(fnd_file.log,'Std org: Dr inv at receiving org cost');


        /* Debit Invenoty at Rcv org's cost */
        if (l_std_exp_sub = 1) then
          distribute_accounts(l_to_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_rcv_qty, 2,
			0, 0, l_std_exp_acct, NULL, NULL, NULL, NULL,NULL,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			null, null, null, null,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
          if (l_err_num <> 0) then
            raise process_error;
          end if;

        else
          distribute_accounts(l_to_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, l_rcv_qty, 1,
			1, 0, NULL, l_std_mat_acct, l_std_mat_ovhd_acct,
			l_std_res_acct, l_std_osp_acct, l_std_ovhd_acct,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			null, null, null, null,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
          if (l_err_num <> 0) then
            raise process_error;
          end if;

        end if;
        /* Debit Receiving Org's intransit. */
        distribute_accounts(l_to_org, i_txn_id,
			0,i_cost_grp_id,i_txn_act_id,
			i_item_id, -1 * l_rcv_qty, 14,
			0, 0, l_io_inv_acct, NULL, NULL, NULL, NULL,NULL,
			l_rcv_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
			l_subinv, l_snd_rcv, l_rcv_curr,
			null, null, null, null,
			i_user_id, i_login_id, i_req_id, i_prg_appl_id, i_prg_id,
			l_err_num, l_err_code, l_err_msg);
        if (l_err_num <> 0) then
          raise process_error;
        end if;

      end if;
    end if;
  end if;

  EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;
 when moh_rules_error then
      rollback;
      o_error_num := 9999;
      o_error_code := 'CST_RULES_ERROR';
      FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
      o_error_message := FND_MESSAGE.Get;
 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.interorg_cost_txn(' || to_char(l_stmt_num) || ') '||
                     substr(SQLERRM,1,180);

end interorg_cost_txn;

procedure avcu_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_QTY			IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_ONHAND_VAR_ACCT     IN      NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_acct_exist		NUMBER;
  l_acct		NUMBER;
  l_cost		NUMBER;
  l_var			NUMBER;
  l_ele_exist		NUMBER;
  l_inv_mat_acct	NUMBER;
  l_inv_mat_ovhd_acct	NUMBER;
  l_inv_res_acct	NUMBER;
  l_inv_osp_acct	NUMBER;
  l_inv_ovhd_acct	NUMBER;
  l_onhand_var          NUMBER;/*LCM*/
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_stmt_num	NUMBER;
  l_debug       VARCHAR2(1);
  process_error	EXCEPTION;
  no_acct_error EXCEPTION;
  no_txn_det_error EXCEPTION;
BEGIN
  -- initialize local variables
  l_ele_exist := 0;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_debug := fnd_profile.value('MRP_DEBUG');

  l_stmt_num := 2;
  if (i_qty = 0 and l_debug = 'Y') THEN
    FND_MESSAGE.set_name('BOM', 'CST_UPDATE_ZERO_QTY');
    fnd_file.put_line(fnd_file.log, 'CSTPACDP.avcu_cost_txn: ' || FND_MESSAGE.Get);
  end if;

  l_stmt_num := 5;

  if (i_cost_grp_id = 1) then
    select count(*)
    into   l_acct_exist
    from   mtl_parameters
    where  organization_id = i_org_id;
  else
    select count(*)
    into   l_acct_exist
    from   cst_cost_group_accounts
    where  organization_id = i_org_id
    and    cost_group_id = i_cost_grp_id;
  end if;

  if (l_acct_exist = 0) then
    raise no_acct_error;
  end if;

  l_stmt_num := 10;

  if (i_cost_grp_id = 1) then
    select nvl(material_account,-1),
           nvl(material_overhead_account,-1),
           nvl(resource_account,-1),
           nvl(outside_processing_account,-1),
           nvl(overhead_account,-1)
    into   l_inv_mat_acct,
           l_inv_mat_ovhd_acct,
           l_inv_res_acct,
           l_inv_osp_acct,
           l_inv_ovhd_acct
    from   mtl_parameters
    where  organization_id = i_org_id;
  else
    select nvl(material_account,-1),
           nvl(material_overhead_account,-1),
           nvl(resource_account,-1),
           nvl(outside_processing_account,-1),
           nvl(overhead_account,-1)
    into   l_inv_mat_acct,
           l_inv_mat_ovhd_acct,
           l_inv_res_acct,
           l_inv_osp_acct,
           l_inv_ovhd_acct
    from   cst_cost_group_accounts
    where  organization_id = i_org_id
    and    cost_group_id = i_cost_grp_id;
  end if;

  l_stmt_num := 20;

  select count(*)
  into l_ele_exist
  from mtl_cst_actual_cost_details
  where transaction_id = i_txn_id
  and organization_id = i_org_id;

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

 -- Initially, average cost update was designed such that no variance
 -- would be generated. However, there were some inconsistencies with this
 -- approach. Average cost update will now generate variances for some cases.
 -- For eg., when a value change is performed that drives Onhand value
 -- negative, the onhand value is driven to zero and the residue is
 -- written off to the avg cost variance account.
 -- Based on this the accounting rules are :
 --
 -- 	Adjustment acct 	(prior - New) * Qty - Variance
 --	Inventory		(New - Prior) * Qty
 -- 	Variance Acct		 Variance
 -- All these value are based on MCACD.


  FOR cost_element IN 1..5 loop
    l_cost := NULL;
    -- The difference between new cost and prior cost is the impact to
    -- inventory. If new cost is higher then it's a debit to inventory
    -- else it is a credit to inventory.

    l_stmt_num := 30;

    select (sum(new_cost) - sum(prior_cost)),sum(variance_amount)
           ,sum(onhand_variance_amount)
    into l_cost,l_var,l_onhand_var
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and cost_element_id = cost_element;


    if (l_cost is not NULL) then

     if (l_cost <> 0) then -- 4706781 This applies to INV accounting only

      -- First post to inventory.
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(l_cost), 1,
				cost_element, NULL, NULL,
				0, NULL, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);

      -- check error
	 if (l_err_num<>0) then
         raise process_error;
 	 end if;

      if (l_acct = -1) then

	l_stmt_num := 40;

        select decode(cost_element, 1, l_inv_mat_acct,
				  2, l_inv_mat_ovhd_acct,
				  3, l_inv_res_acct,
				  4, l_inv_osp_acct,
				  5, l_inv_ovhd_acct)
        into l_acct
        from dual;
      end if;

      insert_account(i_org_id, i_txn_id, i_item_id, i_qty * l_cost,
		sign(i_qty * l_cost) * abs(i_qty)/*modified for bug#4005770*//*i_qty*/, l_acct, i_sob_id, 1,
		cost_element, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;

     end if; -- (l_cost <> 0)

     if (l_cost <> 0 OR l_var <> 0 OR l_onhand_var <> 0) then -- 4706781 Adj has to be posted if variance exists

      -- Second post to adjustment.
      l_cost := -1 * l_cost;
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign((i_qty * l_cost) - l_var-l_onhand_var), 2,
				cost_element, NULL, NULL,
				0, NULL, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);
	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;

      l_stmt_num := 50;

/* Added the decode for BUG: 1107767. Avg cost update through the interface needs all the accounts
   in MMT to be specified, even if only the material cost element is getting affected */

      if (l_acct = -1) then
        select decode(cost_element, 1, i_mat_acct,
				  2, decode(i_mat_ovhd_acct,-1, i_mat_acct, i_mat_ovhd_acct),
                                  3, decode(i_res_acct,-1, i_mat_acct, i_res_acct),
				  4, decode(i_osp_acct,-1, i_mat_acct, i_osp_acct),
				  5, decode(i_ovhd_acct,-1, i_mat_acct, i_ovhd_acct))
        into l_acct
        from dual;
      end if;

      insert_account(i_org_id, i_txn_id, i_item_id, (i_qty * l_cost) - l_var-l_onhand_var,
		i_qty, l_acct, i_sob_id, 2,
		cost_element, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;

     end if; -- (l_cost <> 0 and l_var <> 0)
     if (l_onhand_var <> 0) then

      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
                                sign(l_onhand_var), 20,
                                cost_element, NULL, NULL,
                                0, NULL, l_err_num, l_err_code,
                                l_err_msg,i_cost_grp_id);

          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

      if (l_acct = -1) then
        l_acct := I_ONHAND_VAR_ACCT;
      end if;

      insert_account(i_org_id, i_txn_id, i_item_id, l_onhand_var,
                i_qty, l_acct, i_sob_id, 20,
                cost_element, NULL,
                i_txn_date, i_txn_src_id, i_src_type_id,
                i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
                1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
                l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

     end if;

    end if; -- (l_cost is not NULL)

  end loop;


 -- Now Post one consolidated variance entry

  l_stmt_num := 60;

  select nvl(sum(variance_amount),0)
  into l_var
  from mtl_cst_actual_cost_details cacd
  where transaction_id = i_txn_id
  and organization_id = i_org_id;

  if (l_var <> 0) then

      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
                                sign(l_var), 13,
                                NULL, NULL, NULL,
                                0, NULL, l_err_num, l_err_code,
                                l_err_msg,i_cost_grp_id);

          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

    if (l_acct = -1) then
      if (i_cost_grp_id = 1) then
        select nvl(average_cost_var_account,-1)
        into   l_acct
        from   mtl_parameters
        where  organization_id = i_org_id;
      else
        select nvl(average_cost_var_account,-1)
        into   l_acct
        from   cst_cost_group_accounts
        where  organization_id = i_org_id
        and    cost_group_id = i_cost_grp_id;
      end if;
    end if;

    insert_account(i_org_id, i_txn_id, i_item_id, l_var,
                i_qty, l_acct, i_sob_id, 13,
                NULL, NULL,
                i_txn_date, i_txn_src_id, i_src_type_id,
                i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
                1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
                l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

 end if;

  EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when no_acct_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_CG_ACCTS';
 FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
 O_error_message := FND_MESSAGE.Get;

 when no_txn_det_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_TXN_DET';
 FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
 O_error_message := FND_MESSAGE.Get;

 when others then
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.avcu_cost_txn' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END avcu_cost_txn;

-- New procedure for dropshipment project
procedure logical_cost_txn(
  I_ORG_ID              IN          NUMBER,
  I_TXN_ID              IN          NUMBER,
  I_COST_GRP_ID         IN          NUMBER,
  I_ITEM_ID             IN          NUMBER,
  I_TXN_DATE            IN          DATE,
  I_P_QTY               IN          NUMBER,
  I_SUBINV              IN          VARCHAR2,
  I_TXN_ACT_ID          IN          NUMBER,
  I_TXN_SRC_ID          IN          NUMBER,
  I_SRC_TYPE_ID         IN          NUMBER,
  I_TXN_TYPE_ID         IN          NUMBER,
  I_DIST_ACCT           IN          NUMBER,
  I_SOB_ID              IN          NUMBER,
  I_PRI_CURR            IN          VARCHAR2,
  I_ALT_CURR            IN          VARCHAR2,
  I_CONV_DATE           IN          DATE,
  I_CONV_RATE           IN          NUMBER,
  I_CONV_TYPE           IN          VARCHAR2,
  I_SO_ACCOUNTING       IN          NUMBER,
  I_COGS_PERCENTAGE     IN          NUMBER,
  I_COGS_OM_LINE_ID     IN          NUMBER,
  I_EXP_ITEM            IN          NUMBER,
  I_USER_ID             IN          NUMBER,
  I_LOGIN_ID            IN          NUMBER,
  I_REQ_ID              IN          NUMBER,
  I_PRG_APPL_ID         IN          NUMBER,
  I_PRG_ID              IN          NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2
)IS
  l_exp_sub          NUMBER;
  l_exp              NUMBER;
  l_exp_acct         NUMBER;
  l_acct_line_type   NUMBER;
  l_acct             NUMBER;
  l_stmt_num         NUMBER;
  process_error      EXCEPTION;
  l_err_num          NUMBER;
  l_err_code         VARCHAR2(240);
  l_err_msg          VARCHAR2(240);
  l_msg_count        NUMBER;
  l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_data         VARCHAR2(2000);
  l_cost_method      NUMBER;

  l_def_cogs_acct_id    NUMBER; -- Revenue COGS Matching
  l_ref_om_line_id      NUMBER;
  l_elemental           NUMBER := 0; -- For the offsetting distribution, most are not elemental

BEGIN

  l_stmt_num := 10;

  -- No distributions for Logical sales order issues and
  -- Logical RMA receipts if the item is an expense item
  -- or if it comes from/into an expense subinventory
  if ( (i_src_type_id in (2,12)) AND
       (i_exp_item = 1) ) then
    -- no accounting
    return;
  end if;

  l_stmt_num := 15;


  -- For all of the other transaction types, expense items
  -- will be accounted for as if they are inventory items.
  -- We just need to provide the expense account for expense items.
  if (i_exp_item = 1) then
    if (i_cost_grp_id = 1) then
      select nvl(expense_account,-1)
      into l_exp_acct
      from mtl_parameters
      where  organization_id = i_org_id;
    else
      select nvl(expense_account, -1)
      into l_exp_acct
      from cst_cost_group_accounts
      where cost_group_id = i_cost_grp_id   AND
            organization_id = i_org_id;
    end if;
  else
    l_exp_acct := -1;
  end if;

  l_stmt_num := 20;
  -- hit up MP for some values
  select primary_cost_method, -- Standard costing orgs will have to call the new inventory_accounts_std() procedure
         deferred_cogs_account
  into l_cost_method,
       l_def_cogs_acct_id
  from mtl_parameters
  where organization_id = i_org_id;

  /*******************************************************************************
   ** Set the account and accounting line type for the offsetting distribution. **
   *******************************************************************************/
  l_acct := i_dist_acct;

  if (i_txn_type_id in (19,39,69,22,23)) then
    l_acct_line_type := 31; -- clearing
  elsif (i_txn_type_id in (11,14)) then
    l_acct_line_type := 2; -- account (I/C COGS)
  elsif (i_txn_type_id in (10,13)) then
    l_acct_line_type := 16; -- accrual
  elsif (i_txn_type_id in (16,30)) then -- Logical RMA Receipt or Logical SO Issue
    l_acct_line_type := 35; -- New COGS line type

    l_stmt_num := 30;
    -- Get the original sales order issue OM line ID, and check
    -- whether the original sales order issue was inserted into
    -- the Revenue / COGS Matching data model.
    SELECT max(ool.reference_line_id)
    INTO l_ref_om_line_id
    FROM oe_order_lines_all ool,
         cst_revenue_cogs_match_lines crcml
    WHERE ool.line_id = i_cogs_om_line_id
    AND   ool.reference_line_id = crcml.cogs_om_line_id
    AND   crcml.pac_cost_type_id IS NULL
    AND   i_txn_type_id = 16;
  elsif (i_txn_act_id = 36 AND i_src_type_id = 2) then
  -- COGS Recognition Event

      l_stmt_num := 40;
     /* This procedure will move an appropriate balance between *
      * the Deferred COGS and COGS accounts.                    */
     CST_RevenueCogsMatch_PVT.Process_CogsRecognitionTxn(
                  x_return_status   => l_return_status,
                  x_msg_count       => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_cogs_om_line_id => i_cogs_om_line_id,
                  p_transaction_id  => i_txn_id,
                  p_txn_quantity    => i_p_qty,
                  p_organization_id => i_org_id,
                  p_item_id         => i_item_id,
                  p_sob_id          => i_sob_id,
                  p_txn_date        => i_txn_date,
                  p_txn_src_id      => i_txn_src_id,
                  p_src_type_id     => i_src_type_id,
                  p_pri_curr        => i_pri_curr,
                  p_alt_curr        => i_alt_curr,
                  p_conv_date       => i_conv_date,  --BUG#8681667: Useless Conversion removed
                  p_conv_rate       => i_conv_rate,
                  p_conv_type       => i_conv_type,
                  p_user_id         => i_user_id,
                  p_login_id        => i_login_id,
                  p_req_id          => i_req_id,
                  p_prg_appl_id     => i_prg_appl_id,
                  p_prg_id          => i_prg_id);

     -- check return status
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_err_num := -1;
        IF (l_msg_count = 1) THEN
           l_err_msg := substr(l_msg_data,1,240);
        ELSE
           l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Process_CogsRecognitionTxn()';
        END IF;
        raise process_error;
     ELSE
        RETURN;
     END IF;

  else
    -- invalid transaction type
    l_err_msg := 'Invalid Transaction type passed to logical_cost_txn';
    l_err_num := 9999;
    raise process_error;
  end if;

  l_stmt_num := 50;
  -- Make the inventory distributions
  if (l_cost_method = 1) then
    inventory_accounts_std(i_org_id, i_txn_id, 2,
                        i_txn_act_id,i_cost_grp_id,
                        i_item_id, i_p_qty,
                        i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
                        i_exp_item, 0 /*l_exp_sub*/, l_exp_acct, i_subinv, 0, NULL,
                        i_pri_curr, i_alt_curr, i_conv_date,
                        i_conv_rate, i_conv_type,
                        i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);
  else
    -- i_p_qty will always determine Dr. vs. Cr.
    -- even the txn_action of 11 (logical PO Deliver adj) will work for this
    -- because a positive qty means debit, a negative qty means credit
    inventory_accounts(i_org_id, i_txn_id, 2,
                        i_txn_act_id,i_cost_grp_id,
                        i_item_id, i_p_qty,
                        i_sob_id,i_txn_date, i_txn_src_id, i_src_type_id,
                        i_exp_item, 0 /*l_exp_sub*/, l_exp_acct, i_subinv, 0, NULL,
                        i_pri_curr, i_alt_curr, i_conv_date,
                        i_conv_rate, i_conv_type,
                        i_user_id, i_login_id, i_req_id,
                        i_prg_appl_id, i_prg_id,
                        l_err_num, l_err_code, l_err_msg);
  end if;

  -- check error
  if(l_err_num<>0) then
    raise process_error;
  end if;


  IF (i_txn_type_id = 30 AND i_so_accounting = 2) THEN
     /* Deferred COGS Accounting for this logical sales order */

     /* Only call Insert_OneSoIssue if the percentage is NULL. */
     IF (i_cogs_percentage IS NULL) THEN

        l_stmt_num := 60;
        /* Record this sales order issue for COGS deferral by *
         * inserting into the Revenue / COGS matching tables  */
        CST_RevenueCogsMatch_PVT.Insert_OneSoIssue(
                        p_api_version      => 1,
                        p_user_id          => i_user_id,
                        p_login_id         => i_login_id,
                        p_request_id       => i_req_id,
                        p_pgm_app_id       => i_prg_appl_id,
                        p_pgm_id           => i_prg_id,
                        x_return_status    => l_return_status,
                        p_cogs_om_line_id  => i_cogs_om_line_id,
                        p_cogs_acct_id     => l_acct,
                        p_def_cogs_acct_id => l_def_cogs_acct_id,
                        p_mmt_txn_id       => i_txn_id,
                        p_organization_id  => i_org_id,
                        p_item_id          => i_item_id,
                        p_transaction_date => i_txn_date,
                        p_cost_group_id    => i_cost_grp_id,
                        p_quantity         => (-1*i_p_qty)); /* track issue quantities as positive values */

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           l_err_num := -1;
           FND_MSG_PUB.count_and_get
           (  p_count   => l_msg_count,
              p_data    => l_msg_data,
              p_encoded => FND_API.g_false
           );
           IF (l_msg_count = 1) THEN
              l_err_msg := substr(l_msg_data,1,240);
           ELSE
              l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Insert_OneSoIssue()';
           END IF;
           raise process_error;
        END IF;
     END IF; /* COGS Percentage is NULL */

     l_acct := l_def_cogs_acct_id; /* pass deferred COGS account to distribute_accounts() */
     l_acct_line_type := 36; -- Deferred COGS
     l_elemental := 1;  -- For Deferred COGS sales orders we want elemental call to distribute_accounts()

  END IF; /* Deferred COGS Accounting */

  l_stmt_num := 70;

  /*********************************************************************
   **  Now post to the offsetting accounts.                           **
   *********************************************************************/

  -- Now for RMA receipts that reference an original sales order line ID
  IF (i_txn_type_id = 16 AND l_ref_om_line_id IS NOT NULL) THEN

     /* This procedure will create the offsetting credits *
      * split accordingly between COGS and Deferred COGS. */
     CST_RevenueCogsMatch_PVT.Process_RmaReceipt(
                  x_return_status   => l_return_status,
                  x_msg_count       => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_rma_om_line_id  => i_cogs_om_line_id,
                  p_cogs_om_line_id => l_ref_om_line_id,
                  p_cost_type_id    => 2,
                  p_txn_quantity    => (-1*i_p_qty),
                  p_cogs_percentage => i_cogs_percentage,
                  p_organization_id => i_org_id,
                  p_transaction_id  => i_txn_id,
                  p_item_id         => i_item_id,
                  p_sob_id          => i_sob_id,
                  p_txn_date        => i_txn_date,
                  p_txn_src_id      => i_txn_src_id,
                  p_src_type_id     => i_src_type_id,
                  p_pri_curr        => i_pri_curr,
                  p_alt_curr        => i_alt_curr,
                  p_conv_date       => i_conv_date,
                  p_conv_rate       => i_conv_rate,
                  p_conv_type       => i_conv_type,
                  p_user_id         => i_user_id,
                  p_login_id        => i_login_id,
                  p_req_id          => i_req_id,
                  p_prg_appl_id     => i_prg_appl_id,
                  p_prg_id          => i_prg_id);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_err_num := -1;
        FND_MSG_PUB.count_and_get
        (  p_count   => l_msg_count,
           p_data    => l_msg_data,
           p_encoded => FND_API.g_false
        );
        IF (l_msg_count = 1) THEN
           l_err_msg := substr(l_msg_data,1,240);
        ELSE
           l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Process_RmaReceipt()';
        END IF;
        raise process_error;
     END IF;

  ELSE -- For all non-RMA transactions, as well as RMAs that don't reference deferred COGS sales orders:

     distribute_accounts(i_org_id, i_txn_id,2,i_cost_grp_id,i_txn_act_id,
                        i_item_id, -1 * i_p_qty,l_acct_line_type, l_elemental,
                        0 /*l_ovhd_absp*/,l_acct, l_acct, l_acct, l_acct,
                        l_acct, l_acct,
                        i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                        i_subinv, NULL, i_pri_curr, i_alt_curr, i_conv_date,
                        i_conv_rate, i_conv_type, i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                        l_err_code, l_err_msg, i_cogs_om_line_id);

  END IF; -- IF RMA Receipt with deferred COGS reference

  -- check error
  if(l_err_num<>0) then
    raise process_error;
  end if;

EXCEPTION

 when process_error then
 rollback;
 /* Changed for bug 9950507 */
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.logical_cost_txn (' || to_char(l_stmt_num) ||
                     '): ' || substr(SQLERRM,1,180);

END logical_cost_txn;

-- New procedure for dropshipment project
procedure consigned_update_cost_txn(
  I_ORG_ID              IN          NUMBER,
  I_TXN_ID              IN          NUMBER,
  I_COST_GRP_ID         IN          NUMBER,
  I_ITEM_ID             IN          NUMBER,
  I_TXN_DATE            IN          DATE,
  I_P_QTY               IN          NUMBER,
  I_SUBINV              IN          VARCHAR2,
  I_TXN_ACT_ID          IN          NUMBER,
  I_TXN_SRC_ID          IN          NUMBER,
  I_SRC_TYPE_ID         IN          NUMBER,
  I_DIST_ACCT           IN          NUMBER,
  I_SOB_ID              IN          NUMBER,
  I_PRI_CURR            IN          VARCHAR2,
  I_ALT_CURR            IN          VARCHAR2,
  I_CONV_DATE           IN          DATE,
  I_CONV_RATE           IN          NUMBER,
  I_CONV_TYPE           IN          VARCHAR2,
  I_EXP_ITEM            IN          NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2
)IS
  l_stmt_num         NUMBER;
  process_error      EXCEPTION;
  l_err_num          NUMBER;
  l_err_code         VARCHAR2(240);
  l_err_msg          VARCHAR2(240);
  l_msg_count        NUMBER;
  l_return_status    VARCHAR2(11);
  l_msg_data         VARCHAR2(2000);

  l_retro_acct_id    NUMBER;
  l_qty_adj          NUMBER;
  l_txn_cost         NUMBER;
BEGIN

  -- Initialize
  l_stmt_num := 10;

  -- Get the retro price update account from RCV_PARAMETERS
  select nvl(retroprice_adj_account_id,-1)
  into l_retro_acct_id
  from rcv_parameters
  where organization_id = i_org_id;

  if (l_retro_acct_id = -1) then
    l_err_num := SQLCODE;
    l_err_msg := 'CSTPACDP.consigned_update_cost_txn (10): '||
                 'RCV_PARAMETERS.RETROOPRICE_ADJ_ACCOUNT_ID must not be NULL';
    raise process_error;
  end if;

  l_stmt_num := 20;
  -- For the consigned update transaction, mmt.quantity_adjusted is
  -- used in the distributions since primary quantity and transaction
  -- quantity are 0.
  select quantity_adjusted, transaction_cost
  into l_qty_adj, l_txn_cost
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  l_stmt_num := 30;
  -- The supplier accrual account is stored in MMT.dist_acct_id
  -- Accounting line type 32 = Retroactive Price Adjustment Transaction
  insert_account(i_org_id, i_txn_id, i_item_id, l_qty_adj * l_txn_cost,
                 l_qty_adj, l_retro_acct_id, i_sob_id, 32,
                 1 /*cost_element*/, NULL,
                 i_txn_date, i_txn_src_id, i_src_type_id,
                 i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
                 1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
                 l_err_num, l_err_code, l_err_msg);
  -- check error
  if(l_err_num<>0) then
    raise process_error;
  end if;


  l_stmt_num := 40;
  distribute_accounts(i_org_id, i_txn_id,2,i_cost_grp_id,i_txn_act_id,
                        i_item_id, -1 * l_qty_adj,16, 0 /*l_elemental*/,
                        0 /*l_ovhd_absp*/,i_dist_acct, i_dist_acct, i_dist_acct,
                        i_dist_acct, i_dist_acct, i_dist_acct,
                        i_sob_id, i_txn_date, i_txn_src_id, i_src_type_id,
                        i_subinv, NULL, i_pri_curr, i_alt_curr, i_conv_date,
                        i_conv_rate, i_conv_type, i_user_id, i_login_id,
                        i_req_id, i_prg_appl_id, i_prg_id, l_err_num,
                        l_err_code, l_err_msg);

  -- check error
  if(l_err_num<>0) then
    raise process_error;
  end if;

EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 --O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.consigned_update_cost_txn (' || to_char(l_stmt_num) ||
                     '): ' || substr(SQLERRM,1,180);

END consigned_update_cost_txn;

-- New procedure for dropshipment project
procedure inventory_accounts_std(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_COST_TXN_ACTION_ID  IN      NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_EXP_SUBINV		IN	NUMBER,
  I_EXP_ACCT		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_INTRANSIT		IN	NUMBER,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_cost	NUMBER;
  l_acct	NUMBER;
  l_acct_line_type NUMBER;
  l_var		NUMBER;
  l_exp		NUMBER;
  l_layer_id 	NUMBER;
  l_cost_grp_id NUMBER;
  l_mat_acct	NUMBER;
  l_mat_ovhd_acct NUMBER;
  l_res_acct	NUMBER;
  l_osp_acct	NUMBER;
  l_ovhd_acct	NUMBER;
  l_ele_exist	NUMBER;
  l_stmt_num 	NUMBER;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  process_error	EXCEPTION;
  no_acct_error EXCEPTION;
  no_txn_det_error EXCEPTION;
  l_wms_flg       NUMBER;
  l_pjm_flg       NUMBER;
  l_ele_acct      NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(8000);
  l_ccga_count    NUMBER;
BEGIN
  -- initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_cost := '';

  l_stmt_num := 10;

  select decode(i_exp_item, 0, nvl(i_exp_subinv,0), i_exp_item)
  into l_exp
  from dual;

  if (i_intransit = 1 and i_exp_item = 0) then
    l_exp := 0;
    l_acct_line_type := 14;
  elsif (l_exp = 1) then
    l_acct_line_type := 2;
  else
    l_acct_line_type := 1;
  end if;

  l_stmt_num := 20;

  l_cost_grp_id := i_cost_grp_id;
  l_layer_id := -1;
  select count(*)
  into l_ele_exist
  from mtl_cst_actual_cost_details mcacd
  where mcacd.transaction_id = i_txn_id
  and mcacd.organization_id = i_org_id
  and mcacd.layer_id = l_layer_id;

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

  l_stmt_num := 30;
  if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data, i_org_id)) then
    l_wms_flg := 1;
  else
    l_wms_flg := 0;
  end if;

  l_stmt_num := 40;
  SELECT decode(nvl(cost_group_accounting,0),0,0,
         decode(nvl(project_reference_enabled,0),1,1,0))
  INTO l_pjm_flg
  FROM MTL_PARAMETERS
  WHERE organization_id = i_org_id;

  /* Changes for PJM Standard Costing. */
  if (l_wms_flg=0 AND l_pjm_flg=0 AND i_subinv is not null) then
    l_stmt_num := 50;

    SELECT
           nvl(material_account, -1),
           nvl(material_overhead_account, -1),
           nvl(resource_account, -1),
           nvl(outside_processing_account, -1),
           nvl(overhead_account, -1)
    INTO l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct
    FROM mtl_secondary_inventories
    WHERE organization_id = i_org_id
    and  secondary_inventory_name = i_subinv;
  else
    if (l_cost_grp_id = 1) then
      l_stmt_num := 70;

      SELECT
            nvl(material_account, -1),
            nvl(material_overhead_account, -1),
            nvl(resource_account, -1),
            nvl(outside_processing_account, -1),
            nvl(overhead_account, -1)
      INTO l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct
      FROM mtl_parameters
      WHERE organization_id = i_org_id;
    else
      l_stmt_num := 80;

      SELECT count(*)
      INTO l_ccga_count
      FROM cst_cost_group_accounts
      WHERE cost_group_id = l_cost_grp_id
      AND organization_id = i_org_id;

      if (l_ccga_count = 0) then
        l_err_num := 9999;
        l_err_msg := 'CSTPACDP.inventory_accounts_std(80): Unabled to obtain elemental accounts';
        raise process_error;
      end if;

      l_stmt_num := 90;
      SELECT
            nvl(material_account, -1),
            nvl(material_overhead_account, -1),
            nvl(resource_account, -1),
            nvl(outside_processing_account, -1),
            nvl(overhead_account, -1)
      INTO l_mat_acct, l_mat_ovhd_acct, l_res_acct, l_osp_acct, l_ovhd_acct
      FROM cst_cost_group_accounts
      WHERE organization_id = i_org_id
      AND cost_group_id = l_cost_grp_id;
    end if;
  end if;

  FOR cost_element IN 1..5 loop
    l_cost := NULL;

    l_stmt_num := 100;

    select sum(actual_cost), nvl(sum(variance_amount),0)
    into l_cost, l_var
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and layer_id = l_layer_id
    and cost_element_id = cost_element;

    if (l_cost is not NULL) then
      l_acct := CSTPSCHK.std_get_account_id(i_org_id, i_txn_id, sign(i_p_qty), l_acct_line_type,
                                            cost_element, 0, i_subinv, l_cost_grp_id, l_exp,
                                            i_snd_rcv, l_err_num, l_err_code, l_err_msg);
      -- check error
      if(l_err_num<>0) then
        raise process_error;
      end if;

      if (l_acct = -1) then
        l_stmt_num := 110;
        select decode(l_exp, 1, i_exp_acct,
        decode(cost_element, 1, l_mat_acct,
				  2, l_mat_ovhd_acct,
				  3, l_res_acct,
				  4, l_osp_acct,
				  5, l_ovhd_acct))
        into l_acct
        from dual;
      end if;

       l_stmt_num := 120;
    -- Only insert into mta if the cost elemental detail exist in cacd.
      insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_cost - l_var,
		i_p_qty, l_acct, i_sob_id, l_acct_line_type,
		cost_element, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;
    end if;
  end loop;

  EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when no_acct_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_CG_ACCTS';
 FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
 O_error_message := FND_MESSAGE.Get;

 when no_txn_det_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_TXN_DET';
 FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
 O_error_message := FND_MESSAGE.Get;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.inventory_accounts' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END inventory_accounts_std;

procedure inventory_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_COST_TXN_ACTION_ID  IN      NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_EXP_SUBINV		IN	NUMBER,
  I_EXP_ACCT		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_INTRANSIT		IN	NUMBER,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_cost	NUMBER;
  l_acct	NUMBER;
  l_acct_line_type NUMBER;
  l_var		NUMBER;
  l_exp		NUMBER;
  l_layer_id 	NUMBER;
  l_cost_grp_id NUMBER;
  l_mat_acct	NUMBER;
  l_mat_ovhd_acct NUMBER;
  l_res_acct	NUMBER;
  l_osp_acct	NUMBER;
  l_ovhd_acct	NUMBER;
  l_ele_exist	NUMBER;
  l_acct_exist  NUMBER;
  l_stmt_num 	NUMBER;
  l_err_num	NUMBER;
  l_debug       VARCHAR2(1);
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
-- borrow / payback
  l_txn_type	NUMBER;
  l_txn_action_id  NUMBER;
  l_to_layer_id NUMBER;
  l_payback_var NUMBER;
-- borrow / payback end
  process_error	EXCEPTION;
  no_acct_error EXCEPTION;
  no_txn_det_error EXCEPTION;
BEGIN
  -- initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_cost := '';

  l_stmt_num := 10;

  fnd_file.put_line(fnd_file.log, 'In Inventory_accounts');

  l_debug := fnd_profile.value('MRP_DEBUG');

  select decode(i_exp_item, 0, nvl(i_exp_subinv,0), i_exp_item)
  into l_exp
  from dual;

  -- Currently for an average cost org the inventory valuation accout and
  -- the intransit account is the same.
  l_stmt_num := 15;

  if (i_cost_grp_id = 1) then
    select count(*)
    into   l_acct_exist
    from   mtl_parameters
    where  organization_id = i_org_id;
  else
    select count(*)
    into   l_acct_exist
    from   cst_cost_group_accounts
    where  organization_id = i_org_id
    and    cost_group_id = i_cost_grp_id;
  end if;

  if (l_acct_exist = 0) then
    raise no_acct_error;
  end if;

  l_stmt_num := 20;

  -- Fix bug 894256 the intransit CG accounts can be from common or project CG
  l_cost_grp_id := i_cost_grp_id;

  l_stmt_num := 23;

  if (l_cost_grp_id = 1) then
    select nvl(material_account,-1),
           nvl(material_overhead_account,-1),
           nvl(resource_account,-1),
           nvl(outside_processing_account,-1),
           nvl(overhead_account,-1)
    into   l_mat_acct,
           l_mat_ovhd_acct,
           l_res_acct,
           l_osp_acct,
           l_ovhd_acct
    from   mtl_parameters
    where  organization_id = i_org_id;
  else
    select nvl(material_account,-1),
           nvl(material_overhead_account,-1),
           nvl(resource_account,-1),
           nvl(outside_processing_account,-1),
           nvl(overhead_account,-1)
    into   l_mat_acct,
           l_mat_ovhd_acct,
           l_res_acct,
           l_osp_acct,
           l_ovhd_acct
    from   cst_cost_group_accounts
    where  organization_id = i_org_id
    and    cost_group_id = l_cost_grp_id;
  end if;

  l_stmt_num := 25;

  select layer_id
  into l_layer_id
  from cst_quantity_layers
  where inventory_item_id = i_item_id
  and organization_id = i_org_id
  and cost_group_id = i_cost_grp_id;

  if (l_debug = 'Y') then
  fnd_file.put_line(fnd_file.log, 'layer_id:' || l_layer_id);
  end if;


  if (i_intransit = 1 and i_exp_item = 0) then
    l_exp := 0;
    l_acct_line_type := 14;
  elsif (l_exp = 1) then
    l_acct_line_type := 2;
  else
    l_acct_line_type := 1;
  end if;

  if (l_debug = 'Y') then
  fnd_file.put_line(fnd_file.log, 'l_acct_line_type:' || l_acct_line_type);
  end if;


  l_stmt_num := 30;

  select count(*)
  into l_ele_exist
  from mtl_cst_actual_cost_details mcacd
  where mcacd.transaction_id = i_txn_id
  and mcacd.organization_id = i_org_id
  and mcacd.layer_id = l_layer_id
  and nvl(mcacd.transaction_action_id,-99) =
  nvl(decode(i_comm_iss_flag,1,
	     i_cost_txn_action_id,mcacd.transaction_action_id),-99);

-- borrow payback
  l_stmt_num := 35;
  select mmt.transaction_type_id, mmt.transaction_action_id
    into l_txn_type, l_txn_action_id
    from mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id;
-- borrow payback end



  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

  FOR cost_element IN 1..5 loop
    l_cost := NULL;

      if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'in cost element loop');
      end if;


    l_stmt_num := 40;


    select sum(actual_cost), nvl(sum(variance_amount),0)
    into l_cost, l_var
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and layer_id = l_layer_id
    and cost_element_id = cost_element
    and nvl(transaction_action_id,-99) =
        nvl(decode(i_comm_iss_flag,1,
             i_cost_txn_action_id,transaction_action_id),-99);


    if (l_cost is not NULL) then

        if (l_debug = 'Y') then
          fnd_file.put_line(fnd_file.log, 'org-txn-i_p_qty-cost_element-i_subinv');
          fnd_file.put_line(fnd_file.log, i_org_id || '-' || i_txn_id || '-' ||
                           i_p_qty || '-' || i_subinv);
        end if;
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty), l_acct_line_type,
				cost_element, NULL, i_subinv,
				l_exp, i_snd_rcv,
				 l_err_num, l_err_code, l_err_msg,i_cost_grp_id);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

      if (l_debug = 'Y') then
       fnd_file.put_line(fnd_file.log, 'Calling Insert Account');
      end if;


      if (l_acct = -1) then
	l_stmt_num := 50;
        select decode(l_exp, 1, i_exp_acct,
		decode(cost_element, 1, l_mat_acct,
				  2, l_mat_ovhd_acct,
				  3, l_res_acct,
				  4, l_osp_acct,
				  5, l_ovhd_acct))
        into l_acct
        from dual;
      end if;

       l_stmt_num := 56;
    -- Only insert into mta if the cost elemental detail exist in cacd.
      insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_cost - l_var,
		i_p_qty, l_acct, i_sob_id, l_acct_line_type,
		cost_element, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;
    end if;
  end loop;

  l_stmt_num := 60;

  select nvl(sum(variance_amount),0)
    into l_var
    from mtl_cst_actual_cost_details cacd
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and layer_id = l_layer_id
    and nvl(transaction_action_id,-99) =
        nvl(decode(i_comm_iss_flag,1,
                i_cost_txn_action_id,transaction_action_id),-99);


  if (l_exp <> 1 and l_var <> 0) then /* Not expense */
       -- Insert into variance account.
    l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
   				sign(i_p_qty), 13,
				NULL, NULL, i_subinv,
				0, i_snd_rcv, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);
             -- check error
       if(l_err_num<>0) then
       raise process_error;
       end if;

    l_stmt_num := 70;

    if (l_acct = -1) then
      if (i_cost_grp_id = 1) then
        select nvl(average_cost_var_account,-1)
        into   l_acct
        from   mtl_parameters
        where  organization_id = i_org_id;
      else
        select nvl(average_cost_var_account,-1)
        into   l_acct
        from   cst_cost_group_accounts
        where  cost_group_id = i_cost_grp_id
        and    organization_id = i_org_id;
      end if;
    end if;

    insert_account(i_org_id, i_txn_id, i_item_id, l_var,
	 	i_p_qty, l_acct, i_sob_id, 13,
		NULL, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

         -- check error
         if(l_err_num<>0) then
         raise process_error;
         end if;
  end if;

-- borrow payback
  if (l_txn_type = 68) and (l_txn_action_id = 2) then
     l_stmt_num := 80;
     select nvl(max(layer_id), l_layer_id)
       into l_to_layer_id
       from mtl_cst_actual_cost_details
       where transaction_id = i_txn_id
       and layer_id <> l_layer_id;

     if ((l_layer_id = l_to_layer_id) OR ((l_layer_id <> l_to_layer_id) and (i_p_qty < 0))) then
                                             -- do credit / debit
                                             -- only do dist. for var on payback side

        for cost_element in 1..5 loop
           l_stmt_num := 100;
           select nvl(sum(payback_variance_amount),0)
             into l_payback_var
             from mtl_cst_actual_cost_details cacd
             where transaction_id = i_txn_id
             and organization_id = i_org_id
             and layer_id = l_layer_id
             and cost_element_id = cost_element;

      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty), 13,
				cost_element, NULL, i_subinv,
				0, i_snd_rcv,
				l_err_num, l_err_code, l_err_msg,i_cost_grp_id);
      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

           if (l_acct = -1 AND i_cost_grp_id <> 1) then
           -- if cost_grp_id is 1, then payback variance accountS would remain -1, since
           -- there are no borrow payback variance account defined in mtl_parameters
              l_stmt_num := 110;
              if cost_element = 1 then
                 select nvl(payback_mat_var_account,-1)
                   into l_acct
                   from cst_cost_group_accounts
                  where organization_id = i_org_id
                    and cost_group_id = i_cost_grp_id;
              elsif cost_element = 2 then
                 select nvl(payback_moh_var_account,-1)
                   into l_acct
                   from cst_cost_group_accounts
                  where organization_id = i_org_id
                    and cost_group_id = i_cost_grp_id;
              elsif cost_element = 3 then
                 select nvl(payback_res_var_account,-1)
                   into l_acct
                   from cst_cost_group_accounts
                  where organization_id = i_org_id
                    and cost_group_id = i_cost_grp_id;
              elsif cost_element = 4 then
                 select nvl(payback_osp_var_account,-1)
                   into l_acct
                   from cst_cost_group_accounts
                  where organization_id = i_org_id
                    and cost_group_id = i_cost_grp_id;
              elsif cost_element = 5 then
                 select nvl(payback_ovh_var_account,-1)
                   into l_acct
                   from cst_cost_group_accounts
                  where organization_id = i_org_id
                    and cost_group_id = i_cost_grp_id;
              end if;  -- end selecting different variance account
           end if; -- end if l_acct <> -1 then use hook account

           l_stmt_num := 120;
	   if (l_payback_var <>0) then
              insert_account(i_org_id, i_txn_id, i_item_id, -1 * i_p_qty * l_payback_var,
	     	   i_p_qty, l_acct, i_sob_id, 13,
		   cost_element, NULL,
		   i_txn_date, i_txn_src_id, i_src_type_id,
		   i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		   1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		   l_err_num, l_err_code, l_err_msg);
                 -- check error
              if(l_err_num<>0) then
              raise process_error;
              end if;
           end if;
        end loop;  -- done looping cost elements
     end if; -- different layer
   end if;
-- borrow payback / need to modify cst_avg_dist_accts_v for the new account



  EXCEPTION

 when process_error then
 rollback;
   if (l_debug = 'Y') then
   fnd_file.put_line (fnd_file.log, 'Inventory_accounts' || to_char(l_stmt_num)
                                     || substr(SQLERRM,1,180));
   end if;
   O_error_num := l_err_num;
   O_error_code := l_err_code;
   O_error_message := l_err_msg;

 when no_acct_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_CG_ACCTS';
 FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
 O_error_message := FND_MESSAGE.Get;

 when no_txn_det_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_TXN_DET';
 FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
 O_error_message := FND_MESSAGE.Get;

 when others then

 rollback;
 if (l_debug = 'Y') then
 fnd_file.put_line (fnd_file.log, 'Inventory_accounts' || to_char(l_stmt_num)
                                     || substr(SQLERRM,1,180)) ;
 end if;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.inventory_accounts' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END inventory_accounts;

procedure distribute_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG	IN	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_COST_TXN_ACTION_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_ELEMENTAL		IN	NUMBER,
  I_OVHD_ABSP		IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2,
  I_COGS_OM_LINE_ID     IN      NUMBER
)IS
  l_ele_exist   NUMBER;
  l_acct	NUMBER;
  l_cost	NUMBER;
  l_stmt_num	NUMBER;
  l_layer_id	NUMBER;
  process_error	EXCEPTION;
  no_txn_det_error EXCEPTION;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_debug       VARCHAR2(1);
  -- dropshipment project addition
  l_cost_method NUMBER;
  l_ce_round_cost NUMBER;/* Bug 6030328*/

  l_elemental_cost      number_table;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN
  -- initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_debug := fnd_profile.value('MRP_DEBUG');


    fnd_file.put_line(fnd_file.log,'In distribute_accounts');
    fnd_file.put_line(fnd_file.log,'i_org_id:' || i_org_id );
    fnd_file.put_line(fnd_file.log,'i_txn_id:' || i_txn_id);
    fnd_file.put_line(fnd_file.log,'i_comm_iss_flag:' || i_comm_iss_flag);
    fnd_file.put_line(fnd_file.log,'i_acct_linr_type:' || i_acct_line_type);
    fnd_file.put_line(fnd_file.log,'i_elemental:' || i_elemental);
    fnd_file.put_line(fnd_file.log,'i_ovhd_absp:' || i_ovhd_absp);


    -- For the logical txns introduced in the dropshipment project, standard costing
    -- orgs will also call the average cost distribution processor. A few changes
    -- are needed to distribute_accounts() because of this so l_cost_method stores
    -- the costing method.
    l_stmt_num := 0;
    select primary_cost_method
    into l_cost_method
    from mtl_parameters
    where organization_id = i_org_id;

  if(i_elemental = 1) then


    l_stmt_num := 5;

 -- For regular WIP txns this is not reqd. However for a CITW txn we need
 -- to select layer_id and join to it in mcacd.

    if (i_comm_iss_flag = 1) then
      select layer_id into l_layer_id
      from cst_quantity_layers where
      inventory_item_id = i_item_id and
      organization_id = i_org_id and
      cost_group_id = i_cost_grp_id;
    end if;

    l_stmt_num := 10;

 -- Join on layer_id and transaction_action_id only for a CITW transaction.

    select count(*)
    into l_ele_exist
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and decode(i_comm_iss_flag,1,l_layer_id,layer_id) = layer_id
    and nvl(decode(i_comm_iss_flag,1,i_cost_txn_action_id,transaction_action_id),-99)=
					nvl(transaction_action_id,-99);

    if (l_ele_exist = 0) then
      raise no_txn_det_error;
    end if;

    FOR cost_element IN 1..5 loop
      l_cost := NULL;

      -- i_ovhd_absp indicates which level of material overhead we are
      -- absorbtion and therefore need to go in an absorption account.
      -- 2 means both levels and 1 means this level only.

      l_stmt_num := 20;

      select sum(actual_cost)
      into l_elemental_cost(cost_element)
      from mtl_cst_actual_cost_details cacd
      where transaction_id = i_txn_id
      and organization_id = i_org_id
      and cost_element_id = cost_element
    and decode(i_comm_iss_flag,1,l_layer_id,layer_id) = layer_id and
 nvl(decode(i_comm_iss_flag,1,i_cost_txn_action_id,transaction_action_id),-99)=
                                        nvl(transaction_action_id,-99)
      and (cost_element_id <> 2
           OR
           (cost_element_id = 2
            and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)));

    fnd_file.put_line(fnd_file.log,'actual_cost:' || l_elemental_cost(cost_element) );

      if (l_elemental_cost(cost_element) is not null) then

        -- dropshipment changes
        if (l_cost_method <> 1) then
          l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty),
				i_acct_line_type,
				cost_element, NULL, i_subinv,
				0, i_snd_rcv, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);
        else
          l_acct := CSTPSCHK.std_get_account_id(i_org_id, i_txn_id, sign(i_p_qty),
                         i_acct_line_type, cost_element, 0, i_subinv, i_cost_grp_id,
                         0, i_snd_rcv, l_err_num, l_err_code, l_err_msg);
        end if;

    -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

        if (l_acct = -1) then

	  l_stmt_num := 40;
          select decode(cost_element, 1, i_mat_acct,
				  2, i_mat_ovhd_acct,
				  3, i_res_acct,
				  4, i_osp_acct,
				  5, i_ovhd_acct)
          into l_acct
          from dual;
        end if;

	fnd_file.put_line(fnd_file.log, 'ElementID: ' || cost_element || ' Amt: ' || (i_p_qty * l_elemental_cost(cost_element)) ||
					' Acct: ' || l_acct);

        insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_elemental_cost(cost_element),
		i_p_qty, l_acct, i_sob_id, i_acct_line_type,
		cost_element, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

	      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

      else
         l_elemental_cost(cost_element) := 0;
      end if;
    end loop;

    -- OM transactions (Sales Order, RMAs) are always distributed elementally
    -- which is why this IF statement falls here and not below.
    IF (i_acct_line_type = 36) THEN

	  l_stmt_num := 45;
      -- The following call to Record_SoIssueCost will insert the unit
      -- costs of the sales order issue into CRCML so that subsequent
      -- COGS recognition events can use these same unit costs.

      CST_RevenueCogsMatch_PVT.Record_SoIssueCost(
                p_api_version        => 1.0,
                p_init_msg_list      => FND_API.G_TRUE,
                p_user_id            => i_user_id,
                p_login_id           => i_login_id,
                p_request_id         => i_req_id,
                p_pgm_app_id         => i_prg_appl_id,
                p_pgm_id             => i_prg_id,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_cogs_om_line_id    => I_COGS_OM_LINE_ID,
                p_pac_cost_type_id   => NULL,
                p_unit_material_cost => l_elemental_cost(1),
                p_unit_moh_cost      => l_elemental_cost(2),
                p_unit_resource_cost => l_elemental_cost(3),
                p_unit_op_cost       => l_elemental_cost(4),
                p_unit_overhead_cost => l_elemental_cost(5),
                p_unit_cost          => l_elemental_cost(1) + l_elemental_cost(2) + l_elemental_cost(3) + l_elemental_cost(4) + l_elemental_cost(5),
                p_txn_quantity       => i_p_qty);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_err_num := -1;
         FND_MSG_PUB.count_and_get
         (  p_count   => l_msg_count,
            p_data    => l_msg_data,
            p_encoded => FND_API.g_false
         );
         IF (l_msg_count = 1) THEN
            l_err_msg := substr(l_msg_data,1,240);
         ELSE
            l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Record_SoIssueCost()';
         END IF;
         raise process_error;
      END IF;

	  l_stmt_num := 48;
      /* Set the costed flag to YES in cst_cogs_events for this sales order issue */
      UPDATE cst_cogs_events
      SET costed = NULL,
          last_update_date = sysdate,
          last_updated_by = i_user_id,
          last_update_login = i_login_id,
          request_id = i_req_id
      WHERE cogs_om_line_id = i_cogs_om_line_id
      AND   mmt_transaction_id = i_txn_id;

    END IF; -- Deferred COGS Accounting
  else

    l_stmt_num := 50;

    /* Modified for BUG 8543247 */
    IF I_ACCT_LINE_TYPE = 14 THEN

    /* Bug 6030328 the cost should be rounded at elemental level*/
    l_cost := 0;
    l_ce_round_cost :=0;
    FOR cost_element IN 1..5 LOOP
    BEGIN
    select decode(c1.minimum_accountable_unit,
                  null,ROUND((nvl(sum(actual_cost),0)*abs(i_p_qty)),c1.precision)/abs(i_p_qty),
		  (ROUND((nvl(sum(actual_cost),0)*abs(i_p_qty))/c1.minimum_accountable_unit)*c1.minimum_accountable_unit)/abs(i_p_qty))
    into l_ce_round_cost
    from mtl_cst_actual_cost_details cacd,
         cst_organization_definitions cod,
	 fnd_currencies c1,
	 gl_sets_of_books gsb
    where cacd.transaction_id = i_txn_id
    and cacd.organization_id = i_org_id
    and c1.currency_code = gsb.currency_code
    and gsb.set_of_books_id = cod.set_of_books_id
    and cod.organization_id = i_org_id
    and cacd.cost_element_id = cost_element
    and (cost_element_id <> 2
         OR
         (cost_element_id = 2
          and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)))
    group by c1.minimum_accountable_unit,
             c1.precision;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_ce_round_cost := 0;
    END;
    l_cost := l_cost + l_ce_round_cost;
    END LOOP;

    /* Modified for BUG 8543247 */
    ELSE

    l_stmt_num := 55;

    select nvl(sum(actual_cost),0)
    into l_cost
    from mtl_cst_actual_cost_details cacd
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and (cost_element_id <> 2
         OR
         (cost_element_id = 2
          and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)));

    END IF; --IF I_ACCT_LINE_TYPE = 14

    fnd_file.put_line(fnd_file.log,'actual_cost(60):' || l_cost );


    l_stmt_num := 60;

    if (l_cost_method <> 1) then
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty),
				i_acct_line_type,
				NULL, NULL, i_subinv,
				0, i_snd_rcv, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);
    else
      l_acct := CSTPSCHK.std_get_account_id(i_org_id, i_txn_id, sign(i_p_qty),
                         i_acct_line_type, NULL, 0, i_subinv, i_cost_grp_id,
                         0, i_snd_rcv, l_err_num, l_err_code, l_err_msg);
    end if;

          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

    if (l_acct = -1) then
    	l_acct := i_acct;
    end if;

    l_stmt_num := 70;

    fnd_file.put_line(fnd_file.log, 'Insert account()');

    insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_cost,
		i_p_qty, l_acct, i_sob_id, i_acct_line_type,
		NULL, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

        -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

  end if;

  -- return normally
  O_Error_Num := 0;

  EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when no_txn_det_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_TXN_DET';
 FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
 O_error_message := FND_MESSAGE.Get;

 when others then
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.distribute_accounts' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

end distribute_accounts;

procedure cfm_scrap_dist_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG	IN	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_COST_TXN_ACTION_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_ELEMENTAL		IN	NUMBER,
  I_OVHD_ABSP		IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_ele_exist   NUMBER;
  l_acct	NUMBER;
  l_cost	NUMBER;
  l_stmt_num	NUMBER;
  l_layer_id	NUMBER;
  process_error	EXCEPTION;
  no_txn_det_error EXCEPTION;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
BEGIN
  -- initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

     l_stmt_num := 10;
     -- Join on layer_id and transaction_action_id only for a CITW transaction.
     select count(*)
     into l_ele_exist
     from mtl_cst_actual_cost_details
     where transaction_id = i_txn_id
     and organization_id = i_org_id;

    if (l_ele_exist = 0) then
      raise no_txn_det_error;
    end if;

    FOR cost_element IN 1..5 loop
      l_cost := NULL;
      -- i_ovhd_absp indicates which level of material overhead we are
      -- absorbtion and therefore need to go in an absorption account.
      -- 2 means both levels and 1 means this level only.
      l_stmt_num := 20;

      if (cost_element = 1) then
         select sum(actual_cost)
         into l_cost
         from mtl_cst_actual_cost_details cacd
         where transaction_id = i_txn_id
         and organization_id = i_org_id
         and (level_type = 2
             or (level_type = 1 and cost_element_id =1));
      elsif (cost_element <> 2) then
         select sum(actual_cost)
         into l_cost
         from mtl_cst_actual_cost_details cacd
         where transaction_id = i_txn_id
         and organization_id = i_org_id
         and level_type = 1
         and cost_element_id = cost_element;
      end if;

      if (l_cost is not null AND cost_element <> 2) then
         l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty),
				i_acct_line_type,
				cost_element, NULL, i_subinv,
				0, i_snd_rcv, l_err_num, l_err_code,
				l_err_msg,i_cost_grp_id);
         -- check error
         if(l_err_num<>0) then
            raise process_error;
         end if;

         l_stmt_num := 40;
         select decode(cost_element, 1, i_mat_acct,
		    		     2, i_mat_ovhd_acct,
				     3, i_res_acct,
				     4, i_osp_acct,
				     5, i_ovhd_acct)
         into l_acct
         from dual;

         insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_cost,
		        i_p_qty, l_acct, i_sob_id, i_acct_line_type,
		        cost_element, NULL,
		        i_txn_date, i_txn_src_id, i_src_type_id,
		        i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		        1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		        l_err_num, l_err_code, l_err_msg);

	  -- check error
          if(l_err_num<>0) then
             raise process_error;
          end if;
      end if;
    end loop;

  EXCEPTION
     when process_error then
     rollback;
     O_error_num := l_err_num;
     O_error_code := l_err_code;
     O_error_message := l_err_msg;

     when no_txn_det_error then
     rollback;
     O_error_num := 9999;
     O_error_code := 'CST_NO_TXN_DET';
     FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
     O_error_message := FND_MESSAGE.Get;

     when others then
     rollback;
     O_error_num := SQLCODE;
     O_error_message := 'CSTPACDP.cfm_scrap_dist_accounts' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);
end cfm_scrap_dist_accounts;

procedure ovhd_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_res_id	NUMBER;
  l_cost	NUMBER;
  l_acct	NUMBER;
  l_stmt_num 	NUMBER;
  process_error	EXCEPTION;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);

  cursor mat_ovhds is
    select resource_id, actual_cost
    from mtl_actual_cost_subelement
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and cost_element_id = 2;
BEGIN
  -- Initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  open mat_ovhds;

  loop
    fetch mat_ovhds into l_res_id, l_cost;
    exit when mat_ovhds%NOTFOUND;

    l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_p_qty), 3,
				2, l_res_id, i_subinv,
				0, i_snd_rcv, l_err_num, l_err_code,
				l_err_msg,NULL);
          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

    if (l_acct = -1) then

      l_stmt_num := 10;

      select nvl(absorption_account,-1)
      into l_acct
      from bom_resources
      where resource_id = l_res_id
      and organization_id = i_org_id;

    end if;


    insert_account(i_org_id, i_txn_id, i_item_id, i_p_qty * l_cost,
		i_p_qty, l_acct, i_sob_id, 3,
		2, l_res_id,
		i_txn_date, i_txn_src_id, i_src_type_id,
		i_pri_curr, i_alt_curr, i_conv_date, i_conv_rate, i_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;


  end loop;

  EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.ovhd_accounts' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END ovhd_accounts;


procedure encumbrance_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_ENC_AMOUNT		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ENC_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_acct	NUMBER;
  l_acct_line_type NUMBER;
  l_act_flag    NUMBER; -- Flag to indicate the insert_account if encumbrance
                        -- is being used.
  l_stmt_num 	NUMBER;
  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  process_error	EXCEPTION;
BEGIN
  -- initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_acct_line_type := 15;

  l_act_flag := 0;    -- 0 means that encumbrance is being used

  l_stmt_num := 10;

  l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(i_enc_amount), l_acct_line_type,
				NULL, NULL, NULL,
				0, NULL, l_err_num, l_err_code,
				l_err_msg,NULL);

  -- check error
  if(l_err_num<>0) then
     raise process_error;
  end if;

  if (l_acct = -1) then
    l_acct := i_enc_acct;
  end if;


  insert_account(i_org_id, i_txn_id, i_item_id, i_enc_amount,
		i_p_qty, l_acct, i_sob_id, l_acct_line_type,
		NULL, NULL,
		i_txn_date, i_txn_src_id, i_src_type_id, i_pri_curr, i_alt_curr,
		i_conv_date, i_conv_rate, i_conv_type,
		l_act_flag,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

  -- check error
  if(l_err_num<>0) then
     raise process_error;
  end if;


 EXCEPTION

 when process_error then
 rollback;
 O_error_num := l_err_num;
 O_error_code := l_err_code;
 O_error_message := l_err_msg;

 when others then
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.encumbrance_account' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END encumbrance_account;

/*============================================================================+
|    Function to create specific entries in mtl_transaction account given
|    item cost and quantity, etc.
|    Also used in creating encumbrance entries.
|    act_flg    1 = Actual
|               0 = Encumbrance
+============================================================================*/

PROCEDURE insert_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_VALUE		IN	NUMBER,
  I_QTY			IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_COST_ELEMENT_ID	IN	NUMBER,
  I_RESOURCE_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_ACT_FLAG            IN      NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_operating_unit NUMBER;
  l_req_enc_id     NUMBER;
  l_po_enc_id      NUMBER;
  l_stmt_num 	   NUMBER;
  l_err_num	   NUMBER;
  l_err_code	   VARCHAR2(240);
  l_err_msg	   VARCHAR2(240);
  invalid_acct_error EXCEPTION;
  l_debug          VARCHAR2(1);

  /*Bug #2755069 */
  l_txn_type	   NUMBER;
  l_ussgl_tc       VARCHAR(30);
  l_enc_rev 	   NUMBER;

  /*Bug 9808677 */
  l_conv_rate 	   NUMBER;
  l_conv_date 	   DATE;
  l_conv_type 	   VARCHAR2(30);

BEGIN
  -- Initialize variables;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_conv_rate := i_conv_rate;
  l_conv_date := i_conv_date;
  l_conv_type := i_conv_type;

  fnd_file.put_line(fnd_file.log, 'In insert accounts');

  if (i_acct = -1) then
    raise invalid_acct_error;
  end if;

  /* Bug #2755069 */

  l_stmt_num := 1;
  select decode(encumbrance_reversal_flag,1,1,2,0,0)
  into   l_enc_rev
  from   mtl_parameters
  where  organization_id = i_org_id;

  l_stmt_num := 2;
  IF(l_enc_rev = 1) THEN
     SELECT transaction_type_id
     INTO l_txn_type
     FROM mtl_material_transactions
     WHERE transaction_id = i_txn_id;

     IF( (l_txn_type = 18) OR (l_txn_type = 36) OR (l_txn_type = 71) ) THEN

       IF(i_acct_line_type = 1 AND i_cost_element_id = 1) THEN
         l_stmt_num := 3;
         SELECT rsl.ussgl_transaction_code
         INTO l_ussgl_tc
         FROM mtl_material_transactions mmt,
              rcv_transactions rt,
	      rcv_shipment_lines rsl
         WHERE mmt.transaction_id = i_txn_id
	 AND   mmt.rcv_transaction_id = rt.transaction_id
	 AND   rt.shipment_line_id = rsl.shipment_line_id;

       ELSIF (i_acct_line_type = 15) THEN

         l_stmt_num := 4;
         SELECT POD.ussgl_transaction_code, nvl(pod.rate,1), pod.rate_date, poh.rate_type
         INTO l_ussgl_tc, l_conv_rate, l_conv_date, l_conv_type
         FROM mtl_material_transactions mmt,
              rcv_transactions rt,
              po_distributions_all pod,
              po_headers_all poh
         WHERE mmt.transaction_id = i_txn_id
         AND   mmt.rcv_transaction_id = rt.transaction_id
         AND   pod.po_distribution_id = rt.po_distribution_id
         AND   pod.po_header_id = poh.po_header_id;
       END IF;
     END IF;
  END IF; /* IF(l_enc_rev = 1) */

  FND_FILE.put_line(FND_FILE.log,'l_ussgl_tc : '||l_ussgl_tc);


/* The following select statement will be made to refer to cst_organization_definitions as an impact of the HR-PROFILE option */
  l_stmt_num := 5;
  if (i_act_flag = 0) then
    SELECT NVL(operating_unit,-1)
    INTO l_operating_unit
    /*FROM org_organization_definitions */
    FROM  cst_organization_definitions
    WHERE organization_id = i_org_id;

    l_stmt_num := 6;
    SELECT g1.encumbrance_type_id, g2.encumbrance_type_id
    INTO l_req_enc_id, l_po_enc_id
    FROM gl_encumbrance_types g1, gl_encumbrance_types g2
    WHERE g1.encumbrance_type_key = 'Commitment' AND
          g2.encumbrance_type_key = 'Obligation';

  end if;

  l_stmt_num := 10;

  insert into mtl_transaction_accounts (
        inv_sub_ledger_id, /* R12 - SLA Distribution Link */
	transaction_id,
	reference_account,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
 	inventory_item_id,
	organization_id,
	transaction_date,
	transaction_value,
	accounting_line_type,
	base_transaction_value,
	basis_type,
	contra_set_id,
	resource_id,
	cost_element_id,
	currency_code,
	currency_conversion_date,
	currency_conversion_rate,
	currency_conversion_type,
	primary_quantity,
	rate_or_amount,
	transaction_source_type_id,
	transaction_source_id,
	encumbrance_type_id,
        ussgl_transaction_code)
  select
        /* Bug 9356654- Costing Single Event Approach for Inventory
	For encumbrance line making inv_subledger_id value as -ive
	to indicate single event encumbrance data
	*/
	decode(i_acct_line_type,
	       15,
		-1*CST_INV_SUB_LEDGER_ID_S.NEXTVAL,
		CST_INV_SUB_LEDGER_ID_S.NEXTVAL
		),
	i_txn_id,
	i_acct,
	sysdate,
	i_user_id,
	sysdate,
	i_user_id, i_login_id,
	i_req_id,
	i_prg_appl_id,
	i_prg_id,
	sysdate,
	i_item_id,
	i_org_id,
	to_date(i_txn_date,'DD-MM-RR'),
	decode(i_alt_curr,NULL, NULL,
	       i_pri_curr, NULL,
	       decode(c2.minimum_accountable_unit,
			NULL, round(i_value/l_conv_rate, c2.precision),
			round(i_value/l_conv_rate
			/c2.minimum_accountable_unit)
			* c2.minimum_accountable_unit )),
	i_acct_line_type,
	decode(c1.minimum_accountable_unit,
			NULL, round(i_value, c1.precision),
			round(i_value/c1.minimum_accountable_unit)
			* c1.minimum_accountable_unit ),
	1,
	1,
	i_resource_id,
	i_cost_element_id,
	decode(i_alt_curr, i_pri_curr, NULL, i_alt_curr),
      	decode(i_alt_curr, i_pri_curr, NULL, l_conv_date),
      	decode(i_alt_curr, i_pri_curr, NULL, l_conv_rate),
	decode(i_alt_curr, i_pri_curr, NULL, l_conv_type),
	decode(i_acct_line_type,
		1, i_qty, --inventory
		14, i_qty, --intransit inventory
		3, i_qty, -- overhead absorption
		abs(i_qty) * decode(sign(i_value), 0, sign(i_qty), sign(i_value))
	),	-- primary quantity
	decode(i_qty, 0,0,
		decode(i_acct_line_type,
			1, i_value/i_qty,
			14, i_value/i_qty,
			3, i_value/i_qty,
			abs(i_value/i_qty)
			)
	), -- rate_or_amount
	i_src_type_id,
	nvl(i_txn_src_id,-1),
	decode(i_act_flag,1,NULL,0,decode(i_src_type_id,
                                        1,l_po_enc_id,
                                        7,l_req_enc_id,
                                        8,l_req_enc_id,
                                        NULL),NULL),
        decode(l_enc_rev,1,
	   decode(l_txn_type,
                18, decode(i_acct_line_type,
				1, decode(i_cost_element_id,1, l_ussgl_tc,NULL),
				15, l_ussgl_tc, NULL),
                36, decode(i_acct_line_type,
                                1, decode(i_cost_element_id,1, l_ussgl_tc,NULL),
                                15, l_ussgl_tc, NULL),
                71, decode(i_acct_line_type,
                                1, decode(i_cost_element_id,1, l_ussgl_tc,NULL),
                                15, l_ussgl_tc, NULL),
                NULL),
	   NULL)
  from
	fnd_currencies c1,
	fnd_currencies c2
  where
	c1.currency_code = i_pri_curr
    and c2.currency_code = decode(i_alt_curr, NULL, i_pri_curr, i_alt_curr);

  EXCEPTION

 when invalid_acct_error then
 rollback;
 O_error_num := 9999;
 O_error_code := 'CST_NO_TXN_INVALID_ACCOUNT';
 FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
 O_error_message := FND_MESSAGE.Get;

 when others then
 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.insert_account (' || to_char(l_stmt_num)
                     || ') ' || substr(SQLERRM,1,180);
  FND_FILE.put_line(FND_FILE.log,'DS - others Exception, sqlcode = '||SQLCODE);

end insert_account;

procedure balance_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
)IS
  l_stmt_num	NUMBER;
  l_rowid	ROWID;
  l_base_value	NUMBER;
  l_value	NUMBER;
  l_debug       VARCHAR2(1);

BEGIN

  l_stmt_num := 10;
  l_debug := fnd_profile.value('MRP_DEBUG');
  IF (l_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log,'In balance account!!!!');
  END IF;

  select nvl(sum(base_transaction_value),0), nvl(sum(transaction_value),0)
  into l_base_value, l_value
  from mtl_transaction_accounts
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  and accounting_line_type <> 15;

  if (l_base_value = 0 and l_value = 0) then
    return;
  end if;
  IF (l_debug = 'Y') THEN
   fnd_file.put_line(fnd_file.log, 'Adjustment Amount(l_base_value): '||l_base_value);
   fnd_file.put_line(fnd_file.log, 'Adjustment Amount(l_value): '||l_value);
  END IF;
  l_stmt_num := 20;

-- Bug# 4052277 (propagation of 4015478).
-- Added condition in where clause to check that balance amount should not be
-- adjusted against records with Accounting line type of 9 and 10 since these
-- pertain to INTERORG Transfers where the Transaction value of Inter Org
-- Receivables (Actg Line type 9) should always match the value of Inter Org
-- Payables (Actg Line type 10).

   /* Exclude the encumbrance line as well */
   /*Bug8243112: First find a line which can absorb both l_base_value
                 and l_value
   */
	SELECT MAX(rowid)
	INTO   l_rowid
	FROM   mtl_transaction_accounts
	WHERE  transaction_id = i_txn_id
	AND    organization_id = i_org_id
	AND    accounting_line_type NOT IN (9,10,15) /* this condition added for 4052277 */
	AND    sign(base_transaction_value - l_base_value) *
	       sign(nvl(decode(transaction_value, NULL,
				decode(l_value, 0, NULL,-1*l_value),
                               transaction_value - l_value),0)) >= 0;

       IF (l_rowid IS NOT NULL ) THEN
	 l_stmt_num := 30;
         IF (l_debug = 'Y') THEN
           fnd_file.put_line(fnd_file.log,'Adjusting Balance value against record ' || l_rowid);
         END IF;

         update mtl_transaction_accounts
           set transaction_value = decode(transaction_value, NULL,
                                          decode(l_value, 0, NULL,-1*l_value),
				          transaction_value - l_value),
               base_transaction_value = base_transaction_value - l_base_value
          where rowid = l_rowid;

       ELSE /*l_rowid is null */
        /*Bug8243112: If not found then find a row which can absorb l_value*/
	l_stmt_num := 40;
	IF (l_debug = 'Y') THEN
         fnd_file.put_line(fnd_file.log,'Could not find one single row which can absorb both l_value and l_base_value ');
	 fnd_file.put_line(fnd_file.log,'Finding row which can absorb l_value ');
	END IF;

        SELECT MAX(rowid)
	INTO   l_rowid
	FROM   mtl_transaction_accounts
	WHERE  transaction_id = i_txn_id
	AND    organization_id = i_org_id
	AND    accounting_line_type NOT IN (9,10,15)
	AND    sign(base_transaction_value) *
	       sign(nvl(decode(transaction_value, NULL,
				decode(l_value, 0, NULL,-1*l_value),
				transaction_value - l_value),0)) >= 0;
        l_stmt_num := 50;
	IF (l_debug = 'Y') THEN
         fnd_file.put_line(fnd_file.log,'Adjusting the transaction value balance value against record ' || l_rowid);
	END IF;

	update mtl_transaction_accounts
           set transaction_value = decode(transaction_value, NULL,
	                                  decode(l_value, 0, NULL,-1*l_value),
				          transaction_value - l_value)
        where rowid = l_rowid;
        /*Bug8243112: Then find a row which can absorb l_base_value*/
	l_stmt_num := 60;
	IF (l_debug = 'Y') THEN
	 fnd_file.put_line(fnd_file.log,'Finding row which can absorb l_base_value ');
	END IF;

	SELECT MAX(rowid)
	INTO   l_rowid
	FROM   mtl_transaction_accounts
	WHERE  transaction_id = i_txn_id
	AND    organization_id = i_org_id
	AND    accounting_line_type NOT IN (9,10,15)
	AND    sign(base_transaction_value-l_base_value) *
	       sign(nvl(transaction_value,0)) >= 0;

        l_stmt_num := 70;
	IF (l_debug = 'Y') THEN
         fnd_file.put_line(fnd_file.log,'Adjusting the base transaction value balance value against record ' || l_rowid);
        END IF;

	update mtl_transaction_accounts
          set  base_transaction_value = base_transaction_value - l_base_value
         where rowid = l_rowid;

      END IF;

  EXCEPTION

 when others then

 rollback;
 O_error_num := SQLCODE;
 O_error_message := 'CSTPACDP.balance_account (' || to_char(l_stmt_num) ||
                     ') ' || substr(SQLERRM,1,180);

END balance_account;

/*
|-------------------------------------------------------------------------
|    OPM INVCONV umoogala 15-Apr-2005  Process-Discrete Xfers Enh.
|
|    added new function cost_process_discrete_trx to cost transfer
|    involving Discrete Standard Costing Orgs only. This new routine will
|              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
|    be called from cmlmcw.lpc.
|
|    Note: Process Mfg. Orgs are always marked as Standard Costing Orgs.
|
|    All the entries are for the transaction org only i.e., discrete
|    costing orgs.
|    All the intransit entries are booked using new logical transaction
|    types:
|           22: Logical Intransit Shipment
|           15: Logical Intransit Receipt
|-------------------------------------------------------------------------
|    This code is almost same as inltcp.lpc code for interorg transfers.
|    All the code which is not needed for Process-Discrete Transfers is
|    removed. The main code section are like this:
|
|    case (txn_action_id)
|      when 3 and 21
|      then
|       ... Direct xfers (incomming and outgoing) and intransit shipments
|      when 12
|      then
|       ... Intransit receipts
|      when 22
|      then
|       ... Logical Intransit Shipments
|      when 15
|      then
|       ... Logical Intransit receipts
|    End case (txn_action_id)
|
| History
|  03/27/05      umoogala     Bug 4432078  OPM INVCONV  Process-Discrete Transfers Enh.
|  12/20/05      umoogala     Bug 4885752/4658325
|                               Quantities are not recorded with a proper sign in mta.
|                               Fixed calls to book accounts to send correct sign.
|  11-Aug-2006   ANTHIYAG     Bug#5459157
|                               Modified Code to remove the quantity from being multipled
|                               with the value fetched from MTA table, since the value already
|                               has the quantity accounted for.
|  08-Sep-2006   ANTHIYAG     Bug#5352186
|                               Modifications to pass the Currency details in the receipt organization
|                               distributin entries which refer to Freight Charges and Transfer price
|                               details which are fetched from the sending organization's setup data.
|-------------------------------------------------------------------------
*/

PROCEDURE cost_process_discrete_trx(
  trans_id      IN BINARY_INTEGER
, prg_appid     IN BINARY_INTEGER
, prg_id        IN BINARY_INTEGER
, req_id        IN BINARY_INTEGER
, user_id       IN BINARY_INTEGER
, login_id      IN BINARY_INTEGER

, O_Error_Num     OUT NOCOPY VARCHAR2
, O_Error_Code    OUT NOCOPY VARCHAR2
, O_Error_Message OUT NOCOPY VARCHAR2
)
IS
  alt_curr           VARCHAR2(15);
  conv_date          DATE;
  conv_type          VARCHAR2(30);
  error_code         VARCHAR2(241);
  error_msg          VARCHAR2(241);
  flow_sch           VARCHAR2(2);
  pri_curr           VARCHAR2(15);
  rec_curr           VARCHAR2(15);
  rec_uom            VARCHAR2(3);
  send_curr          VARCHAR2(15);
  send_uom           VARCHAR2(15);
  subinv             VARCHAR2(11);
  txf_subinv         VARCHAR2(11);
  wms_return_status  VARCHAR2(11);
  wms_msg_data       VARCHAR2(2000);
  buffer             VARCHAR2(80);
  i_conv_type        VARCHAR2(241);
  interorg_conv_type VARCHAR2(241);
  mesg               VARCHAR2(241);
  price_err_code     VARCHAR2(241);
  price_err_expl     VARCHAR2(241);

  txn_date           DATE;

  conv_rate          NUMBER;
  enc_amt            NUMBER;
  interorg_xfr_price NUMBER;
  sending_org_cost   NUMBER;
  interorg_profit    NUMBER;
  ppv_amt            NUMBER;
  p_qty              NUMBER;
  prior_cost         NUMBER;
  rprior_cost        NUMBER;
  new_cost           NUMBER;
  qty_adj            NUMBER;
  txf_cost           NUMBER;
  trp_cost           NUMBER;
  recamt             NUMBER;
  payamt             NUMBER;
  rec_item_cost      NUMBER;
  send_item_cost     NUMBER;
  send_p_qty         NUMBER;
  rec_p_qty          NUMBER;
  send_txf_cost      NUMBER;
  send_trp_cost      NUMBER;
  tmp_act_cost       NUMBER;
  txf_price          NUMBER;
  txn_cost           NUMBER;
  act_cost           NUMBER;
  ract_cost          NUMBER;
  item_cost          NUMBER;
  uom_conv_rate      NUMBER;
  l_txn_cost         NUMBER;
  l_rec_txn_cost     NUMBER;
  var_amt            NUMBER;

  interorg_profit_acct     BINARY_INTEGER;
  org_opm_flag             BINARY_INTEGER;
  pd_txf_flag              BINARY_INTEGER;
  txf_org_opm_flag         BINARY_INTEGER;
  acc_line_type            BINARY_INTEGER;
  acct_period_id           BINARY_INTEGER;
  alias_acct               BINARY_INTEGER;
  cstud_id                 BINARY_INTEGER;
  txn_act_id               BINARY_INTEGER;
  txn_src_id               BINARY_INTEGER;
  enc_acct                 BINARY_INTEGER;
  sob_id                   BINARY_INTEGER;
  enc_rev                  BINARY_INTEGER;
  flow_sch_flg             BINARY_INTEGER;
  fob_pt                   BINARY_INTEGER;
  iexp_flg                 BINARY_INTEGER;
  exp_flg                  BINARY_INTEGER;
  rexp_flg                 BINARY_INTEGER;
  exp_acct                 BINARY_INTEGER;
  rexp_acct                BINARY_INTEGER;
  exp_sub                  BINARY_INTEGER;
  rexp_sub                 BINARY_INTEGER;
  io_inv_acct              BINARY_INTEGER;
  io_txfr_cr_acct          BINARY_INTEGER;
  io_rec_acct              BINARY_INTEGER;
  io_pay_acct              BINARY_INTEGER;
  io_ppv_acct              BINARY_INTEGER;
  item_id                  BINARY_INTEGER;
  org_id                   BINARY_INTEGER;
  l_cost_method            BINARY_INTEGER;
  l_trf_cost_method        BINARY_INTEGER;
  l_drop_ship_type_code    BINARY_INTEGER;
  l_stmt_num               BINARY_INTEGER;
  l_trf_organization_id    BINARY_INTEGER;
  op_seq_num               BINARY_INTEGER;
  mv_id                    BINARY_INTEGER;
  p_cst_type               BINARY_INTEGER;
  inv_acct                 BINARY_INTEGER;
  ap_acct                  BINARY_INTEGER;
  cog_acct                 BINARY_INTEGER;
  acv_acct                 BINARY_INTEGER;
  ppv_acct                 BINARY_INTEGER;
  pjm_flg                  BINARY_INTEGER;
  txf_pjm_flg              BINARY_INTEGER;
  return_code              BINARY_INTEGER;
  err_num                  BINARY_INTEGER;
  ccga_count               BINARY_INTEGER;
  send_inv_acct            BINARY_INTEGER;
  rec_inv_acct             BINARY_INTEGER;
  send_p_cst_type          BINARY_INTEGER;
  rec_p_cst_type           BINARY_INTEGER;
  send_sob_id              BINARY_INTEGER;
  rec_sob_id               BINARY_INTEGER;
  src_line_id              BINARY_INTEGER;
  src_type_id              BINARY_INTEGER;
  dist_acct                BINARY_INTEGER;
  trp_acct                 BINARY_INTEGER;
  tprice_option            BINARY_INTEGER;
  txf_org_id               BINARY_INTEGER;
  txn_type_id              BINARY_INTEGER;
  wms_flg                  BINARY_INTEGER;
  txf_wms_flg              BINARY_INTEGER;
  wms_msg_count            BINARY_INTEGER;
  abs_ovhd                 BINARY_INTEGER;
  mvi                      BINARY_INTEGER;
  ent_type                 BINARY_INTEGER;
  lot_based_job            BINARY_INTEGER;
  realoc_yld_cost          BINARY_INTEGER;
  tnx_type                 BINARY_INTEGER;
  zero_cost_flag           BINARY_INTEGER;
  comp_txn_id              BINARY_INTEGER;
  txf_txn_id               BINARY_INTEGER;
  CG_ID                    BINARY_INTEGER;
  TXF_CG_ID                BINARY_INTEGER;
  mv_idmvi                 BINARY_INTEGER;

  from_org                 BINARY_INTEGER;
  to_org                   BINARY_INTEGER;
  from_cost_grp            BINARY_INTEGER;
  to_cost_grp              BINARY_INTEGER;

  l_return_status	         VARCHAR2(80);
  l_return_code		         BINARY_INTEGER;
  l_msg_count		           BINARY_INTEGER;
  l_msg_data		           VARCHAR2(2000);

  l_debug                  VARCHAR2(1);

  snd_rcv                  BINARY_INTEGER;
  mat_acct                 BINARY_INTEGER;
  mat_ovhd_acct            BINARY_INTEGER;
  res_acct                 BINARY_INTEGER;
  osp_acct                 BINARY_INTEGER;
  ovhd_acct                BINARY_INTEGER;
  user_acct_id             BINARY_INTEGER;
  l_earn_moh               BINARY_INTEGER := 1;

  errexit                  exception;

  /* SLA Event Creation */
  l_trx_info              CST_XLA_PVT.t_xla_inv_trx_info;

  moh_rules_error         EXCEPTION;

  --
  -- Bug 5233635; Should not book InterOrg Profit when Intercompany Invoicing is enabled.
  --
  l_io_invoicing          NUMBER;
  l_org_ou                NUMBER;
  l_txf_org_ou            NUMBER;

  /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 Start */
  l_snd_sob_id	          NUMBER;
  l_snd_curr	            VARCHAR2(10);
  l_rcv_sob_id	          NUMBER;
  l_rcv_curr	            VARCHAR2(10);
  l_curr_type	            VARCHAR2(30);
  l_conv_rate	            NUMBER;
  l_conv_date	            DATE;
  /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 End */

begin
  fnd_file.put_line(fnd_file.log, 'cost_process_discrete_trx <<<');
  l_debug := fnd_profile.value('MRP_DEBUG');

  /* Check if the organization_id and/or transfer_organization_id
     are average or FIFO/LIFO orgs. If so, error out this transaction, since it is just meant
     for Standard Costing
  */
  l_stmt_num := 10;


  select
        inventory_item_id, organization_id,
        transaction_date,
        primary_quantity, subinventory_code, nvl(cost_group_id,0),
        transfer_organization_id, nvl(prior_cost,0), nvl(new_cost,0),
        nvl(transaction_cost,0), nvl(actual_cost,0),
        quantity_adjusted, nvl(transfer_cost,0), nvl(transportation_cost,0),
        nvl(transportation_dist_account,-1),
        nvl(flow_schedule, 'N'),
        DECODE(completion_transaction_id,NULL,0,-1,0,completion_transaction_id),
        cost_update_id, transaction_action_id,
        decode( transaction_source_type_id, 16, -1, nvl(transaction_source_id,-1) ),
        transfer_subinventory, nvl(transfer_cost_group_id,0),
        nvl(transfer_transaction_id,0), trx_source_line_id,
        transaction_source_type_id, nvl(distribution_account_id,-1),
        acct_period_id, operation_seq_num,
        currency_code,
        nvl(currency_conversion_date,transaction_date),
        nvl(currency_conversion_rate,-1) , currency_conversion_type,
        nvl(encumbrance_account,-1), nvl(encumbrance_amount,0),
        nvl(variance_amount,0), movement_id,
        transaction_type_id, nvl(transfer_price, 0)
    INTO
        item_id, org_id, txn_date,
        p_qty, subinv, cg_id,
        txf_org_id, prior_cost, new_cost,
        txn_cost, act_cost,
        qty_adj, txf_cost, trp_cost,
        trp_acct,
        flow_sch,
        comp_txn_id,
        cstud_id, txn_act_id,
        txn_src_id,
        txf_subinv, txf_cg_id,
        txf_txn_id, src_line_id,
        src_type_id, dist_acct,
        acct_period_id, op_seq_num,
        alt_curr, conv_date,
        conv_rate, conv_type,
        enc_acct, enc_amt,
        var_amt, mv_idmvi,
        txn_type_id, interorg_xfr_price
     from mtl_material_transactions
     where transaction_id = trans_id;


  -- code to stop profile is at the end of this procedure.
  --
    fnd_file.put_line(fnd_file.log, 'src/act: ' || src_type_id ||'/'|| txn_act_id);

    fnd_file.put_line(fnd_file.log, 'txnId/Org: ' || trans_id || '/' || org_id ||
          ', xferOrg: ' || txf_org_id || ' XferPrice: ' || interorg_xfr_price ||
          ', p_qty: ' || p_qty);
    fnd_file.put_line(fnd_file.log, 'cg_id: ' || cg_id);

    --
    -- Bug 5233635; Should not book InterOrg Profit when Intercompany Invoicing is enabled.
    --
    l_stmt_num := 11;

    SELECT to_number(org_information3)
    INTO   l_org_ou
    FROM   hr_organization_information
    WHERE  org_information_context = 'Accounting Information'
    AND    organization_id = org_id;

    l_stmt_num := 12;
    SELECT to_number(org_information3)
    INTO   l_txf_org_ou
    FROM   hr_organization_information
    WHERE  org_information_context = 'Accounting Information'
    AND    organization_id = txf_org_id;

    l_io_invoicing := to_number(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'));
    fnd_file.put_line(fnd_file.LOG, 'OU/xferOU: ' || l_org_ou ||'/'||l_txf_org_ou||
      ' Internal Order invoicing: ' || l_io_invoicing);

    --
    -- End Bug 5233635
    --

    /*----------------------------------------------------------------------+
     -- set WMS flag
     +----------------------------------------------------------------------*/
    if(wms_install.check_install(l_return_status, l_msg_count, l_msg_data,org_id))
    then
      wms_flg := 1;
    else
      wms_flg := 0;
    end if;


    /*----------------------------------------------------------------------+
     -- set PJM flag
     +----------------------------------------------------------------------*/
    /* Changes for PJM Standard Costing. */
    /*Check if cost group accounting has been enabled. */
    l_stmt_num := 55;

    SELECT decode(nvl(cost_group_accounting,0),0,0,
             decode(nvl(project_reference_enabled,0),1,1,0))
      INTO pjm_flg
      FROM MTL_PARAMETERS
     WHERE organization_id = org_id;

    fnd_file.put_line(fnd_file.log, 'wms_flg: ' || wms_flg || ' pjm_flg: ' || pjm_flg);

    l_stmt_num := 60;

    /* Not sure what to do here!
     *
    switch(inltcl(trans_id, prg_appid, prg_id, req_id, user_id, login_id))
    {
    case 0:
        break;

    case 1:
        if (txn_act_id == 3)
        {
            l_stmt_num := 70;

            EXEC SQL select
                primary_cost_method
            INTO
                :rec_p_cst_type
            from mtl_parameters
            where organization_id = :txf_org_id;

            l_stmt_num := 80;
        }

        goto update_cost;

    case -1:

       if (afdname((text *)'BOM', (text *)'CST_ERR_LOCAL_COSTING'));
       else
          DISCARD afdstring((text *)'CST_ERR_LOCAL_COSTING');
       afdget(msgbuf1,241);
       vchfroms(err_expl,msgbuf1);
       vchfroms(err_code,msgbuf1);
       DISCARD NLSSCPY(errbuf, msgbuf1);
       afdclear();


       raise errexit;

    }
    */

   /*------------------------------------------------------------+
    |  Initialize flow schedule flag to 0.  Set it to 1 if the
    |  column flow_schedule is set to 'Y' in mmt.
    +------------------------------------------------------------*/

    if flow_sch = 'Y'
    then
      flow_sch_flg := 1;
    else
      flow_sch_flg := 0;
    end if;


    l_stmt_num := 125;
    CST_Utility_PUB.get_zeroCostIssue_flag (
      p_api_version	=> 1.0,
      x_return_status	=> l_return_status,
      x_msg_count	=> l_msg_count,
      x_msg_data	=> l_msg_data,
      p_txn_id		=> trans_id,
      x_zero_cost_flag	=> zero_cost_flag
      );

    l_stmt_num := 130;

    select
        primary_cost_method,
        material_account, ap_accrual_account, cost_of_sales_account,
        purchase_price_var_account, average_cost_var_account,
        decode(encumbrance_reversal_flag,1,1,2,0,0),
        material_account, material_overhead_account, resource_account,
        outside_processing_account, overhead_account,
        expense_account
    INTO
        p_cst_type,
        inv_acct, ap_acct, cog_acct,
        ppv_acct, acv_acct,
        enc_rev,
        mat_acct, mat_ovhd_acct, res_acct,
        osp_acct, ovhd_acct,
        exp_acct
     from mtl_parameters
     where organization_id = org_id;


    /*----------------------------------------------------------------------+
     | Get SOB and base currency
     +----------------------------------------------------------------------*/
    l_stmt_num := 140;
    select cod.set_of_books_id, sob.currency_code
      INTO sob_id, pri_curr
      FROM cst_organization_definitions cod, gl_sets_of_books sob
     WHERE cod.organization_id = org_id
       AND sob.set_of_books_id = cod.set_of_books_id;


    /*----------------------------------------------------------------------+
     | Set expense flags
     +----------------------------------------------------------------------*/
    l_stmt_num := 160;
    select decode(inventory_asset_flag,'Y',0,1), nvl(expense_account, -1)
      INTO iexp_flg, exp_acct
      FROM mtl_system_items_b
     WHERE inventory_item_id = item_id
       AND organization_id = org_id;


    --
    -- Bug 4748551: Added if block to set SubInv as Asset SubInv when
    -- SubInv column is NULL. For intransit transfers, receiving SubInv
    -- may be null.
    --
    l_stmt_num := 170;
    if subinv is null
    then
      exp_sub := 0;
      exp_flg := 0;
    else
      --
      -- Bug 5337293: retain exp flag setting of item for intransit transfers
      --
      SELECT DECODE(txn_act_id, 3, DECODE(iexp_flg,1,1,DECODE(asset_inventory,1,0,1)),
                                iexp_flg),
             DECODE(asset_inventory,1,0,1)
        INTO exp_flg, exp_sub
        FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = subinv
         AND organization_id = org_id;
    end if;

    fnd_file.put_line(fnd_file.log, 'iexp_flag/exp_flg/exp_sub: ' || iexp_flg ||'/'|| exp_flg || '/'|| exp_sub);


    /*----------------------------------------------------------------------+
     | Get elemental accounts
     +----------------------------------------------------------------------*/
    l_stmt_num := 180;
    if (wms_flg = 0)
    then

       --
       -- Bug 4748551: Added if block to set SubInv as Asset SubInv when
       -- SubInv column is NULL. For intransit transfers, receiving SubInv
       -- may be null.
       --
       l_stmt_num := 190;
       if subinv is null
       then
         -- l_stmt_num := 191;
         -- We've already populated accounts from mtl_parameters above (stmt 130)
         NULL;
       else
         l_stmt_num := 192;
         select material_account, material_overhead_account, resource_account,
                outside_processing_account, overhead_account,
                nvl(expense_account, exp_acct)
           into mat_acct, mat_ovhd_acct, res_acct,
                osp_acct, ovhd_acct,
                exp_acct
           from mtl_secondary_inventories msi
          where msi.organization_id = org_id
            and secondary_inventory_name = subinv;
       end if;
    else
     if (cg_id = 1)
     then
        l_stmt_num := 210;

        select material_account, material_overhead_account, resource_account,
               outside_processing_account, overhead_account,
               nvl(expense_account, exp_acct)
          into mat_acct, mat_ovhd_acct, res_acct,
               osp_acct, ovhd_acct,
               exp_acct
          from mtl_parameters
         where organization_id = org_id;

     else
         l_stmt_num := 230;

         select count(*)
           INTO ccga_count
           FROM cst_cost_group_accounts
	        WHERE cost_group_id = cg_id
            AND organization_id = org_id;

         l_stmt_num := 240;
         if (ccga_count = 0)
         then
            FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
            O_Error_Num     := NULL;
            O_Error_Code    := 'CST_NO_CG_ACCTS';
            O_Error_Message := FND_MESSAGE.get;
            raise errexit;
         else
            l_stmt_num := 250;

            select material_account, material_overhead_account, resource_account,
                   outside_processing_account, overhead_account,
                   nvl(expense_account, exp_acct)
              into mat_acct, mat_ovhd_acct, res_acct,
                   osp_acct, ovhd_acct,
                   exp_acct
              from cst_cost_group_accounts
             where organization_id = org_id
               and cost_group_id = cg_id;

         end if; /* if (ccga_count = 0) */

      end if; /* if (cg_id = 1) */
    end if; /* if (!wms_flg ) */


    /*----------------------------------------------------------------------+
     |Insert standard cost into mtl_cst_actual_cost_details
     +----------------------------------------------------------------------*/
    fnd_file.put_line(fnd_file.log, 'inserting into mcacd');

    l_stmt_num := 280;
    CSTPSISC.ins_std_cost(org_id, item_id, trans_id,
                          txn_act_id, src_type_id,
                          iexp_flg, exp_sub, txn_cost,
                          act_cost, prior_cost,
                          user_id, login_id, req_id,
                          prg_appid, prg_id, O_Error_Num,
                          O_Error_Code, O_Error_Message);

    if  O_Error_Code is not null or O_Error_Message is not null
    then
      raise errexit;
    end if;


    /*----------------------------------------------------------------------+
    |Call standard cost distribution hook. Return code of 1 means that the
    |hook has been used.
    +----------------------------------------------------------------------*/

    l_stmt_num := 290;
    l_return_code := CSTPSCHK.std_cost_dist_hook( org_id, trans_id,
                    user_id, login_id, req_id, prg_appid,
                    prg_id, O_Error_Num, O_Error_Code, O_Error_Message);

    if (O_Error_Num <> 0)
    then
        raise errexit;
    end if;

    if (l_return_code = 1)        /* Hook has been used */
    then
      goto update_cost;
    end if;


    /*----------------------------------------------------------------------+
     --
     -- Figure out the send/receiving flag. 1 is send and 2 is recv.
     -- Also, set from/to orgs and cost groups.
     -- OPM INVCONV umoogala: Added 15 (Logical Itr Receipt) and 22 (Logical Itr Shipment) actions.
     --
     -- Bug 5349860: Now processing Internal Order Issue to Expense Detination txn
     --              and its logical receiving txn.
     +----------------------------------------------------------------------*/
    l_stmt_num := 300;
    if (txn_act_id in (3, 21) and p_qty <0) or (txn_act_id = 22) or
       (txn_act_id = 1 and src_type_id = 8)
    then
      snd_rcv := 1;
      from_org      := org_id;
      to_org        := txf_org_id;
      from_cost_grp := cg_id;
      to_cost_grp   := txf_cg_id;
    elsif (txn_act_id in (3, 12, 15) and p_qty > 0) or
          (txn_act_id = 17 and src_type_id = 7)
    then
      snd_rcv := 2;
      from_org      := txf_org_id;
      to_org        := org_id;
      from_cost_grp := txf_cg_id;
      to_cost_grp   := cg_id;
    end if;

    fnd_file.put_line(fnd_file.log,'snd_rcv: ' || snd_rcv);
    fnd_file.put_line(fnd_file.log,'from_org: ' || from_org);
    fnd_file.put_line(fnd_file.log,'to_org: ' || to_org);

    /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 Start */
    CSTPAVCP.get_snd_rcv_rate(trans_id, from_org, to_org,
    l_snd_sob_id, l_snd_curr, l_rcv_sob_id, l_rcv_curr,
    l_curr_type, l_conv_rate, l_conv_date,
    O_Error_Num, O_Error_Code, O_Error_Message);

    if (O_Error_Num <> 0) then
        raise errexit;
    end if;
    fnd_file.put(fnd_file.log, 'fromOrg/SOB/Curr: ' || from_org ||'/'|| l_snd_sob_id ||'/'|| l_snd_curr);
    fnd_file.put(fnd_file.log, 'toOrg/SOB/Curr: '  || to_org ||'/'|| l_rcv_sob_id ||'/'|| l_rcv_curr);
    fnd_file.put(fnd_file.log, 'currType/Rate/Date: ' || l_curr_type ||'/'|| l_conv_rate ||'/'|| l_conv_date);

    /* umoogala Bug#5708387 13-dec-2006
     * l_conv_date is not returned from above call. Using txn date
     */
    l_conv_date := nvl(l_conv_date, txn_date);

    fnd_file.put(fnd_file.log, 'currDate: ' || l_conv_date );
    /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 End */

    /*----------------------------------------------------------------------+
     | Get sending and reciving uom
     +----------------------------------------------------------------------*/
    l_stmt_num := 460;
    select send.primary_uom_code, rec.primary_uom_code
      INTO send_uom, rec_uom
      FROM mtl_system_items_b send, mtl_system_items_b rec
     WHERE send.inventory_item_id = item_id
       AND send.organization_id = from_org
       AND rec.inventory_item_id = item_id
       AND rec.organization_id = to_org;

    /*----------------------------------------------------------------------+
     * Transfer Pricing
     * For process-discrete transfers, transfer price is always incomming cost
     * which is stamped on MMT row. We've already queried this above.
     *
     * Transfer cost is n/a for these type of transfers.
     * Freight Charges are nothing but transportation charges.
     +----------------------------------------------------------------------*/

    tprice_option := 2;
    txf_price     := interorg_xfr_price; /* from MMT */
    txf_cost      := 0;  /* is N/A */


    /*----------------------------------------------------------------------+
     | Get inter-org accounts from Shipping Networks
     | Do not set FOB for Direct Org xfers
     +----------------------------------------------------------------------*/
    l_stmt_num := 470;
    SELECT
        case when txn_act_id <> 3 then nvl(mmt.fob_point, mip.fob_point) end case,
        decode(txn_act_id,3,mp.material_account,
               nvl(mmt.intransit_account, mip.intransit_inv_account)),  /* used only for interorg shipment */
        mip.interorg_transfer_cr_account,
        mip.interorg_receivables_account,
        mip.interorg_payables_account,
        mip.interorg_price_var_account,
        mp.average_cost_var_account,
        mip.interorg_profit_account  /* interorg profit account for process-discrete xfers only */
    INTO
        fob_pt,
        io_inv_acct,
        io_txfr_cr_acct,
        io_rec_acct,
        io_pay_acct,
        io_ppv_acct,
        acv_acct,                  /* overwrite sending acv_acct */
        interorg_profit_acct
    FROM mtl_interorg_parameters mip, mtl_parameters mp, mtl_material_transactions mmt
    WHERE mip.from_organization_id = from_org
    AND mip.to_organization_id = to_org
    AND mp.organization_id = org_id
    AND mmt.transaction_id = trans_id;

    fnd_file.put_line(fnd_file.log, 'FOB = ' || fob_pt);


    /*----------------------------------------------------------------------+
     | Get act_cost and item_cost. It is used only in AX code
     +----------------------------------------------------------------------*/
    SELECT decode(act_cost, 0, nvl(item_cost,0), act_cost), nvl(item_cost, 0)
      INTO act_cost, item_cost
      FROM cst_item_costs_for_gl_view
     WHERE inventory_item_id = item_id
       AND organization_id = org_id;

    fnd_file.put_line(fnd_file.log, 'act_cost: ' || act_cost || ' item_cost: ' || item_cost);


    /*----------------------------------------------------------------------+
     * Get PPV Account only for receiving transactions
     +----------------------------------------------------------------------*/

    if (txn_act_id = 12) OR (txn_act_id = 3 and p_qty > 0)
    then

      if (NOT wms_flg = 1)
      then
        if(subinv is not null)
        then
          l_stmt_num := 610;

          if (pjm_flg = 1)
          then
             if (cg_id = 1)
             then
                SELECT nvl(purchase_price_var_account, io_ppv_acct)
                  INTO io_ppv_acct
                  FROM mtl_parameters
                 WHERE organization_id = org_id;
             else
                l_stmt_num := 612;

                SELECT count(*)
                  INTO ccga_count
                  FROM cst_cost_group_accounts
                 WHERE cost_group_id   = cg_id
                   AND organization_id = org_id;

                l_stmt_num := 614;
                if (ccga_count = 0)
                then
                  FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
                  O_Error_Num     := NULL;
                  O_Error_Code    := 'CST_NO_CG_ACCTS';
                  O_Error_Message := FND_MESSAGE.get;
                  raise errexit;
                else
                   l_stmt_num := 616;
                   SELECT nvl(purchase_price_var_account, io_ppv_acct)
                     INTO io_ppv_acct
                     FROM cst_cost_group_accounts
                    WHERE cost_group_id = cg_id
                      AND organization_id = org_id ;
                end if;
             end if; /* if (cg_id <> 1) */
          end if; /* if (pjm_flg) */
        end if; /* if(subinv.len > 0) */
      /* end of if (NOT wms_flg) */
      else
         if (cg_id <> 1)
         then
            l_stmt_num := 640;
            SELECT count(*)
              INTO ccga_count
              FROM cst_cost_group_accounts
             WHERE cost_group_id = cg_id
               AND organization_id = org_id;

            l_stmt_num := 650;
            if (ccga_count = 0)
            then
              FND_MESSAGE.set_name('BOM', 'CST_NO_CG_ACCTS');
              O_Error_Num     := NULL;
              O_Error_Code    := 'CST_NO_CG_ACCTS';
              O_Error_Message := FND_MESSAGE.get;
              raise errexit;
           else
             if (subinv is  not null)
             then
                l_stmt_num := 655;
                SELECT nvl(purchase_price_var_account, io_ppv_acct)
                  INTO io_ppv_acct
                  FROM cst_cost_group_accounts
                 WHERE cost_group_id = cg_id
                   AND organization_id = org_id ;
             end if; /* if(subinv.len > 0) */
           end if; /* if (ccga_count = 0) */
        end if; /* if (cg_id <> 1) */
      end if; /* if (wms_flg) */
    end if; /* if (txn_act_id = 12) OR (txn_act_id = 3 and p_qty > 0) */



    --
    -- Bug 5021305: Added following to see overhead rules are setup or not.
    -- Bug 5349860: umoogala - exclude issue/receipt (to exp destination) txn.
    --

    fnd_file.put_line(fnd_file.log, 'Verifying whether to earn MOH or not...');

    IF (txn_act_id <> 1) AND (txn_act_id <> 17) AND
       (NOT exp_flg = 1) AND (NOT exp_sub = 1)
    THEN

      /*----------------------------------------------------------------------+
       | Verify whether to earn MOH or not
       +----------------------------------------------------------------------*/
      cst_mohRules_pub.apply_moh(
                           1.0,
                           p_organization_id => org_id,
                           p_earn_moh        => l_earn_moh,
                           p_txn_id          => trans_id,
                           p_item_id         => item_id,
                           x_return_status   => l_return_status,
                           x_msg_count       => l_msg_count,
                           x_msg_data        => l_msg_data);

      IF l_return_status <> FND_API.g_ret_sts_success
      THEN

        CST_UTILITY_PUB.writelogmessages
                         ( p_api_version   => 1.0,
                           p_msg_count     => l_msg_count,
                           p_msg_data      => l_msg_data,
                           x_return_status => l_return_status);
        RAISE moh_rules_error;
      END IF;

      fnd_file.put_line(fnd_file.log, 'l_earn_moh: ' || l_earn_moh);

    END IF;

    <<MAIN_CASE_FOR_ACTION_ID>>
    case
      --
      -- Bug 5349860: Added Internal Order issue to Expense destination
      --
      when (txn_act_id = 3 or txn_act_id = 21 or txn_act_id = 1)
      then
      -- {
        /*----------------------------------------------------------------------+
         | Direct Interorg Shipment and Intransit shipment
         +----------------------------------------------------------------------*/

	  --
	  -- Bug 5349860: umoogala 12/Jun/06
	  -- Added Internal order issue to expense destination txn to the following
	  -- if condition
	  --
          l_stmt_num := 480;
          if ((txn_act_id = 3 AND p_qty < 0) OR (fob_pt = 1) OR
	      (txn_act_id = 1))
          then
          --{

            /* Direct interorg between discrete orgs or fob ship */
            fnd_file.put_line(fnd_file.log, 'Processing shipment txn. FOB = ' || fob_pt);

            /*----------------------------------------------------------------------+
             |Sending Organization : Do accounting for asset subinventory only
             +----------------------------------------------------------------------*/
            if (NOT exp_sub = 1)
            then
               if (NOT exp_flg = 1)
               then

                /* Cr Sending Org @sending org cost */


                    /*----------------------------------------------------------------------+
                     | Cr Inv. Val @ sending org cost
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Cr Inv Val @ sending org cost');

                    CSTPACDP.distribute_accounts(
                        org_id, trans_id,
                        0, cg_id , txn_act_id,
                        item_id, p_qty, 1,
                        1, 0, NULL, mat_acct, mat_ovhd_acct,
                        res_acct, osp_acct, ovhd_acct,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

               end if;

            /*----------------------------------------------------------------------+
             |Sending organization: Do the accounting for transfer from expense sub
             |if profile is set to allow this transfer.  No accounting is done for
             |expense items.
             +----------------------------------------------------------------------*/
            else
              if (NOT iexp_flg = 1)
              then


                /*----------------------------------------------------------------------+
                 | Dr Exp Acct
                 +----------------------------------------------------------------------*/
                fnd_file.put_line(fnd_file.log, 'Dr Exp Acct');
                l_stmt_num := 750;

		--
		-- Bug 5331207:
		-- Shipping from expense destination fails with ORA-1400
		-- We were calling distribute_accounts with elemental flag 1.
		-- To book to exp account only, now sending elemental flag 0.
		--
                CSTPACDP.distribute_accounts(
                    org_id, trans_id, 0, cg_id , txn_act_id,
                    item_id, p_qty, 2, 0, 0,
                    exp_acct, NULL, NULL, NULL, NULL, NULL,
                    sob_id, txn_date, txn_src_id, src_type_id,
                    subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                    user_id, login_id, req_id, prg_appid, prg_id,
                    O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;
              end if;

            end if;

            /* Cr Sending Org Freight Exp account */
            if (txn_act_id = 3) and (trp_cost <> 0)
            then

                    user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                       -1, 12, 1, 0,
                                       subinv, cg_id, 0, snd_rcv,
                                       O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    if user_acct_id > 0
                    then
                      trp_acct := user_acct_id;
                    end if;


                    /*----------------------------------------------------------------------+
                     | Cr Freight Acct
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Cr Freight Acct with ' || trp_cost || ' ' || pri_curr);
                    CSTPACDP.insert_account
                       (org_id, trans_id, item_id, -1 * trp_cost,
                        p_qty, trp_acct, sob_id, 12, NULL, NULL,
                        txn_date, txn_src_id, src_type_id,
                        pri_curr, NULL, NULL, NULL, NULL,1,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

            end if;


            /*----------------------------------------------------------------------+
             | Dr Receivalbes with transfer price
             +----------------------------------------------------------------------*/
            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               1, 10, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              io_rec_acct := user_acct_id;
            end if;


            fnd_file.put_line(fnd_file.log, 'Dr Receivables with ' || (txf_price * p_qty) || ' ' || pri_curr);
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, -1 * txf_price * p_qty,
                -1 * p_qty, io_rec_acct, sob_id, 10, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, NULL, NULL, NULL, NULL,1,
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            /*----------------------------------------------------------------------+
             | Dr InterOrg Profit Account with (transfer_price - sending org cost) * qty.
             +----------------------------------------------------------------------*/

           l_stmt_num := 761;

           --
           -- Bug 5233635: Should not book InterOrg Profit If Intercompany Invoicing is enabled.
	   -- Following flag is set at the beginning of the procedure.
           --
           if  (src_type_id = 8)
	   and (l_org_ou <> l_txf_org_ou)
           and (l_io_invoicing = 1)
           and (txn_act_id = 21) -- Bug 5351724
           and (iexp_flg   = 0)    -- Bug 5348953: No IC Invoicing for expense items
           then
             NULL;
             fnd_file.put_line(fnd_file.log, 'No need to book InterOrg Profit since InterCompany Invoicing ' ||
               'is enabled.');
           else
	     /*
	      * Replaced with following SQL
             if (txn_act_id = 3)
             then
               interorg_profit := txf_price - (item_cost + (trp_cost/abs(p_qty)));
             else
               interorg_profit := txf_price - item_cost;
             end if;
	      */

             SELECT SUM(NVL(base_transaction_value,0))
              INTO interorg_profit
              FROM mtl_transaction_accounts
             WHERE transaction_id  = trans_id
               AND organization_id = org_id
             ;

             fnd_file.put_line(fnd_file.log, 'InterOrg Profit = ' || nvl(interorg_profit, 0) || ' ' || pri_curr);

             if (interorg_profit <> 0)
             then

               user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                  -1, G_INTERORG_PROFIT_ACCT, 1, 0,
                                  subinv, cg_id, 0, snd_rcv,
                                  O_Error_Num, O_Error_Code, O_Error_Message);

               if (O_Error_Num <> 0) then
                 raise errexit;
               end if;

               if user_acct_id > 0
               then
                 interorg_profit_acct := user_acct_id;
               end if;

               fnd_file.put_line(fnd_file.log, 'Cr InterOrg Profit with ' || nvl(interorg_profit,0) || ' ' || pri_curr);
               CSTPACDP.insert_account
                  (org_id, trans_id, item_id, -1 * interorg_profit,
                   p_qty, interorg_profit_acct, sob_id,
                   G_INTERORG_PROFIT_ACCT, NULL, NULL,
                   txn_date, txn_src_id, src_type_id,
                   pri_curr, NULL, NULL, NULL, NULL,1,
                   user_id, login_id, req_id, prg_appid, prg_id,
                   O_Error_Num, O_Error_Code, O_Error_Message);

               if (O_Error_Num <> 0) then
                 raise errexit;
               end if;

             end if;
	   end if; -- Bug 5233635

          /* end of: if ((txn_act_id = 3 AND p_qty < 0) OR fob_pt = 1) */


          --}

          /*----------------------------------------------------------------------+
           |FOB point Delivery
           +----------------------------------------------------------------------*/

          elsif (txn_act_id = 21 AND fob_pt = 2)
          then
          --{

            fnd_file.put_line(fnd_file.log, 'Processing intransit shipment. FOB = ' || fob_pt);

            --
	    -- Bug 5332792: No accounting for shipment txn with FOB Receipt for expense item
	    -- Added 2nd condition (NOT iexp_flg = 1) to the IF stmt below.
	    -- So, for expense item transfered using FOB Receipt/Shipment following is the
	    -- acctg:
	    -- Dr Receivalbes
	    --   Cr InterOrg Profit.
	    -- For FOB Shipment: above is done using shipment txn.
	    -- For FOB Receipt:  above is done using logical intransit shipment.
	    --
            if (NOT exp_sub = 1) and (NOT iexp_flg = 1)
            then
                /*----------------------------------------------------------------------+
                 |FOB point Delivery: Do the accounting for asset subinventory
                 +----------------------------------------------------------------------*/

                  /* Cr Sending Orgs Inv. Valuation account */

                  if item_cost > 0
                  then

                    /*----------------------------------------------------------------------+
                     | Cr Inv. Val @ sending org cost
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Cr Inv Val @ sending org cost');
                    CSTPACDP.distribute_accounts(
                        org_id, trans_id,
                        0, cg_id , txn_act_id,
                        item_id, p_qty, 1,
                        1, 0, NULL, mat_acct, mat_ovhd_acct,
                        res_acct, osp_acct, ovhd_acct,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    /* Dr Sending Orgs intransit */


                    /*----------------------------------------------------------------------+
                     | Dr Intransit Acct @ org cost
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Dr Intransit Acct @ org cost');
                    CSTPACDP.distribute_accounts(
                        org_id, trans_id, 0, cg_id , txn_act_id,
                        item_id, -1 * p_qty, 14, 0, 0,
                        io_inv_acct, NULL, NULL, NULL, NULL,NULL,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                  else
                     -- Item Cost is zero, so directly call insert_acct with 0 cost.

                    /*----------------------------------------------------------------------+
                     | Cr Inv. Val @ with zero cost
                     +----------------------------------------------------------------------*/
                    user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                       -1, 1, 1, 0,
                                       subinv, cg_id, 0, snd_rcv,
                                       O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    if user_acct_id > 0
                    then
                      mat_acct := user_acct_id;
                    end if;

                    fnd_file.put_line(fnd_file.log, 'Cr Inv Val');
                    CSTPACDP.insert_account
                       (org_id, trans_id, item_id, 0,
                        p_qty, mat_acct, sob_id, 1, NULL, NULL,
                        txn_date, txn_src_id, src_type_id,
                        pri_curr, NULL, NULL, NULL, NULL,1,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    /*----------------------------------------------------------------------+
                     | Dr Intransit Acct with zero cost
                     +----------------------------------------------------------------------*/
                    user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                       -1, 14, 1, 0,
                                       subinv, cg_id, 0, snd_rcv,
                                       O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    if user_acct_id > 0
                    then
                      io_inv_acct := user_acct_id;
                    end if;

                    fnd_file.put_line(fnd_file.log, 'Dr Intransit Acct');
                    CSTPACDP.insert_account
                       (org_id, trans_id, item_id, 0,
                        -1 * p_qty, io_inv_acct, sob_id, 14, NULL, NULL,
                        txn_date, txn_src_id, src_type_id,
                        pri_curr, NULL, NULL, NULL, NULL,1,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                  end if; /* if item_cost > 0 */

            else

             /*----------------------------------------------------------------------+
              |FOB point Delivery:  Do the accounting for transfer from expense sub
              |if the profile is set to allow this transfer
              +----------------------------------------------------------------------*/
              if (NOT iexp_flg = 1)
              then

                l_stmt_num := 790;


                /*----------------------------------------------------------------------+
                 | Cr Exp Acct
                 +----------------------------------------------------------------------*/
                fnd_file.put_line(fnd_file.log, 'Cr Exp Acct');
                CSTPACDP.distribute_accounts(
                    org_id, trans_id, 0, cg_id , txn_act_id,
                    item_id, p_qty, 2, 0, 0,
                    exp_acct, NULL, NULL, NULL, NULL, NULL,
                    sob_id, txn_date, txn_src_id, src_type_id,
                    subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                    user_id, login_id, req_id, prg_appid, prg_id,
                    O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;


                /*----------------------------------------------------------------------+
                 | Dr Intransit Acct @ org cost
                 +----------------------------------------------------------------------*/
                fnd_file.put_line(fnd_file.log, 'Dr Intransit Acct @ org cost');
                CSTPACDP.distribute_accounts(
                    org_id, trans_id,
                    0, cg_id , txn_act_id,
                    item_id, -1 * p_qty, 14,
                    0, 0, io_inv_acct, NULL, NULL, NULL, NULL,NULL,
                    sob_id, txn_date, txn_src_id, src_type_id,
                    subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                    user_id, login_id, req_id, prg_appid, prg_id,
                    O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;

              end if; /* if (NOT iexp_flg = 1) */
            end if; /* if (NOT exp_sub = 1) and (NOT iexp_flg = 1) */
          --}

          /* OPM INVCONV  umoogala Process-Discrete Xfers Enh. */
          elsif (txn_act_id = 3 AND p_qty > 0)
          then
          --{
            /* This is a direct transfer from process mfg. org. For
             * discrete-discrete xfers, this is always done by sending
             * orgs worker. But, for process discrete transfers since
             * the sending org is process org it will not be done. So,
             * only for process-discrete xfers we've to handle this
             * condition.
             *
             * Reason for adding this is:
             *  Currently, for direct interorg xfers, only shipping side of
             *  the txn is queried and using this txn receiving side is costed.
             *  This is ok for discrete-to-discrete transfers.
             *
             *  But, for process-to-discrete transfers, shipping side is
             *  process mfg org, which will never get picked up. As a result
             *  of this, receiving side i.e., discrete org receiving txn is
             *  not getting costed.
             *
             *  Now, since the receiving txn for direct interorg xfer is comming in
             *  we need to process it accordingly. Existing code would not work
             *  as it assumes that we are processing shipping row.
             *
             *  Following code will handle above scenario.
             *
             *  Following are the accouting entries:
             *  For Asset Inv:
             *    Dr. Inv Valuation @ Org Cost
             *        Cr InterOrg Payables with Transfer Price
             *    Dr. PPV, if any
             *
             *  For Exp:
             *    Dr. Exp Acct @ Transfer Price
             *        Cr InterOrg Payables with Transfer Price
             */

            fnd_file.put_line(fnd_file.log, 'processing direct interorg receiving txn.');


            /*----------------------------------------------------------------------+
             | Cr receiving org payable @ transfer price
             +----------------------------------------------------------------------*/

            /* Amount to account */
            payamt := interorg_xfr_price * p_qty;


            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               -1, 9, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              io_pay_acct := user_acct_id;
            end if;

            fnd_file.put_line(fnd_file.log, 'Cr Payables with ' || payamt || ' ' || pri_curr);
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, -1 * payamt,
                -1 * p_qty, io_pay_acct, sob_id, 9, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1,   /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 */
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;


            /*----------------------------------------------------------------------+
             | Dr Inv. Valuations or Expense Account
             +----------------------------------------------------------------------*/

            if (exp_flg = 1) /* receiving org expense item */
            then

              /* Dr expense account for direct transfer */

              user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                 -1, 2, 1, 0,
                                 subinv, cg_id, 0, snd_rcv,
                                 O_Error_Num, O_Error_Code, O_Error_Message);

              if (O_Error_Num <> 0) then
                raise errexit;
              end if;

              if user_acct_id > 0
              then
                exp_acct := user_acct_id;
              end if;

              /*----------------------------------------------------------------------+
               | Dr Exp Acct
               +----------------------------------------------------------------------*/
              fnd_file.put_line(fnd_file.log, 'Dr Exp Acct');
              CSTPACDP.insert_account
                 (org_id, trans_id, item_id, interorg_xfr_price * p_qty,
                  p_qty, exp_acct, sob_id, 2, NULL, NULL,
                  txn_date, txn_src_id, src_type_id,
                  pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1,   /* umoogala Bug#5708387 13-dec-2006 */
                  user_id, login_id, req_id, prg_appid, prg_id,
                  O_Error_Num, O_Error_Code, O_Error_Message);

              if (O_Error_Num <> 0) then
                raise errexit;
              end if;

              goto update_cost;
               -- This is the final debit.
               -- No PPV and OH absorption are used.
               -- break;

            else  /* Asset Item */

              /* Dr Inv. Valuation @ org cost */

              /*----------------------------------------------------------------------+
               | Dr Inv. Val @ org cost
               +----------------------------------------------------------------------*/
              fnd_file.put_line(fnd_file.log, 'Dr Inv Val @ org cost');
              CSTPACDP.distribute_accounts(
                  org_id, trans_id,
                  0, cg_id , txn_act_id,
                  item_id, p_qty, 1,
                  1, 0, NULL, mat_acct, mat_ovhd_acct,
                  res_acct, osp_acct, ovhd_acct,
                  sob_id, txn_date, txn_src_id, src_type_id,
                  subinv, snd_rcv, pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
                  user_id, login_id, req_id, prg_appid, prg_id,
                  O_Error_Num, O_Error_Code, O_Error_Message);

              if (O_Error_Num <> 0) then
                raise errexit;
              end if;

            end if;  -- if (exp_flg = 1)


            /* receiving overhead absorption */
            /* Earn MOH only for asset subinventory */

            if (NOT exp_flg = 1) AND (NOT exp_sub = 1) AND (l_earn_moh <> 0)
            then

              /*----------------------------------------------------------------------+
               | Booking Overhead Acct
               +----------------------------------------------------------------------*/
                fnd_file.put_line(fnd_file.log, 'Booking Overhead Acct');
                CSTPACDP.ovhd_accounts(org_id, trans_id, item_id,
                              -1 * p_qty, sob_id,
                              txn_date, txn_src_id, src_type_id, subinv,
                              snd_rcv, pri_curr,
                              l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
                              user_id, login_id, req_id, prg_appid, prg_id,
                              O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;

            end if;


            /*----------------------------------------------------------------------+
             | Dr receiving Inter-org PPV
             +----------------------------------------------------------------------*/

            /* Changes for PJM Standard Costing - Update MMT with PPV amount*/


            UPDATE mtl_material_transactions
               SET variance_amount = (SELECT -1 * nvl(sum(base_transaction_value),0)
                                        FROM mtl_transaction_accounts mta
                                       WHERE mta.transaction_id = trans_id
                                         AND mta.organization_id = org_id
                                         AND encumbrance_type_id is null)
             WHERE transaction_id = trans_id
            RETURNING variance_amount INTO ppv_amt;


            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               -1, 6, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              io_ppv_acct := user_acct_id;
            end if;

            fnd_file.put_line(fnd_file.log, 'Dr PPV with ' || ppv_amt || ' ' || pri_curr);
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, ppv_amt,
                p_qty, io_ppv_acct, sob_id, 6, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

          end if;
          --}
      -- }
      -- end of 'when (txn_act_id = 3 or txn_act_id = 21)'

      when ((txn_act_id = 12) /* Intransit receipt */
            OR
	    (txn_act_id = 17))
      then
      -- {


          l_stmt_num := 840;

          <<FOB_POINT>>
          case
            when (fob_pt = 1)  /* FOB Shipping */
            then
            -- {

              /* Receiving Organization */

                  /* Receiving is std/exp, std/not exp */

                  /*----------------------------------------------------------------------+
                   | Dr Inv Val @rec org cost if Item is an Asset Item
                   +----------------------------------------------------------------------*/
		  --
		  -- Bug 5401272: If receiving into exp sub, then book to
		  -- expense account.
		  --
                  if ((exp_flg = 1 or exp_sub = 1) AND NOT iexp_flg = 1)
                  then
                  -- {

                    /*----------------------------------------------------------------------+
                     | Dr Exp Acct
                     +----------------------------------------------------------------------*/
                    -- receiving asset item into exp sub
                    l_stmt_num := 910;

                    user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                       -1, 2, 1, 0,
                                       subinv, cg_id, 0, snd_rcv,
                                       O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    if user_acct_id > 0
                    then
                      exp_acct := user_acct_id;
                    end if;

                    fnd_file.put_line(fnd_file.log, 'Dr Exp Acct');
                    CSTPACDP.distribute_accounts(
                        org_id, trans_id,
                        0, cg_id , txn_act_id,
                        item_id, p_qty, 2,
                        0, 0, exp_acct, NULL, NULL,
                        NULL, NULL, NULL,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                  -- if (exp_flg = 1 AND NOT iexp_flg = 1)
                  -- }

                  elsif (NOT exp_flg = 1)
                  then
                  -- {
                    /* receiving is not expense */


                    /*----------------------------------------------------------------------+
                     | Dr Inv. Val @ org cost
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Dr Inv Val @ org cost');
                    CSTPACDP.distribute_accounts(
                        org_id, trans_id,
                        0, cg_id , txn_act_id,
                        item_id, p_qty, 1,
                        1, 0, NULL, mat_acct, mat_ovhd_acct,
                        res_acct, osp_acct, ovhd_acct,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                  end if; -- if (NOT exp_flg = 1)
                  -- }

                  /* Cr Receiving Org Intransit only for asset item */
                  -- {
                  if (NOT iexp_flg = 1)
                  then

                    user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                       -1, 14, 1, 0,
                                       subinv, cg_id, 0, snd_rcv,
                                       O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                    if user_acct_id > 0
                    then
                      io_inv_acct := user_acct_id;
                    end if;

                    /*----------------------------------------------------------------------+
                     | Cr Intransit Acct @ org cost
                     +----------------------------------------------------------------------*/
                    fnd_file.put_line(fnd_file.log, 'Cr Intransit Acct @ org cost');
                    CSTPACDP.distribute_accounts(
                        org_id, trans_id,
                        0, cg_id , txn_act_id,
                        item_id, -1 * p_qty, 14,
                        0, 0, io_inv_acct, NULL, NULL, NULL, NULL,NULL,
                        sob_id, txn_date, txn_src_id, src_type_id,
                        subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
                        user_id, login_id, req_id, prg_appid, prg_id,
                        O_Error_Num, O_Error_Code, O_Error_Message);

                    if (O_Error_Num <> 0) then
                      raise errexit;
                    end if;

                  end if; -- if (NOT iexp_flg = 1)
                  -- }
              -- }
            when ((fob_pt = 2) OR                /* FOB point Delivery */
	          (txn_act_id = 17))             -- Bug 5349860: umoogala. Added this line
            then
            -- {


              /*----------------------------------------------------------------------+
               | Cr receiving org payable
               +----------------------------------------------------------------------*/

              l_stmt_num := 930;

              payamt := -1.0 * txf_price * p_qty;


              user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                 -1, 9, 1, 0,
                                 subinv, cg_id, 0, snd_rcv,
                                 O_Error_Num, O_Error_Code, O_Error_Message);

              if (O_Error_Num <> 0) then
                raise errexit;
              end if;

              if user_acct_id > 0
              then
                io_pay_acct := user_acct_id;
              end if;

              fnd_file.put_line(fnd_file.log, 'Cr Payables with ' || payamt || ' ' || pri_curr);
              CSTPACDP.insert_account
                 (org_id, trans_id, item_id, payamt,
                  -1 * p_qty, io_pay_acct, sob_id, 9, NULL, NULL,
                  txn_date, txn_src_id, src_type_id,
                  pri_curr, l_snd_curr,l_conv_date, l_conv_rate, l_curr_type, 1,   /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 End */
                  user_id, login_id, req_id, prg_appid, prg_id,
                  O_Error_Num, O_Error_Code, O_Error_Message);

              if (O_Error_Num <> 0) then
                raise errexit;
              end if;


              /* receiving org inv. valuation acct */
	      --
	      -- Bug 5349860: For Logical Expense Requisition Receipt (action id 17) we
	      --              should always Dr Expense Account. Added (txn_act_id <> 17)
	      --              condition to the following IF stmt
	      --
              if (txn_act_id <> 17) AND (NOT exp_flg = 1)
              then

                l_stmt_num := 931;
                /*----------------------------------------------------------------------+
                 | Dr Inv. Val @ org cost
                 +----------------------------------------------------------------------*/
                fnd_file.put_line(fnd_file.log, 'Dr Inv Val @ org cost');
                CSTPACDP.distribute_accounts(
                    org_id, trans_id,
                    0, cg_id , txn_act_id,
                    item_id, p_qty, 1,
                    1, 0, NULL, mat_acct, mat_ovhd_acct,
                    res_acct, osp_acct, ovhd_acct,
                    sob_id, txn_date, txn_src_id, src_type_id,
                    subinv, snd_rcv, pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
                    user_id, login_id, req_id, prg_appid, prg_id,
                    O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;


                /* receiving overhead absorption */

                /*----------------------------------------------------------------------+
                 | Booking Overhead Acct
                 +----------------------------------------------------------------------*/
	        IF (txn_act_id <> 17) AND -- Bug 5349860
		   (exp_flg = 0) AND (exp_sub = 0) AND (l_earn_moh <> 0)
	        THEN
                  fnd_file.put_line(fnd_file.log, 'Booking Overhead Acct');
                  CSTPACDP.ovhd_accounts(org_id, trans_id, item_id,
                                -1 * p_qty, sob_id,
                                txn_date, txn_src_id, src_type_id, subinv,
                                snd_rcv, pri_curr,
                  	        l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
                                user_id, login_id, req_id, prg_appid, prg_id,
                                O_Error_Num, O_Error_Code, O_Error_Message);

                  if (O_Error_Num <> 0) then
                    raise errexit;
                  end if;
                END IF;


                /*----------------------------------------------------------------------+
                 | Dr PPV
                 +----------------------------------------------------------------------*/

		IF (txn_act_id <> 17) -- Bug 5349860
		THEN

                  UPDATE mtl_material_transactions
                     SET variance_amount = (SELECT -1 * nvl(sum(base_transaction_value),0)
                                              FROM mtl_transaction_accounts mta
                                             WHERE mta.transaction_id = trans_id
                                               AND mta.organization_id = org_id
                                               AND encumbrance_type_id is null)
                   WHERE transaction_id = trans_id
                  RETURNING variance_amount INTO ppv_amt;


                  user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                     -1, 6, 1, 0,
                                     subinv, cg_id, 0, snd_rcv,
                                     O_Error_Num, O_Error_Code, O_Error_Message);

                  if (O_Error_Num <> 0) then
                    raise errexit;
                  end if;

                  if user_acct_id > 0
                  then
                    io_ppv_acct := user_acct_id;
                  end if;

                  fnd_file.put_line(fnd_file.log, 'Dr PPV with ' || ppv_amt || ' ' || pri_curr);
                  CSTPACDP.insert_account
                     (org_id, trans_id, item_id, ppv_amt,
                      p_qty, io_ppv_acct, sob_id, 6, NULL, NULL,
                      txn_date, txn_src_id, src_type_id,
                      pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
                      user_id, login_id, req_id, prg_appid, prg_id,
                      O_Error_Num, O_Error_Code, O_Error_Message);

                  if (O_Error_Num <> 0) then
                    raise errexit;
                  end if;

		END IF;

              else

                /*----------------------------------------------------------------------+
                 | Dr Exp Acct
                 +----------------------------------------------------------------------*/

                l_stmt_num := 920;

                user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                                   -1, 2, 1, 0,
                                   subinv, cg_id, 0, snd_rcv,
                                   O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;

                if user_acct_id > 0
                then
                  exp_acct := user_acct_id;
                end if;

                fnd_file.put_line(fnd_file.log, 'Dr Exp Acct');
                CSTPACDP.insert_account
                   (org_id, trans_id, item_id, -1 * payamt,
                    p_qty, exp_acct, sob_id, 2, NULL, NULL,
                    txn_date, txn_src_id, src_type_id,
                    pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
                    user_id, login_id, req_id, prg_appid, prg_id,
                    O_Error_Num, O_Error_Code, O_Error_Message);

                if (O_Error_Num <> 0) then
                  raise errexit;
                end if;

              end if;  -- if (NOT exp_flg = 1)

              -- break;
              -- }
            end case FOB_POINT;
      -- }


      /* OPM INVCONV  umoogala
       * Added following two new logical txns created for
       * process-discrete transfers. These logical txns are created
       * using INV_LOGICAL_TRANSACTIONS_PUB. create_opm_disc_logical_trx
       * Any issues with data should be fixed in above procedure.
       *
       * Txn Action 22 (Logical Intransit Shipment):
       *  Transfer is from Discrete Org to Process Org.
       *  For source Inventory (13) and Type Logical Intransit Shipment (60)
       *      source Int Req (8)    and Type Logical Intransit Shipment (65)
       *
       * Txn Action 15 (Logical  Intransit Receipt):
       *  Transfer is from Process Org to Discrete Org.
       *  For source Inventory (13) and Type Logical Intransit Receipt (59)
       *      source Int Req (7)    and Type Logical Intransit Receipt (76)
       */

      when (txn_act_id = 22)  /* Logical In-transit Shipment */
      then
      -- {
        /*
         * Discrete -> Process Transfer with FOB Receiving
         *
         * Here sending Org is Std Costing Discrete Org and Receiving Org
         * is Process Mfg(OPM) Org.
         * This transaction, for sending org, gets created during In-transit
         * Receipt(12) in Receiving Org.
         *
         * Following accounts needs to be booked:
         *
         * FOB = Receiving(2)
         *
         * Account                    Dr               Cr
         * ------------------------   --------------   ---------------
         *   Inter-Org Receivables    Transfer Price
         *   In-transit Inventory                      Sending Org Cost
         *   Freight Expense A/c                       Freight
         *   InterOrg Profit          (Org Cost +
         *                             Freight -
         *                             Transfer Price)
         * ------------------------------------------------------------
         *
         * Transfer Price  : is in MMT. variable  interorg_xfr_price holds it
         * Sending Org Cost: query it
         * Freight         : Trp Cost in MMT. varaible trp_cost holds it
         */



        /*----------------------------------------------------------------------+
         | Cr In-transit Inventory with Sending Org Cost for Asset Items Only
	 |
	 | Bug 5332764: Exp Item with FOB Rct, shipment is not accounted. So, no
	 | need to book intransit entry.
         +----------------------------------------------------------------------*/
         if (NOT iexp_flg = 1)  -- Bug 5332764.
         then
          user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                             -1, 14, 1, 0,
                             subinv, cg_id, 0, snd_rcv,
                             O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

          if user_acct_id > 0
          then
            io_inv_acct := user_acct_id;
          end if;

          fnd_file.put_line(fnd_file.log, 'Cr Intransit Acct @ org cost');
          CSTPACDP.distribute_accounts(
              org_id, trans_id,
              0, cg_id , txn_act_id,
              item_id, -1 * p_qty, 14,
              0, 0, io_inv_acct, NULL, NULL, NULL, NULL,NULL,
              sob_id, txn_date, txn_src_id, src_type_id,
              subinv, snd_rcv, pri_curr, NULL, NULL, NULL, NULL,
              user_id, login_id, req_id, prg_appid, prg_id,
              O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;
        end if;

        /*----------------------------------------------------------------------+
         | Cr Sending Org Freight absorption account
         +----------------------------------------------------------------------*/
        if(trp_cost <> 0)
        then

          user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                             -1, 12, 1, 0,
                             subinv, cg_id, 0, snd_rcv,
                             O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

          if user_acct_id > 0
          then
            trp_acct := user_acct_id;
          end if;

          fnd_file.put_line(fnd_file.log, 'Cr Freight Acct with ' || trp_cost || ' ' || pri_curr);
          CSTPACDP.insert_account
             (org_id, trans_id, item_id, -1 * trp_cost,
              p_qty, trp_acct, sob_id, 12, NULL, NULL,
              txn_date, txn_src_id, src_type_id,
              pri_curr, NULL, NULL, NULL, NULL,1,
              user_id, login_id, req_id, prg_appid, prg_id,
              O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

        end if;

        /*----------------------------------------------------------------------+
         | Dr Sending Org Receivable with Transfer Price
         +----------------------------------------------------------------------*/

        user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                           1, 10, 1, 0,
                           subinv, cg_id, 0, snd_rcv,
                           O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;

        if user_acct_id > 0
        then
          io_rec_acct := user_acct_id;
        end if;


        fnd_file.put_line(fnd_file.log, 'Dr Receivalbes with ' || (interorg_xfr_price * p_qty) || ' ' || pri_curr);
        CSTPACDP.insert_account
           (org_id, trans_id, item_id, interorg_xfr_price * p_qty,
            p_qty, io_rec_acct, sob_id, 10, NULL, NULL,
            txn_date, txn_src_id, src_type_id,
            pri_curr, NULL, NULL, NULL, NULL,1,
            user_id, login_id, req_id, prg_appid, prg_id,
            O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;

        /*----------------------------------------------------------------------+
         | Dr Book interorg profit
         +----------------------------------------------------------------------*/
        --
        -- Bug 5233635: Should not book InterOrg Profit If Intercompany Invoicing is enabled.
	-- Following flag is set at the beginning of the procedure.
        --
        if  (src_type_id = 8)
        and (l_org_ou <> l_txf_org_ou)
        and (l_io_invoicing = 1)
        and (txn_act_id = 21) -- Bug 5351724
        and (iexp_flg   = 0)    -- Bug 5348953: No IC Invoicing for expense items
        then
          NULL;
          fnd_file.put_line(fnd_file.log, 'No need to book InterOrg Profit since InterCompany Invoicing ' ||
            'is enabled.');
        else

          -- interorg_profit := interorg_xfr_price - (item_cost + (trp_cost/p_qty));
          SELECT SUM(NVL(base_transaction_value,0))
           INTO interorg_profit
           FROM mtl_transaction_accounts
          WHERE transaction_id  = trans_id
            AND organization_id = org_id
          ;

          if (interorg_profit <> 0)
          then

            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               -1, G_INTERORG_PROFIT_ACCT, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              interorg_profit_acct := user_acct_id;
            end if;

            fnd_file.put_line(fnd_file.log, 'Dr InterOrg Profit with ' || nvl(interorg_profit,0) || ' ' || pri_curr);
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, -1 * interorg_profit, /* ANTHIYAG Bug#5459157 11-Aug-2006 */
                p_qty, interorg_profit_acct, sob_id,
                G_INTERORG_PROFIT_ACCT, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, NULL, NULL, NULL, NULL,1,
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;
          end if;
        end if; -- Bug 5233635

      -- }

      when (txn_act_id = 15) /* Logical In-transit Receipt */
      then
      -- {
        /*
         * Process -> Discrete Transfer with FOB Shipping
         *
         * Here sending Org is Process Mfg(OPM) Org and Receiving Org
         * is Std Costing Discrete Org.
         * This transaction, for receving org, gets created during In-transit
         * Shipment(12) in Sending Org i.e., discrete org
         *
         * Following accounts needs to be booked:
         *
         * FOB = Shipping(1)
         *
         * Account                    Dr               Cr
         * ------------------------   --------------   ----------------
         *   In-transit Inventory     Recv. Org Cost
         *   Inter-Org Payables                        Transfer Price
         *   Freight Expense A/c                       Freight
         *   InterOrg Profit          (Transfer Price +
         *                             Freight -
         *                             Recv. Org Cost)
         * ------------------------------------------------------------
         *
         * Transfer Price  : is in MMT. variable  interorg_xfr_price holds it
         * Recv Org Cost   : query it
         * Freight         : Trp Cost in MMT. varaible trp_cost holds it
         */

        /*----------------------------------------------------------------------+
         | Cr receiving org payable with transfer price
         +----------------------------------------------------------------------*/

        payamt := -1.0 * txf_price * p_qty;

        user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                           -1, 9, 1, 0,
                           subinv, cg_id, 0, snd_rcv,
                           O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;

        if user_acct_id > 0
        then
          io_pay_acct := user_acct_id;
        end if;

        fnd_file.put_line(fnd_file.log, 'Cr Payables with ' || payamt || ' ' || pri_curr);
        CSTPACDP.insert_account
           (org_id, trans_id, item_id, payamt,
            -1 * p_qty, io_pay_acct, sob_id, 9, NULL, NULL,
            txn_date, txn_src_id, src_type_id,
            pri_curr, l_snd_curr,l_conv_date, l_conv_rate, l_curr_type, 1,   /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 End */
            user_id, login_id, req_id, prg_appid, prg_id,
            O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;


        /*----------------------------------------------------------------------+
         | Cr freight
         +----------------------------------------------------------------------*/
        if (trp_cost <> 0)
        then

          user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                             -1, 12, 1, 0,
                             subinv, cg_id, 0, snd_rcv,
                             O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

          if user_acct_id > 0
          then
            trp_acct := user_acct_id;
          end if;

          fnd_file.put_line(fnd_file.log, 'Cr Freight Acct with ' || trp_cost || ' ' || pri_curr);
          CSTPACDP.insert_account
             (org_id, trans_id, item_id, -1 * trp_cost,
              p_qty, trp_acct, sob_id, 12, NULL, NULL,
              txn_date, txn_src_id, src_type_id,
              pri_curr, l_snd_curr,l_conv_date, l_conv_rate, l_curr_type, 1, /* INVCONV ANTHIYAG Bug#5352186 09-Sep-2006 End */
              user_id, login_id, req_id, prg_appid, prg_id,
              O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

        end if; -- if (trp_cost <> 0)


        /*----------------------------------------------------------------------+
         | Dr Variance amount
         +----------------------------------------------------------------------*/
        if (var_amt <> 0)
        then

          user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                             -1, 13, 1, 0,
                             subinv, cg_id, 0, snd_rcv,
                             O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

          if user_acct_id > 0
          then
            acv_acct := user_acct_id;
          end if;

          fnd_file.put_line(fnd_file.log, 'Cr variance account with ' || var_amt || ' ' || pri_curr);
          CSTPACDP.insert_account
             (org_id, trans_id, item_id, var_amt,
              p_qty, acv_acct, sob_id, 13, NULL, NULL,
              txn_date, txn_src_id, src_type_id,
              pri_curr, l_snd_curr,l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
              user_id, login_id, req_id, prg_appid, prg_id,
              O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

        end if; /* if (var_amt <> 0) */

        /*----------------------------------------------------------------------+
         | Dr Expense Account
         +----------------------------------------------------------------------*/
	--
	-- Bug 5401272: check items exp flag instead of exp_flag which is based
	-- on item/subInv combination.
	-- Book Exp Account for Exp Items Only
	-- Asset to exp sub, still should got to intransit account
	--
        if (iexp_flg = 1)
        then

            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               -1, 2, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              exp_acct := user_acct_id;
            end if;

            fnd_file.put_line(fnd_file.log, 'Dr Exp Acct');
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, trp_cost,
                p_qty, exp_acct, sob_id, 2, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            /* For this 2 cases, this is the final debit. */
            /* No PPV and OH absorption are used. */
            goto update_cost;
        end if;

        /*----------------------------------------------------------------------+
         | Dr intransit @ receiving org cost
         +----------------------------------------------------------------------*/

        user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                           -1, 14, 1, 0,
                           subinv, cg_id, 0, snd_rcv,
                           O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;

        if user_acct_id > 0
        then
          io_inv_acct := user_acct_id;
        end if;

        fnd_file.put_line(fnd_file.log, 'Dr Intransit Acct @ org cost');
        CSTPACDP.distribute_accounts(
            org_id, trans_id,
            0, cg_id , txn_act_id,
            item_id, p_qty, 14,
            0, 0, io_inv_acct, NULL, NULL, NULL, NULL,NULL,
            sob_id, txn_date, txn_src_id, src_type_id,
            subinv, snd_rcv, pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
            user_id, login_id, req_id, prg_appid, prg_id,
            O_Error_Num, O_Error_Code, O_Error_Message);

        if (O_Error_Num <> 0) then
          raise errexit;
        end if;


        /*----------------------------------------------------------------------+
         | Dr Overhead Obsorption account
         +----------------------------------------------------------------------*/

	/* receiving overhead absorption */
	/* Earn MOH only for asset subinventory */

	fnd_file.put_line(fnd_file.log, '-- Booking Overhead Acct: exp_flg/exp_sub: ' || exp_flg ||'/'||exp_sub ||
	  ' bookMOH Obsorption?: ' || l_earn_moh);

	if (exp_flg = 0) AND (exp_sub = 0) AND (l_earn_moh <> 0)
	then

	  /*----------------------------------------------------------------------+
	   | Booking Overhead Acct
	   +----------------------------------------------------------------------*/
	  fnd_file.put_line(fnd_file.log, '-- Booking Overhead Acct');
	  CSTPACDP.ovhd_accounts(org_id, trans_id, item_id,
			-1 * p_qty, sob_id,
			txn_date, txn_src_id, src_type_id, subinv,
			snd_rcv, pri_curr,
                        l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, /* umoogala Bug#5708387 13-dec-2006 */
			user_id, login_id, req_id, prg_appid, prg_id,
			O_Error_Num, O_Error_Code, O_Error_Message);

	  if (O_Error_Num <> 0) then
	    raise errexit;
	  end if;

	end if;

        /*----------------------------------------------------------------------+
         | Dr PPV with above amount
         +----------------------------------------------------------------------*/
        -- ppv_amt := (item_cost * p_qty) - ((interorg_xfr_price * p_qty) + trp_cost);

	UPDATE mtl_material_transactions
	   SET variance_amount = (SELECT -1 * nvl(sum(base_transaction_value),0)
				    FROM mtl_transaction_accounts mta
				   WHERE mta.transaction_id = trans_id
				     AND mta.organization_id = org_id
				     AND encumbrance_type_id is null)
	 WHERE transaction_id = trans_id
	RETURNING variance_amount INTO ppv_amt;


        if (ppv_amt <> 0)
        then

          user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                             -1, 6, 1, 0,
                             subinv, cg_id, 0, snd_rcv,
                             O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;

          if user_acct_id > 0
          then
            io_ppv_acct := user_acct_id;
          end if;

          fnd_file.put_line(fnd_file.log, 'Dr PPV with ' || ppv_amt || ' ' || pri_curr);
          CSTPACDP.insert_account
             (org_id, trans_id, item_id, ppv_amt,
              p_qty, io_ppv_acct, sob_id, 6, NULL, NULL,
              txn_date, txn_src_id, src_type_id,
              pri_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1, /* umoogala Bug#5708387 13-dec-2006 */
              user_id, login_id, req_id, prg_appid, prg_id,
              O_Error_Num, O_Error_Code, O_Error_Message);

          if (O_Error_Num <> 0) then
            raise errexit;
          end if;
        end if;

      -- }
      -- End of when (txn_act_id = 15) -- Logical In-transit Receipt
      --

    end case MAIN_CASE_FOR_ACTION_ID;


    /*----------------------------------------------------------------------+
     | Process encumbrance if PO or REQ or INTERNAL ORDER
     +----------------------------------------------------------------------*/
    if (src_type_id = 7 OR src_type_id = 8)
    then
        if (enc_rev is not null AND enc_amt <> 0)
        then

            user_acct_id := CSTPSCHK.std_get_account_id( org_id, trans_id,
                               -1, 15, 1, 0,
                               subinv, cg_id, 0, snd_rcv,
                               O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

            if user_acct_id > 0
            then
              enc_acct := user_acct_id;
            end if;

            fnd_file.put_line(fnd_file.log, 'Cr Enc Acct with ' || enc_amt || ' ' || pri_curr);
            CSTPACDP.insert_account
               (org_id, trans_id, item_id, -1*enc_amt,
                p_qty, enc_acct, sob_id, 15, NULL, NULL,
                txn_date, txn_src_id, src_type_id,
                pri_curr, NULL, NULL, NULL, NULL,1,
                user_id, login_id, req_id, prg_appid, prg_id,
                O_Error_Num, O_Error_Code, O_Error_Message);

            if (O_Error_Num <> 0) then
              raise errexit;
            end if;

        end if;
    end if;

    <<update_cost>>
    /* Transfer Pricing */
    /* Perform accounting adjustment */
    /*
     * - OPM INVCONV process/discrete Xfer Enh.
     * Added 15 and 22 action ids. These gets created only for process/discrete
     * transfers.
     */
    if ( ((txn_act_id = 21 AND src_type_id = 8 AND fob_pt = 1) OR
          (txn_act_id = 12 AND src_type_id = 7 AND fob_pt = 2) OR
	  (txn_act_id = 15 AND src_type_id = 7) OR
	  (txn_act_id = 22 AND src_type_id = 8))
         AND tprice_option <> 0 )
    then
    -- {
       fnd_file.put_line(FND_FILE.LOG, 'Start calling CST_TPRICE_PVT.Adjust_Acct');

       CST_TPRICE_PVT.Adjust_Acct(1.0, p_tprice_option => tprice_option,
                              p_txf_price => txf_price, p_txn_id => trans_id,
                              p_cost_grp_id => cg_id, p_txf_cost_grp => txf_cg_id,
                              p_item_id => item_id, p_txn_date => txn_date,
                              p_qty => p_qty, p_subinv => subinv, p_txf_subinv => txf_subinv,
                              p_txn_org_id => org_id, p_txf_org_id => txf_org_id,
                              p_txf_txn_id => txf_txn_id, p_txf_cost => txf_cost,
                              p_txn_act_id => txn_act_id, p_txn_src_id => txn_src_id,
                              p_src_type_id => src_type_id, p_fob_point => fob_pt,
                              p_user_id => user_id, p_login_id => login_id, p_req_id => req_id,
                              p_prg_appl_id => prg_appid, p_prg_id => prg_id,
                              x_return_status => l_return_status, x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data, x_error_num => O_Error_Num,
                              x_error_code => O_Error_Code, x_error_message => O_Error_Message);

        if O_Error_Num <> 0
        then
          raise errexit;
        end if;

        /* Begin fix for bug#3406184: After Transfer Pricing Accounting,
           added code to call balance account to adjust any rounding errors */

        l_stmt_num := 942;

        fnd_file.put_line(fnd_file.log, 'Balancing Accounts');
        CSTPACDP.balance_account(org_id, trans_id, O_Error_Num, O_Error_Code, O_Error_Message);

        if O_Error_Num <> 0
        then
          raise errexit;
        end if;
        /* End Fix for bug#3406184 */
    -- }
    end if;

    /* For wip_scrap and periodic cost update, we don't update actual cost. */
    if  (txn_act_id <> 30 AND txn_act_id <> 50 AND txn_act_id <> 51
    AND  txn_act_id <> 52 AND txn_act_id <> 40 AND txn_act_id <> 41
	  AND  txn_act_id <> 42 AND txn_act_id <> 43
    AND  NOT (txn_act_id = 24 AND src_type_id = 14))
    then
    -- {
	l_stmt_num := 950;

        /* Change for AX team
        Begin
        */
        -- fnd_file.put_line(fnd_file.log, '[AX]FINAL');
        -- fnd_file.put_line(fnd_file.log, '===================================================');

        uom_conv_rate := 1;

        l_stmt_num := 951;
        if act_cost = 0 then
          act_cost := item_cost;

        end if;

        -- fnd_file.put_line(fnd_file.log, '[AX]item_id = %ld', (long)item_id);
        -- fnd_file.put_line(fnd_file.log, '[AX]send_uom = %s', send_uom.arr);
        -- fnd_file.put_line(fnd_file.log, '[AX]rec_uom = %s', rec_uom.arr);
        -- fnd_file.put_line(fnd_file.log, '[AX]Actual Cost = %6.2f', (float)act_cost);
        -- fnd_file.put_line(fnd_file.log, '===================================================');

        if (txn_act_id = 3 OR txn_act_id = 21 )
        then
        -- {

            l_stmt_num := 952;
            -- fnd_file.put_line(fnd_file.log, '---------------------------------------------------');
            -- fnd_file.put_line(fnd_file.log, '[AX]Transafer Cost = %6.2f', (float)txf_cost);
            -- fnd_file.put_line(fnd_file.log, '[AX]Transport Cost = %6.2f', (float)trp_cost);
            -- fnd_file.put_line(fnd_file.log, '[AX]Primary Qty = %6.2f', (float)p_qty);

            -- fnd_file.put_line(fnd_file.log, '---------------------------------------------------');
            -- fnd_file.put_line(fnd_file.log, '[AX]Curr conv rate = %6.2f', (float)conv_rate);
            -- fnd_file.put_line(fnd_file.log, '[AX in f]UOM conv rate = %6.2f', (float)uom_conv_rate);

        /* commented for bug 2865814 -- these messages raise signal 8 error.
            -- fnd_file.put_line(fnd_file.log, '---------------------------------------------------');
            -- fnd_file.put_line(fnd_file.log, '[AXcstavcpb-formula(sending record)]The Txn cost shld be = %6.2f',
                   (float)(((act_cost*abs(p_qty))+txf_cost+trp_cost)/abs(p_qty)));
            -- fnd_file.put_line(fnd_file.log, '[AXcstavcpb-formula(recving record)]The Rcv Txn cost shld be = %6.2f',
                   (float)(((((act_cost*abs(p_qty))+txf_cost+trp_cost)/abs(p_qty))*conv_rate)/(uom_conv_rate)));
        */
        -- }
        else
        -- {
          if (txn_act_id = 12 )
          then
          -- {
            l_stmt_num := 953;

            -- fnd_file.put_line(fnd_file.log, '[AX]Sendg Transaction Cost = %6.2f', (float)txn_cost);
            -- fnd_file.put_line(fnd_file.log, '[AX*]Rcvg Transaction Cost = %6.2f', (float)txn_cost*conv_rate);
            -- fnd_file.put_line(fnd_file.log, '[AX]Curr conv rate = %6.2f', (float)conv_rate);
            -- fnd_file.put_line(fnd_file.log, '[AX]UOM conv rate = %6.2f', (float)uom_conv_rate);
            -- }
          end if;
        -- }
        end if;

        l_stmt_num := 954;
        UPDATE mtl_material_transactions
           SET transaction_cost = (((txf_price*abs(p_qty))+nvl(trp_cost,0))/abs(p_qty))
         WHERE transaction_id = trans_id;

	l_stmt_num := 957;
        UPDATE mtl_material_transactions
        SET costed_flag = NULL,
            transaction_group_id = NULL,
            request_id = req_id,
            program_application_id = prg_appid,
            program_id = prg_id,
            program_update_date = sysdate,
            actual_cost = decode(zero_cost_flag, 1, 0, nvl(item_cost,0))
        WHERE transaction_id = trans_id;

        /* Create Events in SLA */
        l_trx_info.TRANSACTION_ID       := trans_id;
        l_trx_info.TXN_ACTION_ID        := txn_act_id;
        l_trx_info.TXN_ORGANIZATION_ID  := org_id;
        l_trx_info.TXN_SRC_TYPE_ID      := src_type_id;
        l_trx_info.TXFR_ORGANIZATION_ID := txf_org_id;
        l_trx_info.FOB_POINT            := fob_pt;
        l_trx_info.TRANSACTION_DATE     := txn_date;
        l_trx_info.PRIMARY_QUANTITY     := p_qty;

        IF tprice_option <> 0 THEN
          l_trx_info.TP := 'Y';
        END IF;

        /* umoogala: For process/discrete xfers attribute should always
         * be 'SAME'. Process Org transactions are never picked-up in
         * cost processor.
        IF txn_act_id = 3 THEN
          IF p_qty < 0 THEN
            l_trx_info.attribute := 'SAME';
          ELSE
            l_trx_info.attribute := 'TRANSFER';
          END IF;
        END IF;
        */
        l_trx_info.attribute := 'SAME';

        l_stmt_num := 960;

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
          o_error_num     := -1;
          o_error_code    := 'Error raising SLA Event for transaction: '||to_char(trans_id);
          o_error_message := 'CSTPLCIN.COST_INV_TXN:('||l_stmt_num||'): '||o_error_code;
          RAISE FND_API.g_exc_unexpected_error;
        END IF;


    -- }
    end if;


    COMMIT;

    fnd_file.put_line(fnd_file.log, 'cost_process_discrete_trx >>>');

EXCEPTION
 when moh_rules_error then
      rollback;

      o_error_num := 9999;
      o_error_code := 'CST_RULES_ERROR';
      FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
      o_error_message := FND_MESSAGE.Get;

  when errexit
  then
    fnd_file.put_line(fnd_file.log,'in errexit exception');
    ROLLBACK;

    O_Error_Num     := NVL(O_Error_Num, -1);
    O_Error_Message := 'CSTPACDP.cost_process_discrete_trx:' || '(' || l_stmt_num || '):' ||
                         substr(O_Error_Message, 1, 180);


    UPDATE mtl_material_transactions
    SET    costed_flag = 'E',
           error_code = substrb(O_Error_Code,1,240),
           error_explanation = substrb(O_Error_Message,1,240),
           request_id = req_id,
           program_application_id = prg_appid,
           program_id = prg_id,
           program_update_date = sysdate
    WHERE  transaction_id = trans_id;

    l_stmt_num := 1020;
    COMMIT;

  WHEN FND_API.g_exc_unexpected_error THEN
    rollback;

    UPDATE mtl_material_transactions
    SET    costed_flag = 'E',
           error_code = substrb(O_Error_Code,1,240),
           error_explanation = substrb(O_Error_Message,1,240),
           request_id = req_id,
           program_application_id = prg_appid,
           program_id = prg_id,
           program_update_date = sysdate
    WHERE  transaction_id = trans_id;
    commit;

  when others
  then
    fnd_file.put_line(fnd_file.log,'other exception raised');
    rollback;

    O_error_num  := SQLCODE;
    O_error_code := SQLCODE;
    O_error_message := 'CSTPACDP.cost_process_discrete_trx:' || '(' || to_char(l_stmt_num) || '): '|| substr(SQLERRM,1,180);

    UPDATE mtl_material_transactions
    SET    costed_flag = 'E',
           error_code = substrb(O_Error_Code,1,240),
           error_explanation = substrb(O_Error_Message,1,240),
           request_id = req_id,
           program_application_id = prg_appid,
           program_id = prg_id,
           program_update_date = sysdate
    WHERE  transaction_id = trans_id;

    COMMIT;

end cost_process_discrete_trx;



--BUG#6732955
PROCEDURE balance_account_txn_type(
  i_org_id              IN          NUMBER,
  i_txn_id              IN          NUMBER,
  i_txn_type_id         IN          NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2
)IS
  l_stmt_num    NUMBER;
  l_rowid       ROWID;
  l_base_value  NUMBER;
  l_value       NUMBER;
  l_mta_rec     mtl_transaction_accounts%ROWTYPE;
  l_debug       VARCHAR2(1);
BEGIN

  IF G_DEBUG = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'balance_account_txn_type +');
    fnd_file.put_line(fnd_file.log,'  i_txn_type_id:'||i_txn_type_id);
    fnd_file.put_line(fnd_file.log,'  i_txn_id     :'||i_txn_id);
    fnd_file.put_line(fnd_file.log,'  i_org_id     :'||i_org_id);
  END IF;

  IF (i_txn_type_id <> 16) OR (i_txn_type_id IS NULL) THEN

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling balance_account');
    END IF;

    balance_account(
      I_ORG_ID              => i_org_id,
      I_TXN_ID              => i_txn_id,
      O_Error_Num           => O_Error_Num,
      O_Error_Code          => O_Error_Code,
      O_Error_Message       => O_Error_Message);

  ELSE

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'  Case Logical RMA');
    END IF;


    l_stmt_num := 10;

    SELECT nvl(sum(a.base_transaction_value),0)
          ,nvl(sum(a.transaction_value),0)
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.TRANSACTION_ID))
          ,MAX(NVL(b.cost_of_sales_account,-1))   --adj_acct MP COGS
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.LAST_UPDATE_DATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.LAST_UPDATED_BY))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CREATION_DATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CREATED_BY))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.LAST_UPDATE_LOGIN))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.INVENTORY_ITEM_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.ORGANIZATION_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.TRANSACTION_DATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.TRANSACTION_SOURCE_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.TRANSACTION_SOURCE_TYPE_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.TRANSACTION_VALUE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.PRIMARY_QUANTITY))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.GL_BATCH_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.ACCOUNTING_LINE_TYPE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.BASE_TRANSACTION_VALUE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CONTRA_SET_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.RATE_OR_AMOUNT))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.BASIS_TYPE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.RESOURCE_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.COST_ELEMENT_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.ACTIVITY_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CURRENCY_CODE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CURRENCY_CONVERSION_DATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CURRENCY_CONVERSION_TYPE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.CURRENCY_CONVERSION_RATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.REQUEST_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.PROGRAM_APPLICATION_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.PROGRAM_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.PROGRAM_UPDATE_DATE))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.ENCUMBRANCE_TYPE_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.REPETITIVE_SCHEDULE_ID))
          ,MAX(DECODE(a.accounting_line_type,1,
                                a.USSGL_TRANSACTION_CODE))
      INTO l_base_value
          ,l_value
          ,l_mta_rec.TRANSACTION_ID
          ,l_mta_rec.REFERENCE_ACCOUNT
          ,l_mta_rec.LAST_UPDATE_DATE
          ,l_mta_rec.LAST_UPDATED_BY
          ,l_mta_rec.CREATION_DATE
          ,l_mta_rec.CREATED_BY
          ,l_mta_rec.LAST_UPDATE_LOGIN
          ,l_mta_rec.INVENTORY_ITEM_ID
          ,l_mta_rec.ORGANIZATION_ID
          ,l_mta_rec.TRANSACTION_DATE
          ,l_mta_rec.TRANSACTION_SOURCE_ID
          ,l_mta_rec.TRANSACTION_SOURCE_TYPE_ID
          ,l_mta_rec.TRANSACTION_VALUE
          ,l_mta_rec.PRIMARY_QUANTITY
          ,l_mta_rec.GL_BATCH_ID
          ,l_mta_rec.ACCOUNTING_LINE_TYPE
          ,l_mta_rec.BASE_TRANSACTION_VALUE
          ,l_mta_rec.CONTRA_SET_ID
          ,l_mta_rec.RATE_OR_AMOUNT
          ,l_mta_rec.BASIS_TYPE
          ,l_mta_rec.RESOURCE_ID
          ,l_mta_rec.COST_ELEMENT_ID
          ,l_mta_rec.ACTIVITY_ID
          ,l_mta_rec.CURRENCY_CODE
          ,l_mta_rec.CURRENCY_CONVERSION_DATE
          ,l_mta_rec.CURRENCY_CONVERSION_TYPE
          ,l_mta_rec.CURRENCY_CONVERSION_RATE
          ,l_mta_rec.REQUEST_ID
          ,l_mta_rec.PROGRAM_APPLICATION_ID
          ,l_mta_rec.PROGRAM_ID
          ,l_mta_rec.PROGRAM_UPDATE_DATE
          ,l_mta_rec.ENCUMBRANCE_TYPE_ID
          ,l_mta_rec.REPETITIVE_SCHEDULE_ID
          ,l_mta_rec.USSGL_TRANSACTION_CODE
      FROM mtl_transaction_accounts  a,
           mtl_parameters            b
     WHERE a.transaction_id  = i_txn_id
       AND a.organization_id = i_org_id
       AND b.organization_id = a.organization_id;


    IF (l_base_value = 0 and l_value = 0) THEN
       RETURN;
    END IF;

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'Sum of base        amount: '||l_base_value);
      fnd_file.put_line(fnd_file.log, 'Sum of transaction amount: '||l_value);
    END IF;

    l_stmt_num := 20;

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'Creating the difference in adjustment account');
    END IF;

    IF (l_base_value*l_value >=0 ) THEN

    l_mta_rec.accounting_line_type   := 37;
    l_mta_rec.base_transaction_value := -1 * l_base_value;
    l_mta_rec.transaction_value      := -1 * l_value;



    IF l_base_value <> 0 AND l_mta_rec.primary_quantity <> 0 THEN
      l_mta_rec.rate_or_amount       := l_mta_rec.base_transaction_value
                                       /l_mta_rec.primary_quantity;
    END IF;

    l_mta_rec.PRIMARY_QUANTITY       := -1 * l_mta_rec.PRIMARY_QUANTITY;


    INSERT INTO mtl_transaction_accounts
    ( TRANSACTION_ID
     ,REFERENCE_ACCOUNT
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,CREATION_DATE
     --
     ,CREATED_BY
     ,LAST_UPDATE_LOGIN
     ,INVENTORY_ITEM_ID
     ,ORGANIZATION_ID
     ,TRANSACTION_DATE
     --
     ,TRANSACTION_SOURCE_ID
     ,TRANSACTION_SOURCE_TYPE_ID
     ,TRANSACTION_VALUE
     ,PRIMARY_QUANTITY
     ,GL_BATCH_ID
     --
     ,ACCOUNTING_LINE_TYPE
     ,BASE_TRANSACTION_VALUE
     ,CONTRA_SET_ID
     ,RATE_OR_AMOUNT
     ,BASIS_TYPE
     --
     ,RESOURCE_ID
     ,COST_ELEMENT_ID
     ,ACTIVITY_ID
     ,CURRENCY_CODE
     ,CURRENCY_CONVERSION_DATE
     --
     ,CURRENCY_CONVERSION_TYPE
     ,CURRENCY_CONVERSION_RATE
     ,REQUEST_ID
     ,PROGRAM_APPLICATION_ID
     ,PROGRAM_ID
     --
     ,PROGRAM_UPDATE_DATE
     ,ENCUMBRANCE_TYPE_ID
     ,REPETITIVE_SCHEDULE_ID
     ,GL_SL_LINK_ID
     ,USSGL_TRANSACTION_CODE
     --
     ,INV_SUB_LEDGER_ID              )
     SELECT
            l_mta_rec.TRANSACTION_ID
           ,l_mta_rec.REFERENCE_ACCOUNT
           ,l_mta_rec.LAST_UPDATE_DATE
           ,l_mta_rec.LAST_UPDATED_BY
           ,l_mta_rec.CREATION_DATE
           --
           ,l_mta_rec.CREATED_BY
           ,l_mta_rec.LAST_UPDATE_LOGIN
           ,l_mta_rec.INVENTORY_ITEM_ID
           ,l_mta_rec.ORGANIZATION_ID
           ,l_mta_rec.TRANSACTION_DATE
           --
           ,l_mta_rec.TRANSACTION_SOURCE_ID
           ,l_mta_rec.TRANSACTION_SOURCE_TYPE_ID
           ,l_mta_rec.TRANSACTION_VALUE
           ,l_mta_rec.PRIMARY_QUANTITY
           ,l_mta_rec.GL_BATCH_ID
           --
           ,l_mta_rec.ACCOUNTING_LINE_TYPE
           ,l_mta_rec.BASE_TRANSACTION_VALUE
           ,l_mta_rec.CONTRA_SET_ID
           ,l_mta_rec.RATE_OR_AMOUNT
           ,l_mta_rec.BASIS_TYPE
           --
           ,l_mta_rec.RESOURCE_ID
           ,l_mta_rec.COST_ELEMENT_ID
           ,l_mta_rec.ACTIVITY_ID
           ,l_mta_rec.CURRENCY_CODE
           ,l_mta_rec.CURRENCY_CONVERSION_DATE
           --
           ,l_mta_rec.CURRENCY_CONVERSION_TYPE
           ,l_mta_rec.CURRENCY_CONVERSION_RATE
           ,l_mta_rec.REQUEST_ID
           ,l_mta_rec.PROGRAM_APPLICATION_ID
           ,l_mta_rec.PROGRAM_ID
           --
           ,l_mta_rec.PROGRAM_UPDATE_DATE
           ,l_mta_rec.ENCUMBRANCE_TYPE_ID
           ,l_mta_rec.REPETITIVE_SCHEDULE_ID
           ,l_mta_rec.GL_SL_LINK_ID
           ,l_mta_rec.USSGL_TRANSACTION_CODE
            --
           ,CST_INV_SUB_LEDGER_ID_S.NEXTVAL
     FROM DUAL;

    ELSE

    l_mta_rec.accounting_line_type   := 37;
    l_mta_rec.base_transaction_value := -1 * l_base_value;
    l_mta_rec.transaction_value      := 0;



    IF l_base_value <> 0 AND l_mta_rec.primary_quantity <> 0 THEN
      l_mta_rec.rate_or_amount       := l_mta_rec.base_transaction_value
                                       /l_mta_rec.primary_quantity;
    END IF;

    l_mta_rec.PRIMARY_QUANTITY       := -1 * l_mta_rec.PRIMARY_QUANTITY;


    INSERT INTO mtl_transaction_accounts
    ( TRANSACTION_ID
     ,REFERENCE_ACCOUNT
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,CREATION_DATE
     --
     ,CREATED_BY
     ,LAST_UPDATE_LOGIN
     ,INVENTORY_ITEM_ID
     ,ORGANIZATION_ID
     ,TRANSACTION_DATE
     --
     ,TRANSACTION_SOURCE_ID
     ,TRANSACTION_SOURCE_TYPE_ID
     ,TRANSACTION_VALUE
     ,PRIMARY_QUANTITY
     ,GL_BATCH_ID
     --
     ,ACCOUNTING_LINE_TYPE
     ,BASE_TRANSACTION_VALUE
     ,CONTRA_SET_ID
     ,RATE_OR_AMOUNT
     ,BASIS_TYPE
     --
     ,RESOURCE_ID
     ,COST_ELEMENT_ID
     ,ACTIVITY_ID
     ,CURRENCY_CODE
     ,CURRENCY_CONVERSION_DATE
     --
     ,CURRENCY_CONVERSION_TYPE
     ,CURRENCY_CONVERSION_RATE
     ,REQUEST_ID
     ,PROGRAM_APPLICATION_ID
     ,PROGRAM_ID
     --
     ,PROGRAM_UPDATE_DATE
     ,ENCUMBRANCE_TYPE_ID
     ,REPETITIVE_SCHEDULE_ID
     ,GL_SL_LINK_ID
     ,USSGL_TRANSACTION_CODE
     --
     ,INV_SUB_LEDGER_ID              )
     SELECT
            l_mta_rec.TRANSACTION_ID
           ,l_mta_rec.REFERENCE_ACCOUNT
           ,l_mta_rec.LAST_UPDATE_DATE
           ,l_mta_rec.LAST_UPDATED_BY
           ,l_mta_rec.CREATION_DATE
           --
           ,l_mta_rec.CREATED_BY
           ,l_mta_rec.LAST_UPDATE_LOGIN
           ,l_mta_rec.INVENTORY_ITEM_ID
           ,l_mta_rec.ORGANIZATION_ID
           ,l_mta_rec.TRANSACTION_DATE
           --
           ,l_mta_rec.TRANSACTION_SOURCE_ID
           ,l_mta_rec.TRANSACTION_SOURCE_TYPE_ID
           ,l_mta_rec.TRANSACTION_VALUE
           ,l_mta_rec.PRIMARY_QUANTITY
           ,l_mta_rec.GL_BATCH_ID
           --
           ,l_mta_rec.ACCOUNTING_LINE_TYPE
           ,l_mta_rec.BASE_TRANSACTION_VALUE
           ,l_mta_rec.CONTRA_SET_ID
           ,l_mta_rec.RATE_OR_AMOUNT
           ,l_mta_rec.BASIS_TYPE
           --
           ,l_mta_rec.RESOURCE_ID
           ,l_mta_rec.COST_ELEMENT_ID
           ,l_mta_rec.ACTIVITY_ID
           ,l_mta_rec.CURRENCY_CODE
           ,l_mta_rec.CURRENCY_CONVERSION_DATE
           --
           ,l_mta_rec.CURRENCY_CONVERSION_TYPE
           ,l_mta_rec.CURRENCY_CONVERSION_RATE
           ,l_mta_rec.REQUEST_ID
           ,l_mta_rec.PROGRAM_APPLICATION_ID
           ,l_mta_rec.PROGRAM_ID
           --
           ,l_mta_rec.PROGRAM_UPDATE_DATE
           ,l_mta_rec.ENCUMBRANCE_TYPE_ID
           ,l_mta_rec.REPETITIVE_SCHEDULE_ID
           ,l_mta_rec.GL_SL_LINK_ID
           ,l_mta_rec.USSGL_TRANSACTION_CODE
            --
           ,CST_INV_SUB_LEDGER_ID_S.NEXTVAL
     FROM DUAL;
     /*Find a row which can absorb l_value */
        SELECT MAX(rowid)
	INTO   l_rowid
	FROM   mtl_transaction_accounts
	WHERE  transaction_id = i_txn_id
	AND    organization_id = i_org_id
	AND    accounting_line_type NOT IN (9,10,15)
	AND    sign(base_transaction_value) *
	       sign(nvl(decode(transaction_value, NULL,
				decode(l_value, 0, NULL,-1*l_value),
				transaction_value - l_value),0)) >= 0;
        l_stmt_num := 50;
	IF (G_DEBUG = 'Y') THEN
         fnd_file.put_line(fnd_file.log,'Adjusting the transaction value balance value against record ' || l_rowid);
	END IF;

	update mtl_transaction_accounts
           set transaction_value = decode(transaction_value, NULL,
	                                  decode(l_value, 0, NULL,-1*l_value),
				          transaction_value - l_value)
        where rowid = l_rowid;

    END IF;

  END IF;
  IF G_DEBUG = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'balance_account_txn_type -');
  END IF;
EXCEPTION

 WHEN OTHERS then

   ROLLBACK;
   O_error_num := SQLCODE;
   O_error_message := 'CSTPACDP.balance_account_txn_type (' || to_char(l_stmt_num) ||
                     ') ' || substr(SQLERRM,1,180);

END balance_account_txn_type;




END CSTPACDP;


/
