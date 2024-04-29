--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXLLINS.pls 120.1.12010000.1 2008/07/25 07:50:09 appldev ship $ */

-- Retreive the profile in global variable
g_cust_ord_enabled_flag       varchar2(1):=nvl(FND_PROFILE.Value('ONT_VAL_CUST_ORD_ENABLED_FLAG'),'N'); /* Bug # 5036404 */

-- Procedure Check_book_reqd_attributes.
PROCEDURE Check_Book_Reqd_Attributes
( p_line_rec        IN OE_Order_PUB.Line_Rec_Type
, p_old_line_rec    IN OE_Order_PUB.Line_Rec_Type
, x_return_status   IN OUT NOCOPY VARCHAR2
);

--  Procedure Entity

-- Bug 3572931 added the Param p_validation_level
PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2
, p_line_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec  IN OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
,   p_validation_level              IN NUMBER := FND_API.G_VALID_LEVEL_FULL
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
,   p_validation_level		      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
);

-- Procedure Validate_Flex, added for bug 2511313

PROCEDURE Validate_Flex
(   p_x_line_rec         IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type,
    p_old_line_rec       IN            OE_ORDER_PUB.line_rec_type :=
                                         OE_Order_PUB.G_MISS_LINE_REC,
    p_validation_level   IN            NUMBER,
    x_return_status      OUT NOCOPY    VARCHAR2
);


Procedure Validate_ShipSet_SMC
( p_line_rec       IN    OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN    OE_Order_PUB.Line_Rec_Type
 ,x_return_status  OUT   NOCOPY   VARCHAR2
  );

PROCEDURE Validate_Decimal_Quantity
( p_item_id			IN  NUMBER
, p_item_type_code		IN  VARCHAR2
, p_input_quantity		IN  NUMBER
, p_uom_code			IN  VARCHAR2
, p_ato_line_id                 IN  NUMBER
, p_line_id                     IN  NUMBER
, p_line_num                    IN  VARCHAR2
-- Parameter added for bug 3705273
, p_action_split                IN  VARCHAR2 := 'N'
, x_output_quantity             OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status		IN OUT NOCOPY VARCHAR2);

END OE_Validate_Line;

/
