--------------------------------------------------------
--  DDL for Package OE_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SCHEDULE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSCHS.pls 120.12.12010000.10 2011/03/03 09:53:32 rmoharan ship $ */

-- scheduling actions

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


-- scheduling entitites

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

--Caller
SCH_INTERNAL                 CONSTANT VARCHAR2(30) := 'INTERNAL';
SCH_EXTERNAL                 CONSTANT VARCHAR2(30) := 'EXTERNAL';

-- Valid Scheduling levels

SCH_LEVEL_ONE       CONSTANT VARCHAR2(30) :=  'ONE';
SCH_LEVEL_TWO       CONSTANT VARCHAR2(30) :=  'TWO';
SCH_LEVEL_THREE     CONSTANT VARCHAR2(30) :=  'THREE';
-- BUG 1955004
SCH_LEVEL_FOUR      CONSTANT VARCHAR2(30) :=  'FOUR';
SCH_LEVEL_FIVE      CONSTANT VARCHAR2(30) :=  'FIVE';
-- END 1955004

-- 6663462 Delayed_schedule

OE_Delayed_Schedule_line_tbl OE_ORDER_PUB.Line_Tbl_Type;



-- Valid Scheduling Status.

OESCH_STATUS_SCHEDULED  CONSTANT VARCHAR2(30) :=  'SCHEDULED';

-- Auto Schedule Flag and globals

OESCH_PERFORM_SCHEDULING          VARCHAR2(1)    := 'Y';
OESCH_AUTO_SCH_FLAG               VARCHAR2(30)   := 'N';
OESCH_AUTO_SCH_FLAG_FROM_USER     VARCHAR2(30)   := 'N';
OESCH_PERFORM_GRP_SCHEDULING      VARCHAR2(1)    := 'Y';
--11825106
OESCH_SET_SCHEDULING      VARCHAR2(1)    := 'Y';

OESCH_AUTO_SCHEDULE_PROFILE       VARCHAR2(30) :=
                 FND_PROFILE.VALUE('ONT_AUTOSCHEDULE');

--Added for ER 6110708
OESCH_ITEM_IS_SUBSTITUTED VARCHAR2(1) := 'N';

/* Bug: 2097933..
   This flag is to indicate if Reservation has been
   performed on this line or not */
OESCH_PERFORMED_RESERVATION VARCHAR2(1)  := 'N';

-- Scheduling action flag
G_LINE_ACTION                     VARCHAR2(30);


-- Cached Values

sch_cached_header_id           NUMBER;
sch_cached_sch_level_code      VARCHAR2(30);
sch_cached_sch_level_code_head VARCHAR2(30);
sch_cached_sch_level_code_line VARCHAR2(30);
sch_cached_order_type          VARCHAR2(80);
sch_cached_line_type_id        NUMBER;
sch_cached_line_type           VARCHAR2(80);
MRP_SESSION_ID                 NUMBER := 0;
-- 3748723 : New cache variables for sales order id
sch_cached_mtl_order_type_id   NUMBER;
sch_cached_mtl_order_type_name VARCHAR2(80);
sch_cached_mtl_sales_order_id  NUMBER;
sch_cached_mtl_header_id       NUMBER;
sch_cached_mtl_source_code     VARCHAr2(40);

-- BUG 1955004
TYPE inactive_demand_rec_type IS RECORD
  (line_id			NUMBER
  ,scheduling_level_code	VARCHAR2(30));

TYPE OE_inactive_demand_tbl_type IS TABLE OF
   inactive_demand_rec_type INDEX by BINARY_INTEGER;

OE_inactive_demand_tbl OE_inactive_demand_tbl_type;
--END 1955004

-- BUG 1282873
TYPE sch_rec_type IS RECORD
( line_id                      NUMBER
 ,attribute1                  varchar2(30));

TYPE oe_sch_tbl_type is TABLE OF
   sch_rec_type INDEX BY binary_integer;

OE_Override_Tbl OE_sch_Tbl_Type;
-- END 1282873
oe_split_rsv_tbl OE_sch_Tbl_Type; -- 8706868
/* -- 3288805 --*/
G_HEADER_ID        NUMBER       := null; --  moved from body to spec.
G_DATE_TYPE        VARCHAR2(30) := null; --  moved from body to spec.


PROCEDURE Schedule_line
( p_old_line_rec       IN  OE_ORDER_PUB.line_rec_type
 ,p_x_line_rec         IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_caller             IN  VARCHAR2 := SCH_INTERNAL
,x_return_status OUT NOCOPY VARCHAR2);



FUNCTION Need_Scheduling
( p_line_rec           IN OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec       IN OE_ORDER_PUB.line_rec_type
,x_line_action OUT NOCOPY VARCHAR2

,x_auto_sch OUT NOCOPY VARCHAR2)

RETURN BOOLEAN;


PROCEDURE Validate_Line
( p_line_rec      IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_old_line_rec  IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_sch_action    IN  VARCHAR2
 ,p_caller        IN  VARCHAR2 := SCH_EXTERNAL
,x_return_status OUT NOCOPY VARCHAR2);


Procedure  Process_request
( p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type
 ,p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_caller         IN VARCHAR2
 ,p_sch_action     IN VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2);



FUNCTION Get_Lead_Time
( p_ato_line_id      IN NUMBER
 ,p_ship_from_org_id IN NUMBER)
RETURN NUMBER;


FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2;


FUNCTION Get_Order_Number(p_header_id in number)
RETURN NUMBER;


Procedure Load_INV_Request
( p_line_rec            IN  Oe_Order_Pub.Line_Rec_Type
 ,p_quantity_to_reserve IN  NUMBER
 ,p_quantity2_to_reserve IN  NUMBER DEFAULT NULL -- INVCONV
,x_reservation_rec OUT NOCOPY Inv_Reservation_Global.Mtl_Reservation_Rec_Type);



Procedure Insert_Into_Mtl_Sales_Orders
( p_header_rec       IN  OE_ORDER_PUB.header_rec_type);

FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER,
				p_order_type_id IN NUMBER DEFAULT NULL)	 --3745318 added a new parameter p_order_type_id
RETURN NUMBER;

FUNCTION Get_Scheduling_Level( p_header_id IN NUMBER,
                               p_line_type_id IN NUMBER)
RETURN VARCHAR2;

Procedure Process_Group_of_lines
( p_x_old_line_tbl      IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
 ,p_x_line_tbl          IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
 ,p_caller              IN  VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Process_line
( p_old_line_rec        IN  OE_ORDER_PUB.line_rec_type
 ,p_x_line_rec          IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_caller              IN  VARCHAR2
 ,p_call_prn            IN  BOOLEAN := TRUE
,x_return_status OUT NOCOPY VARCHAR2);


-- BUG 1955004
Procedure Inactive_Demand_Scheduling
 ( p_x_old_line_rec	IN OE_ORDER_PUB.line_rec_type
  ,p_x_line_rec		IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
  ,p_sch_action		IN VARCHAR2 := NULL
,x_return_status OUT NOCOPY VARCHAR2);

-- END 1955004

Procedure Load_MRP_request_from_tbl
( p_line_tbl           IN  OE_ORDER_PUB.Line_Tbl_Type
 ,p_old_line_tbl       IN  OE_ORDER_PUB.Line_Tbl_Type
 ,p_partial_set        IN  BOOLEAN := FALSE
 ,p_sch_action         IN  VARCHAR2 := NULL
 ,p_part_of_set        IN  VARCHAR2 DEFAULT 'N' --4405004
 ,x_mrp_atp_rec OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ);


-- Added parameter p_old_line_tbl to support bug 1955004
Procedure Load_Results_from_tbl
( p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_old_line_tbl    IN  OE_ORDER_PUB.line_tbl_type
, p_x_line_tbl      IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_sch_action      IN  VARCHAR2 := NULL
, p_partial         IN  BOOLEAN := FALSE
, p_partial_set     IN  BOOLEAN := FALSE
, x_return_status OUT NOCOPY VARCHAR2);


Procedure ATP_Check
( p_old_line_rec       IN  OE_ORDER_PUB.line_rec_type,
  p_x_line_rec         IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type,
  p_validate           IN  VARCHAR2 := FND_API.G_TRUE,
x_atp_tbl OUT NOCOPY OE_ATP.atp_tbl_type,

x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Multi_ATP_Check
(p_old_line_tbl       IN  OE_ORDER_PUB.line_tbl_type,
 p_x_line_tbl         IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
x_atp_tbl OUT NOCOPY OE_ATP.atp_tbl_type,

x_return_status OUT NOCOPY VARCHAR2);


Procedure Unreserve_Line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_old_ship_from_org_id IN NUMBER DEFAULT NULL -- 6628134
 ,p_quantity_to_unreserve IN  NUMBER
 ,p_quantity2_to_unreserve IN  NUMBER DEFAULT NULL-- INCONV
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Reserve_line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_quantity_to_reserve   IN  NUMBER
 ,p_quantity2_to_reserve IN  NUMBER DEFAULT NULL-- INCONV
 ,p_rsv_update            IN  BOOLEAN DEFAULT FALSE -- To be passed as TRUE where there is an increase to the reserve quantity
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Set_Auto_Sch_Flag
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR);

--Bug 5948059
--To return the value of OESCH_AUTO_SCH_FLAG
FUNCTION Get_Auto_Sch_Flag
RETURN VARCHAR2;

Procedure SPLIT_SCHEDULING
( p_x_line_tbl         IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, x_return_status OUT NOCOPY VARCHAR2);



TYPE mrp_line_rec_type is RECORD
( line_id                      NUMBER
, schedule_ship_date           DATE
, schedule_arrival_date        DATE
, ship_from_org_id             NUMBER
, ship_method_code             VARCHAR2(30)
);

TYPE Mrp_Line_Tbl_Type IS TABLE OF mrp_line_rec_type
    INDEX BY BINARY_INTEGER;

Procedure Update_Results_from_backlog_wb
( p_mrp_line_tbl  IN  mrp_line_tbl_type
, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2);


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
x_return_status OUT NOCOPY VARCHAR2

);

Function Within_Rsv_Time_Fence(p_schedule_ship_date IN DATE,
				p_org_id IN NUMBER)
RETURN BOOLEAN;

Procedure Delete_Row(p_line_id IN NUMBER);

Procedure Call_MRP_ATP
( p_x_line_rec       IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
 ,p_old_line_rec     IN OE_ORDER_PUB.Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Post_Forms_Commit
(x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2);


Procedure call_process_order
( p_x_old_line_tbl      IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_x_line_tbl          IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_control_rec         IN  OE_GLOBALS.control_rec_type
, p_caller              IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Handle_External_Lines
(p_x_line_rec  IN OUT NOCOPY   OE_ORDER_PUB.line_rec_type);

/*----------------------------------------------------------------
This record type will be used to remember old inventory item
values on the lines which is part of set. The related records will be
used in execution of set delayed request.
-----------------------------------------------------------------*/

TYPE Inventory_item_rec_type IS RECORD
( line_id                 NUMBER
 ,inventory_item_id       NUMBER);

TYPE OE_Item_Tbl_Type is TABLE OF
Inventory_item_rec_type INDEX BY binary_integer;

OE_Item_Tbl OE_Item_Tbl_Type;

-- Start 2434807 --

G_ATP_TBL          OE_ATP.atp_tbl_type;  -- Moved from Package body to Scpec.

PROCEDURE Get_Atp_Table_Count(p_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,
                              p_atp_tbl_cnt OUT NOCOPY NUMBER);

-- End 2434807 --

Procedure Display_Sch_Errors
( p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_line_tbl        IN  OE_ORDER_PUB.line_tbl_type
                        := OE_ORDER_PUB.G_MISS_LINE_TBL
, p_line_id         IN  NUMBER DEFAULT NULL);


FUNCTION Schedule_Attribute_Changed
( p_line_rec     IN Oe_Order_Pub.line_rec_type
, p_old_line_rec IN Oe_Order_Pub.line_rec_type)
RETURN BOOLEAN;

FUNCTION Set_Attr_Matched(p_set_ship_from_org_id IN NUMBER ,
                          p_line_ship_from_org_id IN NUMBER,
                          p_set_ship_to_org_id IN NUMBER,
                          p_line_ship_to_org_id IN NUMBER,
                          p_set_schedule_ship_date IN DATE,
                          p_line_schedule_ship_date IN DATE,
                          p_set_arrival_date IN DATE,
                          p_line_arrival_date IN DATE,
                          p_set_shipping_method_code IN VARCHAR2,
                          p_line_shipping_method_code IN VARCHAR2,
                          p_set_type IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION Validate_ship_method
(p_new_ship_method IN VARCHAR2,
 p_old_ship_method IN VARCHAR2,
 p_ship_from_org_id IN NUMBER)
RETURN BOOLEAN;

-- Start 2595661
FUNCTION Get_Pick_Status (p_line_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE Do_Unreserve (p_line_rec             IN  OE_ORDER_PUB.Line_Rec_Type
                       ,p_quantity_to_unreserve IN  NUMBER
                       ,p_quantity2_to_unreserve IN  NUMBER DEFAULT NULL -- INVCONV
                       ,p_old_ship_from_org_id   IN  NUMBER DEFAULT NULL -- 5024936
                       ,x_return_status         OUT NOCOPY VARCHAR2);

-- End 2595661

-- 2391781
/*----------------------------------------------------------------
This record type will be used to store modified scheduling attribute item
values on the lines which is part of set. The related records will be
used in cascading during group scheduling.
-----------------------------------------------------------------*/

TYPE cascade_sch_rec_type IS RECORD
( line_id             NUMBER
 ,set_id              NUMBER
 ,attribute1          VARCHAR2(240):= NULL
 ,attribute2          VARCHAR2(240):= NULL
 ,date_attribute1     DATE := NULL);

TYPE OE_sch_Attrb_Tbl_Type is TABLE OF
cascade_sch_rec_type INDEX BY binary_integer;

OE_sch_Attrb_Tbl OE_sch_Attrb_Tbl_Type;

Procedure Schedule_Split_Lines
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Update_PO(p_schedule_ship_date       IN DATE,
                    p_source_document_id       IN VARCHAR2,
                    p_source_document_line_id  IN VARCHAR2);
-- Pack J
PROCEDURE Promise_Date_for_Sch_Action
(p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,p_sch_action IN VARCHAR2
,P_header_id  IN NUMBER DEFAULT NULL);

PROCEDURE Global_atp(p_line_id IN NUMBER);

FUNCTION Get_ATP_CHECK_Session_Id
RETURN number;

Procedure Cascade_Ship_Set_Attr
( p_request_rec     IN  OE_Order_Pub.Request_Rec_Type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

-- 4026758
Procedure Log_Delete_Set_Request
(p_header_id     IN NUMBER,
 p_line_id       IN NUMBER,
 p_set_id        IN NUMBER,
 x_return_status OUT NOCOPY VARCHAR2);

/* Added the following 2 procedures to fix the bug 6378240  */

PROCEDURE MRP_ROLLBACK
( p_line_id       IN NUMBER
 ,p_schedule_action_code IN VARCHAR2
 ,x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE CALL_MRP_ROLLBACK
( x_return_status OUT NOCOPY VARCHAR2);

/* Added the following procedure to fix the bug 6663462 */

Procedure DELAYED_SCHEDULE_LINES
( x_return_status OUT NOCOPY VARCHAR2);

-- Added for ER 6110708
PROCEDURE IS_ITEM_SUBSTITUTED
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER
);

-- Added for ER 6110708
PROCEDURE IS_LINE_PICKED
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER
);

/*----------------------------------------------------------------------------------
 * PROCEDURE res_against_req_po
 * Added for ER 9224462. This API will validate if there are any reservations of a
 * line against a REQ or PO. If it has, p_result will return 1, else return 0.
 * This API has standard signature as required by Processing Constraints framework,
 * for API based Validation template. Based on this API a Validation template will
 * be created.
 * ---------------------------------------------------------------------------------*/
PROCEDURE res_against_req_po
( p_application_id               IN NUMBER,
  p_entity_short_name            in VARCHAR2,
  p_validation_entity_short_name in VARCHAR2,
  p_validation_tmplt_short_name  in VARCHAR2,
  p_record_set_tmplt_short_name  in VARCHAR2,
  p_scope                        in VARCHAR2,
  p_result                       OUT NOCOPY NUMBER );

/*4241385*/
/*----------------------------------------------------------------------------------
 * PROCEDURE GET_SET_DETAILS
 * Added for ER 4241385. This API will take set_id as the input parameter and return
 whether the set exists or not (new set, or exisitng set) and if the set exisits,
 whether it is scheduled or not.
 * ---------------------------------------------------------------------------------*/

PROCEDURE get_set_details
( p_set_id                       IN NUMBER
 ,x_set_exists                   OUT NOCOPY BOOLEAN
 ,x_set_scheduled                OUT NOCOPY BOOLEAN );


Procedure Log_Set_Request
(p_line_rec       IN OE_ORDER_PUB.Line_rec_type,
 p_old_line_rec   IN OE_ORDER_PUB.Line_rec_type,  -- making public for 4241385
 p_sch_action     IN VARCHAR2,
 p_caller         IN VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2);

END OE_SCHEDULE_UTIL;


/
