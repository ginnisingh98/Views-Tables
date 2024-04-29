--------------------------------------------------------
--  DDL for Package OE_FREIGHT_CHOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FREIGHT_CHOICES_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVFCHS.pls 120.3.12010000.1 2008/07/25 07:59:51 appldev ship $ */

TYPE shipment_summary_rec_type IS RECORD
(consolidation_id      	NUMBER,
 shipping_method	VARCHAR2(80),
 shipping_method_code	VARCHAR2(30),
 ship_from		VARCHAR2(40),
 ship_to		VARCHAR2(40),
 transit_time		NUMBER,
 charge_amount          NUMBER,
 cost		     	NUMBER,
 total_weight           NUMBER,
 weight_uom             VARCHAR2(3),
 total_Volume           NUMBER,
 volume_uom             Varchar2(3),
 Freight_Terms          Varchar2(30),
 scheduled_ship_date    DATE);

TYPE shipment_summary_tbl_type IS TABLE OF shipment_summary_rec_type
INDEX BY BINARY_INTEGER;

TYPE freight_choices_rec_type IS RECORD
(consolidation_id      NUMBER,
 shipping_method	VARCHAR2(80),
 shipping_method_code	VARCHAR2(30),
 transit_time		NUMBER,
 transit_time_uom       VARCHAR2(10),
 charge_amount          NUMBER,
 cost		     	NUMBER,
 lane_id                NUMBER); --bug 4408958

TYPE freight_choices_tbl_type IS TABLE OF freight_choices_rec_type
INDEX BY BINARY_INTEGER;

TYPE Ship_date_rec_type IS Record
(schedule_ship_date    DATE,
 line_id               NUMBER);

TYPE Ship_Date_Tbl IS Table of Ship_date_rec_type
INDEX BY BINARY_INTEGER;

TYPE line_shipment_details_rec_type IS RECORD
(source_line_id       NUMBER,
 inventory_item_id    NUMBER,
 source_quantity      NUMBER,
 source_quantity_uom  VARCHAR2(3),
 ship_date            DATE,
 arrival_date         DATE);

TYPE line_shipment_details_tbl_type IS TABLE OF line_shipment_details_rec_type
INDEX BY BINARY_INTEGER;

g_fte_source_line_tab  	                FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab;
G_shipment_summary_tbl	                shipment_summary_tbl_type;
G_shipment_summary_count	       	NUMBER;
G_shipment_summary_index		NUMBER;
G_Ship_Date_tbl                         Ship_Date_Tbl;

G_FTE_SOURCE_LINE_RATE_TAB      FTE_PROCESS_REQUESTS.fte_source_line_rates_Tab;
G_FTE_LINE_RATE_TAB      FTE_PROCESS_REQUESTS.fte_source_line_rates_Tab;
G_FTE_header_RATE_TAB      FTE_PROCESS_REQUESTS.fte_source_header_rates_Tab;
G_freight_choices_tbl freight_choices_tbl_type;
G_freight_choices_count			NUMBER;
G_freight_choices_index			NUMBER;
G_line_tbl		OE_Order_PUB.Line_Tbl_Type;

G_FTE_SOURCE_HEADER_TAB      FTE_PROCESS_REQUESTS.Fte_Source_Header_Tab;
g_line_shipment_details_tbl   FTE_PROCESS_REQUESTS.fte_source_line_Tab ;

PROCEDURE Get_Shipment_Summary
(p_header_id		IN NUMBER,
 x_shipment_count       OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Shipment_Summary_Tbl(
	x_shipment_summary_tbl IN OUT NOCOPY /* file.sql.39 change */ shipment_summary_tbl_type);

PROCEDURE Get_Freight_Choices
( p_consolidation_id              	IN    NUMBER,
  x_return_status                       OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
  x_msg_count                           OUT NOCOPY /* file.sql.39 change */   NUMBER,
  x_msg_data                             OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
;

PROCEDURE Get_Freight_Choices_Tbl
(x_freight_choices_tbl	IN OUT NOCOPY /* file.sql.39 change */ freight_choices_tbl_type);

PROCEDURE Get_Shipment_Details_Tbl
(x_Line_Shipment_Details_tbl IN OUT NOCOPY /* file.sql.39 change */ line_Shipment_Details_tbl_type);

PROCEDURE Process_Freight_Choices
( p_header_id          	 IN    NUMBER
 ,p_consolidation_id     IN    NUMBER
 ,p_ship_method_code     IN    VARCHAR2
 ,p_lane_id              IN    NUMBER   --bug 4408958
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */   VARCHAR2
 ,x_msg_count           OUT NOCOPY /* file.sql.39 change */   NUMBER
 ,x_msg_data            OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

-- FUNCTION get_method RETURN VARCHAR2;

PROCEDURE Cancel_all;

-- Bug 6186084
PROCEDURE Repopulate_Freight_Choices
( x_volume       OUT NOCOPY NUMBER
 ,x_weight       OUT NOCOPY NUMBER
 ,x_consolidation_id IN NUMBER);

END OE_FREIGHT_CHOICES_PVT;

/
