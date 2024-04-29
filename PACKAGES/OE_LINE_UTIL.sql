--------------------------------------------------------
--  DDL for Package OE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULINS.pls 120.5.12010000.3 2009/04/27 10:59:10 cpati ship $ */

--  Attributes global constants

G_ACCOUNTING_RULE              CONSTANT NUMBER := 1;
G_ACTUAL_ARRIVAL_DATE          CONSTANT NUMBER := 2;
G_ACTUAL_SHIPMENT_DATE         CONSTANT NUMBER := 3;
G_AGREEMENT                    CONSTANT NUMBER := 4;
G_ATO_LINE                     CONSTANT NUMBER := 5;
G_ATTRIBUTE1                   CONSTANT NUMBER := 6;
G_ATTRIBUTE10                  CONSTANT NUMBER := 7;
G_ATTRIBUTE11                  CONSTANT NUMBER := 8;
G_ATTRIBUTE12                  CONSTANT NUMBER := 9;
G_ATTRIBUTE13                  CONSTANT NUMBER := 10;
G_ATTRIBUTE14                  CONSTANT NUMBER := 11;
G_ATTRIBUTE15                  CONSTANT NUMBER := 12;
G_ATTRIBUTE2                   CONSTANT NUMBER := 13;
G_ATTRIBUTE3                   CONSTANT NUMBER := 14;
G_ATTRIBUTE4                   CONSTANT NUMBER := 15;
G_ATTRIBUTE5                   CONSTANT NUMBER := 16;
G_ATTRIBUTE6                   CONSTANT NUMBER := 17;
G_ATTRIBUTE7                   CONSTANT NUMBER := 18;
G_ATTRIBUTE8                   CONSTANT NUMBER := 19;
G_ATTRIBUTE9                   CONSTANT NUMBER := 20;
G_AUTO_SELECTED_QUANTITY       CONSTANT NUMBER := 21;
G_CANCELLED_QUANTITY           CONSTANT NUMBER := 22;
G_COMPONENT                    CONSTANT NUMBER := 23;
G_COMPONENT_NUMBER             CONSTANT NUMBER := 24;
G_COMPONENT_SEQUENCE           CONSTANT NUMBER := 25;
G_CONFIG_DISPLAY_SEQUENCE      CONSTANT NUMBER := 26;
G_CONFIGURATION                CONSTANT NUMBER := 27;
G_CONTEXT                      CONSTANT NUMBER := 28;
G_CREATED_BY                   CONSTANT NUMBER := 31;
G_CREATION_DATE                CONSTANT NUMBER := 32;
G_CUSTOMER_DOCK                CONSTANT NUMBER := 33;
G_CUSTOMER_JOB                 CONSTANT NUMBER := 36;
G_CUSTOMER_PRODUCTION_LINE     CONSTANT NUMBER := 37;
G_CUSTOMER_TRX_LINE            CONSTANT NUMBER := 38;
G_CUST_MODEL_SERIAL_NUMBER     CONSTANT NUMBER := 39;
G_CUST_PO_NUMBER               CONSTANT NUMBER := 40;
G_DELIVERY_LEAD_TIME           CONSTANT NUMBER := 41;
G_DELIVER_TO_CONTACT           CONSTANT NUMBER := 42;
G_DELIVER_TO_ORG               CONSTANT NUMBER := 43;
G_DEMAND_BUCKET_TYPE           CONSTANT NUMBER := 44;
G_DEMAND_CLASS                 CONSTANT NUMBER := 45;
G_DEP_PLAN_REQUIRED            CONSTANT NUMBER := 46;
G_EARLIEST_ACCEPTABLE_DATE     CONSTANT NUMBER := 48;
G_EXPLOSION_DATE               CONSTANT NUMBER := 49;
G_FOB_POINT                    CONSTANT NUMBER := 50;
G_FREIGHT_CARRIER              CONSTANT NUMBER := 51;
G_FREIGHT_TERMS                CONSTANT NUMBER := 52;
G_FULFILLED_QUANTITY           CONSTANT NUMBER := 53;
G_GLOBAL_ATTRIBUTE1            CONSTANT NUMBER := 54;
G_GLOBAL_ATTRIBUTE10           CONSTANT NUMBER := 55;
G_GLOBAL_ATTRIBUTE11           CONSTANT NUMBER := 56;
G_GLOBAL_ATTRIBUTE12           CONSTANT NUMBER := 57;
G_GLOBAL_ATTRIBUTE13           CONSTANT NUMBER := 58;
G_GLOBAL_ATTRIBUTE14           CONSTANT NUMBER := 59;
G_GLOBAL_ATTRIBUTE15           CONSTANT NUMBER := 60;
G_GLOBAL_ATTRIBUTE16           CONSTANT NUMBER := 61;
G_GLOBAL_ATTRIBUTE17           CONSTANT NUMBER := 62;
G_GLOBAL_ATTRIBUTE18           CONSTANT NUMBER := 63;
G_GLOBAL_ATTRIBUTE19           CONSTANT NUMBER := 64;
G_GLOBAL_ATTRIBUTE2            CONSTANT NUMBER := 65;
G_GLOBAL_ATTRIBUTE20           CONSTANT NUMBER := 66;
G_GLOBAL_ATTRIBUTE3            CONSTANT NUMBER := 67;
G_GLOBAL_ATTRIBUTE4            CONSTANT NUMBER := 68;
G_GLOBAL_ATTRIBUTE5            CONSTANT NUMBER := 69;
G_GLOBAL_ATTRIBUTE6            CONSTANT NUMBER := 70;
G_GLOBAL_ATTRIBUTE7            CONSTANT NUMBER := 71;
G_GLOBAL_ATTRIBUTE8            CONSTANT NUMBER := 72;
G_GLOBAL_ATTRIBUTE9            CONSTANT NUMBER := 73;
G_GLOBAL_ATTRIBUTE_CATEGORY    CONSTANT NUMBER := 74;
G_HEADER                       CONSTANT NUMBER := 75;
G_INDUSTRY_ATTRIBUTE1          CONSTANT NUMBER := 76;
G_INDUSTRY_ATTRIBUTE10         CONSTANT NUMBER := 77;
G_INDUSTRY_ATTRIBUTE11         CONSTANT NUMBER := 78;
G_INDUSTRY_ATTRIBUTE12         CONSTANT NUMBER := 79;
G_INDUSTRY_ATTRIBUTE13         CONSTANT NUMBER := 80;
G_INDUSTRY_ATTRIBUTE14         CONSTANT NUMBER := 81;
G_INDUSTRY_ATTRIBUTE15         CONSTANT NUMBER := 82;
G_INDUSTRY_ATTRIBUTE2          CONSTANT NUMBER := 83;
G_INDUSTRY_ATTRIBUTE3          CONSTANT NUMBER := 84;
G_INDUSTRY_ATTRIBUTE4          CONSTANT NUMBER := 85;
G_INDUSTRY_ATTRIBUTE5          CONSTANT NUMBER := 86;
G_INDUSTRY_ATTRIBUTE6          CONSTANT NUMBER := 87;
G_INDUSTRY_ATTRIBUTE7          CONSTANT NUMBER := 88;
G_INDUSTRY_ATTRIBUTE8          CONSTANT NUMBER := 89;
G_INDUSTRY_ATTRIBUTE9          CONSTANT NUMBER := 90;
G_INDUSTRY_CONTEXT             CONSTANT NUMBER := 91;
G_INTERMED_SHIP_TO_CONTACT     CONSTANT NUMBER := 92;
G_INTERMED_SHIP_TO_ORG         CONSTANT NUMBER := 93;
G_INVENTORY_ITEM               CONSTANT NUMBER := 94;
G_INVOICE_INTERFACE_STATUS     CONSTANT NUMBER := 95;
G_INVOICE_TO_CONTACT           CONSTANT NUMBER := 100;
G_INVOICE_TO_ORG               CONSTANT NUMBER := 101;
G_INVOICING_RULE               CONSTANT NUMBER := 102;
G_ORDERED_ITEM                   CONSTANT NUMBER := 103;
G_ITEM_REVISION                CONSTANT NUMBER := 104;
G_ITEM_TYPE                    CONSTANT NUMBER := 105;
G_LAST_UPDATED_BY              CONSTANT NUMBER := 106;
G_LAST_UPDATE_DATE             CONSTANT NUMBER := 107;
G_LAST_UPDATE_LOGIN            CONSTANT NUMBER := 108;
G_LATEST_ACCEPTABLE_DATE       CONSTANT NUMBER := 109;
G_LINE                         CONSTANT NUMBER := 110;
G_LINE_CATEGORY                CONSTANT NUMBER := 111;
G_LINE_NUMBER                  CONSTANT NUMBER := 112;
G_LINE_TYPE                    CONSTANT NUMBER := 113;
G_LINK_TO_LINE                 CONSTANT NUMBER := 114;
G_MODEL_GROUP_NUMBER           CONSTANT NUMBER := 118;
G_OPTION_FLAG                  CONSTANT NUMBER := 119;
G_OPTION_NUMBER                CONSTANT NUMBER := 120;
G_ORDERED_QUANTITY             CONSTANT NUMBER := 121;
G_ORDER_QUANTITY_UOM           CONSTANT NUMBER := 122;
G_ORG                          CONSTANT NUMBER := 123;
G_ORIG_SYS_DOCUMENT_REF        CONSTANT NUMBER := 124;
G_ORIG_SYS_LINE_REF            CONSTANT NUMBER := 125;
G_PAYMENT_TERM                 CONSTANT NUMBER := 128;
G_PRICE_LIST                   CONSTANT NUMBER := 131;
G_PRICING_ATTRIBUTE1           CONSTANT NUMBER := 132;
G_PRICING_ATTRIBUTE10          CONSTANT NUMBER := 133;
G_PRICING_ATTRIBUTE2           CONSTANT NUMBER := 134;
G_PRICING_ATTRIBUTE3           CONSTANT NUMBER := 135;
G_PRICING_ATTRIBUTE4           CONSTANT NUMBER := 136;
G_PRICING_ATTRIBUTE5           CONSTANT NUMBER := 137;
G_PRICING_ATTRIBUTE6           CONSTANT NUMBER := 138;
G_PRICING_ATTRIBUTE7           CONSTANT NUMBER := 139;
G_PRICING_ATTRIBUTE8           CONSTANT NUMBER := 140;
G_PRICING_ATTRIBUTE9           CONSTANT NUMBER := 141;
G_PRICING_CONTEXT              CONSTANT NUMBER := 142;
G_PRICING_DATE                 CONSTANT NUMBER := 143;
G_PRICING_QUANTITY             CONSTANT NUMBER := 144;
G_PRICING_QUANTITY_UOM         CONSTANT NUMBER := 145;
G_PROGRAM                      CONSTANT NUMBER := 146;
G_PROGRAM_APPLICATION          CONSTANT NUMBER := 147;
G_PROGRAM_UPDATE_DATE          CONSTANT NUMBER := 148;
G_PROJECT                      CONSTANT NUMBER := 149;
G_PROMISE_DATE                 CONSTANT NUMBER := 150;
G_REFERENCE_HEADER             CONSTANT NUMBER := 151;
G_REFERENCE_LINE               CONSTANT NUMBER := 152;
G_REFERENCE_TYPE               CONSTANT NUMBER := 153;
G_REQUEST                      CONSTANT NUMBER := 155;
G_REQUEST_DATE                 CONSTANT NUMBER := 156;
G_RESERVED_QUANTITY            CONSTANT NUMBER := 157;
G_RETURN_ATTRIBUTE1            CONSTANT NUMBER := 159;
G_RETURN_ATTRIBUTE10           CONSTANT NUMBER := 160;
G_RETURN_ATTRIBUTE11           CONSTANT NUMBER := 161;
G_RETURN_ATTRIBUTE12           CONSTANT NUMBER := 162;
G_RETURN_ATTRIBUTE13           CONSTANT NUMBER := 163;
G_RETURN_ATTRIBUTE14           CONSTANT NUMBER := 164;
G_RETURN_ATTRIBUTE15           CONSTANT NUMBER := 165;
G_RETURN_ATTRIBUTE2            CONSTANT NUMBER := 166;
G_RETURN_ATTRIBUTE3            CONSTANT NUMBER := 167;
G_RETURN_ATTRIBUTE4            CONSTANT NUMBER := 168;
G_RETURN_ATTRIBUTE5            CONSTANT NUMBER := 169;
G_RETURN_ATTRIBUTE6            CONSTANT NUMBER := 170;
G_RETURN_ATTRIBUTE7            CONSTANT NUMBER := 171;
G_RETURN_ATTRIBUTE8            CONSTANT NUMBER := 172;
G_RETURN_ATTRIBUTE9            CONSTANT NUMBER := 173;
G_RETURN_CONTEXT               CONSTANT NUMBER := 174;
G_RLA_SCHEDULE_TYPE            CONSTANT NUMBER := 176;
G_SCHEDULE_ACTION              CONSTANT NUMBER := 177;
G_SCHEDULE_ARRIVAL_DATE        CONSTANT NUMBER := 178;
G_SCHEDULE_SHIP_DATE           CONSTANT NUMBER := 179;
G_SCHEDULE_STATUS              CONSTANT NUMBER := 180;
G_SHIPMENT_NUMBER              CONSTANT NUMBER := 181;
G_SHIPMENT_PRIORITY            CONSTANT NUMBER := 182;
G_SHIPPED_QUANTITY             CONSTANT NUMBER := 183;
G_SHIPPING_METHOD              CONSTANT NUMBER := 184;
G_SHIPPING_QUANTITY            CONSTANT NUMBER := 185;
G_SHIPPING_QUANTITY_UOM        CONSTANT NUMBER := 186;
G_SHIP_FROM_ORG                CONSTANT NUMBER := 187;
G_SHIP_MODEL_COMPLETE_FLAG     CONSTANT NUMBER := 188;
G_SHIP_TOLERANCE_ABOVE         CONSTANT NUMBER := 189;
G_SHIP_TOLERANCE_BELOW         CONSTANT NUMBER := 190;
G_SHIP_TO_CONTACT              CONSTANT NUMBER := 191;
G_SHIP_TO_ORG                  CONSTANT NUMBER := 192;
G_SOLD_TO_ORG                  CONSTANT NUMBER := 194;
G_SORT_ORDER                   CONSTANT NUMBER := 195;
G_SOURCE_DOCUMENT              CONSTANT NUMBER := 196;
G_SOURCE_DOCUMENT_LINE         CONSTANT NUMBER := 197;
G_SOURCE_DOCUMENT_TYPE         CONSTANT NUMBER := 198;
G_SOURCE_TYPE                  CONSTANT NUMBER := 199;
G_TASK                         CONSTANT NUMBER := 201;
G_TAX                          CONSTANT NUMBER := 202;
G_TAX_DATE                     CONSTANT NUMBER := 203;
G_TAX_EXEMPT                   CONSTANT NUMBER := 204;
G_TAX_EXEMPT_NUMBER            CONSTANT NUMBER := 205;
G_TAX_EXEMPT_REASON            CONSTANT NUMBER := 206;
G_TAX_POINT                    CONSTANT NUMBER := 207;
G_TAX_RATE                     CONSTANT NUMBER := 208;
G_TAX_VALUE                    CONSTANT NUMBER := 209;
G_UNIT_LIST_PRICE              CONSTANT NUMBER := 210;
G_UNIT_SELLING_PRICE           CONSTANT NUMBER := 211;
G_VISIBLE_DEMAND               CONSTANT NUMBER := 212;
G_SPLIT_FROM_LINE              CONSTANT NUMBER := 213;
G_CUST_PRODUCTION_SEQ_NUM      CONSTANT NUMBER := 214;
G_VEH_CUS_ITEM_CUM_KEY         CONSTANT NUMBER := 215;
G_INDUSTRY_ATTRIBUTE16          CONSTANT NUMBER := 216;
G_INDUSTRY_ATTRIBUTE17         CONSTANT NUMBER := 217;
G_INDUSTRY_ATTRIBUTE18         CONSTANT NUMBER := 218;
G_INDUSTRY_ATTRIBUTE19         CONSTANT NUMBER := 219;
G_INDUSTRY_ATTRIBUTE20         CONSTANT NUMBER := 220;
G_INDUSTRY_ATTRIBUTE21         CONSTANT NUMBER := 221;
G_INDUSTRY_ATTRIBUTE22         CONSTANT NUMBER := 222;
G_INDUSTRY_ATTRIBUTE23          CONSTANT NUMBER := 223;
G_INDUSTRY_ATTRIBUTE24          CONSTANT NUMBER := 224;
G_INDUSTRY_ATTRIBUTE25         CONSTANT NUMBER := 225;
G_INDUSTRY_ATTRIBUTE26         CONSTANT NUMBER := 226;
G_INDUSTRY_ATTRIBUTE27         CONSTANT NUMBER := 227;
G_INDUSTRY_ATTRIBUTE28         CONSTANT NUMBER := 228;
G_INDUSTRY_ATTRIBUTE29         CONSTANT NUMBER := 229;
G_INDUSTRY_ATTRIBUTE30         CONSTANT NUMBER := 230;
G_SALESREP                     CONSTANT NUMBER := 231;
G_RETURN_REASON                CONSTANT NUMBER := 232;
G_ARRIVAL_SET                  CONSTANT NUMBER := 233;
G_SHIP_SET                     CONSTANT NUMBER := 234;
G_OVER_SHIP_REASON             CONSTANT NUMBER := 235;
G_OVER_SHIP_RESOLVED           CONSTANT NUMBER := 236;
G_AUTHORIZED_TO_SHIP           CONSTANT NUMBER := 237;
G_ARRIVAL_SET_NAME             CONSTANT NUMBER := 238;
G_SHIP_SET_NAME                CONSTANT NUMBER := 239;
G_ORDER_SOURCE_ID              CONSTANT NUMBER := 240;
G_ORIG_SYS_SHIPMENT_REF        CONSTANT NUMBER := 241;
G_CHANGE_SEQUENCE_ID           CONSTANT NUMBER := 242;
G_DROP_SHIP_FLAG               CONSTANT NUMBER := 243;
G_CUSTOMER_LINE_NUMBER         CONSTANT NUMBER := 244;
G_CUSTOMER_SHIPMENT_NUMBER     CONSTANT NUMBER := 245;
G_CUSTOMER_ITEM_NET_PRICE      CONSTANT NUMBER := 246;
G_CUSTOMER_PAYMENT_TERM_ID     CONSTANT NUMBER := 247;
G_CUSTOMER_PAYMENT_TERM        CONSTANT NUMBER := 248;
G_BOOKED                       CONSTANT NUMBER := 249;
G_CANCELLED                    CONSTANT NUMBER := 250;
G_OPEN                         CONSTANT NUMBER := 251;
G_ORDERED_ITEM_ID              CONSTANT NUMBER := 252;
G_ITEM_IDENTIFIER_TYPE         CONSTANT NUMBER := 253;
G_TOP_MODEL_LINE               CONSTANT NUMBER := 254;
G_SHIPPING_INTERFACED          CONSTANT NUMBER := 255;
G_FIRST_ACK                    CONSTANT NUMBER := 256;
G_FIRST_ACK_DATE               CONSTANT NUMBER := 257;
G_LAST_ACK                     CONSTANT NUMBER := 258;
G_LAST_ACK_DATE                CONSTANT NUMBER := 259;
G_CREDIT_INVOICE_LINE          CONSTANT NUMBER := 260;
G_SOLD_FROM_ORG                CONSTANT NUMBER := 261;
G_END_ITEM_UNIT_NUMBER		 CONSTANT NUMBER := 262;
G_CONFIG_HEADER         		 CONSTANT NUMBER := 263;
G_CONFIG_REV_NBR               CONSTANT NUMBER := 264;
G_MFG_COMPONENT_SEQUENCE		 CONSTANT NUMBER := 265;
G_PLANNING_PRIORITY     		 CONSTANT NUMBER := 266;
G_SHIPPING_INSTRUCTIONS 		 CONSTANT NUMBER := 267;
G_PACKING_INSTRUCTIONS 		 CONSTANT NUMBER := 268;
G_INVOICED_QUANTITY            CONSTANT NUMBER := 269;
G_REFERENCE_CUSTOMER_TRX_LINE  CONSTANT NUMBER := 270;
G_SERVICE_TXN_REASON           CONSTANT NUMBER := 271;
G_SERVICE_TXN_COMMENTS         CONSTANT NUMBER := 272;
G_SERVICE_DURATION             CONSTANT NUMBER := 273;
G_SERVICE_START_DATE           CONSTANT NUMBER := 274;
G_SERVICE_END_DATE             CONSTANT NUMBER := 275;
G_SERVICE_COTERMINATE_FLAG     CONSTANT NUMBER := 276;
G_UNIT_LIST_PERCENT            CONSTANT NUMBER := 277;
G_UNIT_SELLING_PERCENT         CONSTANT NUMBER := 278;
G_UNIT_PERCENT_BASE_PRICE      CONSTANT NUMBER := 279;
G_SERVICE_NUMBER               CONSTANT NUMBER := 280;
G_SERVICE_REFERENCE_TYPE_CODE  CONSTANT NUMBER := 281;
G_SERVICE_REFERENCE_LINE_ID    CONSTANT NUMBER := 282;
G_SERVICE_REFERENCE_SYSTEM_ID  CONSTANT NUMBER := 283;
-- there is gap because service_attribute are deleted (use it)
G_LINE_SET		           CONSTANT NUMBER := 298;
G_SPLIT_BY	                CONSTANT NUMBER := 299;
G_SHIPPABLE                    CONSTANT NUMBER := 300;
G_SERVICE_PERIOD               CONSTANT NUMBER := 301;
G_RE_SOURCE_FLAG               CONSTANT NUMBER := 302;
G_MODEL_REMNANT                 CONSTANT NUMBER := 303;
G_CHANGE_REASON                CONSTANT  NUMBER := 304;
G_CHANGE_COMMENTS              CONSTANT  NUMBER := 305;
G_TP_CONTEXT                   CONSTANT   NUMBER :=306;
G_TP_ATTRIBUTE1                 CONSTANT NUMBER :=307;
G_TP_ATTRIBUTE2                 CONSTANT NUMBER :=308;
G_TP_ATTRIBUTE3                 CONSTANT NUMBER :=309;
G_TP_ATTRIBUTE4                 CONSTANT NUMBER :=310;
G_TP_ATTRIBUTE5                 CONSTANT NUMBER :=311;
G_TP_ATTRIBUTE6                 CONSTANT NUMBER :=312;
G_TP_ATTRIBUTE7                 CONSTANT NUMBER :=313;
G_TP_ATTRIBUTE8                 CONSTANT NUMBER :=314;
G_TP_ATTRIBUTE9                 CONSTANT NUMBER :=315;
G_TP_ATTRIBUTE10                CONSTANT NUMBER :=316;
G_TP_ATTRIBUTE11                CONSTANT NUMBER :=317;
G_TP_ATTRIBUTE12                CONSTANT NUMBER :=318;
G_TP_ATTRIBUTE13                CONSTANT NUMBER :=319;
G_TP_ATTRIBUTE14                CONSTANT NUMBER :=320;
G_TP_ATTRIBUTE15                CONSTANT NUMBER :=321;
G_FLOW_STATUS				  CONSTANT NUMBER := 322;
G_FULFILLED				  CONSTANT NUMBER := 323;
G_FULFILLMENT_METHOD		  CONSTANT NUMBER := 324;
G_FULFILLMENT_SET		       CONSTANT NUMBER := 325;
G_FULFILLMENT_SET_NAME	       CONSTANT NUMBER := 326;
G_MARKETING_SOURCE_CODE_ID      CONSTANT NUMBER := 327;
G_FULFILLMENT_DATE			  CONSTANT NUMBER := 328;
-- Added New Column
G_CALCULATE_PRICE_FLAG		  CONSTANT NUMBER := 329;
G_INVOICED_FLAG		  CONSTANT NUMBER := 330;
G_COMMITMENT                    CONSTANT  NUMBER := 331;

-- OPM columns
G_ORDERED_QUANTITY2             CONSTANT NUMBER := 332;
G_ORDERED_QUANTITY_UOM2         CONSTANT NUMBER := 333;
G_PREFERRED_GRADE               CONSTANT NUMBER := 334;
G_CANCELLED_QUANTITY2           CONSTANT NUMBER := 335;
G_FULFILLED_QUANTITY2           CONSTANT NUMBER := 336;
G_SHIPPED_QUANTITY2             CONSTANT NUMBER := 337;
G_SHIPPING_QUANTITY2            CONSTANT NUMBER := 338;
G_SHIPPING_QUANTITY_UOM2        CONSTANT NUMBER := 339;
G_UPGRADED                      CONSTANT NUMBER := 340;
G_SUBINVENTORY                  CONSTANT NUMBER := 341;
G_UNIT_LIST_PRICE_PER_PQTY              CONSTANT NUMBER := 342;
G_UNIT_SELLING_PRICE_PER_PQTY           CONSTANT NUMBER := 343;
G_PRICE_REQUEST_CODE            CONSTANT NUMBER := 344; -- PROMOTIONS SEP/01
-- Item Substitution columns.
G_ORIGINAL_INVENTORY_ITEM       CONSTANT NUMBER := 345;
G_ORIGINAL_ITEM_IDEN_TYPE       CONSTANT NUMBER := 346;
G_ORIGINAL_ORDERED_ITEM_ID      CONSTANT NUMBER := 347;
G_ORIGINAL_ORDERED_ITEM         CONSTANT NUMBER := 348;
G_ITEM_SUBSTITUTION_TYPE        CONSTANT NUMBER := 349;
G_DEMAND_LATENESS_PENALTY       CONSTANT NUMBER := 350;
G_OVERRIDE_ATP_DATE             CONSTANT NUMBER := 351;

G_ACCOUNTING_RULE_DURATION      CONSTANT NUMBER := 352;
G_LATE_DEMAND_PENALTY_FACTOR    CONSTANT NUMBER := 353;
G_UNIT_COST                     CONSTANT NUMBER := 354;
G_USER_ITEM_DESCRIPTION         CONSTANT NUMBER := 355;
-- ER 2184255 additional DFF columns
G_ATTRIBUTE16                  CONSTANT NUMBER := 356;
G_ATTRIBUTE17                  CONSTANT NUMBER := 357;
G_ATTRIBUTE18                  CONSTANT NUMBER := 358;
G_ATTRIBUTE19                  CONSTANT NUMBER := 359;
G_ATTRIBUTE20                  CONSTANT NUMBER := 360;
G_ITEM_RELATIONSHIP_TYPE       CONSTANT NUMBER := 361;
-- Changes for Blanket Orders
G_BLANKET_NUMBER               CONSTANT NUMBER := 362;
G_BLANKET_LINE_NUMBER          CONSTANT NUMBER := 363;
G_BLANKET_VERSION_NUMBER       CONSTANT NUMBER := 364;
G_FIRM_DEMAND                  CONSTANT NUMBER := 365;
G_EARLIEST_SHIP_DATE           CONSTANT NUMBER := 366;
-- Changes for quoting
g_transaction_phase            CONSTANT NUMBER := 367;
g_source_document_version      CONSTANT NUMBER := 368;
G_MINISITE_ID                  CONSTANT NUMBER := 369;
G_IB_OWNER                     CONSTANT NUMBER := 370;
G_IB_INSTALLED_AT_LOCATION     CONSTANT NUMBER := 371;
G_IB_CURRENT_LOCATION          CONSTANT NUMBER := 372;
G_END_CUSTOMER                 CONSTANT NUMBER := 373;
G_END_CUSTOMER_CONTACT         CONSTANT NUMBER := 374;
G_END_CUSTOMER_SITE_USE         CONSTANT NUMBER := 375;
/*G_SUPPLIER_SIGNATURE           CONSTANT NUMBER := 376;
G_SUPPLIER_SIGNATURE_DATE      CONSTANT NUMBER := 377;
G_CUSTOMER_SIGNATURE           CONSTANT NUMBER := 378;
G_CUSTOMER_SIGNATURE_DATE      CONSTANT NUMBER := 379;
*/
--retro{
G_RETROBILL_REQUEST            CONSTANT NUMBER := 376;
--retro}
G_ORIGINAL_LIST_PRICE          CONSTANT NUMBER := 377;   -- Override List Price
G_COMMITMENT_APPLIED_AMOUNT   CONSTANT NUMBER := 378;
-- key Transaction Dates
g_order_firmed_date            CONSTANT NUMBER := 379;
g_actual_fulfillment_date      CONSTANT NUMBER := 380;
--recurring charges
G_CHARGE_PERIODICITY           CONSTANT NUMBER := 381;
G_RESERVED_QUANTITY2 					 CONSTANT NUMBER := 382; -- INVCONV
--Customer Acceptance
G_CONTINGENCY                  CONSTANT NUMBER := 383;
G_REVREC_EVENT                 CONSTANT NUMBER := 384;
G_REVREC_EXPIRATION_DAYS       CONSTANT NUMBER := 385;
G_REVREC_SIGNATURE             CONSTANT NUMBER := 386;
G_REVREC_SIGNATURE_DATE        CONSTANT NUMBER := 387;
G_REVREC_COMMENTS              CONSTANT NUMBER := 388;
G_REVREC_REFERENCE_DOCUMENT    CONSTANT NUMBER := 389;
G_ACCEPTED_BY                  CONSTANT NUMBER := 390;
G_ACCEPTED_QUANTITY            CONSTANT NUMBER := 391;
G_REVREC_IMPLICIT_FLAG         CONSTANT NUMBER := 392;

G_MAX_ATTR_ID                  CONSTANT NUMBER := 393;


/* Fix for bug 2431953/2749740
G_ORDERED_QTY_CHANGE            BOOLEAN:= FALSE;
Fix ends */

/* Bug # 5036404 Start */
-- retreive the profile value
G_FREEZE_METHOD               VARCHAR2(30) := FND_PROFILE.VALUE('ONT_INCLUDED_ITEM_FREEZE_METHOD');
G_CHARGES_FOR_BACKORDERS      VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('ONT_CHARGES_FOR_BACKORDERS'),'N');
G_CHARGES_FOR_INCLUD_ITM   VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('ONT_CHARGES_FOR_INCLUDED_ITEM'),'N');
/* Bug # 5036404 End */
G_APPLY_AUTOMATIC_ATCHMT      VARCHAR2(1) := NVL(FND_PROFILE.VALUE('OE_APPLY_AUTOMATIC_ATCHMT'),'Y') ; --5893276
/* Temporarily moves to OEXULXTS.pls (OE_Line_Util_Ext)
--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
,   x_line_rec                      OUT OE_Order_PUB.Line_Rec_Type
);
*/

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
);

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
) ;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
) ;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_line_rec                      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_line_rec                      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
);

-- FUNCTION Query_Row
-- IMPORTANT: DO NOT CHANGE THE SPEC OF THIS FUNCTION
-- IT IS PUBLIC AND BEING CALLED BY OTHER PRODUCTS
-- Private OM callers should call the procedure query_row instead
-- as it has the nocopy option which would improve the performance

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER
) RETURN OE_Order_PUB.Line_Rec_Type;

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_line_id                       IN  NUMBER
,   x_line_rec                      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
);

--  Procedure Query_Rows

--

PROCEDURE Query_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_set_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
);

--  Procedure       lock_Row
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_line_id			           IN NUMBER
					              := FND_API.G_MISS_NUM
);

PROCEDURE Lock_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_tbl                      OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

--  Function Get_Values

FUNCTION Get_Values
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
) RETURN OE_Order_PUB.Line_Val_Rec_Type;


--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_line_val_rec                  IN  OE_Order_PUB.Line_Val_Rec_Type
) ;

Procedure Query_Header
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_header_id                     OUT NOCOPY /* file.sql.39 change */ NUMBER
);

-- INVCONV FOR SAO
PROCEDURE get_reserved_quantities
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER DEFAULT NULL
 ,p_order_quantity_uom              IN VARCHAR2 DEFAULT NULL  --added for 3745318
 ,p_inventory_item_id		    				IN NUMBER DEFAULT NULL    --added for 3745318
 ,x_reserved_quantity               OUT NOCOPY NUMBER
 ,x_reserved_quantity2              OUT NOCOPY NUMBER );

FUNCTION Get_Reserved_Quantity
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER DEFAULT NULL
 ,p_order_quantity_uom              IN VARCHAR2 DEFAULT NULL  --added for 3745318
 ,p_inventory_item_id		    IN NUMBER DEFAULT NULL    --added for 3745318
)RETURN NUMBER;


-- INVCONV Get_Reserved_Quantity2 merged into get_reserved_quantities not used by Process Manufacturing now but left in for
-- forward compatibility and in case other modules are using this.

FUNCTION Get_Reserved_Quantity2
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER DEFAULT NULL
)RETURN NUMBER;


FUNCTION Get_Open_Quantity(p_header_id        IN NUMBER,
			   p_line_id          IN NUMBER,
                           p_ordered_quantity IN NUMBER,
			  p_shipped_quantity IN NUMBER)
RETURN NUMBER;

FUNCTION Get_Primary_Uom_Quantity(p_ordered_quantity   IN NUMBER,
						    p_order_quantity_uom IN VARCHAR2)
RETURN NUMBER;


FUNCTION Is_Over_Return(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN;

PROCEDURE Pre_Write_Process
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
);

PROCEDURE Version_Audit_Process
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
,   p_process_step                  IN NUMBER := 3
);

PROCEDURE Post_Write_Process
(   p_x_line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
);

PROCEDURE Post_Line_Process
(  p_control_rec                   IN   OE_Globals.Control_Rec_Type
,  p_x_line_tbl				IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
);

Function Get_Return_Item_Type_Code
(   p_line_rec                      IN OE_Order_PUB.Line_Rec_Type
) RETURN varchar2;

-- OPM 02/JUN/00
-- =============
/*FUNCTION process_characteristics  -- INVCONV OBSOLETE  NEED TO TAKE OUT
(
  p_inventory_item_id IN NUMBER
 ,p_ship_from_org_id  IN NUMBER
 ,x_item_rec          OUT NOCOPY OE_ORDER_CACHE.item_rec_type
)
RETURN BOOLEAN;    */

FUNCTION dual_uom_control -- INVCONV
(
  p_inventory_item_id IN NUMBER
 ,p_ship_from_org_id  IN NUMBER
 ,x_item_rec          OUT NOCOPY OE_ORDER_CACHE.item_rec_type
)
RETURN BOOLEAN;


 /* FUNCTION Get_Dual_Uom -- INVCONV
(
  p_line_rec          OE_ORDER_PUB.Line_Rec_Type
)
RETURN VARCHAR2; */

/* FUNCTION Get_Preferred_Grade -- INVCONV
(
  p_line_rec OE_ORDER_PUB.Line_Rec_Type,
  p_old_line_rec OE_ORDER_PUB.Line_Rec_Type
)
RETURN VARCHAR2; */

PROCEDURE Sync_Dual_Qty
(
   P_X_LINE_REC        IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
  ,P_OLD_LINE_REC      IN OE_ORDER_PUB.Line_Rec_Type
);

/* FUNCTION Calculate_Ordered_Quantity2 INVCONV removed
(
   P_LINE_REC          OE_ORDER_PUB.Line_Rec_Type
)
RETURN NUMBER; */
-- OPM 02/JUN/00 END
-- =================

/* OPM - NC 3/8/02 Bug#2046641 */
PROCEDURE calculate_dual_quantity
(
   p_ordered_quantity       IN OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_old_ordered_quantity   IN NUMBER
  ,p_ordered_quantity2      IN OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_old_ordered_quantity2  IN NUMBER
  ,p_ordered_quantity_uom   IN VARCHAR2
  ,p_ordered_quantity_uom2  IN VARCHAR2
  ,p_inventory_item_id      IN NUMBER
  ,p_ship_from_org_id       IN NUMBER
  ,x_ui_flag		    IN NUMBER
  ,x_return_status 	    OUT NOCOPY /* file.sql.39 change */ NUMBER
--  ,p_lot_id                 IN  NUMBER DEFAULT 0 -- OPM 2380194 added for RMA quantity2 OM pack J project
  ,p_lot_number             IN  VARCHAR2 DEFAULT NULL -- INVCONV  orig for 2380194 added for RMA quantity2 OM pack J project
) ;

Procedure Pre_Attribute_Security
(   p_x_line_rec                IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   p_old_line_rec                 IN         OE_ORDER_PUB.Line_Rec_Type
,   p_index                        IN         NUMBER);

PROCEDURE Log_Scheduling_Requests
(p_x_line_rec    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type
,p_caller        IN  VARCHAR2
,p_order_type_id IN  NUMBER
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);





PROCEDURE  update_adjustment_flags
  ( p_old_line_rec IN OE_Order_PUB.line_rec_type,
    p_x_line_rec IN OE_Order_PUB.line_rec_type);


PROCEDURE GET_ITEM_INFO
(   x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   x_ordered_item          OUT NOCOPY VARCHAR2
,   x_ordered_item_desc     OUT NOCOPY VARCHAR2
,   x_inventory_item        OUT NOCOPY VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
);

--ER7675548
Procedure Get_customer_info_ids
( p_line_customer_info_tbl IN OUT NOCOPY OE_Order_Pub.CUSTOMER_INFO_TABLE_TYPE,
  p_x_line_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data    OUT NOCOPY VARCHAR2
);

--7688372 start
   TYPE attachrule_count_line_tab IS  TABLE OF NUMBER INDEX by oe_attachment_rule_elements.ATTRIBUTE_CODE%TYPE;
   g_attachrule_count_line_tab  attachrule_count_line_tab;
--7688372 end


END OE_Line_Util;

/
