--------------------------------------------------------
--  DDL for Package OE_MARGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MARGIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVMRGS.pls 120.2.12010000.1 2008/07/25 08:04:52 appldev ship $ */

G_SEEDED_MARGIN_HOLD_ID CONSTANT NUMBER:='40';

FUNCTION Get_Cost (p_line_rec       IN  OE_ORDER_PUB.LINE_REC_TYPE   DEFAULT OE_Order_Pub.G_MISS_LINE_REC
                  ,p_request_rec    IN Oe_Order_Pub.Request_Rec_Type DEFAULT Oe_Order_Pub.G_MISS_REQUEST_REC
                  ,p_order_currency IN VARCHAR2 Default NULL
                  ,p_sob_currency   IN VARCHAR2 Default NULL
                  ,p_inventory_item_id    IN NUMBER Default NULL
                  ,p_ship_from_org_id     IN NUMBER Default NULL
                  ,p_conversion_Type_code IN VARCHAR2 Default NULL
                  ,p_conversion_rate      IN NUMBER   Default NULL
                  ,p_item_type_code       IN VARCHAR2 Default 'STANDARD'
                  ,p_header_flag          IN Boolean  Default FALSE) RETURN NUMBER;

PROCEDURE Get_Order_Margin
(p_header_id              IN  NUMBER,
p_org_id  IN NUMBER default NULL,
x_order_margin_percent OUT NOCOPY NUMBER,

x_order_margin_amount OUT NOCOPY NUMBER);


PROCEDURE Margin_Hold
(p_header_id IN NUMBER);

procedure cost_action
                (
                 p_selected_records            Oe_Globals.Selected_Record_Tbl
                ,P_cost_level                  varchar2
);

--------------------------------------------------------------------
--Margin should only avail for pack I
--This is wrapper to a call to OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL
--------------------------------------------------------------------
Function Is_Margin_Avail return Boolean;


--Input line Record
--Output unit cost, margin amount and percent
Procedure Get_Line_Margin(p_line_rec In OE_ORDER_PUB.LINE_REC_TYPE,
                          x_unit_cost Out NOCOPY Number,
                          x_unit_margin_amount Out NOCOPY Number,
                          x_margin_percent Out NOCOPY Number);


End  OE_MARGIN_PVT;

/
