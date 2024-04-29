--------------------------------------------------------
--  DDL for Package OE_GROUP_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GROUP_SCH_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUGRPS.pls 120.1.12010000.2 2010/03/15 09:17:39 spothula ship $ */

TYPE number_arr IS TABLE OF number INDEX BY BINARY_INTEGER;

Procedure Schedule_Order
(p_header_id       IN  NUMBER,
 p_sch_action      IN  VARCHAR2,
 x_atp_tbl         OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type,
 x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count       OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data        OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Schedule_Multi_lines
(p_selected_line_tbl  IN  OE_GLOBALS.Selected_Record_Tbl, --R12. MOAC
 p_line_count     IN  NUMBER,
 p_sch_action         IN  VARCHAR2,
 x_atp_tbl        OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type,
 x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count      OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Schedule_Set
(p_request_rec   IN  OE_ORDER_PUB.request_rec_type,
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Schedule_set_lines
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Validate_Group
(p_x_line_tbl    IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
 p_sch_action    IN  VARCHAR2,
 p_validate_action IN VARCHAR2 DEFAULT 'PARTIAL',     --Added for Bug 3590437
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

-- Added for Bug-2454163
FUNCTION Find_line( p_x_line_tbl  IN OE_ORDER_PUB.Line_Tbl_Type,
                    p_line_id     IN  NUMBER)
Return BOOLEAN;

Procedure Group_Schedule_sets
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Validate_Item_Warehouse
(p_inventory_item_id      IN NUMBER,  -- 4241385
 p_ship_from_org_id       IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);

TYPE set_rec_type is RECORD
( line_id               NUMBER
, ship_set_id           NUMBER
, arrival_set_id        NUMBER
);

TYPE set_Tbl_Type IS TABLE OF set_rec_type
    INDEX BY BINARY_INTEGER;

END OE_GROUP_SCH_UTIL;

/
