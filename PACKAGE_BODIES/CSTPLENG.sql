--------------------------------------------------------
--  DDL for Package Body CSTPLENG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLENG" AS
/* $Header: CSTLENGB.pls 120.16.12010000.6 2010/07/16 21:50:27 fayang ship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   compute_layer_actual_cost                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is analogous to the compute_layer_actual_cost( ) in   --
--   average costing. It is called by the cost processor for each         --
--   transaction, so that MCLACD can be populated, and                    --
--   FIFO/LIFO layers consumed or created as necessary                    --
--                                                                        --
-- PURPOSE:                                                               --
--   FIFO/LIFO layer cost processing for Oracle Applications Rel 11i.2    --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id	      : worker organization ID		          --
--            i_layer_id      : layer ID from CQL                         --
--                              (for organization, item, cost group)      --
--            i_cost_method   : FIFO or LIFO cost method                  --
--            i_cost_hook     : presence of actual cost hook              --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
FUNCTION compute_layer_actual_cost(
				i_org_id 		IN	NUMBER,
				i_cost_method		IN	NUMBER,
                        	i_txn_id 		IN	NUMBER,
                        	i_layer_id 		IN	NUMBER,
				i_cost_hook		IN	NUMBER,
                        	i_cost_type 		IN	NUMBER,
                        	i_mat_ct_id 		IN	NUMBER,
			  	i_avg_rates_id		IN	NUMBER,
				i_item_id		IN	NUMBER,
				i_txn_qty		IN	NUMBER,
				i_txn_action_id		IN	NUMBER,
				i_txn_src_type		IN	NUMBER,
				i_interorg_rec		IN	NUMBER,
				i_exp_flag		IN	NUMBER,
				i_user_id		IN	NUMBER,
				i_login_id		IN	NUMBER,
				i_req_id		IN	NUMBER,
				i_prg_appl_id		IN	NUMBER,
				i_prg_id		IN	NUMBER,
				o_err_num		OUT NOCOPY	NUMBER,
				o_err_code		OUT NOCOPY	VARCHAR2,
				o_err_msg		OUT NOCOPY	VARCHAR2
)
return integer IS
    l_cost_hook		NUMBER;
    l_txn_cost_exists 	NUMBER;
    l_ret_val		NUMBER;
    l_err_num		NUMBER;
    l_err_code		VARCHAR2(240);
    l_err_msg		VARCHAR2(240);
    l_stmt_num		NUMBER;
    process_error	EXCEPTION;
    rows_not_found	EXCEPTION;
    l_debug		VARCHAR2(80);

BEGIN
    /* initialize variables */
    l_stmt_num := 0;
    l_err_num := 0;
    l_err_code := '';
    l_err_msg := '';
    l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

    if (l_debug = 'Y') then
    	FND_FILE.PUT_LINE(FND_FILE.LOG,'Compute layer actual cost ...');
    	FND_FILE.PUT_LINE(FND_FILE.LOG,'layer ID : ' || to_char(i_layer_id));
    	FND_FILE.PUT_LINE(FND_FILE.LOG,'cost hook : ' || to_char(i_cost_hook));
    end if;


    /* For WIP component issue and negative component return,layers have already
       been consumed. WIP calls consume_create_layers, to consume the inventory
       layers, populate MCLACD and MCACD, depending on cost hook existence
       or not
     */
    l_stmt_num := 10;
    if (i_txn_src_type = 5 and (i_txn_action_id IN (1,34))) then
          l_ret_val := 1;
          return l_ret_val;
    end if;

    /* If cost hook is used, then ensure that rows are present in MCACD */
    l_stmt_num := 20;
     if (i_cost_hook = 1) then
        select count(*)
        into l_txn_cost_exists
        from mtl_cst_actual_cost_details
        where transaction_id = i_txn_id
        and organization_id = i_org_id
        and actual_cost >= 0;

        /* Raise error if no cost hook data found in MCACD */
        l_stmt_num := 30;
        if (l_txn_cost_exists = 0) then
             raise rows_not_found;
        end if;
     end if;

    /* Call layer engine for creating or consuming inventory layers */
     l_stmt_num := 40;
     	consume_create_layers(i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_hook,
			i_item_id,
			i_txn_qty,
			i_cost_method,
			i_txn_src_type,
			i_txn_action_id,
                        i_interorg_rec,
			i_cost_type,
			i_mat_ct_id,
			i_avg_rates_id,
			i_exp_flag,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
 			l_err_msg);

      	if (l_err_num <> 0) then
 		raise process_error;
	end if;

      l_ret_val := 1;
      return l_ret_val;

  EXCEPTION
    when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
       l_ret_val := 0;
       return l_ret_val;
    when rows_not_found then
       o_err_num := l_err_num;
       o_err_code := 'CST_NO_COST_HOOK_DATA';
	FND_MESSAGE.set_name('BOM','CST_NO_COST_HOOK_DATA');
       o_err_msg := FND_MESSAGE.get;
       l_ret_val := 0;
       return l_ret_val;
    when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.compute_layer_actual_cost (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
       l_ret_val := 0;
       return l_ret_val;
   END compute_layer_actual_cost;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   consume_create_layers                                                --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure determines whether to create or consume inventory     --
--   layers depending on the transaction  action and primary quantity     --
--                                                                        --
-- PURPOSE:                                                               --
--   * Differentiate consumption and receipt transactions                 --
--   * For scrap transactions, it merely populates MCACD, since no        --
--     inventory layers are involved                                      --
--   * If expense flag is 1, then pick up current cost from CQL (similar  --
--     to average costing). Only MCACD is populated since no inventory    --
--     layers are involved.                                               --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id	      : organization ID			          --
--            i_layer_id      : layer ID from CQL                         --
--                              (for organization, item, cost group)      --
--            i_txn_action_id : Transaction action ID                     --
--            i_txn_qty       : primary quantity                          --
--            i_exp_flag      : Expense flag for item/subinventory        --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
PROCEDURE consume_create_layers(
				i_org_id		IN	NUMBER,
				i_txn_id		IN	NUMBER,
				i_layer_id		IN	NUMBER,
 				i_cost_hook		IN	NUMBER,
				i_item_id		IN	NUMBER,
				i_txn_qty		IN	NUMBER,
				i_cost_method		IN	NUMBER,
				i_txn_src_type		IN	NUMBER,
				i_txn_action_id 	IN	NUMBER,
				i_interorg_rec		IN	NUMBER,
				i_cost_type		IN	NUMBER,
				i_mat_ct_id		IN	NUMBER,
				i_avg_rates_id		IN	NUMBER,
				i_exp_flag		IN	NUMBER,
				i_user_id		IN	NUMBER,
				i_login_id		IN	NUMBER,
				i_req_id		IN	NUMBER,
				i_prg_appl_id		IN	NUMBER,
				i_prg_id		IN	NUMBER,
				o_err_num		OUT NOCOPY	NUMBER,
				o_err_code		OUT NOCOPY	VARCHAR2,
 				o_err_msg		OUT NOCOPY	VARCHAR2
				) IS
l_stmt_num		NUMBER;
l_err_num		NUMBER;
l_err_code		VARCHAR2(240);
l_err_msg		VARCHAR2(240);
process_error		EXCEPTION;
l_debug			VARCHAR2(80);

Begin
  /* Initialize variables */
  l_stmt_num := 0;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

  if (l_debug = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Consume/Create Layers...');
  end if;

  if ((i_txn_action_id = 1)   		/* Issue from stores */
      OR (i_interorg_rec = 0)			/* interorg shipment */
      OR ((i_txn_action_id = 21) and (i_txn_qty < 0))
      OR ((i_txn_action_id = 12) and (i_txn_qty < 0))
      OR ((i_txn_action_id = 2) and (i_txn_qty < 0)) /* Subinv send Org */
      OR ((i_txn_action_id = 5) and (i_txn_qty < 0)) /* VMI Planning Transfer send Org */
      OR ((i_txn_action_id = 28) and (i_txn_qty < 0)) /* Staging transfer */
      OR ((i_txn_action_id = 55) and (i_txn_qty < 0)) /* Cost Group transfer for WMS*/
      OR ((i_txn_action_id = 29) and (i_txn_qty < 0)) /* negative delivery adj*/
      OR ((i_txn_action_id = 4 OR i_txn_action_id = 8) and (i_txn_qty < 0)) /*physical inv, cycle count -ve adj*/
      OR (i_txn_action_id = 32) /* assembly return */
      OR (i_txn_action_id = 34) /* negative component return */
      OR (i_txn_action_id = 6 and i_txn_src_type = 13) /* Reverse change of
                                                          ownership */
      OR ( i_txn_action_id = 9 and i_txn_qty < 0 ) /* Logical IC Sales Issue */
         /* Logical IC Sales Issues consume layers only when they are
            in the organization of the Physical Issue
            This function is called only in that case, hence that check is
            redundant */
     ) then
         l_stmt_num := 10;
       if (l_debug = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Consumption Transaction ...');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Action ID : ' || to_char(i_txn_action_id));
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Primary Qty : ' || to_char(i_txn_qty));
       end if;
         consume_layers(
 			i_org_id,
			i_txn_id,
			i_layer_id,
			i_item_id,
			i_txn_qty,
			i_cost_method,
			i_txn_src_type,
                  	i_txn_action_id,
                  	i_cost_hook,
			i_interorg_rec,
			i_cost_type,
			i_mat_ct_id,
			i_avg_rates_id,
			i_exp_flag,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg
                  	);

           if (l_err_num <> 0) then
			raise process_error;
	     end if;

  elsif ((i_interorg_rec = 1) /* interorg receipt */
         OR ((i_txn_action_id = 12) and (i_txn_qty > 0))
         OR ((i_txn_action_id = 21) and (i_txn_qty > 0))
         OR ((i_txn_action_id = 2) and (i_txn_qty > 0)) /* sub transfer rcv org */
         OR ((i_txn_action_id = 5) and (i_txn_qty > 0)) /* VMI planning transfer rcv org */
         OR ((i_txn_action_id = 28) and (i_txn_qty > 0)) /* Staging transfer */
         OR ((i_txn_action_id = 55) and (i_txn_qty > 0)) /* Cost Group transfer */
         OR (i_txn_action_id = 27) /* receipt into stores */
         OR ((i_txn_action_id = 29) and (i_txn_qty > 0)) /* positive delivery adjustment */
         OR ((i_txn_action_id = 4 OR i_txn_action_id = 8) and (i_txn_qty > 0)) /* +ve cycle count or physical inv adjustment */
         OR (i_txn_action_id = 31) /* assembly completion */
         OR (i_txn_action_id = 33) /* negative component issue */
         OR (i_txn_action_id = 6 and i_txn_src_type = 1) /* Change of ownership
                                                         */
         --{BUG#6902140
         OR ( i_txn_action_id = 14 and i_txn_qty > 0 )  /*logical IC Sales Return*/
         --}
	 /*Bug 7381166*/
         OR ( i_txn_action_id = 26 and i_txn_qty > 0 )  /*logical Receipt*/
        ) then
            l_stmt_num := 20;
         if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Transaction creates inventory layers ...');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Action ID : ' || to_char(i_txn_action_id));
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Primary Qty : ' || to_char(i_txn_qty));
         end if;
            create_layers(
 			i_org_id,
			i_txn_id,
			i_layer_id,
			i_item_id,
			i_txn_qty,
			i_cost_method,
			i_txn_src_type,
                  	i_txn_action_id,
                  	i_cost_hook,
			i_interorg_rec,
			i_cost_type,
			i_mat_ct_id,
			i_avg_rates_id,
			i_exp_flag,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg
                  	);

		  if (l_err_num <> 0) then
			  raise process_error;
		  end if;

  elsif (i_txn_action_id = 30) then
   /* scrap transaction */
         l_stmt_num := 30;
         if (i_cost_hook = 1) then
            if (l_debug = 'Y') then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Scrap transaction with cost hook');
            end if;
              return;
         else
            if (l_debug = 'Y') then
            	FND_FILE.PUT_LINE(FND_FILE.LOG,'Scrap transaction inserts into MCACD');
            end if;
            insert into mtl_cst_actual_cost_details (
					transaction_id,
					organization_id,
					layer_id,
					cost_element_id,
					level_type,
					transaction_action_id,
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
					actual_cost,
					prior_cost,
					new_cost,
					insertion_flag,
					variance_amount,
					user_entered)
             		select
					i_txn_id,
					i_org_id,
					i_layer_id,
					mctcd.cost_element_id,
					mctcd.level_type,
					i_txn_action_id,
					sysdate,
					i_user_id,
					sysdate,
					i_user_id,
					i_login_id,
					i_req_id,
					i_prg_appl_id,
					i_prg_id,
					sysdate,
					mctcd.inventory_item_id,
					mctcd.transaction_cost,
					0,
					NULL,
					'N',
					0,
					'N'
				from mtl_cst_txn_cost_details mctcd
				where mctcd.transaction_id = i_txn_id
				and mctcd.organization_id = i_org_id
				and mctcd.transaction_cost >= 0;
		end if;
  end if;

  if (l_err_num <> 0) then
      raise process_error;
  end if;

EXCEPTION
    when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;

    when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.consume_create_layers (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);

End consume_create_layers;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   get_source_number	                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   This function is used to obtain the transaction source               --
--  for user identification of each transaction that creates an inventory --
--  layer                                                                 --
--    The transaction_source is identified based on the transaction       --
--  source type. It defaults to the transaction_id                        --
--                                                                        --
-- PURPOSE:                                                               --
--   obtain user identifiable transaction source to identify inventory    --
--   layers  								  --
--                                                                        --
-- PARAMETERS:                                                            --
--    i_txn_id   :  transaction id					  --
--    i_src_id   :  transaction source id 				  --
--    i_src_type : transaction source type                                --
--            								  --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
FUNCTION get_source_number (i_txn_id	 IN	NUMBER,
  		       i_txn_src_type 	 IN	NUMBER,
		       i_src_id	 	IN	NUMBER
			)
return VARCHAR2 IS
   l_src_number 	VARCHAR2(240);
   l_debug		VARCHAR2(80);

Begin
   l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
   if (i_txn_src_type = 1) then
      /* Purchase Order, use RCV transaction ID */
      /* Bug 3291126, we should use PO number */
        select po.segment1
        into l_src_number
        from mtl_material_transactions mmt, po_headers_all po
        where mmt.transaction_id = i_txn_id
        and mmt.transaction_source_id = po.po_header_id;
   elsif (i_txn_src_type = 2) then
       /* Sales Order, use Order Number */
	  select segment1
	  into l_src_number
	  from mtl_sales_orders
        where sales_order_id = i_src_id;
   elsif (i_txn_src_type = 3) then
       /* Account, use Account # */
	  select concatenated_segments
	  into l_src_number
        from gl_code_combinations_kfv
	  where code_combination_id = i_src_id;
   elsif (i_txn_src_type = 5) then
       /* job or Schedule, use Job name */
        select wip_entity_name
        into l_src_number
        from wip_entities
 	  where wip_entity_id = i_src_id;
   elsif (i_txn_src_type = 6) then
	 /* Account alias, use account number */
        select concatenated_segments
	  into l_src_number
  	  from gl_code_combinations_kfv
	  where code_combination_id = (select distribution_account
				     from mtl_generic_dispositions
				     where disposition_id = i_src_id);
   elsif (i_txn_src_type = 7) then
       /* internal requisition, use Requisition number */
	  select segment1
	  into l_src_number
        from po_requisition_headers_all
	  where requisition_header_id = i_src_id;
   elsif (i_txn_src_type = 8) then
	 /* internal order, use order number */
	  select segment1
        into l_src_number
        from mtl_sales_orders
        where sales_order_id = i_src_id;
   elsif (i_txn_src_type = 9) then
       /* Cycle count, use cycle count header name */
	  select cycle_count_header_name
        into l_src_number
        from mtl_cycle_count_headers
	  where cycle_count_header_id = i_src_id;
   elsif (i_txn_src_type = 10) then
	 /* physical inventory adjustment, use physical Inv name */
        select physical_inventory_name
        into l_src_number
        from mtl_physical_inventories
        where physical_inventory_id = i_src_id;
   elsif (i_txn_src_type = 12) then
       /* RMA, use sales order number */
	  select segment1
        into l_src_number
        from mtl_sales_orders
	  where sales_order_id = i_src_id;
   elsif (i_txn_src_type = 13) then
	 /* Inventory, use distribution account ID */
        select concatenated_segments
        into l_src_number
        from gl_code_combinations_kfv
        where code_combination_id = (select
                         nvl(mmt.distribution_account_id,mmt.transaction_source_id)
                                     from mtl_material_transactions mmt
                                     where transaction_id = i_txn_id);
   else
        l_src_number := to_char(i_txn_id);
   end if;

   if (l_debug = 'Y') then
   	FND_FILE.PUT_LINE(FND_FILE.LOG,'get_source_number ...');
   	FND_FILE.PUT_LINE(FND_FILE.LOG,'Txn Src Type : ' || to_char(i_txn_src_type));
   	FND_FILE.PUT_LINE(FND_FILE.LOG,'Txn Src ID : ' || to_char(i_src_id));
   	FND_FILE.PUT_LINE(FND_FILE.LOG,'Txn Source : ' || l_src_number);
   end if;

   return l_src_number;
EXCEPTION
   when no_data_found then
    l_src_number := to_char(i_txn_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'No data found, using transaction ID');
    return l_src_number;

END get_source_number;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_mclacd                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Based on the actual_cost_table flag, this procedure picks up costs --
--     from the view cst_layer_actual_costs_v and inserts the cost        --
--     details into MCLACD                                                --
--   * The view is built on top of MCACD,MCTCD and CILCD, with a table    --
--     flag that indicates which portion of the UNION clause needs to be  --
--     execuated during each select against the view.                     --
--                                                                        --
-- PURPOSE:                                                               --
--   A single function used to insert transaction cost details into       --
--    MCLACD. 								  --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_actual_cost_table : table from which actual costs are obtained  --
--      i_layer_cost_table  : table from which layers costs are obtained  --
--      i_cur_layer_id      : the inventory layer inserted into MCLACD    --
--      i_actual_layer_id   : inventory layer whose costs are used        --
--      i_mode              : (CREATE,CONSUME,REPLENISH), determines if   --
--                            outer join is required                      --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE insert_mclacd	 (
			i_txn_id		IN	NUMBER,
			i_org_id		IN	NUMBER,
			i_item_id		IN	NUMBER,
			i_layer_id		IN	NUMBER,
			i_cur_layer_id		IN	NUMBER,
			i_qty			IN	NUMBER,
			i_txn_action_id		IN	NUMBER,
			i_user_id		IN	NUMBER,
			i_login_id		IN	NUMBER,
			i_req_id		IN	NUMBER,
			i_prg_id		IN	NUMBER,
			i_prg_appl_id		IN	NUMBER,
			i_actual_cost_table 	IN	VARCHAR2,
			i_layer_cost_table	IN	VARCHAR2,
			i_actual_layer_id	IN	NUMBER,
                        i_mode			IN	VARCHAR2,
			o_err_num 		OUT NOCOPY	NUMBER,
			o_err_code		OUT NOCOPY	VARCHAR2,
			o_err_msg		OUT NOCOPY	VARCHAR2
			)
/* i_cur_layer_id is the inv layer which is being used in MCLACD, to get the
   layer costs
   i_actual_layer_id is used to get the actual costs
 */
IS
  l_stmt_num	NUMBER;
  l_err_num 	NUMBER;
  l_txn_type_id NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  process_error	EXCEPTION;
  l_mclacd_exists NUMBER;
  l_debug 	VARCHAR2(80);

  /* EAM Acct Enh Project */
  l_zero_cost_flag	NUMBER := -1;
  l_return_status	VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count		NUMBER := 0;
  l_msg_data            VARCHAR2(8000) := '';
  l_api_message		VARCHAR2(8000);

Begin
  l_stmt_num := 0;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

  select transaction_type_id
  into l_txn_type_id
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  /* Write to log file */
  if (l_debug = 'Y') then
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert Row in MCLACD...');
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'layer_id:' || to_char(i_layer_id));
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'cur_layer:' || to_char(i_cur_layer_id));
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'qty :'|| to_char(i_qty));
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'actual_cost_table:' || (i_actual_cost_table));
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'layer_cost_table:' || (i_layer_cost_table));
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'actual_layer_id :' || to_char(i_actual_layer_id));
  end if;

  select count(*)
  into l_mclacd_exists
  from mtl_cst_layer_act_cost_details
  where transaction_id = i_txn_id
  and layer_id = i_layer_id
  and inv_layer_id = i_cur_layer_id;

  if (l_mclacd_exists > 0) then
       l_stmt_num := 2;
       update mtl_cst_layer_act_cost_details
       set layer_quantity = nvl(layer_quantity,0) + i_qty,
       variance_amount = nvl(variance_amount,0) + (nvl(actual_cost,0)-nvl(layer_cost,0))*i_qty
       where transaction_id = i_txn_id
       and layer_id = i_layer_id
       and inv_layer_id = i_actual_layer_id;
/* when in layer is driven negative, then apply_layer_material_ovhd should not be called again */
       if (i_mode = 'CONSUME') then
             o_err_num := 999;
       end if;
  else
        /* changed the logic for the bug 5016055
	 combinations:
           mode        actual_cost_table    layer_cost_table
             -----       -----------------    ----------------
          1) CREATE      MCACD                 MCACD
          2) CREATE      MCTCD                 MCTCD
          3) CREATE      CILCD                 CILCD
          4) CREATE      None                  None
          5) UDPATE      CILCD                 CILCD
          6) REPLENISH   CILCD                 CILCD
          7) CONSUME     MCACD                 CILCD
          8) CONSUME     MCTCD                 CILCD
          9) CONSUME     CILCD                 CILCD

	  */
          -- case 1  CREATE      MCACD MCACD
         if(i_mode = 'CREATE' and i_actual_cost_table = 'MCACD' and i_layer_cost_table = 'MCACD') then

	                /* EAM Acct Enh Project */
	  CST_Utility_PUB.get_zeroCostIssue_flag (
	    p_api_version	=>	1.0,
	    x_return_status	=>	l_return_status,
	    x_msg_count		=>	l_msg_count,
	    x_msg_data		=>	l_msg_data,
	    p_txn_id		=>	i_txn_id,
	    x_zero_cost_flag	=>	l_zero_cost_flag
	    );

	  if (l_return_status <> fnd_api.g_ret_sts_success) then
	    FND_FILE.put_line(FND_FILE.log, l_msg_data);
	    l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	    FND_MESSAGE.set_token('TEXT', l_api_message);
	    FND_MSG_pub.add;
	    raise fnd_api.g_exc_unexpected_error;
	  end if;

	  if (l_debug = 'Y') then
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag: '|| to_char(l_zero_cost_flag));
	  end if;

		      insert into mtl_cst_layer_act_cost_details (
	                        transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id, -- txn id
			i_org_id, -- org id
			i_layer_id,
			i_cur_layer_id,
			mcacd.cost_element_id,
			mcacd.level_type,
                        i_qty,
			decode(l_zero_cost_flag, 1, 0,mcacd.actual_cost),
			decode(l_zero_cost_flag, 1, 0,mcacd.actual_cost),
			0,
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         from   mtl_cst_actual_cost_details mcacd
		 where mcacd.organization_id = i_org_id
		and mcacd.transaction_id = i_txn_id
		and mcacd.user_entered = 'Y';

           -- case 2  CREATE      MCTCD MCTCD
         elsif(i_mode = 'CREATE' and i_actual_cost_table = 'MCTCD' and i_layer_cost_table = 'MCTCD') then

	                /* EAM Acct Enh Project */
	  CST_Utility_PUB.get_zeroCostIssue_flag (
	    p_api_version	=>	1.0,
	    x_return_status	=>	l_return_status,
	    x_msg_count		=>	l_msg_count,
	    x_msg_data		=>	l_msg_data,
	    p_txn_id		=>	i_txn_id,
	    x_zero_cost_flag	=>	l_zero_cost_flag
	    );

	  if (l_return_status <> fnd_api.g_ret_sts_success) then
	    FND_FILE.put_line(FND_FILE.log, l_msg_data);
	    l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	    FND_MESSAGE.set_token('TEXT', l_api_message);
	    FND_MSG_pub.add;
	    raise fnd_api.g_exc_unexpected_error;
	  end if;

	  if (l_debug = 'Y') then
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag: '|| to_char(l_zero_cost_flag));
	  end if;

	        insert into mtl_cst_layer_act_cost_details (
	                        transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			mctcd.cost_element_id,
			mctcd.level_type,
                        i_qty,
			decode(l_zero_cost_flag, 1, 0,mctcd.transaction_cost),
			decode(l_zero_cost_flag, 1, 0,mctcd.transaction_cost),
			0,
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         from   mtl_cst_txn_cost_details mctcd
		 where mctcd.organization_id = i_org_id
		and mctcd.transaction_id = i_txn_id ;

              -- case 4 CREATE   None  None
         elsif(i_mode = 'CREATE' and i_actual_cost_table = 'NONE' and i_layer_cost_table = 'NONE') then

	         insert into mtl_cst_layer_act_cost_details (
				transaction_id,
				organization_id,
                                layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
	     select i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			1, --CE
			1, --LT
			i_qty,
			0, --layer cost
			0, -- actual cost
			0, -- var amount
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
		from dual;
             -- case 6 REPLENISH   CILCD CILCD
         elsif(i_mode = 'REPLENISH' and i_actual_cost_table = 'CILCD' and i_layer_cost_table = 'CILCD') then

	          insert into mtl_cst_layer_act_cost_details (
	                        transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				payback_variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd2.cost_element_id,
			cilcd2.level_type,
                        i_qty,
			nvl(cilcd2.layer_cost,0),
			nvl(cilcd1.layer_cost,0),
			decode(l_txn_type_id,68,0,(nvl(cilcd1.layer_cost,0)-nvl(cilcd2.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(cilcd1.layer_cost,0)-nvl(cilcd2.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	       FROM    cst_inv_layer_cost_details cilcd1,
                       cst_inv_layer_cost_details cilcd2
               where   cilcd1.inv_layer_id (+) = i_actual_layer_id
	       and     cilcd2.inv_layer_id  = i_cur_layer_id
	       and     cilcd1.cost_element_id(+)  = cilcd2.cost_element_id
	       and     cilcd1.level_type (+) = cilcd2.level_type
	       UNION
	       select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd1.cost_element_id,
			cilcd1.level_type,
                        i_qty,
			nvl(cilcd2.layer_cost,0),
			nvl(cilcd1.layer_cost,0),
			decode(l_txn_type_id,68,0,(nvl(cilcd1.layer_cost,0)-nvl(cilcd2.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(cilcd1.layer_cost,0)-nvl(cilcd2.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	       FROM    cst_inv_layer_cost_details cilcd1,
                       cst_inv_layer_cost_details cilcd2
               where  cilcd1.inv_layer_id  = i_actual_layer_id
	       and     cilcd2.inv_layer_id(+)  = i_cur_layer_id
	       and     cilcd1.cost_element_id  = cilcd2.cost_element_id (+)
	       and     cilcd1.level_type  = cilcd2.level_type(+);

	        -- case 7 CONSUME     MCACD CILCD
         elsif(i_mode = 'CONSUME' and i_actual_cost_table = 'MCACD' and i_layer_cost_table = 'CILCD') then

	         insert into mtl_cst_layer_act_cost_details (
	                        transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				payback_variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd.cost_element_id,
			cilcd.level_type,
                        i_qty,
			nvl(cilcd.layer_cost,0),
			nvl(mcacd.actual_cost,0),
			decode(l_txn_type_id,68,0,(nvl(mcacd.actual_cost,0)-nvl(cilcd.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(mcacd.actual_cost,0)-nvl(cilcd.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         FROM    cst_inv_layer_cost_details cilcd,mtl_cst_actual_cost_details mcacd
                where   mcacd.organization_id (+)  = i_org_id
		and     mcacd.transaction_id(+)  =  i_txn_id
                and     cilcd.inv_layer_id  = i_cur_layer_id
		and     cilcd.cost_element_id  = mcacd.cost_element_id (+)
		and     cilcd.level_type  = mcacd.level_type (+)
                AND     mcacd.user_entered(+) = 'Y'
		UNION
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			mcacd.cost_element_id,
			mcacd.level_type,
                        i_qty,
			nvl(cilcd.layer_cost,0),
			nvl(mcacd.actual_cost,0),
			decode(l_txn_type_id,68,0,(nvl(mcacd.actual_cost,0)-nvl(cilcd.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(mcacd.actual_cost,0)-nvl(cilcd.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         FROM    cst_inv_layer_cost_details cilcd,mtl_cst_actual_cost_details mcacd
                where   mcacd.organization_id  = i_org_id
		and     mcacd.transaction_id  =  i_txn_id
                and     cilcd.inv_layer_id(+)  = i_cur_layer_id
		and     cilcd.cost_element_id(+)  = mcacd.cost_element_id
		and     cilcd.level_type (+)  = mcacd.level_type
                AND     mcacd.user_entered = 'Y' ;


               -- case 8 CONSUME     MCTCD CILCD
         elsif(i_mode = 'CONSUME' and i_actual_cost_table = 'MCTCD' and i_layer_cost_table = 'CILCD') then
		        insert into mtl_cst_layer_act_cost_details (
	                        transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				payback_variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd.cost_element_id,
			cilcd.level_type,
                        i_qty,
			nvl(cilcd.layer_cost,0),
			nvl(mctcd.transaction_cost,0),
			decode(l_txn_type_id,68,0,(nvl(mctcd.transaction_cost,0)-nvl(cilcd.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(mctcd.transaction_cost,0)-nvl(cilcd.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         FROM    cst_inv_layer_cost_details cilcd,mtl_cst_txn_cost_details mctcd
                 where   mctcd.organization_id(+)  = i_org_id
		 and     mctcd.transaction_id (+) =  i_txn_id
                 and     cilcd.inv_layer_id  = i_cur_layer_id
		 and     cilcd.cost_element_id  = mctcd.cost_element_id (+)
		 and     cilcd.level_type  = mctcd.level_type (+)
		 UNION
		 select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			mctcd.cost_element_id,
			mctcd.level_type,
                        i_qty,
			nvl(cilcd.layer_cost,0),
			nvl(mctcd.transaction_cost,0),
			decode(l_txn_type_id,68,0,(nvl(mctcd.transaction_cost,0)-nvl(cilcd.layer_cost,0))*i_qty),
                        decode(l_txn_type_id,68,(nvl(mctcd.transaction_cost,0)-nvl(cilcd.layer_cost,0))*i_qty,0),
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         FROM    cst_inv_layer_cost_details cilcd,mtl_cst_txn_cost_details mctcd
                 where   mctcd.organization_id  = i_org_id
		 and     mctcd.transaction_id  =  i_txn_id
                 and     cilcd.inv_layer_id (+) = i_cur_layer_id
		 and     cilcd.cost_element_id(+)  = mctcd.cost_element_id
		 and     cilcd.level_type(+) = mctcd.level_type ;

            -- case 3 CREATE      CILCD CILCD
	    -- case 5 UDPATE      CILCD CILCD
	    -- case 9 CONSUME     CILCD CILCD
         elsif(   (i_mode = 'CREATE' and i_actual_cost_table = 'CILCD' and i_layer_cost_table = 'CILCD')
	        OR(i_mode = 'UPDATE' and i_actual_cost_table = 'CILCD' and i_layer_cost_table = 'CILCD')
		OR(i_mode = 'CONSUME' and i_actual_cost_table = 'CILCD' and i_layer_cost_table = 'CILCD')
	       ) then

	                /* EAM Acct Enh Project */
	  CST_Utility_PUB.get_zeroCostIssue_flag (
	    p_api_version	=>	1.0,
	    x_return_status	=>	l_return_status,
	    x_msg_count		=>	l_msg_count,
	    x_msg_data		=>	l_msg_data,
	    p_txn_id		=>	i_txn_id,
	    x_zero_cost_flag	=>	l_zero_cost_flag
	    );

	  if (l_return_status <> fnd_api.g_ret_sts_success) then
	    FND_FILE.put_line(FND_FILE.log, l_msg_data);
	    l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	    FND_MESSAGE.set_token('TEXT', l_api_message);
	    FND_MSG_pub.add;
	    raise fnd_api.g_exc_unexpected_error;
	  end if;

	  if (l_debug = 'Y') then
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag: '|| to_char(l_zero_cost_flag));
	  end if;
	          insert into mtl_cst_layer_act_cost_details (
	                      transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
		select  i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd.cost_element_id,
			cilcd.level_type,
                        i_qty,
			decode(l_zero_cost_flag, 1, 0,cilcd.layer_cost),
			decode(l_zero_cost_flag, 1, 0,cilcd.layer_cost),
			0,
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
	         from cst_inv_layers cil, cst_inv_layer_cost_details cilcd
		 where cil.inv_layer_id = cilcd.inv_layer_id
		   and cil.layer_id = cilcd.layer_id
		   and cil.inv_layer_id = i_actual_layer_id;

       else /* Else Case */
	  l_stmt_num := 15;
  	  /* EAM Acct Enh Project */
	  CST_Utility_PUB.get_zeroCostIssue_flag (
	    p_api_version	=>	1.0,
	    x_return_status	=>	l_return_status,
	    x_msg_count		=>	l_msg_count,
	    x_msg_data		=>	l_msg_data,
	    p_txn_id		=>	i_txn_id,
	    x_zero_cost_flag	=>	l_zero_cost_flag
	    );

	  if (l_return_status <> fnd_api.g_ret_sts_success) then
	    FND_FILE.put_line(FND_FILE.log, l_msg_data);
	    l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	    FND_MESSAGE.set_token('TEXT', l_api_message);
	    FND_MSG_pub.add;
	    raise fnd_api.g_exc_unexpected_error;
	  end if;

	  if (l_debug = 'Y') then
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag: '|| to_char(l_zero_cost_flag));
	  end if;

          l_stmt_num := 20;

          insert into mtl_cst_layer_act_cost_details (
				transaction_id,
				organization_id,
				layer_id,
				inv_layer_id,
				cost_element_id,
				level_type,
				layer_quantity,
				layer_cost,
				actual_cost,
				variance_amount,
				inventory_item_id,
				user_entered,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
	     select i_txn_id,
			i_org_id,
			i_layer_id,
			i_cur_layer_id,
			cilcd.cost_element_id,
			cilcd.level_type,
                        i_qty,
			decode(l_zero_cost_flag, 1, 0, cilcd.layer_cost),
			decode(l_zero_cost_flag, 1, 0, cilcd.layer_cost),
			0,
			i_item_id,
			'N',
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
		from   cst_inv_layers cil, cst_inv_layer_cost_details cilcd
		 where cil.inv_layer_id = cilcd.inv_layer_id
		   and cil.layer_id = cilcd.layer_id
		   and cil.inv_layer_id = i_actual_layer_id;


            end if;
    end if;
 if (l_debug = 'Y') then
   FND_FILE.PUT_LINE(FND_FILE.LOG,sql%rowcount || ' records inserted using stmt : ' || to_char(l_stmt_num));
 end if;

   if ((l_err_num <> 0) and (l_err_num <> 999)) then
        raise process_error;
   end if;

EXCEPTION
   when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
   when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.insert_mclacd (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
End insert_mclacd;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   create_layers                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Create inventory layer for i_txn_qty (maybe negative) OR add       --
--     i_txn_qty to the inventory layer created last                      --
--   * Insert into CIL,CILCD,MCLACD using costs from MCACD(cost hook),    --
--     MCTCD(if available), CILCD(latest layer cost,the layer may or      --
--     may not have positive qty), 0 cost if no costs available           --
--     update CIL layer cost, burden cost and unburdened cost             --
--   * If layer created has positive quantity, then replenish all         --
--     negative inventory layers                                          --
--                                                                        --
-- PURPOSE:                                                               --
--     create inventory layers using the sequence cst_inv_layers_s        --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_txn_qty      : primary quantity                                 --
--      i_interorg_rec : interorg shimpment (= 0),                        --
--                       interorg receipt (= 1)                           --
--                       subinv transfer with no layer change (= 3)       --
--                       otherwise (= null)                               --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
--    09/14/02     Ray  	  Changes for Layer Minimization (BOM.I)  --
----------------------------------------------------------------------------
procedure create_layers(
	i_org_id		IN	NUMBER,
	i_txn_id		IN	NUMBER,
	i_layer_id		IN	NUMBER,
	i_item_id		IN	NUMBER,
	i_txn_qty		IN	NUMBER,
	i_cost_method		IN	NUMBER,
	i_txn_src_type		IN	NUMBER,
        i_txn_action_id   	IN    	NUMBER,
        i_cost_hook		IN	NUMBER,
	i_interorg_rec		IN	NUMBER,
	i_cost_type		IN	NUMBER,
	i_mat_ct_id		IN	NUMBER,
	i_avg_rates_id		IN	NUMBER,
	i_exp_flag		IN	NUMBER,
	i_user_id		IN	NUMBER,
	i_login_id		IN	NUMBER,
	i_req_id		IN	NUMBER,
	i_prg_appl_id		IN	NUMBER,
	i_prg_id		IN	NUMBER,
	o_err_num		OUT NOCOPY	NUMBER,
	o_err_code		OUT NOCOPY	VARCHAR2,
	o_err_msg		OUT NOCOPY	VARCHAR2
) IS
	TYPE LayerCurType IS REF CURSOR;

 	negative_layer_cursor	LayerCurType;
	sql_stmt 		VARCHAR2(240);
    	l_stmt_num		NUMBER;
    	l_err_num		NUMBER;
	l_err_code		VARCHAR2(240);
	l_err_msg		VARCHAR2(240);
      	l_src_id		NUMBER;
	l_src_number		VARCHAR2(240);
      	l_inv_layer_id 		NUMBER;
      	l_neg_layer_id 		NUMBER;
      	l_neg_layer_qty		NUMBER;
      	l_qty_available		NUMBER;
      	l_qty			NUMBER;
        l_count         	NUMBER;
	l_actual_cost_table 	VARCHAR2(20);
        l_from_org      	NUMBER;
        process_error 		EXCEPTION;
        l_debug			VARCHAR2(80);
	l_create		NUMBER;
	l_last_txn_id           NUMBER;
	l_last_txn_type_id      NUMBER;
	l_last_rcv_txn_id       NUMBER;
	l_last_moh   	  	NUMBER;
	l_txn_type_id           NUMBER;
	l_rcv_txn_id		NUMBER;
	l_moh	           	NUMBER;
	l_last_layer_cost  	NUMBER;
	l_layer_cost       	NUMBER;
	l_merge                 NUMBER;
BEGIN
      	/* Initialize */
	l_stmt_num 	:= 0;
	l_err_num 	:= 0;
	l_err_code 	:= '';
	l_err_msg	:= '';
        l_from_org 	:= 0;
	l_debug 	:= FND_PROFILE.VALUE('MRP_DEBUG');
	l_create	:= 1;

  	/* If expense item, then insert into MCACD using current costs. No inventory layer created */
   	IF (i_exp_flag = 1) THEN
     		IF (l_debug = 'Y') THEN
       			FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into MCACD for expense flag of 1...');
     		END IF;

		l_stmt_num := 5;
      		SELECT 	COUNT(*)
		INTO	l_count
      		FROM 	mtl_cst_txn_cost_details
      		WHERE 	transaction_id = i_txn_id
      		AND 	organization_id = i_org_id;

      		IF (l_count > 0) THEN
			l_stmt_num := 10;
          		INSERT
			INTO 	mtl_cst_actual_cost_details (
				transaction_id,
				organization_id,
				layer_id,
				cost_element_id,
				level_type,
				transaction_action_id,
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
				actual_cost,
				prior_cost,
				new_cost,
				insertion_flag,
				variance_amount,
				user_entered)
			SELECT 	i_txn_id,
				i_org_id,
				i_layer_id,
				ctcd.cost_element_id,
				ctcd.level_type,
				i_txn_action_id,
				sysdate,
				i_user_id,
				sysdate,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				sysdate,
				ctcd.inventory_item_id,
				ctcd.transaction_cost,
				0,
				0,
				'Y',
				0,
				'N'
			FROM 	mtl_cst_txn_cost_details ctcd
			WHERE	ctcd.transaction_id = i_txn_id
			AND	ctcd.organization_id = i_org_id
			/*AND	ctcd.transaction_cost >= 0*/; -- commented for bug#3835412
		ELSE
			l_stmt_num := 15;
      			SELECT 	count(*)
			INTO	l_count
      			FROM 	cst_layer_cost_details
      			WHERE	layer_id = i_layer_id;

      			IF (l_count > 0) THEN
				l_stmt_num := 20;
           			INSERT
				INTO	mtl_cst_actual_cost_details (
					transaction_id,
					organization_id,
					layer_id,
					cost_element_id,
					level_type,
					transaction_action_id,
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
                                	actual_cost,
                                	prior_cost,
                                	new_cost,
                                	insertion_flag,
                                	variance_amount,
	                                user_entered)
		  		SELECT  i_txn_id,
					i_org_id,
					i_layer_id,
					clcd.cost_element_id,
					clcd.level_type,
					i_txn_action_id,
					sysdate,
					i_user_id,
					sysdate,
					i_user_id,
					i_login_id,
					i_req_id,
					i_prg_appl_id,
					i_prg_id,
					sysdate,
					i_item_id,
					clcd.item_cost,
					clcd.item_cost,
					clcd.item_cost,
					'N',
					0,
					'N'
				FROM	cst_layer_cost_details clcd
				WHERE	layer_id = i_layer_id;
            		ELSE
				l_stmt_num := 25;
                		INSERT
				INTO	mtl_cst_actual_cost_details (
                                	transaction_id,
                                	organization_id,
                                	layer_id,
                                	cost_element_id,
                                	level_type,
                                	transaction_action_id,
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
                                	actual_cost,
                                	prior_cost,
                                	new_cost,
                                	insertion_flag,
                                	variance_amount,
                                	user_entered)
				SELECT  i_txn_id,
					i_org_id,
					i_layer_id,
					1,
					1,
					i_txn_action_id,
					sysdate,
					i_user_id,
					sysdate,
					i_user_id,
					i_login_id,
					i_req_id,
					i_prg_appl_id,
					i_prg_id,
					sysdate,
					i_item_id,
					0,
					0,
					0,
					'Y',
					0,
					'N'
			   	FROM 	dual;
              		END IF; /* l_count > 0 */
        	END IF; /* l_count > 0 */
		RETURN;
	END IF; /* i_exp_flag = 1 */

	/* Find the inventory layer last created */
     	l_stmt_num := 30;
	SELECT	nvl(MAX(inv_layer_id),-1)
	INTO	l_inv_layer_id
	FROM 	cst_inv_layers
	WHERE	layer_id = i_layer_id;

    	IF (l_debug = 'Y') THEN
    		FND_FILE.PUT_LINE(FND_FILE.LOG,'Last Inventory Layer : ' || l_inv_layer_id);
    	END IF;

    	/* Obtain cost table, whose costs need to be used to insert into MCLACD
       	   If cost_hook is present, use MCACD, else use costs from MCTCD, or the latest
           inventory layer with positive quantity, 0 cost otherwise */
     	IF (i_cost_hook = 1) THEN
	  	l_actual_cost_table := 'MCACD';
     	ELSE
		l_stmt_num := 35;
       		SELECT	count(*)
       		INTO 	l_count
       		FROM	mtl_cst_txn_cost_details
       		WHERE	transaction_id = i_txn_id
       		AND 	organization_id = i_org_id
       		/* AND	transaction_cost >= 0 */; -- commented for bug#3835412

       		IF (l_count > 0) THEN
	    		l_actual_cost_table := 'MCTCD';
       		ELSE
           		IF (l_inv_layer_id = -1) THEN
		     		l_actual_cost_table := 'NONE';
           		ELSE
		  		l_actual_cost_table := 'CILCD';
           		END IF;
       		END IF;
    	END IF;

    	IF (l_debug = 'Y') THEN
    		FND_FILE.PUT_LINE(FND_FILE.LOG,'Actual cost table : ' || l_actual_cost_table);
    	END IF;

	/* Insert into MCLACD */
	l_stmt_num := 40;
    	insert_mclacd(
		i_txn_id,
		i_org_id,
		i_item_id,
		i_layer_id,
		l_inv_layer_id,
		i_txn_qty,
		i_txn_action_id,
		i_user_id,
		i_login_id,
		i_req_id,
		i_prg_id,
		i_prg_appl_id,
		l_actual_cost_table,
		l_actual_cost_table,
            	l_inv_layer_id,
		'CREATE',
            	l_err_num,
             	l_err_code,
             	l_err_msg);

	IF (l_err_num <> 0) THEN
          	RAISE process_error;
    	END IF;

	/* Apply material overhead to certain transactions for asset items
           and asset subinventories */
      	l_stmt_num := 45;
      	IF ((i_exp_flag <> 1) AND
	    (i_txn_qty > 0) AND
           ((i_txn_action_id = 27 AND i_txn_src_type = 1) OR	/* PO Receipt */
            (i_txn_action_id = 1  AND i_txn_src_type = 1) OR	/* RTV */
            (i_txn_action_id = 29 AND i_txn_src_type = 1) OR	/* Delivery Adj */
            (i_txn_action_id = 31 AND i_txn_src_type = 5) OR	/* WIP completion */

            (i_txn_action_id = 6) OR /* Change of ownership */
            (i_txn_action_id = 32 AND i_txn_src_type = 5) OR	/* Assembly completion */
	    (i_interorg_rec = 1))) 				/* Interorg receipt */
	THEN
		IF (l_debug = 'Y') then
          	    	FND_FILE.PUT_LINE(FND_FILE.LOG,'Apply layer material overhead ...');
		END IF;
		l_stmt_num := 50;
            	apply_layer_material_ovhd(
  			i_org_id,
  			i_txn_id,
  			i_layer_id,
  			l_inv_layer_id,
  			i_txn_qty,
  			i_cost_type,
  			i_mat_ct_id,
  			i_avg_rates_id,
  			i_item_id,
  			i_txn_qty,
  			i_txn_action_id,
  			1,
  			i_user_id,
  			i_login_id,
  			i_req_id,
  			i_prg_appl_id,
  			i_prg_id,
                        i_interorg_rec,
  			l_err_num,
  			l_err_code,
  			l_err_msg);

              	IF (l_err_num <> 0) THEN
                   	RAISE process_error;
              	END IF;
      	END IF;

        IF (l_debug = 'Y') THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,' l_inv_layer_id ' ||l_inv_layer_id);
        END IF;
	/* Check if a layer need to be created */
  	l_merge := CSTPACHK.LayerMerge_Hook(
			i_txn_id => i_txn_id,
			o_err_num => l_err_num,
			o_err_code => l_err_code,
			o_err_msg => l_err_msg
		   );

	IF (l_merge <> 0 AND l_merge <> 1) OR (l_err_num <> 0) THEN
	   IF l_debug = 'Y' THEN
	      l_stmt_num := 15;
 	      fnd_file.put_line(
 	         fnd_file.log,
 	         'CSTPACHK.layer_hook errors out with '||
 	         'l_merge ='||l_merge||','||
 	         'l_err_num = '||l_err_num||','||
 	         'l_err_code = '||l_err_code||','||
 	         'l_err_msg = '||l_err_msg
 	      );
 	   END IF;
 	   IF l_err_num = 0 THEN
 	      l_err_num := -1;
 	   END IF;
 	   RAISE process_error;
 	END IF;

 	IF (l_merge = 1) AND (l_inv_layer_id <> -1) THEN
		/* Check that there is no negative layer other than the last inventory layer that is negative */
		l_stmt_num := 55;
		SELECT	COUNT(*)
		INTO	l_count
		FROM	cst_inv_layers cil,
			cst_quantity_layers cql
		WHERE 	cql.layer_id = i_layer_id
		AND	cil.inv_layer_id = l_inv_layer_id
		AND	cil.layer_quantity < 0
		AND	cil.layer_quantity > cql.layer_quantity;

                IF (l_debug = 'Y') THEN
       			FND_FILE.PUT_LINE(FND_FILE.LOG,'l_count '||l_count);
		END IF;

		IF (l_count = 0) THEN
			/* Check the type of the current transaction and the transaction that
		   	   created the last inventory layer */
			l_stmt_num := 60;
			SELECT  create_transaction_id
			INTO	l_last_txn_id
			FROM    cst_inv_layers
			WHERE	inv_layer_id = l_inv_layer_id;

                	IF (l_debug = 'Y') THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'l_last_txn_id '||l_last_txn_id);
			END IF;

			l_stmt_num := 65;
            BEGIN
			  SELECT  mmt.transaction_type_id,
				decode(rt2.parent_transaction_id,-1,rt2.transaction_id,rt2.parent_transaction_id)
			  INTO  l_last_txn_type_id,
				    l_last_rcv_txn_id
			  FROM	mtl_material_transactions mmt,
				rcv_transactions rt1,
				rcv_transactions rt2
			  WHERE	mmt.transaction_id = l_last_txn_id
			  AND	mmt.rcv_transaction_id = rt1.transaction_id (+)
			  AND	rt1.parent_transaction_id = rt2.transaction_id (+);

              IF (l_debug = 'Y') THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'l_last_txn_type_id '||l_last_txn_type_id);
				FND_FILE.PUT_LINE(FND_FILE.LOG,'l_last_rcv_txn_id '||l_last_rcv_txn_id);
			  END IF;
            EXCEPTION
              when no_data_found then
                l_last_txn_type_id := -1;
                l_last_rcv_txn_id := -1;
            END;

			FND_FILE.PUT_LINE(FND_FILE.LOG,'i_txn_id '||i_txn_id);
			l_stmt_num := 70;
			SELECT	mmt.transaction_type_id,
				decode(rt2.parent_transaction_id,-1,rt2.transaction_id,rt2.parent_transaction_id)
			INTO	l_txn_type_id,
				l_rcv_txn_id
			FROM	mtl_material_transactions mmt,
				rcv_transactions rt1,
				rcv_transactions rt2
			WHERE	mmt.transaction_id = i_txn_id
			AND	mmt.rcv_transaction_id = rt1.transaction_id (+)
			AND	rt1.parent_transaction_id = rt2.transaction_id (+);

                	IF (l_debug = 'Y') THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'l_txn_type_id '||l_txn_type_id);
				FND_FILE.PUT_LINE(FND_FILE.LOG,'l_rcv_txn_id '||l_rcv_txn_id);
			END IF;

			l_stmt_num := 75;
			IF (	(	(l_txn_type_id = l_last_txn_type_id)
				AND	(	(l_txn_type_id = 4)
					OR	(l_txn_type_id = 8)
					OR	(l_txn_type_id = 15)
					OR	(l_txn_type_id = 40)
					OR	(l_txn_type_id = 41)
					OR	(l_txn_type_id = 42)))
			   OR	(	(	(l_txn_type_id = 18)
					OR	(l_txn_type_id = 71))
				AND	(	(l_last_txn_type_id = 18)
					OR	(l_last_txn_type_id = 71))
				AND	(l_rcv_txn_id = l_last_rcv_txn_id))) THEN

				IF(l_txn_type_id = 18 OR l_txn_type_id = 71) THEN
					/* Check the MOH rates of the two transactions */
					l_stmt_num := 80;
					SELECT  nvl(SUM(actual_cost),0)
					INTO   	l_last_moh
					FROM   	mtl_cst_layer_act_cost_details
					WHERE   transaction_id = l_last_txn_id
					AND	organization_id = i_org_id
					AND	layer_id = i_layer_id
					AND	inv_layer_id = l_inv_layer_id
					AND	cost_element_id = 2
					AND	level_type = 1;

                			IF (l_debug = 'Y') THEN
       						FND_FILE.PUT_LINE(FND_FILE.LOG,'l_last_moh '||l_last_moh);
					END IF;
					l_stmt_num := 85;

					SELECT  nvl(SUM(actual_cost),0)
					INTO   	l_moh
					FROM   	mtl_cst_layer_act_cost_details
					WHERE   transaction_id = i_txn_id
					AND	organization_id = i_org_id
					AND	layer_id = i_layer_id
					AND	inv_layer_id = l_inv_layer_id
					AND	cost_element_id = 2
					AND	level_type = 1;

                			IF (l_debug = 'Y') THEN
       						FND_FILE.PUT_LINE(FND_FILE.LOG,'l_moh '||l_moh);
					END IF;

					IF (l_last_moh=l_moh) THEN
						l_create := 0;
					else
					    l_create := 1;
					END IF;

					if (l_create = 0) THEN
					    /* Further check the layer cost of the current transaction and last layer;
					    layer cost update could happen before the current transaction */
					    l_stmt_num := 86;


					    SELECT  nvl(SUM(layer_cost),0)
					    INTO   	l_last_layer_cost
					    FROM   	cst_inv_layers
					    WHERE   organization_id = i_org_id
					    AND	layer_id = i_layer_id
					    AND	inv_layer_id = l_inv_layer_id;




                			    IF (l_debug = 'Y') THEN
       				    		FND_FILE.PUT_LINE(FND_FILE.LOG,'l_last_layer_cost '||l_last_layer_cost);
					    END IF;
					    l_stmt_num := 87;



					    SELECT  nvl(SUM(layer_cost),0)
					    INTO   	l_layer_cost
					    FROM   	mtl_cst_layer_act_cost_details
					    WHERE   transaction_id = i_txn_id
					    AND	organization_id = i_org_id
					    AND	layer_id = i_layer_id
					    AND	inv_layer_id = l_inv_layer_id
					    AND	level_type = 1;


                			    IF (l_debug = 'Y') THEN
       				    		FND_FILE.PUT_LINE(FND_FILE.LOG,'l_layer_cost '||l_layer_cost);
					    END IF;


					    IF (l_last_layer_cost=l_layer_cost) THEN
					    	l_create := 0;
					    else
					        l_create := 1;
					    END IF;
					END IF;
				ELSE
                			IF (l_debug = 'Y') THEN
       						FND_FILE.PUT_LINE(FND_FILE.LOG,'l_actual_cost_table '||l_actual_cost_table);
					END IF;
					IF (l_actual_cost_table = 'CILCD') THEN
						l_create := 0;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

        IF (l_debug = 'Y') THEN
       		FND_FILE.PUT_LINE(FND_FILE.LOG,'l_create '||l_create);
	END IF;

	IF (l_create = 0) THEN
   		IF (l_debug = 'Y') THEN
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Adding inventory layers ...');
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inventory Layer Number : ' || to_char(l_inv_layer_id));
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inventory Layer Quantity : ' || to_char(i_txn_qty));
   		END IF;

   		/* Get transaction source ID for the transaction */
   		l_stmt_num := 86;
   		SELECT 	transaction_source_id
   		INTO	l_src_id
   		FROM	mtl_material_transactions
   		WHERE	transaction_id = i_txn_id;

   		/* Get transaction source name */
   		l_stmt_num := 89;
   		l_src_number := get_source_number(i_txn_id,i_txn_src_type,l_src_id);

		/* Update last created inventory layer */
		l_stmt_num := 90;
		UPDATE	cst_inv_layers
		SET	creation_quantity = creation_quantity + i_txn_qty,
			layer_quantity = layer_quantity	+ i_txn_qty,
			transaction_source_id = decode(transaction_source_id, l_src_id, l_src_id, null),
			transaction_source = decode(transaction_source, l_src_number, l_src_number, null),
			last_update_date = sysdate,
			last_updated_by = i_user_id,
			creation_date = sysdate,
			created_by = i_user_id,
			last_update_login = i_login_id,
			request_id = i_req_id,
			program_application_id = i_prg_appl_id,
			program_id = i_prg_id,
			program_update_date = sysdate
		WHERE	inv_layer_id = l_inv_layer_id;
	ELSE
		/* Generate Inv Layer ID */
   		l_stmt_num := 95;
		SELECT	cst_inv_layers_s.nextval
   		INTO 	l_inv_layer_id
   		FROM 	dual;

   		IF (l_debug = 'Y') THEN
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Creating inventory layers ...');
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inventory Layer Number : ' || to_char(l_inv_layer_id));
   			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inventory Layer Quantity : ' || to_char(i_txn_qty));
   		END IF;

		/* Update MCLACD entries */
		l_stmt_num := 100;
		UPDATE 	mtl_cst_layer_act_cost_details
		SET    	inv_layer_id = l_inv_layer_id
		WHERE  	transaction_id = i_txn_id
		AND  	organization_id = i_org_id
		AND	layer_id = i_layer_id;

		FND_FILE.PUT_LINE(FND_FILE.LOG, sql%rowcount || ' records updated in mclacd for ' || l_inv_layer_id);

   		/* Get transaction source ID for the transaction */
   		l_stmt_num := 105;
   		SELECT 	transaction_source_id
   		INTO	l_src_id
   		FROM	mtl_material_transactions
   		WHERE	transaction_id = i_txn_id;

   		/* Get transaction source name */
   		l_stmt_num := 110;
   		l_src_number := get_source_number(i_txn_id,i_txn_src_type,l_src_id);

   		/* Create inventory layer with 0 cost in CST_INV_LAYERS */
    		l_stmt_num := 115;
     		INSERT
		INTO	cst_inv_layers (
			layer_id,
			inv_layer_id,
			organization_id,
			inventory_item_id,
			creation_quantity,
			layer_quantity,
			layer_cost,
			create_transaction_id,
			transaction_source_id,
			transaction_action_id,
			transaction_source_type_id,
			transaction_source,
			unburdened_cost,
			burden_cost,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date)
		VALUES (i_layer_id,
			l_inv_layer_id,
			i_org_id,
			i_item_id,
			i_txn_qty,
	 		i_txn_qty,
			0,
			i_txn_id,
			l_src_id,
			i_txn_action_id,
			i_txn_src_type,
			l_src_number,
			0,
			0,
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
	        	i_prg_id,
			sysdate);

		IF (l_debug = 'Y') THEN
      			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inventory layer created');
    		END IF;

		/* Delete cost details for the inventory layer from CILCD. No rows should
           	   be present. Just a safety check */
      		l_stmt_num := 120;
      		DELETE
		FROM 	cst_inv_layer_cost_details
      		WHERE 	inv_layer_id = l_inv_layer_id;

      		/* Copy cost details by cost element and level into CILCD */
     		l_stmt_num := 125;
      		INSERT
		INTO	cst_inv_layer_cost_details (
 			layer_id,
			inv_layer_id,
			level_type,
			cost_element_id,
			layer_cost,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date)
		SELECT 	i_layer_id,
			l_inv_layer_id,
			mclacd.level_type,
			mclacd.cost_element_id,
			SUM(mclacd.actual_cost),
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate
		FROM	mtl_cst_layer_act_cost_details mclacd
		WHERE	transaction_id = i_txn_id
		AND	inv_layer_id = l_inv_layer_id
		AND	organization_id = i_org_id
		GROUP
		BY	transaction_id,
			inv_layer_id,
			cost_element_id,
			level_type;

		FND_FILE.PUT_LINE(FND_FILE.LOG, sql%rowcount || ' records copied from mclacd for ' || l_inv_layer_id);
       		/* Update layer cost in CIL */
       		l_stmt_num := 130;
       		IF (nvl(i_interorg_rec,-1) <> 3) THEN
       			UPDATE	cst_inv_layers
       			SET	layer_cost = (
					SELECT 	SUM(layer_cost)
               				FROM 	cst_inv_layer_cost_details
                			WHERE	inv_layer_id = l_inv_layer_id
                                	GROUP
					BY	inv_layer_id),
                		(unburdened_cost,burden_cost) = (
					SELECT 	SUM(decode(cost_element_id,
							   2,decode(level_type,2,layer_cost,0),
							   layer_cost)),
			   			SUM(decode(cost_element_id,
							   2,decode(level_type,1,layer_cost,0),
							   0))
                           		FROM	cst_inv_layer_cost_details
			   		WHERE	inv_layer_id = l_inv_layer_id
			   		GROUP
					BY	inv_layer_id)
       			WHERE	layer_id = i_layer_id
       			AND	inv_layer_id = l_inv_layer_id;
       		END IF;

       		IF (l_debug = 'Y') THEN
       			FND_FILE.PUT_LINE(FND_FILE.LOG,'CIL cost updated from CILCD');
       		END IF;
	END IF; /* l_create = 0 */

       	/* Create cursor to find any negative layers, order in FIFO/LIFO method */
	IF (i_txn_qty > 0) THEN
		sql_stmt := 'select inv_layer_id, layer_quantity from cst_inv_layers ' ||
		    	    'where layer_id = :i and layer_quantity < 0 order by creation_date';

       		IF (i_cost_method = 6) THEN
           		sql_stmt := sql_stmt || ' desc,inv_layer_id desc';
       		ELSE
           		sql_stmt := sql_stmt || ',inv_layer_id';
       		END IF;

	       	/* Open cursor, set total available quantity for replenishment */
       		l_stmt_num := 135;

       		OPEN negative_layer_cursor FOR sql_stmt USING i_layer_id;

	       	l_qty_available := abs(i_txn_qty);

       		IF (l_debug = 'Y') then
       	    		FND_FILE.PUT_LINE(
				FND_FILE.LOG,
				'Qty available for replenishment : ' || to_char(l_qty_available));
       		END IF;

	       	/* Loop while positive quantity is available, get the next negative layer and
        	   insert rows into MCLACD for replenishment */
       		l_stmt_num := 140;

		WHILE (l_qty_available > 0) LOOP

        	  	/* If no negative layers are found, exit While LOOP */
          		l_stmt_num := 145;
          		FETCH negative_layer_cursor into l_neg_layer_id, l_neg_layer_qty;
	  		EXIT WHEN negative_layer_cursor%NOTFOUND;

	          	/* Quantity to be replenished depends on available quantity. */
			IF ((l_qty_available+l_neg_layer_qty) > 0) THEN
             			/* Layer can be completely replenished */
                 		l_qty := abs(l_neg_layer_qty);
	          	ELSE
        	         	l_qty := l_qty_available;
          		END IF;

          		/* Insert into MCLACD for the negative layer, using actual cost from
  	           	   positive layer and layer cost from the negative layer
			   Verify Insert_mclacd( ) code for layer costs and actual costs */
     	         	l_stmt_num := 150;
             	 	insert_mclacd (
				i_txn_id,
				i_org_id,
				i_item_id,
				i_layer_id,
				l_neg_layer_id,
				l_qty,
				i_txn_action_id,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_id,
				i_prg_appl_id,
				'CILCD',
				'CILCD',
                  		l_inv_layer_id,
				'REPLENISH',
				l_err_num,
				l_err_code,
				l_err_msg);

              		IF (l_err_num <> 0) THEN
                   		raise process_error;
              		END IF;

             		/* Update quantity for the negative layer and the quantity available
                	   for replenishment */
                	IF (nvl(i_interorg_rec,-1) <> 3) THEN
				l_stmt_num := 140;
                		UPDATE	cst_inv_layers
                		SET	layer_quantity = l_neg_layer_qty + l_qty
                		WHERE	inv_layer_id = l_neg_layer_id;
                	END IF;

                	l_qty_available := l_qty_available - l_qty;
          	END LOOP;

          	CLOSE negative_layer_cursor;

          	/* For the current layer */
		IF (l_qty_available <> i_txn_qty) THEN

               		/* Obtain quantity used in replenishment */
                	l_qty := i_txn_qty - l_qty_available;

         		/* Insert into MCLACD using negative quantity for current layer */
            		l_stmt_num := 155;

       	      		insert_mclacd(
				i_txn_id,
				i_org_id,
				i_item_id,
				i_layer_id,
				l_inv_layer_id,
				-1*l_qty,
				i_txn_action_id,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_id,
				i_prg_appl_id,
				'CILCD',
				'CILCD',
                        	l_inv_layer_id,
				'UPDATE',
                        	l_err_num,
                        	l_err_code,
                        	l_err_msg);

            		IF (l_err_num <> 0) THEN
				RAISE process_error;
            		END IF;

            		/* Update layer quantity for current layer in CIL */
            		l_stmt_num := 160;
			      /*ADDED IF CONDITION FOR #BUG6722228*/
 	            IF (l_neg_layer_iD=l_inv_layer_id) THEN

 	                IF (nvl(i_interorg_rec,-1) <> 3) THEN

 	                  UPDATE cst_inv_layers
 	                  SET layer_quantity=layer_quantity-l_qty
 	                  WHERE        inv_layer_id = l_inv_layer_id;
 	               END IF;

 	            ELSE

            		IF (nvl(i_interorg_rec,-1) <> 3) THEN
                		UPDATE	cst_inv_layers
                		SET	layer_quantity = l_qty_available
                		WHERE	inv_layer_id = l_inv_layer_id;
            		END IF;
		  END IF;/* END OF #BUG6722228 */
		END IF; /* l_qty_available <> i_txn_qty */
	END IF; /* i_txn_qty > 0 */
EXCEPTION

	WHEN process_error THEN
       		o_err_num  := l_err_num;
       		o_err_code := l_err_code;
       		o_err_msg  := l_err_msg;

   	WHEN OTHERS THEN
       		ROLLBACK;
       		o_err_num  := SQLCODE;
       		o_err_msg  := 'CSTPLENG.create_layers (' ||
			      to_char(l_stmt_num) || '): ' ||
			      substr(SQLERRM,1,200);

END create_layers;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   consume_layers                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Consume inventory layer, insert into MCLACD using inventory layer  --
--     cost. If cost hook or MCTCD is present, then drive to variance     --
--   * Uses inventory layer table to insert costs and update layer qty    --
--                                                                        --
-- PURPOSE:                                                               --
--   consumption of inventory layers                                      --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_txn_qty      : primary quantity                                 --
--      i_interorg_rec : interorg shimpment (= 0),                        --
--                       interorg receipt (= 1)                           --
--                       subinv transfer with no layer change (= 3)       --
--                       otherwise (= null)                               --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
PROCEDURE consume_layers(
 			i_org_id		IN	NUMBER,
			i_txn_id		IN	NUMBER,
			i_layer_id		IN	NUMBER,
			i_item_id		IN	NUMBER,
			i_txn_qty		IN	NUMBER,
			i_cost_method		IN	NUMBER,
			i_txn_src_type		IN	NUMBER,
                  	i_txn_action_id   	IN    	NUMBER,
                  	i_cost_hook		IN	NUMBER,
                        i_interorg_rec		IN	NUMBER,
			i_cost_type		IN	NUMBER,
			i_mat_ct_id		IN	NUMBER,
			i_avg_rates_id		IN	NUMBER,
			i_exp_flag		IN	NUMBER,
			i_user_id		IN	NUMBER,
			i_login_id		IN	NUMBER,
			i_req_id		IN	NUMBER,
			i_prg_appl_id		IN	NUMBER,
			i_prg_id		IN	NUMBER,
			o_err_num		OUT NOCOPY	NUMBER,
			o_err_code		OUT NOCOPY	VARCHAR2,
			o_err_msg		OUT NOCOPY	VARCHAR2
                  ) IS
	l_inv_layer_table	cst_layer_tbl_type := cst_layer_tbl_type();
 	l_layer_hook 		NUMBER;
	l_src_id			NUMBER;
	l_txn_cost_exists		NUMBER;
	l_actual_cost_table	VARCHAR2(10);
	l_err_num			NUMBER;
	l_err_code			VARCHAR2(240);
	l_err_msg			VARCHAR2(240);
 	l_stmt_num			NUMBER;
        l_count                 NUMBER;
        l_exp_item              NUMBER;
        process_error		EXCEPTION;
        l_layers_exist          NUMBER;
        l_debug 		VARCHAR2(80);
	l_subinv		VARCHAR2(80);
	l_expsub		NUMBER;

BEGIN
	l_stmt_num := 0;
	l_err_num := 0;
 	l_err_code := '';
	l_err_msg := '';
        l_layers_exist := 0;
	l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

        l_stmt_num := 5;
        if (l_debug = 'Y') then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Consuming inventory layers from CG layer : ' || to_char(i_layer_id));
        end if;
        select count(*)
        into l_layers_exist
        from cst_inv_layers
        where layer_id = i_layer_id;

        if (l_layers_exist = 0) then
	    if (l_debug = 'Y') then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Creating negative layer ...');
            end if;

/* Bug 2325297
   Create Layers is called with i_interorg_rec parameter as NULL
   This is due to the fact that layers have to be created if layers
   do not exist in the LIFO/FIFO Organization.
   But if the the transaction is a sending transaction, then we
   do not earn material overhead (which is also taken care of in create_layers()
   The value NULL for i_interorg_rec ensures that layers are created
   in the sending organization but it does not earn MOH
*/
             create_layers(i_org_id,
			i_txn_id,
			i_layer_id,
			i_item_id,
			i_txn_qty,
                        i_cost_method,
                        i_txn_src_type,
                        i_txn_action_id,
                        i_cost_hook,
                        NULL, -- i_interorg_rec: Create Layers always if it a sending txn
                        i_cost_type,
                        i_mat_ct_id,
                        i_avg_rates_id,
                        i_exp_flag,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg);
                  return;
                 end if;

  /* If expense item, then insert into MCACD using current costs. No inventory
     layer consumed or created */
  l_stmt_num := 6;
  select decode(inventory_asset_flag,'Y',0,1)
  into l_exp_item
  from mtl_system_items
  where inventory_item_id = i_item_id
  and organization_id = i_org_id;

  l_stmt_num := 7;
  if (l_exp_item = 1) then
      if (l_debug = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into MCACD for expense item...');
      end if;
      select count(*) into l_count
      from cst_layer_cost_details
      where layer_id = i_layer_id;

      if (l_count > 0) then
           insert into mtl_cst_actual_cost_details (
				transaction_id,
				organization_id,
				layer_id,
				cost_element_id,
				level_type,
				transaction_action_id,
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
                                actual_cost,
                                prior_cost,
                                new_cost,
                                insertion_flag,
                                variance_amount,
                                user_entered)
		  select  i_txn_id,
			i_org_id,
			i_layer_id,
			clcd.cost_element_id,
			clcd.level_type,
			i_txn_action_id,
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate,
			i_item_id,
			clcd.item_cost,
			clcd.item_cost,
			clcd.item_cost,
			'N',
			0,
			'N'
		from cst_layer_cost_details clcd
		where layer_id = i_layer_id;
          else
                insert into mtl_cst_actual_cost_details (
                                transaction_id,
                                organization_id,
                                layer_id,
                                cost_element_id,
                                level_type,
                                transaction_action_id,
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
                                actual_cost,
                                prior_cost,
                                new_cost,
                                insertion_flag,
                                variance_amount,
                                user_entered)
			select  i_txn_id,
				i_org_id,
				i_layer_id,
				1,
				1,
				i_txn_action_id,
				sysdate,
				i_user_id,
				sysdate,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				sysdate,
				i_item_id,
				0,
				0,
				0,
				'Y',
				0,
				'N'
			   from dual;
              end if;
	     return;
     end if;

      l_stmt_num := 10;
      l_layer_hook := CSTPACHK.layer_hook(
				       	 i_org_id,
  						i_txn_id,
  						i_layer_id,
  						i_cost_method,
						i_user_id,
						i_login_id,
						i_req_id,
						i_prg_appl_id,
						i_prg_id,
						l_err_num,
						l_err_code,
						l_err_msg);
      IF l_err_num <> 0 THEN
	 IF l_debug = 'Y' THEN
 	    l_stmt_num := 15;
 	    fnd_file.put_line(
 	       fnd_file.log,
 	       'CSTPACHK.layer_hook errors out with '||
 	       'l_err_num = '||l_err_num||','||
 	       'l_err_code = '||l_err_code||','||
 	       'l_err_msg = '||l_err_msg
 	    );
 	 END IF;
 	 RAISE process_error;
      END IF;
	l_stmt_num := 20;
	if ((l_layer_hook > 0) OR ((i_txn_action_id = 1) and (i_txn_src_type = 1))
                OR ((i_txn_action_id = 29) and (i_txn_qty < 0))
		OR ((i_txn_action_id = 32) and (i_txn_src_type = 5))) then

			l_expsub := 0;

			select transaction_source_id
			into l_src_id
			from mtl_material_transactions
			where transaction_id = i_txn_id;


			select subinventory_code
                        into l_subinv
                        from mtl_material_transactions
                        where transaction_id = i_txn_id;

                        select decode(asset_inventory, 1, 0, 1)
                        into l_expsub
                        from mtl_secondary_inventories
                        where organization_id = i_org_id
                        and secondary_inventory_name = l_subinv;

            if (l_debug = 'Y') then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Layer specific consumption...');
	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Layer hook : ' || to_char(l_layer_hook));
 	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Source ID : ' || to_char(l_src_id));
            end if;
	    if (l_expsub = 1) then
	    	IF (l_debug = 'Y') THEN
       			FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into MCACD for the Item Coming from Exp Sub Inv ...');
     		END IF;

		l_stmt_num := 21;
      		SELECT 	COUNT(*)
		INTO	l_count
      		FROM 	mtl_cst_txn_cost_details
      		WHERE 	transaction_id = i_txn_id
      		AND 	organization_id = i_org_id;

      		IF (l_count > 0) THEN
			l_stmt_num := 22;
          		INSERT
			INTO 	mtl_cst_actual_cost_details (
				transaction_id,
				organization_id,
				layer_id,
				cost_element_id,
				level_type,
				transaction_action_id,
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
				actual_cost,
				prior_cost,
				new_cost,
				insertion_flag,
				variance_amount,
				user_entered)
			SELECT 	i_txn_id,
				i_org_id,
				i_layer_id,
				ctcd.cost_element_id,
				ctcd.level_type,
				i_txn_action_id,
				sysdate,
				i_user_id,
				sysdate,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				sysdate,
				ctcd.inventory_item_id,
				ctcd.transaction_cost,
				0,
				0,
				'Y',
				0,
				'N'
			FROM 	mtl_cst_txn_cost_details ctcd
			WHERE	ctcd.transaction_id = i_txn_id
			AND	ctcd.organization_id = i_org_id	;

 		else
		       l_stmt_num := 23;
			INSERT
			INTO	mtl_cst_actual_cost_details (
                                	transaction_id,
                                	organization_id,
                                	layer_id,
                                	cost_element_id,
                                	level_type,
                                	transaction_action_id,
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
                                	actual_cost,
                                	prior_cost,
                                	new_cost,
                                	insertion_flag,
                                	variance_amount,
                                	user_entered)
				SELECT  i_txn_id,
					i_org_id,
					i_layer_id,
					1,
					1,
					i_txn_action_id,
					sysdate,
					i_user_id,
					sysdate,
					i_user_id,
					i_login_id,
					i_req_id,
					i_prg_appl_id,
					i_prg_id,
					sysdate,
					i_item_id,
					0,
					0,
					0,
					'Y',
					0,
					'N'
			   	FROM 	dual;
	            end if; /* l_count > 0 */
	       return;
	    else
              get_layers_consumed(
                i_txn_qty => i_txn_qty,
                i_cost_method => i_cost_method,
                i_layer_id => i_layer_id,
                consume_mode => 'SPECIFIC',
                i_layer_hook => l_layer_hook,
                i_src_id => l_src_id,
                i_txn_id => i_txn_id,
                l_inv_layer_table => l_inv_layer_table,
                o_err_num => l_err_num,
                o_err_code => l_err_code,
                o_err_msg => l_err_msg
              );
           end if; /* l_expsub =1 */
       else
	 l_expsub := 0;

	 if (i_txn_action_id in (1, 27, 33, 34)) then
	   l_stmt_num := 25;
	   select subinventory_code
	   into l_subinv
	   from mtl_material_transactions
	   where transaction_id = i_txn_id;

	   select decode(asset_inventory, 1, 0, 1)
	   into l_expsub
	   from mtl_secondary_inventories
	   where organization_id = i_org_id
	     and secondary_inventory_name = l_subinv;
	 end if;

	 if (l_expsub = 1) then
	   /* For WIP issue/return transactions: cost needed for consumption from
	      expense subinv for asset item should come from only the next layer that
	      would be consumed if it were from asset subinv */
	   l_stmt_num := 27;
           if (l_debug = 'Y') then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Consumption from exp subinv');
           end if;

	   get_layers_consumed(
	     i_txn_id => i_txn_id,
             i_txn_qty => i_txn_qty,
             i_cost_method => i_cost_method,
             i_layer_id => i_layer_id,
             consume_mode => 'EXPSUB',
             l_inv_layer_table => l_inv_layer_table,
             o_err_num => l_err_num,
             o_err_code => l_err_code,
             o_err_msg => l_err_msg
           );
	 else
	   l_stmt_num := 30;
           if (l_debug = 'Y') then
               fnd_file.put_line(fnd_file.log, 'Regular consumption ');
           end if;

	   get_layers_consumed(
	     i_txn_id => i_txn_id,
             i_txn_qty => i_txn_qty,
             i_cost_method => i_cost_method,
             i_layer_id => i_layer_id,
             consume_mode => 'NORMAL',
             l_inv_layer_table => l_inv_layer_table,
             o_err_num => l_err_num,
             o_err_code => l_err_code,
             o_err_msg => l_err_msg
           );
	 end if; /* l_expsub = 1 */
       end if;
       if (l_err_num <> 0) then
          raise process_error;
       end if;

	l_stmt_num := 40;
       if (i_cost_hook = 1) then
		l_actual_cost_table := 'MCACD';
      else
		select count(*)
 		into l_txn_cost_exists
		from mtl_cst_txn_cost_details
		where transaction_id = i_txn_id
		and organization_id = i_org_id;

		if (l_txn_cost_exists > 0) then
			l_actual_cost_table := 'MCTCD';
		else
			l_actual_cost_table := 'CILCD';
		end if;
	 end if;

      IF l_inv_layer_table.COUNT >0 THEN
	 For i IN l_inv_layer_table.FIRST..l_inv_layer_table.LAST
	  LOOP
		l_stmt_num := 50;
		insert_mclacd(i_txn_id,
				i_org_id,
				i_item_id,
				i_layer_id,
				l_inv_layer_table(i).inv_layer_id,
				-1*l_inv_layer_table(i).layer_quantity,
				i_txn_action_id,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_id,
				i_prg_appl_id,
				l_actual_cost_table,
				'CILCD',
				l_inv_layer_table(i).inv_layer_id,
				'CONSUME',
				l_err_num,
				l_err_code,
				l_err_msg);

/* If layer is driven negative, then apply_layer_material_ovhd should not be called again, insert_mclacd return value of 999 in such a case */
         if (l_err_num <> 0) then
		if (l_err_num = 999) then
               		l_err_num := 0;
		else
			raise process_error;
		end if;
         else

		if ((i_exp_flag <> 1)
         		AND
           		((i_txn_action_id = 27 and i_txn_src_type = 1)    /*  PO Receipt  */
            	OR
            	(i_txn_action_id = 1 and i_txn_src_type = 1)     /*     RTV      */
            	OR
            	(i_txn_action_id = 29 and i_txn_src_type = 1)    /* Delivery Adj */
            	OR
            	(i_txn_action_id = 31 and i_txn_src_type = 5)    /*WIP completion*/
                OR
                (i_txn_action_id = 6) /* Change of ownership */

            	OR
	  		(i_txn_action_id = 32 and i_txn_src_type = 5)    /* Assembly completion*/
			OR
            	(i_interorg_rec = 1)					 /*Interorg receipt*/
           		)
          	   ) then
			l_stmt_num :=60;
                if (l_debug = 'Y') then
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling apply_layer_material_ovhd...');
                end if;
              	apply_layer_material_ovhd(
  						i_org_id,
  						i_txn_id,
  						i_layer_id,
  						l_inv_layer_table(i).inv_layer_id,
  						l_inv_layer_table(i).layer_quantity,
  						i_cost_type,
  						i_mat_ct_id,
  						i_avg_rates_id,
  						i_item_id,
  						i_txn_qty,
  						i_txn_action_id,
  						1,
  						i_user_id,
  						i_login_id,
  						i_req_id,
  						i_prg_appl_id,
  						i_prg_id,
                                                i_interorg_rec, --bug 2280515
  						l_err_num,
  						l_err_code,
  						l_err_msg
						);

              	if (l_err_num <> 0) then
                   	raise process_error;
              	end if;
         end if;
    end if;  /* l_err_num = 999 */
		l_stmt_num := 70;
		if ((nvl(i_interorg_rec,-1) <> 3) and (i_exp_flag <> 1)) then
			update cst_inv_layers
			set layer_quantity = nvl(layer_quantity,0)-l_inv_layer_table(i).layer_quantity
			where inv_layer_id = l_inv_layer_table(i).inv_layer_id;
                    if (l_debug = 'Y') then
			FND_FILE.PUT_LINE(FND_FILE.LOG,'CIL.layer_qty changed by ' || to_char(l_inv_layer_table(i).layer_quantity));
                    end if;
		end if;
  	END LOOP;
      END IF; /* IF l_inv_layer_table.COUNT >0 THEN */
EXCEPTION
   when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
   when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.consume_layers (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);

END consume_layers;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_layers_consumed                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure decides which inventory layers need to be consumed    --
--   for the specified issue transaction. The output of this procedure is --
--   a table of inventory layer ids and the quantity that should be       --
--   consumed from each layer.                                            --
--                                                                        --
-- PARAMETERS:                                                            --
--   i_txn_qty         : quantity that needs to be consumed in primary    --
--                       UOM                                              --
--   i_cost_method     : cost method of the organization (5 for FIFO, 6   --
--                       for LIFO)                                        --
--   i_layer_id        : cost group layer id                              --
--   consume_mode      : consumption mode (EXPSUB for Issues of asset     --
--                       items from expense subinventories, SPECIFIC for  --
--                       layer_hook, return to receiving, correction,     --
--                       assembly return, NORMAL for all others)          --
--   i_layer_hook      : specific custom layer that should be consumed    --
--   i_src_id          : source id (PO Receipt for return to receiving,   --
--                       corrections, Job for assembly return, NULL for   --
--                       all others)                                      --
--   i_txn_id          : issue transaction id                             --
--   l_inv_layer_table : inventory layers that should be consumed         --
----------------------------------------------------------------------------
PROCEDURE get_layers_consumed (
  i_txn_qty         IN            NUMBER,
  i_cost_method     IN            NUMBER,
  i_layer_id        IN            NUMBER,
  consume_mode      IN            VARCHAR2,
  i_layer_hook      IN            NUMBER,
  i_src_id          IN            NUMBER,
  i_txn_id          IN            NUMBER,
  l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
  o_err_num         OUT NOCOPY    NUMBER,
  o_err_code        OUT NOCOPY    VARCHAR2,
  o_err_msg         OUT NOCOPY    VARCHAR2
)
IS
  l_stmt_num		NUMBER;
  l_debug           	VARCHAR2(80);
  l_required_qty    	NUMBER;
  l_custom_layer    	NUMBER;
  l_source_id       	NUMBER;
  l_inv_layer_id    	NUMBER;
  l_pos_layer_exist 	NUMBER;
  l_layers_hook   	NUMBER;
  l_rtr            	NUMBER;
  l_rtr_txn_id      	NUMBER;
  l_custom_layers  	CSTPACHK.inv_layer_tbl;
  l_layers_list     	VARCHAR2(2000);
  sql_stmt          	VARCHAR2(2000);
  l_inv_layer_rec   	cst_layer_rec_type;
  inv_layer_cursor  	LayerCurType;
  l_err_num         	NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  process_error	EXCEPTION;
BEGIN
  l_stmt_num := 0;
  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
  l_debug := 'Y';
  l_required_qty := ABS(i_txn_qty);
  l_custom_layer := NVL(i_layer_hook,-1);
  l_source_id := NVL(i_src_id,-1);
  l_rtr_txn_id := 0;
  l_custom_layers := CSTPACHK.inv_layer_tbl();
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  IF l_debug = 'Y' THEN
     fnd_file.put_line(
        fnd_file.log,
 	'Entering get_layers_consumed for transaction '||i_txn_id||
 	' and a required quantity of '||l_required_qty||
 	' with a consumption mode of '||consume_mode
     );
  END IF;
  l_stmt_num := 5;

  /* For issues of asset items from expense subinventories, we don't consume any layers
  Instead, we just need to get a reference cost from the earliest / latest layer */

  IF consume_mode = 'EXPSUB' THEN
     IF l_debug = 'Y' THEN
 	fnd_file.put_line(fnd_file.log,'EXPSUB consumption');
     END IF;
     IF i_cost_method = 5 THEN
        l_stmt_num := 10;
        SELECT MIN(inv_layer_id)
        INTO   l_inv_layer_id
        FROM   cst_inv_layers
        WHERE  layer_id = i_layer_id
        AND    layer_quantity > 0;
     ELSE
 	l_stmt_num := 15;
 	SELECT MAX(inv_layer_id)
 	INTO   l_inv_layer_id
 	FROM   cst_inv_layers
 	WHERE  layer_id = i_layer_id
 	AND    layer_quantity > 0;
     END IF;
     /* If no positive layers exist, pick the latest layer */
     IF l_inv_layer_id IS NULL THEN
      l_stmt_num := 20;
      SELECT MAX(inv_layer_id)
      INTO   l_inv_layer_id
      FROM   cst_inv_layers
      WHERE  layer_id = i_layer_id;
     END IF;
     l_inv_layer_rec.inv_layer_id := l_inv_layer_id;
     l_inv_layer_rec.layer_quantity := l_required_qty;
     l_stmt_num := 25;
     insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
     l_required_qty := 0;
     RETURN;
  END IF;

  /* For issues from asset subinventories, consume the layers in the following order
   1. Positive quantity in the layer specified by the layer hook
   2. Drive the layer specified by the layer hook negative only if there are no
      other positive layers
   3. Positive quantity from the layers specified by the layers hook in the order
      that they are specified
   4. Positive quantity from the layer that was created for the delivery that this
      return / correction correspond to
   5. Positive quantity from the layers that was created for the deliveries for
      the same PO or completions from the same job in FIFO/LIFO manner
   6. Drive the earliest / latest layer that was created for the deliveries for the
      same PO or completions from the same job negative only if there are
      no other positive layers
   7. Positive quantity from all layers in FIFO/LIFO manner
   8. Drive the overall earliest / latest layer negative

   1 and 2 are applicable only when layer hook is used.
   3 is applicable only when layers hook is used.
   4 is applicable only for returns to receiving / corrections.
   5 and 6 are applicable only for returns to receiving, corrections and assembly
   returns. */

   /* 1. Positive quantity in the layer specified by the layer hook */
   IF (l_custom_layer > 0) AND (l_required_qty > 0) THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Trying custom layer '||l_custom_layer);
      END IF;
      l_stmt_num := 30;
      SELECT inv_layer_id, layer_quantity
      INTO   l_inv_layer_rec.inv_layer_id,l_inv_layer_rec.layer_quantity
      FROM   cst_inv_layers
      WHERE  inv_layer_id = l_custom_layer -- inventory layer id exists
      AND    layer_id = i_layer_id;        -- correct organization, item, cost group
      IF l_inv_layer_rec.layer_quantity > 0 THEN
         IF l_required_qty < l_inv_layer_rec.layer_quantity THEN
 	    l_inv_layer_rec.layer_quantity := l_required_qty;
 	 END IF;
 	 IF l_debug = 'Y' THEN
 	    fnd_file.put_line(
 	       fnd_file.log,
 	       'Using custom layer '||l_custom_layer||' for '||l_inv_layer_rec.layer_quantity
 	    );
 	 END IF;
 	 l_required_qty := l_required_qty - l_inv_layer_rec.layer_quantity;
 	 l_stmt_num := 35;
 	 insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
      END IF;
   END IF;
   /* End of 1 */

   /* 2. Drive the layer specified by the layer hook negative only if there are no
   other positive layers */
   IF (l_custom_layer > 0) AND (l_required_qty > 0) THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Driving custom layer '||l_custom_layer||' negative?');
      END IF;
      l_stmt_num := 40;
      SELECT count(*)
      INTO   l_pos_layer_exist
      FROM   cst_inv_layers
      WHERE  layer_id = i_layer_id
      AND    inv_layer_id <> l_custom_layer
      AND    layer_quantity > 0;
      IF l_pos_layer_exist = 0 THEN
         IF l_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'Driving custom layer '||l_custom_layer||' negative');
 	 END IF;
 	 l_inv_layer_rec.inv_layer_id := l_custom_layer;
 	 l_inv_layer_rec.layer_quantity := l_required_qty;
 	 l_required_qty := 0;
 	 l_stmt_num := 45;
         insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
      END IF;
   END IF;
   /* End of 2 */

   /* 3. Positive quantity from the layers specified in the layers hook in the order that they are specified */
   IF l_required_qty > 0 THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Trying custom layers');
      END IF;
      l_stmt_num := 50;
      CSTPACHK.layers_hook (
         i_txn_id => i_txn_id,
 	 i_required_qty => l_required_qty,
 	 i_cost_method => i_cost_method,
 	 o_custom_layers => l_custom_layers,
 	 o_err_num => l_err_num,
 	 o_err_code => l_err_code,
 	 o_err_msg => l_err_msg
      );
      IF l_err_num <> 0 THEN
         fnd_file.put_line(fnd_file.log,'Error in calling CSTPACHK.layers_hook');
 	 RAISE process_error;
      END IF;
      l_layers_hook := 0;
      l_layers_list := '(-1';
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'There are '||l_custom_layers.COUNT||' custom layers');
      END IF;
      IF l_custom_layers.COUNT > 0 THEN
         FOR i IN l_custom_layers.FIRST..l_custom_layers.LAST LOOP
 	 EXIT WHEN l_required_qty = 0;
 	 IF l_debug = 'Y' THEN
 	    fnd_file.put_line(
 	       fnd_file.log,
 	       'Trying to consume '||l_custom_layers(i).layer_quantity||
 	       ' from custom layer '||l_custom_layers(i).inv_layer_id
 	    );
 	 END IF;
         l_stmt_num := 55;
            BEGIN
               SELECT inv_layer_id, l_custom_layers(i).layer_quantity
               INTO   l_inv_layer_rec.inv_layer_id, l_inv_layer_rec.layer_quantity
               FROM   cst_inv_layers
 	       WHERE  inv_layer_id = l_custom_layers(i).inv_layer_id -- valid inventory layer id
 	       AND    layer_id = i_layer_id                          -- valid org, item, cost group
 	       AND    layer_quantity >=
 	              l_custom_layers(i).layer_quantity              -- enough quantity
 	       AND    l_custom_layers(i).layer_quantity > 0;         -- positive quanttiy
 	    EXCEPTION
 	       WHEN NO_DATA_FOUND THEN
 	          l_err_num := -1;
 	          l_err_msg := 'Custom layer '||l_custom_layers(i).inv_layer_id||
 	                       ' and quantity '||l_custom_layers(i).layer_quantity||
 	                       ' is not valid';
 	          fnd_file.put_line(
 	             fnd_file.log, l_err_msg
 	          );
 	          RAISE process_error;
 	    END;
 	    -- ignore the layer if it has been specified by the layer hook to avoid double counting.
 	    IF l_inv_layer_rec.inv_layer_id <> l_custom_layer THEN
 	       IF l_inv_layer_rec.layer_quantity > l_required_qty THEN
 	          l_inv_layer_rec.layer_quantity := l_required_qty;
 	       END IF;
 	       l_required_qty := l_required_qty - l_inv_layer_rec.layer_quantity;
 	       l_stmt_num := 60;
 	       IF l_debug = 'Y' THEN
 	          fnd_file.put_line(
 	             fnd_file.log,
 	             'Using custom layer '||l_custom_layers(i).inv_layer_id||
 	             ' for '||l_inv_layer_rec.layer_quantity
 	           );
 	       END IF;
               insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
               l_layers_hook := 1;
               l_layers_list := l_layers_list || ',' || l_inv_layer_rec.inv_layer_id;
            END IF;
         END LOOP;
      END IF;
      l_layers_list := l_layers_list || ')';
   END IF;
   /* End of 3 */

   /* 4. Positive quantity from the layer that was created for the delivery that this
   return / correction corresponds to */
   IF (consume_mode = 'SPECIFIC') AND (i_src_id IS NOT NULL) AND (l_required_qty > 0) then
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Trying original delivery');
      END IF;
      -- check if the current transaction is a return to receiving or correction
      l_stmt_num := 65;
         SELECT COUNT(*)
         INTO   l_rtr
         FROM   mtl_material_transactions
         WHERE  transaction_id = i_txn_id
         AND    transaction_action_id in (1, 29)
         AND    transaction_source_type_id = 1;
         -- if it is, try to first consume the inv layer created by the receipt
         -- that this return is performed against
         IF l_rtr = 1 THEN
            l_stmt_num := 70;
            BEGIN
               SELECT mmt_del.transaction_id
               INTO   l_rtr_txn_id
               FROM   mtl_material_transactions mmt_del,
                      mtl_material_transactions mmt_rtr,
                      rcv_transactions rt_rtr
               WHERE  mmt_del.rcv_transaction_id = rt_rtr.parent_transaction_id
               AND    rt_rtr.transaction_id = mmt_rtr.rcv_transaction_id
               AND    mmt_rtr.transaction_id = i_txn_id;
            EXCEPTION
              WHEN OTHERS THEN
                 IF (l_debug = 'Y') THEN
                    FND_FILE.PUT_LINE(
                       FND_FILE.LOG,
                       'No delivery is found for transaction ' || i_txn_id
                    );
		 END IF;
            END;
            l_stmt_num := 75;
            sql_stmt := 'SELECT inv_layer_id, layer_quantity'
                      ||' FROM   cst_inv_layers'
                      ||' WHERE  create_transaction_id = :i'
                      ||' AND    layer_quantity > 0'
                      ||' AND    inv_layer_id <> :j';
            IF l_layers_hook > 0 THEN
 	       l_stmt_num := 80;
 	       sql_stmt := sql_stmt || ' AND inv_layer_id NOT IN '|| l_layers_list;
 	    END IF;
            IF l_debug = 'Y' THEN
 	       fnd_file.put_line(
 	          fnd_file.log,
 	          'Using SQL '||sql_stmt||' with '||l_rtr_txn_id||','||l_custom_layer
 	       );
 	    END IF;
 	    OPEN inv_layer_cursor FOR sql_stmt USING l_rtr_txn_id, l_custom_layer;
 	    l_stmt_num := 85;
               populate_layer_table(
                  l_inv_layer_table => l_inv_layer_table,
                  inv_layer_cursor => inv_layer_cursor,
                  i_qty_required => l_required_qty,
                  o_err_num => l_err_num,
                  o_err_code => l_err_code,
                  o_err_msg => l_err_msg
               );
            CLOSE inv_layer_cursor;
         END IF; -- l_rtr = 1
   END IF;
   /* End of 4 */

  /* 5. Positive quantity from the layers that was created for the deliveries for
  the same PO or completions from the same job in FIFO/LIFO manner */
  IF (consume_mode = 'SPECIFIC') AND (i_src_id IS NOT NULL) AND (l_required_qty > 0) THEN
     IF l_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Trying other layers with the same source');
     END IF;
     l_stmt_num := 90;
      sql_stmt := 'SELECT inv_layer_id,layer_quantity FROM cst_inv_layers'
                ||' WHERE layer_id = :i AND transaction_source_id = :j AND layer_quantity > 0 '
                ||' AND create_transaction_id <> :k AND inv_layer_id <> :l';
      IF l_layers_hook > 0 THEN
         l_stmt_num := 95;
            sql_stmt := sql_stmt || ' AND inv_layer_id NOT IN ' || l_layers_list;
      END IF;
      IF i_cost_method = 6 THEN
         l_stmt_num := 100;
         sql_stmt := sql_stmt || ' ORDER BY creation_date DESC, inv_layer_id DESC';
      ELSE
         l_stmt_num := 105;
         sql_stmt := sql_stmt || ' ORDER BY creation_date, inv_layer_id';
      END IF;
      IF l_debug = 'Y' THEN
         fnd_file.put_line(
            fnd_file.log,
 	    'Using SQL '||sql_stmt||' with '||i_layer_id||','||l_source_id||
 	    ','||l_rtr_txn_id||','||l_custom_layer
 	 );
      END IF;
      OPEN inv_layer_cursor FOR sql_stmt USING i_layer_id,l_source_id,l_rtr_txn_id,l_custom_layer;
          l_stmt_num := 110;
             populate_layer_table(
                l_inv_layer_table => l_inv_layer_table,
                inv_layer_cursor => inv_layer_cursor,
                i_qty_required => l_required_qty,
                o_err_num => l_err_num,
                o_err_code => l_err_code,
                o_err_msg => l_err_msg
             );
      CLOSE inv_layer_cursor;
   END IF;
   /* End of 5 */

   /* 6. Drive the earliest / latest layer that was created for the deliveries for the
   same PO or completions from the same job negative only if there are
   no other positive layers */
   IF (consume_mode = 'SPECIFIC') AND (i_src_id IS NOT NULL) AND (l_required_qty > 0) THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(
 	    fnd_file.log,
 	    'Driving earliest/latest layer with the same source negative?'
 	 );
      END IF;
      l_stmt_num := 115;
      sql_stmt := 'SELECT inv_layer_id, layer_quantity FROM cst_inv_layers'
                ||' WHERE  layer_id = :i AND inv_layer_id <> :j'
                ||' AND NVL(transaction_source_id,-2) <> :k'
                ||' AND layer_quantity > 0';
      IF l_layers_hook > 0 THEN
         l_stmt_num := 120;
         sql_stmt := sql_stmt || ' AND inv_layer_id NOT IN ' || l_layers_list;
      END IF;
      IF l_debug = 'Y' THEN
         fnd_file.put_line(
            fnd_file.log,
            'Using SQL '||sql_stmt||' with '||i_layer_id||','||l_custom_layer||
            ','||l_source_id
         );
      END IF;
      OPEN inv_layer_cursor FOR sql_stmt USING i_layer_id,l_custom_layer,l_source_id;
      FETCH inv_layer_cursor INTO l_inv_layer_rec.inv_layer_id, l_inv_layer_rec.layer_quantity;
         IF inv_layer_cursor%NOTFOUND THEN
 	    IF i_cost_method = 5 THEN
 	       l_stmt_num := 125;
 	         SELECT MAX(inv_layer_id)
 	         INTO   l_inv_layer_rec.inv_layer_id
 	         FROM   cst_inv_layers
 	         WHERE  layer_id = i_layer_id
 	         AND    transaction_source_id = l_source_id;
 	    ELSE
 	       l_stmt_num := 130;
 	         SELECT MIN(inv_layer_id)
 	         INTO   l_inv_layer_rec.inv_layer_id
 	         FROM   cst_inv_layers
 	         WHERE  layer_id = i_layer_id
 	         AND    transaction_source_id = l_source_id;
 	    END IF;
            IF l_inv_layer_rec.inv_layer_id IS NOT NULL THEN
               IF l_debug = 'Y' THEN
 	          fnd_file.put_line(
 	             fnd_file.log,
 	             'Driving earliest/latest layer with the same source negative'
 	          );
 	       END IF;
 	       l_inv_layer_rec.layer_quantity := l_required_qty;
 	       l_stmt_num := 135;
 	          insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
 	          l_required_qty := 0;
 	    END IF;
 	 END IF;
      CLOSE inv_layer_cursor;
   END IF;
   /* End of 6 */

   /* 7. Positive quantity from all layers in FIFO/LIFO manner */
   IF l_required_qty > 0 THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'General consumption');
      END IF;
      l_stmt_num := 140;
      sql_stmt := 'SELECT inv_layer_id,layer_quantity FROM cst_inv_layers WHERE layer_id = :i'
 	        ||' AND inv_layer_id <> :j AND NVL(transaction_source_id,-2) <> :k'
 	        ||' AND layer_quantity > 0';
      l_stmt_num := 145;
      IF l_layers_hook > 0 THEN
         sql_stmt := sql_stmt || ' AND inv_layer_id NOT IN '|| l_layers_list;
      END IF;
      IF i_cost_method = 6 THEN
         l_stmt_num := 150;
         sql_stmt := sql_stmt || ' ORDER BY creation_date DESC, inv_layer_id DESC';
      ELSE
         l_stmt_num := 155;
         sql_stmt := sql_stmt || ' ORDER BY creation_date, inv_layer_id';
      END IF;
      IF l_debug = 'Y' THEN
         fnd_file.put_line(
            fnd_file.log,
            'Using SQL '||sql_stmt||' with '||i_layer_id||','||l_custom_layer||
            ','||l_source_id
         );
      END IF;
      OPEN inv_layer_cursor FOR sql_stmt USING i_layer_id,l_custom_layer,l_source_id;
         l_stmt_num := 160;
         populate_layer_table(
            l_inv_layer_table => l_inv_layer_table,
            inv_layer_cursor => inv_layer_cursor,
            i_qty_required => l_required_qty,
            o_err_num => l_err_num,
            o_err_code => l_err_code,
            o_err_msg => l_err_msg
         );
      CLOSE inv_layer_cursor;
   END IF;
   /* End of 7 */

   /* 8. Drive the overall earliest / latest layer negative */
   IF l_required_qty > 0 THEN
      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Driving earliest/latest layer negative');
      END IF;
      IF l_debug = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'l_neg_qty ' || to_char(l_required_qty));
      END IF;
      l_stmt_num := 165;
         sql_stmt := 'SELECT inv_layer_id,layer_quantity FROM cst_inv_layers WHERE layer_id = :i';
         IF i_cost_method = 5 THEN
            sql_stmt := sql_stmt || ' ORDER BY creation_date DESC,inv_layer_id DESC';
         ELSE
 	    sql_stmt := sql_stmt || ' ORDER BY creation_date,inv_layer_id';
 	 END IF;
         IF l_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'Using SQL '||sql_stmt||' with '||i_layer_id);
         END IF;
         OPEN inv_layer_cursor FOR sql_stmt USING i_layer_id;
            FETCH inv_layer_cursor into l_inv_layer_rec.inv_layer_id,l_inv_layer_rec.layer_quantity;
            l_inv_layer_rec.layer_quantity := l_required_qty;
            l_stmt_num := 170;
            insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);
         CLOSE inv_layer_cursor;
   END IF;
   /* End of 8 */

EXCEPTION
    when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
   when others then
       rollback;
       FND_FILE.PUT_LINE(FND_FILE.LOG,SQLCODE ||' ' ||to_char(l_stmt_num)||' '||substr(SQLERRM,1,200));
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.get_layers_consumed (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
END get_layers_consumed;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   populate_layer_table                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   * This procedure loops through the records fetched by the layer      --
--     cursor (IN parameter), and populates the PL/SQL table with the     --
--     inventory layer ID and the quantity that needs to be consumed      --
--     from that layer                                                    --
--   * If no layers are fetched, the procedure issues a return            --
--                                                                        --
-- PURPOSE:                                                               --
--   a single function to loop through records fetched by the inventory   --
--   layer cursor and populate the PL/SQL table with the inv layer ID     --
--   and the quantity to be consuemd from that layer                      --
--                                                                        --
-- PARAMETERS:                                                            --
--     l_inv_layer_table  :  PL/SQL parameter that is populated           --
--     inv_layer_cursor   : cursor that is used to fetch inventory layers --
--     i_qty_required     : total quantity left to be consumed            --
----------------------------------------------------------------------------
PROCEDURE populate_layer_table(l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
					 inv_layer_cursor IN LayerCurType,
					 i_qty_required IN OUT NOCOPY NUMBER,
					 o_err_num	OUT NOCOPY NUMBER,
					 o_err_code OUT NOCOPY VARCHAR2,
					 o_err_msg  OUT NOCOPY VARCHAR2)
IS
	l_inv_layer_rec	cst_layer_rec_type;
	l_stmt_num NUMBER;
	l_err_num NUMBER;
	l_err_code VARCHAR2(240);
	l_err_msg VARCHAR2(240);
        process_error EXCEPTION;
BEGIN
        l_stmt_num := 0;
	l_err_num := 0;
	l_err_code := '';
	l_err_msg := '';

	while (i_qty_required > 0) LOOP
		l_stmt_num := 20;
		FETCH inv_layer_cursor into l_inv_layer_rec.inv_layer_id,
						    l_inv_layer_rec.layer_quantity;
		EXIT WHEN inv_layer_cursor%NOTFOUND;

		if (i_qty_required < l_inv_layer_rec.layer_quantity) then
			l_stmt_num := 30;
			l_inv_layer_rec.layer_quantity := i_qty_required;
		end if;

		l_stmt_num := 40;
		i_qty_required := i_qty_required - l_inv_layer_rec.layer_quantity;

		l_stmt_num := 50;
		insert_record(l_inv_layer_rec,l_inv_layer_table,l_err_num,l_err_code,l_err_msg);

	END LOOP;

EXCEPTION
   when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
   when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.populate_layer_table (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
END populate_layer_table;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_record                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure extends the PL/SQL table and inserts a new record     --
--                                                                        --
-- PURPOSE:                                                               --
--   This procedure extends the PL/SQL table and inserts a new record     --
--                                                                        --
-- PARAMETERS:                                                            --
--       l_inv_layer_rec   : record to be inserted                        --
--       l_inv_layer_table : PL/SQL table into which record is inserted   --
----------------------------------------------------------------------------
PROCEDURE insert_record(l_inv_layer_rec IN cst_layer_rec_type,
				l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
				o_err_num	OUT NOCOPY	 NUMBER,
				o_err_code  OUT NOCOPY	 VARCHAR2,
				o_err_msg   OUT NOCOPY	 VARCHAR2) IS
  l_stmt_num NUMBER;
  l_err_num NUMBER;
  l_err_code VARCHAR2(240);
  l_err_msg  VARCHAR2(240);
  l_next_record NUMBER;
  process_error EXCEPTION;

BEGIN
   l_stmt_num := 0;
   l_err_num := 0;
   l_err_code := '';
   l_err_msg := '';

   l_stmt_num := 10;
   l_next_record := nvl(l_inv_layer_table.LAST,0);

   l_stmt_num := 20;
   l_inv_layer_table.extend;

   l_stmt_num := 30;
   l_next_record := nvl(l_inv_layer_table.LAST,0);

   l_stmt_num := 40;
   l_inv_layer_table(l_next_record).inv_layer_id := l_inv_layer_rec.inv_layer_id;
   l_inv_layer_table(l_next_record).layer_quantity := l_inv_layer_rec.layer_quantity;
EXCEPTION
   when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;
   when others then
       rollback;
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPLENG.insert_record (' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,200);
END insert_record;


---------------------------------------------------------------------------
-- PROCEDURE apply_layer_material_ovh
-- created by Dieu-Thuong Le  21-Apr-2000

-- This procedure will compute material overheads based on the rates
-- defined in the rate cost type specified for the current costing org.
-- The computed movh will be applied to this level material overhead of
-- the specified inventory layer.
-- This procedure will insert MACS rows for each applicable material
-- overhead and insert or update MCLACD.
--     Inserting MCLACD: populate both layer_cost and actual_cost with the
--                       total costs of all MACS rows created for tranx.
--     Updating MCLACD:  add MACS costs to actual_cost, layer_cost will
--                       not be touched.
-- Assumption:  when this procedure is called, MCLACD material row should
-- already be inserted for the transaction.
---------------------------------------------------------------------------
procedure apply_layer_material_ovhd(
  I_ORG_ID        IN      NUMBER,
  I_TXN_ID        IN      NUMBER,
  I_LAYER_ID      IN      NUMBER,
  I_INV_LAYER_ID  IN      NUMBER,
  I_LAYER_QTY     IN      NUMBER,
  I_COST_TYPE     IN      NUMBER,
  I_MAT_CT_ID     IN      NUMBER,
  I_AVG_RATES_ID  IN      NUMBER,
  I_ITEM_ID       IN      NUMBER,
  I_TXN_QTY       IN      NUMBER,
  I_TXN_ACTION_ID IN      NUMBER,
  I_LEVEL         IN      NUMBER,
  I_USER_ID       IN      NUMBER,
  I_LOGIN_ID      IN      NUMBER,
  I_REQ_ID        IN      NUMBER,
  I_PRG_APPL_ID   IN      NUMBER,
  I_PRG_ID        IN      NUMBER,
  I_INTERORG_REC  IN      NUMBER, --bug 2280515:anjgupta
  O_Err_Num       OUT NOCOPY     NUMBER,
  O_Err_Code      OUT NOCOPY     VARCHAR2,
  O_Err_Msg       OUT NOCOPY     VARCHAR2
) IS
  l_mat_ovhds             NUMBER;
  l_item_cost             NUMBER;
  l_res_id                NUMBER;
  l_err_num               NUMBER;
  l_err_code              VARCHAR2(240);
  l_err_msg               VARCHAR2(240);
  l_stmt_num              NUMBER;
  overhead_error          EXCEPTION;
  avg_rates_no_ovhd       EXCEPTION;
  l_mclacd_ovhd           NUMBER;
  l_ovhd_cost             NUMBER;
  l_macs_ovhd             NUMBER;
  l_elemental_visible     VARCHAR2(1);
  l_from_org              NUMBER;
  l_to_org                NUMBER;
  l_txn_org_id            NUMBER;
  l_txfr_org_id           NUMBER;
  l_txn_qty               NUMBER;
  l_txn_type_id           NUMBER;
  l_debug                 VARCHAR2(80);

  /* moh variables */
  l_earn_moh              NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  moh_rules_error         EXCEPTION;
  l_default_MOH_subelement NUMBER;-------------------Bug 3959770


BEGIN
  -- initialize local variables
  l_err_num  := 0;
  l_err_code := '';
  l_err_msg  := '';
  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;

/* BUG 3959770*/
 /* Get the Default MOH sub element of the organization*/

 select DEFAULT_MATL_OVHD_COST_ID
 into l_default_MOH_subelement
 from mtl_parameters
 where organization_id= I_ORG_ID;


-- Find out if there are any material overhead rows for the layer
-- which have actual cost value.

if(l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'In apply_layer_material_ovhd!!!!');
end if;

  l_stmt_num := 10;
   /* Changes for MOH Absorption Rules */

   cst_mohRules_pub.apply_moh(
                              1.0,
                              p_organization_id => i_org_id,
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

  IF(l_earn_moh = 0) THEN
     fnd_file.put_line(fnd_file.log, '--Material Overhead Absorption Overidden--');  ELSE

    l_stmt_num := 11;

  select count(*)
     into l_mat_ovhds
     from mtl_cst_layer_act_cost_details
     where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_layer_id              -- cost group layer
       and inv_layer_id = i_inv_layer_id      -- inventory layer
       and cost_element_id = 2
       and level_type = decode(i_level,1,1,level_type)
       and actual_cost > 0;

  l_stmt_num := 15;

  select organization_id, transfer_organization_id, primary_quantity
     into l_txn_org_id, l_txfr_org_id, l_txn_qty
     from mtl_material_transactions
     where transaction_id = i_txn_id;

  -- Determine the from and to org for this transaction.
  if (i_txn_action_id = 21) then                  -- intransit shipment
   l_from_org := l_txn_org_id;
   l_to_org := l_txfr_org_id;
  elsif (i_txn_action_id = 12) then               -- intransit receipt
   l_from_org := l_txfr_org_id;
   l_to_org := l_txn_org_id;
  elsif (i_txn_action_id =3 and l_txn_qty <0) then  --  direct org transfer
   l_from_org := l_txn_org_id;
   l_to_org := l_txfr_org_id;
  else
     l_from_org := l_txfr_org_id;
     l_to_org := l_txn_org_id;
  end if;


  l_stmt_num := 20;
  -- do elemental visibility check for interorg transfer
  if (i_txn_action_id in (12,21,3)) then
     select NVL(elemental_visibility_enabled,'N')
        into l_elemental_visible
        from mtl_interorg_parameters
        where from_organization_id = l_from_org
          and to_organization_id = l_to_org;
  end if;

-- Until we can support landed cost, i.e. freight, duty, etc... for PO receipt,
-- we can assume that there should be no actual cost in MCLACD overhead rows
-- at this time, UNLESS it is an interorg transaction.

  if not ((i_txn_action_id in (12,21,3)) and (l_elemental_visible = 'Y')) then
     if (l_mat_ovhds > 0) then
       raise overhead_error;
     end if;
  end if;

-- Since RTV or Assembly Return transactions can conceivably have multiple MCLACD
-- movh rows, we should check if MACS rows have already been inserted for the
-- transaction.  If so, there is no need to insert MACS again,
-- we just have to insert or update MCLACD later.

  l_stmt_num := 25;

  select count(*)
     into l_macs_ovhd
     from mtl_actual_cost_subelement
     where transaction_id = i_txn_id
        and organization_id = i_org_id
        and layer_id = i_layer_id
        and cost_element_id = 2
        and level_type = decode (i_level, 1,1,level_type);

  if l_macs_ovhd <= 0  then    /* inserting MACS */
     if (i_mat_ct_id <> i_cost_type) then  --  this is the common scenario since the
                                           --  seeded cost type for FIFO/LIFO should
                                           --  not be the rate cost type

       l_stmt_num := 30;

       -- Compute item cost of layer.  This will be used to calculate
       -- the material overhead of 'total value' basis (basis_type = 5)

       select nvl(sum(actual_cost),0)
       into l_item_cost
       from mtl_cst_layer_act_cost_details
       where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_layer_id
       and inv_layer_id = i_inv_layer_id;

       -- Ensure that resource_id is NOT NULL in CICD
       l_stmt_num := 32;
       select count(*)
       into l_res_id
       from cst_item_cost_details cicd
       where inventory_item_id = i_item_id
          and organization_id = i_org_id
          and cost_type_id = i_mat_ct_Id
          and basis_type in (1,2,5,6)
          and cost_element_id = 2
          and resource_id IS NULL;

  	if (l_res_id > 0) then 		/*Changed this if block and inserted the update statement
					 instead of raising the exception due to bugg 3959770*/

	if (l_default_MOH_subelement is NOT NULL) then
        	update CST_ITEM_COST_DETAILS
	       	set resource_id = l_default_MOH_subelement
	      	where inventory_item_id = i_item_id
	        and organization_id = i_org_id
	        and cost_type_id = i_mat_ct_Id
	        and basis_type in (1,2,5,6)
	        and cost_element_id = 2
	        and resource_id IS NULL;
	else
                raise avg_rates_no_ovhd;
        end if;
       end if;



       l_stmt_num := 35;

       if(l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'Inserting into MACS');
       end if;

       Insert into mtl_actual_cost_subelement(
         transaction_id,
         organization_id,
         layer_id,
         cost_element_id,
         level_type,
         resource_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         actual_cost,
         user_entered)
       select i_txn_id,
         i_org_id,
         i_layer_id,
         cicd.cost_element_id,
         cicd.level_type,
         cicd.resource_id,
         sysdate,
         i_user_id,
         sysdate,
         i_user_id,
         i_login_id,
         i_req_id,
         i_prg_appl_id,
         i_prg_id,
         sysdate,
         decode(cicd.basis_type, 1, cicd.usage_rate_or_amount,
                                 2, cicd.usage_rate_or_amount/abs(i_txn_qty),
                                 5, cicd.usage_rate_or_amount * l_item_cost,
                                 6, cicd.usage_rate_or_amount * cicd.basis_factor,0),
         'N'
       from cst_item_cost_details cicd
       where inventory_item_id = i_item_id
          and organization_id = i_org_id
          and cost_type_id = i_mat_ct_Id
          and basis_type in (1,2,5,6)
          and cost_element_id = 2
          and level_type = decode(i_level, 1,1,level_type);

     else /* material overhead cost type is average cost type */
          -- In this case we will charge the material overhead in the average
          -- cost type using the first material overhead in the average rates
          -- cost type.  This function will error out if material overhead
          -- exists in average cost type and none is defined in the average rates
          -- cost type.

       l_stmt_num := 40;

       select count(*)
          into l_mat_ovhds
          from cst_layer_cost_details
          where layer_id = i_layer_id
            and cost_element_id = 2
            and level_type = 1;

       if (l_mat_ovhds >0 ) then /* material overhead exists in the seeded
                                 cost type */
         l_stmt_num := 45;
         select count(*)
           into l_res_id
           from cst_item_cost_details
           where cost_type_id = i_avg_rates_id
             and inventory_item_id = i_item_id
             and organization_id = i_org_id;

          if (l_res_id > 0) then
            l_stmt_num := 50;
            select resource_id
              into l_res_id
              from cst_item_cost_details
              where cost_type_id = i_avg_rates_id
                and inventory_item_id = i_item_id
                and organization_id = i_org_id
                and cost_element_id = 2
                and rownum = 1;
          end if;
	/* Changed this check and included the elsif block which inserts the resource
	   id instead of throwing the exception	Bug 3959770*/

         if (l_res_id = 0) then
		raise avg_rates_no_ovhd;
 	 elsif (l_res_id is NULL) then
		if (l_default_MOH_subelement IS NOT NULL) then
			l_res_id := l_default_MOH_subelement;

			update cst_item_cost_details
			set resource_id = l_default_MOH_subelement
			where cost_type_id = i_avg_rates_id
	                and inventory_item_id = i_item_id
	                and organization_id = i_org_id
	                and cost_element_id = 2
			and resource_id IS NULL
	                and rownum =1;
		else
			raise avg_rates_no_ovhd;
        	end if;
	 end if;


         l_stmt_num := 55;
       if(l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log, 'Inserting into MACS');
       end if;

         Insert into mtl_actual_cost_subelement(
           transaction_id,
           organization_id,
           layer_id,
           cost_element_id,
           level_type,
           resource_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           actual_cost,
           user_entered)
         select i_txn_id,
           i_org_id,
           i_layer_id,
           clcd.cost_element_id,
           clcd.level_type,
           l_res_id,
           sysdate,
           i_user_id,
           sysdate,
           i_user_id,
           i_login_id,
           i_req_id,
           i_prg_appl_id,
           i_prg_id,
           sysdate,
           clcd.item_cost,
           'N'
         from cst_layer_cost_details clcd
         where layer_id = i_layer_id
           and cost_element_id = 2
           and level_type = 1;
       end if;
     end if;
  end if;  /* end of inserting MACS */

-- check again for existence of MACS.  This time load count into l_mat_ovhds.

  l_stmt_num := 60;

  select count(*)
  into l_mat_ovhds
  from mtl_actual_cost_subelement
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  and layer_id = i_layer_id
  and cost_element_id = 2
  and level_type = decode(i_level, 1,1,level_type);

  if l_debug = 'Y' then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'movh.l_mat_ovhds = '
                                   || to_char(l_mat_ovhds)
                                   || ' , stmt '
                                   || to_char(l_stmt_num));
  end if;

  l_stmt_num := 65;

  -- check if there is data in MCLACD (material overhead) for this layer.
  select count(*)
     into l_mclacd_ovhd
     from mtl_cst_layer_act_cost_details mclacd
     where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_layer_id
       and inv_layer_id = i_inv_layer_id
       and cost_element_id = 2
       and level_type = decode(i_level,1,1,level_type);

  if l_debug = 'Y' then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'movh.mclacd_ovhd = '
                                   || to_char(l_mclacd_ovhd)
                                   || ' , stmt '
                                   || to_char(l_stmt_num));
  end if;

  -- MACS exists :add or modify MCLACD
  -- No data in MACS, then we do not need to do anything.

  if (l_mat_ovhds > 0) then  /* MACS exists */
     -- If there is data in MCLACD then do an update, adding the
     -- sum of MACS.actual cost to the existing cost in mclacd.
     -- Otherwise, insert a row in MCLACD.

       l_stmt_num := 70;
       select sum(actual_cost)
          into l_ovhd_cost
          from mtl_actual_cost_subelement
          where transaction_id = i_txn_id
            and organization_id = i_org_id
            and layer_id = i_layer_id
            and cost_element_id = 2;

  if l_debug = 'Y' then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'movh.l_ovhd_cost = '
                                   || to_char(l_ovhd_cost)
                                   || ' ,stmt '
                                   || to_char(l_stmt_num));
  end if;


     if (l_mclacd_ovhd > 0) then    /* mclacd exists  */
       l_stmt_num := 72;
       select transaction_type_id
       into l_txn_type_id
       from mtl_material_transactions
       where transaction_id = i_txn_id;

/* Bug 2280515  :anjgupta
   The variance_amount is zero in the case of interorg receipt transactions.
   Updating in a seperate if-else loop to prevent use of decode statements.
*/
        if(i_interorg_rec = 1) then

            l_stmt_num := 75;

            update mtl_cst_layer_act_cost_details mclacd
       set mclacd.actual_cost = nvl(mclacd.actual_cost, 0) + l_ovhd_cost,
           mclacd.layer_cost = nvl(mclacd.layer_cost,0) + l_ovhd_cost,
           mclacd.variance_amount = 0,
           mclacd.payback_variance_amount = 0
       where mclacd.transaction_id = i_txn_id
         and mclacd.organization_id = i_org_id
         and mclacd.layer_id = i_layer_id
         and mclacd.inv_layer_id = i_inv_layer_id
         and mclacd.level_type = 1
         and mclacd.cost_element_id = 2;

       else

       l_stmt_num := 76;
       update mtl_cst_layer_act_cost_details mclacd
       set mclacd.actual_cost = nvl(mclacd.actual_cost, 0) + l_ovhd_cost,
           mclacd.variance_amount = decode(l_txn_type_id,68,0,
                                    (nvl(mclacd.actual_cost,0) + l_ovhd_cost
                                    - nvl(mclacd.layer_cost,0)) * layer_quantity ),
           mclacd.payback_variance_amount =  decode(l_txn_type_id,68,
                                      ((nvl(mclacd.actual_cost,0) + l_ovhd_cost
                                    - nvl(mclacd.layer_cost,0)) * layer_quantity),0)

       where mclacd.transaction_id = i_txn_id
         and mclacd.organization_id = i_org_id
         and mclacd.layer_id = i_layer_id
         and mclacd.inv_layer_id = i_inv_layer_id
         and mclacd.level_type = 1
         and mclacd.cost_element_id = 2;
      end if;

          if l_debug = 'Y' then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'movh.updating mclacd...l_ovhd_cost = '
                                   || to_char(l_ovhd_cost)
                                   || ' , stmt '
                                   || to_char(l_stmt_num));
     end if;


     else       /* mclacd does not exist  */
       l_stmt_num := 80;
       insert into mtl_cst_layer_act_cost_details(
          transaction_id,
          organization_id,
          inventory_item_id,
          cost_element_id,
          level_type,
          layer_id,
          inv_layer_id,
          layer_quantity,
          layer_cost,
          actual_cost,
          variance_amount,
          user_entered,
          payback_variance_amount,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date)
       values (
          i_txn_id,
          i_org_id,
          i_item_id,
          2,
          1,
          i_layer_id,
          i_inv_layer_id,
          decode(sign(i_txn_qty),-1,-1*i_layer_qty,i_layer_qty),
          decode(sign(i_txn_qty),-1,0,l_ovhd_cost),    /* layer_cost */
          l_ovhd_cost,  /* actual_cost */
          decode(sign(i_txn_qty),-1,(-1*l_ovhd_cost*i_layer_qty),0),  /* variance_amount */
          'N',               /* user_entered */
          0,                 /* payback_variance_amount */
          sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate);

     if l_debug = 'Y' then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'movh.insertign mclacd...l_ovhd_cost = '
                                   || to_char(l_ovhd_cost)
                                   || ',txn_lyr = '
                                   || to_char(i_layer_qty)
                                   || ' , stmt '
                                   || to_char(l_stmt_num));
     end if;

     end if;    /* mclacd does not exist */
   end if;      /* macs exists */
 END IF;

  EXCEPTION
    when avg_rates_no_ovhd then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NO_MAT_OVHDS';
      FND_MESSAGE.set_name('BOM', 'CST_NO_MAT_OVHDS');
      o_err_msg := FND_MESSAGE.Get;
    when overhead_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_MAT_OVERHEAD';
      FND_MESSAGE.set_name('BOM', 'CST_MAT_OVERHEAD');
      o_err_msg := FND_MESSAGE.Get;
    when moh_rules_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_RULES_ERROR';
      FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
      o_err_msg := FND_MESSAGE.Get;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLENG.apply_layer_material_ovhd (' || to_char(l_stmt_num) ||
                   '): '
                   || substr(SQLERRM, 1,200);

END apply_layer_material_ovhd;

/*********************************************************************************
** PROCEDURE                                                                    **
**     calc_layer_average_cost                                                  **
**                                                                              **
** DESCRIPTION                                                                  **
** It main function is to perform the following for the specified transaction:  **
**      . insert into MCACD with MCLACD's summarized costs                      **
**      . update CLCD with CILCD's summarized costs                             **
**      . update CQL's costs from CLCD                                          **
**      . update CICD's costs from CLCD                                         **
**      . update CIC's costs from CICD                                          **
** This procedure assumes that all MCLACD rows have already been inserted by    **
** calling program.                                                             **
** Set I_NO_UPDATE_MMT = 1 if the calling program does not want mmt to be       **
**                       update; otherwise, set it to 0                         **
** Set I_NO_UPDATE_QTY = 1 if clcd, cql, cic and cicd should not be updated;    **
**                       otherwise, set it to 0                                 **
**                                                                              **
** HISTORY                                                                      **
**   4/24/00     Dieu-Thuong Le              Creation                           **
**   9/05/00     Dieu-Thuong Le    Fix bug 1393484: payback variance should     **
**                                 be stored in MCACD by qty unit because       **
**                                 the distribution proc. CSTPACDP.inventory_   **
**                                 accounts will calc payback variance to be    **
**                                 posted (-1*i_pqty*l_payback_var)             **
*********************************************************************************/

procedure calc_layer_average_cost(
  I_ORG_ID	   IN	NUMBER,
  I_TXN_ID	   IN 	NUMBER,
  I_LAYER_ID	   IN	NUMBER,
  I_COST_TYPE	   IN	NUMBER,
  I_ITEM_ID	   IN	NUMBER,
  I_TXN_QTY	   IN	NUMBER,
  I_TXN_ACTION_ID  IN	NUMBER,
  I_COST_HOOK      IN   NUMBER,
  I_NO_UPDATE_MMT  IN	NUMBER,
  I_NO_UPDATE_QTY  IN   NUMBER,
  I_USER_ID	   IN	NUMBER,
  I_LOGIN_ID	   IN 	NUMBER,
  I_REQ_ID	   IN	NUMBER,
  I_PRG_APPL_ID    IN	NUMBER,
  I_PRG_ID	   IN	NUMBER,
  O_Err_Num	   OUT NOCOPY	NUMBER,
  O_Err_Code	   OUT NOCOPY	VARCHAR2,
  O_Err_Msg	   OUT NOCOPY	VARCHAR2
) IS
  l_txfr_txn_id	     NUMBER;
  l_total_layer_qty  NUMBER;
  l_level_type       NUMBER;
  l_txn_type_id      NUMBER;
  l_proj_enabled     NUMBER;
  l_mandatory_update NUMBER;
  l_count	     NUMBER;
  l_err_num	     NUMBER;
  l_err_code	     VARCHAR2(240);
  l_err_msg	     VARCHAR2(240);
  l_stmt_num	     NUMBER;
  process_error	     EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

/********************************************************************
** For each cost element/level type, one row of MCACD is inserted, **
** aggregating inventory layer(s) cost. The actual cost populated  **
** in MCACD is the weighted average cost of all inventory layers   **
** associated to the transaction.  The variance amount is the sum  **
** of those layers' amounts.                                       **
**                                                                 **
** Note:  Unlike the Average Costing processor which uses the      **
** insertion flag to signal clcd insert, the layer cost processor  **
** uses CILCD for CLCD insert and not MCACD.  Therefore, insertion **
** flag will always be set to 'N'.                                 **
**                                                                 **
********************************************************************/

   -- get transaction type.  It will be needed to identify payback transaction
   -- and calculate payback variance.

   l_stmt_num := 5;
   select transaction_type_id
      into l_txn_type_id
      from mtl_material_transactions
      where transaction_id = i_txn_id;

   l_stmt_num := 6;
   select count(*)
   into l_count
   from mtl_cst_layer_act_cost_details
   where transaction_id = i_txn_id
   and organization_id = i_org_id;

   if (l_count = 0) then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No records in MCLACD');
   end if;

   /* Insert MCACD (by summing up MCLACD) only if it's not a scrap txn.
      Beware: there will be time where MCACD exists, such as when cost hook is used.
      In such case, update MCACD with variance amounts.
   */

   if (i_txn_action_id <> 30) then

      l_stmt_num := 10;
         update mtl_cst_actual_cost_details mcacd
            set (prior_cost,
                 new_cost,
                 variance_amount,
                 payback_variance_amount,
		 onhand_variance_amount) =
            (select
                 0,               -- prior cost
                 NULL,            -- new cost
                 NVL(sum(mclacd.variance_amount),0),
                 NVL(sum(mclacd.payback_variance_amount)/abs(i_txn_qty),0), -- bugfix 1393484
		 NVL(sum(mclacd.onhand_variance_amount),0)
             from mtl_cst_layer_act_cost_details mclacd
             where mclacd.transaction_id = i_txn_id
               and mclacd.organization_id = i_org_id
               and mclacd.layer_id = i_layer_id
               and mclacd.cost_element_id = mcacd.cost_element_id
               and mclacd.level_type = mcacd.level_type
             group by mclacd.cost_element_id, mclacd.level_type)
          where mcacd.transaction_id = i_txn_id
            and mcacd.organization_id = i_org_id
            and mcacd.layer_id = i_layer_id
            and mcacd.transaction_action_id = i_txn_action_id;

      l_stmt_num := 12;
      insert into mtl_cst_actual_cost_details (
	   transaction_id,
	   organization_id,
	   layer_id,
	   cost_element_id,
           level_type,
           transaction_action_id,
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
	   actual_cost,
	   prior_cost,
	   new_cost,
	   insertion_flag,
	   variance_amount,
	   user_entered,
           payback_variance_amount,
	   onhand_variance_amount)
         select i_txn_id,
	    i_org_id,
	    i_layer_id,
	    mclacd.cost_element_id,
	    mclacd.level_type,
	    i_txn_action_id,
	    sysdate,
            i_user_id,
            sysdate,
            i_user_id,
            i_login_id,
            i_req_id,
            i_prg_appl_id,
            i_prg_id,
            sysdate,
	    i_item_id,
            decode(
              i_txn_qty,
              0,
  				NVL((sum(mclacd.actual_cost)),0), -- modified for bug#3835412 -- NVL(abs(sum(mclacd.actual_cost)),0),
                NVL((sum(mclacd.actual_cost * abs(mclacd.layer_quantity)) / abs(i_txn_qty)),0)), -- modified for bug#3835412 -- NVL(abs(sum(mclacd.actual_cost * mclacd.layer_quantity) / i_txn_qty),0)),
            0,                                          -- prior cost
	    NULL,                                       -- new cost
            'N',                                         -- insertion flag
            NVL(sum(mclacd.variance_amount),0),
            'N',
            NVL(sum(mclacd.payback_variance_amount)/abs(i_txn_qty),0), -- bugfix 1393484
	    NVL(sum(mclacd.onhand_variance_amount),0)
          from mtl_cst_layer_act_cost_details mclacd
          where mclacd.transaction_id = i_txn_id
            and mclacd.organization_id = i_org_id
            and mclacd.layer_id = i_layer_id
            and not exists
                (select 'MCACD does not exist'
                    from mtl_cst_actual_cost_details mcacd
                      where mcacd.transaction_id = i_txn_id
                        and mcacd.organization_id = i_org_id
                        and mcacd.layer_id = i_layer_id
                        and mcacd.cost_element_id = mclacd.cost_element_id
                        and mcacd.level_type = mclacd.level_type)
          group by mclacd.cost_element_id, mclacd.level_type;

      end if;   -- end checking for scrap transaction

   -- Update MCACD.prior_cost with the corresponding cost in CLCD before CLCD cost
   -- is updated.

   l_stmt_num := 15;

   update mtl_cst_actual_cost_details mcacd
      set prior_cost =
         (select clcd.item_cost
         from cst_layer_cost_details clcd
         where clcd.layer_id = i_layer_id
           and clcd.cost_element_id = mcacd.cost_element_id
           and clcd.level_type = mcacd.level_type)
     where mcacd.transaction_id = i_txn_id
       and mcacd.organization_id = i_org_id
       and mcacd.layer_id = i_layer_id
       and mcacd.transaction_action_id = i_txn_action_id
       and exists
	   (select 'there is details in clcd'
	    from cst_layer_cost_details clcd
	    where clcd.layer_id = i_layer_id
	      and clcd.cost_element_id = mcacd.cost_element_id
	      and clcd.level_type = mcacd.level_type);

   -- Insert missing cost elements into mcacd (bug 2987309)
   l_stmt_num := 17;
   INSERT
   INTO   mtl_cst_actual_cost_details (
	    transaction_id,
	    organization_id,
	    layer_id,
            cost_element_id,
	    level_type,
	    transaction_action_id,
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
	    actual_cost,
	    prior_cost,
	    new_cost,
	    insertion_flag,
	    variance_amount,
	    user_entered
          )
   SELECT i_txn_id,
          i_org_id,
          i_layer_id,
	  CLCD.cost_element_id,
	  CLCD.level_type,
	  i_txn_action_id,
	  sysdate,
      	  i_user_id,
       	  sysdate,
          i_user_id,
      	  i_login_id,
      	  i_req_id,
      	  i_prg_appl_id,
      	  i_prg_id,
      	  sysdate,
	  i_item_id,
      	  0,
      	  CLCD.item_cost,
	  NULL,
      	  'N',
      	  0,
      	  'N'
   FROM   cst_layer_cost_details CLCD
   WHERE  layer_id = i_layer_id
   AND    NOT EXISTS(
            SELECT 'this detail is not in MCACD already'
	        FROM   mtl_cst_actual_cost_details MCACD
	        WHERE  MCACD.transaction_id = i_txn_id
	        AND    MCACD.organization_id = i_org_id
	        AND    MCACD.layer_id = i_layer_id
	        AND    MCACD.cost_element_id = CLCD.cost_element_id
	        AND    MCACD.level_type = CLCD.level_type);

    /*******************************************************************
    ** Update cst_layer_cost_details if i_no_update_qty is not set.   **
    ** Since CQL quantity before this transaction is still needed by  **
    ** CSTPAVCP.update_mmt, CQL quantity and cost information will be **
    ** updated later.                                                 **
    ********************************************************************/
-- get the total layer quantity from cil
   select sum(cil.layer_quantity)
     into l_total_layer_qty
     from cst_inv_layers cil
     where cil.layer_id = i_layer_id;

/* Update clcd only if i_no_update_qty flag is not set and the total layer quantity is not zero */

    if (i_no_update_qty = 0) and
       (l_total_layer_qty <> 0) then
       l_stmt_num := 20;
       -- get the total layer quantity from cil
          select sum(cil.layer_quantity)
            into l_total_layer_qty
            from cst_inv_layers cil
            where cil.layer_id = i_layer_id;

       l_stmt_num := 25;

       delete from cst_layer_cost_details
          where layer_id = i_layer_id;

       l_stmt_num := 30;

       insert into cst_layer_cost_details(
              layer_id,
              cost_element_id,
              level_type,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              item_cost)
           select cilcd.layer_id,
              cilcd.cost_element_id,
              cilcd.level_type,
              sysdate,
              i_user_id,
              sysdate,
              i_user_id,
              i_login_id,
              i_req_id,
              i_prg_appl_id,
              i_prg_id,
              sysdate,
              (sum((cilcd.layer_cost*cil.layer_quantity)/l_total_layer_qty)) -- modified for bug#3835412
            from cst_inv_layer_cost_details cilcd,
                 cst_inv_layers cil
            where cil.layer_id = i_layer_id
              and cil.organization_id = i_org_id
              and cil.inventory_item_id = i_item_id
              and cil.inv_layer_id = cilcd.inv_layer_id
            group by cilcd.layer_id,cost_element_id, level_type;
    end if;  -- end updating cost info

   /********************************************************************
   ** Update MCACD with new cost                                      **
   ********************************************************************/
   l_stmt_num := 35;

   update mtl_cst_actual_cost_details mcacd
   set new_cost =
       (select clcd.item_cost
           from cst_layer_cost_details clcd
           where clcd.layer_id = i_layer_id
             and clcd.cost_element_id = mcacd.cost_element_id
             and clcd.level_type = mcacd.level_type)
      where mcacd.organization_id = i_org_id
        and mcacd.transaction_id = i_txn_id
        and mcacd.layer_id = i_layer_id
        and mcacd.transaction_action_id = i_txn_action_id;

  /********************************************************************
   ** Update Mtl_Material_Transactions				         **
   ** Need to update prior_costed_quantity now.			         **
   ********************************************************************/
   l_stmt_num := 40;
   if (i_no_update_mmt = 0) then
       -- subinventory transfer for receipt side, we need to pass
       -- txfr_txn_id to update proper transaction in MMT.
      if (i_txn_action_id = 2 and i_txn_qty > 0) then
        select transfer_transaction_id
        into l_txfr_txn_id
        from mtl_material_transactions
        where transaction_id = i_txn_id;
      else
        l_txfr_txn_id := -1;
      end if;

      CSTPAVCP.update_mmt(
			i_org_id,
			i_txn_id,
			l_txfr_txn_id,
			i_layer_id,
			0,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);
      if (l_err_num <> 0) then
        raise process_error;
      end if;
   end if;    -- end updating mmt

  /********************************************************************
  ** Update layer quantity and layer costs information               **
  ** (cst_quantity_layers)                                           **
  ********************************************************************/
   if i_no_update_qty = 0 then
      l_stmt_num := 45;
      update cst_quantity_layers cql
      set (last_updated_by,
	     last_update_date,
	     last_update_login,
	     request_id,
	     program_application_id,
	     program_id,
	     program_update_date,
             layer_quantity,
	     update_transaction_id,
	     pl_material,
	     pl_material_overhead,
	     pl_resource,
	     pl_outside_processing,
	     pl_overhead,
	     tl_material,
	     tl_material_overhead,
	     tl_resource,
	     tl_outside_processing,
	     tl_overhead,
	     material_cost,
	     material_overhead_cost,
	     resource_cost,
	     outside_processing_cost,
	     overhead_cost,
	     pl_item_cost,
	     tl_item_cost,
	     item_cost,
	     unburdened_cost,
	     burden_cost) =
        (select
          i_user_id,
           sysdate,
           i_login_id,
	   i_req_id,
           i_prg_appl_id,
           i_prg_id,
           sysdate,
           l_total_layer_qty,
	   i_txn_id,
	   pl_material,
	   pl_material_overhead,
	   pl_resource,
	   pl_outside_processing,
	   pl_overhead,
	   tl_material,
	   tl_material_overhead,
	   tl_resource,
	   tl_outside_processing,
	   tl_overhead,
	   material_cost,
	   material_overhead_cost,
	   resource_cost,
	   outside_processing_cost,
	   overhead_cost,
	   pl_item_cost,
	   tl_item_cost,
	   item_cost,
	   unburdened_cost,
	   burden_cost
        from cst_quantity_layers_v v
        where v.layer_id = i_layer_id)
      where cql.layer_id = i_layer_id
      and exists
        (select 'there is detail cost'
         from cst_layer_cost_details clcd
         where clcd.layer_id = i_layer_id);

      /********************************************************************
      ** Update Item Cost and Item Cost Details			         **
      ********************************************************************/

      -- Determine the value of mandatory_update_flag.
      -- If project is not enabled, set the l_mandatory_update flag.
      -- This flag is passed to update_item_cost() routine. In that
      -- routine, if this flag is set to 1, the item_cost will be
      -- copied from clcd to cicd evenif the quantity <= 0.
      -- Otherwise, it will return immediately if the quantity <= 0.
      -- For quantity > 0, this flag is ignored, and the weighted avg
      -- of cost in clcd (accross different cost group) will be put
      -- into cicd.

      l_stmt_num := 50;

      -- Bug 2401323 - propagation bug for bugfix 2306923
      -- Bug 2306923: l_mandatory_update should be zero even if project is not enabled
      -- This change was made to function calls (CSTPAVCP.update_item_cost) for
      -- average costing as part of bug 1756613.
      -- In 11i.2, the cost group model has been enhanced, so that
      -- multiple cost groups can exist in a non project manufacturing organization,
      -- depending on the set of accounts. Hence updating item cost and item cost details
      -- is made to behave exactly like an organization with project
      -- references enabled. The cost will be updated in CLCD, but not in CICD.

      /* select nvl(project_reference_enabled,0)
          into l_proj_enabled
          from mtl_parameters
          where organization_id = i_org_id;

      if (l_proj_enabled = 2) then
         l_mandatory_update := 1;
      else
         l_mandatory_update := 0;
      end if;
      */

      l_mandatory_update := 0;

      CSTPAVCP.update_item_cost(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_mandatory_update,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);
     if (l_err_num <> 0) then
        raise process_error;
     end if;
   end if;     -- end updating quantity and cost info

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLENG.calc_layer_average_cost (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END calc_layer_average_cost;

/************************************************************************
**  PROCEDURE                                                          **
**     layer_cost_update                                               **
**                                                                     **
**  DESCRIPTION                                                        **
**     This function is called to update inventory layer cost.         **
**     It will determine the new elemental costs of the layer based    **
**     on user-enter values and compute the adjustment amounts to      **
**     inventory valuation.                                            **
**     MTL_CST_LAYER_ACT_COST_DETAILS will be populated and the other  **
**     cost tables (CILCD, CIL, CLCD, CQL, CICD, CIC) will be updated  **
**     accordingly with the new cost information.                      **
**     This function is duplicated from CSTPAVCP.average_cost_update.  **
**                                                                     **
**  HISTORY                                                            **
**     12-MAY-2000        Dieu-Thuong Le          Creation             **
**                                                                     **
************************************************************************/

procedure layer_cost_update(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_COST_TYPE   IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_TXN_QTY     IN      NUMBER,
  I_TXN_ACT_ID  IN      NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  O_Err_Num     OUT NOCOPY     NUMBER,
  O_Err_Code    OUT NOCOPY     VARCHAR2,
  O_Err_Msg     OUT NOCOPY     VARCHAR2
) IS

  l_neg_cost            NUMBER;
  l_proj_enabled        NUMBER;
  l_mandatory_update    NUMBER;
  l_inv_layer_id        NUMBER;
  l_layer_qty           NUMBER;
  l_mctcd_exist         NUMBER;
  l_stmt_num            NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  process_error         EXCEPTION;
  neg_cost_error        EXCEPTION;
  no_mctcd_error        EXCEPTION;

BEGIN
   -- Initialize variables.
   l_neg_cost := 0;
   l_layer_qty := 0;
   l_mctcd_exist := 0;
   l_err_num := 0;
   l_err_code := '';
   l_err_msg := '';
   o_err_num := 0;
   o_err_code := '';
   o_err_msg := '';

   l_stmt_num := 5;

   -- Get the inv_layer_id whose cost is being changed
   select transaction_source_id
      into   l_inv_layer_id
      from   mtl_material_transactions
      where  transaction_id = I_TXN_ID;

   -- check for existence of mctcd
   l_stmt_num := 7;
   select count(*)
      into l_mctcd_exist
      from mtl_cst_txn_cost_details ctcd
      where ctcd.transaction_id = i_txn_id;

/*   if l_mctcd_exist = 0 then
      raise no_mctcd_error;
   end if;
*/
   if l_mctcd_exist = 0 then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'No mctcd rows');
   end if;

   l_stmt_num := 10;

   /*********************************************************
   ** Insert records into mtl_cst_layer_act_cost_details.  **
   *********************************************************/

   insert into mtl_cst_layer_act_cost_details (
        transaction_id,
        organization_id,
        layer_id,
        inv_layer_id,
        layer_quantity,
        cost_element_id,
        level_type,
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
        actual_cost,
        layer_cost,
        variance_amount,
        user_entered,
	onhand_variance_amount)

 select
        i_txn_id,
        i_org_id,
        i_layer_id,
        l_inv_layer_id,
        cil.layer_quantity,
        ctcd.cost_element_id,
        ctcd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        ctcd.inventory_item_id,
        decode(ctcd.new_average_cost,NULL,          -- actual cost
             decode(ctcd.percentage_change,NULL,
                  /* value change formula */
                  decode(sign(cil.layer_quantity),1,
		    decode(sign(i_txn_qty),1,
		      decode( sign(cil.layer_quantity-i_txn_qty),-1,
                       decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + (ctcd.value_change/i_txn_qty*cil.layer_quantity)),-1,
                            0,
                            (nvl(cilcd.layer_cost,0)*nvl(cil.layer_quantity,0) +
                             (ctcd.value_change/i_txn_qty*cil.layer_quantity))/nvl(cil.layer_quantity,-1)),
                       decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + ctcd.value_change),-1,
                            0,
                            (nvl(cilcd.layer_cost,0)*nvl(cil.layer_quantity,0) +
                             ctcd.value_change)/nvl(cil.layer_quantity,-1))
		             ),
                       decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + ctcd.value_change),-1,
                            0,
                            (nvl(cilcd.layer_cost,0)*nvl(cil.layer_quantity,0) +
                             ctcd.value_change)/nvl(cil.layer_quantity,-1))),
                       nvl(cilcd.layer_cost,0)),
                   /* percentage change formula */
                   nvl(cilcd.layer_cost,0)*(1+ctcd.percentage_change/100)),
             /* new average cost formula */
             ctcd.new_average_cost),
        nvl(cilcd.layer_cost,0),                     -- layer cost
	decode(ctcd.value_change,NULL,
	     0,
	     decode(sign(cil.layer_quantity),1,
	        decode(sign(i_txn_qty),1,
		 decode(sign(cil.layer_quantity-i_txn_qty),-1,
  	          decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + (ctcd.value_change/i_txn_qty*cil.layer_quantity)),-1,
		       (ctcd.value_change/i_txn_qty*cil.layer_quantity) + nvl(cilcd.layer_cost,0) * cil.layer_quantity,
		       0),
	          decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + ctcd.value_change),-1,
		       ctcd.value_change + nvl(cilcd.layer_cost,0) * cil.layer_quantity,
		       0)),
       	          decode(sign(nvl(cilcd.layer_cost,0) * cil.layer_quantity + ctcd.value_change),-1,
		       ctcd.value_change + nvl(cilcd.layer_cost,0) * cil.layer_quantity,
		       0)),
		  ctcd.value_change)),
        'N',                                          -- user entered
	/*LCM*/
	decode(ctcd.value_change,NULL,
           0,
	   decode(sign(i_txn_qty),1,
	          decode(sign(cil.layer_quantity),1,
		         decode(sign(cil.layer_quantity-i_txn_qty),-1,
			        ctcd.value_change*(1-cil.layer_quantity/i_txn_qty),
				0
			        ),
			 0
		         ),
		  0
	          )
           )
  FROM mtl_cst_txn_cost_details ctcd,
       cst_inv_layers cil,
       cst_inv_layer_cost_details cilcd
  WHERE ctcd.transaction_id = i_txn_id
  AND ctcd.organization_id = i_org_id
  AND cil.layer_id = i_layer_id
  AND cil.inv_layer_id = l_inv_layer_id
  AND cil.inventory_item_id = ctcd.inventory_item_id
  AND cil.organization_id = ctcd.organization_id
  AND cilcd.inv_layer_id (+) = l_inv_layer_id
  AND cilcd.cost_element_id (+) = ctcd.cost_element_id
  AND cilcd.level_type (+) = ctcd.level_type;

  -- Verify there are no negative costs!
  l_stmt_num := 20;

/*  select count(*)
     into l_neg_cost
     from mtl_cst_layer_act_cost_details
     where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_layer_id
       and inv_layer_id = l_inv_layer_id
       and actual_cost < 0;

  if (l_neg_cost > 0) then
     raise neg_cost_error;
  end if; */ --removed for bug #4005770

  /************************************************************************
   ** Delete from cst_inv_layer_cost_details and insert the new rows     **
   ** from mtl_cst_actual_cost_details.                                  **
   ***********************************************************************/
  l_stmt_num := 30;

  Delete from cst_inv_layer_cost_details
     where layer_id = i_layer_id
       and inv_layer_id = l_inv_layer_id;

  l_stmt_num := 40;
  Insert into cst_inv_layer_cost_details (
        layer_id,
        inv_layer_id,
        cost_element_id,
        level_type,
        layer_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date)
  select i_layer_id,
         l_inv_layer_id,
         mclacd.cost_element_id,
         mclacd.level_type,
         mclacd.actual_cost,
         sysdate,
         i_user_id,
         sysdate,
         i_user_id,
         i_login_id,
         i_req_id,
         i_prg_appl_id,
         i_prg_id,
         sysdate
     from mtl_cst_layer_act_cost_details mclacd
     where mclacd.transaction_id = i_txn_id
       and mclacd.organization_id = i_org_id
       and mclacd.layer_id = i_layer_id
       and mclacd.inv_layer_id = l_inv_layer_id;

  /********************************************************************
   ** Update cst_inv_layers                                          **
   ********************************************************************/
   l_stmt_num := 50;

   update cst_inv_layers cil
     set (last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        layer_cost)=
     (select
        i_user_id,
        sysdate,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        nvl(sum(layer_cost),0)
      from cst_inv_layer_cost_details cilcd
      where cilcd.layer_id = i_layer_id
        and   cilcd.inv_layer_id = l_inv_layer_id)
   where cil.layer_id = i_layer_id
     and cil.inv_layer_id = l_inv_layer_id
     and exists
        (select 'there is detail cost'
            from cst_inv_layer_cost_details cilcd
            where cilcd.layer_id = i_layer_id
              and cilcd.inv_layer_id = l_inv_layer_id);


   /*******************************************************
   **  Update mcacd, clcd, cql, cic, cicd and mmt        **
   *******************************************************/

   l_stmt_num := 60;

   -- Get transaction quantity
      select cil.layer_quantity
         into l_layer_qty
         from cst_inv_layers cil
         where cil.layer_id = i_layer_id
           and cil.inv_layer_id = l_inv_layer_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'layer qty = ' || to_char(l_layer_qty));
   l_stmt_num := 70;

   CSTPLENG.calc_layer_average_cost(
            i_org_id,
            i_txn_id,
            i_layer_id,
            i_cost_type,
            i_item_id,
            l_layer_qty,
            i_txn_act_id,
            0,                -- no cost hook
            0,                -- i_no_update_mmt
            0,                -- i_no_update_qty
            i_user_id,
            i_login_id,
            i_req_id,
            i_prg_appl_id,
            i_prg_id,
            l_err_num,
            l_err_code,
            l_err_msg);

   if (l_err_num <> 0) then
      raise process_error;
   end if;

/* Update MMT.quantity_adjusted with update transaction quantity. */

   update mtl_material_transactions mmt
      set last_update_date = sysdate,
           last_updated_by = i_user_id,
           last_update_login = i_login_id,
           program_application_id = i_prg_appl_id,
           program_id = i_prg_id,
           program_update_date = sysdate,
           quantity_adjusted = l_layer_qty
      where mmt.transaction_id = i_txn_id;

  EXCEPTION
    when neg_cost_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NEG_ITEM_COST';
      FND_MESSAGE.set_name('BOM', 'CST_NEG_ITEM_COST');
      o_err_msg := FND_MESSAGE.Get;

/*    when no_mctcd_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NO_MCTCD';
      FND_MESSAGE.set_name('BOM', 'CST_NO_MCTCD');
      o_err_msg := FND_MESSAGE.Get;
*/
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;

    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLENG.layer_cost_update (' || to_char(l_stmt_num) ||
                   '): '
                   || substr(SQLERRM, 1,200);
END layer_cost_update;

----------------------------------------------------------------------------
-- FUNCTION
--  get_current_layer
--  This function is called to return the inv layer id whose cost needs to be
--  used if a issue is done. It is called from WIP to create layers when there
--  are no layers at all in WIP. In that case WIP needs to know which layer cost--  has to be used.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_TXN_ID
--  I_LAYER_ID
--  I_ITEM_ID
--  I_TXN_ACT_ID
--
-- RETURN VALUES
--  integer             1       Successful
--                      0       Error
-----------------------------------------------------------------------------
function get_current_layer(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  I_TXN_SRC_TYPE_ID IN  NUMBER,
  I_TXN_SRC_ID  IN      NUMBER,
  O_Err_Num     OUT NOCOPY     NUMBER,
  O_Err_Code    OUT NOCOPY     VARCHAR2,
  O_Err_Msg     OUT NOCOPY     VARCHAR2
)
return integer  IS
l_inv_layer_id NUMBER;
l_cost_method NUMBER;

BEGIN
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';
  l_inv_layer_id := 0;

  /* Get the cost method for the org */
  select primary_cost_method
  into l_cost_method
  from mtl_parameters
  where organization_id = I_ORG_ID;

  if (l_cost_method = 5) then
    /* Try to return the first positive layer */
    select nvl(min(inv_layer_id),0)
    into l_inv_layer_id
    from cst_inv_layers
    where layer_id = i_layer_id
    and layer_quantity > 0;
    /* If there is no positive layer, return the last layer */
    if l_inv_layer_id = 0 then
      select nvl(max(inv_layer_id),0)
      into l_inv_layer_id
      from cst_inv_layers
      where layer_id = i_layer_id;
    end if;
  elsif (l_cost_method = 6) then
    /* Try to return the last positive layer */
    select nvl(max(inv_layer_id), 0)
    into l_inv_layer_id
    from cst_inv_layers
    where layer_id = i_layer_id
    and layer_quantity > 0;
    /* If there is no positive layer, return the first layer */
    if l_inv_layer_id = 0 then
      select nvl(min(inv_layer_id),0)
      into l_inv_layer_id
      from cst_inv_layers
      where layer_id = i_layer_id;
    end if;
  end if;

  if (l_inv_layer_id = 0) then
/* No inv layers exist: Hence create one with 0 qty,cost */

   select cst_inv_layers_s.nextval
   into   l_inv_layer_id
   from   dual;

   insert into cst_inv_layers (
         create_transaction_id,
         layer_id,
         inv_layer_id,
         organization_id,
         inventory_item_id,
         creation_quantity,
         layer_quantity,
         layer_cost,
         transaction_source_type_id,
         transaction_source_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date)
     select
         i_txn_id,
         i_layer_id,
         l_inv_layer_id,
         i_org_id,
         i_item_id,
         0,
         0,
         0,
         i_txn_src_type_id,
         i_txn_src_id,
         sysdate,
         i_user_id,
         sysdate,
         i_user_id,
         i_login_id,
         i_req_id,
         i_prg_appl_id,
         i_prg_id,
         sysdate
     from dual;

      insert into cst_inv_layer_cost_details (
         layer_id,
         inv_layer_id,
         cost_element_id,
         level_type,
         layer_cost,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date)
     select
         i_layer_id,
         l_inv_layer_id,
         1,
         1,
         0,
         sysdate,
         i_user_id,
         sysdate,
         i_user_id,
         i_login_id,
         i_req_id,
         i_prg_appl_id,
         i_prg_id,
         sysdate
     from dual;


  end if;  /* if no layer exists */



return l_inv_layer_id;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLENG.get_current_layer:' || substrb(SQLERRM,1,150);
    return 0;

END get_current_layer;

----------------------------------------------------------------------------
--  layer_cost_det_move
--      This procedure inserts into MCTCD for Layer Cost Update through
--   open interface
----------------------------------------------------------------------------
procedure layer_cost_det_move (
  i_txn_id                  in number,
  i_txn_interface_id        in number,
  i_txn_action_id           in number,
  i_org_id                  in number,
  i_item_id                 in number,
  i_cost_group_id           in number,
  i_inv_layer_id            in number,
  i_txn_cost                in number,
  i_new_avg_cost            in number,
  i_per_change              in number,
  i_val_change              in number,
  i_mat_accnt               in number,
  i_mat_ovhd_accnt          in number,
  i_res_accnt               in number,
  i_osp_accnt               in number,
  i_ovhd_accnt              in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  l_num_detail              number;
  l_layer_id                number;
  cost_det_move_error       EXCEPTION;
  cost_no_layer_error       EXCEPTION;
begin
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  SELECT count(*)
  INTO   l_num_detail
  FROM   MTL_TXN_COST_DET_INTERFACE
  WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  /*  l_num_detail = 0  : No corresponding rows in MTL_TXN_COST_DET_INTERFACE
   *                      OR i_txn_interface_id is null.
   *  In this case, call cstpacit.cost_det_new_insert.
   */

  if (l_num_detail = 0) then
    cstpleng.layer_cost_det_new_insert(i_txn_id, i_txn_action_id, i_org_id,
                                 i_item_id, i_cost_group_id, i_inv_layer_id, i_txn_cost,
                                 i_new_avg_cost, i_per_change, i_val_change,
                                 i_mat_accnt, i_mat_ovhd_accnt, i_res_accnt,
                                 i_osp_accnt, i_ovhd_accnt,
                                 i_user_id, i_login_id, i_request_id,
                                 i_prog_appl_id, i_prog_id,
                                 l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
        raise cost_det_move_error;
  end if;

  else

 l_layer_id := cstpaclm.layer_det_exist(i_org_id, i_item_id, i_cost_group_id,
                                         l_err_num, l_err_code, l_err_msg);

  if (l_err_num <> 0) then
        raise cost_no_layer_error;
  end if;

  if (l_layer_id <> 0) then

    INSERT INTO MTL_CST_TXN_COST_DETAILS (
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
      i_item_id,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      LAYER_COST,
      LAYER_COST,
      NULL,
      NULL,
     sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
    FROM CST_INV_LAYER_COST_DETAILS CILCD
    WHERE CILCD.LAYER_ID = l_layer_id
    AND   CILCD.INV_LAYER_ID = i_inv_layer_id;

UPDATE MTL_CST_TXN_COST_DETAILS mctcd
set (VALUE_CHANGE,
    PERCENTAGE_CHANGE,
    NEW_AVERAGE_COST)
=
(select
 mtcdi.VALUE_CHANGE,
 mtcdi.PERCENTAGE_CHANGE,
 mtcdi.NEW_AVERAGE_COST
 from MTL_TXN_COST_DET_INTERFACE mtcdi
 where mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id
 and mctcd.transaction_id = i_txn_id
 and mtcdi.level_type = mctcd.level_type
 and mtcdi.cost_element_id = mctcd.cost_element_id
)
where
mctcd.transaction_id = i_txn_id
and exists (select 1
            from MTL_TXN_COST_DET_INTERFACE mtcdi
            where mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id
            and mtcdi.level_type = mctcd.level_type
            and mtcdi.cost_element_id = mctcd.cost_element_id);

else

/* No layer exists , hence use THIS level MATERIAL row */

INSERT INTO MTL_CST_TXN_COST_DETAILS (
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
    values (
      i_txn_id,
      i_org_id,
      i_item_id,
      1,                        /* Hard coded to This level Material */
      1,
      i_txn_cost,
      i_new_avg_cost,
      i_per_change,
      i_val_change,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate);


  end if; /* if layer exists */

end if; /* if l_num_detail = 0 */

EXCEPTION
  when cost_det_move_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPLENG.LAYER_COST_DET_MOVE:' || l_err_msg;
  when cost_no_layer_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPLENG.LAYER_COST_DET_MOVE: No layer exists' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLENG.LAYER_COST_DET_MOVE:' || substr(SQLERRM,1,150);

end layer_cost_det_move;

--------------------------------------------------------------------------
--  PROCEDURE layer_cost_det_new_insert
--     procedure used by layer cost update through open interface
--------------------------------------------------------------------------
procedure layer_cost_det_new_insert (
  i_txn_id                  in number,
  i_txn_action_id           in number,
  i_org_id                  in number,
  i_item_id                 in number,
  i_cost_group_id           in number,
  i_inv_layer_id            in number,
  i_txn_cost                in number,
  i_new_avg_cost            in number,
  i_per_change              in number,
  i_val_change              in number,
  i_mat_accnt               in number,
  i_mat_ovhd_accnt          in number,
  i_res_accnt               in number,
  i_osp_accnt               in number,
  i_ovhd_accnt              in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);

  cl_item_cost              number;
  cost_element_count        number;

  l_cost_elmt_id            number;
  l_layer_id                number;
  cil_layer_cost            number;
  cost_det_new_insert_error EXCEPTION;


  cursor cost_elmt_ids is
    SELECT CILCD.COST_ELEMENT_ID
    FROM   CST_INV_LAYERS CIL,
           CST_INV_LAYER_COST_DETAILS CILCD
    WHERE  CIL.LAYER_ID = l_layer_id
    AND    CIL.INV_LAYER_ID = i_inv_layer_id
    AND    CILCD.LAYER_ID = l_layer_id
    AND    CILCD.INV_LAYER_ID = i_inv_layer_id;


begin
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_layer_id := cstpaclm.layer_det_exist(i_org_id, i_item_id, i_cost_group_id,
                                         l_err_num, l_err_code, l_err_msg);

  if (l_err_num <> 0) then
        raise cost_det_new_insert_error;
  end if;

  /*  If layer detail exist, then calculate proportional costs and
   *  insert each elements into MTL_CST_TXN_COST_DETAILS.
   */

  if (l_layer_id <> 0) then

    if (i_txn_action_id = 24) then
      -- checking the existence of accounts for layer cost update case
      open cost_elmt_ids;

      loop
        fetch cost_elmt_ids into l_cost_elmt_id;
        exit when cost_elmt_ids%NOTFOUND;

        if ((l_cost_elmt_id = 1 and i_mat_accnt is null) or
            (l_cost_elmt_id = 2 and i_mat_ovhd_accnt is null) or
            (l_cost_elmt_id = 3 and i_res_accnt is null) or
            (l_cost_elmt_id = 4 and i_osp_accnt is null) or
            (l_cost_elmt_id = 5 and i_ovhd_accnt is null)) then
          -- Error occured

          FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
          l_err_code := 'Invalid accounts.';
          l_err_msg := FND_MESSAGE.Get;
          l_err_num := 999;

          raise cost_det_new_insert_error;
        end if;


      end loop;
    end if;

    SELECT LAYER_COST
    INTO cil_layer_cost
    FROM CST_INV_LAYERS
    WHERE LAYER_ID = l_layer_id
    AND   INV_LAYER_ID = i_inv_layer_id;

    /* for the case of layer cost equal zero */
    /* split cost evenly among cost elements */

    if (cl_item_cost = 0) then
      SELECT count(COST_ELEMENT_ID)
      INTO cost_element_count
      FROM CST_INV_LAYER_COST_DETAILS
      WHERE LAYER_ID = l_layer_id
      AND   INV_LAYER_ID = i_inv_layer_id;
    end if;

      INSERT INTO MTL_CST_TXN_COST_DETAILS (
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
      i_item_id,
      CILCD.COST_ELEMENT_ID,
      CILCD.LEVEL_TYPE,
      DECODE(CIL.LAYER_COST, 0, i_txn_cost / cost_element_count,
      i_txn_cost * CILCD.LAYER_COST / CIL.LAYER_COST),
      DECODE(CIL.LAYER_COST, 0, i_new_avg_cost / cost_element_count,
      i_new_avg_cost * CILCD.LAYER_COST / CIL.LAYER_COST),
      i_per_change,
      DECODE(CIL.LAYER_COST, 0, i_val_change / cost_element_count,
      i_val_change * CILCD.LAYER_COST / CIL.LAYER_COST),
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
      FROM  CST_INV_LAYERS CIL, CST_INV_LAYER_COST_DETAILS CILCD
      WHERE CIL.LAYER_ID = l_layer_id
      AND   CIL.INV_LAYER_ID = i_inv_layer_id
      AND   CILCD.LAYER_ID = l_layer_id
      AND   CILCD.INV_LAYER_ID = i_inv_layer_id;

  /*  If layer detail does not exist, then insert a new row
   *  as a this level material.
   */
  else

    if (i_txn_action_id = 24 and i_mat_accnt is null) then
      -- Error occured only for layer cost update

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
      l_err_code := 'Invalid accounts.';
      l_err_msg := FND_MESSAGE.Get;
      l_err_num := 999;

      raise cost_det_new_insert_error;
    end if;


    INSERT INTO MTL_CST_TXN_COST_DETAILS (
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
    values (
      i_txn_id,
      i_org_id,
      i_item_id,
      1,                        /* Hard coded to This level Material */
      1,
      i_txn_cost,
      i_new_avg_cost,
      i_per_change,
      i_val_change,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate);

  end if;

EXCEPTION
  when cost_det_new_insert_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPLENG.LAYER_COST_DET_NEW_INSERT:' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLENG.LAYER_COST_DET_NEW_INSERT:' || substr(SQLERRM,1,150);

end layer_cost_det_new_insert;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   layer_cost_update_dist                                               --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is called by CSTPLCIN package for layer cost update   --
--  transaction, since distributions need o be done using layer cost      --
--  from MCLACD rather than MCLACD                                        --
--                                                                        --
-- PURPOSE:                                                               --
--   Post distributions into MTA for layer cost update transactions       --
--                                                                        --
-- PARAMETERS:                                                            --
--   all transaction related details                                      --
----------------------------------------------------------------------------
procedure layer_cost_update_dist(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_LAYER_ID		IN 	NUMBER,
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
  l_hook		NUMBER;
  l_item_id 		NUMBER;
  l_cost_grp_id	        NUMBER;
  l_txn_org_id		NUMBER;
  l_txn_src_id          NUMBER;
  l_txn_date		DATE;
  l_p_qty		NUMBER;
  l_subinv		VARCHAR2(10);
  l_qty_adj		NUMBER;
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
  l_enc_rev	NUMBER;
  l_enc_amount	NUMBER;
  l_enc_acct	NUMBER;
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
  l_avg_cost_var_acct   NUMBER;
  /*LCM*/
  l_onhand_var NUMBER;
  l_onhand_var_acct  NUMBER;

  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_stmt_num	NUMBER;
  process_error	EXCEPTION;
  no_acct_error EXCEPTION;
  no_txn_det_error EXCEPTION;

BEGIN
  -- initialize local variables
  l_ele_exist := 0;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 1;
    l_hook := CSTPACHK.cost_dist_hook(i_org_id,
			i_txn_id,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);

  -- If the user choose to do distribution then we are done!
  if (l_hook = 1) then
    return;
  end if;

  -- Populate local variables

  l_stmt_num := 2;
  select
        inventory_item_id, organization_id,
	nvl(cost_group_id,1),
        transaction_date,
        primary_quantity, subinventory_code,
        quantity_adjusted,
        nvl(transaction_source_id,-1),
        nvl(distribution_account_id,-1),
        nvl(material_account, -1), nvl(material_overhead_account, -1),
	nvl(resource_account, -1), nvl(outside_processing_account, -1),
	nvl(overhead_account, -1),
	nvl(encumbrance_account, -1), nvl(encumbrance_amount, 0),
        currency_code,
        nvl(currency_conversion_date,transaction_date),
        nvl(currency_conversion_rate,-1) , currency_conversion_type,
	nvl(expense_account_id,-1)
  into
	l_item_id,
	l_txn_org_id,
	l_cost_grp_id,
	l_txn_date,
	l_p_qty,
	l_subinv,
	l_qty_adj,
	l_txn_src_id,
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
	l_onhand_var_acct
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  l_stmt_num := 3;
  select decode(encumbrance_reversal_flag,1,1,2,0,0)
  into   l_enc_rev
  from   mtl_parameters
  where  organization_id = i_org_id;

  l_stmt_num := 4;

  select ledger_id
  into l_sob_id
  from cst_acct_info_v
  where organization_id = i_org_id;

  l_stmt_num := 5;
  select currency_code
  into l_pri_curr
  from gl_sets_of_books
  where set_of_books_id = l_sob_id;

  l_stmt_num := 6;
  if (l_alt_curr is not NULL and l_conv_rate = -1) then
    if (l_alt_curr <> l_pri_curr) then

      if (l_conv_type is NULL) then
        FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_conv_type);
      end if;

      l_stmt_num := 7;

      l_conv_rate := gl_currency_api.get_rate(l_sob_id,l_alt_curr,l_txn_date,
					   l_conv_type);
    end if;
  end if;

  l_stmt_num := 8;

  BEGIN
   IF l_cost_grp_id <> 1 THEN
   SELECT
     nvl(material_account,-1),
     nvl(material_overhead_account,-1),
     nvl(resource_account,-1),
     nvl(outside_processing_account,-1),
     nvl(overhead_account,-1),
     nvl(average_cost_var_account,-1)
   INTO
     l_inv_mat_acct,
     l_inv_mat_ovhd_acct,
     l_inv_res_acct,
     l_inv_osp_acct,
     l_inv_ovhd_acct,
     l_avg_cost_var_acct
   FROM
     CST_COST_GROUP_ACCOUNTS
   WHERE
       ORGANIZATION_ID = i_org_id
   AND COST_GROUP_ID   = l_cost_grp_id;

   ELSE
     SELECT
       nvl(MATERIAL_ACCOUNT, -1),
       nvl(MATERIAL_OVERHEAD_ACCOUNT, -1),
       nvl(RESOURCE_ACCOUNT, -1),
       nvl(OVERHEAD_ACCOUNT, -1),
       nvl(OUTSIDE_PROCESSING_ACCOUNT, -1),
       nvl(AVERAGE_COST_VAR_ACCOUNT, -1)
     INTO
       l_inv_mat_acct,
       l_inv_mat_ovhd_acct,
       l_inv_res_acct,
       l_inv_ovhd_acct,
       l_inv_osp_acct,
       l_avg_cost_var_acct
     FROM
       MTL_PARAMETERS
     WHERE
       ORGANIZATION_ID = i_org_id;
   END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise no_acct_error;
  END;

  l_stmt_num := 20;

  select count(*)
  into l_ele_exist
  from mtl_cst_actual_cost_details
  where transaction_id = i_txn_id
  and organization_id = i_org_id;

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

 -- Layer cost update has been designed along the same lines as average
 -- cost update. However, since prior_cost column in MCACD is populated as
 -- the current average cost of the item across all inventory layers, the
 -- layer cost update distribution should be based on MCLACD rather than MCACD
 -- Based on this the accounting rules are :
 --
 -- 	Adjustment acct 	(layer_cost - actual_cost) * Qty - Variance
 --	Inventory		(actual_cost - layer_cost) * Qty
 -- 	Variance Acct		 Variance
 -- All these value are based on MCLACD.


  FOR cost_element IN 1..5 loop
    l_cost := NULL;
    -- The difference between new cost and prior cost is the impact to
    -- inventory. If new cost is higher then it's a debit to inventory
    -- else it is a credit to inventory.

    l_stmt_num := 30;

    select (sum(actual_cost) - sum(layer_cost)),sum(variance_amount),
           sum(onhand_variance_amount)
    into l_cost,l_var,l_onhand_var
    from mtl_cst_layer_act_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and cost_element_id = cost_element;

     /*ADDED 'l_cost_grp_id' FOR #BUG8881927*/
    if (l_cost is not NULL ) then
      -- First post to inventory.
     IF (l_cost <> 0) THEN
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign(l_cost), 1,
				cost_element, NULL, NULL,
				0, NULL, l_err_num, l_err_code,
				l_err_msg,l_cost_grp_id);

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

      CSTPACDP.insert_account(i_org_id, i_txn_id, l_item_id, l_qty_adj * l_cost,
		sign(l_qty_adj * l_cost) * abs(l_qty_adj)/*modified for bug #4005770*/ /*l_qty_adj*/, l_acct, l_sob_id, 1,
		cost_element, NULL,
		l_txn_date, l_txn_src_id, 15,
		l_pri_curr, l_alt_curr, l_conv_date, l_conv_rate, l_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;
      END IF;
      -- Second post to adjustment.
      if (l_cost <> 0 OR l_var <> 0 OR l_onhand_var <> 0) then
      l_cost := -1 * l_cost;
       /*ADDED 'l_cost_grp_id' FOR #BUG8881927*/
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
				sign((l_qty_adj * l_cost) - l_var - l_onhand_var), 2,
				cost_element, NULL, NULL,
				0, NULL, l_err_num, l_err_code,
				l_err_msg,l_cost_grp_id);
	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;

      l_stmt_num := 50;

/* Added the decode for BUG: 1107767. Avg cost update through the interface needs all the accounts
   in MMT to be specified, even if only the material cost element is getting affected */

      if (l_acct = -1) then
        select decode(cost_element, 1, l_mat_acct,
				  2, decode(l_mat_ovhd_acct,-1, l_mat_acct, l_mat_ovhd_acct),
                                  3, decode(l_res_acct,-1, l_mat_acct, l_res_acct),
				  4, decode(l_osp_acct,-1, l_mat_acct, l_osp_acct),
				  5, decode(l_ovhd_acct,-1, l_mat_acct, l_ovhd_acct))
        into l_acct
        from dual;
      end if;

      CSTPACDP.insert_account(i_org_id, i_txn_id, l_item_id, (l_qty_adj * l_cost) - l_var - l_onhand_var,
		l_qty_adj, l_acct, l_sob_id, 2,
		cost_element, NULL,
		l_txn_date, l_txn_src_id, 15,
		l_pri_curr, l_alt_curr, l_conv_date, l_conv_rate, l_conv_type,
		1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
		l_err_num, l_err_code, l_err_msg);

	-- check error
         if (l_err_num<>0) then
         raise process_error;
         end if;
     end if;
     if (l_onhand_var <> 0) then
      /*ADDED 'l_cost_grp_id' FOR #BUG8881927*/
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
                                sign(l_onhand_var), 20,
                                cost_element, NULL, NULL,
                                0, NULL, l_err_num, l_err_code,
                                l_err_msg,l_cost_grp_id);

          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

    if (l_acct = -1) then
      l_acct := l_onhand_var_acct;
    end if;

    CSTPACDP.insert_account(i_org_id, i_txn_id, l_item_id, l_onhand_var,
                l_qty_adj, l_acct, l_sob_id, 20,
                cost_element, NULL,
                l_txn_date, l_txn_src_id, 15,
                l_pri_curr, l_alt_curr, l_conv_date, l_conv_rate, l_conv_type,
                1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
                l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

      end if;

    end if;
  end loop;


 -- Now Post one consolidated variance entry

  l_stmt_num := 60;

  select nvl(sum(variance_amount),0)
  into l_var
  from mtl_cst_actual_cost_details cacd
  where transaction_id = i_txn_id
  and organization_id = i_org_id;

  if (l_var <> 0) then
       /*ADDED 'l_cost_grp_id' FOR #BUG8881927*/
      l_acct := CSTPACHK.get_account_id(i_org_id, i_txn_id,
                                sign(l_var), 13,
                                NULL, NULL, NULL,
                                0, NULL, l_err_num, l_err_code,
                                l_err_msg,l_cost_grp_id);

          -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

    if (l_acct = -1) then
      l_acct := l_avg_cost_var_acct;
    end if;

    CSTPACDP.insert_account(i_org_id, i_txn_id, l_item_id, l_var,
                l_qty_adj, l_acct, l_sob_id, 13,
                NULL, NULL,
                l_txn_date, l_txn_src_id, 15,
                l_pri_curr, l_alt_curr, l_conv_date, l_conv_rate, l_conv_type,
                1,i_user_id, i_login_id, i_req_id, i_prg_appl_id,i_prg_id,
                l_err_num, l_err_code, l_err_msg);

      -- check error
      if(l_err_num<>0) then
      raise process_error;
      end if;

 end if;

 UPDATE mtl_cst_actual_cost_details
 SET transaction_costed_date = sysdate
 WHERE transaction_id = i_txn_id
 AND transaction_costed_date IS NULL;

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
 O_error_message := 'CSTPLENG.layer_cost_update_dist' || to_char(l_stmt_num) ||
                     substr(SQLERRM,1,180);

END layer_cost_update_dist;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   update_inv_layer_cost                                                --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is calld by the Define Items form (INVIDITM), to      --
-- set costs as zero, when an item is changed from asset to expense       --
--                                                                        --
-- PURPOSE:                                                               --
--   FIFO/LIFO layer cost processing for Oracle Applications Rel 11i.2    --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id          : organization ID                         --
--            i_item_id         : inventory_item_id for the item whose    --
--                                expense flag is changed                 --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE update_inv_layer_cost (i_org_id IN NUMBER,
                                i_item_id IN NUMBER,
                                i_userid IN NUMBER,
                                i_login_id IN NUMBER)
IS

Begin
  update cst_inv_layers
  set last_updated_by = i_userid,
      last_update_date = sysdate,
      last_update_login = i_login_id,
      layer_cost = 0,
      burden_cost = 0,
      unburdened_cost = 0
  where organization_id = i_org_id
    and inventory_item_id = i_item_id;

  delete from cst_inv_layer_cost_details
  where inv_layer_id IN (select inv_layer_id
                         from cst_inv_layers
                         where organization_id = i_org_id
                          and inventory_item_id = i_item_id);
EXCEPTION
   when NO_DATA_FOUND then null;
End update_inv_layer_cost;


END CSTPLENG;

/
