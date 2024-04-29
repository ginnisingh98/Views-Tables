--------------------------------------------------------
--  DDL for Package OE_SCH_ORGANIZER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SCH_ORGANIZER_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSCOS.pls 120.2.12010000.3 2009/04/08 08:43:05 spothula ship $ */

TYPE sch_line_rec_type is RECORD (
org_id                   NUMBER, -- R12.MOAC--
header_id                NUMBER,
line_id                  NUMBER,
schedule_ship_date       DATE,
schedule_arrival_date    DATE,
demand_class_code        VARCHAR2(30),
shipment_priority_code   VARCHAR2(30),
planning_priority        NUMBER,
ship_from_org_id         NUMBER,
reserved_quantity        NUMBER,
subinventory             VARCHAR2(10),
ship_set                 VARCHAR2(40),
arrival_set              VARCHAR2(40),
project_id               NUMBER,
task_id                  NUMBER,
end_item_unit_number     VARCHAR2(30),
source_type_code         VARCHAR2(30),
shipping_method_code     VARCHAR2(30),
override_atp_date_code   VARCHAR2(30),
late_demand_penalty_factor NUMBER,
latest_acceptable_date   DATE,
exclude                  VARCHAR2(1),
ship_set_changed         VARCHAR2(1),
arrival_set_changed      VARCHAR2(1),
Corrected_Qty            NUMBER,
Corrected_Qty2           NUMBER, -- INVCONV
reserved_quantity2       NUMBER, -- INVCONV
firm_demand_flag         VARCHAR2(1) -- for bug 8370582
);

TYPE sch_line_tbl_type IS TABLE OF sch_line_rec_type
  INDEX BY BINARY_INTEGER;

--3751812 : Size of line_list increased from 2000 to 32000
TYPE line_list_rec_typ IS RECORD(
     line_list VARCHAR2(32000),
     count     NUMBER);

TYPE line_list_tab_typ IS TABLE OF line_list_rec_typ INDEX BY BINARY_INTEGER;

TYPE header_line_rec IS RECORD(
     line_id NUMBER,
     header_id NUMBER,
     exclude VARCHAR2(1));
TYPE header_line_tab IS TABLE OF header_line_rec INDEX BY BINARY_INTEGER;


PROCEDURE Sch_Window_Key_Commit
(p_x_sch_line_tbl IN OUT NOCOPY sch_line_tbl_type,
 x_return_status OUT NOCOPY VARCHAR2,
 x_msg_count OUT NOCOPY NUMBER,
 x_msg_data OUT NOCOPY VARCHAR2,
 x_failed_count OUT NOCOPY NUMBER);

PROCEDURE Order_Boundary_Sorting(p_line_list IN VARCHAR2, p_count IN NUMBER,
                                 x_line_list_tbl OUT NOCOPY line_list_tab_typ);
--Pack J
FUNCTION Submit_Reservation_Request
(p_selected_line_tbl    IN OE_GLOBALS.selected_record_tbl, --R12.MOAC
 p_reservation_mode     IN VARCHAR2 DEFAULT NULL,
 p_percent              IN NUMBER DEFAULT NULL,
 p_reserve_run_type     IN VARCHAR2,
 p_reservation_set_Name IN VARCHAR2 DEFAULT NULL,
 p_override_set         IN VARCHAR2 DEFAULT 'N',
 p_order_by             IN VARCHAR2 DEFAULT NULL,
 p_partial_preference   IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;

PROCEDURE Update_Reservation_Qty
(p_reservation_set  IN  VARCHAR2,
 p_sch_line_tbl  IN  OE_SCH_ORGANIZER_UTIL.sch_line_tbl_type);

FUNCTION Reservation_Set_Processed
(p_reservation_set_name  IN VARCHAR2)
RETURN BOOLEAN;

  -- R12.MOAC
PROCEDURE Insert_into_tmp_tab(p_line_id IN NUMBER);
PROCEDURE Insert_into_tmp_tab(p_line_tbl IN OE_GLOBALS.Selected_Record_Tbl);
PROCEDURE delete_tmp_tab;

PROCEDURE Process_Schedule_Action
(p_selected_line_tbl     IN   OE_GLOBALS.Selected_Record_Tbl,
p_sch_action             IN   VARCHAR2,
x_atp_tbl                OUT NOCOPY oe_atp.atp_tbl_type,
x_return_status          OUT NOCOPY VARCHAR2,
x_msg_count              OUT NOCOPY NUMBER,
x_msg                    OUT NOCOPY VARCHAR2);

END OE_SCH_ORGANIZER_UTIL;

/
