--------------------------------------------------------
--  DDL for Package Body WSH_SC_DETAILS_REQUIRED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_DETAILS_REQUIRED_PKG" as
/* $Header: WSHSCDRB.pls 115.4 99/07/16 08:20:41 porting ship $ */

--
-- Package
--   WSH_SC_DETAILS_REQUIRED_PKG
-- Purpose
--   Inventory Details Required evaluations for line/delivery/departure in SC
--   Called for line level in post-query of form or Open Interface
--   or from form at departure or delivery level
-- History
--      04-mar-97 troveda	Created
--

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --


  --
  -- Name
  --   Details Required
  -- Purpose
  --   Evaluates if a particular batch/header/line requires details or not
  -- Arguments
  -- X_Entity_id	either Picking_line_detail_id, Delivery_id or Departure_id
  -- X_Mode		either LINE, DELIVERY, DEPARTURE
  -- X_Action		BACKORDER (ignores lines with 0 SQ): CONFIRM (all lines)
  -- X_Reservations 	Y or N
  -- X_Warehouse_id     required - use profile mfg_organization_id
  -- X_Order_Category	either P for internal order or anything else
  -- X_Details_Req      Y or N
  --
  -- Notes
  -- we no longer check if the picking_header status = OPEN. We assume that
  -- this routine is only called if it is OPEN and even if its isnt, there
  -- is no harm in returning the details_required flag.



  PROCEDURE Details_Required(X_Entity_id		IN     NUMBER,
			     X_Mode			IN     VARCHAR2,
			     X_Action			IN     VARCHAR2,
			     X_Reservations 	    	IN     VARCHAR2,
			     X_Warehouse_id          	IN     NUMBER,
			     X_Order_Category		IN     VARCHAR2,
			     X_Details_Req              IN OUT VARCHAR2
                             )
  IS
    Sql_Stmt		VARCHAR2(5000);
    X_Cursor 		NUMBER;
    X_Rows 		NUMBER;
    X_Dummy		NUMBER;
    X_Stmt_Num		NUMBER;

  BEGIN
-- Initialize the Details Required Flag here
    X_Details_Req := 'N';

/*
   There is at least one detail requiring a subinventory and
   reservations are OFF or the detail has been autoscheduled
   and for a line with some shipped quantity and no primary
   subinventories exist.
*/



SQL_Stmt :=           'SELECT ''Y'' ';
SQL_Stmt := SQL_Stmt||'FROM so_picking_lines_all sopls,';
SQL_Stmt := SQL_Stmt||'     so_picking_line_details sopld ';
SQL_Stmt := SQL_Stmt||'WHERE sopls.picking_line_id  = sopld.picking_line_id';
if X_MODE = 'LINE' then
SQL_Stmt := SQL_Stmt||' AND  sopld.picking_line_detail_id =:X_ENTITY_ID';
elsif X_MODE = 'DELIVERY'  then
SQL_Stmt := SQL_Stmt||' AND  sopld.delivery_id     = :X_ENTITY_ID';
elsif X_MODE = 'DEPARTURE' then
SQL_Stmt := SQL_Stmt||' AND  sopld.departure_id    = :X_ENTITY_ID';
else
  return;
end if;
SQL_Stmt := SQL_Stmt||' AND nvl(sopld.warehouse_id,sopls.warehouse_id) = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||' AND nvl(sopld.shipped_quantity, decode(:X_Action, ';
SQL_Stmt := SQL_Stmt||'		   ''CONFIRM'', sopld.requested_quantity, ';
SQL_Stmt := SQL_Stmt||'		   ''BACKORDER'', 0)) > 0 ';
SQL_Stmt := SQL_Stmt||' AND (nvl(sopld.autoscheduled_flag,''Y'')=''Y''';
SQL_Stmt := SQL_Stmt||'	 OR :X_Reservations = ''N'')';
SQL_Stmt := SQL_Stmt||' AND sopld.subinventory is NULL';
SQL_Stmt := SQL_Stmt||' AND sopls.picking_header_id >0 ';
SQL_Stmt := SQL_Stmt||' AND NOT EXISTS';
SQL_Stmt := SQL_Stmt||'  (SELECT ''Default Sub Exists'' ';
SQL_Stmt := SQL_Stmt||'    FROM mtl_item_sub_defaults mtlisd, ';
SQL_Stmt := SQL_Stmt||'	 mtl_secondary_inventories mtlsub ';
SQL_Stmt := SQL_Stmt||'    WHERE mtlisd.organization_id = :X_WAREHOUSE_ID ';
SQL_Stmt := SQL_Stmt||'    AND mtlisd.inventory_item_id = sopls.inventory_item_id ';
SQL_Stmt := SQL_Stmt||'    AND mtlisd.default_type = 1 ';
SQL_Stmt := SQL_Stmt||'    AND mtlsub.organization_id   = :X_WAREHOUSE_ID ';
SQL_Stmt := SQL_Stmt||'    AND mtlsub.secondary_inventory_name = mtlisd.subinventory_code ';
SQL_Stmt := SQL_Stmt||'    AND mtlsub.quantity_tracked = 1 ';
SQL_Stmt := SQL_Stmt||'    AND sysdate <= nvl(mtlsub.disable_date,sysdate))';

	X_Stmt_Num := 40;
     X_Cursor := dbms_sql.open_cursor;

	X_Stmt_Num := 50;
     dbms_sql.parse(X_Cursor,SQL_Stmt,dbms_sql.v7);

	X_Stmt_Num := 60;
     dbms_sql.bind_variable(X_Cursor,'X_Entity_Id',X_Entity_Id);
     dbms_sql.bind_variable(X_Cursor,'X_Warehouse_id',X_Warehouse_id);
     dbms_sql.bind_variable(X_Cursor,'X_Reservations',X_Reservations);
     dbms_sql.bind_variable(X_Cursor,'X_Action',X_Action);

	X_Stmt_Num := 80;
     X_Rows := dbms_sql.execute(X_Cursor);

	X_Stmt_Num := 90;
     X_Rows := dbms_sql.fetch_rows(X_Cursor);

        X_Stmt_Num := 110;
     IF X_Rows <> 0 THEN
	X_Details_Req := 'Y';
	X_Stmt_Num := 100;
        IF dbms_sql.is_open(X_Cursor) THEN
	   dbms_sql.close_cursor(X_Cursor);
        END IF;
     ELSE
	X_Stmt_Num := 100;
        IF dbms_sql.is_open(X_Cursor) THEN
	   dbms_sql.close_cursor(X_Cursor);
        END IF;

/*
   Location is required or missing for one detail that is
   under locator control and no default locator is defined
   for the item in inventory.
   Join sub to default sub to get correct loc.
*/


SQL_Stmt :=           'SELECT ''Y'' ';
SQL_Stmt := SQL_Stmt||'FROM mtl_parameters mtlpar';
SQL_Stmt := SQL_Stmt||'    ,mtl_secondary_inventories mtlsin ';
SQL_Stmt := SQL_Stmt||',mtl_item_sub_defaults mtlisd ';
SQL_Stmt := SQL_Stmt||',mtl_secondary_inventories mtlsub ';
SQL_Stmt := SQL_Stmt||',mtl_system_items mtlsis ';
SQL_Stmt := SQL_Stmt||',so_picking_line_details sopld ';
SQL_Stmt := SQL_Stmt||',so_picking_lines_all sopls ';
SQL_Stmt := SQL_Stmt||'WHERE sopls.picking_line_id  = sopld.picking_line_id';
if X_MODE = 'LINE' then
SQL_Stmt := SQL_Stmt||' AND  sopld.picking_line_detail_id =:X_ENTITY_ID';
elsif X_MODE = 'DELIVERY'  then
SQL_Stmt := SQL_Stmt||' AND  sopld.delivery_id     = :X_ENTITY_ID';
elsif X_MODE = 'DEPARTURE' then
SQL_Stmt := SQL_Stmt||' AND  sopld.departure_id    = :X_ENTITY_ID';
else
  return;
end if;
SQL_Stmt := SQL_Stmt||' AND nvl(sopld.shipped_quantity, decode(:X_Action, ';
SQL_Stmt := SQL_Stmt||'	   ''CONFIRM'',  sopld.requested_quantity, ';
SQL_Stmt := SQL_Stmt||'	   ''BACKORDER'', 0)) > 0 ';
SQL_Stmt := SQL_Stmt||' AND (:X_Reservations = ''N'' ';
SQL_Stmt := SQL_Stmt||'     OR   NVL(sopld.autoscheduled_flag,''Y'')= ''Y'')';
SQL_Stmt := SQL_Stmt||' AND mtlpar.organization_id  = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||' AND sopls.picking_header_id >0 ';
SQL_Stmt := SQL_Stmt||' AND mtlsin.organization_id  = mtlpar.organization_id';
SQL_Stmt := SQL_Stmt||' AND mtlsin.secondary_inventory_name = NVL(sopld.subinventory,mtlisd.subinventory_code)';
SQL_Stmt := SQL_Stmt||' AND mtlisd.organization_id   = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||' AND mtlisd.inventory_item_id (+)   = sopls.inventory_item_id';
SQL_Stmt := SQL_Stmt||' AND mtlisd.default_type  = 1';
SQL_Stmt := SQL_Stmt||' AND mtlsub.secondary_inventory_name  = ';
SQL_Stmt := SQL_Stmt||'                       nvl(mtlisd.subinventory_code, mtlsub.secondary_inventory_name)';
SQL_Stmt := SQL_Stmt||' AND mtlsub.organization_id  = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||' AND mtlsub.quantity_tracked = 1';
SQL_Stmt := SQL_Stmt||' AND trunc(sysdate) <= nvl(mtlsub.disable_date, trunc(sysdate))';
SQL_Stmt := SQL_Stmt||' AND mtlsis.organization_id + 0  = mtlpar.organization_id';
SQL_Stmt := SQL_Stmt||' AND mtlsis.inventory_item_id = sopls.inventory_item_id + 0';
SQL_Stmt := SQL_Stmt||' AND decode(NVL( mtlpar.stock_locator_control_code,1), ';
SQL_Stmt := SQL_Stmt||'   	    1,''N'', 2,''Y'', 3,''Y'', 4,';
SQL_Stmt := SQL_Stmt||'            decode(NVL(mtlsin.locator_type,1), 1,''N'', 2,''Y'', 3, ''Y'', 4,''N'',5,';
SQL_Stmt := SQL_Stmt||'            decode(NVL( mtlsis.location_control_code,1), ';
SQL_Stmt := SQL_Stmt||'                        1,''N'', 2,''Y'', 3,''Y'',''N''),''N'')) = ''Y''';
SQL_Stmt := SQL_Stmt||' AND sopld.inventory_location_id is NULL';
SQL_Stmt := SQL_Stmt||' AND not exists';
SQL_Stmt := SQL_Stmt||'  (SELECT ''default loc for this sub exists''';
SQL_Stmt := SQL_Stmt||'   FROM   mtl_item_loc_defaults mtldl,';
SQL_Stmt := SQL_Stmt||'          mtl_secondary_inventories mtlsub,';
SQL_Stmt := SQL_Stmt||'          mtl_item_sub_defaults mtlisd';
SQL_Stmt := SQL_Stmt||'   WHERE  mtldl.inventory_item_id =  sopls.inventory_item_id';
SQL_Stmt := SQL_Stmt||'   AND    mtldl.organization_id =  :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||'   AND    mtldl.default_type = 1';
SQL_Stmt := SQL_Stmt||'   AND    mtldl.subinventory_code = mtlsub.secondary_inventory_name';
SQL_Stmt := SQL_Stmt||'   AND    mtlisd.organization_id =  :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||'   AND    mtlisd.inventory_item_id = sopls.inventory_item_id';
SQL_Stmt := SQL_Stmt||'   AND    mtlisd.default_type = 1';
SQL_Stmt := SQL_Stmt||'   AND    mtlsub.organization_id = mtlisd.organization_id';
SQL_Stmt := SQL_Stmt||'   AND    mtlsub.secondary_inventory_name = mtlisd.subinventory_code';
SQL_Stmt := SQL_Stmt||'   AND    mtlsub.quantity_tracked = 1';
SQL_Stmt := SQL_Stmt||'   AND    trunc(sysdate) <= nvl( mtlsub.disable_date, trunc(sysdate)))';


     X_Stmt_Num := 120;
     X_Cursor := dbms_sql.open_cursor;

	X_Stmt_Num := 130;
     dbms_sql.parse(X_Cursor,SQL_Stmt,dbms_sql.v7);

	X_Stmt_Num := 140;
     dbms_sql.bind_variable(X_Cursor,'X_Entity_Id',X_Entity_Id);
     dbms_sql.bind_variable(X_Cursor,'X_Reservations',X_Reservations);
     dbms_sql.bind_variable(X_Cursor,'X_Warehouse_id',X_Warehouse_id);
     dbms_sql.bind_variable(X_Cursor,'X_Action',X_Action);

	X_Stmt_Num := 160;
     X_Rows := dbms_sql.execute(X_Cursor);

	X_Stmt_Num := 170;
     X_Rows := dbms_sql.fetch_rows(X_Cursor);

        X_Stmt_Num := 180;
     IF X_Rows <> 0 THEN
	X_Details_Req := 'Y';
	X_Stmt_Num := 190;
        IF dbms_sql.is_open(X_Cursor) THEN
	   dbms_sql.close_cursor(X_Cursor);
        END IF;
     ELSE
	X_Stmt_Num := 200;
        IF dbms_sql.is_open(X_Cursor) THEN
	   dbms_sql.close_cursor(X_Cursor);
        END IF;


/*
   Revision, Lot or serial number information is required by at least
   one detail and is missing
*/


SQL_Stmt :=           'SELECT ''Y''';
if X_MODE = 'DELIVERY'  then
SQL_Stmt := SQL_Stmt||'  FROM (select  pl.picking_line_id, pld.warehouse_id, pld.shipped_quantity, ';
SQL_Stmt := SQL_Stmt||'                pld.requested_quantity, pld.autoscheduled_flag, pld.revision, ';
SQL_Stmt := SQL_Stmt||'                pld.lot_number, h.order_category, pld.serial_number, pld.transaction_temp_id ';
SQL_Stmt := SQL_Stmt||'        from so_headers_all h, so_lines_all l, so_picking_lines_all pl, ';
SQL_Stmt := SQL_Stmt||'             so_picking_line_details pld ';
SQL_Stmt := SQL_Stmt||'        where pld.picking_line_id = pl.picking_line_id ';
SQL_Stmt := SQL_Stmt||'        and pl.order_line_id = l.line_id ';
SQL_Stmt := SQL_Stmt||'        and l.header_id = h.header_id ';
SQL_Stmt := SQL_Stmt||'        and pld.delivery_id = :X_ENTITY_ID) sopld';
elsif X_MODE = 'DEPARTURE' then
SQL_Stmt := SQL_Stmt||'  FROM (select pl.picking_line_id, pld.warehouse_id, pld.shipped_quantity, ';
SQL_Stmt := SQL_Stmt||'               pld.requested_quantity, pld.autoscheduled_flag, pld.revision, ';
SQL_Stmt := SQL_Stmt||'               pld.lot_number, h.order_category, pld.serial_number, pld.transaction_temp_id ';
SQL_Stmt := SQL_Stmt||'        from so_headers_all h, so_lines_all l, so_picking_lines_all pl, ';
SQL_Stmt := SQL_Stmt||'             so_picking_line_details pld ';
SQL_Stmt := SQL_Stmt||'        where pld.picking_line_id = pl.picking_line_id ';
SQL_Stmt := SQL_Stmt||'        and pl.order_line_id = l.line_id ';
SQL_Stmt := SQL_Stmt||'        and l.header_id = h.header_id ';
SQL_Stmt := SQL_Stmt||'        and pld.departure_id = :X_ENTITY_ID) sopld';
else
SQL_Stmt := SQL_Stmt||'  FROM so_picking_line_details sopld';
end if;
SQL_Stmt := SQL_Stmt||'      ,mtl_system_items mtlsis';
SQL_Stmt := SQL_Stmt||'      ,so_picking_lines_all sopls ';
SQL_Stmt := SQL_Stmt||'WHERE sopls.picking_line_id  = sopld.picking_line_id';
if X_MODE = 'LINE' then
SQL_Stmt := SQL_Stmt||' AND  sopld.picking_line_detail_id =:X_ENTITY_ID';
elsif X_MODE IN ('DEPARTURE', 'DELIVERY')  then
null;
else
  return;
end if;
SQL_Stmt := SQL_Stmt||'  AND  NVL(sopld.warehouse_id, sopls.warehouse_id)   = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||'  AND  nvl(sopld.shipped_quantity, decode(:X_Action, ';
SQL_Stmt := SQL_Stmt||'			      ''CONFIRM'', sopld.requested_quantity, ';
SQL_Stmt := SQL_Stmt||'			      ''BACKORDER'', 0)) > 0 ';
SQL_Stmt := SQL_Stmt||'  AND (:X_Reservations = ''N'' ';
SQL_Stmt := SQL_Stmt||'       OR  NVL(sopld.autoscheduled_flag,''Y'')= ''Y'')';
SQL_Stmt := SQL_Stmt||'  AND mtlsis.organization_id + 0  = :X_WAREHOUSE_ID';
SQL_Stmt := SQL_Stmt||' AND sopls.picking_header_id >0 ';
SQL_Stmt := SQL_Stmt||'  AND mtlsis.inventory_item_id   = sopls.inventory_item_id + 0';
SQL_Stmt := SQL_Stmt||'  AND (  (decode( mtlsis.revision_qty_control_code,2,''Y'',''N'') = ''Y'' ';
SQL_Stmt := SQL_Stmt||'          AND sopld.revision is NULL)';
SQL_Stmt := SQL_Stmt||'       OR(decode(mtlsis.lot_control_code,2,''Y'',3,''Y'',''N'') = ''Y''';
SQL_Stmt := SQL_Stmt||'	         AND sopld.lot_number is NULL)';
SQL_Stmt := SQL_Stmt||'       OR(decode(mtlsis.serial_number_control_code,2,''Y'',5,''Y'',';
if X_MODE IN ('DELIVERY','DEPARTURE')  then
SQL_Stmt := SQL_Stmt||'	       6,decode(sopld.order_category,''P'',''N'',''Y''), ''N'') = ''Y''';
else
SQL_Stmt := SQL_Stmt||'	       6,decode(:X_Order_Category,''P'',''N'',''Y''), ''N'') = ''Y''';
end if;

--if serial number is null also ensure transaction_temp_id is null
--if transaction_temp_id exists, make sure quantity in msnt is the shipped quantity
SQL_Stmt := SQL_Stmt||'	         AND (  (sopld.serial_number is NULL ';
SQL_Stmt := SQL_Stmt||'                         and (sopld.transaction_temp_id is NULL';
SQL_Stmt := SQL_Stmt||'                              or (not exists (select null from mtl_serial_numbers_temp';
SQL_Stmt := SQL_Stmt||'                                              where transaction_temp_id = sopld.transaction_temp_id))))';

SQL_Stmt := SQL_Stmt||'               or( (sopld.serial_number is NULL or sopld.shipped_quantity>1)';
SQL_Stmt := SQL_Stmt||'                   and sopld.shipped_quantity <> ';

-- here we select the ranges of serial numbers ie: select sum(nvl(to_sn,from_sn) - from_sn) +1
-- it is a little more complex because sn are varchars so we have to strip of the leading prefixes.
-- Bug 848584 : Added nvl before substr (2 places)
SQL_Stmt := SQL_Stmt||'                    (select nvl(sum(to_number(nvl(substr(nvl(to_serial_number,fm_serial_number),';
SQL_Stmt := SQL_Stmt||'				nvl(length(rtrim(nvl(to_serial_number,fm_serial_number), ''0123456789'')),0) + 1),0)) -';
SQL_Stmt := SQL_Stmt||'	to_number(nvl(substr(fm_serial_number,';
SQL_Stmt := SQL_Stmt||'				nvl(length(rtrim(fm_serial_number, ''0123456789'')),0) + 1),0)) + 1),0) ';
SQL_Stmt := SQL_Stmt||'                     from mtl_serial_numbers_temp msnt';
SQL_Stmt := SQL_Stmt||'                     where msnt.transaction_temp_id = sopld.transaction_temp_id)))))';



	X_Stmt_Num := 210;
     X_Cursor := dbms_sql.open_cursor;

	X_Stmt_Num := 220;
     dbms_sql.parse(X_Cursor,SQL_Stmt,dbms_sql.v7);

	X_Stmt_Num := 230;
     dbms_sql.bind_variable(X_Cursor,'X_Entity_Id',X_Entity_Id);
     dbms_sql.bind_variable(X_Cursor,'X_Reservations',X_Reservations);
     dbms_sql.bind_variable(X_Cursor,'X_Warehouse_id',X_Warehouse_id);
     dbms_sql.bind_variable(X_Cursor,'X_Action',X_Action);
     if X_MODE not in ('DEPARTURE','DELIVERY') then
       dbms_sql.bind_variable(X_Cursor,'X_Order_Category',X_Order_Category);
     end if;

	X_Stmt_Num := 250;
     X_Rows := dbms_sql.execute(X_Cursor);

	X_Stmt_Num := 260;
     X_Rows := dbms_sql.fetch_rows(X_Cursor);

        X_Stmt_Num := 270;
     IF X_Rows <> 0 THEN
	X_Details_Req := 'Y';
	X_Stmt_Num := 280;
        IF dbms_sql.is_open(X_Cursor) THEN
	   dbms_sql.close_cursor(X_Cursor);
        END IF;
     ELSE
	X_Details_Req := 'N';
     END IF;
    END IF;
   END IF;

     IF dbms_sql.is_open(X_Cursor) THEN
	dbms_sql.close_cursor(X_Cursor);
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_DETAILS_REQUIRED_PKG.Details_Required');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',X_Stmt_Num ||':'|| SQL_Stmt);
 	APP_EXCEPTION.Raise_Exception;
  END Details_Required;

END WSH_SC_DETAILS_REQUIRED_PKG;

/
