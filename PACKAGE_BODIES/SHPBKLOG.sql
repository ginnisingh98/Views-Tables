--------------------------------------------------------
--  DDL for Package Body SHPBKLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SHPBKLOG" AS
/* $Header: SHPBLOGB.pls 115.1 99/07/16 08:17:20 porting shi $ */

------------------------------------------------------------------------

/* This function returns the backlogged amount of an order */

function ORDER_BACKLOG_AMOUNT(
	O_HEADER_ID		IN	NUMBER	DEFAULT NULL,
	O_BACKLOG_QTY		IN OUT	NUMBER
				)
   return NUMBER
IS
	L_BACKLOG_PRICE		NUMBER := 0;
	L_BACKLOG_QUANTITY	NUMBER := 0;
	O_BACKLOG_AMOUNT	NUMBER := 0;

	CURSOR backlog_line(a_header_id IN NUMBER) IS
	select
		nvl(l.selling_price,0),
		SHPBKLOG.BACKLOG_QTY(l.line_id, l.item_type_code)
	from
		so_lines l
	where
		l.header_id = a_header_id and
		l.line_type_code <> 'PARENT';

BEGIN

	O_BACKLOG_QTY := 0;

	OPEN backlog_line(O_HEADER_ID);
	LOOP
		FETCH	backlog_line INTO
			L_BACKLOG_PRICE,
			L_BACKLOG_QUANTITY;
		EXIT WHEN backlog_line%NOTFOUND;

		O_BACKLOG_AMOUNT := O_BACKLOG_AMOUNT + (L_BACKLOG_PRICE * L_BACKLOG_QUANTITY);
		O_BACKLOG_QTY := O_BACKLOG_QTY + L_BACKLOG_QUANTITY;

	END LOOP;

        RETURN(O_BACKLOG_AMOUNT);
END;




------------------------------------------------------------------------

/* This function return the quantity backlogged per line */

FUNCTION BACKLOG_QTY(
   O_LINE_ID                       IN NUMBER       DEFAULT NULL,
   ITEM_TYPE_CODE		   IN VARCHAR2     DEFAULT NULL
                          )
   RETURN NUMBER
IS

	SHIPPABLE			VARCHAR2(1) := 'N';

	SOMETHING_RELEASED		VARCHAR2(1) := 'Y';

	ALL_SHIPPABLE_RELEASED		VARCHAR2(1) := 'Y';

	ALL_DETAILS_RELEASED		VARCHAR2(1) := 'N';

	ORDERED_QTY			NUMBER DEFAULT NULL;

	CANCELLED_QTY			NUMBER DEFAULT NULL;
	BACK_QTY			NUMBER := 0;
	STANDARD_II_BACK_QTY		NUMBER := 0;
	MODEL_CLASS_BACK_QTY		NUMBER := 0;
	DUMMY				NUMBER;

	/* Assumptions:

	   1. Something was released (SOMETHING_RELEASED = 'Y'). This
	      flag is not restricted to shippable lines only.



	   2. All shippable details were released
	      (ALL_SHIPPABLE_RELEASED = 'Y').
	      Even though (below) we calculate the ALL_SHIPPABLE_RELEASED
	      flag only if the line is shippable and something was released,
	      that flag could be set to 'Y' by its default here.
	      Therefore whenever we want to make sure that a shippable
	      line was fully released we have to check all three flags.
	      (see caculcation of shippable lines and lines with included
	       items downstairs ...)

	   3. Line is not shippable

	*/

BEGIN


	/* determine if line is shippable */

	select nvl(min('Y'), 'N')
	into SHIPPABLE
	from dual
	where exists
		(select 'shippable detail'
		 from so_line_details
		 where line_id = O_LINE_ID
		 and   shippable_flag = 'Y');

	/* determine if anything was released */


	select nvl(min('Y'), 'N')
	into SOMETHING_RELEASED
	from dual
	where exists
		(select 'released details'
		 from so_line_details
		 where nvl(released_flag, 'N') = 'Y'
		 and   line_id = O_LINE_ID);


	select nvl(min('Y'), 'N')
        into ALL_DETAILS_RELEASED
	from dual
	where not exists
		    (select 'unreleased detail'
		     from so_line_details
		     where nvl(released_flag, 'N') = 'N'
		     and line_id = O_LINE_ID);


	/* select ordered and cancelled quantity for the order line */

	select
		ordered_quantity,
		nvl(cancelled_quantity, 0)
	into
		ORDERED_QTY,
		CANCELLED_QTY
	from
		so_lines
	where
		line_id = O_LINE_ID;


	/* if line is shippable and something was released
	   make sure that there are no unrepresented shippable
	   lines is so_picking_lines */


	IF (SHIPPABLE = 'Y' and SOMETHING_RELEASED = 'Y')
	then
		select nvl(min('Y'), 'N')
		into ALL_SHIPPABLE_RELEASED
		from so_line_details ld
		where ld.line_id = O_LINE_ID
		and   ld.shippable_flag = 'Y'
		and   ld.inventory_item_id+0 in
			(select distinct spl.inventory_item_id+0
			 from so_picking_lines spl
			 where spl.order_line_id = O_LINE_ID
			 and   spl.picking_header_id+0 not in (0, -1));

	end if;


	/* Determine Backlog Quantity */

	/* shippable lines where not all distinct items
	   have been released are fully backlogged
	   OR
	   lines where nothing has been released yet */

	IF (ALL_SHIPPABLE_RELEASED = 'N'
	    OR
	    SOMETHING_RELEASED = 'N') /* could be non-shippable */
	THEN

	   BACK_QTY := ORDERED_QTY - CANCELLED_QTY;
	   RETURN(BACK_QTY);

	END IF;

	/* models and classes might have children
	   which have shippable details */

	IF ((ITEM_TYPE_CODE = 'MODEL' or ITEM_TYPE_CODE = 'CLASS') and
	    SOMETHING_RELEASED = 'Y')
	THEN
	BEGIN

           select
		   pl.picking_line_id
	   into
		   dummy
           from
                   so_picking_headers ph,
		   so_picking_lines pl,
		   so_lines child,
		   so_lines parent
           where
		   parent.line_id = O_LINE_ID and
		   child.parent_line_id = parent.line_id and
		   child.line_id = pl.order_line_id and
		   pl.picking_header_id = ph.picking_header_id and
		   ph.status_code in ('CLOSED', 'PENDING', 'OPEN') and
		   ROWNUM = 1;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    RETURN(0);

	END;

	   select
		   ORDERED_QTY -
		   CANCELLED_QTY -
		   nvl(floor(min(sum(nvl(pl.shipped_quantity,0))/ max(pl.component_ratio))), 0)
	   into
		   MODEL_CLASS_BACK_QTY
	   from
		   so_picking_lines pl,
		   so_picking_headers ph,
		   so_lines child,
		   so_lines parent
	   where
		   parent.line_id = O_LINE_ID and
		   child.parent_line_id = parent.line_id and
		   child.line_id = pl.order_line_id and
		   pl.picking_header_id = ph.picking_header_id and
		   ph.status_code in ('CLOSED', 'PENDING', 'OPEN') and
		   exists
		      (select 'child is shippable'
		       from so_line_details ld
		       where ld.line_id = child.line_id) and
		   not exists
		      (SELECT 'UNREPRESENTED COMPONENT'
		       FROM SO_LINE_DETAILS LD
		       WHERE LD.LINE_ID = child.LINE_ID
		       AND LD.SHIPPABLE_FLAG = 'Y'
		       AND LD.INVENTORY_ITEM_ID+0 NOT IN
			 (SELECT DISTINCT SPL.INVENTORY_ITEM_ID+0
			  FROM SO_PICKING_LINES SPL
			  WHERE SPL.ORDER_LINE_ID = LD.LINE_ID
			  AND SPL.PICKING_HEADER_ID+0 NOT IN (0, -1)))
	   group by
		   pl.inventory_item_id;

	    IF SQL%FOUND
	    THEN
		IF MODEL_CLASS_BACK_QTY > BACK_QTY
		THEN
		   BACK_QTY := MODEL_CLASS_BACK_QTY;
		END IF;
		RETURN(BACK_QTY);
	    END IF;
	END IF;

	/* shippable standard lines and lines w/ shippable included items
           which have been fully released */

	IF (ALL_SHIPPABLE_RELEASED = 'Y' AND SHIPPABLE = 'Y' AND SOMETHING_RELEASED = 'Y')
	THEN

	    select
		    ORDERED_QTY -
		    CANCELLED_QTY -
		    nvl(floor(min(sum(nvl(pl.shipped_quantity,0)) / max(pl.component_ratio))), 0)
 	    into
		    STANDARD_II_BACK_QTY
	    from
		    so_picking_lines pl,
		    so_picking_headers ph
	    where
		    pl.order_line_id = O_LINE_ID and
		    ph.picking_header_id = pl.picking_header_id and
		    ph.status_code in ('CLOSED', 'PENDING', 'OPEN')
	    group by
		    pl.inventory_item_id;

	    IF SQL%FOUND
	    THEN
		IF STANDARD_II_BACK_QTY > BACK_QTY
		THEN
		   BACK_QTY := STANDARD_II_BACK_QTY;
		END IF;
	    END IF;

	ELSE /* unrepresented components */

  	    BACK_QTY := ORDERED_QTY - CANCELLED_QTY;


	END IF;

	/* If non-shippable and all the details are released and the item_type
	   is a standard, then do not show as backlog. */

	IF (SHIPPABLE = 'N' AND ALL_DETAILS_RELEASED = 'Y' AND
	    ITEM_TYPE_CODE IN ('STANDARD', 'KIT'))
	THEN

	    BACK_QTY := 0;

	END IF;


        RETURN(BACK_QTY);


END;


END SHPBKLOG;

/
