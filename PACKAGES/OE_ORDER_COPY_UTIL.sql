--------------------------------------------------------
--  DDL for Package OE_ORDER_COPY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_COPY_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCPYS.pls 120.2.12010000.7 2010/04/07 06:09:14 spothula ship $ */

G_PKG_NAME       			  CONSTANT VARCHAR2(30) := 'OE_ORDER_COPY_UTIL';
G_CPY_ORIG_PRICE 			  CONSTANT NUMBER := 1;
G_CPY_REPRICE    			  CONSTANT NUMBER := 2;
G_CPY_REPRICE_WITH_ORIG_DATE    CONSTANT NUMBER := 3;
/* Added the following variable to fix the bug 2107810 */
G_CPY_REPRICE_PARTIAL           CONSTANT NUMBER := 4;
G_Canceled_Line_Deleted       BOOLEAN;
G_Order_Has_Split_Lines       BOOLEAN;
G_REGULAR_TO_RMA              BOOLEAN;
/* Added the following line to fix the bug 1923460 */
G_ORDER_LEVEL_COPY NUMBER := 0;
/* Added to support copy of older versions.. */
G_HDR_VER_NUMBER    	      NUMBER := NULL;
G_HDR_PHASE_CHANGE_FLAG    	  VARCHAR2(1) := NULL;
G_LN_VER_NUMBER    	          NUMBER := NULL;
G_LN_PHASE_CHANGE_FLAG    	  VARCHAR2(1) := NULL;
G_LINE_PRICE_MODE                 NUMBER;
--R12 CC Encryption
G_Create_Payment_Flag	VARCHAR2(1) := 'N';
G_TRXN_EXTENSION_ID   NUMBER;
G_Payment_Type_Code   VARCHAR2(30);
--R12 CC Encryption

TYPE T_NUM   is TABLE OF NUMBER;
TYPE T_V30   is TABLE OF VARCHAR(30);
TYPE T_V1    is TABLE OF VARCHAR(1);

TYPE Line_Number_Rec_Type IS RECORD
(  line_id                 T_NUM := T_NUM(),
   new_line_id             T_NUM := T_NUM(),
   line_number             T_NUM := T_NUM(),
   shipment_number         T_NUM := T_NUM(),
   option_number           T_NUM := T_NUM(),
   component_number        T_NUM := T_NUM(),
   service_number          T_NUM := T_NUM(),
   split_from_line_id      T_NUM := T_NUM(),
   source_document_Line_id T_NUM := T_NUM(),
   source_document_type_id T_NUM := T_NUM(),
   split_by                T_V30 := T_V30(),
   line_set_id             T_NUM := T_NUM(),
   item_type_code          T_V30 := T_V30(),
   service_reference_line_id  T_NUM := T_NUM(),
   link_to_line_id         T_NUM := T_NUM(),
   top_model_line_id       T_NUM := T_NUM() --9534576
);

G_Line_Num_Rec Line_Number_Rec_Type;

TYPE Line_Set_Rec_Type IS RECORD
(  line_id                 NUMBER,
   old_line_id             NUMBER,
   line_index              NUMBER,
   parent_line_index       NUMBER,
   header_id               NUMBER,
   line_type_id            NUMBER,
   line_set_id             NUMBER,
   old_set_id              NUMBER,
   set_count               NUMBER
);

TYPE Line_Set_Tbl_Type IS TABLE OF Line_Set_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Copy Order IN parameter will be replaced with record type.
TYPE Copy_Rec_Type IS RECORD
( api_version_number  NUMBER
 ,init_msg_list       VARCHAR2(1)  --  := FND_API.G_FALSE
 ,commit              VARCHAR2(1)  --  := FND_API.G_FALSE
 ,copy_order          VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_count           NUMBER         := 0
 ,append_to_header_id NUMBER         := NULL
 ,hdr_info            VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_type            NUMBER         := NULL
 ,hdr_descflex        VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_scredits        VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_attchmnts       VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_holds           VARCHAR2(1)  --  := FND_API.G_TRUE
 ,hdr_credit_card_details VARCHAR2(1) -- := FND_API.G_FALSE
 ,version_number      NUMBER := NULL
 ,line_version_number NUMBER := NULL
 ,copy_transaction_name VARCHAR2(1) -- := FND_API.G_FALSE
 ,copy_expiration_date VARCHAR2(1)  -- := FND_API.G_FALSE
 ,expiration_date     DATE
 ,transaction_name    VARCHAR2(240)
 ,new_phase           VARCHAR2(1) -- N or F
 ,phase_change_flag   VARCHAR2(1) -- N or F
 ,line_phase_change_flag   VARCHAR2(1) -- N or F
 ,version_reason_code VARCHAR2(30)
 ,comments            VARCHAR2(2000)
 ,manual_quote_number NUMBER
 ,manual_order_number NUMBER         := NULL
 ,all_lines           VARCHAR2(1)  --  := FND_API.G_TRUE
 ,line_count          NUMBER         := 0
 ,line_type           NUMBER         := NULL
 ,incl_cancelled      VARCHAR2(1)  --  := FND_API.G_FALSE
 ,line_price_mode     NUMBER       --  := G_CPY_ORIG_PRICE
 ,line_price_date     DATE         --  := FND_API.G_MISS_DATE
 ,line_discount_id    NUMBER         := NULL
 ,line_descflex       VARCHAR2(1)  --  := FND_API.G_TRUE
 ,line_scredits       VARCHAR2(1)  --  := FND_API.G_TRUE
 ,line_attchmnts      VARCHAR2(1)  --  := FND_API.G_TRUE
 ,line_holds          VARCHAR2(1)  --  := FND_API.G_TRUE
 ,return_reason_code  VARCHAR2(30)   := NULL
 ,default_null_values VARCHAR2(1)
 ,copy_complete_config  VARCHAR2(1)
 ,source_block_type   VARCHAR2(30)
 ,hdr_payments        VARCHAR2(1)  --  := FND_API.G_FALSE
 ,line_payments       VARCHAR2(1)  --  := FND_API.G_FALSE
 -- Copy Sets ER #2830872 , #1566254.
 ,line_fulfill_sets   VARCHAR2(1)  --  := FND_API.G_FALSE
 ,line_ship_arr_sets  VARCHAR2(1)  --  := FND_API.G_FALSE
 -- Copy Sets ER #2830872 , #1566254.
 --ER 7258165 : Start : Copy accross organizations
 ,copy_org_id NUMBER --Store new order org context
 ,source_org_id NUMBER --Store Source block's org context
 ,source_access_mode VARCHAR2(1) := 'S'  --Store Source block's org context
 --ER 7258165 : End
 );

G_COPY_REC copy_rec_type;

--  Top Model Line record type

/* Start - Code for Bug 1923460, 3923574 */

TYPE Top_Model_Rec_Type IS RECORD
(  config_header_id        NUMBER,
   config_rev_nbr          NUMBER,
   has_canceled_lines      VARCHAR2(1)); -- added new attribute for bug3923574

TYPE Top_Model_Tbl_Type IS TABLE OF Top_Model_Rec_Type
    INDEX BY BINARY_INTEGER;

/* End - Code for Bug 1923460, 3923574 */


Function get_copy_rec
RETURN copy_rec_type;

Function Get_Order_Category
( p_order_type_id IN NUMBER )
RETURN VARCHAR2;

Function Get_Default_line
( p_order_type_id IN  NUMBER
,x_line_type_id OUT NOCOPY NUMBER)
RETURN VARCHAR2;

Function Get_Line_Category
( p_Line_type_id IN NUMBER )
RETURN VARCHAR2;

PROCEDURE Copy_Order
 (p_copy_rec	 IN  copy_rec_type
,p_hdr_id_tbl    IN  OE_GLOBALS.Selected_Record_Tbl
,p_line_id_tbl   IN  OE_GLOBALS.Selected_Record_Tbl
,x_header_id     OUT NOCOPY NUMBER
,x_return_status OUT NOCOPY VARCHAR2
,x_msg_count     OUT NOCOPY NUMBER
,x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE copy_line_dff_from_ref
(p_ref_line_rec IN OE_Order_PUB.Line_Rec_Type,
 p_x_line_rec   IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type);

Function CALL_DFF_COPY_EXTN_API(p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;

-- Copy Sets ER #2830872 , #1566254 Begin.
PROCEDURE COPY_LINE_SETS(
p_old_header_id         IN NUMBER,
p_new_header_id         IN NUMBER,
p_line_tbl              IN OE_Order_PUB.Line_Tbl_Type,
p_copy_fulfillment_sets IN BOOLEAN,
p_copy_ship_arr_sets    IN BOOLEAN,
x_result               OUT NOCOPY VARCHAR2);
-- Copy Sets ER #2830872 , #1566254 End.

END OE_Order_Copy_Util;

/
