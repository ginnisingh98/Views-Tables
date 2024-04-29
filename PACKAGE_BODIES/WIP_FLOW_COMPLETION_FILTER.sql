--------------------------------------------------------
--  DDL for Package Body WIP_FLOW_COMPLETION_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOW_COMPLETION_FILTER" AS
/* $Header: wipfwocb.pls 120.0 2005/05/25 07:46:47 appldev noship $  */

PROCEDURE retrieve_schedules (i_where IN VARCHAR2, i_default_sub IN VARCHAR2,
                              i_default_loc IN NUMBER,
                              i_org_locator_control IN NUMBER,
                              i_qty_retrieve IN NUMBER,
                              i_num_records IN NUMBER,
                              o_result OUT NOCOPY ret_sch_t,
                              o_restrict_error OUT NOCOPY BOOLEAN,
                              o_lot_serial_error OUT NOCOPY BOOLEAN,
                              o_error_num OUT NOCOPY NUMBER,
                              o_error_msg OUT NOCOPY VARCHAR2) IS
  l_cursor_id NUMBER;
  l_stmt VARCHAR2(10000);
  l_dummy INTEGER;
  l_wip_entity_id NUMBER;
  l_primary_item_id NUMBER;
  l_completion_subinventory VARCHAR2(10);
  l_completion_locator NUMBER;
  l_alt_routing_designator VARCHAR2(10);
  l_org_id NUMBER;
  l_project_id NUMBER;
  l_task_id NUMBER;
  l_ret NUMBER;
  i NUMBER;
  l_item_locator_control NUMBER;
  l_restrict_sub NUMBER;
  l_restrict_loc NUMBER;
  l_serial_control NUMBER;
  l_lot_control NUMBER;
  l_sub_locator_control NUMBER;
  l_locator_control NUMBER;
  l_cnt NUMBER;
  l_cur_restrict_error BOOLEAN;
  l_cur_lot_serial_error BOOLEAN;
  l_tot_qty NUMBER;
  l_cur_qty NUMBER;

BEGIN

      l_stmt := 'SELECT primary_item_id,
                        wip_entity_id,
			organization_id,
			completion_subinventory,
			completion_locator_id,
			alternate_routing_designator,
			project_id,
			task_id,
			planned_quantity-NVL(quantity_completed,0)-NVL(quantity_scrapped,0)
                 FROM wip_flow_schedules wfs
		 WHERE (planned_quantity - NVL(quantity_completed,0) -
                        NVL(quantity_scrapped,0)) > 0
                   AND status = 1
          and ( wfs.demand_source_header_id is null or
                exists ( select 1 from wip_open_demands_v wodv
                         where to_char(wodv.demand_source_line_id) = wfs.demand_source_line
                         and wodv.demand_source_header_id = wfs.demand_source_header_id)
              ) ';
              /* bug 3899971, not fetching the schedules linked to orders lines not booked */
      l_stmt := l_stmt || ' AND ' || i_where ;
      l_stmt := l_stmt || ' order by build_sequence, schedule_number ';


      l_cursor_id := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor_id, l_stmt, dbms_sql.v7);
      dbms_sql.define_column(l_cursor_id, 1, l_primary_item_id);
      dbms_sql.define_column(l_cursor_id, 2, l_wip_entity_id);
      dbms_sql.define_column(l_cursor_id, 3, l_org_id);
      dbms_sql.define_column(l_cursor_id, 4, l_completion_subinventory, 10);
      dbms_sql.define_column(l_cursor_id, 5, l_completion_locator);
      dbms_sql.define_column(l_cursor_id, 6, l_alt_routing_designator, 10);
      dbms_sql.define_column(l_cursor_id, 7, l_project_id);
      dbms_sql.define_column(l_cursor_id, 8, l_task_id);
      dbms_sql.define_column(l_cursor_id, 9, l_cur_qty);
      l_dummy :=  dbms_sql.execute(l_cursor_id);

      -- This will be set to true if the item has resricted subinventory/locator,
      -- and the subinventory/locator given from the default or routing
      -- doesn't match. That record will not be returned in the result table.
      o_restrict_error := false;

      -- This will be set to true if the item has lot/serial controlled,
      -- That record will not be returned in the result table.
      o_lot_serial_error := false;

      -- Index of result table
      i := 1;

      -- Total quantity eligible to be completed.
      l_tot_qty := 0;

      WHILE dbms_sql.fetch_rows(l_cursor_id) > 0 LOOP
         -- This is to indicate resricted subinventory/locator error for
         -- the current record.
         l_cur_restrict_error := false;

         -- This is to indicate lot/serial control error for the current record.
         l_cur_lot_serial_error := false;

         dbms_sql.column_value(l_cursor_id,1, l_primary_item_id);
         dbms_sql.column_value(l_cursor_id,2, l_wip_entity_id);
         dbms_sql.column_value(l_cursor_id,3, l_org_id);
         dbms_sql.column_value(l_cursor_id,4, l_completion_subinventory);
         dbms_sql.column_value(l_cursor_id,5, l_completion_locator);
         dbms_sql.column_value(l_cursor_id,6, l_alt_routing_designator);
         dbms_sql.column_value(l_cursor_id,7, l_project_id);
         dbms_sql.column_value(l_cursor_id,8, l_task_id);
         dbms_sql.column_value(l_cursor_id,9, l_cur_qty);


         -- Derive the sub/loc from the routing if none is specified in
         -- the flow schedule.
	 if (l_completion_subinventory is NULL) then
	   l_ret := wip_flow_derive.routing_completion_sub_loc(
					l_completion_subinventory,
					l_completion_locator,
					l_primary_item_id,
					l_org_id,
					l_alt_routing_designator);

	   l_ret := wip_flow_derive.completion_loc(
					l_completion_locator,
					l_primary_item_id,
					l_org_id,
					l_alt_routing_designator,
					l_project_id,
					l_task_id,
					l_completion_subinventory,
					NULL);
         end if;

         -- Error out if no subinventory in the routing, and no default is given.
         -- Otherwise set it to default sub
         if (l_completion_subinventory IS NULL) then
           if (i_default_sub IS NOT NULL) then
             l_completion_subinventory := i_default_sub;
           else
             o_error_num := -1;
             return;
           end if;
         end if;

         select location_control_code,
                restrict_locators_code, restrict_subinventories_code,
	        serial_number_control_code, lot_control_code
         into l_item_locator_control,
              l_restrict_loc, l_restrict_sub,
              l_serial_control, l_lot_control
	 from mtl_system_items
	 where inventory_item_id = l_primary_item_id
	   and organization_id = l_org_id;

	 -- Check if the item is under lot/serial control
         -- If it is, set the lot_serial_error flag.
         -- We will ignore this record not to be included in the
         -- result, but will continue to process the rest
         if (l_serial_control not in (1,6) or l_lot_control <> 1) then
           o_lot_serial_error := true;
           l_cur_lot_serial_error := true;
         end if;

         -- Make sure that the sub is valid if the item uses restricted
         -- subinventory. If it's invalid, set the restricted error flag.
         -- In this case, we keep continue processing for other records,
         -- while the current record with restriction error will not
         -- be returned.
	 if (l_restrict_sub = 1) then
           select count(*)
           into l_cnt
           from mtl_item_sub_ast_trk_val_v
           where organization_id = l_org_id
             and inventory_item_id = l_primary_item_id
	     and secondary_inventory_name = l_completion_subinventory;
           if (l_cnt = 0) then
             o_restrict_error := true;
             l_cur_restrict_error := true;
           end if;
         end if;

         select locator_type
  	 into l_sub_locator_control
	 from mtl_secondary_inventories
	 where organization_id = l_org_id
	   and secondary_inventory_name = l_completion_subinventory;

         l_locator_control := loc_control(i_org_locator_control,
					  l_sub_locator_control,
					  l_item_locator_control,
					  l_restrict_loc);

         -- If it's locator controled,  error out if no locator specified and
         -- no default is given
         -- Otherwise set it to default locator
         if (l_locator_control <> 1 AND l_completion_locator is NULL) then
	   if (i_default_loc is NULL) then
             o_error_num := -1;
             return;
           else
	     l_completion_locator := i_default_loc;
           end if;
         end if;

         -- As in subinventory, we also want to make sure that if the item
         -- has restricted locator, the locator is a valid one.
         -- If it's not, set the restricted error flag.
         if (l_locator_control = 2 AND l_restrict_loc = 1) then
           select count(*)
           into l_cnt
           from mtl_secondary_locators
           where inventory_item_id = l_primary_item_id
             and organization_id = l_org_id
             and subinventory_code = l_completion_subinventory
             and secondary_locator = l_completion_locator;
           if (l_cnt = 0) then
             o_restrict_error := true;
             l_cur_restrict_error := true;
 	   end if;
         end if;

         -- If the restricted error flag and lot/serial error for the current record
         -- is not set, put this record in the result table.
         if (l_cur_restrict_error = false and l_cur_lot_serial_error = false) then
           o_result(i).wip_entity_id := l_wip_entity_id;
           o_result(i).completion_subinventory := l_completion_subinventory;
           o_result(i).completion_locator_id := l_completion_locator;

           -- Only retrieve up to i_qty_retrieve if i_qty_retrieve is not null
           if (i_qty_retrieve IS NOT NULL and i_qty_retrieve <= (l_tot_qty+l_cur_qty)) then
             o_result(i).quantity := i_qty_retrieve - l_tot_qty;
             exit;
           else
             o_result(i).quantity := l_cur_qty;
           end if;

           l_tot_qty := l_tot_qty + l_cur_qty;
           i := i + 1;

           if (i_num_records IS NOT NULL and i > i_num_records) then
             exit;
           end if;

         end if;


      END LOOP;
      o_error_num := 0;

END retrieve_schedules;

-- This function return the locator control.
function loc_control(org_control      IN    number,
                    sub_control      IN    number,
                    item_control     IN    number default NULL,
                    restrict_flag    IN    Number default NULL)
                    return number  is
  locator_control number;
  begin

    if (org_control = 1) then
       locator_control := 1;
    elsif (org_control = 2) then
       locator_control := 2;
    elsif (org_control = 3) then
       locator_control := 3;
       if (restrict_flag = 1) then
         locator_control := 2;
       end if;
    elsif (org_control = 4) then
      if (sub_control = 1) then
         locator_control := 1;
      elsif (sub_control = 2) then
         locator_control := 2;
      elsif (sub_control = 3) then
         locator_control := 3;
         if (restrict_flag = 1) then
           locator_control := 2;
         end if;
      elsif (sub_control = 5) then
        if (item_control = 1) then
           locator_control := 1;
        elsif (item_control = 2) then
           locator_control := 2;
        elsif (item_control = 3) then
           locator_control := 3;
           if (restrict_flag = 1) then
             locator_control := 2;
           end if;
        elsif (item_control IS NULL) then
           locator_control := sub_control;
        else
	   return -1;
        end if;
      else
        return -1;
      end if;
    else
      return -1;
    end if;
    return locator_control;
end loc_control;

END wip_flow_completion_filter;

/
