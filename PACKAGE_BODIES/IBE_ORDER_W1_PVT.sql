--------------------------------------------------------
--  DDL for Package Body IBE_ORDER_W1_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ORDER_W1_PVT" AS
/* $Header: IBEVOW1B.pls 120.0.12010000.2 2009/06/26 10:01:00 scnagara ship $ */

l_true VARCHAR2(1)                := FND_API.G_TRUE;


ROSETTA_G_MISS_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM         NUMBER := 0-1962.0724;

PROCEDURE Construct_Ctrl_Rec(
  p_submit_flag         IN  VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_cancel_flag         IN  VARCHAR2
 ,p_chkconstraint_flag  IN  VARCHAR2
 ,x_control_rec         OUT NOCOPY Control_Rec_Type
 )
 IS
-- l_control_rec Control_Rec_Type  := G_MISS_Control_Rec;

 BEGIN
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct controlrec package body - Begin');
 END IF;

  x_control_rec.SUBMIT_FLAG          := p_submit_flag;
  x_control_rec.CANCEL_FLAG        := p_cancel_flag;
  x_control_rec.CHKCONSTRAINT_FLAG := p_chkconstraint_flag;


 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct controlrec package body - End');
 END IF;

 END Construct_Ctrl_Rec;


Function Construct_Line_Tbl(
 p_LINE_ID                    IN     jtf_number_table          := NULL
 ,p_OPERATION                 IN     jtf_varchar2_table_100    := NULL
 ,p_ORG_ID                    IN     jtf_number_table          := NULL
 ,p_HEADER_ID                 IN     jtf_number_table          := NULL
 ,p_LINE_TYPE_ID              IN     jtf_number_table          := NULL
 ,p_LINE_NUMBER               IN     jtf_number_table          := NULL
 ,p_ORDERED_ITEM              IN     jtf_varchar2_table_300    := NULL
 ,p_REQUEST_DATE              IN     jtf_date_table            := NULL
 ,p_PROMISE_DATE              IN     jtf_date_table            := NULL
 ,p_SCHEDULE_SHIP_DATE        IN     jtf_date_table            := NULL
 ,p_ORDER_QUANTITY_UOM        IN     jtf_varchar2_table_100    := NULL
 ,p_PRICING_QUANTITY          IN     jtf_number_table          := NULL
 ,p_PRICING_QUANTITY_UOM      IN     jtf_varchar2_table_300    := NULL
 ,p_CANCELLED_QUANTITY        IN     jtf_number_table          := NULL
 ,p_SHIPPED_QUANTITY          IN     jtf_number_table          := NULL
 ,p_ORDERED_QUANTITY          IN     jtf_number_table          := NULL
 ,p_FULFILLED_QUANTITY        IN     jtf_number_table          := NULL
 ,p_SHIPPING_QUANTITY         IN     jtf_number_table          := NULL
 ,p_SHIPPING_QUANTITY_UOM     IN     jtf_varchar2_table_100    := NULL
 ,p_DELIVERY_LEAD_TIME        IN     jtf_number_table          := NULL
 ,p_TAX_EXEMPT_FLAG           IN     jtf_varchar2_table_100    := NULL
 ,p_TAX_EXEMPT_NUMBER         IN     jtf_varchar2_table_100    := NULL
 ,p_TAX_EXEMPT_REASON_CODE    IN     jtf_varchar2_table_100    := NULL
 ,p_SHIP_FROM_ORG_ID          IN     jtf_number_table          := NULL
 ,p_SHIP_TO_ORG_ID            IN     jtf_number_table          := NULL
 ,p_INVOICE_TO_ORG_ID         IN     jtf_number_table          := NULL
 ,p_DELIVER_TO_ORG_ID         IN     jtf_number_table          := NULL
 ,p_SHIP_TO_CONTACT_ID        IN     jtf_number_table          := NULL
 ,p_DELIVER_TO_CONTACT_ID     IN     jtf_number_table          := NULL
 ,p_INVOICE_TO_CONTACT_ID     IN     jtf_number_table          := NULL
 ,p_SOLD_FROM_ORG_ID          IN     jtf_number_table          := NULL
 ,p_SOLD_TO_ORG_ID            IN     jtf_number_table          := NULL
 ,p_CUST_PO_NUMBER            IN     jtf_varchar2_table_100    := NULL
 ,p_SHIP_TOLERANCE_ABOVE          IN     jtf_number_table          := NULL
 ,p_SHIP_TOLERANCE_BELOW          IN     jtf_number_table          := NULL
 ,p_DEMAND_BUCKET_TYPE_CODE       IN     jtf_varchar2_table_100    := NULL
 ,p_VEH_CUS_ITEM_CUM_KEY_ID       IN     jtf_number_table          := NULL
 ,p_RLA_SCHEDULE_TYPE_CODE        IN     jtf_varchar2_table_100    := NULL
 ,p_CUSTOMER_DOCK_CODE            IN     jtf_varchar2_table_100    := NULL
 ,p_CUSTOMER_JOB                  IN     jtf_varchar2_table_100    := NULL
 ,p_CUSTOMER_PRODUCTION_LINE      IN     jtf_varchar2_table_100    := NULL
 ,p_CUST_MODEL_SERIAL_NUMBER      IN     jtf_varchar2_table_100    := NULL
 ,p_PROJECT_ID                    IN     jtf_number_table          := NULL
 ,p_TASK_ID                       IN     jtf_number_table          := NULL
 ,p_INVENTORY_ITEM_ID             IN     jtf_number_table          := NULL
 ,p_TAX_DATE                      IN     jtf_date_table            := NULL
 ,p_TAX_CODE                      IN     jtf_varchar2_table_100    := NULL
 ,p_TAX_RATE                      IN     jtf_number_table          := NULL
 ,p_INVOICE_INTER_STATUS_CODE     IN     jtf_varchar2_table_100    := NULL
 ,p_DEMAND_CLASS_CODE             IN     jtf_varchar2_table_100    := NULL
 ,p_PRICE_LIST_ID                 IN     jtf_number_table          := NULL
 ,p_PRICING_DATE                  IN     jtf_date_table            := NULL
 ,p_SHIPMENT_NUMBER               IN     jtf_number_table           := NULL
 ,p_AGREEMENT_ID                  IN     jtf_number_table           := NULL
 ,p_SHIPMENT_PRIORITY_CODE        IN     jtf_varchar2_table_100     := NULL
 ,p_SHIPPING_METHOD_CODE      IN     jtf_varchar2_table_100         := NULL
 ,p_FREIGHT_CARRIER_CODE      IN     jtf_varchar2_table_100         := NULL
 ,p_FREIGHT_TERMS_CODE        IN     jtf_varchar2_table_100         := NULL
 ,p_FOB_POINT_CODE            IN     jtf_varchar2_table_100         := NULL
 ,p_TAX_POINT_CODE            IN     jtf_varchar2_table_100         := NULL
 ,p_PAYMENT_TERM_ID           IN     jtf_number_table               := NULL
 ,p_INVOICING_RULE_ID         IN     jtf_number_table          := NULL
 ,p_ACCOUNTING_RULE_ID        IN     jtf_number_table          := NULL
 ,p_SOURCE_DOCUMENT_TYPE_ID   IN     jtf_number_table          := NULL
 ,p_ORIG_SYS_DOCUMENT_REF     IN     jtf_varchar2_table_100    := NULL
 ,p_SOURCE_DOCUMENT_ID        IN     jtf_number_table          := NULL
 ,p_ORIG_SYS_LINE_REF         IN     jtf_varchar2_table_100    := NULL
 ,p_SOURCE_DOCUMENT_LINE_ID   IN     jtf_number_table          := NULL
 ,p_REFERENCE_LINE_ID         IN     jtf_number_table          := NULL
 ,p_REFERENCE_TYPE            IN     jtf_varchar2_table_300    := NULL
 ,p_REFERENCE_HEADER_ID       IN     jtf_number_table          := NULL
 ,p_ITEM_REVISION             IN     jtf_varchar2_table_100    := NULL
 ,p_UNIT_SELLING_PRICE        IN     jtf_number_table          := NULL
 ,p_UNIT_LIST_PRICE           IN     jtf_number_table          := NULL
 ,p_TAX_VALUE                 IN     jtf_number_table          := NULL
 ,p_CONTEXT                   IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE1                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE2                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE3                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE4                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE5                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE6                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE7                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE8                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE9                IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE10               IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE11               IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE12               IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE13               IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE14               IN     jtf_varchar2_table_300          := NULL
 ,p_ATTRIBUTE15               IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE_CATEGORY IN     jtf_varchar2_table_100          := NULL
 ,p_GLOBAL_ATTRIBUTE1         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE2         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE3         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE4         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE5         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE6         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE7         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE8         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE9         IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE10        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE11        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE12        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE13        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE14        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE15        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE16        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE17        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE18        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE19        IN     jtf_varchar2_table_300          := NULL
 ,p_GLOBAL_ATTRIBUTE20        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_CONTEXT           IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE1        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE2        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE3        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE4        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE5        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE6        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE7        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE8        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE9        IN     jtf_varchar2_table_300          := NULL
 ,p_PRICING_ATTRIBUTE10       IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_CONTEXT          IN     jtf_varchar2_table_100          := NULL
 ,p_INDUSTRY_ATTRIBUTE1         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE2         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE3         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE4         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE5         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE6         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE7         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE8         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE9         IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE10        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE11        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE13        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE12        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE14        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE15        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE16        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE17        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE18        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE19        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE20        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE21        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE22        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE23        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE24        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE25        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE26        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE27        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE28        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE29        IN     jtf_varchar2_table_300          := NULL
 ,p_INDUSTRY_ATTRIBUTE30        IN     jtf_varchar2_table_300          := NULL
 ,p_CREATION_DATE               IN     jtf_date_table            := NULL
 ,p_CREATED_BY                  IN     jtf_number_table          := NULL
 ,p_LAST_UPDATE_DATE            IN     jtf_date_table            := NULL
 ,p_LAST_UPDATED_BY             IN     jtf_number_table          := NULL
 ,p_LAST_UPDATE_LOGIN           IN     jtf_number_table          := NULL
 ,p_PROGRAM_APPLICATION_ID      IN     jtf_number_table          := NULL
 ,p_PROGRAM_ID                  IN     jtf_number_table          := NULL
 ,p_PROGRAM_UPDATE_DATE         IN     jtf_date_table            := NULL
 ,p_REQUEST_ID                  IN     jtf_number_table          := NULL
 ,p_TOP_MODEL_LINE_ID           IN     jtf_number_table          := NULL
 ,p_LINK_TO_LINE_ID             IN     jtf_number_table          := NULL
 ,p_COMPONENT_SEQUENCE_ID       IN     jtf_number_table          := NULL
 ,p_COMPONENT_CODE              IN     jtf_varchar2_table_300    := NULL
 ,p_CONFIG_DISPLAY_SEQUENCE     IN     jtf_number_table          := NULL
 ,p_SORT_ORDER                  IN     jtf_varchar2_table_300    := NULL
 ,p_ITEM_TYPE_CODE              IN     jtf_varchar2_table_100    := NULL
 ,p_OPTION_NUMBER               IN     jtf_number_table          := NULL
 ,p_OPTION_FLAG                 IN     jtf_varchar2_table_100        := NULL
 ,p_DEP_PLAN_REQUIRED_FLAG      IN     jtf_varchar2_table_100        := NULL
 ,p_VISIBLE_DEMAND_FLAG         IN     jtf_varchar2_table_100        := NULL
 ,p_LINE_CATEGORY_CODE          IN     jtf_varchar2_table_100        := NULL
 ,p_ACTUAL_SHIPMENT_DATE        IN     jtf_date_table                := NULL
 ,p_CUSTOMER_TRX_LINE_ID        IN     jtf_number_table              := NULL
 ,p_RETURN_CONTEXT            IN     jtf_varchar2_table_100          := NULL
 ,p_RETURN_ATTRIBUTE1         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE2         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE3         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE4         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE5         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE6         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE7         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE8         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE9         IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE10        IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE11        IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE12        IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE13        IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE14        IN     jtf_varchar2_table_300          := NULL
 ,p_RETURN_ATTRIBUTE15        IN     jtf_varchar2_table_300          := NULL
 ,p_ACTUAL_ARRIVAL_DATE       IN     jtf_date_table                  := NULL
 ,p_ATO_LINE_ID               IN     jtf_number_table                := NULL
 ,p_AUTO_SELECTED_QUANTITY    IN     jtf_number_table                := NULL
 ,p_COMPONENT_NUMBER          IN     jtf_number_table                := NULL
 ,p_EARLIEST_ACCEPTABLE_DATE  IN     jtf_date_table                  := NULL
 ,p_EXPLOSION_DATE            IN     jtf_date_table                  := NULL
 ,p_LATEST_ACCEPTABLE_DATE    IN     jtf_date_table                  := NULL
 ,p_MODEL_GROUP_NUMBER        IN     jtf_number_table                := NULL
 ,p_SCHEDULE_ARRIVAL_DATE     IN     jtf_date_table                  := NULL
 ,p_SHIP_MODEL_COMPLETE_FLAG  IN     jtf_varchar2_table_100          := NULL
 ,p_SCHEDULE_STATUS_CODE      IN     jtf_varchar2_table_100          := NULL
 ,p_SOURCE_TYPE_CODE          IN     jtf_varchar2_table_100          := NULL
 ,p_CANCELLED_FLAG            IN     jtf_varchar2_table_100          := NULL
 ,p_OPEN_FLAG                 IN     jtf_varchar2_table_100          := NULL
 ,p_BOOKED_FLAG               IN     jtf_varchar2_table_100          := NULL
 ,p_SALESREP_ID               IN     jtf_number_table                := NULL
 ,p_RETURN_REASON_CODE        IN     jtf_varchar2_table_100          := NULL
 ,p_ARRIVAL_SET_ID            IN     jtf_number_table                := NULL
 ,p_SHIP_SET_ID               IN     jtf_number_table                := NULL
 ,p_SPLIT_FROM_LINE_ID        IN     jtf_number_table                := NULL
 ,p_CUST_PRODUCTION_SEQ_NUM   IN     jtf_varchar2_table_100          := NULL
 ,p_AUTHORIZED_TO_SHIP_FLAG   IN     jtf_varchar2_table_300          := NULL
 ,p_OVER_SHIP_REASON_CODE     IN     jtf_varchar2_table_100          := NULL
 ,p_OVER_SHIP_RESOLVED_FLAG   IN     jtf_varchar2_table_100          := NULL
 ,p_ORDERED_ITEM_ID           IN     jtf_number_table                := NULL
 ,p_ITEM_IDENTIFIER_TYPE      IN     jtf_varchar2_table_100          := NULL
 ,p_CONFIGURATION_ID          IN     jtf_number_table                := NULL
 ,p_COMMITMENT_ID             IN     jtf_number_table                := NULL
 ,p_SHIPPING_INTERFACED_FLAG  IN     jtf_varchar2_table_100          := NULL
 ,p_CREDIT_INVOICE_LINE_ID    IN     jtf_number_table                := NULL
 ,p_FIRST_ACK_CODE            IN     jtf_varchar2_table_100          := NULL
 ,p_FIRST_ACK_DATE            IN     jtf_date_table                  := NULL
 ,p_LAST_ACK_CODE             IN     jtf_varchar2_table_100          := NULL
 ,p_LAST_ACK_DATE             IN     jtf_date_table                  := NULL
 ,p_PLANNING_PRIORITY         IN     jtf_number_table                := NULL
 ,p_ORDER_SOURCE_ID           IN     jtf_number_table                := NULL
 ,p_ORIG_SYS_SHIPMENT_REF     IN     jtf_varchar2_table_100          := NULL
 ,p_CHANGE_SEQUENCE           IN     jtf_varchar2_table_100          := NULL
 ,p_DROP_SHIP_FLAG            IN     jtf_varchar2_table_100          := NULL
 ,p_CUSTOMER_LINE_NUMBER      IN     jtf_varchar2_table_100          := NULL
 ,p_CUSTOMER_SHIPMENT_NUMBER  IN     jtf_varchar2_table_100          := NULL
 ,p_CUSTOMER_ITEM_NET_PRICE   IN     jtf_number_table                := NULL
 ,p_CUSTOMER_PAYMENT_TERM_ID  IN     jtf_number_table                := NULL
 ,p_FULFILLED_FLAG            IN     jtf_varchar2_table_100          := NULL
 ,p_END_ITEM_UNIT_NUMBER      IN     jtf_varchar2_table_100          := NULL
 ,p_CONFIG_HEADER_ID          IN     jtf_number_table                := NULL
 ,p_CONFIG_REV_NBR            IN     jtf_number_table                := NULL
 ,p_MFG_COMPONENT_SEQUENCE_ID IN     jtf_number_table                := NULL
 ,p_SHIPPING_INSTRUCTIONS     IN     jtf_varchar2_table_300          := NULL
 ,p_PACKING_INSTRUCTIONS      IN     jtf_varchar2_table_300          := NULL
 ,p_INVOICED_QUANTITY         IN     jtf_number_table                := NULL
 ,p_REF_CUSTOMER_TRX_LINE_ID  IN     jtf_number_table                := NULL
 ,p_SPLIT_BY                  IN     jtf_varchar2_table_300          := NULL
 ,p_LINE_SET_ID               IN     jtf_number_table                := NULL
 ,p_SERVICE_TXN_REASON_CODE   IN     jtf_varchar2_table_100          := NULL
 ,p_SERVICE_TXN_COMMENTS      IN     jtf_varchar2_table_300          := NULL
 ,p_SERVICE_DURATION          IN     jtf_number_table                := NULL
 ,p_SERVICE_START_DATE        IN     jtf_date_table                  := NULL
 ,p_SERVICE_END_DATE          IN     jtf_date_table                  := NULL
 ,p_SERVICE_COTERMINATE_FLAG  IN     jtf_varchar2_table_100          := NULL
 ,p_UNIT_LIST_PERCENT         IN     jtf_number_table                := NULL
 ,p_UNIT_SELLING_PERCENT      IN     jtf_number_table                := NULL
 ,p_UNIT_PERCENT_BASE_PRICE   IN     jtf_number_table                := NULL
 ,p_SERVICE_NUMBER            IN     jtf_number_table                := NULL
 ,p_SERVICE_PERIOD            IN     jtf_varchar2_table_100          := NULL
 ,p_SHIPPABLE_FLAG            IN     jtf_varchar2_table_100          := NULL
 ,p_MODEL_REMNANT_FLAG        IN     jtf_varchar2_table_100          := NULL
 ,p_RE_SOURCE_FLAG            IN     jtf_varchar2_table_300          := NULL
 ,p_FLOW_STATUS_CODE          IN     jtf_varchar2_table_100          := NULL
 ,p_TP_CONTEXT                IN     jtf_varchar2_table_100          := NULL
 ,p_TP_ATTRIBUTE1             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE2             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE3             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE4             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE5             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE6             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE7             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE8             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE9             IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE10            IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE11            IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE12            IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE13            IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE14            IN     jtf_varchar2_table_300          := NULL
 ,p_TP_ATTRIBUTE15            IN     jtf_varchar2_table_300          := NULL
 ,p_FULFILLMENT_METHOD_CODE   IN     jtf_varchar2_table_300          := NULL
 ,p_MARKETING_SOURCE_CODE_ID  IN     jtf_number_table                := NULL
 ,p_SERVICE_REF_TYPE_CODE     IN     jtf_varchar2_table_100          := NULL
 ,p_SERVICE_REFERENCE_LINE_ID IN     jtf_number_table                := NULL
 ,p_SERVICE_REF_SYSTEM_ID     IN     jtf_number_table                 := NULL
 ,p_CALCULATE_PRICE_FLAG      IN     jtf_varchar2_table_100           := NULL
 ,p_UPGRADED_FLAG             IN     jtf_varchar2_table_100           := NULL
 ,p_REVENUE_AMOUNT            IN     jtf_number_table                 := NULL
 ,p_FULFILLMENT_DATE          IN     jtf_date_table                   := NULL
 ,p_PREFERRED_GRADE           IN     jtf_varchar2_table_100           := NULL
 ,p_ORDERED_QUANTITY2         IN     jtf_number_table                 := NULL
 ,p_ORDERED_QUANTITY_UOM2     IN     jtf_varchar2_table_100           := NULL
 ,p_SHIPPING_QUANTITY2        IN     jtf_number_table                 := NULL
 ,p_CANCELLED_QUANTITY2       IN     jtf_number_table                 := NULL
 ,p_SHIPPED_QUANTITY2         IN     jtf_number_table                 := NULL
 ,p_SHIPPING_QUANTITY_UOM2    IN     jtf_varchar2_table_100           := NULL
 ,p_FULFILLED_QUANTITY2       IN     jtf_number_table                 := NULL
 ,p_MFG_LEAD_TIME             IN     jtf_number_table                 := NULL
 ,p_LOCK_CONTROL              IN     jtf_number_table                 := NULL
 ,p_SUBINVENTORY              IN     jtf_varchar2_table_100           := NULL
 ,p_UNIT_LIST_PRICE_PER_PQTY  IN     jtf_number_table                 := NULL
 ,p_UNIT_SELL_PRICE_PER_PQTY  IN     jtf_number_table                 := NULL
 ,p_PRICE_REQUEST_CODE        IN     jtf_varchar2_table_300           := NULL
 ,p_ORIGINAL_INVENTORY_ITEM_ID IN    jtf_number_table                 := NULL
 ,p_ORIGINAL_ORDERED_ITEM_ID   IN    jtf_number_table                 := NULL
 ,p_ORIGINAL_ORDERED_ITEM      IN    jtf_varchar2_table_300           := NULL
 ,p_ORIGINAL_ITEM_IDENTIF_TYPE IN    jtf_varchar2_table_100           := NULL
 ,p_ITEM_SUBSTIT_TYPE_CODE     IN    jtf_varchar2_table_100           := NULL
 ,p_OVERRIDE_ATP_DATE_CODE     IN    jtf_varchar2_table_100           := NULL
 ,p_LATE_DEMAND_PENALTY_FACTOR IN    jtf_number_table                 := NULL
 ,p_ACCOUNTING_RULE_DURATION   IN    jtf_number_table                 := NULL

 ,p_top_model_line_index        IN jtf_number_table          := NULL
 ,p_top_model_line_ref          IN jtf_varchar2_table_100    := NULL
 ,p_unit_cost                   IN jtf_number_table          := NULL
 ,p_xml_transaction_type_code   IN jtf_varchar2_table_100    := NULL
 ,p_Sold_to_address_id          IN jtf_number_table          := NULL
 ,p_Split_Action_Code           IN jtf_varchar2_table_100    := NULL
 ,p_split_from_line_ref         IN jtf_varchar2_table_100    := NULL
 ,p_split_from_shipment_ref     IN jtf_varchar2_table_100    := NULL
 ,p_status_flag                 IN jtf_varchar2_table_100    := NULL
 ,p_ship_from_edi_loc_code      IN jtf_varchar2_table_100    := NULL
 ,p_ship_set                    IN jtf_varchar2_table_100    := NULL
 ,p_Ship_to_address_code        IN jtf_varchar2_table_100    := NULL
 ,p_Ship_to_address_id          IN jtf_varchar2_table_300    := NULL
 ,p_ship_to_customer_id         IN jtf_number_table          := NULL
 ,p_ship_to_edi_location_code   IN jtf_varchar2_table_100    := NULL
 ,p_service_ref_line_number     IN jtf_number_table          := NULL
 ,p_service_ref_option_number   IN jtf_number_table          := NULL
 ,p_service_ref_order_number    IN jtf_number_table          := NULL
 ,p_service_ref_ship_number     IN jtf_number_table          := NULL
 ,p_service_reference_line      IN jtf_varchar2_table_100    := NULL
 ,p_service_reference_order     IN jtf_varchar2_table_100    := NULL
 ,p_service_reference_system    IN jtf_varchar2_table_100    := NULL
 ,p_reserved_quantity           IN jtf_number_table          := NULL
 ,p_return_status               IN jtf_varchar2_table_100    := NULL
 ,p_schedule_action_code        IN jtf_varchar2_table_100    := NULL
 ,p_service_line_index          IN jtf_number_table          := NULL
 ,p_intermed_ship_to_cont_id    IN jtf_number_table          := NULL
 ,p_intermed_ship_to_org_id     IN jtf_number_table          := NULL
 ,p_Invoice_address_id          IN jtf_number_table          := NULL
 ,p_invoice_to_customer_id      IN jtf_number_table          := NULL
 ,p_item_relationship_type    IN jtf_number_table          := NULL
 ,p_link_to_line_index          IN jtf_number_table          := NULL
 ,p_link_to_line_ref            IN jtf_varchar2_table_100    := NULL
 ,p_db_flag                     IN jtf_varchar2_table_100    := NULL
 ,p_deliver_to_customer_id      IN jtf_number_table          := NULL
 ,p_fulfillment_set             IN jtf_varchar2_table_100    := NULL
 ,p_fulfillment_set_id          IN jtf_number_table          := NULL
 ,p_change_comments             IN jtf_varchar2_table_300    := NULL
 ,p_change_reason               IN jtf_varchar2_table_100    := NULL
 ,p_change_request_code         IN jtf_varchar2_table_100    := NULL
 ,p_Bill_to_Edi_Location_Code   IN jtf_varchar2_table_100    := NULL
 ,p_Blanket_Line_Number         IN jtf_number_table          := NULL
 ,p_Blanket_Number              IN jtf_number_table          := NULL
 ,p_Blanket_Version_Number      IN jtf_number_table          := NULL
 ,p_arrival_set              IN jtf_varchar2_table_100          := NULL
 ,p_attribute16              IN jtf_varchar2_table_300          := NULL
 ,p_attribute17              IN jtf_varchar2_table_300          := NULL
 ,p_attribute18              IN jtf_varchar2_table_300          := NULL
 ,p_attribute19              IN jtf_varchar2_table_300          := NULL
 ,p_attribute20              IN jtf_varchar2_table_300          := NULL

)
RETURN OE_Order_PUB.Line_Tbl_Type
IS

   l_order_line_tbl     OE_Order_PUB.Line_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct LineRecord package body - Begin');
  END IF;

--To determine the table size

  IF p_HEADER_ID IS NOT NULL THEN
    l_table_size := p_HEADER_ID.COUNT;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('In Returns construct LineRecord tcount' ||l_table_size);
    END IF;
  END IF;

  IF l_table_size > 0 THEN

  FOR i IN 1..l_table_size LOOP

  l_order_line_tbl(i) := OE_Order_PUB.G_MISS_LINE_REC;

  IF ((p_LINE_ID is not null) and ((p_LINE_ID(i) is null) or (p_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LINE_ID := p_LINE_ID(i);
  END IF;

  IF (p_OPERATION is not null) THEN
    l_order_line_tbl(i).OPERATION := p_OPERATION(i);
  END IF;

  IF ((p_ORG_ID is not null) and ((p_ORG_ID(i) is null) or (p_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORG_ID := p_ORG_ID(i);
  END IF;


  IF ((p_HEADER_ID is not null) and ((p_HEADER_ID(i) is null) or (p_HEADER_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).HEADER_ID := p_HEADER_ID(i);
  END IF;

  IF ((p_LINE_TYPE_ID is not null) and ((p_LINE_TYPE_ID(i) is null) or (p_LINE_TYPE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LINE_TYPE_ID := p_LINE_TYPE_ID(i);
  END IF;
  IF ((p_LINE_NUMBER is not null) and ((p_LINE_NUMBER(i) is null) or (p_LINE_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LINE_NUMBER := p_LINE_NUMBER(i);
  END IF;
  IF (p_ORDERED_ITEM is not null) THEN
    l_order_line_tbl(i).ORDERED_ITEM := p_ORDERED_ITEM(i);
  END IF;
  IF ((p_REQUEST_DATE is not null) and ((p_REQUEST_DATE(i) is null) or (p_REQUEST_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).REQUEST_DATE := p_REQUEST_DATE(i);
  END IF;
  IF ((p_PROMISE_DATE is not null) and ((p_PROMISE_DATE(i) is null) or (p_PROMISE_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).PROMISE_DATE := p_PROMISE_DATE(i);
  END IF;
  IF ((p_SCHEDULE_SHIP_DATE is not null) and ((p_SCHEDULE_SHIP_DATE(i) is null) or (p_SCHEDULE_SHIP_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).SCHEDULE_SHIP_DATE := p_SCHEDULE_SHIP_DATE(i);
  END IF;

  IF (p_ORDER_QUANTITY_UOM is not null) THEN
    l_order_line_tbl(i).ORDER_QUANTITY_UOM := p_ORDER_QUANTITY_UOM(i);
  END IF;
  IF ((p_PRICING_QUANTITY is not null) and ((p_PRICING_QUANTITY(i) is null) or (p_PRICING_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PRICING_QUANTITY := p_PRICING_QUANTITY(i);
  END IF;
  IF (p_PRICING_QUANTITY_UOM is not null) THEN
    l_order_line_tbl(i).PRICING_QUANTITY_UOM := p_PRICING_QUANTITY_UOM(i);
  END IF;
  IF ((p_CANCELLED_QUANTITY is not null) and ((p_CANCELLED_QUANTITY(i) is null) or (p_CANCELLED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CANCELLED_QUANTITY := p_CANCELLED_QUANTITY(i);
  END IF;
  IF ((p_SHIPPED_QUANTITY is not null) and ((p_SHIPPED_QUANTITY(i) is null) or (p_SHIPPED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIPPED_QUANTITY := p_SHIPPED_QUANTITY(i);
  END IF;
  IF ((p_ORDERED_QUANTITY is not null) and ((p_ORDERED_QUANTITY(i) is null) or (p_ORDERED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORDERED_QUANTITY := p_ORDERED_QUANTITY(i);
  END IF;
  IF ((p_FULFILLED_QUANTITY is not null) and ((p_FULFILLED_QUANTITY(i) is null) or (p_FULFILLED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).FULFILLED_QUANTITY := p_FULFILLED_QUANTITY(i);
  END IF;
  IF ((p_SHIPPING_QUANTITY is not null) and ((p_SHIPPING_QUANTITY(i) is null) or (p_SHIPPING_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIPPING_QUANTITY := p_SHIPPING_QUANTITY(i);
  END IF;
  IF (p_SHIPPING_QUANTITY_UOM is not null) THEN
    l_order_line_tbl(i).SHIPPING_QUANTITY_UOM := p_SHIPPING_QUANTITY_UOM(i);
  END IF;
  IF ((p_DELIVERY_LEAD_TIME is not null) and ((p_DELIVERY_LEAD_TIME(i) is null) or (p_DELIVERY_LEAD_TIME(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).DELIVERY_LEAD_TIME := p_DELIVERY_LEAD_TIME(i);
  END IF;
  IF (p_TAX_EXEMPT_FLAG is not null) THEN
    l_order_line_tbl(i).TAX_EXEMPT_FLAG := p_TAX_EXEMPT_FLAG(i);
  END IF;
  IF (p_TAX_EXEMPT_NUMBER is not null) THEN
    l_order_line_tbl(i).TAX_EXEMPT_NUMBER := p_TAX_EXEMPT_NUMBER(i);
  END IF;
  IF (p_TAX_EXEMPT_REASON_CODE is not null) THEN
    l_order_line_tbl(i).TAX_EXEMPT_REASON_CODE := p_TAX_EXEMPT_REASON_CODE(i);
  END IF;
  IF ((p_SHIP_FROM_ORG_ID is not null) and ((p_SHIP_FROM_ORG_ID(i) is null) or (p_SHIP_FROM_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_FROM_ORG_ID := p_SHIP_FROM_ORG_ID(i);
  END IF;
  IF ((p_SHIP_TO_ORG_ID is not null) and ((p_SHIP_TO_ORG_ID(i) is null) or (p_SHIP_TO_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_TO_ORG_ID := p_SHIP_TO_ORG_ID(i);
  END IF;
  IF ((p_INVOICE_TO_ORG_ID is not null) and ((p_INVOICE_TO_ORG_ID(i) is null) or (p_INVOICE_TO_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).INVOICE_TO_ORG_ID := p_INVOICE_TO_ORG_ID(i);
  END IF;
  IF ((p_DELIVER_TO_ORG_ID is not null) and ((p_DELIVER_TO_ORG_ID(i) is null) or (p_DELIVER_TO_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).DELIVER_TO_ORG_ID := p_DELIVER_TO_ORG_ID(i);
  END IF;
  IF ((p_SHIP_TO_CONTACT_ID is not null) and ((p_SHIP_TO_CONTACT_ID(i) is null) or (p_SHIP_TO_CONTACT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_TO_CONTACT_ID := p_SHIP_TO_CONTACT_ID(i);
  END IF;
  IF ((p_DELIVER_TO_CONTACT_ID is not null) and ((p_DELIVER_TO_CONTACT_ID(i) is null) or (p_DELIVER_TO_CONTACT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).DELIVER_TO_CONTACT_ID := p_DELIVER_TO_CONTACT_ID(i);
  END IF;
  IF ((p_INVOICE_TO_CONTACT_ID is not null) and ((p_INVOICE_TO_CONTACT_ID(i) is null) or (p_INVOICE_TO_CONTACT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).INVOICE_TO_CONTACT_ID := p_INVOICE_TO_CONTACT_ID(i);
  END IF;

  IF ((p_SOLD_FROM_ORG_ID is not null) and ((p_SOLD_FROM_ORG_ID(i) is null) or (p_SOLD_FROM_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SOLD_FROM_ORG_ID := p_SOLD_FROM_ORG_ID(i);
  END IF;
  IF ((p_SOLD_TO_ORG_ID is not null) and ((p_SOLD_TO_ORG_ID(i) is null) or (p_SOLD_TO_ORG_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SOLD_TO_ORG_ID := p_SOLD_TO_ORG_ID(i);
  END IF;
  IF (p_CUST_PO_NUMBER is not null) THEN
    l_order_line_tbl(i).CUST_PO_NUMBER := p_CUST_PO_NUMBER(i);
  END IF;
  IF ((p_SHIP_TOLERANCE_ABOVE is not null) and ((p_SHIP_TOLERANCE_ABOVE(i) is null) or (p_SHIP_TOLERANCE_ABOVE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_TOLERANCE_ABOVE := p_SHIP_TOLERANCE_ABOVE(i);
  END IF;
  IF ((p_SHIP_TOLERANCE_BELOW is not null) and ((p_SHIP_TOLERANCE_BELOW(i) is null) or (p_SHIP_TOLERANCE_BELOW(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_TOLERANCE_BELOW := p_SHIP_TOLERANCE_BELOW(i);
  END IF;
  IF (p_DEMAND_BUCKET_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).DEMAND_BUCKET_TYPE_CODE := p_DEMAND_BUCKET_TYPE_CODE(i);
  END IF;
  IF ((p_VEH_CUS_ITEM_CUM_KEY_ID is not null) and ((p_VEH_CUS_ITEM_CUM_KEY_ID(i) is null) or (p_VEH_CUS_ITEM_CUM_KEY_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).VEH_CUS_ITEM_CUM_KEY_ID := p_VEH_CUS_ITEM_CUM_KEY_ID(i);
  END IF;
  IF (p_RLA_SCHEDULE_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).RLA_SCHEDULE_TYPE_CODE := p_RLA_SCHEDULE_TYPE_CODE(i);
  END IF;
  IF (p_CUSTOMER_DOCK_CODE is not null) THEN
    l_order_line_tbl(i).CUSTOMER_DOCK_CODE := p_CUSTOMER_DOCK_CODE(i);
  END IF;
  IF (p_CUSTOMER_JOB is not null) THEN
    l_order_line_tbl(i).CUSTOMER_JOB := p_CUSTOMER_JOB(i);
  END IF;
  IF (p_CUSTOMER_PRODUCTION_LINE is not null) THEN
    l_order_line_tbl(i).CUSTOMER_PRODUCTION_LINE := p_CUSTOMER_PRODUCTION_LINE(i);
  END IF;
  IF (p_CUST_MODEL_SERIAL_NUMBER is not null) THEN
    l_order_line_tbl(i).CUST_MODEL_SERIAL_NUMBER := p_CUST_MODEL_SERIAL_NUMBER(i);
  END IF;
  IF ((p_PROJECT_ID is not null) and ((p_PROJECT_ID(i) is null) or (p_PROJECT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PROJECT_ID := p_PROJECT_ID(i);
  END IF;
  IF ((p_TASK_ID is not null) and ((p_TASK_ID(i) is null) or (p_TASK_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).TASK_ID := p_TASK_ID(i);
  END IF;
  IF ((p_INVENTORY_ITEM_ID is not null) and ((p_INVENTORY_ITEM_ID(i) is null) or (p_INVENTORY_ITEM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).INVENTORY_ITEM_ID := p_INVENTORY_ITEM_ID(i);
  END IF;
  IF ((p_TAX_DATE is not null) and ((p_TAX_DATE(i) is null) or (p_TAX_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).TAX_DATE := p_TAX_DATE(i);
  END IF;
  IF (p_TAX_CODE is not null) THEN
    l_order_line_tbl(i).TAX_CODE := p_TAX_CODE(i);
  END IF;
  IF ((p_TAX_RATE is not null) and ((p_TAX_RATE(i) is null) or (p_TAX_RATE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).TAX_RATE := p_TAX_RATE(i);
  END IF;
  IF (p_INVOICE_INTER_STATUS_CODE is not null) THEN
    l_order_line_tbl(i).INVOICE_INTERFACE_STATUS_CODE := p_INVOICE_INTER_STATUS_CODE(i);
  END IF;
  IF (p_DEMAND_CLASS_CODE is not null) THEN
    l_order_line_tbl(i).DEMAND_CLASS_CODE := p_DEMAND_CLASS_CODE(i);
  END IF;
  IF ((p_PRICE_LIST_ID is not null) and ((p_PRICE_LIST_ID(i) is null) or (p_PRICE_LIST_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PRICE_LIST_ID := p_PRICE_LIST_ID(i);
  END IF;
  IF ((p_PRICING_DATE is not null) and ((p_PRICING_DATE(i) is null) or (p_PRICING_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).PRICING_DATE := p_PRICING_DATE(i);
  END IF;
  IF ((p_SHIPMENT_NUMBER is not null) and ((p_SHIPMENT_NUMBER(i) is null) or (p_SHIPMENT_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIPMENT_NUMBER := p_SHIPMENT_NUMBER(i);
  END IF;
  IF ((p_AGREEMENT_ID is not null) and ((p_AGREEMENT_ID(i) is null) or (p_AGREEMENT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).AGREEMENT_ID := p_AGREEMENT_ID(i);
  END IF;
  IF (p_SHIPMENT_PRIORITY_CODE is not null) THEN
    l_order_line_tbl(i).SHIPMENT_PRIORITY_CODE := p_SHIPMENT_PRIORITY_CODE(i);
  END IF;
  IF (p_SHIPPING_METHOD_CODE is not null) THEN
    l_order_line_tbl(i).SHIPPING_METHOD_CODE := p_SHIPPING_METHOD_CODE(i);
  END IF;
  IF (p_FREIGHT_CARRIER_CODE is not null) THEN
    l_order_line_tbl(i).FREIGHT_CARRIER_CODE := p_FREIGHT_CARRIER_CODE(i);
  END IF;
  IF (p_FREIGHT_TERMS_CODE is not null) THEN
    l_order_line_tbl(i).FREIGHT_TERMS_CODE := p_FREIGHT_TERMS_CODE(i);
  END IF;
  IF (p_FOB_POINT_CODE is not null) THEN
    l_order_line_tbl(i).FOB_POINT_CODE := p_FOB_POINT_CODE(i);
  END IF;
  IF (p_TAX_POINT_CODE is not null) THEN
    l_order_line_tbl(i).TAX_POINT_CODE := p_TAX_POINT_CODE(i);
  END IF;
  IF ((p_PAYMENT_TERM_ID is not null) and ((p_PAYMENT_TERM_ID(i) is null) or (p_PAYMENT_TERM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PAYMENT_TERM_ID := p_PAYMENT_TERM_ID(i);
  END IF;
  IF ((p_INVOICING_RULE_ID is not null) and ((p_INVOICING_RULE_ID(i) is null) or (p_INVOICING_RULE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).INVOICING_RULE_ID := p_INVOICING_RULE_ID(i);
  END IF;
  IF ((p_ACCOUNTING_RULE_ID is not null) and ((p_ACCOUNTING_RULE_ID(i) is null) or (p_ACCOUNTING_RULE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ACCOUNTING_RULE_ID := p_ACCOUNTING_RULE_ID(i);
  END IF;
  IF ((p_SOURCE_DOCUMENT_TYPE_ID is not null) and ((p_SOURCE_DOCUMENT_TYPE_ID(i) is null) or (p_SOURCE_DOCUMENT_TYPE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SOURCE_DOCUMENT_TYPE_ID := p_SOURCE_DOCUMENT_TYPE_ID(i);
  END IF;
 IF (p_ORIG_SYS_DOCUMENT_REF is not null) THEN
    l_order_line_tbl(i).ORIG_SYS_DOCUMENT_REF := p_ORIG_SYS_DOCUMENT_REF(i);
  END IF;
  IF ((p_SOURCE_DOCUMENT_ID is not null) and ((p_SOURCE_DOCUMENT_ID(i) is null) or (p_SOURCE_DOCUMENT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SOURCE_DOCUMENT_ID := p_SOURCE_DOCUMENT_ID(i);
  END IF;
  IF (p_ORIG_SYS_LINE_REF is not null) THEN
    l_order_line_tbl(i).ORIG_SYS_LINE_REF := p_ORIG_SYS_LINE_REF(i);
  END IF;
  IF ((p_SOURCE_DOCUMENT_LINE_ID is not null) and ((p_SOURCE_DOCUMENT_LINE_ID(i) is null) or (p_SOURCE_DOCUMENT_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SOURCE_DOCUMENT_LINE_ID := p_SOURCE_DOCUMENT_LINE_ID(i);
  END IF;
  IF ((p_REFERENCE_LINE_ID is not null) and ((p_REFERENCE_LINE_ID(i) is null) or (p_REFERENCE_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).REFERENCE_LINE_ID := p_REFERENCE_LINE_ID(i);
  END IF;
  IF (p_REFERENCE_TYPE is not null) THEN
    l_order_line_tbl(i).REFERENCE_TYPE := p_REFERENCE_TYPE(i);
  END IF;
  IF ((p_REFERENCE_HEADER_ID is not null) and ((p_REFERENCE_HEADER_ID(i) is null) or (p_REFERENCE_HEADER_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).REFERENCE_HEADER_ID := p_REFERENCE_HEADER_ID(i);
  END IF;
  IF (p_ITEM_REVISION is not null) THEN
    l_order_line_tbl(i).ITEM_REVISION := p_ITEM_REVISION(i);
  END IF;
  IF ((p_UNIT_SELLING_PRICE is not null) and ((p_UNIT_SELLING_PRICE(i) is null) or (p_UNIT_SELLING_PRICE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_SELLING_PRICE := p_UNIT_SELLING_PRICE(i);
  END IF;
  IF ((p_UNIT_LIST_PRICE is not null) and ((p_UNIT_LIST_PRICE(i) is null) or (p_UNIT_LIST_PRICE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_LIST_PRICE := p_UNIT_LIST_PRICE(i);
  END IF;
  IF ((p_TAX_VALUE is not null) and ((p_TAX_VALUE(i) is null) or (p_TAX_VALUE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).TAX_VALUE := p_TAX_VALUE(i);
  END IF;
  IF (p_CONTEXT is not null) THEN
    l_order_line_tbl(i).CONTEXT := p_CONTEXT(i);
  END IF;
  IF (p_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE1 := p_ATTRIBUTE1(i);
  END IF;
  IF (p_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE2 := p_ATTRIBUTE2(i);
  END IF;
  IF (p_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE3 := p_ATTRIBUTE3(i);
  END IF;
  IF (p_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE4 := p_ATTRIBUTE4(i);
  END IF;
  IF (p_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE5 := p_ATTRIBUTE5(i);
  END IF;
  IF (p_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE6 := p_ATTRIBUTE6(i);
  END IF;
  IF (p_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE7 := p_ATTRIBUTE7(i);
  END IF;
  IF (p_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE8 := p_ATTRIBUTE8(i);
  END IF;
  IF (p_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE9 := p_ATTRIBUTE9(i);
  END IF;
  IF (p_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE10 := p_ATTRIBUTE10(i);
  END IF;
  IF (p_ATTRIBUTE11 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE11 := p_ATTRIBUTE11(i);
  END IF;
  IF (p_ATTRIBUTE12 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE12 := p_ATTRIBUTE12(i);
  END IF;
  IF (p_ATTRIBUTE13 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE13 := p_ATTRIBUTE13(i);
  END IF;
  IF (p_ATTRIBUTE14 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE14 := p_ATTRIBUTE14(i);
  END IF;
  IF (p_ATTRIBUTE15 is not null) THEN
    l_order_line_tbl(i).ATTRIBUTE15 := p_ATTRIBUTE15(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE_CATEGORY is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY := p_GLOBAL_ATTRIBUTE_CATEGORY(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE1 := p_GLOBAL_ATTRIBUTE1(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE2 := p_GLOBAL_ATTRIBUTE2(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE3 := p_GLOBAL_ATTRIBUTE3(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE4 := p_GLOBAL_ATTRIBUTE4(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE5 := p_GLOBAL_ATTRIBUTE5(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE6 := p_GLOBAL_ATTRIBUTE6(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE7 := p_GLOBAL_ATTRIBUTE7(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE8 := p_GLOBAL_ATTRIBUTE8(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE9 := p_GLOBAL_ATTRIBUTE9(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE10 := p_GLOBAL_ATTRIBUTE10(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE11 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE11 := p_GLOBAL_ATTRIBUTE11(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE12 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE12 := p_GLOBAL_ATTRIBUTE12(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE13 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE13 := p_GLOBAL_ATTRIBUTE13(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE14 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE14 := p_GLOBAL_ATTRIBUTE14(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE15 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE15 := p_GLOBAL_ATTRIBUTE15(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE16 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE16 := p_GLOBAL_ATTRIBUTE16(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE17 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE17 := p_GLOBAL_ATTRIBUTE17(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE18 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE18 := p_GLOBAL_ATTRIBUTE18(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE19 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE19 := p_GLOBAL_ATTRIBUTE19(i);
  END IF;
  IF (p_GLOBAL_ATTRIBUTE20 is not null) THEN
    l_order_line_tbl(i).GLOBAL_ATTRIBUTE20 := p_GLOBAL_ATTRIBUTE20(i);
  END IF;
  IF (p_PRICING_CONTEXT is not null) THEN
    l_order_line_tbl(i).PRICING_CONTEXT := p_PRICING_CONTEXT(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE1 := p_PRICING_ATTRIBUTE1(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE2 := p_PRICING_ATTRIBUTE2(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE3 := p_PRICING_ATTRIBUTE3(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE4 := p_PRICING_ATTRIBUTE4(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE5 := p_PRICING_ATTRIBUTE5(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE6 := p_PRICING_ATTRIBUTE6(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE7 := p_PRICING_ATTRIBUTE7(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE8 := p_PRICING_ATTRIBUTE8(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE9 := p_PRICING_ATTRIBUTE9(i);
  END IF;
  IF (p_PRICING_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).PRICING_ATTRIBUTE10 := p_PRICING_ATTRIBUTE10(i);
  END IF;
  IF (p_INDUSTRY_CONTEXT is not null) THEN
    l_order_line_tbl(i).INDUSTRY_CONTEXT := p_INDUSTRY_CONTEXT(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE1 := p_INDUSTRY_ATTRIBUTE1(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE2 := p_INDUSTRY_ATTRIBUTE2(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE3 := p_INDUSTRY_ATTRIBUTE3(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE4 := p_INDUSTRY_ATTRIBUTE4(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE5 := p_INDUSTRY_ATTRIBUTE5(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE6 := p_INDUSTRY_ATTRIBUTE6(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE7 := p_INDUSTRY_ATTRIBUTE7(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE8 := p_INDUSTRY_ATTRIBUTE8(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE9 := p_INDUSTRY_ATTRIBUTE9(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE10 := p_INDUSTRY_ATTRIBUTE10(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE11 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE11 := p_INDUSTRY_ATTRIBUTE11(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE13 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE13 := p_INDUSTRY_ATTRIBUTE13(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE12 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE12 := p_INDUSTRY_ATTRIBUTE12(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE14 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE14 := p_INDUSTRY_ATTRIBUTE14(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE15 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE15 := p_INDUSTRY_ATTRIBUTE15(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE16 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE16 := p_INDUSTRY_ATTRIBUTE16(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE17 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE17 := p_INDUSTRY_ATTRIBUTE17(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE18 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE18 := p_INDUSTRY_ATTRIBUTE18(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE19 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE19 := p_INDUSTRY_ATTRIBUTE19(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE20 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE20 := p_INDUSTRY_ATTRIBUTE20(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE21 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE21 := p_INDUSTRY_ATTRIBUTE21(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE22 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE22 := p_INDUSTRY_ATTRIBUTE22(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE23 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE23 := p_INDUSTRY_ATTRIBUTE23(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE24 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE24 := p_INDUSTRY_ATTRIBUTE24(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE25 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE25 := p_INDUSTRY_ATTRIBUTE25(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE26 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE26 := p_INDUSTRY_ATTRIBUTE26(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE27 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE27 := p_INDUSTRY_ATTRIBUTE27(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE28 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE28 := p_INDUSTRY_ATTRIBUTE28(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE29 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE29 := p_INDUSTRY_ATTRIBUTE29(i);
  END IF;
  IF (p_INDUSTRY_ATTRIBUTE30 is not null) THEN
    l_order_line_tbl(i).INDUSTRY_ATTRIBUTE30 := p_INDUSTRY_ATTRIBUTE30(i);
  END IF;
  IF ((p_CREATION_DATE is not null) and ((p_CREATION_DATE(i) is null) or (p_CREATION_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).CREATION_DATE := p_CREATION_DATE(i);
  END IF;
  IF ((p_CREATED_BY is not null) and ((p_CREATED_BY(i) is null) or (p_CREATED_BY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CREATED_BY := p_CREATED_BY(i);
  END IF;
  IF ((p_LAST_UPDATE_DATE is not null) and ((p_LAST_UPDATE_DATE(i) is null) or (p_LAST_UPDATE_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).LAST_UPDATE_DATE := p_LAST_UPDATE_DATE(i);
  END IF;
  IF ((p_LAST_UPDATED_BY is not null) and ((p_LAST_UPDATED_BY(i) is null) or (p_LAST_UPDATED_BY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LAST_UPDATED_BY := p_LAST_UPDATED_BY(i);
  END IF;
  IF ((p_LAST_UPDATE_LOGIN is not null) and ((p_LAST_UPDATE_LOGIN(i) is null) or (p_LAST_UPDATE_LOGIN(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LAST_UPDATE_LOGIN := p_LAST_UPDATE_LOGIN(i);
  END IF;
  IF ((p_PROGRAM_APPLICATION_ID is not null) and ((p_PROGRAM_APPLICATION_ID(i) is null) or (p_PROGRAM_APPLICATION_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PROGRAM_APPLICATION_ID := p_PROGRAM_APPLICATION_ID(i);
  END IF;
  IF ((p_PROGRAM_ID is not null) and ((p_PROGRAM_ID(i) is null) or (p_PROGRAM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PROGRAM_ID := p_PROGRAM_ID(i);
  END IF;
  IF ((p_PROGRAM_UPDATE_DATE is not null) and ((p_PROGRAM_UPDATE_DATE(i) is null) or (p_PROGRAM_UPDATE_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).PROGRAM_UPDATE_DATE := p_PROGRAM_UPDATE_DATE(i);
  END IF;
  IF ((p_REQUEST_ID is not null) and ((p_REQUEST_ID(i) is null) or (p_REQUEST_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).REQUEST_ID := p_REQUEST_ID(i);
  END IF;
  IF ((p_TOP_MODEL_LINE_ID is not null) and ((p_TOP_MODEL_LINE_ID(i) is null) or (p_TOP_MODEL_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).TOP_MODEL_LINE_ID := p_TOP_MODEL_LINE_ID(i);
  END IF;
  IF ((p_LINK_TO_LINE_ID is not null) and ((p_LINK_TO_LINE_ID(i) is null) or (p_LINK_TO_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LINK_TO_LINE_ID := p_LINK_TO_LINE_ID(i);
  END IF;
  IF ((p_COMPONENT_SEQUENCE_ID is not null) and ((p_COMPONENT_SEQUENCE_ID(i) is null) or (p_COMPONENT_SEQUENCE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).COMPONENT_SEQUENCE_ID := p_COMPONENT_SEQUENCE_ID(i);
  END IF;
  IF (p_COMPONENT_CODE is not null) THEN
    l_order_line_tbl(i).COMPONENT_CODE := p_COMPONENT_CODE(i);
  END IF;
    IF ((p_CONFIG_DISPLAY_SEQUENCE is not null) and ((p_CONFIG_DISPLAY_SEQUENCE(i) is null) or (p_CONFIG_DISPLAY_SEQUENCE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CONFIG_DISPLAY_SEQUENCE := p_CONFIG_DISPLAY_SEQUENCE(i);
  END IF;
  IF (p_SORT_ORDER is not null) THEN
    l_order_line_tbl(i).SORT_ORDER := p_SORT_ORDER(i);
  END IF;
  IF (p_ITEM_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).ITEM_TYPE_CODE := p_ITEM_TYPE_CODE(i);
  END IF;
  IF ((p_OPTION_NUMBER is not null) and ((p_OPTION_NUMBER(i) is null) or (p_OPTION_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).OPTION_NUMBER := p_OPTION_NUMBER(i);
  END IF;
  IF (p_OPTION_FLAG is not null) THEN
    l_order_line_tbl(i).OPTION_FLAG := p_OPTION_FLAG(i);
  END IF;
  IF (p_DEP_PLAN_REQUIRED_FLAG is not null) THEN
    l_order_line_tbl(i).DEP_PLAN_REQUIRED_FLAG := p_DEP_PLAN_REQUIRED_FLAG(i);
  END IF;
  IF (p_VISIBLE_DEMAND_FLAG is not null) THEN
    l_order_line_tbl(i).VISIBLE_DEMAND_FLAG := p_VISIBLE_DEMAND_FLAG(i);
  END IF;
  IF (p_LINE_CATEGORY_CODE is not null) THEN
    l_order_line_tbl(i).LINE_CATEGORY_CODE := p_LINE_CATEGORY_CODE(i);
  END IF;
  IF ((p_ACTUAL_SHIPMENT_DATE is not null) and ((p_ACTUAL_SHIPMENT_DATE(i) is null) or (p_ACTUAL_SHIPMENT_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).ACTUAL_SHIPMENT_DATE := p_ACTUAL_SHIPMENT_DATE(i);
  END IF;
  IF ((p_CUSTOMER_TRX_LINE_ID is not null) and ((p_CUSTOMER_TRX_LINE_ID(i) is null) or (p_CUSTOMER_TRX_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CUSTOMER_TRX_LINE_ID := p_CUSTOMER_TRX_LINE_ID(i);
  END IF;
  IF (p_RETURN_CONTEXT is not null) THEN
    l_order_line_tbl(i).RETURN_CONTEXT := p_RETURN_CONTEXT(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE1 := p_RETURN_ATTRIBUTE1(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE2 := p_RETURN_ATTRIBUTE2(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE3 := p_RETURN_ATTRIBUTE3(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE4 := p_RETURN_ATTRIBUTE4(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE5 := p_RETURN_ATTRIBUTE5(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE6 := p_RETURN_ATTRIBUTE6(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE7 := p_RETURN_ATTRIBUTE7(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE8 := p_RETURN_ATTRIBUTE8(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE9 := p_RETURN_ATTRIBUTE9(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE10 := p_RETURN_ATTRIBUTE10(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE11 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE11 := p_RETURN_ATTRIBUTE11(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE12 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE12 := p_RETURN_ATTRIBUTE12(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE13 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE13 := p_RETURN_ATTRIBUTE13(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE14 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE14 := p_RETURN_ATTRIBUTE14(i);
  END IF;
  IF (p_RETURN_ATTRIBUTE15 is not null) THEN
    l_order_line_tbl(i).RETURN_ATTRIBUTE15 := p_RETURN_ATTRIBUTE15(i);
  END IF;
    IF ((p_ACTUAL_ARRIVAL_DATE is not null) and ((p_ACTUAL_ARRIVAL_DATE(i) is null) or (p_ACTUAL_ARRIVAL_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).ACTUAL_ARRIVAL_DATE := p_ACTUAL_ARRIVAL_DATE(i);
  END IF;
  IF ((p_ATO_LINE_ID is not null) and ((p_ATO_LINE_ID(i) is null) or (p_ATO_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ATO_LINE_ID := p_ATO_LINE_ID(i);
  END IF;
  IF ((p_AUTO_SELECTED_QUANTITY is not null) and ((p_AUTO_SELECTED_QUANTITY(i) is null) or (p_AUTO_SELECTED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).AUTO_SELECTED_QUANTITY := p_AUTO_SELECTED_QUANTITY(i);
  END IF;
  IF ((p_COMPONENT_NUMBER is not null) and ((p_COMPONENT_NUMBER(i) is null) or (p_COMPONENT_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).COMPONENT_NUMBER := p_COMPONENT_NUMBER(i);
  END IF;
  IF ((p_EARLIEST_ACCEPTABLE_DATE is not null) and ((p_EARLIEST_ACCEPTABLE_DATE(i) is null) or (p_EARLIEST_ACCEPTABLE_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).EARLIEST_ACCEPTABLE_DATE := p_EARLIEST_ACCEPTABLE_DATE(i);
  END IF;
  IF ((p_EXPLOSION_DATE is not null) and ((p_EXPLOSION_DATE(i) is null) or (p_EXPLOSION_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).EXPLOSION_DATE := p_EXPLOSION_DATE(i);
  END IF;
  IF ((p_LATEST_ACCEPTABLE_DATE is not null) and ((p_LATEST_ACCEPTABLE_DATE(i) is null) or (p_LATEST_ACCEPTABLE_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).LATEST_ACCEPTABLE_DATE := p_LATEST_ACCEPTABLE_DATE(i);
  END IF;
  IF ((p_MODEL_GROUP_NUMBER is not null) and ((p_MODEL_GROUP_NUMBER(i) is null) or (p_MODEL_GROUP_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).MODEL_GROUP_NUMBER := p_MODEL_GROUP_NUMBER(i);
  END IF;
  IF ((p_SCHEDULE_ARRIVAL_DATE is not null) and ((p_SCHEDULE_ARRIVAL_DATE(i) is null) or (p_SCHEDULE_ARRIVAL_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).SCHEDULE_ARRIVAL_DATE := p_SCHEDULE_ARRIVAL_DATE(i);
  END IF;
  IF (p_SHIP_MODEL_COMPLETE_FLAG is not null) THEN
    l_order_line_tbl(i).SHIP_MODEL_COMPLETE_FLAG := p_SHIP_MODEL_COMPLETE_FLAG(i);
  END IF;
  IF (p_SCHEDULE_STATUS_CODE is not null) THEN
    l_order_line_tbl(i).SCHEDULE_STATUS_CODE := p_SCHEDULE_STATUS_CODE(i);
  END IF;
  IF (p_SOURCE_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).SOURCE_TYPE_CODE := p_SOURCE_TYPE_CODE(i);
  END IF;
  IF (p_CANCELLED_FLAG is not null) THEN
    l_order_line_tbl(i).CANCELLED_FLAG := p_CANCELLED_FLAG(i);
  END IF;
  IF (p_OPEN_FLAG is not null) THEN
    l_order_line_tbl(i).OPEN_FLAG := p_OPEN_FLAG(i);
  END IF;
  IF (p_BOOKED_FLAG is not null) THEN
    l_order_line_tbl(i).BOOKED_FLAG := p_BOOKED_FLAG(i);
  END IF;
  IF ((p_SALESREP_ID is not null) and ((p_SALESREP_ID(i) is null) or (p_SALESREP_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SALESREP_ID := p_SALESREP_ID(i);
  END IF;
  IF (p_RETURN_REASON_CODE is not null) THEN
    l_order_line_tbl(i).RETURN_REASON_CODE := p_RETURN_REASON_CODE(i);
  END IF;
  IF ((p_ARRIVAL_SET_ID is not null) and ((p_ARRIVAL_SET_ID(i) is null) or (p_ARRIVAL_SET_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ARRIVAL_SET_ID := p_ARRIVAL_SET_ID(i);
  END IF;
  IF ((p_SHIP_SET_ID is not null) and ((p_SHIP_SET_ID(i) is null) or (p_SHIP_SET_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIP_SET_ID := p_SHIP_SET_ID(i);
  END IF;
  IF ((p_SPLIT_FROM_LINE_ID is not null) and ((p_SPLIT_FROM_LINE_ID(i) is null) or (p_SPLIT_FROM_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SPLIT_FROM_LINE_ID := p_SPLIT_FROM_LINE_ID(i);
  END IF;
  IF (p_CUST_PRODUCTION_SEQ_NUM is not null) THEN
    l_order_line_tbl(i).CUST_PRODUCTION_SEQ_NUM := p_CUST_PRODUCTION_SEQ_NUM(i);
  END IF;
  IF (p_AUTHORIZED_TO_SHIP_FLAG is not null) THEN
    l_order_line_tbl(i).AUTHORIZED_TO_SHIP_FLAG := p_AUTHORIZED_TO_SHIP_FLAG(i);
  END IF;
  IF (p_OVER_SHIP_REASON_CODE is not null) THEN
    l_order_line_tbl(i).OVER_SHIP_REASON_CODE := p_OVER_SHIP_REASON_CODE(i);
  END IF;
  IF (p_OVER_SHIP_RESOLVED_FLAG is not null) THEN
    l_order_line_tbl(i).OVER_SHIP_RESOLVED_FLAG := p_OVER_SHIP_RESOLVED_FLAG(i);
  END IF;
  IF ((p_ORDERED_ITEM_ID is not null) and ((p_ORDERED_ITEM_ID(i) is null) or (p_ORDERED_ITEM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORDERED_ITEM_ID := p_ORDERED_ITEM_ID(i);
  END IF;
  IF (p_ITEM_IDENTIFIER_TYPE is not null) THEN
    l_order_line_tbl(i).ITEM_IDENTIFIER_TYPE := p_ITEM_IDENTIFIER_TYPE(i);
  END IF;
  IF ((p_CONFIGURATION_ID is not null) and ((p_CONFIGURATION_ID(i) is null) or (p_CONFIGURATION_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CONFIGURATION_ID := p_CONFIGURATION_ID(i);
  END IF;
  IF ((p_COMMITMENT_ID is not null) and ((p_COMMITMENT_ID(i) is null) or (p_COMMITMENT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).COMMITMENT_ID := p_COMMITMENT_ID(i);
  END IF;
  IF (p_SHIPPING_INTERFACED_FLAG is not null) THEN
    l_order_line_tbl(i).SHIPPING_INTERFACED_FLAG := p_SHIPPING_INTERFACED_FLAG(i);
  END IF;
  IF ((p_CREDIT_INVOICE_LINE_ID is not null) and ((p_CREDIT_INVOICE_LINE_ID(i) is null) or (p_CREDIT_INVOICE_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CREDIT_INVOICE_LINE_ID := p_CREDIT_INVOICE_LINE_ID(i);
  END IF;
IF (p_FIRST_ACK_CODE is not null) THEN
    l_order_line_tbl(i).FIRST_ACK_CODE := p_FIRST_ACK_CODE(i);
  END IF;
  IF ((p_FIRST_ACK_DATE is not null) and ((p_FIRST_ACK_DATE(i) is null) or (p_FIRST_ACK_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).FIRST_ACK_DATE := p_FIRST_ACK_DATE(i);
  END IF;
  IF (p_LAST_ACK_CODE is not null) THEN
    l_order_line_tbl(i).LAST_ACK_CODE := p_LAST_ACK_CODE(i);
  END IF;
  IF ((p_LAST_ACK_DATE is not null) and ((p_LAST_ACK_DATE(i) is null) or (p_LAST_ACK_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).LAST_ACK_DATE := p_LAST_ACK_DATE(i);
  END IF;
  IF ((p_PLANNING_PRIORITY is not null) and ((p_PLANNING_PRIORITY(i) is null) or (p_PLANNING_PRIORITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).PLANNING_PRIORITY := p_PLANNING_PRIORITY(i);
  END IF;
  IF ((p_ORDER_SOURCE_ID is not null) and ((p_ORDER_SOURCE_ID(i) is null) or (p_ORDER_SOURCE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORDER_SOURCE_ID := p_ORDER_SOURCE_ID(i);
  END IF;
  IF (p_ORIG_SYS_SHIPMENT_REF is not null) THEN
    l_order_line_tbl(i).ORIG_SYS_SHIPMENT_REF := p_ORIG_SYS_SHIPMENT_REF(i);
  END IF;
  IF (p_CHANGE_SEQUENCE is not null) THEN
    l_order_line_tbl(i).CHANGE_SEQUENCE := p_CHANGE_SEQUENCE(i);
  END IF;
  IF (p_DROP_SHIP_FLAG is not null) THEN
    l_order_line_tbl(i).DROP_SHIP_FLAG := p_DROP_SHIP_FLAG(i);
  END IF;
  IF (p_CUSTOMER_LINE_NUMBER is not null) THEN
    l_order_line_tbl(i).CUSTOMER_LINE_NUMBER := p_CUSTOMER_LINE_NUMBER(i);
  END IF;
  IF (p_CUSTOMER_SHIPMENT_NUMBER is not null) THEN
    l_order_line_tbl(i).CUSTOMER_SHIPMENT_NUMBER := p_CUSTOMER_SHIPMENT_NUMBER(i);
  END IF;
  IF ((p_CUSTOMER_ITEM_NET_PRICE is not null) and ((p_CUSTOMER_ITEM_NET_PRICE(i) is null) or (p_CUSTOMER_ITEM_NET_PRICE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CUSTOMER_ITEM_NET_PRICE := p_CUSTOMER_ITEM_NET_PRICE(i);
  END IF;
  IF ((p_CUSTOMER_PAYMENT_TERM_ID is not null) and ((p_CUSTOMER_PAYMENT_TERM_ID(i) is null) or (p_CUSTOMER_PAYMENT_TERM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CUSTOMER_PAYMENT_TERM_ID := p_CUSTOMER_PAYMENT_TERM_ID(i);
  END IF;
  IF (p_FULFILLED_FLAG is not null) THEN
    l_order_line_tbl(i).FULFILLED_FLAG := p_FULFILLED_FLAG(i);
  END IF;
  IF (p_END_ITEM_UNIT_NUMBER is not null) THEN
    l_order_line_tbl(i).END_ITEM_UNIT_NUMBER := p_END_ITEM_UNIT_NUMBER(i);
  END IF;
  IF ((p_CONFIG_HEADER_ID is not null) and ((p_CONFIG_HEADER_ID(i) is null) or (p_CONFIG_HEADER_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CONFIG_HEADER_ID := p_CONFIG_HEADER_ID(i);
  END IF;
  IF ((p_CONFIG_REV_NBR is not null) and ((p_CONFIG_REV_NBR(i) is null) or (p_CONFIG_REV_NBR(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CONFIG_REV_NBR := p_CONFIG_REV_NBR(i);
  END IF;
  IF ((p_MFG_COMPONENT_SEQUENCE_ID is not null) and ((p_MFG_COMPONENT_SEQUENCE_ID(i) is null) or (p_MFG_COMPONENT_SEQUENCE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).MFG_COMPONENT_SEQUENCE_ID := p_MFG_COMPONENT_SEQUENCE_ID(i);
  END IF;
  IF (p_SHIPPING_INSTRUCTIONS is not null) THEN
    l_order_line_tbl(i).SHIPPING_INSTRUCTIONS := p_SHIPPING_INSTRUCTIONS(i);
  END IF;
  IF (p_PACKING_INSTRUCTIONS is not null) THEN
    l_order_line_tbl(i).PACKING_INSTRUCTIONS := p_PACKING_INSTRUCTIONS(i);
  END IF;
  IF ((p_INVOICED_QUANTITY is not null) and ((p_INVOICED_QUANTITY(i) is null) or (p_INVOICED_QUANTITY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).INVOICED_QUANTITY := p_INVOICED_QUANTITY(i);
  END IF;
  IF ((p_REF_CUSTOMER_TRX_LINE_ID is not null) and ((p_REF_CUSTOMER_TRX_LINE_ID(i) is null) or (p_REF_CUSTOMER_TRX_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).REFERENCE_CUSTOMER_TRX_LINE_ID := p_REF_CUSTOMER_TRX_LINE_ID(i);
  END IF;
  IF (p_SPLIT_BY is not null) THEN
    l_order_line_tbl(i).SPLIT_BY := p_SPLIT_BY(i);
  END IF;
  IF ((p_LINE_SET_ID is not null) and ((p_LINE_SET_ID(i) is null) or (p_LINE_SET_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LINE_SET_ID := p_LINE_SET_ID(i);
  END IF;
  IF (p_SERVICE_TXN_REASON_CODE is not null) THEN
    l_order_line_tbl(i).SERVICE_TXN_REASON_CODE := p_SERVICE_TXN_REASON_CODE(i);
  END IF;
  IF (p_SERVICE_TXN_COMMENTS is not null) THEN
    l_order_line_tbl(i).SERVICE_TXN_COMMENTS := p_SERVICE_TXN_COMMENTS(i);
  END IF;
  IF ((p_SERVICE_DURATION is not null) and ((p_SERVICE_DURATION(i) is null) or (p_SERVICE_DURATION(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SERVICE_DURATION := p_SERVICE_DURATION(i);
  END IF;
  IF ((p_SERVICE_START_DATE is not null) and ((p_SERVICE_START_DATE(i) is null) or (p_SERVICE_START_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).SERVICE_START_DATE := p_SERVICE_START_DATE(i);
  END IF;
  IF ((p_SERVICE_END_DATE is not null) and ((p_SERVICE_END_DATE(i) is null) or (p_SERVICE_END_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).SERVICE_END_DATE := p_SERVICE_END_DATE(i);
  END IF;
  IF (p_SERVICE_COTERMINATE_FLAG is not null) THEN
    l_order_line_tbl(i).SERVICE_COTERMINATE_FLAG := p_SERVICE_COTERMINATE_FLAG(i);
  END IF;
  IF ((p_UNIT_LIST_PERCENT is not null) and ((p_UNIT_LIST_PERCENT(i) is null) or (p_UNIT_LIST_PERCENT(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_LIST_PERCENT := p_UNIT_LIST_PERCENT(i);
  END IF;
  IF ((p_UNIT_SELLING_PERCENT is not null) and ((p_UNIT_SELLING_PERCENT(i) is null) or (p_UNIT_SELLING_PERCENT(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_SELLING_PERCENT := p_UNIT_SELLING_PERCENT(i);
  END IF;
  IF ((p_UNIT_PERCENT_BASE_PRICE is not null) and ((p_UNIT_PERCENT_BASE_PRICE(i) is null) or (p_UNIT_PERCENT_BASE_PRICE(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_PERCENT_BASE_PRICE := p_UNIT_PERCENT_BASE_PRICE(i);
  END IF;
  IF ((p_SERVICE_NUMBER is not null) and ((p_SERVICE_NUMBER(i) is null) or (p_SERVICE_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SERVICE_NUMBER := p_SERVICE_NUMBER(i);
  END IF;
  IF (p_SERVICE_PERIOD is not null) THEN
    l_order_line_tbl(i).SERVICE_PERIOD := p_SERVICE_PERIOD(i);
  END IF;
  IF (p_SHIPPABLE_FLAG is not null) THEN
    l_order_line_tbl(i).SHIPPABLE_FLAG := p_SHIPPABLE_FLAG(i);
  END IF;
  IF (p_MODEL_REMNANT_FLAG is not null) THEN
    l_order_line_tbl(i).MODEL_REMNANT_FLAG := p_MODEL_REMNANT_FLAG(i);
  END IF;
  IF (p_RE_SOURCE_FLAG is not null) THEN
    l_order_line_tbl(i).RE_SOURCE_FLAG := p_RE_SOURCE_FLAG(i);
  END IF;
  IF (p_FLOW_STATUS_CODE is not null) THEN
    l_order_line_tbl(i).FLOW_STATUS_CODE := p_FLOW_STATUS_CODE(i);
  END IF;
  IF (p_TP_CONTEXT is not null) THEN
    l_order_line_tbl(i).TP_CONTEXT := p_TP_CONTEXT(i);
  END IF;
  IF (p_TP_ATTRIBUTE1 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE1 := p_TP_ATTRIBUTE1(i);
  END IF;
  IF (p_TP_ATTRIBUTE2 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE2 := p_TP_ATTRIBUTE2(i);
  END IF;
  IF (p_TP_ATTRIBUTE3 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE3 := p_TP_ATTRIBUTE3(i);
  END IF;
  IF (p_TP_ATTRIBUTE4 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE4 := p_TP_ATTRIBUTE4(i);
  END IF;
  IF (p_TP_ATTRIBUTE5 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE5 := p_TP_ATTRIBUTE5(i);
  END IF;
  IF (p_TP_ATTRIBUTE6 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE6 := p_TP_ATTRIBUTE6(i);
  END IF;
  IF (p_TP_ATTRIBUTE7 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE7 := p_TP_ATTRIBUTE7(i);
  END IF;
  IF (p_TP_ATTRIBUTE8 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE8 := p_TP_ATTRIBUTE8(i);
  END IF;
  IF (p_TP_ATTRIBUTE9 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE9 := p_TP_ATTRIBUTE9(i);
  END IF;
  IF (p_TP_ATTRIBUTE10 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE10 := p_TP_ATTRIBUTE10(i);
  END IF;
  IF (p_TP_ATTRIBUTE11 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE11 := p_TP_ATTRIBUTE11(i);
  END IF;
  IF (p_TP_ATTRIBUTE12 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE12 := p_TP_ATTRIBUTE12(i);
  END IF;
  IF (p_TP_ATTRIBUTE13 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE13 := p_TP_ATTRIBUTE13(i);
  END IF;
  IF (p_TP_ATTRIBUTE14 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE14 := p_TP_ATTRIBUTE14(i);
  END IF;
  IF (p_TP_ATTRIBUTE15 is not null) THEN
    l_order_line_tbl(i).TP_ATTRIBUTE15 := p_TP_ATTRIBUTE15(i);
  END IF;
  IF (p_FULFILLMENT_METHOD_CODE is not null) THEN
    l_order_line_tbl(i).FULFILLMENT_METHOD_CODE := p_FULFILLMENT_METHOD_CODE(i);
  END IF;
  IF ((p_MARKETING_SOURCE_CODE_ID is not null) and ((p_MARKETING_SOURCE_CODE_ID(i) is null) or (p_MARKETING_SOURCE_CODE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).MARKETING_SOURCE_CODE_ID := p_MARKETING_SOURCE_CODE_ID(i);
  END IF;
  IF (p_SERVICE_REF_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).SERVICE_REFERENCE_TYPE_CODE := p_SERVICE_REF_TYPE_CODE(i);
  END IF;
  IF ((p_SERVICE_REFERENCE_LINE_ID is not null) and ((p_SERVICE_REFERENCE_LINE_ID(i) is null) or (p_SERVICE_REFERENCE_LINE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SERVICE_REFERENCE_LINE_ID := p_SERVICE_REFERENCE_LINE_ID(i);
  END IF;
  IF ((p_SERVICE_REF_SYSTEM_ID is not null) and ((p_SERVICE_REF_SYSTEM_ID(i) is null) or (p_SERVICE_REF_SYSTEM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SERVICE_REFERENCE_SYSTEM_ID := p_SERVICE_REF_SYSTEM_ID(i);
  END IF;
  IF (p_CALCULATE_PRICE_FLAG is not null) THEN
    l_order_line_tbl(i).CALCULATE_PRICE_FLAG := p_CALCULATE_PRICE_FLAG(i);
  END IF;
  IF (p_UPGRADED_FLAG is not null) THEN
    l_order_line_tbl(i).UPGRADED_FLAG := p_UPGRADED_FLAG(i);
  END IF;
  IF ((p_REVENUE_AMOUNT is not null) and ((p_REVENUE_AMOUNT(i) is null) or (p_REVENUE_AMOUNT(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).REVENUE_AMOUNT := p_REVENUE_AMOUNT(i);
  END IF;
  IF ((p_FULFILLMENT_DATE is not null) and ((p_FULFILLMENT_DATE(i) is null) or (p_FULFILLMENT_DATE(i) <> ROSETTA_G_MISS_DATE))) THEN
    l_order_line_tbl(i).FULFILLMENT_DATE := p_FULFILLMENT_DATE(i);
  END IF;
  IF (p_PREFERRED_GRADE is not null) THEN
    l_order_line_tbl(i).PREFERRED_GRADE := p_PREFERRED_GRADE(i);
  END IF;
  IF ((p_ORDERED_QUANTITY2 is not null) and ((p_ORDERED_QUANTITY2(i) is null) or (p_ORDERED_QUANTITY2(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORDERED_QUANTITY2 := p_ORDERED_QUANTITY2(i);
  END IF;
  IF (p_ORDERED_QUANTITY_UOM2 is not null) THEN
    l_order_line_tbl(i).ORDERED_QUANTITY_UOM2 := p_ORDERED_QUANTITY_UOM2(i);
  END IF;
  IF ((p_SHIPPING_QUANTITY2 is not null) and ((p_SHIPPING_QUANTITY2(i) is null) or (p_SHIPPING_QUANTITY2(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIPPING_QUANTITY2 := p_SHIPPING_QUANTITY2(i);
  END IF;
  IF ((p_CANCELLED_QUANTITY2 is not null) and ((p_CANCELLED_QUANTITY2(i) is null) or (p_CANCELLED_QUANTITY2(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).CANCELLED_QUANTITY2 := p_CANCELLED_QUANTITY2(i);
  END IF;
  IF ((p_SHIPPED_QUANTITY2 is not null) and ((p_SHIPPED_QUANTITY2(i) is null) or (p_SHIPPED_QUANTITY2(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).SHIPPED_QUANTITY2 := p_SHIPPED_QUANTITY2(i);
  END IF;
  IF (p_SHIPPING_QUANTITY_UOM2 is not null) THEN
    l_order_line_tbl(i).SHIPPING_QUANTITY_UOM2 := p_SHIPPING_QUANTITY_UOM2(i);
  END IF;
  IF ((p_FULFILLED_QUANTITY2 is not null) and ((p_FULFILLED_QUANTITY2(i) is null) or (p_FULFILLED_QUANTITY2(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).FULFILLED_QUANTITY2 := p_FULFILLED_QUANTITY2(i);
  END IF;
  IF ((p_MFG_LEAD_TIME is not null) and ((p_MFG_LEAD_TIME(i) is null) or (p_MFG_LEAD_TIME(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).MFG_LEAD_TIME := p_MFG_LEAD_TIME(i);
  END IF;
  IF ((p_LOCK_CONTROL is not null) and ((p_LOCK_CONTROL(i) is null) or (p_LOCK_CONTROL(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LOCK_CONTROL := p_LOCK_CONTROL(i);
  END IF;
  IF (p_SUBINVENTORY is not null) THEN
    l_order_line_tbl(i).SUBINVENTORY := p_SUBINVENTORY(i);
  END IF;
  IF ((p_UNIT_LIST_PRICE_PER_PQTY is not null) and ((p_UNIT_LIST_PRICE_PER_PQTY(i) is null) or (p_UNIT_LIST_PRICE_PER_PQTY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_LIST_PRICE_PER_PQTY := p_UNIT_LIST_PRICE_PER_PQTY(i);
  END IF;
  IF ((p_UNIT_SELL_PRICE_PER_PQTY is not null) and ((p_UNIT_SELL_PRICE_PER_PQTY(i) is null) or (p_UNIT_SELL_PRICE_PER_PQTY(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).UNIT_SELLING_PRICE_PER_PQTY := p_UNIT_SELL_PRICE_PER_PQTY(i);
  END IF;
  IF (p_PRICE_REQUEST_CODE is not null) THEN
    l_order_line_tbl(i).PRICE_REQUEST_CODE := p_PRICE_REQUEST_CODE(i);
  END IF;
  IF ((p_ORIGINAL_INVENTORY_ITEM_ID is not null) and ((p_ORIGINAL_INVENTORY_ITEM_ID(i) is null) or (p_ORIGINAL_INVENTORY_ITEM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORIGINAL_INVENTORY_ITEM_ID := p_ORIGINAL_INVENTORY_ITEM_ID(i);
  END IF;
  IF ((p_ORIGINAL_ORDERED_ITEM_ID is not null) and ((p_ORIGINAL_ORDERED_ITEM_ID(i) is null) or (p_ORIGINAL_ORDERED_ITEM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ORIGINAL_ORDERED_ITEM_ID := p_ORIGINAL_ORDERED_ITEM_ID(i);
  END IF;
  IF (p_ORIGINAL_ORDERED_ITEM is not null) THEN
    l_order_line_tbl(i).ORIGINAL_ORDERED_ITEM := p_ORIGINAL_ORDERED_ITEM(i);
  END IF;
  IF (p_ORIGINAL_ITEM_IDENTIF_TYPE is not null) THEN
    l_order_line_tbl(i).ORIGINAL_ITEM_IDENTIFIER_TYPE := p_ORIGINAL_ITEM_IDENTIF_TYPE(i);
  END IF;
  IF (p_ITEM_SUBSTIT_TYPE_CODE is not null) THEN
    l_order_line_tbl(i).ITEM_SUBSTITUTION_TYPE_CODE := p_ITEM_SUBSTIT_TYPE_CODE(i);
  END IF;
  IF (p_OVERRIDE_ATP_DATE_CODE is not null) THEN
    l_order_line_tbl(i).OVERRIDE_ATP_DATE_CODE := p_OVERRIDE_ATP_DATE_CODE(i);
  END IF;
  IF ((p_LATE_DEMAND_PENALTY_FACTOR is not null) and ((p_LATE_DEMAND_PENALTY_FACTOR(i) is null) or (p_LATE_DEMAND_PENALTY_FACTOR(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).LATE_DEMAND_PENALTY_FACTOR := p_LATE_DEMAND_PENALTY_FACTOR(i);
  END IF;
  IF ((p_ACCOUNTING_RULE_DURATION is not null) and ((p_ACCOUNTING_RULE_DURATION(i) is null) or (p_ACCOUNTING_RULE_DURATION(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ACCOUNTING_RULE_DURATION := p_ACCOUNTING_RULE_DURATION(i);
  END IF;

 IF ((p_top_model_line_index is not null) and ((p_top_model_line_index(i) is null) or (p_top_model_line_index(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).top_model_line_index := p_top_model_line_index(i);
  END IF;

  IF (p_top_model_line_ref is not null) THEN
    l_order_line_tbl(i).top_model_line_ref := p_top_model_line_ref(i);
  END IF;

  /*IF ((p_unit_cost is not null) and ((p_unit_cost(i) is null) or (p_unit_cost(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).unit_cost := p_unit_cost(i);
  END IF;

  IF (p_xml_transaction_type_code is not null) THEN
    l_order_line_tbl(i).xml_transaction_type_code := p_xml_transaction_type_code(i);
  END IF;*/

  IF ((p_Sold_to_address_id is not null) and ((p_Sold_to_address_id(i) is null) or (p_Sold_to_address_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).Sold_to_address_id := p_Sold_to_address_id(i);
  END IF;

  IF (p_Split_Action_Code is not null) THEN
    l_order_line_tbl(i).Split_Action_Code := p_Split_Action_Code(i);
  END IF;

  IF (p_split_from_line_ref is not null) THEN
    l_order_line_tbl(i).split_from_line_ref := p_split_from_line_ref(i);
  END IF;

  IF (p_split_from_shipment_ref is not null) THEN
    l_order_line_tbl(i).split_from_shipment_ref := p_split_from_shipment_ref(i);
  END IF;

  IF (p_status_flag is not null) THEN
    l_order_line_tbl(i).status_flag := p_status_flag(i);
  END IF;

  IF (p_ship_from_edi_loc_code is not null) THEN
    l_order_line_tbl(i).ship_from_edi_location_code := p_ship_from_edi_loc_code(i);
  END IF;

  IF (p_ship_set is not null) THEN
    l_order_line_tbl(i).ship_set := p_ship_set(i);
  END IF;

  IF (p_Ship_to_address_code is not null) THEN
    l_order_line_tbl(i).Ship_to_address_code := p_Ship_to_address_code(i);
  END IF;

  IF (p_Ship_to_address_id is not null) THEN
    l_order_line_tbl(i).Ship_to_address_id := p_Ship_to_address_id(i);
  END IF;

  IF ((p_ship_to_customer_id is not null) and ((p_ship_to_customer_id(i) is null) or (p_ship_to_customer_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).ship_to_customer_id := p_ship_to_customer_id(i);
  END IF;

  IF (p_ship_to_edi_location_code is not null) THEN
    l_order_line_tbl(i).ship_to_edi_location_code := p_ship_to_edi_location_code(i);
  END IF;

  IF ((p_service_ref_line_number is not null) and ((p_service_ref_line_number(i) is null) or (p_service_ref_line_number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).service_ref_line_number := p_service_ref_line_number(i);
  END IF;

  IF ((p_service_ref_option_number is not null) and ((p_service_ref_option_number(i) is null) or (p_service_ref_option_number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).service_ref_option_number := p_service_ref_option_number(i);
  END IF;

  IF ((p_service_ref_order_number is not null) and ((p_service_ref_order_number(i) is null) or (p_service_ref_order_number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).service_ref_order_number := p_service_ref_order_number(i);
  END IF;

  IF ((p_service_ref_ship_number is not null) and ((p_service_ref_ship_number(i) is null) or (p_service_ref_ship_number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).service_ref_shipment_number := p_service_ref_ship_number(i);
  END IF;

  IF (p_service_reference_line is not null) THEN
    l_order_line_tbl(i).service_reference_line := p_service_reference_line(i);
  END IF;

  IF (p_service_reference_order is not null) THEN
    l_order_line_tbl(i).service_reference_order := p_service_reference_order(i);
  END IF;

  IF (p_service_reference_system is not null) THEN
    l_order_line_tbl(i).service_reference_system := p_service_reference_system(i);
  END IF;

  IF ((p_reserved_quantity is not null) and ((p_reserved_quantity(i) is null) or (p_reserved_quantity(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).reserved_quantity := p_reserved_quantity(i);
  END IF;

  IF (p_return_status is not null) THEN
    l_order_line_tbl(i).return_status := p_return_status(i);
  END IF;

  IF (p_schedule_action_code is not null) THEN
    l_order_line_tbl(i).schedule_action_code := p_schedule_action_code(i);
  END IF;

  IF ((p_service_line_index is not null) and ((p_service_line_index(i) is null) or (p_service_line_index(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).service_line_index := p_service_line_index(i);
  END IF;

  IF ((p_intermed_ship_to_cont_id is not null) and ((p_intermed_ship_to_cont_id(i) is null) or (p_intermed_ship_to_cont_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).intermed_ship_to_contact_id := p_intermed_ship_to_cont_id(i);
  END IF;

  IF ((p_intermed_ship_to_org_id is not null) and ((p_intermed_ship_to_org_id(i) is null) or (p_intermed_ship_to_org_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).intermed_ship_to_org_id := p_intermed_ship_to_org_id(i);
  END IF;

  IF ((p_Invoice_address_id is not null) and ((p_Invoice_address_id(i) is null) or (p_Invoice_address_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).Invoice_address_id := p_Invoice_address_id(i);
  END IF;

  IF ((p_invoice_to_customer_id is not null) and ((p_invoice_to_customer_id(i) is null) or (p_invoice_to_customer_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).invoice_to_customer_id := p_invoice_to_customer_id(i);
  END IF;

 /* IF ((p_item_relationship_type is not null) and ((p_item_relationship_type(i) is null) or (p_item_relationship_type(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).item_relationship_type := p_item_relationship_type(i);
  END IF;*/

  IF ((p_link_to_line_index is not null) and ((p_link_to_line_index(i) is null) or (p_link_to_line_index(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).link_to_line_index := p_link_to_line_index(i);
  END IF;

  IF (p_link_to_line_ref is not null) THEN
    l_order_line_tbl(i).link_to_line_ref := p_link_to_line_ref(i);
  END IF;

  IF (p_db_flag is not null) THEN
    l_order_line_tbl(i).db_flag := p_db_flag(i);
  END IF;

  IF ((p_deliver_to_customer_id is not null) and ((p_deliver_to_customer_id(i) is null) or (p_deliver_to_customer_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).deliver_to_customer_id := p_deliver_to_customer_id(i);
  END IF;

  IF (p_fulfillment_set is not null) THEN
    l_order_line_tbl(i).fulfillment_set := p_fulfillment_set(i);
  END IF;

  IF ((p_fulfillment_set_id is not null) and ((p_fulfillment_set_id(i) is null) or (p_fulfillment_set_id(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).fulfillment_set_id := p_fulfillment_set_id(i);
  END IF;

  IF (p_change_comments is not null) THEN
    l_order_line_tbl(i).change_comments := p_change_comments(i);
  END IF;

  IF (p_change_reason is not null) THEN
    l_order_line_tbl(i).change_reason := p_change_reason(i);
  END IF;

  IF (p_change_request_code is not null) THEN
    l_order_line_tbl(i).change_request_code := p_change_request_code(i);
  END IF;

  IF (p_Bill_to_Edi_Location_Code is not null) THEN
    l_order_line_tbl(i).Bill_to_Edi_Location_Code := p_Bill_to_Edi_Location_Code(i);
  END IF;

  /*IF ((p_Blanket_Line_Number is not null) and ((p_Blanket_Line_Number(i) is null) or (p_Blanket_Line_Number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).Blanket_Line_Number := p_Blanket_Line_Number(i);
  END IF;

  IF ((p_Blanket_Number is not null) and ((p_Blanket_Number(i) is null) or (p_Blanket_Number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).Blanket_Number := p_Blanket_Number(i);
  END IF;

  IF ((p_Blanket_Version_Number is not null) and ((p_Blanket_Version_Number(i) is null) or (p_Blanket_Version_Number(i) <> ROSETTA_G_MISS_NUM))) THEN
    l_order_line_tbl(i).Blanket_Version_Number := p_Blanket_Version_Number(i);
  END IF;*/

  IF (p_arrival_set is not null) THEN
    l_order_line_tbl(i).arrival_set := p_arrival_set(i);
  END IF;

 /* IF (p_attribute16 is not null) THEN
    l_order_line_tbl(i).attribute16 := p_attribute16(i);
  END IF;

  IF (p_attribute17 is not null) THEN
    l_order_line_tbl(i).attribute17 := p_attribute17(i);
  END IF;

  IF (p_attribute18 is not null) THEN
    l_order_line_tbl(i).attribute18 := p_attribute18(i);
  END IF;

  IF (p_attribute19 is not null) THEN
    l_order_line_tbl(i).attribute19 := p_attribute19(i);
  END IF;

  IF (p_attribute20 is not null) THEN
    l_order_line_tbl(i).attribute20 := p_attribute20(i);
  END IF;*/

 END LOOP;

   RETURN l_order_line_tbl;

 ELSE
   RETURN OE_ORDER_PUB.G_MISS_LINE_TBL; --empty qte_line arrays passed in


   END IF; --end if for l_table_siz
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct LineRecord package body - End');
 END IF;

END Construct_Line_Tbl;


Function Construct_Hdr_Tbl(
   p_HEADER_ID                        IN NUMBER         := FND_API.G_MISS_NUM,
   p_OPERATION                        IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_ORG_ID                           IN NUMBER         := FND_API.G_MISS_NUM,
   p_ORDER_TYPE_ID                    IN NUMBER         := FND_API.G_MISS_NUM,
   p_ORDER_NUMBER                     IN NUMBER         := FND_API.G_MISS_NUM,
   p_VERSION_NUMBER                   IN NUMBER         := FND_API.G_MISS_NUM,
   p_EXPIRATION_DATE                  IN DATE           := FND_API.G_MISS_DATE,
   p_ORDER_SOURCE_ID                  IN NUMBER         := FND_API.G_MISS_NUM,
   p_SOURCE_DOCUMENT_TYPE_ID          IN NUMBER         := FND_API.G_MISS_NUM,
   p_ORIG_SYS_DOCUMENT_REF            IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_SOURCE_DOCUMENT_ID               IN NUMBER         := FND_API.G_MISS_NUM,
   p_ORDERED_DATE                     IN DATE           := FND_API.G_MISS_DATE,
   p_REQUEST_DATE                     IN DATE           := FND_API.G_MISS_DATE,
   p_PRICING_DATE                     IN DATE           := FND_API.G_MISS_DATE,
   p_SHIPMENT_PRIORITY_CODE           IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_DEMAND_CLASS_CODE                IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_PRICE_LIST_ID                    IN NUMBER         := FND_API.G_MISS_NUM,
   p_MINISITE_ID                      IN NUMBER         := FND_API.G_MISS_NUM,  -- bug 8337371, scnagara
   p_TAX_EXEMPT_FLAG                  IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_TAX_EXEMPT_NUMBER                IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_TAX_EXEMPT_REASON_CODE           IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_CONVERSION_RATE                  IN NUMBER         := FND_API.G_MISS_NUM,
   p_CONVERSION_TYPE_CODE             IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_CONVERSION_RATE_DATE             IN DATE           := FND_API.G_MISS_DATE,
   p_PARTIAL_SHIPMENTS_ALLOWED        IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_SHIP_TOLERANCE_ABOVE             IN NUMBER         := FND_API.G_MISS_NUM,
   p_SHIP_TOLERANCE_BELOW             IN NUMBER         := FND_API.G_MISS_NUM,
   p_TRANSACTIONAL_CURR_CODE          IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_AGREEMENT_ID                     IN NUMBER         := FND_API.G_MISS_NUM,
   p_TAX_POINT_CODE                   IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_CUST_PO_NUMBER                   IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_INVOICING_RULE_ID                IN NUMBER         := FND_API.G_MISS_NUM,
   p_ACCOUNTING_RULE_ID               IN NUMBER         := FND_API.G_MISS_NUM,
   p_PAYMENT_TERM_ID                  IN NUMBER         := FND_API.G_MISS_NUM,
   p_SHIPPING_METHOD_CODE             IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_FREIGHT_CARRIER_CODE             IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_FOB_POINT_CODE                   IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_FREIGHT_TERMS_CODE               IN VARCHAR2       := FND_API.G_MISS_CHAR,
   p_SOLD_FROM_ORG_ID                 IN NUMBER         := FND_API.G_MISS_NUM,
   p_SOLD_TO_ORG_ID                   IN NUMBER         := FND_API.G_MISS_NUM,
   p_SHIP_FROM_ORG_ID                 IN NUMBER         := FND_API.G_MISS_NUM,
   p_SHIP_TO_ORG_ID                   IN NUMBER         := FND_API.G_MISS_NUM,
   p_INVOICE_TO_ORG_ID                IN NUMBER         := FND_API.G_MISS_NUM,
   p_DELIVER_TO_ORG_ID                IN NUMBER         := FND_API.G_MISS_NUM,
   p_SOLD_TO_CONTACT_ID               IN NUMBER         := FND_API.G_MISS_NUM,
   p_SHIP_TO_CONTACT_ID               IN NUMBER         := FND_API.G_MISS_NUM,
   p_INVOICE_TO_CONTACT_ID            IN NUMBER         := FND_API.G_MISS_NUM,
   p_DELIVER_TO_CONTACT_ID            IN NUMBER         := FND_API.G_MISS_NUM,
   p_CREATION_DATE                    IN DATE           := FND_API.G_MISS_DATE,
   p_CREATED_BY                       IN NUMBER         := FND_API.G_MISS_NUM,
   p_LAST_UPDATED_BY                  IN NUMBER         := FND_API.G_MISS_NUM,
   p_LAST_UPDATE_DATE                 IN DATE           := FND_API.G_MISS_DATE,
   p_LAST_UPDATE_LOGIN                IN NUMBER         := FND_API.G_MISS_NUM,
   p_PROGRAM_APPLICATION_ID           IN NUMBER         := FND_API.G_MISS_NUM,
   p_PROGRAM_ID                       IN NUMBER         := FND_API.G_MISS_NUM,
   p_PROGRAM_UPDATE_DATE              IN DATE             := FND_API.G_MISS_DATE,
   p_REQUEST_ID                       IN NUMBER           := FND_API.G_MISS_NUM,
   p_CONTEXT                          IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE1                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE2                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE3                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE4                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE5                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE6                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE7                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE8                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE9                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE10                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE11                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE12                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE13                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE14                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ATTRIBUTE15                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE_CATEGORY        IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE1                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE2                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE3                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE4                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE5                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE6                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE7                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE8                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE9                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE10               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE11               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE12               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE13               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE14               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE15               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE16               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE17               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE18               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE19               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_GLOBAL_ATTRIBUTE20               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CANCELLED_FLAG                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_OPEN_FLAG                        IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_BOOKED_FLAG                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_SALESREP_ID                      IN NUMBER           := FND_API.G_MISS_NUM,
   p_RETURN_REASON_CODE               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ORDER_DATE_TYPE_CODE             IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_EARLIEST_SCHEDULE_LIMIT          IN NUMBER           := FND_API.G_MISS_NUM,
   p_LATEST_SCHEDULE_LIMIT            IN NUMBER           := FND_API.G_MISS_NUM,
   p_PAYMENT_TYPE_CODE                IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_PAYMENT_AMOUNT                   IN NUMBER           := FND_API.G_MISS_NUM,
   p_CHECK_NUMBER                     IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CREDIT_CARD_CODE                 IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CREDIT_CARD_HOLDER_NAME          IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CREDIT_CARD_NUMBER               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CREDIT_CARD_EXPIR_DATE           IN DATE             := FND_API.G_MISS_DATE,
   p_CREDIT_CARD_APPROVAL_CODE        IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_SALES_CHANNEL_CODE               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_FIRST_ACK_CODE                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_FIRST_ACK_DATE                   IN DATE             := FND_API.G_MISS_DATE,
   p_LAST_ACK_CODE                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_LAST_ACK_DATE                    IN DATE             := FND_API.G_MISS_DATE,
   p_ORDER_CATEGORY_CODE              IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CHANGE_SEQUENCE                  IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_DROP_SHIP_FLAG                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CUSTOMER_PAYMENT_TERM_ID         IN NUMBER           := FND_API.G_MISS_NUM,
   p_SHIPPING_INSTRUCTIONS            IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_PACKING_INSTRUCTIONS             IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_CONTEXT                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE1                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE2                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE3                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE4                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE5                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE6                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE7                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE8                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE9                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE10                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE11                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE12                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE13                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE14                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_TP_ATTRIBUTE15                   IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_FLOW_STATUS_CODE                 IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_MARKETING_SOURCE_CODE_ID         IN NUMBER           := FND_API.G_MISS_NUM,
   p_CREDIT_CARD_APPROVAL_DATE        IN DATE             := FND_API.G_MISS_DATE,
   p_UPGRADED_FLAG                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_CUSTOMER_PREF_SET_CODE           IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_BOOKED_DATE                      IN DATE             := FND_API.G_MISS_DATE,
   p_LOCK_CONTROL                     IN NUMBER           := FND_API.G_MISS_NUM,
   p_PRICE_REQUEST_CODE               IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_XML_MESSAGE_ID                   IN NUMBER           := FND_API.G_MISS_NUM,
   p_ACCOUNTING_RULE_DURATION         IN NUMBER           := FND_API.G_MISS_NUM,

   p_attribute16                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_attribute17                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_attribute18                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_attribute19                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_attribute20                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_bill_to_edi_location_code        IN VARCHAR2         := FND_API.G_MISS_CHAR,

   p_Blanket_Number                   IN NUMBER           := FND_API.G_MISS_NUM,
   p_change_comments                  IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_change_reason                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_change_request_code              IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_db_flag                          IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_Default_Fulfillment_set          IN VARCHAR2         := FND_API.G_MISS_CHAR,

   p_deliver_to_customer_id           IN NUMBER           := FND_API.G_MISS_NUM,
   p_force_apply_flag                 IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_Fulfillment_Set_Name             IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_INVOICE_ADDRESS_ID               IN NUMBER           := FND_API.G_MISS_NUM,
   p_invoice_to_customer_id           IN NUMBER           := FND_API.G_MISS_NUM,
   p_SHIP_FROM_ADDRESS_ID             IN NUMBER           := FND_API.G_MISS_NUM,
   p_ship_from_edi_loc_code           IN VARCHAR2         := FND_API.G_MISS_CHAR,

   p_Line_Set_Name                    IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_ready_flag                       IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_SHIP_TO_ADDRESS_CODE             IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_SHIP_TO_ADDRESS_ID               IN NUMBER           := FND_API.G_MISS_NUM,
   p_ship_to_customer_id              IN NUMBER           := FND_API.G_MISS_NUM,
   p_ship_to_edi_location_code        IN VARCHAR2         := FND_API.G_MISS_CHAR,

   p_SOLD_TO_ADDRESS_ID               IN NUMBER           := FND_API.G_MISS_NUM,
   p_sold_to_edi_location_code        IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_sold_to_phone_id                 IN NUMBER           := FND_API.G_MISS_NUM,
   p_status_flag                      IN VARCHAR2         := FND_API.G_MISS_CHAR,
   p_xml_transaction_type_code        IN VARCHAR2         := FND_API.G_MISS_CHAR

)

RETURN OE_Order_PUB.Header_Rec_Type
IS
    l_order_header_rec OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC;
BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct HeaderRecord package body - Begin');
 END IF;

    IF p_HEADER_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.HEADER_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.HEADER_ID := p_HEADER_ID;
    END IF;

    l_order_header_rec.OPERATION   := p_OPERATION;

    IF p_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ORG_ID := p_ORG_ID;
    END IF;
    IF p_ORDER_TYPE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ORDER_TYPE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ORDER_TYPE_ID := p_ORDER_TYPE_ID;
    END IF;
    IF p_ORDER_NUMBER = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ORDER_NUMBER := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ORDER_NUMBER := p_ORDER_NUMBER;
    END IF;
    IF p_VERSION_NUMBER = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.VERSION_NUMBER := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.VERSION_NUMBER := p_VERSION_NUMBER;
    END IF;
    IF p_EXPIRATION_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.EXPIRATION_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.EXPIRATION_DATE := p_EXPIRATION_DATE;
    END IF;
    IF p_ORDER_SOURCE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ORDER_SOURCE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ORDER_SOURCE_ID := p_ORDER_SOURCE_ID;
    END IF;
    IF p_SOURCE_DOCUMENT_TYPE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SOURCE_DOCUMENT_TYPE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SOURCE_DOCUMENT_TYPE_ID := p_SOURCE_DOCUMENT_TYPE_ID;
    END IF;

    l_order_header_rec.ORIG_SYS_DOCUMENT_REF  := p_ORIG_SYS_DOCUMENT_REF;

    IF p_SOURCE_DOCUMENT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SOURCE_DOCUMENT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SOURCE_DOCUMENT_ID := p_SOURCE_DOCUMENT_ID;
    END IF;
    IF p_ORDERED_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.ORDERED_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.ORDERED_DATE := p_ORDERED_DATE;
    END IF;
    IF p_REQUEST_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.REQUEST_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.REQUEST_DATE := p_REQUEST_DATE;
    END IF;
    IF p_PRICING_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.PRICING_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.PRICING_DATE := p_PRICING_DATE;
    END IF;
    l_order_header_rec.SHIPMENT_PRIORITY_CODE  := p_SHIPMENT_PRIORITY_CODE;
    l_order_header_rec.DEMAND_CLASS_CODE  := p_DEMAND_CLASS_CODE;
    IF p_PRICE_LIST_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.PRICE_LIST_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.PRICE_LIST_ID := p_PRICE_LIST_ID;
    END IF;
    IF p_MINISITE_ID = ROSETTA_G_MISS_NUM THEN  -- bug 8337371, scnagara
        l_order_header_rec.Minisite_Id := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.Minisite_Id := p_MINISITE_ID;
    END IF;
    l_order_header_rec.TAX_EXEMPT_FLAG  := p_TAX_EXEMPT_FLAG;
    l_order_header_rec.TAX_EXEMPT_NUMBER  := p_TAX_EXEMPT_NUMBER;
    l_order_header_rec.TAX_EXEMPT_REASON_CODE  := p_TAX_EXEMPT_REASON_CODE;
    IF p_CONVERSION_RATE = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.CONVERSION_RATE := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.CONVERSION_RATE := p_CONVERSION_RATE;
    END IF;
    l_order_header_rec.CONVERSION_TYPE_CODE  := p_CONVERSION_TYPE_CODE;
    IF p_CONVERSION_RATE_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.CONVERSION_RATE_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.CONVERSION_RATE_DATE := p_CONVERSION_RATE_DATE;
    END IF;
    l_order_header_rec.PARTIAL_SHIPMENTS_ALLOWED  := p_PARTIAL_SHIPMENTS_ALLOWED;
    IF p_SHIP_TOLERANCE_ABOVE = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SHIP_TOLERANCE_ABOVE := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SHIP_TOLERANCE_ABOVE := p_SHIP_TOLERANCE_ABOVE;
    END IF;
    IF p_SHIP_TOLERANCE_BELOW = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SHIP_TOLERANCE_BELOW := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SHIP_TOLERANCE_BELOW := p_SHIP_TOLERANCE_BELOW;
    END IF;
    l_order_header_rec.TRANSACTIONAL_CURR_CODE  := p_TRANSACTIONAL_CURR_CODE;
    IF p_AGREEMENT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.AGREEMENT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.AGREEMENT_ID := p_AGREEMENT_ID;
    END IF;
    l_order_header_rec.TAX_POINT_CODE  := p_TAX_POINT_CODE;
    l_order_header_rec.CUST_PO_NUMBER  := p_CUST_PO_NUMBER;
    IF p_INVOICING_RULE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.INVOICING_RULE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.INVOICING_RULE_ID := p_INVOICING_RULE_ID;
    END IF;
    IF p_ACCOUNTING_RULE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ACCOUNTING_RULE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ACCOUNTING_RULE_ID := p_ACCOUNTING_RULE_ID;
    END IF;
    IF p_PAYMENT_TERM_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.PAYMENT_TERM_ID := p_PAYMENT_TERM_ID;
    END IF;
    l_order_header_rec.SHIPPING_METHOD_CODE  := p_SHIPPING_METHOD_CODE;
    l_order_header_rec.FREIGHT_CARRIER_CODE  := p_FREIGHT_CARRIER_CODE;
    l_order_header_rec.FOB_POINT_CODE  := p_FOB_POINT_CODE;
    l_order_header_rec.FREIGHT_TERMS_CODE  := p_FREIGHT_TERMS_CODE;
    IF p_SOLD_FROM_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SOLD_FROM_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SOLD_FROM_ORG_ID := p_SOLD_FROM_ORG_ID;
    END IF;
    IF p_SOLD_TO_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SOLD_TO_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SOLD_TO_ORG_ID := p_SOLD_TO_ORG_ID;
    END IF;
    IF p_SHIP_FROM_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SHIP_FROM_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SHIP_FROM_ORG_ID := p_SHIP_FROM_ORG_ID;
    END IF;
    IF p_SHIP_TO_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SHIP_TO_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SHIP_TO_ORG_ID := p_SHIP_TO_ORG_ID;
    END IF;
    IF p_INVOICE_TO_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.INVOICE_TO_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.INVOICE_TO_ORG_ID := p_INVOICE_TO_ORG_ID;
    END IF;
    IF p_DELIVER_TO_ORG_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.DELIVER_TO_ORG_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.DELIVER_TO_ORG_ID := p_DELIVER_TO_ORG_ID;
    END IF;
    IF p_SOLD_TO_CONTACT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SOLD_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SOLD_TO_CONTACT_ID := p_SOLD_TO_CONTACT_ID;
    END IF;
    IF p_SHIP_TO_CONTACT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SHIP_TO_CONTACT_ID := p_SHIP_TO_CONTACT_ID;
    END IF;
    IF p_INVOICE_TO_CONTACT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.INVOICE_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.INVOICE_TO_CONTACT_ID := p_INVOICE_TO_CONTACT_ID;
    END IF;
    IF p_DELIVER_TO_CONTACT_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.DELIVER_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.DELIVER_TO_CONTACT_ID := p_DELIVER_TO_CONTACT_ID;
    END IF;
    IF p_CREATION_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.CREATION_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.CREATION_DATE := p_CREATION_DATE;
    END IF;
    IF p_CREATED_BY = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.CREATED_BY := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.CREATED_BY := p_CREATED_BY;
    END IF;
    IF p_LAST_UPDATED_BY = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.LAST_UPDATED_BY := p_LAST_UPDATED_BY;
    END IF;
    IF p_LAST_UPDATE_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.LAST_UPDATE_DATE := p_LAST_UPDATE_DATE;
    END IF;
    IF p_LAST_UPDATE_LOGIN = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.LAST_UPDATE_LOGIN := p_LAST_UPDATE_LOGIN;
    END IF;
    IF p_PROGRAM_APPLICATION_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.PROGRAM_APPLICATION_ID := p_PROGRAM_APPLICATION_ID;
    END IF;
    IF p_PROGRAM_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.PROGRAM_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.PROGRAM_ID := p_PROGRAM_ID;
    END IF;
    IF p_PROGRAM_UPDATE_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.PROGRAM_UPDATE_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.PROGRAM_UPDATE_DATE := p_PROGRAM_UPDATE_DATE;
    END IF;
    IF p_REQUEST_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.REQUEST_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.REQUEST_ID := p_REQUEST_ID;
    END IF;
    l_order_header_rec.CONTEXT  := p_CONTEXT;
    l_order_header_rec.ATTRIBUTE1  := p_ATTRIBUTE1;
    l_order_header_rec.ATTRIBUTE2  := p_ATTRIBUTE2;
    l_order_header_rec.ATTRIBUTE3  := p_ATTRIBUTE3;
    l_order_header_rec.ATTRIBUTE4  := p_ATTRIBUTE4;
    l_order_header_rec.ATTRIBUTE5  := p_ATTRIBUTE5;
    l_order_header_rec.ATTRIBUTE6  := p_ATTRIBUTE6;
    l_order_header_rec.ATTRIBUTE7  := p_ATTRIBUTE7;
    l_order_header_rec.ATTRIBUTE8  := p_ATTRIBUTE8;
    l_order_header_rec.ATTRIBUTE9  := p_ATTRIBUTE9;
    l_order_header_rec.ATTRIBUTE10  := p_ATTRIBUTE10;
    l_order_header_rec.ATTRIBUTE11  := p_ATTRIBUTE11;
    l_order_header_rec.ATTRIBUTE12  := p_ATTRIBUTE12;
    l_order_header_rec.ATTRIBUTE13  := p_ATTRIBUTE13;
    l_order_header_rec.ATTRIBUTE14  := p_ATTRIBUTE14;
    l_order_header_rec.ATTRIBUTE15  := p_ATTRIBUTE15;
    l_order_header_rec.GLOBAL_ATTRIBUTE_CATEGORY  := p_GLOBAL_ATTRIBUTE_CATEGORY;
    l_order_header_rec.GLOBAL_ATTRIBUTE1  := p_GLOBAL_ATTRIBUTE1;
    l_order_header_rec.GLOBAL_ATTRIBUTE2  := p_GLOBAL_ATTRIBUTE2;
    l_order_header_rec.GLOBAL_ATTRIBUTE3  := p_GLOBAL_ATTRIBUTE3;
    l_order_header_rec.GLOBAL_ATTRIBUTE4  := p_GLOBAL_ATTRIBUTE4;
    l_order_header_rec.GLOBAL_ATTRIBUTE5  := p_GLOBAL_ATTRIBUTE5;
    l_order_header_rec.GLOBAL_ATTRIBUTE6  := p_GLOBAL_ATTRIBUTE6;
    l_order_header_rec.GLOBAL_ATTRIBUTE7  := p_GLOBAL_ATTRIBUTE7;
    l_order_header_rec.GLOBAL_ATTRIBUTE8  := p_GLOBAL_ATTRIBUTE8;
    l_order_header_rec.GLOBAL_ATTRIBUTE9  := p_GLOBAL_ATTRIBUTE9;
    l_order_header_rec.GLOBAL_ATTRIBUTE10  := p_GLOBAL_ATTRIBUTE10;
    l_order_header_rec.GLOBAL_ATTRIBUTE11  := p_GLOBAL_ATTRIBUTE11;
    l_order_header_rec.GLOBAL_ATTRIBUTE12  := p_GLOBAL_ATTRIBUTE12;
    l_order_header_rec.GLOBAL_ATTRIBUTE13  := p_GLOBAL_ATTRIBUTE13;
    l_order_header_rec.GLOBAL_ATTRIBUTE14  := p_GLOBAL_ATTRIBUTE14;
    l_order_header_rec.GLOBAL_ATTRIBUTE15  := p_GLOBAL_ATTRIBUTE15;
    l_order_header_rec.GLOBAL_ATTRIBUTE16  := p_GLOBAL_ATTRIBUTE16;
    l_order_header_rec.GLOBAL_ATTRIBUTE17  := p_GLOBAL_ATTRIBUTE17;
    l_order_header_rec.GLOBAL_ATTRIBUTE18  := p_GLOBAL_ATTRIBUTE18;
    l_order_header_rec.GLOBAL_ATTRIBUTE19  := p_GLOBAL_ATTRIBUTE19;
    l_order_header_rec.GLOBAL_ATTRIBUTE20  := p_GLOBAL_ATTRIBUTE20;
    l_order_header_rec.CANCELLED_FLAG  := p_CANCELLED_FLAG;
    l_order_header_rec.OPEN_FLAG  := p_OPEN_FLAG;
    l_order_header_rec.BOOKED_FLAG  := p_BOOKED_FLAG;
    IF p_SALESREP_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.SALESREP_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.SALESREP_ID := p_SALESREP_ID;
    END IF;
    l_order_header_rec.RETURN_REASON_CODE  := p_RETURN_REASON_CODE;
    l_order_header_rec.ORDER_DATE_TYPE_CODE  := p_ORDER_DATE_TYPE_CODE;
    IF p_EARLIEST_SCHEDULE_LIMIT = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.EARLIEST_SCHEDULE_LIMIT := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.EARLIEST_SCHEDULE_LIMIT := p_EARLIEST_SCHEDULE_LIMIT;
    END IF;
    IF p_LATEST_SCHEDULE_LIMIT = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.LATEST_SCHEDULE_LIMIT := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.LATEST_SCHEDULE_LIMIT := p_LATEST_SCHEDULE_LIMIT;
    END IF;
    l_order_header_rec.PAYMENT_TYPE_CODE  := p_PAYMENT_TYPE_CODE;
    IF p_PAYMENT_AMOUNT = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.PAYMENT_AMOUNT := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.PAYMENT_AMOUNT := p_PAYMENT_AMOUNT;
    END IF;
    l_order_header_rec.CHECK_NUMBER  := p_CHECK_NUMBER;
    l_order_header_rec.CREDIT_CARD_CODE  := p_CREDIT_CARD_CODE;
    l_order_header_rec.CREDIT_CARD_HOLDER_NAME  := p_CREDIT_CARD_HOLDER_NAME;
    l_order_header_rec.CREDIT_CARD_NUMBER  := p_CREDIT_CARD_NUMBER;

    IF p_CREDIT_CARD_EXPIR_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.CREDIT_CARD_EXPIRATION_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.CREDIT_CARD_EXPIRATION_DATE := p_CREDIT_CARD_EXPIR_DATE;
    END IF;
    l_order_header_rec.CREDIT_CARD_APPROVAL_CODE  :=   p_CREDIT_CARD_APPROVAL_CODE;
    l_order_header_rec.SALES_CHANNEL_CODE         :=   p_SALES_CHANNEL_CODE;
    l_order_header_rec.FIRST_ACK_CODE             :=  p_FIRST_ACK_CODE;
    IF p_FIRST_ACK_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.FIRST_ACK_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.FIRST_ACK_DATE := p_FIRST_ACK_DATE;
    END IF;

    l_order_header_rec.LAST_ACK_CODE             :=  p_LAST_ACK_CODE;
    IF p_LAST_ACK_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.LAST_ACK_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.LAST_ACK_DATE := p_LAST_ACK_DATE;
    END IF;
    l_order_header_rec.ORDER_CATEGORY_CODE := p_ORDER_CATEGORY_CODE;
    l_order_header_rec.CHANGE_SEQUENCE    := p_CHANGE_SEQUENCE;
    l_order_header_rec.DROP_SHIP_FLAG     := p_DROP_SHIP_FLAG;

    IF p_CUSTOMER_PAYMENT_TERM_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.CUSTOMER_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.CUSTOMER_PAYMENT_TERM_ID := p_CUSTOMER_PAYMENT_TERM_ID;
    END IF;
    l_order_header_rec.SHIPPING_INSTRUCTIONS     := p_SHIPPING_INSTRUCTIONS;
    l_order_header_rec.PACKING_INSTRUCTIONS      := p_PACKING_INSTRUCTIONS;
    l_order_header_rec.TP_CONTEXT                := p_TP_CONTEXT;
    l_order_header_rec.TP_ATTRIBUTE1             := p_TP_ATTRIBUTE1;
    l_order_header_rec.TP_ATTRIBUTE2             := p_TP_ATTRIBUTE2;
    l_order_header_rec.TP_ATTRIBUTE3             := p_TP_ATTRIBUTE3;
    l_order_header_rec.TP_ATTRIBUTE4             := p_TP_ATTRIBUTE4;
    l_order_header_rec.TP_ATTRIBUTE5             := p_TP_ATTRIBUTE5;
    l_order_header_rec.TP_ATTRIBUTE6             := p_TP_ATTRIBUTE6;
    l_order_header_rec.TP_ATTRIBUTE7             := p_TP_ATTRIBUTE7;
    l_order_header_rec.TP_ATTRIBUTE8             := p_TP_ATTRIBUTE8;
    l_order_header_rec.TP_ATTRIBUTE9             := p_TP_ATTRIBUTE9;
    l_order_header_rec.TP_ATTRIBUTE10            := p_TP_ATTRIBUTE10;
    l_order_header_rec.TP_ATTRIBUTE11            := p_TP_ATTRIBUTE11;
    l_order_header_rec.TP_ATTRIBUTE12            := p_TP_ATTRIBUTE12;
    l_order_header_rec.TP_ATTRIBUTE13            := p_TP_ATTRIBUTE13;
    l_order_header_rec.TP_ATTRIBUTE14            := p_TP_ATTRIBUTE14;
    l_order_header_rec.TP_ATTRIBUTE15            := p_TP_ATTRIBUTE15;

    -- The If condition is checked. because flow_status_code is defaulted to 'entered' in g_miss_header_rec so to avoid overriding.
    IF (p_FLOW_STATUS_CODE IS NOT NULL AND p_FLOW_STATUS_CODE <> FND_API.G_MISS_CHAR) THEN
      l_order_header_rec.FLOW_STATUS_CODE          := p_FLOW_STATUS_CODE;
    END IF;

    IF p_MARKETING_SOURCE_CODE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.MARKETING_SOURCE_CODE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.MARKETING_SOURCE_CODE_ID := p_MARKETING_SOURCE_CODE_ID;
    END IF;


    IF p_CREDIT_CARD_APPROVAL_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.CREDIT_CARD_APPROVAL_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.CREDIT_CARD_APPROVAL_DATE := p_CREDIT_CARD_APPROVAL_DATE;
    END IF;
    l_order_header_rec.UPGRADED_FLAG    := p_UPGRADED_FLAG;
    l_order_header_rec.CUSTOMER_PREFERENCE_SET_CODE    := p_CUSTOMER_PREF_SET_CODE;

    IF p_BOOKED_DATE = ROSETTA_G_MISS_DATE THEN
        l_order_header_rec.BOOKED_DATE := FND_API.G_MISS_DATE;
    ELSE
        l_order_header_rec.BOOKED_DATE := p_BOOKED_DATE;
    END IF;

    IF p_LOCK_CONTROL = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.LOCK_CONTROL := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.LOCK_CONTROL := p_LOCK_CONTROL;
    END IF;
    l_order_header_rec.PRICE_REQUEST_CODE    :=  p_PRICE_REQUEST_CODE;

    IF p_XML_MESSAGE_ID = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.XML_MESSAGE_ID := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.XML_MESSAGE_ID := p_XML_MESSAGE_ID;
    END IF;

    IF p_ACCOUNTING_RULE_DURATION  = ROSETTA_G_MISS_NUM THEN
        l_order_header_rec.ACCOUNTING_RULE_DURATION  := FND_API.G_MISS_NUM;
    ELSE
        l_order_header_rec.ACCOUNTING_RULE_DURATION  := p_ACCOUNTING_RULE_DURATION ;
    END IF;

   /* l_order_header_rec.attribute16  := p_attribute16;
    l_order_header_rec.attribute17  := p_attribute17;
    l_order_header_rec.attribute18  := p_attribute18;
    l_order_header_rec.attribute19  := p_attribute19;
    l_order_header_rec.attribute20  := p_attribute20;*/
    l_order_header_rec.bill_to_edi_location_code  := p_bill_to_edi_location_code;

    /* IF p_Blanket_Number = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.Blanket_Number  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.Blanket_Number  := p_Blanket_Number;
    END IF; */

    l_order_header_rec.change_comments  := p_change_comments;
    l_order_header_rec.change_reason  := p_change_reason;
    l_order_header_rec.change_request_code  := p_change_request_code;
    l_order_header_rec.db_flag  := p_db_flag;
    --l_order_header_rec.Default_Fulfillment_Set  := p_Default_Fulfillment_Set;

    IF p_deliver_to_customer_id = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.deliver_to_customer_id  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.deliver_to_customer_id  := p_deliver_to_customer_id;
    END IF;

    l_order_header_rec.force_apply_flag  := p_force_apply_flag;
    --l_order_header_rec.Fulfillment_Set_Name  := p_Fulfillment_Set_Name;

    IF p_INVOICE_ADDRESS_ID = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.INVOICE_ADDRESS_ID  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.INVOICE_ADDRESS_ID  := p_INVOICE_ADDRESS_ID;
    END IF;

    IF p_invoice_to_customer_id = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.invoice_to_customer_id  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.invoice_to_customer_id  := p_invoice_to_customer_id;
    END IF;

    IF p_SHIP_FROM_ADDRESS_ID = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.SHIP_FROM_ADDRESS_ID  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.SHIP_FROM_ADDRESS_ID  := p_SHIP_FROM_ADDRESS_ID;
    END IF;

    l_order_header_rec.ship_from_edi_location_code  := p_ship_from_edi_loc_code;
    --l_order_header_rec.Line_Set_Name  := p_Line_Set_Name;
    l_order_header_rec.ready_flag  := p_ready_flag;
    l_order_header_rec.SHIP_TO_ADDRESS_CODE  := p_SHIP_TO_ADDRESS_CODE;

    IF p_SHIP_TO_ADDRESS_ID = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.SHIP_TO_ADDRESS_ID  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.SHIP_TO_ADDRESS_ID  := p_SHIP_TO_ADDRESS_ID;
    END IF;

    IF p_ship_to_customer_id = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.ship_to_customer_id  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.ship_to_customer_id  := p_ship_to_customer_id;
    END IF;

    l_order_header_rec.ship_to_edi_location_code  := p_ship_to_edi_location_code;

    IF P_SOLD_TO_ADDRESS_ID = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.SOLD_TO_ADDRESS_ID  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.SOLD_TO_ADDRESS_ID  := p_SOLD_TO_ADDRESS_ID;
    END IF;

    l_order_header_rec.sold_to_edi_location_code  := p_sold_to_edi_location_code;

   /* IF p_sold_to_phone_id = ROSETTA_G_MISS_NUM THEN
      l_order_header_rec.sold_to_phone_id  := FND_API.G_MISS_NUM;
    ELSE
      l_order_header_rec.sold_to_phone_id  := p_sold_to_phone_id;
    END IF;*/

    l_order_header_rec.status_flag  := p_status_flag;
    --l_order_header_rec.xml_transaction_type_code  := p_xml_transaction_type_code;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('In Returns construct HeaderRecord package body - end');
 END IF;

RETURN l_order_header_rec;

END Construct_Hdr_Tbl;


PROCEDURE SaveWrapper(
  x_error_lineids                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
  X_failed_line_ids              OUT NOCOPY JTF_VARCHAR2_TABLE_300 , --3272918
  p_api_version_number           IN  NUMBER                       ,
  p_init_msg_list                IN  VARCHAR2                     ,
  p_commit                       IN  VARCHAR2                      ,
  x_return_status                OUT NOCOPY VARCHAR2               ,
  x_msg_count                    OUT NOCOPY NUMBER                 ,
  x_msg_data                     OUT NOCOPY VARCHAR2               ,
  x_order_header_id              OUT NOCOPY NUMBER                 ,
  x_order_number                 OUT NOCOPY NUMBER                 ,
  x_flow_status_code             OUT NOCOPY VARCHAR2               ,
  x_last_update_date             OUT NOCOPY DATE                   ,
  p_h_HEADER_ID                  IN NUMBER                         ,
  p_h_OPERATION                  IN VARCHAR2                       ,
  p_h_ORG_ID                     IN NUMBER                         ,
  p_h_ORDER_TYPE_ID              IN NUMBER                         ,
  p_h_ORDER_NUMBER               IN NUMBER                         ,
  p_h_VERSION_NUMBER             IN NUMBER                         ,
  p_h_EXPIRATION_DATE            IN DATE                           ,
  p_h_ORDER_SOURCE_ID            IN NUMBER                         ,
  p_h_SOURCE_DOCUMENT_TYPE_ID    IN NUMBER                         ,
  p_h_ORIG_SYS_DOCUMENT_REF      IN VARCHAR2                       ,
  p_h_SOURCE_DOCUMENT_ID         IN NUMBER                         ,
  p_h_ORDERED_DATE               IN DATE                            ,
  p_h_REQUEST_DATE               IN DATE                            ,
  p_h_PRICING_DATE               IN DATE                            ,
  p_h_SHIPMENT_PRIORITY_CODE     IN VARCHAR2                        ,
  p_h_DEMAND_CLASS_CODE          IN VARCHAR2                        ,
  p_h_PRICE_LIST_ID              IN NUMBER                          ,
  p_h_MINISITE_ID                IN NUMBER			    , -- bug 8337371, scnagara
  p_h_TAX_EXEMPT_FLAG            IN VARCHAR2                        ,
  p_h_TAX_EXEMPT_NUMBER          IN VARCHAR2                        ,
  p_h_TAX_EXEMPT_REASON_CODE     IN VARCHAR2                        ,
  p_h_CONVERSION_RATE            IN NUMBER                          ,
  p_h_CONVERSION_TYPE_CODE       IN VARCHAR2                        ,
  p_h_CONVERSION_RATE_DATE       IN DATE                            ,
  p_h_PARTIAL_SHIPMENTS_ALLOWED  IN VARCHAR2                        ,
  p_h_SHIP_TOLERANCE_ABOVE       IN NUMBER                          ,
  p_h_SHIP_TOLERANCE_BELOW       IN NUMBER                          ,
  p_h_TRANSACTIONAL_CURR_CODE    IN VARCHAR2                        ,
  p_h_AGREEMENT_ID               IN NUMBER                          ,
  p_h_TAX_POINT_CODE             IN VARCHAR2                        ,
  p_h_CUST_PO_NUMBER             IN VARCHAR2                        ,
  p_h_INVOICING_RULE_ID          IN NUMBER                         ,
  p_h_ACCOUNTING_RULE_ID         IN NUMBER                         ,
  p_h_PAYMENT_TERM_ID            IN NUMBER                         ,
  p_h_SHIPPING_METHOD_CODE       IN VARCHAR2                        ,
  p_h_FREIGHT_CARRIER_CODE       IN VARCHAR2                        ,
  p_h_FOB_POINT_CODE             IN VARCHAR2                        ,
  p_h_FREIGHT_TERMS_CODE         IN VARCHAR2                        ,
  p_h_SOLD_FROM_ORG_ID           IN NUMBER                         ,
  p_h_SOLD_TO_ORG_ID             IN NUMBER                         ,
  p_h_SHIP_FROM_ORG_ID           IN NUMBER                         ,
  p_h_SHIP_TO_ORG_ID             IN NUMBER                         ,
  p_h_INVOICE_TO_ORG_ID            IN NUMBER                         ,
  p_h_DELIVER_TO_ORG_ID            IN NUMBER                         ,
  p_h_SOLD_TO_CONTACT_ID           IN NUMBER                         ,
  p_h_SHIP_TO_CONTACT_ID           IN NUMBER                         ,
  p_h_INVOICE_TO_CONTACT_ID        IN NUMBER                         ,
  p_h_DELIVER_TO_CONTACT_ID        IN NUMBER                         ,
  p_h_CREATION_DATE                IN DATE                           ,
  p_h_CREATED_BY                   IN NUMBER                         ,
  p_h_LAST_UPDATED_BY              IN NUMBER                         ,
  p_h_LAST_UPDATE_DATE             IN DATE                           ,
  p_h_LAST_UPDATE_LOGIN            IN NUMBER                         ,
  p_h_PROGRAM_APPLICATION_ID       IN NUMBER                         ,
  p_h_PROGRAM_ID                   IN NUMBER                         ,
  p_h_PROGRAM_UPDATE_DATE          IN DATE                            ,
  p_h_REQUEST_ID                   IN NUMBER                         ,
  p_h_CONTEXT          IN VARCHAR2                       ,
  p_h_ATTRIBUTE1       IN VARCHAR2                       ,
  p_h_ATTRIBUTE2       IN VARCHAR2                       ,
  p_h_ATTRIBUTE3       IN VARCHAR2                       ,
  p_h_ATTRIBUTE4       IN VARCHAR2                       ,
  p_h_ATTRIBUTE5       IN VARCHAR2                       ,
  p_h_ATTRIBUTE6       IN VARCHAR2                       ,
  p_h_ATTRIBUTE7       IN VARCHAR2                       ,
  p_h_ATTRIBUTE8       IN VARCHAR2                       ,
  p_h_ATTRIBUTE9                  IN VARCHAR2                       ,
  p_h_ATTRIBUTE10                 IN VARCHAR2                       ,
  p_h_ATTRIBUTE11                 IN VARCHAR2                       ,
  p_h_ATTRIBUTE12                 IN VARCHAR2                       ,
  p_h_ATTRIBUTE13                 IN VARCHAR2                       ,
  p_h_ATTRIBUTE14                 IN VARCHAR2                       ,
  p_h_ATTRIBUTE15                 IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE_CATEGORY   IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE1           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE2           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE3           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE4           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE5           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE6           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE7           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE8           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE9           IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE10       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE11       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE12       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE13       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE14       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE15       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE16       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE17       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE18       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE19       IN VARCHAR2                       ,
  p_h_GLOBAL_ATTRIBUTE20       IN VARCHAR2                       ,
  p_h_CANCELLED_FLAG           IN VARCHAR2                       ,
  p_h_OPEN_FLAG                IN VARCHAR2                       ,
  p_h_BOOKED_FLAG              IN VARCHAR2                       ,
  p_h_SALESREP_ID              IN NUMBER                         ,
  p_h_RETURN_REASON_CODE         IN VARCHAR2                       ,
  p_h_ORDER_DATE_TYPE_CODE       IN VARCHAR2                       ,
  p_h_EARLIEST_SCHEDULE_LIMIT    IN NUMBER                         ,
  p_h_LATEST_SCHEDULE_LIMIT      IN NUMBER                         ,
  p_h_PAYMENT_TYPE_CODE          IN VARCHAR2                       ,
  p_h_PAYMENT_AMOUNT             IN NUMBER                         ,
  p_h_CHECK_NUMBER               IN VARCHAR2                       ,
  p_h_CREDIT_CARD_CODE           IN VARCHAR2                       ,
  p_h_CREDIT_CARD_HOLDER_NAME    IN VARCHAR2                       ,
  p_h_CREDIT_CARD_NUMBER         IN VARCHAR2                       ,
  p_h_CREDIT_CARD_EXPIR_DATE       IN DATE                           ,
  p_h_CREDIT_CARD_APPROVAL_CODE    IN VARCHAR2                       ,
  p_h_SALES_CHANNEL_CODE           IN VARCHAR2                       ,
  p_h_FIRST_ACK_CODE               IN VARCHAR2                       ,
  p_h_FIRST_ACK_DATE               IN DATE                           ,
  p_h_LAST_ACK_CODE                IN VARCHAR2                       ,
  p_h_LAST_ACK_DATE                IN DATE                           ,
  p_h_ORDER_CATEGORY_CODE             IN VARCHAR2                       ,
  p_h_CHANGE_SEQUENCE                 IN VARCHAR2                       ,
  p_h_DROP_SHIP_FLAG                  IN VARCHAR2                       ,
  p_h_CUSTOMER_PAYMENT_TERM_ID        IN NUMBER                         ,
  p_h_SHIPPING_INSTRUCTIONS           IN VARCHAR2                       ,
  p_h_PACKING_INSTRUCTIONS            IN VARCHAR2                       ,
  p_h_TP_CONTEXT                      IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE1                   IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE2                   IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE3                   IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE4                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE5                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE6                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE7                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE8                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE9                  IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE10                 IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE11                 IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE12                 IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE13                 IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE14                 IN VARCHAR2                       ,
  p_h_TP_ATTRIBUTE15                 IN VARCHAR2                       ,
  p_h_FLOW_STATUS_CODE               IN VARCHAR2                       ,
  p_h_MARKETING_SOURCE_CODE_ID       IN NUMBER                         ,
  p_h_CREDIT_CARD_APPROVAL_DATE      IN DATE                            ,
  p_h_UPGRADED_FLAG                  IN VARCHAR2                        ,
  p_h_CUSTOMER_PREF_SET_CODE         IN VARCHAR2                        ,
  p_h_BOOKED_DATE                    IN DATE                            ,
  p_h_LOCK_CONTROL                   IN NUMBER                         ,
  p_h_PRICE_REQUEST_CODE             IN VARCHAR2                        ,
  p_h_XML_MESSAGE_ID                 IN NUMBER                         ,
  p_h_ACCOUNTING_RULE_DURATION       IN NUMBER                         ,
  p_h_attribute16                    IN VARCHAR2                        ,
  p_h_attribute17                    IN VARCHAR2                        ,
  p_h_attribute18                    IN VARCHAR2                        ,
  p_h_attribute19                    IN VARCHAR2                        ,
  p_h_attribute20                    IN VARCHAR2                        ,
  p_h_bill_to_edi_location_code       IN VARCHAR2                       ,
  p_h_Blanket_Number                  IN NUMBER                        ,
  p_h_change_comments                 IN VARCHAR2                       ,
  p_h_change_reason                   IN VARCHAR2                       ,
  p_h_change_request_code             IN VARCHAR2                       ,
  p_h_db_flag                         IN VARCHAR2                       ,
  p_h_Default_Fulfillment_Set         IN VARCHAR2                       ,
  p_h_deliver_to_customer_id          IN NUMBER                        ,
  p_h_force_apply_flag                IN VARCHAR2                       ,
  p_h_Fulfillment_Set_Name            IN VARCHAR2                       ,
  p_h_INVOICE_ADDRESS_ID              IN NUMBER                        ,
  p_h_invoice_to_customer_id          IN NUMBER                        ,
  p_h_SHIP_FROM_ADDRESS_ID            IN NUMBER                        ,
  p_h_ship_from_edi_loc_code          IN VARCHAR2                       ,
  p_h_Line_Set_Name                   IN VARCHAR2                       ,
  p_h_ready_flag                      IN VARCHAR2                       ,
  p_h_SHIP_TO_ADDRESS_CODE            IN VARCHAR2                       ,
  p_h_SHIP_TO_ADDRESS_ID              IN NUMBER                        ,
  p_h_ship_to_customer_id             IN NUMBER                        ,
  p_h_ship_to_edi_location_code       IN VARCHAR2                       ,
  p_h_SOLD_TO_ADDRESS_ID              IN NUMBER                        ,
  p_h_sold_to_edi_location_code       IN VARCHAR2                       ,
  p_h_sold_to_phone_id                IN NUMBER                        ,
  p_h_status_flag                     IN VARCHAR2                       ,
  p_h_xml_transaction_type_code       IN VARCHAR2                       ,
  p_l_LINE_ID                        IN jtf_number_table             ,
  p_l_OPERATION                      IN jtf_varchar2_table_100       ,
  p_l_ORG_ID                         IN jtf_number_table             ,
  p_l_HEADER_ID                      IN jtf_number_table             ,
  p_l_LINE_TYPE_ID                   IN jtf_number_table             ,
  p_l_LINE_NUMBER                    IN jtf_number_table             ,
  p_l_ORDERED_ITEM                   IN jtf_varchar2_table_300       ,
  p_l_REQUEST_DATE                   IN jtf_date_table             ,
  p_l_PROMISE_DATE                   IN jtf_date_table             ,
  p_l_SCHEDULE_SHIP_DATE             IN jtf_date_table             ,
  p_l_ORDER_QUANTITY_UOM             IN jtf_varchar2_table_100       ,
  p_l_PRICING_QUANTITY               IN jtf_number_table             ,
  p_l_PRICING_QUANTITY_UOM           IN jtf_varchar2_table_300       ,
  p_l_CANCELLED_QUANTITY             IN jtf_number_table             ,
  p_l_SHIPPED_QUANTITY               IN jtf_number_table             ,
  p_l_ORDERED_QUANTITY               IN jtf_number_table             ,
  p_l_FULFILLED_QUANTITY             IN jtf_number_table             ,
  p_l_SHIPPING_QUANTITY              IN jtf_number_table             ,
  p_l_SHIPPING_QUANTITY_UOM          IN jtf_varchar2_table_100       ,
  p_l_DELIVERY_LEAD_TIME             IN jtf_number_table           ,
  p_l_TAX_EXEMPT_FLAG                IN jtf_varchar2_table_100         ,
  p_l_TAX_EXEMPT_NUMBER              IN jtf_varchar2_table_100         ,
  p_l_TAX_EXEMPT_REASON_CODE         IN jtf_varchar2_table_100         ,
  p_l_SHIP_FROM_ORG_ID               IN jtf_number_table           ,
  p_l_SHIP_TO_ORG_ID                 IN jtf_number_table           ,
  p_l_INVOICE_TO_ORG_ID              IN jtf_number_table           ,
  p_l_DELIVER_TO_ORG_ID              IN jtf_number_table           ,
  p_l_SHIP_TO_CONTACT_ID             IN jtf_number_table           ,
  p_l_DELIVER_TO_CONTACT_ID          IN jtf_number_table           ,
  p_l_INVOICE_TO_CONTACT_ID          IN jtf_number_table           ,
  p_l_SOLD_FROM_ORG_ID               IN jtf_number_table           ,
  p_l_SOLD_TO_ORG_ID                 IN jtf_number_table           ,
  p_l_CUST_PO_NUMBER                 IN jtf_varchar2_table_100         ,
  p_l_SHIP_TOLERANCE_ABOVE           IN jtf_number_table           ,
  p_l_SHIP_TOLERANCE_BELOW           IN jtf_number_table           ,
  p_l_DEMAND_BUCKET_TYPE_CODE        IN jtf_varchar2_table_100         ,
  p_l_VEH_CUS_ITEM_CUM_KEY_ID        IN jtf_number_table               ,
  p_l_RLA_SCHEDULE_TYPE_CODE         IN jtf_varchar2_table_100         ,
  p_l_CUSTOMER_DOCK_CODE             IN jtf_varchar2_table_100         ,
  p_l_CUSTOMER_JOB                   IN jtf_varchar2_table_100         ,
  p_l_CUSTOMER_PRODUCTION_LINE       IN jtf_varchar2_table_100         ,
  p_l_CUST_MODEL_SERIAL_NUMBER       IN jtf_varchar2_table_100         ,
  p_l_PROJECT_ID                     IN jtf_number_table          ,
  p_l_TASK_ID                        IN jtf_number_table          ,
  p_l_INVENTORY_ITEM_ID              IN jtf_number_table          ,
  p_l_TAX_DATE                       IN jtf_date_table            ,
  p_l_TAX_CODE                       IN jtf_varchar2_table_100          ,
  p_l_TAX_RATE                       IN jtf_number_table                ,
--  p_l_INVOICE_INTERFACE_STATUS_CODE  IN jtf_varchar2_table_100        ,
  p_l_INVOICE_INTER_STATUS_CODE  IN jtf_varchar2_table_100              ,
  p_l_DEMAND_CLASS_CODE              IN jtf_varchar2_table_100          ,
  p_l_PRICE_LIST_ID                  IN jtf_number_table          ,
  p_l_PRICING_DATE                   IN jtf_date_table            ,
  p_l_SHIPMENT_NUMBER                IN jtf_number_table          ,
  p_l_AGREEMENT_ID                   IN jtf_number_table          ,
  p_l_SHIPMENT_PRIORITY_CODE         IN jtf_varchar2_table_100        ,
  p_l_SHIPPING_METHOD_CODE           IN jtf_varchar2_table_100        ,
  p_l_FREIGHT_CARRIER_CODE           IN jtf_varchar2_table_100        ,
  p_l_FREIGHT_TERMS_CODE             IN jtf_varchar2_table_100        ,
  p_l_FOB_POINT_CODE                 IN jtf_varchar2_table_100        ,
  p_l_TAX_POINT_CODE                 IN jtf_varchar2_table_100        ,
  p_l_PAYMENT_TERM_ID                IN jtf_number_table           ,
  p_l_INVOICING_RULE_ID          IN jtf_number_table               ,
  p_l_ACCOUNTING_RULE_ID         IN jtf_number_table               ,
  p_l_SOURCE_DOCUMENT_TYPE_ID    IN jtf_number_table               ,
  p_l_ORIG_SYS_DOCUMENT_REF      IN jtf_varchar2_table_100         ,
  p_l_SOURCE_DOCUMENT_ID         IN jtf_number_table               ,
  p_l_ORIG_SYS_LINE_REF          IN jtf_varchar2_table_100         ,
  p_l_SOURCE_DOCUMENT_LINE_ID    IN jtf_number_table               ,
  p_l_REFERENCE_LINE_ID          IN jtf_number_table               ,
  p_l_REFERENCE_TYPE             IN jtf_varchar2_table_300         ,
  p_l_REFERENCE_HEADER_ID        IN jtf_number_table               ,
  p_l_ITEM_REVISION              IN jtf_varchar2_table_100         ,
  p_l_UNIT_SELLING_PRICE         IN jtf_number_table               ,
  p_l_UNIT_LIST_PRICE            IN jtf_number_table               ,
  p_l_TAX_VALUE                  IN jtf_number_table               ,
  p_l_CONTEXT                    IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE1                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE2                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE3                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE4                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE5                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE6                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE7                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE8                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE9                 IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE10                IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE11                IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE12                IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE13                IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE14                IN jtf_varchar2_table_300        ,
  p_l_ATTRIBUTE15                IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE_CATEGORY  IN jtf_varchar2_table_100        ,
  p_l_GLOBAL_ATTRIBUTE1          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE2          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE3          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE4          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE5          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE6          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE7          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE8          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE9          IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE10         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE11         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE12         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE13         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE14         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE15         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE16         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE17         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE18         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE19         IN jtf_varchar2_table_300        ,
  p_l_GLOBAL_ATTRIBUTE20         IN jtf_varchar2_table_300        ,
  p_l_PRICING_CONTEXT            IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE1         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE2         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE3         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE4         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE5         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE6         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE7         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE8         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE9         IN jtf_varchar2_table_300        ,
  p_l_PRICING_ATTRIBUTE10        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_CONTEXT           IN jtf_varchar2_table_100        ,
  p_l_INDUSTRY_ATTRIBUTE1        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE2        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE3        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE4        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE5        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE6        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE7        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE8        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE9        IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE10       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE11       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE13       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE12       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE14       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE15       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE16       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE17       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE18       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE19       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE20       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE21       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE22       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE23       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE24       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE25       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE26       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE27       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE28       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE29       IN jtf_varchar2_table_300        ,
  p_l_INDUSTRY_ATTRIBUTE30       IN jtf_varchar2_table_300        ,
  p_l_CREATION_DATE              IN jtf_date_table            ,
  p_l_CREATED_BY                 IN jtf_number_table           ,
  p_l_LAST_UPDATE_DATE           IN jtf_date_table            ,
  p_l_LAST_UPDATED_BY            IN jtf_number_table           ,
  p_l_LAST_UPDATE_LOGIN          IN jtf_number_table           ,
  p_l_PROGRAM_APPLICATION_ID     IN jtf_number_table           ,
  p_l_PROGRAM_ID                 IN jtf_number_table           ,
  p_l_PROGRAM_UPDATE_DATE        IN jtf_date_table            ,
  p_l_REQUEST_ID                 IN jtf_number_table           ,
  p_l_TOP_MODEL_LINE_ID          IN jtf_number_table           ,
  p_l_LINK_TO_LINE_ID            IN jtf_number_table           ,
  p_l_COMPONENT_SEQUENCE_ID      IN jtf_number_table           ,
  p_l_COMPONENT_CODE             IN jtf_varchar2_table_300        ,
  p_l_CONFIG_DISPLAY_SEQUENCE    IN jtf_number_table           ,
  p_l_SORT_ORDER                 IN jtf_varchar2_table_300        ,
  p_l_ITEM_TYPE_CODE             IN jtf_varchar2_table_100        ,
  p_l_OPTION_NUMBER              IN jtf_number_table           ,
  p_l_OPTION_FLAG                IN jtf_varchar2_table_100        ,
  p_l_DEP_PLAN_REQUIRED_FLAG     IN jtf_varchar2_table_100        ,
  p_l_VISIBLE_DEMAND_FLAG        IN jtf_varchar2_table_100        ,
  p_l_LINE_CATEGORY_CODE         IN jtf_varchar2_table_100        ,
  p_l_ACTUAL_SHIPMENT_DATE       IN jtf_date_table            ,
  p_l_CUSTOMER_TRX_LINE_ID       IN jtf_number_table           ,
  p_l_RETURN_CONTEXT             IN jtf_varchar2_table_100        ,
  p_l_RETURN_ATTRIBUTE1        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE2        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE3        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE4        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE5        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE6        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE7        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE8        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE9        IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE10       IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE11       IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE12       IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE13       IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE14       IN jtf_varchar2_table_300        ,
  p_l_RETURN_ATTRIBUTE15       IN jtf_varchar2_table_300        ,
  p_l_ACTUAL_ARRIVAL_DATE      IN jtf_date_table            ,
  p_l_ATO_LINE_ID              IN jtf_number_table           ,
  p_l_AUTO_SELECTED_QUANTITY   IN jtf_number_table           ,
  p_l_COMPONENT_NUMBER         IN jtf_number_table           ,
  p_l_EARLIEST_ACCEPTABLE_DATE      IN jtf_date_table            ,
  p_l_EXPLOSION_DATE                IN jtf_date_table            ,
  p_l_LATEST_ACCEPTABLE_DATE        IN jtf_date_table            ,
  p_l_MODEL_GROUP_NUMBER            IN jtf_number_table          ,
  p_l_SCHEDULE_ARRIVAL_DATE         IN jtf_date_table            ,
  p_l_SHIP_MODEL_COMPLETE_FLAG      IN jtf_varchar2_table_100        ,
  p_l_SCHEDULE_STATUS_CODE          IN jtf_varchar2_table_100        ,
  p_l_SOURCE_TYPE_CODE              IN jtf_varchar2_table_100        ,
  p_l_CANCELLED_FLAG                IN jtf_varchar2_table_100        ,
  p_l_OPEN_FLAG                     IN jtf_varchar2_table_100        ,
  p_l_BOOKED_FLAG                   IN jtf_varchar2_table_100        ,
  p_l_SALESREP_ID                   IN jtf_number_table          ,
  p_l_RETURN_REASON_CODE            IN jtf_varchar2_table_100        ,
  p_l_ARRIVAL_SET_ID                IN jtf_number_table          ,
  p_l_SHIP_SET_ID                   IN jtf_number_table          ,
  p_l_SPLIT_FROM_LINE_ID            IN jtf_number_table          ,
  p_l_CUST_PRODUCTION_SEQ_NUM       IN jtf_varchar2_table_100        ,
  p_l_AUTHORIZED_TO_SHIP_FLAG       IN jtf_varchar2_table_300        ,
  p_l_OVER_SHIP_REASON_CODE         IN jtf_varchar2_table_100        ,
  p_l_OVER_SHIP_RESOLVED_FLAG       IN jtf_varchar2_table_100        ,
  p_l_ORDERED_ITEM_ID               IN jtf_number_table          ,
  p_l_ITEM_IDENTIFIER_TYPE          IN jtf_varchar2_table_100        ,
  p_l_CONFIGURATION_ID              IN jtf_number_table          ,
  p_l_COMMITMENT_ID                 IN jtf_number_table          ,
  p_l_SHIPPING_INTERFACED_FLAG      IN jtf_varchar2_table_100        ,
  p_l_CREDIT_INVOICE_LINE_ID        IN jtf_number_table          ,
  p_l_FIRST_ACK_CODE                IN jtf_varchar2_table_100        ,
  p_l_FIRST_ACK_DATE                IN jtf_date_table            ,
  p_l_LAST_ACK_CODE                 IN jtf_varchar2_table_100        ,
  p_l_LAST_ACK_DATE                 IN jtf_date_table            ,
  p_l_PLANNING_PRIORITY             IN jtf_number_table          ,
  p_l_ORDER_SOURCE_ID               IN jtf_number_table          ,
  p_l_ORIG_SYS_SHIPMENT_REF         IN jtf_varchar2_table_100        ,
  p_l_CHANGE_SEQUENCE               IN jtf_varchar2_table_100        ,
  p_l_DROP_SHIP_FLAG                IN jtf_varchar2_table_100        ,
  p_l_CUSTOMER_LINE_NUMBER          IN jtf_varchar2_table_100        ,
  p_l_CUSTOMER_SHIPMENT_NUMBER        IN jtf_varchar2_table_100     ,
  p_l_CUSTOMER_ITEM_NET_PRICE         IN jtf_number_table          ,
  p_l_CUSTOMER_PAYMENT_TERM_ID        IN jtf_number_table          ,
  p_l_FULFILLED_FLAG                  IN jtf_varchar2_table_100    ,
  p_l_END_ITEM_UNIT_NUMBER            IN jtf_varchar2_table_100    ,
  p_l_CONFIG_HEADER_ID                IN jtf_number_table           ,
  p_l_CONFIG_REV_NBR                  IN jtf_number_table          ,
  p_l_MFG_COMPONENT_SEQUENCE_ID       IN jtf_number_table          ,
  p_l_SHIPPING_INSTRUCTIONS           IN jtf_varchar2_table_300    ,
  p_l_PACKING_INSTRUCTIONS            IN jtf_varchar2_table_300    ,
  p_l_INVOICED_QUANTITY               IN jtf_number_table           ,
  p_l_REF_CUSTOMER_TRX_LINE_ID         IN jtf_number_table           ,
  p_l_SPLIT_BY                        IN jtf_varchar2_table_300     ,
  p_l_LINE_SET_ID                     IN jtf_number_table           ,
  p_l_SERVICE_TXN_REASON_CODE         IN jtf_varchar2_table_100    ,
  p_l_SERVICE_TXN_COMMENTS       IN jtf_varchar2_table_300        ,
  p_l_SERVICE_DURATION           IN jtf_number_table           ,
  p_l_SERVICE_START_DATE         IN jtf_date_table            ,
  p_l_SERVICE_END_DATE           IN jtf_date_table            ,
  p_l_SERVICE_COTERMINATE_FLAG   IN jtf_varchar2_table_100     ,
  p_l_UNIT_LIST_PERCENT          IN jtf_number_table           ,
  p_l_UNIT_SELLING_PERCENT       IN jtf_number_table           ,
  p_l_UNIT_PERCENT_BASE_PRICE    IN jtf_number_table           ,
  p_l_SERVICE_NUMBER             IN jtf_number_table           ,
  p_l_SERVICE_PERIOD             IN jtf_varchar2_table_100        ,
  p_l_SHIPPABLE_FLAG             IN jtf_varchar2_table_100        ,
  p_l_MODEL_REMNANT_FLAG         IN jtf_varchar2_table_100        ,
  p_l_RE_SOURCE_FLAG             IN jtf_varchar2_table_300        ,
  p_l_FLOW_STATUS_CODE           IN jtf_varchar2_table_100        ,
  p_l_TP_CONTEXT                 IN jtf_varchar2_table_100        ,
  p_l_TP_ATTRIBUTE1              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE2              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE3              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE4              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE5              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE6              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE7              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE8              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE9              IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE10             IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE11             IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE12             IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE13             IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE14             IN jtf_varchar2_table_300        ,
  p_l_TP_ATTRIBUTE15             IN jtf_varchar2_table_300        ,
  p_l_FULFILLMENT_METHOD_CODE        IN jtf_varchar2_table_300    ,
  p_l_MARKETING_SOURCE_CODE_ID       IN jtf_number_table         ,
  p_l_SERVICE_REF_TYPE_CODE          IN jtf_varchar2_table_100   ,
  p_l_SERVICE_REFERENCE_LINE_ID      IN jtf_number_table           ,
  p_l_SERVICE_REF_SYSTEM_ID          IN jtf_number_table           ,
  p_l_CALCULATE_PRICE_FLAG           IN jtf_varchar2_table_100    ,
  p_l_UPGRADED_FLAG                  IN jtf_varchar2_table_100    ,
  p_l_REVENUE_AMOUNT                 IN jtf_number_table          ,
  p_l_FULFILLMENT_DATE               IN jtf_date_table            ,
  p_l_PREFERRED_GRADE                IN jtf_varchar2_table_100    ,
  p_l_ORDERED_QUANTITY2              IN jtf_number_table          ,
  p_l_ORDERED_QUANTITY_UOM2          IN jtf_varchar2_table_100    ,
  p_l_SHIPPING_QUANTITY2             IN jtf_number_table           ,
  p_l_CANCELLED_QUANTITY2            IN jtf_number_table           ,
  p_l_SHIPPED_QUANTITY2              IN jtf_number_table           ,
  p_l_SHIPPING_QUANTITY_UOM2         IN jtf_varchar2_table_100     ,
  p_l_FULFILLED_QUANTITY2            IN jtf_number_table           ,
  p_l_MFG_LEAD_TIME                  IN jtf_number_table           ,
  p_l_LOCK_CONTROL                   IN jtf_number_table           ,
  p_l_SUBINVENTORY                   IN jtf_varchar2_table_100     ,
  p_l_UNIT_LIST_PRICE_PER_PQTY       IN jtf_number_table           ,
--  p_l_UNIT_SELLING_PRICE_PER_PQTY  IN jtf_number_table           ,
  p_l_UNIT_SELL_PRICE_PER_PQTY       IN jtf_number_table           ,
  p_l_PRICE_REQUEST_CODE             IN jtf_varchar2_table_300    ,
  p_l_ORIGINAL_INVENTORY_ITEM_ID     IN jtf_number_table           ,
  p_l_ORIGINAL_ORDERED_ITEM_ID       IN jtf_number_table           ,
  p_l_ORIGINAL_ORDERED_ITEM          IN jtf_varchar2_table_300    ,
  p_l_ORIGINAL_ITEM_IDENTIF_TYPE      IN jtf_varchar2_table_100  ,
  p_l_ITEM_SUBSTIT_TYPE_CODE          IN jtf_varchar2_table_100   ,
  p_l_OVERRIDE_ATP_DATE_CODE          IN jtf_varchar2_table_100     ,
  p_l_LATE_DEMAND_PENALTY_FACTOR      IN jtf_number_table           ,
  p_l_ACCOUNTING_RULE_DURATION        IN jtf_number_table           ,
  p_l_top_model_line_index         IN jtf_number_table              ,
  p_l_top_model_line_ref           IN jtf_varchar2_table_100        ,
  p_l_unit_cost                    IN jtf_number_table              ,
  p_l_xml_transaction_type_code    IN jtf_varchar2_table_100        ,
  p_l_Sold_to_address_id           IN jtf_number_table              ,
  p_l_Split_Action_Code            IN jtf_varchar2_table_100        ,
  p_l_split_from_line_ref          IN jtf_varchar2_table_100        ,
  p_l_split_from_shipment_ref      IN jtf_varchar2_table_100        ,
  p_l_status_flag                  IN jtf_varchar2_table_100        ,
  p_l_ship_from_edi_loc_code       IN jtf_varchar2_table_100        ,
  p_l_ship_set                     IN jtf_varchar2_table_100        ,
  p_l_Ship_to_address_code         IN jtf_varchar2_table_100        ,
  p_l_Ship_to_address_id           IN jtf_varchar2_table_300        ,
  p_l_ship_to_customer_id          IN jtf_number_table              ,
  p_l_ship_to_edi_location_code    IN jtf_varchar2_table_100        ,
  p_l_service_ref_line_number      IN jtf_number_table           ,
  p_l_service_ref_option_number    IN jtf_number_table           ,
  p_l_service_ref_order_number     IN jtf_number_table           ,
  p_l_service_ref_ship_number      IN jtf_number_table           ,
  p_l_service_reference_line       IN jtf_varchar2_table_100        ,
  p_l_service_reference_order      IN jtf_varchar2_table_100        ,
  p_l_service_reference_system     IN jtf_varchar2_table_100        ,
  p_l_reserved_quantity            IN jtf_number_table              ,
  p_l_return_status                IN jtf_varchar2_table_100        ,
  p_l_schedule_action_code         IN jtf_varchar2_table_100        ,
  p_l_service_line_index           IN jtf_number_table           ,
  p_l_intermed_ship_to_cont_id     IN jtf_number_table           ,
  p_l_intermed_ship_to_org_id      IN jtf_number_table           ,
  p_l_Invoice_address_id           IN jtf_number_table           ,
  p_l_invoice_to_customer_id       IN jtf_number_table           ,
  p_l_item_relationship_type       IN jtf_number_table           ,
  p_l_link_to_line_index           IN jtf_number_table           ,
  p_l_link_to_line_ref             IN jtf_varchar2_table_100        ,
  p_l_db_flag                      IN jtf_varchar2_table_100        ,
  p_l_deliver_to_customer_id       IN jtf_number_table              ,
  p_l_fulfillment_set              IN jtf_varchar2_table_100        ,
  p_l_fulfillment_set_id           IN jtf_number_table              ,
  p_l_change_comments              IN jtf_varchar2_table_300        ,
  p_l_change_reason                IN jtf_varchar2_table_100        ,
  p_l_change_request_code          IN jtf_varchar2_table_100        ,
  p_l_Bill_to_Edi_Location_Code    IN jtf_varchar2_table_100        ,
  p_l_Blanket_Line_Number          IN jtf_number_table              ,
  p_l_Blanket_Number               IN jtf_number_table              ,
  p_l_Blanket_Version_Number       IN jtf_number_table              ,
  p_l_arrival_set                  IN jtf_varchar2_table_100        ,
  p_l_attribute16                  IN jtf_varchar2_table_300        ,
  p_l_attribute17                  IN jtf_varchar2_table_300        ,
  p_l_attribute18                  IN jtf_varchar2_table_300        ,
  p_l_attribute19                  IN jtf_varchar2_table_300        ,
  p_l_attribute20                  IN jtf_varchar2_table_300        ,
  p_c_CANCEL_FLAG                  IN VARCHAR2                        ,
  p_c_SUBMIT_FLAG                  IN VARCHAR2                        ,
  p_c_CHKCONSTRAINT_FLAG           IN VARCHAR2                        ,
  p_party_id                       IN NUMBER                          ,
  p_shipto_partysite_id            IN NUMBER                          ,
  p_billto_partysite_id            IN NUMBER                          ,
  p_save_type                      IN NUMBER
)
IS

l_order_header_rec       OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC;
l_order_line_tbl         OE_Order_PUB.Line_Tbl_Type;
l_ctrl_rec             Control_Rec_Type;

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('In Returns SaveWrapper package body - Begin 123');
END IF;

-- raise no_data_found;
    Construct_Ctrl_Rec(
        p_submit_flag                   => p_c_SUBMIT_FLAG
        ,p_cancel_flag                  => p_c_CANCEL_FLAG
        ,p_chkconstraint_flag           => p_c_chkconstraint_flag
        ,x_control_rec                  => l_ctrl_rec
      );


    l_order_header_rec := Construct_Hdr_Tbl(
       p_HEADER_ID                   =>  p_h_HEADER_ID                ,
       p_OPERATION                   =>  p_h_OPERATION                ,
       p_ORG_ID                      =>  p_h_ORG_ID                   ,
       p_ORDER_TYPE_ID               =>  p_h_ORDER_TYPE_ID            ,
       p_ORDER_NUMBER                =>  p_h_ORDER_NUMBER             ,
       p_VERSION_NUMBER              =>  p_h_VERSION_NUMBER           ,
       p_EXPIRATION_DATE             =>  p_h_EXPIRATION_DATE          ,
       p_ORDER_SOURCE_ID             =>  p_h_ORDER_SOURCE_ID          ,
       p_SOURCE_DOCUMENT_TYPE_ID     =>  p_h_SOURCE_DOCUMENT_TYPE_ID  ,
       p_ORIG_SYS_DOCUMENT_REF       =>  p_h_ORIG_SYS_DOCUMENT_REF    ,
       p_SOURCE_DOCUMENT_ID          =>  p_h_SOURCE_DOCUMENT_ID       ,
       p_ORDERED_DATE                =>  p_h_ORDERED_DATE             ,
       p_REQUEST_DATE                =>  p_h_REQUEST_DATE             ,
       p_PRICING_DATE                =>  p_h_PRICING_DATE             ,
       p_SHIPMENT_PRIORITY_CODE      =>  p_h_SHIPMENT_PRIORITY_CODE   ,
       p_DEMAND_CLASS_CODE           =>  p_h_DEMAND_CLASS_CODE        ,
       p_PRICE_LIST_ID               =>  p_h_PRICE_LIST_ID            ,
       p_MINISITE_ID                 =>  p_h_MINISITE_ID              ,  -- bug 8337371, scnagara
       p_TAX_EXEMPT_FLAG             =>  p_h_TAX_EXEMPT_FLAG          ,
       p_TAX_EXEMPT_NUMBER           =>  p_h_TAX_EXEMPT_NUMBER        ,
       p_TAX_EXEMPT_REASON_CODE      =>  p_h_TAX_EXEMPT_REASON_CODE   ,
       p_CONVERSION_RATE             =>  p_h_CONVERSION_RATE          ,
       p_CONVERSION_TYPE_CODE        =>  p_h_CONVERSION_TYPE_CODE     ,
       p_CONVERSION_RATE_DATE        =>  p_h_CONVERSION_RATE_DATE     ,
       p_PARTIAL_SHIPMENTS_ALLOWED   =>  p_h_PARTIAL_SHIPMENTS_ALLOWED,
       p_SHIP_TOLERANCE_ABOVE        =>  p_h_SHIP_TOLERANCE_ABOVE     ,
       p_SHIP_TOLERANCE_BELOW        =>  p_h_SHIP_TOLERANCE_BELOW     ,
       p_TRANSACTIONAL_CURR_CODE     =>  p_h_TRANSACTIONAL_CURR_CODE  ,
       p_AGREEMENT_ID                =>  p_h_AGREEMENT_ID             ,
       p_TAX_POINT_CODE              =>  p_h_TAX_POINT_CODE           ,
       p_CUST_PO_NUMBER              =>  p_h_CUST_PO_NUMBER           ,
       p_INVOICING_RULE_ID           =>  p_h_INVOICING_RULE_ID        ,
       p_ACCOUNTING_RULE_ID          =>  p_h_ACCOUNTING_RULE_ID       ,
       p_PAYMENT_TERM_ID             =>  p_h_PAYMENT_TERM_ID          ,
       p_SHIPPING_METHOD_CODE        =>  p_h_SHIPPING_METHOD_CODE     ,
       p_FREIGHT_CARRIER_CODE        =>  p_h_FREIGHT_CARRIER_CODE     ,
       p_FOB_POINT_CODE              =>  p_h_FOB_POINT_CODE           ,
       p_FREIGHT_TERMS_CODE          =>  p_h_FREIGHT_TERMS_CODE       ,
       p_SOLD_FROM_ORG_ID            =>  p_h_SOLD_FROM_ORG_ID         ,
       p_SOLD_TO_ORG_ID              =>  p_h_SOLD_TO_ORG_ID           ,
       p_SHIP_FROM_ORG_ID            =>  p_h_SHIP_FROM_ORG_ID         ,
       p_SHIP_TO_ORG_ID              =>  p_h_SHIP_TO_ORG_ID           ,
       p_INVOICE_TO_ORG_ID           =>  p_h_INVOICE_TO_ORG_ID        ,
       p_DELIVER_TO_ORG_ID           =>  p_h_DELIVER_TO_ORG_ID        ,
       p_SOLD_TO_CONTACT_ID          =>  p_h_SOLD_TO_CONTACT_ID       ,
       p_SHIP_TO_CONTACT_ID          =>  p_h_SHIP_TO_CONTACT_ID       ,
       p_INVOICE_TO_CONTACT_ID       =>  p_h_INVOICE_TO_CONTACT_ID    ,
       p_DELIVER_TO_CONTACT_ID       =>  p_h_DELIVER_TO_CONTACT_ID    ,
       p_CREATION_DATE               =>  p_h_CREATION_DATE            ,
       p_CREATED_BY                  =>  p_h_CREATED_BY               ,
       p_LAST_UPDATED_BY             =>  p_h_LAST_UPDATED_BY          ,
       p_LAST_UPDATE_DATE            =>  p_h_LAST_UPDATE_DATE         ,
       p_LAST_UPDATE_LOGIN           =>  p_h_LAST_UPDATE_LOGIN        ,
       p_PROGRAM_APPLICATION_ID      =>  p_h_PROGRAM_APPLICATION_ID   ,
       p_PROGRAM_ID                  =>  p_h_PROGRAM_ID               ,
       p_PROGRAM_UPDATE_DATE         =>  p_h_PROGRAM_UPDATE_DATE      ,
       p_REQUEST_ID                  =>  p_h_REQUEST_ID         ,
       p_CONTEXT                     =>  p_h_CONTEXT            ,
       p_ATTRIBUTE1                  =>  p_h_ATTRIBUTE1         ,
       p_ATTRIBUTE2                  =>  p_h_ATTRIBUTE2         ,
       p_ATTRIBUTE3                  =>  p_h_ATTRIBUTE3         ,
       p_ATTRIBUTE4                  =>  p_h_ATTRIBUTE4         ,
       p_ATTRIBUTE5                  =>  p_h_ATTRIBUTE5         ,
       p_ATTRIBUTE6                  =>  p_h_ATTRIBUTE6         ,
       p_ATTRIBUTE7                  =>  p_h_ATTRIBUTE7         ,
       p_ATTRIBUTE8                  =>  p_h_ATTRIBUTE8         ,
       p_ATTRIBUTE9                  =>  p_h_ATTRIBUTE9         ,
       p_ATTRIBUTE10                 =>  p_h_ATTRIBUTE10        ,
       p_ATTRIBUTE11                 =>  p_h_ATTRIBUTE11        ,
       p_ATTRIBUTE12                 =>  p_h_ATTRIBUTE12        ,
       p_ATTRIBUTE13                 =>  p_h_ATTRIBUTE13        ,
       p_ATTRIBUTE14                 =>  p_h_ATTRIBUTE14        ,
       p_ATTRIBUTE15                 =>  p_h_ATTRIBUTE15        ,
       p_GLOBAL_ATTRIBUTE_CATEGORY  =>  p_h_GLOBAL_ATTRIBUTE_CATEGORY,
       p_GLOBAL_ATTRIBUTE1          =>  p_h_GLOBAL_ATTRIBUTE1        ,
       p_GLOBAL_ATTRIBUTE2          =>  p_h_GLOBAL_ATTRIBUTE2        ,
       p_GLOBAL_ATTRIBUTE3          =>  p_h_GLOBAL_ATTRIBUTE3        ,
       p_GLOBAL_ATTRIBUTE4          =>  p_h_GLOBAL_ATTRIBUTE4        ,
       p_GLOBAL_ATTRIBUTE5          =>  p_h_GLOBAL_ATTRIBUTE5        ,
       p_GLOBAL_ATTRIBUTE6          =>  p_h_GLOBAL_ATTRIBUTE6        ,
       p_GLOBAL_ATTRIBUTE7          =>  p_h_GLOBAL_ATTRIBUTE7        ,
       p_GLOBAL_ATTRIBUTE8          =>  p_h_GLOBAL_ATTRIBUTE8        ,
       p_GLOBAL_ATTRIBUTE9          =>  p_h_GLOBAL_ATTRIBUTE9        ,
       p_GLOBAL_ATTRIBUTE10          =>  p_h_GLOBAL_ATTRIBUTE10        ,
       p_GLOBAL_ATTRIBUTE11          =>  p_h_GLOBAL_ATTRIBUTE11        ,
       p_GLOBAL_ATTRIBUTE12          =>  p_h_GLOBAL_ATTRIBUTE12        ,
       p_GLOBAL_ATTRIBUTE13          =>  p_h_GLOBAL_ATTRIBUTE13        ,
       p_GLOBAL_ATTRIBUTE14          =>  p_h_GLOBAL_ATTRIBUTE14        ,
       p_GLOBAL_ATTRIBUTE15          =>  p_h_GLOBAL_ATTRIBUTE15        ,
       p_GLOBAL_ATTRIBUTE16          =>  p_h_GLOBAL_ATTRIBUTE16        ,
       p_GLOBAL_ATTRIBUTE17          =>  p_h_GLOBAL_ATTRIBUTE17        ,
       p_GLOBAL_ATTRIBUTE18          =>  p_h_GLOBAL_ATTRIBUTE18        ,
       p_GLOBAL_ATTRIBUTE19          =>  p_h_GLOBAL_ATTRIBUTE19        ,
       p_GLOBAL_ATTRIBUTE20          =>  p_h_GLOBAL_ATTRIBUTE20        ,
       p_CANCELLED_FLAG              =>  p_h_CANCELLED_FLAG            ,
       p_OPEN_FLAG                   =>  p_h_OPEN_FLAG                 ,
       p_BOOKED_FLAG                 =>  p_h_BOOKED_FLAG               ,
       p_SALESREP_ID                 =>  p_h_SALESREP_ID               ,
       p_RETURN_REASON_CODE          =>  p_h_RETURN_REASON_CODE          ,
       p_ORDER_DATE_TYPE_CODE        =>  p_h_ORDER_DATE_TYPE_CODE        ,
       p_EARLIEST_SCHEDULE_LIMIT     =>  p_h_EARLIEST_SCHEDULE_LIMIT     ,
       p_LATEST_SCHEDULE_LIMIT       =>  p_h_LATEST_SCHEDULE_LIMIT       ,
       p_PAYMENT_TYPE_CODE           =>  p_h_PAYMENT_TYPE_CODE           ,
       p_PAYMENT_AMOUNT              =>  p_h_PAYMENT_AMOUNT              ,
       p_CHECK_NUMBER                =>  p_h_CHECK_NUMBER                ,
       p_CREDIT_CARD_CODE            =>  p_h_CREDIT_CARD_CODE            ,
       p_CREDIT_CARD_HOLDER_NAME     =>  p_h_CREDIT_CARD_HOLDER_NAME     ,
       p_CREDIT_CARD_NUMBER          =>  p_h_CREDIT_CARD_NUMBER          ,
       p_CREDIT_CARD_EXPIR_DATE      =>  p_h_CREDIT_CARD_EXPIR_DATE      ,
       p_CREDIT_CARD_APPROVAL_CODE   =>  p_h_CREDIT_CARD_APPROVAL_CODE   ,
       p_SALES_CHANNEL_CODE          =>  p_h_SALES_CHANNEL_CODE          ,
       p_FIRST_ACK_CODE              =>  p_h_FIRST_ACK_CODE              ,
       p_FIRST_ACK_DATE              =>  p_h_FIRST_ACK_DATE              ,
       p_LAST_ACK_CODE               =>  p_h_LAST_ACK_CODE               ,
       p_LAST_ACK_DATE               =>  p_h_LAST_ACK_DATE               ,
       p_ORDER_CATEGORY_CODE         =>  p_h_ORDER_CATEGORY_CODE         ,
       p_CHANGE_SEQUENCE             =>  p_h_CHANGE_SEQUENCE             ,
       p_DROP_SHIP_FLAG              =>  p_h_DROP_SHIP_FLAG              ,
       p_CUSTOMER_PAYMENT_TERM_ID    =>  p_h_CUSTOMER_PAYMENT_TERM_ID    ,
       p_SHIPPING_INSTRUCTIONS       =>  p_h_SHIPPING_INSTRUCTIONS       ,
       p_PACKING_INSTRUCTIONS        =>  p_h_PACKING_INSTRUCTIONS        ,
       p_TP_CONTEXT                        =>  p_h_TP_CONTEXT           ,
       p_TP_ATTRIBUTE1                     =>  p_h_TP_ATTRIBUTE1        ,
       p_TP_ATTRIBUTE2                     =>  p_h_TP_ATTRIBUTE2        ,
       p_TP_ATTRIBUTE3                     =>  p_h_TP_ATTRIBUTE3        ,
       p_TP_ATTRIBUTE4                     =>  p_h_TP_ATTRIBUTE4        ,
       p_TP_ATTRIBUTE5                     =>  p_h_TP_ATTRIBUTE5        ,
       p_TP_ATTRIBUTE6                     =>  p_h_TP_ATTRIBUTE6        ,
       p_TP_ATTRIBUTE7                     =>  p_h_TP_ATTRIBUTE7        ,
       p_TP_ATTRIBUTE8                     =>  p_h_TP_ATTRIBUTE8        ,
       p_TP_ATTRIBUTE9                     =>  p_h_TP_ATTRIBUTE9        ,
       p_TP_ATTRIBUTE10                    =>  p_h_TP_ATTRIBUTE10       ,
       p_TP_ATTRIBUTE11                    =>  p_h_TP_ATTRIBUTE11       ,
       p_TP_ATTRIBUTE12                    =>  p_h_TP_ATTRIBUTE12       ,
       p_TP_ATTRIBUTE13                    =>  p_h_TP_ATTRIBUTE13       ,
       p_TP_ATTRIBUTE14                    =>  p_h_TP_ATTRIBUTE14       ,
       p_TP_ATTRIBUTE15                    =>  p_h_TP_ATTRIBUTE15       ,
       p_FLOW_STATUS_CODE                  =>  p_h_FLOW_STATUS_CODE     ,
       p_MARKETING_SOURCE_CODE_ID          =>  p_h_MARKETING_SOURCE_CODE_ID        ,
       p_CREDIT_CARD_APPROVAL_DATE         =>  p_h_CREDIT_CARD_APPROVAL_DATE       ,
       p_UPGRADED_FLAG                     =>  p_h_UPGRADED_FLAG                   ,
       p_CUSTOMER_PREF_SET_CODE            =>  p_h_CUSTOMER_PREF_SET_CODE    ,
       p_BOOKED_DATE                       =>  p_h_BOOKED_DATE                     ,
       p_LOCK_CONTROL                      =>  p_h_LOCK_CONTROL                    ,
       p_PRICE_REQUEST_CODE                =>  p_h_PRICE_REQUEST_CODE              ,
       p_XML_MESSAGE_ID                    =>  p_h_XML_MESSAGE_ID                  ,
       p_ACCOUNTING_RULE_DURATION          =>  p_h_ACCOUNTING_RULE_DURATION        ,
       p_attribute16           =>  p_h_attribute16      ,
       p_attribute17           =>  p_h_attribute17      ,
       p_attribute18           =>  p_h_attribute18      ,
       p_attribute19           =>  p_h_attribute19      ,
       p_attribute20           =>  p_h_attribute20      ,
       p_bill_to_edi_location_code =>  p_h_bill_to_edi_location_code,
       p_Blanket_Number            =>  p_h_Blanket_Number      ,
       p_change_comments           =>  p_h_change_comments      ,
       p_change_reason             =>  p_h_change_reason        ,
       p_change_request_code       =>  p_h_change_request_code  ,
       p_db_flag                   =>  p_h_db_flag        ,
       p_Default_Fulfillment_Set   =>  p_h_Default_Fulfillment_Set,
       p_deliver_to_customer_id    =>  p_h_deliver_to_customer_id,
       p_force_apply_flag          =>  p_h_force_apply_flag      ,
       p_Fulfillment_Set_Name      =>  p_h_Fulfillment_Set_Name  ,
       p_INVOICE_ADDRESS_ID        =>  p_h_INVOICE_ADDRESS_ID    ,
       p_invoice_to_customer_id    =>  p_h_invoice_to_customer_id,
       p_SHIP_FROM_ADDRESS_ID      =>  p_h_SHIP_FROM_ADDRESS_ID  ,
       p_ship_from_edi_loc_code    =>  p_h_ship_from_edi_loc_code ,
       p_Line_Set_Name                 =>  p_h_Line_Set_Name      ,
       p_ready_flag                    =>  p_h_ready_flag         ,
       p_SHIP_TO_ADDRESS_CODE          =>  p_h_SHIP_TO_ADDRESS_CODE,
       p_SHIP_TO_ADDRESS_ID            =>  p_h_SHIP_TO_ADDRESS_ID  ,
       p_ship_to_customer_id           =>  p_h_ship_to_customer_id ,
       p_ship_to_edi_location_code     =>  p_h_ship_to_edi_location_code,
       p_SOLD_TO_ADDRESS_ID            =>  p_h_SOLD_TO_ADDRESS_ID      ,
       p_sold_to_edi_location_code     =>  p_h_sold_to_edi_location_code,
       p_sold_to_phone_id              =>  p_h_sold_to_phone_id        ,
       p_status_flag                   =>  p_h_status_flag      ,
       p_xml_transaction_type_code     =>  p_h_xml_transaction_type_code

   );

    l_order_line_tbl := Construct_Line_Tbl(
       p_LINE_ID                              =>  p_l_LINE_ID                   ,
       p_OPERATION                            =>  p_l_OPERATION                 ,
       p_ORG_ID                               =>  p_l_ORG_ID                    ,
       p_HEADER_ID                            =>  p_l_HEADER_ID                 ,
       p_LINE_TYPE_ID                         =>  p_l_LINE_TYPE_ID              ,
       p_LINE_NUMBER                          =>  p_l_LINE_NUMBER               ,
       p_ORDERED_ITEM                         =>  p_l_ORDERED_ITEM              ,
       p_REQUEST_DATE                         =>  p_l_REQUEST_DATE              ,
       p_PROMISE_DATE                         =>  p_l_PROMISE_DATE              ,
       p_SCHEDULE_SHIP_DATE                   =>  p_l_SCHEDULE_SHIP_DATE        ,
       p_ORDER_QUANTITY_UOM                   =>  p_l_ORDER_QUANTITY_UOM        ,
       p_PRICING_QUANTITY                     =>  p_l_PRICING_QUANTITY          ,
       p_PRICING_QUANTITY_UOM                 =>  p_l_PRICING_QUANTITY_UOM      ,
       p_CANCELLED_QUANTITY                   =>  p_l_CANCELLED_QUANTITY        ,
       p_SHIPPED_QUANTITY                     =>  p_l_SHIPPED_QUANTITY          ,
       p_ORDERED_QUANTITY                     =>  p_l_ORDERED_QUANTITY          ,
       p_FULFILLED_QUANTITY                   =>  p_l_FULFILLED_QUANTITY        ,
       p_SHIPPING_QUANTITY                    =>  p_l_SHIPPING_QUANTITY         ,
       p_SHIPPING_QUANTITY_UOM                =>  p_l_SHIPPING_QUANTITY_UOM     ,
       p_DELIVERY_LEAD_TIME                   =>  p_l_DELIVERY_LEAD_TIME        ,
       p_TAX_EXEMPT_FLAG                      =>  p_l_TAX_EXEMPT_FLAG           ,
       p_TAX_EXEMPT_NUMBER                    =>  p_l_TAX_EXEMPT_NUMBER            ,
       p_TAX_EXEMPT_REASON_CODE               =>  p_l_TAX_EXEMPT_REASON_CODE       ,
       p_SHIP_FROM_ORG_ID                     =>  p_l_SHIP_FROM_ORG_ID             ,
       p_SHIP_TO_ORG_ID                       =>  p_l_SHIP_TO_ORG_ID               ,
       p_INVOICE_TO_ORG_ID                    =>  p_l_INVOICE_TO_ORG_ID            ,
       p_DELIVER_TO_ORG_ID                    =>  p_l_DELIVER_TO_ORG_ID            ,
       p_SHIP_TO_CONTACT_ID                   =>  p_l_SHIP_TO_CONTACT_ID           ,
       p_DELIVER_TO_CONTACT_ID                =>  p_l_DELIVER_TO_CONTACT_ID        ,
       p_INVOICE_TO_CONTACT_ID                =>  p_l_INVOICE_TO_CONTACT_ID        ,
       p_SOLD_FROM_ORG_ID                     =>  p_l_SOLD_FROM_ORG_ID             ,
       p_SOLD_TO_ORG_ID                       =>  p_l_SOLD_TO_ORG_ID               ,
       p_CUST_PO_NUMBER                       =>  p_l_CUST_PO_NUMBER               ,
       p_SHIP_TOLERANCE_ABOVE                 =>  p_l_SHIP_TOLERANCE_ABOVE         ,
       p_SHIP_TOLERANCE_BELOW                 =>  p_l_SHIP_TOLERANCE_BELOW         ,
       p_DEMAND_BUCKET_TYPE_CODE              =>  p_l_DEMAND_BUCKET_TYPE_CODE      ,
       p_VEH_CUS_ITEM_CUM_KEY_ID              =>  p_l_VEH_CUS_ITEM_CUM_KEY_ID      ,
       p_RLA_SCHEDULE_TYPE_CODE               =>  p_l_RLA_SCHEDULE_TYPE_CODE       ,
       p_CUSTOMER_DOCK_CODE                   =>  p_l_CUSTOMER_DOCK_CODE           ,
       p_CUSTOMER_JOB                         =>  p_l_CUSTOMER_JOB                 ,
       p_CUSTOMER_PRODUCTION_LINE             =>  p_l_CUSTOMER_PRODUCTION_LINE     ,
       p_CUST_MODEL_SERIAL_NUMBER             =>  p_l_CUST_MODEL_SERIAL_NUMBER     ,
       p_PROJECT_ID                           =>  p_l_PROJECT_ID                   ,
       p_TASK_ID                              =>  p_l_TASK_ID                      ,
       p_INVENTORY_ITEM_ID                    =>  p_l_INVENTORY_ITEM_ID            ,
       p_TAX_DATE                             =>  p_l_TAX_DATE                     ,
       p_TAX_CODE                             =>  p_l_TAX_CODE                     ,
       p_TAX_RATE                             =>  p_l_TAX_RATE                     ,
       p_INVOICE_INTER_STATUS_CODE            =>  p_l_INVOICE_INTER_STATUS_CODE    ,
       p_DEMAND_CLASS_CODE                    =>  p_l_DEMAND_CLASS_CODE            ,
       p_PRICE_LIST_ID                        =>  p_l_PRICE_LIST_ID                ,
       p_PRICING_DATE                         =>  p_l_PRICING_DATE                 ,
       p_SHIPMENT_NUMBER                      =>  p_l_SHIPMENT_NUMBER              ,
       p_AGREEMENT_ID                         =>  p_l_AGREEMENT_ID                 ,
       p_SHIPMENT_PRIORITY_CODE               =>  p_l_SHIPMENT_PRIORITY_CODE       ,
       p_SHIPPING_METHOD_CODE                 =>  p_l_SHIPPING_METHOD_CODE         ,
       p_FREIGHT_CARRIER_CODE                 =>  p_l_FREIGHT_CARRIER_CODE         ,
       p_FREIGHT_TERMS_CODE                   =>  p_l_FREIGHT_TERMS_CODE           ,
       p_FOB_POINT_CODE                       =>  p_l_FOB_POINT_CODE               ,
       p_TAX_POINT_CODE                       =>  p_l_TAX_POINT_CODE               ,
       p_PAYMENT_TERM_ID                      =>  p_l_PAYMENT_TERM_ID              ,
       p_INVOICING_RULE_ID                    =>  p_l_INVOICING_RULE_ID            ,
       p_ACCOUNTING_RULE_ID                   =>  p_l_ACCOUNTING_RULE_ID           ,
       p_SOURCE_DOCUMENT_TYPE_ID              =>  p_l_SOURCE_DOCUMENT_TYPE_ID      ,
       p_ORIG_SYS_DOCUMENT_REF                =>  p_l_ORIG_SYS_DOCUMENT_REF        ,
       p_SOURCE_DOCUMENT_ID                   =>  p_l_SOURCE_DOCUMENT_ID           ,
       p_ORIG_SYS_LINE_REF                    =>  p_l_ORIG_SYS_LINE_REF            ,
       p_SOURCE_DOCUMENT_LINE_ID              =>  p_l_SOURCE_DOCUMENT_LINE_ID      ,
       p_REFERENCE_LINE_ID                    =>  p_l_REFERENCE_LINE_ID            ,
       p_REFERENCE_TYPE                       =>  p_l_REFERENCE_TYPE               ,
       p_REFERENCE_HEADER_ID                  =>  p_l_REFERENCE_HEADER_ID          ,
       p_ITEM_REVISION                        =>  p_l_ITEM_REVISION                ,
       p_UNIT_SELLING_PRICE                   =>  p_l_UNIT_SELLING_PRICE           ,
       p_UNIT_LIST_PRICE                      =>  p_l_UNIT_LIST_PRICE              ,
       p_TAX_VALUE                            =>  p_l_TAX_VALUE                    ,
       p_CONTEXT                              =>  p_l_CONTEXT                      ,
       p_ATTRIBUTE1                           =>  p_l_ATTRIBUTE1                   ,
       p_ATTRIBUTE2                           =>  p_l_ATTRIBUTE2                   ,
       p_ATTRIBUTE3                           =>  p_l_ATTRIBUTE3                   ,
       p_ATTRIBUTE4                           =>  p_l_ATTRIBUTE4                   ,
       p_ATTRIBUTE5                           =>  p_l_ATTRIBUTE5                   ,
       p_ATTRIBUTE6                           =>  p_l_ATTRIBUTE6                   ,
       p_ATTRIBUTE7                           =>  p_l_ATTRIBUTE7                   ,
       p_ATTRIBUTE8                           =>  p_l_ATTRIBUTE8                   ,
       p_ATTRIBUTE9                           =>  p_l_ATTRIBUTE9                   ,
       p_ATTRIBUTE10                          =>  p_l_ATTRIBUTE10                  ,
       p_ATTRIBUTE11                          =>  p_l_ATTRIBUTE11                  ,
       p_ATTRIBUTE12                          =>  p_l_ATTRIBUTE12                  ,
       p_ATTRIBUTE13                          =>  p_l_ATTRIBUTE13                  ,
       p_ATTRIBUTE14                          =>  p_l_ATTRIBUTE14                  ,
       p_ATTRIBUTE15                          =>  p_l_ATTRIBUTE15                  ,
       p_GLOBAL_ATTRIBUTE_CATEGORY            =>  p_l_GLOBAL_ATTRIBUTE_CATEGORY    ,
       p_GLOBAL_ATTRIBUTE1                    =>  p_l_GLOBAL_ATTRIBUTE1            ,
       p_GLOBAL_ATTRIBUTE2                    =>  p_l_GLOBAL_ATTRIBUTE2            ,
       p_GLOBAL_ATTRIBUTE3                    =>  p_l_GLOBAL_ATTRIBUTE3            ,
       p_GLOBAL_ATTRIBUTE4                    =>  p_l_GLOBAL_ATTRIBUTE4            ,
       p_GLOBAL_ATTRIBUTE5                    =>  p_l_GLOBAL_ATTRIBUTE5            ,
       p_GLOBAL_ATTRIBUTE6                    =>  p_l_GLOBAL_ATTRIBUTE6            ,
       p_GLOBAL_ATTRIBUTE7                    =>  p_l_GLOBAL_ATTRIBUTE7            ,
       p_GLOBAL_ATTRIBUTE8                    =>  p_l_GLOBAL_ATTRIBUTE8            ,
       p_GLOBAL_ATTRIBUTE9                    =>  p_l_GLOBAL_ATTRIBUTE9            ,
       p_GLOBAL_ATTRIBUTE10                   =>  p_l_GLOBAL_ATTRIBUTE10           ,
       p_GLOBAL_ATTRIBUTE11                   =>  p_l_GLOBAL_ATTRIBUTE11           ,
       p_GLOBAL_ATTRIBUTE12                   =>  p_l_GLOBAL_ATTRIBUTE12           ,
       p_GLOBAL_ATTRIBUTE13                   =>  p_l_GLOBAL_ATTRIBUTE13           ,
       p_GLOBAL_ATTRIBUTE14                   =>  p_l_GLOBAL_ATTRIBUTE14           ,
       p_GLOBAL_ATTRIBUTE15                   =>  p_l_GLOBAL_ATTRIBUTE15         ,
       p_GLOBAL_ATTRIBUTE16                   =>  p_l_GLOBAL_ATTRIBUTE16         ,
       p_GLOBAL_ATTRIBUTE17                   =>  p_l_GLOBAL_ATTRIBUTE17         ,
       p_GLOBAL_ATTRIBUTE18                   =>  p_l_GLOBAL_ATTRIBUTE18         ,
       p_GLOBAL_ATTRIBUTE19                   =>  p_l_GLOBAL_ATTRIBUTE19         ,
       p_GLOBAL_ATTRIBUTE20                   =>  p_l_GLOBAL_ATTRIBUTE20         ,
       p_PRICING_CONTEXT                      =>  p_l_PRICING_CONTEXT            ,
       p_PRICING_ATTRIBUTE1                   =>  p_l_PRICING_ATTRIBUTE1         ,
       p_PRICING_ATTRIBUTE2                   =>  p_l_PRICING_ATTRIBUTE2         ,
       p_PRICING_ATTRIBUTE3                   =>  p_l_PRICING_ATTRIBUTE3         ,
       p_PRICING_ATTRIBUTE4                   =>  p_l_PRICING_ATTRIBUTE4         ,
       p_PRICING_ATTRIBUTE5                   =>  p_l_PRICING_ATTRIBUTE5         ,
       p_PRICING_ATTRIBUTE6                   =>  p_l_PRICING_ATTRIBUTE6         ,
       p_PRICING_ATTRIBUTE7                   =>  p_l_PRICING_ATTRIBUTE7         ,
       p_PRICING_ATTRIBUTE8                   =>  p_l_PRICING_ATTRIBUTE8         ,
       p_PRICING_ATTRIBUTE9                   =>  p_l_PRICING_ATTRIBUTE9         ,
       p_PRICING_ATTRIBUTE10                  =>  p_l_PRICING_ATTRIBUTE10        ,
       p_INDUSTRY_CONTEXT                     =>  p_l_INDUSTRY_CONTEXT           ,
       p_INDUSTRY_ATTRIBUTE1                  =>  p_l_INDUSTRY_ATTRIBUTE1        ,
       p_INDUSTRY_ATTRIBUTE2                  =>  p_l_INDUSTRY_ATTRIBUTE2        ,
       p_INDUSTRY_ATTRIBUTE3                  =>  p_l_INDUSTRY_ATTRIBUTE3        ,
       p_INDUSTRY_ATTRIBUTE4                  =>  p_l_INDUSTRY_ATTRIBUTE4        ,
       p_INDUSTRY_ATTRIBUTE5                  =>  p_l_INDUSTRY_ATTRIBUTE5        ,
       p_INDUSTRY_ATTRIBUTE6                  =>  p_l_INDUSTRY_ATTRIBUTE6        ,
       p_INDUSTRY_ATTRIBUTE7                  =>  p_l_INDUSTRY_ATTRIBUTE7        ,
       p_INDUSTRY_ATTRIBUTE8                  =>  p_l_INDUSTRY_ATTRIBUTE8        ,
       p_INDUSTRY_ATTRIBUTE9                  =>  p_l_INDUSTRY_ATTRIBUTE9        ,
       p_INDUSTRY_ATTRIBUTE10                 =>  p_l_INDUSTRY_ATTRIBUTE10        ,
       p_INDUSTRY_ATTRIBUTE11                 =>  p_l_INDUSTRY_ATTRIBUTE11        ,
       p_INDUSTRY_ATTRIBUTE13                 =>  p_l_INDUSTRY_ATTRIBUTE13        ,
       p_INDUSTRY_ATTRIBUTE12                 =>  p_l_INDUSTRY_ATTRIBUTE12        ,
       p_INDUSTRY_ATTRIBUTE14                 =>  p_l_INDUSTRY_ATTRIBUTE14        ,
       p_INDUSTRY_ATTRIBUTE15                 =>  p_l_INDUSTRY_ATTRIBUTE15        ,
       p_INDUSTRY_ATTRIBUTE16                 =>  p_l_INDUSTRY_ATTRIBUTE16        ,
       p_INDUSTRY_ATTRIBUTE17                 =>  p_l_INDUSTRY_ATTRIBUTE17        ,
       p_INDUSTRY_ATTRIBUTE18                 =>  p_l_INDUSTRY_ATTRIBUTE18        ,
       p_INDUSTRY_ATTRIBUTE19                 =>  p_l_INDUSTRY_ATTRIBUTE19        ,
       p_INDUSTRY_ATTRIBUTE20                 =>  p_l_INDUSTRY_ATTRIBUTE20        ,
       p_INDUSTRY_ATTRIBUTE21                 =>  p_l_INDUSTRY_ATTRIBUTE21        ,
       p_INDUSTRY_ATTRIBUTE22                 =>  p_l_INDUSTRY_ATTRIBUTE22        ,
       p_INDUSTRY_ATTRIBUTE23                 =>  p_l_INDUSTRY_ATTRIBUTE23        ,
       p_INDUSTRY_ATTRIBUTE24                 =>  p_l_INDUSTRY_ATTRIBUTE24        ,
       p_INDUSTRY_ATTRIBUTE25                 =>  p_l_INDUSTRY_ATTRIBUTE25        ,
       p_INDUSTRY_ATTRIBUTE26                 =>  p_l_INDUSTRY_ATTRIBUTE26        ,
       p_INDUSTRY_ATTRIBUTE27                 =>  p_l_INDUSTRY_ATTRIBUTE27        ,
       p_INDUSTRY_ATTRIBUTE28                 =>  p_l_INDUSTRY_ATTRIBUTE28        ,
       p_INDUSTRY_ATTRIBUTE29                 =>  p_l_INDUSTRY_ATTRIBUTE29        ,
       p_INDUSTRY_ATTRIBUTE30                 =>  p_l_INDUSTRY_ATTRIBUTE30        ,
       p_CREATION_DATE                        =>  p_l_CREATION_DATE               ,
       p_CREATED_BY                           =>  p_l_CREATED_BY                  ,
       p_LAST_UPDATE_DATE                     =>  p_l_LAST_UPDATE_DATE            ,
       p_LAST_UPDATED_BY                      =>  p_l_LAST_UPDATED_BY             ,
       p_LAST_UPDATE_LOGIN                    =>  p_l_LAST_UPDATE_LOGIN           ,
       p_PROGRAM_APPLICATION_ID               =>  p_l_PROGRAM_APPLICATION_ID      ,
       p_PROGRAM_ID                           =>  p_l_PROGRAM_ID                  ,
       p_PROGRAM_UPDATE_DATE                  =>  p_l_PROGRAM_UPDATE_DATE         ,
       p_REQUEST_ID                           =>  p_l_REQUEST_ID                  ,
       p_TOP_MODEL_LINE_ID                    =>  p_l_TOP_MODEL_LINE_ID           ,
       p_LINK_TO_LINE_ID                      =>  p_l_LINK_TO_LINE_ID             ,
       p_COMPONENT_SEQUENCE_ID                =>  p_l_COMPONENT_SEQUENCE_ID       ,
       p_COMPONENT_CODE                       =>  p_l_COMPONENT_CODE              ,
       p_CONFIG_DISPLAY_SEQUENCE              =>  p_l_CONFIG_DISPLAY_SEQUENCE     ,
       p_SORT_ORDER                           =>  p_l_SORT_ORDER                  ,
       p_ITEM_TYPE_CODE                       =>  p_l_ITEM_TYPE_CODE              ,
       p_OPTION_NUMBER                        =>  p_l_OPTION_NUMBER               ,
       p_OPTION_FLAG                          =>  p_l_OPTION_FLAG                 ,
       p_DEP_PLAN_REQUIRED_FLAG               =>  p_l_DEP_PLAN_REQUIRED_FLAG      ,
       p_VISIBLE_DEMAND_FLAG                  =>  p_l_VISIBLE_DEMAND_FLAG         ,
       p_LINE_CATEGORY_CODE                   =>  p_l_LINE_CATEGORY_CODE          ,
       p_ACTUAL_SHIPMENT_DATE                 =>  p_l_ACTUAL_SHIPMENT_DATE        ,
       p_CUSTOMER_TRX_LINE_ID                 =>  p_l_CUSTOMER_TRX_LINE_ID        ,
       p_RETURN_CONTEXT                       =>  p_l_RETURN_CONTEXT            ,
       p_RETURN_ATTRIBUTE1                    =>  p_l_RETURN_ATTRIBUTE1         ,
       p_RETURN_ATTRIBUTE2                    =>  p_l_RETURN_ATTRIBUTE2         ,
       p_RETURN_ATTRIBUTE3                    =>  p_l_RETURN_ATTRIBUTE3         ,
       p_RETURN_ATTRIBUTE4                    =>  p_l_RETURN_ATTRIBUTE4         ,
       p_RETURN_ATTRIBUTE5                    =>  p_l_RETURN_ATTRIBUTE5         ,
       p_RETURN_ATTRIBUTE6                    =>  p_l_RETURN_ATTRIBUTE6         ,
       p_RETURN_ATTRIBUTE7                    =>  p_l_RETURN_ATTRIBUTE7         ,
       p_RETURN_ATTRIBUTE8                    =>  p_l_RETURN_ATTRIBUTE8         ,
       p_RETURN_ATTRIBUTE9                    =>  p_l_RETURN_ATTRIBUTE9         ,
       p_RETURN_ATTRIBUTE10                   =>  p_l_RETURN_ATTRIBUTE10        ,
       p_RETURN_ATTRIBUTE11                   =>  p_l_RETURN_ATTRIBUTE11        ,
       p_RETURN_ATTRIBUTE12                   =>  p_l_RETURN_ATTRIBUTE12        ,
       p_RETURN_ATTRIBUTE13                   =>  p_l_RETURN_ATTRIBUTE13        ,
       p_RETURN_ATTRIBUTE14                   =>  p_l_RETURN_ATTRIBUTE14        ,
       p_RETURN_ATTRIBUTE15                   =>  p_l_RETURN_ATTRIBUTE15        ,
       p_ACTUAL_ARRIVAL_DATE                  =>  p_l_ACTUAL_ARRIVAL_DATE       ,
       p_ATO_LINE_ID                          =>  p_l_ATO_LINE_ID               ,
       p_AUTO_SELECTED_QUANTITY               =>  p_l_AUTO_SELECTED_QUANTITY    ,
       p_COMPONENT_NUMBER                     =>  p_l_COMPONENT_NUMBER          ,
       p_EARLIEST_ACCEPTABLE_DATE             =>  p_l_EARLIEST_ACCEPTABLE_DATE     ,
       p_EXPLOSION_DATE                       =>  p_l_EXPLOSION_DATE               ,
       p_LATEST_ACCEPTABLE_DATE               =>  p_l_LATEST_ACCEPTABLE_DATE       ,
       p_MODEL_GROUP_NUMBER                   =>  p_l_MODEL_GROUP_NUMBER           ,
       p_SCHEDULE_ARRIVAL_DATE                =>  p_l_SCHEDULE_ARRIVAL_DATE        ,
       p_SHIP_MODEL_COMPLETE_FLAG             =>  p_l_SHIP_MODEL_COMPLETE_FLAG     ,
       p_SCHEDULE_STATUS_CODE                 =>  p_l_SCHEDULE_STATUS_CODE         ,
       p_SOURCE_TYPE_CODE                     =>  p_l_SOURCE_TYPE_CODE             ,
       p_CANCELLED_FLAG                       =>  p_l_CANCELLED_FLAG               ,
       p_OPEN_FLAG                            =>  p_l_OPEN_FLAG                    ,
       p_BOOKED_FLAG                          =>  p_l_BOOKED_FLAG                  ,
       p_SALESREP_ID                          =>  p_l_SALESREP_ID                  ,
       p_RETURN_REASON_CODE                   =>  p_l_RETURN_REASON_CODE           ,
       p_ARRIVAL_SET_ID                       =>  p_l_ARRIVAL_SET_ID               ,
       p_SHIP_SET_ID                          =>  p_l_SHIP_SET_ID                  ,
       p_SPLIT_FROM_LINE_ID                   =>  p_l_SPLIT_FROM_LINE_ID            ,
       p_CUST_PRODUCTION_SEQ_NUM              =>  p_l_CUST_PRODUCTION_SEQ_NUM       ,
       p_AUTHORIZED_TO_SHIP_FLAG              =>  p_l_AUTHORIZED_TO_SHIP_FLAG       ,
       p_OVER_SHIP_REASON_CODE                =>  p_l_OVER_SHIP_REASON_CODE         ,
       p_OVER_SHIP_RESOLVED_FLAG              =>  p_l_OVER_SHIP_RESOLVED_FLAG       ,
       p_ORDERED_ITEM_ID                      =>  p_l_ORDERED_ITEM_ID               ,
       p_ITEM_IDENTIFIER_TYPE                 =>  p_l_ITEM_IDENTIFIER_TYPE          ,
       p_CONFIGURATION_ID                     =>  p_l_CONFIGURATION_ID              ,
       p_COMMITMENT_ID                        =>  p_l_COMMITMENT_ID                 ,
       p_SHIPPING_INTERFACED_FLAG             =>  p_l_SHIPPING_INTERFACED_FLAG      ,
       p_CREDIT_INVOICE_LINE_ID               =>  p_l_CREDIT_INVOICE_LINE_ID        ,
       p_FIRST_ACK_CODE                       =>  p_l_FIRST_ACK_CODE                ,
       p_FIRST_ACK_DATE                       =>  p_l_FIRST_ACK_DATE                ,
       p_LAST_ACK_CODE                        =>  p_l_LAST_ACK_CODE                 ,
       p_LAST_ACK_DATE                        =>  p_l_LAST_ACK_DATE                 ,
       p_PLANNING_PRIORITY                    =>  p_l_PLANNING_PRIORITY             ,
       p_ORDER_SOURCE_ID                      =>  p_l_ORDER_SOURCE_ID               ,
       p_ORIG_SYS_SHIPMENT_REF                =>  p_l_ORIG_SYS_SHIPMENT_REF         ,
       p_CHANGE_SEQUENCE                      =>  p_l_CHANGE_SEQUENCE               ,
       p_DROP_SHIP_FLAG                       =>  p_l_DROP_SHIP_FLAG                ,
       p_CUSTOMER_LINE_NUMBER                 =>  p_l_CUSTOMER_LINE_NUMBER          ,
       p_CUSTOMER_SHIPMENT_NUMBER             =>  p_l_CUSTOMER_SHIPMENT_NUMBER      ,
       p_CUSTOMER_ITEM_NET_PRICE              =>  p_l_CUSTOMER_ITEM_NET_PRICE       ,
       p_CUSTOMER_PAYMENT_TERM_ID             =>  p_l_CUSTOMER_PAYMENT_TERM_ID      ,
       p_FULFILLED_FLAG                       =>  p_l_FULFILLED_FLAG                ,
       p_END_ITEM_UNIT_NUMBER                 =>  p_l_END_ITEM_UNIT_NUMBER          ,
       p_CONFIG_HEADER_ID                     =>  p_l_CONFIG_HEADER_ID              ,
       p_CONFIG_REV_NBR                       =>  p_l_CONFIG_REV_NBR                 ,
       p_MFG_COMPONENT_SEQUENCE_ID            =>  p_l_MFG_COMPONENT_SEQUENCE_ID      ,
       p_SHIPPING_INSTRUCTIONS                =>  p_l_SHIPPING_INSTRUCTIONS          ,
       p_PACKING_INSTRUCTIONS                 =>  p_l_PACKING_INSTRUCTIONS           ,
       p_INVOICED_QUANTITY                    =>  p_l_INVOICED_QUANTITY              ,
       p_REF_CUSTOMER_TRX_LINE_ID             =>  p_l_REF_CUSTOMER_TRX_LINE_ID       ,
       p_SPLIT_BY                             =>  p_l_SPLIT_BY                       ,
       p_LINE_SET_ID                          =>  p_l_LINE_SET_ID                    ,
       p_SERVICE_TXN_REASON_CODE              =>  p_l_SERVICE_TXN_REASON_CODE        ,
       p_SERVICE_TXN_COMMENTS                 =>  p_l_SERVICE_TXN_COMMENTS           ,
       p_SERVICE_DURATION                     =>  p_l_SERVICE_DURATION               ,
       p_SERVICE_START_DATE                   =>  p_l_SERVICE_START_DATE             ,
       p_SERVICE_END_DATE                     =>  p_l_SERVICE_END_DATE               ,
       p_SERVICE_COTERMINATE_FLAG             =>  p_l_SERVICE_COTERMINATE_FLAG       ,
       p_UNIT_LIST_PERCENT                    =>  p_l_UNIT_LIST_PERCENT              ,
       p_UNIT_SELLING_PERCENT                 =>  p_l_UNIT_SELLING_PERCENT           ,
       p_UNIT_PERCENT_BASE_PRICE              =>  p_l_UNIT_PERCENT_BASE_PRICE        ,
       p_SERVICE_NUMBER                       =>  p_l_SERVICE_NUMBER                 ,
       p_SERVICE_PERIOD                       =>  p_l_SERVICE_PERIOD         ,
       p_SHIPPABLE_FLAG                       =>  p_l_SHIPPABLE_FLAG         ,
       p_MODEL_REMNANT_FLAG                   =>  p_l_MODEL_REMNANT_FLAG     ,
       p_RE_SOURCE_FLAG                       =>  p_l_RE_SOURCE_FLAG         ,
       p_FLOW_STATUS_CODE                     =>  p_l_FLOW_STATUS_CODE       ,
       p_TP_CONTEXT                           =>  p_l_TP_CONTEXT             ,
       p_TP_ATTRIBUTE1                        =>  p_l_TP_ATTRIBUTE1          ,
       p_TP_ATTRIBUTE2                        =>  p_l_TP_ATTRIBUTE2          ,
       p_TP_ATTRIBUTE3                        =>  p_l_TP_ATTRIBUTE3          ,
       p_TP_ATTRIBUTE4                        =>  p_l_TP_ATTRIBUTE4          ,
       p_TP_ATTRIBUTE5                        =>  p_l_TP_ATTRIBUTE5          ,
       p_TP_ATTRIBUTE6                        =>  p_l_TP_ATTRIBUTE6          ,
       p_TP_ATTRIBUTE7                        =>  p_l_TP_ATTRIBUTE7          ,
       p_TP_ATTRIBUTE8                        =>  p_l_TP_ATTRIBUTE8          ,
       p_TP_ATTRIBUTE9                        =>  p_l_TP_ATTRIBUTE9          ,
       p_TP_ATTRIBUTE10                       =>  p_l_TP_ATTRIBUTE10         ,
       p_TP_ATTRIBUTE11                       =>  p_l_TP_ATTRIBUTE11         ,
       p_TP_ATTRIBUTE12                       =>  p_l_TP_ATTRIBUTE12         ,
       p_TP_ATTRIBUTE13                       =>  p_l_TP_ATTRIBUTE13         ,
       p_TP_ATTRIBUTE14                       =>  p_l_TP_ATTRIBUTE14         ,
       p_TP_ATTRIBUTE15                       =>  p_l_TP_ATTRIBUTE15         ,
       p_FULFILLMENT_METHOD_CODE              =>  p_l_FULFILLMENT_METHOD_CODE        ,
       p_MARKETING_SOURCE_CODE_ID             =>  p_l_MARKETING_SOURCE_CODE_ID       ,
       p_SERVICE_REF_TYPE_CODE                =>  p_l_SERVICE_REF_TYPE_CODE          ,
       p_SERVICE_REFERENCE_LINE_ID            =>  p_l_SERVICE_REFERENCE_LINE_ID      ,
       p_SERVICE_REF_SYSTEM_ID                =>  p_l_SERVICE_REF_SYSTEM_ID          ,
       p_CALCULATE_PRICE_FLAG                 =>  p_l_CALCULATE_PRICE_FLAG           ,
       p_UPGRADED_FLAG                        =>  p_l_UPGRADED_FLAG                  ,
       p_REVENUE_AMOUNT                       =>  p_l_REVENUE_AMOUNT                 ,
       p_FULFILLMENT_DATE                     =>  p_l_FULFILLMENT_DATE               ,
       p_PREFERRED_GRADE                      =>  p_l_PREFERRED_GRADE                ,
       p_ORDERED_QUANTITY2                    =>  p_l_ORDERED_QUANTITY2              ,
       p_ORDERED_QUANTITY_UOM2                =>  p_l_ORDERED_QUANTITY_UOM2          ,
       p_SHIPPING_QUANTITY2                   =>  p_l_SHIPPING_QUANTITY2             ,
       p_CANCELLED_QUANTITY2                  =>  p_l_CANCELLED_QUANTITY2            ,
       p_SHIPPED_QUANTITY2                    =>  p_l_SHIPPED_QUANTITY2              ,
       p_SHIPPING_QUANTITY_UOM2               =>  p_l_SHIPPING_QUANTITY_UOM2         ,
       p_FULFILLED_QUANTITY2                  =>  p_l_FULFILLED_QUANTITY2            ,
       p_MFG_LEAD_TIME                        =>  p_l_MFG_LEAD_TIME                  ,
       p_LOCK_CONTROL                         =>  p_l_LOCK_CONTROL                   ,
       p_SUBINVENTORY                         =>  p_l_SUBINVENTORY                   ,
       p_UNIT_LIST_PRICE_PER_PQTY             =>  p_l_UNIT_LIST_PRICE_PER_PQTY       ,
       p_UNIT_SELL_PRICE_PER_PQTY             =>  p_l_UNIT_SELL_PRICE_PER_PQTY      ,
       p_PRICE_REQUEST_CODE                   =>  p_l_PRICE_REQUEST_CODE            ,
       p_ORIGINAL_INVENTORY_ITEM_ID           =>  p_l_ORIGINAL_INVENTORY_ITEM_ID    ,
       p_ORIGINAL_ORDERED_ITEM_ID             =>  p_l_ORIGINAL_ORDERED_ITEM_ID      ,
       p_ORIGINAL_ORDERED_ITEM                =>  p_l_ORIGINAL_ORDERED_ITEM         ,
       p_ORIGINAL_ITEM_IDENTIF_TYPE           =>  p_l_ORIGINAL_ITEM_IDENTIF_TYPE    ,
       p_ITEM_SUBSTIT_TYPE_CODE               =>  p_l_ITEM_SUBSTIT_TYPE_CODE        ,
       p_OVERRIDE_ATP_DATE_CODE               =>  p_l_OVERRIDE_ATP_DATE_CODE        ,
       p_LATE_DEMAND_PENALTY_FACTOR           =>  p_l_LATE_DEMAND_PENALTY_FACTOR    ,
       p_ACCOUNTING_RULE_DURATION             =>  p_l_ACCOUNTING_RULE_DURATION      ,
       p_top_model_line_index                 =>  p_l_top_model_line_index          ,
       p_top_model_line_ref                   =>  p_l_top_model_line_ref            ,
       p_unit_cost                            =>  p_l_unit_cost                     ,
       p_xml_transaction_type_code            =>  p_l_xml_transaction_type_code     ,
       p_Sold_to_address_id                   =>  p_l_Sold_to_address_id            ,
       p_Split_Action_Code                    =>  p_l_Split_Action_Code             ,
       p_split_from_line_ref                  =>  p_l_split_from_line_ref           ,
       p_split_from_shipment_ref              =>  p_l_split_from_shipment_ref       ,
       p_status_flag                          =>  p_l_status_flag                   ,
       p_ship_from_edi_loc_code               =>  p_l_ship_from_edi_loc_code   ,
       p_ship_set                             =>  p_l_ship_set                      ,
       p_Ship_to_address_code                 =>  p_l_Ship_to_address_code          ,
       p_Ship_to_address_id                   =>  p_l_Ship_to_address_id            ,
       p_ship_to_customer_id                  =>  p_l_ship_to_customer_id           ,
       p_ship_to_edi_location_code            =>  p_l_ship_to_edi_location_code     ,
       p_service_ref_line_number              =>  p_l_service_ref_line_number       ,
       p_service_ref_option_number            =>  p_l_service_ref_option_number     ,
       p_service_ref_order_number             =>  p_l_service_ref_order_number      ,
       p_service_ref_ship_number              =>  p_l_service_ref_ship_number       ,
       p_service_reference_line               =>  p_l_service_reference_line        ,
       p_service_reference_order              =>  p_l_service_reference_order       ,
       p_service_reference_system             =>  p_l_service_reference_system      ,
       p_reserved_quantity                    =>  p_l_reserved_quantity             ,
       p_return_status                        =>  p_l_return_status                 ,
       p_schedule_action_code                 =>  p_l_schedule_action_code          ,
       p_service_line_index                   =>  p_l_service_line_index            ,
       p_intermed_ship_to_cont_id             =>  p_l_intermed_ship_to_cont_id      ,
       p_intermed_ship_to_org_id              =>  p_l_intermed_ship_to_org_id       ,
       p_Invoice_address_id                   =>  p_l_Invoice_address_id            ,
       p_invoice_to_customer_id               =>  p_l_invoice_to_customer_id        ,
       p_item_relationship_type               =>  p_l_item_relationship_type        ,
       p_link_to_line_index                   =>  p_l_link_to_line_index            ,
       p_link_to_line_ref                     =>  p_l_link_to_line_ref              ,
       p_db_flag                              =>  p_l_db_flag                       ,
       p_deliver_to_customer_id               =>  p_l_deliver_to_customer_id        ,
       p_fulfillment_set                      =>  p_l_fulfillment_set               ,
       p_fulfillment_set_id                   =>  p_l_fulfillment_set_id            ,
       p_change_comments                      =>  p_l_change_comments               ,
       p_change_reason                        =>  p_l_change_reason                 ,
       p_change_request_code                  =>  p_l_change_request_code           ,
       p_Bill_to_Edi_Location_Code            =>  p_l_Bill_to_Edi_Location_Code     ,
       p_Blanket_Line_Number                  =>  p_l_Blanket_Line_Number           ,
       p_Blanket_Number                       =>  p_l_Blanket_Number                ,
       p_Blanket_Version_Number               =>  p_l_Blanket_Version_Number       ,
       p_arrival_set      =>  p_l_arrival_set   ,
       p_attribute16      =>  p_l_attribute16   ,
       p_attribute17      =>  p_l_attribute17   ,
       p_attribute18      =>  p_l_attribute18   ,
       p_attribute19      =>  p_l_attribute19   ,
       p_attribute20      =>  p_l_attribute20

  );

  -- CALLING SAVE() API

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('In Returns SaveWrapper  - B4 calling order_pvt' || p_c_CHKCONSTRAINT_FLAG);
  END IF;


  IF (p_c_CHKCONSTRAINT_FLAG = 'Y') THEN
    IBE_Order_Save_Pvt.CheckConstraint
    (
     p_api_version_number       => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,p_commit                   => p_commit
    ,p_order_header_rec         => l_order_header_rec
    ,p_order_line_tbl           => l_order_line_tbl
    ,p_submit_control_rec       => l_ctrl_rec
    ,p_party_id                 => p_party_id
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
    ,x_error_lineids            => x_error_lineids
    ,x_last_update_date         => x_last_update_date
   );
ELSE

    IBE_Order_Save_PVT.Save(
    p_api_version_number        => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,p_commit                   => p_commit
    ,p_order_header_rec         => l_order_header_rec
    ,p_order_line_tbl           => l_order_line_tbl
    ,p_submit_control_rec       => l_ctrl_rec
    ,p_save_type                => p_save_type
    ,p_party_id                 => p_party_id
    ,p_shipto_partysite_id      => p_shipto_partysite_id
    ,p_billto_partysite_id      => p_billto_partysite_id
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
    ,x_order_header_id          => x_order_header_id
    ,x_order_number             => x_order_number
    ,x_flow_status_code         => x_flow_status_code
    ,x_last_update_date         => x_last_update_date
    ,X_failed_line_ids          => X_failed_line_ids --3272918
);

END IF;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('In Returns SaveWrapper package body - End');
END IF;

END SaveWrapper;

END IBE_Order_W1_PVT;

/
