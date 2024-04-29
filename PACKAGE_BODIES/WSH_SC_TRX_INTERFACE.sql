--------------------------------------------------------
--  DDL for Package Body WSH_SC_TRX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_TRX_INTERFACE" as
/* $Header: WSHSDOIB.pls 115.17 99/08/19 17:01:12 porting s $ */
   completion_status varchar2(20);
   conc_request_id   number;

--****************************************************************************
-- PACKAGE NAME:  WSH_SC_TRX_INTERFACE
-- DESCRIPTION:   Ship Confirm Open Interface
-- Main Function: Confirm_Interface_Data
--
-- DEPENDANCIES
-- Calls the folowing packages:
--      WSH_SC_VALIDATION
--      SHP_SC_SERIAL_VALIDATION_PKG.check_serial_number
--      SHP_SC_DETAILS_REQUIRED_PKG.details_required
--      SHP_SC_CLOSE_HEADER_PKG.validate_ship_date
--      SHP_SC_CLOSE_HEADER_PKG.close_headers
--         calls SHP_SC_QUANTITY_PKG.Cascade_Quantity
--****************************************************************************


-----------------------------------------------------------------------------------
  -- Name :              Duplicate_sn_in_interface
  -- Purpose:            vaidate against duplicates in interface data
  -- Arguments
  --   x_serial_number_control_code
  --   x_warehouse_id    input org id
  --   x_item_id         input item_id
  --   x_rowid           the rowid of the detail line being processed
  --                     with this sn
  --   x_sn              the serial number
  --   RETURNS TRUE if duplicate exists else FALSE
  -- Notes
  --   this checks interface data for duplicates.
  --
-----------------------------------------------------------------------------------

  FUNCTION  Duplicate_SN_in_Interface(X_serial_number_control_code in varchar2,
                 		      X_warehouse_id		   in number,
                 		      X_item_id              	   in number,
                 		      X_rowid                      in varchar2,
                 		      X_sn	        	   in varchar2) return BOOLEAN is

  BEGIN

     DECLARE

       check_item            varchar2(1);
       check_org             varchar2(1);
       x_sn_type             varchar2(1);
       x_transaction_id      number;
       x_item_concat_segs    varchar2(2000);
       valid_flag            boolean;

       CURSOR DUP_CHECK is
         SELECT del.transaction_id
         FROM   wsh_deliveries_interface          del,
      	        wsh_picking_details_interface     dtl
         WHERE  nvl( dtl.shipped_quantity, 0 ) <> 0
           AND  dtl.rowid <> chartorowid(x_rowid)
           AND  del.transaction_id = dtl.transaction_id
           AND  del.process_flag = 1
           AND  dtl.serial_number =  X_sn
           AND  (check_item = 'Y' and (dtl.inventory_item_id = X_item_id
                OR dtl.inventory_item = X_item_concat_segs)
                OR check_item <> 'Y')
           AND  dtl.warehouse_id = decode(check_org,  'Y', X_warehouse_id, dtl.warehouse_id);

       CURSOR IN_MTL_PARAM IS
         SELECT serial_number_type
         FROM   MTL_PARAMETERS
         WHERE  organization_id = X_warehouse_id;

     BEGIN
        check_org  := 'N';
        check_item := 'N';
        if X_SERIAL_NUMBER_CONTROL_CODE = 'Y' then
           check_org  := 'Y';
           check_item := 'Y';
        elsif X_SERIAL_NUMBER_CONTROL_CODE = 'D' then
           open  IN_MTL_PARAM;
           fetch IN_MTL_PARAM into X_sn_type;
           if IN_MTL_PARAM%FOUND then
              if X_sn_type = '1' then
                 check_item := 'Y';
              elsif X_sn_type = '2' then
                 check_org  := 'Y';
              end if;
           end if;
           close IN_MTL_PARAM;
        end if;

        if check_item = 'Y' then
           valid_flag := fnd_flex_keyval.validate_ccid(
                  appl_short_name=>'INV',
		  key_flex_code=>'MSTK',
		  structure_number=>101,
    		  combination_id=>x_item_id,
                  data_set=>x_warehouse_id);
                  x_item_concat_segs := fnd_flex_keyval.concatenated_values;
        end if;

        open  DUP_CHECK;
        fetch DUP_CHECK into X_transaction_id;
        close DUP_CHECK;

        if x_transaction_id is not null then
           return (TRUE);
        end if;
        return (FALSE);

     END;

  END Duplicate_SN_In_Interface;




-----------------------------------------------------------------------------------
  -- Name
  --   Check_Serial_Number
  -- Purpose
  --   ensure any SN in SN range is valid by dissallowing any duplicates
  --   that satisfy any one of the following 3 condtions
  --   1. current status not in (1,3)  (ie  allow 'instore' to permit RMAs that
  --      have been returned/reshelved and  'defined but not used' to permit
  --      serial numbers for predefined control)
  --   2. not yet interfaced to inventory
  --   3. exist in inventory interface tables (ie they have been interfaced
  --      but haven't been processed by inventory yet)
  --
  -- Assumptions
  --    MTL_SER_NUM_INT.FM_SN = MTL_SER_NUM_INT.to_SN therefore we do not bother
  --    with range checking on this table.
  --
  -- Arguments
  --   X_Mode : either post-change or commit.
  --   X_to_sn is required.
  --
  --   X_Serial_number_control : either N, Y or D
  --    N = No serial checking, procedure returns success
  --    Y = either predefined serial numbers or dynamic at inv receipt.
  --    D = dynamic entry at sales issue
  --
  --  X_ERROR_CODE: 0 = success
  --               -1 = error
  --               >1 = program error
  --
  -- Notes
  -- 1) dynamic sql is built according to x_mode and whether to check for
  --    uniqueness at item level, org level, neither (ie across orgs) or
  --    both (ie for dynamic entry at sales issue).
  --
  -- 2) Dynamic entry checks for uniqueness within org and item.
  --    When using dynamic, serial numbers should never exist in MTL_SN
  --    and any record that is found will be an error (other than status 1,3).
  --    Therfore we must use an outer join in these cases.
  --
  -- 3) Post-change checking excludes entire picking line from duplicate checking.
  --    Commit checking is tighter/more granular by excluding detail_line only.
  --    In this way, the user can update a picking line by swapping SN within
  --    it and not receive errors. Otherwise user would have to null out one SN,
  --    change the other SN and then set the nulled out SN
-----------------------------------------------------------------------------------


  PROCEDURE Check_Serial_Number(X_SERIAL_NUMBER_CONTROL_CODE 	IN     VARCHAR2,
                                X_WAREHOUSE_ID			IN     NUMBER,
                                X_ITEM_ID			IN     NUMBER,
                                X_LINE_ID			IN     NUMBER,
                                X_LINE_DETAIL_ID		IN     NUMBER,
                                X_SN	        		IN     VARCHAR2,
   				X_ERROR_CODE 	 		IN OUT NUMBER)  IS

  Cursor IN_MTL_PARAM IS
         select serial_number_type
         from   MTL_PARAMETERS
         where  organization_id = X_warehouse_id;

    X_Cursor 		  NUMBER;
    X_Stmt                VARCHAR2(5000);
    X_Stmt_Num	          NUMBER;
    SN_header_id          NUMBER;
    SN_line_number        NUMBER;
    x_rows  		  NUMBER;
    check_item            BOOLEAN := FALSE;
    check_org             BOOLEAN := FALSE;
    x_sn_type             VARCHAR2(1);

  BEGIN
     x_error_code := 0;

     if X_SERIAL_NUMBER_CONTROL_CODE = 'Y' then
        check_org  := TRUE;
        check_item := TRUE;
     elsif X_SERIAL_NUMBER_CONTROL_CODE = 'D' then
        open  IN_MTL_PARAM;
        fetch IN_MTL_PARAM into X_sn_type;
        if IN_MTL_PARAM%FOUND then
           if    X_sn_type = '1' then
                 check_item := TRUE;
           elsif X_sn_type = '2' then
                 check_org  := TRUE;
           end if;
        end if;
        close IN_MTL_PARAM;
     end if;


     /*** for debugging this is the statement so far

     SELECT SOPLS.PICKING_HEADER_ID, SOPLS.SEQUENCE_NUMBER
     FROM   mtl_serial_numbers s,
            so_picking_lines_all sopls,
	    so_picking_line_details_all sopld
     WHERE  sopld.picking_line_id = sopls.picking_line_id
	    and sopls.picking_line_ID <> :X_line_id
	    and sopls.inventory_item_id = :X_item_id
	    and nvl( sopls.warehouse_id,:X_warehouse_id ) =  :X_warehouse_id
	    and nvl( sopld.shipped_quantity, 0 ) <> 0
	    and (sopld.fm_serial_number <=  :X_to_sn
            and sopld.to_serial_number >=  :x_sn)
            and s.inventory_item_id (+)= :X_item_id
            and s.serial_number (+) between greatest(sopld.fm_serial_number,:x_sn)
            and least (sopld.to_serial_number,:X_to_sn)
            and (nvl(s.current_status,1) not in (1,3)
            or  nvl(sopls.inventory_status, 'NO VALUE') <> 'INTERFACED'
            or  exists (select 'serial number not yet yet interfaced'
                FROM  mtl_serial_numbers_interface si,
                      mtl_transactions_interface ti
                WHERE si.fm_serial_number between greatest(sopld.fm_serial_number,:x_sn)
                      and least (sopld.to_serial_number,:X_to_sn)
            	      and ti.source_code     =   si.source_code
            	      and ti.source_line_id  =   si.source_line_id
            	      and ti.inventory_item_id = sopls.inventory_item_id
            	      and ti.organization_id =   sopld.warehouse_id ))
     ORDER BY sopls.picking_header_id desc
     ***/

     if X_SERIAL_NUMBER_CONTROL_CODE in ('Y','D') then
        X_Stmt := X_Stmt || ' SELECT SOPLS.PICKING_HEADER_ID, ';
        X_Stmt := X_Stmt || '        SOPLS.SEQUENCE_NUMBER ';
        X_Stmt := X_Stmt || ' FROM   mtl_serial_numbers s, ';
        X_Stmt := X_Stmt || '        so_picking_lines_all sopls, ';
        X_Stmt := X_Stmt || '        so_picking_line_details sopld ';
        X_Stmt := X_Stmt || ' WHERE  sopld.picking_line_id = sopls.picking_line_id ';
        X_Stmt := X_Stmt || ' AND    sopld.picking_line_detail_id <> :X_line_detail_id ';

        if check_item then
           X_Stmt := X_Stmt || ' AND   sopls.inventory_item_id = :X_item_id ';
           -- if dynamic generation of SN then MTL_SN wont contain values so use outer join
           if X_SERIAL_NUMBER_CONTROL_CODE = 'D' then
              X_Stmt := X_Stmt || ' AND  s.inventory_item_id(+) = :X_item_id ';
           else
              X_Stmt := X_Stmt || ' AND  s.inventory_item_id = :X_item_id ';
           end if;
        end if;

        if check_org then
           X_Stmt := X_Stmt || ' AND   nvl(sopls.warehouse_id,:X_warehouse_id) = :X_warehouse_id ';
        end if;

        X_Stmt := X_Stmt || ' AND    nvl( sopld.shipped_quantity, 0 ) <> 0 ';
        X_Stmt := X_Stmt || ' AND    sopld.serial_number =  :x_sn ';

        -- if dynamic generation of SN then MTL_SN wont contain values so use outer join
        if X_SERIAL_NUMBER_CONTROL_CODE = 'D' then
        X_Stmt := X_Stmt || ' AND s.serial_number (+) = :x_sn ';
        else
          X_Stmt := X_Stmt || ' AND s.serial_number = :x_sn ';
        end if;

        X_Stmt := X_Stmt || ' AND (nvl(s.current_status,1) not in (1,3) ';
        X_Stmt := X_Stmt || '    OR  nvl(sopls.inventory_status, ''NO VALUE'') <> ''INTERFACED'' ';
        X_Stmt := X_Stmt || '    OR  exists (SELECT ''serial number not yet yet interfaced'' ';
        X_Stmt := X_Stmt || '                 FROM  mtl_serial_numbers_interface si ';

        if check_item or check_org then
           X_Stmt := X_Stmt || '                   ,mtl_transactions_interface ti ';
        end if;

        X_Stmt := X_Stmt || '                 WHERE si.fm_serial_number = :x_sn ';

        if check_item or check_org then
           X_Stmt := X_Stmt || '              AND   ti.source_code     =   si.source_code ';
           X_Stmt := X_Stmt || '              AND   ti.source_line_id  =   si.source_line_id ';

           if check_item then
              X_Stmt := X_Stmt || '           AND   ti.inventory_item_id = sopls.inventory_item_id ';
           end if;
           if check_org then
              X_Stmt := X_Stmt || '           AND   ti.organization_id =   sopld.warehouse_id ';
           end if;

        end if;

        X_Stmt := X_Stmt || ' )) ';
        X_Stmt := X_Stmt || ' ORDER BY sopls.picking_header_id DESC';
        X_Stmt_Num := 40;
        X_Cursor := dbms_sql.open_cursor;
        X_Stmt_Num := 50;
        dbms_sql.parse(X_Cursor,X_Stmt,dbms_sql.v7);
        X_Stmt_Num := 60;
        if check_org then
           dbms_sql.bind_variable (X_Cursor,'X_warehouse_id',X_warehouse_id);
        end if;
        X_Stmt_Num := 61;
        if check_item then
           dbms_sql.bind_variable (X_Cursor,'X_item_id',X_item_id);
        end if;
        X_Stmt_Num := 62;
        dbms_sql.bind_variable (X_Cursor,'x_sn',X_sn);
        X_Stmt_Num := 65;
        dbms_sql.bind_variable (X_Cursor,'X_line_detail_id',X_line_detail_id);
        X_Stmt_Num := 80;
        X_Rows := dbms_sql.execute(X_Cursor);
        X_Stmt_Num := 90;
        X_Rows := dbms_sql.fetch_rows(X_Cursor);
        X_Stmt_Num := 110;
        if X_Rows <> 0 THEN
           X_error_code := -1;
           Return;
        end if;
        X_stmt_Num := 120;
        if dbms_sql.is_open(X_Cursor) then
     	   dbms_sql.close_cursor(X_Cursor);
        end if;
     end if;

  EXCEPTION
  WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','SHP_SC_SERIAL_VALIDATION_PKG.Check_Serial_Numbers');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',X_Stmt_Num ||':'|| X_Stmt);
	APP_EXCEPTION.Raise_Exception;
  END Check_serial_number;



-----------------------------------------------------------------------------------
  -- Name:    Update_Sopld_Row
  -- Purpose: To update SOPLD with new inventory controls and
  --          shipped quantity. Inventory controls cannot be
  --          overwritten if not null, instead a new value will be input.
  --
  -- Arguments:
  --     X_picking_line_detail_id     optional: see notes
  --
  -- Notes
  -- Picking_line_detail_id may be null, in which case we update the
  -- first detail line for this picking_line with the same inventory controls.
  -- we use rownum to ensure we dont update more than one record but there
  -- shouldnt be more than one.
-----------------------------------------------------------------------------------


  PROCEDURE Update_SOPLD_Row
        (X_picking_line_id            in number,
         X_picking_line_detail_id     in number,
         X_requested_quantity         in number,
         X_shipped_quantity           in number,
	 X_warehouse                  in number,
	 X_sn                         in varchar2,
         x_lot                        in varchar2,
         x_revision                   in varchar2,
         x_subinventory               in varchar2,
         x_locator_id                 in number,
         x_departure_id               in number,
         x_delivery_id                in number,
         x_container_id               in number,
         x_context                    in varchar2,
	 x_dpw_assigned_flag 	      in varchar2,
         x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
         x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
         x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
         x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2,
         error_code                   in out varchar2) is

  BEGIN

     BEGIN
        error_code:='0';
        --------------------------------------------------------------------------
        -- this is called with either picking line detail id and no inventory controls
        -- or the opposite. Either way, it can update a record.
        -- Only one record should fit this criteria but to be sure, use rownum.
        --------------------------------------------------------------------------
        wsh_del_oi_core.println('updating pld with pld_id:'||to_char(X_picking_line_detail_id)||
                             ' pl_id:'||to_char(X_picking_line_id)||
                             ' req_qty:'||to_char(X_requested_quantity)||
                             ' shp_qty:'||to_char(X_shipped_quantity)||
                             ' warehouse:'||to_char(X_warehouse)||
                             ' srl:'||X_sn|| ' lot:'||x_lot||
                             ' rev:'||x_revision||' sub:'||x_subinventory||
                             ' loc:'|| to_char(x_locator_id)||
                             ' dep:'||to_char(x_departure_id)||
                             ' del:'||to_char(x_delivery_id)||
                             ' assg_flag:'||x_dpw_assigned_flag||
                             ' container:'||to_char(x_container_id) );

        BEGIN
           /* BUG 820933 : Changed the logic for dpw_assigned_flag. Populate the dpw_assigned_flag
              with null (which means assigned) if any of X_DELIVERY_ID,X_DEPARTURE_ID,
              pld.Departure_id,pld.Delivery_id is not null. Otherwise populate it with
              x_dpw_assigned_flag.
           */
           UPDATE SO_PICKING_LINE_DETAILS pld
           SET Last_update_date	        = sysdate,
	       Last_updated_by		= fnd_global.user_id,
	       Last_update_login	= fnd_global.user_id,
	       Warehouse_id		= nvl(X_warehouse, warehouse_id),
               Requested_quantity       = requested_quantity + x_requested_quantity,
	       Shipped_quantity         = nvl(SHIPPED_QUANTITY,0) + x_shipped_quantity,
	       Serial_number		= nvl(X_SN,        serial_number),
	       Lot_number		= nvl(X_LOT,       lot_number),
	       Revision	                = nvl(X_REVISION,  revision),
	       Subinventory		= nvl(X_SUBINVENTORY,subinventory),
	       Inventory_location_id	= nvl(X_LOCATOR_ID,inventory_location_id),
               Departure_id             = nvl(X_DEPARTURE_ID,departure_id),
               Delivery_id             = nvl(X_DELIVERY_ID, delivery_id),
               Container_id            = nvl(X_CONTAINER_ID,container_id),
               Context                 = x_context,
	       DPW_assigned_flag	= decode(nvl(nvl(X_DELIVERY_ID, delivery_id),nvl(X_DEPARTURE_ID,departure_id)),
                                          null, x_dpw_assigned_flag,null),
               Attribute1 = x_att1,   Attribute2 = x_att2,   Attribute3 = x_att3,   Attribute4 = x_att4,
               Attribute5 = x_att5,   Attribute6 = x_att6,   Attribute7 = x_att7,   Attribute8 = x_att8,
               Attribute9 = x_att9,   Attribute10 = x_att10, Attribute11 = x_att11, Attribute12 = x_att12,
               Attribute13 = x_att13, Attribute14 = x_att14, Attribute15 = x_att15,
               ( Segment1,  Segment2,  Segment3,  Segment4,  Segment5,
                 Segment6,  Segment7,  Segment8,  Segment9,  Segment10,
                 Segment11, Segment12, Segment13, Segment14, Segment15,
                 Segment16, Segment17, Segment18, Segment19, Segment20)
               = ( SELECT Segment1,  Segment2,  Segment3,  Segment4,  Segment5,
                          Segment6,  Segment7,  Segment8,  Segment9,  Segment10,
                          Segment11, Segment12, Segment13, Segment14, Segment15,
                          Segment16, Segment17, Segment18, Segment19, Segment20
                   FROM MTL_ITEM_LOCATIONS
                   WHERE inventory_location_id = nvl(x_locator_id,pld.inventory_location_id))
           WHERE pld.picking_line_id = X_picking_line_id
                 and pld.picking_line_detail_id = nvl(X_picking_line_detail_id, pld.picking_line_detail_id)
                 and ( (nvl(serial_number,nvl(x_sn,'~')) = nvl(X_sn,'~') and requested_quantity = x_shipped_quantity)
                       or
                       nvl(serial_number,'~') = nvl(X_sn,'~') )  -- vms
                 and nvl(lot_number,nvl(X_lot,'~'))     = nvl(X_lot,'~')
                 and nvl(revision,nvl(X_revision,'~'))  = nvl(X_revision,'~')
                 and   nvl(subinventory,nvl(X_subinventory,'~'))   = nvl(X_subinventory,'~')
                 and   nvl(inventory_location_id,nvl(X_locator_id,'-1'))     = nvl(X_locator_id,'-1')
                 and   nvl(delivery_id, nvl(x_delivery_id,-1)) = nvl(x_delivery_id,-1)
                 and   nvl(container_id, nvl(x_container_id,-1)) = nvl(x_container_id,-1)
                 and   rownum < 2;
      EXCEPTION when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.update_sopld');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
      END;

      if sql%notfound then
         wsh_del_oi_core.println('BUT could not update so_picking_line_details.');
         error_code := '1';
      end if;

    END;

  END Update_SOPLD_Row;




-----------------------------------------------------------------------------------
  -- Name
  -- 	Insert_Sopld_Row
  -- Arguments
  -- Line Ids are required.
  -- Inventory controls are optional. If they are not supplied then a new
  -- line is created with the inventory controls of the existing line id
  --
  -- Purpose
  --    Called when creating a remainder
  --    OR when line detail was picked from more than one set of inventory
  --    controls hence requiring a split eg:
  --    1) Serial numbers. By default, only one record is created in SOPL
  --       but if SN are interfaced then multiple records must be input
  --    2) Different Inventory controls: If reservations are OFF, the user
  --       could pick from a variety of inventory controls. Each one requires
  --       a new record.
  --
  -- Notes
  --
-----------------------------------------------------------------------------------

-- 905046. Added pick_slip_number as input to Insert_Sopld_Row.

  PROCEDURE Insert_Sopld_Row
        (X_parent_detail_id           in number,
	 new_pld_id		  in out number,
	 X_pick_slip_number           in number,
         X_requested_quantity         in number,
         X_shipped_quantity           in number,
	 X_warehouse_id               in number,
	 X_sn                         in varchar2,
         x_lot                        in varchar2,
         x_revision                   in varchar2,
         x_subinventory               in varchar2,
         x_locator_id                 in number,
         x_departure_id               in number,
         x_delivery_id                in number,
         x_container_id               in number,
         x_context                    in varchar2,

         x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
         x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
         x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
         x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2) is
  BEGIN

     SELECT SO_PICKING_LINE_DETAILS_S.NEXTVAL into new_pld_id from DUAL;

     wsh_del_oi_core.println('creating pld with pld_id:'||to_char(new_pld_id)||
			     'pick_slip_number:'||to_char(X_pick_slip_number)||
                             ' parent_id:'||to_char(X_parent_detail_id)||
                             ' req_qty:'||to_char(X_requested_quantity)||
                             ' shp_qty:'||to_char(X_shipped_quantity)||
                             ' warehouse:'||to_char(X_warehouse_id)||
                             ' srl:'||X_sn|| ' lot:'||x_lot||
                             ' rev:'||x_revision||' sub:'||x_subinventory||
                             ' loc:'|| to_char(x_locator_id)||
                             ' dep:'||to_char(x_departure_id)||
                             ' del:'||to_char(x_delivery_id)||
                             ' container:'||to_char(x_container_id) );

-- 905046. Inserting pick_slip_number into so_picking_line_details.

     INSERT INTO SO_PICKING_LINE_DETAILS(
	       PICKING_LINE_DETAIL_ID
	,      PICK_SLIP_NUMBER
	,      LAST_UPDATE_DATE
	,      LAST_UPDATED_BY
	,      LAST_UPDATE_LOGIN
	,      CREATION_DATE
	,      CREATED_BY
	,      PICKING_LINE_ID
	,      DETAIL_TYPE_CODE
	,      WAREHOUSE_ID
	,      REQUESTED_QUANTITY
	,      SHIPPED_QUANTITY
	,      SERIAL_NUMBER
	,      LOT_NUMBER
	,      CUSTOMER_REQUESTED_LOT_FLAG
	,      REVISION
	,      SUBINVENTORY
	,      INVENTORY_LOCATION_ID
	,      SEGMENT1,  SEGMENT2,  SEGMENT3,  SEGMENT4,  SEGMENT5,
	       SEGMENT6,  SEGMENT7,  SEGMENT8,  SEGMENT9,  SEGMENT10,
	       SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15,
	       SEGMENT16, SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20,
	       INVENTORY_LOCATION_SEGMENTS
	,      CONTEXT
	,      ATTRIBUTE1,  ATTRIBUTE2,  ATTRIBUTE3,  ATTRIBUTE4,  ATTRIBUTE5,
	       ATTRIBUTE6,  ATTRIBUTE7,  ATTRIBUTE8,  ATTRIBUTE9,  ATTRIBUTE10,
	       ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
	       RELEASED_FLAG
	,      SCHEDULE_DATE
	,      SCHEDULE_STATUS_CODE
	,      SCHEDULE_LEVEL
	,      TRANSACTABLE_FLAG
	,      RESERVABLE_FLAG
	,      LATEST_ACCEPTABLE_DATE
	,      AUTOSCHEDULED_FLAG
	,      DEMAND_ID
	,      DELIVERY
	,      DEMAND_CLASS_CODE
	,      UPDATE_FLAG
	,      SUPPLY_SOURCE_TYPE
	,      SUPPLY_SOURCE_HEADER_ID
        ,      DEPARTURE_ID
        ,      DELIVERY_ID
        ,      CONTAINER_ID
	,      DPW_ASSIGNED_FLAG)
    	SELECT  new_pld_id,
		X_pick_slip_number,
	        SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		FND_GLOBAL.LOGIN_ID,
		pld.picking_line_id,
	        detail_type_code,
        	nvl(x_warehouse_id,    pld.warehouse_id),
		x_requested_quantity,
		x_shipped_quantity,
		x_sn,
		nvl(x_lot,             pld.lot_number),
		pld.customer_requested_lot_flag,
		nvl(x_revision,        pld.revision),
		nvl(x_subinventory,    pld.subinventory),
		nvl(x_locator_id,      pld.inventory_location_id),
                m.Segment1,  m.Segment2,  m.Segment3,  m.Segment4,  m.Segment5,
                m.Segment6,  m.Segment7,  m.Segment8,  m.Segment9,  m.Segment10,
                m.Segment11, m.Segment12, m.Segment13, m.Segment14, m.Segment15,
                m.Segment16, m.Segment17, m.Segment18, m.Segment19, m.Segment20,
		pld.inventory_location_segments,
		nvl(x_context,pld.context),
		nvl(x_att1,pld.attribute1),   nvl(x_att1,pld.attribute2),
		nvl(x_att1,pld.attribute3),   nvl(x_att1,pld.attribute4),
		nvl(x_att1,pld.attribute5),   nvl(x_att1,pld.attribute6),
		nvl(x_att1,pld.attribute7),   nvl(x_att1,pld.attribute8),
		nvl(x_att1,pld.attribute9),   nvl(x_att1,pld.attribute10),
		nvl(x_att1,pld.attribute11),  nvl(x_att1,pld.attribute12),
		nvl(x_att1,pld.attribute13),  nvl(x_att1,pld.attribute14),
		nvl(x_att1,pld.attribute15),
                pld.released_flag,
		pld.schedule_date,
		pld.schedule_status_code,
		pld.schedule_level,
		pld.transactable_flag,
		pld.reservable_flag,
		pld.latest_acceptable_date,
		pld.autoscheduled_flag,
		pld.demand_id,
		pld.delivery,
		pld.demand_class_code,
		pld.update_flag,
		pld.supply_source_type,
		pld.supply_source_header_id,
                x_departure_id,
                x_delivery_id,
                x_container_id,
		NULL
    	FROM SO_PICKING_LINE_DETAILS PLD,
             MTL_ITEM_LOCATIONS      M
    	WHERE PLD.PICKING_LINE_DETAIL_ID = X_Parent_Detail_Id
          AND m.inventory_location_id (+) = nvl(x_locator_id,pld.inventory_location_id);

     EXCEPTION when others then
         FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.Insert_sopld');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
         FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
  	 APP_EXCEPTION.Raise_Exception;

  END Insert_Sopld_Row;


-----------------------------------------------------------------------------------
  -- Name    Update_requested_quantity
  --
  -- Arguments
  --
  -- Notes If the X_backorder_flag = TRUE (ie action_code in (9,10,11,12,13)), ie
  --       the remaining quantity is to be backordered, then the shipped_qty,
  --       departure_id, delivery_id & dpw_assigned_flag should not be nulled out,
  --       If the departure_id & delivery_id are nulled in the original pld_id,
  --       and since the insert_sopld_row will insert new rows in SOPLD
  --       with delivery_id as NOT NULL, it will result in splitting of the
  --       corresponding picking_line in SOPL.
  --       NOTE: Splitting is done if all the pld for a picking line do NOT
  --             have the same delivery_id.
-----------------------------------------------------------------------------------


  PROCEDURE Update_requested_quantity
        (X_picking_line_detail_id     in number,
         X_shipped_quantity           in number,
         X_backorder_flag             in boolean,
         error_code                   in out varchar2) is
  BEGIN
    DECLARE
         X_bo	varchar2(10) := 'FALSE';
    BEGIN

      BEGIN
         error_code:='0';
         IF ( X_backorder_flag = TRUE ) THEN
            X_bo := 'TRUE';
            wsh_del_oi_core.println('Update requested_quantity will NULL out the dep & del in sopld.');
         END IF;
         BEGIN
            UPDATE SO_PICKING_LINE_DETAILS pld
            SET requested_quantity      = requested_quantity - X_shipped_quantity,
                shipped_quantity        = decode(X_bo, 'FALSE' ,NULL,shipped_quantity),
                delivery_id             = decode(X_bo, 'FALSE' ,NULL,delivery_id),
                departure_id            = decode(X_bo, 'FALSE' ,NULL, departure_id),
                dpw_assigned_flag       = decode(X_bo, 'FALSE' ,'N',dpw_assigned_flag)
            WHERE pld.picking_line_detail_id = X_picking_line_detail_id;

         wsh_del_oi_core.println('Reduced req_qty in pl:'|| to_char(X_picking_line_detail_id)||
                                 ' by:'||to_char(X_shipped_quantity));

         EXCEPTION when others then
            FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	    FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.update_requested_quantity');
	    FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
            FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
  	    APP_EXCEPTION.Raise_Exception;
         END;
         if sql%notfound then
            wsh_del_oi_core.println('Unexpected error on picking detail '||to_char(x_picking_line_detail_id));
            error_code := '1';
         end if;
      END;
    END;
  END update_requested_quantity;



-----------------------------------------------------------------------------------
  -- Name:     Split_SOPLD_row
  -- Purpose
  -- This is called when we want to update SOPLD but have found that the line detail
  -- has different inventory controls. This procedure creates a second line detail
  -- with the new inventory controls or updates any existing line detail for this
  -- pickslip with these inventory controls.
  -- Notes
-----------------------------------------------------------------------------------

-- 905046. Added pick_slip_number as input to Split_SOPLD_Row.

  PROCEDURE Split_SOPLD_Row
        (X_picking_line_id            in number,
         X_picking_line_detail_id     in number,
	 X_pick_slip_number           in number,
	 new_pld_id		  in out number,
         X_shipped_quantity           in number,
	 X_warehouse_id               in number,
	 X_sn                         in varchar2,
         X_lot_number                 in varchar2,
         X_revision                   in varchar2,
         X_sub                        in varchar2,
         X_loc                        in varchar2,
         x_departure_id               in number,
         x_delivery_id                in number,
         x_container_id               in number,
         x_backorder_flag             in boolean,
         x_context                    in varchar2,
         x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
         x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
         x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
         x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2,
         error_code  in out varchar) is

  BEGIN
     error_code := '0';

     wsh_del_oi_core.println('Inside Split_SOPLD_Row: x_shipped_qty:'||to_char(X_shipped_quantity));

     --------------------------------------------------------------------------
     -- decrement the requested qty on the original detail line by the ship qty
     -- of the detail line we are trying to insert/update
     --------------------------------------------------------------------------
     WSH_SC_TRX_INTERFACE.update_requested_quantity (X_picking_line_detail_id, X_shipped_quantity,
                                                     X_backorder_flag, error_code);

     --------------------------------------------------------------------------
     -- before inserting a new detail line, try updating any line detail
     -- for this picking line with the same inventory controls
     -- if serial_number exists we assume there is no such line and skip this
     --------------------------------------------------------------------------
     if error_code = '0' then
         WSH_SC_TRX_INTERFACE.insert_sopld_row
          	(X_picking_line_detail_id,
           	new_pld_id,
	 	X_pick_slip_number,
	   	X_shipped_quantity,
	   	X_shipped_quantity,
	   	X_warehouse_id,
	   	X_sn,
	   	X_lot_number,
	   	X_revision,
	   	X_sub,
	   	X_loc,
           	x_departure_id,
           	x_delivery_id,
           	x_container_id,
           	x_context,
           	x_att1,  x_att2,  x_att3,  x_att4,
           	x_att5,  x_att6,  x_att7,  x_att8,
           	x_att9,  x_att10, x_att11, x_att12,
           	x_att13, x_att14, x_att15);
      end if;

  EXCEPTION when others then
         FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.split_sopld_row');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
         FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
  	 APP_EXCEPTION.Raise_Exception;

  END split_SOPLD_row;





-----------------------------------------------------------------------------------

  PROCEDURE PROCESS_PICKING_DETAILS_INTER(X_TRANSACTION_ID IN NUMBER,
                                   	  X_departure_id   in number,
                                   	  X_delivery_id    in number,
                                   	  X_warehouse_id   in number,
                                   	  X_rowid          in out varchar2,
					  X_backorder_flag in boolean ,
                                   	  x_error_code     in out varchar2) is
  BEGIN

     DECLARE
        last_item_id                   number;
        last_warehouse_id              number;
        last_sub                       varchar2(10);

  	valid_item_id                  number;
  	valid_warehouse_id             number;
  	valid_revision                 varchar2(3);
  	valid_sub                      varchar2(10);
  	valid_lot                      varchar2(30);
  	valid_loc                      number;


  	default_sub                    varchar2(10);
  	default_loc                    number;
  	valid_flag                     boolean;

  	x_reservations 		       varchar2(1);
  	x_subinv_restricted_flag       varchar2(1);
  	x_revision_control_flag        varchar2(1);
  	x_lot_control_flag             varchar2(1);
  	x_location_control_flag        varchar2(1);
  	x_location_restricted_flag     varchar2(1);
  	x_serial_number_control_flag   varchar2(1);
  	x_picking_header_id            number;
  	x_picking_line_id              number;
  	x_container_id                 number;
 	x_picking_line_detail_id       number;

  	del_status                     varchar2(2);
  	result                         boolean;
  	result_num                     number;
  	token_name                     varchar2(30);

  	processed_records              boolean;

  	error_line		       number;
  	error_code		       varchar2(240);

  	stop_pld_processing  	       EXCEPTION;

  	seg_array 		       FND_FLEX_EXT.SegmentArray;


        pl_pld_id 			number;
        pl_shp_qty 			number;
  	pl_req_qty 			number;
        new_pld_id 			number;
 	pl_del				number;
	pl_cont				number;

		-- Reservations Transfer Variables

        cannot_transfer		EXCEPTION;
    	online_no_manager	EXCEPTION;
    	online_error		EXCEPTION;
    	ret_val			NUMBER := 0;
    	success		        BOOLEAN;
    	outcome              	VARCHAR2(30);
    	message           	VARCHAR2(128);
    	a1                	VARCHAR2(80);
    	a2                	VARCHAR2(30);
    	a3                	VARCHAR2(30);
    	a4                	VARCHAR2(30);
    	a5                	VARCHAR2(30);
    	a6                	VARCHAR2(30);
    	a7                	VARCHAR2(30);
    	a8                	VARCHAR2(30);
    	a9                	VARCHAR2(30);
    	a10               	VARCHAR2(30);
    	a11               	VARCHAR2(30);
    	a12               	VARCHAR2(30);
    	a13               	VARCHAR2(30);
    	a14               	VARCHAR2(30);
    	a15               	VARCHAR2(30);
    	a16               	VARCHAR2(30);
    	a17               	VARCHAR2(30);
    	a18               	VARCHAR2(30);
    	a19               	VARCHAR2(30);
    	a20               	VARCHAR2(30);
	return_msg1             VARCHAR2(2000);


        CURSOR Open_Interface is
              select sopldi.transaction_id,
    		     sopldi.picking_line_detail_id,

		     ----------------------------------------------------------------------
                     -- items to validate
		     ----------------------------------------------------------------------
    		     sopldi.inventory_item_id            item_id,
    		     sopldi.inventory_item               item_concat_segments,
    		     sopldi.warehouse_id                 warehouse_id,
    		     sopldi.serial_number                sn,
    		     sopldi.lot_number                   lot_number,
    		     sopldi.revision                     revision,
    		     sopldi.subinventory                 subinventory,
    		     sopldi.locator_id                   locator_id,
    		     sopldi.locator_name                 locator_concat_segments,
    		     sopldi.container_id                 container_id,
    		     sopldi.container_sequence           container_sequence,
    		     sopldi.attribute_category context,
    		     sopldi.attribute1,
    		     sopldi.attribute2,
    		     sopldi.attribute3,
    		     sopldi.attribute4,
    		     sopldi.attribute5,
    		     sopldi.attribute6,
    		     sopldi.attribute7,
    		     sopldi.attribute8,
    		     sopldi.attribute9,
    		     sopldi.attribute10,
    		     sopldi.attribute11,
    		     sopldi.attribute12,
    		     sopldi.attribute13,
    		     sopldi.attribute14,
    		     sopldi.attribute15,

		     ----------------------------------------------------------------------
    		     --  Inventory Item Segments
                     ----------------------------------------------------------------------
		     sopldi.item_segment1,
		     sopldi.item_segment2,
		     sopldi.item_segment3,
 		     sopldi.item_segment4,
		     sopldi.item_segment5,
		     sopldi.item_segment6,
		     sopldi.item_segment7,
		     sopldi.item_segment8,
		     sopldi.item_segment9,
		     sopldi.item_segment10,
		     sopldi.item_segment11,
		     sopldi.item_segment12,
		     sopldi.item_segment13,
		     sopldi.item_segment14,
		     sopldi.item_segment15,
		     ----------------------------------------------------------------------
    		     --  Location Segments
                     ----------------------------------------------------------------------
		     sopldi.loc_segment1,
		     sopldi.loc_segment2,
		     sopldi.loc_segment3,
 		     sopldi.loc_segment4,
		     sopldi.loc_segment5,
		     sopldi.loc_segment6,
		     sopldi.loc_segment7,
		     sopldi.loc_segment8,
		     sopldi.loc_segment9,
		     sopldi.loc_segment10,
		     sopldi.loc_segment11,
		     sopldi.loc_segment12,
		     sopldi.loc_segment13,
		     sopldi.loc_segment14,
		     sopldi.loc_segment15,

    		     sopldi.shipped_quantity            shipped_quantity,
    		     rowidtochar(sopldi.rowid)          row_id,

       		     ----------------------------------------------------------------------
    		     --  Valid items from so tables
                     ----------------------------------------------------------------------
    		     sopl.picking_header_id,
    		     sopl.picking_line_id,
    		     sopl.inventory_item_id		sopld_item_id,
    		     sopld.warehouse_id                 sopld_warehouse_id,
		     sopld.pick_slip_number,
    		     sopld.delivery_id                  sopld_delivery_id,
    		     sopld.serial_number		sopld_sn,
    		     sopld.lot_number			sopld_lot_number,
    		     sopld.revision			sopld_revision,
    		     sopld.subinventory   		sopld_subinventory,
    		     sopld.inventory_location_id	sopld_locator_id,
		     sopld.dpw_assigned_flag		sopld_dpw_assigned_flag,

    		     DECODE(X_Reservations,'Y',
    		     DECODE(sopld.reservable_flag,'Y','Y','N'),'N') RESERVATION_PLACED

    		     FROM so_picking_lines_all               	    SOPL,
    			  so_picking_line_details                   SOPLD,
    			  wsh_picking_details_interface             SOPLDI
    		     WHERE sopldi.transaction_id = X_transaction_id
    		       and sopldi.picking_line_detail_id = sopld.picking_line_detail_id
    		       and sopl.picking_line_id = sopld.picking_line_id
    		     ORDER BY sopl.inventory_item_id;


  BEGIN
   ------------------------------------------------------------------------------
   -- Get reservations profile
   ------------------------------------------------------------------------------
   fnd_profile.get( 'SO_RESERVATIONS', X_Reservations);
   wsh_del_oi_core.println('profile option SO_RESERVATIONS:'||X_Reservations );


   ------------------------------------------------------------------------------
   -- Define local variables
   ------------------------------------------------------------------------------
   last_item_id := -1 ;
   last_warehouse_id := -1 ;
   last_sub := 'a';
   processed_records := FALSE;

   wsh_del_oi_core.println('START OF PROCESS_SOPLD_INTERFACE' );

   ------------------------------------------------------------------------------
   -- Loop on interface records
   ------------------------------------------------------------------------------
   FOR oirec IN Open_Interface LOOP

       X_rowid           := oirec.row_id;
       processed_records := TRUE;

       wsh_del_oi_core.println('START OF LOOP oirec.sopld_subinventory: '||oirec.sopld_subinventory||
                               ' pld_id: '|| to_char(oirec.picking_line_detail_id) );

       ------------------------------------------------------------------------------
       --  VALIDATE WAREHOUSE
       -- Warehouse will never be null.
       ------------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating warehouse IDs: warehouse: '|| to_char(oirec.warehouse_id) ||
                               ' sopld_warehouse: '||to_char(oirec.sopld_warehouse_id) );
       wsh_del_oi_core.println(' ');
       error_line := 100;
       error_code := '0';

       wsh_oi_validate.not_equal(oirec.sopld_warehouse_id, oirec.warehouse_id, 'WAREHOUSE', error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 100 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       ------------------------------------------------------------------------------
       -- VALIDATE LINES WITH WAREHOUSE
       -- Ensure lines belong with this delivery's warehouse
       ------------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating lines belong with this delivery warehouse '||
                               ' x_warehouse: '|| to_char(x_warehouse_id)  );
       wsh_del_oi_core.println(' ');
       error_line := 110;
       error_code := '0';

       wsh_oi_validate.not_equal(oirec.sopld_warehouse_id, x_warehouse_id, 'WAREHOUSE', error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 110 ');
          wsh_del_oi_core.println(' ');
          error_code :=  'WSH_OI_LINES_NOT_IN_WHS';
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       ------------------------------------------------------------------------------
       -- VALIDATE INVENTORY ITEM
       ------------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating item id: '|| to_char(oirec.item_id) );
       wsh_del_oi_core.println(' ');
       error_line := 120;
       error_code := '0';

       seg_array(1) := oirec.item_segment1; seg_array(2) := oirec.item_segment2;
       seg_array(3) := oirec.item_segment3; seg_array(4) := oirec.item_segment4;
       seg_array(5) := oirec.item_segment5; seg_array(6) := oirec.item_segment6;
       seg_array(7) := oirec.item_segment7; seg_array(8) := oirec.item_segment8;
       seg_array(9) := oirec.item_segment9; seg_array(10) := oirec.item_segment10;
       seg_array(11) := oirec.item_segment11; seg_array(12) := oirec.item_segment12;
       seg_array(13) := oirec.item_segment13; seg_array(14) := oirec.item_segment14;
       seg_array(15) := oirec.item_segment15;

       wsh_oi_validate.inventory_item(oirec.item_id, oirec.item_concat_segments,
                                      oirec.warehouse_id, oirec.sopld_item_id,
                                      valid_item_id, seg_array, error_code);

       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 120 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       ------------------------------------------------------------------------------
       -- VALIDATE VARIABLES
       -- Validate reseting variables if org/item have changed
       ------------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating reseting variables if org/item changed ');
       wsh_del_oi_core.println(' ');
       error_line := 130;
       error_code := '0';
       wsh_oi_validate.changed_item_org(oirec.warehouse_id,
			                last_warehouse_id,
				        valid_item_id,
 					last_item_id,
				        X_subinv_restricted_flag,
    				        X_revision_control_flag,
    				        X_lot_control_flag,
    				        X_serial_number_control_flag,
				        error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 130 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       ------------------------------------------------------------------------------
       -- VALIDATE SHIPPED QUANTITIES
       -- Validate negative or decimal shipped quantities
       ------------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating negative or decimal shipped quantities: '||
                               to_char( oirec.shipped_quantity) );
       wsh_del_oi_core.println(' ');
       error_line := 140;
       error_code := '0';
       wsh_oi_validate.qty(oirec.shipped_quantity, error_code);

       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 140 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       ------------------------------------------------------------------------------
       -- set all valid-variables to null. These will store
       -- all validated input data and are used for the final update
       -- of Oracle Shipping tables.
       ------------------------------------------------------------------------------

       valid_warehouse_id := oirec.sopld_warehouse_id;
       valid_revision     := NULL;
       valid_sub          := NULL;
       valid_lot          := NULL;
       valid_loc          := NULL;

       ------------------------------------------------------------------------------
        -- if a reservation, ensure no interface controls, if input are the same
       ------------------------------------------------------------------------------

       if oirec.reservation_placed = 'Y' then

          --------------------------------------------------------------------------
          -- Validate if a reservation, ensure no interface controls, if input are
          -- the same if any inventory controls have changed from the reservation
          -- then raise error
          --------------------------------------------------------------------------
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validating if any inventory controls have changed');
          wsh_del_oi_core.println(' ');
          error_line := 150;
          error_code := '0';

          wsh_oi_validate.res_inv_ctrl_change(oirec.lot_number, oirec.sopld_lot_number,
	    				      oirec.revision, oirec.sopld_revision,
					      oirec.subinventory, oirec.sopld_subinventory,
					      oirec.locator_id, oirec.sopld_locator_id,
			                      error_code);
          if error_code <> '0' then
             wsh_del_oi_core.println(' ');
             wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 150 ');
             wsh_del_oi_core.println(' ');
             FND_MESSAGE.SET_NAME('OE', error_code);
             raise stop_pld_processing;
          end if;

          --------------------------------------------------------------------------

          valid_revision     := nvl(oirec.revision,oirec.sopld_revision);
          valid_sub          := nvl(oirec.subinventory,oirec.sopld_subinventory);
          valid_loc          := nvl(oirec.locator_id,oirec.sopld_locator_id);
          valid_lot          := nvl(oirec.lot_number,oirec.sopld_lot_number);

          -- Bug 916149: Loc Control flags should be set even if reservation
		-- is placed.  else check_serial_number routine would fail, if item
		-- is serial & locator controlled.    Get locator_control if
		-- item/org/sub have changed
	     if valid_warehouse_id <> last_warehouse_id
		   or valid_item_id      <> last_item_id
		   or valid_sub          <> last_sub
	    	then
		   WSH_DEL_OI_CORE.get_locator_controls
			 ( valid_warehouse_id,
			   valid_item_id,
			   valid_sub,
			   X_location_control_flag,
			   X_location_restricted_flag,
			   error_code);
		   if error_code <> '0' then
		      EXIT;
		   end if;
		   wsh_del_oi_core.println('Loc Ctrl:'||X_location_control_flag||
		          		  ' loc restricted:'||X_location_restricted_flag);
		end if;
		  -- Bug: 916149 (701829)

          wsh_del_oi_core.println('Reservation is set, Inv Controls set as Sub '||valid_sub||
                     ' revison='||valid_revision||' loc='||to_char(valid_loc)
                     ||' lot='||valid_lot);


         --------------------------------------------------------------------------
         -- else this is NOTa reservation, so  validate the interface controls
         -- if shipped quantity exists
         --------------------------------------------------------------------------

         elsif nvl(oirec.shipped_quantity,0) > 0  then

            --------------------------------------------------------------------------
    	    -- VALIDATE PLD SUBINVENTORY
    	    --------------------------------------------------------------------------
            wsh_del_oi_core.println(' ');
            wsh_del_oi_core.println('Validating Picking Line subinventory'||
                                    ' sub: '|| oirec.subinventory||
                                    ' warehouse:'||to_char(valid_warehouse_id)||
                                    ' restrict_flag:'||X_subinv_restricted_flag||
                                    ' item:'||to_char(valid_item_id)||
                                    ' valid_sub:'||valid_sub||
                                    ' default_sub:'||valid_sub);
            wsh_del_oi_core.println(' ');
            error_line := 160;
            error_code := '0';
            wsh_oi_validate.pld_subinventory(oirec.subinventory,
		 			     oirec.sopld_subinventory,
		 			     valid_warehouse_id,
    	 	            		     valid_item_id,
    	                    		     X_subinv_restricted_flag,
					     valid_sub,
					     default_sub,
				             error_code);
            if error_code <> '0' then
               wsh_del_oi_core.println(' ');
               wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 160 ');
               wsh_del_oi_core.println(' ');
               FND_MESSAGE.SET_NAME('OE', error_code);
               raise stop_pld_processing;
            end if;

            --------------------------------------------------------------------------
    	    -- VALIDATE PLD LOT NUMBER
    	    --------------------------------------------------------------------------
            wsh_del_oi_core.println(' ');
            wsh_del_oi_core.println('Validating Picking Line Lot Number'||
                                    ' valid_lot: '||valid_lot);
            wsh_del_oi_core.println(' ');
            error_line := 170;
            error_code := '0';
            wsh_oi_validate.pld_lot_number(oirec.lot_number,
		 		           X_lot_control_flag,
				           oirec.sopld_lot_number,
				           valid_warehouse_id,
				           valid_item_id,
				           valid_sub,
				           valid_lot,
				           error_code);
           if error_code <> '0' then
              wsh_del_oi_core.println(' ');
              wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 170 ');
              wsh_del_oi_core.println(' ');
              FND_MESSAGE.SET_NAME('OE', error_code);
              raise stop_pld_processing;
           end if;

           --------------------------------------------------------------------------
    	   -- VALIDATE PLD REVISION
    	   --------------------------------------------------------------------------
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Validating Picking Line Revision' ||
                                   ' revision:'|| valid_revision);
           wsh_del_oi_core.println(' ');
           error_line := 180;
           error_code := '0';
           wsh_oi_validate.pld_revision(oirec.revision,
				        oirec.sopld_revision,
				        valid_warehouse_id,
				        valid_item_id,
				        valid_revision,
				        x_revision_control_flag,
				        error_code);
           if error_code <> '0' then
              wsh_del_oi_core.println(' ');
              wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 180 ');
              wsh_del_oi_core.println(' ');
              FND_MESSAGE.SET_NAME('OE', error_code);
              raise stop_pld_processing;
           end if;


           --------------------------------------------------------------------------
    	   -- VALIDATE PLD ITEM LOCATION
    	   --------------------------------------------------------------------------
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Validating Picking Line Item Loc'||
                                   ' loc_control_flag: '||X_location_control_flag||
                                   ' valid_loc:'||valid_loc);
           wsh_del_oi_core.println(' ');
           error_line := 190;
           error_code := '0';
           wsh_oi_validate.pld_item_location(valid_warehouse_id,
		   		             last_warehouse_id,
					     valid_item_id,
					     last_item_id,
					     valid_sub,
					     last_sub,
					     X_location_control_flag,
					     X_location_restricted_flag,
					     valid_loc,
					     error_code);


           if error_code <> '0' then
              wsh_del_oi_core.println(' ');
              wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 190 ');
              wsh_del_oi_core.println(' ');
              FND_MESSAGE.SET_NAME('OE', error_code);
              raise stop_pld_processing;
           end if;

           --------------------------------------------------------------------------
    	   -- VALIDATE PLD LOCATOR
    	   --------------------------------------------------------------------------
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Validating Picking Line Locator');
           wsh_del_oi_core.println(' ');
           error_line := 200;
           error_code := '0';

           seg_array(1) := oirec.loc_segment1; seg_array(2) := oirec.loc_segment2;
    	   seg_array(3) := oirec.loc_segment3; seg_array(4) := oirec.loc_segment4;
    	   seg_array(5) := oirec.loc_segment5; seg_array(6) := oirec.loc_segment6;
    	   seg_array(7) := oirec.loc_segment7; seg_array(8) := oirec.loc_segment8;
    	   seg_array(9) := oirec.loc_segment9; seg_array(10) := oirec.loc_segment10;
    	   seg_array(11) := oirec.loc_segment11; seg_array(12) := oirec.loc_segment12;
    	   seg_array(13) := oirec.loc_segment13; seg_array(14) := oirec.loc_segment14;
    	   seg_array(15) := oirec.loc_segment15;

           dbms_output.enable(1000000);
           wsh_oi_validate.pld_locator(oirec.locator_id,
				       oirec.sopld_locator_id,
				       valid_loc,
				       default_loc,
				       oirec.locator_concat_segments,
				       X_location_control_flag,
				       valid_warehouse_id,
				       valid_item_id,
                                       valid_sub,
				       X_location_restricted_flag,
				       valid_flag,
				       seg_array,
				       error_code);

           if error_code <> '0' then
              wsh_del_oi_core.println(' ');
              wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 200 ');
              wsh_del_oi_core.println(' ');
              FND_MESSAGE.SET_NAME('OE', error_code);
              raise stop_pld_processing;
           end if;
    	   -------------------------------------------------------------------------


       end if; -- ending reservation_placed else statement


       --------------------------------------------------------------------------
       -- VALIDATE PLD SERIAL NUMBER
       -- If present irrespective of reservations
       --------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating Picking Line Serial Numbers:'||oirec.sn);
       wsh_del_oi_core.println(' ');
       error_line := 210;
       error_code := '0';
       wsh_oi_validate.pld_serial_number(oirec.sn,
				         X_serial_number_control_flag,
				         oirec.shipped_quantity,
				         valid_warehouse_id,
				         valid_item_id,
				         valid_sub,
            			         valid_revision,
				         valid_lot,
				         valid_loc,
				         X_location_restricted_flag,
				         X_location_control_flag,
				         oirec.row_id,
				         oirec.picking_line_id,
                            	         oirec.picking_line_detail_id,
			    	         error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 210 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;

       --------------------------------------------------------------------------
       -- VALIDATE PLD CONTAINER
       --------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating Picking Line Container:'|| to_char(oirec.container_id)||
                               ' seq:'||to_char(oirec.container_sequence) );
       wsh_del_oi_core.println(' ');
       error_line := 220;
       error_code := '0';

       wsh_oi_validate.container(oirec.container_id,
				 oirec.container_sequence,
				 x_delivery_id,
				 x_container_id,
				 error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 220 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       --------------------------------------------------------------------------
       --  VALIDATE PLD LINE ADDITION
       --------------------------------------------------------------------------
       wsh_del_oi_core.println(' ');
       wsh_del_oi_core.println('Validating Picking Line Addition of Line');
       wsh_del_oi_core.println(' ');
       error_line := 230;
       error_code := '0';
       wsh_oi_validate.pld_line_add(x_delivery_id,
			            oirec.sopld_delivery_id,
				    del_status,
				    result,
				    result_num,
				    oirec.picking_line_detail_id,
				    token_name,
				    error_code);
       if error_code <> '0' then
          wsh_del_oi_core.println(' ');
          wsh_del_oi_core.println('Validation Error in PROCESS_SOPLD_INTERFACE Error Line = 230 ');
          wsh_del_oi_core.println(' ');
          FND_MESSAGE.SET_NAME('OE', error_code);
          raise stop_pld_processing;
       end if;


       --------------------------------------------------------------------------
       -- At this point we have validated the data and want to update SOPLD.
       -- Update the picking_line_detail_id directly and check it has the same inventory
       -- controls. If it doesnt then call split_SOPLD_row to handle the update.
       --------------------------------------------------------------------------

            SELECT picking_line_detail_id, shipped_quantity, requested_quantity, delivery_id, container_id
            INTO pl_pld_id, pl_shp_qty, pl_req_qty, pl_del, pl_cont
            FROM SO_PICKING_LINE_DETAILS
            WHERE picking_line_detail_id = oirec.picking_line_detail_id;

            wsh_del_oi_core.println('-----After selection from pld');

--            if oirec.picking_line_detail_id = pl_pld_id then
            if ((oirec.shipped_quantity + NVL(pl_shp_qty, 0)) > pl_req_qty) then
	          error_code := '1';
	          wsh_del_oi_core.println('Shipped Quantity > Requested Quantity');
                  raise stop_pld_processing;
            elsif oirec.shipped_quantity = pl_req_qty then
                  wsh_del_oi_core.println('Going to update_line label');
		  goto update_line;
	    else -- Split Lines
                wsh_del_oi_core.println('Going for split_line');
                if x_backorder_flag = false   then
                     wsh_del_oi_core.println('BACKORDER FLAG is FALSE.Going for split of:'||
					     ' pld:'|| to_char(oirec.picking_line_detail_id));
                     WSH_SC_TRX_INTERFACE.split_sopld_row
               		     (oirec.picking_line_id,
              		      oirec.picking_line_detail_id,
			      oirec.pick_slip_number,
                              new_pld_id,
         		      oirec.shipped_quantity,
	 		      valid_warehouse_id,
	 		      oirec.sn,
         		      valid_lot,
         		      valid_revision,
         		      valid_sub,
         		      valid_loc,
         		      x_departure_id,
         		      x_delivery_id,
         		      x_container_id,
                              x_backorder_flag,
         		      oirec.context,
         		      oirec.attribute1,  oirec.attribute2,  oirec.attribute3,  oirec.attribute4,
         		      oirec.attribute5,  oirec.attribute6,  oirec.attribute7,  oirec.attribute8,
              		      oirec.attribute9,  oirec.attribute10, oirec.attribute11, oirec.attribute12,
         		      oirec.attribute13, oirec.attribute14, oirec.attribute15,
         		      error_code);

		     if error_code = '0' and x_reservations = 'Y' then
          	        -- Reservations transfer

		        COMMIT;

		        wsh_del_oi_core.println('Calling Reservations transfer 1');
	     	        ret_val := Fnd_Transaction.synchronous( 1000,
                                        outcome,
                                        message,
                                        'OE',
                                        'WSHURTF',
                                        TO_CHAR(oirec.picking_line_detail_id),
                                        TO_CHAR(new_pld_id),
				        TO_CHAR(oirec.shipped_quantity),
				        TO_CHAR(x_delivery_id));
      	     	        if (ret_val = 2) then
	                      error_code := 'SHP_ONLINE_NO_MANAGER';
		              FND_MESSAGE.SET_NAME('OE', error_code);
                              RAISE online_no_manager;
             	        elsif (ret_val <> 0) then
	                      error_code := 'SHP_AOL_ONLINE_FAILED';
			      FND_MESSAGE.SET_NAME('OE', error_code);
                	      RAISE online_error;
             	         else
                	      if (message = 'FAILURE') then
                   	         error_code := 'WSH_SC_CANNOT_TRANSFER_PLD';
			         FND_MESSAGE.SET_NAME('OE', error_code);
		   	         RAISE cannot_transfer;
                	      end if;
             	        end if;
                     else
		        wsh_del_oi_core.println('CALLING goto_end_processing');
		        goto end_processing;
		     end if; -- Reservations transfer

--   After reservation transfer the departure & Delivery_id dpw_assigned_flag
--   and the serial_number in the new pld is NULLED,

	        BEGIN
                    wsh_del_oi_core.println('Into reseting pld after reservation split. pld:'||
                                               to_char(new_pld_id) );
	            UPDATE SO_PICKING_LINE_DETAILS SET
      	            DELIVERY_ID = nvl(DELIVERY_ID,x_delivery_id),
      	            DEPARTURE_ID = nvl(DEPARTURE_ID,x_departure_id),
	            SERIAL_NUMBER = nvl(SERIAL_NUMBER,oirec.sn),
		    SHIPPED_QUANTITY = NVL(SHIPPED_QUANTITY,0) + oirec.shipped_quantity,
	            DPW_ASSIGNED_FLAG = NULL,
	            CONTAINER_ID = nvl(CONTAINER_ID,x_container_id),
	            WAREHOUSE_ID = nvl(WAREHOUSE_ID,valid_warehouse_id),
	            LAST_UPDATE_DATE = sysdate,
	            LAST_UPDATED_BY = fnd_global.user_id,
	            LAST_UPDATE_LOGIN = fnd_global.user_id
	            WHERE PICKING_LINE_DETAIL_ID = new_pld_id;

                    if sql%notfound then
                       wsh_del_oi_core.println('Could not find record in PLD. pld:'||
                                               to_char(new_pld_id) );
                       error_code := '1';
                       FND_MESSAGE.SET_NAME('OE' , error_code);
                       raise stop_pld_processing;
                    end if;

                    EXCEPTION when others then
                      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
                      FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.update_sopld1');
                      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
                      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
                      APP_EXCEPTION.Raise_Exception;
                END;

--		   oirec.picking_line_detail_id := new_pld_id;
--     		   oirec.shipped_quantity := pl_shp_qty;
--		   oirec.sopld_dpw_assigned_flag := NULL;

		goto end_processing;

                end if; -- a_backorder_flag = FALSE

           end if; -- oirec.shipped_quantity + pl_shp_qty  > pl_req_qty


       <<update_line>>

       wsh_del_oi_core.println('Into the Update_line label.');
       wsh_del_oi_core.println('Going for update of pld:'||
			       to_char(oirec.picking_line_detail_id) );

--  Control will reach here ONLY in case of backorder_flag=TRUE
--  this update will fail only if the inventory controls are different & the
--  pld splitting will take place by the next call.

       WSH_SC_TRX_INTERFACE.update_sopld_row
           (oirec.picking_line_id,
            oirec.picking_line_detail_id,
            0,
            oirec.shipped_quantity,
	    valid_warehouse_id,
	    oirec.sn,
            valid_lot,
            valid_revision,
            valid_sub,
            valid_loc,
            x_departure_id,
            x_delivery_id,
            x_container_id,
            oirec.context,
 	    oirec.sopld_dpw_assigned_flag,
            oirec.attribute1,  oirec.attribute2,  oirec.attribute3,  oirec.attribute4,
            oirec.attribute5,  oirec.attribute6,  oirec.attribute7,  oirec.attribute8,
            oirec.attribute9,  oirec.attribute10, oirec.attribute11, oirec.attribute12,
            oirec.attribute13, oirec.attribute14, oirec.attribute15,
            error_code);


       --------------------------------------------------------------------------
       -- will return 1 when we werent successful with the insert because the line
       -- already exists with different inventory controls so we must split the line
       --------------------------------------------------------------------------
       if error_code = '1' then
          --------------------------------------------------------------------------
          -- dont permit zero quantity when something already exists because
          -- we're probably trying to reset it to zero
          --------------------------------------------------------------------------
          if nvl(oirec.shipped_quantity,0) = 0 then
             error_code := 'WSH_OI_USE_FORM';
             wsh_del_oi_core.println('Shipped qty equal to ZERO.');
             EXIT;
          end if;

          wsh_del_oi_core.println(substr(('Could not update SOPLD using detail_id:: splitting  row '||
          to_char(oirec.picking_line_id)||','||to_char(oirec.picking_line_detail_id)||','||
          to_char(valid_warehouse_id)||','||
          valid_lot||','||valid_revision||','||
          valid_sub||','||valid_loc),1,2000));

          WSH_SC_TRX_INTERFACE.split_sopld_row
               (oirec.picking_line_id,
              	oirec.picking_line_detail_id,
		oirec.pick_slip_number,
  		new_pld_id,
         	oirec.shipped_quantity,
	 	valid_warehouse_id,
	 	oirec.sn,
         	valid_lot,
         	valid_revision,
         	valid_sub,
         	valid_loc,
         	x_departure_id,
         	x_delivery_id,
         	x_container_id,
                x_backorder_flag,
         	oirec.context,
         	oirec.attribute1,  oirec.attribute2,  oirec.attribute3,  oirec.attribute4,
         	oirec.attribute5,  oirec.attribute6,  oirec.attribute7,  oirec.attribute8,
         	oirec.attribute9,  oirec.attribute10, oirec.attribute11, oirec.attribute12,
         	oirec.attribute13, oirec.attribute14, oirec.attribute15,
         	error_code);

       end if;  -- if error_code = 1

       <<end_processing>>

       error_code := '0';

       DELETE from wsh_picking_details_interface
       WHERE picking_line_detail_id = oirec.picking_line_detail_id and rowid = oirec.row_id;

       COMMIT;

       --------------------------------------------------------------------------
       -- update last_variables
       --------------------------------------------------------------------------
       last_item_id         :=  valid_item_id;
       last_warehouse_id    :=  oirec.warehouse_id;
       -- remember valid_sub <>  oirec.subinventory when default sub is used
       last_sub             :=  valid_sub;
       x_picking_header_id  :=  oirec.picking_header_id;

     end loop;

     --------------------------------------------------------------------------
     -- PS based prossing did extra stuff here but in DEL we do it at PACK time
     --------------------------------------------------------------------------
     EXCEPTION

	 WHEN stop_pld_processing then
	 wsh_del_oi_core.println('PLD Process EXCEPTION stop_pld_processing');
         x_error_code := error_code;
         -- at this point error_code should be set and an error is on the stack
         -- it will be handled by the calling program.
         null;

        WHEN online_no_manager THEN
	  wsh_del_oi_core.println('PLD Process EXCEPTION online_no_manager');
      	  --FND_MESSAGE.SET_NAME('OE','SHP_ONLINE_NO_MANAGER');
      	  x_error_code := error_code;

        WHEN online_error THEN
          wsh_del_oi_core.println('PLD Process EXCEPTION online_error');
      	  --FND_MESSAGE.SET_NAME('OE','SHP_ONLINE_NO_MANAGER');
          --FND_MESSAGE.SET_NAME('OE','SHP_AOL_ONLINE_FAILED');
          --FND_MESSAGE.SET_TOKEN('PROGRAM', 'WSHURTF');
          x_error_code := error_code;

        WHEN cannot_transfer THEN
          wsh_del_oi_core.println('PLD Process EXCEPTION cannot_transfer');
          ret_val := Fnd_Transaction.get_values( a1, a2, a3, a4, a5, a6,
                               a7, a8, a9, a10, a11, a12, a13, a14,
                               a15, a16, a17, a18, a19, a20);
          --FND_MESSAGE.Set_Name('OE','WSH_SC_CANNOT_TRANSFER_PLD');
          --FND_MESSAGE.Set_Token('PLD_ID', TO_CHAR(new_pld_id));
          --FND_MESSAGE.Set_Token('REASON', a1);
          x_error_code := error_code;

        WHEN others then
		 return_msg1 := FND_MESSAGE.get;
		 wsh_del_oi_core.println('msg ='|| return_msg1);
           x_error_code := 'OE_QUERY_ERROR';
	   FND_MESSAGE.SET_NAME('OE', x_error_code);
           wsh_del_oi_core.println('PLD Process EXCEPTION others ');
           --FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
           --FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.process_sopld_interface');
           --FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
           --FND_MESSAGE.Set_Token('ORA_TEXT','Insert statement');
           --APP_EXCEPTION.Raise_Exception;
     END;

  END PROCESS_PICKING_DETAILS_INTER;






--------------------------------------------------------------------------
-- Name : PRCOCESS_FREIGHT_CHARGES_INTER
-- Arguments:
--   x_transaction_id    interface transaction_id
--   x_delivery_id       the delivery we are processing
--   x_del_currency      the currency code for DELIVERY CURRENCY
--   x_rowid             rowid of the last fc processed.
--                       an error will terminate processing of fc
--                       so this rowid indicates the record in error.
--   error_code          any error code
-- Notes
-- inserts all freight charges for a given transaction.
-- called from WSH_SC_TRX_INTERFACE.Process_Interface_Data
-- once for each transaction to process
-- This can be called any time prior to AR Interface
--------------------------------------------------------------------------


  PROCEDURE PROCESS_FREIGHT_CHARGES_INTER(X_transaction_id     in number,
                                   	  X_delivery_id        in number,
                                   	  X_del_currency       in out varchar2,
                                   	  X_rowid              out char,
                                   	  x_error_code         in out varchar2) is
  BEGIN
     DECLARE

        cursor Freight_Charge_Cursor is
        select creation_date,
	   created_by,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   freight_charge_type_id,
	   freight_charge_type_desc,
	   amount,
	   currency_code,
	   currency_name,
           decode(delivery_flag,NULL,NULL,x_delivery_id) delivery_id,
           container_id, container_sequence,
	   order_header_id,
           picking_line_detail_id,
           attribute_category,
	   attribute1,	attribute2,  attribute3,  attribute4,  attribute5,
	   attribute6,	attribute7,  attribute8,  attribute9,  attribute10,
	   attribute11,	attribute12, attribute13, attribute14, attribute15,
           ac_attribute_category,
	   ac_attribute1, ac_attribute2, ac_attribute3, ac_attribute4, ac_attribute5,
	   ac_attribute6, ac_attribute7, ac_attribute8, ac_attribute9, ac_attribute10,
	   ac_attribute11,ac_attribute12,ac_attribute13,ac_attribute14,ac_attribute15,
           rowidtochar(rowid) char_rowid
    from   wsh_freight_charges_interface sfci
    where  transaction_id = X_transaction_id;

    fcrec Freight_Charge_Cursor%rowtype;
    first_time boolean := TRUE;
    stop_fc_processing  EXCEPTION;

    x_sysdate        date;
    x_created_by     number;
    x_login          number;
    x_type_id        number;
    x_container_id   number;
    x_order_header_id number;
    x_picking_header_id number;
    valid_cur_code   varchar2(15);
    valid_cur_name   varchar2(50);
    default_delivery_charge_id  number;
    delivery_charge_id number;
    error_code 	varchar(70);
    return_msg1     varchar(2000);

   BEGIN

     error_code      := '0';
     X_sysdate       := sysdate;
     X_Created_By    := FND_GLOBAL.USER_ID;
     X_login         := FND_GLOBAL.LOGIN_ID;
     valid_cur_code  := null;

     OPEN  Freight_Charge_Cursor ;

     LOOP

        wsh_del_oi_core.println(' ');
        wsh_del_oi_core.println('Fetching a record from Freight Charge Interface table');
        wsh_del_oi_core.println(' ');

        fetch Freight_Charge_cursor into fcrec;

    	exit when Freight_Charge_Cursor%notfound;

    	--------------------------------------------------------------------------------------
    	-- Assign rowid: this will identify the rec if an error occurs
    	--------------------------------------------------------------------------------------

    	x_rowid := fcrec.char_rowid;

    	--------------------------------------------------------------------------------------
    	-- Validate if the delivery under consideration is already AR Interfaced
    	-- This basically finds out, if there are any Picking Lines, that have the AR interface
    	-- status set to Not Null and have the AR Interfaced Flag ( s5 )  set to either 5 =
    	-- A/R Interfaced Partial, 8 = A/R Interfaced Not Applicable or 9 = A/R Interfaced.
    	--------------------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating if the Delivery is already A/R Interfaced');
    	wsh_del_oi_core.println(' ');
    	error_code := '0';
    	if first_time then
       	   wsh_oi_validate.if_ar_intfaced(x_delivery_id, error_code );

           if error_code <> '0' then
              wsh_del_oi_core.println(' ');
              wsh_del_oi_core.println('This Delivery is already A/R Interfaced');
              wsh_del_oi_core.println(' ');
              FND_MESSAGE.set_name('OE', error_code);
              raise stop_fc_processing;
           end if;
           first_time := FALSE;
        end if;


    	--------------------------------------------------------------------------------------
    	-- Validate the freight charge type id and desc , if either one or both of them are
    	-- specified
    	--------------------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating Freight Charge Type');
    	wsh_del_oi_core.println(' ');
    	error_code := '0';
    	wsh_oi_validate.freight_charge_type(fcrec.freight_charge_type_id ,
                                            fcrec.freight_charge_type_desc ,
                                            x_type_id ,  -- Return valid Freight Charge Type ID
                                            error_code );

    	if (error_code <> '0' ) then
       	   wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Invalid Freight Charge');
           wsh_del_oi_core.println(' ');
           FND_MESSAGE.set_name('OE', error_code);
           raise stop_fc_processing;
        end if;

    	----------------------------------------------------------------------------
    	-- Validate the currency code, when at least the currency code or name, have
    	-- to be specified
    	----------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating Freight Charge Currency');
    	wsh_del_oi_core.println(' ');
    	error_code := '0' ;
    	wsh_oi_validate.frt_currency_code(fcrec.currency_code ,
                                          fcrec.currency_name ,
                                          fcrec.amount,
                                          valid_cur_code, -- Return valid Currency Code
                                          valid_cur_name,
                                          error_code );

    	if error_code <> '0' then
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Invalid Freight Charge Currency');
           wsh_del_oi_core.println(' ');
           -- message already on the error stack
           raise stop_fc_processing;
        end if;

    	----------------------------------------------------------------------------
    	-- Validate if the Freight Charge Currency is the same as the Delivery
    	-- Currency
    	----------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating if Delivery Currency is same as Freight Charge Currency');
    	wsh_del_oi_core.println(' ');
    	error_code := '0';

    	if nvl(valid_cur_code,'') <> nvl(x_del_currency,'') then
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Delivery Currency is not the same as Freight Charge Currency');
           wsh_del_oi_core.println(' ');
           fnd_message.set_name('OE','WSH_OI_CURRENCY_NOT_SAME'); -- Error Message Not Defined
           raise stop_fc_processing;
        end if;


    	----------------------------------------------------------------------------------
    	-- Validate the container when either the container_id or sequence_number or both
    	-- have been specified. If the container_id is specified, then it takes precedence
    	-- and if not found in WSH_PACKED_CONTAINERS, then it is a validation error. If
    	-- only the sequence_number of the container has been specified, and it does not
    	-- exist in WSH_PACKED_CONTAINERS table, then it is a validation error as well.
    	----------------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating Freight Charge Container');
    	wsh_del_oi_core.println(' ');
    	error_code := '0' ;
    	x_container_id := NULL ;

    	wsh_oi_validate.container(fcrec.container_id,
                                  fcrec.container_sequence,
                                  x_delivery_id,
                                  x_container_id,
                                  error_code);

    	if error_code <> '0' then
       	   wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Invalid Freight Charge Container');
           wsh_del_oi_core.println(' ');
           fnd_message.set_name('OE',error_code);
           raise stop_fc_processing;
        end if;

    	----------------------------------------------------------------------------------
    	-- Validate if the Freight Charge Amount is Negative or Zero
    	----------------------------------------------------------------------------------

    	wsh_del_oi_core.println(' ');
    	wsh_del_oi_core.println('Validating Freight Charge Amount');
    	wsh_del_oi_core.println(' ');
    	error_code := '0' ;
    	wsh_oi_validate.qty(fcrec.amount, error_code );

    	if error_code <> '0' then
           wsh_del_oi_core.println(' ');
           wsh_del_oi_core.println('Invalid Freight Charge Amount. Either Negative or Zero');
           wsh_del_oi_core.println(' ');
           fnd_message.set_name('OE',error_code);
           raise stop_fc_processing;
        end if;

   	--------------------------------------------------------------------------------
   	-- Validate for Duplicate AETCs, this is a check specifically for Automotive
   	--------------------------------------------------------------------------------

   	wsh_del_oi_core.println(' ');
   	wsh_del_oi_core.println('Validating if this Delivery has a Duplicate AETC');
   	wsh_del_oi_core.println(' ');
   	error_code := '0' ;
   	wsh_oi_validate.duplicate_aetc(fcrec.ac_attribute_category ,
                                       x_delivery_id, error_code );

  	if error_code <> '0' then
       	    wsh_del_oi_core.println(' ');
       	    wsh_del_oi_core.println('This Delivery has a Duplicate AETC');
            wsh_del_oi_core.println(' ');
            fnd_message.set_name('OE',error_code);
            raise stop_fc_processing;
      	end if;

	--------------------------------------------------------------------------------
   	-- Populate order header ID
   	--------------------------------------------------------------------------------
	x_order_header_id := fcrec.order_header_id;

	if x_order_header_id is NOT NULL then
	   select max(ph.picking_header_id) into x_picking_header_id
	   from so_picking_line_details pld,
	        so_picking_lines_all pl,
	        so_picking_headers_all ph,
	        so_headers_all h
           where pld.delivery_id = x_delivery_id
             and pld.picking_line_id = pl.picking_line_id
             and pl.picking_header_id + 0 > 0
	     and pl.picking_header_id = ph.picking_header_id
             and ph.order_header_id = h.header_id
	     and h.header_id = x_order_header_id;

	   if SQL%NOTFOUND then
	     -- fail transaction
	     wsh_del_oi_core.println(' ');
       	     wsh_del_oi_core.println('Process failed while selecting order header id');
             wsh_del_oi_core.println(' ');
             fnd_message.set_name('OE',error_code);
             raise stop_fc_processing;
	   end if;
	end if;

   	--------------------------------------------------------------------------------
	wsh_del_oi_core.println(' ');
   	wsh_del_oi_core.println('Creating a new Freight Charges record');
   	wsh_del_oi_core.println(' ');
	--------------------------------------------------------------------------------

   	begin
	   INSERT INTO SO_FREIGHT_CHARGES(
	     picking_header_id,
	     freight_charge_id,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             freight_charge_type_id,
             amount,
             currency_code,
             delivery_id,
             container_id,
             picking_line_detail_id,
             interco_invoice_status,
             context,
             attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
	     attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
	     attribute11, attribute12, attribute13, attribute14, attribute15,
             ac_attribute_category,
	     ac_attribute1, ac_attribute2, ac_attribute3, ac_attribute4, ac_attribute5,
	     ac_attribute6, ac_attribute7, ac_attribute8, ac_attribute9, ac_attribute10,
	     ac_attribute11,ac_attribute12,ac_attribute13,ac_attribute14,ac_attribute15
             ) VALUES (
	      x_picking_header_id,
	      so_freight_charges_s.nextval,
              sysdate,
              x_Created_By,
              sysdate,
              x_Created_By,
              x_login,
              x_Type_Id,
              nvl(fcrec.amount,0) ,
              valid_cur_code,
              x_delivery_id,
              x_container_id,
              fcrec.picking_line_detail_id,
              'NOT INVOICED',
              fcrec.attribute_category,
	      fcrec.attribute1,	      fcrec.attribute2,	      fcrec.attribute3,
	      fcrec.attribute4,	      fcrec.attribute5,	      fcrec.attribute6,
	      fcrec.attribute7,	      fcrec.attribute8,	      fcrec.attribute9,
	      fcrec.attribute10,      fcrec.attribute11,      fcrec.attribute12,
	      fcrec.attribute13,      fcrec.attribute14,      fcrec.attribute15,
              fcrec.ac_attribute_category,
	      fcrec.ac_attribute1, fcrec.ac_attribute2, fcrec.ac_attribute3,
	      fcrec.ac_attribute4, fcrec.ac_attribute5, fcrec.ac_attribute6,
	      fcrec.ac_attribute7, fcrec.ac_attribute8, fcrec.ac_attribute9,
	      fcrec.ac_attribute10,fcrec.ac_attribute11,fcrec.ac_attribute12,
	      fcrec.ac_attribute13,fcrec.ac_attribute14,fcrec.ac_attribute15);

       EXCEPTION
	  when others then
	     FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	     FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.insert_freight_charges statement');
	     FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
             FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	     APP_EXCEPTION.Raise_Exception;
             EXIT;

       	  if ( sql%found ) then
             wsh_del_oi_core.println(' ');
             wsh_del_oi_core.println('Freight Charge record created successfully');
             wsh_del_oi_core.println(' ');
          end if ;

      end;

      DELETE from wsh_freight_charges_interface
      WHERE  freight_charge_type_id = fcrec.freight_charge_type_id and rowid = fcrec.char_rowid;

      wsh_del_oi_core.println('DELETED freight_charge_type_id = '||to_char(fcrec.freight_charge_type_id));

      COMMIT;

     END LOOP;

  EXCEPTION

     when stop_fc_processing then
     --------------------------------------------------------------------------
     -- at this point error_code should be set and an error is on the stack
     -- it will be handled by the calling program.
     --------------------------------------------------------------------------
     x_error_code := error_code;
     null;

     when others then
	   return_msg1 := FND_MESSAGE.get;
	   wsh_del_oi_core.println('msg ='|| return_msg1);
        FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
        FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_TRX_INTERFACE.insert_freight_charges');
        FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT','Insert statement');
        APP_EXCEPTION.Raise_Exception;

     end;

    --x_error_code := error_code;

  END PROCESS_FREIGHT_CHARGES_INTER;



end WSH_SC_TRX_INTERFACE;

/
