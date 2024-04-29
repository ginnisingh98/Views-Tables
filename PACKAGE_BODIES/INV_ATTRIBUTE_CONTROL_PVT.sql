--------------------------------------------------------
--  DDL for Package Body INV_ATTRIBUTE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ATTRIBUTE_CONTROL_PVT" as
/* $Header: INVATTCB.pls 120.4.12010000.6 2010/04/20 05:44:09 qyou ship $ */

function get_attribute_control(x_source_item varchar2) return number is
l_control_level number := 0;
attr_name varchar2(200);
begin
  attr_name := 'MTL_SYSTEM_ITEMS.'||x_source_item;
   begin
      select control_level
        into l_control_level
        from mtl_item_attributes
       where attribute_name = attr_name;
   exception
      when no_data_found then
         null;
   end;
  return l_control_level;
end get_attribute_control;


function check_pending_adjustments(p_org_id in number,
                           p_item_id in number,
                           p_source_item varchar2) return boolean IS
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  -- check at org level
     select count(1)
       into l_org_count
       from mtl_cycle_count_entries
      where inventory_item_id = p_item_id and
            organization_id = p_org_id and
            /*Change for bug 8208397*/ /*Check should be for status 1-Uncounted/2-Pending Approval/3-Recount*/
            /*entry_status_code = 2 and*/
            entry_status_code IN (1,2,3) and
      rownum = 1;

/* Fix for bug 4505262 - Added check on adjustment_quantity in the below query. */
      if (l_org_count <> 1) then
          select count(1)
            into l_org_count
            from mtl_physical_adjustments
           where inventory_item_id = p_item_id
             and organization_id = p_org_id
             and approval_status = 1
	     and adjustment_quantity <> 0
             and rownum = 1;
      end if;
--check at master level
    if (l_org_count <> 1 and get_attribute_control(p_source_item) = 1) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

       select count(1)
         into l_master_count
         from mtl_cycle_count_entries
        where inventory_item_id = p_item_id and
              (organization_id in
                (select organization_id
                   from mtl_parameters
                  where master_organization_id = l_master_org
                )
              )
         /*Change for bug 8208397*/ /*Check should be for status 1-Uncounted/2-Pending Approval/3-Recount*/
         /*and entry_status_code = 2*/
         and entry_status_code IN (1,2,3)
         and rownum = 1;

/* Fix for bug 4505262 - Added check on adjustment_quantity in the below query. */
       if (l_master_count <> 1) then
          select count(1)
            into l_master_count
            from mtl_physical_adjustments
           where inventory_item_id = p_item_id
             and (organization_id in
                    (select organization_id
                       from mtl_parameters
                      where master_organization_id = l_master_org
                    )
                 )
             and approval_status = 1
	     and adjustment_quantity <> 0
             and rownum = 1;
       end if;
    end if;
  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;
end check_pending_adjustments;



-- when try to change from yes to no
function reservable_uncheck (p_org_id in number,
                             p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
            select count(1) into l_org_count
             from  wsh_delivery_details
              where  inventory_item_id = p_item_id
              and    released_status = 'S'
              and    source_code = 'OE'
              and    organization_id = p_org_id
              and    rownum = 1;

         if (l_org_count <> 1 and
            get_attribute_control('RESERVABLE_TYPE') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

        select count(1) into l_master_count
          from wsh_delivery_details
         where inventory_item_id = p_item_id
           and released_status = 'S'
           and source_code = 'OE'
           and organization_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
       end if;
   if (l_org_count = 1 or l_master_count = 1) then
       return TRUE;
   else
       return FALSE;
   end if;
end reservable_uncheck;


-- when changes from no to yes
function reservable_check (p_org_id in number,
                           p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
              select count(1) into l_org_count
               from  wsh_delivery_details
              where  inventory_item_id = p_item_id
              and    released_status = 'Y'
              and    source_code = 'OE'
              and    organization_id = p_org_id
              and    rownum = 1;

         if (l_org_count <> 1 and
            get_attribute_control('RESERVABLE_TYPE') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

        select count(1) into l_master_count
          from wsh_delivery_details
         where inventory_item_id = p_item_id
           and released_status = 'Y'
           and source_code = 'OE'
           and organization_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
       end if;
   if (l_org_count = 1 or l_master_count = 1) then
       return TRUE;
   else
       return FALSE;
   end if;
end reservable_check;




-- when changes from no to Yes
function transactable_check(p_org_id in number,
                            p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  select count(1) into l_org_count
     from oe_order_lines_all l,
          wsh_delivery_details wdd
    where l.inventory_item_id = p_item_id
       and l.open_flag  = 'Y'	-- Bug 8247770
      and wdd.released_status not in ('C','D')
      and wdd.pickable_flag = 'N'
      --and wdd.source_code = 'OE'
      and l.line_id = wdd.source_line_id
      and l.ship_from_org_id = p_org_id
      and rownum = 1;

   if (l_org_count <> 1 and
       get_attribute_control('MTL_TRANSACTIONS_ENABLED_FLAG') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

        select count(1) into l_master_count
          from oe_order_lines_all l,
               wsh_delivery_details wdd
         where l.inventory_item_id = p_item_id
           and l.open_flag  = 'Y'	-- Bug 8247770
           and wdd.released_status not in ('C','D')
           and wdd.pickable_flag = 'N'
           --and wdd.source_code = 'OE'
           and l.line_id = wdd.source_line_id
           and l.ship_from_org_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
   end if;
  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;
end transactable_check;




-- When changes from Yes to No
function transactable_uncheck(p_org_id in number,
                              p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  select count(1) into l_org_count
     from wsh_delivery_details
    where inventory_item_id = p_item_id
      and pickable_flag = 'Y'
      --Bug 4643978 - Perf fix
      and inv_interfaced_flag IN ('N','P')
      --and source_code = 'OE'
      and released_status <> 'D'
      and organization_id = p_org_id
      and rownum = 1;

   if (l_org_count <> 1) then
	select count(1) into l_org_count
	from oe_order_lines_all
	where source_type_code = 'EXTERNAL'
	  and open_flag = 'Y'
	  and nvl(shipped_quantity,0) = 0
	  and item_type_code in ('MODEL','STANDARD','OPTION')
	  and FLOW_STATUS_CODE = 'AWAITING_RECEIPT'
	  and inventory_item_id = p_item_id
	  and ship_from_org_id = p_org_id
	  and rownum = 1;
   end if;

  if (l_org_count <> 1) then
	select count(1) into l_org_count
	from oe_order_lines_all l
	where booked_flag = 'Y'
	  and nvl(shipped_quantity,0) = 0
	  and inventory_item_id = p_item_id
	  and open_flag = 'Y'
	  and ship_from_org_id = p_org_id
	  and exists (select 1
		      from   mtl_transactions_interface
		      where  trx_source_line_id = l.line_id
			and  transaction_source_type_id in (2,8)
			and  source_code = 'ORDER ENTRY')
	  and rownum = 1;
   end if;

  if (l_org_count <> 1) then  -- Added for bug-8460461 Starts here
       select count(1)
        into l_org_count
       from mtl_supply
       where item_id = p_item_id
       and to_organization_id  =p_org_id
       and rownum =1 ;
  end if;                           -- Added for bug-#8460461 ends here


  if (l_org_count <> 1 and
    get_attribute_control('MTL_TRANSACTIONS_ENABLED_FLAG') = 1 ) then

    select master_organization_id into l_master_org
    from mtl_parameters
    where organization_id = p_org_id;
    -- Bug: 4060557 For performance improvement, breaking the SQL
    for i in (select organization_id
              from   mtl_parameters
              where  master_organization_id = l_master_org)
    loop
      select count(1) into l_master_count
      from  wsh_delivery_details
      where inventory_item_id = p_item_id
        and pickable_flag = 'Y'
        --Bug 4643978 - Perf fix
        and inv_interfaced_flag IN ('N','P')
        --and source_code = 'OE'
        and released_status <> 'D'
        and organization_id = i.organization_id
        and rownum = 1;

      if nvl(l_master_count, 0) = 1 then
        exit;
      end if;
    end loop;

    if nvl(l_master_count, 0) <> 1 then
	select count(1) into l_master_count /*l_org_count */ /*Bugfix 8460461 */
        from oe_order_lines_all
        where source_type_code = 'EXTERNAL'
          and open_flag = 'Y'
          and nvl(shipped_quantity,0) = 0
          and item_type_code in ('MODEL','STANDARD','OPTION')
          and FLOW_STATUS_CODE = 'AWAITING_RECEIPT'
          and inventory_item_id = p_item_id
          -- bug 9558897, base bug 9327156, perf issue
          and ship_from_org_id in (select organization_id
               from   mtl_parameters
               where  master_organization_id = l_master_org)
          -- bug 9558897, base bug 9327156, perf issue
          and rownum = 1;
    end if;

    if nvl(l_master_count, 0) <> 1 then

	select count(1) into l_master_count /*l_org_count *//*bugfix 8460461 */
        from oe_order_lines_all l
        where booked_flag = 'Y'
          and nvl(shipped_quantity,0) = 0
          and inventory_item_id = p_item_id
          and open_flag = 'Y'
          -- bug 9558897, base bug 9327156, perf issue
          and ship_from_org_id in (select organization_id
               from   mtl_parameters
               where  master_organization_id = l_master_org)
          -- bug 9558897, base bug 9327156, perf issue
          and exists (select 1
                      from   mtl_transactions_interface
                      where  trx_source_line_id = l.line_id
                        and  transaction_source_type_id in (2,8)
                        and  source_code = 'ORDER ENTRY')
          and rownum = 1;

    end if;

  if nvl(l_master_count, 0) <> 1 then   -- Added for bug#8460461 Starts here

        for i in (select organization_id
                  from   mtl_parameters
                  where  master_organization_id = l_master_org)
        loop
           select count(1) into l_master_count
           from mtl_supply
           where item_id = p_item_id
           and to_organization_id  = i.organization_id
           and rownum =1 ;

           if nvl(l_master_count, 0) = 1 then
            exit;
           end if;
        end loop;
  end if; --end bugfix 8460461

   end if;

  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;

end transactable_uncheck;


function check_pending_interface(p_org_id in number,
                                 p_item_id in number,
                                 p_source_item varchar2) return boolean IS
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  -- check at org level
     select count(1) into l_org_count
       from wsh_delivery_details
    where inventory_item_id = p_item_id
      and oe_interfaced_flag = 'Y'
      and nvl(inv_interfaced_flag,'N') not in ('Y','X')
      and released_status = 'C'
      and source_code = 'OE'
      and organization_id = p_org_id
      and rownum = 1;

  -- check at master level
  if (l_org_count <> 1 and
       get_attribute_control(p_source_item) = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;
    select count(1)
      into l_master_count
          from wsh_delivery_details
         where inventory_item_id = p_item_id
           and oe_interfaced_flag = 'Y'
           and nvl(inv_interfaced_flag,'N') not in ('Y','X')
           and released_status = 'C'
           and source_code = 'OE'
           and organization_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
   end if;

  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;
end check_pending_interface;


-- When changes from None to Any control
function serial_check(p_org_id in number,
                      p_item_id in number) return boolean IS
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  -- check at org level
     select count(1)
       into l_org_count
       from wsh_delivery_details
    where inventory_item_id = p_item_id
      and released_status not in ('B','R','D')
      and nvl(inv_interfaced_flag,'N') not in ('Y','X')
      and pickable_flag = 'Y'
      and source_code = 'OE'
      and organization_id = p_org_id
      and rownum = 1;

  -- check at master level
  if (l_org_count <> 1 and
       get_attribute_control('SERIAL_NUMBER_CONTROL_CODE') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;
    select count(1)
      into l_master_count
          from wsh_delivery_details
         where inventory_item_id = p_item_id
           and released_status not in ('B','R','D')
           and nvl(inv_interfaced_flag,'N') not in ('Y','X')
           and pickable_flag = 'Y'
           and source_code = 'OE'
           and organization_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
   end if;

  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;
end serial_check;

-- When changes from Yes to No
function ato_uncheck(p_org_id in number,
                     p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  select count(1) into l_org_count
     from oe_order_lines_all
    where inventory_item_id = p_item_id
      and open_flag  = 'Y'	-- Bug 8247770
      and cancelled_flag = 'N'
      and ship_from_org_id = p_org_id
      and rownum = 1;
  if (l_org_count <> 1 and
      get_attribute_control('REPLENISH_TO_ORDER_FLAG') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

     select count(1) into l_master_count
     from oe_order_lines_all
    where inventory_item_id = p_item_id
      and open_flag  = 'Y'	-- Bug 8247770
      and cancelled_flag = 'N'
      and ship_from_org_id in (select organization_id
                                   from mtl_parameters
                                  where master_organization_id = l_master_org)
      and rownum = 1;
  end if;
if (l_org_count = 1 or l_master_count = 1) then
   return TRUE;
else
   return FALSE;
end if;
end ato_uncheck;

-- when changes from no to Yes
function shippable_check(p_org_id in number,
                         p_item_id in number) return boolean is
l_org_count number := 0;
l_master_count number := 0;
l_master_org number := 0;
begin
  select count(1) into l_org_count
     from oe_order_lines_all
    where inventory_item_id = p_item_id
      and open_flag  = 'Y'	-- Bug 8247770
      and cancelled_flag = 'N'
      and ship_from_org_id = p_org_id
      and rownum = 1;

   if (l_org_count <> 1 and
       get_attribute_control('SHIPPABLE_ITEM_FLAG') = 1 ) then
        select master_organization_id into l_master_org
          from mtl_parameters
         where organization_id = p_org_id;

        select count(1) into l_master_count
          from oe_order_lines_all
         where inventory_item_id = p_item_id
           and open_flag  = 'Y'	-- Bug 8247770
	   and cancelled_flag = 'N'
           and ship_from_org_id in
                          (select organization_id
                             from mtl_parameters
                            where master_organization_id = l_master_org)
           and rownum = 1;
   end if;
  if (l_org_count = 1 or l_master_count = 1) then
     return TRUE;
  else
     return FALSE;
  end if;
end shippable_check;

end;

/
