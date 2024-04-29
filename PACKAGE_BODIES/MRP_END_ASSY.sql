--------------------------------------------------------
--  DDL for Package Body MRP_END_ASSY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_END_ASSY" AS
/* $Header: MRPEPEGB.pls 115.10 2004/05/25 22:40:55 schaudha ship $ */
procedure peg(p_org_id IN number,
              p_compile_desig IN varchar2,
              p_item_to_peg IN number) is

  count_rows                 number;
  direct_using_assembly      number;
  direct_usage               number;
  SYS_YES     CONSTANT INTEGER := 1;
  SYS_NO      CONSTANT INTEGER := 2;
  --
  --
  -- Define a procedure that will be recursively called in
  -- order to perform end assembly pegging
  --
  procedure recursively_peg (component IN number,
                             cumulative_usage IN number,
                             cumulative_set_back_time IN number,
                             first_level IN boolean ) is
    --
    -- Define a cursor to be used in a cursor FOR loop that
    -- retrieves the using assemblies of the component.
    cursor get_us_assy(c_org_id number, c_compile_desig varchar2,
                       c_component number) IS
          SELECT bom.using_assembly_id using_assembly_item_id,
                         sum(bom.usage_quantity) operation_usage_quantity
          FROM   mrp_bom_components bom,
                 mrp_plan_organizations_v plans
          WHERE  bom.compile_designator = c_compile_desig
          AND    bom.compile_designator = plans.compile_designator
          AND    trunc(bom.effectivity_date) <= trunc(plans.CUTOFF_DATE)
          AND    bom.organization_id = plans.planned_organization
          AND    bom.inventory_item_id = c_component
          AND    bom.alternate_bom_designator is null
          AND    bom.organization_id = c_org_id
          group by using_assembly_id ;

    check_table                 number;
    cum_usage                   number;
    old_usage			number;
    cum_set_back_time           number;
    old_set_back_time           number;
    lead_time                   number;
    var_user_id                 number;

  begin
    --
    --
    -- Begin loop to check each using assembly of the component
    --
    for ea in get_us_assy (p_org_id, p_compile_desig, component) loop
    --
    --
      -- If the item is a direct using assembly of the item to peg, then
      -- save direct using assembly id and usage to variables
      --
      if first_level then
        direct_using_assembly := ea.using_assembly_item_id;
        direct_usage := ea.operation_usage_quantity;
      end if;
      --
      -- Calculate cumulative usage and cumulative set back time
      --
      cum_usage := ea.operation_usage_quantity * cumulative_usage;
      SELECT NVL(full_lead_time, 0) +
             NVL(postprocessing_lead_time, 0) +
             NVL(preprocessing_lead_time, 0)
      INTO   lead_time
      FROM   mrp_system_items
      WHERE  organization_id = p_org_id
      AND    compile_designator = p_compile_desig
      AND    inventory_item_id = ea.using_assembly_item_id;
      cum_set_back_time := lead_time + cumulative_set_back_time;
      --
      -- Check to see if using assembly is an end assembly
      -- (If no rows in mrp_assembly_operations have a value of
      -- inventory_item_id equal to the using assembly in question,
      -- then the using assembly is an end assembly.)
      --
	SELECT count(inventory_item_id)
	INTO   check_table
	FROM   mrp_bom_components
	WHERE  organization_id = p_org_id
	AND    compile_designator = p_compile_desig
	AND    alternate_bom_designator is null
	AND    inventory_item_id = ea.using_assembly_item_id
	AND    ROWNUM = 1;

      if check_table = 0 then  -- yes, it is an end assembly
        --
        -- Check to see if a row already exists that has the same
        -- inventory_item_id, using_assembly_id, and end_assembly_id
        --
        SELECT COUNT(inventory_item_id)
        INTO   check_table
        FROM   mrp_end_assemblies
        WHERE  organization_id = p_org_id
        AND    compile_designator = p_compile_desig
        AND    inventory_item_id = p_item_to_peg
        AND    using_assembly_id = direct_using_assembly
        AND    end_assembly_id = ea.using_assembly_item_id
        AND    ROWNUM = 1;

        var_user_id := fnd_profile.value('USER_ID');
        if var_user_id is NULL then
          var_user_id := -1;
        end if;
        if check_table = 0 then
          --
          -- No, the row does not exist, so insert the row.
          --
          INSERT INTO mrp_end_assemblies (organization_id,
                      compile_designator, inventory_item_id,
                      using_assembly_id, end_assembly_id, usage,
                      set_back_time, end_usage,
                      last_update_date, last_updated_by,
                      creation_date, created_by)
          VALUES      (p_org_id, p_compile_desig, p_item_to_peg,
                       direct_using_assembly, ea.using_assembly_item_id,
                       direct_usage, cum_set_back_time, cum_usage,
                       SYSDATE, var_user_id, SYSDATE, var_user_id);
          COMMIT;
        else
        --
        -- Yes, the row exists.  If the new set back time is longer than
        -- the set back time of the row in the database, then update the
        -- row with the new set back time and usage.
        --
          SELECT set_back_time
          INTO   old_set_back_time
          FROM   mrp_end_assemblies
          WHERE  organization_id = p_org_id
          AND    compile_designator = p_compile_desig
          AND    inventory_item_id = p_item_to_peg
          AND    using_assembly_id = direct_using_assembly
          AND    end_assembly_id = ea.using_assembly_item_id;

          if cum_set_back_time > old_set_back_time then

            SELECT end_usage
            INTO   old_usage
            FROM   mrp_end_assemblies
            WHERE  organization_id = p_org_id
            AND    compile_designator = p_compile_desig
            AND    inventory_item_id = p_item_to_peg
            AND    using_assembly_id = direct_using_assembly
            AND    end_assembly_id = ea.using_assembly_item_id;

            cum_usage := cum_usage + old_usage;

            UPDATE mrp_end_assemblies
            SET    end_usage = cum_usage,
				   set_back_time = cum_set_back_time,
				   last_update_date = SYSDATE,
				   last_updated_by = var_user_id
            WHERE  organization_id = p_org_id
            AND    compile_designator = p_compile_desig
            AND    inventory_item_id = p_item_to_peg
            AND    using_assembly_id = direct_using_assembly
            AND    end_assembly_id = ea.using_assembly_item_id;

            COMMIT;
          end if;
        end if;
      else -- no, the using assembly is not an end assembly
        --
        -- Make a recursive call of this procedure to continue the end
        -- assembly pegging process.
        --
        recursively_peg(ea.using_assembly_item_id,
                        cum_usage,
                        cum_set_back_time,
                        FALSE );
      end if;
    end loop;
  end;

begin
  --
  -- Has end assembly pegging been previously performed for this item?
  --
	  SELECT COUNT(*)
	  INTO count_rows
	  FROM mrp_end_assemblies
	  WHERE organization_id = p_org_id
	  AND compile_designator = p_compile_desig
	  AND inventory_item_id = p_item_to_peg
	  AND ROWNUM = 1;
  --
  -- If no rows retrieved, then perform end assembly pegging
  --
  if count_rows = 0 then
    --
    -- Call recursive procedure to peg end assemblies
    --
    recursively_peg(p_item_to_peg, 1, 0, TRUE);
  end if;
end peg;

END MRP_END_ASSY;

/
