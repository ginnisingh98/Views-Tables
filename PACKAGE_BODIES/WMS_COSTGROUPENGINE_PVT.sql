--------------------------------------------------------
--  DDL for Package Body WMS_COSTGROUPENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_COSTGROUPENGINE_PVT" AS
/* $Header: WMSVPPGB.pls 120.3 2005/06/20 21:33:47 appldev ship $*/
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_CostGroupEngine_PVT';
--
   l_debug                  NUMBER;
--Procedures for logging messages
PROCEDURE log_event(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS
l_module VARCHAR2(255);
BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace(p_message, l_module, 9);

END log_event;

PROCEDURE log_error(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS
l_module VARCHAR2(255);
BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace(p_message, l_module, 9);

END log_error;

PROCEDURE log_error_msg(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2) IS
l_module VARCHAR2(255);
BEGIN
  l_module := g_pkg_name || p_label;

 inv_log_util.trace('', l_module, 9);
END log_error_msg;

PROCEDURE log_procedure(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS
l_module VARCHAR2(255);
BEGIN
   l_module := g_pkg_name  || p_label;

 inv_log_util.trace(p_message, l_module, 9);
END log_procedure;

PROCEDURE log_statement(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS
l_module VARCHAR2(255);
BEGIN
   l_module := g_pkg_name || p_label;
   inv_log_util.trace(p_message, l_module, 9);
END log_statement;
---------------------------------------------------------------------------------
---  Procedures to handle the static calls to open, fetch and close cursor
---  based on the Rule_id. The name of the API_call is decided based on the the
---  flag retrived from the table.


----------------
PROCEDURE execute_CG_rule( p_rule_id IN NUMBER,
                           p_line_id IN NUMBER,
                           x_sql_return OUT NOCOPY NUMBER) IS

invalid_pkg_state  EXCEPTION;
Pragma Exception_Init(invalid_pkg_state, -6508);

l_api_name      VARCHAR2(30);
l_list_pkg      VARCHAR2(30);
l_package_name  VARCHAR2(128);

l_ctr number := 0;

BEGIN

 -- Switching logic to avoid potential contentation issues
IF wms_costgroupengine_pvt.g_rule_list_cg_ctr IS NULL THEN
  wms_costgroupengine_pvt.g_rule_list_cg_ctr := wms_rule_gen_pkgs.get_count_no_lock('COST_GROUP' );
END IF;
 l_ctr := wms_costgroupengine_pvt.g_rule_list_cg_ctr;


 IF (l_ctr = 1) then
     wms_rule_cg_pkg1.EXECUTE_CG_RULE( p_rule_id,
                                    p_line_id,
                                    x_sql_return);
 ELSIF (l_ctr = 2) then
     wms_rule_cg_pkg2.EXECUTE_CG_RULE( p_rule_id,
                                    p_line_id,
                                    x_sql_return);
 ELSIF (l_ctr = 3) then
       wms_rule_cg_pkg3.EXECUTE_CG_RULE( p_rule_id,
                                    p_line_id,
                                    x_sql_return);

 END IF;
 If x_sql_return is NUll Then
     x_sql_return := 1;
 End if;

EXCEPTION
WHEN INVALID_PKG_STATE THEN
   x_sql_return := -1;
   wms_costgroupengine_pvt.g_rule_list_cg_ctr := wms_rule_gen_pkgs.get_count_no_lock('COST_GROUP' );
   WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
   fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
   fnd_message.set_token('LIST_PKG',  l_list_pkg);
   fnd_message.set_token('RULE_NAME', l_package_name);
   fnd_msg_pub.ADD;
   log_error(l_api_name, 'execute_open_rule', 'Invalid Package, Contact your DBA - '
	    || l_list_pkg || ' / ' || l_package_name);

END execute_CG_rule;
----------------

PROCEDURE assign_cost_group(
   p_api_version                  IN   NUMBER
  ,p_init_msg_list                IN   VARCHAR2
  ,p_commit                       IN   VARCHAR2
  ,p_validation_level             IN   NUMBER
  ,x_return_status                OUT  NOCOPY VARCHAR2
  ,x_msg_count                    OUT  NOCOPY NUMBER
  ,x_msg_data                     OUT  NOCOPY VARCHAR2
  ,p_line_id                      IN   NUMBER
  ,p_input_type                   IN   NUMBER
  ,p_simulation_mode              IN   NUMBER
  ,p_simulation_id                IN   NUMBER
) IS

   l_rule_id NUMBER;
   l_pack_exists NUMBER;
   l_package_name VARCHAR2(30);
   l_rule_func_sql	long;
   l_rule_result      NUMBER;
   l_cursor               INTEGER;
   l_dummy		NUMBER;
   l_count  NUMBER;
   l_return_status VARCHAR(1);
   l_sql_return NUMBER;
   l_strategy_id  NUMBER;
   l_cg_rule_id   NUMBER;  --- Added new column
   l_partial_flag WMS_STRATEGY_MEMBERS.partial_success_allowed_flag%TYPE;
   l_to_subinventory_code VARCHAR2(10);
   l_organization_id NUMBER;
   l_source_organization_id NUMBER;
   l_transfer_organization_id NUMBER;
   l_cost_group_id   NUMBER := NULL;
   l_transaction_action_id NUMBER;
   l_input_line	 WMS_COST_GROUPS_INPUT_V%ROWTYPE;
   l_fob_point NUMBER := NULL;
   l_simulation_mode NUMBER;
   l_api_version          constant number       := 1.0;
   l_api_name             constant varchar2(30) := 'Assign_Cost_Group';

   l_return_type           	VARCHAR2(1);
   l_return_type_id        	NUMBER;
   l_sequence_number            NUMBER;
   l_rules_engine_mode     	NUMBER  :=  1;  -- nvl(FND_PROFILE.VALUE('WMS_RULES_ENGINE_MODE'), 0);

   l_rule_counter               INTEGER;
   g_debug                      NUMBER;
  --cursor to get input lines
  CURSOR c_input_line IS
	SELECT organization_id
	      ,to_subinventory_code
	      ,transaction_action_id
	      ,to_organization_id
	FROM wms_cost_groups_input_v
	WHERE line_id = p_line_id;

  CURSOR c_fob_point IS
	SELECT fob_point
	  FROM MTL_INTERORG_PARAMETERS
	 WHERE from_organization_id = l_organization_id/*changed from l_source_organization_id for 3224420*/
	   AND to_organization_id = l_transfer_organization_id;

   --cursor used to determine if the rule package exists
  CURSOR l_pack_gen IS
	SELECT count(object_name)
	FROM user_objects
	WHERE object_name = l_package_name;

  --cursor to get the cost group from the rule
  CURSOR l_rule_cg IS
       SELECT type_hdr_id
         FROM wms_rules_b
        WHERE rule_id = l_rule_id;

   --cursor used to get default cost group from sub
  CURSOR l_default_cg_sub IS
	SELECT default_cost_group_id
	  FROM mtl_secondary_inventories
	 WHERE secondary_inventory_name = l_to_subinventory_code
	   AND organization_id = l_organization_id;


   --cursor used to get default cost group from org
  CURSOR l_default_cg_org IS
	SELECT default_cost_group_id
	  FROM mtl_parameters
	 WHERE organization_id = l_organization_id;

BEGIN

   SAVEPOINT assignCGSP;

   -- l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call( l_api_version
				       ,p_api_version
				       ,l_api_name
				       ,g_pkg_name ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;
   --
   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   -- debugging portion
   -- can be commented out for final code

   IF l_debug = 1 THEN
      log_procedure(l_api_name, '', 'Start Assign_Cost_Group');
      log_procedure (l_api_name, 'Line_id', p_line_id);
      log_procedure (l_api_name, 'Input type', p_input_type);
   END IF;

   -- Validate input parameters and pre-requisites, if validation level
   -- requires this
   IF p_validation_level <> fnd_api.g_valid_level_none THEN

      --check for null line_id
      if (p_line_id IS NULL) then
	fnd_message.set_name('WMS','WMS_CG_MISSING_LINE_ID');
	fnd_msg_pub.add;
        log_error_msg(l_api_name, 'missing_line_id');
	raise fnd_api.g_exc_error;
      end if;

      --check for null type code
      if (p_input_type IS NULL) then
	fnd_message.set_name('WMS','WMS_CG_MISSING_INPUT_TYPE');
	fnd_msg_pub.add;
        log_error_msg(l_api_name, 'missing_input_type');
	raise fnd_api.g_exc_error;
      end if;

  END IF;

  IF p_input_type = g_input_mmtt THEN
      If l_debug = 1 then
         log_event(l_api_name, 'mmtt_line', 'Update a transaction with ' ||
  	        'transaction temp id: ' || p_line_id);
      end if;
  ELSIF p_input_type = g_input_mtrl THEN
      If l_debug = 1 then
         log_event(l_api_name, 'mmtt_line', 'Update a move order with ' ||
		'move order line id: ' || p_line_id);
      end if;
  ELSE
      fnd_message.set_name('WMS','WMS_CG_MISSING_INPUT_TYPE');
      fnd_msg_pub.add;
      log_error_msg(l_api_name, 'invalid_input_type');
      raise fnd_api.g_exc_error;
  END IF;

  --set record type in global variable
  g_current_input_type := p_input_type;

  --validate simulation mode parameters
  IF p_simulation_mode < g_no_simulation OR
     p_simulation_mode > g_rule_mode THEN
    l_simulation_mode := g_no_simulation;
  ELSIF p_simulation_mode IN (g_rule_mode, g_strategy_mode) AND
        p_simulation_id IS NULL THEN
    l_simulation_mode := g_no_simulation;
  ELSE
    l_simulation_mode := p_simulation_mode;
  END IF;

  --get input line from view; store in record
  OPEN c_input_line;
  FETCH c_input_line INTO l_organization_id
		         ,l_to_subinventory_code
			 ,l_transaction_action_id
			 ,l_transfer_organization_id;
  IF (c_input_line%NOTFOUND) THEN
	CLOSE c_input_line;
	fnd_message.set_name('WMS','WMS_CG_LINE_NOT_FOUND');
	fnd_msg_pub.add;
        log_error_msg(l_api_name, 'line_not_found');
	raise fnd_api.g_exc_error;
  END IF;
  CLOSE c_input_line;

  -- Determine which organization to use.
  -- If direct org transfer, use the transfer_org, since that is the
  --  receiving org.  If intransit receipt, we store the organization_id
  -- in the to_organization_id in the view.

  IF l_transaction_action_id IN (3,12) THEN
     l_organization_id := l_transfer_organization_id;
  -- For intransit shipment, the org to run rules on depends on the
  -- fob point flag
  ELSIF l_transaction_action_id = 21 THEN
     OPEN c_fob_point;
     FETCH c_fob_point INTO l_fob_point;
     If c_fob_point%NOTFOUND Then
	  l_fob_point:= NULL;
     End If;
     CLOSE c_fob_point;

     --if fob point = 1, then the ownership change occurs at issue.
     -- If this is true, then we need to run rules on destination org
     If l_fob_point IS NOT NULL and l_fob_point = 1 Then
        l_organization_id := l_transfer_organization_id;
     /*3224420Else
	l_organization_id := l_source_organization_id;*/
     End If;
  /*3224220ELSE
     l_organization_id := l_source_organization_id;*/
  END IF;

  if l_debug = 1 then
     log_statement(l_api_name, 'org_id', 'Running the engine on org ' ||
        l_organization_id);
  end if;

  --get Strategy
  IF l_simulation_mode = g_no_simulation THEN
     if l_debug = 1 then
        log_event(l_api_name, '', 'Calling the Strategy Search function');
     end if;

    If (g_current_input_type  = g_input_mmtt) then
	if l_debug = 1 then
	   log_event(l_api_name, '', 'wms_rules_workbench_pvt.cg_mmtt_search');
           log_event(l_api_name, 'p_transaction_temp_id',p_line_id);
           log_event(l_api_name, 'p_organization_id', l_organization_id);
         end if;
	 wms_rules_workbench_pvt.cg_mmtt_search
	        ( p_api_version              => 1.0
	    	     ,p_init_msg_list        => fnd_api.g_false
	    	     ,p_validation_level     => fnd_api.g_valid_level_none
	    	     ,x_return_status        => l_return_status
	    	     ,x_msg_count            => x_msg_count
	    	     ,x_msg_data             => x_msg_data
	    	     ,p_transaction_temp_id  => p_line_id
	    	     ,p_type_code            => 5
	    	     ,x_return_type          => l_return_type
	    	     ,x_return_type_id       => l_return_type_id
	             ,p_organization_id      => l_organization_id
                     ,x_sequence_number      => l_sequence_number );
	 if l_debug = 1 then
	    log_statement(l_api_name, 'l_return_type', l_return_type);
	    log_statement(l_api_name, 'l_return_type_id', l_return_type_id);
	    log_statement(l_api_name, 'l_organization_id', l_organization_id);
	    log_statement(l_api_name, 'l_sequence_number ', l_sequence_number );
	    log_event(l_api_name, 'cg_mmtt_search', 'End');
         end if;
   elsif (g_current_input_type  = g_input_mtrl) then
        if l_debug = 1 then
       	   log_event(l_api_name, 'Search', 'wms_rules_workbench_pvt.search');
        end if;
        wms_rules_workbench_pvt.Search
	    ( p_api_version          => 1.0
	     ,p_init_msg_list        => fnd_api.g_false
	     ,p_validation_level     => fnd_api.g_valid_level_none
	     ,x_return_status        => l_return_status
	     ,x_msg_count            => x_msg_count
	     ,x_msg_data             => x_msg_data
	     ,p_transaction_temp_id  => p_line_id
	     ,p_type_code            => 5
	     ,x_return_type          => l_return_type
	     ,x_return_type_id       => l_return_type_id
	     ,p_organization_id      => l_organization_id
             ,x_sequence_number      => l_sequence_number);

              if l_debug = 1 then
	     	log_statement(l_api_name, ': l_return_type', l_return_type);
	     	log_statement(l_api_name, ': l_return_type_id', l_return_type_id);
	     	log_statement(l_api_name, ': l_organization_id', l_organization_id);
	     	log_statement(l_api_name, ': l_sequence_number ', l_sequence_number );
	     	log_event(l_api_name, 'search', 'End');
              end if;
   End if;
   if l_return_status = fnd_api.g_ret_sts_unexp_error then
      if l_debug = 1 THEN
         log_error(l_api_name, 'strat_search_unexp_err',
             'Unexpected error in wms_strategy_pvt search procedure');
      end if;
      raise fnd_api.g_exc_unexpected_error;

   elsif l_return_status = fnd_api.g_ret_sts_error then
      if l_debug = 1 then
             log_error(l_api_name, 'strat_search_err',
	       'Error in wms_strategy_pvt search procedure');
      end if;
           raise fnd_api.g_exc_error;
   elsif  l_return_status = fnd_api.g_ret_sts_success then
           --If l_rules_engine_mode = 1 then
     -- {{[ Test Case  # UTK-REALLOC-3.1.3:3c
     --    Description: Strategy search based on rule and strategy assignments
     --    Searching Cost Group rule assignments  Misc Receipt ] }}

     -- {{[ Test Case  # UTK-REALLOC-3.1.3:3m
     --    Description: Strategy search based on rule and strategy assignments
     --    Searching Cost Group rule assignments  PO  Receipt ] }}

	      if  l_return_type = 'S' then
	   	  l_strategy_id :=l_return_type_id;
                  l_cg_rule_id := NULL;
              elsif l_return_type = 'R' then
                  l_cg_rule_id :=l_return_type_id;
                  l_strategy_id := NULL;
	      elsif l_return_type = 'V' then
   	          l_cost_group_id:=l_return_type_id;
	   	  l_strategy_id := NULL;
                  l_cg_rule_id := NULL;
	       else
  	          l_strategy_id := NULL;
                  l_cg_rule_id := NULL;
		  l_cost_group_id:=NULL;
	      end if;
	   End If;
        --end if;

        if l_debug = 1 then
          if l_strategy_id is not null then
           log_event(l_api_name, 'strategy_found','Strategy id:'|| l_strategy_id);
          elsif l_cg_rule_id is not null then
           log_event(l_api_name, 'Rule_found','Rule id:'|| l_cg_rule_id);
	   elsif l_cost_group_id is not null then
   	  log_event(l_api_name, 'Direct Value Found ','Rule id:'|| l_cost_group_id);
          end if;
        end if;
  ELSIF l_simulation_mode = g_strategy_mode THEN
    l_strategy_id := p_simulation_id;
    -- May have to add code if simulation is done for rule
  ELSE
    l_strategy_id := NULL;
    l_cg_rule_id := NULL;
  END IF;

  if l_debug = 1 then
    if l_strategy_id is not NULL then
       log_statement(l_api_name, '', 'Using strategy:' ||  l_strategy_id);
    elsif l_cg_rule_id is not NULL then
       log_statement(l_api_name, '', 'Using rule:' ||  l_cg_rule_id);
   elsif l_cost_group_id is not null then
	   log_statement(l_api_name, '', 'Using Value:' ||  l_cost_group_id);
    end if;
  end if;
  -- Get rules within that strategy
  -- Initialize the internal rules table
  IF l_strategy_id IS NOT NULL THEN
        wms_strategy_pvt.InitStrategyRules ( l_return_status
                      ,x_msg_count
                      ,x_msg_data
                      ,l_strategy_id );

         if l_return_status = fnd_api.g_ret_sts_unexp_error then
           if l_debug = 1 then
              log_error(l_api_name, 'init_rules_unexp_err',
	       'Unexpected error in wms_strategy_pvt InitStrategyRules');
	   end if;
           raise fnd_api.g_exc_unexpected_error;
         elsif l_return_status = fnd_api.g_ret_sts_error then
           if l_debug = 1 then
              log_error(l_api_name, 'init_rules_err',
	       'Error in wms_strategy_pvt InitStrategyRules');
	   end if;
           raise fnd_api.g_exc_error;
         end if;
  END IF;
  -- Loop through all the rules, until all input lines are satisfied
  -- [ call the rule and exit from the loop ]
  --
  -- {{[ Test Case  # UTK-REALLOC-3.1.3:3d
  --     Description: Strategy search based on rule and strategy assignments
  --                  Make sure searching all the rules in the strategy , if stg_id returned ] }}

  -- {{[ Test Case  # UTK-REALLOC-3.1.3:3e
  --     Description: Strategy search based on rule and strategy assignments
  --                  Calling single rule , if rule_id returned ]}}


IF(l_cost_group_id is NULL)  THEN
  if l_debug = 1 then
      log_statement(l_api_name, 'l_cost_group_id is NULL', 'Needs to Derive');
   end if;
    WHILE l_strategy_id IS NOT NULL OR
        p_simulation_mode = g_rule_mode OR
        l_cg_rule_id is NOT NULL LOOP
	 	   --- added for Patchset 'K'

	if l_debug = 1 then
	    log_event(l_api_name, 'Inside While ', 'p_simulation_mode==   ' ||p_simulation_mode || 'g_rule_mode== ' ||g_rule_mode);

         end if;

         --get id of next rule in strategy ,  if workbench returns the strategy_id
         --for cost group rules, we don't use partial success flag

         If p_simulation_mode = g_rule_mode Then
            l_rule_id := p_simulation_id;
         ELSIF l_cg_rule_id is not NULL THEN -- added this code for patchset 'K'
            l_rule_id := l_cg_rule_id;
         Else

            wms_re_common_pvt.GetNextRule(
		 x_rule_id			=> l_rule_id
	     	,x_partial_success_allowed_flag => l_partial_flag);
         End If;
         EXIT WHEN l_rule_id IS NULL;
         if l_debug = 1 then
            log_event(l_api_name, '', 'Current rule  ' ||l_rule_id);
            log_statement(l_api_name, '',
                    'calling GetPackageName( '||l_rule_id ||',' ||l_package_name ||')');
         end if;
         -- get the pre-generated package name for this rule
         wms_rule_pvt.GetPackageName(l_rule_id, l_package_name);
	 if l_debug = 1 then
            log_statement(l_api_name, '',
                'Calling open_curs -' || l_package_name);
             log_statement(l_api_name, 'l_rule_id', l_rule_id);
             log_statement(l_api_name, 'l_sql_return ', l_sql_return );
             log_statement(l_api_name, 'Before Entering Loop ', '');
         END IF;

         For l_rule_counter IN 1..2  LOOP
	     execute_CG_rule(l_rule_id, p_line_id,l_sql_return);

             IF l_debug = 1 THEN
                log_statement(l_api_name, 'execute_CG_rule Loop (l_rule_counter ) ', l_rule_counter);
                log_statement(l_api_name, 'l_sql_return ', l_sql_return );
             END IF;

	     IF (l_sql_return = -1 ) and l_rule_counter   = 2 THEN --error
	         fnd_message.set_name('WMS', 'WMS_PACKAGE_MISSING');
	         fnd_message.set_token('RULEID', l_rule_id);
	         fnd_msg_pub.ADD;
	         if l_debug = 1 then
                    log_statement(l_api_name, 'l_sql_return ', l_sql_return );
	            log_error_msg(l_api_name, 'rule_package_missing');
	            log_statement(l_api_name,'', 'Package name: ' || l_package_name);
	        end if;
	        RAISE fnd_api.g_exc_unexpected_error;
	     ELSIF l_sql_return  <> -1  THEN
	           EXIT;
	     END IF;
          END LOOP;

          if l_debug = 1 then
             log_statement(l_api_name, 'l_sql_return ', l_sql_return );
             log_statement(l_api_name, '','Finished Call to execute_CG_rule');
          end if;

          IF l_sql_return > 0 THEN  -- the rule matches the task
             if l_debug = 1 THEN
                log_event(l_api_name, '', 'Rule succeeded');
	     end if;
             OPEN l_rule_cg;
	     FETCH l_rule_cg INTO l_cost_group_id;
	     IF l_rule_cg%NOTFOUND OR l_cost_group_id IS NULL THEN
		--if rule does not have cost group id, don't raise error;
		--just get cost group id from sub/org
		if l_debug = 1 then
                   log_event(l_api_name, '',
			  'CostGroup id not found');
		end if;
		l_cost_group_id := NULL;
	     END IF;
	     CLOSE l_rule_cg;

             IF l_debug = 1 THEN
                log_event(l_api_name, '',
			  'found Cost group id: ' ||
			  l_cost_group_id);
	     end if;
             -- set global value for simulation form
             wms_search_order_globals_pvt.g_costgroup_rule_id := l_rule_id;
          ELSE
             if l_debug = 1 then
                log_event(l_api_name, '',
                'No cost group found');
             end if;
          END IF;
          -- close the rule package cursor
          -- execute_close_rule(l_rule_id);

          -- cost group assigned, jump out of the rule loop
          EXIT when l_cost_group_id IS NOT NULL OR
                    l_cg_rule_id is NOT NULL OR
                    l_simulation_mode = g_rule_mode;

   END LOOP;

   END IF;
   if l_debug = 1 then
      log_statement(l_api_name, '',
            'Finished checking rules for cg');
   end if;
   --if no cost group found, then get cost group from sub or org
   IF l_cost_group_id IS NULL THEN
      if l_debug = 1 then
         log_event(l_api_name, '',
	  'cost group not found using rules engine.');
      end if;


      --set global for no cg found from rule; used in sim form
      wms_search_order_globals_pvt.g_costgroup_rule_id := -999;

      --if to_sub is defined, get default cost group from there
      IF (l_to_subinventory_code IS NOT NULL) THEN
         if l_debug = 1 then
            log_event(l_api_name, '',
	    'Getting default cost group fo sub' ||
	    l_to_subinventory_code);
	 end if;

	 OPEN l_default_cg_sub;
	 FETCH l_default_cg_sub into l_cost_group_id;
         IF l_default_cg_sub%NOTFOUND OR l_cost_group_id IS NULL THEN
	    --don't raise error, just try to get cg from org
	    l_cost_group_id := NULL;
	    if l_debug = 1 then
               log_event(l_api_name, '',
	        'No default cost group for dest sub');
	     end if;
         ELSE
            if l_debug = 1 then
               log_event(l_api_name, '',
	        'Cost group id: ' || l_cost_group_id);
	    end if;
	 END IF;
	 CLOSE l_default_cg_sub;

      END IF;

      --if no to_sub, or default cost group not defined at to_sub,
      --  get default cost group from org
      -- 10.30.00 - now, we only get the cost group at org level for
      --  transaction records.  For move order lines, it's better
      --  to let the put away engine find a to_sub, and then use that
      --  sub's cost group
      -- {{[ Test Case  # UTK-REALLOC-3.1.3:3f
      --     Description: Strategy search based on rule and strategy assignments
      --     Uses default rule_id , if stg_id / rule_id is not returned ]}}
      IF (l_cost_group_id IS NULL and p_input_type = g_input_mmtt) THEN
         if l_debug = 1 then
            log_event(l_api_name, '',
	      'Getting the default cost group orga ' ||
	    l_organization_id);
	  end if;
	 OPEN l_default_cg_org;
	 FETCH l_default_cg_org into l_cost_group_id;
	 IF (l_default_cg_org%NOTFOUND OR l_cost_group_id IS NULL) THEN
	    --raise error here
	    CLOSE l_default_cg_org;
            fnd_message.set_name('INV','INV_NO_DEFAULT_COST_GROUP');
            fnd_msg_pub.add;
            if l_debug = 1 then
               log_error_msg(l_api_name, 'no_default_org_cg');
            end if;
            raise fnd_api.g_exc_error;
	 END IF;
	 CLOSE l_default_cg_org;
	 if l_debug = 1 then
            log_event(l_api_name, 'default_cg_for_org',
	    'Cost group id: ' || l_cost_group_id);
         end if;
      --This should only happen for mtrl records
      ELSIF l_cost_group_id IS NULL THEN
         if l_debug = 1 then
	    log_event(l_api_name, '',
	 	   'Found no costgroup for this move order line.');
         end if;
      END IF;


   END IF;

   -- update mmtt or mtrl with cost group id
   IF l_cost_group_id IS NOT NULL THEN
      --if input_line_type = MMTT
      if (p_input_type = g_input_mmtt) then
        --IF Transfer or intransit, update transfer_cost_group_id
        IF (l_transaction_action_id IN (2,3,28,21)) THEN
           UPDATE mtl_material_transactions_temp mmtt
              SET mmtt.transfer_cost_group_id = l_cost_group_id
            WHERE mmtt.transaction_temp_id = p_line_id;

        --else, update cost_group_id
        ELSE
           UPDATE mtl_material_transactions_temp mmtt
              SET mmtt.cost_group_id = l_cost_group_id
            WHERE mmtt.transaction_temp_id = p_line_id;
        END IF;

      --else if input_line_type Move Order
      else
        UPDATE mtl_txn_request_lines mtrl
           SET mtrl.to_cost_group_id = l_cost_group_id
         WHERE mtrl.line_id = p_line_id;
      end if;

      --update global value for simulation form
      wms_search_order_globals_pvt.g_costgroup_id := l_cost_group_id;
   END IF;

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- debugging portion
   -- can be commented out for final code

   if l_debug = 1 then
      log_procedure(l_api_name, '', 'End Assign_Cost_Group');
   end if;
 EXCEPTION

    WHEN fnd_api.g_exc_error THEN

       ROLLBACK TO assignCGSP;
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get( p_count => x_msg_count
				  ,p_data  => x_msg_data );
        if l_debug = 1	then
          log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
       end if;

    WHEN OTHERS THEN

       ROLLBACK TO assignCGSP;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get( p_count => x_msg_count
				  ,p_data  => x_msg_data );
       if l_debug = 1 then
          log_error(l_api_name,'unexp_error','Unexpected error - ' || x_msg_data);
       end if;

END assign_cost_group;


FUNCTION GetCurrentInputType RETURN NUMBER IS

BEGIN

  Return g_current_input_type;

END GetCurrentInputType;



END WMS_CostGroupEngine_PVT;

/
