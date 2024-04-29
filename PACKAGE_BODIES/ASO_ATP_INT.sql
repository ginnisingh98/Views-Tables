--------------------------------------------------------
--  DDL for Package Body ASO_ATP_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ATP_INT" as
/* $Header: asoiatpb.pls 120.13.12010000.3 2010/02/18 11:31:29 rassharm ship $ */

--   API Name:  Check_ATP
--   Type    :  Public
--   Pre-Req :  Assumption is that p_qte_line_tbl and p_shipment_tbl are
--              synchronised. The same index should hold values for a
--              particular line.
--  History
--      12/12/2002  hyang - bug 2707989, changed default value to number for
--                          l_api_version_number.
--      06/03/04    skulkarn - bug 3604265, changed description to segment1 in cursor
--                             c_description

 G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_ATP_INT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiatpb.pls';


      PROCEDURE Call_ATP_Commit (p_session_id  OUT NOCOPY /* file.sql.39 change */   NUMBER, p_dblink IN VARCHAR2 )
 	IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	cursor_name  	NUMBER;
	cursor_c1  	NUMBER;
	rows_1  		NUMBER;
	rows_2  		NUMBER;
	l_statement	VARCHAR2(200);
	l_session_id	NUMBER;
	BEGIN

	cursor_name := dbms_sql.open_cursor;
       	DBMS_SQL.PARSE(cursor_name, 'alter session close database link ' ||p_dblink, dbms_sql.native);

 	cursor_c1  := dbms_sql.open_cursor;
	DBMS_SQL.PARSE(cursor_c1, 'Select MRP_ATP_SCHEDULE_TEMP_S.NextVal@' || p_dblink ||' From   Dual', dbms_sql.native);

			BEGIN
				dbms_sql.define_column( cursor_c1, 1, l_session_id );
				rows_1 := dbms_sql.execute(cursor_c1);
				if dbms_sql.fetch_rows( cursor_c1 ) > 0 then
					dbms_sql.column_value( cursor_c1, 1, l_session_id );

				end if;
				p_session_id := l_session_id;
       		END;


       		DBMS_SQL.close_cursor(cursor_c1);
		commit;

		BEGIN
			rows_2 := dbms_sql.execute(cursor_name);
       		EXCEPTION
          	WHEN OTHERS THEN
			null;
       		END;

       	DBMS_SQL.close_cursor(cursor_name);


	END Call_ATP_Commit;






  PROCEDURE Extend_ATP (p_atp_tbl  IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
                          x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    p_atp_tbl.Row_Id.Extend;
    p_atp_tbl.Inventory_Item_Id.Extend;
    p_atp_tbl.Inventory_Item_Name.Extend;
    p_atp_tbl.Source_Organization_Id.Extend;
    p_atp_tbl.Source_Organization_Code.Extend;
    p_atp_tbl.Organization_Id.Extend;
    p_atp_tbl.Identifier.Extend;
    --p_atp_tbl.Demand_Source_Header_Id.Extend;
    --p_atp_tbl.Demand_Source_Delivery.Extend;
    --p_atp_tbl.Demand_Source_Type.Extend;
    p_atp_tbl.Scenario_Id.Extend;
    p_atp_tbl.Calling_Module.Extend;
    p_atp_tbl.Customer_Id.Extend;
    p_atp_tbl.Customer_Site_Id.Extend;
    p_atp_tbl.Destination_Time_Zone.Extend;
    p_atp_tbl.Quantity_Ordered.Extend;
    p_atp_tbl.Quantity_UOM.Extend;
    p_atp_tbl.Requested_Ship_Date.Extend;
    p_atp_tbl.Requested_Arrival_Date.Extend;
    p_atp_tbl.Earliest_Acceptable_Date.Extend;
    p_atp_tbl.Latest_Acceptable_Date.Extend;
    p_atp_tbl.Delivery_Lead_Time.Extend;
    p_atp_tbl.Freight_Carrier.Extend;
    p_atp_tbl.Ship_Method.Extend;
    p_atp_tbl.Demand_Class.Extend;
    p_atp_tbl.Ship_Set_Name.Extend;
    p_atp_tbl.Arrival_Set_Name.Extend;
    p_atp_tbl.Override_Flag.Extend;
    p_atp_tbl.Action.Extend;
    p_atp_tbl.Ship_Date.Extend;
    p_atp_tbl.Available_Quantity.Extend;
    p_atp_tbl.Requested_Date_Quantity.Extend;
    p_atp_tbl.Group_Ship_Date.Extend;
    p_atp_tbl.Group_Arrival_Date.Extend;
    p_atp_tbl.Vendor_Id.Extend;
    p_atp_tbl.Vendor_Name.Extend;
    p_atp_tbl.Vendor_Site_Id.Extend;
    p_atp_tbl.Vendor_Site_Name.Extend;
    p_atp_tbl.Insert_Flag.Extend;
    p_atp_tbl.OE_Flag.Extend;
    p_atp_tbl.Error_Code.Extend;
    --p_atp_tbl.Atp_Lead_Time.Extend;
    p_atp_tbl.Message.Extend;

  END Extend_ATP;


PROCEDURE Populate_Output_Table( p_atp_rec        IN  MRP_ATP_PUB.ATP_REC_TYP,
                                 x_aso_atp_tbl    OUT NOCOPY  ASO_ATP_INT.ATP_TBL_TYP,
                                 x_return_status  OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
AS

l_index    NUMBER;

cursor c_ship_from_org_name(p_ship_from_org_id  number) is
select name
from oe_ship_from_orgs_v
where organization_id = p_ship_from_org_id;

cursor c_inv_item_desc(p_inv_item_id number, p_organization_id number) is
select padded_concatenated_segments, description
from mtl_system_items_kfv
where inventory_item_id = p_inv_item_id
and organization_id = p_organization_id;

cursor c_uom_meaning(p_inv_item_id number, p_organization_id number, p_uom_code varchar2) is
select unit_of_measure
from mtl_item_uoms_view
where inventory_item_id = p_inv_item_id
and organization_id = p_organization_id
and uom_code = p_uom_code;

cursor c_meaning(p_lookup_type varchar2, p_view_application_id number, p_lookup_code varchar2) is
select meaning
from fnd_lookup_values
where lookup_type = p_lookup_type
and view_application_id = p_view_application_id
and lookup_code = p_lookup_code
and enabled_flag = 'Y'
and language = USERENV('LANG')
and trunc(nvl(start_date_active,sysdate)) <= trunc(sysdate)
and trunc(nvl(end_date_active,sysdate)) >= trunc(sysdate);

cursor c_qty_on_hand(p_inv_item_id number, p_organization_id number) is
select total_qoh
from mtl_onhand_items_v
where organization_id = p_organization_id
and inventory_item_id = p_inv_item_id;

cursor c_request_date_type(p_quote_header_id number) is
select nvl(request_date_type,'SHIP'),shipment_id
from aso_shipments
where quote_header_id = p_quote_header_id;

cursor c_request_date_type_meaning(p_lookup_code varchar2) is
select l.meaning
from oe_lookups l
where l.lookup_type = 'REQUEST_DATE_TYPE' and
l.enabled_flag = 'Y'
and trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
and nvl(end_date_active,trunc(sysdate))
and l.lookup_code = p_lookup_code;

cursor c_error_desc(p_error_code varchar2) is
select meaning
from mfg_lookups
where lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
and lookup_code = p_error_code;

cursor c_get_shipment_id (p_qte_header_id number, p_qte_line_id number) is
select shipment_id
from aso_shipments
where quote_header_id = p_qte_header_id
and quote_line_id = p_qte_line_id;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     If p_atp_rec.inventory_item_id IS NOT NULL Then

         if aso_debug_pub.g_debug_flag = 'Y' then
	        aso_debug_pub.add('Populate_Output_Table: inside if for p_atp_rec.inventory_item_id',1,'N');
         end if;

         For i in p_atp_rec.inventory_item_id.FIRST ..  p_atp_rec.inventory_item_id.LAST Loop

              if aso_debug_pub.g_debug_flag = 'Y' then
	             aso_debug_pub.add('Populate_Output_Table: inside loop for p_atp_rec.inventory_item_id',1,'N');
	         end if;

              if p_atp_rec.inventory_item_id.EXISTS(i) then

                  x_aso_atp_tbl(i).inventory_item_id          := p_atp_rec.inventory_item_id(i);
                  x_aso_atp_tbl(i).inventory_item_name        := p_atp_rec.inventory_item_name(i);
                  x_aso_atp_tbl(i).source_organization_id     := p_atp_rec.source_organization_id(i);
                  x_aso_atp_tbl(i).source_organization_code   := p_atp_rec.source_organization_code(i);
                  x_aso_atp_tbl(i).identifier                 := p_atp_rec.identifier(i);
                  x_aso_atp_tbl(i).customer_id                := p_atp_rec.customer_id(i);
                  x_aso_atp_tbl(i).customer_site_id           := p_atp_rec.customer_site_id(i);
                  x_aso_atp_tbl(i).Quantity_Ordered           := p_atp_rec.Quantity_Ordered(i);
                  x_aso_atp_tbl(i).Quantity_UOM               := p_atp_rec.Quantity_UOM(i);
                  x_aso_atp_tbl(i).Requested_Ship_Date        := p_atp_rec.Requested_Ship_Date(i);
                  x_aso_atp_tbl(i).Ship_Date                  := p_atp_rec.Ship_Date(i);
                  x_aso_atp_tbl(i).Available_Quantity         := p_atp_rec.Available_Quantity(i);
                  x_aso_atp_tbl(i).Request_Date_Quantity      := p_atp_rec.Requested_Date_Quantity(i);
                  x_aso_atp_tbl(i).Error_Code                 := p_atp_rec.Error_Code(i);
                  x_aso_atp_tbl(i).Message                    := p_atp_rec.Message(i);
                  --x_aso_atp_tbl(i).request_date_type          := p_atp_rec.request_date_type(i);
                  x_aso_atp_tbl(i).demand_class_code          := p_atp_rec.demand_class(i);
                  x_aso_atp_tbl(i).ship_set_name              := p_atp_rec.ship_set_name(i);
                  x_aso_atp_tbl(i).arrival_set_name           := p_atp_rec.arrival_set_name(i);
                  x_aso_atp_tbl(i).line_number                := p_atp_rec.line_number(i);
                  x_aso_atp_tbl(i).group_ship_date            := p_atp_rec.group_ship_date(i);
                  x_aso_atp_tbl(i).requested_arrival_date     := p_atp_rec.requested_arrival_date(i);
                  x_aso_atp_tbl(i).ship_method_code           := p_atp_rec.ship_method(i);
                  --x_aso_atp_tbl(i).quantity_on_hand           := p_atp_rec.quantity_on_hand(i);
                  x_aso_atp_tbl(i).quote_header_id            := p_atp_rec.demand_source_header_id(i);
                  x_aso_atp_tbl(i).calling_module             := p_atp_rec.calling_module(i);
                  x_aso_atp_tbl(i).quote_number               := p_atp_rec.order_number(i);
                  x_aso_atp_tbl(i).ato_line_id                := p_atp_rec.ato_model_line_id(i);
                  x_aso_atp_tbl(i).ref_line_id                := p_atp_rec.parent_line_id(i);
                  x_aso_atp_tbl(i).top_model_line_id          := p_atp_rec.top_model_line_id(i);
                  x_aso_atp_tbl(i).action                     := p_atp_rec.action(i);
                  x_aso_atp_tbl(i).arrival_date               := p_atp_rec.arrival_date(i);
                  x_aso_atp_tbl(i).organization_id            := p_atp_rec.validation_org(i);
                  x_aso_atp_tbl(i).component_code             := p_atp_rec.component_code(i);
                  x_aso_atp_tbl(i).component_sequence_id      := p_atp_rec.component_sequence_id(i);
                  x_aso_atp_tbl(i).included_item_flag         := p_atp_rec.included_item_flag(i);
                  x_aso_atp_tbl(i).cascade_model_info_to_comp := p_atp_rec.cascade_model_info_to_comp(i);
                  --x_aso_atp_tbl(i).ship_to_party_site_id      := p_atp_rec.ship_to_party_site_id(i);
                  x_aso_atp_tbl(i).country                    := p_atp_rec.customer_country(i);
                  x_aso_atp_tbl(i).state                      := p_atp_rec.customer_state(i);
                  x_aso_atp_tbl(i).city                       := p_atp_rec.customer_city(i);
                  x_aso_atp_tbl(i).postal_code                := p_atp_rec.customer_postal_code(i);
                  x_aso_atp_tbl(i).match_item_id              := p_atp_rec.match_item_id(i);

                  open c_ship_from_org_name(p_atp_rec.source_organization_id(i));
			   fetch c_ship_from_org_name into x_aso_atp_tbl(i).source_organization_name;
			   close c_ship_from_org_name;

                  open c_inv_item_desc(p_atp_rec.inventory_item_id(i), p_atp_rec.validation_org(i));
			   fetch c_inv_item_desc into x_aso_atp_tbl(i).padded_concatenated_segments, x_aso_atp_tbl(i).inventory_item_description;
			   close c_inv_item_desc;

                  open c_uom_meaning(p_atp_rec.inventory_item_id(i), p_atp_rec.validation_org(i), p_atp_rec.quantity_uom(i));
			   fetch c_uom_meaning into x_aso_atp_tbl(i).uom_meaning;
			   close c_uom_meaning;

                  open c_meaning('SHIP_METHOD', 3, p_atp_rec.ship_method(i));
			   fetch c_meaning into x_aso_atp_tbl(i).ship_method_meaning;
			   close c_meaning;

                  open c_meaning('DEMAND_CLASS', 3, p_atp_rec.demand_class(i));
			   fetch c_meaning into x_aso_atp_tbl(i).demand_class_meaning;
			   close c_meaning;

                  -- always getting the header shipment request date type as line shipment request date type is not supported
                  open c_request_date_type(p_atp_rec.demand_source_header_id(i));
			   fetch c_request_date_type into x_aso_atp_tbl(i).request_date_type,x_aso_atp_tbl(i).shipment_id;
			   close c_request_date_type;

                  IF x_aso_atp_tbl(i).request_date_type IS NOT NULL THEN
                    open c_request_date_type_meaning(x_aso_atp_tbl(i).request_date_type);
                    fetch c_request_date_type_meaning into x_aso_atp_tbl(i).request_date_type_meaning;
                    close c_request_date_type_meaning;
                  END IF;

                  open c_error_desc(p_atp_rec.error_code(i));
			   fetch c_error_desc into x_aso_atp_tbl(i).error_description;
			   close c_error_desc;

			   if p_atp_rec.ato_model_line_id(i) is not null and p_atp_rec.ato_model_line_id(i) = p_atp_rec.identifier(i) then

                      open c_qty_on_hand(p_atp_rec.match_item_id(i),  p_atp_rec.source_organization_id(i));  -- bug 9378431
			       fetch c_qty_on_hand into x_aso_atp_tbl(i).quantity_on_hand;
			       close c_qty_on_hand;

	                 if aso_debug_pub.g_debug_flag = 'Y' then
		                aso_debug_pub.add('p_atp_rec.match_item_id: ' || p_atp_rec.match_item_id(i),1,'N');
		                aso_debug_pub.add('x_aso_atp_tbl(i).quantity_on_hand: ' || x_aso_atp_tbl(i).quantity_on_hand,1,'N');
			       end if;

                  elsif nvl(p_atp_rec.top_model_line_id(i), 0) <> p_atp_rec.identifier(i) and p_atp_rec.ato_model_line_id(i) is null then

                      open c_qty_on_hand(p_atp_rec.inventory_item_id(i), p_atp_rec.source_organization_id(i)); -- bug 9378431
			       fetch c_qty_on_hand into x_aso_atp_tbl(i).quantity_on_hand;
			       close c_qty_on_hand;

	                 if aso_debug_pub.g_debug_flag = 'Y' then
		                aso_debug_pub.add('x_aso_atp_tbl(i).quantity_on_hand: ' || x_aso_atp_tbl(i).quantity_on_hand,1,'N');
			       end if;

                  end if;

                 open c_get_shipment_id(p_atp_rec.demand_source_header_id(i), p_atp_rec.identifier(i));
                 fetch c_get_shipment_id into  x_aso_atp_tbl(i).shipment_id;
			  close c_get_shipment_id;

	             if aso_debug_pub.g_debug_flag = 'Y' then
		            aso_debug_pub.add('p_atp_rec.inventory_item_id:          ' || p_atp_rec.inventory_item_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.inventory_item_name:        ' || p_atp_rec.inventory_item_name(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.source_organization_code:   ' || p_atp_rec.source_organization_code(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.source_organization_id:     ' || p_atp_rec.source_organization_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.identifier:                 ' || p_atp_rec.identifier(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_id:                ' || p_atp_rec.customer_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_site_id:           ' || p_atp_rec.customer_site_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Quantity_Ordered:           ' || p_atp_rec.Quantity_Ordered(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Quantity_UOM:               ' || p_atp_rec.Quantity_UOM(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Requested_Ship_Date:        ' || p_atp_rec.Requested_Ship_Date(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Ship_Date:                  ' || p_atp_rec.Ship_Date(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Available_Quantity:         ' || p_atp_rec.Available_Quantity(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Requested_Date_Quantity:    ' || p_atp_rec.Requested_Date_Quantity(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Error_Code:                 ' || p_atp_rec.Error_Code(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.Message:                    ' || p_atp_rec.Message(i),1,'N');
                      --aso_debug_pub.add('p_atp_rec.request_date_type:        ' || p_atp_rec.request_date_type(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.demand_class:               ' || p_atp_rec.demand_class(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.ship_set_name:              ' || p_atp_rec.ship_set_name(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.arrival_set_name:           ' || p_atp_rec.arrival_set_name(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.line_number:                ' || p_atp_rec.line_number(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.group_ship_date:            ' || p_atp_rec.group_ship_date(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.requested_arrival_date:     ' || p_atp_rec.requested_arrival_date(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.ship_method:                ' || p_atp_rec.ship_method(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.demand_source_header_id:    ' || p_atp_rec.demand_source_header_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.calling_module:             ' || p_atp_rec.calling_module(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.order_number:               ' || p_atp_rec.order_number(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.ato_model_line_id:          ' || p_atp_rec.ato_model_line_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.parent_line_id:             ' || p_atp_rec.parent_line_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.top_model_line_id:          ' || p_atp_rec.top_model_line_id(i),1,'N');
		            aso_debug_pub.add('p_atp_rec.match_item_id:              ' || p_atp_rec.match_item_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.action:                     ' || p_atp_rec.action(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.arrival_date:               ' || p_atp_rec.arrival_date(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.validation_org:             ' || p_atp_rec.validation_org(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.component_code:             ' || p_atp_rec.component_code(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.component_sequence_id:      ' || p_atp_rec.component_sequence_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.included_item_flag:         ' || p_atp_rec.included_item_flag(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.cascade_model_info_to_comp: ' || p_atp_rec.cascade_model_info_to_comp(i),1,'N');
                      --aso_debug_pub.add('p_atp_rec.ship_to_party_site_id:    ' || p_atp_rec.ship_to_party_site_id(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_country:           ' || p_atp_rec.customer_country(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_state:             ' || p_atp_rec.customer_state(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_city:              ' || p_atp_rec.customer_city(i),1,'N');
                      aso_debug_pub.add('p_atp_rec.customer_postal_code:       ' || p_atp_rec.customer_postal_code(i),1,'N');
	             end if;

              end if;

         End Loop;

	    if aso_debug_pub.g_debug_flag = 'Y' then

		   for i in 1 .. x_aso_atp_tbl.count loop

	             aso_debug_pub.add('x_aso_atp_tbl('||i||').source_organization_name:     '|| x_aso_atp_tbl(i).source_organization_name, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').padded_concatenated_segments: '|| x_aso_atp_tbl(i).padded_concatenated_segments, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').inventory_item_description:   '|| x_aso_atp_tbl(i).inventory_item_description, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').uom_meaning:                  '|| x_aso_atp_tbl(i).uom_meaning, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').quantity_on_hand:             '|| x_aso_atp_tbl(i).quantity_on_hand, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').ship_method_meaning:          '|| x_aso_atp_tbl(i).ship_method_meaning, 1, 'N');
	             aso_debug_pub.add('x_aso_atp_tbl('||i||').demand_class_meaning:         '|| x_aso_atp_tbl(i).demand_class_meaning, 1, 'N');
                  aso_debug_pub.add('x_aso_atp_tbl('||i||').organization_id:              '|| x_aso_atp_tbl(i).organization_id, 1, 'N');
                  aso_debug_pub.add('x_aso_atp_tbl('||i||').shipment_id:                  '|| x_aso_atp_tbl(i).shipment_id, 1, 'N');
	        end loop;

	    end if;

     End If;

END Populate_Output_Table;



PROCEDURE Do_Check_ATP(
                 P_Api_Version_Number  IN    NUMBER,
                 P_Init_Msg_List       IN    VARCHAR2     := FND_API.G_FALSE,
                 p_qte_header_rec      IN    ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
                 p_qte_line_tbl        IN    ASO_QUOTE_PUB.qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
                 p_shipment_tbl        IN    ASO_QUOTE_PUB.shipment_tbl_type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
                 p_entire_quote_flag   IN    VARCHAR2 :='N',
			  x_return_status       OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                 x_msg_count           OUT NOCOPY /* file.sql.39 change */   NUMBER,
                 x_msg_data            OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                 X_atp_tbl             OUT NOCOPY /* file.sql.39 change */   aso_atp_int.atp_tbl_typ)
AS

l_api_name             CONSTANT VARCHAR2(30) := 'Do_Check_ATP' ;
l_api_version_number   CONSTANT NUMBER := 1.0;

l_session_id 	        number;
l_sysdate	             date;
l_atp_rec	             mrp_atp_pub.atp_rec_typ;
l_atp_rec_out	        mrp_atp_pub.atp_rec_typ;
l_atp_supply_demand    mrp_atp_pub.atp_supply_demand_typ;
l_atp_period           mrp_atp_pub.atp_period_typ;
l_atp_details          mrp_atp_pub.atp_details_typ;
l_null_aso_atp_typ     aso_atp_int.atp_rec_typ;
l_mrp_database_link    Varchar2(128);
l_statement            Varchar2(500);
l_ship_from_org_id     Number ;
l_profile_name         Varchar2(240);
l_customer_id          NUMBER;
l_cust_ship_site_id    NUMBER;
l_mrp_customer_id      NUMBER;
l_mrp_ship_site_id     NUMBER;
l_use_sourcing_rule    VARCHAR2(10);
l_file                 VARCHAR2(200);

l_qte_line_tbl aso_quote_pub.qte_line_tbl_type := p_qte_line_tbl;
l_shipment_tbl aso_quote_pub.shipment_tbl_type := p_shipment_tbl;
l_qte_line_rec aso_quote_pub.qte_line_rec_type;
l_shipment_rec aso_quote_pub.shipment_rec_type;
--l_aso_atp_tbl  aso_atp_int.atp_tbl_typ;

cursor c_description(p_inventory_item_id number,p_organization_id number) is
-- this cursor has been modified to select segment1 instead of description, see bug 3604265
select segment1
from mtl_system_items_vl
where inventory_item_id = p_inventory_item_id
and organization_id = p_organization_id;

cursor c_config_dtl(p_qte_line_id number) is
select a.quote_line_id, b.item_type_code, a.config_header_id, a.config_revision_num,a.component_code,
a.config_item_id, a.ref_line_id, a.top_model_line_id, a.ato_line_id, a.component_sequence_id,
b.ship_model_complete_flag
from aso_quote_line_details a, aso_quote_lines_all b
where b.quote_line_id = p_qte_line_id
and b.quote_line_id = a.quote_line_id
and a.ref_type_code = 'CONFIG';

cursor c_quote_line_id(p_config_header_id number, p_config_revision_num number, p_config_item_id number) is
select quote_line_id
from aso_quote_line_details
where config_header_id = p_config_header_id
and config_revision_num = p_config_revision_num
and config_item_id = p_config_item_id;

cursor c_smc(p_quote_line_id number) is
select ship_model_complete_flag
from aso_quote_lines_all
where quote_line_id = p_quote_line_id;

cursor c_quote_number(p_quote_header_id number) is
select quote_number, cust_account_id
from aso_quote_headers_all
where quote_header_id = p_quote_header_id;

cursor c_configuration_rows(p_config_header_id number, p_config_revision_num number) is
select a.quote_line_id, b.shipment_id
from aso_quote_line_details a, aso_shipments b
where a.quote_line_id = b.quote_line_id
and a.config_header_id = p_config_header_id
and a.config_revision_num = p_config_revision_num
order by a.bom_sort_order;

cursor c_ato_rows(p_config_header_id number, p_config_revision_num number, p_ato_line_id number) is
select a.quote_line_id, b.shipment_id
from aso_quote_line_details a, aso_shipments b
where a.quote_line_id = b.quote_line_id
and a.config_header_id = p_config_header_id
and a.config_revision_num = p_config_revision_num
and a.ato_line_id = p_ato_line_id
order by a.bom_sort_order;

cursor c_top_model_line_id(p_config_header_id number, p_config_revision_num number) is
select quote_line_id from aso_quote_line_details
where config_header_id = p_config_header_id
and config_revision_num = p_config_revision_num
and ref_line_id is null
and ref_type_code = 'CONFIG';

cursor c_shipment_id(p_quote_line_id number) is
select shipment_id from aso_shipments
where quote_line_id = p_quote_line_id;

cursor c_request_date_type(p_shipment_id number) is
select request_date_type from aso_shipments
where shipment_id = p_shipment_id;

-- filtering out the service items and the component models
-- before passing the records to ATP
cursor get_ordered_lines (p_qte_header_id number) is
select quote_line_id
from aso_pvt_quote_lines_bali_v
where quote_header_id = p_qte_header_id
and nvl(service_item_flag,'N')  = 'N'
and instance_id is null
and nvl(config_model_type,'X') <> 'N' ;

cursor get_no_of_lines(p_qte_header_id number) is
select count(quote_line_id)
from aso_quote_lines_all
where quote_header_id = p_qte_header_id;

cursor c_get_warehouse (p_qte_line_id number, p_qte_header_id number ) is
select ship_from_org_id
from aso_shipments
where quote_line_id = p_qte_line_id
and quote_header_id = p_qte_header_id;

cursor c_get_ids (p_qte_line_id number) is
select ato_line_id,top_model_line_id
from aso_quote_line_details
where quote_line_id = p_qte_line_id;

cursor c_get_request_date (p_qte_line_id number, p_qte_header_id number,p_date_type varchar2 ) is
select request_date
from aso_shipments
where quote_line_id = p_qte_line_id
and quote_header_id = p_qte_header_id
and nvl(request_date_type,'SHIP')  = p_date_type;

cursor c_get_ship_method (p_qte_line_id number, p_qte_header_id number ) is
select ship_method_code
from aso_shipments
where quote_line_id = p_qte_line_id
and quote_header_id = p_qte_header_id;

cursor c_get_demand_code (p_qte_line_id number, p_qte_header_id number ) is
select demand_class_code
from aso_shipments
where quote_line_id = p_qte_line_id
and quote_header_id = p_qte_header_id;


l_ship_model_complete_flag  varchar2(1);
l_quote_line_id             number;
l_model_quote_line_id       number;
l_ato_quote_line_id         number;
l_index                     number := 0;
l_top_model_line_id         number;
-- bug 3604265
l_segment1                  varchar2(40);

TYPE Varchar2_Search_Tbl_Type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE Number_Search_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_smc_search_tbl                  Varchar2_Search_Tbl_Type;
l_qte_line_search_tbl             Number_Search_Tbl_Type;
l_shipment_search_tbl             Number_Search_Tbl_Type;
l_config_hdr_search_tbl           Number_Search_Tbl_Type;
l_ato_tbl                         Number_Search_Tbl_Type;
l_ato_line_id_tbl                 Number_Search_Tbl_Type;
l_db_shipment_rec                 aso_quote_pub.shipment_rec_type;
l_db_qte_line_rec                 aso_quote_pub.qte_line_rec_type;
l_check_atp_for_whole_quote       varchar2(1) := fnd_api.g_false;
l_ship_to_party_site_id           number;
l_ship_to_cust_account_id         number;
lx_cust_acct_site_use_id          number;
l_out_qte_line_number_tbl         aso_line_num_int.Out_Line_Number_Tbl_Type;
l_in_qte_line_number_tbl          aso_line_num_int.In_Line_Number_Tbl_Type;

l_search_tbl                      Number_Search_Tbl_Type;
l_qte_line_id_from_bali           number;
l_no_of_lines                     number;
l_new_qte_line_tbl                aso_quote_pub.qte_line_tbl_type ;
l_new_shipment_tbl                aso_quote_pub.shipment_tbl_type ;

l_cascade_ship_from_org_id        number;
l_cascade_request_date            date;
l_cascade_ship_method_code        varchar2(30);
l_cascade_demand_class_code       varchar2(30);
l_ato_line_id                     number;
l_model_line_id                   number;
l_shipment_id                     number;
 x_new_msg_data                   varchar2(3000);
m                                 integer;
l_hdr_shipment_rec                aso_quote_pub.shipment_rec_type;
l_hdr_shipment_tbl                aso_quote_pub.shipment_tbl_type ;
BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT DO_CHECK_ATP_INT;

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('do_check_atp: Begin');
     END IF;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                        	                 p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

	x_return_status := fnd_api.g_ret_sts_success;

     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('do_check_atp: ********Printing the Input to Check ATP API *************', 1, 'Y');
         aso_debug_pub.add('do_check_atp: p_qte_header_rec.quote_header_id: '|| p_qte_header_rec.quote_header_id, 1, 'Y');
         aso_debug_pub.add('do_check_atp: p_entire_quote_flag: '|| p_entire_quote_flag, 1, 'Y');
         aso_debug_pub.add('do_check_atp: p_qte_line_tbl.count: '|| p_qte_line_tbl.count, 1, 'Y');
        for i in 1..p_qte_line_tbl.count loop
         aso_debug_pub.add('do_check_atp: p_qte_line_tbl('||i||').quote_line_id: '|| p_qte_line_tbl(i).quote_line_id, 1, 'Y');
         aso_debug_pub.add('do_check_atp: p_qte_line_tbl('||i||').quote_header_id: '|| p_qte_line_tbl(i).quote_header_id, 1, 'Y');
        end loop;
         aso_debug_pub.add('do_check_atp: p_shipment_tbl.count: '|| p_shipment_tbl.count, 1, 'Y');
	   for i in 1..p_shipment_tbl.count loop
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').ship_method_code: '|| p_shipment_tbl(i).ship_method_code, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').ship_from_org_id: '|| p_shipment_tbl(i).ship_from_org_id, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').demand_class_code: '|| p_shipment_tbl(i).demand_class_code, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').request_date: '|| p_shipment_tbl(i).request_date, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').shipment_id: '|| p_shipment_tbl(i).shipment_id, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: p_shipment_tbl('||i||').quote_line_id: '|| p_shipment_tbl(i).quote_line_id, 1, 'Y');
        end loop;
        aso_debug_pub.add('do_check_atp: **************************************************************', 1, 'Y');
	end if;



	if p_qte_line_tbl.count = 0 and p_shipment_tbl.count = 0 then

         if p_qte_header_rec.quote_header_id is null or p_qte_header_rec.quote_header_id = fnd_api.g_miss_num then

             if aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('do_check_atp: p_qte_line_tbl and p_shipment_tbl is null. Also p_qte_header_rec.quote_header_id is null');
             end if;

             if fnd_msg_pub.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_ALL_MISSING_PARAM');
                 FND_MESSAGE.Set_Token('API_NAME', 'Check_ATP', FALSE);
                 FND_MESSAGE.Set_Token('PARAMETER', 'p_qte_header_rec', FALSE);
                 FND_MSG_PUB.ADD;
             end if;
		   x_return_status := fnd_api.g_ret_sts_error;
             raise fnd_api.g_exc_error;

         else
	        /*
             l_qte_line_tbl := aso_utility_pvt.query_qte_line_rows_atp(p_qte_header_rec.quote_header_id);
             for i in 1..l_qte_line_tbl.count loop
               l_shipment_rec := aso_utility_pvt.query_line_shipment_row_atp(p_qte_header_rec.quote_header_id,
                                                                             l_qte_line_tbl(i).quote_line_id);
               l_shipment_tbl(l_shipment_tbl.count + 1 ) := l_shipment_rec;
             end loop; */
             --l_shipment_tbl := aso_utility_pvt.query_line_shipment_rows_atp(p_qte_header_rec.quote_header_id);
             l_check_atp_for_whole_quote  := fnd_api.g_true;
	    end if;

	end if;

     if p_qte_line_tbl.count >= 1 then

       open get_no_of_lines(p_qte_header_rec.quote_header_id);
	  fetch get_no_of_lines into l_no_of_lines;
	  close get_no_of_lines;

       if p_qte_line_tbl.count = l_no_of_lines then

         if aso_debug_pub.g_debug_flag = 'Y' then
           aso_debug_pub.add('do_check_atp: No of lines passed is equal to no lines in db, hence whole qte is true', 1, 'Y');
         end if;
	    l_check_atp_for_whole_quote  := fnd_api.g_true;
	  end if;

     end if;

	    if ((p_entire_quote_flag = 'Y') or (l_check_atp_for_whole_quote = fnd_api.g_true))  then

             if aso_debug_pub.g_debug_flag = 'Y' then
               aso_debug_pub.add('do_check_atp: Getting the quote lines and shipment from db', 1, 'Y');
             end if;
             l_qte_line_tbl := aso_utility_pvt.query_qte_line_rows_atp(p_qte_header_rec.quote_header_id);
             for i in 1..l_qte_line_tbl.count loop
               l_shipment_rec := aso_utility_pvt.query_line_shipment_row_atp(p_qte_header_rec.quote_header_id,
                                                                             l_qte_line_tbl(i).quote_line_id);
               l_shipment_tbl(i) := l_shipment_rec;
             end loop;
             l_check_atp_for_whole_quote  := fnd_api.g_true;
         end if;

         if aso_debug_pub.g_debug_flag = 'Y' then
           aso_debug_pub.add('do_check_atp: Before creating the search tables', 1, 'Y');
         end if;


         --create quote line search table
         for i in 1..p_qte_line_tbl.count loop

            if p_qte_line_tbl(i).quote_line_id is not null and p_qte_line_tbl(i).quote_line_id <> fnd_api.g_miss_num then

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('do_check_atp:  p_qte_line_tbl(i).quote_line_id: ' || p_qte_line_tbl(i).quote_line_id,1,'Y');
                end if;

                l_qte_line_search_tbl(p_qte_line_tbl(i).quote_line_id) := i;

            else
                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('do_check_atp:  p_qte_line_tbl(i).quote_line_id: ' || p_qte_line_tbl(i).quote_line_id,1,'Y');
                    aso_debug_pub.add('do_check_atp:  Quote_line_id is passed as nulll or g_miss_num in line record' ,1,'Y');
                end if;

                if fnd_msg_pub.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
                    FND_MESSAGE.Set_Token('COLUMN', 'Quote_Line_Id', FALSE);
                    FND_MSG_PUB.ADD;
                end if;
                x_return_status := fnd_api.g_ret_sts_error;
                raise fnd_api.g_exc_error;

            end if;

         end loop;

         --create shipment search table
         --Assumption is p_qte_line_tbl and p_shipment_tbl are one-to-one mapping
         --For each quote line in p_qte_line_tbl there exist a shipment record in p_shipment_tbl

         for i in 1..p_shipment_tbl.count loop

            if p_shipment_tbl(i).shipment_id is not null and p_shipment_tbl(i).shipment_id <> fnd_api.g_miss_num then

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('do_check_atp:   p_shipment_tbl(i).shipment_id: ' ||  p_shipment_tbl(i).shipment_id,1,'Y');
                end if;

                l_shipment_search_tbl(p_shipment_tbl(i).shipment_id) := i;

            else

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('do_check_atp:   p_shipment_tbl(i).shipment_id: ' ||  p_shipment_tbl(i).shipment_id,1,'Y');
                    aso_debug_pub.add('do_check_atp:  shipment_id is passed as nulll or g_miss_num in shipment record' ,1,'Y');
                end if;

                open c_shipment_id(p_qte_line_tbl(i).quote_line_id);
                fetch c_shipment_id into l_shipment_tbl(i).shipment_id;
                close c_shipment_id;

                 l_shipment_search_tbl(l_shipment_tbl(i).shipment_id) := i;
                /*
                if fnd_msg_pub.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
                    FND_MESSAGE.Set_Token('COLUMN', 'Shipment_Id', FALSE);
                    FND_MSG_PUB.ADD;
                end if;
                x_return_status := fnd_api.g_ret_sts_error;
                raise fnd_api.g_exc_error;
                */

            end if;

         end loop;

          if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp: After Creating the search tables '  ,1,'Y');
             aso_debug_pub.add('do_check_atp: l_shipment_search_tbl.count : '||l_shipment_search_tbl.count  ,1,'Y');
             aso_debug_pub.add('do_check_atp: l_qte_line_search_tbl.count : '||l_qte_line_search_tbl.count  ,1,'Y');
          end if;

             -- now honor the values that have been passed
           /*  for i in 1..p_qte_line_tbl.count loop
              for k in 1..l_qte_line_tbl.count loop
               if l_qte_line_tbl(k).quote_line_id = p_qte_line_tbl(i).quote_line_id then
                  l_qte_line_tbl(k) := p_qte_line_tbl(i);
               end if;
              end loop;
             end loop; */

               -- We need to honor values passed from UI in shipment tbl
               -- hence, values in l_shipment_tbl need to be overwritten if they are passed

              if p_shipment_tbl.count > 0 then

               for i in 1..p_shipment_tbl.count loop

                   if (p_shipment_tbl(i).shipment_id is null or p_shipment_tbl(i).shipment_id = fnd_api.g_miss_num) then
                      open c_shipment_id(p_qte_line_tbl(i).quote_line_id);
                      fetch c_shipment_id into l_shipment_id;
                      close c_shipment_id;
                   else
                      l_shipment_id := p_shipment_tbl(i).shipment_id;
                   end if;

                   if (l_shipment_search_tbl.exists(l_shipment_id)) then

                           -- get the index for the corresponding record in the l_shipment_tbl
					  -- this is so becoz the no of records in search tbl may not be
					  -- equal to the no of records in l_shipment_tbl, see bug 4665436
					  for k in 1..l_shipment_tbl.count loop
                               if (l_shipment_tbl(k).shipment_id = l_shipment_id)  then
                                  l_index := k;
						    exit;
						 end if;
					  end loop;

                          if aso_debug_pub.g_debug_flag = 'Y' then
                              aso_debug_pub.add('do_check_atp: Record found in shipment search tbl '  ,1,'Y');
                              aso_debug_pub.add('do_check_atp: l_shipment_tbl.count : '||l_shipment_tbl.count  ,1,'Y');
                              aso_debug_pub.add('do_check_atp: index is : '|| l_index ,1,'Y');
                           end if;

                           if p_shipment_tbl(i).ship_method_code <> fnd_api.g_miss_char then
                             l_shipment_tbl(l_index).ship_method_code := p_shipment_tbl(i).ship_method_code;
                           end if;

                           if p_shipment_tbl(i).demand_class_code <> fnd_api.g_miss_char then
                             l_shipment_tbl(l_index).demand_class_code := p_shipment_tbl(i).demand_class_code;
                           end if;

                           if p_shipment_tbl(i).ship_from_org_id <> fnd_api.g_miss_num then
                             l_shipment_tbl(l_index).ship_from_org_id := p_shipment_tbl(i).ship_from_org_id;
                           end if;

                           if p_shipment_tbl(i).request_date <> fnd_api.g_miss_date then
                             l_shipment_tbl(l_index).request_date := p_shipment_tbl(i).request_date;
                           end if;

                     end if; -- end if for shipment search tbl

                  end loop;  -- end loop for shipment tbl count
                 end if; -- end if for shipment tbl count

                 -- make sure variable gets reset
                 l_shipment_id := null;

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp:After honoring input and creating seacrh tbl  l_qte_line_tbl.count: ' || l_qte_line_tbl.count,1,'Y');
             aso_debug_pub.add('do_check_atp:After honoring input and creating seacrh tbl  l_shipment_tbl.count: ' || l_shipment_tbl.count,1,'Y');
             aso_debug_pub.add('do_check_atp: p_qte_line_tbl.count:        ' || p_qte_line_tbl.count,1,'Y');
             aso_debug_pub.add('do_check_atp: l_qte_line_search_tbl.count: ' || l_qte_line_search_tbl.count,1,'Y');
             aso_debug_pub.add('do_check_atp: l_check_atp_for_whole_quote: '|| l_check_atp_for_whole_quote, 1, 'Y');
         end if;

     if l_check_atp_for_whole_quote = fnd_api.g_false then

         --Add configured lines to input table if it is not passed
         for i in 1..p_qte_line_tbl.count loop

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('do_check_atp: p_qte_line_tbl('||i||').quote_line_id: ' || p_qte_line_tbl(i).quote_line_id,1,'Y');
            end if;

            for row in c_config_dtl(p_qte_line_tbl(i).quote_line_id) loop

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('do_check_atp: row.quote_line_id:            '||row.quote_line_id);
                    aso_debug_pub.add('do_check_atp: row.item_type_code:           '||row.item_type_code);
                    aso_debug_pub.add('do_check_atp: row.config_header_id:         '||row.config_header_id);
                    aso_debug_pub.add('do_check_atp: row.config_revision_num:      '||row.config_revision_num);
                    aso_debug_pub.add('do_check_atp: row.component_code:           '||row.component_code);
                    aso_debug_pub.add('do_check_atp: row.config_item_id:           '||row.config_item_id);
                    aso_debug_pub.add('do_check_atp: row.ref_line_id:              '||row.ref_line_id);
                    aso_debug_pub.add('do_check_atp: row.top_model_line_id:        '||row.top_model_line_id);
                    aso_debug_pub.add('do_check_atp: row.ato_line_id:              '||row.ato_line_id);
                    aso_debug_pub.add('do_check_atp: row.component_sequence_id:    '||row.component_sequence_id);
                    aso_debug_pub.add('do_check_atp: row.ship_model_complete_flag: '||row.ship_model_complete_flag);
                end if;

                if row.item_type_code in('MDL', 'CFG') and row.config_header_id is not null then

                   if not l_config_hdr_search_tbl.exists(row.config_header_id) then

                        if aso_debug_pub.g_debug_flag = 'Y' then
                            aso_debug_pub.add('do_check_atp: Inside not l_config_hdr_search_tbl.exists(row.config_header_id) cond.');
                        end if;

                        --If it is a non SMC PTO then do not add all the configuration lines from database if calling application is not passing

                        if nvl(row.ship_model_complete_flag, 'N') = 'Y' then

                            if aso_debug_pub.g_debug_flag = 'Y' then
                                aso_debug_pub.add('do_check_atp: Inside row.ship_model_complete_flag = Y cond: ');
                            end if;

                            --Add it to search table
                            --l_smc_search_tbl(row.top_model_line_id)       := l_ship_model_complete_flag;
                            l_config_hdr_search_tbl(row.config_header_id) := row.top_model_line_id;

                            if aso_debug_pub.g_debug_flag = 'Y' then
                                aso_debug_pub.add('do_check_atp: After adding to l_config_hdr_search_tbl.');
                            end if;

                            for k in c_configuration_rows(row.config_header_id, row.config_revision_num) loop

                               if aso_debug_pub.g_debug_flag = 'Y' then
                                   aso_debug_pub.add('do_check_atp: k.quote_line_id: ' || k.quote_line_id,1,'Y');
                                   aso_debug_pub.add('do_check_atp: k.shipment_id:   ' || k.shipment_id,1,'Y');
                               end if;

                               if not l_qte_line_search_tbl.exists(k.quote_line_id) then

                                   if aso_debug_pub.g_debug_flag = 'Y' then
                                       aso_debug_pub.add('Quote line id does not exist in l_qte_line_search_tbl, so add it to l_qte_line_tbl from database');
                                   end if;

                                   l_qte_line_rec := aso_utility_pvt.query_qte_line_row(k.quote_line_id);
                                   l_qte_line_tbl(l_qte_line_tbl.count + 1) := l_qte_line_rec;

                               end if;

                               if not l_shipment_search_tbl.exists(k.shipment_id) then

                                   if aso_debug_pub.g_debug_flag = 'Y' then
                                       aso_debug_pub.add('shipment id does not exist in l_shipment_search_tbl, so add it to l_shipment_tbl from database');
                                   end if;

                                   l_shipment_rec := aso_utility_pvt.query_shipment_row(k.shipment_id);
                                   l_shipment_rec.qte_line_index := l_qte_line_tbl.count;
                                   l_shipment_tbl(l_shipment_tbl.count + 1) := l_shipment_rec;

                               end if;

                            end loop;

                        elsif row.item_type_code = 'MDL' and row.ato_line_id is null then

		                  --This is a Non SMC PTO Model Line, so pass all the lines of this configuration to ATP

                            l_config_hdr_search_tbl(row.config_header_id) := row.top_model_line_id;

                            if aso_debug_pub.g_debug_flag = 'Y' then
                                aso_debug_pub.add('do_check_atp: After adding to l_config_hdr_search_tbl: ');
                            end if;

                            for k in c_configuration_rows(row.config_header_id, row.config_revision_num) loop

                               if aso_debug_pub.g_debug_flag = 'Y' then
                                   aso_debug_pub.add('do_check_atp: k.quote_line_id: ' || k.quote_line_id,1,'Y');
                                   aso_debug_pub.add('do_check_atp: k.shipment_id:   ' || k.shipment_id,1,'Y');
                               end if;

                               if not l_qte_line_search_tbl.exists(k.quote_line_id) then

                                   if aso_debug_pub.g_debug_flag = 'Y' then
                                       aso_debug_pub.add('Quote line id does not exist in l_qte_line_search_tbl, so add it to l_qte_line_tbl from database');
                                   end if;

                                   l_qte_line_rec := aso_utility_pvt.query_qte_line_row(k.quote_line_id);
                                   l_qte_line_tbl(l_qte_line_tbl.count + 1) := l_qte_line_rec;

                               end if;

                               if not l_shipment_search_tbl.exists(k.shipment_id) then

                                   if aso_debug_pub.g_debug_flag = 'Y' then
                                       aso_debug_pub.add('shipment id does not exist in l_shipment_search_tbl, so add it to l_shipment_tbl from database');
                                   end if;

                                   l_shipment_rec := aso_utility_pvt.query_shipment_row(k.shipment_id);
                                   l_shipment_rec.qte_line_index := l_qte_line_tbl.count;
                                   l_shipment_tbl(l_shipment_tbl.count + 1) := l_shipment_rec;

                               end if;

                            end loop;

                        elsif row.ato_line_id is not null then

                            if aso_debug_pub.g_debug_flag = 'Y' then
                                aso_debug_pub.add('do_check_atp: Inside row.ato_line_id is not null condition.');
                                aso_debug_pub.add('do_check_atp: row.ato_line_id: ' || row.ato_line_id);
                            end if;

                            --This line is a Model or component of a ATO configuration under the non smc PTO model
                            --OR the root ATO model line
                            --Add complete ATO configuration to input quote line and shipment table

                            if not l_ato_line_id_tbl.exists(row.ato_line_id) then

                                if aso_debug_pub.g_debug_flag = 'Y' then
                                    aso_debug_pub.add('do_check_atp: Inside row.ato_line_id does not exist in search tbl.');
                                end if;

                                if row.item_type_code = 'MDL' then
                                    l_config_hdr_search_tbl(row.config_header_id) := row.top_model_line_id;
                                end if;

                                for k in c_ato_rows(row.config_header_id, row.config_revision_num, row.ato_line_id) loop

                                    if aso_debug_pub.g_debug_flag = 'Y' then
                                        aso_debug_pub.add('do_check_atp: k.quote_line_id: ' || k.quote_line_id,1,'Y');
                                        aso_debug_pub.add('do_check_atp: k.shipment_id:   ' || k.shipment_id,1,'Y');
                                    end if;

                                    if not l_qte_line_search_tbl.exists(k.quote_line_id) then

                                        if aso_debug_pub.g_debug_flag = 'Y' then
                                            aso_debug_pub.add('Quote line id does not exist in l_qte_line_search_tbl, so add it to l_qte_line_tbl from database');
                                        end if;

                                        l_qte_line_rec := aso_utility_pvt.query_qte_line_row(k.quote_line_id);
                                        l_qte_line_tbl(l_qte_line_tbl.count + 1) := l_qte_line_rec;

                                    end if;

                                    if not l_shipment_search_tbl.exists(k.shipment_id) then

                                        if aso_debug_pub.g_debug_flag = 'Y' then
                                            aso_debug_pub.add('shipment id does not exist in l_shipment_search_tbl, so add it to l_shipment_tbl from database');
                                        end if;

                                        l_shipment_rec := aso_utility_pvt.query_shipment_row(k.shipment_id);
                                        l_shipment_rec.qte_line_index := l_qte_line_tbl.count;
                                        l_shipment_tbl(l_shipment_tbl.count + 1) := l_shipment_rec;

                                    end if;

                                end loop;

                                l_ato_line_id_tbl(row.ato_line_id) := row.ato_line_id;

                            end if;   --if not l_ato_line_id_tbl.exists(row.ato_line_id)

                        end if;   --if nvl(l_ship_model_complete_flag, 'N') = 'Y'

                   end if;   --if not l_config_hdr_search_tbl.exists(row.config_header_id)

                end if;   --if row.item_type_code in('MDL', 'CFG') and row.config_header_id is not null

            end loop;   --for row in c_config_dtl(p_qte_line_tbl(i).quote_line_id) loop

         end loop;   --for i in 1..p_qte_line_tbl.count loop

	end if;   --l_check_atp_for_whole_quote = fnd_api.g_false


     /* Get profile value for ASO: ATP Use Sourcing Rules. If the value is null or 'N'
     then get l_ship_from_org_id from the profile ASO_SHIP_FROM_ORG_ID and pass the
     source_organization_id as the value of l_ship_from_org_id.
	*/

     l_use_sourcing_rule := fnd_profile.value(name => 'ASO_ATP_USE_SOURCING_RULE');

     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('do_check_atp: ASO: Use Sourcing Rule profile value is: '||l_use_sourcing_rule,1,'Y');
     end if;

     if l_use_sourcing_rule IS NULL OR l_use_sourcing_rule = 'N' then

         -- Get the value for Ship from org Id.
         l_ship_from_org_id := fnd_profile.value(name => 'ASO_SHIP_FROM_ORG_ID');

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp: ASO: Default Ship From Org profile value is: '||l_ship_from_org_id, 1, 'Y');
         end if;

     end if;

	if l_qte_line_tbl.count > 0 then

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp: Before call to aso_line_num_int.reset_line_num procedure', 1, 'Y');
         end if;

         aso_line_num_int.reset_line_num;
	    l_in_qte_line_number_tbl(1).quote_line_id := l_qte_line_tbl(1).quote_line_id;

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp: Before call to aso_line_num_int.aso_ui_line_number procedure', 1, 'Y');
         end if;

	    aso_line_num_int.aso_ui_line_number( p_in_Line_number_tbl   => l_in_qte_line_number_tbl,
	                                         x_out_line_number_tbl  => l_out_qte_line_number_tbl);


         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('do_check_atp: After call to aso_line_num_int.aso_ui_line_number procedure', 1, 'Y');
         end if;

	end if;



     /* Logic for ordering the output by UI Line Number */
     for i in 1..l_qte_line_tbl.count loop
         l_search_tbl(l_qte_line_tbl(i).quote_line_id) := i;
     end loop;

     open get_ordered_lines(p_qte_header_rec.quote_header_id);
     loop
     fetch get_ordered_lines into l_qte_line_id_from_bali;
     exit when get_ordered_lines%NOTFOUND;
       if l_search_tbl.exists(l_qte_line_id_from_bali) then
          l_new_qte_line_tbl(l_new_qte_line_tbl.count +1) := l_qte_line_tbl(l_search_tbl(l_qte_line_id_from_bali) );
          l_new_shipment_tbl(l_new_shipment_tbl.count + 1) := l_shipment_tbl(l_search_tbl(l_qte_line_id_from_bali) );
       end if;
     end loop;
     Close get_ordered_lines;

     l_qte_line_tbl := l_new_qte_line_tbl;
     l_shipment_tbl := l_new_shipment_tbl;

     /* End Logic for Ordering Output */

     -- if qte line tbl count is 0 that means quote has all service items or all trade-ins, then return
     if l_qte_line_tbl.count = 0 then
        x_return_status := fnd_api.g_ret_sts_success;
        return;
	end if;

     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('do_check_atp: ********************************************************', 1, 'Y');
         aso_debug_pub.add('do_check_atp: Printing the data in l_qte_line_tbl and l_shipment_tbl', 1, 'Y');
        for i in 1..l_qte_line_tbl.count loop
         aso_debug_pub.add('do_check_atp: l_qte_line_tbl('||i||').quote_line_id: '|| l_qte_line_tbl(i).quote_line_id, 1, 'Y');
        end loop;
	   for i in 1..l_shipment_tbl.count loop
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').ship_method_code: '|| l_shipment_tbl(i).ship_method_code, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').ship_from_org_id: '|| l_shipment_tbl(i).ship_from_org_id, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').demand_class_code: '|| l_shipment_tbl(i).demand_class_code, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').request_date: '|| l_shipment_tbl(i).request_date, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').quote_line_id: '|| l_shipment_tbl(i).quote_line_id, 1, 'Y');
	    aso_debug_pub.add('do_check_atp: l_shipment_tbl('||i||').shipment_id: '|| l_shipment_tbl(i).shipment_id, 1, 'Y');
        end loop;
        aso_debug_pub.add('do_check_atp: ********************************************************', 1, 'Y');
	end if;

	for i in 1 .. l_qte_line_tbl.count loop

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('do_check_atp: Before call to MSC_GLOBAL_ATP.EXTEND_ATP', 1, 'Y');
          END IF;

          MSC_ATP_GLOBAL.EXTEND_ATP(l_atp_rec, x_return_status, 1);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('do_check_atp: After call to MSC_GLOBAL_ATP.EXTEND_ATP: x_return_status: '||x_return_status);
          END IF;

          If x_return_status <> FND_API.G_RET_STS_SUCCESS Then

              IF x_return_status = FND_API.G_RET_STS_ERROR then
                  RAISE FND_API.G_EXC_ERROR;
              ELSE
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

          End if;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('do_check_atp: l_db_qte_line_rec.quote_line_i:       '|| ASO_ATP_INT.ATPQUERY);
              aso_debug_pub.add('l_qte_line_tbl('||i||').quote_line_id: '|| l_qte_line_tbl(i).quote_line_id);
          END IF;

		if l_check_atp_for_whole_quote = fnd_api.g_false then
              l_db_qte_line_rec := aso_utility_pvt.query_qte_line_row(l_qte_line_tbl(i).quote_line_id);
          else
		    l_db_qte_line_rec := l_qte_line_tbl(i);
          end if;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('do_check_atp: ASO_ATP_INT.ATPQUERY:    '|| ASO_ATP_INT.ATPQUERY);
              aso_debug_pub.add('do_check_atp: fnd_global.prog_appl_id: '|| fnd_global.prog_appl_id);
              aso_debug_pub.add('l_db_qte_line_rec.inventory_item_id:    '|| l_db_qte_line_rec.inventory_item_id);
              aso_debug_pub.add('l_db_qte_line_rec.quantity:             '|| l_db_qte_line_rec.quantity);
              aso_debug_pub.add('l_db_qte_line_rec.uom_code:             '|| l_db_qte_line_rec.uom_code);
              aso_debug_pub.add('l_db_qte_line_rec.organization_id:      '|| l_db_qte_line_rec.organization_id);
              aso_debug_pub.add('l_db_qte_line_rec.quote_header_id:      '|| l_db_qte_line_rec.quote_header_id);
          END IF;

          l_atp_rec.action(i)                     := ASO_ATP_INT.ATPQUERY;
	     l_atp_rec.calling_module(i)             := fnd_global.prog_appl_id;
          l_atp_rec.inventory_item_id(i)          := l_db_qte_line_rec.inventory_item_id;
          l_atp_rec.validation_org(i)             := l_db_qte_line_rec.organization_id;
          l_atp_rec.identifier(i)                 := l_db_qte_line_rec.quote_line_id;
          l_atp_rec.quantity_ordered(i)           := l_db_qte_line_rec.quantity;
          l_atp_rec.quantity_uom(i)               := l_db_qte_line_rec.uom_code;
          l_atp_rec.demand_source_header_id(i)    := l_db_qte_line_rec.quote_header_id;
          l_atp_rec.included_item_flag(i)         := 2;
        --l_atp_rec.cascade_model_info_to_comp(i) := 2;
	     l_atp_rec.line_number(i)                := aso_line_num_int.get_ui_line_number(l_db_qte_line_rec.quote_line_id);

          open  c_description(l_db_qte_line_rec.inventory_item_id, l_db_qte_line_rec.organization_id);
	     fetch c_description into l_atp_rec.inventory_item_name(i);
          close c_description;

		open  c_quote_number(l_db_qte_line_rec.quote_header_id);
          fetch c_quote_number into l_atp_rec.order_number(i), l_atp_rec.customer_id(i);
          close c_quote_number;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_atp_rec.order_number('||i||'): '|| l_atp_rec.order_number(i));
              aso_debug_pub.add('l_atp_rec.customer_id('||i||'):  '|| l_atp_rec.customer_id(i));
          END IF;


          If l_shipment_tbl.EXISTS(i) Then

              -- query the hdr shipment rec
		    l_hdr_shipment_tbl  := aso_utility_pvt.query_shipment_rows(p_qte_header_rec.quote_header_id,null);

		    if l_hdr_shipment_tbl.count > 0 then
		      l_hdr_shipment_rec := l_hdr_shipment_tbl(1);
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Header Shipment Request_date_type:  '|| l_hdr_shipment_rec.request_date_type );
                END IF;
		    end if;


		    if l_check_atp_for_whole_quote = fnd_api.g_false then
                  l_db_shipment_rec := aso_utility_pvt.query_shipment_row(l_shipment_tbl(i).shipment_id);
              else
		        l_db_shipment_rec := l_shipment_tbl(i);
              end if;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.add('do_check_atp: ****** Database shipment record has following data ******', 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.ship_method_code: '|| l_shipment_tbl(i).ship_method_code, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.ship_from_org_id: '|| l_shipment_tbl(i).ship_from_org_id, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.demand_class_code: '|| l_shipment_tbl(i).demand_class_code, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.request_date: '|| l_shipment_tbl(i).request_date, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.request_date_type: '|| l_shipment_tbl(i).request_date_type, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.quote_line_id: '|| l_shipment_tbl(i).quote_line_id, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: l_db_shipment_rec.shipment_id: '|| l_shipment_tbl(i).shipment_id, 1, 'Y');
	          aso_debug_pub.add('do_check_atp: ****** End of Database shipment record data ******', 1, 'Y');
              END IF;
		        -- fix for bug 4724470, over-riding the line req date type with the hdr record req date type
			   -- this is becoz req date type at line level is not supported and hence over-written
			   -- with the hdr value
                  l_db_shipment_rec.request_date_type := l_hdr_shipment_rec.request_date_type;




              if  l_shipment_tbl(i).ship_from_org_id is not null and l_shipment_tbl(i).ship_from_org_id <> fnd_api.g_miss_num then
                  l_atp_rec.source_organization_id(i) := l_shipment_tbl(i).ship_from_org_id;

              else

                  open c_get_ids( l_qte_line_tbl(i).quote_line_id );
                  fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
                  close c_get_ids;
                  -- if the line is an option under ATO
                  if (l_ato_line_id is not null and l_top_model_line_id is not null )then
                     -- check if record has been passed in , then honor that
                    open c_shipment_id(l_ato_line_id);
                    fetch c_shipment_id into l_shipment_id;
                    close c_shipment_id;
                    if (l_shipment_search_tbl.exists(l_shipment_id) and
                        ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id is not null) and
                         (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id <> fnd_api.g_miss_num))) then
                            l_atp_rec.source_organization_id(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id;
                    else
                      -- try to cascade database info from ATO Model
                       open c_get_warehouse(l_ato_line_id, l_qte_line_tbl(i).quote_header_id);
                       fetch  c_get_warehouse into l_cascade_ship_from_org_id;
                       close c_get_warehouse;
                       if l_cascade_ship_from_org_id is not null and l_cascade_ship_from_org_id <> fnd_api.g_miss_num then
                         l_atp_rec.source_organization_id(i) := l_cascade_ship_from_org_id;
                       else
                         -- try to cascade from top model
                         if l_ato_line_id <> l_top_model_line_id then
                           -- check if PTO Model record has been passed in , then honor that
                           open c_shipment_id(l_top_model_line_id);
                           fetch c_shipment_id into l_shipment_id;
                           close c_shipment_id;
                           if (l_shipment_search_tbl.exists(l_shipment_id) and
                               ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id is not null) and
                                (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id <> fnd_api.g_miss_num))) then
                            l_atp_rec.source_organization_id(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id;
                           else
                            open c_get_warehouse(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                            fetch  c_get_warehouse into l_cascade_ship_from_org_id;
                            close c_get_warehouse;
                            if l_cascade_ship_from_org_id is not null and l_cascade_ship_from_org_id <> fnd_api.g_miss_num then
                                  l_atp_rec.source_organization_id(i) := l_cascade_ship_from_org_id;
                            end if;
                           end if;
                          end if; -- ato and model are not same end if
                        end if;
                     end if; -- shipment tbl exists end if
                     -- if it as a option under an PTO Model
                  elsif  (l_ato_line_id is null and l_top_model_line_id is not null )then
                     open c_shipment_id(l_top_model_line_id);
                     fetch c_shipment_id into l_shipment_id;
                     close c_shipment_id;
                     if (l_shipment_search_tbl.exists(l_shipment_id) and
                         ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id is not null) and
                          (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id <> fnd_api.g_miss_num))) then
                         l_atp_rec.source_organization_id(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_from_org_id;
                     else
                          open c_get_warehouse(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                          fetch  c_get_warehouse into l_cascade_ship_from_org_id;
                          close c_get_warehouse;
                          if l_cascade_ship_from_org_id is not null and l_cascade_ship_from_org_id <> fnd_api.g_miss_num then
                             l_atp_rec.source_organization_id(i) := l_cascade_ship_from_org_id;
                          end if;
                     end if;
                  end if; -- ato line id and model line id not null end if

              end if;  -- original end if

              if l_atp_rec.source_organization_id(i) is null or l_atp_rec.source_organization_id(i) = fnd_api.g_miss_num  then
                if l_db_shipment_rec.ship_from_org_id is not null and l_db_shipment_rec.ship_from_org_id <> fnd_api.g_miss_num  then
                  l_atp_rec.source_organization_id(i) := l_db_shipment_rec.ship_from_org_id;
                else
                  if nvl(l_use_sourcing_rule,'N') = 'Y' then
                     l_atp_rec.source_organization_id(i) := null;
                  else
                     -- if after everything  it is still null, get value from profile
                     l_atp_rec.source_organization_id(i) := l_ship_from_org_id;
                  end if; -- check for profile
                end if;
              end if;


              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('l_atp_rec.source_organization_id('||i||'):    '|| l_atp_rec.source_organization_id(i));
                  aso_debug_pub.add('l_db_shipment_rec.request_date_type: '|| l_db_shipment_rec.request_date_type);
                  aso_debug_pub.add('l_shipment_tbl('||i||').request_date:         '|| l_shipment_tbl(i).request_date);
              end if;

		    if (l_db_shipment_rec.request_date_type is null or l_db_shipment_rec.request_date_type = 'SHIP'
		       or l_db_shipment_rec.request_date_type = fnd_api.g_miss_char) then

		        if ((l_shipment_tbl(i).request_date <> fnd_api.g_miss_date) and (l_shipment_tbl(i).request_date is not null)) then
                      l_atp_rec.requested_ship_date(i) := l_shipment_tbl(i).request_date;
			   else
                  open c_get_ids( l_qte_line_tbl(i).quote_line_id );
                  fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
                  close c_get_ids;
                   if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('l_ato_line_id:       '|| l_ato_line_id);
                      aso_debug_pub.add('l_top_model_line_id: '|| l_top_model_line_id);
                    end if;
                  -- if the line is an option under ATO
                  if (l_ato_line_id is not null and l_top_model_line_id is not null )then
                     -- check if record has been passed in , then honor that
                    open c_shipment_id(l_ato_line_id);
                    fetch c_shipment_id into l_shipment_id;
                    close c_shipment_id;
                    if (l_shipment_search_tbl.exists(l_shipment_id) and
                        ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date is not null) and
                         (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date<> fnd_api.g_miss_date))) then
                           if aso_debug_pub.g_debug_flag = 'Y' then
                             aso_debug_pub.add('getting the request date from input ');
                           end if;
                           l_atp_rec.requested_ship_date(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date;
                    else
                      -- try to cascade database info from ATO Model
                       open c_get_request_date(l_ato_line_id, l_qte_line_tbl(i).quote_header_id,'SHIP');
                       fetch  c_get_request_date into l_cascade_request_date;
                       close c_get_request_date;
                       if aso_debug_pub.g_debug_flag = 'Y' then
                           aso_debug_pub.add('l_cascade_request_date: '|| l_cascade_request_date );
                       end if;
                       if l_cascade_request_date  is not null and l_cascade_request_date  <> fnd_api.g_miss_date then
                         l_atp_rec.requested_ship_date(i)  := l_cascade_request_date;
                       else
                         -- try to cascade from top model
                         if l_ato_line_id <> l_top_model_line_id then
                           -- check if PTO Model record has been passed in , then honor that
                           open c_shipment_id(l_top_model_line_id);
                           fetch c_shipment_id into l_shipment_id;
                           close c_shipment_id;
                           if (l_shipment_search_tbl.exists(l_shipment_id) and
                               ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date is not null) and
                                (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date <> fnd_api.g_miss_date))) then
                             l_atp_rec.requested_ship_date(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date;
                           else
                            open c_get_request_date(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id,'SHIP');
                            fetch  c_get_request_date into l_cascade_request_date;
                            close c_get_request_date;
                            if l_cascade_request_date is not null and l_cascade_request_date <> fnd_api.g_miss_date then
                                  l_atp_rec.requested_ship_date(i) := l_cascade_request_date;
                            end if;
                           end if;
                          end if; -- ato and model are not same end if
                        end if;
                     end if; -- shipment tbl exists end if
                     -- if it as a option under an PTO Model
                  elsif  (l_ato_line_id is null and l_top_model_line_id is not null )then
                     open c_shipment_id(l_top_model_line_id);
                     fetch c_shipment_id into l_shipment_id;
                     close c_shipment_id;
                     if (l_shipment_search_tbl.exists(l_shipment_id) and
                         ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date  is not null) and
                          (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date <> fnd_api.g_miss_date))) then
                         l_atp_rec.requested_ship_date(i)  := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date ;
                     else
                          open c_get_request_date(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id,'SHIP');
                          fetch  c_get_request_date into l_cascade_request_date;
                          close c_get_request_date;
                          if l_cascade_request_date is not null and l_cascade_request_date <> fnd_api.g_miss_date then
                             l_atp_rec.requested_ship_date(i) :=  l_cascade_request_date;
                          end if;
                     end if;
                  end if; -- ato line id and model line id not null end if

                 end if;  -- original end if
                  -- even after trying to cascade value is null then get from db
			   if ( l_atp_rec.requested_ship_date(i) is null or l_atp_rec.requested_ship_date(i)  = fnd_api.g_miss_date) then
                    if ((l_db_shipment_rec.request_date is not null) and (l_db_shipment_rec.request_date <> fnd_api.g_miss_date)) then
                      l_atp_rec.requested_ship_date(i) := l_db_shipment_rec.request_date;
			     else

                      -- fix for bug 4724374 if db value is null get the value from the hdr record
                      if ( l_hdr_shipment_rec.request_date is not null and l_hdr_shipment_rec.request_date <> fnd_api.g_miss_date ) then
                        l_atp_rec.requested_ship_date(i) := l_hdr_shipment_rec.request_date;
                      else
                       if aso_debug_pub.g_debug_flag = 'Y' then
                           aso_debug_pub.add('Setting the request date to sysdate' );
                       end if;
				    l_atp_rec.requested_ship_date(i) := sysdate;
                      end if; -- end if for the hdr rec check
			     end if;
                  end if;
              elsif l_db_shipment_rec.request_date_type = 'ARRIVAL' then

		        if ((l_shipment_tbl(i).request_date <> fnd_api.g_miss_date) and (l_shipment_tbl(i).request_date is not null)) then
                      l_atp_rec.requested_arrival_date(i) := l_shipment_tbl(i).request_date;
			   else
                  open c_get_ids( l_qte_line_tbl(i).quote_line_id );
                  fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
                  close c_get_ids;
                  -- if the line is an option under ATO
                  if (l_ato_line_id is not null and l_top_model_line_id is not null )then
                     -- check if record has been passed in , then honor that
                    open c_shipment_id(l_ato_line_id);
                    fetch c_shipment_id into l_shipment_id;
                    close c_shipment_id;
                    if (l_shipment_search_tbl.exists(l_shipment_id) and
                        ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date is not null) and
                         (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date<> fnd_api.g_miss_date))) then
                            l_atp_rec.requested_arrival_date(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date;
                    else
                      -- try to cascade database info from ATO Model
                       open c_get_request_date(l_ato_line_id, l_qte_line_tbl(i).quote_header_id,'ARRIVAL');
                       fetch  c_get_request_date into l_cascade_request_date;
                       close c_get_request_date;
                       if l_cascade_request_date  is not null and l_cascade_request_date  <> fnd_api.g_miss_date then
                         l_atp_rec.requested_arrival_date(i)  := l_cascade_request_date;
                       else
                         -- try to cascade from top model
                         if l_ato_line_id <> l_top_model_line_id then
                           -- check if PTO Model record has been passed in , then honor that
                           open c_shipment_id(l_top_model_line_id);
                           fetch c_shipment_id into l_shipment_id;
                           close c_shipment_id;
                           if (l_shipment_search_tbl.exists(l_shipment_id) and
                               ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date is not null) and
                                (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date <> fnd_api.g_miss_date))) then
                             l_atp_rec.requested_arrival_date(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date;
                           else
                            open c_get_request_date(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id,'ARRIVAL');
                            fetch  c_get_request_date into l_cascade_request_date;
                            close c_get_request_date;
                            if l_cascade_request_date is not null and l_cascade_request_date <> fnd_api.g_miss_date then
                                  l_atp_rec.requested_arrival_date(i) := l_cascade_request_date;
                            end if;
                           end if;
                          end if; -- ato and model are not same end if
                        end if;
                     end if; -- shipment tbl exists end if
                     -- if it as a option under an PTO Model
                  elsif  (l_ato_line_id is null and l_top_model_line_id is not null )then
                     open c_shipment_id(l_top_model_line_id);
                     fetch c_shipment_id into l_shipment_id;
                     close c_shipment_id;
                     if (l_shipment_search_tbl.exists(l_shipment_id) and
                         ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date  is not null) and
                          (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date <> fnd_api.g_miss_date))) then
                         l_atp_rec.requested_arrival_date(i)  := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).request_date ;
                     else
                          open c_get_request_date(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id,'ARRIVAL');
                          fetch  c_get_request_date into l_cascade_request_date;
                          close c_get_request_date;
                          if l_cascade_request_date is not null and l_cascade_request_date <> fnd_api.g_miss_date then
                             l_atp_rec.requested_arrival_date(i) :=  l_cascade_request_date;
                          end if;
                     end if;
                  end if; -- ato line id and model line id not null end if

                 end if;  -- original end if
                  -- even after trying to cascade value is null then get from db
                  if ( l_atp_rec.requested_arrival_date(i) is null or l_atp_rec.requested_arrival_date(i)  = fnd_api.g_miss_date) then
                    if ((l_db_shipment_rec.request_date is not null) and (l_db_shipment_rec.request_date <> fnd_api.g_miss_date)) then
                      l_atp_rec.requested_arrival_date(i) := l_db_shipment_rec.request_date;
                    else
                      -- fix for bug 4724374
                      if ( l_hdr_shipment_rec.request_date is not null and l_hdr_shipment_rec.request_date <> fnd_api.g_miss_date) then
                        l_atp_rec.requested_arrival_date(i) := l_hdr_shipment_rec.request_date;
                      else
                        l_atp_rec.requested_arrival_date(i) := sysdate;
                      end if; -- end if for the hdr rec check
                    end if;
                  end if;


              end if;

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('l_shipment_tbl('||i||').ship_method_code: '|| l_shipment_tbl(i).ship_method_code);
              end if;

		    if (l_shipment_tbl(i).ship_method_code <> fnd_api.g_miss_char and l_shipment_tbl(i).ship_method_code is not null) then
                  l_atp_rec.ship_method(i) := l_shipment_tbl(i).ship_method_code;

              else
                  open c_get_ids( l_qte_line_tbl(i).quote_line_id );
                  fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
                  close c_get_ids;
                  -- if the line is an option under ATO
                  if (l_ato_line_id is not null and l_top_model_line_id is not null )then
                     -- check if record has been passed in , then honor that
                    open c_shipment_id(l_ato_line_id);
                    fetch c_shipment_id into l_shipment_id;
                    close c_shipment_id;
                    if (l_shipment_search_tbl.exists(l_shipment_id) and
                        ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code is not null) and
                         (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code<> fnd_api.g_miss_char))) then
                            l_atp_rec.ship_method(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code;
                    else
                      -- try to cascade database info from ATO Model
                       open c_get_ship_method(l_ato_line_id, l_qte_line_tbl(i).quote_header_id);
                       fetch  c_get_ship_method into l_cascade_ship_method_code;
                       close c_get_ship_method;
                       if l_cascade_ship_method_code is not null and l_cascade_ship_method_code<> fnd_api.g_miss_char then
                         l_atp_rec.ship_method(i) := l_cascade_ship_method_code;
                       else
                         -- try to cascade from top model
                         if l_ato_line_id <> l_top_model_line_id then
                           -- check if PTO Model record has been passed in , then honor that
                           open c_shipment_id(l_top_model_line_id);
                           fetch c_shipment_id into l_shipment_id;
                           close c_shipment_id;
                           if (l_shipment_search_tbl.exists(l_shipment_id) and
                               ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code is not null) and
                                (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code<> fnd_api.g_miss_char))) then
                            l_atp_rec.ship_method(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code;
                           else
                            open c_get_ship_method(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                            fetch  c_get_ship_method into l_cascade_ship_method_code;
                            close c_get_ship_method;
                            if l_cascade_ship_method_code is not null and l_cascade_ship_method_code<> fnd_api.g_miss_char then
                                  l_atp_rec.ship_method(i) := l_cascade_ship_method_code;
                            end if;
                           end if;
                          end if; -- ato and model are not same end if
                        end if;
                     end if; -- shipment tbl exists end if
                     -- if it as a option under an PTO Model
                  elsif  (l_ato_line_id is null and l_top_model_line_id is not null )then
                     open c_shipment_id(l_top_model_line_id);
                     fetch c_shipment_id into l_shipment_id;
                     close c_shipment_id;
                     if (l_shipment_search_tbl.exists(l_shipment_id) and
                         ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code is not null) and
                          (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code<> fnd_api.g_miss_char))) then
                         l_atp_rec.ship_method(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).ship_method_code;
                     else
                          open c_get_ship_method(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                          fetch  c_get_ship_method into l_cascade_ship_method_code;
                          close c_get_ship_method;
                          if l_cascade_ship_method_code is not null and l_cascade_ship_method_code<> fnd_api.g_miss_char then
                             l_atp_rec.ship_method(i) := l_cascade_ship_method_code;
                          end if;
                     end if;
                  end if; -- ato line id and model line id not null end if

              end if;  -- original end if

		    if l_atp_rec.ship_method(i) is null or l_atp_rec.ship_method(i) = fnd_api.g_miss_char then
                 if (l_db_shipment_rec.ship_method_code is not null and l_db_shipment_rec.ship_method_code <> fnd_api.g_miss_char)  then
		         l_atp_rec.ship_method(i) := l_db_shipment_rec.ship_method_code;
                 else
		        l_atp_rec.ship_method(i) := aso_shipment_pvt.get_ship_method_code(p_qte_header_id => l_qte_line_tbl(i).quote_header_id,
			                                                                      p_qte_line_id   => l_shipment_tbl(i).quote_line_id);
                 end if;
              end if;

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('l_shipment_tbl('||i||').demand_class_code: '|| l_shipment_tbl(i).demand_class_code);
              end if;



		    if (l_shipment_tbl(i).demand_class_code <> fnd_api.g_miss_char and l_shipment_tbl(i).demand_class_code is not null) then
                  l_atp_rec.demand_class(i) := l_shipment_tbl(i).demand_class_code;

              else
                  open c_get_ids( l_qte_line_tbl(i).quote_line_id );
                  fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
                  close c_get_ids;
                  -- if the line is an option under ATO
                  if (l_ato_line_id is not null and l_top_model_line_id is not null )then
                     -- check if record has been passed in , then honor that
                    open c_shipment_id(l_ato_line_id);
                    fetch c_shipment_id into l_shipment_id;
                    close c_shipment_id;
                    if (l_shipment_search_tbl.exists(l_shipment_id) and
                        ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code is not null) and
                         (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code<> fnd_api.g_miss_char))) then
                            l_atp_rec.demand_class(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code;
                    else
                      -- try to cascade database info from ATO Model
                       open c_get_demand_code(l_ato_line_id, l_qte_line_tbl(i).quote_header_id);
                       fetch  c_get_demand_code into l_cascade_demand_class_code;
                       close c_get_demand_code;
                       if l_cascade_demand_class_code is not null and l_cascade_demand_class_code<> fnd_api.g_miss_char then
                         l_atp_rec.demand_class(i) := l_cascade_demand_class_code;
                       else
                         -- try to cascade from top model
                         if l_ato_line_id <> l_top_model_line_id then
                           -- check if PTO Model record has been passed in , then honor that
                           open c_shipment_id(l_top_model_line_id);
                           fetch c_shipment_id into l_shipment_id;
                           close c_shipment_id;
                           if (l_shipment_search_tbl.exists(l_shipment_id) and
                               ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code is not null) and
                                (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code<> fnd_api.g_miss_char))) then
                            l_atp_rec.demand_class(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code;
                           else
                            open c_get_demand_code(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                            fetch  c_get_demand_code into l_cascade_demand_class_code;
                            close c_get_demand_code;
                            if l_cascade_demand_class_code is not null and l_cascade_demand_class_code<> fnd_api.g_miss_char then
                                  l_atp_rec.demand_class(i) := l_cascade_demand_class_code;
                            end if;
                           end if;
                          end if; -- ato and model are not same end if
                        end if;
                     end if; -- shipment tbl exists end if
                     -- if it as a option under an PTO Model
                  elsif  (l_ato_line_id is null and l_top_model_line_id is not null )then
                     open c_shipment_id(l_top_model_line_id);
                     fetch c_shipment_id into l_shipment_id;
                     close c_shipment_id;
                     if (l_shipment_search_tbl.exists(l_shipment_id) and
                         ((p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code is not null) and
                          (p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code<> fnd_api.g_miss_char))) then
                         l_atp_rec.demand_class(i) := p_shipment_tbl( l_shipment_search_tbl(l_shipment_id)).demand_class_code;
                     else
                          open c_get_demand_code(l_top_model_line_id, l_qte_line_tbl(i).quote_header_id);
                          fetch  c_get_demand_code into l_cascade_demand_class_code;
                          close c_get_demand_code;
                          if l_cascade_demand_class_code is not null and l_cascade_demand_class_code<> fnd_api.g_miss_char then
                             l_atp_rec.demand_class(i) := l_cascade_demand_class_code;
                          end if;
                     end if;
                  end if; -- ato line id and model line id not null end if

              end if;  -- original end if

              if l_atp_rec.demand_class(i) = fnd_api.g_miss_char or l_atp_rec.demand_class(i) is null then
                if (l_db_shipment_rec.demand_class_code is not null and l_db_shipment_rec.demand_class_code <> fnd_api.g_miss_char) then
		        l_atp_rec.demand_class(i) := l_db_shipment_rec.demand_class_code;
                else
		        l_atp_rec.demand_class(i) := aso_shipment_pvt.get_demand_class_code(p_qte_header_id => l_qte_line_tbl(i).quote_header_id,
			                                                                        p_qte_line_id   => l_shipment_tbl(i).quote_line_id);
                end if;
              end if;


              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('l_db_shipment_rec.ship_to_party_site_id:   '|| l_db_shipment_rec.ship_to_party_site_id);
                  aso_debug_pub.add('l_db_shipment_rec.ship_to_cust_account_id: '|| l_db_shipment_rec.ship_to_cust_account_id);
              end if;


		    if l_db_shipment_rec.ship_to_party_site_id is not null then
		        --l_atp_rec.customer_site_id(i) := l_db_shipment_rec.ship_to_party_site_id;
		        l_ship_to_party_site_id := l_db_shipment_rec.ship_to_party_site_id;
		    else
		        l_ship_to_party_site_id := aso_shipment_pvt.get_ship_to_party_site_id(
			                                                               p_qte_header_id => l_qte_line_tbl(i).quote_header_id,
			                                                               p_qte_line_id   => l_shipment_tbl(i).quote_line_id);
              end if;

		    if l_db_shipment_rec.ship_to_cust_account_id is not null then
		        l_ship_to_cust_account_id := l_db_shipment_rec.ship_to_cust_account_id;
		    else
		        l_ship_to_cust_account_id := aso_shipment_pvt.get_ship_to_cust_account_id(
			                                                               p_qte_header_id => l_qte_line_tbl(i).quote_header_id,
			                                                               p_qte_line_id   => l_shipment_tbl(i).quote_line_id);
              end if;

              if l_ship_to_party_site_id is not null and l_ship_to_cust_account_id is not null then

                  ASO_MAP_QUOTE_ORDER_INT.get_acct_site_uses ( p_party_site_id   =>  l_ship_to_party_site_id,
                                                               p_acct_site_type  =>  'SHIP_TO',
                                                               p_cust_account_id =>  l_ship_to_cust_account_id,
                                                               x_return_status   =>  x_return_status,
                                                               x_site_use_id     =>  lx_cust_acct_site_use_id );

                  if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('After call to ASO_MAP_QUOTE_ORDER_INT.get_acct_site_uses: x_return_status '|| x_return_status);
                      aso_debug_pub.add('lx_cust_acct_site_use_id: '|| lx_cust_acct_site_use_id);
                  end if;

                  l_atp_rec.customer_site_id(i) := lx_cust_acct_site_use_id;

              elsif l_ship_to_party_site_id is not null then

                  --UnComment this after you get the ATP patch
                  --l_atp_rec.ship_to_party_site_id(i) := l_ship_to_party_site_id;
                  null;

              else

                  l_atp_rec.customer_country(i)     :=  l_shipment_tbl(i).ship_to_country;
                  l_atp_rec.customer_state(i)       :=  l_shipment_tbl(i).ship_to_state;
                  l_atp_rec.customer_city(i)        :=  l_shipment_tbl(i).ship_to_city;
                  l_atp_rec.customer_postal_code(i) :=  l_shipment_tbl(i).ship_to_postal_code;

              end if;

           End If; --if shipment record exists


           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('After End if for shipment record exists');
           END IF;

           for j in c_config_dtl(l_qte_line_tbl(i).quote_line_id) loop

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('do_check_atp: l_qte_line_tbl('||i||').quote_line_id: '||l_qte_line_tbl(i).quote_line_id);
                  aso_debug_pub.add('do_check_atp: quote_line_id:            '||j.quote_line_id);
                  aso_debug_pub.add('do_check_atp: item_type_code:           '||j.item_type_code);
                  aso_debug_pub.add('do_check_atp: config_header_id:         '||j.config_header_id);
                  aso_debug_pub.add('do_check_atp: config_revision_num:      '||j.config_revision_num);
                  aso_debug_pub.add('do_check_atp: component_code:           '||j.component_code);
                  aso_debug_pub.add('do_check_atp: config_item_id:           '||j.config_item_id);
                  aso_debug_pub.add('do_check_atp: ref_line_id:              '||j.ref_line_id);
                  aso_debug_pub.add('do_check_atp: ato_line_id:              '||j.ato_line_id);
                  aso_debug_pub.add('do_check_atp: top_model_line_id:        '||j.top_model_line_id);
                  aso_debug_pub.add('do_check_atp: component_sequence_id:    '||j.component_sequence_id);
                  aso_debug_pub.add('do_check_atp: ship_model_complete_flag: '||j.ship_model_complete_flag);
              end if;

              if j.config_header_id is not null then

                  if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('j.config_header_id is not null. This is a configuration line.');
                  end if;

                  if nvl(j.ship_model_complete_flag, 'N') = 'Y' then
                      l_atp_rec.ship_set_name(i) := j.top_model_line_id;
                  end if;

                  l_atp_rec.ato_model_line_id(i)     := j.ato_line_id;
                  l_atp_rec.top_model_line_id(i)     := j.top_model_line_id;
                  l_atp_rec.parent_line_id(i)        := j.ref_line_id;
                  l_atp_rec.component_code(i)        := j.component_code;
                  l_atp_rec.component_sequence_id(i) := j.component_sequence_id;

              end if;

           end loop; -- End of c_config_dtl cursor loop

      End Loop; -- End of l_qte_line_tbl loop


	 --Print the input parameters to MRP call_atp procedure

      IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('After the qte line tbl loop ');

          if l_atp_rec.identifier IS NOT NULL then

              for i in l_atp_rec.identifier.FIRST .. l_atp_rec.identifier.LAST loop

                  if l_atp_rec.identifier.EXISTS(i) then

	                 aso_debug_pub.add('do_check_atp: l_atp_rec.identifier('||i||'):              '|| l_atp_rec.identifier(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.parent_line_id('||i||'):          '|| l_atp_rec.parent_line_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.top_model_line_id('||i||'):       '|| l_atp_rec.top_model_line_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.ato_model_line_id('||i||'):       '|| l_atp_rec.ato_model_line_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.component_code('||i||'):          '|| l_atp_rec.component_code(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.component_sequence_id('||i||'):   '|| l_atp_rec.component_sequence_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.ship_set_name('||i||'):           '|| l_atp_rec.ship_set_name(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.action('||i||'):                  '|| l_atp_rec.action(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.calling_module('||i||'):          '|| l_atp_rec.calling_module(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.inventory_item_id('||i||'):       '|| l_atp_rec.inventory_item_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.validation_org('||i||'):          '|| l_atp_rec.validation_org(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.quantity_ordered('||i||'):        '|| l_atp_rec.quantity_ordered(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.quantity_uom('||i||'):            '|| l_atp_rec.quantity_uom(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.demand_source_header_id('||i||'): '|| l_atp_rec.demand_source_header_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.customer_id('||i||'):             '|| l_atp_rec.customer_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.customer_site_id('||i||'):        '|| l_atp_rec.customer_site_id(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.ship_method('||i||'):             '|| l_atp_rec.ship_method(i));
	                 aso_debug_pub.add('do_check_atp: l_atp_rec.order_number('||i||'):            '|| l_atp_rec.order_number(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.source_organization_id('||i||'):  '|| l_atp_rec.source_organization_id(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.demand_class('||i||'):            '|| l_atp_rec.demand_class(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.requested_arrival_date('||i||'):  '|| l_atp_rec.requested_arrival_date(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.requested_ship_date('||i||'):     '|| l_atp_rec.requested_ship_date(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.customer_country('||i||'):     '|| l_atp_rec.customer_country(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.customer_state('||i||'):     '|| l_atp_rec.customer_state(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.customer_city('||i||'):     '|| l_atp_rec.customer_city(i));
                      aso_debug_pub.add('do_check_atp: l_atp_rec.customer_postal_code('||i||'):     '|| l_atp_rec.customer_postal_code(i));
                   end if;

              end loop;

          end if;

      END IF; -- end if for debug


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp: Before call to msc_atp_global.get_atp_session_id procedure',1,'Y');
      END IF;

	 MSC_ATP_GLOBAL.Get_ATP_Session_Id(l_session_id, x_return_status);

	 if x_return_status <> fnd_api.g_ret_sts_success then
          raise fnd_api.g_exc_unexpected_error;
      end if;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp: After call to msc_atp_global.get_atp_session_id procedure',1,'Y');
          aso_debug_pub.add('do_check_atp: Before call to mrp_atp_pub.call_atp procedure',1,'Y');
      END IF;

      MRP_ATP_PUB.CALL_ATP(l_session_id,
	                      l_atp_rec,
	                      l_atp_rec_out,
	                      l_atp_supply_demand,
                           l_atp_period,
	                      l_atp_details,
	                      x_return_status,
                           x_new_msg_data,
	                      x_msg_count);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp: After call to mrp_atp_pub.call_atp procedure',1,'Y');
          aso_debug_pub.add('do_check_atp: x_return_status: '|| x_return_status ,1,'Y');
          aso_debug_pub.add('Error msg: '||x_new_msg_data,1,'Y');
     END IF;

      if x_return_status <> fnd_api.g_ret_sts_success then
          raise fnd_api.g_exc_unexpected_error;
      end if;



      /* added new debug messages */

      if aso_debug_pub.g_debug_flag = 'Y' then

	     aso_debug_pub.add('do_check_atp:  Printing the atp_rec_out ',1,'Y');

          if l_atp_rec_out.inventory_item_id IS NOT NULL then

              for i in l_atp_rec_out.inventory_item_id.FIRST .. l_atp_rec_out.inventory_item_id.LAST loop

                  if l_atp_rec_out.inventory_item_id.EXISTS(i) then
                      aso_debug_pub.add('do_check_atp: l_atp_rec_out.inventory_item_id '|| l_atp_rec_out.inventory_item_id(i),1,'Y');
                  end if;

                  if l_atp_rec_out.identifier.EXISTS(i) then
                      aso_debug_pub.add('do_check_atp: l_atp_rec_out.identifier '|| l_atp_rec_out.identifier(i),1,'Y');
                  end if;

                  if l_atp_rec_out.Error_Code.EXISTS(i) then
                      aso_debug_pub.add('do_check_atp: l_atp_rec_out.Error_Code '|| l_atp_rec_out.Error_Code(i),1,'Y');
                  end if;

              end loop;

          end if;

      end if;   -- checking the debug flag if

      /*  end of new debug messages */

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp:Before calling populate_output_table' );
      END IF;

      populate_output_table(l_atp_rec_out,x_atp_tbl,x_return_status);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp:After calling populate_output_table: x_return_status: '|| x_return_status );
      END IF;

     --  Logic for ordering the output by UI Line Number
  /*   for i in 1..x_atp_tbl.count loop
         l_search_tbl(x_atp_tbl(i).Identifier) := i;
     end loop;

     open get_ordered_lines(p_qte_header_rec.quote_header_id);
     loop
     fetch get_ordered_lines into l_qte_line_id_from_bali;
     exit when get_ordered_lines%NOTFOUND;
       if l_search_tbl.exists(l_qte_line_id_from_bali) then
         x_new_atp_tbl(x_new_atp_tbl.count + 1) := x_atp_tbl( l_search_tbl(l_qte_line_id_from_bali) );
       end if;
     end loop;
     Close get_ordered_lines;

     --x_atp_tbl := null;
     x_atp_tbl := x_new_atp_tbl; */
     --  End Logic for Ordering Output

	 /*
      if l_check_atp_for_whole_quote = fnd_api.g_false then

	     for i in 1..p_qte_line_tbl.count loop

	         l_aso_atp_tbl(i) := x_atp_tbl(i);

          end loop;

	     x_atp_tbl := l_aso_atp_tbl;

      end if;
	 */


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('do_check_atp: END' );
      END IF;

      EXCEPTION

           WHEN FND_API.G_EXC_ERROR THEN
               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME        => L_API_NAME
                   ,P_PKG_NAME        => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                   ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT
                   ,X_MSG_COUNT       => X_MSG_COUNT
                   ,X_MSG_DATA        => X_MSG_DATA
                   ,X_RETURN_STATUS   => X_RETURN_STATUS);

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME        => L_API_NAME
                   ,P_PKG_NAME        => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                   ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT
                   ,X_MSG_COUNT       => X_MSG_COUNT
                   ,X_MSG_DATA        => X_MSG_DATA
                   ,X_RETURN_STATUS   => X_RETURN_STATUS);

           WHEN OTHERS THEN
               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME        => L_API_NAME
                   ,P_PKG_NAME        => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                   ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT
                   ,P_SQLCODE         => SQLCODE
                   ,P_SQLERRM         => SQLERRM
                   ,X_MSG_COUNT       => X_MSG_COUNT
                   ,X_MSG_DATA        => X_MSG_DATA
                   ,X_RETURN_STATUS   => X_RETURN_STATUS);

END do_check_atp;



PROCEDURE Check_ATP(
    P_Api_Version_Number         IN    NUMBER,
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    p_qte_header_rec             IN    ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_qte_line_tbl               IN    ASO_QUOTE_PUB.qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    p_shipment_tbl               IN    ASO_QUOTE_PUB.shipment_tbl_type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    p_entire_quote_flag          IN    VARCHAR2 := 'N',
    x_return_status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_atp_tbl                    OUT NOCOPY /* file.sql.39 change */   aso_atp_int.atp_tbl_typ)
AS
l_api_name            CONSTANT VARCHAR2(30) := 'Check_ATP' ;
l_api_version_number  CONSTANT NUMBER := 1.0;
l_session_id 	       number;
l_sysdate	            date;
l_atp_rec	            mrp_atp_pub.atp_rec_typ;
l_atp_rec_out	       mrp_atp_pub.atp_rec_typ;
l_atp_supply_demand   mrp_atp_pub.atp_supply_demand_typ;
l_atp_period          mrp_atp_pub.atp_period_typ;
l_atp_details         mrp_atp_pub.atp_details_typ;
l_null_aso_atp_typ    aso_atp_int.atp_rec_typ;
l_mrp_database_link   Varchar2(128);
l_statement           Varchar2(500);
l_ship_from_org_id    Number ;
l_profile_name        Varchar2(240);
l_customer_id         NUMBER;
l_cust_ship_site_id   NUMBER;
l_mrp_customer_id     NUMBER;
l_mrp_ship_site_id    NUMBER;
l_use_sourcing_rule   VARCHAR2(10);
l_file                VARCHAR2(200);

-- Cursor to check whether the customer exists in MRP collection.
CURSOR mrp_cust(p_customer_id NUMBER) is SELECT TP_ID
                   FROM   msc_tp_id_lid tp
                   WHERE  tp.SR_TP_ID = p_customer_id
                   AND    tp.PARTNER_TYPE = 2;

-- Cursor to check whether ship to site exists in MRP Collection.
CURSOR mrp_ship_site(p_customer_site_id NUMBER) IS
                   SELECT TP_SITE_ID
                   FROM   msc_tp_site_id_lid tpsite
                   WHERE  tpsite.SR_TP_SITE_ID = p_customer_site_id
                   AND    tpsite.PARTNER_TYPE = 2;

l_aps_version  number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CHECK_ATP_INT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

	 /*
      If p_qte_line_tbl.FIRST IS NULL or p_shipment_tbl.FIRST IS NULL Then
          Return;
      End IF;
	 */

      l_aps_version := MSC_ATP_GLOBAL.Get_APS_Version;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Check_atp : l_aps_version: '|| l_aps_version,1,'Y');
          aso_debug_pub.add('Check_atp : use sourcing rule is '||l_use_sourcing_rule,1,'Y');
      END IF;

      if l_aps_version = 10 then

         do_check_atp(
              P_Api_Version_Number   => 1.0,
              P_Init_Msg_List        => FND_API.G_FALSE,
              p_qte_header_rec       => p_qte_header_rec,
              p_qte_line_tbl         => p_qte_line_tbl,
              p_shipment_tbl         => p_shipment_tbl,
              p_entire_quote_flag    => p_entire_quote_flag,
		    x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data,
              x_atp_tbl              => x_atp_tbl);

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Check_atp :After calling do_check_atp',1,'Y');
             aso_debug_pub.add('Check_atp :x_return_status: '|| x_return_status ,1,'Y');
         END IF;


         if x_return_status = FND_API.G_RET_STS_ERROR then
             RAISE FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

     else


     Select MRP_ATP_SCHEDULE_TEMP_S.NextVal
     Into   l_session_id
     From   Dual;

/* Get profile value for ASO: ATP Use Sourcing Rules. If the value is null or 'N
' then get l_ship_from_org_id from the profile ASO_SHIP_FROM_ORG_ID and pass the
source_organization_id as the value of l_ship_from_org_id else get Default Custo
mer and site id for ATP and pass Source Organization id as null and a combinatio
n of customer and site id so that mrp api can use sourcing rules */

  l_use_sourcing_rule := fnd_profile.value(name => 'ASO_ATP_USE_SOURCING_RULE');

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Check_atp : use sourcing rule is '||l_use_sourcing_rule,1,'Y');
  END IF;

  IF l_use_sourcing_rule IS NULL OR l_use_sourcing_rule = 'N' THEN

    -- Get the value for Ship from org Id.
    l_ship_from_org_id := fnd_profile.value(name => 'ASO_SHIP_FROM_ORG_ID');
    If l_ship_from_org_id IS NULL Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         select  user_profile_option_name
         into   l_profile_name
         from   fnd_profile_options_vl
         where  profile_option_name = 'ASO_SHIP_FROM_ORG_ID';

         FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
         fnd_message.set_token('PROFILE', l_profile_name);
         FND_MSG_PUB.ADD;
      END IF;
      raise FND_API.G_EXC_ERROR;
    End If;

  ELSE
    -- Sourcing rule is 'Y' so get the default customer and site id.

    -- To get the Default Customer Id from profile ASO: Atp Default Customer
    l_customer_id := fnd_profile.value(name => 'ASO_ATP_DEFAULT_CUSTOMER_ID');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_atp: Default Customer Id from profile'||l_customer_id,1,'Y');
    END IF;

    IF l_customer_id IS NULL Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        select  user_profile_option_name
        into   l_profile_name
        from   fnd_profile_options_vl
        where  profile_option_name = 'ASO_ATP_DEFAULT_CUSTOMER_ID';

        FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
        fnd_message.set_token('PROFILE', l_profile_name);
        FND_MSG_PUB.ADD;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    -- To get the Default Customer Ship to site Id from profile ASO: Atp Default SHip to Site id.

    l_cust_ship_site_id:= fnd_profile.value(name => 'ASO_ATP_SHIP_TO_SITE_ID');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_atp : Default Customer Site Id from profile'||l_cust_ship_site_id);
    END IF;

    IF l_cust_ship_site_id IS NULL Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        select  user_profile_option_name
        into   l_profile_name
        from   fnd_profile_options_vl
        where  profile_option_name = 'ASO_ATP_SHIP_TO_SITE_ID';

        FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
        fnd_message.set_token('PROFILE', l_profile_name);
        FND_MSG_PUB.ADD;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  For curr_index IN p_qte_line_tbl.FIRST .. p_qte_line_tbl.LAST Loop
     If p_qte_line_tbl.EXISTS(curr_index) Then
       Extend_ATP(l_atp_rec, x_return_status);

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Check_Atp : Inventory Id for Atp is '||p_qte_line_tbl(curr_index).inventory_item_id);
       END IF;

       l_atp_rec.inventory_item_id(curr_index) := p_qte_line_tbl(curr_index).inventory_item_id;


       IF l_use_sourcing_rule IS NULL OR l_use_sourcing_rule = 'N' THEN
          l_atp_rec.source_organization_id(curr_index) := l_ship_from_org_id;
       ELSE
          -- Always pass null for source_organization_id. This will enable
          -- multi-org ATP
          l_atp_rec.source_organization_id(curr_index) := null;
       END IF;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Check_atp : Source Organization ID is '||l_atp_rec.source_organization_id(curr_index),1,'Y');
            aso_debug_pub.add('Check_atp : Organization ID is '||p_qte_line_tbl(curr_index).organization_id,1,'Y');
       END IF;

       l_atp_rec.organization_id(curr_index) :=
                             p_qte_line_tbl(curr_index).organization_id;
       l_atp_rec.identifier(curr_index) :=
                             p_qte_line_tbl(curr_index).quote_line_id;
       l_atp_rec.quantity_ordered(curr_index) :=
                             p_qte_line_tbl(curr_index).quantity;
       l_atp_rec.quantity_uom(curr_index) :=
                             p_qte_line_tbl(curr_index).uom_code ;

       If p_shipment_tbl.EXISTS(curr_index) Then
         l_atp_rec.requested_ship_date(curr_index) :=
                             p_shipment_tbl(curr_index).request_date;

	if p_shipment_tbl( curr_index ).ship_from_org_id is null
		or p_shipment_tbl( curr_index ).ship_from_org_id = FND_API.G_MISS_NUM then
		/* Changes for the Save Warehouse */

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Check_atp: Source Organization ID is '||l_atp_rec.source_organization_id(curr_index));
        END IF;

	  /* Need to pass customer id, ship to site id and ship method id only if
	  the use sourcing level profile is 'Yes' */

         IF l_use_sourcing_rule = 'Y' THEN
            IF p_shipment_tbl(curr_index).ship_to_cust_account_id is NOT NULL
              AND p_shipment_tbl(curr_index).ship_to_party_site_id is NOT NULL
            THEN
            -- Check whether Customer and site id exists in MRP Collection.

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Check_atp :Before checking for customer in mrp collection',1,'Y');
              END IF;

              open mrp_cust(p_shipment_tbl(curr_index).ship_to_cust_account_id);
              fetch mrp_cust into l_mrp_customer_id;
              close mrp_cust;

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Check_atp :After checking for customer in mrp collection',1,'Y');
              END IF;

              IF l_mrp_customer_id IS NOT NULL THEN

                 open mrp_ship_site(p_shipment_tbl(curr_index).ship_to_party_site_id);
                 fetch mrp_ship_site into l_mrp_ship_site_id;
                 close mrp_ship_site;

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Check_atp :After checking for cust site in mrp collection');
                 END IF;

                 IF l_mrp_ship_site_id IS NOT NULL THEN

			    IF aso_debug_pub.g_debug_flag = 'Y' THEN

                       aso_debug_pub.add('Check_atp :Real Customer id'||
			        p_shipment_tbl(curr_index).ship_to_cust_account_id||'
			        and site id'||p_shipment_tbl(curr_index).ship_to_party_site_id,1,'Y');

                   END IF;

                   l_atp_rec.customer_id(curr_index) := p_shipment_tbl(curr_index).ship_to_cust_account_id;
		         l_atp_rec.customer_site_id(curr_index) := p_shipment_tbl(curr_index).ship_to_party_site_id;
                 ELSE
                   -- Pass the default customer and site id from profiles.

			    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Check_atp :no data in MRP, use the default cust id '||l_customer_id ||' and ship site '||l_cust_ship_site_id,1,'Y');
                   END IF;

                   l_atp_rec.customer_id(curr_index)      := l_customer_id;
                   l_atp_rec.customer_site_id(curr_index) := l_cust_ship_site_id;

                 END IF;

               END IF;

            ELSE
               -- Pass the default customer and site id from profiles.
		     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Check_atp :cust and site id are null, use the default cust id '||l_customer_id ||' and ship site '||l_cust_ship_site_id,1,'Y');
               END IF;

               l_atp_rec.customer_id(curr_index) := l_customer_id;
               l_atp_rec.customer_site_id(curr_index) := l_cust_ship_site_id;
            END IF;

         END IF;-- for sourcing_rule = 'Y'

else

          l_atp_rec.Source_Organization_Id(curr_index) := p_shipment_tbl(curr_index).ship_from_org_id;
end if;

         l_atp_rec.ship_method(curr_index) := p_shipment_tbl(curr_index).ship_method_code;

       End If;

     --have to populate action code. waiting for a reply back from mrp.
     --for now i have defined a variable in the specification.
       l_atp_rec.action(curr_index) := ASO_ATP_INT.ATPQUERY;

	-- 02/06/2001 - bug1630636 (ashukla)
	-- populate the calling module. This is the application_id for
	-- Oracle Oracle Capture.

        -- 03/15/2001  - This should be populated from the application id
        -- in the environment, using fnd_global

	  l_atp_rec.calling_module(curr_index) := fnd_global.prog_appl_id;

     End If;
  End Loop;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Check_atp: Source Organization ID is '||l_atp_rec.source_organization_id(1));
             aso_debug_pub.add('Check_atp :Before calling mrp api ',1,'Y');
         END IF;

         MRP_ATP_PUB.CALL_ATP(l_session_id,
	                         l_atp_rec,
	                         l_atp_rec_out,
	                         l_atp_supply_demand,
                              l_atp_period,
	                         l_atp_details,
	                         x_return_status,
                              x_msg_data,
	                         x_msg_count);

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Check_atp :After calling mrp api',1,'Y');
             aso_debug_pub.add('Check_atp :x_return_status === '|| x_return_status ,1,'Y');
         END IF;

         If x_return_status <> FND_API.G_RET_STS_SUCCESS Then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         End if;

         populate_output_table(l_atp_rec_out,x_atp_tbl,x_return_status);

    end if;

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE      => SQLCODE
                  ,P_SQLERRM      => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Check_ATP;

PROCEDURE Check_ATP(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_line_tbl               IN   ASO_QUOTE_PUB.qte_line_tbl_type,
    p_shipment_tbl               IN   ASO_QUOTE_PUB.shipment_tbl_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_atp_tbl                    OUT NOCOPY /* file.sql.39 change */  aso_atp_int.atp_tbl_typ
)
IS

l_qte_header_rec   aso_quote_pub.qte_header_rec_type;

Begin
     x_return_status := fnd_api.g_ret_sts_success;
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_ATP_INT: Check_Atp Begin', 1, 'Y');
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

	if p_qte_line_tbl.count > 0 then
	   l_qte_header_rec.quote_header_id := p_qte_line_tbl(1).quote_header_id;
     end if;

     Check_Atp( P_Api_Version_Number   => P_Api_Version_Number,
                P_Init_Msg_List        => FND_API.G_FALSE,
                p_qte_header_rec       => l_qte_header_rec,
                p_qte_line_tbl         => p_qte_line_tbl,
                p_shipment_tbl         => p_shipment_tbl,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                x_atp_tbl              => x_atp_tbl);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Check_atp :After calling check_atp overloaded procedure',1,'Y');
         aso_debug_pub.add('Check_atp :x_return_status: '|| x_return_status ,1,'Y');
     END IF;

     EXCEPTION

           WHEN OTHERS THEN

                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('Check_Atp (not overloaded): Inside when others exception', 1, 'N');
                   END IF;

End Check_ATP;


PROCEDURE update_configuration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_qte_line_dtl_tbl           IN   ASO_QUOTE_PUB.qte_line_dtl_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

l_api_name             CONSTANT VARCHAR2(30) := 'update_configuration' ;
l_api_version_number   CONSTANT NUMBER := 1.0;
l_qte_line_dtl_tbl              ASO_QUOTE_PUB.qte_line_dtl_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;

Cursor get_line_details(l_qte_header_id NUMBER) IS
SELECT b.config_header_id,b.config_revision_num,b.quote_line_id
from aso_quote_lines_all a, aso_quote_line_details b
where a.quote_line_id = b.quote_line_id
and  a. quote_header_id = l_qte_header_id
and b.ref_line_id is null
and b.ref_type_code = 'CONFIG';

Cursor get_line_id(l_config_header_id Number,l_config_revision_num Number) IS
select a.quote_line_id
from aso_quote_lines_all a, aso_quote_line_details b
where a.quote_line_id = b.quote_line_id
and b.config_header_id = l_config_header_id
and b.config_revision_num = l_config_revision_num
and ref_type_code = 'CONFIG'
and ref_line_id is null;

Cursor get_no_of_lines(l_qte_header_id NUMBER) IS
select count(a.quote_line_id)
from aso_quote_lines_all a, aso_quote_line_details b
where a.quote_line_id = b.quote_line_id
and  a. quote_header_id = l_qte_header_id
and b.ref_line_id is null
and b.ref_type_code = 'CONFIG';


Cursor get_cz_data(l_config_header_id Number,l_config_revision_num Number) IS
select a.ato_config_item_id,b.quote_line_detail_id
from cz_config_details_v a, aso_quote_line_details b
where a.config_hdr_id = b.config_header_id
and a.config_rev_nbr = b.config_revision_num
and b.config_header_id = l_config_header_id
and b.config_revision_num = l_config_revision_num
order by b.bom_sort_order;

Cursor get_ato_line(l_config_header_id Number,l_config_revision_num Number,l_config_item_id Number) IS
select quote_line_id
from aso_quote_line_details
where config_header_id = l_config_header_id
and config_revision_num = l_config_revision_num
and config_item_id = l_config_item_id;

l_config_hdr_id   NUMBER;
l_config_rev_nbr   NUMBER;
l_qte_line_id  NUMBER;
l_count        NUMBER;
l_ato_item_id      NUMBER;
l_line_detail_id    NUMBER;
l_ato_line_id    NUMBER;
i                INTEGER;
Begin

     -- Standard Start of API savepoint
     SAVEPOINT UPDATE_CONFIGURATION_INT;

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('update_configuration: Begin');
     END IF;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

     x_return_status := fnd_api.g_ret_sts_success;
       -- check to see if the quote header info is missing
         if p_qte_header_rec.quote_header_id is null or p_qte_header_rec.quote_header_id = fnd_api.g_miss_num then

             if aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('p_qte_header_rec.quote_header_id is null');
             end if;

             if fnd_msg_pub.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_ALL_MISSING_PARAM');
                 FND_MESSAGE.Set_Token('API_NAME', 'UPDATE_CONFIGURATION', FALSE);
                 FND_MESSAGE.Set_Token('PARAMETER', 'p_qte_header_rec', FALSE);
                 FND_MSG_PUB.ADD;
             end if;
             x_return_status := fnd_api.g_ret_sts_error;
             raise fnd_api.g_exc_error;
          end if;


     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('update_configuration: p_qte_line_dtl_tbl.count: '|| p_qte_line_dtl_tbl.count, 1, 'Y');
     end if;

     if p_qte_line_dtl_tbl.count = 0  then

             OPEN get_line_details(p_qte_header_rec.quote_header_id);
		   loop
		   fetch get_line_details into l_config_hdr_id,l_config_rev_nbr,l_qte_line_id;
             exit when get_line_details%NOTFOUND;
             i := l_qte_line_dtl_tbl.count + 1;
		   l_qte_line_dtl_tbl(i).quote_line_id := l_qte_line_id;
		   l_qte_line_dtl_tbl(i).config_header_id  := l_config_hdr_id;
		   l_qte_line_dtl_tbl(i).config_revision_num := l_config_rev_nbr;
		   end loop;
		   close get_line_details;
     else
	  -- check to see if only the model lines are passed or not
	   open get_no_of_lines(p_qte_header_rec.quote_header_id);
	   fetch get_no_of_lines into l_count;
	   close get_no_of_lines;

	   if p_qte_line_dtl_tbl.count > l_count then
	        if fnd_msg_pub.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_ALL_MISSING_PARAM');
                 FND_MESSAGE.Set_Token('API_NAME', 'UPDATE_CONFIGURATION', FALSE);
                 FND_MESSAGE.Set_Token('PARAMETER', 'p_qte_line_dtl_tbl', FALSE);
                 FND_MSG_PUB.ADD;
             end if;
	   else
	      l_qte_line_dtl_tbl := p_qte_line_dtl_tbl;
        end if;

     end if;

     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('update_configuration: l_qte_line_dtl_tbl.count: '|| l_qte_line_dtl_tbl.count, 1, 'Y');
     end if;

 for i in 1..l_qte_line_dtl_tbl.count loop

   -- check to see if the qte line detail table is properly populated before processing the row
   if (((l_qte_line_dtl_tbl(i).config_header_id  is null) or (l_qte_line_dtl_tbl(i).config_header_id =  FND_API.G_MISS_NUM)) or
       ((l_qte_line_dtl_tbl(i).config_revision_num  is null) or (l_qte_line_dtl_tbl(i).config_revision_num =  FND_API.G_MISS_NUM))) then

               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_MISSING_COLUMN' );
                  FND_MESSAGE.Set_Token ('COLUMN' , '.config_header_id', FALSE );
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
   end if;

    if (l_qte_line_dtl_tbl(i).quote_line_id is null) or (l_qte_line_dtl_tbl(i).quote_line_id =  FND_API.G_MISS_NUM) then
      open get_line_id(l_qte_line_dtl_tbl(i).config_header_id,l_qte_line_dtl_tbl(i).config_revision_num);
      fetch get_line_id into l_qte_line_dtl_tbl(i).quote_line_id;
      close get_line_id;
   end if;

    open get_cz_data(l_qte_line_dtl_tbl(i).config_header_id,l_qte_line_dtl_tbl(i).config_revision_num);
    loop
       fetch get_cz_data into l_ato_item_id,l_line_detail_id;
       exit when get_cz_data%notfound;

         open get_ato_line(l_qte_line_dtl_tbl(i).config_header_id,l_qte_line_dtl_tbl(i).config_revision_num,l_ato_item_id);
         fetch get_ato_line into l_ato_line_id;
         close get_ato_line;

       update aso_quote_line_details
       set top_model_line_id = l_qte_line_dtl_tbl(i).quote_line_id,
           ato_line_id = nvl(l_ato_line_id,null)
       where quote_line_detail_id = l_line_detail_id;
    end loop;
    close get_cz_data;

 end loop;


    IF fnd_api.to_boolean (p_commit) THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Commiting the work',1,'N');
      END IF;
      COMMIT WORK;
    END IF;

   fnd_msg_pub.count_and_get(p_encoded => 'F',
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   for k in 1..x_msg_count loop
    x_msg_data := fnd_msg_pub.get(p_msg_index => k,
                                  p_encoded   => 'F');
   end loop;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('update_configuration: END' );
      END IF;


EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE      => SQLCODE
                  ,P_SQLERRM      => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End update_configuration;

End aso_atp_int;

/
