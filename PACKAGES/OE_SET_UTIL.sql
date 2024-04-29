--------------------------------------------------------
--  DDL for Package OE_SET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SET_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSETS.pls 120.4.12010000.2 2008/12/24 10:32:07 rmoharan ship $ */

g_delivery_set_rec      OE_ORDER_PUB.set_rec_type;
g_invoice_set_rec       OE_ORDER_PUB.set_rec_type;
g_ship_set_rec          OE_ORDER_PUB.set_rec_type;
g_fullfillment_set_rec  OE_ORDER_PUB.set_rec_type;
G_Create_Ship_set  VARCHAR2(30) := FND_API.G_FALSE;
G_Create_Arrival_set  VARCHAR2(30) := FND_API.G_FALSE;
G_Set_Request_Tbl  OE_ORDER_PUB.Request_Tbl_Type;
G_Set_Recursive_Flag BOOLEAN := FALSE;

--Bug 4080531
g_set_rec OE_ORDER_CACHE.set_rec_type;

Type Set_rec IS RECORD
(
Line_id number := FND_api.g_miss_num,
Set_name  varchar2(80) := FND_Api.g_miss_char,
set_type varchar2(30),
process_flag varchar2(1):= 'N',
operation  varchar2(1):= 'U');

Type Set_opt_rec IS RECORD
(
Line_id number := FND_api.g_miss_num,
Set_id  number := FND_Api.g_miss_num,
set_type varchar2(30));

Type auto_set_rec IS RECORD
(
Line_id number := FND_api.g_miss_num);

Type Set_opt_line_Tbl IS TABLE OF set_opt_rec
index by binary_integer;

Type Set_line_Tbl IS TABLE OF set_rec
index by binary_integer;

Type auto_set_tbl IS TABLE OF auto_set_rec
index by binary_integer;

g_set_tbl Set_line_Tbl;
g_set_opt_tbl Set_opt_line_Tbl;
g_auto_set_tbl auto_set_tbl;


-- Function to find if set exists
FUNCTION Set_Exist(p_set_name IN VARCHAR2,
                    p_set_type IN VARCHAR2,
		    p_Header_Id  IN NUMBER,
x_set_id OUT NOCOPY NUMBER)

RETURN BOOLEAN;

-- Function to get Fulfillment sets for a line

FUNCTION Get_Fulfillment_List(p_line_id IN NUMBER)
RETURN VARCHAR2;

-- Function to find if set exists for a set id

FUNCTION Set_Exist(p_set_id	IN NUMBER,
		   p_header_id IN NUMBER := FND_API.G_MISS_NUM)
RETURN BOOLEAN;

-- This procedure is first thing to get called in Lines procedure
-- to figure out if there are any set requests and populate the
-- global tables that get accessed in post lines process

PROCEDURE get_set_id(
			     p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
				p_old_line_rec IN OE_ORDER_PUB.line_rec_type,
				p_Index IN NUmber);

-- This Procedure is designed to be called from form controller for a
-- multiselect case and user using the right mouse click button to do
-- set operations

Procedure Process_Sets
(   p_selected_line_tbl    IN OE_GLOBALS.Selected_Record_Tbl, --R12.MOAC
    p_record_count	    IN NUMBER,
    p_set_name             IN VARCHAR2,
    p_set_type             IN VARCHAR2 := FND_API.G_MISS_CHAR,
    p_operation            IN VARCHAR2,
    p_header_id	           IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_Set_Id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);


-- This api is called to create set passing the required set attributes
-- Validates if all the required set attributes set correctly and creates
-- the set and returns the set id
Procedure Create_Set
        (p_Set_Name                     IN VARCHAR2,
         p_Set_Type                     IN VARCHAR2,
         p_Header_Id                    IN NUMBER := NULL,
         p_Ship_From_Org_Id             IN NUMBER := NULL,
         p_Ship_To_Org_Id               IN NUMBER := NULL,
         p_shipment_priority_code   IN VARCHAR2 := NULL,
         p_Schedule_Ship_Date           IN DATE := NULL,
         p_Schedule_Arrival_Date        IN DATE := NULL,
         p_Freight_Carrier_Code         IN VARCHAR2 := NULL,
         p_Shipping_Method_Code         IN VARCHAR2 := NULL,
         p_system_set                   IN VARCHAR2 DEFAULT 'N',
x_Set_Id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

         );
-- Insert Into Set is called from a delayed request for a case where
-- User chooses to default the preference of set from the header rec
-- This dependes on the customer preference set code

Procedure Insert_Into_Set
	(p_Set_request_tbl  oe_order_pub.Request_Tbl_Type,
	 p_Push_Set_Date                IN VARCHAR2 := FND_API.G_FALSE,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

);

-- This is desinged with the intention to push new lines of the split that
-- are part of the ship or arrival set
-- into a different new set

Procedure Split_Set
	 (p_set_id			IN NUMBER,
	  p_set_name			IN VARCHAR2,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

);

-- Update set is called from scheduling when any of the set attributes
-- changes and result in cascading on the lines of the set.
Procedure Update_Set
	(p_Set_Id			IN NUMBER,
	 p_Ship_From_Org_Id		IN NUMBER := FND_API.G_MISS_NUM,
	 p_Ship_To_Org_Id		IN NUMBER := FND_API.G_MISS_NUM,
	 p_Schedule_Ship_Date		IN DATE := FND_API.G_MISS_DATE,
	 p_Schedule_Arrival_Date	IN DATE := FND_API.G_MISS_DATE,
	 p_Freight_Carrier_Code		IN VARCHAR2 := FND_API.G_MISS_CHAR,
	 p_Shipping_Method_Code	IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_shipment_priority_code   IN VARCHAR2 := FND_API.G_MISS_CHAR,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

	);

-- This is use to cache the set record for performance reasons
FUNCTION get_set_rec(p_set_id IN NUMBER)
RETURN OE_ORDER_CACHE.set_rec_type;

-- This api checks if all the set attributes on the set are same

PROCEDURE Validate_set_attributes(p_set_id IN NUMBER ,
  p_Ship_From_Org_Id IN NUMBER := FND_API.G_MISS_NUM,
  p_Ship_To_Org_Id   IN NUMBER := FND_API.G_MISS_NUM,
  p_Schedule_Ship_Date  IN DATE := FND_API.G_MISS_DATE,
  p_Schedule_Arrival_Date IN DATE := FND_API.G_MISS_DATE,
  p_Freight_Carrier_Code IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_Shipping_Method_Code  IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_shipment_priority_code   IN VARCHAR2 := FND_API.G_MISS_CHAR,
X_Return_Status OUT NOCOPY VARCHAR2);


-- This is to check if an arrival set already exists in a ship set and
-- if so to restrict user from creating a second one

PROCEDURE Validate_Multi_Arr_Set(p_header_id IN NUMBER,
	   p_ship_Set_id IN NUMBER ,
x_arrival_set_id OUT NOCOPY NUMBER);


-- Updates the options if a model is changed

Procedure Update_Options(p_ato_line_id IN NUMBER := FND_API.G_MISS_NUM,
               p_config_line_id IN NUMBER := FND_API.G_MISS_NUM,
               p_set_id IN NUMBER,
               p_set_type IN VARCHAR2 );

-- To query all the lines in the set

PROCEDURE Query_Set_Rows(p_set_id IN NUMBER,
		x_line_tbl   OUT NOCOPY OE_Order_PUB.Line_Tbl_Type);

-- To create a line set
Procedure Create_line_Set(p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE);

-- To process the sets from the global table populated by get set id api
-- this is called from post line process and get executed when the proces is
-- set to true
Procedure Process_Sets(p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE);

-- To remove from fullifllment set
Procedure Remove_from_fulfillment(p_line_id NUMBER);

-- To create fulfillment set
Procedure Create_Fulfillment_Set(p_line_id NUMBER,
                                 -- 4925992
                                 p_top_model_line_id NUMBER := NULL,
                                 p_set_id NUMBER);

-- Add new procedure Default line set for set and scheduling revamping
Procedure Default_Line_Set(p_x_line_rec IN OUT NOCOPY
                                oe_order_pub.line_rec_type,
                           p_old_line_rec IN  oe_order_pub.line_rec_type);
-- 4026756
-- To delete  set
Procedure Delete_Set(p_request_rec   IN  OE_ORDER_PUB.request_rec_type,
                     x_return_status OUT NOCOPY VARCHAR2);

--Standalone
FUNCTION Stand_Alone_set_exists (p_ship_set_id IN NUMBER,
                                 p_arrival_set_id IN NUMBER,
                                 p_header_id IN NUMBER,
                                 p_line_id IN NUMBER,
                                 p_sch_level IN VARCHAR2)
RETURN BOOLEAN;

END OE_Set_Util;

/
