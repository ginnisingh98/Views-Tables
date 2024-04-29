--------------------------------------------------------
--  DDL for Package Body WSH_SC_DEL_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_DEL_LINES" as
/* $Header: WSHSCDLB.pls 115.1 99/07/16 08:20:29 porting ship $ */

Procedure update_shp_qty(del_id number, action_code varchar2) is
begin

--this procedure updates the shipped quantity when we try to pack
--depending on the action_code passed

  IF action_code = 'ALL' THEN

    UPDATE so_picking_line_details
    SET shipped_quantity = requested_quantity
    WHERE shipped_quantity IS NULL
    AND   picking_line_detail_id IN
       ( SELECT pld.picking_line_detail_id
         FROM so_picking_lines_all pl, so_picking_line_details pld
         WHERE pl.picking_header_id+0 > 0
         AND   pl.picking_line_id = pld.picking_line_id
         AND   pld.delivery_id = del_id );

  ELSIF action_code = 'ENTERED' THEN

    UPDATE so_picking_line_details
    SET shipped_quantity = 0
    WHERE shipped_quantity IS NULL
    AND   picking_line_detail_id IN
       ( SELECT pld.picking_line_detail_id
         FROM so_picking_lines_all pl, so_picking_line_details pld
         WHERE pl.picking_header_id+0 > 0
         AND   pl.picking_line_id = pld.picking_line_id
         AND   pld.delivery_id = del_id );

  ELSIF action_code = 'BACKORDER_ALL' THEN

    UPDATE so_picking_line_details
    SET shipped_quantity = 0
    WHERE picking_line_detail_id IN
       ( SELECT pld.picking_line_detail_id
         FROM so_picking_lines_all pl, so_picking_line_details pld
         WHERE pl.picking_header_id + 0 > 0
         AND   pl.picking_line_id = pld.picking_line_id
         AND   pld.delivery_id = del_id );

  END IF;

  -- now go ahead and update the shipped quantity on picking lines
  -- we need to do this here since we do not do this at close time
  -- unless we have a case of Split picking header/line.

   UPDATE so_picking_lines_all pl
   SET pl.shipped_quantity =
    (select sum (pld.shipped_quantity)
     from so_picking_lines_all pl1, so_picking_line_details pld
     where pld.delivery_id = del_id
     and   pld.picking_line_id = pl1.picking_line_id
     and   pl.picking_line_id = pl1.picking_line_id
     and   pl.picking_header_id+0 > 0)
   WHERE  pl.picking_line_id in
  (select picking_line_id
   from so_picking_line_details
   where delivery_id = del_id ) ;


end;

PROCEDURE update_unrel_lines(del_id number) is
begin
    UPDATE so_line_details
    SET released_flag = 'N'
    WHERE line_detail_id IN
    ( SELECT ld.line_detail_id
      FROM  so_line_details ld, so_lines_all l
      WHERE ld.delivery_id = del_id
      AND  l.ato_line_id is NULL
      AND  ld.configuration_item_flag is NULL
      AND  l.ato_flag = 'Y'
      AND  l.s2 = 5
      AND  ld.released_flag = 'Y'
      AND  ld.shippable_flag = 'N'
      AND  l.line_id = ld.line_id);


    UPDATE so_line_details
    SET delivery_id = NULL,
	departure_id = NULL,
        dpw_assigned_flag = 'N'
    WHERE line_detail_id IN
    ( SELECT ld.line_detail_id
    FROM so_line_details ld, so_lines_all l
    WHERE ld.delivery_id = del_id
    AND   ld.released_flag = 'N'
    AND   l.line_id = ld.line_id);

    UPDATE so_picking_line_details
    SET delivery_id = NULL,
	departure_id = NULL,
        dpw_assigned_flag = 'N'
    WHERE picking_line_detail_id IN
    ( SELECT pld.picking_line_detail_id
    FROM so_picking_lines_all pl, so_picking_line_details pld
    WHERE pld.delivery_id = del_id
    AND   pld.picking_line_id = pl.picking_line_id
    AND   pl.picking_header_id = 0 ) ;

end;


END WSH_SC_DEL_LINES;

/
