--------------------------------------------------------
--  DDL for Package OE_BLKT_RELEASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLKT_RELEASE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUBRLS.pls 120.1.12010000.2 2009/09/24 08:57:48 smanian ship $ */

-- 11i10 Pricing Change
-- Move cached blanket header/line values to package spec
TYPE Blanket_Line_Rec_TYPE IS RECORD
         (LINE_ID                             NUMBER
         ,HEADER_ID                           NUMBER
         ,OVERRIDE_BLANKET_CONTROLS_FLAG      VARCHAR2(1)
         ,OVERRIDE_RELEASE_CONTROLS_FLAG      VARCHAR2(1)
         ,RELEASED_AMOUNT                     NUMBER
         ,RETURNED_AMOUNT                     NUMBER
         ,MIN_RELEASE_AMOUNT                  NUMBER
         ,MAX_RELEASE_AMOUNT                  NUMBER
         ,BLANKET_LINE_MAX_AMOUNT             NUMBER
         ,BLANKET_MAX_QUANTITY                NUMBER
         ,RELEASED_QUANTITY                   NUMBER
         ,FULFILLED_QUANTITY                  NUMBER
         ,FULFILLED_AMOUNT                    NUMBER
         ,MIN_RELEASE_QUANTITY                NUMBER
         ,MAX_RELEASE_QUANTITY                NUMBER
         ,UOM                                 VARCHAR2(30)
         ,RETURNED_QUANTITY                   NUMBER
         -- 11i10 Pricing change, add new attributes to cache
         -- old values sourced from this order against this blanket line
         ,LOCKED_FLAG                         VARCHAR2(1)
         );

TYPE Blanket_Line_Tbl_TYPE IS TABLE OF Blanket_Line_Rec_TYPE
INDEX BY BINARY_INTEGER;

TYPE Blanket_Header_Rec_TYPE IS RECORD
         (
	  HEADER_ID                           NUMBER
	 ,OVERRIDE_AMOUNT_FLAG                VARCHAR2(1)
         ,RELEASED_AMOUNT                     NUMBER
         ,RETURNED_AMOUNT                     NUMBER
         ,FULFILLED_AMOUNT                    NUMBER
         ,BLANKET_MAX_AMOUNT                  NUMBER
         ,CURRENCY_CODE                       VARCHAR2(15) -- Bug 5511359
         ,CONVERSION_TYPE_CODE                VARCHAR2(30)
         -- 11i10 Pricing change, add new attributes to cache
         -- old values sourced from this order against this blanket header
         ,LOCKED_FLAG                         VARCHAR2(1)
         );

TYPE Blanket_Header_Tbl_TYPE IS TABLE OF Blanket_Header_Rec_TYPE
INDEX BY BINARY_INTEGER;

g_blkt_line_tbl           Blanket_Line_Tbl_TYPE;
g_blkt_hdr_tbl            Blanket_Header_Tbl_TYPE;

TYPE BL_Order_Val_Rec_TYPE IS RECORD
         (ORDER_RELEASED_QUANTITY             NUMBER
         ,ORDER_RELEASED_AMOUNT               NUMBER
         );

TYPE BL_Order_Val_Tbl_TYPE IS TABLE OF BL_Order_Val_Rec_TYPE
INDEX BY BINARY_INTEGER;

TYPE BH_Order_Val_Rec_TYPE IS RECORD
         (ORDER_RELEASED_AMOUNT               NUMBER
         );

TYPE BH_Order_Val_Tbl_TYPE IS TABLE OF BH_Order_Val_Rec_TYPE
INDEX BY BINARY_INTEGER;

g_bl_order_val_tbl        BL_Order_Val_Tbl_TYPE;
g_bh_order_val_tbl        BH_Order_Val_Tbl_TYPE;

FUNCTION Convert_Amount
  (p_from_currency       IN VARCHAR2
  ,p_to_currency         IN VARCHAR2
  ,p_conversion_date     IN DATE
  ,p_conversion_type     IN VARCHAR2
  ,p_amount              IN NUMBER
  )
RETURN NUMBER;

PROCEDURE Process_Releases
  (p_request_tbl      IN OUT NOCOPY OE_ORDER_PUB.Request_Tbl_Type
  ,x_return_status    OUT NOCOPY VARCHAR2
  );

PROCEDURE Populate_Old_Values
(p_blanket_number              IN NUMBER
,p_blanket_line_number         IN NUMBER
,p_line_id                     IN NUMBER
,p_old_quantity                IN NUMBER DEFAULT NULL
,p_old_unit_sp                 IN NUMBER DEFAULT NULL
,p_header_id                   IN NUMBER DEFAULT NULL
);

PROCEDURE Cache_Order_Qty_Amt
  (p_request_rec      IN OUT NOCOPY OE_ORDER_PUB.Request_Rec_Type
  ,x_return_status    OUT NOCOPY VARCHAR2
  );

END;

/
