--------------------------------------------------------
--  DDL for Package Body MTL_PARAM_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_PARAM_VALIDATE_PKG" as
/* $Header: INVSDO2B.pls 120.2 2006/07/19 06:50:48 jrayarot noship $ */

  function master_has_items(curr_org_id in NUMBER,
		master_org_id in NUMBER)
	return integer is
  v_status number := 1;
  v_garbage VARCHAR(255);
  BEGIN
	select 'x'
        into v_garbage
	from mtl_system_items i
        where i.organization_id =
	  curr_org_id
        and not exists (select 'x'
		from mtl_system_items i2
		where i2.organization_id =
		master_org_id
		and i2.inventory_item_id =
			i.inventory_item_id)
		and rownum < 2;

		return(v_status);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	v_status := 2;
	return(v_status);
  end master_has_items;

  function org_has_children(org_id in NUMBER)
	return integer is
  v_status number := 1;
  v_garbage VARCHAR(255);
  BEGIN
	select 'org has children'
	into v_garbage
        from mtl_parameters
        where master_organization_id =
		org_id
        and organization_id <>
		org_id
	and rownum < 2;

	return(v_status);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	v_status := 2;
	return(v_status);
  END org_has_children;

  function lot_control_validate(curr_lot_control in NUMBER,
		org_id in NUMBER)
	return integer is
  v_garbage VARCHAR2(255);
  v_return_val integer := 1;
  BEGIN

	if curr_lot_control = 1 then
	BEGIN
          select 'uniqueness violated'
          into v_garbage
	  from mtl_lot_numbers a, mtl_lot_numbers b
          where a.lot_number = b.lot_number
          and a.inventory_item_id <> b.inventory_item_id
          and rownum < 2;

 	  v_return_val := -1;
	  return(v_return_val);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  return(v_return_val);
	END;
	elsif curr_lot_control = 2 then
   	BEGIN
	  select 'uniqueness already imposed'
	  into v_garbage
          from mtl_parameters
          where lot_number_uniqueness = 1
          and organization_id <>
		org_id
          and rownum < 2;

	  v_return_val := 2;
	  return(v_return_val);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  return(v_return_val);
	END;

	else
	   app_exception.invalid_argument('LOT_CONTROL_VALIDATE',
		'CURR_LOT_CONTROL', curr_lot_control);
	end if;
  end lot_control_validate;

  function serial_control_validate(
		curr_serial_control in NUMBER,
		org_id in NUMBER)
	return integer IS
  v_garbage VARCHAR2(255);
  v_return_val integer := 1;
  l_ser_num VARCHAR2(30);
  l_ser_count NUMBER;
  cursor ser_config(p_org_id number) is
      select serial_number,count(*)
	from mtl_serial_numbers
	where inventory_item_id in (select inventory_item_id
				      from mtl_system_items_b
				       where organization_id = p_org_id
				       and serial_number_control_code <> 1
				       and base_item_id is not null
				       and bom_item_type = 4)
          and current_organization_id = p_org_id
      group by serial_number
      having count(*) > 1;
  BEGIN
/* bug 3403255 Added check to validate serial uniqueness with in model and items
 * this is to support the serial uniqueness for the configured items of the
 * same base model can have the same serial numbers.
 * Lookup codes are changed now
 * 1 -- Serial unique with in model and item
 * 4 -- Serial unique with in items
 * When changing to 1 we need to validate whether same base model configurations
 * are having the same serial if so error out */

   if curr_serial_control is null then
	app_exception.invalid_argument(
		'SERIAL_CONTROL_VALIDATE',
		'CURR_SERIAL_CONTROL',
		curr_serial_control);
   elsif curr_serial_control = 4 then -- At item Level
	BEGIN
	   select 'break constraint'
	   into v_garbage
	   from mtl_parameters
	   where serial_number_type = 3
	   and organization_id <> org_id
	   and rownum < 2;

	   v_return_val := 3;
	   return(v_return_val);

	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	 	v_return_val := 1;
	   	return(v_return_val);
	 END;

   elsif curr_serial_control = 2 then -- With in Org
	BEGIN
	select 'uniqueness violated'
	into v_garbage
	from mtl_serial_numbers a,
	     mtl_serial_numbers b
	where a.serial_number = b.serial_number
	and a.current_organization_id = org_id
	and b.current_organization_id = org_id
	and a.inventory_item_id <> b.inventory_item_id
	and rownum < 2;

	v_return_val := 0;
	return(v_return_val);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	 BEGIN
	   select 'break constraint'
	   into v_garbage
	   from mtl_parameters
	   where serial_number_type = 3
	   and organization_id <> org_id
	   and rownum < 2;

	   v_return_val := 3;
	   return(v_return_val);

	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	 	v_return_val := 1;
	   	return(v_return_val);
	 END;
	END;

   elsif curr_serial_control = 3 then -- Across Org
      BEGIN
        --Bug 5263266 Modified the below sql for performance issues.
	--select 'uniqueness violated'
	--into v_garbage
	--from mtl_serial_numbers a,
	--     mtl_serial_numbers b
	--where a.serial_number = b.serial_number
	--and a.current_organization_id <>
	--	b.current_organization_id
	--and rownum < 2;
	--Modified SQL
	select 'uniqueness violated'
	  into v_garbage
          from mtl_serial_numbers a
         where exists ( select 1
                          from mtl_serial_numbers b
                         where a.serial_number = b.serial_number
                           and a.current_organization_id <>  b.current_organization_id )
           and rownum < 2;
         --End Bug 5263266
	v_return_val := 2;
	return(v_return_val);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          select 'uniqueness violated'
          into v_garbage
          from mtl_serial_numbers a,
               mtl_serial_numbers b
          where a.serial_number = b.serial_number
          and a.current_organization_id = org_id
          and b.current_organization_id = org_id
          and a.inventory_item_id <> b.inventory_item_id
          and rownum < 2;

          v_return_val := 0;
          return(v_return_val);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                v_return_val := 1;
                return(v_return_val);
        END;
      END;
   elsif curr_serial_control = 1 then -- At model level
     begin
	open ser_config(org_id);
	fetch ser_config into l_ser_num,l_ser_count;
	if (ser_config%found) then
	  v_return_val := 4;
        else
	  select 'break constraint'
	    into v_garbage
	    from mtl_parameters
	    where serial_number_type = 3
	      and organization_id <> org_id
	      and rownum < 2;
          v_return_val := 3;
       end if;

       close ser_config;
       return(v_return_val);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       v_return_val := 1; close ser_config;
       return(v_return_val);
     END;
   else
	app_exception.invalid_argument(
		'SERIAL_CONTROL_VALIDATE',
		'CURR_SERIAL_CONTROL',
		curr_serial_control);
   end if;
  end serial_control_validate;

END MTL_PARAM_VALIDATE_PKG;

/
