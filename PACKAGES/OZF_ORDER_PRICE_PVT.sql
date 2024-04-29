--------------------------------------------------------
--  DDL for Package OZF_ORDER_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ORDER_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvorps.pls 120.4 2006/12/15 03:22:53 mkothari ship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_HDR_TYPE   VARCHAR2(30) :='ORDER';
G_LINE_TYPE   VARCHAR2(30) :='LINE';

G_ORDER_HEADER_TYPE  VARCHAR2(30) :='ORDER';
G_ORDER_LINE_TYPE  VARCHAR2(30) :='LINE';


--===================================================================
--    Start of Comments
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================

TYPE LINE_REC_TYPE is RECORD
(
   LINE_INDEX                NUMBER,
   LINE_ID                   NUMBER,
   LINE_TYPE_CODE            VARCHAR2(30),
   PRICING_EFFECTIVE_DATE    DATE,
   ACTIVE_DATE_FIRST         DATE,
   ACTIVE_DATE_FIRST_TYPE    VARCHAR2(30),
   ACTIVE_DATE_SECOND        DATE,
   ACTIVE_DATE_SECOND_TYPE   VARCHAR2(30),
   LINE_QUANTITY             NUMBER,
   LINE_UOM_CODE             VARCHAR2(30),
   REQUEST_TYPE_CODE         VARCHAR2(30),
   PRICED_QUANTITY           NUMBER,
   PRICED_UOM_CODE           VARCHAR2(30),
   CURRENCY_CODE             VARCHAR2(30),
   UNIT_PRICE                NUMBER,
   PERCENT_PRICE             NUMBER,
   UOM_QUANTITY              NUMBER,
   ADJUSTED_UNIT_PRICE       NUMBER,
   UPD_ADJUSTED_UNIT_PRICE   NUMBER,
   PROCESSED_FLAG            VARCHAR2(1),
   PRICE_FLAG                VARCHAR2(1),
   PROCESSING_ORDER          NUMBER,
   PRICING_STATUS_CODE       VARCHAR2(30),
   PRICING_STATUS_TEXT       VARCHAR2(2000),
   ROUNDING_FLAG             VARCHAR2(1),
   ROUNDING_FACTOR           NUMBER,
   QUALIFIERS_EXIST_FLAG     VARCHAR2(1),
   PRICING_ATTRS_EXIST_FLAG  VARCHAR2(1),
   PRICE_LIST_ID             NUMBER,
   PL_VALIDATED_FLAG         VARCHAR2(1),
   PRICE_REQUEST_CODE        VARCHAR2(240),
   USAGE_PRICING_TYPE        VARCHAR2(30),
   LINE_CATEGORY             VARCHAR2(30),
   CHARGEBACK_INT_ID         NUMBER,
   RESALE_TABLE_TYPE         VARCHAR2(15),
   LIST_PRICE_OVERRIDE_FLAG  VARCHAR2(1) := NULL -- mkothari 13-dec-2006
);



TYPE LINE_REC_TBL_TYPE is table of LINE_REC_TYPE index by binary_integer;


G_HEADER_REC oe_order_pub.header_rec_type;

TYPE G_LINE_REC_TBL_TYPE is table of oe_order_pub.line_rec_type index by binary_integer;

G_LINE_REC_TBL G_LINE_REC_TBL_TYPE;

TYPE LDETS_TBL_TYPE is table of qp_ldets_v%rowtype index by binary_integer;

TYPE RLTD_LINE_TBL_TYPE is table of QP_PREQ_RLTD_LINES_TMP%rowtype index by binary_integer;


-- R12 IDSM Resale Global Structure (+)
TYPE RESALE_LINE_REC_TYPE IS RECORD (
 QP_CONTEXT_REQUEST_ID                    NUMBER,
 LINE_INDEX                               NUMBER,

 BATCH_TYPE                               VARCHAR2(30),
 RESALE_TABLE_TYPE                        VARCHAR2(15),
 LINE_ID                                  NUMBER,

 RESALE_TRANSFER_TYPE                     VARCHAR2(30),
 PRODUCT_TRANSFER_MOVEMENT_TYPE           VARCHAR2(30),
 PRODUCT_TRANSFER_DATE                    DATE,
 TRACING_FLAG                             VARCHAR2(1),

 SOLD_FROM_CUST_ACCOUNT_ID                NUMBER,
 SOLD_FROM_SITE_ID                        NUMBER,
 SOLD_FROM_CONTACT_PARTY_ID               NUMBER,

 SHIP_FROM_CUST_ACCOUNT_ID                NUMBER,
 SHIP_FROM_SITE_ID                        NUMBER,
 SHIP_FROM_CONTACT_PARTY_ID               NUMBER,

 BILL_TO_PARTY_ID                         NUMBER,
 BILL_TO_PARTY_SITE_ID                    NUMBER,
 BILL_TO_CONTACT_PARTY_ID                 NUMBER,

 SHIP_TO_PARTY_ID                         NUMBER,
 SHIP_TO_PARTY_SITE_ID                    NUMBER,
 SHIP_TO_CONTACT_PARTY_ID                 NUMBER,

 END_CUST_PARTY_ID                        NUMBER,
 END_CUST_SITE_USE_ID                     NUMBER,
 END_CUST_SITE_USE_CODE                   VARCHAR2(30),
 END_CUST_PARTY_SITE_ID                   NUMBER,
 END_CUST_CONTACT_PARTY_ID                NUMBER,

 DATA_SOURCE_CODE                         VARCHAR2(30),

 HEADER_ATTRIBUTE_CATEGORY                VARCHAR2(30),
 HEADER_ATTRIBUTE1                        VARCHAR2(240),
 HEADER_ATTRIBUTE2                        VARCHAR2(240),
 HEADER_ATTRIBUTE3                        VARCHAR2(240),
 HEADER_ATTRIBUTE4                        VARCHAR2(240),
 HEADER_ATTRIBUTE5                        VARCHAR2(240),
 HEADER_ATTRIBUTE6                        VARCHAR2(240),
 HEADER_ATTRIBUTE7                        VARCHAR2(240),
 HEADER_ATTRIBUTE8                        VARCHAR2(240),
 HEADER_ATTRIBUTE9                        VARCHAR2(240),
 HEADER_ATTRIBUTE10                       VARCHAR2(240),
 HEADER_ATTRIBUTE11                       VARCHAR2(240),
 HEADER_ATTRIBUTE12                       VARCHAR2(240),
 HEADER_ATTRIBUTE13                       VARCHAR2(240),
 HEADER_ATTRIBUTE14                       VARCHAR2(240),
 HEADER_ATTRIBUTE15                       VARCHAR2(240),

 LINE_ATTRIBUTE_CATEGORY                  VARCHAR2(30),
 LINE_ATTRIBUTE1                          VARCHAR2(240),
 LINE_ATTRIBUTE2                          VARCHAR2(240),
 LINE_ATTRIBUTE3                          VARCHAR2(240),
 LINE_ATTRIBUTE4                          VARCHAR2(240),
 LINE_ATTRIBUTE5                          VARCHAR2(240),
 LINE_ATTRIBUTE6                          VARCHAR2(240),
 LINE_ATTRIBUTE7                          VARCHAR2(240),
 LINE_ATTRIBUTE8                          VARCHAR2(240),
 LINE_ATTRIBUTE9                          VARCHAR2(240),
 LINE_ATTRIBUTE10                         VARCHAR2(240),
 LINE_ATTRIBUTE11                         VARCHAR2(240),
 LINE_ATTRIBUTE12                         VARCHAR2(240),
 LINE_ATTRIBUTE13                         VARCHAR2(240),
 LINE_ATTRIBUTE14                         VARCHAR2(240),
 LINE_ATTRIBUTE15                         VARCHAR2(240)
);

TYPE RESALE_LINE_TBL_TYPE IS TABLE OF RESALE_LINE_REC_TYPE
INDEX BY BINARY_INTEGER;

G_RESALE_LINE_REC                         RESALE_LINE_REC_TYPE;
G_RESALE_LINE_TBL                         RESALE_LINE_TBL_TYPE;
-- R12 IDSM Resale Global Structure (-)


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Order_Price
--
-- PURPOSE
--    Get the price of an order
--
-- PARAMETERS
--
--
-- NOTES
--    1. get list of order line as an input.
--    2. call build order and build line to create order structure.
--    3. construct the control rec
--    4. call pricing engine.
--    5. return the result of pricing engine call.
---------------------------------------------------------------------
PROCEDURE  Get_Order_Price (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_control_rec            IN            QP_PREQ_GRP.CONTROL_RECORD_TYPE
   ,xp_line_tbl              IN OUT NOCOPY LINE_REC_TBL_TYPE
   ,x_ldets_tbl              OUT NOCOPY    LDETS_TBL_TYPE
   ,x_related_lines_tbl      OUT NOCOPY    RLTD_LINE_TBL_TYPE
);

---------------------------------------------------------------------
-- PROCEDURE
--    Purge_Pricing_Temp_table
--
-- PURPOSE
--    Purge the pricing temp table
--
-- PARAMETERS
--
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Purge_Pricing_Temp_table (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);
END OZF_ORDER_PRICE_PVT;

 

/
