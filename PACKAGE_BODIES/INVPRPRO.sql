--------------------------------------------------------
--  DDL for Package Body INVPRPRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPRPRO" AS
/* $Header: INVPRPRB.pls 120.2 2005/06/20 09:19:27 appldev ship $ */

function project_where (
	order_line_id 			IN	number,
	add_where_clause IN OUT NOCOPY /* file.sql.39 change */ varchar2 ) return number IS

    proj_id 	number;
    t_id 	number;
    success 	number;

  BEGIN

    success 		:= 0;
    add_where_clause 	:= '';

    /* get the project and task based on order line id */

   if order_line_id is null then
	success := -1;
	return success;
    else
	BEGIN
          -- Goto the right table based on OE/OM installation
          if (oe_install.get_active_product = 'ONT') then
	    select project_id, task_id
	    into proj_id, t_id
	    from OE_ORDER_LINES_ALL
	    where line_id = order_line_id;
	  else
	    select project_id, task_id
	    into proj_id, t_id
	    from SO_LINES_ALL
	    where line_id = order_line_id;
	  end if;
	EXCEPTION
                when NO_DATA_FOUND then
		  success := -2;
		  return success;
                when OTHERS then
		  success := -3;
		  return success;
	END;
    end if;

    /* project and task obtained succesfully */
    /* construct the where clause depending on what the values are */

    if ((proj_id IS NULL) AND (t_id IS NULL)) then

	/* no project or task referenced, pick from common inventory only */

	add_where_clause := '((A.LOCATOR_ID IS NULL) OR (A.LOCATOR_ID IS NOT NULL ' ||
	'AND (EXISTS (SELECT INVENTORY_LOCATION_ID FROM MTL_ITEM_LOCATIONS WHERE INVENTORY_LOCATION_ID = A.LOCATOR_ID AND ORGANIZATION_ID = A.ORGANIZATION_ID AND PROJECT_ID IS NULL AND TASK_ID IS NULL))))';

    elsif ((t_id IS NULL)) then

        /* no task referenced, pick from inventory corresponding to this
           project only */

	add_where_clause := '((A.LOCATOR_ID IS NOT NULL) AND (EXISTS (SELECT INVENTORY_LOCATION_ID FROM MTL_ITEM_LOCATIONS ' ||
	'WHERE INVENTORY_LOCATION_ID = A.LOCATOR_ID AND ORGANIZATION_ID = A.ORGANIZATION_ID AND PROJECT_ID = ' || TO_CHAR(proj_id) || ' AND TASK_ID IS NULL)))';

    else

	/* referencing project and task, pick only from those locators */

	add_where_clause := '((A.LOCATOR_ID IS NOT NULL) AND (EXISTS (SELECT INVENTORY_LOCATION_ID FROM MTL_ITEM_LOCATIONS ' ||
	'WHERE INVENTORY_LOCATION_ID = A.LOCATOR_ID AND ORGANIZATION_ID = A.ORGANIZATION_ID AND PROJECT_ID = ' || TO_CHAR(proj_id) || ' AND TASK_ID = '|| TO_CHAR(t_id) || ')))';

    end if;

  success := 1;
  return success;

  EXCEPTION
    WHEN OTHERS THEN
	success := -4;
	return success;
  END project_where;

END INVPRPRO;

/
