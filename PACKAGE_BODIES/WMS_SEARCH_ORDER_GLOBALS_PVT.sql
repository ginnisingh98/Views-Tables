--------------------------------------------------------
--  DDL for Package Body WMS_SEARCH_ORDER_GLOBALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SEARCH_ORDER_GLOBALS_PVT" AS
/* $Header: WMSSOGBB.pls 120.2 2005/07/18 05:22:17 ajohnson noship $ */


-- File        : WMSSOGBB.pls
-- Content     : WMS_SEARCH_ORDER_GLOBALS_PVT package body
-- Description : This API is created  to store Rules Engine Process flow
--               Variabls. This API  Gobal Variable will be updated by
---              WMS_RULES_ENGINE_PVT  and to be refrenced by WMSRLSIM.fmb

-- Notes       :
-- Created By  : Grao 06/16/01    Created
-- ---------   ------  ------------------------------------------

  --Procedures for logging messages
  PROCEDURE log_event(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
     g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_module VARCHAR2(255);

  BEGIN
    --l_progress := l_progress + 10;
    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_event;

  PROCEDURE log_error(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
     g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_module VARCHAR2(255);

  BEGIN
    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_error;

  PROCEDURE log_error_msg(p_api_name VARCHAR2, p_label VARCHAR2) IS
     g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_module VARCHAR2(255);
  BEGIN
    l_module:= 'wms.plsql.'|| g_pkg_name ||'.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_label, l_module, 9);
  END log_error_msg;

  PROCEDURE log_procedure(p_api_name VARCHAR2, p_label VARCHAR2,
			  p_message VARCHAR2) IS
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_module VARCHAR2(255);
  BEGIN

    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_procedure;

  PROCEDURE log_statement(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
      g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
      l_module VARCHAR2(255);
   BEGIN

      l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
      inv_log_util.trace(p_message, l_module, 9);
  END log_statement;

--- Function to get the business_object_type name based on the G_PICK_BUSINESS_OBJECT_ID / G_PUTAWAY_BUSINESS_OBJECT_ID
--- G_PICK_BUSINESS_OBJECT_ID / G_PUTAWAY_BUSINESS_OBJECT_ID is get updated by Rules Engine API

  FUNCTION get_object_type ( engine_type IN VARCHAR2)
    RETURN  VARCHAR2 is
    l_object_type       VARCHAR2(80)   := NULL;
    l_object_type_id    NUMBER         := NULL;
    l_engine_type       VARCHAR2(20)   := NULL;
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'get_object_type';

    BEGIN
       l_engine_type := engine_type;
       --
       --
       if (l_engine_type = 'PICK' ) then
           l_object_type_id := G_PICK_BUSINESS_OBJECT_ID ;
       elsif (l_engine_type = 'PUTAWAY' ) then
           l_object_type_id := G_PUTAWAY_BUSINESS_OBJECT_ID ;
       elsif (l_engine_type = 'COSTGROUP' ) then
           l_object_type_id := G_COSTGROUP_BUSINESS_OBJECT_ID ;
       else
          return Null;
       end if;
     --
       if (l_object_type_id > 0 )  then
       select name  into l_object_type
         from wms_objects
        where object_id = l_object_type_id ;
      else
         return Null;
      end if;
      return  l_object_type;
   EXCEPTION
     WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN  NULL;
   END;
-----------------------------------------
---  Function to get the object_ name based on the G_PICK_BUSINESS_OBJECT_ID /
---- G_PUTAWAY_BUSINESS_OBJECT_ID/G_COSTGROUP_BUSINESS_OBJECT_ID
---  G_PICK_BUSINESS_OBJECT_ID / G_PUTAWAY_BUSINESS_OBJECT_IDis /
---- G_COSTGROUP_BUSINESS_OBJECT_ID , ORGANIZATIONS_ID, PK_VALUES get updated by Rules Engine API

  FUNCTION get_object_name ( engine_type IN VARCHAR2,
                             org_id IN NUMBER  )

    RETURN  VARCHAR2 is
    l_object_type       VARCHAR2(80)   := NULL;
    l_object_type_id    NUMBER         := NULL;
    l_object_name       VARCHAR2(4000);
    l_engine_type       VARCHAR2(20)   := NULL;
    l_org_id            NUMBER;
    l_pk1_value         VARCHAR2(150);
    l_pk2_value         VARCHAR2(150);
    l_pk3_value         VARCHAR2(150);
    l_pk4_value         VARCHAR2(150);
    l_pk5_value         VARCHAR2(150);

    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'get_object_NAME';

    BEGIN

       l_engine_type := engine_type;
       l_org_id      := org_id;
       --
       --
       if (l_engine_type = 'PICK' ) then
           l_object_type_id := G_PICK_BUSINESS_OBJECT_ID ;
           l_pk1_value      := G_PICK_PK1_VALUE;
           l_pk2_value      := G_PICK_PK2_VALUE;
           l_pk3_value      := G_PICK_PK3_VALUE;
           l_pk4_value      := G_PICK_PK4_VALUE;
           l_pk5_value      := G_PICK_PK5_VALUE;

       elsif (l_engine_type = 'PUTAWAY' ) then
           l_object_type_id := G_PUTAWAY_BUSINESS_OBJECT_ID ;
           l_pk1_value      := G_PUTAWAY_PK1_VALUE;
           l_pk2_value      := G_PUTAWAY_PK2_VALUE;
           l_pk3_value      := G_PUTAWAY_PK3_VALUE;
           l_pk4_value      := G_PUTAWAY_PK4_VALUE;
           l_pk5_value      := G_PUTAWAY_PK5_VALUE;

       elsif (l_engine_type = 'COSTGROUP' ) then
           l_object_type_id := G_COSTGROUP_BUSINESS_OBJECT_ID ;
           l_pk1_value      := G_COSTGROUP_PK1_VALUE;
           l_pk2_value      := G_COSTGROUP_PK2_VALUE;
           l_pk3_value      := G_COSTGROUP_PK3_VALUE;
           l_pk4_value      := G_COSTGROUP_PK4_VALUE;
           l_pk5_value      := G_COSTGROUP_PK5_VALUE;

       else
          return  Null;
       end if;
     --
      if l_org_id > 0 then
       if (l_object_type_id > 0 and l_pk1_value is not null )  then

           l_object_name :=  WMS_Assignment_PVT.GetObjectValueName ( 1,
                                        L_OBJECT_TYPE_ID ,
                                        L_PK1_VALUE ,
                                        L_PK2_VALUE ,
                                        L_PK3_VALUE ,
                                        L_PK4_VALUE ,
                                        L_PK5_VALUE );
      else
       return Null;
      end if;
     end if;
      return l_object_name;

   EXCEPTION
     WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN  NULL;
   END;

--- Function to get the Strategy name based on the G_PICK_STRATEGY_ID /G_PUTAWAY_STRATEGY_ID
--- G_PICK_STRATEGY_ID /G_PUTAWAY_STRATEGY_ID  is get updated by Rules Engine API

 FUNCTION get_strategy_name ( engine_type IN VARCHAR2
                             ,org_id      IN NUMBER)
   RETURN  VARCHAR2 is
    l_strategy          VARCHAR2(80)   := NULL;
    l_strategy_id       NUMBER          ;
    l_org_id            NUMBER          ;
    l_engine_type       VARCHAR2(20)   := NULL;
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'get_strategy_name';
   BEGIN
        l_engine_type := engine_type;
        l_org_id      := org_id;

       if (l_engine_type = 'PICK' ) then
           l_strategy_id := G_PICK_STRATEGY_ID;
       elsif (l_engine_type = 'PUTAWAY' ) then
           l_strategy_id := G_PUTAWAY_STRATEGY_ID ;
       elsif (l_engine_type = 'COSTGROUP' ) then
            l_strategy_id:= G_COSTGROUP_STRATEGY_ID ;
       else
          return Null;
       end if;
       --
       if (l_strategy_id = -999) then
           l_strategy :=  'DEFAULT' ;
       elsif (l_strategy_id > 0 )  then
          select distinct name into l_strategy
             from wms_strategies_vl
	      where organization_id in (l_org_id, -1)
	       and  type_code = decode (l_engine_type, 'PICK',2,'PUTAWAY' ,1)
              and strategy_id = l_strategy_id;
       else
         return Null;
         --return G_PICK_STRATEGY_ID;
      end if;
      return l_strategy;
   EXCEPTION
    WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN NULL;
   END;


-- Function to get the rule name based on the G_Costgroup_ID
--- G_costgroup_rule_id is updated by Rules Engine API

 FUNCTION get_rule_name ( engine_type IN VARCHAR2
                             ,org_id      IN NUMBER)
   RETURN  VARCHAR2 is
    l_rule         VARCHAR2(80)   := NULL;
    l_rule_id       NUMBER          ;
    l_org_id            NUMBER          ;
    l_engine_type       VARCHAR2(20)   := NULL;
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'get_rule_name';
   BEGIN
        l_engine_type := engine_type;
        l_org_id      := org_id;

       if (l_engine_type = 'PICK' ) then
           l_rule_id := G_PICK_RULE_ID;
       elsif (l_engine_type = 'PUTAWAY' ) then
           l_rule_id := G_PUTAWAY_RULE_ID ;
       elsif (l_engine_type = 'COSTGROUP' ) then
            l_rule_id := G_COSTGROUP_RULE_ID ;
       else
          return Null;
       end if;
       --
       if (l_rule_id <> 0 )  then
         select name into l_rule
           from wms_rules_vl
	  where organization_id in (l_org_id, -1)
            and rule_id = l_rule_id;
       else
         return Null;
      end if;
      return l_rule;
   EXCEPTION
    WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN NULL;
  END;


-- Function to get the costgroup name based on the G_Costgroup_ID
--- G_costgroup_id is updated by Rules Engine API

 FUNCTION get_costgroup_name ( engine_type IN VARCHAR2
                             ,org_id      IN NUMBER)
   RETURN  VARCHAR2 is
    l_costgroup         VARCHAR2(80)   := NULL;
    l_costgroup_id       NUMBER          ;
    l_org_id            NUMBER          ;
    l_engine_type       VARCHAR2(20)   := NULL;
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'get_rule_name';
   BEGIN
        l_engine_type  := engine_type;
        l_org_id       := org_id;
        l_costgroup_id := G_COSTGROUP_ID ;

       --
       if (l_costgroup_id <> 0 )  then
         select cost_group into l_costgroup
           from cst_cost_groups
	      where organization_id in (l_org_id, -1)
            and cost_group_id = l_costgroup_id;
       else
         return Null;
      end if;
      return l_costgroup;
   EXCEPTION
    WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN NULL;
  END;



-- Function to get the costgroup Desc based on the G_Costgroup_ID
--- G_costgroup_id is updated by Rules Engine API

 FUNCTION get_costgroup_desc ( engine_type IN VARCHAR2
                             ,org_id      IN NUMBER)
   RETURN  VARCHAR2 is
    l_costgroup_desc         VARCHAR2(80)   := NULL;
    l_costgroup_id           NUMBER          ;
    l_org_id                 NUMBER          ;
    l_engine_type            VARCHAR2(20)   := NULL;
    g_pkg_name constant      VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant      VARCHAR2(30)   := 'get_rule_name';
   BEGIN
        l_engine_type  := engine_type;
        l_org_id       := org_id;
        l_costgroup_id := G_COSTGROUP_ID ;

       --
       if (l_costgroup_id <> 0 )  then
         select cost_group into l_costgroup_desc
           from cst_cost_groups
	      where organization_id in (l_org_id, -1)
            and cost_group_id = l_costgroup_id;
       else
         return Null;
      end if;
      return l_costgroup_desc;
   EXCEPTION
    WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN NULL;
  END;

   --- Initilize Global Variables
   ------------------------------------------------------
  Procedure  init_global_variables is
    begin
  --- Pick Search order Global Variables

    G_PICK_BUSINESS_OBJECT_ID   := NULL;
    G_PICK_OBJECT               := NULL;
    G_PICK_PK1_VALUE            := NULL;
    G_PICK_PK2_VALUE            := NULL;
    G_PICK_PK3_VALUE            := NULL;
    G_PICK_PK4_VALUE            := NULL;
    G_PICK_PK5_VALUE            := NULL;
    G_PICK_STRATEGY_ID          := NULL;
    G_PICK_RULE_ID              := NULL;
    G_PICK_HEADER_ID            := NULL;
    G_PICK_SEQ_NUM              := NULL;

    --- Putaway  Search order Global Variables

    G_PUTAWAY_BUSINESS_OBJECT_ID     := null;
    G_PUTAWAY_OBJECT            := null;
    G_PUTAWAY_PK1_VALUE         := NULL;
    G_PUTAWAY_PK2_VALUE         := NULL;
    G_PUTAWAY_PK3_VALUE         := NULL;
    G_PUTAWAY_PK4_VALUE         := NULL;
    G_PUTAWAY_PK5_VALUE         := NULL;
    G_PUTAWAY_STRATEGY_ID       := null;
    G_PUTAWAY_RULE_ID           := NULL;
    G_PUTAWAY_HEADER_ID         := NULL;
    G_PUTAWAY_SEQ_NUM           := NULL;

    --- Cost Group Search order Global Variables

    G_COSTGROUP_BUSINESS_OBJECT_ID   := null;
    G_COSTGROUP_OBJECT               := null;
    G_COSTGROUP_PK1_VALUE            := NULL;
    G_COSTGROUP_PK2_VALUE            := NULL;
    G_COSTGROUP_PK3_VALUE            := NULL;
    G_COSTGROUP_PK4_VALUE            := NULL;
    G_COSTGROUP_PK5_VALUE            := NULL;
    G_COSTGROUP_STRATEGY_ID          := null;
    G_COSTGROUP_RULE_ID              := NULL;
    G_COSTGROUP_SEQ_NUM              := NULL;


    G_COSTGROUP_ID                   := NULL;
    ----
    G_SIMULATION_MODE                := 'N' ;
  end   init_global_variables ;
  -------------------------------------------------------

  Procedure Simulate_rules        ( p_mo_line_id IN VARCHAR2,
          p_simulation_flag       IN NUMBER,
          p_simulation_id         IN NUMBER,
          x_msg_data              OUT  NOCOPY varchar2,
          x_return_status         OUT  NOCOPY varchar2,
          x_return_status_qty     OUT  NOCOPY varchar2
         ) is

     	l_return_status_qty varchar2(1);
     	l_return_status varchar2(1);
     	l_msg_count number;
     	l_msg_data varchar2(240);
     	l_start date;
	l_end date;
	l_message varchar2(1000);
	l_changed number;
	l_reservations inv_reservation_global.mtl_reservation_tbl_type;
	l_line_id NUMBER;
        l_simulation_mode NUMBER;
        l_simulation_id NUMBER;
        l_rec_count Number;

        l_debug    NUMBER;

        l_organization_id number;
        l_inventory_item_id number;
begin

   l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       --
   If l_debug = 1  THEN
      log_procedure('WMS_SEARCH_ORDER_GLOBALS_PVT', 'Simulate Rule', 'Start Simulate Rules');
      log_event('WMS_SEARCH_ORDER_GLOBALS_PVT', 'init_global_variables', 'Populate Item details in Suggestion Block');
      log_event('WMS_SEARCH_ORDER_GLOBALS_PVT', 'Delete', 'Deleteting  all records from WTT');
   End if;
   --- Populate Item details in Suggestion Block ---
   l_line_id 		:=   p_mo_line_id;
   l_simulation_id 	:=   p_simulation_id;
   l_simulation_mode 	:=   p_simulation_flag;

  ---- Initilizeing Search Order Global Variables
   wms_search_order_globals_pvt.init_global_variables;

   rollback;
   inv_quantity_tree_pvt.clear_quantity_cache;
  --- Deleteting  all records from WTT
   delete  wms_transactions_temp ;

  ---  Deleting All record  from mmtt
   delete  mtl_material_transactions_temp
     where move_order_line_id = l_line_id;

  ---- Deleting trace header and line records  based on  Gobal Variables

   DELETE_TRACE_ROWS;   --(l_line_id);
   G_SIMULATION_MODE := 'Y' ;

   if l_debug = 1 then
       log_procedure('WMS_SEARCH_ORDER_GLOBALS_PVT', 'create_suggestions',
                       'Calling wms_engine_pvt.create_suggestions ');
       log_statement('SEARCH_ORDER_GLOBALS', 'p_transaction_temp_id =>' ,to_char(l_line_id));
       log_statement('', 'p_simulation_id       =>' ,to_char(l_simulation_id));
       log_statement('', 'p_simulation_mode     =>' ,to_char(l_simulation_id));
   end if;

    wms_engine_pvt.create_suggestions
     (
      p_api_version           => 1.0,
      p_init_msg_list         => fnd_api.g_true,
      p_commit                => fnd_api.g_false,
      p_validation_level      => fnd_api.g_valid_level_full,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_transaction_temp_id   => l_line_id,
      p_reservations          => l_reservations,
      p_suggest_serial        => fnd_api.g_true,
      p_simulation_id 	      => l_simulation_id,
      p_simulation_mode       => l_simulation_mode );

      x_return_status  :=  l_return_status;
      x_msg_data       := l_msg_data;

      if l_debug = 1 then
      log_statement('', 'x_return_status     =>' ,l_return_status );
      end if;

   ---------------

if ( l_return_status = 'S' ) then

       select organization_id, inventory_item_id
        into l_organization_id, l_inventory_item_id
        from mtl_txn_request_lines
       where line_id = l_line_id;

       if l_debug = 1 then
              log_procedure('WMS_SEARCH_ORDER_GLOBALS_PVT', 'release_lock',
                              'Calling inv_quantity_tree_pvt.release_lock');
       end if;

   inv_quantity_tree_pvt.release_lock(
       p_api_version_number   => 1.0
     , p_init_msg_lst         => fnd_api.g_false
     , x_return_status        => l_return_status_qty
     , x_msg_count            => l_msg_count
     , x_msg_data             => l_msg_data
     , p_organization_id      => l_organization_id
     , p_inventory_item_id    => l_inventory_item_id);

   end if;

       x_return_status_qty  :=  l_return_status_qty;
      if l_debug = 1 then
         log_procedure('', 'End ',
                                 ' End of Simulate Rules');
      end if;
  end;
  -----------------------------------------------------------------------------------
  ----- This procedure is called by Create Suggestions for inserting Trace data
  ----- in Header and lines tables. Data is inserted into trace tables in simulation
  ----- mode as well as in production mode it the debug flag is set to 'Y'

  ----- One record is inserted for Picking Simulation and one record is inserted for
  ----- Putaway simulation. In case of Transfer Picking_header_id is stored in the putaway
  ----- record
  -----------------------------------------------------------------------------------
  procedure insert_trace_header
  (
    p_api_version         	in  NUMBER
   ,p_init_msg_list       	in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level    	in  NUMBER   DEFAULT fnd_api.g_valid_level_full
   ,x_return_status       	out NOCOPY VARCHAR2
   ,x_msg_count           	out NOCOPY number
   ,x_msg_data            	out NOCOPY varchar2
   ,x_header_id 		out NOCOPY NUMBER
   ,p_pick_header_id    	in  NUMBER
   ,p_move_order_line_id        in NUMBER
   ,p_total_qty                 in  NUMBER
   ,p_secondary_total_qty       in  NUMBER
   ,p_type_code 		in  NUMBER
   ,p_business_object_id        in  NUMBER
   ,p_object_id 		in  NUMBER
   ,p_strategy_id      	        in NUMBER
  )  IS
     -- API standard variables
     l_api_version         constant number       := 1.0;
     g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
     l_api_name            constant varchar2(30) := ' insert_trace_header';
     l_return_status 	   VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_row_id        	   VARCHAR2(20);
     l_object_name         VARCHAR2(4000);
     l_engine_type         VARCHAR2(20)   := NULL;
     l_date          	   DATE;
     l_user_id       	   NUMBER;
     l_login_id      	   NUMBER;
     l_found         	   BOOLEAN;
     l_header_id           NUMBER;
     l_sid                 NUMBER;

begin

  -- Standard call to check for call compatibility
  if not fnd_api.compatible_api_call( l_api_version
                                     ,l_api_version
                                     ,l_api_name
                                     ,g_pkg_name ) then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE
  if fnd_api.to_boolean( p_init_msg_list ) then
    fnd_msg_pub.initialize;
  end if;

 IF (nvl(p_move_order_line_id,0) > 0)  then

  SELECT  wms_rule_trace_header_s.NEXTVAL INTO l_header_id FROM dual;

   /* get who column information */

   SELECT Sysdate INTO l_date FROM dual;

   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

  -- select rawtohex(dbms_session.unique_session_id) into l_sid from dual;


   if p_type_code = 2 then
       l_engine_type        := 'PICK';
   elsif p_type_code = 1 then
       l_engine_type        := 'PUTAWAY';
   end if;

   l_object_name := get_object_name(l_engine_type, 1);


   /* call the table insert row to do the insert */
    insert_headers_row
     (
       x_header_id                    => l_header_id
      ,x_pick_header_id               => p_pick_header_id
      ,x_move_order_line_id           => p_move_order_line_id
      ,x_total_qty                    => p_total_qty
      ,x_secondary_total_qty          => p_secondary_total_qty
      ,x_type_code                    => p_type_code
      ,x_business_object_id           => p_business_object_id
      ,x_object_id                    => p_object_id
      ,x_strategy_id                  => p_strategy_id
      ,x_creation_date                => l_date
      ,x_created_by                   => l_user_id
      ,x_last_update_date             => l_date
      ,x_last_updated_by              => l_user_id
      ,x_last_update_login            => l_login_id
      ,x_object_name                  => l_object_name
      ,x_simulation_mode              => G_simulation_mode
      ,x_sid                          => l_login_id
     );

   x_return_status := l_return_status;
   x_header_id      := l_header_id;

   ---- Storing header ID in Global Variables for deleting the trace records
   ---- before next simulation
   if ( nvl(p_pick_header_id,0) > 0 ) then
        G_PUTAWAY_HEADER_ID :=  l_header_id;
   else
        G_PICK_HEADER_ID    :=  l_header_id;
   end if ;
end if;
EXCEPTION
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    end if;
   /* fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );*/

end  insert_trace_header;
------------------------------------------------------------------------------------
---- Based on the rows im the WMS_SEARCH_ORDER_GLOBALS_PVT.pre_suggestions_record_tbl
---- equal number of records are created in the trace lines table for each Header Id
--------------------------------------------------------------------------------------
 procedure insert_trace_lines
  (
    p_api_version         	in  NUMBER
   ,p_init_msg_list       	in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level    	in  NUMBER   DEFAULT fnd_api.g_valid_level_full
   ,x_return_status       	out NOCOPY VARCHAR2
   ,x_msg_count           	out NOCOPY number
   ,x_msg_data            	out NOCOPY varchar2
   ,p_header_id  		in  NUMBER
   ,p_rule_id                   in  NUMBER
   ,p_pre_suggestions           in  WMS_SEARCH_ORDER_GLOBALS_PVT.pre_suggestions_record_tbl
  )  IS
     -- API standard variables
     g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
     l_api_version         constant number      	 := 1.0;
     l_api_name            constant varchar2(30) 	 := 'insert_trace_lines';
     l_return_status 	   VARCHAR2(1) 		         := fnd_api.g_ret_sts_success;
     l_date          	   DATE;
     l_user_id       	   NUMBER;
     l_login_id      	   NUMBER;
     l_found         	   BOOLEAN;
     l_line_id             NUMBER;
     l_pre_suggestions     WMS_SEARCH_ORDER_GLOBALS_PVT.pre_suggestions_record ;
     l_header_id           NUMBER;
     l_rule_id             NUMBER;
     l_index               BINARY_INTEGER;
begin

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

 if ( nvl(p_header_id ,0 ) > 0 and nvl(p_rule_id,0)  > 0 ) then

  /* get who column information */
   SELECT Sysdate INTO l_date FROM dual;
   l_user_id    	:= fnd_global.user_id;
   l_login_id   	:= fnd_global.login_id;

  -- l_pre_suggestions  	:= p_pre_suggestions  ;
   l_header_id  	:= p_header_id;
   l_rule_id    	:= p_rule_id;

   l_index 		:= p_pre_suggestions.FIRST;
LOOP
  -- Bug #3107777
  if l_index is null then
     exit;
  end if;
  SELECT  wms_rule_trace_lines_s.NEXTVAL INTO l_line_id FROM dual;

   /* call the table insert procedure  to do the insert */
    insert_lines_row
     (
       x_header_id                       => l_header_id
      ,x_line_id                         => l_line_id
      ,x_rule_id                         => l_rule_id
      ,x_quantity                        => p_pre_suggestions(l_index).quantity
      ,x_revision                        => p_pre_suggestions(l_index).revision
      ,x_lot_number                      => p_pre_suggestions(l_index).lot_number
      ,x_lot_expiration_date             => p_pre_suggestions(l_index).lot_expiration_date
      ,x_serial_number                   => p_pre_suggestions(l_index).serial_number
      ,x_subinventory_code               => p_pre_suggestions(l_index).subinventory_code
      ,x_locator_id                      => p_pre_suggestions(l_index).locator_id
      ,x_lpn_id                          => p_pre_suggestions(l_index).lpn_id
      ,x_cost_group_id                   => p_pre_suggestions(l_index).cost_group_id
      ,x_uom_code                        => p_pre_suggestions(l_index).uom_code
      ,x_remaining_qty                   => p_pre_suggestions(l_index).remaining_qty
      ,x_ATT_qty                         => p_pre_suggestions(l_index).ATT_qty
      ,x_suggested_qty                   => p_pre_suggestions(l_index).suggested_qty
      ,x_sec_uom_code                    => p_pre_suggestions(l_index).secondary_uom_code               --new
      ,x_sec_qty                         => p_pre_suggestions(l_index).secondary_qty                    --new
      ,x_sec_ATT_qty                     => p_pre_suggestions(l_index).secondary_ATT_qty	               --new
      ,x_sec_suggested_qty               => p_pre_suggestions(l_index).secondary_suggested_qty          --new
      ,x_grade_code                      => p_pre_suggestions(l_index).grade_code                       --new
      ,x_same_subinv_loc_flag            => p_pre_suggestions(l_index).same_subinv_loc_flag
      ,x_ATT_qty_flag                    => p_pre_suggestions(l_index).ATT_qty_flag
      ,x_consist_string_flag             => p_pre_suggestions(l_index).consist_string_flag
      ,x_order_string_flag               => p_pre_suggestions(l_index).order_string_flag
      ,x_Material_status_flag            => p_pre_suggestions(l_index).Material_status_flag
      ,x_Pick_UOM_flag                   => p_pre_suggestions(l_index).Pick_UOM_flag
      ,x_partial_pick_flag               => p_pre_suggestions(l_index).partial_pick_flag
      ,x_Serial_number_used_flag         => p_pre_suggestions(l_index).Serial_number_used_flag
      ,x_CG_comingle_flag                => p_pre_suggestions(l_index).CG_comingle_flag
      ,x_entire_lpn_flag                 => p_pre_suggestions(l_index).entire_lpn_flag
      ,x_comments                        => p_pre_suggestions(l_index).comments
      ,x_creation_date                   => l_date
      ,x_created_by                      => l_user_id
      ,x_last_update_date                => l_date
      ,x_last_updated_by                 => l_user_id
      ,x_last_update_login               => l_login_id
         );
      EXIT WHEN l_index =  p_pre_suggestions.LAST;
      l_index := p_pre_suggestions.NEXT(l_index);

  END LOOP;
      x_return_status := l_return_status;
  end if;
EXCEPTION
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    end if;
    /*fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data ); */

end  insert_trace_lines;

-----------------------------------------------------------------------
------------------------------------------------------------------------
  Procedure   insert_headers_row
     (
     x_header_id  		IN  NUMBER,
     x_pick_header_id           IN  NUMBER,
     x_move_order_line_id	IN  NUMBER,
     x_total_qty                IN  NUMBER,
     x_secondary_total_qty      IN  NUMBER,
     x_type_code                IN  NUMBER,
     x_business_object_id       IN  NUMBER,
     x_object_id                IN  NUMBER,
     x_strategy_id              IN  NUMBER,
     x_last_updated_by          IN  NUMBER,
     x_last_update_date         IN  DATE ,
     x_created_by               IN  NUMBER ,
     x_creation_date            IN  DATE   ,
     x_last_update_login        IN  NUMBER ,
     x_object_name              IN  VARCHAR2,
     x_simulation_mode          IN  VARCHAR2,
     x_sid                      IN  NUMBER
        )
is
---- This API Call is a Autonomous Procedure ---------------

PRAGMA AUTONOMOUS_TRANSACTION;
-----
begin
  INSERT into  WMS_RULE_TRACE_HEADERS (
       header_id
      ,pick_header_id
      ,move_order_line_id
      ,total_qty
      ,secondary_total_qty
      ,type_code
      ,business_object_id
      ,object_id
      ,strategy_id
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,object_name
      ,simulation_mode
      ,sid
    ) VALUES
   (
       x_header_id
      ,x_pick_header_id
      ,x_move_order_line_id
      ,x_total_qty
      ,x_secondary_total_qty
      ,x_type_code
      ,x_business_object_id
      ,x_object_id
      ,x_strategy_id
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_object_name
      ,x_simulation_mode
      ,x_sid
);
commit;
end   insert_headers_row;

-----------------------------------------------------
Procedure   insert_lines_row
     (
       x_header_id                       IN  NUMBER
      ,x_line_id                         IN  NUMBER
      ,x_rule_id                         IN  NUMBER
      ,x_quantity                        IN  NUMBER
      ,x_revision                        IN  VARCHAR2
      ,x_lot_number                      IN  VARCHAR2
      ,x_lot_expiration_date             IN  DATE
      ,x_serial_number                   IN  VARCHAR2
      ,x_subinventory_code               IN  VARCHAR2
      ,x_locator_id                      IN  NUMBER
      ,x_lpn_id                          IN  NUMBER
      ,x_cost_group_id                   IN  NUMBER
      ,x_uom_code                        IN  VARCHAR2
      ,x_remaining_qty                   IN  NUMBER
      ,x_ATT_qty                         IN  NUMBER
      ,x_suggested_qty                   IN  NUMBER
      ,x_sec_uom_code                    IN  VARCHAR2                  -- new
      ,x_sec_qty                         IN  NUMBER                    -- new
      ,x_sec_ATT_qty                     IN  NUMBER                    -- new
      ,x_sec_suggested_qty               IN  NUMBER                    -- new
      ,x_grade_code                      IN  VARCHAR2                  -- new
      ,x_same_subinv_loc_flag            IN  VARCHAR2
      ,x_ATT_qty_flag                    IN  VARCHAR2
      ,x_consist_string_flag             IN  VARCHAR2
      ,x_order_string_flag               IN  VARCHAR2
      ,x_Material_status_flag            IN  VARCHAR2
      ,x_Pick_UOM_flag                   IN  VARCHAR2
      ,x_partial_pick_flag               IN  VARCHAR2
      ,x_Serial_number_used_flag         IN  VARCHAR2
      ,x_CG_comingle_flag                IN  VARCHAR2
      ,x_entire_lpn_flag                 IN  VARCHAR2
      ,x_comments                        IN  VARCHAR2
      ,x_creation_date                   IN  DATE
      ,x_created_by                      IN  NUMBER
      ,x_last_update_date                IN  DATE
      ,x_last_updated_by                 IN  NUMBER
      ,x_last_update_login               IN  NUMBER
    )
   is
   ---- This API Call is a Autonomous Procedure ---------------

   PRAGMA AUTONOMOUS_TRANSACTION;
   ----
  begin
        insert into WMS_RULE_TRACE_LINES
      (
          header_id
          ,line_id
          ,rule_id
          ,quantity
          ,revision
          ,lot_number
          ,lot_expiration_date
          ,serial_number
          ,subinventory_code
          ,locator_id
          ,lpn_id
          ,cost_group_id
          ,uom_code
          ,remaining_qty
          ,ATT_qty
          ,suggested_qty                             -- new
          ,secondary_uom_code                        -- new
          ,secondary_quantity                        -- new
          ,secondary_ATT_qty                         -- new
          ,secondary_suggested_qty                   -- new
          ,grade_code                                -- new
          ,same_subinv_loc_flag
          ,ATT_qty_flag
          ,consist_string_flag
          ,order_string_flag
          ,Material_status_flag
          ,Pick_UOM_flag
          ,partial_pick_flag
          ,Serial_number_used_flag
          ,CG_comingle_flag
          ,entire_lpn_flag
          ,comments
          ,last_updated_by
          ,last_update_date
          ,created_by
          ,creation_date
          ,last_update_login
      ) VALUES
      (
           x_header_id
          ,x_line_id
          ,x_rule_id
          ,x_quantity
          ,x_revision
          ,x_lot_number
          ,x_lot_expiration_date
          ,x_serial_number
          ,x_subinventory_code
          ,x_locator_id
          ,x_lpn_id
          ,x_cost_group_id
          ,x_uom_code
          ,x_remaining_qty
          ,x_ATT_qty
          ,x_suggested_qty
          ,x_sec_uom_code                        -- new
          ,x_sec_qty                             -- new
          ,x_sec_ATT_qty                         -- new
          ,x_sec_suggested_qty                   -- new
          ,x_grade_code
          ,x_same_subinv_loc_flag
          ,x_ATT_qty_flag
          ,x_consist_string_flag
          ,x_order_string_flag
          ,x_Material_status_flag
          ,x_Pick_UOM_flag
          ,x_partial_pick_flag
          ,x_Serial_number_used_flag
          ,x_CG_comingle_flag
          ,x_entire_lpn_flag
          ,x_comments
          ,x_last_updated_by
          ,x_last_update_date
          ,x_created_by
          ,x_creation_date
          ,x_last_update_login
);
commit;
end   insert_lines_row;
------------------------------------------------------
----------------------------------
-- Function that return 'Y' and 'N' if the passed item_id is
-- in Global Variables

 FUNCTION  IS_Object_selected ( p_move_order_line_id number,
                                p_engine_type Varchar2,
                                p_object_type varchar2,
                                p_object_id number )
   RETURN  VARCHAR2 is
    l_object_type       VARCHAR2(80)   := NULL;
    l_object_id         NUMBER         := NULL;
    l_engine_type       VARCHAR2(20)   := NULL;
    l_return_status     VARCHAR2(1)    := 'N';
    l_rule_id           NUMBER;
    l_line_id           NUMBER;

    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'IS_object_Selected';

    BEGIN
       l_engine_type := p_engine_type;
       l_object_type := p_object_type;
       l_object_id   := p_object_id;
       l_line_id     := p_move_order_line_id ;
       --
       --
       if (l_engine_type = 'PICK' ) then

          if   ( l_object_type = 'SO' ) then
                 if (l_object_id = G_PICK_BUSINESS_OBJECT_ID ) then
                     l_return_status := 'Y';
                 end if;
          elsif   ( l_object_type = 'STG' ) then
                 if (l_object_id = G_PICK_STRATEGY_ID ) then
                     l_return_status := 'Y';
                 end if;
         elsif   ( l_object_type = 'RULE' ) then
                 begin
                    select distinct pick_rule_id into l_rule_id
                      from wms_suggestions_temp_v
                     where pick_rule_id = l_object_id ;
                     --  and move_order_line_id = l_line_id;

                     if (l_object_id = l_rule_id ) then
                         l_return_status := 'Y';
                     end if;
                exception
                   when no_data_found then
                        l_return_status := 'N';

                end ;

         end if;

       elsif (l_engine_type = 'PUTAWAY' ) then

          if   ( l_object_type = 'SO' ) then
                 if (l_object_id = G_PUTAWAY_BUSINESS_OBJECT_ID ) then
                     l_return_status := 'Y';
                 end if;
         elsif   ( l_object_type = 'STG' ) then
                 if (l_object_id = G_PUTAWAY_STRATEGY_ID ) then
                     l_return_status := 'Y';
                 end if;
          end if;

      elsif (l_engine_type = 'COSTGROUP' ) then

          if   ( l_object_type = 'SO' ) then
                 if (l_object_id =  G_COSTGROUP_BUSINESS_OBJECT_ID ) then
                     l_return_status := 'Y';
                 end if;
         elsif   ( l_object_type = 'STG' ) then
                 if (l_object_id =  G_COSTGROUP_STRATEGY_ID ) then
                     l_return_status := 'Y';
                 end if;
         elsif   ( l_object_type = 'RULE' ) then
                 if (l_object_id = G_COSTGROUP_RULE_ID ) then
                     l_return_status := 'Y';
                 end if;

         end if;

       end if;
      return l_return_status;
   EXCEPTION
     WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN  'N';
  END IS_Object_selected;

---------------------------------
--- Overloaded Function ---------
-- Function that return 'Y' and 'N' if the passed item_id is
-- in Global Variables

 FUNCTION  IS_BO_Object_selected ( p_move_order_line_id number,
                                p_engine_type Varchar2,     /*'PICK', 'PUTAWAY' .. */
                                p_object_type varchar2,     /* 'SO', 'BO' ... */
                                p_object      varchar2 )    /* object  name*/
   RETURN  VARCHAR2 is
    l_object_type       VARCHAR2(80)   := NULL;
    l_object            varchar2(50)   := NULL;
    l_engine_type       VARCHAR2(20)   := NULL;
    l_return_status     VARCHAR2(1)    := 'N';
    l_rule_id           NUMBER;
    l_line_id           NUMBER;
    l_org_id            NUMBER;
    l_g_object          VARCHAR2(50);   /* to Hold the G_PICK_OBJECT/ G_PUTAWAY_OBJECT /G_COSTGROUP_OBJECT value */

    g_pkg_name constant VARCHAR2(50)   := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
    l_api_name constant VARCHAR2(30)   := 'IS_BO_object_Selected';


    BEGIN
       l_engine_type := p_engine_type;
       l_object_type := p_object_type;
       l_line_id     := p_move_order_line_id ;
       l_object      := p_object;
       --
       --

       if l_line_id > 0 then
           select organization_id into l_org_id
           from mtl_txn_request_lines
           where line_id = l_line_id;
       end if;

        if (l_engine_type = 'PICK' ) then
             if (WMS_SEARCH_ORDER_GLOBALS_PVT.G_PICK_OBJECT is not null ) then
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_PICK_OBJECT;
              else
                  WMS_SEARCH_ORDER_GLOBALS_PVT.G_PICK_OBJECT := get_object_name(l_engine_type, l_org_id);
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_PICK_OBJECT;
              end if;
        elsif (l_engine_type = 'PUTAWAY') then
            if (WMS_SEARCH_ORDER_GLOBALS_PVT.G_PUTAWAY_OBJECT is not null ) then
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_PUTAWAY_OBJECT;
              else
                  WMS_SEARCH_ORDER_GLOBALS_PVT.G_PUTAWAY_OBJECT := get_object_name(l_engine_type, l_org_id);
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_PUTAWAY_OBJECT;
              end if;
       elsif (l_engine_type = 'COSTGROUP') then
            if (WMS_SEARCH_ORDER_GLOBALS_PVT.G_COSTGROUP_OBJECT is not null ) then
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_COSTGROUP_OBJECT;
              else
                  WMS_SEARCH_ORDER_GLOBALS_PVT.G_COSTGROUP_OBJECT := get_object_name(l_engine_type, l_org_id);
                  l_g_object := WMS_SEARCH_ORDER_GLOBALS_PVT.G_COSTGROUP_OBJECT;
              end if;
       end if;
          IF (l_g_object = l_object ) then
               l_return_status := 'Y';
          else
                 l_return_status := 'N';
          end if;

      return l_return_status;
   EXCEPTION
     WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN  'N';

   END IS_BO_Object_selected;
-----------------------------------------------------------------------------
--- Trace Tables to be deleted  - WMS_RULE_TRACE_HEADERS, WMS_RULE_TRACE_LINES
 -- Deleting trace header and line records  based on  Gobal Variables
--- stored at the time of Insert header row for Picking and Putaway
--- Records. After deleting the trace records G_PICK_HEADER_ID and
--- G_PUTAWAY_HEADER_ID is initilized to 0

PROCEDURE DELETE_TRACE_ROWS is
PRAGMA AUTONOMOUS_TRANSACTION;
l_user_id number;
l_login_id number;
BEGIN

   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   -- Deleteing all trace records created in simulation mode for this user
             delete wms_rule_trace_lines
              where header_id in (select header_id
                           from wms_rule_trace_headers
                           where  simulation_mode = 'Y'
                            and   sid = l_login_id);
            delete wms_rule_trace_headers
            where simulation_mode = 'Y'
              and sid = l_login_id;
      COMMIT;
  --end if;
END   DELETE_TRACE_ROWS;
--------------------------
-------------------------------------------------
--- This procedure call is used to populate records into
--- Three temp table one for each material suggestions, lot numbers
--- and serial number tables. Lot and Serial Tables will be populated
--- based on the lot_insert_flag and serial_insert_flags
--- '0' - for no records to be inserted and '1' for records to be inserted
--- The data in these three tables will be used by Run Time trace form

 procedure insert_txn_trace_rows(
    p_api_version               in  NUMBER
   ,p_init_msg_list             in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level          in  NUMBER    DEFAULT fnd_api.g_valid_level_full
   ,x_return_status             out NOCOPY VARCHAR2
   ,x_msg_count                 out NOCOPY number
   ,x_msg_data                  out NOCOPY varchar2
   ,p_txn_header_id 		in  number
   ,p_insert_lot_flag           in  number
   ,p_insert_serial_flag        in  number) is

     ---- This API Call is a Autonomous Procedure ---------------
  --- PRAGMA AUTONOMOUS_TRANSACTION;

    -- API standard variables
     l_api_version         constant number       := 1.0;
     g_pkg_name constant   VARCHAR2(50)          := 'WMS_SEARCH_ORDER_GLOBALS_PVT';
     l_api_name            constant varchar2(30) := 'insert_txn_trace_rows';
     l_return_status       VARCHAR2(1)           := fnd_api.g_ret_sts_success;
     l_txn_header_id       number;
     l_insert_lot_flag     number;
     l_insert_serial_flag  number;

 begin

    l_txn_header_id            := nvl(p_txn_header_id,0);
    l_insert_lot_flag          := nvl(p_insert_lot_flag,0);
    l_insert_serial_flag       := nvl(p_insert_serial_flag,0);

    -- Standard call to check for call compatibility

   if not fnd_api.compatible_api_call( l_api_version
                                     ,l_api_version
                                     ,l_api_name
                                     ,g_pkg_name ) then
       raise fnd_api.g_exc_unexpected_error;
   end if;

--- If transaction_header id passed is not null records inserted into following tables
---

If ( l_txn_header_id > 0) then

insert into WMS_MATERIAL_TXN_TRACE
 (
 TRANSACTION_HEADER_ID          ,
 TRANSACTION_TEMP_ID            ,
 SOURCE_CODE                     ,
 SOURCE_LINE_ID                ,
 TRANSACTION_MODE              ,
 LOCK_FLAG                     ,
 LAST_UPDATE_DATE              ,
 LAST_UPDATED_BY                ,
 CREATION_DATE                ,
 CREATED_BY                   ,
 LAST_UPDATE_LOGIN                 ,
 REQUEST_ID                     ,
 PROGRAM_APPLICATION_ID           ,
 PROGRAM_ID                       ,
 PROGRAM_UPDATE_DATE             ,
 INVENTORY_ITEM_ID            ,
 REVISION                      ,
 ORGANIZATION_ID               ,
 SUBINVENTORY_CODE             ,
 LOCATOR_ID                     ,
 TRANSACTION_QUANTITY           ,
 PRIMARY_QUANTITY               ,
 TRANSACTION_UOM                ,
 TRANSACTION_COST               ,
 TRANSACTION_TYPE_ID             ,
 TRANSACTION_ACTION_ID          ,
 TRANSACTION_SOURCE_TYPE_ID    ,
 TRANSACTION_SOURCE_ID         ,
 TRANSACTION_SOURCE_NAME       ,
 TRANSACTION_DATE              ,
 ACCT_PERIOD_ID                ,
 DISTRIBUTION_ACCOUNT_ID       ,
 TRANSACTION_REFERENCE         ,
 REQUISITION_LINE_ID           ,
 REQUISITION_DISTRIBUTION_ID   ,
 REASON_ID                     ,
 LOT_NUMBER                 ,
 LOT_EXPIRATION_DATE            ,
 SERIAL_NUMBER                 ,
 RECEIVING_DOCUMENT              ,
 DEMAND_ID                       ,
 RCV_TRANSACTION_ID              ,
 MOVE_TRANSACTION_ID            ,
 COMPLETION_TRANSACTION_ID       ,
 WIP_ENTITY_TYPE                ,
 SCHEDULE_ID                    ,
 REPETITIVE_LINE_ID             ,
 EMPLOYEE_CODE                  ,
 PRIMARY_SWITCH                 ,
 SCHEDULE_UPDATE_CODE           ,
 SETUP_TEARDOWN_CODE             ,
 ITEM_ORDERING                 ,
 NEGATIVE_REQ_FLAG             ,
 OPERATION_SEQ_NUM              ,
 PICKING_LINE_ID                 ,
 TRX_SOURCE_LINE_ID              ,
 TRX_SOURCE_DELIVERY_ID          ,
 PHYSICAL_ADJUSTMENT_ID          ,
 CYCLE_COUNT_ID                  ,
 RMA_LINE_ID                     ,
 CUSTOMER_SHIP_ID                ,
 CURRENCY_CODE                   ,
 CURRENCY_CONVERSION_RATE        ,
 CURRENCY_CONVERSION_TYPE        ,
 CURRENCY_CONVERSION_DATE         ,
 USSGL_TRANSACTION_CODE          ,
 VENDOR_LOT_NUMBER              ,
 ENCUMBRANCE_ACCOUNT            ,
 ENCUMBRANCE_AMOUNT               ,
 SHIP_TO_LOCATION                ,
 SHIPMENT_NUMBER                ,
 TRANSFER_COST                   ,
 TRANSPORTATION_COST                      ,
 TRANSPORTATION_ACCOUNT                   ,
 FREIGHT_CODE                             ,
 CONTAINERS                               ,
 WAYBILL_AIRBILL                          ,
 EXPECTED_ARRIVAL_DATE                    ,
 TRANSFER_SUBINVENTORY                    ,
 TRANSFER_ORGANIZATION                    ,
 TRANSFER_TO_LOCATION                     ,
 NEW_AVERAGE_COST                         ,
 VALUE_CHANGE                             ,
 PERCENTAGE_CHANGE                        ,
 MATERIAL_ALLOCATION_TEMP_ID              ,
 DEMAND_SOURCE_HEADER_ID                  ,
 DEMAND_SOURCE_LINE                       ,
 DEMAND_SOURCE_DELIVERY                   ,
 ITEM_SEGMENTS                            ,
 ITEM_DESCRIPTION                         ,
 ITEM_TRX_ENABLED_FLAG                    ,
 ITEM_LOCATION_CONTROL_CODE               ,
 ITEM_RESTRICT_SUBINV_CODE                ,
 ITEM_RESTRICT_LOCATORS_CODE              ,
 ITEM_REVISION_QTY_CONTROL_CODE           ,
 ITEM_PRIMARY_UOM_CODE                    ,
 ITEM_UOM_CLASS                           ,
 ITEM_SHELF_LIFE_CODE                     ,
 ITEM_SHELF_LIFE_DAYS                     ,
 ITEM_LOT_CONTROL_CODE                    ,
 ITEM_SERIAL_CONTROL_CODE                 ,
 ITEM_INVENTORY_ASSET_FLAG                ,
 ALLOWED_UNITS_LOOKUP_CODE                ,
 DEPARTMENT_ID                            ,
 DEPARTMENT_CODE                          ,
 WIP_SUPPLY_TYPE                          ,
 SUPPLY_SUBINVENTORY                      ,
 SUPPLY_LOCATOR_ID                        ,
 VALID_SUBINVENTORY_FLAG                  ,
 VALID_LOCATOR_FLAG                      ,
 LOCATOR_SEGMENTS                         ,
 CURRENT_LOCATOR_CONTROL_CODE             ,
 NUMBER_OF_LOTS_ENTERED                        ,
 WIP_COMMIT_FLAG                          ,
 NEXT_LOT_NUMBER                         ,
 LOT_ALPHA_PREFIX                         ,
 NEXT_SERIAL_NUMBER                       ,
 SERIAL_ALPHA_PREFIX                      ,
 SHIPPABLE_FLAG                          ,
 POSTING_FLAG                             ,
 REQUIRED_FLAG                            ,
 PROCESS_FLAG                             ,
 ERROR_CODE                               ,
 ERROR_EXPLANATION                        ,
 ATTRIBUTE_CATEGORY                       ,
 ATTRIBUTE1                               ,
 ATTRIBUTE2                               ,
 ATTRIBUTE3                               ,
 ATTRIBUTE4                               ,
 ATTRIBUTE5                               ,
 ATTRIBUTE6                               ,
 ATTRIBUTE7                               ,
 ATTRIBUTE8                               ,
 ATTRIBUTE9                               ,
 ATTRIBUTE10                              ,
 ATTRIBUTE11                              ,
 ATTRIBUTE12                              ,
 ATTRIBUTE13                              ,
 ATTRIBUTE14                              ,
 ATTRIBUTE15                              ,
 MOVEMENT_ID                              ,
 RESERVATION_QUANTITY                     ,
 SHIPPED_QUANTITY                         ,
 TRANSACTION_LINE_NUMBER                  ,
 TASK_ID                                  ,
 TO_TASK_ID                               ,
 SOURCE_TASK_ID                           ,
 PROJECT_ID                               ,
 SOURCE_PROJECT_ID                        ,
 PA_EXPENDITURE_ORG_ID                    ,
 TO_PROJECT_ID                            ,
 EXPENDITURE_TYPE                         ,
 FINAL_COMPLETION_FLAG                   ,
 TRANSFER_PERCENTAGE                      ,
 TRANSACTION_SEQUENCE_ID                  ,
 MATERIAL_ACCOUNT                         ,
 MATERIAL_OVERHEAD_ACCOUNT                ,
 RESOURCE_ACCOUNT                         ,
 OUTSIDE_PROCESSING_ACCOUNT               ,
 OVERHEAD_ACCOUNT                         ,
 FLOW_SCHEDULE                            ,
 COST_GROUP_ID                            ,
 DEMAND_CLASS                             ,
 QA_COLLECTION_ID                         ,
 KANBAN_CARD_ID                           ,
 OVERCOMPLETION_TRANSACTION_QTY           ,
 OVERCOMPLETION_PRIMARY_QTY               ,
 OVERCOMPLETION_TRANSACTION_ID            ,
 END_ITEM_UNIT_NUMBER                    ,
 SCHEDULED_PAYBACK_DATE                   ,
 LINE_TYPE_CODE                           ,
 PARENT_TRANSACTION_TEMP_ID               ,
 PUT_AWAY_STRATEGY_ID                     ,
 PUT_AWAY_RULE_ID                         ,
 PICK_STRATEGY_ID                         ,
 PICK_RULE_ID                             ,
 MOVE_ORDER_LINE_ID                       ,
 TASK_GROUP_ID                            ,
 PICK_SLIP_NUMBER                        ,
 RESERVATION_ID                           ,
 COMMON_BOM_SEQ_ID                        ,
 COMMON_ROUTING_SEQ_ID                    ,
 ORG_COST_GROUP_ID                        ,
 COST_TYPE_ID                             ,
 TRANSACTION_STATUS                       ,
 STANDARD_OPERATION_ID                    ,
 TASK_PRIORITY                            ,
 WMS_TASK_TYPE                            ,
 PARENT_LINE_ID                           ,
 SOURCE_LOT_NUMBER                        ,
 TRANSFER_COST_GROUP_ID                   ,
 LPN_ID                                   ,
 TRANSFER_LPN_ID                          ,
 WMS_TASK_STATUS                          ,
 CONTENT_LPN_ID                           ,
 CONTAINER_ITEM_ID                        ,
 CARTONIZATION_ID                         ,
 PICK_SLIP_DATE                           ,
 REBUILD_ITEM_ID                          ,
 REBUILD_SERIAL_NUMBER                    ,
 REBUILD_ACTIVITY_ID                      ,
 REBUILD_JOB_NAME                        ,
 ORGANIZATION_TYPE                        ,
 TRANSFER_ORGANIZATION_TYPE               ,
 OWNING_ORGANIZATION_ID                   ,
 OWNING_TP_TYPE                           ,
 XFR_OWNING_ORGANIZATION_ID               ,
 TRANSFER_OWNING_TP_TYPE                  ,
 PLANNING_ORGANIZATION_ID                 ,
 PLANNING_TP_TYPE                         ,
 XFR_PLANNING_ORGANIZATION_ID             ,
 TRANSFER_PLANNING_TP_TYPE                ,
 SECONDARY_UOM_CODE                       ,          -- new
 SECONDARY_TRANSACTION_QUANTITY           ,          -- new
 ALLOCATED_LPN_ID                         ,
 SCHEDULE_NUMBER                          ,
 SCHEDULED_FLAG                           ,
 CLASS_CODE                               ,
 SCHEDULE_GROUP                           ,
 BUILD_SEQUENCE                           ,
 BOM_REVISION                             ,
 ROUTING_REVISION                         ,
 BOM_REVISION_DATE                        ,
 ROUTING_REVISION_DATE                    ,
 ALTERNATE_BOM_DESIGNATOR                 ,
 ALTERNATE_ROUTING_DESIGNATOR
 )
 select
 TRANSACTION_HEADER_ID          ,
 TRANSACTION_TEMP_ID            ,
 SOURCE_CODE                     ,
 SOURCE_LINE_ID                ,
 TRANSACTION_MODE              ,
 LOCK_FLAG                     ,
 LAST_UPDATE_DATE              ,
 LAST_UPDATED_BY                ,
 CREATION_DATE                ,
 CREATED_BY                   ,
 LAST_UPDATE_LOGIN                 ,
 REQUEST_ID                     ,
 PROGRAM_APPLICATION_ID           ,
 PROGRAM_ID                       ,
 PROGRAM_UPDATE_DATE             ,
 INVENTORY_ITEM_ID            ,
 REVISION                      ,
 ORGANIZATION_ID               ,
 SUBINVENTORY_CODE             ,
 LOCATOR_ID                     ,
 TRANSACTION_QUANTITY           ,
 PRIMARY_QUANTITY               ,
 TRANSACTION_UOM                ,
 TRANSACTION_COST               ,
 TRANSACTION_TYPE_ID             ,
 TRANSACTION_ACTION_ID          ,
 TRANSACTION_SOURCE_TYPE_ID    ,
 TRANSACTION_SOURCE_ID         ,
 TRANSACTION_SOURCE_NAME       ,
 TRANSACTION_DATE              ,
 ACCT_PERIOD_ID                ,
 DISTRIBUTION_ACCOUNT_ID       ,
 TRANSACTION_REFERENCE         ,
 REQUISITION_LINE_ID           ,
 REQUISITION_DISTRIBUTION_ID   ,
 REASON_ID                     ,
 LOT_NUMBER                 ,
 LOT_EXPIRATION_DATE            ,
 SERIAL_NUMBER                 ,
 RECEIVING_DOCUMENT              ,
 DEMAND_ID                       ,
 RCV_TRANSACTION_ID              ,
 MOVE_TRANSACTION_ID            ,
 COMPLETION_TRANSACTION_ID       ,
 WIP_ENTITY_TYPE                ,
 SCHEDULE_ID                    ,
 REPETITIVE_LINE_ID             ,
 EMPLOYEE_CODE                  ,
 PRIMARY_SWITCH                 ,
 SCHEDULE_UPDATE_CODE           ,
 SETUP_TEARDOWN_CODE             ,
 ITEM_ORDERING                 ,
 NEGATIVE_REQ_FLAG             ,
 OPERATION_SEQ_NUM              ,
 PICKING_LINE_ID                 ,
 TRX_SOURCE_LINE_ID              ,
 TRX_SOURCE_DELIVERY_ID          ,
 PHYSICAL_ADJUSTMENT_ID          ,
 CYCLE_COUNT_ID                  ,
 RMA_LINE_ID                     ,
 CUSTOMER_SHIP_ID                ,
 CURRENCY_CODE                   ,
 CURRENCY_CONVERSION_RATE        ,
 CURRENCY_CONVERSION_TYPE        ,
 CURRENCY_CONVERSION_DATE         ,
 USSGL_TRANSACTION_CODE          ,
 VENDOR_LOT_NUMBER              ,
 ENCUMBRANCE_ACCOUNT            ,
 ENCUMBRANCE_AMOUNT               ,
 SHIP_TO_LOCATION                ,
 SHIPMENT_NUMBER                ,
 TRANSFER_COST                   ,
 TRANSPORTATION_COST                      ,
 TRANSPORTATION_ACCOUNT                   ,
 FREIGHT_CODE                             ,
 CONTAINERS                               ,
 WAYBILL_AIRBILL                          ,
 EXPECTED_ARRIVAL_DATE                    ,
 TRANSFER_SUBINVENTORY                    ,
 TRANSFER_ORGANIZATION                    ,
 TRANSFER_TO_LOCATION                     ,
 NEW_AVERAGE_COST                         ,
 VALUE_CHANGE                             ,
 PERCENTAGE_CHANGE                        ,
 MATERIAL_ALLOCATION_TEMP_ID              ,
 DEMAND_SOURCE_HEADER_ID                  ,
 DEMAND_SOURCE_LINE                       ,
 DEMAND_SOURCE_DELIVERY                   ,
 ITEM_SEGMENTS                            ,
 ITEM_DESCRIPTION                         ,
 ITEM_TRX_ENABLED_FLAG                    ,
 ITEM_LOCATION_CONTROL_CODE               ,
 ITEM_RESTRICT_SUBINV_CODE                ,
 ITEM_RESTRICT_LOCATORS_CODE              ,
 ITEM_REVISION_QTY_CONTROL_CODE           ,
 ITEM_PRIMARY_UOM_CODE                    ,
 ITEM_UOM_CLASS                           ,
 ITEM_SHELF_LIFE_CODE                     ,
 ITEM_SHELF_LIFE_DAYS                     ,
 ITEM_LOT_CONTROL_CODE                    ,
 ITEM_SERIAL_CONTROL_CODE                 ,
 ITEM_INVENTORY_ASSET_FLAG                ,
 ALLOWED_UNITS_LOOKUP_CODE                ,
 DEPARTMENT_ID                            ,
 DEPARTMENT_CODE                          ,
 WIP_SUPPLY_TYPE                          ,
 SUPPLY_SUBINVENTORY                      ,
 SUPPLY_LOCATOR_ID                        ,
 VALID_SUBINVENTORY_FLAG                  ,
 VALID_LOCATOR_FLAG                      ,
 LOCATOR_SEGMENTS                         ,
 CURRENT_LOCATOR_CONTROL_CODE             ,
 NUMBER_OF_LOTS_ENTERED                        ,
 WIP_COMMIT_FLAG                          ,
 NEXT_LOT_NUMBER                         ,
 LOT_ALPHA_PREFIX                         ,
 NEXT_SERIAL_NUMBER                       ,
 SERIAL_ALPHA_PREFIX                      ,
 SHIPPABLE_FLAG                          ,
 POSTING_FLAG                             ,
 REQUIRED_FLAG                            ,
 PROCESS_FLAG                             ,
 ERROR_CODE                               ,
 ERROR_EXPLANATION                        ,
 ATTRIBUTE_CATEGORY                       ,
 ATTRIBUTE1                               ,
 ATTRIBUTE2                               ,
 ATTRIBUTE3                               ,
 ATTRIBUTE4                               ,
 ATTRIBUTE5                               ,
 ATTRIBUTE6                               ,
 ATTRIBUTE7                               ,
 ATTRIBUTE8                               ,
 ATTRIBUTE9                               ,
 ATTRIBUTE10                              ,
 ATTRIBUTE11                              ,
 ATTRIBUTE12                              ,
 ATTRIBUTE13                              ,
 ATTRIBUTE14                              ,
 ATTRIBUTE15                              ,
 MOVEMENT_ID                              ,
 RESERVATION_QUANTITY                     ,
 SHIPPED_QUANTITY                         ,
 TRANSACTION_LINE_NUMBER                  ,
 TASK_ID                                  ,
 TO_TASK_ID                               ,
 SOURCE_TASK_ID                           ,
 PROJECT_ID                               ,
 SOURCE_PROJECT_ID                        ,
 PA_EXPENDITURE_ORG_ID                    ,
 TO_PROJECT_ID                            ,
 EXPENDITURE_TYPE                         ,
 FINAL_COMPLETION_FLAG                   ,
 TRANSFER_PERCENTAGE                      ,
 TRANSACTION_SEQUENCE_ID                  ,
 MATERIAL_ACCOUNT                         ,
 MATERIAL_OVERHEAD_ACCOUNT                ,
 RESOURCE_ACCOUNT                         ,
 OUTSIDE_PROCESSING_ACCOUNT               ,
 OVERHEAD_ACCOUNT                         ,
 FLOW_SCHEDULE                            ,
 COST_GROUP_ID                            ,
 DEMAND_CLASS                             ,
 QA_COLLECTION_ID                         ,
 KANBAN_CARD_ID                           ,
 OVERCOMPLETION_TRANSACTION_QTY           ,
 OVERCOMPLETION_PRIMARY_QTY               ,
 OVERCOMPLETION_TRANSACTION_ID            ,
 END_ITEM_UNIT_NUMBER                    ,
 SCHEDULED_PAYBACK_DATE                   ,
 LINE_TYPE_CODE                           ,
 PARENT_TRANSACTION_TEMP_ID               ,
 PUT_AWAY_STRATEGY_ID                     ,
 PUT_AWAY_RULE_ID                         ,
 PICK_STRATEGY_ID                         ,
 PICK_RULE_ID                             ,
 MOVE_ORDER_LINE_ID                       ,
 TASK_GROUP_ID                            ,
 PICK_SLIP_NUMBER                        ,
 RESERVATION_ID                           ,
 COMMON_BOM_SEQ_ID                        ,
 COMMON_ROUTING_SEQ_ID                    ,
 ORG_COST_GROUP_ID                        ,
 COST_TYPE_ID                             ,
 TRANSACTION_STATUS                       ,
 STANDARD_OPERATION_ID                    ,
 TASK_PRIORITY                            ,
 WMS_TASK_TYPE                            ,
 PARENT_LINE_ID                           ,
 ' '                                      ,
 TRANSFER_COST_GROUP_ID                   ,
 LPN_ID                                   ,
 TRANSFER_LPN_ID                          ,
 WMS_TASK_STATUS                          ,
 CONTENT_LPN_ID                           ,
 CONTAINER_ITEM_ID                        ,
 CARTONIZATION_ID                         ,
 PICK_SLIP_DATE                           ,
 REBUILD_ITEM_ID                          ,
 REBUILD_SERIAL_NUMBER                    ,
 REBUILD_ACTIVITY_ID                      ,
 REBUILD_JOB_NAME                        ,
 ORGANIZATION_TYPE                        ,
 TRANSFER_ORGANIZATION_TYPE               ,
 OWNING_ORGANIZATION_ID                   ,
 OWNING_TP_TYPE                           ,
 XFR_OWNING_ORGANIZATION_ID               ,
 TRANSFER_OWNING_TP_TYPE                  ,
 PLANNING_ORGANIZATION_ID                 ,
 PLANNING_TP_TYPE                         ,
 XFR_PLANNING_ORGANIZATION_ID             ,
 TRANSFER_PLANNING_TP_TYPE                ,
 SECONDARY_UOM_CODE                       ,          -- new
 SECONDARY_TRANSACTION_QUANTITY           ,          -- new
 ALLOCATED_LPN_ID                         ,
 SCHEDULE_NUMBER                          ,
 SCHEDULED_FLAG                           ,
 CLASS_CODE                               ,
 SCHEDULE_GROUP                           ,
 BUILD_SEQUENCE                           ,
 BOM_REVISION                             ,
 ROUTING_REVISION                         ,
 BOM_REVISION_DATE                        ,
 ROUTING_REVISION_DATE                    ,
 ALTERNATE_BOM_DESIGNATOR                 ,
 ALTERNATE_ROUTING_DESIGNATOR
 from mtl_material_transactions_temp
 where transaction_header_id =  l_txn_header_id;
 --- If lot controlled item, insert records into lot_trace table

If (l_insert_lot_flag = 1) then
 insert into wms_transaction_lots_trace
 (
 TRANSACTION_TEMP_ID,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN ,
 REQUEST_ID ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID  ,
 PROGRAM_UPDATE_DATE ,
 TRANSACTION_QUANTITY,
 PRIMARY_QUANTITY,
 SECONDARY_QUANTITY,                           -- new
 GRADE_CODE,                                   -- new
 LOT_NUMBER ,
 LOT_EXPIRATION_DATE ,
 ERROR_CODE  ,
 SERIAL_TRANSACTION_TEMP_ID ,
 GROUP_HEADER_ID   ,
 PUT_AWAY_RULE_ID ,
 PICK_RULE_ID  ,
 DESCRIPTION  ,
 VENDOR_NAME  ,
 SUPPLIER_LOT_NUMBER,
 ORIGINATION_DATE  ,
 DATE_CODE    ,
 CHANGE_DATE  ,
 MATURITY_DATE  ,
 STATUS_ID   ,
 RETEST_DATE  ,
 AGE     ,
 ITEM_SIZE ,
 COLOR  ,
 VOLUME  ,
 VOLUME_UOM  ,
 PLACE_OF_ORIGIN  ,
 BEST_BY_DATE  ,
 LENGTH    ,
 LENGTH_UOM  ,
 RECYCLED_CONTENT  ,
 THICKNESS     ,
 THICKNESS_UOM    ,
 WIDTH      ,
 WIDTH_UOM   ,
 CURL_WRINKLE_FOLD ,
 LOT_ATTRIBUTE_CATEGORY,
 C_ATTRIBUTE1   ,
 C_ATTRIBUTE2 ,
 C_ATTRIBUTE3  ,
 C_ATTRIBUTE4  ,
 C_ATTRIBUTE5  ,
 C_ATTRIBUTE6  ,
 C_ATTRIBUTE7  ,
 C_ATTRIBUTE8  ,
 C_ATTRIBUTE9  ,
 C_ATTRIBUTE10  ,
 C_ATTRIBUTE11  ,
 C_ATTRIBUTE12  ,
 C_ATTRIBUTE13 ,
 C_ATTRIBUTE14  ,
 C_ATTRIBUTE15   ,
 C_ATTRIBUTE16  ,
 C_ATTRIBUTE17  ,
 C_ATTRIBUTE18   ,
 C_ATTRIBUTE19  ,
 C_ATTRIBUTE20  ,
 D_ATTRIBUTE1   ,
 D_ATTRIBUTE2   ,
 D_ATTRIBUTE3    ,
 D_ATTRIBUTE4   ,
 D_ATTRIBUTE5   ,
 D_ATTRIBUTE6  ,
 D_ATTRIBUTE7  ,
 D_ATTRIBUTE8  ,
 D_ATTRIBUTE9  ,
 D_ATTRIBUTE10  ,
 N_ATTRIBUTE1   ,
 N_ATTRIBUTE2   ,
 N_ATTRIBUTE3   ,
 N_ATTRIBUTE4   ,
 N_ATTRIBUTE5   ,
 N_ATTRIBUTE6   ,
 N_ATTRIBUTE7  ,
 N_ATTRIBUTE8  ,
 N_ATTRIBUTE9  ,
 N_ATTRIBUTE10  ,
 VENDOR_ID     ,
 TERRITORY_CODE  ,
 SUBLOT_NUM     ,
 SECONDARY_UNIT_OF_MEASURE  ,
 QC_GRADE   )
 select
  TRANSACTION_TEMP_ID,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN ,
 REQUEST_ID ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID  ,
 PROGRAM_UPDATE_DATE ,
 TRANSACTION_QUANTITY,
 PRIMARY_QUANTITY,
 SECONDARY_QUANTITY,                           -- new
 GRADE_CODE,                                   -- new
 LOT_NUMBER ,
 LOT_EXPIRATION_DATE ,
 ERROR_CODE  ,
 SERIAL_TRANSACTION_TEMP_ID ,
 GROUP_HEADER_ID   ,
 PUT_AWAY_RULE_ID ,
 PICK_RULE_ID  ,
 DESCRIPTION  ,
 VENDOR_NAME  ,
 SUPPLIER_LOT_NUMBER,
 ORIGINATION_DATE  ,
 DATE_CODE    ,
 CHANGE_DATE  ,
 MATURITY_DATE  ,
 STATUS_ID   ,
 RETEST_DATE  ,
 AGE     ,
 ITEM_SIZE ,
 COLOR  ,
 VOLUME  ,
 VOLUME_UOM  ,
 PLACE_OF_ORIGIN  ,
 BEST_BY_DATE  ,
 LENGTH    ,
 LENGTH_UOM  ,
 RECYCLED_CONTENT  ,
 THICKNESS     ,
 THICKNESS_UOM    ,
 WIDTH      ,
 WIDTH_UOM   ,
 CURL_WRINKLE_FOLD ,
 LOT_ATTRIBUTE_CATEGORY,
 C_ATTRIBUTE1   ,
 C_ATTRIBUTE2 ,
 C_ATTRIBUTE3  ,
 C_ATTRIBUTE4  ,
 C_ATTRIBUTE5  ,
 C_ATTRIBUTE6  ,
 C_ATTRIBUTE7  ,
 C_ATTRIBUTE8  ,
 C_ATTRIBUTE9  ,
 C_ATTRIBUTE10  ,
 C_ATTRIBUTE11  ,
 C_ATTRIBUTE12  ,
 C_ATTRIBUTE13 ,
 C_ATTRIBUTE14  ,
 C_ATTRIBUTE15   ,
 C_ATTRIBUTE16  ,
 C_ATTRIBUTE17  ,
 C_ATTRIBUTE18   ,
 C_ATTRIBUTE19  ,
 C_ATTRIBUTE20  ,
 D_ATTRIBUTE1   ,
 D_ATTRIBUTE2   ,
 D_ATTRIBUTE3    ,
 D_ATTRIBUTE4   ,
 D_ATTRIBUTE5   ,
 D_ATTRIBUTE6  ,
 D_ATTRIBUTE7  ,
 D_ATTRIBUTE8  ,
 D_ATTRIBUTE9  ,
 D_ATTRIBUTE10  ,
 N_ATTRIBUTE1   ,
 N_ATTRIBUTE2   ,
 N_ATTRIBUTE3   ,
 N_ATTRIBUTE4   ,
 N_ATTRIBUTE5   ,
 N_ATTRIBUTE6   ,
 N_ATTRIBUTE7  ,
 N_ATTRIBUTE8  ,
 N_ATTRIBUTE9  ,
 N_ATTRIBUTE10  ,
 VENDOR_ID     ,
 TERRITORY_CODE  ,
 SUBLOT_NUM     ,
 SECONDARY_UNIT_OF_MEASURE  ,
 QC_GRADE
 from mtl_transaction_lots_temp
 where transaction_temp_id in ( select transaction_temp_id
                                  from wms_material_txn_trace
                                 where transaction_header_id = l_txn_header_id);


 End if;

  --- If only serial controlled item , insert records into serial_trace table

 If (l_insert_serial_flag = 1 and l_insert_lot_flag = 0) then
 insert into  wms_serial_numbers_trace
  (
 TRANSACTION_TEMP_ID        ,
 LAST_UPDATE_DATE           ,
 LAST_UPDATED_BY            ,
 CREATION_DATE              ,
 CREATED_BY                 ,
 LAST_UPDATE_LOGIN          ,
 REQUEST_ID                 ,
 PROGRAM_APPLICATION_ID     ,
 PROGRAM_ID                 ,
 PROGRAM_UPDATE_DATE       ,
 VENDOR_SERIAL_NUMBER      ,
 VENDOR_LOT_NUMBER         ,
 FM_SERIAL_NUMBER          ,
 TO_SERIAL_NUMBER          ,
 SERIAL_PREFIX             ,
 ERROR_CODE                ,
 GROUP_HEADER_ID           ,
 PARENT_SERIAL_NUMBER      ,
 END_ITEM_UNIT_NUMBER      ,
 SERIAL_ATTRIBUTE_CATEGORY  ,
 ORIGINATION_DATE           ,
 C_ATTRIBUTE1               ,
 C_ATTRIBUTE2               ,
 C_ATTRIBUTE3               ,
 C_ATTRIBUTE4                ,
 C_ATTRIBUTE5               ,
 C_ATTRIBUTE6               ,
 C_ATTRIBUTE7               ,
 C_ATTRIBUTE8               ,
 C_ATTRIBUTE9               ,
 C_ATTRIBUTE10              ,
 C_ATTRIBUTE11              ,
 C_ATTRIBUTE12              ,
 C_ATTRIBUTE13              ,
 C_ATTRIBUTE14              ,
 C_ATTRIBUTE15             ,
 C_ATTRIBUTE16             ,
 C_ATTRIBUTE17             ,
 C_ATTRIBUTE18             ,
 C_ATTRIBUTE19              ,
 C_ATTRIBUTE20     ,
 D_ATTRIBUTE1      ,
 D_ATTRIBUTE2      ,
 D_ATTRIBUTE3      ,
 D_ATTRIBUTE4      ,
 D_ATTRIBUTE5      ,
 D_ATTRIBUTE6      ,
 D_ATTRIBUTE7      ,
 D_ATTRIBUTE8      ,
 D_ATTRIBUTE9      ,
 D_ATTRIBUTE10     ,
 N_ATTRIBUTE1      ,
 N_ATTRIBUTE2      ,
 N_ATTRIBUTE3      ,
 N_ATTRIBUTE4      ,
 N_ATTRIBUTE5      ,
 N_ATTRIBUTE6      ,
 N_ATTRIBUTE7      ,
 N_ATTRIBUTE8      ,
 N_ATTRIBUTE9      ,
 N_ATTRIBUTE10     ,
 STATUS_ID         ,
 TERRITORY_CODE    ,
 TIME_SINCE_NEW    ,
 CYCLES_SINCE_NEW  ,
 TIME_SINCE_OVERHAUL,
 CYCLES_SINCE_OVERHAUL,
 TIME_SINCE_REPAIR    ,
 CYCLES_SINCE_REPAIR  ,
 TIME_SINCE_VISIT     ,
 CYCLES_SINCE_VISIT   ,
 TIME_SINCE_MARK      ,
 CYCLES_SINCE_MARK    ,
 NUMBER_OF_REPAIRS
)
select
TRANSACTION_TEMP_ID        ,
 LAST_UPDATE_DATE           ,
 LAST_UPDATED_BY            ,
 CREATION_DATE              ,
 CREATED_BY                 ,
 LAST_UPDATE_LOGIN          ,
 REQUEST_ID                 ,
 PROGRAM_APPLICATION_ID     ,
 PROGRAM_ID                 ,
 PROGRAM_UPDATE_DATE       ,
 VENDOR_SERIAL_NUMBER      ,
 VENDOR_LOT_NUMBER         ,
 FM_SERIAL_NUMBER          ,
 TO_SERIAL_NUMBER          ,
 SERIAL_PREFIX             ,
 ERROR_CODE                ,
 GROUP_HEADER_ID           ,
 PARENT_SERIAL_NUMBER      ,
 END_ITEM_UNIT_NUMBER      ,
 SERIAL_ATTRIBUTE_CATEGORY  ,
 ORIGINATION_DATE           ,
 C_ATTRIBUTE1               ,
 C_ATTRIBUTE2               ,
 C_ATTRIBUTE3               ,
 C_ATTRIBUTE4                ,
 C_ATTRIBUTE5               ,
 C_ATTRIBUTE6               ,
 C_ATTRIBUTE7               ,
 C_ATTRIBUTE8               ,
 C_ATTRIBUTE9               ,
 C_ATTRIBUTE10              ,
 C_ATTRIBUTE11              ,
 C_ATTRIBUTE12              ,
 C_ATTRIBUTE13              ,
 C_ATTRIBUTE14              ,
 C_ATTRIBUTE15             ,
 C_ATTRIBUTE16             ,
 C_ATTRIBUTE17             ,
 C_ATTRIBUTE18             ,
 C_ATTRIBUTE19              ,
 C_ATTRIBUTE20     ,
 D_ATTRIBUTE1      ,
 D_ATTRIBUTE2      ,
 D_ATTRIBUTE3      ,
 D_ATTRIBUTE4      ,
 D_ATTRIBUTE5      ,
 D_ATTRIBUTE6      ,
 D_ATTRIBUTE7      ,
 D_ATTRIBUTE8      ,
 D_ATTRIBUTE9      ,
 D_ATTRIBUTE10     ,
 N_ATTRIBUTE1      ,
 N_ATTRIBUTE2      ,
 N_ATTRIBUTE3      ,
 N_ATTRIBUTE4      ,
 N_ATTRIBUTE5      ,
 N_ATTRIBUTE6      ,
 N_ATTRIBUTE7      ,
 N_ATTRIBUTE8      ,
 N_ATTRIBUTE9      ,
 N_ATTRIBUTE10     ,
 STATUS_ID         ,
 TERRITORY_CODE    ,
 TIME_SINCE_NEW    ,
 CYCLES_SINCE_NEW  ,
 TIME_SINCE_OVERHAUL,
 CYCLES_SINCE_OVERHAUL,
 TIME_SINCE_REPAIR    ,
 CYCLES_SINCE_REPAIR  ,
 TIME_SINCE_VISIT     ,
 CYCLES_SINCE_VISIT   ,
 TIME_SINCE_MARK      ,
 CYCLES_SINCE_MARK    ,
 NUMBER_OF_REPAIRS
 from mtl_serial_numbers_temp
 where transaction_temp_id in ( select transaction_temp_id
                                 from wms_material_txn_trace
                                where transaction_header_id =  l_txn_header_id);


 End if;

  --- If lot and serial controlled item , insert records into serial_trace table

 If (l_insert_serial_flag = 1 and l_insert_lot_flag = 1) then
  insert into wms_serial_numbers_trace
 (
 TRANSACTION_TEMP_ID        ,
 LAST_UPDATE_DATE           ,
 LAST_UPDATED_BY            ,
 CREATION_DATE              ,
 CREATED_BY                 ,
 LAST_UPDATE_LOGIN          ,
 REQUEST_ID                 ,
 PROGRAM_APPLICATION_ID     ,
 PROGRAM_ID                 ,
 PROGRAM_UPDATE_DATE       ,
 VENDOR_SERIAL_NUMBER      ,
 VENDOR_LOT_NUMBER         ,
 FM_SERIAL_NUMBER          ,
 TO_SERIAL_NUMBER          ,
 SERIAL_PREFIX             ,
 ERROR_CODE                ,
 GROUP_HEADER_ID           ,
 PARENT_SERIAL_NUMBER      ,
 END_ITEM_UNIT_NUMBER      ,
 SERIAL_ATTRIBUTE_CATEGORY  ,
 ORIGINATION_DATE           ,
 C_ATTRIBUTE1               ,
 C_ATTRIBUTE2               ,
 C_ATTRIBUTE3               ,
 C_ATTRIBUTE4                ,
 C_ATTRIBUTE5               ,
 C_ATTRIBUTE6               ,
 C_ATTRIBUTE7               ,
 C_ATTRIBUTE8               ,
 C_ATTRIBUTE9               ,
 C_ATTRIBUTE10              ,
 C_ATTRIBUTE11              ,
 C_ATTRIBUTE12              ,
 C_ATTRIBUTE13              ,
 C_ATTRIBUTE14              ,
 C_ATTRIBUTE15             ,
 C_ATTRIBUTE16             ,
 C_ATTRIBUTE17             ,
 C_ATTRIBUTE18             ,
 C_ATTRIBUTE19              ,
 C_ATTRIBUTE20     ,
 D_ATTRIBUTE1      ,
 D_ATTRIBUTE2      ,
 D_ATTRIBUTE3      ,
 D_ATTRIBUTE4      ,
 D_ATTRIBUTE5      ,
 D_ATTRIBUTE6      ,
 D_ATTRIBUTE7      ,
 D_ATTRIBUTE8      ,
 D_ATTRIBUTE9      ,
 D_ATTRIBUTE10     ,
 N_ATTRIBUTE1      ,
 N_ATTRIBUTE2      ,
 N_ATTRIBUTE3      ,
 N_ATTRIBUTE4      ,
 N_ATTRIBUTE5      ,
 N_ATTRIBUTE6      ,
 N_ATTRIBUTE7      ,
 N_ATTRIBUTE8      ,
 N_ATTRIBUTE9      ,
 N_ATTRIBUTE10     ,
 STATUS_ID         ,
 TERRITORY_CODE    ,
 TIME_SINCE_NEW    ,
 CYCLES_SINCE_NEW  ,
 TIME_SINCE_OVERHAUL,
 CYCLES_SINCE_OVERHAUL,
 TIME_SINCE_REPAIR    ,
 CYCLES_SINCE_REPAIR  ,
 TIME_SINCE_VISIT     ,
 CYCLES_SINCE_VISIT   ,
 TIME_SINCE_MARK      ,
 CYCLES_SINCE_MARK    ,
 NUMBER_OF_REPAIRS
)
select
TRANSACTION_TEMP_ID        ,
 LAST_UPDATE_DATE           ,
 LAST_UPDATED_BY            ,
 CREATION_DATE              ,
 CREATED_BY                 ,
 LAST_UPDATE_LOGIN          ,
 REQUEST_ID                 ,
 PROGRAM_APPLICATION_ID     ,
 PROGRAM_ID                 ,
 PROGRAM_UPDATE_DATE       ,
 VENDOR_SERIAL_NUMBER      ,
 VENDOR_LOT_NUMBER         ,
 FM_SERIAL_NUMBER          ,
 TO_SERIAL_NUMBER          ,
 SERIAL_PREFIX             ,
 ERROR_CODE                ,
 GROUP_HEADER_ID           ,
 PARENT_SERIAL_NUMBER      ,
 END_ITEM_UNIT_NUMBER      ,
 SERIAL_ATTRIBUTE_CATEGORY  ,
 ORIGINATION_DATE           ,
 C_ATTRIBUTE1               ,
 C_ATTRIBUTE2               ,
 C_ATTRIBUTE3               ,
 C_ATTRIBUTE4                ,
 C_ATTRIBUTE5               ,
 C_ATTRIBUTE6               ,
 C_ATTRIBUTE7               ,
 C_ATTRIBUTE8               ,
 C_ATTRIBUTE9               ,
 C_ATTRIBUTE10              ,
 C_ATTRIBUTE11              ,
 C_ATTRIBUTE12              ,
 C_ATTRIBUTE13              ,
 C_ATTRIBUTE14              ,
 C_ATTRIBUTE15             ,
 C_ATTRIBUTE16             ,
 C_ATTRIBUTE17             ,
 C_ATTRIBUTE18             ,
 C_ATTRIBUTE19              ,
 C_ATTRIBUTE20     ,
 D_ATTRIBUTE1      ,
 D_ATTRIBUTE2      ,
 D_ATTRIBUTE3      ,
 D_ATTRIBUTE4      ,
 D_ATTRIBUTE5      ,
 D_ATTRIBUTE6      ,
 D_ATTRIBUTE7      ,
 D_ATTRIBUTE8      ,
 D_ATTRIBUTE9      ,
 D_ATTRIBUTE10     ,
 N_ATTRIBUTE1      ,
 N_ATTRIBUTE2      ,
 N_ATTRIBUTE3      ,
 N_ATTRIBUTE4      ,
 N_ATTRIBUTE5      ,
 N_ATTRIBUTE6      ,
 N_ATTRIBUTE7      ,
 N_ATTRIBUTE8      ,
 N_ATTRIBUTE9      ,
 N_ATTRIBUTE10     ,
 STATUS_ID         ,
 TERRITORY_CODE    ,
 TIME_SINCE_NEW    ,
 CYCLES_SINCE_NEW  ,
 TIME_SINCE_OVERHAUL,
 CYCLES_SINCE_OVERHAUL,
 TIME_SINCE_REPAIR    ,
 CYCLES_SINCE_REPAIR  ,
 TIME_SINCE_VISIT     ,
 CYCLES_SINCE_VISIT   ,
 TIME_SINCE_MARK      ,
 CYCLES_SINCE_MARK    ,
 NUMBER_OF_REPAIRS
 from mtl_serial_numbers_temp
  where transaction_temp_id in ( select wtlt.serial_transaction_temp_id
                                     from  wms_material_txn_trace wmtt,
                                           wms_transaction_lots_trace wtlt
                                     where wmtt.transaction_header_id = l_txn_header_id
                                       and wmtt.transaction_temp_id = wtlt.transaction_temp_id);
  End if;

    End if;

 EXCEPTION
   when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    end if;
 End insert_txn_trace_rows;
---------------------------------------------------------------------------------------
---- This procedure is used by 'Run time trace form' to set the
---- global variables based on WMS_RULE_TRACE_HEADERS record for a given move order
---- so that the actual traceed path could be shown in the form.

procedure set_global_variables(
    p_move_order_line_id        in  NUMBER
   ,p_trace_date                in  DATE
   ,x_return_status             out NOCOPY VARCHAR2) is

   cursor trace_globals(p_move_order_id number, p_trace_date date ) is
    select header_id,
           strategy_id,
           object_id,
           type_code,
           pick_header_id,
           creation_date
     from wms_rule_trace_headers
     where move_order_line_id = p_move_order_line_id
       and  to_char(creation_date, 'HH:MI:SS') =  to_char(p_trace_date, 'HH:MI:SS')
      and simulation_mode = 'N'
       order by type_code ;

    --l_pick_header_id number := 0;
begin
    --- Pick Search order Global Variables

 for c_trace in trace_globals(p_move_order_line_id, p_trace_date) loop

   if ( c_trace.type_code = 2 ) then
      if (c_trace.header_id = G_PICK_HEADER_ID) then

          G_PICK_SEQ_NUM              := c_trace.object_id; ---- currently used for sequence number
          G_PICK_STRATEGY_ID          := c_trace.strategy_id;


      end if;
   elsif ( c_trace.type_code = 1 and c_trace.creation_date = p_trace_date ) then


      G_PUTAWAY_SEQ_NUM              := c_trace.object_id; ---- currently used for sequence number
      G_PUTAWAY_STRATEGY_ID          := c_trace.strategy_id;
      G_PICK_HEADER_ID               := c_trace.pick_header_id;
      G_PUTAWAY_HEADER_ID            := c_trace.header_id;
  end if;

 end loop;
  x_return_status := 'Y' ;
 exception
 when others then
   x_return_status := 'N' ;

end set_global_variables;
-------------------------------------------------
--- get Pick or Putaway header id from global variables

FUNCTION get_trace_line_header_id( engine_type IN VARCHAR2 )
     RETURN NUMBER is
   l_header_id number := 0;
 begin
     if (engine_type = 'PICK')  then
         l_header_id := G_PICK_HEADER_ID;
    elsif (engine_type = 'PUTAWAY')  then
         l_header_id := G_PUTAWAY_HEADER_ID;
     end if;
    RETURN  l_header_id;
 END get_trace_line_header_id;
 ------------------------------------------------

 FUNCTION get_strategy_id( p_rule_type IN NUMBER )
   RETURN  NUMBER is
   l_strategy_id number;
   Begin
      IF p_rule_type = 2 THEN
         l_strategy_id := G_PICK_STRATEGY_ID;
      ELSIF p_rule_type = 1 THEN
         l_strategy_id := G_PUTAWAY_STRATEGY_ID;
      ELSIF p_rule_type = 5 THEN
         l_strategy_id := G_COSTGROUP_STRATEGY_ID;
      END IF;
      RETURN l_strategy_id;
 END get_strategy_id;



 FUNCTION get_rule_id( p_rule_type IN NUMBER )
   RETURN  NUMBER is
   l_rule_id number;
   Begin
      IF p_rule_type = 2 THEN
         l_rule_id := G_PICK_RULE_ID;
      ELSIF p_rule_type = 1 THEN
         l_rule_id := G_PUTAWAY_RULE_ID;
      ELSIF p_rule_type = 5 THEN
         l_rule_id := G_COSTGROUP_RULE_ID;
      END IF;
      RETURN l_rule_id;
 END get_rule_id;

  -----------------------
 FUNCTION get_seq_num( p_rule_type IN NUMBER )
   RETURN  NUMBER is
   l_seq_num  number := 0;
    Begin
       IF p_rule_type = 2 THEN
          l_seq_num  := G_PICK_SEQ_NUM;
       ELSIF p_rule_type = 1 THEN
          l_seq_num  := G_PUTAWAY_SEQ_NUM;
       ELSIF p_rule_type = 5 THEN
         l_seq_num   := G_COSTGROUP_SEQ_NUM ;
       END IF;
       RETURN l_seq_num;
 END get_seq_num;
 ---
END; -- Package Body WMS_SEARCH_ORDER_GLOBALS_PVT

/
