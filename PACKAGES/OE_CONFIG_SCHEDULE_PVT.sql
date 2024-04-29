--------------------------------------------------------
--  DDL for Package OE_CONFIG_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCSCS.pls 120.1.12010000.1 2008/07/25 07:59:23 appldev ship $ */

/*----------------------------------------------------------------
This record type will be used to remember imp. old and changed
values on the lines. The related records will be collected in
a table and will be used in the delayed request execution.
-----------------------------------------------------------------*/

TYPE Reservation_Rec_Type IS RECORD
( entity_id               NUMBER
 ,line_id                 NUMBER
 ,qty_to_reserve          NUMBER
 ,qty_to_unreserve        NUMBER
 ,qty2_to_reserve         NUMBER -- INVCONV
 ,qty2_to_unreserve       NUMBER -- INVCONV
 );

TYPE OE_Reservations_Tbl_Type is TABLE OF
Reservation_Rec_Type INDEX BY binary_integer;

OE_Reservations_Tbl OE_Reservations_Tbl_Type;

-------------- Constants ---------------------------------------
-- Caller used in process_group API
SCH_ATO         CONSTANT VARCHAR2(30) := 'SCHEDULE_ATO';
SCH_UI          CONSTANT VARCHAR2(30) := 'UI_ACTION';
SCH_SET         CONSTANT VARCHAR2(30) := 'SCHEDULE_SET';

--------------- Public Procedures ------------------------------

PROCEDURE Log_Config_Sch_Request
( p_line_rec       IN  OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN  OE_Order_PUB.Line_Rec_Type
 ,p_sch_action     IN  VARCHAR2
 ,p_caller         IN  VARCHAR2 := OE_SCHEDULE_UTIL.SCH_INTERNAL
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Schedule_ATO
( p_request_rec    IN  OE_Order_Pub.Request_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Schedule_SMC
( p_request_rec    IN  OE_Order_Pub.Request_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Schedule_NONSMC
( p_request_tbl     IN  OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_res_changes     IN  VARCHAR2 := 'N'
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Process_Group
( p_x_line_tbl       IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl     IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action       IN  VARCHAR2
 ,p_caller           IN  VARCHAR2 := 'X'
 ,p_handle_unreserve IN  VARCHAR2 := 'N'
 ,p_partial          IN  BOOLEAN := FALSE
 ,p_partial_set      IN  BOOLEAN := FALSE
 ,p_part_of_set      IN  VARCHAR2 DEFAULT 'N' -- 4405004
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Query_Set_Lines
(p_header_id         IN NUMBER,
 p_ship_set_id       IN NUMBER  := FND_API.G_MISS_NUM,
 p_arrival_set_id    IN NUMBER  := FND_API.G_MISS_NUM,
 p_model_line_id     IN NUMBER  := FND_API.G_MISS_NUM,
 p_link_to_line_id   IN NUMBER  := FND_API.G_MISS_NUM,
 p_sch_action        IN VARCHAR2,
 p_send_cancel_lines IN VARCHAR2 := 'N',
 x_line_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type,
 x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE Delete_Attribute_Changes
(p_entity_id   NUMBER := -1);

PROCEDURE Save_Sch_Attributes
( p_x_line_tbl    IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action    IN  VARCHAR2
 ,p_caller        IN  VARCHAR2
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Update_Reservation
( p_line_rec      IN  OE_Order_Pub.Line_Rec_Type
 ,p_old_line_rec  IN  OE_Order_Pub.Line_Rec_Type
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
END Oe_Config_Schedule_Pvt;

/
