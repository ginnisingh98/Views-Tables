--------------------------------------------------------
--  DDL for Package Body WSH_SC_DELIVERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_DELIVERY_PVT" as
/* $Header: WSHSDELB.pls 115.7 99/10/18 18:46:56 porting ship $ */

--      Function Name   :       Close_Delivery

--      Purpose         :
--      To process Ship_all and Ship_entered actions on a Delivery

--      Parameters      :
--      1. Del_Id         IN NUMBER
--         - delivery id we are working with
--	2. Action_Code  IN 	VARCHAR2
--	   -ALL for Ship All
--	   -ENTERED for Ship Entered

--      Return Value    :       BOOLEAN
--
FUNCTION Close_Delivery(Del_Id          	IN      NUMBER,
			Action_Code		IN	VARCHAR2,
			default_fcc		IN 	VARCHAR2,
			default_bol		IN	VARCHAR2,
			p_vehicle_item_id       IN      NUMBER DEFAULT NULL,
			p_vehicle_number        IN      VARCHAR2 DEFAULT NULL,
			p_seal_code             IN      VARCHAR2 DEFAULT NULL,
			p_volume_uom            IN      VARCHAR2 DEFAULT NULL,
			p_volume_total          IN      NUMBER DEFAULT NULL,
			p_weight_uom            IN      VARCHAR2 DEFAULT NULL,
			p_gross_wt              IN      NUMBER DEFAULT NULL,
			p_tare_wt               IN      NUMBER DEFAULT NULL,
			p_pack_instr            IN      VARCHAR2 DEFAULT NULL,
			default_actual_date	IN 	DATE DEFAULT SYSDATE)
RETURN BOOLEAN IS

--go ahead and declare some local variables to be used in the function

dep_id			NUMBER;
org_id			NUMBER;
freight_carrier		VARCHAR2(30);
dep_freight_carrier	VARCHAR2(30);
weight_uom		VARCHAR2(3);
volume_uom		VARCHAR2(3);
weight_of_delivery	NUMBER;
volume_of_delivery	NUMBER;
trans_temp_id		NUMBER;
x_waybill		VARCHAR2(30);
X_net_weight            NUMBER;
X_tare_weight           NUMBER;
X_volume                NUMBER;
X_status                NUMBER;
weight_volume_sc_flag   VARCHAR2(1);
close_date		DATE;
auto_created_dep	BOOLEAN		:=FALSE;
industry 		VARCHAR2(30);
status   		VARCHAR2(30);
return_msg1        VARCHAR2(2000);
BEGIN

  -- If we have delivery lines that are not assicated with this delivery
  -- associated with picking headers or picking lines that we are working
  -- with then we need to first split these picking headers and picking lines
  -- to kinda get rid of these delivery lines.
  -- So go ahead and call the routine which splits the picking headers
  -- and picking lines, if necessary

  Split_Picking_Headers (del_id);


  -- If a serial number range has been entered for the shipped quantity of the
  -- item, then we need to explode the picking line details.
  -- wsh_sc_pld_pkg (WShSCPDB.pls) is our guy to do this. He takes care
  -- of exploding only those lines that need to be.

  WSH_SC_PLD_PKG.Close_Details(del_id);

  -- We are now ready to update the delivery status to closed
  select sysdate into close_date from sys.dual;
  UPDATE wsh_deliveries
  SET status_code = 'CL',
      date_closed = close_date
  WHERE delivery_id = del_id;

  -- if this delivery has not been associated with a departure yet
  -- then we need to do an 'auto create departure' ie create a
  -- departure for this delivery to be able to actually 'depart' !
  -- so call Auto_Create_Departure

  -- first check if we need to do it
  SELECT actual_departure_id
	 ,organization_id
	 ,freight_carrier_code
	 ,weight_uom_code
	 ,volume_uom_code
	 ,gross_weight
	 ,volume
	 ,waybill
  INTO  dep_id
	,org_id
	,freight_carrier
	,weight_uom
	,volume_uom
	,weight_of_delivery
	,volume_of_delivery
	,x_waybill
  FROM wsh_deliveries
  WHERE delivery_id = del_id;
   -- if freight carrier at the delivery is null, update it from the departure
  IF freight_carrier IS NULL and dep_id IS NOT NULL THEN
    SELECT freight_carrier_code
      INTO dep_freight_carrier
      FROM wsh_departures
     WHERE departure_id = dep_id;

    UPDATE wsh_deliveries
    SET freight_carrier_code = dep_freight_carrier
    WHERE delivery_id = del_id;
  END IF;

  IF dep_id is NULL THEN

    dep_id := Auto_Create_Departure (	org_id,
					NVL( default_fcc, freight_carrier),
					NVL( p_weight_uom, weight_uom),
					NVL( p_volume_uom, volume_uom),
					NVL( p_gross_wt, weight_of_delivery),
					p_tare_wt,
					NVL( p_volume_total, volume_of_delivery),
					p_vehicle_item_id,
					p_vehicle_number,
					p_seal_code,
					p_pack_instr,
					default_bol,
					default_actual_date  );

    -- now update the actual departure id on this delivery with the new departure created
    -- and the departure id on the delivery lines. Also call the ASN API for ASN integration

    IF dep_id > 0 THEN

      UPDATE wsh_deliveries
      SET actual_departure_id = dep_id,
      freight_carrier_code = NVL(default_fcc, freight_carrier)
      WHERE delivery_id = del_id;

      auto_created_dep := TRUE;
      WSH_PARAMETERS_PVT.get_param_value(org_id, 'WEIGHT_VOLUME_SC_FLAG',
                                        weight_volume_sc_flag);
      if (weight_volume_sc_flag = 'A') then
        wsh_wv_pvt.departure_weight_volume(
        source            => 'SC',
        departure_id      => dep_id,
        organization_id   => org_id,
        wv_flag           => 'ALWAYS',
        update_flag       => 'Y',
        menu_flag         => 'N',
        dpw_pack_flag     => 'N',
        master_weight_uom => weight_uom,
        net_weight        => X_net_weight,
        tare_weight       => X_tare_weight,
        master_volume_uom => volume_uom,
        volume            => X_volume,
        status            => X_status);
    if (X_status = 0) then

        update wsh_departures
        set net_weight = X_net_weight,
        fill_percent = 0
        where departure_id = dep_id;
      end if;

     end if;


     -- check if EDI product is installed
     IF (edi_installed_flag = 'U') THEN
       edi_installed_flag := 'N';
       IF (fnd_installation.get(175, 175, status, industry)) THEN
	 IF (status = 'I') THEN
	   edi_installed_flag := 'Y';
	 END IF;
       END IF;
     END IF;

     /*now call the ASN package
     IF (edi_installed_flag = 'Y') THEN
       ece_dsno.export_deliveries_api(dep_id);
     END IF;
	*/

    END IF;
  END IF;

  --We will delay the  update the status of the picking_header_id
  --in so_picking_headers_all until the departure is closed

  IF ( auto_created_dep ) THEN
    UPDATE so_picking_headers_all
    SET waybill_num = x_waybill,
        STATUS_CODE = 'PENDING'
    WHERE delivery_id = del_id;
  ELSE
    UPDATE so_picking_headers_all
    SET waybill_num = x_waybill
    WHERE delivery_id = del_id;
  END IF;

-- make departure id in so_picking_line_details in correct
  UPDATE so_picking_line_details
  SET departure_id = dep_id
  WHERE delivery_id = del_id;

-- clear any serial number entered in MTL_SERIAL_NUMBERS_TEMP
  wsh_sc_pld_pkg.delete_from_msnt(del_id);


  -- if we come here with no errors then we are ready to return back to the client
  -- with a value of 'True'
  RETURN TRUE;

-- Handle any exceptions
Exception

  WHEN OTHERS THEN
    return_msg1 := FND_MESSAGE.get;
    wsh_del_oi_core.println('msg ='|| return_msg1);
    FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
    FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_DELIVERY_PVT.Close_Delivery');
    FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    APP_EXCEPTION.Raise_Exception;
    return FALSE;

END Close_Delivery;

FUNCTION Print_Shipping_Doc_Set( x_del_id	IN NUMBER,
				 x_doc_set_id	IN NUMBER,
				 x_return_msg	OUT VARCHAR2 )
RETURN BOOLEAN IS
  return_code		BOOLEAN;
  return_message	VARCHAR2(2000);
  return_msg1           VARCHAR2(2000);
  x_org_id		NUMBER DEFAULT NULL;
  x_report_set_id	NUMBER;
  CURSOR c1( x_del_id	NUMBER) IS
  SELECT report_set_id, organization_id
  FROM wsh_deliveries
  WHERE delivery_id = x_del_id;
  invalid_parameters	EXCEPTION;
BEGIN
  IF ( x_del_id IS NULL ) THEN
    RAISE invalid_parameters;
  END IF;
  x_report_set_id := x_doc_set_id;
  IF ( NVL(x_report_set_id,-1) <= 0) THEN
    OPEN c1( x_del_id);
    FETCH c1 INTO x_report_set_id, x_org_id;
    IF ( c1%NOTFOUND ) THEN
      RAISE invalid_parameters;
    END IF;
    IF ( c1%ISOPEN) THEN
      CLOSE c1;
    END IF;
  END IF;
  IF ( x_report_set_id IS NULL ) THEN
    FND_MESSAGE.SET_NAME('OE','WSH_NO_DOCS');
    return_message := FND_MESSAGE.GET;
    x_return_msg := return_message;
    RETURN TRUE;
  END IF;

	WSH_DOC_SETS.Print_Document_Sets (
	X_report_set_id => x_report_set_id,
	P_DELIVERY_ID =>  TO_CHAR(x_del_id),
 	P_ORGANIZATION_ID => TO_CHAR(x_org_id),
        P_WAREHOUSE_ID => TO_CHAR(x_org_id),
	message_string => return_message,
	status => return_code );
  x_return_msg := return_message;
  RETURN return_code;
EXCEPTION
  WHEN invalid_parameters THEN
    IF ( c1%ISOPEN) THEN
      CLOSE c1;
    END IF;
    FND_MESSAGE.SET_NAME('OE','WSH_SC_INVALID_PARA');
    return_message := FND_MESSAGE.GET;
    x_return_msg := return_message;
    RETURN FALSE;
  WHEN others THEN
    return_msg1 := FND_MESSAGE.get;
    wsh_del_oi_core.println('msg ='|| return_msg1);
    IF ( c1%ISOPEN) THEN
      CLOSE c1;
    END IF;
    x_return_msg := return_message;
    RETURN FALSE;
END Print_Shipping_Doc_Set;

--      Function Name   :       Backorder_Delivery

--      Purpose         :
--      To process Backorder_all action on a Delivery

--      Parameters      :
--      1. Del_Id       IN      NUMBER
--         - delivery id we are working with
--      2. Process_Online IN    VARCHAR2
--         Y - run Update Shipping and Inventory Interface Online
--         N - do not run Update Shipping and Inventory Interface Online

--      Return Value    :       BOOLEAN
--
FUNCTION Backorder_Delivery(    Del_Id          IN      NUMBER)
RETURN BOOLEAN IS
  CURSOR c1( x_del_id 	NUMBER) IS
    SELECT actual_departure_id
    FROM wsh_deliveries
    WHERE delivery_id = x_del_id;

  dep_id 	NUMBER;
  return_msg1   varchar2(2000);
BEGIN

  -- update shipped quantity in so_picking_line_details
  wsh_sc_del_lines.update_shp_qty (del_id, 'BACKORDER_ALL');

  -- clear any charges entered in SO_FREIGHT_CHARGES
  delete from so_freight_charges
  where delivery_id = del_id;

  -- clear any container entered in WSH_PACKED_CONTAINERS
  delete from wsh_packed_containers
  where delivery_id = del_id;

  OPEN c1(del_id);
  FETCH c1 INTO dep_id;
  IF ( c1%ISOPEN) THEN
    CLOSE c1;
  END IF;

  UPDATE so_picking_line_details
  SET departure_id = dep_id,
      container_id = NULL,
      shipped_quantity = 0
  WHERE delivery_id = del_id;

  --call the server routine to unassign the unreleased delivery
  --lines from this delivery
  wsh_sc_del_lines.update_unrel_lines(del_id);

  -- Split the picking headers, picking lines and update the
  -- shipped quantity in picking lines

  split_picking_headers (del_id);


  -- update the delivery as 'CB' /* close backordered - is it CB or BO ? -open issue */

  UPDATE so_picking_headers_all
  SET status_code = 'PENDING'
  WHERE picking_header_id in
   (SELECT distinct pl.picking_header_id
    FROM so_picking_lines_all pl, so_picking_line_details pld
    WHERE pld.delivery_id = del_id
    AND	 pl.picking_line_id = pld.picking_line_id
    AND   pl.picking_header_id+0 > 0);

  update wsh_deliveries
  set status_code = 'CB'
  where delivery_id = del_id;

  return TRUE;

Exception
  WHEN OTHERS THEN
    return_msg1 := FND_MESSAGE.get;
    wsh_del_oi_core.println('msg ='|| return_msg1);
    IF ( c1%ISOPEN) THEN
      CLOSE c1;
    END IF;
    FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
    FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_DELIVERY_PVT.Backorder_Delivery');
    FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    APP_EXCEPTION.Raise_Exception;
    return FALSE;

END Backorder_Delivery;

--      Function Name   :       Unpack_Delivery

--      Purpose         :
--      To process the unpacking action on a Delivery

--      Parameters      :
--      1. Del_Id       IN      NUMBER
--         - delivery id we are working with

--      Return Value    :       BOOLEAN
--
FUNCTION Unpack_Delivery (Del_Id IN NUMBER) RETURN BOOLEAN IS

Source	Varchar2(1);

BEGIN

  --We need to take out the containers off the Delivery Lines and set the Shipped
  --quantity to null on them.

  UPDATE so_picking_line_details
  SET container_id = null
  WHERE delivery_id = Del_Id;

  --Now look at the souce code of the delivery ie who created it - DPW or SC
  SELECT source_code
  INTO Source
  FROM wsh_deliveries
  WHERE delivery_id = Del_Id;

  --Depending on the source, update the delivery status

  IF Source = 'D' THEN
    UPDATE wsh_deliveries
    SET status_code = 'PL'
    WHERE delivery_id = Del_Id;
  ELSIF Source = 'S' THEN
    UPDATE wsh_deliveries
    SET status_code = 'OP'
    WHERE delivery_id = Del_Id;
  END IF;

  RETURN TRUE;

--handle any exceptions
Exception

  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
    FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_DELIVERY_PVT.Unpack_Delivery');
    FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    APP_EXCEPTION.Raise_Exception;
    return FALSE;

END Unpack_Delivery;

--      Procedure Name  :       Update_Del_Status

--      Purpose         :
--      Updates the status code on a delivery to the required value

--      Parameters      :
--      1. Del_Id IN NUMBER
--         - delivery id we are working with
--      2. Del_Status_Code
--         - status to which we want the delivery to be updated

PROCEDURE Update_Del_Status(    Del_Id          IN      NUMBER,
                                Del_Status_Code IN      VARCHAR2) IS
BEGIN

  --just a simple and stupid statement to update the delivery status
  UPDATE wsh_deliveries
  SET status_code = del_status_code
  WHERE delivery_id = Del_Id;

END Update_Del_Status;


--      Procedure Name  :       Insert_Ph_Row

--      Purpose         :
--      Inserts a New Picking Header record in so_picking_headers

--      Parameters      :
--      1. Ph_Id        IN      NUMBER
--         - Picking Header record from which the new picking header
--           record is to be created
--      2. New_Ph_Id    IN      NUMBER
--         - Picking Header Id for the New picking header record
PROCEDURE Insert_Ph_Row (       Ph_Id           IN      NUMBER,
                                New_Ph_Id       IN      NUMBER) IS
BEGIN

  --Go ahead and insert a record in so_picking_headers_all
  INSERT INTO so_picking_headers_all
    ( PICKING_HEADER_ID
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,PROGRAM_APPLICATION_ID
    ,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,REQUEST_ID
    ,BATCH_ID
    ,ORDER_HEADER_ID
    ,WAREHOUSE_ID
    ,SHIP_TO_SITE_USE_ID
    ,STATUS_CODE
    ,PICK_SLIP_NUMBER
    ,WAYBILL_NUM
    ,PICKED_BY_ID
    ,PACKED_BY_ID
    ,WEIGHT
    ,WEIGHT_UNIT_CODE
    ,NUMBER_OF_BOXES
    ,SHIP_METHOD_CODE
    ,DATE_RELEASED
    ,DATE_SHIPPED
    ,DATE_CONFIRMED
    ,CONTEXT
    ,ATTRIBUTE1
    ,ATTRIBUTE2
    ,ATTRIBUTE3
    ,ATTRIBUTE4
    ,ATTRIBUTE5
    ,ATTRIBUTE6
    ,ATTRIBUTE7
    ,ATTRIBUTE8
    ,ATTRIBUTE9
    ,ATTRIBUTE10
    ,ATTRIBUTE11
    ,ATTRIBUTE12
    ,ATTRIBUTE13
    ,ATTRIBUTE14
    ,ATTRIBUTE15
    ,EXPECTED_ARRIVAL_DATE
    ,ORG_ID
    ,SHIP_NOTICE_SENT_DATE
    ,SHIP_NOTICE_SENT_FLAG
    ,DELIVERY_ID
    ,ARRIVED_FLAG )
  SELECT
    new_ph_id
    ,SYSDATE
    ,fnd_global.user_id
    ,SYSDATE
    ,fnd_global.user_id
    ,fnd_global.login_id
    ,PROGRAM_APPLICATION_ID
    ,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,REQUEST_ID
    ,BATCH_ID
    ,ORDER_HEADER_ID
    ,WAREHOUSE_ID
    ,SHIP_TO_SITE_USE_ID
    ,STATUS_CODE
    ,PICK_SLIP_NUMBER
    ,WAYBILL_NUM
    ,PICKED_BY_ID
    ,PACKED_BY_ID
    ,WEIGHT
    ,WEIGHT_UNIT_CODE
    ,NUMBER_OF_BOXES
    ,SHIP_METHOD_CODE
    ,DATE_RELEASED
    ,DATE_SHIPPED
    ,DATE_CONFIRMED
    ,CONTEXT
    ,ATTRIBUTE1
    ,ATTRIBUTE2
    ,ATTRIBUTE3
    ,ATTRIBUTE4
    ,ATTRIBUTE5
    ,ATTRIBUTE6
    ,ATTRIBUTE7
    ,ATTRIBUTE8
    ,ATTRIBUTE9
    ,ATTRIBUTE10
    ,ATTRIBUTE11
    ,ATTRIBUTE12
    ,ATTRIBUTE13
    ,ATTRIBUTE14
    ,ATTRIBUTE15
    ,EXPECTED_ARRIVAL_DATE
    ,ORG_ID
    ,SHIP_NOTICE_SENT_DATE
    ,SHIP_NOTICE_SENT_FLAG
    ,DELIVERY_ID
    ,ARRIVED_FLAG
  FROM so_picking_headers_all
  WHERE picking_header_id = Ph_Id;

END Insert_Ph_Row;

--      Procedure Name  :       Insert_Pl_Row

--      Purpose         :
--      Inserts a new picking line record in so_picking_lines_all

--      Parameters      :
--      1. Pl_Id        IN      NUMBER
--         - picking line record from which the new picking line
--           record is created
--      2. New_Pl_Id    IN      NUMBER
--         - picking line id for the new picking line record
--      3. New_Ph_Id    IN      NUMBER
--         - Picking Header Id for the New picking header record
PROCEDURE Insert_Pl_Row (       Pl_Id           IN      NUMBER,
                                New_Pl_Id       IN      NUMBER,
                                New_Ph_Id       IN      NUMBER) IS
BEGIN

  --Insert a row in so_picking_lines_all
  INSERT INTO so_picking_lines_all
  ( PICKING_LINE_ID
  ,CREATION_DATE
  ,CREATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,PICKING_HEADER_ID
  ,SEQUENCE_NUMBER
  ,ORDER_LINE_ID
  ,COMPONENT_CODE
  ,LINE_DETAIL_ID
  ,COMPONENT_RATIO
  ,REQUESTED_QUANTITY
  ,INVENTORY_ITEM_ID
  ,INCLUDED_ITEM_FLAG
  ,DATE_REQUESTED
  ,ORIGINAL_REQUESTED_QUANTITY
  ,WAREHOUSE_ID
  ,SHIPPED_QUANTITY
  ,CANCELLED_QUANTITY
  ,SHIP_TO_SITE_USE_ID
  ,SHIP_TO_CONTACT_ID
  ,SHIPMENT_PRIORITY_CODE
  ,SHIP_METHOD_CODE
  ,DATE_CONFIRMED
  ,RA_INTERFACE_STATUS
  ,INVOICED_QUANTITY
  ,INVENTORY_STATUS
  ,UNIT_CODE
  ,CONTEXT
  ,ATTRIBUTE1
  ,ATTRIBUTE2
  ,ATTRIBUTE3
  ,ATTRIBUTE4
  ,ATTRIBUTE5
  ,ATTRIBUTE6
  ,ATTRIBUTE7
  ,ATTRIBUTE8
  ,ATTRIBUTE9
  ,ATTRIBUTE10
  ,ATTRIBUTE11
  ,ATTRIBUTE12
  ,ATTRIBUTE13
  ,ATTRIBUTE14
  ,ATTRIBUTE15
  ,SCHEDULE_DATE
  ,DEMAND_CLASS_CODE
  ,COMPONENT_SEQUENCE_ID
  ,CONFIGURATION_ITEM_FLAG
  ,LATEST_ACCEPTABLE_DATE
  ,MOVEMENT_ID
  ,ORG_ID
  ,TRANSACTION_HEADER_ID
  ,SERVICE_INTERFACE_STATUS
  ,BO_PICKING_LINE_ID
  ,DEP_PLAN_REQUIRED_FLAG
  ,CUSTOMER_ITEM_ID )
  SELECT
  new_pl_id
  ,SYSDATE
  ,fnd_global.user_id
  ,SYSDATE
  ,fnd_global.user_id
  ,fnd_global.login_id
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,new_ph_id
  ,SEQUENCE_NUMBER
  ,ORDER_LINE_ID
  ,COMPONENT_CODE
  ,LINE_DETAIL_ID
  ,COMPONENT_RATIO
  ,REQUESTED_QUANTITY
  ,INVENTORY_ITEM_ID
  ,INCLUDED_ITEM_FLAG
  ,DATE_REQUESTED
  ,ORIGINAL_REQUESTED_QUANTITY
  ,WAREHOUSE_ID
  ,SHIPPED_QUANTITY
  ,CANCELLED_QUANTITY
  ,SHIP_TO_SITE_USE_ID
  ,SHIP_TO_CONTACT_ID
  ,SHIPMENT_PRIORITY_CODE
  ,SHIP_METHOD_CODE
  ,DATE_CONFIRMED
  ,RA_INTERFACE_STATUS
  ,INVOICED_QUANTITY
  ,INVENTORY_STATUS
  ,UNIT_CODE
  ,CONTEXT
  ,ATTRIBUTE1
  ,ATTRIBUTE2
  ,ATTRIBUTE3
  ,ATTRIBUTE4
  ,ATTRIBUTE5
  ,ATTRIBUTE6
  ,ATTRIBUTE7
  ,ATTRIBUTE8
  ,ATTRIBUTE9
  ,ATTRIBUTE10
  ,ATTRIBUTE11
  ,ATTRIBUTE12
  ,ATTRIBUTE13
  ,ATTRIBUTE14
  ,ATTRIBUTE15
  ,SCHEDULE_DATE
  ,DEMAND_CLASS_CODE
  ,COMPONENT_SEQUENCE_ID
  ,CONFIGURATION_ITEM_FLAG
  ,LATEST_ACCEPTABLE_DATE
  ,MOVEMENT_ID
  ,ORG_ID
  ,TRANSACTION_HEADER_ID
  ,SERVICE_INTERFACE_STATUS
  ,BO_PICKING_LINE_ID
  ,DEP_PLAN_REQUIRED_FLAG
  ,CUSTOMER_ITEM_ID
  FROM so_picking_lines_all
  WHERE picking_line_id = Pl_Id;

END Insert_Pl_Row;

--      Procedure Name  :       Split_Picking_Headers

--      Purpose         :
--      Splits Picking Headers and associated Picking Lines if
--      necessary while closing a delivery.

--      Parameters      :
--      1. Del_Id IN NUMBER
--         - delivery id we are working with
PROCEDURE Split_Picking_Headers (Del_Id         IN      NUMBER) IS

  --declare some local variables
  ph_id  	NUMBER;
  new_ph_id  	NUMBER;
  pl_id		NUMBER;
  new_pl_id  	NUMBER;
  num_found  	NUMBER;
  shp_qty	NUMBER;
  req_qty	NUMBER;

  --declare the picking header cursor
  CURSOR c1(del_id NUMBER) IS
  SELECT distinct pl.picking_header_id picking_header_id
  FROM so_picking_lines_all pl, so_picking_line_details pld
  WHERE	pld.delivery_id = del_id
  AND	pld.picking_line_id = pl.picking_line_id
  AND	pl.picking_header_id > 0;

  --declare the picking_lines_cursor
  CURSOR c2(ph_id NUMBER) IS
  SELECT picking_line_id
  FROM so_picking_lines_all
  WHERE picking_header_id = ph_id;

BEGIN

  -- Split the picking headers, picking lines and update the shipped
  -- quantity in picking lines

  OPEN c1 (del_id);
  Fetch c1 into ph_id ;

  WHILE c1%FOUND LOOP
  --begin picking header id loop

    --update the delivery_id on so_picking_headers_all
    UPDATE so_picking_headers_all
    SET delivery_id = del_id
    WHERE picking_header_id = ph_id;

    SELECT COUNT(*)
    into num_found
    FROM so_picking_line_details pld, so_picking_lines_all pl
    WHERE pl.picking_header_id = ph_id
    AND   pl.picking_line_id = pld.picking_line_id
    AND   ( pld.delivery_id <> del_id  OR
	   pld.delivery_id IS NULL ) ;

    IF num_found > 0 then
      --insert a new row into so_picking_headers_all by using the row with
      --picking_header_id = ph_id - except who info.

      --store the new picking header id as new_ph_id
      select so_picking_headers_s.nextval
      into new_ph_id
      from dual;

      insert_ph_row (ph_id, new_ph_id);

      UPDATE so_picking_headers_all
      set delivery_id = NULL
      where picking_header_id = ph_id;

      OPEN c2 (ph_id);
      Fetch c2 into pl_id;

      WHILE c2%FOUND LOOP
      -- begin picking line loop

  	SELECT COUNT(*)
        INTO num_found
        FROM so_picking_line_details
        WHERE picking_line_id = pl_id
        AND   ( delivery_id <> del_id OR
	 	delivery_id IS NULL ) ;

        IF num_found > 0 then -- outer if condition

  	  SELECT COUNT(*)
  	  INTO num_found
  	  FROM so_picking_line_details
  	  WHERE picking_line_id = pl_id
  	  AND delivery_id = del_id;

  	  IF num_found > 0 then  -- inner if condition

  	    --insert a new row into so_picking_lines_all by using the row with
  	    --picking_line_id = pl_id and ph_id = new ph id (except the
  	    --requested_quantity, shipped_quantity, and who info).

  	    --get the new picking line id
	    select so_picking_lines_s.nextval
  	    into new_pl_id
	    from dual;

	    insert_pl_row (pl_id, new_pl_id, new_ph_id);


  	    UPDATE so_picking_line_details
  	    SET picking_line_id = new_pl_id
  	    WHERE picking_line_id = pl_id
  	    AND   delivery_id = del_id;

	    -- now update the shipped and requested quantities on this new picking line
  	    SELECT sum(nvl(shipped_quantity,0)), sum(nvl(requested_quantity,0))
  	    INTO shp_qty, req_qty
  	    FROM so_picking_line_details
  	    WHERE picking_line_id = new_pl_id
  	    GROUP BY picking_line_id;

  	    UPDATE so_picking_lines_all
  	    SET   shipped_quantity = shp_qty,
  	    requested_quantity = req_qty,
            original_requested_quantity = req_qty
  	    where picking_line_id = new_pl_id;

	    -- also update the shipped and requested quantities on the old picking line
  	    SELECT sum(nvl(shipped_quantity,0)), sum(nvl(requested_quantity,0))
  	    INTO shp_qty, req_qty
  	    FROM so_picking_line_details
  	    WHERE picking_line_id = pl_id
  	    GROUP BY picking_line_id;

  	    UPDATE so_picking_lines_all
  	    SET   shipped_quantity = shp_qty,
  	    requested_quantity = req_qty,
            original_requested_quantity = req_qty
  	    where picking_line_id = pl_id;

--  	  ELSE

--  	    UPDATE so_picking_lines_all
--  	    SET picking_header_id = new_ph_id
--  	    WHERE picking_line_id = pl_id;


  	  END IF; -- inner if condition
          ELSE

            UPDATE so_picking_lines_all
            SET picking_header_id = new_ph_id
            WHERE picking_line_id = pl_id;

  	END IF;  -- outer if condition

        -- fetch the next record
        Fetch c2 into pl_id;

      END LOOP ; -- picking lines loop

      Close c2; -- close the picking line id cursor

    END IF;

    -- fetch the next record
    Fetch c1 into ph_id ;
  END LOOP;  -- picking header id loop

  Close c1;  -- close the picking header id cursor

END Split_Picking_Headers;

--      Function Name   :       Auto_Create_Departure

--      Purpose         :
--      To Create a departure and assign it to a delivery if the
--	delivery is not already associated with a departure

--      Parameters      :
--      All the parameters refer to the values on the delivery
--	for which we are creating the departure
--	1. Org_Id		IN	Number
--	2. Freight_Carrier	IN	Varchar2(30)
--	3. Weight_UOM		IN	Varchar2(3)
--	4. Volume_UOM		IN	Varchar2(3)
--	5. Weight_of_Delivery	IN	Number
--	6. Volume_of_Delivery	IN	Number

--      Return Value    :       Number - the departure id of the created
--				departure
--
FUNCTION Auto_Create_Departure (
	Org_Id			IN	Number,
	Freight_Carrier		IN	Varchar2,
	Weight_UOM		IN	Varchar2,
	Volume_UOM		IN	Varchar2,
	Weight_of_Delivery	IN	Number,
	p_tare_wt		IN	Number,
	Volume_of_Delivery	IN	Number,
	p_vehicle_item_id	IN	Number,
	p_vehicle_number	IN	Varchar2,
	p_seal_code		IN	Varchar2,
	p_pack_instr		IN	Varchar2,
	bol			IN	VARCHAR2,
	actual_date		IN	DATE DEFAULT SYSDATE,
	dep_name		IN	VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

-- declare local variables
dep_id	Number;
x_bol	WSH_DEPARTURES.BILL_OF_LADING%TYPE;
rep_id  number;
BEGIN

  -- Get the new departure id from the sequence
  select WSH_DEPARTURES_S.nextval into dep_id
  FROM DUAL;

  IF ( bol IS NULL) THEN
    x_bol := WSH_External_Custom.Bill_Of_Lading( dep_id);
  ELSE
    x_bol := bol;
  END IF;

  wsh_parameters_pvt.get_param_value_num(org_id,'DEPARTURE_REPORT_SET_ID',rep_id);


  -- Now go ahead and to the Insert

  INSERT INTO WSH_DEPARTURES (
  ORGANIZATION_ID
  ,DEPARTURE_ID
  ,NAME
  ,SOURCE_CODE
  ,ARRIVE_AFTER_DEPARTURE_ID
  ,STATUS_CODE
  ,REPORT_SET_ID
  ,DATE_CLOSED
  ,VEHICLE_ITEM_ID
  ,VEHICLE_NUMBER
  ,FREIGHT_CARRIER_CODE
  ,PLANNED_DEPARTURE_DATE
  ,ACTUAL_DEPARTURE_DATE
  ,BILL_OF_LADING
  ,GROSS_WEIGHT
  ,NET_WEIGHT
  ,WEIGHT_UOM_CODE
  ,VOLUME
  ,VOLUME_UOM_CODE
  ,FILL_PERCENT
  ,SEAL_CODE
  ,ROUTING_INSTRUCTIONS
  ,ATTRIBUTE_CATEGORY
  ,ATTRIBUTE1
  ,ATTRIBUTE2
  ,ATTRIBUTE3
  ,ATTRIBUTE4
  ,ATTRIBUTE5
  ,ATTRIBUTE6
  ,ATTRIBUTE7
  ,ATTRIBUTE8
  ,ATTRIBUTE9
  ,ATTRIBUTE10
  ,ATTRIBUTE11
  ,ATTRIBUTE12
  ,ATTRIBUTE13
  ,ATTRIBUTE14
  ,ATTRIBUTE15
  ,CREATION_DATE
  ,CREATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID )
  VALUES
  (
  Org_Id /*ORGANIZATION_ID */
  ,dep_id /* DEPARTURE_ID */
  ,NVL( dep_name, to_char(dep_id)) /* NAME */
  ,'S' /* SOURCE_CODE */
  ,NULL /* ARRIVE_AFTER_DEPARTURE_ID */
  ,'CL' /* STATUS_CODE */
  ,rep_id /* REPORT_SET_ID */
  ,SYSDATE /* DATE_CLOSED */
  ,p_vehicle_item_id /* VEHICLE_ITEM_ID */
  ,p_vehicle_number /* VEHICLE_NUMBER */
  ,Freight_Carrier /* FREIGHT_CARRIER_CODE */
  ,SYSDATE /* PLANNED_DEPARTURE_DATE */
  ,NVL( actual_date, SYSDATE) /* ACTUAL_DEPARTURE_DATE */
  ,x_bol
  ,Weight_of_Delivery /* GROSS_WEIGHT */
  ,Weight_of_delivery - p_tare_wt /* NET_WEIGHT */
  ,Weight_UOM /* WEIGHT_UOM_CODE */
  ,Volume_of_Delivery /* VOLUME */
  ,Volume_UOM /* VOLUME_UOM_CODE */
  ,NULL /* FILL_PERCENT */
  ,p_seal_code /* SEAL_CODE */
  ,p_pack_instr /* ROUTING_INSTRUCTIONS */
  ,NULL /* ATTRIBUTE_CATEGORY */
  ,NULL /* ATTRIBUTE1 */
  ,NULL /* ATTRIBUTE2 */
  ,NULL /* ATTRIBUTE3 */
  ,NULL /* ATTRIBUTE4 */
  ,NULL /* ATTRIBUTE5 */
  ,NULL /* ATTRIBUTE6 */
  ,NULL /* ATTRIBUTE7 */
  ,NULL /* ATTRIBUTE8 */
  ,NULL /* ATTRIBUTE9 */
  ,NULL /* ATTRIBUTE10 */
  ,NULL /* ATTRIBUTE11 */
  ,NULL /* ATTRIBUTE12 */
  ,NULL /* ATTRIBUTE13 */
  ,NULL /* ATTRIBUTE14 */
  ,NULL /* ATTRIBUTE15 */
  ,SYSDATE /* CREATION_DATE */
  ,FND_GLOBAL.User_Id /* CREATED_BY */
  ,SYSDATE /* LAST_UPDATE_DATE */
  ,FND_GLOBAL.User_Id /* LAST_UPDATED_BY */
  ,FND_GLOBAL.Login_Id /* LAST_UPDATE_LOGIN */
  ,300 /* PROGRAM_APPLICATION_ID  - 300 for order entry */
  ,NULL /* PROGRAM_ID */
  ,SYSDATE /* PROGRAM_UPDATE_DATE */
  ,NULL /* REQUEST_ID */
  );

  Return Dep_Id;

--handle any exceptions

Exception

  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
    FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_DELIVERY_PVT.Auto_Create_Departure');
    FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    APP_EXCEPTION.Raise_Exception;
    Return -1;

END Auto_Create_Departure;

--      Function Name   :       Delete_Container_Contents

--      Purpose         :

--      Parameters      :	X_Contaier_Id IN  Number

--      Return Value    :       Boolean

FUNCTION Delete_Container_Contents( x_container_id      IN NUMBER)
RETURN BOOLEAN IS

    CURSOR c1( x_cid    NUMBER) IS
    SELECT container_id FROM so_picking_line_details
    WHERE container_id = x_cid
    FOR UPDATE OF picking_line_detail_id NOWAIT;
    dummy_id            NUMBER;
    record_locked       EXCEPTION;
    PRAGMA    EXCEPTION_INIT( record_locked, -54);
  BEGIN
    SAVEPOINT before_lock;
    OPEN c1(x_container_id);
    FETCH c1 INTO dummy_id;
    CLOSE c1;

    UPDATE so_picking_line_details
    SET container_id = NULL
    WHERE container_id = x_container_id;

    RETURN TRUE;
  EXCEPTION
    WHEN others THEN
      ROLLBACK TO before_lock;
      IF c1%ISOPEN THEN
        CLOSE c1;
      END IF;
      FND_MESSAGE.SET_NAME('OE', 'WSH_FAIL_TO_LOCK_PLD');
      RETURN FALSE;
END Delete_Container_Contents;



END WSH_SC_DELIVERY_PVT;

/
