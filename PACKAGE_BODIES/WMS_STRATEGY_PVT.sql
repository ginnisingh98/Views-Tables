--------------------------------------------------------
--  DDL for Package Body WMS_STRATEGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_STRATEGY_PVT" as
/* $Header: WMSVPPSB.pls 120.10.12010000.14 2010/05/06 11:17:33 abasheer ship $ */

  -- File        : WMSVPPSB.pls
  -- Content     : WMS_Strategy_PVT package body
  -- Description : W<S strategy private API's
  -- Notes       :
  -- Modified    : 02/08/99 mzeckzer created
  --             : 04/20/99 bitang   modified
  -- Modified    : 05/17/02 Grao
  -- Modified    : 05/12/05 Grao - [Added code to handle rule_id instead of strategy_id from
  --                               rules workbench ]
  -- Modified    : 09/06/2008 Kbanddyo - [Added call to procedure INV_Quantity_Tree_PVT. release_lock
  --                                      as part of bug fix 6867434]

  g_pkg_name constant varchar2(30) := 'WMS_Strategy_PVT';
  -- API versions called within WMS_Strategy_PVT.Apply API
  g_pp_rule_api_version  constant number := 1.0; -- WMS_Rule_PVT
  g_qty_tree_api_version constant number := 1.0; -- INV_Quantity_Tree_PVT

--Procedures for logging messages
PROCEDURE log_event(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN

  l_module := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
  inv_log_util.trace(p_message, l_module, 9);
  /*fnd_log.string(
         log_level      => FND_LOG.LEVEL_EVENT
        ,module         => l_module
        ,message        => p_message);
  inv_log_util.trace(p_message, l_module, 9);
  gmi_reservation_util.println(p_message); */
END log_event;

PROCEDURE log_error(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN

  l_module := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
  inv_log_util.trace(p_message, l_module, 9);
  /*
  fnd_log.string(
         log_level      => FND_LOG.LEVEL_ERROR
        ,module         => l_module
        ,message        => p_message);
  inv_log_util.trace(p_message, l_module, 9);
  gmi_reservation_util.println(p_label||' '||p_message); */
END log_error;

PROCEDURE log_error_msg(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN

  l_module := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message => 'Error in '||p_api_name,
                       p_module  => l_module,
                     p_level   => 9);
 /*
  fnd_log.message(
         log_level      => FND_LOG.LEVEL_ERROR
        ,module         => l_module
        ,pop_message    => FALSE);

  inv_log_util.trace(p_message => 'Error in '||p_api_name,
                     p_module  => l_module,
                     p_level   => 9);

    gmi_reservation_util.println(p_label); */
END log_error_msg;

PROCEDURE log_procedure(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN

  l_module := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
  inv_log_util.trace(p_message, l_module, 9);
  /*
  fnd_log.string(
         log_level      => FND_LOG.LEVEL_PROCEDURE
        ,module         => l_module
        ,message        => p_message);
  inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message);
    */
END log_procedure;

PROCEDURE log_statement(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_statement;

  -- Start of comments
  -- Name        : InitInput
  -- Function    : Initializes internal table of detail input records.
  --               Returns input header information.
  -- Pre-reqs    : none
  -- Parameters  :
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  --  p_transaction_temp_id        in  number   required
  --  p_type_code                  in  number   required
  --  x_organization_id            out number
  --  x_inventory_item_id          out number
  --  x_transaction_source_type_id out number
  --  x_transaction_source_id      out number
  --  x_trx_source_line_id         out number
  --  x_trx_source_delivery_id     out number
  --  x_transaction_source_name    out varchar2(30)
  --  x_tree_mode                  out number
  -- Notes       : privat procedure for internal use only
  -- End of comments

  procedure InitInput (
            x_return_status                out nocopy   varchar2
           ,x_msg_count                    out nocopy  number
           ,x_msg_data                     out nocopy  varchar2
           ,p_transaction_temp_id          in   number
           ,p_type_code                    in   number
           ,x_organization_id              out nocopy  number
           ,x_inventory_item_id            out nocopy  number
           ,x_transaction_uom              out nocopy  varchar2
           ,x_primary_uom                  out nocopy  varchar2
           ,x_secondary_uom                out nocopy  varchar2
           ,x_transaction_source_type_id   out nocopy  number
           ,x_transaction_source_id        out nocopy  number
           ,x_trx_source_line_id           out nocopy  number
           ,x_trx_source_delivery_id       out nocopy  number
           ,x_transaction_source_name      out nocopy  varchar2
           ,x_transaction_type_id	   out nocopy  number
           ,x_tree_mode                    out nocopy  number
                      ) is

    l_api_name             VARCHAR2(30) := 'InitInput';
    l_pp_transaction_temp_id
                           WMS_TRANSACTIONS_TEMP.PP_TRANSACTION_TEMP_ID%type;
    l_revision             WMS_TRANSACTIONS_TEMP.REVISION%type;
    l_lot_number           WMS_TRANSACTIONS_TEMP.LOT_NUMBER%type;
    l_lot_expiration_date  WMS_TRANSACTIONS_TEMP.LOT_EXPIRATION_DATE%type;
    l_from_subinventory_code WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%type;
    l_from_locator_id      WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%type;
    l_from_cost_group_id   WMS_TRANSACTIONS_TEMP.FROM_COST_GROUP_ID%type;
    l_to_subinventory_code WMS_TRANSACTIONS_TEMP.TO_SUBINVENTORY_CODE%type;
    l_to_locator_id        WMS_TRANSACTIONS_TEMP.TO_LOCATOR_ID%type;
    l_to_cost_group_id     WMS_TRANSACTIONS_TEMP.TO_COST_GROUP_ID%type;
    l_primary_quantity     WMS_TRANSACTIONS_TEMP.PRIMARY_QUANTITY%type;
    l_secondary_quantity   WMS_TRANSACTIONS_TEMP.SECONDARY_QUANTITY%type;
    l_grade_code           WMS_TRANSACTIONS_TEMP.GRADE_CODE%type;
    l_line_type_code       WMS_TRANSACTIONS_TEMP.LINE_TYPE_CODE%type;
    l_reservation_id       NUMBER;
    l_serial_number        WMS_TRANSACTIONS_TEMP.SERIAL_NUMBER%type;
    l_transaction_action_id Number;
    l_from_organization_id  NUMBER;
    l_to_organization_id    NUMBER;

    --- [ Added code - l_serial_number  WMS_TRANSACTIONS_TEMP.SERIAL_NUMBER; ]
    l_lpn_id		   NUMBER;

    l_debug               NUMBER;
    --use to_organization if put away, from_organization if pick
    -- 3/7/01 - changed query to get txn_source_id and txn_source_line_id
    -- instead of header_id and line_id
   /*  Bug #5265024
    CURSOR inphead IS
    SELECT decode(p_type_code, 1, mpsmttv.to_organization_id,
           mpsmttv.from_organization_id) organization_id
          ,mpsmttv.inventory_item_id
          ,mpsmttv.transaction_source_type_id
          ,mpsmttv.txn_source_id
          ,mpsmttv.txn_source_line_id
          ,mpsmttv.txn_source_line_detail
          ,mpsmttv.txn_source_name
          ,mpsmttv.transaction_type_id
          ,mpsmttv.transaction_uom
          ,msi.primary_uom_code
          ,msi.secondary_uom_code
      from mtl_system_items              msi
          ,wms_strategy_mat_txn_tmp_v mpsmttv
     where msi.organization_id         =
                       decode(p_type_code, 1, mpsmttv.to_organization_id,
                                mpsmttv.from_organization_id)
       and msi.inventory_item_id       = mpsmttv.inventory_item_id
       and mpsmttv.line_id             = p_transaction_temp_id
       and mpsmttv.type_code           = p_type_code; */

    CURSOR inphead1 IS
      select txn_source_id ,
      	   txn_source_line_id,
      	   txn_source_name,
      	   txn_source_line_detail
       from  wms_txn_context_temp wtct
    where line_id =  p_transaction_temp_id;


--changed by jcearley on 12/8/99 to order transfers in order of
--pick suggestions and put away suggestions
-- [ Added the following  code in the cursor inpline / serial allocation proj ]
    cursor inpline is
    select mptt.PP_TRANSACTION_TEMP_ID
          ,mptt.REVISION
          ,mptt.LOT_NUMBER
          ,mptt.LOT_EXPIRATION_DATE
          ,mptt.FROM_SUBINVENTORY_CODE
          ,mptt.FROM_LOCATOR_ID
          ,mptt.FROM_COST_GROUP_ID
          ,mptt.TO_SUBINVENTORY_CODE
          ,mptt.TO_LOCATOR_ID
          ,mptt.TO_COST_GROUP_ID
          ,mptt.primary_quantity
          ,mptt.secondary_quantity
          ,mptt.grade_code
          ,mptt.reservation_id
          ,mptt.serial_number   ---- [ Added code - ,mptt.serial_number ]
          ,mptt.lpn_id
      from WMS_TRANSACTIONS_TEMP mptt
     where mptt.TRANSACTION_TEMP_ID = p_transaction_temp_id
       and mptt.TYPE_CODE           = p_type_code
       and mptt.LINE_TYPE_CODE      = 1
     order by mptt.pp_transaction_temp_id
    ;



  begin
   IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    If (l_debug = 1) then
      log_procedure(l_api_name,'start', 'start InitInput');
    End if;
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;
    If l_debug = 1 THEN
       log_procedure(l_api_name,'start', 'p_type_code '||p_type_code);
       log_procedure(l_api_name,'start', 'p_transaction_temp_id '||p_transaction_temp_id);
    END IF;


    --- Added the following code as part bug fix 5265024 --
    -- Set and get the MO line values
    IF inv_cache.set_mol_rec(p_transaction_temp_id)  THEN
         x_transaction_type_id 	:= inv_cache.mol_rec.transaction_type_id;
         x_inventory_item_id 	:= inv_cache.mol_rec.inventory_item_id;
         x_transaction_source_type_id := inv_cache.mol_rec.transaction_source_type_id;

         l_transaction_action_id := inv_cache.mtt_rec.transaction_action_id;

         --- This code is added to handle direct-org xfers
         IF  l_transaction_action_id = 3 THEN
               l_to_organization_id   	:= inv_cache.mol_rec.to_organization_id;
         ELSE
               l_from_organization_id   := inv_cache.mol_rec.organization_id;
         END IF;

         IF p_type_code  = 1 AND  l_transaction_action_id = 3 THEN
            x_organization_id :=  l_to_organization_id;
         ELSE
            x_organization_id :=  l_from_organization_id;
         END IF;

         x_transaction_uom := inv_cache.mol_rec.uom_code;
         x_primary_uom := inv_cache.item_rec.primary_uom_code;
    	 x_secondary_uom := inv_cache.item_rec.secondary_uom_code ;

         open  inphead1;
         fetch inphead1 into
                 x_transaction_source_id,
	         x_trx_source_line_id,
	         x_transaction_source_name,
	         x_trx_source_delivery_id;
	 if inphead1%notfound then
	       If (l_debug = 1) then
	           log_event(l_api_name, 'no_input_head',
	                    'The general input information stored in ' ||
	                    'WMS_TXN_CONTEXT_TEMP could not be found. ' ||
	                    'Detailing will fail.');
	       End if;
	 end if;
	 close inphead1;


    END IF;
    If (l_debug = 1) then
	    log_statement(l_api_name, 'Detailing Header Values ', '-------------');
	    log_statement(l_api_name, 'l_transaction_action_id ', l_transaction_action_id);
	    log_statement(l_api_name, 'x_organization_id ', x_organization_id);
	    log_statement(l_api_name, 'x_transaction_type_id ', x_transaction_type_id);
	    log_statement(l_api_name, 'x_inventory_item_id ', x_inventory_item_id);
	    log_statement(l_api_name, 'x_transaction_source_type_id', x_transaction_source_type_id);
	    log_statement(l_api_name, 'x_transaction_source__id', x_transaction_source_id);
	    log_statement(l_api_name, 'x_trx_source_line_id', x_trx_source_line_id);
	    log_statement(l_api_name, 'x_transaction_source_name', x_transaction_source_name);
	    log_statement(l_api_name, 'x_trx_source_delivery_id' , x_trx_source_delivery_id );
	    log_statement(l_api_name, 'x_transaction_uom ', x_transaction_uom);
	    log_statement(l_api_name, 'x_primary_uom ' , x_primary_uom);
	    log_statement(l_api_name, 'x_transaction_source_name   ', x_transaction_source_name   );
    END IF;

    /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    --
    -- Get txn detail line input parameters

    -- Commented as a part of performance bug fix 5265024
    open inphead;
    fetch inphead into x_organization_id
                      ,x_inventory_item_id
                      ,x_transaction_source_type_id
                      ,x_transaction_source_id
                      ,x_trx_source_line_id
                      ,x_trx_source_delivery_id
                      ,x_transaction_source_name
                      ,x_transaction_type_id
                      ,x_transaction_uom
                      ,x_primary_uom
                      ,x_secondary_uom
                      ;
    if inphead%notfound then
       --close inphead;
       -- no need to raise error - instead, no lines will be detailed
       -- raise no_data_found;
       If (l_debug = 1) then
           log_event(l_api_name, 'no_input_head',
                    'The general input information stored in ' ||
                    'WMS_STRATEGY_MAT_TXN_TMP_V could not be found. ' ||
                    'Detailing will fail.');
       End if;
    end if;
    close inphead;
   */
    -- End of bug fix 5265024
   log_procedure(l_api_name,'start', 'got head ');
    -- Tree mode should be parameter for pp engine call ??!!
   -- ER 7307189 changes start
    /*
    if p_type_code = 2 then
       x_tree_mode := INV_Quantity_Tree_PVT.g_transaction_mode;
    else
      x_tree_mode := null;
    end if;
    */

    log_statement(l_api_name, 'x_transaction_source_type_id:-', x_transaction_source_type_id);
    log_statement(l_api_name, 'l_transaction_action_id:-', l_transaction_action_id);
    log_statement(l_api_name, 'p_type_code:-', p_type_code);

    if p_type_code= 2 and x_transaction_source_type_id=4 and l_transaction_action_id=2 then
       x_tree_mode  :=    INV_Quantity_Tree_PUB.g_no_lpn_rsvs_mode ;
    elsif p_type_code = 2 then
       x_tree_mode := INV_Quantity_Tree_PVT.g_transaction_mode;
    else
      x_tree_mode := null;
    end if;

    -- ER 7307189 changes end

    log_procedure(l_api_name,'start', 'tree mode '||x_tree_mode);
    -- Initialize input line PL/SQL table
    Wms_re_common_pvt.InitInputTable;

    -- Loop through txn detail line input parameters
    open inpline;
    while true loop
      fetch inpline into l_pp_transaction_temp_id
                        ,l_revision
                        ,l_lot_number
                        ,l_lot_expiration_date
                        ,l_from_subinventory_code
                        ,l_from_locator_id
                        ,l_from_cost_group_id
                        ,l_to_subinventory_code
                        ,l_to_locator_id
                        ,l_to_cost_group_id
                        ,l_primary_quantity
                        ,l_secondary_quantity
                        ,l_grade_code
                        ,l_reservation_id
                        ,l_serial_number  -- [ new code -- l_serial_number]
                        ,l_lpn_id;

     log_procedure(l_api_name,'start', 'inpline '||l_lot_number);

      exit when inpline%notfound;

      -- create a new input line record in the input line table
      Wms_re_common_pvt.InitInputLine ( l_pp_transaction_temp_id
                                      ,l_revision
                                      ,l_lot_number
                                      ,l_lot_expiration_date
                                      ,l_from_subinventory_code
                                      ,l_from_locator_id
                                      ,l_from_cost_group_id
                                      ,l_to_subinventory_code
                                      ,l_to_locator_id
                                      ,l_to_cost_group_id
                                      ,l_primary_quantity
                                      ,l_secondary_quantity
                                      ,l_grade_code
                                      ,l_reservation_id
                                      ,l_serial_number  -- [ new code -  serial_number]
                                      ,l_lpn_id
                                );
    end loop;
    close inpline;

/*  --no need to raise error - no lines will be detailed
    if Wms_re_common_pvt.GetCountInputLines = 0 then
      raise no_data_found;
    end if;

    --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    If (l_debug = 1) then
      log_procedure(l_api_name, 'end', 'End InitInput');
    End if;
  exception
    when others then
   /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       -- Note: in debug mode, later call to fnd_msg_pub.get will not get
       -- the message retrieved here since it is no longer on the stack
       inv_pp_debug.set_last_error_message(Sqlerrm);
       inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
       inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
    /* if inphead%isopen then
        close inphead;
      end if; */
      if inpline%isopen then
        close inpline;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
          log_error(l_api_name, 'error', 'Error in InitInput - ' ||x_msg_data);
      End if;

  end InitInput;

  -- Start of comments
  -- Name        : InitStrategyRules
  -- Function    : Initializes internal table of strategy members ( = rules ).
  -- Pre-reqs    : none
  -- Parameters  :
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  --  p_strategy_id                in  number   required
  -- Notes       : privat procedure for internal use only
  -- End of comments

  procedure InitStrategyRules (
            x_return_status                out NOCOPY  varchar2
           ,x_msg_count                    out NOCOPY  number
           ,x_msg_data                     out NOCOPY  varchar2
           ,p_strategy_id                  in   number
			      ) is

    l_api_name             VARCHAR2(30) := 'InitStrategyRules';
    l_rule_id         WMS_STRATEGY_MEMBERS.RULE_ID%type;
    l_partial_success_allowed_flag
                      WMS_STRATEGY_MEMBERS.PARTIAL_SUCCESS_ALLOWED_FLAG%type;
    l_rule_counter    integer;
    l_debug           NUMBER;

    l_over_alloc_mode	      NUMBER; -- 8809951
    l_tolerance	            NUMBER ;  -- 8809951
	--changed by jcearley on 12/8/99
	--rules assigned to strategies can now be disabled, so we
	--now have to check to make sure that all the rules are enabled
	--before we use them in the engine
    CURSOR rules IS
    SELECT wsm.rule_id
          ,wsm.partial_success_allowed_flag
	  ,NVL(wsb.over_allocation_mode, 1) ,wsb.tolerance_value
      FROM wms_strategy_members  wsm
          ,wms_strategies_b      wsb
	  ,wms_rules_b		 wrb
     WHERE wsm.strategy_id  = p_strategy_id
       AND wsb.strategy_id  = p_strategy_id
       AND wrb.rule_id 	    = wsm.rule_id
       AND wrb.enabled_flag = 'Y'
       AND wms_datecheck_pvt.date_valid (wsb.organization_id,
				      wsm.date_type_code,
				      wsm.date_type_from,
				      wsm.date_type_to,
				      wsm.effective_from,
				      wsm.effective_to) = 'Y'
      ORDER BY wsm.sequence_number;

  begin
    IF (g_debug IS  NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    If (l_debug = 1) then
      log_procedure(l_api_name, 'start', 'Start InitStrategyRules');
    End if;
    -- nothing to init if p_strategy_id is null (no rule detailing)
    IF p_strategy_id IS NULL THEN
       x_return_status := fnd_api.g_ret_sts_success;
       RETURN;
    END IF;
    /*--
    --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Initialize local input line counter
    l_rule_counter := 0;

    -- Initialize strategy members PL/SQL table
    Wms_re_common_pvt.InitRulesTable;
    -- 8809951 Added the IF condition.
    l_rule_counter := wms_cache.get_Strategy_from_cache(p_strategy_id,
					     x_return_status => x_return_status,
					     x_msg_count     => x_msg_count,
					     x_msg_data      => x_msg_data,
					     x_over_alloc_mode => l_over_alloc_mode,
					     x_tolerance     => l_tolerance);
    IF  (l_rule_counter > 0 ) THEN
	g_over_allocation_mode  := l_over_alloc_mode;
	g_tolerance_value	:= l_over_alloc_mode;

    ELSE
    -- Loop through strategy members
    open rules;
    while true loop
      fetch rules into l_rule_id
                      ,l_partial_success_allowed_flag
		      ,g_over_allocation_mode
                      ,g_tolerance_value;
      exit when rules%notfound;

      -- create a new record in the rule table
      Wms_re_common_pvt.InitRule (
                       l_rule_id
                      ,l_partial_success_allowed_flag
                      ,l_rule_counter
				 );
    end loop;
    close rules;
    END IF;

    if l_rule_counter = 0 then
      If (l_debug = 1) then
        log_event(l_api_name, 'no_rules', 'No rules enabled for ' ||
                          'strategy ' || p_strategy_id);
      End if;
      raise no_data_found;
    end if;
    /*
    --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    If (l_debug = 1) then
      log_procedure(l_api_name, 'end', 'End InitStrategyRules');
    End if;
    --g_debug := NULL;
  exception
    when others then
   /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       -- Note: in debug mode, later call to fnd_msg_pub.get will not get
       -- the message retrieved here since it is no longer on the stack
       inv_pp_debug.set_last_error_message(Sqlerrm);
       inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
       inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
      if rules%isopen then
        close rules;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

    If (l_debug = 1) then
      log_error(l_api_name, 'error', 'Error in InitStrategyRules - ' ||
		  x_msg_data);
    End if;
    --g_debug := NULL;

  end InitStrategyRules;

  -- Start of comments
  -- Name        : InitQtyTree
  -- Function    : Initializes quantity tree for picking and returns tree id.
  -- Pre-reqs    : none
  -- Parameters  :
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  --  p_organization_id            in  number   required
  --  p_inventory_item_id          in  number   required
  --  p_transaction_source_type_id in  number   required
  --  p_transaction_source_id      in  number   required
  --  p_trx_source_line_id         in  number   required
  --  p_trx_source_delivery_id     in  number   required
  --  p_transaction_source_name    in  varchar2 required
  --  p_tree_mode                  in  number   required
  --  x_tree_id                    out number
  -- Notes       : privat procedure for internal use only
  -- End of comments

  procedure InitQtyTree (
            x_return_status                out nocopy  varchar2
           ,x_msg_count                    out nocopy  number
           ,x_msg_data                     out nocopy  varchar2
           ,p_organization_id              in   number
           ,p_inventory_item_id            in   number
           ,p_transaction_source_type_id   in   number
	   ,p_transaction_type_id          in   number
           ,p_transaction_source_id        in   number
           ,p_trx_source_line_id           in   number
           ,p_trx_source_delivery_id       in   number
           ,p_transaction_source_name      in   varchar2
           ,p_tree_mode                    in   number
           ,x_tree_id                      out nocopy  number
                        ) is

    l_api_name            VARCHAR2(30) := 'InitQtyTree';
    l_rev_control_code    MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE%type;
    l_lot_control_code    MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE%type;
    l_ser_control_code    MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE%type;
    l_is_revision_control boolean;
    l_is_lot_control      boolean;
    l_is_serial_control   boolean;
    l_msg_data VARCHAR2(240);
    l_transaction_source_id NUMBER;
    l_trx_source_line_id NUMBER;
    l_lot_expiration_date DATE;
    l_debug              NUMBER;
    cursor iteminfo is
    select nvl(msi.REVISION_QTY_CONTROL_CODE,1)
          ,nvl(msi.LOT_CONTROL_CODE,1)
          ,nvl(msi.SERIAL_NUMBER_CONTROL_CODE,1)
      from MTL_SYSTEM_ITEMS msi
     where ORGANIZATION_ID   = p_organization_id
       and INVENTORY_ITEM_ID = p_inventory_item_id
    ;
  begin

    IF (g_debug IS   NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    If (l_debug = 1) then
      log_procedure(l_api_name, 'start', 'Start InitQtyTree');
    End if;
    /*--
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    open iteminfo;
    fetch iteminfo into l_rev_control_code
                       ,l_lot_control_code
                       ,l_ser_control_code;
    if iteminfo%notfound then
      close iteminfo;
      raise no_data_found;
    end if;
    close iteminfo;

    if l_rev_control_code = 1 then
      l_is_revision_control := false;
    else
      l_is_revision_control := true;
    end if;
    if l_lot_control_code = 1 then
      l_is_lot_control := false;
    else
      l_is_lot_control := true;
    end if;
    if l_ser_control_code = 1 then
      l_is_serial_control := false;
    else
      l_is_serial_control := true;
    end if;

    -- bug 2398927
    --if source type id is 13 (inventory), don't pass in the demand
    --source line and header info.  This info was causing LPN putaway
    -- to fall for unit effective items.
    --l_lot_expiration_date := SYSDATE; commented 9313649,added below IF block
    IF INV_PICK_RELEASE_PUB.g_pick_expired_lots THEN
        l_lot_expiration_date := NULL;
        log_event(l_api_name, 'before create_tree','g_pick_expired_lots TRUE');
    ELSE
        l_lot_expiration_date := SYSDATE;
        log_event(l_api_name, 'before create_tree','g_pick_expired_lots FALSE');
    END IF;

    IF p_transaction_source_type_id IN (4,13) THEN
      l_transaction_source_id := -9999;
      l_trx_source_line_id := -9999;
     IF  p_transaction_source_type_id = 4 AND  p_transaction_type_id =64 THEN
 	             l_lot_expiration_date := NULL;
      END IF;
    ELSE
      l_transaction_source_id := p_transaction_source_id;
      l_trx_source_line_id := p_trx_source_line_id;
    END IF;

    If (l_debug = 1) then
      log_event(l_api_name, 'create_tree',
	        'Trying to create quantity tree in exclusive mode');
    End if;

    INV_Quantity_Tree_PVT.Create_Tree
        (
          p_api_version_number              => g_qty_tree_api_version
          --,p_init_msg_list                => fnd_api.g_false
          ,x_return_status                  => x_return_status
          ,x_msg_count                      => x_msg_count
          ,x_msg_data                       => x_msg_data
          ,p_organization_id                => p_organization_id
          ,p_inventory_item_id              => p_inventory_item_id
          ,p_tree_mode                      => p_tree_mode
          ,p_is_revision_control            => l_is_revision_control
          ,p_is_lot_control                 => l_is_lot_control
          ,p_is_serial_control              => l_is_serial_control
          ,p_asset_sub_only                 => FALSE
          ,p_include_suggestion             => TRUE
          ,p_demand_source_type_id          => p_transaction_source_type_id
          ,p_demand_source_header_id        => l_transaction_source_id
          ,p_demand_source_line_id          => l_trx_source_line_id
          ,p_demand_source_name             => p_transaction_source_name
          ,p_demand_source_delivery         => p_trx_source_delivery_id
          ,p_lot_expiration_date            => l_lot_expiration_date --9156669
          ,p_onhand_source                  => inv_quantity_tree_pvt.g_all_subs
          ,p_exclusive                      => inv_quantity_tree_pvt.g_exclusive
          ,p_pick_release                   => inv_quantity_tree_pvt.g_pick_release_yes
          ,x_tree_id                        => x_tree_id
        );
    --
    If (l_debug = 1) then
      log_event(l_api_name, 'create_tree_finished',
	        'Created quantity tree in exclusive mode');
    End if;
   /* -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section */
    If (l_debug = 1) then
      log_procedure(l_api_name, 'end', 'End InitQtyTree');
    End if;
    --
exception
    when others then
  /*  --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       -- Note: in debug mode, later call to fnd_msg_pub.get will not get
       -- the message retrieved here since it is no longer on the stack
       inv_pp_debug.set_last_error_message(Sqlerrm);
       inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
       inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
      if iteminfo%isopen then
        close iteminfo;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
        log_error(l_api_name, 'error', 'Error in InitQtyTree - ' || x_msg_data);
      End if;
  end InitQtyTree;

  -- Start of comments
  -- Name        : FreeGlobals
  -- Function    : Frees internal tables of strategy members and detailed input
  --               records.
  -- Pre-reqs    : none
  -- Parameters  : none
  -- Notes       : privat procedure for internal use only
  -- End of comments

  procedure FreeGlobals is
    l_api_name             VARCHAR2(30) := 'FreeGlobals';
  begin
   /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    Wms_re_common_pvt.InitInputTable;
    Wms_re_common_pvt.InitRulesTable;
   /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
  end FreeGlobals;

  -- Start of comments
  -- API name    : Search
  -- Type        : Private
  -- Function    : Searches for a pick or put away strategy according to
  --               provided transaction/reservation input and set up strategy
  --               assignments to business objects.
  --               Calls stub procedure to search for strategy assignments in a
  --               customer-defined manner before actually following his own
  --               algorithm to determine the valid strategy.
  -- Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
  --                identified by parameters p_transaction_temp_id and
  --                p_type_code ( base table MTL_MATERIAL_TRANSACTIONS_TEMP )
  -- Parameters  :
  --  p_api_version          in  number   required
  --  p_init_msg_list        in  varchar2 optional default = fnd_api.g_false
  --  p_validation_level     in  number   optional default =
  --                                               fnd_api.g_valid_level_full
  --  x_return_status        out varchar2(1)
  --  x_msg_count            out number
  --  x_msg_data             out varchar2(2000)
  --  p_transaction_temp_id  in  number   required default = NULL
  --  p_type_code            in  number   required default = NULL
  --  x_strategy_id          out  number
  -- Version     :  Current version 1.0
  --
  --                    Changed ...
  --               Previous version
  --
  --                Initial version 1.0
  -- Notes       : calls stub procedure WMS_re_Custom_PUB.SearchForStrategy
  --               and API's of Wms_re_common_pvt
  -- End of comments

  procedure Search (
            p_api_version          in   number
           ,p_init_msg_list        in   varchar2 := fnd_api.g_false
           ,p_validation_level     in   number   := fnd_api.g_valid_level_full
           ,x_return_status        out  NOCOPY varchar2
           ,x_msg_count            out  NOCOPY number
           ,x_msg_data             out  NOCOPY varchar2
           ,p_transaction_temp_id  in   number   := NULL
           ,p_type_code            in   number   := NULL
           ,x_strategy_id          out  NOCOPY number
           ,p_organization_id      IN   NUMBER   DEFAULT NULL
    ) is

    -- API standard variables
    l_api_version                constant number       := 1.0;
    l_api_name                   constant varchar2(30) := 'Search';

    -- variables needed for validation
    l_dummy                      number;
    l_hierarchy                  number;

    -- variables needed for dynamic SQL
    l_select                     long                  := null;
    l_from                       long                  := null;
    l_where                      long                  := null;
    l_order_by			 long		       := null;
    l_stmt                       long                  := null;
    l_identifier                 varchar2(10);
    l_cursor                     integer;
    l_rows                       integer;

    -- other variables
    l_organization_id            MTL_PARAMETERS.ORGANIZATION_ID%type;
    l_object_id                  WMS_OBJECTS_B.OBJECT_ID%type;
    l_strat_asgmt_db_object_id   WMS_OBJECTS_B.STRAT_ASGMT_DB_OBJECT_ID%type;
    l_db_object_id               WMS_DB_OBJECTS.DB_OBJECT_ID%type;
    l_table_name                 WMS_DB_OBJECTS.TABLE_NAME%type;
    l_table_alias                WMS_DB_OBJECTS.TABLE_ALIAS%type;
    l_parent_table_alias         WMS_DB_OBJECTS.TABLE_ALIAS%type;
    l_parameter_type_code        WMS_PARAMETERS_B.PARAMETER_TYPE_CODE%type;
    l_column_name                WMS_PARAMETERS_B.COLUMN_NAME%type;
    l_expression                 WMS_PARAMETERS_B.EXPRESSION%type;
    l_data_type_code             WMS_PARAMETERS_B.DATA_TYPE_CODE%type;
    l_parent_parameter_type_code WMS_PARAMETERS_B.PARAMETER_TYPE_CODE%type;
    l_parent_column_name         WMS_PARAMETERS_B.COLUMN_NAME%type;
    l_parent_expression          WMS_PARAMETERS_B.EXPRESSION%type;
    l_parent_data_type_code      WMS_PARAMETERS_B.DATA_TYPE_CODE%type;
    l_left_part_conv_fct         varchar2(100);
    l_right_part_conv_fct        varchar2(100);
    l_search_type_code           NUMBER;
    l_join                       varchar2(400);
    l_last_object_found          BOOLEAN;
    l_pk1_value                  VARCHAR2(150);
    l_pk2_value                  VARCHAR2(150);
    l_pk3_value                  VARCHAR2(150);
    l_pk4_value                  VARCHAR2(150);
    l_pk5_value                  VARCHAR2(150);
    ---
    --
    --Bug # 2465807 / Grao - To handle  SO for Cost Group  Search Order (Item Type)

        l_table_alias_left                WMS_DB_OBJECTS.TABLE_ALIAS%type;

    -- cursor for getting actual inventory org to search for strategy
    cursor input is
    select decode(p_type_code, 1, mpsmttv.TO_ORGANIZATION_ID,
		mpsmttv.FROM_ORGANIZATION_ID) organization_id
      from WMS_STRATEGY_MAT_TXN_TMP_V mpsmttv
     where mpsmttv.LINE_ID    = p_transaction_temp_id
       and mpsmttv.TYPE_CODE  = p_type_code;

    --cursor for getting org for cost group search
    cursor cg_org is
    select organization_id
      from wms_cost_groups_input_v wcgiv
     where wcgiv.line_id = p_transaction_temp_id;


    -- cursor for hierarchy of possible strategy assignments
    --   use p_type_code, not l_search_type_code, since hierarchy is
    --   defined by users using form, which doesn't show strat search types
    cursor hierarchy is
    select mpo.OBJECT_ID
          ,mpo.STRAT_ASGMT_DB_OBJECT_ID
      from WMS_OBJECTS_B             mpo
          ,WMS_ORG_HIERARCHY_OBJS    mpoho
     where mpoho.ORGANIZATION_ID        = l_organization_id
       and mpoho.TYPE_CODE		= p_type_code
       and mpo.OBJECT_ID                = mpoho.OBJECT_ID
       and mpo.STRAT_ASGMT_DB_OBJECT_ID is not null
       and mpo.STRAT_ASGMT_LOV_SQL      is not null
     order by mpoho.SEARCH_ORDER;

    -- cursor for all DB objects needed to build strategy searching dynamic SQL
    cursor objects is
    select mpdo.DB_OBJECT_ID
          ,mpdo.TABLE_NAME
          ,mpdo.TABLE_ALIAS
      from WMS_DB_OBJECTS      mpdo
      where mpdo.db_object_id IN
        (SELECT mpdo.db_object_id
         FROM wms_db_objects mpdo
         WHERE mpdo.db_object_id = l_strat_asgmt_db_object_id
         UNION
         SELECT mpdop.parent_db_object_id
         FROM wms_db_objects_parents mpdop
	 WHERE mpdop.type_code = l_search_type_code
         Connect by mpdop.DB_OBJECT_ID   = prior mpdop.PARENT_DB_OBJECT_ID
         Start with mpdop.DB_OBJECT_ID = l_strat_asgmt_db_object_id AND
                    mpdop.type_code = l_search_type_code );

    -- cursor for join information regarding the actual and parent DB object
    --Bug # 2465807 / Grao - To handle  SO for Cost Group  Search Order (Item Type)
    --              Modified the cursor to get the parent table alias

    cursor conditions is
    select mpp.PARAMETER_TYPE_CODE
          ,mpp.COLUMN_NAME
          ,mpdop1.TABLE_ALIAS  --- added for CG
          ,mpp.EXPRESSION
          ,mpp.DATA_TYPE_CODE
          ,mppp.PARAMETER_TYPE_CODE
          ,mppp.COLUMN_NAME
          ,mppp.EXPRESSION
          ,mppp.DATA_TYPE_CODE
          ,mpdop.TABLE_ALIAS  -- alias n.a. for multi object based parameters
      from WMS_DB_OBJECTS      mpdop
          ,WMS_DB_OBJECTS      mpdop1  -- added for CG
          ,WMS_PARAMETERS_B    mppp
          ,WMS_PARAMETERS_B    mpp
          ,WMS_DB_OBJECT_JOINS mpdoj
     where mpdoj.DB_OBJECT_ID     = l_db_object_id
       and mpdoj.type_code 	  = l_search_type_code
       and mpp.PARAMETER_ID       = mpdoj.PARAMETER_ID
       and mppp.PARAMETER_ID      = mpdoj.PARENT_PARAMETER_ID
       and mpdop1.DB_OBJECT_ID    = mpp.DB_OBJECT_ID   --- Added for CG
       and mpdop.DB_OBJECT_ID (+) = mppp.DB_OBJECT_ID;
    --
    l_err VARCHAR2(240);
    l_pos NUMBER;
    l_strategy_id NUMBER;
    l_debug NUMBER;

  BEGIN
    IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
    l_debug := g_debug;
    --
    If (l_debug = 1) then
      log_procedure(l_api_name, 'start', 'Start Search');
    End if;
    /*-- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    -- Standard call to check for call compatibility
    if not fnd_api.compatible_api_call( l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- Initialize message list if p_init_msg_list is set to TRUE
    if fnd_api.to_boolean( p_init_msg_list ) then
      fnd_msg_pub.initialize;
    end if;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    if p_validation_level <> fnd_api.g_valid_level_none then
      if p_transaction_temp_id is null or
         p_transaction_temp_id = fnd_api.g_miss_num then
         fnd_message.set_name('WMS','WMS_TRX_REQ_LINE_ID_MISS');
         fnd_msg_pub.add;
         If (l_debug = 1) then
           log_error_msg(l_api_name, 'missing_txn_temp_id');
         End if;
         raise fnd_api.g_exc_unexpected_error;
      end if;
      if p_type_code is null or
               p_type_code = fnd_api.g_miss_num then
         fnd_message.set_name('WMS','WMS_STRA_TYPE_CODE_MISS');
         fnd_msg_pub.add;
         If (l_debug = 1) then
           log_error_msg(l_api_name, 'missing_type_code');
         End if;
         raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- get actual inventory org to search for strategy
    -- ( and by the way, validate pre-requisites )
    IF p_organization_id IS NULL THEN
      If p_type_code = 5 Then  --cost group engine
         open cg_org;
         fetch cg_org into l_organization_id;
         if cg_org%notfound then
           close cg_org;
           fnd_message.set_name('WMS','WMS_TRX_REQ_REC_NOTFOUND');
           fnd_msg_pub.add;
           If (l_debug = 1) then
              log_error_msg(l_api_name, 'missing_org_id_cg');
           End if;
           raise fnd_api.g_exc_unexpected_error;
         end if;
         close cg_org;
      Else -- pick/put strategy
         open input;
         fetch input into l_organization_id;
         if input%notfound then
           close input;
           fnd_message.set_name('WMS','WMS_TRX_REQ_REC_NOTFOUND');
           fnd_msg_pub.add;
           If (l_debug = 1) then
              log_error_msg(l_api_name, 'missing_org_id_pp');
           End if;
           raise fnd_api.g_exc_unexpected_error;
         end if;
         close input;
      End If;
    ELSE
      l_organization_id := p_organization_id;
    END IF;

    -- Call custom-specific strategy search stub procedure
    wms_re_Custom_PUB.SearchForStrategy (
                     p_init_msg_list
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data
                    ,p_transaction_temp_id
                    ,p_type_code
                    ,l_strategy_id
                    );
    -- leave the actual procedure, if stub procedure already found a strategy
    if    x_return_status = fnd_api.g_ret_sts_success then
      If (l_debug = 1) then
        log_event(l_api_name, 'custom_search',
                'Strategy found using custom strategy search function. ' ||
               'Strategy: ' || l_strategy_id);
      End if;
      x_strategy_id := l_strategy_id;
      return;
    -- leave the actual procedure, if stub procedure got an unexpected error
    elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    -- continue strategy search, if stub procedure didn't find strategy already
    elsif x_return_status = fnd_api.g_ret_sts_error then
      -- Re-Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
    -- every other return status seems to be unexpected: leave
    else
       fnd_message.set_name('WMS','WMS_INVALID_RETURN_STATUS');
       -- WMS_re_Custom_PUB.SearchForStrategy returned wrong status
       fnd_msg_pub.add;
       If (l_debug = 1) then
         log_error_msg(l_api_name, 'bad_return_status');
       End if;
       raise fnd_api.g_exc_unexpected_error;
    end if;

   --two different type codes at work here
   --p_type_code tells us which engine is calling this procedure
   --   1 or 2 means pick/put engine
   --   5 means cost group engine
   --l_search_type_code is the type_code used in the rules engine
   -- data repository to indicate which objects should be used for
   -- building sql statements.
   --   99 means pick/put strategy search
   --   98 means pick/put cost group search
   --Here, we need to set the l_search_type_code based on the p_type_code
   IF p_type_code = 5 THEN  --cost group
      l_search_type_code := 98;
   ELSE --p_type_code = 1 or 2 (pick/put)
      l_search_type_code := 99;
   END IF;

    -- Loop through the hierarchy of possible strategy assignments
    l_hierarchy := 0;
    open hierarchy;
    while true loop
      fetch hierarchy into l_object_id
                          ,l_strat_asgmt_db_object_id;
      exit when hierarchy%notfound;
      l_hierarchy := l_hierarchy + 1;
      If (g_debug = 1) then
        log_event(l_api_name, 'current_object',
              'Looking for strategy assigned to object_id ' || l_object_id);
      End if;

      -- -------------------------------------------------------------------- --
      -- BUILD DYNAMIC SQL TO FIND STRATEGY                                   --
      -- -------------------------------------------------------------------- --

      -- Initialize variables for dynamically bound input parameters
      inv_sql_binding_pvt.InitBindTables;

      -- Initialize 'where' and 'from' clause
      l_where  := null;
      l_from   := null;
      --indicates whether root of object tree was found
      l_last_object_found := FALSE;

      -- loop through all the DB objects necessary to build the dynamic SQL
      open objects;
      while true loop
        fetch objects into l_db_object_id
                          ,l_table_name
                          ,l_table_alias;
        exit when objects%notfound;

        -- Add DB object to 'from' clause
        if l_db_object_id = l_strat_asgmt_db_object_id then  -- 1st record
                    l_from  := 'from '||l_table_name||' '||l_table_alias|| '
                       '|| l_from;
        else
                    l_from  := l_from||','||l_table_name||' '||l_table_alias|| '
                       ';
        end if;

        -- Add static parts, when strategy assignment table arises
        if l_table_name = 'WMS_STRATEGY_ASSIGNMENTS' then

          -- Initialize 'select' clause
           l_select := 'select '||l_table_alias||'.STRATEGY_ID'|| '
              ,' || l_table_alias || '.PK1_VALUE ' || '
              ,' || l_table_alias || '.PK2_VALUE ' || '
              ,' || l_table_alias || '.PK3_VALUE ' || '
              ,' || l_table_alias || '.PK4_VALUE ' || '
              ,' || l_table_alias || '.PK5_VALUE ' || '
              ';
          -- add organization id, to search for assignments set up within the
          -- actual organization only
          -- Bug 1736590 - Need to look for strategies that are common to
          -- all orgs; added -1
          l_identifier := inv_sql_binding_pvt.InitBindVar(l_organization_id);
          l_where      := l_where||'and '||l_table_alias||
            '.ORGANIZATION_ID IN (' ||l_identifier|| ', -1)
               ';

          -- add object id restriction
          l_identifier := inv_sql_binding_pvt.InitBindVar(l_object_id);
          l_where      := l_where||'and '||l_table_alias||'.OBJECT_ID = '||
                          l_identifier|| '
                          ';

          -- add type code restriction
          l_identifier := inv_sql_binding_pvt.InitBindVar(p_type_code);
          l_where      := l_where||'and '||l_table_alias||
                          '.STRATEGY_TYPE_CODE = '||l_identifier|| '
                          ';

          -- add effective date restrictions
          l_where      := l_where
                          ||'and wms_datecheck_pvt.date_valid( '
                          ||l_table_alias||'.organization_id, '
                          ||l_table_alias||'.date_type_code, '
                          ||l_table_alias||'.date_type_from, '
                          ||l_table_alias||'.date_type_to, '
                          ||l_table_alias||'.effective_from, '
                          ||l_table_alias||'.effective_to) = ''Y'' '
                          ||' and (select wsbxyz.enabled_flag from wms_strategies_b wsbxyz where '
                          ||l_table_alias||'.strategy_id = wsbxyz.strategy_id) = ''Y'' ';

          --add order by for sequence number
          l_order_by := 'order by '
                        || l_table_alias || '.SEQUENCE_NUMBER';

        end if;

        -- join last DB object with Key Identifiers
        if l_db_object_id = 1000 then
          l_identifier := inv_sql_binding_pvt.InitBindVar(p_type_code);
          l_where :='and '||l_table_alias||'.TYPE_CODE = '||l_identifier||'
                        '||l_where;
          l_identifier:=inv_sql_binding_pvt.InitBindVar(p_transaction_temp_id);
          l_where  := 'where '||l_table_alias||'.LINE_ID = '||
                       l_identifier||'
                       '||l_where;
          l_last_object_found := TRUE;
        -- for cost groups
        elsif l_db_object_id = 40 then -- wms_cost_group_input_v
          l_identifier := inv_sql_binding_pvt.InitBindVar(p_transaction_temp_id);
          l_where      := 'where '||l_table_alias||'.LINE_ID = '||
                       l_identifier||'
                       '||l_where;
          l_last_object_found := TRUE;
        end if;
        -- loop through all the join conditions
        open conditions;
        while true loop
          fetch conditions into l_parameter_type_code
                               ,l_column_name
                               ,l_table_alias_left   --- Added for CG
                               ,l_expression
                               ,l_data_type_code
                               ,l_parent_parameter_type_code
                               ,l_parent_column_name
                               ,l_parent_expression
                               ,l_parent_data_type_code
                               ,l_parent_table_alias;
          exit when conditions%notfound;

          -- find out, if data type conversion is needed
          inv_sql_binding_pvt.GetConversionString ( l_data_type_code
                                                ,l_parent_data_type_code
                                                ,l_left_part_conv_fct
                                                ,l_right_part_conv_fct );

          -- add join conditions to 'where' clause ( in backward order )
          l_join   := l_right_part_conv_fct||'
                       ';
          if l_parent_parameter_type_code = 1 then
            l_join := l_parent_table_alias||'.'||l_parent_column_name
                    ||l_join;
          else
            l_join := l_parent_expression||l_join;
          end if;
          l_join   := ' = '||l_left_part_conv_fct||l_join;
          if    l_parameter_type_code = 1 then
             if (l_search_type_code = 98) then    --- Added for CG
                 l_join := l_table_alias_left||'.'||l_column_name||l_join;
             else
                 l_join := l_table_alias||'.'||l_column_name||l_join;
             end if;
          elsif l_parameter_type_code = 2 then
            l_join := l_expression||l_join;
          end if;
          l_where   := l_where || 'and '|| l_join;
        end loop;
        close conditions;
      end loop;
      close objects;
      if l_last_object_found = FALSE then
        close hierarchy;
        fnd_message.set_name('WMS','WMS_DB_OBJECT_CHAIN');
        -- Seed data corrupted: DB object chain
        fnd_msg_pub.add;
        If (g_debug = 1) then
          log_error_msg(l_api_name, 'bad_db_object_chain');
        End if;
        raise fnd_api.g_exc_unexpected_error;
      end if;

      -- ----------------------------------------------------------------
      -- EXECUTE DYNAMIC SQL TO FIND STRATEGY
      -- ----------------------------------------------------------------
      -- 1st step: assemble the SQL statement
      -- remark: ordering of records is not necessary, because one effective
      --         strategy of one type ( pick OR put away )is allowed per object
      --         only !
      l_stmt := l_select || l_from || l_where || l_order_by;
      --inv_pp_debug.send_long_to_pipe(l_stmt);
      If (g_debug = 1) then
        log_event(l_api_name, 'Dynamic SQL STMT for Stg Search Order', l_stmt);
      End if;

      --Wms_re_common_pvt.ShowSQL(l_stmt);
      inv_sql_binding_pvt.ShowBindVars;

      -- 2nd step: get a cursor and parse the SQL statement
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse( l_cursor, l_stmt, dbms_sql.native );

      -- 3rd step: bind input variables
      inv_sql_binding_pvt.BindVars(l_cursor);

      -- 4th step: define output column
      dbms_sql.define_column(l_cursor, 1, l_strategy_id);
      dbms_sql.define_column(l_cursor, 2, l_pk1_value,150);
      dbms_sql.define_column(l_cursor, 3, l_pk2_value,150);
      dbms_sql.define_column(l_cursor, 4, l_pk3_value,150);
      dbms_sql.define_column(l_cursor, 5, l_pk4_value,150);
      dbms_sql.define_column(l_cursor, 6, l_pk5_value,150);

      -- 5th step: execute the SQL statement and fetch one record
      l_rows := dbms_sql.execute_and_fetch(l_cursor, false);
      if l_rows = 0 then
        l_strategy_id := null;
      else
        dbms_sql.column_value(l_cursor, 1, l_strategy_id);
        dbms_sql.column_value(l_cursor, 2, l_pk1_value);
        dbms_sql.column_value(l_cursor, 3, l_pk2_value);
        dbms_sql.column_value(l_cursor, 4, l_pk3_value);
        dbms_sql.column_value(l_cursor, 5, l_pk4_value);
        dbms_sql.column_value(l_cursor, 6, l_pk5_value);
      end if;

      -- 6th step: finally, close dynamic cursor
      dbms_sql.close_cursor(l_cursor);

      -- interrupt the search, if a strategy was found
      exit when l_strategy_id is not null;
      If (g_debug = 1) then
        log_event(l_api_name, 'no_strat_found',
                 'No strategy found for this object');
      End if;
    end loop;
    close hierarchy;

    --commenting out exception calls;  if strategy can't be found,
    -- we don't want to raise error. calling function will have to
    -- use some sort of default.  We should create a log message, though.
    if l_hierarchy = 0 then
       fnd_message.set_name('WMS','WMS_SEARCH_ORDER_EMPTY');
       --inv_pp_debug.send_message_to_pipe('no search order defined for this org');
       -- Strategy search object hierarchy contains no entry
       --fnd_msg_pub.add;
       If (g_debug = 1) then
         log_event(l_api_name, 'no_hierarchy',
                 'No strategy search order defined for this organization');
       End if;
       --raise fnd_api.g_exc_error;
    end if;
    if l_strategy_id is null then
       fnd_message.set_name('WMS','WMS_NO_STRATEGY_ASSIGN');
    --   inv_pp_debug.send_message_to_pipe('no strategy assigned');
       --No active strategy assignment detected according to provided input
       --fnd_msg_pub.add;
       If (g_debug = 1) then
         log_event(l_api_name, 'no_strategy',
                    'The strategy search function failed to find a valid ' ||
                    'strategy.');
       End if;
       --raise fnd_api.g_exc_error;
       IF  p_type_code = 1 THEN
           wms_search_order_globals_pvt.g_putaway_strategy_id := -999;
       ELSIF p_type_code = 2 THEN
           wms_search_order_globals_pvt.g_pick_strategy_id := -999;
       ELSIF p_type_code = 5 THEN
           wms_search_order_globals_pvt.g_costgroup_strategy_id := -999;
       END IF;
    else
       If (g_debug = 1) then
         log_event(l_api_name, 'strategy_found',
                          'The strategy search function found a valid strategy. ' ||
                          'Strategy : '|| l_strategy_id);
       End if;
       -- Calls to populate globals used by Simulation form
       wms_engine_pvt.g_business_object_id := l_object_id;
       IF  p_type_code = 1 THEN
          wms_search_order_globals_pvt.g_putaway_business_object_id := l_object_id;
          wms_search_order_globals_pvt.g_putaway_strategy_id := l_strategy_id;
          wms_search_order_globals_pvt.g_putaway_pk1_value:= l_pk1_value;
          wms_search_order_globals_pvt.g_putaway_pk2_value:= l_pk2_value;
          wms_search_order_globals_pvt.g_putaway_pk3_value:= l_pk3_value;
          wms_search_order_globals_pvt.g_putaway_pk4_value:= l_pk4_value;
          wms_search_order_globals_pvt.g_putaway_pk5_value:= l_pk5_value;
       ELSIF p_type_code = 2 THEN
          wms_search_order_globals_pvt.g_pick_business_object_id := l_object_id;
          wms_search_order_globals_pvt.g_pick_strategy_id := l_strategy_id;
          wms_search_order_globals_pvt.g_pick_pk1_value:= l_pk1_value;
          wms_search_order_globals_pvt.g_pick_pk2_value:= l_pk2_value;
          wms_search_order_globals_pvt.g_pick_pk3_value:= l_pk3_value;
          wms_search_order_globals_pvt.g_pick_pk4_value:= l_pk4_value;
          wms_search_order_globals_pvt.g_pick_pk5_value:= l_pk5_value;
       ELSIF p_type_code = 5 THEN
          wms_search_order_globals_pvt.g_costgroup_business_object_id := l_object_id;
          wms_search_order_globals_pvt.g_costgroup_strategy_id := l_strategy_id;
          wms_search_order_globals_pvt.g_costgroup_pk1_value:= l_pk1_value;
          wms_search_order_globals_pvt.g_costgroup_pk2_value:= l_pk2_value;
          wms_search_order_globals_pvt.g_costgroup_pk3_value:= l_pk3_value;
          wms_search_order_globals_pvt.g_costgroup_pk4_value:= l_pk4_value;
          wms_search_order_globals_pvt.g_costgroup_pk5_value:= l_pk5_value;
       END IF;
    end if;
    x_strategy_id := l_strategy_id;
    -- Clean up variables for dynamically bound input parameters
    inv_sql_binding_pvt.InitBindTables;

    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get( p_count => x_msg_count
			       ,p_data  => x_msg_data );
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('strategy id found '||l_strategy_id);
    END IF;
    --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    If (g_debug = 1) then
      log_procedure(l_api_name, 'end', 'End Search');
    End if;

    g_debug := NULL;
    --
exception
     when fnd_api.g_exc_error then
        --
        -- debugging portion
        -- can be commented ut for final code
        IF inv_pp_debug.is_debug_mode THEN
           -- Note: in debug mode, later call to fnd_msg_pub.get will not get
           -- the message retrieved here since it is no longer on the stack
           inv_pp_debug.set_last_error_message(Sqlerrm);
           inv_pp_debug.set_last_error_position(dbms_sql.last_error_position);
           --changed by jcearley on 11/22/99 because call was causing error
           --   inv_pp_debug.set_last_dynamic_sql(l_stmt);
           inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
           inv_pp_debug.send_last_error_message;
           --   inv_pp_debug.send_last_dynamic_sql;
           inv_pp_debug.send_last_error_position;
        END IF;
        -- end of debugging section
        --
        inv_sql_binding_pvt.InitBindTables;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get( p_count => x_msg_count
           ,p_data  => x_msg_data );
        If (g_debug = 1) then
          log_error(l_api_name, 'error', 'Error in Search - ' || x_msg_data);
        End if;

        g_debug := NULL;

     when fnd_api.g_exc_unexpected_error then
        --
        -- debugging portion
        -- can be commented ut for final code
        IF inv_pp_debug.is_debug_mode THEN
           -- Note: in debug mode, later call to fnd_msg_pub.get will not get
           -- the message retrieved here since it is no longer on the stack
           inv_pp_debug.set_last_error_message(Sqlerrm);
           inv_pp_debug.set_last_error_position(dbms_sql.last_error_position);
           --   inv_pp_debug.set_last_dynamic_sql(l_stmt);
           inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
           inv_pp_debug.send_last_error_message;
           --   inv_pp_debug.send_last_dynamic_sql;
           inv_pp_debug.send_last_error_position;
        END IF;
        -- end of debugging section
        --
        inv_sql_binding_pvt.InitBindTables;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get( p_count => x_msg_count
           ,p_data  => x_msg_data );
                If (g_debug = 1) then
                  log_error(l_api_name, 'unexp_error',
                          'Unexpected error in Search - ' || x_msg_data);
                End if;
                g_debug := NULL;

     when others then
     --
     -- debugging portion
     -- can be commented ut for final code
     IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(Sqlerrm);
        inv_pp_debug.set_last_error_position(dbms_sql.last_error_position);
        --	   inv_pp_debug.set_last_dynamic_sql(l_stmt);
        inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
        inv_pp_debug.send_last_error_message;
        --	   inv_pp_debug.send_last_dynamic_sql;
        inv_pp_debug.send_last_error_position;
     END IF;
     -- end of debugging section
     --
     inv_sql_binding_pvt.InitBindTables;
     if input%isopen then
        close input;
     end if;
     if hierarchy%isopen then
        close hierarchy;
     end if;
     if objects%isopen then
        close objects;
     end if;
     if conditions%isopen then
        close conditions;
     end if;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
     If (g_debug = 1) then
          log_error(l_api_name, 'other_error',
                 'Other error in Search - ' || x_msg_data);
     End if;
     g_debug := NULL;
  end Search;

  -- Start of comments
-- Name        : Get_Max_Tolerance
  -- Function    : Gets the Max Tolerance value as well as sets the Min Qty that can be allocated against MO Line
  -- Pre-reqs    : none
  -- Parameters  :
  --  p_transaction_temp_id        in  number
  --  p_organization_id            in  number
  --  p_inventory_item_id          in  number
  --  p_trx_source_line_id         in  number
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  -- Notes       : private procedure for internal use only
  -- End of comments
  PROCEDURE get_max_tolerance(
    p_transaction_temp_id	IN NUMBER
  , p_organization_id	        IN NUMBER
  , p_inventory_item_id	        IN NUMBER
  , p_trx_source_line_id	IN NUMBER
  , x_max_tolerance	        OUT NOCOPY NUMBER
  , x_return_status	        OUT NOCOPY VARCHAR2
  , x_msg_count			OUT NOCOPY NUMBER
  , x_msg_data		        OUT NOCOPY NUMBER
  ) IS

  l_return_status    VARCHAR2(1);
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Max_Tolerance';
  l_debug            NUMBER := g_debug;
  l_allowed_flag     VARCHAR2(1);
  l_mo_quantity      NUMBER;
  l_quantity_to_pick NUMBER;
  l_max_quantity     NUMBER;
  l_other_alloc      NUMBER;
  l_cur_mo_alloc     NUMBER;
  l_max_possible_qty NUMBER;
  l_max_tolerance    NUMBER;
  l_avail_req_qty    NUMBER;

  BEGIN
    IF (l_debug = 1) THEN
        log_statement(l_api_name, 'Entering get_max_tolerance', '-------------------');
    END IF;
    l_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_mo_quantity    := WMS_Engine_PVT.g_mo_quantity;

    -- l_other_alloc is sum of allocation for all MO except current MO, with same p_trx_source_line_id
    SELECT NVL(SUM(transaction_quantity), 0)
    INTO   l_other_alloc
    FROM   mtl_material_transactions_temp
    WHERE  move_order_line_id <> p_transaction_temp_id
    AND    organization_id = p_organization_id
    AND    inventory_item_id = p_inventory_item_id
    AND    transaction_action_id = 28
    AND    trx_source_line_id = p_trx_source_line_id;

    -- l_quantity_to_pick is required by 'wsh_details_validations.check_quantity_to_pick' to decide if any more
    -- allocation is allowed or not and will return value of l_allowed_flag. This is not being used currently here.
    l_quantity_to_pick  := l_other_alloc + l_mo_quantity;

    /* Shipping API returns the following:
     l_max_quantity: Maximum quantity(including order line tolerance) that can be staged (e.g. 110 - already staged)
     l_avail_req_qty: Minimum quantity remaining to be staged to satify the actual sales order line quantity
     (e.g. 100 - already staged) */
    wsh_details_validations.check_quantity_to_pick
    (  p_order_line_id              => p_trx_source_line_id
     , p_quantity_to_pick           => l_quantity_to_pick
     , x_allowed_flag               => l_allowed_flag
     , x_max_quantity_allowed       => l_max_quantity
     , x_return_status              => l_return_status
     , x_avail_req_quantity         => l_avail_req_qty );
    IF (l_debug = 1) THEN
       log_statement(l_api_name, 'Return status from check_quantity_to_pick = ', l_return_status);
       log_statement(l_api_name, 'l_max_quantity ' , l_max_quantity);
       log_statement(l_api_name, 'l_avail_req_qty ', l_avail_req_qty);
    END IF;
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- l_cur_mo_alloc is any existing allocation for the current MO
    SELECT NVL(SUM(transaction_quantity), 0)
    INTO   l_cur_mo_alloc
    FROM   mtl_material_transactions_temp
    WHERE  move_order_line_id = p_transaction_temp_id;

    -- l_max_possible_qty is maximum quantity(including tolerance) that can be allocated
    -- l_other_alloc should never exceed l_max_quantity, however to be safe putting GREATEST
    l_max_possible_qty  := GREATEST(0, l_max_quantity - NVL(l_other_alloc,0));

    -- WMS_RULE_PVT.g_min_qty_to_allocate is minimum quantity remaining to be allocated to satisfy sales order line
    -- quantity. Loop in Rules will try to allocate till this or current MO quantity whichever is less and will
    -- exit if this quantity is allocated
    WMS_RULE_PVT.g_min_qty_to_allocate := GREATEST(0,l_avail_req_qty - NVL(l_other_alloc,0) - NVL(l_cur_mo_alloc, 0));

    -- l_max_tolerance is tolerance value for the current MO, however it will be set to zero if it is non-negative
    -- and Rule allocation mode does not allows it
    l_max_tolerance := l_max_possible_qty - l_mo_quantity;

    IF (l_debug = 1) THEN
       log_statement(l_api_name, 'l_mo_quantity ',         l_mo_quantity);
       log_statement(l_api_name, 'l_other_alloc ',         l_other_alloc);
       log_statement(l_api_name, 'l_cur_mo_alloc ',        l_cur_mo_alloc);
       log_statement(l_api_name, 'l_max_possible_qty ',    l_max_possible_qty);
       log_statement(l_api_name, 'g_min_qty_to_allocate ', WMS_RULE_PVT.g_min_qty_to_allocate);
       log_statement(l_api_name, 'l_max_tolerance ',       l_max_tolerance);
    END IF;

    x_return_status := l_return_status;
    x_max_tolerance := l_max_tolerance;

    IF (l_debug = 1) THEN
       log_statement(l_api_name, 'Exiting get_max_tolerance', '--------------------');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
  END get_max_tolerance;

  -- Start of comments
  -- API name    : Apply
  -- Type        : Private
  -- Function    : Applies a pick or put away strategy to the given transaction
  --               or reservation input parameters and creates recommendations
  -- Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
  --                identified by parameters p_transaction_temp_id and
  --                p_type_code ( base table MTL_MATERIAL_TRANSACTIONS_TEMP )
  --               at least one transaction detail record in
  --                WMS_TRX_DETAILS_TMP_V identified by line type code = 1
  --                and parameters p_transaction_temp_id and p_type_code
  --                ( base tables MTL_MATERIAL_TRANSACTIONS_TEMP and
  --                WMS_TRANSACTIONS_TEMP )
  --               strategy record in WMS_STRATEGIES_B uniquely identified by
  --                parameter p_strategy_id
  --               at least one strategy member record in
  --                WMS_STRATEGY_MEMBERS identified by parameter
  --                p_strategy_id
  -- Parameters  :
  --  p_api_version          in  number   required
  --  p_init_msg_list        in  varchar2 optional default = fnd_api.g_false
  --  p_commit               in  varchar2 optional default = fnd_api.g_false
  --  p_validation_level     in  number   optional default =
  --                                               fnd_api.g_valid_level_full
  --  x_return_status        out varchar2(1)
  --  x_msg_count            out number
  --  x_msg_data             out varchar2(2000)
  --  p_transaction_temp_id  in  number   required default = NULL
  --  p_type_code            in  number   required default = NULL
  --  p_strategy_id          in  number   required default = NULL
  -- ,p_quick_pick_flag      in   varchar2 default 'N'  The other value are  'Y' and 'Q'
  --                               'Y' is passed in patchset 'J' onwards for Inventory Moves
  --                                when the lpn_request_context is 1 and
  --                               'Q' is added to enable the functionality in 11.5.9 /'I'
  -- Version     :  Current version 1.0
  --
  --                    Changed ...
  --               Previous version
  --
  --                Initial version 1.0
  -- Notes       : calls API's of Wms_re_common_pvt, WMS_Rule_PVT
  --                and INV_Quantity_Tree_PVT
  --               This API must be called internally by
  --                WMS_Engine_PVT.Create_Suggestions only !
  -- End of comments

  procedure Apply (
            p_api_version          in   number
           ,p_init_msg_list        in   varchar2 := fnd_api.g_false
           ,p_commit               in   varchar2 := fnd_api.g_false
           ,p_validation_level     in   number   := fnd_api.g_valid_level_full
           ,x_return_status        out  NOCOPY varchar2
           ,x_msg_count            out  NOCOPY number
           ,x_msg_data             out  NOCOPY varchar2
           ,p_transaction_temp_id  in   number   := NULL
           ,p_type_code            in   number   := NULL
           ,p_strategy_id          in   number   := NULL
           ,p_rule_id              in   number   := NULL -- [ Added new column p_rule_id ]
           ,p_detail_serial        in   BOOLEAN  DEFAULT FALSE
           ,p_from_serial          IN   VARCHAR2 DEFAULT NULL
           ,p_to_serial            IN   VARCHAR2 DEFAULT NULL
           ,p_detail_any_serial    IN   NUMBER   DEFAULT NULL
           ,p_unit_volume          IN   NUMBER   DEFAULT NULL
           ,p_volume_uom_code      IN   VARCHAR2 DEFAULT NULL
           ,p_unit_weight          IN   NUMBER   DEFAULT NULL
           ,p_weight_uom_code      IN   VARCHAR2 DEFAULT NULL
           ,p_base_uom_code        IN   VARCHAR2 DEFAULT NULL
           ,p_lpn_id               IN   NUMBER   DEFAULT NULL
           ,p_unit_number          IN   VARCHAR2   DEFAULT NULL
           ,p_allow_non_partial_rules IN  BOOLEAN DEFAULT TRUE
           ,p_simulation_mode	   IN   NUMBER	 DEFAULT 0
           ,p_simulation_id	   IN   NUMBER   DEFAULT NULL
           ,p_project_id	   IN   NUMBER   DEFAULT NULL
           ,p_task_id		   IN   NUMBER   DEFAULT NULL
           ,p_quick_pick_flag      IN   VARCHAR2 DEFAULT 'N'
	   ,p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
                ) is

    -- API standard variables
    l_api_version       constant number       := 1.0;
    l_api_name          constant varchar2(30) := 'Apply';

    l_organization_id   MTL_MATERIAL_TRANSACTIONS_TEMP.ORGANIZATION_ID%type;
    l_inventory_item_id MTL_MATERIAL_TRANSACTIONS_TEMP.INVENTORY_ITEM_ID%type;
    l_line_type_code    WMS_TRANSACTIONS_TEMP.LINE_TYPE_CODE%type;
    l_transaction_uom   MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_UOM%type;
    l_primary_uom       MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%type;
    l_secondary_uom     VARCHAR2(3) ; -- MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE%type;
    l_grade_code        VARCHAR2(150);
    l_transaction_source_type_id
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_SOURCE_TYPE_ID%type;
    l_transaction_source_id
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_SOURCE_ID%type;
    l_trx_source_line_id
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRX_SOURCE_LINE_ID%type;
    l_trx_source_delivery_id
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRX_SOURCE_DELIVERY_ID%type;
    l_transaction_source_name
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_SOURCE_NAME%type;
    l_transaction_type_id
                 MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_TYPE_ID%type;

    l_rule_id           WMS_STRATEGY_MEMBERS.RULE_ID%type;
    l_partial_success_allowed_flag
                                WMS_STRATEGY_MEMBERS.PARTIAL_SUCCESS_ALLOWED_FLAG%type;
    l_finished                  VARCHAR2(1);
    l_tree_mode                 NUMBER;
    l_tree_id                   NUMBER;
    l_msg_data                  VARCHAR2(240);
    l_msg_count                 NUMBER;
    l_skip_rule                 VARCHAR2(1);
    l_simulation_mode           NUMBER;
    l_allow_non_partial_rules   BOOLEAN;

    --Aded bug3237702 caching
    l_req_locator_id               NUMBER;
    l_req_subinventory_code        MTL_MATERIAL_TRANSACTIONS_TEMP.SUBINVENTORY_CODE%type;
    is_pickrelease                 BOOLEAN;
    --Bug 3237702 ends

   -- Rules J Project Variables
   --

    l_current_release_level      NUMBER      :=  WMS_UI_TASKS_APIS.G_WMS_PATCH_LEVEL;
    l_j_release_level            NUMBER      :=  WMS_UI_TASKS_APIS.G_PATCHSET_J;
    l_quick_pick_flag            VARCHAR2(1);  -- 'J Project:This variable is used for QuickPick during Inventory Move
                                               --  Values 'Y' - Perform Quick Pick ,
                                               --         'N' - Do not call quick Pick
                                               --         'Q' - Perform Quick Pick for patset 'I' / Without Qty_tree validation
                                               --         for performance reasons
    l_qty_tree_allowed    VARCHAR2(1) := 'Y' ;
    l_debug               NUMBER ;

    -- [ Lot Indivisable Var
    l_lot_divisible_flag       VARCHAR2(1);
    l_lot_control_code         NUMBER;
    l_indiv_lot_allowed        VARCHAR2(1); -- [ Added ]
    l_max_tolerance 	       NUMBER;
    l_min_tolerance            NUMBER;

    --]

    -- [ 3.1.4	Inventory Allocation - Skipping Put away rules   ]
    l_wms_installed BOOLEAN;
    l_wms_enabled_flag VARCHAR2(1);
    l_over_allocation_mode NUMBER;
    l_tolerance_value      NUMBER;
     -- 8809951 modified the cursor
    CURSOR c_output_exists IS
       SELECT 'Y'
         FROM WMS_TRANSACTIONS_TEMP
              WHERE TYPE_CODE = p_type_code
                    AND LINE_TYPE_CODE = 2;

  begin
    IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    l_wms_installed := INV_CACHE.wms_installed;


    IF p_quick_pick_flag = 'Q' THEN
       l_qty_tree_allowed := 'N' ;
    ELSE
       l_qty_tree_allowed := 'Y' ;
    END IF;
    --
    If (l_debug = 1) then
      log_procedure(l_api_name, 'start', 'Start wms_strategy_pvt.Apply');
    End if;
    -- debugging portion
    -- can be commented ut for final code

    -- Bug 2286454
       l_allow_non_partial_rules := p_allow_non_partial_rules;

    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    --
    -- Standard start of API savepoint
    savepoint ApplyStrategySP;

    -- Standard call to check for call compatibility
    if not fnd_api.compatible_api_call( l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- Initialize message list if p_init_msg_list is set to TRUE
    if fnd_api.to_boolean( p_init_msg_list ) then
      fnd_msg_pub.initialize;
    end if;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Initialize functional return status to 'missing'
    --l_finished := fnd_api.g_miss_char; --bug 3673962
    l_finished := fnd_api.g_false; --bug3673962

    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    if p_validation_level <> fnd_api.g_valid_level_none then
      if p_transaction_temp_id is null or
         p_transaction_temp_id = fnd_api.g_miss_num
      then
         fnd_message.set_name('WMS','WMS_TRX_REQ_LINE_ID_MISS');
         -- Transaction input identifier required but not provided
         fnd_msg_pub.add;
         If (l_debug = 1) then
           log_error_msg(l_api_name,'missing_txn_temp_id');
         End if;
      raise fnd_api.g_exc_unexpected_error;
      end if;
      if p_type_code           is null or
         p_type_code           = fnd_api.g_miss_num
      then
         fnd_message.set_name('WMS','WMS_STRA_TYPE_CODE_MISS');
         -- Strategy type code required but not provided
         fnd_msg_pub.add;
         If (l_debug = 1) then
            log_error_msg(l_api_name,'missing_type_code');
         End if;
         raise fnd_api.g_exc_unexpected_error;
      end if;
      /*    Strategy Id is no longer required
      if p_strategy_id         is null or
         p_strategy_id         = fnd_api.g_miss_num  then
           fnd_message.set_name('WMS','WMS_STRATEGY_ID_MISSING');
        -- Strategy identifier required but not provided
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      end if;
     */
    end if;

    --Added for bug3237702
     -- Check whether this is a pick release process and if locator is specified
     If inv_cache.is_pickrelease then
        is_pickrelease := true;
        l_req_locator_id := inv_cache.tolocator_id;
        l_req_subinventory_code := inv_cache.tosubinventory_code;
     ELSIF p_wave_simulation_mode = 'Y' THEN
	l_req_locator_id := inv_cache.tolocator_id;
	l_req_subinventory_code := inv_cache.tosubinventory_code;
     End if;
     --bug3237702 ends

    -- make sure, everything is clean
    FreeGlobals;

    -- [ Initilizing the lot control valuse from cache
    l_lot_divisible_flag  	:= inv_cache.item_rec.lot_divisible_flag;
    l_lot_control_code    	:= inv_cache.item_rec.lot_control_code;
    -- ]

    --if simulation mode is put away rule, but we are doing picking,
    -- ignore simulation modea
    IF p_simulation_mode = 4 AND
       p_type_code = 2 THEN
       l_simulation_mode := 0;
    ELSE
       l_simulation_mode := p_simulation_mode;
    END IF;

    -- Initialize the internal input table
    InitInput ( x_return_status
               ,l_msg_count
               ,l_msg_data
               ,p_transaction_temp_id
               ,p_type_code
               ,l_organization_id
               ,l_inventory_item_id
               ,l_transaction_uom
               ,l_primary_uom
               ,l_secondary_uom
               ,l_transaction_source_type_id
               ,l_transaction_source_id
               ,l_trx_source_line_id
               ,l_trx_source_delivery_id
               ,l_transaction_source_name
               ,l_transaction_type_id
               ,l_tree_mode
              );
    if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
    end if;

    select NVL(WMS_ENABLED_FLAG, 'N') INTO l_wms_enabled_flag
    from mtl_parameters
    where ORGANIZATION_ID = l_organization_id;

    -- Build Qty Tree, if type_code = 2
    l_tree_id := null;
    if p_type_code = 2 and  l_qty_tree_allowed = 'Y'  THEN  -- Added for bug #4006426
      InitQtyTree ( x_return_status
                   ,l_msg_count
                   ,l_msg_data
                   ,l_organization_id
                   ,l_inventory_item_id
                   ,l_transaction_source_type_id
		   ,l_transaction_type_id
                   ,l_transaction_source_id
                   ,l_trx_source_line_id
                   ,l_trx_source_delivery_id
                   ,l_transaction_source_name
                   ,l_tree_mode
                   ,l_tree_id
                  );
      if x_return_status = fnd_api.g_ret_sts_unexp_error then
        raise fnd_api.g_exc_unexpected_error;
      elsif x_return_status = fnd_api.g_ret_sts_error then
        raise fnd_api.g_exc_error;
      end if;
    end if;
---

   /** J Project:If l_quick_pick_flag  equals to  'Y' and the type code is 'Pick',
       Call Quickpick() during the user initiated Moves moves for
       validations without actually calling the Picking rules engine  **/

       --trace(' ================== Before  entering p_quick_Pick_flag = Y  and p_type_code = 2 ') ;
       --trace ('p_quick_Pick_flag ' || p_quick_Pick_flag );
       --trace('p_type_code '|| p_type_code);

    log_event(l_api_name,'', 'before quick pick');
    IF  p_quick_pick_flag in ( 'Y', 'Q')  and p_type_code = 2 then  -- modified Bug #4006426

       If (l_debug = 1) then
             log_event(l_api_name, 'APPLY', 'WMS_RULES_PVT.Calling QuickPick() ');
       End if;
       WMS_Rule_PVT.QuickPick (
                   p_api_version            =>    g_pp_rule_api_version
                ,  p_init_msg_list          =>   fnd_api.g_false
                ,  p_commit                 =>   fnd_api.g_false
                ,  p_validation_level       =>   fnd_api.g_valid_level_full
                ,  x_return_status          =>   x_return_status
                ,  x_msg_count              =>   l_msg_count
                ,  x_msg_data               =>   l_msg_data
                ,  p_type_code              =>   p_type_code
                ,  p_transaction_temp_id    =>   p_transaction_temp_id
                ,  p_organization_id        =>   l_organization_id
                ,  p_inventory_item_id      =>   l_inventory_item_id
                ,  p_transaction_uom        =>   l_transaction_uom
                ,  p_primary_uom            =>   l_primary_uom
                ,  p_secondary_uom          =>   l_secondary_uom
                ,  p_grade_code             =>   l_grade_code
                ,  p_transaction_type_id    =>   l_transaction_type_id
                ,  p_tree_id                =>   l_tree_id
                ,  x_finished               =>   l_finished
                ,  p_detail_serial          =>   p_detail_serial
                ,  p_from_serial            =>   p_from_serial
                ,  p_to_serial              =>   p_to_serial
                ,  p_detail_any_serial      =>   p_detail_any_serial
                ,  p_unit_volume            =>   p_unit_volume
                ,  p_volume_uom_code        =>   p_volume_uom_code
                ,  p_unit_weight            =>   p_unit_weight
                ,  p_weight_uom_code        =>   p_weight_uom_code
                ,  p_base_uom_code          =>   p_base_uom_code
                ,  p_lpn_id                 =>   p_lpn_id
                ,  p_unit_number            =>   p_unit_number
                ,  p_simulation_mode        =>   p_simulation_mode
                ,  p_project_id             =>   p_project_id
                ,  p_task_id                =>   p_task_id
                );

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
       END IF;
    Else     ----  Patchset  H , I and non Invt. Moves
      log_event(l_api_name,'', 'no quick pick');
      -- Initialize the internal rules table
      InitStrategyRules ( x_return_status
                       ,l_msg_count
                       ,l_msg_data
                       ,p_strategy_id );

      if x_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
      elsif x_return_status = fnd_api.g_ret_sts_error then
          raise fnd_api.g_exc_error;
      end if;

    log_event(l_api_name,'', 'after init strategyrules ');

    -- Loop through all the rules, until all input lines are satisfied
    if l_debug = 1 THEN
       log_event(l_api_name,'', 'getcountinputlines '||wms_re_common_pvt.getcountinputlines);
    END IF;

    --- [ Lot Indiv  3.1.6 Indivisible Lot support
    ---   Getting the max and min tolerance  for lot_indivisable items and storing in global vars
    ---   to be used in wms_rules_pvt.Apply()
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'Calling get_tolerance()', '');
       log_statement(l_api_name, 'lot_divisible_flag',   l_lot_divisible_flag);
       log_statement(l_api_name, 'l_lot_control_code ',  l_lot_control_code );
    END IF;

    g_allocated_quantity := 0;
    l_over_allocation_mode := g_over_allocation_mode;
    l_tolerance_value := g_tolerance_value;

    WMS_RULE_PVT.g_max_tolerance := 0;
    WMS_RULE_PVT.g_over_allocation := 'N';

    IF l_lot_divisible_flag = 'N' and l_lot_control_code <> 1 and p_type_code = 2 THEN -- lot ctl and indivisible
	WMS_RULE_PVT.g_min_tolerance := 0;

       INV_Pick_Release_PVT.get_tolerance(p_mo_line_id    => p_transaction_temp_id,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          x_max_tolerance => l_max_tolerance,
                                          x_min_tolerance => l_min_tolerance );
       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'INV_Pick_Release_PVT.get_tolerance', 'Unexpected error in get_tolerance Call');
          END IF;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'INV_Pick_Release_PVT.get_tolerance', 'Error in get_tolerance Call');
          END IF;
       END IF;
       WMS_RULE_PVT.g_max_tolerance := l_max_tolerance;
       WMS_RULE_PVT.g_min_tolerance := l_min_tolerance;
    ELSIF p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 and l_wms_enabled_flag = 'Y' THEN
	 -- Though with constant tolerance over allocation will occur, but WMS_RULE_PVT.g_over_allocation = 'N'
         -- will show that get_max-tolerance was not called,which will decide EXIT condition in the loop in Rules API
	 IF l_over_allocation_mode = 3 THEN
    	    WMS_RULE_PVT.g_max_tolerance := (l_tolerance_value * WMS_Engine_PVT.g_mo_quantity)/100;
	    WMS_RULE_PVT.g_over_allocation := 'N';

	 ELSIF l_over_allocation_mode = 2 THEN
	       get_max_tolerance(
                                  p_transaction_temp_id	=> p_transaction_temp_id,
		                  p_organization_id     => l_organization_id,
		                  p_inventory_item_id	=> l_inventory_item_id,
		                  p_trx_source_line_id	=> l_trx_source_line_id,
		                  x_max_tolerance       => l_max_tolerance,
		                  x_return_status       => x_return_status,
                                  x_msg_count	        => x_msg_count,
                                  x_msg_data	        => x_msg_data
                         );
		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   IF l_debug = 1 THEN
		      log_statement(l_api_name, 'get_max_tolerance', 'Unexpected error in get_max_tolerance Call');
		   END IF;
		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		   IF l_debug = 1 THEN
		      log_statement(l_api_name, 'get_max_tolerance', 'Error in get_max_tolerance Call');
		   END IF;
		END IF;
		WMS_RULE_PVT.g_max_tolerance := l_max_tolerance;
		WMS_RULE_PVT.g_over_allocation := 'Y';

         ELSIF p_strategy_id IS NULL or  l_over_allocation_mode = 1 THEN
	 -- Querying all MO other than current MO line that have the same l_trx_source_line_id to see if any one
         -- then have been Over Allocated earlier. If so, then even though the current Strategy does not allow
         -- for Over Allocation, we need to consider the previous over allocated quantity and make sure we honor
         -- the tolerance limits
		BEGIN
			SELECT 'Y'
			INTO  WMS_RULE_PVT.g_over_allocation
			FROM mtl_txn_request_lines mtrl
			WHERE mtrl.txn_source_line_id = l_trx_source_line_id
				AND mtrl.LINE_ID <> p_transaction_temp_id
				AND mtrl.quantity_detailed IS NOT NULL
				AND mtrl.inventory_item_id = l_inventory_item_id
				AND mtrl.organization_id = l_organization_id
			HAVING sum(mtrl.quantity - Nvl(mtrl.quantity_delivered, 0)) <	(SELECT sum(Nvl(mmtt.transaction_quantity, 0))
																	FROM mtl_material_transactions_temp mmtt
																	WHERE mmtt.trx_source_line_id = l_trx_source_line_id
																		AND mmtt.move_order_line_id <> p_transaction_temp_id
																		AND mmtt.inventory_item_id = l_inventory_item_id
																		AND mmtt.organization_id = l_organization_id
																		AND mmtt.transaction_action_id = 28);
		EXCEPTION
	          WHEN NO_DATA_FOUND THEN
		       WMS_RULE_PVT.g_over_allocation := 'N';
		END;

		IF WMS_RULE_PVT.g_over_allocation = 'Y' THEN
		   get_max_tolerance(
		    		     p_transaction_temp_id	=> p_transaction_temp_id,
				     p_organization_id		=> l_organization_id,
				     p_inventory_item_id	=> l_inventory_item_id,
				     p_trx_source_line_id	=> l_trx_source_line_id,
				     x_max_tolerance		=> l_max_tolerance,
				     x_return_status		=> x_return_status,
				     x_msg_count	        => x_msg_count,
				     x_msg_data			=> x_msg_data
				     );
    		   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		      IF l_debug = 1 THEN
		         log_statement(l_api_name, 'get_max_tolerance', 'Unexpected error in get_max_tolerance Call');
		      END IF;
		   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
		      IF l_debug = 1 THEN
		         log_statement(l_api_name, 'get_max_tolerance', 'Error in get_max_tolerance Call');
		      END IF;
		   END IF;
		   IF l_max_tolerance < 0 THEN
		      WMS_RULE_PVT.g_max_tolerance := l_max_tolerance;
		   END IF;
		END IF;
         END IF;
    ELSE
	WMS_RULE_PVT.g_over_allocation := 'N';
    END IF;

    IF l_debug = 1 THEN
       log_statement(l_api_name, 'g_max_tolerance  ', WMS_RULE_PVT.g_max_tolerance);
       log_statement(l_api_name, 'WMS_RULE_PVT.g_over_allocation  ', WMS_RULE_PVT.g_over_allocation);
    END IF;
    --- [ End get_tolerance() ]
    ---
    while Wms_re_common_pvt.GetCountInputLines > 0 OR p_strategy_id IS NULL LOOP
      If l_debug = 1 THEN
         log_event(l_api_name,'', 'looping rules ');
      END IF;

      -- only fetch rule if p_strategy_id is not null
      -- which is no rule detailing
      IF p_strategy_id IS NOT null AND
           l_simulation_mode  NOT IN (2,4) THEN

         -- Get the next rule
         wms_re_common_pvt.GetNextRule ( l_rule_id
                                    ,l_partial_success_allowed_flag );

         If l_debug = 1 THEN
            log_event(l_api_name,'', 'get rule '||l_rule_id);
         END IF;
         exit when l_rule_id is null;

         If (l_debug = 1) then
            log_event(l_api_name, 'rule_num',
              'Calling Apply procedure for rule ' || l_rule_id);
         End if;
      ELSIF l_simulation_mode IN (2,4) THEN
           l_rule_id := p_simulation_id;
           l_partial_success_allowed_flag := 'Y';

      -- [ New Code : to call rule assignments  ]
      ELSIF p_rule_id IS NOT null THEN
          l_rule_id := p_rule_id;
      ELSE
          l_rule_id := NULL;
          l_partial_success_allowed_flag := 'Y';
          If (l_debug = 1) then
            log_event(l_api_name, 'null_rule',
                   'Calling Apply procedure for null rule');
          End if;
      END IF;

       -- Bug 1734809 - Rules whose partial success allowed flag = N
       -- should not be executed if previous rules in the strategy
       -- have allocated some of the material
       l_skip_rule := 'N';
       IF l_partial_success_allowed_flag = 'N' THEN
          OPEN c_output_exists;
          FETCH c_output_exists INTO l_skip_rule;

          IF (l_partial_success_allowed_flag = 'N' AND l_allow_non_partial_rules = FALSE)  THEN
              l_skip_rule := 'Y';
          ELSIF c_output_exists%NOTFOUND Then
              l_skip_rule := 'N';
          Else
             If (l_debug = 1) then
               log_event(l_api_name, 'skip_rule',
                'Skipping rule with partial success allowed flag = N,' ||
                'since previous rules partially allocated.');
             End if;
          End If;
          CLOSE c_output_exists;
       ELSE
          l_skip_rule  := 'N';
       END IF;

       IF l_skip_rule = 'N' THEN


          If (l_debug = 1) then
              log_event(l_api_name, 'APPLY()', 'Calling ApplyRule() with rule id : '        || l_rule_id);
              log_event(l_api_name, 'APPLY()', 'Calling ApplyRule() with p_detail_any_serial : ' || p_detail_any_serial);
              log_event(l_api_name, 'APPLY()', 'Calling ApplyRule() p_from_serial : '      || p_from_serial);
              log_event(l_api_name, 'APPLY()', '                      p_type_code : '      || p_type_code);
              log_event(l_api_name, 'APPLY()', '                 l_wms_enabled_flag : '      ||  l_wms_enabled_flag);

          End if;

        --Added for bug3237702
          -- IF (is_pickrelease AND p_type_code = 1 AND l_req_locator_id IS NOT NULL)  OR
	  IF ((is_pickrelease OR p_wave_simulation_mode = 'Y') AND p_type_code = 1 AND l_req_locator_id IS NOT NULL)  OR
             ( p_type_code = 1 AND l_wms_enabled_flag = 'N' ) OR  -- [ Skiping putaway rules for INV Org ]
             (WMS_ENGINE_PVT.g_Is_xdock AND p_type_code = 1 ) -- [ Skip Rules for Xdocking
              THEN
              IF l_debug = 1 THEN
                 log_event(l_api_name, 'APPLY()', 'applydefloc ');
                 If l_wms_installed THEN
                    log_event(l_api_name, 'APPLY()', 'Calling applydefloc for WMS flow');
                 ELSE
                    log_event(l_api_name, 'APPLY()', 'applydefloc for non WMS flow ');
                 END IF;

              END IF;
            WMS_rule_PVT.applydefloc
                 (
                  p_api_version           => g_pp_rule_api_version,
                  p_init_msg_list         => fnd_api.g_false,
                  p_commit                => p_commit,
                  p_validation_level      => fnd_api.g_valid_level_none,
                  x_return_status         => x_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_transaction_temp_id   => p_transaction_temp_id,
                  p_organization_id       => l_organization_id,
                  p_inventory_item_id     => l_inventory_item_id,
                  p_subinventory_code     => l_req_subinventory_code,
                  p_locator_id            => l_req_locator_id,
                  p_transaction_uom       => l_transaction_uom,
                  p_primary_uom           => l_primary_uom,
                  p_transaction_type_id   => l_transaction_type_id,
                  x_finished              => l_finished,
                  p_lpn_id                => p_lpn_id,
                  p_simulation_mode       => l_simulation_mode,
                  p_project_id            => p_project_id,
                  p_task_id               => p_task_id
                  );

         -- LG convergence add
         ElsIF  p_simulation_mode = 10 THEN --mode is manual alloc
             log_event(l_api_name, 'APPLY()', 'get_availabe_inv ');
             WMS_Rule_PVT.get_available_inventory(
                      p_api_version                  => g_pp_rule_api_version
                    , p_init_msg_list                => fnd_api.g_false
                    , p_commit                       => fnd_api.g_false
                    , p_validation_level             => fnd_api.g_valid_level_full
                    , x_return_status                => x_return_status
                    , x_msg_count                    => l_msg_count
                    , x_msg_data                     => l_msg_data
                    , p_rule_id                      => l_rule_id
                    , p_type_code                    => p_type_code
                    , p_partial_success_allowed_flag => l_partial_success_allowed_flag
                    , p_transaction_temp_id          => p_transaction_temp_id
                    , p_organization_id              => l_organization_id
                    , p_inventory_item_id            => l_inventory_item_id
                    , p_transaction_uom              => l_transaction_uom
                    , p_primary_uom                  => l_primary_uom
                    , p_transaction_type_id          => l_transaction_type_id
                    , p_tree_id                      => l_tree_id
                    , x_finished                     => l_finished
                    , p_detail_serial                => p_detail_serial
                    , p_from_serial                  => p_from_serial
                    , p_to_serial                    => p_to_serial
                    , p_detail_any_serial            => p_detail_any_serial
                    , p_unit_volume                  => p_unit_volume
                    , p_volume_uom_code              => p_volume_uom_code
                    , p_unit_weight                  => p_unit_weight
                    , p_weight_uom_code              => p_weight_uom_code
                    , p_base_uom_code                => p_base_uom_code
                    , p_lpn_id                       => p_lpn_id
                    , p_unit_number                  => p_unit_number
                    , p_simulation_mode              => p_simulation_mode
                    , p_project_id                   => p_project_id
                    , p_task_id                      => p_task_id
                    ) ;

                    --bug#6867434 start
		    INV_Quantity_Tree_PVT. release_lock(
                                         p_api_version_number => g_qty_tree_api_version,
                                         p_init_msg_lst       => fnd_api.g_false,
                                         x_return_status      => x_return_status,
             				 x_msg_count          => l_msg_count,
    			 		 x_msg_data           => l_msg_data,
                                         p_organization_id    => l_organization_id,
                                         p_inventory_item_id  => l_inventory_item_id
                                                       ) ;
                    --bug#6867434 end
             log_event(l_api_name, 'APPLY()', 'end of get_availabe_inv ');

         -- End of LG convergence
          Elsif p_rule_id is not null Then

		-- {{ Test Case  # UTK-REALLOC-3.1.3:3a
		--and Test Case  # UTK-REALLOC-3.1.3:3b
		--    Description: Strategy search based on rule and strategy assignments
		--    Searching pick rule/ Putaway rules assignments
		--    Defaulting the l_partial_success_allowed_flag to 'Y' }}
		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3g
		--     Make sure searching all the picking rules in the strategy , if stg_id returned }}
		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3h
		--     Calling  pick single rule , if rule_id returned}}
		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3i
		--	    Uses default pick rule_id , if stg_id / rule_id is not returned}}

		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3j
		--     Make sure searching all the put away in the strategy , if stg_id returned}}
		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3k
		--     Calling  put away single rule , if rule_id returned}}
		-- {{[ Test Case  # UTK-REALLOC-3.1.3:3l
		--     Uses default put away rule_id , if stg_id / rule_id is not returned}}

	      If (l_debug = 1) then
	          log_event(l_api_name, 'APPLY()', 'rule apply  for pick or putaway rule');
	      End If;

	            WMS_Rule_PVT.Apply (
	                    p_api_version                     =>    g_pp_rule_api_version
	                  , p_init_msg_list                   =>    fnd_api.g_false
	                  , p_commit                          =>    fnd_api.g_false
	                  , p_validation_level                =>    fnd_api.g_valid_level_full
	                  , x_return_status                   =>    x_return_status
	                  , x_msg_count                       =>    l_msg_count
	                  , x_msg_data                        =>    l_msg_data
	                  , p_rule_id                         =>    l_rule_id
	                  , p_type_code                       =>    p_type_code
	                  , p_partial_success_allowed_flag    =>    'Y'
	                  , p_transaction_temp_id             =>    p_transaction_temp_id
	                  , p_organization_id                 =>    l_organization_id
	                  , p_inventory_item_id               =>    l_inventory_item_id
	                  , p_transaction_uom                 =>    l_transaction_uom
	                  , p_primary_uom                     =>    l_primary_uom
	                  , p_secondary_uom                   =>    l_secondary_uom
	                  , p_grade_code                      =>    l_grade_code
	                  , p_transaction_type_id             =>    l_transaction_type_id
	                  , p_tree_id                         =>    l_tree_id
	                  , x_finished                        =>    l_finished
	                  , p_detail_serial                   =>    p_detail_serial
	                  , p_from_serial                     =>    p_from_serial
	                  , p_to_serial                       =>    p_to_serial
	                  , p_detail_any_serial               =>    p_detail_any_serial
	                  , p_unit_volume                     =>    p_unit_volume
	                  , p_volume_uom_code                 =>    p_volume_uom_code
	                  , p_unit_weight                     =>    p_unit_weight
	                  , p_weight_uom_code                 =>    p_weight_uom_code
	                  , p_base_uom_code                   =>    p_base_uom_code
	                  , p_lpn_id                          =>    p_lpn_id
	                  , p_unit_number                     =>    p_unit_number
	                  , p_simulation_mode                 =>    p_simulation_mode
	                  , p_project_id                      =>    p_project_id
	                  , p_task_id                         =>    p_task_id
			  , p_wave_simulation_mode            =>    p_wave_simulation_mode
           );
         Else
         --Bug3237702 ends

           log_event(l_api_name, 'APPLY()', 'rule apply ');
           WMS_Rule_PVT.Apply (
                   p_api_version                     =>    g_pp_rule_api_version
                 , p_init_msg_list                   =>    fnd_api.g_false
                 , p_commit                          =>    fnd_api.g_false
                 , p_validation_level                =>    fnd_api.g_valid_level_full
                 , x_return_status                   =>    x_return_status
                 , x_msg_count                       =>    l_msg_count
                 , x_msg_data                        =>    l_msg_data
                 , p_rule_id                         =>    l_rule_id
                 , p_type_code                       =>    p_type_code
                 , p_partial_success_allowed_flag    =>    l_partial_success_allowed_flag
                 , p_transaction_temp_id             =>    p_transaction_temp_id
                 , p_organization_id                 =>    l_organization_id
                 , p_inventory_item_id               =>    l_inventory_item_id
                 , p_transaction_uom                 =>    l_transaction_uom
                 , p_primary_uom                     =>    l_primary_uom
                 , p_secondary_uom                   =>    l_secondary_uom
                 , p_grade_code                      =>    l_grade_code
                 , p_transaction_type_id             =>    l_transaction_type_id
                 , p_tree_id                         =>    l_tree_id
                 , x_finished                        =>    l_finished
                 , p_detail_serial                   =>    p_detail_serial
                 , p_from_serial                     =>    p_from_serial
                 , p_to_serial                       =>    p_to_serial
                 , p_detail_any_serial               =>    p_detail_any_serial
                 , p_unit_volume                     =>    p_unit_volume
                 , p_volume_uom_code                 =>    p_volume_uom_code
                 , p_unit_weight                     =>    p_unit_weight
                 , p_weight_uom_code                 =>    p_weight_uom_code
                 , p_base_uom_code                   =>    p_base_uom_code
                 , p_lpn_id                          =>    p_lpn_id
                 , p_unit_number                     =>    p_unit_number
                 , p_simulation_mode                 =>    p_simulation_mode
                 , p_project_id                      =>    p_project_id
                 , p_task_id                         =>    p_task_id
		 , p_wave_simulation_mode            =>    p_wave_simulation_mode
           );

           -- Bug # 3413372
           -- Initilize  global variable /Tables  used by get_itemobhand(),
           -- get_project_attribute() in WMS_PARAMETERS_PVT
           wms_parameter_pvt.g_GetItemOnhq_IsRuleCached  := 'N';
           wms_parameter_pvt.g_GetProjAttr_IsRuleCached  := 'N';

           wms_parameter_pvt.g_locator_item_quantity.DELETE;
           wms_parameter_pvt.g_bulkCollect_Locator.DELETE;
           wms_parameter_pvt.g_bulkCollect_quantity.DELETE;
           -- end of Bug# 3413372
        END IF;
        if x_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
        elsif x_return_status = fnd_api.g_ret_sts_error then
          raise fnd_api.g_exc_error;
        end if;
      END IF;
      if (l_debug = 1) then
         log_statement(l_api_name, 'l_finished ', l_finished);
      end if;
      --gmi_reservation_util.println('l_finished '||l_finished);

      /*
         Bug#8360804 removed the simulation mode as 10 in exit clause
         and added following if condition
      */

      IF l_simulation_mode = 10 and  p_strategy_id IS NOT NULL THEN
          l_finished := fnd_api.g_false;
      END IF;

      exit when fnd_api.to_boolean(l_finished) OR  p_strategy_id IS NULL
           OR l_simulation_mode IN (2,4);
    end loop;


   END IF; --  end Patchset J changes

    -- Standard check of p_commit
    if fnd_api.to_boolean(p_commit) then
      commit work;
    end if;

    --
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );
   /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section */
    If (l_debug = 1) then
      log_procedure(l_api_name, 'end', 'End Apply');
    End if;
    -- g_debug := NULL;
    --
exception
    when fnd_api.g_exc_error then
    /* --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
    -- Note: in debug mode, later call to fnd_msg_pub.get will not get
    -- the message retrieved here since it is no longer on the stack
    inv_pp_debug.set_last_error_message(Sqlerrm);
    inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
    inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
      rollback to ApplyStrategySP;
      FreeGlobals;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
        log_error(l_api_name, 'error', 'Error in Apply - ' || x_msg_data);
      End if;
      g_debug := NULL;

    when fnd_api.g_exc_unexpected_error then
    /*--
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
    -- Note: in debug mode, later call to fnd_msg_pub.get will not get
    -- the message retrieved here since it is no longer on the stack
    inv_pp_debug.set_last_error_message(Sqlerrm);
    inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
    inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
      rollback to ApplyStrategySP;
      FreeGlobals;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
        log_error(l_api_name, 'unexp_error',
                 'Unexpected error in Apply - ' || x_msg_data);
      End if;
     -- g_debug := NULL;

    when others then
    /*--
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(Sqlerrm);
        inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
        inv_pp_debug.send_last_error_message;
    END IF;
    -- end of debugging section
    -- */
      rollback to ApplyStrategySP;
      FreeGlobals;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
        log_error(l_api_name, 'other_error',
              'Other error in Apply - ' || x_msg_data);
      End if;
      --g_debug := NULL;
  end Apply;
  end WMS_Strategy_PVT;

/
