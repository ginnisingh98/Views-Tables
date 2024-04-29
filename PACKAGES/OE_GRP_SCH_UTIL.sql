--------------------------------------------------------
--  DDL for Package OE_GRP_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GRP_SCH_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXVGRPS.pls 120.0 2005/06/01 00:26:12 appldev noship $ */

--  Global constant holding the package name

Type Sch_Group_Rec_Type IS RECORD (
request_id                  NUMBER := NULL,
entity_type                 VARCHAR2(30) := NULL,
header_id                   NUMBER := NULL, -- Group Identifier
line_id                     NUMBER := NULL, -- Group Identifier
top_model_line_id           NUMBER := NULL, -- Group Identifier
ship_set_number             NUMBER := NULL, -- Group Identifier
arrival_set_number          NUMBER := NULL, -- Group Identifier
-- Group Attributes
ship_from_org_id            NUMBER := NULL,
schedule_ship_date          DATE := NULL,
schedule_arrival_date       DATE := NULL,
request_date                DATE := NULL,
ship_to_org_id              NUMBER := NULL,
quantity                    NUMBER := NULL,
freight_carrier             VARCHAR2(30) := NULL,
latest_date                 DATE := NULL,
demand_class_code           VARCHAR2(30) := NULL,
shipment_priority           VARCHAR2(30) := NULL,
-- Old Group Attributes
old_ship_set_number         NUMBER := NULL,
old_arrival_set_number      NUMBER := NULL,
old_ship_from_org_id        NUMBER := NULL,
old_schedule_ship_date      DATE := NULL,
old_schedule_arrival_date   DATE := NULL,
old_request_date            DATE := NULL,
old_ship_to_org_id          NUMBER := NULL,
old_quantity                NUMBER := NULL,
old_freight_carrier         VARCHAR2(30) := NULL,
old_latest_date             DATE := NULL,
old_demand_class_code       VARCHAR2(30) := NULL,
old_shipment_priority       VARCHAR2(30) := NULL,
-- Scheduling Action
action                      VARCHAR2(30) := NULL,
delayed_request             VARCHAR2(30) := NULL,
explode                     VARCHAR2(30) := NULL);

TYPE number_arr IS TABLE OF number INDEX BY BINARY_INTEGER;

Procedure Group_Schedule(p_group_req_rec        IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
,x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type

,x_return_status OUT NOCOPY Varchar2);


Procedure Schedule_Order(p_header_id       IN  NUMBER,
                         p_sch_action      IN  VARCHAR2,
                         p_entity_type     IN  VARCHAR2,
                         p_line_id         IN  NUMBER,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);


Procedure Schedule_ATO(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2);


Procedure Schedule_set_of_lines
                ( p_old_line_tbl   IN  OE_ORDER_PUB.line_tbl_type,
                 p_x_line_tbl       IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
x_return_status OUT NOCOPY VARCHAR2);


Procedure Process_set_of_lines
           ( p_old_line_tbl  IN    OE_ORDER_PUB.line_tbl_type
                                    := OE_ORDER_PUB.G_MISS_LINE_TBL,
            p_write_to_db   IN    VARCHAR2 := FND_API.G_TRUE,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

            p_x_line_tbl      IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
            p_log_msg       IN VARCHAR2 := 'Y',
x_return_status OUT NOCOPY VARCHAR2);


Procedure Schedule_SMC(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_return_status OUT NOCOPY VARCHAR2);


Procedure Schedule_Set(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2);


Procedure Sch_Multi_selected_lines
              (p_line_list     IN  VARCHAR2,
              p_line_count     IN  NUMBER,
              p_action         IN  VARCHAR2,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);


Procedure Line_In_Sch_Group
(p_application_id              IN   NUMBER,
p_entity_short_name            IN   VARCHAR2,
p_validation_entity_short_name IN   VARCHAR2,
p_validation_tmplt_short_name  IN   VARCHAR2,
p_record_set_short_name        IN   VARCHAR2,
p_scope                        IN   VARCHAR2,
x_result OUT NOCOPY NUMBER);


FUNCTION Compare_Set_Attr
(p_set_ship_from_org_id    IN NUMBER ,
 p_line_ship_from_org_id   IN NUMBER,
 p_set_ship_to_org_id      IN NUMBER,
 p_line_ship_to_org_id     IN NUMBER,
 p_set_schedule_ship_date  IN DATE,
 p_line_schedule_ship_date IN DATE,
 p_set_arrival_date        IN DATE,
 p_line_arrival_date       IN DATE,
 p_set_type                IN VARCHAR2)
RETURN BOOLEAN;


END OE_GRP_SCH_UTIL;

 

/
