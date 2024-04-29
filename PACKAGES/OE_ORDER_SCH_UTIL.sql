--------------------------------------------------------
--  DDL for Package OE_ORDER_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_SCH_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXVSCHS.pls 120.0 2005/06/01 01:49:27 appldev noship $ */

OESCH_ACT_RESERVE            CONSTANT VARCHAR2(30) := 'RESERVE';
OESCH_ACT_SCHEDULE           CONSTANT VARCHAR2(30) := 'SCHEDULE';
OESCH_ACT_DEMAND             CONSTANT VARCHAR2(30) := 'SCHEDULE';
OESCH_ACT_SOURCE             CONSTANT VARCHAR2(30) := 'SOURCE';
OESCH_ACT_UNDEMAND           CONSTANT VARCHAR2(30) := 'UNSCHEDULE';
OESCH_ACT_UNRESERVE          CONSTANT VARCHAR2(30) := 'UNRESERVE';
OESCH_ACT_UNSCHEDULE         CONSTANT VARCHAR2(30) := 'UNSCHEDULE';
OESCH_ACT_ATP_CHECK          CONSTANT VARCHAR2(30) := 'ATP_CHECK';
OESCH_ACT_RESCHEDULE         CONSTANT VARCHAR2(30) := 'RESCHEDULE';
OESCH_ACT_RES_TRANSFER       CONSTANT VARCHAR2(30) := 'RES_TRANSFER';
OESCH_ACT_REDEMAND           CONSTANT VARCHAR2(30) := 'REDEMAND';
OESCH_ACT_CHECK_SCHEDULING   CONSTANT VARCHAR2(30) := 'CHECK_SCHEDULING';

OESCH_ENTITY_ORDER           CONSTANT VARCHAR2(30) := 'ORDER';
OESCH_ENTITY_SET             CONSTANT VARCHAR2(30) := 'SET';
OESCH_ENTITY_SHIP_SET        CONSTANT VARCHAR2(30) := 'SHIP_SET';
OESCH_ENTITY_ARRIVAL_SET     CONSTANT VARCHAR2(30) := 'ARRIVAL_SET';
OESCH_ENTITY_SMC             CONSTANT VARCHAR2(30) := 'SHIP_MODEL_COMPLETE';
OESCH_ENTITY_ATO_CONFIG      CONSTANT VARCHAR2(30) := 'ATO_CONFIG';
OESCH_ENTITY_CONFIGURATION   CONSTANT VARCHAR2(30) := 'CONFIGURATION';
OESCH_ENTITY_O_LINE          CONSTANT VARCHAR2(30) := 'ORDER_LINE';
OESCH_ENTITY_P_LINE          CONSTANT VARCHAR2(30) := 'PARENT_LINE';

OESCH_ENTITY_LINE            CONSTANT VARCHAR2(30) := 'LINE';

/* Valid Scheduling Status.
*/

SCH_LEVEL_ONE    	CONSTANT VARCHAR2(30) :=  'ONE';
SCH_LEVEL_TWO       CONSTANT VARCHAR2(30) :=  'TWO';
SCH_LEVEL_THREE     CONSTANT VARCHAR2(30) :=  'THREE';

/* Valid Scheduling Status.
*/

OESCH_STATUS_BLANK    	CONSTANT VARCHAR2(30) :=  '';
OESCH_STATUS_RESERVED   CONSTANT VARCHAR2(30) :=  'RESERVED';
OESCH_STATUS_DEMANDED   CONSTANT VARCHAR2(30) :=  'SCHEDULED';
OESCH_STATUS_SCHEDULED  CONSTANT VARCHAR2(30) :=  'SCHEDULED';

/* Auto Schedule Flag
*/

OESCH_PERFORM_SCHEDULING          VARCHAR2(1)    := 'Y';
OESCH_AUTO_SCH_FLAG               VARCHAR2(30)   := 'N';
OESCH_AUTO_SCH_FLAG_FROM_USER     VARCHAR2(30)   := 'N';

/* Cached Values
*/

sch_cached_header_id      NUMBER;
sch_cached_sch_level_code VARCHAR2(30);
sch_cached_sch_level_code_head VARCHAR2(30);
sch_cached_sch_level_code_line VARCHAR2(30);
sch_cached_order_type     VARCHAR2(80);
sch_cached_line_type_id   NUMBER;
sch_cached_line_type      VARCHAR2(80);
MRP_SESSION_ID            NUMBER := 0;

/* Group Scheduling Flag
*/
OESCH_PERFORM_GRP_SCHEDULING  VARCHAR2(1)    := 'Y';

/* Flag to indicate if the schedule_parent_line to be called in post-write */
OESCH_SCH_POST_WRITE VARCHAR2(1) := 'N';

/* Bug: 2097933..
   This flag is to indicate if Reservation has been
   performed on this line or not */
OESCH_PERFORMED_RESERVATION VARCHAR2(1)  := 'N';

TYPE number_arr IS TABLE OF number;
TYPE char30_arr IS TABLE OF varchar2(30);
TYPE char3_arr IS TABLE OF varchar2(3);
TYPE char1_arr IS TABLE of varchar2(1);
TYPE char2000_arr IS TABLE of varchar2(2000);
TYPE char1000_arr IS TABLE of varchar2(1000);
TYPE date_arr IS TABLE OF date;

TYPE request_rec_type is RECORD (
Header_Id                       NUMBER,
Line_Id                         NUMBER,
Config_Line_Id                  NUMBER,
Ato_Line_Id                     NUMBER,
Component_sequence_id           NUMBER,
Component_Code                  VARCHAR2(1000),
Invoice_To_Org_Id               NUMBER,
Inventory_Item_Id               NUMBER,
Organization_Id                 NUMBER,
Identifier                      NUMBER,
Calling_Module                  NUMBER,
Sold_To_Org_Id                  NUMBER,
Ship_To_Org_Id                  NUMBER,
Destination_Time_Zone           VARCHAR2(30),
Ordered_Quantity                NUMBER,
Ordered_Quantity_uom            VARCHAR2(3),
Requested_Ship_Date             DATE,
Requested_Arrival_Date          DATE,
Schedule_Date                   DATE,
Schedule_Arrival_Date           DATE,
Earliest_Acceptable_Date        DATE,
Latest_Acceptable_Date          DATE,
Delivery_Lead_Time              NUMBER,
Freight_Carrier                 VARCHAR2(30),
Ship_Method                     VARCHAR2(30),
Demand_Class                    VARCHAR2(30),
Ship_Set_Name                   VARCHAR2(30),
Arrival_Set_Name                VARCHAR2(30),
Override_Flag                   VARCHAR2(1),
Action                          NUMBER,
Ship_Date                       DATE,
Available_Quantity              NUMBER,
Group_Ship_Date                 DATE,
Group_Arrival_Date              DATE,
Ship_From_Org_Id                NUMBER,
Insert_Flag                     NUMBER,
Message                         VARCHAR2(2000)
);

TYPE sch_rec_type is RECORD
( ship_from_org_id             NUMBER
, schedule_date                DATE
, shipping_method_code         VARCHAR2(30)
, freight_carrier_code         VARCHAR2(30)
, delivery_lead_time           NUMBER
);

TYPE mrp_line_rec_type is RECORD
( line_id                      NUMBER
, schedule_ship_date           DATE
, schedule_arrival_date        DATE
, ship_from_org_id             NUMBER
, ship_method_code             VARCHAR2(30)
);

TYPE Mrp_Line_Tbl_Type IS TABLE OF mrp_line_rec_type
    INDEX BY BINARY_INTEGER;

Procedure Schedule_line
(  p_old_line_rec      IN  OE_ORDER_PUB.line_rec_type
, p_write_to_db        IN  VARCHAR2
, p_update_flag        IN  VARCHAR2 := FND_API.G_TRUE
, p_recursive_call     IN  VARCHAR2 := FND_API.G_TRUE
, p_x_line_rec         IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
, x_atp_tbl            OUT NOCOPY /* file.sql.39 change */ OE_ATP.atp_tbl_type
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Update_line_record
(  p_line_tbl  IN  OE_ORDER_PUB.line_tbl_type
, p_x_new_line_tbl      IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_write_to_db   IN  VARCHAR2
, p_recursive_call IN VARCHAR2
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION Need_Scheduling
( p_line_rec           IN OE_ORDER_PUB.line_rec_type
, p_old_line_rec       IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN;

Procedure Check_Item_Attribute
(p_line_rec IN OE_ORDER_PUB.line_rec_type);

FUNCTION Scheduling_Activity
(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN;

Procedure Validate_Line
( p_line_rec      IN  OE_ORDER_PUB.Line_Rec_Type
, p_old_line_rec  IN  OE_ORDER_PUB.Line_Rec_Type
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure  Process_request
( p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type
, p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
, x_out_atp_tbl    OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type
, x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


FUNCTION Get_Lead_Time
( p_ato_line_id      IN NUMBER
, p_ship_from_org_id IN NUMBER)
RETURN NUMBER;

Procedure Create_Group_Request
(  p_line_rec         IN  OE_ORDER_PUB.line_rec_type
 , p_old_line_rec     IN  OE_ORDER_PUB.line_rec_type
 , x_group_req_rec    OUT NOCOPY /* file.sql.39 change */ OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
 , x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


Procedure Load_INV_Request
( p_line_rec             IN  Oe_Order_Pub.Line_Rec_Type
, p_quantity_to_reserve  IN  NUMBER
, p_quantity2_to_reserve  IN  NUMBER DEFAULT NULL-- INVCONV
, x_reservation_rec      OUT NOCOPY /* file.sql.39 change */ Inv_Reservation_Global.Mtl_Reservation_Rec_Type);

FUNCTION Schedule_Attribute_Changed
( p_line_rec     IN Oe_Order_Pub.Line_Rec_Type
, p_old_line_rec IN Oe_Order_Pub.Line_Rec_Type)
RETURN BOOLEAN;

Procedure Unreserve_Line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
, p_quantity_to_unreserve IN  NUMBER
, p_quantity2_to_unreserve IN  NUMBER -- INVCONV
, x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Call_ATP
( p_atp_table          IN    MRP_ATP_PUB.ATP_Rec_Typ
, x_atp_table          OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Rec_Typ
, x_atp_supply_demand  OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Supply_Demand_Typ
, x_atp_period         OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Period_Typ
, x_atp_details        OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Details_Typ
, x_return_status      OUT NOCOPY /* file.sql.39 change */   VARCHAR2
, x_msg_data           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */   NUMBER);

Procedure Load_MRP_Request
( p_line_tbl              IN  Oe_Order_Pub.Line_Tbl_Type
, p_old_line_tbl          IN  Oe_Order_Pub.Line_Tbl_Type
                              := OE_ORDER_PUB.G_MISS_LINE_TBL
, x_atp_table             OUT NOCOPY /* file.sql.39 change */ MRP_ATP_PUB.ATP_Rec_Typ
);

Procedure Load_Results
( p_atp_table       IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_x_line_tbl        IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, x_atp_tbl         OUT NOCOPY /* file.sql.39 change */ OE_ATP.ATP_tbl_Type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Insert_Into_Mtl_Sales_Orders
( p_header_rec       IN  OE_ORDER_PUB.header_rec_type);

FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER)
RETURN NUMBER;

/*
PROCEDURE Set_Auto_Sch_Flag
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_default_value    IN VARCHAR2 := FND_API.G_MISS_CHAR);
*/

PROCEDURE Set_Auto_Sch_Flag
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR);

PROCEDURE Build_Included_Items
             (p_line_rec IN OE_ORDER_PUB.line_rec_type,
              x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type);

Procedure SPLIT_SCHEDULING
( p_x_line_tbl           IN OUT NOCOPY  OE_ORDER_PUB.line_tbl_type
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE SPLIT_RESERVATIONS
( p_reserved_line_id   IN  NUMBER
, p_ordered_quantity   IN  NUMBER
, p_reserved_quantity  IN  NUMBER
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- added by fabdi 03/May/2001
-- added new parameter p_line_id as DEFAULT NULL
Procedure Query_Qty_Tree(p_org_id            IN NUMBER,
                         p_item_id           IN NUMBER,
                         p_line_id           IN NUMBER DEFAULT NULL,
                         p_sch_date          IN DATE DEFAULT NULL,
                         x_on_hand_qty      OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_avail_to_reserve OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_on_hand_qty2      OUT NOCOPY /* file.sql.39 change */ NUMBER, -- INVCONV
                         x_avail_to_reserve2 OUT NOCOPY /* file.sql.39 change */ NUMBER  -- INVCONV
                         );

Procedure Update_Results_from_backlog_wb
( p_mrp_line_tbl  IN  mrp_line_tbl_type
, x_msg_count     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION Get_Session_Id
RETURN number;

FUNCTION Get_MRP_Session_Id
RETURN number;

Procedure Insert_Mandatory_Components
(p_order_number           IN  NUMBER,
p_ato_line_id             IN  NUMBER,
p_customer_name           IN  VARCHAR2,
p_customer_location       IN  VARCHAR2,
p_arrival_set_name        IN  VARCHAR2,
p_ship_set_name           IN  VARCHAR2,
p_ship_set_id             IN  NUMBER,
p_requested_ship_date     IN  DATE,
p_requested_arrival_date  IN  DATE,
p_session_id              IN  NUMBER,
p_instance_id             IN  NUMBER,
p_insert_code             IN  NUMBER,
x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

Function Within_Rsv_Time_Fence(p_schedule_ship_date IN DATE)
RETURN BOOLEAN;

FUNCTION Get_Scheduling_Level( p_header_id IN NUMBER,
                               p_line_type_id IN NUMBER)
RETURN VARCHAR2;

Procedure Delete_Row(p_line_id IN NUMBER);

/*            -- added by fabdi 03/May/2001 INVCONV not needed now
PROCEDURE get_process_query_quantities
  (   p_org_id       IN  NUMBER
   ,  p_item_id      IN  NUMBER
   ,  p_line_id      IN  NUMBER
   ,  x_on_hand_qty  OUT NOCOPY NUMBER
   ,  x_avail_to_reserve OUT NOCOPY NUMBER
  );
-- end fabdi
*/


--Added for the Bug 2097933
PROCEDURE Post_Forms_Commit
(x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,x_msg_count      OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END OE_ORDER_SCH_UTIL;

 

/
