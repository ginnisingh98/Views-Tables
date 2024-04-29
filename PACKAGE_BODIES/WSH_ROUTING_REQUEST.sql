--------------------------------------------------------
--  DDL for Package Body WSH_ROUTING_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ROUTING_REQUEST" as
/* $Header: WSHRORQB.pls 120.1 2005/06/30 03:38:25 rahujain noship $ */

-- standard global constants
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_ROUTING_REQUEST';


--Constant are define for each field of Routing Request and
--Supplier Address book, which are use as an index for pl/sql table.

--Routing Request constant declaration begin
--For Header index 1 to 50 are reserved.
c_Supplier_name 		constant	number:= 1;
c_request_date 			constant	number:= 2;
c_request_number 		constant	number:= 3;
c_request_revision 		constant	number:= 4;


--For Delivery index 51 to 100 are reserved.
c_ship_from_add1 		constant	number:= 51;
c_ship_from_add2 		constant	number:= 52;
c_ship_from_add3 		constant	number:= 53;
c_ship_from_add4 		constant	number:= 54;
c_ship_from_city 		constant	number:= 55;
c_ship_from_state 		constant	number:= 56;
c_ship_from_county 		constant	number:= 57;
c_ship_from_country 		constant	number:= 58;
c_ship_from_province 		constant	number:= 59;
c_ship_from_postal_code 	constant	number:= 60;
c_ship_from_Code 		constant	number:= 61;
c_shipper_name			constant	number:= 62;
c_phone				constant	number:= 63;
c_email				constant	number:= 64;
c_number_of_containers 		constant	number:= 65;
c_del_total_weight 		constant	number:= 66;
c_del_weight_uom 		constant	number:= 67;
c_del_total_volume 		constant	number:= 68;
c_del_volume_uom 		constant	number:= 69;
c_remark 			constant	number:= 70;


--For Line index 101 to 150 are reserved.
c_po_header_number 	constant	number:= 101;
c_po_release_number 	constant	number:= 102;
c_po_line_number 	constant	number:= 103;
c_po_shipment_number 	constant	number:= 104;
c_po_operating_unit 	constant	number:= 105;
c_item_qty 		constant	number:= 106;
c_item_uom 		constant	number:= 107;
c_total_weight 		constant	number:= 108;
c_weight_uom 		constant	number:= 109;
c_total_volume 		constant	number:= 110;
c_volume_uom 		constant	number:= 111;
c_earliest_pickup_date 	constant	number:= 112;
c_latest_pickup_date 	constant	number:= 113;
--Routing Request constant declaration end

--Supplier Address Book constant declaration begin
--For Address Book index 200 to 250 are reserved.
cs_Supplier_name 		constant	number:= 201;
cs_ship_from_add1 		constant	number:= 202;
cs_ship_from_add2 		constant	number:= 203;
cs_ship_from_add3 		constant	number:= 204;
cs_ship_from_add4 		constant	number:= 205;
cs_ship_from_city 		constant	number:= 206;
cs_ship_from_state 		constant	number:= 207;
cs_ship_from_county 		constant	number:= 208;
cs_ship_from_country 		constant	number:= 209;
cs_ship_from_province 		constant	number:= 210;
cs_ship_from_postal_code 	constant	number:= 211;
cs_ship_from_Code 		constant	number:= 212;
cs_shipper_name			constant	number:= 213;
cs_phone			constant	number:= 214;
cs_email			constant	number:= 215;
cs_action			constant	number:= 216;
--Supplier Address Book constant declaration end

--PL/Sql table used to hold error messages.
g_error_tbl		tbl_var2000;

--File line number either of Routing Request or Supplier Address Book File.
g_file_line_number	number;

--Date format used to covert varchar to date.
g_date_format		varchar2(2000);

--Structure to hold validation attributes of Routing Request/Supplier Address Book fields.
TYPE Field_Validation_Type IS RECORD (
name			tbl_var2000, --name of field
requried          	tbl_var1,    --Y for Mandatory field else 'N'.
max_size		tbl_number,  --Maximum size of field.
supplied		tbl_var1     --Default 'N','Y' if field is a part of input file.
);

--Hold validation meta data for Routing Request/Supplier Address Book.
g_field	Field_Validation_Type;


-- Start of comments
-- API name : Create_Address_Record
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to create a blank address record of type Address_Rec_type.
-- Parameters :
-- IN:
--      p_index         IN 	Index where address record is to be created.
--      p_Address       IN OUT	Type Address_Rec_type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Address_Record(
               		p_index  	IN	NUMBER,
			p_Address  	IN OUT NOCOPY Address_Rec_type,
               		x_return_status OUT NOCOPY VARCHAR2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Address_Record';
l_return_status		varchar2(1);
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       p_address.supplier_name(p_index):= NULL;
       p_address.ship_from_address1(p_index):= NULL;
       p_address.ship_from_address2(p_index):= NULL;
       p_address.ship_from_address3(p_index):= NULL;
       p_address.ship_from_address4(p_index):= NULL;
       p_address.Ship_From_city(p_index):= NULL;
       p_address.Ship_From_state(p_index):= NULL;
       p_address.Ship_From_county(p_index):= NULL;
       p_address.Ship_From_country(p_index):= NULL;
       p_address.Ship_From_province(p_index):= NULL;
       p_address.Ship_From_postal_code(p_index):= NULL;
       p_address.Ship_From_code(p_index):= NULL;
       p_address.shipper_name(p_index):= NULL;
       p_address.phone(p_index):= NULL;
       p_address.email(p_index):= NULL;
       p_address.action(p_index):= NULL;
       p_address.error_flag(p_index):= 'N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_Address_Record;


-- Start of comments
-- API name : Create_Line_Record
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to create a blank routing request line record of type Line_Rec_type.
-- Parameters :
-- IN:
--      p_index         IN      Index where routing request line record is to be created.
--      p_line       	IN OUT  Type Line_Rec_type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Line_Record(
               		p_index  	IN	NUMBER,
			p_line  	IN OUT NOCOPY Line_Rec_type,
               		x_return_status OUT NOCOPY VARCHAR2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Line_Record';
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       p_line.Delivery_line_number(p_index):= NULL;
       p_line.po_header_number(p_index):= NULL;
       p_line.Po_Release_number(p_index):= NULL;
       p_line.PO_Line_number(p_index):= NULL;
       p_line.PO_Shipment_number(p_index):= NULL;
       p_line.Po_Operating_unit(p_index):= NULL;
       p_line.Item_quantity(p_index):= NULL;
       p_line.Item_uom(p_index):= NULL;
       p_line.weight(p_index):= NULL;
       p_line.Weight_uom(p_index):= NULL;
       p_line.volume(p_index):= NULL;
       p_line.volume_uom(p_index):= NULL;
       p_line.earliest_pickup_date(p_index):= NULL;
       p_line.Latest_pickup_date(p_index):= NULL;
       p_line.error_flag(p_index):= 'N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_Line_Record;


-- Start of comments
-- API name : Create_Delivery_Record
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to create a blank routing request delivery record of type delivery_Rec_type.
-- Parameters :
-- IN:
--      p_index         IN      Index where routing request delivery record is to be created.
--      p_delivery      IN OUT  Type delivery_Rec_type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Delivery_Record(
               		p_index  	IN	NUMBER,
			p_delivery  	IN OUT NOCOPY delivery_Rec_type,
               		x_return_status OUT NOCOPY VARCHAR2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Delivery_Record';
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       p_Delivery.Header_line_number(p_index):= NULL;
       p_Delivery.ship_from_address1(p_index):= NULL;
       p_Delivery.ship_from_address2(p_index):= NULL;
       p_Delivery.ship_from_address3(p_index):= NULL;
       p_Delivery.ship_from_address4(p_index):= NULL;
       p_Delivery.Ship_From_city(p_index):= NULL;
       p_Delivery.Ship_From_state(p_index):= NULL;
       p_Delivery.Ship_From_county(p_index):= NULL;
       p_Delivery.Ship_From_country(p_index):= NULL;
       p_Delivery.Ship_From_province(p_index):= NULL;
       p_Delivery.Ship_From_postal_code(p_index):= NULL;
       p_Delivery.Ship_From_code(p_index):= NULL;
       p_Delivery.shipper_name(p_index):= NULL;
       p_Delivery.phone(p_index):= NULL;
       p_Delivery.email(p_index):= NULL;
       p_Delivery.number_of_containers(p_index):= NULL;
       p_Delivery.total_weight(p_index):= NULL;
       p_Delivery.weight_uom(p_index):= NULL;
       p_Delivery.total_volume(p_index):= NULL;
       p_Delivery.volume_uom(p_index):= NULL;
       p_Delivery.remark(p_index):= NULL;
       p_Delivery.error_flag(p_index):= 'N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_Delivery_Record;


-- Start of comments
-- API name : Create_Header_Record
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to create a blank routing request header record of type Header_Rec_type.
-- Parameters :
-- IN:
--      p_index         IN      Index where routing request delivery record is to be created.
--      p_header        IN OUT  Type Header_Rec_type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Header_Record(
               		p_index  	IN	NUMBER,
			p_header  	IN OUT NOCOPY Header_Rec_type,
               		x_return_status OUT NOCOPY VARCHAR2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Create_Header_Record';
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       p_header.Supplier_name(p_index):= NULL;
       p_header.Request_date(p_index):= NULL;
       p_header.Request_Number(p_index):= NULL;
       p_header.request_revision(p_index):= NULL;
       p_header.error_flag(p_index):= 'N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_Header_Record;


-- Start of comments
-- API name : Is_All_Line_Error
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to determine consolidates status of input table of status for
--            multiple records. The consolidates status is
--            1.ERROR:If all the lines are errors.
--            2.WARNING:If error line is more than one and less than total
--              lines.
--            3.SUCCESS:If none of line is error.
-- Parameters :
-- IN:
--      p_error_tbl     IN      	Table of error status of routing request deliveries/address lines.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Is_All_Line_Error(p_error_tbl		IN	tbl_var1,
               		    x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Is_All_Line_Error';

l_index		number;
l_count		number:=0;
l_error_count	number:=0;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_error_tbl.count',p_error_tbl.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


l_count := p_error_tbl.count;

--Loop through records to see the status.
l_index:= p_error_tbl.first;
WHILE (l_index IS NOT NULL) LOOP
    IF (p_error_tbl(l_index) = 'Y' ) THEN
       --Increment the error count if record is error.
       l_error_count := l_error_count + 1;
    END IF;

l_index:= p_error_tbl.next(l_index);
END LOOP;

IF (l_error_count >= l_count) THEN
   --If all the lines are Error.
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF ( l_error_count > 0 and l_error_count < l_count) THEN
   --If more then one line and less then total line count are Error.
   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_count',l_count);
    WSH_DEBUG_SV.log(l_module_name,'l_error_count',l_error_count);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;


EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Is_All_Line_Error;


-- Start of comments
-- API name : set_message
-- Type     : Private
-- Pre-reqs : None.
-- Function: API to get translated message from FND Message stack.Error Messages are first transfer from FND stack
--               to store in local table,so that error meesages can be appended to output message tabe to UI in sequence
--               of success then error messages.
-- Parameters :
-- IN:
--      p_product         IN    Product Code
--      p_msg_name        IN 	Message Code
-- RETURN:
--      Translated message from FND Message.
-- End of comments
FUNCTION set_message(p_product	varchar2,p_msg_name	varchar2) RETURN varchar2
IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'set_message';

l_msg		varchar2(2000);
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_msg_name',p_msg_name);
    WSH_DEBUG_SV.log(l_module_name,'p_product',p_product);
END IF;

--Set the message to FND stack, so that translation is taken care off.
FND_MESSAGE.SET_NAME(p_product, p_msg_name);
l_msg :=FND_MESSAGE.GET;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Message',l_msg);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN l_msg;

EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    raise ;
END set_message;



-- Start of comments
-- API name : add_time_to_date
-- Type     : Private
-- Pre-reqs : None.
-- Function: API to add time component to a date field when date field did have time component specified.
--           then add time of '00:00:00' elase if 'L' the '23:59:59' to date field.
-- Parameters :
-- IN:
--      p_date         IN    Input Date
--      p_type         IN    'F' add time '00:00:00' to date field
--                           'L' add time '23:59:59' to date field
-- RETURN:
--      Date with time component.
-- End of comments
FUNCTION add_time_to_date(p_date	date,p_type	varchar2) RETURN date
IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'add_time_to_date';

l_msg		varchar2(2000);
l_new_date	date;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_date',p_date);
    WSH_DEBUG_SV.log(l_module_name,'p_type',p_type);
END IF;

l_new_date := p_date;

IF (p_date - trunc(p_date) = 0 ) THEN
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Adding the time',p_date - trunc(p_date));
   END IF;

   IF (p_type='F') THEN
      l_new_date := to_date(to_char(p_date,'mm/dd/yyyy') || '00:00:00','mm/dd/yyyy HH24:MI:SS');
   ELSIF (p_type='L') THEN
      l_new_date := to_date(to_char(p_date,'mm/dd/yyyy') || '23:59:59','mm/dd/yyyy HH24:MI:SS');
   END IF;

END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_new_date',l_new_date);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN l_new_date;

EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    raise ;
END add_time_to_date;


-- Start of comments
-- API name : Get_message
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to get message from FND Stack and put in global message.
--            Error Messages are first transfer from FND stack
--            to store in local table,so that error meesages can be appended to output message tabe to UI in sequence
--            of success then error messages.
-- Parameters :
-- IN:
--     None
-- OUT:
--     None
-- End of comments
PROCEDURE Get_message IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Get_Message';
l_msg		varchar2(23767);

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Message Count:',FND_MSG_PUB.Count_Msg);
END IF;


IF (FND_MSG_PUB.Count_Msg > 0 ) THEN
--Loop through all the messages in stack.
FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
   l_msg :=  FND_MSG_PUB.get(i, FND_API.G_FALSE);
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Stack Message :',l_msg);
   END IF;

   --Collect the Translated message from FND stack.
   g_error_tbl(g_error_tbl.count + 1) := l_msg;
END LOOP;
END IF;

--Since message are collect from FND stack ,initialized the stack to avoid
--duplicate message being collected.
FND_MSG_PUB.initialize;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'After Init Message
Count:',FND_MSG_PUB.Count_Msg);
END IF;
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     g_error_tbl(g_error_tbl.count + 1) :=FND_MESSAGE.GET;
END Get_message;


-- Start of comments
-- API name : Init_Routing_Req_Validation
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to set the Routing Request validation parameters.
-- Parameters :
-- IN:
--      None
-- OUT:
--      None
-- End of comments
PROCEDURE Init_Routing_Req_Validation IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Init_Routing_Req_Validation';
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;

--For Header
g_field.name(c_Supplier_name):=set_message('FTE','FTE_RR_HDR_SUP_NAME');
g_field.requried(c_Supplier_name):='Y';
g_field.max_size(c_Supplier_name):=240;
g_field.supplied(c_Supplier_name):='N';

g_field.name(c_request_date):=set_message('FTE','FTE_RR_HDR_REQ_DATE');
g_field.requried(c_request_date):='Y';
g_field.max_size(c_request_date):=NULL;
g_field.supplied(c_request_date):='N';

g_field.name(c_request_number):=set_message('FTE','FTE_RR_HDR_REQ_NUM');
g_field.requried(c_request_number):='Y';
g_field.max_size(c_request_number):=30;
g_field.supplied(c_request_number):='N';

g_field.name(c_request_revision):=set_message('FTE','FTE_RR_HDR_REQ_REV');
g_field.requried(c_request_revision):='Y';
g_field.max_size(c_request_revision):=30;
g_field.supplied(c_request_revision):='N';
--For Header

  --For Delivery
g_field.name(c_ship_from_add1):=set_message('FTE','FTE_RR_DEL_SF_ADD1');
g_field.requried(c_ship_from_add1):='Y';
g_field.max_size(c_ship_from_add1):=240;
g_field.supplied(c_ship_from_add1):='N';

g_field.name(c_ship_from_add2):=set_message('FTE','FTE_RR_DEL_SF_ADD2');
g_field.requried(c_ship_from_add2):='N';
g_field.max_size(c_ship_from_add2):=240;
g_field.supplied(c_ship_from_add2):='N';

g_field.name(c_ship_from_add3):=set_message('FTE','FTE_RR_DEL_SF_ADD3');
g_field.requried(c_ship_from_add3):='N';
g_field.max_size(c_ship_from_add3):=240;
g_field.supplied(c_ship_from_add3):='N';

g_field.name(c_ship_from_add4):=set_message('FTE','FTE_RR_DEL_SF_ADD4');
g_field.requried(c_ship_from_add4):='N';
g_field.max_size(c_ship_from_add4):=240;
g_field.supplied(c_ship_from_add4):='N';

g_field.name(c_ship_from_city):=set_message('FTE','FTE_RR_DEL_CITY');
g_field.requried(c_ship_from_city):='N';
g_field.max_size(c_ship_from_city):=60;
g_field.supplied(c_ship_from_city):='N';

g_field.name(c_ship_from_state):=set_message('FTE','FTE_RR_DEL_STATE');
g_field.requried(c_ship_from_state):='N';
g_field.max_size(c_ship_from_state):=60;
g_field.supplied(c_ship_from_state):='N';

g_field.name(c_ship_from_county):=set_message('FTE','FTE_RR_DEL_COUNTY');
g_field.requried(c_ship_from_county):='N';
g_field.max_size(c_ship_from_county):=60;
g_field.supplied(c_ship_from_county):='N';

g_field.name(c_ship_from_country):=set_message('FTE','FTE_RR_DEL_COUNTRY');
g_field.requried(c_ship_from_country):='Y';
g_field.max_size(c_ship_from_country):=2;
g_field.supplied(c_ship_from_country):='N';

g_field.name(c_ship_from_province):=set_message('FTE','FTE_RR_DEL_PROVINCE');
g_field.requried(c_ship_from_province):='N';
g_field.max_size(c_ship_from_province):=60;
g_field.supplied(c_ship_from_province):='N';

g_field.name(c_ship_from_postal_code):=set_message('FTE','FTE_RR_DEL_POSTALCD');
g_field.requried(c_ship_from_postal_code):='N';
g_field.max_size(c_ship_from_postal_code):=60;
g_field.supplied(c_ship_from_postal_code):='N';

g_field.name(c_ship_from_code):=set_message('FTE','FTE_RR_DEL_SF_CODE');
g_field.requried(c_ship_from_code):='Y';
g_field.max_size(c_ship_from_code):=10;
g_field.supplied(c_ship_from_code):='N';

g_field.name(c_shipper_name):=set_message('FTE','FTE_RR_DEL_SHIPPER_NAME');
g_field.requried(c_shipper_name):='Y';
g_field.max_size(c_shipper_name):=240;
g_field.supplied(c_shipper_name):='N';

g_field.name(c_phone):=set_message('FTE','FTE_RR_DEL_PHONE');
g_field.requried(c_phone):='N';
g_field.max_size(c_phone):=40;
g_field.supplied(c_phone):='N';

g_field.name(c_email):=set_message('FTE','FTE_RR_DEL_EMAIL');
g_field.requried(c_email):='Y';
g_field.max_size(c_email):=500;
g_field.supplied(c_email):='N';


g_field.name(c_number_of_containers
):=set_message('FTE','FTE_RR_DEL_NUM_CONT');
g_field.requried(c_number_of_containers ):='N';
g_field.max_size(c_number_of_containers ):=30;
g_field.supplied(c_number_of_containers ):='N';

g_field.name(c_del_total_weight):=set_message('FTE','FTE_RR_DEL_TOT_WT');
g_field.requried(c_del_total_weight):='N';
g_field.max_size(c_del_total_weight):=30;
g_field.supplied(c_del_total_weight):='N';

g_field.name(c_del_weight_uom):=set_message('FTE','FTE_RR_DEL_WT_UOM');
g_field.requried(c_del_weight_uom):='N';
g_field.max_size(c_del_weight_uom):=3;
g_field.supplied(c_del_weight_uom):='N';

g_field.name(c_del_total_volume):=set_message('FTE','FTE_RR_DEL_TOT_VOL');
g_field.requried(c_del_total_volume):='N';
g_field.max_size(c_del_total_volume):=30;
g_field.supplied(c_del_total_volume):='N';

g_field.name(c_del_volume_uom):=set_message('FTE','FTE_RR_DEL_VOL_UOM');
g_field.requried(c_del_volume_uom):='N';
g_field.max_size(c_del_volume_uom):=3;
g_field.supplied(c_del_volume_uom):='N';

g_field.name(c_remark):=set_message('FTE','FTE_RR_DEL_REMARK');
g_field.requried(c_remark):='N';
g_field.max_size(c_remark):=500;
g_field.supplied(c_remark):='N';
--For Delivery


  --For Line
g_field.name(c_po_header_number):=set_message('FTE','FTE_RR_LINE_POHDR_NUM');
g_field.requried(c_po_header_number):='Y';
g_field.max_size(c_po_header_number):=20;
g_field.supplied(c_po_header_number):='N';

g_field.name(c_po_release_number):=set_message('FTE','FTE_RR_LINE_POREL_NUM');
g_field.requried(c_po_release_number):='N';
g_field.max_size(c_po_release_number):=38;
g_field.supplied(c_po_release_number):='N';

g_field.name(c_po_line_number):=set_message('FTE','FTE_RR_LINE_POLINE_NUM');
g_field.requried(c_po_line_number):='Y';
g_field.max_size(c_po_line_number):=38;
g_field.supplied(c_po_line_number):='N';

g_field.name(c_po_shipment_number):=set_message('FTE','FTE_RR_LINE_POSHIP_NUM');
g_field.requried(c_po_shipment_number):='Y';
g_field.max_size(c_po_shipment_number):=38;
g_field.supplied(c_po_shipment_number):='N';

g_field.name(c_po_operating_unit):=set_message('FTE','FTE_RR_LINE_POOPUNIT');
g_field.requried(c_po_operating_unit):='Y';
g_field.max_size(c_po_operating_unit):=240;
g_field.supplied(c_po_operating_unit):='N';

g_field.name(c_item_qty):=set_message('FTE','FTE_RR_LINE_ITEM_QTY');
g_field.requried(c_item_qty):='Y';
g_field.max_size(c_item_qty):=30;
g_field.supplied(c_item_qty):='N';

g_field.name(c_item_uom):=set_message('FTE','FTE_RR_LINE_ITEM_UOM');
g_field.requried(c_item_uom):='Y';
g_field.max_size(c_item_uom):=3;
g_field.supplied(c_item_uom):='N';

g_field.name(c_total_weight):=set_message('FTE','FTE_RR_LINE_TOT_WT');
g_field.requried(c_total_weight):='N';
g_field.max_size(c_total_weight):=30;
g_field.supplied(c_total_weight):='N';

g_field.name(c_weight_uom):=set_message('FTE','FTE_RR_DEL_WT_UOM');
g_field.requried(c_weight_uom):='N';
g_field.max_size(c_weight_uom):=3;
g_field.supplied(c_weight_uom):='N';

g_field.name(c_total_volume):=set_message('FTE','FTE_RR_LINE_TOT_VOL');
g_field.requried(c_total_volume):='N';
g_field.max_size(c_total_volume):=30;
g_field.supplied(c_total_volume):='N';

g_field.name(c_volume_uom):=set_message('FTE','FTE_RR_DEL_VOL_UOM');
g_field.requried(c_volume_uom):='N';
g_field.max_size(c_volume_uom):=3;
g_field.supplied(c_volume_uom):='N';

g_field.name(c_earliest_pickup_date):=set_message('FTE','FTE_RR_LINE_EPICKUP_DATE');
g_field.requried(c_earliest_pickup_date):='N';
g_field.max_size(c_earliest_pickup_date):=NULL;
g_field.supplied(c_earliest_pickup_date):='N';

g_field.name(c_latest_pickup_date):=set_message('FTE','FTE_RR_LINE_LPICKUP_DATE');
g_field.requried(c_latest_pickup_date):='N';
g_field.max_size(c_latest_pickup_date):=NULL;
g_field.supplied(c_latest_pickup_date):='N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    raise ;
END Init_Routing_Req_Validation;


-- Start of comments
-- API name : Init_Supplier_Validation
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to set the Supplier Address Book validation parameters.
-- Parameters :
-- IN:
--      None
-- OUT:
--      None
-- End of comments
PROCEDURE Init_Supplier_Validation IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Init_Supplier_Validation';
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;

g_field.name(cs_Supplier_name):=set_message('FTE','FTE_RR_HDR_SUP_NAME');
g_field.requried(cs_Supplier_name):='Y';
g_field.max_size(cs_Supplier_name):=240;
g_field.supplied(cs_Supplier_name):='N';

g_field.name(cs_ship_from_add1):=set_message('FTE','FTE_RR_DEL_SF_ADD1');
g_field.requried(cs_ship_from_add1):='Y';
g_field.max_size(cs_ship_from_add1):=240;
g_field.supplied(cs_ship_from_add1):='N';

g_field.name(cs_ship_from_add2):=set_message('FTE','FTE_RR_DEL_SF_ADD2');
g_field.requried(cs_ship_from_add2):='N';
g_field.max_size(cs_ship_from_add2):=240;
g_field.supplied(cs_ship_from_add2):='N';

g_field.name(cs_ship_from_add3):=set_message('FTE','FTE_RR_DEL_SF_ADD3');
g_field.requried(cs_ship_from_add3):='N';
g_field.max_size(cs_ship_from_add3):=240;
g_field.supplied(cs_ship_from_add3):='N';

g_field.name(cs_ship_from_add4):=set_message('FTE','FTE_RR_DEL_SF_ADD4');
g_field.requried(cs_ship_from_add4):='N';
g_field.max_size(cs_ship_from_add4):=240;
g_field.supplied(cs_ship_from_add4):='N';

g_field.name(cs_ship_from_city):=set_message('FTE','FTE_RR_DEL_CITY');
g_field.requried(cs_ship_from_city):='N';
g_field.max_size(cs_ship_from_city):=60;
g_field.supplied(cs_ship_from_city):='N';

g_field.name(cs_ship_from_state):=set_message('FTE','FTE_RR_DEL_STATE');
g_field.requried(cs_ship_from_state):='N';
g_field.max_size(cs_ship_from_state):=60;
g_field.supplied(cs_ship_from_state):='N';

g_field.name(cs_ship_from_county):=set_message('FTE','FTE_RR_DEL_COUNTY');
g_field.requried(cs_ship_from_county):='N';
g_field.max_size(cs_ship_from_county):=60;
g_field.supplied(cs_ship_from_county):='N';

g_field.name(cs_ship_from_country):=set_message('FTE','FTE_RR_DEL_COUNTRY');
g_field.requried(cs_ship_from_country):='Y';
g_field.max_size(cs_ship_from_country):=2;
g_field.supplied(cs_ship_from_country):='N';

g_field.name(cs_ship_from_province):=set_message('FTE','FTE_RR_DEL_PROVINCE');
g_field.requried(cs_ship_from_province):='N';
g_field.max_size(cs_ship_from_province):=60;
g_field.supplied(cs_ship_from_province):='N';

g_field.name(cs_ship_from_postal_code):=set_message('FTE','FTE_RR_DEL_POSTALCD');
g_field.requried(cs_ship_from_postal_code):='N';
g_field.max_size(cs_ship_from_postal_code):=60;
g_field.supplied(cs_ship_from_postal_code):='N';

g_field.name(cs_ship_from_code):=set_message('FTE','FTE_RR_DEL_SF_CODE');
g_field.requried(cs_ship_from_code):='Y';
g_field.max_size(cs_ship_from_code):=10;
g_field.supplied(cs_ship_from_code):='N';

g_field.name(cs_shipper_name):=set_message('FTE','FTE_RR_DEL_SHIPPER_NAME');
g_field.requried(cs_shipper_name):='Y';
g_field.max_size(cs_shipper_name):=240;
g_field.supplied(cs_shipper_name):='N';

g_field.name(cs_phone):=set_message('FTE','FTE_RR_DEL_PHONE');
g_field.requried(cs_phone):='N';
g_field.max_size(cs_phone):=40;
g_field.supplied(cs_phone):='N';

g_field.name(cs_email):=set_message('FTE','FTE_RR_DEL_EMAIL');
g_field.requried(cs_email):='Y';
g_field.max_size(cs_email):=500;
g_field.supplied(cs_email):='N';


g_field.name(cs_action ):=set_message('FTE','FTE_SAB_ACTION_CODE');
g_field.requried(cs_action ):='Y';
g_field.max_size(cs_action ):=30;
g_field.supplied(cs_action ):='N';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    raise ;
END Init_Supplier_Validation;


-- Start of comments
-- API name : Find_Miss_Column
-- Type     : Private
-- Pre-reqs : None.
-- Function : API to determine if any of column is missed in routing request/supplier address book file.
--            Api does
--            1.Determine the start and end index of global validation(g_field) table
--              based on level to find the missing column.
--            2.Loop through all the columns of level, if not supplied and mandatory field then error.
-- Parameters :
-- IN:
--      p_level  IN   Level number of routing request/supplier address book file.
--                    For Routing request File  1:Hedaer 2:Delivery and 3:Line
--                    For Supplier Address Book 11:Address Line
-- OUT:
--      Function returns boolean.
-- End of comments
FUNCTION Find_Miss_Column(p_level	number) RETURN boolean IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Find_Miss_Column';

l_find_miss_column	boolean:=false;
l_start_index		number;
l_end_index		number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_level',p_level);
END IF;

--Determine the start and end index of global validation(g_field) table based on level to find the missing column.
IF (p_level=1 ) THEN
    --Starting column of header
    l_start_index := c_Supplier_name;
    --End column of header
    l_end_index := c_request_revision;
ELSIF (p_level = 2 ) THEN
    --Starting column of delivery
    l_start_index := c_ship_from_add1;
    --End column of delivery
    l_end_index := c_remark;
ELSIF (p_level = 3 ) THEN
    --Starting column of line
    l_start_index := c_po_header_number;
    --End column of line.
    l_end_index := c_latest_pickup_date;
ELSIF (p_level = 11 ) THEN
    --Starting column of address line.
    l_start_index := cs_supplier_name;
    --End column of address line.
    l_end_index := cs_action;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_start_index',l_start_index);
    WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
END IF;

--Loop through all the columns of level,
--error if not supplied and mandatory field.
FOR i IN l_start_index..l_end_index LOOP
    IF (g_field.supplied(i) = 'N') THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Missing Column',g_field.name(i));
      END IF;

      IF (g_field.requried(i) = 'Y' ) THEN
          l_find_miss_column:= true;
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_MISS_COLUMN');
          FND_MESSAGE.SET_TOKEN('COL_NAME',g_field.name(i));
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',g_file_line_number);
          fnd_msg_pub.add;
      END IF;
    END IF;

    g_field.supplied(i):= 'N';
END LOOP;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
RETURN l_find_miss_column;

EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    raise;
END Find_Miss_Column;


-- Start of comments
-- API name : Is_field_valid
-- Type     : Private
-- Pre-reqs : None.
-- Function : API to determine if Routing Request/Supplier Address Book field satisfied all
--            the required validation as defined in tractions type meta data.
--
-- Parameters :
-- IN:
--      p_index  	IN   Index of global record g_field, where validation are defined.
--      p_field_value  	IN   Input value of field.
-- OUT:
--      Function returns boolean.
-- End of comments
FUNCTION Is_field_valid(p_index		NUMBER,
		     p_field_value	varchar2) RETURN boolean IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Is_field_valid';
l_status	boolean := true;
--vendor merge changes
l_field_value VARCHAR2(32767);
l_position    NUMBER;
l_tmp_value VARCHAR2(32767);
l_dummy NUMBER;
--

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
    WSH_DEBUG_SV.log(l_module_name,'p_field_value',p_field_value);
    WSH_DEBUG_SV.log(l_module_name,'p_field_value size',length(p_field_value));
END IF;

--This field is part of Routing Request /Supplier Address Book file.
g_field.supplied(p_index):='Y';

--Required and not null field.
IF (nvl(g_field.requried(p_index),'N') = 'Y' and p_field_value IS NULL )
THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_RR_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(p_index));
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',g_file_line_number);
    fnd_msg_pub.add;

    l_status := false;
END IF;
--vendor merge changes {
l_field_value := p_field_value;

IF p_index IN ( c_request_number, c_ship_from_code )
AND (length(l_field_value) > g_field.max_size(p_index) )
THEN
--{
    l_position := INSTRB(l_field_value,'-VM',-1);

    IF l_position > 0
    THEN
    --{
	--
        l_tmp_value   := SUBSTRB(l_field_value,l_position);
	--
	IF  SUBSTRB(l_tmp_value,1,1) = '-'
	AND SUBSTRB(l_tmp_value,2,1) = 'V'
	AND SUBSTRB(l_tmp_value,3,1) = 'M'
	THEN
	    l_field_value := SUBSTRB(l_field_value,1,l_position-1);
	    BEGIN
		--
	        l_dummy := to_number( SUBSTRB(l_tmp_value,4) );
		--
		IF length(l_dummy) <> 3
		THEN
		   l_field_value := p_field_value;
		END IF;
            EXCEPTION
	        WHEN OTHERS THEN
		   l_field_value := p_field_value;
	    END;
	END IF;
    --}
    END IF;
--}
END IF;
--vendor merge changes }
--Field excide max size.
--This check is not required for date field,
--where g_field.max_size(p_index) will be null
IF ( g_field.max_size(p_index) IS NOT NULL
      AND (length(l_field_value) > g_field.max_size(p_index)) ) THEN

    FND_MESSAGE.SET_NAME('WSH','WSH_RR_EXC_SIZE');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(p_index));
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',g_file_line_number);
    fnd_msg_pub.add;

    l_status := false;
END IF;



IF l_debug_on THEN

    WSH_DEBUG_SV.log(l_module_name,'l_field_value',l_field_value);
    IF l_status THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Field Valid TRUE');
    ELSE
       WSH_DEBUG_SV.logmsg(l_module_name,'Field Valid FALSE');
    END IF;

    WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN l_status;
EXCEPTION
WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    RETURN false;
END Is_field_valid;


-- Start of comments
-- API name : Process_Address_Line
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create address line record. Api does
--            1.Column name of field is reference against validation meta
--              data.
--            2.Call api Is_field_valid to validated a field.
--            3.Assign validate field to address line record.
--
-- Parameters :
-- IN:
--      p_col_name   IN  Column Name of field.
--      p_col_value  IN  Value of field.
--      p_index      IN  Index of global record g_field, where validation are defined.
--      p_address    IN  Record of type Address_Rec_Type to hold address line information.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Address_Line(
        p_col_name   	IN  varchar2,
        p_col_value	IN  varchar2,
	p_index		IN  number,
        p_address   	IN  OUT NOCOPY  Address_Rec_Type,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Process_Address_Line';

l_error	boolean:=false;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (p_col_name = g_field.name(cs_supplier_name) ) THEN
    IF (Is_field_valid(cs_supplier_name,p_col_value))THEN
       p_address.supplier_name(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_ship_from_add1) ) THEN
    IF (Is_field_valid(cs_ship_from_add1,p_col_value))THEN
       p_address.ship_from_address1(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_ship_from_add2) ) THEN
    IF (Is_field_valid(cs_ship_from_add2,p_col_value))THEN
       p_address.ship_from_address2(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_ship_from_add3) ) THEN
    IF (Is_field_valid(cs_ship_from_add3,p_col_value))THEN
       p_address.ship_from_address3(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_ship_from_add4 )) THEN
    IF (Is_field_valid(cs_ship_from_add4,p_col_value))THEN
       p_address.ship_from_address4(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_city )) THEN
    IF (Is_field_valid(cs_Ship_From_city,p_col_value))THEN
       p_address.Ship_From_city(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_state)) THEN
    IF (Is_field_valid(cs_Ship_From_state,p_col_value))THEN
       p_address.Ship_From_state(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_county)) THEN
    IF (Is_field_valid(cs_Ship_From_county,p_col_value))THEN
       p_address.Ship_From_county(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_country)) THEN
    IF (Is_field_valid(cs_Ship_From_country,p_col_value))THEN
       p_address.Ship_From_country(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_province)) THEN
    IF (Is_field_valid(cs_Ship_From_province,p_col_value))THEN
       p_address.Ship_From_province(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_postal_code)) THEN
    IF (Is_field_valid(cs_Ship_From_postal_code,p_col_value))THEN
       p_address.Ship_From_postal_code(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_Ship_From_code)) THEN
    IF (Is_field_valid(cs_Ship_From_code,p_col_value))THEN
       p_address.Ship_From_code(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_shipper_name)) THEN
    IF (Is_field_valid(cs_shipper_name,p_col_value))THEN
       p_address.shipper_name(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_phone)) THEN
    IF (Is_field_valid(cs_phone,p_col_value))THEN
       p_address.phone(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_email)) THEN
    IF (Is_field_valid(cs_email,p_col_value))THEN
       p_address.email(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(cs_action)) THEN
    IF (Is_field_valid(cs_action,p_col_value))THEN
       p_address.action(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (l_error) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_FIELD');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME', p_col_name);
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_index);
    fnd_msg_pub.add;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;


END Process_Address_Line;



-- Start of comments
-- API name : Process_Address_File
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create address line record from input of Supplier Address
--             book record as passed by UI. Api does.
--            1.Create blank address record of type Address_Rec_Type.
--            2.Loop through address record as pass by Supplier address book UI.
--            3.Validate and assign field value to type Address_Rec_Type.
--            4.Scan through record created to find missing column.
--            5.Check if not all the records have errors..
--            6.Finally call api WSH_SUPPLIER_PARTY.Process_Address to process
--              address book records.
-- Parameters :
-- IN:
--      p_in_param   	IN  Hold additional parameter passed by UI.
--      p_file_fields   IN  Hold Supplier Address book record as passed by UI
-- OUT:
--      x_message_tbl   OUT NOCOPY List of Success/Error messages passed back to UI for display.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Address_File(
        p_in_param	IN In_Param_Rec_Type,
        p_file_fields   IN WSH_FILE_RECORD_TYPE ,
        x_message_tbl   OUT  NOCOPY  WSH_FILE_MSG_TABLE,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Address_File';
l_return_status	varchar2(1);
l_index	number;
l_hi	number;
l_debugfile	varchar2(2000);
l_msg_count 	number:=0;
l_error_count	number:=0;
l_last_index	number;

l_prev_line_number	number;
l_Address		Address_Rec_Type;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);

WSH_DEBUG_SV.log(l_module_name,'p_file_fields.level_number.count',p_file_fields.level_number.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Initilized message and validation meta data.
x_message_tbl := WSH_FILE_MSG_TABLE();
g_error_tbl.delete;
Init_Supplier_Validation;

l_last_index :=p_file_fields.level_number.last;
l_index := p_file_fields.level_number.first;
l_prev_line_number:= p_file_fields.file_line_number(l_index);

--Create blank address record.
Create_Address_Record(p_address   =>l_address,
               p_index          =>l_prev_line_number,
               x_return_status  =>l_return_status);

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
   raise FND_API.G_EXC_ERROR;
END IF;

WHILE (l_index IS NOT NULL ) LOOP --{
   g_file_line_number := p_file_fields.file_line_number(l_index);

   --Create new record only ,when line number change.
   IF ( l_prev_line_number <> g_file_line_number ) THEN

      Create_Address_Record(p_address   =>l_address,
               p_index          =>g_file_line_number,
               x_return_status  =>l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

      --Find the mandatory missing columns.
      IF (Find_Miss_Column(11) ) THEN
              l_Address.error_flag(l_prev_line_number):='Y';
      END IF;
   END IF;

   --Validate and assign field value to address record created.
   Process_Address_Line(
        p_col_name	=> p_file_fields.col_name(l_index),
        p_col_value   	=> ltrim(rtrim(p_file_fields.col_value(l_index))),
        p_index         => p_file_fields.file_line_number(l_index),
        p_Address       => l_Address,
        x_return_status => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_Address
l_return_status',l_return_status);
      END IF;

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         l_address.error_flag(g_file_line_number):='Y';
      END IF;


     l_prev_line_number:= g_file_line_number;

l_index :=p_file_fields.level_number.next(l_index);
END LOOP; --}

--Find the mandatory missing columns.
IF (Find_Miss_Column(11) ) THEN
    l_Address.error_flag(l_prev_line_number):='Y';
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'***************************');
    WSH_DEBUG_SV.logmsg(l_module_name,'Printing Address');
END IF;


l_hi := l_Address.Supplier_name.first;
WHILE (l_hi IS NOT NULL ) LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Index',l_hi);

WSH_DEBUG_SV.log(l_module_name,'Supplier_name',l_Address.Supplier_name(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'P_address1',
l_Address.ship_from_address1(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'P_address2',
l_Address.ship_from_address2(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'P_address3',
l_Address.ship_from_address3(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'P_address4',
l_Address.ship_from_address4(l_hi));

WSH_DEBUG_SV.log(l_module_name,'P_city',l_Address.ship_from_city(l_hi));

WSH_DEBUG_SV.log(l_module_name,'P_postal_code',l_Address.ship_from_postal_code(l_hi));

WSH_DEBUG_SV.log(l_module_name,'P_state',l_Address.ship_from_state(l_hi));

WSH_DEBUG_SV.log(l_module_name,'P_province',l_Address.ship_from_province(l_hi));

WSH_DEBUG_SV.log(l_module_name,'P_county',l_Address.ship_from_county(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'p_country',
l_Address.ship_from_country(l_hi));

WSH_DEBUG_SV.log(l_module_name,'p_shipper_name',l_Address.shipper_name(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'p_phone',l_Address.phone(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'p_email',l_Address.email(l_hi));
      wSH_DEBUG_SV.log(l_module_name,'p_action',l_Address.action(l_hi));

WSH_DEBUG_SV.log(l_module_name,'Error_flag',l_Address.error_flag(l_hi));
    END IF;

l_hi :=l_Address.Supplier_name.next(l_hi);
END LOOP;


--Check if not all the lines have errors.
Is_All_Line_Error(p_error_tbl		=>l_Address.error_flag,
		   x_return_status	=> x_return_status);


IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Is_All_Line_Error
x_return_status',x_return_status);
END IF;

IF (x_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) ) THEN
    --Process the Supplier address book information.
    WSH_SUPPLIER_PARTY.Process_Address(
        p_in_param     => p_in_param,
        p_Address      => l_Address,
        x_success_tbl  => x_message_tbl,
        x_error_tbl  => g_error_tbl,
        x_return_status=> x_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Process_Address
x_return_status',x_return_status);
    END IF;
END IF;

  --Merge Message from fnd message stack and global message table
  --to output message table.
get_message;
l_msg_count:= x_message_tbl.count;

l_index := g_error_tbl.first;
WHILE (l_index IS NOT NULL) LOOP
     l_msg_count:= l_msg_count + 1;
     x_message_tbl.extend;
     x_message_tbl(l_msg_count):= g_error_tbl(l_index);

l_index := g_error_tbl.next(l_index);
END LOOP;

--Insert as message Debug information if debugger is on
IF l_debug_on THEN
    fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
    l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

    FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);

    l_msg_count:= l_msg_count + 1;
    x_message_tbl.extend;
    x_message_tbl(l_msg_count):= FND_MESSAGE.GET;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     l_msg_count:= l_msg_count + 1;
     x_message_tbl.extend;
     x_message_tbl(l_msg_count):= FND_MESSAGE.GET;

END Process_Address_File;


-- Start of comments
-- API name : Process_line
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create routing request line record.
--            1.Column name of field is reference against validation meta
--              data.
--            2.Call api Is_field_valid to validated a field.
--            3.Assign validate field to routing request line record.
--
-- Parameters :
-- IN:
--      p_col_name   IN  Column Name of field.
--      p_col_value  IN  Value of field.
--      p_index      IN  Index of global record g_field, where validation are defined.
--      p_address    IN  Record of type Line_Rec_Type to hold routing request line information.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Line(
        p_col_name   	IN  varchar2,
        p_col_value	IN  varchar2,
	p_index		IN  number,
        p_Line   	IN  OUT NOCOPY  Line_Rec_Type,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Line';

l_error	boolean:=false;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_col_name',p_col_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (p_col_name = g_field.name(c_po_header_number) ) THEN
    IF (Is_field_valid(c_po_header_number,p_col_value)) THEN
       p_line.po_header_number(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Po_Release_number) ) THEN
    IF (Is_field_valid(c_Po_Release_number,p_col_value)) THEN
       p_line.Po_Release_number(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_PO_Line_number) ) THEN
    IF (Is_field_valid(c_PO_Line_number,p_col_value)) THEN
       p_line.PO_Line_number(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_PO_Shipment_number) ) THEN
    IF (Is_field_valid(c_PO_Shipment_number,p_col_value)) THEN
       p_line.PO_Shipment_number(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Po_Operating_unit) ) THEN
    IF (Is_field_valid(c_Po_Operating_unit,p_col_value)) THEN
       p_line.Po_Operating_unit(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;


IF (p_col_name = g_field.name(c_item_qty) ) THEN
    IF (Is_field_valid(c_item_qty,p_col_value)) THEN
       p_line.Item_quantity(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Item_uom) ) THEN
    IF (Is_field_valid(c_Item_uom,p_col_value)) THEN
       p_line.Item_uom(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_total_weight) ) THEN
    IF (Is_field_valid(c_total_weight,p_col_value)) THEN
       p_line.weight(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Weight_uom) ) THEN
    IF (Is_field_valid(c_Weight_uom,p_col_value)) THEN
       p_line.Weight_uom(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_total_volume) ) THEN
    IF (Is_field_valid(c_total_volume,p_col_value)) THEN
       p_line.volume(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_volume_uom) ) THEN
    IF (Is_field_valid(c_volume_uom,p_col_value)) THEN
       p_line.volume_uom(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;


IF (p_col_name = g_field.name(c_earliest_pickup_date) ) THEN
    IF (Is_field_valid(c_earliest_pickup_date,p_col_value)) THEN
       p_line.earliest_pickup_date(p_index):=
to_date(p_col_value,g_date_format);
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Latest_pickup_date) ) THEN
    IF (Is_field_valid(c_Latest_pickup_date,p_col_value)) THEN
       p_line.Latest_pickup_date(p_index):=
to_date(p_col_value,g_date_format);
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (l_error) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_FIELD');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME', p_col_name);
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_index);
     fnd_msg_pub.add;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;


END Process_Line;



-- Start of comments
-- API name : Process_Delivery
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create routing request delivery record.
--            1.Column name of field is reference against validation meta
--              data.
--            2.Call api Is_field_valid to validated a field.
--            3.Assign validate field to routing request delivery record.
-- Parameters :
-- IN:
--      p_col_name   IN  Column Name of field.
--      p_col_value  IN  Value of field.
--      p_index      IN  Index of global record g_field, where validation are defined.
--      p_address    IN  Record of type Delivery_Rec_Type to hold routing request delivery information.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Delivery(
        p_col_name   	IN  varchar2,
        p_col_value	IN  varchar2,
	  p_index		IN  number,
        p_Delivery   	IN  OUT NOCOPY  Delivery_Rec_Type,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Delivery';

l_error	boolean:=false;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (p_col_name = g_field.name(c_ship_from_add1) ) THEN
    IF (Is_field_valid(c_ship_from_add1,p_col_value))THEN
       p_Delivery.ship_from_address1(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_ship_from_add2) ) THEN
    IF (Is_field_valid(c_ship_from_add2,p_col_value))THEN
       p_Delivery.ship_from_address2(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_ship_from_add3) ) THEN
    IF (Is_field_valid(c_ship_from_add3,p_col_value))THEN
       p_Delivery.ship_from_address3(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_ship_from_add4 )) THEN
    IF (Is_field_valid(c_ship_from_add4,p_col_value))THEN
       p_Delivery.ship_from_address4(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_city )) THEN
    IF (Is_field_valid(c_Ship_From_city,p_col_value))THEN
       p_Delivery.Ship_From_city(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_state)) THEN
    IF (Is_field_valid(c_Ship_From_state,p_col_value))THEN
       p_Delivery.Ship_From_state(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_county)) THEN
    IF (Is_field_valid(c_Ship_From_county,p_col_value))THEN
       p_Delivery.Ship_From_county(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_country)) THEN
    IF (Is_field_valid(c_Ship_From_country,p_col_value))THEN
       p_Delivery.Ship_From_country(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_province)) THEN
    IF (Is_field_valid(c_Ship_From_province,p_col_value))THEN
       p_Delivery.Ship_From_province(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_postal_code)) THEN
    IF (Is_field_valid(c_Ship_From_postal_code,p_col_value))THEN
       p_Delivery.Ship_From_postal_code(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_Ship_From_code)) THEN
    IF (Is_field_valid(c_Ship_From_code,p_col_value))THEN
       p_Delivery.Ship_From_code(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_shipper_name)) THEN
    IF (Is_field_valid(c_shipper_name,p_col_value))THEN
       p_Delivery.shipper_name(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_phone)) THEN
    IF (Is_field_valid(c_phone,p_col_value))THEN
       p_Delivery.phone(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_email)) THEN
    IF (Is_field_valid(c_email,p_col_value))THEN
       p_Delivery.email(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_number_of_containers)) THEN
    IF (Is_field_valid(c_number_of_containers,p_col_value))THEN
       p_Delivery.number_of_containers(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_del_total_weight)) THEN
    IF (Is_field_valid(c_del_total_weight,p_col_value))THEN
       p_Delivery.total_weight(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_del_weight_uom)) THEN
    IF (Is_field_valid(c_del_weight_uom,p_col_value))THEN
       p_Delivery.weight_uom(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_del_total_volume)) THEN
    IF (Is_field_valid(c_del_total_volume,p_col_value))THEN
       p_Delivery.total_volume(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_del_volume_uom)) THEN
    IF (Is_field_valid(c_del_volume_uom,p_col_value))THEN
       p_Delivery.volume_uom(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;


IF (p_col_name = g_field.name(c_remark)) THEN
    IF (Is_field_valid(c_remark,p_col_value))THEN
       p_Delivery.remark(p_index):= p_col_value;
    ELSE
       l_error:=true;
    END IF;
END IF;

IF (l_error) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_FIELD');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME', p_col_name);
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_index);
     fnd_msg_pub.add;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Process_Delivery;



-- Start of comments
-- API name : Process_Header
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to routing request header record.
--            1.Column name of field is reference against validation meta
--              data.
--            2.Call api Is_field_valid to validated a field.
--            3.Assign validate field to routing request header record.
-- Parameters :
-- IN:
--      p_col_name   IN  Column Name of field.
--      p_col_value  IN  Value of field.
--      p_index      IN  Index of global record g_field, where validation are defined.
--      p_address    IN  Record of type Header_Rec_Type to hold routing request header information.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Header(
        p_col_name   	IN  varchar2,
        p_col_value	IN  varchar2,
	p_index		IN  number,
        p_header   	IN  OUT NOCOPY  Header_Rec_Type,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Header';

l_error	boolean:=false;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (p_col_name = g_field.name(c_Supplier_name)) THEN
    IF (Is_field_valid(c_Supplier_name,p_col_value)) THEN
       p_header.Supplier_name(p_index):= p_col_value;
    ELSE
       l_error := true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_request_date)) THEN
    IF (Is_field_valid(c_request_date,p_col_value)) THEN
       p_header.Request_date(p_index):=  to_date(p_col_value,g_date_format);
    ELSE
       l_error := true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_request_number)) THEN
    IF (Is_field_valid(c_request_number,p_col_value)) THEN
       p_header.Request_Number(p_index):= p_col_value;
    ELSE
       l_error := true;
    END IF;
END IF;

IF (p_col_name = g_field.name(c_request_revision)) THEN
    IF (Is_field_valid(c_request_revision,p_col_value)) THEN
       p_header.request_revision(p_index):= p_col_value;
    ELSE
       l_error := true;
    END IF;
END IF;


IF (l_error) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_FIELD');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME', p_col_name);
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_index);
     fnd_msg_pub.add;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Process_Header;



-- Start of comments
-- API name : Validate_UOM
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate Unit of Measurement for Quantity,
--            Weight and Volume. Api does.
--           1. For UOM type Quantity calls api wsh_util_validate.Validate_Order_uom for validation.
--           2. For UOM type Weight/Volume calls api wsh_util_validate.validate_uom for validation.
--           3.If Routing request line Quantity UOM is deferent from detail
--           line Quantity UOM, then UOM conversion is done. This is applicable
--           only for Routing Request line validation.
-- Parameters :
-- IN:
--        p_uom_type              IN UOM Type QUANTITY/WEIGHT/VOLUME
--        p_organization_id       IN Organization Id
--        p_rr_uom_code           IN UOM code of Routing Request Line.
--        p_rr_qty                IN Quantity of Routing Request Line.
--        p_inventory_item_id     IN Item Id.
--        p_detail_uom_code       IN UOM code of detail line.
-- OUT:
--      x_convert_qty   OUT NOCOPY      Converted quantity in detail line UOM.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Validate_UOM(
        p_uom_type              IN              VARCHAR2,
        p_organization_id       IN              NUMBER,
        p_rr_uom_code           IN              VARCHAR2,
        p_rr_qty                IN              NUMBER Default NULL,
        p_inventory_item_id     IN              NUMBER Default NULL,
        p_detail_uom_code       IN              VARCHAR2 Default NULL,
        x_convert_qty           OUT NOCOPY      NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_UOM';

l_return_status		varchar2(1);
l_rr_uom_code		varchar2(25);
l_primary_uom_code	varchar2(25);
l_num_warnings          number;
l_num_errors            number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_uom_type',p_uom_type);
    WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
    WSH_DEBUG_SV.log(l_module_name,'p_detail_uom_code',p_detail_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'p_rr_uom_code',p_rr_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'p_rr_qty',p_rr_qty);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

l_rr_uom_code:= p_rr_uom_code;
x_convert_qty := p_rr_qty;

IF (p_uom_type='QUANTITY') THEN
    wsh_util_validate.Validate_Order_uom (
         p_inventory_item_id    =>p_inventory_item_id,
         p_organization_id	=>p_organization_id,
         x_uom_code		=>l_rr_uom_code,
         p_unit_of_measure	=>NULL,
         x_return_status	=>l_return_status);
ELSE -- p_uom_type in ('WEIGHT','VOLUME')
    wsh_util_validate.validate_uom (
         p_type                 =>p_uom_type,
         p_organization_id	=>p_organization_id,
         p_uom_code		=>l_rr_uom_code,
         p_uom_desc		=>NULL,
         x_return_status	=>l_return_status);
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'wsh_util_validate.validate_uom
l_return_status',l_return_status);
END IF;
wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

--UOM conversion is done only for UOM type 'QUANTITY' and
--routing request line and detail line UOM are different.
IF (p_uom_type='QUANTITY') THEN
    IF  (nvl(p_detail_uom_code,'##') <> p_rr_uom_code) THEN

      l_primary_uom_code:= p_detail_uom_code;

      WSH_INBOUND_UTIL_PKG.convert_quantity
       (p_inv_item_id		=> p_inventory_item_id,
  	p_organization_id	=> p_organization_id,
  	p_primary_uom_code 	=> l_primary_uom_code,
  	p_quantity 		=> p_rr_qty,
  	p_qty_uom_code		=> l_rr_uom_code,
  	x_conv_qty		=> x_convert_qty,
        x_return_status		=> l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status',l_return_status);
         WSH_DEBUG_SV.log(l_module_name,'x_convert_qty',x_convert_qty);
      END IF;

      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
    END IF;
END IF;

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_UOM;


-- Start of comments
-- API name : Process Address
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: Wrapper API to create Location, Party and Contacts for delivery. Api does.
--          1.For input party_id and location code,check if address is already created.
--          2.If Not create address information by calling api WSH_SUPPLIER_PARTY.Create_Address.
--          3.If create ,update the address information by calling api WSH_SUPPLIER_PARTY.update_Address.
-- Parameters :
-- IN:
--        P_vendor_id                     IN      Vendor Id
--        P_party_id                      IN      Party Id
--        P_location_code                 IN      Location Code
--        P_address1                      IN      Address1
--        P_address2                      IN      Address2
--        P_address3                      IN      Address3
--        P_address4                      IN      Address4
--        P_city                          IN      City
--        P_postal_code                   IN      Postal Code
--        P_state                         IN      State
--        P_Province                      IN      Province
--        P_county                        IN      County
--        p_country                       IN      Country
--        p_shipper_name                  IN      Shipper Name
--        p_phone			  IN      Phone
--        p_email			  IN      Email
-- OUT:
--        x_location_id   OUT NOCOPY Location Id for given input information.
--        x_party_site_id OUT NOCOPY Party Site Id for given input information.
--        x_return_status OUT NOCOPY Standard to output api status.
-- End of comments
PROCEDURE Process_Address(
        P_vendor_id                     IN      number,
        P_party_id                     IN      number,
        P_location_code                 IN      varchar2,
        P_address1                      IN      varchar2,
        P_address2                      IN      varchar2,
        P_address3                      IN      varchar2,
        P_address4                      IN      varchar2,
        P_city                          IN      varchar2,
        P_postal_code                   IN      varchar2,
        P_state                         IN      varchar2,
        P_Province                      IN      varchar2,
        P_county                        IN      varchar2,
        p_country                       IN      varchar2,
        p_shipper_name                  IN      varchar2,
        p_phone				IN      varchar2,
        p_email				IN      varchar2,
        x_location_id                   OUT NOCOPY number,
        x_party_site_id                 OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Address';

--Cursor to check party site relationship, if this cursor returns record means
--Delivery information is already created for this party and ship from location
--Code.
CURSOR check_location_csr(cp_party_id	NUMBER,
			  cp_location_code	VARCHAR2) IS
   SELECT ps.location_id,ps.party_site_id,ps.party_id,ps.status -- IB-Phase-2 Vendor Merge
   FROM   hz_party_sites ps,hz_party_site_uses psu
   WHERE ps.party_site_id = psu.party_site_id
   AND   psu.site_use_type = 'SUPPLIER_SHIP_FROM'
   and   party_site_number=cp_location_code
   and	 party_id =cp_party_id;


l_return_status         varchar2(1);
l_party_id		NUMBER;
l_party_site_id		NUMBER;
l_party_site_use_id	NUMBER;
l_num_warnings          number;
l_num_errors            number;
l_party_site_status     varchar2(1);
l_party_site_msg        varchar2(1000);

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_vendor_id',P_vendor_id);
      WSH_DEBUG_SV.log(l_module_name,'P_party_id',P_party_id);
      WSH_DEBUG_SV.log(l_module_name,'p_location_code',p_location_code);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
      WSH_DEBUG_SV.log(l_module_name,'p_phone',p_phone);
      WSH_DEBUG_SV.log(l_module_name,'p_email',p_email);
END IF;

IF (p_vendor_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_vendor_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
END IF;

IF (P_location_code IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_location_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

OPEN check_location_csr(p_party_id,p_location_code||'|'||p_party_id);
FETCH check_location_csr INTO x_location_id,l_party_site_id,l_party_id,l_party_site_status; -- IB-phase-2
--
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'x_location_id',x_location_id);
   WSH_DEBUG_SV.log(l_module_name,'l_party_site_id',l_party_site_id);
   WSH_DEBUG_SV.log(l_module_name,'l_party_id',l_party_id);
   WSH_DEBUG_SV.log(l_module_name,'l_party_site_status',l_party_site_status);
END IF;
--
IF (check_location_csr%NOTFOUND) THEN --{

       --If Address Information where not present, create new address information.
       WSH_SUPPLIER_PARTY.Create_Address(
        P_vendor_id     => p_vendor_id,
        P_party_id      => p_party_id,
        P_location_code => p_location_code,
        P_address1      => p_Address1,
        P_address2      => p_Address2,
        P_address3      => p_Address3,
        P_address4      => p_Address4,
        P_city          => p_city,
        P_postal_code   => p_postal_code,
        P_state         => p_state,
        P_province      => p_province,
        P_county        => p_county,
        p_country       => p_country,
        p_shipper_name  => p_shipper_name,
        p_phone         => p_phone,
        p_email         => p_email,
        x_location_id   => x_location_id,
        x_party_site_id => x_party_site_id,
        x_return_status => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Create_Address l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'x_location_id',x_location_id);
       WSH_DEBUG_SV.log(l_module_name,'l_party_site_id',l_party_site_id);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

ELSE --}{

    -- { IB-Phase-2
    -- If Party Site is not Active then error out, with a suitable message.
    IF l_party_site_status <> 'A'
    THEN
      l_party_site_msg := p_location_code;
      FND_MESSAGE.SET_NAME('WSH','WSH_INACTIVE_PARTY_SITE');
      FND_MESSAGE.SET_TOKEN('PARTY_SITE',l_party_site_msg);
      fnd_msg_pub.add;
      raise FND_API.G_EXC_ERROR;
    END IF;
    -- } IB-Phase-2

    --Address information are already created, so update the Address Information
    WSH_SUPPLIER_PARTY.Update_address(
        P_location_id   => x_location_id,
        P_party_id      => p_party_id,
        P_party_site_id => l_party_site_id,
        P_address1      => P_address1,
        P_address2      => P_address2,
        P_address3      => P_address3,
        P_address4      => P_address4,
        P_city          => P_city,
        P_postal_code   => P_postal_code,
        P_state         => P_state,
        P_province      => P_province,
        P_county        => P_county,
        p_country       => p_country,
        p_shipper_name  => p_shipper_name,
        p_phone         => p_phone,
        p_email         => p_email,
        x_return_status => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Update_Address l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF; --}
CLOSE check_location_csr;


IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF (check_location_csr%ISOPEN) THEN
        CLOSE check_location_csr;
     END IF;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF (check_location_csr%ISOPEN) THEN
        CLOSE check_location_csr;
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Process_Address;


-- Start of comments
-- API name : Create_PO
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create Purchase Order line in wsh_delivery_details.Api does.
--            1.Get the attributes of PO line from Purchase Order.
--            2.Populate additional line information.
--            3.Create the PO line in wsh_delivery_details.
--
-- Parameters :
-- IN:
--      p_po_line_location_id   IN  PO Line location Id.
--      p_detail_att  		IN  Attribute of detail line.
--      x_delivery_detail_id    IN  Delivery detail id from which PO line need to created.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_PO( p_po_line_location_id 	IN NUMBER,
                     p_detail_att               IN      detail_att_rec_type,
                     x_delivery_detail_id	OUT NOCOPY NUMBER,
		     x_return_status 		OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_PO';

l_line_rec 	OE_WSH_BULK_GRP.line_rec_type;
l_action_prms  WSH_BULK_TYPES_GRP.action_parameters_rectype;
l_additional_line_info_rec
WSH_BULK_PROCESS_PVT.additional_line_info_rec_type;

l_return_status		varchar2(1);
l_num_warnings		number;
l_num_errors		number;
l_index		number;
l_tab_count		number;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);

WSH_DEBUG_SV.log(l_module_name,'p_po_line_location_id',p_po_line_location_id);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--Get the attributes of PO line from Purchase Order
WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes(
              p_po_line_location_id  => p_po_line_location_id,
              x_line_rec             => l_line_rec,
              x_return_status        => l_return_status);

IF l_debug_on THEN

WSH_DEBUG_SV.log(l_module_name,'WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes
l_return_status',l_return_status);
END IF;

wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

l_index := l_line_rec.header_id.first;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
    WSH_DEBUG_SV.log(l_module_name,'header_id',l_line_rec.header_id(l_index));
    WSH_DEBUG_SV.log(l_module_name,'line_id',l_line_rec.line_id(l_index));
    WSH_DEBUG_SV.log(l_module_name,'vendor_id',l_line_rec.vendor_id(l_index));
END IF;

--Populate additional line information.
WSH_PO_CMG_PVT.populate_additional_line_info(
           p_line_rec                  => l_line_rec,
           p_index                     => l_index,
           p_additional_line_info_rec  => l_additional_line_info_rec ,
           x_return_status             => l_return_status);

IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'WSH_PO_CMG_PVT.populate_additional_line_info l_return_status',l_return_status);
   WSH_DEBUG_SV.log(l_module_name,'l_additional_line_info_rec.service_level.count',l_additional_line_info_rec.service_level.count);
END IF;
wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors,
           p_module_name   => l_module_name,
           p_msg_data      => 'WSH_POPULATE_ADD_INFO_ERROR');


--Set the these attributes to new line.
l_action_prms.org_id:=p_detail_att.org_id;
l_additional_line_info_rec.source_code:= p_detail_att.source_code;
l_additional_line_info_rec.released_status(l_index):=p_detail_att.released_status;
l_line_rec.shipping_interfaced_flag(l_index):='Y';
l_line_rec.source_header_number(l_index):=p_detail_att.source_header_number;
l_line_rec.source_header_type_id(l_index):=p_detail_att.source_header_type_id;
l_line_rec.source_header_type_name(l_index):=p_detail_att.source_header_type_name;
l_line_rec.requested_quantity_uom(l_index):=p_detail_att.requested_quantity_uom;
l_line_rec.requested_quantity_uom2(l_index):=p_detail_att.requested_quantity_uom2;
l_line_rec.request_date(l_index):=p_detail_att.date_requested;
l_additional_line_info_rec.earliest_dropoff_date(l_index):=p_detail_att.earliest_dropoff_date;
l_additional_line_info_rec.latest_dropoff_date(l_index):=p_detail_att.latest_dropoff_date;

--Create the PO line in wsh_delivery_details.
WSH_BULK_PROCESS_PVT.bulk_insert_details (
	   P_line_rec       => l_line_rec,
	   p_index          => l_index,
	   p_action_prms    => l_action_prms,
	   p_additional_line_info_rec => l_additional_line_info_rec,
	   X_return_status  => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'WSH_BULK_PROCESS_PVT.bulk_insert_details
l_return_status',l_return_status);
END IF;
wsh_util_core.api_post_call(
	   p_return_status => l_return_status,
	   x_num_warnings  => l_num_warnings,
	   x_num_errors    => l_num_errors,
	   p_module_name   => l_module_name,
           p_msg_data      => 'WSH_BULK_INSERT_FAILED');

x_delivery_detail_id :=
l_line_rec.delivery_detail_id(l_line_rec.delivery_detail_id.first);

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN

WSH_DEBUG_SV.log(l_module_name,'x_delivery_detail_id',x_delivery_detail_id);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_PO;


-- Start of comments
-- API name : Validate_PO
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate PO for Approval,Hold,Cancelled and Close status.Api does.
--           1. Validate status only if code release is PRC_11i_Family_Pack_J or later.
--           2. Call PO api PO_FTE_INTEGRATION_GRP.po_status_check to get the status of PO shipment line.Api return error if
--            2.1 PO is 'CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING'
--            2.2 PO is cancelled.
--            2.3 PO is in Hold.
--            2.4 PO is not Approved.
-- Parameters :
-- IN:
--        p_header_id       		IN      PO Header Id.
--        p_header       		IN      PO Number.
--        p_line_id       		IN      PO Line Id.
--        p_line_location_id       	IN      PO Line location Id.
--        p_release_id       		IN      PO release Id.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Validate_PO(
        p_header_id       		IN      NUMBER,
        p_header       			IN      varchar2,
        p_line_id       		IN      NUMBER,
        p_line_location_id       	IN      NUMBER,
        p_release_id       		IN      NUMBER,
        x_return_status         	OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_PO';

l_return_status		varchar2(1);
l_delivery_status	varchar2(30);
l_convert_qty		number;

l_po_status_rec		PO_STATUS_REC_TYPE;
--l_po_status_rec		STATUS_REC_TYPE;
l_index			number;
l_num_warnings          number;
l_num_errors            number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_header_id',p_header_id);
    WSH_DEBUG_SV.log(l_module_name,'p_header',p_header);
    WSH_DEBUG_SV.log(l_module_name,'p_line_id',p_line_id);
    WSH_DEBUG_SV.log(l_module_name,'p_line_location_id',p_line_location_id);
    WSH_DEBUG_SV.log(l_module_name,'p_release_id',p_release_id);
    WSH_DEBUG_SV.log(l_module_name,'Current_Release',PO_CODE_RELEASE_GRP.Current_Release);
    WSH_DEBUG_SV.log(l_module_name,'PRC_11i_Family_Pack_J',PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Validate status only if code release is PRC_11i_Family_Pack_J or later.
IF (PO_CODE_RELEASE_GRP.Current_Release >=PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Before calling PO_FTE_INTEGRATION_GRP.po_status_check');
   END IF;

   PO_FTE_INTEGRATION_GRP.po_status_check (
    p_api_version           => 1,
    p_header_id             => p_header_id,
    p_line_id               => p_line_id,
    p_line_location_id	    => p_line_location_id,
    p_release_id	    => p_release_id,
    p_mode                  => 'GET_STATUS',
    x_po_status_rec         => l_po_status_rec,
    x_return_status         => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'PO_FTE_INTEGRATION_GRP.po_status_check l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors,
           p_module_name   => l_module_name,
           p_msg_data      => 'WSH_RR_PO_INVALID',
           p_token1        => 'PO_NUMBER',
           p_value1        => p_header);



    l_index:=l_po_status_rec.approval_flag.first;
    WHILE (l_index IS NOT NULL) LOOP
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'approval_flag',l_po_status_rec.approval_flag(l_index));
          WSH_DEBUG_SV.log(l_module_name,'cancel_flag',l_po_status_rec.cancel_flag(l_index));
          WSH_DEBUG_SV.log(l_module_name,'closed_code',l_po_status_rec.closed_code(l_index));
          WSH_DEBUG_SV.log(l_module_name,'hold_flag',l_po_status_rec.hold_flag(l_index));
       END IF;

       --IF PO is 'CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING' and not Cancelled.
       IF (nvl(l_po_status_rec.closed_code(l_index),'N') IN ('CLOSED','FINALLY CLOSED','CLOSED FOR RECEIVING')
           AND
           nvl(l_po_status_rec.cancel_flag(l_index),'N') <> 'Y'
       ) THEN

          FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_CLOSED');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END IF;

       --If PO is cancelled.
       IF (nvl(l_po_status_rec.cancel_flag(l_index),'N') = 'Y' ) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_CANCELLED');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END IF;

       --If PO is in Hold.
       IF (nvl(l_po_status_rec.hold_flag(l_index),'N') = 'Y') THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_HOLD');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END IF;

       --If PO is not Approved.
       IF (nvl(l_po_status_rec.approval_flag(l_index),'N') <> 'Y' ) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_UNAPPROVED');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END IF;

    l_index:=l_po_status_rec.approval_flag.next(l_index);
    END LOOP;
ELSE
   raise fnd_api.g_exc_error;
END IF;

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_PO;

-- Start of comments
-- API name : Validate_line
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate Routing Request Line for Conditional Requried field,UOM's and decimal precision. Api does
--           1.Validate either latest_pickup_date or earliest_pickup_date is required.
--           2.If both date are specified than earliest pickup date should not be grater than latest pickup date.
--           3.Validate item qty, weight and volume for negative.
--           4.Validate if Weight UOM is given then weight is required, vice-versa.
--           5.Validate,if Volume UOM is given then Volume is required, vice-versa.
--           6.For One time Item directly validate the UOM from
--             mtl_units_of_measure else call wrapper api Validate_UOM
--           7.Validate item qty decimal precision.
--           8.Validate weight and volume UOM by calling wrapper api Validate_UOM.
-- Parameters :
-- IN:
--        p_organization_id       	IN      Organization Id.
--        p_item_id       		IN      Item Id.
--        p_detail_item_uom_code       	IN	UOM of Item.
--        p_detail_weight_uom_code      IN      UOM of weight.
--        p_detail_volume_uom_code      IN      UOM of Volume.
--        p_line_index            	IN      Index if Routing Request Line.
--        p_line                  	IN OUT  Type Line_Rec_Type, Routing Request Line Record.
-- OUT:
--        x_detail_item_qty            	OUT NOCOPY Item Qty in detail UOM.
--        x_detail_weight_qty           OUT NOCOPY Weight in detail UOM.
--        x_detail_volume_qty           OUT NOCOPY Volume in detail UOM.
--        x_return_status         	OUT NOCOPY varchar2 standard to output status
-- End of comments
PROCEDURE Validate_line(
        p_organization_id       	IN      NUMBER,
        p_item_id       		IN      NUMBER,
        p_detail_item_uom_code       	IN	VARCHAR2,
        x_detail_item_qty            	OUT     NOCOPY  NUMBER,
        p_detail_weight_uom_code       	IN      VARCHAR2,
        x_detail_weight_qty            	OUT     NOCOPY  NUMBER,
        p_detail_volume_uom_code       	IN      VARCHAR2,
        x_detail_volume_qty            	OUT     NOCOPY  NUMBER,
        p_line_index            	IN      NUMBER,
        p_line                  	IN OUT  NOCOPY  Line_Rec_Type,
        x_return_status         	OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_line';

--This cursor is use to validate UOM for One time item, as one time item
--does not inventory item id.
CURSOR get_item_uom(p_uom varchar2) IS
SELECT  1
  FROM   mtl_units_of_measure
  WHERE  uom_code = p_uom
  AND    uom_class = 'Quantity';


l_return_status		varchar2(1);
l_delivery_status	varchar2(30);
l_convert_qty		number;
l_item_qty		number;
l_tmp		        number;
l_primary_uom_code      varchar2(30);
l_num_warnings          number;
l_num_errors            number;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
    WSH_DEBUG_SV.log(l_module_name,'p_item_id',p_item_id);
    WSH_DEBUG_SV.log(l_module_name,'p_line_index',p_line_index);
    WSH_DEBUG_SV.log(l_module_name,'p_line.delivery_line_number.count',p_line.delivery_line_number.count);
    WSH_DEBUG_SV.log(l_module_name,'earliest_pickup_date',p_line.earliest_pickup_date(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'latest_pickup_date',p_line.latest_pickup_date(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'Item_quantity',p_line.Item_quantity(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'weight',p_line.weight(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'weight_uom', p_line.weight_uom(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'volume',p_line.volume(p_line_index));
    WSH_DEBUG_SV.log(l_module_name,'volume_uom',p_line.volume_uom(p_line_index));
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--Either latest_pickup_date or earliest_pickup_date is requried.
--If both date are specified than earlies pickup date should not be grater than latest pickup date.
IF (p_line.earliest_pickup_date(p_line_index) IS NULL and
p_line.latest_pickup_date(p_line_index) IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_REQ_PICKUP_DATE');
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_line_index);
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
ELSIF (p_line.earliest_pickup_date(p_line_index) IS NOT NULL
            and p_line.latest_pickup_date(p_line_index) IS NULL) THEN
    p_line.latest_pickup_date(p_line_index):= p_line.earliest_pickup_date(p_line_index);
ELSIF (p_line.earliest_pickup_date(p_line_index) IS NULL
            and p_line.latest_pickup_date(p_line_index) IS NOT NULL) THEN
    p_line.earliest_pickup_date(p_line_index):= p_line.latest_pickup_date(p_line_index);
ELSIF (p_line.earliest_pickup_date(p_line_index) IS NOT NULL
            and p_line.latest_pickup_date(p_line_index) IS NOT NULL) THEN

    IF (p_line.earliest_pickup_date(p_line_index) > p_line.latest_pickup_date(p_line_index) ) THEN
       FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INV_PICKUP_DATE');
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
    END IF;

END IF;

--No negative Item qty.
IF (p_line.Item_quantity(p_line_index) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_item_qty));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
END IF;

--No negative weight.
IF (nvl(p_line.weight(p_line_index),1) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_total_weight));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
END IF;


--No negative volume.
IF (nvl(p_line.volume(p_line_index),1) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_total_volume));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
END IF;


--If Weight UOM is given then weight is requried, vice-versa.
IF ((p_line.weight(p_line_index) IS NOT NULL  and p_line.weight_uom(p_line_index) IS NULL)
     OR (p_line.weight(p_line_index) IS NULL  and p_line.weight_uom(p_line_index) IS NOT NULL)
    ) THEN

       FND_MESSAGE.SET_NAME('WSH','WSH_RR_REQUIRED_FIELD_NULL');
       IF (p_line.weight(p_line_index) IS NULL) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_total_weight));
       ELSE
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_weight_uom));
       END IF;
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
END IF;

--If Volume UOM is given then Volume is requried, vice-versa.
IF ( (p_line.volume(p_line_index) IS NOT NULL  and p_line.volume_uom(p_line_index) IS NULL )
     OR (p_line.volume(p_line_index) IS NULL  and p_line.volume_uom(p_line_index) IS NOT NULL)
    )THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_REQUIRED_FIELD_NULL');
       IF (p_line.volume(p_line_index) IS NULL) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_total_volume));
       ELSE
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_volume_uom));
       END IF;

       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_index);
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
END IF;

l_item_qty:=p_line.item_quantity(p_line_index);

IF (p_line.item_uom(p_line_index) IS NOT NULL ) THEN
--{
   IF (p_item_id IS NULL) THEN
      --For One time Item directly validate the UOM from mtl_units_of_measure.
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,' Lose Item');
      END IF;

      OPEN get_item_uom(p_line.item_uom(p_line_index));
      FETCH get_item_uom INTO l_tmp;
      IF (get_item_uom%NOTFOUND) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_UOM');
           fnd_msg_pub.add;
           CLOSE get_item_uom;
           raise fnd_api.g_exc_error;
      END IF;
      CLOSE get_item_uom;

      --Convert the routing request line qty to detail line qty UOM.
      IF  (nvl(p_detail_item_uom_code,'##') <> p_line.item_uom(p_line_index)) THEN

         l_primary_uom_code:= p_detail_item_uom_code;

         WSH_INBOUND_UTIL_PKG.convert_quantity
          ( p_organization_id       => p_organization_id,
           p_primary_uom_code      => l_primary_uom_code,
           p_quantity              => p_line.item_quantity(p_line_index),
           p_qty_uom_code          => p_line.item_uom(p_line_index),
           x_conv_qty              => l_item_qty,
           x_return_status         => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'x_convert_qty',l_item_qty);
         END IF;

         wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
      END IF;

   ELSE
      --Non One time Item
      Validate_UOM(
        p_uom_type		=> 'QUANTITY',
        p_organization_id	=> p_organization_id,
        p_inventory_item_id	=> p_item_id,
        p_rr_uom_code		=> p_line.item_uom(p_line_index),
        p_detail_uom_code       => p_detail_item_uom_code,
        p_rr_qty            	=> p_line.item_quantity(p_line_index),
        x_convert_qty		=> l_item_qty,
        x_return_status		=> l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'validate_uom l_return_status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'l_item_qty',l_item_qty);
       END IF;

        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    END IF;
--}
END IF;

-- RV DEC_QTY
/*
--Check fop decimal precision.
WSH_DETAILS_VALIDATIONS.check_decimal_quantity(
  p_item_id 		=>p_item_id,
  p_organization_id 	=>p_organization_id,
  p_input_quantity	=>l_item_qty,
  p_uom_code		=>p_line.item_uom(p_line_index),
  x_output_quantity  	=>x_detail_item_qty,
  x_return_status	=>l_return_status);

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'WSH_DETAILS_VALIDATIONS.check_decimal_quantity l_return_status',l_return_status);
     WSH_DEBUG_SV.log(l_module_name,'x_detail_item_qty',x_detail_item_qty);
  END IF;
  wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

*/

x_detail_item_qty := l_item_qty;
-- RV DEC_QTY

IF (p_line.weight_uom(p_line_index) IS NOT NULL) THEN
Validate_UOM(
        p_uom_type		=> 'WEIGHT',
        p_organization_id	=> p_organization_id,
        p_rr_uom_code		=> p_line.weight_uom(p_line_index),
        x_convert_qty		=> x_detail_weight_qty,
        x_return_status		=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'validate_uom l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF;

IF (p_line.volume_uom(p_line_index) IS NOT NULL) THEN
Validate_UOM(
        p_uom_type		=> 'VOLUME',
        p_organization_id	=> p_organization_id,
        p_rr_uom_code		=> p_line.volume_uom(p_line_index),
        x_convert_qty		=> x_detail_volume_qty,
        x_return_status		=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'validate_uom l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
  END IF;

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_line;



-- Start of comments
-- API name : Validate_Delivery
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate Routing Request delivery for Conditional Required field and process address.api does
--           1.Validate if Number of container,Weight and volume for negative.
--           2.Validate if Weight UOM is given then weight is required, vice-versa.
--           3.Validate,if Volume UOM is given then Volume is required, vice-versa.
--           4.Procces the address information by calling wrapper api process_address.
-- Parameters :
-- IN:
--      p_detail_att            IN  Attributes of delivery detail line.
--      p_delivery_index        IN  Index of delivery record.
--      p_delivery              IN  Delivery_Rec_Type,Routing Request delivery record.
-- OUT:
--      x_return_status         OUT NOCOPY varchar2 standard to output status.
-- End of comments

PROCEDURE Validate_Delivery(
        p_detail_att            IN OUT  NOCOPY detail_att_rec_type,
        p_delivery_index        IN      NUMBER,
        p_delivery              IN OUT  NOCOPY  Delivery_Rec_Type,
        x_return_status         OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY';

l_return_status		varchar2(1);
l_delivery_status	varchar2(30);
l_convert_qty		number;
l_num_warnings          number;
l_num_errors            number;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_index',p_delivery_index);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery.Ship_From_Address1.count',p_delivery.Ship_From_Address1.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


IF (nvl(p_delivery.Number_of_containers(p_delivery_index),1) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_number_of_containers));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_delivery_index);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
END IF;

IF (nvl(p_delivery.total_weight(p_delivery_index),1) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_total_weight));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_delivery_index);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
END IF;


IF (nvl(p_delivery.total_volume(p_delivery_index),1) < 0 ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_total_volume));
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_delivery_index);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
END IF;


--If weigh UOM given the weight is requried, vice-versa
IF ( (p_delivery.total_weight(p_delivery_index) IS NOT NULL  and p_delivery.weight_uom(p_delivery_index) IS NULL)
      OR (p_delivery.total_weight(p_delivery_index) IS NULL  and p_delivery.weight_uom(p_delivery_index) IS NOT NULL)
    )THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_REQUIRED_FIELD_NULL');
       IF (p_delivery.total_weight(p_delivery_index) IS NULL) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_total_weight));
       ELSE
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_weight_uom));
       END IF;
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_delivery_index);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
END IF;

--If volume UOM given the volume is requried, vice-versa
IF ((p_delivery.total_volume(p_delivery_index) IS NOT NULL  and p_delivery.volume_uom(p_delivery_index) IS NULL)
      OR (p_delivery.total_volume(p_delivery_index) IS NULL  and p_delivery.volume_uom(p_delivery_index) IS NOT NULL)
    ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_REQUIRED_FIELD_NULL');
       IF (p_delivery.total_volume(p_delivery_index) IS NULL) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_total_volume));
       ELSE
          FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_del_volume_uom));
       END IF;

       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_delivery_index);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
END IF;


--Create/Update Ship location ,party and contacts information.
Process_Address(
        P_vendor_id	=> p_detail_att.vendor_id,
        p_party_id	=> p_detail_att.party_id,
        P_location_code	=> p_delivery.ship_from_code(p_delivery_index),
        P_address1	=> p_delivery.ship_from_address1(p_delivery_index),
        P_address2	=> p_delivery.ship_from_address2(p_delivery_index),
        P_address3	=> p_delivery.ship_from_address3(p_delivery_index),
        P_address4	=> p_delivery.ship_from_address4(p_delivery_index),
        P_city		=> p_delivery.ship_from_city(p_delivery_index),
        P_postal_code	=> p_delivery.ship_from_postal_code(p_delivery_index),
        P_state		=> p_delivery.ship_from_state(p_delivery_index),
        P_Province	=> p_delivery.ship_from_Province(p_delivery_index),
        P_county	=> p_delivery.ship_from_county(p_delivery_index),
        p_country	=> p_delivery.ship_from_country(p_delivery_index),
        p_shipper_name	=> p_delivery.shipper_name(p_delivery_index),
        p_phone		=> p_delivery.phone(p_delivery_index),
        p_email		=> p_delivery.email(p_delivery_index),
        x_location_id	=> p_detail_att.ship_from_location_id,
	x_party_site_id => p_detail_att.party_site_id,
        x_return_status => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Process_Address l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id',p_detail_att.ship_from_location_id);
    WSH_DEBUG_SV.log(l_module_name,'party_site_id',p_detail_att.party_site_id);
END IF;
wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     p_delivery.error_flag(p_delivery_index):= 'Y';


     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    p_delivery.error_flag(p_delivery_index):= 'Y';

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_Delivery;


-- Start of comments
-- API name : Validate_Delivery_uom
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate Routing Request delivery UOM. Api calls wrapper api validate_UOM to this.
-- Parameters :
-- IN:
--      p_organization_id       IN  Organization Id.
--      p_delivery_index        IN  Index of delivery record.
--      p_delivery              IN  Delivery_Rec_Type,Routing Request delivery record.
-- OUT:
--      x_return_status         OUT NOCOPY varchar2 standard to output status.
-- End of comments
PROCEDURE Validate_Delivery_uom(
        p_organization_id       IN 	NUMBER,
        p_delivery_index        IN      NUMBER,
        p_delivery              IN OUT  NOCOPY  Delivery_Rec_Type,
        x_return_status         OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Delivery_uom';

l_return_status		varchar2(1);
l_delivery_status	varchar2(30);
l_convert_qty		number;
l_num_warnings          number;
l_num_errors            number;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_index',p_delivery_index);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery.Ship_From_Address1.count',p_delivery.Ship_From_Address1.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


IF (p_delivery.weight_uom(p_delivery_index) IS NOT NULL) THEN
--Call wrapper api for final validation.
Validate_UOM(
        p_uom_type		=> 'WEIGHT',
        p_organization_id	=> p_organization_id,
        p_rr_uom_code		=> p_delivery.weight_uom(p_delivery_index),
        x_convert_qty		=> l_convert_qty,
        x_return_status		=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'validate_uom l_return_status',l_return_status);
    END IF;

     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
  END IF;

IF (p_delivery.volume_uom(p_delivery_index)IS NOT NULL) THEN
--Call wrapper api for final validation.
Validate_UOM(
        p_uom_type		=> 'VOLUME',
        p_organization_id	=> p_organization_id,
        p_rr_uom_code		=> p_delivery.volume_uom(p_delivery_index),
        x_convert_qty		=> l_convert_qty,
        x_return_status		=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'validate_uom l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF;


IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     p_delivery.error_flag(p_delivery_index):= 'Y';


     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    p_delivery.error_flag(p_delivery_index):= 'Y';

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_Delivery_uom;


-- Start of comments
-- API name : Update_Split_Details
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to sum up and split the delivery detail lines. Api does
--           1.Update the first detail line with attributes of routing request.
--           2.For the requested qty update with grater of item or sum of crurrent requested qty.
--           3.If routing request qty is less then request qty then split the
--             line by difference of req. qty and routing request qty.
--           4.Calculate the ratio for secondary qty
--           5.Drive the secondary qty from ratio and primary qty.
--           6.If routing request qty is less then request qty then split the
--             line by difference of req. qty and routing request qty.
--           7.Update the newly create line result of split, with
--             ship_from_location_id to -1,ignore_for_planning to 'Y' and
--             routing_req_id,picked_quantity,picked_quantity2,
--             earliest_pickup_date and latest_pickup_date to NULL. This to
--             nullify the update on main line.
--           8.Update the Weight/Volume attributes to first line.
--           9.Except the first line,delete the remaining detail lines.
-- Parameters :
-- IN:
--      p_detail_ids   IN  List of delivery detail line Id's.
--      p_detail_att   IN  Attributes of delivery and delivery line.
-- OUT:
--      x_new_detail_ids OUT NOCOPY      New delivery detail id's created result of split.
--      x_return_status  OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Update_Split_Details(
        p_detail_ids       	IN      wsh_util_core.id_tab_type,
        p_detail_att            IN      detail_att_rec_type,
	x_new_detail_ids	OUT 	NOCOPY	wsh_util_core.id_tab_type,
	x_return_status		OUT	NOCOPY	varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_Split_Details';
l_return_status		varchar2(1);
l_frozen_flag		varchar2(1);

l_item_quantity			number;
l_item_quantity2		number;
l_split_delivery_detail_id	number;

l_picked_quantity2		number := 0;
l_picked_quantity		number := 0;
l_index				number;
l_ratio				number;

-- HW OPMCONV - Removed OPM precision

l_num_warnings          number;
l_num_errors            number;
l_first_detail_id	number;
l_earliest_pickup_date	date;
l_latest_pickup_date	date;

l_dbi_rs               VARCHAR2(1); -- Return Status from DBI API

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_detail_ids.count',p_detail_ids.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


l_index := p_detail_ids.first;
l_first_detail_id:=p_detail_ids(l_index);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'item_quantity',p_detail_att.item_quantity);
    WSH_DEBUG_SV.log(l_module_name,'requested_quantity',p_detail_att.requested_quantity);
    WSH_DEBUG_SV.log(l_module_name,'requested_quantity2',p_detail_att.requested_quantity2);
    WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',l_first_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'dd_net_weight',p_detail_att.dd_net_weight);
    WSH_DEBUG_SV.log(l_module_name,'dd_gross_weight',p_detail_att.dd_gross_weight);
    WSH_DEBUG_SV.log(l_module_name,'dd_volume',p_detail_att.dd_volume);
    WSH_DEBUG_SV.log(l_module_name,'dd_wv_frozen_flag',p_detail_att.dd_wv_frozen_flag);
END IF;


--Update the line with grater of item or requested qty and the split if requried.
IF ( p_detail_att.item_quantity >= p_detail_att.requested_quantity) THEN
    l_picked_quantity:= p_detail_att.item_quantity;
ELSE
    l_picked_quantity:= p_detail_att.requested_quantity;
END IF;

--Calculate the ratio for secondary qty.
IF (p_detail_att.requested_quantity2 <> 0 and
p_detail_att.requested_quantity <> 0) THEN
    l_ratio:= p_detail_att.requested_quantity2/
p_detail_att.requested_quantity;
END IF;


--Calculate the Secondary qty.
IF (p_detail_att.requested_quantity2 <> 0 ) THEN
-- HW OPMCONV - No need to use OPM precision. Use current INV which is 5
    l_picked_quantity2 := ROUND(l_ratio * l_picked_quantity,
                          WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV);
ELSE
    l_picked_quantity2:= NULL;
END IF;

--Set the Wt/Vol calculation frozen flag to 'Y', if weight/Volume is passed.
IF (p_detail_att.weight IS NOT NULL or p_detail_att.volume IS NOT NULL) THEN
    l_frozen_flag:='Y';
ELSE
    l_frozen_flag:='N';
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_picked_quantity',l_picked_quantity);
    WSH_DEBUG_SV.log(l_module_name,'l_ratio',l_ratio);
    WSH_DEBUG_SV.log(l_module_name,'l_picked_quantity2',l_picked_quantity2);
    WSH_DEBUG_SV.log(l_module_name,'l_frozen_flag',l_frozen_flag);
    WSH_DEBUG_SV.log(l_module_name,'requested_quantity',p_detail_att.requested_quantity);
    WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id',p_detail_att.ship_from_location_id);
    WSH_DEBUG_SV.log(l_module_name,'party_id',p_detail_att.party_id);
END IF;

IF (p_detail_att.item_quantity > 0 ) THEN  -- {

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'p_detail_att.earliest_pickup_date',p_detail_att.earliest_pickup_date);
       WSH_DEBUG_SV.log(l_module_name,'p_detail_att.latest_pickup_date',p_detail_att.latest_pickup_date);
    END IF;

    l_earliest_pickup_date := add_time_to_date(p_detail_att.earliest_pickup_date,'F');
    l_latest_pickup_date := add_time_to_date(p_detail_att.latest_pickup_date,'L');

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_earliest_pickup_date',l_earliest_pickup_date);
       WSH_DEBUG_SV.log(l_module_name,'l_latest_pickup_date',l_latest_pickup_date);
    END IF;

    --Update the first line of p_detail_att
    UPDATE wsh_delivery_details
     SET requested_quantity = p_detail_att.requested_quantity,
         requested_quantity2 = decode(p_detail_att.requested_quantity2,0,NULL,p_detail_att.requested_quantity2),
         picked_quantity = l_picked_quantity,
         picked_quantity2 = l_picked_quantity2,
         routing_req_id = p_detail_att.routing_req_id,
         earliest_pickup_date = l_earliest_pickup_date,
         latest_pickup_date = l_latest_pickup_date,
         party_id = p_detail_att.party_id,
         ship_from_location_id = p_detail_att.ship_from_location_id,
         ignore_for_planning = 'N',
         wv_frozen_flag = p_detail_att.dd_wv_frozen_flag,
         net_weight = p_detail_att.dd_net_weight,
         gross_weight = p_detail_att.dd_gross_weight,
         volume = p_detail_att.dd_volume,
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.USER_ID
     WHERE delivery_detail_id = l_first_detail_id
     AND  released_status='X';

    --Delivery Details for new delivery to be created
    x_new_detail_ids(x_new_detail_ids.count + 1) := l_first_detail_id;

    --
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- DBI API will check if DBI is installed
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',x_new_detail_ids.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => x_new_detail_ids,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    -- Only Handle Unexpected error
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      --
      x_return_status := l_dbi_rs;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
    -- End of Code for DBI Project
    --

    IF (p_detail_att.item_quantity <  p_detail_att.requested_quantity ) THEN --{

       --Qty to be split.
       l_item_quantity := p_detail_att.requested_quantity - p_detail_att.item_quantity;

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_detail_att.requested_quantity2',p_detail_att.requested_quantity2);
       END IF;

       --Calculate the secondary split qty.
       IF (p_detail_att.requested_quantity2 <> 0) THEN
-- HW OPMCONV - No need to use OPM precision. Use current INV which is 5
          l_item_quantity2 := ROUND(l_ratio * l_item_quantity,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV);
       ELSE
          l_item_quantity2 := NULL;
       END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_item_quantity',l_item_quantity);
          WSH_DEBUG_SV.log(l_module_name,'l_item_quantity2',l_item_quantity2);
       END IF;

       --Split the first detail line already updated with routing request attributes.
       WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details (
        p_from_detail_id        => l_first_detail_id,
        p_req_quantity          => l_item_quantity,
        p_req_quantity2         => l_item_quantity2,
        p_unassign_flag         => 'Y',
        p_converted_flag        => NULL,
        p_manual_split          => NULL,
        x_new_detail_id         => l_split_delivery_detail_id,
        x_return_status         => l_return_status);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
           WSH_DEBUG_SV.log(l_module_name,'l_split_delivery_detail_id',l_split_delivery_detail_id);
           WSH_DEBUG_SV.log(l_module_name,'l_item_quantity',l_item_quantity);
        END IF;
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

       --Update the new line create because of split, to nullify the update on original line.
        UPDATE wsh_delivery_details
        SET ship_from_location_id = -1,
         ignore_for_planning = 'Y',
         routing_req_id = null,
         picked_quantity = null,
         picked_quantity2 = null,
         earliest_pickup_date = null,
         latest_pickup_date = null,
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.USER_ID
        WHERE delivery_detail_id = l_split_delivery_detail_id;
    END IF; --}


    --Update the first line with Weight/Volume attributes.
    UPDATE wsh_delivery_details
     SET net_weight = nvl(p_detail_att.weight,net_weight),
         gross_weight = nvl(p_detail_att.weight,gross_weight),
         weight_uom_code = nvl(p_detail_att.weight_uom,weight_uom_code),
         volume = nvl(p_detail_att.volume,volume),
         volume_uom_code = nvl(p_detail_att.volume_uom,volume_uom_code),
         wv_frozen_flag= decode(l_frozen_flag,'N',wv_frozen_flag,'Y',l_frozen_flag),
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.USER_ID
     WHERE delivery_detail_id = l_first_detail_id
     AND  released_status='X';


    --Delete the remaining detail lines.
    IF (p_detail_ids.count > 1 ) THEN --{

       l_index := p_detail_ids.next(l_index);

       WHILE (l_index IS NOT NULL) LOOP

          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',p_detail_ids(l_index));
          END IF;

          WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details (
              p_delivery_detail_id      => p_detail_ids(l_index),
              x_return_status           => l_return_status);

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Delete_Delivery_Details l_return_status',l_return_status);
           END IF;
           wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);


       l_index := p_detail_ids.next(l_index);
       END LOOP;
    END IF; --}

END IF; --}

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN

WSH_DEBUG_SV.log(l_module_name,'x_new_detail_ids.count',x_new_detail_ids.count);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Update_Split_Details;


-- Start of comments
-- API name : UnAssign_Details
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to Unassigned detail lines from delivery. Api does
--             1.Get the line status and delivery_id of all the detail lines for input routing request id.
--             2.If any one of line is not open then error out.
--             3.Unplan the delivery associate with the lines.
--             4.Un assign the detail lines by calling api WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details
--
-- Parameters :
-- IN:
--      p_routing_req_id   IN  Routing Request id
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE UnAssign_Details(
	p_routing_req_id	IN number ,
	x_return_status		OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'|| G_PKG_NAME||'.'||'UnAssign_Details';
l_return_status	varchar2(1);

-- Select released_status and associated delivery for unplaning and un assigning.
CURSOR unassign_del_csr IS
SELECT wdd.delivery_detail_id,wdd.released_status,wda.delivery_id
FROM   wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
WHERE  routing_req_id = p_routing_req_id
AND    wdd.delivery_detail_id = wda.delivery_detail_id
ORDER BY wda.delivery_id;

l_msg_count	number;
l_detail_ids    wsh_util_core.id_tab_type;
l_action_prms   wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
l_dlvy_ids      wsh_util_core.id_tab_type;
l_prev_delivery_id number;
l_num_warnings          number;
l_num_errors            number;
BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_routing_req_id',p_routing_req_id);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


FOR del_rec IN unassign_del_csr LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',del_rec.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'released_status',del_rec.released_status);
      WSH_DEBUG_SV.log(l_module_name,'delivery_id',del_rec.delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'l_prev_delivery_id',l_prev_delivery_id);
    END IF;

   --Unassigned allowed only lines are released status 'X' i.e. Inbound open lines.
   IF (del_rec.released_status <> 'X' ) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_RR_UNASSIGN_DET_ERROR');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
   END IF;
   l_detail_ids(l_detail_ids.count + 1):= del_rec.delivery_detail_id;


   IF (del_rec.delivery_id <> nvl(l_prev_delivery_id,-9) ) THEN
      l_dlvy_ids(l_dlvy_ids.count + 1):=del_rec.delivery_id;
   END IF;

   l_prev_delivery_id:=del_rec.delivery_id;
END LOOP;


--Unplan the delivery before unassiging.
IF (l_dlvy_ids.count > 0 ) THEN
    WSH_NEW_DELIVERY_ACTIONS.Unplan
                (p_del_rows      => l_dlvy_ids,
                 x_return_status =>l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'WSH_NEW_DELIVERY_ACTIONS.plan l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

END IF;


l_action_prms.caller:='WSH_IB';
--Call WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details with caller 'WSH_IP' for un assiginig details.
IF (l_detail_ids.count > 0 ) THEN
    WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details(
       p_rec_of_detail_ids => l_detail_ids,
       p_from_delivery     => 'Y',
       p_from_container    => 'N',
       p_action_prms       => l_action_prms,
       x_return_status     => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Unassign_Multiple_Details
l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF;

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;


     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END UnAssign_Details;


-- Start of comments
-- API name : Create_Delivery
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to create delivery for Routing Request lines.Api does
--            1.Auto create delivery by calling api WSH_INTERFACE_GRP.Delivery_Detail_Action.
--            2.If delivery create is more than one than error out.
--            3.Delivery created is one, than go through details line to verify delivery associated is same with newly created delivery.
--            4.Plan the newly created delivery.
--            5.Updates wsh_new_deliveries with delivery level attributes of routing request.
--            6.If weight and volume is passed set the wv_frozen_flag to 'Y'.
--            7.Calculate the weight and volume.
-- Parameters :
-- IN:
--      p_detail_ids   		IN  List of detail lines for which delivery need to be created.
--      p_delivery_index  	IN  Index of delivery record.
--      p_delivery      	IN  Delivery record type Delivery_Rec_Type.
-- OUT:
--      x_new_deliveries OUT NOCOPY      Id of new delivery created.
--      x_return_status  OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Delivery(
        p_detail_ids		IN	 wsh_util_core.id_tab_type,
        p_delivery_index        IN      NUMBER,
        p_delivery              IN OUT  NOCOPY Delivery_Rec_Type,
        x_new_deliveries	OUT	NOCOPY wsh_util_core.id_tab_type,
        x_return_status         OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Delivery';
l_return_status		varchar2(1);
l_ship_from_location_id	number;
l_party_id		number;
l_party_site_id		number;
l_dummy_rows		wsh_util_core.id_tab_type;
l_new_deliveries	wsh_util_core.id_tab_type;
l_new_detail_ids	wsh_util_core.id_tab_type;

--Proration
l_old_net_weight	NUMBER :=0;
l_old_gross_weight	NUMBER :=0;
l_new_net_weight	NUMBER :=0;
l_new_gross_weight	NUMBER :=0;
l_delivery_UOM_code	VARCHAR2(3);

CURSOR c_get_delivery_weight(p_deliveryid NUMBER) IS
SELECT net_weight, gross_weight, weight_uom_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_deliveryid;
--Proration

--Cursor to get the PO and delivery information.
CURSOR get_del_info(p_detail_id NUMBER) IS
SELECT wdd.source_header_number,
	wdd.source_line_number,
	wdd.po_shipment_line_number,
	wdd.source_blanket_reference_num,
	wda.delivery_id
FROM   wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
WHERE  wdd.delivery_detail_id = p_detail_id
AND    wdd.delivery_detail_id = wda.delivery_detail_id;

l_del_info	get_del_info%ROWTYPE;

l_prev_delivery_id 	NUMBER;
l_delivery_id		NUMBER;

l_dd_action_prms   WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
l_dd_action_out_rec    WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

l_msg_count	NUMBER;
l_msg_data	varchar2(2000);

l_index			number;
l_frozen		varchar2(1);
l_num_warnings          number;
l_num_errors            number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_detail_ids.count',p_detail_ids.count);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_index',p_delivery_index);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery.Ship_From_Address1.count',p_delivery.Ship_From_Address1.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Auto create delivery
IF (p_detail_ids.count > 0 ) THEN

    l_dd_action_prms.caller      := 'WSH_IB';
    l_dd_action_prms.action_code := 'AUTOCREATE-DEL';

    WSH_INTERFACE_GRP.Delivery_Detail_Action (
      p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_commit             => FND_API.G_FALSE,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      p_detail_id_tab      => p_detail_ids,
      p_action_prms        => l_dd_action_prms,
      x_action_out_rec     => l_dd_action_out_rec);


    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'wsh_util_validate.validate_uom l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'l_dd_action_out_rec.count',l_dd_action_out_rec.delivery_id_tab.count);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'first out delivery',l_dd_action_out_rec.delivery_id_tab(l_dd_action_out_rec.delivery_id_tab.first));
    END IF;

    --Number of delivery created should always be one.
    IF (l_dd_action_out_rec.delivery_id_tab.count= 1 ) THEN
       FOR i IN p_detail_ids.first..p_detail_ids.last LOOP

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Index i',i);
            WSH_DEBUG_SV.log(l_module_name,'delivert_detail_id',p_detail_ids(i));
         END IF;

         OPEN get_del_info ( p_detail_ids(i));
         FETCH get_del_info INTO l_del_info;
         CLOSE get_del_info;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'delivery_id',l_del_info.delivery_id);
            WSH_DEBUG_SV.log(l_module_name,'source_header_number',l_del_info.source_header_number);
            WSH_DEBUG_SV.log(l_module_name,'source_line_number',l_del_info.source_line_number);
            WSH_DEBUG_SV.log(l_module_name,'po_shipment_line_number',l_del_info.po_shipment_line_number);
            WSH_DEBUG_SV.log(l_module_name,'source_blanket_reference_num',l_del_info.source_blanket_reference_num);
         END IF;

         -- Scan through details line, delivery associated is same for all lines.
         IF (l_prev_delivery_id IS NOT NULL AND l_prev_delivery_id <> l_del_info.delivery_id) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_GROUP_NOT_MATCH');
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_del_info.delivery_id));
           FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_del_info.source_header_number);
           FND_MESSAGE.SET_TOKEN('PO_LINE_NUM', l_del_info.source_line_number);
           FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM', l_del_info.po_shipment_line_number);
           FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_del_info.source_blanket_reference_num);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           x_new_deliveries(1):=l_del_info.delivery_id;
         END IF;
       l_prev_delivery_id:=l_del_info.delivery_id;

       END LOOP;

    ELSE
        -- Error, multiple deliveries created.
        -- E.g Line with different ship to location are part of Routing Request Delivery.
       FOR i IN p_detail_ids.first..p_detail_ids.last LOOP

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Index i',i);
            WSH_DEBUG_SV.log(l_module_name,'delivert_detail_id',p_detail_ids(i));
         END IF;

         OPEN get_del_info ( p_detail_ids(i));
         FETCH get_del_info INTO l_del_info;
         CLOSE get_del_info;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'delivery_id',l_del_info.delivery_id);
            WSH_DEBUG_SV.log(l_module_name,'source_header_number',l_del_info.source_header_number);
            WSH_DEBUG_SV.log(l_module_name,'source_line_number',l_del_info.source_line_number);
            WSH_DEBUG_SV.log(l_module_name,'po_shipment_line_number',l_del_info.po_shipment_line_number);
            WSH_DEBUG_SV.log(l_module_name,'source_blanket_reference_num',l_del_info.source_blanket_reference_num);
         END IF;


         FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_GROUP_NOT_MATCH');
         FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_del_info.delivery_id));
         FND_MESSAGE.SET_TOKEN('PO_HEADER_NUM',l_del_info.source_header_number);
         FND_MESSAGE.SET_TOKEN('PO_LINE_NUM', l_del_info.source_line_number);
         FND_MESSAGE.SET_TOKEN('PO_SHIPMENT_LINE_NUM', l_del_info.po_shipment_line_number);
         FND_MESSAGE.SET_TOKEN('PO_RELEASE_NUM',l_del_info.source_blanket_reference_num);
         fnd_msg_pub.add;
       END LOOP;

       raise fnd_api.g_exc_error;
    END IF;

ELSE
    raise fnd_api.g_exc_error;
END IF;


--Plan the newly created delivery.
IF (x_new_deliveries.count > 0) THEN
    WSH_NEW_DELIVERY_ACTIONS.plan
                (p_del_rows             =>x_new_deliveries,
                 x_return_status        => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'WSH_NEW_DELIVERY_ACTIONS.plan l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF;

--START Proration
OPEN c_get_delivery_weight(x_new_deliveries(1));
FETCH c_get_delivery_weight INTO l_old_net_weight, l_old_gross_weight, l_delivery_UOM_code;
CLOSE c_get_delivery_weight;
--END Proration

IF (p_delivery.total_weight(p_delivery_index) IS NOT NULL
     OR  p_delivery.total_volume(p_delivery_index) IS NOT NULL) THEN
    l_frozen:='Y';
ELSE
    l_frozen:='N';
END IF;

IF (x_new_deliveries.count > 0 ) THEN
--Update the created delivery with delivery attributes of routing request.
FORALL i IN x_new_deliveries.first..x_new_deliveries.last
  UPDATE wsh_new_deliveries
  SET  number_of_lpn = p_delivery.number_of_containers(p_delivery_index),
	net_weight = nvl(p_delivery.total_weight(p_delivery_index),net_weight),
	gross_weight = nvl(p_delivery.total_weight(p_delivery_index),gross_weight),
	weight_uom_code = nvl(p_delivery.weight_uom(p_delivery_index),weight_uom_code),
        volume       = nvl(p_delivery.total_volume(p_delivery_index),volume),
        volume_uom_code       = nvl(p_delivery.volume_uom(p_delivery_index),volume_uom_code),
        wv_frozen_flag = l_frozen,
        additional_shipment_info = p_delivery.remark(p_delivery_index),
        last_update_date = sysdate,
        last_updated_by = FND_GLOBAL.USER_ID
  WHERE delivery_id = x_new_deliveries(i);
END IF;

--Proration
--compare the old and new weights
IF (p_delivery.total_weight(p_delivery_index) IS NOT NULL ) THEN
	IF ((NVL(l_old_gross_weight,0) <> p_delivery.total_weight(p_delivery_index)) OR (NVL(l_old_net_weight,0) <> p_delivery.total_weight(p_delivery_index))) THEN
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.PRORATE_WEIGHT',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;

	    WSH_WV_UTILS.PRORATE_WEIGHT
	      (
	       p_entity_id     => x_new_deliveries(1) ,
	       p_old_gross_wt  => l_old_gross_weight,
	       p_new_gross_wt  => p_delivery.total_weight(p_delivery_index),
	       p_old_net_wt    => l_old_net_weight,
	       p_new_net_wt    => p_delivery.total_weight(p_delivery_index),
	       p_weight_uom_code => l_delivery_UOM_code,
	       p_entity_type   => 'DELIVERY',
	       x_return_status => l_return_status
	      );

	    IF l_debug_on THEN
	       WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	    END IF;

	    wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);
	END IF;
END IF;
--End Proration

--Re-calculate the Wt/Vol based on wt_vol frozen.
IF (p_delivery.total_weight(p_delivery_index) IS NOT NULL
     OR  p_delivery.total_volume(p_delivery_index) IS NOT NULL) THEN
    IF (p_detail_ids.count > 0 ) THEN
       --Calculate the Wt/Volume in detail line level, since
       --delivery level Wt/Volume is passed.
       WSH_WV_UTILS.Detail_Weight_Volume (
        p_detail_rows   	=> p_detail_ids,
        p_override_flag		=> 'Y',
        p_calc_wv_if_frozen	=> 'N',
        x_return_status 	=> l_return_status);

       wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
    END IF;
ELSE
    IF (x_new_deliveries.count > 0 ) THEN
       --Calculate Wt/Vol both in detail line and delivery level.
       WSH_WV_UTILS.Delivery_Weight_Volume (
        p_del_rows   		=> x_new_deliveries,
        p_update_flag		=> 'Y',
        p_calc_wv_if_frozen	=> 'N',
        x_return_status 	=> l_return_status);

       wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
    END IF;
  END IF;

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     p_delivery.error_flag(p_delivery_index):= 'Y';

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    p_delivery.error_flag(p_delivery_index):= 'Y';

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_Delivery;


-- Start of comments
-- API name : Validate_Header
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to validate Routing Request Header for Supplier,routing request number and revision. Api does
--            1.Validate revision number for negative.
--            2.Validate Supplier information.
--            3.Get the information from wsh_inbound_txn_history for party and receipt number.
--            4.If found then this is revision, Un-assign detail lines from delivery.
--            5.Store the current information in  wsh_inbound_txn_history.
-- Parameters :
-- IN:
--	p_in_param      	IN      Additional parameter passed from routing request UI.
--      p_request_number        IN      Routing Request Number.
--      p_request_revision      IN      Routing Request revision
--	p_supplier_name		IN	Supplier Name.
--      p_line_number           IN      Line of Routing Request File.
--      p_detail_att            IN OUT  Attributes of routing request line type In_param_Rec_Type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Validate_Header(
	p_in_param      	IN      In_param_Rec_Type,
        p_request_number        IN      VARCHAR2 ,
        p_request_revision      IN      NUMBER,
	p_supplier_name		IN	VARCHAR2,
        p_line_number           IN      NUMBER,
        p_detail_att            IN OUT  NOCOPY detail_att_rec_type,
        x_return_status         OUT     NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_HEADER';
l_return_status		varchar2(1);

--Cursor to test if routing request is new one or revision.
CURSOR get_revision_number_csr(cp_request_number VARCHAR2,p_supplier_id
NUMBER) IS
SELECT revision_number,transaction_id
FROM	wsh_inbound_txn_history
WHERE receipt_number = cp_request_number
AND   TRANSACTION_TYPE ='ROUTING_REQUEST'
AND   SUPPLIER_ID=p_supplier_id
ORDER BY revision_number desc;

l_txn_rec		WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
l_revision_number	NUMBER;
l_num_warnings          number;
l_num_errors            number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_request_number',p_request_number);
    WSH_DEBUG_SV.log(l_module_name,'p_request_revision',p_request_revision);
    WSH_DEBUG_SV.log(l_module_name,'p_supplier_name',p_supplier_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Negative revision is not allowed.
IF (p_request_revision < 0 ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_NEG_NUM');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME',g_field.name(c_request_revision));
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_number);
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
END IF;


--Validate and create Supplier information.
WSH_SUPPLIER_PARTY.Validate_Supplier(
        p_in_param      => p_in_param,
        p_supplier_name => p_supplier_name,
        x_vendor_id     => p_detail_att.vendor_id,
        x_party_id      => p_detail_att.party_id,
        x_return_status => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Validate_Supplier l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'vendor_id',p_detail_att.vendor_id);
    WSH_DEBUG_SV.log(l_module_name,'party_id',p_detail_att.party_id);
END IF;
wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);



OPEN get_revision_number_csr(p_request_number,p_detail_att.vendor_id);
FETCH get_revision_number_csr INTO l_revision_number,p_detail_att.prev_routing_req_id;

IF (get_revision_number_csr%FOUND ) THEN
    --This is routing request revision

    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'get_revision_number_csr FOUND');
    END IF;

    IF (p_request_revision <=  nvl(l_revision_number,-99) ) THEN
       FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_REVISION');
       FND_MESSAGE.SET_TOKEN('C_REV_NUM', p_request_revision);
       FND_MESSAGE.SET_TOKEN('P_REV_NUM', l_revision_number);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
    END IF;

    --Unassign the lines from delivery, since every
    --revision is replacement of another.
    Unassign_Details(
            p_routing_req_id       => p_detail_att.prev_routing_req_id ,
            x_return_status        => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Unassign_Details l_return_status',l_return_status);
        END IF;

     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
END IF;
CLOSE get_revision_number_csr;

IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'get_revision_number_csr NOT FOUND');
END IF;


--Store the current information in Inbound History table.
l_txn_rec.TRANSACTION_TYPE:='ROUTING_REQUEST';
l_txn_rec.RECEIPT_NUMBER:= p_request_number;
l_txn_rec.REVISION_NUMBER:= p_request_revision;
l_txn_rec.status:= 'PROCESSED';
l_txn_rec.supplier_id := p_detail_att.vendor_id;

--Store the header information in Inbound Txn History.
WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history (
              p_txn_history_rec => l_txn_rec,
              x_txn_id          => p_detail_att.routing_req_id,
              x_return_status   => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history
l_return_status',l_return_status);
END IF;
wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     IF ( get_revision_number_csr%ISOPEN) THEN
        CLOSE get_revision_number_csr;
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     IF ( get_revision_number_csr%ISOPEN) THEN
        CLOSE get_revision_number_csr;
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Validate_Header;


-- Start of comments
-- API name : Validate_Org
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to validate Operating Unit. Api validate operating Unit name against HR_ORGANIZATION_UNITS table.
--
-- Parameters :
-- IN:
--      p_org_name   IN  Operating Unit Name.
-- OUT:
--      x_org_id 	OUT NOCOPY      org Id
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Validate_Org(
          p_org_name      IN varchar2,
          x_org_id        OUT NOCOPY number,
          x_return_status OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ORG';
l_return_status	varchar2(1);

--Cursor to validate Operating Unit
CURSOR get_org_csr(p_org_name	varchar2) IS
SELECT organization_id
  FROM   HR_ORGANIZATION_UNITS
  WHERE  name = p_org_name;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_org_name',p_org_name);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Validate operating Unit name against HR_ORGANIZATION_UNITS table.
OPEN get_org_csr(p_org_name);
FETCH get_org_csr INTO x_org_id;
CLOSE get_org_csr;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_org_id',x_org_id);
END IF;
IF (x_org_id is NULL) THEN
       raise fnd_api.g_exc_error;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ORG');
     fnd_msg_pub.add;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;


END validate_org;


-- Start of comments
-- API name : Process_Routing_Request
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to validate and upload routing request. Api does
--           1.Error if any one of header, delivery or line record has no data.
--           2.Sequence of processing is first scanning through header record,then
--             lines and then corresponding delivery associate to line.
--           3.Scan through Header Record, does header level validation.
--           4.Scan through line record, if
--             4.1 Delivery is invalid ,ignore remaining lines
--             4.2 Correction validation.
--             4.3 Validate Operation Unit
--             4.4 When delivery change for line ,Validate Delivery level
--                 information.
--           5.Get the detail info based on cursor get_po_info_csr
--             5.1 If not found then try to get the detail info based on cursor
--                 get_po_not_found_detail.
--              5.1.1  If not found then Error
--          5.2 else
--              5.2.1 Validate the PO for correct status.
--              5.2.2 Create a PO line in wsh_delivery_detail.
--              5.2.3 Collect detail line information for updating/splitting
--         6.Validate line level information.
--         7.Update and Split the detail line with routing request line information.
--         8.Collect the updated line delivery_detail_id's.
--         9.When delivery change for line auto create delivery for these lines.
--
-- Parameters :
-- IN:
--	  p_in_param      IN	  Type In_param_Rec_Type,hold additional Input Parameter from Routing Request UI.
--        p_header        IN  OUT Type Header_Rec_type,hold header information of Routing Request file.
--        p_delivery      IN  OUT Type Delivery_Rec_Type,hold delivery information of Routing Request file.
--        p_line          IN  OUT Type Line_Rec_Type,hold line information of Routing Request file.
-- OUT:
--      x_success_tbl   OUT NOCOPY      List of output message need to be displayed in Routing Request UI.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Routing_Request(
	p_in_param      IN	In_param_Rec_Type,
        p_header        IN  OUT NOCOPY  Header_Rec_type,
        p_delivery      IN  OUT NOCOPY  Delivery_Rec_Type ,
        p_line          IN  OUT NOCOPY  Line_Rec_Type,
        x_success_tbl   IN  OUT NOCOPY  WSH_FILE_MSG_TABLE,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Routing_Request';

--This cursor is used to get the open detail lines, which are not
--associate to routing request for input PO attributes.
CURSOR get_po_not_found_detail (p_org_id                number,
                        p_po_header_number      varchar2,
                        p_po_line_number        varchar2,
                        p_po_release_number     number,
                        p_po_shipment_number    number,
			p_vendor_id		number) IS
SELECT delivery_detail_id,
        organization_id,
        source_header_id,
        source_line_id,
        po_shipment_line_id,
        source_blanket_reference_id,
        inventory_item_id,
	weight_uom_code,
	volume_uom_code,
	routing_req_id,
	requested_quantity,
	nvl(requested_quantity2,0) requested_quantity2,
	requested_quantity_uom,
	requested_quantity_uom2,
	org_id,
	source_code,
	released_status,
	source_header_type_id,
	source_header_type_name,
	date_requested,
	earliest_dropoff_date,
	latest_dropoff_date,
        shipping_control
  FROM   wsh_delivery_details
  WHERE  org_id=p_org_id
  AND    source_header_number = p_po_header_number
  AND    source_line_number = p_po_line_number
  AND    po_shipment_line_number = p_po_shipment_number
  AND    nvl(SOURCE_BLANKET_REFERENCE_NUM,-1) =nvl(nvl(p_po_release_number, SOURCE_BLANKET_REFERENCE_NUM),-1)
  AND    nvl(line_direction,'O') not in ('O','IO')
  AND    vendor_id = p_vendor_id
  AND	 source_code='PO';

l_po_not_found_detail	get_po_not_found_detail%ROWTYPE;

--This cursor is used to get the detail line attributes,
--when open lines are not present for input PO attributes.
CURSOR get_po_info_csr (p_org_id                number,
      			p_po_header_number 	varchar2,
                        p_po_line_number	varchar2,
                        p_po_release_number	number,
                        p_po_shipment_number    number,
			p_vendor_id		number) IS
SELECT delivery_detail_id,
        source_header_id,
        source_line_id,
	organization_id,
        inventory_item_id,
	weight_uom_code,
	volume_uom_code,
	routing_req_id,
	requested_quantity,
	requested_quantity_uom,
	nvl(requested_quantity2,0) requested_quantity2,
	requested_quantity_uom2,
        po_shipment_line_id,
        source_blanket_reference_id,
        nvl(net_weight,0) net_weight,
        nvl(gross_weight,0) gross_weight,
        nvl(volume,0) volume,
        wv_frozen_flag
  FROM   wsh_delivery_details
  WHERE  org_id=p_org_id
  AND    source_header_number = p_po_header_number
  AND    source_line_number = p_po_line_number
  AND    po_shipment_line_number = p_po_shipment_number
  AND    nvl(SOURCE_BLANKET_REFERENCE_NUM,-1) =nvl(nvl(p_po_release_number, SOURCE_BLANKET_REFERENCE_NUM),-1)
  AND    nvl(line_direction,'O') not in ('O','IO')
  AND    vendor_id = p_vendor_id
  AND    routing_req_id IS NULL
  AND    shipping_control = 'BUYER'
  AND    released_status = 'X'
  AND	 source_code='PO'
  FOR UPDATE NOWAIT ; --halock

e_wdd_locked EXCEPTION ;
PRAGMA  EXCEPTION_INIT(e_wdd_locked,-54);
--halock

l_detail_att		detail_att_rec_type;
l_del_ids		wsh_util_core.id_tab_type;
l_new_detail_ids       	wsh_util_core.id_tab_type;
l_sum_new_detail_ids    wsh_util_core.id_tab_type;

e_delivery_invalid	exception;
e_ignore_line		exception;

l_dd_net_weight		number;
l_dd_gross_weight	number;
l_dd_volume		number;
l_wv_frozen_flag	varchar2(1);
l_return_status		varchar2(1);
l_header_index		number;
l_delivery_index	number;
l_prev_delivery_index	number;
l_line_index		number;
l_index			number;
l_msg_count		number:=0;
l_line_last		number;
l_line_first		number;
l_id			number;
l_del_new_index		number;

l_tmp			varchar2(2000);
l_header_error		number:=0;

l_po_rec_found		boolean:= false;
l_detail_ids            wsh_util_core.id_tab_type;
l_new_deliveries	wsh_util_core.id_tab_type;
l_total_req_qty 	number:= 0;
l_total_req_qty2 	number:= 0;
l_item_qty 		number;

l_weight 		number;
l_volume 		number;
l_warn_count		number:=0;
l_num_warnings          number;
l_num_errors            number;
l_supplier_name		varchar2(2000);
l_organization_id	number;

BEGIN
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.logmsg(l_module_name,'heali');
    WSH_DEBUG_SV.log(l_module_name,'p_header.count',p_header.supplier_name.count);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery.count',p_delivery.ship_from_address1.count);
    WSH_DEBUG_SV.log(l_module_name,'p_line.count',p_line.po_header_number.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;

--Error if any one of header,delivery or line record has no data.
IF (p_header.supplier_name.count <> 1 OR p_delivery.ship_from_address1.count < 1 OR p_line.po_header_number.count < 1) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_RR_INV_FILE_FORMAT');
    fnd_msg_pub.add;
    raise FND_API.G_EXC_ERROR;
END IF;

l_header_index := p_header.supplier_name.first;
WHILE (l_header_index IS NOT NULL)  LOOP  --{ Header Loop
BEGIN
    --Loop through header record.

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_header_index',l_header_index);
    END IF;


    -- Hedaer is invalid ,ignore remaining lines
    IF ( p_header.error_flag(l_header_index) = 'Y' ) THEN
       raise FND_API.G_EXC_ERROR;
    END IF;


    --Call api to handle header level validation.
    Validate_Header(
	p_in_param      	=>p_in_param,
        p_request_number	=>p_header.request_number(l_header_index),
        p_request_revision	=>p_header.request_revision(l_header_index),
        p_supplier_name		=>p_header.supplier_name(l_header_index),
        p_line_number		=>l_header_index,
        p_detail_att		=>l_detail_att,
        x_return_status		=>l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Validate_Header l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    l_supplier_name:=p_header.supplier_name(l_header_index);

    l_line_last := p_line.po_header_number.last;
    l_line_first := p_line.po_header_number.first;
    l_line_index := l_line_first;

    WHILE (l_line_index IS NOT NULL)  LOOP  --{ Line Loop
    BEGIN
       --Loop through line record.

       l_delivery_index := p_line.delivery_line_number(l_line_index);

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'---------------------');
          WSH_DEBUG_SV.log(l_module_name,'l_line_index',l_line_index);
          WSH_DEBUG_SV.log(l_module_name,'l_delivery_index',l_delivery_index);
          WSH_DEBUG_SV.log(l_module_name,'l_prev_delivery_index',l_prev_delivery_index);
          WSH_DEBUG_SV.log(l_module_name,'p_delivery.error_flag',p_delivery.error_flag(l_delivery_index));
          WSH_DEBUG_SV.log(l_module_name,'p_line.item_quantity',p_line.item_quantity(l_line_index));
          WSH_DEBUG_SV.log(l_module_name,'prev_routing_req_id',l_detail_att.prev_routing_req_id);
          WSH_DEBUG_SV.log(l_module_name,'Message Count :',FND_MSG_PUB.Count_Msg);
       END IF;

       l_new_detail_ids.delete;

       IF (l_prev_delivery_index IS NOT NULL and l_prev_delivery_index <> l_delivery_index) THEN --{
          --Create the previous delivery

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Creating Previous Delivery');
          WSH_DEBUG_SV.log(l_module_name,'Delivery Error flag',p_delivery.error_flag(l_prev_delivery_index));
          WSH_DEBUG_SV.log(l_module_name,'l_sum_new_detail_ids.count',l_sum_new_detail_ids.count);
         END IF;

         IF (p_delivery.error_flag(l_prev_delivery_index) <> 'Y' and l_sum_new_detail_ids.count > 0) THEN

          Create_Delivery(
              p_detail_ids            => l_sum_new_detail_ids,
              p_delivery_index        => l_prev_delivery_index,
              p_delivery              => p_delivery,
              x_new_deliveries        => l_new_deliveries,
              x_return_status         => l_return_status);

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Create_Delivery l_return_status',l_return_status);
               WSH_DEBUG_SV.log(l_module_name,'l_new_deliveries.count',l_new_deliveries.count);
            END IF;

            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
             l_del_new_index:=l_new_deliveries.first;
             WHILE (l_del_new_index IS NOT NULL) LOOP
                IF (p_in_param.caller='ISP') THEN
                   --If caller ic ISP than do not displayed the delivery name.
                   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      l_warn_count:=l_warn_count + 1;
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_WARN');
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_delivery_index);
                      fnd_msg_pub.add;
                   ELSE
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_SUCCESS');
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_delivery_index);
                   END IF;
                ELSE
                   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      l_warn_count:=l_warn_count + 1;
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_WSH_DEL_WARN');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(l_new_deliveries(l_del_new_index)));
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_delivery_index);
                      fnd_msg_pub.add;
                   ELSE
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_WSH_DEL_SUCCESS');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(l_new_deliveries(l_del_new_index)));
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_delivery_index);
                   END IF;
                END IF;

                IF (l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                   l_msg_count:= l_msg_count + 1;
                   x_success_tbl.extend;
                   x_success_tbl(l_msg_count):= FND_MESSAGE.GET;
                END IF;

             l_del_new_index:=l_new_deliveries.next(l_del_new_index);
             END LOOP;

            ELSE
                p_delivery.error_flag(l_prev_delivery_index):='Y';
                FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
                FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_delivery_index);
                fnd_msg_pub.add;

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Rollback to save point l_delivery_savepoint');
                END IF;
                rollback to savepoint l_delivery_savepoint;
            END IF;

         END IF;

         --Create current delivery
         l_sum_new_detail_ids.delete;
         l_new_deliveries.delete;

       END IF;--}



       --Delivery is invalid ,ignore remaining lines.
       IF ( p_delivery.error_flag(l_delivery_index) = 'Y' ) THEN
           raise e_delivery_invalid;
       END IF;


       -- No processing has to do with cancel line here.
       IF (p_line.item_quantity(l_line_index) = 0 AND l_detail_att.prev_routing_req_id is NOT NULL) THEN
          raise e_ignore_line;
       END IF;


       --If delivery changes in line, validate the new delivery.
       --This is because sequence of processing is line and associated delivery.
       IF (nvl(l_prev_delivery_index,-99) <> l_delivery_index) THEN --{

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Establishing save point l_delivery_savepoint');
          END IF;
          savepoint l_delivery_savepoint;

          IF ( p_delivery.error_flag(l_delivery_index) <> 'Y' ) THEN

             Validate_Delivery(
        	p_detail_att     => l_detail_att,
        	p_delivery_index => l_delivery_index,
        	p_delivery	 => p_delivery,
      		x_return_status  => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Validate_Delivery l_return_status',l_return_status);
             END IF;

          wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

          END IF;


       END IF; --}

       -- First Routing Request should not be correction.
       -- A correction is routing request line with zero quantity.
       IF (p_line.item_quantity(l_line_index) = 0 AND l_detail_att.prev_routing_req_id is NULL) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_INVALID_CORRECTION');
          fnd_msg_pub.add;

          raise FND_API.G_EXC_ERROR;
       END IF;

       --Validate Operation Unit
       Validate_Org(
      		p_org_name	=> p_line.po_operating_unit(l_line_index),
		x_org_id	=> l_detail_att.org_id,
      		x_return_status => l_return_status);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Org l_return_status',l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_org_id',l_detail_att.org_id);
          END IF;

        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);



       --Validation for existing PO reference information
       l_po_rec_found:= false;
       l_detail_ids.delete;
       l_total_req_qty := 0;
       l_total_req_qty2 := 0;

       l_dd_net_weight:=0;
       l_dd_gross_weight:=0;
       l_dd_volume:=0;
       l_wv_frozen_flag:='N';


       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'org_id',l_detail_att.org_id);
          WSH_DEBUG_SV.log(l_module_name,'po_header_number',p_line.po_header_number(l_line_index));
          WSH_DEBUG_SV.log(l_module_name,'po_line_number',p_line.po_line_number(l_line_index));
          WSH_DEBUG_SV.log(l_module_name,'po_release_number',p_line.po_release_number(l_line_index));
          WSH_DEBUG_SV.log(l_module_name,'po_shipment_number',p_line.po_shipment_number(l_line_index));
          WSH_DEBUG_SV.log(l_module_name,'vendor_id',l_detail_att.vendor_id);
       END IF;

       --Cursor to get the valid PO details from wsh_delivery_detail table.
       FOR l_po_info IN get_po_info_csr(l_detail_att.org_id, --{
			    p_line.po_header_number(l_line_index),
                            p_line.po_line_number(l_line_index),
                            p_line.po_release_number(l_line_index),
                            p_line.po_shipment_number(l_line_index),
			    l_detail_att.vendor_id)
       LOOP
          l_po_rec_found:= true;

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'WDD line found');
          END IF;

          IF ( (l_po_info.source_blanket_reference_id IS NOT NULL
                 AND p_line.po_release_number(l_line_index) IS NULL)
               OR
               (l_po_info.source_blanket_reference_id IS NULL
                 AND p_line.po_release_number(l_line_index) IS NOT NULL)
             ) THEN

             raise FND_API.G_EXC_ERROR;
          END IF;


          --Validate the PO for correct status.
          Validate_PO(
             p_header_id              => l_po_info.source_header_id,
             p_header                 => p_line.po_header_number(l_line_index),
             p_line_id                => l_po_info.source_line_id,
             p_line_location_id       => l_po_info.po_shipment_line_id,
             p_release_id             => l_po_info.source_blanket_reference_id,
             x_return_status          => l_return_status);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Validate_PO l_return_status',l_return_status);
          END IF;

          wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Before updates');
             WSH_DEBUG_SV.log(l_module_name,'l_po_info.delivery_detail_id',l_po_info.delivery_detail_id);
             WSH_DEBUG_SV.log(l_module_name,'l_po_info.requested_quantity',l_po_info.requested_quantity);
             WSH_DEBUG_SV.log(l_module_name,'l_total_req_qty',l_total_req_qty);
             WSH_DEBUG_SV.log(l_module_name,'l_total_req_qty2',l_total_req_qty2);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_net_weight',l_dd_net_weight);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_gross_weight',l_dd_gross_weight);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_volume',l_dd_volume);
             WSH_DEBUG_SV.log(l_module_name,'l_wv_frozen_flag',l_wv_frozen_flag);
          END IF;

          --Collect the attributes of detail line and
          --sum of requested quantities,weight and volume.
          l_detail_ids(l_detail_ids.count+1) := l_po_info.delivery_detail_id;
          l_total_req_qty := l_total_req_qty + l_po_info.requested_quantity;
          l_total_req_qty2 := l_total_req_qty2 + nvl(l_po_info.requested_quantity2,0);
          l_detail_att.inventory_item_id := l_po_info.inventory_item_id;
          l_detail_att.requested_quantity_uom := l_po_info.requested_quantity_uom;
          l_detail_att.requested_quantity_uom2 := l_po_info.requested_quantity_uom2;
          l_organization_id:=l_po_info.organization_id;

          l_dd_net_weight:= l_dd_net_weight + l_po_info.net_weight;
          l_dd_gross_weight:= l_dd_gross_weight + l_po_info.gross_weight;
          l_dd_volume:= l_dd_volume + l_po_info.volume;

          IF (l_po_info.wv_frozen_flag='Y') THEN
             l_wv_frozen_flag:='Y';
          END IF;

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'After updates');
             WSH_DEBUG_SV.log(l_module_name,'l_total_req_qty',l_total_req_qty);
             WSH_DEBUG_SV.log(l_module_name,'l_total_req_qty2',l_total_req_qty2);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_net_weight',l_dd_net_weight);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_gross_weight',l_dd_gross_weight);
             WSH_DEBUG_SV.log(l_module_name,'l_dd_volume',l_dd_volume);
             WSH_DEBUG_SV.log(l_module_name,'l_wv_frozen_flag',l_wv_frozen_flag);
          END IF;
       END LOOP; --}


       --If PO information not found in above case,
       --try to get the PO line information based on header,line,release
       --and shipment number using cursor get_po_not_found_detail.
       IF (NOT l_po_rec_found) THEN --{
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'No WDD line found');
          END IF;

          OPEN get_po_not_found_detail (l_detail_att.org_id,
			    p_line.po_header_number(l_line_index),
                            p_line.po_line_number(l_line_index),
                            p_line.po_release_number(l_line_index),
                            p_line.po_shipment_number(l_line_index),
			    l_detail_att.vendor_id);

          FETCH get_po_not_found_detail INTO  l_po_not_found_detail;

          IF (get_po_not_found_detail%FOUND) THEN

             --If transportation is not arranged by Buyer than error.
             IF (l_po_not_found_detail.shipping_control <> 'BUYER') THEN
                CLOSE get_po_not_found_detail;
                FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_BUYER_PO');
                FND_MESSAGE.SET_TOKEN('PO_NUMBER', p_line.po_header_number(l_line_index));
                fnd_msg_pub.add;

                raise FND_API.G_EXC_ERROR;
             END IF;

             IF ( (l_po_not_found_detail.source_blanket_reference_id IS NOT NULL
                    AND p_line.po_release_number(l_line_index) IS NULL)
                  OR
                  (l_po_not_found_detail.source_blanket_reference_id IS NULL
                    AND p_line.po_release_number(l_line_index) IS NOT NULL)
                ) THEN
                raise FND_API.G_EXC_ERROR;
             END IF;

             --PO line found, validate for correct PO status.
             Validate_PO(
                p_header_id              => l_po_not_found_detail.source_header_id,
                p_header                 => p_line.po_header_number(l_line_index),
                p_line_id                => l_po_not_found_detail.source_line_id,
                p_line_location_id       => l_po_not_found_detail.po_shipment_line_id,
                p_release_id             => l_po_not_found_detail.source_blanket_reference_id,
                x_return_status          => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Validate_PO l_return_status',l_return_status);
             END IF;

             wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

             --Collect the line attributes for creating new line in wsh_delivery_details.
             l_detail_att.source_header_number := p_line.po_header_number(l_line_index);
             l_detail_att.inventory_item_id := l_po_not_found_detail.inventory_item_id;
             l_detail_att.requested_quantity_uom := l_po_not_found_detail.requested_quantity_uom;
             l_detail_att.requested_quantity_uom2 := l_po_not_found_detail.requested_quantity_uom2;
             l_detail_att.org_id := l_po_not_found_detail.org_id;
             l_detail_att.source_code := l_po_not_found_detail.source_code;
             l_detail_att.released_status := 'X';
             l_detail_att.source_header_type_id := l_po_not_found_detail.source_header_type_id;
             l_detail_att.source_header_type_name := l_po_not_found_detail.source_header_type_name;
             l_detail_att.date_requested:= l_po_not_found_detail.date_requested;
             l_detail_att.earliest_dropoff_date:= l_po_not_found_detail.earliest_dropoff_date;
             l_detail_att.latest_dropoff_date:= l_po_not_found_detail.latest_dropoff_date;
             l_organization_id:=l_po_not_found_detail.organization_id;

             --Create a PO line in wsh_delivery_detail for over picked qty.
             Create_PO( p_po_line_location_id      => l_po_not_found_detail.po_shipment_line_id,
                        p_detail_att               => l_detail_att,
                     	x_delivery_detail_id       => l_detail_att.delivery_detail_id,
                     	x_return_status            => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Create_PO l_return_status',l_return_status);
             END IF;
             wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

             l_detail_ids(l_detail_ids.count+1) := l_detail_att.delivery_detail_id;
             l_total_req_qty := 0;
             l_total_req_qty2 :=  0;
          ELSE
             --Detail lines are not found for input PO, error out.
             CLOSE get_po_not_found_detail;
             FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_PO_INFO');
             FND_MESSAGE.SET_TOKEN('SUPPLIER', l_supplier_name);
             FND_MESSAGE.SET_TOKEN('HRD_NUMBER', p_line.po_header_number(l_line_index));
             FND_MESSAGE.SET_TOKEN('REL_NUMBER', p_line.po_release_number(l_line_index));
             FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_line.po_line_number(l_line_index));
             FND_MESSAGE.SET_TOKEN('SHIP_NUMBER', p_line.po_shipment_number(l_line_index));
             FND_MESSAGE.SET_TOKEN('OP_UNIT', p_line.po_operating_unit(l_line_index));
             fnd_msg_pub.add;
             raise FND_API.G_EXC_ERROR;
          END IF;

          CLOSE get_po_not_found_detail;
       END IF; --}


       --If delivery changes in line, validate the delivery for UOM's.
       --This is done after getting the line information because
       --organization_id is need for UOM's validation.
       IF (nvl(l_prev_delivery_index,-99) <> l_delivery_index) THEN --{
          IF ( p_delivery.error_flag(l_delivery_index) <> 'Y' ) THEN
             Validate_Delivery_uom(
                p_organization_id => l_organization_id,
                p_delivery_index => l_delivery_index,
                p_delivery       => p_delivery,
                x_return_status  => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Validate_Delivery_uom l_return_status',l_return_status);
             END IF;

             wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);

          END IF;
       END IF; --}


       --Validate line level data of Routing Request.
       Validate_line(
             p_organization_id        => l_organization_id,
             p_item_id                => l_detail_att.inventory_item_id,
             p_detail_item_uom_code   => l_detail_att.requested_quantity_uom,
             x_detail_item_qty        => l_item_qty,
             p_detail_weight_uom_code => l_detail_att.weight_uom,
             x_detail_weight_qty      => l_weight,
             p_detail_volume_uom_code => l_detail_att.volume_uom,
             x_detail_volume_qty      => l_volume,
             p_line_index             => l_line_index,
             p_line                   => p_line,
             x_return_status          => l_return_status);

       IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Validate_line l_return_status',l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_item_qty',l_item_qty);
       END IF;
       wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);


       l_detail_att.requested_quantity := l_total_req_qty;
       l_detail_att.requested_quantity2 := l_total_req_qty2;
       l_detail_att.item_quantity := l_item_qty;
       l_detail_att.weight := p_line.weight(l_line_index);
       l_detail_att.weight_uom := p_line.weight_uom(l_line_index);
       l_detail_att.volume := p_line.volume(l_line_index);
       l_detail_att.volume_uom := p_line.volume_uom(l_line_index);
       l_detail_att.Earliest_pickup_date := p_line.Earliest_pickup_date(l_line_index);
       l_detail_att.Latest_pickup_date := p_line.Latest_pickup_date(l_line_index);

       l_detail_att.dd_net_weight:= l_dd_net_weight;
       l_detail_att.dd_gross_weight:= l_dd_gross_weight;
       l_detail_att.dd_volume:= l_dd_volume;
       l_detail_att.dd_wv_frozen_flag:=l_wv_frozen_flag;


       --Update and Split the detail line with routing request line information.
       Update_Split_Details(
        p_detail_att            => l_detail_att,
        p_detail_ids            => l_detail_ids,
        x_new_detail_ids        => l_new_detail_ids,
        x_return_status         => l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Update_Split_Details l_return_status',l_return_status);
       END IF;
       wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

       IF (l_new_detail_ids.count > 1) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Line e_line_error :',l_return_status);
       END IF;

          p_line.error_flag(l_line_index):='Y';
          p_delivery.error_flag(l_delivery_index):='Y';
          FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
          fnd_msg_pub.add;

        IF (get_po_not_found_detail%ISOPEN) THEN
          CLOSE get_po_not_found_detail;
        END IF;

        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Line Rollback to save point l_delivery_savepoint');
        END IF;
        rollback to savepoint l_delivery_savepoint;

      --halock
      WHEN e_wdd_locked THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Detail lines are locked:',l_line_index);
          END IF;

          p_line.error_flag(l_line_index):='Y';
          p_delivery.error_flag(l_delivery_index):='Y';

          FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
          fnd_msg_pub.add;

          FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
          fnd_msg_pub.add;

          IF (get_po_not_found_detail%ISOPEN) THEN
             CLOSE get_po_not_found_detail;
          END IF;

           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Line Rollback to save point l_delivery_savepoint');
           END IF;
           rollback to savepoint l_delivery_savepoint;
      --halock

      WHEN e_ignore_line THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Line e_ignore_line');
       END IF;


      WHEN e_delivery_invalid THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Line e_delivery_invalid');
       END IF;

      WHEN others THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Line others');
       END IF;
        p_line.error_flag(l_line_index):='Y';
        p_delivery.error_flag(l_delivery_index):='Y';

        FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
        FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
        fnd_msg_pub.add;

        FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
        fnd_msg_pub.add;
    END;


    l_id := l_new_detail_ids.first;
    WHILE (l_id IS NOT NULL ) LOOP
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Collecting detail ids',l_new_detail_ids(l_id));
          END IF;
          l_sum_new_detail_ids(l_sum_new_detail_ids.count + 1):=l_new_detail_ids(l_id);

    l_id := l_new_detail_ids.next(l_id);
    END LOOP;

    l_new_detail_ids.delete;


    IF ( l_line_last = l_line_index  and p_delivery.error_flag(l_delivery_index) <> 'Y' and l_sum_new_detail_ids.count > 0) THEN
    --{

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Creating last delivery');
             WSH_DEBUG_SV.log(l_module_name,'l_sum_new_detail_ids.count',l_sum_new_detail_ids.count);
          END IF;

         Create_Delivery(
              p_detail_ids            => l_sum_new_detail_ids,
              p_delivery_index        => l_delivery_index,
              p_delivery              => p_delivery,
              x_new_deliveries        => l_new_deliveries,
              x_return_status         => l_return_status);


          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Create_Delivery l_return_status',l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_new_deliveries.count',l_new_deliveries.count);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
             l_del_new_index:=l_new_deliveries.first;
             WHILE (l_del_new_index IS NOT NULL) LOOP
                IF (p_in_param.caller='ISP') THEN
                   --If caller ic ISP than do not displayed the delivery name.
                   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      l_warn_count:=l_warn_count + 1;
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_WARN');
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
                      fnd_msg_pub.add;
                   ELSE
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_SUCCESS');
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
                   END IF;
                ELSE
                   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      l_warn_count:=l_warn_count + 1;
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_WSH_DEL_WARN');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(l_new_deliveries(l_del_new_index)));
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
                      fnd_msg_pub.add;
                   ELSE
                      FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_WSH_DEL_SUCCESS');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(l_new_deliveries(l_del_new_index)));
                      FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
                   END IF;
                END IF;

                IF (l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                   l_msg_count:= l_msg_count + 1;
                   x_success_tbl.extend;
                   x_success_tbl(l_msg_count):= FND_MESSAGE.GET;
                END IF;

             l_del_new_index:=l_new_deliveries.next(l_del_new_index);
             END LOOP;

          ELSE
                p_delivery.error_flag(l_delivery_index):='Y';
                FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
                FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_delivery_index);
                fnd_msg_pub.add;

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Rollback to save point l_delivery_savepoint');
                END IF;
                rollback to savepoint l_delivery_savepoint;
          END IF;

          --Once Delivery created, initialized the table for line id's.
          l_sum_new_detail_ids.delete;
         l_new_deliveries.delete;

    END IF; --}


    --Store the current delivery for comparison with next delivery.
    l_prev_delivery_index := l_delivery_index;


    l_line_index := p_line.po_header_number.next(l_line_index);
    END LOOP; --} Line Loop


EXCEPTION
   WHEN  FND_API.G_EXC_ERROR THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Header error: ',l_return_status);
       END IF;

        l_header_error := l_header_error + 1;
        p_header.error_flag(l_header_index):='Y';
        FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_HEADER_FAILED');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_header_index);
        fnd_msg_pub.add;


   WHEN others THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Header others');
       END IF;
     l_header_error := l_header_error + 1;
     p_header.error_flag(l_header_index):='Y';

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_HEADER_FAILED');
     FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_header_index);
     fnd_msg_pub.add;

END;

l_header_index := p_header.supplier_name.next(l_header_index);
END LOOP; --} Header Loop


IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_warn_count',l_warn_count);
END IF;
IF (l_warn_count > 0 ) THEN
     raise wsh_util_core.g_exc_warning;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_header_error',l_header_error);
END IF;

IF (l_header_error >= p_header.supplier_name.count) THEN
     --All header records are error.
     raise FND_API.G_EXC_ERROR;
ELSIF (l_header_error < p_header.supplier_name.count and l_header_error > 0 ) THEN
     --Error header record is grater than one and less the total header records.
     raise wsh_util_core.g_exc_warning;
END IF;

--If all the deliveries are error than error out.
Is_All_Line_Error(p_error_tbl          => p_delivery.error_flag,
                   x_return_status      => x_return_status);
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Is_All_Line_Error x_return_status',x_return_status);
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN wsh_util_core.g_exc_warning THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.g_exc_warning
exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;


WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Process_Routing_Request;


-- Start of comments
-- API name : Process_Routing_Request_File
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to create header,delivery and line records from input of Routing Request records as passed by UI. Api does.
--            1.Create blank header,delivery and line record.
--            2.Loop through routing request record as pass by UI.
--            3.Validate header,delivery and line field and assign field
--              value to corresponding level.
--            4.Scan through record created to find missing column.
--            5.Check if not all the records have errors..
--            6.Finally call api Process_Routing_request to process
--              Routing Request records.
--
-- Parameters :
-- IN:
--      p_in_param      IN  Hold additional parameter passed by UI.
--      p_file_fields   IN  Hold Routing Request records as passed by UI
-- OUT:
--      x_message_tbl   OUT NOCOPY List of Success/Error messages passed back to UI for display.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_Routing_Request_File(
        p_in_param	IN	In_param_Rec_Type,
        p_file_fields   IN WSH_FILE_RECORD_TYPE ,
        x_message_tbl   OUT  NOCOPY  WSH_FILE_MSG_TABLE,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Routing_Request_File';
l_return_status	varchar2(1);
l_index	number;
l_hi	number;
l_di	number;
l_li	number;
l_debugfile	varchar2(2000);
l_line_index	number:=0;
l_msg_count	number:=0;

l_last_index    number;
l_prev_line_number      number;
l_prev_level_number	number;

l_header		Header_Rec_Type;
l_delivery		Delivery_Rec_Type;
l_line	      		Line_Rec_Type;
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;
l_num_warnings   NUMBER;
l_num_errors     NUMBER;

BEGIN

--Bugfix 4070732
l_num_warnings := 0;
l_num_errors   := 0;
IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
   WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
   WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
END IF;

l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_file_fields.level_number.count',p_file_fields.level_number.count);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Initialized message and validation meta data.
x_message_tbl := WSH_FILE_MSG_TABLE();
g_error_tbl.delete;
Init_Routing_Req_Validation;

l_last_index:= p_file_fields.level_number.last;
l_index := p_file_fields.level_number.first;
l_prev_line_number:= p_file_fields.file_line_number(l_index);

--Based on level information, create blank record for that level.
IF (p_file_fields.level_number(l_index) = 1 ) THEN
    Create_Header_Record(p_header	=>l_header,
	       p_index		=>l_prev_line_number,
               x_return_status  =>l_return_status);
ELSIF (p_file_fields.level_number(l_index) = 2 ) THEN
    Create_Delivery_Record(p_delivery	=>l_delivery,
	       p_index		=>l_prev_line_number,
               x_return_status  =>l_return_status);
ELSIF (p_file_fields.level_number(l_index) = 3 ) THEN
    Create_Line_Record(p_line	=>l_line,
	       p_index		=>l_prev_line_number,
               x_return_status  =>l_return_status);
END IF;


IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
   raise FND_API.G_EXC_ERROR;
END IF;

WHILE (l_index IS NOT NULL ) LOOP --{
   g_file_line_number := p_file_fields.file_line_number(l_index);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
      WSH_DEBUG_SV.log(l_module_name,'l_prev_line_number',l_prev_line_number);
      WSH_DEBUG_SV.log(l_module_name,'g_file_line_number',g_file_line_number);
      WSH_DEBUG_SV.log(l_module_name,'l_prev_level_number',l_prev_level_number);
   END IF;

   --When file number changes
   IF ( l_prev_line_number <> g_file_line_number) THEN --{
      --Create Record when level changes
      IF (p_file_fields.level_number(l_index) = 1 ) THEN
         Create_Header_Record(p_header	=>l_header,
	       p_index		=>g_file_line_number,
               x_return_status  =>l_return_status);
      ELSIF (p_file_fields.level_number(l_index) = 2 ) THEN
         Create_Delivery_Record(p_delivery	=>l_delivery,
	       p_index		=>g_file_line_number,
               x_return_status  =>l_return_status);
      ELSIF (p_file_fields.level_number(l_index) = 3 ) THEN
         Create_Line_Record(p_line	=>l_line,
	       p_index		=>g_file_line_number,
               x_return_status  =>l_return_status);
      END IF;

      --Check for missing column
      IF (Find_Miss_Column(l_prev_level_number) ) THEN
         IF (l_prev_level_number = 1) THEN
              l_header.error_flag(l_prev_line_number):='Y';
         ELSIF (l_prev_level_number = 2) THEN
              l_delivery.error_flag(l_prev_line_number):='Y';
         ELSIF (l_prev_level_number = 3) THEN
              l_line.error_flag(l_prev_line_number):='Y';
              l_delivery.error_flag(l_line.delivery_line_number(l_prev_line_number)):='Y';
         END IF;
      END IF;

      --Display error for corresponding level.
      IF (l_prev_level_number = 1) THEN
         IF ( l_header.error_flag(l_prev_line_number)='Y') THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_HEADER_FAILED');
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_line_number);
           fnd_msg_pub.add;
         END IF;
      ELSIF (l_prev_level_number = 2) THEN
         IF (l_delivery.error_flag(l_prev_line_number)='Y') THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_line_number);
           fnd_msg_pub.add;
         END IF;
      ELSIF (l_prev_level_number = 3) THEN
         IF (l_line.error_flag(l_prev_line_number)='Y') THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line.delivery_line_number(l_prev_line_number));
           fnd_msg_pub.add;
         END IF;
      END IF;

   END IF; --}


   IF (p_file_fields.level_number(l_index) = 1 ) THEN
      --Validate Header data and assign to newly created record.
      Process_Header(
        p_col_name	=> p_file_fields.col_name(l_index),
        p_col_value   	=> ltrim(rtrim(p_file_fields.col_value(l_index))),
        p_index         => p_file_fields.file_line_number(l_index),
        p_header        => l_header,
        x_return_status => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_header l_return_status',l_return_status);
      END IF;
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         l_header.error_flag(g_file_line_number):='Y';
      END IF;

   ELSIF (p_file_fields.level_number(l_index) = 2 ) THEN
       l_delivery.header_line_number(p_file_fields.file_line_number(l_index)):= p_file_fields.Level_Ref_Number(l_index);

      --Validate Delivery data and assign to newly created record.
       Process_Delivery (
        p_col_name	=> p_file_fields.col_name(l_index),
        p_col_value   	=> ltrim(rtrim(p_file_fields.col_value(l_index))),
        p_index         => p_file_fields.file_line_number(l_index),
        p_delivery      => l_delivery,
        x_return_status => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_Delivery l_return_status',l_return_status);
      END IF;
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         l_delivery.error_flag(g_file_line_number):='Y';
      END IF;

   ELSIF (p_file_fields.level_number(l_index) = 3 ) THEN
      l_line.delivery_line_number(p_file_fields.file_line_number(l_index)):= p_file_fields.Level_Ref_Number(l_index);

      --Validate Line data and assign to newly created record.
        Process_Line(
        p_col_name	=> p_file_fields.col_name(l_index),
        p_col_value   	=> ltrim(rtrim(p_file_fields.col_value(l_index))),
        p_index         => p_file_fields.file_line_number(l_index),
        p_Line        	=> l_Line,
        x_return_status => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_Line l_return_status',l_return_status);
      END IF;
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         l_Line.error_flag(g_file_line_number):='Y';
         l_delivery.error_flag(p_file_fields.Level_Ref_Number(l_index)):='Y';
      END IF;
   END IF;

   l_prev_level_number:= p_file_fields.level_number(l_index);
   l_prev_line_number:= g_file_line_number;

l_index :=p_file_fields.level_number.next(l_index);
END LOOP; --}

--Check for missing column in last level
IF (Find_Miss_Column(l_prev_level_number) ) THEN
   IF (l_prev_level_number = 1) THEN
      l_header.error_flag(l_prev_line_number):='Y';
   ELSIF (l_prev_level_number = 2) THEN
      l_delivery.error_flag(l_prev_line_number):='Y';
   ELSIF (l_prev_level_number = 3) THEN
      l_line.error_flag(l_prev_line_number):='Y';
      l_delivery.error_flag(l_line.delivery_line_number(l_prev_line_number)):='Y';
   END IF;
END IF;

--Display error for corresponding level.
IF (l_prev_level_number = 1) THEN
      IF ( l_header.error_flag(l_prev_line_number)='Y') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_HEADER_FAILED');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_line_number);
        fnd_msg_pub.add;
      END IF;
ELSIF (l_prev_level_number = 2) THEN
      IF (l_delivery.error_flag(l_prev_line_number)='Y') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_prev_line_number);
        fnd_msg_pub.add;
      END IF;
ELSIF (l_prev_level_number = 3) THEN
      IF (l_line.error_flag(l_prev_line_number)='Y') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_DEL_ERROR');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', l_line.delivery_line_number(l_prev_line_number));
        fnd_msg_pub.add;
      END IF;
END IF;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'***************************');
    WSH_DEBUG_SV.logmsg(l_module_name,'Printing Header');
END IF;

l_hi := l_header.Supplier_name.first;
WHILE (l_hi IS NOT NULL ) LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------');
      WSH_DEBUG_SV.log(l_module_name,'Index',l_hi);
      WSH_DEBUG_SV.log(l_module_name,'Supplier_name',l_header.Supplier_name(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'Request_date',l_header.Request_date(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'Request_Number',l_header.Request_Number(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'Request_revision',l_header.Request_revision(l_hi));
      WSH_DEBUG_SV.log(l_module_name,'error_flag',l_header.error_flag(l_hi));
    END IF;

l_hi :=l_header.Supplier_name.next(l_hi);
END LOOP;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'***************************');
    WSH_DEBUG_SV.logmsg(l_module_name,'Printing Delivery');
END IF;

l_di := l_delivery.Ship_From_Address1.first;
WHILE (l_di IS NOT NULL ) LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------');
      WSH_DEBUG_SV.log(l_module_name,'Index',l_di);
      WSH_DEBUG_SV.log(l_module_name,'Header_line_number',l_delivery.Header_line_number(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_Address1',l_delivery.Ship_From_Address1(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_Address2',l_delivery.Ship_From_Address2(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_Address3',l_delivery.Ship_From_Address3(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_Address4',l_delivery.Ship_From_Address4(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_city',l_delivery.Ship_From_city(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_state',l_delivery.Ship_From_state(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_county',l_delivery.Ship_From_county(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_country',l_delivery.Ship_From_country(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_province',l_delivery.Ship_From_province(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_postal_code',l_delivery.Ship_From_postal_code(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Ship_From_code',l_delivery.Ship_From_code(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Shipper_name',l_delivery.Shipper_name(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Phone',l_delivery.Phone(l_di));
      WSH_DEBUG_SV.log(l_module_name,'email',l_delivery.email(l_di));
      WSH_DEBUG_SV.log(l_module_name,'Number_of_containers',l_delivery.Number_of_containers(l_di));
      WSH_DEBUG_SV.log(l_module_name,'total_weight',l_delivery.total_weight(l_di));
      WSH_DEBUG_SV.log(l_module_name,'weight_uom',l_delivery.weight_uom(l_di));
      WSH_DEBUG_SV.log(l_module_name,'total_volume',l_delivery.total_volume(l_di));
      WSH_DEBUG_SV.log(l_module_name,'volume_UOM',l_delivery.volume_UOM(l_di));
      WSH_DEBUG_SV.log(l_module_name,'remark',l_delivery.remark(l_di));
      WSH_DEBUG_SV.log(l_module_name,'error_flag',l_delivery.error_flag(l_di));
    END IF;


l_di :=l_delivery.Ship_From_Address1.next(l_di);
END LOOP;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'***************************');
    WSH_DEBUG_SV.logmsg(l_module_name,'Printing Line');
END IF;

l_li := l_line.Po_Header_number.first;
WHILE (l_li IS NOT NULL ) LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------');
      WSH_DEBUG_SV.log(l_module_name,'Index',l_li);
      WSH_DEBUG_SV.log(l_module_name,'Delivery_line_number',l_line.Delivery_line_number(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Po_Header_number',l_line.Po_Header_number(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Po_Release_number',l_line.Po_Release_number(l_li));
      WSH_DEBUG_SV.log(l_module_name,'PO_Line_number',l_line.PO_Line_number(l_li));
      WSH_DEBUG_SV.log(l_module_name,'PO_Shipment_number',l_line.PO_Shipment_number(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Po_Operating_unit',l_line.Po_Operating_unit(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Item_quantity',l_line.Item_quantity(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Item_uom',l_line.Item_uom(l_li));
      WSH_DEBUG_SV.log(l_module_name,'weight',l_line.weight(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Weight_uom',l_line.Weight_uom(l_li));
      WSH_DEBUG_SV.log(l_module_name,'volume',l_line.volume(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Volume_UOM',l_line.Volume_UOM(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Earliest_pickup_date',l_line.Earliest_pickup_date(l_li));
      WSH_DEBUG_SV.log(l_module_name,'Latest_pickup_date',l_line.Latest_pickup_date(l_li));
      WSH_DEBUG_SV.log(l_module_name,'error_flag',l_line.error_flag(l_li));
    END IF;

l_li :=l_line.Po_Header_number.next(l_li);
END LOOP;


--If all the headers failed format level validation then error.
Is_All_Line_Error(p_error_tbl          => l_header.error_flag,
                   x_return_status      => x_return_status);

IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Is_All_Line_Error for Headers
x_return_status',x_return_status);
END IF;

IF (x_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) ) THEN

    --If all the deliveries failed format level validation then error.
    Is_All_Line_Error(p_error_tbl          => l_delivery.error_flag,
                   x_return_status      => x_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Is_All_Line_Error x_return_status',x_return_status);
    END IF;
    get_message;

    IF (x_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) ) THEN
       --Process the Routing Request information.
       Process_Routing_request(
	  p_in_param     => p_in_param,
        p_header       => l_header,
        p_delivery     => l_delivery,
        p_line         => l_line,
        x_success_tbl  => x_message_tbl,
        x_return_status=> x_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Process_Routing_request x_return_status',x_return_status);
       END IF;
    END IF;

END IF;

--Merge Message from fnd message stack and global message table
--to output message table.
get_message;

l_msg_count:= x_message_tbl.count;
l_index := g_error_tbl.first;
WHILE (l_index IS NOT NULL) LOOP
     l_msg_count:= l_msg_count + 1;
     x_message_tbl.extend;
     x_message_tbl(l_msg_count):= g_error_tbl(l_index);

l_index := g_error_tbl.next(l_index);
END LOOP;



  --
  -- Start code for Bugfix 4070732
  --
  IF  x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
  AND UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
  --}
  ELSIF UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          l_reset_flags := TRUE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
  --}
  END IF;
  --
  -- End of Code Bugfix 4070732
  --


--Insert Debug information as message ,if debugger is on.
IF l_debug_on THEN
    fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
    l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

    FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);

    l_msg_count:= l_msg_count + 1;
    x_message_tbl.extend;
    x_message_tbl(l_msg_count):= FND_MESSAGE.GET;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     --
     -- Start code for Bugfix 4070732
     --
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
     --{
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         --{
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
             END IF;
         --}
         END IF;
     --}
     END IF;
     --
     -- End of Code Bugfix 4070732
     --
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has
occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Start code for Bugfix 4070732
    --
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => l_return_status);


            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
            END IF;
        --}
        END IF;
    --}
    END IF;
    --
    -- End of Code Bugfix 4070732
    --

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);

     l_msg_count:= l_msg_count + 1;
     x_message_tbl.extend;
     x_message_tbl(l_msg_count):= FND_MESSAGE.GET;
END Process_Routing_Request_File;


-- Start of comments
-- API name : Process_File
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to upload routing request and Supplier Address Book. This api is called
--            from Routing Request/Supplier Address Book UI. Api does
--           1.Intilized the message global table.
--           2.Based on transaction type called the corresponding
--             wrapper api for processing.
-- Parameters :
-- IN:
--      p_caller        IN              WSH/ISP
--      p_txn_type      IN              RREQ -For Routing Request, SAB for Supplier Address Book.
--      p_user_id       IN              Passed if caller is ISP.
--      p_date_format   IN              UI date format need to be same with server date format.
--      p_file_fields   IN              List of fields as parse from Routing Request/Supplier Address book file.
-- OUT:
--      x_message_tbl   OUT NOCOPY      List of success/error messages return to calling api.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_File(
        p_caller      	IN  VARCHAR2,
        p_txn_type      IN  VARCHAR2,
        p_user_id       IN  NUMBER,
        p_date_format   IN  VARCHAR2,
        p_file_fields   IN  WSH_FILE_RECORD_TYPE ,
        x_message_tbl   OUT NOCOPY WSH_FILE_MSG_TABLE,
        x_return_status OUT NOCOPY      varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Process_File';
l_return	varchar2(1);
l_in_param	In_param_Rec_Type;
l_msg_count	number:=1;
BEGIN
x_message_tbl:= WSH_FILE_MSG_TABLE();
x_message_tbl.delete;

l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
    WSH_DEBUG_SV.log(l_module_name,'p_txn_type',p_txn_type);
    WSH_DEBUG_SV.log(l_module_name,'p_user_id',p_user_id);
    WSH_DEBUG_SV.log(l_module_name,'p_date_format',p_date_format);

WSH_DEBUG_SV.log(l_module_name,'x_message_tbl.count',x_message_tbl.count);
    WSH_DEBUG_SV.log(l_module_name,'g_error_tbl.count',g_error_tbl.count);
END IF;

--Initialize error message and fnd message table.
g_error_tbl.delete;
FND_MSG_PUB.Initialize;

--Colleted the input scalar parameter to record to facilities
--passing as parameter between api's.
l_in_param.caller:=p_caller;
l_in_param.txn_type:=p_txn_type ;
l_in_param.user_id:=p_user_id;
l_in_param.date_format:=p_date_format;
g_date_format:=p_date_format;


IF (p_txn_type = 'RREQ' ) THEN
    --Process Routing Request
    Process_Routing_Request_File(
	   p_in_param	=> l_in_param,
        p_file_fields   => p_file_fields,
        x_message_tbl   => x_message_tbl,
        x_return_status => x_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Process_Routing_Request_File x_return_status',x_return_status);
    END IF;
ELSE
    --Process Supplier Address Book.
    Process_Address_File(
	   p_in_param	=> l_in_param,
        p_file_fields   => p_file_fields,
        x_message_tbl   => x_message_tbl,
        x_return_status => x_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Process_Address_File x_return_status',x_return_status);
    END IF;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'After x_message_tbl.count',x_message_tbl.count);
    WSH_DEBUG_SV.log(l_module_name,'After g_error_tbl.count',g_error_tbl.count);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occurred.
Oracle error message is '||

SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     x_message_tbl.extend;
     x_message_tbl(l_msg_count):= FND_MESSAGE.GET;
END Process_File;


END WSH_ROUTING_REQUEST;

/
