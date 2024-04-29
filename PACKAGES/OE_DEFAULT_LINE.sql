--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXDLINS.pls 120.0.12010000.4 2009/10/28 08:27:28 cpati ship $ */

PROCEDURE Attributes
(   p_x_Line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_Line_rec                  IN  OE_Order_PUB.Line_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

FUNCTION Get_Line
RETURN NUMBER;

FUNCTION Get_Shipment_Number
RETURN NUMBER;

FUNCTION Get_Line_Number
RETURN NUMBER;

FUNCTION Get_Defaulting_Invoice_Line(p_return_context IN VARCHAR2,
                                     p_return_attribute1 IN VARCHAR2,
                                     p_return_attribute2 IN VARCHAR2)
RETURN NUMBER;
FUNCTION Get_Dual_Uom -- INVCONV
(
  p_line_rec          OE_ORDER_PUB.Line_Rec_Type
)
RETURN VARCHAR2;



FUNCTION Get_Defaulting_Order_Line(p_return_context IN VARCHAR2,
                                   p_return_attribute1 IN VARCHAR2,
                                   p_return_attribute2 IN VARCHAR2)
RETURN NUMBER;

-- to default return attributes from referenced invoice line
Procedure Attributes_From_Invoice_Line
(   p_invoice_line_id 	IN NUMBER
,   p_x_line_rec  		IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

-- to default return attributes from referenced order line
Procedure Attributes_From_Order_Line
(   p_order_line_id 	IN NUMBER
,   p_x_line_rec  		IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

-- to default return attributes
Procedure Return_Attributes
(   p_x_line_rec      	IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec  	IN  OE_Order_PUB.Line_Rec_Type
);

FUNCTION Get_Item_Type(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
                       p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2;

PROCEDURE Insert_into_set
(p_line_id         IN NUMBER,
 p_child_line_id        IN NUMBER,
 x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

-- 2806483
--  Added to spec to call the API from other packages.
FUNCTION GET_FREIGHT_CARRIER(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
                             p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2;

/* Added for Pack J to support Config and Service items for Blanket Functionality
 -- Added this package to populate the Service and Config
 -- Related Blanket Number, Blanket Line Number and Version Number
 -- By Srini
*/

PROCEDURE Get_Blanket_Number_SVC_CONFIG
  ( p_blanket_number           IN  OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_inventory_item_id        IN  NUMBER,
    x_blanket_line_number      OUT NOCOPY number,
    x_blanket_version_number   OUT NOCOPY number);

/* Made BSA defaulting procedure public.
   --By Srini
*/
PROCEDURE Default_Blanket_Values
(  p_blanket_number IN NUMBER,
   p_cust_po_number IN VARCHAR2,
   p_ordered_item_id IN NUMBER DEFAULT NULL, --bug6826787
   p_ordered_item IN VARCHAR2 ,
   p_inventory_item_id IN NUMBER,
   p_item_identifier_type IN VARCHAR2,
   p_request_date IN DATE,
   p_sold_to_org_id IN NUMBER,
   x_blanket_number OUT NOCOPY NUMBER,
   x_blanket_line_number OUT NOCOPY NUMBER,
   x_blanket_version_number OUT NOCOPY NUMBER,
   x_blanket_request_date OUT NOCOPY DATE
);


/*PROCEDURE Get_Blanket_Number_SVC_CONFIG
  ( p_blanket_number           IN  OUT NUMBER,
    p_inventory_item_id        IN  NUMBER,
    x_blanket_line_number      OUT NOCOPY number,
    x_blanket_version_number   OUT NOCOPY number); */ -- INVCONV FOR PROBLEM


--8319535 start
/*9040537
FUNCTION Get_Def_Invoice_Line_Int
(p_return_context IN VARCHAR2,
p_return_attribute1 IN VARCHAR2,
p_return_attribute2 IN VARCHAR2,
p_sold_to_org_id    IN NUMBER,
p_curr_code     IN VARCHAR2,
p_ref_line_id OUT NOCOPY NUMBER

) RETURN NUMBER;
9040537*/
--8319535 end


END OE_Default_Line;

/
